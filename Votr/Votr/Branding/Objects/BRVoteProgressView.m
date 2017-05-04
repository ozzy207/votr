//
//  BRVoteProgressView.m
//  Votr
//
//  Created by Edward Kim on 2/26/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "BRVoteProgressView.h"
#import "BRLabel.h"

@interface  BRVoteProgressView ()
@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic) double startingPercentage;
@property (nonatomic) BOOL incrementChange;
@end

@implementation  BRVoteProgressView

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
		//[self setup];
	}
	return self;
}

- (void)setup
{
	[self setPercentage:0.0];
	[self setLineWidth:5];
	[self setBackgroundColor:[UIColor clearColor]];
	[self.detailLabel setText:@""];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
	[self drawBackgroundCircle];
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
		self.timer = [NSTimer scheduledTimerWithTimeInterval:.02
													  target:self
													selector:@selector(updatePercentage:)
													userInfo:nil
													 repeats:YES];
	}
}

- (void)changePercentage:(CGFloat)percentage
{
	_startingPercentage = _percentage;
	
	self.incrementChange = _startingPercentage<percentage;
	
	if (_startingPercentage == percentage) {
		return;
	}
	
	_percentage = percentage;
	
	
	if (percentage>1.0) {
		_percentage = 1.0;
	}
	if (percentage<0.0) {
		_percentage = 0.0;
	}
	
	self.timer = [NSTimer scheduledTimerWithTimeInterval:.02
												  target:self
												selector:@selector(updatePercentageChange:)
												userInfo:nil
												 repeats:YES];
}

- (void)updatePercentageChange:(NSTimer*)timer
{
	_startingPercentage += self.incrementChange?.01:-0.01;
	if (self.progress) {
		self.progress(_startingPercentage);
	}
	
	if (self.incrementChange? (_startingPercentage >= _percentage):(_startingPercentage <= _percentage)) {
		_startingPercentage = _percentage;
		if (self.completion) {
			self.completion();
		}
		[timer invalidate];
		timer = nil;
	}
	
	[self.detailLabel setText:[NSString stringWithFormat:@"%0.0f%%",_startingPercentage*100]];
	[self setNeedsDisplay];
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
	
	[self.detailLabel setText:[NSString stringWithFormat:@"%2.0f%%",_startingPercentage*100]];
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
	CGContextSetStrokeColorWithColor(ctx, [[Branding shareInstance] color:self.colorCode].CGColor);
	
	CGFloat starting = -M_PI_2;
	CGFloat arcLength = 2*M_PI;
	CGContextAddArc(ctx, center.x, center.y,diameter, starting, starting + arcLength*self.startingPercentage, 0);
	CGContextStrokePath(ctx);
}

- (void)drawBackgroundCircle
{
	CGSize size = self.frame.size;
	CGFloat lineWidth = self.lineWidth;
	CGFloat diameter = fminf(size.width/2, size.height/2)-lineWidth/2;
	CGPoint center = CGPointMake(size.width / 2.0, size.height / 2.0);
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextBeginPath(ctx);
	
	CGContextSetLineWidth(ctx, lineWidth);
	CGContextSetStrokeColorWithColor(ctx, [[[Branding shareInstance] color:@"K"] colorWithAlphaComponent:0.8].CGColor);
	
	CGFloat starting = -M_PI_2;
	CGFloat arcLength = 2*M_PI;
	CGContextAddArc(ctx, center.x, center.y,diameter, starting, starting + arcLength, 0);
	CGContextStrokePath(ctx);
}

#pragma mark - Setters
- (void)setColorCode:(NSString *)colorCode
{
	_colorCode = colorCode;
	//[self setBackgroundColor:[[Branding shareInstance] color:colorCode]];
	[self.detailLabel setColorCode:colorCode];
	[self setNeedsDisplay];
}

@end
