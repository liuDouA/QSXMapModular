//
//  SportsMapViewControlManager.m
//  Pods
//
//  Created by 刘豆 on 2018/9/13.
//

#import "SportsMapViewControlManager.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
static dispatch_once_t onceToken;
static SportsMapViewControlManager *SportsMapmanager =nil;

@interface SportsMapViewControlManager ()<MAMapViewDelegate, AMapLocationManagerDelegate>
@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) AMapLocationManager *locationManager;

@property (nonatomic, strong) UISegmentedControl *showSegment;
@property (nonatomic, strong) UISegmentedControl *backgroundSegment;
@property (nonatomic, strong) MAPointAnnotation *pointAnnotaiton;
@end

@implementation SportsMapViewControlManager


+ (SportsMapViewControlManager *) shareManager
{
    dispatch_once(&onceToken, ^{
        SportsMapmanager = [[SportsMapViewControlManager alloc] init];
        [AMapServices sharedServices].apiKey =@"0ca5230eaac6389788b6bb40b39cd0a9";
        
    });
    return SportsMapmanager;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"will appear");
    
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    NSLog(@"will dis appear");
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self initMapView];
    
    [self configLocationManager];
    [self initBtnView];
    
}
- (void)initMapView
{
    if (self.mapView == nil)
    {
        self.mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        [self.mapView setDelegate:self];
        self.mapView.userTrackingMode = MAUserTrackingModeFollow;
        [self.mapView setMapType:MAMapTypeStandard];
        
        self.mapView.showsUserLocation = YES;
        
        [self.view addSubview:self.mapView];
    }
}
- (void)initBtnView
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(100, 110, 60, 40);
    btn.backgroundColor = [UIColor redColor];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"返回" forState:UIControlStateNormal];
    [self.view addSubview:btn];
    
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame = CGRectMake(self.view.frame.size.width-140, 110, 60, 40);
    btn2.backgroundColor = [UIColor greenColor];
    [btn2 addTarget:self action:@selector(btnStopClick) forControlEvents:UIControlEventTouchUpInside];
    [btn2 setTitle:@"暂停" forState:UIControlStateNormal];
    [self.view addSubview:btn2];
    
    
}
- (void)btnClick
{
    self.view.hidden = YES;
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"MapIsHidden"];
}
- (void)btnStopClick
{
    [self.locationManager stopUpdatingLocation];
    [self.mapView removeAnnotations:self.mapView.annotations];
    self.pointAnnotaiton = nil;
    
    //设置允许系统暂停定位
    [self.locationManager setPausesLocationUpdatesAutomatically:YES];
    
    //设置禁止在后台定位
    [self.locationManager setAllowsBackgroundLocationUpdates:NO];
}
- (void)configLocationManager
{
    self.locationManager = [[AMapLocationManager alloc] init];
    
    [self.locationManager setDelegate:self];
    
    //设置不允许系统暂停定位
    [self.locationManager setPausesLocationUpdatesAutomatically:NO];
    
    //设置允许在后台定位
    [self.locationManager setAllowsBackgroundLocationUpdates:YES];
    
    //设置允许连续定位逆地理
    [self.locationManager setLocatingWithReGeocode:YES];
    
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.locationManager startUpdatingLocation];
}
#pragma mark - AMapLocationManager Delegate

- (void)amapLocationManager:(AMapLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"%s, amapLocationManager = %@, error = %@", __func__, [manager class], error);
}

- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location reGeocode:(AMapLocationReGeocode *)reGeocode
{
    NSLog(@"location:{lat:%f; lon:%f; accuracy:%f; reGeocode:%@}", location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy, reGeocode.formattedAddress);
    
    //获取到定位信息，更新annotation
    if (self.pointAnnotaiton == nil)
    {
        self.pointAnnotaiton = [[MAPointAnnotation alloc] init];
        [self.pointAnnotaiton setCoordinate:location.coordinate];
        
        [self.mapView addAnnotation:self.pointAnnotaiton];
    }
    
    [self.pointAnnotaiton setCoordinate:location.coordinate];
    
    [self.mapView setCenterCoordinate:location.coordinate];
    [self.mapView setZoomLevel:15.1 animated:NO];
}
#pragma mark - MAMapView Delegate

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndetifier = @"pointReuseIndetifier";
        
        MAPinAnnotationView *annotationView = (MAPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndetifier];
        }
        
        annotationView.canShowCallout   = NO;
        annotationView.animatesDrop     = NO;
        annotationView.draggable        = NO;
        annotationView.image            = [UIImage imageNamed:@"icon_location.png"];
        
        return annotationView;
    }
    
    return nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
