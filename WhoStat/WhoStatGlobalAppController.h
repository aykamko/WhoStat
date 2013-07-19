//
//  WhoStatGlobalAppController.h
//  WhoStat
//
//  Created by Aleks Kamko on 7/15/13.
//  Copyright (c) 2013 Dan Schlosser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBRequestController.h"
#import "TitleViewController.h"
#import "GameViewController.h"

@interface WhoStatGlobalAppController : NSObject
<UINavigationControllerDelegate,
TitleViewControllerDelegate,
GameViewControllerDelegate>

@property (strong, nonatomic) UINavigationController *navController;

+ (WhoStatGlobalAppController *)appController;
- (void)sendNewRoundToGameViewController;

@end
