PL/SQL Developer Test script 3.0
365
-- Created on 19/08/2021 by T0032717 
DECLARE
  vr_exc_erro EXCEPTION;
  vr_dscritic crapcri.dscritic%TYPE;

  vr_dados_rollback CLOB; -- Grava update de rollback
  vr_texto_rollback VARCHAR2(32600);
  vr_nmarqbkp       VARCHAR2(100);
  vr_nmdireto       VARCHAR2(4000); 
  vr_progress_recid craplcm.progress_recid%TYPE;
  
  vr_contrato       GENE0002.typ_split;
  vr_dadosctr       GENE0002.typ_split;
  vr_condicao       VARCHAR2(300);
  vr_tabela         VARCHAR2(100);
  
  -- coop;conta;contrato
  vr_pipedados      VARCHAR2(1000) := '10;109207;30131|10;109207;30172'; -- contratos efetivados
  vr_pipedados_ren  VARCHAR2(1000) := '10;109207;30130|10;109207;30171'; -- capas e conteudos
  
  -- Busca lista de inserts para rollback (atentar campos com caracteres especiais no nome)
  CURSOR cr_rollback(pr_condicao IN VARCHAR2
                    ,pr_tabela   IN VARCHAR2) IS
    SELECT 'INSERT INTO ' || table_name || ' (' ||
            RTRIM(XMLQUERY('for $i in ROW/* return concat(name($i),",")' PASSING
                           t.column_value.EXTRACT('ROW') RETURNING content),',') || 
            ') VALUES (' || UTL_I18N.UNESCAPE_REFERENCE(RTRIM(XMLQUERY('for $i in ROW/* return concat("''", $i, "''",",")' PASSING
                           t.column_value.EXTRACT('ROW') RETURNING content),
            ',')) || ');' query_insert
      FROM all_tables,
           XMLTABLE('ROW' PASSING DBMS_XMLGEN.GETXMLTYPE('SELECT * FROM ' || table_name || ' ' || pr_condicao).EXTRACT('ROWSET/ROW')) t
     WHERE UPPER(table_name) = UPPER(pr_tabela);
  rw_rollback cr_rollback%ROWTYPE;
  
  CURSOR cr_crapepr(pr_cdcooper IN crapepr.cdcooper%TYPE
                   ,pr_nrdconta IN crapepr.nrdconta%TYPE
                   ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
    SELECT decode(epr.idfiniof, 1, (epr.vlemprst - nvl(epr.vltarifa,0) - nvl(epr.vliofepr,0)), epr.vlemprst) vlemprst
      FROM crapepr epr 
     WHERE epr.cdcooper = pr_cdcooper 
       AND epr.nrdconta = pr_nrdconta
       AND epr.nrctremp = pr_nrctremp;
  rw_crapepr cr_crapepr%ROWTYPE;
  
  -- Cursor Capa do Lote
  CURSOR cr_craplot(pr_cdcooper IN craplot.cdcooper%TYPE
                   ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                   ,pr_cdagenci IN craplot.cdagenci%TYPE
                   ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                   ,pr_nrdolote IN craplot.nrdolote%TYPE)  IS
  SELECT lot.dtmvtolt
        ,lot.cdagenci
        ,lot.cdbccxlt
        ,lot.nrdolote
        ,NVL(lot.nrseqdig,0) nrseqdig
        ,lot.cdcooper
        ,lot.tplotmov
        ,lot.vlinfodb
        ,lot.vlcompdb
        ,lot.qtinfoln
        ,lot.qtcompln
        ,lot.cdoperad
        ,lot.tpdmoeda
        ,lot.rowid
    FROM craplot lot
   WHERE lot.cdcooper = pr_cdcooper
     AND lot.dtmvtolt = pr_dtmvtolt
     AND lot.cdagenci = pr_cdagenci
     AND lot.cdbccxlt = pr_cdbccxlt
     AND lot.nrdolote = pr_nrdolote;
  rw_craplot cr_craplot%ROWTYPE;  
  
BEGIN
  dbms_output.enable(NULL);
  vr_dados_rollback := NULL;
  dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
  dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);    
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, '-- Programa para rollback das informacoes'||chr(13), FALSE);
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',0,'ROOT_MICROS');
  vr_nmdireto := vr_nmdireto||'cpd/bacas/INC0102315'; 
  vr_nmarqbkp  := 'ROLLBACK_INC0102315_'||to_char(sysdate,'ddmmyyyy_hh24miss')||'.sql';
  
  -- separa registro
  vr_contrato := GENE0002.fn_quebra_string(pr_string  => vr_pipedados
                                          ,pr_delimit => '|'); 
  -- Listagem de contratos selecionados
  FOR vr_idx_lst IN 1..vr_contrato.COUNT LOOP
    -- separa valor
    vr_dadosctr := GENE0002.fn_quebra_string(pr_string  => vr_contrato(vr_idx_lst)
                                            ,pr_delimit => ';'); 
    
    -- grava rollback crawepr
    vr_condicao := 'WHERE cdcooper = ' || vr_dadosctr(1) || ' AND nrdconta = ' || vr_dadosctr(2) || ' AND nrctremp = ' || vr_dadosctr(3);
    vr_tabela   := 'CRAWEPR';
    FOR rw_rollback IN cr_rollback(pr_condicao => vr_condicao
                                  ,pr_tabela   => vr_tabela) LOOP
      -- grava rollback
      gene0002.pc_escreve_xml(vr_dados_rollback
                          , vr_texto_rollback
                          , REPLACE(rw_rollback.query_insert, '_x0023_', '#') || chr(13), FALSE); 
    END LOOP;
    -- grava rollback crapepr
    vr_condicao := 'WHERE cdcooper = ' || vr_dadosctr(1) || ' AND nrdconta = ' || vr_dadosctr(2) || ' AND nrctremp = ' || vr_dadosctr(3);
    vr_tabela   := 'CRAPEPR';
    FOR rw_rollback IN cr_rollback(pr_condicao => vr_condicao
                                  ,pr_tabela   => vr_tabela) LOOP
      -- grava rollback
      gene0002.pc_escreve_xml(vr_dados_rollback
                          , vr_texto_rollback
                          , REPLACE(rw_rollback.query_insert, '_x0023_', '#') || chr(13), FALSE); 
    END LOOP;
    -- grava rollback crapprp
    vr_condicao := 'WHERE cdcooper = ' || vr_dadosctr(1) || ' AND nrdconta = ' || vr_dadosctr(2) || ' AND nrctrato = ' || vr_dadosctr(3);
    vr_tabela   := 'CRAPPRP';
    FOR rw_rollback IN cr_rollback(pr_condicao => vr_condicao
                                  ,pr_tabela   => vr_tabela) LOOP
      -- grava rollback
      gene0002.pc_escreve_xml(vr_dados_rollback
                          , vr_texto_rollback
                          , REPLACE(rw_rollback.query_insert, '_x0023_', '#') || chr(13), FALSE); 
    END LOOP;
    -- grava rollback crappep
    vr_condicao := 'WHERE cdcooper = ' || vr_dadosctr(1) || ' AND nrdconta = ' || vr_dadosctr(2) || ' AND nrctremp = ' || vr_dadosctr(3);
    vr_tabela   := 'CRAPPEP';
    FOR rw_rollback IN cr_rollback(pr_condicao => vr_condicao
                                  ,pr_tabela   => vr_tabela) LOOP
      -- grava rollback
      gene0002.pc_escreve_xml(vr_dados_rollback
                          , vr_texto_rollback
                          , REPLACE(rw_rollback.query_insert, '_x0023_', '#') || chr(13), FALSE); 
    END LOOP;
    -- grava rollback crapris
    vr_condicao := 'WHERE cdcooper = ' || vr_dadosctr(1) || ' AND nrdconta = ' || vr_dadosctr(2) || ' AND nrctremp = ' || vr_dadosctr(3);
    vr_tabela   := 'CRAPRIS';
    FOR rw_rollback IN cr_rollback(pr_condicao => vr_condicao
                                  ,pr_tabela   => vr_tabela) LOOP
      -- grava rollback
      gene0002.pc_escreve_xml(vr_dados_rollback
                          , vr_texto_rollback
                          , REPLACE(rw_rollback.query_insert, '_x0023_', '#') || chr(13), FALSE); 
    END LOOP;
    -- grava rollback crapvri  
    vr_condicao := 'WHERE cdcooper = ' || vr_dadosctr(1) || ' AND nrdconta = ' || vr_dadosctr(2) || ' AND nrctremp = ' || vr_dadosctr(3);
    vr_tabela   := 'CRAPVRI';
    FOR rw_rollback IN cr_rollback(pr_condicao => vr_condicao
                                  ,pr_tabela   => vr_tabela) LOOP
      -- grava rollback
      gene0002.pc_escreve_xml(vr_dados_rollback
                          , vr_texto_rollback
                          , REPLACE(rw_rollback.query_insert, '_x0023_', '#') || chr(13), FALSE); 
    END LOOP;
    -- grava rollback craplem  
    vr_condicao := 'WHERE cdcooper = ' || vr_dadosctr(1) || ' AND nrdconta = ' || vr_dadosctr(2) || ' AND nrctremp = ' || vr_dadosctr(3);
    vr_tabela   := 'CRAPLEM';
    FOR rw_rollback IN cr_rollback(pr_condicao => vr_condicao
                                  ,pr_tabela   => vr_tabela) LOOP
      -- grava rollback
      gene0002.pc_escreve_xml(vr_dados_rollback
                          , vr_texto_rollback
                          , REPLACE(rw_rollback.query_insert, '_x0023_', '#') || chr(13), FALSE); 
    END LOOP;
    
    -- Limpar a crawepr e crapepr
    DELETE FROM crawepr WHERE cdcooper = vr_dadosctr(1) AND nrdconta = vr_dadosctr(2) AND nrctremp = vr_dadosctr(3);
    DELETE FROM crapepr WHERE cdcooper = vr_dadosctr(1) AND nrdconta = vr_dadosctr(2) AND nrctremp = vr_dadosctr(3);
    -- Limpar a crapprp
    DELETE FROM crapprp WHERE cdcooper = vr_dadosctr(1) AND nrdconta = vr_dadosctr(2) AND nrctrato = vr_dadosctr(3);
    -- Limpar a crappep
    DELETE FROM crappep WHERE cdcooper = vr_dadosctr(1) AND nrdconta = vr_dadosctr(2) AND nrctremp = vr_dadosctr(3);
    -- Limpar a crapris e crapvri
    DELETE FROM crapris WHERE cdcooper = vr_dadosctr(1) AND nrdconta = vr_dadosctr(2) AND nrctremp = vr_dadosctr(3);
    DELETE FROM crapvri WHERE cdcooper = vr_dadosctr(1) AND nrdconta = vr_dadosctr(2) AND nrctremp = vr_dadosctr(3);
    -- Limpar a craplem
    DELETE FROM craplem WHERE cdcooper = vr_dadosctr(1) AND nrdconta = vr_dadosctr(2) AND nrctremp = vr_dadosctr(3);
    
  END LOOP;
  
  
  -- Detalhes da renegociacao
  vr_contrato := GENE0002.fn_quebra_string(pr_string  => vr_pipedados_ren
                                          ,pr_delimit => '|'); 
  -- Listagem de contratos selecionados
  FOR vr_idx_lst IN 1..vr_contrato.COUNT LOOP
    
    vr_dadosctr := GENE0002.fn_quebra_string(pr_string  => vr_contrato(vr_idx_lst)
                                            ,pr_delimit => ';'); 
    -- grava rollback tbepr_renegociacao  
    vr_condicao := 'WHERE cdcooper = ' || vr_dadosctr(1) || ' AND nrdconta = ' || vr_dadosctr(2) || ' AND nrctremp = ' || vr_dadosctr(3);
    vr_tabela   := 'TBEPR_RENEGOCIACAO';
    FOR rw_rollback IN cr_rollback(pr_condicao => vr_condicao
                                  ,pr_tabela   => vr_tabela) LOOP
      -- grava rollback
      gene0002.pc_escreve_xml(vr_dados_rollback
                          , vr_texto_rollback
                          , rw_rollback.query_insert || chr(13), FALSE); 
    END LOOP;
    
    -- grava rollback tbepr_renegociacao_contrato  
    vr_condicao := 'WHERE cdcooper = ' || vr_dadosctr(1) || ' AND nrdconta = ' || vr_dadosctr(2) || ' AND nrctremp = ' || vr_dadosctr(3);
    vr_tabela   := 'TBEPR_RENEGOCIACAO_CONTRATO';
    FOR rw_rollback IN cr_rollback(pr_condicao => vr_condicao
                                  ,pr_tabela   => vr_tabela) LOOP
      -- grava rollback
      gene0002.pc_escreve_xml(vr_dados_rollback
                          , vr_texto_rollback
                          , rw_rollback.query_insert || chr(13), FALSE); 
    END LOOP;
    
    -- grava rollback tbepr_renegociacao  
    vr_condicao := 'WHERE cdcooper = ' || vr_dadosctr(1) || ' AND nrdconta = ' || vr_dadosctr(2) || ' AND nrctremp = ' || vr_dadosctr(3);
    vr_tabela   := 'TBEPR_RENEGOCIACAO_SIMULA';
    FOR rw_rollback IN cr_rollback(pr_condicao => vr_condicao
                                  ,pr_tabela   => vr_tabela) LOOP
      -- grava rollback
      gene0002.pc_escreve_xml(vr_dados_rollback
                          , vr_texto_rollback
                          , rw_rollback.query_insert || chr(13), FALSE); 
    END LOOP;
    
    -- grava rollback tbepr_renegociacao_contrato  
    vr_condicao := 'WHERE cdcooper = ' || vr_dadosctr(1) || ' AND nrdconta = ' || vr_dadosctr(2) || ' AND nrctremp = ' || vr_dadosctr(3);
    vr_tabela   := 'TBEPR_RENEGOCIACAO_CONTRATO_SIMULA';
    FOR rw_rollback IN cr_rollback(pr_condicao => vr_condicao
                                  ,pr_tabela   => vr_tabela) LOOP
      -- grava rollback
      gene0002.pc_escreve_xml(vr_dados_rollback
                          , vr_texto_rollback
                          , rw_rollback.query_insert || chr(13), FALSE); 
    END LOOP;
    
    -- Limpa o conteudo da capa - deve ser apagado antes devido a FK
    DELETE FROM tbepr_renegociacao_contrato WHERE cdcooper = vr_dadosctr(1) AND nrdconta = vr_dadosctr(2) AND nrctremp = vr_dadosctr(3);
    -- Limpa a capa
    DELETE FROM tbepr_renegociacao WHERE cdcooper = vr_dadosctr(1) AND nrdconta = vr_dadosctr(2) AND nrctremp = vr_dadosctr(3);
    -- Limpa o conteudo da capa da simulacao - deve ser apagado antes devido a FK
    DELETE FROM tbepr_renegociacao_contrato_simula WHERE cdcooper = vr_dadosctr(1) AND nrdconta = vr_dadosctr(2) AND nrctremp = vr_dadosctr(3);
    -- Limpa a capa da simulacao
    DELETE FROM tbepr_renegociacao_simula WHERE cdcooper = vr_dadosctr(1) AND nrdconta = vr_dadosctr(2) AND nrctremp = vr_dadosctr(3);
    
  END LOOP;

  -- Lancamento para INC0102308
  OPEN cr_crapepr(pr_cdcooper => 12
                 ,pr_nrdconta => 94617
                 ,pr_nrctremp => 35004);
  FETCH cr_crapepr INTO rw_crapepr;
  CLOSE cr_crapepr;
  
  OPEN cr_craplot(pr_cdcooper => 12
                 ,pr_dtmvtolt => '13/08/2021'
                 ,pr_cdagenci => 1
                 ,pr_cdbccxlt => 100
                 ,pr_nrdolote => 8456);
  FETCH cr_craplot INTO rw_craplot;
  -- Apenas Fecha Cursor
  CLOSE cr_craplot;
  
  BEGIN
    INSERT INTO craplcm (cdcooper ,dtmvtolt, cdagenci, cdbccxlt, nrdolote, nrdconta, nrdctabb
       , nrdctitg
       , nrdocmto
       , cdhistor
       , nrseqdig
       , cdpesqbb
       , vllanmto)
    VALUES  
       (12, rw_craplot.dtmvtolt, rw_craplot.cdagenci, rw_craplot.cdbccxlt, rw_craplot.nrdolote, 94617, 94617
       , GENE0002.fn_mask(94617,'99999999')
       , GENE0002.fn_mask(35004 || TO_CHAR(sysdate,'SSSSS') || (nvl(rw_craplot.nrseqdig,0) + 1),'999999999999999') -- rw_crabepr.nrctremp
       , 15 -- CR.EMPRESTIMO
       , nvl(rw_craplot.nrseqdig,0) + 1
       , GENE0002.fn_mask(35004,'99999999')
       , rw_crapepr.vlemprst) RETURNING progress_recid INTO vr_progress_recid;
  EXCEPTION
    WHEN OTHERS THEN
      cecred.pc_internal_exception;
      vr_dscritic := 'Erro ao inserir na tabela craplcm 1 - (15) . ' || SQLERRM;
     --Sair do programa
     RAISE vr_exc_erro;
  END;
  
  -- grava rollback
  gene0002.pc_escreve_xml(vr_dados_rollback
                        , vr_texto_rollback
                        , 'DELETE FROM craplcm WHERE cdcooper = 12 AND nrdconta = 94617 AND cdhistor = 15 AND progress_recid = '||vr_progress_recid||';' || chr(13), FALSE); 
  
  -- Lancamento para INC0102315
  OPEN cr_crapepr(pr_cdcooper => 10
                 ,pr_nrdconta => 109207
                 ,pr_nrctremp => 29935);
  FETCH cr_crapepr INTO rw_crapepr;
  CLOSE cr_crapepr;
  
  OPEN cr_craplot(pr_cdcooper => 10
                 ,pr_dtmvtolt => '16/08/2021'
                 ,pr_cdagenci => 1
                 ,pr_cdbccxlt => 100
                 ,pr_nrdolote => 8456);
  FETCH cr_craplot INTO rw_craplot;
  CLOSE cr_craplot;
  
  BEGIN
    INSERT INTO craplcm (cdcooper ,dtmvtolt, cdagenci, cdbccxlt, nrdolote, nrdconta, nrdctabb
       , nrdctitg
       , nrdocmto
       , cdhistor
       , nrseqdig
       , cdpesqbb
       , vllanmto)
    VALUES  
       (10, rw_craplot.dtmvtolt, rw_craplot.cdagenci, rw_craplot.cdbccxlt, rw_craplot.nrdolote, 109207, 109207
       , GENE0002.fn_mask(109207,'99999999')
       , GENE0002.fn_mask(29935 || TO_CHAR(sysdate,'SSSSS') || (nvl(rw_craplot.nrseqdig,0) + 1),'999999999999999') -- rw_crabepr.nrctremp
       , 15 -- CR.EMPRESTIMO
       , nvl(rw_craplot.nrseqdig,0) + 1
       , GENE0002.fn_mask(29935,'99999999')
       , rw_crapepr.vlemprst) RETURNING progress_recid INTO vr_progress_recid;
  EXCEPTION
    WHEN OTHERS THEN
      cecred.pc_internal_exception;
      vr_dscritic := 'Erro ao inserir na tabela craplcm 2 - (15) . ' || SQLERRM;
     --Sair do programa
     RAISE vr_exc_erro;
  END;

  -- grava rollback
  gene0002.pc_escreve_xml(vr_dados_rollback
                        , vr_texto_rollback
                        , 'DELETE FROM craplcm WHERE cdcooper = 10 AND nrdconta = 109207 AND cdhistor = 15 AND progress_recid = '||vr_progress_recid||';' || chr(13), FALSE); 
  
  -- Adiciona TAG de commit rollback
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'COMMIT;'||chr(13), FALSE);
  -- Fecha o arquivo rollback
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, chr(13), TRUE); 
             
  -- Grava o arquivo de rollback
  GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => 3                             --> Cooperativa conectada
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
  
  COMMIT;
  
  dbms_lob.close(vr_dados_rollback);
  dbms_lob.freetemporary(vr_dados_rollback); 

EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
    raise_application_error(-20100, 'Erro ao apagar contratos - ' || vr_dscritic);
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20100, 'Erro ao apagar contratos - ' || SQLERRM);
end;
0
0
