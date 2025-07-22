import Foundation

func calculateSimilarity(_ input: String, _ target: String) -> Int {
    if input.isEmpty || target.isEmpty {
        return 0
    }
    
    if input == target {
        return 100
    }
    
    let inputChars = Array(input)
    let targetChars = Array(target)
    
    // 편집 거리 계산 (Levenshtein Distance)
    let distance = levenshteinDistance(inputChars, targetChars)
    let maxLength = max(inputChars.count, targetChars.count)
    
    // 유사도 계산 (0-100)
    let similarity = 100 - (distance * 100 / maxLength)
    
    return max(0, similarity)
}

private func levenshteinDistance(_ s1: [Character], _ s2: [Character]) -> Int {
    let m = s1.count
    let n = s2.count
    
    if m == 0 { return n }
    if n == 0 { return m }
    
    var matrix = Array(repeating: Array(repeating: 0, count: n + 1), count: m + 1)
    
    // 초기화
    for i in 0...m {
        matrix[i][0] = i
    }
    for j in 0...n {
        matrix[0][j] = j
    }
    
    // 거리 계산
    for i in 1...m {
        for j in 1...n {
            let cost = s1[i-1] == s2[j-1] ? 0 : 1
            matrix[i][j] = min(
                matrix[i-1][j] + 1,     // 삭제
                matrix[i][j-1] + 1,     // 삽입
                matrix[i-1][j-1] + cost // 대체
            )
        }
    }
    
    return matrix[m][n]
}