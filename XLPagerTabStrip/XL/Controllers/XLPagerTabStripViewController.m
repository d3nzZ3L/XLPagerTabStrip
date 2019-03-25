//
//  XLPagerTabStripViewController
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

#import "XLPagerTabStripViewController.h"

@interface XLPagerTabStripViewController ()

@property (readonly) NSArray *pagerTabStripChildViewControllersForScrolling;
@property (nonatomic) NSUInteger currentIndex;
@property (nonatomic) NSUInteger preCurrentIndex;

@end

@implementation XLPagerTabStripViewController
{
    NSUInteger _lastPageNumber;
    CGFloat _lastContentOffset;
    NSUInteger _pageBeforeRotate;
    CGSize _lastSize;
}

@synthesize currentIndex = _currentIndex;
@synthesize pagerTabStripChildViewControllersForScrolling = _pagerTabStripChildViewControllersForScrolling;

#pragma maek - initializers

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        [self pagerTabStripViewControllerInit];
    }
    return self;
}


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self){
        [self pagerTabStripViewControllerInit];
    }
    return self;
}

-(void)dealloc
{
    self.containerView.delegate = nil;
}


-(void)pagerTabStripViewControllerInit
{
    _currentIndex = 0;
    _delegate = self;
    _dataSource = self;
    _lastContentOffset = 0.0f;
    _isElasticIndicatorLimit = NO;
    _skipIntermediateViewControllers = YES;
    _isProgressiveIndicator = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!self.containerView){
        self.containerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
        self.containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        [self.view addSubview:self.containerView];
    }
    self.containerView.clipsToBounds = YES;
    self.containerView.bounces = YES;
    [self.containerView setAlwaysBounceHorizontal:YES];
    [self.containerView setAlwaysBounceVertical:NO];
    self.containerView.scrollsToTop = NO;
    self.containerView.delegate = self;
    self.containerView.showsVerticalScrollIndicator = NO;
    self.containerView.showsHorizontalScrollIndicator = NO;
    self.containerView.pagingEnabled = YES;
    
    if (self.dataSource){
        _pagerTabStripChildViewControllers = [self.dataSource childViewControllersForPagerTabStripViewController:self];
    }    

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _lastSize = self.containerView.bounds.size;
    [self updateIfNeeded];
    BOOL needUpdateCurrentChild = _preCurrentIndex != _currentIndex;
    if (needUpdateCurrentChild) {
        [self moveToViewControllerAtIndex:_preCurrentIndex];
    }
    for (UIViewController *children in _pagerTabStripChildViewControllers) {
        [children endAppearanceTransition];
    }
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self updateIfNeeded];
    if  ([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending){
        // SYSTEM_VERSION_LESS_THAN 8.0
        [self.view layoutSubviews];
    }
}

#pragma mark - Properties

- (NSArray *)pagerTabStripChildViewControllersForScrolling
{
    // If a temporary re-ordered version of the view controllers is available return that
    // (i.e. skipIntermediateViewControllers==YES, the user has tapped a tab/cell and
    // we're animating using the re-ordered version)
    // Otherwise just return the normally ordered pagerTabStripChildViewControllers
    return _pagerTabStripChildViewControllersForScrolling ?: self.pagerTabStripChildViewControllers;
}

#pragma mark - move to another view controller

-(void)moveToViewControllerAtIndex:(NSUInteger)index
{
    [self moveToViewControllerAtIndex:index animated:YES];
}


