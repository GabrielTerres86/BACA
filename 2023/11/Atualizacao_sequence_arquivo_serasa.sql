BEGIN
   UPDATE CECRED.CRAPSQU S SET S.NRSEQATU = 1899 where UPPER(squ.nmtabela)  = upper('CRAPCOB') and UPPER(squ.nmdcampo)  = upper('NRSEQARQ') and UPPER(squ.dsdchave)  = upper('14');
   UPDATE CECRED.CRAPSQU S SET S.NRSEQATU = 1786 where UPPER(squ.nmtabela)  = upper('CRAPCOB') and UPPER(squ.nmdcampo)  = upper('NRSEQARQ') and UPPER(squ.dsdchave)  = upper('12');
   COMMIT;
END;