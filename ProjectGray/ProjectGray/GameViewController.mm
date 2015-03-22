//
//  GameViewController.m
//  ProjectGray
//
//  Created by Tim Wang on 2015-01-30.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#import "GameViewController.h"
#import <OpenGLES/ES2/glext.h>
#import "Camera.h"
#import "Game.h"
#import "SoundManager.h"
#import "background.h"
#include "HexCells.h"
#include "GLProgramUtils.h"
#import "GameObject.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))


// Uniform index.
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    UNIFORM_TRANSLATION_MATRIX,
    UNIFORM_TEXTURE,
    UNIFORM_HEX_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_HEX_COLOUR,
    UNIFORM_UNIT_TEXTURE,
    NUM_UNIFORMS,
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    NUM_ATTRIBUTES
};

@interface GameViewController () {
    GLuint _program;
    GLuint _hexProgram;
    
    float _rotation;
    
    GLuint _vertexVikingArray[3];
    GLuint _vertexVikingBuffer[3];
    GLuint _normalVikingArray[3];
    GLuint _normalVikingBuffer[3];
    GLuint _vertexGrayArray[3];
    GLuint _vertexGrayBuffer[3];
    GLuint _normalGrayArray[3];
    GLuint _normalGrayBuffer[3];
    GLuint _vertexVikingItemArray[3];
    GLuint _vertexVikingItemBuffer[3];
    GLuint _normalVikingItemArray[3];
    GLuint _normalVikingItemBuffer[3];
    GLuint _vertexGrayItemArray[3];
    GLuint _vertexGrayItemBuffer[3];
    GLuint _normalGrayItemArray[3];
    GLuint _normalGrayItemBuffer[3];

    Camera *_camera;
    
    GLuint _vertexHexArray;
    GLuint _vertexHexBuffer;
    HexCells *hexCells;
    GLfloat instanceVertices[91][16];
    
    GLuint _vertexBGArray;
    GLuint _vertexBGBuffer;
    
    GLuint _vikingTexture;
    GLuint _grayTexture;
    GLuint _vikingBrokenTexture;
    GLuint _grayBrokenTexture;
    GLuint _bgTexture;
    GLuint _itemTexture;
    
    NSMutableArray* graySelectableRange;
    NSMutableArray* vikingsSelectableRange;

}

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

- (void)setupGL;
- (void)tearDownGL;

- (BOOL)loadShaders;

/**
 * Draws all units in the given list with the vertex array and given program.
 *
 * @param units    The array of units to be drawn.
 * @param vertices An identifier (created by OpenGL) for the vertex array for the particular unit.
 * @param program  The OpenGL program to use.
 */
- (void) drawUnits: (NSMutableArray *)units withVertices: (GLuint*)vertices usingProgram: (GLuint)program andIsAlive:(bool) isAlive;
@end

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [SoundManager sharedManager].allowsBackgroundMusic = YES;
    [[SoundManager sharedManager] prepareToPlay];
    [[SoundManager sharedManager] playMusic:@"track1.caf" looping:YES];
    
    UIPinchGestureRecognizer *pinchZoom = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(doPinch:)];
    [self.view addGestureRecognizer:pinchZoom];
    
    UIPanGestureRecognizer *fingerDrag = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(doPan:)];
    fingerDrag.maximumNumberOfTouches = 1;
    fingerDrag.minimumNumberOfTouches = 1;
    [self.view addGestureRecognizer:fingerDrag];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    hexCells = _game.map;

     _camera = [[Camera alloc] initWithWidth:self.view.bounds.size.width WithHeight: self.view.bounds.size.height WithRadius:hexCells.N];
    
    graySelectableRange = [_game.map graysSelectableRange];
    vikingsSelectableRange = [_game.map vikingsSelectableRange];
    
    [self setupGL];
}


