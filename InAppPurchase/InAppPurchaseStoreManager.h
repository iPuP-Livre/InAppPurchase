//
//  InAppPurchaseStoreManager.h
//  InAppPurchase
//
//  Created by Marian PAUL on 10/03/12.
//  Copyright (c) 2012 iPuP SARL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#define kIdProduit1 @"fr.ipup.LivreInAppPurchase.001"
#define kIdProduit2 @"fr.ipup.LivreInAppPurchase.002"

@protocol InAppPurchaseStoreManagerDelegate;

@interface InAppPurchaseStoreManager : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
    NSMutableArray *_listOfProductsPurchasedOrNot;
    NSMutableArray *_listOfProductsAvailabled;
}
@property (nonatomic, assign) id<InAppPurchaseStoreManagerDelegate> delegate;

+ (InAppPurchaseStoreManager *)sharedManager;
- (void) requestProductData;
- (BOOL) havePurchasedProduct:(NSString*) productID;
- (void) wantToPurchaseProduct:(SKProduct*) product;
@end

@protocol InAppPurchaseStoreManagerDelegate <NSObject>
@optional
// informe le delegate de l'achat d'un produit
- (void)inAppPurchaseStoreManager:(InAppPurchaseStoreManager*)manager didPurchasedProduct:(NSString *)productId;
@required
// demande au delegate d'afficher la liste des produits
- (void)inAppPurchaseStoreManager:(InAppPurchaseStoreManager*)manager askToDisplayListOfProducts:(NSMutableArray*)list;
@end
