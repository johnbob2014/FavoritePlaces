//
//  GCFavoritePlaceVC.m
//  FavoritePlaces-Chapter02
//
//  Created by 张保国 on 16/5/12.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "GCFavoritePlaceVC.h"
#import "GCFavoritePlace.h"

@interface GCFavoritePlaceVC ()<UITextFieldDelegate>

@property (strong,nonatomic) GCFavoritePlace *favoritePlace;

@end

@implementation GCFavoritePlaceVC

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self=[super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    [self.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UITextField class]]) {
            UITextField *tf=(UITextField *)obj;
            tf.delegate=self;
            //NSLog(@"%@",tf);
        }
    }];
    
    if (self.favoritePlaceID) {
        [kAppDelegate.managedObjectContext performBlock:^{
            GCFavoritePlace *place=(GCFavoritePlace *)[kAppDelegate.managedObjectContext objectWithID:self.favoritePlaceID];
            
            [self.nameTextField setText:[self.favoritePlace valueForKey:@"placeName"]];
            [self.addressTextField setText:[self.favoritePlace valueForKey:@"placeStreetAddress"]];
            [self.cityTextField setText:[self.favoritePlace valueForKey:@"placeCity"]];
            [self.stateTextField setText:[self.favoritePlace valueForKey:@"placeState"]];
            [self.postalTextField setText:[self.favoritePlace valueForKey:@"placePostal"]];
            [self.latitudeTextField setText:[[self.favoritePlace valueForKey:@"latitude"] stringValue]];
            [self.longitudeTextField setText:[[self.favoritePlace valueForKey:@"longitude"] stringValue]];
            [self.displayProximitySwitch setOn:[[self.favoritePlace valueForKey:@"displayProximity"] boolValue]];
            [self.displayRadiusSlider setValue:[[self.favoritePlace valueForKey:@"displayRadius"] floatValue]];
            BOOL hideDisplayRadius = ![self.displayProximitySwitch isOn];
            [self.displayRadiusLabel setHidden:hideDisplayRadius];
            [self.displayRadiusSlider setHidden:hideDisplayRadius];
            [self displayProxityRadiusChanged:nil];
        }];
    }else{
        [self.displayProximitySwitch setOn:NO];
    }
    
    BOOL hideGeofence=![CLLocationManager regionMonitoringAvailable];
    
    [self.displayProximitySwitch setHidden:hideGeofence];
    
    if (hideGeofence) {
        [self.geofenceLabel setText:@"Geofence N/A"];
    }
}

