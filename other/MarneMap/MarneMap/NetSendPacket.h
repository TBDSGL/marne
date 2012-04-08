//
//  NetSendPacket.h
//  MarneMap
//
//  Created by Dylan Garrett on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetSendPacket : NSObject

@property (retain) NSNumber *tick;
@property (retain) NSString *name;
@property (retain) NSNumber *data;

- (id)initWithTick:(NSNumber*)newTick name:(NSString*)newName data:(NSNumber*)newData;

@end
