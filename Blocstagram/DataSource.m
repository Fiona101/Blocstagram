//
//  DataSource.m
//  Blocstagram
//
//  Created by Fiona Alpe on 8/3/16.
//  Copyright © 2016 Fiona Alpe. All rights reserved.
//

#import "DataSource.h"
#import "User.h"
#import "Media.h"
#import "Comment.h"
#import "LoginViewController.h"


@interface DataSource () {
    
    NSMutableArray *_mediaItems;

}

@property (nonatomic, strong) NSString *accessToken;

@property (nonatomic, strong) NSArray *mediaItems;

@property (nonatomic, assign) BOOL isRefreshing;

@property (nonatomic, assign) BOOL isLoadingOlderItems;

@property (nonatomic, assign) BOOL thereAreNoMoreOlderMessages;

@end


@implementation DataSource


+ (instancetype) sharedInstance {
    
    static dispatch_once_t once;
    
    static id sharedInstance;
    
    dispatch_once(&once, ^{
        
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype) init {
    self = [super init];
    
    if (self) {
        
        // checkpoint 33 remove the random data and use the Instagram login
        // [self addRandomData];
    
    [self registerForAccessTokenNotification];
    
    }
    
    return self;
}

- (void) registerForAccessTokenNotification {
    
    [[NSNotificationCenter defaultCenter] addObserverForName:LoginViewControllerDidGetAccessTokenNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        
        self.accessToken = note.object;
        
        // Got a token; populate the initial data
        
        [self populateDataWithParameters:nil completionHandler:nil];
    }];
}


#pragma mark - Key/Value Observing

- (NSUInteger) countOfMediaItems {
    return self.mediaItems.count;
}

- (id) objectInMediaItemsAtIndex:(NSUInteger)index {
    return [self.mediaItems objectAtIndex:index];
}

- (NSArray *) mediaItemsAtIndexes:(NSIndexSet *)indexes {
    return [self.mediaItems objectsAtIndexes:indexes];
}

- (void) insertObject:(Media *)object inMediaItemsAtIndex:(NSUInteger)index {
    [_mediaItems insertObject:object atIndex:index];
}

- (void) removeObjectFromMediaItemsAtIndex:(NSUInteger)index {
    [_mediaItems removeObjectAtIndex:index];
}

- (void) replaceObjectInMediaItemsAtIndex:(NSUInteger)index withObject:(id)object {
    [_mediaItems replaceObjectAtIndex:index withObject:object];
}


- (void) deleteMediaItem:(Media *)item {
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
    [mutableArrayWithKVO removeObject:item];
}


#pragma mark - Completion Handler


- (void) requestNewItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler {
    
    self.thereAreNoMoreOlderMessages = NO;
    
    // #1
    if (self.isRefreshing == NO) {
        
        self.isRefreshing = YES;
        
        
        //
        // TODO: Add images
        
        
        NSString *minID = [[self.mediaItems firstObject] idNumber];
        NSDictionary *parameters;
        
        if (minID) {
            parameters = @{@"min_id": minID};
        }
        
        [self populateDataWithParameters:parameters completionHandler:^(NSError *error) {
            self.isRefreshing = NO;
            
            if (completionHandler) {
                completionHandler(error);
            }
        }];
    }
}


- (void) requestOldItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler {
    
            if (self.isLoadingOlderItems == NO && self.thereAreNoMoreOlderMessages == NO) {
                 
                self.isLoadingOlderItems = YES;
        
        // TODO: Add images
                
        NSString *maxID = [[self.mediaItems lastObject] idNumber];
        NSDictionary *parameters;
        
            if (maxID) {
                    parameters = @{@"max_id": maxID};
            
                }
                    [self populateDataWithParameters:parameters completionHandler:^(NSError *error) {
                    
                        self.isLoadingOlderItems = NO;
                        
                        if (completionHandler) {
                        completionHandler(error);
                        }
                    }];
            
            }
    }



+ (NSString *) instagramClientID {
    
    return @"573efd3ee80647caae1caeaaab5ec70d";
    
}

    
- (void) populateDataWithParameters:(NSDictionary *)parameters completionHandler:(NewItemCompletionBlock)completionHandler {
    
    if (self.accessToken) {
    
        // only try to get the data if there's an access token
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
            // do the network request in the background, so the UI doesn't lock up
            
            NSMutableString *urlString = [NSMutableString stringWithFormat:@"https://api.instagram.com/v1/users/self/media/recent/?access_token=%@", self.accessToken];
            
            for (NSString *parameterName in parameters) {
            
                // for example, if dictionary contains {count: 50}, append `&count=50` to the URL
                [urlString appendFormat:@"&%@=%@", parameterName, parameters[parameterName]];
            }
            
            NSURL *url = [NSURL URLWithString:urlString];
            
            if (url) {
                
                NSURLRequest *request = [NSURLRequest requestWithURL:url];
                
                // NSURLResponse *response;
                
                // NSError *webError;  with NSURLSession this is now error
    
                
                // NSData *responseData = [NSURLSession dataTaskWithRequest:request returningResponse:&response error:&webError];
                
                
                // attempt change for NSURLSession
                
                
            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
            NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
                NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    
                if (data) {
                        
                    NSError *jsonError;
                        
                    NSDictionary *feedDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                        
                if (feedDictionary) {
                            
                    dispatch_async(dispatch_get_main_queue(), ^{
                                
                    // done networking, go back on the main thread
                    
                    [self parseDataFromFeedDictionary:feedDictionary fromRequestWithParameters:parameters];
                        
                            if (completionHandler) {
                            
                                completionHandler(nil);
                            }
                        });
                
                    } else if (completionHandler) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                        completionHandler(jsonError);
                        });
                    }
                    
                } else if (completionHandler) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionHandler(error);
                    });
                
                }
                
                }];
                
                // below resume put in as it makes it work with the NSURLSession
                [dataTask resume];
                
            }
        });
    }
}

