//
//  ConnectionManager.m
//  EatNow
//
//  Created by Tim Windsor Brown on 10/10/2015.
//  Copyright © 2015 ExNihilo. All rights reserved.
//

#import "ConnectionManager.h"
#import "AFNetworking.h"
#import "PlaceAnnotation.h"

static NSString* kGooglePlacesAPIKey = @"AIzaSyCeplRU7YygTzT9zR7juLXkj-gTrkQhURk";

@implementation ConnectionManager


+ (void) requestPlacesNearMe:(CLLocationCoordinate2D)coordinate
              googleMapsType:(NSString*)type
                      radius:(float)radius
                  completion:(void (^)(NSArray* places))completionBlock
                  errorBlock:(void (^)(NSError* error))errorBlock {
    
    // Google Places API Documentation:
    // https://developers.google.com/places/web-service/?hl=en_US
    
    NSString *fullUrl = [NSString stringWithFormat:
                         @"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&radius=%0.f&type=%@&key=%@",
                         coordinate.latitude,
                         coordinate.longitude,
                         radius,
                         type,
                         kGooglePlacesAPIKey
                         ];
    
    NSLog(@"Request URL: %@", fullUrl);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:fullUrl parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSLog(@"Success: %@", responseObject);
        
        NSMutableArray *places = [[NSMutableArray alloc] init];

        if (responseObject != nil &&
            [responseObject isKindOfClass:[NSDictionary class]]) {
            
            NSArray *results = responseObject[@"results"];
            
            if (results != nil && [results isKindOfClass:[NSArray class]]) {
                
                for (NSDictionary *result in results) {
                    
                    PlaceAnnotation *place = [ConnectionManager parsePlace:result];
                    
                    [places addObject:place];
                }
            }
        }
        
        completionBlock([NSArray arrayWithArray:places]);
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        
        errorBlock(error);
    }];
    
}


+ (PlaceAnnotation*) parsePlace:(NSDictionary*)dictionary {
    
    PlaceAnnotation *place = [[PlaceAnnotation alloc] init];
    NSDictionary *geometry = dictionary[@"geometry"];
    if (geometry != nil && [geometry isKindOfClass:[NSDictionary class]]) {
    
        NSDictionary *location = geometry[@"location"];
        if (location != nil && [location isKindOfClass:[NSDictionary class]]) {
            
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(0, 0);
            
            NSNumber *lat = location[@"lat"];
            NSNumber *lng = location[@"lng"];
            if (lat != nil && lng != nil) {
                coord.latitude = lat.floatValue;
                coord.longitude = lng.floatValue;
            }
            place.coordinate = coord;
        }
    }
    
    NSString *name = dictionary[@"name"];
    if (name != nil && [name isKindOfClass:[NSString class]]) {
        place.name = name;
    }

    NSNumber *rating = dictionary[@"rating"];
    if (rating != nil && [rating isKindOfClass:[NSNumber class]]) {
        place.rating = rating.stringValue;
    }


    
    return place;
    
}


@end
