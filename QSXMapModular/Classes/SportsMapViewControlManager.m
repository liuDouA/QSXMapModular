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
#import "AMapRouteRecord.h"
#import "QSXMAPointAnnotation.h"
static dispatch_once_t onceToken;
static SportsMapViewControlManager *SportsMapmanager =nil;


#define kTempTraceLocationCount 20
@interface SportsMapViewControlManager ()<MAMapViewDelegate, AMapLocationManagerDelegate>
@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) UIButton *locationBtn;
@property (nonatomic, strong) UIImage *imageLocated;
@property (nonatomic, strong) UIImage *imageNotLocate;

@property (nonatomic, assign) BOOL isRecording;
@property (atomic, assign) BOOL isSaving;

@property (nonatomic, strong) MAPolyline *polyline;

@property (nonatomic, strong) AMapRouteRecord *currentRecord;

@property (nonatomic, strong) NSMutableArray *tracedPolylines;// 中间变量  记录地图上的  线  方便移除 不可少
@property (nonatomic, strong) NSMutableArray *ChacePolylines; //存放的 一路上的所有的线
@property (nonatomic, strong) NSMutableArray *tempTraceLocations;//中间变量  每段线的所有坐标


@property(assign,nonatomic)BOOL    mapViewStartWork;// 地图开始工作
@property(assign,nonatomic)BOOL    mapViewPasueWork; //地图暂停工作
@property(assign,nonatomic)BOOL    mapViewStopWork;  //地图停止工作

@property(assign,nonatomic)BOOL    ponitIsBegining;  //地图开始工作 起始点标记



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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
     //[self.locationManager startUpdatingLocation];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.mapViewStartWork = NO;
    self.mapViewPasueWork = NO;
    self.mapViewStopWork = NO;
    self.ponitIsBegining = NO;
    if (self.currentRecord == nil)
    {
        self.currentRecord = [[AMapRouteRecord alloc] init];
    }
    
    
    
    [self initMapView];
    [self initBtnView];
    self.tracedPolylines = [NSMutableArray array];
    self.tempTraceLocations = [NSMutableArray array];
    self.ChacePolylines = [NSMutableArray array];

    
}
- (void)initMapView
{
    if (self.mapView == nil)
    {
        
        self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
        self.mapView.zoomLevel = 16.0;
        self.mapView.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        
        self.mapView.showsIndoorMap = YES;
        self.mapView.delegate = self;
        
        [self.view addSubview:self.mapView];

    }
}
- (void)initBtnView
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(20, 110, 60, 40);
    btn.backgroundColor = [UIColor redColor];
    [btn addTarget:self action:@selector(btnClickStart) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"开始" forState:UIControlStateNormal];
    [self.view addSubview:btn];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame = CGRectMake(self.view.frame.size.width-250, 110, 60, 40);
    btn2.backgroundColor = [UIColor greenColor];
    [btn2 addTarget:self action:@selector(btnzhantingClick) forControlEvents:UIControlEventTouchUpInside];
    [btn2 setTitle:@"暂停" forState:UIControlStateNormal];
    [self.view addSubview:btn2];
    
    UIButton *btnJx = [UIButton buttonWithType:UIButtonTypeCustom];
    btnJx.frame = CGRectMake(self.view.frame.size.width-180, 110, 60, 40);
    btnJx.backgroundColor = [UIColor greenColor];
    [btnJx addTarget:self action:@selector(JIxuClick) forControlEvents:UIControlEventTouchUpInside];
    [btnJx setTitle:@"恢复" forState:UIControlStateNormal];
    [self.view addSubview:btnJx];
    
    UIButton *btn3 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn3.frame = CGRectMake(self.view.frame.size.width-90, 110, 60, 40);
    btn3.backgroundColor = [UIColor orangeColor];
    [btn3 addTarget:self action:@selector(btnStopClick) forControlEvents:UIControlEventTouchUpInside];
    [btn3 setTitle:@"结束" forState:UIControlStateNormal];
    [self.view addSubview:btn3];
    
    
    UIButton *btn4 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn4.frame = CGRectMake(self.view.frame.size.width-140, self.view.frame.size.height-50, 100, 40);
    btn4.backgroundColor = [UIColor greenColor];
    [btn4 addTarget:self action:@selector(btnClickbackCenter) forControlEvents:UIControlEventTouchUpInside];
    [btn4 setTitle:@"回中心点" forState:UIControlStateNormal];
    [self.view addSubview:btn4];
    
    
}


