//
//  MoreViewController.m
//  browser
//
//  Created by niu_o0 on 14-5-27.
//
//

#import "MoreViewController.h"
#import "CollectionViewCell.h"
#import "CollectionViewLayout.h"
#import "SearchManager.h"
#import "MarketServerManage.h"
#import "DownloadStatus.h"
#import "CollectionViewBack.h"
#import "SearchResult_DetailViewController.h"
#import "DetailViewController.h"
#import "FindDetailViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "AlertLabel.h"

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag
#endif

#define IDEN_REFRESH_NOCACHE @"JX_Detail_refresh_NoCache_ID"

#define NECESSARY_ID @"696"
//static NSString * MORECELL = @"morecell";

static NSInteger Game_index = 1, App_index = 1, Topic_index = 1, Activity_index = 1, Necessary_index = 1, Free_App_index = 1,Free_Game_index = 1;


@interface MoreViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MarketServerDelegate, SearchManagerDelegate, EGORefreshTableHeaderDelegate>{
    UICollectionView * _collectionView;
    CollectionViewLayout * layout;
    _CHOICE __choice;
    MarketServerManage * _dataServer;
    NSMutableArray * _dataArray;
    BOOL isHave;
    BOOL isRequest;
    BOOL requestFail;
    SearchResult_DetailViewController * _detail;
    DetailViewController * _topic;
    //FindDetailViewController * _activ;
    EGORefreshTableHeaderView * _refreshView;
    
    CollectionViewBack * _backView;
    AlertLabel *alertLabel;
    
    UIButton *appButton;
    UIButton *gameButton;
}

@end

@implementation MoreViewController

- (void)dealloc{
    _collectionView.delegate = nil;
    _collectionView.dataSource = nil;
    [_dataServer removeListener:self];
    _refreshView.egoDelegate = nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        _dataServer = [MarketServerManage new];
        
        [_dataServer addListener:self];
        
        __choice = NSNotFound;
        
        
        _detail = [SearchResult_DetailViewController new];
        _topic = [DetailViewController defaults];
        
        _dataArray = [NSMutableArray new];
//        _activ = [FindDetailViewController new];
    }
    return self;
}

- (void)setChoiceView:(_CHOICE)_choice{
    
    __choice = _choice;
    
    [self request:[NSNumber numberWithInteger:_choice]];

    
    self.navigationItem.title = [[_StaticImage titleArray] objectAtIndex:_choice];
    [self setBackView];
}

