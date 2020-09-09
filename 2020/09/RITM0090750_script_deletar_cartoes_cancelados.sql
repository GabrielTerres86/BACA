-- Created on 26/08/2020 by T0032613 
DECLARE
  -- definicao da pltable para os registros
  TYPE typ_reg_cartoes_cancelados IS RECORD(
       cdagebcb crapcop.cdagebcb%TYPE
       ,nrcpfcgc crapass.nrcpfcgc%TYPE
       ,nrcctitg crawcrd.nrcctitg%TYPE
       ,nrcrcard VARCHAR2(500)
  );  
  /* Tipo de tabela de cartoes cancelados */
  TYPE typ_tab_cartoes_cancelados IS TABLE OF typ_reg_cartoes_cancelados INDEX BY PLS_INTEGER;
    
  -- Variaveis
  vr_direxcel VARCHAR2(500);
  vr_nmrquivo VARCHAR2(500);
  vr_listarqs VARCHAR2(2000);
  vr_dscritic crapcri.dscritic%TYPE;
  vr_idprglog tbgen_prglog.idprglog%TYPE := NULL;
  vr_cdprogra VARCHAR2(500) := 'RITM0090750';
  vr_crdcancl typ_tab_cartoes_cancelados;
  vr_nprocess typ_tab_cartoes_cancelados; -- Guarda registros nao processados
  vrp_typ_saida  VARCHAR2(3);      --> Saída do comando no OS
  vrp_des_saida VARCHAR2(1000); 
  
  -- Vetor para armazenar os arquivos para processamento
  vr_vet_nmarquiv gene0002.typ_split := gene0002.typ_split();  
  
  -- CURSORES
  CURSOR cr_cooperativa IS 
    SELECT c.cdagebcb
           ,c.cdcooper
      FROM crapcop c;
  rw_cooperativa cr_cooperativa%ROWTYPE;
  
  -- Variaveis critica
  vr_exc_saida EXCEPTION;
  
  -- Procedures
  -- Procedure para ler o excel e gravar as linhas em um pl table
  PROCEDURE pc_processa_arquivo(pr_direxcel  IN VARCHAR2
                                ,pr_nmarquv  IN VARCHAR2
                                ,pr_tabcancl OUT typ_tab_cartoes_cancelados
                                ,pr_dscritic OUT crapcri.dscritic%TYPE) IS    
  BEGIN
    DECLARE
      vr_arqextxt utl_file.file_type; -- Variavel para receber linhas do arquivo excel
      vr_arqdstxt VARCHAR2(2000);     -- Contem o conteudo da linha do excel
      vr_arqlinha NUMBER := 0;
    BEGIN
      -- Varrer o arquivo 
      gene0001.pc_abre_arquivo(pr_nmdireto => pr_direxcel||'/'   --> Diretorio do arquivo
                              ,pr_nmarquiv => pr_nmarquv         --> Nome do arquivo
                              ,pr_tipabert => 'R'                --> modo de abertura (r,w,a)
                              ,pr_utlfileh => vr_arqextxt        --> handle do arquivo aberto
                              ,pr_des_erro => pr_dscritic);      --> erro     

      IF TRIM(pr_dscritic) IS NOT NULL THEN 
         cecred.pc_log_programa(pr_dstiplog       => 'O'           
                                ,pr_cdprograma    => vr_cdprogra   
                                ,pr_tpexecucao    => 1             --> tipo de execucao (0-outro/ 1-batch/ 2-job/ 3-online)
                                ,pr_tpocorrencia  => 1             --> tp ocorrencia (1-erro de negocio/ 2-erro nao tratado/ 3-alerta/ 4-mensagem)
                                ,pr_cdcriticidade => 0             --> nivel criticidade (0-baixa/ 1-media/ 2-alta/ 3-critica)
                                ,pr_dsmensagem    => vr_dscritic    --> dscritic       
                                ,pr_flgsucesso    => 0             --> indicador de sucesso da execução
                                ,pr_idprglog      => vr_idprglog);         
         RETURN;
      END IF;                                   
      
      -- Linhas do arquivo
      vr_arqlinha := 0;
      pr_tabcancl.delete();
      
      -- Iniciamos o loop nas linhas
      IF  utl_file.IS_OPEN(vr_arqextxt) THEN
          LOOP
            BEGIN
              -- Lê a linha do arquivo aberto
              gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_arqextxt   --> Handle do arquivo aberto
                                          ,pr_des_text => vr_arqdstxt); --> Texto lido
              
              -- se for HEADER
              IF substr(vr_arqdstxt,0,7) = 'EMISSOR'  THEN
                 CONTINUE;
              END IF;
              
              -- Somar linha do arquivo
              vr_arqlinha := vr_arqlinha + 1;
                            
              --dbms_output.put_line(trim(vr_arqdstxt));
              SELECT  REGEXP_SUBSTR (TRIM(vr_arqdstxt), '[^,]+', 1, 2) col1 -- Cód Agencia
              ,       REGEXP_SUBSTR (TRIM(vr_arqdstxt), '[^,]+', 1, 3) col2 -- CPF/CNPJ
              ,       REGEXP_SUBSTR (TRIM(vr_arqdstxt), '[^,]+', 1, 4) col3 -- Nr. Conta Cartão
              ,       REGEXP_SUBSTR (TRIM(vr_arqdstxt), '[^,]+', 1, 5) col4 -- Nr. Cartãol
              INTO    pr_tabcancl(vr_arqlinha).cdagebcb, pr_tabcancl(vr_arqlinha).nrcpfcgc, pr_tabcancl(vr_arqlinha).nrcctitg, pr_tabcancl(vr_arqlinha).nrcrcard
              FROM    dual; 
                                    
            EXCEPTION
              WHEN no_data_found THEN -- não encontrar mais linhas
                  cecred.pc_log_programa(pr_dstiplog       => 'O'           
                                         ,pr_cdprograma    => vr_cdprogra   
                                         ,pr_tpexecucao    => 1             --> tipo de execucao (0-outro/ 1-batch/ 2-job/ 3-online)
                                         ,pr_tpocorrencia  => 4             --> tp ocorrencia (1-erro de negocio/ 2-erro nao tratado/ 3-alerta/ 4-mensagem)
                                         ,pr_dsmensagem    => 'Final de leitura de linhas do arquivo: ['|| vr_vet_nmarquiv(1) ||']'    --> dscritic    
                                         ,pr_idprglog      => vr_idprglog);                
                EXIT;
              WHEN OTHERS THEN
                IF trim(vr_dscritic) IS NULL THEN
                  pr_dscritic := 'Erro no processamento do arquivo ['|| vr_vet_nmarquiv(1) ||']: '||SQLERRM;
                END IF;
                cecred.pc_log_programa(pr_dstiplog       => 'O'           
                                       ,pr_cdprograma    => vr_cdprogra   
                                       ,pr_tpexecucao    => 1             --> tipo de execucao (0-outro/ 1-batch/ 2-job/ 3-online)
                                       ,pr_tpocorrencia  => 2             --> tp ocorrencia (1-erro de negocio/ 2-erro nao tratado/ 3-alerta/ 4-mensagem)
                                       ,pr_dsmensagem    => pr_dscritic    --> dscritic       
                                       ,pr_idprglog      => vr_idprglog);                
                EXIT;
            END;
          END LOOP; -- Fim loop do arquivo        
      END IF; -- Fim if utl_file.is_open;
      
      -- Fechar o arquivo
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_arqextxt); --> Handle do arquivo aberto; 
      
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro no processamento do arquivo: ['|| pr_nmarquv ||']: '||SQLERRM;
    END;
  END;

  -- Procedures para tratamento de arquivo
  PROCEDURE iniciaArquivo(pr_clob IN OUT CLOB) IS
  BEGIN      
    -- Inicializa CLOB
    dbms_lob.createtemporary(pr_clob, TRUE);
    dbms_lob.open(pr_clob, dbms_lob.lob_readwrite);
  END iniciaArquivo; 

  PROCEDURE encerraArquivo(pr_clob         IN OUT CLOB
                           ,pr_xml_temp    IN OUT VARCHAR2
                           ,pr_dsdiretorio IN VARCHAR2
                           ,pr_nmarquivo   IN VARCHAR2
                           ,pr_dscritic    OUT crapcri.dscritic%TYPE) IS
  BEGIN
      
    IF dbms_lob.compare(pr_clob, empty_clob()) != 0 THEN
       -- Incluir todos os dados no clob
       gene0002.pc_escreve_xml(pr_xml            => pr_clob
                              ,pr_texto_completo => pr_xml_temp
                              ,pr_texto_novo     => ''
                              ,pr_fecha_xml      => TRUE);
    END IF;                         
    -- Gera o relatorio
    GENE0002.pc_clob_para_arquivo(pr_clob     => pr_clob,
                                  pr_caminho  => pr_dsdiretorio,
                                  pr_arquivo  => pr_nmarquivo,
                                  pr_des_erro => pr_dscritic);
          
    -- testa se tem critica
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;   
      
    -- Libera a memoria do CLOB
    dbms_lob.close(pr_clob);
    dbms_lob.freetemporary(pr_clob);                  
  END encerraArquivo;  
  
  -- Procedure para salvar o arquivo e reiniciar o processo de escrita
  PROCEDURE restartArquivo(prr_clob        IN OUT CLOB
                          ,prr_xml_temp    IN OUT VARCHAR2
                          ,prr_dsdiretorio IN VARCHAR2
                          ,prr_nmarquivo   IN VARCHAR2
                          ,prr_dscritic    OUT crapcri.dscritic%TYPE) IS
  BEGIN
    
    encerraArquivo(pr_clob        => prr_clob
                  ,pr_xml_temp    => prr_xml_temp
                  ,pr_dsdiretorio => prr_dsdiretorio
                  ,pr_nmarquivo   => prr_nmarquivo
                  ,pr_dscritic    => prr_dscritic);
    
    IF prr_dscritic IS NOT NULL THEN
       RAISE vr_exc_saida;
    END IF;
    
    iniciaArquivo(pr_clob => prr_clob);
    
  END;

  -- Validacao de diretorio
  PROCEDURE pc_valida_direto(pr_nmdireto IN VARCHAR2
                             ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
  BEGIN
    DECLARE
      vr_dscritic crapcri.dscritic%TYPE;
      vr_typ_saida VARCHAR2(3);
      vr_des_saida VARCHAR2(1000);  
      vr_exc_erro  EXCEPTION;    
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
  --  
  
  -- Procedure para deletar os registros de cartoes
  PROCEDURE pc_deletar_registros(pr_tabcancl  IN typ_tab_cartoes_cancelados
                                ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    DECLARE
    vr_exc_erro EXCEPTION;
    -- Clob para os arquivos csv
    vr_dados_rollback_proposta CLOB;
    vr_dados_rollback_cartao CLOB;
    vr_dados_rollback_endereco CLOB;
    vr_dados_rollback_aprovacao CLOB; 
    --
    -- Texto temporario               
    vr_texto_rollback_proposta VARCHAR2(32600);
    vr_texto_rollback_cartao VARCHAR2(32600);
    vr_texto_rollback_endereco VARCHAR2(32600);
    vr_texto_rollback_aprovacao VARCHAR2(32600);
    --           
    vr_nmdireto VARCHAR2(4000) := NULL;
    -- Arquivos
    vr_nmarqbkp_proposta VARCHAR2(1000);
    vr_nmarqbkp_cartao VARCHAR2(1000);
    vr_nmarqbkp_endereco VARCHAR2(1000);
    vr_nmarqbkp_aprovacao VARCHAR2(1000); 
    
    vr_qtdlinhas_processadas NUMBER := 0;    
    vr_nrcardini NUMBER := 0; -- Parte inicial do cartao
    vr_nrcardfin NUMBER := 0; -- PArte final do cartao       
    
    -- CURSORES
    -- Buscar a cooperativa    
    CURSOR cr_crapcop(prc_cdagebcb IN crapcop.cdagebcb%TYPE) IS
      SELECT c.cdcooper
        FROM crapcop c
       WHERE c.cdagebcb = prc_cdagebcb;
    rw_crapcop cr_crapcop%ROWTYPE;
    
    -- Buscar a proposa do cartao   
    CURSOR cr_crawcrd(prc_cdcooper IN crawcrd.cdcooper%TYPE
                     ,prc_nrcpfcgc IN crapass.nrcpfcgc%TYPE
                     ,prc_nrcctitg IN crawcrd.nrcctitg%TYPE
                     ,prc_nrcrcard IN VARCHAR2) IS 
      SELECT w.*
             ,COUNT(*) OVER( PARTITION BY insitcrd ) AS qtd_cartoes
        FROM crawcrd w,
             crapass a
       WHERE w.cdcooper = a.cdcooper
         AND w.nrdconta = a.nrdconta
         AND a.nrcpfcgc = prc_nrcpfcgc
         AND w.cdcooper = prc_cdcooper
         AND w.nrcctitg = prc_nrcctitg
         AND (substr(w.nrcrcard,0,6) || '-' || substr(w.nrcrcard,13)) = prc_nrcrcard;      
    rw_crawcrd cr_crawcrd%ROWTYPE;

    -- Buscar a proposa do cartao   
    CURSOR cr_crawcrd_documento(prd_cdcooper IN crawcrd.cdcooper%TYPE
                               ,prd_nrcpfcgc IN crapass.nrcpfcgc%TYPE
                               ,prd_nrcctitg IN crawcrd.nrcctitg%TYPE
                               ,prd_nrcrcard IN VARCHAR2) IS 
      SELECT w.*
        FROM crawcrd w
       WHERE w.nrcpftit = prd_nrcpfcgc
         AND w.cdcooper = prd_cdcooper
         AND w.nrcctitg = prd_nrcctitg
         AND w.nrcrcard LIKE prd_nrcrcard;  -- (substr(w.nrcrcard,0,6) || '-' || substr(w.nrcrcard,13)) LIKE prd_nrcrcard||'%';      
    rw_crawcrd_documento cr_crawcrd_documento%ROWTYPE;    

    -- Buscar o cartao   
    CURSOR cr_crapcrd(prp_cdcooper IN crapcrd.cdcooper%TYPE
                     ,prp_nrdconta IN crapcrd.nrdconta%TYPE
                     ,prp_nrctrcrd IN crapcrd.nrctrcrd%TYPE) IS 
      SELECT p.*
        FROM crapcrd p
       WHERE p.cdcooper = prp_cdcooper
         AND p.nrdconta = prp_nrdconta
         AND p.nrctrcrd = prp_nrctrcrd;
    rw_crapcrd cr_crapcrd%ROWTYPE;    
    
    -- Buscar aprovacao do cartao
    CURSOR cr_aprovacao_cartao(pra_cdcooper IN tbcrd_aprovacao_cartao.cdcooper%TYPE
                              ,pra_nrdconta IN tbcrd_aprovacao_cartao.nrdconta%TYPE
                              ,pra_nrctrcrd IN tbcrd_aprovacao_cartao.nrctrcrd%TYPE) IS
      SELECT *
        FROM tbcrd_aprovacao_cartao ac
       WHERE ac.cdcooper = pra_cdcooper
         AND ac.nrdconta = pra_nrdconta
         AND ac.nrctrcrd = pra_nrctrcrd;
    rw_aprovacao_cartao cr_aprovacao_cartao%ROWTYPE;
    
    -- Buscar endereco de entrega
    CURSOR cr_endereco_cartao(pre_cdcooper IN tbcrd_endereco_entrega.cdcooper%TYPE
                             ,pre_nrdconta IN tbcrd_endereco_entrega.nrdconta%TYPE
                             ,pre_nrctrcrd IN tbcrd_endereco_entrega.nrctrcrd%TYPE) IS
      SELECT *
        FROM tbcrd_endereco_entrega ee
       WHERE ee.cdcooper = pre_cdcooper
         AND ee.nrdconta = pre_nrdconta
         AND ee.nrctrcrd = pre_nrctrcrd;
    rw_endereco_cartao cr_endereco_cartao%ROWTYPE;
            
    -- Procedure para guardar registros nao processados
    PROCEDURE pc_registros_nao_processados(prr_cdagebcb IN crapcop.cdagebcb%TYPE
                                          ,prr_nrcpfcgc IN crapass.nrcpfcgc%TYPE
                                          ,prr_nrcctitg IN crawcrd.nrcctitg%TYPE
                                          ,prr_nrcrcard IN VARCHAR2) IS
    BEGIN
      DECLARE
       vr_nlinha NUMBER := 0;
      BEGIN
        vr_nlinha := vr_nprocess.count() + 1;
        vr_nprocess(vr_nlinha).cdagebcb := prr_cdagebcb;
        vr_nprocess(vr_nlinha).nrcpfcgc := prr_nrcpfcgc;        
        vr_nprocess(vr_nlinha).nrcctitg := prr_nrcctitg;
        vr_nprocess(vr_nlinha).nrcrcard := prr_nrcrcard;
      END;
    END;  
    
    -- Deletar proposta de cartao
    PROCEDURE pc_deleta_proposta(pr_linha_proposta IN cr_crawcrd%ROWTYPE) IS    
    BEGIN
      DECLARE
      vr_del_reg CLOB;
      BEGIN
         DELETE 
           FROM crawcrd w 
          WHERE w.cdcooper = pr_linha_proposta.cdcooper 
            AND w.nrdconta = pr_linha_proposta.nrdconta 
            AND w.nrctrcrd = pr_linha_proposta.nrctrcrd;  
         -- Salvamos as informacoes
         vr_del_reg := pr_linha_proposta.nrcrcard||','||pr_linha_proposta.nrdconta||','||pr_linha_proposta.nmtitcrd||','||pr_linha_proposta.nrcpftit||','||
                       pr_linha_proposta.cdgraupr||','||pr_linha_proposta.vlsalari||','||pr_linha_proposta.vlsalcon||','||pr_linha_proposta.vloutras||','||
                       pr_linha_proposta.vlalugue||','||pr_linha_proposta.dddebito||','||pr_linha_proposta.cdlimcrd||','||pr_linha_proposta.dtpropos||','||
                       pr_linha_proposta.cdoperad||','||pr_linha_proposta.insitcrd||','||pr_linha_proposta.nrctrcrd||','||pr_linha_proposta.dtmvtolt||','||
                       pr_linha_proposta.cdagenci||','||pr_linha_proposta.cdbccxlt||','||pr_linha_proposta.nrdolote||','||pr_linha_proposta.nrseqdig||','||
                       pr_linha_proposta.dtsolici||','||pr_linha_proposta.dtentreg||','||pr_linha_proposta.dtvalida||','||pr_linha_proposta.dtanuida||','||
                       pr_linha_proposta.vlanuida||','||pr_linha_proposta.inanuida||','||pr_linha_proposta.qtanuida||','||pr_linha_proposta.qtparcan||','||
                       pr_linha_proposta.dtlibera||','||pr_linha_proposta.dtcancel||','||pr_linha_proposta.cdmotivo||','||pr_linha_proposta.nrprotoc||','||
                       pr_linha_proposta.dtentr2v||','||pr_linha_proposta.tpcartao||','||pr_linha_proposta.cdadmcrd||','||pr_linha_proposta.dtnasccr||','||
                       pr_linha_proposta.nrdoccrd||','||pr_linha_proposta.dtultval||','||pr_linha_proposta.nrctaav1||','||pr_linha_proposta.flgimpnp||','||
                       pr_linha_proposta.nmdaval1||','||pr_linha_proposta.dscpfav1||','||pr_linha_proposta.dsendav1##1||','||pr_linha_proposta.dsendav1##2||','||
                       pr_linha_proposta.nrctaav2||','||pr_linha_proposta.nmdaval2||','||pr_linha_proposta.dscpfav2||','||pr_linha_proposta.dsendav2##1||','||
                       pr_linha_proposta.dsendav2##2||','||pr_linha_proposta.dscfcav1||','||pr_linha_proposta.dscfcav2||','||pr_linha_proposta.nmcjgav1||','||
                       pr_linha_proposta.nmcjgav2||','||pr_linha_proposta.dtsol2vi||','||pr_linha_proposta.vllimdlr||','||pr_linha_proposta.cdcooper||','||
                       pr_linha_proposta.flgctitg||','||pr_linha_proposta.dtectitg||','||pr_linha_proposta.flgdebcc||','||pr_linha_proposta.flgrmcor||','||
                       pr_linha_proposta.flgprote||','||pr_linha_proposta.flgmalad||','||pr_linha_proposta.nrcctitg||','||pr_linha_proposta.dt2viasn||','||
                       pr_linha_proposta.nrrepent||','||pr_linha_proposta.nrreplim||','||pr_linha_proposta.nrrepven||','||pr_linha_proposta.nrrepsen||','||
                       pr_linha_proposta.nrrepcar||','||pr_linha_proposta.nrrepcan||','||pr_linha_proposta.dddebant||','||pr_linha_proposta.nmextttl||','||
                       pr_linha_proposta.tpenvcrd||','||pr_linha_proposta.tpdpagto||','||pr_linha_proposta.vllimcrd||','||pr_linha_proposta.nmempcrd||','||
                       pr_linha_proposta.flgprcrd||','||pr_linha_proposta.nrseqcrd||','||pr_linha_proposta.cdorigem||','||pr_linha_proposta.flgdebit||','||
                       pr_linha_proposta.dtrejeit||','||pr_linha_proposta.cdopeexc||','||pr_linha_proposta.cdageexc||','||pr_linha_proposta.dtinsexc||','||
                       pr_linha_proposta.cdopeori||','||pr_linha_proposta.cdageori||','||pr_linha_proposta.dtinsori||','||pr_linha_proposta.dtrefatu||','||
                       pr_linha_proposta.insitdec||','||pr_linha_proposta.dtaprova||','||pr_linha_proposta.dsprotoc||','||pr_linha_proposta.dsjustif||','||
                       pr_linha_proposta.cdopeent||','||pr_linha_proposta.inupgrad||','||pr_linha_proposta.cdopesup||','||pr_linha_proposta.dsobscmt||','||
                       pr_linha_proposta.dtenvest||','||pr_linha_proposta.dtenefes||','||pr_linha_proposta.dsendenv||','||pr_linha_proposta.idlimite||chr(10);
         
         gene0002.pc_escreve_xml(vr_dados_rollback_proposta, 
                                 vr_texto_rollback_proposta, 
                                 vr_del_reg, 
                                 FALSE
         ); 
          
       END; 
    END;

    -- Deletar cartao
    PROCEDURE pc_deleta_cartao(pr_linha_cartao IN cr_crapcrd%ROWTYPE) IS    
    BEGIN
      DECLARE
      vr_del_reg CLOB;
      BEGIN
         DELETE 
           FROM crapcrd p 
          WHERE p.cdcooper = pr_linha_cartao.cdcooper 
            AND p.nrdconta = pr_linha_cartao.nrdconta 
            AND p.nrctrcrd = pr_linha_cartao.nrctrcrd;
              
         -- Salvamos as informacoes
         vr_del_reg := pr_linha_cartao.nrdconta||','||pr_linha_cartao.nrcrcard||','||pr_linha_cartao.nrcpftit||','||pr_linha_cartao.nmtitcrd||','||pr_linha_cartao.dddebito||','||
                       pr_linha_cartao.cdlimcrd||','||pr_linha_cartao.dtvalida||','||pr_linha_cartao.nrctrcrd||','||pr_linha_cartao.dtcancel||','||pr_linha_cartao.cdmotivo||','||
                       pr_linha_cartao.nrprotoc||','||pr_linha_cartao.dtanucrd||','||pr_linha_cartao.vlanucrd||','||pr_linha_cartao.inanucrd||','||pr_linha_cartao.cdadmcrd||','||
                       pr_linha_cartao.tpcartao||','||pr_linha_cartao.dtultval||','||pr_linha_cartao.vllimdlr||','||pr_linha_cartao.cdcooper||','||pr_linha_cartao.dtaltval||','||
                       pr_linha_cartao.dtaltlim||','||pr_linha_cartao.dtaltldl||','||pr_linha_cartao.dtaltddb||','||pr_linha_cartao.inacetaa||','||pr_linha_cartao.qtsenerr||','||
                       pr_linha_cartao.cdopetaa||','||pr_linha_cartao.dtacetaa||','||pr_linha_cartao.dssentaa||','||pr_linha_cartao.flgdebit||','||pr_linha_cartao.dssenpin||','||
                       pr_linha_cartao.cdopeori||','||pr_linha_cartao.cdageori||','||pr_linha_cartao.dtinsori||','||pr_linha_cartao.dtrefatu||','||pr_linha_cartao.flgprovi||','||
                       pr_linha_cartao.dtassele||','||pr_linha_cartao.dtasssup||chr(10);
         
         gene0002.pc_escreve_xml(vr_dados_rollback_cartao, 
                                 vr_texto_rollback_cartao, 
                                 vr_del_reg, 
                                 FALSE
         ); 
          
       END; 
    END;
    
    -- Deletar e guardar endereco
    PROCEDURE pc_deleta_endereco_cartao(pr_linha_endereco IN cr_endereco_cartao%ROWTYPE) IS
    BEGIN
      DECLARE
      vr_del_reg CLOB;
      BEGIN      
         DELETE 
           FROM tbcrd_endereco_entrega ee 
          WHERE ee.cdcooper = pr_linha_endereco.cdcooper 
            AND ee.nrdconta = pr_linha_endereco.nrdconta 
            AND ee.nrctrcrd = pr_linha_endereco.nrctrcrd;

           -- Salvamos as informacoes
           vr_del_reg := pr_linha_endereco.cdcooper||','||pr_linha_endereco.nrdconta||','||pr_linha_endereco.nrctrcrd||','||pr_linha_endereco.idtipoenvio||','||
                         pr_linha_endereco.nmlogradouro||','||pr_linha_endereco.nrlogradouro||','||pr_linha_endereco.dscomplemento||','||pr_linha_endereco.nmbairro||','||
                         pr_linha_endereco.nmcidade||','||pr_linha_endereco.nrcep||','||pr_linha_endereco.cdagenci||','||pr_linha_endereco.cdufende||chr(10);
           
           gene0002.pc_escreve_xml(vr_dados_rollback_endereco, 
                                   vr_texto_rollback_endereco, 
                                   vr_del_reg, 
                                   FALSE
           ); 
      END;                     
    END;   
    
    -- Deletar e guardar a aprovacao do cartao
    PROCEDURE pc_deleta_aprovacao_cartao(pr_linha_aprovacao IN cr_aprovacao_cartao%ROWTYPE) IS
    BEGIN
      DECLARE
      vr_del_reg CLOB;
      BEGIN      
         DELETE 
           FROM tbcrd_aprovacao_cartao ac 
          WHERE ac.cdcooper = pr_linha_aprovacao.cdcooper 
            AND ac.nrdconta = pr_linha_aprovacao.nrdconta 
            AND ac.nrctrcrd = pr_linha_aprovacao.nrctrcrd;

           -- Salvamos as informacoes
           vr_del_reg := pr_linha_aprovacao.cdcooper     ||','||
                         pr_linha_aprovacao.nrdconta     ||','||
                         pr_linha_aprovacao.nrctrcrd     ||','||
                         pr_linha_aprovacao.indtipo_senha||','||
                         pr_linha_aprovacao.dtaprovacao  ||','||
                         pr_linha_aprovacao.hraprovacao  ||','||
                         pr_linha_aprovacao.nrcpf        ||','||
                         pr_linha_aprovacao.nmaprovador  ||','||
                         pr_linha_aprovacao.cdaprovador  ||','||
                         pr_linha_aprovacao.dsmotivo_canais|| chr(10);
           
           gene0002.pc_escreve_xml(vr_dados_rollback_aprovacao, 
                                   vr_texto_rollback_aprovacao, 
                                   vr_del_reg, 
                                   FALSE
           ); 
      END;                     
    END;          
      
    BEGIN
       -- Verificamos se table possui registros
       IF pr_tabcancl.count() > 0 THEN  
          -- Diretorio padrao
          vr_nmdireto := gene0001.fn_diretorio('C', 3, 'RITM0090750');
          vr_nmarqbkp_proposta := 'cartoes_proposta_'||pr_tabcancl(1).cdagebcb||'.csv';
          vr_nmarqbkp_cartao := 'cartoes_cartao_'||pr_tabcancl(1).cdagebcb||'.csv';
          vr_nmarqbkp_endereco := 'cartoes_endereco_'||pr_tabcancl(1).cdagebcb||'.csv';
          vr_nmarqbkp_aprovacao := 'cartoes_aprovacao_'||pr_tabcancl(1).cdagebcb||'.csv';
          
          -- Criamos o diretorio da cooperativa dentro da ritm
          pc_valida_direto(pr_nmdireto => vr_nmdireto || '/'||pr_tabcancl(1).cdagebcb
                             ,pr_dscritic => pr_dscritic);

          IF TRIM(pr_dscritic) IS NOT NULL THEN
             RAISE vr_exc_erro;
          END IF;     
          
          vr_nmdireto := vr_nmdireto || '/'||pr_tabcancl(1).cdagebcb;
          
          -- inicializacao de abertura de arquivo
          iniciaArquivo(vr_dados_rollback_proposta);
          iniciaArquivo(vr_dados_rollback_cartao);
          iniciaArquivo(vr_dados_rollback_endereco);
          iniciaArquivo(vr_dados_rollback_aprovacao);   
               
                          
          -- Como os arquivos sao separados por cooperativa, nao precisamos busca-la toda vez no loop
          -- Desde modo, utilizamos apenas 1 registro.
          OPEN  cr_crapcop(pr_tabcancl(1).cdagebcb);    
          FETCH cr_crapcop INTO rw_crapcop;
             --
             IF cr_crapcop%NOTFOUND THEN
                CLOSE cr_crapcop;
                pr_dscritic := 'Cooperativa nao encontrada para o codigo de agencia: ' || pr_tabcancl(1).cdagebcb;
                RAISE vr_exc_erro;
             END IF;
             --
          CLOSE cr_crapcop;
          --
          FOR idx IN pr_tabcancl.first .. pr_tabcancl.last LOOP   
              
              -- Controlamos a quantidade de linhas processadas
              -- para quebra de arquivo de 10 em 10 mil linhas
              vr_qtdlinhas_processadas := vr_qtdlinhas_processadas + 1;                      
              -- 
              OPEN  cr_crawcrd(rw_crapcop.cdcooper, pr_tabcancl(idx).nrcpfcgc, pr_tabcancl(idx).nrcctitg, pr_tabcancl(idx).nrcrcard);              
              FETCH cr_crawcrd INTO rw_crawcrd;
                --
                IF cr_crawcrd%NOTFOUND THEN
                   CLOSE cr_crawcrd;
                   
                   vr_nrcardini := SUBSTR(pr_tabcancl(idx).nrcrcard, 0, INSTR(pr_tabcancl(idx).nrcrcard, '-')-1);
                   vr_nrcardfin := SUBSTR(pr_tabcancl(idx).nrcrcard, INSTR(pr_tabcancl(idx).nrcrcard, '-')+1);
                   
                   -- Cursor diminui a performance, porém é necessario pois as vezes o cpf cadastrado na crawcrd esta diferente da crapass
                   OPEN  cr_crawcrd_documento(rw_crapcop.cdcooper, pr_tabcancl(idx).nrcpfcgc, pr_tabcancl(idx).nrcctitg, vr_nrcardini||'%'||vr_nrcardfin);
                   FETCH cr_crawcrd_documento INTO rw_crawcrd_documento;
                   --
                     IF  cr_crawcrd_documento%NOTFOUND THEN
                         CLOSE cr_crawcrd_documento;
                         -- Guardamos os registros nao processados para posteriormente notificacao
                         pc_registros_nao_processados(pr_tabcancl(idx).cdagebcb, pr_tabcancl(idx).nrcpfcgc, pr_tabcancl(idx).nrcctitg, pr_tabcancl(idx).nrcrcard);
                         CONTINUE;                           
                     END IF;
                   --
                   CLOSE cr_crawcrd_documento;
                   
                ELSE
                  CLOSE cr_crawcrd;   
                END IF;
              
              
              -- Nao iremos processar pois nao sabemos qual deletar
              IF rw_crawcrd.qtd_cartoes > 1 THEN
                 -- Guardamos os registros nao processados para posteriormente notificacao
                 pc_registros_nao_processados(pr_tabcancl(idx).cdagebcb, pr_tabcancl(idx).nrcpfcgc, pr_tabcancl(idx).nrcctitg, pr_tabcancl(idx).nrcrcard);
                 CONTINUE;                 
              END IF;
              
              -- Buscamos aprovacao do cartao
              OPEN  cr_aprovacao_cartao(rw_crawcrd.cdcooper, rw_crawcrd.nrdconta, rw_crawcrd.nrctrcrd);
              FETCH cr_aprovacao_cartao INTO rw_aprovacao_cartao;
              CLOSE cr_aprovacao_cartao;
              
              -- Buscamos endereco do cartao 
              OPEN  cr_endereco_cartao(rw_crawcrd.cdcooper, rw_crawcrd.nrdconta, rw_crawcrd.nrctrcrd);
              FETCH cr_endereco_cartao INTO rw_endereco_cartao;
              CLOSE cr_endereco_cartao;       
                            
              -- Buscamos o cartao
              OPEN  cr_crapcrd(rw_crawcrd.cdcooper, rw_crawcrd.nrdconta, rw_crawcrd.nrctrcrd);
              FETCH cr_crapcrd INTO rw_crapcrd;
              CLOSE cr_crapcrd;
              
              -- Efetuamos a removacao dos dados
              -- Deletar proposta
              pc_deleta_proposta(rw_crawcrd);
                     
              -- Deletar cartao
              pc_deleta_cartao(rw_crapcrd);
              
              -- Deletar endereco cartao
              pc_deleta_endereco_cartao(rw_endereco_cartao);
              
              -- Deletar aprovacao do cartao
              pc_deleta_aprovacao_cartao(rw_aprovacao_cartao);
              
              IF vr_qtdlinhas_processadas = 5000 THEN
                 -- Restart contador
                 vr_qtdlinhas_processadas := 0;
                 
                 -- Encerra e restarta o processo 
                 restartArquivo(prr_clob        => vr_dados_rollback_proposta
                               ,prr_xml_temp    => vr_texto_rollback_proposta
                               ,prr_dsdiretorio => vr_nmdireto
                               ,prr_nmarquivo   => to_char(SYSDATE, 'ddmmrrrrhh24miss') || '_' || vr_nmarqbkp_proposta 
                               ,prr_dscritic    => pr_dscritic);

                 IF TRIM(pr_dscritic) IS NOT NULL THEN
                    RAISE vr_exc_erro;
                 END IF;                                   

                 -- Encerra e restarta o processo 
                 restartArquivo(prr_clob        => vr_dados_rollback_cartao
                               ,prr_xml_temp    => vr_texto_rollback_cartao
                               ,prr_dsdiretorio => vr_nmdireto
                               ,prr_nmarquivo   => to_char(SYSDATE, 'ddmmrrrrhh24miss') || '_' || vr_nmarqbkp_cartao
                               ,prr_dscritic    => pr_dscritic);

                 IF TRIM(pr_dscritic) IS NOT NULL THEN
                    RAISE vr_exc_erro;
                 END IF;                                                                      

                 -- Encerra e restarta o processo 
                 restartArquivo(prr_clob        => vr_dados_rollback_endereco
                               ,prr_xml_temp    => vr_texto_rollback_endereco
                               ,prr_dsdiretorio => vr_nmdireto
                               ,prr_nmarquivo   => to_char(SYSDATE, 'ddmmrrrrhh24miss') || '_' || vr_nmarqbkp_endereco
                               ,prr_dscritic    => pr_dscritic);

                 IF TRIM(pr_dscritic) IS NOT NULL THEN
                    RAISE vr_exc_erro;
                 END IF;                                                                      

                 -- Encerra e restarta o processo 
                 restartArquivo(prr_clob        => vr_dados_rollback_aprovacao
                               ,prr_xml_temp    => vr_texto_rollback_aprovacao
                               ,prr_dsdiretorio => vr_nmdireto
                               ,prr_nmarquivo   => to_char(SYSDATE, 'ddmmrrrrhh24miss') || '_' || vr_nmarqbkp_aprovacao
                               ,prr_dscritic    => pr_dscritic);                                                                                                         

                 IF TRIM(pr_dscritic) IS NOT NULL THEN
                    RAISE vr_exc_erro;
                 END IF;                                                                      
              END IF;
          END LOOP; -- End loop pr_tabcancl      
          
          -- Finalizamos rollback de propostas                                    
          encerraArquivo(pr_clob        => vr_dados_rollback_proposta
                        ,pr_xml_temp    => vr_texto_rollback_proposta
                        ,pr_dsdiretorio => vr_nmdireto
                        ,pr_nmarquivo   => vr_nmarqbkp_proposta
                        ,pr_dscritic    => pr_dscritic);
                        
          IF TRIM(pr_dscritic) IS NOT NULL THEN
             RAISE vr_exc_erro;
          END IF;
          
          --Finalizamos rollback de cartao
          encerraArquivo(pr_clob        => vr_dados_rollback_cartao
                        ,pr_xml_temp    => vr_texto_rollback_cartao
                        ,pr_dsdiretorio => vr_nmdireto
                        ,pr_nmarquivo   => vr_nmarqbkp_cartao
                        ,pr_dscritic    => pr_dscritic);
                        
          IF TRIM(pr_dscritic) IS NOT NULL THEN
             RAISE vr_exc_erro;
          END IF;  

          --Finalizamos rollback de endereco
          encerraArquivo(pr_clob        => vr_dados_rollback_endereco
                        ,pr_xml_temp    => vr_texto_rollback_endereco
                        ,pr_dsdiretorio => vr_nmdireto
                        ,pr_nmarquivo   => vr_nmarqbkp_endereco
                        ,pr_dscritic    => pr_dscritic);
                        
          IF TRIM(pr_dscritic) IS NOT NULL THEN
             RAISE vr_exc_erro;
          END IF; 

          --Finalizamos rollback de aprovacao
          encerraArquivo(pr_clob        => vr_dados_rollback_aprovacao
                        ,pr_xml_temp    => vr_texto_rollback_aprovacao
                        ,pr_dsdiretorio => vr_nmdireto
                        ,pr_nmarquivo   => vr_nmarqbkp_aprovacao
                        ,pr_dscritic    => pr_dscritic);
                        
          IF TRIM(pr_dscritic) IS NOT NULL THEN
             RAISE vr_exc_erro;
          END IF;                            
                                       
       END IF; -- End if pr_tabcancl.count()
       
       COMMIT;
    EXCEPTION
      WHEN vr_exc_erro THEN         
        ROLLBACK;
      WHEN OTHERS THEN
        ROLLBACK;
        pr_dscritic := 'Erro na procedure pc_deletar_registros: ['|| SQLERRM ||'] ';      
    END;
  END;
  
  -- Gerar arquivo com arquivos nao processados
  PROCEDURE pc_arquivo_nao_processados(pr_tabnao_processados  IN typ_tab_cartoes_cancelados
                                      ,pr_dscritic            OUT crapcri.dscritic%TYPE) IS
  BEGIN
    DECLARE
      vr_dados_nao_processados CLOB; 
      vr_texto_nao_processados VARCHAR2(32600); 
      vr_conteudo VARCHAR2(200);
    BEGIN
       
       IF pr_tabnao_processados.count() > 0 THEN
         iniciaArquivo(vr_dados_nao_processados);

         gene0002.pc_escreve_xml(vr_dados_nao_processados, 
                                 vr_texto_nao_processados, 
                                 'AGENCIA,DOCUMENTO,CONTA CARTAO,NUMERO CARTAO'||chr(10), 
                                 FALSE
          );         
          FOR idx IN pr_tabnao_processados.first .. pr_tabnao_processados.last LOOP     
            vr_conteudo := pr_tabnao_processados(idx).cdagebcb||','||
                           pr_tabnao_processados(idx).nrcpfcgc||','||
                           pr_tabnao_processados(idx).nrcctitg||','||
                           pr_tabnao_processados(idx).nrcrcard||chr(10);
            gene0002.pc_escreve_xml(vr_dados_nao_processados, 
                                   vr_texto_nao_processados, 
                                   vr_conteudo, 
                                   FALSE
            );    
          END LOOP;         

          -- Finalizamos rollback de propostas                                    
          encerraArquivo(pr_clob        => vr_dados_nao_processados
                        ,pr_xml_temp    => vr_texto_nao_processados
                        ,pr_dsdiretorio => vr_direxcel
                        ,pr_nmarquivo   => pr_tabnao_processados(1).cdagebcb || '_registros_nao_processados.csv'
                        ,pr_dscritic    => pr_dscritic);           
       END IF;
      
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Nao foi possivel gerar o arquivo dos registros nao processados: pc_arquivo_nao_processados - ' || SQLERRM;
    END;    
  END;
  
BEGIN
  -- Controle para programa
  cecred.pc_log_programa(pr_dstiplog   => 'I'    
                        ,pr_cdprograma => vr_cdprogra          
                        ,pr_cdcooper   => 3
                        ,pr_tpexecucao => 1    -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        ,pr_idprglog   => vr_idprglog);
                       
  -- Diretorio dos arquivos
  vr_direxcel := gene0001.fn_diretorio('C', 3, 'RITM0090750');

  -- Criamos o diretorio dos arquivos processados
  pc_valida_direto(pr_nmdireto => vr_direxcel || '/processados'
                   ,pr_dscritic => vr_dscritic);

  IF TRIM(vr_dscritic) IS NOT NULL THEN
     RAISE vr_exc_saida;
  END IF;  
  
  FOR rw_cooperativa IN cr_cooperativa LOOP

      -- Grava LOG de inicio de processamento
      cecred.pc_log_programa(pr_dstiplog           => 'O'
                            ,pr_cdprograma         => vr_cdprogra 
                            ,pr_tpexecucao         => 1   -- tipo de execucao (0-outro/ 1-batch/ 2-job/ 3-online)
                            ,pr_tpocorrencia       => 4
                            ,pr_dsmensagem         => 'Iniciando processamento do arquivo: ' || 'cartoes_'||to_char(rw_cooperativa.cdagebcb)
                            ,pr_idprglog           => vr_idprglog); 
                                 
      vr_crdcancl.delete();
      vr_nprocess.delete();
      
      -- monta nome do arquivo
      vr_nmrquivo := 'cartoes_'||to_char(rw_cooperativa.cdagebcb)||'%.%';
            
      -- Trazer todos os arquivos da pasta
      gene0001.pc_lista_arquivos(pr_path     => vr_direxcel 
                                ,pr_pesq     => vr_nmrquivo  
                                ,pr_listarq  => vr_listarqs 
                                ,pr_des_erro => vr_dscritic); 

      --Ocorreu um erro no lista_arquivos
      IF TRIM(vr_dscritic) IS NOT NULL THEN
         RAISE vr_exc_saida;
      END IF;

      -- Verificamos se encontrou arquivo para processar
      IF TRIM(vr_listarqs) IS NULL THEN
         vr_dscritic := 'Nao encontrou o arquivo ' || 'cartoes_'||to_char(rw_cooperativa.cdagebcb);
         cecred.pc_log_programa(pr_dstiplog       => 'O'           
                                ,pr_cdprograma    => vr_cdprogra   
                                ,pr_tpexecucao    => 1             --> tipo de execucao (0-outro/ 1-batch/ 2-job/ 3-online)
                                ,pr_tpocorrencia  => 1             --> tp ocorrencia (1-erro de negocio/ 2-erro nao tratado/ 3-alerta/ 4-mensagem)
                                ,pr_cdcriticidade => 0             --> nivel criticidade (0-baixa/ 1-media/ 2-alta/ 3-critica)
                                ,pr_dsmensagem    => vr_dscritic    --> dscritic       
                                ,pr_flgsucesso    => 0             --> indicador de sucesso da execução
                                ,pr_idprglog      => vr_idprglog);         
         CONTINUE;
      ELSE
         vr_vet_nmarquiv := gene0002.fn_quebra_string(pr_string  => vr_listarqs,pr_delimit => ',');
         -- Nenhum arquivo
         IF vr_vet_nmarquiv.count = 0 THEN
            vr_dscritic := 'Nao encontrou o arquivo ' || 'cartoes_'||to_char(rw_cooperativa.cdagebcb);
            cecred.pc_log_programa(pr_dstiplog       => 'O'           
                                   ,pr_cdprograma    => vr_cdprogra   
                                   ,pr_tpexecucao    => 1             --> tipo de execucao (0-outro/ 1-batch/ 2-job/ 3-online)
                                   ,pr_tpocorrencia  => 1             --> tp ocorrencia (1-erro de negocio/ 2-erro nao tratado/ 3-alerta/ 4-mensagem)
                                   ,pr_cdcriticidade => 0             --> nivel criticidade (0-baixa/ 1-media/ 2-alta/ 3-critica)
                                   ,pr_dsmensagem    => vr_dscritic    --> dscritic       
                                   ,pr_flgsucesso    => 0             --> indicador de sucesso da execução
                                   ,pr_idprglog      => vr_idprglog);            
            CONTINUE;
         END IF;
      END IF;  
      --
      -- Processa o excel e guarda em uma pltable
      pc_processa_arquivo(vr_direxcel
                         ,vr_vet_nmarquiv(1)
                         ,vr_crdcancl
                         ,vr_dscritic);
            
      IF TRIM(vr_dscritic) IS NOT NULL THEN
         cecred.pc_log_programa(pr_dstiplog           => 'O'
                               ,pr_cdprograma         => vr_cdprogra 
                               ,pr_tpexecucao         => 1   -- tipo de execucao (0-outro/ 1-batch/ 2-job/ 3-online)
                               ,pr_tpocorrencia       => 1
                               ,pr_dsmensagem         => 'Erro no processamento do arquivo: ' || 'cartoes_'||to_char(rw_cooperativa.cdagebcb) || ' - ' || vr_dscritic
                               ,pr_idprglog           => vr_idprglog);     
         CONTINUE;                                  
      END IF;
      --
      
      -- Grava LOG de inicio de processamento
      cecred.pc_log_programa(pr_dstiplog           => 'O'
                            ,pr_cdprograma         => vr_cdprogra 
                            ,pr_tpexecucao         => 1   -- tipo de execucao (0-outro/ 1-batch/ 2-job/ 3-online)
                            ,pr_tpocorrencia       => 4
                            ,pr_dsmensagem         => 'Arquivo : ' || 'cartoes_'||to_char(rw_cooperativa.cdagebcb) || ' processado e salvo na pl/table'
                            ,pr_idprglog           => vr_idprglog);
                            
      -- Grava LOG de inicio de processamento
      cecred.pc_log_programa(pr_dstiplog           => 'O'
                            ,pr_cdprograma         => vr_cdprogra 
                            ,pr_tpexecucao         => 1   -- tipo de execucao (0-outro/ 1-batch/ 2-job/ 3-online)
                            ,pr_tpocorrencia       => 4
                            ,pr_dsmensagem         => 'Iniciando processo para deletar registros referente ao arquivo: ' || 'cartoes_'||to_char(rw_cooperativa.cdagebcb)
                            ,pr_idprglog           => vr_idprglog);      
      
      
      pc_deletar_registros(vr_crdcancl, vr_dscritic);
      --
      IF TRIM(vr_dscritic) IS NOT NULL THEN
         cecred.pc_log_programa(pr_dstiplog           => 'O'
                               ,pr_cdprograma         => vr_cdprogra 
                               ,pr_tpexecucao         => 1   -- tipo de execucao (0-outro/ 1-batch/ 2-job/ 3-online)
                               ,pr_tpocorrencia       => 1
                               ,pr_dsmensagem         => 'Erro ao deletar registros do arquivo: ' || 'cartoes_'||to_char(rw_cooperativa.cdagebcb) || ' - ' || vr_dscritic
                               ,pr_idprglog           => vr_idprglog);     
         CONTINUE;                                  
      END IF;
      
      -- Movemos o arquivo para pasta processados
      gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||vr_direxcel||'/'||vr_vet_nmarquiv(1)||' '||vr_direxcel||'/processados'
                                 ,pr_typ_saida   => vrp_typ_saida
                                 ,pr_des_saida   => vr_dscritic);            
      --
      cecred.pc_log_programa(pr_dstiplog       => 'O'           
                             ,pr_cdprograma    => vr_cdprogra   
                             ,pr_tpexecucao    => 1             --> tipo de execucao (0-outro/ 1-batch/ 2-job/ 3-online)
                             ,pr_tpocorrencia  => 4             --> tp ocorrencia (1-erro de negocio/ 2-erro nao tratado/ 3-alerta/ 4-mensagem)
                             ,pr_dsmensagem    => 'Fim do processamento do arquivo: ['|| vr_vet_nmarquiv(1) ||']'    --> dscritic    
                             ,pr_idprglog      => vr_idprglog); 

                                    
      -- Geramos arquivo com os cartoes nao processados
      pc_arquivo_nao_processados(vr_nprocess, vr_dscritic);             

      IF TRIM(vr_dscritic) IS NOT NULL THEN
         cecred.pc_log_programa(pr_dstiplog       => 'O'           
                               ,pr_cdprograma    => vr_cdprogra   
                               ,pr_tpexecucao    => 1             --> tipo de execucao (0-outro/ 1-batch/ 2-job/ 3-online)
                               ,pr_tpocorrencia  => 2             --> tp ocorrencia (1-erro de negocio/ 2-erro nao tratado/ 3-alerta/ 4-mensagem)
                               ,pr_dsmensagem    => vr_dscritic
                               ,pr_idprglog      => vr_idprglog);    
      END IF; 
           
  END LOOP; -- cooperativas  
  
  cecred.pc_log_programa(pr_dstiplog       => 'F'           
                         ,pr_cdprograma    => vr_cdprogra   
                         ,pr_tpexecucao    => 1             --> tipo de execucao (0-outro/ 1-batch/ 2-job/ 3-online)
                         ,pr_tpocorrencia  => 4             --> tp ocorrencia (1-erro de negocio/ 2-erro nao tratado/ 3-alerta/ 4-mensagem)
                         ,pr_dsmensagem    => 'Fim do processamento dos arquivos para cancelamento de cartoes'    --> dscritic    
                         ,pr_idprglog      => vr_idprglog);  
						 
	COMMIT;
EXCEPTION
  WHEN vr_exc_saida THEN
    raise_application_error(-20111,vr_dscritic);
  WHEN OTHERS THEN
    raise_application_error(-20111,SQLERRM);
END;