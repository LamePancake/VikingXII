//
//  OBJLoader.h
//  ProjectGray
//
//  Created by Tim Wang on 2015-02-09.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#ifndef __ProjectGray__OBJLoader__
#define __ProjectGray__OBJLoader__

#include <stdio.h>
#include <stdlib.h>
#include <vector>
#include "glm/glm.hpp"

bool loadOBJ(
             const char * path,
             std::vector<glm::vec3> & out_vertices,
             std::vector<glm::vec2> & out_uvs,
             std::vector<glm::vec3> & out_normals
);

bool loadAssImp(
             const char * path,
             std::vector<unsigned short> & indices,
             std::vector<glm::vec3> & vertices,
             std::vector<glm::vec2> & uvs,
             std::vector<glm::vec3> & normals
);

#endif /* defined(__ProjectGray__OBJLoader__) */
