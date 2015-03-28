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
#import "EnvironmentStats.h"
#import "environmentmodel.h"
#import "EnvironmentEntity.h"
#import "CTFGameMode.h"
#import "SkirmishGameMode.h"
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
    UNIFORM_2D_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_2D_NORMAL_MATRIX,
    UNIFORM_2D_UNIT_TEXTURE,
    UNIFORM_2D_TRANSLATION_MATRIX,
    UNIFORM_LIGHT_POSITION,
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
    GLuint _2DProgram;
    
    float _rotation;
    
    // Ship vertices and normals
    GLuint _shipVertexArray[NUM_FACTIONS][NUM_CLASSES];
    GLuint _shipVertexBuffer[NUM_FACTIONS][NUM_CLASSES];
    
    VertexAttribute _modelVertexSpecification[3];
    
    // Item vertices and normals
    GLuint _vertexVikingItemArray[3];
    GLuint _vertexVikingItemBuffer[3];
    GLuint _vertexGrayItemArray[3];
    GLuint _vertexGrayItemBuffer[3];
    
    // Environment vertices and normals
    GLuint _vertexEnvironmentArray[1];
    GLuint _vertexEnvironmentBuffer[1];

    Camera *_camera;
    
    GLuint _vertexHexArray;
    GLuint _vertexHexBuffer;
    HexCells *hexCells;
    GLfloat instanceVertices[217][16];
    
    GLuint _vertexBGArray;
    GLuint _vertexBGBuffer;
    
    GLuint _vikingTexture;
    GLuint _grayTexture;
    GLuint _vikingBrokenTexture;
    GLuint _grayBrokenTexture;
    GLuint _bgTexture;
    GLuint _itemTexture;
    GLuint _evironmentTexture;
    
    NSMutableArray* graySelectableRange;
    NSMutableArray* vikingsSelectableRange;
    NSMutableArray* grayCaptureRange;
    NSMutableArray* vikingsCaptureRange;
    
    UILabel *hitLabel;
    
    GLKVector3 lightPos;
    GLKVector3 bgPos;
    float bgRotation;
    bool endTurnPressed;
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
    
    // Add the sound manager and start playing the main game theme
    [SoundManager sharedManager].allowsBackgroundMusic = YES;
    [[SoundManager sharedManager] prepareToPlay];
    //[[SoundManager sharedManager] playMusic:@"track1.caf" looping:YES];
    
    lightPos = GLKVector3Make(0.0, 5.0, -5.0);
    bgPos = GLKVector3Make(0.0, 0, -6.0);
    bgRotation = 0.0;
    
    // Add gesture recognisers for zooming and panning the camera
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
    
    // Retrieve the map from the Game object constructed in the unit selection screen
    hexCells = _game.map;

     _camera = [[Camera alloc] initWithWidth:self.view.bounds.size.width WithHeight: self.view.bounds.size.height WithRadius:hexCells.N];
    
    graySelectableRange = [_game.map graysSelectableRange];
    vikingsSelectableRange = [_game.map vikingsSelectableRange];
    grayCaptureRange = [_game.map setupGraysCaptureRange];
    vikingsCaptureRange = [_game.map setupVikingsCaptureRange];
    
    // Set the vertex specification that we'll use for models
    _modelVertexSpecification[0] = {GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 32, 0};
    _modelVertexSpecification[1] = {GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 32, 12};
    _modelVertexSpecification[2] = {GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 32, 24};
    
    [_selectedUnitVIew setImage:[UIImage imageNamed:[NSString stringWithUTF8String:shipImages[_game.selectedUnit.faction][_game.selectedUnit.shipClass]]]];
    
    hitLabel = [[UILabel alloc] init];
    endTurnPressed = NO;
    
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
    
    glBindVertexArrayOES(0); // End configuration for the hex tiles
    
    // Translate the hex cells by the appropriate amount in x and y depending on where they are in the map
    NSMutableArray *instPositions = hexCells.hexPositions;
    for (int i = 0; i < 217; ++i)
    {
        
        for (int j = 0; j < 16; j += 2)
        {
            instanceVertices[i][j] = vertices[j] + [[instPositions objectAtIndex: i * 2] floatValue];
            instanceVertices[i][j + 1] = vertices[j + 1] + [[instPositions objectAtIndex: i * 2 + 1] floatValue];
        }
    }
    
    // Generate and fill buffers for each ship model
    for(int faction = 0; faction < NUM_FACTIONS; faction++)
    {
        for(int shipClass = 0; shipClass < NUM_CLASSES; shipClass++)
        {
            // Creates a new array and buffer, fills the buffer, and sets the vertex specification
            [self setupVertexArray: &_shipVertexArray[faction][shipClass]
                        withBuffer: & _shipVertexBuffer[faction][shipClass]
                       andVertices: shipModels[faction][shipClass]
                   withNumVertices: shipVertexCounts[faction][shipClass]
                  usingDrawingMode: GL_STATIC_DRAW
              withVertexAttributes: _modelVertexSpecification
                  andNumAttributes: 3];
        }
    }
    
    // set up items
    [self setupItems];
    
    // set up environment
    [self setupEnvironment];
    
    // Background setup
    [self setupVertexArray:&_vertexBGArray
                withBuffer:&_vertexBGBuffer
               andVertices:bgVerts
           withNumVertices:bgNumVerts
          usingDrawingMode:GL_STATIC_DRAW
      withVertexAttributes:_modelVertexSpecification
          andNumAttributes:3];
    
    _vikingTexture = [GLProgramUtils setupTexture:@"VikingDiff.png"];
    _grayTexture = [GLProgramUtils setupTexture:@"GrayDiff.png"];
    _vikingBrokenTexture = [GLProgramUtils setupTexture:@"Pause.png"];
    _grayBrokenTexture = [GLProgramUtils setupTexture:@"EndTurn.png"];
    _bgTexture = [GLProgramUtils setupTexture:@"Spaaaace.jpg"];
    _itemTexture = [GLProgramUtils setupTexture:@"factionitem.png"];
    _evironmentTexture = [GLProgramUtils setupTexture:@"environment.png"];
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

