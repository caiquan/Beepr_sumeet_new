//
//  B_USER.h
//  Beerp
//
//  Created by JH Lee on 7/1/15.
//  Copyright (c) 2015 Catalyze Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "catalyze.h"

@interface B_USER : NSObject{
    CatalyzeEntry * mEntry;
    CatalyzeUser *mUser;
    NSString * objectId;
    NSString * email;
    NSString * fullname;
    NSArray *groupMember;
    NSString *profilePhoto;
    NSString *thumb;
}

-(id) initWithCatalyzeEntry:(CatalyzeEntry *) entry;
-(id) initWithCatalyzeUser:(CatalyzeUser *) user;
-(id) initWithDictionary:(NSDictionary* ) dic;
-(NSString* ) getObjectId;
-(NSString* ) getEmail;
-(NSString* ) getFullName;
-(NSArray* ) getGroupMember;
-(NSString *) getProfilePhoto;
-(NSString *) getThumb;
-(CatalyzeUser *) getUser;
-(CatalyzeEntry *) getEntry;

@end
