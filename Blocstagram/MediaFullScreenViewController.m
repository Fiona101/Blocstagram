//
//  MediaFullScreenViewController.m
//  Blocstagram
//
//  Created by Fiona Alpe on 11/8/16.
//  Copyright © 2016 Fiona Alpe. All rights reserved.
//

#import "MediaFullScreenViewController.h"
#import "Media.h"
#import "ImagesTableViewController.h"
#import "MediaTableViewCell.h"

@interface MediaFullScreenViewController () <MediaTableViewCellDelegate,UIScrollViewDelegate>

@property (nonatomic, strong) Media *media;
@property (nonatomic, strong) MediaTableViewCell *mediaCell;

@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTap;


@end

@implementation MediaFullScreenViewController


- (instancetype) initWithMediaCell:(MediaTableViewCell *)cell {
    self = [super init];
    
    if (self) {
        self.media = cell.mediaItem;
        self.mediaCell = cell;
    }
    
    return self;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.view.autoresizesSubviews = NO;
    shareButton.autoresizingMask = 0;
    [shareButton addTarget:self
                    action:@selector(showActivityController)
          forControlEvents:UIControlEventTouchUpInside];
    
    
    [shareButton setTitle:@"Share" forState:UIControlStateNormal];
    
    shareButton.frame = CGRectMake((self.view.bounds.size.width - 60), 10, 50, 30.0);
    //shareButton.backgroundColor = [UIColor yellowColor];
    

    // #1
    self.scrollView = [UIScrollView new];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.scrollView];
    
    // #2
    self.imageView = [UIImageView new];
    self.imageView.image = self.media.image;
    
    [self.scrollView addSubview:self.imageView];
    
    // #3
    self.scrollView.contentSize = self.media.image.size;
    
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
    
    self.doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapFired:)];
    self.doubleTap.numberOfTapsRequired = 2;
    
    [self.tap requireGestureRecognizerToFail:self.doubleTap];
    
    [self.scrollView addGestureRecognizer:self.tap];
    [self.scrollView addGestureRecognizer:self.doubleTap];

    [self.view addSubview:shareButton];

    /*

    NSLayoutConstraint *topLC = [NSLayoutConstraint constraintWithItem:shareButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:0.001 constant:5];
    NSLayoutConstraint *rightLC = [NSLayoutConstraint constraintWithItem:shareButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:0 constant:15];

    NSLayoutConstraint *widthLC = [NSLayoutConstraint constraintWithItem:shareButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0.001 constant:65];
    NSLayoutConstraint *heightLC = [NSLayoutConstraint constraintWithItem:shareButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.001 constant:35];
*/
    
    NSDictionary *vb = NSDictionaryOfVariableBindings(shareButton);
    /*
    [NSLayoutConstraint activateConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[shareButton(60)]-|" options:0 metrics:nil views:vb]];

    [NSLayoutConstraint activateConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[shareButton(30)]-|" options:0 metrics:nil views:vb]];
    */
     /*
    shareButton.autoresizingMask = UIViewAutoresizingNone;
     */
    /*
    [NSLayoutConstraint activateConstraints:@[topLC,rightLC
                                              //,widthLC,heightLC
                                              ]];
*/
}


- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    // #4
    self.scrollView.frame = self.view.bounds;
    
    // #5
    CGSize scrollViewFrameSize = self.scrollView.frame.size;
    CGSize scrollViewContentSize = self.scrollView.contentSize;
    
    CGFloat scaleWidth = scrollViewFrameSize.width / scrollViewContentSize.width;
    CGFloat scaleHeight = scrollViewFrameSize.height / scrollViewContentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    
    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.maximumZoomScale = 1;

}

- (void)centerScrollView {
    [self.imageView sizeToFit];
    
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = self.imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - CGRectGetWidth(contentsFrame)) / 2;
    } else {
        contentsFrame.origin.x = 0;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - CGRectGetHeight(contentsFrame)) / 2;
    } else {
        contentsFrame.origin.y = 0;
    }
    
    self.imageView.frame = contentsFrame;

}

#pragma mark - UIScrollViewDelegate

    // #6
- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;

}

    // #7
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self centerScrollView];

}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self centerScrollView];

}

#pragma mark - Gesture Recognizers

- (void) tapFired:(UITapGestureRecognizer *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

}

- (void) doubleTapFired:(UITapGestureRecognizer *)sender {
    
    if (self.scrollView.zoomScale == self.scrollView.minimumZoomScale) {
    
        // #8
        CGPoint locationPoint = [sender locationInView:self.imageView];
        
        CGSize scrollViewSize = self.scrollView.bounds.size;
        
        CGFloat width = scrollViewSize.width / self.scrollView.maximumZoomScale;
        CGFloat height = scrollViewSize.height / self.scrollView.maximumZoomScale;
        CGFloat x = locationPoint.x - (width / 2);
        CGFloat y = locationPoint.y - (height / 2);
        
        [self.scrollView zoomToRect:CGRectMake(x, y, width, height) animated:YES];
    
    } else {
    
        // #9
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    }

}

- (IBAction)showActivityController {
    NSMutableArray *itemsToShare = [NSMutableArray array];
    
    if (self.media.caption.length > 0) {
        [itemsToShare addObject:self.media.caption];
    }
    
    if (self.media.image) {
        [itemsToShare addObject:self.media.image];
    }
    
    if (itemsToShare.count > 0) {
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
        [self presentViewController:activityVC animated:YES completion:nil];
        
    }
    
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
