/*
This script is a detailed explanation of each pipeline in the solution and the tasks contained in each.

* Top Level Pipeline
    * Set Possible Debug: Examines the Debug parameter and if 1, sets the Main Control Table Name parameter to include "_DEBUG". The 
    * Get Sum Of Objects to Copy: Counts the number of Objects in the Main Control Table to be loaded
    * Copy Batches Of Objects Sequentially: Divides the set of Objects into batches
        * Calls the Middle Level Pipeline

* Middle Level Pipeline
    * For Each: Divide One Batch Into Multiple Groups: 
        * Calls the Bottom Level Pipeline


* Bottom Level Pipeline
    * Switch on Load Type: Full Load or Delta Load
        * Full Load:
            * Full Load One Object: Copy Data from Source to Destination
            * 
        * Delta Load:
            * Delta Load One Object: Copy Data (via a query) from Source to Destination. Uses UPSERT functionality of a Lakehouse for the Destination.
            * 
            










*/