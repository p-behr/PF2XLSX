**free

/IF DEFINED(PF2XLSX_H)
/EOF
/ENDIF
/DEFINE PF2XLSX_H


//------------------------------------------------------------------------------
//  Create all the files that we need for the spreadsheet
//------------------------------------------------------------------------------
dcl-pr P2X_createFiles extproc(*dclcase);
    fullPath char(5000) const;
end-pr;


//------------------------------------------------------------------------------
//  Create all the folders that we need for the spreadsheet
//------------------------------------------------------------------------------
dcl-pr P2X_createFolders extproc(*dclcase);
    fullPath char(5000) const;
end-pr;


//------------------------------------------------------------------------------
//  Clear the contents of the PF2XLSX temporary folder
//------------------------------------------------------------------------------
dcl-pr P2X_clearTempFolder extproc(*dclcase);
    fullPath char(5000) const;
end-pr;


//------------------------------------------------------------------------------
//  Make sure all directories in the path exist
//------------------------------------------------------------------------------
dcl-pr P2X_createPath extproc(*dclcase);
    fullPath char(5000) const;
end-pr;


//------------------------------------------------------------------------------
//  Parse the LIB/FILE data structure into individual fields.
//------------------------------------------------------------------------------
dcl-pr P2X_parsePath  extproc(*dclcase);
    fullPath char(5000) const;
    path     char(5000) options(*nopass : *omit);
    file     char(256)  options(*nopass : *omit);
    type     char(10)   options(*nopass : *omit);
end-pr;
