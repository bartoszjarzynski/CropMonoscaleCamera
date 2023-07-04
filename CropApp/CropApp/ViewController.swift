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

        // Backgroud color main view
        self.view.backgroundColor = .systemBlue
        // Title view
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 100, width: view.frame.width, height: 400))
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.font = UIFont(name: "Impact", size: 80)
        titleLabel.text = "CROP PIC"
        view.addSubview(titleLabel)
        
        // Pick a photo button
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        button.setImage(UIImage(systemName: "photo")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        button.setTitle(" Pick a photo", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.orange
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 8
        button.center = view.center
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        view.addSubview(button)
        
        // Take a photo button
        let cameraButton = UIButton(frame: CGRect(x: view.bounds.midX - 100, y: view.bounds.maxY - 370, width: 200, height: 50))
        cameraButton.setImage(UIImage(systemName: "camera")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        cameraButton.setTitle(" Take a photo", for: .normal)
        cameraButton.setTitleColor(.white, for: .normal)
        cameraButton.backgroundColor = .orange
        cameraButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        cameraButton.layer.cornerRadius = 8
        cameraButton.addTarget(self, action: #selector(cameraTaker), for: .touchUpInside)
        view.addSubview(cameraButton)
        
        // Displaying a photo here in 300x300px
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
                imageView.contentMode = .scaleAspectFit
                imageView.center = view.center
                view.addSubview(imageView)
    }
    
    // Camera roll choose
    @objc func didTapButton() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }
    
    //Taking a picture choose
    @objc func cameraTaker() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        present(picker, animated: true)
    }
    
    // Picker cancel
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    // Show crop controller
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        picker.dismiss(animated: true)
        showCrop(image: image)
    }
    
    // Crop adjusting
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
    
    // Cropping view Controller
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true)
    }
    
    // Declare imageView as an instance variable of your view controller class
    var imageView: UIImageView!

    // Did crop controller :: after
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        // May the background stay white
        self.view.backgroundColor = .white

        // Dismiss the crop view controller
        cropViewController.dismiss(animated: true)

        // Update the existing imageView with the new cropped image
        imageView.image = image

        // Remove the previously added subviews (buttons)
        view.subviews.forEach { subview in
            if subview is UIButton {
                subview.removeFromSuperview()
            }
        }

        // Pick once more a picture button
        let pickButton = UIButton(frame: CGRect(x: 40, y: view.frame.height - 100, width: 100, height: 40))
        pickButton.setTitle("Pick again", for: .normal)
        pickButton.setTitleColor(.white, for: .normal)
        pickButton.backgroundColor = UIColor.systemPink
        pickButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        pickButton.layer.cornerRadius = 8
        pickButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        view.addSubview(pickButton)

        // Color change button
        let convertButton = UIButton(frame: CGRect(x: view.frame.width - 140, y: view.frame.height - 100, width: 100, height: 40))
        convertButton.setTitle("Color", for: .normal)
        convertButton.backgroundColor = UIColor.blue
        convertButton.setTitleColor(.white, for: .normal)
        convertButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        convertButton.layer.cornerRadius = 8
        convertButton.addTarget(self, action: #selector(colorChangeTap), for: .touchUpInside)
        view.addSubview(convertButton)
        
        // Share button
        let shareButton = UIButton(frame: CGRect(x: view.frame.width - 100, y: 80, width: 80, height: 40))
        shareButton.setTitle("Share", for: .normal)
        shareButton.backgroundColor = UIColor.systemRed
        shareButton.setTitleColor(.white, for: .normal)
        shareButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        shareButton.layer.cornerRadius = 8
        view.addSubview(shareButton)
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
    }
    
    // Share button options
    @objc func shareButtonTapped() {
        guard let imageToShare = imageView.image else {
            // Handle the case when there is no image to share
            return
        }

        var activityItems: [Any] = [imageToShare]

        // Check if Facebook app is installed
        if let facebookURL = URL(string: "fb://") {
            if UIApplication.shared.canOpenURL(facebookURL) {
                // Add Facebook activity
                activityItems.append("Share on Facebook")
            }
        }

        // Check if Instagram app is installed
        if let instagramURL = URL(string: "instagram://") {
            if UIApplication.shared.canOpenURL(instagramURL) {
                // Add Instagram activity
                activityItems.append("Share on Instagram")
            }
        }

        // Check if Twitter app is installed
        if let twitterURL = URL(string: "twitter://") {
            if UIApplication.shared.canOpenURL(twitterURL) {
                // Add Twitter activity
                activityItems.append("Share on Twitter")
            }
        }

        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)

        // Exclude some activity types if desired
        activityViewController.excludedActivityTypes = [
            .addToReadingList,
            .assignToContact,
            .markupAsPDF,
            .openInIBooks,
            .postToTencentWeibo,
            .postToFlickr,
            .postToVimeo,
            .postToWeibo
        ]
        present(activityViewController, animated: true, completion: nil)
    }


    // Saving image statement
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // Handle the case when saving the image encounters an error
            print("Error saving image: \(error.localizedDescription)")
        } else {
            // Handle the case when the image is saved successfully
            print("Image saved successfully.")
        }
    }
    
    // Saving in memory original image look
    // Filter index based on original photo
    var originalImages: [UIImage: UIImage] = [:]
    var filterIndex = 0
    
    // Color changing function tap - sepia and BW
    @objc func colorChangeTap() {
        guard let image = imageView.image else {
            return
        }
        
        let filters: [String] = ["CISepiaTone", "CIPhotoEffectMono"]
        let filterName = filters[filterIndex]
        
        if let originalImage = originalImages[image] {
            // Revert to the original color image
            imageView.image = originalImage
            originalImages.removeValue(forKey: image)
        } else {
            // Apply the selected filter
            let filter = CIFilter(name: filterName)!
            filter.setValue(CIImage(image: image), forKey: kCIInputImageKey)
            
            if let outputImage = filter.outputImage {
                let context = CIContext(options: nil)
                guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
                    return
                }
                
                // Create a new UIImage with the filter applied
                let filteredImage = UIImage(cgImage: cgImage)
                
                // Store both the original color image and the filtered image
                originalImages[image] = image
                originalImages[filteredImage] = image
                
                // Update the imageView with the filtered image
                imageView.image = filteredImage
            }
        }
        
        // Update the filter index for the next click
        filterIndex = (filterIndex + 1) % filters.count
    }
    
}

