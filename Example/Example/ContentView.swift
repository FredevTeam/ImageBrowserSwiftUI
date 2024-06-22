//
//  ContentView.swift
//  Example
//
//  Created by Kan Tao on 2024/6/22.
//

import SwiftUI

struct ContentView: View {
    
    @State private var current: Int = 0

    @State private var sheet = false
    @State private var customSheet = false
    enum ShowType {
        case uiimage
        case names
        case urls
        case systemSF
    }
    
    
    @State private var showType: ShowType = .uiimage

    var body: some View {
        VStack(spacing: 10) {
            Button {
                self.showType = .uiimage
                sheet.toggle()
            } label: {
                Text("show uiimage")
            }
            
            Button {
                self.showType = .names
                sheet.toggle()
            } label: {
                Text("show local image with names")
            }
            
            Button {
                self.showType = .urls
                sheet.toggle()
            } label: {
                Text("show remote image with urls")
            }
            
            Button {
                self.showType = .systemSF
                sheet.toggle()
            } label: {
                Text("show system SF")
            }
        }
        .buttonBorderShape(.roundedRectangle)
        .sheet(isPresented: $sheet) {
            switch self.showType {
            case .uiimage:
                ImageBrowser(uiimages: uiimages, current: $current)
            case .names:
                ImageBrowser(names: names, current: $current)
            case .urls:
                ImageBrowser(urls: urls, current: $current)
            case .systemSF:
                ImageBrowser(systemImages: systemImages, current: $current)
            }
        }
        
        Button {
            self.showType = .names
            self.customSheet.toggle()
        } label: {
            Text("Custom page control")
        }
        .sheet(isPresented: $customSheet) {
            ImageBrowser(names: names, current: $current, pageControl: false)
                .overlay(alignment: .bottom) {
                    HStack(spacing: 5) {
                        ForEach(0..<names.count, id:\.self) { index in
                            Circle()
                                .frame(width: 8, height: 8)
                                .foregroundColor(index == self.current ? .blue : .white)
                                .onTapGesture(perform: { self.current = index })
                        }
                    }
                }
        }
    }
}


extension ContentView {
    private var uiimages: [UIImage]  {
        ["1","2","3","4","5","6","7","8"].compactMap({UIImage.init(named: $0)})
    }
    private var names:[String] {
        ["1","2","3","4","5","6","7","8"]
    }
    
    private var urls:[URL] { 
        [
        "https://images.unsplash.com/photo-1575936123452-b67c3203c357?q=80&w=2970&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
        "https://images.unsplash.com/photo-1566438480900-0609be27a4be?q=80&w=3094&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
        "https://images.unsplash.com/photo-1517329782449-810562a4ec2f?q=80&w=2963&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
        "https://images.unsplash.com/photo-1574169207511-e21a21c8075a?q=80&w=2680&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
        "https://images.unsplash.com/photo-1566438480900-0609be27a4be?q=80&w=2794&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
        "https://images.unsplash.com/photo-1574169208507-84376144848b?q=80&w=2679&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
        ].compactMap({URL.init(string: $0)})
    }
    
    private var systemImages:[String] {
        ["square.and.arrow.up.fill","eraser","pencil.tip.crop.circle.badge.arrow.forward.fill"]
    }
}


#Preview {
    ContentView()
}




struct ImageBrowser<Resource>: View {
    private var resources:[Resource] = []
    @Binding private  var current: Int
    private var system: Bool = false
    private var bundle: Bundle? = nil
    private var pageControl: Bool = true

    init(systemImages resources:[String], current: Binding<Int>, pageControl: Bool = true) where Resource == String {
        self.resources = resources
        self._current = current
        self.system = true
        self.pageControl = pageControl
    }
    
    init(names resources:[String], bundle: Bundle? = nil, current: Binding<Int>, pageControl: Bool = true) where Resource == String {
        self.resources = resources
        self._current = current
        self.bundle = bundle
        self.pageControl = pageControl
    }
    init(uiimages resource:[UIImage], current: Binding<Int>, pageControl: Bool = true) where Resource == UIImage {
        self.resources = resource
        self._current = current
        self.pageControl = pageControl
    }
    init(urls resource:[URL], current: Binding<Int>, pageControl: Bool = true) where Resource == URL {
        self.resources = resource
        self._current = current
        self.pageControl = pageControl
    }
    
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.black)
            
            if !resources.isEmpty {
                TabView(selection: $current,
                        content:  {
                    if resources is [UIImage] || resources is [String] {
                        ForEach(resources.indices,  id: \.self) { index in
                            ContentLocalImage(resource: resources[index], system: self.system)
                                .tag(index)
                                .ignoresSafeArea()
                        }
                    }else {
                        ForEach(resources.indices, id: \.self) { index in
                            ContentAsyncImage(resource: resources[index] as! URL)
                                .tag(index)
                                .ignoresSafeArea()
                        }
                    }
                })
                .tabViewStyle(.page(indexDisplayMode: self.pageControl ? .always :  .never))
            }else {
                Text("please set image name or urls")
                    .foregroundStyle(.white)
            }

        }
        .frame(maxWidth: .infinity,maxHeight: .infinity)
        .ignoresSafeArea()
        
    }
}

