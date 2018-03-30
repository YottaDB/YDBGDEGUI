# YottaDBGUI
Repository for all GUI apps developed by YottaDB

Instructions for launching the GDE GUI:
1. Run YottaDB once in direct mode to ensure that the database is present, then halt.
2. Copy the routines from this repository's r/ directory to a directory listed in $gtmroutines, such as $gtmdir/$gtmver/r.
3. Copy the web/www/ folder from this repository into $gtmdir.
4. In YottaDB direct mode, set ^%WHOME to the full path of where you copied the web/www/ directory (including the web/www/ portion). 
5. From direct mode, run DO WEB^GDE(portnum) - portnum can be 8080.
6. In the browser, connect to localhost:8080 to load the GUI.
7. To shut down the server, kill the mumps server process; currently, this is the only way to stop the server.
8. To restart the server, run DO WEB^GDE(8080) from direct mode.
