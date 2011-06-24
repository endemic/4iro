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
#import "GameConfig.h"

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
			fontMultiplier = 2;
		}
		else
		{
			hdSuffix = @"";
			fontMultiplier = 1;
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
		
		// Set default SFX volume to be a bit lower for the intro animation
		[[SimpleAudioEngine sharedEngine] setEffectsVolume:0.25];
		
		
		rows = 11;	// An extra row so there won't be a gap in animation
		cols = 12;
		lastRow = 0;
		
		grid = [[NSMutableArray arrayWithCapacity:rows * cols] retain];
		
		// First time the game is run in a session, do a intro animation
		// Create one row, then have in each block's action a callback which adds another block, waits 
		// a random amount of time, then animates to position
		if ([GameSingleton sharedGameSingleton].showIntroAnimation)
		{
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
				id ease = [CCEaseIn actionWithAction:move rate:2];
				id sfx = [CCCallBlock actionWithBlock:^{
					[[SimpleAudioEngine sharedEngine] playEffect:@"block-fall.caf"];
				}];
				id recursive = [CCCallFuncN actionWithTarget:self selector:@selector(dropNextBlockAfter:)];
				
				[b runAction:[CCSequence actions:ease, sfx, recursive, nil]];
			}
			
			// Set "showIntroAnimation" bool false so this animation doesn't repeat itself
			[GameSingleton sharedGameSingleton].showIntroAnimation = NO;
		}
		// Otherwise, create the background all at once
		else 
		{
			// Fill grid w/ blocks
			// Arrgh, + 1 to cols here due to using the "snapToGridPosition" method which puts first row below screen
			for (int y = 1; y < cols + 1; y++)
			{
				for (int x = 0; x < rows; x++)
				{
					Block *b = [Block random];
					
					// Move to correct location on screen
					[b setGridPosition:ccp(x, y)];
					[b snapToGridPosition];
					
					// Add to layer
					[self addChild:b];
					
					// Add to grid
					[grid addObject:b];
				}
			}
			
			// Call method which shows UI and schedules update method
			[self showUI];
		}
		
		// Create "scores" UI here, default position is off screen
		scoresNode = [CCNode node];
		scoresNode.contentSize = windowSize;
		scoresNode.position = ccp(0, -windowSize.height);
		[self addChild:scoresNode z:3];
		
		// Get scores array stored in user defaults
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
		// Get high scores array from "defaults" object
		NSArray *highScores = [defaults arrayForKey:@"scores"];
		
		// Create title label
		CCSprite *title = [CCSprite spriteWithFile:[NSString stringWithFormat:@"high-scores%@.png", hdSuffix]];
		title.position = ccp(windowSize.width / 2, windowSize.height - title.contentSize.height / 2);
		[scoresNode addChild:title];
		
		int defaultFontSize = 32;
		
		// Iterate through array and print out high scores
		for (int i = 0; i < [highScores count]; i++)
		{
			// Create labels that will display the scores
			CCLabelBMFont *label = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%i.%i\n", i + 1, [[highScores objectAtIndex:i] intValue]] 
														  fntFile:[NSString stringWithFormat:@"chalkduster-%i.fnt", defaultFontSize * fontMultiplier]];
			label.anchorPoint = ccp(0, 0.5); 
			label.position = ccp(windowSize.width / 2 - windowSize.width / 3, title.position.y - label.contentSize.height * (i + 2));
			[scoresNode addChild:label z:2];
		}
		
		// Create button that will take us back to the title screen
		CCMenuItemFont *backButton = [CCMenuItemImage itemFromNormalImage:@"back-button.png" selectedImage:@"back-button-selected.png" block:^(id sender) {
			[[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
			
			// Ease the default logo node down into view, replacing the scores node
			[scoresNode runAction:[CCEaseBackInOut actionWithAction:[CCMoveTo actionWithDuration:1.0 position:ccp(0, -windowSize.height)]]];
			[titleNode runAction:[CCEaseBackInOut actionWithAction:[CCMoveTo actionWithDuration:1.0 position:ccp(0, 0)]]];
		}];
		
		// Create menu that contains our buttons
		CCMenu *menu = [CCMenu menuWithItems:backButton, nil];
		
		// Set position of menu to be below the scores
		[menu setPosition:ccp(windowSize.width / 2, backButton.contentSize.height)];
		
		// Add menu to layer
		[scoresNode addChild:menu z:2];
		
	}	// End if ((self = [super init]))
	
	return self;
}

