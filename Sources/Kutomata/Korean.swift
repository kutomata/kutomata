//
//  Korean.swift
//  Kutomata
//
//  Created by Hansol Ju on 11/10/24.
//

import Foundation

struct Korean {
    let chosungs = ["ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ", "ㄹ", "ㅁ", "ㅂ", "ㅃ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅉ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"]
    let consonants = ["ㄱ": 0, "ㄲ": 1, "ㄴ": 2, "ㄷ": 3, "ㄸ": 4, "ㄹ": 5, "ㅁ": 6, "ㅂ": 7, "ㅃ": 8, "ㅅ": 9, "ㅆ": 10, "ㅇ": 11, "ㅈ": 12, "ㅉ": 13, "ㅊ": 14, "ㅋ": 15, "ㅌ": 16, "ㅍ": 17, "ㅎ": 18]
    let vowels = ["ㅏ": 0, "ㅐ": 1, "ㅑ": 2, "ㅒ": 3, "ㅓ": 4, "ㅔ": 5, "ㅕ": 6, "ㅖ": 7, "ㅗ": 8, "ㅘ": 9, "ㅙ": 10, "ㅚ": 11, "ㅛ": 12, "ㅜ": 13, "ㅝ": 14, "ㅞ": 15, "ㅟ": 16, "ㅠ": 17, "ㅡ": 18, "ㅢ": 19, "ㅣ": 20]
    let joongsungs = [
        "ㅏ", "ㅐ", "ㅑ", "ㅒ", "ㅓ", "ㅔ", "ㅕ", "ㅖ", "ㅗ", "ㅘ", "ㅙ", "ㅚ", "ㅛ", "ㅜ", "ㅝ", "ㅞ", "ㅟ", "ㅠ", "ㅡ", "ㅢ", "ㅣ"]


    /// [(분리가능한 종성의 인덱스): (두번째 자음의 초성 index, 빼줘야하는 index)]
    let doubleJongsungs: [Int : (Int, UInt32)] = [
        3: (9, 2), // ㄱㅅ
        5: (12, 1), // ㄴㅈ
        6: (18, 2), // ㄴㅎ
        9: (0, 1), // ㄹㄱ
        10: (6, 2), // ㄹㅁ
        11: (7, 3), // ㄹㅂ
        12: (9, 4), // ㄹㅅ
        13: (16, 5), // ㄹㅌ
        14: (17, 6), // ㄹㅍ
        15: (18, 7), // ㄹㅎ
        18: (9, 1)] // ㅂㅅ
    
    let jongsungIndex: [String: UInt32] = [
        "ㄱ": 1,
        "ㄲ": 2,
        "ㄴ": 4,
        "ㄷ": 7,
        "ㄹ": 8,
        "ㅁ": 16,
        "ㅂ": 17,
        "ㅅ": 19,
        "ㅆ": 20,
        "ㅇ": 21,
        "ㅈ": 22,
        "ㅊ": 23,
        "ㅋ": 24,
        "ㅌ": 25,
        "ㅍ": 26,
        "ㅎ": 27
    ]
    
    /// [종성Index, 초성Index], indexToAdd]
    let combinationOfJongsung: [[Int]: UInt32] = [
        [1, 9]: 2,
        [4, 12]: 1,
        [4, 18]: 2,
        [8, 0]: 1,
        [8, 6]: 2,
        [8, 7]: 3,
        [8, 9]: 4,
        [8, 16]: 5,
        [8, 17]: 6,
        [8, 18]: 7,
        [17, 9]: 1]
    
    let indexOfConsonantsWithJongsungIndex = [
        1: 0, // ㄱ
        2: 1, // ㄲ
        4: 2, // ㄴ
        7: 3, // ㄷ
        8: 5, // ㄹ
        16: 6, // ㅁ
        17: 7, // ㅂ
        19: 9, // ㅅ
        20: 10, // ㅆ
        21: 11, // ㅇ
        22: 12, // ㅈ
        23: 14, // ㅊ
        24: 15, // ㅋ
        25: 16, // ㅌ
        26: 17, // ㅍ
        27: 18 // ㅎ
    ]
}
