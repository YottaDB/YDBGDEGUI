# YottaDBGUI
Repository for all GUI apps developed by YottaDB. At present, it only contains a proof-of-concept prototype for a GDE GUI.

Instructions for launching the GDE GUI:
1. Run YottaDB once in direct mode to ensure that the database is present, then halt.
2. Either copy the routines from this repository's r/ directory to a directory listed in $gtmroutines, such as $gtmdir/$gtmver/r or adjust $gtmroutines so that the routines are executed ahead of any routines in $ydb_dist. You must do this with the environment variable; setting $zroutines inside a process does not pass any changes in $zroutines to JOB'd processes.
3. Set ^%WHOME to the full path of the web/www directory from the repository, ending with web/www/. While this proof of concept uses global variables, the production version will not.
5. From direct mode, run DO WEB^GDE(portnum); e.g., DO WEB^GDE(8080)
  * If the routines are being compiled, compilation errors from code intended for other MUMPS implementations is expected. This will not be the case for the production version.
  * Click on the dot next to a node to bring up a menu for that item. At present, the menu items only pertain to connectivity and node existence. In the production version, you will be able to edit other properties.
  * Saving re-orders the graph.
6. In the browser, connect to localhost:portnum (e.g. localhost:8080) to load the GUI. Use the mouse scrolling function to zoom in and out.
7. To shut down the server, kill the mumps server process; currently, this is the only way to stop the server.
8. To restart the server, run DO WEB^GDE(portnum) from direct mode.

Note that this is just a proof-of-concept prototype, and not intended for use other than to evaluate user-interface models.
