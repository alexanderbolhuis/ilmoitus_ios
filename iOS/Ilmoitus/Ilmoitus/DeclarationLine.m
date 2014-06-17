//
//  DeclarationLine.m
//  Ilmoitus
//
//  Created by Sjors Boom on 24/04/14.
//  Copyright (c) 2014 42IN12EWa. All rights reserved.
//

#import "DeclarationLine.h"

@implementation DeclarationLine

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.subtype = [[DeclarationSubType alloc]init];
        self.type = [[DeclarationType alloc] init];
    }
    return self;
}

-(void)setDate:(NSString *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy-MM-dd' 'HH:mm:ss.S";
    NSDate *dateFromBE = [formatter dateFromString:date];
    
    if (dateFromBE == nil) {
        formatter.dateFormat = @"yyyy-MM-dd' 'HH:mm:ss";
        dateFromBE = [formatter dateFromString:date];
    }
    
    formatter.dateFormat = @"yyyy-MM-dd' 'HH:mm:ss.S";
    NSString *dateFromBEString = [formatter stringFromDate:dateFromBE];
    
    _date = dateFromBEString;
}

@end