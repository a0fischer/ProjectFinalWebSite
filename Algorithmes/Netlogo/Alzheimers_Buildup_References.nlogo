globals [CellState]                                                       ;; keep track of CellState

Breed [NFT a-NFT ]
NFT-own [energyNFT]                                                       ;; AB, NFT, and APOE2 are all breeds of turtle.

Breed [ AB a-AB ]
AB-own [energyAB]

Breed [ APOE APOEsingle]
APOE-own [energyAPOE birth]

patches-own [countdown dead ]

to setup
  clear-all

  ask patches [
    set countdown DiseaseProgression ]                                    ;; initialize CellState to set parameter

  set-default-shape NFT "circle"
  create-NFT NFT-buildup [                                                ;; create the NFT, then initialize their variables
    set color magenta
    set size 2.3                                                          ;; NFT can be up to 441 amino acids long (Sontheimer, 2015), using the 352 isoform, 352/150 = 2.3
    set label-color magenta - 2
    set energyNFT 50
    setxy random-xcor random-ycor ]

  set-default-shape AB "circle"
  create-AB AB-buildup [                                                  ;; create the AB, then initialize their variables
    set color blue
    set size .5                                                           ;; AB is up to 51 amino acids long (Olsson, 2014), 51/200 = .333, round up to .5
    set label-color blue - 2
    set energyAB 50
    setxy random-xcor random-ycor ]

  set-default-shape APOE "square"
  create-APOE Inital-APOE [                                               ;; create the APOE, then initialize their variables
    set color red
    set size 2                                                            ;; APOE is 299 amino acids long  (Phillips, 2014), 299/150 = 2
    set energyAPOE 100
    setxy random-xcor random-ycor ]

  reset-ticks
end

to go
  if not any? APOE [ stop ]                                               ;; Humans require APOE for survival
  if (((count patches with [pcolor = green]) * 100)/(count patches) < %LiveRequired? ) [ stop]  ;; Humans require live cells

  ask NFT [                                                               ;; NFT is intracellular, does not move, does not lose energy
    task-CellState
    transcribe-NFT ]

  ask AB [
    move
    set energyAB energyAB - .25                                           ;; AB loses energy as it moves
    task-CellState
    transcribe-AB ]

  ask APOE [
    move
    set energyAPOE energyAPOE - 1                                         ;; APOE requires more energy than AB to move, larger
    set birth 1
    catch
    deathAPOE
    transcribe-APOE ]

  ask patches [ grow-CellState ]                                          ;; run procedure to allow regrowth of Cell health

  tick
end

to move                                                                   ;; turtle moving around procedure
  rt random 100
  lt random 100
  fd 1
end

to task-CellState                                                         ;; task CellState
  ask NFT-here [
    if pcolor = green [
    set pcolor brown                                                      ;; turn the cell brown, indicating cell recovering from task performed
    set energyNFT energyNFT + 5                                           ;; NFT and AB gain energy by performing tasks on each cell
      if energyNFT < 0 and pcolor = brown [ die ] ] ]                     ;; if NFT or AB run out of energy on an already unhealthy cell, die

  ask AB-here [
    if pcolor = green [                                                   ;; same thing, for AB
    set pcolor brown
    set energyAB energyAB + 100
      if energyAB < 0 and pcolor = brown [ die ] ] ]
end

to catch
 let preyAB one-of AB-here                                                ;; AB procedure, grab a random AB
  if (preyAB != nobody)                                                   ;; did we get one? if so,
  [ if (APOE-Variant = "APOE2" ) and (random-float 50 < AB-Transcription-Level ) ;; APOE2 has better odds of binding than APOE3 or APOE4
     [ ask preyAB [ die ]                                                 ;; kill it
      set energyAPOE energyAPOE + 50 ]                                    ;; get energy from breaking down AB

    if (APOE-Variant = "APOE3" ) and (random-float 75 < AB-Transcription-Level )
      [ ask preyAB [ die ]                                                ;; APOE3 and APOE4 are progressively worse at binding AB, get less energy from it
      set energyAPOE energyAPOE + 35 ]

    if (APOE-Variant = "APOE4" ) and (random-float 100 < AB-Transcription-Level )
      [ ask preyAB [ die ]                                                ;; APOE3 and APOE4 are progressively worse at binding AB, get less energy from it
      set energyAPOE energyAPOE + 20 ] ]                                  ;; APOE3 and APOE4 allow higher levels of waste accumulation

  if count AB > 1                                                         ;; APOE only acts on NFT when AB is present (Farfel, 2016)
   [let preyNFT one-of NFT-here                                           ;; same as above for NFT
    if (preyNFT != nobody)
  [ if (APOE-Variant = "APOE2" ) and (random-float 50 < NFT-Transcription-Level )
     [ ask preyNFT [ die ]
      set energyAPOE energyAPOE + 50 ]

    if ( APOE-Variant = "APOE3" ) and (random-float 75 < NFT-Transcription-Level )
    [ ask preyNFT [ die ]
      set energyAPOE energyAPOE + 35 ]

    if (APOE-Variant = "APOE4" ) and (random-float 100 < NFT-Transcription-Level )
    [ ask preyNFT [ die ]
        set energyAPOE energyAPOE + 20 ] ] ]

