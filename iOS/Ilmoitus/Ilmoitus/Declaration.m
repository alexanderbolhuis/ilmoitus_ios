//
//  Declaration.m
//  Ilmoitus
//
//  Created by Alexander Bolhuis on 24-04-14.
//  Copyright (c) 2014 42IN12EWa. All rights reserved.
//

#import "Declaration.h"
#import "DeclarationLine.h"

@implementation Declaration

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.lines = [[NSMutableArray alloc]init];
        self.attachments = [[NSMutableArray alloc] init];
        self.assignedTo = [[NSMutableArray alloc]init];
    }
    return self;
}

-(float)calculateTotalPrice
{
    float price = 0.00;
    for (DeclarationLine *line in self.lines) {
        price = price + line.cost;
    }
    
    self.itemsTotalPrice = price;
    
    return self.itemsTotalPrice;
}

-(void)setCreatedAt:(NSString *)createdAt
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy-MM-dd' 'HH:mm:ss.S";
    NSDate *dateFromBE = [formatter dateFromString:createdAt];
    
    if (dateFromBE == nil) {
        formatter.dateFormat = @"yyyy-MM-dd' 'HH:mm:ss";
        dateFromBE = [formatter dateFromString:createdAt];
    }
    
    formatter.dateFormat = @"yyyy-MM-dd' 'HH:mm:ss.S";
    NSString *dateFromBEString = [formatter stringFromDate:dateFromBE];
    
    _createdAt = dateFromBEString;
}

@end
