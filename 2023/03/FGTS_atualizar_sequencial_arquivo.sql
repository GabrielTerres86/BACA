BEGIN
update crapsqu
   set nrseqatu = nrseqatu + 1
 where UPPER(nmtabela) = upper('GNCONVE')
   and UPPER(nmdcampo) = upper('NRSEQCXA')
   and UPPER(dsdchave) = upper( 'FGTS' );
  COMMIT;
END;							   