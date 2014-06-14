//
//  AttachmentsTableViewController.h
//  Ilmoitus
//
//  Created by Sjors Boom on 13/06/14.
//  Copyright (c) 2014 42IN12EWa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Declaration.h"
#import "StateType.h"

@interface AttachmentsTableViewController : UITableViewController

@property (nonatomic, strong) Declaration *declaration;
@property (nonatomic) StateType state;

@end