end

to transcribe-NFT                                                          ;; NFT procedure
  if count AB > 1   [                                                      ;; AB cascade hypothesis (Jack, 2011)
    if random-float 100 < ( NFT-Transcription-Level / 25 ) [               ;; throw "dice" to see if you will transcribe
      set energyNFT (energyNFT / 2)                                        ;; divide energy between parent and offspring
        hatch 1 [ rt random-float 360 fd 3 ] ] ]                           ;; hatch an offspring and move it forward 5 steps
end

to transcribe-AB                                                           ;; AB procedure
  if random-float 50 < ( AB-Transcription-Level / 25 ) [                   ;; throw "dice" to see if you will transcribe, odds are better to compensate for NFT being larger/more accessible to APOE
    set energyAB (energyAB / 2)                                            ;; divide energy between parent and offspring
      hatch 1 [ rt random-float 360 fd 1 ] ]                               ;; hatch an offspring and move it forward 1 step
end

to transcribe-APOE                                                         ;; APOE procedure
  ifelse ( count APOE < ( count NFT + count AB) ) [                        ;; transcribe more APOE only if NFT and AB levels are too high
     if (random-float 100 < ( APOE-Transcription-Level / 25 ))             ;; throw "dice" to see if you will transcribe
     [set energyAPOE (energyAPOE / 2)                                      ;; divide energy between parent and offspring
      hatch 1 [ rt random-float 360 fd 1]                                  ;; hatch an offspring and move it forward 1 step
      if pcolor = green
       [set pcolor brown
          set energyAPOE energyAPOE + 5 ] ] ]                              ;; APOE gets energy from cell as it is transcribed, takes cell's health for itself

     [ die ]                                                               ;; if ( APOE > NFT + AB) too much APOE already, cells will degrade APOE not produce more
end

to deathAPOE                                                               ;; APOE procedure when energy dips, die
  if APOE-Variant = "APOE2" [ if energyAPOE < 0 [ die ]  ]                 ;; APOE2 is the baseline
  if APOE-Variant = "APOE3" [ if energyAPOE < 5 [ die ]  ]                 ;; APOE3 and APOE4 are worse adapted to survival, die faster
  if APOE-Variant = "APOE4" [ if energyAPOE < 10 [ die ]  ]
end

to grow-CellState                                                          ;; countdown on brown patches: if reach 0, grow some CellState
    if pcolor = brown [
      ifelse countdown <= 0
        [ set pcolor green
          set countdown DiseaseProgression ]
        [   if APOE-Variant = "APOE2" [ set countdown countdown - 10 ]     ;; APOE2 is the baseline, cell recover faster
            if APOE-Variant = "APOE3" [ set countdown countdown - 5  ]     ;; APOE3 and APOE4 are harder on the cells, cells take longer to recover
            if APOE-Variant = "APOE4" [ set countdown countdown - 1  ] ] ]
end

to color-patches                                                           ;; sets the disease state - user inputs how 'healthy' the tissue begins
         let InitalLivePatches (100 - DiseaseProgression)
         let total InitalLivePatches + DiseaseProgression
         let p-green InitalLivePatches / total
         let p-brown DiseaseProgression / total
      ask patches [
         let x random-float 1.0
         if x <= p-green + p-brown [ set pcolor green]
         if x <= p-brown [ set pcolor brown] ]
end
@#$#@#$#@
GRAPHICS-WINDOW
303
10
770
478
-1
-1
9.0
1
14
1
1
1
0
1
1
1
-25
25
-25
25
1
1
1
ticks
30.0

SLIDER
4
125
177
158
AB-Buildup
AB-Buildup
1
20
10.0
1
1
NIL
HORIZONTAL

SLIDER
4
160
177
193
AB-Transcription-Level
AB-Transcription-Level
1.0
75
35.0
1.0
1
%
HORIZONTAL

