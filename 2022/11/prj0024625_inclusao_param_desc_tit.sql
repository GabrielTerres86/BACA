BEGIN
  INSERT INTO tbcred_parametro_analise ( cdcooper,
                                         tpproduto,
                                         incomite,
                                         incontigen,
                                         inanlautom,
                                         nmregmpf,
                                         nmregmpj,
                                         qtsstime,
                                         qtmeschq,
                                         qtmeschqal11,
                                         qtmeschqal12,
                                         qtmesest,
                                         qtmesemp,
                                         incalris)
  SELECT w.cdcooper,
         1 tpproduto,
         w.incomite,
         w.incontigen,
         w.inanlautom,
         'PoliticaDescontoTitPF' nmregmpf,
         'PoliticaDescontoTitPJ' nmregmpj,
         w.qtsstime,
         w.qtmeschq,
         w.qtmeschqal11,
         w.qtmeschqal12,
         w.qtmesest,
         w.qtmesemp,
         w.incalris
    FROM tbcred_parametro_analise w
   WHERE  w.tpproduto = 5;

  COMMIT;
END;
