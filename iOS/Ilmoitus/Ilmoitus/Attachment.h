//
//  Attachment.h
//  Ilmoitus
//
//  Created by Sjors Boom on 13/05/14.
//  Copyright (c) 2014 42IN12EWa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Attachment : NSObject

@property (nonatomic, strong) NSString *data;
@property (nonatomic, strong) NSString *name;

-(void)setAttachmentData:(NSObject *)dataObject;

-(void)SetAttachmentDataFromImage:(UIImage *)image;

@end