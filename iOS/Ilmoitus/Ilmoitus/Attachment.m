//
//  Attachment.m
//  Ilmoitus
//
//  Created by Sjors Boom on 13/05/14.
//  Copyright (c) 2014 42IN12EWa. All rights reserved.
//

#import "Attachment.h"

@implementation Attachment

-(NSString *)setAttachmentData:(NSString *)dataString;
{
    self.data = dataString;
    return self.data;
}

-(NSString *)NSDataToDataString:(NSData *)data
{
    return [data base64EncodedStringWithOptions:0];
}

-(NSString *)SetAttachmentDataFromImage:(UIImage *)image
{
    [self setAttachmentData:[NSString stringWithFormat:@"data:image/jpeg;base64,%@", [self NSDataToDataString:UIImageJPEGRepresentation(image, 1.0f)]]];
    return self.data;
}

@end