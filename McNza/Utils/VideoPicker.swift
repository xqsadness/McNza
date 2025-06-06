//
//  VideoPicker.swift
//  McNza
//
//  Created by xqsadness4 on 5/6/25.
//

import SwiftUI
import PhotosUI

struct VideoPicker: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIImagePickerController
    typealias SourceType = UIImagePickerController.SourceType
    
    var sourceType: SourceType
    var mediaTypes: [String]
    var onCompletion: (Result<URL, Error>) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.mediaTypes = mediaTypes
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // No update needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onCompletion: onCompletion)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var onCompletion: (Result<URL, Error>) -> Void
        
        init(onCompletion: @escaping (Result<URL, Error>) -> Void) {
            self.onCompletion = onCompletion
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            picker.dismiss(animated: true)
            
            guard let mediaType = info[.mediaType] as? String,
                  mediaType == UTType.movie.identifier,
                  let url = info[.mediaURL] as? URL else {
                onCompletion(.failure(ImagePickerError.invalidSelection))
                return
            }
            onCompletion(.success(url))
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
            onCompletion(.failure(ImagePickerError.cancelled))
        }
    }
}

enum ImagePickerError: Error {
    case invalidSelection
    case cancelled
    case invalidURL
}
