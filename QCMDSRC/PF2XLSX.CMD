                                                            
/* Command front end for PF2XLSX program    */              
/* There's an extra space in the File/Lib   */              
/* parm because the RPG accepts CHAR(21)    */              
/* and the command will only send CHAR(20)  */              
/* leaving a '/' in the last byte.          */              
                                                            
CMD PROMPT('OUTPUT FILE TO A SPREADSHEET')                  
                                                            
PARM  KWD(FILE) TYPE(Q1) MIN(1) PROMPT('File')              
PARM  KWD(XLSX) TYPE(*PNAME) LEN(5000) MIN(1) PROMPT('Path')
                                                            
Q1:   QUAL TYPE(*NAME) LEN(10) MIN(1)                       
      QUAL TYPE(*NAME) LEN(10) DFT(*LIBL) +                 
           SPCVAL((*LIBL)) PROMPT('Library')                
      QUAL TYPE(*CHAR) LEN(1) CONSTANT(' ') MIN(1)          