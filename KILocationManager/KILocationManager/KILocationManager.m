//
//  KILocationManager.m
//  Kitalker
//
//  Created by 杨 烽 on 13-4-14.
//
//

#import "KILocationManager.h"

NSString * const KILMDidUpdateLocationNotification = @"KILMDidUpdateLocationNotification";

const double a = 6378245.0;
const double ee = 0.00669342162296594323;
const double pi = 3.14159265358979324;

@interface KILocationManager() <CLLocationManagerDelegate> {
    CLLocationCoordinate2D  _lastCoordinate;
}
@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, copy) KILMDidChangeAuthorizationStatusBlock   didChangeAuthorizationStatusBlock;
@property (nonatomic, copy) KILMDidUpdateToLocationBlock            didUpdateToLocationBlock;
@property (nonatomic, copy) KILMdidUpdateLocationsBlock             didUpdateLocationsBlock;
@property (nonatomic, copy) KILMDidFailBlock                        didFailBlock;
@end

@implementation KILocationManager

static KILocationManager *KI_LOCATION_MANAGER;

+ (KILocationManager *)sharedInstance {
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        KI_LOCATION_MANAGER = [[super allocWithZone:nil] init];
    });
    return KI_LOCATION_MANAGER;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedInstance];
}

- (void)dealloc {
    _didChangeAuthorizationStatusBlock = nil;
    _didUpdateToLocationBlock = nil;
    _didUpdateLocationsBlock = nil;
    _didFailBlock = nil;
}

- (id)init {
    if (KI_LOCATION_MANAGER == nil) {
        if (self = [super init]) {
            KI_LOCATION_MANAGER = self;
            [self locationManager];
        }
    }
    return KI_LOCATION_MANAGER;
}

- (BOOL)checkLocationServicesEnabled {
    return [CLLocationManager locationServicesEnabled];
}

- (CLAuthorizationStatus)checkAuthorizationStatus {
    return [CLLocationManager authorizationStatus];
}

- (CLLocationManager *)locationManager {
    if (_locationManager == nil) {
        _locationManager = [[CLLocationManager alloc] init];
        [_locationManager setDelegate:self];
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        [_locationManager setDistanceFilter:500.0f];
    }
    
    return _locationManager;
}

- (void)setDesiredAccuracy:(CLLocationAccuracy)desiredAccuracy {
    [self.locationManager setDesiredAccuracy:desiredAccuracy];
}

- (CLLocationAccuracy)desiredAccuracy {
    return [self.locationManager desiredAccuracy];
}

- (void)setDistanceFilter:(CLLocationDistance)distanceFilter {
    [self.locationManager setDistanceFilter:distanceFilter];
}

- (CLLocationDistance)distanceFilter {
    return [self.locationManager distanceFilter];
}

- (void)startUpdatingLocation {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    CLAuthorizationStatus status = [self checkAuthorizationStatus];
    if (status == kCLAuthorizationStatusNotDetermined) {
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        } else {
            [self.locationManager startUpdatingLocation];
        }
        //在 Info.plist 中添加 NSLocationWhenInUseUsageDescription
    } else if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
        [self.locationManager startUpdatingLocation];
    }
#else
    [self.locationManager startUpdatingLocation];
#endif
}

- (void)stopUpdatingLocation {
    [self.locationManager stopUpdatingLocation];
}


#pragma mark block setter

- (void)setDidChangeAuthorizationStatusBlock:(KILMDidChangeAuthorizationStatusBlock)block {
    _didChangeAuthorizationStatusBlock = [block copy];
}

- (void)setDidUpdateToLocationBlock:(KILMDidUpdateToLocationBlock)block {
    _didUpdateToLocationBlock = [block copy];
}

- (void)setDidUpdateLocationsBlock:(KILMdidUpdateLocationsBlock)block {
    _didUpdateLocationsBlock = [block copy];
}

- (void)setDidFailBlock:(KILMDidFailBlock)block {
    _didFailBlock = [block copy];
}


#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
#else
        case kCLAuthorizationStatusAuthorized:
