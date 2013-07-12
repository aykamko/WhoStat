//
//  GameViewController.m
//  WhoStat
//
//  Created by Dan Schlosser on 7/11/13.
//  Copyright (c) 2013 Dan Schlosser. All rights reserved.
//

#import "GameViewController.h"
#import "FriendOptionCell.h"

@interface GameViewController () {
    NSIndexPath *_indexPathOfCurrentFriendSelection;
}

-(void)flipFlippingParentViewWithBlock:(void (^)(BOOL))completion shouldFlipToFinalLayout:(BOOL)shouldFlipToFinalLayout;

@end

@implementation GameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // custom initializations
        _displayingStatus = YES;
        NSDictionary *matt = @{@"image":[UIImage imageNamed:@"earth.jpeg"], @"name":@"Matt"};
        NSDictionary *dan = @{@"image":[UIImage imageNamed:@"eye.jpeg"], @"name":@"Dan"};
        NSDictionary *ashwin = @{@"image":[UIImage imageNamed:@"girl.jpg"], @"name":@"Ashwin"};
        NSDictionary *aleks = @{@"image":[UIImage imageNamed:@"man.png"], @"name":@"Aleks"};
        NSDictionary *george = @{@"image":[UIImage imageNamed:@"camera.jpg"], @"name":@"George"};
        _correctFriendName = @"Dan";
        _correctFriendImage = [UIImage imageNamed:@"eye.jpeg"];
        _friendOptions = [[NSArray alloc] initWithObjects:matt, george, dan, ashwin, aleks, nil];
    }
    return self;
}

- (id)init {
    return [self initWithNibName:@"GameViewController" bundle:nil];
    
}

-(void)flipFlippingParentViewWithBlock:(void (^)(BOOL))completion shouldFlipToFinalLayout:(BOOL)shouldFlipToFinalLayout{
    [UIView transitionWithView:self.flippingParentView
                      duration:1.0
                       options:(_displayingStatus ? UIViewAnimationOptionTransitionFlipFromRight :
                                UIViewAnimationOptionTransitionFlipFromLeft)
                    animations: ^{
                        if(shouldFlipToFinalLayout) {
                            [[self nameLabel] setText:[self correctFriendName]];
                            [[self topLabel] setText:@"The answer is:"];
                            self.noButton.hidden = true;
                            self.xOrOImageView.hidden = true;
                            [self.guessImageView setImage:[self correctFriendImage]];
                            self.yesButton.hidden = true;
                            self.nextButton.hidden = false;
                            
                        }
                        else if(_displayingStatus)
                        {
                            self.statusView.hidden = true;
                            self.confirmGuessView.hidden = false;
                        }
                        else
                        {
                            self.statusView.hidden = false;
                            self.confirmGuessView.hidden = true;
                        }
                    }
                    completion:completion];
}

- (IBAction)cancelGuess:(id)sender {
    [[self friendOptionsTableView] setUserInteractionEnabled:YES];
    [[self friendOptionsTableView] deselectRowAtIndexPath:_indexPathOfCurrentFriendSelection animated:YES];
    [self flipFlippingParentViewWithBlock:^(BOOL finished) {
        if (finished) {
            _displayingStatus = !_displayingStatus;
        }
    } shouldFlipToFinalLayout:NO];
    
}
- (IBAction)confirmGuess:(id)sender {
    NSString *nameOfGuessedFriend = [[self nameLabel] text];
    NSLog(@"%@", nameOfGuessedFriend);
    if ([nameOfGuessedFriend isEqualToString:_correctFriendName]) {
        [UIView animateWithDuration:1 animations:^{
            [[self xOrOImageView] setImage:[UIImage imageNamed:@"checkmark.png"]];
        }];
    } else {
        [UIView animateWithDuration:0 animations:^{
            [[self xOrOImageView] setImage:[UIImage imageNamed:@"xmark.png"]];
        }];
    }
    usleep(500000);
    [self flipFlippingParentViewWithBlock:^(BOOL finished) {
        if (finished) {
            _displayingStatus = !_displayingStatus;
        }
    } shouldFlipToFinalLayout:YES];
    self.xOrOImageView.hidden = false;
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[self friendOptionsTableView] setUserInteractionEnabled:NO];
    NSDictionary *guessedFriendInfo = [[self friendOptions] objectAtIndex:[indexPath row]];
    _indexPathOfCurrentFriendSelection = indexPath;
    [[self guessImageView] setImage:guessedFriendInfo[@"image"]];
    [[self nameLabel] setText:guessedFriendInfo[@"name"]];
    [self flipFlippingParentViewWithBlock:^(BOOL finished) {
        if (finished) {
            _displayingStatus = !_displayingStatus;
        }
    } shouldFlipToFinalLayout:NO];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"entered tableview:numberrowsinsection:");
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"entered tableView:cellForRowAtIndexPath:");
    FriendOptionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendOptionCell"];
    
    [cell setController:self];
//    [cell setTableView:tableView];
    NSDictionary *friendInfo = [[self friendOptions] objectAtIndex:[indexPath row]];
    [[cell nameLabel] setText:friendInfo[@"name"]];
    [[cell thumbnailView] setImage:friendInfo[@"image"]];
    return cell;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    NSLog(@"The view will appear");
    self.nextButton.hidden = true;
    [[self confirmGuessView] setHidden:YES];
    _friendOptionsTableView.scrollEnabled = NO;
    [[self friendOptionsTableView] setDelegate:self];
    [[self friendOptionsTableView] setDataSource:self];
    [[self friendOptionsTableView] reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UINib *nib = [UINib nibWithNibName:@"FriendOptionCell" bundle:nil];
    
    [[self friendOptionsTableView] registerNib:nib forCellReuseIdentifier:@"FriendOptionCell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
