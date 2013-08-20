//
//  CMPPadView.h
//  Custom MidiPad
//
//  Created by Matt Rohr on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PGMidi.h"
#import <QuartzCore/QuartzCore.h>
@protocol CMPPadViewDelegate
-(void)midiOn:(int) note channel:(int)channel velocity:(int)velocity;
-(void)midiOff:(int) note channel:(int)channel;
@end
@interface CMPPadView : UIControl
{
    CGPoint currentPoint;
    bool beingTouched;
    id<CMPPadViewDelegate> delegate;
}
@property(nonatomic) id<CMPPadViewDelegate> delegate;
@property(nonatomic) int note;
@property(nonatomic) NSString *noteName;
@property(nonatomic) int channel;
@property(nonatomic) int velocity;
@property(nonatomic) BOOL isEditing;

-(id)initFromDictionary:(NSDictionary*) dict;
-(NSDictionary *) toDictionary;
@end
