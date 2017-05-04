//
//  BRCircleView.m
//  ViktoNote
//
//  Created by Edward Kim on 11/19/16.
//  Copyright © 2016 ViktoMedia. All rights reserved.
//

#import "BRProgressCircleView.h"
#import "Branding.h"

@interface BRProgressCircleView()
@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic) double startingPercentage;
@end

@implementation BRProgressCircleView

- (instancetype)initWithFrame:(CGRect)frame
{
	if ( self = [super initWithFrame:frame]) {
		[self setup];
	}
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super initWithCoder:aDecoder]) {
		[self setup];
	}
	return self;
}

- (void)setup
{
	[self setPercentage:0.0];
	[self setLineWidth:5];
	[self setBackgroundColor:[UIColor clearColor]];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
	[self drawCircle];
	// Drawing code
}

- (void)setPercentage:(CGFloat)percentage
{
	_percentage = percentage;
	_startingPercentage = 0;
	
	if (percentage>1.0) {
		_percentage = 1.0;
	}
	if (percentage<0.0) {
		_percentage = 0.0;
	}
	
	if (percentage>0) {
		self.timer = [NSTimer scheduledTimerWithTimeInterval:.06
													  target:self
													selector:@selector(updatePercentage:)
													userInfo:nil
													 repeats:YES];
	}
	
}

- (void)updatePercentage:(NSTimer*)timer
{
	_startingPercentage += .01;
	if (self.progress) {
		self.progress(_startingPercentage);
	}
	
	if (_startingPercentage >= _percentage) {
		_startingPercentage = _percentage;
		if (self.completion) {
			self.completion();
		}
		[timer invalidate];
		timer = nil;
	}
	[self setNeedsDisplay];
}

- (void)resetAnimation
{
	[self.timer invalidate];
	self.timer = nil;
	self.startingPercentage = 0;
	[self setNeedsDisplay];
}

- (void)drawCircle
{
	
	CGSize size = self.frame.size;
	CGFloat lineWidth = self.lineWidth;
	CGFloat diameter = fminf(size.width/2, size.height/2)-lineWidth/2;
	CGPoint center = CGPointMake(size.width / 2.0, size.height / 2.0);
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextBeginPath(ctx);
	
	CGContextSetLineWidth(ctx, lineWidth);
	CGFloat ra[] = {2,2};
	CGContextSetLineDash(ctx, 0.0, ra, 2);
	CGContextSetStrokeColorWithColor(ctx, [[Branding shareInstance] color:@"N"].CGColor);
	
	CGFloat starting = -M_PI_2;
	CGFloat arcLength = 2*M_PI;
	CGContextAddArc(ctx, center.x, center.y,diameter, starting, starting + arcLength*self.startingPercentage, 0);
	CGContextStrokePath(ctx);
}

@end
