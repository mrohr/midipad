//
//  CMPAppDelegate.h
//  Custom MidiPad
//
//  Created by Matt Rohr on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PGMidi.h"
@class CMPViewController;

@interface CMPAppDelegate : UIResponder <UIApplicationDelegate>
{
    PGMidi *midi;
}
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CMPViewController *viewController;

@end