SLIDER
5
304
177
337
Inital-APOE
Inital-APOE
1
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
4
339
177
372
APOE-Transcription-Level
APOE-Transcription-Level
1
100
50.0
1.0
1
%
HORIZONTAL

BUTTON
182
26
298
59
setup
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

BUTTON
182
97
298
130
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

PLOT
777
57
1093
254
populations
time
pop.
0.0
100.0
0.0
100.0
true
true
"" ""
PENS
"AB" 1.0 0 -13345367 true "" "plot count AB"
"NFT" 1.0 0 -5825686 true "" "plot count NFT"
"APOE" 1.0 0 -2674135 true "" "plot count APOE"

MONITOR
777
10
844
55
AB
count AB
3
1
11

MONITOR
943
10
1006
55
APOE
count APOE
3
1
11

MONITOR
778
257
912
302
Percent Healthy Cells 
(( count patches with [pcolor = green] ) * 100 ) / ( count patches )
1
1
11

TEXTBOX
8
106
148
125
Beta-Amyloid Settings
11
0.0
0

TEXTBOX
10
284
123
302
APOE Settings
11
0.0
0

TEXTBOX
8
195
158
213
Neurofibrillary Tangle Settings
11
0.0
1

SLIDER
4
215
176
248
NFT-buildup
NFT-buildup
1
20
10.0
1
1
NIL
HORIZONTAL

SLIDER
4
250
177
283
NFT-Transcription-Level
NFT-Transcription-Level
1
75
35.0
1
1
%
HORIZONTAL

MONITOR
862
10
927
55
NFT
count NFT
3
1
11

CHOOSER
5
25
176
70
APOE-Variant
APOE-Variant
"APOE2" "APOE3" "APOE4"
2

SLIDER
4
72
177
105
DiseaseProgression
DiseaseProgression
25
100
25.0
1
1
%
HORIZONTAL

TEXTBOX
7
10
157
28
Disease Settings 
11
0.0
1

BUTTON
182
62
298
95
color-patches
color-patches
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
778
305
978
455
Tissue Health 
Time 
Live Cells 
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Cell State" 1.0 0 -14439633 true "" "plot count patches with [pcolor = green] "

CHOOSER
182
132
299
177
%LiveRequired?
%LiveRequired?
0 1 5 10 15 25
1

@#$#@#$#@
## WHAT IS IT?

**This model explores the interactions between APOE and the buildup of neurofibrillary tangles and amyloid-beta plaques in the brain.**

Classic symptoms of Alzheimer’s disease include a buildup of beta-amyloid plaques and neurofibrillary tangles in the neural tissue. This model presents a very simplified possible version of one of APOE’s mechanisms in the body - breaking down waste.

APOE is a lipoprotein that metabolizes fats – as well as peptides like beta-amyloid - that has three variants that differ at a single-base level: APOE2, APOE3, and APOE4. 
This model represents one possible effect of APOE2, a more efficient breakdown of the waste products. 

APOE2 has a protective effect on against the onset of Alzheimer’s but we are not sure why
APOE3 is the ‘wild type’ version that is the most common
Patients who have the APOE4 gene are at a higher risk for developing Alzheimer’s

## HOW IT WORKS

APOE breaks down the neurofibrillary tangles (NFT) and amyloid-beta plaques (AB) in the neural tissue. APOE loses ‘energy’ as it moves – this is a simplification of protein inactivation, competition, and degradation as time passes. To replenish energy, APOE must bind and break down NFT and/or AB. It gains a small amount of energy from the cells it passes over, this helps stabilize the model. If energy is not replenished, APOE dies.

AB also loses ‘energy’ as it moves about the tissue, this is a simplification of the cellular mechanisms that each AB has within the brain. Both AB and NFT are necessary for a healthy system – but they can quickly build up and cause the system to fail. NFT and AB perform tasks at each cell but build up rapidly and make the cell unhealthy, turning it brown. The NFT or AB must move on and the cell must recover to regain its green and become a healthy cell again.

**APOE only acts on NFT if there is AB present.** This represents one hypothesis about the mechanism of Alzheimer’s Disease - the AB cascade hypothesis (Jack, 2011).

## HOW TO USE IT

1. Adjust the slider parameters, choose a live threshold and APOE variant (see below).

2. Press the Set-up button.

3. Press the color-patches button

4. Press the Go button to begin the simulation.

5. Look at the monitors to see the current population sizes

6. Look at the Populations plot to watch the populations fluctuate over time


### Parameters: 

**APOE Variant:** The user chooses one of three genetic variants of APOE Disease 

**Progression:** The initial percent unhealthy cells, as well as how long it takes for cell to recover from a AB or NFT task AB-Buildup: The initial volume of AB buildup 

