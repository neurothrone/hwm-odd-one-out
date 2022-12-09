//
//  ContentView.swift
//  OddOneOut
//
//  Created by Zaid Neurothrone on 2022-12-09.
//

import SwiftUI

struct ContentView: View {
  private static let gridSize = 10
  private static let maxLevels = 8
  private static let maxLives = 3

  @State private var images = [
    "elephant", "giraffe", "hippo", "monkey", "panda",
    "parrot", "penguin", "pig", "rabbit", "snake"
  ]

  @State private var layout = Array(
    repeating: "empty",
    count: gridSize * gridSize
  )

  @State private var currentLevel = 1
  @State private var livesRemaining = Self.maxLives
  @State private var isGameOver = false

  var body: some View {
    content
      .onAppear(perform: createLevel)
      .contentShape(Rectangle())
      .contextMenu {
        Button("Start New Game", action: restartGame)
      }
  }

  private var content: some View {
    ZStack {
      VStack {
        HStack {
          Text("Level: \(currentLevel) / \(Self.maxLevels)")
          Spacer()
          Text("Odd One Out")
            .font(.system(size: 36, weight: .thin))
            .fixedSize()
          Spacer()
          Text("Lives: \(livesRemaining) / \(Self.maxLives)")
        }
        .padding(.horizontal)

        ForEach(.zero..<Self.gridSize, id: \.self) { row in
          HStack {
            ForEach(.zero..<Self.gridSize, id: \.self) { column in
              if image(row, column) == "empty" {
                Rectangle()
                  .fill(.clear)
                  .frame(width: 64, height: 64)
              } else {
                Button {
                  processAnswer(at: row, column)
                } label: {
                  Image(image(row, column))
                }
                .buttonStyle(.borderless)
              }
            }
          }
        }
      }
      .opacity(isGameOver ? 0.2 : 1)
      .disabled(isGameOver)

      if isGameOver {
        VStack {
          Text("Game over!")
            .font(.largeTitle)

          Text(livesRemaining <= .zero ? "You lose." : "You win.")

          Button("Play Again", action: restartGame)
          .font(.headline)
          .foregroundColor(.white)
          .buttonStyle(.borderless)
          .padding(20)
          .background(.blue)
          .clipShape(Capsule())
        }
      }
    }
  }
}


extension ContentView {
  private func image(_ row: Int, _ column: Int) -> String {
    layout[row * Self.gridSize + column]
  }

  private func generateLayout(items: Int) {
    // remove any existing layouts
    layout.removeAll(keepingCapacity: true)

    // randomize the image order, and consider the first image to be the correct animal
    images.shuffle()
    layout.append(images[0])

    // prepare to loop through the other animals
    var numUsed = 0
    var itemCount = 1

    for _ in 1..<items {
      // place the current animal image and add to the counter
      layout.append(images[itemCount])
      numUsed += 1

      // if we already placed two, move to the next animal image
      if (numUsed == 2) {
        numUsed = 0
        itemCount += 1
      }

      // if we placed all the animal images, go back to index 1.
      if (itemCount == images.count) {
        itemCount = 1
      }
    }

    // fill the remainder of our array with empty rectangles then shuffle the layout
    layout += Array(repeating: "empty", count: 100 - layout.count)
    layout.shuffle()
  }

  private func createLevel() {
    if currentLevel > Self.maxLevels {
      withAnimation {
        isGameOver = true
      }
    } else {
      let numbersOfItems = [0, 5, 15, 25, 35, 49, 65, 81, 100]
      generateLayout(items: numbersOfItems[currentLevel])
    }
  }

  private func processAnswer(at row: Int, _ column: Int) {
    if image(row, column) == images[.zero] {
      // They clicked the correct animal
      currentLevel += 1
      createLevel()
      return
    }

    // they clicked the wrong animal
    if currentLevel > 1 {
      // take the current level down by 1 if we can
      currentLevel -= 1
    }

    livesRemaining -= 1

    if livesRemaining <= .zero {
      isGameOver = true
    }

    // Create a new layout
    createLevel()
  }

  private func restartGame() {
    currentLevel = 1
    livesRemaining = Self.maxLives
    isGameOver = false
    createLevel()
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
