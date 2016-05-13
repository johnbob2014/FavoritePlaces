//
//  GCLocationManager.h
//  FavoritePlaces-Chapter02
//
//  Created by 张保国 on 16/5/11.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void (^GCLocationUpdateCompletionBlock)(CLLocation *location,NSError *error);

/**
    地理位置管理器
*/

@interface GCLocationManager : NSObject<CLLocationManagerDelegate>

+ (GCLocationManager *)sharedLocationManager;

@property (strong,nonatomic) CLLocation *location;
@property (strong,nonatomic) CLLocationManager *locationManager;
@property (nonatomic) BOOL hasLocation;
@property (strong,nonatomic) NSError *locationError;
@property (strong,nonatomic) CLGeocoder *geocoder;

-(void)getLocationWithCompletionBlock:(GCLocationUpdateCompletionBlock)block;

@end
