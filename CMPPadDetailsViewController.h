//
//  CMPPadDetailsViewController.h
//  Custom MidiPad
//
//  Created by Matt Rohr on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMPPadView.h"

@protocol CMPPadDetailsControllerDelegate
-(void)padRemoved:(CMPPadView *) pad;
@end

@interface CMPPadDetailsViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate,UIActionSheetDelegate>{
    id<CMPPadDetailsControllerDelegate> delegate;
}

@property (nonatomic) NSMutableArray *notes;
@property (strong,nonatomic) CMPPadView *padView;
@property (strong,nonatomic) UIPickerView *notePicker;
@property (strong,nonatomic) UILabel *velocityLabel;
@property (strong,nonatomic) UISlider *velocitySlider;
@property (strong,nonatomic) UILabel *channelLabel;
@property (strong,nonatomic) UISlider *channelSlider;
@property (nonatomic) id<CMPPadDetailsControllerDelegate> delegate;

- (id)initWithPadView:(CMPPadView *)pad;
@end
