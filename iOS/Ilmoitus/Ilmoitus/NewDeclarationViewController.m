//
//  SecondViewController.m
//  Ilmoitus
//
//  Created by Alexander Bolhuis on 22-04-14.
//  Copyright (c) 2014 42IN12EWa. All rights reserved.
//

#import "NewDeclarationViewController.h"
#import "DeclarationLinesTableViewController.h"
#import "AttachmentsTableViewController.h"
#import "Declaration.h"
#import "DeclarationLine.h"
#import "Supervisor.h"
#import "constants.h"
#import "Attachment.h"
#import "StateType.h"

@interface NewDeclarationViewController ()
@property (weak, nonatomic) IBOutlet UITextField *supervisor;
@property (nonatomic) NSMutableArray *supervisorList;
@property (weak, nonatomic) IBOutlet UITextView *comment;
@property (weak, nonatomic) IBOutlet UIButton *add;
@property (weak, nonatomic) IBOutlet UIButton *cancel;
@property (nonatomic) UIPickerView *supervisorPicker;
@property (nonatomic) UIToolbar *supervisorPickerToolbar;
@property (nonatomic) UIActionSheet *pickerViewPopup;

@property (weak, nonatomic) IBOutlet UILabel *totalPrice;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;
@property (weak, nonatomic) IBOutlet UILabel *bijlageLabel;
@property (weak, nonatomic) IBOutlet UILabel *regelsLabel;

@end

@implementation NewDeclarationViewController

@synthesize declaration = _declaration;

-(Declaration *)declaration
{
    if(_declaration == nil)
    {
        self.declaration = [[Declaration alloc]init];
        self.state = NEW;
    }
    return _declaration;
}

-(void)setDeclaration:(Declaration *)declaration
{
    _declaration = declaration;
    [self decalrationChanged];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.regelsLabel.text = [NSString stringWithFormat:@"Declaratie items: %d", [self.declaration.lines count]];
    self.bijlageLabel.text = [NSString stringWithFormat:@"Bijlages: %d", [self.declaration.attachments count]];
    [self setTotalPrice];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    
    self.supervisor.delegate = self;
    [self.comment setReturnKeyType: UIReturnKeyDone];
    self.comment.delegate = self;
    
    if (_declaration == nil) {
        [self.navigationItem setTitle:@"Declaratie aanmaken"];
    }
    else if(self.state == EDIT)
    {
        [self.navigationItem setTitle:@"Declaratie aanpassen"];
        
        [self.cancel setTitle:@"Verwijder" forState:UIControlStateNormal];
        [self.cancel setTitle:@"Verwijder" forState:UIControlStateHighlighted];
        [self.cancel setTitle:@"Verwijder" forState:UIControlStateDisabled];
        [self.cancel setTitle:@"Verwijder" forState:UIControlStateSelected];
        
        [self.add setTitle:@"Opslaan" forState:UIControlStateNormal];
        [self.add setTitle:@"Opslaan" forState:UIControlStateHighlighted];
        [self.add setTitle:@"Opslaan" forState:UIControlStateDisabled];
        [self.add setTitle:@"Opslaan" forState:UIControlStateSelected];
    }
    else
    {
        [self.navigationItem setTitle:@"Declaratie bekijken"];
        self.supervisor.enabled = NO;
        self.comment.editable = NO;
        for (UIButton *button in self.buttons)
        {
            button.hidden = YES;
        }
    }
    
    if (self.state == NEW || self.state == VIEW) {
        [self getSupervisorList];
    }
    
    self.comment.text = self.declaration.comment;
    
    
    // Textfield delegates
    self.supervisor.delegate = self;
    [self.comment setReturnKeyType: UIReturnKeyDone];
    self.comment.delegate = self;
    
    // TextView styling
    [self.comment.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [self.comment.layer setBorderWidth:0.5];
    self.comment.layer.cornerRadius = 5;
    self.comment.clipsToBounds = YES;
    
    [self.supervisor addTarget:self
                        action:@selector(textFieldDidChange)
              forControlEvents:UIControlEventEditingChanged];
    
    [self createSupervisorPicker];
}

-(void)createSupervisorPicker
{
    // Create type picker
    self.supervisorPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, 0, 0)];
    self.supervisorPicker.hidden = NO;
    self.supervisorPicker.delegate = self;
    
    self.supervisorPicker.dataSource = self;
    
    self.supervisorPickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    self.supervisorPickerToolbar.tintColor = [UIColor whiteColor];
    self.supervisorPickerToolbar.barTintColor = [UIColor colorWithRed:(189/255.0) green:(26/255.0) blue:(47/255.0) alpha:1.0];
    [self.supervisorPickerToolbar sizeToFit];
    
    NSMutableArray *supervisorBarItems = [[NSMutableArray alloc] init];
    
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    [supervisorBarItems addObject:flexSpace];
    
    UIBarButtonItem *supervisorDoneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneSupervisorButtonPressed)];
    [supervisorBarItems addObject:supervisorDoneBtn];
    
    UIBarButtonItem *cancelSupervisorBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelSupervisorButtonPressed)];
    [supervisorBarItems addObject:cancelSupervisorBtn];
    
    [self.supervisorPickerToolbar setItems:supervisorBarItems animated:YES];
    
    //set labels
    self.comment.text = self.declaration.comment;
    self.supervisor.text = self.declaration.comment;
}