- (void)clearCache{
    
    [_collectionView setContentOffset:CGPointZero animated:NO];
    
    [_dataArray removeAllObjects];
    
    isHave = YES;
    
    isLoading = NO;
    
    requestFail = NO;
    
    [_collectionView reloadData];
    
    
    
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

//请求精选内的数据
- (void)request:(NSNumber *)number{
    
    _CHOICE _choice = [number integerValue];
    
    switch (_choice) {
            
        case GAME:
            [_dataServer getGoodGameAppList:CLASSIFY_GAME pageCount:1 userData:nil];
            Game_index = 1;
            break;
            
        case APP:
            [_dataServer getGoodGameAppList:CLASSIFY_APP pageCount:1 userData:nil];
            App_index = 1;
            break;
            
        case ACTIVITY:
            [_dataServer getDiscoverList:1 type:DISCOVER_ACTIVITY_LIST userData:nil];
            Activity_index = 1;
            break;
            
        case TOPIC:
            [_dataServer getSpecialList:1 userData:nil];
            Topic_index = 1;
            break;
        case FREE_APP:
            [_dataServer requestFreeAppOrGame:1 type:CLASSIFY_APP userData:CLASSIFY_APP isUseCache:NO];
            Free_App_index = 1;
            break;
        case FREE_GAME:
            [_dataServer requestFreeAppOrGame:1 type:CLASSIFY_GAME userData:CLASSIFY_GAME isUseCache:NO];
            Free_Game_index = 1;
            break;
        case NECESSARY:
            [_dataServer requestInstallednecessary:NO userData:nil];
            Necessary_index = 1;
            break;
        case GIFT:
            [_dataServer requestPackageWebUrl:nil];
            break;
        default:
            break;
    }
}

- (void)pullRefreshRequest:(NSNumber *)number
{
    _CHOICE _choice = [number integerValue];
    
    switch (_choice) {
            
        case GAME:
            [_dataServer requestGoodGameAppList:CLASSIFY_GAME pageCount:1 userData:IDEN_REFRESH_NOCACHE];
            break;
            
        case APP:
            [_dataServer requestGoodGameAppList:CLASSIFY_APP pageCount:1 userData:IDEN_REFRESH_NOCACHE];
            break;
            
        case ACTIVITY:
            [_dataServer requestDiscoverList:1 type:DISCOVER_ACTIVITY_LIST userData:IDEN_REFRESH_NOCACHE];
            break;
            
        case TOPIC:
            [_dataServer requestSpecialList:1 userData:IDEN_REFRESH_NOCACHE];
            break;
            
        case FREE_APP:
            [_dataServer requestFreeAppOrGame:1 type:@"app" userData:IDEN_REFRESH_NOCACHE isUseCache:NO];
            Free_App_index = 1;
            break;
        case FREE_GAME:
            [_dataServer requestFreeAppOrGame:1 type:@"game" userData:IDEN_REFRESH_NOCACHE isUseCache:NO];
            Free_Game_index = 1;
            break;
        case NECESSARY:
            [_dataServer requestInstallednecessary:NO userData:IDEN_REFRESH_NOCACHE];
            Necessary_index = 1;
            break;
        case GIFT:
            [_dataServer requestPackageWebUrl:nil];
            break;
        default:
            break;
    }
}

- (void)requestMore{
    
    switch (__choice) {
        case GAME:
            [_dataServer getGoodGameAppList:CLASSIFY_GAME pageCount:Game_index userData:nil];
            break;
            
        case APP:
            [_dataServer getGoodGameAppList:CLASSIFY_APP pageCount:App_index userData:nil];
            break;
            
        case ACTIVITY:
            [_dataServer getDiscoverList:Activity_index type:DISCOVER_ACTIVITY_LIST userData:nil];
            break;
            
        case TOPIC:
            [_dataServer getSpecialList:Topic_index userData:nil];
            break;
        case FREE_APP:
            [_dataServer requestFreeAppOrGame:Free_App_index type:@"app" userData:nil isUseCache:NO];
            Free_App_index = 1;
            break;
        case FREE_GAME:
            [_dataServer requestFreeAppOrGame:Free_Game_index type:@"game" userData:nil isUseCache:NO];
            Free_Game_index = 1;
            break;
//        case NECESSARY:
//            [_dataServer requestInstallednecessary:NO userData:nil];
//            Necessary_index = 1;
//            break;
//        case GIFT:
//            [_dataServer requestPackageWebUrl:nil];
//            break;
        default:
            break;
    }
}

- (CGSize) collectionViewItemSize:(_CHOICE)_choice{
    CGSize size = CGSizeZero;
    switch (_choice) {
        case TOPIC:
            size = CGSizeMake(self.view.bounds.size.width, 170/2);
            break;
        case ACTIVITY:
            size = CGSizeMake(self.view.bounds.size.width, 93);
            break;
        default:
            size = CGSizeMake(self.view.bounds.size.width, 176/2);
            break;
    }
    return size;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    addNavgationBarBackButton(self, back)
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    layout = [CollectionViewLayout new];
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor clearColor];
    [_collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:__STYLE_ACTIVITY];
    [_collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:__STYLE_RECOMMEND];
    [_collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:__STYLE_MORE_TOPIC];
    
    [_collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:__STYLE_REQUESTMORE];
    
    [self.view addSubview:_collectionView];
    
    _refreshView = [[EGORefreshTableHeaderView alloc] init];
    _refreshView.egoDelegate = self;
    [_collectionView addSubview:_refreshView];
    
    _backView = [CollectionViewBack new];
    [_collectionView addSubview:_backView];
    
    __unsafe_unretained typeof(self) mySelf = self;
    [_backView setClickActionWithBlock:^{
        [mySelf requestFailed:NO];
        [mySelf performSelector:@selector(request:) withObject:[NSNumber numberWithInteger:mySelf->__choice] afterDelay:delayTime];
    }];
    
    alertLabel = [[AlertLabel alloc] init];
    [self.view addSubview:alertLabel];
    
    [self setBackView];
    
    //右滑返回手势
//    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(back)];
//    swipe.direction = UISwipeGestureRecognizerDirectionRight;
//    [self.view addGestureRecognizer:swipe];
    
}

