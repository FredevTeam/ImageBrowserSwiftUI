// The Swift Programming Language
// https://docs.swift.org/swift-book
import SwiftUI

public struct ImageBrowser<Resource>: View {
    private var resources:[Resource] = []
    @Binding private var current: Int
    private var system: Bool = false
    private var bundle: Bundle? = nil
    private var pageControl: Bool = true

    public init(systemImages resources:[String], current: Binding<Int>, pageControl: Bool = true) where Resource == String {
        self.resources = resources
        self._current = current
        self.system = true
        self.pageControl = pageControl
    }
    
    public init(names resources:[String], bundle: Bundle? = nil, current: Binding<Int>, pageControl: Bool = true) where Resource == String {
        self.resources = resources
        self._current = current
        self.bundle = bundle
        self.pageControl = pageControl
    }
    public init(uiimages resource:[UIImage], current: Binding<Int>, pageControl: Bool = true) where Resource == UIImage {
        self.resources = resource
        self._current = current
        self.pageControl = pageControl
    }
    public init(urls resource:[URL], current: Binding<Int>, pageControl: Bool = true) where Resource == URL {
        self.resources = resource
        self._current = current
        self.pageControl = pageControl
    }
    
    
    public var body: some View {
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
