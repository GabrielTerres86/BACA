DECLARE
   vr_aux_ambiente    INTEGER       := 3;             
   vr_aux_diretor     VARCHAR2(100) := 'RITM0420417';     
   vr_aux_arquivo     VARCHAR2(100) := 'registros';
   vr_aux_cdcooper    NUMBER := 9; 
   vr_handle          UTL_FILE.FILE_TYPE; 
   vr_handle_log      UTL_FILE.FILE_TYPE;
   vr_handle_regs     UTL_FILE.FILE_TYPE;
   vr_nmarq_regs      VARCHAR2(200);
   vr_nmarq_log       VARCHAR2(200);
   vr_nmarq_rollback  VARCHAR2(200);
   rw_crapdat         BTCH0001.cr_crapdat%ROWTYPE;
   vr_des_erro        VARCHAR2(10000); 
   vr_tab_erro        GENE0001.typ_tab_erro;
   vr_des_linha       VARCHAR2(3000);  
   vr_vet_campos      GENE0002.typ_split; 
   vr_nrcontad        PLS_INTEGER := 0;  
   vr_aux_nrctrlim    NUMBER;
   vr_aux_nrdconta    NUMBER;
   vr_cont_commit     NUMBER(6) := 0;
   vr_cdcritic        crapcri.cdcritic%TYPE;
   vr_dscritic        crapcri.dscritic%TYPE;
   vr_exc_erro        EXCEPTION;
   vr_conta_ambiente  NUMBER;
   vr_tpctrlim        craplim.tpctrlim%TYPE := 1;
   vr_cdoperad        craplim.cdopecan%TYPE := 1;
   vr_cdagenci        crawlim.cdagenci%TYPE := 0;
   vr_idorigem        NUMBER := 5;
   vr_inusatab        BOOLEAN := FALSE;
   vr_nrdcaixa        NUMBER := 0;
   vr_rowid_log       ROWID;
     
   TYPE typ_reg_carga IS RECORD(cdcooper  craplim.cdcooper%TYPE
                               ,nrdconta  craplim.nrdconta%TYPE
                               ,nrctrlim  craplim.nrctrlim%TYPE);
  TYPE typ_tab_carga IS TABLE OF typ_reg_carga INDEX BY PLS_INTEGER;
  vr_tab_carga typ_tab_carga;
  
  CURSOR cr_conta_ambiente(pr_cdcooper IN craplim.cdcooper%TYPE
                          ,pr_nrctrlim IN craplim.nrctrlim%TYPE) IS
    SELECT lim.nrdconta
      FROM cecred.craplim lim
     WHERE lim.cdcooper = pr_cdcooper
       AND lim.nrctrlim = pr_nrctrlim
       AND lim.tpctrlim = 1;
  rw_conta_ambiente cr_conta_ambiente%ROWTYPE;
  
  PROCEDURE pc_cancelar_limite_cred(pr_cdcooper IN crapcop.cdcooper%TYPE                
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE  
                                   ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  
                                   ,pr_nrctrlim IN craplim.nrctrlim%TYPE   
                                   ,pr_cdcritic OUT PLS_INTEGER           
                                   ,pr_dscritic OUT VARCHAR2) IS          
  BEGIN

  DECLARE
    vr_cdcritic  crapcri.cdcritic%TYPE;
    vr_dscritic  crapcri.dscritic%TYPE;
    vr_nrdrowid  rowid;
    vr_exc_saida EXCEPTION;

    CURSOR cr_crawlim(pr_cdcooper IN craplim.cdcooper%TYPE
                     ,pr_nrdconta IN craplim.nrdconta%TYPE
                     ,pr_nrctrlim IN craplim.nrctrlim%TYPE
                     ,pr_tpctrlim IN craplim.tpctrlim%TYPE) IS
      SELECT lim.insitlim
            ,lim.insitest
            ,lim.cdcooper
            ,lim.nrdconta
            ,lim.nrctrlim
            ,lim.tpctrlim
        FROM CECRED.crawlim lim
       WHERE lim.cdcooper = pr_cdcooper
         AND lim.nrdconta = pr_nrdconta
         AND lim.nrctrlim = pr_nrctrlim
         AND lim.tpctrlim = pr_tpctrlim;
    rw_crawlim cr_crawlim%ROWTYPE;

    CURSOR cr_craplim(pr_cdcooper IN craplim.cdcooper%TYPE
                     ,pr_nrdconta IN craplim.nrdconta%TYPE
                     ,pr_nrctrlim IN craplim.nrctrlim%TYPE
                     ,pr_tpctrlim IN craplim.tpctrlim%TYPE) IS  
      SELECT lim.insitlim
            ,lim.idcobope
            ,lim.cdcooper
            ,lim.nrdconta
            ,lim.nrctrlim
            ,lim.tpctrlim
            ,lim.inbaslim
            ,lim.dtcancel
            ,lim.cdopeexc
            ,lim.cdageexc
            ,lim.dtinsexc
            ,lim.cdopecan    
        FROM CECRED.craplim lim
       WHERE lim.cdcooper = pr_cdcooper
         AND lim.nrdconta = pr_nrdconta
         AND lim.nrctrlim = pr_nrctrlim
         AND lim.tpctrlim = pr_tpctrlim;
    rw_craplim cr_craplim%ROWTYPE;
    
    CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE,
                       pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT inpessoa,
             nrdctitg,
             flgctitg,
             nrcpfcnpj_base,
             cdagenci,
             vllimcre,
             dtultlcr
        FROM cecred.crapass
       WHERE crapass.cdcooper = pr_cdcooper 
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
       
    CURSOR cr_crapsda (pr_cdcooper IN crapass.cdcooper%TYPE,
                       pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT 1
        FROM cecred.crapsda a
       WHERE a.cdcooper = pr_cdcooper
         AND a.nrdconta = pr_nrdconta
         AND a.vllimutl = 0 
         AND ROWNUM = 1
    ORDER BY a.dtmvtolt DESC;
    rw_crapsda cr_crapsda%ROWTYPE;

  BEGIN
    
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;

    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_dscritic := 'Associado nao cadastrado. Conta: ' || pr_nrdconta;
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_crapass;
    END IF;
    
    OPEN cr_craplim(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta,
                    pr_nrctrlim => pr_nrctrlim,
                    pr_tpctrlim => vr_tpctrlim);
    FETCH cr_craplim INTO rw_craplim;

    IF cr_craplim%NOTFOUND THEN
      CLOSE cr_craplim;
      vr_dscritic := 'Cooperado nao possui limite de credito. Conta: ' || pr_nrdconta;
      RAISE vr_exc_saida;
    ELSE
      IF rw_craplim.insitlim <> 2 THEN
         vr_dscritic := 'Contrato de limite de credito nao esta ATIVO. Conta: ' || pr_nrdconta;
         RAISE vr_exc_erro;
      END IF;
      CLOSE cr_craplim;
    END IF;
    
    OPEN cr_crapsda(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);
    FETCH cr_crapsda INTO rw_crapsda;

    IF cr_crapsda%NOTFOUND THEN
       CLOSE cr_crapsda;
       vr_dscritic := 'Cancelamento não permitido, cooperado entraria em ADP. Conta: ' || pr_nrdconta;
       RAISE vr_exc_saida;
    ELSE
      CLOSE cr_crapsda;
    END IF;
           
    BEGIN
      UPDATE CECRED.craplim lim
         SET lim.insitlim = 3
            ,lim.dtcancel = pr_dtmvtolt
            ,lim.cdopeexc = vr_cdoperad
            ,lim.cdageexc = vr_cdagenci
            ,lim.dtinsexc = trunc(SYSDATE)
            ,lim.cdopecan = vr_cdoperad
       WHERE lim.cdcooper = pr_cdcooper
         AND lim.nrdconta = pr_nrdconta
         AND lim.nrctrlim = pr_nrctrlim
         AND lim.tpctrlim = vr_tpctrlim;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao cancelar o contrato de limite de credito. ' || SQLERRM;
        RAISE vr_exc_erro;
    END;
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                  ,pr_des_text => 'UPDATE cecred.craplim lim '    ||
                                                  '   SET lim.insitlim = ' || rw_craplim.insitlim ||
                                                  '      ,lim.dtcancel = ' || rw_craplim.dtcancel ||
                                                  '      ,lim.cdopeexc = ' || rw_craplim.cdopeexc ||
                                                  '      ,lim.cdageexc = ' || rw_craplim.cdageexc ||
                                                  '      ,lim.dtinsexc = ' || rw_craplim.dtinsexc ||
                                                  '      ,lim.cdopecan = ' || rw_craplim.cdopecan ||
                                                  ' WHERE lim.cdcooper = ' || rw_craplim.cdcooper ||
                                                  '   AND lim.nrdconta = ' || rw_craplim.nrdconta ||
                                                  '   AND lim.nrctrlim = ' || rw_craplim.nrctrlim ||
                                                  '   AND lim.tpctrlim = ' || vr_tpctrlim ||
                                                  ';');
    

    BLOQ0001.pc_bloq_desbloq_cob_operacao(pr_nmdatela         => 'ATENDA',
                                          pr_idcobertura      => rw_craplim.idcobope,
                                          pr_inbloq_desbloq   => 'D',
                                          pr_cdoperador       => vr_cdoperad,
                                          pr_flgerar_log      => 'S',
                                          pr_atualizar_rating => 0,
                                          pr_dscritic         => vr_dscritic);

    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
 

    BEGIN
      UPDATE CECRED.crawlim lim
         SET lim.insitlim = 3
            ,lim.dtcancel = pr_dtmvtolt
            ,lim.cdopeexc = vr_cdoperad
            ,lim.cdageexc = vr_cdagenci
            ,lim.dtinsexc = trunc(SYSDATE)
            ,lim.cdopecan = vr_cdoperad
       WHERE lim.cdcooper = pr_cdcooper
         AND lim.nrdconta = pr_nrdconta
         AND lim.nrctrlim = pr_nrctrlim
         AND lim.tpctrlim = vr_tpctrlim;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao cancelar a proposta de limite de credito.' || SQLERRM;
        RAISE vr_exc_erro;
    END;
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                  ,pr_des_text => 'UPDATE cecred.crawlim lim '    ||
                                                  '   SET lim.insitlim = ' || rw_craplim.insitlim ||
                                                  '      ,lim.dtcancel = ' || rw_craplim.dtcancel ||
                                                  '      ,lim.cdopeexc = ' || rw_craplim.cdopeexc ||
                                                  '      ,lim.cdageexc = ' || rw_craplim.cdageexc ||
                                                  '      ,lim.dtinsexc = ' || rw_craplim.dtinsexc ||
                                                  '      ,lim.cdopecan = ' || rw_craplim.cdopecan ||
                                                  ' WHERE lim.cdcooper = ' || rw_craplim.cdcooper ||
                                                  '   AND lim.nrdconta = ' || rw_craplim.nrdconta ||
                                                  '   AND lim.nrctrlim = ' || rw_craplim.nrctrlim ||
                                                  '   AND lim.tpctrlim = ' || vr_tpctrlim ||
                                                  ';');

                                                  
    CREDITO.incluirHistoricoLimite(pr_cdcooper => pr_cdcooper,
                                   pr_nrdconta => pr_nrdconta,
                                   pr_nrctrlim => pr_nrctrlim,
                                   pr_tpctrlim => vr_tpctrlim,
                                   pr_dsmotivo => 'CANCELAMENTO',
                                   pr_cdcritic => vr_cdcritic,
                                   pr_dscritic => vr_dscritic);
    IF NVL(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    
    BEGIN
      UPDATE CECRED.crapass ass
         SET ass.vllimcre = 0
            ,ass.dtultlcr = pr_dtmvtolt
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar crapass. ' || SQLERRM;
        RAISE vr_exc_erro;
    END;
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                  ,pr_des_text => 'UPDATE cecred.crapass ass '    ||
                                                  '   SET ass.vllimcre = ' || rw_crapass.vllimcre ||
                                                  ' WHERE ass.cdcooper = ' || pr_cdcooper ||
                                                  '   AND ass.nrdconta = ' || pr_nrdconta ||
                                                  ';');   
    
                                               
    SISTEMA.geraLog(pr_cdcooper => pr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscritic => '',
                    pr_dsorigem => canalEntrada(5).dscanal,
                    pr_dstransa => 'Cancelamento de limite de credito',
                    pr_dttransa => trunc(SYSDATE),
                    pr_flgtrans => 1,
                    pr_hrtransa => buscarTime,
                    pr_idseqttl => 1,
                    pr_nmdatela => 'ATENDA',
                    pr_nrdconta => pr_nrdconta,
                    pr_nrdrowid => vr_rowid_log);
    
    SISTEMA.geraLogItem(pr_nrdrowid => vr_rowid_log,
                        pr_nmdcampo => 'nrctrlim',
                        pr_dsdadant => '',
                        pr_dsdadatu => pr_nrctrlim);
              
  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral pc_cancelar_limite_cred: '|| SQLERRM;
    END;

  END pc_cancelar_limite_cred;
   

