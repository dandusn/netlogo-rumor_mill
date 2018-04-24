globals [
  color-mode       ;; 0 = normal, 1 = when heard, 2 = times heard
  clique           ;; how many patches have heard the rumor
  previous-clique  ;; value of clique from last tick, for use in the "successive" plots
  varn
  pvarn1
  pvarn2
  pvarn3
  pvarn4
  pvarn5
  pvarn6
  pvarn7
  pvarn8
  pvarn
]

patches-own [
  times-heard    ;; tracks times the rumor has been heard
  first-heard    ;; clock tick when first heard the rumor
  just-heard?    ;; tracks whether rumor was heard this round -- resets each round
]

;;; setup procedures

to setup [seed-one?]
  clear-all
  set color-mode 0
  set clique 0
  set varn 800
  
  output-print varn1 / 8
  output-print varn2 / 8
  output-print varn3 / 8
  output-print varn4 / 8
  output-print varn5 / 8
  output-print varn6 / 8
  output-print varn7 / 8
  output-print varn8 / 8
  
  set pvarn1 varn1 / 8
  set pvarn2 varn2 / 8
  set pvarn3 varn3 / 8
  set pvarn4 varn4 / 8
  set pvarn5 varn5 / 8
  set pvarn6 varn6 / 8
  set pvarn7 varn7 / 8
  set pvarn8 varn8 / 8
  
  set pvarn (list pvarn1 pvarn2 pvarn3 pvarn4 pvarn5 pvarn6 pvarn7 pvarn8)
  
  ask patches
    [ set first-heard -1
      set times-heard 0
      set just-heard? false
      recolor ]
  ifelse seed-one?
    [ seed-one ]
    [ seed-random ]
  reset-ticks
end

to seed-one
  ;; tell the center patch the rumor
  ask patch 0 0
    [ hear-rumor 0 ]
end

to seed-random
  ;; seed with random number of rumor sources governed by init-clique slider
  ask patches with [times-heard = 0]
    [ if (random-float 100.0) < init-clique
        [ hear-rumor 0 ] ]
end

to go
  if all? patches [times-heard > 0]
    [ stop ]
  ask patches
    [ if times-heard > 0
        [ spread-rumor ] ]
  update
  tick
end

to spread-rumor  ;; patch procedure
  let neighbor nobody
  ifelse eight-mode?
    [ set neighbor n-of 8 neighbors ]
    [ set neighbor n-of 4 neighbors4 ]
  ask neighbor [ set just-heard? true ]
end

to hear-rumor [when]  ;; patch procedure
  if first-heard = -1
    [ set first-heard when
      set just-heard? true ]
  set times-heard times-heard + 1
  recolor
end

to update
  ask patches with [just-heard?]
    [ set just-heard? false
      hear-rumor ticks ]
  set previous-clique clique
  set clique count patches with [times-heard > 0]
end

;;; coloring procedures

to recolor  ;; patch procedure
  ifelse color-mode = 0
    [ recolor-normal ]
    [ ifelse color-mode = 1
      [ recolor-by-when-heard ]
      [ recolor-by-times-heard ] ]
end

to recolor-normal  ;; patch procedure
  ifelse first-heard >= 0
    [ set pcolor red ]
    [ set pcolor blue ]
end

to recolor-by-when-heard  ;; patch procedure
  ifelse first-heard = -1
    [ set pcolor black ]
    [ set pcolor scale-color yellow first-heard world-width 0 ]
end

to recolor-by-times-heard   ;; patch procedure
  set pcolor scale-color green times-heard 0 world-width
end

;;; mouse handling

to spread-rumor-with-mouse
  if mouse-down?
    [ ask patch mouse-xcor mouse-ycor
        [ hear-rumor ticks ]
        display ]
end


; Copyright 1997 Uri Wilensky.
; See Info tab for full copyright and license.
