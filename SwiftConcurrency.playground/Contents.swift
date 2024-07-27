import UIKit
import Combine
import SwiftUI
import PlaygroundSupport

class ImageDownloadBootCamp {
    
    class ImageLoader {
        func downloadImage(urlString: String, completion: @escaping (UIImage?)->()) {
            guard let url = URL(string: urlString) else {
                completion(nil)
                return
            }
            URLSession.shared.dataTask(with: url) { [weak self] data, response , _ in
                let image = self?.handleData(data: data, response: response)
                completion(image)
            }.resume()
        }
        
        
        
        func downloadImage(urlString: String) -> AnyPublisher<UIImage?, Error> {
            guard let url = URL(string: urlString) else {
                return Just(nil)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            return URLSession.shared.dataTaskPublisher(for: url)
                .map(handleData)
                .mapError({ $0 })
                .eraseToAnyPublisher()
        }
        
        func downloadWithAsync(urlString: String) async throws -> UIImage? {
            guard let url = URL(string: urlString) else {
                throw URLError(.notConnectedToInternet)
            }
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                return handleData(data: data, response: response)
            } catch {
                throw error
            }
        }
        
        func handleData(data: Data?, response: URLResponse?) -> UIImage? {
            guard let data  = data, let image = UIImage(data: data) else {
                return nil
            }
            return image
        }
    }

    class DownloadImageViewModel: ObservableObject {
        @Published var image: UIImage? = nil
        private let imageLoader = ImageLoader()
        var cancellables = Set<AnyCancellable>()
        
        func fetchImage() async {
            let imageURL = "https://picsum.photos/200/300"
    //        imageLoader.downloadImage(urlString: imageURL) { [weak self] image in
    //            self? .image = image
    //        }
    //        imageLoader.downloadImage(urlString: imageURL)
    //            .receive(on: DispatchQueue.main)
    //            .sink { _ in
    //
    //        } receiveValue: { [weak self] image in
    //            self? .image = image
    //        }.store(in: &cancellables)
            let image  = try? await imageLoader.downloadWithAsync(urlString: imageURL)
            await MainActor.run {
                self.image = image
            }
        }
    }

    struct DownloadImageView: View {
        
        @StateObject private var viewModel = DownloadImageViewModel()
        
        var body: some View {
            ZStack{
                if let image = viewModel.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 250)
                }
            }.onAppear {
                Task {
                    await viewModel.fetchImage()
                }
            }
        }
    }
}

class AsyncBootCamp {
    class AsyncBootCampViewModel: ObservableObject {
        @Published var dataModel: [String] = []
        
    //    func addTitle1() {
    //        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
    //            let title = "Title 1: \(Thread.current)"
    //            self.dataModel.append(title)
    //        }
    //    }
    //
    //    func addTitle2() {
    //        DispatchQueue.global().asyncAfter(deadline: .now()+2) {
    //            let title = "Title 2: \(Thread.current)"
    //            DispatchQueue.main.async {
    //                self.dataModel.append(title)
    //            }
    //        }
    //    }
        
        func addAuthor1() async {
            let author1 = "Author 1: \(Thread.current)"
            self.dataModel.append(author1)
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            
            let author2 = "Author 2: \(Thread.current)"
            
            
            await MainActor.run {
                self.dataModel.append(author2)
                let author3 = "Author 3: \(Thread.current)"
                self.dataModel.append(author3)
            }
        }
        
        func addSomething() async {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            
            let something1 = "something 1: \(Thread.current)"
            
            
            await MainActor.run {
                self.dataModel.append(something1)
                let something2 = "something 2: \(Thread.current)"
                self.dataModel.append(something2)
            }
        }
    }

    struct AsyncBootCampView: View {
        
        @StateObject private var viewModel = AsyncBootCampViewModel()
        
        var body: some View {
            List {
                ForEach(viewModel.dataModel, id: \.self) { data in
                    Text(data)
                }
            }.onAppear {
                Task {
                    await viewModel.addAuthor1()
                    await viewModel.addSomething()
                    let finalText  = "Final text \(Thread.current)"
                    viewModel.dataModel.append(finalText)
                }
            }
        }
    }
}

class TaskBootCamp {
    
