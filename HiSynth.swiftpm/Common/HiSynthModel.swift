//
//  File.swift
//
//
//  Created by Bill Chen on 2023/4/3.
//
import SwiftUI
import Foundation

class MyModel: ObservableObject {
    @Published var myData: String = "Hello, world!"
}

struct MyView: View {
    @State private var showDetail: Bool = false
    @EnvironmentObject var myModel: MyModel
    
    var body: some View {
        VStack {
            Text(myModel.myData)
            Button("Show Detail") {
                showDetail = true
            }
        }
        .sheet(isPresented: $showDetail) {
            DetailView(detailData: $myModel.myData)
        }
    }
}

struct DetailView: View {
    @Binding var detailData: String
    
    var body: some View {
        TextField("Enter detail data", text: $detailData)
    }
}
//
//
//struct DetailViewProvider: PreviewProvider {
//    static var previews: some View {
//        MyView(myModel: MyModel())
//            .previewDevice(PreviewDevice(rawValue: "iPhone 13"))
//    }
//}
//
