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

declare function local:next-line-comp($star-position,$lines-map,$pos,$number)
{
  let $next-line-star-pos-range := (($star-position  - 1 ) to ($star-position  + 1))
  let $next-line-map := map:get($lines-map,($pos + 1) ! xs:string(.))
  let $next-line-nums := for $next-n in map:keys($next-line-map)[fn:not(.="total")]
                          let $num-pos := map:get(map:get($next-line-map,$next-n),"position")
                          let $num-length := map:get(map:get($next-line-map,$next-n),"length")
                          let $num-last-pos := ($num-pos + $num-length) - 1
                          return if ($star-position  = (($num-pos - 1),($num-last-pos + 1)))
                                 then fn:tokenize($number,"-")[2] || "*" || fn:tokenize($next-n ,"-")[2]
                                 else ()
   return $next-line-nums
};

let $input := fn:doc("/aoc/day3/inputfile.txt")
let $lines := fn:tokenize($input,"\n")
let $lines-map := json:object()
let $populate-lines-map-with-numbers :=  
                          for $line at $pos in $lines
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
                                                                 =>map:with("length",fn:string-length($curr))
                                                                 =>map:with("line",$pos))
                                                            else 
                                                               let $next := local:recur($line-with-nums,$posn)
                                                               let $val := $curr || $next
                                                               return (map:put($map,$posn || "-" || $val,json:object()
                                                                           =>map:with("position",$posn)
                                                                           =>map:with("length",fn:string-length($val))
                                                                           =>map:with("line",$pos)

                                                                           ),
                                                                           map:put($map,"total",($posn + fn:string-length($val)) - 1 ))
                          return map:put($lines-map,$pos ! xs:string(.),$map)     
                                                           
let $curr-line-values :=  for $line at $pos in $lines
                          
                          let $map := map:get($lines-map,$pos ! xs:string(.))
                          
                          let $chars := for $number in map:keys($map)[fn:not(.="total")]

                                          let $position-of-number := map:get(map:get($map,$number),"position")
                                          let $length-of-number := map:get(map:get($map,$number),"length")
                                          let $line-chars := for $each at $pos in (1 to fn:string-length($line))
                                                             return fn:substring($line,$pos,1)

                                         
                                           let $pos-after-number := ($position-of-number + $length-of-number)
                                           let $pos-before-number := ($position-of-number - 1)
                                           
                                           return if ($line-chars[$pos-after-number] eq "*")
                                                  then 
                                                      let $curr-num := ($number ! fn:tokenize(.,"-"))[2]
                                                      let $next-num := for $num in map:keys($map)[fn:not(.="total")]
                                                                       return if (map:get(map:get($map,$num),"position") eq ($pos-after-number + 1))
                                                                              then ($num ! fn:tokenize(.,"-"))[2]
                                                                              else ()
                                                      return if (fn:exists($next-num))
                                                             then $curr-num || "*" || $next-num
                                                             else 
                                                                  let $star-position := $pos-after-number
                                                                  return local:next-line-comp($star-position,$lines-map,$pos,$number)
                                                             
                                                  else if ($pos-before-number eq 0)
                                                  then ()
                                                  else if (($line-chars[$pos-before-number] eq "*") and 
                                                            fn:not(($pos-before-number - 1) eq 0) and 
                                                            fn:matches($line-chars[$pos-before-number - 1],'[^0-9]'))
                                                  then 
                                                      let $star-position := $pos-before-number
                                                      return local:next-line-comp($star-position,$lines-map,$pos,$number)
                                                  else if ($line-chars[$pos-after-number] eq ".")
                                                  then 
                                                       let $next-num := for $nxt-numb in map:keys($map)[fn:not(.="total")]
                                                                        return if (map:get(map:get($map,$nxt-numb),"position") eq ($pos-after-number + 1))
                                                                               then $nxt-numb
                                                                               else ()
                                                        return if (fn:exists($next-num))
                                                               then 
                                                                   let $next-line := $lines[$pos + 1]
                                                                   let $next-line-chars := for $each at $pos in (1 to fn:string-length($next-line))
                                                                                            return fn:substring($next-line,$pos,1)

                                                                   let $next-line-star := $next-line-chars[$pos-after-number]
                                                                   let $prev-line := $lines[$pos - 1]
                                                                   let $prev-line-chars := for $each at $pos in (1 to fn:string-length($prev-line))
                                                                                            return fn:substring($prev-line,$pos,1)

                                                                   let $prev-line-star := $prev-line-chars[$pos-after-number]

                                                                   return if ($next-line-star eq "*" or $prev-line-star eq "*")
                                                                          then fn:tokenize($number,"-")[2] || "*" || fn:tokenize($next-num,"-")[2]
                                                                          else ()
                                                               else ()
                                                  else ()

                                         
                             let $_ := map:put($lines-map,$pos ! xs:string(.),$map)                
                             return $chars 
                             
