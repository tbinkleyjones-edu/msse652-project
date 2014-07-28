//
//  AppDelegate.m
//  SCIS
//
//  Created by Tim Binkley-Jones on 7/5/14.
//  Copyright (c) 2014 msse652. All rights reserved.
//

#import "AppDelegate.h"
#import "Program.h"
#import "course.h"
#import "RestKit.h"

@implementation AppDelegate

- (void)initializeRestKit {
    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
    RKLogConfigureByName("RestKit/CoreData", RKLogLevelTrace);
    RKLogConfigureByName("RestKit/Network", RKLogLevelDebug);

    //NSURL *url = [[NSURL alloc] initWithString: @"http://localhost:8080"]; // /regis2.course
    NSURL *url = [[NSURL alloc] initWithString: @"http://regisscis.net"];

    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL: url];
    [RKObjectManager setSharedManager:objectManager];

    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    objectManager.managedObjectStore = managedObjectStore;

    // setup mapping to the core data entites for program and course
    RKEntityMapping *programMapping = [RKEntityMapping mappingForEntityForName: NSStringFromClass([Program class])
                                                          inManagedObjectStore:managedObjectStore];
    programMapping.identificationAttributes = @[@"id"];
    [programMapping addAttributeMappingsFromDictionary:@{@"id" : @"id", @"name" : @"name"}];

    RKEntityMapping *courseMapping = [RKEntityMapping mappingForEntityForName: NSStringFromClass([Course class])
                                                          inManagedObjectStore:managedObjectStore];
    courseMapping.identificationAttributes = @[@"id"];
    [courseMapping addAttributeMappingsFromDictionary:@{@"id" : @"id", @"name" : @"name"}];

    // Define the relationship mapping
    [courseMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"pid"
                                                                                   toKeyPath:@"pid"
                                                                                 withMapping:programMapping]];
\
    // register the entity mappings
    RKResponseDescriptor *programDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:programMapping
                                                                                           method:RKRequestMethodGET
                                                                                      pathPattern:@"/Regis2/webresources/regis2.program"
                                                                                          keyPath:nil
                                                                                      statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:programDescriptor];

    RKResponseDescriptor *courseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:courseMapping
                                                                                          method:RKRequestMethodGET
                                                                                     pathPattern:@"/Regis2/webresources/regis2.course"
                                                                                         keyPath:nil
                                                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:courseDescriptor];

    // setup the core data object contexts
    [managedObjectStore createPersistentStoreCoordinator];
    NSString *storePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"SCIS.sqlite"];
    NSLog(@"%@", storePath);
    NSError *error;
    NSPersistentStore *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:storePath fromSeedDatabaseAtPath:nil withConfiguration:nil options:@{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES} error:&error];
    NSAssert(persistentStore, @"Failed persistent store: %@", error);

    [managedObjectStore createManagedObjectContexts];

    [RKManagedObjectStore setDefaultStore:managedObjectStore];
    managedObjectStore.managedObjectCache = [[RKInMemoryManagedObjectCache alloc]initWithManagedObjectContext:managedObjectStore.persistentStoreManagedObjectContext];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [self initializeRestKit];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
