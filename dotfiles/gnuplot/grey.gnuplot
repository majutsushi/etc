set object 1 rectangle from graph 0,0 to graph 1,1 behind
set object 1 rectangle fillcolor rgb "grey90"

set mxtics
set mytics
set style line 80 lc rgb "grey50" lt 1
set border 0 back ls 80
set tics nomirror out textcolor rgb "grey50" scale 1,0.001

set style line 81 lc rgb "white" lt 1 lw 1
set style line 82 lc rgb "#eeeeee" lt 1 lw 0.5
set grid xtics mxtics ytics mytics ls 81, ls 82

set key opaque width 0.5 height 0.5 box lc rgb "black" lt 1
