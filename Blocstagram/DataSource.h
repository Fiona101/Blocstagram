//
//  DataSource.h
//  Blocstagram
//
//  Created by Fiona Alpe on 8/3/16.
//  Copyright © 2016 Fiona Alpe. All rights reserved.
//

#import <Foundation/Foundation.h>


@class Media;

typedef void (^NewItemCompletionBlock)(NSError *error);
typedef void (^OnComplete) (NSData *responseData);


@interface DataSource : NSObject


+(instancetype) sharedInstance;


@property (nonatomic, strong, readonly) NSArray *mediaItems;
@property (nonatomic, strong, readonly) NSString *accessToken;

- (void) deleteMediaItem:(Media *)item;


- (void) requestNewItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler;

- (void) requestOldItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler;

- (void) downloadImageForMediaItem:(Media *)mediaItem;

+ (NSString *) instagramClientID;


@end
