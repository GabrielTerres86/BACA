
BEGIN

  /* CANCELAR SEGUROS CASA */ 
  UPDATE crapseg
     SET crapseg.cdsitseg = 2
        , crapseg.dtcancel = trunc(sysdate) /* cancelamento ocorrera em 30/09/2019*/  
     -- , crapseg.dtfimvig = crapseg.dtfimvig
        , crapseg.cdmotcan = 1 /* Não interesse pelo Seguro */
        , crapseg.cdopeexc = '1'
        , crapseg.cdageexc = 1
        , crapseg.dtinsexc = crapseg.dtcancel 
        , crapseg.cdopecnl = '1'
  
   WHERE crapseg.cdcooper IN (2,6,8,12,13) /* 2-ACREDICOOP, 6-UNILOS, 8-CREDELESC, 12-CREVISC e 13-CIVIA */ 
     AND crapseg.cdsitseg IN (1,3) /* novo, renovado */ 
     AND crapseg.tpseguro = 11     /* CASA */
     AND crapseg.cdsegura = 5011;  /* CHUBB */ 
  
  COMMIT;
END;

 
