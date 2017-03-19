This is the project capstone for the course Getting and Cleaning Data from Coursera.

Note that I used a lot of help from benjamin-chan's project, you can find his project here in GitHub by searching "benjamin-chan" (his user name).

The script "run_analysis.R" works as follow (note that inside the scripts there are comments describing it's functionality):

1 -> Load the libraries needed for the proper functioning of the script.

2 -> Download the file using the current directory set in your R Studio.

3 -> Extract the file using WinRAR, meaning that you need WinRAR installed in the exact same directory as set in the script.

4 -> Set the PathIn variable as the result of the extracted zip file.

5 -> Read the files with the fread function.

6 -> Merge files as needed, first merging by Rows and then by Columns, finally, set the key to the Data Frame.

7 -> Separate only the Mean and Standard Deviation, as asked by the project.

8 -> Set the descriptive activity names.

9 -> Seperate features from featureName using the helper function grepthis.

10 -> Finally, create the Tidy Set.
