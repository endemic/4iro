//
//  TitleScene.m
//  Yotsu Iro
//
//  Created by Nathan Demick on 5/25/11.
//  Copyright 2011 Ganbaru Games. All rights reserved.
//

#import "TitleScene.h"


@implementation TitleScene

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	TitleScene *layer = [TitleScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if ((self = [super init]))
	{
		// ask director the the window size
		CGSize windowSize = [[CCDirector sharedDirector] winSize];
		
		CCSprite *bg = [CCSprite spriteWithFile:@"Default.png"];
		[bg setPosition:ccp(windowSize.width / 2, windowSize.height / 2)];
		[self addChild:bg];
	}
	
	return self;
}

@end
