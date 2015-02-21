//
//  NSMutableArray+QueueAdditions.h
//  ProjectGray
//
//  Created by Dan Russell on 2015-02-20.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#ifndef ProjectGray_NSMutableArray_QueueAdditions_h
#define ProjectGray_NSMutableArray_QueueAdditions_h


@interface NSMutableArray (QueueAdditions)

-(id) dequeue;
-(void) enqueue:(id)obj;
-(id) peek:(int)index;
-(id) peekHead;
-(id) peekTail;
-(BOOL) empty;

@end

#endif
