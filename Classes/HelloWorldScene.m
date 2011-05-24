//
//  HelloWorldLayer.m
//  Yotsu Iro
//
//  Created by Nathan Demick on 4/13/11.
//  Copyright Ganbaru Games 2011. All rights reserved.
//
// Other name ideas: 4iro, fouriro, shiirow
// Import the interfaces
#import "HelloWorldScene.h"
#import "Block.h"

// HelloWorld implementation
@implementation HelloWorld

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorld *layer = [HelloWorld node];
	
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
		
		// Add background for game status area
		CCSprite *bg = [CCSprite spriteWithFile:@"top-background.png"];
		[bg setPosition:ccp(windowSize.width / 2, windowSize.height - bg.contentSize.height / 2)];
		[self addChild:bg z:2];
		
		[self setIsTouchEnabled:YES];
		
		// Set up score int/label
		score = 0;
		scoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%i", score] fontName:@"FFF_Tusj.ttf" fontSize:32];
		[scoreLabel setPosition:ccp(windowSize.width / 2, windowSize.height - scoreLabel.contentSize.height)];
		[self addChild:scoreLabel z:3];
		
		rows = 10;
		cols = 10;
		gridOffset = 1;
		
//		int visibleRows = rows - gridOffset * 2;
//		int visibleCols = cols - gridOffset * 2;

//		rows = 8;
//		cols = 8;
//		gridOffset = 0;
		
		blockSize = 40;
		
		// Array w/ 100 spaces - 10x10
		int gridCapacity = rows * cols;
		grid = [[NSMutableArray arrayWithCapacity:gridCapacity] retain];
		
		// array[x + y*size] === array[x][y]
		for (int i = 0; i < gridCapacity; i++)
			[self newBlockAtIndex:i];
		
		// Reset the "buffer" blocks hidden around the outside of the screen
		[self resetBuffer];
	}
	return self;
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	// Determine touched row/column and store starting touch point
	UITouch *touch = [touches anyObject];
	
	CGPoint touchPoint = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
	
	touchStart = touchPrevious = touchPoint;
	horizontalMove = verticalMove = NO;
	
	touchRow = touchPoint.y / blockSize + gridOffset;
	touchCol = touchPoint.x / blockSize + gridOffset;
	
