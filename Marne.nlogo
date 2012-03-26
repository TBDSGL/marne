extensions [ netsend ]

globals [
  r-file
  background
  mouse-click
  unit-size
  ;last-placed-waypoint
  association-root
]

breed [ reds red-unit ]
breed [ blues blue-unit ]

breed [ taxis taxi ]
breed [ taxi-waypoints taxi-waypoint ]

breed [ horses horse ]
breed [ trains train ]
breed [ walkers walker ]

breed [ waypoints waypoint ]

breed [ frontline_arrows frontline_arrow]

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

taxis-own [
  path
  current-waypoint
  capacity
  current-units
]

trains-own [
  path
  current-waypoint
  capacity
  current-units
]

horses-own [
  path
  current-waypoint
  capacity
  current-units
]

walkers-own [
  path
  current-waypoint
  capacity
  current-units
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
; ex. [ [ 123 "road" ] [ 432 "rail" ] [ 980 "road" ] ]
waypoints-own [
  id
  next-waypoints
]

to test
  netsend:send "bleh" random 10
end

;;**
;; Clears the screen
;;**
to clear
  clear-all
  set-default-shape reds "arrow"
  set-default-shape blues "default"
  set-default-shape taxis "default"
  set-default-shape taxi-waypoints "triangle"
  set-default-shape frontline_arrows "arrow"
  set unit-size 5
  set last-placed-waypoint 0

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
      import-drawing "background.jpg"
    ][
      ask patches [
      ]
    ]
end

;;**
;; Runs the simulation
;; **
to go
  tick
  ;;ask reds [fd 1 rt random 90 lt random 90]
  ;;ask blues [fd 1 rt random 90 lt random 90]
  ask taxis [ go-taxi ]
  ask frontline_arrows [ go-frontline_arrow ]
end


;;**
;; Loads the data
;;**
to load-form
  ;setup-patches
  ;setup-carth-form
  ;setup-rome-form
  
  clear
  ;set-default-shape reds "person"
  ;set-default-shape blues "person"
  
  ;;setup-red-form
  ;;setup-blue-form
  setup-frontline
  
  reset-ticks
end

;;**
;; Saves the data
;;**
to save-form
  ;;save the red team coordinates
  carefully [ file-delete "red.txt" ][ write "File Not Deleted" ]
  file-open "red.txt"
  file-write ( count reds )

  ask reds [
      file-write xcor
      file-write ycor
    ]
  
  file-close
  
  ;;save the blue team coordinates
  carefully [ file-delete "blue.txt" ][ write "File Not Deleted" ]
  file-open "blue.txt"
  file-write ( count blues )

  ask blues [
      file-write xcor
      file-write ycor
    ]
  
  file-close
  
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
      create-taxis 1 [
        set xcor mouse-xcor
        set ycor mouse-ycor
        set path path-number
        set current-waypoint 0
        set size 3
      ]
    ]
    
    if type-to-add = "waypoint" [
      create-waypoints 1 [
        set xcor mouse-xcor
        set ycor mouse-ycor
        set id random 10000000
        set next-waypoints []
      ]
    ]
    
    set mouse-click 0
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

;;;;;;;;;; FRONTLINE ARROWS ;;;;;;;;;;;;;

;;** 
;; Sets up the front line
;;**
to setup-frontline
  let start_y 20
  let loopNo 0
  ;;create 10 arrows
  while [loopNo < 10] [
    create-frontline_arrows 1 [
    set color blue
    set heading 90 ;;0 is north, 90 is east, etc
    set xcor 10
    set ycor start_y
    ]
  set loopNo (loopNo + 1)
  set start_y (start_y - 2)
  ]
  
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
  
  set loopNo 0
  while [loopNo < 9]
  [
    ask turtle (first_id + loopNo) [ create-link-with turtle (first_id + loopNo + 1) ]
    set loopNo (loopNo + 1)
  ]
  
end

to go-frontline_arrow 
  ifelse (direction = "red")
  [
    set xcor (xcor + .1)
    set color red
    set heading 90
    
    ;;set pen-size 3
    ;;pen-erase
  ]
  [
    set xcor (xcor - .1)
    set color blue
    set heading 270
  ]
  
  ifelse (xcor > 10)
  [
    set pen-size 2
    pd
    set color red
  ]
  [
    set pen-size 2
    pd
    set color blue
  ]


  ifelse (random 6 <= 2)
  [
    set direction "blue"
  ]
  [
    set direction "red"
  ]

end

;;;;;;;;;; TAXIS ;;;;;;;;;;;;;
to go-taxi
  let next-waypoint 0
  
  foreach sort taxi-waypoints [
    if [path] of ? = path and [waypoint-number] of ? = current-waypoint + 1 [
      set next-waypoint ?
      ;print next-waypoint
    ]
  ]
  if next-waypoint = 0 [ stop ]
  if (abs (xcor - ([xcor] of next-waypoint))) < 2 and (abs (ycor - ([ycor] of next-waypoint))) < 2 [
    set current-waypoint (current-waypoint + 1)
  ]
  ;print next-waypoint
  set heading atan (([xcor] of next-waypoint) - xcor) (([ycor] of next-waypoint) - ycor)
  fd 1
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
  if mouse-down? [ set mouse-click 1 ]
  
  if (mouse-down? = false and mouse-click = 1 and any? waypoints) [
    let closest-waypoint first sort-by [ [distancexy mouse-xcor mouse-ycor] of ?1 < [distancexy mouse-xcor mouse-ycor] of ?2 ] waypoints
    ifelse association-root = 0 [
      ; set association-root to closest waypoint to mouse
      set association-root closest-waypoint
    ] [
      ask association-root [ set next-waypoints lput ( list ([id] of closest-waypoint) (path-type) ) next-waypoints ]
    ]
    set mouse-click 0
  ]
end

to new-association
  set association-root 0
end

to-report get-waypoint-by-id [search-id]
  ask waypoints [
    if id = search-id [
      report self
    ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
384
16
1577
840
45
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
-45
45
-30
30
0
0
1
ticks
30.0

BUTTON
20
82
83
115
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
19
29
88
62
NIL
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
103
28
166
61
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
104
81
168
114
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
20
147
158
192
type-to-add
type-to-add
"red" "blue" "taxi" "waypoint"
3

BUTTON
179
151
265
184
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
215
28
318
61
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
5
208
160
268
path-number
2
1
0
Number

BUTTON
170
219
287
252
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
171
298
325
331
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
4
287
159
347
last-placed-waypoint
0
1
0
Number

BUTTON
21
393
84
426
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
23
452
181
485
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

BUTTON
194
453
327
486
NIL
new-association
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
34
504
172
549
path-type
path-type
"rail" "road" "footpath"
0

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

car
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

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

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

@#$#@#$#@
0
@#$#@#$#@
