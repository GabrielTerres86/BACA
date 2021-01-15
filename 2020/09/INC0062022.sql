DECLARE 
 TYPE tContaCartao IS RECORD(cdcooper crawcrd.cdcooper%TYPE
                             ,nrcctitg crawcrd.nrcctitg%TYPE
                             ,nrdconta crawcrd.nrdconta%TYPE
 );
 
 TYPE tTableCartao IS TABLE OF tContaCartao INDEX BY PLS_INTEGER;
 
 vListaContaCartao tTableCartao;
 vr_dados_rollback CLOB; -- Grava update de rollback
 vr_texto_rollback VARCHAR2(32600); 
 vr_nmarqbkp       VARCHAR2(100);
 vr_nmdireto       VARCHAR2(4000); 
 vr_dscritic       crapcri.dscritic%TYPE;
 vr_exc_erro       EXCEPTION;
  -- Validacao de diretorio
  PROCEDURE pc_valida_direto(pr_nmdireto IN VARCHAR2
                             ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
  BEGIN
    DECLARE
      vr_dscritic crapcri.dscritic%TYPE;
      vr_typ_saida VARCHAR2(3);
      vr_des_saida VARCHAR2(1000);      
    BEGIN
        -- Primeiro garantimos que o diretorio exista
        IF NOT gene0001.fn_exis_diretorio(pr_nmdireto) THEN
          -- Efetuar a criação do mesmo
          gene0001.pc_OSCommand_Shell(pr_des_comando => 'mkdir ' || pr_nmdireto || ' 1> /dev/null'
                                      ,pr_typ_saida  => vr_typ_saida
                                      ,pr_des_saida  => vr_des_saida);
          --Se ocorreu erro dar RAISE
          IF vr_typ_saida = 'ERR' THEN
             vr_dscritic := 'CRIAR DIRETORIO ARQUIVO --> Nao foi possivel criar o diretorio para gerar os arquivos. ' || vr_des_saida;
             RAISE vr_exc_erro;
          END IF;
          -- Adicionar permissão total na pasta
          gene0001.pc_OSCommand_Shell(pr_des_comando => 'chmod 777 ' || pr_nmdireto || ' 1> /dev/null'
                                      ,pr_typ_saida  => vr_typ_saida
                                      ,pr_des_saida  => vr_des_saida);
          --Se ocorreu erro dar RAISE
          IF vr_typ_saida = 'ERR' THEN
             vr_dscritic := 'PERMISSAO NO DIRETORIO --> Nao foi possivel adicionar permissao no diretorio dos arquivos. ' || vr_des_saida;
             RAISE vr_exc_erro;
          END IF;
        END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
    END;    
  END; 
  
  function fRecord(pCDCOOPER number, pNRCCTITG number, pNRDCONTA number) return tContaCartao is
    vRet tContaCartao;
  Begin
    vRet.CDCOOPER := pCDCOOPER;
    vRet.NRCCTITG := pNRCCTITG;
    vRet.NRDCONTA := pNRDCONTA;
    return vRet;
  ENd;
   
BEGIN
  --Inicializando relação de contas
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(16, 7564420016688, 246166);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(16, 7564420023534, 310590);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(16, 7564420058966, 713163);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(16, 7564420061095, 636940);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(13, 7564457021448, 194069);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(13, 7564457033552, 460931);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(5, 7563318002346, 105627);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(2, 7563265026497, 746550);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239145920, 6188958);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239444519, 7362412);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239476792, 10493603);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239482532, 10313184);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239492304, 8008213);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239504412, 10700820);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239504515, 10702172);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239514296, 3837300);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239517199, 10795928);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239521605, 10832211);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239521955, 10834397);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239524633, 10855980);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239533238, 10920285);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239533568, 10922539);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239535932, 3237028);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239537123, 10928995);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239537285, 10945857);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239537306, 10952683);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239537995, 10958916);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239540961, 2836106);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239544711, 11005963);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239549126, 11024097);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239557572, 11116994);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239558872, 9489711);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239563729, 11166851);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239564102, 9468935);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239566204, 11189290);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239577561, 9235841);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239579146, 7444214);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239579639, 11305347);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239582315, 11212292);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239583746, 11338350);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239586703, 10185771);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239587180, 11369620);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239587310, 11303255);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239589396, 11390344);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239589473, 7873719);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239589904, 2302055);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239590026, 11395583);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239590821, 10179984);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239590948, 11365854);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239592417, 11416459);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239593440, 11425768);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239593842, 2829258);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239595968, 11448679);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239596776, 3197590);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239598788, 11473380);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239600430, 11490381);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239601252, 9422633);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239608405, 11560207);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239609799, 11573090);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239610846, 6686486);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239611307, 11586451);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239612358, 11595027);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239616111, 9890670);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239616858, 11633506);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239624119, 11698560);
  vListaContaCartao(nvl(vListaContaCartao.last,0)+1) := fRecord(1, 7563239624668, 11703300);
  vr_nmdireto  := gene0001.fn_diretorio(pr_tpdireto => 'C' 
                                        ,pr_cdcooper => 3);
  pc_valida_direto(pr_nmdireto => vr_nmdireto || '/INC0062022'
                   ,pr_dscritic => vr_dscritic);
    
  IF TRIM(vr_dscritic) IS NOT NULL THEN
     RAISE vr_exc_erro;
  END IF;    
  
  vr_nmdireto := vr_nmdireto || '/INC0062022';                                    
  vr_dados_rollback := NULL;
  dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
  dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);       
    
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, '-- Programa para rollback das informacoes'||chr(13), FALSE);
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'BEGIN'||chr(13), FALSE);
    
  vr_nmarqbkp  := 'ROLLBACK_INC0062022'||to_char(sysdate,'hh24miss')||'.sql';                                          
                                             
  -- Percorremos as conta cartoes invalidas
  FOR idx IN vListaContaCartao.FIRST .. vListaContaCartao.LAST LOOP
      -- 
      FOR reg IN (SELECT * 
                    FROM tbcrd_conta_cartao cc 
                   WHERE cc.cdcooper = vListaContaCartao(idx).cdcooper 
                     AND cc.nrdconta = vListaContaCartao(idx).nrdconta 
                     AND cc.nrconta_cartao = vListaContaCartao(idx).nrcctitg) LOOP
                     
        FOR proposta IN (SELECT w.nrcrcard
                                 ,w.nrcctitg
                                 ,w.insitcrd
                                 ,w.nrctrcrd
                           FROM crawcrd w 
                          WHERE w.cdcooper = vListaContaCartao(idx).cdcooper
                            AND w.nrdconta = vListaContaCartao(idx).nrdconta
                            AND w.nrcctitg = vListaContaCartao(idx).nrcctitg) LOOP
        
              --alterar registro
              UPDATE crawcrd
                 SET nrcrcard = 0
                     ,nrcctitg = 0
                     ,insitcrd = 6
               WHERE cdcooper = vListaContaCartao(idx).cdcooper
                 AND nrdconta = vListaContaCartao(idx).nrdconta
                 AND nrcctitg = vListaContaCartao(idx).nrcctitg;
              --rolback
              gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 
                                                         'UPDATE crawcrd'||chr(13)||
                                                         '   SET nrcrcard = '|| proposta.nrcrcard ||chr(13)||
                                                         '      ,nrcctitg = '|| proposta.nrcctitg ||chr(13)||
                                                         '      ,insitcrd = '|| proposta.insitcrd ||chr(13)||
                                                         ' WHERE cdcooper = '|| vListaContaCartao(idx).cdcooper ||chr(13)||
                                                         '   AND nrdconta = '|| vListaContaCartao(idx).nrdconta ||CHR(13)||
                                                         '   AND nrctrcrd = '|| proposta.nrctrcrd ||';'||chr(13), FALSE); 
        END LOOP;
        --rolback
        gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 
                                                 'INSERT INTO tbcrd_conta_cartao (cdcooper, nrdconta, nrconta_cartao) values'||chr(13)||
                                                 '   ('||vListaContaCartao(idx).cdcooper||','||vListaContaCartao(idx).nrdconta||','||vListaContaCartao(idx).nrcctitg||');'||chr(13), FALSE);        
                                                   
        FOR reg_alerta_atranso IN (SELECT al.rowid
                                          ,al.qtdias_atraso
                                          ,to_char(al.vlsaldo_devedor,'9999999999999999999999999.99') vlsaldo_devedor
                                     FROM tbcrd_alerta_atraso al
                                    WHERE al.cdcooper = vListaContaCartao(idx).cdcooper
                                      AND al.nrdconta = vListaContaCartao(idx).nrdconta
                                      AND al.nrconta_cartao = vListaContaCartao(idx).nrcctitg) LOOP
          --rolback
          gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 
                                                   'INSERT INTO tbcrd_alerta_atraso (cdcooper, nrdconta, nrconta_cartao, qtdias_atraso, vlsaldo_devedor) values'||chr(13)||
                                                   '   ('||vListaContaCartao(idx).cdcooper||','
                                                         ||vListaContaCartao(idx).nrdconta||','
                                                         ||vListaContaCartao(idx).nrcctitg||','
                                                         ||reg_alerta_atranso.qtdias_atraso||','
                                                         ||reg_alerta_atranso.vlsaldo_devedor||');'||chr(13), FALSE);
          --excluir registro                                               
          DELETE tbcrd_alerta_atraso al 
           WHERE al.rowid = reg_alerta_atranso.rowid; 
        END LOOP;                                                          
                                                                   
        --excluir registro
        DELETE tbcrd_conta_cartao cc                                                      
         WHERE cc.cdcooper = vListaContaCartao(idx).cdcooper
           AND cc.nrdconta = vListaContaCartao(idx).nrdconta
           AND cc.nrconta_cartao = vListaContaCartao(idx).nrcctitg;
         
        
      END LOOP;  
      --
  END LOOP; 
  -- Adiciona TAG de commit 
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'COMMIT;'||chr(13), FALSE);
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'END;'||chr(13), FALSE);    
    
  -- Fecha o arquivo          
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, chr(13), TRUE);      
    
  -- Grava o arquivo de rollback
  GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => 3                               --> Cooperativa conectada
                                       ,pr_cdprogra  => 'ATENDA'                      --> Programa chamador - utilizamos apenas um existente 
                                       ,pr_dtmvtolt  => trunc(SYSDATE)                --> Data do movimento atual
                                       ,pr_dsxml     => vr_dados_rollback             --> Arquivo XML de dados
                                       ,pr_dsarqsaid => vr_nmdireto||'/'||vr_nmarqbkp --> Path/Nome do arquivo PDF gerado
                                       ,pr_flg_impri => 'N'                           --> Chamar a impressão (Imprim.p)
                                       ,pr_flg_gerar => 'S'                           --> Gerar o arquivo na hora
                                       ,pr_flgremarq => 'N'                           --> remover arquivo apos geracao
                                       ,pr_nrcopias  => 1                             --> Número de cópias para impressão
                                       ,pr_des_erro  => vr_dscritic);                 --> Retorno de Erro
        
  IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
  END IF;    
                                                     
  -- Liberando a memória alocada pro CLOB    
  dbms_lob.close(vr_dados_rollback);
  dbms_lob.freetemporary(vr_dados_rollback);   
  
  -- Efetuamos a transação  
  COMMIT; 
END;
