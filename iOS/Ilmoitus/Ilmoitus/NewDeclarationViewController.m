//
//  SecondViewController.m
//  Ilmoitus
//
//  Created by Alexander Bolhuis on 22-04-14.
//  Copyright (c) 2014 42IN12EWa. All rights reserved.
//

#import "NewDeclarationViewController.h"
#import "NewDeclarationLineViewController.h"
#import "Declaration.h"
#import "DeclarationLine.h"
#import "Supervisor.h"
#import "constants.h"
#import "Attachment.h"

@interface NewDeclarationViewController ()
@property (weak, nonatomic) IBOutlet UITextField *supervisor;
@property (nonatomic) NSMutableArray *supervisorList;
@property (weak, nonatomic) IBOutlet UITextView *comment;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) UIPickerView * pktStatePicker;
@property (nonatomic) UIToolbar *mypickerToolbar;
@property (weak, nonatomic) IBOutlet UILabel *totalPrice;
@property (weak, nonatomic) IBOutlet UILabel *navItem;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;
@property (nonatomic) StateType state;

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


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    
    self.supervisor.delegate = self;
    [self.comment setReturnKeyType: UIReturnKeyDone];
    self.comment.delegate = self;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self getSupervisorList];
    
    if (_declaration == nil) {
        self.navItem.text = @"Declaratie Aanmaken";
    }
    else if(self.edit)
    {
        self.navItem.text = @"Declaratie Aanpassen";
    }
    else
    {
        self.navItem.text = @"Declaratie Bekijken";
        for (UIButton *button in self.buttons)
        {
            button.hidden = YES;
        }

    }

    [self declarationLinesChanged];
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
    // Create SupervisorPicker
    self.supervisorList = [[NSMutableArray alloc] init];
    
    self.pktStatePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 43, 320, 480)];
    
    self.pktStatePicker.delegate = self;
    
    self.pktStatePicker.dataSource = self;
    
    [self.pktStatePicker  setShowsSelectionIndicator:YES];
    
    self.supervisor.inputView =  self.pktStatePicker  ;
    
    // Create done button in UIPickerView
    self.mypickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 56)];
    
    self.mypickerToolbar.tintColor = [UIColor whiteColor];
    self.mypickerToolbar.barTintColor = [UIColor colorWithRed:(189/255.0) green:(26/255.0) blue:(47/255.0) alpha:1.0];
    
    [self.mypickerToolbar sizeToFit];
    
    
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    
    
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    [barItems addObject:flexSpace];
    
    
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(pickerDoneClicked)];
    
    [barItems addObject:doneBtn];
    
    
    [self.mypickerToolbar setItems:barItems animated:YES];
    
    
    self.supervisor.inputAccessoryView = self.mypickerToolbar;
    
    //set labels
    self.comment.text = self.declaration.comment;
    self.supervisor.text = self.declaration.comment;
    
    
}


-(IBAction)unwindToNewDeclaration:(UIStoryboardSegue *)segue
{
    NewDeclarationLineViewController * source = [segue sourceViewController];
    if(source.declarationLine != nil)
    {
        [self.declaration.lines addObject:source.declarationLine];
        [self declarationLinesChanged];
    }
    if(source.attachment != nil)
    {
        [self.declaration.attachments addObject:source.attachment];
    }
}

-(void)textFieldDidChange
{
    NSLog( @"Supervisor TextField changed: %@", self.supervisor.text);
    
    for (int i = 0; i < [self.supervisorList count]; i++){
        Supervisor *supervisor = [self.supervisorList objectAtIndex:i];
        if ([[NSString stringWithFormat:@"%@ %@ (%d)", supervisor.first_name, supervisor.last_name, supervisor.employee_number] isEqualToString:self.supervisor.text]) {
            [self.declaration.assignedTo addObject:[NSNumber numberWithLongLong:supervisor.ident]];
            [self.pktStatePicker selectRow:i inComponent:0 animated:YES];
        }
    }
}

-(void)pickerDoneClicked
{
    [self.supervisor resignFirstResponder];
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

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    Supervisor *sup = [self.supervisorList objectAtIndex:row];
    self.supervisor.text = @"";
    [self.supervisor insertText:[NSString stringWithFormat:@"%@ %@ (%d)", sup.first_name, sup.last_name, sup.employee_number]];
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
    [self clearView];
}

