import UIKit

class ViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var chosenPasswordLabel: UILabel!
    @IBOutlet weak var createPasswordButton: UIButton!
    @IBOutlet weak var crackPasswordButton: UIButton!
    
    // MARK: - Actions
    
    @IBAction func createPassword(_ sender: Any) {
        password = generatePassword()
        passwordTextField.text = password
        self.passwordTextField.isSecureTextEntry = true
    }
    
    @IBAction func crakPassword(_ sender: Any) {
        queue.async {
            self.bruteForce(passwordToUnlock: self.password)
        }
    }
    
    @IBAction func onBut(_ sender: Any) {
        isBlack.toggle()
    }
    
    // MARK: - Properties
    
    var isBlack: Bool = false {
        didSet {
            if isBlack {
                self.view.backgroundColor = .systemYellow
            } else {
                self.view.backgroundColor = .white
            }
        }
    }
    
    let allowedCharacters: [String] = String().printable.map { String($0) }
    var password: String = ""
    var isWorking = false
    let queue = DispatchQueue(label: "brute", qos: .utility)
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        activityIndicator.isHidden = true
    }
    
    // MARK: - Functions
    
    func bruteForce(passwordToUnlock: String) {
        
        var password: String = ""
        isWorking = true
        
        let findPassword = DispatchWorkItem {
            self.chosenPasswordLabel.text = "Select a password: " + "\(password)"
            self.passwordTextField.isSecureTextEntry = true
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        }
        
        let resultPassword = DispatchWorkItem {
            self.chosenPasswordLabel.text = "Your password: " + "\(password)"
            self.passwordTextField.isSecureTextEntry = false
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
        }
        
        while password != passwordToUnlock {
            password = generateBruteForce(password, fromArray: allowedCharacters)
            if isWorking {
                DispatchQueue.main.async(execute: findPassword)
            } else {
                break
            }
            print(password)
        }
        
        if isWorking {
            DispatchQueue.main.async(execute: resultPassword)
        }
    }
    
    func generatePassword() -> String {
        var password = String()
        for _ in 1...3 {
            let character = allowedCharacters[Int.random(in: 0...allowedCharacters.count - 1)]
            password += character
        }
        return password
    }
}

func indexOf(character: Character, _ array: [String]) -> Int {
    return array.firstIndex(of: String(character))!
}

func characterAt(index: Int, _ array: [String]) -> Character {
    return index < array.count ? Character(array[index])
    : Character("")
}

func generateBruteForce(_ string: String, fromArray array: [String]) -> String {
    var str: String = string
    
    if str.count <= 0 {
        str.append(characterAt(index: 0, array))
    }
    else {
        str.replace(at: str.count - 1,
                    with: characterAt(index: (indexOf(character: str.last!, array) + 1) % array.count, array))
        
        if indexOf(character: str.last!, array) == 0 {
            str = String(generateBruteForce(String(str.dropLast()), fromArray: array)) + String(str.last!)
        }
    }
    return str
}

extension String {
    var digits:      String { return "0123456789" }
    var lowercase:   String { return "abcdefghijklmnopqrstuvwxyz" }
    var uppercase:   String { return "ABCDEFGHIJKLMNOPQRSTUVWXYZ" }
    var punctuation: String { return "!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~" }
    var letters:     String { return lowercase + uppercase }
    var printable:   String { return digits + letters + punctuation }
    
    mutating func replace(at index: Int, with character: Character) {
        var stringArray = Array(self)
        stringArray[index] = character
        self = String(stringArray)
    }
}