-(void)doneSupervisorButtonPressed
{
    int selected = [self.supervisorPicker selectedRowInComponent:0];
    Supervisor *sup = [self.supervisorList objectAtIndex:selected];
    [self setSupervisorField:sup];
    [self setSupervisorForDeclaration:sup];
    [self setSupervisorPickerSelected:sup];
    [self.pickerViewPopup dismissWithClickedButtonIndex:1 animated:YES];
}

-(void)cancelSupervisorButtonPressed
{
    [self.pickerViewPopup dismissWithClickedButtonIndex:1 animated:YES];
}

-(void)setSupervisorField:(Supervisor *)sup
{
    NSString *name = [NSString stringWithFormat:@"%@ %@ (%i)", sup.first_name, sup.last_name, sup.employee_number];
    self.supervisor.text = @"";
    self.supervisor.text = name;
}

-(void)setSupervisorForDeclaration:(Supervisor *)sup
{
    NSNumber *ident = [NSNumber numberWithLongLong:sup.ident];
    [self.declaration.assignedTo removeAllObjects];
    [self.declaration.assignedTo addObject:ident];
}

-(void)setSupervisorPickerSelected:(Supervisor *)sup
{
    for (int i = 0; i < [self.supervisorList count]; i++) {
        Supervisor *superv = [self.supervisorList objectAtIndex:i];
        if (superv.ident == sup.ident) {
            [self.supervisorPicker selectRow:i inComponent:0 animated:YES];
        }
    }
}

