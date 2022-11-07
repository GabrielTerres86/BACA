DECLARE

   vr_aux_ambiente    INTEGER       := 3;             
   vr_aux_diretor     VARCHAR2(100) := 'INC0228851';     
   vr_aux_arquivo     VARCHAR2(100) := 'registros_imob'; 
   vr_handle          UTL_FILE.FILE_TYPE; 
   vr_handle_log      UTL_FILE.FILE_TYPE;
   vr_handle_bens     UTL_FILE.FILE_TYPE;
   vr_nmarq_bens      VARCHAR2(200);
   vr_nmarq_log       VARCHAR2(200);
   vr_nmarq_rollback  VARCHAR2(200);
   vr_des_erro        VARCHAR2(10000); 
   vr_des_linha       VARCHAR2(3000); 
   vr_aux_arrlinha    GENE0002.typ_split; 
   vr_cont_reg        NUMBER :=0 ;
   vr_aux_cont_ocorre NUMBER :=0 ;
   vr_cdcritic        crapcri.cdcritic%TYPE;
   vr_dscritic        crapcri.dscritic%TYPE;
   vr_exc_erro        EXCEPTION;

   CURSOR cr_sembem IS       
   SELECT c.cdcooper, 
          c.nrdconta, 
          c.nrctremp
     FROM credito.tbepr_contrato_imobiliario c 
    WHERE tipo_registro = 2
      AND NOT EXISTS (SELECT 1
                        FROM tbepr_contrato_bem_imobiliario b
                       WHERE b.cdcooper = c.cdcooper
                         AND b.nrdconta = c.nrdconta
                         AND b.nrctremp = c.nrctremp);
   
    CURSOR cr_dados_bem(pr_nrctremp IN CREDITO.tbepr_contrato_imobiliario.nrctremp%type) IS                      
    SELECT imob.cdcooper,
           imob.nrdconta,
           imob.nrctremp,
           imob.cdoperad,
           bimob.nrmatricula,       
           bimob.dslogradouro,
           bimob.nrlogradouro,
           bimob.dscomplemento,
           bimob.nmbairro,
           bimob.nmcidade,
           bimob.nmestado,
           bimob.nrcep,
           bimob.qtareatotal,
           bimob.qtareautil                       
      FROM credito.tbepr_contrato_imobiliario imob,
           credito.tbepr_contrato_bem_imobiliario bimob
     WHERE bimob.nrdconta = imob.nrdconta
       AND bimob.cdcooper = imob.cdcooper
       AND bimob.nrctremp = imob.nrctremp
       AND imob.nrctremp = pr_nrctremp;                       
    rw_dados_bem cr_dados_bem%ROWTYPE;
              
    TYPE typ_reg_arquivo IS
    RECORD(nrctremp      tbepr_contrato_bem_imobiliario.nrctremp%TYPE,
           nrcep         tbepr_contrato_bem_imobiliario.nrcep%TYPE,
           dslogradouro  tbepr_contrato_bem_imobiliario.dslogradouro%TYPE,
           dscomplemento tbepr_contrato_bem_imobiliario.dscomplemento%TYPE,
           dscategoria   tbepr_contrato_bem_imobiliario.dscategoria%TYPE,
           nrlogradouro  tbepr_contrato_bem_imobiliario.nrlogradouro%TYPE,
           dsbairro      tbepr_contrato_bem_imobiliario.nmbairro%TYPE,
           nmcidade      tbepr_contrato_bem_imobiliario.nmcidade%TYPE,
           nmestado      tbepr_contrato_bem_imobiliario.nmestado%TYPE,
           operacaob3    tbepr_imovel_alienado.nrregistro_operacao%TYPE,
           datab3        tbepr_imovel_alienado.dtregistro_operacao%TYPE);

    TYPE typ_tab_arquivo IS TABLE OF typ_reg_arquivo INDEX BY PLS_INTEGER;     
    vr_tab_arquivo typ_tab_arquivo;
    
    PROCEDURE pc_busca_registros_arquivo(pr_tab_dados_arquivo OUT NOCOPY typ_tab_arquivo) IS
      BEGIN      
         gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nmarq_bens
                                 ,pr_tipabert => 'R'              
                                 ,pr_utlfileh => vr_handle_bens   
                                 ,pr_des_erro => vr_des_erro);
         IF vr_des_erro IS NOT NULL THEN
            vr_dscritic := 'Erro ao abrir arquivo de bens: ' || vr_des_erro;
            RAISE vr_exc_erro;
         END IF;

         BEGIN
             LOOP
                GENE0001.pc_le_linha_arquivo(pr_utlfileh => vr_handle_bens
                                            ,pr_des_text => vr_des_linha);
                      
                 vr_des_linha := TRIM(REPLACE(REPLACE(vr_des_linha,chr(13),''),chr(10),''));
                       
                 IF instr(vr_des_linha,'OPERACAO') > 0 THEN
                    vr_cont_reg := vr_cont_reg + 1;
                    vr_aux_arrlinha := gene0002.fn_quebra_string(vr_des_linha,';');
                    pr_tab_dados_arquivo(vr_cont_reg).operacaob3 := vr_aux_arrlinha(2);
                    pr_tab_dados_arquivo(vr_cont_reg).datab3 := TO_DATE(vr_aux_arrlinha(3),'DD/MM/RRRR');
                 END IF;
                   
                 IF instr(vr_des_linha,'CONTRATO') > 0 THEN
                    vr_aux_arrlinha := gene0002.fn_quebra_string(vr_des_linha,';'); 
                    pr_tab_dados_arquivo(vr_cont_reg).nrctremp := vr_aux_arrlinha(3);  
                 END IF;
                       
                 IF instr(vr_des_linha,'IMOVEL') > 0 THEN
                     vr_aux_arrlinha := gene0002.fn_quebra_string(vr_des_linha,';');
                     pr_tab_dados_arquivo(vr_cont_reg).dslogradouro := vr_aux_arrlinha(9);
                     pr_tab_dados_arquivo(vr_cont_reg).nrlogradouro := CASE vr_aux_arrlinha(10) WHEN 'SN' THEN '' ELSE vr_aux_arrlinha(10) END;                                               
                     pr_tab_dados_arquivo(vr_cont_reg).dscomplemento := vr_aux_arrlinha(11);
                     pr_tab_dados_arquivo(vr_cont_reg).dsbairro := vr_aux_arrlinha(12);
                     pr_tab_dados_arquivo(vr_cont_reg).nmestado := vr_aux_arrlinha(14);
                     pr_tab_dados_arquivo(vr_cont_reg).nrcep := vr_aux_arrlinha(15);
                     IF (instr(UPPER(vr_aux_arrlinha(11)),'AP') > 0) OR instr(UPPER(vr_aux_arrlinha(11)),'UNID') > 0 THEN
                        pr_tab_dados_arquivo(vr_cont_reg).dscategoria := 'Apartamento';
                     ELSIF instr(UPPER(vr_aux_arrlinha(11)),'CASA') > 0 THEN
                        pr_tab_dados_arquivo(vr_cont_reg).dscategoria := 'Casa';
                     ELSE
                        pr_tab_dados_arquivo(vr_cont_reg).dscategoria := 0;  
                     END IF;
                 END IF;  
             END LOOP;  
                  
         EXCEPTION
             WHEN no_data_found THEN
             NULL;
         END;
         gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_bens);
    END pc_busca_registros_arquivo;                                           


    PROCEDURE pc_inclui_bem(pr_tab_dados_arquivo IN OUT NOCOPY typ_tab_arquivo) IS  
      BEGIN                                      
           FOR rw_sembem IN cr_sembem LOOP
             
                vr_aux_cont_ocorre := 0;
                vr_dscritic := '';

                FOR vr_ind in pr_tab_dados_arquivo.first .. pr_tab_dados_arquivo.last LOOP 
                  
                    IF rw_sembem.nrctremp = pr_tab_dados_arquivo(vr_ind).nrctremp THEN
                        
                       BEGIN
                       INSERT INTO CREDITO.TBEPR_CONTRATO_BEM_IMOBILIARIO(CDCOOPER,
                                                                          NRDCONTA,
                                                                          NRCTREMP,
                                                                          DSCATEGORIA,
                                                                          NRCEP,
                                                                          DSLOGRADOURO,
                                                                          DSCOMPLEMENTO,
                                                                          NRLOGRADOURO,
                                                                          NMBAIRRO,
                                                                          NMESTADO)
                                                                    VALUES
                                                                         (rw_sembem.cdcooper,
                                                                          rw_sembem.nrdconta,
                                                                          rw_sembem.nrctremp,
                                                                          pr_tab_dados_arquivo(vr_ind).dscategoria,
                                                                          pr_tab_dados_arquivo(vr_ind).nrcep,
                                                                          pr_tab_dados_arquivo(vr_ind).dslogradouro,
                                                                          pr_tab_dados_arquivo(vr_ind).dscomplemento,
                                                                          pr_tab_dados_arquivo(vr_ind).nrlogradouro,
                                                                          pr_tab_dados_arquivo(vr_ind).dsbairro,
                                                                          pr_tab_dados_arquivo(vr_ind).nmestado);
                       EXCEPTION
                          WHEN OTHERS THEN
                            vr_dscritic := 'Erro ao inserir na tabela TBEPR_CONTRATO_BEM_IMOBILIARIO. ' || SQLERRM;
                            gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                                          ,pr_des_text => rw_sembem.cdcooper || ';' || 
                                                                          rw_sembem.nrdconta || ';' ||
                                                                          rw_sembem.nrctremp || ';' ||
                                                                          vr_dscritic);
                                           
                        END;
                        
                        IF vr_dscritic IS NULL THEN
                           gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                                         ,pr_des_text => 'DELETE CREDITO.TBEPR_CONTRATO_BEM_IMOBILIARIO'
                                                                       ||' WHERE cdcooper = '||rw_sembem.cdcooper
                                                                       ||'   AND nrdconta = '||rw_sembem.nrdconta
                                                                       ||'   AND nrctremp = '||rw_sembem.nrctremp||';');  
                           gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                                         ,pr_des_text => 'COMMIT;');                             
                                                                                                                                                      
                        END IF;
                        
                        vr_aux_cont_ocorre := vr_aux_cont_ocorre + 1;
                     END IF;
   
                END LOOP;
                
                IF vr_aux_cont_ocorre = 0 THEN
                    vr_dscritic := 'Contrato nao encontrado no arquivo.';
                    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                                  ,pr_des_text => rw_sembem.cdcooper || ';' || 
                                                                  rw_sembem.nrdconta || ';' ||
                                                                  rw_sembem.nrctremp || ';' ||
                                                                  vr_dscritic);   
                END IF;
           END LOOP;
           COMMIT;                               
    END pc_inclui_bem;
    
    
    PROCEDURE pc_inclui_operacao(pr_tab_dados_arquivo IN OUT NOCOPY typ_tab_arquivo) IS  
      BEGIN 
        
       FOR vr_ind in pr_tab_dados_arquivo.first .. pr_tab_dados_arquivo.last LOOP 
           vr_dscritic := '';
           
           OPEN cr_dados_bem(pr_tab_dados_arquivo(vr_ind).nrctremp);
           FETCH cr_dados_bem into rw_dados_bem;         

           IF cr_dados_bem%NOTFOUND THEN
              vr_dscritic := 'Contrato nao encontrado na base.';
              gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                            ,pr_des_text => ';;' ||
                                                            pr_tab_dados_arquivo(vr_ind).nrctremp || ';' ||
                                                            vr_dscritic);  
           ELSE                   
             BEGIN                
                INSERT INTO cecred.tbepr_imovel_alienado(cdcooper
                                                        ,nrdconta
                                                        ,nrctrpro
                                                        ,idseqbem
                                                        ,dtmvtolt
                                                        ,cdoperad
                                                        ,cdsituacao 
                                                        ,nrmatric_cartorio
                                                        ,nrcns_cartorio 
                                                        ,nrreg_garantia
                                                        ,dtreg_garantia
                                                        ,nrgrau_garantia
                                                        ,tplogradouro
                                                        ,dslogradouro 
                                                        ,nrlogradouro 
                                                        ,dscomplemento 
                                                        ,dsbairro
                                                        ,cdcidade
                                                        ,nrcep
                                                        ,dtcompra
                                                        ,vlcompra
                                                        ,tpimplantacao
                                                        ,vlarea_total 
                                                        ,vlarea_privada
                                                        ,qtddormitorio
                                                        ,qtdvagas
                                                        ,insitimovel
                                                        ,nrregistro_operacao
                                                        ,dtregistro_operacao)
                                                      VALUES
                                                        (rw_dados_bem.cdcooper
                                                        ,rw_dados_bem.nrdconta
                                                        ,rw_dados_bem.nrctremp
                                                        ,1
                                                        ,trunc(SYSDATE) 
                                                        ,NVL(rw_dados_bem.cdoperad,1)
                                                        ,0
                                                        ,NVL(rw_dados_bem.nrmatricula,0)
                                                        ,0 
                                                        ,0 
                                                        ,trunc(SYSDATE)
                                                        ,0
                                                        ,33
                                                        ,UPPER(rw_dados_bem.dslogradouro)
                                                        ,rw_dados_bem.nrlogradouro
                                                        ,UPPER(rw_dados_bem.dscomplemento)
                                                        ,UPPER(rw_dados_bem.nmbairro)
                                                        ,0
                                                        ,NVL(rw_dados_bem.nrcep,0)
                                                        ,trunc(SYSDATE)
                                                        ,0 
                                                        ,0                                                     
                                                        ,NVL(rw_dados_bem.qtareatotal,0)
                                                        ,NVL(rw_dados_bem.qtareautil,0)
                                                        ,0 
                                                        ,0 
                                                        ,3 
                                                        ,pr_tab_dados_arquivo(vr_ind).operacaob3
                                                        ,pr_tab_dados_arquivo(vr_ind).datab3);      
             EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao inserir na tabela tbepr_imovel_alienado. ' || SQLERRM;
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                                ,pr_des_text => rw_dados_bem.cdcooper || ';' || 
                                                                rw_dados_bem.nrdconta || ';' ||
                                                                rw_dados_bem.nrctremp || ';' ||
                                                                vr_dscritic);                                          
             END;
           END IF;  
           CLOSE cr_dados_bem;
           
           IF vr_dscritic IS NULL THEN
               gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                             ,pr_des_text => 'DELETE cecred.tbepr_imovel_alienado'
                                                           ||' WHERE cdcooper = '||rw_dados_bem.cdcooper
                                                           ||'   AND nrdconta = '||rw_dados_bem.nrdconta
                                                           ||'   AND nrctrpro = '||rw_dados_bem.nrctremp||';');  
               gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                             ,pr_des_text => 'COMMIT;');                                                                                                                                                                                     
           END IF;                      
       END LOOP;                                          
    END pc_inclui_operacao;      

