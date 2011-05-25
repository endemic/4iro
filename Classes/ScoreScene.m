//
//  ScoreScene.m
//  Yotsu Iro
//
//  Created by Nathan Demick on 5/25/11.
//  Copyright 2011 Ganbaru Games. All rights reserved.
//

#import "ScoreScene.h"
#import "TitleScene.h"

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
		
		// Get scores array stored in user defaults
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
		// Get high scores array from "defaults" object
		NSArray *highScores = [defaults arrayForKey:@"scores"];
		
		// Create title label
		CCLabelTTF *title = [CCLabelTTF labelWithString:@"high scores" fontName:@"Courier" fontSize:32.0];
		[title setPosition:ccp(windowSize.width / 2, windowSize.height - title.contentSize.height)];
		[self addChild:title];
		
		// Create a mutable string which will be used to store the score list
		NSMutableString *scoresString = [NSMutableString stringWithString:@""];
		
		// Iterate through array and print out high scores
		for (int i = 0; i < [highScores count]; i++)
		{
			[scoresString appendFormat:@"%i. %i\n", i + 1, [[highScores objectAtIndex:i] intValue]];
		}
		
		// Create label that will display the scores - manually set the dimensions due to multi-line content
		CCLabelTTF *scoresLabel = [CCLabelTTF labelWithString:scoresString dimensions:CGSizeMake(windowSize.width, windowSize.height / 3) alignment:CCTextAlignmentCenter fontName:@"Courier" fontSize:16.0];
		[scoresLabel setPosition:ccp(windowSize.width / 2, windowSize.height / 2)];
		[self addChild:scoresLabel];
		
		// Create button that will take us back to the title screen
		CCMenuItemFont *backButton = [CCMenuItemFont itemFromString:@"back" target:self selector:@selector(backButtonAction)];
		
		// Create menu that contains our buttons
		CCMenu *menu = [CCMenu menuWithItems:backButton, nil];
		
		// Set position of menu to be below the scores
		[menu setPosition:ccp(windowSize.width / 2, scoresLabel.position.y - scoresLabel.contentSize.height)];
		
		// Add menu to layer
		[self addChild:menu z:2];
	}
	
	return self;
}

- (void)backButtonAction
{
	NSLog(@"Switch to TitleScene");
	[[CCDirector sharedDirector] replaceScene:[TitleScene scene]];
}
@end