-(void)textFieldDidBeginEditing:(UITextField*)textField
{
    if (textField == self.supervisor) {
        [self.supervisor resignFirstResponder];
        self.pickerViewPopup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        [self.pickerViewPopup addSubview:self.supervisorPickerToolbar];
        [self.pickerViewPopup addSubview:self.supervisorPicker];
        [self.pickerViewPopup showInView:self.view];
        [self.pickerViewPopup setBounds:CGRectMake(0,0,320, 464)];
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.supervisorList count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    Supervisor *sup = [self.supervisorList objectAtIndex:row];
    return [NSString stringWithFormat:@"%@ %@ (%d)", sup.first_name, sup.last_name, sup.employee_number];
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView {
    self.declaration.comment = self.comment.text;
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (IBAction)cancelDeclaration:(id)sender
{
    if (self.state == EDIT){
        [self deleteDeclaration];
    } else {
        [self clearView];
    }
}

- (void)clearView {
    _declaration = nil;
    [self viewDidLoad];
    [self declaration];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveDeclaration:(id)sender
{
    if(self.state == VIEW)
    {
        return;
    } else if (self.state == EDIT) {
        [self editDeclaration];
    } else {
        
        self.declaration.createdBy = [[[NSUserDefaults standardUserDefaults] stringForKey:@"person_id"] longLongValue];
        self.declaration.className = @"open_declaration";
        self.declaration.status = @"Open";
        
        Declaration *decl = self.declaration;
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"token"] forHTTPHeaderField:@"Authorization"];
        
        // Lines
        NSMutableArray *declarationlines = [[NSMutableArray alloc] init];
        for (DeclarationLine *line in decl.lines)
        {
            if (line.comment == nil) {
                line.comment = @"";
            }
            
            NSDictionary *currentline = @{@"receipt_date": line.date, @"comment":line.comment, @"cost":[NSNumber numberWithFloat:line.cost], @"declaration_sub_type":[NSNumber numberWithLongLong:line.subtype.ident]};
            [declarationlines addObject:currentline];
        }
        
        // Attachments
        NSMutableArray *attachments = [[NSMutableArray alloc] init];
        for (Attachment *attachment in self.declaration.attachments)
        {
            NSDictionary *currentAttachment = @{@"name":attachment.name, @"file":attachment.data};
            [attachments addObject:currentAttachment];
        }
        
        // Declaration
        if (decl.comment == nil) {
            decl.comment = @"";
        }
        
        NSDictionary *declaration = @{@"state":decl.status, @"created_by":[NSNumber numberWithLongLong:decl.createdBy], @"supervisor":[decl.assignedTo firstObject], @"comment":decl.comment, @"items_total_price":[NSNumber numberWithFloat:decl.itemsTotalPrice], @"items_count":[NSNumber numberWithInt:decl.itemsCount], @"lines":declarationlines, @"attachments":attachments};
        
        
        // Total dict
        NSDictionary *params = @{@"declaration":declaration};
        
        NSLog(@"JSON data that is going to be saved/sent: %@",params);
        
        NSString *url = [NSString stringWithFormat:@"%@/declaration", baseURL];
        AFHTTPRequestOperation *apiRequest = [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSError* error;
            NSDictionary* json = [NSJSONSerialization
                                  JSONObjectWithData:responseObject
                                  
                                  options:kNilOptions
                                  error:&error];
            [self showSuccessMessage:@"Indienen geslaagd" :@"Declaratie is ingediend"];
            [self clearView];
            NSLog(@"JSON response data for saving declaration: %@",json);
            // Handle success
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error while saving declaration: %@, %@", error, operation.responseString);
            // Handle error
            
        }];
        
        [apiRequest start];
    }
}

-(void)deleteDeclaration
{
    // Do Request
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager.requestSerializer setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"token"] forHTTPHeaderField:@"Authorization"];
    NSString *url = [NSString stringWithFormat:@"%@/declaration/%lld", baseURL, self.declaration.ident];
    [manager DELETE:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError* error;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseObject
                              
                              options:kNilOptions
                              error:&error];
        
        [self showSuccessMessage:@"Verwijderen geslaagd" :@"Declaratie is verwijdert"];
        [self.navigationController popViewControllerAnimated:YES];
        
        // NSLog(@"JSON response: %@", json);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error while getting supervisor list: %@", error);
    }];
}

-(void)editDeclaration
{
    Declaration *decl = self.declaration;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"token"] forHTTPHeaderField:@"Authorization"];
    
    // Lines
    NSMutableArray *declarationlines = [[NSMutableArray alloc] init];
    for (DeclarationLine *line in decl.lines)
    {
        if (line.comment == nil) {
            line.comment = @"";
        }
        
        NSDictionary *currentline = @{@"receipt_date": line.date, @"comment":line.comment, @"cost":[NSNumber numberWithFloat:line.cost], @"declaration_sub_type":[NSNumber numberWithLongLong:line.subtype.ident]};
        [declarationlines addObject:currentline];
    }
    
    // Attachments
    NSMutableArray *attachments = [[NSMutableArray alloc] init];
    for (Attachment *attachment in self.declaration.attachments)
    {
        if (attachment.data != nil) {
            NSDictionary *currentAttachment = @{@"name":attachment.name, @"file":attachment.data};
            [attachments addObject:currentAttachment];
        } else {
            NSDictionary *currentAttachment = @{@"id":[NSString stringWithFormat:@"%lld", attachment.ident], @"name":attachment.name};
            [attachments addObject:currentAttachment];
        }
    }
    
    // Declaration
    NSDictionary *declaration = @{@"state":decl.status, @"supervisor":[decl.assignedTo firstObject], @"comment":decl.comment, @"items_total_price":[NSNumber numberWithFloat:decl.itemsTotalPrice], @"items_count":[NSNumber numberWithInt:decl.itemsCount], @"lines":declarationlines, @"attachments":attachments};
    
    
    // Total dict
    NSDictionary *params = @{@"declaration":declaration};
    
    // NSLog(@"JSON data that is going to be saved/sent: %@",params);
    
    NSString *url = [NSString stringWithFormat:@"%@/declaration/%lld", baseURL, self.declaration.ident];
    AFHTTPRequestOperation *apiRequest = [manager PUT:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError* error;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseObject
                              
                              options:kNilOptions
                              error:&error];
        [self showSuccessMessage:@"Aanpassen geslaagd" :@"Declaratie is aangepast"];
        [self.navigationController popViewControllerAnimated:YES];
        
        // NSLog(@"JSON response data for saving declaration: %@",json);
        // Handle success
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error while saving declaration: %@, %@", error, operation.responseString);
        // Handle error
        
    }];
    
    [apiRequest start];
}

