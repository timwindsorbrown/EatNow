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

@interface NearMeMapVC () <CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *findFoodButton;
@property (weak, nonatomic) IBOutlet UIButton *viewTypeButton;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLoction;
@property (strong, nonatomic) NSArray *placeAnnotations;


@end

@implementation NearMeMapVC



-(void) viewDidLoad {
    
    [super viewDidLoad];
    
    // Setup location manager
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    
    // Set default view display
    [self.viewTypeButton setImage:[UIImage imageNamed:@"List_Small"] forState:UIControlStateNormal];
    [self.containerView bringSubviewToFront:self.mapView];

    // Setup TableView
    self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 80, 0);
    
}

#pragma mark - Actions

- (IBAction) viewTypeButtonPressed:(UIButton *)sender {
    
    NSUInteger mapViewIndex = [[self.mapView superview].subviews indexOfObject:self.mapView];
    NSUInteger listViewIndex = [[self.tableView superview].subviews indexOfObject:self.tableView];
    
    if (mapViewIndex > listViewIndex) { // List on top
        [sender setImage:[UIImage imageNamed:@"Map_Small"] forState:UIControlStateNormal];
        [self.containerView bringSubviewToFront:self.tableView];

    }
    else { // Map on top
        [sender setImage:[UIImage imageNamed:@"List_Small"] forState:UIControlStateNormal];
        [self.containerView bringSubviewToFront:self.mapView];
    }
    
}


- (IBAction)findFoodPressed:(LoadingButton *)sender {
    
    
    if (self.currentLoction != nil) {
        
        [sender showLoading:true];
        
        float oneMile = 1.61 * 1000; // 1 mile -> meters
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
             UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error!" message:@"Unable to search for places, check your network and try again." preferredStyle:UIAlertControllerStyleAlert];
             [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
             [self presentViewController:alert animated:true completion:nil];
             NSLog(@"Error: %@", error);
         }];
    }
    else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error!" message:@"Cannont determine your location, check your settings and try again." preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:true completion:nil];
    }
    
}

// Has reloaded data, refresh data sources
- (void) dataReloaded {
    
    [self removeAnnotations];
    [self.mapView addAnnotations:self.placeAnnotations];
    for (PlaceAnnotation* annotation in self.placeAnnotations) {
        
        MKAnnotationView *view = [self.mapView viewForAnnotation:annotation];
        annotation.title = annotation.name;
        view.canShowCallout = true;
    }
    
    // Zoom to show all pins
    MKMapRect rect = [self getMapZoomSpanFromObjects:self.placeAnnotations];
    [self.mapView setVisibleMapRect:rect animated:YES];

    [self.tableView reloadData];
    
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
    
    self.currentLoction = userLocation.location;

    if (self.currentLoction == nil) {
        
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
    
     PlaceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlaceCell"];
    [cell setupWithPlace:self.placeAnnotations[indexPath.row]];
    
    return cell;
}


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

- (MKMapRect) getMapZoomSpanFromObjects:(NSArray*)annotations
{
    MKMapPoint annotationPoint = MKMapPointForCoordinate(self.mapView.userLocation.coordinate);
    MKMapRect zoomRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
    for (id <MKAnnotation> annotation in self.mapView.annotations)
    {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
        zoomRect = MKMapRectUnion(zoomRect, pointRect);
    }
    
    // Add Padding
    double inset = -zoomRect.size.width * 0.1;
    zoomRect = MKMapRectInset(zoomRect, inset, inset);
    return zoomRect;
    
}

- (void)removeAnnotations
{
    
    for (id<MKAnnotation> annotation in self.mapView.annotations)
    {
        if (![annotation isKindOfClass:[MKUserLocation class]])
        {
            [self.mapView removeAnnotation:annotation];
        }
    }
}


@end
