extensions [ netsend ]

globals [
  r-file
  background
  mouse-click
  unit-size
  ;last-placed-waypoint
  association-root
  association-root-referee
  french-color
  german-color
  frontline-mid
  referee-no
  myTurtleScale
  retreat-flag
]

directed-link-breed [ waypoint-links waypoint-link ]
undirected-link-breed [ turtle-links turtle-link ]

breed [ reds red-unit ]
breed [ blues blue-unit ]

breed [ taxi-waypoints taxi-waypoint ]

breed [ transports transport ]

breed [ waypoints waypoint ]
breed [ units unit ]
breed [ transport-spawners transport-spawner ]

;front line/battle breeds
breed [ frontline_arrows frontline_arrow]
breed [ referees referee ]

;;DEFINE REDS (Germans);;
reds-own [
  soldierNo
  artilleryNo
]

;;DEFINE BLUES (French);;
blues-own [ 
  soldierNo
  artilleryNo
]

frontline_arrows-own [
 direction 
]

referees-own [
 french
 german
 referee_neighbors
]

transports-own [
  transport-type
  current-waypoint
  capacity
  current-units
  returning
]

transport-spawners-own [
  type-to-spawn
  number-to-spawn
  ticks-to-next-spawn
]

taxi-waypoints-own [
  path
  waypoint-number
]

; id is a random big number indentifying the waypoint
;
; next-waypoints is a list of lists where
; 0th item is id of next waypoint
; 1st item is type of path to that waypoint
; 2nd item is need - 1 or 0
; 3rd item is "last sent" - how many troops sent 
; ex. [ [ 123 "road" 1 1 ] [ 432 "rail" 1 0 ] [ 980 "road" 0 0 ] ]
waypoints-own [
  id
  next-waypoints
  previous-waypoints
  weight
  need
]

units-own [
  id
  org-soldiers
  cur-soldiers
  old-soldiers
  thresh-retreat
  rof
  hit_prob
  ammo_per_soldier
  weight
  next-waypoints
  previous-waypoints
  team
  need
  winning
]

to test
  ;ask turtles [netsend:send "bleh" random 10]
  ask turtles [send-position]
end

;;**
;; Clears the screen
;;**
to clear
  clear-all
  set-default-shape reds "arrow"
  set-default-shape blues "default"
  set-default-shape taxi-waypoints "triangle"
  set-default-shape frontline_arrows "arrow"
  set unit-size 5
  set last-placed-waypoint 0
  
  setup-patches

  netsend:send "reset" 0

  reset-ticks
  
end

;;**
;; Sets up the patches
;;**
to setup-patches
    clear-drawing
    ask patches [ set pcolor 38 ]
    set background abs (background - 1)
    ifelse background = 1 [
      import-drawing "background.png"
    ][
      ask patches [
      ]
    ]
end

;;**
;; Runs the simulation
;; **
to go
  set myTurtleScale 5000
  ;;ask reds [fd 1 rt random 90 lt random 90]
  ;;ask blues [fd 1 rt random 90 lt random 90]
  ask transports [ go-transport ]
  ;ask waypoints [ set label get-waypoint-weight self ]
  ask waypoints [ set label need ]
  ask referees [ go-referee ]
  ask frontline_arrows [ go-frontline_arrow ]
  ask units [ if (team = "german") [go-german] if (team = "french") [go-french] ]
  ask transport-spawners [ go-transport-spawner] 
  ask waypoint-links [ handle-visible ] 

  print retreat-flag
  if (retreat-flag = true) [
    print "RETREAT!!!!"
  ]
  
  tick
  
  if (ticks mod 10 = 0) [ask turtles [send-position]]
  
end

;;**
;; Sets up the simulation to run
;;**
to setup
  ;setup-patches
  ;setup-carth-form
  ;setup-rome-form
  
  clear
  ;set-default-shape reds "person"
  ;set-default-shape blues "person"
  
  ;;setup-red-form
  ;;setup-blue-form
  
  ;;***GLOBAL SETUP INFORMATION HERE***
  set french-color blue
  set german-color red
  set frontline-mid 10
  set referee-no 6
  set myTurtleScale 5000
  set retreat-flag false
  set total-reinforcements 13600
  
  setup-frontline
  setup-referee
  clear-plot
  
  reset-ticks
end

;;**
;; Loads the data
;;**
to load-form
  import-world file-name
  clear-plot
  set retreat-flag false
end

