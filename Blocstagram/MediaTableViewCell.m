//
//  MediaTableViewCell.m
//  Blocstagram
//
//  Created by Fiona Alpe on 9/13/16.
//  Copyright © 2016 Fiona Alpe. All rights reserved.
//

#import "MediaTableViewCell.h"
#import "Media.h"
#import "Comment.h"
#import "User.h"


@interface MediaTableViewCell ()

@property (nonatomic, strong) UIImageView *mediaImageView;
@property (nonatomic, strong) UILabel *usernameAndCaptionLabel;
@property (nonatomic, strong) UILabel *commentLabel;
@property(nonatomic) NSTextAlignment alignment;


@end


static UIFont *lightFont;
static UIFont *boldFont;
static UIColor *usernameLabelGray;
static UIColor *commentLabelGray;
static UIColor *linkColor;
static NSParagraphStyle *paragraphStyle;
static UIColor *orangeColor;
static NSParagraphStyle *paragraphStyleRight;


@implementation MediaTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.mediaImageView = [[UIImageView alloc] init];
        self.usernameAndCaptionLabel = [[UILabel alloc] init];
        self.usernameAndCaptionLabel.numberOfLines = 0;
        self.usernameAndCaptionLabel.backgroundColor = usernameLabelGray;
        
        self.commentLabel = [[UILabel alloc] init];
        self.commentLabel.numberOfLines = 0;
        self.commentLabel.backgroundColor = commentLabelGray;
        
        for (UIView *view in @[self.mediaImageView, self.usernameAndCaptionLabel, self.commentLabel]) {
            [self.contentView addSubview:view];
        }
    }
    return self;
}


// the method below loads all the text formatting options and colours and fonts once at the start of execution

+ (void)load {
    lightFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:11];
    boldFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:11];
    usernameLabelGray = [UIColor colorWithRed:0.933 green:0.933 blue:0.933 alpha:1]; /*#eeeeee*/
    commentLabelGray = [UIColor colorWithRed:0.898 green:0.898 blue:0.898 alpha:1]; /*#e5e5e5*/
    linkColor = [UIColor colorWithRed:0.345 green:0.314 blue:0.427 alpha:1]; /*#58506d*/
    
    NSMutableParagraphStyle *mutableParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    mutableParagraphStyle.headIndent = 20.0;
    mutableParagraphStyle.firstLineHeadIndent = 20.0;
    mutableParagraphStyle.tailIndent = -20.0;
    mutableParagraphStyle.paragraphSpacingBefore = 5;
    
    //assignment29 to right align every second comment
    
    mutableParagraphStyle.alignment = NSTextAlignmentLeft;
    
    paragraphStyle = mutableParagraphStyle;

}

- (NSAttributedString *) usernameAndCaptionString {
    // #1
    CGFloat usernameFontSize = 15;
    
    // #2 - Make a string that says "username caption"
    NSString *baseString = [NSString stringWithFormat:@"%@ %@", self.mediaItem.user.userName, self.mediaItem.caption];
    
    // #3 - Make an attributed string, with the "username" bold
    NSMutableAttributedString *mutableUsernameAndCaptionString = [[NSMutableAttributedString alloc] initWithString:baseString attributes:@{NSFontAttributeName : [lightFont fontWithSize:usernameFontSize], NSParagraphStyleAttributeName : paragraphStyle}];
    
    // #4
    NSRange usernameRange = [baseString rangeOfString:self.mediaItem.user.userName];
    [mutableUsernameAndCaptionString addAttribute:NSFontAttributeName value:[boldFont fontWithSize:usernameFontSize] range:usernameRange];
    
    
    // Assignment 29 set kerning - i.e. set space inbetween characters
    
    float spacing = 5.0f;
    
    [mutableUsernameAndCaptionString addAttribute:NSKernAttributeName value:@(spacing) range:NSMakeRange(0, [self.mediaItem.caption length])];
    
    [mutableUsernameAndCaptionString addAttribute:NSForegroundColorAttributeName value:linkColor range:usernameRange];
    
    return mutableUsernameAndCaptionString;

}

