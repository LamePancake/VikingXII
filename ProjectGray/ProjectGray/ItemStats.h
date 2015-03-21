//
//  ItemStats.h
//  ProjectGray
//
//  Created by Tim Wang on 2015-03-21.
//  Copyright (c) 2015 Tim Wang. All rights reserved.
//

#ifndef ProjectGray_ItemStats_h
#define ProjectGray_ItemStats_h


/**
 * Indicates the ship's general class.
 *
 * Light units can move quickly, but they have little health and do not have a large attack range or damage.
 * Medium units have both moderate move range and attack damage/range.
 * Heavy units can't move far, but they can deal significant damage.
 */
#define ITEM_CLASSES 3 /// The number of of classes. Must be updated when factions are added/deleted.
typedef enum _ItemClasses {
    PROJECTILE = 0,
    FLAG = 1
} ItemClasses;

#endif
