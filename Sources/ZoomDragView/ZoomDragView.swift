//
//  ZoomDragView.swift
//  ZoomDragView
//
//  Created by 間嶋大輔 on 2023/06/14.
//

import UIKit

public class ZoomDragView: UIView {
    public var zoomScale:CGFloat! {
        didSet {
            scale = 0.4/zoomScale
        }
    }
    var scale = 0.2

    var touchPointView = PointView()
    public var touchPointColor:UIColor? {
        didSet {
            touchPointView.setTouchPointColor(color: touchPointColor)
        }
    }

    public override var backgroundColor: UIColor? {
        didSet {
            if let backgroundColor = backgroundColor {
                backgroundImageColor = backgroundColor
            } else {
                backgroundImageColor = .white
            }
            if let image = image {
                blackImage = UIImage(color: backgroundImageColor,size: CGSize(width: image.size.width*2, height: image.size.height*2))
            }
        }
    }
    public var backgroundImageColor = UIColor.white
    public var image: UIImage? {
        didSet {
            guard let image = image else {return}
            imageView.image = image
            imageView.contentMode = .scaleAspectFill
            let imageSize = image.size
            let aspect = imageSize.height/imageSize.width
            let imageViewHeight = self.bounds.width * aspect
            imageView.frame = CGRect(x: 0, y: self.center.y - imageViewHeight / 2, width: self.bounds.width, height: imageViewHeight)
            imageView.backgroundColor = .clear
            
            zoomViewFrameLeft = CGRect(x: imageView.bounds.width * 0.05, y: imageView.bounds.width * 0.05, width: imageView.bounds.width * 0.4, height: imageView.bounds.width * 0.4)
            zoomViewFrameRight = CGRect(x: imageView.center.x+imageView.bounds.width * 0.05, y: imageView.bounds.width * 0.05, width: imageView.bounds.width * 0.4, height: imageView.bounds.width * 0.4)
            zoomView.clipsToBounds = true
//            zoomView.layer.cornerRadius = imageView.bounds.width * 0.4 / 2
            imageView.addSubview(zoomView)
            zoomView.backgroundColor = .clear
            zoomView.layer.borderColor = UIColor.black.cgColor
            zoomView.layer.borderWidth = 3
            blackImage = UIImage(color: backgroundImageColor,size: CGSize(width: imageSize.width*2, height: imageSize.height*2))
            touchPointView.frame = CGRect(x: 0, y: 0, width: self.bounds.width*0.025, height: self.bounds.width*0.025)
            touchPointView.setNeedsDisplay()
            touchPointView.isHidden = true
        }
    }
    var imageView = UIImageView()
    var zoomView = UIImageView()
    var zoomViewFrameLeft = CGRect.zero
    var zoomViewFrameRight = CGRect.zero
    var moving = false
    var blackImage:UIImage!

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.zoomScale = 2
        self.touchPointColor = .red
        self.backgroundColor = .clear
        self.addSubview(imageView)
        self.addSubview(zoomView)
        imageView.addSubview(touchPointView)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func touchingAction(touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        guard let image = image else {return}
        if !moving {
            moving = true
        let location = touch.location(in: imageView)
        touchPointView.isHidden = false
        touchPointView.center = location
        if location.x < imageView.center.x {
            zoomView.frame = zoomViewFrameRight
        } else {
            zoomView.frame = zoomViewFrameLeft
        }
        
        zoomView.isHidden = false
        let imageSize = image.size
        let normalizedLocation = CGPoint(x: location.x/imageView.bounds.width, y: location.y/imageView.bounds.height)
        let locationInImage = CGPoint(x:normalizedLocation.x * imageSize.width,y: normalizedLocation.y * imageSize.height)
        var croppedImage:UIImage!
        var cropRect = CGRect(x: locationInImage.x-imageSize.width*(scale/2), y: locationInImage.y-imageSize.width*(scale/2), width: imageSize.width*scale, height: imageSize.width*scale)
        if cropRect.minX < 0 || cropRect.maxX > image.size.width || cropRect.minY < 0 || cropRect.maxY > image.size.height {
            cropRect = CGRect(x: locationInImage.x+(blackImage.size.width-imageSize.width*(scale/2)-imageSize.width)/2, y: locationInImage.y+(blackImage.size.height-imageSize.height*(scale/2)-imageSize.height)/2, width: imageSize.width*scale, height: imageSize.width*scale)
            
            let compositeImage = blackImage.composite(image: image)
            croppedImage = compositeImage!.crop(cropRect: cropRect)
        } else {
            croppedImage = image.crop(cropRect: cropRect)
        }
        let circleInZoomImage = 0.025/0.4
        if let touchPointColor = touchPointColor {
            guard let zoomCircleImage = croppedImage?.drawCircleInImageCenter(normalizedCircleWidth: circleInZoomImage,touchPointColor: touchPointColor) else {moving = false;return}
            zoomView.image = zoomCircleImage
        } else {
            zoomView.image = croppedImage
        }
        moving = false
        }
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchingAction(touches: touches)
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchingAction(touches: touches)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        zoomView.isHidden = true
        touchPointView.isHidden = true
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

public extension UIImage {
  convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
    let rect = CGRect(origin: .zero, size: size)
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 1)
    color.setFill()
    UIRectFill(rect)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    guard let cgImage = image?.cgImage else { return nil }
    self.init(cgImage: cgImage)
  }
    
