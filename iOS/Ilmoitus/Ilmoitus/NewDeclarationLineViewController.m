//
//  NewDeclarationLineViewController.m
//  Ilmoitus
//
//  Created by Alexander Bolhuis on 15-05-14.
//  Copyright (c) 2014 42IN12EWa. All rights reserved.
//

#import "NewDeclarationLineViewController.h"
#import "Declaration.h"
#import "DeclarationLine.h"
#import "constants.h"
#import "DeclarationType.h"
#import "DeclarationSubType.h"
#import "Attachment.h"
#import "NewDeclarationViewController.h"

@interface NewDeclarationLineViewController ()
@property (weak, nonatomic) IBOutlet UIButton *add;
@property (weak, nonatomic) IBOutlet UIButton *cancel;
@property (weak, nonatomic) IBOutlet UITextField *dateField;
@property (weak, nonatomic) IBOutlet UITextField *typeField;
@property (weak, nonatomic) IBOutlet UITextField *subtypeField;
@property (weak, nonatomic) IBOutlet UITextField *costField;
@property (weak, nonatomic) IBOutlet UITextField *costDecimalField;
@property (weak, nonatomic) IBOutlet UITextField *commentField;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttonCollection;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *inputCollection;

@property (nonatomic) UIDatePicker *datePicker;
@property (nonatomic) UIPickerView *typePicker;
@property (nonatomic) UIPickerView *subTypePicker;
@property (nonatomic) UIToolbar *datePickerToolbar;
@property (nonatomic) UIToolbar *typePickerToolbar;
@property (nonatomic) UIToolbar *subTypePickerToolbar;
@property (nonatomic) UIActionSheet *pickerViewPopup;
@property (nonatomic) NSMutableArray *typeList;
@property (nonatomic) NSMutableArray *subTypeList;
@end

@implementation NewDeclarationLineViewController

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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSURL *imageURL = (NSURL *)[info valueForKey:UIImagePickerControllerReferenceURL];
    
    UIImage *image = (UIImage *)[info valueForKey:UIImagePickerControllerOriginalImage];
    
    self.attachment = [[Attachment alloc]init];
    [self.attachment SetAttachmentDataFromImage:image];
    self.attachment.name = [imageURL path];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)reloadLineData
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    
    if(self.declarationLine == nil)
    {
        NSDate *date = [NSDate date];
        [dateFormat setDateFormat:@"dd-MM-yyyy"];
        NSString *dateString = [dateFormat stringFromDate:date];
        [dateFormat setDateFormat:@"yyyy-MM-dd' 'HH:mm:ss.S"];
        self.declarationLine = [[DeclarationLine alloc] init];
        self.declarationLine.date = [dateFormat stringFromDate:date];
        
        self.dateField.text = dateString;
    }
    else
    {
        NSDate *date =[[NSDate alloc]init];
        [dateFormat setDateFormat:@"yyyy-MM-dd' 'HH:mm:ss.S"];
        date = [dateFormat dateFromString:self.declarationLine.date];
        [dateFormat setDateFormat:@"dd-MM-yyyy"];
        
        self.dateField.text = [dateFormat stringFromDate:date];
        self.commentField.text = self.declarationLine.description;
        int intCost = floorf(self.declarationLine.cost);
        int decimal = roundf(((self.declarationLine.cost - intCost)*100));
        self.costField.text = [NSString stringWithFormat:@"%d", intCost];
        self.costDecimalField.text = [NSString stringWithFormat:@"%02d", decimal];
        self.typeField.text = self.declarationLine.type.mainTypeName;
        self.subtypeField.text = self.declarationLine.subtype.subTypeName;
        [self downLoadSubTypes:self.declarationLine.type.ident];
    }
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
    [self setupInputFields];
    [self setupPickers];
    self.add.titleLabel.text = @"Toevoegen";
    self.title = @"declaratie regel maken";
}

-(void)setModusEdit
{
    [self setModusNew];
    self.add.titleLabel.text = @"Updaten";
    self.title = @"declaratie regel aanpassen";
}

