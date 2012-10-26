//
//  NetworkManager.m
//  Operadoras3g
//
//  Created by Pedro Scocco on 9/5/12.
//  Copyright (c) 2012 Kubic. All rights reserved.
//

#import "NetworkManager.h"
#import "Reachability.h"
#include <arpa/inet.h> 
#include <net/if.h> 
#include <ifaddrs.h> 
#include <net/if_dl.h>
#include <mach/mach_time.h>

const int kNumberOfSamples = 5;
const float kSampleInterval = 1.0;
const float kDelayTime = 2.0;

@implementation NetworkManager
@synthesize delegate = _delegate;
@synthesize testDelegate = _testDelegate;
@synthesize selectedServer = _selectedServer;
@synthesize connection = _connection;
@synthesize internetReach = _internetReach;
@synthesize hostReach = _hostReach;
@synthesize sampleArray = _sampleArray;

- (id)initWithDelegate: (id <ConnectionDelegate>)delegate
{
    self = [super init];
    if (self) {
        
        self.delegate = delegate;
        
        self.selectedServer = @"http://fisica.ufpr.br/kurumin/kurumin.iso";
        
        
        //        Reachability implementation
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reachabilityChanged:)
                                                     name:kReachabilityChangedNotification
                                                   object:nil];
        self.internetReach = [Reachability reachabilityForInternetConnection];
        [self.internetReach startNotifier];
        [self updateDelegateConnectionStatus:self.internetReach];
//        self.hostReach = [Reachability reachabilityWithHostname:self.selectedServer];        
//        [self.hostReach startNotifier];
    }
    return self;
}

- (void) reachabilityChanged: (NSNotification *) note
{
    Reachability *reach = [note object];
    
    [self updateDelegateConnectionStatus:reach];

}

- (void)updateDelegateConnectionStatus: (Reachability*)reach
{
    if (reach == self.internetReach) {
        if ([reach isReachableViaWiFi]) {
            [self.delegate didChangeConnectionStatus:@"WiFi"];
        } else if ([reach isReachableViaWWAN]) {
            [self.delegate didChangeConnectionStatus:@"Cellular Data"];
        } else {
            [self.delegate didChangeConnectionStatus:@"No Internet"];
        }
    } else {
        
    }
}

- (void)startDownloadWithDelegate:(id<SpeedTestDelegate>)testDelegate{
    
    self.testDelegate = testDelegate;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.selectedServer] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest: request delegate:self];
    if(connection) {
        self.connection = connection;
        self.sampleArray = [[NSMutableArray alloc] initWithCapacity:kNumberOfSamples+1];
    } else {
        NSLog(@"Failled connection");
    }
    
//    NSLog(@"GOO !");
//    initial = [NSDate date];
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://199.91.153.125/mmi1i91eavvg/d3gasioxz71aw43/photo_scape_362_Baixaki.rar"] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];
//    
//    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest: request delegate:self];
//    if(connection) {
//        self.connection = connection;
//    } else {
//        NSLog(@"Failled connection");
//    }
//    counter = 0;

}

- (void)testSpeed{
    countSamples++;
    if(countSamples < kNumberOfSamples) {
        [NSTimer scheduledTimerWithTimeInterval:kSampleInterval target:self selector:@selector(testSpeed) userInfo:nil repeats:NO];
    } else {
        [NSTimer scheduledTimerWithTimeInterval:kSampleInterval target:self selector:@selector(finishSpeedTest) userInfo:nil repeats:NO];
    }
    
    int sample = [self getDataCounters];
    [self.sampleArray addObject:[NSNumber numberWithInt:sample]];
//    mach_timebase_info_data_t timer;
//    mach_timebase_info(&timer);
//    
//    uint64_t twoSecs = 2000000000;
//    twoSecs *= timer.denom;
//    twoSecs /= timer.numer;
//    
//    uint64_t fiveSecs = 5000000000;
//    fiveSecs *= timer.denom;
//    fiveSecs /= timer.numer;
//    
//    uint64_t start_time = mach_absolute_time();
//    
//    while (mach_absolute_time() - start_time < twoSecs) {
//        
//    }
//    
//    NSInteger startData = [self getDataCounters];
//    uint64_t mid_time = mach_absolute_time();
//    
//    while (mach_absolute_time() - mid_time < fiveSecs) {
//        
//    }   
//    startData = [self getDataCounters] - startData;
//    
//    float speed = startData / 5.0;
//    speed *= 0.008;
//    
//    uint64_t now = mach_absolute_time();
//    int64_t elapsed = now - start_time;
//    elapsed *= timer.numer;
//    elapsed /= timer.denom;
//    NSLog(@"Elapsed time: %lld ns", elapsed);
//    NSLog(@"Calculated speed: %0.2f Kbps", speed);   
}

