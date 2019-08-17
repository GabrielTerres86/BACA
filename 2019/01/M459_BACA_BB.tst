PL/SQL Developer Test script 3.0
232
/***************************************************
** IMPORTANTE
** Separar os dados por ponto-virgula (;)
** Considerado somente as 7 primeiras posições da conta ITG desprezando o digito
***************************************************/

DECLARE
  vr_dsdireto   VARCHAR2(4000);
  vr_nmarquiv   VARCHAR2(100)  := 'contasBB.csv';
  vr_nmarq_com  varchar2(100)  := 'contasBB_com_erro.csv';
  vr_nmarq_sem  varchar2(100)  := 'contasBB_sem_erro.csv';
  vr_dtaltera   DATE := TRUNC(SYSDATE);
  vr_nrlinha    NUMBER := 1;
  vr_dscritic   VARCHAR2(4000);
  vr_linha_arq  VARCHAR2(2000);
  vr_conta_old  VARCHAR2(8);
  vr_conta_new  VARCHAR2(8);
  vr_nmcooper   VARCHAR2(50);
  vr_dsaltera   VARCHAR2(100);
  vr_cdcooper   NUMBER;
  vr_nrseqdig   NUMBER; 
  vr_blnachou   BOOLEAN;
  vr_handle_arq utl_file.file_type;
  vr_handle_com utl_file.file_type;
  vr_handle_sem utl_file.file_type;
  vr_vet_dados  gene0002.typ_split;

  CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
                   ,pr_nrdctitg IN crapass.nrdctitg%TYPE) IS
    SELECT crapass.rowid
          ,crapass.nrdconta
          ,crapass.nrdctitg
      FROM crapass
     WHERE crapass.cdcooper = pr_cdcooper
       AND UPPER(crapass.nrdctitg) LIKE UPPER(pr_nrdctitg || '%');
--        AND UPPER(substr(crapass.nrdctitg,1,7)) = UPPER(pr_nrdctitg);
  rw_crapass cr_crapass%ROWTYPE;

  CURSOR cr_crapalt(pr_cdcooper IN crapcop.cdcooper%TYPE
                   ,pr_nrdconta IN crapass.nrdconta%TYPE
                   ,pr_dtaltera IN crapalt.dtaltera%TYPE) IS
    SELECT crapalt.rowid
          ,crapalt.dsaltera
      FROM crapalt
     WHERE crapalt.cdcooper = pr_cdcooper
       AND crapalt.nrdconta = pr_nrdconta
       AND crapalt.dtaltera = pr_dtaltera;
  rw_crapalt cr_crapalt%ROWTYPE;


