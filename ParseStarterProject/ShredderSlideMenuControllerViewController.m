//
//  ShredderSlideMenuControllerViewController.m
//  ParseStarterProject
//
//  Created by Alan Mathews on 20/11/2012.
//
//

#import "ShredderSlideMenuControllerViewController.h"
#import "MyLogInViewController.h"
#import "MySignUpViewController.h"
#import "AllMessagesViewController.h"
#import "AllReportsViewController.h"
#import "ContactsTableViewController.h"
#import "MBProgressHUD.h"
#import <AddressBook/AddressBook.h>
#import "Contact+Create.h"
#import "UIImage+ResizeAdditions.h"


@interface ShredderSlideMenuControllerViewController ()

@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;
@property (nonatomic, assign) UIBackgroundTaskIdentifier messagePostBackgroundTaskId;
@property (nonatomic, strong) PFFile *photoFile;

@end

@implementation ShredderSlideMenuControllerViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        self.slideMenuDataSource = self;
        
        // Add notification to notify when app enters background
        // Method called may log user out if settings require it
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
    }
    return self;
}

#pragma mark - SASlideMenuDataSource
// The SASlideMenuDataSource is used to provide the initial segueid that represents the initial visibile view controller and to provide eventual additional configuration to the menu button

-(NSString*)initialSegueId{
    return @"LogOut";
}

-(void) configureMenuButton:(UIButton *)menuButton{
    
    menuButton.frame = CGRectMake(0, 0, 40, 29);
    [menuButton setImage:[UIImage imageNamed:@"menuicon.png"] forState:UIControlStateNormal];
    [menuButton setBackgroundImage:[UIImage imageNamed:@"menu.png"] forState:UIControlStateNormal];
    [menuButton setBackgroundImage:[UIImage imageNamed:@"menuhighlighted.png"] forState:UIControlStateHighlighted];
    [menuButton setAdjustsImageWhenHighlighted:NO];
    [menuButton setAdjustsImageWhenDisabled:NO];
}

#pragma mark - Segue Preparation
// This is used to pass on the UIManagedDocument pointer
// This is used to configure the destination view controllers

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"LogOut"])
    {
        // Log out any existing user
        [PFUser logOut];
        
        // Configure log in controller
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        MyLogInViewController *logInViewController = [navController.viewControllers lastObject];
        
        logInViewController.fields = PFLogInFieldsUsernameAndPassword
        | PFLogInFieldsLogInButton
        | PFLogInFieldsSignUpButton
        | PFLogInFieldsPasswordForgotten;
        logInViewController.delegate = self;
        
        // Configure sign up controller
        MySignUpViewController *signUpViewController = [[MySignUpViewController alloc] init];
        logInViewController.signUpController = signUpViewController;
        logInViewController.signUpController.delegate = self;
        logInViewController.signUpController.fields = PFSignUpFieldsUsernameAndPassword | PFSignUpFieldsSignUpButton | PFSignUpFieldsDismissButton;
        
    } else if([segue.identifier isEqualToString:@"Messages"])
    {
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        
        AllMessagesViewController *controller = [navController.viewControllers lastObject];
        
        controller.contactsDatabase = self.contactsDatabase;
        
    } else if([segue.identifier isEqualToString:@"Contacts"])
    {
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        
        ContactsTableViewController *controller = [navController.viewControllers lastObject];
        
        controller.contactsDatabase = self.contactsDatabase;
        
    } else if([segue.identifier isEqualToString:@"Reports"])
    {
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        
        AllReportsViewController *controller = [navController.viewControllers lastObject];
        
        controller.contactsDatabase = self.contactsDatabase;
    }
    
}

#pragma mark - Login/SignUp Delegate Calls
// These are used to control the data which may be entered in the fields
// These are used to open the database when login or signup is successful

// Sent to the delegate to determine whether the log in request should be submitted to the server
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    
    // Check if both fields are completed
    if (username && password && username.length != 0 && password.length != 0) {
        return YES; // Begin login process
    }
    
    [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                message:@"Make sure you fill out all of the information!"
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
    return NO; // Interrupt login process
}

