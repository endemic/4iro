//
//  ScoreScene.m
//  Yotsu Iro
//
//  Created by Nathan Demick on 5/25/11.
//  Copyright 2011 Ganbaru Games. All rights reserved.
//

#import "ScoreScene.h"
#import "TitleScene.h"

#import "CocosDenshion.h"
#import "SimpleAudioEngine.h"

@implementation ScoreScene
+ (id)scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	ScoreScene *layer = [ScoreScene node];
	
	// add layer as a child to scene
	[scene addChild:layer];
	
	// return the scene
	return scene;
}

- (id)init
{
	if ((self = [super init]))
	{
		// Get window size
		CGSize windowSize = [CCDirector sharedDirector].winSize;
		
		CCSprite *bg = [CCSprite spriteWithFile:@"title-background.png"];
		[bg setPosition:ccp(windowSize.width / 2, windowSize.height / 2)];
		[self addChild:bg];
		
		// Get scores array stored in user defaults
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
		// Get high scores array from "defaults" object
		NSArray *highScores = [defaults arrayForKey:@"scores"];
		
		// Create title label
		CCLabelTTF *title = [CCLabelTTF labelWithString:@"high scores" fontName:@"FFF_Tusj.ttf" fontSize:40];
		[title setPosition:ccp(windowSize.width / 2, windowSize.height - title.contentSize.height)];
		[title setColor:ccc3(0, 0, 0)];
		[self addChild:title];
		
		// Create a mutable string which will be used to store the score list
		NSMutableString *scoresString = [NSMutableString stringWithString:@""];
		
		// Iterate through array and print out high scores
		for (int i = 0; i < [highScores count]; i++)
		{
			[scoresString appendFormat:@"%i. %i\n", i + 1, [[highScores objectAtIndex:i] intValue]];
		}
		
		// Create label that will display the scores - manually set the dimensions due to multi-line content
		CCLabelTTF *scoresLabel = [CCLabelTTF labelWithString:scoresString dimensions:CGSizeMake(windowSize.width, windowSize.height / 2) alignment:CCTextAlignmentCenter fontName:@"FFF_Tusj.ttf" fontSize:32];
		[scoresLabel setPosition:ccp(windowSize.width / 2, windowSize.height / 2)];
		[scoresLabel setColor:ccc3(0, 0, 0)];
		[self addChild:scoresLabel];
		
		// Create button that will take us back to the title screen
		CCMenuItemFont *backButton = [CCMenuItemFont itemFromString:@"back" target:self selector:@selector(backButtonAction)];
		
		// Create menu that contains our buttons
		CCMenu *menu = [CCMenu menuWithItems:backButton, nil];
		
		// Set position of menu to be below the scores
		[menu setPosition:ccp(windowSize.width / 2, backButton.contentSize.height)];
		[menu setColor:ccc3(0, 0, 0)];
		
		// Add menu to layer
		[self addChild:menu z:2];
	}
	
	return self;
}

- (void)backButtonAction
{
	[[SimpleAudioEngine sharedEngine] playEffect:@"button.wav"];
	
	CCTransitionFlipX *transition = [CCTransitionFlipX transitionWithDuration:0.5 scene:[TitleScene node] orientation:kOrientationUpOver];
	[[CCDirector sharedDirector] replaceScene:transition];
}
@end