-(void)getSupervisorList
{
    // Do Request
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager.requestSerializer setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"token"] forHTTPHeaderField:@"Authorization"];
    NSString *url = [NSString stringWithFormat:@"%@/current_user/supervisors", baseURL];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError* error;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseObject
                              
                              options:kNilOptions
                              error:&error];
        
        NSLog(@"JSON response: %@", json);
        
        NSMutableArray *supervisorsFound = [[NSMutableArray alloc] init];
        for (NSDictionary *supervisor in json) {
            Supervisor *sup = [[Supervisor alloc] init];
            sup.ident = [supervisor[@"id"]longLongValue];
            sup.class_name = supervisor[@"class_name"];
            sup.first_name = supervisor[@"first_name"];
            sup.last_name = supervisor[@"last_name"];
            sup.email = supervisor[@"email"];
            sup.employee_number = [supervisor[@"employee_number"] integerValue];
            sup.supervisor = [supervisor[@"supervisor"] longLongValue];
            sup.max_declaration_price = [supervisor[@"max_declaration_price"] floatValue];
            
            [supervisorsFound addObject:sup];
            
            // Set default supervisor
            /*if ((sup.ident == [[[NSUserDefaults standardUserDefaults] stringForKey:@"supervisor"] longLongValue]) && ([self.declaration.assignedTo firstObject] == nil)) {
                self.supervisor.text = @"";
                NSString *spv = [NSString stringWithFormat:@"%@ %@ (%d)", sup.first_name, sup.last_name, sup.employee_number];
                self.supervisor.text = spv;
                [self.declaration.assignedTo addObject:[NSNumber numberWithLongLong:sup.ident]];
            }*/
        }
        self.supervisorList = supervisorsFound;
        
        if (self.state == NEW) {
            for (Supervisor *sup in supervisorsFound) {
                if (sup.ident == [[[NSUserDefaults standardUserDefaults] objectForKey:@"supervisor"] longLongValue]) {
                    [self setSupervisorField:sup];
                    [self setSupervisorForDeclaration:sup];
                    [self setSupervisorPickerSelected:sup];
                }
            }
        } else {
            for (Supervisor *sup in supervisorsFound) {
                if (sup.ident == [[self.declaration.assignedTo firstObject] longLongValue]) {
                    [self setSupervisorField:sup];
                    [self setSupervisorForDeclaration:sup];
                    [self setSupervisorPickerSelected:sup];
                }
            }
        }
        
        [self.supervisorPicker reloadAllComponents];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error while getting supervisor list: %@", error);
    }];
}

-(void)decalrationChanged
{
    [self viewWillAppear:YES];
    self.comment.text = self.declaration.comment;
}

-(void)setTotalPrice
{
    NSString* formattedAmount = [NSString stringWithFormat:@"%.2f", self.declaration.calculateTotalPrice];
    self.totalPrice.text = [NSString stringWithFormat:@"Totaal bedrag: €%@", formattedAmount];
    
}

-(void)showSuccessMessage: (NSString*)successTitle :(NSString*)successMessage
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:successTitle
                                                    message:successMessage
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"listLines"])
    {
        DeclarationLinesTableViewController *destination = [segue destinationViewController];
        
        destination.declaration = self.declaration;

        destination.state = self.state;
    }
    if([[segue identifier] isEqualToString:@"listAttachment"])
    {
        AttachmentsTableViewController *destination = [segue destinationViewController];

        destination.declaration = self.declaration;
        
        destination.state = self.state;
    }
    
}
@end
