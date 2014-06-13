//
//  NewAttachmentViewController.h
//  Ilmoitus
//
//  Created by Sjors Boom on 13/06/14.
//  Copyright (c) 2014 42IN12EWa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Attachment.h"
#import "StateType.h"

@interface NewAttachmentViewController : UIViewController< UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    UIImagePickerController *imagePicker;
}

@property (nonatomic) StateType state;
@property Attachment *attachment;

-(void)setModus:(StateType)state;

@end