- (void) setupEnvironment
{
    // Item: Asteroid
    glGenVertexArraysOES(1, &_vertexEnvironmentArray[ENV_ASTEROID]);
    glBindVertexArrayOES(_vertexEnvironmentArray[ENV_ASTEROID]);
    
    glGenBuffers(1, &_vertexEnvironmentBuffer[ENV_ASTEROID]);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexEnvironmentBuffer[ENV_ASTEROID]);
    glBufferData(GL_ARRAY_BUFFER, environmentVertexCounts[ENV_ASTEROID] * sizeof(float) * 8, environmentModels[ENV_ASTEROID], GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(12));
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(24));
    
    glBindVertexArrayOES(0);
}

/**
 * Tears down the GL context and all associated variables.
 * @todo Need to refactor normals such that they everything can be deleted in the same way.
 */
- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    for(int i = 0; i < NUM_CLASSES; i++)
    {
//        glDeleteBuffers(1, &_vertexVikingBuffer[i]);
//        glDeleteBuffers(1, &_vertexGrayBuffer[i]);
//        
//        glDeleteBuffers(1, &_normalVikingBuffer[i]);
//        glDeleteBuffers(1, &_normalGrayBuffer[i]);
//        
//        glDeleteVertexArraysOES(1, &_vertexVikingArray[i]);
//        glDeleteVertexArraysOES(1, &_vertexGrayArray[i]);
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
    if (_2DProgram) {
        glDeleteProgram(_2DProgram);
        _2DProgram = 0;
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

- (IBAction)scoutAbilitySelected:(id)sender
{
    _game.selectedUnitAbility = SCOUT;        
}

- (IBAction)attackAbilitySelected:(id)sender
{
    _game.selectedUnitAbility = ATTACK;
}

- (IBAction)moveAbilitySelected:(id)sender
{
    _game.selectedUnitAbility = MOVE;
}

- (IBAction)healAbilitySelected:(id)sender
{
    _game.selectedUnitAbility = HEAL;
}

- (IBAction)searchAbilitySelected:(id)sender
{
    _game.selectedUnitAbility = SEARCH;
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
    {
        [_game selectTile: pickedTile WithAlienRange:graySelectableRange WithVikingRange:vikingsSelectableRange];
    }
    else
        [_game selectTile: pickedTile];
    
    if (_game.selectedUnit.shipClass == MEDIUM)
    {
        _healAbilityButton.hidden = false;
    }
    else
    {
        _healAbilityButton.hidden = true;
    }
    
    [[SoundManager sharedManager] playSound:@"select.wav" looping:NO];
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    lightPos = GLKMatrix4MultiplyVector3(GLKMatrix4MakeRotation(0.003f, 0, 0, 1), lightPos);
    glUniform3f(uniforms[UNIFORM_LIGHT_POSITION], lightPos.x, lightPos.y, lightPos.z);
    
    if(_game.selectedUnit == nil)
    {
        [_selectedUnitVIew setImage:[UIImage imageNamed:[NSString stringWithUTF8String:""]]];
        _apLabel.hidden = YES;
    }
    else
    {
        [_selectedUnitVIew setImage:[UIImage imageNamed:[NSString stringWithUTF8String:shipImages[_game.selectedUnit.faction][_game.selectedUnit.shipClass]]]];
        _apLabel.hidden = NO;
        [_apLabel setText:[NSString stringWithFormat:@"AP: %d", _game.selectedUnit.stats->actionPool]];
    }
    
    [_camera UpdateWithWidth:self.view.frame.size.width AndHeight: self.view.frame.size.height];
    
    self.effect.transform.projectionMatrix = _camera.projectionMatrix;
    
    self.effect.transform.modelviewMatrix = _camera.modelViewMatrix;
    
    [_game update];
    
    int winner;
    
    if (_game.mode == CTF)
    {
        CTFGameMode* game = (CTFGameMode*)_game;
        winner = [game checkForFlagCaptureInVikingZone:vikingsCaptureRange andGraysZone:grayCaptureRange];
    }
    else
    {
        
        SkirmishGameMode* game = (SkirmishGameMode*)_game;
        winner = [game checkForWin];
    }
    
    switch(winner)
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
        NSString *stats = [NSString stringWithFormat:@"Hull: %f\rAttack Range: %d\rDamage: %f\rMovement Range: %d\rAccuracy: %.2f\rShip Health: %d",
                           seld.stats->hull,
                           seld.stats->attackRange,
                           seld.stats->damage,
                           seld.moveRange,
                           seld.stats->accuracy,
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
        if (_game.mode == CTF)
        {
            for(Hex* hex in vikingsCaptureRange)
            {
                [hex setColour:VIKING_CAPTURE_ZONE_COLOUR];
            }
            
            for(Hex* hex in grayCaptureRange)
            {
                [hex setColour:GRAY_CAPTURE_ZONE_COLOUR];
            }
        }
        
        if (_game.selectedUnit)
        {
            if (_game.selectedUnitAbility == MOVE)
            {
                NSMutableArray* movableRange;
                movableRange = [_game.map makeFrontierFrom:_game.selectedUnit.hex.q :_game.selectedUnit.hex.r inRangeOf:[_game.selectedUnit moveRange]];
                
                for(Hex* hex in movableRange)
                {
                    [hex setColour:MOVEABLE_COLOUR];
                }
            }
            else if (_game.selectedUnitAbility == SEARCH)
            {
                for (EnvironmentEntity* entity in _game.environmentEntities)
                {
                    if (entity.active && entity.type == ENV_ASTEROID && [HexCells distanceFrom:_game.selectedUnit.hex toHex:entity.hex] == 1 && _game.selectedUnit.stats->actionPool > 0)
                    {
                        [entity.hex setColour:ASTEROID_COLOUR];
                    }
                }
            }
            else if (_game.selectedUnitAbility == ATTACK && [_game.selectedUnit ableToAttack])
            {
                if (_game.selectedUnit.shipClass == HEAVY) {
                    for (EnvironmentEntity* entity in _game.environmentEntities)
                    {
                        if (entity.type == ENV_ASTEROID && [HexCells distanceFrom:_game.selectedUnit.hex toHex:entity.hex] == 1 &&
                            [HexCells distanceFrom:_game.selectedUnit.hex toHex:entity.hex] <= _game.selectedUnit.stats->attackRange)
                        {
                            [entity.hex setColour:ATTACKABLE_COLOUR];
                        }
                    }
                }
                
                if(_game.whoseTurn == _game.p1Faction)
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
                else if (_game.whoseTurn == _game.p2Faction)
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
            else if (_game.selectedUnitAbility == SCOUT/* && [_game.selectedUnit ableToAttack]*/)
            {
                if(_game.whoseTurn == _game.p1Faction)
                {
                    for(Unit* unit in _game.p2Units)
                    {
                        if(unit.active)
                        {
                            if ([HexCells distanceFrom:_game.selectedUnit.hex toHex:unit.hex] <= _game.selectedUnit.stats->attackRange)
                            {
                                [unit.hex setColour:SCOUT_COLOUR];
                            }
                        }
                    }
                }
                else if (_game.whoseTurn == _game.p2Faction)
                {
                    for(Unit* unit in _game.p1Units)
                    {
                        if(unit.active)
                        {
                            if ([HexCells distanceFrom:_game.selectedUnit.hex toHex:unit.hex] <= _game.selectedUnit.stats->attackRange)
                            {
                                [unit.hex setColour:SCOUT_COLOUR];
                            }
                        }
                    }
                }
            }
            else if (_game.selectedUnitAbility == HEAL && [_game.selectedUnit ableToHeal])
            {
                if(_game.whoseTurn == VIKINGS)
                {
                    for(Unit* unit in _game.p1Units)
                    {
                        if ([HexCells distanceFrom:_game.selectedUnit.hex toHex:unit.hex] <= _game.selectedUnit.stats->attackRange)
                        {
                            [unit.hex setColour:HEAL_COLOUR];
                        }
                    }
                    
                }
                else if (_game.whoseTurn == ALIENS)
                {
                    for(Unit* unit in _game.p2Units)
                    {
                        if ([HexCells distanceFrom:_game.selectedUnit.hex toHex:unit.hex] <= _game.selectedUnit.stats->attackRange)
                        {
                            [unit.hex setColour:HEAL_COLOUR];
                        }
                    }
                    
                }
            }
            
            if (_game.selectedUnit.faction == VIKINGS)
            {
                [_game.selectedUnit.hex setColour:SELECTED_VIKING_COLOUR];
            }
            else
            {
                [_game.selectedUnit.hex setColour:SELECTED_GRAY_COLOUR];
            }
            
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
    [self draw:bgNumVerts withVertices:_vertexBGArray usingProgram:_2DProgram];
    
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
    
    
    if (_game.mode == CTF)
    {
        CTFGameMode* game = (CTFGameMode*)_game;
        if (game.vikingFlagState != HIDDEN)
            [self drawFlag:game.vikingFlag ofFaction:VIKINGS withVertices:_vertexVikingItemArray usingProgram:_program];
        if (game.graysFlagState != HIDDEN)
            [self drawFlag:game.graysFlag ofFaction:ALIENS withVertices:_vertexGrayItemArray usingProgram:_program];
    }

    glActiveTexture(GL_TEXTURE0);
    glUniform1i(uniforms[UNIFORM_UNIT_TEXTURE], 0);
    
    //Draw environment hazzards
    glBindTexture(GL_TEXTURE_2D, _evironmentTexture);
    [self drawEnvironment:_game.environmentEntities withVertices: _vertexEnvironmentArray usingProgram:_program];

    //Draw Units
    glBindTexture(GL_TEXTURE_2D, _vikingTexture);
    [self drawUnits:_game.p1Units withVertices:_shipVertexArray[_game.p1Faction] usingProgram:_program andIsAlive:YES];
    glBindTexture(GL_TEXTURE_2D, _grayTexture);
    [self drawUnits:_game.p2Units withVertices:_shipVertexArray[_game.p2Faction] usingProgram:_program andIsAlive:YES];
    
    //Draw dead units
    glBindTexture(GL_TEXTURE_2D, _vikingBrokenTexture);
    [self drawUnits:_game.p1Units withVertices:_shipVertexArray[_game.p1Faction] usingProgram:_program andIsAlive:NO];
    glBindTexture(GL_TEXTURE_2D, _grayBrokenTexture);
    [self drawUnits:_game.p2Units withVertices:_shipVertexArray[_game.p2Faction] usingProgram:_program andIsAlive:NO];
    
    //Draw items
    glBindTexture(GL_TEXTURE_2D, _itemTexture);
    [self drawProjectile:_game.p1Units withVertices:_vertexVikingItemArray usingProgram:_program];
    [self drawProjectile:_game.p2Units withVertices:_vertexGrayItemArray usingProgram:_program];
}

- (void) draw:(float) numVerts withVertices: (GLuint)vertices usingProgram: (GLuint)program
{
    GLKMatrix4 _transMat;
    GLKMatrix4 _scaleMat;
    GLKMatrix4 _rotMat;
    glBindVertexArrayOES(vertices);
    glUseProgram(program);
    
    bgRotation += 0.0003f;
    if(bgRotation >= 360)
        bgRotation = 0;
    
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _camera.modelViewProjectionMatrix.m);
    _rotMat = GLKMatrix4MakeRotation(-bgRotation, 0, 0, 1);
    _transMat = GLKMatrix4Translate(_camera.modelViewMatrix, bgPos.x, bgPos.y, bgPos.z);
    _scaleMat = GLKMatrix4MakeScale(5, 5, 5);
    
    _rotMat = GLKMatrix4Multiply(_rotMat, _scaleMat);
    _transMat = GLKMatrix4Multiply(_transMat, _rotMat);
    _transMat = GLKMatrix4Multiply(_camera.projectionMatrix, _transMat);
    
    GLKMatrix4 _transNorm = GLKMatrix4MakeScale(5, 5, 5);
    GLKMatrix4 _rotNorm = GLKMatrix4MakeRotation(-bgRotation, 0, 0, 1);
    _transNorm = GLKMatrix4Multiply(_transNorm, _rotNorm);
    _transNorm = GLKMatrix4Multiply(_rotNorm, GLKMatrix4MakeTranslation(bgPos.x, bgPos.y, bgPos.z));
    _transNorm = GLKMatrix4Multiply(_camera.modelViewMatrix, _transNorm);
    
    GLKMatrix3 tempNorm = GLKMatrix4GetMatrix3(GLKMatrix4InvertAndTranspose(_transNorm, 0));
    
    glUniformMatrix4fv(uniforms[UNIFORM_TRANSLATION_MATRIX], 1, 0, _transMat.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, tempNorm.m);
    
    glDrawArrays(GL_TRIANGLES, 0, numVerts);

}

- (void) drawUnits: (NSMutableArray *)units withVertices: (GLuint*)vertices usingProgram: (GLuint)program andIsAlive:(bool) isAlive
{
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
            GLKMatrix4 _rotMat;
            glBindVertexArrayOES(vertices[((Unit*)curUnit).shipClass]);
            glUseProgram(program);
            
            glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _camera.modelViewProjectionMatrix.m);
            
            _rotMat = GLKMatrix4MakeZRotation(curUnit.rotation.z);
            _transMat = GLKMatrix4Translate(_camera.modelViewMatrix, curUnit.position.x, curUnit.position.y, curUnit.position.z);
            _scaleMat = GLKMatrix4MakeScale(curUnit.scale.x, curUnit.scale.y, curUnit.scale.z);
            
            _rotMat = GLKMatrix4Multiply(_rotMat, _scaleMat);
            _transMat = GLKMatrix4Multiply(_transMat, _rotMat);
            _transMat = GLKMatrix4Multiply(_camera.projectionMatrix, _transMat);
            
            GLKMatrix4 _transNorm = GLKMatrix4MakeScale(curUnit.scale.x, curUnit.scale.y, curUnit.scale.z);
            GLKMatrix4 _rotNorm = GLKMatrix4MakeZRotation(curUnit.rotation.z);
            _transNorm = GLKMatrix4Multiply(_transNorm, _rotNorm);
            _transNorm = GLKMatrix4Multiply(_transNorm, GLKMatrix4MakeTranslation(curUnit.position.x, curUnit.position.y, curUnit.position.z));
            _transNorm = GLKMatrix4Multiply(_camera.modelViewMatrix, _transNorm);
            
            GLKMatrix3 tempNorm = GLKMatrix4GetMatrix3(GLKMatrix4InvertAndTranspose(_transNorm, 0));
            
            glUniformMatrix4fv(uniforms[UNIFORM_TRANSLATION_MATRIX], 1, 0, _transMat.m);
            glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, tempNorm.m);
            
            glDrawArrays(GL_TRIANGLES, 0, shipVertexCounts[curUnit.faction][curUnit.shipClass]);
        }
    }
}

