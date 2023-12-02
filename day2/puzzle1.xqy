(:Q - Determine which games would have been possible 
if the bag had been loaded with only 12 red cubes, 13 green cubes, and 14 blue cubes. 
What is the sum of the IDs of those games?:)

declare function local:update-color-map($colour-map,$colour,$all-colours)
{
  let $colour-count := for $each in $all-colours
                       return if (fn:contains($each,$colour))
                              then fn:substring-before($each,$colour) ! xs:int(.)
                              else ()

  return map:put($colour-map,$colour,(map:get($colour-map,$colour),$colour-count))
};

let $doc := fn:doc("/aoc/day2/file1.txt")
let $games := fn:tokenize($doc,"\n")

let $red-max := 12
let $green-max := 13
let $blue-max := 14

let $final-game-ids := for $game in $games
                        let $rounds := fn:tokenize(fn:substring-after($game,":"),";")
                        let $game-id := fn:substring-before($game,":") ! fn:replace(.,"Game","") ! xs:int(.)
                        let $colour-map := json:object()
                        let $colours := for $round in $rounds
                                        let $all-colours := fn:tokenize($round,",") ! fn:replace(.," ","")
                                        let $red := local:update-color-map($colour-map,"red",$all-colours)
                                        let $green := local:update-color-map($colour-map,"green",$all-colours)
                                        let $blue := local:update-color-map($colour-map,"blue",$all-colours)

                                        return ()

                        return if (map:get($colour-map,"red") gt $red-max or 
                                   map:get($colour-map,"green") gt $green-max or
                                   map:get($colour-map,"blue") gt $blue-max)
                               then ()
                               else $game-id
                                
return fn:sum($final-game-ids)    
