//
//  PopupView.h
//

#import <UIKit/UIKit.h>

@protocol PopupViewDelegate <NSObject>

@optional

- (void)didLayoutContentView;

@end

@interface PopupView : UIView

@property (nonatomic, weak) id<PopupViewDelegate> delegate;

- (instancetype)initWithContentView:(UIView *)contentView;

- (void)showInView:(UIView *)parentView;
- (void)hide;

@end
