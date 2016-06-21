//
//  GoodAppGameViewController.m
//  MyHelper
//
//  Created by 李环宇 on 15-1-20.
//  Copyright (c) 2015年 myHelper. All rights reserved.
//


#import "GoodAppGameViewController.h"

@interface GoodAppGameViewController ()<UICollectionViewDataSource ,UICollectionViewDelegate ,UICollectionViewDelegateFlowLayout,EGORefreshTableHeaderDelegate,UIScrollViewDelegate,MyServerRequestManagerDelegate,CarouselViewDelegate>{
    GoodType goodType;
    UICollectionView *myCollectionView;
    UIWebViewController *webView;
    TopicDetailsViewController *topicDetailsView;

    EGORefreshTableHeaderView * _refreshHeader;
    
    BOOL isLoading;
    BOOL result;
    BOOL HeaderBool;//失败加载页判断
    BOOL hasNextData; // 是否有下页数据
    BOOL lunboBool;
    BOOL couldPullRefreshFlag; // 是否请求中

    NSInteger pageNumber;
    NSInteger _pageCount;

    
    CollectionCellRequestStyle lastCellStyle;
    CollectionViewBack * _goodbackView;
    
    NSArray *_firstImageAry;
    
    LoadingCollectionCell *_cell_loading;
    
    NSArray *loopingPicturesArr; // 轮播图
    CarouselView*loopingView;
    int loadingCellHigh;
    SearchResult_DetailViewController *detailVC;//app详情页面
}

@end

static NSString *CellIdentifier = @"PublicCollectionCell_good";
static NSString *cellLoadingIden = @"LoadingCollectionCell_good";
static NSString*lunboIdentidier=@"lunboCollectionCell_good";
@implementation GoodAppGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor whiteColor];
    
    
    [[MyServerRequestManager getManager]addListener:self];
    _dataArr=[[NSMutableArray alloc] init];
    result=YES;
    HeaderBool=YES;
    lunboBool=YES;
    hasNextData=YES;
    loadingCellHigh=0;
    [self initCollectionView];
    [self setCollectionViewFrame];
    _goodbackView = [CollectionViewBack new];
    __weak typeof(self) mySelf = self;
    [_goodbackView setClickActionWithBlock:^{
        [mySelf setHeaderBool:YES];
        [mySelf performSelector:@selector(initGoodRequest) withObject:nil afterDelay:delayTime];
    }];
    _goodbackView.status = Loading;
    
    [self.view addSubview:_goodbackView];
    
    detailVC = [[SearchResult_DetailViewController alloc]init];

    
}
- (void)initCollectionView{
    
    //列表
    MyCollectionViewFlowLayout *flowLayout = [MyCollectionViewFlowLayout new];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    myCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    myCollectionView.backgroundColor = hllColor(242, 242, 242, 1);
    myCollectionView.dataSource = self;
    myCollectionView.delegate = self;
    myCollectionView.alwaysBounceVertical = YES;
    myCollectionView.indicatorStyle=UIScrollViewIndicatorStyleDefault;
    [myCollectionView registerClass:[PublicCollectionCell class] forCellWithReuseIdentifier:CellIdentifier];
    [myCollectionView registerClass:[LoadingCollectionCell class] forCellWithReuseIdentifier:cellLoadingIden];
    [myCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:lunboIdentidier];

    [self.view addSubview:myCollectionView];
    
    
    _refreshHeader = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectZero];
    _refreshHeader.egoDelegate = self;
    _refreshHeader.backgroundColor=[UIColor whiteColor];
    _refreshHeader.inset = myCollectionView.contentInset;
    [myCollectionView addSubview:_refreshHeader];
    
    [self initLoopingPictures];
//    [myCollectionView addSubview:loopingView];

}
-(void)setCollectionViewFrame
{
    myCollectionView.frame=CGRectMake(0, 62, MainScreen_Width, MainScreen_Height - 20-64+0);
    _refreshHeader.frame = CGRectMake(0, -myCollectionView.frame.size.height-myCollectionView.contentInset.top+0, myCollectionView.bounds.size.width, myCollectionView.bounds.size.height);
    _goodbackView.frame = CGRectMake(0, 0, MainScreen_Width, MainScreen_Height - 20);
//    NSLog(@"--------------%d",loadingCellHigh);

}

