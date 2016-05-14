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
#import "GCFavoritePlaceVC.h"

@interface GCMapViewController ()<GCFavoritePlaceVCDelegate>

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
    [placesRequest setReturnsObjectsAsFaults:NO];
    NSManagedObjectContext *moc=kAppDelegate.managedObjectContext;
    NSError *error=nil;
    NSArray *places=[moc executeFetchRequest:placesRequest error:&error];
    
    if (error) {
        NSLog(@"Core Data fetch error %@, %@", error,[error userInfo]);
    }
    
//    NSLog(@"FavoritePalce count: %ld",(long)[places count]);
//    [places enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        GCFavoritePlace *place=(GCFavoritePlace *) obj;
//        NSLog(@"%@",place);
//        //NSLog(@"%f,%f", place.coordinate.latitude,place.coordinate.longitude);
//        if ([place respondsToSelector:@selector(coordinate)]) {
//            
//            [self.mapView addAnnotation:place];
//            NSLog(@"Add An Annotation: %@",place);
//        }
// 
//    } ];
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

#pragma mark - Favorite Place View Controller Delegate Methods
- (void)favoritePlaceViewControllerDidFinish:(GCFavoritePlaceVC *)controller
{
    //    if (self.favoritePlacePopoverController)
    //    {
    //        [self.favoritePlacePopoverController dismissPopoverAnimated:YES];
    //        self.favoritePlacePopoverController = nil;
    //    } else
    //    {
    //        [self dismissViewControllerAnimated:YES completion:nil];
    //    }
    
    [controller dismissViewControllerAnimated:YES completion:nil];
    //[self dismissViewControllerAnimated:YES completion:nil];
    [self updateMapAnnotations];
    [self zoomMapToFitAnnotations];
}

- (MKMapItem *)currentLocationMapItem
{
    CLLocation *currentLocation = self.mapView.userLocation.location;
    CLLocationCoordinate2D currentCoordinate = currentLocation.coordinate;
    
    MKPlacemark *currentPlacemark =
    [[MKPlacemark alloc] initWithCoordinate:currentCoordinate
                          addressDictionary:nil];
    
    MKMapItem *currentItem =
    [[MKMapItem alloc] initWithPlacemark:currentPlacemark];
    
    return currentItem;
}

- (void)displayDirectionsForRoute:(MKRoute *)route
{
    [self.mapView addOverlay:route.polyline];
    
    //    if (self.favoritePlacePopoverController)
    //    {
    //        [self.favoritePlacePopoverController
    //         dismissPopoverAnimated:YES];
    //
    //        self.favoritePlacePopoverController = nil;
    //    } else
    //    {
    //        [self dismissViewControllerAnimated:YES
    //                                 completion:nil];
    //    }
}

#pragma mark - Navigation
- (IBAction)addAction:(id)sender {
    
    [self performSegueWithIdentifier:@"addFavoritePlace" sender:sender];
}

- (IBAction)currentAction:(id)sender {
    [self zoomMapToUserLocation];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"addFavoritePlace"]) {
        [[segue destinationViewController] setDelegate:self];
//        UIPopoverController *popoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
//        self.favoritePlacePopoverController = popoverController;
//        popoverController.delegate = self;
    }else if ([[segue identifier] isEqualToString:@"showFavoritePlaceDetail"]) {
        MKAnnotationView *view = (MKAnnotationView *)sender;
        GCFavoritePlace *place = (GCFavoritePlace *)[view annotation];
        
        GCFavoritePlaceVC *fpvc = (GCFavoritePlaceVC *)[segue destinationViewController];
        [fpvc setDelegate:self];
        [fpvc setFavoritePlaceID:[place objectID]];
    }
}