-(void) drawProjectile:(NSMutableArray *)units withVertices: (GLuint*)vertices usingProgram:(GLuint)program
{
    NSUInteger numProjectiles = [units count];
    
    for(unsigned int i = 0; i < numProjectiles; i++)
    {
        GLKMatrix4 _transMat;
        GLKMatrix4 _scaleMat;
        GLKMatrix4 _rotMat;
        
        Unit* curUnit = (Unit*)units[i];
        
        if(!curUnit.attacking)
            continue;
        
        // projectile
        glBindVertexArrayOES(vertices[PROJECTILE]);
        glUseProgram(program);
        
        glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _camera.modelViewProjectionMatrix.m);
        
        _rotMat = GLKMatrix4MakeZRotation(curUnit.projectile.rotation.z);
        _transMat = GLKMatrix4Translate(_camera.modelViewMatrix, curUnit.projectile.position.x, curUnit.projectile.position.y, curUnit.projectile.position.z);
        _scaleMat = GLKMatrix4MakeScale(curUnit.projectile.scale.x, curUnit.projectile.scale.y, curUnit.projectile.scale.z);
        
        _rotMat = GLKMatrix4Multiply(_rotMat, _scaleMat);
        _transMat = GLKMatrix4Multiply(_transMat, _rotMat);
        _transMat = GLKMatrix4Multiply(_camera.projectionMatrix, _transMat);
        
        GLKMatrix4 _transNorm = GLKMatrix4MakeScale(curUnit.projectile.scale.x, curUnit.projectile.scale.y, curUnit.projectile.scale.z);
        GLKMatrix4 _rotNorm = GLKMatrix4MakeZRotation(curUnit.rotation.z);
        _transNorm = GLKMatrix4Multiply(_transNorm, _rotNorm);
        _transNorm = GLKMatrix4Multiply(_transNorm, GLKMatrix4MakeTranslation(curUnit.projectile.position.x, curUnit.projectile.position.y, curUnit.projectile.position.z));
        _transNorm = GLKMatrix4Multiply(_camera.modelViewMatrix, _transNorm);
        
        GLKMatrix3 tempNorm = GLKMatrix4GetMatrix3(GLKMatrix4InvertAndTranspose(_transNorm, 0));
        
        glUniformMatrix4fv(uniforms[UNIFORM_TRANSLATION_MATRIX], 1, 0, _transMat.m);
        glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, tempNorm.m);
        
        glDrawArrays(GL_TRIANGLES, 0, factionVertexCounts[curUnit.faction][PROJECTILE]);
    }
}

