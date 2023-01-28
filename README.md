# PF2XLSX

Reads the contents of a table and outputs it in OOXML (XLSX) format .

## Prerequisites and Limitations
* Will soon require at least version 7.3 and some PTFs  
    * See notes on RPG Cafe here:  
    https://www.ibm.com/support/pages/rpg-cafe-spring-2022-new-messaging-opcodes-snd-msg-and-excp   
  
* Currently does not handle FLOAT nor GRAPHIC data types (future).  
* Uses PASE "jar" command to zip the files.  
>> **Please consider voting for this enhancement to the CPYTOARCF command**    
    https://ibm-power-systems.ideas.ibm.com/ideas/IBMI-I-1816

## Install
1. Download the source  
    *  IFSIO_H is from Scott Klement (thanks Scott!).  
        If you already have that on your system than you probably don't need this one.  

2. Compile the objects
    * Compile the RPG program
    * Optionally compile the command

## Usage
* Command:  
    ```
    PF2XLSX FILE(SOMELIB/MYTABLE) XLSX('/the/path/where/you/want/spreadsheet.xlsx') 
    ```
* Prototyped call:    
    ```
    **free
    /copy PF2XLSX_H
    PF2XLSX('SOMELIB/MYTABLE' : '/the/path/where/you/want/spreadsheet.xlsx');
    return;
    ```
    

## Params
1.  The table to read.  Format can be: 
    * "FILE"  
    * "LIB/FILE"  
    * "FILE______LIB" data structure 
2.  The full path, including filename and extension, where you want the spreadsheet:  
    "/the/path/where/you/want/spreadsheet.xlsx"
