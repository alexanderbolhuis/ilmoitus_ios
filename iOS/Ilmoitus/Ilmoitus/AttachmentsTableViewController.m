//
//  AttachmentsTableViewController.m
//  Ilmoitus
//
//  Created by Sjors Boom on 13/06/14.
//  Copyright (c) 2014 42IN12EWa. All rights reserved.
//

#import "AttachmentsTableViewController.h"
#import "NewAttachmentViewController.h"
#import "Attachment.h"
#import "constants.h"
#import "HttpResponseHandler.h"

@interface AttachmentsTableViewController ()
@property (strong, nonatomic) IBOutlet UITableView *table;

@end

@implementation AttachmentsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Bijlages";
    
    if(self.state != VIEW)
    {
        [self setupToolBar];
    }
}

-(void)setupToolBar
{
    UIBarButtonItem *add = [[UIBarButtonItem alloc]initWithTitle:@"+" style:UIBarButtonSystemItemAdd target:self action:@selector(addNew)];
    
    [add setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont fontWithName:@"AmericanTypewriter-Light" size:30.0]
       }
                       forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = add;
}

-(void)addNew
{
    [self performSegueWithIdentifier:@"newAttachment" sender:self];
}

-(IBAction)unwindToAttachments:(UIStoryboardSegue *)segue
{
    NewAttachmentViewController * source = [segue sourceViewController];
    switch (source.state)
    {
        case NEW:
            if(source.attachment != nil)
            {
                [self.declaration.attachments addObject:source.attachment];
                [self.table reloadData];
            }
            break;
        case EDIT:
            if(source.attachment!=nil)
            {
                NSIndexPath *index = [self.table indexPathForSelectedRow];
                [self.declaration.attachments replaceObjectAtIndex:index.row withObject:source.attachment];
                [self.table reloadData];
            }
            else
            {
                [self.declaration.attachments removeObjectAtIndex:[self.table indexPathForSelectedRow].row];
                [self.table reloadData];
            }
            break;
            
        default:
            break;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.table reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.declaration.attachments count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AttachmentCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    Attachment *attachment = [self.declaration.attachments objectAtIndex:indexPath.row];
    
    UILabel *label = (UILabel *)[cell viewWithTag:1];
    
    label.text = attachment.name;
    
    
    return cell;
    
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return self.state!=VIEW;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self.declaration.attachments removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return NO;
}

-(void)getAttachmentToken:(Attachment *)att
{
    AFHTTPRequestOperationManager *manager = [HttpResponseHandler createNewHttpRequestOperationManager];
    
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    [manager.requestSerializer setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"token"] forHTTPHeaderField:@"Authorization"];
    
    NSString *url = [NSString stringWithFormat:@"%@/attachment_token/%lld", baseURL, att.ident];
    NSLog(@"%@", url);
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError* error;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseObject
                              
                              options:kNilOptions
                              error:&error];
        
        NSLog(@"JSON response: %@", json);
        
        NSString *token = json[@"attachment_token"];
        [self downloadAttachment:token :att];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error while getting attachment token: %@", error);
        [HttpResponseHandler handelErrorCode:operation :error:self];
    }];
}

-(void)downloadAttachment:(NSString *)token :(Attachment *)att
{
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:att.name];
    
    AFHTTPRequestOperationManager *manager = [HttpResponseHandler createNewHttpRequestOperationManager];
    
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    [manager.requestSerializer setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"token"] forHTTPHeaderField:@"Authorization"];
    
    NSString *url = [NSString stringWithFormat:@"%@/attachment/%lld/%@", baseURL, att.ident, token];
    AFHTTPRequestOperation *op = [manager GET:url
                                   parameters:nil
                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                          NSLog(@"successful download to %@", path);
                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          [HttpResponseHandler handelErrorCode:operation :error:self];
                                          NSLog(@"Error: %@", error);
                                      }];
    [op setResponseSerializer:[AFHTTPResponseSerializer serializer]];
    op.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"viewAttachment"])
    {
        NewAttachmentViewController *destination = [segue destinationViewController];
        
        NSIndexPath *path = [self.table indexPathForSelectedRow];
        Attachment *attachment = [self.declaration.attachments objectAtIndex:path.row];
        [self getAttachmentToken:attachment];
        destination.attachment = attachment;
        
        if(self.state == NEW)
        {
            destination.state = EDIT;
        }
        else
        {
            destination.state = self.state;
        }
    }
    else if([[segue identifier] isEqualToString:@"newAttachment"])
    {
        NewAttachmentViewController *destination = [segue destinationViewController];
        
        destination.attachment = nil;
        
        destination.state = NEW;
    }
}
@end
