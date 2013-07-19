//
//  GameViewController.m
//  WhoStat
//
//  Created by Dan Schlosser on 7/11/13.
//  Copyright (c) 2013 Dan Schlosser. All rights reserved.
//

#import "GameViewController.h"
#import "FriendOptionCell.h"
#import "FBRequestController.h"

@interface GameViewController ()
{
    NSIndexPath *_indexPathOfCurrentFriendSelection;
    GameViewController *_newGameViewController;
    UIBarButtonItem *_nextButton;
}

@property (weak, nonatomic) NSString *currentStatus;
@property (strong, nonatomic) UIImage *correctFriendImage;
@property (strong, nonatomic) NSString *correctFriendName;
@property (weak, nonatomic) NSIndexPath *correctFriendIndexPath;


@property (strong, nonatomic) NSDictionary *currentRound;


//Views
@property (weak, nonatomic) IBOutlet UIView *statusBackgroundView;
@property (weak, nonatomic) IBOutlet UITextView *statusTextView;

@property (weak, nonatomic) IBOutlet UIImageView *friendImageView;
@property (weak, nonatomic) IBOutlet UILabel *friendNameLabel;

@property (weak, nonatomic) IBOutlet UIView *imageBottomBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *imageTopBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *imageWholeBackgroundView;

@property (weak, nonatomic) IBOutlet UITableView *friendOptionsTableView;

@property (weak, nonatomic) IBOutlet UILabel *streakLabel;

@end

@implementation GameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        // Next Button Configuration
        _nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(gotToNextRound:)];
        [_nextButton setEnabled:NO];
        [[self navigationItem] setRightBarButtonItem:_nextButton];
        UINavigationItem *navigationItem = [self navigationItem];
        [navigationItem setTitle:@"WhoStat?"];
        
        
    }
    return self;
}

- (id)init {
    return [self initWithNibName:@"GameViewController" bundle:nil];
}

-(void)gotToNextRound:(id)sender{
    [self.delegate didFinishRound];
//    [self.navigationController pushViewController:_newGameViewController
//                                         animated:YES];
}


- (void)setUpNextRound:(NSDictionary *)round
{
    _currentRound = round;
    [self setCorrectFriendName:_currentRound[@"correctName"]];
    [self setCorrectFriendImage:_currentRound[@"correctPic"]];
    [self setCurrentStatus:_currentRound[@"status"]];
    [self setCorrectFriendIndexPath:[NSIndexPath indexPathForRow:[_currentRound[@"correctFriendIndex"] integerValue] inSection:0]];
    [self setFriendOptions:_currentRound[@"friendOptions"]];
    
    if (self.navigationController != nil) {
        NSLog(@"nil navigationController");
        _newGameViewController = [[GameViewController alloc] initWithNibName:@"GameViewController" bundle:nil];
        [_newGameViewController setDelegate:[self delegate]];
        [_newGameViewController setUpNextRound:round];
        [self.navigationController pushViewController:_newGameViewController
                                             animated:YES];
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[self friendOptionsTableView] setUserInteractionEnabled:NO];
    NSDictionary *guessedFriendInfo = [[self friendOptions] objectAtIndex:[indexPath row]];
    _indexPathOfCurrentFriendSelection = indexPath;
    [[self friendImageView] setImage:[self correctFriendImage]];
    [[self friendNameLabel] setText:[self correctFriendName]];
    
    //Change colors of the table view cells
    if (guessedFriendInfo[@"name"] != [self correctFriendName]) {
        FriendOptionCell *incorrectCell = (FriendOptionCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
        [incorrectCell changeStyle:FriendOptionCellStyleIncorrect];
    }
    
    FriendOptionCell *correctCell = (FriendOptionCell *)[self tableView:tableView cellForRowAtIndexPath:[self correctFriendIndexPath]];
    [correctCell changeStyle:FriendOptionCellStyleCorrect];
    
    [_nextButton setEnabled:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // NSLog(@"entered tableview:numberrowsinsection:");
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // NSLog(@"entered tableView:cellForRowAtIndexPath:");
    FriendOptionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendOptionCell"];
    
    [cell setController:self];
    NSDictionary *friendInfo = [[self friendOptions] objectAtIndex:[indexPath row]];
    //NSLog(@"%@", friendInfo);
    [[cell nameLabel] setText:friendInfo[@"name"]];
    [[cell thumbnailView] setImage:friendInfo[@"image"]];
    return cell;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    //NSLog(@"The view will appear");
    [[self streakLabel] setText:@"Streak:7"];
    _friendOptionsTableView.scrollEnabled = NO;
    [[self friendOptionsTableView] setDelegate:self];
    [[self friendOptionsTableView] setDataSource:self];
    [[self friendOptionsTableView] reloadData];
    [[self friendNameLabel] setText:@"Who posted this?"];
    [_statusTextView setText:_currentStatus];
    [[self friendImageView] setImage:[UIImage imageNamed:@"eye.jpeg"]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [_nextButton setEnabled:NO];
    
    self.navigationController.navigationBar.hidden = NO;
    
    UINib *nib = [UINib nibWithNibName:@"FriendOptionCell" bundle:nil];
    [[self friendOptionsTableView] registerNib:nib forCellReuseIdentifier:@"FriendOptionCell"];
    
    // Pretty up the friend image view and border
    [self imageWholeBackgroundView].layer.cornerRadius = 2;
    [self imageBottomBackgroundView].layer.cornerRadius = 2;
    [self imageTopBackgroundView].layer.cornerRadius = 2;
    [self statusBackgroundView].layer.cornerRadius = 2;
    [self imageBottomBackgroundView].layer.borderColor = [[UIColor lightGrayColor] CGColor];
    [self imageBottomBackgroundView].layer.borderWidth = 1.0;
    [self imageTopBackgroundView].layer.borderColor = [[UIColor blackColor] CGColor];
    [self imageTopBackgroundView].layer.borderWidth =1.0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
