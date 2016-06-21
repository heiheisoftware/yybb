//
//  TopAppGameViewController.m
//  MyHelper
//
//  Created by 李环宇 on 14-12-31.
//  Copyright (c) 2014年 myHelper. All rights reserved.
//

#import "TopAppGameViewController.h"
#import "MyCollectionViewFlowLayout.h"
#import "PublicCollectionCell.h"
#import "TopFirstAppGameCell.h"
#import "EGORefreshTableHeaderView.h"
#import "LoadingCollectionCell.h"
#import "SearchManager.h"
#import "UIImageEx.h"
#import "AppStatusManage.h"
#import "SearchResult_DetailViewController.h"

#import "SearchResult_DetailTableViewController.h"

@interface TopAppGameViewController ()<UICollectionViewDataSource ,UICollectionViewDelegate ,UICollectionViewDelegateFlowLayout,EGORefreshTableHeaderDelegate,UIScrollViewDelegate,MyServerRequestManagerDelegate>{
    TopType topType;
    UICollectionView *myCollectionView;
    EGORefreshTableHeaderView * _refreshHeader;

    BOOL isLoading;
    BOOL result;
    BOOL HeaderBool;//失败加载页判断
    BOOL hasNextData; // 是否有下页数据
    BOOL couldPullRefreshFlag; // 是否请求中

    NSInteger pageNumber;

    CollectionCellRequestStyle lastCellStyle;
    CollectionViewBack * _backView;

    NSArray*_firstImageAry;
    LoadingCollectionCell *_cell_loading;
    int loadingCellHigh;
    SearchResult_DetailViewController *detailVC;//app详情页面
    SearchResult_DetailTableViewController *detaiTablVC;
    
    NSDictionary *_dicTop;
}

@end

static NSString *CellIdentifier_top = @"PublicCollectionCell";
static NSString *cellFirstIden_top = @"TopFirstAppGameCell";
static NSString *cellLoadingIden_top = @"LoadingCollectionCell_top";

@implementation TopAppGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor whiteColor];
    
    
    [[MyServerRequestManager getManager]addListener:self];
    _dataArr=[[NSMutableArray alloc] init];
    result=YES;
    HeaderBool=YES;
    hasNextData=YES;
    loadingCellHigh=0;
    [self initCollectionView];
    [self setCollectionViewFrame];
    _backView = [CollectionViewBack new];
    __weak typeof(self) mySelf = self;
    [_backView setClickActionWithBlock:^{
        [mySelf setHeaderBool:YES];
        [mySelf performSelector:@selector(initTopRequest) withObject:nil afterDelay:delayTime];
    }];
    _backView.status = Loading;
    [self.view addSubview:_backView];
    detailVC = [[SearchResult_DetailViewController alloc]init];

}

- (void)setHeaderBool:(BOOL)flag
{
    HeaderBool = flag;
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
    [myCollectionView registerClass:[PublicCollectionCell class] forCellWithReuseIdentifier:LISTVIEWCELLS];
    [myCollectionView registerClass:[LoadingCollectionCell class] forCellWithReuseIdentifier:cellLoadingIden_top];
    [myCollectionView registerClass:[TopFirstAppGameCell class] forCellWithReuseIdentifier:cellFirstIden_top];
    [self.view addSubview:myCollectionView];

    
    _refreshHeader = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectZero];
    _refreshHeader.egoDelegate = self;
    _refreshHeader.backgroundColor=[UIColor whiteColor];
    _refreshHeader.inset = myCollectionView.contentInset;
    [myCollectionView addSubview:_refreshHeader];


}
-(void)setCollectionViewFrame
{
    myCollectionView.frame=CGRectMake(0, 62, MainScreen_Width, MainScreen_Height - 20-64+loadingCellHigh);
    _refreshHeader.frame = CGRectMake(0, -myCollectionView.bounds.size.height-myCollectionView.contentInset.top, myCollectionView.bounds.size.width, myCollectionView.bounds.size.height);
    _backView.frame = myCollectionView.bounds;
    

}
- (void)viewWillLayoutSubviews{
    
    [super viewWillLayoutSubviews];


}
-(void)appJudge:(TopType)state{
    topType=state;
    classState=[NSString stringWithFormat:@"%d",state];

}
//网络请求
-(void)initTopRequest{
    pageNumber = 1;
    couldPullRefreshFlag=NO;
//    NSLog(@"首次网络请求");
    
//加载界面
    [self requestActivitiesData];

}
//网络请求
-(void)requestActivitiesData{
    if (result) {
        
        if (topType==top_app) {
            [[MyServerRequestManager getManager] requestRankingAppGameList:tagType_app rankingType:rankingType_All pageCount:pageNumber isUseCache:YES userData:classState];
   
        }else{
            [[MyServerRequestManager getManager] requestRankingAppGameList:tagType_game rankingType:rankingType_All pageCount:pageNumber isUseCache:YES userData:classState];
        }
        _cell_loading.hidden=NO;
//        [_cell_loading setStyle:CollectionCellRequestStyleLoading];

    }
    
}


