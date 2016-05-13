//
//  GCFavoritePlaceVC.h
//  FavoritePlaces-Chapter02
//
//  Created by 张保国 on 16/5/12.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCLocationManager.h"
#import <MapKit/MapKit.h>

@class GCFavoritePlaceVC;

@protocol  GCFavoritePlaceVCDelegate

- (void)favoritePlaceViewControllerDidFinish:(GCFavoritePlaceVC *)controller;
- (MKMapItem *)currentLocationMapItem;
- (void)displayDirectionsForRoute:(MKRoute *)route;

@end

@interface GCFavoritePlaceVC : UIViewController

@property (nonatomic, strong) IBOutlet UITextField *nameTextField;
@property (nonatomic, strong) IBOutlet UITextField *addressTextField;
@property (nonatomic, strong) IBOutlet UITextField *cityTextField;
@property (nonatomic, strong) IBOutlet UITextField *stateTextField;
@property (nonatomic, strong) IBOutlet UITextField *postalTextField;
@property (nonatomic, strong) IBOutlet UITextField *latitudeTextField;
@property (nonatomic, strong) IBOutlet UITextField *longitudeTextField;
@property (nonatomic, strong) IBOutlet UILabel *geofenceLabel;
@property (nonatomic, strong) IBOutlet UISwitch *displayProximitySwitch;
@property (nonatomic, strong) IBOutlet UILabel *displayRadiusLabel;
@property (nonatomic, strong) IBOutlet UISlider *displayRadiusSlider;
@property (nonatomic, strong) IBOutlet UIButton *geocodeNowButton;

- (IBAction)saveButtonTouched:(id)sender;
- (IBAction)cancelButtonTouched:(id)sender;
- (IBAction)geocodeLocationTouched:(id)sender;
- (IBAction)displayProxitySwitchChanged:(id)sender;
- (IBAction)displayProxityRadiusChanged:(id)sender;
- (IBAction)getDirectionsButtonTouched:(id)sender;
- (IBAction)getDirectionsToButtonTouched:(id)sender;

@property (strong,nonatomic) NSManagedObjectID *favoritePlaceID;

@property (weak,nonatomic) id <GCFavoritePlaceVCDelegate> delegate;

@end