- (void)requestFailed:(BOOL)fail{
    requestFail = fail;
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    _collectionView.frame = self.view.bounds;
    _refreshView.inset = _collectionView.contentInset;
    CGFloat startY = IOS7 ? 64 : 0;
    _refreshView.frame = CGRectMake(0, -_collectionView.bounds.size.height-_collectionView.contentInset.top+startY, _collectionView.bounds.size.width, _collectionView.bounds.size.height);
    _backView.frame = _collectionView.bounds;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
   
    if (__choice != FREE_APP&&__choice != FREE_GAME) {
        return;
    }
    appButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    appButton.frame = CGRectMake(100, 0, 100, 44);
    [appButton setTitle:@"应用" forState:UIControlStateNormal];
    [appButton addTarget:self action:@selector(showFree_app) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:appButton];
    
    gameButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    gameButton.frame = CGRectMake(200, 0, 100, 44);
    [gameButton setTitle:@"游戏" forState:UIControlStateNormal];
    [gameButton addTarget:self action:@selector(showFree_game) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:gameButton];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [appButton removeFromSuperview];
    [gameButton removeFromSuperview];
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (!self.navigationController) [self clearCache];
}


- (void)setBackView{
    
    if (!_dataArray.count) {
        if (requestFail){
            [_backView setStatus:Failed];
        }else{
            [_backView setStatus:Loading];
        }
        _collectionView.scrollEnabled = NO;
    }else{
        [_backView setStatus:Hidden];
        _collectionView.scrollEnabled = YES;
        if (isLoading) [self didRequestData];
    }
}

-(void)showDownRefreshFailedLabel
{
    CGFloat originY = (IOS7)?64:0;
    [alertLabel startAnimationFromOriginY:originY];
}

#pragma mark - 导航上游戏/应用按钮
- (void)showFree_app{
    [self setChoiceView:FREE_APP];
}
- (void)showFree_game{
    [self setChoiceView:FREE_GAME];
}