- (void)dropNextBlockAfter:(Block *)block
{	
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
	
	// A bunch of actions and crap
	id move = [CCMoveTo actionWithDuration:randomTime position:ccp(x * blockSize - blockSize / 2, y * blockSize + blockSize / 2)];
	id ease = [CCEaseIn actionWithAction:move rate:2];
	id recursive = [CCCallFuncN actionWithTarget:self selector:@selector(dropNextBlockAfter:)];
	id sfx = [CCCallBlock actionWithBlock:^{
		[[SimpleAudioEngine sharedEngine] playEffect:@"block-fall.caf"];
	}];
	id flash = [CCCallBlock actionWithBlock:^{
		[self flash];
		[self showUI];
	}];
	
	if (y < cols - 1)
	{
		// Column isn't full, so move the block down to its' place and run this method again
		[b runAction:[CCSequence actions:ease, sfx, recursive, nil]];
	}
	else
	{
		// Column is full. Move block to place and check whether the entire top row is full
		if (++lastRow == rows)
		{
			// If top row is full, show UI elements
			[b runAction:[CCSequence actions:ease, flash, nil]];
		}
		else 
		{
			[b runAction:[CCSequence actions:ease, sfx, nil]];
		}

	}
}

- (void)showUI
{
	CGSize windowSize = [[CCDirector sharedDirector] winSize];
	
	// Create a "container" node which allows us to ease logo/menu off the screen to replace w/ high scores
	titleNode = [CCNode node];
	titleNode.contentSize = windowSize;
	titleNode.position = ccp(0, 0);
	[self addChild:titleNode z:3];
	
	CCSprite *logo = [CCSprite spriteWithFile:@"title-logo.png"];
	logo.position = ccp(windowSize.width / 2, windowSize.height - logo.contentSize.height / 1.5);
	[titleNode addChild:logo z:3];
	
	CCMenuItemImage *startButton = [CCMenuItemImage itemFromNormalImage:@"play-button.png" selectedImage:@"play-button-selected.png" block:^(id sender) {
		[GameSingleton sharedGameSingleton].gameMode = kGameModeNormal;
		[[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
		
		// Go to game scene
		CCTransitionFlipX *transition = [CCTransitionFlipX transitionWithDuration:0.5 scene:[HelloWorld node] orientation:kOrientationUpOver];
		[[CCDirector sharedDirector] replaceScene:transition];
		
		// Transition this menu off screen, and move "Game Type" selector menu on
	}];
	
	CCMenuItemImage *scoresButton = [CCMenuItemImage itemFromNormalImage:@"scores-button.png" selectedImage:@"scores-button-selected.png" block:^(id sender) {
		[[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
		
		// Ease the scores node up into view, replacing the default logo, etc.
		[scoresNode runAction:[CCEaseBackInOut actionWithAction:[CCMoveTo actionWithDuration:1.0 position:ccp(0, 0)]]];
		[titleNode runAction:[CCEaseBackInOut actionWithAction:[CCMoveTo actionWithDuration:1.0 position:ccp(0, windowSize.height)]]];
	}];
	
	CCMenu *titleMenu = [CCMenu menuWithItems:startButton, scoresButton, nil];
	[titleMenu alignItemsVerticallyWithPadding:10];
	[titleMenu setPosition:ccp(windowSize.width / 2, logo.position.y - titleMenu.contentSize.height / 2.5)];
	[titleNode addChild:titleMenu z:3];
	
	int defaultFontSize = 16;
	CCLabelBMFont *copyright = [CCLabelBMFont labelWithString:@"© 2011 Ganbaru Games" 
													  fntFile:[NSString stringWithFormat:@"chalkduster-%i.fnt", defaultFontSize * fontMultiplier]];
	
	//CCLabelTTF *copyright = [CCLabelTTF labelWithString:@"© 2011 Ganbaru Games" fontName:@"Chalkduster.ttf" fontSize:16];
	copyright.position = ccp(windowSize.width / 2, copyright.contentSize.height * 0.75);
	[titleNode addChild:copyright];
	
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
	
	// Reset SFX volume back to normals
	[[SimpleAudioEngine sharedEngine] setEffectsVolume:1.0];
	
	[[SimpleAudioEngine sharedEngine] playEffect:@"explode.caf"];
}

- (void)removeNodeFromParent:(CCNode *)node
{
	[node.parent removeChild:node cleanup:YES];
}

- (void)dealloc
{
	[grid release];
	
	[super dealloc];
}

@end
