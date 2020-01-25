//
//  ViewController.swift
//  PhotoJournal
//
//  Created by Melinda Diaz on 1/23/20.
//  Copyright © 2020 Melinda Diaz. All rights reserved.
//

import UIKit
import AVFoundation

class PhotoViewController: UIViewController {
    
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    //This is an instance of ImageObject back in our Model
    private var photoObjects = [ImageObject]()
    private let imagePickerController = UIImagePickerController()
    //Where we are saving this
    private let dataPersistence = PersistenceHelper(filename: "photoJournal.plist")
    
    private var selectedImage: UIImage? {
        didSet {
            //gets Property Observer called when new image is selected
            //there is no dispatch main CAUSE WE ARE NOT DOING ANY ASYCHRONOUS CALLS
            appendNewPhotoToCollection()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    private func loadImageObjects() {
        do {
            photoObjects = try dataPersistence.loadEvents()
        } catch {
            print("loading objects error: \(error)")
        }
    }
    
    private func appendNewPhotoToCollection() {
        guard let image = selectedImage,//we take in this image(UIImage) and converting into data we use optional chaining
            //there is also a pngdata if you want to waste more space for the user
            let imageData = image.jpegData(compressionQuality: 1.0) else {
                print("image is nil")
                return
        }
    }
    private func appendNewPhotoCollection() {
        guard let image = selectedImage else {
            print("")
            return
        }
        
        
        let size = UIScreen.main.bounds.size
        let rect = AVMakeRect(aspectRatio: image.size, insideRect: CGRect(origin: CGPoint.zero, size: size))
        let resizedImage = image.resizeImage(to: rect.size.width, height: rect.size.height)
        guard let resizedImageData = resizedImage.jpegData(compressionQuality: 1.0) else {
            print()
            return
        }
        //we need to create an imageObjects using the image selected
        let imageObject = ImageObject(imageData: resizedImageData, date: Date())
        
        //insert new image object into ImageObjects
        photoObjects.insert(imageObject, at: 0)
        //create an indexPath for insertion into collection View
        let indexPath = IndexPath(row: 0, section: 0)
        
        //insert new cell into collection view (this will be a smooth transition) dont reload the whole thing and you will not get a smooth animation
        photoCollectionView.insertItems(at: [indexPath])
        
        //persist image object to documents directory
        do {
            try dataPersistence.create(item: imageObject)
        } catch {
            print("saving error: \(error)")
        }
    }
}


extension UIImage {
    func resizeImage(to width: CGFloat, height: CGFloat) -> UIImage {
        let size = CGSize(width: width, height: height)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (context) in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
