//
//  SecondViewController.h
//  Ilmoitus
//
//  Created by Alexander Bolhuis on 22-04-14.
//  Copyright (c) 2014 42IN12EWa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Declaration.h"
#import "StateType.h"

@interface NewDeclarationViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
@property Declaration *declaration;
@property (nonatomic) StateType state;
-(void)getSupervisorList;
@end
