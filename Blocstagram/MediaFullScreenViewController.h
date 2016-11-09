//
//  MediaFullScreenViewController.h
//  Blocstagram
//
//  Created by Fiona Alpe on 11/8/16.
//  Copyright © 2016 Fiona Alpe. All rights reserved.
//

#import <UIKit/UIKit.h>


@class MediaTableViewCell;



@interface MediaFullScreenViewController : UIViewController

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *shareButton;
@property(nonatomic, readonly) UIButtonType buttonType;


- (instancetype) initWithMediaCell:(MediaTableViewCell *)cell;

- (void) centerScrollView;

@end

