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
typedef void(^KILMDidUpdateToLocationBlock) (KILocationManager *locationManager, CLLocation *newLocation, CLLocation *oldLocation);
typedef void(^KILMdidUpdateLocationsBlock)  (KILocationManager *locationManager, NSArray *locations);
typedef void(^KILMDidFailBlock)             (KILocationManager *locationManager, NSError *error);

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

- (void)setDidUpdateLocationsBlock:(KILMdidUpdateLocationsBlock)block;

- (void)setDidFailBlock:(KILMDidFailBlock)block;


- (CLLocationCoordinate2D)transformWithLatitude:(double)lat longitude:(double)lng;
- (BOOL)isLocationOutOfChina:(CLLocationCoordinate2D)location;

@end