    class TaskBootCampViewModel: ObservableObject {
        
        @Published var image: UIImage? = nil
        @Published var image2: UIImage? = nil
        
        func fetchImage() async {
            guard let url = URL(string: "https://picsum.photos/200/300") else {
                return
            }
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                self.image = UIImage(data: data)
            } catch {
                print(error.localizedDescription)
            }
        }
        
        func fetchImage2() async {
            guard let url = URL(string: "https://picsum.photos/300/300") else {
                return
            }
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                self.image2 = UIImage(data: data)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    struct TaskBootCampView: View {
        
        @StateObject private var viewModel = TaskBootCampViewModel()
        var body: some View {
            VStack(spacing: 40) {
                if let image = viewModel.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 250)
                }
                if let image = viewModel.image2 {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 250)
                }
            }.task {
                await viewModel.fetchImage()
                await viewModel.fetchImage2()
            }
        }
    }
}

class AsyncLetBootCamp {
    
    struct AsyncLetBootCampView: View {
        
        @State private var images: [UIImage]  = []
        let columns = [GridItem(.flexible()), GridItem(.flexible())]
        
        var body: some View {
//            NavigationView {
                ScrollView(.vertical, showsIndicators: true) {
                    LazyVGrid(columns: columns) {
                        ForEach(images, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 150)
                            
                        }
                    }
                }
                .background(Color.black)
                .navigationBarTitle("Async Let 🥳", displayMode: .inline)
                .onAppear {
                    Task {
                        
                        do {
                            async let fetchImage1 = fetchImage()
                            async let fetchImage2 = fetchImage()
                            async let fetchImage3 = fetchImage()
                            async let fetchImage4 = fetchImage()
                            let (image1, image2, image3, image4) = await (try fetchImage1, try fetchImage2, try fetchImage3, try fetchImage4)
                            images.append(contentsOf: [image1, image2, image3, image4])
                            
                            
                            async let asyncImage = fetchImage()
                            async let asyncTitle = getTitle()
                            
                            let (image, title) = await (try asyncImage, asyncTitle)
//                            let image = try await fetchImage()
//                            self.images.append(image)
//                            
//                            let image1 = try await fetchImage()
//                            self.images.append(image1)
//                            
//                            let image2 = try await fetchImage()
//                            self.images.append(image2)
//                            
//                            let image3 = try await fetchImage()
//                            self.images.append(image3)
                            
                            print("image downloaded")
                        }
                        catch {
                            print(error.localizedDescription)
                        }
                    }
                }
                
//            }
            
        }
        
        private func getTitle() async -> String {
            return "New Title"
            
        }
        
        private func fetchImage() async throws -> UIImage {
            guard let url = URL(string: "https://picsum.photos/200/300") else {
                throw URLError(.badURL)
            }
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    return image
                } else {
                    throw URLError(.badURL)
                }
            } catch {
                throw error
            }
        }
    }
}

class TaskGroupBootCamp {
    
    class TaskGroupBootCampViewModel: ObservableObject{
        @Published var images: [UIImage]  = []
        let manager = TaskGroupDataManager()
        
        func fetchAllImages() async {
            if let images = try? await manager.fetchAllImagesWithTaskGroup() {
                self.images = images
            }
        }
    }
    
    class TaskGroupDataManager {
        
        func fetchAllImages() async throws -> [UIImage] {
            async let image1 = fetchImage()
            async let image2 = fetchImage()
            async let image3 = fetchImage()
            async let image4 = fetchImage()
            return await [try image1, try image2, try image3, try image4]
        }
        
        func fetchAllImagesWithTaskGroup() async throws -> [UIImage] {
            return try await withThrowingTaskGroup(of: UIImage?.self) { group in
                var images: [UIImage] = []
//                group.addTask {
//                    try await self.fetchImage()
//                }
//                group.addTask {
//                    try await self.fetchImage()
//                }
//                group.addTask {
//                    try await self.fetchImage()
//                }
//                group.addTask {
//                    try await self.fetchImage()
//                }
                for i in 1..<10 {
                    group.addTask {
                        try? await self.fetchImage()
                    }
                }
                for try await image in group {
                    if let image = image {
                        images.append(image)
                    }
                }
                return images
            }
        }
        
