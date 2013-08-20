//
//  CMPViewController.m
//  Custom MidiPad
//
//  Created by Matt Rohr on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CMPViewController.h"
#import "CMPPadView.h"
#import "CMPPadDetailsViewController.h"
@implementation CMPViewController
@synthesize statusLight;
@synthesize toolbar;
@synthesize editButton;
@synthesize addPadButton;
@synthesize padViews,isEditing,midi,detailsController,detailsPopover,currentPage;
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setPadViews:[[NSMutableArray alloc]init]];
    self.detailsController = [[CMPPadDetailsViewController alloc] init];
    currentPage = 1;
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(dismissPopover)
                                                 name:@"hidePopover" 
                                               object:nil];
    [self loadPadsFromBundle:0];
    [self updateStatusLight];
	// Do any additional setup after loading the view, typically from a nib.
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [midi enableNetwork:YES];
    [self updateStatusLight];
    
}

-(void)loadPadsFromBundle:(int)page{
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [path stringByAppendingPathComponent:@"storedSettings.plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:finalPath];
    if(dict == nil){
        dict = [[NSDictionary alloc] init]; 
    }
    NSArray *pages = [dict objectForKey:@"pages"];
    if(pages == nil){
        pages = [[NSArray alloc] init];
    }
    NSArray *pads = [[NSArray alloc] init];
    if(page < [pages count]){
        pads = [pages objectAtIndex:0];
    }
    for(NSDictionary *padDict in pads){
        CMPPadView *pad = [[CMPPadView alloc] initFromDictionary:padDict];
        [self.padViews addObject:pad];
        [self.view addSubview:pad];
    }
}
-(void)savePageToBundle:(int) page{
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [path stringByAppendingPathComponent:@"storedSettings.plist"];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[NSDictionary dictionaryWithContentsOfFile:finalPath]];
    if(dict == nil){
        dict = [[NSMutableDictionary alloc] init]; 
    }
    NSMutableArray *pages = [[NSMutableArray alloc] initWithArray:[dict objectForKey:@"pages"]];
    if(pages == nil){
        pages = [[NSMutableArray alloc] init];
    }
    NSMutableArray *pads = [[NSMutableArray alloc]init];
    for(CMPPadView *pad in self.padViews){
        NSDictionary *padDict = [pad toDictionary];
        [pads addObject:padDict];
    }
    [pages insertObject:pads atIndex:page];
    [dict setObject:pages forKey:@"pages"];
    [dict writeToFile:finalPath atomically:NO];
}
- (void)viewDidUnload
{
    [self setEditButton:nil];
    [self setAddPadButton:nil];
    [self setToolbar:nil];
    [self setStatusLight:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}
-(void)longPressPad:(UIGestureRecognizer *)recognizer{
    if(([recognizer class] == [UILongPressGestureRecognizer class] && recognizer.state == UIGestureRecognizerStateBegan) ||
       ([recognizer class] == [UITapGestureRecognizer class]       && recognizer.state == UIGestureRecognizerStateEnded)){
        NSLog(@"Long press");
        if(self.detailsPopover){
            [self.detailsPopover dismissPopoverAnimated:YES];
        }
        CMPPadView *padView =((CMPPadView *) recognizer.view);
        self.detailsController = [[CMPPadDetailsViewController alloc] initWithPadView:padView];
        self.detailsController.delegate = self;
        self.detailsPopover = [[UIPopoverController alloc] 
                                           initWithContentViewController:self.detailsController];
        
        [self.detailsPopover presentPopoverFromRect:CGRectMake(padView.center.x,padView.center.y,1,1) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

- (void)resizePad:(UIGestureRecognizer *)sender {
    static CGRect initialBounds;
    
    UIView *pad = sender.view;
    
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        initialBounds = pad.bounds;
    }
    CGFloat factor = [(UIPinchGestureRecognizer *)sender scale];
    
    CGAffineTransform zt = CGAffineTransformScale(CGAffineTransformIdentity, factor, factor);
    pad.bounds = CGRectApplyAffineTransform(initialBounds, zt);
    [pad setNeedsDisplay];
    return;
}
-(void)dismissPopover{
    if(self.detailsPopover){
        [self.detailsPopover dismissPopoverAnimated:YES];
    }
}
- (IBAction)toggleEdit:(id)sender {
    [self setIsEditing:!self.isEditing];
    for(CMPPadView *pad in padViews){
        [pad setIsEditing:self.isEditing];
        if(self.isEditing){
            [self addRecognizers:pad];
        }else{
            for(UIGestureRecognizer *rec in pad.gestureRecognizers){
                [pad removeGestureRecognizer:rec];
            }
        }
    }
    if(isEditing){
        editButton.title = @"Finish Editing";
        addPadButton.enabled = YES;
        
    }else{
        editButton.title = @"Edit Pad";
        addPadButton.enabled = NO;
        [self savePageToBundle:0];
    }
}
-(BOOL)updateStatusLight{
    NSArray *destinations = [self.midi destinations];
    for(PGMidiDestination *dest in destinations){
        MIDIEndpointRef endpointRef = [dest endpoint];
        CFStringRef name = (CFStringRef)@"apple.midirtp.session";
        CFDictionaryRef *dictRef =(CFDictionaryRef *) alloca(sizeof(CFDictionaryRef));
        MIDIObjectGetDictionaryProperty(endpointRef, name, dictRef);
        NSDictionary *dict = (__bridge NSDictionary *)*dictRef;
        NSArray *peers = [dict objectForKey:@"peers"];
        if(peers && [peers count] > 0){
            statusLight.tintColor = [UIColor greenColor];
            return YES;
        }
    }
    statusLight.tintColor = [UIColor redColor];
    return NO;
}
-(void)addRecognizers:(UIView *) view{
    [view addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressPad:)]];
    [view addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(resizePad:)]];
    UITapGestureRecognizer *tapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(longPressPad:)];
    tapRec.numberOfTapsRequired = 2;
    [view addGestureRecognizer:tapRec];
}

