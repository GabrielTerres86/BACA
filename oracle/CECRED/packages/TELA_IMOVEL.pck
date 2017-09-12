CREATE OR REPLACE PACKAGE CECRED.TELA_IMOVEL AS

  -- BUSCAR OS DADOS DO ASSOCIADO E OS EMPRESTIMOS DO MESMO
  PROCEDURE pc_busca_dados_ass_epr(pr_cdcooper IN NUMBER                --> Código da cooperativa para buscar os dados
                                  ,pr_nrdconta IN NUMBER                --> Numero da Conta para buscar os dados
                                  ,pr_cddopcao IN VARCHAR2              --> Opção selecionada na tela
                                  ,pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                  ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                                  ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2);           --> Saida OK/NOK

  -- CONSULTAR AS CIDADES CONFORME O ESTADO INFORMADO
  PROCEDURE pc_busca_cidades_cetip(pr_cdestado IN VARCHAR2              --> Código do estado selecionado em tela
                                  ,pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                  ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                                  ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2);           --> Saida OK/NOK
                         
  -- BUSCAR OS IMÓVEIS DO CONTRATO SELECIONADO NA TELA         
  PROCEDURE pc_busca_imoveis_contrato(pr_cdcooper IN NUMBER                --> Código da cooperativa para buscar os dados
                                     ,pr_nrdconta IN NUMBER                --> Número da conta
                                     ,pr_nrctremp IN NUMBER                --> Número do contrato
                                     ,pr_cddopcao IN VARCHAR2              --> Opção selecionada na tela
                                  	 ,pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                                     ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2);           --> Saida OK/NOK

  -- BUSCAR OS DADOS DO IMÓVEL SELECIONADO NA TELA
  PROCEDURE pc_busca_dados_imovel(pr_cdcooper IN NUMBER                --> Código da cooperativa para buscar os dados
                                 ,pr_nrdconta IN NUMBER                --> Número da conta
                                 ,pr_nrctremp IN NUMBER                --> Número do contrato
                                 ,pr_idseqbem IN NUMBER                --> Indica a sequencia do bem
                                 ,pr_cddopcao IN VARCHAR2              --> Opção selecionada na tela
                                 ,pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                 ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                                 ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2);           --> Saida OK/NOK

  -- GRAVAR OS DADOS DO IMÓVEL INSERIDOS NA TELA
  PROCEDURE pc_grava_dados_imovel(pr_cdcooper   IN NUMBER           -- Código da cooperativa
                                 ,pr_nrdconta   IN NUMBER           -- Número da conta
                                 ,pr_nrctremp   IN NUMBER           -- Número do contrato de empréstimo
                                 ,pr_idseqbem   IN NUMBER           -- Código de sequencia do bem
                                 ,pr_cdoperad   IN VARCHAR2         -- Código do cooperado
                                 ,pr_nrmatcar   IN NUMBER           -- Número da matrícula no cartório
                                 ,pr_nrcnscar   IN NUMBER           -- Código CNS do cartório
                                 ,pr_tpimovel   IN NUMBER           -- Tipo do Imóvel (DSCATBEM)
                                 ,pr_nrreggar   IN VARCHAR2         -- Número da garantia do imóvel
                                 ,pr_dtreggar   IN VARCHAR2         -- Data da garantia do imóvel (DD/MM/YYYY)
                                 ,pr_nrgragar   IN VARCHAR2         -- Indica o grau da garantia
                                 ,pr_nrceplgr   IN VARCHAR2         -- Número do CEP
                                 ,pr_tplograd   IN NUMBER           -- Tipo do logradouro 
                                 ,pr_dslograd   IN VARCHAR2         -- Descrição do Endereço do imóvel
                                 ,pr_nrlograd   IN VARCHAR2         -- Número do imóvel
                                 ,pr_dscmplgr   IN VARCHAR2         -- Complemento do endereço do imóvel
                                 ,pr_dsbairro   IN VARCHAR2         -- Bairro do imóvel
                                 ,pr_cdcidade   IN NUMBER           -- Código da cidade  (já referencia a UF)
                                 ,pr_dtavlimv   IN VARCHAR2         -- Data de avaliação do imóvel (DD/MM/YYYY)
                                 ,pr_vlavlimv   IN VARCHAR2         -- Valor de avaliação do imóvel
                                 ,pr_dtcprimv   IN VARCHAR2         -- Data de compra do imóvel (DD/MM/YYYY)
                                 ,pr_vlcprimv   IN VARCHAR2         -- Valor de compra do imóvel
                                 ,pr_tpimpimv   IN NUMBER           -- Tipo de implantação do imóvel
                                 ,pr_incsvimv   IN NUMBER           -- Estado de conservação do imóvel
                                 ,pr_inpdracb   IN NUMBER           -- Nível do padrão de acabamento
                                 ,pr_vlmtrtot   IN VARCHAR2         -- Área total do imóvel em metros quadrados
                                 ,pr_vlmtrpri   IN VARCHAR2         -- Área de uso privativo do imóvel em metros quadrados
                                 ,pr_qtdormit   IN NUMBER           -- Quantidade de dormitórios
                                 ,pr_qtdvagas   IN NUMBER           -- Quantidades de vagas de garagem
                                 ,pr_vlmtrter   IN VARCHAR2         -- Área em metros quadrados do terreno
                                 ,pr_vlmtrtes   IN VARCHAR2         -- Metragem da frente do imóvel
                                 ,pr_incsvcon   IN NUMBER           -- Indicador de conservação do condomínio
                                 ,pr_inpesvdr   IN NUMBER           -- Tipo de pessoa do vendedor do imóvel
                                 ,pr_nrdocvdr   IN VARCHAR2         -- Número do documento do vendedor
                                 ,pr_nmvendor   IN VARCHAR2         -- Nome do vendedor
                                 ,pr_nrreginc   IN NUMBER           -- INCLUSÃO MANUAL: Número do Registro da CETIP
                                 ,pr_dtinclus   IN VARCHAR2         -- INCLUSÃO MANUAL: Data da inclusão manual
                                 ,pr_dsjstinc   IN VARCHAR2         -- INCLUSÃO MANUAL: Justificativa para inclusão manual
                                 ,pr_xmllog   IN VARCHAR2           --> XML com informacoes de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER       --> Codigo da critica
                                 ,pr_dscritic OUT VARCHAR2          --> Descricao da critica
                                 ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2);        --> Saida OK/NOK
  
  -- IMPRIMIR OS DADOS DO IMÓVEL
  PROCEDURE pc_imprime_dados_imovel(pr_cdcooper IN NUMBER                --> Código da cooperativa para buscar os dados
                                 	 ,pr_nrdconta IN NUMBER                --> Número da conta
                                   ,pr_nrctremp IN NUMBER                --> Número do contrato
                                   ,pr_idseqbem IN NUMBER                -- Indica a sequencia do bem
                                   ,pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                   ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                                   ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2);           --> Saida OK/NOK
  
  -- GRAVAR OS DADOS REFERENTE A BAIXA MANUAL
  PROCEDURE pc_gravar_baixa_manual_imovel(pr_cdcooper   IN NUMBER             -- Código da cooperativa
                                         ,pr_nrdconta   IN NUMBER             -- Número da conta
                                         ,pr_nrctremp   IN NUMBER             -- Número do contrato de empréstimo
                                         ,pr_idseqbem   IN NUMBER             -- Código de sequencia do bem
                                         ,pr_dtdbaixa   IN VARCHAR2           -- Data da baixa da alienação
                                         ,pr_dsjstbxa   IN VARCHAR2           -- Justificativa da Baixa
                                         ,pr_cdoperad   IN VARCHAR2           -- Código do operador
                                         ,pr_xmllog     IN VARCHAR2           --> XML com informacoes de LOG
                                         ,pr_cdcritic  OUT PLS_INTEGER        --> Codigo da critica
                                         ,pr_dscritic  OUT VARCHAR2           --> Descricao da critica
                                         ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                         ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                                         ,pr_des_erro  OUT VARCHAR2);         --> Saida OK/NOK
  
  -- LISTAS AS COOPERATIVAS A SEREM LISTADAS NA TELA
  PROCEDURE pc_lista_coop_pesquisa(pr_xmllog     IN VARCHAR2            --> XML com informações de LOG
                                  ,pr_cdcritic  OUT PLS_INTEGER         --> Código da crítica
                                  ,pr_dscritic  OUT VARCHAR2            --> Descrição da crítica
                                  ,pr_retxml     IN OUT NOCOPY XMLType  --> Arquivo de retorno do XML
                                  ,pr_nmdcampo  OUT VARCHAR2            --> Nome do campo com erro
                                  ,pr_des_erro  OUT VARCHAR2);          --> Erros do processo
  
  -- REALIZAR A GERAÇÃO DOS RELATÓRIOS SOLICITADOS NA TELA DE IMÓVEIS
  PROCEDURE pc_imprime_relatorio_imovel(pr_cdcooper IN NUMBER                --> Código da cooperativa conectada
                                       ,pr_cdcoptel IN NUMBER                --> Código da cooperativa selecionada na tela
                                       ,pr_inrelato IN NUMBER                --> Indica o relatório
                                       ,pr_intiprel IN VARCHAR2              --> Indica o tipo do relatório
                                       ,pr_dtrefere IN VARCHAR2              --> Data de referencia para os itens do relatório
                                       ,pr_cddolote IN NUMBER                --> Código do Lote
                                       ,pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                       ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                                       ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2);           --> Saida OK/NOK
  
  -- GERAR OS ARQUIVOS COM DADOS PARA SEREM ENVIADOS A CETIP
  PROCEDURE pc_gerar_arquivo_cetip(pr_cdcoptel IN NUMBER                --> Código da cooperativa selecionada na tela
                                  ,pr_intiparq IN VARCHAR2              --> Indica o tipo de arquivo
                                  ,pr_cdoperad IN VARCHAR2              --> Código do operador
                                  ,pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                  ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                                  ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2);           --> Saida OK/NOK
  
  -- REALIZAR A LEITURA DOS ARQUIVOS DE RETORNO DO CETIP
  PROCEDURE pc_leitura_arquivo_cetip(pr_cdoperad IN VARCHAR2              --> Código do operador
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);           --> Saida OK/NOK
  
