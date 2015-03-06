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
    
    GLuint _vertexVikingArray;
    GLuint _vertexVikingBuffer;
    GLuint _normalVikingArray;
    GLuint _normalVikingBuffer;
    GLuint _vertexGrayArray;
    GLuint _vertexGrayBuffer;
    GLuint _normalGrayArray;
    GLuint _normalGrayBuffer;

    Camera *_camera;
    
    GLuint _vertexHexArray;
    GLuint _vertexHexBuffer;
    HexCells *hexCells;
    GLfloat instanceVertices[91][16];
    
    GLuint _vertexBGArray;
    GLuint _vertexBGBuffer;
    GLuint _bgTexture;
    
    //GameStuff
    Game* game;
    
    //unit stuff
    int vikingNum;
    int grayNum;
    NSMutableArray *vikingList;
    NSMutableArray *grayList;
    int currentGrayUnit;
    int currentVikingUnit;
    
    GLuint _vikingTexture;
    GLuint _grayTexture;
    GLuint _vikingBrokenTexture;
    GLuint _grayBrokenTexture;
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
- (void) drawUnits: (NSMutableArray *)units withVertices: (GLuint)vertices usingProgram: (GLuint)program;
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
    
    HexCells* map = [[HexCells alloc] initWithSize:5];

    //unit lists initialization
    vikingNum = 3;
    vikingList = [[NSMutableArray alloc] initWithCapacity:vikingNum];
    for(int i = 0; i < vikingNum; i++)
    {
        Hex* temp = [map hexAtQ:0 andR:i];
        Unit* tempUnit = [[Unit alloc] initWithFaction:VIKINGS andClass:LIGHT atPosition: GLKVector3Make(temp.worldPosition.x, temp.worldPosition.y, 0.02)
                                          withRotation:GLKVector3Make(0, 0, 0) andScale:0.002 onHex:temp];
        [vikingList addObject:tempUnit];
    }
    
    grayNum = 3;
    grayList = [[NSMutableArray alloc] initWithCapacity:grayNum];
    for(int i = 0; i < grayNum; i++)
    {
        Hex* temp = [map hexAtQ:-2 andR:i];
        Unit* tempUnit = [[Unit alloc] initWithFaction:ALIENS andClass:LIGHT atPosition: GLKVector3Make(temp.worldPosition.x, temp.worldPosition.y, 0.02)
                                          withRotation:GLKVector3Make(0, 0, 0) andScale:0.002 onHex:temp];
        [grayList insertObject:tempUnit atIndex:i];
    }
    
    currentGrayUnit = 0;
    currentVikingUnit = 0;
    
    id<GameMode> skirmishMode = [[SkirmishMode alloc] init];
    game = [[Game alloc] initWithMode:skirmishMode andPlayer1Units:vikingList andPlayer2Units:grayList andMap:map];

    hexCells = game.map;

     _camera = [[Camera alloc] initWithWidth:self.view.bounds.size.width WithHeight: self.view.bounds.size.height WithRadius:hexCells.N];
    
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
    
    // viking stuff
    glGenVertexArraysOES(1, &_vertexVikingArray);
    glBindVertexArrayOES(_vertexVikingArray);
    
    glGenBuffers(1, &_vertexVikingBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexVikingBuffer);
    glBufferData(GL_ARRAY_BUFFER, ((Unit*)vikingList[0]).modelArrSize, ((Unit*)vikingList[0]).modelData, GL_STATIC_DRAW);
    //vertLoc = glGetAttribLocation(_program, "position");
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(12));
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(24));
    
    glBindVertexArrayOES(0);
    
    // gray stuff
    glGenVertexArraysOES(1, &_vertexGrayArray);
    glBindVertexArrayOES(_vertexGrayArray);
    
    glGenBuffers(1, &_vertexGrayBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexGrayBuffer);
    glBufferData(GL_ARRAY_BUFFER, ((Unit*)grayList[0]).modelArrSize, ((Unit*)grayList[0]).modelData, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(12));
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(24));
    
    glBindVertexArrayOES(0);
    
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
    _grayTexture = [GLProgramUtils setupTexture:@"VikingDiff.png"];
    _vikingBrokenTexture = [GLProgramUtils setupTexture:@"Pause.png"];
    _grayBrokenTexture = [GLProgramUtils setupTexture:@"EndTurn.png"];
    _bgTexture = [GLProgramUtils setupTexture:@"Spaaaace.jpg"];
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &_vertexVikingBuffer);
    glDeleteVertexArraysOES(1, &_vertexVikingArray);
    
    glDeleteBuffers(1, &_vertexBGBuffer);
    glDeleteVertexArraysOES(1, &_vertexBGArray);
    
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
    [game selectTile: pickedTile];
    [[SoundManager sharedManager] playSound:@"select.wav" looping:NO];
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    [_camera UpdateWithWidth:self.view.frame.size.width AndHeight: self.view.frame.size.height];
    
    self.effect.transform.projectionMatrix = _camera.projectionMatrix;
    
    self.effect.transform.modelviewMatrix = _camera.modelViewMatrix;
    
    switch([game checkForWin])
    {
        case 1:
        {
            _winLabel.text = @"Vikings Win!!";
            break;
        }
        case 2:
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
    
    if(game.selectedUnit)
    {
        Unit* seld = game.selectedUnit;
        NSString *stats = [NSString stringWithFormat:@"Hull: %d\rAttack Range: %d\rDamage: %d\rMovement Range: %d\rAccuracy: %.2f\rCritical Chance: %.2f\rCritical Modifier: %.2f\rAction Points: %d\rEngine Health: %d\rWeapon Health: %.2f\rShip Health: %d",
                           seld.stats->hull,
                           seld.stats->attackRange,
                           seld.stats->damage,
                           seld.moveRange,
                           seld.stats->accuracy,
                           seld.stats->critChance,
                           seld.stats->critModifier,
                           seld.stats->actionPool,
                           seld.stats->engineHealth,
                           seld.stats->weaponHealth,
                           seld.stats->shipHealth];
        _statsLabel.text = stats;
    }
    else
    {
        _statsLabel.text = @"";
    }
    
    [game.map clearColours];
    if (game.selectedUnit != nil)
    {
        NSMutableArray* movableRange;
        movableRange = [game.map movableRange:([game.selectedUnit moveRange]) from:game.selectedUnit.hex];
        for(Hex* hex in movableRange)
        {
            [hex setColour:MOVEABLE_COLOUR];
        }
        
        if(game.whoseTurn == VIKINGS)
        {
            if ([game.selectedUnit ableToAttack])
            {
                for(Unit* unit in game.p2Units)
                {
                    if ([HexCells distanceFrom:game.selectedUnit.hex toHex:unit.hex] <= game.selectedUnit.stats->attackRange) {
                        [unit.hex setColour:ATTACKABLE_COLOUR];
                    }
                }
            }
        }
        else if (game.whoseTurn == ALIENS)
        {
            if ([game.selectedUnit ableToAttack])
            {
                for(Unit* unit in game.p1Units)
                {
                    if ([HexCells distanceFrom:game.selectedUnit.hex toHex:unit.hex] <= game.selectedUnit.stats->attackRange) {
                        [unit.hex setColour:ATTACKABLE_COLOUR];
                    }
                }
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
    glEnable( GL_BLEND );
    
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
    [self drawUnits:vikingList withVertices:_vertexVikingArray usingProgram:_program andIsAlive:YES];
    glBindTexture(GL_TEXTURE_2D, _grayTexture);
    [self drawUnits:grayList withVertices:_vertexGrayArray usingProgram:_program andIsAlive:YES];
    glBindTexture(GL_TEXTURE_2D, _vikingBrokenTexture);
    [self drawUnits:vikingList withVertices:_vertexVikingArray usingProgram:_program andIsAlive:NO];
    glBindTexture(GL_TEXTURE_2D, _grayBrokenTexture);
    [self drawUnits:grayList withVertices:_vertexGrayArray usingProgram:_program andIsAlive:NO];
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
    
    GLKMatrix3 tempNorm = GLKMatrix4GetMatrix3(GLKMatrix4Translate(_camera.modelViewMatrix, 0, 0, -6));
    glUniformMatrix4fv(uniforms[UNIFORM_TRANSLATION_MATRIX], 1, 0, _transMat.m);
    glUniformMatrix4fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, tempNorm.m);
    
    glDrawArrays(GL_TRIANGLES, 0, numVerts);

}

- (void) drawUnits: (NSMutableArray *)units withVertices: (GLuint)vertices usingProgram: (GLuint)program andIsAlive:(bool) isAlive {
    NSUInteger numUnits = [units count];

    for(unsigned int i = 0; i < numUnits; i++)
    {
        Unit* curUnit = (Unit *)units[i];
        if(curUnit.active == isAlive)
        {
            GLKMatrix4 _transMat;
            GLKMatrix4 _scaleMat;
            glBindVertexArrayOES(vertices);
            glUseProgram(program);
            
            glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _camera.modelViewProjectionMatrix.m);
            _transMat = GLKMatrix4Translate(_camera.modelViewMatrix, curUnit.position.x, curUnit.position.y, curUnit.position.z);
            _scaleMat = GLKMatrix4MakeScale(curUnit.scale, curUnit.scale, curUnit.scale);
            _transMat = GLKMatrix4Multiply(_transMat, _scaleMat);
            _transMat = GLKMatrix4Multiply(_camera.projectionMatrix, _transMat);
            
            GLKMatrix3 tempNorm = GLKMatrix4GetMatrix3(GLKMatrix4Translate(_camera.modelViewMatrix, curUnit.position.x, curUnit.position.y, curUnit.position.z));
            glUniformMatrix4fv(uniforms[UNIFORM_TRANSLATION_MATRIX], 1, 0, _transMat.m);
            glUniformMatrix4fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, tempNorm.m);
            
            glDrawArrays(GL_TRIANGLES, 0, curUnit.numModelVerts);
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
    [game switchTurn];
}

- (IBAction)pausePresssed:(id)sender
{
    [sender setImage:[UIImage imageNamed:@"PausePressed.png"] forState:UIControlStateHighlighted];
}

@end
