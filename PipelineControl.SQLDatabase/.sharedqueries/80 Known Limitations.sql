/*
Known Limitations:

    * The Refresh SQL Endpoint pipeline task is currently in preview. It does not support dynamic 
    content for the Workspace. Also, even though it looks like dynamic content is supported for the
    SQL Endpoint Id, if you do put in dynamic content, it is not saved.
    Because of this, I had to put in separate tasks, one for each lakehouse to be refreshed regardless
    of the lakehouse that was actually written to.

    * The Copy Data tasks (in both Full and Delta paths) do not support dynamic content for the 
    Connection Type property. This sample solution just happens to use two sources that are both
    SQL Server so this property is set accordingly. 
    If your solution requires multiple connection types, I leave it up to you, dear reader, to make the
    required changes.

    * Fabric does not expose the Trigger Name pipeline property to the pipeline Dynamic Content editor. 
    Because of this, multiple Top Level Pipelines are used and the Main Control Table is filtered
    based on that name.





*/