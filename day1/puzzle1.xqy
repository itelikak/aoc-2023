let $doc := fn:doc("/aoc/day1/file.txt")
let $lines := fn:tokenize($doc,"\n")
let $numbers := (0 to 9)

let $all-numbers := for $line in $lines

                    let $number-as-string := fn:replace($line, '[A-Za-z]', '')
                    let $length := fn:string-length($number-as-string)
                    let $first-value := fn:substring($number-as-string,1,1)
                    let $last-value := fn:substring($number-as-string,$length)
                    let $first-and-last := fn:concat($first-value,$last-value) ! xs:int(.)
                    return $first-and-last
                    
return fn:sum(($all-numbers))
