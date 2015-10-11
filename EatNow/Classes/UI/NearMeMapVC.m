//
//  NearMeMapVC.m
//  EatNow
//
//  Created by Tim Windsor Brown on 08/10/2015.
//  Copyright © 2015 ExNihilo. All rights reserved.
//

#import "NearMeMapVC.h"
#import <MapKit/MapKit.h>
#import "ConnectionManager.h"
#import "LoadingButton.h"
#import "PlaceCell.h"
#import "PlaceAnnotation.h"

@import GoogleMaps;

@interface NearMeMapVC () <CLLocationManagerDelegate, GMSMapViewDelegate, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
//@property (strong, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *findFoodButton;
@property (strong, nonatomic) UIButton *showMapButton;
@property (strong, nonatomic) UIButton *showListButton;
@property (weak, nonatomic) IBOutlet UIButton *viewTypeButton;

@property (strong, nonatomic) GMSPlacesClient *placesClient;
@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) CLLocation *currentLoction;
@property (strong, nonatomic) NSArray *placeAnnotations;


@end

@implementation NearMeMapVC



-(void) viewDidLoad {
    
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    [self.locationManager requestWhenInUseAuthorization];
    
    // Set default view display
    [self.viewTypeButton setImage:[UIImage imageNamed:@"Map_Small"] forState:UIControlStateNormal];
    [self.containerView bringSubviewToFront:self.tableView];


    // Setup TableView
    self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 80, 0);
    
}

#pragma mark - Actions

- (IBAction) viewTypeButtonPressed:(UIButton *)sender {
    
    int mapViewIndex = [[self.mapView superview].subviews indexOfObject:self.mapView];
    int listViewIndex = [[self.tableView superview].subviews indexOfObject:self.tableView];
    
    
    if (mapViewIndex > listViewIndex) { // Map on top
        [sender setImage:[UIImage imageNamed:@"Map_Small"] forState:UIControlStateNormal];
        [self.containerView bringSubviewToFront:self.tableView];

    }
    else { // List on top
        [sender setImage:[UIImage imageNamed:@"List_Small"] forState:UIControlStateNormal];
        [self.containerView bringSubviewToFront:self.mapView];
    }
    
}


- (IBAction)findFoodPressed:(LoadingButton *)sender {
    
    
    if (self.currentLoction != nil) {
        
        [sender showLoading:true];
        
        float oneMile = 1.61 * 1000;
        [ConnectionManager requestPlacesNearMe:self.currentLoction.coordinate
                                googleMapsType:@"food"
                                        radius:oneMile
                                    completion:^(NSArray *places)
         {
             
             [sender showLoading:false];
             NSLog(@"Places: %@", places);
             self.placeAnnotations = places;
             [self dataReloaded];
             
         } errorBlock:^(NSError *error) {
             
             [sender showLoading:false];
             NSLog(@"Error: %@", error);
         }];
    }
    
}

- (void) dataReloaded {
    
    [self removeAnnotations];
    [self.mapView addAnnotations:self.placeAnnotations];
    for (PlaceAnnotation* annotation in self.placeAnnotations) {
        
        MKAnnotationView *view = [self.mapView viewForAnnotation:annotation];
        annotation.title = annotation.name;
        view.canShowCallout = true;
    }
    [self.tableView reloadData];
    
    MKCoordinateRegion region = [self getMapZoomSpanFromObjects:self.placeAnnotations];
    
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:true];

    
}

#pragma mark - MKMapView Delegate

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    
    if ([view.annotation isKindOfClass:[PlaceAnnotation class]]) {
        view.canShowCallout = true;
    }
    
}


- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (self.currentLoction == nil) {
        
        self.currentLoction = userLocation.location;
        
        MKCoordinateRegion region = [self getMapZoomSpanForLocation:userLocation.location.coordinate];
        
        [mapView setRegion:[mapView regionThatFits:region] animated:true];
        
    }
}

#pragma mark - LocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        
        [self.locationManager startUpdatingLocation];
        
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    if (locations.count > 0)
    {
        
        [manager stopUpdatingLocation];
    }
    
}

#pragma mark - TableView Delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.placeAnnotations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//    NSString *cellId = @"identifier";
     PlaceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlaceCell"];
    
//    if (!cell)
//    {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PlaceCell"];
//    }
//    
    //    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#Prototype Identifier#>];
    
    [cell setupWithPlace:self.placeAnnotations[indexPath.row]];
    
    return cell;
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//}



#pragma mark - Misc Functions

- (MKCoordinateRegion) getMapZoomSpanForLocation:(CLLocationCoordinate2D)location
{
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.02;
    span.longitudeDelta = 0.02;
    region.span = span;
    region.center = location;
    return region;
}

- (MKCoordinateRegion) getMapZoomSpanFromObjects:(NSArray*)annotations
{
    float maxLat = 0;
    float minLat = 55;
    float maxLong = 0;
    float minLong = 1;
    
    for (PlaceAnnotation *annotation in annotations)
    {
        minLat = (annotation.coordinate.latitude < minLat) ? annotation.coordinate.latitude : minLat;
        maxLat = (annotation.coordinate.latitude > maxLat) ? annotation.coordinate.latitude : maxLat;
        minLong = (annotation.coordinate.longitude < minLong) ? annotation.coordinate.longitude : minLong;
        maxLong = (annotation.coordinate.longitude > maxLong) ? annotation.coordinate.longitude : maxLong;
    }
    
    CLLocationDegrees deltaLat = maxLat-minLat;
    
    CLLocationDegrees deltaLong = maxLong-minLong;
    
    CLLocationCoordinate2D centerCoord = CLLocationCoordinate2DMake(minLat + deltaLat/2, minLong + deltaLong/2);
    
    // Add margin between pins and edgeo of mapview
    deltaLat = deltaLat * 1;
    deltaLong = deltaLong * 1;
    
    MKCoordinateSpan span = MKCoordinateSpanMake(deltaLat, deltaLong);
    
    return MKCoordinateRegionMake(centerCoord, span);
    
}

- (void)removeAnnotations
{
    
    NSArray *annotationsToRemove = @[];
    
    for (id<MKAnnotation> annotation in self.mapView.annotations)
    {
        if (![annotation isKindOfClass:[MKUserLocation class]])
        {
            annotationsToRemove = [annotationsToRemove arrayByAddingObject:annotation];
        }
    }
    
    [self.mapView removeAnnotations:annotationsToRemove];
    
}


@end
