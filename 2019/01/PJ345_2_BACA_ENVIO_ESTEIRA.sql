DECLARE

  vr_exc_erro              EXCEPTION;
  vr_cdcritic              NUMBER;
  vr_dscritic              VARCHAR2(4000);
  --
  -- Propostas Solicitadas
  CURSOR cur_propostas_crd IS
    SELECT crw.rowid
      FROM crawcrd crw
     WHERE crw.insitcrd in (2,3,4) -- (2 - Solic., 3 - Liberada, 4 - Em uso)
       AND crw.insitdec = 3
       AND crw.flgprcrd = 1 -- considerar só titular
       AND crw.nrcctitg > 0 -- com conta cartao (efetivou no Bancoob)
       AND crw.cdadmcrd between 10 and 80; -- Cartão Cecred
   
  -- Solicitação de limite de credito
  CURSOR cur_alt_limite_crd IS
    SELECT tbla.rowid
      FROM tbcrd_limite_atualiza tbla
          ,crawcrd crcrd
     WHERE tbla.cdcooper   = crcrd.cdcooper
       AND tbla.nrdconta   = crcrd.nrdconta
       AND tbla.insitdec   = 3 -- Aprovado manual
       AND tbla.tpsituacao = 3
       AND crcrd.insitcrd  = 4
       AND crcrd.flgprcrd  = 1
       AND crcrd.nrcctitg  = tbla.nrconta_cartao
       AND crcrd.cdadmcrd  = tbla.cdadmcrd
       AND crcrd.nrctrcrd  = tbla.nrctrcrd --Novo
       AND NOT EXISTS (SELECT 1
                       FROM   tbgen_webservice_aciona tbwa
                       WHERE (tbwa.dsoperacao LIKE 'ENVIO%PROPOSTA%ESTEIRA%CREDITO' OR
                              tbwa.dsoperacao LIKE 'ENVIO%EFETIVACAO%PROPOSTA%ANALISE%CREDITO')
                       AND tbwa.cdcooper  = tbla.cdcooper
                       AND tbwa.nrdconta  = tbla.nrdconta
                       AND tbwa.nrctrprp  = crcrd.nrctrcrd
                       AND tbwa.tpproduto = 4)
       AND tbla.dtalteracao = (SELECT MAX(tbla1.dtalteracao)
                               FROM   tbcrd_limite_atualiza tbla1
                               WHERE  tbla1.cdcooper = tbla.cdcooper
                                   AND    tbla1.nrdconta = tbla.nrdconta
                                   AND    tbla1.nrctrcrd = tbla.nrctrcrd --Novo
                                   AND    tbla1.nrproposta_est = tbla.nrproposta_est); --Novo

 
BEGIN

  FOR r_propostas_crd IN cur_propostas_crd LOOP
    BEGIN
      UPDATE crawcrd wpr
         SET wpr.dtenvest = trunc(sysdate)
       WHERE wpr.rowid = r_propostas_crd.rowid;  
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Nao foi possivel atualizar proposta apos envio para Análise de Crédito: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
        
  END LOOP;
  
  commit;
  
  FOR r_alt_limite_crd IN cur_alt_limite_crd LOOP
    BEGIN
      UPDATE tbcrd_limite_atualiza tla
           SET dtenvest = trunc(sysdate)
         WHERE tla.rowid = r_alt_limite_crd.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Nao foi possivel atualizar proposta apos envio para Análise de Crédito: '||SQLERRM;
          RAISE vr_exc_erro;
      END;   
  END LOOP;

  commit;

EXCEPTION
  WHEN vr_exc_erro THEN
    null;
    dbms_output.put_line('ERRO: ' || to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_crps733 --> ' || vr_dscritic);
  WHEN OTHERS THEN
    null;
    dbms_output.put_line('ERRO: ' || to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_crps733 --> ' || SQLERRM);
END;
