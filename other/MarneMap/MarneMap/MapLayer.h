//
//  MapLayer.h
//  MarneMap
//
//  Created by Dylan Garrett on 4/8/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "NetSendPacket.h"

#define BACKGROUND_TAG 0

@interface MapLayer : CCLayer {
    BOOL updating;
    NSMutableArray *netPackets;
}
//@property (nonatomic) IBOutlet UITextView *textBox;
//@property (retain) NSMutableArray *netPackets;
@property (retain) NSTimer *timer;
//@property (nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UITextField *ipField;
@property (retain) NSString *ipAddr;
@property (retain) NSMutableDictionary *turtleCache;

+(CCScene *) scene;

- (IBAction)getData:(id)sender;
- (IBAction)resetData:(id)sender;
- (void)showTime:(double)tick;
- (CCSprite*)getTurtle:(NSNumber*)id;


@end