BEGIN
  
  vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'M'
                            ,pr_cdcooper => 3
                            ,pr_nmsubdir => NULL);
  
  -- Abrir o arquivo de saida de erro
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_dsdireto    --> Diretório do arquivo
                          ,pr_nmarquiv => vr_nmarq_com   --> Nome do arquivo
                          ,pr_tipabert => 'W'            --> Modo de abertura (R,W,A)
                          ,pr_utlfileh => vr_handle_com  --> Handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);  --> Erro

  -- Abrir o arquivo de saida de erro
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_dsdireto    --> Diretório do arquivo
                          ,pr_nmarquiv => vr_nmarq_sem   --> Nome do arquivo
                          ,pr_tipabert => 'W'            --> Modo de abertura (R,W,A)
                          ,pr_utlfileh => vr_handle_sem  --> Handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);  --> Erro

  -- Abrir arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_dsdireto    --> Diretório do arquivo
                          ,pr_nmarquiv => vr_nmarquiv    --> Nome do arquivo
                          ,pr_tipabert => 'R'            --> Modo de abertura (R,W,A)
                          ,pr_utlfileh => vr_handle_arq  --> Handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);  --> Erro

    IF utl_file.IS_OPEN(vr_handle_arq) then

      -- gravar linha de cabecalho do arquivo de saida
      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_com,
                                     pr_des_text => 'NUMERO DE CONTA;NUMERO DE CONTA ANTIGA;NUMERO DE CONTA NOVA;COOPERATIVA');

      -- gravar linha de cabecalho do arquivo de saida
      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_sem,
                                     pr_des_text => 'NUMERO DE CONTA;NUMERO DE CONTA ANTIGA;NUMERO DE CONTA NOVA;COOPERATIVA');

      BEGIN
        LOOP
          
          gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_handle_arq,
                                       pr_des_text => vr_linha_arq);
        
          -- valida a partir da linha 2, linha 1 é cabeçalho
          IF vr_nrlinha >= 2 THEN
            
            vr_vet_dados := gene0002.fn_quebra_string(pr_string => vr_linha_arq, pr_delimit => ';');
            
            vr_conta_old := lpad(TRIM(vr_vet_dados(1)) || TRIM(vr_vet_dados(2)),8,'0');
            vr_conta_new := lpad(TRIM(vr_vet_dados(3)) || TRIM(vr_vet_dados(4)),8,'0');
            vr_nmcooper  := TRIM(upper(REPLACE(vr_vet_dados(5),CHR(13),'')));
           
            IF vr_conta_old IS NOT NULL AND
               vr_conta_new IS NOT NULL AND
               vr_nmcooper  IS NOT NULL THEN
              
              CASE vr_nmcooper
                WHEN 'VIACREDI'    THEN vr_cdcooper := 1;
                WHEN 'ACREDICOOP'  THEN vr_cdcooper := 2;
                WHEN 'CECRED'      THEN vr_cdcooper := 3;
                WHEN 'ACENTRA'     THEN vr_cdcooper := 5;
                WHEN 'CREDIFIESC'  THEN vr_cdcooper := 6;
                WHEN 'CREDCREA'    THEN vr_cdcooper := 7;
                WHEN 'CREDELESC'   THEN vr_cdcooper := 8;
                WHEN 'TRANSPOCRED' THEN vr_cdcooper := 9;
                WHEN 'CREDICOMIM'  THEN vr_cdcooper := 10;
                WHEN 'CREDIFOZ'    THEN vr_cdcooper := 11;
                WHEN 'CREVISC'     THEN vr_cdcooper := 12;
                WHEN 'SCRCRED'     THEN vr_cdcooper := 13;
                WHEN 'RODOCREDITO' THEN vr_cdcooper := 14;
                WHEN 'VIACREDI AV' THEN vr_cdcooper := 16;
              END CASE;

              OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                             ,pr_nrdctitg => vr_conta_old);
              FETCH cr_crapass INTO rw_crapass;
              vr_blnachou := cr_crapass%FOUND;
              CLOSE cr_crapass;

              IF vr_blnachou THEN
                
                vr_conta_old := rw_crapass.nrdctitg;
                
                UPDATE crapass
                   SET crapass.nrdctitg = vr_conta_new
                 WHERE crapass.rowid = rw_crapass.rowid;

                OPEN cr_crapalt(pr_cdcooper => vr_cdcooper
                               ,pr_nrdconta => rw_crapass.nrdconta
                               ,pr_dtaltera => vr_dtaltera);
                FETCH cr_crapalt INTO rw_crapalt;
                vr_blnachou := cr_crapalt%FOUND;
                CLOSE cr_crapalt;
                
                vr_dsaltera := 'Ag.ITG anterior: 3420-7  Ag.ITG nova: 3125-9, ' ||
                               'Conta ITG anterior: ' || vr_conta_old || ' Conta ITG nova: ' || vr_conta_new || ',';
                
                
                IF vr_blnachou THEN

                  UPDATE crapalt SET crapalt.dsaltera = rw_crapalt.dsaltera || vr_dsaltera
                   WHERE crapalt.rowid = rw_crapalt.rowid;

                ELSE

                  INSERT INTO crapalt
                             (crapalt.cdcooper
                             ,crapalt.nrdconta
                             ,crapalt.dtaltera
                             ,crapalt.cdoperad
                             ,crapalt.tpaltera
                             ,crapalt.flgctitg
                             ,crapalt.dsaltera)
                      VALUES (vr_cdcooper
                             ,rw_crapass.nrdconta
                             ,vr_dtaltera
                             ,1
                             ,1
                             ,0
                             ,vr_dsaltera);
                END IF;
                
                /****elton*****/
                
                          
                SELECT NVL(MAX(obs.nrseqdig),0)+1 INTO vr_nrseqdig
                       FROM crapobs obs
                       WHERE cdcooper = vr_cdcooper            AND
                             nrdconta = rw_crapass.nrdconta;
                          
    
                INSERT INTO crapobs (crapobs.cdcooper,
                                     crapobs.nrdconta,
                                     crapobs.nrseqdig,
                                     crapobs.cdoperad,
                                     crapobs.hrtransa,
                                     crapobs.flgprior,
                                     crapobs.dsobserv)
                      VALUES (vr_cdcooper,
                              rw_crapass.nrdconta,
                              vr_nrseqdig,
                              '1',
                              TO_CHAR(SYSDATE,'SSSSS'),
                               0,
                               'Comunique ao cooperado  a alteração do número de agência e conta ITG. ' ||
                               'Verifique com o cooperado se possui algum serviço contratado nesta conta e ' ||
                               'oriente a transferir para a conta mantida na Cooperativa.');
                  

                
                /**************/
                
                gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_sem,
                                               pr_des_text => rw_crapass.nrdconta || ';' || vr_conta_old || ';' || vr_conta_new || ';' || vr_nmcooper);
              ELSE
                gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_com,
                                               pr_des_text => ';' || vr_conta_old || ';' || vr_conta_new || ';' || vr_nmcooper);
              END IF;
            ELSE
              gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_com,
                                             pr_des_text => ';' || vr_conta_old || ';' || vr_conta_new || ';' || vr_nmcooper);
            END IF;

          END IF;
          vr_nrlinha := vr_nrlinha + 1;
        END LOOP;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          -- Fim das linhas do arquivo
          NULL;
      END;
    END IF;
  
  -- Fecha arquivos
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_arq);
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_com);
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_sem);

  --ROLLBACK;
  COMMIT;

END;
0
4
vr_nrlinha
vr_nmcooper
pr_nrdctitg
rw_crapass.nrdconta
