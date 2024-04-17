(define-constant ERR_INVALID_INPUT (err u100))
(define-constant ERR_INVALID_RLP (err u101))
(define-constant ERR_INVALID_LENGTH (err u102))
(define-constant MAX_SIZE 512)

(define-private (rlp-decode-item (input (buff 512)))
  (let ((first-byte (unwrap-panic (element-at? input u0))))
    (if (< (buff-to-uint-be first-byte) u128)
        ;; If the first byte is less than 0x80 (128), it's a single byte item
        (ok (unwrap-panic (slice? input u0 u1)))
    (if (< (buff-to-uint-be first-byte) u184)
            ;; If the first byte is between 0x80 (128) and 0xb7 (183), it's a string item
            ;; The length of the string is the first byte minus 0x80 (128)
            (let ((item-length (- (buff-to-uint-be first-byte) u128)))
              (ok (unwrap-panic (slice? input u1 (+ u1 item-length)))))
            ;; If the first byte is between 0xb8 (184) and 0xbf (191), it's a string item with a long length
            ;; The number of bytes representing the length is the first byte minus 0xb7 (183)
            (let ((length-bytes-count (- (buff-to-uint-be first-byte) u183)))
              (if (> length-bytes-count u16)
                  ;; If the length of the length bytes is greater than 16, it's an invalid length
                  (err ERR_INVALID_LENGTH)
                  ;; Otherwise, parse the length bytes to get the actual length of the string
                  (let ((length-bytes (unwrap-panic (slice? input u1 (+ u1 length-bytes-count)))))
                    (let ((item-length (buff-to-uint-be (unwrap-panic (as-max-len? length-bytes u16)))))
                      (ok (unwrap-panic (slice? input (+ u1 length-bytes-count) (+ u1 length-bytes-count item-length))))))))))))

(define-private (rlp-decode-list (input (buff 512)))
  (let ((first-byte (unwrap-panic (element-at? input u0))))
    (if (< (buff-to-uint-be first-byte) u192)
        ;; If the first byte is less than 0xc0 (192), it's not a valid RLP list
        (err ERR_INVALID_RLP)
        (if (< (buff-to-uint-be first-byte) u248)
            ;; If the first byte is between 0xc0 (192) and 0xf7 (247), it's a list with a short length
            ;; The length of the list is the first byte minus 0xc0 (192)
            (let ((list-length (- (buff-to-uint-be first-byte) u192)))
              (ok (rlp-decode-list-items (unwrap-panic (slice? input u1 (+ u1 list-length))))))
            ;; If the first byte is between 0xf8 (248) and 0xff (255), it's a list with a long length
            ;; The number of bytes representing the length is the first byte minus 0xf7 (247)
            (let ((length-bytes-count (- (buff-to-uint-be first-byte) u247)))
              (if (> length-bytes-count u16)
                  ;; If the length of the length bytes is greater than 16, it's an invalid length
                  (err ERR_INVALID_LENGTH)
                  ;; Otherwise, parse the length bytes to get the actual length of the list
                  (let ((length-bytes (unwrap-panic (slice? input u1 (+ u1 length-bytes-count)))))
                    (let ((list-length (buff-to-uint-be (unwrap-panic (as-max-len? length-bytes u16)))))
                      (ok (rlp-decode-list-items (unwrap-panic (slice? input (+ u1 length-bytes-count) (+ u1 length-bytes-count list-length)))))))))))))

(define-private (rlp-decode-list-items (input (buff 512)))
  (fold rlp-decode-item-fold (list ) input))

(define-private (rlp-decode-item-fold (decoded-items (list 512 (buff 512))) (input (buff 512)))
  ;; Decode the next item in the input
  (let ((item (unwrap-panic (rlp-decode-item input))))
    (let ((item-length (len item)))
      ;; Slice the input to remove the decoded item
      (let ((remaining-input (unwrap-panic (slice? input item-length (len input)))))
        ;; Append the decoded item to the list of decoded items
        (ok (append decoded-items item))))))

(define-read-only (rlp-decode (input (buff 512)))
  (begin
    ;; Assert that the input is not empty
    (asserts! (> (len input) u0) ERR_INVALID_INPUT)
    (let ((first-byte (unwrap-panic (element-at? input u0))))
      (if (< (buff-to-uint-be first-byte) u192)
          ;; If the first byte is less than 0xc0 (192), it's an RLP item
          (rlp-decode-item input)
          ;; Otherwise, it's an RLP list
          (rlp-decode-list input)))))
