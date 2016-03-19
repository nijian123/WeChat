//
//  WCEditCardViewController.h
//  WeChat
//
//  Created by 倪建 on 16/3/19.
//  Copyright © 2016年 倪建. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WCEditCardViewController;
@protocol WCEditCardViewControllerDelegate <NSObject>

- (void)editCardViewController:(WCEditCardViewController *)editVc didFinishedSave:(id)sender;

@end





@interface WCEditCardViewController : UITableViewController


/**
 *  上一个控制器（个人信息控制器）传入的cell
 */
@property (nonatomic,strong)UITableViewCell *cell;

@property (nonatomic,weak) id<WCEditCardViewControllerDelegate> delegate;

@end



