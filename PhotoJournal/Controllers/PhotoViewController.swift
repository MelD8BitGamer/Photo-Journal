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
    //This is an instance of ImageObject back in our Model an array of image objects
    private var photoObjects = [ImageObject]()
    var selectedPhoto: UIImage?
    //Where we are saving this
    private let dataPersistence = PersistenceHelper(filename: "photoJournal.plist")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
     
    }
    
    private func loadImageObjects() {
          do {
              photoObjects = try dataPersistence.loadEvents()
          } catch {
              print("loading objects error: \(error)")
          }
      }
      
      //TODO: Check this function why it does not work
    
      private func appendNewPhotoCollection() {
          guard let image = selectedPhoto else {
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
          let imageObject = ImageObject(imageData: resizedImageData, date: Date(), imageDescription: "")
          
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
    
    @IBAction func addPhotoButtonPressed(_ sender: UIBarButtonItem) {
        guard let uploadVC = storyboard?.instantiateViewController(identifier: "UploadViewController") as? UploadViewController else {
            fatalError("Could not segue")}
        navigationController?.pushViewController(uploadVC, animated: true)
    }

}

    extension PhotoViewController: UICollectionViewDataSource {
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return photoObjects.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            //step4: creating custom delegation: - must have an instance of object B
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCollectionCell else {
                fatalError("could not downcast to an PhotoCell")
            }
            let imageObject = photoObjects[indexPath.row]
            cell.configureCell(imageObject: imageObject)
            //step5: creating custom delegation - set delegate object, similar to tableView.delegate = self
           // cell.delegate = self
            return cell
        }
        
     
    }


extension PhotoViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //this gets the width of the device
        let maxWidth: CGFloat = UIScreen.main.bounds.size.width
        let itemWidth: CGFloat = maxWidth * 0.80 //and from the width of the device 80% will be the size of the cell
        return CGSize(width: itemWidth, height: itemWidth) //we made the height the same as the width to make a square }
    }
}


//step 6: creating custom delegation - conform to delegate
extension PhotoViewController: PhotoCellDelegate {
    func didLongPress(_ imageCell: PhotoCollectionCell) {
        print("Cell was selected")
        guard let indexPath = photoCollectionView.indexPath(for: imageCell) else {
            return
        }
        //present an action sheet
        
        //actions: delete, cancel
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] alertAction in
            self?.deleteImageObject(indexPath: indexPath)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
        
    }
    private func deleteImageObject(indexPath: IndexPath) {
        do {
            try dataPersistence.delete(event: indexPath.row)
            photoObjects.remove(at: indexPath.row)
            photoCollectionView.deleteItems(at: [indexPath])
        } catch {
            print("error deleting item: \(error)")
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
