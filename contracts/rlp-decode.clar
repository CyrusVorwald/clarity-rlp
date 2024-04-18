(define-constant ERR_INVALID_INPUT (err u100))
(define-constant ERR_INVALID_RLP (err u101))
(define-constant ERR_INVALID_LENGTH (err u102))
(define-constant MAX_SIZE 512)

(define-public  (decodeDeposit (input (buff 1024)))
    (ok (let (
            (decoded-list (decode-list  input))
            (decoded1 (decode-item   decoded-list))
            (method   (decode-string (get-item decoded1)))
            (decoded2 (decode-item   (get-rlp  decoded1)))
            (token    (decode-string (get-item decoded2)))
            (decoded3 (decode-item   (get-rlp  decoded2)))
            (from     (decode-string (get-item decoded3)))
            (decoded4 (decode-item   (get-rlp decoded3)))
            (to       (decode-string (get-item decoded4)))
            (decoded5 (decode-item   (get-rlp decoded4)))
            (amount   (decode-uint   (get-item decoded5)))
            (decoded6 (decode-item   (get-rlp decoded4)))
            (data     (get-item decoded5))

        )
            (print method)
            (print token)
            (print from)
            (print to)
            (print data)
            (print amount)
        )
    )
)

(define-read-only (get-item (input (list 2 (buff 1024))))
  (unwrap-panic (element-at? input u0))
)

(define-read-only (get-rlp (input (list 2 (buff 1024))))
  (unwrap-panic (element-at? input u1))
)

(define-read-only (decode-string (input (buff 1024)))
  (let (
        (length (unwrap-panic  (to-consensus-buff? (len input))))
        (sliced (unwrap-panic  (slice? length u13  (len length))))
        (data (concat sliced input))
        (res (concat 0x0d data))
    )
    (unwrap-panic (from-consensus-buff? (string-ascii 1024) res))
  )
)

(define-read-only (decode-uint (input (buff 1024)))
    (buff-to-uint-be (unwrap-panic (as-max-len? input u16)))
)

(define-read-only (decode-item (input (buff 1024)))
(let ((first-byte (unwrap-panic (element-at? input u0))))
    (if (< (buff-to-uint-be first-byte) u128)
        ;; If the first byte is less than 0x80 (128), it's a single byte item
       (list (default-to 0x (slice? input u0 u1)) (default-to 0x  (slice? input u1 (len input))))
    (if (< (buff-to-uint-be first-byte) u184)
            ;; If the first byte is between 0x80 (128) and 0xb7 (183), it's a string item
            ;; The length of the string is the first byte minus 0x80 (128)
            (let ((item-length (- (buff-to-uint-be first-byte) u128)))
              (list (default-to 0x (slice? input u1 (+ u1 item-length))) (default-to 0x (slice? input (+ u1 item-length) (len input)))))
            ;; If the first byte is between 0xb8 (184) and 0xbf (191), it's a string item with a long length
            ;; The number of bytes representing the length is the first byte minus 0xb7 (183)
            (let ((length-bytes-count (- (buff-to-uint-be first-byte) u183)))
              ;; If the length of the length bytes is greater than 16, it's an invalid length
              ;;  (unwrap-panic (verify-long-len length-bytes-count))
            ;; Otherwise, parse the length bytes to get the actual length of the string
            (let ((length-bytes (unwrap-panic (slice? input u1 (+ u1 length-bytes-count)))))
            (let ((item-length (buff-to-uint-be (unwrap-panic (as-max-len? length-bytes u16)))))
                (list (default-to 0x (slice? input (+ u1 length-bytes-count) (+ u1 length-bytes-count item-length))) (default-to 0x (slice? input (+ u1 length-bytes-count item-length) (len input))) ))))))))



;; (define-read-only (to-list (input (buff 1024)))
;;   (let (
;;     (data (decode-list input))
;;     (length  (buff-to-uint-be (unwrap-panic (as-max-len? (get-item data) u16))))
;;     (lst  (get-rlp data))
;;   )
;;   (print length)
;;   (if (is-eq length u0)
;;       (list )
;;   (if (is-eq length u1)
;;       (list1 lst)
;;   (if (is-eq length u2)
;;       (list2 lst)
;;   (if (is-eq length u3)
;;       (list3 lst)
;;       (list )
;;   )))))
;; )


(define-read-only (decode-list (input (buff 1024)))
    (let (
        (first-byte (unwrap-panic (element-at? input u0)))
      )
      ;; If the first byte is less than 0xc0 (192), it's not a valid RLP list
      (unwrap-panic (verify-is-list first-byte))
      (if (< (buff-to-uint-be first-byte) u248)
          ;; If the first byte is between 0xc0 (192) and 0xf7 (247), it's a list with a short length
          ;; The length of the list is the first byte minus 0xc0 (192)
          (let ((list-length (- (buff-to-uint-be first-byte) u192)))
              (unwrap-panic (as-max-len? (default-to 0x (slice? input u1 (+ u1 list-length))) u500)))
          ;; If the first byte is between 0xf8 (248) and 0xff (255), it's a list with a long length
          ;; The number of bytes representing the length is the first byte minus 0xf7 (247)
          (let (
              (length-bytes-count (- (buff-to-uint-be first-byte) u247))
              )
              ;; If the length of the length bytes is greater than 16, it's an invalid length
              (unwrap-panic (verify-long-len length-bytes-count))
              ;; Otherwise, parse the length bytes to get the actual length of the list
              (unwrap-panic (as-max-len? (unwrap-panic (slice? input (+ u1 length-bytes-count) (len input))) u500))))))

(define-read-only (verify-is-list (prefix (buff 1)))
    (if (< (buff-to-uint-be prefix) u192)
        (err ERR_INVALID_RLP)
        (ok 1)
    )
)

(define-read-only (verify-long-len (lenght uint))
  (if (> lenght u16)
    (err ERR_INVALID_LENGTH)
    (ok 1)
  )
)