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
}

// returns a Scene that contains the HelloWorld as the only child
+ (id)scene;

- (void)update:(ccTime)dt;
- (void)loseGame;

- (void)shiftLeft;
- (void)shiftRight;
- (void)shiftUp;
- (void)shiftDown;

- (void)resetBuffer;
- (void)matchCheck;

- (void)dropBlocks;
- (void)newBlockAtIndex:(int)index;
- (void)createParticlesAt:(CGPoint)position;

- (void)updateScore:(int)points;
- (void)comboCountdown;
- (void)removeNodeFromParent:(CCNode *)node;

@end
