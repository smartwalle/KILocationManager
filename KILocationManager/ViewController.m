//
//  ViewController.m
//  KILocationManager
//
//  Created by apple on 15/11/4.
//  Copyright (c) 2015年 smartwalle. All rights reserved.
//

#import "ViewController.h"
#import "KILocationManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[KILocationManager sharedInstance] setDidUpdateToLocationBlock:^(KILocationManager *locationManager, CLLocation *newLocation, CLLocation *oldLocation) {
        
        // 停止定位
        [locationManager stopUpdatingLocation];
        
         NSLog(@"%@", newLocation);
    }];

    [[KILocationManager sharedInstance] setDidUpdatePlacemarkBlock:^(KILocationManager *locationManager, CLLocation *location, CLPlacemark *placemark, NSError *error) {
        NSLog(@"位置信息：%@--%@--%@--%@--%@--%@--%@--%@", placemark.name, placemark.country, placemark.administrativeArea, placemark.locality, placemark.subLocality, placemark.thoroughfare, placemark.subThoroughfare, placemark.ISOcountryCode);
    }];
    
    // 开始定位
    [[KILocationManager sharedInstance] startUpdatingLocation];
}

@end
