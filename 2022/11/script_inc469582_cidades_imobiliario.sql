DECLARE

   vr_aux_ambiente    INTEGER       := 3;             
   vr_aux_diretor     VARCHAR2(100) := 'INC469582';     
   vr_aux_arquivo     VARCHAR2(100) := 'registros_imob'; 
   vr_handle          UTL_FILE.FILE_TYPE; 
   vr_handle_log      UTL_FILE.FILE_TYPE;
   vr_nmarq_log       VARCHAR2(200);
   vr_nmarq_rollback  VARCHAR2(200);
   vr_des_erro        VARCHAR2(10000); 
   vr_cdcritic        crapcri.cdcritic%TYPE;
   vr_dscritic        crapcri.dscritic%TYPE;
   vr_exc_erro        EXCEPTION;

   PROCEDURE pc_ajusta_cidades IS 
         
       vr_qtd_sucesso_nmcidade integer := 0;
       vr_qtd_erro_nmcidade integer := 0;
       vr_qtd_sucesso_cdcidade integer := 0;
       vr_qtd_erro_cdcidade integer := 0;
        
       CURSOR cr_bem_sem_cidade is
          SELECT b.cdcooper, b.nrdconta, b.nrctremp, b.nrcep, B.NMCIDADE, (SELECT i.nmextcid 
                                                                             FROM crapdne i
                                                                            WHERE SUBSTR(i.nrceplog,1,5) = SUBSTR(b.nrcep,1,5)
                                                                              AND i.cdcidibge is not null
                                                                              AND ROWNUM = 1) CIDADE
            FROM credito.tbepr_contrato_bem_imobiliario b
           WHERE b.nrctremp not in (SELECT bimob.nrctremp
                                      FROM cecred.crapmun mun
                                          ,credito.tbepr_contrato_bem_imobiliario bimob  
                                     WHERE upper(mun.dscidade) = upper(bimob.nmcidade)
                                       AND mun.cdestado = bimob.nmestado);
                                    
        CURSOR cr_imovel_sem_cdcidade IS
          SELECT I.CDCOOPER, I.NRDCONTA, I.NRCTRPRO, b.nmcidade, I.CDCIDADE, (SELECT MUN.CDCIDADE
                                                                                FROM crapmun mun
                                                                               WHERE upper(mun.dscidade) = upper(b.nmcidade)
                                                                                 AND upper(mun.cdestado) = upper(b.nmestado)) cod
            FROM cecred.tbepr_imovel_alienado i
                ,credito.tbepr_contrato_bem_imobiliario b 
           WHERE I.CDCIDADE = 0
             AND i.cdcooper = b.cdcooper
             AND i.nrdconta = b.nrdconta
             AND i.nrctrpro = b.nrctremp; 
           
       
     BEGIN                                      
          FOR rw_bem_sem_cidade in cr_bem_sem_cidade LOOP
            vr_dscritic := '';
            BEGIN
              
             UPDATE credito.tbepr_contrato_bem_imobiliario b
                SET b.nmcidade = rw_bem_sem_cidade.cidade
              WHERE b.cdcooper = rw_bem_sem_cidade.cdcooper
                AND b.nrdconta = rw_bem_sem_cidade.nrdconta
                AND b.nrctremp = rw_bem_sem_cidade.nrctremp; 
                 
             vr_qtd_sucesso_nmcidade := vr_qtd_sucesso_nmcidade + 1;
            EXCEPTION
              WHEN OTHERS THEN
                vr_qtd_erro_nmcidade := vr_qtd_erro_nmcidade + 1;
                vr_dscritic := 'Erro ao atualizar tabela credito.tbepr_contrato_bem_imobiliario. ' || SQLERRM;
                gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                              ,pr_des_text => rw_bem_sem_cidade.cdcooper || ';' || 
                                                              rw_bem_sem_cidade.nrdconta || ';' ||
                                                              rw_bem_sem_cidade.nrctremp || ';' ||
                                                              vr_dscritic);
            END;
                        
            IF vr_dscritic IS NULL THEN
               gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                             ,pr_des_text => 'UPDATE CREDITO.TBEPR_CONTRATO_BEM_IMOBILIARIO'
                                                           ||' SET nmcidade   = "'||rw_bem_sem_cidade.nmcidade || '"'
                                                           ||' WHERE cdcooper = '||rw_bem_sem_cidade.cdcooper
                                                           ||'   AND nrdconta = '||rw_bem_sem_cidade.nrdconta
                                                           ||'   AND nrctremp = '||rw_bem_sem_cidade.nrctremp||';');  
               gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                             ,pr_des_text => 'COMMIT;');                                                                                                                                                                                
            END IF;
          END LOOP; 
          COMMIT;

          FOR rw_imovel_sem_cdcidade IN cr_imovel_sem_cdcidade LOOP
            vr_dscritic := '';
            BEGIN
                           
              UPDATE cecred.tbepr_imovel_alienado i 
                 SET i.CDCIDADE = rw_imovel_sem_cdcidade.cod
               WHERE i.CDCOOPER = rw_imovel_sem_cdcidade.CDCOOPER
                 AND i.NRDCONTA = rw_imovel_sem_cdcidade.NRDCONTA
                 AND i.NRCTRPRO = rw_imovel_sem_cdcidade.NRCTRPRO;
                 
              vr_qtd_sucesso_cdcidade := vr_qtd_sucesso_cdcidade + 1;
              
            EXCEPTION
              WHEN OTHERS THEN
                vr_qtd_erro_cdcidade := vr_qtd_erro_cdcidade + 1;
                vr_dscritic := 'Erro ao atualizar tabela cecred.tbepr_imovel_alienado. ' || SQLERRM;
                gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                              ,pr_des_text => rw_imovel_sem_cdcidade.cdcooper || ';' || 
                                                              rw_imovel_sem_cdcidade.nrdconta || ';' ||
                                                              rw_imovel_sem_cdcidade.nrctrpro || ';' ||
                                                              vr_dscritic);
                END;
                            
                IF vr_dscritic IS NULL THEN
                   gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                                 ,pr_des_text => 'UPDATE cecred.tbepr_imovel_alienado'
                                                               ||' SET cdcidade   = '||rw_imovel_sem_cdcidade.cdcidade
                                                               ||' WHERE cdcooper = '||rw_imovel_sem_cdcidade.cdcooper
                                                               ||'   AND nrdconta = '||rw_imovel_sem_cdcidade.nrdconta
                                                               ||'   AND nrctrpro = '||rw_imovel_sem_cdcidade.nrctrpro||';');  
                   gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                                 ,pr_des_text => 'COMMIT;');                                                                                                                                                                                
                END IF;   
          END LOOP;
          COMMIT;
          
          
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                        ,pr_des_text => chr(10) || 'Nomes de cidade atualizados:' || vr_qtd_sucesso_nmcidade || chr(10) || 
                                                        'Nomes de cidade com erro:'    || vr_qtd_erro_nmcidade || chr(10) ||
                                                        'Codigo de cidade atualizados:' || vr_qtd_sucesso_cdcidade || chr(10) ||
                                                        'Codigo de cidade com erro:' || vr_qtd_erro_cdcidade);                             
   END pc_ajusta_cidades;
        

BEGIN
    IF vr_aux_ambiente = 1 THEN 
      vr_nmarq_log      := '/progress/t0032597/micros/script_renovacao/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_LOG.txt';      
      vr_nmarq_rollback := '/progress/t0032597/micros/script_renovacao/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_ROLLBACK.sql';       
    ELSIF vr_aux_ambiente = 2 THEN     
      vr_nmarq_log      := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/evandro/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_LOG.txt';     
      vr_nmarq_rollback := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/evandro/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_ROLLBACK.sql'; 
    ELSIF vr_aux_ambiente = 3 THEN 
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

    pc_ajusta_cidades();

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