//	NSMutableString *tmp = [NSMutableString stringWithString:@""];
//	for (int i = touchRow * rows; i < touchRow * rows + cols; i++)	// Check row values
//	//for (int i = touchCol; i < rows * cols; i += cols)					// Check column values
//		[tmp appendFormat:@"%i ", [[grid objectAtIndex:i] number]];
//	NSLog(tmp);
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	// Determine the row/column that is touched
	// Determine whether movement is vertical or horizontal
	UITouch *touch = [touches anyObject];
	
	CGPoint touchPoint = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
	CGPoint touchDiff = ccp(touchPoint.x - touchPrevious.x, touchPoint.y - touchPrevious.y);
	
	// Determine whether the movement is horiz/vert
	if (!horizontalMove && !verticalMove)
	{
		if (fabs(touchPoint.x - touchStart.x) > fabs(touchPoint.y - touchStart.y))
			horizontalMove = YES;
		else
			verticalMove = YES;
	}
	
	/*
	Movement gets screwed up when the player's finger moves more than 40px per frame. That's what is causing movement to "jump"
	 */
	
	if (horizontalMove)
	{
		// Move each block in the row based on the difference on the x-axis
		int touchDiffX = touchDiff.x;
		for (int i = 0; i < cols; i++)
		{
			Block *s = [grid objectAtIndex:touchRow * cols + i];
			[s setPosition:ccp(s.position.x + touchDiffX % blockSize, s.position.y)];
			//[s setPosition:ccp(s.position.x + touchDiffX, s.position.y)];
		}
		
		int d = touchStart.x - touchPoint.x;
		//NSLog(@"%f - %f = %i", touchStart.x, touchPoint.x, d);
		if (d >= blockSize)
		{
			// Handle very fast movement
			for (int i = 0; i < floor(d / blockSize); i++)
				[self shiftLeft];
	
			// Reset the "start" position
			touchStart = touchPoint;
		}
		else if (d <= -blockSize)
		{
			for (int i = 0; i > floor(d / blockSize); i--)
				[self shiftRight];
			
			// Reset the "start" position
			touchStart = touchPoint;
		}
	}
	else if (verticalMove)
	{
		// Move each block in the row based on the difference on the y-axis
		int touchDiffY = touchDiff.y;
		for (int i = 0; i < cols; i++)
		{
			CCSprite *s = [grid objectAtIndex:touchCol + cols * i];
			[s setPosition:ccp(s.position.x, s.position.y + touchDiffY % blockSize)];
		}
		
		int d = touchStart.y - touchPoint.y;
		if (d >= blockSize)
		{
			for (int i = 0; i < floor(d / blockSize); i++)
				[self shiftDown];
			
			// Reset the "start" position
			touchStart = touchPoint;
		}
		else if (d <= -blockSize)
		{
			for (int i = 0; i > floor(d / blockSize); i--)
				[self shiftUp];
			
			// Reset the "start" position
			touchStart = touchPoint;
		}
	}
	
	touchPrevious = touchPoint;
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	// Initiate action to snap row/column back to nearest grid position
	UITouch *touch = [touches anyObject];
	
	CGPoint touchPoint = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
	CGPoint touchDiff = ccp(touchPoint.x - touchStart.x, touchPoint.y - touchStart.y);
	
	if (horizontalMove)
	{
		// Move back to original position
		if (touchDiff.x <= blockSize / 2 && touchDiff.x >= -blockSize / 2)
		{
			//NSLog(@"touchDiff: %f, snap: %f", touchDiff.x, -touchDiff.x);
			
			for (int i = touchRow * rows; i < touchRow * rows + cols; i++)
			{
				Block *s = [grid objectAtIndex:i];
				//id action = [CCEaseInOut actionWithAction:[CCMoveBy actionWithDuration:0.2 position:ccp(-touchDiff.x, 0)] rate:0.2];
				id action = [CCMoveTo actionWithDuration:0.2 position:ccp(blockSize * (i % rows) - blockSize / 2, s.position.y)];
				[s runAction:action];
			}
		}
		// Shift either left or right
		else if (touchDiff.x < -blockSize / 2)
		{
			//NSLog(@"touchDiff: %f, snap: %f", touchDiff.x, -(blockSize + touchDiff.x));
			
			// Shift grid
			[self shiftLeft];
			
			// Need to move last sprite in array row to its' correct display position
			Block *last = [grid objectAtIndex:touchRow * rows + (cols - 1)];
			Block *secondToLast = [grid objectAtIndex:touchRow * rows + (cols - 2)];
			[last setPosition:ccp(secondToLast.position.x + blockSize, secondToLast.position.y)];
			
			// Animate the entire row to snap back to position
			for (int i = touchRow * rows; i < touchRow * rows + cols; i++)
			{
				Block *s = [grid objectAtIndex:i];
				id action = [CCMoveTo actionWithDuration:0.2 position:ccp(blockSize * (i % rows) - blockSize / 2, s.position.y)];
				[s runAction:action];
			}
		}
		else if (touchDiff.x > blockSize / 2)
		{
			//NSLog(@"touchDiff: %f, snap: %f", touchDiff.x, blockSize - touchDiff.x);
			
			// Shift grid
			[self shiftRight];
			
			// Need to move first sprite in array row to its' correct display position
			Block *first = [grid objectAtIndex:touchRow * rows];
			Block *second = [grid objectAtIndex:touchRow * rows + 1];
			[first setPosition:ccp(second.position.x - blockSize, second.position.y)];
			
			// Animate the entire row to snap back to position
			for (int i = touchRow * rows; i < touchRow * rows + cols; i++)
			{
				Block *s = [grid objectAtIndex:i];
				id action = [CCMoveTo actionWithDuration:0.2 position:ccp(blockSize * (i % rows) - blockSize / 2, s.position.y)];
				[s runAction:action];
			}			
		}
	}
	else if (verticalMove)
	{
		// Move back to original position
		if (touchDiff.y <= blockSize / 2 && touchDiff.y >= -blockSize / 2)
		{
			for (int i = touchCol; i < rows * cols; i += cols)
			{
				Block *s = [grid objectAtIndex:i];
				id action = [CCMoveTo actionWithDuration:0.2 position:ccp(s.position.x, blockSize * (i / cols) - blockSize / 2)];
				[s runAction:action];
			}
		}
		// Shift either up or down
		else if (touchDiff.y < -blockSize / 2)
		{
			// Shift down
			[self shiftDown];
			
			// Need to move last sprite in array column to its' correct display position
			Block *last = [grid objectAtIndex:touchCol + (cols - 1) * cols];
			Block *secondToLast = [grid objectAtIndex:touchCol + (cols - 2) * cols];
			[last setPosition:ccp(secondToLast.position.x, secondToLast.position.y + blockSize)];
			
			// Animate the entire column to snap back to position
			for (int i = touchCol; i < rows * cols; i += cols)
			{
				Block *s = [grid objectAtIndex:i];
				id action = [CCMoveTo actionWithDuration:0.2 position:ccp(s.position.x, blockSize * (i / cols) - blockSize / 2)];
				[s runAction:action];
			}
		}
		else if (touchDiff.y > blockSize / 2)
		{
			// Shift up
			[self shiftUp];
			
			// Need to move first sprite in array column to its' correct display position
			Block *first = [grid objectAtIndex:touchCol];
			Block *second = [grid objectAtIndex:touchCol + cols];
			[first setPosition:ccp(second.position.x, second.position.y - blockSize)];
			
			// Animate the entire column to snap back to position
			for (int i = touchCol; i < rows * cols; i += cols)
			{
				Block *s = [grid objectAtIndex:i];
				id action = [CCMoveTo actionWithDuration:0.2 position:ccp(s.position.x, blockSize * (i / cols) - blockSize / 2)];
				[s runAction:action];
			}
		}
	}
	
	[self matchCheck];
}