- (void) drawEnvironment: (NSMutableArray *)environment withVertices: (GLuint*)vertices usingProgram:(GLuint)program
{
    NSUInteger numEntities = [environment count];
    
    for(unsigned int i = 0; i < numEntities; i++)
    {
        EnvironmentEntity* curEntity = (EnvironmentEntity*)environment[i];
        
        if(!curEntity.active) continue;
        
        if(_game.state == SELECTION)
            if(curEntity.hex == nil)
                continue;
        
        GLKMatrix4 _transMat;
        GLKMatrix4 _scaleMat;
        glBindVertexArrayOES(vertices[ENV_ASTEROID]);
        glUseProgram(program);
        
        glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _camera.modelViewProjectionMatrix.m);
        _transMat = GLKMatrix4Translate(_camera.modelViewMatrix, curEntity.position.x, curEntity.position.y, curEntity.position.z);
        _scaleMat = GLKMatrix4MakeScale(curEntity.scale.x, curEntity.scale.y, curEntity.scale.z);
        _transMat = GLKMatrix4Multiply(_transMat, _scaleMat);
        _transMat = GLKMatrix4Multiply(_camera.projectionMatrix, _transMat);
        
        GLKMatrix4 _transNorm = GLKMatrix4MakeScale(curEntity.scale.x, curEntity.scale.y, curEntity.scale.z);
        GLKMatrix4 _rotNorm = GLKMatrix4MakeZRotation(curEntity.rotation.z);
        _transNorm = GLKMatrix4Multiply(_transNorm, _rotNorm);
        _transNorm = GLKMatrix4Multiply(_transNorm, GLKMatrix4MakeTranslation(curEntity.position.x, curEntity.position.y, curEntity.position.z));
        _transNorm = GLKMatrix4Multiply(_camera.modelViewMatrix, _transNorm);
        
        GLKMatrix3 tempNorm = GLKMatrix4GetMatrix3(GLKMatrix4InvertAndTranspose(_transNorm, 0));
        
        glUniformMatrix4fv(uniforms[UNIFORM_TRANSLATION_MATRIX], 1, 0, _transMat.m);
        glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, tempNorm.m);
        
        glDrawArrays(GL_TRIANGLES, 0, environmentVertexCounts[ENV_ASTEROID]);
    }
}

