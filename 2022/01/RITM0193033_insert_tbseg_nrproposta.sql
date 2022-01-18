DECLARE

  vr_nmarqmov VARCHAR2(200) := 'IP_0464_20211214193019_1442066.txt';
  vr_listadir VARCHAR2(4000);
  
  vr_rootmicros VARCHAR2(200) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_diretorio  VARCHAR2(200) := vr_rootmicros|| 'cpd/bacas/RITM0193033';
  
  vr_cdcritic           crapcri.cdcritic%TYPE;
  vr_tab_nmarqtel       GENE0002.typ_split;
  vr_arqhandle          utl_file.file_type; 
  vr_dslinharq          VARCHAR2(4000);
  vr_dscritic           VARCHAR2(4000) := '';
  vr_exc_sem_arq        EXCEPTION;            -- Tratamento de erros
  vr_exc_saida          EXCEPTION;
  
  TYPE vr_tab_tbseg_nrproposta IS TABLE OF tbseg_nrproposta%ROWTYPE INDEX BY BINARY_INTEGER;
  typ_tab_tbseg_nrproposta vr_tab_tbseg_nrproposta;
  vr_id_nrproposta NUMBER := 0; 
  
  CURSOR cr_tbseg_nrproposta(pr_nrproposta tbseg_nrproposta.nrproposta%TYPE) IS
    SELECT 1
      FROM tbseg_nrproposta 
     WHERE nrproposta = pr_nrproposta;
    rw_tbseg_nrproposta cr_tbseg_nrproposta%ROWTYPE;
	
BEGIN

    gene0001.pc_lista_arquivos(pr_path     => vr_diretorio  --Listar arquivos no diretorio
                              ,pr_pesq     => vr_nmarqmov
                              ,pr_listarq  => vr_listadir
                              ,pr_des_erro => vr_dscritic);

    IF vr_dscritic IS NOT NULL THEN                                       --Se ocorreu erro
      RAISE vr_exc_saida;                                                 --Levantar Excecao
    END IF;
  
    vr_tab_nmarqtel:= GENE0002.fn_quebra_string(pr_string => vr_listadir);  --Montar vetor com nomes dos arquivos

    IF vr_tab_nmarqtel.COUNT <= 0 THEN                                    --Se nao encontrou arquivos
      vr_cdcritic := 182;                                                 -- Montar mensagem de critica
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)  ||
                     ' - caminho:' || vr_diretorio ||
                     ', nome:'     || vr_nmarqmov;

      RAISE vr_exc_sem_arq;
    END IF;

    FOR idx IN 1..vr_tab_nmarqtel.COUNT LOOP                                -- Leitura dos arquivos do diretorio

      vr_nmarqmov := vr_tab_nmarqtel(idx);

      gene0001.pc_abre_arquivo(pr_nmdireto => vr_diretorio||'/'          -- Efetuar abertura do arquivo
                              ,pr_nmarquiv => vr_nmarqmov               --vr_tab_nmarqtel(idx)
                              ,pr_tipabert => 'R'
                              ,pr_utlfileh => vr_arqhandle
                              ,pr_des_erro => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN                                   -- Em caso de problema na abertura do arquivo
        vr_dscritic := 'Erro na abertura do arquivo --> ' || vr_diretorio||'/'||vr_nmarqmov|| ' --> ' ||vr_dscritic;
        RAISE vr_exc_saida;
      END IF;

      LOOP
        BEGIN
          vr_cdcritic := 0;
          
          BEGIN
            gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_arqhandle            -- Leitura linha a linha
                                        ,pr_des_text => vr_dslinharq);
          EXCEPTION 
            WHEN OTHERS THEN
              vr_dslinharq := '';
          END;      
                                                 
          IF NVL(TRIM(vr_dslinharq),' ') = ' ' THEN
            EXIT;
          END IF;
          -- Gerando ID do Array
          vr_id_nrproposta := typ_tab_tbseg_nrproposta.count + 1;

          typ_tab_tbseg_nrproposta(vr_id_nrproposta).nrproposta := TRIM(SUBSTR(vr_dslinharq,1,12));
                    
          CONTINUE; -- Pular ao próximo registro
        EXCEPTION
          WHEN vr_exc_saida THEN
            IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN   -- Buscar descrição da critica
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          END IF;
        END;
      END LOOP; 
      
      gene0001.pc_fecha_arquivo(vr_arqhandle);       -- Fechar handle do arquivo pendente

      -- INSERINDO AS INFORMAÇÕES LIDAS DO ARQUIVO NA TABELA
      IF vr_id_nrproposta > 0 AND vr_dscritic IS NULL THEN
        FOR vr_ind IN typ_tab_tbseg_nrproposta.FIRST .. typ_tab_tbseg_nrproposta.LAST LOOP
          OPEN cr_tbseg_nrproposta(typ_tab_tbseg_nrproposta(vr_ind).nrproposta);
            FETCH cr_tbseg_nrproposta
            INTO rw_tbseg_nrproposta;
          IF cr_tbseg_nrproposta%NOTFOUND THEN
            BEGIN
              INSERT INTO tbseg_nrproposta(nrproposta)
                                    VALUES(typ_tab_tbseg_nrproposta(vr_ind).nrproposta);  
              typ_tab_tbseg_nrproposta.delete(vr_ind);
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := ' Ao inserir na tbseg_nrproposta --> '|| SQLERRM;
                CLOSE cr_tbseg_nrproposta;
                RAISE vr_exc_saida;
            END;
          END IF;
          CLOSE cr_tbseg_nrproposta;
        END LOOP;
      END IF;  
      
    END LOOP;
    COMMIT;

EXCEPTION
  WHEN OTHERS THEN NULL;
END;