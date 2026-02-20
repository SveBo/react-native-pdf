/**
 * Copyright (c) 2017-present, Wonday (@wonday.org)
 * All rights reserved.
 *
 * This source code is licensed under the MIT-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "RNPDFPdfView.h"

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <PDFKit/PDFKit.h>

#if __has_include(<React/RCTAssert.h>)
#import <React/RCTBridgeModule.h>
#import <React/RCTEventDispatcher.h>
#import <React/UIView+React.h>
#import <React/RCTLog.h>
#import <React/RCTBlobManager.h>
#else
#import "RCTBridgeModule.h"
#import "RCTEventDispatcher.h"
#import "UIView+React.h"
#import "RCTLog.h"
#import <RCTBlobManager.h">
#endif

#ifdef RCT_NEW_ARCH_ENABLED
#import <React/RCTConversions.h>
#import <React/RCTFabricComponentsPlugins.h>
#import <react/renderer/components/rnpdf/ComponentDescriptors.h>
#import <react/renderer/components/rnpdf/Props.h>
#import <react/renderer/components/rnpdf/RCTComponentViewHelpers.h>

// Some RN private method hacking below similar to how it is done in RNScreens:
// https://github.com/software-mansion/react-native-screens/blob/90e548739f35b5ded2524a9d6410033fc233f586/ios/RNSScreenStackHeaderConfig.mm#L30
@interface RCTBridge (Private)
+ (RCTBridge *)currentBridge;
@end

#endif

#ifndef __OPTIMIZE__
// only output log when debug
#define DLog( s, ... ) NSLog( @"<%p %@:(%d)> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define DLog( s, ... )
#endif

// output log both debug and release
#define RLog( s, ... ) NSLog( @"<%p %@:(%d)> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )

const float MAX_SCALE = 3.0f;
const float MIN_SCALE = 1.0f;

@interface RNPDFPdfView() <PDFDocumentDelegate, PDFViewDelegate, UIGestureRecognizerDelegate
#ifdef RCT_NEW_ARCH_ENABLED
, RCTRNPDFPdfViewViewProtocol
#endif
>
@end

@implementation RNPDFPdfView
{
    RCTBridge *_bridge;
    PDFDocument *_pdfDocument;
    PDFView *_pdfView;
    PDFOutline *root;
    float _fixScaleFactor;
    bool _initialed;
    NSArray<NSString *> *_changedProps;
    UITapGestureRecognizer *_doubleTapRecognizer;
    UITapGestureRecognizer *_singleTapRecognizer;
    UIPinchGestureRecognizer *_pinchRecognizer;
    UILongPressGestureRecognizer *_longPressRecognizer;
    UITapGestureRecognizer *_doubleTapEmptyRecognizer;
}

#ifdef RCT_NEW_ARCH_ENABLED

using namespace facebook::react;

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
  return concreteComponentDescriptorProvider<RNPDFPdfViewComponentDescriptor>();
}

// Needed because of this: https://github.com/facebook/react-native/pull/37274
+ (void)load
{
  [super load];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        static const auto defaultProps = std::make_shared<const RNPDFPdfViewProps>();
        _props = defaultProps;
        [self initCommonProps];
    }
    return self;
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
    const auto &newProps = *std::static_pointer_cast<const RNPDFPdfViewProps>(props);
    NSMutableArray<NSString *> *updatedPropNames = [NSMutableArray new];
    if (_path != RCTNSStringFromStringNilIfEmpty(newProps.path)) {
        _path = RCTNSStringFromStringNilIfEmpty(newProps.path);
        [updatedPropNames addObject:@"path"];
    }
    if (_page != newProps.page) {
        _page = newProps.page;
        [updatedPropNames addObject:@"page"];
    }
    if (_scale != newProps.scale) {
        _scale = newProps.scale;
        [updatedPropNames addObject:@"scale"];
    }
    if (_minScale != newProps.minScale) {
        _minScale = newProps.minScale;
        [updatedPropNames addObject:@"minScale"];
    }
    if (_maxScale != newProps.maxScale) {
        _maxScale = newProps.maxScale;
        [updatedPropNames addObject:@"maxScale"];
    }
    if (_horizontal != newProps.horizontal) {
        _horizontal = newProps.horizontal;
        [updatedPropNames addObject:@"horizontal"];
    }
    if (_enablePaging != newProps.enablePaging) {
        _enablePaging = newProps.enablePaging;
        [updatedPropNames addObject:@"enablePaging"];
    }
    if (_enableRTL != newProps.enableRTL) {
        _enableRTL = newProps.enableRTL;
        [updatedPropNames addObject:@"enableRTL"];
    }
    if (_enableAnnotationRendering != newProps.enableAnnotationRendering) {
        _enableAnnotationRendering = newProps.enableAnnotationRendering;
        [updatedPropNames addObject:@"enableAnnotationRendering"];
    }
    if (_enableDoubleTapZoom != newProps.enableDoubleTapZoom) {
        _enableDoubleTapZoom = newProps.enableDoubleTapZoom;
        [updatedPropNames addObject:@"enableDoubleTapZoom"];
    }
    if (_fitPolicy != newProps.fitPolicy) {
        _fitPolicy = newProps.fitPolicy;
        [updatedPropNames addObject:@"fitPolicy"];
    }
    if (_spacing != newProps.spacing) {
        _spacing = newProps.spacing;
        [updatedPropNames addObject:@"spacing"];
    }
    if (_password != RCTNSStringFromStringNilIfEmpty(newProps.password)) {
        _password = RCTNSStringFromStringNilIfEmpty(newProps.password);
        [updatedPropNames addObject:@"password"];
    }
    if (_singlePage != newProps.singlePage) {
        _singlePage = newProps.singlePage;
        [updatedPropNames addObject:@"singlePage"];
    }
    if (_showsHorizontalScrollIndicator != newProps.showsHorizontalScrollIndicator) {
        _showsHorizontalScrollIndicator = newProps.showsHorizontalScrollIndicator;
        [updatedPropNames addObject:@"showsHorizontalScrollIndicator"];
    }
    if (_showsVerticalScrollIndicator != newProps.showsVerticalScrollIndicator) {
        _showsVerticalScrollIndicator = newProps.showsVerticalScrollIndicator;
        [updatedPropNames addObject:@"showsVerticalScrollIndicator"];
    }
    if (_scrollEnabled != newProps.scrollEnabled) {
        _scrollEnabled = newProps.scrollEnabled;
        [updatedPropNames addObject:@"scrollEnabled"];
    }

    [super updateProps:props oldProps:oldProps];
    [self didSetProps:updatedPropNames];
}

// already added in case https://github.com/facebook/react-native/pull/35378 has been merged
- (BOOL)shouldBeRecycled
{
    return NO;
}

- (void)prepareForRecycle
{
    [super prepareForRecycle];

    // Remove KVO before tearing down
    if (_pdfView) {
        for (UIView *subview in _pdfView.subviews) {
            if ([subview isKindOfClass:[UIScrollView class]]) {
                UIScrollView *scrollView = (UIScrollView *)subview;
                @try {
                    [scrollView removeObserver:self forKeyPath:@"contentOffset"];
                } @catch (__unused NSException *e) {}
            }
        }
    }

    [_pdfView removeFromSuperview];
    _pdfDocument = Nil;
    _pdfView = Nil;

    // Remove notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PDFViewDocumentChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PDFViewPageChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PDFViewScaleChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PDFViewSelectionChangedNotification object:nil];

    // remove old recognizers before adding new ones
    [self removeGestureRecognizer:_doubleTapRecognizer];
    [self removeGestureRecognizer:_singleTapRecognizer];
    [self removeGestureRecognizer:_pinchRecognizer];
    [self removeGestureRecognizer:_longPressRecognizer];
    [self removeGestureRecognizer:_doubleTapEmptyRecognizer];

    [self initCommonProps];
}

- (void)updateLayoutMetrics:(const facebook::react::LayoutMetrics &)layoutMetrics oldLayoutMetrics:(const facebook::react::LayoutMetrics &)oldLayoutMetrics
{
    // Fabric equivalent of `reactSetFrame` method
    [super updateLayoutMetrics:layoutMetrics oldLayoutMetrics:oldLayoutMetrics];
    _pdfView.frame = CGRectMake(0, 0, layoutMetrics.frame.size.width, layoutMetrics.frame.size.height);

    NSMutableArray *mProps = [_changedProps mutableCopy];
    if (_initialed) {
        [mProps removeObject:@"path"];
    }
    _initialed = YES;

    [self didSetProps:mProps];
}

- (void)handleCommand:(const NSString *)commandName args:(const NSArray *)args
{
  RCTRNPDFPdfViewHandleCommand(self, commandName, args);
}

- (void)setNativePage:(NSInteger)page
{
    _page = page;
    [self didSetProps:@[@"page"]];
}

#endif // RCT_NEW_ARCH_ENABLED

- (instancetype)initWithBridge:(RCTBridge *)bridge
{
    self = [super init];
    if (self) {
        _bridge = bridge;
        [self initCommonProps];
    }
    return self;
}

- (void)initCommonProps
{
    _page = 1;
    _scale = 1;
    _minScale = MIN_SCALE;
    _maxScale = MAX_SCALE;
    _horizontal = NO;
    _enablePaging = NO;
    _enableRTL = NO;
    _enableAnnotationRendering = YES;
    _enableDoubleTapZoom = YES;
    _fitPolicy = 2;
    _spacing = 10;
    _singlePage = NO;
    _showsHorizontalScrollIndicator = YES;
    _showsVerticalScrollIndicator = YES;
    _scrollEnabled = YES;

    // init and config PDFView
    _pdfView = [[PDFView alloc] initWithFrame:CGRectMake(0, 0, 500, 500)];
    _pdfView.displayMode = kPDFDisplaySinglePageContinuous;
    _pdfView.autoScales = YES;
    _pdfView.displaysPageBreaks = YES;
    _pdfView.displayBox = kPDFDisplayBoxCropBox;
    _pdfView.backgroundColor = [UIColor clearColor];

    _fixScaleFactor = -1.0f;
    _initialed = NO;
    _changedProps = NULL;

    _initialXOffset = 0;
    _initialYOffset = 0;

    [self addSubview:_pdfView];

    // register notification
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(onDocumentChanged:) name:PDFViewDocumentChangedNotification object:_pdfView];
    [center addObserver:self selector:@selector(onPageChanged:) name:PDFViewPageChangedNotification object:_pdfView];
    [center addObserver:self selector:@selector(onScaleChanged:) name:PDFViewScaleChangedNotification object:_pdfView];
    [center addObserver:self selector:@selector(onSelectionChanged:) name:PDFViewSelectionChangedNotification object:_pdfView];
    [center addObserver:self selector:@selector(onOrientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];

    [[_pdfView document] setDelegate:self];
    [_pdfView setDelegate:self];

    // Disable built-in taps to avoid conflicts with custom recognizers.
    for (UIGestureRecognizer *recognizer in _pdfView.gestureRecognizers) {
        if ([recognizer isKindOfClass:[UITapGestureRecognizer class]]) {
            recognizer.enabled = NO;
        }
    }

    [self bindTap];
}

- (void)onSelectionChanged:(NSNotification *)noti
{
    if (_pdfView.currentSelection) {
        [_pdfView setCurrentSelection:nil];
    }
}

- (void)moveToNative:(float)x y:(float)y scale:(float)scale
{
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        for (UIView *subview in strongSelf->_pdfView.subviews) {
            if ([subview isKindOfClass:[UIScrollView class]]) {
                CGFloat newScale = scale * strongSelf->_fixScaleFactor;
                [strongSelf->_pdfView setScaleFactor:newScale];
                [strongSelf setNeedsDisplay];
                [strongSelf onScaleChanged:nil];

                UIScrollView *scrollView = (UIScrollView *)subview;
                CGPoint contentOffset = CGPointMake(x, y);
                [scrollView setContentOffset:contentOffset animated:NO];
            }
        }
    });
}

- (void)resetZoom
{
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        float min = strongSelf->_pdfView.minScaleFactor / strongSelf->_fixScaleFactor;
        float scale = min;

        CGFloat newScale = scale * strongSelf->_fixScaleFactor;
        CGPoint tapPoint = CGPointMake(0.0, 0.0);

        PDFPage *tappedPdfPage = [strongSelf->_pdfView pageForPoint:tapPoint nearest:NO];
        PDFPage *pageRef = tappedPdfPage ? tappedPdfPage : strongSelf->_pdfView.currentPage;
        tapPoint = [strongSelf->_pdfView convertPoint:tapPoint toPage:pageRef];

        CGRect tempZoomRect = CGRectZero;
        tempZoomRect.size.width = strongSelf->_pdfView.frame.size.width;
        tempZoomRect.size.height = 1;
        tempZoomRect.origin = tapPoint;

        [strongSelf->_pdfView setScaleFactor:newScale];

        [strongSelf->_pdfView goToRect:tempZoomRect onPage:pageRef];
        CGPoint defZoomOrigin = [strongSelf->_pdfView convertPoint:tempZoomRect.origin fromPage:pageRef];
        defZoomOrigin.x = defZoomOrigin.x - strongSelf->_pdfView.frame.size.width / 2;
        defZoomOrigin.y = defZoomOrigin.y - strongSelf->_pdfView.frame.size.height / 2;
        defZoomOrigin = [strongSelf->_pdfView convertPoint:defZoomOrigin toPage:pageRef];
        CGRect defZoomRect = CGRectOffset(
            tempZoomRect,
            defZoomOrigin.x - tempZoomRect.origin.x,
            defZoomOrigin.y - tempZoomRect.origin.y
        );
        [strongSelf->_pdfView goToRect:defZoomRect onPage:pageRef];

        [strongSelf setNeedsDisplay];
        [strongSelf onScaleChanged:nil];
    });
}

- (void)onOrientationChanged:(NSNotification *)noti
{
    [self resetZoom];
    [self pdfSizeChanged];
}

- (void)pdfSizeChanged
{
    __weak __typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf || !strongSelf->_pdfDocument) return;

        PDFPage *page = [strongSelf->_pdfDocument pageAtIndex:strongSelf->_pdfDocument.pageCount - 1];
        CGSize pageSize = [strongSelf->_pdfView rowSizeForPage:page];

        NSString *computedSize = [NSString stringWithFormat:@"onPdfSizeChanged|%f|%f",
                                  pageSize.width / strongSelf->_scale,
                                  pageSize.height / strongSelf->_scale];

        [strongSelf notifyOnChangeWithMessage:[[NSString alloc] initWithString:computedSize]];
    });
}

- (void)loadCompelete
{
    if (self->_pdfDocument) {
        unsigned long numberOfPages = self->_pdfDocument.pageCount;
        NSString *jsonString = [self getTableContents];
        [self notifyOnChangeWithMessage:[[NSString alloc] initWithString:[NSString stringWithFormat:@"loadComplete|%lu|%@", numberOfPages, jsonString]]];
        [self pdfSizeChanged];
    }
}

- (void)PDFViewWillClickOnLink:(PDFView *)sender withURL:(NSURL *)url
{
    NSString *_url = url.absoluteString;
    [self notifyOnChangeWithMessage:
     [[NSString alloc] initWithString:
      [NSString stringWithFormat:@"linkPressed|%s", _url.UTF8String]]];
}

- (void)didSetProps:(NSArray<NSString *> *)changedProps
{
    if (!_initialed) {
        _changedProps = changedProps;
        return;
    }

    if ([changedProps containsObject:@"path"]) {

        if (_pdfDocument != Nil) {
            _pdfDocument = Nil;
        }

        if ([_path hasPrefix:@"blob:"]) {
            RCTBlobManager *blobManager = [
#ifdef RCT_NEW_ARCH_ENABLED
                [RCTBridge currentBridge]
#else
                _bridge
#endif
                moduleForName:@"BlobModule"];
            NSURL *blobURL = [NSURL URLWithString:_path];
            NSData *blobData = [blobManager resolveURL:blobURL];
            if (blobData != nil) {
                _pdfDocument = [[PDFDocument alloc] initWithData:blobData];
            }
        } else {
            _path = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapes(NULL, (CFStringRef)_path, CFSTR(""));
            NSURL *fileURL = [NSURL fileURLWithPath:_path];
            _pdfDocument = [[PDFDocument alloc] initWithURL:fileURL];
        }

        if (_pdfDocument) {
            if (_pdfDocument.isLocked && ![_pdfDocument unlockWithPassword:_password]) {
                [self notifyOnChangeWithMessage:@"error|Password required or incorrect password."];
                _pdfDocument = Nil;
                return;
            }
            _pdfView.document = _pdfDocument;
        } else {
            [self notifyOnChangeWithMessage:[[NSString alloc] initWithString:[NSString stringWithFormat:@"error|Load pdf failed. path=%s", _path.UTF8String]]];
            _pdfDocument = Nil;
            return;
        }
    }

    if (_pdfDocument && ([changedProps containsObject:@"path"] || [changedProps containsObject:@"spacing"])) {
        // Keep your behavior (no shadows), but make sure margins use scale factor like in your HEAD
        if (_horizontal) {
            _pdfView.pageBreakMargins = UIEdgeInsetsMake(0, _spacing / _fixScaleFactor, 0, 0);
            if (@available(iOS 12.0, *)) _pdfView.pageShadowsEnabled = NO;
        } else {
            _pdfView.pageBreakMargins = UIEdgeInsetsMake(0, 0, _spacing / _fixScaleFactor, 0);
            if (@available(iOS 12.0, *)) _pdfView.pageShadowsEnabled = NO;
        }
    }

    if (_pdfDocument && ([changedProps containsObject:@"path"] || [changedProps containsObject:@"enableRTL"])) {
        _pdfView.displaysRTL = _enableRTL;
    }

    if (_pdfDocument && ([changedProps containsObject:@"path"] || [changedProps containsObject:@"enableAnnotationRendering"])) {
        if (!_enableAnnotationRendering) {
            for (unsigned long i = 0; i < _pdfView.document.pageCount; i++) {
                PDFPage *pdfPage = [_pdfView.document pageAtIndex:i];
                for (unsigned long j = 0; j < pdfPage.annotations.count; j++) {
                    pdfPage.annotations[j].shouldDisplay = _enableAnnotationRendering;
                }
            }
        }
    }

    if (_pdfDocument && ([changedProps containsObject:@"path"] || [changedProps containsObject:@"fitPolicy"] || [changedProps containsObject:@"minScale"] || [changedProps containsObject:@"maxScale"])) {

        PDFPage *pdfPage = _pdfView.currentPage ? _pdfView.currentPage : [_pdfDocument pageAtIndex:_pdfDocument.pageCount - 1];
        CGRect pdfPageRect = [pdfPage boundsForBox:kPDFDisplayBoxCropBox];

        if (pdfPage.rotation == 90 || pdfPage.rotation == 270) {
            pdfPageRect = CGRectMake(0, 0, pdfPageRect.size.height, pdfPageRect.size.width);
        }

        if (_fitPolicy == 0) {
            _fixScaleFactor = self.frame.size.width / pdfPageRect.size.width;
        } else if (_fitPolicy == 1) {
            _fixScaleFactor = self.frame.size.height / pdfPageRect.size.height;
        } else {
            float pageAspect = pdfPageRect.size.width / pdfPageRect.size.height;
            float reactViewAspect = self.frame.size.width / self.frame.size.height;
            if (reactViewAspect > pageAspect) {
                _fixScaleFactor = self.frame.size.height / pdfPageRect.size.height;
            } else {
                _fixScaleFactor = self.frame.size.width / pdfPageRect.size.width;
            }
        }

        _pdfView.scaleFactor = _scale * _fixScaleFactor;
        _pdfView.minScaleFactor = _fixScaleFactor * _minScale;
        _pdfView.maxScaleFactor = _fixScaleFactor * _maxScale;
    }

    if (_pdfDocument && ([changedProps containsObject:@"path"] || [changedProps containsObject:@"scale"])) {
        _pdfView.scaleFactor = _scale * _fixScaleFactor;
        if (_pdfView.scaleFactor > _pdfView.maxScaleFactor) _pdfView.scaleFactor = _pdfView.maxScaleFactor;
        if (_pdfView.scaleFactor < _pdfView.minScaleFactor) _pdfView.scaleFactor = _pdfView.minScaleFactor;
    }

    if (_pdfDocument && ([changedProps containsObject:@"path"] || [changedProps containsObject:@"horizontal"])) {
        if (_horizontal) {
            _pdfView.displayDirection = kPDFDisplayDirectionHorizontal;
            _pdfView.pageBreakMargins = UIEdgeInsetsMake(0, _spacing / _fixScaleFactor, 0, 0);
        } else {
            _pdfView.displayDirection = kPDFDisplayDirectionVertical;
            _pdfView.pageBreakMargins = UIEdgeInsetsMake(0, 0, _spacing / _fixScaleFactor, 0);
        }
    }

    if (_pdfDocument && ([changedProps containsObject:@"path"] || [changedProps containsObject:@"enablePaging"])) {
        if (_enablePaging) {
            [_pdfView usePageViewController:YES withViewOptions:@{
                UIPageViewControllerOptionSpineLocationKey: @(UIPageViewControllerSpineLocationMin),
                UIPageViewControllerOptionInterPageSpacingKey: @(_spacing)
            }];
        } else {
            [_pdfView usePageViewController:NO withViewOptions:Nil];
        }
    }

    if (_pdfDocument && ([changedProps containsObject:@"path"] || [changedProps containsObject:@"singlePage"])) {
        if (_singlePage) {
            _pdfView.displayMode = kPDFDisplaySinglePage;
            _pdfView.userInteractionEnabled = NO;
        } else {
            _pdfView.displayMode = kPDFDisplaySinglePageContinuous;
            _pdfView.userInteractionEnabled = YES;
        }
    }

    if (_pdfDocument && ([changedProps containsObject:@"path"] || [changedProps containsObject:@"showsHorizontalScrollIndicator"] || [changedProps containsObject:@"showsVerticalScrollIndicator"])) {
        [self setScrollIndicators:_pdfView horizontal:_showsHorizontalScrollIndicator vertical:_showsVerticalScrollIndicator depth:0];
    }

    if (_pdfDocument && ([changedProps containsObject:@"path"] || [changedProps containsObject:@"scrollEnabled"])) {
        for (UIView *subview in _pdfView.subviews) {
            if ([subview isKindOfClass:[UIScrollView class]]) {
                UIScrollView *scrollView = (UIScrollView *)subview;
                scrollView.scrollEnabled = _scrollEnabled;

                // Your extra handling
                scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
                scrollView.contentInset = UIEdgeInsetsZero;
                if (_scrollEnabled) {
                    scrollView.contentOffset = CGPointMake(_initialXOffset, _initialYOffset);
                }

                // Your KVC hack (keep it, but be aware this is private API risk)
                @try {
                    [scrollView setValue:@(YES) forKey:@"forcesTopAlignment"];
                } @catch (__unused NSException *e) {}
            }
        }
    }

    if (_pdfDocument && ([changedProps containsObject:@"path"] || [changedProps containsObject:@"enablePaging"] || [changedProps containsObject:@"horizontal"] || [changedProps containsObject:@"page"])) {

        PDFPage *pdfPage = [_pdfDocument pageAtIndex:_page - 1];
        if (_page == 1) {
            // Your HEAD version intentionally does not force a goToRect for page 1.
        } else if (pdfPage) {
            CGPoint pointLeftTop = CGPointMake(0, 0);
            PDFDestination *pdfDest = [[PDFDestination alloc] initWithPage:pdfPage atPoint:pointLeftTop];
            [_pdfView goToDestination:pdfDest];
            _pdfView.scaleFactor = _fixScaleFactor * _scale;
        }
    }

    _pdfView.backgroundColor = [UIColor clearColor];
    [_pdfView layoutDocumentView];
    [self setNeedsDisplay];
}

- (void)reactSetFrame:(CGRect)frame
{
    [super reactSetFrame:frame];
    _pdfView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);

    NSMutableArray *mProps = [_changedProps mutableCopy];
    if (_initialed) {
        [mProps removeObject:@"path"];
    }
    _initialed = YES;

    [self didSetProps:mProps];
}

- (void)notifyOnChangeWithMessage:(NSString *)message
{
#ifdef RCT_NEW_ARCH_ENABLED
    if (_eventEmitter != nullptr) {
        std::dynamic_pointer_cast<const RNPDFPdfViewEventEmitter>(_eventEmitter)
            ->onChange(RNPDFPdfViewEventEmitter::OnChange{.message = RCTStringFromNSString(message)});
    }
#else
    _onChange(@{ @"message": message });
#endif
}

- (void)dealloc
{
    if (_pdfView) {
        for (UIView *subview in _pdfView.subviews) {
            if ([subview isKindOfClass:[UIScrollView class]]) {
                UIScrollView *scrollView = (UIScrollView *)subview;
                @try {
                    [scrollView removeObserver:self forKeyPath:@"contentOffset"];
                } @catch (__unused NSException *e) {}
            }
        }
    }

    _pdfDocument = Nil;
    _pdfView = Nil;

    [[NSNotificationCenter defaultCenter] removeObserver:self name:PDFViewDocumentChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PDFViewPageChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PDFViewScaleChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PDFViewSelectionChangedNotification object:nil];

    _doubleTapRecognizer = nil;
    _singleTapRecognizer = nil;
    _pinchRecognizer = nil;
    _longPressRecognizer = nil;
    _doubleTapEmptyRecognizer = nil;
}

#pragma mark notification process

- (void)onDocumentChanged:(NSNotification *)noti
{
    [self loadCompelete];
}

-(NSString *)getTableContents
{
    NSMutableArray<PDFOutline *> *arrTableOfContents = [[NSMutableArray alloc] init];

    if (_pdfDocument && _pdfDocument.outlineRoot) {
        PDFOutline *currentRoot = _pdfDocument.outlineRoot;
        NSMutableArray<PDFOutline *> *stack = [[NSMutableArray alloc] init];
        [stack addObject:currentRoot];

        while (stack.count > 0) {
            PDFOutline *currentOutline = stack.lastObject;
            [stack removeLastObject];

            if (currentOutline.label.length > 0) {
                [arrTableOfContents addObject:currentOutline];
            }

            for (NSInteger i = currentOutline.numberOfChildren; i > 0; i--) {
                [stack addObject:[currentOutline childAtIndex:i - 1]];
            }
        }
    }

    NSMutableArray *arrParentsContents = [[NSMutableArray alloc] init];

    for (NSInteger i = 0; i < arrTableOfContents.count; i++) {
        PDFOutline *currentOutline = [arrTableOfContents objectAtIndex:i];

        NSInteger indentationLevel = -1;
        PDFOutline *parentOutline = currentOutline.parent;

        while (parentOutline != nil) {
            indentationLevel += 1;
            parentOutline = parentOutline.parent;
        }

        if (indentationLevel == 0) {
            NSMutableDictionary *DXParentsContent = [[NSMutableDictionary alloc] init];

            [DXParentsContent setObject:[[NSMutableArray alloc] init] forKey:@"children"];
            [DXParentsContent setObject:@"" forKey:@"mNativePtr"];
            [DXParentsContent setObject:[NSString stringWithFormat:@"%lu", [_pdfDocument indexForPage:currentOutline.destination.page]] forKey:@"pageIdx"];
            [DXParentsContent setObject:currentOutline.label forKey:@"title"];

            [arrParentsContents addObject:DXParentsContent];
        } else {
            NSMutableDictionary *DXParentsContent = [arrParentsContents lastObject];
            NSMutableArray *arrChildren = [DXParentsContent valueForKey:@"children"];

            while (indentationLevel > 1) {
                NSMutableDictionary *DXchild = [arrChildren lastObject];
                arrChildren = [DXchild valueForKey:@"children"];
                indentationLevel--;
            }

            NSMutableDictionary *DXChildContent = [[NSMutableDictionary alloc] init];
            [DXChildContent setObject:[[NSMutableArray alloc] init] forKey:@"children"];
            [DXChildContent setObject:@"" forKey:@"mNativePtr"];
            [DXChildContent setObject:[NSString stringWithFormat:@"%lu", [_pdfDocument indexForPage:currentOutline.destination.page]] forKey:@"pageIdx"];
            [DXChildContent setObject:currentOutline.label forKey:@"title"];
            [arrChildren addObject:DXChildContent];
        }
    }

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:arrParentsContents options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

- (void)onPageChanged:(NSNotification *)noti
{
    if (_pdfDocument) {
        PDFPage *currentPage = _pdfView.currentPage;
        unsigned long page = [_pdfDocument indexForPage:currentPage];
        unsigned long numberOfPages = _pdfDocument.pageCount;

        [self notifyOnChangeWithMessage:[[NSString alloc] initWithString:[NSString stringWithFormat:@"pageChanged|%lu|%lu", page + 1, numberOfPages]]];
    }
}

- (void)onScaleChanged:(NSNotification *)noti
{
    if (_initialed && _fixScaleFactor > 0) {
        if (_scale != _pdfView.scaleFactor / _fixScaleFactor) {
            _scale = _pdfView.scaleFactor / _fixScaleFactor;
            [self notifyOnChangeWithMessage:[[NSString alloc] initWithString:[NSString stringWithFormat:@"scaleChanged|%f", _scale]]];
            [self pdfSizeChanged];
        }
    }
}

#pragma mark gesture process

- (void)handleDoubleTapEmpty:(UITapGestureRecognizer *)recognizer {}

- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_pdfView clearSelection];
    });

    if (!_enableDoubleTapZoom) return;

    float min = self->_pdfView.minScaleFactor / self->_fixScaleFactor;
    float max = self->_pdfView.maxScaleFactor / self->_fixScaleFactor;
    float mid = (max - min) / 2 + min;
    float scale = self->_scale;

    if (self->_scale < mid) scale = mid;
    else if (self->_scale < max) scale = max;
    else scale = min;

    CGFloat newScale = scale * self->_fixScaleFactor;
    CGPoint tapPoint = [recognizer locationInView:self->_pdfView];

    PDFPage *tappedPdfPage = [_pdfView pageForPoint:tapPoint nearest:NO];
    PDFPage *pageRef = tappedPdfPage ? tappedPdfPage : self->_pdfView.currentPage;
    tapPoint = [self->_pdfView convertPoint:tapPoint toPage:pageRef];

    CGRect tempZoomRect = CGRectZero;
    tempZoomRect.size.width = self->_pdfView.frame.size.width;
    tempZoomRect.size.height = 1;
    tempZoomRect.origin = tapPoint;

    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            [self->_pdfView setScaleFactor:newScale];

            [self->_pdfView goToRect:tempZoomRect onPage:pageRef];
            CGPoint defZoomOrigin = [self->_pdfView convertPoint:tempZoomRect.origin fromPage:pageRef];
            defZoomOrigin.x = defZoomOrigin.x - self->_pdfView.frame.size.width / 2;
            defZoomOrigin.y = defZoomOrigin.y - self->_pdfView.frame.size.height / 2;
            defZoomOrigin = [self->_pdfView convertPoint:defZoomOrigin toPage:pageRef];
            CGRect defZoomRect = CGRectOffset(
                tempZoomRect,
                defZoomOrigin.x - tempZoomRect.origin.x,
                defZoomOrigin.y - tempZoomRect.origin.y
            );
            [self->_pdfView goToRect:defZoomRect onPage:pageRef];

            [self setNeedsDisplay];
            [self onScaleChanged:nil];
        }];
    });
}

- (void)handleSingleTap:(UITapGestureRecognizer *)sender
{
    CGPoint point = [sender locationInView:self];
    PDFPage *pdfPage = [_pdfView pageForPoint:point nearest:NO];
    if (pdfPage) {
        unsigned long page = [_pdfDocument indexForPage:pdfPage];
        [self notifyOnChangeWithMessage:
         [[NSString alloc] initWithString:[NSString stringWithFormat:@"pageSingleTap|%lu|%f|%f", page + 1, point.x, point.y]]];
    }
}

-(void)handlePinch:(UIPinchGestureRecognizer *)sender
{
    [self onScaleChanged:nil];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        self.startPoint = [gestureRecognizer locationInView:self];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint pressPoint = [gestureRecognizer locationInView:self];

        if (CGPointEqualToPoint(pressPoint, self.startPoint)) {
            PDFPage *pdfPage = [_pdfView pageForPoint:pressPoint nearest:NO];
            if (pdfPage) {
                unsigned long page = [_pdfDocument indexForPage:pdfPage];
                [self notifyOnChangeWithMessage:
                 [[NSString alloc] initWithString:[NSString stringWithFormat:@"pageSingleTap|%lu|%f|%f|%@", page + 1, pressPoint.x, pressPoint.y, @"YES"]]];
            }
        }
    }
}

- (void)bindTap
{
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.numberOfTouchesRequired = 1;
    doubleTapRecognizer.delegate = self;
    [self addGestureRecognizer:doubleTapRecognizer];
    _doubleTapRecognizer = doubleTapRecognizer;

    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTapRecognizer.numberOfTapsRequired = 1;
    singleTapRecognizer.numberOfTouchesRequired = 1;
    singleTapRecognizer.delegate = self;
    [self addGestureRecognizer:singleTapRecognizer];
    _singleTapRecognizer = singleTapRecognizer;

    [singleTapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];

    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    pinchRecognizer.delegate = self;
    [self addGestureRecognizer:pinchRecognizer];
    _pinchRecognizer = pinchRecognizer;

    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPressRecognizer.allowableMovement = 100;
    longPressRecognizer.minimumPressDuration = 0.3;
    longPressRecognizer.delegate = self;
    [self addGestureRecognizer:longPressRecognizer];
    _longPressRecognizer = longPressRecognizer;

    // Observe scroll position
    for (UIView *subview in _pdfView.subviews) {
        if ([subview isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = (UIScrollView *)subview;
            [scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        }
    }

    // Override the _pdfView double tap gesture recognizer so that it doesn't conflict with custom double tap
    UITapGestureRecognizer *doubleTapEmptyRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapEmpty:)];
    doubleTapEmptyRecognizer.numberOfTapsRequired = 2;
    [_pdfView addGestureRecognizer:doubleTapEmptyRecognizer];
    _doubleTapEmptyRecognizer = doubleTapEmptyRecognizer;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"] && [object isKindOfClass:[UIScrollView class]]) {
        CGPoint newContentOffset = [[change valueForKey:NSKeyValueChangeNewKey] CGPointValue];
        [self notifyOnChangeWithMessage:
         [[NSString alloc] initWithString:[NSString stringWithFormat:@"onScroll|%f|%f", newContentOffset.x, newContentOffset.y]]];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return !_singlePage;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return !_singlePage;
}

// Upstream helper: apply indicators even if scrollviews are nested
- (void)setScrollIndicators:(UIView *)view horizontal:(BOOL)horizontal vertical:(BOOL)vertical depth:(int)depth
{
    if (depth > 10) return;

    if ([view isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)view;
        scrollView.showsHorizontalScrollIndicator = horizontal;
        scrollView.showsVerticalScrollIndicator = vertical;
    }

    for (UIView *subview in view.subviews) {
        [self setScrollIndicators:subview horizontal:horizontal vertical:vertical depth:depth + 1];
    }
}

@end

#ifdef RCT_NEW_ARCH_ENABLED
Class<RCTComponentViewProtocol> RNPDFPdfViewCls(void)
{
    return RNPDFPdfView.class;
}
#endif