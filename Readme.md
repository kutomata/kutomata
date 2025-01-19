# Kutomata (코토마타)
Swift에서 한글 입력을 자연스럽게 처리할 수 있도록 도와주는 라이브러리입니다.
Kutomata helps Swift handle Korean input naturally.

### Feature (특징)
- 자음, 모음, 글자(초성, 중성, 종성(optional)으로 이루어진)를 입력하거나 삭제할 수 있습니다.
- 모든 자음과 모든 모음을 입력할 수 있습니다.
- 자음, 모음, 한글, 그 외의 문자를 입력하는 경우에 따라 입력되야 하는 마지막 글자 또는 마지막 두 글자를 반환합니다.
- 종성을 가지고 있는 글자에 자음을 더한 경우, 겹받침으로 처리할 수 있습니다. e.g., 갑+ㅅ -> 값
- 종성을 가지고 있는 글자에 모음을 더한 경우, 종성을 분리 후 새로운 글자를 생성할 수 있습니다. e.g., 몫+ㅗ -> 목소
- 겹받침을 가지고 있는 글자에 모음을 더한 경우, 겹받침을 분리 후 마지막 자음을 초성으로한 새로운 글자를 생성할 수 있습니다.
- 문자를 삭제처리할 수 있고, 수정되어야 하는 마지막 글자 또는 마지막 두 글자를 반환합니다.
- 자모 단위, 글자 단위를 구분해서 삭제처리를 할 수 있습니다.

- Allows input and deletion of characters composed of consonants, vowels, and characters(which consist of chosung, joonsung, and jongsung).
- Supports input of all consonants and all vowels.
- Returns the last character or the last two characters based on the input type (consonant, vowel, Korean, or other characters).
- Handles the addition of consonants to a character with a jongsung to form a double final consonants(겹받침)
. e.g., "갑" + "ㅅ" → "값".
- Handles the addition of vowels to a character with a jongsung by splitting the jongsung and forming a new character. e.g., "몫" + "ㅗ" → "목소".
- Handles the addition of vowels to a character with a double final consonants by splitting the final jongsung and using the final jongsung as the chosung for the new character.
- Allows deletion of characters and returns the last modified character or the last two modified characters.
- Supports deletion by distinguishing between units of consonants/vowels and character.

## Installation using SPM

## Usage
```swift
private var kutomata = Kutomata()

override func textDidChange(_ textInput: (any UITextInput)?) {
    kutomata.clearExistingText()
}

func inputCharacter(_ string: String) {

    guard textDocumentProxy.hasText else {
        kutomata.clearExistingText()
        _ = kutomata.input(string)
        textDocumentProxy.insertText(string)
        return
    }
    
    let result = kutomata.input(string)
    if result.needToModifyLastText {
        textDocumentProxy.deleteBackward()
    }
    
    textDocumentProxy.insertText(result.stringToInput)
}

func deleteCharacter() {

    let result = kutomata.deleteBackward()

    textDocumentProxy.deleteBackward()

    guard let stringToInput = result.stringToInput else { return }
    
    if result.needToModifyPreviousText,
        let beforeInput = textDocumentProxy.documentContextBeforeInput,
        beforeInput.count > 1 {
        textDocumentProxy.deleteBackward()
    }
    
    textDocumentProxy.insertText(stringToInput)
}
```

### License
Kutomata is under the MIT License.