- (void) drawFlag: (Item*)flag ofFaction:(Faction) faction withVertices: (GLuint*)vertices usingProgram: (GLuint)program
{
    if(_game.state == SELECTION)
            return;
    
    GLKMatrix4 _transMat;
    GLKMatrix4 _scaleMat;
    glBindVertexArrayOES(vertices[FLAG]);
    glUseProgram(program);
    
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _camera.modelViewProjectionMatrix.m);
    _transMat = GLKMatrix4Translate(_camera.modelViewMatrix, flag.position.x, flag.position.y, flag.position.z);
    _scaleMat = GLKMatrix4MakeScale(flag.scale.x, flag.scale.y, flag.scale.z);
    _transMat = GLKMatrix4Multiply(_transMat, _scaleMat);
    _transMat = GLKMatrix4Multiply(_camera.projectionMatrix, _transMat);
    
    GLKMatrix4 _transNorm = GLKMatrix4MakeScale(flag.scale.x, flag.scale.y, flag.scale.z);
    _transNorm = GLKMatrix4Multiply(_transNorm, GLKMatrix4MakeTranslation(flag.position.x, flag.position.y, flag.position.z));
    _transNorm = GLKMatrix4Multiply(_camera.modelViewMatrix, _transNorm);
    
    GLKMatrix3 tempNorm = GLKMatrix4GetMatrix3(GLKMatrix4InvertAndTranspose(_transNorm, 0));
    GLKMatrix4 _rotNorm = GLKMatrix4MakeZRotation(flag.rotation.z);
    _transNorm = GLKMatrix4Multiply(_transNorm, _rotNorm);
    glUniformMatrix4fv(uniforms[UNIFORM_TRANSLATION_MATRIX], 1, 0, _transMat.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, tempNorm.m);
    
    glDrawArrays(GL_TRIANGLES, 0, factionVertexCounts[faction][FLAG]);

}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders
{
    NSString *vertShaderPathname, *fragShaderPathname, *vert2DShaderPathname;
    NSString *vertHexShaderPathname, *fragHexShaderPathname, *frag2DShaderPathname;
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    vertHexShaderPathname = [[NSBundle mainBundle] pathForResource:@"HexShader" ofType:@"vsh"];
    vert2DShaderPathname = [[NSBundle mainBundle] pathForResource:@"2DShader" ofType:@"vsh"];

    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    fragHexShaderPathname = [[NSBundle mainBundle] pathForResource:@"HexShader" ofType:@"fsh"];
    frag2DShaderPathname = [[NSBundle mainBundle] pathForResource:@"2DShader" ofType:@"fsh"];
    
    ShaderAttribute mainProgAttrs[] = {{GLKVertexAttribPosition, "position"}, {GLKVertexAttribNormal, "normal"}, {GLKVertexAttribTexCoord0, "texCoordIn"}};
    ShaderAttribute hexProgAttrs[] = {{GLKVertexAttribPosition, "position"}};
    ShaderAttribute twoDProgAttrs[] = {{GLKVertexAttribPosition, "position"}, {GLKVertexAttribNormal, "normal"}, {GLKVertexAttribTexCoord0, "texCoordIn"}};
    
    if([GLProgramUtils makeProgram: &_program withVertShader: vertShaderPathname andFragShader: fragShaderPathname
               andAttributes: mainProgAttrs withNumberOfAttributes:3])
        return NO;
    if([GLProgramUtils makeProgram: &_hexProgram withVertShader: vertHexShaderPathname andFragShader: fragHexShaderPathname
                     andAttributes: hexProgAttrs withNumberOfAttributes:1]){
        glDeleteProgram(_program);
        return NO;
    }
    if([GLProgramUtils makeProgram: &_2DProgram withVertShader: vert2DShaderPathname andFragShader: frag2DShaderPathname andAttributes:twoDProgAttrs withNumberOfAttributes:3])
    {
        glDeleteProgram(_program);
        glDeleteProgram(_hexProgram);
        return NO;
    }
        
    // Get uniform locations.
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program, "normalMatrix");
    uniforms[UNIFORM_TRANSLATION_MATRIX] = glGetUniformLocation(_program, "translationMatrix");
    uniforms[UNIFORM_2D_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_2DProgram, "modelViewProjectionMatrix");
    uniforms[UNIFORM_2D_NORMAL_MATRIX] = glGetUniformLocation(_2DProgram, "normalMatrix");
    uniforms[UNIFORM_2D_TRANSLATION_MATRIX] = glGetUniformLocation(_2DProgram, "translationMatrix");
    uniforms[UNIFORM_HEX_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_hexProgram, "modelViewProjectionMatrix");
    uniforms[UNIFORM_HEX_COLOUR] = glGetUniformLocation(_hexProgram, "color");
    uniforms[UNIFORM_UNIT_TEXTURE] = glGetUniformLocation(_program, "texture");
    uniforms[UNIFORM_2D_UNIT_TEXTURE] = glGetUniformLocation(_2DProgram, "texture");
    uniforms[UNIFORM_LIGHT_POSITION] = glGetUniformLocation(_program, "lightPos");

    return YES;
}