- (void)viewWillLayoutSubviews{
    
    [super viewWillLayoutSubviews];
    
    
}
-(void)appJudge:(GoodType)state{
    goodType=state;
    classState=[NSString stringWithFormat:@"%d",state];
    
}
//网络请求
-(void)initGoodRequest{
    
    pageNumber = 1;
//    NSLog(@"首次网络请求");
    couldPullRefreshFlag=NO;
    //轮播
    if ( goodType==good_app) {
        [[MyServerRequestManager getManager] requestCarouselDiagrams:lunBo_appType isUseCache:YES userData:classState];
        
//        NSLog(@"----app轮播请求");
    }else{
        [[MyServerRequestManager getManager] requestCarouselDiagrams:lunBo_gameType isUseCache:YES userData:classState];
//        NSLog(@"---game轮播请求");
    }

    
    //加载
    [self requestActivitiesData];
    
}
//网络请求
-(void)requestActivitiesData{
    if (result) {
        
        if (goodType==good_app) {
            [[MyServerRequestManager getManager] requestExcellentAppGameList:tagType_app pageCount:pageNumber isUseCache:pageNumber userData:classState];
            
        }else{
            [[MyServerRequestManager getManager] requestExcellentAppGameList:tagType_game pageCount:pageNumber isUseCache:pageNumber userData:classState];
        }
        _cell_loading.hidden=NO;

    }
    
}


//网络请求回调
- (void)excellentAppGameRequestSuccess:(NSDictionary *)dataDic TagType:(TagType)tagType pageCount:(NSInteger)pageCount isUseCache:(BOOL)isUseCache userData:(id)userData{
    if (![userData isEqualToString:classState]) return;
    if (pageNumber!=pageCount) return;
        
    _goodbackView.status = Hidden;
    _pageCount=pageCount;
    NSArray*ary=[dataDic objectForKey:@"data"];

    if ([[[dataDic objectForKey:@"flag"] objectForKey:@"dataend"] isEqualToString:@"y"]) {
//        NSLog(@"yyy");
        result=YES;

    }else{
//        NSLog(@"nnn");
        result=NO;
        _cell_loading.hidden=YES;
        if (pageCount!=1) {
            loadingCellHigh=44;
            [self setCollectionViewFrame];
        }
        }
    if (pageCount==1) {
        [_dataArr removeAllObjects];
    }
    if (pageCount>1) {
        HeaderBool=NO;
    }
    
    //    NSLog(@"网络请求成功--%@,",dataDic);
//    NSLog(@"---%lu----%ld",ary.count,pageCount);
    
    
    if (![[MyVerifyDataValid instance] verifySearchResultListData:dataDic]){
//        _cell_loading.hidden=YES;
        _goodbackView.status = Failed;
        result=YES;

        return;
    }  // 数据有效性检测

    if (ary.count>=1) {
        hasNextData=YES;
        [_dataArr addObjectsFromArray:ary];
    }else{
//        NSLog(@"就这些");
        //   上拉cell隐藏
//        _cell_loading.hidden=YES;
    }
    
    [myCollectionView reloadData];
    // 下次请求页数+1
    pageNumber++;

}
- (void)excellentAppGameRequestFailed:(TagType)tagType pageCount:(NSInteger)pageCount isUseCache:(BOOL)isUseCache userData:(id)userData{
    if (![userData isEqualToString:classState]) return;

//    NSLog(@"网请求失败");

    hasNextData=NO;
    if (HeaderBool&&pageNumber==1) {
        _goodbackView.status = Failed;
        
    }
    
}