-(void)setModusView
{
    self.title =@"declaratie regel inzien";
    [self tearDownInput];
}

-(void) tearDownInput
{
    for (UIButton *button in self.buttonCollection)
    {
        button.hidden = true;
    }
    for(UITextField *input in self.inputCollection)
    {
        input.enabled = false;
    }
}

-(void)setupImagePicker
{
    imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.delegate = self;
}

-(void)setupPickers
{
    self.dateField.delegate = self;
    self.typeField.delegate = self;
    self.subtypeField.delegate = self;
    // Create date picker
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 44, 0, 0)];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    self.datePicker.hidden = NO;
    self.datePicker.date = [NSDate date];
    
    self.datePickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    self.datePickerToolbar.tintColor = [UIColor whiteColor];
    self.datePickerToolbar.barTintColor = [UIColor colorWithRed:(189/255.0) green:(26/255.0) blue:(47/255.0) alpha:1.0];
    [self.datePickerToolbar sizeToFit];
    
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [barItems addObject:flexSpace];
    
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneDateButtonPressed)];
    [barItems addObject:doneBtn];
    
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelDateButtonPressed)];
    [barItems addObject:cancelBtn];
    
    [self.datePickerToolbar setItems:barItems animated:YES];
    
    // Create type picker
    self.typePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, 0, 0)];
    self.typePicker.hidden = NO;
    self.typePicker.delegate = self;
    
    self.typePicker.dataSource = self;
    
    self.typePickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    self.typePickerToolbar.tintColor = [UIColor whiteColor];
    self.typePickerToolbar.barTintColor = [UIColor colorWithRed:(189/255.0) green:(26/255.0) blue:(47/255.0) alpha:1.0];
    [self.typePickerToolbar sizeToFit];
    
    NSMutableArray *typeBarItems = [[NSMutableArray alloc] init];
    
    [typeBarItems addObject:flexSpace];
    
    UIBarButtonItem *typeDoneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTypeButtonPressed)];
    [typeBarItems addObject:typeDoneBtn];
    
    UIBarButtonItem *cancelTypeBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelTypeButtonPressed)];
    [typeBarItems addObject:cancelTypeBtn];
    
    [self.typePickerToolbar setItems:typeBarItems animated:YES];
    
    // Create subtype picker
    self.subTypePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, 0, 0)];
    self.subTypePicker.hidden = NO;
    self.subTypePicker.delegate = self;
    
    self.subTypePicker.dataSource = self;
    
    self.subTypePickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    self.subTypePickerToolbar.tintColor = [UIColor whiteColor];
    self.subTypePickerToolbar.barTintColor = [UIColor colorWithRed:(189/255.0) green:(26/255.0) blue:(47/255.0) alpha:1.0];
    [self.subTypePickerToolbar sizeToFit];
    
    NSMutableArray *subTypeBarItems = [[NSMutableArray alloc] init];
    
    [subTypeBarItems addObject:flexSpace];
    
    UIBarButtonItem *subTypeDoneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneSubTypeButtonPressed)];
    [subTypeBarItems addObject:subTypeDoneBtn];
    
    UIBarButtonItem *cancelSubTypeBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelSubTypeButtonPressed)];
    [subTypeBarItems addObject:cancelSubTypeBtn];
    
    [self.subTypePickerToolbar setItems:subTypeBarItems animated:YES];
}

-(void)setupInputFields
{
    self.costField.delegate = self;
    self.costField.keyboardType = UIKeyboardTypeNumberPad;
    self.costDecimalField.delegate = self;
    self.costDecimalField.keyboardType = UIKeyboardTypeNumberPad;
    self.commentField.delegate = self;
    [self.commentField setReturnKeyType: UIReturnKeyDone];
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    [self setModus:self.state];
    [self reloadLineData];
}

- (void) viewDidAppear:(BOOL)animated
{
    [self downLoadMainTypes];
}

