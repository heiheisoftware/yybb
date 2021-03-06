//
//  AppTableViewController.m
//  browser
//
//  Created by liguiyang on 14-6-10.
//
//

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag
#endif

#import "AppTableViewController.h"
#import "SearchResultCell.h"
#import "SettingPlistConfig.h"
#import "AppStatusManage.h"


@interface AppTableViewController ()
@property (nonatomic, strong) NSArray *appList;
@property (nonatomic, strong) NSString *appFromSource; // lunbo/list

@end

@implementation AppTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}


#pragma mark - Utility

-(void)reloadAppTableView:(NSArray *)appArray withFromSource:(NSString *)fromSource
{
    self.appList = appArray;
    self.appFromSource = fromSource;
    [self.tableView reloadData];
}

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    if (IOS7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.tableView.scrollEnabled = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source and delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _appList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"downloadFreeFlowCell";
    SearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[SearchResultCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.identifier = CellIdentifier;
    
    NSDictionary *appInfor = _appList[indexPath.row];
    [cell initCellwithInfor:appInfor];
    cell.source = _appFromSource;
    
    //cell 内实现下载按钮状态改变
    [cell initDownloadButtonState];
    
    
    //图片显示
    [cell.iconImageView sd_setImageWithURL:[NSURL URLWithString:[appInfor objectForKey:@"appiconurl"]] placeholderImage:_StaticImage.icon_60x60];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(appTableView:didSelectRowAtIndexPath:)]) {
        [self.delegate appTableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

#pragma mark - Life Cycle

-(void)dealloc
{
    self.appList = nil;
    self.appFromSource = nil;
}

@end