//网络请求回调
- (void)rankingAppGameRequestSuccess:(NSDictionary *)dataDic TagType:(TagType)tagType rankingType:(RankingType)rankingType pageCount:(NSInteger)pageCount isUseCache:(BOOL)isUseCache userData:(id)userData{
    if (![userData isEqualToString:classState]) return;
    if (pageNumber!=pageCount) return;

    _backView.status = Hidden;

    if ([[[dataDic objectForKey:@"flag"] objectForKey:@"dataend"] isEqualToString:@"y"]) {
//        NSLog(@"y");
        result=YES;
        
    }else{
//        NSLog(@"n");
        result=NO;
        _cell_loading.hidden=YES;
        loadingCellHigh=44;
        [self setCollectionViewFrame];
        [_refreshHeader egoRefreshScrollViewDataSourceDidFinishedLoading:myCollectionView];
    }

//    NSLog(@"网络请求成功--%@,",dataDic);
    NSArray *ary = [dataDic objectForKey:@"data"];
//    NSLog(@"---%lu",ary.count);
    if (pageNumber==1 && ary.count>0 && ary!=nil) {
        NSDictionary *dic = [ary objectAtIndex:0];
        [_dataArr removeAllObjects];
        
        _dicTop = [NSDictionary dictionaryWithDictionary:dic];
        
//        [self firstAppImageRequest:[dic objectForKey:@"appiphonefirstpreview"]];
    }
    if (pageNumber>1) {
        HeaderBool=NO;
    }
      // 下次请求页数+1
    pageNumber++;

    if (![[MyVerifyDataValid instance] verifySearchResultListData:dataDic]){
//        _cell_loading.hidden=YES;
        _backView.status = Failed;

        return;
    }  // 数据有效性检测
    if (ary.count>=1) {
        hasNextData=YES;
        [_dataArr addObjectsFromArray:ary];
    }else{
//        NSLog(@"就这些");
    }

    [myCollectionView reloadData];

}

- (void)rankingAppGameRequestFailed:(TagType)tagType rankingType:(RankingType)rankingType pageCount:(NSInteger)pageCount isUseCache:(BOOL)isUseCache userData:(id)userData{
//    NSLog(@"网络请求失败");
    hasNextData=NO;

    if (HeaderBool&&pageNumber==1) {
        _backView.status = Failed;

    }

}

-(void)firstAppImageRequest:(NSString*)ipadetailinfor{

        _firstImageAry = [[SearchManager getObject] getIpaDetailContent:ipadetailinfor];

}
#pragma mark - UICollectionView datasource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{

    return _dataArr.count+1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        TopFirstAppGameCell *cell=(TopFirstAppGameCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellFirstIden_top forIndexPath:indexPath];
        cell.tag = 202;
        if (_dataArr != nil&&_dataArr.count>0) {
            NSString*str = [NSString stringWithFormat:@"%ld",(long)(indexPath.row+1)];
            cell.orderLabel.text = str;
            //设置数据
            
            NSDictionary *showCellDic = [_dataArr objectAtIndex:0];
            cell.downLoadSource = HOME_PAGE_RECOMMEND_MY(indexPath.section, indexPath.row);
            [cell setCellData:showCellDic];
            [cell initDownloadButtonState];
            
//            UIImageView *imageView = [[UIImageView alloc] init];
//            [imageView sd_setImageWithURL:[NSURL URLWithString:[_dicTop objectForKey:@"appiphonefirstpreview"]]];
            
//            if (_firstImageAry.count > 0) {
                [cell.backlineView sd_setImageWithURL:[NSURL URLWithString:[_dicTop objectForKey:@"appiphonefirstpreview"]] placeholderImage:[UIImage imageNamed:@"rotationDefault"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (error) {
//                        NSLog(@"error");
//                        CGSize size=CGSizeMake(MainScreen_Width,212*MULTIPLE);
                        
//                        [cell firstimageFrame:size];

                    }else{
                        ;
//                        cell.backlineView.image=nil;
                        cell.backlineView.image = [image getSubImage:CGRectMake(0, (image.size.height-150)/1.5, image.size.width, 250*MULTIPLE)];
//                        [myCollectionView reloadData];
//                        [cell firstimageFrame:image.size];

                    }
                }];
            }
//        }
        
