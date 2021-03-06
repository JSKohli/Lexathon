# Lexathon Project
Contributors: Jaswin Kohli, Paarth Kapadia, Aahan Sawhney

### About
Lexathon is a word game that we made as part of an academic group project for our Computer Architecture class. At present the game lacks user friendliness. I intend to make the interface slightly more intuitive. 

### How to Play:
* The player is given a grid consisting of nine randomly generated vowels or consonants.
* The player is given 120 seconds as initial time in which he has to form a word using only the letters in the grid (without repetition).
* A valid word is a word that:
  1. has length between 4 and 9 (inclusive).
  2. has the middle letter.
  3. has only the letters in the grid (no repetition).
  4. is a valid dictionary word.
* For every correct answer the player will be awarded 10 points and an additional 30 seconds.
* For every incorrect answer no points will be awarded.
* The player cannot continue if he/she runs out of time. 
* The player can exit the game at anytime by pressing 0.

### Limitations of our Program:
* The random letters do not always form valid words from the dictionary.
* The dictionary does not have all the valid words.
* The total number of valid words that can be formed using the random letters generated have not been calculated.
* The program can display the time remaining only after the player inputs a word.
* There's no graphic user interface.
* Program terminates if you use backspace.

### Extra Features:
* We have implemented sounds to indicate input of wrong and right answers.
* Our lexathon has a time counter to limit the time a player can use to enter the word. For each valid input the player is given more time.
* We have used interactive dialogue box alert messages for the player.

### Screenshots from the Game

![Game start](https://raw.githubusercontent.com/JSKohli/Lexathon/master/Screenshots/Screenshot1.jpg)

![Screenshot2](https://raw.githubusercontent.com/JSKohli/Lexathon/master/Screenshots/Screenshot2.jpg)