**NFT-Buildup:** The initial volume of NFT buildup Initial-APOE: The initial volume of APOE 

**AB-Transcription-Level:** The probability of a NFT being transcribed at each time step 

**NFT-Transcription-Level:** The probability of a AB being transcribed at each time step 

**APOE-Transcription-Level:** The probability of a APOE being transcribed at each time step

**%LiveRequired:** User chooses the threshold at which the model dies.

## THINGS TO NOTICE

Watch as the NFT/AB and APOE populations fluctuate. Notice that increases and decreases in the sizes of each population are related. In what way are they related? What eventually happens?

Notice the Tissue Health plot representing fluctuations in the overall number of live cells. How do the sizes of the NFT, AB, APOE and live cell populations appear to relate? What is the explanation for this?

Why do you suppose that some variations of the model might be stable while others are not?

## THINGS TO TRY

Try adjusting the transcription parameters under various settings. How sensitive is the stability of the model? Repeat with the initial buildup, although this will not affect the model beyond starting-up

Which slider is the model most sensitive to? Which drop-down menu?

Can you find any other parameter settings that generate a stable ecosystem?

What happens if all three turtles are the same size?

What happens if NFT is also allowed to move?

Try changing the transcription rules – for example, what would happen if transcription depended on energy rather than being determined by a fixed probability?

Try changing the energy values in the code - how much energy does APOE need from each AB and NFT to survive?

## NETLOGO FEATURES
Note the use of breeds to model three different kinds of “turtles”: APOE, NFT, and AB.
 
Some breeds are stuck in place, while others move.

Note the use of patches to model CellState.

Note use of the ONE-OF agentset reporter to select a random AB or NFT to be broken down by an APOE.

## RELATED MODELS

Look at Child of Wolf Sheep Predation and Rabbits Grass Weeds for other models of interacting populations with different rules.

## CREDITS AND REFERENCES

Bizzle, J. (2014). Child of Wolf Sheep Predation, Model ID 3513 – NetLogo Modeling Commons. modelingcommons.org/browse/one_model/3513#model_tabs_browse_info.

Wilensky, U. & Reisman, K. (1999). Connected Science: Learning Biology through Constructing and Testing Computational Theories – an Embodied Modeling Approach. International Journal of Complex Systems, M. 234, pp. 1 - 12.

Wilensky, U. & Reisman, K. (2006). Thinking like a Wolf, a Sheep or a Firefly: Learning Biology through Constructing and Testing Computational Theories – an Embodied Modeling Approach. Cognition & Instruction, 24(2), pp. 171-209.

Jiang, Q. Y., Lee, C. E., Mandrekar, S. M., Wilkinson, B. L., Cramer, P. C., Landreth, G. D., Holtzman, D. (2008). ApoE Promotes the Proteolytic Degradation of Aβ. Neuron, 58(5), 681-693.

Cho, Yunhee, et. al. (2018) IPSC & CRISPR/Cas9 Technologies Enable Precise & Controlled Physiologically Relevant Disease Modeling for Basic & Applied Research. Applied StemCell Inc. www.appliedstemcell.com.

Genaro Gabriel Ortiz, et. al. (July 1st 2015). Genetic, Biochemical and Histopathological Aspects of Familiar Alzheimer’s Disease, Alzheimer’s Disease, Inga Zerr, IntechOpen, DOI: 10.5772/59809. 

Farfel, Yu, De Jager, Schneider, & Bennett. (2016). Association of APOE with tau-tangle pathology with and without β-amyloid. Neurobiology of Aging, 37, 19-25.

Jack CR Jr, et. al.Alzheimer’s Disease Neuroimaging, I. Evidence for ordering of Alzheimer disease biomarkers. Archives of neurology. 2011; 68(12):1526–1535.
Phillips MC (2014). “Apolipoprotein E isoforms and lipoprotein metabolism”. IUBMB Life. 66 (9): 616–23. doi:10.1002/iub.1314. PMID 25328986.

Olsson F, Schmidt S, Althoff V, Munter LM, Jin S, Rosqvist S, Lendahl U, Multhaup G, Lundkvist J (January 2014). “Characterization of intermediate steps in amyloid beta (Aβ) production under near-native conditions”. The Journal of Biological Chemistry. 289 (3): 1540–50. doi:10.1074/jbc.M113.498246

Sontheimer, H. (2015). Chapter 4 - Aging, Dementia, and Alzheimer Disease. In Diseases of the Nervous System (pp. 99-131).
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
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

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

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.3
@#$#@#$#@
setup
set grass? true
repeat 75 [ go ]
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
