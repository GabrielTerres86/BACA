CREATE OR REPLACE PACKAGE CECRED.TELA_ATENDA_COBRAN IS

  PROCEDURE pc_busca_apuracao(pr_nrdconta  IN crapceb.nrdconta%TYPE --> Conta
                             ,pr_nrconven  IN crapceb.nrconven%TYPE --> Convenio
                             ,pr_nrcnvceb  IN crapceb.nrcnvceb%TYPE --> Convenio CECRED
                             ,pr_xmllog    IN VARCHAR2 --> XML com informacoes de LOG
                             ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                             ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                             ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_exclui_convenio(pr_nrdconta  IN crapceb.nrdconta%TYPE --> Conta
                              ,pr_nrconven  IN crapceb.nrconven%TYPE --> Convenio
                              ,pr_nrcnvceb  IN crapceb.nrcnvceb%TYPE --> Convenio CECRED
                              ,pr_xmllog    IN VARCHAR2 --> XML com informacoes de LOG
                              ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                              ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                              ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_valida_habilitacao(pr_nrdconta  IN crapceb.nrdconta%TYPE --> Conta
                                 ,pr_nrconven  IN crapceb.nrconven%TYPE --> Convenio
                                 ,pr_xmllog    IN VARCHAR2 --> XML com informacoes de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                 ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                 ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_valida_dados_limite(pr_nrdconta  IN crapceb.nrdconta%TYPE --> Conta
                                  ,pr_dsorgarq  IN crapcco.dsorgarq%TYPE --> Origem Arquivo
                                  ,pr_inarqcbr  IN crapceb.inarqcbr%TYPE --> Recebe Arquivo de Retorno de Cobranca
                                  ,pr_cddemail  IN crapceb.cddemail%TYPE --> Email Arquivo de Retorno de Cobranca
                                  ,pr_idseqttl  IN crapcem.idseqttl%TYPE --> Sequencia do titular
                                  ,pr_xmllog    IN VARCHAR2 --> XML com informacoes de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                  ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                  ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_habilita_convenio(pr_nrdconta  IN crapceb.nrdconta%TYPE --> Conta
                                ,pr_nrconven  IN crapceb.nrconven%TYPE --> Convenio
                                ,pr_insitceb  IN crapceb.insitceb%TYPE --> Situacao do Convenio
                                ,pr_inarqcbr  IN crapceb.inarqcbr%TYPE --> Recebe Arquivo Retorno
                                ,pr_cddemail  IN crapceb.cddemail%TYPE --> Email Arquivo de Retorno
                                ,pr_flgcruni  IN crapceb.flgcruni%TYPE --> Credito Unificado
                                ,pr_flgcebhm  IN crapceb.flgcebhm%TYPE --> Contem o convenio homologado
                                ,pr_idseqttl  IN crapttl.idseqttl%TYPE --> Sequencia Titular
                                ,pr_flgregon  IN crapceb.flgregon%TYPE --> Flag de registro de titulo online (0-Nao/1-Sim)
                                ,pr_flgpgdiv  IN crapceb.flgpgdiv%TYPE --> Flag de autorizacao de pagamento divergente (0-Nao/ 1-Sim)
                                ,pr_flcooexp  IN crapceb.flcooexp%TYPE --> Cooperado Emite e Expede Boletos
                                ,pr_flceeexp  IN crapceb.flceeexp%TYPE --> Cooperativa Emite e Expede Boletos
                                ,pr_flserasa  IN crapceb.flserasa%TYPE --> Pode negativar no Serasa
                                ,pr_qtdfloat  IN crapceb.qtdfloat%TYPE --> Quantidade de dias para o Float
                                ,pr_flprotes  IN crapceb.flprotes%TYPE --> Liberacao da opcao de Protesto na Cobranca
                                ,pr_qtdecprz  IN crapceb.qtdecprz%TYPE --> Quantidade de dias para Decurso de Prazo
                                ,pr_idrecipr  IN crapceb.idrecipr%TYPE --> ID unico do calculo de reciprocidade atrelado a contratacao
                                ,pr_idreciprold IN crapceb.idrecipr%TYPE --> ID unico do calculo de reciprocidade atrelado a contratacao
                                ,pr_perdesconto IN VARCHAR2 --> Categoria e valor do desconto
																,pr_inenvcob  IN crapceb.inenvcob%TYPE --> Forma de envio de arquivo de cobrança																
                                ,pr_xmllog    IN VARCHAR2 --> XML com informacoes de LOG
                                ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_busca_config_conv(pr_nrconven  IN crapcco.nrconven%TYPE --> Convenio
                                ,pr_xmllog    IN VARCHAR2 --> XML com informacoes de LOG
                                ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_busca_categoria(pr_nrdconta  IN crapass.nrdconta%TYPE --> Conta
                              ,pr_nrconven  IN crapcco.nrconven%TYPE --> Convenio
                              ,pr_xmllog    IN VARCHAR2 --> XML com informacoes de LOG
                              ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                              ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                              ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_busca_tarifa(pr_nrconven  IN crapceb.nrconven%TYPE --> Convenio
                           ,pr_cdcatego  IN crapcat.cdcatego%TYPE --> Convenio
                           ,pr_inpessoa  IN craptar.inpessoa%TYPE --> Tipo de pessoa
                           ,pr_xmllog    IN VARCHAR2 --> XML com informacoes de LOG
                           ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                           ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                           ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_verifica_apuracao(pr_nrdconta  IN crapceb.nrdconta%TYPE --> Conta
                                ,pr_nrconven  IN crapceb.nrconven%TYPE --> Convenio
                                ,pr_xmllog    IN VARCHAR2 --> XML com informacoes de LOG
                                ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_gera_arq_ajuda(pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                             ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2             --Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2);           --Erros do processo

  --> Rotina para ativar convenio
  PROCEDURE pc_ativar_convenio( pr_nrdconta  IN crapceb.nrdconta%TYPE --> Conta
                               ,pr_nrconven  IN crapceb.nrconven%TYPE --> Convenio
                               ,pr_nrcnvceb  IN crapceb.nrcnvceb%TYPE --> Ceb
                               ,pr_xmllog    IN VARCHAR2              --> XML com informacoes de LOG
                               ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                               ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                               ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2);            --> Erros do processo

  --> Retornar lista com os log do convenio ceb
  PROCEDURE pc_consulta_log_conv_web(pr_nrdconta IN crawepr.nrdconta%TYPE --> Nr. da Conta
                                    ,pr_nrconven IN crapceb.nrconven%TYPE --> Nr. do convenio
                                    ,pr_nrcnvceb IN crapceb.nrcnvceb%TYPE --> Nr. do ceb
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);           --> Erros do processo                               

  --> Rotina para cancelar os boletos
  PROCEDURE pc_cancela_boletos(pr_cdcooper IN crapceb.cdcooper%TYPE --> Codigo da cooperativa
                              ,pr_nrdconta IN crapceb.nrdconta%TYPE --> Conta
                              ,pr_nrconven IN crapceb.nrconven%TYPE --> Convenio
                              ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2);           --> Erros do processo   

  --> Rotina para sustar os boletos
  PROCEDURE pc_susta_boletos(pr_cdcooper IN crapceb.cdcooper%TYPE --> Codigo da cooperativa
                            ,pr_nrdconta IN crapceb.nrdconta%TYPE --> Conta
                            ,pr_nrconven IN crapceb.nrconven%TYPE --> Convenio
                            ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                            ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2);           --> Erros do processo   

END TELA_ATENDA_COBRAN;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_ATENDA_COBRAN IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_ATENDA_COBRAN
  --  Sistema  : Ayllos Web
  --  Autor    : Jaison Fernando
  --  Data     : Fevereiro - 2016                 Ultima atualizacao: 14/09/2016
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas relacionadas a tela Cobranca dentro da ATENDA
  --
  -- Alteracoes: 04/08/2016 - Adicionado parametro pr_inenvcob na procedure 
  -- 						  pc_habilita_convenio (Reinert).
  --
  --             14/09/2016 - Adicionado validacao de convenio ativo na procedure
  --                          pc_habilita_convenio (Douglas - Chamado 502770)
  -- 
  --             25/11/2016 - Alterado cursor cr_crapope, para ler o departamento
  --                          do operador a partir da tabela CRAPDPO. O setor de 
  --                          COBRANCA foi removido da validação, pois o mesmo não 
  --                          existe na CRAPDPO (Renato Darosci - Supero)
  ---------------------------------------------------------------------------


  PROCEDURE pc_busca_apuracao(pr_nrdconta  IN crapceb.nrdconta%TYPE --> Conta
                             ,pr_nrconven  IN crapceb.nrconven%TYPE --> Convenio
                             ,pr_nrcnvceb  IN crapceb.nrcnvceb%TYPE --> Convenio CECRED
                             ,pr_xmllog    IN VARCHAR2 --> XML com informacoes de LOG
                             ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                             ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                             ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_busca_apuracao
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Fevereiro/2016                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para alertar em caso de periodo de apuracao de reciprocidade em aberto.

    Alteracoes: 
    ..............................................................................*/

    DECLARE

      -- Verifica se possui reciprocidade
      CURSOR cr_crapceb(pr_cdcooper IN crapceb.cdcooper%TYPE
                       ,pr_nrdconta IN crapceb.nrdconta%TYPE
                       ,pr_nrconven IN crapceb.nrconven%TYPE
                       ,pr_nrcnvceb IN crapceb.nrcnvceb%TYPE) IS
        SELECT NVL(crapceb.idrecipr,0)
          FROM crapceb 
         WHERE crapceb.cdcooper = pr_cdcooper
           AND crapceb.nrdconta = pr_nrdconta
           AND crapceb.nrconven = pr_nrconven
           AND crapceb.nrcnvceb = pr_nrcnvceb;


      -- Verifica se possui apuracao em aberto
      CURSOR cr_apuracao(pr_cdcooper IN crapceb.cdcooper%TYPE
                        ,pr_nrdconta IN crapceb.nrdconta%TYPE
                        ,pr_nrconven IN crapceb.nrconven%TYPE) IS
        SELECT COUNT(1)
          FROM tbrecip_apuracao apr
         WHERE indsituacao_apuracao = 'A' -- Em apuracao
           AND apr.cdcooper         = pr_cdcooper
           AND apr.nrdconta         = pr_nrdconta
           AND apr.cdchave_produto  = pr_nrconven
           AND apr.cdproduto        = 6; -- Cobranca

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis
      vr_idrecipr crapceb.idrecipr%TYPE;
      vr_qtapurac NUMBER;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

    BEGIN
      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Verifica se possui reciprocidade
      OPEN cr_crapceb(pr_cdcooper => vr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrconven => pr_nrconven
                     ,pr_nrcnvceb => pr_nrcnvceb);
      FETCH cr_crapceb INTO vr_idrecipr;
      -- Fecha cursor
      CLOSE cr_crapceb;

      -- Se possui reciprocidade
      IF vr_idrecipr > 0 THEN

        -- Verifica se possui apuracao em aberto
        OPEN cr_apuracao(pr_cdcooper => vr_cdcooper
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrconven => pr_nrconven);
        FETCH cr_apuracao INTO vr_qtapurac;
        -- Fecha cursor
        CLOSE cr_apuracao;

        -- Se possui apuracao em aberto
        IF vr_qtapurac > 0 THEN
          vr_dscritic := 'Atenção: Existe Reciprocidade em apuração para o convênio, os descontos concedidos não poderão ser revertidos se você cancelar o convênio!';
          RAISE vr_exc_saida;
        END IF;

      END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela TELA_ATENDA_COBRAN: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

    END;


  END pc_busca_apuracao;

  PROCEDURE pc_exclui_convenio(pr_nrdconta  IN crapceb.nrdconta%TYPE --> Conta
                              ,pr_nrconven  IN crapceb.nrconven%TYPE --> Convenio
                              ,pr_nrcnvceb  IN crapceb.nrcnvceb%TYPE --> Convenio CECRED
                              ,pr_xmllog    IN VARCHAR2 --> XML com informacoes de LOG
                              ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                              ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                              ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_exclui_convenio             Antigo: b1wgen0082.p/exclui-convenio
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Fevereiro/2016                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para excluir o convenio.

    Alteracoes: 25/04/2016 - Atualizar convenio na cabine e gerar log cip
                             PRJ318 Plataforma cobrança (Odirlei-AMcom)
                          
    ..............................................................................*/
    DECLARE

      -- Verifica se possui boletos
      CURSOR cr_crapcob(pr_cdcooper IN crapcob.cdcooper%TYPE
                       ,pr_nrdconta IN crapcob.nrdconta%TYPE
                       ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE) IS
        SELECT COUNT(1)
          FROM crapcob 
         WHERE crapcob.cdcooper = pr_cdcooper
           AND crapcob.nrdconta = pr_nrdconta
           AND crapcob.nrcnvcob = pr_nrcnvcob;

      -- Busca o cadastro de convenio
      CURSOR cr_crapcco(pr_cdcooper IN crapcco.cdcooper%TYPE
                       ,pr_nrconven IN crapcco.nrconven%TYPE) IS
        SELECT 1
          FROM crapcco 
         WHERE crapcco.cdcooper = pr_cdcooper
           AND crapcco.nrconven = pr_nrconven;
      rw_crapcco cr_crapcco%ROWTYPE;

      -- Busca o operador
      CURSOR cr_crapope(pr_cdcooper IN crapope.cdcooper%TYPE
                       ,pr_cdoperad IN crapope.cdoperad%TYPE) IS
        SELECT 1
          FROM crapope 
         WHERE crapope.cdcooper = pr_cdcooper
           AND crapope.cdoperad = pr_cdoperad;
      rw_crapope cr_crapope%ROWTYPE;

      --> Busca associado
      CURSOR cr_crapass (pr_cdcooper IN crapcco.cdcooper%TYPE,
                         pr_nrdconta IN crapass.nrdconta%TYPE)IS
        SELECT ass.inpessoa,
               to_char(ass.nrcpfcgc) nrcpfcgc,
               to_char(ass.nrdconta) nrdconta,
               decode(ass.inpessoa,1,lpad(ass.nrcpfcgc,11,'0'),
                                         lpad(ass.nrcpfcgc,14,'0')) dscpfcgc,
               decode(ass.inpessoa,1,'F','J') dspessoa,
               to_char(cop.cdagectl) cdagectl
          FROM crapass ass,
               crapcop cop
         WHERE ass.cdcooper = cop.cdcooper
           AND ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;
      
      -- Cadastro de Bloquetos
      CURSOR cr_crapceb(pr_cdcooper IN crapceb.cdcooper%TYPE
                       ,pr_nrdconta IN crapceb.nrdconta%TYPE
                       ,pr_nrconven IN crapceb.nrconven%TYPE) IS
        SELECT crapceb.insitceb
          FROM crapceb
         WHERE crapceb.cdcooper = pr_cdcooper
           AND crapceb.nrdconta = pr_nrdconta
           AND crapceb.nrconven = pr_nrconven;
      rw_crapceb cr_crapceb%ROWTYPE;
      
      -- Cursor generico de calendario
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;       
      
      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis
      vr_blnfound BOOLEAN;
      vr_qtbolcob NUMBER;
      vr_nrdrowid ROWID;
      vr_dstransa VARCHAR2(1000);
      vr_dtfimrel VARCHAR2(8);
      vr_nrconven VARCHAR2(10);

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

    BEGIN
      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Seta a descricao da transacao
      vr_dstransa := 'Validar cancelamento do convenio de cobranca.';

      -- Verificacao do calendario
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;
      
      -- Verifica se possui boletos
      OPEN cr_crapcob(pr_cdcooper => vr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrcnvcob => pr_nrconven);
      FETCH cr_crapcob INTO vr_qtbolcob;
      -- Fecha cursor
      CLOSE cr_crapcob;
      -- Se possui boletos cadastrados
      IF vr_qtbolcob > 0 THEN
        vr_dscritic := 'Existem boletos cadastrados para este convenio CEB.';
        RAISE vr_exc_saida;
      END IF;

      -- Busca o cadastro de convenio
      OPEN cr_crapcco(pr_cdcooper => vr_cdcooper
                     ,pr_nrconven => pr_nrconven);
      FETCH cr_crapcco INTO rw_crapcco;
      -- Alimenta a booleana se achou ou nao
      vr_blnfound := cr_crapcco%FOUND;
      -- Fecha cursor
      CLOSE cr_crapcco;
      -- Se NAO encontrou
      IF NOT vr_blnfound THEN
        vr_cdcritic := 563;
        RAISE vr_exc_saida;
      END IF;

      -- Busca o operador
      OPEN cr_crapope(pr_cdcooper => vr_cdcooper
                     ,pr_cdoperad => vr_cdoperad);
      FETCH cr_crapope INTO rw_crapope;
      -- Alimenta a booleana se achou ou nao
      vr_blnfound := cr_crapope%FOUND;
      -- Fecha cursor
      CLOSE cr_crapope;
      -- Se NAO encontrou
      IF NOT vr_blnfound THEN
        vr_cdcritic := 67;
        RAISE vr_exc_saida;
      END IF;

      -- Cadastro de bloquetos
      OPEN cr_crapceb(pr_cdcooper => vr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrconven => pr_nrconven);
      FETCH cr_crapceb INTO rw_crapceb;
      CLOSE cr_crapceb;

      -- Seta a descricao da transacao
      vr_dstransa := 'Efetuar o cancelamento do convenio de cobranca.';

      BEGIN
        DELETE tbcobran_categ_tarifa_conven
         WHERE cdcooper = vr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrconven = pr_nrconven;

        DELETE tbrecip_apuracao_indica
         WHERE idapuracao_reciproci IN (SELECT idapuracao_reciproci
                                          FROM tbrecip_apuracao
                                         WHERE cdcooper        = vr_cdcooper
                                           AND nrdconta        = pr_nrdconta
                                           AND cdchave_produto = pr_nrconven
                                           AND cdproduto       = 6); -- Cobranca

        DELETE tbrecip_apuracao
         WHERE cdcooper        = vr_cdcooper
           AND nrdconta        = pr_nrdconta
           AND cdchave_produto = pr_nrconven
           AND cdproduto       = 6; -- Cobranca

        DELETE tbrecip_apuracao_tarifa
         WHERE cdcooper        = vr_cdcooper
           AND nrdconta        = pr_nrdconta
           AND cdchave_produto = pr_nrconven
           AND cdproduto       = 6; -- Cobranca

        DELETE tbcobran_categ_tarifa_conven
         WHERE cdcooper = vr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrconven = pr_nrconven;

        DELETE 
          FROM crapceb
         WHERE cdcooper = vr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrconven = pr_nrconven
           AND nrcnvceb = pr_nrcnvceb;
      EXCEPTION
        WHEN OTHERS THEN
        vr_dscritic := 'Problema ao excluir convenio: ' || SQLERRM;
        RAISE vr_exc_saida;
      END;
      
      -- Gerar informacoes do log
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => ' '
                          ,pr_dsorigem => GENE0001.vr_vet_des_origens(vr_idorigem)
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1 --> TRUE
                          ,pr_hrtransa => GENE0002.fn_busca_time
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'COBRANCA'
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
                          
      -- Gerar informacoes do item
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'nrconven'
                               ,pr_dsdadant => pr_nrconven
                               ,pr_dsdadatu => NULL);
      
      -- Gerar informacoes do item
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'nrcnvceb'
                               ,pr_dsdadant => pr_nrcnvceb
                               ,pr_dsdadatu => NULL);

      --> Busca associado
      OPEN cr_crapass (pr_cdcooper => vr_cdcooper,
                       pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      IF cr_crapass%NOTFOUND THEN
        vr_cdcritic := 9; -- associado nao cadastrado
        CLOSE cr_crapass;
      ELSE
        CLOSE cr_crapass;
      END IF;      
      
      --> Gravar o log de adesao ou bloqueio do convenio
      COBR0008.pc_gera_log_ceb ( pr_idorigem  => vr_idorigem,
                                 pr_cdcooper  => vr_cdcooper,
                                 pr_cdoperad  => vr_cdoperad,
                                 pr_nrdconta  => pr_nrdconta,
                                 pr_nrconven  => pr_nrconven,
                                 pr_insitceb_ant => nvl(rw_crapceb.insitceb,0),
                                 pr_insitceb  => 2, -- 'INATIVO'
                                 pr_dscritic  => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      -- Atualizar convenio na CIP  
      BEGIN      
        vr_dtfimrel := to_char(rw_crapdat.dtmvtolt,'RRRRMMDD');
        vr_nrconven := to_char(pr_nrconven);
        UPDATE cecredleg.TBJDDDABNF_Convenio@jdnpcsql
           SET TBJDDDABNF_Convenio."SitConvBenfcrioPar" = 'E',
               TBJDDDABNF_Convenio."DtFimRelctConv"     = vr_dtfimrel
         WHERE TBJDDDABNF_Convenio."ISPB_IF"            = '05463212'
           AND TBJDDDABNF_Convenio."TpPessoaBenfcrio" = rw_crapass.dspessoa
           AND TBJDDDABNF_Convenio."CNPJ_CPFBenfcrio" = rw_crapass.dscpfcgc
           AND TBJDDDABNF_Convenio."CodCli_Conv"      = vr_nrconven
           AND TBJDDDABNF_Convenio."AgDest"           = rw_crapass.cdagectl
           AND TBJDDDABNF_Convenio."CtDest"           = rw_crapass.nrdconta;
      
      EXCEPTION 
        WHEN OTHERS THEN
          vr_dscritic := 'Nao foi possivel atualizar convenio na CIP: '||SQLERRM;
          RAISE vr_exc_saida;
      END;
      
      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

        -- Gerar informacoes do log
        GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => GENE0001.vr_vet_des_origens(vr_idorigem)
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 0 --> FALSE
                            ,pr_hrtransa => GENE0002.fn_busca_time
                            ,pr_idseqttl => 1
                            ,pr_nmdatela => 'COBRANCA'
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
        COMMIT;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela TELA_ATENDA_COBRAN: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_exclui_convenio;

  PROCEDURE pc_valida_habilitacao(pr_nrdconta  IN crapceb.nrdconta%TYPE --> Conta
                                 ,pr_nrconven  IN crapceb.nrconven%TYPE --> Convenio
                                 ,pr_xmllog    IN VARCHAR2 --> XML com informacoes de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                 ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                 ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_valida_habilitacao          Antigo: b1wgen0082.p/valida-habilitacao
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Fevereiro/2016                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para validar a habilitacao do convenio.

    Alteracoes: 
    ..............................................................................*/
    DECLARE

      -- Busca o cadastro de convenio
      CURSOR cr_crapcco(pr_cdcooper IN crapcco.cdcooper%TYPE
                       ,pr_nrconven IN crapcco.nrconven%TYPE) IS
        SELECT crapcco.flgativo
              ,crapcco.dsorgarq
              ,crapcco.flgregis
              ,crapcco.cddbanco
              ,crapcco.flserasa
          FROM crapcco 
         WHERE crapcco.cdcooper = pr_cdcooper
           AND crapcco.nrconven = pr_nrconven;
      rw_crapcco cr_crapcco%ROWTYPE;

      -- Cadastro de bloquetos
      CURSOR cr_crapceb(pr_cdcooper IN crapceb.cdcooper%TYPE
                       ,pr_nrdconta IN crapceb.nrdconta%TYPE
                       ,pr_nrconven IN crapceb.nrconven%TYPE) IS
        SELECT 1
          FROM crapceb
         WHERE crapceb.cdcooper = pr_cdcooper
           AND crapceb.nrdconta = pr_nrdconta
           AND crapceb.nrconven = pr_nrconven;
      rw_crapceb cr_crapceb%ROWTYPE;

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis
      vr_blnfound BOOLEAN;
      vr_nrdrowid ROWID;
      vr_dstransa VARCHAR2(1000);
      vr_flgregis VARCHAR2(3);

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

    BEGIN
      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Seta a descricao da transacao
      vr_dstransa := 'Validar habilitacao de cadastro de cobranca.';

      -- Busca o cadastro de convenio
      OPEN cr_crapcco(pr_cdcooper => vr_cdcooper
                     ,pr_nrconven => pr_nrconven);
      FETCH cr_crapcco INTO rw_crapcco;
      -- Alimenta a booleana se achou ou nao
      vr_blnfound := cr_crapcco%FOUND;
      -- Fecha cursor
      CLOSE cr_crapcco;
      -- Se NAO encontrou
      IF NOT vr_blnfound THEN
        vr_cdcritic := 563;
        RAISE vr_exc_saida;
      END IF;

      -- Se convenio esta desativado
      IF rw_crapcco.flgativo = 0 THEN
        vr_cdcritic := 949;
        RAISE vr_exc_saida;
      END IF;

      -- Cadastro de bloquetos
      OPEN cr_crapceb(pr_cdcooper => vr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrconven => pr_nrconven);
      FETCH cr_crapceb INTO rw_crapceb;
      -- Alimenta a booleana se achou ou nao
      vr_blnfound := cr_crapceb%FOUND;
      -- Fecha cursor
      CLOSE cr_crapceb;
      -- Se encontrou
      IF vr_blnfound THEN
        vr_cdcritic := 793;
        RAISE vr_exc_saida;
      END IF;

      -- Se NAO for registrada
      IF rw_crapcco.flgregis = 0 THEN
        vr_flgregis := 'NAO';
      ELSE
        vr_flgregis := 'SIM';
      END IF;
      
      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'cddbanco'
                            ,pr_tag_cont => rw_crapcco.cddbanco
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'dsorgarq'
                            ,pr_tag_cont => rw_crapcco.dsorgarq
                            ,pr_des_erro => vr_dscritic);
      
      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'flgregis'
                            ,pr_tag_cont => vr_flgregis
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'flserasa'
                            ,pr_tag_cont => rw_crapcco.flserasa
                            ,pr_des_erro => vr_dscritic);

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

        -- Gerar informacoes do log
        GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => GENE0001.vr_vet_des_origens(vr_idorigem)
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 0 --> FALSE
                            ,pr_hrtransa => GENE0002.fn_busca_time
                            ,pr_idseqttl => 1
                            ,pr_nmdatela => 'COBRANCA'
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
        COMMIT;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela TELA_ATENDA_COBRAN: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_valida_habilitacao;

  PROCEDURE pc_valida_dados_limite(pr_nrdconta  IN crapceb.nrdconta%TYPE --> Conta
                                  ,pr_dsorgarq  IN crapcco.dsorgarq%TYPE --> Origem Arquivo
                                  ,pr_inarqcbr  IN crapceb.inarqcbr%TYPE --> Recebe Arquivo de Retorno de Cobranca
                                  ,pr_cddemail  IN crapceb.cddemail%TYPE --> Email Arquivo de Retorno de Cobranca
                                  ,pr_idseqttl  IN crapcem.idseqttl%TYPE --> Sequencia do titular
                                  ,pr_xmllog    IN VARCHAR2 --> XML com informacoes de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                  ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                  ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_valida_dados_limite         Antigo: b1wgen0082.p/valida-dados-limites
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Fevereiro/2016                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para validar os dados inclusao/alteracao do convenio.

    Alteracoes: 
    ..............................................................................*/
    DECLARE

      -- Busca o cadastro de email
      CURSOR cr_crapcem(pr_cdcooper IN crapcem.cdcooper%TYPE
                       ,pr_nrdconta IN crapcem.nrdconta%TYPE
                       ,pr_idseqttl IN crapcem.idseqttl%TYPE
                       ,pr_cddemail IN crapcem.cddemail%TYPE) IS
        SELECT 1
          FROM crapcem 
         WHERE crapcem.cdcooper = pr_cdcooper
           AND crapcem.nrdconta = pr_nrdconta
           AND crapcem.idseqttl = pr_idseqttl
           AND crapcem.cddemail = pr_cddemail;
      rw_crapcem cr_crapcem%ROWTYPE;

      -- Cadastro de associados
      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT crapass.idastcjt
          FROM crapass
         WHERE crapass.cdcooper = pr_cdcooper
           AND crapass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;

      -- Cadastro de senhas
      CURSOR cr_crapsnh(pr_cdcooper IN crapsnh.cdcooper%TYPE
                       ,pr_nrdconta IN crapsnh.nrdconta%TYPE
                       ,pr_idseqttl IN crapsnh.idseqttl%TYPE) IS
        SELECT 1
          FROM crapsnh 
         WHERE crapsnh.cdcooper = pr_cdcooper
           AND crapsnh.nrdconta = pr_nrdconta
           AND crapsnh.tpdsenha = 1 -- Internet
           AND crapsnh.idseqttl = DECODE(pr_idseqttl, 0, crapsnh.idseqttl, pr_idseqttl)
           AND crapsnh.cdsitsnh = 1; -- Ativa
      rw_crapsnh cr_crapsnh%ROWTYPE;

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis
      vr_blnfound BOOLEAN;
      vr_nrdrowid ROWID;
      vr_dstransa VARCHAR2(1000);
      vr_idseqttl crapsnh.idseqttl%TYPE;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

    BEGIN
      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Seta a descricao da transacao
      vr_dstransa := 'Validar dados de inclusao/alteracao do convenio.';

      -- Se NAO foi informado um tipo de retorno
      IF pr_inarqcbr < 0 OR pr_inarqcbr > 3  THEN
        vr_dscritic := 'Tipo de arquivo de retorno invalido.';
        RAISE vr_exc_saida;
      END IF;

      -- Se NAO foi informado email para o retorno
      IF pr_cddemail = 0 AND pr_inarqcbr > 0  THEN
        vr_dscritic := 'Informe email para arquivo de retorno.';
        RAISE vr_exc_saida;
      END IF;

      -- Se tem arquivo de retorno
      IF pr_inarqcbr > 0 THEN
        -- Busca o cadastro de email
        OPEN cr_crapcem(pr_cdcooper => vr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_idseqttl => pr_idseqttl
                       ,pr_cddemail => pr_cddemail);
        FETCH cr_crapcem INTO rw_crapcem;
        -- Alimenta a booleana se achou ou nao
        vr_blnfound := cr_crapcem%FOUND;
        -- Fecha cursor
        CLOSE cr_crapcem;
        -- Se NAO encontrou
        IF NOT vr_blnfound THEN
          vr_cdcritic := 812;
          RAISE vr_exc_saida;
        END IF;
      END IF;

      -- Cadastro de associados
      OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      -- Alimenta a booleana se achou ou nao
      vr_blnfound := cr_crapass%FOUND;
      -- Fecha cursor
      CLOSE cr_crapass;
      -- Se NAO encontrou
      IF NOT vr_blnfound THEN
        vr_cdcritic := 9;
        RAISE vr_exc_saida;
      END IF;

      -- Se convenio INTERNET
      IF pr_dsorgarq = 'INTERNET' THEN

        -- Indicador de assinatura conjunta (0 – Nao exige)
        IF rw_crapass.idastcjt = 0 THEN
          vr_idseqttl := 1;
        ELSE
          vr_idseqttl := 0;
        END IF;

        -- Cadastro de senhas
        OPEN cr_crapsnh(pr_cdcooper => vr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_idseqttl => vr_idseqttl);
        FETCH cr_crapsnh INTO rw_crapsnh;
        -- Alimenta a booleana se achou ou nao
        vr_blnfound := cr_crapsnh%FOUND;
        -- Fecha cursor
        CLOSE cr_crapsnh;
        -- Se NAO encontrou
        IF NOT vr_blnfound THEN
          vr_dscritic := 'Nenhuma senha de internet esta ativa.';
          RAISE vr_exc_saida;
        END IF;

      END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

        -- Gerar informacoes do log
        GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => GENE0001.vr_vet_des_origens(vr_idorigem)
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 0 --> FALSE
                            ,pr_hrtransa => GENE0002.fn_busca_time
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => 'COBRANCA'
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
        COMMIT;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela TELA_ATENDA_COBRAN: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_valida_dados_limite;

  PROCEDURE pc_habilita_convenio(pr_nrdconta  IN crapceb.nrdconta%TYPE --> Conta
                                ,pr_nrconven  IN crapceb.nrconven%TYPE --> Convenio
                                ,pr_insitceb  IN crapceb.insitceb%TYPE --> Situacao do Convenio
                                ,pr_inarqcbr  IN crapceb.inarqcbr%TYPE --> Recebe Arquivo Retorno
                                ,pr_cddemail  IN crapceb.cddemail%TYPE --> Email Arquivo de Retorno
                                ,pr_flgcruni  IN crapceb.flgcruni%TYPE --> Credito Unificado
                                ,pr_flgcebhm  IN crapceb.flgcebhm%TYPE --> Contem o convenio homologado
                                ,pr_idseqttl  IN crapttl.idseqttl%TYPE --> Sequencia Titular
                                ,pr_flgregon  IN crapceb.flgregon%TYPE --> Flag de registro de titulo online (0-Nao/1-Sim)
                                ,pr_flgpgdiv  IN crapceb.flgpgdiv%TYPE --> Flag de autorizacao de pagamento divergente (0-Nao/ 1-Sim)
                                ,pr_flcooexp  IN crapceb.flcooexp%TYPE --> Cooperado Emite e Expede Boletos
                                ,pr_flceeexp  IN crapceb.flceeexp%TYPE --> Cooperativa Emite e Expede Boletos
                                ,pr_flserasa  IN crapceb.flserasa%TYPE --> Pode negativar no Serasa
                                ,pr_qtdfloat  IN crapceb.qtdfloat%TYPE --> Quantidade de dias para o Float
                                ,pr_flprotes  IN crapceb.flprotes%TYPE --> Liberacao da opcao de Protesto na Cobranca
                                ,pr_qtdecprz  IN crapceb.qtdecprz%TYPE --> Quantidade de dias para Decurso de Prazo
                                ,pr_idrecipr  IN crapceb.idrecipr%TYPE --> ID unico do calculo de reciprocidade atrelado a contratacao
                                ,pr_idreciprold IN crapceb.idrecipr%TYPE --> ID unico do calculo de reciprocidade atrelado a contratacao
                                ,pr_perdesconto IN VARCHAR2 --> Categoria e valor do desconto
																,pr_inenvcob  IN crapceb.inenvcob%TYPE --> Forma de envio de arquivo de cobrança
                                ,pr_xmllog    IN VARCHAR2 --> XML com informacoes de LOG
                                ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_habilita_convenio           Antigo: b1wgen0082.p/habilita-convenio
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Fevereiro/2016                 Ultima atualizacao: 17/10/2017

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para habilitar o convenio do cooperado.

    Alteracoes: 26/04/2016 - Ajustes projeto PRJ318 - Nova Plataforma cobrança
                             (Odirlei-AMcom)

				24/08/2016 - Ajuste emergencial pós-liberação do projeto 318. (Rafael)
                             
                14/09/2016 - Adicionado validacao de convenio ativo 
                             (Douglas - Chamado 502770)

                03/11/2016 - Ajustado as validacoes de situacao do convenio na conta do 
                             cooperado quando alterar os dados (Douglas - Chamado 547082)

        				13/12/2016 - PRJ340 - Nova Plataforma de Cobranca - Fase II. (Jaison/Cechet)
                
                17/10/2017 - Utilizar data de abertura da conta (ass.dtabtcct) ao registrar
                             beneficiario na CIP. (Rafael)

    ..............................................................................*/
    DECLARE

      -- Cadastro de associados
      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT to_char(crapass.nrdconta) nrdconta
              ,crapass.inpessoa
              ,decode(crapass.inpessoa,1,'F','J') dspessoa
              ,crapass.nmprimtl
              ,decode(crapass.inpessoa,1,lpad(crapass.nrcpfcgc,11,'0'),
                                         lpad(crapass.nrcpfcgc,14,'0')) dscpfcgc
              ,decode(crapass.inpessoa,1,to_char(crapass.nrcpfcgc)
                                        ,to_char(crapass.nrcpfcgc)) nrcpfcgc
              ,to_char(crapcop.cdagectl) cdagectl
              ,nvl(crapass.dtabtcct,crapass.dtmvtolt) dtabtcct -- existem casos que a dtabtcct é nula (?)
          FROM crapass,
               crapcop 
         WHERE crapass.cdcooper = crapcop.cdcooper
           AND crapass.cdcooper = pr_cdcooper
           AND crapass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;

      -- Busca o cadastro de convenio
      CURSOR cr_crapcco(pr_cdcooper IN crapcco.cdcooper%TYPE
                       ,pr_nrconven IN crapcco.nrconven%TYPE) IS
        SELECT crapcco.nrconven
              ,crapcco.cddbanco
              ,crapcco.dsorgarq
              ,crapcco.flgregis
              ,crapcco.flgutceb
              ,crapcco.flgativo
          FROM crapcco 
         WHERE crapcco.cdcooper = pr_cdcooper
           AND crapcco.nrconven = pr_nrconven;
      rw_crapcco cr_crapcco%ROWTYPE;

      -- Busca o operador
      CURSOR cr_crapope(pr_cdcooper IN crapope.cdcooper%TYPE
                       ,pr_cdoperad IN crapope.cdoperad%TYPE) IS
        SELECT crapope.cddepart
              ,crapope.nmoperad
          FROM crapope 
         WHERE crapope.cdcooper = pr_cdcooper
           AND crapope.cdoperad = pr_cdoperad;
      rw_crapope cr_crapope%ROWTYPE;

      -- Verifica se existe convenio INTERNET habilitado
      CURSOR cr_cco_ceb(pr_cdcooper IN crapcco.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE
                       ,pr_nrconven IN crapcco.nrconven%TYPE
                       ,pr_flgregis IN crapcco.flgregis%TYPE
                       ,pr_cddbanco IN crapcco.cddbanco%TYPE) IS
        SELECT COUNT(1)
          FROM crapcco
              ,crapceb
         WHERE crapcco.cdcooper = pr_cdcooper
           AND crapcco.nrconven <> pr_nrconven
           AND crapcco.flgregis = pr_flgregis
           AND crapcco.cddbanco = pr_cddbanco
           AND crapcco.dsorgarq = 'INTERNET'
           AND crapcco.flginter = 1 -- Utilizado na Internet
           AND crapceb.cdcooper = crapcco.cdcooper
           AND crapceb.nrconven = crapcco.nrconven
           AND crapceb.nrdconta = pr_nrdconta
           AND crapceb.insitceb = 1; -- Ativo

      -- Cadastro de Bloquetos
      CURSOR cr_crapceb(pr_cdcooper IN crapceb.cdcooper%TYPE
                       ,pr_nrdconta IN crapceb.nrdconta%TYPE
                       ,pr_nrconven IN crapceb.nrconven%TYPE) IS
        SELECT crapceb.nrcnvceb
              ,crapceb.insitceb
              ,crapceb.inarqcbr
              ,crapceb.cddemail
              ,crapceb.flgcruni
              ,crapceb.flgregon
              ,crapceb.flgpgdiv
              ,crapceb.flcooexp
              ,crapceb.flceeexp
              ,crapceb.flprotes
              ,crapceb.qtdecprz
              ,crapceb.qtdfloat
							,crapceb.inenvcob
          FROM crapceb
         WHERE crapceb.cdcooper = pr_cdcooper
           AND crapceb.nrdconta = pr_nrdconta
           AND crapceb.nrconven = pr_nrconven;
      rw_crapceb cr_crapceb%ROWTYPE;

      -- Ultimo Cadastro de Bloquetos
      CURSOR cr_lastceb(pr_cdcooper IN crapceb.cdcooper%TYPE
                       ,pr_nrconven IN crapceb.nrconven%TYPE) IS
        SELECT /*+ INDEX_DESC(T0 CRAPCEB##CRAPCEB3) */
               nrcnvceb 
          FROM crapceb T0 
         WHERE cdcooper = pr_cdcooper
           AND nrconven = pr_nrconven
           AND ROWNUM = 1;
      rw_lastceb cr_lastceb%ROWTYPE;

      -- Verifica se existe convenio do mesmo tipo
      CURSOR cr_ceb_cco(pr_cdcooper IN crapceb.cdcooper%TYPE
                       ,pr_nrdconta IN crapceb.nrdconta%TYPE) IS
        SELECT crapcco.flgregis
          FROM crapceb
              ,crapcco
         WHERE crapceb.cdcooper = pr_cdcooper
           AND crapceb.nrdconta = pr_nrdconta
           AND crapceb.cdcooper = crapcco.cdcooper
           AND crapceb.nrconven = crapcco.nrconven;

      -- Busca a categoria
      CURSOR cr_crapcat(pr_cdcatego IN crapcat.cdcatego%TYPE) IS
        SELECT INITCAP(crapcat.dscatego) dscatego
          FROM crapcat
         WHERE crapcat.cdcatego = pr_cdcatego;
      rw_crapcat cr_crapcat%ROWTYPE;

      -- Busca periodo de apuracao da Reciprocidade
      CURSOR cr_apuracao(pr_nrconven IN crapcco.nrconven%TYPE
                        ,pr_idrecipr IN crapceb.idrecipr%TYPE) IS
        SELECT apr.idapuracao_reciproci
              ,apr.dtinicio_apuracao
              ,apr.dttermino_apuracao
              ,apr.idconfig_recipro
              ,apr.tpreciproci
          FROM tbrecip_apuracao apr
         WHERE apr.indsituacao_apuracao = 'A' -- Em apuracao
           AND apr.idconfig_recipro     = pr_idrecipr
           AND apr.cdproduto            = 6 -- Cobranca
           AND apr.cdchave_produto      = pr_nrconven;
      rw_apuracao cr_apuracao%ROWTYPE;

      -- Configuracao para calculo de Reciprocidade
      CURSOR cr_indicador(pr_idapuracao_reciproci IN tbrecip_apuracao_indica.idapuracao_reciproci%TYPE) IS
        SELECT air.idindicador
              ,idr.tpindicador
          FROM tbrecip_apuracao_indica air
              ,tbrecip_indicador       idr
         WHERE air.idindicador = idr.idindicador
           AND air.idapuracao_reciproci = pr_idapuracao_reciproci;

      --> Cursor para verificar se ja existe o beneficiario na cip
      CURSOR cr_DDA_Benef (pr_dspessoa VARCHAR2,
                           pr_nrcpfcgc crapass.nrcpfcgc%TYPE) IS      
        SELECT 1
          FROM cecredleg.TBJDDDABNF_BeneficiarioIF@jdnpcsql b
         WHERE b.ISPB_IF = '05463212'
           AND "TpPessoaBenfcrio" = pr_dspessoa
           AND "CNPJ_CPFBenfcrio" = pr_nrcpfcgc;
      rw_DDA_Benef cr_DDA_Benef%ROWTYPE;
      
      --> Cursor para verificar se ja existe o convenio na cip
      CURSOR cr_DDA_Conven (pr_dspessoa VARCHAR2,
                            pr_nrcpfcgc crapass.nrcpfcgc%TYPE,
                            pr_nrconven VARCHAR2) IS      
        SELECT 1
          FROM cecredleg.TBJDDDABNF_Convenio@jdnpcsql b
         WHERE b."ISPB_IF" = '05463212'
           AND b."TpPessoaBenfcrio" = pr_dspessoa
           AND b."CNPJ_CPFBenfcrio" = pr_nrcpfcgc
           AND b."CodCli_Conv"      = pr_nrconven;
      rw_DDA_Conven cr_DDA_Conven%ROWTYPE;      
      
      --> Buscar dados pessoa juridica
      CURSOR cr_crapjur (pr_cdcooper crapjur.cdcooper%TYPE,
                         pr_nrdconta crapjur.nrdconta%TYPE) IS
        SELECT jur.nmfansia
          FROM crapjur  jur
         WHERE jur.cdcooper = pr_cdcooper
           AND jur.nrdconta = pr_nrdconta; 
      rw_crapjur cr_crapjur%ROWTYPE;
      
      -- Cursor generico de calendario
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
      vr_des_erro VARCHAR2(3);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis
      vr_blnfound BOOLEAN;
      vr_blnewreg BOOLEAN;
      vr_flDDA_Sit_Ben BOOLEAN;
      vr_flgimpri INTEGER;
      vr_qtccoceb NUMBER;
      vr_nrdrowid ROWID;
      vr_dstransa VARCHAR2(1000);
      vr_dsoperac VARCHAR2(1000);
      vr_dsdmesag VARCHAR2(1000);
      vr_nrcnvceb crapceb.nrcnvceb%TYPE;
      vr_lstdados GENE0002.typ_split;
      vr_lstdado2 GENE0002.typ_split;
      vr_cdcatego tbcobran_categ_tarifa_conven.cdcatego%TYPE; 
      vr_percdesc tbcobran_categ_tarifa_conven.perdesconto%TYPE;
      vr_flgatingido CHAR(1);
      vr_insitceb crapceb.insitceb%TYPE;
      vr_sitifcnv VARCHAR2(10);
      vr_dsdtmvto VARCHAR2(10);
      vr_insitif  VARCHAR2(10);
      vr_insitcip VARCHAR2(10);
      vr_nrconven VARCHAR2(10);
      vr_dtfimrel VARCHAR2(10) := NULL;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      
      ------------> SUB-Programas <------------
      
      
    BEGIN
      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Verificacao do calendario
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;

      -- Cadastro de associados
      OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      -- Alimenta a booleana se achou ou nao
      vr_blnfound := cr_crapass%FOUND;
      -- Fecha cursor
      CLOSE cr_crapass;
      -- Se NAO encontrou
      IF NOT vr_blnfound THEN
        vr_cdcritic := 9;
        RAISE vr_exc_saida;
      END IF;

      vr_insitceb := pr_insitceb;

      -- Monta a mensagem da operacao para envio no e-mail
      vr_dsoperac := 'Tentativa de habilitacao de cobranca na conta ' ||
                     GENE0002.fn_mask_conta(rw_crapass.nrdconta) || ' - CPF/CNPJ ' ||
                     GENE0002.fn_mask_cpf_cnpj(rw_crapass.nrcpfcgc,rw_crapass.inpessoa);

	    -- Verificar se a conta esta no cadastro restritivo
      CADA0004.pc_alerta_fraude (pr_cdcooper => vr_cdcooper         --> Cooperativa
                                ,pr_cdagenci => vr_cdagenci         --> PA
                                ,pr_nrdcaixa => vr_nrdcaixa         --> Nr. do caixa
                                ,pr_cdoperad => vr_cdoperad         --> Cod. operador
                                ,pr_nmdatela => vr_nmdatela         --> Nome da tela
                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Data de movimento
                                ,pr_idorigem => vr_idorigem         --> ID de origem
                                ,pr_nrcpfcgc => rw_crapass.nrcpfcgc --> Nr. do CPF/CNPJ
                                ,pr_nrdconta => pr_nrdconta         --> Nr. da conta
                                ,pr_idseqttl => pr_idseqttl         --> Id de sequencia do titular
                                ,pr_bloqueia => 1                   --> Flag Bloqueia operacao
                                ,pr_cdoperac => 2                   --> Cod da operacao
                                ,pr_dsoperac => vr_dsoperac         --> Desc. da operacao
                                ,pr_cdcritic => vr_cdcritic         --> Cod. da critica
                                ,pr_dscritic => vr_dscritic         --> Desc. da critica
                                ,pr_des_erro => vr_des_erro);       --> Retorno de erro  OK/NOK
      -- Se retornou erro
      IF vr_des_erro <> 'OK' THEN
        RAISE vr_exc_saida;
      END IF;

      -- Busca o cadastro de convenio
      OPEN cr_crapcco(pr_cdcooper => vr_cdcooper
                     ,pr_nrconven => pr_nrconven);
      FETCH cr_crapcco INTO rw_crapcco;
      -- Alimenta a booleana se achou ou nao
      vr_blnfound := cr_crapcco%FOUND;
      -- Fecha cursor
      CLOSE cr_crapcco;
      -- Se NAO encontrou
      IF NOT vr_blnfound THEN
        vr_cdcritic := 563;
        RAISE vr_exc_saida;
      END IF;

      -- Se for CECRED
      IF rw_crapcco.cddbanco = 85 THEN
        -- Caso NAO foi informado quem ira Emitir e Expedir
        IF pr_flcooexp = 0 AND pr_flceeexp = 0 THEN
          vr_dscritic := 'Campo Cooperativa Emite e Expede ou Cooperado Emite e Expede devem ser preenchidos';
          RAISE vr_exc_saida;
        END IF;
      END IF;

      -- Busca o operador
      OPEN cr_crapope(pr_cdcooper => vr_cdcooper
                     ,pr_cdoperad => vr_cdoperad);
      FETCH cr_crapope INTO rw_crapope;
      -- Alimenta a booleana se achou ou nao
      vr_blnfound := cr_crapope%FOUND;
      -- Fecha cursor
      CLOSE cr_crapope;
      -- Se NAO encontrou
      IF NOT vr_blnfound THEN
        vr_cdcritic := 67;
        RAISE vr_exc_saida;
      END IF;
      
      -- NAO pode haver dois convenios INTERNET ativos do mesmo banco
      -- para o mesmo cooperado - cob. sem registro
      IF vr_insitceb = 1 THEN
        -- Se a origem arquivo for INTERNET
        IF rw_crapcco.dsorgarq = 'INTERNET' THEN
          -- Verifica se existe convenio INTERNET habilitado
          OPEN cr_cco_ceb(pr_cdcooper => vr_cdcooper
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_nrconven => pr_nrconven
                         ,pr_flgregis => rw_crapcco.flgregis
                         ,pr_cddbanco => rw_crapcco.cddbanco);
          FETCH cr_cco_ceb INTO vr_qtccoceb;
          -- Fecha cursor
          CLOSE cr_cco_ceb;
          -- Se possui convenio INTERNET habilitado
          IF vr_qtccoceb > 0 THEN
            vr_dscritic := 'Ja existe um convenio INTERNET habilitado.';
            RAISE vr_exc_saida;
          END IF;
        END IF;
      END IF;

      -- Cadastro de bloquetos
      OPEN cr_crapceb(pr_cdcooper => vr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrconven => pr_nrconven);
      FETCH cr_crapceb INTO rw_crapceb;
      -- Alimenta a booleana se achou ou nao
      vr_blnfound := cr_crapceb%FOUND;
      -- Fecha cursor
      CLOSE cr_crapceb;
      -- Se encontrou
      IF vr_blnfound THEN
        -- Se for BB e foi escolhido CNAB 400
        IF rw_crapcco.cddbanco = 1 AND pr_inarqcbr = 3 THEN
          vr_dscritic := 'Convenio nao suporta arquivo de retorno CNAB400.';
          RAISE vr_exc_saida;
        ELSE
          -- Se tem identificador de sequencia
          IF rw_crapcco.flgutceb = 1 THEN
            vr_nrcnvceb := rw_crapceb.nrcnvceb;
          ELSE
            vr_nrcnvceb := 0;
          END IF;
        END IF;
      ELSE
        -- Se tem identificador de sequencia
        IF rw_crapcco.flgutceb = 1 THEN
          -- Ultimo Cadastro de bloquetos
          OPEN cr_lastceb(pr_cdcooper => vr_cdcooper
                         ,pr_nrconven => pr_nrconven);
          FETCH cr_lastceb INTO rw_lastceb;
          -- Alimenta a booleana se achou ou nao
          vr_blnfound := cr_lastceb%FOUND;
          -- Fecha cursor
          CLOSE cr_lastceb;
          -- Se NAO encontrou
          IF NOT vr_blnfound THEN
            vr_nrcnvceb := 1;
          ELSE
            vr_nrcnvceb := rw_lastceb.nrcnvceb + 1;
          END IF;
          -- Numero do Convenio CECRED for superior
          IF vr_nrcnvceb > 9999 THEN
            vr_dscritic := 'Numero CEB superior a 9999.';
            RAISE vr_exc_saida;
          END IF;
        ELSE
          vr_nrcnvceb := 0;
        END IF;
      END IF;

      -- Gerar impressao
      vr_flgimpri := 1;

      -- Verifica se existe convenio do mesmo tipo
      FOR rw_ceb_cco IN cr_ceb_cco(pr_cdcooper => vr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta) LOOP
        -- Se ja tem, flega para nao imprimir
        IF rw_ceb_cco.flgregis = rw_crapcco.flgregis THEN
          vr_flgimpri := 0;
        END IF;
      END LOOP;

      -- Permitir a reativacao de convenios de cobranca sem registro (Renato - Supero - SD 194301)
      IF rw_crapope.cddepart NOT IN (18) THEN
        -- Regra para nao permitir ativar um convenio sem registro do BB inativo
        IF  vr_insitceb = 1
        AND rw_crapceb.insitceb = 2
        AND rw_crapcco.flgregis = 0
        AND rw_crapcco.cddbanco = 1 
        THEN
          vr_dscritic := 'Nao eh permitido habilitar convenio BB sem registro inativado.';
          RAISE vr_exc_saida;
        END IF;
      END IF;

			/* Se forma de envio de arquivo de cobrança for por FTP e origem do convênio 
			   não for "IMPRESSO PELO SOFTWARE", gerar crítica*/
			IF pr_inenvcob = 2 AND rw_crapcco.dsorgarq <> 'IMPRESSO PELO SOFTWARE' THEN
				  -- Atribuir descrição da crítica
          vr_dscritic := 'Forma de envio de arquivo de cobrança não permitido para esta origem de convênio.';
					-- Levantar exceção
          RAISE vr_exc_saida;				
			END IF;
      -- Seta como registro existente
      vr_blnewreg := FALSE;

      -- Cadastro de bloquetos
      OPEN cr_crapceb(pr_cdcooper => vr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrconven => pr_nrconven);
      FETCH cr_crapceb INTO rw_crapceb;
      -- Alimenta a booleana se achou ou nao
      vr_blnfound := cr_crapceb%FOUND;
      -- Fecha cursor
      CLOSE cr_crapceb;
      -- Se NAO encontrou
      IF NOT vr_blnfound THEN
        
        -- Se convenio esta desativado, e a situacao que esta sendo alterada eh para ativa-lo
        IF rw_crapcco.flgativo = 0 AND pr_insitceb = 1 THEN
          vr_cdcritic := 949;
          RAISE vr_exc_saida;
        END IF;
      
        BEGIN
          INSERT INTO crapceb
                     (cdcooper
                     ,nrdconta
                     ,nrconven
                     ,nrcnvceb
                     ,cdoperad
                     ,cdopeori
                     ,cdageori
                     ,dtinsori)
               VALUES(vr_cdcooper
                     ,pr_nrdconta
                     ,pr_nrconven
                     ,vr_nrcnvceb
                     ,vr_cdoperad
                     ,vr_cdoperad
                     ,vr_cdagenci
                     ,SYSDATE);
          -- Seta como registro novo
          vr_blnewreg := TRUE;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir o registro na CRAPCEB: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;
      END IF;

      -- Verificar se o convenio esta sendo atualizado 
      IF NOT vr_blnewreg THEN
        -- Se convenio esta desativado, e a situacao que esta sendo alterada eh para ativa-lo
        IF rw_crapcco.flgativo = 0 AND  -- Convenio Inativo
           rw_crapceb.insitceb = 2 AND  -- Convenio na conta do cooperado Inativo
           pr_insitceb <> 2        THEN -- Alterando a situacao do convenio para qualquer outra situacao
          vr_cdcritic := 949;
          RAISE vr_exc_saida;
        END IF;
      END IF;

      /**** - Tratamento CIP ****/
      
      --> Buscar situacao do benificiario na cip
      vr_insitif  := NULL;
      vr_insitcip := NULL;
      DDDA0001.pc_ret_sit_beneficiario( pr_inpessoa  => rw_crapass.inpessoa,  --> Tipo de pessoa
                                        pr_nrcpfcgc  => rw_crapass.nrcpfcgc,  --> CPF/CNPJ do beneficiario
                                        pr_insitif   => vr_insitif,           --> Retornar situação IF
                                        pr_insitcip  => vr_insitcip,          --> Retorna situação na CIP
                                        pr_dscritic  => vr_dscritic);         --> Retorna critica
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      --> Se foi inclusao 
      IF vr_blnewreg AND 
         (nvl(vr_insitif,'A') <> 'I' AND (vr_insitcip IS NULL OR vr_insitcip = 'A')) THEN
        
        vr_dsdtmvto := to_char(rw_crapdat.dtmvtolt,'RRRRMMDD');      
        
        --> Verificar se ja existe o beneficiario na cip
        OPEN cr_DDA_Benef (pr_dspessoa => rw_crapass.dspessoa,
                           pr_nrcpfcgc => rw_crapass.nrcpfcgc);
        FETCH cr_DDA_Benef INTO rw_DDA_Benef;
        
        IF cr_DDA_Benef%NOTFOUND THEN
          IF rw_crapass.inpessoa = 2 THEN
            --> Buscar dados pessoa juridica
            OPEN cr_crapjur (pr_cdcooper => vr_cdcooper,
                             pr_nrdconta => pr_nrdconta);
            FETCH cr_crapjur INTO rw_crapjur;
            CLOSE cr_crapjur;
          END IF;              
                    
          BEGIN
            -- utilizar a data de admissao do cooperado como data de relacionamento
            vr_dsdtmvto := to_char(nvl(rw_crapass.dtabtcct,rw_crapdat.dtmvtolt),'RRRRMMDD');      
            
            INSERT INTO cecredleg.TBJDDDABNF_BeneficiarioIF@jdnpcsql
                  ( "ISPB_IF",
                    "TpPessoaBenfcrio",
                    "CNPJ_CPFBenfcrio",
                    "Nom_RzSocBenfcrio", 
                    "Nom_FantsBenfcrio", 
                    "DtInicRelctPart",    
                    "DtFimRelctPart")
            VALUES ('05463212'           -- ISPB_IF
                   ,rw_crapass.dspessoa  -- TpPessoaBenfcrio
                   ,rw_crapass.dscpfcgc  -- CNPJ_CPFBenfcrio
                   ,rw_crapass.nmprimtl  -- Nom_RzSocBenfcrio 
                   ,rw_crapjur.nmfansia  -- Nom_FantsBenfcrio 
                   ,vr_dsdtmvto          -- DtInicRelctPart    
                   ,NULL);               -- DtFimRelctPart    
            
          EXCEPTION 
            WHEN dup_val_on_index THEN
              vr_dscritic := 'CPF/CNPJ do Beneficiario ja cadastrado na CIP, favor verificar.';
              RAISE vr_exc_saida;              
            WHEN OTHERS THEN
              vr_dscritic := 'Nao foi possivel cadastrar Beneficiario na CIP: ' || SQLERRM;
              RAISE vr_exc_saida;              
          END;
        END IF;
        CLOSE cr_DDA_Benef;
                
        --> Verificar se situacao permite continuar        
        IF  VR_INSITIF IN ('A') OR 
           -- ou não houver sit IF porem ativo na CIP
           (VR_INSITIF IS NULL AND VR_INSITCIP = 'A') OR
           -- Ou ativo no IF e sem sit na CIP
           (VR_INSITIF = 'A' AND VR_INSITCIP IS NULL) OR
           -- Ou ainda nao existir situacao
           (VR_INSITIF IS NULL AND VR_INSITCIP IS NULL) THEN                      
          
          --> Gravar o log de adesao ou bloqueio do convenio
          COBR0008.pc_gera_log_ceb 
                          (pr_idorigem  => vr_idorigem,
                           pr_cdcooper  => vr_cdcooper,
                           pr_cdoperad  => vr_cdoperad,
                           pr_nrdconta  => pr_nrdconta,
                           pr_nrconven  => pr_nrconven,
                           pr_insitceb  => 1, --'ATIVO'
                           pr_dscritic  => vr_dscritic);
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF; 
          
          vr_sitifcnv := 'A'; -- Apto
          
        --SITIF => “I”, bloquear convênio de cobrança mostrando a mensagem no final: “Cobrança não liberada”;                          
        ELSIF VR_INSITIF = 'I' THEN

          --> Gravar o log de adesao ou bloqueio do convenio
          COBR0008.pc_gera_log_ceb 
                          (pr_idorigem  => vr_idorigem,
                           pr_cdcooper  => vr_cdcooper,
                           pr_cdoperad  => vr_cdoperad,
                           pr_nrdconta  => pr_nrdconta,
                           pr_nrconven  => pr_nrconven,
                           pr_insitceb  => 4, -- 'BLOQUEADO'
                           pr_dscritic  => vr_dscritic);
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
          
          vr_cdcritic := 0;
          vr_dscritic := 'Convênio de cobrança não liberado.';
          RAISE vr_exc_saida;
          
          -- Guardar variavel para atualizar crapceb
          --vr_insitceb := 4; -- Bloqueado
          --vr_sitifcnv := 'I'; -- Inativo
          --vr_dtfimrel := to_char(rw_crapdat.dtmvtolt,'RRRRMMDD');
          
        --> SITCIP => “I” ou “E” ou SITIF = "E", realizar o cadastro do convênio do cooperado com status “PENDENTE”;
        ELSIF VR_INSITCIP IN ('I','E') OR
              VR_INSITIF IN ('E') THEN        
        
          --> Gravar o log de adesao ou bloqueio do convenio
          COBR0008.pc_gera_log_ceb 
                          (pr_idorigem  => vr_idorigem,
                           pr_cdcooper  => vr_cdcooper,
                           pr_cdoperad  => vr_cdoperad,
                           pr_nrdconta  => pr_nrdconta,
                           pr_nrconven  => pr_nrconven,
                           pr_insitceb  => 3, -- 'PENDENTE'
                           pr_dscritic  => vr_dscritic);
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
          
          -- Guardar variavel para atualizar crapceb
          vr_insitceb := 3; -- PENDENTE
          vr_sitifcnv := 'A'; -- Ativo
          vr_dtfimrel := NULL;
          vr_flgimpri := 0;
        ELSE
          vr_dscritic := 'Situacao invalida do Beneficiario na JDBNF1.';
          RAISE vr_exc_saida;  
        END IF;   
        

        --> Verificar se ja existe o convenio na cip
        OPEN cr_DDA_Conven (pr_dspessoa => rw_crapass.dspessoa,
                            pr_nrcpfcgc => rw_crapass.nrcpfcgc,
                            pr_nrconven => to_char(pr_nrconven));
        FETCH cr_DDA_Conven INTO rw_DDA_Conven;
        IF cr_DDA_Conven%NOTFOUND THEN
          --> Gerar informação de adesão de convênio ao JDBNF                            
          BEGIN
            
            vr_dsdtmvto := to_char(rw_crapdat.dtmvtolt,'RRRRMMDD');      
            
            INSERT INTO cecredleg.TBJDDDABNF_Convenio@jdnpcsql 
                       ("ISPB_IF",
                        "ISPBPartIncorpd",
                        "TpPessoaBenfcrio",
                        "CNPJ_CPFBenfcrio",
                        "CodCli_Conv",
                        "SitConvBenfcrioPar",
                        "DtInicRelctConv",
                        "DtFimRelctConv",
                        "TpAgDest",
                        "AgDest",
                        "TpCtDest",
                        "CtDest",
                        "TpProdtConv",
                        "TpCartConvCobr" )
                 VALUES('05463212',                             -- ISPB_IF
                        NULL,                                   -- ISPBPartIncorpd
                        rw_crapass.dspessoa,                    -- TpPessoaBenfcrio
                        rw_crapass.dscpfcgc,                    -- CNPJ_CPFBenfcrio
                        pr_nrconven,                            -- CodCli_Conv
                        vr_sitifcnv,                            -- SitConvBenfcrioPar
                        vr_dsdtmvto,                            -- DtInicRelctConv
                        vr_dtfimrel,                            -- DtFimRelctConv
                        'F',                                    -- TpAgDest (F=Fisica)
                        rw_crapass.cdagectl,                    -- AgDest
                        'CC',                                   -- TpCtDest
                        rw_crapass.nrdconta,                    -- CtDest
                        '01', -- boleto de cobranca             -- TpProdtConv
                        '1' );-- com registro                   -- TpCartConvCobr
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Nao foi possivel registrar convenio na CIP: ' || SQLERRM;
              RAISE vr_exc_saida;              
          END;
      ELSE
        BEGIN
          vr_nrconven := to_char(pr_nrconven);
                    
          UPDATE cecredleg.TBJDDDABNF_Convenio@jdnpcsql a
             SET a."SitConvBenfcrioPar" = vr_sitifcnv
                ,a."DtInicRelctConv"    = nvl(vr_dsdtmvto,a."DtInicRelctConv")
                ,a."DtFimRelctConv"     = vr_dtfimrel
           WHERE a."ISPB_IF"            = '05463212'
             AND a."TpPessoaBenfcrio"   = rw_crapass.dspessoa
             AND a."CNPJ_CPFBenfcrio"   = rw_crapass.dscpfcgc
             AND a."CodCli_Conv"        = vr_nrconven;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Nao foi possivel atualizar convenio na CIP: ' || SQLERRM;
              RAISE vr_exc_saida;              
          END;            
      END IF;
      CLOSE cr_DDA_Conven;
      
      
      --> senao é manutencao  
      ELSE
        --> Verificar se situacao permite continuar
        --A=Apto, I=Inapto, E=Em análise
        IF VR_INSITIF IN ('A','E') THEN
          --> Gravar o log de adesao ou bloqueio do convenio
          COBR0008.pc_gera_log_ceb 
                          (pr_idorigem  => vr_idorigem,
                           pr_cdcooper  => vr_cdcooper,
                           pr_cdoperad  => vr_cdoperad,
                           pr_nrdconta  => pr_nrdconta,
                           pr_nrconven  => pr_nrconven,
                           pr_dstransa  => 'Manutencao do convenio de cobranca',
                           pr_insitceb_ant => nvl(rw_crapceb.insitceb,0), --Antes de alterar
                           pr_insitceb  => 1, -- 'ATIVO'
                           pr_dscritic  => vr_dscritic);
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
          
        --> SITIF => “I”, convênio de cobrança inapto; Deverá ser bloqueado;
        ELSIF VR_INSITIF = 'I' THEN
          --> Gravar o log de adesao ou bloqueio do convenio
          COBR0008.pc_gera_log_ceb 
                          (pr_idorigem  => vr_idorigem,
                           pr_cdcooper  => vr_cdcooper,
                           pr_cdoperad  => vr_cdoperad,
                           pr_nrdconta  => pr_nrdconta,
                           pr_nrconven  => pr_nrconven,
                           pr_dstransa  => 'Manutencao do convenio de cobranca',
                           pr_insitceb_ant => nvl(rw_crapceb.insitceb,0), --Antes de alterar
                           pr_insitceb  => 4 , -- 'Bloqueado'
                           pr_dscritic  => vr_dscritic);
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
          
          vr_cdcritic := 0;
          vr_dscritic := 'Convênio de cobrança não liberado.';
          RAISE vr_exc_saida;
          
          -- Guardar variavel para atualizar crapceb
          -- vr_insitceb := 4; -- Bloqueado
          
        ELSIF (VR_INSITCIP IN ('I','E') OR VR_INSITCIP IS NULL) THEN
          --> Gravar o log de adesao ou bloqueio do convenio
          COBR0008.pc_gera_log_ceb 
                          (pr_idorigem  => vr_idorigem,
                           pr_cdcooper  => vr_cdcooper,
                           pr_cdoperad  => vr_cdoperad,
                           pr_nrdconta  => pr_nrdconta,
                           pr_nrconven  => pr_nrconven,
                           pr_dstransa  => 'Manutencao do convenio de cobranca',
                           pr_insitceb_ant => nvl(rw_crapceb.insitceb,0), --Antes de alterar
                           pr_insitceb  => 1, -- 'ATIVO'
                           pr_dscritic  => vr_dscritic);
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
                    
          
          vr_flgimpri := 0; -- nao imprimir o termo de adesao
          
        ELSE
          vr_dscritic := 'Situacao invalida do Beneficiario na JDBNF2.';
          RAISE vr_exc_saida;        
        END IF;
      
      END IF;  
      
      /**** Fim Tratamento CIP ****/
      
      BEGIN
        UPDATE crapceb
           SET crapceb.dtcadast = rw_crapdat.dtmvtolt
              ,crapceb.inarqcbr = pr_inarqcbr
              ,crapceb.cddemail = DECODE(pr_inarqcbr, 0, 0, pr_cddemail)
              ,crapceb.flgcruni = pr_flgcruni
              ,crapceb.flgcebhm = pr_flgcebhm
              ,crapceb.flgregon = pr_flgregon
              ,crapceb.flgpgdiv = pr_flgpgdiv
              ,crapceb.flcooexp = pr_flcooexp
              ,crapceb.flceeexp = pr_flceeexp
              ,crapceb.flserasa = pr_flserasa
              ,crapceb.insitceb = vr_insitceb
              ,crapceb.cdhomolo = vr_cdoperad
              ,crapceb.qtdfloat = pr_qtdfloat
              ,crapceb.flprotes = pr_flprotes
              ,crapceb.qtdecprz = pr_qtdecprz
              ,crapceb.idrecipr = pr_idrecipr
							,crapceb.inenvcob = pr_inenvcob
         WHERE crapceb.cdcooper = vr_cdcooper
           AND crapceb.nrdconta = pr_nrdconta
           AND crapceb.nrconven = pr_nrconven;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao alterar o registro na CRAPCEB: ' || SQLERRM;
          RAISE vr_exc_saida;
      END;


      -- Remove os registros para depois incluir
      BEGIN
        DELETE 
          FROM tbcobran_categ_tarifa_conven
         WHERE tbcobran_categ_tarifa_conven.cdcooper = vr_cdcooper
           AND tbcobran_categ_tarifa_conven.nrdconta = pr_nrdconta
           AND tbcobran_categ_tarifa_conven.nrconven = pr_nrconven;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao excluir o registro na TBCOBRAN_CATEG_TARIFA_CONVEN: ' || SQLERRM;
          RAISE vr_exc_saida;
      END;

      -- Separar a lista de codigos de categoria e percentual de desconto
      vr_lstdados := GENE0002.fn_quebra_string(pr_string => pr_perdesconto, pr_delimit => '|');
      FOR vr_idx IN 1..vr_lstdados.COUNT LOOP
        vr_lstdado2 := GENE0002.fn_quebra_string(pr_string => vr_lstdados(vr_idx), pr_delimit => '#');
        vr_cdcatego := vr_lstdado2(1);
        vr_percdesc := vr_lstdado2(2);

        BEGIN
          INSERT INTO tbcobran_categ_tarifa_conven
                     (cdcooper
                     ,nrdconta
                     ,nrconven
                     ,cdcatego 
                     ,perdesconto)
               VALUES(vr_cdcooper
                     ,pr_nrdconta
                     ,pr_nrconven
                     ,vr_cdcatego
                     ,vr_percdesc);
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir o registro na TBCOBRAN_CATEG_TARIFA_CONVEN: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;
      END LOOP;

      -- Se houve alteracao no calculo devemos cancelar o periodo de apuracao em aberto
      IF pr_idreciprold <> pr_idrecipr AND 
         pr_idreciprold > 0 THEN

        -- Busca periodo de apuracao da Reciprocidade
        OPEN cr_apuracao(pr_nrconven => pr_nrconven
                        ,pr_idrecipr => pr_idreciprold);
        FETCH cr_apuracao INTO rw_apuracao;
        -- Alimenta a booleana se achou ou nao
        vr_blnfound := cr_apuracao%FOUND;
        -- Fecha cursor
        CLOSE cr_apuracao;
        -- Se encontrou
        IF vr_blnfound THEN
          -- Configuracao para calculo de Reciprocidade
          FOR rw_indicador IN cr_indicador(pr_idapuracao_reciproci => rw_apuracao.idapuracao_reciproci) LOOP
            -- Acionamos a rotina que calculara o apurador e atualizara seu valor realizado parcialmente
            RCIP0001.pc_calcula_recipro_atingida(pr_cdcooper           => vr_cdcooper
                                                ,pr_nrdconta           => pr_nrdconta
                                                ,pr_idapuracao         => rw_apuracao.idapuracao_reciproci
                                                ,pr_idindicador        => rw_indicador.idindicador
                                                ,pr_dtinicio_apuracao  => rw_apuracao.dtinicio_apuracao
                                                ,pr_dttermino_apuracao => rw_apuracao.dttermino_apuracao
                                                ,pr_idconfig_recipro   => rw_apuracao.idconfig_recipro
                                                ,pr_tpreciproci        => rw_apuracao.tpreciproci
                                                ,pr_tpindicador        => rw_indicador.tpindicador
                                                ,pr_flgatingido        => vr_flgatingido
                                                ,pr_descr_error        => vr_dscritic);
            -- Se encontrou erro
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
          END LOOP;

          BEGIN
            UPDATE tbrecip_apuracao
               SET indsituacao_apuracao = 'C' -- Cancelada
                  ,dtcancela_apuracao   = SYSDATE
                  ,perrecipro_atingida  = 0   -- Sempre zero em cancelamento
                  ,flgtarifa_debitada   = 0   -- Sempre nao em cancelamento
                  ,flgtarifa_revertida  = 0   -- Sempre nao em cancelamento
             WHERE idapuracao_reciproci = rw_apuracao.idapuracao_reciproci;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao alterar o registro na TBRECIP_APURACAO: ' || SQLERRM;
              RAISE vr_exc_saida;
          END;
        END IF;

      END IF;

      -- ATENCAO! As 8 posicoes destinadas ao numero do convenio
      -- no log de inclusao, estao sendo utilizadas na tela CONGPR.
      -- Se houver alteracao neste log a tela devera ser corrigida.
      IF vr_blnewreg THEN
        vr_dstransa := 'Incluir convenio de cobranca ' ||
                       TO_CHAR(GENE0002.fn_mask(rw_crapcco.nrconven,'zzzzzzz9')) || '.';
        -- Se possuir Numero do Convenio CECRED
        IF vr_nrcnvceb > 0 THEN
          vr_dsdmesag := 'Convenio CEB de numero ' ||
                         TO_CHAR(GENE0002.fn_mask(vr_nrcnvceb,'zzz,zz9')) ||
                         ' habilitado com sucesso!';
        END IF;
      ELSE
        vr_dstransa := 'Alterar convenio de cobranca ' ||
                       TO_CHAR(GENE0002.fn_mask(rw_crapcco.nrconven,'zzzzzzz9')) || '.';
      END IF;

      -- Gerar informacoes do log
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => ' '
                          ,pr_dsorigem => GENE0001.vr_vet_des_origens(vr_idorigem)
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1 --> TRUE
                          ,pr_hrtransa => GENE0002.fn_busca_time
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'COBRANCA'
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);

      -- Se for inclusao
      IF vr_blnewreg THEN
        -- Numero convenio
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'nrconven'
                                 ,pr_dsdadant => NULL
                                 ,pr_dsdadatu => pr_nrconven);
        -- Convenio CEB
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'nrcnvceb'
                                 ,pr_dsdadant => NULL
                                 ,pr_dsdadatu => vr_nrcnvceb);
      END IF;

      -- Se alterou Situacao CEB
      IF rw_crapceb.insitceb <> pr_insitceb THEN
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'insitceb'
                                 ,pr_dsdadant => CASE WHEN rw_crapceb.insitceb = 1 THEN 'ATIVO' ELSE 'INATIVO' END
                                 ,pr_dsdadatu => CASE WHEN pr_insitceb = 1 THEN 'ATIVO' ELSE 'INATIVO' END);
      END IF;

      -- Se alterou Registro de Titulo Online
      IF rw_crapceb.flgregon <> pr_flgregon THEN
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'flgregon'
                                 ,pr_dsdadant => CASE WHEN rw_crapceb.flgregon = 1 THEN 'ATIVO' ELSE 'INATIVO' END
                                 ,pr_dsdadatu => CASE WHEN pr_flgregon = 1 THEN 'ATIVO' ELSE 'INATIVO' END);
      END IF;

      -- Se alterou Autorizacao de Pagamento Divergente
      IF rw_crapceb.flgpgdiv <> pr_flgpgdiv THEN
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'flgpgdiv'
                                 ,pr_dsdadant => CASE WHEN rw_crapceb.flgpgdiv = 1 THEN 'ATIVO' ELSE 'INATIVO' END
                                 ,pr_dsdadatu => CASE WHEN pr_flgpgdiv = 1 THEN 'ATIVO' ELSE 'INATIVO' END);
      END IF;

      -- Se alterou Cooperado Emite e Expede
      IF rw_crapceb.flcooexp <> pr_flcooexp THEN
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'flcooexp'
                                 ,pr_dsdadant => CASE WHEN rw_crapceb.flcooexp = 1 THEN 'ATIVO' ELSE 'INATIVO' END
                                 ,pr_dsdadatu => CASE WHEN pr_flcooexp = 1 THEN 'ATIVO' ELSE 'INATIVO' END);
      END IF;

      -- Se alterou Cooperativa Emite e Expede
      IF rw_crapceb.flceeexp <> pr_flceeexp THEN
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'flceeexp'
                                 ,pr_dsdadant => CASE WHEN rw_crapceb.flceeexp = 1 THEN 'ATIVO' ELSE 'INATIVO' END
                                 ,pr_dsdadatu => CASE WHEN pr_flceeexp = 1 THEN 'ATIVO' ELSE 'INATIVO' END);
      END IF;

      -- Se alterou Envio de Protesto
      IF rw_crapceb.flprotes <> pr_flprotes THEN
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'Envio de Protesto'
                                 ,pr_dsdadant => CASE WHEN rw_crapceb.flprotes = 1 THEN 'ATIVO' ELSE 'INATIVO' END
                                 ,pr_dsdadatu => CASE WHEN pr_flprotes = 1 THEN 'ATIVO' ELSE 'INATIVO' END);
      END IF;

      -- Se alterou Float a aplicar
      IF rw_crapceb.qtdfloat <> pr_qtdfloat THEN
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'Float a aplicar'
                                 ,pr_dsdadant => rw_crapceb.qtdfloat
                                 ,pr_dsdadatu => pr_qtdfloat);
      END IF;

      -- Se alterou Decurso de Prazo
      IF rw_crapceb.qtdecprz <> pr_qtdecprz THEN
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'Decurso de Prazo'
                                 ,pr_dsdadant => rw_crapceb.qtdecprz
                                 ,pr_dsdadatu => pr_qtdecprz);
      END IF;

      -- Se alterou Arquivo Retorno
      IF rw_crapceb.inarqcbr <> pr_inarqcbr THEN
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'inarqcbr'
                                 ,pr_dsdadant => rw_crapceb.inarqcbr
                                 ,pr_dsdadatu => pr_inarqcbr);
      END IF;

      -- Se alterou Email retorno
      IF rw_crapceb.cddemail <> pr_cddemail THEN
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'cddemail'
                                 ,pr_dsdadant => rw_crapceb.cddemail
                                 ,pr_dsdadatu => pr_cddemail);
      END IF;

      -- Se alterou Credito Unificado
      IF rw_crapceb.flgcruni <> pr_flgcruni THEN
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'flgcruni'
                                 ,pr_dsdadant => CASE WHEN rw_crapceb.flgcruni = 1 THEN 'SIM' ELSE 'NAO' END
                                 ,pr_dsdadatu => CASE WHEN pr_flgcruni = 1 THEN 'SIM' ELSE 'NAO' END);
      END IF;
      
      -- Se alterou Forma de envio de arquivo de cobrança
      IF rw_crapceb.inenvcob <> pr_inenvcob THEN
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'inenvcob'
                                 ,pr_dsdadant => CASE WHEN rw_crapceb.inenvcob = 1 THEN 'INTERNET BANK' ELSE 'FTP' END
                                 ,pr_dsdadatu => CASE WHEN pr_inenvcob = 1 THEN 'INTERNET BANK' ELSE 'FTP' END);
      END IF;

      
      -- Gera log das categorias e percentual de desconto
      FOR vr_idx IN 1..vr_lstdados.COUNT LOOP
        vr_lstdado2 := GENE0002.fn_quebra_string(pr_string => vr_lstdados(vr_idx), pr_delimit => '#');
        vr_cdcatego := vr_lstdado2(1);
        vr_percdesc := vr_lstdado2(2);

        -- Busca a categoria
        OPEN cr_crapcat(pr_cdcatego => vr_cdcatego);
        FETCH cr_crapcat INTO rw_crapcat;
        CLOSE cr_crapcat;

        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => rw_crapcat.dscatego
                                 ,pr_dsdadant => NULL
                                 ,pr_dsdadatu => vr_percdesc);
      END LOOP;

      -- Se alterou Situacao CEB
      IF rw_crapceb.insitceb <> pr_insitceb THEN
        vr_dstransa := 'Convenio ' ||
                       (CASE WHEN pr_insitceb = 1 THEN 'ativado' ELSE 'desativado' END) ||
                       ' pelo operador ' || vr_cdoperad || ' - ' || rw_crapope.nmoperad;

        -- Gerar informacoes do log
        GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => ' '
                            ,pr_dsorigem => GENE0001.vr_vet_des_origens(vr_idorigem)
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1 --> TRUE
                            ,pr_hrtransa => GENE0002.fn_busca_time
                            ,pr_idseqttl => 1
                            ,pr_nmdatela => 'COBRANCA'
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
        -- Situacao CEB
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'insitceb'
                                 ,pr_dsdadant => CASE WHEN rw_crapceb.insitceb = 1 THEN 'ATIVO' ELSE 'INATIVO' END
                                 ,pr_dsdadatu => CASE WHEN pr_insitceb = 1 THEN 'ATIVO' ELSE 'INATIVO' END);
      END IF;
      
      --> Verificar se esta bloqueada
      IF vr_insitceb = 4 THEN
        vr_dsdmesag := 'Cobrança não liberada';
      --> Pendente  
      ELSIF vr_insitceb = 3 THEN
        --> Enviar email de convenio pendente
        DDDA0001.pc_email_alert_JDBNF ( pr_cdcooper  => vr_cdcooper,
                                        pr_nrdconta  => pr_nrdconta,
                                        pr_nrconven  => pr_nrconven,
                                        pr_nrcnvceb  => vr_nrcnvceb,
                                        pr_tpalerta  => 1, --> Convenio pendente
                                        pr_cdcritic  => vr_cdcritic,
                                        pr_dscritic  => vr_dscritic);
        vr_cdcritic := 0;
        vr_dscritic := 0;
        vr_dsdmesag := 'Adesão do produto em análise na CECRED. Dúvidas, entre em contato ' || 
                       'com a área de cobrança bancária.';
      END IF;
      
      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'flgimpri'
                            ,pr_tag_cont => vr_flgimpri
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'dsdmesag'
                            ,pr_tag_cont => vr_dsdmesag
                            ,pr_des_erro => vr_dscritic);

      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

        -- Gerar informacoes do log
        GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => GENE0001.vr_vet_des_origens(vr_idorigem)
                            ,pr_dstransa => 'Incluir/Alterar convenio de cobranca'
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 0 --> FALSE
                            ,pr_hrtransa => GENE0002.fn_busca_time
                            ,pr_idseqttl => 1
                            ,pr_nmdatela => 'COBRANCA'
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
                            
        IF cr_DDA_Benef%ISOPEN THEN CLOSE cr_DDA_Benef; END IF;
        IF cr_DDA_Conven%ISOPEN THEN CLOSE cr_DDA_Conven; END IF;
        
        COMMIT;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela TELA_ATENDA_COBRAN: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
                                       
        IF cr_DDA_Benef%ISOPEN THEN CLOSE cr_DDA_Benef; END IF;
        IF cr_DDA_Conven%ISOPEN THEN CLOSE cr_DDA_Conven; END IF;
                                       
        ROLLBACK;
    END;

  END pc_habilita_convenio;

  PROCEDURE pc_busca_config_conv(pr_nrconven  IN crapcco.nrconven%TYPE --> Convenio
                                ,pr_xmllog    IN VARCHAR2 --> XML com informacoes de LOG
                                ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_busca_config_conv
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Marco/2016                 Ultima atualizacao: 08/07/2016

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar a configuracao do convenio selecionado.

    Alteracoes: 08/07/2016 - Envio da flag Serasa (Marcos-Supero)
    ..............................................................................*/
    DECLARE

      -- Busca o cadastro de convenio
      CURSOR cr_cco_prc(pr_cdcooper IN crapcco.cdcooper%TYPE
                       ,pr_nrconven IN crapcco.nrconven%TYPE) IS
        SELECT cco.qtdfloat
              ,cco.qtfltate
              ,cco.flrecipr
              ,cco.idprmrec
              ,cco.fldctman
              ,cco.perdctmx
              ,prc.perdesconto_maximo perdesconto_maximo_recipro
              ,cco.flgapvco
              ,cco.flprotes
              ,cco.flserasa
              ,cco.qtdecini
              ,cco.qtdecate
              ,cco.cddbanco
              ,cco.flgregis
      FROM tbrecip_parame_calculo prc
          ,crapcco cco
     WHERE cco.idprmrec = prc.idparame_reciproci (+) -- Outer pois nem sempre havera PRC
       AND cco.cdcooper = pr_cdcooper
       AND cco.nrconven = pr_nrconven;
      rw_cco_prc cr_cco_prc%ROWTYPE;

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

    BEGIN
      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Busca o cadastro de convenio
      OPEN cr_cco_prc(pr_cdcooper => vr_cdcooper
                     ,pr_nrconven => pr_nrconven);
      FETCH cr_cco_prc INTO rw_cco_prc;
      
      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'qtdfloat'
                            ,pr_tag_cont => rw_cco_prc.qtdfloat
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'qtfltate'
                            ,pr_tag_cont => rw_cco_prc.qtfltate
                            ,pr_des_erro => vr_dscritic);
      
      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'flrecipr'
                            ,pr_tag_cont => rw_cco_prc.flrecipr
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'idprmrec'
                            ,pr_tag_cont => rw_cco_prc.idprmrec
                            ,pr_des_erro => vr_dscritic);
      
      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'fldctman'
                            ,pr_tag_cont => rw_cco_prc.fldctman
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'perdctmx'
                            ,pr_tag_cont => rw_cco_prc.perdctmx
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'perdesconto_maximo_recipro'
                            ,pr_tag_cont => rw_cco_prc.perdesconto_maximo_recipro
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'flgapvco'
                            ,pr_tag_cont => rw_cco_prc.flgapvco
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'flprotes'
                            ,pr_tag_cont => rw_cco_prc.flprotes
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'flserasa'
                            ,pr_tag_cont => rw_cco_prc.flserasa
                            ,pr_des_erro => vr_dscritic);                      

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'qtdecini'
                            ,pr_tag_cont => rw_cco_prc.qtdecini
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'qtdecate'
                            ,pr_tag_cont => rw_cco_prc.qtdecate
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'cddbanco'
                            ,pr_tag_cont => rw_cco_prc.cddbanco
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'flgregis'
                            ,pr_tag_cont => rw_cco_prc.flgregis
                            ,pr_des_erro => vr_dscritic);

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela TELA_ATENDA_COBRAN: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_busca_config_conv;

  PROCEDURE pc_busca_categoria(pr_nrdconta  IN crapass.nrdconta%TYPE --> Conta
                              ,pr_nrconven  IN crapcco.nrconven%TYPE --> Convenio
                              ,pr_xmllog    IN VARCHAR2 --> XML com informacoes de LOG
                              ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                              ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                              ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_busca_categoria
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Marco/2016                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar as categorias com base nas tarifas vinculadas.

    Alteracoes: 
    ..............................................................................*/
    DECLARE

      -- Busca as categorias
      CURSOR cr_cat_sgr(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE
                       ,pr_nrconven IN crapcco.nrconven%TYPE) IS
        SELECT INITCAP(sgr.dssubgru) dssubgru
              ,cat.cdcatego
              ,INITCAP(cat.dscatego) dscatego
              ,cat.fldesman
              ,cat.flrecipr
              ,cat.flcatcee
              ,cat.flcatcoo
              ,DECODE(ctc.perdesconto, NULL, 0, ctc.perdesconto) perdesconto
          FROM crapcat cat
              ,crapsgr sgr
              ,tbcobran_categ_tarifa_conven ctc
         WHERE cat.cdsubgru = sgr.cdsubgru
           AND cat.cdtipcat = 2 -- Cobranca
           AND ctc.cdcatego(+) = cat.cdcatego
           AND ctc.cdcooper(+) = pr_cdcooper
           AND ctc.nrdconta(+) = pr_nrdconta
           AND ctc.nrconven(+) = pr_nrconven
      ORDER BY cat.flcatcee + cat.flcatcoo DESC -- COO E CEE Antes
              ,sgr.cdsubgru
              ,cat.dscatego;

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      -- Variaveis gerais
      vr_cont_cat PLS_INTEGER := 0;
      vr_cont_sub PLS_INTEGER := -1;
      vr_ultsubgru VARCHAR2(60) := ' ';

    BEGIN
      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      -- Cadastro das categorias
      FOR rw_cat_sgr IN cr_cat_sgr(pr_cdcooper => vr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_nrconven => pr_nrconven) LOOP

        -- Se for um novo sub grupo
        IF vr_ultsubgru <> rw_cat_sgr.dssubgru THEN
          vr_cont_sub := vr_cont_sub + 1;

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Dados'
                                ,pr_posicao  => 0
                                ,pr_tag_nova => 'subgrupo'
                                ,pr_tag_cont => NULL
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_gera_atributo(pr_xml   => pr_retxml
                                   ,pr_tag   => 'subgrupo'
                                   ,pr_atrib => 'dssubgru'
                                   ,pr_atval => rw_cat_sgr.dssubgru
                                   ,pr_numva => vr_cont_sub
                                   ,pr_des_erro => vr_dscritic);

          vr_ultsubgru := rw_cat_sgr.dssubgru;
        END IF;

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'subgrupo'
                              ,pr_posicao  => vr_cont_sub
                              ,pr_tag_nova => 'categoria'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'categoria'
                              ,pr_posicao  => vr_cont_cat
                              ,pr_tag_nova => 'cdcatego'
                              ,pr_tag_cont => rw_cat_sgr.cdcatego
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'categoria'
                              ,pr_posicao  => vr_cont_cat
                              ,pr_tag_nova => 'dscatego'
                              ,pr_tag_cont => rw_cat_sgr.dscatego
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'categoria'
                              ,pr_posicao  => vr_cont_cat
                              ,pr_tag_nova => 'fldesman'
                              ,pr_tag_cont => rw_cat_sgr.fldesman
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'categoria'
                              ,pr_posicao  => vr_cont_cat
                              ,pr_tag_nova => 'flrecipr'
                              ,pr_tag_cont => rw_cat_sgr.flrecipr
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'categoria'
                              ,pr_posicao  => vr_cont_cat
                              ,pr_tag_nova => 'flcatcee'
                              ,pr_tag_cont => rw_cat_sgr.flcatcee
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'categoria'
                              ,pr_posicao  => vr_cont_cat
                              ,pr_tag_nova => 'flcatcoo'
                              ,pr_tag_cont => rw_cat_sgr.flcatcoo
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'categoria'
                              ,pr_posicao  => vr_cont_cat
                              ,pr_tag_nova => 'perdesconto'
                              ,pr_tag_cont => rw_cat_sgr.perdesconto
                              ,pr_des_erro => vr_dscritic);

        vr_cont_cat := vr_cont_cat + 1;
      END LOOP;

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela TELA_ATENDA_COBRAN: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_busca_categoria;

  PROCEDURE pc_busca_tarifa(pr_nrconven  IN crapceb.nrconven%TYPE --> Convenio
                           ,pr_cdcatego  IN crapcat.cdcatego%TYPE --> Convenio
                           ,pr_inpessoa  IN craptar.inpessoa%TYPE --> Tipo de pessoa
                           ,pr_xmllog    IN VARCHAR2 --> XML com informacoes de LOG
                           ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                           ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                           ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_busca_tarifa
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Marco/2016                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar as tarifas com base nas categorias.

    Alteracoes: 
    ..............................................................................*/
    DECLARE

      -- Busca as tarifas
      CURSOR cr_tar_inc(pr_cdcatego IN craptar.cdcatego%TYPE
                       ,pr_inpessoa IN craptar.inpessoa%TYPE) IS
        SELECT tar.cdtarifa
              ,tar.dstarifa
              ,inc.dsinctar
              ,tar.cdocorre
              ,tar.cdmotivo
          FROM craptar tar
              ,crapint inc 
         WHERE tar.cdinctar = inc.cdinctar
           AND tar.cdcatego = pr_cdcatego
           AND tar.inpessoa = pr_inpessoa;

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
      vr_tab_erro GENE0001.typ_tab_erro;

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      -- Variaveis Gerais
      vr_cdhistor INTEGER;
      vr_cdhisest INTEGER;
      vr_vltarifa NUMBER;
      vr_dtdivulg DATE;
      vr_dtvigenc DATE;
      vr_cdfvlcop INTEGER;
      vr_contador INTEGER := 0;

    BEGIN
      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      -- Cadastro das tarifas
      FOR rw_tar_inc IN cr_tar_inc(pr_cdcatego => pr_cdcatego
                                  ,pr_inpessoa => pr_inpessoa) LOOP
        -- Busca o valor da tarifa
        TARI0001.pc_carrega_dados_tarifa_cobr
                (pr_cdcooper => vr_cdcooper
                ,pr_nrconven => pr_nrconven
                ,pr_dsincide => rw_tar_inc.dsinctar 
                ,pr_cdocorre => rw_tar_inc.cdocorre
                ,pr_cdmotivo => rw_tar_inc.cdmotivo
                ,pr_inpessoa => pr_inpessoa
                ,pr_vllanmto => 0.01 -- Usaremos o valor ficticio minimo
                ,pr_cdprogra => 'ATENDA'
				,pr_flaputar => 0 -- Nao apurar
                ,pr_cdhistor => vr_cdhistor
                ,pr_cdhisest => vr_cdhisest
                ,pr_vltarifa => vr_vltarifa
                ,pr_dtdivulg => vr_dtdivulg
                ,pr_dtvigenc => vr_dtvigenc
                ,pr_cdfvlcop => vr_cdfvlcop
                ,pr_cdcritic => vr_cdcritic
                ,pr_dscritic => vr_dscritic);
        -- Se ocorrer erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          vr_vltarifa := 0;
        END IF;

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'tarifa'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'tarifa'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'cdtarifa'
                              ,pr_tag_cont => rw_tar_inc.cdtarifa
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'tarifa'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'dstarifa'
                              ,pr_tag_cont => rw_tar_inc.dstarifa
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'tarifa'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'vltarifa'
                              ,pr_tag_cont => vr_vltarifa
                              ,pr_des_erro => vr_dscritic);

        vr_contador := vr_contador + 1;
      END LOOP;

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela TELA_ATENDA_COBRAN: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_busca_tarifa;

  PROCEDURE pc_verifica_apuracao(pr_nrdconta  IN crapceb.nrdconta%TYPE --> Conta
                                ,pr_nrconven  IN crapceb.nrconven%TYPE --> Convenio
                                ,pr_xmllog    IN VARCHAR2 --> XML com informacoes de LOG
                                ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_verifica_apuracao
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Abril/2016                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para verificar se existe apuracao de reciprocidade.

    Alteracoes: 
    ..............................................................................*/

    DECLARE

      -- Verifica se possui apuracao em aberto
      CURSOR cr_apuracao(pr_cdcooper IN crapceb.cdcooper%TYPE
                        ,pr_nrdconta IN crapceb.nrdconta%TYPE
                        ,pr_nrconven IN crapceb.nrconven%TYPE) IS
        SELECT COUNT(1)
          FROM tbrecip_apuracao apr
         WHERE apr.cdcooper         = pr_cdcooper
           AND apr.nrdconta         = pr_nrdconta
           AND apr.cdchave_produto  = pr_nrconven
           AND apr.cdproduto        = 6; -- Cobranca

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis
      vr_qtapurac NUMBER;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

    BEGIN
      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Verifica se possui apuracao
      OPEN cr_apuracao(pr_cdcooper => vr_cdcooper
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_nrconven => pr_nrconven);
      FETCH cr_apuracao INTO vr_qtapurac;
      -- Fecha cursor
      CLOSE cr_apuracao;
      
      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'qtapurac'
                            ,pr_tag_cont => vr_qtapurac
                            ,pr_des_erro => vr_dscritic);

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela TELA_ATENDA_COBRAN: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

    END;


  END pc_verifica_apuracao;

  PROCEDURE pc_gera_arq_ajuda(pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                             ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2             --Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2) IS         --Erros do processo
  /* .............................................................................
  
    Programa: pc_gera_arq_ajuda
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Abril/2016                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para gerar o arquivo de ajuda.

    Alteracoes: 
  ..............................................................................*/

    --Variaveis do Clob
    vr_clobxml CLOB;
    vr_dstexto VARCHAR2(32767);
    
    --Variaveis Locais
    vr_cdcooper       INTEGER;
    vr_cdoperad       VARCHAR2(100);
    vr_nmdatela       VARCHAR2(100);
    vr_nmeacao        VARCHAR2(100);
    vr_cdagenci       VARCHAR2(100);
    vr_nrdcaixa       VARCHAR2(100);
    vr_idorigem       VARCHAR2(100);
    vr_nmdireto       VARCHAR2(1000);
    vr_nmarqimp       VARCHAR2(1000);
    vr_nmarquiv       VARCHAR2(1000);
    vr_comando        VARCHAR2(1000);
       
    --Variaveis de Erro
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3);
    vr_tab_erro GENE0001.typ_tab_erro;
    
    --Variaveis de Excecao
    vr_exc_saida EXCEPTION;
         
    BEGIN
      --Inicializar Variavel
      vr_cdcritic:= 0;
      vr_dscritic:= NULL;

      -- Extrair dados do XML de requisição
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Diretorio para salvar
      vr_nmdireto := GENE0001.fn_diretorio (pr_tpdireto => 'C' --> usr/coop
                                           ,pr_cdcooper => vr_cdcooper
                                           ,pr_nmsubdir => 'rl'); 

      -- Nome Arquivo
      vr_nmarqimp := dbms_random.string('X',20) || '.pdf';

      -- Inicializar as informações do XML de dados para o relatório
      dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);

      --Escrever no arquivo XML
      GENE0002.pc_escreve_xml(vr_clobxml,vr_dstexto,
        '<?xml version="1.0" encoding="UTF-8"?><raiz></raiz>',TRUE);

      -- Gera relatório
      GENE0002.pc_solicita_relato(pr_cdcooper  => vr_cdcooper                   --> Cooperativa conectada
                                 ,pr_cdprogra  => 'IMPRES'                      --> Programa chamador
                                 ,pr_dtmvtolt  => NULL                          --> Data do movimento atual
                                 ,pr_dsxml     => vr_clobxml                    --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/raiz'                       --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'recipr_simcrp.jasper'        --> Arquivo de layout do iReport
                                 ,pr_dsparams  => NULL                          --> Sem parâmetros                                         
                                 ,pr_dsarqsaid => vr_nmdireto||'/'||vr_nmarqimp --> Arquivo final com o path
                                 ,pr_qtcoluna  => 132                           --> Colunas do relatorio
                                 ,pr_flg_gerar => 'S'                           --> Geraçao na hora
                                 ,pr_flg_impri => 'N'                           --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => '132col'                      --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1                             --> Número de cópias
                                 ,pr_cdrelato  => 73                            --> Codigo do Relatorio
                                 ,pr_des_erro  => vr_dscritic);                 --> Saída com erro
      --Se ocorreu erro no relatorio
      IF vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_saida;
      END IF; 

      --Fechar Clob e Liberar Memoria  
      dbms_lob.close(vr_clobxml);
      dbms_lob.freetemporary(vr_clobxml);

      -- Ayllos Web       
      IF vr_idorigem = 5 THEN

        --Enviar arquivo para Web
        GENE0002.pc_efetua_copia_pdf(pr_cdcooper => vr_cdcooper
                                    ,pr_cdagenci => vr_cdagenci
                                    ,pr_nrdcaixa => vr_nrdcaixa
                                    ,pr_nmarqpdf => vr_nmdireto || '/' || vr_nmarqimp
                                    ,pr_des_reto => vr_des_reto
                                    ,pr_tab_erro => vr_tab_erro);
        --Se ocorreu erro
        IF vr_des_reto = 'NOK' THEN
          --Se tem erro na tabela 
          IF vr_tab_erro.COUNT > 0 THEN
            --Mensagem Erro
            vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          ELSE
            vr_dscritic:= 'Erro ao enviar arquivo para web.';  
          END IF; 
          --Sair 
          RAISE vr_exc_saida;
        END IF;
        
        -- Comando para remover arquivo do rl
        vr_comando:= 'rm '||vr_nmdireto || '/' || vr_nmarqimp||' 2>/dev/null';

        --Remover Arquivo pre-existente
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => vr_comando
                             ,pr_typ_saida   => vr_des_reto
                             ,pr_des_saida   => vr_dscritic);
        --Se ocorreu erro dar RAISE
        IF vr_des_reto = 'ERR' THEN
          RAISE vr_exc_saida;
        END IF;

      END IF;

      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'nmarqpdf', pr_tag_cont => vr_nmarqimp, pr_des_erro => vr_dscritic);

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela TELA_ATENDA_COBRAN: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

  END pc_gera_arq_ajuda;

  --> Rotina para ativar convenio
  PROCEDURE pc_ativar_convenio( pr_nrdconta  IN crapceb.nrdconta%TYPE --> Conta
                               ,pr_nrconven  IN crapceb.nrconven%TYPE --> Convenio
                               ,pr_nrcnvceb  IN crapceb.nrcnvceb%TYPE --> Ceb
                               ,pr_xmllog    IN VARCHAR2              --> XML com informacoes de LOG
                               ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                               ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                               ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo
  

  /* .............................................................................

    Programa: pc_ativar_convenio          
    Sistema : Ayllos Web
    Autor   : Odirlei Busana - AMcom
    Data    : Abril/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para ativar convenio.

    Alteracoes:
  ..............................................................................*/
    
    ------------> CURSORES <------------
    
    -- Cadastro de associados
    CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT to_char(crapass.nrdconta) nrdconta
            ,crapass.inpessoa
            ,decode(crapass.inpessoa,1,lpad(crapass.nrcpfcgc,11,'0'),
                                       lpad(crapass.nrcpfcgc,14,'0')) dscpfcgc
            ,decode(crapass.inpessoa,1,'F','J') dspessoa
            ,crapass.nmprimtl
            ,to_char(crapass.nrcpfcgc) nrcpfcgc
            ,to_char(crapcop.cdagectl) cdagectl
        FROM crapass,
             crapcop 
       WHERE crapass.cdcooper = crapcop.cdcooper
         AND crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
    
    
    -- Cadastro de Bloquetos
    CURSOR cr_crapceb(pr_cdcooper IN crapceb.cdcooper%TYPE
                     ,pr_nrdconta IN crapceb.nrdconta%TYPE
                     ,pr_nrconven IN crapceb.nrconven%TYPE
                     ,pr_nrcnvceb IN crapceb.nrcnvceb%TYPE) IS
      SELECT crapceb.insitceb
        FROM crapceb
       WHERE crapceb.cdcooper = pr_cdcooper
         AND crapceb.nrdconta = pr_nrdconta
         AND crapceb.nrconven = pr_nrconven
         AND crapceb.nrcnvceb = pr_nrcnvceb;
    rw_crapceb cr_crapceb%ROWTYPE;
    
    --> Cursor para verificar se ja existe o beneficiario na cip
    CURSOR cr_DDA_Benef (pr_dspessoa VARCHAR2,
                         pr_nrcpfcgc crapass.nrcpfcgc%TYPE) IS      
      SELECT 1
        FROM cecredleg.TBJDDDABNF_BeneficiarioIF@jdnpcsql b
       WHERE b.ISPB_IF = '05463212'
         AND "TpPessoaBenfcrio" = pr_dspessoa
         AND "CNPJ_CPFBenfcrio" = pr_nrcpfcgc;
    rw_DDA_Benef cr_DDA_Benef%ROWTYPE;    
    
    --> Cursor para verificar se ja existe o convenio na cip
    CURSOR cr_DDA_Conven (pr_dspessoa VARCHAR2,
                          pr_nrcpfcgc crapass.nrcpfcgc%TYPE,
                          pr_nrconven VARCHAR2) IS      
      SELECT 1
        FROM cecredleg.TBJDDDABNF_Convenio@jdnpcsql b
       WHERE b."ISPB_IF" = '05463212'
         AND b."TpPessoaBenfcrio" = pr_dspessoa
         AND b."CNPJ_CPFBenfcrio" = pr_nrcpfcgc
         AND b."CodCli_Conv"      = pr_nrconven;
    rw_DDA_Conven cr_DDA_Conven%ROWTYPE;      
    
    --> Buscar dados pessoa juridica
    CURSOR cr_crapjur (pr_cdcooper crapjur.cdcooper%TYPE,
                       pr_nrdconta crapjur.nrdconta%TYPE) IS
      SELECT jur.nmfansia
        FROM crapjur  jur
       WHERE jur.cdcooper = pr_cdcooper
         AND jur.nrdconta = pr_nrdconta; 
    rw_crapjur cr_crapjur%ROWTYPE;        
    
    -- Cursor generico de calendario
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
    ------------> VARIAVEIS <-----------  
    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(2000);

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    
    vr_nrdrowid ROWID;
    vr_dstransa VARCHAR2(1000);
    vr_dsdmesag VARCHAR2(1000);
    vr_flgimpri PLS_INTEGER;
    
    vr_dtativac VARCHAR2(8);
    vr_nrconven VARCHAR2(10);
    vr_sitifcnv VARCHAR2(10) := 'A';
    vr_dsdtmvto VARCHAR2(10);
    vr_insitif  VARCHAR2(10);
    vr_insitcip VARCHAR2(10);
    vr_dtfimrel VARCHAR2(10) := NULL;
    
    
  BEGIN
    -- Extrai os dados vindos do XML
    GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
  
    -- Seta a descricao da transacao
    vr_dstransa := 'Ativar convenio de cobranca.';
    
    -- Cadastro de associados
    OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                   ,pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    -- Se NAO encontrou
    IF cr_crapass%NOTFOUND THEN
      vr_cdcritic := 9;
      CLOSE cr_crapass;
      RAISE vr_exc_saida;
    END IF;
    CLOSE cr_crapass;
    
    -- Verificacao do calendario
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    CLOSE BTCH0001.cr_crapdat;
    
    -- Cadastro de bloquetos
    OPEN cr_crapceb(pr_cdcooper => vr_cdcooper
                   ,pr_nrdconta => pr_nrdconta
                   ,pr_nrconven => pr_nrconven
                   ,pr_nrcnvceb => pr_nrcnvceb);
    FETCH cr_crapceb INTO rw_crapceb;
    CLOSE cr_crapceb;
      
    --> Atualizar convenio
    BEGIN
      UPDATE crapceb 
         SET insitceb = 1 -- ATIVO
	   WHERE cdcooper = vr_cdcooper
	     AND nrdconta = pr_nrdconta
	     AND nrconven = pr_nrconven
         AND nrcnvceb = pr_nrcnvceb;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Nao foi possivel atualizar crapceb: '||SQLERRM;
        RAISE vr_exc_saida;     
    END; 
    
    --> Gravar o log de adesao ou bloqueio do convenio
    COBR0008.pc_gera_log_ceb 
                    (pr_idorigem  => vr_idorigem,
                     pr_cdcooper  => vr_cdcooper,
                     pr_cdoperad  => vr_cdoperad,
                     pr_nrdconta  => pr_nrdconta,
                     pr_nrconven  => pr_nrconven,
                     pr_dstransa  => vr_dstransa,
                     pr_insitceb_ant => nvl(rw_crapceb.insitceb,0), --Antes de alterar
                     pr_insitceb  => 1, -- 'ATIVO'
                     pr_dscritic  => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF; 
    
    --> Verificar se ja existe o beneficiario na cip
    OPEN cr_DDA_Benef (pr_dspessoa => rw_crapass.dspessoa,
                       pr_nrcpfcgc => rw_crapass.nrcpfcgc);
    FETCH cr_DDA_Benef INTO rw_DDA_Benef;
    IF cr_DDA_Benef%NOTFOUND THEN
      IF rw_crapass.inpessoa = 2 THEN
        --> Buscar dados pessoa juridica
        OPEN cr_crapjur (pr_cdcooper => vr_cdcooper,
                         pr_nrdconta => pr_nrdconta);
        FETCH cr_crapjur INTO rw_crapjur;
        CLOSE cr_crapjur;
      END IF;  
            
      vr_dsdtmvto := to_char(rw_crapdat.dtmvtolt,'RRRRMMDD');
                    
      BEGIN
        INSERT INTO cecredleg.TBJDDDABNF_BeneficiarioIF@jdnpcsql
              ( "ISPB_IF",
                "TpPessoaBenfcrio",
                "CNPJ_CPFBenfcrio",
                "Nom_RzSocBenfcrio", 
                "Nom_FantsBenfcrio", 
                "DtInicRelctPart",    
                "DtFimRelctPart")
        VALUES ('05463212'           -- ISPB_IF
               ,rw_crapass.dspessoa  -- TpPessoaBenfcrio
               ,rw_crapass.dscpfcgc  -- CNPJ_CPFBenfcrio
               ,rw_crapass.nmprimtl  -- Nom_RzSocBenfcrio 
               ,rw_crapjur.nmfansia  -- Nom_FantsBenfcrio 
               ,vr_dsdtmvto          -- DtInicRelctPart    
               ,NULL);               -- DtFimRelctPart    
            
      EXCEPTION 
        WHEN OTHERS THEN
          vr_dscritic := 'Nao foi possivel cadastrar Beneficiario na CIP: ' || SQLERRM;
          RAISE vr_exc_saida;              
      END;

    ELSE    
    
      -- Atualizar convenio na CIP  
      BEGIN      
        vr_dtativac := to_char(rw_crapdat.dtmvtolt,'RRRRMMDD');
        vr_nrconven := to_char(pr_nrconven);
        UPDATE cecredleg.TBJDDDABNF_Convenio@jdnpcsql
           SET TBJDDDABNF_Convenio."SitConvBenfcrioPar" = 'A',
               TBJDDDABNF_Convenio."DtInicRelctConv"    = vr_dtativac
         WHERE TBJDDDABNF_Convenio."ISPB_IF" = '05463212'
           AND TBJDDDABNF_Convenio."TpPessoaBenfcrio" = rw_crapass.dspessoa
           AND TBJDDDABNF_Convenio."CNPJ_CPFBenfcrio" = rw_crapass.dscpfcgc
           AND TBJDDDABNF_Convenio."CodCli_Conv"      = vr_nrconven
           AND TBJDDDABNF_Convenio."AgDest"           = rw_crapass.cdagectl
           AND TBJDDDABNF_Convenio."CtDest"           = rw_crapass.nrdconta;
        
      EXCEPTION 
        WHEN OTHERS THEN
          vr_dscritic := 'Nao foi possivel atualizar convenio na CIP: '||SQLERRM;
          RAISE vr_exc_saida;
      END;
      
    END IF;
    
    CLOSE cr_DDA_Benef;
    
    --> Verificar se ja existe o convenio na cip
    OPEN cr_DDA_Conven (pr_dspessoa => rw_crapass.dspessoa,
                        pr_nrcpfcgc => rw_crapass.nrcpfcgc,
                        pr_nrconven => to_char(pr_nrconven));
    FETCH cr_DDA_Conven INTO rw_DDA_Conven;
    IF cr_DDA_Conven%NOTFOUND THEN
      --> Gerar informação de adesão de convênio ao JDBNF                            
      BEGIN
        INSERT INTO cecredleg.TBJDDDABNF_Convenio@jdnpcsql 
                   ("ISPB_IF",
                    "ISPBPartIncorpd",
                    "TpPessoaBenfcrio",
                    "CNPJ_CPFBenfcrio",
                    "CodCli_Conv",
                    "SitConvBenfcrioPar",
                    "DtInicRelctConv",
                    "DtFimRelctConv",
                    "TpAgDest",
                    "AgDest",
                    "TpCtDest",
                    "CtDest",
                    "TpProdtConv",
                    "TpCartConvCobr" )
             VALUES('05463212',                             -- ISPB_IF
                    NULL,                                   -- ISPBPartIncorpd
                    rw_crapass.dspessoa,                    -- TpPessoaBenfcrio
                    rw_crapass.dscpfcgc,                    -- CNPJ_CPFBenfcrio
                    pr_nrconven,                            -- CodCli_Conv
                    vr_sitifcnv,                            -- SitConvBenfcrioPar
                    vr_dsdtmvto,                            -- DtInicRelctConv
                    vr_dtfimrel,                            -- DtFimRelctConv
                    'F',                                    -- TpAgDest (F=Fisica)
                    rw_crapass.cdagectl,                    -- AgDest
                    'CC',                                   -- TpCtDest
                    rw_crapass.nrdconta,                    -- CtDest
                    '01', -- boleto de cobranca             -- TpProdtConv
                    '1' );-- com registro                   -- TpCartConvCobr
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Nao foi possivel registrar convenio na CIP: ' || SQLERRM;
          RAISE vr_exc_saida;              
      END;
    ELSE
      BEGIN
        vr_nrconven := to_char(pr_nrconven);
        vr_dsdtmvto := to_char(rw_crapdat.dtmvtolt,'RRRRMMDD');          
        UPDATE cecredleg.TBJDDDABNF_Convenio@jdnpcsql a
           SET a."SitConvBenfcrioPar" = vr_sitifcnv
              ,a."DtInicRelctConv"    = vr_dsdtmvto
              ,a."DtFimRelctConv"     = vr_dtfimrel
         WHERE a."ISPB_IF"            = '05463212'
           AND a."TpPessoaBenfcrio"   = rw_crapass.dspessoa
           AND a."CNPJ_CPFBenfcrio"   = rw_crapass.dscpfcgc
           AND a."CodCli_Conv"        = vr_nrconven;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Nao foi possivel atualizar convenio na CIP: ' || SQLERRM;
            RAISE vr_exc_saida;              
        END;            
    END IF;
    CLOSE cr_DDA_Conven;    
    
    --> Tratar retorno
    vr_dsdmesag := gene0007.fn_acento_xml('Convênio ativado com sucesso.');
    -- sempre gerar impressao na ativacao
    vr_flgimpri := 1;     
    
    -- Criar cabecalho do XML
    pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Root'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'Dados'
                          ,pr_tag_cont => NULL
                          ,pr_des_erro => vr_dscritic);

    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'flgimpri'
                          ,pr_tag_cont => vr_flgimpri
                          ,pr_des_erro => vr_dscritic);

    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'dsdmesag'
                          ,pr_tag_cont => vr_dsdmesag
                          ,pr_des_erro => vr_dscritic); 
                          
    IF cr_DDA_Benef%ISOPEN THEN CLOSE cr_DDA_Benef; END IF;
    IF cr_DDA_Conven%ISOPEN THEN CLOSE cr_DDA_Conven; END IF;                          
    
    COMMIT;
  
  EXCEPTION
    WHEN vr_exc_saida THEN
      
      IF cr_DDA_Benef%ISOPEN THEN CLOSE cr_DDA_Benef; END IF;
      IF cr_DDA_Conven%ISOPEN THEN CLOSE cr_DDA_Conven; END IF;
    
      IF vr_cdcritic <> 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;

      -- Gerar informacoes do log
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => vr_dscritic
                          ,pr_dsorigem => GENE0001.vr_vet_des_origens(vr_idorigem)
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0 --> FALSE
                          ,pr_hrtransa => GENE0002.fn_busca_time
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'COBRANCA'
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      COMMIT;

    WHEN OTHERS THEN
      
      IF cr_DDA_Benef%ISOPEN THEN CLOSE cr_DDA_Benef; END IF;
      IF cr_DDA_Conven%ISOPEN THEN CLOSE cr_DDA_Conven; END IF;
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina pc_ativar_convenio: ' || SQLERRM;

      -- Carregar XML padrão para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_ativar_convenio;    
  
  --> Retornar lista com os log do convenio ceb
  PROCEDURE pc_consulta_log_conv_web(pr_nrdconta IN crawepr.nrdconta%TYPE --> Nr. da Conta
                                   ,pr_nrconven IN crapceb.nrconven%TYPE --> Nr. do convenio
                                   ,pr_nrcnvceb IN crapceb.nrcnvceb%TYPE --> Nr. do ceb
                                   ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    /* .............................................................................
    
        Programa: pc_consulta_log_ceb_web
        Sistema : CECRED
        Sigla   : COBRAN
        Autor   : Odirlei Busana - AMcom
        Data    : Maio/16.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Retornar lista com os log do convenio ceb
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
    ---------> CURSORES <--------
    --> Buscar logs
    CURSOR cr_TBCOBRAN_LOG_CONV ( pr_cdcooper crapceb.cdcooper%TYPE,
                                  pr_nrdconta crapceb.nrdconta%TYPE,
                                  pr_nrconven crapceb.nrconven%TYPE) IS
      SELECT to_char(log.dhlog,'DD/MM/RRRR HH24:MI:SS') dthorlog
            ,log.dslog
            ,ope.nmoperad
        FROM TBCOBRAN_LOG_CONV log
            ,crapope   ope
       WHERE log.cdcooper = pr_cdcooper
         AND log.nrdconta = pr_nrdconta
         AND log.nrconven = pr_nrconven
         AND ope.cdcooper = log.cdcooper
         AND ope.cdoperad = log.cdoperad
         ORDER BY log.dhlog DESC;
    
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    
    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    -- Variáveis para armazenar as informações em XML
    vr_des_xml         CLOB;
    -- Variável para armazenar os dados do XML antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);
      
    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    END;
  BEGIN
    
    pr_des_erro := 'OK';
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);
    
    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;
    
    -- Leitura da PL/Table e geração do arquivo XML
    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    -- Inicilizar as informações do XML
    vr_texto_completo := NULL;
    pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1"?><root><dados>');
    
    --> buscar logs ceb
    FOR rw_log IN cr_TBCOBRAN_LOG_CONV ( pr_cdcooper => vr_cdcooper,
                                         pr_nrdconta => pr_nrdconta,
                                         pr_nrconven => pr_nrconven) LOOP
      pc_escreve_xml('<inf>'||
                        '<dthorlog>' || rw_log.dthorlog ||'</dthorlog>' ||
                        '<dscdolog>' || rw_log.dslog    ||'</dscdolog>' ||
                        '<nmoperad>' || rw_log.nmoperad ||'</nmoperad>' ||
                     '</inf>');
    END LOOP;
    
    pc_escreve_xml('</dados></root>',TRUE);    
    
    pr_retxml := XMLType.createXML(vr_des_xml);
    
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;

  END pc_consulta_log_conv_web;     
  
  PROCEDURE pc_cancela_boletos(pr_cdcooper IN crapceb.cdcooper%TYPE  --> Codigo da cooperativa
                               ,pr_nrdconta IN crapceb.nrdconta%TYPE --> Conta
                               ,pr_nrconven IN crapceb.nrconven%TYPE --> Nro Convenio
                               ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
                                    
    --> Buscar boletos
    CURSOR cr_boletos (pr_cdcooper crapceb.cdcooper%TYPE,
                       pr_nrdconta crapceb.nrdconta%TYPE,
                       pr_nrconven crapceb.nrconven%TYPE) IS
      SELECT nrdconta,
             nrcnvcob,
             nrdocmto,
             insitcrt,
             insrvprt
        FROM crapcob
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrcnvcob = pr_nrconven
         AND dtdpagto IS NULL
         AND dtdbaixa IS NULL
         AND (insitcrt = 0 OR insitcrt = 1);
    rw_boletos cr_boletos%ROWTYPE;
      
    -- Cria o registro de data
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    
    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    -- Variáveis para armazenar as informações em XML
    vr_des_xml         CLOB;
    -- Variável para armazenar os dados do XML antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);
    
  BEGIN
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);
                             
    -- Abre o cursor de data
    OPEN btch0001.cr_crapdat(pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;
    
    FOR boleto IN cr_boletos(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta,
                    pr_nrconven => pr_nrconven)
    LOOP
      --dbms_output.put_line('Doc Nro: ' || boleto.nrdocmto);
        COBR0010.pc_grava_instr_boleto(pr_cdcooper => pr_cdcooper          --Codigo Cooperativa
                                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt  --Data Movimentacao
                                      ,pr_cdoperad => nvl(vr_cdoperad,'1') --Codigo Operador
                                      ,pr_cdinstru => 41                   --Codigo Instrucao
                                      ,pr_nrdconta => pr_nrdconta          --Nro Conta
                                      ,pr_nrcnvcob => pr_nrconven          --Nro Convenio
                                      ,pr_nrdocmto => boleto.nrdocmto      --Nro Documento
                                      ,pr_vlabatim => NULL                 --Valor Abatimento
                                      ,pr_dtvencto => NULL                 --Data Vencimento
                                      ,pr_qtdiaprt => NULL                 --Qtd dias
                                      ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                                      ,pr_dscritic => vr_dscritic);        --Descricao Critica
    END LOOP;
    
    CLOSE cr_boletos;
    
    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;

  END pc_cancela_boletos;      
  
  PROCEDURE pc_susta_boletos(pr_cdcooper IN crapceb.cdcooper%TYPE  --> Codigo da cooperativa
                               ,pr_nrdconta IN crapceb.nrdconta%TYPE --> Conta
                               ,pr_nrconven IN crapceb.nrconven%TYPE --> Nro Convenio
                               ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
                                    
    --> Buscar boletos
    CURSOR cr_boletos (pr_cdcooper crapceb.cdcooper%TYPE,
                       pr_nrdconta crapceb.nrdconta%TYPE,
                       pr_nrconven crapceb.nrconven%TYPE) IS
      SELECT nrdconta,
             nrcnvcob,
             nrdocmto,
             insitcrt,
             insrvprt
        FROM crapcob
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrcnvcob = pr_nrconven
         AND dtdpagto IS NULL
         AND dtdbaixa IS NULL
         AND (insitcrt = 2 OR insitcrt = 3);
    rw_boletos cr_boletos%ROWTYPE;
      
    -- Cria o registro de data
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    
    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    -- Variáveis para armazenar as informações em XML
    vr_des_xml         CLOB;
    -- Variável para armazenar os dados do XML antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);
    
  BEGIN
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);
                             
    -- Abre o cursor de data
    OPEN btch0001.cr_crapdat(vr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;
    
    FOR boleto IN cr_boletos(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta,
                    pr_nrconven => pr_nrconven)
    LOOP
      --dbms_output.put_line('Doc Nro: ' || boleto.nrdocmto);
        COBR0010.pc_grava_instr_boleto(pr_cdcooper => pr_cdcooper          --Codigo Cooperativa
                                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt  --Data Movimentacao
                                      ,pr_cdoperad => nvl(vr_cdoperad,'1') --Codigo Operador
                                      ,pr_cdinstru => 41                   --Codigo Instrucao
                                      ,pr_nrdconta => pr_nrdconta          --Nro Conta
                                      ,pr_nrcnvcob => pr_nrconven          --Nro Convenio
                                      ,pr_nrdocmto => boleto.nrdocmto      --Nro Documento
                                      ,pr_vlabatim => NULL                 --Valor Abatimento
                                      ,pr_dtvencto => NULL                 --Data Vencimento
                                      ,pr_qtdiaprt => NULL                 --Qtd dias
                                      ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                                      ,pr_dscritic => vr_dscritic);        --Descricao Critica
    END LOOP;
    
    CLOSE cr_boletos;
    
    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;

  END pc_susta_boletos;      

END TELA_ATENDA_COBRAN;
/
