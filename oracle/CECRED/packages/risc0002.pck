CREATE OR REPLACE PACKAGE CECRED.RISC0002 is
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : RISC0002
  --  Sistema  : Rotinas para Calculos de Risco
  --  Sigla    : RISC
  --  Autor    : James Prust Junior
  --  Data     : Fevereiro/2016.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas genericas para a importacao dos dados para a central de risco
  --
  -- Alteracoes: 06/06/2017 - Inclusao do novo tipo de saldo (7 - PAR (parcelado rotativo)).
  --                          Procedure pc_import_arq_risco_cartao.
  --                          (Chamado 687323) - (Fabricio)
	--
	--             16/07/2019 - Inclusão do novo tipo de saldo (8 - Saldo parcela não quitada).
  --                          (Reinert - RITM0028079)
  ---------------------------------------------------------------------------------------------------------------
  -- Registro para as informações do arquivo CB117 de controle
  TYPE typ_tab_linhas_controle IS
    TABLE OF PLS_INTEGER
      INDEX BY VARCHAR2(40);

  -- Registro para as informações do arquivo CB117
  TYPE typ_linhas_arquivo IS
    RECORD(cdcooper         tbcrd_risco.cdcooper%TYPE         -- Codigo da cooperativa
          ,nrdconta         tbcrd_risco.nrdconta%TYPE         -- Numero da conta
          ,nrdconta_cartao  tbcrd_risco.nrdconta_cartao%TYPE  -- Numero da conta cartao
          ,nrcontrato       tbcrd_risco.nrcontrato%TYPE       -- Numero do contato       
          ,nrcpfcnpj        tbcrd_risco.nrcpfcnpj%TYPE        -- CPF/CNPJ
          ,nrmodalidade     tbcrd_risco.nrmodalidade%TYPE     -- Codigo da modalidade
          ,dtrefere         tbcrd_risco.dtrefere%TYPE         -- Data de referencia
          ,dtcadastro       tbcrd_risco.dtcadastro%TYPE       -- Data de abertura da conta cartao
          ,cdtipo_saldo     tbcrd_risco.cdtipo_saldo%TYPE     -- Tipo de saldo
          ,vltaxa_juros     tbcrd_risco.vltaxa_juros%TYPE     -- Taxa de Juros mensal
          ,dtvencimento     tbcrd_risco.dtvencimento%TYPE     -- Data de vencimento
          ,vlsaldo_devedor  tbcrd_risco.vlsaldo_devedor%TYPE  -- Saldo Devedor
          ,vlcet            tbcrd_risco.vlcet%TYPE);          -- CET

  -- Definição de um tipo de tabela com o registro acima
  TYPE typ_tab_linhas_arquivo IS
    TABLE OF typ_linhas_arquivo
      INDEX BY VARCHAR2(50);
   
  -- Registro dos riscos do cartao de credito
  TYPE typ_risco_cartao IS
    RECORD(cdcooper       tbcrd_risco.cdcooper%TYPE
          ,nrdconta       tbcrd_risco.nrdconta%TYPE
          ,nrcontrato     tbcrd_risco.nrcontrato%TYPE
          ,cdagencia      crapris.cdagenci%TYPE
          ,nrmodalidade   tbcrd_risco.nrmodalidade%TYPE
          ,dtcadastro     tbcrd_risco.dtcadastro%TYPE
          ,dtvencimento   tbcrd_risco.dtvencimento%TYPE
          ,innivris       crapris.innivris%TYPE
          ,vldivida       crapris.vldivida%TYPE
          ,inpessoa       crapris.inpessoa%TYPE
          ,dtvencop       crapris.dtvencop%TYPE
          ,qtdiaatr       crapris.qtdiaatr%TYPE
          ,nrcpfcgc       crapris.nrcpfcgc%TYPE
          ,flgindiv       crapris.flgindiv%TYPE);
              
  -- Definição de um tipo de tabela com o registro acima
  TYPE typ_tab_risco_cartao IS
    TABLE OF typ_risco_cartao
      INDEX BY VARCHAR2(40);
      
  -- Registro dos riscos do cartao de credito
  TYPE typ_risco_venc_cartao IS
    RECORD(cdcooper       tbcrd_risco.cdcooper%TYPE
          ,nrdconta       tbcrd_risco.nrdconta%TYPE
          ,nrcontrato     tbcrd_risco.nrcontrato%TYPE
          ,nrmodalidade   tbcrd_risco.nrmodalidade%TYPE
          ,cdvencto       crapvri.cdvencto%TYPE
          ,dtrefere       crapvri.dtrefere%TYPE
          ,innivris       crapvri.innivris%TYPE
          ,vldivida       crapvri.vldivida%TYPE);
              
  -- Definição de um tipo de tabela com o registro acima
  TYPE typ_tab_risco_venc_cartao IS
    TABLE OF typ_risco_venc_cartao
      INDEX BY VARCHAR2(50);      
      
  -- Definicao de tipo de registro
  TYPE typ_reg_crapcop IS
    RECORD (cdcooper crapcop.cdcooper%TYPE
           ,nmrescop crapcop.nmrescop%TYPE
           ,cdagebcb crapcop.cdagebcb%TYPE);
           
  TYPE typ_tab_crapcop IS TABLE OF typ_reg_crapcop INDEX BY VARCHAR2(10); 
  
  PROCEDURE pc_verifica_envio_email(pr_tab_crapcop IN RISC0002.typ_tab_crapcop --> Temp-Table Cooperativas
                                   ,pr_dtrefere    IN DATE                     --> Data de Referencia
                                   ,pr_cdcritic    OUT PLS_INTEGER             --> Código da crítica
                                   ,pr_dscritic    OUT VARCHAR2);              --> Descrição da crítica
                                   
  -- Procedure para busar os arquivos que serao importados
  PROCEDURE pc_lista_arquivos(pr_cdagebcb IN crapcop.cdagebcb%TYPE --> Agencia do Bancoob
                             ,pr_dsdirarq IN crapscb.dsdirarq%TYPE --> Diretorio que contem os arquivos
                             ,pr_listadir OUT VARCHAR2             --> Arquivos que serao importados
                             ,pr_nmrquivo OUT VARCHAR2             --> Nome do Arquivo
                             ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2);           --> Descrcao da critica
                             
  PROCEDURE pc_atualiza_param_risco_cartao(pr_cdcooper IN crapcop.cdcooper%TYPE
                                          ,pr_tipsplit IN GENE0002.typ_split
		  				    				        	      ,pr_dscritic OUT VARCHAR2);
                                              
  /* Esta rotina é acionada diretamente pelo Job */
  PROCEDURE pc_import_arq_risco_cartao_job;
  
  /* Esta rotina eh acionada pela tela IMPCAR */
  PROCEDURE pc_import_arq_risco_cartao_tel(pr_cdcooper IN crapcop.cdcooper%TYPE);
  
  /* Rotina para processamento de Arquivos VIP - Durante processo Batch */
  PROCEDURE pc_gera_risco_cartao_vip_proc(pr_cdcooper IN NUMBER
                                         ,pr_cdprogra IN VARCHAR2
                                         ,pr_dtmvtolt IN VARCHAR2
                                         ,pr_dtrefere IN VARCHAR2);
   
