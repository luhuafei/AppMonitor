//
//  AppMonitor.m
//  AppMonitor
//
//  Created by RAHUL CK on 11/4/16.
//  Copyright © 2016 Robosoft Technologies Pvt Ltd. All rights reserved.
//

#import "AppMonitor.h"
#import "AppMonitorContants.h"
#import "AppMonitorManager.h"
#import "AppMonitorLogger.h"
#import "AppMonitorEvent.h"

#define  COPY_RIGHTS @"Copyright © 2016 Robosoft Technologies Pvt Ltd. All rights reserved."

@interface AppMonitor ()

@property (nonatomic,assign) BOOL isInitialized;

@property (nonatomic ,strong) AppMonitorManager *monitorManager;

@end

@implementation AppMonitor

+ (AppMonitor *)sharedSDK
{
    static AppMonitor *appMonitor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        appMonitor = [AppMonitor new];
    });
    
    return appMonitor;
}

-(instancetype) init
{
    self = [super init];
   
    if (self) {
        self.isInitialized = NO;
        
        self.monitorManager = [[AppMonitorManager alloc]init];
    }
    return self;
}

+(void) initializeWithAPIKey:(NSString*)apiKey logLevel:(AppMonitorLoggingLevel)inLogLevel
{
    if ([[self validAPIkeys] containsObject:apiKey]) {
       
        if ([[AppMonitor sharedSDK]isInitialized]) {
          
            [[AppMonitorLogger shared]Log:LOG_MESSAGE_SDK_ALREADY_INITIALIZED withLogLevel:AppMonitorLoggingLevelMinimal];
            

        }
        else
        {
            [[AppMonitor sharedSDK]setIsInitialized:YES];
            [[AppMonitorLogger shared]setLoggingLevel:inLogLevel];
            [[AppMonitorLogger shared]LogFrameworkVersion];
            [[AppMonitorLogger shared]LogFrameworkCopyRights];


            
            [[AppMonitorLogger shared]Log:LOG_MESSAGE_SDK_INITIALIZED withLogLevel:AppMonitorLoggingLevelAllLogs];
            [[[AppMonitor sharedSDK]monitorManager]startMonitor];

        }
    }
    else
    {
        [[AppMonitorLogger shared]Log:LOG_MESSAGE_SDK_INVALID_APIKEY withLogLevel:AppMonitorLoggingLevelErrors];
        
        @throw NSInvalidArgumentException;
    }
    
}
-(void) postEvent:(NSString*) eventName withAttributes:(NSArray*)attributes
{
    if ([self isInitialized])
    {
        AppMonitorEvent *event = [[AppMonitorEvent alloc]initWithName:eventName attributes:attributes];
        [event postEvent];
 
    }
    else
    {
        [[AppMonitorLogger shared]Log:LOG_MESSAGE_SDK_NOT_INITIALIZED
                                                 withLogLevel:AppMonitorLoggingLevelErrors];
    }
}
-(NSInteger) appLaunchCount
{
    NSInteger appLaunchCount = 0;
    
    if ([self isInitialized])
    {
        appLaunchCount = [self.monitorManager appLaunchCount];
        
    }
    else
    {
        [[AppMonitorLogger shared]Log:LOG_MESSAGE_SDK_NOT_INITIALIZED
                         withLogLevel:AppMonitorLoggingLevelErrors];
    }
    return appLaunchCount;
}

-(NSTimeInterval) appSpentTime
{
    NSTimeInterval appSpentTime = 0.0;
   
    if ([self isInitialized])
    {
        appSpentTime = [self.monitorManager appSpentTime];
        
    }
    else
    {
        [[AppMonitorLogger shared]Log:LOG_MESSAGE_SDK_NOT_INITIALIZED
                         withLogLevel:AppMonitorLoggingLevelErrors];
    }
    return appSpentTime;

}

-(void)dealloc
{
    NSString *logMessage = [NSString stringWithFormat:@"Deallocated %@",NSStringFromClass([self class])];
    [[AppMonitorLogger shared]Log:logMessage withLogLevel:AppMonitorLoggingLevelAllLogs];
}
#pragma mark - Framework Details
-(NSString*) framewokVersion
{
    return [NSString stringWithFormat:@"AppMonitor Version :%1.1f",AppMonitorVersionNumber];
}

-(NSString*) framewokCopyRight
{
    return COPY_RIGHTS;
}

#pragma mark-API keys
+(NSArray*)validAPIkeys
{
    return @[@"12345",@"45678",@"abcde",@"abc123"];
}
@end