- (void)dealloc
{
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }
    
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    [self loadShaders];
    
    glEnable(GL_CULL_FACE);
    glCullFace(GL_BACK);
    
    self.effect = [[GLKBaseEffect alloc] init];
    self.effect.light0.enabled = GL_TRUE;
    self.effect.light0.diffuseColor = GLKVector4Make(1.0f, 0.4f, 0.4f, 1.0f);
    
    glEnable(GL_DEPTH_TEST);
    
    glGenVertexArraysOES(1, &_vertexHexArray);
    glBindVertexArrayOES(_vertexHexArray);
    
    // Hex stuff
    GLfloat vertices[16];
    
    int centerX = 0;
    int centerY = 0;
    GLfloat size = 0.2;
    GLfloat angle = 2 * M_PI / 6 * 1;
    // top tri
    vertices[0] = centerX;
    vertices[1] = centerY;
    vertices[2] = centerX + size * cos(angle);
    vertices[3] = centerY + size * sin(angle);
    angle = 2 * M_PI / 6 * 2;
    vertices[4] = centerX + size * cos(angle);
    vertices[5] = centerY + size * sin(angle);
    // top left tri
    angle = 2 * M_PI / 6 * 3;
    vertices[6] = centerX + size * cos(angle);
    vertices[7] = centerY + size * sin(angle);
    // bottom left tri
    angle = 2 * M_PI / 6 * 4;
    vertices[8] = centerX + size * cos(angle);
    vertices[9] = centerY + size * sin(angle);
    // bottom tri
    angle = 2 * M_PI / 6 * 5;
    vertices[10] = centerX + size * cos(angle);
    vertices[11] = centerY + size * sin(angle);
    // bottom right tri
    angle = 2 * M_PI / 6 * 6;
    vertices[12] = centerX + size * cos(angle);
    vertices[13] = centerY + size * sin(angle);
    // bottom right tri
    angle = 2 * M_PI / 6 * 7;
    vertices[14] = centerX + size * cos(angle);
    vertices[15] = centerY + size * sin(angle);
    
    GLuint elements[] = {
        0, 1, 2,
        0, 2, 3,
        0, 3, 4,
        0, 4, 5,
        0, 5, 6,
        0, 6, 7,
        
    };
    
    glGenBuffers(1, &_vertexHexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexHexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    // make ebo, element buffer
    GLuint ebo;
    glGenBuffers(1, &ebo);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER,
                 sizeof(elements), elements, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, BUFFER_OFFSET(0));
    
    glBindVertexArrayOES(0);
    
    NSMutableArray *instPositions = hexCells.hexPositions;
    
    for (int i = 0; i < 91; ++i)
    {
        
        for (int j = 0; j < 16; j += 2)
        {
            instanceVertices[i][j] = vertices[j] + [[instPositions objectAtIndex: i * 2] floatValue];
            instanceVertices[i][j + 1] = vertices[j + 1] + [[instPositions objectAtIndex: i * 2 + 1] floatValue];
        }
    }
    
    // viking light
    glGenVertexArraysOES(1, &_vertexVikingArray[LIGHT]);
    glBindVertexArrayOES(_vertexVikingArray[LIGHT]);
    
    glGenBuffers(1, &_vertexVikingBuffer[LIGHT]);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexVikingBuffer[LIGHT]);
    glBufferData(GL_ARRAY_BUFFER, shipVertexCounts[VIKINGS][LIGHT] * sizeof(float) * 8, shipModels[VIKINGS][LIGHT], GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(12));
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(24));
    
    glBindVertexArrayOES(0);
    
    // Viking Medium
    glGenVertexArraysOES(1, &_vertexVikingArray[MEDIUM]);
    glBindVertexArrayOES(_vertexVikingArray[MEDIUM]);
    
    glGenBuffers(1, &_vertexVikingBuffer[MEDIUM]);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexVikingBuffer[MEDIUM]);
    glBufferData(GL_ARRAY_BUFFER, shipVertexCounts[VIKINGS][MEDIUM] * sizeof(float) * 8, shipModels[VIKINGS][MEDIUM], GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(12));
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(24));
    
    glBindVertexArrayOES(0);

    // Viking Heavy
    glGenVertexArraysOES(1, &_vertexVikingArray[HEAVY]);
    glBindVertexArrayOES(_vertexVikingArray[HEAVY]);
    
    glGenBuffers(1, &_vertexVikingBuffer[HEAVY]);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexVikingBuffer[HEAVY]);
    glBufferData(GL_ARRAY_BUFFER, shipVertexCounts[VIKINGS][HEAVY] * sizeof(float) * 8, shipModels[VIKINGS][HEAVY], GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(12));
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(24));
    
    glBindVertexArrayOES(0);
    
    // gray light
    glGenVertexArraysOES(1, &_vertexGrayArray[LIGHT]);
    glBindVertexArrayOES(_vertexGrayArray[LIGHT]);
    
    glGenBuffers(1, &_vertexGrayBuffer[LIGHT]);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexGrayBuffer[LIGHT]);
    glBufferData(GL_ARRAY_BUFFER, shipVertexCounts[ALIENS][LIGHT] * sizeof(float) * 8, shipModels[ALIENS][LIGHT], GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(12));
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(24));
    
    glBindVertexArrayOES(0);
    
    // gray Medium
    glGenVertexArraysOES(1, &_vertexGrayArray[MEDIUM]);
    glBindVertexArrayOES(_vertexGrayArray[MEDIUM]);
    
    glGenBuffers(1, &_vertexGrayBuffer[MEDIUM]);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexGrayBuffer[MEDIUM]);
    glBufferData(GL_ARRAY_BUFFER, shipVertexCounts[ALIENS][MEDIUM] * sizeof(float) * 8, shipModels[ALIENS][MEDIUM], GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(12));
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(24));
    
    glBindVertexArrayOES(0);

    // gray Heavy
    glGenVertexArraysOES(1, &_vertexGrayArray[HEAVY]);
    glBindVertexArrayOES(_vertexGrayArray[HEAVY]);
    
    glGenBuffers(1, &_vertexGrayBuffer[HEAVY]);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexGrayBuffer[HEAVY]);
    glBufferData(GL_ARRAY_BUFFER, shipVertexCounts[ALIENS][HEAVY] * sizeof(float) * 8, shipModels[ALIENS][HEAVY], GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(12));
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(24));
    
    glBindVertexArrayOES(0);
    
    // set up items
    [self setupItems];
    
    
    //Background vertices
    glGenVertexArraysOES(1, &_vertexBGArray);
    glBindVertexArrayOES(_vertexBGArray);
    
    glGenBuffers(1, &_vertexBGBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBGBuffer);
    glBufferData(GL_ARRAY_BUFFER, bgNumVerts * sizeof(float) * 8, bgVerts, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(12));
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(24));
    
    glBindVertexArrayOES(0);
    
    _vikingTexture = [GLProgramUtils setupTexture:@"VikingDiff.png"];
    _grayTexture = [GLProgramUtils setupTexture:@"GrayDiff.png"];
    _vikingBrokenTexture = [GLProgramUtils setupTexture:@"Pause.png"];
    _grayBrokenTexture = [GLProgramUtils setupTexture:@"EndTurn.png"];
    _bgTexture = [GLProgramUtils setupTexture:@"Spaaaace.jpg"];
    _itemTexture = [GLProgramUtils setupTexture:@"factionitem.png"];
}

