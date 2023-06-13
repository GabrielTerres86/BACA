BEGIN
  UPDATE credito.tbcred_pronampe_contrato x
     SET x.vlsolicitacaohonra =
         (SELECT z.vlsaldhonrrec
            FROM credito.tbcred_pronampe_infdiario z
           WHERE z.idcontrato = x.idcontrato
             AND z.dtinfdiario = (SELECT MIN(y.dtinfdiario)
                                    FROM credito.tbcred_pronampe_infdiario y
                                   WHERE y.idcontrato = z.idcontrato))
   WHERE x.idcontrato IN (SELECT a.idcontrato
                            FROM credito.tbcred_pronampe_contrato  a
                                ,credito.tbcred_pronampe_infdiario b
                           WHERE a.dtsolicitacaohonra = b.dtinfdiario
                             AND a.idcontrato = b.idcontrato
                             AND b.tpregistro = '98'
                             AND a.vlsolicitacaohonra <> b.vlsaldhonrrec);

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
