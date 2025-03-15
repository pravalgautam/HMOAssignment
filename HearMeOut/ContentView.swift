//
//  ContentView.swift
//  HearMeOut
//
//  Created by Praval Gautam on 11/03/25.
//
import SwiftUI
import AVFoundation

struct AudioVisualizerView: View {
    @State private var isPlaying = false
    @State private    var amplitudes: [CGFloat] = (0..<50).map { _ in CGFloat.random(in: 10...90) }
    @State private var rotationAngle: Double = 0
    @State private var scale: CGFloat = 1.0
    @State private var currentTime: Double = 0
    @State private var audioPlayer: AVAudioPlayer?
    
    @State private var audioDuration: Double = 90
    
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea(.all)
            
            HStack {
                ZStack {
                    Circle()
                        .stroke(Color.yellow, lineWidth: 3)
                        .frame(width: 40, height: 40)
                        .rotationEffect(.degrees(rotationAngle))
                        .scaleEffect(scale)
                        .animation(.easeInOut(duration: 0.5), value: rotationAngle)
                        .animation(.easeInOut(duration: 0.5), value: scale)
                    
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color.yellow)
                        .padding()
                }
                .padding(.trailing)
                .onTapGesture {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        isPlaying.toggle()
                        if isPlaying {
                            playAudio()
                        } else {
                            pauseAudio()
                        }
                    }
                }
                
                // Interactive Visualizer
                GeometryReader { geo in
                    HStack(spacing: 3) {
                        ForEach(amplitudes.indices, id: \.self) { index in
                            Capsule()
                                .fill(index < Int(currentTime / audioDuration * Double(amplitudes.count)) ? Color.yellow : Color.yellow.opacity(0.3))
                                .frame(width: 2, height: amplitudes[index])
                        }
                    }
                    .frame(height: 50)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let tapLocation = value.location.x
                                let totalWidth = geo.size.width
                                let newTime = (tapLocation / totalWidth) * audioDuration
                                
                                seekAudio(to: newTime)
                            }
                    )
                }
                .frame(height: 50)
            }
        }
        .onAppear {
            loadAudio()
        }
    }
    
    func loadAudio() {
        if let url = Bundle.main.url(forResource: "audio", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay()
                audioPlayer?.delegate = nil
                audioDuration = audioPlayer?.duration ?? 90
            } catch {
                print("Error loading audio file: \(error.localizedDescription)")
            }
        }
    }
    
    func playAudio() {
        audioPlayer?.play()
        startAnimation()
    }
    
    func pauseAudio() {
        audioPlayer?.pause()
        stopAnimation()
    }
    
    func seekAudio(to time: Double) {
        audioPlayer?.currentTime = time
        currentTime = time
    }
    
    func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { timer in
            withAnimation(.easeInOut(duration: 0.2)) {
                amplitudes = amplitudes.map { _ in CGFloat.random(in: 10...90) }
            }
            if let player = audioPlayer, player.isPlaying {
                currentTime = player.currentTime
            } else {
                timer.invalidate()
            }
        }
    }
    
    func stopAnimation() {
        audioPlayer?.pause()
    }
}

#Preview {
    AudioVisualizerView()
}
