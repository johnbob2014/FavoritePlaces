//
//  GCMapViewController.h
//  FavoritePlaces-Chapter02
//
//  Created by 张保国 on 16/5/12.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface GCMapViewController : UIViewController <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

- (IBAction)mapTypeSelectionChanged:(id)sender;

@end
