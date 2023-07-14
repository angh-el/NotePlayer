# NotePlayer

## Aims of the project
- Produce a program that is capable of playing musical notes depending on user input
- Allow the use to choose the colour of the background and line on which the stave will be drawn

## Overview of the program 
![image](https://github.com/angh-el/NotePlayer/assets/123000792/505e135d-71ca-4cc8-8ed4-f1fe319425ee)


## How it woeks
- the program is written in mips assembly language
- registers are used to store user inputs and variable
- program is split into different functions, for each option
  - cls: based on user input it will fill the background in
  - stave: it takes a user integer input and draws the first line of the satve on that line; it also does validation and insures the input is valid
  - note: it takes a char input from the user and draws a not in the correct place and plays the sound associated with that note
  - exit: it ends the program
- note that users have to connect to the Bitmap display manually and select the correct settings 

## Ho to install and run the program
- the program is written in mips assembly language, therefore the Mars Emulator can be used to run the program
- clone the repository -> **_git clone https://github.com/angh-el/NotePlayer_**
- open the Mars emulator and open the **_NotePlayer.asm_** file
- click on **_Run_** and **_Run_**
- open the display -> **_Tools_** then **_Bitmap Display_**
  ![image](https://github.com/angh-el/NotePlayer/assets/123000792/f9b079e6-1a0a-4871-b6ed-04ad9da4a42b)
- choose the settings as in the image above and click **_Connect to MIPS_**
- click the green arrow at the top of the screen to run the program

  ## How to use the program
  - firstly choose option '1' and choose the background colour
    ![image](https://github.com/angh-el/NotePlayer/assets/123000792/aa6e0da1-6217-4b75-9eac-edff068b737d)

  - choose option '2' to draw the stave and enter the line on which you would like to do so
    ![image](https://github.com/angh-el/NotePlayer/assets/123000792/236cbc5b-2b65-442a-9c03-01054e2eb75e)

  - choose option '3' to play and draw the musical notes
    ![image](https://github.com/angh-el/NotePlayer/assets/123000792/3a99bc74-0f34-4831-97a1-d068e23f5c8e)

  - option '4' exits the code
