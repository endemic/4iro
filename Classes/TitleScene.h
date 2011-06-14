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
}

+ (id)scene;
- (void)showUI;
- (void)update:(ccTime)dt;

@end
