DECLARE
  vr_conta       cecred.GENE0002.typ_split;
  vr_reg_conta   cecred.GENE0002.typ_split;
  vr_cdcooper    crapcop.cdcooper%TYPE;
  vr_progress    crapass.progress_recid%TYPE;
  vr_nrborder    crapbdt.nrborder%TYPE;
  vr_vllanmto    tbdsct_lancamento_bordero.vllanmto%TYPE;
  vr_dscritic    crapcri.dscritic%TYPE;
  vr_cdcritic    crapcri.cdcritic%TYPE;
  rw_crapdat     btch0001.cr_crapdat%rowtype;
  vr_nrdrowid    ROWID;
  vr_nrdolote    craplot.nrdolote%TYPE;
  vr_incrineg    INTEGER;
  vr_tab_retorno LANC0001.typ_reg_retorno;
  
  CURSOR cr_crapass(pr_cdcooper IN cecred.crapass.cdcooper%TYPE,
                    pr_nrborder IN cecred.crapbdt.nrborder%TYPE
                   ,pr_progress IN cecred.crapass.progress_recid%TYPE) IS
    SELECT a.nrdconta
      FROM cecred.crapass a,
           cecred.crapbdt b
     WHERE a.cdcooper = b.cdcooper
       AND b.nrborder = pr_nrborder
       AND a.cdcooper = pr_cdcooper
       AND a.progress_recid = pr_progress;
  rw_crapass cr_crapass%ROWTYPE;
    
BEGIN 
  vr_conta := cecred.GENE0002.fn_quebra_string(pr_string  =>'2;867857;47971;672,71|' 
                                              ,pr_delimit => '|');
                                                
  IF vr_conta.COUNT > 0 THEN
    
    OPEN  btch0001.cr_crapdat(pr_cdcooper => 1);
    FETCH btch0001.cr_crapdat into rw_crapdat;
    CLOSE btch0001.cr_crapdat;
       
    FOR vr_idx_lst IN 1 .. vr_conta.COUNT - 1 LOOP
      vr_reg_conta := cecred.GENE0002.fn_quebra_string(pr_string  => vr_conta(vr_idx_lst),
                                                       pr_delimit => ';');
    
      vr_cdcooper := vr_reg_conta(1);
      vr_progress := vr_reg_conta(2);
      vr_nrborder := vr_reg_conta(3);
      vr_vllanmto := cecred.GENE0002.fn_char_para_number(pr_dsnumtex => vr_reg_conta(4));
    
      OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                     ,pr_nrborder => vr_nrborder
                     ,pr_progress => vr_progress);
      FETCH cr_crapass INTO rw_crapass;
      
      IF cr_crapass%FOUND THEN

        DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => vr_cdcooper
                                              ,pr_nrdconta => rw_crapass.nrdconta
                                              ,pr_nrborder => vr_nrborder
                                              ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                              ,pr_cdorigem => 5
                                              ,pr_cdhistor => 2671
                                              ,pr_vllanmto => vr_vllanmto
                                              ,pr_dscritic => vr_dscritic );
        IF TRIM(vr_dscritic) IS NOT NULL THEN
           gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                               ,pr_cdoperad => 1
                               ,pr_dscritic => vr_dscritic
                               ,pr_dsorigem => 5
                               ,pr_dstransa => 'Erro lancamento operacao: ' || vr_dscritic
                               ,pr_dttransa => rw_crapdat.dtmvtolt
                               ,pr_flgtrans => 0 
                               ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate,'SSSSS'))
                               ,pr_idseqttl => 1
                               ,pr_nmdatela => 'Script-INC0354048'
                               ,pr_nrdconta => rw_crapass.nrdconta
                               ,pr_nrdrowid => vr_nrdrowid);
        END IF;
 
        COMMIT;
             
      END IF;
      CLOSE cr_crapass;
      
    END LOOP;
  END IF; 

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    dbms_output.put_line('Efetuado Rollback.');
    Raise_Application_Error(-20002, 'Erro Geral no Script. Erro: ' || vr_dscritic);
END;
