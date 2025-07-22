import Foundation

func getChosung(_ char: Character) -> String {
    let choSung = ["ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ", "ㄹ", "ㅁ", "ㅂ", "ㅃ",
                   "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅉ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"]
    
    guard let scalar = char.unicodeScalars.first else { return String(char) }
    let unicode = scalar.value
    
    // 한글 유니코드 범위: 0xAC00(가) ~ 0xD7A3(힣)
    if unicode >= 0xAC00 && unicode <= 0xD7A3 {
        let index = Int((unicode - 0xAC00) / (21 * 28))
        return choSung[index]
    }
    
    return String(char)
}

func getRandomKoreanChar() -> Character {
    let consonants = ["ㄱ", "ㄴ", "ㄷ", "ㄹ", "ㅁ", "ㅂ", "ㅅ", "ㅇ", "ㅈ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"]
    let vowels = ["ㅏ", "ㅑ", "ㅓ", "ㅕ", "ㅗ", "ㅛ", "ㅜ", "ㅠ", "ㅡ", "ㅣ"]
    let finalConsonants = ["", "ㄱ", "ㄲ", "ㄳ", "ㄴ", "ㄵ", "ㄶ", "ㄷ", "ㄹ", "ㄺ", "ㄻ", "ㄼ", "ㄽ", "ㄾ", "ㄿ", "ㅀ", "ㅁ", "ㅂ", "ㅄ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"]
    
    let consonant = consonants.randomElement()!
    let vowel = vowels.randomElement()!
    let finalConsonant = finalConsonants.randomElement()!
    
    let consonantIndex = consonants.firstIndex(of: consonant)!
    let vowelIndex = vowels.firstIndex(of: vowel)!
    let finalConsonantIndex = finalConsonants.firstIndex(of: finalConsonant)!
    
    let unicode = 0xAC00 + (consonantIndex * 21 * 28) + (vowelIndex * 28) + finalConsonantIndex
    
    return Character(UnicodeScalar(unicode)!)
}