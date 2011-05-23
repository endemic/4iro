//
//  Block.m
//  Yotsu Iro
//
//  Created by Nathan Demick on 5/9/11.
//  Copyright 2011 Ganbaru Games. All rights reserved.
//

#import "Block.h"


@implementation Block

@synthesize colour, shape;

// The init method we have to override - http://www.cocos2d-iphone.org/wiki/doku.php/prog_guide:sprites (bottom of page)
- (id)initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
	// Call the init method of the parent class (CCSprite)
	if ((self = [super initWithTexture:texture rect:rect]))
	{
		// The only custom stuff here is scheduling an update method
		//[self scheduleUpdate];
	}
	return self;
}

@end
