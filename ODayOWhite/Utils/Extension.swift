//
//  Extension.swift
//  ODayOWhite
//
//  Created by sangheon on 2021/02/09.
//

import UIKit
import SafariServices
import MessageUI


extension PersonalInfoViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let _ = error {
            controller.dismiss(animated: true)
        }
        controller.dismiss(animated: true)
    }
}
