//
//  GCFavoritePlace.h
//  FavoritePlaces-Chapter02
//
//  Created by 张保国 on 16/5/12.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>

@interface GCFavoritePlace : NSManagedObject <MKAnnotation,MKOverlay>

@end
