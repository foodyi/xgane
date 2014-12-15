/*
 
 Copyright (c) 2012, DIVIJ KUMAR
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 The views and conclusions contained in the software and documentation are those
 of the authors and should not be interpreted as representing official policies,
 either expressed or implied, of the FreeBSD Project.
 
 
 */

/*
 *
 * CarrierPigeon
 *
 * Created by fudi on 14-9-1.
 * Copyright (c) 2014年 __MyCompanyName__. All rights reserved.
 */

#import "FlashRuntimeExtensions.h"
#import "FRETypeConversion.h"
#import <UIKit/UIApplication.h>
#import <UIKit/UIAlertView.h>
#import "CarrierPigeon.h"
#import "StarterNotificationChecker.h"
#import "XGPush.h"
#import <objc/runtime.h>
#import <objc/message.h>
#define _IPHONE80_ 80000


@implementation CarrierPigeon

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken{}
//
- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error{}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{}

+ (void)registerPushForIOS8{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
    
    //Types
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    
    //Actions
    UIMutableUserNotificationAction *acceptAction = [[UIMutableUserNotificationAction alloc] init];
    
    acceptAction.identifier = @"ACCEPT_IDENTIFIER";
    acceptAction.title = @"Accept";
    
    acceptAction.activationMode = UIUserNotificationActivationModeForeground;
    acceptAction.destructive = NO;
    acceptAction.authenticationRequired = NO;
    
    //Categories
    UIMutableUserNotificationCategory *inviteCategory = [[UIMutableUserNotificationCategory alloc] init];
    
    inviteCategory.identifier = @"INVITE_CATEGORY";
    
    [inviteCategory setActions:@[acceptAction] forContext:UIUserNotificationActionContextDefault];
    
    [inviteCategory setActions:@[acceptAction] forContext:UIUserNotificationActionContextMinimal];
    
    NSSet *categories = [NSSet setWithObjects:inviteCategory, nil];
    
    
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:categories];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
#endif
}

+ (void)registerPush{
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
}


+ (NSString*) convertToJSonString:(NSDictionary*)dict
{
    if(dict == nil) {
        return @"{}";
    }
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&jsonError];
    if (jsonError != nil) {
        NSLog(@"[AirPushNotification] JSON stringify error: %@", jsonError.localizedDescription);
        return @"{}";
    }
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end

FREContext myCtx = nil;

void didRegisterForRemoteNotificationsWithDeviceToken(id self, SEL _cmd, UIApplication* application, NSData* deviceToken)
{
    
  
    //FREDispatchStatusEventAsync(myCtx, (uint8_t*)"TOKEN_SUCCESS", (uint8_t*)[tokenString UTF8String]);
    NSString* tokenString = [NSString stringWithFormat:@"Failed to get token, error: %@",deviceToken];
    void (^successBlock)(void) = ^(void){
        //成功之后的处理
        NSLog(@"[xgpush]handleLaunching's successBlock");
        //nativeAlert(@"提示", @"注册设备成功!");
        FREDispatchStatusEventAsync(myCtx, (uint8_t*)"TOKEN_SUCCESS", (uint8_t*)[tokenString UTF8String]);
    };
    
    void (^errorBlock)(void) = ^(void){
        //失败之后的处理
        NSLog(@"[xgpush]handleLaunching's errorBlock");
        //nativeAlert(@"提示", @"注册设备失败!");
        FREDispatchStatusEventAsync(myCtx, (uint8_t*)"TOKEN_FAIL", nil);
    };
    //[XGPush handleLaunching:launchOptions successCallback:successBlock errorCallback:errorBlock];
    NSString* tokenStr = [XGPush registerDevice:deviceToken successCallback:successBlock errorCallback:errorBlock ];
    NSLog(@"My token is: %@", tokenStr);
    //nativeAlert(@"token",tokenStr);
    //    if ( myCtx != nil )
    //    {
    //        FREDispatchStatusEventAsync(myCtx, (uint8_t*)"TOKEN_SUCCESS", (uint8_t*)[tokenString UTF8String]);
    //    }
}

//custom implementations of empty signatures above. Used for push notification delegate implementation.
void didFailToRegisterForRemoteNotificationsWithError(id self, SEL _cmd, UIApplication* application, NSError* error)
{
    //nativeAlert(@"推送",@"注册设备失败!");
    NSString* tokenString = [NSString stringWithFormat:@"Failed to get token, error: %@",error];
    if ( myCtx != nil )
    {
        FREDispatchStatusEventAsync(myCtx, (uint8_t*)"TOKEN_FAIL", (uint8_t*)[tokenString UTF8String]);
    }
}

