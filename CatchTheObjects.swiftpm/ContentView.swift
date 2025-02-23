import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var basketPosition: CGFloat = UIScreen.main.bounds.width / 2
    @State private var objectPosition: CGPoint = CGPoint(x: CGFloat.random(in: 50...350), y: 50) // Start at y: 50
    @State private var score: Int = 0
    @State private var isGameOver: Bool = false
    @State private var audioPlayer: AVAudioPlayer?
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // Background
            Color.blue.ignoresSafeArea()
            
            // Basket
            Image("basket")
                .resizable()
                .frame(width: 100, height: 100)
                .position(x: basketPosition, y: UIScreen.main.bounds.height - 100)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            basketPosition = value.location.x
                        }
                )
            
            // Falling Object
            Image("apple")
                .resizable()
                .frame(width: 50, height: 50)
                .border(Color.red, width: 2) // Debug border
                .position(objectPosition)
                .onAppear {
                    print("Apple image loaded") // Debug print
                }
                .onReceive(timer) { _ in
                    withAnimation {
                        objectPosition.y += 50
                        print("Object Position: \(objectPosition)") // Debug print
                        if objectPosition.y > UIScreen.main.bounds.height {
                            objectPosition = CGPoint(x: CGFloat.random(in: 50...350), y: 50)
                            isGameOver = true
                        }
                        if abs(objectPosition.x - basketPosition) < 50 && objectPosition.y > UIScreen.main.bounds.height - 150 {
                            score += 1
                            objectPosition = CGPoint(x: CGFloat.random(in: 50...350), y: 50)
                            playSound("catchSound.wav")
                        }
                    }
                }
            
            // Score Display
            Text("Score: \(score)")
                .font(.largeTitle)
                .foregroundColor(.white)
                .padding()
                .background(Color.black.opacity(0.5))
                .cornerRadius(10)
                .position(x: UIScreen.main.bounds.width / 2, y: 50)
            
            // Game Over Screen
            if isGameOver {
                VStack {
                    Text("Game Over!")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    Text("Final Score: \(score)")
                        .font(.title)
                    Button("Play Again") {
                        score = 0
                        isGameOver = false
                        objectPosition = CGPoint(x: CGFloat.random(in: 50...350), y: 50)
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.8))
            }
        }
        .onAppear {
            playSound("backgroundMusic.mp3", loop: true)
        }
    }
    
    func playSound(_ soundFile: String, loop: Bool = false) {
        if let path = Bundle.main.path(forResource: soundFile, ofType: nil) {
            print("Sound file found at: \(path)") // Debug print
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                audioPlayer?.play()
                if loop {
                    audioPlayer?.numberOfLoops = -1
                }
            } catch {
                print("Error playing sound: \(error)")
            }
        } else {
            print("Sound file not found: \(soundFile)")
        }
    }
}

@main
struct CatchTheObjectsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
