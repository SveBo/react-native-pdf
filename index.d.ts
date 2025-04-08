/**
 * Copyright (c) 2017-present, Wonday (@wonday.org)
 * All rights reserved.
 *
 * This source code is licensed under the MIT-style license found in the
 * LICENSE file in the root directory of this source tree.
 */
 
import * as React from 'react';
import * as ReactNative from 'react-native';
 
export type TableContent = {
    children: TableContent[],
    mNativePtr: number,
    pageIdx: number,
    title: string,
};
 
export type Source = {
    uri?: string;
    headers?: {
        [key: string]: string;
    };
    cache?: boolean;
    cacheFileName?: string;
    expiration?: number;
    method?: string;
};
 
export interface PdfProps {
    style?: ReactNative.StyleProp<ReactNative.ViewStyle>,
    progressContainerStyle?: ReactNative.StyleProp<ReactNative.ViewStyle>,
    source: Source | number,
    page?: number,
    scale?: number,
    minScale?: number,
    maxScale?: number,
    horizontal?: boolean,
    showsHorizontalScrollIndicator?: boolean,
    showsVerticalScrollIndicator?: boolean,
    scrollEnabled?: boolean,
    spacing?: number,
    password?: string,
    renderActivityIndicator?: (progress: number) => React.ReactElement,
    enableAntialiasing?: boolean,
    enablePaging?: boolean,
    enableRTL?: boolean,
    enableAnnotationRendering?: boolean,
    enableDoubleTapZoom?: boolean;
    /**
     * Fit policy.  This will adjust the initial zoom of the PDF based on the initial size of the view and the scale factor.
     * 0 = fit width
     * 1 = fit height
     * 2 = fit both
     */
    fitPolicy?: 0 | 1 | 2,
    trustAllCerts?: boolean,
    singlePage?: boolean,
    onLoadProgress?: (percent: number,) => void,
    onPdfSizeChanged?: (width: number, height: number) => void,
    onLoadComplete?: (numberOfPages: number, path: string, tableContents?: TableContent[]) => void,
    onPageChanged?: (page: number, numberOfPages: number) => void,
    onError?: (error: object) => void,
    onScroll?: (x: number, y: number) => void,
    onPageSingleTap?: (page: number, x: number, y: number, isLongPress: boolean) => void,
    onScaleChanged?: (scale: number) => void,
    onPressLink?: (url: string) => void,
    initialXOffset?: number,
    initialYOffset?: number,
}
 
 
declare class Pdf extends React.Component<PdfProps, any> {
    moveTo: (x: number, y: number, scale: number) => void;
    resetZoom: () => void;
    setPage: (pageNumber: number) => void;
}
 
export default Pdf;