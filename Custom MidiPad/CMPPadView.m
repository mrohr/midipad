//
//  CMPPadView.m
//  Custom MidiPad
//
//  Created by Matt Rohr on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CMPPadView.h"

@implementation CMPPadView
@synthesize isEditing,delegate,note,channel,velocity,noteName;
- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.userInteractionEnabled = YES;
        self.note = 60;
        self.noteName = @"C3";
        self.velocity = 100;
        self.channel = 1;
        self.backgroundColor = [UIColor clearColor];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 16;
        self.layer.borderColor = [UIColor blackColor].CGColor;
        self.layer.borderWidth = 1.5;
        beingTouched = NO;
    }
    return self;
}

-(id)initFromDictionary:(NSDictionary*) dict{
    self = [self init];
    if(self){
        [self resetFromDictionary:dict];
    }
    return self;
}
-(void)resetFromDictionary:(NSDictionary *)dict{
    self.note = [(NSNumber *)[dict objectForKey:@"note"] intValue];
    self.noteName = (NSString *)[dict objectForKey:@"noteName"];
    self.velocity = [(NSNumber *)[dict objectForKey:@"velocity"] intValue];
    self.channel = [(NSNumber *)[dict objectForKey:@"channel"] intValue];
    self.frame = CGRectFromString((NSString *)[dict objectForKey:@"frame"]);
}

-(NSDictionary *) toDictionary{
    NSMutableDictionary *pad = [[NSMutableDictionary alloc] init];
    [pad setObject:[NSNumber numberWithInt:self.note] forKey:@"note"];
    [pad setObject:self.noteName forKey:@"noteName"];
    [pad setObject:[NSNumber numberWithInt:self.velocity] forKey:@"velocity"];
    [pad setObject:[NSNumber numberWithInt:self.channel]  forKey:@"channel"];
    [pad setObject:NSStringFromCGRect(self.frame) forKey:@"frame"];
    
    return pad;
}

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    // When a touch starts, get the current location in the view
    if(isEditing){
    currentPoint = [[touches anyObject] locationInView:self];
    }else{
        beingTouched = YES;
        [self setNeedsDisplay];
        [delegate midiOn:self.note channel:self.channel velocity:self.velocity];
        //[self performSelectorInBackground:@selector(sendMidiOn:) withObject:[NSNumber numberWithInt:note]];
    }
}
-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // When a touch starts, get the current location in the view
    if(isEditing){
        
    }else{
        beingTouched = NO;
                [self setNeedsDisplay];
        [delegate midiOff:self.note channel:self.channel];
        //[self performSelectorInBackground:@selector(sendMidiOff:) withObject:[NSNumber numberWithInt:note]];

    }
}

-(void) setNoteName:(NSString *)name{
    noteName = name;
    [self setNeedsDisplay];
}
-(void) setChannel:(int)chan{
    channel = chan;
    [self setNeedsDisplay];
}
- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
    if(isEditing){
        // Get active location upon move
        CGPoint activePoint = [[touches anyObject] locationInView:self];
        
        // Determine new point based on where the touch is now located
        CGPoint newPoint = CGPointMake(self.center.x + (activePoint.x - currentPoint.x),
                                       self.center.y + (activePoint.y - currentPoint.y));
        
        //--------------------------------------------------------
        // Make sure we stay within the bounds of the parent view
        //--------------------------------------------------------
        float midPointX = CGRectGetMidX(self.bounds);
        // If too far right...
        if (newPoint.x > self.superview.bounds.size.width  - midPointX)
            newPoint.x = self.superview.bounds.size.width - midPointX;
        else if (newPoint.x < midPointX)  // If too far left...
            newPoint.x = midPointX;
        
        float midPointY = CGRectGetMidY(self.bounds);
        // If too far down...
        if (newPoint.y > self.superview.bounds.size.height  - midPointY)
            newPoint.y = self.superview.bounds.size.height - midPointY;
        else if (newPoint.y < midPointY)  // If too far up...
            newPoint.y = midPointY;
        
        // Set new center location
        self.center = newPoint;
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = {0.0,.4,1.0};
    
    NSArray *colors;
    if(beingTouched){
        colors = [NSArray arrayWithObjects:
                       (id)[UIColor colorWithRed:.7 green:.7 blue:.7 alpha:1].CGColor,
                       (id)[UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1].CGColor,
                       (id)[UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1].CGColor,nil];
    }else{
        colors = [NSArray arrayWithObjects:
                  (id)[UIColor colorWithRed:.8 green:.8 blue:.8 alpha:1].CGColor,
                  (id)[UIColor colorWithRed:.6 green:.6 blue:.6 alpha:1].CGColor,
                  (id)[UIColor colorWithRed:.3 green:.3 blue:.3 alpha:1].CGColor,nil];
    }
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace,(__bridge CFArrayRef)colors,locations);
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    CGContextSaveGState(context);
    CGContextAddRect(context, rect);
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(context);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    int size = rect.size.width /5;
    [self.noteName drawAtPoint:CGPointMake(rect.origin.x + 10, rect.origin.y + rect.size.height - size - 5) 
                      withFont:[UIFont systemFontOfSize:size]];
    int channelOffset = size / 2;
    if(self.channel >= 10){
        channelOffset = size;
    }
    [[NSString stringWithFormat:@"%d",self.channel] drawAtPoint:CGPointMake(rect.origin.x + rect.size.width - channelOffset - 10,
                                                                           rect.origin.y + rect.size.height - size - 5)
                                                       withFont:[UIFont systemFontOfSize:size]];
    
}

@end