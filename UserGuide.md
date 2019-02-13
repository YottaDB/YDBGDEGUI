# Global Director Editor (GDE) GUI User Guide

The Global Directory Editor GUI is the first GUI available for YottaDB and aims to make editing global directories easier for both experienced users as well as those just getting started with YottaDB.

This guide isn't intended to cover all global directory elements and meanings. Please see the [Admin and Operations Guide](https://docs.yottadb.com/AdminOpsGuide/gde.html) for more information about global directory elements and theory.

## Overall layout

There are 4 main sections:

1. Global Action Bar
2. Names
3. Regions
4. Segments
5. Global mapping (hidden behind Advanced button)

### Global Action bar

The global action bar contains actions that change all sections within the global directory:

1. Search
2. Advanced
3. Save
4. Add

#### Search

The search box and button allow filtering of all sections of the GUI to just display what the search term matches (this can include "hidden" matches based on other data contained within the object that may not be displayed in the GUI).

#### Advanced

This controls the visibility of the global mapping data. global mapping data contains the range of data mapped to a particular region/segment that may assist in visualizing exactly where your data may be stored.

#### Save

This saves the displayed global directory to the system running the Global Directory Editor GUI. This also performs validation of the global directory and if it doesn't pass validation it will not save the global directory until any error is fixed. If you want to get back to the saved state of the global directory before any changes were made, refresh the page in your web browser

#### Add

This allows for the addition of Names, Regions, and Segments to the global directory.

This dialog box remembers certain input parameters to make adding lots of similar items in quick succession faster and easier.

### Names

This displays all Names within the global directory including Region and File information.

The Actions column contains:

 * Edit - Allows changing the Name to a different Region
 * Delete - Deletes the Name from the global directory
 * Show Details - Shows the rest of the information not shown in the table

### Regions

This displays Region information contained within the global directory.

The Actions column contains:

 * Delete
 * Show Details - Shows the rest of the information not shown in the table

### Segments

This displays Segment information contained within the global directory.

The Actions column contains:

 * Delete
 * Show Details - which shows the rest of the information not shown in the table

### Global mapping

This displays global mapping information which includes:

 * The starting global name (inclusive)
 * The ending global name (exclusive)
 * Region
 * Segment
 * File Name

This view can prove useful to determine where a given global is stored on the file system.
