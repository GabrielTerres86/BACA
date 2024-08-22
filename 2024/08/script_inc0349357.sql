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
  vr_excerro     EXCEPTION;
  
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
  vr_conta := cecred.GENE0002.fn_quebra_string(pr_string  =>'1;266646;1131728;1811,15|' ||
                                                            '1;266646;1106944;1329,74|' ||
                                                            '1;266646;1100293;442,30|' ||
                                                            '1;266646;1086701;1194,44|' ||
                                                            '1;266646;1074016;1633,68|' ||
                                                            '1;266646;1071341;422,05|' ||
                                                            '1;266646;1062348;698,28|' ||
                                                            '1;751545;1135289;50,45|' ||
                                                            '1;751545;1131674;287,99|' ||
                                                            '1;751545;1103296;1123,39|' ||
                                                            '1;751545;1088735;605,08|' ||
                                                            '1;751545;1086680;443,32|' ||
                                                            '1;751545;1072935;108,94|' ||
                                                            '1;751545;1070377;17,10|' ||
                                                            '1;751545;1066566;86,96|' ||
                                                            '1;751545;1063423;26,20|' ||
                                                            '1;751545;1052663;89,78|' ||
                                                            '1;751545;1036490;23,25|' ||
                                                            '1;751545;1033824;53,90|' ||
                                                            '1;751545;1030780;125,91|' ||
                                                            '1;751545;1029720;53,81|' ||
                                                            '1;751545;1027841;115,71|' ||
                                                            '1;751545;1023404;185,69|' ||
                                                            '1;751545;1022953;143,46|' ||
                                                            '1;751545;1003193;47,60|' 
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
      FETCH cr_crapass
        INTO rw_crapass;
      IF cr_crapass%FOUND THEN

        DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => vr_cdcooper
                                              ,pr_nrdconta => rw_crapass.nrdconta
                                              ,pr_nrborder => vr_nrborder
                                              ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                              ,pr_cdorigem => 5
                                              ,pr_cdhistor => 2811
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
                               ,pr_nmdatela => 'Script-INC0349357'
                               ,pr_nrdconta => rw_crapass.nrdconta
                               ,pr_nrdrowid => vr_nrdrowid);
        END IF;


      
      vr_nrdolote := fn_sequence(pr_nmtabela => 'CRAPLOT'
                                ,pr_nmdcampo => 'NRDOLOTE'
                                ,pr_dsdchave => TO_CHAR(vr_cdcooper)|| ';'
                                             || TO_CHAR(rw_crapdat.dtmvtolt, 'DD/MM/RRRR') || ';'
                                             || TO_CHAR('1')|| ';'
                                             || '100');
   
       LANC0001.pc_gerar_lancamento_conta(pr_cdcooper =>vr_cdcooper          
                                         ,pr_dtmvtolt =>rw_crapdat.dtmvtolt   
                                         ,pr_cdagenci =>1     
                                         ,pr_cdbccxlt =>100 
                                         ,pr_nrdolote =>vr_nrdolote   
                                         ,pr_nrdconta =>rw_crapass.nrdconta    
                                         ,pr_nrdctabb =>rw_crapass.nrdconta
                                         ,pr_nrdocmto =>vr_nrborder               
                                         ,pr_cdhistor =>2758
                                         ,pr_nrseqdig =>1
                                         ,pr_vllanmto =>vr_vllanmto
                                         ,pr_cdpesqbb => 'Desconto de Titulo do Bordero ' || vr_nrborder
                                         ,pr_tab_retorno => vr_tab_retorno
                                         ,pr_incrineg => vr_incrineg
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);

        IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
           gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                               ,pr_cdoperad => 1
                               ,pr_dscritic => vr_dscritic
                               ,pr_dsorigem => 5
                               ,pr_dstransa => 'Erro lancamento conta: ' || vr_dscritic
                               ,pr_dttransa => rw_crapdat.dtmvtolt
                               ,pr_flgtrans => 0 
                               ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate,'SSSSS'))
                               ,pr_idseqttl => 1
                               ,pr_nmdatela => 'Script-INC0349357'
                               ,pr_nrdconta => rw_crapass.nrdconta
                               ,pr_nrdrowid => vr_nrdrowid);
        END IF;
  
      CLOSE cr_crapass;   
      COMMIT;
             
      END IF;
      
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
