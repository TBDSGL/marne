//
//  MapLayer.m
//  MarneMap
//
//  Created by Dylan Garrett on 4/8/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MapLayer.h"


@implementation MapLayer
//@synthesize scrollView;
@synthesize ipField;
@synthesize netPackets, timer;
@synthesize ipAddr;

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MapLayer *layer = [MapLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
        // ask director the the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
        
        self.netPackets = [NSMutableArray array];
        
        ipField = [[UITextField alloc] initWithFrame:
                   CGRectMake(10, 10, 300, 31)];
        ipField.backgroundColor = [UIColor whiteColor];
        ipField.borderStyle = UITextBorderStyleRoundedRect;
        [[[CCDirector sharedDirector] openGLView] addSubview:ipField];
        
        UIButton *startButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [startButton setTitle:@"Start" forState:UIControlStateNormal];
        startButton.frame = CGRectMake(size.width - 100 - 10, 10, 100, 40);
        [[[CCDirector sharedDirector] openGLView] addSubview:startButton];
        [startButton addTarget:self action:@selector(getData:) forControlEvents:UIControlEventTouchUpInside];
        
        
        
        CCSprite *background = [CCSprite spriteWithFile:@"background.png"];
        background.position = ccp(size.width / 2, size.height / 2);
        [self addChild:background];
        
        updating = NO;
        //[self schedule:@selector(doGetData:)];
		
	}
	return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

- (IBAction)getData:(id)sender {
    if (updating) {
        NSLog(@"Timer being invalidated");
        //[timer invalidate];
        //timer = nil;
        [self unschedule:@selector(doGetData:)];
        [sender setTitle:@"Start" forState:UIControlStateNormal];
    } else {
        NSLog(@"Timer being started");
        [self.ipAddr release];
        self.ipAddr = [NSString stringWithString:ipField.text];
        [self schedule:@selector(doGetData:) interval:1.0];
        //[self performSelectorOnMainThread:@selector(startUpdate) withObject:nil waitUntilDone:YES];
        //[self startUpdate];
        [sender setTitle:@"Stop" forState:UIControlStateNormal];
    }
}




-(void)startUpdate {
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1 
                                             target:self 
                                           selector:@selector(doGetData:) 
                                           userInfo:nil 
                                            repeats:YES];
}

- (void)doGetData:(NSTimer*)theTimer {
    NSLog(@"Getting data");
    //NSString *ipAddr = ipField.text;
    NSNumber *lastTick = [NSNumber numberWithDouble:0.0];
    CCLOG(@"packets: %@", netPackets);
    if ([netPackets count] > 0) {
        
        lastTick = [[netPackets lastObject] tick];
    }
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:8080/?tick=%@", self.ipAddr, lastTick]];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:nil error:nil];
    NSLog(@"%@\n", data);
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@\n", str);
    NSArray *lines = [str componentsSeparatedByString:@"\n"];
    
    for (NSString *line in lines) {
        NSArray *items = [line componentsSeparatedByString:@"\t"];
        if ([items count] == 3 && [@"ticks" isEqualToString:[items objectAtIndex:0]] == NO) {
            NSNumber *tick = [NSNumber numberWithDouble:[[items objectAtIndex:0] doubleValue]];
            NSString *name = [items objectAtIndex:1];
            NSNumber *data = [NSNumber numberWithDouble:[[items objectAtIndex:2] doubleValue]];
            [netPackets addObject:[[NetSendPacket alloc] initWithTick:tick name:name data:data]];
        }
    }
    
    //textBox.text = [packets description];
    NSLog(@"new packets: %@", lines);
    
    
}
- (IBAction)resetData:(id)sender {
    netPackets = [NSMutableArray array];
    [timer invalidate];
    timer = nil;
}



@end