- (NSAttributedString *) commentString {
    NSMutableAttributedString *commentString = [[NSMutableAttributedString alloc] init];
    
    for (Comment *comment in self.mediaItem.comments) {
        // Make a string that says "username comment" followed by a line break
        NSString *baseString = [NSString stringWithFormat:@"%@ %@\n", comment.from.userName, comment.text];
     
        
        // Make an attributed string, with the "username" bold
        
        NSMutableAttributedString *oneCommentString = [[NSMutableAttributedString alloc] initWithString:baseString attributes:@{NSFontAttributeName : lightFont, NSParagraphStyleAttributeName : paragraphStyle}];
       
        NSRange usernameRange = [baseString rangeOfString:comment.from.userName];
        [oneCommentString addAttribute:NSFontAttributeName value:boldFont range:usernameRange];
        
            
        if ([self.mediaItem.comments indexOfObject:comment] == 0) // if this is the first comment then make it orange
        
        {
            NSRange firstCommentRange = [baseString rangeOfString:comment.text];
                
            [oneCommentString addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor] range:firstCommentRange];
           
        }
        
        // Assignment 29 right align every other comment
               
        if ([self.mediaItem.comments indexOfObject:comment] % 2 == 0)
        
        {
            
          NSMutableParagraphStyle *mutableParagraphStyle2 = [[NSMutableParagraphStyle alloc] init];
            mutableParagraphStyle2.headIndent = 20.0;
            mutableParagraphStyle2.firstLineHeadIndent = 20.0;
            mutableParagraphStyle2.tailIndent = -20.0;
            mutableParagraphStyle2.paragraphSpacingBefore = 5;

            mutableParagraphStyle2.alignment = NSTextAlignmentRight;
            
            paragraphStyleRight = mutableParagraphStyle2;
            
            // do not use the alternateCommentRange below as you need the whole lie including the bold username at the start in order to get it right aligned
            // instead use the NSMakeRange(0, baseString.length) shown below
            // NSRange alternateCommentRange = [baseString rangeOfString:comment.text];
            
            [oneCommentString addAttribute:NSParagraphStyleAttributeName value:mutableParagraphStyle2 range:NSMakeRange(0, baseString.length)];
            
        }
        
        [commentString appendAttributedString:oneCommentString];
        
    }
    
    return commentString;
}

        
- (CGSize) sizeOfString:(NSAttributedString *)string {
    CGSize maxSize = CGSizeMake(CGRectGetWidth(self.contentView.bounds) - 40, 0.0);
    CGRect sizeRect = [string boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    sizeRect.size.height += 20;
    sizeRect = CGRectIntegral(sizeRect);
    return sizeRect.size;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    if (!self.mediaItem) {
        return;
    }
    
    CGFloat imageHeight = self.mediaItem.image.size.height / self.mediaItem.image.size.width * CGRectGetWidth(self.contentView.bounds);
    self.mediaImageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.contentView.bounds), imageHeight);
    
    CGSize sizeOfUsernameAndCaptionLabel = [self sizeOfString:self.usernameAndCaptionLabel.attributedText];
    self.usernameAndCaptionLabel.frame = CGRectMake(0, CGRectGetMaxY(self.mediaImageView.frame), CGRectGetWidth(self.contentView.bounds), sizeOfUsernameAndCaptionLabel.height);
    
    CGSize sizeOfCommentLabel = [self sizeOfString:self.commentLabel.attributedText];
    self.commentLabel.frame = CGRectMake(0, CGRectGetMaxY(self.usernameAndCaptionLabel.frame), CGRectGetWidth(self.bounds), sizeOfCommentLabel.height);
    
    // Hide the line between cells
    self.separatorInset = UIEdgeInsetsMake(0, CGRectGetWidth(self.bounds)/2.0, 0, CGRectGetWidth(self.bounds)/2.0);

}

- (void) setMediaItem:(Media *)mediaItem {
    _mediaItem = mediaItem;
    self.mediaImageView.image = _mediaItem.image;
    self.usernameAndCaptionLabel.attributedText = [self usernameAndCaptionString];
    self.commentLabel.attributedText = [self commentString];

}

+ (CGFloat) heightForMediaItem:(Media *)mediaItem width:(CGFloat)width {
    // Make a cell
    MediaTableViewCell *layoutCell = [[MediaTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"layoutCell"];
    
    // Set it to the given width, and the maximum possible height
    layoutCell.frame = CGRectMake(0, 0, width, CGFLOAT_MAX);
    
    // Give it the media item
    layoutCell.mediaItem = mediaItem;
    
    // Make it adjust the image view and labels
    [layoutCell layoutSubviews];
    
    // The height will be wherever the bottom of the comments label is
    return CGRectGetMaxY(layoutCell.commentLabel.frame);

}



// the code below was present when the class was set up and had above it the -(void)awakeFromNib method that was deleted
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
