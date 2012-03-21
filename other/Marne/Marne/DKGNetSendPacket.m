//
//  DKGNetSendPacket.m
//  Marne
//
//  Created by Dylan Garrett on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DKGNetSendPacket.h"

@implementation DKGNetSendPacket
@synthesize tick, name, data;

- (id)initWithTick:(NSNumber*)newTick name:(NSString*)newName data:(NSNumber*)newData
{
    if (self = [super init]) {
        self.tick = newTick;
        self.name = newName;
        self.data = newData;
    }
    
    return self;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"tick: %@, name: %@, data: %@", tick, name, data];
}

@end
