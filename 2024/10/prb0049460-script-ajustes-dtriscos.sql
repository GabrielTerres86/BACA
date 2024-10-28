DECLARE
   vr_aux_ambiente    INTEGER       := 3;             
   vr_aux_diretor     VARCHAR2(100) := 'PRB0049460';     
   vr_aux_arquivo     VARCHAR2(100) := 'registros';
   vr_handle          UTL_FILE.FILE_TYPE; 
   vr_handle_log      UTL_FILE.FILE_TYPE;
   vr_handle_regs     UTL_FILE.FILE_TYPE;
   vr_nmarq_regs      VARCHAR2(200);
   vr_nmarq_log       VARCHAR2(200);
   vr_nmarq_rollback  VARCHAR2(200);
   vr_des_erro        VARCHAR2(10000); 
   vr_des_linha       VARCHAR2(3000);  
   vr_vet_campos      GENE0002.typ_split; 
   vr_nrcontad        PLS_INTEGER := 0; 
   vr_aux_cdcooper    NUMBER;  
   vr_aux_cddlinha    NUMBER;
   vr_aux_nrborder    NUMBER;
   vr_aux_nrdconta    NUMBER;
   vr_cont_commit     NUMBER(6) := 0;
   vr_cdcritic        crapcri.cdcritic%TYPE;
   vr_dscritic        crapcri.dscritic%TYPE;
   vr_exc_erro        EXCEPTION;
   vr_conta_ambiente  NUMBER;
   vr_aux_campo1      DATE;
     
  TYPE typ_reg_carga IS RECORD(cdcooper  crapbdt.cdcooper%TYPE
                              ,nrdconta  crapbdt.nrdconta%TYPE
                              ,nrborder  crapbdt.nrborder%TYPE
                              ,campo1    DATE);
  TYPE typ_tab_carga IS TABLE OF typ_reg_carga INDEX BY PLS_INTEGER;
  vr_tab_carga typ_tab_carga;
  
  CURSOR cr_conta_ambiente(pr_cdcooper IN crapbdt.cdcooper%TYPE
                          ,pr_nrborder IN crapbdt.nrborder%TYPE) IS
    SELECT bdt.nrdconta
      FROM cecred.crapbdt bdt
     WHERE bdt.cdcooper = pr_cdcooper
       AND bdt.nrborder = pr_nrborder;
  rw_conta_ambiente cr_conta_ambiente%ROWTYPE;
  
        
    PROCEDURE pc_ajustar_risco (pr_cdcooper IN crapcop.cdcooper%TYPE 
                               ,pr_nrdconta IN crapass.nrdconta%TYPE
                               ,pr_nrborder IN crapbdt.nrborder%TYPE
                               ,pr_dtriscof IN DATE    
                               ,pr_cdcritic OUT crapcri.cdcritic%TYPE 
                               ,pr_dscritic OUT VARCHAR2) IS                                                                    
      
    CURSOR cr_risco(pr_cdcooper craptdb.cdcooper%TYPE
                   ,pr_nrdconta craptdb.nrdconta%TYPE
                   ,pr_nrborder craptdb.nrborder%TYPE) IS
      SELECT o.dtreferencia DTREFERE, 
             o.idcooperativa COOP,
             o.nrconta CTA,
             o.nrcontrato CTR,
             o.qtdia_atraso, 
             o.flprejuizo,
             r.cdrisco_final FIN,
             r.dtrisco_final,
             r.dtreferencia,
             r.rowid
        FROM creditogestao.tb_central_risco c     
             ,creditogestao.tb_central_risco_operacao o
             ,creditogestao.tb_central_risco_operacao_riscos r
        WHERE o.idcooperativa = c.idcooperativa
          AND o.dtreferencia  = c.dtreferencia
          AND r.idcooperativa = c.idcooperativa
          AND r.dtreferencia  = c.dtreferencia
          AND o.idcooperativa = pr_cdcooper
          AND o.nrconta = pr_nrdconta
          AND o.nrcontrato = pr_nrborder
          and c.dtreferencia >= to_date('14/10/2024','DD/MM/RRRR')
          AND r.idcentral_risco_operacao = o.idcentral_risco_operacao;

    vr_cdcritic    NUMBER;
    vr_dscritic    VARCHAR2(1000);
    vr_exc_erro    EXCEPTION;

    BEGIN

      
       BEGIN
            FOR rw_risco IN cr_risco (pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_nrborder => pr_nrborder
                                     ,pr_dtriscof => pr_dtriscof) LOOP
                                     
     
                        
               UPDATE creditogestao.tb_central_risco_operacao_riscos
                  SET dtrisco_final = to_date(pr_dtriscof,'DD/MM/RRRR'),
                      dtreferencia = to_date('28/10/2024','DD/MM/RRRR')
                WHERE ROWID = rw_risco.id;                         
                                                 
                gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                              ,pr_des_text => 'UPDATE creditogestao.tb_central_risco_operacao_riscos '    ||
                                                              '   SET dtrisco_final = to_date("' || rw_risco.dtrisco_final || '","DD/MM/RRRR")' ||
                                                              '      ,dtreferencia = to_date("' || rw_risco.dtreferencia || '","DD/MM/RRRR")' ||
                                                              ' WHERE ROWID = ' || rw_risco.id ||
                                                              ';'); 
                                       
            END LOOP;                                                  
       EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar creditogestao.tb_central_risco_operacao_riscos: ' || SQLERRM;
            RAISE vr_exc_erro;
       END;

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
        ROLLBACK;
        pr_cdcritic := 0;
        pr_dscritic := 'Erro não tratado na rotina pc_ajustar_risco: ' ||SQLERRM;
    END pc_ajustar_risco;
   

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
           vr_aux_nrborder := TO_NUMBER(vr_vet_campos(3));
           vr_aux_campo1   := vr_vet_campos(4);                                     
        EXCEPTION
          WHEN OTHERS THEN
            gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                          ,pr_des_text => 'Erro na leitura da linha: ' || vr_nrcontad || ' => ' || SQLERRM);
              
          CONTINUE;
        END;             

        vr_tab_carga(vr_nrcontad).cdcooper := vr_aux_cdcooper;
        vr_tab_carga(vr_nrcontad).nrdconta := vr_aux_nrdconta;
        vr_tab_carga(vr_nrcontad).nrborder := vr_aux_nrborder;
        vr_tab_carga(vr_nrcontad).campo1   := to_date(vr_aux_campo1, 'DD/MM/RRRR');

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

           
         IF vr_aux_ambiente = 3 THEN 
            vr_conta_ambiente := vr_tab_carga(vr_idx1).nrdconta;
         ELSE  
             OPEN cr_conta_ambiente (pr_cdcooper => vr_tab_carga(vr_idx1).cdcooper
                                    ,pr_nrborder => vr_tab_carga(vr_idx1).nrborder);
             FETCH cr_conta_ambiente INTO rw_conta_ambiente;
             IF cr_conta_ambiente%NOTFOUND THEN
                CLOSE cr_conta_ambiente;
                gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                              ,pr_des_text => 'Coop: ' || vr_tab_carga(vr_idx1).cdcooper ||' - Bordero nao encontrado: ' || vr_tab_carga(vr_idx1).nrborder);
                CONTINUE;
             END IF;
             CLOSE cr_conta_ambiente;
                 
             vr_conta_ambiente := rw_conta_ambiente.nrdconta;
         END IF;

         pc_ajustar_risco(pr_cdcooper => vr_tab_carga(vr_idx1).cdcooper
                         ,pr_nrdconta => vr_conta_ambiente
                         ,pr_nrborder => vr_tab_carga(vr_idx1).nrborder
                         ,pr_dtriscof => vr_tab_carga(vr_idx1).campo1
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic);

         IF vr_dscritic IS NOT NULL THEN
            gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                          ,pr_des_text => vr_tab_carga(vr_idx1).cdcooper || ';' || 
                                                          vr_conta_ambiente || ';' || 
                                                          vr_tab_carga(vr_idx1).nrborder || ';' || 
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