#pragma mark - UICollectionView datasource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return _dataArr.count+2;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        
        UICollectionViewCell*cell=(UICollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.tag=331;
        return cell;
    }
    
    if (indexPath.row==_dataArr.count+1) {
        
        _cell_loading = [collectionView dequeueReusableCellWithReuseIdentifier:cellLoadingIden forIndexPath:indexPath];
        _cell_loading.identifier = nil;
        
//        NSLog(@"goodaa");
        if (self->hasNextData){
            lastCellStyle=CollectionCellRequestStyleLoading;

        }else{
            lastCellStyle=CollectionCellRequestStyleFailed;

        }
        [_cell_loading setStyle:lastCellStyle];
        if (_dataArr.count>0) {
            _cell_loading.hidden=YES;
            [self requestActivitiesData];

        }
        
        return _cell_loading;
        
    }
    
    PublicCollectionCell*cell=(PublicCollectionCell*)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.tag=502;
    [cell setBottomLineLong:NO];

    if (_dataArr!=nil) {
        
        //设置数据
        
        NSDictionary *showCellDic = [_dataArr objectAtIndex:indexPath.row-1];
        //设置属性
        cell.downLoadSource = HOME_PAGE_RECOMMEND_MY(indexPath.section, (long)indexPath.row);
        [cell setCellData:showCellDic];
        [cell initDownloadButtonState];

    }
    
    cell.backgroundColor = [UIColor whiteColor];
    
    
    return cell;
    
}

#pragma mark - UICollectionViewLayoutDelegate

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0) {
        CGSize size = CGSizeMake(self.view.frame.size.width,0);//300/2*MULTIPLE);
        return size;
        
    }

    if (indexPath.row<=_dataArr.count) {
        CGSize size = CGSizeMake(collectionView.frame.size.width,168/2*MULTIPLE);
        return size;
        
    }
    int height;
//    if (_pageCount==1&&_dataArr.count<3) {
//        height=212/2*MULTIPLE*(3-_dataArr.count);
//    }else{
        height=0;
//    }
    CGSize size = CGSizeMake(collectionView.frame.size.width,180/2*MULTIPLE+height);
    return size;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, 0, 0);
    return insets;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"ssss点击");
    if (indexPath.row!=_dataArr.count+1) {

    PublicCollectionCell *cell = (PublicCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    NSString *source =[NSString new];
    if (goodType==good_app) {
        source=EXCELLENT_APP((long)indexPath.row);
    }else{
        source=EXCELLENT_GAME((long)indexPath.row);
    }
        
    if (SHOW_REAL_VIEW_FLAG&&!DIRECTLY_GO_APPSTORE) {
        [self pushToAppDetailViewWithAppInfor:_dataArr[indexPath.row-1] andSoure:source];
    }else{
        [[NSNotificationCenter  defaultCenter] postNotificationName:OPEN_APPSTORE object:cell.appdigitalid];
    }
    
    //汇报点击
    [[ReportManage instance] reportAppDetailClick:source contentDic:_dataArr[indexPath.row-1]];
    }
//    if (_dataArr!=nil&&_dataArr.count>0) {
//        NSUInteger lastIndex = _dataArr.count;
//        [myCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
//        
//    }

}


#pragma mark - UIScrollViewDelegate
BOOL _deceler_good;
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_refreshHeader egoRefreshScrollViewDidScroll:scrollView];

    CGFloat refreshHeight = self.view.frame.size.height+49; // 底部导航条的高度
    if (couldPullRefreshFlag&&scrollView.contentSize.height-scrollView.contentOffset.y < refreshHeight){
//        NSLog(@"lalala");
        [self requestActivitiesData];
        
        couldPullRefreshFlag=NO;
    }

    
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (scrollView.decelerating) _deceler_good = YES;
    [_cell_loading setStyle:CollectionCellRequestStyleLoading];

}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [_refreshHeader egoRefreshScrollViewDidEndDragging:scrollView];
    if (!decelerate && !_deceler_good) [self exposure]; _deceler_good = NO;
    couldPullRefreshFlag=YES;
    if (!hasNextData&&!decelerate && !_deceler_good) {
        [_cell_loading setStyle:CollectionCellRequestStyleFailed];
        
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (!_deceler_good) {
        _deceler_good = YES;
        [self exposure];
        if (!hasNextData) {
            [_cell_loading setStyle:CollectionCellRequestStyleFailed];
            
        }
    }
   
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (scrollView.contentOffset.y<-(myCollectionView.contentInset.top+65) && !self->isLoading) {
        *targetContentOffset = scrollView.contentOffset;
    }
}

