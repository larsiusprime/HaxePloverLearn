HaxePloverLearn
===========

*a fork of [PloverLearn](https://github.com/erika-n/PloverLearn) by [Erika Nesse](https://github.com/erika-n)*

Drills for the Learn Plover! book, part of the Open Steno Project. 

Website: http://www.tranklements.com/PloverLearn/

Building
========

1. Download & install Haxe/OpenFL ([instructions](http://www.openfl.org/documentation/getting-started/installing-openfl/))
2. Open a command line in the same directory as project.xml
3. Execute ```lime test flash``` to build & run the flash swf
4. Download & install Python ([site](https://www.python.org/downloads/)) -- I used version 3.
5. Navigate to "/Assets" in the command line
6. Execute ```py distribute_lessons.py``` to prepare the lesson folders
7. Copy the contents of the "Assets" folder to your webserver to deploy the lessons

Lessons
=======

1. Create a folder under "assets"
2. Create a lesson.txt file inside it
3. Remember to run the python command (see above) to distribute the index.html files
4. Use the correct format:

```
Lesson X Exercise Y
Description goes here
'word': HINT
'word': HINT
```

For example:
```
Lesson 2 Exercise 3
Inversion
'edit': ETD
'elves': EFLS
'twelve': TWEFL
'credit': KRETD
'portal': PORLT
```

You can also add settings to the lessons:

```
Lesson 3F Exercise 1
Fingerspelling!
'The': T*P H* *E
'quick': KW* *EU KR* K*
'brown': PW* R* *O W* TPH*
'fox': TP* *O KP*
'jumps': SKWR* *U PH* P* S*
'over': *O SR* *E R*
'the': T* H* *E
'lazy': HR* *A *STPKW KWR*
'dog': TK* *O *TPKW
case_sensitive=true
```

You add settings by entering text of the format

```
setting=value
```

The recognized settings are:
	
	* case_sensitive : requires user to match uppercase and lowercase. False by default.
	* require_spaces : requires user to generate spaces at the end of each word. 
	                   False by default. Mostly only useful for fingerpselling exercises.


Coming Soon
===========

HTML5 and Win/Mac/Linux C++ Desktop builds