#endif
            [self startUpdatingLocation];
            break;
        default:
            break;
    }
    
    if (self.didChangeAuthorizationStatusBlock != nil) {
        self.didChangeAuthorizationStatusBlock(self, status);
    }
}

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation {
#ifdef DEBUG
    NSLog(@"didUpdateToLocation(latitude, longitude):%f,%f from:%f,%F", newLocation.coordinate.longitude, newLocation.coordinate.latitude , oldLocation.coordinate.longitude, oldLocation.coordinate.latitude);
#endif
    
    //判断是不是属于国内范围
    if (![self isLocationOutOfChina:[newLocation coordinate]]) {
        //转换后的coord
        _lastCoordinate = [self transformWithLatitude:newLocation.coordinate.latitude
                                            longitude:newLocation.coordinate.longitude];
    } else {
        _lastCoordinate = newLocation.coordinate;
    }
    
    if (self.didUpdateToLocationBlock != nil) {
        self.didUpdateToLocationBlock(self, newLocation, oldLocation);
    }
    
    if (self.didUpdateLocationsBlock) {
        NSMutableArray *locations = [[NSMutableArray alloc] init];
        if (oldLocation) {
            [locations addObject:oldLocation];
        }
        [locations addObject:newLocation];
        self.didUpdateLocationsBlock(self, locations);
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KILMDidUpdateLocationNotification object:nil];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *lastLocation = [locations lastObject];
    
    //判断是不是属于国内范围
    if (![self isLocationOutOfChina:lastLocation.coordinate]) {
        //转换后的coord
        _lastCoordinate = [self transformWithLatitude:lastLocation.coordinate.latitude
                                            longitude:lastLocation.coordinate.longitude];
    } else {
        _lastCoordinate = lastLocation.coordinate;
    }
    
    if (self.didUpdateToLocationBlock != nil) {
        CLLocation *oldLocation = nil;
        if (locations.count > 2) {
            oldLocation = locations[locations.count-1];
        }
        self.didUpdateToLocationBlock(self, lastLocation, oldLocation);
    }
    
    if (self.didUpdateLocationsBlock) {
        self.didUpdateLocationsBlock(self, locations);
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KILMDidUpdateLocationNotification object:nil];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    if (self.didFailBlock != nil) {
        self.didFailBlock(self, error);
    }
}

- (double)transformLatitudeWithX:(double)x andY:(double)y {
    double ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(abs(x));
    ret += (20.0 * sin(y * M_PI) + 40.0 * sin(y / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(y * M_PI) + 40.0 * sin(y / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (160.0 * sin(y / 12.0 * M_PI) + 320 * sin(y * M_PI / 30.0)) * 2.0 / 3.0;
    return ret;
}

- (double)transformLongitudeWithX:(double)x andY:(double)y {
    double ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(abs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(x * M_PI) + 40.0 * sin(x / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (150.0 * sin(x / 12.0 * M_PI) + 300.0 * sin(x / 30.0 * M_PI)) * 2.0 / 3.0;
    return ret;
}

- (CLLocationCoordinate2D)transformWithLatitude:(double)lat longitude:(double)lng {
    double dLat = [self transformLatitudeWithX:(lng - 105.0) andY:(lat - 35.0)];
    double dLon = [self transformLongitudeWithX:(lng - 105.0) andY:(lat - 35.0)];
    
    double radLat = lat / 180.0 * M_PI;
    double magic = sin(radLat);
    magic = 1 - ee * magic * magic;
    
    double sqrtMagic = sqrt(magic);
    
    dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * M_PI);
    dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * M_PI);
    
    CLLocationDegrees latitude = lat + dLat;
    CLLocationDegrees longitude = lng + dLon;
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    return coordinate;
}

//判断是不是在中国
- (BOOL)isLocationOutOfChina:(CLLocationCoordinate2D)location {
    if (location.longitude < 72.004 || location.longitude > 137.8347 || location.latitude < 0.8293 || location.latitude > 55.8271)
        return YES;
    return NO;
}

@end
