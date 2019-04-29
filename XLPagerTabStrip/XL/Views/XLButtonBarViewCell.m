//
//  XLButtonBarViewCell.m
//  XLPagerTabStrip ( https://github.com/xmartlabs/XLPagerTabStrip )
//
//  Copyright (c) 2015 Xmartlabs ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "XLButtonBarViewCell.h"

@interface XLButtonBarViewCell()

@property IBOutlet UIImageView * imageView;
@property IBOutlet UILabel * label;
@property IBOutlet UILabel * priceLabel;
@property IBOutlet UILabel * etaLabel;
@end

@implementation XLButtonBarViewCell

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    if (!self.label.superview){
        // If label wasn't configured in a XIB or storyboard then it won't have
        // been added to the view so we need to do it programmatically.
        [self.contentView addSubview:self.label];
    }
    if (!self.priceLabel.superview) {
        [self.contentView addSubview:self.priceLabel];
    }
    if (!self.etaLabel.superview) {
        [self.contentView addSubview:self.etaLabel];
    }
}

- (UILabel *)label
{
    if (_label) return _label;
    // If _label is nil then it wasn't configured in a XIB or storyboard so this
    // class is being used programmatically. We need to initialise the label,
    // setup some sensible defaults and set an appropriate frame.
    // The label gets added to to the view in willMoveToSuperview:
    _label = [[UILabel alloc] initWithFrame:self.contentView.bounds];
    _label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _label.textAlignment = NSTextAlignmentLeft;
    _label.font = [UIFont systemFontOfSize:14.0f weight:UIFontWeightMedium];
    return _label;
}

- (UILabel *)priceLabel {
    if (_priceLabel) return _priceLabel;
    _priceLabel = [[UILabel alloc] initWithFrame:self.contentView.bounds];
    _priceLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _priceLabel.textAlignment = NSTextAlignmentCenter;
    _priceLabel.font = [UIFont systemFontOfSize:16.0f weight:UIFontWeightMedium];
    return _priceLabel;
}
- (UILabel *)etaLabel {
    if (_etaLabel) return _etaLabel;
    _etaLabel = [[UILabel alloc] initWithFrame:self.contentView.bounds];
    _etaLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _etaLabel.textAlignment = NSTextAlignmentCenter;
    _etaLabel.font = [UIFont systemFontOfSize:12.0f weight:UIFontWeightMedium];
    return _etaLabel;

}
@end
