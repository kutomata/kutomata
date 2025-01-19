//  MIT License
//
//  Copyright (c) 2024 Hansol Ju
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation

public struct Kutomata {

    private var existingText: String = String()
    private let korean = Korean()
    
    public init() { }
    
    /// 현재 저장된 텍스트를 모두 삭제하는 함수
    /// - 다음과 같은 상황에서 사용됩니다
    ///     - **텍스트 필드가 비어있을 때**
    ///     - 커서가 이동할 때(글자 단위 삭제와 자모 단위 삭제를 구별하기 위함)
    public mutating func clearExistingText() { existingText.removeAll() }
    
    public func getExistingText() -> String { existingText }

    /// 문자열이 전부 한글인지 확인하는 함수
    /// - Parameter string: 확인할 문자열
    /// - Returns: 한글이면 true, 아니면 false
    private func isHangul(_ string: String) -> Bool {
        return string.range(of: "^[\\p{Hangul}]+$", options: .regularExpression) != nil
    }
    
    /// 한글을 입력했을 때, 마지막 글자를 수정해야하는 지 여부와 수정 또는 추가해야하는 문자를 반환
    /// input 메서드를 사용하기 전에 커서 앞의 문자가 존재하지 않을 때, existingText를 clear 하는 작업이 선행되어야함
    public mutating func input(_ string: String) -> (needToModifyLastText: Bool, stringToInput: String) {
        
        // 입력된 문자가 띄어쓰기나 return이면 입력된 문자를 반환
        if string == " " || string == "\n" {
            existingText.removeAll()
            return (false, string)
        }
        
        // 입력한 문자가 한글로만 이루어지지 않았거나
        guard isHangul(string),
              // 이전에 입력된 문자가 없는 경우
              let lastCharacter = existingText.last
        else {
            // 입력된 문자를 반환
            existingText.append(string)
            return (false, string)
        }
        
        let lastString = String(lastCharacter)
        
        // 이전에 입력된 문자의 마지막이 한글이 아니라면 입력된 문자를 반환
        guard isHangul(lastString) else {
            existingText.append(string)
            return (false, string)
        }
        
        // 한글을 입력했고, 이전에 입력한 문자가 한글인 상황
        
        // 마지막 문자가 자음인 경우
        if let consonantIndex = korean.consonants[lastString] {
            // 입력된 문자가 모음인 경우
            if let vowelIndex = korean.vowels[string] {
                // 마지막 자음과 입력된 모음을 합친 글자 반환
                let newString = combine(consonantIndex, vowelIndex)
                changeLastStringOfExistingText(with: newString)
                return (true, newString)
                
            // 입력된 문자가 자음인 경우 입력된 자음을 반환
            } else {
                existingText.append(string)
                return (false, string)
            }
        }
        
        // 마지막 문자가 모음인 경우 입력된 문자를 반환
        if korean.vowels.keys.contains(lastString) {
            existingText.append(string)
            return (false, string)
        }
        
        // 마지막 문자가 초성, 중성, 종성으로 이루어진 글자인 경우
        
        // 1. 입력된 문자가 자음인 경우
        if let consonantIndex = korean.consonants[string] {
            let indexOfJongsung = containJongsungIndex(string: lastString)
            
            // 1-1. 마지막 글자에 종성이 없는 경우
            if indexOfJongsung == 0 {
                
                // 1-1-1. 입력된 자음을 종성으로 사용할 수 있는 경우, 종성을 추가한 글자 반환
                if let jongsungIndex = korean.jongsungIndex[string] {
                    let newString = getNewstring(lastString: lastString, indexToAdd: jongsungIndex)
                    changeLastStringOfExistingText(with: newString)
                    return (true, newString)
                
                // 1-1-2. 입력된 자음을 종성으로 사용할 수 없는 경우, 입력된 문자 반환
                } else {
                    existingText.append(string)
                    return (false, string)
                }
                
            // 1-2. 마지막 글자에 종성이 있는 경우
            } else {
                
                // 1-2-1. 입력된 자음을 기존 종성과 겹받침으로 만들 수 있는 경우, 종성을 조합한 글자 반환
                if let indexToAdd = korean.combinationOfJongsung[[indexOfJongsung, consonantIndex]] {
                    let newString = getNewstring(lastString: lastString, indexToAdd: indexToAdd)
                    changeLastStringOfExistingText(with: newString)
                    return (true, newString)
                    
                // 1-2-2. 입력된 자음을 기존 종성과 겹받침으로 만들 수 없는 경우, 입력된 문자 반환
                } else {
                    existingText.append(string)
                    return (false, string)
                }
            }
        }
        
        // 2. 입력된 글자가 모음인 경우
        if let vowelIndex = korean.vowels[string] {
            let indexOfJongsung = containJongsungIndex(string: lastString)
            
            // 2-1. 마지막 글자에 종성이 없는 경우, 입력된 문자 반환
            if indexOfJongsung == 0 {
                existingText.append(string)
                return (false, string)
                
                
            // 2-2. 마지막 글자에 종성이 있는 경우
            } else {
                // 2-2-1. 종성이 겹받침인 경우, 마지막 종성만 분리해서 초성으로 사용하고 새로운 2글자 반환
                if let (consonantIndex, indexToMinus) = korean.doubleJongsungs[indexOfJongsung] {
                    let newString = getNewstring(lastString: lastString, indexToMinus: indexToMinus) + combine(consonantIndex, vowelIndex)
                    changeLastStringOfExistingText(with: newString)
                    return (true, newString)
                    
                // 2-2-2. 종성이 겹받침이 아닌 경우, 종성을 분리해서 초성으로 사용하고 새로운 2글자 반환
                } else if let consonantIndex = korean.indexOfConsonantsWithJongsungIndex[indexOfJongsung] {
                    let newString = getNewstring(lastString: lastString, indexToMinus: UInt32(indexOfJongsung))
                    + combine(consonantIndex, vowelIndex)
                    changeLastStringOfExistingText(with: newString)
                    return (true, newString)
                }
            }
        }
        
        // 3. 입력된 문자가 보통의 한글이 아닌 경우 ex) ㅋㅋㅋ
        existingText.append(string)
        return (false, string)
    }
    