- (void)btnClickStart{
    
    [self  ChangemapViewStartWork];
    [self  showUserLinePathPonit];
    
}

- (void)btnzhantingClick{
    [self ChangemapViewPasueWork];
    [self.tempTraceLocations removeAllObjects];
    [self.ChacePolylines addObject:self.polyline];
    
    [self showUserLinePathPonit];
}
- (void)JIxuClick{
    
    [self ChangemapViewBeginAgin];
    
    [self showUserLinePathPonit];
}
- (void)btnStopClick
{
    [self ChangemapViewStopWork];
    [self.tempTraceLocations removeAllObjects];
    [self.ChacePolylines addObject:self.polyline];
    
    [self showUserLinePathPonit];
}

- (void)ChangemapViewStartWork{
    self.mapViewStartWork = YES;
    self.mapViewPasueWork = NO;
    self.mapViewStopWork = NO;
    
    
    
    self.ponitIsBegining = YES;
}
- (void)ChangemapViewPasueWork{
    self.mapViewPasueWork = YES;
    self.mapViewStartWork = NO;
    self.mapViewStopWork = NO;
    
}

- (void)ChangemapViewBeginAgin{
    self.mapViewStartWork = YES;
    self.mapViewPasueWork = NO;
    self.mapViewStopWork = NO;
    
    self.ponitIsBegining = YES;
    
}
- (void)ChangemapViewStopWork{
    self.mapViewStopWork = YES;
    self.mapViewStartWork = NO;
    self.mapViewPasueWork = NO;
}

- (void)showUserLinePathPonit{
    [self.ChacePolylines enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MAPolyline  *polyLines = (MAPolyline*)obj;
        
//        polyLines.points[0];
//        polyLines.points[2];
//        polyLines.points[polyLines.pointCount-1]
        if (idx==0) {
           QSXMAPointAnnotation  *animatinPause =[[QSXMAPointAnnotation alloc]init];
            animatinPause.coordinate = MACoordinateForMapPoint(polyLines.points[polyLines.pointCount-1]);
            if (self.ChacePolylines.count==1&&self.mapViewStopWork) {
                // 结束点
                animatinPause.typeFlage = 4;
            }else{
                //暂停点
                animatinPause.typeFlage = 2;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.mapView  addAnnotation:animatinPause];
            });
            
            
        }else if ((idx==self.ChacePolylines.count-1)&&self.mapViewStopWork){
            // 再次开始
            QSXMAPointAnnotation  *animatinBegin =[[QSXMAPointAnnotation alloc]init];
            animatinBegin.coordinate = MACoordinateForMapPoint(polyLines.points[0]);
            animatinBegin.typeFlage = 3;
            
            //结束
            QSXMAPointAnnotation  *animatinStop =[[QSXMAPointAnnotation alloc]init];
            animatinStop.coordinate = MACoordinateForMapPoint(polyLines.points[polyLines.pointCount-1]);
            animatinStop.typeFlage = 4;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.mapView  addAnnotation:animatinBegin];
                [self.mapView  addAnnotation:animatinStop];
            });
            
        }else{
            //中间的线
            
            // 再次开始
            QSXMAPointAnnotation  *animatinBegin =[[QSXMAPointAnnotation alloc]init];
            animatinBegin.coordinate = MACoordinateForMapPoint(polyLines.points[0]);
            animatinBegin.typeFlage = 3;
            
            //暂停
            QSXMAPointAnnotation  *animatinPause =[[QSXMAPointAnnotation alloc]init];
            animatinPause.coordinate = MACoordinateForMapPoint(polyLines.points[polyLines.pointCount-1]);
            animatinPause.typeFlage = 2;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.mapView  addAnnotation:animatinBegin];
                [self.mapView  addAnnotation:animatinPause];
            });
            
            
        }
        
        
        
    }];
}

