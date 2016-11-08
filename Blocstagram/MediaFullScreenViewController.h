//
//  MediaFullScreenViewController.h
//  Blocstagram
//
//  Created by Fiona Alpe on 11/8/16.
//  Copyright © 2016 Fiona Alpe. All rights reserved.
//

#import <UIKit/UIKit.h>


@class Media;

@interface MediaFullScreenViewController : UIViewController

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;

- (instancetype) initWithMedia:(Media *)media;

- (void) centerScrollView;

@end

