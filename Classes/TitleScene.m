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

#import "GameSingleton.h"

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
	
		// This string gets appended onto all image filenames based on whether the game is on iPad or not
		if ([GameSingleton sharedGameSingleton].isPad)
		{
			hdSuffix = @"-hd";
			fontMultiplier = 1;
		}
		else
		{
			hdSuffix = @"";
			fontMultiplier = 2;
		}
		
		CCSprite *bg = [CCSprite spriteWithFile:@"Default.png"];
		[bg setPosition:ccp(windowSize.width / 2, windowSize.height / 2)];
		[self addChild:bg];
		
		// Load UI graphics into texture cache
		[[CCTextureCache sharedTextureCache] addImage:@"title-logo.png"];
		[[CCTextureCache sharedTextureCache] addImage:@"play-button.png"];
		[[CCTextureCache sharedTextureCache] addImage:@"scores-button.png"];
		[[CCTextureCache sharedTextureCache] addImage:@"play-button-selected.png"];
		[[CCTextureCache sharedTextureCache] addImage:@"scores-button-selected.png"];
		
		// Do one row, then have in each block's action a callback which adds another block, waits 
		//a random amount of time, then animates to position
		
		int rows = 11;	// An extra row so there won't be a gap in animation
		int cols = 12;
		lastRow = 0;
		
		grid = [[NSMutableArray arrayWithCapacity:rows * cols] retain];

		// Drop a bunch of blocks onto the screen
		for (int x = 0; x < rows; x++)
		{
			int y = 0;
			Block *b = [Block random];
			
			[b setGridPosition:ccp(x, y)];
			[b snapToGridPosition];
			
			// Move the block higher by a random value (0 - 49)
			[b setPosition:ccp(b.position.x, b.position.y + windowSize.height + (float)(arc4random() % 100) / 100 * 50)];
			
			// Add to layer
			[self addChild:b];
			
			// Add to grid
			[grid addObject:b];
			
			int blockSize = b.contentSize.width;
			float randomTime = (float)(arc4random() % 40) / 100 + 0.25;
			
			id move = [CCMoveTo actionWithDuration:randomTime position:ccp(x * blockSize - blockSize / 2, y * blockSize + blockSize / 2)];
			id recursive = [CCCallFuncN actionWithTarget:self selector:@selector(dropNextBlockAfter:)];
			
			[b runAction:[CCSequence actions:move, recursive, nil]];
		}
	}
	
	return self;
}

- (void)dropNextBlockAfter:(Block *)block
{	
	int rows = 11;
	int cols = 12;

	CGSize windowSize = [[CCDirector sharedDirector] winSize];
	
	Block *b = [Block random];
	
	int x = block.gridPosition.x;
	int y = block.gridPosition.y + 1;

	// Set where the block should be
	[b setGridPosition:ccp(x, y)];
	[b snapToGridPosition];
	
	// Move the block higher by a random value (0 - 49)
	[b setPosition:ccp(b.position.x, b.position.y + windowSize.height + (float)(arc4random() % 100) / 100 * 50)];
	
	// Add to layer
	[self addChild:b];
	
	// Add to grid
	[grid addObject:b];
	
	int blockSize = b.contentSize.width;
	float randomTime = (float)(arc4random() % 40) / 100 + 0.25;
	
	id move = [CCMoveTo actionWithDuration:randomTime position:ccp(x * blockSize - blockSize / 2, y * blockSize + blockSize / 2)];
	id recursive = [CCCallFuncN actionWithTarget:self selector:@selector(dropNextBlockAfter:)];
	
	if (y < cols)
	{
		// Column isn't full, so move the block down to its' place and run this method again
		[b runAction:[CCSequence actions:move, recursive, nil]];
	}
	else
	{
		// Column is full. Move block to place and check whether the entire top row is full
		// If top row is full, show UI elements
		[b runAction:move];
		
		lastRow++;
		
		if (lastRow == rows)
		{
			[self flash];
			[self showUI];
		}
	}
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
	[titleMenu setPosition:ccp(windowSize.width / 2, logo.position.y - titleMenu.contentSize.height / 2.5)];
	[self addChild:titleMenu z:3];
	
	CCLabelTTF *copyright = [CCLabelTTF labelWithString:@"© 2011 Ganbaru Games" fontName:@"Chalkduster.ttf" fontSize:16];
	copyright.color = ccc3(0, 0, 0);
	copyright.position = ccp(windowSize.width / 2, copyright.contentSize.height * 0.75);
	[self addChild:copyright];
	
	[self scheduleUpdate];
}

- (void)update:(ccTime)dt
{
	CGSize windowSize = [[CCDirector sharedDirector] winSize];

	for (Block *b in grid)
	{
		// Slowly move blocks to the right
		b.position = ccp(b.position.x + 1, b.position.y);
		
		// If too far to the right, have them circle around again
		if (b.position.x >= windowSize.width + b.contentSize.width * 1.5)
			b.position = ccp(-b.contentSize.width * 1.5 + 1, b.position.y);
	}
}

- (void)flash
{
	// ask director the the window size
	CGSize windowSize = [[CCDirector sharedDirector] winSize];
	
	CCSprite *bg = [CCSprite spriteWithFile:[NSString stringWithFormat:@"flash%@.png", hdSuffix]];
	bg.position = ccp(windowSize.width / 2, windowSize.height / 2);
	[self addChild:bg z:10];
	
	[bg runAction:[CCSequence actions:
				   [CCFadeOut actionWithDuration:1.0],
				   [CCCallFuncN actionWithTarget:self selector:@selector(removeNodeFromParent:)],
				   nil]];
}

- (void)removeNodeFromParent:(CCNode *)node
{
	//[sprite.parent removeChild:sprite cleanup:YES];
	
	// Trying this from forum post http://www.cocos2d-iphone.org/forum/topic/981#post-5895
	// Apparently fixes a memory error?
	CCNode *parent = node.parent;
	[node retain];
	[parent removeChild:node cleanup:YES];
	[node autorelease];
}

- (void)dealloc
{
	[grid release];
	
	[super dealloc];
}

@end
