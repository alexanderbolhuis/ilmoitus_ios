//
//  NewAttachmentViewController.m
//  Ilmoitus
//
//  Created by Sjors Boom on 13/06/14.
//  Copyright (c) 2014 42IN12EWa. All rights reserved.
//

#import "NewAttachmentViewController.h"

@interface NewAttachmentViewController ()
@property (weak, nonatomic) IBOutlet UIButton *cancel;
@property (weak, nonatomic) IBOutlet UIButton *select;
@property (weak, nonatomic) IBOutlet UIButton *add;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttonCollection;
@property (weak, nonatomic) IBOutlet UIImageView *image;

@end

@implementation NewAttachmentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setModus:self.state];
    
    self.image.contentMode = UIViewContentModeScaleAspectFit;
    self.image.clipsToBounds = YES;
    self.image.image = self.attachment.image;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self addAttachmentFromPhotoLibrary];
            break;
        case 1:
            [self addAttachmentFromCamera];
            break;
        default:
            break;
    }
}

- (IBAction)addAttachment:(id)sender {
    [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Close" destructiveButtonTitle:nil otherButtonTitles:@"Choose existing", @"Create new",  nil]showInView:self.view];
}

-(void)addAttachmentFromPhotoLibrary
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentImagePicker];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Photo Library is not available" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
        [alert show];
    }
}

-(void)addAttachmentFromCamera
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentImagePicker];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Camera is not available" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
        [alert show];
    }
}

-(void)presentImagePicker
{
    [self presentViewController:imagePicker animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSURL *imageURL = (NSURL *)[info valueForKey:UIImagePickerControllerReferenceURL];
    
    UIImage *image = (UIImage *)[info valueForKey:UIImagePickerControllerOriginalImage];
    
    [self.image setImage:image];
    
    self.attachment = [[Attachment alloc]init];
    self.attachment.image = image;
    [self.attachment SetAttachmentDataFromImage:image];
    self.attachment.name = [imageURL path];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)setModus:(StateType)state
{
    switch (state) {
        case EDIT:
            [self setModusEdit];
            break;
        case VIEW:
            [self setModusView];
            break;
        default:
            [self setModusNew];
            break;
    }
}

-(void)setModusNew
{
    [self setupImagePicker];
    self.add.titleLabel.text = @"Toevoegen";
    self.title = @"attachment toevoegen";
}

-(void)setModusEdit
{
    [self setModusNew];
    self.add.titleLabel.text = @"Updaten";
    self.title = @"attachment aanpassen";
}

-(void)setModusView
{
    self.title =@"attachment bekijken";
    [self tearDownInput];
}


-(void)setupImagePicker
{
    imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.delegate = self;
}

-(void) tearDownInput
{
    for (UIButton *button in self.buttonCollection)
    {
        button.hidden = true;
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    if (sender == self.cancel)
    {
        self.attachment = nil;
    }
}
@end
