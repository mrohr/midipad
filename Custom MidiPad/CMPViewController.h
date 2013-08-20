//
//  CMPViewController.h
//  Custom MidiPad
//
//  Created by Matt Rohr on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PGMidi.h"
#import "CMPPadDetailsViewController.h"
#import "CMPPadView.h"
@interface CMPViewController : UIViewController<PGMidiSourceDelegate,PGMidiDelegate,CMPPadViewDelegate,CMPPadDetailsControllerDelegate>
{
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *statusLight;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addPadButton;
@property(nonatomic) PGMidi *midi;
@property(nonatomic) NSMutableArray *padViews;
@property(strong,nonatomic) CMPPadDetailsViewController *detailsController;
@property(nonatomic,strong) UIPopoverController *detailsPopover;
@property(nonatomic) BOOL isEditing;
@property(nonatomic) int currentPage;

-(void)dismissPopover;
- (IBAction)toggleEdit:(id)sender;
- (IBAction)addPad:(id)sender;
@end
