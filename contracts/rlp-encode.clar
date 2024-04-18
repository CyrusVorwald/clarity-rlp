(define-read-only  (encodeDeposit )
    (begin
       (ok (encode-buff-arr (list
          (unwrap-panic (as-max-len? (encode-string "Deposit") u500))
          (unwrap-panic (as-max-len? (encode-string "0x0000000000000000000000000000000000000003") u500))
          (unwrap-panic (as-max-len? (encode-string "0x0000000000000000000000000000000000001234") u500))
          (unwrap-panic (as-max-len? (encode-string "0x1.icon/cx5") u500))
          (unwrap-panic (as-max-len? (encode-uint u112356000000000000000000) u500))
          (unwrap-panic (as-max-len? (encode-buff 0x73776170) u500))
          (unwrap-panic (as-max-len?  (encode-arr (list
                        (unwrap-panic (as-max-len? (encode-string "0x0000000000000000000000000000000000000003") u500))
                        (unwrap-panic (as-max-len? (encode-string "0x0000000000000000000000000000000000001234") u500))
                      )) u500))
        )
      )
    )
  )
)


(define-read-only  (encode-string (message (string-ascii 500)))
    (let
        (   (encoded (unwrap-panic (to-consensus-buff? message)))
            (sliced  (unwrap-panic (slice? encoded u4  (len encoded))))
            (id (unwrap-panic  (to-consensus-buff? (+ u128 (buff-to-uint-le (unwrap-panic (element-at? sliced u0)))) )))
            (prefix (unwrap-panic  (element-at? id u16) ) )
            (res (replace-at? sliced u0 prefix ))
        )
        (unwrap-panic res)
    )
)

(define-read-only  (encode-uint (data uint))
  (encode-lenght (encode-uint-raw data))
)


(define-read-only  (encode-arr (objects (list 500 (buff 500))))
  (encode-list-lenght (encode-buff-arr objects))
)

(define-private (encode-buff-arr (objects (list 500 (buff 500))))
    (fold concat-buff objects 0x)
)

(define-private   (encode-buff (data (buff 500)))
    (if (< u1 (len data))
      (encode-buff-long data)
      data
    )
)

(define-private (rm-lead (a (buff 500)) (b (buff 500)))
    (if (is-eq 0x00 a)
        (if (is-eq 0x b)
            b
            (unwrap-panic (as-max-len? (concat b a) u500))
        )
        (unwrap-panic (as-max-len? (concat b a) u500))
    )
)

(define-private (encode-uint-raw (data uint))
    (let (
        (encoded (unwrap-panic (to-consensus-buff? data)))
        (sliced (unwrap-panic (slice? encoded u4  (len encoded))))
        )
        (unwrap-panic (as-max-len?  ( fold rm-lead sliced 0x) u500))
    )
)

(define-private (encode-lenght (data (buff 500)))
  (let (
        (length (len data))
        )
        (if (<= length u1 )
            data
            (if (<= length u55 )
                (concat  (encode-uint-raw (+ u128 length)) data)
                (concat  (encode-uint-raw (+ u183 length)) data)
            )
        )
    )
)

(define-private (encode-list-lenght (data (buff 500)))
  (let (
            (length (len data))
        )
        (if (<= length u55 )
            (concat  (encode-uint-raw (+ u192 length)) data)
            (let (
                    (encoded_lenght (encode-uint-raw length))
                    (prefix (concat (encode-uint-raw (+ u247 (len encoded_lenght))) encoded_lenght))
                )
                (concat  prefix data)
            )
        )
    )
)

(define-private (concat-buff (a (buff 500)) (b (buff 500)))
  (unwrap-panic (as-max-len? (concat b a) u500))
)

(define-private (encode-buff-long (data (buff 500)))
  (let
        ((prefix (unwrap-panic  (element-at?  (unwrap-panic (to-consensus-buff? (+ u128 (len data))))  u16) )))
        (concat prefix data)
    )
)
