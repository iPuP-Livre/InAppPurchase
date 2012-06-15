//
//  StoreDisplayTableViewController.m
//  InAppPurchase
//
//  Created by Marian PAUL on 11/03/12.
//  Copyright (c) 2012 iPuP SARL. All rights reserved.
//

#import "StoreDisplayTableViewController.h"
#import "ViewController.h"

@interface StoreDisplayTableViewController ()

@end

@implementation StoreDisplayTableViewController
@synthesize rootViewController = _rootViewController;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *buttonBack = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(backToRoot:)];
    self.navigationItem.leftBarButtonItem = buttonBack;
    
    self.title = @"Liste des achats";    
}

- (void) backToRoot:(id)sender {
    [_rootViewController dismissModalViewControllerAnimated:YES];    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _rootViewController.arrayToDisplay.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // on récupère le produit de la ligne
    SKProduct *product = [_rootViewController.arrayToDisplay objectAtIndex:indexPath.row];
    
    // formate le chiffre selon le pays
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];
    NSString *formattedPrice = [numberFormatter stringFromNumber:product.price];
    
    //NSLog(@"Produit : %@\nDescription : %@ \nPrix : %@, ID : %@",[product localizedTitle], [product localizedDescription], formattedPrice, [product productIdentifier]);
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ — %@", [product localizedTitle], formattedPrice];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    // on récupère le produit à acheter
    SKProduct *productToPurchase = [_rootViewController.arrayToDisplay objectAtIndex:indexPath.row];
    // on demande au manager d'acheter l'objet
    [[InAppPurchaseStoreManager sharedManager] wantToPurchaseProduct:productToPurchase];
}

@end
