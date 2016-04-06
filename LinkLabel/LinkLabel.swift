//
//  LinkLabel.swift
//  LinkLabel
//
//  Created by TuanNA16 on 4/5/16.
//  Copyright © 2016 LinkLabel. All rights reserved.
//

import UIKit

protocol LinkLabelDelegate : NSObjectProtocol {
    /* delegate method that gets called when user taps on a link.
     @label: label that holds the link.
     @tag: tag value helps identify the link.
    */
    func linkLabel(label:LinkLabel, touchEndedOnTag tag:String)
}


class LinkLabel: UILabel {

    // This metadata holds the list of links and their position (range) in the text. metadata also holds "tag" to help identify the link that user has tapped on. The tags are defined by you (as developer) when inserting the links.
    private var metadata = [MetaDataItem]()
    private class MetaDataItem {
        var tag : String
        var range : NSRange
        init(tag:String, range: NSRange) {
            self.tag = tag
            self.range = range
        }
    }

    weak var delegate : LinkLabelDelegate! {
        willSet {
            self.userInteractionEnabled = true // false by default, then we have to set it true
        }
    }

    // For convenience, when you reset label text/attributedString (because data has changed, the text/links should be updated) metadata must be reset too.
    override var text: String? {
        get {
            return super.text
        }
        set {
            if (newValue == nil) {
                self.metadata.removeAll()
            }
            super.text = newValue
        }
    }

    override var attributedText: NSAttributedString? {
        get {
            return super.attributedText
        }
        set {
            if (newValue == nil) {
                self.metadata.removeAll()
            }
            super.attributedText = newValue
        }
    }

    /* You have to call this method to embed a text/link to the label
     @text: attributed string which you can custom it with font, size, color, style (bold/regular/italic/underscore,...).
     @tag: if not null, the text is considered a link and its' position and tag are saved in metadata for later computation. When user taps on the text, the delegate method gets called with the tag.
    */
    func appendAttributedText(text:NSAttributedString, tag:String?) {
        if let tag = tag { // this string should be marked as link
            // calculate range for new text
            var length = 0
            if let attText = self.attributedText {
                length = attText.length
            }
            let range = NSRange(location: length, length: text.length)
            self.metadata.append(MetaDataItem(tag: tag, range: range))
        }

        // append new text
        if let attText = self.attributedText {
            let attrStr = NSMutableAttributedString(attributedString: attText)
            attrStr.appendAttributedString(text)
            self.attributedText = attrStr
        } else {
            self.attributedText = text
        }
    }

    /* Handle tap event.
     Actually, you should add a tap gesture recognizer to recognize only tap events.
     This implementation simply overrides touchesEnded. This is acceptable for many cases (when you don't have to separate tap events and other touch events)
    */
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first, let attrText = self.attributedText, let delegate = self.delegate where self.metadata.count > 0 {
            // current size of label
            let size = self.bounds.size

            // text container
            let textContainer = NSTextContainer(size: size)
            textContainer.lineFragmentPadding = 0.0
            textContainer.lineBreakMode = self.lineBreakMode
            textContainer.maximumNumberOfLines = self.numberOfLines

            // layout manager
            let layoutManager = NSLayoutManager()
            layoutManager.addTextContainer(textContainer)

            // text storage
            let textStorage = NSTextStorage(attributedString: attrText)
            textStorage.addLayoutManager(layoutManager)

            // calculate location of touch on text
            let touchLocation = touch.locationInView(self)
            let textBoundingRect = layoutManager.usedRectForTextContainer(textContainer)
            let textContainerOffset = CGPoint(x: (size.width - textBoundingRect.size.width) * 0.5 - textBoundingRect.origin.x,
                                              y: (size.height - textBoundingRect.size.height) * 0.5 - textBoundingRect.origin.y)
            let touchLocationInTextContainer = CGPoint(x: touchLocation.x - textContainerOffset.x, y: touchLocation.y - textContainerOffset.y)

            // find charater index at the touch location
            let characterIndex = layoutManager.characterIndexForPoint(touchLocationInTextContainer, inTextContainer: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

            // check metadata if there is a link at that location
            for metadata in self.metadata {
                if (NSLocationInRange(characterIndex, metadata.range)) {
                    delegate.linkLabel(self, touchEndedOnTag: metadata.tag)
                }
            }
        }
    }
}
