//
//  DeclarationLinesTableViewController.m
//  Ilmoitus
//
//  Created by Sjors Boom on 13/06/14.
//  Copyright (c) 2014 42IN12EWa. All rights reserved.
//

#import "DeclarationLinesTableViewController.h"
#import "NewDeclarationLineViewController.h"
#import "DeclarationLine.h"

@interface DeclarationLinesTableViewController ()
@property (strong, nonatomic) IBOutlet UITableView *table;

@end

@implementation DeclarationLinesTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.table reloadData];
}

-(void)setupToolBar
{
    UIBarButtonItem *add = [[UIBarButtonItem alloc]initWithTitle:@"+" style:UIBarButtonSystemItemAdd target:self action:@selector(addNew)];
    
    self.navigationItem.rightBarButtonItem = add;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Regels";
    
    if(self.state != VIEW)
    {
        [self setupToolBar];
    }
}

-(void)addNew
{
    [self performSegueWithIdentifier:@"newLine" sender:self];
}

-(IBAction)unwindToLines:(UIStoryboardSegue *)segue
{
    NewDeclarationLineViewController * source = [segue sourceViewController];
    switch (source.state)
    {
        case NEW:
            if(source.declarationLine != nil)
            {
                [self.declaration.lines addObject:source.declarationLine];
                [self.table reloadData];
            }
            break;
        case EDIT:
            if(source.declarationLine!=nil)
            {
                NSIndexPath *index = [self.table indexPathForSelectedRow];
                [self.declaration.lines replaceObjectAtIndex:index.row withObject:source.declarationLine];
                [self.table reloadData];
            }
            else
            {
                [self.declaration.lines removeObjectAtIndex:[self.table indexPathForSelectedRow].row];
                [self.table reloadData];
            }
            break;
            
        default:
            break;
    }
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
    return [self.declaration.lines count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
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
        [self.declaration.lines removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return NO;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"viewLine"])
    {
        NewDeclarationLineViewController *destination = [segue destinationViewController];

        NSIndexPath *path = [self.table indexPathForSelectedRow];
        DeclarationLine *line = [self.declaration.lines objectAtIndex:path.row];
        
        destination.declarationLine = line;
        
        if(self.state == NEW)
        {
            destination.state = EDIT;
        }
        else
        {
            destination.state = self.state;
        }
    }
    else if([[segue identifier] isEqualToString:@"newLine"])
    {
        NewDeclarationLineViewController *destination = [segue destinationViewController];
        
        destination.declarationLine = nil;
        
        destination.state = NEW;
    }
}
@end
