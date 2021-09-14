//
//  HtmlTextView.swift
//  HtmlTextView
//
//  Created by Indra Tirta Nugraha on 14/09/21.
//

import Foundation
import UIKit
import SwiftSoup

class HtmlTextView: UITextView {
    
    private var htmlText: String = ""
    var boldFont: UIFont?
    var italicFont: UIFont?
    var boldItalicFont: UIFont?
    var onClickURL: ((URL) -> Void)?
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        isEditable = false
        isSelectable = false
        delegate = self
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setHtml(_ html: String) {
        self.htmlText = html
        
        do {
            let doc: Document = try SwiftSoup.parse(htmlText.replacingOccurrences(of: "<br>", with: "\\n"))
            
            let parsedStr = try doc.text().replacingOccurrences(of: "\\n", with: "\n")
            let mutableAttrStr = NSMutableAttributedString(string: parsedStr)
            
            if let bodyElements: Elements = try doc.body()?.getAllElements() {
                for element in bodyElements {
                    let tag = element.tagName()
                    let text = try element.text()
                    let parentTag = element.parent()?.tagName() ?? ""
                    let range = (parsedStr as NSString).range(of: text)
                    
                    switch tag {
                    case "b", "strong":
                        let _font = (parentTag == "i") || (parentTag == "em")
                            ? getBoldItalicFont()
                            : getBoldFont()
                        mutableAttrStr.addAttribute(.font, value: _font, range: range)
                        mutableAttrStr.addAttribute(.foregroundColor, value: getTextColor(), range: range)
                    case "i", "em":
                        let _font = (parentTag == "b") || (parentTag == "strong")
                            ? getBoldItalicFont()
                            : getItalicFont()
                        mutableAttrStr.addAttribute(.font, value: _font, range: range)
                        mutableAttrStr.addAttribute(.foregroundColor, value: getTextColor(), range: range)
                    case "u":
                        mutableAttrStr.addAttribute(.font, value: getFont(), range: range)
                        mutableAttrStr.addAttribute(.underlineStyle, value: 2, range: range)
                        mutableAttrStr.addAttribute(.foregroundColor, value: getTextColor(), range: range)
                    case "strike":
                        mutableAttrStr.addAttribute(.font, value: getFont(), range: range)
                        mutableAttrStr.addAttribute(.strikethroughStyle, value: 2, range: range)
                        mutableAttrStr.addAttribute(.foregroundColor, value: getTextColor(), range: range)
                    case "a":
                        let href = try element.attr("href")
                        mutableAttrStr.addAttribute(.font, value: getBoldFont(), range: range)
                        mutableAttrStr.addAttribute(.link, value: href, range: range)
                    default:
                        mutableAttrStr.addAttribute(.font, value: getFont(), range: range)
                        mutableAttrStr.addAttribute(.foregroundColor, value: getTextColor(), range: range)
                    }
                }
                
                self.attributedText = mutableAttrStr
            }
        } catch Exception.Error(_, let message) {
            self.text = message
        } catch {
            self.text = "error"
        }
    }
    
    private func getTextColor() -> UIColor {
        return textColor ?? .label
    }
    
    private func getFont() -> UIFont {
        guard let _font = font else {
            return UIFont.systemFont(ofSize: 14)
        }
        
        return _font
    }
    
    private func getBoldFont() -> UIFont {
        guard let _font = boldFont else {
            return UIFont.boldSystemFont(ofSize: 14)
        }
        
        return _font
    }
    
    private func getItalicFont() -> UIFont {
        guard let _font = italicFont else {
            return UIFont.italicSystemFont(ofSize: 14)
        }
        
        return _font
    }
    
    private func getBoldItalicFont() -> UIFont {
        guard let _font = boldItalicFont else {
            return UIFont.boldSystemFont(ofSize: 14)
        }
        
        return _font
    }
    
}

extension HtmlTextView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        onClickURL?(URL)
        return false
    }
}