END RISC0002;
/
CREATE OR REPLACE PACKAGE BODY CECRED.RISC0002 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : RISC0002
  --  Sistema  : Rotinas para Calculos de Risco
  --  Sigla    : RISC
  --  Autor    : James Prust Junior
  --  Data     : Fevereiro/2016.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas genericas para a importacao dos dados para a central de risco
  --
  -- Alterações: 06/06/2017 - Inclusao do novo tipo de saldo (7 - PAR (parcelado rotativo)).
  --                          Procedure pc_import_arq_risco_cartao.
  --                          (Chamado 687323) - (Fabricio)
	--
	--             16/07/2019 - Inclusão do novo tipo de saldo (8 - Saldo parcela não quitada).
  --                          (Reinert - RITM0028079)	
  ---------------------------------------------------------------------------------------------------------------  
  PROCEDURE pc_verifica_envio_email(pr_tab_crapcop IN RISC0002.typ_tab_crapcop --> Temp-Table Cooperativas
                                   ,pr_dtrefere    IN DATE                     --> Data de Referencia
                                   ,pr_cdcritic    OUT PLS_INTEGER             --> Código da crítica
                                   ,pr_dscritic    OUT VARCHAR2) IS            --> Descrição da crítica
  BEGIN                          
    ---------------------------------------------------------------------------------------------------------------
    --  Programa : pc_verifica_envio_email
    --  Sistema  : Ayllos
    --  Sigla    : CRED
    --  Autor    : James Prust Junior
    --  Data     : Fevereiro/2016.                   Ultima atualizacao: 03/01/2016
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Envio de email para a area responsavel
    --
    -- Alterações 03/01/2016 - Ajustes para ignorar cartões das coops inatvas(Migração/Incorporacao)
    --                         (Odirlei-AMcom) 
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      CURSOR cr_crawcrd IS
        SELECT DISTINCT
               crawcrd.cdcooper
              ,tbcrd_bandeira.idbandeira
              ,tbcrd_bandeira.nmbandeira
          FROM crawcrd
          JOIN crapadc
            ON crapadc.cdcooper = crawcrd.cdcooper
           AND crapadc.cdadmcrd = crawcrd.cdadmcrd
          JOIN tbcrd_bandeira
            ON TRIM(UPPER(tbcrd_bandeira.nmbandeira)) = TRIM(UPPER(crapadc.nmbandei))
         WHERE crawcrd.cdadmcrd >= 10
           AND crawcrd.cdadmcrd <= 80
           AND crawcrd.insitcrd = 4
           AND crawcrd.vllimcrd > 0;
      
      CURSOR cr_tbcrd_arq_risco(pr_dtrefere IN DATE) IS
        SELECT tbcrd_arq_risco.cdcooper
              ,tbcrd_arq_risco.idbandeira
              ,tbcrd_bandeira.nmbandeira
              ,tbcrd_arq_risco.cdsituacao
          FROM tbcrd_arq_risco
          JOIN tbcrd_bandeira
            ON tbcrd_bandeira.idbandeira = tbcrd_arq_risco.idbandeira
         WHERE tbcrd_arq_risco.dtrefere  = pr_dtrefere
      ORDER BY tbcrd_arq_risco.cdsituacao DESC;
      
      -- Definicao de tipo de registro
      TYPE typ_reg_arquivos IS
        RECORD (cdcooper    tbcrd_arq_risco.cdcooper%TYPE
               ,nmbandeira  tbcrd_bandeira.nmbandeira%TYPE
               ,cdsituacao  tbcrd_arq_risco.cdsituacao%TYPE);
      TYPE typ_tab_arquivos IS TABLE OF typ_reg_arquivos INDEX BY VARCHAR2(20);
      vr_tab_arquivos typ_tab_arquivos;
      
      vr_desemail   VARCHAR(4000) := '';
      vr_indice     VARCHAR2(20);
      vr_indice_cop VARCHAR2(20);
      
      -- Variaveis de Erro
      vr_cdcritic   crapcri.cdcritic%TYPE;
      vr_dscritic   VARCHAR2(4000);

      -- Variaveis Excecao
      vr_exc_erro   EXCEPTION;    
    BEGIN
      -- Buscar todas as bandeiras que sao obrigatorias ter arquivo
      FOR rw_crawcrd IN cr_crawcrd LOOP
        vr_indice := LPAD(rw_crawcrd.cdcooper,10,'0') || LPAD(rw_crawcrd.idbandeira,10,'0');
        vr_tab_arquivos(vr_indice).cdcooper   := rw_crawcrd.cdcooper;
        vr_tab_arquivos(vr_indice).nmbandeira := rw_crawcrd.nmbandeira;
        vr_tab_arquivos(vr_indice).cdsituacao := 0;
      END LOOP;
      
      -- Carregar todas as bandeiras processadas
      FOR rw_tbcrd_arq_risco IN cr_tbcrd_arq_risco(pr_dtrefere => pr_dtrefere) LOOP
        vr_indice := LPAD(rw_tbcrd_arq_risco.cdcooper,10,'0') || LPAD(rw_tbcrd_arq_risco.idbandeira,10,'0');
        IF NOT vr_tab_arquivos.EXISTS(vr_indice) THEN
          vr_tab_arquivos(vr_indice).cdcooper   := rw_tbcrd_arq_risco.cdcooper;
          vr_tab_arquivos(vr_indice).nmbandeira := rw_tbcrd_arq_risco.nmbandeira;
        END IF;
        vr_tab_arquivos(vr_indice).cdsituacao := rw_tbcrd_arq_risco.cdsituacao;
      END LOOP;
      
      -- Percorre todos os arquivos
      vr_indice := vr_tab_arquivos.first;
      WHILE vr_indice IS NOT NULL LOOP
        vr_indice_cop := LPAD(vr_tab_arquivos(vr_indice).cdcooper,10,'0');
      
        --> Apenas tratar coops ativas, pois podem existir dados de cartao
        --> de coops migradas/incorporadas        
        IF pr_tab_crapcop.exists(vr_indice_cop) THEN        
        
          -- Texto do e-mail
          vr_desemail := vr_desemail || 
                         pr_tab_crapcop(vr_indice_cop).nmrescop ||' - ' ||
                         vr_tab_arquivos(vr_indice).nmbandeira  || ': ';
                       
          IF vr_tab_arquivos(vr_indice).cdsituacao = 0 THEN
            vr_desemail := vr_desemail || 'Arquivo nao importado <br />';
          ELSIF vr_tab_arquivos(vr_indice).cdsituacao = 1 THEN
            vr_desemail := vr_desemail || 'Arquivo importado com sucesso <br />';
          ELSIF vr_tab_arquivos(vr_indice).cdsituacao = 2 THEN
            vr_desemail := vr_desemail || 'Arquivo importado com criticas <br />';
          END IF;
        END IF;
        -- Proxima linha
        vr_indice := vr_tab_arquivos.next(vr_indice);
      END LOOP;

      IF TRIM(vr_desemail) IS NOT NULL THEN
        -- Envia email aos responsaveis pela importacao do arquivo CB117
        gene0003.pc_solicita_email(pr_cdcooper        => 3
                                  ,pr_cdprogra        => 'RISC0002'
                                  ,pr_des_destino     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                                                   pr_cdacesso => 'RISCO_CARTAO_EMAIL')
                                  ,pr_des_assunto     => 'IMPORTACAO ARQUIVO RISCO CARTAO CB117'
                                  ,pr_des_corpo       => vr_desemail
                                  ,pr_des_anexo       => NULL --> nao envia anexo, anexo esta disponivel no dir conf. geracao do arq.
                                  ,pr_flg_remove_anex => 'N'  --> Remover os anexos passados
                                  ,pr_flg_remete_coop => 'N'  --> Se o envio sera do e-mail da Cooperativa
                                  ,pr_flg_enviar      => 'S'  --> Enviar o e-mail na hora
                                  ,pr_des_erro        => vr_dscritic);

        -- Se houver erros
        IF vr_dscritic IS NOT NULL THEN
           RAISE vr_exc_erro;
        END IF;  
      END IF;
        
    EXCEPTION
      WHEN vr_exc_erro THEN
        --Variavel de erro recebe erro ocorrido
        IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        -- Descricao do erro
        pr_dscritic := 'Erro nao tratado na RISC0002.pc_verifica_envio_email ' || SQLERRM;
    END;
    
  END pc_verifica_envio_email;
  
  PROCEDURE pc_atualiza_param_risco_cartao(pr_cdcooper IN crapcop.cdcooper%TYPE
                                          ,pr_tipsplit IN GENE0002.typ_split
		  				    				        	      ,pr_dscritic OUT VARCHAR2) IS --> Descrição da crítica
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --  Programa : pc_atualiza_param_arq_contabil
    --  Sistema  : Ayllos
    --  Sigla    : CRED
    --  Autor    : James Prust Junior
    --  Data     : Fevereiro/2016.                   Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Atualizar o status de controle de importacao do arquivo
    -- 
    -- Alterações
    ---------------------------------------------------------------------------------------------------------------
    DECLARE 
      vr_dsvlrprm crapprm.dsvlrprm%TYPE;
      vr_total    INTEGER;
    BEGIN
      vr_total := pr_tipsplit.COUNT;
      FOR vr_indice IN pr_tipsplit.first .. pr_tipsplit.last LOOP
        IF vr_total = vr_indice THEN
          vr_dsvlrprm := vr_dsvlrprm || pr_tipsplit(vr_indice);
        ELSE
          vr_dsvlrprm := vr_dsvlrprm || pr_tipsplit(vr_indice) || ';';
        END IF;
      END LOOP;
      
      BEGIN
        UPDATE crapprm
           SET dsvlrprm = vr_dsvlrprm
         WHERE cdcooper = pr_cdcooper
           AND UPPER(nmsistem) = 'CRED' 
           AND UPPER(cdacesso) = 'RISCO_CARTAO_BACEN';
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro ao atualizar crapprm: ' || SQLERRM;
      END;
    END;
    
  END pc_atualiza_param_risco_cartao;
  
  PROCEDURE pc_gera_log(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_cdprogra IN crapprg.cdprogra%TYPE
                       ,pr_cdorigem IN INTEGER
                       ,pr_cdcritic IN crapcri.cdcritic%TYPE
                       ,pr_dscritic IN crapcri.dscritic%TYPE) IS
  BEGIN                  
    ---------------------------------------------------------------------------------------------------------------
    --  Programa : pc_gera_log
    --  Sistema  : Ayllos
    --  Sigla    : CRED
    --  Autor    : James Prust Junior
    --  Data     : Fevereiro/2016.                   Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Atualizar o status de controle de importacao do arquivo
    -- 
    -- Alterações
    ---------------------------------------------------------------------------------------------------------------                        
    DECLARE
      vr_cdcooper PLS_INTEGER;
      vr_dscritic VARCHAR2(4000);    
    BEGIN
      vr_cdcooper := pr_cdcooper;
      vr_dscritic := pr_dscritic;
      -- Job
      IF pr_cdorigem = 7 THEN
        -- CECRED
        vr_cdcooper := 3;
      END IF;
      -- Se foi passado somente o codigo da critica
      IF pr_cdcritic > 0 AND pr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      -- Se foi passado como parametro o codigo da critica e a descricao da critica          
      ELSIF pr_cdcritic > 0 AND pr_dscritic IS NOT NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic) || ' --> ' || vr_dscritic;
      END IF;
      -- Monta a descricao para o LOG
      vr_dscritic := TO_CHAR(SYSDATE,'HH24:MI:SS') || ' - ' || pr_cdprogra || ' --> ' || vr_dscritic;
      -- Gera o LOG
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2
                                ,pr_des_log      => vr_dscritic);
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
            
  END pc_gera_log;
  
  PROCEDURE pc_atualiza_arq_processado(pr_idarquivo  IN tbcrd_arq_risco.idarquivo%TYPE
                                      ,pr_cdsituacao IN tbcrd_arq_risco.cdsituacao%TYPE
                                      ,pr_cdcritic   IN crapcri.cdcritic%TYPE
                                      ,pr_dscritica  IN tbcrd_arq_risco.dscritica%TYPE) IS
  BEGIN                  
    ---------------------------------------------------------------------------------------------------------------
    --  Programa : pc_atualiza_arq_processado
    --  Sistema  : Ayllos
    --  Sigla    : CRED
    --  Autor    : James Prust Junior
    --  Data     : Marco/2016.                   Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Atualiza os dados do arquivo processado
    -- 
    -- Alterações
    ---------------------------------------------------------------------------------------------------------------                        
    DECLARE
      vr_dscritic tbcrd_arq_risco.dscritica%TYPE;
    BEGIN
      -- Se foi passado somente o codigo da critica
      IF pr_cdcritic > 0 AND pr_dscritica IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      ELSE
        vr_dscritic := pr_dscritica;          
      END IF;
    
      BEGIN
        UPDATE tbcrd_arq_risco
           SET cdsituacao = pr_cdsituacao
              ,dscritica  = vr_dscritic
         WHERE idarquivo  = pr_idarquivo;
      END;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
            
  END pc_atualiza_arq_processado;
  
  PROCEDURE pc_lista_arquivos(pr_cdagebcb IN crapcop.cdagebcb%TYPE    --> Agencia do Bancoob
                             ,pr_dsdirarq IN crapscb.dsdirarq%TYPE    --> Diretorio que contem os arquivos
                             ,pr_listadir OUT VARCHAR2                --> Arquivos que serao importados
                             ,pr_nmrquivo OUT VARCHAR2                --> Nome do Arquivo
                             ,pr_cdcritic OUT PLS_INTEGER             --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2) IS            --> Descrição da crítica 
  BEGIN                  
    ---------------------------------------------------------------------------------------------------------------
    --  Programa : pc_lista_arquivos
    --  Sistema  : Ayllos
    --  Sigla    : CRED
    --  Autor    : James Prust Junior
    --  Data     : Fevereiro/2016.                   Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Listar os arquivos que serao importados
    -- 
    -- Alterações
    ---------------------------------------------------------------------------------------------------------------                        
    DECLARE
      -- Variaveis de Erro
      vr_cdcritic   crapcri.cdcritic%TYPE;
      vr_dscritic   VARCHAR2(4000);

      -- Variaveis Excecao
      vr_exc_erro   EXCEPTION;
    BEGIN
      -- monta nome do arquivo
      pr_nmrquivo := '756_2011_' || TO_CHAR(lpad(pr_cdagebcb,4,'0')) || '_05_CB117';
      -- Recupera a lista de arquivos "CB117"
      gene0001.pc_lista_arquivos(pr_path     => pr_dsdirarq || '/recebe',
                                 pr_pesq     => pr_nmrquivo || '%',
                                 pr_listarq  => pr_listadir,
                                 pr_des_erro => vr_dscritic);
                                     
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF; 
    EXCEPTION
      WHEN vr_exc_erro THEN
        --Variavel de erro recebe erro ocorrido
        IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        -- Descricao do erro
        pr_dscritic := 'Erro nao tratado na RISC0002.pc_lista_arquivos ' || SQLERRM;
    END;
            
  END pc_lista_arquivos;    
  
  /* Procedure para mover arquivos processados para a pasta /USR/CONNECT/BANCOOB/RECEBIDOS */
  PROCEDURE pc_move_arquivo_recebido(pr_cdcooper IN crapcop.cdcooper%TYPE
                                    ,pr_cdorigem IN INTEGER
                                    ,pr_nmdireto IN VARCHAR2     --> Caminho de arquivos do Bancoob/CABAL
                                    ,pr_nmrquivo IN VARCHAR2) IS --> Nome do arquivo  
  BEGIN
    ---------------------------------------------------------------------------------------------------------------------
    --  Programa : pc_move_arquivo_recebido
    --  Sistema  : Ayllos
    --  Sigla    : CRED
    --  Autor    : Carlos Rafael Tanholi
    --  Data     : Marco/2016.                   Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Esta rotina será acionada pela procedure pc_importa_arq_risco_cartao para salvar os arquivos recebidos
    -- 
    -- Alterações
    ---------------------------------------------------------------------------------------------------------------------
    DECLARE       
       vr_comando   VARCHAR2(2000); --> Comando UNIX para Mover arquivo lido
       vr_typ_saida VARCHAR2(100);  -- Tipo de saida
       
       -- Variaveis tratamento de erros
       vr_cdcritic  PLS_INTEGER;
       vr_dscritic  VARCHAR2(4000);
    BEGIN
      vr_comando := 'mv '|| pr_nmdireto || '/recebe/' || pr_nmrquivo || ' ' || pr_nmdireto || '/recebidos/';
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_comando                           
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);
                           
      IF vr_dscritic IS NOT NULL THEN
        -- Grava LOG
        pc_gera_log(pr_cdcooper => pr_cdcooper
                   ,pr_cdprogra => 'JOB_CARTAO_RISCO'
                   ,pr_cdorigem => pr_cdorigem
                   ,pr_cdcritic => vr_cdcritic
                   ,pr_dscritic => vr_dscritic);
      END IF;                      
    END;
  
  END pc_move_arquivo_recebido;  
  
  PROCEDURE pc_importa_arq_layout(pr_cdcooper             IN crapcop.cdcooper%TYPE                --> Codigo da cooperativa
                                 ,pr_cdagebcb             IN crapcop.cdagebcb%TYPE                --> Agencia do Bancoob
                                 ,pr_dtrefere             IN DATE                                 --> Data de Referencia                                
                                 ,pr_nmarquiv             IN VARCHAR2                             --> Nome do arquivo
                                 ,pr_cdbandeira           OUT tbcrd_arq_risco.idbandeira%TYPE     --> Codigo da bandeira
                                 ,pr_tab_linhas_arquivo   OUT RISC0002.typ_tab_linhas_arquivo     --> Temp-Table com todas as linhas do arquivo
                                 ,pr_tab_linhas_controle  OUT RISC0002.typ_tab_linhas_controle    --> Temp-Table com as linhas que sera feito a provisao
                                 ,pr_cdcritic             OUT PLS_INTEGER                         --> Código da critica
  				    				        	 ,pr_dscritic             OUT VARCHAR2) IS                        --> Descricao da critica IS
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --  Programa : pc_importa_arq_layout
    --  Sistema  : Ayllos
    --  Sigla    : CRED
    --  Autor    : James Prust Junior
    --  Data     : Fevereiro/2016.                   Ultima atualizacao: 03/01/2016
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Importa o arquivo de layout
    --
    -- Alterações: 03/01/2016 - Incluido tratamento para fechar arquivo ao fim da importação(Odirlei-AMcom)
    --
    --             06/06/2017 - Inclusao do novo tipo de saldo (7 - PAR (parcelado rotativo)).
    --                          (Chamado 687323) - (Fabricio)
		--
	  --             16/07/2019 - Inclusão do novo tipo de saldo (8 - Saldo parcela não quitada).
    --                          (Reinert - RITM0028079)
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      CURSOR cr_tbcrd_arq_risco (pr_cdcooper   IN tbcrd_arq_risco.cdcooper%TYPE
                                ,pr_dtrefere   IN tbcrd_arq_risco.dtrefere%TYPE
                                ,pr_idbandeira IN tbcrd_arq_risco.idbandeira%TYPE) IS
        SELECT 1
          FROM tbcrd_arq_risco
         WHERE tbcrd_arq_risco.cdcooper   = pr_cdcooper
           AND tbcrd_arq_risco.dtrefere   = pr_dtrefere                              
           AND tbcrd_arq_risco.idbandeira = pr_idbandeira
           AND tbcrd_arq_risco.cdsituacao = 1;
      vr_flgexcrd PLS_INTEGER := 0;
      
      vr_input_file         UTL_FILE.FILE_TYPE;               -- Handle para leitura de arquivo
      vr_setlinha           VARCHAR2(4000);                   -- Texto do arquivo lido
      vr_tipo_registro      NUMBER(10);                       -- Tipo de Registro
      vr_periodobase        INTEGER;                          -- Periodo Base
      vr_cdagebcb           crapcop.cdagebcb%TYPE;            -- Agencia do Bancoob
      vr_nrdconta_cartao    tbcrd_risco.nrdconta_cartao%TYPE; -- Numero da conta cartao
      vr_nrcpfcnpj          crapris.nrcpfcgc%TYPE;
      vr_ind_arq_importado  VARCHAR2(50);
    
      -- Variaveis tratamento de erro
      vr_exc_erro           EXCEPTION;
      vr_cdcritic           crapcri.cdcritic%TYPE;
      vr_dscritic           VARCHAR2(4000);      
    BEGIN
      pr_tab_linhas_arquivo.DELETE;
      
      -- Carrega arquivo
      gene0001.pc_abre_arquivo(pr_nmcaminh => pr_nmarquiv   --> Nome do arquivo
                              ,pr_tipabert => 'R'           --> Modo de abertura (R,W,A)
                              ,pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                              ,pr_des_erro => vr_dscritic); --> Descricao do erro

      -- Laco para leitura de linhas do arquivo
      LOOP
        -- Carrega handle do arquivo
        gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                    ,pr_des_text => vr_setlinha); --> Texto lido
                                      
        -- Tipo de Registro. (HEADER, DETAIL, FOOTER)                            
        vr_tipo_registro := SUBSTR(vr_setlinha,11,1);
          
        -- HEADER
        IF vr_tipo_registro = '0' THEN
          vr_periodobase := TO_NUMBER(SUBSTR(vr_setlinha,25,6)); -- Periodo base
          vr_cdagebcb    := TO_NUMBER(SUBSTR(vr_setlinha,21,4)); -- Agencia
          pr_cdbandeira  := TO_NUMBER(SUBSTR(vr_setlinha,31,3)); -- Codigo da bandeira
          
          IF pr_cdbandeira NOT IN (1,5) THEN
            vr_dscritic := 'Codigo da bandeira invalida. Coop: ' || pr_cdcooper || '. Bandeira: ' || pr_cdbandeira;
            RAISE vr_exc_erro;
          END IF;

          -- Vamos verificar o periodo base do arquivo
          IF TO_CHAR(pr_dtrefere,'RRRRMM') <> TO_CHAR(vr_periodobase) THEN
            vr_dscritic := 'Periodo base invalido. Coop: ' || pr_cdcooper || '. Periodo: ' || vr_periodobase;
            RAISE vr_exc_erro;
          END IF;
            
          -- Vamos validar o codigo da agencia
          IF pr_cdagebcb <> vr_cdagebcb THEN
            vr_dscritic := 'Numero da agencia invalida. Coop: ' || pr_cdcooper || '. Agencia: ' || vr_cdagebcb;
            RAISE vr_exc_erro;
          END IF;

          -- Valida se o codigo da bandeira jah foi processado
          OPEN cr_tbcrd_arq_risco(pr_cdcooper   => pr_cdcooper
                                 ,pr_dtrefere   => pr_dtrefere
                                 ,pr_idbandeira => pr_cdbandeira);
          FETCH cr_tbcrd_arq_risco
           INTO vr_flgexcrd;
          CLOSE cr_tbcrd_arq_risco;                        
          
          IF NVL(vr_flgexcrd,0) = 1 THEN
            vr_dscritic := 'Bandeira ja foi processada. Coop: ' || pr_cdcooper || 
                           '. Bandeira: ' || pr_cdbandeira || 
                           '. Data Referencia: ' || TO_CHAR(pr_dtrefere,'DD/MM/RRRR');
            RAISE vr_exc_erro;
          END IF;          
          
          -- Proxima Linha
          CONTINUE;
        END IF;
          
        -- DETAIL
        IF vr_tipo_registro = '1' THEN
          vr_nrdconta_cartao   := TO_NUMBER(SUBSTR(vr_setlinha,26,20));
          vr_nrcpfcnpj         := TO_NUMBER(TRIM(SUBSTR(vr_setlinha,12,14)));
          -- Indice da Temp-Table
          vr_ind_arq_importado := SUBSTR(vr_setlinha,1,10);
          pr_tab_linhas_arquivo(vr_ind_arq_importado).cdcooper        := pr_cdcooper;
          pr_tab_linhas_arquivo(vr_ind_arq_importado).nrdconta_cartao := vr_nrdconta_cartao;
          pr_tab_linhas_arquivo(vr_ind_arq_importado).nrcpfcnpj       := vr_nrcpfcnpj;
          pr_tab_linhas_arquivo(vr_ind_arq_importado).dtcadastro      := TO_DATE(SUBSTR(vr_setlinha,46,8),'YYYYMMDD');
          pr_tab_linhas_arquivo(vr_ind_arq_importado).cdtipo_saldo    := TO_NUMBER(SUBSTR(vr_setlinha,54,4));
          pr_tab_linhas_arquivo(vr_ind_arq_importado).vltaxa_juros    := (TO_NUMBER(SUBSTR(vr_setlinha,58,7)) / 100) / 100;
          pr_tab_linhas_arquivo(vr_ind_arq_importado).dtvencimento    := TO_DATE(SUBSTR(vr_setlinha,65,8),'YYYYMMDD');
          pr_tab_linhas_arquivo(vr_ind_arq_importado).vlsaldo_devedor := TO_NUMBER(SUBSTR(vr_setlinha,73,15)) / 100;
          pr_tab_linhas_arquivo(vr_ind_arq_importado).vlcet           := TO_NUMBER(SUBSTR(vr_setlinha,88,6)) / 100;
          
          /*
          Somente sera feito o provisionamento quando o cartao de credito possuir os saldos 1,2,3,4,7,8.
          1 - Saldo à vista  financiado (rotativo + saques à vista).
          2 - Saldo à vista não financiado.
          3 - Saldo parcelado sem juros.
          4 - Saldo parcelado com juros.
          5 - LImite disponível à vista.
          6 - LImite disponível parcelado.        
          7 - PAR (parcelado rotativo)
					8 - Saldo parcela não quitada
          */
          IF pr_tab_linhas_arquivo(vr_ind_arq_importado).cdtipo_saldo IN (1,2,3,4,7,8) THEN
            vr_ind_arq_importado := LPAD(vr_nrdconta_cartao,20,'0') || LPAD(vr_nrcpfcnpj,20,'0');
            -- Controle para informar que o registro sera provisionado
            pr_tab_linhas_controle(vr_ind_arq_importado) := 1;
          END IF;          
        END IF;
          
        -- Footer
        IF vr_tipo_registro = '9' THEN
          --> Fechar arquivo
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
          EXIT;          
        END IF;
        
      END LOOP; /* END LOOP */    
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        --Variavel de erro recebe erro ocorrido
        IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        -- Descricao do erro
        pr_dscritic := 'Erro nao tratado na RISC0002.pc_importa_arq_layout( '||pr_cdagebcb||')' || SQLERRM;
    END;
    
  END pc_importa_arq_layout;

  PROCEDURE pc_efetua_arrasto(pr_cdcooper IN crapcop.cdcooper%TYPE  --> codigo da cooperativa
                             ,pr_dtrefere IN DATE                   --> Data de Referencia
                             ,pr_cdcritic OUT PLS_INTEGER           --> Código da critica
  				    				       ,pr_dscritic OUT VARCHAR2) IS          --> Descricao da critica
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --  Programa : pc_efetua_arrasto
    --  Sistema  : Ayllos
    --  Sigla    : CRED
    --  Autor    : James Prust Junior
    --  Data     : Fevereiro/2016.                   Ultima atualizacao: 24/10/2017
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Efetua o arrasto das operacoes
    --
    -- Alterações: 24/10/2017 - Atualizacao do Grupo Economico fora do loop da crapris com valor de arrasto.
    --                          (Jaison/James)
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      CURSOR cr_crapris_last(pr_cdcooper IN crapris.cdcooper%TYPE
                            ,pr_nrdconta IN crapris.nrdconta%TYPE
                            ,pr_dtrefere IN crapris.dtrefere%TYPE
                            ,pr_vlarrast IN crapris.vldivida%TYPE) IS
        SELECT /*+index_desc (crapris CRAPRIS##CRAPRIS1)*/
               innivris
          FROM crapris
         WHERE crapris.cdcooper = pr_cdcooper
           AND crapris.nrdconta = pr_nrdconta
           AND crapris.dtrefere = pr_dtrefere           
           AND crapris.inddocto = 1
           AND (crapris.vldivida > pr_vlarrast OR pr_vlarrast = 0);
      rw_crapris_last cr_crapris_last%ROWTYPE;
    
      CURSOR cr_crapris (pr_cdcooper  IN crapris.cdcooper%TYPE
                        ,pr_dtrefere  IN crapris.dtrefere%TYPE
                        ,pr_vlarrasto IN NUMBER) IS
        SELECT cdcooper
              ,nrdconta
              ,nrctremp
              ,cdmodali
              ,dtrefere
              ,innivori
              ,nrseqctr
              ,innivris
              ,rowid
              ,ROW_NUMBER () OVER (PARTITION BY nrdconta
                                       ORDER BY nrdconta,innivris DESC) sequencia
          FROM crapris
         WHERE cdcooper = pr_cdcooper
           AND dtrefere = pr_dtrefere
           AND inddocto = 4
           AND vldivida > pr_vlarrasto --> Valor dos parâmetros        
      ORDER BY nrdconta
              ,innivris DESC;

      CURSOR cr_upd_ris(pr_cdcooper IN crapris.cdcooper%TYPE
                       ,pr_dtrefere IN crapris.dtrefere%TYPE) IS
        SELECT crapris.ROWID
              ,crapris.nrcpfcgc
          FROM crapris
         WHERE crapris.cdcooper = pr_cdcooper
           AND crapris.dtrefere = pr_dtrefere
           AND crapris.inddocto = 4;

      CURSOR cr_max_ris(pr_cdcooper IN crapris.cdcooper%TYPE
                       ,pr_dtrefere IN crapris.dtrefere%TYPE) IS
        SELECT NVL(MAX(crapris.nrdgrupo),0) nrdgrupo
              ,crapris.nrcpfcgc
          FROM crapris
         WHERE crapris.cdcooper = pr_cdcooper
           AND crapris.dtrefere = pr_dtrefere           
           AND crapris.inddocto IN (1,3)
      GROUP BY crapris.nrcpfcgc;

      TYPE typ_tab_max_ris IS TABLE OF crapris.nrdgrupo%TYPE INDEX BY VARCHAR2(25);

      TYPE typ_upd_ris IS RECORD (regrowid ROWID
                                 ,nrdgrupo crapris.nrdgrupo%TYPE);
      TYPE typ_tab_upd_ris IS TABLE OF typ_upd_ris INDEX BY PLS_INTEGER;

      vr_tab_grupo    typ_tab_max_ris;
      vr_tab_upris    typ_tab_upd_ris;

      vr_dstextab     craptab.dstextab%TYPE;        
      vr_innivris     crapris.innivris%TYPE;
      vr_vlarrasto    NUMBER;      
      vr_fcrapris     BOOLEAN;
      vr_ind_upris    PLS_INTEGER;

      -- Variaveis tratamento de erro
      vr_exc_erro     EXCEPTION;
      vr_cdcritic     crapcri.cdcritic%TYPE;
      vr_dscritic     VARCHAR2(4000);
    BEGIN
      -- Chamar função que busca o dstextab para retornar o valor de arrasto
      -- no parâmetro de sistema RISCOBACEN
      vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'RISCOBACEN'
                                               ,pr_tpregist => 000);
      -- Se a variavel voltou vazia
      IF vr_dstextab IS NULL THEN
        vr_cdcritic := 55;
        -- Envio centralizado de log de erro
        RAISE vr_exc_erro;
      END IF;
      -- Por fim, tenta converter o valor de arrasto presente na posição 3 até 12
      vr_vlarrasto := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,3,9));
      -- Efetua o arrasto para as operacoes acima de 100,00
      FOR rw_crapris IN cr_crapris(pr_cdcooper  => pr_cdcooper
                                  ,pr_dtrefere  => pr_dtrefere
                                  ,pr_vlarrasto => vr_vlarrasto) LOOP
                                  
        -- Para o primeiro registro da conta
        IF rw_crapris.sequencia = 1 THEN
          -- Risco calculado do cartao de credito
          vr_innivris := rw_crapris.innivris;          
          -- Vamos verificar se possui operacao na mensal acima de 100,00
          OPEN cr_crapris_last(pr_cdcooper => rw_crapris.cdcooper
                              ,pr_nrdconta => rw_crapris.nrdconta
                              ,pr_dtrefere => pr_dtrefere
                              ,pr_vlarrast => vr_vlarrasto);
          FETCH cr_crapris_last INTO rw_crapris_last;
          vr_fcrapris := cr_crapris_last%FOUND;
          CLOSE cr_crapris_last;
          -- Condicao para verificar se existe registro          
          IF vr_fcrapris THEN
            vr_innivris := rw_crapris_last.innivris;
          ELSE
            -- Vamos verificar se possui operacao na mensal abaixo de 100,00
            OPEN cr_crapris_last(pr_cdcooper => rw_crapris.cdcooper
                                ,pr_nrdconta => rw_crapris.nrdconta
                                ,pr_dtrefere => pr_dtrefere
                                ,pr_vlarrast => 0);
            FETCH cr_crapris_last INTO rw_crapris_last;
            vr_fcrapris := cr_crapris_last%FOUND;
            CLOSE cr_crapris_last;
            -- Condicao para verificar se existe registro
            IF vr_fcrapris THEN
              vr_innivris := rw_crapris_last.innivris;
            END IF;            
          END IF;
          
        END IF; /* END IF rw_crapris.sequencia = 1 THEN */
        
        -- Prejuizo
        IF vr_innivris = 10 THEN
          vr_innivris := 9;
        END IF;

        -- Atualizar o risco
        BEGIN
          UPDATE crapris
             SET innivris = vr_innivris
                ,inindris = vr_innivris
           WHERE rowid = rw_crapris.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar a tabela crapris. --> '
                           || 'Conta: '||rw_crapris.nrdconta||', Rowid: '||rw_crapris.rowid
                           || '. Detalhes:'||sqlerrm;
            RAISE vr_exc_erro;
        END;
        
        -- Atualizar o risco
        BEGIN
          UPDATE crapvri
             SET innivris = vr_innivris
           WHERE cdcooper = rw_crapris.cdcooper
             AND nrdconta = rw_crapris.nrdconta
             AND nrctremp = rw_crapris.nrctremp
             AND cdmodali = rw_crapris.cdmodali
             AND dtrefere = rw_crapris.dtrefere
             AND nrseqctr = rw_crapris.nrseqctr;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar a tabela crapvri. --> '
                           || 'Conta: '||rw_crapris.nrdconta||', Rowid: '||rw_crapris.rowid
                           || '. Detalhes:'||sqlerrm;
            RAISE vr_exc_erro;
        END;

      END LOOP; -- Fim riscos

      -- Carrega maior grupo economico do CPF/CNPJ
      FOR rw_max_ris IN cr_max_ris(pr_cdcooper => pr_cdcooper
                                  ,pr_dtrefere => pr_dtrefere) LOOP
        vr_tab_grupo(rw_max_ris.nrcpfcgc) := rw_max_ris.nrdgrupo;
      END LOOP;

      -- Listagem dos registros
      FOR rw_upd_ris IN cr_upd_ris(pr_cdcooper => pr_cdcooper
                                  ,pr_dtrefere => pr_dtrefere) LOOP
        -- Se existir o CPF/CNPJ nos grupos carregados
        IF vr_tab_grupo.EXISTS(rw_upd_ris.nrcpfcgc) THEN
          -- Se grupo maior que zero, carrega na tabela para update
          IF vr_tab_grupo(rw_upd_ris.nrcpfcgc) > 0 THEN
            vr_ind_upris := vr_tab_upris.COUNT + 1;
            vr_tab_upris(vr_ind_upris).regrowid := rw_upd_ris.ROWID;
            vr_tab_upris(vr_ind_upris).nrdgrupo := vr_tab_grupo(rw_upd_ris.nrcpfcgc);
          END IF;
        END IF;
      END LOOP;

      -- Atualizar registros
      BEGIN
        FORALL idx IN 1..vr_tab_upris.COUNT SAVE EXCEPTIONS
        UPDATE crapris
           SET nrdgrupo = vr_tab_upris(idx).nrdgrupo
         WHERE ROWID    = vr_tab_upris(idx).regrowid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar crapris: ' || SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
          RAISE vr_exc_erro;
      END;

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Variavel de erro recebe erro ocorrido
        IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        -- Descricao do erro
        pr_dscritic := 'Erro nao tratado na RISC0002.pc_efetua_arrasto ' || SQLERRM;
    END;
    
  END pc_efetua_arrasto;
              
  PROCEDURE pc_grava_crapris_temporaria(pr_cdcooper          IN tbcrd_risco.cdcooper%TYPE         -- Codigo da cooperativa
                                       ,pr_nrdconta          IN tbcrd_risco.nrdconta%TYPE         -- Numero da conta
                                       ,pr_inpessoa          IN crapris.inpessoa%TYPE             -- Tipo de pessoa
                                       ,pr_nrcontrato        IN tbcrd_risco.nrcontrato%TYPE       -- Numero do contrato
                                       ,pr_cdagencia         IN crapris.cdagenci%TYPE             -- Numero da agencia
                                       ,pr_nrcpfcnpj         IN tbcrd_risco.nrcpfcnpj%TYPE        -- CPF/CNPJ
                                       ,pr_nrmodalidade      IN tbcrd_risco.nrmodalidade%TYPE     -- Codigo da modalidade
                                       ,pr_dtultdma_util     IN DATE                              -- Ultima dia util do mes anterior
                                       ,pr_dtcadastro        IN tbcrd_risco.dtcadastro%TYPE       -- Data de abertura da conta cartao
                                       ,pr_cdtipo_saldo      IN tbcrd_risco.cdtipo_saldo%TYPE     -- Tipo de saldo
                                       ,pr_dtvencimento      IN tbcrd_risco.dtvencimento%TYPE     -- Data de vencimento
                                       ,pr_vlsaldo_devedor   IN tbcrd_risco.vlsaldo_devedor%TYPE  -- Saldo Devedor
                                       ,pr_tab_risco_cartao  IN OUT NOCOPY RISC0002.typ_tab_risco_cartao   --> Temp-Table do risco do cartao de credito
                                       ,pr_cdcritic          OUT PLS_INTEGER                     --> Código da critica
  				    				        	       ,pr_dscritic          OUT VARCHAR2) IS                    --> Descricao da critica IS
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --  Programa : pc_grava_crapris_temporaria
    --  Sistema  : Ayllos
    --  Sigla    : CRED
    --  Autor    : James Prust Junior
    --  Data     : Fevereiro/2016.                   Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para gravar os dados na crapris temporaria
    --
    -- Alterações: 06/06/2017 - Inclusao do novo tipo de saldo (7 - PAR (parcelado rotativo)).
    --                          (Chamado 687323) - (Fabricio)
		--
	  --             16/07/2019 - Inclusão do novo tipo de saldo (8 - Saldo parcela não quitada).
    --                          (Reinert - RITM0028079)		
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      vr_ind_risco          VARCHAR2(50);
      vr_qtdiaatr           INTEGER;
      
      -- Variaveis tratamento de erro
      vr_exc_erro           EXCEPTION;
      vr_cdcritic           crapcri.cdcritic%TYPE;
      vr_dscritic           VARCHAR2(4000);
      
      -- Calcula os dias de atraso do cartao de credito
      FUNCTION fn_calcula_dias_atraso(pr_dtvencimento  IN DATE
                                     ,pr_dtultdma_util IN DATE) RETURN NUMBER IS
      BEGIN
        IF (pr_dtvencimento - pr_dtultdma_util) <= 0 THEN
          RETURN ABS(pr_dtvencimento - pr_dtultdma_util);
        END IF;
        
        RETURN 0;        
      END;
      
      -- Calculo do nivel de risco
      FUNCTION fn_calcula_nivel_risco(pr_qtdiaatr IN NUMBER) RETURN NUMBER IS
        vr_aux_nivel INTEGER;
      BEGIN
        CASE 
          WHEN pr_qtdiaatr < 15   THEN
            vr_aux_nivel := 2;
          WHEN pr_qtdiaatr <= 30  THEN
            vr_aux_nivel := 3;
          WHEN pr_qtdiaatr <= 60  THEN
            vr_aux_nivel := 4;
          WHEN pr_qtdiaatr <= 90  THEN
            vr_aux_nivel := 5;
          WHEN pr_qtdiaatr <= 120 THEN
            vr_aux_nivel := 6;
          WHEN pr_qtdiaatr <= 150 THEN
            vr_aux_nivel := 7;
          WHEN pr_qtdiaatr <= 180   THEN
            vr_aux_nivel := 8;
          ELSE
            vr_aux_nivel := 9;
        END CASE;
        
        RETURN vr_aux_nivel;       
      END;
      
    BEGIN
      vr_ind_risco := LPAD(pr_nrdconta,20,'0') || LPAD(pr_nrcontrato,20,'0');
      IF NOT pr_tab_risco_cartao.EXISTS(vr_ind_risco) THEN
        pr_tab_risco_cartao(vr_ind_risco).cdcooper     := pr_cdcooper;
        pr_tab_risco_cartao(vr_ind_risco).nrdconta     := pr_nrdconta;
        pr_tab_risco_cartao(vr_ind_risco).nrcontrato   := pr_nrcontrato;
        pr_tab_risco_cartao(vr_ind_risco).nrmodalidade := pr_nrmodalidade;
        pr_tab_risco_cartao(vr_ind_risco).dtcadastro   := pr_dtcadastro;
        pr_tab_risco_cartao(vr_ind_risco).inpessoa     := pr_inpessoa;
        pr_tab_risco_cartao(vr_ind_risco).dtvencimento := pr_dtvencimento;
        pr_tab_risco_cartao(vr_ind_risco).dtvencop     := pr_dtvencimento;
        pr_tab_risco_cartao(vr_ind_risco).cdagencia    := pr_cdagencia;
        pr_tab_risco_cartao(vr_ind_risco).qtdiaatr     := 0;
        pr_tab_risco_cartao(vr_ind_risco).nrcpfcgc     := pr_nrcpfcnpj;
        pr_tab_risco_cartao(vr_ind_risco).vldivida     := 0;
        pr_tab_risco_cartao(vr_ind_risco).flgindiv     := 0;
      ELSE       
        -- Data de vencimento da operacao
        IF (pr_dtvencimento > pr_tab_risco_cartao(vr_ind_risco).dtvencop) THEN
          pr_tab_risco_cartao(vr_ind_risco).dtvencop := pr_dtvencimento;
        END IF;
              
        -- Menor data de vencimento
        IF (pr_dtvencimento < pr_tab_risco_cartao(vr_ind_risco).dtvencimento) THEN
          pr_tab_risco_cartao(vr_ind_risco).dtvencimento := pr_dtvencimento;
        END IF;
        
      END IF;
      
      /* 
			   1 - Rotativo
				 2 - Saldo a vista nao financiado
			   3 - Saldo parcelado sem juros
				 4 - Saldo parcelado com juros
				 7 - PAR (parcelado rotativo)
				 8 - Saldo parcela não quitada
			*/
      IF (pr_cdtipo_saldo IN (1,2,3,4,7,8)) THEN
        pr_tab_risco_cartao(vr_ind_risco).vldivida := pr_tab_risco_cartao(vr_ind_risco).vldivida + NVL(pr_vlsaldo_devedor,0);
      END IF;
        
      -- Calculo da quantidade de dias em atraso
      vr_qtdiaatr := fn_calcula_dias_atraso(pr_dtvencimento  => pr_tab_risco_cartao(vr_ind_risco).dtvencimento
                                           ,pr_dtultdma_util => pr_dtultdma_util);                                                     
      pr_tab_risco_cartao(vr_ind_risco).qtdiaatr := vr_qtdiaatr;
        
      -- Calculo do nivel de risco
      pr_tab_risco_cartao(vr_ind_risco).innivris := fn_calcula_nivel_risco(pr_qtdiaatr => vr_qtdiaatr);        
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        --Variavel de erro recebe erro ocorrido
        IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        -- Descricao do erro
        pr_dscritic := 'Erro nao tratado na RISC0002.pc_grava_crapris_temporaria ' || SQLERRM;
    END;
    
  END pc_grava_crapris_temporaria;
  
  PROCEDURE pc_grava_crapvri_temporaria(pr_cdcooper              IN tbcrd_risco.cdcooper%TYPE         -- Codigo da cooperativa
                                       ,pr_nrdconta              IN tbcrd_risco.nrdconta%TYPE         -- Numero da conta
                                       ,pr_nrcontrato            IN tbcrd_risco.nrcontrato%TYPE       -- Numero do contrato
                                       ,pr_nrmodalidade          IN tbcrd_risco.nrmodalidade%TYPE     -- Codigo da modalidade
                                       ,pr_dtrefere              IN tbcrd_risco.dtrefere%TYPE         -- Data de referencia
                                       ,pr_cdtipo_saldo          IN tbcrd_risco.cdtipo_saldo%TYPE     -- Tipo de saldo
                                       ,pr_vlsaldo_devedor       IN tbcrd_risco.vlsaldo_devedor%TYPE  -- Saldo Devedor
                                       ,pr_dtultdma_util         IN DATE                              -- Ultima dia util do mes anterior
                                       ,pr_dtvencimento          IN tbcrd_risco.dtvencimento%TYPE     -- Data de vencimento
                                       ,pr_tab_risco_cartao      IN RISC0002.typ_tab_risco_cartao     -- Risco de vencimento cartao de credito
                                       ,pr_tab_risco_venc_cartao IN OUT NOCOPY RISC0002.typ_tab_risco_venc_cartao -- Risco de vencimento cartao de credito
                                       ,pr_cdcritic              OUT PLS_INTEGER                      -- Código da critica
  				    				        	       ,pr_dscritic              OUT VARCHAR2) IS                     -- Descricao da critica IS
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --  Programa : pc_grava_crapvri_temporaria
    --  Sistema  : Ayllos
    --  Sigla    : CRED
    --  Autor    : James Prust Junior
    --  Data     : Fevereiro/2016.                   Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para gravar os dados na crapris temporaria
    --
    -- Alterações: 06/06/2017 - Inclusao do novo tipo de saldo (7 - PAR (parcelado rotativo)).
    --                          (Chamado 687323) - (Fabricio)
		--
	  --             16/07/2019 - Inclusão do novo tipo de saldo (8 - Saldo parcela não quitada).
    --                          (Reinert - RITM0028079)		
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      vr_ind_risco          VARCHAR2(50);
      vr_indice             VARCHAR2(50);
      vr_cdvencto           crapvri.cdvencto%TYPE;
      vr_qtdiaatr           crapris.qtdiaatr%TYPE;
      
      -- Variaveis tratamento de erro
      vr_exc_erro           EXCEPTION;
      vr_cdcritic           crapcri.cdcritic%TYPE;
      vr_dscritic           VARCHAR2(4000);      
      
      -- Subrotina para calculo do código de vencimento
      FUNCTION fn_calc_codigo_vcto(pr_diasvenc IN OUT INTEGER) RETURN INTEGER IS
      BEGIN
        -- Se for crédito a vencer
        IF pr_diasvenc >= 0  THEN
          IF  pr_diasvenc <= 30 THEN
            RETURN 110;
          ELSIF pr_diasvenc <= 60 THEN
            RETURN 120;            
          ELSIF pr_diasvenc <= 90 THEN
            RETURN 130;            
          ELSIF pr_diasvenc <= 180 THEN
            RETURN 140;            
          ELSIF pr_diasvenc <= 360 THEN
            RETURN 150;            
          ELSIF pr_diasvenc <= 720 THEN
            RETURN 160;            
          ELSIF pr_diasvenc <= 1080 THEN
            RETURN 165;            
          ELSIF  pr_diasvenc <= 1440 THEN
            RETURN 170;            
          ELSIF pr_diasvenc <= 1800 THEN
            RETURN 175;            
          ELSIF pr_diasvenc <= 5400 THEN
            RETURN 180;            
          ELSE
            RETURN 190;
          END IF;
        ELSE -- Creditos Vencidos
          -- Multiplicar por -1 para que os dias fiquem no passado
          pr_diasvenc := pr_diasvenc * -1;
          IF pr_diasvenc <= 14 THEN
            RETURN 205;
          ELSIF pr_diasvenc <= 30 THEN
            RETURN 210;
          ELSIF pr_diasvenc <= 60 THEN
            RETURN 220;
          ELSIF pr_diasvenc <= 90 THEN
            RETURN 230;
          ELSIF pr_diasvenc <= 120 THEN
            RETURN 240;
          ELSIF pr_diasvenc <= 150 THEN
            RETURN 245;
          ELSIF pr_diasvenc <= 180 THEN
            RETURN 250;
          ELSIF pr_diasvenc <= 240 THEN
            RETURN 255;
          ELSIF pr_diasvenc <= 300 THEN
            RETURN 260;
          ELSIF pr_diasvenc <= 360 THEN
            RETURN 270;
          ELSIF pr_diasvenc <= 540 THEN
            RETURN 280;
          ELSE
            RETURN 290;
          END IF;
        END IF;
      END;
    BEGIN
      /* 
			   1 - Rotativo
				 2 - Saldo a vista nao financiado
			   3 - Saldo parcelado sem juros
				 4 - Saldo parcelado com juros
				 7 - PAR (parcelado rotativo)
				 8 - Saldo parcela não quitada
			*/
      IF (pr_cdtipo_saldo NOT IN (1,2,3,4,7,8)) THEN
        RETURN;        
      END IF;
      
      -- Calcular diferença de dias entre a parcela e o dia atual
      vr_qtdiaatr := pr_dtvencimento - pr_dtultdma_util;
      -- Buscar o código do vencimento a lançar
      vr_cdvencto := fn_calc_codigo_vcto(pr_diasvenc => vr_qtdiaatr);
      -- Indice da temp-table
      vr_ind_risco := LPAD(pr_nrdconta,20,'0') || LPAD(pr_nrcontrato,20,'0');
      -- Indice da temp-table
      vr_indice := LPAD(pr_nrdconta,20,'0') || LPAD(pr_nrcontrato,20,'0') || LPAD(vr_cdvencto,10,'0');
      IF NOT pr_tab_risco_venc_cartao.EXISTS(vr_indice) THEN
        pr_tab_risco_venc_cartao(vr_indice).cdcooper     := pr_cdcooper;
        pr_tab_risco_venc_cartao(vr_indice).nrdconta     := pr_nrdconta;
        pr_tab_risco_venc_cartao(vr_indice).nrcontrato   := pr_nrcontrato;        
        pr_tab_risco_venc_cartao(vr_indice).innivris     := pr_tab_risco_cartao(vr_ind_risco).innivris;
        pr_tab_risco_venc_cartao(vr_indice).dtrefere     := pr_dtrefere;
        pr_tab_risco_venc_cartao(vr_indice).nrmodalidade := pr_nrmodalidade;
        pr_tab_risco_venc_cartao(vr_indice).cdvencto     := vr_cdvencto;
        pr_tab_risco_venc_cartao(vr_indice).vldivida     := 0;
      END IF;
      
        pr_tab_risco_venc_cartao(vr_indice).vldivida := pr_tab_risco_venc_cartao(vr_indice).vldivida + NVL(pr_vlsaldo_devedor,0);
              
    EXCEPTION
      WHEN vr_exc_erro THEN
        --Variavel de erro recebe erro ocorrido
        IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        -- Descricao do erro
        pr_dscritic := 'Erro nao tratado na RISC0002.pc_grava_crapvri_temporaria ' || SQLERRM;
    END;
    
  END pc_grava_crapvri_temporaria;  
    
  PROCEDURE pc_import_arq_risco_cartao(pr_cdcooper   IN crapcop.cdcooper%TYPE        --> codigo da cooperativa
                                      ,pr_dtrefere   IN DATE                         --> Data de Referencia
                                      ,pr_rw_crapdat IN btch0001.cr_crapdat%ROWTYPE  --> Dados da crapdat
                                      ,pr_cdorigem   IN INTEGER                      --> Codigo da Origem
                                      ,pr_dsdirarq   IN VARCHAR2                     --> Diretorio dos arquivos
                                      ,pr_listadir   IN VARCHAR2                     --> Lista os arquivos que serao importados
                                      ,pr_cdcritic   OUT PLS_INTEGER                 --> Código da critica
  				    				        	      ,pr_dscritic   OUT VARCHAR2) IS                --> Descricao da critica
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --  Programa : pc_import_arq_risco_cartao
    --  Sistema  : Ayllos
    --  Sigla    : CRED
    --  Autor    : James Prust Junior
    --  Data     : Fevereiro/2016.                   Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Importar os arquivos de risco de cartao de credito CB117
    --
    -- Alterações: 06/06/2017 - Inclusao do novo tipo de saldo (7 - PAR (parcelado rotativo)).
    --                          (Chamado 687323) - (Fabricio)
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      -- Busca as cooperativas
      CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT crapcop.cdagebcb
              ,crapcop.nmrescop
          FROM crapcop
         WHERE cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
         
      -- Busca dos associados unindo com seu saldo na conta
      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE) IS
        SELECT crapass.nrdconta,
               crapass.cdagenci,
               crapass.inpessoa,
               crapass.nrcpfcgc
          FROM crapass
         WHERE crapass.cdcooper = pr_cdcooper;
         
      -- Cursor do cartao de credito
      CURSOR cr_crawcrd_nrcctitg(pr_cdcooper IN crawcrd.cdcooper%TYPE) IS
        SELECT DISTINCT crawcrd.nrcctitg,
               crawcrd.nrdconta
          from crawcrd 
         WHERE crawcrd.cdcooper  = pr_cdcooper 
           AND crawcrd.cdadmcrd >= 10 
           AND crawcrd.cdadmcrd <= 80
           AND crawcrd.nrcctitg  > 0;
           
      -- Definição de tipo para armazenar todas as contas integracao
      TYPE typ_reg_crd_nrcctitg IS
        RECORD(nrdconta crawcrd.nrdconta%TYPE);
        
      TYPE typ_tab_crd_nrcctitg IS
        TABLE OF typ_reg_crd_nrcctitg
          INDEX BY VARCHAR2(50);
          
      -- Definicao dos registros da tabela crapass
      TYPE typ_reg_crapass IS
        RECORD(inpessoa crapass.inpessoa%TYPE
              ,cdagenci crapass.cdagenci%TYPE
              ,nrcpfcgc crapass.nrcpfcgc%TYPE);
        
      TYPE typ_tab_crapass IS
        TABLE OF typ_reg_crapass
          INDEX BY VARCHAR2(50);
          
      TYPE typ_tab_risco_cartao_temp IS
        TABLE OF typ_risco_cartao
          INDEX BY PLS_INTEGER;
          
      TYPE typ_tab_risco_venc_cartao_temp IS
        TABLE OF typ_risco_venc_cartao
          INDEX BY PLS_INTEGER;          
        
      -- Tabela para armazenar os registros do arquivo
      vr_tab_risco_cartao           typ_tab_risco_cartao;
      vr_tab_risco_cartao_temp      typ_tab_risco_cartao_temp;
      vr_tab_risco_venc_cartao      typ_tab_risco_venc_cartao;
      vr_tab_risco_venc_cartao_temp typ_tab_risco_venc_cartao_temp;
      vr_tab_crd_nrcctitg           typ_tab_crd_nrcctitg;
      vr_tab_crapass                typ_tab_crapass;      
      
      -- Variaveis
      vr_indice               VARCHAR2(50);
      vr_ind_linha_arquivo    VARCHAR2(50);
      vr_ind_arq_controle     VARCHAR2(50);
      vr_ind_crapvri          VARCHAR2(50);
      vr_ind_crapris          VARCHAR2(50);
      vr_ind_tab_crapass      VARCHAR2(50);                     -- Indice do risco de cartao de credito
      vr_vet_arquivos         gene0002.typ_split;               -- Array de arquivos
      vr_tab_linhas_arquivo   typ_tab_linhas_arquivo;           -- Todas as linhas do arquivo
      vr_tab_linhas_controle  typ_tab_linhas_controle;          -- Somente as linhas que sera feito a provisao 
      vr_cdbandeira           tbcrd_arq_risco.idbandeira%TYPE;  -- Codigo da bandeira
      vr_nrdconta_cartao      tbcrd_risco.nrdconta_cartao%TYPE; -- Numero da conta
      vr_idarquivo            tbcrd_arq_risco.idarquivo%TYPE;   -- Id do arquivo
      vr_dtultdma_util        DATE;                             -- Data do ultimo dia util do mes anterior
      
      -- Variaveis de Erro
      vr_cdcritic             crapcri.cdcritic%TYPE;
      vr_dscritic             VARCHAR2(4000);

      -- Variaveis Excecao
      vr_exc_erro             EXCEPTION;
      vr_exc_proximo_arq      EXCEPTION;
    BEGIN
      vr_tab_crapass.DELETE;
      vr_tab_crd_nrcctitg.DELETE;
      -- Temp-Table registro da central de risco
      vr_tab_risco_cartao.DELETE;
      -- Temp-Table registros de vencimento da central de risoc
      vr_tab_risco_venc_cartao.DELETE;
      -- Ultima data util do mes anterior
      vr_dtultdma_util := gene0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper, -- Cooperativa
                                                      pr_dtmvtolt  => pr_dtrefere, -- Data de referencia
                                                      pr_tipo      => 'A');
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      -- Se nao encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;
      
      -- Separar os arquivos de retorno em um Array
      vr_vet_arquivos := gene0002.fn_quebra_string(pr_string => pr_listadir);
      -- Vamos verificar se possui algum arquivo na pasta para importar
      IF vr_vet_arquivos.COUNT <= 0 THEN
        -- Sai da procedure
        RETURN;
      END IF;
      
      -- Condicao para verificar se o processo estah rodando
      IF NVL(pr_rw_crapdat.inproces,0) >= 2 THEN
        -- Sai da procedure
        RETURN;
      END IF;
      
      -- Buscar todas as contas integracao cadastradas
      FOR rw_crawcrd IN cr_crawcrd_nrcctitg(pr_cdcooper => pr_cdcooper) LOOP
        -- Armazenar na tabela de memória a descrição
        vr_tab_crd_nrcctitg(rw_crawcrd.nrcctitg).nrdconta := rw_crawcrd.nrdconta;
      END LOOP;
      
      -- Buscar todas os tipos de pessoa
      FOR rw_crapass IN cr_crapass(pr_cdcooper => pr_cdcooper) LOOP
        -- Armazenar na tabela de memória a descrição
        vr_tab_crapass(rw_crapass.nrdconta).inpessoa := rw_crapass.inpessoa;
        vr_tab_crapass(rw_crapass.nrdconta).cdagenci := rw_crapass.cdagenci;
        vr_tab_crapass(rw_crapass.nrdconta).nrcpfcgc := rw_crapass.nrcpfcgc;
      END LOOP;
      
      -- Leitura da PL/Table e processamento dos arquivos
      vr_ind_linha_arquivo := vr_vet_arquivos.first;
      WHILE vr_ind_linha_arquivo IS NOT NULL LOOP
        -- Temp-Table com as linhas do arquivo
        vr_tab_linhas_arquivo.DELETE;
        -- Temp-Table com as linhas que serao gravadas
        vr_tab_linhas_controle.DELETE;        
        -- Temp-Table de risco
        vr_tab_risco_cartao.DELETE;
        vr_tab_risco_cartao_temp.DELETE;
        -- Temp-Table com os vencimentos
        vr_tab_risco_venc_cartao.DELETE;
        vr_tab_risco_venc_cartao_temp.DELETE;
        vr_idarquivo := 0;
        vr_cdcritic  := 0;
        vr_dscritic  := '';        
        BEGIN       
          -- Importa o arquivo e retorna a Temp-Table        
          pc_importa_arq_layout(pr_cdcooper            => pr_cdcooper
                               ,pr_cdagebcb            => rw_crapcop.cdagebcb
                               ,pr_dtrefere            => pr_dtrefere                             
                               ,pr_nmarquiv            => pr_dsdirarq || '/recebe/' || vr_vet_arquivos(vr_ind_linha_arquivo)
                               ,pr_cdbandeira          => vr_cdbandeira
                               ,pr_tab_linhas_arquivo  => vr_tab_linhas_arquivo
                               ,pr_tab_linhas_controle => vr_tab_linhas_controle
                               ,pr_cdcritic            => vr_cdcritic
                               ,pr_dscritic            => vr_dscritic);
            
          -- Condicao para verificar se houve critica
          IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_proximo_arq;
          END IF;

          BEGIN
            INSERT INTO tbcrd_arq_risco
                (idarquivo
                ,cdcooper
                ,dsnome_arq
                ,dtmovimento
                ,dtrefere
                ,cdsituacao
                ,idbandeira)
            VALUES
                (fn_sequence('TBCRD_ARQ_RISCO','IDARQUIVO',0)
                ,pr_cdcooper
                ,vr_vet_arquivos(vr_ind_linha_arquivo)
                ,pr_rw_crapdat.dtmvtolt
                ,pr_dtrefere
                ,0
                ,vr_cdbandeira)
                RETURNING tbcrd_arq_risco.idarquivo INTO vr_idarquivo;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao inserir na tabela de tbcrd_arq_risco. ' || sqlerrm;
              RAISE vr_exc_proximo_arq;
          END;
          -- Vamos gravar o arquivo que estah sendo importado
          COMMIT; 
                      
          -----------------------------------------------------------------------------------------------------------
          --  INICIO PARA GRAVAR OS REGISTROS tbcrd_risco
          -----------------------------------------------------------------------------------------------------------
          vr_indice := vr_tab_linhas_arquivo.first;
          WHILE vr_indice IS NOT NULL LOOP
            -- Numero da conta cartao
            vr_nrdconta_cartao  := vr_tab_linhas_arquivo(vr_indice).nrdconta_cartao;
            -- Indice do arquivo de controle
            vr_ind_arq_controle := LPAD(vr_nrdconta_cartao,20,'0') || LPAD(vr_tab_linhas_arquivo(vr_indice).nrcpfcnpj,20,'0');
            -- Condicao para verificar se o registro podera ser processado
            IF vr_tab_linhas_controle.EXISTS(vr_ind_arq_controle) AND vr_tab_crd_nrcctitg.EXISTS(vr_nrdconta_cartao)  THEN
              -- Indice da TEMP-TABLE do cooperado
              vr_ind_tab_crapass := vr_tab_crd_nrcctitg(vr_nrdconta_cartao).nrdconta;
              
              -- Cria o registro na tabela de risco
              BEGIN
                INSERT INTO tbcrd_risco
                    (idarquivo
                    ,idrisco
                    ,cdcooper
                    ,nrdconta
                    ,nrcontrato
                    ,nrmodalidade
                    ,dtrefere
                    ,cdtipo_cartao
                    ,nrdconta_cartao
                    ,dtcadastro
                    ,cdtipo_saldo
                    ,vltaxa_juros
                    ,dtvencimento
                    ,vlsaldo_devedor
                    ,vlcet
                    ,nrcpfcnpj)
                  VALUES
                    (vr_idarquivo
                    ,fn_sequence('TBCRD_RISCO','IDRISCO',0)
                    ,pr_cdcooper
                    ,vr_tab_crd_nrcctitg(vr_nrdconta_cartao).nrdconta
                    ,SUBSTR(TO_CHAR(vr_nrdconta_cartao),4,10)
                    ,1513                   -- nrmodalidade
                    ,pr_dtrefere            -- dtrefere
                    ,1                      -- cdtipo_cartao
                    ,vr_nrdconta_cartao
                    ,vr_tab_linhas_arquivo(vr_indice).dtcadastro
                    ,vr_tab_linhas_arquivo(vr_indice).cdtipo_saldo
                    ,vr_tab_linhas_arquivo(vr_indice).vltaxa_juros
                    ,vr_tab_linhas_arquivo(vr_indice).dtvencimento
                    ,vr_tab_linhas_arquivo(vr_indice).vlsaldo_devedor
                    ,vr_tab_linhas_arquivo(vr_indice).vlcet
                    ,vr_tab_crapass(vr_ind_tab_crapass).nrcpfcgc)
                    RETURNING tbcrd_risco.cdcooper
                             ,tbcrd_risco.nrdconta
                             ,tbcrd_risco.nrcontrato
                             ,tbcrd_risco.nrmodalidade
                             ,tbcrd_risco.dtrefere
                         INTO vr_tab_linhas_arquivo(vr_indice).cdcooper
                             ,vr_tab_linhas_arquivo(vr_indice).nrdconta
                             ,vr_tab_linhas_arquivo(vr_indice).nrcontrato
                             ,vr_tab_linhas_arquivo(vr_indice).nrmodalidade
                             ,vr_tab_linhas_arquivo(vr_indice).dtrefere;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_cdcritic := 0;
                  vr_dscritic := 'Erro ao inserir na tabela de tbcrd_risco. ' || sqlerrm;
                  RAISE vr_exc_proximo_arq;
              END;            
              
              -----------------------------------------------------------------------------------------------------------
              --  INICIO PARA MONTAR OS REGISTROS PARA A CENTRAL DE RISCO
              -----------------------------------------------------------------------------------------------------------              
              pc_grava_crapris_temporaria(pr_cdcooper          => vr_tab_linhas_arquivo(vr_indice).cdcooper
                                         ,pr_nrdconta          => vr_tab_linhas_arquivo(vr_indice).nrdconta
                                         ,pr_inpessoa          => vr_tab_crapass(vr_ind_tab_crapass).inpessoa
                                         ,pr_nrcontrato        => vr_tab_linhas_arquivo(vr_indice).nrcontrato
                                         ,pr_cdagencia         => vr_tab_crapass(vr_ind_tab_crapass).cdagenci
                                         ,pr_nrcpfcnpj         => vr_tab_crapass(vr_ind_tab_crapass).nrcpfcgc
                                         ,pr_nrmodalidade      => vr_tab_linhas_arquivo(vr_indice).nrmodalidade
                                         ,pr_dtultdma_util     => vr_dtultdma_util
                                         ,pr_dtcadastro        => vr_tab_linhas_arquivo(vr_indice).dtcadastro
                                         ,pr_cdtipo_saldo      => vr_tab_linhas_arquivo(vr_indice).cdtipo_saldo
                                         ,pr_dtvencimento      => vr_tab_linhas_arquivo(vr_indice).dtvencimento
                                         ,pr_vlsaldo_devedor   => vr_tab_linhas_arquivo(vr_indice).vlsaldo_devedor
                                         ,pr_tab_risco_cartao  => vr_tab_risco_cartao
                                         ,pr_cdcritic          => vr_cdcritic
                                         ,pr_dscritic          => vr_dscritic);
                                           
              IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_proximo_arq;
              END IF;
                
              -----------------------------------------------------------------------------------------------------------
              --  INICIO PARA MONTAR OS REGISTROS DE VENCIMENTO PARA A CENTRAL DE RISCO
              -----------------------------------------------------------------------------------------------------------
              pc_grava_crapvri_temporaria(pr_cdcooper              => vr_tab_linhas_arquivo(vr_indice).cdcooper
                                         ,pr_nrdconta              => vr_tab_linhas_arquivo(vr_indice).nrdconta
                                         ,pr_nrcontrato            => vr_tab_linhas_arquivo(vr_indice).nrcontrato
                                         ,pr_nrmodalidade          => vr_tab_linhas_arquivo(vr_indice).nrmodalidade
                                         ,pr_dtrefere              => vr_tab_linhas_arquivo(vr_indice).dtrefere
                                         ,pr_cdtipo_saldo          => vr_tab_linhas_arquivo(vr_indice).cdtipo_saldo                                       
                                         ,pr_vlsaldo_devedor       => vr_tab_linhas_arquivo(vr_indice).vlsaldo_devedor
                                         ,pr_dtultdma_util         => vr_dtultdma_util
                                         ,pr_dtvencimento          => vr_tab_linhas_arquivo(vr_indice).dtvencimento
                                         ,pr_tab_risco_cartao      => vr_tab_risco_cartao
                                         ,pr_tab_risco_venc_cartao => vr_tab_risco_venc_cartao
                                         ,pr_cdcritic              => vr_cdcritic
                                         ,pr_dscritic              => vr_dscritic);
                                           
              IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_proximo_arq;
              END IF;
                
            END IF;
            
            -- Proxima linha
            vr_indice := vr_tab_linhas_arquivo.next(vr_indice);  
          END LOOP;
          
          -----------------------------------------------------------------------------------------------------------
          --  INICIO PARA GRAVAR OS REGISTROS CRAPRIS
          -----------------------------------------------------------------------------------------------------------
          vr_indice := vr_tab_risco_cartao.first;
          WHILE vr_indice IS NOT NULL LOOP
            vr_tab_risco_cartao_temp(vr_tab_risco_cartao_temp.count + 1) := vr_tab_risco_cartao(vr_indice);              
            vr_indice := vr_tab_risco_cartao.next(vr_indice);
          END LOOP;
                  
          BEGIN
            FORALL idx IN INDICES OF vr_tab_risco_cartao_temp SAVE EXCEPTIONS
              INSERT INTO crapris
                       (  nrdconta, 
                          dtrefere, 
                          innivris, 
                          qtdiaatr, 
                          vldivida, 
                          inpessoa, 
                          nrcpfcgc, 
                          inddocto, 
                          cdmodali, 
                          nrctremp, 
                          nrseqctr, 
                          dtinictr, 
                          cdorigem, 
                          cdagenci, 
                          innivori, 
                          cdcooper, 
                          inindris, 
                          cdinfadi,                       
                          dsinfaux, 
                          dtvencop)  
                  VALUES (vr_tab_risco_cartao_temp(idx).nrdconta,
                          pr_dtrefere,
                          vr_tab_risco_cartao_temp(idx).innivris,
                          ABS(vr_tab_risco_cartao_temp(idx).qtdiaatr),
                          vr_tab_risco_cartao_temp(idx).vldivida,
                          vr_tab_risco_cartao_temp(idx).inpessoa,
                          vr_tab_risco_cartao_temp(idx).nrcpfcgc,
                          4, --inddocto
                          vr_tab_risco_cartao_temp(idx).nrmodalidade,
                          vr_tab_risco_cartao_temp(idx).nrcontrato,
                          1, --nrseqctr
                          vr_tab_risco_cartao_temp(idx).dtcadastro,
                          6, --cdorigem
                          vr_tab_risco_cartao_temp(idx).cdagencia,
                          vr_tab_risco_cartao_temp(idx).innivris, --innivori
                          vr_tab_risco_cartao_temp(idx).cdcooper,
                          vr_tab_risco_cartao_temp(idx).innivris, --inindris
                          ' ', --cdinfadi
                          ' ', --dsinfaux
                          vr_tab_risco_cartao_temp(idx).dtvencop);
          EXCEPTION
            WHEN others THEN
              -- Gerar erro
              vr_dscritic := 'Erro ao inserir na tabela crapris. '|| SQLERRM(-(SQL%BULK_EXCEPTIONS(1).ERROR_CODE));
              RAISE vr_exc_proximo_arq;
          END;
          
          -----------------------------------------------------------------------------------------------------------
          --  INICIO PARA GRAVAR OS REGISTROS CRAPVRI
          -----------------------------------------------------------------------------------------------------------
          vr_indice := vr_tab_risco_venc_cartao.first;
          WHILE vr_indice IS NOT NULL LOOP
            -- Indice da tabela de memoria crapvri
            vr_ind_crapvri := vr_tab_risco_venc_cartao_temp.count + 1;        
            -- Indice da tabela de memoria crapris
            vr_ind_crapris := LPAD(vr_tab_risco_venc_cartao(vr_indice).nrdconta,20,'0') || 
                              LPAD(vr_tab_risco_venc_cartao(vr_indice).nrcontrato,20,'0');
            vr_tab_risco_venc_cartao_temp(vr_ind_crapvri)          := vr_tab_risco_venc_cartao(vr_indice);
            vr_tab_risco_venc_cartao_temp(vr_ind_crapvri).innivris := vr_tab_risco_cartao(vr_ind_crapris).innivris;
            vr_indice := vr_tab_risco_venc_cartao.next(vr_indice);
          END LOOP;

          BEGIN
            FORALL idx IN 1..vr_tab_risco_venc_cartao_temp.count SAVE EXCEPTIONS
              INSERT INTO crapvri(cdcooper
                                 ,nrdconta
                                 ,dtrefere
                                 ,innivris
                                 ,cdmodali
                                 ,cdvencto
                                 ,nrctremp
                                 ,nrseqctr
                                 ,vldivida)
                          VALUES (vr_tab_risco_venc_cartao_temp(idx).cdcooper
                                 ,vr_tab_risco_venc_cartao_temp(idx).nrdconta
                                 ,vr_tab_risco_venc_cartao_temp(idx).dtrefere
                                 ,vr_tab_risco_venc_cartao_temp(idx).innivris
                                 ,vr_tab_risco_venc_cartao_temp(idx).nrmodalidade
                                 ,vr_tab_risco_venc_cartao_temp(idx).cdvencto
                                 ,vr_tab_risco_venc_cartao_temp(idx).nrcontrato
                                 ,1 -- nrseqctr
                                 ,nvl(vr_tab_risco_venc_cartao_temp(idx).vldivida,0)); 
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar CRAPVRI. ' || SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
              RAISE vr_exc_proximo_arq;
          END;          
          
          -----------------------------------------------------------------------------------------------------------
          --  INICIO PARA EFETUAR O ARRASTO 
          -----------------------------------------------------------------------------------------------------------
          pc_efetua_arrasto(pr_cdcooper => pr_cdcooper
                           ,pr_dtrefere => pr_dtrefere
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic);
                           
          IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_proximo_arq;
          END IF;
          
          -----------------------------------------------------------------------------------------------------------
          --  ALTERAR O ARQUIVO PARA PROCESSADO
          -----------------------------------------------------------------------------------------------------------
          BEGIN
            UPDATE tbcrd_arq_risco
               SET cdsituacao = 1
             WHERE idarquivo = vr_idarquivo;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar tbcrd_arq_risco: ' || SQLERRM;
              RAISE vr_exc_proximo_arq;
          END;
          
          COMMIT;
        EXCEPTION
          WHEN vr_exc_proximo_arq THEN
            ROLLBACK;
            -- Atualiza o status do arquivo processado
            pc_atualiza_arq_processado(pr_idarquivo  => vr_idarquivo
                                      ,pr_cdsituacao => 2
                                      ,pr_cdcritic   => vr_cdcritic
                                      ,pr_dscritica  => vr_dscritic);
            -- Grava LOG
            pc_gera_log(pr_cdcooper => pr_cdcooper
                       ,pr_cdprogra => 'JOB_CARTAO_RISCO'
                       ,pr_cdorigem => pr_cdorigem
                       ,pr_cdcritic => vr_cdcritic
                       ,pr_dscritic => vr_dscritic);
          WHEN OTHERS THEN
            ROLLBACK;
            -- Atualiza o status do arquivo processado
            pc_atualiza_arq_processado(pr_idarquivo  => vr_idarquivo
                                      ,pr_cdsituacao => 2
                                      ,pr_cdcritic   => vr_cdcritic
                                      ,pr_dscritica  => SQLERRM);
            -- Grava LOG                          
            pc_gera_log(pr_cdcooper => pr_cdcooper
                       ,pr_cdprogra => 'JOB_CARTAO_RISCO'
                       ,pr_cdorigem => pr_cdorigem
                       ,pr_cdcritic => 0
                       ,pr_dscritic => SQLERRM);
        END;
        
        -----------------------------------------------------------------------------------------------------------
        --  INICIO PARA MOVER OS ARQUIVOS PROCESSADOS PARA A PASTA /USR/CONNECT/BANCOOB/RECEBIDOS
        -----------------------------------------------------------------------------------------------------------
        pc_move_arquivo_recebido(pr_cdcooper => pr_cdcooper
                                ,pr_cdorigem => pr_cdorigem
                                ,pr_nmdireto => pr_dsdirarq
                                ,pr_nmrquivo => vr_vet_arquivos(vr_ind_linha_arquivo));
                                
        -- Proximo arquivo
        vr_ind_linha_arquivo := vr_vet_arquivos.next(vr_ind_linha_arquivo);        
      END LOOP;
      
      COMMIT;
         
    EXCEPTION
      WHEN vr_exc_erro THEN
        ROLLBACK;
        -- Variavel de erro recebe erro ocorrido
        IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        ROLLBACK;
        -- Descricao do erro
        pr_dscritic := 'Erro nao tratado na RISC0002.pc_import_arq_risco_cartao ' || SQLERRM;
    END;
                           
  END pc_import_arq_risco_cartao;
  
  /* Esta rotina é acionada diretamente pelo Job */
  PROCEDURE pc_import_arq_risco_cartao_job IS
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --  Programa : pc_import_arq_risco_cartao_job
    --  Sistema  : Ayllos
    --  Sigla    : CRED
    --  Autor    : James Prust Junior
    --  Data     : Fevereiro/2016.                   Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Esta rotina será acionada diretamente pelo Job para importar os arquivos de risco
    -- 
    -- Alterações
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      -- Busca as cooperativas
      CURSOR cr_crapcop IS
        SELECT cdcooper
              ,nmrescop
              ,cdagebcb
          FROM crapcop
         WHERE flgativo = 1
           AND cdcooper <> 3
      ORDER BY cdcooper;
      
      CURSOR cr_crapscb IS
        SELECT dsdirarq
          FROM crapscb
         WHERE tparquiv = 9; -- CB117
      rw_crapscb cr_crapscb%ROWTYPE;
      
      -- Cursor generico de calendario
      rw_crapdat     BTCH0001.CR_CRAPDAT%ROWTYPE;
      
      -- Variaveis
      vr_hasfound    BOOLEAN;
      vr_cdcooper    crapcop.cdcooper%TYPE;
      vr_dsprmris    crapprm.dsvlrprm%TYPE;
      vr_cdorigem    INTEGER;
      vr_listadir    VARCHAR2(4000);  -- Descricao da saida
      vr_nmrquivo    VARCHAR2(4000);  -- Nome do arquivo
      vr_indice      VARCHAR2(10);
      vr_dtrefere    DATE;
      vr_flgemail    BOOLEAN;
      
      -- Variaveis de Erro
      vr_cdcritic    crapcri.cdcritic%TYPE;
      vr_dscritic    VARCHAR2(4000);

      -- Variaveis Excecao
      vr_exc_proximo EXCEPTION;
      
      -- Tabela para armazenar os registros do arquivo
      vr_tab_crapcop typ_tab_crapcop;
      vr_tipsplit    gene0002.typ_split;
    BEGIN
      -- Batch
      vr_cdorigem := 7;
      vr_flgemail := FALSE;
      vr_tab_crapcop.DELETE;
      
      -- Inicio da geracao de LOG no arquivo
      pc_gera_log(pr_cdcooper => 3
                 ,pr_cdprogra => 'JOB_CARTAO_RISCO'
                 ,pr_cdorigem => vr_cdorigem
                 ,pr_cdcritic => 0
                 ,pr_dscritic => 'Inicio da execucao do JOB_CARTAO_RISCO');
      
      -- buscar informações do arquivo a ser processado
      OPEN cr_crapscb;
      FETCH cr_crapscb INTO rw_crapscb;
      CLOSE cr_crapscb;
       
      -- Vamos percorrer todas as cooperativas e gravar na tabela temporaria, devido ao erro ORA-01002
      FOR rw_crapcop IN cr_crapcop LOOP
        vr_indice := LPAD(rw_crapcop.cdcooper,10,'0');
        vr_tab_crapcop(vr_indice).cdcooper := rw_crapcop.cdcooper;
        vr_tab_crapcop(vr_indice).nmrescop := rw_crapcop.nmrescop;        
        vr_tab_crapcop(vr_indice).cdagebcb := rw_crapcop.cdagebcb;
      END LOOP;
      
      -- Faz laço com todas as cooperativas     
      vr_indice := vr_tab_crapcop.first;
      WHILE vr_indice IS NOT NULL LOOP
        BEGIN
          vr_cdcooper := vr_tab_crapcop(vr_indice).cdcooper;
          -- Buscar a data do movimento
          OPEN btch0001.cr_crapdat(vr_cdcooper);
          FETCH btch0001.cr_crapdat INTO rw_crapdat;
          -- Verificar se existe informacao, e gerar erro caso nao exista
          vr_hasfound := btch0001.cr_crapdat%FOUND;
          -- Fechar o cursor
          CLOSE btch0001.cr_crapdat;
          IF NOT vr_hasfound THEN
            -- Gerar excecao
            vr_cdcritic := 1;
            RAISE vr_exc_proximo;
          END IF;
          -- Data de Referencia
          vr_dtrefere := rw_crapdat.dtultdma;          
          -- Condicao para verificar se o arquivo contabil jah foi gerado
          vr_dsprmris := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                  ,pr_cdcooper => vr_cdcooper
                                                  ,pr_cdacesso => 'RISCO_CARTAO_BACEN');
                                                       
          vr_tipsplit := gene0002.fn_quebra_string(pr_string => vr_dsprmris, pr_delimit => ';');
          -- Condicao para verificar se nesse momento estah ocorrendo a geracao do arquivo contabil, ou se o arquivo jah foi gerado
          IF ((vr_tipsplit(2) = 1) OR (TO_CHAR(TO_DATE(vr_tipsplit(1),'DD/MM/RRRR'),'MMRRRR') = TO_CHAR(rw_crapdat.dtmvtolt,'MMRRRR'))) THEN
            RAISE vr_exc_proximo;
          END IF;
          
          -- Condicao para verificar se nesse momento estah sendo importado os arquivos CB177
          IF vr_tipsplit(3) = 1 THEN
            RAISE vr_exc_proximo;
          END IF;
          
          -- Seta a flag para informar que estah sendo importado o arquivo CB117
          vr_tipsplit(3) := 1;
          pc_atualiza_param_risco_cartao(pr_cdcooper => vr_cdcooper
                                        ,pr_tipsplit => vr_tipsplit
                                        ,pr_dscritic => vr_dscritic);
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_proximo;
          END IF;
          
          -- Grava a flag como true para informar que o arquivo CB117 estah sendo processado
          COMMIT;
          -- Seta a variavel que devemos enviar e-mail
          vr_flgemail := TRUE;
          -- Busca os arquivos que serao importados
          pc_lista_arquivos(pr_cdagebcb => vr_tab_crapcop(vr_indice).cdagebcb
                           ,pr_dsdirarq => rw_crapscb.dsdirarq
                           ,pr_listadir => vr_listadir
                           ,pr_nmrquivo => vr_nmrquivo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic);
          -- Condicao para verificar se houve erro
          IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_proximo;
          END IF; 
          
          -- Procedure responsavel pela importacao do arquivo de risco do cartao
          pc_import_arq_risco_cartao(pr_cdcooper                => vr_cdcooper                    --> Codigo da Cooperativa
                                    ,pr_dtrefere                => vr_dtrefere                    --> Data de Referencia
                                    ,pr_rw_crapdat              => rw_crapdat                     --> Cursor Data
                                    ,pr_cdorigem                => vr_cdorigem                    --> Codigo de Origem
                                    ,pr_dsdirarq                => rw_crapscb.dsdirarq            --> Diretorio dos arquivos
                                    ,pr_listadir                => vr_listadir                    --> Lista os arquivos que serao importados
                                    ,pr_cdcritic                => vr_cdcritic                    --> Codigo da critica
                                    ,pr_dscritic                => vr_dscritic);                  --> Descricao da critica
          
          -- Condicao para verificar se houve erro
          IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_proximo;
          END IF;
          
        EXCEPTION
          WHEN vr_exc_proximo THEN
            ROLLBACK;
            IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
              -- Grava LOG
              pc_gera_log(pr_cdcooper => 3
                         ,pr_cdprogra => 'JOB_CARTAO_RISCO'
                         ,pr_cdorigem => vr_cdorigem
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic);
            END IF;
          WHEN OTHERS THEN
            ROLLBACK;
            -- Grava LOG
            pc_gera_log(pr_cdcooper => 3
                       ,pr_cdprogra => 'JOB_CARTAO_RISCO'
                       ,pr_cdorigem => vr_cdorigem
                       ,pr_cdcritic => 0
                       ,pr_dscritic => SQLERRM);
        END;
        
        -- Seta a flag para informar que acabou de importar o arquivo a cooperativa
        vr_tipsplit(3) := 0;
        pc_atualiza_param_risco_cartao(pr_cdcooper => vr_cdcooper
                                      ,pr_tipsplit => vr_tipsplit
                                      ,pr_dscritic => vr_dscritic);                                          
        -- Comitar por cooperativa
        COMMIT;        
        -- Proxima cooperativa
        vr_indice := vr_tab_crapcop.next(vr_indice);
      END LOOP;
      
      -- Condicao para verificar se envia o email
      IF vr_flgemail THEN
        -- Envia o e-mail para os responsaveis
        pc_verifica_envio_email(pr_tab_crapcop => vr_tab_crapcop
                               ,pr_dtrefere    => vr_dtrefere
                               ,pr_cdcritic    => vr_cdcritic
                               ,pr_dscritic    => vr_dscritic);
                               
        -- Condicao para verificar se houve erro                       
        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          pc_gera_log(pr_cdcooper => 3
                     ,pr_cdprogra => 'JOB_CARTAO_RISCO'
                     ,pr_cdorigem => vr_cdorigem
                     ,pr_cdcritic => vr_cdcritic
                     ,pr_dscritic => vr_dscritic);
        END IF;
      END IF;
      
      -- Inicio da geracao de LOG no arquivo
      pc_gera_log(pr_cdcooper => 3
                 ,pr_cdprogra => 'JOB_CARTAO_RISCO'
                 ,pr_cdorigem => vr_cdorigem
                 ,pr_cdcritic => 0
                 ,pr_dscritic => 'Execucao ok');

    EXCEPTION
      WHEN OTHERS THEN
        -- Desfazer a operacao
        ROLLBACK;
        -- Gera log
        pc_gera_log(pr_cdcooper => 3
                   ,pr_cdprogra => 'JOB_CARTAO_RISCO'
                   ,pr_cdorigem => vr_cdorigem
                   ,pr_cdcritic => 0
                   ,pr_dscritic => SQLERRM);
    END;
    
  END pc_import_arq_risco_cartao_job;
  
  /* Esta rotina é acionada diretamente pelo Job */
  PROCEDURE pc_import_arq_risco_cartao_tel(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --  Programa : pc_import_arq_risco_cartao_tel
    --  Sistema  : Ayllos
    --  Sigla    : CRED
    --  Autor    : James Prust Junior
    --  Data     : Fevereiro/2016.                   Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Esta rotina será acionada diretamente pela tela IMPCAR
    -- 
    -- Alterações
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      -- Busca as cooperativas
      CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT crapcop.cdagebcb
              ,crapcop.nmrescop
          FROM crapcop
         WHERE cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      
      CURSOR cr_crapscb IS
        SELECT dsdirarq
          FROM crapscb
         WHERE tparquiv = 9; -- CB117
      rw_crapscb cr_crapscb%ROWTYPE;
      
      -- Cursor generico de calendario
      rw_crapdat     BTCH0001.CR_CRAPDAT%ROWTYPE;
      vr_dsprmris    crapprm.dsvlrprm%TYPE;
      vr_tipsplit    gene0002.typ_split;
      vr_listadir    VARCHAR2(4000);
      vr_nmrquivo    VARCHAR2(4000);
      vr_cdorigem    INTEGER;
      vr_hasfound    BOOLEAN;
      
      -- Variaveis de Erro
      vr_cdcritic    crapcri.cdcritic%TYPE;
      vr_dscritic    VARCHAR2(4000);
      vr_exc_erro    EXCEPTION;
    BEGIN
      -- Ayllos Web
      vr_cdorigem := 5;
      -- Inicio da geracao de LOG no arquivo
      pc_gera_log(pr_cdcooper => pr_cdcooper
                 ,pr_cdprogra => 'JOB_CARTAO_RISCO'
                 ,pr_cdorigem => vr_cdorigem
                 ,pr_cdcritic => 0
                 ,pr_dscritic => 'Inicio da execucao do JOB_CARTAO_RISCO');
                       
      -- Condicao para verificar se o arquivo contabil jah foi gerado
      vr_dsprmris := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_cdacesso => 'RISCO_CARTAO_BACEN');
      vr_tipsplit := gene0002.fn_quebra_string(pr_string => vr_dsprmris, pr_delimit => ';');      
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      -- Se nao encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;
      
      -- buscar informações do arquivo a ser processado
      OPEN cr_crapscb;
      FETCH cr_crapscb INTO rw_crapscb;
      CLOSE cr_crapscb;
       
      -- Buscar a data do movimento
      OPEN btch0001.cr_crapdat(pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Verificar se existe informacao, e gerar erro caso nao exista
      vr_hasfound := btch0001.cr_crapdat%FOUND;
      -- Fechar o cursor
      CLOSE btch0001.cr_crapdat;
      IF NOT vr_hasfound THEN
        -- Gerar excecao
        vr_cdcritic := 1;
        RAISE vr_exc_erro;
      END IF;
      
      -- Busca os arquivos que serao importados
      pc_lista_arquivos(pr_cdagebcb => rw_crapcop.cdagebcb
                       ,pr_dsdirarq => rw_crapscb.dsdirarq
                       ,pr_listadir => vr_listadir
                       ,pr_nmrquivo => vr_nmrquivo
                       ,pr_cdcritic => vr_cdcritic
                       ,pr_dscritic => vr_dscritic);
      -- Condicao para verificar se houve erro
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
            
      -- Procedure responsavel pela importacao do arquivo de risco do cartao
      pc_import_arq_risco_cartao(pr_cdcooper   => pr_cdcooper          --> Codigo da Cooperativa
                                ,pr_dtrefere   => rw_crapdat.dtultdma  --> Data de Referencia
                                ,pr_rw_crapdat => rw_crapdat           --> Cursor Data
                                ,pr_cdorigem   => vr_cdorigem          --> Codigo de Origem
                                ,pr_dsdirarq   => rw_crapscb.dsdirarq  --> Diretorio dos arquivos
                                ,pr_listadir   => vr_listadir          --> Lista os arquivos que serao importados
                                ,pr_cdcritic   => vr_cdcritic          --> Codigo da critica
                                ,pr_dscritic   => vr_dscritic);        --> Descricao da critica
      
      -- Condicao para verificar se houve erro
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
            
      -- Seta a flag para informar que terminou a importacao dos arquivos
      vr_tipsplit(3) := 0;
      pc_atualiza_param_risco_cartao(pr_cdcooper => pr_cdcooper
                                    ,pr_tipsplit => vr_tipsplit
                                    ,pr_dscritic => vr_dscritic);
        
      -- Inicio da geracao de LOG no arquivo
      pc_gera_log(pr_cdcooper => pr_cdcooper
                 ,pr_cdprogra => 'JOB_CARTAO_RISCO'
                 ,pr_cdorigem => vr_cdorigem
                 ,pr_cdcritic => 0
                 ,pr_dscritic => 'Execucao ok');

      -- Comitar por cooperativa
      COMMIT;
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Desfazer a operacao
        ROLLBACK;
        -- Gera Log
        pc_gera_log(pr_cdcooper => pr_cdcooper
                   ,pr_cdprogra => 'JOB_CARTAO_RISCO'
                   ,pr_cdorigem => vr_cdorigem
                   ,pr_cdcritic => vr_cdcritic
                   ,pr_dscritic => vr_dscritic);
        -- Libera a importacao dos arquivos do cartao           
        vr_tipsplit(3) := 0;
        pc_atualiza_param_risco_cartao(pr_cdcooper => pr_cdcooper
                                      ,pr_tipsplit => vr_tipsplit
                                      ,pr_dscritic => vr_dscritic);
        COMMIT;
      WHEN OTHERS THEN
        -- Desfazer a operacao
        ROLLBACK;
        -- Gera log
        pc_gera_log(pr_cdcooper => pr_cdcooper
                   ,pr_cdprogra => 'JOB_CARTAO_RISCO'
                   ,pr_cdorigem => vr_cdorigem
                   ,pr_cdcritic => 0
                   ,pr_dscritic => SQLERRM);
        -- Libera a importacao dos arquivos do cartao           
        vr_tipsplit(3) := 0;
        pc_atualiza_param_risco_cartao(pr_cdcooper => pr_cdcooper
                                      ,pr_tipsplit => vr_tipsplit
                                      ,pr_dscritic => vr_dscritic);
        COMMIT;           
    END;
    
  END pc_import_arq_risco_cartao_tel;  
  
  PROCEDURE pc_importa_arq_layout_vip(pr_cdcooper             IN crapcop.cdcooper%TYPE                --> Codigo da cooperativa
                                     ,pr_dtrefere             IN DATE                                 --> Data de Referencia                                
                                     ,pr_nmarquiv             IN VARCHAR2                             --> Nome do arquivo
                                     ,pr_tab_linhas_arquivo   OUT RISC0002.typ_tab_linhas_arquivo     --> Temp-Table com todas as linhas do arquivo
                                     ,pr_tab_linhas_controle  OUT RISC0002.typ_tab_linhas_controle    --> Temp-Table com as linhas que sera feito a provisao
                                     ,pr_cdcritic             OUT PLS_INTEGER                         --> Código da critica
                                     ,pr_dscritic             OUT VARCHAR2) IS                        --> Descricao da critica IS
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --  Programa : pc_importa_arq_layout_vip
    --  Sistema  : Ayllos
    --  Sigla    : CRED
    --  Autor    : Andrei Vieira - MOUTs
    --  Data     : Maio/2017.                   Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Importa o arquivo de layout
    --
    -- Alterações
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      
      vr_input_file         UTL_FILE.FILE_TYPE;               -- Handle para leitura de arquivo
      vr_setlinha           VARCHAR2(4000);                   -- Texto do arquivo lido
      vr_tipo_registro      NUMBER(10);                       -- Tipo de Registro
      vr_nrdconta_cartao    tbcrd_risco.nrdconta_cartao%TYPE; -- Numero da conta cartao
      vr_nrcpfcnpj          crapris.nrcpfcgc%TYPE;
      vr_ind_arq_importado  VARCHAR2(50);
      vr_dat_vencimento     DATE;
      
      -- Variaveis tratamento de erro
      vr_exc_erro           EXCEPTION;
      vr_cdcritic           crapcri.cdcritic%TYPE;
      vr_dscritic           VARCHAR2(4000);      
    BEGIN
      pr_tab_linhas_arquivo.DELETE;
      
      -- Carrega arquivo
      gene0001.pc_abre_arquivo(pr_nmcaminh => pr_nmarquiv   --> Nome do arquivo
                              ,pr_tipabert => 'R'           --> Modo de abertura (R,W,A)
                              ,pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                              ,pr_des_erro => vr_dscritic); --> Descricao do erro

      -- Laco para leitura de linhas do arquivo
      LOOP
        -- Carrega handle do arquivo
        gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                    ,pr_des_text => vr_setlinha); --> Texto lido
                                      
        -- Tipo de Registro. (HEADER, DETAIL, FOOTER)                            
        vr_tipo_registro := SUBSTR(vr_setlinha,1,1);
          
        -- HEADER
        IF vr_tipo_registro = '0' THEN
          -- Proxima Linha
          CONTINUE;
        END IF;
          
        -- DETAIL
        IF vr_tipo_registro = '1' THEN
          vr_nrdconta_cartao   := TO_NUMBER(SUBSTR(vr_setlinha,44,9));
          vr_nrcpfcnpj         := TO_NUMBER(TRIM(SUBSTR(vr_setlinha,2,14)));
          
          -- Somente considerar os lançamentos com vencimento no mês posterior a 
          -- data de referência, portanto primeiro vamos buscar a data de vencimento
          vr_dat_vencimento := TO_DATE(SUBSTR(vr_setlinha,71,10),'DD.MM.RRRR');
          
          -- Se o vencimento no for no mês seguinte
          IF trunc(vr_dat_vencimento,'mm') <> trunc(add_months(pr_dtrefere,1),'mm') THEN 
            -- Processar o próximo registro
            continue;
          END IF;
          
          -- Criar um registro para o Saldo Financiado
          vr_ind_arq_importado := pr_tab_linhas_arquivo.count;
          pr_tab_linhas_arquivo(vr_ind_arq_importado).cdcooper        := pr_cdcooper;
          pr_tab_linhas_arquivo(vr_ind_arq_importado).nrdconta_cartao := vr_nrdconta_cartao;
          pr_tab_linhas_arquivo(vr_ind_arq_importado).nrcpfcnpj       := vr_nrcpfcnpj;
          pr_tab_linhas_arquivo(vr_ind_arq_importado).cdtipo_saldo    := 1;
          pr_tab_linhas_arquivo(vr_ind_arq_importado).dtvencimento    := vr_dat_vencimento;
          pr_tab_linhas_arquivo(vr_ind_arq_importado).vlsaldo_devedor := gene0002.fn_char_para_number(SUBSTR(vr_setlinha,92,14));
          
          -- Indicar que deverá haver Provisão neste registro
          pr_tab_linhas_controle(vr_ind_arq_importado) := 1;
          
          -- Criar um registro para o Limite de Credito jah descontando o valor utilizado
          vr_ind_arq_importado := pr_tab_linhas_arquivo.count;
          pr_tab_linhas_arquivo(vr_ind_arq_importado).cdcooper        := pr_cdcooper;
          pr_tab_linhas_arquivo(vr_ind_arq_importado).nrdconta_cartao := vr_nrdconta_cartao;
          pr_tab_linhas_arquivo(vr_ind_arq_importado).nrcpfcnpj       := vr_nrcpfcnpj;
          pr_tab_linhas_arquivo(vr_ind_arq_importado).cdtipo_saldo    := 5;
          pr_tab_linhas_arquivo(vr_ind_arq_importado).dtvencimento    := TO_DATE(SUBSTR(vr_setlinha,71,10),'DD.MM.RRRR');
          pr_tab_linhas_arquivo(vr_ind_arq_importado).vlsaldo_devedor := gene0002.fn_char_para_number(SUBSTR(vr_setlinha,82,9)) - pr_tab_linhas_arquivo(vr_ind_arq_importado-1).vlsaldo_devedor;

          -- Indicar que deverá haver Provisão neste registro
          pr_tab_linhas_controle(vr_ind_arq_importado) := 1;
                
        END IF;
          
        -- Footer
        IF vr_tipo_registro = '9' THEN
          EXIT;          
        END IF;
        
      END LOOP; /* END LOOP */    
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        --Variavel de erro recebe erro ocorrido
        IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        -- Descricao do erro
        pr_dscritic := 'Erro nao tratado na RISC0002.pc_importa_arq_layout_vip ' || SQLERRM;
    END;
    
  END pc_importa_arq_layout_vip;
  
  PROCEDURE pc_gera_risco_cartao_vip(pr_cdcooper   IN crapcop.cdcooper%TYPE        --> codigo da cooperativa
                                    ,pr_cdprogra   IN VARCHAR2                     --> Codigo do programa
                                    ,pr_dtmvtolt   IN DATE                         --> Data do movimento
                                    ,pr_dtrefere   IN DATE                         --> Data de Referencia
                                    ,pr_cdorigem   IN INTEGER                      --> Codigo da Origem
                                    ,pr_cdcritic   OUT PLS_INTEGER                 --> Código da critica
                                    ,pr_dscritic   OUT VARCHAR2) IS                --> Descricao da critica
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --  Programa : pc_gera_risco_cartao_vip
    --  Sistema  : Ayllos
    --  Sigla    : CRED
    --  Autor    : Andrei Vieira
    --  Data     : Maio/2017.                   Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Importar os arquivos de risco de cartao de credito VIP
    --
    -- Alterações
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      -- Busca as cooperativas
      CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT crapcop.cdagebcb
              ,crapcop.nmrescop
              ,crapcop.dsdircop
          FROM crapcop
         WHERE cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
         
      -- Busca dos associados unindo com seu saldo na conta
      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE) IS
        SELECT crapass.nrdconta,
               crapass.cdagenci,
               crapass.inpessoa,
               crapass.nrcpfcgc
          FROM crapass
         WHERE crapass.cdcooper = pr_cdcooper;
         
      -- Cursor do cartao de credito
      CURSOR cr_crawcrd(pr_cdcooper IN crawcrd.cdcooper%TYPE) IS
        SELECT lpad(to_char(nrcrcard),25,'0') nrcrcard
              ,nrdconta
              ,nvl(dtpropos,dtsolici) dtsolici
          from crawcrd
         WHERE cdcooper  = pr_cdcooper;
         
      -- Buscar configuração do produto VIP
      CURSOR cr_prod IS
        SELECT vltaxa_juros
          FROM tbrisco_provisgarant_prodt 
         WHERE lower(tparquivo) = 'cartao_bb'; -- VIP   
      rw_prod cr_prod%ROWTYPE;     
         
      -- Definição de tipo para armazenar todos os cartões
      TYPE typ_reg_crd_nrcrcard IS
        RECORD(nrdconta crawcrd.nrdconta%TYPE
              ,dtsolici crawcrd.dtsolici%TYPE);
        
      TYPE typ_tab_crd_nrcrcard IS
        TABLE OF typ_reg_crd_nrcrcard
          INDEX BY VARCHAR2(25);
          
      -- Definicao dos registros da tabela crapass
      TYPE typ_reg_crapass IS
        RECORD(inpessoa crapass.inpessoa%TYPE
              ,cdagenci crapass.cdagenci%TYPE
              ,nrcpfcgc crapass.nrcpfcgc%TYPE);
        
      TYPE typ_tab_crapass IS
        TABLE OF typ_reg_crapass
          INDEX BY VARCHAR2(50);
          
      TYPE typ_tab_risco_cartao_temp IS
        TABLE OF typ_risco_cartao
          INDEX BY PLS_INTEGER;
          
      TYPE typ_tab_risco_venc_cartao_temp IS
        TABLE OF typ_risco_venc_cartao
          INDEX BY PLS_INTEGER;          
        
      -- Tabela para armazenar os registros do arquivo
      vr_tab_risco_cartao           typ_tab_risco_cartao;
      vr_tab_risco_cartao_temp      typ_tab_risco_cartao_temp;
      vr_tab_risco_venc_cartao      typ_tab_risco_venc_cartao;
      vr_tab_risco_venc_cartao_temp typ_tab_risco_venc_cartao_temp;
      vr_tab_crd_nrcrcard           typ_tab_crd_nrcrcard;
      vr_tab_crapass                typ_tab_crapass;      
      
      -- Variaveis
      vr_indice               VARCHAR2(50);
      vr_ind_linha_arquivo    VARCHAR2(50);
      vr_ind_crapvri          VARCHAR2(50);
      vr_ind_crapris          VARCHAR2(50);
      vr_ind_tab_crapass      VARCHAR2(50);                     -- Indice do risco de cartao de credito
      vr_vet_arquivos         gene0002.typ_split;               -- Array de arquivos
      vr_tab_linhas_arquivo   typ_tab_linhas_arquivo;           -- Todas as linhas do arquivo
      vr_tab_linhas_controle  typ_tab_linhas_controle;          -- Somente as linhas que sera feito a provisao 
      vr_cdbandeira           tbcrd_arq_risco.idbandeira%TYPE;  -- Codigo da bandeira
      vr_nrdconta_cartao      tbcrd_risco.nrdconta_cartao%TYPE; -- Numero da conta
      vr_txdconta_cartao      VARCHAR2(25);                     -- Numero da Conta em Texto
      vr_idarquivo            tbcrd_arq_risco.idarquivo%TYPE;   -- Id do arquivo
      vr_dtultdma_util        DATE;                             -- Data do ultimo dia util do mes anterior
      vr_dsdirarq             VARCHAR2(300);                    -- Diretorio para processamento
      vr_listadir             VARCHAR2(4000);                   -- Lista de arquivos para processamento
      
      -- Variaveis de Erro
      vr_cdcritic             crapcri.cdcritic%TYPE;
      vr_dscritic             VARCHAR2(4000);

      -- Variaveis Excecao
      vr_exc_erro             EXCEPTION;
      vr_exc_proximo_arq      EXCEPTION;
    BEGIN
      vr_tab_crapass.DELETE;
      vr_tab_crd_nrcrcard.DELETE;
      -- Temp-Table registro da central de risco
      vr_tab_risco_cartao.DELETE;
      -- Temp-Table registros de vencimento da central de risoc
      vr_tab_risco_venc_cartao.DELETE;
      -- Ultima data util do mes anterior
      vr_dtultdma_util := gene0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper, -- Cooperativa
                                                      pr_dtmvtolt  => pr_dtrefere, -- Data de referencia
                                                      pr_tipo      => 'A');
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      -- Se nao encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;
      
      -- Buscar diretório para processamento 
      vr_dsdirarq := gene0001.fn_param_sistema('CRED',pr_cdcooper,'DIRETORIO_COMPEL_RETORNO');
      -- Trocar string substituivel [dsdircop] pela dsdircoop da Cooperativa
      vr_dsdirarq := REPLACE(vr_dsdirarq,'[dsdircop]',rw_crapcop.dsdircop);
      
      -- Buscar os arquivos VIPS do mês de referência
      gene0001.pc_lista_arquivos(pr_path     => vr_dsdirarq,
                                 pr_pesq     => 'VIP%'||to_char(pr_dtrefere,'MMRRRR')||'%.ret',
                                 pr_listarq  => vr_listadir,
                                 pr_des_erro => vr_dscritic);
        
      -- Separar os arquivos de retorno em um Array
      vr_vet_arquivos := gene0002.fn_quebra_string(pr_string => vr_listadir);
      -- Vamos verificar se possui algum arquivo na pasta para importar
      IF vr_vet_arquivos.COUNT <= 0 THEN
        -- Sai da procedure pois não existem arquivos para processamento 
        RETURN;
      END IF;
      
      -- Buscar todos os cartões cadastrados
      FOR rw_crd IN cr_crawcrd(pr_cdcooper => pr_cdcooper) LOOP
        -- Armazenar na tabela de memória a descrição
        vr_tab_crd_nrcrcard(rw_crd.nrcrcard).nrdconta := rw_crd.nrdconta;
        vr_tab_crd_nrcrcard(rw_crd.nrcrcard).dtsolici := rw_crd.dtsolici;
      END LOOP;
      
      -- Buscar todas os tipos de pessoa
      FOR rw_crapass IN cr_crapass(pr_cdcooper => pr_cdcooper) LOOP
        -- Armazenar na tabela de memória a descrição
        vr_tab_crapass(rw_crapass.nrdconta).inpessoa := rw_crapass.inpessoa;
        vr_tab_crapass(rw_crapass.nrdconta).cdagenci := rw_crapass.cdagenci;
        vr_tab_crapass(rw_crapass.nrdconta).nrcpfcgc := rw_crapass.nrcpfcgc;
      END LOOP;
      
      -- Buscar configuração do produto VIP
      OPEN cr_prod;
      FETCH cr_prod
       INTO rw_prod;     
      CLOSE cr_prod;
      
      -- Badeira é fixo VISA
      vr_cdbandeira := 3;
      
      -- Leitura da PL/Table e processamento dos arquivos
      vr_ind_linha_arquivo := vr_vet_arquivos.first;
      WHILE vr_ind_linha_arquivo IS NOT NULL LOOP
        -- Temp-Table com as linhas do arquivo
        vr_tab_linhas_arquivo.DELETE;
        -- Temp-Table com as linhas que serao gravadas
        vr_tab_linhas_controle.DELETE;        
        -- Temp-Table de risco
        vr_tab_risco_cartao.DELETE;
        vr_tab_risco_cartao_temp.DELETE;
        -- Temp-Table com os vencimentos
        vr_tab_risco_venc_cartao.DELETE;
        vr_tab_risco_venc_cartao_temp.DELETE;
        vr_idarquivo := 0;
        vr_cdcritic  := 0;
        vr_dscritic  := '';        
        BEGIN       
          -- Importa o arquivo e retorna a Temp-Table        
          pc_importa_arq_layout_vip(pr_cdcooper            => pr_cdcooper
                                   ,pr_dtrefere            => pr_dtrefere                             
                                   ,pr_nmarquiv            => vr_dsdirarq || '/' || vr_vet_arquivos(vr_ind_linha_arquivo)
                                   ,pr_tab_linhas_arquivo  => vr_tab_linhas_arquivo
                                   ,pr_tab_linhas_controle => vr_tab_linhas_controle
                                   ,pr_cdcritic            => vr_cdcritic
                                   ,pr_dscritic            => vr_dscritic);
          
          -- Condicao para verificar se houve critica
          IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_proximo_arq;
          END IF;

          BEGIN
            INSERT INTO tbcrd_arq_risco
                (idarquivo
                ,cdcooper
                ,dsnome_arq
                ,dtmovimento
                ,dtrefere
                ,cdsituacao
                ,idbandeira)
            VALUES
                (fn_sequence('TBCRD_ARQ_RISCO','IDARQUIVO',0)
                ,pr_cdcooper
                ,vr_vet_arquivos(vr_ind_linha_arquivo)
                ,pr_dtmvtolt
                ,pr_dtrefere
                ,0
                ,vr_cdbandeira)
                RETURNING tbcrd_arq_risco.idarquivo INTO vr_idarquivo;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao inserir na tabela de tbcrd_arq_risco. ' || sqlerrm;
              RAISE vr_exc_proximo_arq;
          END;
                      
          -----------------------------------------------------------------------------------------------------------
          --  INICIO PARA GRAVAR OS REGISTROS tbcrd_risco
          -----------------------------------------------------------------------------------------------------------
          vr_indice := vr_tab_linhas_arquivo.first;
          WHILE vr_indice IS NOT NULL LOOP
            -- Numero da conta cartao
            vr_nrdconta_cartao := vr_tab_linhas_arquivo(vr_indice).nrdconta_cartao;
            vr_txdconta_cartao := lpad(to_char(vr_nrdconta_cartao),25,'0');
            -- Condicao para verificar se o registro podera ser processado
            IF vr_tab_linhas_controle.EXISTS(vr_indice) AND vr_tab_crd_nrcrcard.EXISTS(vr_txdconta_cartao)  THEN
              -- Indice da TEMP-TABLE do cooperado
              vr_ind_tab_crapass := vr_tab_crd_nrcrcard(vr_txdconta_cartao).nrdconta;
              
              -- Cria o registro na tabela de risco
              BEGIN
                INSERT INTO tbcrd_risco
                    (idarquivo
                    ,idrisco
                    ,cdcooper
                    ,nrdconta
                    ,nrcontrato
                    ,nrmodalidade
                    ,dtrefere
                    ,cdtipo_cartao
                    ,nrdconta_cartao
                    ,dtcadastro
                    ,cdtipo_saldo
                    ,vltaxa_juros
                    ,dtvencimento
                    ,vlsaldo_devedor
                    ,vlcet
                    ,nrcpfcnpj)
                  VALUES
                    (vr_idarquivo
                    ,fn_sequence('TBCRD_RISCO','IDRISCO',0)
                    ,pr_cdcooper
                    ,vr_tab_crd_nrcrcard(vr_txdconta_cartao).nrdconta
                    ,vr_nrdconta_cartao
                    ,1513                   -- nrmodalidade
                    ,pr_dtrefere            -- dtrefere
                    ,2                      -- cdtipo_cartao
                    ,vr_nrdconta_cartao
                    ,vr_tab_crd_nrcrcard(vr_txdconta_cartao).dtsolici
                    ,vr_tab_linhas_arquivo(vr_indice).cdtipo_saldo
                    ,nvl(rw_prod.vltaxa_juros,0.01)
                    ,vr_tab_linhas_arquivo(vr_indice).dtvencimento
                    ,vr_tab_linhas_arquivo(vr_indice).vlsaldo_devedor
                    ,0
                    ,vr_tab_crapass(vr_ind_tab_crapass).nrcpfcgc)
                    RETURNING tbcrd_risco.cdcooper
                             ,tbcrd_risco.nrdconta
                             ,tbcrd_risco.nrcontrato
                             ,tbcrd_risco.nrmodalidade
                             ,tbcrd_risco.dtrefere
                         INTO vr_tab_linhas_arquivo(vr_indice).cdcooper
                             ,vr_tab_linhas_arquivo(vr_indice).nrdconta
                             ,vr_tab_linhas_arquivo(vr_indice).nrcontrato
                             ,vr_tab_linhas_arquivo(vr_indice).nrmodalidade
                             ,vr_tab_linhas_arquivo(vr_indice).dtrefere;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_cdcritic := 0;
                  vr_dscritic := 'Erro ao inserir na tabela de tbcrd_risco. ' || sqlerrm;
                  RAISE vr_exc_proximo_arq;
              END;            
              
              -----------------------------------------------------------------------------------------------------------
              --  INICIO PARA MONTAR OS REGISTROS PARA A CENTRAL DE RISCO
              -----------------------------------------------------------------------------------------------------------              
              pc_grava_crapris_temporaria(pr_cdcooper          => vr_tab_linhas_arquivo(vr_indice).cdcooper
                                         ,pr_nrdconta          => vr_tab_linhas_arquivo(vr_indice).nrdconta
                                         ,pr_inpessoa          => vr_tab_crapass(vr_ind_tab_crapass).inpessoa
                                         ,pr_nrcontrato        => vr_tab_linhas_arquivo(vr_indice).nrcontrato
                                         ,pr_cdagencia         => vr_tab_crapass(vr_ind_tab_crapass).cdagenci
                                         ,pr_nrcpfcnpj         => vr_tab_crapass(vr_ind_tab_crapass).nrcpfcgc
                                         ,pr_nrmodalidade      => vr_tab_linhas_arquivo(vr_indice).nrmodalidade
                                         ,pr_dtultdma_util     => vr_dtultdma_util
                                         ,pr_dtcadastro        => vr_tab_crd_nrcrcard(vr_txdconta_cartao).dtsolici
                                         ,pr_cdtipo_saldo      => vr_tab_linhas_arquivo(vr_indice).cdtipo_saldo
                                         ,pr_dtvencimento      => vr_tab_linhas_arquivo(vr_indice).dtvencimento
                                         ,pr_vlsaldo_devedor   => vr_tab_linhas_arquivo(vr_indice).vlsaldo_devedor
                                         ,pr_tab_risco_cartao  => vr_tab_risco_cartao
                                         ,pr_cdcritic          => vr_cdcritic
                                         ,pr_dscritic          => vr_dscritic);
                                           
              IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_proximo_arq;
              END IF;
                
              -----------------------------------------------------------------------------------------------------------
              --  INICIO PARA MONTAR OS REGISTROS DE VENCIMENTO PARA A CENTRAL DE RISCO
              -----------------------------------------------------------------------------------------------------------
              pc_grava_crapvri_temporaria(pr_cdcooper              => vr_tab_linhas_arquivo(vr_indice).cdcooper
                                         ,pr_nrdconta              => vr_tab_linhas_arquivo(vr_indice).nrdconta
                                         ,pr_nrcontrato            => vr_tab_linhas_arquivo(vr_indice).nrcontrato
                                         ,pr_nrmodalidade          => vr_tab_linhas_arquivo(vr_indice).nrmodalidade
                                         ,pr_dtrefere              => vr_tab_linhas_arquivo(vr_indice).dtrefere
                                         ,pr_cdtipo_saldo          => vr_tab_linhas_arquivo(vr_indice).cdtipo_saldo                                       
                                         ,pr_vlsaldo_devedor       => vr_tab_linhas_arquivo(vr_indice).vlsaldo_devedor
                                         ,pr_dtultdma_util         => vr_dtultdma_util
                                         ,pr_dtvencimento          => vr_tab_linhas_arquivo(vr_indice).dtvencimento
                                         ,pr_tab_risco_cartao      => vr_tab_risco_cartao
                                         ,pr_tab_risco_venc_cartao => vr_tab_risco_venc_cartao
                                         ,pr_cdcritic              => vr_cdcritic
                                         ,pr_dscritic              => vr_dscritic);
                                           
              IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_proximo_arq;
              END IF;
                
            END IF;
            
            -- Proxima linha
            vr_indice := vr_tab_linhas_arquivo.next(vr_indice);  
          END LOOP;
          
          -----------------------------------------------------------------------------------------------------------
          --  INICIO PARA GRAVAR OS REGISTROS CRAPRIS
          -----------------------------------------------------------------------------------------------------------
          vr_indice := vr_tab_risco_cartao.first;
          WHILE vr_indice IS NOT NULL LOOP
            vr_tab_risco_cartao_temp(vr_tab_risco_cartao_temp.count + 1) := vr_tab_risco_cartao(vr_indice);              
            vr_indice := vr_tab_risco_cartao.next(vr_indice);
          END LOOP;
                  
          BEGIN
            FORALL idx IN INDICES OF vr_tab_risco_cartao_temp SAVE EXCEPTIONS
              INSERT INTO crapris
                       (  nrdconta, 
                          dtrefere, 
                          innivris, 
                          qtdiaatr, 
                          vldivida, 
                          inpessoa, 
                          nrcpfcgc, 
                          inddocto, 
                          cdmodali, 
                          nrctremp, 
                          nrseqctr, 
                          dtinictr, 
                          cdorigem, 
                          cdagenci, 
                          innivori, 
                          cdcooper, 
                          inindris, 
                          cdinfadi,                       
                          dsinfaux, 
                          dtvencop)  
                  VALUES (vr_tab_risco_cartao_temp(idx).nrdconta,
                          pr_dtrefere,
                          vr_tab_risco_cartao_temp(idx).innivris,
                          ABS(vr_tab_risco_cartao_temp(idx).qtdiaatr),
                          vr_tab_risco_cartao_temp(idx).vldivida,
                          vr_tab_risco_cartao_temp(idx).inpessoa,
                          vr_tab_risco_cartao_temp(idx).nrcpfcgc,
                          4, --inddocto
                          vr_tab_risco_cartao_temp(idx).nrmodalidade,
                          vr_tab_risco_cartao_temp(idx).nrcontrato,
                          1, --nrseqctr
                          vr_tab_risco_cartao_temp(idx).dtcadastro,
                          6, --cdorigem
                          vr_tab_risco_cartao_temp(idx).cdagencia,
                          vr_tab_risco_cartao_temp(idx).innivris, --innivori
                          vr_tab_risco_cartao_temp(idx).cdcooper,
                          vr_tab_risco_cartao_temp(idx).innivris, --inindris
                          ' ', --cdinfadi
                          ' ', --dsinfaux
                          vr_tab_risco_cartao_temp(idx).dtvencop);
          EXCEPTION
            WHEN others THEN
              -- Gerar erro
              vr_dscritic := 'Erro ao inserir na tabela crapris. '|| SQLERRM(-(SQL%BULK_EXCEPTIONS(1).ERROR_CODE));
              RAISE vr_exc_proximo_arq;
          END;
          
          -----------------------------------------------------------------------------------------------------------
          --  INICIO PARA GRAVAR OS REGISTROS CRAPVRI
          -----------------------------------------------------------------------------------------------------------
          vr_indice := vr_tab_risco_venc_cartao.first;
          WHILE vr_indice IS NOT NULL LOOP
            -- Indice da tabela de memoria crapvri
            vr_ind_crapvri := vr_tab_risco_venc_cartao_temp.count + 1;        
            -- Indice da tabela de memoria crapris
            vr_ind_crapris := LPAD(vr_tab_risco_venc_cartao(vr_indice).nrdconta,20,'0') || 
                              LPAD(vr_tab_risco_venc_cartao(vr_indice).nrcontrato,20,'0');
            vr_tab_risco_venc_cartao_temp(vr_ind_crapvri)          := vr_tab_risco_venc_cartao(vr_indice);
            vr_tab_risco_venc_cartao_temp(vr_ind_crapvri).innivris := vr_tab_risco_cartao(vr_ind_crapris).innivris;
            vr_indice := vr_tab_risco_venc_cartao.next(vr_indice);
          END LOOP;

          BEGIN
            FORALL idx IN 1..vr_tab_risco_venc_cartao_temp.count SAVE EXCEPTIONS
              INSERT INTO crapvri(cdcooper
                                 ,nrdconta
                                 ,dtrefere
                                 ,innivris
                                 ,cdmodali
                                 ,cdvencto
                                 ,nrctremp
                                 ,nrseqctr
                                 ,vldivida)
                          VALUES (vr_tab_risco_venc_cartao_temp(idx).cdcooper
                                 ,vr_tab_risco_venc_cartao_temp(idx).nrdconta
                                 ,vr_tab_risco_venc_cartao_temp(idx).dtrefere
                                 ,vr_tab_risco_venc_cartao_temp(idx).innivris
                                 ,vr_tab_risco_venc_cartao_temp(idx).nrmodalidade
                                 ,vr_tab_risco_venc_cartao_temp(idx).cdvencto
                                 ,vr_tab_risco_venc_cartao_temp(idx).nrcontrato
                                 ,1 -- nrseqctr
                                 ,nvl(vr_tab_risco_venc_cartao_temp(idx).vldivida,0)); 
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar CRAPVRI. ' || SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
              RAISE vr_exc_proximo_arq;
          END;    
          
          -----------------------------------------------------------------------------------------------------------
          --  ALTERAR O ARQUIVO PARA PROCESSADO
          -----------------------------------------------------------------------------------------------------------
          BEGIN
            UPDATE tbcrd_arq_risco
               SET cdsituacao = 1
             WHERE idarquivo = vr_idarquivo;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar tbcrd_arq_risco: ' || SQLERRM;
              RAISE vr_exc_proximo_arq;
          END;
          
        EXCEPTION
          WHEN vr_exc_proximo_arq THEN
            ROLLBACK;
            -- Atualiza o status do arquivo processado
            pc_atualiza_arq_processado(pr_idarquivo  => vr_idarquivo
                                      ,pr_cdsituacao => 2
                                      ,pr_cdcritic   => vr_cdcritic
                                      ,pr_dscritica  => vr_dscritic);
            -- Grava LOG
            pc_gera_log(pr_cdcooper => pr_cdcooper
                       ,pr_cdprogra => pr_cdprogra
                       ,pr_cdorigem => pr_cdorigem
                       ,pr_cdcritic => vr_cdcritic
                       ,pr_dscritic => vr_dscritic);
          WHEN OTHERS THEN
            ROLLBACK;
            -- Atualiza o status do arquivo processado
            pc_atualiza_arq_processado(pr_idarquivo  => vr_idarquivo
                                      ,pr_cdsituacao => 2
                                      ,pr_cdcritic   => vr_cdcritic
                                      ,pr_dscritica  => SQLERRM);
            -- Grava LOG                          
            pc_gera_log(pr_cdcooper => pr_cdcooper
                       ,pr_cdprogra => pr_cdprogra
                       ,pr_cdorigem => pr_cdorigem
                       ,pr_cdcritic => 0
                       ,pr_dscritic => SQLERRM);
        END;
                                
        -- Proximo arquivo
        vr_ind_linha_arquivo := vr_vet_arquivos.next(vr_ind_linha_arquivo);        
      END LOOP;
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        ROLLBACK;
        -- Variavel de erro recebe erro ocorrido
        IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        ROLLBACK;
        -- Descricao do erro
        pr_dscritic := 'Erro nao tratado na RISC0002.pc_gera_risco_cartao_vip --> ' || SQLERRM;
    END;
                           
  END pc_gera_risco_cartao_vip;
  
  /* Rotina para processamento de Arquivo VIP - Durante processo Batch */
  PROCEDURE pc_gera_risco_cartao_vip_proc(pr_cdcooper IN NUMBER
                                         ,pr_cdprogra IN VARCHAR2
                                         ,pr_dtmvtolt IN VARCHAR2
                                         ,pr_dtrefere IN VARCHAR2) IS
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --  Programa : pc_gera_risco_cartao_vip_proc
    --  Sistema  : Ayllos
    --  Sigla    : CRED
    --  Autor    : Andrei Vieira - Mouts
    --  Data     : Maio/2017.                   Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Esta rotina será acionada diretamente pelo processo noturno mensal e
    --             efetuará a leitura dos arquivos VIPS recebidos do Banco do Brasil
    -- 
    -- Alterações
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      
      -- Variaveis
      vr_cdorigem    INTEGER;
      
      -- Variaveis de Erro
      vr_cdcritic    crapcri.cdcritic%TYPE;
      vr_dscritic    VARCHAR2(4000);
      
      -- Datas de processo
      vr_dtmvtolt DATE;
      vr_dtrefere DATE;
      
      -- Variaveis Excecao
      vr_excsaida EXCEPTION;
      
    BEGIN
      -- Batch
      vr_cdorigem := 7;
      
      -- Inicio da geracao de LOG no arquivo
      pc_gera_log(pr_cdcooper => pr_cdcooper
                 ,pr_cdprogra => pr_cdprogra
                 ,pr_cdorigem => vr_cdorigem
                 ,pr_cdcritic => 0
                 ,pr_dscritic => 'Inicio da integracao para Central Risco do Arquivos VIP - Coop '||pr_cdcooper);
      
      -- Transformar as datas recebidas em varchar2 em date
      vr_dtmvtolt := to_date(pr_dtmvtolt,'dd/mm/rrrr');
      vr_dtrefere := to_date(pr_dtrefere,'dd/mm/rrrr');
      
      -- Procedure responsavel pela importacao do arquivo de risco do cartao
      pc_gera_risco_cartao_vip(pr_cdcooper => pr_cdcooper    --> Codigo da Cooperativa
                              ,pr_cdprogra => pr_cdprogra    --> Codigo do programa
                              ,pr_dtmvtolt => vr_dtmvtolt    --> Data do Movimento
                              ,pr_dtrefere => vr_dtrefere    --> Data de Referencia
                              ,pr_cdorigem => vr_cdorigem    --> Codigo de Origem
                              ,pr_cdcritic => vr_cdcritic    --> Codigo da critica
                              ,pr_dscritic => vr_dscritic);  --> Descricao da critica
          
      -- Condicao para verificar se houve erro
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_excsaida;
      END IF;      
      
      -- INICIO PARA EFETUAR O ARRASTO após incorporar novos contratos de Risco
      pc_efetua_arrasto(pr_cdcooper => pr_cdcooper
                       ,pr_dtrefere => vr_dtrefere
                       ,pr_cdcritic => vr_cdcritic
                       ,pr_dscritic => vr_dscritic);
                         
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_excsaida;
      END IF;
      
      -- Inicio da geracao de LOG no arquivo
      pc_gera_log(pr_cdcooper => pr_cdcooper
                 ,pr_cdprogra => pr_cdprogra
                 ,pr_cdorigem => vr_cdorigem
                 ,pr_cdcritic => 0
                 ,pr_dscritic => 'Execucao ok - Coop '||pr_cdcooper);
                 

    EXCEPTION
      WHEN vr_excsaida THEN
        ROLLBACK;
        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          -- Grava LOG
          pc_gera_log(pr_cdcooper => pr_cdcooper
                     ,pr_cdprogra => pr_cdprogra
                     ,pr_cdorigem => vr_cdorigem
                     ,pr_cdcritic => vr_cdcritic
                     ,pr_dscritic => vr_dscritic);
        END IF;

      WHEN OTHERS THEN
        -- Desfazer a operacao
        ROLLBACK;
        -- Gera log
        pc_gera_log(pr_cdcooper => pr_cdcooper
                   ,pr_cdprogra => pr_cdprogra
                   ,pr_cdorigem => vr_cdorigem
                   ,pr_cdcritic => 0
                   ,pr_dscritic => 'Erro nao tratado no processamento: '||SQLERRM);
    END;
    
  END pc_gera_risco_cartao_vip_proc;
  
END RISC0002;
/
