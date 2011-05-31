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
	
		CCSprite *bg = [CCSprite spriteWithFile:@"title-background.png"];
		[bg setPosition:ccp(windowSize.width / 2, windowSize.height / 2)];
		[self addChild:bg];
		
		// Do one row, then have in each block's action a callback which adds another block, waits a random amount of time, then animates to position
		
//		int rows = 12;
//		int cols = 8;
//		
//		// Drop a bunch of blocks onto the screen
//		for (int i = 0; i < 96; i++)
//		{
//			Block *b = [Block random];
//			
//			int x = i % cols;
//			int y = floor(i / rows);
//			
//			// Set where the block should be
//			[b setGridPosition:ccp(x, y)];
//			[b snapToGridPosition];
//			
//			// Move the block higher by a random value (0 - 49)
//			[b setPosition:ccp(b.position.x, b.position.y + windowSize.height + (float)(arc4random() % 100) / 100 * 50)];
//			
//			// Add to layer
//			[self addChild:b];
//			
//			// Animate the block moving back to position
//			[b animateToGridPosition];
//		}
		

		// Game logo/name
		CCLabelTTF *titleLabel = [CCLabelTTF labelWithString:@"COLOR\n+\nSHAPE" dimensions:CGSizeMake(windowSize.width, windowSize.height / 3) alignment:CCTextAlignmentCenter fontName:@"Chunkfive.otf" fontSize:48];
		[titleLabel setPosition:ccp(windowSize.width / 2, windowSize.height - titleLabel.contentSize.height)];
		[titleLabel setColor:ccc3(0, 0, 0)];
		[self addChild:titleLabel z:3];
		
		// Specify font details
		[CCMenuItemFont setFontSize:32];
		[CCMenuItemFont setFontName:@"Chunkfive.otf"];
		
		CCMenuItemFont *startButton = [CCMenuItemFont itemFromString:@"Start" block:^(id sender) {
			[[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
			
			// Reload this scene
			CCTransitionFlipX *transition = [CCTransitionFlipX transitionWithDuration:0.5 scene:[HelloWorld node] orientation:kOrientationUpOver];
			[[CCDirector sharedDirector] replaceScene:transition];
		}];
		
		CCMenuItemFont *scoresButton = [CCMenuItemFont itemFromString:@"High Scores" block:^(id sender) {
			[[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
			
			// Go to score scene
			CCTransitionFlipX *transition = [CCTransitionFlipX transitionWithDuration:0.5 scene:[ScoreScene node] orientation:kOrientationUpOver];
			[[CCDirector sharedDirector] replaceScene:transition];
		}];
		
		CCMenu *titleMenu = [CCMenu menuWithItems:startButton, scoresButton, nil];
		[titleMenu alignItemsVerticallyWithPadding:20];
		[titleMenu setColor:ccc3(0, 0, 0)];
		[titleMenu setPosition:ccp(windowSize.width / 2, titleLabel.position.y - titleMenu.contentSize.height / 2)];
		[self addChild:titleMenu z:3];
		
	}
	
	return self;
}

@end