#pragma mark - 新增功能区_免费
- (void)requestFreeAppOrGameSucess:(NSDictionary*)dataDic page:(int)page type:(NSString*)type userData:(id)userData{
    if (![_StaticImage checkAppList:dataDic]){
        [self requestFreeAppOrGameFail:1 type:nil userData:nil];
        return;
    }
    
    if ([[[dataDic objectForKey:@"flag"] objectForKey:@"dataend"] isEqualToString:@"n"]) {
        isHave = NO;
    }else{
        isHave = YES;
    }
    
    if (self->isLoading) {
        [self didRequestData];
    }
    
    if ( IS_NSARRAY([dataDic objectForKey:@"data"]) ){
        if ([[dataDic objectForKey:@"data"] count] > 0) {
            if ([userData isEqualToString:IDEN_REFRESH_NOCACHE]){
                // 下拉刷新成功、清理数据
                if ([type isEqualToString:CLASSIFY_GAME]) {
                    Game_index = 1;
                }else if ([type isEqualToString:CLASSIFY_APP]){
                    App_index = 1;
                }
                [_dataArray removeAllObjects];
            }
            [_dataArray addObjectsFromArray:[dataDic objectForKey:@"data"]];
            
            
            if ([type isEqualToString:CLASSIFY_GAME]) {
                Game_index ++;
            }else if ([type isEqualToString:CLASSIFY_APP]){
                App_index ++;
            }
        }
    }
    
    [self setBackView];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [_collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    [CATransaction commit];
    
    isRequest = NO;
    
}
- (void)requestFreeAppOrGameFail:(int)page type:(NSString*)type userData:(id)userData{
    isShow = NO;
    isRequest = NO;
    requestFail = YES;
    [self setBackView];
    
    // 下拉刷新失败
    if ([userData isEqualToString:IDEN_REFRESH_NOCACHE]) {
        [self showDownRefreshFailedLabel];
    }
}

#pragma mark - 新增功能区_必备
- (void)requestInstallednecessarySucess:(NSDictionary*)dataDic userData:(id)userData{
    if (![_StaticImage checkAppList:dataDic]){
        [self requestInstallednecessaryFail:userData];
        return;
    }
    
//    if ([[[dataDic objectForKey:@"flag"] objectForKey:@"dataend"] isEqualToString:@"n"]) {
//        isHave = NO;
//    }else{
//        isHave = YES;
//    }
    isHave = NO;
    
    if (self->isLoading) {
        [self didRequestData];
    }
    
    if ( IS_NSARRAY([dataDic objectForKey:@"data"]) ){
        if ([[dataDic objectForKey:@"data"] count] > 0) {
            if ([userData isEqualToString:IDEN_REFRESH_NOCACHE]){
                // 下拉刷新成功、清理数据
                [_dataArray removeAllObjects];
            }
            [_dataArray addObjectsFromArray:[dataDic objectForKey:@"data"]  ];
            
        }
    }
    
    [self setBackView];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [_collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    [CATransaction commit];
    
    isRequest = NO;
}
- (void)requestInstallednecessaryFail:(id)userData{
    isShow = NO;
    isRequest = NO;
    requestFail = YES;
    [self setBackView];
    
    // 下拉刷新失败
    if ([userData isEqualToString:IDEN_REFRESH_NOCACHE]) {
        [self showDownRefreshFailedLabel];
    }
}



#pragma mark - 优秀 游戏 应用

- (void)goodGameAppListRequestSucess:(NSDictionary *)dataDic type:(NSString *)type pageCount:(int)pageCount userData:(id)userData{
    
    if (![_StaticImage checkAppList:dataDic]){
        [self goodGameAppListRequestFail:type pageCount:pageCount userData:userData];
        return;
    }
    
    if ([[[dataDic objectForKey:@"flag"] objectForKey:@"dataend"] isEqualToString:@"n"]) {
        isHave = NO;
    }else{
        isHave = YES;
    }
    
    if (self->isLoading) {
        [self didRequestData];
    }
    
    if ( IS_NSARRAY([dataDic objectForKey:@"data"]) ){
        if ([[dataDic objectForKey:@"data"] count] > 0) {
            if ([userData isEqualToString:IDEN_REFRESH_NOCACHE]){
                // 下拉刷新成功、清理数据
                if ([type isEqualToString:CLASSIFY_GAME]) {
                    Game_index = 1;
                }else if ([type isEqualToString:CLASSIFY_APP]){
                    App_index = 1;
                }
                [_dataArray removeAllObjects];
            }
            [_dataArray addObjectsFromArray:[dataDic objectForKey:@"data"]];
            
            
            if ([type isEqualToString:CLASSIFY_GAME]) {
                Game_index ++;
            }else if ([type isEqualToString:CLASSIFY_APP]){
                App_index ++;
            }
        }
    }
    
    [self setBackView];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [_collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    [CATransaction commit];
    
    isRequest = NO;
    
}

- (void)goodGameAppListRequestFail:(NSString *)type pageCount:(int)pageCount userData:(id)userData{
    
    isShow = NO;
//    [_collectionView reloadData];
    isRequest = NO;
    requestFail = YES;
    [self setBackView];
    
    // 下拉刷新失败
    if ([userData isEqualToString:IDEN_REFRESH_NOCACHE]) {
        [self showDownRefreshFailedLabel];
    }
   }

#pragma mark - 专题

- (void)specialListRequestSucess:(NSDictionary *)dataDic pageCount:(int)pageCount userData:(id)userData{
    
    NSDictionary * dic = [dataDic getNSDictionaryObjectForKey:@"flag"];
    if (!dic) return;
    
    if (!([_StaticImage checkSpecial:dataDic] && [_StaticImage checkFlag:dic])){
        [self specialListRequestFail:pageCount userData:userData];
        return;
    }
    
    
    if ([[dic objectForKey:@"dataend"] isEqualToString:@"n"]) {
        isHave = NO;
    }else{
        isHave = YES;
    }
    
    if (self->isLoading) {
        [self didRequestData];
    }
    
    NSArray * obj = [dataDic objectForKey:@"data"];
    if (IS_NSARRAY(obj) && obj.count > 0)
    {
        if ([userData isEqualToString:IDEN_REFRESH_NOCACHE]){
            // 下拉刷新成功、清理数据
            Topic_index = 1;
            [_dataArray removeAllObjects];
        }
        [_dataArray addObjectsFromArray:[dataDic objectForKey:@"data"]];
        
        Topic_index ++;
    }
    
    [self setBackView];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [_collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    [CATransaction commit];
    

    isRequest = NO;
    
    
}

- (void)specialListRequestFail:(int)pageCount userData:(id)userData{
    
    isShow = NO;
    [_collectionView reloadData];
    isRequest = NO;
    requestFail = YES;
    [self setBackView];
    
    // 下拉刷新失败
    if ([userData isEqualToString:IDEN_REFRESH_NOCACHE]) {
        [self showDownRefreshFailedLabel];
    }
}

#pragma mark - 专题详情
//专题应用请求成功
- (void)specialAppRequestSucess:(NSDictionary*)dataDic specialID:(NSString*)specialID pageCount:(int)pageCount userData:(id)userData{
    NSDictionary * dic = [dataDic getNSDictionaryObjectForKey:@"flag"];
    if (!dic) return;
    
    if (!([_StaticImage checkAppList:dataDic])){
        [self specialListRequestFail:pageCount userData:userData];
        return;
    }
    
    
    if ([[dic objectForKey:@"dataend"] isEqualToString:@"n"]) {
        isHave = NO;
    }else{
        isHave = YES;
    }
    
    if (self->isLoading) {
        [self didRequestData];
    }
    
    NSArray * obj = [dataDic objectForKey:@"data"];
    if (IS_NSARRAY(obj) && obj.count > 0)
    {
        if ([userData isEqualToString:NECESSARY_ID]){
            // 下拉刷新成功、清理数据
            Necessary_index = 1;
            [_dataArray removeAllObjects];
        }
        [_dataArray addObjectsFromArray:[dataDic objectForKey:@"data"]];
        
        Necessary_index ++;
    }
    
    [self setBackView];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [_collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    [CATransaction commit];
    
    
    isRequest = NO;
}
//专题详情请求失败
- (void)specialInfoRequestFail:(int)specialID userData:(id)userData{
    
}
#pragma mark - 活动

- (void)discoverListRequestSucess:(NSDictionary *)dataDic pageCount:(int)pageCount type:(NSString *)type userData:(id)userData{
    
    NSDictionary * dic = [dataDic getNSDictionaryObjectForKey:@"flag"];
    if (!dic) return;
    
    if (!([_StaticImage checkActivity:dataDic] && [_StaticImage checkFlag:dic])){
        [self specialListRequestFail:pageCount userData:userData];
        return;
    }
            
    if ([[dic objectForKey:@"dataend"] isEqualToString:@"n"]) {
        isHave = NO;
    }else{
        isHave = YES;
    }
    
    if (self->isLoading) {
        [self didRequestData];
    }
    
    NSArray * obj = [dataDic objectForKey:@"data"];
    if (IS_NSARRAY(obj) && obj.count)
    {
        if ([userData isEqualToString:IDEN_REFRESH_NOCACHE]){
            // 下拉刷新成功、清理数据
            Activity_index = 1;
            [_dataArray removeAllObjects];
        }
        [_dataArray addObjectsFromArray:[dataDic objectForKey:@"data"]];
        
        Activity_index ++;
    }
    
    [self setBackView];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [_collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    [CATransaction commit];
    
    isRequest = NO;
}

- (void)discoverListRequestFail:(int)pageCount type:(NSString *)type userData:(id)userData{
    isShow = NO;
//    [_collectionView reloadData];
    isRequest = NO;
    requestFail = YES;
    [self setBackView];
    
    // 下拉刷新失败
    if ([userData isEqualToString:IDEN_REFRESH_NOCACHE]) {
        [self showDownRefreshFailedLabel];
    }
}

#pragma mark - collectionview delegate


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (!_dataArray) return 0;
    if (isHave)
    return _dataArray.count+1;
    return _dataArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == _dataArray.count) return REQUESTCELLSIZE;
    return [self collectionViewItemSize:__choice];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CollectionViewCell * cell = nil;
    
    if (indexPath.row == _dataArray.count) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:__STYLE_REQUESTMORE forIndexPath:indexPath];
        if (isShow) {
            [cell.juhua startGif];
        }else{
            [cell.juhua stopGif];
        }
    }else{
        if (!_dataArray.count) return cell;
        
        if (__choice == ACTIVITY) {
            
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:__STYLE_ACTIVITY forIndexPath:indexPath];
            cell.iconImageView.url = [NSURL URLWithString:[[_dataArray objectAtIndex:indexPath.row] objectForKey:PIC_URL]];
            cell.nameLabel.text = [[_dataArray objectAtIndex:indexPath.row] objectForKey:TITLE];
            cell.subLabel.text = [[_dataArray objectAtIndex:indexPath.row] objectForKey:DATE];
            [cell.downButton setTitle:[DownloadStatus changeValue:[[_dataArray objectAtIndex:indexPath.row] objectForKey:VIEW_COUNT] WithValueClass:Value_Count] forState:UIControlStateNormal];
            cell.baoguang = [[_dataArray objectAtIndex:indexPath.row] objectForKey:@"id"];
            
            [cell layoutSubviews];
            
        }else if (__choice == TOPIC){
            
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:__STYLE_MORE_TOPIC forIndexPath:indexPath];
            cell.iconImageView.url = [NSURL URLWithString:[[_dataArray objectAtIndex:indexPath.row] objectForKey:SPECIAL_PIC_URL]];
            cell.nameLabel.text = [[_dataArray objectAtIndex:indexPath.row] objectForKey:SPECIALNAME];
            cell.subLabel.text = [[_dataArray objectAtIndex:indexPath.row] objectForKey:SPECIALCONTENT];
            cell.baoguang = [[_dataArray objectAtIndex:indexPath.row] objectForKey:SPECIALID];
            
        }else{
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:__STYLE_RECOMMEND forIndexPath:indexPath];
            
            cell.iconImageView.url = [NSURL URLWithString:[[_dataArray objectAtIndex:indexPath.row] objectForKey:APPICON]];
            cell.nameLabel.text = [[_dataArray objectAtIndex:indexPath.row] objectForKey:APPNAME];
            cell.subLabel.text = [NSString stringWithFormat:@"%@  |  %@",[[_dataArray objectAtIndex:indexPath.row] objectForKey:APPCATEGROY],[DownloadStatus changeValue:[[_dataArray objectAtIndex:indexPath.row] objectForKey:APPSIZE] WithValueClass:Value_MB]];      //@"动作游戏  |  694.13M";
            [cell.zanButton setTitle:[DownloadStatus changeValue:[[_dataArray objectAtIndex:indexPath.row] objectForKey:APPREPUTATION] WithValueClass:Value_Count] forState:UIControlStateNormal];
            [cell.downButton setTitle:[DownloadStatus changeValue:[[_dataArray objectAtIndex:indexPath.row] objectForKey:APPDOWNCOUNT] WithValueClass:Value_Count] forState:UIControlStateNormal];
            cell.baoguang = [[_dataArray objectAtIndex:indexPath.row] objectForKey:APPID];
            
            NSIndexPath * __indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:__choice];
            cell.downloadButton.buttonIndexPath = __indexPath;
            [DownloadStatus checkButton:cell.downloadButton
                            WithAppInfo:[_dataArray objectAtIndex:indexPath.row]];
        }
    }
    
    [cell.iconImageView sd_setImageWithURL:cell.iconImageView.url placeholderImage:[_StaticImage collectionViewItemImage:__choice]];
    
    
    return cell;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0.0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (__choice == TOPIC) {
        [_topic setDetailInfo:[_dataArray objectAtIndex:indexPath.row] andStyle:_DETAIL_STYLE_TOPIC];
        [self.navigationController pushViewController:_topic animated:YES];
    }else if (__choice == ACTIVITY){
        
        if ([[[_dataArray objectAtIndex:indexPath.row] objectForKey:@"content_url_open_type"] integerValue] == 1) {
            FindDetailViewController * _activeViewController = [FindDetailViewController new];
            [_activeViewController reloadActivityDetailVC:[_dataArray objectAtIndex:indexPath.row]];
            [self.navigationController pushViewController:_activeViewController animated:YES];
        }else if ([[[_dataArray objectAtIndex:indexPath.row] objectForKey:@"content_url_open_type"] integerValue] == 2){
            NSURL * url = [NSURL URLWithString:[[_dataArray objectAtIndex:indexPath.row] objectForKey:@"content"]];
            [[UIApplication sharedApplication] openURL:url];
        }
        
    }else{
    
    if (_dataArray.count == indexPath.row) return;
    [_detail setAppSoure:[DownloadStatus dlfrom:[NSIndexPath indexPathForRow:indexPath.row inSection:__choice]]];
    [_detail beginPrepareAppContent:[_dataArray objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:_detail animated:YES];
        
    [[ReportManage instance] ReportAppDetailClick:[DownloadStatus dlfrom:[NSIndexPath indexPathForRow:indexPath.row inSection:__choice]] appid:[[_dataArray objectAtIndex:indexPath.row] objectForKey:APPID]];
    }
}