- (void)shiftLeft
{
	// Store first value
	Block *tmp = [grid objectAtIndex:touchRow * rows];
	
	// Cycle through the rest of the blocks in a row
	for (int i = touchRow * rows; i < touchRow * rows + (cols - 1); i++)
	{
		// Shift left
		[grid replaceObjectAtIndex:i withObject:[grid objectAtIndex:i + 1]];
		
		// Update index of Block obj
	}
	
	// Move stored sprite to appropriate (x,y) location
	Block *secondToLastBlock = [grid objectAtIndex:touchRow * rows + (cols - 1)];
	[tmp setPosition:ccp(secondToLastBlock.position.x + blockSize, secondToLastBlock.position.y)];
	
	// Place first value at end of array row
	[grid replaceObjectAtIndex:touchRow * rows + (cols - 1) withObject:tmp];
	
	[self resetBuffer];
	
	//NSLog(@"Shift left");
}

- (void)shiftRight
{
	// Store last value
	Block *tmp = [grid objectAtIndex:touchRow * rows + (cols - 1)];
	
	// Shift right
	for (int i = touchRow * rows + (cols - 1); i > touchRow * rows; i--)
		[grid replaceObjectAtIndex:i withObject:[grid objectAtIndex:i - 1]];
	
	// Move sprite to appropriate (x,y) location
	Block *secondBlock = [grid objectAtIndex:touchRow * rows + 1];
	[tmp setPosition:ccp(secondBlock.position.x - blockSize, secondBlock.position.y)];
	
	// Place last value in front of array row
	[grid replaceObjectAtIndex:touchRow * rows withObject:tmp];
	
	[self resetBuffer];
	
	//NSLog(@"Shift right");
}

- (void)shiftUp
{
	// Store last value
	Block *tmp = [grid objectAtIndex:touchCol + rows * (cols - 1)];
	
	// Shift up
	for (int i = touchCol + rows * (cols - 1); i > touchCol; i -= cols)
		[grid replaceObjectAtIndex:i withObject:[grid objectAtIndex:i - cols]];
	
	// Move sprite to appropriate (x,y) location
	Block *secondBlock = [grid objectAtIndex:touchCol + cols];
	[tmp setPosition:ccp(secondBlock.position.x, secondBlock.position.y - blockSize)];
	
	// Place last value in front of array row
	[grid replaceObjectAtIndex:touchCol withObject:tmp];
	
	[self resetBuffer];
	
	//NSLog(@"Shift up");
}