-(void)dismissKeyboard {
    [self.costField resignFirstResponder];
    [self.costDecimalField resignFirstResponder];
    [self.commentField resignFirstResponder];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (sender == self.add)
    {
        self.declarationLine.cost = [self.costField.text floatValue] + ([self.costDecimalField.text floatValue] / 100);
    }
    else if (sender == self.cancel)
    {
        self.declarationLine = nil;
        self.attachment = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView

{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component

{
    if (pickerView == self.typePicker) {
        return [self.typeList count];
    } else if (pickerView == self.subTypePicker) {
        return [self.subTypeList count];
    } else {
        return 0;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView == self.typePicker) {
        DeclarationType *type = [self.typeList objectAtIndex:row];
        return [NSString stringWithFormat:@"%@", type.mainTypeName];
    } else if (pickerView == self.subTypePicker) {
        DeclarationSubType *subtype = [self.subTypeList objectAtIndex:row];
        return [NSString stringWithFormat:@"%@", subtype.subTypeName];
    } else {
        return nil;
    }
}

-(void)textFieldDidBeginEditing:(UITextField*)textField
{
    if (textField == self.dateField) {
        [self.dateField resignFirstResponder];
        self.pickerViewPopup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        [self.pickerViewPopup addSubview:self.datePickerToolbar];
        [self.pickerViewPopup addSubview:self.datePicker];
        [self.pickerViewPopup showInView:self.view];
        [self.pickerViewPopup setBounds:CGRectMake(0,0,320, 464)];
    } else if (textField == self.typeField) {
        [self.typeField resignFirstResponder];
        self.pickerViewPopup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        [self.pickerViewPopup addSubview:self.typePickerToolbar];
        [self.pickerViewPopup addSubview:self.typePicker];
        [self.pickerViewPopup showInView:self.view];
        [self.pickerViewPopup setBounds:CGRectMake(0,0,320, 464)];
        
    } else if (textField == self.subtypeField) {
        [self.subtypeField resignFirstResponder];
        self.pickerViewPopup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        [self.pickerViewPopup addSubview:self.subTypePickerToolbar];
        [self.pickerViewPopup addSubview:self.subTypePicker];
        [self.pickerViewPopup showInView:self.view];
        [self.pickerViewPopup setBounds:CGRectMake(0,0,320, 464)];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.costField) {
        if (textField.text.length >= 10 && range.length == 0)
        {
            return NO;
        }
        else
        {
            return YES;
        }
    } else if (textField == self.costDecimalField) {
        if (textField.text.length >= 2 && range.length == 0)
        {
            return NO;
        }
        else
        {
            return YES;
        }
    } else {
        return YES;
    }
}

-(void)doneDateButtonPressed
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd' 'HH:mm:ss.S"];
    
    NSString *stringFromDate = [formatter stringFromDate:self.datePicker.date];
    self.declarationLine.date = stringFromDate;
    
    [formatter setDateFormat:@"dd-MM-yyyy"];
    NSString *dateString = [formatter stringFromDate:self.datePicker.date];
    
    [self.dateField setText: dateString];
    [self.pickerViewPopup dismissWithClickedButtonIndex:1 animated:YES];
}

-(void)cancelDateButtonPressed
{
    [self.pickerViewPopup dismissWithClickedButtonIndex:1 animated:YES];
}

-(void)doneTypeButtonPressed
{
    int selected = [self.typePicker selectedRowInComponent:0];
    DeclarationType *type = [self.typeList objectAtIndex:selected];
    self.typeField.text = type.mainTypeName;
    self.declarationLine.type = type;
    [self downLoadSubTypes:type.ident];
    [self.pickerViewPopup dismissWithClickedButtonIndex:1 animated:YES];
}

-(void)cancelTypeButtonPressed
{
    [self.pickerViewPopup dismissWithClickedButtonIndex:1 animated:YES];
}

-(void)doneSubTypeButtonPressed
{
    int selected = [self.subTypePicker selectedRowInComponent:0];
    DeclarationSubType *subtype = [self.subTypeList objectAtIndex:selected];
    self.subtypeField.text = subtype.subTypeName;
    self.declarationLine.subtype = subtype;
    [self.pickerViewPopup dismissWithClickedButtonIndex:1 animated:YES];
}

-(void)cancelSubTypeButtonPressed
{
    [self.pickerViewPopup dismissWithClickedButtonIndex:1 animated:YES];
}

- (void)downLoadMainTypes
{
    if(self.state!=VIEW)
    {
        NSMutableArray *declarationsTypesFound = [[NSMutableArray alloc] init];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        [manager.requestSerializer setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"token"] forHTTPHeaderField:@"Authorization"];
        NSString *url = [NSString stringWithFormat:@"%@/declarationtypes", baseURL];
        [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             NSError* error;
             NSDictionary* json = [NSJSONSerialization
                                   JSONObjectWithData:responseObject
                                   
                                   options:kNilOptions
                                   error:&error];
             for (NSDictionary *decl in json)
             {
                 DeclarationType *declarationType = [[DeclarationType alloc] init];
                 declarationType.ident = [decl[@"id"] longLongValue];
                 declarationType.mainTypeName = decl[@"name"];
                 [declarationsTypesFound addObject:declarationType];
             }
             
             NSLog(@"GET request success response for all declarations: %@", json);
             self.typeList = declarationsTypesFound;
             [self.typePicker reloadAllComponents];
         }
             failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             NSLog(@"GET request Error for all declarations main types: %@", error);
         }];
    }
}

