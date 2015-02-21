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
    
    GLint vertLoc;
    
    //GameStuff
    Game* game;
    
    //unit stuff
    int vikingNum;
    int grayNum;
    NSMutableArray *vikingList;
    NSMutableArray *grayList;
    int currentGrayUnit;
    int currentVikingUnit;
    
    bool turn;
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
    
    UIPinchGestureRecognizer *pinchZoom = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(doPinch:)];
    [self.view addGestureRecognizer:pinchZoom];
    
    UIPanGestureRecognizer *fingerDrag = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(doPan:)];
    fingerDrag.maximumNumberOfTouches = 1;
    fingerDrag.minimumNumberOfTouches = 1;
    [self.view addGestureRecognizer:fingerDrag];
    
    _camera = [[Camera alloc] initWithWidth:self.view.bounds.size.width WithHeight: self.view.bounds.size.height];
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    game = [game initWithSize:2];
    
    //unit lists initialization
    vikingNum = 3;
    vikingList = [[NSMutableArray alloc] initWithCapacity:vikingNum];
    for(int i = 0; i < vikingNum; i++)
    {
        Unit *tempUnit = [[Unit alloc] initWithCoords:GLKVector3Make(0, 0, 0) And:GLKVector3Make(0, 0, 0) And:0.002];
        [tempUnit initShip:0 And:0];
        tempUnit.position = GLKVector3Make(i , i , i );
        
        [vikingList insertObject:tempUnit atIndex:i];
    }
    
    grayNum = 3;
    grayList = [[NSMutableArray alloc] initWithCapacity:grayNum];
    for(int i = 0; i < grayNum; i++)
    {
        Unit *tempUnit = [[Unit alloc] initWithCoords:GLKVector3Make(0, 0, 0) And:GLKVector3Make(0, 0, 0) And:0.002];
        [tempUnit initShip:1 And:0];
        tempUnit.position = GLKVector3Make(-i , -i , -i );
        
        [grayList insertObject:tempUnit atIndex:i];
    }
    
    currentGrayUnit = 0;
    currentVikingUnit = 0;
    
    turn = YES;
    
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
/*
-(void) initHexCellsInstanceVertices:(int) numberOfHex :(int)verticesInHex
{
    instanceVertices = (float**)malloc(numberOfHex * sizeof(float*));
    int i;
    for(i = 0; i < numberOfHex; ++i)
    {
        instanceVertices[i] = (float*)malloc(verticesInHex * sizeof(float));
    }
}

-(void) destoryHexCellsInstanceVertices:(int)numberOfHex
{
    int i;
    for(i = 0; i < numberOfHex; ++i)
    {
        free(instanceVertices[i]);
    }
}*/

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    [self loadShaders];
    
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
    
    hexCells = [[HexCells alloc]initWithSize:5];
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
    //vertLoc = glGetAttribLocation(_program, "position");
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(12));
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(24));
    
    glBindVertexArrayOES(0);
    
    //Placing the units, Hardcoded for now
    NSMutableArray *grayPos = [[NSMutableArray alloc] initWithCapacity:grayNum];
    grayPos[0] = [hexCells hexAtQ:-1 andR:-1];
    grayPos[1] = [hexCells hexAtQ:0 andR:-2];
    grayPos[2] = [hexCells hexAtQ:1 andR:-2];
    
    NSMutableArray *vikingPos = [[NSMutableArray alloc] initWithCapacity:vikingNum];
    vikingPos[0] = [hexCells hexAtQ:-1 andR:2];
    vikingPos[1] = [hexCells hexAtQ:0 andR:2];
    vikingPos[2] = [hexCells hexAtQ:1 andR:1];
    
    for(int i = 0; i < grayNum; i++)
    {
        ((Unit*)grayList[i]).position = GLKVector3Make(((Hex*)grayPos[i]).worldPosition.x, ((Hex*)grayPos[i]).worldPosition.y, 0.02);
    }
    
    for(int i = 0; i < vikingNum; i++)
    {
        ((Unit*)vikingList[i]).position = GLKVector3Make(((Hex*)vikingPos[i]).worldPosition.x, ((Hex*)vikingPos[i]).worldPosition.y, 0.02);
    }
    
    NSMutableArray *path = [hexCells makePathFrom:-2 :2 To:2 :-2];
    
    for (Hex *hex in path)
    {
        [hex setColour:GLKVector4Make(0.3f, 0.5f, 0.8f, 1.0)];
    }
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &_vertexVikingBuffer);
    glDeleteVertexArraysOES(1, &_vertexVikingArray);
    
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
    [pickedTile setColour:GLKVector4Make(0, 0, 1, 1)];
    
    
    bool occupied = NO;
    for(int i = 0; i < grayNum; i++)
    {
        if(pickedTile.worldPosition.x == ((Unit*)grayList[i]).position.x
           && pickedTile.worldPosition.y == ((Unit*)grayList[i]).position.y)
        {
            if(turn)
                currentGrayUnit = i;
            occupied = YES;
            break;
        }
    }
    
    for(int i = 0; i < vikingNum; i++)
    {
        if(pickedTile.worldPosition.x == ((Unit*)vikingList[i]).position.x
           && pickedTile.worldPosition.y == ((Unit*)vikingList[i]).position.y)
        {
            if(!turn)
                currentVikingUnit = i;
            occupied = YES;
            break;
        }
    }
    
    if(!occupied)
    {
        if(turn)
            ((Unit*)grayList[currentGrayUnit]).position = GLKVector3Make(pickedTile.worldPosition.x, pickedTile.worldPosition.y, 0);
        else
            ((Unit*)vikingList[currentVikingUnit]).position = GLKVector3Make(pickedTile.worldPosition.x, pickedTile.worldPosition.y, 0);
    }
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    [_camera UpdateWithWidth:self.view.frame.size.width AndHeight: self.view.frame.size.height];
    
    self.effect.transform.projectionMatrix = _camera.projectionMatrix;
    
    self.effect.transform.modelviewMatrix = _camera.modelViewMatrix;
    
    [hexCells movableRange:2 from:[hexCells hexAtQ:1 andR:0]];//Just testing
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

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
            
            //NSLog(@"%d", hex.instanceVertexIndex);
            
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
            
            //NSLog(@"%d", hex.instanceVertexIndex);
            
            glBindBuffer(GL_ARRAY_BUFFER, _vertexHexBuffer);
            glBufferData(GL_ARRAY_BUFFER, sizeof(instanceVertices[hex.instanceVertexIndex]), instanceVertices[hex.instanceVertexIndex], GL_STATIC_DRAW);
            
            glDrawElements(GL_TRIANGLES, 18, GL_UNSIGNED_INT, 0);
        }
    }
    
    [self drawUnits:vikingList withVertices:_vertexVikingArray usingProgram:_program];
    [self drawUnits:grayList withVertices:_vertexGrayArray usingProgram:_program];
}

