//
//  ComparacoesViewController.m
//  Operadoras3g
//
//  Created by Pedro Scocco on 9/1/12.
//  Copyright (c) 2012 Kubic. All rights reserved.
//

#import "ComparacoesViewController.h"
#import "NetworkManager.h"

@interface ComparacoesViewController ()

@end

@implementation ComparacoesViewController
@synthesize startTest = _startTest;
@synthesize networkManager = _networkManager;
@synthesize speedDisplayLabel = _speedDisplayLabel;
@synthesize segmentedRegionSelection = _segmentedRegionSelection;
@synthesize operator = _operator;
@synthesize city = _city;
@synthesize state = _state;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self segmentedControlChangedIndex:nil];
}

- (void)viewDidUnload
{
    [self setSpeedDisplayLabel:nil];
    [self setSegmentedRegionSelection:nil];
    [self setFieldClaroPre:nil];
    [self setFieldClaroPos:nil];
    [self setFieldOiPre:nil];
    [self setFieldOiPos:nil];
    [self setFieldVivoPre:nil];
    [self setFieldVivoPos:nil];
    [self setFieldTimPre:nil];
    [self setFieldTimPos:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.startTest) {
        [self performSpeedTest];
    }
}

- (void)performSpeedTest
{
    [self.networkManager startDownloadWithDelegate:self];
}

- (void)showAnimation {
    animationStart = [[UIImageView alloc] initWithFrame:CGRectMake(14, 87.5, 0, 50)];
    animationStart.image = [UIImage imageNamed:@"fill_start.png"];
    [animationStart setAlpha:0.9f];
    [animationStart setClipsToBounds:YES];
    [self.view addSubview:animationStart];
    
    
    animation = [[UIImageView alloc] initWithFrame:CGRectMake(26, 82.4, 0, 55.6)];
    animation.image = [UIImage imageNamed:@"fill_blue.png"];
    [animation setAlpha:0.9f];
    [animation setClipsToBounds:YES];
    [animation setContentMode:UIViewContentModeScaleToFill];
    
    [self.view addSubview:animation];
    
    float animDuration = (kNumberOfSamples * kSampleInterval) + kDelayTime;
    
    [UIView animateWithDuration:animDuration*0.047
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^(void) {
                         animationStart.frame = CGRectMake(12, 82.4, 14, 55.6);
                     }
                     completion:NULL];
    
    [UIView animateWithDuration:animDuration*0.953
                          delay:animDuration*0.048
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(void) {
                         animation.frame = CGRectMake(26, 82.4, 282, 55.6);
                     }
                     completion:NULL];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (IBAction)segmentedControlChangedIndex:(id)sender {
    if (self.segmentedRegionSelection.selectedSegmentIndex == 0) {
        self.fieldClaroPre.text = @"102.43 KBps";
        self.fieldClaroPos.text = @"212.14 KBps";
        self.fieldOiPre.text = @"108.02 KBps";
        self.fieldOiPos.text = @"234.02 KBps";
        self.fieldTimPre.text = @"98.87 KBps";
        self.fieldTimPos.text = @"206.98 KBps";
        self.fieldVivoPre.text = @"121.50 KBps";
        self.fieldVivoPos.text = @"194.09 KBps";
    } else if (self.segmentedRegionSelection.selectedSegmentIndex == 1) {
        self.fieldClaroPre.text = @"132.94 KBps";
        self.fieldClaroPos.text = @"254.93 KBps";
        self.fieldOiPre.text = @"131.12 KBps";
        self.fieldOiPos.text = @"264.90 KBps";
        self.fieldTimPre.text = @"112.05 KBps";
        self.fieldTimPos.text = @"234.80 KBps";
        self.fieldVivoPre.text = @"131.90 KBps";
        self.fieldVivoPos.text = @"229.81 KBps";
    } else {
        self.fieldClaroPre.text = @"250.23 KBps";
        self.fieldClaroPos.text = @"452.92 KBps";
        self.fieldOiPre.text = @"232.90 KBps";
        self.fieldOiPos.text = @"498.50 KBps";
        self.fieldTimPre.text = @"262.11 KBps";
        self.fieldTimPos.text = @"512.44 KBps";
        self.fieldVivoPre.text = @"269.06 KBps";
        self.fieldVivoPos.text = @"523.17 KBps";
    }
}

- (IBAction)backTapped:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)restartTest:(id)sender {
#warning Verificar se ja nao tem um teste em andamento
    self.speedDisplayLabel.text = @"";
    [self performSpeedTest];
    
}

- (void)didFinishTestWithResult:(float)result
{
    [UIView animateWithDuration:0.5f animations:^{
        animation.alpha = 0.0f;
        animationStart.alpha = 0.0f;
    } completion:^(BOOL finished) {
        animation = nil;
        animationStart = nil;
        
#warning Medida em KBps
        self.speedDisplayLabel.text = [NSString stringWithFormat:@"%0.2f KBps", result];
    }];
    
    NSString *postBody = [NSString stringWithFormat:@"operator=%@&city=%@&speed=%0.2f", self.operator, self.city, result];
    
    NSMutableURLRequest *request = [NSMutableURLRequest
									requestWithURL:[NSURL URLWithString:@"http://testedasoperadoras.com/teste.php"]];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[postBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (connection) {
        self.connection = connection;
        self.responseData = [[NSMutableData alloc] init];
    }
    
}

#pragma mark Connection delegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.connection = nil;
    self.responseData = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (connection == self.connection) {
        NSString *resp = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
        
        NSLog(@"%@", resp);
        
        resp = [resp substringToIndex:1];
        
        if ([resp isEqualToString:@"1"]) {
            NSLog(@"Worked");
        } else {
            NSLog(@"noot");
        }
    }
}


@end