- (void)downLoadSubTypes:(int64_t)mainTpyeId
{
    if(self.state != VIEW)
    {
        NSString *combinedURL = [NSString stringWithFormat:@"%@%@%lld", baseURL, @"/declarationtype/", mainTpyeId];
        NSMutableArray *declarationsSubTypesFound = [[NSMutableArray alloc] init];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        [manager.requestSerializer setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"token"] forHTTPHeaderField:@"Authorization"];
        [manager GET:combinedURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             NSError* error;
             NSDictionary* json = [NSJSONSerialization
                                   JSONObjectWithData:responseObject
                                   
                                   options:kNilOptions
                                   error:&error];
             
             
             for (NSDictionary *decl in json)
             {
                 DeclarationSubType *declarationSubType = [[DeclarationSubType alloc] init];
                 declarationSubType.ident = [decl[@"id"] longLongValue];
                 declarationSubType.subTypeName = decl[@"name"];
                 declarationSubType.subTypeDescription = decl[@"declarationType"];
                 declarationSubType.subTypeMaxCost = [decl[@"max_cost"] floatValue];
                 [declarationsSubTypesFound addObject:declarationSubType];
             }
             
             NSLog(@"GET request success response for all declarations sub types: %@", json);
             self.subTypeList = declarationsSubTypesFound;
             [self.subTypePicker reloadAllComponents];
         }
             failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             NSLog(@"GET request Error for all declarations: %@", error);
         }];
    }
}


- (void) showErrorMessage: (NSString*)errorTitle :(NSString*)errorMessage
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:errorTitle
                                                    message:errorMessage
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if (sender == self.add)
    {
        if (([self.costField.text isEqualToString:@""] || [self.costDecimalField.text isEqualToString:@""]) && self.declarationLine.subtype.ident == nil) {
            [self showErrorMessage:@"Niets ingevoerd" :@"Er is niets ingevoerd."];
            return NO;
        } else if ([self.costField.text isEqualToString:@"" ] || [self.costDecimalField.text isEqualToString:@""]) {
            // TODO Make errormessages for each inputfield
            [self showErrorMessage:@"Ongeldig bedrag" :@"Er is een ongeldig bedrag ingevoerd."];
            return NO;
        } else if (self.declarationLine.subtype.ident == nil) {
            [self showErrorMessage:@"Geen Type/Subtype geselecteerd" :@"Er geen Type en/of Subtype geselecteerd."];
            return NO;
        } else {
            return YES;
        }
    }
    return YES;
}

@end