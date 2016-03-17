//
//  KILocationManager.h
//  Kitalker
//
//  Created by 杨 烽 on 13-4-14.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

extern NSString * const KILMDidUpdateLocationNotification;

@class KILocationManager;
typedef void(^KILMDidChangeAuthorizationStatusBlock) (KILocationManager *locationManager, CLAuthorizationStatus status);
typedef void(^KILMDidUpdateToLocationBlock)          (KILocationManager *locationManager, CLLocation *newLocation, CLLocation *oldLocation);
typedef void(^KILMDidUpdateLocationsBlock)           (KILocationManager *locationManager, NSArray *locations);
typedef void(^KILMDidUpdatePlacemarkBlock)           (KILocationManager *locationManager, CLLocation *location, CLPlacemark *placemark, NSError *error);
typedef void(^KILMDidFailBlock)                      (KILocationManager *locationManager, NSError *error);
typedef void(^KILMDidReverseGeocodeLocationBlock)    (KILocationManager *locationManager, CLPlacemark *placemark, NSError *error);

@interface KILocationManager : NSObject

@property (nonatomic, assign) CLLocationDistance distanceFilter;

@property (nonatomic, assign) CLLocationAccuracy desiredAccuracy;

@property (nonatomic, readonly) CLLocationCoordinate2D lastCoordinate;

+ (KILocationManager *)sharedInstance;

- (BOOL)checkLocationServicesEnabled;

- (CLAuthorizationStatus)checkAuthorizationStatus;

- (void)startUpdatingLocation;

- (void)stopUpdatingLocation;


- (void)setDidChangeAuthorizationStatusBlock:(KILMDidChangeAuthorizationStatusBlock)block;

- (void)setDidUpdateToLocationBlock:(KILMDidUpdateToLocationBlock)block;

- (void)setDidUpdateLocationsBlock:(KILMDidUpdateLocationsBlock)block;

- (void)setDidUpdatePlacemarkBlock:(KILMDidUpdatePlacemarkBlock)block;

- (void)setDidFailBlock:(KILMDidFailBlock)block;

//country - 国家
//administrativeArea - 省份
//locality - 城市
//subLocality - 区
//thoroughfare - 街道
//subThoroughfare - 号码
- (void)reverseGeocodeLocation:(CLLocation *)location completionHandler:(KILMDidReverseGeocodeLocationBlock)block;

- (CLLocationCoordinate2D)transformWithLatitude:(double)lat longitude:(double)lng;
- (BOOL)isLocationOutOfChina:(CLLocationCoordinate2D)location;

@end

//Info.plist
//NSLocationWhenInUseUsageDescription - 使用应用期间开启定位
//NSLocationAlwaysUsageDescription - 始终使用定位