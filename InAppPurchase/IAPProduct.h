//
//  IAPProduct.h
//  InAppPurchase
//
//  Created by Marian PAUL on 10/03/12.
//  Copyright (c) 2012 iPuP SARL. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kIdentifier @"identifier"
#define kPurchased @"purchased"

@interface IAPProduct : NSObject <NSCoding>
@property (nonatomic, retain) NSString *productID;
@property (assign) BOOL purchased;
@end
