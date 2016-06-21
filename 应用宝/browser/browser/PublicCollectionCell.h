//
//  PublicCollectionCell.h
//  Mymenu
//
//  Created by mingzhi on 14/11/22.
//  Copyright (c) 2014年 mingzhi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CollectionCells.h"

@interface CollectionViewCellButton_my : UIButton
@property (nonatomic, strong) NSIndexPath * buttonIndexPath;
@property (nonatomic, assign) BOOL down;
@end

@interface CollectionViewCellImageView_my : UIImageView
@property (nonatomic, strong) CAShapeLayer * maskLayer;
@property (nonatomic, assign) CGFloat   maskCornerRadius;
@property (nonatomic, strong) NSURL * url;
@end

@interface PublicCollectionCell : UICollectionViewCell
{
//    UIImageView *lineView1;
    UIImageView *lineView2;
}

//属性
@property (nonatomic, retain) NSDictionary *cellDataDic;
@property (nonatomic, retain) NSString *appdigitalid;
@property (nonatomic, retain) NSString *appID;
@property (nonatomic, retain) NSString *plist;
@property (nonatomic , retain) NSString *downLoadSource;//来源
@property (nonatomic, retain) NSString *installtype;

//UI
@property (nonatomic, strong) CollectionViewCellImageView_my * iconImageView;
@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) UILabel * subLabel;
@property (nonatomic, strong) UIImageView *downloadIconImageView;//下载数图
@property (nonatomic, strong) UIImageView * bottomlineView;

@property (nonatomic, strong) UILabel * priceLabel;
@property (nonatomic, strong) CollectionViewCellButton_my * downButton;
@property (nonatomic, strong) UILabel * sizeLabel;
@property (nonatomic, strong) UILabel * orderLabel;
@property (nonatomic, strong) UIButton *downLoadBtn;

- (void)setBottomLineLong:(BOOL)bl;
- (void)setCellData:(NSDictionary *)showCellDic;
- (void)initDownloadButtonState; // 设置按钮状态

-(void)setDownNumber:(NSString *)downNumber size:(NSString *)sizeStr;
@end
