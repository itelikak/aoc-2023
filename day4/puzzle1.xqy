let $input := fn:doc("/aoc/day4/inputfile.txt")
let $cards := fn:tokenize($input,"\n")
let $card-values := for $card in $cards
                    let $win-numbers := fn:tokenize(fn:normalize-space(fn:tokenize(fn:tokenize($card, "\|")[1],":")[2])," ")
                    let $play-numbers := fn:tokenize(fn:normalize-space(fn:tokenize($card, "\|")[2])," ")
                    let $count-map := json:object()
                                        => map:with("count",0)
                    let $count := for $each in $play-numbers
                                  return if ($each = $win-numbers)
                                         then map:put($count-map,"count",(map:get($count-map,"count") + 1))
                                         else ()
                    return if (map:get($count-map,"count") eq 0) 
                           then () 
                           else math:pow(2,map:get($count-map,"count") - 1)
return fn:sum($card-values)