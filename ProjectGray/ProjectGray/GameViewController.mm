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

#include "HexCells.h"

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
    GLuint _guiProgram;
    
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
    GLfloat instanceVertices[19][16];
    
    GLuint _vertexGUIArray;
    GLuint _vertexGUIBuffer;
    GLfloat guiVertices[24];
    GLuint guiElements[6];
    GLuint _texture;
    GLuint guiEbo;
    Unit *testUnit;
    GLint vertLoc;

    GLKMatrix4 SteveJobsIsAFag;
    
    //unit stuff
    int vikingNum;
    int grayNum;
    NSMutableArray *vikingList;
    NSMutableArray *grayList;
}

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

- (void)setupGL;
- (void)tearDownGL;

- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
//- (BOOL)validateProgram:(GLuint)prog;
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
    
    //unit lists initialization
    vikingNum = 3;
    vikingList = [[NSMutableArray alloc] initWithCapacity:vikingNum];
    for(int i = 0; i < vikingNum; i++)
    {
        Unit *tempUnit = [[Unit alloc] initWithCoords:GLKVector3Make(0, 0, 0) And:GLKVector3Make(0, 0, 0) And:0.3];
        [tempUnit initShip:0 And:0];
        tempUnit.position = GLKVector3Make(i , i , i );
        
        [vikingList insertObject:tempUnit atIndex:i];
    }
    
    grayNum = 3;
    grayList = [[NSMutableArray alloc] initWithCapacity:grayNum];
    for(int i = 0; i < grayNum; i++)
    {
        Unit *tempUnit = [[Unit alloc] initWithCoords:GLKVector3Make(0, 0, 0) And:GLKVector3Make(0, 0, 0) And:0.3];
        [tempUnit initShip:1 And:0];
        tempUnit.position = GLKVector3Make(-i , -i , -i );
        
        [grayList insertObject:tempUnit atIndex:i];
    }
    
    //testUnit = [[Unit alloc] initWithCoords:GLKVector3Make(0, 0, 0) And:GLKVector3Make(0, 0, 0) And:1.0];
    //[testUnit initShip:0 And:0];
    //testUnit.position = GLKVector3Make(0, 0, 0);
    
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
    
    hexCells = [[HexCells alloc]initWithSize:2];
    NSMutableArray *instPositions = hexCells.hexPositions;
    
    for (int i = 0; i < 19; ++i)
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
    
    //GUI Vertices
    glGenVertexArraysOES(1, &_vertexGUIArray);
    glBindVertexArrayOES(_vertexGUIArray);
    
    float guiSize = 0.3;
    
    //Bottom square
    guiVertices[0] = -1 * guiSize; //x
    guiVertices[1] = -1 * guiSize; //y
    guiVertices[2] = 0;  //u
    guiVertices[3] = 1; //v
    
    guiVertices[4] = 1 * guiSize;  //x
    guiVertices[5] = -1 * guiSize; //y
    guiVertices[6] = 1; //u
    guiVertices[7] = 1;  //v
    
    guiVertices[8] = -1 * guiSize;  //x
    guiVertices[9] = 1 * guiSize;   //y
    guiVertices[10] = 0; //u
    guiVertices[11] = 0;  //v
    
    //Top Face
    guiVertices[12] = 1 * guiSize;  //x
    guiVertices[13] = 1 * guiSize;  //y
    guiVertices[14] = 1;  //u
    guiVertices[15] = 0;  //v

    
    guiElements[0] = 0;
    guiElements[1] = 1;
    guiElements[2] = 2;
    guiElements[3] = 2;
    guiElements[4] = 1;
    guiElements[5] = 3;
    
    glGenBuffers(1, &_vertexGUIBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexGUIBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(guiVertices), guiVertices, GL_STATIC_DRAW);
    
    glGenBuffers(1, &guiEbo);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, guiEbo);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(guiElements), guiElements, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 16, BUFFER_OFFSET(0));
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 16, BUFFER_OFFSET(8));
    
    glBindVertexArrayOES(0);
    
    _texture = [self setupTexture:@"EndTurn.png"];
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _texture);
    GLuint loc = glGetUniformLocation(_guiProgram, "texture");
    glUniform1i(loc, 0);
    
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
        ((Unit*)grayList[i]).position = GLKVector3Make(((Hex*)grayPos[i]).worldPosition.x, ((Hex*)grayPos[i]).worldPosition.y, 0);
    }
    
    for(int i = 0; i < vikingNum; i++)
    {
        ((Unit*)vikingList[i]).position = GLKVector3Make(((Hex*)vikingPos[i]).worldPosition.x, ((Hex*)vikingPos[i]).worldPosition.y, 0);
    }
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &_vertexVikingBuffer);
    glDeleteVertexArraysOES(1, &_vertexVikingArray);
    
    glDeleteBuffers(1, &_vertexGUIBuffer);
    glDeleteVertexArraysOES(1, &_vertexGUIArray);

    self.effect = nil;
    
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
    if (_hexProgram) {
        glDeleteProgram(_hexProgram);
        _hexProgram = 0;
    }
    if (_guiProgram) {
        glDeleteProgram(_guiProgram);
        _guiProgram = 0;
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
 * Unproject the screen point (from http://whackylabs.com/rants/?p=1043 ) and test it against the xy-plane to pick a hex cell.
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
    
    // Make vector from touched point to end of clipping plane
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
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    [_camera Update];
    
    self.effect.transform.projectionMatrix = _camera.projectionMatrix;
    
    self.effect.transform.modelviewMatrix = _camera.modelViewMatrix;
    
    [hexCells movableRange:0 from:[hexCells hexAtQ:0 andR:0]];//Just testing
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
    
    for(int i = 0; i < vikingNum; i++)
    {
        GLKMatrix4 _transMat;
        GLKMatrix4 _scaleMat;
        // Chicken stuff
        glBindVertexArrayOES(_vertexVikingArray);
        // Render the object again with ES2
        glUseProgram(_program);
        
        glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _camera.modelViewProjectionMatrix.m);
        _transMat = GLKMatrix4Translate(_camera.modelViewMatrix, ((Unit*)vikingList[i]).position.x, ((Unit*)vikingList[i]).position.y, ((Unit*)vikingList[i]).position.z);
        _scaleMat = GLKMatrix4MakeScale(((Unit*)vikingList[i]).scale, ((Unit*)vikingList[i]).scale, ((Unit*)vikingList[i]).scale);
        _transMat = GLKMatrix4Multiply(_transMat, _scaleMat);
        _transMat = GLKMatrix4Multiply(_camera.projectionMatrix, _transMat);
        
        GLKMatrix3 tempNorm = GLKMatrix4GetMatrix3(GLKMatrix4Translate(_camera.modelViewMatrix, ((Unit*)vikingList[i]).position.x, ((Unit*)vikingList[i]).position.y, ((Unit*)vikingList[i]).position.z));
        glUniformMatrix4fv(uniforms[UNIFORM_TRANSLATION_MATRIX], 1, 0, _transMat.m);
        glUniformMatrix4fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, tempNorm.m);
        
        
        glDrawArrays(GL_TRIANGLES, 0, ((Unit*)vikingList[i]).numModelVerts);
        
    }
    
    for(int i = 0; i < grayNum; i++)
    {
        GLKMatrix4 _transMat;
        GLKMatrix4 _scaleMat;
        // Chicken stuff
        glBindVertexArrayOES(_vertexGrayArray);
        // Render the object again with ES2
        glUseProgram(_program);
        
        glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _camera.modelViewProjectionMatrix.m);
        _transMat = GLKMatrix4Translate(_camera.modelViewMatrix, ((Unit*)grayList[i]).position.x, ((Unit*)grayList[i]).position.y, ((Unit*)grayList[i]).position.z);
        _scaleMat = GLKMatrix4MakeScale(((Unit*)grayList[i]).scale, ((Unit*)grayList[i]).scale, ((Unit*)grayList[i]).scale);
        _transMat = GLKMatrix4Multiply(_transMat, _scaleMat);
        _transMat = GLKMatrix4Multiply(_camera.projectionMatrix, _transMat);
        
        GLKMatrix3 tempNorm = GLKMatrix4GetMatrix3(GLKMatrix4Translate(_camera.modelViewMatrix, ((Unit*)grayList[i]).position.x, ((Unit*)grayList[i]).position.y, ((Unit*)grayList[i]).position.z));
        glUniformMatrix4fv(uniforms[UNIFORM_TRANSLATION_MATRIX], 1, 0, _transMat.m);
        glUniformMatrix4fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, tempNorm.m);
        
        glDrawArrays(GL_TRIANGLES, 0, ((Unit*)grayList[i]).numModelVerts);
    }
    
    // Chicken stuff
