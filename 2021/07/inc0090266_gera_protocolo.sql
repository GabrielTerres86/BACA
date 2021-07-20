DECLARE
  vr_dsprotoc  crappro.dsprotoc%TYPE; --> Descri��o protocolo
  vr_dscritic  VARCHAR2(5000);        --> Descri��o do erro
  vr_des_erro  VARCHAR2(3);           --> Retorno do processo "OK" / "NOK"

BEGIN
  GENE0006.pc_gera_protocolo(pr_cdcooper => 1,
                             pr_dtmvtolt => TO_DATE('08/03/2021', 'DD/MM/YYYY'),
                             pr_hrtransa => 44398,
                             pr_nrdconta => 10122133,
                             pr_nrdocmto => 4224239,
                             pr_nrseqaut => 0,
                             pr_vllanmto => 800,
                             pr_nrdcaixa => 996,
                             pr_gravapro => TRUE,
                             pr_cdtippro => 34,
                             pr_dsinfor1 => 'Pagamento PIX',
                             pr_dsinfor2 => '',
                             pr_dsinfor3 => '',
                             pr_dscedent => 'DEBITO PIX',
                             pr_flgagend => FALSE,
                             pr_nrcpfope => 0,
                             pr_nrcpfpre => 0,
                             pr_nmprepos => '',
                             pr_dsprotoc => vr_dsprotoc,
                             pr_dscritic => vr_dscritic,
                             pr_des_erro => vr_des_erro);

  IF vr_des_erro = 'NOK' THEN
    RETURN;
  END IF;

  BEGIN
    -- atualiza data da transa��o do protocolo, pois a rotina GENE0006.pc_gera_protocolo salva a data atual
    UPDATE crappro
       SET DTTRANSA = TO_DATE('08/03/2021 12:19:58', 'dd/mm/yyyy hh24:mi:ss')
     WHERE DSPROTOC = vr_dsprotoc
       AND CDCOOPER = 1
       AND NRDCONTA = 10122133
       and VLDOCMTO = 800
       AND NRDOCMTO = 4224239;   
  END;
  
  COMMIT;
END;