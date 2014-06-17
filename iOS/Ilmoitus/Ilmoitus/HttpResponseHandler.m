//
//  HttpResponseHandler.m
//  Ilmoitus
//
//  Created by Alexander Bolhuis on 17-06-14.
//  Copyright (c) 2014 42IN12EWa. All rights reserved.
//

#import "HttpResponseHandler.h"

@implementation HttpResponseHandler
+(AFHTTPRequestOperationManager *)createNewHttpRequestOperationManager
{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc]init];
    [manager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status)
     {
         switch (status)
         {
             case AFNetworkReachabilityStatusReachableViaWWAN:
             case AFNetworkReachabilityStatusReachableViaWiFi:
                 NSLog(@"Connected to network");
                 break;
             case AFNetworkReachabilityStatusNotReachable:
                 NSLog(@"No internet connection");
                 [HttpResponseHandler showErrorMessageTitle:@"Geen verbinding" Message:@"Kon geen verbinding maken met een netwerk"];
                 break;
             default:
                 NSLog(@"Unknown internet connection");
                 [HttpResponseHandler showErrorMessageTitle:@"Onbekende verbinding" Message:@"Verbonden met een onbekend soort netwerk"];
                 break;
         }
     }];
    
    [manager.reachabilityManager startMonitoring];
    
    return manager;
}

+ (void) handelErrorCode:(AFHTTPRequestOperation *)operation :(NSError *)error :(UIViewController *) sourceView
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
            [HttpResponseHandler showErrorMessageTitle:@"Verkeerde aanvraag" Message:errorMessage];
            break;
            
        case 401: // Unauthorized
            // NSLog(@"Request Error 401: %@", error);
            [HttpResponseHandler showErrorMessageTitle:@"Onvoldoende rechten" Message:errorMessage];
            
            if ([errorMessage  isEqual: @"U bent niet ingelogd"])
            {
                [sourceView.tabBarController setSelectedIndex:[sourceView.tabBarController.tabBar.items count]-1];
            }
            break;
            
        case 403: // Forbidden
            // NSLog(@"Request Error 403: %@", error);
            [HttpResponseHandler showErrorMessageTitle:@"Aanvraag niet toegestaan" Message:errorMessage];
            break;
            
        case 404: // Not Found
            // NSLog(@"Request Error 404: %@", error);
            [HttpResponseHandler showErrorMessageTitle:@"Niet gevonden" Message:errorMessage];
            break;
            
        case 405: // Method Not Allowed
            // NSLog(@"Request Error 405: %@", error);
            [HttpResponseHandler showErrorMessageTitle:@"Aanvraag niet toegestaan" Message:errorMessage];
            break;
            
        case 406: // Not Acceptable
            // NSLog(@"Request Error 406: %@", error);
            [HttpResponseHandler showErrorMessageTitle:@"Aanvraag niet toegestaan" Message:errorMessage];
            break;
            
        case 407: // Proxy Authentication Required
            // NSLog(@"Request Error 407: %@", error);
            [HttpResponseHandler showErrorMessageTitle:@"Onvoldoende rechten op proxy" Message:errorMessage];
            break;
            
        case 408: // Request Timeout
            // NSLog(@"Request Error 408: %@", error);
            [HttpResponseHandler showErrorMessageTitle:@"Aanvraag tijd voorbij" Message:errorMessage];
            break;
            
        case 409: // Conflict
            // NSLog(@"Request Error 409: %@", error);
            [HttpResponseHandler showErrorMessageTitle:@"Conflict op verzonden data" Message:errorMessage];
            break;
            
        case 410: // Gone
            // NSLog(@"Request Error 410: %@", error);
            [HttpResponseHandler showErrorMessageTitle:@"Actie verdwenen" Message:errorMessage];
            break;
            
        case 411: // Length Required
            // NSLog(@"Request Error 411: %@", error);
            [HttpResponseHandler showErrorMessageTitle:@"Onjuiste waardes" Message:errorMessage];
            break;
            
        case 412: // Precondition Failed
            // NSLog(@"Request Error 412: %@", error);
            [HttpResponseHandler showErrorMessageTitle:@"Randvoorwaarde onjuist" Message:errorMessage];
            break;
            
        case 413: // Request Entity Too Large
            // NSLog(@"Request Error 413: %@", error);
            [HttpResponseHandler showErrorMessageTitle:@"Aanvraag entiteit onjuist" Message:errorMessage];
            break;
            
        case 414: // Request-URI Too Long
            // NSLog(@"Request Error 414: %@", error);
            [HttpResponseHandler showErrorMessageTitle:@"Aanvraag url te lang" Message:errorMessage];
            break;
            
            
        case 415: // Unsupported Media Type
            // NSLog(@"Request Error 415: %@", error);
            [HttpResponseHandler showErrorMessageTitle:@"Media type niet ondersteund" Message:errorMessage];
            break;
            
        case 416: // Requested Range Not Satisfiable
            // NSLog(@"Request Error 416: %@", error);
            [HttpResponseHandler showErrorMessageTitle:@"Aanvraag lengte voldoet niet" Message:errorMessage];
            break;
            
        case 417: // Expectation Failed
            // NSLog(@"Request Error 417: %@", error);
            [HttpResponseHandler showErrorMessageTitle:@"Onbekende verwachting" Message:errorMessage];
            break;
            
        case 500: // Internal Server Error
            // NSLog(@"Request Error 500: %@", error);
            [HttpResponseHandler showErrorMessageTitle:@"Interne server error" Message:errorMessage];
            break;
            
        case 501: // Not Implemented
            // NSLog(@"Request Error 501: %@", error);
            [HttpResponseHandler showErrorMessageTitle:@"Niet geïmplementeerd" Message:errorMessage];
            break;
            
        case 502: // Bad Gateway
            // NSLog(@"Request Error 502: %@", error);
            break;
            
        case 503: // Service Unavailable
            // NSLog(@"Request Error 503: %@", error);
            [HttpResponseHandler showErrorMessageTitle:@"Server niet bereikbaar" Message:errorMessage];
            break;
            
        case 504: // Gateway Timeout
            // NSLog(@"Request Error 504: %@", error);
            break;
            
        case 505: // HTTP Version Not Supported
            // NSLog(@"Request Error 505: %@", error);
            [HttpResponseHandler showErrorMessageTitle:@"HTML versie niet ondersteund" Message:errorMessage];
            break;
            
        default:
            // NSLog(@"Request Error : %@", error);
            [HttpResponseHandler showErrorMessageTitle:@"Fout" Message:errorMessage];
            break;
    }
}

+ (void) showSuccessMessageTitle:(NSString *)successTitle Message:(NSString *)successMessage
{
    [HttpResponseHandler showAlert:successTitle :successMessage];
}

+ (void) showErrorMessageTitle:(NSString *)errorTitle Message:(NSString *)errorMessage
{
    [HttpResponseHandler showAlert:errorTitle :errorMessage];
}

+(void)showAlert:(NSString *)alertTitle :(NSString *)alertMessage
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                    message:alertMessage
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}
@end
