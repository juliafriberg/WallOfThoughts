
//
//  PlaceViewController.swift
//  testDrawing
//
//  Created by Julia Friberg on 2016-09-28.
//  Copyright © 2016 Julia Friberg. All rights reserved.
//
import GLKit
import UIKit
import FirebaseDatabase

class PlaceViewController: GLKViewController {
    
    @IBOutlet weak var imageContainer: UIImageView!
    
    var image: UIImage?
    var panoramaView = PanoramaView.shared()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Thought image
        if let image = image {
            imageContainer.frame = CGRect(x: (UIScreen.main.bounds.width/2-image.size.width/8), y: (UIScreen.main.bounds.height/2-image.size.height/8), width: image.size.width/4, height: image.size.height/4)
            imageContainer.image = image
        }
        let borderLayer  = dashedBorderLayerWithColor(color: UIColor.black.cgColor)
        imageContainer.layer.addSublayer(borderLayer)
        imageContainer.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        
        self.view = panoramaView
        self.view.addSubview(imageContainer)
    }
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        panoramaView?.draw()
    }
    
    func dashedBorderLayerWithColor(color:CGColor) -> CAShapeLayer {
        
        let  borderLayer = CAShapeLayer()
        borderLayer.name  = "borderLayer"
        let frameSize = imageContainer.frame.size
        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
        
        borderLayer.bounds=shapeRect
        borderLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = color
        borderLayer.lineWidth=1
        borderLayer.lineJoin=kCALineJoinRound
        borderLayer.lineDashPattern = NSArray(array: [NSNumber(value: 8),NSNumber(value:4)]) as? [NSNumber]
        
        let path = UIBezierPath.init(roundedRect: shapeRect, cornerRadius: 0)
        
        borderLayer.path = path.cgPath
        
        return borderLayer
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        imageContainer.removeFromSuperview()
        self.view = GLKView()
        
        if segue.identifier == "showWall" {
            //Upload image
            var ref: FIRDatabaseReference!
            ref = FIRDatabase.database().reference()
            
            let x = imageContainer.center.x - imageContainer.frame.size.width/2
            let y = imageContainer.center.y - imageContainer.frame.size.height/2
            let vector = panoramaView?.vector(fromScreenLocation: CGPoint(x: x, y: y))
            
            let xPos : String = String(describing: vector!.v.0)
            let yPos : String = String(describing: vector!.v.1)
            let zPos : String = String(describing: vector!.v.2)
            let uploadImage: String = (UIImagePNGRepresentation(image!)?.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters))!
            
            let imageInfo = ["x": xPos, "y": yPos, "z": zPos, "image": uploadImage]
            
            let key = ref.child("images").childByAutoId()
            key.setValue(imageInfo)
        }
    }
    
    
    
}