;;**
;; Saves the data
;;**
to save-form
  export-world file-name
  ;;save the red team coordinates
  ;carefully [ file-delete "red.txt" ][ write "File Not Deleted" ]
  ;file-open "red.txt"
  ;file-write ( count reds )

  ;ask reds [
  ;    file-write xcor
  ;    file-write ycor
  ;  ]
  ;
  ;file-close
  
  ;;save the blue team coordinates
  ;carefully [ file-delete "blue.txt" ][ write "File Not Deleted" ]
  ;file-open "blue.txt"
  ;file-write ( count blues )

  ;ask blues [
  ;    file-write xcor
  ;    file-write ycor
  ;  ]
  
  ;file-close
  
end

;;**
;; Adds a unit to the screen
;;**
to add-unit
  ;;TODO: Debug code temporarily creates soldiers in the 3rd quadrant to easily note the troop locations
    ;create-blues 1 [
    ;set color blue
    ;set xcor -10
    ;set ycor -10
  ;]
  
  if mouse-down? [ set mouse-click 1 ]
  
  if (mouse-down? = false and mouse-click = 1) [
    if type-to-add = "blue" [
      create-blues 1 [
        set color blue
        set xcor mouse-xcor
        set ycor mouse-ycor
        set size unit-size
      ]
    ]
    
    if type-to-add = "red" [
      create-reds 1 [
        set color red
        set xcor mouse-xcor
        set ycor mouse-ycor
        set size unit-size
      ]
    ]
    
    if type-to-add = "taxi" [
      create-transports 1 [
        set xcor mouse-xcor
        set ycor mouse-ycor
        ;set path path-number
        set current-waypoint 0
        set size 3
        set transport-type "taxi"
        set current-units 5
        ;set total-reinforcements (total-reinforcements - current-units)
        
        ;change shape of the transport depending on what kind of transport is being modeled
        if (transport-type = "taxi")
        [
          set shape "car right"
        ]
        if (transport-type = "train")
        [
          set shape "train right"
        ]
        if (transport-type = "foot")
        [
          set shape "person"
        ]
      ]
    ]
    
    if type-to-add = "waypoint" [
      create-waypoints 1 [
        set xcor mouse-xcor
        set ycor mouse-ycor
        set id random 10000000
        set size 1.5
        set next-waypoints []
        set previous-waypoints []
        set weight 0
        set shape "circle"
        set color sky
      ]
    ]
    
    if type-to-add = "french" [
      create-units 1 [
        set xcor mouse-xcor
        set ycor mouse-ycor
        set id random 10000000
        set shape "square"
        set color french-color
        set-soldiers unit-soldier-count
        set org-soldiers cur-soldiers
        set thresh-retreat 0.8
        set rof unit-rof
        set hit_prob unit-hit-prob
        set ammo_per_soldier unit-ammo-per-soldier
        set team "french"
        ;set weight random 5
        set next-waypoints []
        set previous-waypoints []
      ]
    ]
    
    if type-to-add = "german" [
      create-units 1 [
        set xcor mouse-xcor
        set ycor mouse-ycor
        set id random 10000000
        set shape "square"
        set color german-color
        set team "german"
        set-soldiers unit-soldier-count
        set org-soldiers cur-soldiers
        set thresh-retreat 0.8
        set rof unit-rof
        set hit_prob unit-hit-prob
        set ammo_per_soldier unit-ammo-per-soldier
        ;set weight random 5
        set next-waypoints []
        set previous-waypoints []
      ]
    ]
    
    if type-to-add = "taxi spawner" [
      create-transport-spawners 1 [
        set xcor mouse-xcor
        set ycor mouse-ycor
        ;set shape "square"
        set color blue
        set type-to-spawn "taxi"
        set number-to-spawn max-taxis
      ]
    ]
    
    if type-to-add = "train spawner" [
      create-transport-spawners 1 [
        set xcor mouse-xcor
        set ycor mouse-ycor
        ;set shape "square"
        set color green
        set type-to-spawn "train"
        set number-to-spawn max-trains
      ]
    ]
    
    set mouse-click 0
  ]
  
end

;;**
;; Handles the visiblity of the elements
;;**
to handle-visible
  ;;handle visilbity
  if (shape = "rail")
  [
     set hidden? show-rails
  ]
  if (shape = "road")
  [
    set hidden? show-roads
  ]
end