- (void)setupItems
{
    // Item: cannonball
    glGenVertexArraysOES(1, &_vertexVikingItemArray[PROJECTILE]);
    glBindVertexArrayOES(_vertexVikingItemArray[PROJECTILE]);
    
    glGenBuffers(1, &_vertexVikingItemBuffer[PROJECTILE]);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexVikingItemBuffer[PROJECTILE]);
    glBufferData(GL_ARRAY_BUFFER, factionVertexCounts[VIKINGS][PROJECTILE] * sizeof(float) * 8, factionModels[VIKINGS][PROJECTILE], GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(12));
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(24));
    
    glBindVertexArrayOES(0);
    
    // Item: laser
    glGenVertexArraysOES(1, &_vertexGrayItemArray[PROJECTILE]);
    glBindVertexArrayOES(_vertexGrayItemArray[PROJECTILE]);
    
    glGenBuffers(1, &_vertexGrayItemBuffer[PROJECTILE]);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexGrayItemBuffer[PROJECTILE]);
    glBufferData(GL_ARRAY_BUFFER, factionVertexCounts[ALIENS][PROJECTILE] * sizeof(float) * 8, factionModels[ALIENS][PROJECTILE], GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(12));
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(24));
    
    glBindVertexArrayOES(0);
    
    // Item: Viking Flag
    glGenVertexArraysOES(1, &_vertexVikingItemArray[FLAG]);
    glBindVertexArrayOES(_vertexVikingItemArray[FLAG]);
    
    glGenBuffers(1, &_vertexVikingItemBuffer[FLAG]);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexVikingItemBuffer[FLAG]);
    glBufferData(GL_ARRAY_BUFFER, factionVertexCounts[VIKINGS][FLAG] * sizeof(float) * 8, factionModels[VIKINGS][FLAG], GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(12));
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(24));
    
    glBindVertexArrayOES(0);
    
    // Item: Gray Flag
    glGenVertexArraysOES(1, &_vertexGrayItemArray[FLAG]);
    glBindVertexArrayOES(_vertexGrayItemArray[FLAG]);
    
    glGenBuffers(1, &_vertexGrayItemBuffer[FLAG]);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexGrayItemBuffer[FLAG]);
    glBufferData(GL_ARRAY_BUFFER, factionVertexCounts[ALIENS][FLAG] * sizeof(float) * 8, factionModels[ALIENS][FLAG], GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(12));
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(24));
    
    glBindVertexArrayOES(0);
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    for(int i = 0; i < NUM_CLASSES; i++)
    {
        glDeleteBuffers(1, &_vertexVikingBuffer[i]);
        glDeleteBuffers(1, &_vertexGrayBuffer[i]);
        
        glDeleteBuffers(1, &_normalVikingBuffer[i]);
        glDeleteBuffers(1, &_normalGrayBuffer[i]);
        
        glDeleteVertexArraysOES(1, &_vertexVikingArray[i]);
        glDeleteVertexArraysOES(1, &_vertexGrayArray[i]);
    }
    
    _camera = nil;
    _game = nil;
    
    glDeleteBuffers(1, &_vertexBGBuffer);
    glDeleteVertexArraysOES(1, &_vertexHexArray);
    
    self.effect = nil;
    
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
    if (_hexProgram) {
        glDeleteProgram(_hexProgram);
        _hexProgram = 0;
    }
}

