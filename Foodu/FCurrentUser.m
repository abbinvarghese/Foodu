//
//  FCurrentUser.m
//  Foodu
//
//  Created by Abbin Varghese on 28/02/16.
//  Copyright © 2016 Paadam. All rights reserved.
//

#import "FCurrentUser.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "FLocationWarningViewController.h"

NSString *const firstLaunchKey = @"firstLaunchKey";
NSString *const userFacebookDefaultPassword = @"comPaadamFooduFacebookPassword";
@implementation FCurrentUser

static FCurrentUser *shareduser = nil;

+ (FCurrentUser*)sharedUser {
    if (shareduser == nil) {
        shareduser = [[FCurrentUser alloc] init];
    }
    return shareduser;
}

+ (void)resetSharedInstance {
    shareduser = nil;
}

- (id)init {
    if (self = [super init]) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        
        [self.locationManager requestWhenInUseAuthorization];
        
        [_locationManager startUpdatingLocation];
        if ([PFUser currentUser]) {
            self.email = [PFUser currentUser].email;
            self.name = [[PFUser currentUser]valueForKey:@"name"];
            self.userType = [[[PFUser currentUser]valueForKey:@"userType"] integerValue];
        }
    }
    return self;
}

+(BOOL)isFirstLaunch{
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:firstLaunchKey]) {
        return NO;
    }
    else{
        return YES;
    }
}

+(void)didFinishFirstLaunch{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:firstLaunchKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)isSessionValid{
    if ([PFUser currentUser]){
        return YES;
    }
    else{
        return NO;
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [FCurrentUser sharedUser].userlocation = [PFGeoPoint geoPointWithLocation:[locations lastObject]];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([appDelegate.window.rootViewController.presentedViewController isKindOfClass:[FLocationWarningViewController class]]) {
        [appDelegate.window.rootViewController.presentedViewController dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted){
        FLocationWarningViewController *con = [[FLocationWarningViewController alloc]initWithNibName:@"FLocationWarningViewController" bundle:[NSBundle mainBundle]];
        con.providesPresentationContextTransitionStyle = YES;
        con.definesPresentationContext = YES;
        con.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.window.rootViewController presentViewController:con animated:YES completion:^{
            
        }];
    }
}

+(void)signUpUserWithName:(NSString*)name email:(NSString*)email password:(NSString*)password success:(void (^)(BOOL success))success failure:(void (^)(NSString *error))failure{
    
    if (failure == nil) {
        failure = ^(NSString *error){};
    }
    if (success == nil) {
        success = ^(BOOL success){};
    }
    
    PFUser *user = [PFUser user];
    user.password = password;
    user.email = email;
    user.username = email;
    user[@"name"] = name;
    user[@"userType"] = @(EmailUser);
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {   // Hooray! Let them use the app now.
            if ([FCurrentUser isFirstLaunch]) {
                [FCurrentUser didFinishFirstLaunch];
            }
            [FCurrentUser sharedUser].email = user.email;
            [FCurrentUser sharedUser].name = [user objectForKey:@"name"];
            [FCurrentUser sharedUser].userType = EmailUser;
            success(succeeded);
        }
        else
        {
            NSString *errorString = [[error userInfo][@"error"] capitalizedString];   // Show the errorString somewhere and let the user try again.
            failure(errorString);
        }
    }];
}

+(void)logOutCurrentUser:(void (^)(BOOL success))success failure:(void (^)(NSString *error))failure{

        if (failure == nil) {
            failure = ^(NSString *error){};
        }
        if (success == nil) {
            success = ^(BOOL success){};
        }
    
        
        [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
            if (error == nil) {
                [FCurrentUser resetSharedInstance];
                if ([FCurrentUser sharedUser].userType == FaceBookUser) {
                    [[FBSDKLoginManager new] logOut];
                }
                success(YES);
            }
            else{
                NSString *errorString = [[error userInfo][@"error"] capitalizedString];
                failure(errorString);
            }
        }];
}