- (void)shiftDown
{
	// Store first value
	Block *tmp = [grid objectAtIndex:touchCol];
	
	// Shift down
	for (int i = touchCol; i < touchCol + rows * (cols - 1); i += cols)
		[grid replaceObjectAtIndex:i withObject:[grid objectAtIndex:i + cols]];
	
	// Move sprite to appropriate (x,y) location
	Block *secondBlock = [grid objectAtIndex:touchCol + rows * (cols - 2)];
	[tmp setPosition:ccp(secondBlock.position.x, secondBlock.position.y + blockSize)];
	
	// Place first value at end of array row
	[grid replaceObjectAtIndex:touchCol + rows * (cols - 1) withObject:tmp];
	
	[self resetBuffer];
	
	//NSLog(@"Shift down");
}

- (void)resetBuffer
{
	// Bottom
	for (int i = 1; i < rows - 1; i++)
	{
		Block *source = [grid objectAtIndex:(rows * (cols - 2)) + i];
		Block *destination = [grid objectAtIndex:i];
		destination.colour = source.colour;
		destination.shape = source.shape;
		destination.texture = source.texture;
	}
	
	// Put blocks from first visible row (bottom) into top offscreen buffer
	for (int i = 1; i < rows - 1; i++)
	{
		Block *source = [grid objectAtIndex:rows + i];
		Block *destination = [grid objectAtIndex:(rows * (cols - 1)) + i];
		destination.colour = source.colour;
		destination.shape = source.shape;
		destination.texture = source.texture;
	}
	
	// Left
	for (int i = 1; i < cols - 1; i++)
	{
		Block *source = [grid objectAtIndex:i * rows + (cols - 2)];
		Block *destination = [grid objectAtIndex:i * rows];
		destination.colour = source.colour;
		destination.shape = source.shape;
		destination.texture = source.texture;
	}
	
	// Right
	for (int i = 1; i < cols - 1; i++)
	{
		Block *source = [grid objectAtIndex:i * rows + 1];
		Block *destination = [grid objectAtIndex:i * rows + (cols - 1)];
		destination.colour = source.colour;
		destination.shape = source.shape;
		destination.texture = source.texture;
		
		//NSLog(@"Source: %i, desintation: %i", i * rows + 1, i * rows + (cols - 1));
	}
}

