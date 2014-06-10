//
//  DeclarationDetailViewController.m
//  Ilmoitus
//
//  Created by Alexander Bolhuis on 22-04-14.
//  Copyright (c) 2014 42IN12EWa. All rights reserved.
//

#import "DeclarationDetailViewController.h"
#import "DeclarationLine.h"

@interface DeclarationDetailViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *leidinggevende;
@property (weak, nonatomic) IBOutlet UITextView *opmerking;

@property (strong, nonatomic) NSMutableArray *declarationLines;
@property (weak, nonatomic) IBOutlet UIScrollView *scroll;

@end

@implementation DeclarationDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.scroll setScrollEnabled:YES];
    [self.scroll setContentSize:CGSizeMake(320, 831)];
    self.declarationLines = [[NSMutableArray alloc]init];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.declarationLines count];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DeclarationLine *line = (DeclarationLine *)[self.declarationLines objectAtIndex:indexPath];
    
    static NSString *simpleTableIdentifier = @"declarationLine";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    UILabel *dateLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *subTypeLabel = (UILabel *)[cell viewWithTag:2];
    UILabel *costLabel = (UILabel *)[cell viewWithTag:3];
    
    dateLabel.text = line.date;
    // TODO Get subtype
    subTypeLabel.text = @"Type";
    costLabel.text =[NSString stringWithFormat:@"€%.2f", line.cost];
    
    
    return cell;
}

@end