let $next-lines-values := for $line at $pos in $lines
                          let $line-with-nums := fn:replace($line, '[^.0-9]', '.')
                          let $map := map:get($lines-map,$pos ! xs:string(.))
                          let $chars := for $number in map:keys($map)[fn:not(.="total")]

                                        let $position-of-number := map:get(map:get($map,$number),"position")
                                        let $length-of-number := map:get(map:get($map,$number),"length")
                                        let $next-line := $lines[$pos + 1]
                                        let $next-line-chars := for $each at $pos in (1 to fn:string-length($next-line))
                                                                return fn:substring($next-line,$pos,1)

                                        
                                         let $pos-range := (($position-of-number - 1) to  + ($position-of-number + $length-of-number))
                                         return if ($next-line-chars[$pos-range] = "*")
                                                then 
                                                    let $next-line-star-pos := (for $ec in $pos-range
                                                                                return if ($next-line-chars[$ec] = "*")
                                                                                       then $ec
                                                                                       else ())[1]
                                                    let $next-line-star-pos-range := (($next-line-star-pos - 1 ) to ($next-line-star-pos + 1))
                                                    let $next-line-map := map:get($lines-map,($pos + 1) ! xs:string(.))
                                                    let $next-line-nums := for $next-n in map:keys($next-line-map)[fn:not(.="total")]
                                                                            let $num-pos := map:get(map:get($next-line-map,$next-n),"position")
                                                                            let $num-length := map:get(map:get($next-line-map,$next-n),"length")
                                                                            let $num-last-pos := ($num-pos + $num-length) - 1
                                                                            return if ($next-line-star-pos = (($num-pos - 1),($num-last-pos + 1)))
                                                                                   then fn:tokenize($number,"-")[2] || "*" || fn:tokenize($next-n ,"-")[2]
                                                                                   else ()

                                                    let $ntn-line := $lines[$pos + 2]
                                                    let $ntn-line-nums := 
                                                           if (fn:exists($ntn-line))
                                                           then 
                                                              let $ntn-line-chars := for $each at $pos in (1 to fn:string-length($ntn-line))
                                                                                      return fn:substring($ntn-line,$pos,1)

                                                              let $ntn-line-map := map:get($lines-map,($pos + 2) ! xs:string(.))
                                                              let $ntn-numbers := for $ntn-n in map:keys($ntn-line-map)[fn:not(.="total")]
                                                                                  let $num-pos := map:get(map:get($ntn-line-map,$ntn-n),"position")
                                                                                  let $num-length := map:get(map:get($ntn-line-map,$ntn-n),"length")
                                                                                  let $num-range := ($num-pos to (($num-pos + $num-length) - 1))
                                                                                  let $in-range-num := for $star-range in $next-line-star-pos-range
                                                                                                        return if ($star-range = $num-range)
                                                                                                               then $ntn-n 
                                                                                                               else ()
                                                                                  return fn:distinct-values(($in-range-num))
                                                              return if (fn:exists($ntn-numbers))
                                                                     then 
                                                                         for $each-ntn-number in $ntn-numbers 
                                                                         return fn:tokenize($number,"-")[2] || "*" || fn:tokenize( $each-ntn-number,"-")[2]
                                                                     else ()
                                                           else ()
                                                      return ($next-line-nums,$ntn-line-nums)
                                                else ()
                                                
                           return $chars 
                           
return fn:sum(($curr-line-values,$next-lines-values) ! ((fn:tokenize(.,"\*")[1] ! xs:int(.)) * (fn:tokenize(.,"\*")[2] ! xs:int(.))))
