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
    //this is some controller that you present to the  user and they are embedded into navigation controller
    private let imagePickerController = UIImagePickerController()
    //Where we are saving this
    private let dataPersistence = PersistenceHelper(filename: "photoJournal.plist")
    
    private var selectedImage: UIImage? {
        didSet {
            //gets Property Observer called when new image is selected. So anytime I change my image i want to insert my photo in the collectionview
            //there is no dispatch main CAUSE WE ARE NOT DOING ANY ASYCHRONOUS CALLS
            appendNewPhotoToCollection()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        //this is an instance of picker controller and who is listening I am listening- keep in mind you can have the delegate object somewhere else. You need to conform to 2 protocols inorder to use this which is UI
        imagePickerController.delegate = self
    }
    
    private func loadImageObjects() {
          do {
              photoObjects = try dataPersistence.loadEvents()
          } catch {
              print("loading objects error: \(error)")
          }
      }
      
      //we will use this to append the photo to the collection
      private func appendNewPhotoToCollection() {
          guard let image = selectedImage,//we take in this image(UIImage) and converting into data we use optional chaining
              //there is also a pngdata if you want to waste more space for the user. Jpeg is a formate cause you can change the compression quality the bigger the image the more space it takes. we are taking the image float value and turning it into data
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
    
    @IBAction func addPhotoButtonPressed(_ sender: UIBarButtonItem) {
        //present an action sheet to the user The actions will be camera, photo library or cancel. We will use an alert controller and change the type to action sheet instead of an alert. AN action sheet comes from the bottom and a alert comes from the middle of the page
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)//this is the controller you present
        //the UIAction alert is the ACTION (every button/options) you want to use inside your alertController
           let cameraAction = UIAlertAction(title: "Camera", style: .default) { [weak self] alertAction in //the completion handler is what to do  when the user clicks on the camera button. SO what do you want to do if the user clicks on the camera action
               self?.showImageController(isCameraSelected: true)
               
           }// the action is what you want to use
           //If you want to use some modifing action so we default but if you want it red alert then use .destructive such as to delete
           let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { [weak self] alertAction in
               //self?.showImageController(isCameraSelected: false)
           }
        //you NEED to have an Cancel action
           let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
           //check if camera is available, if camera is not available the app will crash, is the sourceType available
        //this ask if there is a comera available if the phone doesnt it wont crash
           if UIImagePickerController.isSourceTypeAvailable(.camera) {
               alertController.addAction(cameraAction)//so now its added
           }
           //Setting what the action sheet contains in the order we have it in
           alertController.addAction(photoLibraryAction)
           alertController.addAction(cancelAction)
           present(alertController, animated: true)//Alert controller is the product//you can have a completion if you were presenting something after that
      
    }
    
    private func showImageController(isCameraSelected: Bool) {
             //if the user selected the camera and if they have a camera they change the sourcetype
             //We need access to the camera
             //create an instance of the object that we want to use (ImagePickerController)
             //sourcetype(what is the user selecting from) default will be .photolibrary
             
             
             if isCameraSelected {
                 imagePickerController.sourceType = .camera
                 
             } else {
                 imagePickerController.sourceType = .photoLibrary
             }
             present(imagePickerController, animated: true)
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

//You need this delegate and since the button is on the navigation controller therefor you need UIIMagePickerControllerDelegate AND UINavigationController. Its responsible for alerting us with 2 actions.  1 the user picks an image or movie  and did the user clicks cancel.
extension PhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    //this is how we get the picture inside that dictionary
    //when you writing custom delegation you need to pass that picker OBJECT WITH THE SAME OR SIMILAR NAME SO the complier knows
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //we need to access the UIImagePickerController.InfoKey.originalImage key to get the UIImage that was selected
        //Since we are dealing with the dictionary we are dealing with a value type and its an optional so we  need a guard statement. info is that dictionary
        //this is the key to the object that the user selected and info is that dictionary and we dont want it cropped or live photo only the original image
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { //here you downcast to the object
            print("image selected not found")
            return  //you only want to fatal error for developer related things so in this case just use return or print statement
        }
        selectedImage = image //If I dont do this my image will always be nil
        dismiss(animated: true)
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
