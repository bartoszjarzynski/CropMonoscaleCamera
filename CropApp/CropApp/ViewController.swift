//
//  ViewController.swift
//  CropApp
//
//  Created by Magdalena Maloszyc on 13/06/2023.
//
import SwiftUI
import CropViewController
import UIKit
import CoreImage
import Photos
import Foundation


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemBlue
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 100, width: view.frame.width, height: 400))
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.font = UIFont(name: "Impact", size: 80)
        titleLabel.text = "CROP PIC"
        view.addSubview(titleLabel)
        
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        button.setImage(UIImage(systemName: "photo")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        button.setTitle("Pick a photo", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.orange
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 8
        button.center = view.center
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        view.addSubview(button)
        
        let label = UILabel(frame: CGRect(x: 0, y: view.frame.height - 120, width: view.frame.width, height: 100))
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.numberOfLines = 0
        
        
        let attributedText = NSMutableAttributedString()
        
        let highlighterAttachment = NSTextAttachment()
        highlighterAttachment.image = UIImage(systemName: "highlighter")?.withRenderingMode(.alwaysTemplate)
        highlighterAttachment.bounds = CGRect(x: 0, y: -4, width: 20, height: 20)
        let highlighterAttributedString = NSAttributedString(attachment: highlighterAttachment)
        attributedText.append(highlighterAttributedString)
        
        let createdText = NSAttributedString(string: "Created by:\n\n")
        attributedText.append(createdText)
        let names = ["Jakub Chrobok,", "Weronika Chruszcz,", "Bartosz Jarzyński"]
        for name in names {
            attributedText.append(NSAttributedString(string: " "))
            attributedText.append(NSAttributedString(string: name))
        }
        attributedText.append(NSAttributedString(string: "\n"))
        
        label.attributedText = attributedText
        
        view.addSubview(label)
    }
    
    @objc func didTapButton() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        picker.dismiss(animated: true)
        
        showCrop(image: image)
    }
    
    
    func showCrop(image: UIImage) {
        let vc = CropViewController(croppingStyle: .default, image: image)
        vc.aspectRatioPreset = .presetSquare
        vc.aspectRatioLockEnabled = true
        vc.doneButtonColor = .systemOrange
        vc.cancelButtonColor = .systemRed
        vc.toolbarPosition = .bottom
        vc.doneButtonTitle = "Done"
        vc.cancelButtonTitle = "Back"
        vc.delegate = self
        present(vc, animated: true)
    }
    
    
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true)
    }
    
    // Declare imageView as an instance variable of your view controller class
    var imageView: UIImageView!

    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        // May the background stay white
        self.view.backgroundColor = .white
        
        // Cropping
        cropViewController.dismiss(animated: true)
        imageView = UIImageView(frame: view.frame)
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        view.addSubview(imageView)
        
        // Pick once more a picture button
        let pickbutton = UIButton(frame: CGRect(x: 20, y: view.frame.height - 100, width: 100, height: 40))
        pickbutton.setTitle("Pick again", for: .normal)
        pickbutton.setTitleColor(.white, for: .normal)
        pickbutton.backgroundColor = UIColor.systemPink
        pickbutton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        pickbutton.layer.cornerRadius = 8
        pickbutton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        view.addSubview(pickbutton)
        
        //Monochrome scale buttom
        let convertButton = UIButton(frame: CGRect(x: view.frame.width / 2 - 40, y: view.frame.height - 100, width: 100, height: 40))
            convertButton.setTitle("Monoscale", for: .normal)
            convertButton.backgroundColor = UIColor.blue
            convertButton.setTitleColor(.white, for: .normal)
            convertButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            convertButton.layer.cornerRadius = 8
            convertButton.addTarget(self, action: #selector(convertToMonochrome), for: .touchUpInside)
            view.addSubview(convertButton)
        
        // Save button
        let saveButton = UIButton(frame: CGRect(x: view.frame.width - 100, y: view.frame.height - 100, width: 80, height: 40))
        saveButton.setTitle("Save", for: .normal)
        saveButton.backgroundColor = UIColor.orange
        saveButton.setTitleColor(.black, for: .normal)
        saveButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        saveButton.layer.cornerRadius = 8
        view.addSubview(saveButton)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }

    @objc func saveButtonTapped() {
        guard let imageToSave = imageView.image else {
            // Handle the case when there is no image to save
            return
        }
        
        // Perform the code to save the image to the gallery
        UIImageWriteToSavedPhotosAlbum(imageToSave, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // Handle the case when saving the image encounters an error
            print("Error saving image: \(error.localizedDescription)")
        } else {
            // Handle the case when the image is saved successfully
            print("Image saved successfully.")
        }
    }
    
    var originalImages: [UIImage: UIImage] = [:]

    @objc func convertToMonochrome() {
        guard let image = imageView.image else {
            return
        }
        
        if let originalImage = originalImages[image] {
            // Revert to the original color image
            imageView.image = originalImage
            originalImages.removeValue(forKey: image)
        } else {
            // Convert to monochrome
            guard let ciImage = CIImage(image: image) else {
                return
            }
            
            let context = CIContext(options: nil)
            let filter = CIFilter(name: "CIColorControls")!
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(0.0, forKey: kCIInputSaturationKey)
            
            guard let outputImage = filter.outputImage,
                  let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
                return
            }
            
            let monochromeImage = UIImage(cgImage: cgImage)
            
            // Store both the original color image and the monochrome image
            originalImages[image] = image
            originalImages[monochromeImage] = image
            
            // Update the imageView with the monochrome image
            imageView.image = monochromeImage
        }
    }

}
