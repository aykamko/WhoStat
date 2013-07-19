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

- (id) init
{
    return [self initWithNibName:@"GameViewController" bundle:nil];
}

- (void)gotToNextRound:(id)sender
{
    [self.delegate gameViewControllerShouldExit:self];
}


- (void)setUpNextRound:(NSDictionary *)round withCurrentStreak:(int) streak
{
    _currentRound = round;
    [self setCorrectFriendName:_currentRound[@"correctName"]];
    [self setCorrectFriendImage:_currentRound[@"correctPic"]];
    [self setCurrentStatus:_currentRound[@"status"]];
    [self setCorrectFriendIndexPath:[NSIndexPath indexPathForRow:[_currentRound[@"correctFriendIndex"] integerValue] inSection:0]];
    [self setFriendOptions:_currentRound[@"friendOptions"]];
    
    [self setCurrentStreak:streak];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[self friendOptionsTableView] setUserInteractionEnabled:NO];
    
    NSDictionary *guessedFriendInfo = [[self friendOptions] objectAtIndex:[indexPath row]];
    [[self friendImageView] setImage:[self correctFriendImage]];
    [[self friendNameLabel] setText:[self correctFriendName]];
    
    //Change colors of the table view cells
    if (guessedFriendInfo[@"name"] != [self correctFriendName]) {
        FriendOptionCell *incorrectCell = (FriendOptionCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
//        [incorrectCell changeStyle:FriendOptionCellStyleIncorrect];
        NSLog(@"coloring incorrect cell");
        [self setCurrentStreak:0];
        incorrectCell.selectedBackgroundView = [[UIView alloc] init];
        [incorrectCell.selectedBackgroundView setBackgroundColor:[UIColor colorWithRed:93.0f/255.0f green:133.0f/255.0f blue:21.0f/255.0f alpha:1]];
        [incorrectCell setNeedsDisplay];
    } else {
        [self setCurrentStreak:[self currentStreak]+1];
    }
    [[self streakLabel] setText:[NSString stringWithFormat:@"Streak: %i", [self currentStreak]]];
    NSLog(@"coloring correct cell");
    FriendOptionCell *correctCell = (FriendOptionCell *)[self tableView:tableView cellForRowAtIndexPath:[self correctFriendIndexPath]];
//    [correctCell changeStyle:FriendOptionCellStyleCorrect];
    correctCell.selectedBackgroundView = [[UIView alloc] init];
    [correctCell.selectedBackgroundView setBackgroundColor:[UIColor colorWithRed:184.0f/255.0f green:55.0f/255.0f blue:29.0f/255.0f alpha:1]];
    [correctCell setNeedsDisplay];
    [_nextButton setEnabled:YES];
    [self.delegate gameViewControllerDidFinishRound:self];
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
    [super viewWillAppear:animated];
    //NSLog(@"The view will appear");
    _friendOptionsTableView.scrollEnabled = NO;
    
    [[self friendOptionsTableView] setDelegate:self];
    [[self friendOptionsTableView] setDataSource:self];
    [[self friendOptionsTableView] reloadData];
    
    [[self streakLabel] setText:[NSString stringWithFormat:@"Streak: %i", [self currentStreak]]];
    [[self friendNameLabel] setText:@"Who posted this?"];
    [_statusTextView setText:_currentStatus];
    [[self friendImageView] setImage:[UIImage imageNamed:@"placeholder.png"]];
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
