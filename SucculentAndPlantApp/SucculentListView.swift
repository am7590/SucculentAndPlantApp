//
//  SucculentListView.swift
//  SucculentAndPlantApp
//
//  Created by Alek Michelson on 5/7/23.
//

import SwiftUI
import CoreData
import _PhotosUI_SwiftUI

struct SucculentListView: View {
    @EnvironmentObject var router: Router
    @EnvironmentObject var imagePicker: ImagePicker
    @EnvironmentObject var viewModel: SucculentListViewModel
    @EnvironmentObject var shareService: PersistImageService
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)])
    var items: FetchedResults<Item>
    
    var body: some View {
        NavigationStack(path: $router.path) {
            GeometryReader { proxy in
                let cellWidth = proxy.size.width/2 - 24
                
                Group {
                    if items.isEmpty {
                        EmptyGridView(listType: .allSucculents)
                            .padding(.leading, 24)
                    } else {
                        ScrollView {
                            if viewModel.isList {
                                listView(width: cellWidth)
                            } else {
                                LazyVGrid(columns: viewModel.gridItemLayout, spacing: 16) {
                                    listView(width: cellWidth)
                                }
                            }
                        }
                    }
                }
                .navigationTitle("All Succulents")
                .searchable(text: $viewModel.searchText, prompt: "Search")
                .toolbar {
                    CustomToolbar()
                }
                .sheet(item: $viewModel.formState) { $0 }
                .alert("Image Updated", isPresented: $viewModel.imageExists) {
                    Button("OK") {}
                }
                .onChange(of: imagePicker.uiImage) { newImage in
                    viewModel.handleImageChange(newImage)
                }
                .onChange(of: shareService.codeableImage) { codableImage in
                    updateOrRestoreImage(codableImage, items)
                }
                .onChange(of: viewModel.searchText) { value in
                    updateItemsFromSearchQuery(value)
                }
                .onOpenURL { url in
                    handleDeepLinkingToItem(url: url)
                }
                .onAppear {
                    //wiggle.toggle()
                }
            }
        }
    }
    
    func listView(width cellWidth: CGFloat) -> some View {
        ForEach(items) { item in
            Button {
                viewModel.formState = .edit(item)
            } label: {
                Image(uiImage: item.uiImage)
                    .resizable()
                    .scaledToFill()
                    .modifier(CustomFrameModifier(active: !viewModel.isList, width: cellWidth))
                    .clipped()
                    .cornerRadius(24)
                    .shadow(radius: 8.0)
//                    .rotationEffect(.degrees(viewModel.wiggle ? 2.5 : 0))
//                    .rotation3DEffect(.degrees(viewModel.wiggle ? 5 : 0), axis: (x: 0, y: viewModel.wiggle ? -5: 0, z: 0))
//                    .animation(.easeInOut(duration: 0.15).repeat(while: viewModel.wiggle), value: viewModel.wiggle)
            }
        }
        .padding(.horizontal)

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SucculentListView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

//struct LazyVGridModifier: ViewModifier {
//    var active : Bool
//    var gridItemLayout = [GridItem(.adaptive(minimum: 150))]
//
//    @ViewBuilder func body(content: Content) -> some View {
//        if active {
//            LazyVGrid(columns: gridItemLayout, spacing: 16) {
//                content
//            }
//        } else {
//            content
//        }
//    }
//}

//    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
//            offsets.map { items[$0] }.forEach(viewContext.delete)
//
//            do {
//                try viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//
//    }
    
//    private func addItem() {
//        withAnimation {
//            let newItem = Item(context: viewContext)
//            newItem.timestamp = Date()
//
//            do {
//                try viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }
    
    //private let itemFormatter: DateFormatter = {
    //    let formatter = DateFormatter()
    //    formatter.dateStyle = .short
    //    formatter.timeStyle = .medium
    //    return formatter
    //}()
