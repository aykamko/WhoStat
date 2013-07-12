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

-(void)flipFlippingParentToView:(DestinationViewOption)destination withBlock:(void (^)(BOOL))completion;

@end

@implementation GameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // custom initializations
        _currentlyDisplayedView = DestinationViewOptionStatus;
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

-(void)flipFlippingParentToView:(DestinationViewOption)destination withBlock:(void (^)(BOOL))completion {
    if ([self currentlyDisplayedView] == destination)
        return;
    [UIView transitionWithView:self.flippingParentView
                      duration:0.5
                       options:((destination > [self currentlyDisplayedView]) ?
                                UIViewAnimationOptionTransitionFlipFromRight :
                                UIViewAnimationOptionTransitionFlipFromLeft)
                    animations: ^{
                        switch (destination) {
                            case DestinationViewOptionStatus:
                                self.statusView.hidden = false;
                                self.confirmGuessView.hidden = true;
                                self.correctAnswerView.hidden = true;
                                break;
                            case DestinationViewOptionGuess:
                                self.statusView.hidden = true;
                                self.confirmGuessView.hidden = false;
                                self.correctAnswerView.hidden = true;
                                break;
                            case DestinationViewOptionAnswer:
                                self.statusView.hidden = true;
                                self.confirmGuessView.hidden = true;
                                self.correctAnswerView.hidden = false;
                                break;
                        }
                    }
                    completion:completion];
}
- (IBAction)nextQuestion:(id)sender {
    GameViewController *gameViewController = [[GameViewController alloc] initWithNibName:@"GameViewController" bundle:nil];
    
    [self.navigationController pushViewController:gameViewController animated:YES];
}

- (IBAction)cancelGuess:(id)sender {
    [[self friendOptionsTableView] setUserInteractionEnabled:YES];
    [[self friendOptionsTableView] deselectRowAtIndexPath:_indexPathOfCurrentFriendSelection animated:YES];
    [self flipFlippingParentToView:DestinationViewOptionStatus withBlock:^(BOOL finished) {
        if (finished) {
            [self setCurrentlyDisplayedView:DestinationViewOptionStatus];
        }
    }];
}
- (IBAction)confirmGuess:(id)sender {
    NSString *nameOfGuessedFriend = [[self guessNameLabel] text];
    
    void (^completionBlock)(BOOL success) = ^void(BOOL success) {
        double firstDelayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(firstDelayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            
            
            double delayInSeconds = 0.4;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self flipFlippingParentToView:DestinationViewOptionAnswer withBlock:^(BOOL finished) {
                    if (finished) {
                        [self setCurrentlyDisplayedView:DestinationViewOptionAnswer];
                    }
                }];
            });
        });
        
    };
    
    
    if ([nameOfGuessedFriend isEqualToString:_correctFriendName]) {
        [UIView animateWithDuration:1 animations:^{
            [[self xOrOImageView] setImage:[UIImage imageNamed:@"checkmark.png"]];
        }
                         completion:completionBlock];
    } else {
        [UIView animateWithDuration:1 animations:^{
            [[self xOrOImageView] setImage:[UIImage imageNamed:@"xmark.png"]];
        }
                         completion:completionBlock];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[self friendOptionsTableView] setUserInteractionEnabled:NO];
    NSDictionary *guessedFriendInfo = [[self friendOptions] objectAtIndex:[indexPath row]];
    _indexPathOfCurrentFriendSelection = indexPath;
    [[self guessImageView] setImage:guessedFriendInfo[@"image"]];
    [[self guessNameLabel] setText:guessedFriendInfo[@"name"]];
    [self flipFlippingParentToView:DestinationViewOptionGuess withBlock:^(BOOL finished) {
        if (finished) {
            [self setCurrentlyDisplayedView:DestinationViewOptionGuess];
        }
    }];
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
    [[self statusTextView] setEditable:NO];
    [[self correctFriendNameLabel] setText:[self correctFriendName]];
    [[self correctFriendImageView] setImage:[self correctFriendImage]];
    [self.view bringSubviewToFront:_xOrOImageView];
    self.confirmGuessView.hidden = true;
    self.correctAnswerView.hidden = true;
    
    UINib *nib = [UINib nibWithNibName:@"FriendOptionCell" bundle:nil];
    
    [[self friendOptionsTableView] registerNib:nib forCellReuseIdentifier:@"FriendOptionCell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