-(void)moveToViewControllerAtIndex:(NSUInteger)index animated:(BOOL)animated
{
    if (!self.isViewLoaded && !self.view.window && _currentIndex == index){
        self.preCurrentIndex = index;
    } else {
        if (animated && self.skipIntermediateViewControllers && ABS(self.currentIndex - index) > 1){
            NSMutableArray * tempChildViewControllers = [NSMutableArray arrayWithArray:self.pagerTabStripChildViewControllers];
            UIViewController *currentChildVC = [self.pagerTabStripChildViewControllers objectAtIndex:self.currentIndex];
            NSUInteger fromIndex = (self.currentIndex < index) ? index - 1 : index + 1;
            UIViewController *fromChildVC = [self.pagerTabStripChildViewControllers objectAtIndex:fromIndex];
            [tempChildViewControllers setObject:fromChildVC atIndexedSubscript:self.currentIndex];
            [tempChildViewControllers setObject:currentChildVC atIndexedSubscript:fromIndex];
            _pagerTabStripChildViewControllersForScrolling = tempChildViewControllers;
            [self.containerView setContentOffset:CGPointMake([self pageOffsetForChildIndex:fromIndex], 0) animated:NO];
            if (self.navigationController){
                self.navigationController.view.userInteractionEnabled = NO;
            } else {
                self.view.userInteractionEnabled = NO;
            }
            [self.containerView setContentOffset:CGPointMake([self pageOffsetForChildIndex:index], 0) animated:YES];
        } else {
            [self.containerView setContentOffset:CGPointMake([self pageOffsetForChildIndex:index], 0) animated:animated];
        }
        
    }
}

-(void)moveToViewController:(UIViewController *)viewController
{
    [self moveToViewControllerAtIndex:[self.pagerTabStripChildViewControllers indexOfObject:viewController]];
}

-(void)moveToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self moveToViewControllerAtIndex:[self.pagerTabStripChildViewControllers indexOfObject:viewController] animated:animated];
}

#pragma mark - XLPagerTabStripViewControllerDelegate

-(void)pagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
          updateIndicatorFromIndex:(NSInteger)fromIndex
                           toIndex:(NSInteger)toIndex{

}

-(void)pagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
          updateIndicatorFromIndex:(NSInteger)fromIndex
                           toIndex:(NSInteger)toIndex
            withProgressPercentage:(CGFloat)progressPercentage
             indexWasChanged:(BOOL)indexWasChanged
{
    NSLog(@"8=============FIRED==================3");
}


#pragma mark - XLPagerTabStripViewControllerDataSource

-(NSArray *)childViewControllersForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
{
    NSAssert(NO, @"Sub-class must implement the XLPagerTabStripViewControllerDataSource childViewControllersForPagerTabStripViewController: method");
    return nil;
}


#pragma mark - Helpers

-(void)updateIfNeeded
{
    if (!CGSizeEqualToSize(_lastSize, self.containerView.bounds.size)){
        [self updateContent];
    }
}

-(XLPagerTabStripDirection)scrollDirection
{
    if (self.containerView.contentOffset.x > _lastContentOffset){
        return XLPagerTabStripDirectionLeft;
    }
    else if (self.containerView.contentOffset.x < _lastContentOffset){
        return XLPagerTabStripDirectionRight;
    }
    return XLPagerTabStripDirectionNone;
}

-(BOOL)canMoveToIndex:(NSUInteger)index
{
    return (self.currentIndex != index && self.pagerTabStripChildViewControllers.count > index);
}

-(CGFloat)pageOffsetForChildIndex:(NSUInteger)index
{
    return (index * CGRectGetWidth(self.containerView.bounds));
}

-(CGFloat)offsetForChildIndex:(NSUInteger)index
{
    if (CGRectGetWidth(self.containerView.bounds) > CGRectGetWidth(self.view.bounds)){
        return (index * CGRectGetWidth(self.containerView.bounds) + ((CGRectGetWidth(self.containerView.bounds) - CGRectGetWidth(self.view.bounds)) * 0.5));
    }
    return (index * CGRectGetWidth(self.containerView.bounds));
}

-(CGFloat)offsetForChildViewController:(UIViewController *)viewController
{
    NSInteger index = [self.pagerTabStripChildViewControllers indexOfObject:viewController];
    if (index == NSNotFound){
        @throw [NSException exceptionWithName:NSRangeException reason:nil userInfo:nil];
    }
    return [self offsetForChildIndex:index];
}

-(NSUInteger)pageForContentOffset:(CGFloat)contentOffset
{
    NSInteger result = [self virtualPageForContentOffset:contentOffset];
    return [self pageForVirtualPage:result];
}

-(NSInteger)virtualPageForContentOffset:(CGFloat)contentOffset
{
    NSInteger result = (contentOffset + (1.5f * [self pageWidth])) / [self pageWidth];
    return result - 1;
}

