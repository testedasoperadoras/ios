//
//  Operadoras3gViewController.h
//  Operadoras3g
//
//  Created by Pedro Scocco on 8/31/12.
//  Copyright (c) 2012 Kubic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "NetworkManager.h"

@interface Operadoras3gViewController : UIViewController <CLLocationManagerDelegate, ConnectionDelegate>
{
    NSInteger limit;
}
#pragma mark UI Elements
@property (weak, nonatomic) IBOutlet UILabel *operadoraField;
@property (weak, nonatomic) IBOutlet UILabel *cityField;
@property (weak, nonatomic) IBOutlet UILabel *stateField;
@property (weak, nonatomic) IBOutlet UILabel *connectionField;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;

#pragma mark Managers
@property (strong, nonatomic) NetworkManager *networkManager;
@property (strong, nonatomic) CLLocationManager *locationManager;

#pragma mark userInfo
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *state;
@property (nonatomic) NSInteger mcc;
@property (nonatomic) NSInteger mnc;

@end
