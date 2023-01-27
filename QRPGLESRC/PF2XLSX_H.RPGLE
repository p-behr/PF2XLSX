**free

/IF DEFINED(PF2XLSX)
/EOF
/ENDIF
/DEFINE PF2XLXS

dcl-pr PF2XLSX extpgm('PF2XLSX');
    in_libFile varchar(21) const;
    in_fullPath char(5000) const;
end-pr;