    func composite(image:UIImage) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, false, 1)
        self.draw(in: CGRect(origin: CGPoint.zero, size: self.size))
        let frontRect = CGRect(x: (self.size.width-image.size.width)/2, y:  (self.size.height-image.size.height)/2, width: image.size.width, height: image.size.height)
        image.draw(in: frontRect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }
    
    func crop(cropRect:CGRect)->UIImage? {
        if let cgImage = self.cgImage?.cropping(to: cropRect) {
            return UIImage(cgImage: cgImage)
        }
        
        return nil

    }
    
    func drawCircleInImageCenter(normalizedCircleWidth:CGFloat,touchPointColor:UIColor)->UIImage? {
        guard let cgImage = self.cgImage else {return nil}
        let size = CGSize(width: cgImage.width, height: cgImage.height)
        guard let cgContext = CGContext(data: nil,
                                        width: Int(size.width),
                                        height: Int(size.height),
                                        bitsPerComponent: 8,
                                        bytesPerRow: 4 * Int(size.width),
                                        space: CGColorSpaceCreateDeviceRGB(),
                                        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
        cgContext.draw(cgImage, in: CGRect(origin: .zero, size: size))

        let denormalizedCircleWidth = self.size.width * normalizedCircleWidth
        let circleRect = CGRect(x: self.size.width/2-denormalizedCircleWidth/2, y: self.size.height/2-denormalizedCircleWidth/2, width: denormalizedCircleWidth, height: denormalizedCircleWidth)
//        let path = UIBezierPath(ovalIn: circleRect)
        cgContext.addEllipse(in: circleRect)
        cgContext.setStrokeColor(touchPointColor.cgColor)
        cgContext.setFillColor(touchPointColor.cgColor)

        cgContext.drawPath(using: .fillStroke)
        cgContext.strokePath()
        cgContext.fillEllipse(in: circleRect)
        guard let newImage = cgContext.makeImage() else { return nil }
        return UIImage(ciImage: CIImage(cgImage: newImage))
    }
    
    func resize(size _size: CGSize) -> UIImage? {
        let widthRatio = _size.width / size.width
        let heightRatio = _size.height / size.height
        let ratio = widthRatio < heightRatio ? widthRatio : heightRatio

        let resizedSize = CGSize(width: size.width * ratio, height: size.height * ratio)

        UIGraphicsBeginImageContextWithOptions(resizedSize, false, 0.0) // 変更
        draw(in: CGRect(origin: .zero, size: resizedSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resizedImage
    }
}

class PointView: UIView {
    var touchPointColor:UIColor? = UIColor.red
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func draw(_ rect: CGRect) {
        if let touchPointColor = touchPointColor {
            let circle = UIBezierPath(ovalIn: self.bounds)
            touchPointColor.setFill()
            touchPointColor.setStroke()
            circle.fill()
            circle.stroke()
        }
    }
    
    func setTouchPointColor(color:UIColor?) {
        self.touchPointColor = color
        self.setNeedsDisplay()
    }
    
    
}