#pragma mark - 获取更多

static BOOL isShow;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [_refreshView egoRefreshScrollViewDidScroll:scrollView];
    if (isRequest) return;
    if (!_dataArray.count) return;
    if (!isHave) return;
    if (isLoading == YES) return;
    
    if (scrollView.contentOffset.y + _collectionView.bounds.size.height + 49 >= [_collectionView.collectionViewLayout collectionViewContentSize].height) {
        
        isRequest = YES;
        isShow = YES;
        [_collectionView reloadData];
        [self performSelector:@selector(requestMore) withObject:nil afterDelay:delayTime];
    }
    
}

#pragma mark - 下拉刷新

static bool _decler = false;
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (scrollView.decelerating) _decler = true;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    if (!decelerate && _decler == false) [self baoguang]; _decler = false;
     [_refreshView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self baoguang];
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (isLoading) {
        return ;
    }
    if (scrollView.contentOffset.y<-(_collectionView.contentInset.top+65)) {
        *targetContentOffset = scrollView.contentOffset;
    }
}

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view{
    self->isLoading = YES;
    [self performSelector:@selector(pullRefreshRequest:) withObject:[NSNumber numberWithInteger:__choice] afterDelay:delayTime];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view{
    return self->isLoading;
}

- (void)didRequestData{
    self->isLoading = NO;
    [_refreshView egoRefreshScrollViewDataSourceDidFinishedLoading:_collectionView];
}

#pragma mark - 下载回调

- (void)_reload{
    [_collectionView reloadData];
}

- (void)baoguang{
    _baoguang(_collectionView, [NSIndexPath indexPathForRow:-1 inSection:__choice])
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
