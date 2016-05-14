//
//  AppDelegate.m
//  FavoritePlaces-Chapter02
//
//  Created by 张保国 on 16/5/11.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "AppDelegate.h"
#import "GCLocationManager.h"

//#define FirstRun 1

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
#ifdef FirstRun
    [AppDelegate setupStarterData];
#endif
    
    if ([CLLocationManager locationServicesEnabled]) {
        GCLocationManager *appLocationManager=[GCLocationManager sharedLocationManager];
        [appLocationManager.locationManager startUpdatingLocation];
        
        //NSLog(@"%@",appLocationManager.locationManager);
    }else{
        NSLog(@"Location Services disabled.");
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.ZhangBaoGuo.FavoritePlaces_Chapter02" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"FavoritePlaces" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"FavoritePlaces.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Setup Starter Data

+ (void)setupStarterData
{
    NSManagedObjectContext *moc =
    [kAppDelegate managedObjectContext];
    
    NSManagedObject *newPlace1 =
    [NSEntityDescription insertNewObjectForEntityForName:@"FavoritePlace"
                                  inManagedObjectContext:moc];
    
    [newPlace1 setValue:@"Denver Museum of Nature and Science" forKey:@"placeName"];
    [newPlace1 setValue:@"2001 Colorado Blvd" forKey:@"placeStreetAddress"];
    [newPlace1 setValue:@"Denver" forKey:@"placeCity"];
    [newPlace1 setValue:@"CO" forKey:@"placeState"];
    [newPlace1 setValue:@"80205" forKey:@"placePostal"];
    [newPlace1 setValue:@39.748039 forKey:@"latitude"];
    [newPlace1 setValue:@-104.943390 forKey:@"longitude"];
    [newPlace1 setValue:@NO forKey:@"goingNext"];
    [newPlace1 setValue:@NO forKey:@"displayProximity"];
    [newPlace1 setValue:@0.0 forKey:@"displayRadius"];
    
    NSManagedObject *newPlace2 =
    [NSEntityDescription insertNewObjectForEntityForName:@"FavoritePlace"
                                  inManagedObjectContext:moc];
    
    [newPlace2 setValue:@"Denver Art Museum" forKey:@"placeName"];
    [newPlace2 setValue:@"100 W 14th Ave Pkwy" forKey:@"placeStreetAddress"];
    [newPlace2 setValue:@"Denver" forKey:@"placeCity"];
    [newPlace2 setValue:@"CO" forKey:@"placeState"];
    [newPlace2 setValue:@"80204" forKey:@"placePostal"];
    [newPlace2 setValue:@39.737770 forKey:@"latitude"];
    [newPlace2 setValue:@-104.989598 forKey:@"longitude"];
    [newPlace2 setValue:@NO forKey:@"goingNext"];
    [newPlace2 setValue:@NO forKey:@"displayProximity"];
    [newPlace2 setValue:@0.0 forKey:@"displayRadius"];
    
    NSManagedObject *newPlace3 =
    [NSEntityDescription insertNewObjectForEntityForName:@"FavoritePlace"
                                  inManagedObjectContext:moc];
    
    [newPlace3 setValue:@"Colorado History Museum" forKey:@"placeName"];
    [newPlace3 setValue:@"1200 Broadway" forKey:@"placeStreetAddress"];
    [newPlace3 setValue:@"Denver" forKey:@"placeCity"];
    [newPlace3 setValue:@"CO" forKey:@"placeState"];
    [newPlace3 setValue:@"80203" forKey:@"placePostal"];
    [newPlace3 setValue:@39.735286 forKey:@"latitude"];
    [newPlace3 setValue:@-104.987536 forKey:@"longitude"];
    [newPlace3 setValue:@NO forKey:@"goingNext"];
    [newPlace3 setValue:@NO forKey:@"displayProximity"];
    [newPlace3 setValue:@0.0 forKey:@"displayRadius"];
    
    NSManagedObject *newPlace4 =
    [NSEntityDescription insertNewObjectForEntityForName:@"FavoritePlace"
                                  inManagedObjectContext:moc];
    
    [newPlace4 setValue:@"Coors Field" forKey:@"placeName"];
    [newPlace4 setValue:@"2299 Wewatta St" forKey:@"placeStreetAddress"];
    [newPlace4 setValue:@"Denver" forKey:@"placeCity"];
    [newPlace4 setValue:@"CO" forKey:@"placeState"];
    [newPlace4 setValue:@"80202" forKey:@"placePostal"];
    [newPlace4 setValue:@39.758895 forKey:@"latitude"];
    [newPlace4 setValue:@-104.994655 forKey:@"longitude"];
    [newPlace4 setValue:@NO forKey:@"goingNext"];
    [newPlace4 setValue:@NO forKey:@"displayProximity"];
    [newPlace4 setValue:@0.0 forKey:@"displayRadius"];
    
    NSManagedObject *newPlace5 =
    [NSEntityDescription insertNewObjectForEntityForName:@"FavoritePlace"
                                  inManagedObjectContext:moc];
    
    [newPlace5 setValue:@"City Park Golf Course" forKey:@"placeName"];
    [newPlace5 setValue:@"2500 York St" forKey:@"placeStreetAddress"];
    [newPlace5 setValue:@"Denver" forKey:@"placeCity"];
    [newPlace5 setValue:@"CO" forKey:@"placeState"];
    [newPlace5 setValue:@"80205" forKey:@"placePostal"];
    [newPlace5 setValue:@39.752612 forKey:@"latitude"];
    [newPlace5 setValue:@-104.954844 forKey:@"longitude"];
    [newPlace5 setValue:@NO forKey:@"goingNext"];
    [newPlace5 setValue:@NO forKey:@"displayProximity"];
    [newPlace5 setValue:@0.0 forKey:@"displayRadius"];
    
    NSManagedObject *newPlace6 =
    [NSEntityDescription insertNewObjectForEntityForName:@"FavoritePlace"
                                  inManagedObjectContext:moc];
    
    [newPlace6 setValue:@"Where I Am Going Next!" forKey:@"placeName"];
    [newPlace6 setValue:@39.745286 forKey:@"latitude"];
    [newPlace6 setValue:@-104.959935 forKey:@"longitude"];
    [newPlace6 setValue:@YES forKey:@"goingNext"];
    [newPlace6 setValue:@NO forKey:@"displayProximity"];
    [newPlace6 setValue:@0.0 forKey:@"displayRadius"];
    
    NSError *mocSaveError = nil;
    
    if ([moc save:&mocSaveError])
    {
        NSLog(@"Save completed successfully.");
    } else
    {
        NSLog(@"Save did not complete successfully. Error: %@",
              [mocSaveError localizedDescription]);
    }
    
}

@end