;;**
;; Sets up the red units
;;**
to setup-red-form
  ;;load red soldiers
  carefully [
  file-open "red.txt"
  let num-reds file-read
      
  while [num-reds > 0] [
    create-reds 1 [
      set color red
      set xcor file-read
      set ycor file-read
    ]
    set num-reds (num-reds - 1);
  ]
  
  ] [print "Error"]
  file-close
end

;;**
;; Sets up the blue units
;;**
to setup-blue-form
  ;;load blue soldiers
  carefully [
  file-open "blue.txt"
  let num-blues file-read
      
  while [num-blues > 0] [
    create-blues 1 [
      set color blue
      set xcor file-read
      set ycor file-read
    ]
    set num-blues (num-blues - 1);
  ]
  
  ] [print "Error"]
  file-close
end

to set-soldiers [newSoliderNo]
  set cur-soldiers newSoliderNo
  set weight cur-soldiers
  set size cur-soldiers / myTurtleScale
end

;;;;;;;;;; REFEREES ;;;;;;;;;;;

;;**
;; Sets up the referees
;;**
to setup-referee
  let start_y 20 + 3
  let loopNo 0
  ;;create 10 referees
  while [loopNo < referee-no] [
    create-referees 1 [
    set color black
    set shape "circle"
    set size .5
    set xcor frontline-mid
    set ycor start_y
    set referee_neighbors other frontline_arrows in-radius 5
    
    ]
  set loopNo (loopNo + 1)
  set start_y (start_y - 5)
  ]
end

to reset-all-units
  setup-patches
  ask units [set-soldiers 1000]
  ask frontline_arrows [set xcor 10]
  ask referees [set referee_neighbors (other frontline_arrows in-radius 5)]
  clear-plot 
  reset-ticks
end

;;**
;; Referee with ref the encounters
;;**
to go-referee
  
  let alpha .001
  let phi .002
  
  if (french != 0 and german != 0) [
    let french_strength ([cur-soldiers] of french) * ([rof] of french) * ([hit_prob] of french) * alpha
    let german_strength ([cur-soldiers] of german) * ([rof] of german) * ([hit_prob] of german) * phi
    
    print ([thresh-retreat] of french)
    
    let german-fight false
    let french-fight false
    
    if ([cur-soldiers] of french / [org-soldiers] of french > [thresh-retreat] of french) [
      set french-fight true
    ]
    
    if ([cur-soldiers] of german / [org-soldiers] of german > [thresh-retreat] of german) [
      set german-fight true
    ]
    
    if (french-fight = true) [
      ask german [set-soldiers (cur-soldiers - french_strength / 10)]
    ]
    
    if (german-fight = true) [
      ask french [set-soldiers (cur-soldiers - german_strength / 10)]
    ]
          
    
    if ([cur-soldiers] of french < 0) [
      ask french [set-soldiers 0]
    ]
    
    if ([cur-soldiers] of german < 0) [
      ask german [set-soldiers 0]
    ]
    
    let french-str [cur-soldiers] of french
    let german-str [cur-soldiers] of german
    ask referee_neighbors [set-frontline_arrow-direction (french-str - german-str) / 10000 ]
    ask french [ set winning (french-str - german-str) / 1000 ]
  ]
  
end

;; Sets assocation between referees to a unit (click referee first, then unit)
to associate-referees
  if mouse-down? and (mouse-click = 0) and (any? referees) [
    let closest-referee first sort-by [ [distancexy mouse-xcor mouse-ycor] of ?1 < [distancexy mouse-xcor mouse-ycor] of ?2 ] referees
    set association-root-referee closest-referee
    print "setting association-root"
    set mouse-click 1
  ]
  
  if (mouse-down? = false and mouse-click = 1 and any? units) [
    
    let closest-unit first sort-by [ [distancexy mouse-xcor mouse-ycor] of ?1 < [distancexy mouse-xcor mouse-ycor] of ?2 ] units
    if ([team] of closest-unit = "french")
    [
      ask association-root-referee [ set french closest-unit ]
    ]
    if ([team] of closest-unit = "german")
    [
      ask association-root-referee [ set german closest-unit ]
    ]
    
    set mouse-click 0
  ]

end

to-report total-french
  let val 0
  let retreat-total 0
  ask units [if team = "french" [set val (val + cur-soldiers)] ]  
  ask units [if (team = "french" and (cur-soldiers / org-soldiers < thresh-retreat)) [set retreat-total (retreat-total + 1) ] ]
  
  if (retreat-total = referee-no ) [
    set retreat-flag true
  ]
  
  report val
