//
//  ViewController.swift
//  aerologix
//
//  Created by Karthi CK on 02/06/21.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK : - Properties

    @IBOutlet weak var tableView: UITableView!
    
    let refreshControl = UIRefreshControl()
    let coreDataHelper = CoreDataHelper.sharedInstance
    
    var tableData: ProfileDetailModal? = nil
    
    // MARK : - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        tableView.delegate = self
        tableView.dataSource = self
                
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing")
        refreshControl.addTarget(self, action: #selector(self.getProfileDetail), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Load from json", style: .plain, target: self, action: #selector(self.loadDataFromLocalJSON(_:)))
        
        self.getProfileDetail()
    }
}

// MARK : - Tableview delegate and Datasource implementation

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableData?.data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let userProfileView = UserProfileView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 60))
        userProfileView.backgroundColor = .systemBackground
        userProfileView.profileImageView.layer.cornerRadius = 25
        userProfileView.profileImageView.layer.masksToBounds = true
        guard let profileData = tableData?.data?[section] else { return userProfileView }
        if let profileURL = profileData.picture,
           profileURL.count > 0 {
            userProfileView.profileImageView.loadImageWithUrl(profileURL)
        } else {
            userProfileView.profileImageView.image = UIImage(named: "person.fill")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 24))
        }
        userProfileView.userNameLabel.text = "\(profileData.firstname ?? "")" + " " + "\(profileData.lastname ?? "")"
        let gender = profileData.gender == nil ? "Not Specified" : "\(profileData.gender ?? "")"
        let age = profileData.age == nil ? "Not Specified" : "\(profileData.age ?? 0)"
        userProfileView.descriptionLabel.text = "Gender: \(gender)" + ", " + "Age: \(age)"
        userProfileView.tag = section
        let gestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        userProfileView.addGestureRecognizer(gestureRecogniser)        
        return userProfileView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionData = tableData?.data?[section] else { return 0 }
        if (sectionData.isExpanded) {
            let jobCount = sectionData.job?.count ?? 0
            let educationCount = sectionData.education?.count ?? 0
            if (sectionData.isJobExpanded && !sectionData.isEducationExpanded) {
                return (jobCount + 2)
            }
            if (!sectionData.isJobExpanded && sectionData.isEducationExpanded) {
                return (educationCount + 2)
            }
            if (sectionData.isJobExpanded && sectionData.isEducationExpanded) {
                return jobCount + educationCount + 2
            }
            return 2
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.selectionStyle = .none
        
        guard let sectionData = tableData?.data?[indexPath.section] else { return cell }
        
        if (sectionData.isExpanded) {
            // When both job & education is collapsed
            if (!sectionData.isJobExpanded && !sectionData.isEducationExpanded) {
                switch indexPath.row {
                case 0, 1:
                    cell.imageView?.image = rowsHeaderImage[indexPath.row]
                    cell.textLabel?.text = rowsHeaderTitle[indexPath.row]
                    cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
                default:
                    break
                }
            }
            
            // When only job is expanded
            if (sectionData.isJobExpanded && !sectionData.isEducationExpanded) {
                let jobCount = sectionData.job?.count ?? 0
                if (indexPath.row == 0) {
                    cell.imageView?.image = rowsHeaderImage[indexPath.row]
                    cell.textLabel?.text = rowsHeaderTitle[indexPath.row]
                    cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
                } else if (indexPath.row == jobCount + 1) {
                    cell.imageView?.image = rowsHeaderImage[1]
                    cell.textLabel?.text = rowsHeaderTitle[1]
                    cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
                } else {
                    cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
                    guard let jobArray = tableData?.data?[indexPath.section].job?[indexPath.row - 1] else {
                        return cell
                    }
                    cell.indentationLevel = 2
                    cell.indentationLevel = 4
                    cell.textLabel?.text = jobArray.organization
                    cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .subheadline)
                    cell.detailTextLabel?.text = "\(jobArray.role ?? "")" + ", " + "\(jobArray.exp ?? 0)"
                }
            }
            
            // When only education is expanded
            if (!sectionData.isJobExpanded && sectionData.isEducationExpanded) {
                if (indexPath.row == 0 || indexPath.row == 1) {
                    cell.imageView?.image = rowsHeaderImage[indexPath.row]
                    cell.textLabel?.text = rowsHeaderTitle[indexPath.row]
                    cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
                } else {
                    cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
                    guard let educationArray = tableData?.data?[indexPath.section].education?[indexPath.row - 2] else {
                        return cell
                    }
                    cell.indentationLevel = 2
                    cell.indentationLevel = 4
                    cell.textLabel?.text = educationArray.institution
                    cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .subheadline)
                    cell.detailTextLabel?.text = "\(educationArray.degree ?? "")"
                }
            }
            
            // When both job and education is expanded
            if (sectionData.isJobExpanded && sectionData.isEducationExpanded) {
                let jobCount = sectionData.job?.count ?? 0
                if (indexPath.row == 0) {
                    cell.imageView?.image = rowsHeaderImage[indexPath.row]
                    cell.textLabel?.text = rowsHeaderTitle[indexPath.row]
                    cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
                } else if (indexPath.row >= 1 && indexPath.row < jobCount + 1) {
                    cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
                    guard let jobArray = tableData?.data?[indexPath.section].job?[indexPath.row - 1] else {
                        return cell
                    }
                    cell.indentationLevel = 2
                    cell.indentationLevel = 4
                    cell.textLabel?.text = jobArray.organization
                    cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .subheadline)
                    cell.detailTextLabel?.text = "\(jobArray.role ?? "")" + ", " + "\(jobArray.exp ?? 0)"
                } else if (indexPath.row == jobCount + 1) {
                    cell.imageView?.image = rowsHeaderImage[1]
                    cell.textLabel?.text = rowsHeaderTitle[1]
                    cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
                }
                else {
                    cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
                    guard let educationArray = tableData?.data?[indexPath.section].education?[indexPath.row - (jobCount + 2)] else {
                        return cell
                    }
                    cell.indentationLevel = 2
                    cell.indentationLevel = 4
                    cell.textLabel?.text = educationArray.institution
                    cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .subheadline)
                    cell.detailTextLabel?.text = "\(educationArray.degree ?? "")"
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let sectionData = tableData?.data?[indexPath.section] else { return }
        // Handle expand & collapse of table cell (i.e, job and education)
        if (sectionData.isExpanded) {
            // When job and education both are collapsed |
            // When job is expanded and education is collapsed
            if (!sectionData.isJobExpanded && !sectionData.isEducationExpanded ||
                    sectionData.isEducationExpanded && !sectionData.isJobExpanded) {
                switch indexPath.row {
                case 0:
                    tableData?.data?[indexPath.section].isJobExpanded.toggle()
                    self.tableView.reloadData()
                    break
                case 1:
                    tableData?.data?[indexPath.section].isEducationExpanded.toggle()
                    self.tableView.reloadData()
                    break
                default:
                    break
                }
            }
            
            // When job is expanded and education is collapsed |
            // When both job and education is expanded
            if (sectionData.isJobExpanded && !sectionData.isEducationExpanded ||
                    sectionData.isJobExpanded && sectionData.isEducationExpanded) {
                let jobCount = sectionData.job?.count ?? 0
                switch indexPath.row {
                case 0:
                    tableData?.data?[indexPath.section].isJobExpanded.toggle() //Toggle Job
                    self.tableView.reloadData()
                    break
                case jobCount + 1:
                    tableData?.data?[indexPath.section].isEducationExpanded.toggle() //Toggle Education
                    self.tableView.reloadData()
                    break
                default:
                    break
                }
            }
        }
    }
    
    // MARK : - Handler function for tableview header
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        guard let senderView = sender.view else { return }
        tableData?.data?[senderView.tag].isExpanded.toggle()
        self.tableView.reloadSections(IndexSet(integer: senderView.tag), with: .automatic)
    }
}

