//
//  GLProgramUtils.h
//  Assignment1
//
//  Created by Shane Spoor on 2015-02-13.
//  Copyright (c) 2015 BCIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

// Converts a buffer offset to a pointer to make OpenGL happy.
#define BUFFER_OFFSET(i) ((char *)NULL + (i))

/**
 * @brief Failure states for the makeProgram function.
 */
enum GL_PROG_UTILS_MAKEFAIL
{
    VERT_SHADER_FAIL  = 1,
    FRAG_SHADER_FAIL  = 2,
    PROGRAM_LINK_FAIL = 3
};

/**
 * Contains the OpenGL index indicating the type of attribute and its name within the vertex shader.
 */
typedef struct _ShaderAttribute {
    GLuint attributeIndex;      // The user-defined attribute index to reference this attribute (e.g. GLKVertexAttribPosition).
    const char *attributeName;  // The name of the attribute within the shader (e.g. "texCoordIn").
} ShaderAttribute;

typedef struct _VertexAttribute {
    GLuint index;               // The user-defined attribute index to reference this attribute (e.g. GLKVertexAttribPosition).
    GLint size;                 // The number of elements that make up this attribute.
    GLenum type;                // The type of element (GL_FLOAT, GL_UNSIGNED_SHORT, etc.).
    GLboolean normalise;        // Whether to normalise the values before use.
    GLsizei stride;             // The number of bytes between attributes of this type.
    unsigned int bufferOffset;  // The starting offset into the buffer from which to read the first attribute.
} VertexAttribute;

@interface GLProgramUtils : NSObject

/**
 * @brief Validates a linked program.
 *
 * @discussion According to the <a href="https://www.khronos.org/opengles/sdk/docs/man/xhtml/glValidateProgram.xml">
 *             OpenGL</a> specification, glValidateProgram determines whether the program can run given the current
 *             state of OpenGL. If this function returns NO, use <a href="https://www.khronos.org/opengles/sdk/docs/man/xhtml/glGetProgramInfoLog.xml">
 *             glGetProgramInfoLog</a> to retrieve a string describing the problem.
 *
 * @param prog Handle to the program to be validated.
 * @return Whether the program is valid.
 */
+ (BOOL)validateProgram:(GLuint)prog;

/**
 * @brief Links a compiled shader program.
 * @param prog Index to the compiled program to be linked.
 * @return Whether the shader was successfully linked.
 */
+ (BOOL)linkProgram:(GLuint)prog;

/**
 * @brief Compiles the shader of the specified type with source code in the given file.
 *
 * @discussion Note that the shader can only be used if this function returns YES.
 *
 * @param shader Pointer to an integer which will hold the shader index on success.
 * @param type   The type of shader (not sure what this actually is).
 * @param file   The path to the file containing the shader's source code.
 * @return       Whether the shader was successfully compiled.
 */
+ (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;

/**
 * @brief Compiles, links and validates a program with the given vertex and fragment shader.
 * @discussion The returned integer will be 0 on success and will otherwise hold the creation step that failed.
 * @param program        Pointer to ta GLuint which will hold the program handle on successful compilation.
 * @param vertShaderPath Path to the vertex shader.
 * @param fragShaderPath Path to the fragment shader.
 * @param attributes     An array of shader attribute structs ({
 * @return The creation step that failed or 0 on success.
 */
+ (int)makeProgram:(GLuint *)program withVertShader: (NSString *)vertShaderPath andFragShader: (NSString *)fragShaderPath
     andAttributes: (ShaderAttribute *)attributes withNumberOfAttributes: (int) attrCount;

/**
 * @brief Loads in a texture
 * @discussion Returns a int that represents the texture
 * @param fileName        The path to the texture to load.
 * @return An int that represents the texture.
 */
+ (GLuint)setupTexture:(NSString *)fileName;

/**
 * @brief Sets up the vertex specification for the currently bound buffer.
 * @param attributes A list of vertex attributes to enable.
 * @param numAttrs   The number of attributes in the list.
 */
+ (void)setVertexAttributes: (VertexAttribute *)attributes withNumAttributes: (unsigned int)numAttrs;
@end
