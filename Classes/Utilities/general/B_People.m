//
//  B_People.m
//  Beepr
//
//  Created by JH Lee on 7/2/15.
//  Copyright (c) 2015 Catalyze Inc. All rights reserved.
//

#import "B_People.h"
#import "catalyze.h"
#import "AppConstant.h"
@implementation B_People
- (id) initWithCaltalyzEntry:(CatalyzeEntry *)entry{
    user1 = [[entry content] valueForKey:PF_PEOPLE_USER1];
    user2 = [[entry content] valueForKey:PF_PEOPLE_USER2];
    nameUser1 = [[entry content] valueForKey:@"nameUser1"];
    nameUser2 = [[entry content] valueForKey:@"nameUser2"];
    objUser1 = [[entry content] valueForKey:@"objUser1"];
    objUser2 = [[entry content] valueForKey:@"objUser2"];
    objectId = [[entry content] valueForKey:@"objectId"];
    return self;
}

- (NSString *) getUser1{
    return user1;
}

- (NSString *) getUser2{
    return user2;
}

- (NSString *) getObjectId{
    return objectId;
}

- (B_USER *) getObjUser1{
    return objUser1;
}
- (B_USER *) getObjUser2{
    return objUser2;
}

- (NSString *) getNameUser1{
    return  nameUser1;
}
- (NSString *) getNameUser2{
    return nameUser2;
}

@end
