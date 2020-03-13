--RITM006544 - Miguel - 13/03/2020 -- Credicomin
DECLARE 
 
  vr_arq_path  VARCHAR2(1000):= gene0001.fn_diretorio(pr_tpdireto => 'M', 
                                                      pr_cdcooper => 0, 
                                                      pr_nmsubdir => 'cpd/bacas/ritm006544/credicomin'); 


  vr_nmarquiv  VARCHAR2(100) := 'Credicomin_ITG.txt';
  vr_nmarqbkp  VARCHAR2(100) := 'ROLLBACK_Credicomin_ITG.txt';

  vr_hutlfile utl_file.file_type;
  vr_dstxtlid VARCHAR2(1000);
  vr_txtauxil VARCHAR2(200); -- Texto auxiliar
  
  vr_contador INTEGER := 0;

  vr_des_xml         CLOB;
  vr_texto_completo  VARCHAR2(32600);
  
  vr_nrdconta crapass.nrdconta%TYPE;

  vr_dscritic crapcri.dscritic%TYPE;
  vr_exc_erro EXCEPTION;

  CURSOR cr_crapass (pr_nrdconta crapass.nrdconta%TYPE) IS
    SELECT cdcooper, nrdconta, nrdctitg, flgctitg
    FROM   CRAPASS 
    WHERE  cdcooper = 10  --Credicomin
    AND    nrdconta = pr_nrdconta
    AND    flgctitg <> 3;

    rw_crapass     cr_crapass%rowtype;
    vr_qtdcta      NUMBER := 0;

  PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                           pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
  END;

BEGIN 

  -- Inicializar o CLOB
  vr_des_xml := NULL;
  dbms_lob.createtemporary(vr_des_xml, TRUE);
  dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
  vr_texto_completo := NULL;
  
  -- Efetuar abertura do arquivo para processamento
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_arq_path   --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarquiv   --> Nome do arquivo
                          ,pr_tipabert => 'R'           --> Modo de abertura (R,W,A)
                          ,pr_utlfileh => vr_hutlfile   --> Handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic); --> Erro
                          
  IF vr_dscritic IS NOT NULL THEN
    --Levantar Excecao
    vr_dscritic := 'Erro na leitura do arquivo --> '||vr_dscritic;
    dbms_output.put_line(vr_dscritic);
    RAISE vr_exc_erro;
  END IF;  
  
  --Verifica se o arquivo esta aberto
  IF utl_file.IS_OPEN(vr_hutlfile) THEN
    BEGIN   
      -- Laço para efetuar leitura de todas as linhas do arquivo 
      LOOP  
        -- Leitura da linha x
        gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_hutlfile --> Handle do arquivo aberto
                                    ,pr_des_text => vr_dstxtlid); --> Texto lido
        
        vr_contador := vr_contador + 1;
        
        -- Ignorar linhas vazias
        IF length(vr_dstxtlid) <= 1 THEN 
          continue;
        END IF;

        -- Efetuar leitura da conta no arquivo
        BEGIN
          vr_dstxtlid := REPLACE(REPLACE(vr_dstxtlid,CHR(10)),CHR(13));                                   
          vr_nrdconta := TO_NUMBER(vr_dstxtlid);                                                  
        EXCEPTION
          WHEN OTHERS THEN
            cecred.pc_internal_exception;
            vr_dscritic := 'Erro na leitura do arquivo na linha: '||vr_contador||' --> '||vr_txtauxil;  
            dbms_output.put_line(vr_dscritic);            
            RAISE vr_exc_erro;
        END;
        
        -- Busca a conta na crapass
        FOR rw_crapass IN cr_crapass(pr_nrdconta => vr_nrdconta) LOOP
          vr_qtdcta := vr_qtdcta + 1;
          BEGIN
            --Atualiza status da conta ITG
            UPDATE CRAPASS
            SET    flgctitg = 3
            WHERE  cdcooper = rw_crapass.cdcooper
            AND    nrdconta = rw_crapass.nrdconta;
             
            pc_escreve_xml('UPDATE CRAPASS '||
                              'SET flgctitg = ' ||rw_crapass.flgctitg||
                           ' WHERE cdcooper = ' ||rw_crapass.cdcooper||
                           '   AND nrdconta = '||rw_crapass.nrdconta||';'||chr(10));        

          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar crapass na linha: '||vr_contador||' '|| SQLERRM;
              dbms_output.put_line(vr_dscritic);
              RAISE vr_exc_erro;
          END;                                    

          BEGIN
            --Inclui log de alteração da conta ITG
            INSERT INTO crapalt 
              (nrdconta
              ,dtaltera
              ,cdoperad
              ,dsaltera
              ,tpaltera
              ,flgctitg
              ,cdcooper)
            VALUES
              (rw_crapass.nrdconta
              ,sysdate
              ,1
              ,'exclusao conta-itg('||rw_crapass.nrdctitg||')- ope.1'
              ,2 
              ,0  --nao enviada
              ,rw_crapass.cdcooper);
          END;
                                    
        END LOOP;
         
      END LOOP; --Fim loop arquivo

      COMMIT;

    EXCEPTION 
      WHEN no_data_found THEN 
        dbms_output.put_line('Qtde contas lidas:'||vr_contador);
        dbms_output.put_line('Qtde contas atualizadas:'||vr_qtdcta);
        
        pc_escreve_xml('COMMIT;');
        pc_escreve_xml(' ',TRUE);

        -- fechar arquivo
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_hutlfile);
        dbms_output.put_line('Arquivo fechado');

        -- Tansforma em arquivo de bkp
        DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_xml, vr_arq_path, vr_nmarqbkp, NLS_CHARSET_ID('UTF8'));
        dbms_output.put_line('Gerado arquivo Bkp');

        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_des_xml);
        dbms_lob.freetemporary(vr_des_xml);
        dbms_output.put_line('Liberado memoria e finalizado processo');
      WHEN OTHERS THEN
        dbms_output.put_line('Erro inesperado 1 ' || SQLERRM);
        cecred.pc_internal_exception;
    END;
  END IF;  
  
  COMMIT;
  
EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
  WHEN OTHERS THEN
    dbms_output.put_line('Erro inesperado 2' || SQLERRM);    
    cecred.pc_internal_exception;
    ROLLBACK;
END;
