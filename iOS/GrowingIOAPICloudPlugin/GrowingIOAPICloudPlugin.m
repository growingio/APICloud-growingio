//
//  GrowingIOAPICloudPlugin.m
//  GrowingIOAPICloudPlugin
//
//  Created by apple on 2018/6/20.
//  Copyright © 2018年 GrowingIO. All rights reserved.
//

#import "GrowingIOAPICloudPlugin.h"
#import <GrowingCoreKit/GrowingCoreKit.h>
#import "NSDictionaryUtils.h"
#import "UZAppDelegate.h"

@interface GrowingIOAPICloudPlugin ()<UIApplicationDelegate>

@end

@implementation GrowingIOAPICloudPlugin

- (id)initWithUZWebView:(UZWebView *)webView_ {
    if (self = [super initWithUZWebView:webView_]) {
        [[UZAppDelegate appDelegate] addAppHandle:self];
    }
    return self;
}

- (void)dispose {
    //do clean
    [[UZAppDelegate appDelegate] removeAppHandle:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([Growing handleUrl:url]) {
        return YES;
    }
    return NO;
}

+ (void)launch {
    NSDictionary *feature = [[UZAppDelegate appDelegate] getFeatureByName:@"GrowingIO"];

    NSString *trackerHost = [feature stringValueForKey:@"trackerHost" defaultValue:@""];
    NSString *reportHost = [feature stringValueForKey:@"reportHost" defaultValue:@""];
    NSString *dataHost = [feature stringValueForKey:@"dataHost" defaultValue:@""];
    NSString *gtaHost = [feature stringValueForKey:@"gtaHost" defaultValue:@""];
    NSString *wsHost = [feature stringValueForKey:@"wsHost" defaultValue:@""];
    NSString *zone = [feature stringValueForKey:@"zone" defaultValue:@""];
    NSString *debug = [feature stringValueForKey:@"debug" defaultValue:@""];
    NSString *accountId = [feature stringValueForKey:@"accountId" defaultValue:@""];

    if (trackerHost.length != 0) {
        [Growing setTrackerHost:trackerHost];
    }
    if (reportHost.length != 0) {
        [Growing setReportHost:reportHost];
    }
    if (dataHost.length != 0) {
        [Growing setDataHost:dataHost];
    }
    if (gtaHost.length != 0) {
        [Growing setGtaHost:gtaHost];
    }
    if (wsHost.length != 0) {
        [Growing setWsHost:wsHost];
    }
    if (zone.length != 0) {
        [Growing setZone:zone];
    }
    if (debug.length != 0 && [debug isEqualToString:@"true"]) {
        [Growing setEnableLog:YES];
    }
    
    [Growing startWithAccountId:accountId];
    
}

- (void)track:(NSDictionary *)event
{
    if (event.count == 0) {
        return;
    }
    
    NSInteger cbid = [event integerValueForKey:@"cbId" defaultValue:0];

    if (![event isKindOfClass:[NSDictionary class]]) {
        if (cbid > 0) {
            [self sendResultEventWithCallbackId:cbid dataDict:[self errorCallbackDictWithMsg:@"Argument error, The Argument event must be object type"] errDict:nil doDelete:YES];
        }
        return;
    }
    
    if (event.count == 1 && cbid > 0) {
        [self sendResultEventWithCallbackId:cbid dataDict:[self errorCallbackDictWithMsg:@"Argument error, The Argument event can not be empty"] errDict:nil doDelete:YES];
        return;
    }
    
    NSString *eventId = event[@"eventId"];
    
    if (![eventId isKindOfClass:[NSString class]]) {
        if (cbid > 0) {
            [self sendResultEventWithCallbackId:cbid dataDict:[self errorCallbackDictWithMsg:@"Argument error, The eventId value must be string type"] errDict:nil doDelete:YES];
        }
        return;
    }
    
    if (eventId.length == 0) {
        if (cbid > 0) {
            [self sendResultEventWithCallbackId:cbid dataDict:[self errorCallbackDictWithMsg:@"Argument error, The eventId value can not be empty"] errDict:nil doDelete:YES];
        }
        return;
    }
    
    NSDictionary *eventLevelVariable = event[@"eventLevelVariable"];
    NSNumber *number = event[@"number"];
    
    if (!eventLevelVariable && !number) {
        [self dispatchInMainThread:^{
            [Growing track:eventId];
        }];
        
    } else if (eventLevelVariable && number) {
        if (![eventLevelVariable isKindOfClass:[NSDictionary class]]) {
            if (cbid > 0) {
                [self sendResultEventWithCallbackId:cbid dataDict:[self errorCallbackDictWithMsg:@"Argument error, The eventLevelVariable value must be object type"] errDict:nil doDelete:YES];
            }
            return;
        }
        if (![number isKindOfClass:[NSNumber class]]) {
            if (cbid > 0) {
                [self sendResultEventWithCallbackId:cbid dataDict:[self errorCallbackDictWithMsg:@"Argument error, The number value must be number type"] errDict:nil doDelete:YES];
            }
            return;
        }
        [self dispatchInMainThread:^{
            [Growing track:eventId withNumber:number andVariable:eventLevelVariable];
        }];
        
    } else if (eventLevelVariable) {
        if (![eventLevelVariable isKindOfClass:[NSDictionary class]]) {
            if (cbid > 0) {
                [self sendResultEventWithCallbackId:cbid dataDict:[self errorCallbackDictWithMsg:@"Argument error, The eventLevelVariable value must be object type"] errDict:nil doDelete:YES];
            }
            return;
        }
        [self dispatchInMainThread:^{
            [Growing track:eventId withVariable:eventLevelVariable];
        }];
    } else if (number) {
        if (![number isKindOfClass:[NSNumber class]]) {
            if (cbid > 0) {
                [self sendResultEventWithCallbackId:cbid dataDict:[self errorCallbackDictWithMsg:@"Argument error, The number value must be number type"] errDict:nil doDelete:YES];
            }
            return;
        }
        [self dispatchInMainThread:^{
            [Growing track:eventId withNumber:number];
        }];
    }
    
    if (cbid > 0) {
        [self sendResultEventWithCallbackId:cbid dataDict:[self successCallbackDictWithMsg:@"track"] errDict:nil doDelete:YES];
    }
}

- (void)setEvar:(NSDictionary *)conversionVariables
{
    if (conversionVariables.count == 0) {
        return;
    }
    
    NSInteger cbid = [conversionVariables integerValueForKey:@"cbId" defaultValue:0];
    [((NSMutableDictionary *)conversionVariables) removeObjectForKey:@"cbId"];

    if (![conversionVariables isKindOfClass:[NSDictionary class]]) {
        if (cbid > 0) {
            [self sendResultEventWithCallbackId:cbid dataDict:[self errorCallbackDictWithMsg:@"Argument error, The Argument conversionVariables must be object type"] errDict:nil doDelete:YES];
        }
        return;
    }
    
    if (conversionVariables.count == 1 && cbid > 0) {
        [self sendResultEventWithCallbackId:cbid dataDict:[self errorCallbackDictWithMsg:@"Argument error, The Argument conversionVariables can not be empty"] errDict:nil doDelete:YES];
        return;
    }
    
    [self dispatchInMainThread:^{
        [Growing setEvar:conversionVariables];
    }];
    
    if (cbid > 0) {
        [self sendResultEventWithCallbackId:cbid dataDict:[self successCallbackDictWithMsg:@"setEvar"] errDict:nil doDelete:YES];
    }
}

- (void)setPeopleVariable:(NSDictionary *)peopleVariables
{
    if (peopleVariables.count == 0) {
        return;
    }
    
    NSInteger cbid = [peopleVariables integerValueForKey:@"cbId" defaultValue:0];
    [((NSMutableDictionary *)peopleVariables) removeObjectForKey:@"cbId"];

    if (![peopleVariables isKindOfClass:[NSDictionary class]]) {
        if (cbid > 0) {
            [self sendResultEventWithCallbackId:cbid dataDict:[self errorCallbackDictWithMsg:@"Argument error, The Argument peopleVariables must be object type"] errDict:nil doDelete:YES];
        }
        return;
    }
    
    if (peopleVariables.count == 1 && cbid > 0) {
        [self sendResultEventWithCallbackId:cbid dataDict:[self errorCallbackDictWithMsg:@"Argument error, The Argument peopleVariables can not be empty"] errDict:nil doDelete:YES];
        return;
    }
    
    [self dispatchInMainThread:^{
        [Growing setPeopleVariable:peopleVariables];
    }];
    
    if (cbid > 0) {
        [self sendResultEventWithCallbackId:cbid dataDict:[self successCallbackDictWithMsg:@"setPeopleVariable"] errDict:nil doDelete:YES];
    }
}

- (void)setUserId:(NSDictionary *)userIdDict
{
    if (userIdDict.count == 0) {
        return;
    }
    
    NSInteger cbid = [userIdDict integerValueForKey:@"cbId" defaultValue:0];

    NSString *userId = userIdDict[@"userId"];
    
    if (userIdDict.count == 1 && cbid > 0) {
        [self sendResultEventWithCallbackId:cbid dataDict:[self errorCallbackDictWithMsg:@"Argument error, The Argument userIdObject can not be empty"] errDict:nil doDelete:YES];
    }
    
    if (![userId isKindOfClass:[NSString class]] && ![userId isKindOfClass:[NSNumber class]]) {
        if (cbid > 0) {
            [self sendResultEventWithCallbackId:cbid dataDict:[self errorCallbackDictWithMsg:@"Argument error, userId value must be string or number type"] errDict:nil doDelete:YES];
        }
        return;
    }
    
    if ([userId isKindOfClass:[NSNumber class]]) {
        userId = ((NSNumber *)userId).stringValue;
    }
    
    if (userId.length == 0 || userId.length > 1000) {
        if (cbid > 0) {
            [self sendResultEventWithCallbackId:cbid dataDict:[self errorCallbackDictWithMsg:@"Argument error, userId length can not > 1000 or = 0"] errDict:nil doDelete:YES];
        }
        return;
    }
    
    [self dispatchInMainThread:^{
        [Growing setUserId:userId];
    }];
    
    if (cbid > 0) {
        [self sendResultEventWithCallbackId:cbid dataDict:[self successCallbackDictWithMsg:@"setUserId"] errDict:nil doDelete:YES];
    }
}

- (void)clearUserId:(NSDictionary *)callbackDict
{
    NSInteger cbid = [callbackDict integerValueForKey:@"cbId" defaultValue:0];

    [self dispatchInMainThread:^{
        [Growing clearUserId];
    }];
    
    if (cbid > 0) {
        [self sendResultEventWithCallbackId:cbid dataDict:[self successCallbackDictWithMsg:@"clearUserId"] errDict:nil doDelete:YES];
    }
}

- (NSMutableDictionary *)successCallbackDictWithMsg:(NSString *)msg
{
    NSMutableDictionary *callbackDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@ success", msg], @"msg", @YES, @"status", nil];
    return callbackDict;
}

- (NSMutableDictionary *)errorCallbackDictWithMsg:(NSString *)msg
{
    NSMutableDictionary *callbackDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:msg, @"msg", @NO, @"status", nil];
    return callbackDict;
}

- (void)dispatchInMainThread:(void (^)(void))block
{
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}


@end
