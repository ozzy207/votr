//
// ASJTag.m
//

#import "ASJTag.h"

@interface ASJTag ()

@property (weak, nonatomic) IBOutlet UIButton *tagButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (readonly, nonatomic) UIImage *defaultCrossImage;

- (IBAction)tagTapped:(UIButton *)sender;
- (IBAction)deleteTapped:(UIButton *)sender;

@end

@implementation ASJTag

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.crossImage = self.defaultCrossImage;
}

- (UIImage *)defaultCrossImage
{
  NSString *resourcesBundlePath = [[NSBundle mainBundle] pathForResource:@"Resources" ofType:@"bundle"];
  NSBundle *resourcesBundle = [NSBundle bundleWithPath:resourcesBundlePath];
  return [UIImage imageNamed:@"cross" inBundle:resourcesBundle compatibleWithTraitCollection:nil];
}

#pragma mark - IBActions

- (IBAction)tagTapped:(UIButton *)sender
{
  if (_tapBlock) {
    _tapBlock(sender.titleLabel.text, self.tag);
  }
}

- (IBAction)deleteTapped:(UIButton *)sender
{
  if (_deleteBlock) {
    _deleteBlock(_tagButton.titleLabel.text, self.tag);
  }
}

#pragma mark - Property setters

- (void)setTagText:(NSString *)tagText
{
  if (!tagText) {
    return;
  }
  _tagText = tagText;
  
  [UIView performWithoutAnimation:^{
    [_tagButton setTitle:tagText forState:UIControlStateNormal];
    [_tagButton layoutIfNeeded];
  }];
}

- (void)setTagTextColor:(UIColor *)tagTextColor
{
  if (!tagTextColor) {
    return;
  }
  _tagTextColor = tagTextColor;
  [_tagButton setTitleColor:tagTextColor forState:UIControlStateNormal];
}

- (void)setCrossImage:(UIImage *)crossImage
{
  if (!crossImage) {
    return;
  }
  _crossImage = crossImage;
  [_deleteButton setImage:crossImage forState:UIControlStateNormal];
}

- (void)setTagFont:(UIFont *)tagFont
{
  if (!tagFont) {
    return;
  }
  _tagFont = tagFont;
  _tagButton.titleLabel.font = tagFont;
}

@end
