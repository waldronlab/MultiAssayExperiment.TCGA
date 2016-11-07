## Find the index from Excel Range
excel_position <- function(letterIndex) {
    letterIndex <- toupper(letterIndex)
    stringLength <- nchar(letterIndex)
    lengthsVector <- sapply(seq_len(stringLength), function(i, letIdx) {
        which(LETTERS == substr(letIdx, i, i))
    }, letIdx = letterIndex)
    (sum(lengthsVector[-length(lengthsVector)]*26)) +
        (lengthsVector[length(lengthsVector)])
}
