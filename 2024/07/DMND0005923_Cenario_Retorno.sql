BEGIN
  UPDATE crapsqu squ
     SET squ.nrseqatu = 0
   WHERE (UPPER(squ.nmtabela), UPPER(squ.nmdcampo), UPPER(squ.dsdchave)) IN
         (('IEPTB_CON', 'NRSEQUENCIAL', '20240711'), ('IEPTB_RET', 'NRSEQUENCIAL', '20240711'));
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    sistema.excecaointerna(pr_cdcooper => 3, pr_compleme => 'DMND0005923');
    RAISE;
END;
