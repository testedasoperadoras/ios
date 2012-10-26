//
//  NetworkManager.h
//  Operadoras3g
//
//  Created by Pedro Scocco on 9/5/12.
//  Copyright (c) 2012 Kubic. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Reachability;

@protocol ConnectionDelegate <NSObject>
- (void)didChangeConnectionStatus:(NSString*)status;
@end

@protocol SpeedTestDelegate <NSObject>
- (void)didFinishTestWithResult:(float)result;
- (void)showAnimation;
@end

extern const int kNumberOfSamples;
extern const float kSampleInterval;
extern const float kDelayTime;

@interface NetworkManager : NSObject
{
    int countSamples;
}

- (id)initWithDelegate: (id <ConnectionDelegate>)delegate;
- (void)startDownloadWithDelegate:(id <SpeedTestDelegate>)testDelegate;

@property (strong, nonatomic) NSString *selectedServer;
@property (strong, nonatomic) NSURLConnection *connection;

@property (weak, nonatomic) id <ConnectionDelegate> delegate;
@property (weak, nonatomic) id <SpeedTestDelegate> testDelegate;

@property (strong, nonatomic) Reachability *internetReach;
@property (strong, nonatomic) Reachability *hostReach;

@property (strong, nonatomic) NSMutableArray *sampleArray;

@end