//custom implementations of empty signatures above. Used for push notification delegate implementation.
void didReceiveRemoteNotification(id self, SEL _cmd, UIApplication* application,NSDictionary *userInfo)
{
    if ( myCtx != nil )
    {
        NSString *stringInfo = [CarrierPigeon convertToJSonString:userInfo];
        if (application.applicationState == UIApplicationStateActive)
        {
            FREDispatchStatusEventAsync(myCtx, (uint8_t*)"NOTIFICATION_RECEIVED_WHEN_IN_FOREGROUND", (uint8_t*)[stringInfo UTF8String]);
        }
        else if (application.applicationState == UIApplicationStateInactive)
        {
            FREDispatchStatusEventAsync(myCtx, (uint8_t*)"APP_BROUGHT_TO_FOREGROUND_FROM_NOTIFICATION", (uint8_t*)[stringInfo UTF8String]);
        }
        else if (application.applicationState == UIApplicationStateBackground)
        {
            FREDispatchStatusEventAsync(myCtx, (uint8_t*)"APP_STARTED_IN_BACKGROUND_FROM_NOTIFICATION", (uint8_t*)[stringInfo UTF8String]);
        }
    }
}



/* CarrierPigeonExtInitializer()
 * The extension initializer is called the first time the ActionScript side of the extension
 * calls ExtensionContext.createExtensionContext() for any context.
 *
 * Please note: this should be same as the <initializer> specified in the extension.xml
 */
void CarrierPigeonExtInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet)
{
    
    *extDataToSet = NULL;
    *ctxInitializerToSet = &ContextInitializer;
    *ctxFinalizerToSet = &ContextFinalizer;
    
}

/* CarrierPigeonFinalizer()
 * The extension finalizer is called when the runtime unloads the extension. However, it may not always called.
 *
 * Please note: this should be same as the <finalizer> specified in the extension.xml
 */
void CarrierPigeonExtFinalizer(void* extData)
{
    NSLog(@"Entering CarrierPigeonFinalizer()");
    
    // Nothing to clean up.
    NSLog(@"Exiting CarrierPigeonFinalizer()");
    return;
}

/* ContextInitializer()
 * The context initializer is called when the runtime creates the extension context instance.
 */
void ContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet)
{
    NSLog(@"Entering ContextInitializer()");
    myCtx = ctx;
    
//    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
//     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
//    
    //injects our modified delegate functions into the sharedApplication delegate
    
    id delegate = [[UIApplication sharedApplication] delegate];
    
    Class objectClass = object_getClass(delegate);
    
    NSString *newClassName = [NSString stringWithFormat:@"Custom_%@", NSStringFromClass(objectClass)];
    Class modDelegate = NSClassFromString(newClassName);
    if (modDelegate == nil) {
        // this class doesn't exist; create it
        // allocate a new class
        modDelegate = objc_allocateClassPair(objectClass, [newClassName UTF8String], 0);
        
        SEL selectorToOverride1 = @selector(application:didRegisterForRemoteNotificationsWithDeviceToken:);
        
        SEL selectorToOverride2 = @selector(application:didFailToRegisterForRemoteNotificationsWithError:);
        
        SEL selectorToOverride3 = @selector(application:didReceiveRemoteNotification:);
        
        // get the info on the method we're going to override
        Method m1 = class_getInstanceMethod(objectClass, selectorToOverride1);
        Method m2 = class_getInstanceMethod(objectClass, selectorToOverride2);
        Method m3 = class_getInstanceMethod(objectClass, selectorToOverride3);
        
        // add the method to the new class
        class_addMethod(modDelegate, selectorToOverride1, (IMP)didRegisterForRemoteNotificationsWithDeviceToken, method_getTypeEncoding(m1));
        class_addMethod(modDelegate, selectorToOverride2, (IMP)didFailToRegisterForRemoteNotificationsWithError, method_getTypeEncoding(m2));
        class_addMethod(modDelegate, selectorToOverride3, (IMP)didReceiveRemoteNotification, method_getTypeEncoding(m3));
        
        // register the new class with the runtime
        objc_registerClassPair(modDelegate);
    }
    // change the class of the object
    object_setClass(delegate, modDelegate);
    ///////// end of delegate injection / modification code
    
    /* The following code describes the functions that are exposed by this native extension to the ActionScript code.
     */
    static FRENamedFunction func[] =
    {
        MAP_FUNCTION(isSupported, NULL),
        MAP_FUNCTION(startApp, NULL),
        MAP_FUNCTION(setAccount, NULL),
        MAP_FUNCTION(setTag, NULL),
        MAP_FUNCTION(delTag, NULL),
        MAP_FUNCTION(unRegisterDevice, NULL),
    };
    
    *numFunctionsToTest = sizeof(func) / sizeof(FRENamedFunction);
    *functionsToSet = func;
    
    NSLog(@"Exiting ContextInitializer()");
}

