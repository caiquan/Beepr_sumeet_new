//
//  B_USER.m
//  Beerp
//
//  Created by JH Lee on 7/1/15.
//  Copyright (c) 2015 Catalyze Inc. All rights reserved.
//

#import "B_USER.h"
#import "catalyze.h"
#import "AppConstant.h"

@implementation B_USER
-(id) initWithCatalyzeEntry:(CatalyzeEntry *)entry{
    objectId = [[entry content] valueForKey:PF_USER_OBJECTID];
    fullname = [[entry content] valueForKey:PF_USER_FULLNAME];
    email = [[entry content] valueForKey:PF_USER_EMAIL];
    groupMember = [[entry content] valueForKey:PF_GROUP_MEMBERS];
    profilePhoto = [[entry content] valueForKey:@"profilePhoto"];
    thumb = [[entry content] valueForKey:@"thumb"];
    mEntry = entry;
    
    return self;
}
-(id) initWithCatalyzeUser:(CatalyzeUser *)user{
    objectId = user.usersId;
    fullname = user.username;
    email = user.email.primary;
    profilePhoto = user.profilePhoto;
    thumb = user.avatar;
    mUser = user;
    return self;
}
- (id) initWithDictionary: (NSDictionary *) entry{
    objectId = [entry valueForKey:PF_USER_OBJECTID];
    fullname = [entry valueForKey:PF_USER_FULLNAME];
    email = [entry valueForKey:PF_USER_EMAIL];
    groupMember = [entry valueForKey:PF_GROUP_MEMBERS];
    profilePhoto = [entry valueForKey:@"profilePhoto"];
    thumb = [entry valueForKey:@"thumb"];
    
    return self;
}

-(NSString* ) getObjectId{
    return objectId;
}
-(NSString* )getEmail{
    return email;
}
-(NSString* ) getFullName{
    return fullname;
}

-(NSArray* ) getGroupMember{
    return groupMember;
}
-(NSString *)getProfilePhoto{
    return profilePhoto;
}
-(NSString *) getThumb{
    return thumb;
}

- (CatalyzeUser *) getUser{
    return mUser;
}

-(CatalyzeEntry *) getEntry{
    return mEntry;
}
@end
