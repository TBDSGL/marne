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

@interface MapLayer : CCLayer {
    BOOL updating;
}
//@property (nonatomic) IBOutlet UITextView *textBox;
@property (retain) NSMutableArray *netPackets;
@property (retain) NSTimer *timer;
//@property (nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UITextField *ipField;
@property (retain) NSString *ipAddr;

+(CCScene *) scene;

- (IBAction)getData:(id)sender;
- (IBAction)resetData:(id)sender;



@end