end

to-report total-german
  let val 0
  ask units [if team = "german" [set val (val + cur-soldiers)] ]  
  report val
end

;;;;;;;;;; FRONTLINE ARROWS ;;;;;;;;;;;;;
;;** 
;; Sets up the front line
;;**
to setup-frontline
  let start_y 20 + 3 + 5 / 2 
  let loopNo 0
  ;;create 10 arrows
  while [loopNo < referee-no - 1 ] [
    set start_y (start_y - 5)
    create-frontline_arrows 1 [
    set color german-color
    set heading 90 ;;0 is north, 90 is east, etc
    set xcor frontline-mid
    set ycor start_y
    ]
    set loopNo (loopNo + 1)
  ]
  
  ;;gets the first ID of the arrows to set up links
  set loopNo 0
  let first_id 150
  while [loopNo < (count turtles)] [
   show [who] of turtle loopNo
   if  is-frontline_arrow? turtle loopNo
   [
     set first_id ([who] of turtle loopNo)
     set loopNo (count turtles)
   ]
    set loopNo (loopNo + 1)
  ]
  
  show first_id
  
  ;;set up links between the front line arrows
  set loopNo 0
  while [loopNo < referee-no - 2 ]
  [
    ask turtle (first_id + loopNo) [ create-turtle-link-with turtle (first_id + loopNo + 1) ]
    set loopNo (loopNo + 1)
  ]
  
end

;;**
;; Runs the frontline arrows and moves them accordingly
;;**
to go-frontline_arrow 
  
  if (direction > 0) ;;french winning
  [
    if (xcor < frontline-mid + 10 and xcor > frontline-mid - 10)
    [
      forward direction
    ]
    set color french-color
    set heading 90
    
    ;;set pen-size 3
    ;;pen-erase
  ]
  if (direction < 0) ;;germans winning
  [
    if (xcor < frontline-mid + 10 and xcor > 0)
    [
      forward -1 * direction
    ]
    set color german-color
    set heading 270
  ]
  
  if (xcor > frontline-mid)
  [
    set pen-size 2
    pd
    set color french-color
  ]
  if (xcor < frontline-mid)
  [
    set pen-size 2
    pd
    set color german-color
  ]
end

to set-frontline_arrow-direction [myDirection]
  set direction 0
  set direction direction + myDirection
  
  ;if (direction > 0)
  ;[
  ;  set direction 1 ;blue is positive
  ;]
  ;if (direction < 0)
  ;[
  ;  set direction -1 ;red is negative
  ;]
end