- (IBAction)addPad:(id)sender {
    CGRect rect = CGRectMake(0, 0, 100, 100);
    CMPPadView *pad = [[CMPPadView alloc] initWithFrame:rect];
    pad.isEditing = self.isEditing;
    pad.delegate = self;
    if(self.isEditing){
        [self addRecognizers:pad];
    }
    [[self padViews] addObject:pad];
    [self.view addSubview:pad];
}

-(void)padRemoved:(CMPPadView *)pad{
    [self.padViews removeObject:pad];
}


-(void)midiOn:(int)note channel:(int)channel velocity:(int)velocity{
    int statusByte = 128 + 16 + channel;
    //int statusByte = 0x90;
    const UInt8 bytes[] = {statusByte,note,velocity};
    [self sendMidiBytes:bytes];
    
}
-(void)midiOff:(int)note channel:(int)channel{
    int statusByte = 128 +16 + (channel - 1);
    //int statusByte = 0x80;
    const UInt8 bytes[] = {statusByte,note,0};
    [self sendMidiBytes:bytes];
    
}
-(void)sendMidiBytes:(const UInt8[]) bytes{
    [midi sendBytes:bytes size:sizeof(&bytes)];    
}

- (void) midi:(PGMidi*)midi sourceAdded:(PGMidiSource *)source{
        [self updateStatusLight];
}
- (void) midi:(PGMidi*)midi sourceRemoved:(PGMidiSource *)source{
        [self updateStatusLight];
}
- (void) midi:(PGMidi*)midi destinationAdded:(PGMidiDestination *)destination{
            [self updateStatusLight];
}
- (void) midi:(PGMidi*)midi destinationRemoved:(PGMidiDestination *)destination{
            [self updateStatusLight];
}
- (void) propertyChanged{
        [self updateStatusLight];
    
}
- (void) midiSource:(PGMidiSource*)input midiReceived:(const MIDIPacketList *)packetList{
    NSLog(@"TEST");
    NSLog(@"%@",packetList);
}

/*-(void)sendMidiOff:(NSNumber *) sentNote{
    const UInt8 bytes[] = {0x80,[sentNote intValue],127};
    [midi sendBytes:bytes size:sizeof(bytes)];    
}*/


@end
