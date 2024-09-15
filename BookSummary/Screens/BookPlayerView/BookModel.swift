//
//  BookModel.swift
//  BookSummary
//
//  Created by Olya Lutsyk on 15.09.2024.
//

import Foundation

struct Book: Identifiable, Equatable {
    let id: UUID
    let title: String
    let imageName: String
    let chapters: [BookChapter]
}

struct BookChapter: Equatable {
    let title: String
    let audioFileName: String
    let duration: TimeInterval
}

extension Book {
    static let mockData = Book(
        id: UUID(0),
        title: "title",
        imageName: "BookCover",
        chapters: [
            BookChapter(
                title: "Chapter 1. Lorem ipsumdolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                audioFileName: "audio0",
                duration: 302),
            BookChapter(
                title: "Chapter 2. Lorem ipsum** dolor sit amet",
                audioFileName: "audio1",
                duration: 296),
        ]
    )
}
