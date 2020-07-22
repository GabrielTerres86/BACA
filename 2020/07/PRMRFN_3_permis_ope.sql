-- Created on 21/07/2020 by T0032717 
DECLARE
  CURSOR cr_crapcop IS
    SELECT cdcooper
      FROM crapcop
     WHERE flgativo = 1;
  rw_crapcop cr_crapcop%ROWTYPE;

  vr_exc_erro EXCEPTION;
  vr_dscritic crapcri.dscritic%TYPE;

  vr_cddopcao_nova VARCHAR(50) := '@,C,H,D'; -- opcoes/permissoes da tela que serao adicionadas
  -- Operadores a serem permitidos
  vr_operadores VARCHAR2(2000) := 'f0030689,f0030516,f0032113,f0020517,f0032005,f0030835';

  vr_nmdatela VARCHAR(10) := 'PRMRFN'; -- tela que serao liberadas as permissoes

  vr_lista     GENE0002.typ_split;
  vr_lista_ope GENE0002.typ_split;
  
  vr_dados_rollback CLOB; -- Grava update de rollback
  vr_texto_rollback VARCHAR2(32600);
  vr_nmarqbkp       VARCHAR2(100);
  vr_nmdireto       VARCHAR2(4000); 
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
BEGIN

  vr_lista     := GENE0002.fn_quebra_string(pr_string => vr_cddopcao_nova, pr_delimit => ',');
  vr_lista_ope := GENE0002.fn_quebra_string(pr_string => vr_operadores, pr_delimit => ',');

  FOR vr_idx_lst IN 1 .. vr_lista.COUNT LOOP
    FOR vr_idx_ope IN 1 .. vr_lista_ope.COUNT LOOP
      FOR rw_crapcop IN cr_crapcop LOOP
        INSERT INTO CRAPACE
          (NMDATELA,
           CDDOPCAO,
           CDOPERAD,
           NMROTINA,
           CDCOOPER,
           NRMODULO,
           IDEVENTO,
           IDAMBACE)
        VALUES
          (vr_nmdatela,
           vr_lista(vr_idx_lst),
           vr_lista_ope(vr_idx_ope),
           ' ',
           rw_crapcop.cdcooper,
           1,
           1,
           1);
      
        INSERT INTO CRAPACE
          (NMDATELA,
           CDDOPCAO,
           CDOPERAD,
           NMROTINA,
           CDCOOPER,
           NRMODULO,
           IDEVENTO,
           IDAMBACE)
        VALUES
          (vr_nmdatela,
           vr_lista(vr_idx_lst),
           vr_lista_ope(vr_idx_ope),
           ' ',
           rw_crapcop.cdcooper,
           1,
           1,
           2);
      END LOOP;
    END LOOP;
  END LOOP;
  COMMIT;
  
  vr_dados_rollback := NULL;
  dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
  dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);    
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, '-- Programa para rollback das informacoes'||chr(13), FALSE);
    
  vr_nmdireto := gene0001.fn_param_sistema('CRED',0,'ROOT_MICROS');
    
  -- Depois criamos o diretorio do projeto
  pc_valida_direto(pr_nmdireto => vr_nmdireto || 'cpd/bacas'
                  ,pr_dscritic => vr_dscritic);
      
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;  
    
  -- Depois criamos o diretorio do projeto
  pc_valida_direto(pr_nmdireto => vr_nmdireto || 'cpd/bacas/RDM0035715'
                  ,pr_dscritic => vr_dscritic);
      
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;  
    
  vr_nmdireto := vr_nmdireto||'cpd/bacas/RDM0035715'; 
  vr_nmarqbkp  := 'RDM0035715_Rollback'||to_char(sysdate,'ddmmyyyy_hh24miss')||'.sql';
    
  -- rollback
  gene0002.pc_escreve_xml(vr_dados_rollback
                        , vr_texto_rollback
                        , 'DELETE FROM crapaca ' || chr(13) || 
                          ' WHERE nmdeacao = ''BUSCA_CONTAS_PRMRFN''; ' ||chr(13)||chr(13), FALSE);    
    
  gene0002.pc_escreve_xml(vr_dados_rollback
                        , vr_texto_rollback
                        , 'DELETE FROM crapaca ' || chr(13) || 
                          ' WHERE nmdeacao = ''HAB_CONTA_PRMRFN''; ' ||chr(13)||chr(13), FALSE);    
                            
  gene0002.pc_escreve_xml(vr_dados_rollback
                        , vr_texto_rollback
                        , 'DELETE FROM crapaca ' || chr(13) || 
                          ' WHERE nmdeacao = ''DES_CONTA_PRMRFN''; ' ||chr(13)||chr(13), FALSE);    
                            
  gene0002.pc_escreve_xml(vr_dados_rollback
                        , vr_texto_rollback
                        , 'DELETE FROM crapaca ' || chr(13) || 
                          ' WHERE nmdeacao = ''VALIDA_CONTA_PRMRFN''; ' ||chr(13)||chr(13), FALSE);    
                            
  gene0002.pc_escreve_xml(vr_dados_rollback
                        , vr_texto_rollback
                        , 'DELETE FROM craptel ' || chr(13) || 
                          ' WHERE nmdatela = ''PRMRFN''; ' ||chr(13)||chr(13), FALSE);        

  gene0002.pc_escreve_xml(vr_dados_rollback
                        , vr_texto_rollback
                        , 'DELETE FROM crapprg ' || chr(13) || 
                          ' WHERE cdprogra = ''PRMRFN''; ' ||chr(13)||chr(13), FALSE);        

  gene0002.pc_escreve_xml(vr_dados_rollback
                        , vr_texto_rollback
                        , 'DELETE FROM craprdr ' || chr(13) || 
                          ' WHERE nmprogra = ''TELA_PRMRFN''; ' ||chr(13)||chr(13), FALSE);      

  gene0002.pc_escreve_xml(vr_dados_rollback
                        , vr_texto_rollback
                        , 'DELETE FROM crapace ' || chr(13) || 
                          ' WHERE nmdatela = ''PRMRFN'' AND cdoperad IN (''f0030689'',
                                                                         ''f0030516'',
                                                                         ''f0032113'',
                                                                         ''f0020517'',
                                                                         ''f0032005'',
                                                                         ''f0030835''); ' ||chr(13)||chr(13), FALSE);     

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
  
  dbms_lob.close(vr_dados_rollback);
  dbms_lob.freetemporary(vr_dados_rollback); 
  COMMIT;
END;
