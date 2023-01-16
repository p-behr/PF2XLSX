**free

ctl-opt nomain;

/copy IFSIO_H
/copy PF2XLSX_H


//------------------------------------------------------------------------------
//  Create all the OOXML files that we need for the spreadsheet
//------------------------------------------------------------------------------
dcl-proc  P2X_createFiles  export;
    dcl-pi *n;
        fullPath char(5000) const;
    end-pi;

    dcl-s path char(5000);
    dcl-s fd int(10);
    dcl-s openFlags int(10);
    dcl-s modeFlags int(10);
    dcl-s codePage uns(10);

    openFlags = O_WRONLY + O_CREAT + O_TRUNC + O_CODEPAGE;
    modeFlags = S_IRWXU + S_IRWXG + S_IXOTH + S_IROTH;
    codePage = 1208;

    P2X_parsePath(fullPath : path);
    chdir(%trim(path));

    if access('pf2xlsx_temp' : F_OK) = 0;
        P2X_clearTempFolder(fullPath);
        chdir(%trim(path));
    else;
        mkdir('pf2xlsx_temp' : modeFlags);
    endif;

    chdir('pf2xlsx_temp');

    fd = open('[Content_Types].xml' : openFlags : modeFlags : codePage);
    callp close(fd);

    mkdir('_rels' : modeFlags);
    fd = open('_rels/.rels' : openFlags : modeFlags : codePage);
    callp close(fd);

    mkdir('docProps' : modeFlags);
    fd = open('docProps/app.xml' : openFlags : modeFlags : codePage);
    callp close(fd);
    fd = open('docProps/core.xml' : openFlags : modeFlags : codePage);
    callp close(fd);

    mkdir('xl' : modeFlags);
    chdir('xl');

    fd = open('sharedStrings.xml' : openFlags : modeFlags : codePage);
    callp close(fd);
    fd = open('styles.xml' : openFlags : modeFlags : codePage);
    callp close(fd);
    fd = open('workbook.xml' : openFlags : modeFlags : codePage);
    callp close(fd);

    mkdir('_rels' : modeFlags);
    fd = open('_rels/workbook.xml.rels' : openFlags : modeFlags : codePage);
    callp close(fd);
    mkdir('worksheets' : modeFlags);
    fd = open('worksheets/sheet1.xml' : openFlags : modeFlags : codePage);
    callp close(fd);

    return;
end-proc  P2X_createFiles;


//------------------------------------------------------------------------------
//  Clear all the contents of the PF2XLSX_TEMP folder
//------------------------------------------------------------------------------
dcl-proc  P2X_clearTempFolder  export;
    dcl-pi *n;
        fullPath char(5000) const;
    end-pi;

    dcl-s path char(5000);

    P2X_parsePath(fullPath : path);
    chdir(%trim(path) + '/pf2xlsx_temp');

    unlink('_rels/.rels');
    rmdir('_rels');

    unlink('docProps/app.xml');
    unlink('docProps/core.xml');
    rmdir('docProps');

    unlink('xl/_rels/workbook.xml.rels');
    rmdir('xl/_rels');

    unlink('xl/worksheets/sheet1.xml');
    rmdir('xl/worksheets');

    unlink('xl/sharedStrings.xml');
    unlink('xl/styles.xml');
    unlink('xl/workbook.xml');
    rmdir('xl');

    unlink('[Content_Types].xml');

    return;
end-proc  P2X_clearTempFolder;


//------------------------------------------------------------------------------
//  Make sure all directories in the path exist
//------------------------------------------------------------------------------
dcl-proc  P2X_createPath  export;
    dcl-pi *n;
        fullPath char(5000) const;
    end-pi;

    dcl-s pos uns(5);
    dcl-s curPath char(5000);

    pos = %scan('/' : fullPath : 2);
    dow pos > 0;
        curPath = %subst(fullPath : 1 : pos);
        if access(%trim(curPath) : F_OK) = -1;
            // create the directory and grant RWX to user + group and RX to public
            mkdir(%trim(curPath) : S_IRWXU + S_IRWXG + S_IROTH + S_IXOTH);
        endif;
        pos = %scan('/' : fullPath : pos + 1);
    enddo;

    return;
end-proc  P2X_createPath;


//------------------------------------------------------------------------------
//  Parse the LIB/FILE data structure into individual fields.
//------------------------------------------------------------------------------
dcl-proc  P2X_parsePath  export;
    dcl-pi  *n;
        fullPath char(5000) const;
        path     char(5000) options(*nopass : *omit);
        file     char(256)  options(*nopass : *omit);
        type     char(10)   options(*nopass : *omit);
    end-pi;

    dcl-s lastSlash uns(5);
    dcl-s dotExt uns(5);

    lastSlash = %scanr('/' : fullPath);
    dotExt = %scanr('.' : fullPath);

    if %parms >= %parmNum(path) and %addr(path) <> *NULL;
        path = %subst(fullPath : 1 : lastSlash - 1);
    endif;

    if %parms >= %parmNum(file) and %addr(file) <> *NULL;
        file = %subst(fullPath : lastSlash + 1 : dotExt - (lastSlash + 1) );
    endif;

    if %parms >= %parmNum(type) and %addr(type) <> *NULL;
        type = %subst(fullPath : dotExt + 1);
    endif;

    return;
end-proc  P2X_parsePath;