fileprivate struct ContentLocalImage<Resource>: View {
    var resource: Resource
    var system: Bool = false
    var bundle: Bundle? = nil
    // 缩放手势
    @State private var scale: CGFloat = 1.0
    @GestureState private var gestureScale: CGFloat = 1.0
    
    // 位移手势
    @State private var position: CGSize = .zero
    @GestureState private var gestureOffset: CGSize = .zero

    
    @State private var imageFrame: CGRect = .zero
    var body: some View {
        
        let dragGesture = DragGesture()
                   .updating($gestureOffset) { value, state, _ in
                       state = value.translation
                   }
                   .onChanged({ value in
                     
                   })
                   .onEnded { value in
                       var newOffset = CGSize(width: position.width + value.translation.width, height: position.height + value.translation.height)
                       
                       let maxSize = CGSize.init(width: imageFrame.width * scale, height: imageFrame.height * scale)
                       let leftMaxPadding = (maxSize.width - imageFrame.width ) / 2
                       if abs(newOffset.width) > leftMaxPadding {
                           newOffset.width = newOffset.width > 0 ? leftMaxPadding : -leftMaxPadding
                       }
                      
                       position = newOffset
                       
//                       position.width += value.translation.width
//                       position.height += value.translation.height
                   }
        
        let  magnificationGesture =  MagnificationGesture()
            .updating($gestureScale, body: {(value, gestureState, transaction) in
                guard value >= 1 else {return}
                gestureState = value
            })
            .onEnded({ value in
                let newScale = value * scale
                if newScale > 1 {
                    self.scale = newScale
                }else {
                    self.scale = 1
                    self.position = .zero
                }
            })
        
        ZStack(content: {
            Image.image(resource: resource, system: self.system,bundle: self.bundle)
                .resizable()
                .foregroundColor(self.system ? .white :  nil)
                .aspectRatio(contentMode: .fit)
                .scaleEffect(scale * gestureScale)
                .offset(gestureOffset)
                .offset(position)
                .gesture(magnificationGesture)
                .highPriorityGesture(
                    scale > 1 ?
                    dragGesture
                    : nil
                )
                .onTapGesture(count: 2, perform: {
                    withAnimation {
                        self.scale = 1
                        self.position = .zero
                    }
                })
                .background(
                    GeometryReader(content: { geometry in
                        Color.clear.onAppear {
                            imageFrame = geometry.frame(in: .global)
                        }
                    })
                )
        })
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(.rect)
        .onDisappear(perform: {
            scale = 1
        })
    }
}


fileprivate extension Image {
    static func image<T>(resource:T, system:Bool, bundle: Bundle?) -> Image {
        if let string = resource as? String, system {
            return Image(systemName: string)
        }
        if let uiimage = resource as? UIImage {
            return Image(uiImage: uiimage)
        }
        return Image((resource as? String) ?? "", bundle: bundle)
    }
}

fileprivate struct ContentAsyncImage: View {
    var resource: URL
    // 缩放手势
    @State private var scale: CGFloat = 1.0
    @GestureState private var gestureScale: CGFloat = 1.0
    
    // 位移手势
    @State private var position: CGSize = .zero
    @GestureState private var gestureOffset: CGSize = .zero

    
    @State private var imageFrame: CGRect = .zero
    var body: some View {
        
        let dragGesture = DragGesture()
                   .updating($gestureOffset) { value, state, _ in
                       state = value.translation
                   }
                   .onChanged({ value in
                     
                   })
                   .onEnded { value in
                       var newOffset = CGSize(width: position.width + value.translation.width, height: position.height + value.translation.height)
                       
                       let maxSize = CGSize.init(width: imageFrame.width * scale, height: imageFrame.height * scale)
                       let leftMaxPadding = (maxSize.width - imageFrame.width ) / 2
                       if abs(newOffset.width) > leftMaxPadding {
                           newOffset.width = newOffset.width > 0 ? leftMaxPadding : -leftMaxPadding
                       }
                      
                       position = newOffset
                       
//                       position.width += value.translation.width
//                       position.height += value.translation.height
                   }
        
        let  magnificationGesture =  MagnificationGesture()
            .updating($gestureScale, body: {(value, gestureState, transaction) in
                guard value >= 1 else {return}
                gestureState = value
            })
            .onEnded({ value in
                let newScale = value * scale
                if newScale > 1 {
                    self.scale = newScale
                }else {
                    self.scale = 1
                    self.position = .zero
                }
            })
        
        ZStack(content: {
            AsyncImage(url: resource) { image in
                    image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(scale * gestureScale)
                    .offset(gestureOffset)
                    .offset(position)
                    .gesture(magnificationGesture)
                    .highPriorityGesture(
                        scale > 1 ?
                        dragGesture
                        : nil
                    )
                    .onTapGesture(count: 2, perform: {
                        withAnimation {
                            self.scale = 1
                            self.position = .zero
                        }
                    })
                    .background(
                        GeometryReader(content: { geometry in
                            Color.clear.onAppear {
                                imageFrame = geometry.frame(in: .global)
                            }
                        })
                    )
            } placeholder: {
                ProgressView()
            }
        })
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(.rect)
        .onDisappear(perform: {
            scale = 1
        })
    }
}