//    glBindVertexArrayOES(_vertexArray);
    // Render the object again with ES2
//    glUseProgram(_program);
    
//    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _camera.modelViewProjectionMatrix.m);
//    _transMat = GLKMatrix4Translate(_camera.modelViewMatrix, testUnit.position.x, testUnit.position.y, testUnit.position.z);
//    _transMat = GLKMatrix4Multiply(_camera.projectionMatrix, _transMat);
//
//    GLKMatrix3 tempNorm = GLKMatrix4GetMatrix3(GLKMatrix4Translate(_camera.modelViewMatrix, testUnit.position.x, testUnit.position.y, testUnit.position.z));
//    glUniformMatrix4fv(uniforms[UNIFORM_TRANSLATION_MATRIX], 1, 0, _transMat.m);
//    glUniformMatrix4fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, tempNorm.m);

    
//    glDrawArrays(GL_TRIANGLES, 0, testUnit.numModelVerts);
    
    //gui stuff
    /*glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable( GL_BLEND );
    
    glBindVertexArrayOES(_vertexGUIArray);
    glUseProgram(_guiProgram);
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexGUIBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(guiVertices), guiVertices, GL_STATIC_DRAW);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, guiEbo);
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
    glDisable(GL_BLEND);*/
    
}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    GLuint vertHexShader, fragHexShader;
    NSString *vertHexShaderPathname, *fragHexShaderPathname;
    GLuint vertGUIShader, fragGUIShader;
    NSString *vertGUIShaderPathname, *fragGUIShaderPathname;
    
    // Create shader program.
    _program = glCreateProgram();
    _hexProgram = glCreateProgram();
    _guiProgram = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    vertHexShaderPathname = [[NSBundle mainBundle] pathForResource:@"HexShader" ofType:@"vsh"];
    if (![self compileShader:&vertHexShader type:GL_VERTEX_SHADER file:vertHexShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    vertGUIShaderPathname = [[NSBundle mainBundle] pathForResource:@"GUIShader" ofType:@"vsh"];
    if (![self compileShader:&vertGUIShader type:GL_VERTEX_SHADER file:vertGUIShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    fragHexShaderPathname = [[NSBundle mainBundle] pathForResource:@"HexShader" ofType:@"fsh"];
    if (![self compileShader:&fragHexShader type:GL_FRAGMENT_SHADER file:fragHexShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    fragGUIShaderPathname = [[NSBundle mainBundle] pathForResource:@"GUIShader" ofType:@"fsh"];
    if (![self compileShader:&fragGUIShader type:GL_FRAGMENT_SHADER file:fragGUIShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(_program, vertShader);
    glAttachShader(_hexProgram, vertHexShader);
    glAttachShader(_guiProgram, vertGUIShader);
    
    // Attach fragment shader to program.
    glAttachShader(_program, fragShader);
    glAttachShader(_hexProgram, fragHexShader);
    glAttachShader(_guiProgram, fragGUIShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(_program, GLKVertexAttribPosition, "position");
    glBindAttribLocation(_program, GLKVertexAttribNormal, "normal");
    glBindAttribLocation(_hexProgram, GLKVertexAttribPosition, "position");
    glBindAttribLocation(_guiProgram, GLKVertexAttribPosition, "position");
    glBindAttribLocation(_guiProgram, GLKVertexAttribTexCoord0, "texCoordIn");
    
    // Link program.
    if (![self linkProgram:_program]) {
        NSLog(@"Failed to link program: %d", _program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        
        return NO;
    }
    if (![self linkProgram:_hexProgram]) {
        NSLog(@"Failed to link program: %d", _hexProgram);
        
        if (vertHexShader) {
            glDeleteShader(vertHexShader);
            vertHexShader = 0;
        }
        if (fragHexShader) {
            glDeleteShader(fragHexShader);
            fragHexShader = 0;
        }
        if (_hexProgram) {
            glDeleteProgram(_hexProgram);
            _hexProgram = 0;
        }
        
        return NO;
    }
    if (![self linkProgram:_guiProgram]) {
        NSLog(@"Failed to link program: %d", _guiProgram);
        
        if (vertGUIShader) {
            glDeleteShader(vertGUIShader);
            vertGUIShader = 0;
        }
        if (fragGUIShader) {
            glDeleteShader(fragGUIShader);
            fragGUIShader = 0;
        }
        if (_guiProgram) {
            glDeleteProgram(_guiProgram);
            _guiProgram = 0;
        }
        
        return NO;
    }

    // Get uniform locations.
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program, "normalMatrix");
    uniforms[UNIFORM_TRANSLATION_MATRIX] = glGetUniformLocation(_program, "translationMatrix");
    uniforms[UNIFORM_HEX_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_hexProgram, "modelViewProjectionMatrix");
    uniforms[UNIFORM_HEX_COLOUR] = glGetUniformLocation(_hexProgram, "color");
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }
    
    if (vertHexShader) {
        glDetachShader(_hexProgram, vertHexShader);
        glDeleteShader(vertHexShader);
    }
    if (fragHexShader) {
        glDetachShader(_hexProgram, fragHexShader);
        glDeleteShader(fragHexShader);
    }
    
    if (vertGUIShader) {
        glDetachShader(_guiProgram, vertGUIShader);
        glDeleteShader(vertGUIShader);
    }
    if (fragGUIShader) {
        glDetachShader(_guiProgram, fragGUIShader);
        glDeleteShader(fragGUIShader);
    }

    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)ƒ:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
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
    
    
}

- (IBAction)pausePressed:(id)sender {
    [sender setImage:[UIImage imageNamed:@"PausePressed.png"] forState:UIControlStateHighlighted];
}

@end
