//
//  B_Group.h
//  Beepr
//
//  Created by JH Lee on 7/3/15.
//  Copyright (c) 2015 Catalyze Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "catalyze.h"
@interface B_Group : NSObject{
    NSArray* members;
    NSString *name;
    CatalyzeEntry * mEntry;
    NSString * user;
    NSString *objectId;
}

-(id) initWithEntry:(CatalyzeEntry *) entry;
-(NSString *) getName;
-(NSArray *) getMemebers;
-(NSString *) getUserId;
-(NSString *) getObjectId;
-(CatalyzeEntry *) getEntry;
@end
