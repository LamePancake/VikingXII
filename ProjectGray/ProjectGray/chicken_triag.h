/*
created with obj2opengl.pl

source file    : ./chicken_triag.obj
vertices       : 666
faces          : 1329
normals        : 3984
texture coords : 907


// include generated arrays
#import "./chicken_triag.h"

// set input data to arrays
glVertexPointer(3, GL_FLOAT, 0, chicken_triagVerts);
glNormalPointer(GL_FLOAT, 0, chicken_triagNormals);
glTexCoordPointer(2, GL_FLOAT, 0, chicken_triagTexCoords);

// draw data
glDrawArrays(GL_TRIANGLES, 0, chicken_triagNumVerts);
*/

#ifndef CHICKENTRIAG_H
#define CHICKENTRIAG_H
extern unsigned int chicken_triagNumVerts;
extern float chicken_triagVerts[];
#endif
