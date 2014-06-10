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
    }
    return self;
}

@end