- (void)logInViewController:(PFLogInViewController *)controller
               didLogInUser:(PFUser *)user {
    
    // Save username for future logins
    [[NSUserDefaults standardUserDefaults] setObject:[user username] forKey:@"mostRecentUsername"];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:controller.view animated:YES];
    hud.labelText = @"Loading...";
    
    // Reset password field
    controller.logInView.passwordField.text = @"";
    
    // Set the device's installation object to this user
    PFInstallation *installation = [PFInstallation currentInstallation];
    [installation setObject:[PFUser currentUser] forKey:@"owner"];
    [installation saveEventually];
    
    // Get access to the database
    if (!self.contactsDatabase) {
        [self createDatabase];
    } else {
        [self databaseIsReady];
    }
    
    // Send welcome message!
    [self sendWelcomeMessage];
}

// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    
    BOOL informationComplete = YES;
    
    // loop through all of the submitted data
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || field.length == 0) { // check completion
            informationComplete = NO;
            break;
        }
    }
    
    // Display an alert if a field wasn't completed
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                    message:@"Make sure you fill out all of the information!"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        
        // Or display an alert if email address not valid
    } else if(![self NSStringIsValidEmail:[info objectForKey:@"username"]]){
        
        [[[UIAlertView alloc] initWithTitle:@"Invalid Email Address"
                                    message:@"Please enter a valid email address!"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        
        informationComplete = NO;
    }
    
    return informationComplete;
}

-(BOOL)NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    
    // Save username for future logins
    [[NSUserDefaults standardUserDefaults] setObject:[user username] forKey:@"mostRecentUsername"];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:signUpController.view animated:YES];
    hud.labelText = @"Loading...";
    
    signUpController.signUpView.passwordField.text = @"";
    
    // Setting the device's installation to this user
    PFInstallation *installation = [PFInstallation currentInstallation];
    [installation setObject:[PFUser currentUser] forKey:@"owner"];
    [installation saveEventually];
    
    
    if (!self.contactsDatabase) {
        
        // Get access to the database
        [self createDatabase];
        
    } else {
        
        // Database is ready so scan address book for new contacts
        [self databaseIsReady];
    }
}

- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    
}

#pragma mark - Database Creation and Address Book Import

-(void)createDatabase{
    
    // Create UIManagedDocument to access database
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"MyDocument.md"];
    self.contactsDatabase = [[UIManagedDocument alloc] initWithFileURL:url];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    self.contactsDatabase.persistentStoreOptions = options;
    
    // File exists so open
    if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
        
        [self.contactsDatabase openWithCompletionHandler:^(BOOL success) {
            
            if (success) [self databaseIsReady];
            if (!success) NSLog(@"couldn’t open document at %@", url);
        }];
        
    } else {
        
        // File does not exist so create
        [self.contactsDatabase saveToURL:url forSaveOperation:UIDocumentSaveForCreating
                       completionHandler:^(BOOL success) {
                           if (success) [self databaseIsReady];
                           if (!success) NSLog(@"couldn’t create document at %@", url);
                       }];
    }

}

// Every time database is opened, scan for new contacts
-(void)databaseIsReady{
    
    // Initialise address book helper
    self.addressBookHelper = [[AddressBookHelper alloc] init];
    self.addressBookHelper.delegate = self;
    
    // Scan for new contacts, this will return with delegate method below when complete
    self.addressBookHelper.contactsDatabase = self.contactsDatabase;
    [self.addressBookHelper retrieveAddressBookContacts];
}

// When Address Book Helper object returns with array of contacts, fire method to extract new contacts to database
-(void)addressBookHelper:(AddressBookHelper *)addressBookHelper finishedLoading:(NSArray *)people
{

    // If there are new contacts process them
    if([people count]!=0)
    {
        [self.addressBookHelper fetchAddressBookData:people IntoDocument:self.contactsDatabase];
      
    // Otherwise proceed to messages page
    } else {
        [self finishedMatchingContacts];
    }
    
}

-(void)finishedMatchingContacts
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    [self performSegueWithIdentifier:@"Messages" sender:self];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)addressBookHelperDeniedAccess:(AddressBookHelper *)addressBookHelper{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Shredder will not function fully without access to contacts. \n\n Please enable access through your device settings page" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
}

