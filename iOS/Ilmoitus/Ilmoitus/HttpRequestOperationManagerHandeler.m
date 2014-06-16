//
//  NewRequestOperationManager.m
//  Ilmoitus
//
//  Created by Administrator on 15/06/14.
//  Copyright (c) 2014 42IN12EWa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpRequestOperationManagerHandeler.h"

@implementation HttpRequestOperationManagerHandeler

+(AFHTTPRequestOperationManager*)createNewHttpRequestOperationManager
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager.requestSerializer setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"token"] forHTTPHeaderField:@"Authorization"];
    
    [manager.reachabilityManager startMonitoring];
    
    return manager;
}

+ (void) handelErrorCode: (AFHTTPRequestOperation*) operation: (NSError*) error: (UIViewController *) sourceView
{
    // extrext the user error messages from the server response
    NSData* data = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:data
                          
                          options:kNilOptions
                          error:&error];
    
    NSString *errorMessage = json[@"user_message"];
    data = NULL;
    json = NULL;
    
    switch (operation.response.statusCode)
    {
        case 400: // Bad Request
            // NSLog(@"Request Error 400: %@", error);
            [HttpRequestOperationManagerHandeler showErrorMessage:@"Verkeerde aanvraag" :errorMessage];
            break;
            
        case 401: // Unauthorized
            // NSLog(@"Request Error 401: %@", error);
            [HttpRequestOperationManagerHandeler showErrorMessage:@"Onvoldoende rechten" :errorMessage];
            
            if ([errorMessage  isEqual: @"U bent niet ingelogd"])
            {
                [sourceView.tabBarController setSelectedIndex:[sourceView.tabBarController.tabBar.items count]-1];
            }
            break;
            
        case 403: // Forbidden
            // NSLog(@"Request Error 403: %@", error);
            [HttpRequestOperationManagerHandeler showErrorMessage:@"Aanvraag niet toegestaan" :errorMessage];
            break;
            
        case 404: // Not Found
            // NSLog(@"Request Error 404: %@", error);
            [HttpRequestOperationManagerHandeler showErrorMessage:@"Niet gevonden" :errorMessage];
            break;
            
        case 405: // Method Not Allowed
            // NSLog(@"Request Error 405: %@", error);
            [HttpRequestOperationManagerHandeler showErrorMessage:@"Aanvraag niet toegestaan" :errorMessage];
            break;
            
        case 406: // Not Acceptable
            // NSLog(@"Request Error 406: %@", error);
            [HttpRequestOperationManagerHandeler showErrorMessage:@"Aanvraag niet toegestaan" :errorMessage];
            break;
            
        case 407: // Proxy Authentication Required
            // NSLog(@"Request Error 407: %@", error);
            [HttpRequestOperationManagerHandeler showErrorMessage:@"Onvoldoende rechten op proxy" :errorMessage];
            break;
            
        case 408: // Request Timeout
            // NSLog(@"Request Error 408: %@", error);
            [HttpRequestOperationManagerHandeler showErrorMessage:@"Aanvraag tijd voorbij" :errorMessage];
            break;
            
        case 409: // Conflict
            // NSLog(@"Request Error 409: %@", error);
            [HttpRequestOperationManagerHandeler showErrorMessage:@"Conflict op verzonden data" :errorMessage];
            break;
            
        case 410: // Gone
            // NSLog(@"Request Error 410: %@", error);
            [HttpRequestOperationManagerHandeler showErrorMessage:@"Actie verdwenen" :errorMessage];
            break;
            
        case 411: // Length Required
            // NSLog(@"Request Error 411: %@", error);
            [HttpRequestOperationManagerHandeler showErrorMessage:@"Onjuiste waardes" :errorMessage];
            break;
            
        case 412: // Precondition Failed
            // NSLog(@"Request Error 412: %@", error);
            [HttpRequestOperationManagerHandeler showErrorMessage:@"Randvoorwaarde onjuist" :errorMessage];
            break;
            
        case 413: // Request Entity Too Large
            // NSLog(@"Request Error 413: %@", error);
            [HttpRequestOperationManagerHandeler showErrorMessage:@"Aanvraag entiteit onjuist" :errorMessage];
            break;
            
        case 414: // Request-URI Too Long
            // NSLog(@"Request Error 414: %@", error);
            [HttpRequestOperationManagerHandeler showErrorMessage:@"Aanvraag url te lang" :errorMessage];
            break;
            
            
        case 415: // Unsupported Media Type
            // NSLog(@"Request Error 415: %@", error);
            [HttpRequestOperationManagerHandeler showErrorMessage:@"media type niet ondersteund" :errorMessage];
            break;
            
        case 416: // Requested Range Not Satisfiable
            // NSLog(@"Request Error 416: %@", error);
            [HttpRequestOperationManagerHandeler showErrorMessage:@"Aanvraag lengte voldoet niet" :errorMessage];
            break;
            
        case 417: // Expectation Failed
            // NSLog(@"Request Error 417: %@", error);
            [HttpRequestOperationManagerHandeler showErrorMessage:@"Onbekende verwachting" :errorMessage];
            break;
            
        case 500: // Internal Server Error
            // NSLog(@"Request Error 500: %@", error);
            [HttpRequestOperationManagerHandeler showErrorMessage:@"Interne server error" :errorMessage];
            break;
            
        case 501: // Not Implemented
            // NSLog(@"Request Error 501: %@", error);
            [HttpRequestOperationManagerHandeler showErrorMessage:@"Niet geïmplementeerd" :errorMessage];
            break;
            
        case 502: // Bad Gateway
            // NSLog(@"Request Error 502: %@", error);
            break;
            
        case 503: // Service Unavailable
            // NSLog(@"Request Error 503: %@", error);
            [HttpRequestOperationManagerHandeler showErrorMessage:@"Server niet bereikbaar" :errorMessage];
            break;
            
        case 504: // Gateway Timeout
            // NSLog(@"Request Error 504: %@", error);
            break;
            
        case 505: // HTTP Version Not Supported
            // NSLog(@"Request Error 505: %@", error);
            [HttpRequestOperationManagerHandeler showErrorMessage:@"HTML versie niet ondersteund" :errorMessage];
            break;
            
        default:
            // NSLog(@"Request Error : %@", error);
            [HttpRequestOperationManagerHandeler showErrorMessage:@"Fout" :errorMessage];
            break;
    }
}


+ (void) showErrorMessage: (NSString*)errorTitle:(NSString*)errorMessage
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:errorTitle
                                                    message:errorMessage
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

@end
