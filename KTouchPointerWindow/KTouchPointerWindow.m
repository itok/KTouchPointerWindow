//
//  TouchWindow.m
//
//  Created by Ito Kei on 12/03/02.
//  Copyright (c) 2012年 itok. All rights reserved.
//

#import "KTouchPointerWindow.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>

// Settings for touch pointer
#define KTOUCH_POINTER_FADEOUT_TIME (0.5)		// second
#define KTOUCH_POINTER_RED (1)					// 0-1
#define KTOUCH_POINTER_GREEN (0)
#define KTOUCH_POINTER_BLUE (0)
#define KTOUCH_POINTER_ALPHA (0.6f)			// 0-1
#define KTOUCH_POINTER_RADIUS (15)

static UIColor* s_color = nil;
static CGFloat s_radius = 0;
static NSTimeInterval s_fadeout = 0;
static CGFloat s_alpha = 0;

void KTouchPointerWindowInstall() 
{
	KTouchPointerWindowInstallWithOptions([UIColor colorWithRed:KTOUCH_POINTER_RED green:KTOUCH_POINTER_GREEN blue:KTOUCH_POINTER_BLUE alpha:KTOUCH_POINTER_ALPHA], KTOUCH_POINTER_RADIUS, KTOUCH_POINTER_FADEOUT_TIME);
}

void KTouchPointerWindowInstallWithOptions(UIColor* color, CGFloat radius, NSTimeInterval fadeout)
{
	static BOOL installed = NO;
	if (!installed) {
		installed = YES;
		
		Class _class = [UIWindow class];
		
		Method orig = class_getInstanceMethod(_class, sel_registerName("sendEvent:"));
		Method my = class_getInstanceMethod(_class, sel_registerName("itk_sendEvent:"));
		method_exchangeImplementations(orig, my);
	
		s_color = [color copy];
		s_radius = radius;
		s_fadeout = fadeout;
		
		if (!s_color) {
			s_color = [[UIColor colorWithRed:KTOUCH_POINTER_RED green:KTOUCH_POINTER_GREEN blue:KTOUCH_POINTER_BLUE alpha:KTOUCH_POINTER_ALPHA] copy];
		}
		[s_color getRed:nil green:nil blue:nil alpha:&s_alpha];
		if (s_radius == 0) {
			s_radius = KTOUCH_POINTER_RADIUS;
		}
	}
}

static char s_key;

@interface __ITKTouchPointerView : UIView

@property (nonatomic, retain) NSSet* touches;

@end

@interface UIWindow (KTouchPointerWindow)

@property (nonatomic, retain) __ITKTouchPointerView* itk_touchPointerView;

@end

@implementation UIWindow (KTouchPointerWindow)

- (__ITKTouchPointerView*) itk_touchPointerView
{
	return objc_getAssociatedObject(self, &s_key);
}

-(void) setItk_touchPointerView:(__ITKTouchPointerView *)value
{
	objc_setAssociatedObject(self, &s_key, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void) itk_sendEvent:(UIEvent *)event
{
	if (!self.itk_touchPointerView) {
		self.itk_touchPointerView = [[__ITKTouchPointerView alloc] initWithFrame:self.bounds];
		self.itk_touchPointerView.backgroundColor = [UIColor clearColor];
		self.itk_touchPointerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.itk_touchPointerView.userInteractionEnabled = NO;
		[self addSubview:self.itk_touchPointerView];
	}
	
	[self bringSubviewToFront:self.itk_touchPointerView];
	
	NSMutableSet* began = nil;
	NSMutableSet* moved = nil;
	NSMutableSet* ended = nil;
	NSMutableSet* cancelled = nil;
	for (UITouch* touch in [event allTouches]) {
		switch (touch.phase) {
			case UITouchPhaseBegan:
				if (!began) {
					began = [NSMutableSet set];
				}
				[began addObject:touch];
				break;
			case UITouchPhaseEnded:
				if (!ended) {
					ended = [NSMutableSet set];
				}
				[ended addObject:touch];
				break;
			case UITouchPhaseCancelled:
				if (!cancelled) {
					cancelled = [NSMutableSet set];
				}
				[cancelled addObject:touch];
				break;
			case UITouchPhaseMoved:
				if (!moved) {
					moved = [NSMutableSet set];
				}
				[moved addObject:touch];
				break;
			default:
				break;
		}
	}
	if (began) {
		[self.itk_touchPointerView touchesBegan:began withEvent:event];
	}
	if (moved) {
		[self.itk_touchPointerView touchesMoved:moved withEvent:event];
	}
	if (ended) {
		[self.itk_touchPointerView touchesEnded:ended withEvent:event];
	}
	if (cancelled) {
		[self.itk_touchPointerView touchesCancelled:cancelled withEvent:event];
	}
	[self itk_sendEvent:event];
}

@end

@implementation __ITKTouchPointerView

@synthesize touches;

-(void) drawRect:(CGRect)rect
{
	for (UITouch* touch in self.touches) {
		CGRect touchRect = CGRectZero;
		touchRect.origin = [touch locationInView:self];
		UIBezierPath* bp = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(touchRect, -s_radius, -s_radius)];
		[s_color set];
		[bp fill];
	}
}

-(void) touchesBegan:(NSSet *)_touches withEvent:(UIEvent *)event
{
	self.touches = _touches;
	[self setNeedsDisplay];
}

-(void) touchesMoved:(NSSet *)_touches withEvent:(UIEvent *)event
{
	self.touches = _touches;
	[self setNeedsDisplay];	
}

-(void) touchesCancelled:(NSSet *)_touches withEvent:(UIEvent *)event
{
	if (s_fadeout > 0) {
		for (UITouch *touch in _touches) {
			[self drawFadeoutTouchPointer:[touch locationInView:self]];
		}
	}

	self.touches = nil;
	[self setNeedsDisplay];
}

-(void) touchesEnded:(NSSet *)_touches withEvent:(UIEvent *)event
{
	if (s_fadeout > 0) {
		for (UITouch *touch in _touches) {
			[self drawFadeoutTouchPointer:[touch locationInView:self]];
		}
	}
	
	self.touches = nil;
	[self setNeedsDisplay];
}

// draw the touch pointer to fade out
- (void)drawFadeoutTouchPointer:(CGPoint)point
{
    CAShapeLayer* layer = [CAShapeLayer layer];
	layer.frame = CGRectMake(point.x - s_radius, point.y - s_radius, s_radius * 2, s_radius * 2);
	layer.opacity = s_alpha;
    layer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, s_radius * 2, s_radius * 2)].CGPath;
    layer.fillColor = [s_color CGColor];
	[self.layer addSublayer:layer];
	
	[CATransaction flush];
	[CATransaction begin];
	[CATransaction setCompletionBlock:^{
		[layer removeFromSuperlayer];
	}];
	
	[CATransaction setValue:[NSNumber numberWithFloat:s_fadeout] forKey:kCATransactionAnimationDuration];
	layer.opacity = 0.0f;
	
	[CATransaction commit];
}

-(void) didAddSubview:(UIView *)subview
{
	self.userInteractionEnabled = ([self.subviews count] > 0);
}

-(void) willRemoveSubview:(UIView *)subview
{
	self.userInteractionEnabled = ([self.subviews count] > 1);
}


@end
