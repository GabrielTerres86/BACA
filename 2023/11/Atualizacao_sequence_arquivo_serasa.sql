BEGIN
   UPDATE CECRED.CRAPSQU SQU SET SQU.NRSEQATU = 1899 where UPPER(squ.nmtabela)  = upper('CRAPCOB') and UPPER(squ.nmdcampo)  = upper('NRSEQARQ') and UPPER(squ.dsdchave)  = upper('14');
   UPDATE CECRED.CRAPSQU SQU SET SQU.NRSEQATU = 1786 where UPPER(squ.nmtabela)  = upper('CRAPCOB') and UPPER(squ.nmdcampo)  = upper('NRSEQARQ') and UPPER(squ.dsdchave)  = upper('12');
   COMMIT;
END;