#pragma mark - MapViewDelegate methods
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    
    if (annotation == mapView.userLocation) {
        return nil;
    }
    
    MKAnnotationView *view=nil;
    
    GCFavoritePlace *place=(GCFavoritePlace *)annotation;
    
    if ([[place valueForKey:@"goingNext"] boolValue]) {
        //下一站标记
        view=(MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"arrow"];
        
        if (!view) {
            view=[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"arrow"];
        }
        
        view.canShowCallout=YES;
        view.draggable=YES;
        view.image=[UIImage imageNamed:@"anext_arrow"];
        
        UIImageView *leftView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"annotation_view_arrow"]];
        
        view.leftCalloutAccessoryView=leftView;
        view.rightCalloutAccessoryView=nil;
    }else{
        //普通标记
        MKPinAnnotationView *pinView=(MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"pin"];
        
        if (!pinView) {
            pinView=[[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"pin"];
        }
        
        pinView.pinColor=MKPinAnnotationColorRed;
        pinView.canShowCallout=YES;
        pinView.draggable=NO;
        
        UIImageView *leftView = [[UIImageView alloc]
                                 initWithImage:[UIImage imageNamed:@"annotation_view_star"]];
        
        [pinView setLeftCalloutAccessoryView:leftView];
        
        UIButton *rightButton=[UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [pinView setRightCalloutAccessoryView:rightButton];
        
        view=pinView;

    }
    
    return view;
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    MKCoordinateRegion newRegion=[mapView region];
    CLLocationCoordinate2D center=newRegion.center;
    MKCoordinateSpan span=newRegion.span;
    
    NSLog(@"New map region center: <%f/%f>, span: <%f/%f>",
          center.latitude,center.longitude,span.latitudeDelta,
          span.longitudeDelta);
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay{
    MKOverlayRenderer *returnView=nil;
    
    if ([overlay isKindOfClass:[GCFavoritePlace class]]) {
        //点
        GCFavoritePlace *place=(GCFavoritePlace *)overlay;
        
        CLLocationDistance radius=[[place valueForKey:@"displayRadius"] floatValue];
        MKCircle *circle=[MKCircle circleWithCenterCoordinate:[overlay coordinate] radius:radius];
        MKCircleRenderer *circleView=[[MKCircleRenderer alloc] initWithCircle:circle];
        circleView.fillColor=[[UIColor redColor] colorWithAlphaComponent:0.2];
        circleView.strokeColor=[[UIColor redColor] colorWithAlphaComponent:0.7];
        circleView.lineWidth=3;
        returnView=circleView;
        
    }else if([overlay isKindOfClass:[MKPolyline class]]){
        //路线
        MKPolyline *line=(MKPolyline *)overlay;
        
        MKPolylineRenderer *polylineRenderer=[[MKPolylineRenderer alloc]initWithPolyline:line];
        polylineRenderer.lineWidth=3.0;
        polylineRenderer.fillColor=[UIColor blueColor];
        polylineRenderer.strokeColor=[UIColor blueColor];
        returnView=polylineRenderer;
    }
    
    return returnView;
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    [self performSegueWithIdentifier:@"showFavoritePlaceDetail" sender:view];
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState{
    //处理MKAnnotationView的拖拽事件
    if (newState == MKAnnotationViewDragStateEnding) {
        GCFavoritePlace *draggedPlace=(GCFavoritePlace *)[view annotation];
        
        UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [activityView startAnimating];
        
        view.leftCalloutAccessoryView=activityView;
        
        [self reverseGeocodeDraggedAnnotation:draggedPlace forAnnotationView:view];
    }
}

#pragma mark - Custom Methods
- (void)reverseGeocodeDraggedAnnotation:(GCFavoritePlace *)place
                      forAnnotationView:(MKAnnotationView *)annotationView{
    CLGeocoder *geocoder=[[GCLocationManager sharedLocationManager] geocoder];
    
    CLLocation *draggedLocation=[[CLLocation alloc]initWithLatitude:place.coordinate.latitude longitude:place.coordinate.longitude];
    
    [geocoder reverseGeocodeLocation:draggedLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        UIImage *arrowImage =
        [UIImage imageNamed:@"annotation_view_arrow"];
        
        UIImageView *leftView =
        [[UIImageView alloc] initWithImage:arrowImage];
        
        [annotationView setLeftCalloutAccessoryView:leftView];
        
        if (error)
        {
            UIAlertView *alert =
            [[UIAlertView alloc] initWithTitle:@"Geocoding Error"
                                       message:error.localizedDescription
                                      delegate:nil
                             cancelButtonTitle:@"OK"
                             otherButtonTitles: nil];
            
            [alert show];
        } else
        {
            if ([placemarks count] > 0) {
                CLPlacemark *placemark = [placemarks lastObject];
                [self updateFavoritePlace:place withPlacemark:placemark];
            }
            
        }

    }];
}

- (void)updateFavoritePlace:(GCFavoritePlace *)place
              withPlacemark:(CLPlacemark *)placemark
{
    [kAppDelegate.managedObjectContext performBlock:^{
        NSString *newName =
        [NSString stringWithFormat:@"Next: %@",placemark.name];
        
        [place setValue:newName forKey:@"placeName"];
        
        NSString *newStreetAddress =
        [NSString stringWithFormat:@"%@ %@",
         placemark.subThoroughfare, placemark.thoroughfare];
        
        [place setValue:newStreetAddress
                 forKey:@"placeStreetAddress"];
        
        [place setValue:placemark.subAdministrativeArea
                 forKey:@"placeCity"];
        
        [place setValue:placemark.postalCode
                 forKey:@"placePostal"];
        
        [place setValue:placemark.administrativeArea
                 forKey:@"placeState"];
        
        NSError *saveError = nil;
        [kAppDelegate.managedObjectContext save:&saveError];
        if (saveError) {
            NSLog(@"Save Error: %@",saveError.localizedDescription);
        }
    }];
    
}

@end
