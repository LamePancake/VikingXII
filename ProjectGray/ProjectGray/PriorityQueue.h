//
//  PriorityQueue.h
//  ProjectGray
//
//  Created by Dan Russell on 2015-03-09.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#ifndef ProjectGray_PriorityQueue_h
#define ProjectGray_PriorityQueue_h

#import <Foundation/Foundation.h>

// .h
@interface PriorityQueue : NSObject {
    struct PQNode*	mObjs;
    unsigned			mCount;
    unsigned			mCapacity;
    
    BOOL				mHeapified;
}

- init;

- (unsigned)count;
- (void)addObject: (id)obj value: (unsigned)val;
- (id)pop;

@end
#endif
