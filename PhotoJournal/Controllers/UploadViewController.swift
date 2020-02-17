//
//  UploadViewController.swift
//  PhotoJournal
//
//  Created by Melinda Diaz on 1/23/20.
//  Copyright © 2020 Melinda Diaz. All rights reserved.
//

import UIKit
import AVFoundation
//TODO: fix the add Photo button it does not persist. fix textview
class UploadViewController: UIViewController {

    @IBOutlet weak var uploadTextView: UITextView!
    
    @IBOutlet weak var uploadedOrEditedPhoto: UIImageView!
    private var userText = ""
    
    //this is some controller that you present to the  user and they are embedded into navigation controller
     private let imagePickerController = UIImagePickerController()
    private var selectedImage: UIImage? {
           didSet {
               //gets Property Observer called when new image is selected. So anytime I change my image i want to insert my photo in the collectionview
               //there is no dispatch main CAUSE WE ARE NOT DOING ANY ASYCHRONOUS CALLS
               appendNewPhotoToCollection()
           }
       }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //this is an instance of picker controller and who is listening I am listening- keep in mind you can have the delegate object somewhere else. You need to conform to 2 protocols in order to use this which is UI
             imagePickerController.delegate = self
        uploadTextView.delegate = self
    }
    

    @IBAction func savePhotoPressed(_ sender: UIBarButtonItem) {
        appendNewPhotoToCollection()
    }
    

    @IBAction func addPhotoButtonPressed(_ sender: UIBarButtonItem) {
        selectPhoto()
    }
    //TODO: Camera not working COMPILER ERROR: simultaneously satisfy constraints.
    //Probably at least one of the constraints in the following list is one you don't want.
    @IBAction func cameraButtonPressed(_ sender: UIBarButtonItem) {
        
        imagePickerController.sourceType = .camera
        present(imagePickerController, animated: true)
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

    func selectPhoto() {
         
                //present an action sheet to the user The actions will be camera, photo library or cancel. We will use an alert controller and change the type to action sheet instead of an alert. AN action sheet comes from the bottom and a alert comes from the middle of the page
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)//this is the controller you present
                //the UIAction alert is the ACTION (every button/options) you want to use inside your alertController
                   let cameraAction = UIAlertAction(title: "Camera", style: .default) { [weak self] alertAction in //the completion handler is what to do  when the user clicks on the camera button. SO what do you want to do if the user clicks on the camera action
                       self?.showImageController(isCameraSelected: true)

                   }// the action is what you want to use
                   //If you want to use some modifing action so we default but if you want it red alert then use .destructive such as to delete
        
                   let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { [weak self] alertAction in
                       self?.showImageController(isCameraSelected: false)
                   }
        
                //you NEED to have an Cancel action
                   let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                   //check if camera is available, if camera is not available the app will crash, is the sourceType available
                //this ask if there is a comera available if the phone doesnt it wont crash
                   if UIImagePickerController.isSourceTypeAvailable(.camera) {
                       alertController.addAction(cameraAction)//so now its added
                   }
                   //Setting what the action sheet contains in the order we have it in
       
                    alertController.addAction(cameraAction)
                   alertController.addAction(photoLibraryAction)
                   alertController.addAction(cancelAction)
                   present(alertController, animated: true)//Alert controller is the product//you can have a completion if you were presenting something after that
        }
    private func appendNewPhotoToCollection() {
            guard let image = selectedImage,//we take in this image(UIImage) and converting into data we use optional chaining
                //there is also a pngdata if you want to waste more space for the user. Jpeg is a formate cause you can change the compression quality the bigger the image the more space it takes. we are taking the image float value and turning it into data
                let imageData = image.jpegData(compressionQuality: 1.0) else {
                    print("image is nil")
                    return
            }
        }
    }

//You need this delegate and since the button is on the navigation controller therefor you need UIIMagePickerControllerDelegate AND UINavigationController. Its responsible for alerting us with 2 actions.  1 the user picks an image or movie  and did the user clicks cancel.
extension UploadViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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

extension UploadViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        guard let text = textView.text else {
            //showAlert()
            return
        }
        userText = text
    }
}