// Pointer to vertex array
// Pointer to vertex buffer
// Number of vertices
// Pointer to vertices
// Drawing mode
// VertexAttribute list
// Number of vertex attributes
/**
 * Creates a vertex array and buffer, loads the specified data, and sets the vertex specification.
 */
- (void) setupVertexArray: (GLuint *)array withBuffer: (GLuint*)buffer andVertices: (const void*)vertices withNumVertices: (unsigned int)numVertices
         usingDrawingMode: (int)drawMode withVertexAttributes: (VertexAttribute*)attribs andNumAttributes: (unsigned int)numAttributes
{
    unsigned int size = 0;
    
    // Calculate the size of one vertex
    for(unsigned i = 0; i < numAttributes; i++)
    {
        switch(attribs[i].type)
        {
            case GL_BYTE:
            case GL_UNSIGNED_BYTE:
                size += attribs[i].size;
                break;
            case GL_SHORT:
            case GL_UNSIGNED_SHORT:
                size += attribs[i].size * sizeof(short);
                break;
            case GL_FIXED:
            case GL_FLOAT:
                size += attribs[i].size * sizeof(float);
                break;
        }
    }
    
    // Generate the array. gemerate amd fill the buffer, and set the vertex specification
    glGenVertexArraysOES(1, array);
    glBindVertexArrayOES(*array);
    
    glGenBuffers(1, buffer);
    glBindBuffer(GL_ARRAY_BUFFER, *buffer);
    glBufferData(GL_ARRAY_BUFFER, numVertices * size, vertices, drawMode);
    
    [GLProgramUtils setVertexAttributes:attribs withNumAttributes:numAttributes];
    glBindVertexArrayOES(0);
}

