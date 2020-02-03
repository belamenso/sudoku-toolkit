# sudoku-toolbox

### TODO
* unify iterators (all should produce I99)
* better organize parsing/rendering code
* try to make it work on JS backend
* mode granular strategies
* **exploratory: if you (by brute-forcing) see that some value is supposed to be there, can you
  somehow examine why and report it? Maybe it's possible to automatically discover strategies?**

### USER --> SYSTEM (entering sudoku in a pleasant and versatile way)
* ocr
* manual edition of inputted data
* manaual input
* inport from known formats (if any)
* heuristic input (or maybe very configurable function)?

### SUDOKU GAME
* history (tree, like vim with rimes and :earlier) of moves
* tactics (options to apply heuristics)
* **readable summary of applied tactics and actions** -> **GOAL: algorithm should generate minimum noise in logs**
* API allowing you to steer the progress of a game in a versatile way (?)
* steering should be invisible, seamless, no API, just interaction

### Other
* exceptionally readable error messages, explaining to the user, in appropriate level of detail, what went wrong,
they should approach what a human would write

### SYSTEM --> OUT
* export to various formats
* configurable export
* augumented reality output
