//
//  B_Group.m
//  Beepr
//
//  Created by JH Lee on 7/3/15.
//  Copyright (c) 2015 Catalyze Inc. All rights reserved.
//

#import "B_Group.h"
#import "AppConstant.h"
@implementation B_Group

-(id) initWithEntry:(CatalyzeEntry *) entry{
    name = [[entry content] valueForKey:PF_GROUP_NAME];
    members = (NSArray *)[[entry content] valueForKey:PF_GROUP_MEMBERS];
    user = [[entry content] valueForKey:PF_GROUP_USER];
    objectId = [entry valueForKey:@"entryId"];
    mEntry = entry;
    
    return self;
}
-(NSString *) getName{
    return  name;
}
-(NSArray *) getMemebers{
    return members;
}
-(NSString *) getUserId{
    return user;
}
-(CatalyzeEntry *) getEntry{
    return mEntry;
}

-(NSString *) getObjectId;
{
    return objectId;
}
@end
