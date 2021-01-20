//
//  ViewController.swift
//  textRecognition
//
//  Created by 1 on 10/26/20.
//

import UIKit
import SnapKit
import Firebase

class ViewController: UIViewController {
    let processor = Processor()
    
    var scannedText: String = "Detected text can be edited here." {
      didSet {
        detectedText.text = scannedText
      }
    }
    
    lazy var cameraButton: UIBarButtonItem = {
        let cameraButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(cameraButtonTapped))
        return cameraButton
    }()
    
    lazy var imagePickerController: UIImagePickerController = {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .savedPhotosAlbum
        imagePickerController.allowsEditing = false
        return imagePickerController
    }()

    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    lazy var detectedText: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir-Heavy", size: 20)
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        let pickerController = UIImagePickerController()
        pickerController.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        pickerController.allowsEditing = true
        pickerController.sourceType = .camera
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationItem.rightBarButtonItem = cameraButton
        setupUI()
    }
    
    override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
        }

    @objc func cameraButtonTapped() {
        showAlert()
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            debugPrint("Called")

            if let image = info[.originalImage] as? UIImage {

                imageView.image = image
  
                processor.process(in: imageView) { (text) in
                    self.detectedText.text = text
                }
                
                imagePickerController.dismiss(animated: true, completion: nil)
            }
        }

        //Show alert
            func showAlert() {

                let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {(action: UIAlertAction) in
                    self.getImage(fromSourceType: .camera)
                }))
                alert.addAction(UIAlertAction(title: "Photo Album", style: .default, handler: {(action: UIAlertAction) in
                    self.getImage(fromSourceType: .photoLibrary)
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }

            //get image from source type
           func getImage(fromSourceType sourceType: UIImagePickerController.SourceType) {
                //Check is source type available
                if UIImagePickerController.isSourceTypeAvailable(sourceType) {

                    imagePickerController.sourceType = sourceType
                    self.present(imagePickerController, animated: true, completion: nil)
                }
            }
    }

extension ViewController {
    func setupUI() {
        self.view.backgroundColor = UIColor.systemPink
        self.view.addSubview(imageView)
        self.view.addSubview(detectedText)
       
        imageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(UIScreen.main.bounds.height * 0.05)
            make.width.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.height / 2)
        }
        
        detectedText.snp.makeConstraints { (make) in
            make.top.equalTo(imageView.snp.bottom).offset(25)
            make.centerX.equalToSuperview()
        }
    }
}
