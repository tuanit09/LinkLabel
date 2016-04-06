//
//  ViewController.swift
//  LinkLabel
//
//  Created by TuanNA16 on 4/6/16.
//  Copyright © 2016 Home. All rights reserved.
//

import UIKit

class ViewController: UIViewController, LinkLabelDelegate {

    @IBOutlet weak var lbLinks: LinkLabel!
    @IBOutlet weak var lbMessage: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // set delegate
        self.lbLinks.delegate = self

        /* reset text to trigger resetting link metadata (refer LinkLabel).
         For a fresh-new label you don't need to call this. but whenever you need to change label content (text/link) you have to set attributedText = nil first
        */
        self.lbLinks.attributedText = nil

        /* if there are many texts/links, you have to call "appendAttributedText(text:, tag:)" method to add them one by one.
         If tag != nil the text is considered link.
        */
        for idx in 14...40 {

            var text : NSAttributedString // displayed string
            var tag : String? // tag for link

            /* this example shows you some sample cases.
             [1] texts which doesn't trigger the delegate method when user taps on it
             [2] link with different fonts/styles/colors
            */

            switch idx {

            case let x where (x == 15 || x == 31 || x == 39): // this is a pure text
                text = NSAttributedString(string: " This is text \(idx)",
                                          attributes: [NSFontAttributeName : UIFont.systemFontOfSize(CGFloat(idx)),
                                            NSForegroundColorAttributeName : UIColor.redColor()])

            case let x where (x == 14 || x == 22 || x == 40): // clor the link and make it underscored
                text = NSAttributedString(string: " Link \(idx)",
                                         attributes: [NSFontAttributeName : UIFont.systemFontOfSize(CGFloat(idx)),
                                            NSUnderlineStyleAttributeName : NSNumber(integer: NSUnderlineStyle.StyleSingle.rawValue),
                                            NSForegroundColorAttributeName : UIColor.greenColor()])
                tag = "link \(idx)"

            case let x where x % 2 == 0: // bold font
                text = NSAttributedString(string: " Link \(idx)", attributes: [NSFontAttributeName : UIFont.boldSystemFontOfSize(CGFloat(idx))])
                tag = "link \(idx)"

            default: // italic font
                text = NSAttributedString(string: " Link \(idx)", attributes: [NSFontAttributeName : UIFont.italicSystemFontOfSize(CGFloat(idx))])
                tag = "link \(idx)"
            }

            // append the text / link
            self.lbLinks.appendAttributedText(text, tag: tag)
        }
    }

    // delegate method when user taps on a link
    func linkLabel(label: LinkLabel, touchEndedOnTag tag: String) {
        self.lbMessage.text = "You has tapped on the link with tag = \(tag)"
    }
}

