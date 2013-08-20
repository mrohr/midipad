//
//  CMPPadDetailsViewController.m
//  Custom MidiPad
//
//  Created by Matt Rohr on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CMPPadDetailsViewController.h"

@interface CMPPadDetailsViewController ()

@end

@implementation CMPPadDetailsViewController
@synthesize notes,notePicker,velocityLabel,velocitySlider,padView,delegate,channelLabel,channelSlider;
- (id)initWithPadView:(CMPPadView *)pad
{
    self = [super init];
    if (self) {
        // Custom initialization
        [self initNotes];
        self.padView = pad;
    }
    return self;
}

-(void)initNotes{
    NSMutableArray *noteArray = [[NSMutableArray alloc]init];
    NSArray *letters = [[NSArray alloc] initWithObjects:@"C",@"C#",@"D",@"Eb",@"E",@"F",@"F#",@"G",@"G#",@"A",@"Bb",@"B", nil];
    int octiveCount = 0;
    for(int i=0; i<127; i++){
        if(i%12 ==0){
            octiveCount +=1;
        }
        [noteArray addObject:[NSString stringWithFormat:@"%@%d",[letters objectAtIndex:i%12],octiveCount - 3]];
    }
    [self setNotes:noteArray];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    int popoverWidth = 320;
	// Do any additional setup after loading the view.
    int pickerWidth = 100;
    self.view.backgroundColor = [UIColor whiteColor];
    self.notePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x,
                                                                     self.view.frame.origin.y,
                                                                     pickerWidth,
                                                                     0)];
    self.notePicker.delegate = self;
    self.notePicker.dataSource = self;
    self.notePicker.showsSelectionIndicator = YES;
    [self.notePicker selectRow:self.padView.note inComponent:0 animated:NO];
    int labelHeight = 40;
    UIFont *labelFont = [UIFont fontWithName:@"Helvetica Neue" size:30];
    int pad = 5;
    self.velocityLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.origin.x + pickerWidth + pad,
                                                              self.view.frame.origin.y + pad,
                                                              popoverWidth - pickerWidth - pad*2,
                                                              labelHeight)];
    self.velocityLabel.textAlignment = UITextAlignmentLeft;
    self.velocityLabel.text = [NSString stringWithFormat: @"Velocity:%d",self.padView.velocity];
    self.velocityLabel.font = labelFont;
    self.velocityLabel.backgroundColor = [UIColor clearColor];

    self.velocitySlider = [[UISlider alloc] initWithFrame:CGRectMake(self.view.frame.origin.x + pickerWidth + pad,
                                                                  self.view.frame.origin.y + labelHeight + pad,
                                                                  popoverWidth - pickerWidth - pad*2,
                                                                  labelHeight)];
    self.velocitySlider.maximumValue = 127;
    self.velocitySlider.minimumValue = 0;
    [self.velocitySlider setValue:self.padView.velocity animated:NO];
    [self.velocitySlider addTarget:self action:@selector(updateVelocitySlider) forControlEvents:UIControlEventValueChanged];
    
    self.channelLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.origin.x + pickerWidth + pad,
                                                                  self.view.frame.origin.y + labelHeight*2 + pad*2,
                                                                  popoverWidth - pickerWidth - pad*2,
                                                                  labelHeight)];
    self.channelLabel.textAlignment = UITextAlignmentLeft;
    self.channelLabel.text = [NSString stringWithFormat: @"Channel:%d",self.padView.channel];
    self.channelLabel.font = labelFont;
    self.channelLabel.backgroundColor = [UIColor clearColor];
    
    self.channelSlider = [[UISlider alloc] initWithFrame:CGRectMake(self.view.frame.origin.x + pickerWidth + pad,
                                                                     self.view.frame.origin.y + labelHeight*3 + pad*3,
                                                                     popoverWidth - pickerWidth - pad*2,
                                                                     labelHeight)];
    self.channelSlider.maximumValue = 16;
    self.velocitySlider.minimumValue = 1;
    [self.channelSlider setValue:self.padView.channel animated:NO];
    [self.channelSlider addTarget:self action:@selector(updateChannelSlider) forControlEvents:UIControlEventValueChanged];
    
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteButton.frame= CGRectMake(self.view.frame.origin.x + pickerWidth -2,
                                   self.view.frame.origin.y + self.notePicker.bounds.size.height - labelHeight - pad, 
                                   popoverWidth - pickerWidth + 4,
                                   labelHeight + pad);
    [deleteButton setBackgroundImage:[[UIImage imageNamed:@"deletebutton.png"] stretchableImageWithLeftCapWidth:8.0f topCapHeight:0.0f] forState:UIControlStateNormal];
    [deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    deleteButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [deleteButton setTitle:@"Delete Pad" forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(deletePressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.velocityLabel];
    [self.view addSubview:self.velocitySlider];
    [self.view addSubview:self.channelLabel];
    [self.view addSubview:self.channelSlider];
    [self.view addSubview:deleteButton];
    [self.view addSubview:self.notePicker];
    self.contentSizeForViewInPopover = CGSizeMake(popoverWidth, self.notePicker.bounds.size.height);
}

-(void)deletePressed{
    UIActionSheet *confirm = [[UIActionSheet alloc] initWithTitle:@"Really Delete Pad?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles: nil];
    [confirm showInView:self.view];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 0){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hidePopover" 
                                                            object:nil];
        [delegate padRemoved:self.padView];
        [self.padView removeFromSuperview];
    }
}
-(void)updateVelocitySlider{
    int velocity = (int)self.velocitySlider.value;
    self.velocityLabel.text = [NSString stringWithFormat:@"Velocity:%d",velocity];
    self.padView.velocity = velocity;
}
-(void)updateChannelSlider{
    int channel = (int)self.channelSlider.value;
    if(channel < 1){
        channel = 1;
    }
    self.channelLabel.text = [NSString stringWithFormat:@"Channel:%d",channel];
    self.padView.channel = channel;
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    
    return [[self notes ]count];
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [[self notes] objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    NSLog(@"Selected Note: %@. midi value of selected note: %i", [[self notes] objectAtIndex:row], row);
    self.padView.note = row;
    self.padView.noteName = [[self notes] objectAtIndex:row];
}
@end
