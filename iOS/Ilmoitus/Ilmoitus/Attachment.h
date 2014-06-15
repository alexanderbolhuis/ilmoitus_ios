//
//  Attachment.h
//  Ilmoitus
//
//  Created by Sjors Boom on 13/05/14.
//  Copyright (c) 2014 42IN12EWa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Attachment : NSObject

@property (nonatomic) int64_t ident;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *data;
@property (nonatomic, strong) NSString *name;

-(NSString *)setAttachmentData:(NSObject *)dataObject;

-(NSString *)SetAttachmentDataFromImage:(UIImage *)image;

@end