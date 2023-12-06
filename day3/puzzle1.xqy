declare function local:recur($line-with-nums,$posn)
{
let $curr := fn:substring($line-with-nums,$posn + 1,1)
return if ($curr eq ".")
       then ()
       else 
           if (fn:exists($curr) and fn:not($curr = ""))
           then
               let $next := local:recur($line-with-nums,$posn + 1)
               return $curr || $next 
           else ()
};

let $input := fn:doc("/aoc/day3/inputfile.txt")
let $lines := fn:tokenize($input,"\n")
let $values :=  for $line at $pos in $lines
                let $line-with-nums := fn:replace($line, '[^.0-9]', '.')
                let $map := json:object()

                let $numbers := for $each at $posn in (1 to string-length($line-with-nums))

                                return if (fn:substring($line-with-nums,$posn,1) eq ".")
                                       then ()
                                       else if ($posn le map:get($map,"total"))
                                       then $posn
                                       else 
                                           let $curr := fn:substring($line-with-nums,$posn,1)
                                           return if ($posn eq fn:string-length($line-with-nums))
                                                  then map:put($map,$posn || "-" || $curr,json:object()
                                                       =>map:with("position",$posn)
                                                       =>map:with("length",fn:string-length($curr)))
                                                  else 
                                                     let $next := local:recur($line-with-nums,$posn)
                                                     let $val := $curr || $next
                                                     return (map:put($map,$posn || "-" || $val,json:object()
                                                                 =>map:with("position",$posn)
                                                                 =>map:with("length",fn:string-length($val))

                                                                 ),
                                                                 map:put($map,"total",($posn + fn:string-length($val)) - 1 ))



                let $chars := for $number in map:keys($map)[fn:not(.="total")]
                              
                              let $position-of-number := map:get(map:get($map,$number),"position")
                              let $length-of-number := map:get(map:get($map,$number),"length")
                              let $line-chars := for $each at $pos in (1 to fn:string-length($line))
                                                 return fn:substring($line,$pos,1)

                              let $line-check := if ($position-of-number eq 1)
                                                 then 
                                                     for $each-char in $line-chars[1 to ($length-of-number + 1)]
                                                         return if (fn:matches($each-char,'[^.0-9]'))
                                                                then $number
                                                                else ()
                                                 else 
                                                     for $each-char in $line-chars[($position-of-number - 1) to ($position-of-number + $length-of-number)]
                                                     return if (fn:matches($each-char,'[^.0-9]'))
                                                            then $number
                                                            else ()

                              let $next-line := $lines[$pos+1]
                              let $next-line-chars := for $each at $pos in (1 to fn:string-length($next-line))
                                                      return fn:substring($next-line,$pos,1)
                              let $check := if ($position-of-number eq 1)
                                             then 
                                                 for $each-char in ($next-line-chars[1 to ($length-of-number + 1)])
                                                 return if (fn:matches($each-char,'[^.0-9]'))
                                                        then $number
                                                        else ()
                                             else 
                                                 for $each-char in $next-line-chars[($position-of-number - 1) to ($position-of-number + $length-of-number)]
                                                 return if (fn:matches($each-char,'[^.0-9]'))
                                                        then $number
                                                        else ()

                              let $prev-line := $lines[$pos - 1]
                              let $prev-line-chars := for $each at $pos in (1 to fn:string-length($prev-line))
                                                      return fn:substring($prev-line,$pos,1)
                              let $check2 := if ($position-of-number eq 1)
                                             then 
                                                 for $each-char in ($prev-line-chars[1 to ($length-of-number + 1)])
                                                 return if (fn:matches($each-char,'[^.0-9]'))
                                                        then $number
                                                        else ()
                                             else 
                                                 for $each-char in $prev-line-chars[($position-of-number - 1) to ($position-of-number + $length-of-number)]
                                                 return if (fn:matches($each-char,'[^.0-9]'))
                                                        then $number
                                                        else ()

                               return if (fn:exists($line-check) or fn:exists($check) or fn:exists($check2))
                                      then ($number ! fn:tokenize(.,"-"))[2] ! xs:int(.)
                                      else ()
                   return $chars
              
return fn:sum(($values))
