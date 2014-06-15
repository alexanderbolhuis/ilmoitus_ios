//
//  NewRequestOperationManager.h
//  Ilmoitus
//
//  Created by Administrator on 15/06/14.
//  Copyright (c) 2014 42IN12EWa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpRequestOperationManagerHandeler : NSObject
+(AFHTTPRequestOperationManager*)createNewHttpRequestOperationManager;
+ (void) handelErrorCode: (AFHTTPRequestOperation*) operation: (NSError*) error;
+ (void) showErrorMessage: (NSString*)errorTitle:(NSString*)errorMessage;
@end
