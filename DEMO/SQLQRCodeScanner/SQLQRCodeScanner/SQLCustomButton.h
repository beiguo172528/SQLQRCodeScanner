
#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,SQLCustomButtonType) {
    SQLCustomButtonLeftImageType,//左图标，右文字
    SQLCustomButtonTopImageType,//上图标，下文字
    SQLCustomButtonRightImageType//右图标，左文字
};



@interface SQLCustomButton : UIView


@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, assign) BOOL isShowSelectBackgroudColor;//是否展示点击效果

@property (nonatomic, copy)void(^touchBlock)(SQLCustomButton *button);



/* 
 初始化
 imageSize  图标大小
 isAutoWidth 是否根据文字长度自适应
 */
- (id)initWithFrame:(CGRect)frame
               type:(SQLCustomButtonType)type
          imageSize:(CGSize)imageSize
          midmargin:(CGFloat)midmargin;

//点击响应
- (void)touchAction:(void(^)(SQLCustomButton *button))block;


NS_ASSUME_NONNULL_END

@end
