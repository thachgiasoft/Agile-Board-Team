//
//  IssueListView.swift
//  Agile Board Team
//
//  Created by Huynh Tan Phu on 3/13/20.
//  Copyright © 2020 Filesoft. All rights reserved.
//

import SwiftUI
import RefreshableList

struct IssueListView: View {
    @EnvironmentObject var issueListModel: IssueListModel
    
    var body: some View {
        
        NavigationView {
            VStack {
                NavigationBar()
                IssueErrorView()
                IssueSearchView()
               
                RefreshableList(showRefreshView: self.$issueListModel.isPulling){
                    ForEach(self.issueListModel.isFiltering ? self.issueListModel.filtedItems : self.issueListModel.items) { (issue)  in
                        NavigationLink(destination: IssueDetailView().environmentObject(IssueDetailModel(issue: issue)) ) {
                            IssueRowView(issue: issue)
                        }
                    }
                    if self.issueListModel.isLoadingMore {
                        LastRowView(isLoadingMore: self.$issueListModel.isLoadingMore)
                    }
                }
                .onRefreshPerform {
                    self.issueListModel.reload(byUsing: .pull)
                }
                .onLastPerform {
                    self.issueListModel.loadMore()
                }
                .onAppear {
                    self.issueListModel.reload(animated: true, whenEmpty: true)
                }
                .resignKeyboardOnDragGesture()
                .overlay(
                     IssueNotFoundView()
                )
                .overlay(
                    CircleProgressView(display: self.$issueListModel.isRefreshing)
                        .frame(width: 30, height: 30, alignment: .center)
                )
                
            }
        }
    }
    
}

struct IssueListView_Previews: PreviewProvider {
    static var previews: some View {
        IssueListView().environmentObject(IssueListModel(issues: issueData))
    }
}

struct IssueNotFoundView: View {
    @EnvironmentObject var issueListModel: IssueListModel
    @State var opactiy: Double = 0
    
    var body: some View {
        Group {
            if issueListModel.emptySearchResult && issueListModel.isFiltering {
                NotFoundView(title: "Issue Not Found")
                    .opacity(self.opactiy)
                    .onAppear {
                        withAnimation (.easeInOut(duration: 2)){
                            self.opactiy = 1
                        }
                }
                .onDisappear{
                    self.opactiy = 0
                }
            }
        }
    }
}

private struct NavTrailingView: View {
    @EnvironmentObject var issueListModel: IssueListModel
    
    var body: some View {
   
        HStack (spacing: 25) {
            Button(action: {
                withAnimation(.easeInOut(duration: 1)) {
                    self.issueListModel.showCancelButton = true
                }
            }) {
                Image(systemName: "magnifyingglass")
            }
            
            Button(action: {
                
            }) {
                Image(systemName: "plus")
            }
        }
    }
}

private struct NavigationBar: View {
    @EnvironmentObject var issueListModel: IssueListModel
    
    var body: some View {
        
        Rectangle()
            .frame(height: 0, alignment: .center)
            .navigationBarTitle("Issues", displayMode: .inline)
            .navigationBarItems(trailing: NavTrailingView() )
            .navigationBarHidden(issueListModel.showCancelButton)
    }
}

private struct IssueErrorView: View {
    @EnvironmentObject var issueListModel: IssueListModel
    
    var body: some View {
        Group {
            if self.issueListModel.isFailed {
                ErrorBannerView(message: self.issueListModel.errorMessage, display: self.$issueListModel.isFailed)
            }
        }
    }
}

private struct IssueSearchView: View {
    @EnvironmentObject var issueListModel: IssueListModel
    var body: some View {
        Group {
            if self.issueListModel.showCancelButton {
                SearchView(search: self.$issueListModel.search, showCancelButton: self.$issueListModel.showCancelButton)
            }
        }
    }
}
