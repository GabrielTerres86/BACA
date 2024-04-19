DECLARE
   vr_aux_ambiente    INTEGER       := 3;             
   vr_aux_diretor     VARCHAR2(100) := 'RITM0379357';     
   vr_aux_arquivo     VARCHAR2(100) := 'registros';
   vr_aux_cdcooper    NUMBER := 8; 
   vr_handle          UTL_FILE.FILE_TYPE; 
   vr_handle_log      UTL_FILE.FILE_TYPE;
   vr_handle_regs     UTL_FILE.FILE_TYPE;
   vr_nmarq_regs      VARCHAR2(200);
   vr_nmarq_log       VARCHAR2(200);
   vr_nmarq_rollback  VARCHAR2(200);
   rw_crapdat         BTCH0001.cr_crapdat%ROWTYPE;
   vr_des_erro        VARCHAR2(10000); 
   vr_des_linha       VARCHAR2(3000);  
   vr_vet_campos      GENE0002.typ_split; 
   vr_nrcontad        PLS_INTEGER := 0;  
   vr_aux_cddlinha    NUMBER;
   vr_aux_nrctrlim    NUMBER;
   vr_aux_nrdconta    NUMBER;
   vr_cont_commit     NUMBER(6) := 0;
   vr_cdcritic        crapcri.cdcritic%TYPE;
   vr_dscritic        crapcri.dscritic%TYPE;
   vr_exc_erro        EXCEPTION;
   vr_conta_ambiente  NUMBER;  
     
   TYPE typ_reg_carga IS RECORD(cdcooper  craplim.cdcooper%TYPE
                               ,nrdconta  craplim.nrdconta%TYPE
                               ,nrctrlim  craplim.nrctrlim%TYPE
                               ,cddlinha  craplim.cddlinha%TYPE);
  TYPE typ_tab_carga IS TABLE OF typ_reg_carga INDEX BY PLS_INTEGER;
  vr_tab_carga typ_tab_carga;
  
  CURSOR cr_conta_ambiente(pr_cdcooper IN craplim.cdcooper%TYPE
                          ,pr_nrctrlim IN craplim.nrctrlim%TYPE) IS
    SELECT lim.nrdconta,
           lim.cddlinha
      FROM cecred.craplim lim
     WHERE lim.cdcooper = pr_cdcooper
       AND lim.nrctrlim = pr_nrctrlim
       AND lim.tpctrlim = 1;
  rw_conta_ambiente cr_conta_ambiente%ROWTYPE;
  
  PROCEDURE pc_renovar_limite_cred_manual(pr_cdcooper IN crapcop.cdcooper%TYPE                
                                         ,pr_nrdconta IN crapass.nrdconta%TYPE  
                                         ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  
                                         ,pr_nrctrlim IN craplim.nrctrlim%TYPE  
                                         ,pr_cddlinha IN craplim.cddlinha%TYPE  
                                         ,pr_cdcritic OUT PLS_INTEGER           
                                         ,pr_dscritic OUT VARCHAR2) IS          
  BEGIN

  DECLARE
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    vr_nrdrowid rowid;
    vr_exc_saida EXCEPTION;

    CURSOR cr_craplim(pr_cdcooper IN craplim.cdcooper%TYPE    
                     ,pr_nrdconta IN craplim.nrdconta%TYPE    
                     ,pr_nrctrlim IN craplim.nrctrlim%TYPE) IS 
      SELECT craplim.cddlinha,
             craplim.insitlim,
             craplim.cdcooper,
             craplim.nrctrlim,
             craplim.nrdconta,     
             craplim.cdoperad                         
        FROM cecred.craplim
       WHERE craplim.cdcooper = pr_cdcooper
         AND craplim.nrdconta = pr_nrdconta
         AND craplim.nrctrlim = pr_nrctrlim
         AND craplim.tpctrlim = 1
         AND craplim.insitlim = 2;
    rw_craplim cr_craplim%ROWTYPE;

    CURSOR cr_craplrt (pr_cdcooper IN craplrt.cdcooper%TYPE,
                       pr_cddlinha IN craplrt.cddlinha%TYPE) IS
      SELECT craplrt.flgstlcr
        FROM cecred.craplrt
       WHERE craplrt.cdcooper = pr_cdcooper AND
             craplrt.cddlinha = pr_cddlinha;
    rw_craplrt cr_craplrt%ROWTYPE;


    CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE,
                       pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT inpessoa,
             nrdctitg,
             flgctitg,
             nrcpfcnpj_base,
             cdagenci
        FROM cecred.crapass
       WHERE crapass.cdcooper = pr_cdcooper AND
             crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

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
                    pr_nrctrlim => pr_nrctrlim);
    FETCH cr_craplim INTO rw_craplim;

    IF cr_craplim%NOTFOUND THEN
      CLOSE cr_craplim;
      vr_dscritic := 'Associado nao possui limite de credito ativo.';
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_craplim;
    END IF;

    OPEN cr_craplrt(pr_cdcooper => pr_cdcooper,
                    pr_cddlinha => pr_cddlinha);
    FETCH cr_craplrt INTO rw_craplrt;
    IF cr_craplrt%NOTFOUND THEN
      CLOSE cr_craplrt;
      vr_dscritic := 'Linha de Credito invalida. Linha: ' || pr_cddlinha;
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_craplrt;
    END IF;
 
    UPDATE cecred.craplim lim
       SET lim.cddlinha = pr_cddlinha
     WHERE lim.nrctrlim = rw_craplim.nrctrlim
       AND lim.nrdconta = rw_craplim.nrdconta
       AND lim.cdcooper = rw_craplim.cdcooper
       AND lim.tpctrlim = 1;
                        
    UPDATE cecred.crawlim lim
       SET lim.cddlinha = pr_cddlinha
     WHERE lim.nrctrlim = rw_craplim.nrctrlim
       AND lim.nrdconta = rw_craplim.nrdconta
       AND lim.cdcooper = rw_craplim.cdcooper
       AND lim.tpctrlim = 1;

    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                  ,pr_des_text => 'UPDATE cecred.craplim lim '    ||
                                                  '   SET lim.cddlinha = ' || rw_craplim.cddlinha ||
                                                  ' WHERE lim.cdcooper = ' || rw_craplim.cdcooper ||
                                                  '   AND lim.nrdconta = ' || rw_craplim.nrdconta ||
                                                  '   AND lim.nrctrlim = ' || rw_craplim.nrctrlim ||
                                                  '   AND lim.tpctrlim = 1'||
                                                  ';');

    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                  ,pr_des_text => 'UPDATE cecred.crawlim lim '    ||
                                                  '   SET lim.cddlinha = ' || rw_craplim.cddlinha ||
                                                  ' WHERE lim.cdcooper = ' || rw_craplim.cdcooper ||
                                                  '   AND lim.nrdconta = ' || rw_craplim.nrdconta ||
                                                  '   AND lim.nrctrlim = ' || rw_craplim.nrctrlim ||
                                                  '   AND lim.tpctrlim = 1'||
                                                  ';');
         
     gene0001.pc_gera_log(pr_cdcooper =>  rw_craplim.cdcooper
                         ,pr_cdoperad => '1'
                         ,pr_dscritic => ' '
                         ,pr_dsorigem => gene0001.vr_vet_des_origens(5)
                         ,pr_dstransa => 'Alteracao via script linha limite de credito - ' || vr_aux_diretor
                         ,pr_dttransa => TRUNC(SYSDATE)
                         ,pr_flgtrans => 1
                         ,pr_hrtransa => gene0002.fn_busca_time
                         ,pr_idseqttl => 1
                         ,pr_nmdatela => 'Script'
                         ,pr_nrdconta => rw_craplim.nrdconta
                         ,pr_nrdrowid => vr_nrdrowid);

     gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                               pr_nmdcampo => 'Linha',
                               pr_dsdadant => rw_craplim.cddlinha,
                               pr_dsdadatu => pr_cddlinha);    

  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral pc_renovar_limite_cred_manual: '|| SQLERRM;
    END;

  END pc_renovar_limite_cred_manual;
   

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
           vr_aux_cddlinha := TO_NUMBER(vr_vet_campos(3));
        EXCEPTION
          WHEN OTHERS THEN
            gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                          ,pr_des_text => 'Erro na leitura da linha: ' || vr_nrcontad || ' => ' || SQLERRM);
              
          CONTINUE;
        END;             

        vr_tab_carga(vr_nrcontad).cdcooper := vr_aux_cdcooper;
        vr_tab_carga(vr_nrcontad).nrdconta := vr_aux_nrdconta;
        vr_tab_carga(vr_nrcontad).nrctrlim := vr_aux_nrctrlim;
        vr_tab_carga(vr_nrcontad).cddlinha := vr_aux_cddlinha;

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

         pc_renovar_limite_cred_manual(pr_cdcooper => vr_tab_carga(vr_idx1).cdcooper
                                      ,pr_nrdconta => vr_conta_ambiente
                                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                      ,pr_nrctrlim => vr_tab_carga(vr_idx1).nrctrlim
                                      ,pr_cddlinha => vr_tab_carga(vr_idx1).cddlinha
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