- (void)matchCheck
{
	// Go thru and check for matching colors/shapes - first horizontally, then vertically
	// Only go through indices 1 - 8
	// Test out horizontal first - color
	
	NSMutableArray *colorArray = [NSMutableArray arrayWithCapacity:8];
	NSMutableArray *shapeArray = [NSMutableArray arrayWithCapacity:8];
	NSMutableArray *removeArray = [NSMutableArray arrayWithCapacity:16];	// Arbitrary capacity
	NSMutableString *previousColor = [NSMutableString stringWithString:@""];
	NSMutableString *previousShape = [NSMutableString stringWithString:@""];
	
	int minimumMatchCount = 4;		// Number of adjacent blocks needed to disappear
	Block *b;
	
	// Find horizontal matches
	for (int i = gridOffset; i < rows - gridOffset; i++)
	{
		// for each block in row
		for (int j = i * rows + gridOffset; j < i * rows + cols - gridOffset; j++)
		{
			b = [grid objectAtIndex:j];
			
			// Condition in order to add the first block to the "set"
			if (j == i * rows + gridOffset)
			{
				[previousColor setString:b.colour];
				[previousShape setString:b.shape];
			}
			
			// Check color
			if ([b.colour isEqualToString:previousColor])
			{
				[colorArray addObject:[NSNumber numberWithInt:j]];
			}
			else
			{
				// If the set array has enough objects, add them to the "removal" array
				if ([colorArray count] >= minimumMatchCount)
					[removeArray addObjectsFromArray:colorArray];
					
				// Reset the set
				[colorArray removeAllObjects];
				
				// Add current block
				[colorArray addObject:[NSNumber numberWithInt:j]];
			}
			
			// Check shape
			if ([b.shape isEqualToString:previousShape])
			{
				[shapeArray addObject:[NSNumber numberWithInt:j]];
			}
			else
			{
				// If the set array has enough objects, add them to the "removal" array
				if ([shapeArray count] >= minimumMatchCount)
					[removeArray addObjectsFromArray:shapeArray];
					
				// Reset the set
				[shapeArray removeAllObjects];
				
				// Add current block
				[shapeArray addObject:[NSNumber numberWithInt:j]];
			}
			
			// reset the previous color comparison
			[previousColor setString:b.colour];
			
			// reset the previous shape comparison
			[previousShape setString:b.shape];
			
		}	// End col for loop
		
		// Do another check here at the end of the row for both shape & color
		if ([shapeArray count] >= minimumMatchCount)
			[removeArray addObjectsFromArray:shapeArray];
		
		if ([colorArray count] >= minimumMatchCount)
			[removeArray addObjectsFromArray:colorArray];
		
		// Remove all blocks in matching arrays at the end of a row
		[shapeArray removeAllObjects];
		[colorArray removeAllObjects];
	}	// End row for loop
	
	// Find vertical matches
	for (int i = gridOffset; i < cols - gridOffset; i++)
	{
		// For each block in column
		for (int j = i + rows; j < rows * (cols - gridOffset) + i; j += rows)
		{
			b = [grid objectAtIndex:j];
			
			// Condition in order to add the first block to the "set"
			if (j == i + rows)
			{
				[previousColor setString:b.colour];
				[previousShape setString:b.shape];
			}
			
			// Check color
			if ([b.colour isEqualToString:previousColor])
			{
				[colorArray addObject:[NSNumber numberWithInt:j]];
			}
			else
			{
				// If the set array has enough objects, add them to the "removal" array
				if ([colorArray count] >= minimumMatchCount)
					[removeArray addObjectsFromArray:colorArray];
				
				// Reset the set
				[colorArray removeAllObjects];
				
				// Add current block
				[colorArray addObject:[NSNumber numberWithInt:j]];
			}
			
			// Check shape
			if ([b.shape isEqualToString:previousShape])
			{
				[shapeArray addObject:[NSNumber numberWithInt:j]];
			}
			else
			{
				// If the set array has enough objects, add them to the "removal" array
				if ([shapeArray count] >= minimumMatchCount)
					[removeArray addObjectsFromArray:shapeArray];
				
				// Reset the set
				[shapeArray removeAllObjects];
				
				// Add current block
				[shapeArray addObject:[NSNumber numberWithInt:j]];
			}
			
			// reset the previous color comparison
			[previousColor setString:b.colour];
			
			// reset the previous shape comparison
			[previousShape setString:b.shape];
		}	// End of each block in column
		
		// Do another check here at the end of the row for both shape & color
		if ([shapeArray count] >= minimumMatchCount)
			[removeArray addObjectsFromArray:shapeArray];
		
		if ([colorArray count] >= minimumMatchCount)
			[removeArray addObjectsFromArray:colorArray];
		
		// Remove all blocks in matching arrays at the end of a column
		[shapeArray removeAllObjects];
		[colorArray removeAllObjects];
	}

	// Remove all blocks with indices in removeArray
	for (int i = 0, j = [removeArray count]; i < j; i++)
	{
		int gridIndex = [[removeArray objectAtIndex:i] intValue];
		Block *remove = [grid objectAtIndex:gridIndex];
		
		if (remove)
		{
			[self createParticlesAt:remove.position];
			[self removeChild:remove cleanup:YES];
			[self newBlockAtIndex:gridIndex];
			
			// Do some sort of effect here to show which blocks matched
			//[remove flash];
			
			[self updateScore:10];
		}
	}
	
	// Finally, clear out the removeSet array
	[removeArray removeAllObjects];
}

