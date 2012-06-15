//
//  ViewController.h
//  InAppPurchase
//
//  Created by Marian PAUL on 10/03/12.
//  Copyright (c) 2012 iPuP SARL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InAppPurchaseStoreManager.h"

@interface ViewController : UIViewController <InAppPurchaseStoreManagerDelegate>

@property (nonatomic, retain) NSMutableArray *arrayToDisplay;

@end
