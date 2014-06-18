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
    
    self.image.contentMode = UIViewContentModeScaleAspectFit;
    self.image.clipsToBounds = YES;
    self.image.image = self.attachment.image;
    [self setModus:self.state];
}

-(void)reloadFile
{
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:self.attachment.name];
    self.image.image = [UIImage imageWithContentsOfFile:path];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:self.attachment.name];
    self.image.image = [UIImage imageWithContentsOfFile:path];  
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
    NSLog(@"%@", self.attachment.name);
    
    if(![self.attachment.name isEqualToString:@""] && self.attachment != nil && self.state != NEW ){
        [self openAttachmentFile:self.attachment.name];
    } else {
        [[[UIActionSheet alloc] initWithTitle:@"Maak een keuze:" delegate:self cancelButtonTitle:@"Annuleren" destructiveButtonTitle:nil otherButtonTitles:@"Kies bestaande foto", @"Maak nieuwe fote",  nil]showInView:self.view];
    }
}

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller{
    return self;
}

-(void)openAttachmentFile:(NSString *)filename
{
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
    self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:path]];
    
    // Configure Document Interaction Controller
    [self.documentInteractionController setDelegate:self];
    
    [self.documentInteractionController presentOptionsMenuFromRect:self.view.frame inView:self.view animated:YES];
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
        #warning show error HTTPResponehandler
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Foto bibliotheek is niet beschikbaar" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
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
        #warning show error HTTPResponehandler
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Camera is niet beschikbaar" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
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
    
    NSString *pathname = [[imageURL path] stringByReplacingOccurrencesOfString:@"/" withString:@""];
    NSString *name = [NSString stringWithFormat:@"%i%@", (arc4random() % 999), pathname];
    self.attachment.name = name;
    
    NSData* imageData = UIImageJPEGRepresentation(image, 1.0);
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:self.attachment.name];
    [imageData writeToFile:path atomically:NO];
    
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
    self.cancel.titleLabel.text = @"Annuleren";
}

-(void)setModusEdit
{
    [self setModusNew];
    [self.select setTitle:@"Bijlage openen" forState:UIControlStateNormal];
    [self.select setTitle:@"Bijlage openen" forState:UIControlStateHighlighted];
    [self.select setTitle:@"Bijlage openen" forState:UIControlStateDisabled];
    [self.select setTitle:@"Bijlage openen" forState:UIControlStateSelected];
    
    [self.add setTitle:@"Updaten" forState:UIControlStateNormal];
    [self.add setTitle:@"Updaten" forState:UIControlStateHighlighted];
    [self.add setTitle:@"Updaten" forState:UIControlStateDisabled];
    [self.add setTitle:@"Updaten" forState:UIControlStateSelected];
    
    [self.cancel setTitle:@"Verwijder" forState:UIControlStateNormal];
    [self.cancel setTitle:@"Verwijder" forState:UIControlStateHighlighted];
    [self.cancel setTitle:@"Verwijder" forState:UIControlStateDisabled];
    [self.cancel setTitle:@"Verwijder" forState:UIControlStateSelected];
    
    [self.cancel.titleLabel setTextAlignment: NSTextAlignmentCenter];
    [self.add.titleLabel setTextAlignment: NSTextAlignmentCenter];
    
    [self.navigationItem setTitle:@"Bijlage aanpassen"];
}

-(void)setModusView
{
    [self.navigationItem setTitle:@"Bijlage bekijken"];

    [self.select setTitle:@"Bijlage openen" forState:UIControlStateNormal];
    [self.select setTitle:@"Bijlage openen" forState:UIControlStateHighlighted];
    [self.select setTitle:@"Bijlage openen" forState:UIControlStateDisabled];
    [self.select setTitle:@"Bijlage openen" forState:UIControlStateSelected];
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

-(void)showErrorMessage: (NSString*)errorTitle :(NSString*)errorMessage
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:errorTitle message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alert show];
}


-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if(sender == self.add)
    {
        if(self.attachment.data == nil)
        {
            [self showErrorMessage:@"Geen bijlage" :@"Er is geen bijlage toegevoegd."];
            return NO;
        }
    }
    return YES;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    if (sender == self.cancel)
    {
        self.attachment = nil;
    }
}
@end