- (void)newBlockAtIndex:(int)index
{
	int randomColorNumber = (float)(arc4random() % 100) / 100 * 4;
	int randomShapeNumber = (float)(arc4random() % 100) / 100 * 4;
	NSString *color;
	NSString *shape;
	
	switch (randomColorNumber)
	{
		case 0: color = @"red"; break;
		case 1: color = @"green"; break;
		case 2: color = @"blue"; break;
		case 3: color = @"yellow"; break;
	}
	
	switch (randomShapeNumber)
	{
		case 0: shape = @"star"; break;
		case 1: shape = @"clover"; break;
		case 2: shape = @"heart"; break;
		case 3: shape = @"diamond"; break;
	}
	
	Block *s = [Block spriteWithFile:[NSString stringWithFormat:@"%@-%@.png", color, shape]];
	[s setColour:color];
	[s setShape:shape];
	
	int x = index % cols;
	int y = floor(index / rows);
	
	[s setGridPosition:ccp(x, y)];
	[s snapToGridPosition];
	//[s setPosition:ccp(x * blockSize - blockSize / 2, y * blockSize - blockSize / 2)];		// Extended grid
	//[s setPosition:ccp(x * blockSize + blockSize / 2, y * blockSize + blockSize / 2)];	// "Fit" grid

	[self addChild:s z:1];
	
	// Do a "growing" animation on the new block
	[s embiggen];
	
	// Do a check here to see if we need to replace an object or insert
	if ([grid count] > index && [grid objectAtIndex:index] != nil)
		[grid replaceObjectAtIndex:index withObject:s];
	else
		[grid insertObject:s atIndex:index];
}

- (void)createParticlesAt:(CGPoint)position
{
	// Create quad particle system (faster on 3rd gen & higher devices, only slightly slower on 1st/2nd gen)
	CCParticleSystemQuad *particleSystem = [[CCParticleSystemQuad alloc] initWithTotalParticles:25];
	
	// duration is for the emitter
	[particleSystem setDuration:0.5f];
	
	[particleSystem setEmitterMode:kCCParticleModeGravity];
	
	// Gravity Mode: gravity
	[particleSystem setGravity:ccp(0, 0)];
	
	// Gravity Mode: speed of particles
	[particleSystem setSpeed:140];
	[particleSystem setSpeedVar:40];
	
	// Gravity Mode: radial
	[particleSystem setRadialAccel:0];
	[particleSystem setRadialAccelVar:0];
	
	// Gravity Mode: tagential
	[particleSystem setTangentialAccel:0];
	[particleSystem setTangentialAccelVar:0];
	
	// angle
	[particleSystem setAngle:90];
	[particleSystem setAngleVar:360];
	
	// emitter position
	[particleSystem setPosition:position];
	[particleSystem setPosVar:CGPointZero];
	
	// life is for particles particles - in seconds
	[particleSystem setLife:0.5f];
	[particleSystem setLifeVar:0.25f];
	
	// size, in pixels
	[particleSystem setStartSize:8.0f];
	[particleSystem setStartSizeVar:2.0f];
	[particleSystem setEndSize:kCCParticleStartSizeEqualToEndSize];
	
	// emits per second
	[particleSystem setEmissionRate:[particleSystem totalParticles] / [particleSystem duration]];
	
	// color of particles
	ccColor4F startColor = {1.0f, 1.0f, 1.0f, 1.0f};
	ccColor4F endColor = {1.0f, 1.0f, 1.0f, 1.0f};
	[particleSystem setStartColor:startColor];
	[particleSystem setEndColor:endColor];
	
	[particleSystem setTexture:[[CCTextureCache sharedTextureCache] addImage:@"particle.png"]];
	
	// additive
	[particleSystem setBlendAdditive:NO];
	
	// Auto-remove the emitter when it is done!
	[particleSystem setAutoRemoveOnFinish:YES];
	
	// Add to layer
	[self addChild:particleSystem z:10];
	
	NSLog(@"Tryin' to make a particle emitter at %f, %f", position.x, position.y);
}

- (void)updateScore:(int)points
{
	score += points;
	[scoreLabel setString:[NSString stringWithFormat:@"%i", score]];
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	[grid release];
	
	
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
