//
//  DKGViewController.m
//  Marne
//
//  Created by Dylan Garrett on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DKGViewController.h"

@interface DKGViewController ()

@end

@implementation DKGViewController
@synthesize scrollView;
@synthesize textBox, packets, timer;

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        packets = [NSMutableArray array];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setTextBox:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (IBAction)getData:(id)sender {
    if (timer && [timer isValid]) {
        NSLog(@"Timer being invalidated");
        [timer invalidate];
        timer = nil;
    } else {
        NSLog(@"Timer being started");
        [self performSelectorOnMainThread:@selector(startUpdate) withObject:nil waitUntilDone:YES];
        
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
    NSNumber *lastTick = [NSNumber numberWithDouble:0.0];
    if ([packets count] > 0) {
        lastTick = [[packets lastObject] tick];
    }
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://192.168.11.4:8080/?tick=%@", lastTick]];
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
            [packets addObject:[[DKGNetSendPacket alloc] initWithTick:tick name:name data:data]];
        }
    }
    
    textBox.text = [packets description];
    NSLog(@"packets: %@", [packets description]);
    
    
}
@end