+(void)logInUserWithEmail:(NSString*)email password:(NSString*)password success:(void (^)(BOOL success))success failure:(void (^)(NSString *error))failure{
    [PFUser logInWithUsernameInBackground:email password:password
                                    block:^(PFUser *user, NSError *error) {
                                        if (user) {
                                            if ([FCurrentUser isFirstLaunch]) {
                                                [FCurrentUser didFinishFirstLaunch];
                                            }
                                            [FCurrentUser sharedUser].email = user.email;
                                            [FCurrentUser sharedUser].name = [user objectForKey:@"name"];
                                            [FCurrentUser sharedUser].userType = EmailUser;
                                            success(YES);
                                        } else {
                                            if ([error code] == 101) {
                                                NSString *errorString = @"Incorrect email/password";
                                                failure(errorString);
                                            }
                                            else{
                                                NSString *errorString = [[error userInfo][@"error"] capitalizedString];
                                            
                                                failure(errorString);
                                            }
                                        }
                                    }];
    
}

+(void)connectWithFacebookFromViewController:(UIViewController*)viewController success:(void (^)(BOOL success))success failure:(void (^)(NSString *error))failure{
    //    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[@"public_profile",@"email",@"user_friends"];
    
    if ([FBSDKAccessToken currentAccessToken]) {
        [[FBSDKLoginManager new] logOut];
    }
    
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    
    [login
     logInWithReadPermissions: permissionsArray
     fromViewController:viewController
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if (error) {
             failure(@"Failed to Sign in to Facebook");
         } else if (result.isCancelled) {
             failure(@"Facebook Sign in was canceled");
         } else {
             if ([FBSDKAccessToken currentAccessToken]) {
                 [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{ @"fields" : @"id,name,email,friends,picture.width(100).height(100)"}]startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                     if (!error) {
                         if ([result objectForKey:@"email"]) {
                             
                             PFQuery *query = [PFUser query];
                             [query whereKey:@"email" equalTo:[result objectForKey:@"email"]]; // find all the women
                             [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                                 
                                 if (objects.count==0) {
                                     PFUser *user = [PFUser user];
                                     user.password = userFacebookDefaultPassword;
                                     user.email = [result objectForKey:@"email"];
                                     user.username = [result objectForKey:@"email"];
                                     user[@"name"] = [result objectForKey:@"name"];
                                     user[@"userType"] = [NSNumber numberWithInteger:FaceBookUser];
                                     user[@"userlocation"] = [FCurrentUser sharedUser].userlocation;
                                     user[@"facebookId"] = [result objectForKey:@"id"];
                                     NSString *url = [[[result objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"];
                                     PFFile *image;
                                     if (url.length>0) {
                                        image = [PFFile fileWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
                                     }
                                     if (image) {
                                         user[@"profilePicture"] = image;
                                     }
                                     [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                         if (!error) {   // Hooray! Let them use the app now.
                                             if ([FCurrentUser isFirstLaunch]) {
                                                 [FCurrentUser didFinishFirstLaunch];
                                             }
                                             [FCurrentUser sharedUser].email = user.email;
                                             [FCurrentUser sharedUser].name = [user objectForKey:@"name"];
                                             [FCurrentUser sharedUser].userType = FaceBookUser;
                                             success(succeeded);
                                         }
                                         else
                                         {
                                            NSString *errorString = [[error userInfo][@"error"] capitalizedString];   // Show the errorString somewhere and let the user try again.
                                             failure(errorString);
                                         }
                                     }];
                                     
                                 }
                                 else{
                                     [PFUser logInWithUsernameInBackground:[result objectForKey:@"email"] password:userFacebookDefaultPassword
                                                                     block:^(PFUser *user, NSError *error) {
                                                                         if (user) {
                                                                             if ([FCurrentUser isFirstLaunch]) {
                                                                                 [FCurrentUser didFinishFirstLaunch];
                                                                             }
                                                                             [FCurrentUser sharedUser].email = user.email;
                                                                             [FCurrentUser sharedUser].name = [user objectForKey:@"name"];
                                                                             [FCurrentUser sharedUser].userType = FaceBookUser;
                                                                             success(YES);
                                                                         } else {
                                                                             NSString *errorString = [[error userInfo][@"error"] capitalizedString];
                                                                             failure(errorString);
                                                                         }
                                                                     }];
                                     
                                 }
                                 
                             }];
                         }
                         else{
                             failure(@"Couldn't regester a new account. Carte requires your email");
                         }
                     }
                 }];
             }
         }
     }];
}

@end
