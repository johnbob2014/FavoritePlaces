//
//  GCMapViewController.m
//  FavoritePlaces-Chapter02
//
//  Created by 张保国 on 16/5/12.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "GCMapViewController.h"
#import "GCLocationManager.h"
#import <CoreLocation/CoreLocation.h>
#import "GCFavoritePlace.h"

@interface GCMapViewController ()

- (void)updateMapAnnotations;
- (void)zoomMapToFitAnnotations;
- (void)locationUpdated:(NSNotification *)notification;
- (void)updateFavoritePlace:(GCFavoritePlace *)place withPlacemark:(CLPlacemark *)placemark;
- (void)reverseGeocodeDraggedAnnotation:(GCFavoritePlace *)place
                      forAnnotationView:(MKAnnotationView *)annotationView;
@end

@implementation GCMapViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self updateMapAnnotations];
}

- (void)viewWillAppear:(BOOL)animated{
    GCLocationManager *appLocationManager=[GCLocationManager sharedLocationManager];
    
    [appLocationManager getLocationWithCompletionBlock:^(CLLocation *location, NSError *error) {
        
        if (error) {
            UIAlertView *alert =
            [[UIAlertView alloc] initWithTitle:@"Location Error"
                                       message:error.localizedDescription
                                      delegate:nil
                             cancelButtonTitle:@"OK"
                             otherButtonTitles: nil];
            
            [alert show];
        }
        
        //[self zoomMapToFitAnnotations];
        
        [self zoomMapToUserLocation];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationUpdated:) name:@"locationUpdated" object:nil];
    }];
}

#pragma mark -
- (IBAction)mapTypeSelectionChanged:(id)sender {
    UISegmentedControl *mapSelection=(UISegmentedControl *)sender;
    
    switch (mapSelection.selectedSegmentIndex) {
        case 0:
            self.mapView.mapType=MKMapTypeStandard;
            break;
        case 1:
            self.mapView.mapType=MKMapTypeSatellite;
            break;
        case 2:
            self.mapView.mapType=MKMapTypeHybrid;
            break;
            
        default:
            break;
    }
}

#pragma mark - Map Methods
-(void)updateMapAnnotations{
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
    
    CLLocationManager *locManager=[[GCLocationManager sharedLocationManager] locationManager];
    
    NSSet *monitoredRegions=[locManager monitoredRegions];
    
    for (CLRegion *region in monitoredRegions) {
        [locManager stopMonitoringForRegion:region];
    }
    
    NSFetchRequest *placesRequest=[[NSFetchRequest alloc] initWithEntityName:@"FavoritePlace"];
    NSManagedObjectContext *moc=kAppDelegate.managedObjectContext;
    NSError *error=nil;
    NSArray *places=[moc executeFetchRequest:placesRequest error:&error];
    
    if (error) {
        NSLog(@"Core Data fetch error %@, %@", error,[error userInfo]);
    }
    
    [self.mapView addAnnotations:places];
    
    for (GCFavoritePlace *favPlace in places) {
        BOOL displayOverlay=[[favPlace valueForKeyPath:@"displayProximity"] boolValue];
        
        if (displayOverlay) {
            [self.mapView addOverlay:favPlace];
            
            NSString *placeObjectID=[[[favPlace objectID] URIRepresentation] absoluteString];
            CLLocationDistance monitorRadius=[[favPlace valueForKey:@"displayRadius"] floatValue];
            
            CLRegion *region=[[CLRegion alloc]
                              initCircularRegionWithCenter:[favPlace coordinate]
                              radius:monitorRadius
                              identifier:placeObjectID];
            
            [locManager startMonitoringForRegion:region];
        }
    }
}

-(void)zoomMapToFitAnnotations{
    CLLocationCoordinate2D maxCoordinate=CLLocationCoordinate2DMake(-90.0, -180.0);
    CLLocationCoordinate2D minCoordinate=CLLocationCoordinate2DMake(90.0,180.0);
    NSMutableArray *currentPlaces=[[NSMutableArray alloc] initWithArray:[self.mapView annotations]];
    [currentPlaces removeObject:self.mapView.userLocation];
    
    maxCoordinate.latitude=[[currentPlaces valueForKeyPath:@"@max.latitude"] doubleValue];
    minCoordinate.latitude=[[currentPlaces valueForKeyPath:@"@min.latitude"] doubleValue];
    
    maxCoordinate.longitude =[[currentPlaces valueForKeyPath:@"@max.longitude"] doubleValue];
    minCoordinate.longitude =[[currentPlaces valueForKeyPath:@"@min.longitude"] doubleValue];
    
    CLLocationCoordinate2D centerCoordinate;
    centerCoordinate.longitude =(minCoordinate.longitude + maxCoordinate.longitude) / 2.0;
    centerCoordinate.latitude =(minCoordinate.latitude + maxCoordinate.latitude) / 2.0;
    
    MKCoordinateSpan span;
    span.longitudeDelta=(maxCoordinate.longitude - minCoordinate.longitude) * 1.2;
    span.latitudeDelta=(maxCoordinate.latitude - minCoordinate.latitude) * 1.2;
    
    MKCoordinateRegion newRegion=MKCoordinateRegionMake(centerCoordinate, span);
    
    [self.mapView setRegion:newRegion animated:YES];
}

-(void)zoomMapToUserLocation{
    CLLocationCoordinate2D centerCoordinate=self.mapView.userLocation.coordinate;
    CLLocationDistance latitudinalMeters=1000.0f;
    CLLocationDistance longitudinalMeters=1000.0f;
    MKCoordinateRegion newRegion=MKCoordinateRegionMakeWithDistance(centerCoordinate, latitudinalMeters ,longitudinalMeters);
    [self.mapView setRegion:newRegion animated:YES];
}

-(void)locationUpdated:(NSNotification *)notification{
    
}

#pragma mark - MapViewDelegate methods

@end
