## Bees Harvest ##

Ruby v.2.0.0, Rails v.4.1.1

### Description ###

1. Index page get data from two files located inside the project: db/pollens.csv and db/harvest.csv.

2. Visualization of data contains three main fields:

   - text info;
   
   - graph;
   
   - table;
   
   Graph and table data can be switched to show data per days or per bees.
   
3. User can upload other files which would be a format of .csv and would have the same structure of columns. These files are not saved to a disk but only analyzed to build new visualization.

4. Start "rake test" command in rails console to perform application test.

### Libraries and templates ###

1. View template - Bootstrap United: https://bootswatch.com/united/
2. Javascript library to build a graph - d3.js: http://d3js.org/
