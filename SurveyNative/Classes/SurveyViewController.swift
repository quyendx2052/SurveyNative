//
//  SurveyViewController.swift
//  SurveyNative
//
//  Created by Nora Mullaney on 1/23/17.
//  Copyright © 2017 Recovery Record. All rights reserved.
//

import UIKit

open class SurveyViewController: UIViewController {

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        return tableView
    }()

    open var surveyQuestions : SurveyQuestions?

    open var dataSource: UITableViewDataSource?
    open var delegate : UITableViewDelegate?
    open var cellDataDelegate : TableCellDataDelegate?

    /**
     Return questions JSON file name e.g: `sample_questions_pack`
     */
    open func surveyJsonFile() -> String? {
        return nil
    }

    /**
     Return JSON dictionary of the questions
     */
    open func surveyJSON() -> [String: Any]? {
        return nil
    }

    open func surveyTheme() -> SurveyTheme {
        return DefaultSurveyTheme()
    }

    open func setSurveyAnswerDelegate(_ surveyAnswerDelegate: SurveyAnswerDelegate) {
        surveyQuestions?.setSurveyAnswerDelegate(surveyAnswerDelegate)
    }

    open func setCustomConditionDelegate(_ customConditionDelegate: CustomConditionDelegate) {
        surveyQuestions?.setCustomConditionDelegate(customConditionDelegate)
    }

    open func setValidationFailedDelegate(_ validationFailedDelegate: ValidationFailedDelegate) {
        self.cellDataDelegate?.setValidationFailedDelegate(validationFailedDelegate)
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        if let jsonFile = surveyJsonFile() {
            surveyQuestions = SurveyQuestions.load(jsonFile, surveyTheme: surveyTheme())

        } else if let jsonDict = surveyJSON() {
            surveyQuestions = SurveyQuestions.load(jsonDict, surveyTheme: surveyTheme())

        } else {
            Logger.log("Could not find questions", level: .error)
        }

        // Add tableView as UIView's subview
        view.addSubview(tableView)
        if #available(iOS 11.0, *) {
            let top = tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
            let bottom = tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            let leading = tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
            let trailing = tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
            NSLayoutConstraint.activate([top, bottom, trailing, leading])
        } else {
            let top = tableView.topAnchor.constraint(equalTo: view.topAnchor)
            let bottom = tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            let leading = tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
            let trailing = tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            NSLayoutConstraint.activate([top, bottom, trailing, leading])
        }
        
        TableUIUpdater.setupTable(tableView)

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        tapRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tapRecognizer)

        self.cellDataDelegate = DefaultTableCellDataDelegate(surveyQuestions!, tableView: tableView, submitCompletionHandler: { data, response, error -> Void in
            self.dismiss(animated: true, completion: nil)
        })
        self.dataSource = SurveyDataSource(surveyQuestions!, surveyTheme: self.surveyTheme(), tableCellDataDelegate: cellDataDelegate!, presentationDelegate: self)
        tableView.dataSource = dataSource
        self.delegate = SurveyTableViewDelegate(surveyQuestions!)
        tableView.delegate = self.delegate
    }

    @objc public func tableViewTapped(sender: UITapGestureRecognizer) {
        if sender.view as? UITextField == nil {
            tableView.endEditing(true)
            UIApplication.shared.sendAction(#selector(resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}