-(NSUInteger)pageForVirtualPage:(NSInteger)virtualPage
{
    if (virtualPage < 0){
        return 0;
    }
    if (virtualPage > self.pagerTabStripChildViewControllers.count - 1){
        return self.pagerTabStripChildViewControllers.count - 1;
    }
    return virtualPage;
}

-(CGFloat)pageWidth
{
    return CGRectGetWidth(self.containerView.bounds);
}

-(CGFloat)scrollPercentage
{
    if ([self scrollDirection] == XLPagerTabStripDirectionLeft || [self scrollDirection] == XLPagerTabStripDirectionNone){
        if (fmodf(self.containerView.contentOffset.x, [self pageWidth]) == 0.0) {
            return 1.0;
        }
        return fmodf(self.containerView.contentOffset.x, [self pageWidth]) / [self pageWidth];
    }
    return 1 - fmodf(self.containerView.contentOffset.x >= 0 ? self.containerView.contentOffset.x : [self pageWidth] + self.containerView.contentOffset.x, [self pageWidth]) / [self pageWidth];
}

-(void)updateContent
{
    if (!CGSizeEqualToSize(_lastSize, self.containerView.bounds.size)){
        if (_lastSize.width != self.containerView.bounds.size.width){
            _lastSize = self.containerView.bounds.size;
            [self.containerView setContentOffset:CGPointMake([self pageOffsetForChildIndex:self.currentIndex], 0) animated:NO];
        }
        else{
            _lastSize = self.containerView.bounds.size;
        }
    }
    
    NSArray * childViewControllers = self.pagerTabStripChildViewControllersForScrolling;
    self.containerView.contentSize = CGSizeMake(CGRectGetWidth(self.containerView.bounds) * childViewControllers.count, self.containerView.contentSize.height);
    
    [childViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIViewController * childController = (UIViewController *)obj;
        CGFloat pageOffsetForChild = [self pageOffsetForChildIndex:idx];
        if (fabs(self.containerView.contentOffset.x - pageOffsetForChild) < CGRectGetWidth(self.containerView.bounds)) {
            if (![childController parentViewController]) { // Add child
                [self addChildViewController:childController];
                [childController didMoveToParentViewController:self];
                
                CGFloat childPosition = [self offsetForChildIndex:idx];
                [childController.view setFrame:CGRectMake(childPosition, 0, MIN(CGRectGetWidth(self.view.bounds), CGRectGetWidth(self.containerView.bounds)), CGRectGetHeight(self.containerView.bounds))];
                childController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

                [childController beginAppearanceTransition:YES animated:NO];
                [self.containerView addSubview:childController.view];
                [childController endAppearanceTransition];
            } else {
                CGFloat childPosition = [self offsetForChildIndex:idx];
                [childController.view setFrame:CGRectMake(childPosition, 0, MIN(CGRectGetWidth(self.view.bounds), CGRectGetWidth(self.containerView.bounds)), CGRectGetHeight(self.containerView.bounds))];
                childController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            }
        } else {
            if ([childController parentViewController]) { // Remove child
                [childController willMoveToParentViewController:nil];
                [childController beginAppearanceTransition:NO animated:NO];
                [childController.view removeFromSuperview];
                [childController endAppearanceTransition];
                [childController removeFromParentViewController];
            }
        }
    }];
    
    NSUInteger oldCurrentIndex = self.currentIndex;
    NSInteger virtualPage = [self virtualPageForContentOffset:self.containerView.contentOffset.x];
    NSUInteger newCurrentIndex = [self pageForVirtualPage:virtualPage];
    self.currentIndex = newCurrentIndex;
    self.preCurrentIndex = self.currentIndex;
    BOOL changeCurrentIndex = newCurrentIndex != oldCurrentIndex;
    
    if (self.isProgressiveIndicator){
        if ([self.delegate respondsToSelector:@selector(pagerTabStripViewController:updateIndicatorFromIndex:toIndex:withProgressPercentage:indexWasChanged:)]){
            CGFloat scrollPercentage = [self scrollPercentage];
            if (scrollPercentage > 0) {
                NSInteger fromIndex = self.currentIndex;
                NSInteger toIndex = self.currentIndex;
                XLPagerTabStripDirection scrollDirection = [self scrollDirection];
                if (scrollDirection == XLPagerTabStripDirectionLeft){
                    if (virtualPage > self.pagerTabStripChildViewControllersForScrolling.count - 1){
                        fromIndex = self.pagerTabStripChildViewControllersForScrolling.count - 1;
                        toIndex = self.pagerTabStripChildViewControllersForScrolling.count;
                    } else{
                        if (scrollPercentage >= 0.5f){
                            fromIndex = MAX(toIndex - 1, 0);
                        }
                        else{
                            toIndex = fromIndex + 1;
                        }
                    }
                } else if (scrollDirection == XLPagerTabStripDirectionRight) {
                    if (virtualPage < 0){
                        fromIndex = 0;
                        toIndex = -1;
                    } else {
                        if (scrollPercentage > 0.5f){
                            fromIndex = MIN(toIndex + 1, self.pagerTabStripChildViewControllersForScrolling.count - 1);
                        } else {
                            toIndex = fromIndex - 1;
                        }
                    }
                }
                NSLog(@"TO INDEX %ld FROM %ld", (long)toIndex, fromIndex);
                [self.delegate pagerTabStripViewController:self updateIndicatorFromIndex:fromIndex toIndex:toIndex withProgressPercentage:(self.isElasticIndicatorLimit ? scrollPercentage : ( toIndex < 0 || toIndex >= self.pagerTabStripChildViewControllersForScrolling.count ? 0 : scrollPercentage )) indexWasChanged:changeCurrentIndex];
            }
        }
    }
    else{
        if ([self.delegate respondsToSelector:@selector(pagerTabStripViewController:updateIndicatorFromIndex:toIndex:)] && oldCurrentIndex != newCurrentIndex){
            [self.delegate pagerTabStripViewController:self
                              updateIndicatorFromIndex:MIN(oldCurrentIndex, self.pagerTabStripChildViewControllersForScrolling.count - 1)
                                               toIndex:newCurrentIndex];
        }
    }
}


