/*
 * Copyright (C) 2014 Catalyze, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

#import "Message.h"

@implementation Message

- (id)initWithClassName:(NSString *)className dictionary:(NSDictionary *)dictionary {
    self = [super initWithClassName:className];
    if (self) {
        for (NSString *s in [dictionary allKeys]) {
            [[self content] setValue:[dictionary objectForKey:s] forKey:s];
        }
    }
    return self;
}

- (NSString *)text {
    return [[self content] valueForKey:@"msgContent"];
}

- (NSString *)sender {
    return [[self content] valueForKey:@"fromPhone"];
}

- (NSDate *)date {
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MM-dd-yyyy HH:mm:ss.SSSSSS"];
    return [format dateFromString:[[self content] valueForKey:@"timestamp"]];
}

@end