    /// 자음과 모음으로 한글을 반환하는 함수
    private func combine(_ consonantIndex: Int, _ vowelIndex: Int) -> String {
        let baseCode = 44032
        let syllableIndex = consonantIndex * 588 + vowelIndex * 28
        return String(UnicodeScalar(baseCode + syllableIndex)!)
    }
    
    /// 한글의 종성인덱스를 반환하는 함수, 없다면 nil
    private func containJongsungIndex(string: String) -> Int {
        let unicodeValue = string.unicodeScalars.first!.value
        let base = unicodeValue - 0xAC00
        return Int(base % 28)
    }
    
    private func getNewstring(lastString: String, indexToAdd: UInt32) -> String {
        return String(UnicodeScalar(lastString.unicodeScalars.first!.value + indexToAdd)!)
    }
    private func getNewstring(lastString: String, indexToMinus: UInt32) -> String {
        return String(UnicodeScalar(lastString.unicodeScalars.first!.value - indexToMinus)!)
    }
        
    /// 지우기 후 문자가 수정해야할 마지막 문자가 있다면 해당 문자를 반환, 없다면 nil을 반환
    /// needToModifyPreviousText가 ture인 경우는 "가아"에서 삭제를 할 때처럼 마지막 글자의 초성이 그 이전의 글자에 종성으로 쓰일 수 있는 경우
    /// 마지막 글자의 초성이 그 이전 글자의 초성인 경우 마지막 2글자를 수정해야하고 이때 반환값은 (true, "강")의 형태와 같음
    public mutating func deleteBackward() -> (needToModifyPreviousText: Bool, stringToInput: String?) {
        
        // 이전에 입력된 문자가 없다면 nil 반환
        guard let lastCharacter = existingText.last else { return (false, nil) }
        
        let lastString = String(lastCharacter)
        
        // 이전에 입력된 마지막 문자가 한글이 아니거나 자모인 경우, (false, nil) 반환
        if !isHangul(lastString)
            || korean.consonants.keys.contains(lastString)
            || korean.vowels.keys.contains(lastString)  {
            _ = existingText.popLast()
            return (false, nil)
        }
    
        // 마지막 문자가 초성, 중성, 종성으로 이루어진 글자인 경우
        let jongsungIndex = containJongsungIndex(string: lastString)
        // 종성이 없는 경우, 먼저 중성을 지운다
        if jongsungIndex == 0 {
            guard let chosung = getChosung(from: lastString) else {
                _ = existingText.popLast()
                return (false, nil)
            }
            
            // 마지막 글자의 이전 글자가 존재하지 않는 경우, (false, 초성) 반환
            guard existingText.count > 1,
                  let previousCharacter = existingText.suffix(2).first
            else {
                changeLastStringOfExistingText(with: chosung)
                return (false, chosung)
            }
            
            let previousString = String(previousCharacter)

            // 마지막 글자의 이전 글자가 초성, 중성, 종성으로 이루어진 글자가 아닌 경우, (false, 초성) 반환
            if !isHangul(previousString)
                || korean.consonants.keys.contains(previousString)
                || korean.vowels.keys.contains(previousString) {
                changeLastStringOfExistingText(with: chosung)
                return (false, chosung)
            }
            
            let jongsungIndexOfPreviousString = containJongsungIndex(string: previousString)
            // 마지막 글자의 이전 글자에 종성이 있는 경우
            guard jongsungIndexOfPreviousString == 0 else {
                
                // 초성을 마지막 글자의 이전 글자의 종성과 겹받침으로 만들 수 없는 경우, (false, 초성) 반환
                guard let consonantsIndex = korean.consonants[chosung],
                      let indexToAdd = korean.combinationOfJongsung[[jongsungIndexOfPreviousString, consonantsIndex]]
                else {
                    changeLastStringOfExistingText(with: chosung)
                    return (false, chosung)
                }
                
                // 초성을 마지막 글자의 이전 글자의 종성과 겹받침으로 만들 수 있는 경우, (true, 수정된 그 이전 글자) 반환
                let newString = getNewstring(lastString: previousString, indexToAdd: indexToAdd)
                _ = existingText.popLast()
                changeLastStringOfExistingText(with: newString)
                return (true, newString)
            }
            
            // 마지막 글자의 이전 글자가 종성이 없는 경우
            // 초성을 마지막 글자의 이전 글자에 종성으로 사용할 수 없는 경우, (false, 초성) 반환
            guard let newJongsungIndexOfPreviousString = korean.jongsungIndex[chosung] else {
                changeLastStringOfExistingText(with: chosung)
                return (false, chosung)
            }
            // 초성을 마지막 글자의 이전 글자에 종성으로 사용할 수 있는 경우, (true, 수정된 그 이전 글자) 반환
            let newString = getNewstring(lastString: previousString, indexToAdd: newJongsungIndexOfPreviousString)
            _ = existingText.popLast()
            changeLastStringOfExistingText(with: newString)
            return (true, newString)
        }
        
        // 종성이 있는 경우
        // 종성이 겹받침이 아닌 경우, 종성을 삭제한 글자 반환
        guard let (_, indextToMinus) = korean.doubleJongsungs[jongsungIndex] else {
            let newString = getNewstring(lastString: lastString, indexToMinus: UInt32(jongsungIndex))
            changeLastStringOfExistingText(with: newString)
            return (false, newString)
        }
        
        // 종성이 겹받침인 경우, 마지막 종성을 삭제한 글자 반환
        let newString = getNewstring(lastString: lastString, indexToMinus: indextToMinus)
        changeLastStringOfExistingText(with: newString)
        return (false, newString)
    }
    
    /// 한글의 초성을 반환하는 함수
    private func getChosung(from string: String) -> String? {
        let unicodeValue = string.unicodeScalars.first!.value
        let base = unicodeValue - 0xAC00
        let chosungIndex = Int(base / (21 * 28))
        return korean.chosungs[chosungIndex]
    }
    
    private mutating func changeLastStringOfExistingText(with newString: String) {
        _ = existingText.popLast()
        existingText.append(newString)
    }
}