-(IBAction)doPinch:(UIPinchGestureRecognizer *)recognizer
{
    BOOL didBegin;
    if([(UIPinchGestureRecognizer*)recognizer state] == UIGestureRecognizerStateBegan)
        didBegin = YES;
    else
        didBegin = NO;
    
    [_camera ZoomDidBegin:didBegin Scale: recognizer.scale];
}

-(IBAction)doPan:(UIPanGestureRecognizer *)recognizer
{
    BOOL didBegin;
    if([recognizer state] == UIGestureRecognizerStateBegan)
        didBegin = YES;
    else
        didBegin = NO;
    
    CGPoint translation = [recognizer translationInView:recognizer.view];
    float x = translation.x/recognizer.view.frame.size.width;
    float y = translation.y/recognizer.view.frame.size.height;
    
    [_camera PanDidBegin:didBegin X:x Y:y];
}

/*!
 * Unproject the screen point (from http://whackylabs.com/rants/?p=1043 ) and intersect it against the xy-plane to pick a hex cell.
 */
- (IBAction)doTap:(UITapGestureRecognizer *)sender {
    
    CGPoint screenTouch = [sender locationInView:self.view]; // The screen coordinates of the touch
    GLKVector2 touchLocation;                                // The location of the touch in clip space
    GLKVector4 near, far;                                    // The near and far points of the ray (in homogenous coordinates)
    GLKVector4 rayDirection;                                 // The ray for checking intersections
    GLKMatrix4 inverseMVP;                                   // The inverse of the model-view-projection matrix
    
    // Flip the y coordinate so that it goes from the bottom left corner (as OpenGL prefers)
    screenTouch.y = [self.view bounds].size.height - screenTouch.y;
    
    // Convert the screen touches into devices coordinates (between [-1, 1])
    screenTouch.x /= self.view.frame.size.width;
    screenTouch.y /= self.view.frame.size.height;

    screenTouch.x *= 2;
    screenTouch.y *= 2;
    
    screenTouch.x -= 1;
    screenTouch.y -= 1;
    
    touchLocation = GLKVector2Make(screenTouch.x, screenTouch.y);
    
    // Calculate the points where the ray intersects with the near and far clipping planes
    near = GLKVector4Make(touchLocation.x, touchLocation.y, -1.0f, 1.0f);
    far = GLKVector4Make(touchLocation.x, touchLocation.y, 1.0f, 1.0f);
    
    inverseMVP = GLKMatrix4Invert(_camera.modelViewProjectionMatrix, NULL);
    near = GLKMatrix4MultiplyVector4(inverseMVP, near);
    far = GLKMatrix4MultiplyVector4(inverseMVP, far);
    
    // Homogenous coordinates, so need to divide by w
    near = GLKVector4DivideScalar(near, near.w);
    far = GLKVector4DivideScalar(far, far.w);
    
    // Get direction from touched point to end of clipping plane
    rayDirection = GLKVector4Normalize(GLKVector4Subtract(far, near));
    
    // Let vector v be the direction from near point to far point
    // Solve for t (parametric equation)
    // x = t(A) + xi; y = t(B) + yi; z = t(C) + zi
    // We know that hexagons are rendered in the xy plane, so the plane's equation is z = 0
    // The z-coordinate on our near to far vector: z = t * (k component of near to far vector) + zi
    // Since z = 0, we can say that t(vk) + zi = 0
    // Rearranged, we get t = -zi / vk
    float t = -near.z / rayDirection.z;
    
    // Use t to determine how far we go in the x and y directions
    GLKVector3 worldPoint = GLKVector3Make((t * rayDirection.x) + near.x, (t * rayDirection.y) + near.y, (t * rayDirection.z) + near.z);
    
    Hex* pickedTile = [hexCells closestHexToWorldPosition:GLKVector2Make(worldPoint.x, worldPoint.y) WithinHexagon:TRUE];
        
    if(_game.state == SELECTION)
        [_game selectTile: pickedTile WithAlienRange:graySelectableRange WithVikingRange:vikingsSelectableRange];
    else
        [_game selectTile: pickedTile];
    
    [[SoundManager sharedManager] playSound:@"select.wav" looping:NO];
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    [_camera UpdateWithWidth:self.view.frame.size.width AndHeight: self.view.frame.size.height];
    
    self.effect.transform.projectionMatrix = _camera.projectionMatrix;
    
    self.effect.transform.modelviewMatrix = _camera.modelViewMatrix;
    
    switch([_game checkForWin])
    {
        case VIKINGS:
        {
            _winLabel.text = @"Vikings Win!!";
            break;
        }
        case ALIENS:
        {
            _winLabel.text = @"Grays Win!!";
            break;
        }
        default:
        {
            _winLabel.text = @"";
        }
    }
    
    _attackLabel.text = @""; //[UnitActions getAttackInfo];
    
    if(_game.selectedUnit)
    {
        _statsBackground.hidden = NO;
        Unit* seld = _game.selectedUnit;
        NSString *stats = [NSString stringWithFormat:@"Hull: %d\rAttack Range: %d\rDamage: %d\rMovement Range: %d\rAccuracy: %.2f\rAction Points: %d\rShip Health: %d",
                           seld.stats->hull,
                           seld.stats->attackRange,
                           seld.stats->damage,
                           seld.moveRange,
                           seld.stats->accuracy,
                           seld.stats->actionPool,
                           seld.stats->shipHealth];
        _statsLabel.text = stats;
    }
    else
    {
        _statsBackground.hidden = YES;
        _statsLabel.text = @"";
    }
    
    [_game.map clearColours];
    if(_game.state == PLAYING)
    {
        if (_game.selectedUnit != nil)
        {
            NSMutableArray* movableRange;
            movableRange = [_game.map movableRange:([_game.selectedUnit moveRange]) from:_game.selectedUnit.hex];
            for(Hex* hex in movableRange)
            {
                [hex setColour:MOVEABLE_COLOUR];
            }
            
            if(_game.whoseTurn == VIKINGS)
            {
                if ([_game.selectedUnit ableToAttack])
                {
                    for(Unit* unit in _game.p2Units)
                    {
                        if(unit.active)
                        {
                            if ([HexCells distanceFrom:_game.selectedUnit.hex toHex:unit.hex] <= _game.selectedUnit.stats->attackRange)
                            {
                                [unit.hex setColour:ATTACKABLE_COLOUR];
                            }
                        }
                    }
                }
            }
            else if (_game.whoseTurn == ALIENS)
            {
                if ([_game.selectedUnit ableToAttack])
                {
                    for(Unit* unit in _game.p1Units)
                    {
                        if(unit.active)
                        {
                            if ([HexCells distanceFrom:_game.selectedUnit.hex toHex:unit.hex] <= _game.selectedUnit.stats->attackRange)
                            {
                                [unit.hex setColour:ATTACKABLE_COLOUR];
                            }
                        }
                    }
                }
            }
            [_game.selectedUnit.hex setColour:SELECTED_COLOUR];
        }
    }
    else if(_game.state == SELECTION)
    {
        if(_game.whoseTurn == ALIENS)
        {
            for(Hex* hex in graySelectableRange)
            {
                [hex setColour:GRAY_PLACEMENT_COLOUR];
            }
        }
        else if(_game.whoseTurn == VIKINGS)
        {
            for(Hex* hex in vikingsSelectableRange)
            {
                [hex setColour:VIKING_PLACEMENT_COLOUR];
            }
        }
    }
    
    [[Game taskManager] runTasksWithCurrentTime: [NSDate timeIntervalSinceReferenceDate]];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glBindTexture(GL_TEXTURE_2D, _bgTexture);
    [self draw:bgNumVerts withVertices:_vertexBGArray usingProgram:_program];
    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
    
    // Hex stuff
    glBindVertexArrayOES(_vertexHexArray);
    glUseProgram(_hexProgram);
    
    glUniformMatrix4fv(uniforms[UNIFORM_HEX_MODELVIEWPROJECTION_MATRIX], 1, 0, _camera.modelViewProjectionMatrix.m);
    
    int hexCount = hexCells.N;
    
    for (int q = 0; q <= hexCount; ++q)
    {
        for (int r = -hexCount; r <= hexCount - q; ++r)
        {
            Hex *hex = ((Hex *)[hexCells hexAtQ:q andR:r]);
            
            GLKVector4 colour = hex.colour;
            
            glUniform4f(uniforms[UNIFORM_HEX_COLOUR], colour.r, colour.g, colour.b, colour.a);
            
            glBindBuffer(GL_ARRAY_BUFFER, _vertexHexBuffer);
            glBufferData(GL_ARRAY_BUFFER, sizeof(instanceVertices[hex.instanceVertexIndex]), instanceVertices[hex.instanceVertexIndex], GL_STATIC_DRAW);
            
            glDrawElements(GL_TRIANGLES, 18, GL_UNSIGNED_INT, 0);
        }
    }
    // left side of hex
    for (int q = -1; q >= -hexCount; --q)
    {
        for (int r = hexCount; r >= -hexCount - q; --r)
        {
            Hex *hex = ((Hex *)[hexCells hexAtQ:q andR:r]);
            
            GLKVector4 colour = hex.colour;
            
            glUniform4f(uniforms[UNIFORM_HEX_COLOUR], colour.r, colour.g, colour.b, colour.a);
            
            glBindBuffer(GL_ARRAY_BUFFER, _vertexHexBuffer);
            glBufferData(GL_ARRAY_BUFFER, sizeof(instanceVertices[hex.instanceVertexIndex]), instanceVertices[hex.instanceVertexIndex], GL_STATIC_DRAW);
            
            glDrawElements(GL_TRIANGLES, 18, GL_UNSIGNED_INT, 0);
        }
    }
    glDisable(GL_BLEND);

    
    glActiveTexture(GL_TEXTURE0);
    glUniform1i(uniforms[UNIFORM_UNIT_TEXTURE], 0);
    
    glBindTexture(GL_TEXTURE_2D, _vikingTexture);
    [self drawUnits:_game.p1Units withVertices:_vertexVikingArray usingProgram:_program andIsAlive:YES];
    glBindTexture(GL_TEXTURE_2D, _grayTexture);
    [self drawUnits:_game.p2Units withVertices:_vertexGrayArray usingProgram:_program andIsAlive:YES];
    
    glBindTexture(GL_TEXTURE_2D, _vikingBrokenTexture);
    [self drawUnits:_game.p1Units withVertices:_vertexVikingArray usingProgram:_program andIsAlive:NO];
    glBindTexture(GL_TEXTURE_2D, _grayBrokenTexture);
    [self drawUnits:_game.p2Units withVertices:_vertexGrayArray usingProgram:_program andIsAlive:NO];
}

