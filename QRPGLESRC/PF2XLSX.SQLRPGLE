**free

ctl-opt dftactgrp(*no) actgrp('PF2XLSX');
ctl-opt main(main);

dcl-proc  main;
    dcl-pi *n;
        inputFile char(21) const;
        outputPath varchar(5000) const;
    end-pi;


    return;
end-proc  main;