        func fetchImage(urlString: String = "https://picsum.photos/200/300") async throws -> UIImage {
            guard let url = URL(string: urlString) else {
                throw URLError(.badURL)
            }
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    return image
                } else {
                    throw URLError(.badURL)
                }
            } catch {
                throw error
            }
        }
    }
    
    struct TaskGroupBootCampView: View {
        
        @StateObject var viewModel: TaskGroupBootCampViewModel = TaskGroupBootCampViewModel()
        let columns = [GridItem(.flexible()), GridItem(.flexible())]
        
        var body: some View {
                ScrollView(.vertical, showsIndicators: true) {
                    LazyVGrid(columns: columns) {
                        ForEach(viewModel.images, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 150)
                            
                        }
                    }
                }
                .background(Color.black)
                .navigationBarTitle("Task Group Let 🥳", displayMode: .inline)
                .task {
                    await viewModel.fetchAllImages()
                }
            
        }
        
    }
}

class ContinuationBootCamp {
    
    private func isEvenNumber(number: Int, completion: @escaping (Bool) -> ()) {
        DispatchQueue.global().asyncAfter(deadline: .now()+2) {
            completion(true)
        }
    }

    private func isEvenNumber(number: Int, unsafe: Bool = false) async -> Bool {
        if unsafe {
            return await withUnsafeContinuation { continuation in
                if number%2 == 0 {
                    //continuation.resume(returning: true)
                    //continuation.resume(returning: true)
                } else {
                    continuation.resume(returning: false)
                }
            }
        } else {
            return await withCheckedContinuation { continuation in
                if number%2 == 0 {
                    //continuation.resume(returning: true)
                    //continuation.resume(returning: true)
                } else {
                    continuation.resume(returning: false)
                }
            }
        }
    }
    
    func startTesting() {
        Task {
            let isEven = await isEvenNumber(number: 5)
            print("5 is \(isEven ? "even" : "odd")")
            let isEven1 = await isEvenNumber(number: 3)
            print("3 is \(isEven1 ? "even" : "odd")")
            let isEven2 = await isEvenNumber(number: 4)
            print("4 is \(isEven2 ? "even" : "odd")")
        }
    }

}

class StructClassActorBootCamp {
    
    struct StructClassActorBootCampView: View {
        var body: some View {
            Text("Test")
                .onAppear{
                    structTest()
                }
        }
        
        private func structTest() {
            print("structTest")
            Task {
                await actorTest()
            }
        }
        
        private func actorTest() async {
            print("actorTest")
            
            let objectA = MyActor(title: "Starting title")
            await print("ObjectA: ", objectA.title)
            
            let objectB = objectA
            await print("ObjectB: ", objectB.title)
            
            await objectB.updateTitle(newTitle: "Second title")
            print("ObjectB title changed")
            
            await print("ObjectA: ", objectA.title)
            await print("ObjectB: ", objectB.title)
            
        }
        
        actor MyActor {
            var title: String
            
            init(title: String) {
                self.title = title
            }
            
            func updateTitle(newTitle: String) {
                self.title = newTitle
            }
        }
        
        
    }
}


//let continationBootcamp = ContinuationBootCamp()
//continationBootcamp.startTesting()

//let view = StructClassActorBootCamp.StructClassActorBootCampView()
//PlaygroundPage.current.setLiveView(view)
//print("Executed")

class Student: Identifiable {
    let id: Int
    
    init(_ id: Int) {
        self.id = id
    }
}

class ReferralViewModel: ObservableObject {
    @Published var students = [Student(1), Student(2), Student(3), Student(4)]
    
    func removeChild() {
        students.removeAll(where: { $0.id == 2 })
    }
}

struct ReferralView: View {
    
    @StateObject var viewModel = ReferralViewModel()
    
    var body: some View {
        VStack {
            ForEach(viewModel.students) { student in
                Text("Student \(student.id)")
            }
        }.onAppear {
            print("appear")
            DispatchQueue.main.asyncAfter(deadline: .now()+5) {
                viewModel.removeChild()
                print("child removed")
            }
        }
    }
}

let view = ReferralView()
PlaygroundPage.current.setLiveView(view)
print("Executed")
