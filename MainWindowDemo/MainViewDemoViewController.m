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


@interface MainViewDemoViewController () <CAAnimationDelegate>
{
    UIView *zoneView;
    UIView *zoneBottomView;
    UIImageView *clothImageView;
    
    
    UIView *chatView;
    UIView *chatBottomView;
    
    UIView *feedView;
    
    CGPoint startPoint;
    CGPoint endPoint;
    
    UIPanGestureRecognizer *panG;
    
    UIPanGestureRecognizer *dragCloth;
    
    CurrentView currentView;
    
    UIImageView *dummyView;
}
@end

@implementation MainViewDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    currentView = ZONE_VIEW;

    panG = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    
    dragCloth = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDragClothPanGesture:)];
    
    [self.view addGestureRecognizer:panG];

    
    
    [self layout];
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
    
    clothImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Cloth"]];
    clothImageView.contentMode = UIViewContentModeScaleAspectFit;
    clothImageView.center = zoneView.center;
    clothImageView.userInteractionEnabled = YES;
    [clothImageView addGestureRecognizer:dragCloth];
    
    [zoneView addSubview:clothImageView];
    
    [self.view addSubview:zoneView];
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
        dummyView.center = clothImageView.center;
        [zoneView addSubview:dummyView];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        dummyView.center = [gestureRecognizer locationInView:self.view];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [dummyView removeFromSuperview];
    }
}


@end