/* ContextFinalizer()
 * The context finalizer is called when the extension's ActionScript code
 * calls the ExtensionContext instance's dispose() method.
 * If the AIR runtime garbage collector disposes of the ExtensionContext instance, the runtime also calls ContextFinalizer().
 */
void ContextFinalizer(FREContext ctx)
{
    NSLog(@"Entering ContextFinalizer()");
    
    // Nothing to clean up.
    NSLog(@"Exiting ContextFinalizer()");
    return;
}


/* This is a TEST function that is being included as part of this template.
 *
 * Users of this template are expected to change this and add similar functions
 * to be able to call the native functions in the ANE from their ActionScript code
 */
ANE_FUNCTION(isSupported)
{
    NSLog(@"Entering IsSupported()");
    
    FREObject fo;
    
    FREResult aResult = FRENewObjectFromBool(YES, &fo);
    if (aResult == FRE_OK)
    {
        NSLog(@"Result = %d", aResult);
    }
    else
    {
        NSLog(@"Result = %d", aResult);
    }
    
    NSLog(@"Exiting IsSupported()");
    return fo;
}

ANE_FUNCTION(startApp)
{
    uint32_t style;
    NSString *value;
    FREGetObjectAsUint32(argv[0], &style);
    FREGetObjectAsString(argv[1], &value);
    [XGPush startApp:style appKey:value];
    
    //注册设备
    void (^successCallback)(void) = ^(void){
        //如果变成需要注册状态
        if(![XGPush isUnRegisterStatus])
        {
            //iOS8注册push方法 ==> need to know this place
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
            
            float sysVer = [[[UIDevice currentDevice] systemVersion] floatValue];
            if(sysVer < 8){
                [CarrierPigeon registerPush];
                //nativeAlert(@"提示", @"注册call registerPush");
            }
            else{
                [CarrierPigeon registerPushForIOS8];
                //nativeAlert(@"提示", @"注册call registerPushForIOS8");
            }
#else
            //iOS8之前注册push方法
            //注册Push服务，注册后才能收到推送
            [CarrierPigeon registerPush];
#endif
        }
    };
    [XGPush initForReregister:successCallback];
    
    //推送反馈回调版本示例，表示是通过推送启动app的
    void (^successBlock)(void) = ^(void){
        //成功之后的处理
        NSLog(@"[XGPush]handleLaunching's successBlock");
    };
    
    void (^errorBlock)(void) = ^(void){
        //失败之后的处理
        NSLog(@"[XGPush]handleLaunching's errorBlock");
    };
    //统计
    [XGPush handleLaunching:[StarterNotificationChecker getStarterNotification] successCallback:successBlock errorCallback:errorBlock];
    
    return NULL;
}

ANE_FUNCTION(setAccount)
{
    //nativeAlert(@"设置", @"设置账户");
    NSString *name;
    FREGetObjectAsString(argv[0], &name);
    [XGPush setAccount:name];
    return NULL;
}

ANE_FUNCTION(setTag)
{
    NSString *tag;
    FREGetObjectAsString(argv[0], &tag);
//    nativeAlert(@"设置标签", tag);
//    void (^successBlock)(void) = ^(void){
//        nativeAlert(@"设置标签", @"设置成功");
//    };
//    
//    void (^errorBlock)(void) = ^(void){
//        nativeAlert(@"设置标签", @"设置失败");
//    };
//    
    //[XGPush setTag:tag successCallback:successBlock errorCallback:errorBlock];
    [XGPush setTag:tag];
    return NULL;
}

ANE_FUNCTION(delTag)
{
    NSString *tag;
    FREGetObjectAsString(argv[0], &tag);
//    void (^successBlock)(void) = ^(void){
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"信鸽推送"
//                                                        message:@"删除标签成功"
//                                                       delegate:nil
//                                              cancelButtonTitle:@"OK"
//                                              otherButtonTitles:nil];
//        [alert show];
//    };
//    
//    void (^errorBlock)(void) = ^(void){
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"信鸽推送"
//                                                        message:@"删除标签失败"
//                                                       delegate:nil
//                                              cancelButtonTitle:@"OK"
//                                              otherButtonTitles:nil];
//        [alert show];
//    };
//    
//    [XGPush delTag:tag successCallback:successBlock errorCallback:errorBlock];

    
    [XGPush delTag: tag];//可以监听回调方法
    return NULL;
}

ANE_FUNCTION(unRegisterDevice)
{
    [XGPush unRegisterDevice];
    return NULL;
}


void alert(NSString * title, NSString * message) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
}