BEGIN
    IF vr_aux_ambiente = 1 THEN 
      vr_nmarq_regs     := '/progress/t0032597/micros/script_renovacao/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'.csv';  
      vr_nmarq_log      := '/progress/t0032597/micros/script_renovacao/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_LOG.txt';      
      vr_nmarq_rollback := '/progress/t0032597/micros/script_renovacao/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_ROLLBACK.sql';       
    ELSIF vr_aux_ambiente = 2 THEN   
      vr_nmarq_regs     := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/evandro/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'.csv';     
      vr_nmarq_log      := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/evandro/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_LOG.txt';     
      vr_nmarq_rollback := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/evandro/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_ROLLBACK.sql'; 
    ELSIF vr_aux_ambiente = 3 THEN 
      vr_nmarq_regs     := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/fabricio/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'.csv';
      vr_nmarq_log      := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/fabricio/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_LOG.txt';      
      vr_nmarq_rollback := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/fabricio/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_ROLLBACK.sql'; 
    ELSE
      vr_dscritic := 'Erro ao apontar ambiente de execucao.';
      RAISE vr_exc_erro;
    END IF;

    gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nmarq_log
                            ,pr_tipabert => 'W'              
                            ,pr_utlfileh => vr_handle_log   
                            ,pr_des_erro => vr_des_erro);
    if vr_des_erro is not null then
      vr_dscritic := 'Erro ao abrir arquivo de LOG: ' || vr_des_erro;
      RAISE vr_exc_erro;
    end if;
    
    gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nmarq_regs
                            ,pr_tipabert => 'R'
                            ,pr_utlfileh => vr_handle_regs
                            ,pr_des_erro => vr_dscritic);                                                                       
      IF vr_dscritic IS NOT NULL THEN 
         vr_dscritic := 'Erro ao abrir o arquivo para leitura: '||vr_nmarq_regs || ' - ' || vr_dscritic;
         RAISE vr_exc_erro;
      END IF;

    gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nmarq_rollback
                            ,pr_tipabert => 'W'              
                            ,pr_utlfileh => vr_handle   
                            ,pr_des_erro => vr_des_erro);
    if vr_des_erro is not null then
      vr_dscritic := 'Erro ao abrir arquivo de ROLLBACK: ' || vr_des_erro;
      RAISE vr_exc_erro;
    end if; 
      
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                  ,pr_des_text => 'Inicio da execucao - ' ||  to_char(SYSDATE, 'HH24:MI:SS') || chr(10) || 'Cooperativa;Conta;Contrato;Erro');
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                  ,pr_des_text => 'BEGIN');                                                                  

  
    LOOP 
      BEGIN
        gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_handle_regs 
                                    ,pr_des_text => vr_des_linha); 
      
        vr_nrcontad := vr_nrcontad + 1; 
          
        vr_des_linha := REPLACE(REPLACE(vr_des_linha,chr(13),''),chr(10),''); 

        vr_vet_campos := gene0002.fn_quebra_string(TRIM(vr_des_linha),';'); 

        BEGIN   
           vr_aux_nrdconta := TO_NUMBER(vr_vet_campos(1));
           vr_aux_nrctrlim := TO_NUMBER(vr_vet_campos(2));
        EXCEPTION
          WHEN OTHERS THEN
            gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                          ,pr_des_text => 'Erro na leitura da linha: ' || vr_nrcontad || ' => ' || SQLERRM);
              
          CONTINUE;
        END;             

        vr_tab_carga(vr_nrcontad).cdcooper := vr_aux_cdcooper;
        vr_tab_carga(vr_nrcontad).nrdconta := vr_aux_nrdconta;
        vr_tab_carga(vr_nrcontad).nrctrlim := vr_aux_nrctrlim;

      EXCEPTION
        WHEN no_data_found THEN
          EXIT;
        WHEN vr_exc_erro THEN
          RAISE vr_exc_erro;
        WHEN OTHERS THEN
          vr_dscritic := 'Erro na leitura da linha '||vr_nrcontad||' => '||SQLERRM;
          RAISE vr_exc_erro;
      END;
    END LOOP;


    FOR vr_idx1 IN vr_tab_carga.first .. vr_tab_carga.last LOOP
        IF vr_tab_carga.exists(vr_idx1) THEN
         
         vr_conta_ambiente := '';   
         vr_cont_commit  := vr_cont_commit + 1;
              
         OPEN BTCH0001.cr_crapdat(pr_cdcooper =>  vr_tab_carga(vr_idx1).cdcooper);
         FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
         CLOSE BTCH0001.cr_crapdat;

           
         IF vr_aux_ambiente = 3 THEN 
            vr_conta_ambiente := vr_tab_carga(vr_idx1).nrdconta;
         ELSE  
             OPEN cr_conta_ambiente (pr_cdcooper => vr_tab_carga(vr_idx1).cdcooper
                                    ,pr_nrctrlim => vr_tab_carga(vr_idx1).nrctrlim);
             FETCH cr_conta_ambiente INTO rw_conta_ambiente;
             IF cr_conta_ambiente%NOTFOUND THEN
                CLOSE cr_conta_ambiente;
                gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                              ,pr_des_text => 'Contrato nao encontrado: ' || vr_tab_carga(vr_idx1).nrctrlim);
                CONTINUE;
             END IF;
             CLOSE cr_conta_ambiente;
                 
             vr_conta_ambiente := rw_conta_ambiente.nrdconta;
         END IF;
         

         pc_cancelar_limite_cred(pr_cdcooper => vr_tab_carga(vr_idx1).cdcooper
                                ,pr_nrdconta => vr_conta_ambiente
                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                ,pr_nrctrlim => vr_tab_carga(vr_idx1).nrctrlim
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);
         IF vr_dscritic IS NOT NULL THEN
            gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                          ,pr_des_text => vr_tab_carga(vr_idx1).cdcooper || ';' || 
                                                          vr_conta_ambiente || ';' || 
                                                          vr_tab_carga(vr_idx1).nrctrlim || ';' || 
                                                          vr_dscritic);                                                                     
         END IF;
                         
         IF vr_cont_commit = 50 THEN
            vr_cont_commit := 0;
            COMMIT;
         END IF;

        END IF;
    END LOOP;

    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                  ,pr_des_text => 'Fim da execucao - ' ||  to_char(SYSDATE, 'HH24:MI:SS'));
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                  ,pr_des_text => 'EXCEPTION' || chr(10) || 'WHEN OTHERS THEN' || chr(10) || 'ROLLBACK;' || chr(10) || 'END;');                                                                                                                        
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle);          
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log);             

    COMMIT;
EXCEPTION  
  WHEN vr_exc_erro THEN
    dbms_output.put_line('Erro arquivos: ' || vr_dscritic);
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                  ,pr_des_text => 'Erro arquivos: ' || vr_dscritic || ' SQLERRM: ' || SQLERRM);      
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log);
    ROLLBACK;  
  WHEN OTHERS THEN
    dbms_output.put_line('Erro geral: ' || ' SQLERRM: ' || SQLERRM);
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                  ,pr_des_text => 'Erro geral: ' || ' SQLERRM: ' || SQLERRM);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log);
    ROLLBACK;
END;
