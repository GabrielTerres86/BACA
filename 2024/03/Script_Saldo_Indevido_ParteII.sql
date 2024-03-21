BEGIN
  UPDATE cecred.craprda rda
     SET rda.insaqtot = 1
        ,rda.vlsdrdca = 0
        ,rda.vlsltxmx = 0
        ,rda.vlsltxmm = 0
   WHERE rda.progress_recid IN (SELECT rda.progress_recid
                            FROM craprda rda
                                ,crapcop cop
                           WHERE rda.cdcooper = cop.cdcooper
                             AND round(rda.vlsltxmx, 2) <= 0
                             AND rda.insaqtot = 0
                             AND rda.tpaplica IN (7, 8)
                             AND cop.FLGATIVO = 1);

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.EXCECAOINTERNA(pr_cdcooper => 3, pr_compleme => 'Altera saldo indevido II inc0302555 ');
  
END;
