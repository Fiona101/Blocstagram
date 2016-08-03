//
//  DataSource.h
//  Blocstagram
//
//  Created by Fiona Alpe on 8/3/16.
//  Copyright © 2016 Fiona Alpe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataSource : NSObject

+(instancetype) sharedInstance;

@property (nonatomic, strong, readonly) NSArray *mediaItems;


@end
