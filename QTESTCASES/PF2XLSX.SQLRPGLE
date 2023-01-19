**free
ctl-opt  nomain;
ctl-opt  option(*srcstmt : *nodebugio);
ctl-opt  bnddir('PF2XLSX');

/copy rpgunit/qinclude,TESTCASE
/copy IFSIO_H

// prototype(s) for the system under test
/copy PF2XLSX_H

// =============================================================================
// =============================================================================
// Set up procedures
// =============================================================================
// =============================================================================

// -----------------------------------------------------------------------------
// Setup Suite
// Called once (and only once) at the very beginning of testing
// -----------------------------------------------------------------------------
dcl-proc  setupSuite;
    return;
end-proc  setupSuite;

// -----------------------------------------------------------------------------
// Setup
// Called before each individual test
// -----------------------------------------------------------------------------
dcl-proc  setup;
    return;
end-proc  setup;

// -----------------------------------------------------------------------------
// Teardown
// Called after each individual test
// -----------------------------------------------------------------------------
dcl-proc  teardown;
    return;
end-proc  teardown;

// -----------------------------------------------------------------------------
// Teardown Suite
// Called once at the end of testing after all tests have run
// -----------------------------------------------------------------------------
dcl-proc  teardownSuite;
    return;
end-proc  teardownSuite;



// =============================================================================
// =============================================================================
// TEST CASES
// =============================================================================
// =============================================================================


// =============================================================================
dcl-proc test_parsePath export;
    dcl-s fullPath char(5000);
    dcl-s expectedPath char(5000);
    dcl-s actualPath char(5000);
    dcl-s expectedFile char(256);
    dcl-s actualFile char(256);
    dcl-s expectedType char(10);
    dcl-s actualType char(10);

    fullPath = '/dir1/dir2/dir3/thefilename.extension';
    P2X_parsePath(fullPath : actualPath : actualFile : actualType);

    expectedPath = '/dir1/dir2/dir3';
    expectedFile = 'thefilename';
    expectedType = 'extension';

    aEqual( expectedPath : actualPath : 'Path');
    aEqual( expectedFile : actualFile : 'File');
    aEqual( expectedType : actualType : 'Type');

    return;
end-proc test_parsePath;


// =============================================================================
dcl-proc test_createPath export;

    dcl-c FOLDER_EXISTS 0;
    dcl-s folderCheck int(10);

    rmdir('/home/rpgunit/pf2xlsx');

    P2X_createPath('/home/rpgunit/pf2xlsx/testfile.xlsx');

    folderCheck = access('/home/rpgunit/pf2xlsx/' : F_OK);
    iEqual(FOLDER_EXISTS : folderCheck : 'Path folders');

    return;
end-proc test_createPath;


// =============================================================================
dcl-proc test_createFiles export;

    dcl-c FILE_EXISTS 0;
    dcl-s fileCheck int(10);

    P2X_createPath('/home/rpgunit/pf2xlsx/testfile.xlsx');
    P2X_createFiles('/home/rpgunit/pf2xlsx/testfile.xlsx');

    fileCheck = access('/home/rpgunit/pf2xlsx/pf2xlsx_temp/[Content_Types].xml' : F_OK);
    iEqual(FILE_EXISTS : fileCheck : 'ContentTypes.xml');

    fileCheck = access('/home/rpgunit/pf2xlsx/pf2xlsx_temp/_rels/.rels' : F_OK);
    iEqual(FILE_EXISTS : fileCheck : '.rels');

    fileCheck = access('/home/rpgunit/pf2xlsx/pf2xlsx_temp/docProps/app.xml' : F_OK);
    iEqual(FILE_EXISTS : fileCheck : 'app.xml');

    fileCheck = access('/home/rpgunit/pf2xlsx/pf2xlsx_temp/docProps/core.xml' : F_OK);
    iEqual(FILE_EXISTS : fileCheck : 'core.xml');

    fileCheck = access('/home/rpgunit/pf2xlsx/pf2xlsx_temp/xl/_rels/workbook.xml.rels' : F_OK);
    iEqual(FILE_EXISTS : fileCheck : 'workbook.xml.rels');

    fileCheck = access('/home/rpgunit/pf2xlsx/pf2xlsx_temp/xl/worksheets/sheet1.xml' : F_OK);
    iEqual(FILE_EXISTS : fileCheck : 'sheet1.xml');

    fileCheck = access('/home/rpgunit/pf2xlsx/pf2xlsx_temp/xl/sharedStrings.xml' : F_OK);
    iEqual(FILE_EXISTS : fileCheck : 'sharedStrings.xml');

    fileCheck = access('/home/rpgunit/pf2xlsx/pf2xlsx_temp/xl/styles.xml' : F_OK);
    iEqual(FILE_EXISTS : fileCheck : 'styles.xml');

    fileCheck = access('/home/rpgunit/pf2xlsx/pf2xlsx_temp/xl/workbook.xml' : F_OK);
    iEqual(FILE_EXISTS : fileCheck : 'workbook.xml');

    return;
end-proc test_createFiles;


// =============================================================================
dcl-proc test_clearTempFolder export;

    dcl-c FOLDER_NOT_EXISTS -1;
    dcl-s folderCheck int(10);

    P2X_createPath('/home/rpgunit/pf2xlsx/testfile.xlsx');
    P2X_createFiles('/home/rpgunit/pf2xlsx/testfile.xlsx');
    P2X_clearTempFolder('/home/rpgunit/pf2xlsx/testfile.xlsx');

    folderCheck = access('/home/rpgunit/pf2xlsx/pf2xlsx_temp' : F_OK);
    iEqual(FOLDER_NOT_EXISTS : folderCheck : 'Path folders');

    return;
end-proc test_clearTempFolder;
