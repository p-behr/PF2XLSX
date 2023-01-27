# PF2XLSX

Reads the contents of a table and outputs it in OOXML (XLSX) format .

## Params
1.  The table to read.  Format can be: 
    * "FILE"  
    * "LIB/FILE"  
    * "FILE______LIB" data structure 
2.  The full path where you want the spreadsheet:  
    "/home/user/reports/spreadsheet.xlsx"
## Limitations

* Currently does not handle FLOAT and GRAPHIC data types (future).

* It's using the PASE "jar" command to zip the files, so it's calling QSH.  
** Please consider voting for this enhancement to the CPYTOARCF command:  
https://ibm-power-systems.ideas.ibm.com/ideas/IBMI-I-1816
