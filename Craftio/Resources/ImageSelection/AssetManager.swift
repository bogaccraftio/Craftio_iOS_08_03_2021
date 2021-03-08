import Foundation
import UIKit
import Photos

open class AssetManager {
    
    public static func getImage(_ name: String) -> UIImage {
        return UIImage(named: name) ?? UIImage()
    }
    
    public static func getLibraryMedia(withConfiguration configuration: Configuration, _ completion: @escaping (_ assets: [PHAsset]) -> Void)  {
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            fetch(withConfiguration: configuration) { (assets) in
                DispatchQueue.main.async {
                    completion(assets)
                }
            }
        } else {
            PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in
                if status == .authorized {
                    fetch(withConfiguration: configuration) { (assets) in
                        DispatchQueue.main.async {
                            completion(assets)
                        }
                    }
                } else {
                }
            })
        }
    }

    
    public static func fetch(withConfiguration configuration: Configuration, _ completion: @escaping (_ assets: [PHAsset]) -> Void) {
        

        guard PHPhotoLibrary.authorizationStatus() == .authorized else { return }
        
        DispatchQueue.global(qos: .background).async {
            // MARK: - Changed by Sohil R. Memon
            var fetchResult: PHFetchResult<PHAsset>!
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            
            switch configuration.fetchType {
            case .photo:
                fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            case .video:
                fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions)
            case .all:
                fetchResult = PHAsset.fetchAssets(with: fetchOptions)
            }
            
            if fetchResult.count > 0 {
                // MARK: - Changed by Sohil R. Memon
                var assets = [PHAsset]()
                fetchResult.enumerateObjects({ object, _, _ in
                    if object.mediaType == PHAssetMediaType.video {
                        guard let maxVideoInterval = configuration.maxVideoInterval, maxVideoInterval > 0 else {
                            assets.insert(object, at: 0)
                            return
                        }
                        
                        if object.duration.rounded() <= maxVideoInterval {
                            assets.insert(object, at: 0)
                        }
                    } else {
                        assets.insert(object, at: 0)
                    }
                })
                
                DispatchQueue.main.async {
                    completion(assets)
                }
            }
        }
    }
    
    public static func getImageData(_ asset: PHAsset, completion: @escaping (_ imageData: Data?) -> Void) {
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.deliveryMode = .fastFormat
        requestOptions.isNetworkAccessAllowed = true
        
        imageManager.requestImageData(for: asset, options: requestOptions) { (data, _, _, _) in
            DispatchQueue.main.async(execute: {
                completion(data)
            })
        }
    }
    
    public static func resolveAsset(_ asset: PHAsset, size: CGSize = CGSize(width: 720, height: 1280), shouldPreferLowRes: Bool = false, completion: @escaping (_ image: UIImage?) -> Void) {
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isNetworkAccessAllowed = true
        requestOptions.isSynchronous = true
        
        imageManager.requestImage(for: asset, targetSize: CGSize(width: 250, height: 250), contentMode: .aspectFit, options: requestOptions) { image, info in
            if let info = info, info["PHImageFileUTIKey"] == nil {
                DispatchQueue.main.async(execute: {
                    completion(image)
                })
            }
        }
    }
    
    public static func resolveAssets(_ assets: [PHAsset], size: CGSize = CGSize(width: 720, height: 1280)) -> [UIImage] {
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        
        var images = [UIImage]()
        for asset in assets {
            imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: requestOptions) { image, _ in
                if let image = image {
                    images.append(image)
                }
            }
        }
        return images
    }
    
    static func requestURL(_ mPhasset: PHAsset, completionHandler: @escaping (URL?) -> ()) {
        
        if mPhasset.mediaType == .image {
            getImageData(mPhasset) { (data) in
                if let data = data {
                    let writePath = FileManager.default.documentsDirectoryPath! + "/temp_\(Date().timeIntervalSince1970).png"
                    let imageURL = URL(fileURLWithPath: writePath)
                    do {
                        try data.write(to: URL(fileURLWithPath: writePath), options: Data.WritingOptions.atomic)
                        completionHandler(imageURL)
                    } catch {
                        completionHandler(nil)
                    }
                }
            }
        } else if mPhasset.mediaType == .video {
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .original
            options.isNetworkAccessAllowed = true
            PHImageManager.default().requestAVAsset(forVideo: mPhasset, options: options, resultHandler: { (asset, audioMix, info) in
                if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl = urlAsset.url
                    let toURL = URL(fileURLWithPath: FileManager.default.documentsDirectoryPath! + "/temp_\(Date().timeIntervalSince1970).mp4")
                    do {
                        try FileManager.default.copyItem(at: localVideoUrl, to: toURL)
                        completionHandler(toURL)
                    } catch {
                        debugPrint("Error \(error.localizedDescription)")
                    }
                } else {
                    completionHandler(nil)
                }
            })
        }
    }
    
    static func generateThumbnail(path: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: path, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
}

extension FileManager {
    
    /// EZSE: Returns path of documents directory
    public var documentsDirectoryPath: String? {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as [String]
        return paths[0]
    }
    
    /// EZSE: Returns path of documents directory caches
    public var cachesDirectoryPath: String? {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true) as [String]
        return paths[0]
    }
    
    func clearDocumentsDirectory() {
        let items = try? self.contentsOfDirectory(at: URL(string: documentsDirectoryPath!)!, includingPropertiesForKeys: nil)
        items?.forEach { item in
            try? self.removeItem(at: item)
        }
    }
}
