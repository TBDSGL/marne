//
//  NetSendPacket.m
//  MarneMap
//
//  Created by Dylan Garrett on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NetSendPacket.h"

@implementation NetSendPacket
@synthesize tick, turtleID, name, data;

- (id)initWithTick:(NSNumber*)newTick turtleID:(NSNumber*)newID name:(NSString*)newName data:(NSNumber*)newData
{
    if (self = [super init]) {
        self.tick = newTick;
        self.turtleID = newID;
        self.name = newName;
        self.data = newData;
    }
    
    return self;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"tick: %@, name: %@, data: %@", self.tick, self.name, self.data];
}

@end