-(IBAction)saveButtonTouched:(id)sender{
    [kAppDelegate.managedObjectContext performBlock:^{
        if (!self.favoritePlace) {
            self.favoritePlace=[NSEntityDescription insertNewObjectForEntityForName:@"FavoritePlace" inManagedObjectContext:kAppDelegate.managedObjectContext];
        }
        
        [self.favoritePlace setValue:[self.nameTextField text] forKeyPath:@"placeName"];
        [self.favoritePlace setValue:[self.addressTextField text] forKeyPath:@"placeStreetAddress"];
        [self.favoritePlace setValue:[self.cityTextField text] forKeyPath:@"placeCity"];
        [self.favoritePlace setValue:[self.stateTextField text] forKeyPath:@"placeState"];
        [self.favoritePlace setValue:[self.postalTextField text] forKeyPath:@"placePostal"];
        NSNumber *latNumber = [NSNumber numberWithFloat:[self.latitudeTextField.text floatValue]];
        [self.favoritePlace setValue:latNumber forKeyPath:@"latitude"];
        NSNumber *longNumber = [NSNumber numberWithFloat:[self.longitudeTextField.text floatValue]];
        [self.favoritePlace setValue:longNumber forKeyPath:@"longitude"];
        NSNumber *displayProx = [NSNumber numberWithBool:[self.displayProximitySwitch isOn]];
        [self.favoritePlace setValue:displayProx forKeyPath:@"displayProximity"];
        NSNumber *displayRadius = [NSNumber numberWithFloat:[self.displayRadiusSlider value]];
        [self.favoritePlace setValue:displayRadius forKeyPath:@"displayRadius"];
        
        NSError *saveError = nil;
        [kAppDelegate.managedObjectContext save:&saveError];
        if (saveError)
        {
            NSLog(@"Core Data save error %@, %@", saveError, [saveError userInfo]);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Core Data Error" message:saveError.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        } else
        {
            [self.delegate favoritePlaceViewControllerDidFinish:self];
            
        }

    }];
}

- (IBAction)cancelButtonTouched:(id)sender{
    [self.delegate favoritePlaceViewControllerDidFinish:self];
}

- (IBAction)geocodeLocationTouched:(id)sender{
    NSString *geocodeString = @"";
    if ([self.addressTextField.text length] > 0) {
        geocodeString = self.addressTextField.text;
    }
    if ([self.cityTextField.text length] > 0) {
        if ([geocodeString length] > 0) {
            
            geocodeString =
            [geocodeString stringByAppendingFormat:@", %@",
             self.cityTextField.text];
            
        } else
        {
            geocodeString = self.cityTextField.text;
        }
    }
    if ([self.stateTextField.text length] > 0) {
        if ([geocodeString length] > 0) {
            
            geocodeString =
            [geocodeString stringByAppendingFormat:@", %@",
             self.stateTextField.text];
            
        } else
        {
            geocodeString = self.stateTextField.text;
        }
    }
    if ([self.postalTextField.text length] > 0) {
        if ([geocodeString length] > 0) {
            
            geocodeString =
            [geocodeString stringByAppendingFormat:@" %@",
             self.postalTextField.text];
            
        } else
        {
            geocodeString = self.postalTextField.text;
        }
    }
    
    [self.latitudeTextField setText:@"Geocoding..."];
    [self.longitudeTextField setText:@"Geocoding..."];
    
    [self.geocodeNowButton setTitle:@"Geocoding now..."
                           forState:UIControlStateDisabled];
    
    [self.geocodeNowButton setEnabled:NO];
    
    CLGeocoder *geocode=[[GCLocationManager sharedLocationManager] geocoder];
    
    [geocode geocodeAddressString:geocodeString completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
       
        [self.geocodeNowButton setEnabled:YES];
        if (error) {
            
            [self.latitudeTextField setText:@"Not found"];
            [self.longitudeTextField setText:@"Not found"];
            
            UIAlertView *alert =
            [[UIAlertView alloc] initWithTitle:@"Geocoding Error"
                                       message:error.localizedDescription
                                      delegate:nil
                             cancelButtonTitle:@"OK"
                             otherButtonTitles: nil];
            
            [alert show];

        }else{
            if ([placemarks count] > 0) {
                CLPlacemark *placemark=[placemarks lastObject];
                
                NSString *latString =
                [NSString stringWithFormat:@"%f",
                 placemark.location.coordinate.latitude];
                
                [self.latitudeTextField setText:latString];
                
                NSString *longString =
                [NSString stringWithFormat:@"%f",
                 placemark.location.coordinate.longitude];
                
                [self.longitudeTextField setText:longString];

            }
        }
    }];

}

-(IBAction)displayProxitySwitchChanged:(id)sender{
    BOOL hideDisplayRadius = ![self.displayProximitySwitch isOn];
    [self.displayRadiusLabel setHidden:hideDisplayRadius];
    [self.displayRadiusSlider setHidden:hideDisplayRadius];
    [self displayProxityRadiusChanged:nil];

}

- (IBAction)displayProxityRadiusChanged:(id)sender{
    NSString *radiusString = [NSString stringWithFormat:@"Geofence Proximity Radius (%3.0f m):",[self.displayRadiusSlider value]];
    [self.displayRadiusLabel setText:radiusString];
}

