//
//  ViewController.m
//  InAppPurchase
//
//  Created by Marian PAUL on 10/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "StoreDisplayTableViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize arrayToDisplay = _arrayToDisplay;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        UIButton *buttonStore = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [buttonStore addTarget:self action:@selector(askForListOfProducts:) forControlEvents:UIControlEventTouchUpInside];
        [buttonStore setTitle:@"Store" forState:UIControlStateNormal];
        [buttonStore setFrame:CGRectMake(30, 30, 100, 30)];
        [self.view addSubview:buttonStore];
        
        [InAppPurchaseStoreManager sharedManager].delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


- (void) askForListOfProducts:(id)sender {
    // demande à l'App Store la liste des produits
    [[InAppPurchaseStoreManager sharedManager] requestProductData];
} 

#pragma mark - InAppPurchaseStoreManager delegate
- (void) inAppPurchaseStoreManager:(InAppPurchaseStoreManager *)manager askToDisplayListOfProducts:(NSMutableArray *)list {
    
    // on récupère le tableau
    self.arrayToDisplay = list;
    
    StoreDisplayTableViewController *storeDisplayViewController = [[StoreDisplayTableViewController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:storeDisplayViewController];
    storeDisplayViewController.rootViewController = self; //[1]
    // on affiche la vue
    [self presentModalViewController:navController animated:YES];
}

- (void)inAppPurchaseStoreManager:(InAppPurchaseStoreManager*)manager didPurchasedProduct:(NSString *)productId {
    NSLog(@"Vous venez d'acheter %@", productId);    
}

@end
