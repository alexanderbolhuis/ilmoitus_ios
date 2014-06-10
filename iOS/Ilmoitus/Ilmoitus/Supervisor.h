//
//  Supervisor.h
//  Ilmoitus
//
//  Created by Alexander Bolhuis on 14-05-14.
//  Copyright (c) 2014 42IN12EWa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Supervisor : NSObject
@property (nonatomic) int64_t ident;
@property (strong, nonatomic) NSString *class_name;
@property (strong, nonatomic) NSString *first_name;
@property (strong, nonatomic) NSString *last_name;
@property (strong, nonatomic) NSString *email;
@property (nonatomic) int employee_number;
@property (nonatomic) int64_t department;
@property (nonatomic) int64_t supervisor;
@property (nonatomic) float max_declaration_price;
@end
