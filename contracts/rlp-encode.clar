(define-private (encode-byte (byte int))
  (if (< byte 0x80)
      ;; If the byte is less than 0x80 (128), it's a single byte item
      (unwrap-panic (as-max-len? (list byte) u1))
      ;; Otherwise, it's a single byte item with a length prefix
      ;; The length prefix is 0x80 (128) plus the length of the byte (1)
      (unwrap-panic (as-max-len? (list (+ 0x80 1) byte) u2))))

(define-private (encode-length (input-len uint) (offset uint))
  (if (< input-len u56)
      ;; If the input length is less than 56, it's a short string
      ;; The length is encoded as a single byte with the offset added
      (encode-byte (to-int (+ input-len offset)))
      ;; Otherwise, it's a long string
      ;; The length is encoded as a byte array using uint-to-buff
      (let ((len-buff (uint-to-buff input-len)))
        ;; The prefix is encoded as a single byte with the offset and the length of the byte array added
        (let ((prefix (encode-byte (to-int (+ (len len-buff) offset u55)))))
          ;; The prefix is concatenated with the length byte array
          (concat prefix len-buff)))))

(define-private (uint-to-buff (val uint))
  ;; Converts a uint to a byte array in big-endian order
  (get reverse
    (fold uint-to-buff-fold (list 0x val) (list u0 u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15))))

(define-private (uint-to-buff-fold (state (tuple (buff (buff 32)) (val uint))) (index uint))
  ;; Folds over the uint value to convert it to a byte array
  (let ((buff (get buff state))
        (val (get val state)))
    (if (is-eq val u0)
        ;; If the uint value is 0, return the current state
        state
        ;; Otherwise, encode the least significant byte and append it to the byte array
        (let ((byte (mod val u256)))
          (tuple (buff (concat buff (encode-byte (to-int byte))))
                 (val (/ val u256)))))))

(define-private (rlp-encode-buff (input (buff 1024)))
  (let ((input-len (len input)))
    (if (and (is-eq input-len u1) (< (unwrap-panic (element-at input u0)) u128))
        ;; If the input is a single byte item with a value less than 128, it's encoded as is
        input
        ;; Otherwise, encode the length prefix and concatenate it with the input
        (let ((length-prefix (encode-length input-len u128)))
          (concat length-prefix input)))))

(define-public (rlp-encode (input (buff 1024)))
  (let ((input-type (unwrap-panic (element-at input u0))))
    (if (is-eq input-type 0x00)
        ;; Assuming that if the input type is 0x00, it's a single item
        (rlp-encode-buff input)
        ;; Otherwise, it's a list of items
        (let ((items (unwrap-panic (element-at input u1))))
          ;; Encode the length prefix for the list with an offset of 192
          ;; Fold over the items and concatenate their encoded representations
          (fold rlp-encode-concat (encode-length (len items) u192) items)))))

(define-private (rlp-encode-concat (acc (buff 1024)) (item (buff 1024)))
  ;; Concatenates the encoded items in the list
  (concat acc (rlp-encode-buff item)))
