//
//  ViewController.m
//  MainWindowDemo
//
//  Created by Juncheng Han on 9/20/16.
//  Copyright © 2016 Theohzoneinc. All rights reserved.
//

#import "MainViewDemoViewController.h"

typedef enum CurrentView {
    ZONE_VIEW = 1,
    CHAT_VIEW = 2,
    FEED_VIEW = 3
}CurrentView;

typedef enum TableTag {
    SMALL_TABLE = 1,
    LARGE_TABLE = 2
}TableTag;


@interface MainViewDemoViewController () <CAAnimationDelegate, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>
{
    UIView *zoneView;
    UIView *zoneBottomView;
    UIImageView *clothImageView;
    
    
    UIView *chatView;
    UIView *chatBottomView;
    
    UIVisualEffect *blurEffect;
    UIVisualEffectView *visualEffectView;
    
    UIView *leftSideView;
    UIView *rightSideView;
    
    UIView *feedView;
    
    CGPoint startPoint;
    CGPoint endPoint;
    
    UIPanGestureRecognizer *panG;
    
    UIPanGestureRecognizer *dragCloth;
    
    CurrentView currentView;
    
    UIImageView *dummyView;
    
    UIView *chatContainerView;
    UITextView *chatInputTxtView;
    UIButton *sendButton;
    
    CGFloat deltaY;
    CGPoint originalChatContainerCenter;
    
    UITableView *smallTable;
    
    UITableView *largeTable;
    
    NSMutableArray *fakeData;
    NSMutableArray *repository;
    
    NSString *newMessage;
    
}
@end

@implementation MainViewDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    currentView = ZONE_VIEW;
    
    fakeData = [[NSMutableArray alloc] initWithObjects:@"Looks good", @"Nice", @"Try this on.",@"Looks good", @"Nice", @"Try this on.",nil];
    
    repository = [NSMutableArray new];

    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
    panG = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    
    dragCloth = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDragClothPanGesture:)];
    
    [self.view addGestureRecognizer:panG];

    
    
    [self layout];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self registerForKeyboardNotifications];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self loadFakedata];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadFakedata {
    
    if (repository.count == 3) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [repository removeObjectAtIndex:0];
        [smallTable beginUpdates];
        [smallTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        [smallTable endUpdates];
        
    }
    
    [repository addObject:fakeData[[self getRandomNumberBetween:0 to:(int)(fakeData.count - 1)]]];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:repository.count - 1 inSection:0];
    
    [smallTable beginUpdates];
    [smallTable insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
    [smallTable endUpdates];
    
    [self performSelector:@selector(loadFakedata) withObject:nil afterDelay:[self getRandomNumberBetween:1 to:4]];
}

-(int)getRandomNumberBetween:(int)from to:(int)to {
    
    return (int)from + arc4random() % (to-from+1);
}

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillOpen:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillClose:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidClose:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
//    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(keyboardWillChangeFrame:)
//                                                     name:UIKeyboardWillChangeFrameNotification
//                                                   object:nil];
//    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)layout {
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;

    [self layoutZoneViewW:screenWidth viewH:screenHeight];
    [self layoutFeedViewW:screenWidth viewH:screenHeight];
    [self layoutChatViewW:screenWidth viewH:screenHeight];
    
    
}

- (void)layoutZoneViewW:(CGFloat)viewW viewH:(CGFloat)viewH {
    
    zoneView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewW, viewH)];
    zoneView.backgroundColor = [UIColor redColor];
    zoneView.tag = ZONE_VIEW;
    
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WechatIMG10"]];
    bg.frame = CGRectMake(0, 0, viewW, viewH);
    bg.contentMode = UIViewContentModeScaleAspectFit;
    [zoneView addSubview:bg];
    
    leftSideView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, viewH)];
    leftSideView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.6];
    leftSideView.alpha = 0.0;
    
    rightSideView = [[UIView alloc] initWithFrame:CGRectMake(viewW - 50, 0, 50, viewH)];
    rightSideView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.6];
    rightSideView.alpha = 0.0;
    
    chatContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, viewH - 50, viewW, 50)];
    chatContainerView.backgroundColor = [UIColor whiteColor];
    
    chatContainerView.alpha = 0.0;
    
    chatInputTxtView = [[UITextView alloc] initWithFrame:CGRectMake(8, 0, 200, 40)];
    chatInputTxtView.center = CGPointMake(chatInputTxtView.center.x, 50/2.0);
    chatInputTxtView.backgroundColor = [UIColor lightGrayColor];
    chatInputTxtView.textColor = [UIColor blackColor];
    chatInputTxtView.delegate = self;
    
    sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
    sendButton.frame = CGRectMake(viewW - 8 - 50, 0, 50, 40);
    sendButton.center = CGPointMake(sendButton.center.x, 50/2.0);
    [sendButton setTitle:@"Send" forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
    
    [chatContainerView addSubview:chatInputTxtView];
    [chatContainerView addSubview:sendButton];
    
    
    clothImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Cloth"]];
    clothImageView.contentMode = UIViewContentModeScaleAspectFit;
    clothImageView.center = zoneView.center;
    clothImageView.userInteractionEnabled = YES;
    [clothImageView addGestureRecognizer:dragCloth];
    
    //[clothImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    smallTable = [[UITableView alloc] initWithFrame:CGRectMake(viewW - 8 - 200, 60, 200, 100) style:UITableViewStylePlain];
    smallTable.backgroundColor = [UIColor clearColor];
    smallTable.allowsSelection = NO;
    smallTable.bounces = NO;
    smallTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    smallTable.delegate = self;
    smallTable.dataSource = self;
    smallTable.contentInset = UIEdgeInsetsZero;
    smallTable.tag = SMALL_TABLE;
    smallTable.userInteractionEnabled = YES;
    [smallTable setTableFooterView:[UIView new]];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSmallTabel)];
    
    [smallTable addGestureRecognizer:tap];
    
    [zoneView addSubview:clothImageView];
    [zoneView addSubview:smallTable];
    [zoneView addSubview:leftSideView];
    [zoneView addSubview:rightSideView];
    [zoneView addSubview:chatContainerView];
    
    [smallTable reloadData];
    
    originalChatContainerCenter = chatContainerView.center;
    
    [self.view addSubview:zoneView];
    
    //NSArray *test = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[v0]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:@{@"v0":clothImageView}];
    
    //NSArray *test1 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[v0]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:@{@"v0":clothImageView}];
    
