//
// SettingsViewController.swift
//

import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: SettingsDelegate?
    var playbackSetting: PlaybackSetting!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupCancelBarButton()
        setupSaveBarButton()
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func setupCancelBarButton() {
        cancelBarButton.target = self
        cancelBarButton.action = #selector(cancelTapped(_:))
    }
    
    func setupSaveBarButton() {
        saveBarButton.target = self
        saveBarButton.action = #selector(saveTapped(_:))
    }
    
    @objc func cancelTapped(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true)
    }

    @objc func saveTapped(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.delegate?.updateSetting(with: self.playbackSetting)
        }
    }
}

extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        default:
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.tintColor = .white
        
        switch indexPath.section {
        default:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Ascending"
                cell.accessoryType = (playbackSetting.isAscending ? .checkmark : .none)
            default:
                cell.textLabel?.text = "Descending"
                cell.accessoryType = (playbackSetting.isAscending ? .none : .checkmark)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UITableViewHeaderFooterView()
        
        switch section {
        default:
            header.textLabel?.text = "Creation Date"
        }
        
        return header
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = .white
    }
}

protocol SettingsDelegate: AnyObject {
    func updateSetting(with: PlaybackSetting)
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let previousCellIndex = playbackSetting.isAscending ? 0 : 1
        guard previousCellIndex != indexPath.row,
              let previousCell = tableView.cellForRow(at: IndexPath(row: previousCellIndex, section: 0)),
              let currentCell = tableView.cellForRow(at: indexPath) else { return }

        previousCell.accessoryType = .none
        currentCell.accessoryType = .checkmark
    
        switch indexPath.row{
        case 0:
            playbackSetting.isAscending = true
        default:
            playbackSetting.isAscending = false
        }
    }
}