- (IBAction)endTurnPressed:(id)sender
{
    if(!endTurnPressed)
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
    
        if([_game switchTurn])
        {
            if([_game whoseTurn] == VIKINGS)
            {
                [_turnImage setImage:[UIImage imageNamed:@"vikingsturn.png"]];
                [_turnMarker setImage:[UIImage imageNamed:@"VikingPortrait.png"]];
            }
            else if([_game whoseTurn] == ALIENS)
            {
                [_turnImage setImage:[UIImage imageNamed:@"graysturn.png"]];
                [_turnMarker setImage:[UIImage imageNamed:@"GrayPortrait.png"]];
            }
            
            [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                _turnImage.hidden = NO;
                endTurnPressed = YES;
                ((UIView*)_turnImage).transform = CGAffineTransformMakeScale(2.0,2.0);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    ((UIView*)_turnImage).transform = CGAffineTransformMakeScale(0.0001,0.001);
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                        _turnImage.hidden = YES;
                        endTurnPressed = NO;
                    } completion:nil];
                }];

            }];
            
            if(_game.state == SELECTION)
                [_selectedUnitVIew setImage:[UIImage imageNamed:[NSString stringWithUTF8String:shipImages[_game.selectedUnit.faction][_game.selectedUnit.shipClass]]]];
        }
    }
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

