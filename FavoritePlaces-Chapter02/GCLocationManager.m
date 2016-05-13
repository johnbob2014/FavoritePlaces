//
//  GCLocationManager.m
//  FavoritePlaces-Chapter02
//
//  Created by 张保国 on 16/5/11.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "GCLocationManager.h"
#import "GCFavoritePlace.h"

static GCLocationManager *_sharedLocationManager;

@interface GCLocationManager ()
@property (strong,nonatomic) NSMutableArray *completionBlockArray;
@end

@implementation GCLocationManager

+ (GCLocationManager *)sharedLocationManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        _sharedLocationManager=[[GCLocationManager alloc]init];
    });
    return _sharedLocationManager;
}

- (instancetype)init{
    self=[super init];
    if (self) {
        self.locationManager=[[CLLocationManager alloc]init];
        self.locationManager.desiredAccuracy=kCLLocationAccuracyBest;
        self.locationManager.distanceFilter=100.0f;
        self.locationManager.delegate=self;
        self.completionBlockArray=[[NSMutableArray alloc]initWithCapacity:10];
        self.geocoder=[[CLGeocoder alloc]init];
    }
    return self;
}

#pragma mark -
-(void)getLocationWithCompletionBlock:(GCLocationUpdateCompletionBlock)block{
    
    if (block) {
        [self.completionBlockArray addObject:block];
    }
    
    if (self.hasLocation) {
        for (GCLocationUpdateCompletionBlock completionBlock in self.completionBlockArray) {
            completionBlock(self.location,nil);
        }
        if ([self.completionBlockArray count]==0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"" object:nil];
        }
        [self.completionBlockArray removeAllObjects];
    }
    
    if (self.locationError) {
        for (GCLocationUpdateCompletionBlock completionBlock in self.completionBlockArray) {
            completionBlock(nil,self.locationError);
        }
        [self.completionBlockArray removeAllObjects];
    }
}

#pragma mark - CLLocationManagerDelegate methods
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    
    CLLocation *lastLocation=[locations lastObject];
    
    if (lastLocation.horizontalAccuracy < 0) {
        return;
    }
    
    self.location=lastLocation;
    self.hasLocation=YES;
    self.locationError=nil;
    
    CLLocationCoordinate2D coord=lastLocation.coordinate;
    NSLog(@"Location lat/long: %f,%f",coord.latitude, coord.longitude);
    
    CLLocationAccuracy horizontalAccuracy =lastLocation.horizontalAccuracy;
    NSLog(@"Horizontal accuracy: %f meters",horizontalAccuracy);
    
    CLLocationDistance altitude = lastLocation.altitude;
    NSLog(@"Location altitude: %f meters",altitude);
    
    CLLocationAccuracy verticalAccuracy =lastLocation.verticalAccuracy;
    NSLog(@"Vertical accuracy: %f meters",verticalAccuracy);
    
    NSDate *timestamp=lastLocation.timestamp;
    NSLog(@"Timestamp: %@",timestamp);
    
    CLLocationSpeed speed=lastLocation.speed;
    NSLog(@"Speed: %f meters per second",speed);
    
    CLLocationDirection direction=lastLocation.course;
    NSLog(@"Course: %f degrees from true north",direction);
    
    [self getLocationWithCompletionBlock:nil];

}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    [self.locationManager stopUpdatingLocation];
    self.locationError=error;
    [self getLocationWithCompletionBlock:nil];
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if (status == kCLAuthorizationStatusDenied) {
        [self.locationManager stopUpdatingLocation];
        
        NSString *errorMessage =@"Location Services Permission Denied for this app.  Visit Settings.app to allow.";
        
        NSDictionary *errorInfo =@{NSLocalizedDescriptionKey:errorMessage};
        
        NSError *deniedError=[NSError errorWithDomain:@"GCLocationErrorDomain" code:1 userInfo:errorInfo];
        
        self.locationError=deniedError;
        
        [self getLocationWithCompletionBlock:nil];

    }
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        
    }
}

#pragma mark - Region Monitoring delegate methods
-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region{
    
    NSString *placeIdentifier=[region identifier];
    
    NSURL *placeIDURL=[NSURL URLWithString:placeIdentifier];
    
    NSManagedObjectID *placeObjectID=[kAppDelegate.persistentStoreCoordinator managedObjectIDForURIRepresentation:placeIDURL];
    
    GCFavoritePlace *place=(GCFavoritePlace *)[kAppDelegate.managedObjectContext objectWithID:placeObjectID];
    
    [kAppDelegate.managedObjectContext performBlock:^{
        
        NSNumber *distance=[place valueForKey:@"displayRadius"];
        NSString *placeName=[place valueForKey:@"placeName"];
        
        
        NSString *baseMessage =@"Favorite Place %@ nearby - within %@ meters.";
        
        NSString *proximityMessage =
        [NSString stringWithFormat:baseMessage,placeName,distance];
        
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:@"Favorite Nearby!"
                                   message:proximityMessage
                                  delegate:nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles: nil];
        [alert show];

    }];
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region{
    
    NSString *placeIdentifier=[region identifier];
    
    NSURL *placeIDURL=[NSURL URLWithString:placeIdentifier];
    
    NSManagedObjectID *placeObjectID=[kAppDelegate.persistentStoreCoordinator managedObjectIDForURIRepresentation:placeIDURL];
    
    GCFavoritePlace *place=[kAppDelegate.managedObjectContext objectWithID:placeObjectID];
    
    [kAppDelegate.managedObjectContext performBlock:^{
        
        NSNumber *distance = [place valueForKey:@"displayRadius"];
        NSString *placeName = [place valueForKey:@"placeName"];
        
        NSString *baseMessage =@"Favorite Place %@ Geofence exited.";
        
        NSString *proximityMessage =
        [NSString stringWithFormat:baseMessage,placeName];
        
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:@"Geofence exited"
                                   message:proximityMessage
                                  delegate:nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles: nil];
        [alert show];
        
    }];
    
    
}

-(void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error{
    
}

@end
