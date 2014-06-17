//
//  FirstViewController.m
//  Ilmoitus
//
//  Created by Alexander Bolhuis on 22-04-14.
//  Copyright (c) 2014 42IN12EWa. All rights reserved.
//

#import "MyDeclarationViewController.h"
#import "NewDeclarationViewController.h"
#import "Declaration.h"
#import "DeclarationLine.h"
#import "Attachment.h"
#import "constants.h"
#import "HttpResponseHandler.h"

@interface MyDeclarationViewController ()
@property (nonatomic, strong) NSMutableArray *declarationList;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;

@end

@implementation MyDeclarationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Init Refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshInvoked:forState:) forControlEvents:UIControlEventValueChanged];
    
	// Do any additional setup after loading the view, typically from a nib.
    self.navItem.title = [NSString stringWithFormat:@"Ingelogd als %@ %@ (%@)", [[NSUserDefaults standardUserDefaults] stringForKey:@"person_first_name"], [[NSUserDefaults standardUserDefaults] stringForKey:@"person_last_name"], [[NSUserDefaults standardUserDefaults] stringForKey:@"person_employee_number"]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    // GET Actions when showing view
    [self declarationsFromServer];
    
}

// For refreshing tableview
-(void) refreshInvoked:(id)sender forState:(UIControlState)state {
    [self declarationsFromServer];
}

