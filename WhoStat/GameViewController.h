//
//  GameViewController.h
//  WhoStat
//
//  Created by Dan Schlosser on 7/11/13.
//  Copyright (c) 2013 Dan Schlosser. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum DestinationViewOption: NSInteger {
    DestinationViewOptionStatus = 0,
    DestinationViewOptionGuess = 1,
    DestinationViewOptionAnswer = 2,
} DestinationViewOption;

@interface GameViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>


// Parent view for top panel that filps between three subviews
@property (weak, nonatomic) IBOutlet UIView *flippingParentView;
    //Which of the three views is displayed
    @property (nonatomic) DestinationViewOption currentlyDisplayedView;
    // The status
    @property (weak, nonatomic) IBOutlet UIView *statusView;
        @property (weak, nonatomic) NSString *currentStatus;
        @property (weak, nonatomic) IBOutlet UITextView *statusTextView;
    // User confirms guess
    @property (weak, nonatomic) IBOutlet UIView *confirmGuessView;
        @property (weak, nonatomic) IBOutlet UIImageView *guessImageView;
        @property (weak, nonatomic) IBOutlet UILabel *guessNameLabel;
        @property (weak, nonatomic) IBOutlet UIButton *yesButton;
        @property (weak, nonatomic) IBOutlet UIButton *noButton;
    // Correct Answer
    @property (strong, nonatomic) IBOutlet UIView *correctAnswerView;
        @property (weak, nonatomic) IBOutlet UILabel *correctFriendNameLabel;
        @property (weak, nonatomic) IBOutlet UIImageView *xOrOImageView;
        @property (strong, nonatomic) NSString *correctFriendName;
        @property (strong, nonatomic) UIImage *correctFriendImage;
@property (weak, nonatomic) IBOutlet UIImageView *correctFriendImageView;
        @property (weak, nonatomic) IBOutlet UIButton *nextButton;
// TableView below
@property (weak, nonatomic) IBOutlet UITableView *friendOptionsTableView;
    @property (strong, nonatomic) NSArray *friendOptions;

@end
