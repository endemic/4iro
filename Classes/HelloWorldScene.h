//
//  HelloWorldLayer.h
//  Yotsu Iro
//
//  Created by Nathan Demick on 4/13/11.
//  Copyright Ganbaru Games 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorld Layer
@interface HelloWorld : CCLayer
{
	// Array which stores references to puzzle objects
	NSMutableArray *grid;
	
	// References to size of the playing grid
	int rows, cols, blockSize, gridOffset, visibleRows, visibleCols;
	
	// Variables for user interaction
	int touchRow, touchCol;
	CGPoint touchStart, touchPrevious;
	BOOL horizontalMove, verticalMove;
	
	// Various display bits
	int score, combo, level;
	CCLabelTTF *scoreLabel;
	CCLabelTTF *comboLabel;
	CCLabelTTF *levelLabel;
	
	float timeRemaining;						// Say a maximum of 30 seconds
	float timePlayed;							// Records how long the player has been playing
	CCProgressTimer *timeRemainingDisplay;		// kCCProgressTimerTypeVerticalBarBT
	
	// String to be appended to sprite filenames if required to use a high-rez file (e.g. iPhone 4 assests on iPad)
	NSString *hdSuffix;
	int fontMultiplier;
}

// returns a Scene that contains the HelloWorld as the only child
+ (id)scene;

- (void)update:(ccTime)dt;
- (void)gameOver;

- (void)shiftLeft;
- (void)shiftRight;
- (void)shiftUp;
- (void)shiftDown;

- (void)resetBuffer;
- (void)matchCheck;

- (void)dropBlocks;
- (void)newBlockAtIndex:(int)index;
- (void)createParticlesAt:(CGPoint)position;
- (void)createStatusMessageAt:(CGPoint)position withText:(NSString *)text;
- (void)flash;

- (void)updateTime;
- (void)updateScore:(int)points;
- (void)comboCountdown;
- (void)updateCombo;
- (void)removeNodeFromParent:(CCNode *)node;

@end