#pragma mark - 下拉刷新

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view{
    isLoading = YES;
    HeaderBool=NO;

    [self performSelector:@selector(downRefreshRquest) withObject:nil afterDelay:delayTime];
    result=YES;
    [self initGoodRequest];
    
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view{
    return isLoading;
}

- (void)downRefreshRquest{
    self -> isLoading = NO;
    [_refreshHeader egoRefreshScrollViewDataSourceDidFinishedLoading:myCollectionView];
}
#pragma mark - 曝光
- (void)exposure
{
//    NSLog(@"bbb");
    NSArray *cellArray = [myCollectionView visibleCells];
    
    NSMutableArray *appIds = [NSMutableArray array];
    NSMutableArray *digitalIds = [NSMutableArray array];
    
    for (UICollectionViewCell *obj in cellArray) {
        if (obj.tag == 502) {
            PublicCollectionCell *cell = (PublicCollectionCell*)obj;
            [appIds addObject:cell.appID];
            [digitalIds addObject:cell.appdigitalid];
        }
        if (obj.tag==331) {
            lunboBool=YES;
        }else{
            lunboBool=NO;
        }

    }
    NSString *source =[NSString new];
    if (goodType==good_app) {
        source=EXCELLENT_APP((long)-1);
    }else{
        source=EXCELLENT_GAME((long)-1);
    }
    [[ReportManage instance] reportAppBaoGuang:source appids:appIds digitalIds:digitalIds];
}

#pragma mark - initialization(轮播)

-(void)initLoopingPictures
{ // 轮播图
//    CGFloat topHeight = IOS7?64:0;
    loopingView=[[CarouselView alloc] initWithFrame:CGRectMake(0, 0, MainScreen_Width, lunboHeight)];
//    loopingView.delegate=self;
}
- (void)carouselViewClick:(NSInteger)index{
    
    if (!IS_NSARRAY(loopingPicturesArr) || !loopingPicturesArr.count) return;
    
    // 点击量汇报
    NSString *source = nil;
    if (loopingPicturesArr.count>0) {
        NSDictionary *dic = loopingPicturesArr[index];
        if (goodType==good_app) {
            source=HOME_PAGE_LUNBO(LUNBO_APP, (long)index);
        }else{
            source=HOME_PAGE_LUNBO(LUNBO_GAME, (long)index);
        }
        
        NSString*appid=[dic objectForKey:@"id"];
        if (appid) {
            [[ReportManage instance]reportOtherDetailClick:source appid:[dic objectForKey:@"id"]];
        }
    }
    
    NSDictionary *tmpDic = [loopingPicturesArr objectAtIndex:index];
    NSString *typeStr = [tmpDic objectForKey:LUNBO_LINK];
    if ([typeStr isEqualToString:@"app"]) {
        //应用
        NSDictionary *appDataDic = [tmpDic objectForKey:LUNBO_LINK_DETAIL];
        if (SHOW_REAL_VIEW_FLAG&&!DIRECTLY_GO_APPSTORE) {
            [self pushToAppDetailViewWithAppInfor:appDataDic andSoure:@"goodapp_luobo"];
        }else{
            [[NSNotificationCenter  defaultCenter] postNotificationName:OPEN_APPSTORE object:[appDataDic objectForKey:APPDIGITALID]];
        }
        
    }else if ([typeStr isEqualToString:@"article"]) {
        //文章
        [self showDetailInformation:loopingPicturesArr[index] withSource:source shareImage:nil];
        
    }else if ([typeStr isEqualToString:@"mobileLink"]) {
        //外链
        NSString *mobileLink = [tmpDic objectForKey:LUNBO_LINK_DETAIL];
        [webView navigation:mobileLink];
        [webView setTitle:[tmpDic objectForKey:LUNBO_TITLE]];
        [self pushDetailViewController:webView];
        
    }else if ([typeStr isEqualToString:@"special"]) {
        //专题
        NSDictionary *specialDataDic = [tmpDic objectForKey:LUNBO_LINK_DETAIL];
        [topicDetailsView setDataDic:specialDataDic andColorm:source];
        [self pushDetailViewController:topicDetailsView];
        
    }else if ([typeStr isEqualToString:@"safariLink"]) {
        //safar外链
        NSString *safariLink = [tmpDic objectForKey:LUNBO_LINK_DETAIL];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:safariLink]];
    }
}

