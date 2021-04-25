//
//  projectDetailViewController.swift
//  proTodo
//
//  Created by 성다연 on 2021/04/19.
//  Copyright © 2021 성다연. All rights reserved.
//

import UIKit
import MobileCoreServices

class ProjectBoardViewController: UIViewController {
    @IBOutlet weak var projectDateLabel: UILabel! {
        didSet {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy년 MM월 dd일"
            var date = formatter.string(from: project.startDate)
            
            if project.endDate != nil {
                let end = formatter.string(from: project.endDate!)
                date.append(" ~ " + end)
            }
            
            projectDateLabel.text = date
            
        }
    }
    @IBOutlet weak var boardCollectionView: UICollectionView! {
        didSet {
            boardCollectionView.delegate = self
            boardCollectionView.dataSource = self
        }
    }
    @IBOutlet weak var todoListView: UIView!
    @IBAction func showTodoListButton(_ sender: UIButton) {
    }
    
    @IBOutlet weak var firstTableView: UITableView!{
        didSet {
            firstTableView.delegate = self
            firstTableView.dataSource = self
            firstTableView.dropDelegate = self
            firstTableView.dragDelegate = self
            firstTableView.dragInteractionEnabled = true
        }
    }
    @IBOutlet weak var todoListTableView: UITableView! {
        didSet {
            todoListTableView.delegate = self
            todoListTableView.dataSource = self
            todoListTableView.dropDelegate = self
            todoListTableView.dragDelegate = self
            todoListTableView.dragInteractionEnabled = true
        }
    }

    static let cellID = "ProjectBoardViewController"
    private var selectIndexPath : (IndexPath, Bool)?
    private var firstItems : [Todo] = []
    private var todoLists = TodoModel.shared.list
    
    var project : Project!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = project.name
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
}

extension ProjectBoardViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProjectBoardTableViewCell.cellID) as! ProjectBoardTableViewCell
        cell.bindViewModel(todo: todoLists[indexPath.row])
        return cell
    }
}


extension ProjectBoardViewController : UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let itemProvider = NSItemProvider(object: todoLists[indexPath.row] as NSItemProviderWriting)
        selectIndexPath = (indexPath, false)
        return [UIDragItem(itemProvider: itemProvider)]
    }
    
    func tableView(_ tableView: UITableView, dragSessionDidEnd session: UIDragSession) {
        guard let selectIndexPath = selectIndexPath else { return }
       
        if selectIndexPath.1 {
            if tableView == firstTableView {
                firstItems.remove(at: selectIndexPath.0.row)
            } else {
                todoLists.remove(at: selectIndexPath.0.row)
//                secondItems.remove(at: selectIndexPath.0.row)
            }
            tableView.beginUpdates()
            tableView.deleteRows(at: [selectIndexPath.0], with: .automatic)
            tableView.endUpdates()
        }
    }
}


extension ProjectBoardViewController : UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: Todo.self)
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        var dropProposal = UITableViewDropProposal(operation: .cancel)
        guard session.items.count == 1 else { return dropProposal }
       
        if tableView.hasActiveDrag {
            if tableView.isEditing {
                dropProposal = UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
            }
        } else {
            if let indexPath = selectIndexPath {
                selectIndexPath = (indexPath.0, true)
            }
            // drag is comming from outside from app
            return UITableViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
        }
        return dropProposal
    }

    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        var destinationIndexPath = IndexPath(row: tableView.numberOfRows(inSection: 0), section: 0)
        if let indexpath = coordinator.destinationIndexPath {
            destinationIndexPath = indexpath
        }
        
        coordinator.session.loadObjects(ofClass: Todo.self) { [weak self] items in
            guard let subject = items as? [Todo] else { return }
            var indexPaths = [IndexPath]()
            
            for (index, value) in subject.enumerated() {
                let indexPath = IndexPath(row: destinationIndexPath.row + index, section: destinationIndexPath.section)
                
                if tableView == self?.firstTableView {
                    self?.firstItems.insert(value, at: indexPath.row)
                } else {
//                    self?.secondItems.insert(value, at: indexPath.row)
                }
                indexPaths.append(indexPath)
            }
            
            tableView.beginUpdates()
            tableView.insertRows(at: indexPaths, with: .automatic)
            tableView.endUpdates()
        }
    }
}


extension ProjectBoardViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return project.list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProjectBoardCollectionViewCell.cellID, for: indexPath) as! ProjectBoardCollectionViewCell
        cell.bindViewModel(board: project.list[indexPath.row])
        cell.handleBorder()
        return cell
    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 361, height: 646)
//    }
}