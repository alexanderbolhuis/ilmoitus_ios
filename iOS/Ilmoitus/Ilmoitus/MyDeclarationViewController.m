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
#import "constants.h"
#import "HttpRequestOperationManagerHandeler.h"

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
    
    // GET Actions when shwoing view
    [self getDeclarations];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    // GET Actions when showing view
    [self getDeclarations];
    
}

// For refreshing tableview
-(void) refreshInvoked:(id)sender forState:(UIControlState)state {
    [self getDeclarations];
}

- (void)getDeclarations
{
    // Do Request
    AFHTTPRequestOperationManager *manager = [HttpRequestOperationManagerHandeler createNewHttpRequestOperationManager];
    
    [manager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status)
     {
         switch (status)
         {
             case AFNetworkReachabilityStatusReachableViaWWAN:
             case AFNetworkReachabilityStatusReachableViaWiFi:
                 NSLog(@"Connected to network");
                 [self declarationsFromServer:manager];
                 break;
             case AFNetworkReachabilityStatusNotReachable:
                 NSLog(@"No internet connection");
                 [HttpRequestOperationManagerHandeler showErrorMessage:@"Geen verbinding" : @"Kon geen verbinding maken met een netwerk"];
                 break;
             default:
                 NSLog(@"Unknown internet connection");
                 [HttpRequestOperationManagerHandeler showErrorMessage:@"Onbekende verbinding" : @"Verbonden met een onbekend soort netwerk"];
                 break;
         }
     }];
}

- (void) declarationsFromServer:(AFHTTPRequestOperationManager*) manager
{
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
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        [HttpRequestOperationManagerHandeler handelErrorCode:operation :error];
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
    AFHTTPRequestOperationManager *manager = [HttpRequestOperationManagerHandeler createNewHttpRequestOperationManager];
    
    [manager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status)
     {
         switch (status)
         {
             case AFNetworkReachabilityStatusReachableViaWWAN:
             case AFNetworkReachabilityStatusReachableViaWiFi:
                 NSLog(@"Connected to network");
                 [self createNewDeclaration:manager:ident:destination];
                 break;
             case AFNetworkReachabilityStatusNotReachable:
                 NSLog(@"No internet connection");
                 [HttpRequestOperationManagerHandeler showErrorMessage:@"Geen verbinding" : @"Kon geen verbinding maken met een netwerk"];
                 break;
             default:
                 NSLog(@"Unknown internet connection");
                 [HttpRequestOperationManagerHandeler showErrorMessage:@"Onbekende verbinding" : @"Verbonden met een onbekend soort netwerk"];
                 break;
         }
     }];
}

-(void)createNewDeclaration:(AFHTTPRequestOperationManager*) manager:(int64_t)ident:(NewDeclarationViewController *)destination
{
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
            DeclarationSubType *declarationSubType = [[DeclarationSubType alloc]init];
            NSDictionary *declarationSubTypeDict = line[@"declaration_sub_type"];
            declarationSubType.subTypeName = declarationSubTypeDict[@"name"];
            foundLine.subtype = declarationSubType;
            
            [lines addObject:foundLine];
            //TODO DeclarationType
        }
        dec.lines = lines;
        
        //TODO Attachments ophalen
        
        destination.declaration = dec;
        NSLog(@"GET request SUCCES for specific declaration: %@", json);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        [HttpRequestOperationManagerHandeler handelErrorCode:operation :error];
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
        //TODO: set to correct value!
        destination.edit = false;//[dec.status  isEqual: @"Open"];
    }
}

@end
