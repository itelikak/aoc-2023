(:have to load the input file (aoc-2023/day1/inputfile.txt) into database (I used MarkLogic):)

let $doc := fn:doc("/aoc-2023/day1/inputfile.txt")
let $lines := fn:tokenize($doc,"\n")
let $num-list := ("1","2","3","4","5","6","7","8","9")
let $updated-numbers := for $line in $lines

                          let $line := fn:lower-case($line)
                          
                          let $one := fn:replace($line,"one","1")
                          let $two := fn:replace($line,"two","2")
                          let $three := fn:replace($line,"three","3")
                          let $four := fn:replace($line,"four","4")
                          let $five := fn:replace($line,"five","5")
                          let $six := fn:replace($line,"six","6")
                          let $seven := fn:replace($line,"seven","7")
                          let $eight := fn:replace($line,"eight","8")
                          let $nine := fn:replace($line,"nine","9")
                          
                          let $check := map:map()
                          let $first-value := for $pos in (1 to fn:string-length($line))
                                              
                                              for $each in ($one,$two,$three,$four,$five,$six,$seven,$eight,$nine)
                                              return if (fn:exists(map:keys($check)))
                                                     then ()
                                                     else 
                                                         let $value-at-pos := fn:substring($each,$pos,1)
                                                         return if ($value-at-pos = $num-list)
                                                                then 
                                                                    let $_ := map:put($check,"check",$each)
                                                                    return $value-at-pos
                                                                else ()
                                  
                          let $check := map:map()  
                          let $last-value := for $pos in (0 to fn:string-length($line))
                                               
                                              for $each in ($one,$two,$three,$four,$five,$six,$seven,$eight,$nine)
                                              return if (fn:exists(map:keys($check)))
                                                     then ()
                                                     else 
                                                         let $value-at-pos := fn:substring($each,(fn:string-length($each) - $pos),1)
                                                         return if ($value-at-pos = $num-list)
                                                                then 
                                                                    let $_ := map:put($check,"check",$each)
                                                                    return $value-at-pos
                                                                else ()

                          return ($first-value || $last-value) ! xs:int(.)

return fn:sum($updated-numbers)