// 暂时不用  等展示记录的数据使用
- (void)userCatchOrNetWorkDownload{
    
    {
        [self.ChacePolylines enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            MAPolyline  *polyLines = (MAPolyline*)obj;
            
            //        polyLines.points[0];
            //        polyLines.points[2];
            //        polyLines.points[polyLines.pointCount-1]
            if (idx==0) {
                
                
                QSXMAPointAnnotation  *animatin =[[QSXMAPointAnnotation alloc]init];
                animatin.coordinate =  MACoordinateForMapPoint(polyLines.points[0]);;
                animatin.typeFlage = 1;
                
                
                
                QSXMAPointAnnotation  *animatinPause =[[QSXMAPointAnnotation alloc]init];
                animatinPause.coordinate = MACoordinateForMapPoint(polyLines.points[polyLines.pointCount-1]);
               
                if (self.ChacePolylines.count==1) {
                    // 结束点
                    animatinPause.typeFlage = 4;
                }else{
                    //暂停点
                     animatinPause.typeFlage = 2;
                }
                
               
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.mapView addAnnotation:animatin];
                    [self.mapView  addAnnotation:animatinPause];
                });
                
                
            }else if (idx==self.ChacePolylines.count-1){
                // 再次开始
                QSXMAPointAnnotation  *animatinBegin =[[QSXMAPointAnnotation alloc]init];
                animatinBegin.coordinate = MACoordinateForMapPoint(polyLines.points[0]);
                animatinBegin.typeFlage = 3;
                
                //结束
                QSXMAPointAnnotation  *animatinStop =[[QSXMAPointAnnotation alloc]init];
                animatinStop.coordinate = MACoordinateForMapPoint(polyLines.points[polyLines.pointCount-1]);
                animatinStop.typeFlage = 4;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.mapView  addAnnotation:animatinBegin];
                    [self.mapView  addAnnotation:animatinStop];
                });
                
            }else{
                //中间的线
                
                // 再次开始
                QSXMAPointAnnotation  *animatinBegin =[[QSXMAPointAnnotation alloc]init];
                animatinBegin.coordinate = MACoordinateForMapPoint(polyLines.points[0]);
                animatinBegin.typeFlage = 3;
                
                //暂停
                QSXMAPointAnnotation  *animatinPause =[[QSXMAPointAnnotation alloc]init];
                animatinPause.coordinate = MACoordinateForMapPoint(polyLines.points[polyLines.pointCount-1]);
                animatinPause.typeFlage = 2;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.mapView  addAnnotation:animatinBegin];
                    [self.mapView  addAnnotation:animatinPause];
                });
                
                
            }
            
            
            
        }];
    }
    
}

- (void)btnClickbackCenter
{
    
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"MapIsHidden"];
    [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:YES];
}

#pragma mark - MapView Delegate
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    if (!updatingLocation)
    {
        return;
    }
    if (!self.mapViewStartWork) {
        return;
    }
    if (userLocation.location.horizontalAccuracy < 100 && userLocation.location.horizontalAccuracy > 0)
    {
        double lastDis = [userLocation.location distanceFromLocation:self.currentRecord.endLocation];
        
        if (lastDis < 0 || lastDis > 2)
        {
            
            [self.currentRecord addLocation:userLocation.location];
            
            [self.mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
            
            
            // trace
            [self.tempTraceLocations addObject:userLocation.location];
            
            [self queryTraceWithLocations:self.tempTraceLocations withSaving:NO];

        }
    }

}
- (void)mapView:(MAMapView *)mapView didChangeUserTrackingMode:(MAUserTrackingMode)mode animated:(BOOL)animated
{
    if (mode == MAUserTrackingModeNone)
    {
        [self.locationBtn setImage:self.imageNotLocate forState:UIControlStateNormal];
    }
    else
    {
        [self.locationBtn setImage:self.imageLocated forState:UIControlStateNormal];
    }
}

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay
{

        MAPolylineRenderer *view = [[MAPolylineRenderer alloc] initWithPolyline:overlay];
        view.lineWidth = 5.0;
        view.strokeColor = [UIColor redColor];
        return view;

    /*
     MAMultiColoredPolylineRenderer *view = [[MAMultiColoredPolylineRenderer alloc] initWithPolyline:overlay];
     view.gradient = YES;
     view.lineWidth = 8;
     view.strokeColors = @[[UIColor greenColor], [UIColor redColor]];
     */
    
    return nil;
}
#pragma mark - Utility

