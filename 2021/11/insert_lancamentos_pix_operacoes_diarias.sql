DECLARE 
  ------------------------------- CURSORES ---------------------------------
  CURSOR cr_obterAutoAtendimentoPix(pr_dataIni DATE,
                                    pr_dataFim DATE) IS
    SELECT autoatendimento_pix.nrdconta, 
           autoatendimento_pix.cdcooper, 
           autoatendimento_pix.tipo, 
           autoatendimento_pix.dtmvtolt datalancamento, 
           NVL(SUM(autoatendimento_pix.qtd), 0) quantidade_autoatendimento_ano
    FROM
    (--OBTEM LANÇAMENTOS DE CREDITO, DEBITO E DEVOLUÇÕES DE ESTORNO PIX
     SELECT craplcm.nrdconta, craplcm.cdcooper, 24 tipo, craplcm.dtmvtolt, COUNT(craplcm.nrdconta) qtd
       FROM craplcm
            INNER JOIN crapcop on (crapcop.cdcooper = craplcm.cdcooper)
      WHERE craplcm.cdhistor IN (3318, 3320, 3371, 3373, 3450, 3671, 3677, 3675, 3396, 3397, 3437, 3438, 3468)
        AND craplcm.dtmvtolt BETWEEN pr_dataini AND pr_datafim
        AND craplcm.cdcooper IN (7)
        AND crapcop.flgativo = 1 
        AND crapcop.cdcooper <> 3
      GROUP BY craplcm.nrdconta, craplcm.cdcooper, craplcm.dtmvtolt
      UNION --OBTEM LANÇAMENTOS DE ESTORNO PIX
     SELECT craplcm.nrdconta, craplcm.cdcooper, 25 tipo, craplcm.dtmvtolt, COUNT(craplcm.nrdconta) qtd
       FROM craplcm
            INNER JOIN crapcop on (crapcop.cdcooper = craplcm.cdcooper)
      WHERE craplcm.cdhistor IN (3319, 3321, 3322, 3323, 3377, 3375, 3379, 3380, 3451, 3452, 3453, 3673, 3681, 3684, 3683, 3679, 3435, 3436, 3469, 3470)
        AND craplcm.dtmvtolt BETWEEN pr_dataini AND pr_datafim
        AND craplcm.cdcooper IN (7)
        AND crapcop.flgativo = 1 
        AND crapcop.cdcooper <> 3
      GROUP BY craplcm.nrdconta, craplcm.cdcooper, craplcm.dtmvtolt
    ) autoatendimento_pix
    GROUP BY autoatendimento_pix.nrdconta, autoatendimento_pix.cdcooper, autoatendimento_pix.tipo, autoatendimento_pix.dtmvtolt
    ORDER BY autoatendimento_pix.nrdconta ASC;
  
  vr_cdcritic PLS_INTEGER;
  vr_dscritic VARCHAR(250);
  
BEGIN

  delete from tbcc_operacoes_diarias
  where cdoperacao in (24, 25);
  
  FOR rw_autoAtendimentoPix IN cr_obterAutoAtendimentoPix('01/01/2021', '31/12/2021') LOOP
  BEGIN
    INSERT INTO tbcc_operacoes_diarias(cdcooper, nrdconta, cdoperacao, dtoperacao, nrsequen, flgisencao_tarifa)
    VALUES(rw_autoAtendimentoPix.cdcooper,
           rw_autoAtendimentoPix.nrdconta,
           rw_autoAtendimentoPix.tipo,
           rw_autoAtendimentoPix.datalancamento,
           rw_autoAtendimentoPix.quantidade_autoatendimento_ano,
           0);
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 1034;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                 'TBCC_OPERACOES_DIARIAS(1):' ||
                 ' cdcooper:'  || rw_autoAtendimentoPix.cdcooper ||
                 ', nrdconta:' || rw_autoAtendimentoPix.nrdconta ||
                 ', tipo:'     || rw_autoAtendimentoPix.tipo ||
                 ', dtoperac:' || rw_autoAtendimentoPix.datalancamento ||
                 ', nrsequen:' || rw_autoAtendimentoPix.quantidade_autoatendimento_ano ||
                 ', flgisenc:' || '0' ||
                 '. ' || SQLERRM;
        RAISE;
    END;
  END LOOP;

  COMMIT;
  
  EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
END;