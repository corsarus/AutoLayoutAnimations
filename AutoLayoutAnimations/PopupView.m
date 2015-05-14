//
//  PopupView.m
//


#import "PopupView.h"

CGFloat const contentViewTopOffset = 40.0;

@interface PopupView ()

@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, weak) UIView *presentingView;
@property (nonatomic, strong) UIView *dimmedView;

@property (nonatomic, strong) NSLayoutConstraint *contentViewHeightConstraint;

@end

@implementation PopupView

- (instancetype)initWithContentView:(UIView *)contentView
{
    if (self = [super init]) {
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundColor = [UIColor whiteColor];
    
        self.contentView = contentView;
        self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        // Important: reveals the content view progressively during the animation
        self.contentView.clipsToBounds = YES;
    
        return self;
    
}
    
    return nil;
}

#pragma mark - Accessors

- (UIView *)dimmedView
{
    if (!_dimmedView) {
        
        _dimmedView = [[UIView alloc] init];
        _dimmedView.translatesAutoresizingMaskIntoConstraints = NO;
        _dimmedView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6];
        
        [_dimmedView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)]];
    }
    
    return _dimmedView;
}

#pragma mark - Auto Layout

- (void)updateConstraints
{
    // The content view initial height is zero
    self.contentViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                    attribute:NSLayoutAttributeHeight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:nil
                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                   multiplier:1.0
                                                                     constant:0.0];
    
    [self.contentView addConstraint:self.contentViewHeightConstraint];
    
    // Attach the content view borders to the container view borders
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[contentView]-|"
                                                                 options:NSLayoutFormatAlignAllCenterY
                                                                 metrics:nil
                                                                   views:@{@"contentView": self.contentView}]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|"
                                                                 options:NSLayoutFormatAlignAllCenterX
                                                                 metrics:nil
                                                                   views:@{@"contentView": self.contentView}]];
    

    // Center the container view in the dimmed view
    [self.dimmedView addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                                    attribute:NSLayoutAttributeCenterY
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.dimmedView
                                                                    attribute:NSLayoutAttributeCenterY
                                                                   multiplier:1.0
                                                                     constant:0.0]];
    [self.dimmedView addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                                    attribute:NSLayoutAttributeCenterX
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.dimmedView
                                                                    attribute:NSLayoutAttributeCenterX
                                                                   multiplier:1.0
                                                                     constant:0.0]];
    
    // Attach the dimmed view borders to the presenting view borders
    [self.presentingView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[dimmedView]|"
                                                                 options:NSLayoutFormatAlignAllCenterY
                                                                 metrics:nil
                                                                   views:@{@"dimmedView": self.dimmedView}]];
    
    [self.presentingView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[dimmedView]|"
                                                                 options:NSLayoutFormatAlignAllCenterX
                                                                 metrics:nil
                                                                   views:@{@"dimmedView": self.dimmedView}]];
    
    [super updateConstraints];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // For multi-line UILabel content views, set the maximum width to 3/4 of the presenting view width
    if ([self.contentView isKindOfClass:NSClassFromString(@"UILabel")]) {
        UILabel *contentViewLabel = (UILabel *)self.contentView;
        contentViewLabel.preferredMaxLayoutWidth = self.presentingView.frame.size.width * 0.75;
    }
    
    [super layoutSubviews];
}


- (void)setupViewHierarchy
{
    [self.presentingView addSubview:self.dimmedView];
    
    [self.dimmedView addSubview:self];
    
    [self addSubview:self.contentView];
}

#pragma mark - Presenting and dismissing

- (void)showInView:(UIView *)parentView
{
    self.presentingView = parentView;
    [self setupViewHierarchy];
    
    // Set the Auto Layout constraints (calls the -updateConstraints method)
    [self setNeedsUpdateConstraints];
    
    // Trigger a layout pass to set the initial frames for the view hierarchy
    [UIView animateWithDuration:0.0
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         [self layoutIfNeeded];
                     }
                     completion:^(BOOL finished){
                         
                         // Update the constraint to match the real height of the content view
                         self.contentViewHeightConstraint.constant = [self.contentView intrinsicContentSize].height;
                         
                         // Animate the constraint change
                         [UIView animateWithDuration:0.8
                                               delay:0.0
                              usingSpringWithDamping:0.4
                               initialSpringVelocity:0.0
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              
                                              // Trigger a second layout pass to update the view frames
                                              [self layoutIfNeeded];
                                              
                                          }
                                          completion:nil];
                     }];
}

- (void)hide
{
    // Increase the height of the content view to create a spring effect
    self.contentViewHeightConstraint.constant *= 1.2;
    
    // Trigger a layout pass to animate the content view to the increased height
    [UIView animateWithDuration:0.1
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         [self layoutIfNeeded];
                         
                     }
                     completion:^(BOOL finished) {
                         
                         // Update the constraint to match the real height of the content view
                         self.contentViewHeightConstraint.constant = 0.0;
                         
                         // Trigger a second layout pass to animate the content view to a height of zero
                         [UIView animateWithDuration:0.2
                                               delay:0.0
                                             options:UIViewAnimationOptionCurveLinear
                                          animations:^{
                                              
                                              self.dimmedView.alpha = 0.0;
                                              [self layoutIfNeeded];
                                              
                                          }
                                          completion:^(BOOL finished) {
                                              
                                              [self.dimmedView removeFromSuperview];
                                              
                                          }];
                     }];
    

}

@end