- (CLLocationCoordinate2D *)coordinatesFromLocationArray:(NSArray *)locations count:(NSUInteger *)count
{
    if (locations.count == 0)
    {
        return NULL;
    }
    
    *count = locations.count;
    
    CLLocationCoordinate2D *coordinates = (CLLocationCoordinate2D *)malloc(sizeof(CLLocationCoordinate2D) * *count);
    
    int i = 0;
    for (CLLocation *location in locations)
    {
        coordinates[i] = location.coordinate;
        ++i;
    }
    
    return coordinates;
}


- (void)queryTraceWithLocations:(NSArray<CLLocation *> *)locations withSaving:(BOOL)saving
{
    if (locations.count < 2) {
        return;
    }
    
    if (self.ponitIsBegining) {
        QSXMAPointAnnotation  *animatin =[[QSXMAPointAnnotation alloc]init];
        animatin.coordinate = locations[0].coordinate;;
        if (self.ChacePolylines.count==0) {
            animatin.typeFlage = 1;
        }else{
            animatin.typeFlage = 3;
        }
        
        [self.mapView addAnnotation:animatin];
        self.ponitIsBegining = NO;
    }
    
    NSMutableArray *points = [NSMutableArray array];
    for(CLLocation *loc in locations)
    {
        MATracePoint *tLoc = [[MATracePoint alloc] init];
        tLoc.latitude = loc.coordinate.latitude;
        tLoc.longitude = loc.coordinate.longitude;
        [points addObject:tLoc];
    }
     [self addFullTrace:points];

}

- (void)addFullTrace:(NSArray<MATracePoint*> *)tracePoints
{
    MAPolyline *polyline = [self makePolylineWith:tracePoints];
    if(!polyline)
    {
        return;
    }
    self.polyline = polyline;
    [self.mapView removeOverlays:self.tracedPolylines];
    [self.tracedPolylines addObject:polyline];
    [self.mapView  addOverlays:self.ChacePolylines];
    [self.mapView addOverlay:polyline];
    
}

- (MAPolyline *)makePolylineWith:(NSArray<MATracePoint*> *)tracePoints
{
    if(tracePoints.count < 2)
    {
        return nil;
    }
    
    CLLocationCoordinate2D *pCoords = malloc(sizeof(CLLocationCoordinate2D) * tracePoints.count);
    if(!pCoords) {
        return nil;
    }
    
    for(int i = 0; i < tracePoints.count; ++i) {
        MATracePoint *p = [tracePoints objectAtIndex:i];
        CLLocationCoordinate2D *pCur = pCoords + i;
        pCur->latitude = p.latitude;
        pCur->longitude = p.longitude;
    }
    
    MAPolyline *polyline = [MAPolyline polylineWithCoordinates:pCoords count:tracePoints.count];
    
    if(pCoords)
    {
        free(pCoords);
    }
    
    return polyline;
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[QSXMAPointAnnotation class]]) {
        static NSString *pointReuseIndetifier = @"pointReuseIndetifierQSX";
        MAPinAnnotationView *annotationView = (MAPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndetifier];
        }
        
        annotationView.canShowCallout   = NO;
        annotationView.animatesDrop     = NO;
        annotationView.draggable        = NO;
        
        QSXMAPointAnnotation  *midAni = (QSXMAPointAnnotation*)annotation;
        if (midAni.typeFlage == 1) {
            annotationView.image            = BundelImage(@"开始@2x.png");
        }
        if (midAni.typeFlage == 2) {
            annotationView.image            = BundelImage(@"暂停@2x.png");
        }
        
        if (midAni.typeFlage == 3) {
            annotationView.image            = BundelImage(@"再开始.png");
        }
        if (midAni.typeFlage == 4) {
            annotationView.image            = BundelImage(@"结束.png");
        }
        
        return annotationView;
    }
    
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
        annotationView.image            = BundelImage(@"开始@2x.png");
        annotationView.zIndex=100000;
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
