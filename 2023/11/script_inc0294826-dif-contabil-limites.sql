DECLARE
  vr_conta       cecred.GENE0002.typ_split;
  vr_reg_conta   cecred.GENE0002.typ_split;
  vr_cdcooper    crapcop.cdcooper%TYPE;
  vr_cdhistor    craphis.cdhistor%TYPE;
  vr_progress    crapass.progress_recid%TYPE;
  vr_nrborder    crapbdt.nrborder%TYPE;
  vr_vllanmto    tbdsct_lancamento_bordero.vllanmto%TYPE;
  vr_dscritic    crapcri.dscritic%TYPE;
  vr_excerro     EXCEPTION;
  rw_crapdat     datasCooperativa;
  
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
  vr_conta := cecred.GENE0002.fn_quebra_string(pr_string  =>'1;1594631;2811;1492862;970,30|' ||
                                                            '1;198803;2811;1260794;21,03|' ||
                                                            '1;96278;2811;1236253;1,47|' ||
                                                            '1;1323082;2811;1160169;37,90|' ||
                                                            '1;1357794;2811;1190968;35,82|' ||
                                                            '1;1388280;2811;1191683;7,42|' ||
                                                            '1;336603;2811;1542049;41,09|' ||
                                                            '1;800348;2811;1565065;12,46|' ||
                                                            '1;198803;2811;1224180;19,15|' ||
                                                            '1;1285962;2811;1223640;1,17|' ||
                                                            '1;1141667;2811;1244023;10,00|' ||
                                                            '1;1323082;2811;1195717;17,73|' 
                                                ,pr_delimit => '|');
                                                
  IF vr_conta.COUNT > 0 THEN
    FOR vr_idx_lst IN 1 .. vr_conta.COUNT - 1 LOOP
      vr_reg_conta := cecred.GENE0002.fn_quebra_string(pr_string  => vr_conta(vr_idx_lst),
                                                       pr_delimit => ';');
    
      vr_cdcooper := vr_reg_conta(1);
      vr_progress := vr_reg_conta(2);
      vr_cdhistor := vr_reg_conta(3);
      vr_nrborder := vr_reg_conta(4);
      vr_vllanmto := cecred.GENE0002.fn_char_para_number(pr_dsnumtex => vr_reg_conta(5));
      rw_crapdat  := datasCooperativa(pr_cdcooper => vr_cdcooper);
    
      OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                     ,pr_nrborder => vr_nrborder
                     ,pr_progress => vr_progress);
      FETCH cr_crapass
        INTO rw_crapass;
      IF cr_crapass%FOUND THEN
        dbms_output.put_line('Conta: ' || rw_crapass.nrdconta || ' - valor: ' || vr_vllanmto);
        
        DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => vr_cdcooper
                                              ,pr_nrdconta => rw_crapass.nrdconta
                                              ,pr_nrborder => vr_nrborder
                                              ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                              ,pr_cdorigem => 5
                                              ,pr_cdhistor => vr_cdhistor
                                              ,pr_vllanmto => vr_vllanmto
                                              ,pr_dscritic => vr_dscritic );
        IF TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_excerro;
        END IF;
        
      ELSE
        dbms_output.put_line('Conta nao encontrada - Progress_RECID: ' || vr_progress);
      END IF;
      
      CLOSE cr_crapass;   
      COMMIT;
    END LOOP;
  END IF; 

EXCEPTION
   WHEN vr_excerro THEN
    dbms_output.put_line('Erro Geral no Script. Erro: ' || vr_dscritic);
    ROLLBACK;
    dbms_output.put_line('Efetuado Rollback.');
    Raise_Application_Error(-20002, 'Erro Geral no Script. Erro: ' || vr_dscritic);
  WHEN OTHERS THEN
    ROLLBACK;
END;