- (void) parseDataFromFeedDictionary:(NSDictionary *) feedDictionary fromRequestWithParameters:(NSDictionary *)parameters {
    
    NSArray *mediaArray = feedDictionary[@"data"];
    
    NSMutableArray *tmpMediaItems = [NSMutableArray array];
    
    for (NSDictionary *mediaDictionary in mediaArray) {
        Media *mediaItem = [[Media alloc] initWithDictionary:mediaDictionary];
        
        if (mediaItem) {
            [tmpMediaItems addObject:mediaItem];
            
            [self downloadImageForMediaItem:mediaItem];
        
            }
        }
    
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
    
    if (parameters[@"min_id"]) {
        // This was a pull-to-refresh request
        
        NSRange rangeOfIndexes = NSMakeRange(0, tmpMediaItems.count);
        
        NSIndexSet *indexSetOfNewObjects = [NSIndexSet indexSetWithIndexesInRange:rangeOfIndexes];
        
        [mutableArrayWithKVO insertObjects:tmpMediaItems atIndexes:indexSetOfNewObjects];
        
            } else if (parameters[@"max_id"]) {
                // This was an infinite scroll request
        
                if (tmpMediaItems.count == 0) {
                    // disable infinite scroll, since there are no more older messages
                    self.thereAreNoMoreOlderMessages = YES;
                
            } else {
                
                [mutableArrayWithKVO addObjectsFromArray:tmpMediaItems];
            }
    
            } else {
                
                [self willChangeValueForKey:@"mediaItems"];
                self.mediaItems = tmpMediaItems;
                [self didChangeValueForKey:@"mediaItems"];
    }

}

- (void) downloadImageForMediaItem:(Media *)mediaItem {
    
    if (mediaItem.mediaURL && !mediaItem.image) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
            
            NSURLRequest *request = [NSURLRequest requestWithURL:mediaItem.mediaURL];
            NSURLResponse *response;
            
            NSError *error;
            
            //NSData *imageData;
            
            // codefrom checkpoint 34 below line
            
            NSData *imageData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            
            /*/ NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
            
            NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
            
            NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable imageData, NSURLResponse * _Nullable response, NSError * _Nullable error) { /*/
            
            if (imageData) {
                UIImage *image = [UIImage imageWithData:imageData];
                
                if (image) {
                    mediaItem.image = image;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
                        
                        NSUInteger index = [mutableArrayWithKVO indexOfObject:mediaItem];
                        
                        [mutableArrayWithKVO replaceObjectAtIndex:index withObject:mediaItem];
                        
                        
                    });
                    
    
                    } else {
                         NSLog(@"Error downloading image: %@", error);
                    }
            };
                
                     // below resume put in as it makes it work with the NSURLSession
                     //[dataTask resume];
                     
            //}];
            
        });
    }
}

@end



