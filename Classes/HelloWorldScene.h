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
	int rows, cols, blockSize, gridOffset;
	
	// Variables for user interaction
	int touchRow, touchCol;
	CGPoint touchStart, touchPrevious;
	BOOL horizontalMove, verticalMove;
}

// returns a Scene that contains the HelloWorld as the only child
+ (id)scene;

- (void)shiftLeft;
- (void)shiftRight;
- (void)shiftUp;
- (void)shiftDown;
- (void)resetBuffer;
- (void)matchCheck;

@end
