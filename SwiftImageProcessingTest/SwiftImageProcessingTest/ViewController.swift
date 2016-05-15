//
//  ViewController.swift
//  SwiftImageProcessingTest
//
//  Created by 劉柏賢 on 2016/5/8.
//  Copyright © 2016年 劉柏賢. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var sourceImageView: UIImageView!
    @IBOutlet weak var destImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    var width: Int = 0
    var height: Int = 0
    
    func getRGBA(image: UIImage) -> UnsafeMutableBufferPointer<Pixel>?
    {
        guard let cgImage = image.CGImage else {
            return nil
        }
        
        // 1
        width = Int(image.size.width)
        height = Int(image.size.height)
        
        let bitsPerComponent = 8
        
        // 2
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        let imageData = UnsafeMutablePointer<Pixel>.alloc(width * height)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        // 3
        var bitmapInfo: UInt32 = CGBitmapInfo.ByteOrder32Big.rawValue
        bitmapInfo |= CGImageAlphaInfo.PremultipliedLast.rawValue & CGBitmapInfo.AlphaInfoMask.rawValue
        
        guard let imageContext = CGBitmapContextCreate(imageData, width, height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo) else {
            return nil
        }
        
        CGContextDrawImage(imageContext, CGRect(origin: CGPointZero, size: image.size), cgImage)
        
        // 4
        let pixels = UnsafeMutableBufferPointer<Pixel>(start: imageData, count: width * height)
        
        return pixels
    }
    
    func getImage<T>(pixels: UnsafeMutableBufferPointer<T>) -> UIImage?
    {
        let bitsPerComponent = 8
        
        // 1
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        // 2
        var bitmapInfo: UInt32 = CGBitmapInfo.ByteOrder32Big.rawValue
        bitmapInfo |= CGImageAlphaInfo.PremultipliedLast.rawValue & CGBitmapInfo.AlphaInfoMask.rawValue
        let imageContext = CGBitmapContextCreateWithData(pixels.baseAddress, width, height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo, nil, nil)
        guard let cgImage = CGBitmapContextCreateImage(imageContext) else {
            pixels.baseAddress.destroy()
            pixels.baseAddress.dealloc(1)
            
            return nil
        }
        
        pixels.baseAddress.destroy()
        pixels.baseAddress.dealloc(1)
        
        // 3
        let image = UIImage(CGImage: cgImage)
        
        return image
    }
    
    /**
     Swift with Objective-C Bridge
     
     - parameter image: image description
     
     - returns: return value description
     */
    func bridgeProcess(image: UIImage) -> UIImage?
    {
        let data = ImageProcessing.getRGBAsFromImage(image)
        let width: Int = Int(image.size.width)
        let height: Int = Int(image.size.height)
        
        let bytesOfPixels = 4
        let ptr = UnsafeMutablePointer<UInt8>(data.bytes)
        let pixels = UnsafeMutableBufferPointer(start: ptr, count: data.length)
        
        for index in 0.stride(to: data.length, by: bytesOfPixels)
        {
            let r = index + 0
            let g = index + 1
            let b = index + 2
            _ = index + 3
            
            let value: Int = (Int(pixels[r]) + Int(pixels[g]) + Int(pixels[b])) / 3
            let color: UInt8 = value > 128 ? 255 : 0
            pixels[r] = color
            pixels[g] = color
            pixels[b] = color
            
            
        }
        
        var resultImage: UIImage?
        ImageProcessing.setImageFromData(data, width: UInt(width), height: UInt(height), destImage: &resultImage)
        
        return resultImage
    }
    
    /**
     Swift
     
     - parameter image: image description
     
     - returns: return value description
     */
    func process(image: UIImage) -> UIImage?
    {
        guard let pixels = getRGBA(image) else {
            return nil
        }
        
        for index in 0..<pixels.count
        {
            let value = (Int(pixels[index].red) + Int(pixels[index].green) + Int(pixels[index].blue)) / 3
            let color: UInt8 = value > 128 ? 255 : 0
            pixels[index].red = color
            pixels[index].green = color
            pixels[index].blue = color
            
            
            pixels[index].red = color
            pixels[index].green = color
            pixels[index].blue = color
        }
        
        let resultImage = getImage(pixels)
        return resultImage
    }
    
    @IBAction func handler(sender: UIButton) {
        
        let startTime = CACurrentMediaTime()
        
        guard let image = sourceImageView.image else {
            return
        }
        
        // Async
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { [weak self] in
            
            guard let weakSelf = self else {
                return
            }
            
//            let destImage = weakSelf.bridgeProcess(image)
            let destImage = weakSelf.process(image)
            
            // UI thread
            dispatch_async(dispatch_get_main_queue(), { 
                
                weakSelf.destImageView.image = destImage
                
                let sec = CACurrentMediaTime() - startTime
                
                weakSelf.timeLabel.text = String(format: "耗時:%.3f秒", sec)
                
            })
        }
        
    }
    
}


struct Pixel
{
    var red: UInt8
    var green: UInt8
    var blue: UInt8
    var alpha: UInt8
}