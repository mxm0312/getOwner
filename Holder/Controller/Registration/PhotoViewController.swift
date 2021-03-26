//
//  PhotoViewController.swift
//  Holder
//
//  Created by Maxim Perehod on 13.11.2020.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import AudioToolbox

// данная структура содержит информацию о номере машин, uid пользователя и айди VC который будет показан после меню создания автомобиля. Это сделано, чтобы можно было ссылаться на CarVC из двух других VC: текущего и ProfileVC
struct structForCarVC {
    var uid: String?
    var carNumber: String?
    var whereToGoAfter: String?
    
    init(uid: String, carNumber: String, whereToGoAfter: String) {
        self.uid = uid
        self.carNumber = carNumber
        self.whereToGoAfter = whereToGoAfter
    }
}

class PhotoViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet var imageButton: UIButton!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var skipButton: UIButton!
    var imageData: Data?
   
    @IBOutlet var continueButtonHeight: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        overrideUserInterfaceStyle = .light
        imageButton.layer.cornerRadius = 60
        imageButton.clipsToBounds = true
        nextButton.layer.cornerRadius = continueButtonHeight.constant/2
        nextButton.isEnabled = false
    }
    
    
    @IBAction func choosePhotoButton(_ sender: Any) {
        AudioServicesPlaySystemSound(1520)
        let image = UIImagePickerController()
        image.delegate = self
        image.allowsEditing = true
        image.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(image, animated: true, completion: nil)
    }
    
    
    @IBAction func nextButton(_ sender: Any) {
        if imageData != nil {
            let task = Storage.storage().reference().child(Auth.auth().currentUser!.uid + ".png").putData(imageData!, metadata: nil, completion: { (data, error) in
                if error == nil {
                    
                } else {
                    print(error?.localizedDescription as Any)
                }
            })
            task.observe(.success) { _ in
                
               
                let st = structForCarVC(uid: Auth.auth().currentUser!.uid, carNumber: "one", whereToGoAfter: "toHome")
                UserDefaults.standard.setValue(self.imageData, forKey: "userImageData")
                self.performSegue(withIdentifier: "carSegue", sender: st)
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "carSegue" {
            if let vc = segue.destination as? CarViewController {
                if let st = sender as? structForCarVC {
                    vc.userUID = st.uid
                    vc.carNumber = st.carNumber
                    vc.whereToGoAfter = st.whereToGoAfter
                }
            }
        }
    }
    
    @IBAction func skipButton(_ sender: Any) {
        self.performSegue(withIdentifier: "carSegue", sender: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        nextButton.backgroundColor = UIColor(hexString: "#202020")
        nextButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
        
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.imageButton.setImage(image, for: .normal)
            self.imageData = image.jpegData(compressionQuality: 0.4)
            self.nextButton.alpha = 1
            self.nextButton.isEnabled = true
        }
    }
    
    func setupUI() {
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
                case 1136: // айфоны пятые и SE
                    self.continueButtonHeight.constant = 45
                    break
                default:
                    print("unknown")
            }
        }
    }
    
}