- (IBAction)getDirectionsButtonTouched:(id)sender{
    //准备导航数据
    CLLocationCoordinate2D destination=[self.favoritePlace coordinate];
    
    MKPlacemark *destinationPlacemark=[[MKPlacemark alloc]initWithCoordinate:destination addressDictionary:nil];
    
    MKMapItem *destinationItem=[[MKMapItem alloc] initWithPlacemark:destinationPlacemark];
    
    destinationItem.name=[self.favoritePlace valueForKey:@"placeName"];
    
    //配置导航参数，并打开Maps进行导航
    NSDictionary *lanunchOptions=@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving,
                                   MKLaunchOptionsMapTypeKey:[NSNumber numberWithInt:MKMapTypeStandard]};
    
    NSArray *mapItems=@[destinationItem];
    
    BOOL success=[MKMapItem openMapsWithItems:mapItems launchOptions:lanunchOptions];
    
    if (!success) {
        NSLog(@"Failed to open Maps.app");
    }
}

-(IBAction)getDirectionsToButtonTouched:(id)sender{
    CLLocationCoordinate2D destination=[self.favoritePlace coordinate];
    
    MKPlacemark *destinationPlacemark=[[MKPlacemark alloc] initWithCoordinate:destination addressDictionary:nil];
    MKMapItem *destinationItem=[[MKMapItem alloc] initWithPlacemark:destinationPlacemark];
    
    MKMapItem *currentMapItem=[self.delegate currentLocationMapItem];
    
    MKDirectionsRequest *directionsRequest=[[MKDirectionsRequest alloc]init];
    [directionsRequest setDestination:destinationItem];
    [directionsRequest setSource:currentMapItem];
    
    MKDirections *directions=[[MKDirections alloc] initWithRequest:directionsRequest];
    [directions calculateDirectionsWithCompletionHandler:
     ^(MKDirectionsResponse * _Nullable response, NSError * _Nullable error) {
         if (error) {
             
             NSString *dirMessage =
             [NSString stringWithFormat:@"Failed to get directions: %@",
              error.localizedDescription];
             
             UIAlertView *dirAlert =
             [[UIAlertView alloc] initWithTitle:@"Directions Error"
                                        message:dirMessage
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles: nil];
             
             [dirAlert show];

         }else{
             if ([response.routes count] > 0) {
                 MKRoute *firstRoute=[response.routes firstObject];
                 NSLog(@"Directions received. Steps for route 1 are:");
                 NSInteger stepNumber=1;
                 for (MKRouteStep *step in firstRoute.steps) {
                     
                     NSLog(@"Step %ld, %f meters: %@",(long)stepNumber,step.distance,step.instructions);
                     stepNumber++;
                 }
                 
                 [self.delegate displayDirectionsForRoute:firstRoute];
             }else{
                 NSString *dirMessage = @"No directions available";
                 
                 UIAlertView *dirAlert =
                 [[UIAlertView alloc] initWithTitle:@"No Directions"
                                            message:dirMessage
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles: nil];
                 
                 [dirAlert show];
             }
         }
    }];
}

//If we encounter a newline character , return NO.
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // enter closes the keyboard
    if ([string isEqualToString:@"\n"])
    {
        [textField resignFirstResponder];
        return NO;
    }
    return YES;
}

//Now the textFieldShouldEndEditing fires and the text field resigns first responder.
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    NSLog(@"%@",NSStringFromSelector(_cmd));
    [textField resignFirstResponder];
    return YES;
}
//-(void)textFieldDidEndEditing:(UITextField *)textField{
//    NSLog(@"%@",NSStringFromSelector(_cmd));
//    [textField resignFirstResponder];
//}
//
//-(void)textFieldDidBeginEditing:(UITextField *)textField{
//    NSLog(@"%@",NSStringFromSelector(_cmd));
//}
@end