//        cell.backlineView.image
        
        cell.backgroundColor = [UIColor whiteColor];
        return  cell;
    }

       if (indexPath.row==_dataArr.count) {

    _cell_loading = [collectionView dequeueReusableCellWithReuseIdentifier:cellLoadingIden_top forIndexPath:indexPath];
    _cell_loading.identifier = nil;
    
//    NSLog(@"topaa");
    if (self->hasNextData){
        lastCellStyle=CollectionCellRequestStyleLoading;

    }else{
        lastCellStyle=CollectionCellRequestStyleFailed;

    }
           [_cell_loading setStyle:lastCellStyle];
           _cell_loading.hidden=YES;

    [self requestActivitiesData];
    return _cell_loading;
    
       }
    
        PublicCollectionCell*cell=(PublicCollectionCell*)[collectionView dequeueReusableCellWithReuseIdentifier:LISTVIEWCELLS forIndexPath:indexPath];
    cell.tag=202;
        if (_dataArr!=nil) {
            NSString*str=[NSString stringWithFormat:@"%ld",(long)(indexPath.row+1)];
            cell.orderLabel.text=str;

            //设置数据
            
            NSDictionary *showCellDic = [_dataArr objectAtIndex:indexPath.row];
            //设置属性
            cell.downLoadSource = HOME_PAGE_RECOMMEND_MY(indexPath.section, indexPath.row);
            [cell setCellData:showCellDic];
            [cell initDownloadButtonState];

        }
    
        cell.backgroundColor = [UIColor whiteColor];
        return cell;
 
}
#pragma mark - 截取部分图片
- (UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect {
    CGImageRef sourceImageRef = [image CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    return newImage;
}

#pragma mark - UICollectionViewLayoutDelegate

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0) {
        CGSize size = CGSizeMake(collectionView.frame.size.width,212*MULTIPLE);
        return size;
    
    }
    if (indexPath.row<=_dataArr.count-1) {
    CGSize size = CGSizeMake(collectionView.frame.size.width,168/2*MULTIPLE);
        return size;

    }
    CGSize size = CGSizeMake(collectionView.frame.size.width,180/2*MULTIPLE);
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
    if (indexPath.row!=_dataArr.count) {

    PublicCollectionCell *cell = (PublicCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];

        
    NSString *source =[NSString new];
    if (topType==top_app) {
        source=APP_TOTAL_RANKING((long)indexPath.row);
    }else{
        source=GAME_TOTAL_RANKING((long)indexPath.row);
    }
        
        
    if (SHOW_REAL_VIEW_FLAG&&!DIRECTLY_GO_APPSTORE) {
        [self pushToAppDetailViewWithAppInfor:_dataArr[indexPath.row] andSoure:source];
    }else{
        [[NSNotificationCenter  defaultCenter] postNotificationName:OPEN_APPSTORE object:cell.appdigitalid];
    }
    //汇报点击
    [[ReportManage instance] reportAppDetailClick:source contentDic:_dataArr[indexPath.row]];
    
    }
}

#pragma mark - UIScrollViewDelegate
BOOL _deceler_top;
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
    if (scrollView.decelerating) _deceler_top = YES;
    [_cell_loading setStyle:CollectionCellRequestStyleLoading];

}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [_refreshHeader egoRefreshScrollViewDidEndDragging:scrollView];
    if (!decelerate && !_deceler_top) [self exposure]; _deceler_top = NO;
    couldPullRefreshFlag=YES;
    if (!hasNextData&&!decelerate && !_deceler_top) {
        [_cell_loading setStyle:CollectionCellRequestStyleFailed];
        
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (!_deceler_top) {
        _deceler_top = YES;
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
        [self initTopRequest];

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
    NSArray *cellArray = [myCollectionView visibleCells];
    
    NSMutableArray *appIds = [NSMutableArray array];
    NSMutableArray *digitalIds = [NSMutableArray array];
    
    for (UICollectionViewCell *obj in cellArray) {
        if (obj.tag == 202) {
            PublicCollectionCell *cell = (PublicCollectionCell*)obj;
            [appIds addObject:cell.appID];
            [digitalIds addObject:cell.appdigitalid];
        }
    }
    NSString *source =[NSString new];
    if (topType==top_app) {
        source=APP_TOTAL_RANKING((long)-1);
    }else{
        source=GAME_TOTAL_RANKING((long)-1);
    }
    [[ReportManage instance] reportAppBaoGuang:source appids:appIds digitalIds:digitalIds];
}
#pragma mark - 推详情
- (void)pushToAppDetailViewWithAppInfor:(NSDictionary *)inforDic andSoure:(NSString *)source{
    [detailVC setAppSoure:source];
    [detailVC beginPrepareAppContent:inforDic];
    MyNavigationController *nav = (MyNavigationController *)self.parentVC.navigationController;
    [nav prepairScreenShot:self.parentVC.navigationController];
    [self.parentVC.navigationController pushViewController:detailVC animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
