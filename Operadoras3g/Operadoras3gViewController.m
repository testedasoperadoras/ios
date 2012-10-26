//
//  Operadoras3gViewController.m
//  Operadoras3g
//
//  Created by Pedro Scocco on 8/31/12.
//  Copyright (c) 2012 Kubic. All rights reserved.
//

#import "Operadoras3gViewController.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreLocation/CoreLocation.h>
#import "ComparacoesViewController.h"
#import "NetworkManager.h"
#import "Reachability.h"

@interface Operadoras3gViewController ()

@end

@implementation Operadoras3gViewController
@synthesize operadoraField = _operadoraField;
@synthesize cityField = _downloadSpeedField;
@synthesize stateField = _stateField;
@synthesize connectionField = _uploadSpeedField;
@synthesize progressBar = _progressBar;
@synthesize networkManager = _networkManager;
@synthesize locationManager = _locationManager;
@synthesize city = _city;
@synthesize state = _state;
@synthesize mcc = _mcc;
@synthesize mnc = _mnc;

#pragma mark viewLifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
   

//    Finding user`s carrier and country
    CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netinfo subscriberCellularProvider];
    self.mcc = [carrier.mobileCountryCode integerValue];
    self.mnc = [carrier.mobileNetworkCode integerValue];
    NSString *operadora = [self operadoraString:self.mnc];
#warning uncomment
//    if (operadora) {
//        self.operadoraField.text = [NSString stringWithFormat:@"%@", operadora];
//    } else {
//        self.operadoraField.text = [NSString stringWithFormat:@"%@", [carrier carrierName]];
//        self.mnc = 0;
//    }
    
//    Finding user`s location
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyThreeKilometers];
    [self.locationManager startUpdatingLocation];
    
//    Finding user`s connection type
    self.networkManager = [[NetworkManager alloc] initWithDelegate:self];   
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.locationManager startUpdatingLocation];
}

- (void)viewDidUnload
{
    [self setOperadoraField:nil];
    [self setCityField:nil];
    [self setConnectionField:nil];
    [self setProgressBar:nil];
    [self setStateField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [self.locationManager stopUpdatingLocation];
    
    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        for (CLPlacemark * placemark in placemarks) {
            self.city = [placemark locality];
            self.state = [placemark administrativeArea];
#warning uncomment
//            self.cityField.text =self.city;
//            self.stateField.text = self.state;
        }
    }];
}

- (void)didChangeConnectionStatus:(NSString *)status
{
#warning uncoment
//    self.connectionField.text = status;
}

- (IBAction)testeConnectionTapped:(id)sender {
    
#warning Faltam as verificacoes antes de testar a velocidade (Rede, operadora, Pais)
    
    [self performSegueWithIdentifier:@"speedSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"speedSegue"]) {
        [segue.destinationViewController setNetworkManager:self.networkManager];
        [segue.destinationViewController setStartTest:YES];
        [segue.destinationViewController setOperator:self.operadoraField.text];
        [segue.destinationViewController setCity:self.city];
    } else {
        [segue.destinationViewController setNetworkManager:self.networkManager];
        [segue.destinationViewController setStartTest:NO];
    }

}

- (NSString*)operadoraString: (NSInteger) mobileNC
{
    NSString *operadora;
    switch (mobileNC) {
        case 2:
            operadora = @"TIM";
            break;
        case 3:
            operadora = @"TIM";
            break;
        case 4:
            operadora = @"TIM";
            break;
        case 8:
            operadora = @"TIM";
            break;
        case 5:
            operadora = @"Claro";
            break;
        case 6:
            operadora = @"Vivo";
            break;
        case 10:
            operadora = @"Vivo";
            break;
        case 11:
            operadora = @"Vivo";
            break;
        case 23:
            operadora = @"Vivo";
            break;
        case 16:
            operadora = @"Oi";
            break;
        case 24:
            operadora = @"Oi";
            break;
        case 31:
            operadora = @"Oi";
            break;
            
        default:
            operadora = nil;
            break;
    }
    return operadora;
}


@end
