//
//  GameSingleton.h
//  Yotsu Iro
//
//  Created by Nathan Demick on 6/11/11.
//  Copyright 2011 Ganbaru Games. All rights reserved.
//

// Serializes certain game variables on exit then restores them on game load
// Taken from http://stackoverflow.com/questions/2670815/game-state-singleton-cocos2d-initwithencoder-always-returns-null

#import "cocos2d.h"
#import "SynthesizeSingleton.h"
#import <GameKit/GameKit.h>

@interface GameSingleton : NSObject <NSCoding, GKLeaderboardViewControllerDelegate> 
{
	// Boolean that's set to "true" if game is running on iPad!
	bool isPad;
	
	// Variable we check to see if player quit in the middle of a level
	bool restoreLevel;
	
	// Info about the current play session
	int points, combo, level;	
	float timeRemaining, timePlayed;
	
	// Game Center properties
	BOOL hasGameCenter;
	NSMutableArray *unsentScores;
	UIViewController *myViewController;
}

@property (nonatomic) bool isPad;
@property (nonatomic) bool restoreGame;

@property (readwrite, nonatomic) int points;
@property (readwrite, nonatomic) int combo;
@property (readwrite, nonatomic) int level;

@property (readwrite, nonatomic) float timeRemaining;
@property (readwrite, nonatomic) float timePlayed;

@property (readwrite) BOOL hasGameCenter;
@property (readwrite, retain) NSMutableArray *unsentScores;

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(GameSingleton);

// Game Center methods
- (BOOL)isGameCenterAPIAvailable;
- (void)authenticateLocalPlayer;
- (void)reportScore:(int64_t)score forCategory:(NSString *)category;
- (void)showLeaderboardForCategory:(NSString *)category;
- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController;

// Serialization methods
+ (void)loadState;
+ (void)saveState;

@end