- (void)clearView {
    self.declaration = nil;
    [self viewDidLoad];
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
        //TODO error?
        return;
    }
    
    self.declaration.createdBy = [[[NSUserDefaults standardUserDefaults] stringForKey:@"person_id"] longLongValue];
    self.declaration.className = @"open_declaration";
    self.declaration.status = @"Open";
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"token"] forHTTPHeaderField:@"Authorization"];
    
    [manager.reachabilityManager startMonitoring];
    
    [manager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status)
     {
         switch (status)
         {
             case AFNetworkReachabilityStatusReachableViaWWAN:
             case AFNetworkReachabilityStatusReachableViaWiFi:
                 NSLog(@"Connected to network");
                 [self uploadDeclaration:manager];
                 break;
             case AFNetworkReachabilityStatusNotReachable:
                 NSLog(@"No internet connection");
                 [self showErrorMessage:@"Geen verbinding" : @"Kon geen verbinding maken met een netwerk"];
                 break;
             default:
                 NSLog(@"Unknown internet connection");
                 [self showErrorMessage:@"Onbekende verbinding" : @"Verbonden met een onbekend soort netwerk"];
                 break;
         }
     }];
}

-(void)uploadDeclaration:(AFHTTPRequestOperationManager*) manager
{
    Declaration *decl = self.declaration;
    
    // Lines
    NSMutableArray *declarationlines = [[NSMutableArray alloc] init];
    for (DeclarationLine *line in decl.lines)
    {
        NSDictionary *currentline = @{@"receipt_date": line.date, @"cost":[NSNumber numberWithFloat:line.cost], @"declaration_sub_type":[NSNumber numberWithLongLong:line.subtype.ident]};
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
        //[self clearView];
        NSLog(@"JSON response data for saving declaration: %@",json);
        // Handle success
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        switch (operation.response.statusCode)
        {
            case 400: // Bad Request
                NSLog(@"POST Request Error 400 for post new declaration: %@", error);
                [self showErrorMessage:@"Verkeerde aanvraag" :operation.responseString];
                break;
                
                
            case 401: // Unauthorized
				NSLog(@"POST Request Error 401 for post new declaration: %@", error);
                [self showErrorMessage:@"Onvoldoende rechten" :operation.responseString];
                break;
                
                
            case 403: // Forbidden
                NSLog(@"POST Request Error 403 for post new declaration: %@", error);
                [self showErrorMessage:@"Aanvraag niet toegestaan" :operation.responseString];
                break;
                
                
                
            case 404: // Not Found
                NSLog(@"POST Request Error 404 for post new declaration: %@", error);
                [self showErrorMessage:@"Niet gevonden" :operation.responseString];
                break;
                break;
                
                
            case 405: // Method Not Allowed
                NSLog(@"POST Request Error 405 for post new declaration: %@", error);
                [self showErrorMessage:@"Aanvraag niet toegestaan" :operation.responseString];
                break;
                
                
            case 406: // Not Acceptable
                NSLog(@"POST Request Error 406 for post new declaration: %@", error);
                [self showErrorMessage:@"Aanvraag niet toegestaan" :operation.responseString];
                break;
                
                
            case 407: // Proxy Authentication Required
                NSLog(@"POST Request Error 407 for post new declaration: %@", error);
                [self showErrorMessage:@"Onvoldoende rechten op proxy" :operation.responseString];
                break;
                
                
            case 408: // Request Timeout
                NSLog(@"POST Request Error 408 for post new declaration: %@", error);
                [self showErrorMessage:@"Aanvraag tijd voorbij" :operation.responseString];
                break;
                
                
            case 409: // Conflict
                NSLog(@"POST Request Error 409 for post new declaration: %@", error);
                [self showErrorMessage:@"Conflict op verzonden data" :operation.responseString];
                break;
                
                
            case 410: // Gone
                NSLog(@"POST Request Error 410 for post new declaration: %@", error);
                [self showErrorMessage:@"Actie verdwenen" :operation.responseString];
                break;
                
                
            case 411: // Length Required
                NSLog(@"POST Request Error 411 for post new declaration: %@", error);
                [self showErrorMessage:@"Onjuiste waardes" :operation.responseString];
                break;
                
                
            case 412: // Precondition Failed
                NSLog(@"POST Request Error 412 for post new declaration: %@", error);
                [self showErrorMessage:@"Randvoorwaarde onjuist" :operation.responseString];
                break;
                
                
            case 413: // Request Entity Too Large
                NSLog(@"POST Request Error 413 for post new declaration: %@", error);
                [self showErrorMessage:@"Aanvraag entiteit onjuist" :operation.responseString];
                break;
                
            case 414: // Request-URI Too Long
                NSLog(@"POST Request Error 414 for post new declaration: %@", error);
                [self showErrorMessage:@"Aanvraag url te lang" :operation.responseString];
                break;
                
                
            case 415: // Unsupported Media Type
                NSLog(@"POST Request Error 415 for post new declaration: %@", error);
                [self showErrorMessage:@"media type niet ondersteund" :operation.responseString];
                break;
                
                
            case 416: // Requested Range Not Satisfiable
                NSLog(@"POST Request Error 416 for post new declaration: %@", error);
                [self showErrorMessage:@"Aanvraag lengte voldoet niet" :operation.responseString];
                break;
                
                
            case 417: // Expectation Failed
                NSLog(@"POST Request Error 417 for post new declaration: %@", error);
                [self showErrorMessage:@"Onbekende verwachting" :operation.responseString];
                break;
                
            case 500: // Internal Server Error
                NSLog(@"POST Request Error 500 for post new declaration: %@", error);
                [self showErrorMessage:@"Interne server error" :operation.responseString];
                break;
                
            case 501: // Not Implemented
                NSLog(@"POST Request Error 501 for post new declaration: %@", error);
                [self showErrorMessage:@"Niet geïmplementeerd" :operation.responseString];
                break;
                
            case 502: // Bad Gateway
                NSLog(@"POST Request Error 502 for post new declaration: %@", error);
                break;
                
            case 503: // Service Unavailable
                NSLog(@"POST Request Error 503 for post new declaration: %@", error);
                [self showErrorMessage:@"Server niet bereikbaar" :operation.responseString];
                break;
                
            case 504: // Gateway Timeout
                NSLog(@"POST Request Error 504 for post new declaration: %@", error);
                break;
                
            case 505: // HTTP Version Not Supported
                NSLog(@"POST Request Error 505 for post new declaration: %@", error);
                [self showErrorMessage:@"HTML versie niet ondersteund" :operation.responseString];
                break;
            default:
                NSLog(@"POST Request Error for get supervisors: %@", error);
                [self showErrorMessage:@"Fout" :operation.responseString];
                break;
        }
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
    
    [manager.reachabilityManager startMonitoring];
    
    [manager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status)
     {
         switch (status)
         {
             case AFNetworkReachabilityStatusReachableViaWWAN:
             case AFNetworkReachabilityStatusReachableViaWiFi:
                 NSLog(@"Connected to network");
                 [self downloadSupervisorFromServer:manager];
                 break;
             case AFNetworkReachabilityStatusNotReachable:
                 NSLog(@"No internet connection");
                 [self showErrorMessage:@"Geen verbinding" : @"Kon geen verbinding maken met een netwerk"];
                 break;
             default:
                 NSLog(@"Unknown internet connection");
                 [self showErrorMessage:@"Onbekende verbinding" : @"Verbonden met een onbekend soort netwerk"];
                 break;
         }
     }];
}

