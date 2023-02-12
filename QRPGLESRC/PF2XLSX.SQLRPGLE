**free

// Copyright © 2023 Patrick Behr

// Permission is hereby granted, free of charge, to any person obtaining a copy of 
// this software and associated documentation files (the “Software”), to deal in 
// the Software without restriction, including without limitation the rights to use, 
// copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the 
// Software, and to permit persons to whom the Software is furnished to do so, 
// subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all 
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS 
// IN THE SOFTWARE.

ctl-opt dftactgrp(*no) actgrp('PF2XLSX');
ctl-opt option(*nodebugio : *srcstmt);
ctl-opt main(P2X_main);

/copy IFSIO_H
/copy QSYSINC/QRPGLESRC,SQLSCDS

dcl-pr system int(10) extproc('system');
    cmd  pointer  value options(*string);
end-pr;

dcl-ds sds PSDS qualified;
    currentUser char(10) pos(358);
end-ds;



//------------------------------------------------------------------------------
//  Creates an OOXML spreadsheet based on a file
//------------------------------------------------------------------------------
dcl-proc  P2X_main;
    dcl-pi *n extpgm('PF2XLSX');
        in_libFile char(21) const;
        in_fullPath char(5000) const;
    end-pi;

    dcl-s lib char(10);
    dcl-s file char(10);
    dcl-s path char(5000);
    dcl-s filename char(256);

    P2X_parseLibFile(in_libFile : lib : file);
    P2X_parsePath(in_fullPath : path : filename);

    // make sure all folders in the path exist.
    // send the entire path, including the filename
    P2X_createPath(in_fullPath);

    // create the folders/files we need to create a spreadsheet
    // everything will be created in a subdirectory "pf2xlsx_temp"
    P2X_createFiles(path);

    // Start writing all the generic files we need
    P2X_writeContentTypes(path);
    P2X_writeRels(path);
    P2X_writeApp(path);
    P2X_writeCore(path);
    P2X_writeWorkbookRels(path);
    P2X_writeWorkbook(path);
    P2X_writeStyles(path);
    P2X_writeSharedStrings(path);

    // Add the worksheet with data from file
    P2X_writeSheet(lib : file : path);

    // Zip up all the files
    P2X_zipFiles(path : filename);

    // Move the zip file up to the correct directory
    P2X_moveZip(path : filename);

    // Clean up the temp directory
    P2X_clearTempFolder(path);

    return;

end-proc;

//------------------------------------------------------------------------------
//  Create all the OOXML files that we need for the spreadsheet
//------------------------------------------------------------------------------
dcl-proc  P2X_createFiles;
    dcl-pi *n;
        path char(5000);
    end-pi;

    dcl-s fd int(10);
    dcl-s openFlags int(10);
    dcl-s modeFlags int(10);
    dcl-s codePage uns(10);
    dcl-s errText char(128);

    openFlags = O_WRONLY + O_CREAT + O_TRUNC + O_CODEPAGE;
    modeFlags = S_IRWXU + S_IRWXG + S_IXOTH + S_IROTH;
    codePage = 1208;

    chdir(%trim(path));

    // If the PF2XLSX temp folder already exists, remove it
    if access('pf2xlsx_temp' : F_OK) = 0;
        P2X_clearTempFolder(path);
    endif;

    mkdir('pf2xlsx_temp' : modeFlags);
    chdir('pf2xlsx_temp');

    fd = open('[Content_Types].xml' : openFlags : modeFlags : codePage);
    if fd < 0;
        errText = P2X_getError();
    endif;
    callp(e) close(fd);

    mkdir('_rels' : modeFlags);
    fd = open('_rels/.rels' : openFlags : modeFlags : codePage);
    if fd < 0;
        errText = P2X_getError();
    endif;
    callp(e) close(fd);

    mkdir('docProps' : modeFlags);
    fd = open('docProps/app.xml' : openFlags : modeFlags : codePage);
    if fd < 0;
        errText = P2X_getError();
    endif;
    callp(e) close(fd);
    fd = open('docProps/core.xml' : openFlags : modeFlags : codePage);
    if fd < 0;
        errText = P2X_getError();
    endif;
    callp(e) close(fd);

    mkdir('xl' : modeFlags);
    chdir('xl');

    fd = open('sharedStrings.xml' : openFlags : modeFlags : codePage);
    if fd < 0;
        errText = P2X_getError();
    endif;
    callp(e) close(fd);
    fd = open('styles.xml' : openFlags : modeFlags : codePage);
    if fd < 0;
        errText = P2X_getError();
    endif;
    callp(e) close(fd);
    fd = open('workbook.xml' : openFlags : modeFlags : codePage);
    if fd < 0;
        errText = P2X_getError();
    endif;
    callp(e) close(fd);

    mkdir('_rels' : modeFlags);
    fd = open('_rels/workbook.xml.rels' : openFlags : modeFlags : codePage);
    if fd < 0;
        errText = P2X_getError();
    endif;
    callp(e) close(fd);
    mkdir('worksheets' : modeFlags);
    fd = open('worksheets/sheet1.xml' : openFlags : modeFlags : codePage);
    if fd < 0;
        errText = P2X_getError();
    endif;
    callp(e) close(fd);

    return;
