//
//  ImageViewVC.swift
//  Boundri IOS
//
//  Created by Tanner York on 6/22/20.
//  Copyright © 2020 Boundri. All rights reserved.
//

import UIKit
import MLKit

class ImageViewVC: UIViewController {
    
    //MARK: Properties
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageText: UITextView!

    var imageToPresent: UIImage!
    var visionOption: String!
    var frameSublayer = CALayer()
    
    
//    fileprivate var showNetworkActivityIndicator = false {
//        didSet {
//            UIApplication.shared.isNetworkActivityIndicatorVisible = showNetworkActivityIndicator
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = imageToPresent
        
        //MARK: Google OCR
        let image = self.imageView.image!
        let visionImage = VisionImage(image: image)
        visionImage.orientation = image.imageOrientation
        
        if visionOption == "scene" {
            let options = ImageLabelerOptions()
            options.confidenceThreshold = 0.8
            let labeler = ImageLabeler.imageLabeler(options: options)
            
            var label_arr: [String] = []
            labeler.process(visionImage) { labels, error in
                guard error == nil, let labels = labels else { return }
                print(labels)
                for label in labels { label_arr.append(label.text) }
                self.imageText.text = label_arr.joined(separator: ", ")
            }
            
        } else if visionOption == "text" {
            let textRecognizer = TextRecognizer.textRecognizer()
            textRecognizer.process(visionImage) { result, error in
                guard error == nil, let result = result else { return }
                // Recognized text
                self.imageText.text = result.text
            }
        } else {
            self.imageText.text = "Error: Did not receive vision option."
        }
        
    }
        
    
    
    //MARK: FrameView
    /// Converts a feature frame to a frame UIView that is displayed over the image.
    ///
    /// - Parameters:
    ///   - featureFrame: The rect of the feature with the same scale as the original image.
    ///   - imageSize: The size of original image.
    ///   - viewRect: The view frame rect on the screen.
    private func addFrameView(featureFrame: CGRect, imageSize: CGSize, viewFrame: CGRect, text: String? = nil) {
        print("Frame: \(featureFrame).")
        
        let viewSize = viewFrame.size
        
        // Find resolution for the view and image
        let rView = viewSize.width / viewSize.height
        let rImage = imageSize.width / imageSize.height
        
        // Define scale based on comparing resolutions
        var scale: CGFloat
        if rView > rImage {
            scale = viewSize.height / imageSize.height
        } else {
            scale = viewSize.width / imageSize.width
        }
        
        // Calculate scaled feature frame size
        let featureWidthScaled = featureFrame.size.width * scale
        let featureHeightScaled = featureFrame.size.height * scale
        
        // Calculate scaled feature frame top-left point
        let imageWidthScaled = imageSize.width * scale
        let imageHeightScaled = imageSize.height * scale
        
        let imagePointXScaled = (viewSize.width - imageWidthScaled) / 2
        let imagePointYScaled = (viewSize.height - imageHeightScaled) / 2
        
        let featurePointXScaled = imagePointXScaled + featureFrame.origin.x * scale
        let featurePointYScaled = imagePointYScaled + featureFrame.origin.y * scale
        
        // Define a rect for scaled feature frame
        let featureRectScaled = CGRect(x: featurePointXScaled,
                                       y: featurePointYScaled,
                                       width: featureWidthScaled,
                                       height: featureHeightScaled)
        
        drawFrame(featureRectScaled, text: text)
    }
    
    /// Creates and draws a frame for the calculated rect as a sublayer.
    ///
    /// - Parameter rect: The rect to draw.
    private func drawFrame(_ rect: CGRect, text: String? = nil) {
        let bpath: UIBezierPath = UIBezierPath(rect: rect)
        let rectLayer: CAShapeLayer = CAShapeLayer()
        rectLayer.path = bpath.cgPath
        rectLayer.strokeColor = Constants.lineColor
        rectLayer.fillColor = Constants.fillColor
        rectLayer.lineWidth = Constants.lineWidth
        if let text = text {
            let textLayer = CATextLayer()
            textLayer.string = text
            textLayer.fontSize = 12.0
            textLayer.foregroundColor = Constants.lineColor
            let center = CGPoint(x: rect.midX, y: rect.midY)
            textLayer.position = center
            textLayer.frame = rect
            textLayer.alignmentMode = CATextLayerAlignmentMode.center
            textLayer.contentsScale = UIScreen.main.scale
            frameSublayer.addSublayer(textLayer)
        }
        frameSublayer.addSublayer(rectLayer)
    }
    
    private func removeFrames() {
        guard let sublayers = frameSublayer.sublayers else { return }
        for sublayer in sublayers {
            guard let frameLayer = sublayer as CALayer? else {
                print("Failed to remove frame layer.")
                continue
            }
            frameLayer.removeFromSuperlayer()
        }
    }
    
    
}

fileprivate enum Constants {
    static let labelConfidenceThreshold: Float = 0.75
    static let lineWidth: CGFloat = 3.0
    static let lineColor = UIColor.yellow.cgColor
    static let fillColor = UIColor.clear.cgColor
}
