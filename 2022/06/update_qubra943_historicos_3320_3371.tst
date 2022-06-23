PL/SQL Developer Test script 3.0
98
DECLARE 
  vr_exc_erro EXCEPTION;

  CURSOR cr_quebra IS
    SELECT * 
      FROM tbjur_qbr_sig_extrato qbr 
     WHERE nrseqlcm IN (987009763,998979582,1018416727,1053031082,1075915921,1075916534,1101506667,1233414794) 
       AND qbr.nrseq_quebra_sigilo = 943;
  rw_quebra cr_quebra%ROWTYPE;
  
  CURSOR cr_lancamento (pr_nrseqlcm IN tbjur_qbr_sig_extrato.nrseqlcm%TYPE) IS
    SELECT lcm.cdcooper
          ,lcm.nrdconta
          ,lcm.dtmvtolt
          ,lcm.vllanmto 
      FROM craplcm lcm
     WHERE lcm.progress_recid = pr_nrseqlcm;
  rw_lancamento cr_lancamento%ROWTYPE;
  
  CURSOR cr_lancamento_estorno (pr_cdcooper IN craplcm.cdcooper%TYPE
                               ,pr_nrdconta IN craplcm.nrdconta%TYPE
                               ,pr_dtmvtolt IN craplcm.dtmvtolt%TYPE
                               ,pr_vllanmto IN craplcm.vllanmto%TYPE) IS
    SELECT lcm.progress_recid 
      FROM craplcm lcm
     WHERE lcm.cdcooper = pr_cdcooper 
       AND lcm.nrdconta = pr_nrdconta 
       AND lcm.dtmvtolt = pr_dtmvtolt 
       AND lcm.vllanmto = pr_vllanmto
       AND lcm.cdpesqbb LIKE '%EST%';
  rw_lancamento_estorno cr_lancamento_estorno%ROWTYPE;
  
  CURSOR cr_pix (pr_nrseqlcm tbpix_transacao.IDREGISTRO_LCM%TYPE) IS
    SELECT idtipo_transacao     AS tipo_transacao,
           cdbccxlt_recebedor   AS banco_recebedor,
           nragencia_recebedor  AS agencia_recebedor,
           nrconta_recebedor    AS conta_recebedor,
           tpconta_recebedor    AS tipo_conta_recebedor,
           tppessoa_recebedor   AS tipo_pessoa_recebedor,
           nrcpf_cnpj_recebedor AS cpf_cnpj_recebedor,
           nome_recebedor
      FROM tbpix_transacao p
     WHERE idregistro_lcm = pr_nrseqlcm;
  rw_pix cr_pix%ROWTYPE;
                                                  
BEGIN
  FOR rw_quebra IN cr_quebra LOOP   
    OPEN cr_lancamento (pr_nrseqlcm => rw_quebra.nrseqlcm);
    FETCH cr_lancamento INTO rw_lancamento;
    IF cr_lancamento%FOUND THEN
      OPEN cr_lancamento_estorno (pr_cdcooper => rw_lancamento.cdcooper
                                 ,pr_nrdconta => rw_lancamento.nrdconta
                                 ,pr_dtmvtolt => rw_lancamento.dtmvtolt
                                 ,pr_vllanmto => rw_lancamento.vllanmto);
      FETCH cr_lancamento_estorno INTO rw_lancamento_estorno;
      IF cr_lancamento_estorno%FOUND THEN
        OPEN cr_pix (pr_nrseqlcm => rw_lancamento_estorno.progress_recid);
        FETCH cr_pix INTO rw_pix;
        IF cr_pix%FOUND THEN
          UPDATE tbjur_qbr_sig_extrato t
             SET t.cdbandep = rw_pix.banco_recebedor
                ,t.cdagedep = rw_pix.agencia_recebedor
                ,t.nrctadep = rw_pix.conta_recebedor
                ,t.tpdconta = rw_pix.tipo_conta_recebedor   
                ,t.inpessoa = rw_pix.tipo_pessoa_recebedor
                ,t.nrcpfcgc = rw_pix.cpf_cnpj_recebedor
                ,t.nmprimtl = rw_pix.nome_recebedor
                ,t.dsobserv = ''
                ,t.dsobsqbr = ''
                ,t.idsitqbr = 1
           WHERE t.nrseq_quebra_sigilo = 943
             AND t.nrseqlcm = rw_quebra.nrseqlcm;
        ELSE 
          CLOSE cr_pix;
          RAISE vr_exc_erro;
        END IF;      
      ELSE
        CLOSE cr_lancamento_estorno;
        RAISE vr_exc_erro;
      END IF;
    ELSE
      CLOSE cr_lancamento;
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_lancamento; 
    CLOSE cr_lancamento_estorno;
    CLOSE cr_pix; 
  END LOOP;
  
  COMMIT;
  
EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
  
  WHEN OTHERS THEN    
    ROLLBACK;  
END;
0
0