- (void) draw:(float) numVerts withVertices: (GLuint)vertices usingProgram: (GLuint)program
{
    GLKMatrix4 _transMat;
    GLKMatrix4 _scaleMat;
    glBindVertexArrayOES(vertices);
    glUseProgram(program);
    
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _camera.modelViewProjectionMatrix.m);
    _transMat = GLKMatrix4Translate(_camera.modelViewMatrix, 0, 0, -6);
    _scaleMat = GLKMatrix4MakeScale(4, 4, 4);
    _transMat = GLKMatrix4Multiply(_transMat, _scaleMat);
    _transMat = GLKMatrix4Multiply(_camera.projectionMatrix, _transMat);
    
    GLKMatrix4 _transNorm = GLKMatrix4MakeScale(4, 4, 4);
    _transNorm = GLKMatrix4Multiply(_transNorm, GLKMatrix4MakeTranslation(0, 0, -6));
    _transNorm = GLKMatrix4Multiply(_camera.modelViewMatrix, _transNorm);
    
    GLKMatrix3 tempNorm = GLKMatrix4GetMatrix3(GLKMatrix4InvertAndTranspose(_transNorm, 0));
    
    glUniformMatrix4fv(uniforms[UNIFORM_TRANSLATION_MATRIX], 1, 0, _transMat.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, tempNorm.m);
    
    glDrawArrays(GL_TRIANGLES, 0, numVerts);

}

