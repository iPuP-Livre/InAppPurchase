//
//  InAppPurchaseStoreManager.m
//  InAppPurchase
//
//  Created by Marian PAUL on 10/03/12.
//  Copyright (c) 2012 iPuP SARL. All rights reserved.
//

#import "InAppPurchaseStoreManager.h"
#import "IAPProduct.h"

@interface InAppPurchaseStoreManager(private)
- (void) retrieveListProductsFromSavedFile;
- (void) completeTransaction:(SKPaymentTransaction *)transaction;
- (void) restoreTransaction:(SKPaymentTransaction *)transaction;
- (void) failedTransaction:(SKPaymentTransaction *)transaction;
- (void) recordTransaction:(SKPaymentTransaction*) transaction;
@end

@implementation InAppPurchaseStoreManager
@synthesize delegate = _delegate;


- (void) retrieveListProductsFromSavedFile {

    // on récupère depuis le fichier avec NSCoding
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"products.myArchive"];
    NSData *data;
    NSKeyedUnarchiver *unarchiver;
    data = [[NSData alloc] initWithContentsOfFile:path];
    if(data)
    {
        // si le fichier contient des données, on désarchive
        unarchiver = [[NSKeyedUnarchiver alloc]                  initForReadingWithData:data];
        NSMutableArray *arrayArchived = [unarchiver decodeObjectForKey:@"Products"];
        _listOfProductsPurchasedOrNot = arrayArchived;
        [unarchiver finishDecoding];

    }
    
    if (!_listOfProductsPurchasedOrNot) {
        // le fichier n'existe pas, on le crée
        _listOfProductsPurchasedOrNot = [[NSMutableArray alloc] init];
        // ajout du premier produit
        IAPProduct *product1 = [[IAPProduct alloc] init];
        product1.productID = kIdProduit1;
        product1.purchased = NO;
        [_listOfProductsPurchasedOrNot addObject:product1];
        
        // ajout du second produit
        IAPProduct *product2 = [[IAPProduct alloc] init];
        product2.productID = kIdProduit2;
        product2.purchased = NO;
        [_listOfProductsPurchasedOrNot addObject:product2];
    }
}

// demande la liste des produits disponibles auprès de l'app Store
- (void) requestProductData
{
    // crée un tableau ne contenant que les identifiers disponibles
    // remarquez que la clé est le nom de l'objet NSString *productID de IAPProduct 
    NSArray *arrayOfIdentifiers = [_listOfProductsPurchasedOrNot valueForKey:@"productID"];
    // création de la requête
    SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers: [NSSet setWithArray:arrayOfIdentifiers]];
    // self est delegate de SKProductsRequest
    request.delegate = self; //[1]
    // on démarre
    [request start];
}

#pragma mark - SKProductsRequestDelegate methods
// appelée lorsque le delegate reçoit la réponse de l'App Store
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    if (!_listOfProductsAvailabled)
        _listOfProductsAvailabled = [[NSMutableArray alloc] init];

    // on enlève tous les objets
    [_listOfProductsAvailabled removeAllObjects];
    [_listOfProductsAvailabled addObjectsFromArray:response.products];
    
    // à vous d'afficher une vue pour présenter les données
    
    [_delegate inAppPurchaseStoreManager:self askToDisplayListOfProducts:_listOfProductsAvailabled];
    
    // on release ici la requête instanciée plus haut dans requestProductData
    request = nil;
}

#pragma mark - Buy methods

- (void) wantToPurchaseProduct:(SKProduct*) product {
    if ([SKPaymentQueue canMakePayments]) // [1]
    {
        SKPayment *payment = [SKPayment paymentWithProduct:product]; // [2]
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
    else 
    {
        // L'utilisateur a désactivé la possibilité d'acheter -> présenter une alert si besoin
    }    
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}

- (void) completeTransaction:(SKPaymentTransaction *)transaction
{
    // on enregistre
    [self recordTransaction: transaction];
    // on informe le delegate
    if([_delegate respondsToSelector:@selector(inAppPurchaseStoreManager:didPurchasedProduct:)])
    {
        [_delegate inAppPurchaseStoreManager:self didPurchasedProduct:transaction.payment.productIdentifier];
    }
    // on finit la transaction
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
    // on enregistre
    [self recordTransaction: transaction];
    // on informe le delegate
    if([_delegate respondsToSelector:@selector(inAppPurchaseStoreManager:didPurchasedProduct:)])
    {
        [_delegate inAppPurchaseStoreManager:self didPurchasedProduct:transaction.payment.productIdentifier];
    }
    // on finit la transaction
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // il y a eu une erreur dans l'achat    
    }
    // on finit la transaction
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) recordTransaction:(SKPaymentTransaction*) transaction 
{
    // on énumère pour mettre à YES le booléen du produit acheté
    for (IAPProduct *iapProduct in _listOfProductsPurchasedOrNot) {
        if ([iapProduct.productID isEqualToString:transaction.payment.productIdentifier]) {
            iapProduct.purchased = YES; 
        }
    }
    // on sauvegarde en avec NSCoding
    NSMutableData *data;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *archivePath = [documentsDirectory stringByAppendingPathComponent:@"products.myArchive"];
    NSKeyedArchiver *archiver;
    
    data = [NSMutableData data];
    archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:_listOfProductsPurchasedOrNot forKey:@"Products"];
    [archiver finishEncoding];
    [data writeToFile:archivePath atomically:YES];
}

// retourne un booléen selon si le produit a déjà été acheté ou non
- (BOOL) havePurchasedProduct:(NSString*) productID 
{
    for(IAPProduct *iapProduct in _listOfProductsPurchasedOrNot)
    {
        if ([iapProduct.productID isEqualToString:productID]) {
            return iapProduct.purchased;
        }  
    }
    return NO;
}

// notre manager
static InAppPurchaseStoreManager *sharedManager;

+ (InAppPurchaseStoreManager *)sharedManager
{
    @synchronized(self)
    {        
        if (!sharedManager)
        {
            sharedManager = [[InAppPurchaseStoreManager alloc] init];
            
            // on récupère la liste des produits stockés dans un fichier ou les préférences
            [sharedManager retrieveListProductsFromSavedFile];
            
            // on ajoute un observateur du store le plus tôt possible pour gérer les achats
            [[SKPaymentQueue defaultQueue] addTransactionObserver:sharedManager];
        }
        
        
        return sharedManager;
    }
    return sharedManager;
}

#pragma mark Singleton Methods

+ (id)allocWithZone:(NSZone *)zone
{    
    @synchronized(self) {    
        if (sharedManager == nil) {    
            sharedManager = [super allocWithZone:zone];            
            return sharedManager; 
        }
    }
    return nil;    
}
- (id)copyWithZone:(NSZone *)zone
{
    return self;    
}

@end