;;;;;;;;;; TAXIS ;;;;;;;;;;;;;
to go-transport
  
  ;get "next waypoint"
  ;determine which of the next waypoints which will be inside method "next waypoint"
  ;return the next waypoint
  if current-waypoint = 0 and any? waypoints [
    let closest-waypoint first sort-by [ [distancexy [xcor] of myself [ycor] of myself] of ?1 < [distancexy [xcor] of myself [ycor] of myself] of ?2 ] waypoints
    set current-waypoint closest-waypoint
  ]
  
  
  ;check to see if within range of a waypoint
  if (current-waypoint != 0 and (abs (xcor - ([xcor] of current-waypoint))) < 2 and (abs (ycor - ([ycor] of current-waypoint))) < 2) [
    if (is-unit? current-waypoint) [
      ask current-waypoint [ set-soldiers (cur-soldiers + [current-units] of myself) ]
      ;set returning 1
      ;set current-units 0
      die
    ]
    ;if only one next one, simply use the next one
    let old-waypoint current-waypoint
    set current-waypoint [get-next-waypoint ([transport-type] of myself) ([returning] of myself)] of current-waypoint
    let next-path-type 0
    
    ; Back at Paris
    ifelse (returning = 1 and current-waypoint = 0) [
      ; TODO fix for trains
      if (transport-type = "taxi") [ set current-units taxi-capacity * taxi-aggro ]
      if (transport-type = "train") [ set current-units train-capacity ]
      if (total-reinforcements <= 0) [ die ]
      set total-reinforcements (total-reinforcements - current-units)
      set returning 0
      set current-waypoint 0
      if (total-reinforcements <= 0) [ set current-units (current-units + total-reinforcements) set total-reinforcements 0 ]
      
    ] [
    
      foreach ([next-waypoints] of old-waypoint) [
        ;print "test"
        ;print ?
        ;print [id] of current-waypoint
        if (item 0 ? = [id] of current-waypoint) [ set next-path-type item 1 ? ]
        ;print next-path-type
      ]
      if ((transport-type = "taxi" or transport-type = "train") and next-path-type = "footpath") [
        let people-to-spawn current-units / person-aggr
        hatch-transports people-to-spawn [
          ;set xcor [xcor] of myself
          ;set ycor [ycor] of myself
          ;set path path-number
          set current-waypoint [current-waypoint] of myself
          set transport-type "person"
          set size 2
          
          ;set current-units [current-units] of myself
          set current-units person-aggr
        ]
        ;die
        set returning 1
        set current-units 0
        set current-waypoint 0
      ]
    ]
  ]
  
  if (transport-type = "taxi" and returning = 1) [
    set color yellow
  ]
  if (transport-type = "taxi" and returning = 0) [
    set color blue
  ]
  
  if (transport-type = "train" and returning = 1) [
    set color yellow
  ]
  if (transport-type = "train" and returning = 0) [
    set color green
  ]
  
  ;change the direction the transport is facing when moving in a certain direction
  if (heading < 180)
  [
    if (transport-type = "taxi")
    [
      set shape "car right"
    ]
    if (transport-type = "train")
    [
      set shape "train right"
    ]
  ]
  if (heading > 180)
  [
    if (transport-type = "taxi")
    [
      set shape "car left"
    ]
    if (transport-type = "train")
    [
      set shape "train left"
    ]
  ]  
  if (transport-type = "person")
  [
    set shape "person"
  ]
  
  ;print next-waypoint
  if current-waypoint != 0 [
    set heading atan (([xcor] of current-waypoint) - xcor) (([ycor] of current-waypoint) - ycor)
    if (transport-type = "person")
    [
      fd .2
    ]
    if (transport-type = "taxi")
    [
      fd 1
    ]
    if (transport-type = "train")
    [
      fd 2
    ]
  ]
end

;;**
;; Determine the next waypoint to go to
;;**
to-report get-next-waypoint-old
  ifelse length next-waypoints  = 0 [
    report 0
  ]
  [
    let min-waypoint 0
    foreach next-waypoints [
      ;ask what its weight is, which ever one is the highest weight, we'll return that waypoint
      let temp-waypoint (get-waypoint-by-id item 0 ?)
      ;intilaize for the first loop through
      if min-waypoint = 0 [
        set min-waypoint temp-waypoint
      ]
      ;check to see if a new min waypoint has been found
      if get-waypoint-weight min-waypoint > get-waypoint-weight temp-waypoint [
        set min-waypoint temp-waypoint
      ]
    ]
    
    report min-waypoint
  ]
end

to-report get-appropriate-waypoints [for-transport-type]
  let appropriate-waypoints []
  let num-footpath 0
  let num-road 0
  let num-rail 0
  foreach next-waypoints [
    if (item 1 ? = "footpath") [ set num-footpath (num-footpath + 1) ]
    if (item 1 ? = "road") [ set num-road (num-road + 1) ]
    if (item 1 ? = "rail") [ set num-rail (num-rail + 1) ]
  ]
  
  foreach next-waypoints [
    if (for-transport-type = "train" and ( item 1 ? = "rail" or ( item 1 ? = "footpath" and num-rail = 0 ) )) [
      set appropriate-waypoints lput ? appropriate-waypoints
    ]
    
    if (for-transport-type = "taxi" and ( item 1 ? = "road" or item 1 ? = "footpath" )) [
      set appropriate-waypoints lput ? appropriate-waypoints
    ]
    
    if (for-transport-type = "person") [
      set appropriate-waypoints lput ? appropriate-waypoints
    ]
  ]
  
  report appropriate-waypoints
  
end

to-report get-next-waypoint [for-transport-type is-returning]
  let index 0
  
  ifelse (is-returning = 1 and length previous-waypoints >= 1) [ report get-waypoint-by-id item 0 previous-waypoints ]
  [ if (is-returning = 1) [ report 0 ] ]
  
  ; Only look at waypoints approprate for transport
  let appropriate-waypoints get-appropriate-waypoints for-transport-type
