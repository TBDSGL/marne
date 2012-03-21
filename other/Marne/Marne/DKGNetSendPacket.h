//
//  DKGNetSendPacket.h
//  Marne
//
//  Created by Dylan Garrett on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DKGNetSendPacket : NSObject

@property NSNumber *tick;
@property NSString *name;
@property NSNumber *data;

- (id)initWithTick:(NSNumber*)newTick name:(NSString*)newName data:(NSNumber*)newData;

@end
