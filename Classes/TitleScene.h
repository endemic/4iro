//
//  TitleScene.h
//  Yotsu Iro
//
//  Created by Nathan Demick on 5/25/11.
//  Copyright 2011 Ganbaru Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface TitleScene : CCLayer 
{
	NSMutableArray *grid;
	
	// String to be appended to sprite filenames if required to use a high-rez file (e.g. iPhone 4 assests on iPad)
	NSString *hdSuffix;
	int fontMultiplier;
}

+ (id)scene;
- (void)showUI;
- (void)update:(ccTime)dt;
- (void)flash;
- (void)removeNodeFromParent:(CCNode *)node;

@end
