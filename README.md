*This language works on Visual Studio Code and Replit
To use this programming language you first need to download the "scratchflow.lua" file and place it in your coding folder.

Next up, create a new file with any name you want with the extension '.sfw'.
e.g.:
The file "helloworld.py" is called 'helloworld' and has the extension '.py'.

After you created such file, go into "scratchflow.lua" and at the top there should be FILE = "".
Go ahead and place the full name of the file you created in between the " ".
e.g.:
I have a file called "testing.sfw". So I put "testing.sfw" in between the " " (FILE = "testing.sfw").


**Running the file**
*Visual Studio Code:
Go into ".vscode/launch.json" and replace "program" to ""program": "${workspaceFolder}/scratchflow.lua""

*Replit:
Go into ".replit" in Coding Files and replace "entrypoint" to "entrypoint = "scratchflow.lua"" and "run" to  "run = "lua scratchflow.lua""


Now you should be good using this language.