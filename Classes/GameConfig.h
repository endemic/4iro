//
//  GameConfig.h
//  Yotsu Iro
//
//  Created by Nathan Demick on 4/13/11.
//  Copyright Ganbaru Games 2011. All rights reserved.
//

#ifndef __GAME_CONFIG_H
#define __GAME_CONFIG_H

//
// Supported Autorotations:
//		None,
//		UIViewController,
//		CCDirector
//
#define kGameAutorotationNone 0
#define kGameAutorotationCCDirector 1
#define kGameAutorotationUIViewController 2

//
// Define here the type of autorotation that you want for your game
//
#define GAME_AUTOROTATION kGameAutorotationNone

#define kGameModeNormal 1
#define kGameModeTimeAttack 2

#define kAnimationDuration 0.2
#define kMaxTimeLimit 30.0

#endif // __GAME_CONFIG_H