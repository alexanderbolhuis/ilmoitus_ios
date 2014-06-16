//
//  DeclarationLine.h
//  Ilmoitus
//
//  Created by Sjors Boom on 24/04/14.
//  Copyright (c) 2014 42IN12EWa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeclarationSubType.h"
#import "DeclarationType.h"

@interface DeclarationLine : NSObject

@property (strong, nonatomic) NSString *date;
@property (nonatomic) float cost;
@property (nonatomic, strong) DeclarationSubType *subtype;
@property (nonatomic, strong) DeclarationType *type;
@property (nonatomic, strong) NSString *description;


@end