- (void)finishSpeedTest
{
    float maxSample = 0.0;
    float average = 0.0;
    float median = 0.0;
    int sample = [self getDataCounters];
    [self.sampleArray addObject:[NSNumber numberWithInt:sample]];
    for (int i = 1; i <= kNumberOfSamples; i++) {
        float aux = [[self.sampleArray objectAtIndex:i] integerValue];
        aux -= [[self.sampleArray objectAtIndex:i-1] integerValue];
        aux = aux / kSampleInterval;
        [self.sampleArray removeObjectAtIndex:i-1];
        [self.sampleArray insertObject:[NSNumber numberWithFloat:aux] atIndex:i-1];
//        NSLog(@"%0.2f KBps", aux / 1000);
        average += aux;
        if (aux > maxSample) {
            maxSample = aux;
        }
    }
    [self.sampleArray removeLastObject];
    NSSortDescriptor *highestToLowest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO];
    [self.sampleArray sortUsingDescriptors:[NSArray arrayWithObject:highestToLowest]];
    
    for (int i = 0; i < kNumberOfSamples; i++) {
        NSLog(@"%0.2f KBps", [[self.sampleArray objectAtIndex:i] floatValue]);
    }

    if (kNumberOfSamples % 2 == 0) {
        median = [[self.sampleArray objectAtIndex:kNumberOfSamples/2] floatValue];
        median += [[self.sampleArray objectAtIndex:kNumberOfSamples/2 -1] floatValue];
        median = median / 2;
    } else {
        median = [[self.sampleArray objectAtIndex:kNumberOfSamples/2] floatValue];
    }
    average /= kNumberOfSamples;
    
    NSLog(@"MEDIANA: %0.2f KBps", median/1000);
    NSLog(@"MEDIA: %0.2f KBps", average/1000);
    NSLog(@"MAIS ALTO: %0.2f KBps", maxSample/1000);
    
#warning fixed result demonstration               VVVVV
    float rand = (arc4random() % 20000) / 100;
    [self.testDelegate didFinishTestWithResult:rand + 400.0];
    [self.connection cancel];
}


- (NSInteger)getDataCounters
{
    BOOL   success;
    struct ifaddrs *addrs;
    const struct ifaddrs *cursor;
    const struct if_data *networkStatisc;
    
//    int WiFiSent = 0;
    int WiFiReceived = 0;
//    int WWANSent = 0;
//    int WWANReceived = 0;
    
    NSString *name=[[NSString alloc]init];
    
    success = getifaddrs(&addrs) == 0;
    if (success)
    {
        cursor = addrs;
        while (cursor != NULL)
        {
            name=[NSString stringWithFormat:@"%s",cursor->ifa_name];
//            NSLog(@"ifa_name %s == %@\n", cursor->ifa_name,name);
            // names of interfaces: en0 is WiFi ,pdp_ip0 is WWAN
            
            if (cursor->ifa_addr->sa_family == AF_LINK)
            {
                if ([name hasPrefix:@"en"])
                {
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
//                    WiFiSent+=networkStatisc->ifi_obytes;
                    WiFiReceived+=networkStatisc->ifi_ibytes;
//                    NSLog(@"WiFiSent %d ==%d",WiFiSent,networkStatisc->ifi_obytes);
//                    NSLog(@"WiFiReceived %d ==%d",WiFiReceived,networkStatisc->ifi_ibytes);
                }
                
//                if ([name hasPrefix:@"pdp_ip"])
//                {
//                    networkStatisc = (const struct if_data *) cursor->ifa_data;
//                    WWANSent+=networkStatisc->ifi_obytes;
//                    WWANReceived+=networkStatisc->ifi_ibytes;
//                    NSLog(@"WWANSent %d ==%d",WWANSent,networkStatisc->ifi_obytes);
//                    NSLog(@"WWANReceived %d ==%d",WWANReceived,networkStatisc->ifi_ibytes);
//                }
            }
            
            cursor = cursor->ifa_next;
        }
        
        freeifaddrs(addrs);
    }
    
    return WiFiReceived;
}

#pragma mark connectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    countSamples = 0;
    [NSTimer scheduledTimerWithTimeInterval:kDelayTime target:self selector:@selector(testSpeed) userInfo:nil repeats:NO];
    [self.testDelegate showAnimation];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Failed speed test with error: %@", error);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
//    float interval = [[NSDate date] timeIntervalSinceDate:initial];
//    NSLog(@"%d bytes em %f segundos", counter, interval);
}

@end
