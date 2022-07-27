BEGIN
  UPDATE cecred.crapsqu squ
  SET   squ.nrseqatu = 19
  WHERE upper(squ.nmtabela) = 'GNCONVE' 
    AND upper(squ.nmdcampo) = 'NRSEQCXA' 
    AND upper(squ.dsdchave) = 'FGTS';

  COMMIT;
END;