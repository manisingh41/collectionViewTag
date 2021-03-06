/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

protocol AddBarCVLayoutDelegate: class {
  // 1. Method to ask the delegate for the height of the image
  func collectionView(_ collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat
    func collectionView(_ collectionView:UICollectionView, widthForTagAtIndexPath indexPath:IndexPath) -> CGFloat
}

class AddBarCVLayout: UICollectionViewLayout {
  //1. Pinterest Layout Delegate
  weak var delegate: AddBarCVLayoutDelegate!
  
  //2. Configurable properties
  fileprivate var numberOfRows = 3
  fileprivate var cellPadding: CGFloat = 0.1
  
  //3. Array to keep a cache of attributes.
  fileprivate var cache = [UICollectionViewLayoutAttributes]()
  
  //4. Content height and size
    fileprivate var contentHeight: CGFloat = 0
  
  fileprivate var contentWidth: CGFloat = 0
  
  override var collectionViewContentSize: CGSize {
    return CGSize(width: contentWidth, height: (collectionView?.contentSize.height)!)
  }
  
  override func prepare() {
    // 1. Only calculate once
    guard cache.isEmpty == true, let collectionView = collectionView else {
      return
    }
    // 2. Pre-Calculates the X Offset for every column and adds an array to increment the currently max Y Offset for each column
   // let columnWidth = contentWidth / CGFloat(numberOfColumns)
    var xOffset = [CGFloat](repeating: 0, count: numberOfRows)
//    for column in 0 ..< numberOfColumns {
//      xOffset.append(CGFloat(column) * columnWidth)
//    }
    var yOffset = [CGFloat]()
    for column in 0 ..< numberOfRows {
        yOffset.append((CGFloat(column) * 40.0))
    }
    var column = 0
    //var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
    
    // 3. Iterates through the list of items in the first section
    var width:CGFloat = 0.0
    for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
      
      let indexPath = IndexPath(item: item, section: 0)
      
      // 4. Asks the delegate for the height of the picture and the annotation and calculates the cell frame.
      let photoHeight = delegate.collectionView(collectionView, heightForPhotoAtIndexPath: indexPath)
      let height = cellPadding * 1 + photoHeight
        
        let tagwidth = delegate.collectionView(collectionView, widthForTagAtIndexPath: indexPath)
        
      let frame = CGRect(x: xOffset[column], y: yOffset[column], width: tagwidth, height: height)
        width = tagwidth

        //print("current frame of cell is:",frame)
      let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
      
      // 5. Creates an UICollectionViewLayoutItem with the frame and add it to the cache
      let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
      attributes.frame = insetFrame
      cache.append(attributes)
      // 6. Updates the collection view content height
        
        
        
//      contentHeight = max(contentHeight, frame.maxY)
//      yOffset[column] = yOffset[column] + height
        contentWidth = max(contentWidth, frame.maxX)
        xOffset[column] = xOffset[column] + width
      column = column < (numberOfRows - 1) ? (column + 1) : 0
        
//        if column == 0
//        {
//            xOffset[column] = 0.0
//        }
//        else
//        {
//            xOffset[column] = xOffset[column] + width
//        }
    }
  }
  
  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    
    var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
    
    // Loop through the cache and look for items in the rect
    for attributes in cache {
      if attributes.frame.intersects(rect) {
        visibleLayoutAttributes.append(attributes)
      }
    }
    return visibleLayoutAttributes
  }
  
  override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    return cache[indexPath.item]
  }
  
    

    
}
