//
//  DeclarationSubTypes.h
//  Ilmoitus
//
//  Created by Administrator on 23/05/14.
//  Copyright (c) 2014 42IN12EWa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeclarationSubType : NSObject

@property (nonatomic) int64_t ident;
@property (strong, nonatomic) NSString *subTypeName;
@property (strong, nonatomic) NSString *subTypeDescription;
@property (nonatomic) float subTypeMaxCost;


@end
