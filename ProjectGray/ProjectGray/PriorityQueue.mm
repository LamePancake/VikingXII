//
//  PriorityQueue.m
//  ProjectGray
//
//  Created by Dan Russell on 2015-03-09.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

//
//  PriorityQueue.mm
//

#import "PriorityQueue.h"
#include <algorithm>


typedef struct PQNode {
    void* obj;
    unsigned val;
} PQNode;

static bool NodeLessThan(PQNode &n1, PQNode &n2)
{
    if( n1.val != n2.val )
        return n1.val > n2.val;
    else
        return (long)n1.obj < (long)n2.obj;
}

@implementation PriorityQueue

- init
{
    if( ( self = [super init] ) )
    {
        mCount = 0;
        mCapacity = 100;
        mObjs = (PQNode *)malloc( mCapacity * sizeof(PQNode) );
    }
    return self;
}

- (void)dealloc
{
    free( mObjs );
}

#pragma mark -

- (void)buildheap
{
    std::make_heap( mObjs, mObjs + mCount, NodeLessThan );
    mHeapified = YES;
}

#pragma mark -

- (unsigned)count
{
    return mCount;
}

- (void)addObject: (id)obj value: (unsigned)val
{
    mCount++;
    if( mCount > mCapacity )
    {
        mCapacity *= 2;
        mObjs = (PQNode *)realloc( mObjs, mCapacity * sizeof(PQNode) );
    }
    
    mObjs[mCount - 1].obj = (__bridge_retained void *)obj;
    mObjs[mCount - 1].val = val;
    
    if( mHeapified )
        std::push_heap( mObjs, mObjs + mCount, NodeLessThan );
}

- (id)pop
{
    if( !mHeapified )
    {
        [self buildheap];
    }
    
    std::pop_heap( mObjs, mObjs + mCount, NodeLessThan );
    mCount--;
    return (__bridge_transfer id)mObjs[mCount].obj;
}

- (NSString *)description
{
    NSMutableString *str = [NSMutableString string];
    
    [str appendString: @"ChemicalBurnOrderedQueue = (n"];
    unsigned i;
    for( i = 0; i < mCount; i++ )
        [str appendFormat: @"t%@ = %un", mObjs[i].obj, mObjs[i].val];
    [str appendString: @")n"];
    
    return str;
}

@end