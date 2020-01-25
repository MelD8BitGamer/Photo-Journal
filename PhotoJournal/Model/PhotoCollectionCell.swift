//
//  PhotoCollection.swift
//  PhotoJournal
//
//  Created by Melinda Diaz on 1/23/20.
//  Copyright © 2020 Melinda Diaz. All rights reserved.
//

import UIKit


//step 1: creating custom delegation - define protocol
protocol PhotoCellDelegate: AnyObject {//AnyObject requires ImageCellDelegate only works class types
    //list required functions, initializers, variables
    func didLongPress(_ imageCell: PhotoCollectionCell)
    
    }
    

class PhotoCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var photoNameGiven: UILabel!
    @IBOutlet weak var photoDateTaken: UILabel!
    @IBOutlet weak var photoReceived: UIImageView!
    
  //step2: creating custom delegation: - define optional delegate variable
        weak var delegate: PhotoCellDelegate?
        
        //setup long pressed gesture recognizer
        //step 1 long press setup
        private lazy var longPressGesture: UILongPressGestureRecognizer = {
            let gesture = UILongPressGestureRecognizer()
            gesture.addTarget(self, action: #selector(longPressAction(gesture:)))
            return gesture
        }()
        
        override func layoutSubviews() {
            super.layoutSubviews()
            layer.cornerRadius = 20.0
            backgroundColor = .orange
            //step 3: long press set up - added gesture to view
            addGestureRecognizer(longPressGesture)
        }
        //step 2 long press setup
        //function gets called when long press is activated
        @objc
        private func longPressAction(gesture: UILongPressGestureRecognizer) {
            if gesture.state == .began { //if gesture is activated
                gesture.state = .cancelled
                return
            }
            print("long pressed activated")
            //step 3: creating custom delegation - explicity use delegate object to notify of anyupdate eg. notifying the ImagesViewController when the user long presses on the cell
            delegate?.didLongPress(self)
            //imagesViewController -> didLongPress(:) this is very similar . the view controller has a didlongpress function and in that function you have access to the cell
        }
        public func configureCell(imageObject: ImageObject) {
            guard let image = UIImage(data: imageObject.imageData) else {
                return
            }
            photoReceived.image = image
        }
    }

