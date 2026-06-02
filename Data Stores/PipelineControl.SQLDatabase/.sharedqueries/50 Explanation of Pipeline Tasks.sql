/*
This script is a detailed explanation of each pipeline in the solution and the tasks contained in each.

* Top Level Pipeline (Full, Debug, etc.)
    * Set Possible Debug: Examines the Debug parameter and if 1, sets the Main Control Table Name parameter to include "_DEBUG". The 
    * Get Sum Of Objects to Copy: Counts the number of Objects in the Main Control Table to be loaded
    * Copy Batches Of Objects Sequentially: Divides the set of Objects into batches
        * Calls the Middle Level Pipeline and specifies the CurrentSequentialNumberOfBatch.
        Example: There are 50 tables to be loaded. The batch size is 20 tables. The Middle Level Pipeline
                 will be called three times, with the CurrentSequentialNumberOfBatch 1, 2, and 3.

    Parameters:
    The Top Level Pipelines are the only ones that should be run directly or scheduled. The parameters
    are as follows:
    * MaxNumberOfObjectsReturnedFromLookupActivity  
        Maximum Number of Objects (tables) Returned From Lookup Activity
        Default = 5000
    * MaxNumberOfConcurrentTasks
        Maximum Number of concurrent FULL or DELTA queries that will be run by the Bottom Level for any one Batch.
        Default = 20
    * MainControlTableName
        The name of the view or table that contains the configuration data. 
        Default = dbo.MainControlTable_JSON_FLATTENED
    * DEBUG     
        Sets up a Debug Run
        Default = 0

* Middle Level Pipeline
    * For Each: 
        * Lookup: Gets the set of objects from the Control Table based on the CurrentSequentialNumberOfBatch and builds an ordered list.
        * Calls the Bottom Level Pipeline and passes the rows as an Array to an input parameter.


* Bottom Level Pipeline
    * For Each: For Each object (row) in the Array sent down via the input parameter:
        * Switch on Load Type: Full Load or Delta Load
            * Full Load:
                * Full Load One Object: Copy Data from Source to Destination
                * Update Watermark Column: Runs the stored procedure to record the LastRunDateTime of the load.
                * Lookup: Find the Delta Load row in the control table that matches this Full Load. Used later on.
                * Refresh SQL Endpoint: (Does not take dynamic content so I had to refresh each one manually.)
                * Lookup: Run the Watermark Query to get the new Watermark Value
                * Update Watermakr Column: Runs the stored procedure to record the new Watermark Value to the Delta Load row.
            * Delta Load:
                * Delta Load One Object: Copy Data (via a query) from Source to Destination. Uses UPSERT functionality of a Lakehouse for the Destination.
                * Refresh SQL Endpoint: (Does not take dynamic content so I had to refresh each one manually.)
                * Lookup: Run the Watermark Query to get the new Watermark Value
                * Update Watemark Column: Runs the stored procedure to record BOTH the new Watermark Value and the Last Run Date Time for this Delta Load.
                

*/








*/