-(void)addressBookHelperError:(AddressBookHelper *)addressBookHelper{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"There was an error accessing your contacts" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

#pragma mark - Handle App Backgrounding
// This is used if the application is sent to the background
// If the user settings request it, on re-launch the user will be logged out
// And presented with a modal login screen which acts like the segue login screen

-(void)appDidEnterBackground
{
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"passwordLockSetting"] isEqualToNumber:[NSNumber numberWithBool:YES]])
    {
        [self dismissModalViewControllerAnimated:NO];
        [self presentLoginScreen:self];
    }
    
}

-(void)presentLoginScreen:(UIViewController *)controller
{
    [PFUser logOut];
    
    MyLogInViewController *logInViewController = [[MyLogInViewController alloc] init];
    logInViewController.fields = PFLogInFieldsUsernameAndPassword
    | PFLogInFieldsLogInButton
    | PFLogInFieldsSignUpButton
    | PFLogInFieldsPasswordForgotten;
    logInViewController.delegate = self;
    
    MySignUpViewController *signUpViewController = [[MySignUpViewController alloc] init];
    logInViewController.signUpController = signUpViewController;
    logInViewController.signUpController.delegate = self;
    logInViewController.signUpController.fields = PFSignUpFieldsUsernameAndPassword | PFSignUpFieldsSignUpButton | PFSignUpFieldsDismissButton;
    
    [controller presentModalViewController:logInViewController animated:NO];
}

-(void)sendWelcomeMessage
{
    [self shouldUploadImage];
    
    PFUser *Shredder = [PFQuery getUserObjectWithId:@"h6PDNLxCvW"];
    
    PFObject *message = [PFObject objectWithClassName:@"Message"];
    [message setObject:@"Welcome to Shredder!\n\nThis new private messaging app is designed to ensure that sensitive information is permanently erased once it has been read.\n\nImages may be attached to your messages, please tap on the thumbnail in the below right to view.\n\nWhen you are finished reading, please press the Shredder button below to delete the message forever." forKey:@"body"];
    [message setObject:Shredder forKey:@"sender"];
    [message setObject:[PFUser currentUser] forKey:@"recipient"];
    [message setObject:[NSNumber numberWithBool:NO] forKey:@"report"];
    
    // Handle attached image
    if(self.photoFile)
    {
        [message setObject:self.photoFile forKey:@"attachedImage"];
    }
    
    PFACL *messageACL = [PFACL ACL];
    [messageACL setReadAccess:YES forUser:[PFUser currentUser]];
    [messageACL setWriteAccess:YES forUser:[PFUser currentUser]];
    //[messageACL setReadAccess:YES forUser:self.recipientUser];
    //[messageACL setWriteAccess:YES forUser:self.recipientUser];
    
    message.ACL = messageACL;
    
    // Request a background execution task to allow us to finish uploading
    // the message even if the app is sent to the background
    self.messagePostBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.messagePostBackgroundTaskId];
    }];
    
    [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        
        if(succeeded){
            
            // Create our installation query
            PFQuery *pushQuery = [PFInstallation query];
            [pushQuery whereKey:@"owner" equalTo:[PFUser currentUser]];
            
            // Send push notification to query
            PFPush *push = [[PFPush alloc] init];
            [push setQuery:pushQuery];
            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"You have received a message on Shredder", @"alert",
                                  @"Increment", @"badge",
                                  @"chainsaw-02.wav", @"sound",
                                  nil];
            [push setData:data];
            [push sendPushInBackground];
        } else {
            
            // No welcome message, doh
            
        }
        
        [[UIApplication sharedApplication] endBackgroundTask:self.messagePostBackgroundTaskId];
    }];
}

- (BOOL)shouldUploadImage {
    // Resize the image to be square (what is shown in the preview)
    UIImage *anImage = [UIImage imageNamed:@"surferatsunset.jpg"];
    UIImage *resizedImage = [anImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit
                                                          bounds:CGSizeMake(560.0f, 560.0f)
                                            interpolationQuality:kCGInterpolationHigh];
    
    // Get an NSData representation of our images. We use JPEG 

    NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.8f);
    if (!imageData) {
        return NO;
    }
    
    // Create the PFFiles and store them in properties since we'll need them later
    self.photoFile = [PFFile fileWithData:imageData];
    
    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
    }];
    
    [self.photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Image uploaded successfully");
        } else {
            NSLog(@"Image failed to upload");
        }
        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
    }];
    
    return YES;
    
}


@end