;  foreach next-waypoints [
;    if (for-transport-type = "taxi") [
;      if (item 1 ? = "road" or item 1 ? = "footpath") [
;        set appropriate-waypoints lput ? appropriate-waypoints
;      ]
;    ]
;    if (for-transport-type = "train") [
;      if (item 1 ? = "rail" or item 1 ? = "footpath") [
;        set appropriate-waypoints lput ? appropriate-waypoints
;      ]
;    ]
;    if (for-transport-type = "person") [
;      set appropriate-waypoints next-waypoints
;    ]
;
;  ]
  
  ifelse length next-waypoints = 0 [
    report 0
  ]
  [
    let next-needed 0
    ; if all waypoints have had something sent, reset sent value
    let all-sent 1
    foreach next-waypoints [
      ; only look at needy
      if (item 2 ? = 1 and item 3 ? = 0) [ set all-sent 0 ]
    ]
    
    if (all-sent = 1) [
      set index 0
      foreach next-waypoints [
        set next-waypoints replace-item index next-waypoints (replace-item 3 (item index next-waypoints) 0)
        set index (index + 1)
      ]
    ]
    
    set index 0
    foreach next-waypoints [
      ; if need, and hasn't been sent
      if (item 2 ? = 1 and item 3 ? = 0) [
        ; send on this path
        if member? ? appropriate-waypoints [
          set next-waypoints replace-item index next-waypoints (replace-item 3 (item index next-waypoints) 1)
          report get-waypoint-by-id item 0 ?
        ]
      ]
      set index (index + 1)
    ]
    
    ; If can't find a good waypoint, just choose a random one
    report get-waypoint-by-id item 0 (item (random length appropriate-waypoints) appropriate-waypoints)
  ]
end

to-report get-waypoint-weight [waypoint]
    let report-weight [weight] of waypoint
    
    foreach [next-waypoints] of waypoint [
      set report-weight report-weight + get-waypoint-weight (get-waypoint-by-id item 0 ?)
    ]
    
    report report-weight
end

to add-waypoint
  if mouse-down? [ set mouse-click 1 ]
  
  if (mouse-down? = false and mouse-click = 1) [
    create-taxi-waypoints 1 [
        set color (path-number * 12)
        set xcor mouse-xcor
        set ycor mouse-ycor
        set path path-number
        set waypoint-number (last-placed-waypoint + 1)
        set label waypoint-number
        set size 1
        
        set last-placed-waypoint (last-placed-waypoint + 1)
      ]
    set mouse-click 0
  ]
end

to reset-last-waypoint
  set last-placed-waypoint 0
end


to associate-waypoints
  if mouse-down? and (mouse-click = 0) and (any? waypoints) [
    let closest-waypoint first sort-by [ [distancexy mouse-xcor mouse-ycor] of ?1 < [distancexy mouse-xcor mouse-ycor] of ?2 ] waypoints
    set association-root closest-waypoint
    print "setting association-root"
    set mouse-click 1
  ]
  
  ;if mouse-down? [ set mouse-click 1 ]
  
  if (mouse-down? = false and mouse-click = 1 and any? waypoints) [
    
    let closest-waypoint first sort-by [ [distancexy mouse-xcor mouse-ycor] of ?1 < [distancexy mouse-xcor mouse-ycor] of ?2 ] (sentence sort waypoints sort units)
    ask association-root [ set next-waypoints lput ( list ([id] of closest-waypoint) (path-type) 0 0 ) next-waypoints ]
    ask closest-waypoint [ set previous-waypoints lput ( [id] of association-root ) previous-waypoints ]
    
    ;change properties of link depending on type of trail being traveled on
    if (path-type = "rail")
    [
      ask association-root [ create-waypoint-link-to closest-waypoint [
          set color magenta 
          set thickness .1
          set shape "rail"] ]
    ]
    if (path-type = "road")
    [
      ask association-root [ create-waypoint-link-to closest-waypoint [
          set color magenta
          set thickness .1
          set shape "road"] ]
    ]
    if (path-type = "footpath")
    [
      ask association-root [ create-waypoint-link-to closest-waypoint [
          set color magenta
          set thickness .2] ]
    ]
    
    set mouse-click 0
  ]
end


to-report get-waypoint-by-id [search-id]
  report first sentence (sort waypoints with [id = search-id]) (sort units with [id = search-id])
  
end