- (void)declarationsFromServer
{
    // Do Request
    AFHTTPRequestOperationManager *manager = [HttpResponseHandler createNewHttpRequestOperationManager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    [manager.requestSerializer setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"token"] forHTTPHeaderField:@"Authorization"];
    
    NSString *url = [NSString stringWithFormat:@"%@/current_user/declarations", baseURL];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError* error;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseObject
                              
                              options:kNilOptions
                              error:&error];
        
        NSMutableArray *declarationsFound = [[NSMutableArray alloc] init];
        for (NSDictionary *decl in json) {
            Declaration *declaration = [[Declaration alloc] init];
            declaration.ident = [decl[@"id" ] longLongValue];
            declaration.status = decl[@"state"];
            NSNumber *assigned = [NSNumber numberWithLongLong:[decl[@"assigned_to"][0] longLongValue]];
            [declaration.assignedTo addObject:assigned];
            declaration.itemsCount = [decl[@"items_count"] intValue];
            declaration.itemsTotalPrice = [decl[@"items_total_price"] floatValue];
            NSDateFormatter *formatter = [NSDateFormatter new];
            formatter.dateFormat = @"yyyy-MM-dd' 'HH:mm:ss.S";
            
            NSDate *date = [formatter dateFromString:decl[@"created_at"]];
            [formatter setDateFormat:@"dd-MM-yyyy"];
            declaration.createdAt = [formatter stringFromDate:date];
            [declarationsFound addObject:declaration];
        }
        
        [self.declarationList removeAllObjects];
        self.declarationList = declarationsFound;
        
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
        
        NSLog(@"GET request success response for all declarations: %@", json);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HttpResponseHandler handelErrorCode:operation :error:self];
        NSLog(@"GET request Error for all declarations: %@", error);
    }];
    
    // Reload the data
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Only one section
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return number of actions in actionlist
    return [self.declarationList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:  (NSIndexPath *)indexPath
{
    // View for TableViewCell
    static NSString *CellIdentifier = @"declaration";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    Declaration *declaration = [self.declarationList     objectAtIndex:indexPath.row];
    
    UILabel *createdAtlabel;
    
    createdAtlabel = (UILabel *)[cell viewWithTag:1];
    [createdAtlabel adjustsFontSizeToFitWidth];
    createdAtlabel.text = [NSString stringWithFormat:@"Declaratie op %@", declaration.createdAt];
    
    UILabel *statusLabel;
    
    statusLabel = (UILabel *)[cell viewWithTag:2];
    [statusLabel adjustsFontSizeToFitWidth];
    statusLabel.text = declaration.status;
    
    UILabel *amountLabel;
    
    amountLabel = (UILabel *)[cell viewWithTag:3];
    [amountLabel adjustsFontSizeToFitWidth];
    NSString* formattedAmount = [NSString stringWithFormat:@"%.02f", declaration.itemsTotalPrice];
    amountLabel.text = [NSString stringWithFormat:@"€%@", formattedAmount];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Declaraties";
}

-(void)setFullDeclaration:(int64_t)ident destination:(NewDeclarationViewController *)destination
{
    AFHTTPRequestOperationManager *manager = [HttpResponseHandler createNewHttpRequestOperationManager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    [manager.requestSerializer setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"token"] forHTTPHeaderField:@"Authorization"];
    
    NSString *url = [NSString stringWithFormat:@"%@/declaration/%lld", baseURL, ident];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError* error;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseObject
                              
                              options:kNilOptions
                              error:&error];
        
        Declaration *dec = [[Declaration alloc]init];
        dec.ident = [json[@"id"] longLongValue];
        dec.comment = json[@"comment"];
        dec.createdAt = json[@"created_at"];
        NSNumber *assigned = [NSNumber numberWithLongLong:[json[@"assigned_to"][0] longLongValue]];
        [dec.assignedTo addObject:assigned];
        dec.itemsCount = [json[@"items_count"] intValue];
        dec.itemsTotalPrice = [json[@"items_total_price"] floatValue];
        dec.status = json[@"state"];
        
        
        //lines
        NSMutableArray *lines = [[NSMutableArray alloc] init];
        for (NSDictionary *line in json[@"lines"])
        {
            DeclarationLine *foundLine = [[DeclarationLine alloc]init];
            foundLine.cost = [line[@"cost"] floatValue];
            foundLine.date = line[@"receipt_date"];
            if (line[@"comment"] != nil && ![line[@"comment"]isEqual:[NSNull null]]) {
                foundLine.comment = line[@"comment"];
            } else {
                foundLine.comment = @"";
            }
            
            DeclarationSubType *declarationSubType = [[DeclarationSubType alloc]init];
            NSDictionary *declarationSubTypeDict = line[@"declaration_sub_type"];
            declarationSubType.ident = [declarationSubTypeDict[@"id"] longLongValue];
            declarationSubType.subTypeName = declarationSubTypeDict[@"name"];
            foundLine.subtype = declarationSubType;
            
            DeclarationType *declarationType = [[DeclarationType alloc]init];
            NSDictionary * declarationTypeDict = line[@"declaration_type"];
            declarationType.mainTypeName = declarationTypeDict[@"name"];
            declarationType.ident = [declarationTypeDict[@"id" ] longLongValue];
            foundLine.type = declarationType;
            
            [lines addObject:foundLine];
        }
        dec.lines = lines;
        
        NSMutableArray *attachments = [[NSMutableArray alloc] init];
        for (NSDictionary *attachment in json[@"attachments"])
        {
            Attachment *foundAtt = [[Attachment alloc]init];
            foundAtt.ident = [attachment[@"id"] longLongValue];
            foundAtt.name = attachment[@"name"];
            
            [attachments addObject:foundAtt];
        }
        dec.attachments = attachments;
        
        destination.declaration = dec;
        [destination getSupervisorList];
        NSLog(@"GET request SUCCES for specific declaration: %@", json);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"GET request Error for all declarations: %@", error);
        [HttpResponseHandler handelErrorCode:operation :error:self];
    }];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"viewDeclaration"])
    {
        NewDeclarationViewController *destination =  [segue destinationViewController];
        
        NSIndexPath *index = [self.tableView indexPathForSelectedRow];
        Declaration *dec = self.declarationList[index.row];
        
        [self setFullDeclaration:dec.ident destination:destination];
        
        destination.declaration = [[Declaration alloc] init];
        
        if([dec.status  isEqual: @"Open"])
        {
            destination.state = EDIT;
        }
        else
        {
            destination.state = VIEW;
        }
    }
}
@end
