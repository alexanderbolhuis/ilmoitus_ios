//
//  HttpResponseHandler.h
//  Ilmoitus
//
//  Created by Alexander Bolhuis on 17-06-14.
//  Copyright (c) 2014 42IN12EWa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpResponseHandler : NSObject
+ (AFHTTPRequestOperationManager *)createNewHttpRequestOperationManager;
+ (void) handelErrorCode:(AFHTTPRequestOperation *)operation :(NSError *)error :(UIViewController *) sourceView;
+ (void) showErrorMessageTitle:(NSString *)errorTitle Message:(NSString *)errorMessage;
+ (void) showSuccessMessageTitle:(NSString *)successTitle Message:(NSString *)successMessage;
@end
