//
//  MediaTableViewCell.h
//  Blocstagram
//
//  Created by Fiona Alpe on 9/13/16.
//  Copyright © 2016 Fiona Alpe. All rights reserved.
//

#import <UIKit/UIKit.h>


@class Media;


@interface MediaTableViewCell : UITableViewCell

@property (nonatomic, strong) Media *mediaItem;
@property (nonatomic, strong) NSIndexPath *indexPath;



+ (CGFloat) heightForMediaItem:(Media *)mediaItem width:(CGFloat)width;

@end