BEGIN
    IF vr_aux_ambiente = 1 THEN 
      vr_nmarq_bens     := '/progress/t0032597/micros/script_renovacao/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'.csv';  
      vr_nmarq_log      := '/progress/t0032597/micros/script_renovacao/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_LOG.txt';      
      vr_nmarq_rollback := '/progress/t0032597/micros/script_renovacao/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_ROLLBACK.sql';       
    ELSIF vr_aux_ambiente = 2 THEN   
      vr_nmarq_bens     := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/evandro/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'.csv';     
      vr_nmarq_log      := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/evandro/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_LOG.txt';     
      vr_nmarq_rollback := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/evandro/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_ROLLBACK.sql'; 
    ELSIF vr_aux_ambiente = 3 THEN 
      vr_nmarq_bens     := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/DouglasP/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'.csv';
      vr_nmarq_log      := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/DouglasP/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_LOG.txt';      
      vr_nmarq_rollback := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/DouglasP/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_ROLLBACK.sql'; 
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

    pc_busca_registros_arquivo(pr_tab_dados_arquivo => vr_tab_arquivo);      
    pc_inclui_bem(pr_tab_dados_arquivo => vr_tab_arquivo); 
    pc_inclui_operacao(pr_tab_dados_arquivo => vr_tab_arquivo); 

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
