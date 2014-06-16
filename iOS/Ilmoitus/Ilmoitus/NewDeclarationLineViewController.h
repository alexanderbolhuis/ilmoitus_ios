//
//  NewDeclarationLineViewController.h
//  Ilmoitus
//
//  Created by Alexander Bolhuis on 15-05-14.
//  Copyright (c) 2014 42IN12EWa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeclarationLine.h"
#import "StateType.h"

@interface NewDeclarationLineViewController : UIViewController <UITextFieldDelegate, UIPickerViewDelegate>

-(void)setModus:(StateType)state;

@property (nonatomic) StateType state;
@property DeclarationLine *declarationLine;
@end