//
//  GameViewController.h
//  WhoStat
//
//  Created by Dan Schlosser on 7/11/13.
//  Copyright (c) 2013 Dan Schlosser. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *friendOptionsTableView;
@property (weak, nonatomic) IBOutlet UIView *statusView;
@property (weak, nonatomic) IBOutlet NSString *currentStatus;
@property (weak, nonatomic) IBOutlet UIView *confirmGuessView;
@property (weak, nonatomic) IBOutlet UIView *flippingParentView;
@property (weak, nonatomic) IBOutlet UIView *flippingImageView;
@property (nonatomic) BOOL displayingStatus;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *guessImageView;
@property (strong, nonatomic) NSArray *friendOptions;
@property (strong, nonatomic) NSString *correctFriendName;
@property (strong, nonatomic) UIImage *correctFriendImage;
@property (weak, nonatomic) IBOutlet UITextView *statusTextView;

@property (weak, nonatomic) IBOutlet UIButton *yesButton;
@property (weak, nonatomic) IBOutlet UIButton *noButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UIImageView *xOrOImageView;



@end
