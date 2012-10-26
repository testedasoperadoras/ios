//
//  ComparacoesViewController.h
//  Operadoras3g
//
//  Created by Pedro Scocco on 9/1/12.
//  Copyright (c) 2012 Kubic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkManager.h"

@interface ComparacoesViewController : UIViewController <SpeedTestDelegate, NSURLConnectionDataDelegate>
{
    UIImageView *animationStart;
    UIImageView *animation;
}

@property (nonatomic) BOOL startTest;

@property (strong, nonatomic) NetworkManager *networkManager;

#pragma mark UI Elements
@property (weak, nonatomic) IBOutlet UILabel *speedDisplayLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedRegionSelection;

#pragma mark Carriers Speeds Table
@property (weak, nonatomic) IBOutlet UILabel *fieldClaroPre;
@property (weak, nonatomic) IBOutlet UILabel *fieldClaroPos;
@property (weak, nonatomic) IBOutlet UILabel *fieldOiPre;
@property (weak, nonatomic) IBOutlet UILabel *fieldOiPos;
@property (weak, nonatomic) IBOutlet UILabel *fieldVivoPre;
@property (weak, nonatomic) IBOutlet UILabel *fieldVivoPos;
@property (weak, nonatomic) IBOutlet UILabel *fieldTimPre;
@property (weak, nonatomic) IBOutlet UILabel *fieldTimPos;

#pragma mark user Info
@property (strong, nonatomic) NSString *operator;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *state;

#pragma mark Connection
@property (strong, nonatomic) NSURLConnection *connection;
@property (strong, nonatomic) NSMutableData *responseData;



@end