- (void) downloadSupervisorFromServer:(AFHTTPRequestOperationManager*) manager
{
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
            if ((sup.ident == [[[NSUserDefaults standardUserDefaults] stringForKey:@"supervisor"] longLongValue]) && ([self.declaration.assignedTo firstObject] == nil)) {
                self.supervisor.text = @"";
                NSString *spv = [NSString stringWithFormat:@"%@ %@ (%d)", sup.first_name, sup.last_name, sup.employee_number];
                self.supervisor.text = spv;
                [self.declaration.assignedTo addObject:[NSNumber numberWithLongLong:sup.ident]];
            }
        }
        self.supervisorList = supervisorsFound;
        
        [self.pktStatePicker reloadAllComponents];
        
        // TODO create dropdown to select supervisor
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        switch (operation.response.statusCode)
        {
            case 400: // Bad Request
                NSLog(@"GET request Error 400 for supervisor: %@", error);
                [self showErrorMessage:@"Verkeerde aanvraag" :operation.responseString];
                break;
                
                
            case 401: // Unauthorized
				NSLog(@"GET request Error 401 for supervisor: %@", error);
                [self showErrorMessage:@"Onvoldoende rechten" :operation.responseString];
                break;
                
                
            case 403: // Forbidden
                NSLog(@"GET request Error 403 for supervisor: %@", error);
                [self showErrorMessage:@"Aanvraag niet toegestaan" :operation.responseString];
                break;
                
                
                
            case 404: // Not Found
                NSLog(@"GET request Error 404 for supervisor: %@", error);
                [self showErrorMessage:@"Niet gevonden" :operation.responseString];
                break;
                break;
                
                
            case 405: // Method Not Allowed
                NSLog(@"GET request Error 405 for supervisor: %@", error);
                [self showErrorMessage:@"Aanvraag niet toegestaan" :operation.responseString];
                break;
                
                
            case 406: // Not Acceptable
                NSLog(@"GET request Error 406 for supervisor: %@", error);
                [self showErrorMessage:@"Aanvraag niet toegestaan" :operation.responseString];
                break;
                
                
            case 407: // Proxy Authentication Required
                NSLog(@"GET request Error 407 for supervisor: %@", error);
                [self showErrorMessage:@"Onvoldoende rechten op proxy" :operation.responseString];
                break;
                
                
            case 408: // Request Timeout
                NSLog(@"GET request Error 408 for supervisor: %@", error);
                [self showErrorMessage:@"Aanvraag tijd voorbij" :operation.responseString];
                break;
                
                
            case 409: // Conflict
                NSLog(@"GET request Error 409 for supervisor: %@", error);
                [self showErrorMessage:@"Conflict op verzonden data" :operation.responseString];
                break;
                
                
            case 410: // Gone
                NSLog(@"GET request Error 410 for supervisor: %@", error);
                [self showErrorMessage:@"Actie verdwenen" :operation.responseString];
                break;
                
                
            case 411: // Length Required
                NSLog(@"GET request Error 411 for supervisor: %@", error);
                [self showErrorMessage:@"Onjuiste waardes" :operation.responseString];
                break;
                
                
            case 412: // Precondition Failed
                NSLog(@"GET request Error 412 for supervisor: %@", error);
                [self showErrorMessage:@"Randvoorwaarde onjuist" :operation.responseString];
                break;
                
                
            case 413: // Request Entity Too Large
                NSLog(@"GET request Error 413 for supervisor: %@", error);
                [self showErrorMessage:@"Aanvraag entiteit onjuist" :operation.responseString];
                break;
                
            case 414: // Request-URI Too Long
                NSLog(@"GET request Error 414 for supervisor: %@", error);
                [self showErrorMessage:@"Aanvraag url te lang" :operation.responseString];
                break;
                
                
            case 415: // Unsupported Media Type
                NSLog(@"GET request Error 415 for supervisor: %@", error);
                [self showErrorMessage:@"media type niet ondersteund" :operation.responseString];
                break;
                
                
            case 416: // Requested Range Not Satisfiable
                NSLog(@"GET request Error 416 for supervisor: %@", error);
                [self showErrorMessage:@"Aanvraag lengte voldoet niet" :operation.responseString];
                break;
                
                
            case 417: // Expectation Failed
                NSLog(@"GET request Error 417 for supervisor: %@", error);
                [self showErrorMessage:@"Onbekende verwachting" :operation.responseString];
                break;
                
            case 500: // Internal Server Error
                NSLog(@"GET request Error 500 for supervisor: %@", error);
                [self showErrorMessage:@"Interne server error" :operation.responseString];
                break;
                
            case 501: // Not Implemented
                NSLog(@"GET request Error 501 for supervisor: %@", error);
                [self showErrorMessage:@"Niet geïmplementeerd" :operation.responseString];
                break;
                
            case 502: // Bad Gateway
                NSLog(@"GET request Error 502 for supervisor: %@", error);
                break;
                
            case 503: // Service Unavailable
                NSLog(@"GET request Error 503 for supervisor: %@", error);
                [self showErrorMessage:@"Server niet bereikbaar" :operation.responseString];
                break;
                
            case 504: // Gateway Timeout
                NSLog(@"GET request Error 504 for supervisor: %@", error);
                break;
                
            case 505: // HTTP Version Not Supported
                NSLog(@"GET request Error 505 for supervisor: %@", error);
                [self showErrorMessage:@"HTML versie niet ondersteund" :operation.responseString];
                break;
            default:
                NSLog(@"GET request Error for get supervisors: %@", error);
                [self showErrorMessage:@"Fout" :operation.responseString];
                break;
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.declaration.lines count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DeclarationLineCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    DeclarationLine *line = [self.declaration.lines objectAtIndex:indexPath.row];
    
    UILabel *label = (UILabel *)[cell viewWithTag:1];
    UILabel *subTypelabel = (UILabel *)[cell viewWithTag:2];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy-MM-dd' 'HH:mm:ss.S";
    NSDate *date = [formatter dateFromString:line.date];
    
    [formatter setDateFormat:@"dd-MM-yyyy"];
    NSString *dateString = [formatter stringFromDate:date];
    
    label.text = [NSString stringWithFormat:@"%@ - €%.02f", dateString, line.cost];
    subTypelabel.text = [NSString stringWithFormat:@"%@", line.subtype.subTypeName];
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.declaration.lines removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self setTotalPrice];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return self.edit;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return NO;
}

-(void)decalrationChanged
{
    [self declarationLinesChanged];
    [self setTotalPrice];
    self.comment.text = self.declaration.comment;
}

-(void)declarationLinesChanged
{
    [self.tableView reloadData];
    [self setTotalPrice];
}

-(void)setTotalPrice
{
    NSString* formattedAmount = [NSString stringWithFormat:@"%.2f", self.declaration.calculateTotalPrice];
    self.totalPrice.text = [NSString stringWithFormat:@"Totaal bedrag: €%@", formattedAmount];

}

- (void) showErrorMessage: (NSString*)errorTitle:(NSString*)errorMessage
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:errorTitle
                                                    message:errorMessage
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}
@end