-(void)showDamageAtPos:(GLKVector3) position Damage: (float) damage IsDamage: (bool) isDamage
{
    GLKVector3 pos = GLKMatrix4MultiplyAndProjectVector3(_camera.modelViewProjectionMatrix, position);
    int winX = (int) round((( pos.x + 1 ) / 2.0) * self.view.frame.size.width );
    int winY = (int) round((( 1 - pos.y ) / 2.0) * self.view.frame.size.height );
    
    [hitLabel setFrame:CGRectMake(winX, winY, 100, 20)];
    hitLabel.backgroundColor=[UIColor clearColor];
    
    if(isDamage && damage == 0)
        hitLabel.textColor=[UIColor blueColor];
    else if(isDamage)
        hitLabel.textColor=[UIColor redColor];
    else
        hitLabel.textColor=[UIColor greenColor];
    
    hitLabel.userInteractionEnabled = NO;
    [self.view addSubview:hitLabel];
    
    if(isDamage)
        if(damage == 0)
            hitLabel.text = [NSString stringWithFormat:@"MISS"];
        else
            hitLabel.text = [NSString stringWithFormat:@"-%.2f", damage];
    else
        hitLabel.text = [NSString stringWithFormat:@"+%.2f", damage];
    
    
    [UIView animateWithDuration:0.0 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        ((UILabel *)hitLabel).transform = CGAffineTransformMakeScale(0.0,0.0);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            ((UILabel *)hitLabel).transform = CGAffineTransformMakeScale(1,1);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:1.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                ((UILabel *)hitLabel).transform = CGAffineTransformMakeScale(0.95,0.95);
            } completion:^(BOOL finished) {
               hitLabel.text = @"";
            }];
        }];
    }];
}


@end
