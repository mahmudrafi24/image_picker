import UIKit
import Flutter
import MobileCoreServices
import UniformTypeIdentifiers

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  private var pickerChannel: FlutterMethodChannel?
  private var pathChannel: FlutterMethodChannel?
  private var imagePicker: UIImagePickerController?
  private var currentResult: FlutterResult?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController
    
    // Image picker channel
    pickerChannel = FlutterMethodChannel(name: "custom_picker_channel", binaryMessenger: controller.binaryMessenger)
    pickerChannel?.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      guard let self = self else { return }
      if call.method == "pickImage" {
        guard let args = call.arguments as? [String: Any],
              let sourceString = args["source"] as? String else {
          result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
          return
        }
        
        let sourceType: UIImagePickerController.SourceType = sourceString == "camera" ? .camera : .photoLibrary
        
        if sourceType == .camera && !UIImagePickerController.isSourceTypeAvailable(.camera) {
          result(FlutterError(code: "camera_unavailable", message: "Camera not available", details: nil))
          return
        }
        
        self.imagePicker = UIImagePickerController()
        self.imagePicker?.sourceType = sourceType
        self.imagePicker?.delegate = self
        
        if #available(iOS 14.0, *) {
          self.imagePicker?.mediaTypes = [UTType.image.identifier]
        } else {
          self.imagePicker?.mediaTypes = [kUTTypeImage as String]
        }
        
        if let vc = self.imagePicker {
          controller.present(vc, animated: true, completion: nil)
          self.currentResult = result
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
    
    // Path provider channel
    pathChannel = FlutterMethodChannel(name: "custom_path_channel", binaryMessenger: controller.binaryMessenger)
    pathChannel?.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "getTempDir" {
        let tempDir = NSTemporaryDirectory()
        result(tempDir)
      } else if call.method == "getAppDocsDir" {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        result(documentsPath)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

extension AppDelegate: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    defer { picker.dismiss(animated: true) }
    
    guard let image = info[.originalImage] as? UIImage,
          let imageData = image.jpegData(compressionQuality: 1.0) else {
      currentResult?(FlutterError(code: "image_error", message: "Failed to get image", details: nil))
      currentResult = nil
      return
    }
    
    let tempDir = NSTemporaryDirectory()
    let fileName = "image_picker_\(UUID().uuidString).jpg"
    let filePath = tempDir + fileName
    
    if FileManager.default.createFile(atPath: filePath, contents: imageData, attributes: nil) {
      currentResult?(filePath)
    } else {
      currentResult?(FlutterError(code: "save_error", message: "Failed to save image", details: nil))
    }
    currentResult = nil
  }
  
  public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true)
    currentResult?(nil)
    currentResult = nil
  }
}