- (void) drawUnits: (NSMutableArray *)units withVertices: (GLuint)vertices usingProgram: (GLuint)program {
    NSUInteger numUnits = [units count];
    
    for(unsigned int i = 0; i < numUnits; i++)
    {
        Unit* curUnit = (Unit *)units[i];
        GLKMatrix4 _transMat;
        GLKMatrix4 _scaleMat;
        glBindVertexArrayOES(vertices);
        glUseProgram(program);
        
        glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _camera.modelViewProjectionMatrix.m);
        _transMat = GLKMatrix4Translate(_camera.modelViewMatrix, curUnit.position.x, curUnit.position.y, curUnit.position.z);
        _scaleMat = GLKMatrix4MakeScale(curUnit.scale, curUnit.scale, curUnit.scale);
        _transMat = GLKMatrix4Multiply(_transMat, _scaleMat);
        _transMat = GLKMatrix4Multiply(_camera.projectionMatrix, _transMat);
        
        GLKMatrix3 tempNorm = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(GLKMatrix4Translate(_camera.modelViewMatrix, curUnit.position.x, curUnit.position.y, curUnit.position.z)), 0);
        glUniformMatrix4fv(uniforms[UNIFORM_TRANSLATION_MATRIX], 1, 0, _transMat.m);
        glUniformMatrix4fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, tempNorm.m);
        
        glDrawArrays(GL_TRIANGLES, 0, curUnit.numModelVerts);
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
    
    ShaderAttribute mainProgAttrs[] = {{GLKVertexAttribPosition, "position"}, {GLKVertexAttribNormal, "normal"}};
    ShaderAttribute hexProgAttrs[] = {{GLKVertexAttribPosition, "position"}};
    
    if([GLProgramUtils makeProgram: &_program withVertShader: vertShaderPathname andFragShader: fragShaderPathname
               andAttributes: mainProgAttrs withNumberOfAttributes:2])
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
    return YES;
}

// Load in and set up texture image (adapted from Ray Wenderlich)
- (GLuint)setupTexture:(NSString *)fileName
{
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    if (!spriteImage) {
        NSLog(@"Failed to load image %@", fileName);
        exit(1);
    }
    
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    GLubyte *spriteData = (GLubyte *) calloc(width*height*4, sizeof(GLubyte));
    
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    
    CGContextRelease(spriteContext);
    
    GLuint texName;
    glGenTextures(1, &texName);
    glBindTexture(GL_TEXTURE_2D, texName);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)width, (int)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    free(spriteData);
    return texName;
}

- (IBAction)endTurnPressed:(id)sender
{
    [sender setImage:[UIImage imageNamed:@"EndTurnPressed.png"] forState:UIControlStateHighlighted];
    turn = !turn;
}

- (IBAction)pausePressed:(id)sender {
    [sender setImage:[UIImage imageNamed:@"PausePressed.png"] forState:UIControlStateHighlighted];
}

@end