- (void) drawUnits: (NSMutableArray *)units withVertices: (GLuint*)vertices usingProgram: (GLuint)program andIsAlive:(bool) isAlive {
    NSUInteger numUnits = [units count];

    for(unsigned int i = 0; i < numUnits; i++)
    {
        Unit* curUnit = (Unit*)units[i];
        
        if(_game.state == SELECTION)
            if(curUnit.hex == nil)
                continue;
        
        if(curUnit.active == isAlive)
        {
            GLKMatrix4 _transMat;
            GLKMatrix4 _scaleMat;
            glBindVertexArrayOES(vertices[((Unit*)curUnit).shipClass]);
            glUseProgram(program);
            
            glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _camera.modelViewProjectionMatrix.m);
            _transMat = GLKMatrix4Translate(_camera.modelViewMatrix, curUnit.position.x, curUnit.position.y, curUnit.position.z);
            _scaleMat = GLKMatrix4MakeScale(curUnit.scale, curUnit.scale, curUnit.scale);
            _transMat = GLKMatrix4Multiply(_transMat, _scaleMat);
            _transMat = GLKMatrix4Multiply(_camera.projectionMatrix, _transMat);
            
            GLKMatrix4 _transNorm = GLKMatrix4MakeScale(curUnit.scale, curUnit.scale, curUnit.scale);
            _transNorm = GLKMatrix4Multiply(_transNorm, GLKMatrix4MakeTranslation(curUnit.position.x, curUnit.position.y, curUnit.position.z));
            _transNorm = GLKMatrix4Multiply(_camera.modelViewMatrix, _transNorm);
            
            GLKMatrix3 tempNorm = GLKMatrix4GetMatrix3(GLKMatrix4InvertAndTranspose(_transNorm, 0));
            
            glUniformMatrix4fv(uniforms[UNIFORM_TRANSLATION_MATRIX], 1, 0, _transMat.m);
            glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, tempNorm.m);
            
            glDrawArrays(GL_TRIANGLES, 0, shipVertexCounts[curUnit.faction][curUnit.shipClass]);
        }
    }
}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders
{
    NSString *vertShaderPathname, *fragShaderPathname;
    NSString *vertHexShaderPathname, *fragHexShaderPathname;
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    vertHexShaderPathname = [[NSBundle mainBundle] pathForResource:@"HexShader" ofType:@"vsh"];

    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    fragHexShaderPathname = [[NSBundle mainBundle] pathForResource:@"HexShader" ofType:@"fsh"];
    
    ShaderAttribute mainProgAttrs[] = {{GLKVertexAttribPosition, "position"}, {GLKVertexAttribNormal, "normal"}, {GLKVertexAttribTexCoord0, "texCoordIn"}};
    ShaderAttribute hexProgAttrs[] = {{GLKVertexAttribPosition, "position"}};
    
    if([GLProgramUtils makeProgram: &_program withVertShader: vertShaderPathname andFragShader: fragShaderPathname
               andAttributes: mainProgAttrs withNumberOfAttributes:3])
        return NO;
    if([GLProgramUtils makeProgram: &_hexProgram withVertShader: vertHexShaderPathname andFragShader: fragHexShaderPathname
                     andAttributes: hexProgAttrs withNumberOfAttributes:1]){
        glDeleteProgram(_program);
        return NO;
    }
    
    // Get uniform locations.
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program, "normalMatrix");
    uniforms[UNIFORM_TRANSLATION_MATRIX] = glGetUniformLocation(_program, "translationMatrix");
    uniforms[UNIFORM_HEX_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_hexProgram, "modelViewProjectionMatrix");
    uniforms[UNIFORM_HEX_COLOUR] = glGetUniformLocation(_hexProgram, "color");
    uniforms[UNIFORM_UNIT_TEXTURE] = glGetUniformLocation(_program, "texture");

    return YES;
}

