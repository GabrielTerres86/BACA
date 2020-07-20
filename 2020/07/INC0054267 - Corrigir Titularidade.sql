DECLARE
  -- Local variables here
  vr_cdcooper   crapcop.cdcooper%TYPE;
  vr_nome_baca  VARCHAR2(100);
  vr_nmarqlog   VARCHAR2(100);
  vr_nmarqimp   VARCHAR2(100);
  vr_nmarqbkp   VARCHAR2(100);
  vr_nmdireto   VARCHAR2(4000); 
  vr_dscritic   crapcri.dscritic%TYPE;
  vr_exc_erro   EXCEPTION; 
  vr_dados_rollback CLOB; -- Grava update de rollback
  vr_texto_rollback VARCHAR2(32600);
  aux_flgprcrd crawcrd.flgprcrd%type;
  vr_pasta varchar2(100) := 'INC0054267';
  
  -- Cursores
  
  CURSOR cr_crapcop IS 
    SELECT c.cdcooper
           ,c.dsdircop
      FROM crapcop c;
  rw_crapcop cr_crapcop%ROWTYPE;
  
  CURSOR cr_cartoes(pr_cdcooper crapcop.cdcooper%TYPE) IS
    select a.progress_recid, a.nrdconta, a.cdcooper, a.nrctrcrd, a.flgprcrd, b.inpessoa, a.nrcpftit, a.cdadmcrd, a.rowid rid_cartao
               from crawcrd a,
                    crapass b
              where a.nrdconta = b.nrdconta
                and a.cdcooper = b.cdcooper
                and b.CDSITDCT = 1
                and a.insitcrd != 6
                and a.cdadmcrd between 11 and 17
                AND a.cdcooper = pr_cdcooper
                and b.inpessoa != 2
               order by a.cdcooper, a.dtpropos desc, a.nrdconta, a.progress_recid;
  rw_cartoes cr_cartoes%ROWTYPE;
   
  -- Sub procedures  
  
  --é o titular?
  function fPrimeiroCartao(pCdcooper crawcrd.cdcooper%type, 
                           pNrdconta crawcrd.nrdconta%type, 
                           pCdadmcrd crawcrd.cdadmcrd%type,
                           pNrcpftit crawcrd.nrcpftit%type,
                           pInpessoa crapass.inpessoa%type,
                           pNrctrcrd crawcrd.nrctrcrd%type) return crawcrd.flgprcrd%type is
    aux_flgprcrd crawcrd.flgprcrd%type;
  Begin
    aux_flgprcrd := 1;
    --busca o primeiro cartão
    for pc in (select *
                 from crawcrd a
                where a.cdcooper = pCdcooper
                  and a.nrdconta = pNrdconta
                  and a.cdadmcrd = pCdadmcrd
                  and a.flgprcrd = 1
                 order by a.progress_recid)
    loop
      if (pc.nrcpftit = pNrcpftit or (pInpessoa = 2 and pc.nrctrcrd = pNrctrcrd)) then
        aux_flgprcrd := 1;
      else
        aux_flgprcrd := 0;  
      end if;
      exit;
    end loop;
    return aux_flgprcrd;
  End;  

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

  vr_nmdireto  := gene0001.fn_diretorio(pr_tpdireto => 'C' 
                                          ,pr_cdcooper => 3);

  -- Primeiro criamos o diretorio da INC, dentro de um diretorio ja existente
  pc_valida_direto(pr_nmdireto => vr_nmdireto || '/'||vr_pasta
                     ,pr_dscritic => vr_dscritic);

  IF TRIM(vr_dscritic) IS NOT NULL THEN
     RAISE vr_exc_erro;
  END IF;     
  
  vr_nmdireto := vr_nmdireto || '/'||vr_pasta;
                                             
  FOR rw_crapcop IN cr_crapcop LOOP  
    vr_dados_rollback := NULL;

    dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
    dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);       
    
    gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, '-- Programa para rollback das informacoes'||chr(13), FALSE);
    gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'BEGIN'||chr(13), FALSE);
    
    vr_cdcooper  := rw_crapcop.cdcooper;
    
    vr_nmarqbkp  := 'BKP_'||upper(rw_crapcop.dsdircop)||''||to_char(sysdate,'hh24miss')||'.sql';
                   
    -- Percorrer todas as contas para gerar o arquivo de rollback
    FOR rw_cartoes IN cr_cartoes(vr_cdcooper) LOOP
        aux_flgprcrd := fPrimeiroCartao(rw_cartoes.cdcooper, rw_cartoes.nrdconta, rw_cartoes.cdadmcrd, rw_cartoes.nrcpftit, rw_cartoes.inpessoa, rw_cartoes.nrctrcrd);
        if (rw_cartoes.flgprcrd != aux_flgprcrd) then

          update crawcrd a
             set a.flgprcrd = aux_flgprcrd
           where a.progress_recid = rw_cartoes.progress_recid; 
           
          gene0002.pc_escreve_xml(vr_dados_rollback
                                 , vr_texto_rollback
                                 , 'UPDATE crawcrd w ' || chr(13) || 
                                   '   SET w.flgprcrd = ' || rw_cartoes.flgprcrd || chr(13) ||
                                   ' WHERE w.progress_recid = ' || rw_cartoes.progress_recid  || '; ' ||chr(13)||chr(13), FALSE);                                   
           
           
        end if;
    
    END LOOP;
                    
    -- Adiciona TAG de commit 
    gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'COMMIT;'||chr(13), FALSE);
    gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'END;'||chr(13), FALSE);    
    
    -- Fecha o arquivo          
    gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, chr(13), TRUE);      
    
    -- Grava o arquivo de rollback
    GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => vr_cdcooper                     --> Cooperativa conectada
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
      
  END LOOP;  
  
  -- Efetuamos a transação  
  COMMIT;
  
EXCEPTION
  WHEN vr_exc_erro THEN
    raise_application_error(-20111, vr_dscritic);
END;
