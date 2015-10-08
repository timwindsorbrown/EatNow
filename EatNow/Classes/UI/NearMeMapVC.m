//
//  NearMeMapVC.m
//  EatNow
//
//  Created by Tim Windsor Brown on 08/10/2015.
//  Copyright © 2015 ExNihilo. All rights reserved.
//

#import "NearMeMapVC.h"
#import <MapKit/MapKit.h>


@interface NearMeMapVC () <MKMapViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *findFoodButton;
@property (strong, nonatomic) UIButton *showMapButton;
@property (strong, nonatomic) UIButton *showListButton;


@end

@implementation NearMeMapVC


-(void) viewDidLoad {
    
    [super viewDidLoad];
    
}

#pragma mark - Actions

- (IBAction)listButtonPressed:(UIButton *)sender {
    [[sender superview] bringSubviewToFront:sender];
    [[self containerView] bringSubviewToFront:self.tableView];
    
}

- (IBAction)mapButtonPressed:(UIButton *)sender {
    
    [[sender superview] bringSubviewToFront:sender];
    [[self containerView] bringSubviewToFront:self.mapView];
}

- (IBAction)findFoodPressed:(UIButton *)sender {
    
}

#pragma mark - MKMapView Delegate

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    
//    if ([view.annotation isKindOfClass:[EWMapLocationObject class]])
//    {
//        self.locationTitle.text = [(EWMapLocationObject*)view.annotation title];
//        self.locationDescription.text = [(EWMapLocationObject*)view.annotation locationDescription];
//    }
    
}

- (void) mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered
{
//    if (self.mapView.alpha != 1)
//    {
//        [UIView animateWithDuration:0.34f animations:^{
//            self.mapView.alpha = 1;
//        }];
//    }
//    
//    [self.view bringSubviewToFront:self.annotationSelector];
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    
    
//    if ([annotation isKindOfClass:[EWMapLocationObject class]])
//    {
//        
//        MKAnnotationView *annView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kANNOTATION_REUSE_KEY];
//        
//        EWMapLocationObject *location = (EWMapLocationObject*)annotation;
//        annView.image = [location annotationImage];
//        annView.enabled = YES;
//        
//        return annView;
//    }
    
    
    return nil;
}


@end
