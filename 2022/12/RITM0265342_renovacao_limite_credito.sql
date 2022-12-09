DECLARE

   vr_aux_ambiente    INTEGER       := 3;             
   vr_aux_diretor     VARCHAR2(100) := 'RITM0265342';     
   vr_aux_arquivo     VARCHAR2(100) := 'registros'; 
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
   vr_idx_carga       PLS_INTEGER; 
   vr_aux_cdcooper    NUMBER;
   vr_aux_nrdconta    NUMBER;
   vr_aux_nrctrlim    NUMBER;
   vr_cont_commit     NUMBER(6) := 0;
   vr_cdcritic        crapcri.cdcritic%TYPE;
   vr_dscritic        crapcri.dscritic%TYPE;
   vr_exc_erro        EXCEPTION;    
   
   
   TYPE typ_reg_carga IS RECORD(cdcooper  craplim.cdcooper%TYPE
                              ,nrdconta  craplim.nrdconta%TYPE
                              ,nrctrlim  craplim.nrctrlim%TYPE);
  TYPE typ_tab_carga IS TABLE OF typ_reg_carga INDEX BY PLS_INTEGER;
  vr_tab_carga typ_tab_carga;

  
  PROCEDURE pc_renovar_limite_cred_manual(pr_cdcooper IN crapcop.cdcooper%TYPE  
                                         ,pr_cdoperad IN crapope.cdoperad%TYPE  
                                         ,pr_nmdatela IN craptel.nmdatela%TYPE 
                                         ,pr_idorigem IN INTEGER                
                                         ,pr_nrdconta IN crapass.nrdconta%TYPE  
                                         ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  
                                         ,pr_nrctrlim IN craplim.nrctrlim%TYPE  
                                         ,pr_cdcritic OUT PLS_INTEGER           
                                         ,pr_dscritic OUT VARCHAR2) IS          
  BEGIN

  DECLARE
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    vr_flgctitg crapalt.flgctitg%TYPE;
    vr_dsaltera LONG;
    vr_retorno  BOOLEAN DEFAULT(FALSE);
    vr_xml      xmltype;
    vr_nrdrowid rowid;
    vr_exc_saida EXCEPTION;
    vr_flg_Rating_Renovacao_Ativo NUMBER := 0;   
    vr_in_risco_rat INTEGER;
    vr_habrat       VARCHAR2(1) := 'N';
    vr_strating     NUMBER;
    vr_flgrating    NUMBER;
    vr_vlendivid    craplim.vllimite%TYPE; 
    vr_vllimrating  craplim.vllimite%TYPE;
    rw_crapdat      btch0001.rw_crapdat%TYPE;
    vr_innivris     NUMBER;

    CURSOR cr_craplim(pr_cdcooper IN craplim.cdcooper%TYPE    
                     ,pr_nrdconta IN craplim.nrdconta%TYPE    
                     ,pr_nrctrlim IN craplim.nrctrlim%TYPE) IS 
      SELECT craplim.cddlinha,
             craplim.insitlim,
             craplim.qtrenova,
             craplim.dtrenova,
             craplim.vllimite,
             nvl(craplim.dtfimvig, craplim.dtinivig + craplim.qtdiavig) as dtfimvig,      
             craplim.tprenova,
             craplim.dsnrenov,
             craplim.dtfimvig dtfimvig_rollback,
             craplim.cdoperad,
             craplim.cdopelib                         
        FROM craplim
       WHERE craplim.cdcooper = pr_cdcooper
         AND craplim.nrdconta = pr_nrdconta
         AND craplim.nrctrlim = pr_nrctrlim
         AND craplim.tpctrlim = 1
         AND craplim.insitlim = 2;
    rw_craplim cr_craplim%ROWTYPE;

    CURSOR cr_craplrt (pr_cdcooper IN craplrt.cdcooper%TYPE,
                       pr_cddlinha IN craplrt.cddlinha%TYPE) IS
      SELECT craplrt.flgstlcr
        FROM craplrt
       WHERE craplrt.cdcooper = pr_cdcooper AND
             craplrt.cddlinha = pr_cddlinha;
    rw_craplrt cr_craplrt%ROWTYPE;

    CURSOR cr_craprli (pr_cdcooper IN craprli.cdcooper%TYPE,
                       pr_inpessoa IN craprli.inpessoa%TYPE) IS
      SELECT qtmaxren
        FROM craprli
       WHERE craprli.cdcooper = pr_cdcooper AND
             craprli.inpessoa = DECODE(pr_inpessoa,3,2,pr_inpessoa)
             AND craprli.tplimite = 1; 
    rw_craprli cr_craprli%ROWTYPE;

    CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE,
                       pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT inpessoa,
             nrdctitg,
             flgctitg,
             nrcpfcnpj_base,
             cdagenci
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper AND
             crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    CURSOR cr_crapalt (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_nrdconta IN crapass.nrdconta%TYPE
                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
      SELECT crapalt.dsaltera,
             crapalt.rowid,
             crapalt.cdoperad,
             crapalt.flgctitg
        FROM crapalt
       WHERE crapalt.cdcooper = pr_cdcooper
         AND crapalt.nrdconta = pr_nrdconta
         AND crapalt.dtaltera = pr_dtmvtolt;
    rw_crapalt cr_crapalt%ROWTYPE;

    CURSOR cr_tbrisco_operacoes(pr_cdcooper IN craplim.cdcooper%TYPE    
                               ,pr_nrdconta IN craplim.nrdconta%TYPE    
                               ,pr_nrctrlim IN craplim.nrctrlim%TYPE) IS 
    SELECT 1 FROM tbrisco_operacoes o
                 WHERE o.cdcooper = pr_cdcooper
                   AND o.nrdconta = pr_nrdconta
                   AND o.nrctremp = pr_nrctrlim
                   AND o.tpctrato = 1
                   AND o.flintegrar_sas = 1;
    rw_tbrisco_operacoes cr_tbrisco_operacoes%ROWTYPE;

  BEGIN

    vr_flg_Rating_Renovacao_Ativo := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                              ,pr_cdcooper => 0
                                                              ,pr_cdacesso => 'RATING_RENOVACAO_ATIVO');

    vr_habrat := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                           pr_cdcooper => pr_cdcooper,
                                           pr_cdacesso => 'HABILITA_RATING_NOVO');

    OPEN cr_craplim(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta,
                    pr_nrctrlim => pr_nrctrlim);
    FETCH cr_craplim INTO rw_craplim;

    IF cr_craplim%NOTFOUND THEN
      CLOSE cr_craplim;
      vr_dscritic := 'Associado nao possui proposta de limite de credito Ativa. ';
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_craplim;
    END IF;

    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;

    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      CLOSE BTCH0001.cr_crapdat;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
      RAISE vr_exc_saida;
    ELSE
      CLOSE BTCH0001.cr_crapdat;
    END IF;

    IF nvl(rw_craplim.insitlim,0) <> 2 THEN
      vr_dscritic := 'O contrato de limite de credito deve estar ativo.';
      RAISE vr_exc_saida;
    END IF;

    OPEN cr_craplrt(pr_cdcooper => pr_cdcooper,
                    pr_cddlinha => rw_craplim.cddlinha);
    FETCH cr_craplrt INTO rw_craplrt;
    IF cr_craplrt%NOTFOUND THEN
      CLOSE cr_craplrt;
      vr_dscritic := 'Linha de Credito nao cadastrada. Linha: ' || rw_craplim.cddlinha;
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_craplrt;
    END IF;

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

    OPEN cr_craprli(pr_cdcooper => pr_cdcooper,
                    pr_inpessoa => rw_crapass.inpessoa);
    FETCH cr_craprli INTO rw_craprli;

    IF cr_craprli%NOTFOUND THEN
      CLOSE cr_craprli;
      vr_dscritic := 'Regras da Linha de Credito nao cadastrada.';
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_craprli;
    END IF;


    IF vr_habrat = 'S' THEN

      IF vr_flg_Rating_Renovacao_Ativo = 1 THEN

        RATI0003.pc_busca_status_rating(pr_cdcooper  => pr_cdcooper
                                       ,pr_nrdconta  => pr_nrdconta
                                       ,pr_tpctrato  => 1
                                       ,pr_nrctrato  => pr_nrctrlim
                                       ,pr_strating  => vr_strating
                                       ,pr_flgrating => vr_flgrating
                                       ,pr_cdcritic  => vr_cdcritic
                                       ,pr_dscritic  => vr_dscritic);

        IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          
           IF substr(vr_dscritic,1,47) = 'Contrato nao pode ser efetivado, Rating vencido' THEN

              OPEN cr_tbrisco_operacoes(pr_cdcooper => pr_cdcooper,
                                        pr_nrdconta => pr_nrdconta,
                                        pr_nrctrlim => pr_nrctrlim);
              FETCH cr_tbrisco_operacoes INTO rw_tbrisco_operacoes;
              
              IF cr_tbrisco_operacoes%NOTFOUND THEN
                BEGIN 
                  UPDATE tbrisco_operacoes o
                     SET o.flintegrar_sas = 1
                   WHERE o.cdcooper = pr_cdcooper
                     AND o.nrdconta = pr_nrdconta
                     AND o.nrctremp = pr_nrctrlim
                     AND o.tpctrato = 1;
                EXCEPTION
                  WHEN OTHERS THEN
                  vr_dscritic := 'Erro atualizar tabela tbrisco_operacoes, para rating vencido '||SQLERRM;
                  RAISE vr_exc_saida;
                END;
                                                
                vr_retorno := rati0003.fn_registra_historico(pr_cdcooper             => pr_cdcooper
                                                            ,pr_cdoperad             => pr_cdoperad
                                                            ,pr_nrdconta             => pr_nrdconta
                                                            ,pr_nrctro               => pr_nrctrlim
                                                            ,pr_dtmvtolt             => NULL
                                                            ,pr_valor                => 0
                                                            ,pr_tpctrato             => 1
                                                            ,pr_rating_sugerido      => NULL
                                                            ,pr_justificativa        => 'Renovacao Limite de credito em massa1'
                                                            ,pr_inrisco_rating       => NULL
                                                            ,pr_dtrisco_rating       => NULL
                                                            ,pr_inrisco_rating_autom => NULL
                                                            ,pr_dtrisco_rating_autom => NULL
                                                            ,pr_insituacao_rating    => NULL
                                                            ,pr_inorigem_rating      => NULL
                                                            ,pr_cdoperad_rating      => pr_cdoperad
                                                            ,pr_tpoperacao_rating    => NULL
                                                            ,pr_cdcritic             => vr_cdcritic
                                                            ,pr_dscritic             => vr_dscritic);
                IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                  RAISE vr_exc_saida;
                END IF;
                
                gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                              ,pr_des_text => 'UPDATE tbrisco_operacoes SET '
                                                                  ||' flintegrar_sas = 0 '
                                                            ||' WHERE cdcooper = '||pr_cdcooper
                                                            ||'   AND nrdconta = '||pr_nrdconta
                                                             ||'  AND nrctremp = '||pr_nrctrlim
                                                             ||'  AND tpctrato = 1;');        

                 gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                         ,pr_des_text => 'Delete tbrating_historicos '
                                       ||' WHERE cdcooper = '||pr_cdcooper           
                                       ||'   AND nrdconta = '||pr_nrdconta                                 
                                       ||'   AND nrctremp = '||pr_nrctrlim                                 
                                       ||'   AND tpctrato = 1 '                                 
                                       ||'   AND ds_justificativa = '||''''||'Renovacao Limite de credito em massa1'||''''                                 
                                       ||';'                                 
                                      );                                  
              END IF;                                                  
                                   
           ELSE
             RAISE vr_exc_saida;
           END IF;  
        ELSE

          RATI0003.pc_busca_endivid_param(pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_vlendivi => vr_vlendivid
                                         ,pr_vlrating => vr_vllimrating
                                         ,pr_dscritic => vr_dscritic);
          IF TRIM(vr_dscritic) IS NOT NULL THEN
             RAISE vr_exc_saida;
          END IF;

          IF vr_flgrating = 0 THEN
            vr_dscritic := 'Contrato não pode ser efetivado porque não há Rating válido.';
            RAISE vr_exc_saida;

          ELSE

            IF ((vr_vlendivid) > vr_vllimrating) THEN

              rati0003.pc_grava_rating_operacao(pr_cdcooper          => pr_cdcooper
                                               ,pr_nrdconta          => pr_nrdconta
                                               ,pr_tpctrato          => 1 
                                               ,pr_nrctrato          => pr_nrctrlim
                                               ,pr_dtrating          => pr_dtmvtolt
                                               ,pr_strating          => 4
                                               ,pr_efetivacao_rating => 1 
                                               ,pr_cdoperad          => pr_cdoperad
                                               ,pr_dtmvtolt          => pr_dtmvtolt
                                               ,pr_valor             => rw_craplim.vllimite
                                               ,pr_rating_sugerido   => NULL
                                               ,pr_justificativa     => 'Renovação de Contrato - Efetivação do Rating [LIMI0001.pc_renovar_limite_cred_manual]'
                                               ,pr_tpoperacao_rating => 2
                                               ,pr_nrcpfcnpj_base    => rw_crapass.nrcpfcnpj_base
                                               ,pr_cdcritic          => vr_cdcritic
                                               ,pr_dscritic          => vr_dscritic);

              IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                RAISE vr_exc_saida;
              END IF;

              rati0005.pc_altera_flag_alterar(pr_cdcooper => pr_cdcooper
                                             ,pr_nrdconta => pr_nrdconta
                                             ,pr_nrctrato => pr_nrctrlim
                                             ,pr_tpctrato => 1 
                                             ,pr_flgalter => 0
                                             ,pr_dscritic => vr_dscritic);

              IF TRIM(vr_dscritic) IS NOT NULL THEN
                RAISE vr_exc_saida;
              END IF;

            END IF;
            
          END IF;

        END IF;

      END IF;

    END IF;

 

    BEGIN
      UPDATE craplim SET
             dtrenova = pr_dtmvtolt,
             tprenova = 'M',
             dsnrenov = '',
             dtfimvig = pr_dtmvtolt + nvl(qtdiavig,0),
             qtrenova = nvl(qtrenova,0) + 1,
             cdoperad = pr_cdoperad,
             cdopelib = pr_cdoperad
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctrlim = pr_nrctrlim
         AND tpctrlim = 1; 
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao renovar o limite de credito: ' || SQLERRM;
        RAISE vr_exc_saida;
    END;
       
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                  ,pr_des_text => 'UPDATE craplim SET '
                                                      ||' dtrenova = '||''''||to_char(rw_craplim.dtrenova,'dd/mm/rrrr')||''''
                                                      ||' ,tprenova = '||''''||rw_craplim.tprenova||''''
                                                      ||' ,dsnrenov = '||''''||rw_craplim.dsnrenov||''''                
                                                      ||' ,dtfimvig = '||''''||to_char(rw_craplim.dtfimvig_rollback,'dd/mm/rrrr')||''''
                                                      ||' ,qtrenova = '||rw_craplim.qtrenova
                                                      ||' ,cdoperad = '||''''||rw_craplim.cdoperad||''''
                                                      ||' ,cdopelib = '||''''||rw_craplim.cdoperad||''''
                                                      ||' WHERE cdcooper = '||pr_cdcooper
                                                      ||'  AND nrdconta = '||pr_nrdconta
                                                      ||'  AND nrctrlim = '||pr_nrctrlim
                                                      ||'  AND tpctrlim = 1;' );

    vr_flgctitg  := 3;
    vr_dsaltera  := 'Renov. Manual Limite Cred. Ctr: ' || pr_nrctrlim || ',';


    IF trim(rw_crapass.nrdctitg) IS NOT NULL AND rw_crapass.flgctitg = 2 THEN 
      vr_flgctitg := 0;
    END IF;

    OPEN cr_crapalt (pr_cdcooper => pr_cdcooper
                    ,pr_nrdconta => pr_nrdconta
                    ,pr_dtmvtolt => pr_dtmvtolt);
    FETCH cr_crapalt INTO rw_crapalt;

    IF cr_crapalt%FOUND THEN
      CLOSE cr_crapalt;

      BEGIN
        UPDATE crapalt SET
               crapalt.dsaltera = rw_crapalt.dsaltera || vr_dsaltera,
               crapalt.cdoperad = pr_cdoperad,
               crapalt.flgctitg = vr_flgctitg
         WHERE crapalt.rowid = rw_crapalt.rowid;
         
         gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                  ,pr_des_text => 'UPDATE crapalt SET '
                                                          ||' dsaltera = '||''''||to_char(rw_craplim.dtrenova,'dd/mm/rrrr')||''''
                                                          ||' ,cdoperad = '||''''||rw_craplim.cdoperad||''''
                                                          ||' ,flgctitg = '||''''||rw_craplim.cdoperad||''''
                                                    ||' WHERE rowid = '||''''||rw_crapalt.rowid||''''
                                                    ||';'
                                                   );     
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic:= 'Erro ao atualizar crapalt. '||SQLERRM;
          RAISE vr_exc_saida;
      END;
    ELSE
      CLOSE cr_crapalt;

      BEGIN
        INSERT INTO crapalt
          (crapalt.nrdconta
          ,crapalt.dtaltera
          ,crapalt.tpaltera
          ,crapalt.dsaltera
          ,crapalt.cdcooper
          ,crapalt.flgctitg
          ,crapalt.cdoperad)
        VALUES
          (pr_nrdconta
          ,pr_dtmvtolt
          ,2
          ,vr_dsaltera
          ,pr_cdcooper
          ,vr_flgctitg
          ,pr_cdoperad);

          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                        ,pr_des_text => 'delete crapalt '
                                                      ||' WHERE cdcooper = '||pr_cdcooper
                                                      ||' and nrdconta = '||pr_nrdconta
                                                      ||' and tpaltera = 2'
                                                      ||' and dtaltera = '||''''||to_char(pr_dtmvtolt,'dd/mm/rrrr')||''''
                                                      ||';'
                                                     );          
    
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir crapalt. '||SQLERRM;
          RAISE vr_exc_saida;
      END;

    END IF;
    
   GENE0001.pc_gera_log(pr_cdcooper =>  pr_cdcooper
                       ,pr_cdoperad => '1'
                       ,pr_dscritic => ' '
                       ,pr_dsorigem => gene0001.vr_vet_des_origens(5)
                       ,pr_dstransa => 'Renovacao manual Limite - ' || vr_aux_diretor
                       ,pr_dttransa => TRUNC(SYSDATE)
                       ,pr_flgtrans => 1
                       ,pr_hrtransa => gene0002.fn_busca_time
                       ,pr_idseqttl => 1
                       ,pr_nmdatela => 'Script'
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrdrowid => vr_nrdrowid);

   GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                             pr_nmdcampo => 'Contrato',
                             pr_dsdadant => NULL,
                             pr_dsdadatu => pr_nrctrlim);    

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
          vr_aux_cdcooper := TO_NUMBER(vr_vet_campos(1));
          vr_aux_nrdconta := TO_NUMBER(vr_vet_campos(2));
          vr_aux_nrctrlim := TO_NUMBER(vr_vet_campos(3));
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
            
        vr_cont_commit  := vr_cont_commit + 1;
              
         OPEN BTCH0001.cr_crapdat(pr_cdcooper =>  vr_tab_carga(vr_idx1).cdcooper);
         FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
         CLOSE BTCH0001.cr_crapdat;

         pc_renovar_limite_cred_manual(pr_cdcooper => vr_tab_carga(vr_idx1).cdcooper
                                      ,pr_cdoperad => '1'
                                      ,pr_nmdatela => 'ATENDA'
                                      ,pr_idorigem => 5
                                      ,pr_nrdconta => vr_tab_carga(vr_idx1).nrdconta
                                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                      ,pr_nrctrlim => vr_tab_carga(vr_idx1).nrctrlim
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic);
         IF vr_dscritic IS NOT NULL THEN
            gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                          ,pr_des_text => vr_tab_carga(vr_idx1).cdcooper || ';' || 
                                                          vr_tab_carga(vr_idx1).nrdconta || ';' || 
                                                          vr_tab_carga(vr_idx1).nrctrlim || ';' || 
                                                          vr_dscritic);
                                                                            
         END IF;
                         
         IF vr_cont_commit = 200 THEN
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