to go-transport-spawner
  let aggr 1
  if (type-to-spawn = "taxi") [ set aggr taxi-aggro ]
  set ticks-to-next-spawn (ticks-to-next-spawn - 1)
  if (ticks-to-next-spawn <= 0 and number-to-spawn > 0) [
    let spawning 1
    if (spawn-sequentially = false) [
      set spawning number-to-spawn
    ]
    
    if (spawning < 0) [ set spawning 0 ]
    
    set number-to-spawn (number-to-spawn - (spawning * aggr))
    
    if (type-to-spawn = "taxi") [
      hatch-transports spawning [
        ;set xcor [xcor] of myself
        ;set ycor [ycor] of myself
        ;set path path-number
        set current-waypoint 0
        set size 3
        set transport-type "taxi"
        set current-units taxi-capacity * taxi-aggro
        set total-reinforcements (total-reinforcements - current-units)
        

        set shape "car right"

      ]
    ]
    
    if (type-to-spawn = "train") [
      hatch-transports spawning [
        ;set xcor [xcor] of myself
        ;set ycor [ycor] of myself
        ;set path path-number
        set current-waypoint 0
        set size 3
        set transport-type "train"
        set current-units train-capacity
        
        set shape "train right"

      ]
    ]
    
    set ticks-to-next-spawn 5
    
  ]
end



