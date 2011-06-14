//
//  TitleScene.m
//  Yotsu Iro
//
//  Created by Nathan Demick on 5/25/11.
//  Copyright 2011 Ganbaru Games. All rights reserved.
//

#import "TitleScene.h"
#import "Block.h"
#import "HelloWorldScene.h"
#import "ScoreScene.h"

#import "CocosDenshion.h"
#import "SimpleAudioEngine.h"

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
		
		// Do one row, then have in each block's action a callback which adds another block, waits 
		//a random amount of time, then animates to position
		
		int rows = 13;
		int cols = 13;
		grid = [[NSMutableArray arrayWithCapacity:rows*cols] retain];
		
		// Drop a bunch of blocks onto the screen
		for (int i = 0; i < rows * cols; i++)
		{
			Block *b = [Block random];
			
			int x = i % cols;
			int y = floor(i / rows);
			
			// Set where the block should be
			[b setGridPosition:ccp(x, y)];
			[b snapToGridPosition];
			
			// Move the block higher by a random value (0 - 49)
			[b setPosition:ccp(b.position.x, b.position.y + windowSize.height + (float)(arc4random() % 100) / 100 * 50)];
			
			// Add to layer
			[self addChild:b];
			
			// Add to grid
			[grid addObject:b];
			
			// Animate the block moving back to position
			[b animateToGridPositionSlowly];
		}
		
		// Display the UI after 2 seconds
		[self runAction:[CCSequence actions:
						 [CCDelayTime actionWithDuration:2],
						 [CCCallFunc actionWithTarget:self selector:@selector(showUI)],
						 nil]];

	}
	
	return self;
}

- (void)showUI
{
	CGSize windowSize = [[CCDirector sharedDirector] winSize];
	
	CCSprite *logo = [CCSprite spriteWithFile:@"title-logo.png"];
	logo.position = ccp(windowSize.width / 2, windowSize.height - logo.contentSize.height / 1.5);
	[self addChild:logo z:3];
	
	CCMenuItemImage *startButton = [CCMenuItemImage itemFromNormalImage:@"play-button.png" selectedImage:@"play-button-selected.png" block:^(id sender) {
		[[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
		
		// Reload this scene
		CCTransitionFlipX *transition = [CCTransitionFlipX transitionWithDuration:0.5 scene:[HelloWorld node] orientation:kOrientationUpOver];
		[[CCDirector sharedDirector] replaceScene:transition];
	}];
	
	CCMenuItemImage *scoresButton = [CCMenuItemImage itemFromNormalImage:@"scores-button.png" selectedImage:@"scores-button-selected.png" block:^(id sender) {
		[[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
		
		// Go to score scene
		CCTransitionFlipX *transition = [CCTransitionFlipX transitionWithDuration:0.5 scene:[ScoreScene node] orientation:kOrientationUpOver];
		[[CCDirector sharedDirector] replaceScene:transition];
	}];
	
	CCMenu *titleMenu = [CCMenu menuWithItems:startButton, scoresButton, nil];
	[titleMenu alignItemsVerticallyWithPadding:10];
	[titleMenu setPosition:ccp(windowSize.width / 2, logo.position.y - titleMenu.contentSize.height / 2)];
	[self addChild:titleMenu z:3];
	
	
	CCLabelTTF *copyright = [CCLabelTTF labelWithString:@"© 2011 Ganbaru Games" fontName:@"Chalkduster.ttf" fontSize:16];
	copyright.color = ccc3(0, 0, 0);
	copyright.position = ccp(windowSize.width / 2, copyright.contentSize.height);
	[self addChild:copyright];
	
	//[self schedule:@selector(update:) interval:0.1];
	[self scheduleUpdate];
}

- (void)update:(ccTime)dt
{
	CGSize windowSize = [[CCDirector sharedDirector] winSize];
	
	for (Block *b in grid)
	{
		// Slowly move blocks to the right
		b.position = ccp(b.position.x + 0.1, b.position.y);
		
		// If too far to the right, have them circle around again
		if (b.position.x >= windowSize.width + b.contentSize.width * 1.5)
			b.position = ccp(-b.contentSize.width * 1.5 + 1, b.position.y);
	}
}

- (void)dealloc
{
	[grid release];
	
	[super dealloc];
}

@end