//    [clothImageView.superview addConstraints:test];
//    [clothImageView.superview addConstraints:test1];
    
    //[NSLayoutConstraint activateConstraints:test];
}

- (void)layoutChatViewW:(CGFloat)viewW viewH:(CGFloat)viewH {
    chatView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewW, viewH)];
    chatView.backgroundColor = [UIColor blueColor];
    chatView.tag = CHAT_VIEW;
}


- (void)layoutFeedViewW:(CGFloat)viewW viewH:(CGFloat)viewH {
    
    feedView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewW, viewH)];
    feedView.backgroundColor = [UIColor yellowColor];
    feedView.tag = FEED_VIEW;
}

#pragma mark - view transfer animation
- (void)transferFromView:(UIView *)view1 toView:(UIView *)view2 toLeft:(BOOL)toLeft {

    //NSUInteger index;
    
    //for(index = 0; [self.view.subviews objectAtIndex:index] != view1; ++index) {};
    
    // Remove old view
    [view1 removeFromSuperview];
    
    // Inser new view at right index
    //[self.view insertSubview:view2 atIndex:index];
    [self.view addSubview:view2];
    
    // Create the transition
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    [animation setType:kCATransitionPush];
    if (toLeft) {
        [animation setSubtype:kCATransitionFromLeft];
    } else {
        [animation setSubtype:kCATransitionFromRight];
    }
    [animation setDuration:0.3];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animation setValue:self.view forKey:@"mainWindowViewChange"];
    [[self.view layer] addAnimation:animation forKey:@"transferViews"];
    
    currentView = (CurrentView)view2.tag;
    NSLog(@"current: %d", currentView);
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    NSLog(@"animation stoped");
    
    [self.view addGestureRecognizer:panG];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint velovity = [gestureRecognizer velocityInView:self.view];
    //CGPoint translation = [gestureRecognizer translationInView:self.view];

    //NSLog(@"translation: %f, %f", translation.x, translation.y);
    //NSLog(@"velovity: %f, %f", velovity.x, velovity.y);
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        startPoint = [gestureRecognizer locationInView:self.view];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        endPoint = [gestureRecognizer locationInView:self.view];
        if (fabs(startPoint.x - endPoint.x) > 150 && fabs(startPoint.y - endPoint.y) < 50) {
            if (velovity.x > 0) {
                NSLog(@"to left view");
                if (currentView == ZONE_VIEW) {
                    [self.view removeGestureRecognizer:panG];
                    [self transferFromView:zoneView toView:feedView toLeft:YES];
                } else if (currentView == CHAT_VIEW) {
                    [self.view removeGestureRecognizer:panG];
                    [self transferFromView:chatView toView:zoneView toLeft:YES];
                } else if (currentView == FEED_VIEW) {
                    
                }
            } else {
                NSLog(@"to right view");
                if (currentView == ZONE_VIEW) {
                    [self.view removeGestureRecognizer:panG];
                    [self transferFromView:zoneView toView:chatView toLeft:NO];
                } else if (currentView == FEED_VIEW) {
                    [self.view removeGestureRecognizer:panG];
                    [self transferFromView:feedView toView:zoneView toLeft:NO];
                } else if (currentView == CHAT_VIEW) {
                            
                }
            }
        }
    }
}

