//    The MIT License (MIT)
//
//    Copyright (c) 2015 Krzysztof Rossa
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.

import Cocoa

class ViewController: NSViewController, NSTextFieldDelegate {

    @IBOutlet weak var stringEncodingRadio: NSButtonCell!
    
    @IBOutlet weak var textEdit: NSTextField!
    
    @IBOutlet weak var hashTextView: NSTextField!
    
    @IBOutlet weak var hashAlgorithmComboBox: NSComboBox!
    
    @IBOutlet weak var upperCaseCheckButton: NSButton!
    
    let SELECTED_ALGORITHM_INDEX_KEY = "selectedAlgorithmIndex"
    let UPPER_CASE_KEY = "upperCase"
    
    let MD5 = 0
    let SHA1 = 1
    let SHA224 = 2
    let SHA384 = 3
    let SHA512 = 4
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        textEdit.delegate = self
        
        loadDefault()
    }
    
    func loadDefault(){
        let defaults = NSUserDefaults.standardUserDefaults()
        let seletedAlgorithmIndex = defaults.integerForKey(SELECTED_ALGORITHM_INDEX_KEY)
        if (validateItem(seletedAlgorithmIndex)) {
            hashAlgorithmComboBox.selectItemAtIndex(seletedAlgorithmIndex)
        }
        
        let upperCase = defaults.boolForKey(UPPER_CASE_KEY)
        if (upperCase){
            upperCaseCheckButton.state = NSOnState
        } else {
            upperCaseCheckButton.state = NSOffState
        }
    }
    
    
    @IBAction func onUpperCaseChangeState(sender: NSButton) {
        let defaults = NSUserDefaults.standardUserDefaults()
        if (upperCaseCheckButton.state == NSOnState){
            defaults.setBool(true, forKey: UPPER_CASE_KEY)
        } else {
            defaults.setBool(false, forKey: UPPER_CASE_KEY)
        }
        
        calculateHash()
    }
    
    func validateItem(seletedAlgorithmIndex : Int) -> Bool {
        return seletedAlgorithmIndex >= MD5 && seletedAlgorithmIndex <= SHA512
    }
    
    func calculateHash() {
        let strToHash = textEdit.stringValue

        var hash = ""
        switch (hashAlgorithmComboBox.indexOfSelectedItem){
        case MD5:
            hash = strToHash.calculateHash(HMACAlgorithm.MD5)
        case SHA1:
            hash = strToHash.calculateHash(HMACAlgorithm.SHA1)
        case SHA224:
            hash = strToHash.calculateHash(HMACAlgorithm.SHA224)
        case SHA384:
            hash = strToHash.calculateHash(HMACAlgorithm.SHA384)
        case SHA512:
            hash = strToHash.calculateHash(HMACAlgorithm.SHA512)
        default:
            hash = "error"
        }
        
        if (upperCaseCheckButton.state == NSOnState){
            hashTextView.stringValue = hash.uppercaseString
        } else {
            hashTextView.stringValue = hash
        }
    }
 
    @IBAction func onHashAlgorithmChange(sender: NSComboBox) {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        defaults.setInteger(sender.indexOfSelectedItem, forKey: SELECTED_ALGORITHM_INDEX_KEY)
        
        calculateHash()
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func onClickExit(sender: AnyObject) {
        NSApplication.sharedApplication().terminate(self)
    }
    
    @IBAction func onClickCopyHash(sender: AnyObject) {
        var pasteBoard = NSPasteboard.generalPasteboard()

        pasteBoard.clearContents()
        
        var str = hashTextView.stringValue
        // now read write our String and an Array with 1 item at index 0
        pasteBoard.writeObjects([str])
    }
    
    
    
    @IBAction func onClickPasteString(sender: AnyObject) {
        
        // lets create a pasteBoard that we can write to (and read from)
        var pasteBoard : NSPasteboard = NSPasteboard.generalPasteboard()
        

        // here's how we can read text from the clipboard. We reading just the first item assuming there are not multiple items
        if let pasted = pasteBoard.pasteboardItems {
            var count = pasted.count
            
            if count > 0 {
                var valueFromClipboard = pasted[0].stringForType("public.utf8-plain-text")
                if let value = valueFromClipboard {
                    textEdit.stringValue = value
                    calculateHash()
                }
            } else {
                
            }
        }
    }
    
    override func controlTextDidChange(aNotification: NSNotification) {
        calculateHash()
    }

}