// MARK : - Handlers

extension ViewController {
    
    // MARK : - Get All Details API call
    
    @objc
    private func getProfileDetail() {
        // when network available, make a api call, and store data to core data
        // else try loading from core data
        if Reachability.isConnectedToNetwork() {
            RestAPIManager.sharedInstance.getAllProfile { (data, response, error) in
                if let error = error {
                    showToast(error.localizedDescription)
                    return
                }
                
                if let jsonData = data {
                    do {
                        let profileDetail = try JSONDecoder().decode(ProfileDetailModal.self, from: jsonData)
                        self.tableData = profileDetail
                        DispatchQueue.main.async {
                            self.coreDataHelper.writeProfileData(jsonData) // write the data to core data.
                            if ((self.tableView.refreshControl?.isRefreshing) != nil) {
                                self.tableView.refreshControl?.endRefreshing()
                            }
                            self.tableView.reloadData()
                        }
                    } catch let parseErr {
                        showToast(parseErr.localizedDescription)
                        return
                    }
                }
                return
            }
        } else {
            showToast("Your internet connection appears to be offline")
            if let profileData = self.coreDataHelper.fetchProfileData(),
               let jsonData = profileData.userDetail {
                do {
                    let profileDetail = try JSONDecoder().decode(ProfileDetailModal.self, from: jsonData)
                    self.tableData = profileDetail
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } catch let parseErr {
                    print(parseErr.localizedDescription)
                    return
                }
            }
        }
    }
    
    
    // MARK : - To load data from json file that is stored locally
    
    @objc
    private func loadDataFromLocalJSON(_ sender: UIBarButtonItem) {
        if let localJSONPath = Bundle.main.path(forResource: "demoresponse", ofType: "json") {
            do {
                let jsonData = try Data(contentsOf: URL(fileURLWithPath: localJSONPath))
                let profileDetail = try JSONDecoder().decode(ProfileDetailModal.self, from: jsonData)
                self.tableData = profileDetail
                showToast("Data has been successfully loaded from local json file", textColor: .white, bgColor: .black)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch let parseErr {
                print(parseErr.localizedDescription)
                return
            }
        }
    }
}
