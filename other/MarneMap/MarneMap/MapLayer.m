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
//@synthesize netPackets, timer;
@synthesize ipAddr;
@synthesize turtleCache;

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
        
        netPackets = [[NSMutableArray array] retain];
        self.turtleCache = [[NSMutableDictionary dictionary] retain];
        
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
        [self addChild:background z:-1 tag:BACKGROUND_TAG];
        
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
    /*timer = [NSTimer scheduledTimerWithTimeInterval:0.1 
                                             target:self 
                                           selector:@selector(doGetData:) 
                                           userInfo:nil 
                                            repeats:YES];*/
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
        if ([items count] == 4 && [@"ticks" isEqualToString:[items objectAtIndex:0]] == NO) {
            NSNumber *tick = [NSNumber numberWithDouble:[[items objectAtIndex:0] doubleValue]];
            NSNumber *turtleID = [NSNumber numberWithDouble:[[items objectAtIndex:1] doubleValue]];
            NSString *name = [items objectAtIndex:2];
            NSNumber *data = [NSNumber numberWithDouble:[[items objectAtIndex:3] doubleValue]];
            [netPackets addObject:[[NetSendPacket alloc] initWithTick:tick turtleID:turtleID name:name data:data]];
        }
    }
    
    //textBox.text = [packets description];
    NSLog(@"new packets: %@", lines);
    
    if ([netPackets count] > 0) {
        
        lastTick = [[netPackets lastObject] tick];
        [self showTime:[lastTick doubleValue]];
    }
    
    
    
}
- (IBAction)resetData:(id)sender {
    netPackets = [NSMutableArray array];
    //[timer invalidate];
    //timer = nil;
}

- (void)showTime:(double)tick
{
    int startIndex = [netPackets count]-1, endIndex = 0;
    NSNumber *tickNumber = [NSNumber numberWithDouble:tick];
    CCNode *background = [self getChildByTag:BACKGROUND_TAG];
    /*for (int i = 0; i < [netPackets count]; i++) {
        if ([[[netPackets objectAtIndex:i] tick] isEqualToNumber:tickNumber]) {
            startIndex = i;
            break;
        }
    }*/
    while (startIndex > 0 && tick <= [[[netPackets objectAtIndex:startIndex] tick] doubleValue]) {
        startIndex--;
    }
    while (endIndex < [netPackets count]-1 && tick >= [[[netPackets objectAtIndex:endIndex] tick] doubleValue]) {
        endIndex++;
    }
    
    for (int i = startIndex; i <= endIndex; i++) {
        NetSendPacket *packet = [netPackets objectAtIndex:i];
        if ([[packet name] isEqualToString:@"x"]) {
            CCSprite *turtle = [self getTurtle:packet.turtleID];
            float x = background.position.x + (background.boundingBox.size.width / 2) * [packet.data floatValue];
            turtle.position = ccp(x, turtle.position.y);
            CCLOG(@"Turtle pos: %f, %f", turtle.position.x, turtle.position.y);
        }
        if ([[packet name] isEqualToString:@"y"]) {
            CCSprite *turtle = [self getTurtle:packet.turtleID];
            // - (background.contentSize.height / 2)
            float y = background.position.y + (background.boundingBox.size.height / 2) * [packet.data floatValue];
            turtle.position = ccp(turtle.position.x, y);
            CCLOG(@"Turtle pos:  %f, %f", turtle.position.x, turtle.position.y);
        }
        
    }
    
}


- (CCSprite*)getTurtle:(NSNumber*)turtleID
{
    CCLOG(@"Getting id: %@", turtleID);
    CCSprite *turtle = [turtleCache objectForKey:turtleID];
    if (turtle == nil) {
        CCSprite *newTurtle = [CCSprite spriteWithFile:@"button_question.png"];
        [turtleCache setObject:newTurtle forKey:turtleID];
        [self addChild:newTurtle];
        return newTurtle;
    }
    
    return turtle;
}



@end
