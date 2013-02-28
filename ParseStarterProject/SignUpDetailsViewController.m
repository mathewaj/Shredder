//
//  SignUpDetailsViewController.m
//  Shredder
//
//  Created by Shredder on 14/02/2013.
//
//

#import "SignUpDetailsViewController.h"
#import "PhoneNumberManager.h"


@interface SignUpDetailsViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SignUpDetailsViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        // Get ordered list of Country Code Information Objects,
        self.countryCodeInformationList = [PhoneNumberManager getListOfAllCountryCodeInformationObjects];
        
        for(CountryCodeInformation *info in self.countryCodeInformationList){
            NSLog([info countryName]);
        }
        


        
    }
    
    return self;
}

-(void)viewDidLoad{
    
    [super viewDidLoad];
    
    // Set up table view
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [self.countryCodeInformationList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CountryCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    CountryCodeInformation *countryCodeInfo = [self.countryCodeInformationList objectAtIndex:indexPath.row];
    cell.textLabel.text = countryCodeInfo.countryName;
    if(countryCodeInfo.countryCallingCode){
        cell.detailTextLabel.text = [@"+" stringByAppendingString:countryCodeInfo.countryCallingCode];
    }
    
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate countrySelected:[self.countryCodeInformationList objectAtIndex:indexPath.row]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelButtonPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}
@end
