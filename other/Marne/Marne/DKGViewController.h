//
//  DKGViewController.h
//  Marne
//
//  Created by Dylan Garrett on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DKGNetSendPacket.h"

@interface DKGViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *textBox;
@property NSMutableArray *packets;
@property NSTimer *timer;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)getData:(id)sender;

@end