to go-french
  if (old-soldiers = 0) [ set old-soldiers cur-soldiers ]
  ;let soldiers-diff (soldiers - old-soldiers) / old-soldiers
  let soldiers-diff winning
  print "soldiers-diff"
  print soldiers-diff
  ;if (need = 0 and soldiers < 900) [
  if (need = 0 and soldiers-diff < need-threshold) [
    ; send back need
    set need 1
    set-my-need need
  ]
  ;if (need = 1 and soldiers > 900) [
  if (need = 1 and soldiers-diff > need-threshold) [
    set need 0
    set-my-need need
  ]
  set label need
  
  ;;temp debug for reinforce
  if (ticks mod 25 = 0) [ 
    let temp random 3
    set-soldiers cur-soldiers - temp
  ]
  set old-soldiers cur-soldiers
end

to go-german
;  if (ticks mod 25 = 0) [
;    set-soldiers cur-soldiers + 5
;  ]
end


to set-need-for-id [new-need for-id]
  let any-need 0
  let index 0
  foreach next-waypoints [
    if ( item 0 ? = for-id ) [
      ;print (item index next-waypoints)
      ;print replace-item index next-waypoints (replace-item 2 (item index next-waypoints) new-need)
      set next-waypoints replace-item index next-waypoints (replace-item 2 (item index next-waypoints) new-need)
    ]
    
    set index (index + 1)
  ]
  
  foreach next-waypoints [
    ;print item 2 ?
    if ((item 2 ?) = 1) [ set any-need 1 ]
  ]
  
  
  if (any-need != need) [ set-my-need any-need ]
  
end

to set-my-need [new-need]
  set need new-need
  foreach previous-waypoints [
      let previous-waypoint (get-waypoint-by-id ?)
      ask previous-waypoint [
        set-need-for-id new-need [id] of myself
        ;set-my-need new-need
      ]
  ]
end

to send-position
  ;netsend:send "x" (xcor / max-pxcor)
  ;netsend:send "y" (ycor / max-pycor)
end
@#$#@#$#@
GRAPHICS-WINDOW
384
15
1421
839
39
30
13.0
1
10
1
1
1
0
0
0
1
-39
39
-30
30
0
0
1
ticks
30.0

BUTTON
299
55
362
88
Save
save-form
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
12
96
85
129
Clear
clear
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
92
12
155
45
NIL
Go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
299
13
363
46
Load
load-form
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
1438
301
1594
346
type-to-add
type-to-add
"taxi" "waypoint" "french" "german" "taxi spawner" "train spawner"
1

BUTTON
1438
357
1588
390
NIL
add-unit
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
17
787
120
820
Toggle Map
setup-patches
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
14
499
169
559
path-number
2
1
0
Number

BUTTON
182
512
335
545
NIL
add-waypoint
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
181
580
335
613
NIL
reset-last-waypoint
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
13
565
168
625
last-placed-waypoint
0
1
0
Number

BUTTON
19
826
82
859
NIL
test
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
180
641
338
674
NIL
associate-waypoints
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
13
637
168
682
path-type
path-type
"rail" "road" "footpath"
2

BUTTON
180
686
341
719
NIL
associate-referees
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
12
55
83
88
Reset
reset-all-units
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
12
12
81
45
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
203
409
375
442
max-taxis
max-taxis
0
600
600
1
1
taxis
HORIZONTAL

SWITCH
14
449
191
482
spawn-sequentially
spawn-sequentially
0
1
-1000

SWITCH
15
408
192
441
show-roads
show-roads
0
1
-1000

SWITCH
15
366
192
399
show-rails
show-rails
1
1
-1000

PLOT
12
137
248
356
Total Soldiers: French vs Germans
Time
Number of Soliders
0.0
1440.0
0.0
70000.0
false
false
"" ""
PENS
"french-plot-pen" 1.0 0 -15390905 true "" "plot total-french"
"german-plot-pen" 1.0 0 -2674135 true "" "plot total-german"

MONITOR
258
137
372
182
NIL
total-french
17
1
11

MONITOR
258
193
343
238
NIL
total-german
17
1
11

INPUTBOX
1438
470
1612
531
need-threshold
0
1
0
Number

INPUTBOX
181
13
289
73
file-name
train-path-test
1
0
String

INPUTBOX
1434
17
1543
77
unit-soldier-count
13200
1
0
Number

INPUTBOX
1435
88
1544
148
unit-rof
5
1
0
Number

INPUTBOX
1436
159
1591
219
unit-hit-prob
0.75
1
0
Number

INPUTBOX
1437
227
1592
287
unit-ammo-per-soldier
75
1
0
Number

SLIDER
203
369
375
402
max-trains
max-trains
0
10
10
1
1
NIL
HORIZONTAL

INPUTBOX
1439
548
1594
608
total-reinforcements
13600
1
0
Number

MONITOR
258
253
336
298
NIL
retreat-flag
17
1
11

SLIDER
93
827
265
860
taxi-aggro
taxi-aggro
0
200
60
1
1
NIL
HORIZONTAL

INPUTBOX
95
863
250
923
person-aggr
100
1
0
Number

INPUTBOX
274
864
429
924
train-capacity
200
1
0
Number

INPUTBOX
453
869
608
929
taxi-capacity
5
1
0
Number

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car left
false
0
Polygon -7500403 true true 0 180 21 164 39 144 60 135 74 132 87 106 97 84 115 63 141 50 165 50 225 60 300 150 300 165 300 225 0 225 0 180
Circle -16777216 true false 30 180 90
Circle -16777216 true false 180 180 90
Polygon -16777216 true false 138 80 168 78 166 135 91 135 106 105 111 96 120 89
Circle -7500403 true true 195 195 58
Circle -7500403 true true 47 195 58

car right
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
0
Rectangle -7500403 true true 151 225 180 285
Rectangle -7500403 true true 47 225 75 285
Rectangle -7500403 true true 15 75 210 225
Circle -7500403 true true 135 75 150
Circle -16777216 true false 165 76 116

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

train left
false
0
Rectangle -7500403 true true 60 105 270 150
Polygon -7500403 true true 60 105 30 30 120 30 90 105
Polygon -7500403 true true 105 180 30 180 0 210 105 210
Circle -7500403 true true 210 165 90
Circle -7500403 true true 30 225 30
Circle -7500403 true true 120 165 90
Circle -7500403 true true 75 225 30
Rectangle -7500403 true true 195 30 300 150
Rectangle -16777216 true false 225 60 270 105
Polygon -7500403 true true 105 180 135 150 60 150 60 180
Rectangle -7500403 true true 135 75 165 105
Rectangle -7500403 true true 45 120 75 150
Rectangle -16777216 true false 150 203 270 218

train right
false
0
Rectangle -7500403 true true 30 105 240 150
Polygon -7500403 true true 240 105 270 30 180 30 210 105
Polygon -7500403 true true 195 180 270 180 300 210 195 210
Circle -7500403 true true 0 165 90
Circle -7500403 true true 240 225 30
Circle -7500403 true true 90 165 90
Circle -7500403 true true 195 225 30
Rectangle -7500403 true true 0 30 105 150
Rectangle -16777216 true false 30 60 75 105
Polygon -7500403 true true 195 180 165 150 240 150 240 180
Rectangle -7500403 true true 135 75 165 105
Rectangle -7500403 true true 225 120 255 150
Rectangle -16777216 true false 30 203 150 218

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 1.0 0.0
0.0 1 1.0 0.0
0.2 0 1.0 0.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

rail
0.0
-0.2 1 4.0 4.0
0.0 0 0.0 1.0
0.2 1 4.0 4.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

road
0.0
-0.2 1 1.0 0.0
0.0 1 4.0 4.0
0.2 1 1.0 0.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