- (IBAction)endTurnPressed:(id)sender
{
    [sender setImage:[UIImage imageNamed:@"EndTurnPressed.png"] forState:UIControlStateHighlighted];
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [sender setImage:[UIImage imageNamed:@"EndTurnPressed.png"] forState:UIControlStateNormal];
        ((UIButton*)sender).transform = CGAffineTransformMakeScale(0.8,0.8);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            ((UIButton*)sender).transform = CGAffineTransformMakeScale(1,1);
        } completion:nil];
        
        [sender setImage:[UIImage imageNamed:@"EndTurn.png"] forState:UIControlStateNormal];
    }];
    
    [_game switchTurn];
    
    if([_game whoseTurn] == VIKINGS)
    {
        [_turnMarker setImage:[UIImage imageNamed:@"vikingsturn.png"]];
    }
    else if([_game whoseTurn] == ALIENS)
    {
        [_turnMarker setImage:[UIImage imageNamed:@"graysturn.png"]];
    }
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        ((UIView*)_turnMarker).transform = CGAffineTransformMakeScale(1.5,1.5);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            ((UIView*)_turnMarker).transform = CGAffineTransformMakeScale(1,1);
        } completion:nil];
    }];
}

- (IBAction)pausePresssed:(id)sender
{
    [sender setImage:[UIImage imageNamed:@"PausePressed.png"] forState:UIControlStateHighlighted];
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [sender setImage:[UIImage imageNamed:@"PausePressed.png"] forState:UIControlStateNormal];
        ((UIButton*)sender).transform = CGAffineTransformMakeScale(0.8,0.8);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            ((UIButton*)sender).transform = CGAffineTransformMakeScale(1,1);
        } completion:nil];
        
        [sender setImage:[UIImage imageNamed:@"Pause.png"] forState:UIControlStateNormal];
    }];
}

@end
