//
//  ProjectListView.swift
//  Agile Board Team
//
//  Created by Huynh Tan Phu on 3/13/20.
//  Copyright © 2020 Filesoft. All rights reserved.
//

import SwiftUI
import SwiftUIRefresh

struct ProjectListView: View {
    
    @EnvironmentObject var viewModel: ProjectListModel
    
    init() {
        UITableView.appearance().separatorStyle = .none
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isFailed {
                    ErrorBannerView(message: viewModel.errorMessage, display: $viewModel.isFailed)
                }
                SearchView(search: $viewModel.search, showCancelButton: $viewModel.showCancelButton)
                    .navigationBarTitle("Projects")
                    .navigationBarHidden(self.viewModel.showCancelButton).animation(.default)
                List {
                    ForEach(viewModel.isFiltering ? viewModel.filteredProjects : viewModel.projects) { (project)  in
                        ProjectRowView(project: project).onAppear {
                            self.onAppear(project)
                        }
                    }
                    
                    if viewModel.isLoadingMore {
                        LastRowView(isLoadingMore: $viewModel.isLoadingMore)
                    }
                    
                }
                .pullToRefresh(isShowing: $viewModel.isShowing) {
                    self.viewModel.reload(animated: false)
                }
                .resignKeyboardOnDragGesture()
                
            }
            .overlay(CircleProgressView(display: $viewModel.isInprogress))
            .overlay(ProjectNotFoundView())
        }
    }
    
   
    func onAppear(_ project: Project) {
        guard viewModel.isLastRow(id: project.id) else { return }
        viewModel.loadMore(animated: true)
    }
}

struct ProjectListView_Previews: PreviewProvider {
    static var previews: some View {    
        ProjectListView().environmentObject(ProjectListModel())
    }
}

struct ProjectNotFoundView: View {
    @EnvironmentObject var viewModel: ProjectListModel
    
    var body: some View {
        Group {
            if viewModel.emptySearchResult && viewModel.isFiltering {
                NotFoundView(title: "Project Not Found")
            }
        }
    }
}