-(void)reloadPagerTabStripView
{
    if ([self isViewLoaded]){
        [self.pagerTabStripChildViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UIViewController * childController = (UIViewController *)obj;
            if ([childController parentViewController]){
                [childController.view removeFromSuperview];
                [childController willMoveToParentViewController:nil];
                [childController removeFromParentViewController];
            }
        }];
        _pagerTabStripChildViewControllers = self.dataSource ? [self.dataSource childViewControllersForPagerTabStripViewController:self] : @[];
        self.containerView.contentSize = CGSizeMake(CGRectGetWidth(self.containerView.bounds) * self.pagerTabStripChildViewControllers.count, self.containerView.contentSize.height);
        if (self.currentIndex >= self.pagerTabStripChildViewControllers.count){
            self.currentIndex = self.pagerTabStripChildViewControllers.count - 1;
        }
        _preCurrentIndex = _currentIndex;
        [self.containerView setContentOffset:CGPointMake([self pageOffsetForChildIndex:self.currentIndex], 0)  animated:NO];
        [self updateContent];
    }
}

#pragma mark - UIScrollViewDelegte

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.containerView == scrollView){
        [self updateContent];
        _lastContentOffset = scrollView.contentOffset.x;
    }
}


-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.containerView == scrollView){
        _lastPageNumber = [self pageForContentOffset:scrollView.contentOffset.x];
    }
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (self.containerView == scrollView){
        _pagerTabStripChildViewControllersForScrolling = nil;
        
        [self updateContent];
    }
    
    if (self.navigationController){
        self.navigationController.view.userInteractionEnabled = YES;
    }
    else{
        self.view.userInteractionEnabled = YES;
    }
}

#pragma mark - Orientation

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    _pageBeforeRotate = self.currentIndex;
    __typeof__(self) __weak weakSelf = self;
    [coordinator animateAlongsideTransition:nil
                                 completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
                                     weakSelf.currentIndex = _pageBeforeRotate;
                                     weakSelf.preCurrentIndex = weakSelf.currentIndex;
                                     [weakSelf updateIfNeeded];
    }];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    _pageBeforeRotate = self.currentIndex;
}

@end
