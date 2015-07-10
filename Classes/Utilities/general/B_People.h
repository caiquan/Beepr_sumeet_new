//
//  B_People.h
//  Beepr
//
//  Created by JH Lee on 7/2/15.
//  Copyright (c) 2015 Catalyze Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "catalyze.h"
#import "B_USER.h"
@interface B_People : NSObject{
    NSString *user1;
    NSString *user2;
    NSString *nameUser1;
    NSString *nameUser2;
    B_USER  *objUser1;
    B_USER  *objUser2;
    NSString *objectId;
}
- (id) initWithCaltalyzEntry: (CatalyzeEntry *) entry;
- (NSString *) getUser1;
- (NSString *) getUser2;
- (NSString *) getObjectId;
- (B_USER *) getObjUser1;
- (B_USER *) getObjUser2;
- (NSString *) getNameUser1;
- (NSString *) getNameUser2;

@end