end-proc  P2X_createFiles;


//------------------------------------------------------------------------------
//  Writes to "[Content_Types].xml"
//  The file must have already been created and should be UTF-8
//------------------------------------------------------------------------------
dcl-proc  P2X_writeContentTypes;
    dcl-pi *n;
        path char(5000);
    end-pi;

    // dcl-s path char(5000);
    dcl-s fd int(10);

    dcl-c TYPE_PACKAGE 'ContentType="application/vnd.openxmlformats-package.';
    dcl-c TYPE_DOC 'ContentType="application/vnd.openxmlformats-officedocument.';

    chdir(%trim(path) + '/pf2xlsx_temp');

    fd = open('[Content_Types].xml' : O_WRONLY);
    if fd < 0;
        P2X_getError();
    endif;

    P2X_write(fd:
    '<?xml version="1.0" encoding="UTF-8" standalone="no"?>+
     <Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">+
      <Default '+ TYPE_PACKAGE +'relationships+xml" Extension="rels" />+
      <Default ContentType="application/xml" Extension="xml" />+
      <Override PartName="/docProps/app.xml" '+
                TYPE_DOC +'extended-properties+xml" />+
      <Override PartName="/docProps/core.xml" ' +
                TYPE_PACKAGE + 'core-properties+xml" />+
      <Override PartName="/xl/sharedStrings.xml" ' +
                TYPE_DOC + 'spreadsheetml.sharedStrings+xml" />+
      <Override PartName="/xl/styles.xml" ' +
                TYPE_DOC + 'spreadsheetml.styles+xml" />+
      <Override PartName="/xl/workbook.xml" ' +
                TYPE_DOC + 'spreadsheetml.sheet.main+xml" />+
      <Override PartName="/xl/worksheets/sheet1.xml" ' +
                TYPE_DOC + 'spreadsheetml.worksheet+xml" />+
      </Types>');

    return;

    on-exit;
        callp(e) close(fd);

end-proc  P2X_writeContentTypes;


//------------------------------------------------------------------------------
//  Writes to "_rels/.rels"
//  The file must have already been created and should be UTF-8
//------------------------------------------------------------------------------
dcl-proc  P2X_writeRels;
    dcl-pi *n;
        path char(5000);
    end-pi;

    dcl-s fd int(10);

    dcl-c HTTP_REL 'http://schemas.openxmlformats.org/package/2006/relationships';
    dcl-c HTTP_DOC 'http://schemas.openxmlformats.org/officeDocument/2006/relationships';

    chdir(%trim(path) + '/pf2xlsx_temp/_rels');

    fd = open('.rels' : O_WRONLY);
    if fd < 0;
        P2X_getError();
    endif;

    P2X_write(fd:
    '<?xml version="1.0" encoding="UTF-8" standalone="no"?>+
    <Relationships xmlns="' + HTTP_REL + '">+
        <Relationship Id="rId1" Target="xl/workbook.xml" +
                    Type="' + HTTP_DOC + '/officeDocument" />+
        <Relationship Id="rId2" Target="docProps/app.xml" +
                    Type="' + HTTP_DOC + '/extended-properties" />+
        <Relationship Id="rId3" Target="docProps/core.xml" +
                    Type="' + HTTP_REL + '/metadata/core-properties" />+
    </Relationships>');

    return;

    on-exit;
        callp(e) close(fd);

end-proc  P2X_writeRels;


//------------------------------------------------------------------------------
//  Writes to "docProps/app.xml"
//  The file must have already been created and should be UTF-8
//------------------------------------------------------------------------------
dcl-proc  P2X_writeApp;
    dcl-pi *n;
        path char(5000);
    end-pi;

    dcl-s fd int(10);

    dcl-c HTTP_DOC 'http://schemas.openxmlformats.org/officeDocument/2006';

    chdir(%trim(path) + '/pf2xlsx_temp/docProps');

    fd = open('app.xml' : O_WRONLY);
    if fd < 0;
        P2X_getError();
    endif;

    P2X_write(fd:
    '<?xml version="1.0" encoding="UTF-8"?>+
    <Properties xmlns="' + HTTP_DOC + '/extended-properties">+
        <Application>PF2XLSX</Application>+
    </Properties>');

    return;

    on-exit;
        callp(e) close(fd);

end-proc  P2X_writeApp;


//------------------------------------------------------------------------------
//  Writes to "docProps/core.xml"
//  The file must have already been created and should be UTF-8
//------------------------------------------------------------------------------
dcl-proc  P2X_writeCore;
    dcl-pi *n;
        path char(5000);
    end-pi;

    dcl-s fd int(10);

    dcl-c HTTP_CP 'http://schemas.openxmlformats.org/package/2006/metadata';
    dcl-c HTTP_PURL 'http://purl.org/dc';
    dcl-c HTTP_XSI 'http://www.w3.org/2001';


    chdir(%trim(path) + '/pf2xlsx_temp/docProps');

    fd = open('core.xml' : O_WRONLY);
    if fd < 0;
        P2X_getError();
    endif;

    P2X_write(fd:
    '<?xml version="1.0" encoding="UTF-8" standalone="no"?>+
    <cp:coreProperties +
        xmlns:cp="' + HTTP_CP + '/core-properties" +
        xmlns:dc="' + HTTP_PURL + '/elements/1.1/" +
        xmlns:dcterms="' + HTTP_PURL + '/terms/" +
        xmlns:xsi="' + HTTP_XSI + '/XMLSchema-instance">+
        <dcterms:created xsi:type="dcterms:W3CDTF">'+
            P2X_getUtcTimestamp() +
        '</dcterms:created>+
        <dc:creator>' +
            %trim(sds.currentUser) +
        '</dc:creator>+
    </cp:coreProperties>');

    return;

    on-exit;
        callp(e) close(fd);

end-proc  P2X_writeCore;


//------------------------------------------------------------------------------
//  Writes to "xl/_rels/workbook.xml.rels"
//  The file must have already been created and should be UTF-8
//------------------------------------------------------------------------------
dcl-proc  P2X_writeWorkbookRels;
    dcl-pi *n;
        path char(5000);
    end-pi;

    dcl-s fd int(10);

    dcl-c HTTP_DOC 'http://schemas.openxmlformats.org/officeDocument/2006/relationships';
    dcl-c HTTP_PKG 'http://schemas.openxmlformats.org/package/2006';


    chdir(%trim(path) + '/pf2xlsx_temp/xl/_rels');

    fd = open('workbook.xml.rels' : O_WRONLY);
    if fd < 0;
        P2X_getError();
    endif;

    P2X_write(fd:
    '<?xml version="1.0" encoding="UTF-8" standalone="no"?>+
    <Relationships xmlns="' + HTTP_PKG + '/relationships">+
        <Relationship Id="rId1" Target="sharedStrings.xml" +
                    Type="' + HTTP_DOC + '/sharedStrings" />+
        <Relationship Id="rId2" Target="styles.xml" +
                Type="' + HTTP_DOC + '/styles" />+
        <Relationship Id="rId3" Target="worksheets/sheet1.xml" +
                Type="' + HTTP_DOC + '/worksheet" />+
    </Relationships>');

    return;

    on-exit;
        callp(e) close(fd);

end-proc  P2X_writeWorkbookRels;


//------------------------------------------------------------------------------
//  Writes to "xl/workbook.xml"
//  The file must have already been created and should be UTF-8
//------------------------------------------------------------------------------
dcl-proc  P2X_writeWorkbook;
    dcl-pi *n;
        path char(5000);
    end-pi;

    dcl-s fd int(10);

    chdir(%trim(path) + '/pf2xlsx_temp/xl');

    fd = open('workbook.xml' : O_WRONLY);
    if fd < 0;
        P2X_getError();
    endif;

    P2X_write(fd:
    '<?xml version="1.0" encoding="UTF-8"?>+
    <workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" +
            xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">+
        <workbookPr date1904="false" />+
        <bookViews><workbookView activeTab="0" /></bookViews>+
        <sheets><sheet name="Sheet1" r:id="rId3" sheetId="1" /></sheets>+
    </workbook>');

    return;

    on-exit;
        callp(e) close(fd);

end-proc  P2X_writeWorkbook;


//------------------------------------------------------------------------------
//  Writes to "xl/styles.xml"
//  The file must have already been created and should be UTF-8
//------------------------------------------------------------------------------
dcl-proc  P2X_writeStyles;
    dcl-pi *n;
        path char(5000);
    end-pi;

    dcl-s fd int(10);


    chdir(%trim(path) + '/pf2xlsx_temp/xl');

    fd = open('styles.xml' : O_WRONLY);
    if fd < 0;
        P2X_getError();
    endif;

    P2X_write(fd:
    '<?xml version="1.0" encoding="UTF-8"?>+
    <styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">+
        <numFmts count="0" />+
        <fonts count="3">+
            <font><sz val="11.0" /><color indexed="8" /><name val="Calibri" />+
            <family val="2" /><scheme val="minor" /></font>+
            <font><name val="Calibri" /><sz val="11.0" /><b val="true" /></font>+
            <font><name val="Calibri" /><sz val="11.0" /></font>+
        </fonts>+
        <fills count="2">+
            <fill><patternFill patternType="none" /></fill>+
            <fill><patternFill patternType="darkGray" /></fill>+
        </fills>+
        <borders count="1">+
            <border><left /><right /><top /><bottom /><diagonal /></border>+
        </borders>+
        <cellStyleXfs count="1">+
            <xf numFmtId="0" fontId="0" fillId="0" borderId="0" />+
        </cellStyleXfs>+
        <cellXfs count="3">+
            <xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0" />+
            <xf numFmtId="0" fontId="1" fillId="0" borderId="0" xfId="0" applyFont="true" />+
            <xf numFmtId="0" fontId="2" fillId="0" borderId="0" xfId="0" applyFont="true" />+
        </cellXfs>+
    </styleSheet>');

    return;

    on-exit;
        callp(e) close(fd);

end-proc  P2X_writeStyles;


//------------------------------------------------------------------------------
//  Writes to "xl/sharedStrings.xml"
//  The file must have already been created and should be UTF-8
//------------------------------------------------------------------------------
dcl-proc  P2X_writeSharedStrings;
    dcl-pi *n;
        path char(5000);
    end-pi;

    dcl-s fd int(10);

    chdir(%trim(path) + '/pf2xlsx_temp/xl');

    fd = open('sharedStrings.xml' : O_WRONLY);
    if fd < 0;
        P2X_getError();
    endif;

    P2X_write(fd:
    '<?xml version="1.0" encoding="UTF-8"?>+
    <sst count="0" uniqueCount="0" +
         xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" />');

    return;

    on-exit;
        callp(e) close(fd);

end-proc  P2X_writeSharedStrings;


//------------------------------------------------------------------------------
//  Writes to "xl/worksheets/sheet1.xml"
//  The file must have already been created and should be UTF-8
//------------------------------------------------------------------------------
dcl-proc  P2X_writeSheet;
    dcl-pi *n;
        lib char(10);
        file char(10);
        path char(5000) const;
    end-pi;

    dcl-s fd int(10);


    chdir(%trim(path) + '/pf2xlsx_temp/xl/worksheets');

    fd = open('sheet1.xml' : O_WRONLY);
    if fd < 0;
        P2X_getError();
    endif;

    P2X_write(fd:
    '<?xml version="1.0" encoding="UTF-8"?>+
    <worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">+
        <dimension ref="A1" />+
        <sheetViews><sheetView workbookViewId="0" tabSelected="true" /></sheetViews>+
        <sheetFormatPr defaultRowHeight="15.0" />+
        <sheetData>');


    P2X_loadPfData(fd : lib : file);


    P2X_write(fd:
        '</sheetData>+
        <pageMargins bottom="0.75" footer="0.3" header="0.3" left="0.7" right="0.7" top="0.75" />+
    </worksheet>');

    return;

    on-exit;
        callp(e) close(fd);

end-proc  P2X_writeSheet;


//------------------------------------------------------------------------------
//  Writes data rows "xl/worksheets/sheet1.xml"
//  The file must have already been created and should be UTF-8
//------------------------------------------------------------------------------
dcl-proc  P2X_loadPfData;
    dcl-pi *n;
        fd int(10);
        lib char(10) const;
        file char(10) const;
    end-pi;

    dcl-c MAX_ROWS  1048576;  // Current Excel limit
    dcl-c DATE_TYPE_DATE 1;
    dcl-c DATE_TYPE_TIME 2;
    dcl-c DATE_TYPE_TIMESTAMP 3;


    dcl-s data char(32767) ccsid(*UTF8);
    dcl-s curRow uns(10);
    dcl-s curCol uns(10);
    dcl-s sqlStmt varchar(32);
    dcl-s type int(10);
    dcl-s dateType int(10);
    dcl-s nullInd int(10);

    dcl-s columnCount uns(5);
    dcl-ds columns qualified inz dim(8000);
        name varchar(128);
        type varchar(8);
        precision int(5);
        scale int(5);
    end-ds;
    dcl-ds nullInds qualified inz dim(8000);
        isnull int(5) dim(4);
    end-ds;

    dcl-s charData char(32765);
    dcl-s varcharData varchar(32739);
    dcl-s numData zoned(50 : 20);
    dcl-s decData packed(50 : 20);
    dcl-s smallintData int(5);
    dcl-s intData int(10);
    dcl-s bigintData int(20);
    dcl-s dateData date;
    dcl-s timeData time;
    dcl-s tsData timestamp;

    sqlStmt = 'SELECT * FROM ' + %trim(lib) + '/' + %trim(file);
    Exec SQL
    PREPARE sql_stmt FROM :sqlStmt;

    Exec SQL
        DECLARE pf2xlsx_column_headings CURSOR FOR
        SELECT column_name, data_type, numeric_precision, numeric_scale
        FROM syscolumns
        WHERE system_table_schema = :lib
        AND system_table_name = :file;

    Exec SQL
        OPEN pf2xlsx_column_headings;

    Exec SQL
        FETCH pf2xlsx_column_headings
        FOR 8000 ROWS
        INTO :columns :nullInds;

    Exec SQL
        GET DIAGNOSTICS :columnCount = ROW_COUNT;

    Exec SQL
        CLOSE pf2xlsx_column_headings;

    Exec SQL
    ALLOCATE DESCRIPTOR 'mydescr' WITH MAX :columnCount;

    Exec SQL
    DESCRIBE sql_stmt USING DESCRIPTOR 'mydescr';


    // COLUMN HEADINGS ROW  ==========================
    exsr startNewRow;
    for curCol = 1 to columnCount;

        P2X_write(fd:
        '<c r="'+ P2X_getCellRef(curRow:curCol) +'" s="2" t="inlineStr">+
            <is><t>' + %trim(columns(curCol).name) + '</t></is>+
        </c>');

        // Change scale of zoned and packed fields
        if columns(curCol).type = 'DECIMAL'
        or columns(curCol).type = 'NUMERIC';
            Exec SQL
            SET DESCRIPTOR 'mydescr' VALUE :curCol
            PRECISION = 50, SCALE = 20;
        endif;
    endfor;
    P2X_write(fd: '</row>');


    // TABLE DATA ROWS  ========================
    Exec SQL
    DECLARE sql_cursor CURSOR FOR sql_stmt;

    Exec SQL
    OPEN sql_cursor;

    dou sqlcode = 100 or curRow = MAX_ROWS;

        Exec SQL
        FETCH sql_cursor
        INTO SQL DESCRIPTOR 'mydescr';
        if sqlcode = 100;
            iter;
        endif;

        exsr startNewRow;
        for curCol = 1 to columnCount;

            Exec SQL
             GET DESCRIPTOR 'mydescr' VALUE :curCol
                :type = TYPE,
                :dateType = DATETIME_INTERVAL_CODE,
                :nullInd = INDICATOR;

            if nullInd < 0;
                iter;
            endif;

            P2X_write(fd: '<c r="' + P2X_getCellRef(curRow:curCol) + '" s="2"');

            if type = SQL_TYPE_CHAR;
                clear charData;
                Exec SQL
                  GET DESCRIPTOR 'mydescr' VALUE :curCol
                                :charData = DATA;
                charData = %scanrpl('"' : '&quot;' : charData);
                P2X_write(fd: ' t="inlineStr"><is><t>');
                P2X_write(fd: %trimr(charData));
                P2X_write(fd: '</t></is></c>');
                iter;
            endif;

            if type = SQL_TYPE_VARCHAR;
                clear varcharData;
                Exec SQL
                GET DESCRIPTOR 'mydescr' VALUE :curCol
                    :varcharData = DATA;
                varcharData = %scanrpl('"' : '&quot;' : varcharData);
                P2X_write(fd: ' t="inlineStr"><is><t>');
                P2X_write(fd: %trimr(varcharData));
                P2X_write(fd: '</t></is></c>');
                iter;
            endif;

            if dateType = DATE_TYPE_DATE;
                clear dateData;
                Exec SQL
                GET DESCRIPTOR 'mydescr' VALUE :curCol
                :dateData = DATA;
                P2X_write(fd: ' t="inlineStr"><is><t>');
                P2X_write(fd: %char(dateData));
                P2X_write(fd: '</t></is></c>');
                iter;
            endif;

            if dateType = DATE_TYPE_TIME;
                clear timeData;
                Exec SQL
                GET DESCRIPTOR 'mydescr' VALUE :curCol
                :timeData = DATA;
                P2X_write(fd: ' t="inlineStr"><is><t>');
                P2X_write(fd: %char(timeData));
                P2X_write(fd: '</t></is></c>');
                iter;
            endif;

            if dateType = DATE_TYPE_TIMESTAMP;
                clear tsData;
                Exec SQL
                GET DESCRIPTOR 'mydescr' VALUE :curCol
                :tsData = DATA;
                P2X_write(fd: ' t="inlineStr"><is><t>');
                P2X_write(fd: %char(tsData));
                P2X_write(fd: '</t></is></c>');
                iter;
            endif;

            if type = SQL_TYPE_NUMERIC;
                clear numData;
                Exec SQL
                GET DESCRIPTOR 'mydescr' VALUE :curCol
                :numData = DATA;
                P2X_write(fd: ' t="n"><v>');
                P2X_write(fd: P2X_fixNumber(numData : columns(curCol).scale));
                P2X_write(fd: '</v></c>');
                iter;
            endif;

            if type = SQL_TYPE_DECIMAL;
                clear decData;
                Exec SQL
                GET DESCRIPTOR 'mydescr' VALUE :curCol
                :decData = DATA;
                P2X_write(fd: ' t="n"><v>');
                P2X_write(fd: P2X_fixNumber(decData : columns(curCol).scale));
                P2X_write(fd: '</v></c>');
                iter;
            endif;

            if type = SQL_TYPE_SMALLINT;
                clear smallintData;
                Exec SQL
                GET DESCRIPTOR 'mydescr' VALUE :curCol
                :smallintData = DATA;
                P2X_write(fd: ' t="n"><v>');
                P2X_write(fd: %char(smallintData));
                P2X_write(fd: '</v></c>');
                iter;
            endif;

            if type = SQL_TYPE_INTEGER;
                clear intData;
                Exec SQL
                GET DESCRIPTOR 'mydescr' VALUE :curCol
                :intData = DATA;
                P2X_write(fd: ' t="n"><v>');
                P2X_write(fd: %char(intData));
                P2X_write(fd: '</v></c>');
                iter;
            endif;

            if type = SQL_TYPE_BIGINT;
                clear bigintData;
                Exec SQL
                GET DESCRIPTOR 'mydescr' VALUE :curCol
                :bigintData = DATA;
                P2X_write(fd: ' t="n"><v>');
                P2X_write(fd: %char(bigintData));
                P2X_write(fd: '</v></c>');
                iter;
            endif;

            P2X_write(fd: ' t="inlineStr"><is><t>');
            P2X_write(fd: 'Unsupported data type');
            P2X_write(fd: '</t></is></c>');

        endfor;
        P2X_write(fd: '</row>');

    enddo;

    return;

    begsr startNewRow;
        curRow += 1;
        P2X_write(fd: '<row r="' + %char(curRow) + '">');
    endsr;

    on-exit;
        Exec SQL CLOSE sql_cursor;
        Exec SQL DEALLOCATE DESCRIPTOR 'mydescr';

end-proc  P2X_loadPfData;


//------------------------------------------------------------------------------
//  Convert currentRow + currentCol into a cell reference
//------------------------------------------------------------------------------
dcl-proc P2X_getCellRef;
    dcl-pi *n  varchar(10);
        row uns(10) const;
        col uns(5) value;
    end-pi;
    dcl-s colName char(3);
    dcl-s cellName varchar(10);

    colName = P2X_getCellColumn(col);
    cellName = %trim(colName) + %char(row);

    return cellName;
end-proc P2X_getCellRef;


//------------------------------------------------------------------------------
//  Get cell column
//  Converts a column number into a cell column (i.e. 1="A"  1379="BAA")
//------------------------------------------------------------------------------
dcl-proc P2X_getCellColumn;
    dcl-pi *n char(3);
        colNbr uns(5) value;
    end-pi;

    dcl-c LETTERS 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    dcl-s col char(3);
    dcl-s i uns(3) inz(3);
    dcl-s rem uns(3);

    dou colNbr = 0;
        rem = %rem(colNbr : 26);
        colNbr /= 26;
        if rem = 0;
            rem = 26;
            colNbr -= 1;
        endif;
        %subst(col : i : 1) = %subst(LETTERS : rem : 1);
        i -= 1;
    enddo;

    return %trim(col);
end-proc P2X_getCellColumn;




//------------------------------------------------------------------------------
//  Clear all the contents of the PF2XLSX_TEMP folder
//------------------------------------------------------------------------------
dcl-proc  P2X_clearTempFolder;
    dcl-pi *n;
        path char(5000);
    end-pi;

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

    chdir(%trim(path));
    rmdir('pf2xlsx_temp');

    return;
end-proc  P2X_clearTempFolder;


//------------------------------------------------------------------------------
//  Make sure all directories in the path exist
//------------------------------------------------------------------------------
dcl-proc  P2X_createPath;
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
//  Parse the full path to spreadsheet into path, filename, filetype
//------------------------------------------------------------------------------
dcl-proc  P2X_parsePath;
    dcl-pi  *n;
        fullPath char(5000) const;
        path     char(5000);
        filename char(256);
    end-pi;

    dcl-s lastSlash uns(5);

    lastSlash = %scanr('/' : fullPath);
    path = %subst(fullPath : 1 : lastSlash - 1);
    filename = %subst(fullPath : lastSlash + 1);

    return;
end-proc  P2X_parsePath;


//------------------------------------------------------------------------------
//  Parse the library and file
//------------------------------------------------------------------------------
dcl-proc  P2X_parseLibFile;
    dcl-pi  *n;
        in_libFile char(21) const;
        out_lib char(10);
        out_file char(10);
    end-pi;

    dcl-ds libFile;
        file char(10);
        lib char(10);
    end-ds;
    dcl-s slash uns(3);
    dcl-s dot uns(3);

    // If there's a slash or a dot, it's specified as LIB/FILE
    slash = %scan('/' :in_libFile);
    dot = %scan('.' :in_libFile);

    if slash > 0;
        lib = %subst(in_libFile : 1 : slash-1);
        file = %subst(in_libFile : slash+1);

    elseif dot > 0;
        lib = %subst(in_libFile : 1 : dot-1);
        file = %subst(in_libFile : dot+1);

    // If no slash or dot, it could be 'FILE  LIB' data structure,
    // or perhaps just a file name without a library.
    else;
        libFile = in_libFile;
        if lib = *BLANKS or lib = '*LIBL';
            lib = P2X_findLibrary(file);
        endif;
    endif;

    out_lib = lib;
    out_file = file;

    return;
end-proc  P2X_parseLibFile;


//------------------------------------------------------------------------------
//  Parse the library and file
//------------------------------------------------------------------------------
dcl-proc  P2X_findLibrary;
    dcl-pi  *n char(10);
        in_file char(10);
    end-pi;

    dcl-s lib char(10);

    Exec SQL
    SELECT objlib
    INTO :lib
    FROM TABLE(
        OBJECT_STATISTICS(
            OBJECT_SCHEMA => '*LIBL',
            OBJTYPELIST => '*FILE',
            OBJECT_NAME => :in_file
        )
    )
    INNER JOIN library_list_info
        ON system_schema_name = objlib
    ORDER BY ordinal_position
    FETCH FIRST ROW ONLY;

    return lib;
end-proc  P2X_findLibrary;


// =============================================================================
// P2X_getError
// Gets the error number and text for calls to C procedures that failed
// =============================================================================
dcl-proc  P2X_getError;
    dcl-pi *n char(128);
        error int(10) options(*nopass : *omit);
    end-pi;

    dcl-pr  get_errno  pointer  extproc('__errno')  end-pr;
    dcl-pr  str_error  pointer  extproc('strerror');
        errno  int(10) value;
    end-pr;

    dcl-s  errno  int(10) based(p_errno);
    dcl-s  errstr  char(128) based(p_errstr);

    p_errno = get_errno();
    p_errstr = str_error(errno);

    if %parms >= %parmnum(error) and %addr(error) <> *NULL;
        error = errno;
    endif;

    return errstr;
end-proc  P2X_getError;


// =============================================================================
// P2X_zipFiles
// Zips the contents of the pf2xlsx_temp folder and moves it
// =============================================================================
dcl-proc  P2X_zipFiles;
    dcl-pi *n;
        in_path char(5000);
        in_filename char(256);
    end-pi;

    dcl-c JAR_PATH '/QOpenSys/usr/bin/jar';
    dcl-s qshCmd varchar(5600);
    dcl-s cdCmd varchar(5050);
    dcl-s jarCmd varchar(512);

    cdCmd = 'cd ' + %trim(in_path) + '/pf2xlsx_temp';
    jarCmd = JAR_PATH + ' cvfM ' + %trim(in_filename) + ' ./*';
    qshCmd = 'QSH CMD(''' + cdCmd + ' && ' + jarCmd + ''')';
    system(qshCmd);

    return;
end-proc  P2X_zipFiles;


// =============================================================================
// P2X_moveZip
// Moves the zip file up one directory to the correct path
// =============================================================================
dcl-proc  P2X_moveZip;
    dcl-pi *n;
        in_path char(5000);
        in_filename char(256);
    end-pi;

    dcl-s movCmd varchar(1200);

    movCmd = 'MOV OBJ('''+ %trim(in_path) +'/pf2xlsx_temp/'+ %trim(in_filename) +''') +
                  TODIR(''' + %trim(in_path) + ''')';
    system(movCmd);

    return;
end-proc  P2X_moveZip;



// =============================================================================
// P2X_GetUtcTimestamp
// =============================================================================
dcl-proc  P2X_getUtcTimestamp;
    dcl-pi *n char(20);
    end-pi;

    dcl-pr ConvertDateTimeFormat extpgm('QWCCVTDT');
        inputFormat     char(10) const;
        inputVariable   char(1);
        outputFormat    char(10) const;
        outputVariable  like(utc);
        errorDs         likeds(errorDs);
        inputZone       char(10) const;
        outputZone      char(10) const;
        zoneInfo        char(1);
        lenZoneInfo     int(10) const;
        precisionInd    char(1) const;
    end-pr;

    dcl-ds utc qualified;
        datePart  zoned(8) pos(1);
        timePart  zoned(6) pos(9);
    end-ds;
    dcl-s utcString char(20);

    dcl-ds errorDs qualified;
        bytesProvided int(10) inz(%size(errorDs.msgData));
        bytesAvailable int(10);
        exceptionId char(7);
        *n char(1);
        msgData char(128);
    end-ds;

    dcl-s notUsed char(1);

    ConvertDateTimeFormat(
        '*CURRENT' :
        notUsed    :
        '*YYMD'    :
        utc        :
        errorDs    :
        notUsed    :
        '*UTC'     :
        notUsed    :
        0          :
        '0'
    );

    utcString = %char(%date(utc.datePart) : *ISO-) + 'T' +
            %char(%time(utc.timePart) : *HMS:) + 'Z';

    return utcString;
end-proc  P2X_getUtcTimestamp;



// =============================================================================
// P2X_write
//  Converts to *UTF8 and writes data to IFS file
// =============================================================================
dcl-proc  P2X_write;
    dcl-pi *n int(10);
        fd int(10);
        data char(32767) const;
    end-pi;

    dcl-s  rtnVal int(10);
    dcl-s  ifsData char(32767) ccsid(*UTF8);

    ifsData = data;
    rtnVal = write(fd : %addr(ifsData): %len(%trimr(ifsData)));

    return  rtnVal;
end-proc  P2X_write;



// =============================================================================
// P2X_fixNumber
//  Fixes packed or zoned data to show the correct number of decimal 
//  places and to ensure we always have a leading zero.
// =============================================================================
dcl-proc  P2X_fixNumber;
    dcl-pi *n varchar(52);
        number  packed(50 : 20) const;
        scale   int(5) const;
    end-pi;

    dcl-s  numberChar  char(52);
    dcl-s  rtnVal varchar(52);
    dcl-s  decimalPoint  uns(3);

    rtnVal = %char(%int(number));
    if scale > 0;
        numberChar = %char(number);
        decimalPoint = %check('-0123456789' : numberChar);
        rtnVal += %subst(numberChar : decimalPoint : scale + 1);
    endif;

    return  rtnVal;
end-proc  P2X_fixNumber;