END TELA_IMOVEL;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_IMOVEL AS
  /*---------------------------------------------------------------------------------------------------------------
  --
  --    Programa: TELA_IMOVEL 
  --    Autor   : Renato Darosci/SUPERO
  --    Data    : Junho/2016                   Ultima Atualizacao: 12/09/2017
  --
  --    Dados referentes ao programa:
  --
  --    Objetivo  : BO ref. a Mensageria da tela IMOVEL
  --
  --    Alteracoes: 12/09/2017 - Decorrente a inclusão de novo parâmetro na rotina pc_abre_arquivo,
                                 foi ncessário ajuste para mencionar os parâmetros no momento da chamada
                                (Adriano - SD 734960 ).
  
  ---------------------------------------------------------------------------------------------------------------*/
  -- Buscar os dados do registro que vai ser atualizado
  CURSOR cr_tbepr_imovel_alienado(pr_cdcooper  tbepr_imovel_alienado.cdcooper%TYPE
                                 ,pr_nrdconta  tbepr_imovel_alienado.nrdconta%TYPE
                                 ,pr_nrctremp  tbepr_imovel_alienado.nrctrpro%TYPE
                                 ,pr_idseqbem  tbepr_imovel_alienado.idseqbem%TYPE) IS
    SELECT imv.flgenvia
         , imv.cdoperad
         , imv.cdsituacao           cdsituac
         , imv.nrmatric_cartorio    nrmatcar
         , imv.nrcns_cartorio       nrcnscar
         , imv.nrreg_garantia       nrreggar
         , imv.dtreg_garantia       dtreggar
         , imv.nrgrau_garantia      nrgragar
         , imv.tplogradouro         tplograd
         , imv.dslogradouro         dslograd
         , imv.nrlogradouro         nrlograd
         , imv.dscomplemento        dscmplgr
         , imv.dsbairro
         , imv.cdcidade
         , imv.nrcep                nrceplgr
         , imv.dtavaliacao          dtavlimv
         , imv.vlavaliado           vlavlimv
         , imv.dtcompra             dtcprimv
         , imv.vlcompra             vlcprimv
         , imv.tpimplantacao        tpimpimv
         , imv.indconservacao       incsvimv
         , imv.indpadrao_acab       inpdracb
         , imv.vlarea_total         vlmtrtot
         , imv.vlarea_privada       vlmtrpri
         , imv.qtddormitorio        qtdormit
         , imv.qtdvagas             qtdvagas
         , imv.vlarea_terreno       vlmtrter
         , imv.vltamanho_frente     vlmtrtes
         , imv.indconserv_condom    incsvcon
         , imv.indpessoa_vendedor   inpesvdr
         , imv.nrdoc_vendedor       nrdocvdr
         , imv.nmvendor
         , imv.nrreg_cetip          nrreginc
         , imv.dtinclusao           dtinclus
         , imv.tpinclusao           tpinclus
         , imv.dsjustific_inclus    dsjstinc
         , imv.dtbaixa              dtdbaixa
         , imv.tpbaixa              tpdbaixa
         , imv.dsjustific_baixa     dsjstbxa
      FROM tbepr_imovel_alienado imv
     WHERE imv.cdcooper = pr_cdcooper
       AND imv.nrdconta = pr_nrdconta
       AND imv.nrctrpro = pr_nrctremp
       AND imv.idseqbem = pr_idseqbem;

  
  -- Rotina para gerar os logs de alteração do imovel
  PROCEDURE pc_registra_alteracao_imovel(pr_cdcooper   IN tbepr_imovel_alienado.cdcooper%TYPE
                                        ,pr_nrdconta   IN tbepr_imovel_alienado.nrdconta%TYPE
                                        ,pr_nrctremp   IN tbepr_imovel_alienado.nrctrpro%TYPE
                                        ,pr_idseqbem   IN tbepr_imovel_alienado.idseqbem%TYPE
                                        ,pr_dstransa   IN craplgm.dstransa%TYPE
                                        ,pr_rgimovel   IN cr_tbepr_imovel_alienado%ROWTYPE) IS  -- Contém os dados antigos do imóvel
    
    -- Variáveis
    rw_rgimovel_novo    cr_tbepr_imovel_alienado%ROWTYPE;
    vr_rowidlog         VARCHAR2(20);
        
  BEGIN
    
    -- Buscar o registro com os novos dados 
    OPEN  cr_tbepr_imovel_alienado(pr_cdcooper, pr_nrdconta, pr_nrctremp, pr_idseqbem);
    FETCH cr_tbepr_imovel_alienado INTO rw_rgimovel_novo;
    CLOSE cr_tbepr_imovel_alienado;

    -- Registrar o log de inclusão/alteração
    GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                        ,pr_cdoperad => rw_rgimovel_novo.cdoperad
                        ,pr_dscritic => ' '
                        ,pr_dsorigem => gene0001.vr_vet_des_origens(1)
                        ,pr_dstransa => pr_dstransa
                        ,pr_dttransa => SYSDATE
                        ,pr_flgtrans => 1
                        ,pr_hrtransa => GENE0002.fn_busca_time
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => 'IMOVEL'
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_rowidlog);
    
    /*** Verifica as diferenças campo a campo e faz o registro dos novos valores ***/
    ----
    IF nvl(pr_rgimovel.flgenvia,-1) <> nvl(rw_rgimovel_novo.flgenvia,-1)  THEN
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowidlog
                               ,pr_nmdcampo => 'FLGENVIA'
                               ,pr_dsdadant => pr_rgimovel.flgenvia
                               ,pr_dsdadatu => rw_rgimovel_novo.flgenvia);
    END IF;
    ----
    IF nvl(pr_rgimovel.cdsituac,-1) <> nvl(rw_rgimovel_novo.cdsituac,-1)  THEN
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowidlog
                               ,pr_nmdcampo => 'CDSITUAC'
                               ,pr_dsdadant => pr_rgimovel.cdsituac
                               ,pr_dsdadatu => rw_rgimovel_novo.cdsituac);
    END IF;
    ----
    IF nvl(pr_rgimovel.nrmatcar,-1) <> nvl(rw_rgimovel_novo.nrmatcar,-1)  THEN
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowidlog
                               ,pr_nmdcampo => 'NRMATCAR'
                               ,pr_dsdadant => pr_rgimovel.nrmatcar
                               ,pr_dsdadatu => rw_rgimovel_novo.nrmatcar);
    END IF;
    ----
    IF nvl(pr_rgimovel.nrcnscar,-1) <> nvl(rw_rgimovel_novo.nrcnscar,-1)  THEN
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowidlog
                               ,pr_nmdcampo => 'NRCNSCAR'
                               ,pr_dsdadant => pr_rgimovel.nrcnscar
                               ,pr_dsdadatu => rw_rgimovel_novo.nrcnscar);
    END IF;
    ---
    IF nvl(pr_rgimovel.nrreggar,-1) <> nvl(rw_rgimovel_novo.nrreggar,-1)  THEN
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowidlog
                               ,pr_nmdcampo => 'NRREGGAR'
                               ,pr_dsdadant => pr_rgimovel.nrreggar
                               ,pr_dsdadatu => rw_rgimovel_novo.nrreggar);
    END IF;
    ----
    IF nvl(pr_rgimovel.dtreggar,SYSDATE) <> nvl(rw_rgimovel_novo.dtreggar,SYSDATE)  THEN
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowidlog
                               ,pr_nmdcampo => 'NRREGGAR'
                               ,pr_dsdadant => pr_rgimovel.nrreggar
                               ,pr_dsdadatu => rw_rgimovel_novo.nrreggar);
    END IF;
    ----
    IF nvl(pr_rgimovel.nrgragar,-1) <> nvl(rw_rgimovel_novo.nrgragar,-1)  THEN
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowidlog
                               ,pr_nmdcampo => 'NRGRAGAR'
                               ,pr_dsdadant => pr_rgimovel.nrgragar
                               ,pr_dsdadatu => rw_rgimovel_novo.nrgragar);
    END IF;
    ----
    IF nvl(pr_rgimovel.tplograd,-1) <> nvl(rw_rgimovel_novo.tplograd,-1)  THEN
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowidlog
                               ,pr_nmdcampo => 'TPLOGRAD'
                               ,pr_dsdadant => pr_rgimovel.tplograd
                               ,pr_dsdadatu => rw_rgimovel_novo.tplograd);
    END IF;
    ----
    IF nvl(pr_rgimovel.dslograd,' ') <> nvl(rw_rgimovel_novo.dslograd,' ')  THEN
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowidlog
                               ,pr_nmdcampo => 'DSLOGRAD'
                               ,pr_dsdadant => pr_rgimovel.dslograd
                               ,pr_dsdadatu => rw_rgimovel_novo.dslograd);
    END IF;
    ----
    IF nvl(pr_rgimovel.nrlograd,-1) <> nvl(rw_rgimovel_novo.nrlograd,-1)  THEN
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowidlog
                               ,pr_nmdcampo => 'NRLOGRAD'
                               ,pr_dsdadant => pr_rgimovel.nrlograd
                               ,pr_dsdadatu => rw_rgimovel_novo.nrlograd);
    END IF;
    ----
    IF nvl(pr_rgimovel.dscmplgr,' ') <> nvl(rw_rgimovel_novo.dscmplgr,' ')  THEN
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowidlog
                               ,pr_nmdcampo => 'DSCMPLGR'
                               ,pr_dsdadant => pr_rgimovel.dscmplgr
                               ,pr_dsdadatu => rw_rgimovel_novo.dscmplgr);
    END IF;
    ----
    IF nvl(pr_rgimovel.dsbairro,' ') <> nvl(rw_rgimovel_novo.dsbairro,' ')  THEN
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowidlog
                               ,pr_nmdcampo => 'DSBAIRRO'
                               ,pr_dsdadant => pr_rgimovel.dsbairro
                               ,pr_dsdadatu => rw_rgimovel_novo.dsbairro);
    END IF;
    ----
    IF nvl(pr_rgimovel.cdcidade,-1) <> nvl(rw_rgimovel_novo.cdcidade,-1)  THEN
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowidlog
                               ,pr_nmdcampo => 'CDCIDADE'
                               ,pr_dsdadant => pr_rgimovel.cdcidade
                               ,pr_dsdadatu => rw_rgimovel_novo.cdcidade);
    END IF;
    ----
    IF nvl(pr_rgimovel.nrceplgr,-1) <> nvl(rw_rgimovel_novo.nrceplgr,-1)  THEN
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowidlog
                               ,pr_nmdcampo => 'NRCEPLGR'
                               ,pr_dsdadant => pr_rgimovel.nrceplgr
                               ,pr_dsdadatu => rw_rgimovel_novo.nrceplgr);
    END IF;
    ----
    IF nvl(pr_rgimovel.dtavlimv,SYSDATE) <> nvl(rw_rgimovel_novo.dtavlimv,SYSDATE)  THEN
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowidlog
                               ,pr_nmdcampo => 'DTAVLIMV'
                               ,pr_dsdadant => pr_rgimovel.dtavlimv
                               ,pr_dsdadatu => rw_rgimovel_novo.dtavlimv);
    END IF;
    ----
    IF nvl(pr_rgimovel.vlavlimv,-1) <> nvl(rw_rgimovel_novo.vlavlimv,-1)  THEN
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowidlog
                               ,pr_nmdcampo => 'VLAVLIMV'
                               ,pr_dsdadant => pr_rgimovel.vlavlimv
                               ,pr_dsdadatu => rw_rgimovel_novo.vlavlimv);
    END IF;
    ----
    IF nvl(pr_rgimovel.dtcprimv,SYSDATE) <> nvl(rw_rgimovel_novo.dtcprimv,SYSDATE)  THEN
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowidlog
                               ,pr_nmdcampo => 'DTCPRIMV'
                               ,pr_dsdadant => pr_rgimovel.dtcprimv
                               ,pr_dsdadatu => rw_rgimovel_novo.dtcprimv);
    END IF;
    ----
    IF nvl(pr_rgimovel.vlcprimv,-1) <> nvl(rw_rgimovel_novo.vlcprimv,-1)  THEN
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowidlog
                               ,pr_nmdcampo => 'VLCPRIMV'
                               ,pr_dsdadant => pr_rgimovel.vlcprimv
                               ,pr_dsdadatu => rw_rgimovel_novo.vlcprimv);
    END IF;
    ----
    IF nvl(pr_rgimovel.tpimpimv,-1) <> nvl(rw_rgimovel_novo.tpimpimv,-1)  THEN
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowidlog
                               ,pr_nmdcampo => 'TPIMPIMV'
                               ,pr_dsdadant => pr_rgimovel.tpimpimv
                               ,pr_dsdadatu => rw_rgimovel_novo.tpimpimv);
    END IF;
    ----
    IF nvl(pr_rgimovel.incsvimv,-1) <> nvl(rw_rgimovel_novo.incsvimv,-1)  THEN
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowidlog
                               ,pr_nmdcampo => 'INCSVIMV'
                               ,pr_dsdadant => pr_rgimovel.incsvimv
                               ,pr_dsdadatu => rw_rgimovel_novo.incsvimv);
    END IF;
    ----
    IF nvl(pr_rgimovel.inpdracb,-1) <> nvl(rw_rgimovel_novo.inpdracb,-1)  THEN
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowidlog
                               ,pr_nmdcampo => 'INPDRACB'
                               ,pr_dsdadant => pr_rgimovel.inpdracb
                               ,pr_dsdadatu => rw_rgimovel_novo.inpdracb);
    END IF;
    ----
    IF nvl(pr_rgimovel.vlmtrtot,-1) <> nvl(rw_rgimovel_novo.vlmtrtot,-1)  THEN
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowidlog
                               ,pr_nmdcampo => 'VLMTRTOT'
                               ,pr_dsdadant => pr_rgimovel.vlmtrtot
                               ,pr_dsdadatu => rw_rgimovel_novo.vlmtrtot);
    END IF;
    ----
    IF nvl(pr_rgimovel.vlmtrpri,-1) <> nvl(rw_rgimovel_novo.vlmtrpri,-1)  THEN
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowidlog
                               ,pr_nmdcampo => 'VLMTRPRI'
                               ,pr_dsdadant => pr_rgimovel.vlmtrpri
                               ,pr_dsdadatu => rw_rgimovel_novo.vlmtrpri);
    END IF;
    ----
    IF nvl(pr_rgimovel.qtdormit,-1) <> nvl(rw_rgimovel_novo.qtdormit,-1)  THEN
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowidlog
                               ,pr_nmdcampo => 'QTDORMIT'
                               ,pr_dsdadant => pr_rgimovel.qtdormit
                               ,pr_dsdadatu => rw_rgimovel_novo.qtdormit);
    END IF;
    ----
    IF nvl(pr_rgimovel.qtdvagas,-1) <> nvl(rw_rgimovel_novo.qtdvagas,-1)  THEN
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowidlog
                               ,pr_nmdcampo => 'QTDVAGAS'
                               ,pr_dsdadant => pr_rgimovel.qtdvagas
                               ,pr_dsdadatu => rw_rgimovel_novo.qtdvagas);
    END IF;
    ----
    IF nvl(pr_rgimovel.vlmtrter,-1) <> nvl(rw_rgimovel_novo.vlmtrter,-1)  THEN
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowidlog
                               ,pr_nmdcampo => 'VLMTRTER'
                               ,pr_dsdadant => pr_rgimovel.vlmtrter
                               ,pr_dsdadatu => rw_rgimovel_novo.vlmtrter);
    END IF;
    ----
    IF nvl(pr_rgimovel.vlmtrtes,-1) <> nvl(rw_rgimovel_novo.vlmtrtes,-1)  THEN
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowidlog
                               ,pr_nmdcampo => 'VLMTRTES'
                               ,pr_dsdadant => pr_rgimovel.vlmtrtes
                               ,pr_dsdadatu => rw_rgimovel_novo.vlmtrtes);
    END IF;
    ----
    IF nvl(pr_rgimovel.incsvcon,-1) <> nvl(rw_rgimovel_novo.incsvcon,-1)  THEN
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowidlog
                               ,pr_nmdcampo => 'INCSVCON'
                               ,pr_dsdadant => pr_rgimovel.incsvcon
                               ,pr_dsdadatu => rw_rgimovel_novo.incsvcon);
    END IF;
    ----
    IF nvl(pr_rgimovel.inpesvdr,-1) <> nvl(rw_rgimovel_novo.inpesvdr,-1)  THEN
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowidlog
                               ,pr_nmdcampo => 'INPESVDR'
                               ,pr_dsdadant => pr_rgimovel.inpesvdr
                               ,pr_dsdadatu => rw_rgimovel_novo.inpesvdr);
    END IF;
    ----
    IF nvl(pr_rgimovel.nrdocvdr,-1) <> nvl(rw_rgimovel_novo.nrdocvdr,-1)  THEN
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowidlog
                               ,pr_nmdcampo => 'NRDOCVDR'
                               ,pr_dsdadant => pr_rgimovel.nrdocvdr
                               ,pr_dsdadatu => rw_rgimovel_novo.nrdocvdr);
    END IF;
    ----
    IF nvl(pr_rgimovel.nmvendor,' ') <> nvl(rw_rgimovel_novo.nmvendor,' ')  THEN
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowidlog
                               ,pr_nmdcampo => 'NMVENDOR'
                               ,pr_dsdadant => pr_rgimovel.nmvendor
                               ,pr_dsdadatu => rw_rgimovel_novo.nmvendor);
    END IF;
    ----
    IF nvl(pr_rgimovel.nrreginc,-1) <> nvl(rw_rgimovel_novo.nrreginc,-1)  THEN
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowidlog
                               ,pr_nmdcampo => 'NRREGINC'
                               ,pr_dsdadant => pr_rgimovel.nrreginc
                               ,pr_dsdadatu => rw_rgimovel_novo.nrreginc);
    END IF;
    ----
    IF nvl(pr_rgimovel.dtinclus,SYSDATE) <> nvl(rw_rgimovel_novo.dtinclus,SYSDATE)  THEN
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowidlog
                               ,pr_nmdcampo => 'DTINCLUS'
                               ,pr_dsdadant => pr_rgimovel.dtinclus
                               ,pr_dsdadatu => rw_rgimovel_novo.dtinclus);
    END IF;
    ----
    IF nvl(pr_rgimovel.tpinclus,' ') <> nvl(rw_rgimovel_novo.tpinclus,' ')  THEN
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowidlog
                               ,pr_nmdcampo => 'TPINCLUS'
                               ,pr_dsdadant => pr_rgimovel.tpinclus
                               ,pr_dsdadatu => rw_rgimovel_novo.tpinclus);
    END IF;
    ----
    IF nvl(pr_rgimovel.dsjstinc,' ') <> nvl(rw_rgimovel_novo.dsjstinc,' ')  THEN
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowidlog
                               ,pr_nmdcampo => 'DSJSTINC'
                               ,pr_dsdadant => pr_rgimovel.dsjstinc
                               ,pr_dsdadatu => rw_rgimovel_novo.dsjstinc);
    END IF;
    ----
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001,'Erro pc_registra_alteracao_imovel: '||SQLERRM);
  END pc_registra_alteracao_imovel;
  
  -- Rotina para gerar os logs de baixa do imóvel
  PROCEDURE pc_registra_baixa_imovel(pr_cdcooper   IN tbepr_imovel_alienado.cdcooper%TYPE
                                    ,pr_nrdconta   IN tbepr_imovel_alienado.nrdconta%TYPE
                                    ,pr_nrctremp   IN tbepr_imovel_alienado.nrctrpro%TYPE
                                    ,pr_idseqbem   IN tbepr_imovel_alienado.idseqbem%TYPE
                                    ,pr_rgimovel   IN cr_tbepr_imovel_alienado%ROWTYPE) IS  -- Contém os dados antigos do imóvel
    
    -- Variáveis
    rw_rgimovel_novo    cr_tbepr_imovel_alienado%ROWTYPE;
    vr_rowidlog         VARCHAR2(20);
                              
  BEGIN
    
    -- Buscar o registro com os novos dados 
    OPEN  cr_tbepr_imovel_alienado(pr_cdcooper, pr_nrdconta, pr_nrctremp, pr_idseqbem);
    FETCH cr_tbepr_imovel_alienado INTO rw_rgimovel_novo;
    CLOSE cr_tbepr_imovel_alienado;
         
    -- Registrar o log de inclusão/alteração
    GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                        ,pr_cdoperad => rw_rgimovel_novo.cdoperad
                        ,pr_dscritic => ' '
                        ,pr_dsorigem => gene0001.vr_vet_des_origens(1)
                        ,pr_dstransa => 'Registro de baixa manual.'
                        ,pr_dttransa => SYSDATE
                        ,pr_flgtrans => 1
                        ,pr_hrtransa => GENE0002.fn_busca_time
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => 'IMOVEL'
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_rowidlog);
    
    /*** Verifica as diferenças campo a campo e faz o registro dos novos valores ***/
    ----
    IF nvl(pr_rgimovel.flgenvia,-1) = nvl(rw_rgimovel_novo.flgenvia,-1)  THEN
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowidlog
                               ,pr_nmdcampo => 'FLGENVIA'
                               ,pr_dsdadant => pr_rgimovel.flgenvia
                               ,pr_dsdadatu => rw_rgimovel_novo.flgenvia);
    END IF;
    ----
    IF nvl(pr_rgimovel.cdsituac,-1) = nvl(rw_rgimovel_novo.cdsituac,-1)  THEN
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowidlog
                               ,pr_nmdcampo => 'CDSITUAC'
                               ,pr_dsdadant => pr_rgimovel.cdsituac
                               ,pr_dsdadatu => rw_rgimovel_novo.cdsituac);
    END IF;
    ----
    IF nvl(pr_rgimovel.dtdbaixa,SYSDATE) = nvl(rw_rgimovel_novo.dtdbaixa,SYSDATE)  THEN
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowidlog
                               ,pr_nmdcampo => 'DTDBAIXA'
                               ,pr_dsdadant => pr_rgimovel.dtdbaixa
                               ,pr_dsdadatu => rw_rgimovel_novo.dtdbaixa);
    END IF;
    ----
    IF nvl(pr_rgimovel.tpdbaixa,' ') = nvl(rw_rgimovel_novo.tpdbaixa,' ')  THEN
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowidlog
                               ,pr_nmdcampo => 'TPDBAIXA'
                               ,pr_dsdadant => pr_rgimovel.tpdbaixa
                               ,pr_dsdadatu => rw_rgimovel_novo.tpdbaixa);
    END IF;
    ----
    IF nvl(pr_rgimovel.dsjstbxa,' ') = nvl(rw_rgimovel_novo.dsjstbxa,' ')  THEN
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowidlog
                               ,pr_nmdcampo => 'DSJSTBXA'
                               ,pr_dsdadant => pr_rgimovel.dsjstbxa
                               ,pr_dsdadatu => rw_rgimovel_novo.dsjstbxa);
    END IF;
    ----
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20002,'Erro geral pc_registra_baixa_imovel: '||SQLERRM);
  END pc_registra_baixa_imovel;

  -- Gerar o relatório de registros de inclusão e baixa enviados via arquivo
  PROCEDURE pc_relatorio_enviados(pr_cdcooper  IN NUMBER                --> Código da cooperativa conectada
                                 ,pr_cdcoptel  IN NUMBER                --> Código da cooperativa selecionada na tela
                                 ,pr_intiprel  IN VARCHAR2              --> Indica o tipo do relatório
                                 ,pr_dtrefere  IN VARCHAR2              --> Data de referencia para os itens do relatório
                                 ,pr_cddolote  IN NUMBER                --> Código do Lote
                                 ,pr_nmarquiv OUT VARCHAR2) IS          --> Retorna o nome do arquivo gerado
    /* .............................................................................
    Programa: pc_relatorio_enviados
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Renato Darosci/SUPERO
    Data    : Junho/2016                       Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para gerar o relatório de registros de inclusão e baixa enviados via arquivo

    Alteracoes:
    ............................................................................. */
    
    -- Buscar os dados de registros enviados e não retornados
    CURSOR cr_dados_sem_retorno IS
      SELECT to_char(imv.cdcooper,'FM000')                 cdcooper
           , to_char(ass.cdagenci,'FM000')                 cdagenci
           , decode(env.tpoperacao, 'A', 'ALTERACAO'
                                  , 'B', 'BAIXA'
                                  , 'I', 'INCLUSAO')       dsoperac
           , TO_CHAR(env.nrdolote,'FM0000000')             nrdolote
           , TRIM(GENE0002.fn_mask_conta(imv.nrdconta))    nrdconta
           , GENE0002.fn_mask_cpf_cnpj(ass.nrcpfcgc
                                      ,ass.inpessoa)       nrcpfcgc
           , TRIM(GENE0002.fn_mask_contrato(imv.nrctrpro)) nrctrpro
           , bpr.idseqbem
           , bpr.idseqbem||'-'||bpr.dsbemfin               dsbemfin
           , to_char(env.dtenvio,'DD/MM/YYYY')             dtdenvio
        FROM crapass               ass
           , crapbpr               bpr
           , tbepr_envio_cetip     env
           , tbepr_imovel_alienado imv
       WHERE ass.cdcooper = imv.cdcooper
         AND ass.nrdconta = imv.nrdconta
         AND bpr.cdcooper = imv.cdcooper
         AND bpr.nrdconta = imv.nrdconta
         AND bpr.tpctrpro = 90
         AND bpr.nrctrpro = imv.nrctrpro
         AND bpr.idseqbem = imv.idseqbem
         AND env.cdcooper = imv.cdcooper
         AND env.nrdconta = imv.nrdconta
         AND env.nrctrpro = imv.nrctrpro
         AND env.idseqbem = imv.idseqbem
         AND env.dtretorno IS NULL
         -- Filtros
         AND (env.tpoperacao = pr_intiprel OR pr_intiprel = 'T')  -- Por operacao ou todos
         AND (env.nrdolote   = pr_cddolote OR pr_cddolote IS NULL)-- Data especifica ou todas
         AND (env.cdcooper   = pr_cdcoptel OR pr_cdcoptel = 0  )  -- Todas as cooperativas ou específica
       ORDER BY cdcooper, cdagenci, nrdconta, nrctrpro, idseqbem, nrdolote
                , env.nrseqlote;
    
    -- Buscar os dados de registros processados com sucesso
    CURSOR cr_dados_sucesso IS
      SELECT to_char(imv.cdcooper,'FM000')                 cdcooper
           , to_char(ass.cdagenci,'FM000')                 cdagenci
           , DECODE(env.tpoperacao,'I','INCLUSAO'
                                  ,'A','ALTERACAO'
                                  ,'B','BAIXA') dsoperac
           , LPAD(env.nrdolote,7,'0')                      nrdolote
           , TRIM(GENE0002.fn_mask_conta(imv.nrdconta))    nrdconta
           , GENE0002.fn_mask_cpf_cnpj(ass.nrcpfcgc
                                      ,ass.inpessoa)       nrcpfcgc
           , TRIM(GENE0002.fn_mask_contrato(imv.nrctrpro)) nrctrpro
           , bpr.idseqbem
           , bpr.idseqbem||'-'||bpr.dsbemfin               dsbemfin
           , to_char(env.dtenvio,'dd/mm/yyyy')             dtdenvio
           , to_char(env.dtretorno,'dd/mm/yyyy')           dtretorn
           , DECODE(env.tpoperacao,'I',DECODE(env.cdretorno, 5,'INCLUSAO - Sucesso: Nr. Registro: '||imv.nrreg_cetip
                                                              ,'CRITICA - '||env.cdretorno||' - '||rto.dsretorn)
                                  ,'A',DECODE(env.cdretorno, 8,'ALTERACAO - Sucesso'
                                                              ,'CRITICA - '||env.cdretorno||' - '||rto.dsretorn)
                                  ,'B',DECODE(env.cdretorno, 9,'BAIXA - Sucesso'
                                                              ,'CRITICA - '||env.cdretorno||' - '||rto.dsretorn))  dssituac
           , env.cdretorno
        FROM crapass               ass
           , crapbpr               bpr
           , craprto               rto
           , tbepr_imovel_alienado imv
           , tbepr_envio_cetip     env
       WHERE ass.cdcooper   = imv.cdcooper
         AND ass.nrdconta   = imv.nrdconta
         AND bpr.cdcooper   = imv.cdcooper
         AND bpr.nrdconta   = imv.nrdconta
         AND bpr.tpctrpro   = 90
         AND bpr.nrctrpro   = imv.nrctrpro
         AND bpr.idseqbem   = imv.idseqbem
         ---
         AND rto.cdretorn = env.cdretorno
         AND rto.nrtabela = 1    -- Será tabela fixa
         AND rto.cdoperac = 'I'  -- Produto 3 será tratado como I fixo
         AND rto.cdprodut = 3    -- CETIP
         ---
         AND env.cdcooper   = imv.cdcooper
         AND env.nrdconta   = imv.nrdconta
         AND env.nrctrpro   = imv.nrctrpro
         AND env.idseqbem   = imv.idseqbem
         -- Filtros
         AND (env.tpoperacao = pr_intiprel OR 
              pr_intiprel = 'T'  OR 
              (pr_intiprel = 'C' AND env.cdretorno NOT IN (5,8,9)))
         AND (env.dtenvio    = pr_dtrefere OR pr_dtrefere IS NULL)-- Data especifica ou todas
         AND (env.nrdolote   = pr_cddolote OR pr_cddolote IS NULL)-- Data especifica ou todas
         AND (env.cdcooper   = pr_cdcoptel OR pr_cdcoptel = 0  )  -- Todas as cooperativas oou específica
         
         ORDER BY cdcooper, cdagenci, nrdconta, nrctrpro, idseqbem, nrdolote
                , env.nrseqlote;
      
    -- VARIÁVEIS
    vr_xml       CLOB; --> CLOB com conteudo do XML do relatório
    vr_xmlbuffer VARCHAR2(32767); --> Auxiliar para envio do texto ao XML
    vr_strbuffer VARCHAR2(32767); --> Auxiliar para envio do texto ao XML
        
    -- Variaveis para a geracao do relatorio
    vr_nom_direto VARCHAR2(500);
    vr_nmarqimp   VARCHAR2(100);

    -- Variaveis extraidas do xml pr_retxml
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    
    -- Variável de críticas
    vr_dscritic  VARCHAR2(10000);
    vr_des_reto  VARCHAR2(10);
    vr_typ_saida VARCHAR2(3);
    vr_tab_erro  gene0001.typ_tab_erro;
    
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    
  BEGIN
    
    -- Inicializar XML do relatório
    dbms_lob.createtemporary(vr_xml, TRUE);
    dbms_lob.open(vr_xml, dbms_lob.lob_readwrite);
    
    vr_strbuffer := '<?xml version="1.0" encoding="utf-8"?><root>';
    
    -- Enviar ao CLOB
    gene0002.pc_escreve_xml(pr_xml            => vr_xml
                           ,pr_texto_completo => vr_xmlbuffer
                           ,pr_texto_novo     => vr_strbuffer);
    -- Limpar a auxiliar
    vr_strbuffer := '<semretorno>';
    
    -- Buscar todos os dados dos registros enviados que não foram retornados ainda
    FOR rw_reg IN cr_dados_sem_retorno LOOP
      
      vr_strbuffer := vr_strbuffer || 
                    '<registro>' || 
                        '<cdcooper>' || rw_reg.cdcooper || '</cdcooper>' ||
                        '<cdagenci>' || rw_reg.cdagenci || '</cdagenci>' ||
                        '<dsoperac>' || rw_reg.dsoperac || '</dsoperac>' ||
                        '<nrdolote>' || rw_reg.nrdolote || '</nrdolote>' ||
                        '<nrdconta>' || rw_reg.nrdconta || '</nrdconta>' ||
                        '<nrcpfcgc>' || rw_reg.nrcpfcgc || '</nrcpfcgc>' ||
                        '<nrctrpro>' || rw_reg.nrctrpro || '</nrctrpro>' ||
                        '<dsbemfin>' || rw_reg.dsbemfin || '</dsbemfin>' || 
                        '<dtdenvio>' || rw_reg.dtdenvio || '</dtdenvio>' || 
                    '</registro>';
    END LOOP;
    
    vr_strbuffer := vr_strbuffer || '</semretorno>';
    
    -- Enviar ao CLOB
    gene0002.pc_escreve_xml(pr_xml            => vr_xml
                           ,pr_texto_completo => vr_xmlbuffer
                           ,pr_texto_novo     => vr_strbuffer
                           ,pr_fecha_xml      => FALSE); --> Ultima chamada
        
    -- Limpar a auxiliar
    vr_strbuffer := '<processados>';
    
    -- Buscar todos os dados dos registros enviados que não foram retornados ainda
    FOR rw_reg IN cr_dados_sucesso LOOP
      
      vr_strbuffer := vr_strbuffer || 
                    '<registro>' || 
                        '<cdcooper>' || rw_reg.cdcooper || '</cdcooper>' ||
                        '<cdagenci>' || rw_reg.cdagenci || '</cdagenci>' ||
                        '<dsoperac>' || rw_reg.dsoperac || '</dsoperac>' ||
                        '<nrdolote>' || rw_reg.nrdolote || '</nrdolote>' ||
                        '<nrdconta>' || rw_reg.nrdconta || '</nrdconta>' ||
                        '<nrcpfcgc>' || rw_reg.nrcpfcgc || '</nrcpfcgc>' ||
                        '<nrctrpro>' || rw_reg.nrctrpro || '</nrctrpro>' || 
                        '<dsbemfin>' || rw_reg.dsbemfin || '</dsbemfin>' || 
                        '<dtdenvio>' || rw_reg.dtdenvio || '</dtdenvio>' || 
                        '<dtretorn>' || rw_reg.dtretorn || '</dtretorn>' || 
                        '<dssituac>' || rw_reg.dssituac || '</dssituac>' || 
                    '</registro>';
    END LOOP;
    
    vr_strbuffer := vr_strbuffer || '</processados></root>';
    
    -- Enviar ao CLOB
    gene0002.pc_escreve_xml(pr_xml            => vr_xml
                           ,pr_texto_completo => vr_xmlbuffer
                           ,pr_texto_novo     => vr_strbuffer
                           ,pr_fecha_xml      => TRUE); --> Ultima chamada
    
    
    -- Somente se o CLOB contiver informações
    IF dbms_lob.getlength(vr_xml) > 0 THEN
      
      -- Busca do diretório base da cooperativa para PDF
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl
      
      -- Definir nome do relatorio
      vr_nmarqimp := 'crrl722_' || GENE0002.fn_busca_time || '.pdf';
      
      -- Solicitar geração do relatorio
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper --> Cooperativa conectada
                                 ,pr_cdprogra  => 'IMOVEL' --> Programa chamador
                                 ,pr_dtmvtolt  => SYSDATE --> Data do movimento atual
                                 ,pr_dsxml     => vr_xml --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/root' --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl722.jasper' --> Arquivo de layout do iReport
                                 ,pr_dsparams  => null --> Sem parâmetros
                                 ,pr_dsarqsaid => vr_nom_direto || '/' || vr_nmarqimp --> Arquivo final com o path
                                 ,pr_cdrelato  => 722
                                 ,pr_qtcoluna  => 234 --> 132 colunas
                                 ,pr_flg_gerar => 'S' --> Geraçao na hora
                                 ,pr_flg_impri => 'N' --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => '' --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1 --> Número de cópias
                                 ,pr_sqcabrel  => 1 --> Qual a seq do cabrel
                                 ,pr_des_erro  => vr_dscritic); --> Saída com erro

      -- Tratar erro
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        raise vr_exc_saida;
      END IF;
      
      -- Enviar relatorio para intranet
      gene0002.pc_efetua_copia_pdf(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                  ,pr_cdagenci => vr_cdagenci --> Codigo da agencia para erros
                                  ,pr_nrdcaixa => vr_nrdcaixa --> Codigo do caixa para erros
                                  ,pr_nmarqpdf => vr_nom_direto || '/' ||vr_nmarqimp --> Arquivo PDF  a ser gerado
                                  ,pr_des_reto => vr_des_reto --> Saída com erro
                                  ,pr_tab_erro => vr_tab_erro); --> tabela de erros
      
      -- caso apresente erro na operação
      IF nvl(vr_des_reto, 'OK') <> 'OK' THEN
        IF vr_tab_erro.COUNT > 0 THEN
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          
          RAISE vr_exc_saida;
        END IF;
      END IF;
      
      -- Remover relatorio da pasta rl apos gerar
      gene0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => 'rm ' || vr_nom_direto || '/' || vr_nmarqimp
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);
      -- Se retornou erro
      IF vr_typ_saida = 'ERR'
         OR vr_dscritic IS NOT null THEN
        -- Concatena o erro que veio
        vr_dscritic := 'Erro ao remover arquivo: ' || vr_dscritic;
        RAISE vr_exc_saida;
      END IF;
      
    END IF;
    
    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_xml);
    dbms_lob.freetemporary(vr_xml);
    
    -- retornar o nome do arquivo
    pr_nmarquiv := vr_nmarqimp;
  EXCEPTION
    WHEN vr_exc_saida THEN
      raise_application_error(-20013, vr_dscritic );
    WHEN OTHERS THEN
      raise_application_error(-20003,'Erro pc_relatorio_enviados: '||SQLERRM );
  END pc_relatorio_enviados;


  -- Gerar o relatório de registros de inclusão e baixa enviados via arquivo
  PROCEDURE pc_relatorio_manual(pr_cdcooper  IN NUMBER                --> Código da cooperativa conectada
                               ,pr_cdcoptel  IN NUMBER                --> Código da cooperativa selecionada na tela
                               ,pr_intiprel  IN VARCHAR2              --> Indica o tipo do relatório
                               ,pr_dtrefere  IN VARCHAR2              --> Data de referencia para os itens do relatório
                               ,pr_nmarquiv OUT VARCHAR2) IS          --> Retorna o nome do arquivo gerado
    /* .............................................................................
    Programa: pc_relatorio_manual
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Renato Darosci/SUPERO
    Data    : Junho/2016                       Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para gerar o relatório de registros de inclusão e baixa enviados via arquivo

    Alteracoes:
    ............................................................................. */
    
    -- Buscar os dados de registros inclusos manualmente
    CURSOR cr_dados_inclusao IS
      SELECT to_char(imv.cdcooper,'FM000')                 cdcooper
           , to_char(ass.cdagenci,'FM000')                 cdagenci
           , TRIM(GENE0002.fn_mask_conta(imv.nrdconta))    nrdconta
           , GENE0002.fn_mask_cpf_cnpj(ass.nrcpfcgc
                                      ,ass.inpessoa)       nrcpfcgc
           , TRIM(GENE0002.fn_mask_contrato(imv.nrctrpro)) nrctrpro
           , bpr.idseqbem
           , bpr.idseqbem||'-'||bpr.dsbemfin               dsbemfin
           , to_char(imv.dtinclusao,'dd/mm/yyyy')          dtoperac
           , imv.nrreg_cetip                               nrregctp
           , imv.dsjustific_inclus                         dsjustif
        FROM crapass               ass
           , crapbpr               bpr
           , tbepr_imovel_alienado imv
       WHERE ass.cdcooper = imv.cdcooper
         AND ass.nrdconta = imv.nrdconta
         AND bpr.cdcooper = imv.cdcooper
         AND bpr.nrdconta = imv.nrdconta
         AND bpr.tpctrpro = 90
         AND bpr.nrctrpro = imv.nrctrpro
         AND bpr.idseqbem = imv.idseqbem
         AND imv.tpinclusao = 'M'   -- Registros com tipo de inclusão igual a MANUAL
         AND (imv.dtinclusao = TO_DATE(pr_dtrefere,'DD/MM/YYYY') OR pr_dtrefere IS NULL)
         AND (imv.cdcooper   = pr_cdcoptel OR pr_cdcoptel = 0)
       ORDER BY cdcooper, cdagenci, nrdconta, nrctrpro, dtoperac, idseqbem;
    
    -- Buscar os dados de registros baixados manualmente
    CURSOR cr_dados_baixa IS
      SELECT to_char(imv.cdcooper,'FM000')                 cdcooper
           , to_char(ass.cdagenci,'FM000')                 cdagenci
           , TRIM(GENE0002.fn_mask_conta(imv.nrdconta))    nrdconta
           , GENE0002.fn_mask_cpf_cnpj(ass.nrcpfcgc
                                      ,ass.inpessoa)       nrcpfcgc
           , TRIM(GENE0002.fn_mask_contrato(imv.nrctrpro)) nrctrpro
           , bpr.idseqbem
           , bpr.idseqbem||'-'||bpr.dsbemfin               dsbemfin
           , to_char(imv.dtbaixa,'dd/mm/yyyy')             dtoperac
           , imv.dsjustific_baixa                          dsjustif
        FROM crapass               ass
           , crapbpr               bpr
           , tbepr_imovel_alienado imv
       WHERE ass.cdcooper = imv.cdcooper
         AND ass.nrdconta = imv.nrdconta
         AND bpr.cdcooper = imv.cdcooper
         AND bpr.nrdconta = imv.nrdconta
         AND bpr.tpctrpro = 90
         AND bpr.nrctrpro = imv.nrctrpro
         AND bpr.idseqbem = imv.idseqbem
         AND imv.tpbaixa  = 'M'   -- Registros com tipo de inclusão igual a MANUAL
         AND (imv.dtbaixa = TO_DATE(pr_dtrefere,'DD/MM/YYYY') OR pr_dtrefere IS NULL)
         AND (imv.cdcooper   = pr_cdcoptel OR pr_cdcoptel = 0)
       ORDER BY cdcooper, cdagenci, nrdconta, nrctrpro, dtoperac, idseqbem;
    
    -- VARIÁVEIS
    vr_xml       CLOB; --> CLOB com conteudo do XML do relatório
    vr_xmlbuffer VARCHAR2(32767); --> Auxiliar para envio do texto ao XML
    vr_strbuffer VARCHAR2(32767); --> Auxiliar para envio do texto ao XML
        
    -- Variaveis para a geracao do relatorio
    vr_nom_direto VARCHAR2(500);
    vr_nmarqimp   VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    
    -- Variável de críticas
    --vr_cdcritic  crapcri.cdcritic%TYPE;
    vr_dscritic  VARCHAR2(10000);
    vr_des_reto  VARCHAR2(10);
    vr_typ_saida VARCHAR2(3);
    vr_tab_erro  gene0001.typ_tab_erro;
    
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    
  BEGIN
    
    -- Inicializar XML do relatório
    dbms_lob.createtemporary(vr_xml, TRUE);
    dbms_lob.open(vr_xml, dbms_lob.lob_readwrite);
    
    vr_strbuffer := '<?xml version="1.0" encoding="utf-8"?><root intiprel="'||pr_intiprel||'">';
    
    -- Enviar ao CLOB
    gene0002.pc_escreve_xml(pr_xml            => vr_xml
                           ,pr_texto_completo => vr_xmlbuffer
                           ,pr_texto_novo     => vr_strbuffer);
    
    -- Limpar a auxiliar
    vr_strbuffer := '<inclusao>';
    
    -- Se o tipo de relatório for Todos ou Inclusão
    IF pr_intiprel IN ('T','I') THEN
        
      -- Buscar todos os dados dos registros enviados que não foram retornados ainda
      FOR rw_reg IN cr_dados_inclusao LOOP
        
        vr_strbuffer := vr_strbuffer || 
                      '<registro>' || 
                          '<cdcooper>' || rw_reg.cdcooper || '</cdcooper>' ||
                          '<cdagenci>' || rw_reg.cdagenci || '</cdagenci>' ||
                          '<nrdconta>' || rw_reg.nrdconta || '</nrdconta>' ||
                          '<nrcpfcgc>' || rw_reg.nrcpfcgc || '</nrcpfcgc>' ||
                          '<nrctrpro>' || rw_reg.nrctrpro || '</nrctrpro>' ||
                          '<dsbemfin>' || rw_reg.dsbemfin || '</dsbemfin>' ||
                          '<nrregctp>' || rw_reg.nrregctp || '</nrregctp>' ||
                          '<dtoperac>' || rw_reg.dtoperac || '</dtoperac>' || 
                          '<dsjustif>' || rw_reg.dsjustif || '</dsjustif>' || 
                      '</registro>';
      END LOOP;
    
    END IF;
     
    vr_strbuffer := vr_strbuffer || '</inclusao>';
      
    -- Enviar ao CLOB
    gene0002.pc_escreve_xml(pr_xml            => vr_xml
                           ,pr_texto_completo => vr_xmlbuffer
                           ,pr_texto_novo     => vr_strbuffer
                           ,pr_fecha_xml      => FALSE); --> Ultima chamada
    
    -- Limpar a auxiliar
    vr_strbuffer := '<baixa>';
    
    -- Se o tipo de relatório for Todos ou Baixa
    IF pr_intiprel IN ('T','B') THEN
      
      -- Buscar todos os dados dos registros enviados que não foram retornados ainda
      FOR rw_reg IN cr_dados_baixa LOOP
        
        vr_strbuffer := vr_strbuffer || 
                      '<registro>' || 
                          '<cdcooper>' || rw_reg.cdcooper || '</cdcooper>' ||
                          '<cdagenci>' || rw_reg.cdagenci || '</cdagenci>' ||
                          '<nrdconta>' || rw_reg.nrdconta || '</nrdconta>' ||
                          '<nrcpfcgc>' || rw_reg.nrcpfcgc || '</nrcpfcgc>' ||
                          '<nrctrpro>' || rw_reg.nrctrpro || '</nrctrpro>' ||
                          '<dsbemfin>' || rw_reg.dsbemfin || '</dsbemfin>' ||
                          '<dtoperac>' || rw_reg.dtoperac || '</dtoperac>' || 
                          '<dsjustif>' || rw_reg.dsjustif || '</dsjustif>' || 
                      '</registro>';
      END LOOP;
    
    END IF;  
    
    vr_strbuffer := vr_strbuffer || '</baixa></root>';
      
    -- Enviar ao CLOB
    gene0002.pc_escreve_xml(pr_xml            => vr_xml
                           ,pr_texto_completo => vr_xmlbuffer
                           ,pr_texto_novo     => vr_strbuffer
                           ,pr_fecha_xml      => TRUE); --> Ultima chamada
    
    -- Somente se o CLOB contiver informações
    IF dbms_lob.getlength(vr_xml) > 0 THEN
      
      -- Busca do diretório base da cooperativa para PDF
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl
      
      -- Definir nome do relatorio
      vr_nmarqimp := 'crrl722_' || GENE0002.fn_busca_time || '.pdf';
      
      -- Solicitar geração do relatorio
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper --> Cooperativa conectada
                                 ,pr_cdprogra  => 'IMOVEL' --> Programa chamador
                                 ,pr_dtmvtolt  => SYSDATE --> Data do movimento atual
                                 ,pr_dsxml     => vr_xml --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/root' --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl723.jasper' --> Arquivo de layout do iReport
                                 ,pr_dsparams  => null --> Sem parâmetros
                                 ,pr_dsarqsaid => vr_nom_direto || '/' || vr_nmarqimp --> Arquivo final com o path
                                 ,pr_cdrelato  => 723
                                 ,pr_qtcoluna  => 132 --> 132 colunas
                                 ,pr_flg_gerar => 'S' --> Geraçao na hora
                                 ,pr_flg_impri => 'N' --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => '' --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1 --> Número de cópias
                                 ,pr_sqcabrel  => 1 --> Qual a seq do cabrel
                                 ,pr_des_erro  => vr_dscritic); --> Saída com erro

      -- Tratar erro
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        raise vr_exc_saida;
      END IF;
      
      -- Enviar relatorio para intranet
      gene0002.pc_efetua_copia_pdf(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                  ,pr_cdagenci => vr_cdagenci --> Codigo da agencia para erros
                                  ,pr_nrdcaixa => vr_nrdcaixa --> Codigo do caixa para erros
                                  ,pr_nmarqpdf => vr_nom_direto || '/' ||vr_nmarqimp --> Arquivo PDF  a ser gerado
                                  ,pr_des_reto => vr_des_reto --> Saída com erro
                                  ,pr_tab_erro => vr_tab_erro); --> tabela de erros
      
      -- caso apresente erro na operação
      IF nvl(vr_des_reto, 'OK') <> 'OK' THEN
        IF vr_tab_erro.COUNT > 0 THEN
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          
          RAISE vr_exc_saida;
        END IF;
      END IF;
      
      -- Remover relatorio da pasta rl apos gerar
      gene0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => 'rm ' || vr_nom_direto || '/' || vr_nmarqimp
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);
      -- Se retornou erro
      IF vr_typ_saida = 'ERR'
         OR vr_dscritic IS NOT null THEN
        -- Concatena o erro que veio
        vr_dscritic := 'Erro ao remover arquivo: ' || vr_dscritic;
        RAISE vr_exc_saida;
      END IF;
      
    END IF;
    
    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_xml);
    dbms_lob.freetemporary(vr_xml);
    
    -- retornar o nome do arquivo
    pr_nmarquiv := vr_nmarqimp;
  EXCEPTION
    WHEN vr_exc_saida THEN
      raise_application_error(-20013, vr_dscritic );
    WHEN OTHERS THEN
      raise_application_error(-20003,'Erro pc_relatorio_manual: '||SQLERRM );
  END pc_relatorio_manual;

  -- BUSCAR OS DADOS DO ASSOCIADO E OS EMPRESTIMOS DO MESMO
  PROCEDURE pc_busca_dados_ass_epr(pr_cdcooper IN NUMBER                --> Código da cooperativa para buscar os dados
                                  ,pr_nrdconta IN NUMBER                --> Numero da Conta para buscar os dados
                                  ,pr_cddopcao IN VARCHAR2              --> Opção selecionada na tela
                                  ,pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                  ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                                  ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2) IS         --> Saida OK/NOK
                                  
    /* .............................................................................
    Programa: pc_busca_dados_ass_epr
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Renato Darosci/SUPERO
    Data    : Junho/2016                       Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para buscar o Nome do cooperado e os contratos de empréstimo 
                que possuam imóveis atrelados.

    Alteracoes:
    ............................................................................. */

    -- Buscar dados do associado
    CURSOR cr_crapass  IS
      SELECT t.nmprimtl
        FROM crapass    t
       WHERE t.cdcooper = pr_cdcooper
         AND t.nrdconta = pr_nrdconta;
    rw_crapass     cr_crapass%ROWTYPE;
    
    -- Buscar todos os empréstimos não efetivados que tentam um bem do tipo Apartamento ou Casa alienado
    CURSOR cr_crapepr_opcao  IS
      SELECT epr.nrctremp
        FROM craplcr lcr
           , crawepr epr
       WHERE lcr.cdcooper = epr.cdcooper
         AND lcr.cdlcremp = epr.cdlcremp
         AND lcr.tpctrato = 3 -- Contratos de imóveis
         AND epr.cdcooper = pr_cdcooper
         AND epr.nrdconta = pr_nrdconta
         AND EXISTS (SELECT 1
                       FROM crapbpr bpr
                      WHERE bpr.cdcooper = epr.cdcooper
                        AND bpr.nrdconta = epr.nrdconta
                        AND bpr.nrctrpro = epr.nrctremp
                        AND bpr.tpctrpro = 90
                        AND bpr.flgalien = 1
                        AND bpr.dscatbem IN ('APARTAMENTO','CASA') );
    
    -- Buscar todos os empréstimos não efetivados que tentam um bem do tipo Apartamento ou Casa alienado
    CURSOR cr_crapepr_opcaoAeN  IS
      SELECT epr.nrctremp
        FROM craplcr lcr
           , crawepr epr
       WHERE lcr.cdcooper = epr.cdcooper
         AND lcr.cdlcremp = epr.cdlcremp
         AND lcr.tpctrato = 3 -- Contratos de imóveis
         AND epr.cdcooper = pr_cdcooper
         AND epr.nrdconta = pr_nrdconta
         AND NOT EXISTS (SELECT 1 
                           FROM crapepr emp
                          WHERE emp.cdcooper = epr.cdcooper
                            AND emp.nrdconta = epr.nrdconta
                            AND emp.nrctremp = epr.nrctremp)
         AND EXISTS (SELECT 1
                       FROM crapbpr bpr
                      WHERE bpr.cdcooper = epr.cdcooper
                        AND bpr.nrdconta = epr.nrdconta
                        AND bpr.nrctrpro = epr.nrctremp
                        AND bpr.tpctrpro = 90
                        AND bpr.flgalien = 1
                        AND bpr.dscatbem IN ('APARTAMENTO','CASA') 
                        AND ((pr_cddopcao = 'A'
                              AND EXISTS (SELECT 1
                                            FROM cecred.tbepr_imovel_alienado imv 
                                           WHERE imv.cdcooper = bpr.cdcooper
                                             AND imv.nrdconta = bpr.nrdconta
                                             AND imv.nrctrpro = bpr.nrctrpro
                                             AND imv.idseqbem = bpr.idseqbem )) 
                          OR (pr_cddopcao = 'N'
                              AND NOT EXISTS (SELECT 1
                                                FROM cecred.tbepr_imovel_alienado imv 
                                               WHERE imv.cdcooper = bpr.cdcooper
                                                 AND imv.nrdconta = bpr.nrdconta
                                                 AND imv.nrctrpro = bpr.nrctrpro
                                                 AND imv.idseqbem = bpr.idseqbem ) )) );

    -- Buscar todos os empréstimos efetivados que possuam imóvel alienado
    CURSOR cr_crapepr_opcaoX  IS
      SELECT epr.nrctremp
        FROM craplcr lcr
           , crapepr epr -- Buscar apenas contratos efetivados
       WHERE lcr.cdcooper = epr.cdcooper
         AND lcr.cdlcremp = epr.cdlcremp
         AND lcr.tpctrato = 3 -- Contratos de imóveis
         AND epr.cdcooper = pr_cdcooper
         AND epr.nrdconta = pr_nrdconta
         AND EXISTS (SELECT 1
                       FROM crapbpr bpr
                      WHERE bpr.cdcooper = epr.cdcooper
                        AND bpr.nrdconta = epr.nrdconta
                        AND bpr.nrctrpro = epr.nrctremp
                        AND bpr.tpctrpro = 90
                        AND bpr.flgalien = 1
                        AND bpr.dscatbem IN ('APARTAMENTO','CASA') );

    -- Buscar os dados do 
    CURSOR cr_cddepart(pr_cdoperad crapope.cdoperad%TYPE) IS
      SELECT ope.cddepart
        FROM crapope ope
       WHERE ope.cdcooper = pr_cdcooper
         AND ope.cdoperad = pr_cdoperad;

    -- Variáveis
    vr_cddepart    CRAPOPE.cddepart%TYPE;
    vr_nmprimtl    VARCHAR2(200);
    
    vr_indice      NUMBER;
   
    -- Variaveis extraidas do xml pr_retxml
    vr_cdcooper NUMBER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_dscritic VARCHAR2(100);
  
    -- Variavel Tabela Temporaria
    vr_tab_dados   gene0007.typ_mult_array;       --> PL Table para armazenar dados para formar o XML
    vr_tab_tags    gene0007.typ_tab_tagxml;       --> PL Table para armazenar TAG's do XML

    --Controle de erro
    vr_exc_erro EXCEPTION;

  BEGIN

    pr_des_erro := 'NOK';
    
    -- extrair informações do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
    
    -- Se for opção X -> Deve validar o departamento
    IF pr_cddopcao = 'X' THEN
      OPEN  cr_cddepart(vr_cdoperad);
      FETCH cr_cddepart INTO vr_cddepart;
      -- Se não encontrar registro
      IF cr_cddepart%NOTFOUND THEN
        vr_cddepart := 0;
      END IF;
      -- Fechar o cursor
      CLOSE cr_cddepart;
      
      -- Se o departamento for diferente de 14 - Produtos
      IF vr_cddepart <> 14 THEN
        pr_cdcritic := 36; -- Operação não permitida
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
        RAISE vr_exc_erro;
      END IF;
    END IF;
    
    -- Criar cabecalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

    -- Se a conta foi informada
    IF NVL(pr_nrdconta,0) > 0 THEN
        
      -- Buscar pelo associado
      OPEN  cr_crapass;
      FETCH cr_crapass INTO rw_crapass;
        
      -- Se não encontrar o registro
      IF cr_crapass%NOTFOUND THEN
        -- Fechar o cursor antes de encerrar a execução
        CLOSE cr_crapass;
        
        -- Retornar a mensagem de erro nos parametros
        pr_cdcritic := 9;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
        
        RAISE vr_exc_erro;
      END IF;
        
      -- Fechar o cursor 
      CLOSE cr_crapass;
        
      -- Guarda o nome 
      vr_nmprimtl := rw_crapass.nmprimtl;
    ELSE
      -- Retornar a mensagem de erro nos parametros
      pr_cdcritic := 0;
      pr_dscritic := 'Conta/DV não foi informada'; 
      RAISE vr_exc_erro;
    END IF;
 
    -- Zerar o índice
    vr_indice := 0;

    -- Se for opção X
    IF pr_cddopcao = 'X' THEN
      -- Percorrer todas as propostas de empréstimo que possuam imóveis atreladas
      FOR rg_crapepr IN cr_crapepr_opcaoX LOOP
        -- Incrementa o índice
        vr_indice := vr_indice + 1;
      
        -- O nome será inserido em todos os nodos para facilitar a montagem do xml, mas na tela será lido apenas uma vez
        vr_tab_dados(vr_indice)('nmprimtl') := vr_nmprimtl;
        vr_tab_dados(vr_indice)('nrctremp') := rg_crapepr.nrctremp;
      END LOOP;
    -- Se for opção A ou N
    ELSIF pr_cddopcao IN ('A','N') THEN
      FOR rg_crapepr IN cr_crapepr_opcaoAeN LOOP
        -- Incrementa o índice
        vr_indice := vr_indice + 1;
      
        -- O nome será inserido em todos os nodos para facilitar a montagem do xml, mas na tela será lido apenas uma vez
        vr_tab_dados(vr_indice)('nmprimtl') := vr_nmprimtl;
        vr_tab_dados(vr_indice)('nrctremp') := rg_crapepr.nrctremp;
      END LOOP;
    ELSE
      FOR rg_crapepr IN cr_crapepr_opcao LOOP
        -- Incrementa o índice
        vr_indice := vr_indice + 1;
      
        -- O nome será inserido em todos os nodos para facilitar a montagem do xml, mas na tela será lido apenas uma vez
        vr_tab_dados(vr_indice)('nmprimtl') := vr_nmprimtl;
        vr_tab_dados(vr_indice)('nrctremp') := rg_crapepr.nrctremp;
      END LOOP;
    END IF;
    
    -- Se nenhum registro foi adicionado
    IF vr_indice = 0 THEN
      -- Incrementa o índice
      vr_indice := vr_indice + 1;
      
      -- adiciona o nome do cooperado sem adicionar contrato
      vr_tab_dados(vr_indice)('nmprimtl') := vr_nmprimtl;
      vr_tab_dados(vr_indice)('nrctremp') := 0;
    END IF;
    
    gene0007.pc_gera_tag('nmprimtl',vr_tab_tags);
    gene0007.pc_gera_tag('nrctremp',vr_tab_tags);

    -- Forma XML de retorno para casos de sucesso (listar dados)
    gene0007.pc_gera_xml(pr_tab_dados => vr_tab_dados
                        ,pr_tab_tag   => vr_tab_tags
                        ,pr_XMLType   => pr_retxml
                        ,pr_path_tag  => '/Root'
                        ,pr_tag_no    => 'retorno'
                        ,pr_des_erro  => pr_des_erro);
  
    -- Finaliza com status de sucesso
    pr_des_erro := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>Rotina com erros</Dados></Root>');

    WHEN OTHERS THEN
      pr_des_erro := 'Erro geral: ' || SQLERRM;
      pr_dscritic := pr_des_erro;
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>Rotina com erros</Dados></Root>');
  END pc_busca_dados_ass_epr;

  -- CONSULTAR AS CIDADES CONFORME O ESTADO INFORMADO
  PROCEDURE pc_busca_cidades_cetip(pr_cdestado IN VARCHAR2              --> Código do estado selecionado em tela
                                  ,pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                  ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                                  ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2) IS         --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_busca_cidades_cetip
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Renato Darosci/SUPERO
    Data    : Junho/2016                       Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para buscar a lista das cidades conforme o estado selecionado.

    Alteracoes:
    ............................................................................. */
    
    -- Variavel Tabela Temporaria
    vr_tab_dados   GENE0007.typ_mult_array;       --> PL Table para armazenar dados para formar o XML
    vr_tab_tags    GENE0007.typ_tab_tagxml;       --> PL Table para armazenar TAG's do XML
    vr_tab_crapmun CADA0003.typ_tab_crapmun;
       
    -- Variáveis
    vr_indice      NUMBER;
    vr_cdcritic    NUMBER;
    vr_dscritic    VARCHAR2(500);
    
    -- Controle de erro
    vr_exc_erro EXCEPTION;
    
  BEGIN
    
    pr_des_erro := 'NOK';
    
    -- Criar cabecalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    
    -- Zerar o indice
    vr_indice := 0;
    
    -- Buscar cidades fintrando pelo estado(UF)
    CADA0003.pc_busca_cidades(pr_idcidade    => NULL
                             ,pr_cdcidade    => NULL
                             ,pr_dscidade    => NULL
                             ,pr_cdestado    => pr_cdestado
                             ,pr_infiltro    => 1 -- CETIP
                             ,pr_intipnom    => 1 -- Sem acentuação
                             ,pr_tab_crapmun => vr_tab_crapmun
                             ,pr_cdcritic    => vr_cdcritic
                             ,pr_dscritic    => vr_dscritic);
    
    -- Verifica a ocorrencia de erros
    IF vr_dscritic IS NOT NULL THEN
      pr_des_erro := vr_dscritic;
      RAISE vr_exc_erro;
    END IF;
    
    FOR ind IN vr_tab_crapmun.FIRST()..vr_tab_crapmun.LAST() LOOP
      
      -- O nome será inserido em todos os nodos para facilitar a montagem do xml, mas na tela será lido apenas uma vez
      vr_tab_dados(ind)('cdcidade') := vr_tab_crapmun(ind).cdcidade;
      vr_tab_dados(ind)('dscidade') := vr_tab_crapmun(ind).dscidade;
    
    END LOOP;
      
    gene0007.pc_gera_tag('cdcidade',vr_tab_tags);
    gene0007.pc_gera_tag('dscidade',vr_tab_tags);

    -- Forma XML de retorno para casos de sucesso (listar dados)
    gene0007.pc_gera_xml(pr_tab_dados => vr_tab_dados
                        ,pr_tab_tag   => vr_tab_tags
                        ,pr_XMLType   => pr_retxml
                        ,pr_path_tag  => '/Root'
                        ,pr_tag_no    => 'cidade'
                        ,pr_des_erro  => pr_des_erro);
  
    -- Finaliza com status de sucesso
    pr_des_erro := 'OK';
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := pr_des_erro;
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>Rotina com erros</Dados></Root>');

    WHEN OTHERS THEN
      pr_des_erro := 'Erro geral: ' || SQLERRM;
      pr_dscritic := pr_des_erro;
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>Rotina com erros</Dados></Root>');
  END pc_busca_cidades_cetip;

  -- BUSCAR OS IMÓVEIS DO CONTRATO SELECIONADO NA TELA   
  PROCEDURE pc_busca_imoveis_contrato(pr_cdcooper IN NUMBER                --> Código da cooperativa para buscar os dados
                                     ,pr_nrdconta IN NUMBER                --> Número da conta
                                     ,pr_nrctremp IN NUMBER                --> Número do contrato
                                     ,pr_cddopcao IN VARCHAR2              --> Opção selecionada na tela
                                  	 ,pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                                     ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2) IS         --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_busca_imoveis_contrato
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Renato Darosci/SUPERO
    Data    : Junho/2016                       Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para buscar a lista dos imóveis do contrato selecionado.

    Alteracoes:
    ............................................................................. */
    
    -- Buscar todos os imóveis relacionados ao contrato e que estejam alienados a proposta
    CURSOR cr_crapbpr  IS
      SELECT bpr.idseqbem
           , bpr.idseqbem||' - '||bpr.dsbemfin dsbemfin
        FROM crapbpr bpr
       WHERE bpr.cdcooper = pr_cdcooper
         AND bpr.nrdconta = pr_nrdconta
         AND bpr.nrctrpro = pr_nrctremp
         AND bpr.dscatbem IN ('CASA','APARTAMENTO') -- Não deve retornar os demais bens
         AND bpr.tpctrpro = 90
         AND bpr.flgalien = 1
         AND -- OPÇÃO N - Não deve existir cadastro ainda 
            (  (pr_cddopcao = 'N' AND NOT EXISTS (SELECT 1
                                                    FROM tbepr_imovel_alienado imv
                                                   WHERE imv.cdcooper = bpr.cdcooper
                                                     AND imv.nrdconta = bpr.nrdconta
                                                     AND imv.nrctrpro = bpr.nrctrpro
                                                     AND imv.idseqbem = bpr.idseqbem))
             -- OPÇÃO A - Deve existir informação cadastrada
             OR (pr_cddopcao = 'A' AND EXISTS (SELECT 1
                                                 FROM tbepr_imovel_alienado imv
                                                WHERE imv.cdcooper = bpr.cdcooper
                                                  AND imv.nrdconta = bpr.nrdconta
                                                  AND imv.nrctrpro = bpr.nrctrpro
                                                  AND imv.idseqbem = bpr.idseqbem))
             -- Demais opções deve retornar todoss
             OR (pr_cddopcao NOT IN ('A','N'))
            )
       ORDER BY bpr.idseqbem;
       
    -- Variavel Tabela Temporaria
    vr_tab_dados   gene0007.typ_mult_array;       --> PL Table para armazenar dados para formar o XML
    vr_tab_tags    gene0007.typ_tab_tagxml;       --> PL Table para armazenar TAG's do XML
       
    -- Variáveis
    vr_indice      NUMBER;
    
    -- Controle de erro
    vr_exc_erro EXCEPTION;
    
  BEGIN
    
    pr_des_erro := 'NOK';
    
    -- Criar cabecalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    
    -- Zerar o indice
    vr_indice := 0;
    
    -- Percorrer 
    FOR rg_crapbpr IN cr_crapbpr LOOP
      -- Incrementa o índice
      vr_indice := vr_indice + 1;
    
      -- O nome será inserido em todos os nodos para facilitar a montagem do xml, mas na tela será lido apenas uma vez
      vr_tab_dados(vr_indice)('idseqbem') := rg_crapbpr.idseqbem;
      vr_tab_dados(vr_indice)('dsbemfin') := rg_crapbpr.dsbemfin;
    
    END LOOP;
  
    gene0007.pc_gera_tag('idseqbem',vr_tab_tags);
    gene0007.pc_gera_tag('dsbemfin',vr_tab_tags);

    -- Forma XML de retorno para casos de sucesso (listar dados)
    gene0007.pc_gera_xml(pr_tab_dados => vr_tab_dados
                        ,pr_tab_tag   => vr_tab_tags
                        ,pr_XMLType   => pr_retxml
                        ,pr_path_tag  => '/Root'
                        ,pr_tag_no    => 'imovel'
                        ,pr_des_erro  => pr_des_erro);
  
    -- Finaliza com status de sucesso
    pr_des_erro := 'OK';
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := pr_des_erro;
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>Rotina com erros</Dados></Root>');

    WHEN OTHERS THEN
      pr_des_erro := 'Erro geral: ' || SQLERRM;
      pr_dscritic := pr_des_erro;
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>Rotina com erros</Dados></Root>');
  END pc_busca_imoveis_contrato;


  -- BUSCAR OS DADOS DO IMÓVEL SELECIONADO NA TELA
  PROCEDURE pc_busca_dados_imovel(pr_cdcooper IN NUMBER                --> Código da cooperativa para buscar os dados
                                 ,pr_nrdconta IN NUMBER                --> Número da conta
                                 ,pr_nrctremp IN NUMBER                --> Número do contrato
                                 ,pr_idseqbem IN NUMBER                --> Indica a sequencia do bem
                                 ,pr_cddopcao IN VARCHAR2              --> Opção selecionada na tela
                                 ,pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                 ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                                 ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2) IS         --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_busca_dados_imovel
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Renato Darosci/SUPERO
    Data    : Junho/2016                       Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para buscar os dados do imóvel selecionado na tela.

    Alteracoes:
    ............................................................................. */
    
    -- Buscar todos os imóveis relacionados ao contrato
    CURSOR cr_imovel_alienado  IS
      SELECT imv.cdsituacao                       cdsituac
           , imv.tpinclusao                       tpinclus
           , imv.tpbaixa                          tpdbaixa
           , imv.nrmatric_cartorio                nrmatcar
           , imv.nrcns_cartorio                   nrcnscar
           , imv.nrreg_garantia                   nrreggar
           , TO_CHAR(imv.dtreg_garantia,'DD/MM/YYYY')  dtreggar
           , imv.nrgrau_garantia                  nrgragar
           , imv.tplogradouro                     tplograd
           , imv.dslogradouro                     dslograd
           , GENE0002.fn_mask(imv.nrlogradouro,'zzz.zz9') nrlograd
           , imv.dscomplemento                    dscmplgr
           , imv.dsbairro
           , mun.cdcidade
           , mun.cdestado
           , GENE0002.fn_mask(imv.nrcep,'zzzzz-zz9') nrceplgr
           , TO_CHAR(imv.dtavaliacao,'DD/MM/YYYY')   dtavlimv
           , TO_CHAR(imv.vlavaliado,'FM9G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.') vlavlimv
           , TO_CHAR(imv.dtcompra,'DD/MM/YYYY')   dtcprimv
           , TO_CHAR(imv.vlcompra,'FM9G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.')   vlcprimv
           , imv.tpimplantacao                    tpimpimv
           , imv.indconservacao                   incsvimv
           , imv.indpadrao_acab                   inpdracb
           , TO_CHAR(imv.vlarea_total,'FM999G990D00','NLS_NUMERIC_CHARACTERS=,.')     vlmtrtot
           , TO_CHAR(imv.vlarea_privada,'FM999G990D00','NLS_NUMERIC_CHARACTERS=,.')   vlmtrpri
           , imv.qtddormitorio                    qtdormit
           , imv.qtdvagas                         qtdvagas
           , TO_CHAR(imv.vlarea_terreno,'FM999G990D00','NLS_NUMERIC_CHARACTERS=,.')   vlmtrter
           , TO_CHAR(imv.vltamanho_frente,'FM999G990D00','NLS_NUMERIC_CHARACTERS=,.') vlmtrtes
           , imv.indconserv_condom                incsvcon
           , imv.indpessoa_vendedor               inpesvdr
           , NVL2(imv.nrdoc_vendedor,GENE0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => imv.nrdoc_vendedor
                                                              ,pr_inpessoa => decode(MOD(imv.indpessoa_vendedor ,2)
                                                                                           , 0, 2, 1)), NULL) nrdocvdr
           , imv.nmvendor
           , imv.nrreg_cetip                      nrreginc
           , TO_CHAR(imv.dtinclusao,'DD/MM/YYYY') dtinclus  
           , imv.dsjustific_inclus                dsjstinc
           , TO_CHAR(imv.dtbaixa,'DD/MM/YYYY')    dtdbaixa  
           , imv.dsjustific_baixa                 dsjstbxa
        FROM crapmun               mun
           , tbepr_imovel_alienado imv
       WHERE mun.cdcidade = imv.cdcidade
         AND imv.cdcooper = pr_cdcooper
         AND imv.nrdconta = pr_nrdconta
         AND imv.nrctrpro = pr_nrctremp
         AND imv.idseqbem = pr_idseqbem;
    rw_imovel_alienado      cr_imovel_alienado%ROWTYPE;
    
    -- Buscar o tipo do imóvel
    CURSOR cr_crapbpr_epr IS
      SELECT DECODE(bpr.dscatbem, 'CASA',1,'APARTAMENTO',2, 0) tpimovel
           , NVL(epr.inliquid,0)  inliquid
           , epr.nrctremp  -- Número do contrato para indicar que não foi efetivado
        FROM crapepr  epr
           , crapbpr  bpr
       WHERE epr.NRCTREMP(+) = bpr.nrctrpro
         AND epr.NRDCONTA(+) = bpr.nrdconta
         AND epr.CDCOOPER(+) = bpr.cdcooper
         AND bpr.cdcooper    = pr_cdcooper
         AND bpr.nrdconta    = pr_nrdconta
         AND bpr.nrctrpro    = pr_nrctremp
         AND bpr.tpctrpro    = 90
         AND bpr.idseqbem    = pr_idseqbem
         AND bpr.flgalien    = 1;
    
    -- Buscar a critica quando situação for 3
    CURSOR cr_critica IS
      SELECT env.cdretorno||' - '||rto.dsretorn 
        FROM craprto             rto
           , tbepr_envio_cetip   env
       WHERE rto.cdretorn = env.cdretorno
         AND rto.nrtabela = 1 -- Será tabela fixa
         AND rto.cdoperac = 'I' -- Produto 3 será tratado como I fixo
         AND rto.cdprodut = 3 -- CETIP
         AND env.idseqbem = pr_idseqbem
         AND env.nrctrpro = pr_nrctremp
         AND env.nrdconta = pr_nrdconta
         AND env.cdcooper = pr_cdcooper
       ORDER BY env.dtretorno DESC;
    
    -- Variavel Tabela Temporaria
    vr_tab_dados   gene0007.typ_mult_array;       --> PL Table para armazenar dados para formar o XML
    vr_tab_tags    gene0007.typ_tab_tagxml;       --> PL Table para armazenar TAG's do XML
       
    -- Variáveis
    vr_indice      NUMBER;
    vr_tpimovel    NUMBER;
    vr_inliquid    crapepr.inliquid%TYPE;
    vr_nrctremp    crapepr.nrctremp%TYPE;
    
    -- Controle de erro
    vr_exc_erro EXCEPTION;
    
  BEGIN
    
    pr_des_erro := 'NOK';
    
    -- Criar cabecalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    
    -- Será apenas um registro
    vr_indice := 1;

    -- Buscar o tipo do imóvel e dados do emprestimo
    OPEN  cr_crapbpr_epr;
    FETCH cr_crapbpr_epr INTO vr_tpimovel
                            , vr_inliquid
                            , vr_nrctremp;
    CLOSE cr_crapbpr_epr;

    -- Verificar a situação conforme opção selecionada em tela
    IF pr_cddopcao IN ('A','N','M') THEN  
      -- Se o contrato não estiver nulo indica que Proposta já foi efetivada
      IF vr_nrctremp IS NOT NULL THEN
        pr_des_erro := GENE0007.fn_caract_acento('Proposta já efetivada! Não é possível efetuar alterações.');
        RAISE vr_exc_erro;
      -- Verifica se o bem está com crítica ou se já foi alienado
      ELSIF rw_imovel_alienado.cdsituac = 1 THEN -- Enviado
         pr_des_erro := GENE0007.fn_caract_acento('Contrato sendo processado via arquivo. Verifique!');
         RAISE vr_exc_erro;
      ELSIF rw_imovel_alienado.cdsituac = 2 THEN -- Alienado
         pr_des_erro := GENE0007.fn_caract_acento('Alienação já informada à Cetip! Para alterações utilize a opção X.');
         RAISE vr_exc_erro;
      ELSIF rw_imovel_alienado.cdsituac = 4 THEN -- Baixado
          
         -- SE FOR OPÇÃO M... deve verificar a situação do contrato, pois SE AINDA NÃO FOI 
         -- LIQUIDADO, deve permitir que o registro seja incluído novamente (recurso para baixas indevidas)
         IF  pr_cddopcao = 'M' THEN
           IF vr_inliquid <> 0 THEN
             pr_des_erro := GENE0007.fn_caract_acento('Contrato já liquidado, inclusão não permitida!');
             RAISE vr_exc_erro;
           END IF;
         ELSE
           pr_des_erro := GENE0007.fn_caract_acento('Baixa já informada à Cetip!');
           RAISE vr_exc_erro;
         END IF;
           
      END IF;
        
    ELSIF pr_cddopcao = 'B' THEN
      -- Verifica situação do Bem
      IF rw_imovel_alienado.cdsituac NOT IN (2,5) THEN -- Diferente de Registrado ou baixa com crítica
         pr_des_erro := GENE0007.fn_caract_acento('Situação do Bem inválida! Alienação não OK!');
         RAISE vr_exc_erro;
      END IF;
    ELSIF pr_cddopcao = 'X' THEN  
      -- Se o contrato estiver nulo indica que Proposta ainda não foi efetivada
      IF vr_nrctremp IS NULL THEN
        pr_des_erro := GENE0007.fn_caract_acento('Proposta não efetivada, não é possível efetuar alterações!');
        RAISE vr_exc_erro;
      END IF;
      /*
      -- Verifica situação do Bem
      IF rw_imovel_alienado.cdsituac <> 2 THEN -- Diferente de Registrado
         pr_des_erro := GENE0007.fn_caract_acento('Situação do Bem inválida! Alienação não OK!');
         RAISE vr_exc_erro;
      END IF;*/
    END IF;


    -- Buscar os dados do imóvel
    OPEN  cr_imovel_alienado;
    FETCH cr_imovel_alienado INTO rw_imovel_alienado;
    
    -- Se já há cadastro
    IF cr_imovel_alienado%FOUND THEN
    
      -- O nome será inserido em todos os nodos para facilitar a montagem do xml, mas na tela será lido apenas uma vez
      vr_tab_dados(vr_indice)('cdsituac') := rw_imovel_alienado.cdsituac;
      vr_tab_dados(vr_indice)('tpinclus') := rw_imovel_alienado.tpinclus;
      vr_tab_dados(vr_indice)('tpdbaixa') := rw_imovel_alienado.tpdbaixa;
      vr_tab_dados(vr_indice)('nrmatcar') := rw_imovel_alienado.nrmatcar;
      vr_tab_dados(vr_indice)('nrcnscar') := rw_imovel_alienado.nrcnscar;
      vr_tab_dados(vr_indice)('tpimovel') := vr_tpimovel;
      vr_tab_dados(vr_indice)('nrreggar') := rw_imovel_alienado.nrreggar;
      vr_tab_dados(vr_indice)('dtreggar') := rw_imovel_alienado.dtreggar;
      vr_tab_dados(vr_indice)('nrgragar') := rw_imovel_alienado.nrgragar;
      vr_tab_dados(vr_indice)('nrceplgr') := rw_imovel_alienado.nrceplgr;
      vr_tab_dados(vr_indice)('tplograd') := rw_imovel_alienado.tplograd;
      vr_tab_dados(vr_indice)('dslograd') := rw_imovel_alienado.dslograd;
      vr_tab_dados(vr_indice)('nrlograd') := rw_imovel_alienado.nrlograd;
      vr_tab_dados(vr_indice)('dscmplgr') := rw_imovel_alienado.dscmplgr;
      vr_tab_dados(vr_indice)('dsbairro') := rw_imovel_alienado.dsbairro;
      vr_tab_dados(vr_indice)('cdcidade') := rw_imovel_alienado.cdcidade;
      vr_tab_dados(vr_indice)('cdestado') := rw_imovel_alienado.cdestado;
      vr_tab_dados(vr_indice)('dtavlimv') := rw_imovel_alienado.dtavlimv;
      vr_tab_dados(vr_indice)('vlavlimv') := rw_imovel_alienado.vlavlimv;
      vr_tab_dados(vr_indice)('dtcprimv') := rw_imovel_alienado.dtcprimv;
      vr_tab_dados(vr_indice)('vlcprimv') := rw_imovel_alienado.vlcprimv;
      vr_tab_dados(vr_indice)('tpimpimv') := rw_imovel_alienado.tpimpimv;
      vr_tab_dados(vr_indice)('incsvimv') := rw_imovel_alienado.incsvimv;
      vr_tab_dados(vr_indice)('inpdracb') := rw_imovel_alienado.inpdracb;
      vr_tab_dados(vr_indice)('vlmtrtot') := rw_imovel_alienado.vlmtrtot;
      vr_tab_dados(vr_indice)('vlmtrpri') := rw_imovel_alienado.vlmtrpri;
      vr_tab_dados(vr_indice)('qtdormit') := rw_imovel_alienado.qtdormit;
      vr_tab_dados(vr_indice)('qtdvagas') := rw_imovel_alienado.qtdvagas;
      vr_tab_dados(vr_indice)('vlmtrter') := rw_imovel_alienado.vlmtrter;
      vr_tab_dados(vr_indice)('vlmtrtes') := rw_imovel_alienado.vlmtrtes;
      vr_tab_dados(vr_indice)('incsvcon') := rw_imovel_alienado.incsvcon;
      vr_tab_dados(vr_indice)('inpesvdr') := rw_imovel_alienado.inpesvdr;
      vr_tab_dados(vr_indice)('nrdocvdr') := rw_imovel_alienado.nrdocvdr;
      vr_tab_dados(vr_indice)('nmvendor') := rw_imovel_alienado.nmvendor;
      vr_tab_dados(vr_indice)('nrreginc') := rw_imovel_alienado.nrreginc;
      vr_tab_dados(vr_indice)('dtinclus') := rw_imovel_alienado.dtinclus;
      vr_tab_dados(vr_indice)('dsjstinc') := rw_imovel_alienado.dsjstinc;    
      vr_tab_dados(vr_indice)('dtdbaixa') := rw_imovel_alienado.dtdbaixa;
      vr_tab_dados(vr_indice)('dsjstbxa') := rw_imovel_alienado.dsjstbxa;
      vr_tab_dados(vr_indice)('dscritic') := NULL;
    
    ELSE
      
      -- Retornar todos os valores como NULL
      vr_tab_dados(vr_indice)('cdsituac') := 0;  -- Não enviado
      vr_tab_dados(vr_indice)('tpinclus') := '';
      vr_tab_dados(vr_indice)('tpdbaixa') := '';
      vr_tab_dados(vr_indice)('nrmatcar') := '';
      vr_tab_dados(vr_indice)('nrcnscar') := '';
      vr_tab_dados(vr_indice)('tpimovel') := vr_tpimovel;
      vr_tab_dados(vr_indice)('nrreggar') := '';
      vr_tab_dados(vr_indice)('dtreggar') := '';
      vr_tab_dados(vr_indice)('nrgragar') := '';
      vr_tab_dados(vr_indice)('nrceplgr') := '';
      vr_tab_dados(vr_indice)('tplograd') := '';
      vr_tab_dados(vr_indice)('dslograd') := '';
      vr_tab_dados(vr_indice)('nrlograd') := '';
      vr_tab_dados(vr_indice)('dscmplgr') := '';
      vr_tab_dados(vr_indice)('dsbairro') := '';
      vr_tab_dados(vr_indice)('cdcidade') := '';
      vr_tab_dados(vr_indice)('cdestado') := '';
      vr_tab_dados(vr_indice)('dtavlimv') := '';
      vr_tab_dados(vr_indice)('vlavlimv') := '';
      vr_tab_dados(vr_indice)('dtcprimv') := '';
      vr_tab_dados(vr_indice)('vlcprimv') := '';
      vr_tab_dados(vr_indice)('tpimpimv') := '';
      vr_tab_dados(vr_indice)('incsvimv') := '';
      vr_tab_dados(vr_indice)('inpdracb') := '';
      vr_tab_dados(vr_indice)('vlmtrtot') := '';
      vr_tab_dados(vr_indice)('vlmtrpri') := '';
      vr_tab_dados(vr_indice)('qtdormit') := '';
      vr_tab_dados(vr_indice)('qtdvagas') := '';
      vr_tab_dados(vr_indice)('vlmtrter') := '';
      vr_tab_dados(vr_indice)('vlmtrtes') := '';
      vr_tab_dados(vr_indice)('incsvcon') := '';
      vr_tab_dados(vr_indice)('inpesvdr') := '';
      vr_tab_dados(vr_indice)('nrdocvdr') := '';
      vr_tab_dados(vr_indice)('nmvendor') := '';
      vr_tab_dados(vr_indice)('nrreginc') := '';
      vr_tab_dados(vr_indice)('dtinclus') := '';
      vr_tab_dados(vr_indice)('dsjstinc') := '';
      vr_tab_dados(vr_indice)('dtdbaixa') := '';
      vr_tab_dados(vr_indice)('dsjstbxa') := '';
      vr_tab_dados(vr_indice)('dscritic') := '';
    
    END IF;
      
    -- Fechar os dados do cursor
    CLOSE cr_imovel_alienado;
    
    -- Se o código da situação for 3 - Processado com crítica ou 5 - Baixa com Critica deve buscar a crítica 
    IF rw_imovel_alienado.cdsituac IN (3,5) THEN
      vr_tab_dados(vr_indice)('dscritic') := NULL;  
      
      -- BUSCAR A CRÍTICA 
      OPEN  cr_critica;
      FETCH cr_critica INTO vr_tab_dados(vr_indice)('dscritic');
      CLOSE cr_critica;
      
    END IF;
    
    -- Criar as tags
    gene0007.pc_gera_tag('cdsituac',vr_tab_tags);
    gene0007.pc_gera_tag('tpinclus',vr_tab_tags);
    gene0007.pc_gera_tag('tpdbaixa',vr_tab_tags);
    gene0007.pc_gera_tag('nrmatcar',vr_tab_tags);
    gene0007.pc_gera_tag('nrcnscar',vr_tab_tags);
    gene0007.pc_gera_tag('tpimovel',vr_tab_tags);
    gene0007.pc_gera_tag('nrreggar',vr_tab_tags);
    gene0007.pc_gera_tag('dtreggar',vr_tab_tags);
    gene0007.pc_gera_tag('nrgragar',vr_tab_tags);
    gene0007.pc_gera_tag('nrceplgr',vr_tab_tags);
    gene0007.pc_gera_tag('tplograd',vr_tab_tags);
    gene0007.pc_gera_tag('dslograd',vr_tab_tags);
    gene0007.pc_gera_tag('nrlograd',vr_tab_tags);
    gene0007.pc_gera_tag('dscmplgr',vr_tab_tags);
    gene0007.pc_gera_tag('dsbairro',vr_tab_tags);
    gene0007.pc_gera_tag('cdcidade',vr_tab_tags);
    gene0007.pc_gera_tag('cdestado',vr_tab_tags);
    gene0007.pc_gera_tag('dtavlimv',vr_tab_tags);
    gene0007.pc_gera_tag('vlavlimv',vr_tab_tags);
    gene0007.pc_gera_tag('dtcprimv',vr_tab_tags);
    gene0007.pc_gera_tag('vlcprimv',vr_tab_tags);
    gene0007.pc_gera_tag('tpimpimv',vr_tab_tags);
    gene0007.pc_gera_tag('incsvimv',vr_tab_tags);
    gene0007.pc_gera_tag('inpdracb',vr_tab_tags);
    gene0007.pc_gera_tag('vlmtrtot',vr_tab_tags);
    gene0007.pc_gera_tag('vlmtrpri',vr_tab_tags);
    gene0007.pc_gera_tag('qtdormit',vr_tab_tags);
    gene0007.pc_gera_tag('qtdvagas',vr_tab_tags);
    gene0007.pc_gera_tag('vlmtrter',vr_tab_tags);
    gene0007.pc_gera_tag('vlmtrtes',vr_tab_tags);
    gene0007.pc_gera_tag('incsvcon',vr_tab_tags);
    gene0007.pc_gera_tag('inpesvdr',vr_tab_tags);
    gene0007.pc_gera_tag('nrdocvdr',vr_tab_tags);
    gene0007.pc_gera_tag('nmvendor',vr_tab_tags);
    gene0007.pc_gera_tag('nrreginc',vr_tab_tags);
    gene0007.pc_gera_tag('dtinclus',vr_tab_tags);
    gene0007.pc_gera_tag('dsjstinc',vr_tab_tags);
    gene0007.pc_gera_tag('dtdbaixa',vr_tab_tags);
    gene0007.pc_gera_tag('dsjstbxa',vr_tab_tags);
    gene0007.pc_gera_tag('dscritic',vr_tab_tags);
    
    -- Forma XML de retorno para casos de sucesso (listar dados)
    gene0007.pc_gera_xml(pr_tab_dados => vr_tab_dados
                        ,pr_tab_tag   => vr_tab_tags
                        ,pr_XMLType   => pr_retxml
                        ,pr_path_tag  => '/Root'
                        ,pr_tag_no    => 'imovel'
                        ,pr_des_erro  => pr_des_erro);
  
    -- Finaliza com status de sucesso
    pr_des_erro := 'OK';
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := pr_des_erro;
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>Rotina com erros</Dados></Root>');

    WHEN OTHERS THEN
      pr_des_erro := 'Erro geral: ' || SQLERRM;
      pr_dscritic := pr_des_erro;
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>Rotina com erros</Dados></Root>');
  END pc_busca_dados_imovel;
  
  
  -- GRAVAR OS DADOS DO IMÓVEL INSERIDOS NA TELA
  PROCEDURE pc_grava_dados_imovel(pr_cdcooper   IN NUMBER           -- Código da cooperativa
                                 ,pr_nrdconta   IN NUMBER           -- Número da conta
                                 ,pr_nrctremp   IN NUMBER           -- Número do contrato de empréstimo
                                 ,pr_idseqbem   IN NUMBER           -- Código de sequencia do bem
                                 ,pr_cdoperad   IN VARCHAR2         -- Código do cooperado
                                 ,pr_nrmatcar   IN NUMBER           -- Número da matrícula no cartório
                                 ,pr_nrcnscar   IN NUMBER           -- Código CNS do cartório
                                 ,pr_tpimovel   IN NUMBER           -- Tipo do Imóvel (DSCATBEM)
                                 ,pr_nrreggar   IN VARCHAR2         -- Número da garantia do imóvel
                                 ,pr_dtreggar   IN VARCHAR2         -- Data da garantia do imóvel (DD/MM/YYYY)
                                 ,pr_nrgragar   IN VARCHAR2         -- Indica o grau da garantia
                                 ,pr_nrceplgr   IN VARCHAR2         -- Número do CEP
                                 ,pr_tplograd   IN NUMBER           -- Tipo do logradouro 
                                 ,pr_dslograd   IN VARCHAR2         -- Descrição do Endereço do imóvel
                                 ,pr_nrlograd   IN VARCHAR2         -- Número do imóvel
                                 ,pr_dscmplgr   IN VARCHAR2         -- Complemento do endereço do imóvel
                                 ,pr_dsbairro   IN VARCHAR2         -- Bairro do imóvel
                                 ,pr_cdcidade   IN NUMBER           -- Código da cidade  (já referencia a UF)
                                 ,pr_dtavlimv   IN VARCHAR2         -- Data de avaliação do imóvel (DD/MM/YYYY)
                                 ,pr_vlavlimv   IN VARCHAR2         -- Valor de avaliação do imóvel
                                 ,pr_dtcprimv   IN VARCHAR2         -- Data de compra do imóvel (DD/MM/YYYY)
                                 ,pr_vlcprimv   IN VARCHAR2         -- Valor de compra do imóvel
                                 ,pr_tpimpimv   IN NUMBER           -- Tipo de implantação do imóvel
                                 ,pr_incsvimv   IN NUMBER           -- Estado de conservação do imóvel
                                 ,pr_inpdracb   IN NUMBER           -- Nível do padrão de acabamento
                                 ,pr_vlmtrtot   IN VARCHAR2         -- Área total do imóvel em metros quadrados
                                 ,pr_vlmtrpri   IN VARCHAR2         -- Área de uso privativo do imóvel em metros quadrados
                                 ,pr_qtdormit   IN NUMBER           -- Quantidade de dormitórios
                                 ,pr_qtdvagas   IN NUMBER           -- Quantidades de vagas de garagem
                                 ,pr_vlmtrter   IN VARCHAR2         -- Área em metros quadrados do terreno
                                 ,pr_vlmtrtes   IN VARCHAR2         -- Metragem da frente do imóvel
                                 ,pr_incsvcon   IN NUMBER           -- Indicador de conservação do condomínio
                                 ,pr_inpesvdr   IN NUMBER           -- Tipo de pessoa do vendedor do imóvel
                                 ,pr_nrdocvdr   IN VARCHAR2         -- Número do documento do vendedor
                                 ,pr_nmvendor   IN VARCHAR2         -- Nome do vendedor
                                 ,pr_nrreginc   IN NUMBER           -- INCLUSÃO MANUAL: Número do Registro da CETIP
                                 ,pr_dtinclus   IN VARCHAR2         -- INCLUSÃO MANUAL: Data da inclusão manual
                                 ,pr_dsjstinc   IN VARCHAR2         -- INCLUSÃO MANUAL: Justificativa para inclusão manual
                                 ,pr_xmllog    IN VARCHAR2           --> XML com informacoes de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER       --> Codigo da critica
                                 ,pr_dscritic OUT VARCHAR2          --> Descricao da critica
                                 ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2) IS      --> Saida OK/NOK
    
    /* .............................................................................
    Programa: pc_gravar_dados_imovel
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Renato Darosci/SUPERO
    Data    : Junho/2016                       Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para gravar os dados do imóvel informados na tela.

    Alteracoes:
    ............................................................................. */
    
    -- Controle de erro
    vr_exc_erro EXCEPTION;
    
    -- VARIÁVEIS
    rw_imovel_alienado cr_tbepr_imovel_alienado%ROWTYPE;
    vr_tpinclus        tbepr_imovel_alienado.tpinclusao%TYPE := NULL;
    vr_cdsituac        tbepr_imovel_alienado.cdsituacao%TYPE := NULL;
    vr_flgregis        BOOLEAN := FALSE;
    vr_dstransa        craplgm.dstransa%TYPE;
    vr_flgenvia        tbepr_imovel_alienado.flgenvia%TYPE;
    
  BEGIN
  
    pr_des_erro := 'NOK';
    
    -- Criar cabecalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    
    OPEN  cr_tbepr_imovel_alienado(pr_cdcooper, pr_nrdconta, pr_nrctremp, pr_idseqbem);
    FETCH cr_tbepr_imovel_alienado INTO rw_imovel_alienado;
    -- Verifica se encontrou registro
    IF cr_tbepr_imovel_alienado%FOUND THEN
      -- Indica que foi encontrado o registro
      vr_flgregis := TRUE;
    END IF;
    CLOSE cr_tbepr_imovel_alienado;

    -- inicializa
    vr_cdsituac := NULL;
         
    -- Verificar se foram informados dados da inclusão, caracterizando inclusão MANUAL
    IF trim(pr_nrreginc) IS NOT NULL THEN
      vr_tpinclus := 'M'; -- Indicar inclusão manual
      vr_cdsituac := 2;   -- Situação será Registrado
      vr_flgenvia := 0;   -- Não envia a CETIP
      vr_dstransa := 'Registro de inclusao manual.';
    ELSE
      -- Se o registro já existia 
      IF vr_flgregis THEN
        vr_dstransa := 'Atualizacao dos dados do imovel.';
      ELSE
        vr_dstransa := 'Inclusao dos dados do imovel.';
      END IF;
      
      vr_flgenvia := 1; -- Realiza o envio para a Cetip
    END IF;
    
    -- Se o registro foi encontrado
    IF vr_flgregis THEN
    ---- 
      -- Atualiza o registro
      BEGIN
        UPDATE tbepr_imovel_alienado
           SET dtmvtolt            = trunc(SYSDATE)
             , cdoperad            = pr_cdoperad
             , flgenvia            = vr_flgenvia -- Indica se o registro deve ou não ser enviado a Cetip
             , cdsituacao          = NVL(vr_cdsituac,cdsituacao)
             , nrmatric_cartorio   = pr_nrmatcar
             , nrcns_cartorio      = pr_nrcnscar
             , nrreg_garantia      = pr_nrreggar
             , dtreg_garantia      = to_date(pr_dtreggar, 'DD/MM/YYYY')
             , nrgrau_garantia     = pr_nrgragar
             , tplogradouro        = pr_tplograd
             , dslogradouro        = UPPER(pr_dslograd)
             , nrlogradouro        = pr_nrlograd
             , dscomplemento       = UPPER(pr_dscmplgr)
             , dsbairro            = UPPER(pr_dsbairro)
             , cdcidade            = pr_cdcidade
             , nrcep               = pr_nrceplgr
             , dtavaliacao         = to_date(pr_dtavlimv, 'DD/MM/YYYY')
             , vlavaliado          = gene0002.fn_char_para_number(pr_vlavlimv)
             , dtcompra            = to_date(pr_dtcprimv, 'DD/MM/YYYY')
             , vlcompra            = gene0002.fn_char_para_number(pr_vlcprimv)
             , tpimplantacao       = pr_tpimpimv
             , indconservacao      = pr_incsvimv
             , indpadrao_acab      = pr_inpdracb
             , vlarea_total        = gene0002.fn_char_para_number(pr_vlmtrtot)
             , vlarea_privada      = gene0002.fn_char_para_number(pr_vlmtrpri)
             , qtddormitorio       = pr_qtdormit
             , qtdvagas            = pr_qtdvagas
             , vlarea_terreno      = gene0002.fn_char_para_number(pr_vlmtrter)
             , vltamanho_frente    = gene0002.fn_char_para_number(pr_vlmtrtes)
             , indconserv_condom   = pr_incsvcon
             , indpessoa_vendedor  = pr_inpesvdr
             , nrdoc_vendedor      = pr_nrdocvdr
             , nmvendor            = UPPER(pr_nmvendor)
             -- se não receber um valor, permanece os da tabela
             , nrreg_cetip         = NVL(pr_nrreginc, nrreg_cetip)
             , dtinclusao          = NVL(to_date(pr_dtinclus, 'DD/MM/YYYY'), dtinclusao)
             , tpinclusao          = NVL(vr_tpinclus, tpinclusao)
             , dsjustific_inclus   = NVL(pr_dsjstinc, dsjustific_inclus)
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctrpro = pr_nrctremp
           AND idseqbem = pr_idseqbem;
      EXCEPTION 
        WHEN OTHERS THEN
          pr_des_erro := 'Erro ao atualizar dados: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
    ---- 
    ELSE
    ----    
      -- Realizar a gravação dos dados na tabela
      BEGIN
        -- Efetua o insert, mas em caso de estouro da chave, faz o  update
        INSERT INTO tbepr_imovel_alienado
          (cdcooper
          ,nrdconta
          ,nrctrpro
          ,idseqbem
          ,dtmvtolt
          ,cdoperad
          ,flgenvia
          ,cdsituacao 
          ,nrmatric_cartorio 
          ,nrcns_cartorio 
          ,nrreg_garantia 
          ,dtreg_garantia 
          ,nrgrau_garantia 
          ,tplogradouro 
          ,dslogradouro 
          ,nrlogradouro 
          ,dscomplemento 
          ,dsbairro
          ,cdcidade
          ,nrcep 
          ,dtavaliacao 
          ,vlavaliado 
          ,dtcompra 
          ,vlcompra 
          ,tpimplantacao 
          ,indconservacao 
          ,indpadrao_acab 
          ,vlarea_total 
          ,vlarea_privada 
          ,qtddormitorio 
          ,qtdvagas 
          ,vlarea_terreno 
          ,vltamanho_frente 
          ,indconserv_condom 
          ,indpessoa_vendedor 
          ,nrdoc_vendedor 
          ,nmvendor 
          ,nrreg_cetip 
          ,dtinclusao 
          ,tpinclusao 
          ,dsjustific_inclus )
        VALUES
          (pr_cdcooper
          ,pr_nrdconta
          ,pr_nrctremp
          ,pr_idseqbem
          ,trunc(SYSDATE) 
          ,pr_cdoperad
          ,vr_flgenvia -- Indica que o registro deve ou não ser enviado a Cetip
          ,NVL(vr_cdsituac,0)
          ,pr_nrmatcar
          ,pr_nrcnscar
          ,pr_nrreggar
          ,to_date(pr_dtreggar, 'DD/MM/YYYY')
          ,pr_nrgragar
          ,pr_tplograd
          ,UPPER(pr_dslograd)
          ,pr_nrlograd
          ,UPPER(pr_dscmplgr)
          ,UPPER(pr_dsbairro)
          ,pr_cdcidade
          ,pr_nrceplgr
          ,to_date(pr_dtavlimv, 'DD/MM/YYYY')
          ,gene0002.fn_char_para_number(pr_vlavlimv)
          ,to_date(pr_dtcprimv, 'DD/MM/YYYY')
          ,gene0002.fn_char_para_number(pr_vlcprimv)
          ,pr_tpimpimv
          ,pr_incsvimv
          ,pr_inpdracb
          ,gene0002.fn_char_para_number(pr_vlmtrtot)
          ,gene0002.fn_char_para_number(pr_vlmtrpri)
          ,pr_qtdormit
          ,pr_qtdvagas
          ,gene0002.fn_char_para_number(pr_vlmtrter)
          ,gene0002.fn_char_para_number(pr_vlmtrtes)
          ,pr_incsvcon
          ,pr_inpesvdr
          ,pr_nrdocvdr
          ,UPPER(pr_nmvendor)
          ,pr_nrreginc
          ,to_date(pr_dtinclus, 'DD/MM/YYYY')
          ,vr_tpinclus
          ,pr_dsjstinc);
      EXCEPTION
        WHEN OTHERS THEN
          pr_des_erro := 'Erro ao gravar dados: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
    ----
    END IF; -- fim: IF vr_flgregis
    
    -- Rotina para verificar as alterações realizadas e gravar o log das alterações
    pc_registra_alteracao_imovel(pr_cdcooper
                                ,pr_nrdconta
                                ,pr_nrctremp
                                ,pr_idseqbem
                                ,vr_dstransa
                                ,rw_imovel_alienado);
    
    -- Finaliza com status de sucesso
    pr_des_erro := 'OK';
  
    -- Efetivar os dados inseridos
    COMMIT;
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      ROLLBACK;
      pr_dscritic := pr_des_erro;
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>Rotina com erros</Dados></Root>');

    WHEN OTHERS THEN
      ROLLBACK;
      pr_des_erro := 'Erro geral: ' || SQLERRM;
      pr_dscritic := pr_des_erro;
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>Rotina com erros</Dados></Root>');
  END pc_grava_dados_imovel;

  -- IMPRIMIR OS DADOS DO IMÓVEL
  PROCEDURE pc_imprime_dados_imovel(pr_cdcooper IN NUMBER                --> Código da cooperativa para buscar os dados
                                 	 ,pr_nrdconta IN NUMBER                --> Número da conta
                                   ,pr_nrctremp IN NUMBER                --> Número do contrato
                                   ,pr_idseqbem IN NUMBER                -- Indica a sequencia do bem
                                   ,pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                   ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                                   ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2) IS         --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_imprime_dados_imovel
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Renato Darosci/SUPERO
    Data    : Junho/2016                       Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para imprimir os dados do imóvel selecionado na tela.

    Alteracoes:
    ............................................................................. */
    
    -- Buscar os dados do associado e dos bens do contrato
    CURSOR cr_crapass IS
      SELECT -- Informações do Credor
             cop.cdcooper
           , cop.nmrescop
           , GENE0002.fn_mask_cpf_cnpj(cop.nrdocnpj,2)  dsdoccop
           -- Informações do Devedor
           , TRIM(GENE0002.fn_mask_conta(ass.nrdconta))        dsdconta
           , ass.nrdconta
           , ass.nmprimtl                                      nmprimtl
           , GENE0002.fn_mask_cpf_cnpj(ass.nrcpfcgc,ass.inpessoa)  dsdocass
           , ass.inpessoa
           -- Dados da Operação de Crédito
           , TRIM(GENE0002.fn_mask_contrato(bpr.nrctrpro))     dsctremp
           , bpr.nrctrpro
           , to_char(epr.vlemprst, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.') vlemprst
           , bpr.idseqbem||' - '||bpr.dsbemfin                 idseqbem
           , lcr.cdmodali
           , lcr.cdsubmod
           , decode(bpr.dscatbem, 'CASA', '1 - CASA','APARTAMENTO','2 - APARTAMENTO') tpimovel
        FROM crapcop cop
           , crapass ass
           , craplcr lcr
           , crawepr epr
           , crapbpr bpr
       WHERE cop.cdcooper = ass.cdcooper
         AND ass.cdcooper = bpr.cdcooper
         AND ass.nrdconta = bpr.nrdconta
         AND lcr.cdlcremp = epr.cdlcremp
         AND lcr.cdcooper = epr.cdcooper
         AND epr.nrctremp = bpr.nrctrpro
         AND epr.nrdconta = bpr.nrdconta
         AND epr.cdcooper = bpr.cdcooper
         AND bpr.cdcooper = pr_cdcooper
         AND bpr.nrdconta = pr_nrdconta
         AND bpr.nrctrpro = pr_nrctremp
         AND bpr.tpctrpro = 90
         AND bpr.idseqbem = pr_idseqbem;
    rw_crapass     cr_crapass%ROWTYPE;
    
    -- Buscar todos os imóveis relacionados ao contrato
    CURSOR cr_crapbpr  IS
      SELECT imv.cdsituacao                                          cdsituac
           , DECODE(imv.cdsituacao , 0, 'NÃO ENVIADO'             
                                   , 1, 'EM PROCESSAMENTO'
                                   , 2, DECODE(imv.tpinclusao ,'A','REGISTRADO VIA ARQUIVO'
                                                              ,'M','REGISTRADO MANUAL')
                                	 , 3, 'PROCESSADO COM CRÍTICA'
                                   , 4, DECODE(imv.tpbaixa ,'A','BAIXADO VIA ARQUIVO'
                                                           ,'M','BAIXADO MANUAL')
                                   , 5, 'BAIXA COM CRÍTICA')   dssituac
           , imv.nrmatric_cartorio                                   nrmatcar
           , imv.nrcns_cartorio                                      nrcnscar
           , imv.nrreg_garantia                                      nrreggar
           , to_char(imv.dtreg_garantia ,'DD/MM/YYYY')               dtreggar
           , DECODE(imv.nrgrau_garantia 
                     , 0,'0 - Alienação fiduciária'
                     , 1,'1 - Hipoteca - primeiro grau'
                     , 2,'2 - Hipoteca - segundo grau'
                     , 3,'3 - Hipoteca - outros graus')              nrgragar
           , DECODE(imv.tplogradouro 
                     ,  1, 'Aeroporto'  ,  2, 'Alameda'   ,  3, 'Área'
                     ,  4, 'Avenida'    ,  5, 'Campo'     ,  6, 'Chácara'
                     ,  7, 'Colônia'    ,  8, 'Condomínio',  9, 'Conjunto'
                     , 10, 'Distrito'   , 11, 'Esplanada' , 12, 'Estação'
                     , 13, 'Estrada'    , 14, 'Favela'    , 15, 'Fazenda'
                     , 16, 'Feira'      , 17, 'Jardim'    , 18, 'Ladeira'
                     , 19, 'Lago'       , 20, 'Lagoa'     , 21, 'Largo'
                     , 22, 'Loteamento' , 23, 'Morro'     , 24, 'Núcleo'
                     , 25, 'Parque'     , 26, 'Passarela' , 27, 'Pátio'
                     , 28, 'Praça'      , 29, 'Quadra'    , 30, 'Recanto'
                     , 31, 'Residencial', 32, 'Rodovia'   , 33, 'Rua'
                     , 34, 'Setor'      , 35, 'Sítio'     , 36, 'Travessa'
                     , 37, 'Trecho'     , 38, 'Trevo'     , 39, 'Vale'
                     , 40, 'Vereda'     , 41, 'Via'       , 42, 'Viaduto'
                     , 43, 'Viela'      , 44, 'Vila'      , 99, 'Outros') tplograd  
           , imv.dslogradouro                                        dslograd
           , GENE0002.fn_mask(imv.nrlogradouro ,'zzz.zz9')           nrlograd
           , imv.dscomplemento                                       dscmplgr
           , imv.dsbairro                                            dsbairro
           , mun.dscidade                                            dscidade
           , mun.cdestado                                            cdestado
           , GENE0002.fn_mask(imv.nrcep ,'zzzzz-zz9')                nrceplgr
           , to_char(imv.dtavaliacao ,'DD/MM/YYYY')                  dtavlimv
           , to_Char(imv.vlavaliado ,'fm9g999g999g990d00','NLS_NUMERIC_CHARACTERS=,.') vlavlimv
           , to_char(imv.dtcompra  ,'DD/MM/YYYY')                    dtcprimv
           , to_Char(imv.vlcompra ,'fm9g999g999g990d00','NLS_NUMERIC_CHARACTERS=,.')   vlcprimv
           , DECODE(imv.tpimplantacao , 1, '1 - Condomínio'
                                      , 2, '2 - Isolado')            tpimpimv
           , DECODE(imv.indconservacao , 1, '1 - Bom' 
                                       , 2, '2 - Regular'
                                       , 3, '3 - Ruim'
                                       , 4, '4 - Em construção')     incsvimv
           , DECODE(imv.indpadrao_acab , 1, '1 - Alto' 
                                       , 2, '2 - Normal'
                                       , 3, '3 - Baixo'
                                       , 4, '4 - Mínimo')            inpdracb
           , to_Char(imv.vlarea_total ,'fm999g990d00','NLS_NUMERIC_CHARACTERS=,.')     vlmtrtot
           , to_Char(imv.vlarea_privada ,'fm999g990d00','NLS_NUMERIC_CHARACTERS=,.')   vlmtrpri
           , imv.qtddormitorio                                       qtdormit
           , imv.qtdvagas                                            qtdvagas
           , to_Char(imv.vlarea_terreno ,'fm999g990d00','NLS_NUMERIC_CHARACTERS=,.')   vlmtrter
           , to_Char(imv.vltamanho_frente ,'fm999g990d00','NLS_NUMERIC_CHARACTERS=,.') vlmtrtes
           , DECODE(imv.indconserv_condom , 1, '1 - Bom' 
                                          , 2, '2 - Regular'
                                          , 3, '3 - Ruim'
                                          , 4, '4 - Em implantação') incsvcon
           , DECODE(imv.indpessoa_vendedor , 1, '1 - Pessoa Física - CPF'
                                           , 2, '2 - Pessoa Jurídica - CNPJ'
                                           , 3, '3 - Pessoa Física no exterior'
                                           , 4, '4 - Pessoa Jurídica no exterior'
                                           , 5, '5 - Pessoa Física sem CPF'
                                           , 6, '6 - Pessoa Jurídica sem CNPJ' )       inpesvdr
           , NVL2(imv.nrdoc_vendedor,GENE0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => imv.nrdoc_vendedor
                                                              ,pr_inpessoa => decode(MOD(imv.indpessoa_vendedor ,2)
                                                                                           , 0, 2, 1)), NULL) nrdocvdr
           , imv.nmvendor                                            nmvendor
           , imv.nrreg_cetip                                         nrreginc
           , imv.tpinclusao                                          tpinclus
           , to_char(imv.dtinclusao,'DD/MM/YYYY')                    dtinclus
           , imv.dsjustific_inclus                                   dsjstinc          
           , imv.tpbaixa                                             tpdbaixa
           , to_char(imv.dtbaixa,'DD/MM/YYYY')                       dtdbaixa
           , imv.dsjustific_baixa                                    dsjstbxa
        FROM crapmun                 mun
           , tbepr_imovel_alienado   imv
       WHERE mun.cdcidade = imv.cdcidade
         AND imv.cdcooper = pr_cdcooper
         AND imv.nrdconta = pr_nrdconta
         AND imv.nrctrpro = pr_nrctremp
         AND imv.idseqbem = pr_idseqbem;
    rw_crapbpr    cr_crapbpr%ROWTYPE;
    
    -- Buscar a critica quando situação for 3 ou 5
    CURSOR cr_critica IS
      SELECT env.cdretorno||' - '||rto.dsretorn 
        FROM craprto             rto
           , tbepr_envio_cetip   env
       WHERE rto.cdretorn = env.cdretorno
         AND rto.nrtabela = 1 -- Será tabela fixa
         AND rto.cdoperac = 'I' -- Produto 3 será tratado como I fixo
         AND rto.cdprodut = 3 -- CETIP
         AND env.idseqbem = pr_idseqbem
         AND env.nrctrpro = pr_nrctremp
         AND env.nrdconta = pr_nrdconta
         AND env.cdcooper = pr_cdcooper
       ORDER BY env.dtretorno DESC;
    
    vr_xml       CLOB; --> CLOB com conteudo do XML do relatório
    vr_xmlbuffer VARCHAR2(32767); --> Auxiliar para envio do texto ao XML
    vr_strbuffer VARCHAR2(32767); --> Auxiliar para envio do texto ao XML
    
    -- Variaveis para a geracao do relatorio
    vr_nom_direto VARCHAR2(500);
    vr_nmarqimp   VARCHAR2(100);
    vr_dsmodali   VARCHAR2(10);
    vr_cdmodali   NUMBER;
    vr_cdsubmod   NUMBER;

    -- Variaveis extraidas do xml pr_retxml
    vr_cdcooper NUMBER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    -- Variável de críticas
    vr_cdcritic  crapcri.cdcritic%TYPE;
    vr_dscritic  VARCHAR2(10000);
    vr_des_reto  VARCHAR2(10);
    vr_typ_saida VARCHAR2(3);
    vr_tab_erro  gene0001.typ_tab_erro;
    
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    
  BEGIN
    
    -- extrair informações do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
    
    -- Inicializar XML do relatório
    dbms_lob.createtemporary(vr_xml, TRUE);
    dbms_lob.open(vr_xml, dbms_lob.lob_readwrite);
    
    vr_strbuffer := '<?xml version="1.0" encoding="utf-8"?>';
    
    -- Enviar ao CLOB
    gene0002.pc_escreve_xml(pr_xml            => vr_xml
                           ,pr_texto_completo => vr_xmlbuffer
                           ,pr_texto_novo     => vr_strbuffer);
    -- Limpar a auxiliar
    vr_strbuffer := NULL;
    
    -- Buscar os dados do cooperado e do bem do contrato
    OPEN  cr_crapass;
    FETCH cr_crapass INTO rw_crapass;
    CLOSE cr_crapass;
    
    -- Buscar o código da modalidade do BACEN
    vr_dsmodali := fn_busca_modalidade_bacen(pr_cdmodali => rw_crapass.cdmodali||rw_crapass.cdsubmod
                                            ,pr_cdcooper => rw_crapass.cdcooper
                                            ,pr_nrdconta => rw_crapass.nrdconta
                                            ,pr_nrctremp => rw_crapass.nrctrpro
                                            ,pr_inpessoa => rw_crapass.inpessoa
                                            ,pr_cdorigem => 3 -- Fixo 3 - Empréstimo
                                            ,pr_dsinfaux => '');
        
    -- Separar a modalidade retornada em modalidade e submodalidade
    vr_cdmodali := SUBSTR(LPAD(vr_dsmodali,4,'0'),0,2);
    vr_cdsubmod := SUBSTR(LPAD(vr_dsmodali,4,'0'),3);
    
    -- Buscar os dados do imovel
    OPEN  cr_crapbpr;
    FETCH cr_crapbpr INTO rw_crapbpr;
    
    -- Se não encontrar registros, pois o cadastro ainda não foi realizado
    IF cr_crapbpr%NOTFOUND THEN
      -- Não deve mostrar o tipo do bem, como não irá mostrar os demais dados
      rw_crapass.tpimovel := NULL;
      
      -- Envia a situação como não enviado
      rw_crapbpr.cdsituac := 0;
      rw_crapbpr.dssituac := 'NÃO ENVIADO';
    ELSE
      -- Se o código da situação for 3 - Processado com crítica ou 5 - baixa com crítica deve buscar a crítica 
      IF rw_crapbpr.cdsituac IN (3,5) THEN
        
        vr_dscritic := NULL;  
      
        -- BUSCAR A CRÍTICA 
        OPEN  cr_critica;
        FETCH cr_critica INTO vr_dscritic;
        CLOSE cr_critica;
        
      END IF;
    END IF;
    
    -- Montar XML com dados do imóvel
    vr_strbuffer := vr_strbuffer || 
                    '<imovel>' || 
                        '<cdcooper>' || rw_crapass.cdcooper || '</cdcooper>' ||
                        '<nmrescop>' || rw_crapass.nmrescop || '</nmrescop>' ||
                        '<dsdoccop>' || rw_crapass.dsdoccop || '</dsdoccop>' ||
                        '<dsdocass>' || rw_crapass.dsdocass || '</dsdocass>' ||
                        '<vlemprst>' || rw_crapass.vlemprst || '</vlemprst>' ||
                        '<cdmodali>' || LPAD(vr_cdmodali,2,'0') || '</cdmodali>' ||
                        '<cdsubmod>' || LPAD(vr_cdsubmod,2,'0') || '</cdsubmod>' ||
                        '<cdsituac>' || rw_crapbpr.cdsituac || '</cdsituac>' ||
                        '<dssituac>' || rw_crapbpr.dssituac || '</dssituac>' ||
                        '<nrdconta>' || rw_crapass.dsdconta || '</nrdconta>' ||
                        '<nmprimtl>' || rw_crapass.nmprimtl || '</nmprimtl>' ||
                        '<nrctremp>' || rw_crapass.dsctremp || '</nrctremp>' ||
                        '<idseqbem>' || rw_crapass.idseqbem || '</idseqbem>' ||
                        '<nrmatcar>' || rw_crapbpr.nrmatcar || '</nrmatcar>' || 
                        '<nrcnscar>' || rw_crapbpr.nrcnscar || '</nrcnscar>' || 
                        '<tpimovel>' || rw_crapass.tpimovel || '</tpimovel>' || 
                        '<nrreggar>' || rw_crapbpr.nrreggar || '</nrreggar>' || 
                        '<dtreggar>' || rw_crapbpr.dtreggar || '</dtreggar>' || 
                        '<nrgragar>' || rw_crapbpr.nrgragar || '</nrgragar>' || 
                        '<nrceplgr>' || rw_crapbpr.nrceplgr || '</nrceplgr>' || 
                        '<tplograd>' || rw_crapbpr.tplograd || '</tplograd>' || 
                        '<dslograd>' || rw_crapbpr.dslograd || '</dslograd>' || 
                        '<nrlograd>' || rw_crapbpr.nrlograd || '</nrlograd>' || 
                        '<dscmplgr>' || rw_crapbpr.dscmplgr || '</dscmplgr>' || 
                        '<dsbairro>' || rw_crapbpr.dsbairro || '</dsbairro>' || 
                        '<dscidade>' || rw_crapbpr.dscidade || '</dscidade>' || 
                        '<cdestado>' || rw_crapbpr.cdestado || '</cdestado>' || 
                        '<dtavlimv>' || rw_crapbpr.dtavlimv || '</dtavlimv>' || 
                        '<vlavlimv>' || rw_crapbpr.vlavlimv || '</vlavlimv>' || 
                        '<dtcprimv>' || rw_crapbpr.dtcprimv || '</dtcprimv>' || 
                        '<vlcprimv>' || rw_crapbpr.vlcprimv || '</vlcprimv>' || 
                        '<tpimpimv>' || rw_crapbpr.tpimpimv || '</tpimpimv>' || 
                        '<incsvimv>' || rw_crapbpr.incsvimv || '</incsvimv>' || 
                        '<inpdracb>' || rw_crapbpr.inpdracb || '</inpdracb>' || 
                        '<vlmtrtot>' || rw_crapbpr.vlmtrtot || '</vlmtrtot>' || 
                        '<vlmtrpri>' || rw_crapbpr.vlmtrpri || '</vlmtrpri>' || 
                        '<qtdormit>' || rw_crapbpr.qtdormit || '</qtdormit>' || 
                        '<qtdvagas>' || rw_crapbpr.qtdvagas || '</qtdvagas>' || 
                        '<vlmtrter>' || rw_crapbpr.vlmtrter || '</vlmtrter>' || 
                        '<vlmtrtes>' || rw_crapbpr.vlmtrtes || '</vlmtrtes>' || 
                        '<incsvcon>' || rw_crapbpr.incsvcon || '</incsvcon>' || 
                        '<inpesvdr>' || rw_crapbpr.inpesvdr || '</inpesvdr>' || 
                        '<nrdocvdr>' || rw_crapbpr.nrdocvdr || '</nrdocvdr>' || 
                        '<nmvendor>' || rw_crapbpr.nmvendor || '</nmvendor>' || 
                        '<nrdocvdr>' || rw_crapbpr.nrdocvdr || '</nrdocvdr>' ||
                        '<nmvendor>' || rw_crapbpr.nmvendor || '</nmvendor>' ||
                        '<nrreginc>' || rw_crapbpr.nrreginc || '</nrreginc>' ||
                        '<tpinclus>' || rw_crapbpr.tpinclus || '</tpinclus>' ||
                        '<dtinclus>' || rw_crapbpr.dtinclus || '</dtinclus>' ||
                        '<dsjstinc>' || rw_crapbpr.dsjstinc || '</dsjstinc>' ||
                        '<tpdbaixa>' || rw_crapbpr.tpdbaixa || '</tpdbaixa>' ||
                        '<dtdbaixa>' || rw_crapbpr.dtdbaixa || '</dtdbaixa>' ||
                        '<dsjstbxa>' || rw_crapbpr.dsjstbxa || '</dsjstbxa>' ||
                        '<dscritic>' || vr_dscritic         || '</dscritic>' ||
                    '</imovel>';
    
    -- Fechar os dados do cursor
    CLOSE cr_crapbpr;
    
    -- Evitar erros indevidos
    vr_dscritic := NULL;
    
    -- Enviar ao CLOB
    gene0002.pc_escreve_xml(pr_xml            => vr_xml
                           ,pr_texto_completo => vr_xmlbuffer
                           ,pr_texto_novo     => vr_strbuffer
                           ,pr_fecha_xml      => TRUE); --> Ultima chamada
    
    -- Somente se o CLOB contiver informações
    IF dbms_lob.getlength(vr_xml) > 0 THEN
      
      -- Busca do diretório base da cooperativa para PDF
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl
      
      -- Definir nome do relatorio
      vr_nmarqimp := 'crrl720_' || pr_nrdconta || '_' || pr_nrctremp || '_' || pr_idseqbem || '.pdf';
      
      -- Solicitar geração do relatorio
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper --> Cooperativa conectada
                                 ,pr_cdprogra  => 'IMOVEL' --> Programa chamador
                                 ,pr_dtmvtolt  => SYSDATE --> Data do movimento atual
                                 ,pr_dsxml     => vr_xml --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/imovel' --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl720.jasper' --> Arquivo de layout do iReport
                                 ,pr_dsparams  => null --> Sem parâmetros
                                 ,pr_dsarqsaid => vr_nom_direto || '/' || vr_nmarqimp --> Arquivo final com o path
                                 ,pr_cdrelato  => 720
                                 ,pr_qtcoluna  => 132 --> 132 colunas
                                 ,pr_flg_gerar => 'S' --> Geraçao na hora
                                 ,pr_flg_impri => 'N' --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => '' --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1 --> Número de cópias
                                 ,pr_sqcabrel  => 1 --> Qual a seq do cabrel
                                 ,pr_des_erro  => vr_dscritic); --> Saída com erro
      -- Tratar erro
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        raise vr_exc_saida;
      END IF;
      
      -- Enviar relatorio para intranet
      gene0002.pc_efetua_copia_pdf(pr_cdcooper => vr_cdcooper --> Cooperativa conectada
                                  ,pr_cdagenci => vr_cdagenci --> Codigo da agencia para erros
                                  ,pr_nrdcaixa => vr_nrdcaixa --> Codigo do caixa para erros
                                  ,pr_nmarqpdf => vr_nom_direto || '/' ||vr_nmarqimp --> Arquivo PDF  a ser gerado
                                  ,pr_des_reto => vr_des_reto --> Saída com erro
                                  ,pr_tab_erro => vr_tab_erro); --> tabela de erros
      
      -- caso apresente erro na operação
      IF nvl(vr_des_reto, 'OK') <> 'OK' THEN
        IF vr_tab_erro.COUNT > 0 THEN
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          
          RAISE vr_exc_saida;
        END IF;
      END IF;
      
      -- Remover relatorio da pasta rl apos gerar
      gene0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => 'rm ' || vr_nom_direto || '/' || vr_nmarqimp
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);
      -- Se retornou erro
      IF vr_typ_saida = 'ERR'
         OR vr_dscritic IS NOT null THEN
        -- Concatena o erro que veio
        vr_dscritic := 'Erro ao remover arquivo: ' || vr_dscritic;
        RAISE vr_exc_saida;
      END IF;
      
    END IF;
    
    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_xml);
    dbms_lob.freetemporary(vr_xml);
    
    -- Criar XML de retorno
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><nmarqpdf>' ||
                                   vr_nmarqimp || '</nmarqpdf>');
  
  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' ||
                                     pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral pc_imprime_dados_imovel: ' || SQLERRM;
      
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' ||
                                     pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_imprime_dados_imovel;

  -- GRAVAR OS DADOS REFERENTE A BAIXA MANUAL
  PROCEDURE pc_gravar_baixa_manual_imovel(pr_cdcooper   IN NUMBER             -- Código da cooperativa
                                         ,pr_nrdconta   IN NUMBER             -- Número da conta
                                         ,pr_nrctremp   IN NUMBER             -- Número do contrato de empréstimo
                                         ,pr_idseqbem   IN NUMBER             -- Código de sequencia do bem
                                         ,pr_dtdbaixa   IN VARCHAR2           -- Data da baixa da alienação
                                         ,pr_dsjstbxa   IN VARCHAR2           -- Justificativa da Baixa
                                         ,pr_cdoperad   IN VARCHAR2           -- Código do operador
                                         ,pr_xmllog     IN VARCHAR2           --> XML com informacoes de LOG
                                         ,pr_cdcritic  OUT PLS_INTEGER        --> Codigo da critica
                                         ,pr_dscritic  OUT VARCHAR2           --> Descricao da critica
                                         ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                         ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                                         ,pr_des_erro  OUT VARCHAR2) IS       --> Saida OK/NOK
    
    /* .............................................................................
    Programa: pc_gravar_baixa_manual_imovel
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Renato Darosci/SUPERO
    Data    : Junho/2016                       Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para gravar a baixa manual das alienação.

    Alteracoes:
    ............................................................................. */
    
    -- VARIÁVEIS
    rw_imovel_alienado cr_tbepr_imovel_alienado%ROWTYPE;
    
    -- Controle de erro
    vr_exc_erro EXCEPTION;
    
  BEGIN
    
    pr_des_erro := 'NOK';
    
    OPEN  cr_tbepr_imovel_alienado(pr_cdcooper, pr_nrdconta, pr_nrctremp, pr_idseqbem);
    FETCH cr_tbepr_imovel_alienado INTO rw_imovel_alienado;
    CLOSE cr_tbepr_imovel_alienado;
    
    -- Criar cabecalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    
    -- Realizar a gravação dos dados na tabela
    BEGIN
      UPDATE tbepr_imovel_alienado
         SET dtmvtolt          = trunc(SYSDATE)
           , cdoperad          = pr_cdoperad
           , flgenvia          = 0 -- Indica que o registro não deve ser enviado a Cetip
           , cdsituacao        = 4 -- Baixado
           , dtbaixa           = to_date(pr_dtdbaixa,'DD/MM/YYYY')
           , tpbaixa           = 'M' -- Baixa Manual
           , dsjustific_baixa  = pr_dsjstbxa
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctrpro = pr_nrctremp
         AND idseqbem = pr_idseqbem;
    EXCEPTION
      WHEN OTHERS THEN
        pr_des_erro := 'Erro ao atualizar dados: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
    
    -- Rotina para verificar as alterações realizadas e gravar o log das alterações
    pc_registra_baixa_imovel(pr_cdcooper
                            ,pr_nrdconta
                            ,pr_nrctremp
                            ,pr_idseqbem
                            ,rw_imovel_alienado);
    
    -- Finaliza com status de sucesso
    pr_des_erro := 'OK';
  
    -- Efetivar os dados inseridos
    COMMIT;
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      ROLLBACK;
      pr_dscritic := pr_des_erro;
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>Rotina com erros</Dados></Root>');

    WHEN OTHERS THEN
      ROLLBACK;
      pr_des_erro := 'Erro geral: ' || SQLERRM;
      pr_dscritic := pr_des_erro;
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>Rotina com erros</Dados></Root>');
  END pc_gravar_baixa_manual_imovel;

  -- LISTAS AS COOPERATIVAS A SEREM LISTADAS NA TELA
  PROCEDURE pc_lista_coop_pesquisa(pr_xmllog     IN VARCHAR2            --> XML com informações de LOG
                                  ,pr_cdcritic  OUT PLS_INTEGER         --> Código da crítica
                                  ,pr_dscritic  OUT VARCHAR2            --> Descrição da crítica
                                  ,pr_retxml     IN OUT NOCOPY XMLType  --> Arquivo de retorno do XML
                                  ,pr_nmdcampo  OUT VARCHAR2            --> Nome do campo com erro
                                  ,pr_des_erro  OUT VARCHAR2) IS        --> Erros do processo

    /* .............................................................................

      Programa: pc_lista_coop_pesquisa
      Sistema : Conta-Corrente - Cooperativa de Credito
      Sigla   : CRED
      Autor   : Renato Darosci/SUPERO
      Data    : Junho/2016                       Ultima atualizacao:

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Realiza listagem das cooperativas que serão listadas nos
                  parametros de pesquisa da tela IMOVEL
      Observacao: -----

      Alteracoes:

    ..............................................................................*/
    -- Cursores
    CURSOR cr_crapcop(pr_cdcooper crapprm.cdcooper%TYPE) IS
      SELECT cop.cdcooper
           , cop.nmrescop  nmrescop
        FROM crapcop  cop
       WHERE cop.flgativo = 1
         AND (cop.cdcooper = pr_cdcooper
            OR pr_cdcooper = 3)
       ORDER BY cop.nmrescop;

    -- Variáveis
    vr_cdcooper         NUMBER;
    vr_nmdatela         VARCHAR2(25);
    vr_nmeacao          VARCHAR2(25);
    vr_cdagenci         VARCHAR2(25);
    vr_nrdcaixa         VARCHAR2(25);
    vr_idorigem         VARCHAR2(25);
    vr_cdoperad         VARCHAR2(25);

    -- Excessões
    vr_exc_erro         EXCEPTION;

  BEGIN

    -- Extrair informacoes padrao do xml - parametros
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => pr_dscritic);

    -- Criar cabecalho do XML
     pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

     -- Para cada cooperativa encontrada
     FOR rw_crapcop IN cr_crapcop(vr_cdcooper) LOOP

       -- Criar nodo filho
       pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                          ,'/Root'
                                          ,XMLTYPE('<coop>'||
                                                   '<cdcooper>'||rw_crapcop.cdcooper||'</cdcooper>'||
                                                   '<nmrescop>'||rw_crapcop.nmrescop||'</nmrescop>'||
                                                   '</coop>'));

     END LOOP;


  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Desfazer alterações
      ROLLBACK;

      pr_dscritic := pr_des_erro;
       -- Carregar XML padrao para variavel de retorno nao utilizada.
      -- Existe para satisfazer exigencia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>Rotina com erros</Dados></Root>');
    WHEN OTHERS THEN
      -- Desfazer alterações
      ROLLBACK;

      pr_des_erro := 'Erro geral na rotina pc_lista_coop_pesquisa: '||SQLERRM;
      pr_dscritic := pr_des_erro;

      -- Carregar XML padrao para variavel de retorno nao utilizada.
      -- Existe para satisfazer exigencia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>Rotina com erros</Dados></Root>');
  END pc_lista_coop_pesquisa;

  -- REALIZAR A GERAÇÃO DOS RELATÓRIOS SOLICITADOS NA TELA DE IMÓVEIS
  PROCEDURE pc_imprime_relatorio_imovel(pr_cdcooper IN NUMBER                --> Código da cooperativa conectada
                                       ,pr_cdcoptel IN NUMBER                --> Código da cooperativa selecionada em tela
                                       ,pr_inrelato IN NUMBER                --> Indica o relatório
                                       ,pr_intiprel IN VARCHAR2              --> Indica o tipo do relatório
                                       ,pr_dtrefere IN VARCHAR2              --> Data de referencia para os itens do relatório
                                       ,pr_cddolote IN NUMBER                --> Código do Lote
                                       ,pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                       ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                                       ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2) IS         --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_imprime_relatorio_imovel
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Renato Darosci/SUPERO
    Data    : Junho/2016                       Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para imprimir os relatórios dos imóveis conforme parâmetros.

    Alteracoes:
    ............................................................................. */
     
    -- VARIÁVEIS
    vr_nmarqimp   VARCHAR2(100);
    
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    
  BEGIN
  
    -- Verifica qual o relatório a ser chamado
    IF pr_inrelato = 1 THEN
      pc_relatorio_enviados(pr_cdcooper
                           ,pr_cdcoptel
                           ,pr_intiprel
                           ,pr_dtrefere
                           ,pr_cddolote
                           ,vr_nmarqimp);
    ELSIF pr_inrelato = 2 THEN
      pc_relatorio_manual(pr_cdcooper
                         ,pr_cdcoptel
                         ,pr_intiprel
                         ,pr_dtrefere
                         ,vr_nmarqimp);
    ELSE
      pr_dscritic := 'Relatório solicitado não definido.';
      RAISE vr_exc_saida;
    END IF;
    
    -- Se não gerou nome de arquivo ocorreu algum erro
    IF vr_nmarqimp IS NULL THEN
      pr_dscritic := 'Arquivo não gerado, verifique!';
      RAISE vr_exc_saida;
    END IF;
    
    -- Criar XML de retorno
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><nmarqpdf>' ||
                                   vr_nmarqimp || '</nmarqpdf>');
  
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' ||
                                     pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro geral pc_imprime_relatorio_imovel('||pr_cdcooper||'): ' || SQLERRM;
      
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' ||
                                     pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_imprime_relatorio_imovel;
  
  -- GERAR OS ARQUIVOS COM DADOS PARA SEREM ENVIADOS A CETIP
  PROCEDURE pc_gerar_arquivo_cetip(pr_cdcoptel IN NUMBER                --> Código da cooperativa para buscar os dados
                                  ,pr_intiparq IN VARCHAR2              --> Indica o tipo de arquivo
                                  ,pr_cdoperad IN VARCHAR2              --> Código do operador
                                  ,pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                  ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                                  ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2) IS         --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_gerar_arquivo_cetip
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Renato Darosci/SUPERO
    Data    : Junho/2016                       Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para gerar o arquivo a ser enviado para o Cetip

    Alteracoes:
    ............................................................................. */
    
    -- Buscar todas as cooperativas ou a cooperativa selecionada na tela
    CURSOR cr_crapcop IS
      SELECT cop.cdcooper
           , cop.nrdocnpj
        FROM crapcop cop
       WHERE (cop.cdcooper = pr_cdcoptel OR pr_cdcoptel = 0);
    
    -- Buscar as informações dos empréstimos com registros a serem inclusos
    CURSOR cr_crapepr(pr_cdcooper crapcop.cdcooper%TYPE
                     ,pr_dtultdma crapdat.dtultdma%TYPE) IS
      WITH IMV_CETIP AS (SELECT cdcooper
                              , nrdconta
                              , nrctrpro
                              , COUNT(1) qtdenvia
                              , SUM(DECODE(i.cdsituacao, 2,1,0)) qtaltera
                              , SUM(DECODE(i.cdsituacao, 3,1,0)) qtcritic
                           FROM tbepr_imovel_alienado i
                          WHERE i.flgenvia = 1
                            AND i.cdsituacao IN (0,2,3) -- não processado, alteracao ou com critica
                            AND i.cdcooper = pr_cdcooper
                          GROUP BY cdcooper, nrdconta, nrctrpro)
      SELECT epr.nrdconta
           , epr.nrctremp
           , epr.vlemprst
           , ROUND((POWER(1 + ( lcr.txmensal /100),12) - 1) * 100,2)  vltxaanual
           , lcr.cdmodali
           , lcr.cdsubmod
           , ass.inpessoa
           , ass.nrcpfcgc
           , ass.nmprimtl
           , (SELECT COUNT(1) qtdbens
                FROM crapbpr b
               WHERE b.flgalien = 1
                 AND b.dscatbem IN ('CASA','APARTAMENTO')
                 AND b.tpctrpro = 90
                 AND b.cdcooper = epr.cdcooper
                 AND b.nrdconta = epr.nrdconta
                 AND b.nrctrpro = epr.nrctremp) qtdbens
           , imv.qtdenvia
           , imv.qtaltera
           , imv.qtcritic
        FROM crapass  ass
           , craplcr  lcr
           , crapepr  epr
           , IMV_CETIP imv
       WHERE ass.nrdconta = epr.nrdconta
         AND ass.cdcooper = epr.cdcooper
         AND lcr.cdcooper = epr.cdcooper
         AND lcr.cdlcremp = epr.cdlcremp
         AND imv.cdcooper = epr.cdcooper
         AND imv.nrdconta = epr.nrdconta
         AND imv.nrctrpro = epr.nrctremp
         -- ver renato AND epr.dtmvtolt <= pr_dtultdma -- Aprovados no ultimo dia do mês anterior inclusive
         AND epr.cdcooper = pr_cdcooper;
    
    -- Buscar todos os registros a serem lidos para envio
    CURSOR cr_imoveis(pr_cdcooper    crapbpr.cdcooper%TYPE
                     ,pr_nrdconta    crapbpr.nrdconta%TYPE
                     ,pr_nrctrpro    crapbpr.nrctrpro%TYPE) IS
      SELECT imv.idseqbem
           , DECODE(bpr.dscatbem, 'CASA', '1','APARTAMENTO','2') tpimovel
           , imv.nrmatric_cartorio
           , imv.nrcns_cartorio
           , imv.nrreg_garantia
           , to_char(imv.dtreg_garantia,'YYYY-MM-DD') dtreg_garantia
           , imv.nrgrau_garantia
           , imv.tplogradouro
           , imv.dslogradouro
           , NVL(TO_CHAR(imv.nrlogradouro),'SN') nrlogradouro -- SN = Sem Número
           , imv.dscomplemento
           , NVL(TO_CHAR(imv.dsbairro),'SB')  dsbairro -- SB = Sem Bairro
           , imv.cdcidade
           , mun.cdestado
           , imv.nrcep
           , to_char(imv.dtavaliacao,'YYYY-MM-DD') dtavaliacao
           , imv.vlavaliado
           , to_char(imv.dtcompra,'YYYY-MM-DD') dtcompra
           , imv.vlcompra
           , imv.tpimplantacao
           , imv.indconservacao
           , imv.indpadrao_acab
           , imv.vlarea_total
           , imv.vlarea_privada
           , imv.qtddormitorio
           , imv.qtdvagas
           , imv.vlarea_terreno
           , imv.vltamanho_frente
           , imv.indconserv_condom
           , imv.indpessoa_vendedor
           , imv.nrdoc_vendedor
           , imv.nmvendor
           , imv.rowid    dsrowid
           , DECODE(imv.cdsituacao, 3, NVL2(imv.nrreg_cetip,'A','I'), 0,'I', 2, 'A') tpoperacao
        FROM crapmun               mun
           , tbepr_imovel_alienado imv
           , crapbpr               bpr
       WHERE mun.cdcidade = imv.cdcidade
         AND bpr.cdcooper = imv.cdcooper
         AND bpr.nrdconta = imv.nrdconta
         AND bpr.tpctrpro = 90
         AND bpr.nrctrpro = imv.nrctrpro
         AND bpr.idseqbem = imv.idseqbem
         AND imv.flgenvia = 1
         AND imv.cdcooper = pr_cdcooper
         AND imv.nrdconta = pr_nrdconta
         AND imv.nrctrpro = pr_nrctrpro
       ORDER BY imv.idseqbem;
    
    CURSOR cr_liquidado(pr_cdcooper crapcop.cdcooper%TYPE
                       ,pr_dtultdma crapdat.dtultdma%TYPE) IS
      SELECT epr.nrdconta
           , epr.nrctremp
           , TO_CHAR(epr.dtultpag, 'YYYY-MM-DD') dtliquid
           , lcr.cdmodali
           , lcr.cdsubmod
           , ass.inpessoa
           , imv.idseqbem
           , imv.rowid  dsrowid
        FROM crapass  ass
           , craplcr  lcr
           , tbepr_imovel_alienado  imv
           , crapepr  epr
       WHERE ass.nrdconta = epr.nrdconta
         AND ass.cdcooper = epr.cdcooper
         AND lcr.cdcooper = epr.cdcooper
         AND lcr.cdlcremp = epr.cdlcremp
         AND imv.cdcooper = epr.cdcooper
         AND imv.nrdconta = epr.nrdconta
         AND imv.nrctrpro = epr.nrctremp
         AND imv.nrreg_cetip IS NOT NULL -- já registrados na CETIP
         AND ((imv.cdsituacao = 2 AND imv.tpbaixa IS NULL) OR 
              (imv.cdsituacao = 5 AND imv.tpbaixa IS NOT NULL) OR  -- não baixados
              (imv.cdsituacao = 1 ) )       
         AND epr.cdcooper = pr_cdcooper
         AND epr.inliquid = 1            -- Empréstimo liquidado
         -- ver renato AND epr.dtultpag <= pr_dtultdma 
         AND epr.inprejuz = 0;           -- Não tenha sido colocado como prejuizo

    
    -- Registro das linhas que serão escritas no arquivo
    TYPE typ_linhas IS TABLE OF VARCHAR2(500) INDEX BY BINARY_INTEGER;
    vr_tablinhas       typ_linhas;
   
    -- VARIÁVEIS
    vr_dsdiretorio     VARCHAR2(100);      --> Local onde estão os arquivos 
    vr_dsnomearq       VARCHAR2(30);       --> Nome do arquivo
    vr_nrdoscr         VARCHAR2(40);
    vr_cdmodali        VARCHAR2(4);
    vr_nrlinha         NUMBER;
    vr_rowidlog        VARCHAR2(20);
    vr_dsarquiv        CLOB; -- conteúdo do arquivo
    vr_dscritic        VARCHAR2(100);
    vr_texto           VARCHAR2(1000);
    vr_nrlote          NUMBER;
    vr_nrseqlote       NUMBER;
    vr_indexlinha      NUMBER;
    vr_typ_said        VARCHAR2(30);
    vr_dscomand        VARCHAR2(1000);
    vr_cdcadu          crapprm.dsvlrprm%TYPE;
    
    vr_flgcoop         BOOLEAN;
    vr_flgepr          BOOLEAN;
    
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    
    -- Procedure para adicionar as linhas no registro
    PROCEDURE add_linha(pr_dslinha IN VARCHAR2) IS
    BEGIN
      -- Calcula o proximo indice
      vr_indexlinha := vr_tablinhas.count()+1;
      -- Adiciona a linha no registro
      vr_tablinhas(vr_indexlinha) := pr_dslinha;
    END;
    
    FUNCTION fn_form_number(pr_number IN NUMBER) RETURN VARCHAR2 IS
    BEGIN
      RETURN to_char(pr_number, 'fm999999999999999990d00','NLS_NUMERIC_CHARACTERS=,.');
    END;
    
  BEGIN
    -- Criar cabecalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

    -- Finaliza com status de sucesso
    pr_des_erro := 'NOK';
    
    vr_flgcoop := FALSE;
    vr_flgepr  := FALSE;

    -- Busca o número do lote para cada cooperativa inclusa no arquivo
    vr_nrlote := fn_sequence(pr_nmtabela => 'TBEPR_ENVIO_CETIP'
                            ,pr_nmdcampo => 'NRDOLOTE'
                            ,pr_dsdchave => ' ');
    
    -- Buscar o diretório para o arquivo
    vr_dsdiretorio := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                               ,pr_cdacesso => 'ENVIO_CETIP');

    -- Buscar o código CADU, que é o código de cadastro da cooperativa na CETIP
    vr_cdcadu := TRIM(gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                               ,pr_cdacesso => 'CADU_CETIP'));

    -- Formar o nome do arquivo a ser enviado, com lote e data
    vr_dsnomearq := 'ENV_'||TO_CHAR(vr_nrlote,'FM0000000')||'_'||to_char(SYSDATE,'YYYYMMDD')||'.txt';
    
    -- Imprimir o código de cadastro Cetip (CADU) na primeira linha do arquivo
    add_linha(vr_cdcadu);
    
    -- Sequencial dentro do lote
    vr_nrseqlote := 0;
    
    -- Percorrer todas as cooperativas, ou a cooperativa selecionada
    FOR rw_coop IN cr_crapcop LOOP
     
      -- Setar para imprimir
      vr_flgcoop := TRUE;

      -- Buscar a data corrente para a cooperativa
      OPEN  BTCH0001.cr_crapdat(rw_coop.cdcooper);
      FETCH BTCH0001.cr_crapdat INTO BTCH0001.rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;
      
      -- Se for para mandar arquivo com inclusão ou todos
      IF pr_intiparq IN ('I','T') THEN
      
        -- Percorrer todos os empréstimos com dados a serem enviados a Cetip
        FOR rw_operac IN cr_crapepr(rw_coop.cdcooper, BTCH0001.rw_crapdat.dtultdma) LOOP

          -- Verifica se ainda há imóveis no emprestimo a serem preenchidos
          IF rw_operac.qtdbens <> rw_operac.qtdenvia AND rw_operac.qtaltera = 0 AND rw_operac.qtcritic = 0 THEN
            CONTINUE; -- Passa apra o próximo registro
          END IF;
        
          -- Buscar o código da modalidade do BACEN
          vr_cdmodali := fn_busca_modalidade_bacen(pr_cdmodali => rw_operac.cdmodali||rw_operac.cdsubmod
                                                  ,pr_cdcooper => rw_coop.cdcooper
                                                  ,pr_nrdconta => rw_operac.nrdconta
                                                  ,pr_nrctremp => rw_operac.nrctremp
                                                  ,pr_inpessoa => rw_operac.inpessoa
                                                  ,pr_cdorigem => 3 -- Fixo 3 - Empréstimo
                                                  ,pr_dsinfaux => '');
        
          -- Formar o código do SCR conforme o 3040
          vr_nrdoscr := LPAD(rw_coop.cdcooper,5,'0')  ||
                        LPAD(rw_operac.nrdconta,15,'0') ||
                        LPAD(rw_operac.nrctremp,15,'0') ||
                        LPAD(vr_cdmodali,5,'0');

          -- Setar para imprimir
          vr_flgepr := TRUE;
         
          -- Buscar os Imóveis do contrato que devem ser enviados
          FOR rw_imovel IN  cr_imoveis(rw_coop.cdcooper,rw_operac.nrdconta,rw_operac.nrctremp) LOOP
            
            IF vr_flgcoop THEN
              -- Adiciona linha do CREDOR
              add_linha('C;'||rw_coop.nrdocnpj);
                            
              -- Setar para não imprimir
              vr_flgcoop := FALSE;
            END IF;
            
            IF vr_flgepr THEN
          
              -- Adicionar a linha referente à OPERAÇÃO DE CRÉDITO
              add_linha(  'O;'                        -- Tipo de informação
                        ||'C;'                        -- Tipo da origem das informações(será sempre COMPLETO)
                        ||rw_coop.nrdocnpj    ||';'   -- CNPJ do Credor
                        ||vr_nrdoscr          ||';'   -- Código do SCR
                        ||vr_cdmodali         ||';'   -- Código da modalidade e submodalidade
                        ||fn_form_number(rw_operac.vlemprst)  ||';'   -- Valor do empréstimo
                        ||fn_form_number(rw_operac.vltxaanual)||';'   -- Taxa anual emprestimo
                        ||'' );                      -- Data de liquidação do contrato - NULL
                          
              -- Adicionar a linha referente aos DADOS DO DEVEDOR
              add_linha(  'D;'                        -- Tipo de informação
                        ||rw_coop.nrdocnpj    ||';'   -- CNPJ do Credor
                        ||vr_nrdoscr          ||';'   -- Código do SCR
                        ||rw_operac.inpessoa  ||';'   -- Código da modalidade e submodalidade
                        ||rw_operac.nrcpfcgc  ||';'   -- Número do CPF ou CNPJ do titular
                        ||SUBSTR(rw_operac.nmprimtl,0,40)||';'   -- Nome do devedor
                        ||'S' );                    -- Devedor informado no SCR - FIXO
              
              -- Setar para não imprimir
              vr_flgepr := FALSE;
              
            END IF;

            -- Adicionar a linha referente aos DADOS DO IMOVEL
            add_linha(  'I;'                            -- Tipo de informação
                      ||rw_coop.nrdocnpj    ||';'       -- CNPJ do Credor
                      ||vr_nrdoscr          ||';'       -- Código do SCR
                      ||rw_imovel.nrcns_cartorio||';'   -- Código CNS do cartório
                      ||rw_imovel.nrmatric_cartorio||';'-- Número de matrícula do imóvel
                      ||rw_imovel.nrreg_garantia||';'   -- Número de registro da garantia
                      ||rw_imovel.dtreg_garantia||';'   -- Data do registro da garantia
                      ||rw_imovel.nrgrau_garantia||';'  -- Grau da garantia
                      ||rw_imovel.tplogradouro||';'     -- Tipo do Logradouro
                      ||rw_imovel.dslogradouro||';'     -- Endereço logradouro
                      ||rw_imovel.nrlogradouro||';'     -- Número do logradouro
                      ||rw_imovel.dscomplemento||';'    -- Complemento
                      ||rw_imovel.dsbairro||';'         -- Bairro
                      ||rw_imovel.cdcidade||';'         -- Código da cidade
                      ||rw_imovel.cdestado||';'         -- Unidade da Federação
                      ||rw_imovel.nrcep||';'            -- Número do CEP
                      ||rw_imovel.tpimovel||';'         -- Tipo do imóvel: Casa ou apartamento
                      ||rw_imovel.tpimplantacao||';'    -- Tipo de implantação do imóvel
                      ||fn_form_number(rw_imovel.vlarea_total)||';'  -- Área total do imóvel
                      ||fn_form_number(rw_imovel.vlarea_privada)||';'-- Área privativa do imóvel
                      ||rw_imovel.qtddormitorio||';'    -- Quantidade de dormitórios do imóvel
                      ||rw_imovel.qtdvagas||';'         -- Quantidade de vagas do imóvel
                      ||rw_imovel.indconserv_condom||';'-- Estado de conservação do condomínio
                      ||fn_form_number(rw_imovel.vlarea_terreno)||';'   -- Área do terreno do imóvel
                      ||fn_form_number(rw_imovel.vltamanho_frente)||';' -- Tamanho da frente do terreno - testada
                      ||rw_imovel.indconservacao||';'   -- Estado de conservação do imóvel
                      ||rw_imovel.indpadrao_acab||';'   -- Nível de padrão de acabamento
                      ||rw_imovel.dtavaliacao||';'      -- Data da avaliação do imovel
                      ||fn_form_number(rw_imovel.vlavaliado)||';' -- Valor avaliado
                      ||rw_imovel.dtcompra||';'         -- Data da compra do imóvel
                      ||fn_form_number(rw_imovel.vlcompra)||';'   -- Valore avaliado
                      ||'');                          -- Identificação da avaliação(Apenas banco com plataforma imobiliaria)
             
            -- Incluir a informação na tabela de controle de envios
            BEGIN 

              -- Incrementar a sequencia
              vr_nrseqlote := vr_nrseqlote + 1;
            
              INSERT INTO tbepr_envio_cetip(cdcooper
                                           ,nrdconta
                                           ,nrctrpro
                                           ,idseqbem
                                           ,nrdolote
                                           ,tpoperacao
                                           ,dtenvio
                                           ,dtretorno
                                           ,cdretorno
                                           ,nrreg_cetip
                                           ,nrlinhaarquivo
                                           ,nrseqlote
                                           ,nrscr_cetip)
                                    VALUES (rw_coop.cdcooper      -- cdcooper
                                           ,rw_operac.nrdconta    -- nrdconta
                                           ,rw_operac.nrctremp    -- nrctrpro
                                           ,rw_imovel.idseqbem    -- idseqbem
                                           ,vr_nrlote             -- nrdolote
                                           ,rw_imovel.tpoperacao  -- tpoperacao
                                           ,trunc(SYSDATE)        -- dtenvio
                                           ,NULL                  -- dtretorno
                                           ,NULL                  -- cdretorno
                                           ,NULL                  -- nrreg_cetip
                                           ,vr_indexlinha         -- nrlinhaarquivo
                                           ,vr_nrseqlote          -- nrseqlote
                                           ,vr_nrdoscr );         -- nrscr_cetip
            EXCEPTION
              WHEN OTHERS THEN
                pr_dscritic := 'Erro ao registrar envio: '||SQLERRM;
                RAISE vr_exc_saida; -- encerra execução

            END; 
            --
               
            -- Se foram preenchidos dados do vendedor
            IF rw_imovel.indpessoa_vendedor IS NOT NULL THEN
              add_linha(  'V;'                      -- Tipo de informação
                      ||rw_coop.nrdocnpj    ||';'   -- CNPJ do Credor
                      ||vr_nrdoscr          ||';'   -- Código do SCR
                      ||rw_imovel.indpessoa_vendedor||';'   -- Código CNS do cartório
                      ||rw_imovel.nrdoc_vendedor    ||';'   -- Número de matrícula do imóvel
                      ||rw_imovel.nmvendor  ||''); -- Data da compra do imóvel
            END IF;

            -- Atualizar o registro enviado na tabela
            BEGIN
              UPDATE tbepr_imovel_alienado imv
                 SET imv.dtmvtolt   = trunc(SYSDATE)
                   , imv.cdoperad   = pr_cdoperad
                   , imv.flgenvia   = 0 -- desmarcar a flag de envio
                   , imv.cdsituacao = 1 -- marcado como em processamento
                   , imv.tpinclusao = DECODE(rw_imovel.tpoperacao,'A', imv.tpinclusao, 'A') -- marca a inclusão como automática quando não for alteração
                   , imv.dtinclusao = DECODE(rw_imovel.tpoperacao,'A', imv.dtinclusao, BTCH0001.rw_crapdat.dtmvtolt)
               WHERE ROWID = rw_imovel.dsrowid;
            EXCEPTION
              WHEN OTHERS THEN
                pr_dscritic := 'Erro ao atualizar tabela do imóvel: '||SQLERRM;
                RAISE vr_exc_saida; -- encerra execução
            END;
            
            -- Registrar o log de envio das informações
            GENE0001.pc_gera_log(pr_cdcooper => rw_coop.cdcooper
                                ,pr_cdoperad => pr_cdoperad
                                ,pr_dscritic => ' '
                                ,pr_dsorigem => gene0001.vr_vet_des_origens(1)
                                ,pr_dstransa => 'Envio de registro a Cetip. Contrato: '||rw_operac.nrctremp
                                                ||' - Seq. Bem: '||rw_imovel.idseqbem||' - Lote: '||vr_nrlote||'.'
                                ,pr_dttransa => SYSDATE
                                ,pr_flgtrans => 1
                                ,pr_hrtransa => GENE0002.fn_busca_time
                                ,pr_idseqttl => 1
                                ,pr_nmdatela => 'IMOVEL'
                                ,pr_nrdconta => rw_operac.nrdconta
                                ,pr_nrdrowid => vr_rowidlog);
            
          END LOOP; -- Fim loop IMOVEL
          
        END LOOP; -- Fim loop OPERAÇÃO DE CRÉDITO  
      END IF; -- IF pr_intiparq IN ('I','T') 

      -- Se for para mandar arquivo com BAIXA ou todos
      IF pr_intiparq IN ('B','T') THEN
        -- Buscar todos os imóveis que devem ser baixados
        FOR reg_liquid IN cr_liquidado(rw_coop.cdcooper, BTCH0001.rw_crapdat.dtultdma) LOOP
          
          IF vr_flgcoop THEN
            -- Adiciona linha do CREDOR
            add_linha('C;'||rw_coop.nrdocnpj||'');
              
            -- Setar para não imprimir
            vr_flgcoop := FALSE;
          END IF;
        
          -- Buscar o código da modalidade do BACEN
          vr_cdmodali := fn_busca_modalidade_bacen(pr_cdmodali => reg_liquid.cdmodali||reg_liquid.cdsubmod
                                                  ,pr_cdcooper => rw_coop.cdcooper
                                                  ,pr_nrdconta => reg_liquid.nrdconta
                                                  ,pr_nrctremp => reg_liquid.nrctremp
                                                  ,pr_inpessoa => reg_liquid.inpessoa
                                                  ,pr_cdorigem => 3 -- Fixo 3 - Empréstimo
                                                  ,pr_dsinfaux => '');
        
          -- Formar o código do SCR conforme o 3040
          vr_nrdoscr := LPAD(rw_coop.cdcooper,5,'0')  ||
                        LPAD(reg_liquid.nrdconta,15,'0') ||
                        LPAD(reg_liquid.nrctremp,15,'0') ||
                        LPAD(vr_cdmodali,5,'0');
        
          -- Adicionar a linha referente à OPERAÇÃO DE CRÉDITO
          add_linha(  'O;'                        -- Tipo de informação
                    ||'Q;'                        -- Tipo da origem das informações - QUITAÇÃO
                    ||rw_coop.nrdocnpj    ||';'   -- CNPJ do Credor
                    ||vr_nrdoscr          ||';'   -- Código do SCR
                    ||reg_liquid.dtliquid ||''); -- Data da liquidação do contrato

          -- Incluir a informação na tabela de controle de envios
          BEGIN 
          
            -- Incrementar a sequencia
            vr_nrseqlote := vr_nrseqlote + 1;  
          
            -- Insere o registro de envio
            INSERT INTO tbepr_envio_cetip(cdcooper
                                         ,nrdconta
                                         ,nrctrpro
                                         ,idseqbem
                                         ,nrdolote
                                         ,tpoperacao
                                         ,dtenvio
                                         ,dtretorno
                                         ,cdretorno
                                         ,nrreg_cetip
                                         ,nrlinhaarquivo
                                         ,nrseqlote
                                         ,nrscr_cetip)
                                  VALUES (rw_coop.cdcooper    -- cdcooper
                                         ,reg_liquid.nrdconta -- nrdconta
                                         ,reg_liquid.nrctremp -- nrctrpro
                                         ,reg_liquid.idseqbem -- idseqbem
                                         ,vr_nrlote           -- nrdolote
                                         ,'B'                 -- tpoperacao
                                         ,trunc(SYSDATE)      -- dtenvio
                                         ,NULL                -- dtretorno
                                         ,NULL                -- cdretorno
                                         ,NULL                -- nrreg_cetip
                                         ,vr_indexlinha       -- nrlinhaarquivo
                                         ,vr_nrseqlote        -- nrseqlote
                                         ,vr_nrdoscr );       -- nrscr_cetip
          EXCEPTION
            WHEN OTHERS THEN
              pr_dscritic := 'Erro ao registrar envio: '||SQLERRM;
              RAISE vr_exc_saida; -- encerra execução
          END; 
          
          -- Atualizar o registro enviado na tabela
          BEGIN
            UPDATE tbepr_imovel_alienado imv
               SET imv.dtmvtolt   = trunc(SYSDATE)
                 , imv.cdoperad   = pr_cdoperad
                 , imv.flgenvia   = 0 -- desmarcar a flag de envio
                 , imv.cdsituacao = 1 -- marcado como em processamento
                 , imv.tpbaixa    = 'A' -- marca a inclusão como automática
                 , imv.dtinclusao = BTCH0001.rw_crapdat.dtmvtolt
             WHERE ROWID = reg_liquid.dsrowid;

          EXCEPTION
            WHEN OTHERS THEN
              pr_dscritic := 'Erro na baixa do imóvel: '||SQLERRM;
              RAISE vr_exc_saida; -- encerra execução

          END;

          -- Registrar o log de envio das informações
          GENE0001.pc_gera_log(pr_cdcooper => rw_coop.cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => ' '
                              ,pr_dsorigem => gene0001.vr_vet_des_origens(1)
                              ,pr_dstransa => 'Baixa de registro Cetip. Contrato: '||reg_liquid.nrctremp
                                              ||' - Seq. Bem: '||reg_liquid.idseqbem||' - Lote: '||vr_nrlote||'.'
                              ,pr_dttransa => SYSDATE
                              ,pr_flgtrans => 1
                              ,pr_hrtransa => GENE0002.fn_busca_time
                              ,pr_idseqttl => 1
                              ,pr_nmdatela => 'IMOVEL'
                              ,pr_nrdconta => reg_liquid.nrdconta
                              ,pr_nrdrowid => vr_rowidlog);
          
        END LOOP; -- Fim loop Liquidados
      END IF; -- IF pr_intiparq IN ('B','T') 
    END LOOP; -- Fim loop CREDOR - Cooperativas
    
    -- Se não tem dados deve retornar mensagem de erro
    IF vr_tablinhas.COUNT() = 0 THEN
      pr_dscritic := 'Nenhum dado foi encontrado. Arquivo nao gerado!';
      RAISE vr_exc_saida;
    END IF;

    -- 
    -- Inicializar o CLOB
    vr_dsarquiv := NULL;
    dbms_lob.createtemporary(vr_dsarquiv, TRUE);
    dbms_lob.open(vr_dsarquiv, dbms_lob.lob_readwrite);
    
    -- Percorre todas as linhas geradas
    FOR ind IN vr_tablinhas.FIRST..vr_tablinhas.LAST LOOP
      
      vr_texto := vr_tablinhas(ind);
    
      -- Se não for a ultima posição
      IF ind <> vr_tablinhas.LAST THEN
        -- concatena a quebra de linha
        vr_texto := vr_texto || chr(10);
      
      END IF;
      
      -- Escreve a linha no lob
      dbms_lob.writeappend(vr_dsarquiv,length(vr_texto),vr_texto);
    END LOOP;
          
    -- Solicitar geracao do arquivo TEMPORARIO fisico
    GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => 3 -- Gerar sempre CECRED  --> Cooperativa conectada
                                       ,pr_cdprogra  => 'IMOVEL'                  --> Programa chamador
                                       ,pr_dtmvtolt  => SYSDATE                   --> Data do movimento atual
                                       ,pr_dsxml     => vr_dsarquiv               --> Arquivo XML de dados
                                       ,pr_dsarqsaid => vr_dsdiretorio||'TMP_'||vr_dsnomearq --> Path/Nome do arquivo PDF gerado
                                       ,pr_flg_impri => 'N'                       --> Chamar a impressão (Imprim.p)
                                       ,pr_flg_gerar => 'S'                       --> Gerar o arquivo na hora
                                       ,pr_flgremarq => 'N'                       --> remover arquivo apos geracao
                                       ,pr_nrcopias  => 1                         --> Número de cópias para impressão
                                       ,pr_dspathcop => NULL                      --> Lista sep. por ';' de diretórios a copiar o arquivo
                                       ,pr_dsmailcop => NULL                      --> Lista sep. por ';' de emails para envio do arquivo
                                       ,pr_dsassmail => NULL                      --> Assunto do e-mail que enviará o arquivo
                                       ,pr_dscormail => NULL                      --> HTML corpo do email que enviará o arquivo
                                       ,pr_flappend  => 'N'
                                       ,pr_des_erro  => vr_dscritic);             --> Retorno de Erro
    
    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_dsarquiv);
    dbms_lob.freetemporary(vr_dsarquiv); 
  
    -- Verifica a ocorrencia de erro ao gerar o arquivo
    IF vr_dscritic IS NOT NULL THEN
      pr_dscritic := vr_dscritic;
      RAISE vr_exc_saida;
    END IF;
  
    -- Executa comando UNIX para converter arq para Dos
    vr_dscomand := 'ux2dos ' || vr_dsdiretorio||'TMP_'||vr_dsnomearq||' > '
                             || vr_dsdiretorio||vr_dsnomearq || ' 2>/dev/null';
    
    -- Para cada caminho, executar o comando montado acima
    gene0001.pc_OScommand_Shell(pr_des_comando => vr_dscomand
                               ,pr_typ_saida   => vr_typ_said
                               ,pr_des_saida   => pr_dscritic);
    -- Testar erro
    IF vr_typ_said = 'ERR' THEN
      pr_dscritic := 'Erro ao converter arquivo: '||pr_dscritic;
      RAISE vr_exc_saida;
    END IF;
    
    -- Executa comando UNIX para REMOVER o arquivo temporário gerado
    vr_dscomand := 'rm ' || vr_dsdiretorio||'TMP_'||vr_dsnomearq;
    
    -- Para cada caminho, executar o comando montado acima
    gene0001.pc_OScommand_Shell(pr_des_comando => vr_dscomand
                               ,pr_typ_saida   => vr_typ_said
                               ,pr_des_saida   => pr_dscritic);
    
    -- Testar erro
    IF vr_typ_said = 'ERR' THEN
      pr_dscritic := 'Erro ao remover arquivo temporario: '||pr_dscritic;
      RAISE vr_exc_saida;
    END IF;    
    
    -- Finaliza com status de sucesso
    pr_des_erro := 'OK';
    
    COMMIT; -- Registra na base as informações
  
  EXCEPTION
    WHEN vr_exc_saida THEN
      
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' ||
                                     pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro geral pc_gerar_arquivo_cetip: ' || SQLERRM;
      
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' ||
                                     pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_gerar_arquivo_cetip;
  
  -- REALIZAR A LEITURA DOS ARQUIVOS DE RETORNO DO CETIP
  PROCEDURE pc_leitura_arquivo_cetip(pr_cdoperad IN VARCHAR2              --> Código do operador
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS         --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_leitura_arquivo_cetip
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Renato Darosci/SUPERO
    Data    : Julho/2016                       Ultima atualizacao: 12/09/2017

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para realizar a leitura do arquivo de processamento do Cetip

    Alteracoes: 12/09/2017 - Decorrente a inclusão de novo parâmetro na rotina pc_abre_arquivo,
                             foi ncessário ajuste para mencionar os parâmetros no momento da chamada
                            (Adriano - SD 734960 ).
    ............................................................................. */
    -- Buscar todas as cooperativas ou a cooperativa selecionada na tela
    CURSOR cr_crapcop IS
      SELECT cop.cdcooper
           , cop.nrdocnpj
           , dat.dtmvtolt
        FROM crapdat dat
           , crapcop cop
       WHERE dat.cdcooper = cop.cdcooper;
        
    -- Buscar o registro do envio das informações ao CETIP
    CURSOR cr_envio(pr_cdcooper        tbepr_envio_cetip.cdcooper%TYPE
                   ,pr_nrseqlote       tbepr_envio_cetip.nrseqlote%TYPE
                   ,pr_nrlinhaarquivo  tbepr_envio_cetip.nrlinhaarquivo%TYPE
                   ,pr_nrscr_cetip     VARCHAR2 ) IS -- tbepr_envio_cetip.nrscr_cetip%TYPE ) IS
      SELECT env.rowid      dsrowid
           , env.cdcooper
           , env.nrdconta
           , env.nrctrpro
           , env.idseqbem
           , env.tpoperacao
           , env.cdretorno
           , env.nrreg_cetip
        FROM tbepr_envio_cetip env
       WHERE env.cdcooper       = pr_cdcooper
         AND env.nrseqlote      = pr_nrseqlote
         AND env.nrlinhaarquivo = pr_nrlinhaarquivo
         AND env.nrscr_cetip    = pr_nrscr_cetip
         AND env.dtretorno IS NULL;  -- Não deve ter recebido retorno ainda
    rw_envio   cr_envio%ROWTYPE;
      
    TYPE tab_cooper IS TABLE OF cr_crapcop%ROWTYPE INDEX BY VARCHAR2(25);
    vr_tabcooper        tab_cooper;
    -- Tabela de memória para as linhas do arquivo
    TYPE tab_linha_arquivo IS TABLE OF VARCHAR2(500) INDEX BY BINARY_INTEGER;
    vr_tabarquivo       tab_linha_arquivo;
    -- PL/Table que vai armazenar os nomes de arquivos a serem processados
    vr_tab_arqtmp       gene0002.typ_split;
    -- Pl/table para armazenar separadamente cada campo da linha retornada no arquivo
    vr_tab_dados        gene0002.typ_split;
    
    -- VARIÁVEIS
    vr_dsdiretorio      VARCHAR2(100);      --> Local onde esta os arquivos Sicoob
    vr_listaarq         VARCHAR2(4000);     --> Lista de arquivos
    vr_arquivo          utl_file.file_type; --> arquivo que sera trabalhado
    vr_textolinha       VARCHAR2(500);      --> Linha lida do arquivo
    vr_nrdolote         NUMBER;             --> Número do LOTE que será extraído do nome do arquivo
    vr_cdsituacao       NUMBER;
    vr_flgenvia         NUMBER;
    vr_dstralog         craplog.dstransa%TYPE;
    vr_rowidlog         VARCHAR2(20);
        
    -- CNPJ do credor
    vr_nrdocnpj         NUMBER;
    -- Código do SCR
    vr_dscsrcetip       VARCHAR2(40);
    -- Número da operação gerado no CETIP
    vr_nrreg_cetip      NUMBER;
    -- Número da linha do arquivo enviado
    vr_nrlinha_arq      NUMBER;
    -- Código de retorno 
    vr_cdretorno        NUMBER;
    
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    
  BEGIN
    
    -- Buscar todas as cooperativas e classificar no array por cnpj
    FOR rw_crapcop IN cr_crapcop LOOP
      vr_tabcooper(rw_crapcop.nrdocnpj).cdcooper := rw_crapcop.cdcooper;
      vr_tabcooper(rw_crapcop.nrdocnpj).nrdocnpj := rw_crapcop.nrdocnpj;
      vr_tabcooper(rw_crapcop.nrdocnpj).dtmvtolt := rw_crapcop.dtmvtolt;
    END LOOP;
   
    -- Busca o diretorio onde esta os arquivos CETIP
    vr_dsdiretorio := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                pr_cdacesso => 'RETORNO_CETIP');

    -- Listar arquivos
    gene0001.pc_lista_arquivos( pr_path     => vr_dsdiretorio
                               ,pr_pesq     => '%.txt'
                               ,pr_listarq  => vr_listaarq
                               ,pr_des_erro => pr_dscritic);
    -- Se ocorreu erro, cancela o programa
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    -- Se possuir arquivos para serem processados
    IF vr_listaarq IS NOT NULL THEN

      --Carregar a lista de arquivos txt na pl/table
      vr_tab_arqtmp := gene0002.fn_quebra_string(pr_string => vr_listaarq);
      
      -- Leitura da PL/Table e processamento dos arquivos
      FOR ind_arq IN vr_tab_arqtmp.first()..vr_tab_arqtmp.last() LOOP
        
        -- Limpar a tabela de linhas do arquivo
        vr_tabarquivo.DELETE();
        
        -- Extrair o número do lote do nome do arquivo
        vr_nrdolote := TO_NUMBER(SUBSTR(vr_tab_arqtmp(ind_arq), INSTR(vr_tab_arqtmp(ind_arq),'_')+5, 7));
        
        -- Abrir o arquivo
        gene0001.pc_abre_arquivo(pr_nmdireto => vr_dsdiretorio,
                                 pr_nmarquiv => vr_tab_arqtmp(ind_arq),
                                 pr_tipabert => 'R',
                                 pr_utlfileh => vr_arquivo,
                                 pr_des_erro => pr_dscritic);
        
        IF pr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        
        -- Efetua o loop para todas as linhas do arquivo
        LOOP
          -- Leitura das linhas do arquivo
          BEGIN
            gene0001.pc_le_linha_arquivo(vr_arquivo, vr_textolinha);
            
            -- Se a linha não estiver nula (evitando linhas em branco)
            IF TRIM(vr_textolinha) IS NOT NULL THEN
              -- Adiciona a linha na tabela de memória
              vr_tabarquivo(vr_tabarquivo.COUNT()+1) := TRIM(vr_textolinha);
            END IF;
            
          EXCEPTION
            WHEN no_data_found THEN
              -- Terminou o arquivo, deve sair do loop
              EXIT;
          END;
          
        END LOOP;
        
        -- Fechar o arquivo
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_arquivo);
        
        /****** PROCESSAR TODOS OS DADOS DO ARQUIVO ******/
        -- percorrer todas as linhas lidas no arquivo de retorno
        FOR ind_linha IN vr_tabarquivo.first()..vr_tabarquivo.last() LOOP
          
          -- quebrar a linha por ponto-e-vírgula
          vr_tab_dados := gene0002.fn_quebra_string(pr_string => vr_tabarquivo(ind_linha),pr_delimit => ';');
        
          -- CNPJ do credor
          vr_nrdocnpj    := TO_NUMBER(vr_tab_dados(1));
          -- Código do SCR
          vr_dscsrcetip  := vr_tab_dados(2);
          -- Número da operação gerado no CETIP
          vr_nrreg_cetip := TO_NUMBER(vr_tab_dados(3));
          -- Número da linha do arquivo enviado
          vr_nrlinha_arq := TO_NUMBER(vr_tab_dados(4));
          -- Código de retorno 
          vr_cdretorno   := TO_NUMBER(vr_tab_dados(5));
          
          -- Verificar se consegue encontrar a cooperativa
          IF NOT vr_tabcooper.EXISTS(vr_nrdocnpj) THEN
            pr_dscritic := 'Cooperativa do arquivo nao encontrada(Linha: '||ind_linha||'). Verifique!';
            RAISE vr_exc_saida;
          END IF;

          -- Buscar o registro de envio, conforme o SCR, Lote e número da linha
          OPEN  cr_envio(vr_tabcooper(vr_nrdocnpj).cdcooper  -- pr_cdcooper      
                        ,vr_nrdolote                -- pr_nrseqlote     
                        ,vr_nrlinha_arq             -- pr_nrlinhaarquivo
                        ,vr_dscsrcetip);            -- pr_nrscr_cetip   
          FETCH cr_envio INTO rw_envio;
          
          -- Se não encontrar registro
          IF cr_envio%NOTFOUND THEN
            -- Fechar o cursor
            CLOSE cr_envio;
            -- Retornar mensagem de erro
            pr_dscritic := 'Registro de envio nao encontrado(Linha: '||ind_linha||'). Verifique!';
            RAISE vr_exc_saida;
          END IF;
          
          -- Fechar o cursor
          CLOSE cr_envio;
          
          -- Atualizar o registro do envio 
          BEGIN
            UPDATE tbepr_envio_cetip env
               SET env.cdretorno   = vr_cdretorno
                 , env.nrreg_cetip = vr_nrreg_cetip
                 , env.dtretorno   = trunc(SYSDATE)
             WHERE ROWID = rw_envio.dsrowid;
          EXCEPTION
            WHEN OTHERS THEN
              pr_dscritic := 'Erro ao atualizar envio(Linha: '||ind_linha||'): '||SQLERRM; 
              RAISE vr_exc_saida;
          END;
          
          -- Limpar/inicializar as variáveis
          vr_flgenvia   := 0;
          vr_dstralog   := NULL;
          
          -- Se a operação for de inclusão e o retorno foi 5 - Inclusão com sucesso
          IF rw_envio.tpoperacao = 'I' AND vr_cdretorno = 5 THEN
            vr_cdsituacao := 2;
            
            -- Montar a mensagem do Log            
            vr_dstralog := 'Retorno da inclusão na Cetip. Cód. Registro gerado: '||vr_nrreg_cetip||' - Lote: '||vr_nrdolote||'.';

          -- Se a operação for de alteração e o retorno foi 8 - Atualização com sucesso
          ELSIF rw_envio.tpoperacao = 'A' AND vr_cdretorno = 8 THEN
            vr_cdsituacao  := 2; -- Irá retornar a situação para 2
            vr_nrreg_cetip := NULL; -- não irá alterar valor
            
            -- Montar a mensagem do Log            
            vr_dstralog := 'Retorno da alteração na Cetip. Lote: '||vr_nrdolote||'.';

          -- Se a operação for de baixa e o retorno foi 9 - Quitação com sucesso
          ELSIF rw_envio.tpoperacao = 'B' AND vr_cdretorno = 9 THEN
            vr_cdsituacao  := 4;
            vr_nrreg_cetip := NULL;-- não irá alterar valor
            
            -- Montar a mensagem do Log            
            vr_dstralog := 'Retorno da baixa na Cetip. Lote: '||vr_nrdolote||'.';
            
          ELSIF vr_cdretorno NOT IN (5,8,9) THEN --  se não se enquadrar em nenhum retorno ok, é critica
            -- Se for retorno de uma baixa....
            IF rw_envio.tpoperacao = 'B' THEN
              
              -- Situação 5 - indicando critica na baixa
              vr_cdsituacao  := 5;
              
              -- Montar a mensagem do Log            
              vr_dstralog := 'Retorno critica ['||vr_cdretorno||'] da baixa na Cetip. Lote: '||vr_nrdolote||'.';
            
            ELSE
              
              -- Situação 3 - indicando critica na Inclusão ou alteração
              vr_cdsituacao  := 3;
              
              IF rw_envio.tpoperacao = 'I' THEN
                -- Montar a mensagem do Log            
                vr_dstralog := 'Retorno critica ['||vr_cdretorno||'] da inclusao na Cetip. Lote: '||vr_nrdolote||'.';
              ELSIF rw_envio.tpoperacao = 'A' THEN
                -- Montar a mensagem do Log            
                vr_dstralog := 'Retorno critica ['||vr_cdretorno||'] da alteracao na Cetip. Lote: '||vr_nrdolote||'.';
              END IF;
            
            END IF;
            
            -- não irá alterar valor de registro da cetip
            vr_nrreg_cetip := NULL;
            -- Quando for crítica deve marcar para reenvio
            vr_flgenvia    := 1;    
          
          ELSE
            -- ATENÇÃO:
            -- Caso haja o retorno dos códigos 5, 8 ou 9, porém não condizendo com a operação 
            -- enviada, deve retornar uma mensagem solicitando verificação!!!
            -- Por exemplo... quando enviado uma alteração, mas o retorno for 9 - Quitação com sucesso
            -- Ou quando enviado uma inclusão, mas o retorno for 8 - Alteração com sucesso. Esses casos
            -- devem ser verificados de forma mais pontual.
            pr_dscritic := 'Codigo de retorno invalido (Linha: '||ind_linha||'). Verificar!'; 
            RAISE vr_exc_saida;
          END IF;
          
          -- Atualizar o registro do IMOVEL
          BEGIN
            UPDATE tbepr_imovel_alienado  imv
               SET imv.dtmvtolt    = trunc(SYSDATE)
                 , imv.cdoperad    = pr_cdoperad
                 , imv.cdsituacao  = NVL(vr_cdsituacao , imv.cdsituacao)
                 , imv.nrreg_cetip = NVL(vr_nrreg_cetip, imv.nrreg_cetip)
                 , imv.dtinclusao  = DECODE(vr_cdsituacao, 3, NULL, imv.dtinclusao)
                 , imv.dtbaixa     = DECODE(vr_cdsituacao, 5, NULL, imv.dtbaixa)
                 , imv.flgenvia    = vr_flgenvia 
             WHERE cdcooper = rw_envio.cdcooper
               AND nrdconta = rw_envio.nrdconta
               AND nrctrpro = rw_envio.nrctrpro
               AND idseqbem = rw_envio.idseqbem;
             
          EXCEPTION
            WHEN OTHERS THEN
              pr_dscritic := 'Erro ao atualizar imovel(Linha: '||ind_linha||'): '||SQLERRM; 
              RAISE vr_exc_saida;
          END;      
          
          -- REGISTRAR O LOG DO RETORNO
          GENE0001.pc_gera_log(pr_cdcooper => rw_envio.cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => ' '
                              ,pr_dsorigem => gene0001.vr_vet_des_origens(1)
                              ,pr_dstransa => vr_dstralog
                              ,pr_dttransa => SYSDATE
                              ,pr_flgtrans => 1
                              ,pr_hrtransa => GENE0002.fn_busca_time
                              ,pr_idseqttl => 1
                              ,pr_nmdatela => 'IMOVEL'
                              ,pr_nrdconta => rw_envio.nrdconta
                              ,pr_nrdrowid => vr_rowidlog);
          
        END LOOP; -- Loop das linhas do arquivo
        
        -- Mover o arquivo do diretorio arq para o salvar
        gene0001.pc_oscommand_shell(pr_des_comando => 'mv '||vr_dsdiretorio||vr_tab_arqtmp(ind_arq)||' '||vr_dsdiretorio||'processados/'||vr_tab_arqtmp(ind_arq)||' 2> /dev/null');
        
        -- Efetivar os dados a cada arquivo
        COMMIT; 
        
      END LOOP; -- Loop dos arquivos
      
    ELSE 
      pr_dscritic := 'Nenhum arquivo encontrado para processamento!';
      RAISE vr_exc_saida;
    END IF;
    
    -- Efetivar os dados
    COMMIT; 
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' ||
                                     pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro geral pc_gerar_arquivo_cetip: ' || SQLERRM;
      
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' ||
                                     pr_dscritic || '</Erro></Root>');
      ROLLBACK;  
  END pc_leitura_arquivo_cetip;



  
END TELA_IMOVEL;
/