- (void)handleDragClothPanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
    //CGPoint velovity = [gestureRecognizer velocityInView:self.view];
    //CGPoint translation = [gestureRecognizer translationInView:self.view];
    
    //NSLog(@"translation: %f, %f", translation.x, translation.y);
    //NSLog(@"velovity: %f, %f", velovity.x, velovity.y);
    
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        //startPoint = [gestureRecognizer locationInView:self.view];
        dummyView = [[UIImageView alloc] initWithImage:clothImageView.image];
        dummyView.transform = CGAffineTransformMakeScale(0.8, 0.8);
        dummyView.center = clothImageView.center;
        [zoneView addSubview:dummyView];
        [self changeAppearanceOfView:leftSideView alpha:0.5];
        [self changeAppearanceOfView:rightSideView alpha:0.5];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        dummyView.center = [gestureRecognizer locationInView:self.view];
        
        CGPoint finalRightPoint = [rightSideView convertPoint:[gestureRecognizer locationInView:self.view] fromView:rightSideView.window];
        if ([rightSideView pointInside:finalRightPoint withEvent:nil]) {
            rightSideView.alpha = 0.7;
        } else {
            rightSideView.alpha = 0.5;
        }
        
        CGPoint finalLeftPoint = [leftSideView convertPoint:[gestureRecognizer locationInView:self.view] fromView:leftSideView.window];
        if ([leftSideView pointInside:finalLeftPoint withEvent:nil]) {
            leftSideView.alpha = 0.7;
        } else {
            leftSideView.alpha = 0.5;
        }
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [dummyView removeFromSuperview];
        CGPoint finalRightPoint = [rightSideView convertPoint:[gestureRecognizer locationInView:self.view] fromView:rightSideView.window];
        if ([rightSideView pointInside:finalRightPoint withEvent:nil]) {
            NSLog(@"send to chat");
            rightSideView.alpha = 0.5;
            [chatInputTxtView becomeFirstResponder];
        }
        
        CGPoint finalLeftPoint = [leftSideView convertPoint:[gestureRecognizer locationInView:self.view] fromView:leftSideView.window];
        if ([leftSideView pointInside:finalLeftPoint withEvent:nil]) {
            leftSideView.alpha = 0.5;
            NSLog(@"send to post");
        }
        
        [self changeAppearanceOfView:leftSideView alpha:0.0];
        [self changeAppearanceOfView:rightSideView alpha:0.0];
        
        
    }
}

- (void)changeAppearanceOfView:(UIView *)view alpha:(CGFloat)alpha {
    [UIView animateWithDuration:0.2 animations:^{
        view.alpha = alpha;
    }];
}

- (void)keyboardWillOpen:(NSNotification *)notification {
    [UIView animateWithDuration:0.2 animations:^{
        chatContainerView.alpha = 1.0;
    }];
    
    NSDictionary *info = [notification userInfo];
    CGRect keyboardFrame = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardFrame = [self.view convertRect:keyboardFrame fromView:nil];
    CGFloat yPosition = keyboardFrame.origin.y;
    
//    NSInteger height = [UIScreen mainScreen].bounds.size.height - yPosition;
    
    double animationDuration;
    animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];

    deltaY = chatContainerView.frame.origin.y + chatContainerView.frame.size.height - yPosition;
    
    if (deltaY > 0) {
        [UIView animateWithDuration:animationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            chatContainerView.center = CGPointMake(chatContainerView.center.x, chatContainerView.center.y - deltaY);
        } completion:^(BOOL finished) {
            
        }];
    }

}

- (void)tapSmallTabel {
    [chatInputTxtView becomeFirstResponder];
}

- (void)keyboardWillClose:(NSNotification *)notification {
    [UIView animateWithDuration:0.2 animations:^{
        chatContainerView.alpha = 0.0;
    }];
    
    double animationDuration;
    animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];

    [UIView animateWithDuration:animationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        chatContainerView.center = originalChatContainerCenter;
    } completion:^(BOOL finished) {
        
    }];

}

- (void)keyboardDidClose:(NSNotification *)notification {
    
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    newMessage = textView.text;
    NSLog(@"message: %@", newMessage);
    [self addNewMessage:newMessage];
}

- (void)sendMessage {
    [chatInputTxtView resignFirstResponder];
}


- (void)addNewMessage:(NSString *)message {
    
    if (repository.count == 3) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [repository removeObjectAtIndex:0];
        [smallTable beginUpdates];
        [smallTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        [smallTable endUpdates];
        
    }
    
    [repository addObject:message];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:repository.count - 1 inSection:0];
    
    [smallTable beginUpdates];
    [smallTable insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [smallTable endUpdates];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView.tag == SMALL_TABLE) {
        return repository.count;
    } else if (tableView.tag == LARGE_TABLE) {
        return fakeData.count;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100 / 3.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == SMALL_TABLE) {
        NSString *identifier = @"smallTable";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        }
        
        cell.layer.cornerRadius = 8;
        cell.layer.masksToBounds = YES;
        cell.backgroundColor = [UIColor whiteColor];
        cell.textLabel.text = repository[indexPath.row];
        return cell;
    }
    
    return nil;
}

@end
