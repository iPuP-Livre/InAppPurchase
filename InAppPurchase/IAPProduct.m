//
//  IAPProduct.m
//  InAppPurchase
//
//  Created by Marian PAUL on 10/03/12.
//  Copyright (c) 2012 iPuP SARL. All rights reserved.
//

#import "IAPProduct.h"

@implementation IAPProduct
@synthesize productID = _productID, purchased = _purchased;

- (id) initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.productID = [coder decodeObjectForKey:kIdentifier];
        self.purchased = [coder decodeBoolForKey:kPurchased];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.productID forKey:kIdentifier];
    [coder encodeBool:self.purchased forKey:kPurchased];
}

@end