-(void)carouselViewScroll:(NSInteger)index{
    
    if (loopingPicturesArr.count>0&&lunboBool) {
        
        NSString *source = nil;
        if (goodType==good_app) {
            source=HOME_PAGE_LUNBO(LUNBO_APP, (long)index);
        }else{
            source=HOME_PAGE_LUNBO(LUNBO_GAME, (long)index);
        }
        
        NSDictionary *dic = loopingPicturesArr[index];
        NSString*appid=[dic objectForKey:@"id"];
        if (appid) {
            NSArray*ary=[NSArray arrayWithObject:[dic objectForKey:@"id"]];
            [[ReportManage instance]reportAppBaoGuang:source appids:ary digitalIds:nil];
        }
    }
}
-(void)showDetailInformation:(NSDictionary *)infoDic withSource:(NSString *)fromSource shareImage:(UIImage *)img
{
    NSArray*ary=[NSArray arrayWithObjects:infoDic,fromSource, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_FIND object:ary];

//    FindDetailViewController * findDetailViewController = [[FindDetailViewController alloc] init];
//    findDetailViewController.fromSource = fromSource;
//    findDetailViewController.shareImage = img;
//    NSDictionary*dic=[[NSDictionary alloc] init];
//    if (![infoDic objectForKey:@"content_url"]) {
//        NSLog(@"没有文章 content_url");
//        dic=[infoDic objectForKey:@"link_detail"];
//    }else{
//        dic=infoDic;
//    }
//    
//    findDetailViewController.content = [dic objectForKey:@"content_url"];
//    [findDetailViewController reloadActivityDetailVC:dic];
//    [self pushDetailViewController:findDetailViewController];
//    
//    [self hideNavBottomBar:YES];
}

#pragma mark - MarketServerDelegate（轮播）

- (void)carouselDiagramsRequestSuccess:(NSDictionary *)dataDic type:(lunBoType)type isUseCache:(BOOL)isUseCache userData:(id)userData{
    if (type == lunBo_discoverType) return;
    
//    if (![classState isEqualToString:userData]) return;

    if ([userData isKindOfClass:[NSString class]]) {
        if (![userData isEqualToString:classState]) {
            return;
        }
    }
//    NSLog(@"userData: %@",userData);
        if (![[MyVerifyDataValid instance] checkLunboData:dataDic]) return; // 数据有效性检测
    //checkLunboData
    loopingPicturesArr = [dataDic objectForKey:@"data"];
    [loopingView setCarous_dataSource:loopingPicturesArr];
    [myCollectionView reloadData];
}

- (void)carouselDiagramsRequestFailed:(lunBoType)type isUseCache:(BOOL)isUseCache userData:(id)userData{
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)hideNavBottomBar:(BOOL)flag
{
    self.navigationController.navigationBar.hidden = flag;
    [[NSNotificationCenter defaultCenter] postNotificationName:HIDETABBAR object:(flag?@"yes":nil)];
}
#pragma mark - 推详情
- (void)pushToAppDetailViewWithAppInfor:(NSDictionary *)inforDic andSoure:(NSString *)source{
    [detailVC setAppSoure:source];
    [detailVC beginPrepareAppContent:inforDic];
    MyNavigationController *nav = (MyNavigationController *)((MarketAppGameViewController_my *)(self.delegate)).navigationController;
    [nav prepairScreenShot:((MarketAppGameViewController_my *)(self.delegate)).navigationController];
    [((MarketAppGameViewController_my *)(self.delegate)).navigationController pushViewController:detailVC animated:YES];
}
#pragma mark - Utility

-(void)pushDetailViewController:(UIViewController*)VC
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(GoodNavControllerPushViewController:)]) {
        [self.delegate GoodNavControllerPushViewController:VC];
    }
}

- (void)setHeaderBool:(BOOL)flag
{
    HeaderBool = flag;
}

- (void)dealloc
{
    [[MyServerRequestManager getManager] removeListener:self];
//    NSLog(@"----移除");
}


@end
