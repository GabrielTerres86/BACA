BEGIN
  UPDATE cecred.craprda rda
     SET rda.insaqtot = 1
        ,rda.vlsdrdca = 0
        ,rda.vlsltxmx = 0
        ,rda.vlsltxmm = 0
   WHERE rda.vlsltxmm <= 0
     AND rda.vlsltxmx > 0
     AND rda.insaqtot = 0
     AND rda.tpaplica IN (7, 8)
     AND rda.vlsdrdca > 0;
  COMMIT;   
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.EXCECAOINTERNA(pr_cdcooper => 3, pr_compleme => 'Altera saldo indevido inc0302555 ');
     
END;