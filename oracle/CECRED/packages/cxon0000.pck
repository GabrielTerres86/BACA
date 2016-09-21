CREATE OR REPLACE PACKAGE CECRED.cxon0000 AS

/*..............................................................................

   Programa: cxon0000                        Antigo: siscaixa/web/dbo/b1crap00.p
   Sistema : Caixa On-line
   Sigla   : CRED
   Autor   : Mirtes.
   Data    : Marco/2001                      Ultima atualizacao: 23/06/2016

   Dados referentes ao programa:

   Frequencia: Diario (Caixa Online).
   Objetivo  : Possui varias procedures uteis para todo o sistema.

   Alteracoes: 28/09/2005 - Passagem da cooperativa como parametro para as
                            procedures (Julio)

               22/02/2006 - Unificacao dos bancos - SQLWorks - Eder

               26/04/2007 - Usar 3 caracteres para o caixa na procedure
                            obtem-literal-autenticacao (Evandro).

               23/07/2007 - Criada a procedure grava-autenticacao-internet
                            para poder gravar a autenticacao com a data que for
                            enviada via parametro (Evandro).

               15/08/2007 - Alterada grava-autenticacao-internet para receber a
                            conta e titularidade para controle de erros;
                            Alterado para usar a data com crapdat.dtmvtocd
                            (Evandro).

               24/01/2008 - Alterado para nao permitir PAC 90 (internet) na
                            tela de identificacao (Elton).

               18/03/2008 - Tratar autenticacao guias GPS-BANCOOB (Evandro).

               20/05/2009 - Alterar tratamento para verificacao de registros
                            que estao com EXCLUSIVE-LOCK (David).

               04/01/2010 - Alterar tratamento para ultimo dia do ano (David).

               14/06/2010 - Tratamento para PAC 91, conforme PAC 90 (Elton).

               30/08/2010 - Incluido caminho completo para o destino dos
                            arquivos de log (Elton).

               20/10/2010 - Incluido caminho completo nas referencias do
                            diretorio spool (Elton).

               29/10/2010 - Incluido procedure atualiza-previa-caixa (Elton).

               13/07/2011 - Alteracao no formato do campo p-literal na procedure
                            obtem-literal-autenticacao (Adriano).

               08/08/2011 - Acerto na procedure atualiza-previa-caixa para nao
                            exibir mensagens de erro no log quando pagamento
                            for com dinheiro (Elton).

               30/09/2011 - Alterar diretorio spool para
                            /usr/coop/sistema/siscaixa/web/spool (Fernando).

               28/11/2011 - Alteracao de ajuste do dia 13/07/2011, pois quando
                            utilizado retorno COBAN, desconfigurava a aut.
                            Colocado ',' no format do valor para formar 48 pos.
                            (Guilherme).

               14/12/2011 - Continuacao da altera¿¿o acima pois RoundTable
                            nao mostrava dif de caracteres em branco(Guilherme)

               08/03/2012 - Alterado a composicao da autenticacao
                             (p-literal) para autenticacoes com data
                             >= 25/04/2012, na procedure
                             obtem-literal-autenticacao. (Fabricio)

               12/04/2013 - Adicionado procedure verifica-sangria-caixa.
                            (Fabricio)

               21/05/2013 - Altera¿¿es para gerar autentica¿¿o para DARFs (Lucas).

               22/05/2013 - Corre¿¿o autentica¿¿o para DARFs (Lucas).

               31/05/2013 - Limpar erro na valida conta (Gabriel).

               10/06/2013 - Corre¿¿o Buffer crapaut (Lucas).

               28/06/2013 - Convers¿o Progress para Oracle (Alisson - AMcom)

               16/04/2014 - Utilizar a funcao fn_sequence para buscar o maior valor
                            (Andrino/RKAM)

               16/07/2014 - Conversao de procedures atualiza-previa-caixa e
                            valida-agencia do fonte b1crap00 para
                            pc_atualiza_previa_cxa do e pc_valida_agencia
                            pacote CXON0000. (Andre Santos - SUPERO)

               02/10/2015 - Inclusao do tratamento do historico 1414 quando
                            internet banking - String Autenticacao
                            (Guilherme/SUPERO)
                            
               10/03/2016 - Incluir log na procedure pc_grava_autenticacao_internet 
                            caso ocorra erro na autenticacao (Lucas Ranghetti/Fabricio)
                            
               11/03/2016 - Incluir validacao na grava_autenticacao_-internet para 
                            nao ler a tabela crapcbl caso for o cdagenci 90 e 91
                            (Lucas Ranghetti/Fabricio)
                            
               21/03/2016 - Incluir validacao na grava_autenticacao para 
                            nao ler a tabela crapcbl caso for o cdagenci 90 e 91
                            (Lucas Ranghetti/Fabricio)
                            
               17/06/2016 - Implementacao da consulta dos dados contidos na
                            CRAPTAB, atraves da TABE0001.fn_busca_dstextab na
                            procedure pc_atualiza_previa_cxa.
                            (Carlos Rafael Tanholi).         
                            
               23/06/2016 - Correcao no cursor da crapbcx utilizando o indice 
                            correto sobre o campo cdopecxa.(Carlos Rafael Tanholi). 							
                                
  ..............................................................................*/

  /* Tipo de tabela para os dias da semana por extenso */
  TYPE typ_tab_dia IS VARRAY(7) OF VARCHAR2(3);

  /* Tipo de tabela para os meses abreviados */
  TYPE typ_tab_mes IS VARRAY(12) OF VARCHAR2(3);


  /* Vetor de memoria com os dias da semana por extenso */
  vr_tab_dia typ_tab_dia:= typ_tab_dia('DOM','SEG','TER','QUA','QUI','SEX','SAB');

  /* Vetor de memoria com os meses abreviados */
  vr_tab_mes typ_tab_mes:= typ_tab_mes('JAN','FEV','MAR','ABR','MAI','JUN',
                                       'JUL','AGO','SET','OUT','NOV','DEZ');

  /* Procedure para criar erro */
  PROCEDURE pc_cria_erro(pr_cdcooper IN INTEGER   --Codigo Cooperativa
                        ,pr_cdagenci IN INTEGER   --Codigo da Agencia
                        ,pr_nrdcaixa IN INTEGER   --Numero do Caixa
                        ,pr_cod_erro IN INTEGER   --Codigo do erro para gravar
                        ,pr_dsc_erro IN VARCHAR2  --Descricao do erro para gravar
                        ,pr_flg_erro IN BOOLEAN   --Flag Erro
                        ,pr_cdcritic OUT INTEGER --Codigo de retorno de erro
                        ,pr_dscritic OUT VARCHAR2); --Descricao de retorno de erro

  /* Procedure para gravar a autenticacao */
  PROCEDURE pc_grava_autenticacao (pr_cooper       IN INTEGER --Codigo Cooperativa
                                  ,pr_cod_agencia  IN INTEGER --Codigo Agencia
                                  ,pr_nro_caixa    IN INTEGER --Numero do caixa
                                  ,pr_cod_operador IN VARCHAR2 --Codigo Operador
                                  ,pr_valor        IN NUMBER   --Valor da transacao
                                  ,pr_docto        IN NUMBER   --Numero documento
                                  ,pr_operacao     IN BOOLEAN  --Indicador Operacao
                                  ,pr_status       IN VARCHAR2 --Status da Operacao
                                  ,pr_estorno      IN BOOLEAN  --Indicador Estorno
                                  ,pr_histor       IN INTEGER  --Historico
                                  ,pr_data_off     IN DATE     --Data Transacao
                                  ,pr_sequen_off   IN INTEGER  --Sequencia
                                  ,pr_hora_off     IN INTEGER  --Hora transcao
                                  ,pr_seq_aut_off  IN INTEGER  --Sequencia automatica
                                  ,pr_literal      OUT VARCHAR2 --Descricao literal
                                  ,pr_sequencia    OUT INTEGER  --Sequencia
                                  ,pr_registro     OUT ROWID    --ROWID do registro
                                  ,pr_cdcritic     OUT INTEGER     --C¿digo do erro
                                  ,pr_dscritic     OUT VARCHAR2);   --Descricao do erro

  /* Procedure para gravar autenticacao na internet */
  PROCEDURE pc_grava_autenticacao_internet (pr_cooper       IN INTEGER  --Codigo Cooperativa
                                           ,pr_nrdconta     IN INTEGER  --Numero da Conta
                                           ,pr_idseqttl     IN crapttl.idseqttl%TYPE --Sequencial do titular
                                           ,pr_cod_agencia  IN INTEGER  --Codigo Agencia
                                           ,pr_nro_caixa    IN INTEGER  --Numero do caixa
                                           ,pr_cod_operador IN VARCHAR2 --Codigo Operador
                                           ,pr_valor        IN NUMBER   --Valor da transacao
                                           ,pr_docto        IN NUMBER   --Numero documento
                                           ,pr_operacao     IN BOOLEAN  --Indicador Operacao
                                           ,pr_status       IN VARCHAR2 --Status da Operacao
                                           ,pr_estorno      IN BOOLEAN  --Indicador Estorno
                                           ,pr_histor       IN INTEGER  --Historico
                                           ,pr_data_off     IN DATE     --Data Transacao
                                           ,pr_sequen_off   IN INTEGER  --Sequencia
                                           ,pr_hora_off     IN INTEGER  --Hora transcao
                                           ,pr_seq_aut_off  IN INTEGER  --Sequencia automatica
                                           ,pr_cdempres     IN VARCHAR2 --Descricao Observacao
                                           ,pr_literal      OUT VARCHAR2 --Descricao literal
                                           ,pr_sequencia    OUT INTEGER  --Sequencia
                                           ,pr_registro     OUT ROWID    --ROWID do registro
                                           ,pr_cdcritic     OUT INTEGER     --C¿digo do erro
                                           ,pr_dscritic     OUT INTEGER);   --Descricao do erro

  /* Calcular Digito verificador IPTU e SAMAE Blumenau */
  PROCEDURE pc_calc_digito_iptu_samae (pr_valor    IN OUT VARCHAR2   --> Valor Calculado
                                      ,pr_nrdigito OUT INTEGER     --> Digito Verificador
                                      ,pr_retorno  OUT BOOLEAN);   --> Retorno digito correto

  /* Calcular Digito verificador Titulo */
  PROCEDURE pc_calc_digito_verif (pr_valor        IN OUT VARCHAR2   --> Valor Calculado
                                 ,pr_valida_zeros IN BOOLEAN      --> Validar Zeros
                                 ,pr_nro_digito   OUT INTEGER     --> Digito Verificador
                                 ,pr_retorno      OUT BOOLEAN);   --> Retorno digito correto

  /* Calcular Digito verificador Titulo */
  PROCEDURE pc_calc_digito_titulo (pr_valor        IN OUT VARCHAR2   --> Valor Calculado
                                  ,pr_retorno      OUT BOOLEAN);   --> Retorno digito correto

  /* Procedure para eliminar erros */
  PROCEDURE pc_elimina_erro (pr_cooper      IN INTEGER                    --Codigo cooperativa
                            ,pr_cod_agencia IN INTEGER                    --Codigo agencia
                            ,pr_nro_caixa   IN INTEGER                    --Numero Caixa
                            ,pr_cdcritic    OUT INTEGER     --Codigo do erro
                            ,pr_dscritic    OUT VARCHAR2);   --Descricao do erro

  /* Procedure para verificar digito internet */
  PROCEDURE pc_verifica_digito_internet (pr_cooper       IN INTEGER                    --Codigo Cooperativa
                                        ,pr_nrdconta     IN INTEGER                    --Numero da Conta
                                        ,pr_idseqttl     IN crapttl.idseqttl%TYPE      --Sequencial do titular
                                        ,pr_cod_agencia  IN INTEGER                    --Codigo Agencia
                                        ,pr_nro_caixa    IN INTEGER                    --Numero do caixa
                                        ,pr_nro_conta    IN OUT NUMBER                 --Codigo Da Conta
                                        ,pr_cdcritic     OUT INTEGER     --C¿digo do erro
                                        ,pr_dscritic     OUT VARCHAR2);   --Descricao do erro

  /* Calcular Digito verificador Titulo */
  PROCEDURE pc_calc_digito_titulo_mod11 (pr_valor      IN OUT VARCHAR2   --> Valor Calculado
                                        ,pr_nro_digito OUT INTEGER     --> Digito verificador
                                        ,pr_retorno    OUT BOOLEAN);   --> Retorno digito correto

  /* Atualiza previas do caixa */
  PROCEDURE pc_atualiza_previa_cxa(pr_cooper            IN VARCHAR2    --> Codigo Cooperativa
                                  ,pr_cod_agencia       IN INTEGER     --> Codigo Agencia
                                  ,pr_nro_caixa         IN INTEGER     --> Codigo do Caixa
                                  ,pr_cod_operador      IN VARCHAR2    --> Codigo Operador
                                  ,pr_dtmvtolt          IN DATE        --> Data
                                  ,pr_operacao          IN INTEGER     --> Operacao(1-Incluisao/2-Estorno/3-Consulta)
                                  ,pr_retorno           OUT VARCHAR2   --> Retorna OK/NOK
                                  ,pr_cdcritic          OUT INTEGER    --> Codigo da Critica
                                  ,pr_dscritic          OUT VARCHAR2); --> Descricao da Critica

  /* Rotina de Validacao de Agencias - PA */
  PROCEDURE pc_valida_agencia(pr_cooper            IN VARCHAR2    --> Codigo Cooperativa
                             ,pr_cod_agencia       IN INTEGER     --> Codigo Agencia
                             ,pr_nro_caixa         IN INTEGER     --> Codigo do Caixa
                             ,pr_qtchqprv          OUT INTEGER    --> Qtd de Previas
                             ,pr_retorno           OUT VARCHAR2   --> Retorna OK/NOK
                             ,pr_cdcritic          OUT INTEGER    --> Codigo da Critica
                             ,pr_dscritic          OUT VARCHAR2); --> Descricao da Critica

END cxon0000;
/
CREATE OR REPLACE PACKAGE BODY CECRED.cxon0000 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : CXON0000
  --  Sistema  : Procedimentos e funcoes das transacoes do caixa online
  --  Sigla    : CRED
  --  Autor    : Alisson C. Berrido - Amcom
  --  Data     : Junho/2013.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos e funcoes das transacoes do caixa online

  ---------------------------------------------------------------------------------------------------------------

  /* Busca dos dados da cooperativa */
  CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
    SELECT crapcop.cdcooper
          ,crapcop.nmrescop
          ,crapcop.nrtelura
          ,crapcop.dsdircop
          ,crapcop.cdbcoctl
          ,crapcop.cdagectl
          ,crapcop.flgoppag
          ,crapcop.flgopstr
          ,crapcop.inioppag
          ,crapcop.fimoppag
          ,crapcop.iniopstr
          ,crapcop.fimopstr
          ,crapcop.cdagebcb
          ,crapcop.dssigaut
          ,crapcop.cdagesic
          ,crapcop.nrctasic
          ,crapcop.cdcrdins
      FROM crapcop
     WHERE crapcop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

  /* Buscar dados das agencias */
  CURSOR cr_crapage (pr_cdcooper IN crapage.cdcooper%type
                    ,pr_cdagenci IN crapage.cdagenci%type) IS
    SELECT crapage.nmresage
          ,crapage.cdagenci
          ,crapage.qtddaglf
    FROM crapage
    WHERE crapage.cdcooper = pr_cdcooper
    AND   crapage.cdagenci = pr_cdagenci;
  rw_crapage cr_crapage%ROWTYPE;

  /* Busca dos dados do associado */
  CURSOR cr_crapass(pr_cdcooper IN craptab.cdcooper%TYPE
                   ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT crapass.nrdconta
          ,crapass.nmprimtl
          ,crapass.inpessoa
          ,crapass.cdagenci
          ,crapass.vllimcre
      FROM crapass
     WHERE crapass.cdcooper = pr_cdcooper
     AND   crapass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;

  --Selecionar informacoes do log caixa
  CURSOR cr_crapcbl (pr_cdcooper IN crapcbl.cdcooper%type
                    ,pr_cdagenci IN crapcbl.cdagenci%type
                    ,pr_nrdcaixa IN crapcbl.nrdcaixa%type) IS
    SELECT crapcbl.cdcooper
          ,crapcbl.cdagenci
          ,crapcbl.nrdcaixa
          ,crapcbl.blidenti
          ,crapcbl.vlcompdb
          ,crapcbl.vlcompcr
          ,crapcbl.vlinicial
          ,crapcbl.rowid
    FROM crapcbl
    WHERE crapcbl.cdcooper = pr_cdcooper
    AND   crapcbl.cdagenci = pr_cdagenci
    AND   crapcbl.nrdcaixa = pr_nrdcaixa
    ORDER BY crapcbl.progress_recid ASC;
  rw_crapcbl cr_crapcbl%ROWTYPE;

  --Selecionar informacoes da autenticacao
  CURSOR cr_crapaut (pr_cdcooper IN crapaut.cdcooper%TYPE
                    ,pr_cdagenci IN crapaut.cdagenci%TYPE
                    ,pr_nrdcaixa IN crapaut.nrdcaixa%TYPE
                    ,pr_dtmvtolt IN crapaut.dtmvtolt%TYPE) IS
    SELECT crapaut.dtmvtolt
          ,crapaut.hrautent
          ,crapaut.nrsequen
          ,crapaut.nrdcaixa
          ,crapaut.blidenti
          ,crapaut.blsldini
          ,crapaut.bltotpag
          ,crapaut.bltotrec
          ,crapaut.blvalrec
          ,crapaut.nrseqaut
          ,crapaut.ROWID
    FROM crapaut
    WHERE crapaut.cdcooper = pr_cdcooper
    AND   crapaut.cdagenci = pr_cdagenci
    AND   crapaut.nrdcaixa = pr_nrdcaixa
    AND   crapaut.dtmvtolt = pr_dtmvtolt
    ORDER BY crapaut.progress_recid DESC;
  rw_crapaut cr_crapaut%ROWTYPE;

  --Selecionar informacoes da autenticacao
  CURSOR cr_crapaut_hist (pr_cdcooper IN crapaut.cdcooper%TYPE
                         ,pr_cdagenci IN crapaut.cdagenci%TYPE
                         ,pr_nrdcaixa IN crapaut.nrdcaixa%TYPE
                         ,pr_dtmvtolt IN crapaut.dtmvtolt%TYPE
                         ,pr_cdhistor IN crapaut.cdhistor%TYPE
                         ,pr_nrdocmto IN crapaut.nrdocmto%TYPE
                         ,pr_estorno  IN crapaut.estorno%TYPE) IS
    SELECT crapaut.dtmvtolt
          ,crapaut.hrautent
          ,crapaut.nrsequen
          ,crapaut.nrdcaixa
          ,crapaut.blidenti
          ,crapaut.blsldini
          ,crapaut.bltotpag
          ,crapaut.bltotrec
          ,crapaut.blvalrec
          ,crapaut.nrseqaut
          ,crapaut.ROWID
    FROM crapaut
    WHERE crapaut.cdcooper = pr_cdcooper
    AND   crapaut.cdagenci = pr_cdagenci
    AND   crapaut.nrdcaixa = pr_nrdcaixa
    AND   crapaut.dtmvtolt = pr_dtmvtolt
    AND   crapaut.cdhistor = pr_cdhistor
    AND   crapaut.nrdocmto = pr_nrdocmto
    AND   crapaut.estorno  = pr_estorno
    ORDER BY crapaut.progress_recid DESC;

  --Selecionar informacoes da autenticacao
  CURSOR cr_crapaut_sequen (pr_cdcooper IN crapaut.cdcooper%TYPE
                           ,pr_cdagenci IN crapaut.cdagenci%TYPE
                           ,pr_nrdcaixa IN crapaut.nrdcaixa%TYPE
                           ,pr_dtmvtolt IN crapaut.dtmvtolt%TYPE
                           ,pr_nrsequen IN crapaut.nrsequen%TYPE) IS
    SELECT crapaut.dtmvtolt
          ,crapaut.hrautent
          ,crapaut.nrsequen
          ,crapaut.nrdcaixa
          ,crapaut.blidenti
          ,crapaut.blsldini
          ,crapaut.bltotpag
          ,crapaut.bltotrec
          ,crapaut.blvalrec
          ,crapaut.nrseqaut
          ,crapaut.ROWID
    FROM crapaut
    WHERE crapaut.cdcooper = pr_cdcooper
    AND   crapaut.cdagenci = pr_cdagenci
    AND   crapaut.nrdcaixa = pr_nrdcaixa
    AND   crapaut.dtmvtolt = pr_dtmvtolt
    AND   crapaut.nrsequen = pr_nrsequen
    ORDER BY crapaut.progress_recid ASC;

  /* Procedure para eliminar erros */
  PROCEDURE pc_elimina_erro (pr_cooper      IN INTEGER                    --Codigo cooperativa
                            ,pr_cod_agencia IN INTEGER                    --Codigo agencia
                            ,pr_nro_caixa   IN INTEGER                    --Numero Caixa
                            ,pr_cdcritic    OUT INTEGER     --Codigo do erro
                            ,pr_dscritic    OUT VARCHAR2) IS --Descricao do erro
---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_elimina_erro    Antigo: dbo/bo-erro1.i/elimina-erro
  --  Sistema  : Procedure para eliminar erro
  --  Sigla    : CXON
  --  Autor    : Alisson C. Berrido - Amcom
  --  Data     : Julho/2013.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para eliminar erro

  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      --Variaveis Erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis Excecao
      vr_exc_erro EXCEPTION;
    BEGIN
      --Inicializar variaveis retorno
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;
      BEGIN
        --Excluir registro de erro dos parametros
        DELETE craperr
        WHERE craperr.cdcooper = pr_cooper
        AND   craperr.cdagenci = pr_cod_agencia
        AND   craperr.nrdcaixa = pr_nro_caixa;
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic:= 0;
          vr_dscritic:= 'Erro ao excluir craperr. '||sqlerrm;
          RAISE vr_exc_erro;
      END;
    EXCEPTION
       WHEN vr_exc_erro THEN
         pr_cdcritic:= vr_cdcritic;
         pr_dscritic:= vr_dscritic;
       WHEN OTHERS THEN
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro na rotina CXON0000.pc_elimina_erro. '||SQLERRM;
    END;
  END pc_elimina_erro;

  /* Procedure para criar erro */
  PROCEDURE pc_cria_erro(pr_cdcooper IN INTEGER   --Codigo Cooperativa
                        ,pr_cdagenci IN INTEGER   --Codigo da Agencia
                        ,pr_nrdcaixa IN INTEGER   --Numero do Caixa
                        ,pr_cod_erro IN INTEGER   --Codigo do erro para gravar
                        ,pr_dsc_erro IN VARCHAR2  --Descricao do erro para gravar
                        ,pr_flg_erro IN BOOLEAN   --Flag Erro
                        ,pr_cdcritic OUT INTEGER --Codigo de retorno de erro
                        ,pr_dscritic OUT VARCHAR2) IS --Descricao de retorno de erro
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_cria_erro            Antigo: dbo/b1crap00.p/cria-erro
  --  Sistema  : Procedure para criar erro
  --  Sigla    : CRED
  --  Autor    : Alisson C. Berrido - Amcom
  --  Data     : Junho/2013.                   Ultima atualizacao: 17/04/2014
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo   : Procedure para criar erro
  -- Alterações : 17/04/2014 - Ajuste na procedure "cria-erro" para buscar a
  --                           proxima sequence banco Oracle. (James)

  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      --Selecionar informacoes das criticas
      CURSOR cr_crapcri (pr_cdcritic IN crapcri.cdcritic%type) IS
        SELECT crapcri.dscritic
        FROM crapcri
        WHERE crapcri.cdcritic = pr_cdcritic;
      rw_crapcri cr_crapcri%ROWTYPE;
      --Variaveis locais
      vr_ind_erro INTEGER;
      --Variaveis Erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      vr_dsc_erro VARCHAR2(4000);
      --Variaveis Excecao
      vr_exc_erro EXCEPTION;
    BEGIN
      --Inicializar variaveis retorno
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;
      --Se o codigo <> 0
      IF pr_cod_erro != 0 THEN
        --Selecionar Critica
        OPEN cr_crapcri (pr_cdcritic => pr_cod_erro);
        --Posicionar no proximo registro
        FETCH cr_crapcri INTO rw_crapcri;
        --Se nao encontrar
        IF cr_crapcri%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_crapcri;
          vr_dsc_erro:= 'Critica nao Cadastrada.';
        ELSE
          vr_dsc_erro:= rw_crapcri.dscritic || pr_dsc_erro;
        END IF;
        --Fechar Cursor
        CLOSE cr_crapcri;
      END IF;
      --Transformar boolean em numero
      IF pr_flg_erro THEN
        vr_ind_erro:= 1;
      ELSE
        vr_ind_erro:= 0;
      END IF;
      --Inserir erro
      BEGIN
        INSERT INTO craperr
          (craperr.cdcooper
          ,craperr.cdagenci
          ,craperr.nrdcaixa
          ,craperr.nrsequen
          ,craperr.cdcritic
          ,craperr.dscritic
          ,craperr.erro)
        VALUES
          (pr_cdcooper
          ,pr_cdagenci
          ,pr_nrdcaixa
          ,fn_sequence('CRAPERR','NRSEQUEN',pr_cdcooper||';'||pr_cdagenci||';'||pr_nrdcaixa)
          ,pr_cod_erro
          ,substr(nvl(trim(vr_dsc_erro),pr_dsc_erro),1,92) --tamanho maximo do campo
          ,vr_ind_erro);
      EXCEPTION
        WHEN Others THEN
          vr_cdcritic:= 0;
          vr_dscritic:= 'Erro ao inserir na tabela craperr. '||sqlerrm;
          --Levantar Excecao
          RAISE vr_exc_erro;
      END;
    EXCEPTION
       WHEN vr_exc_erro THEN
         pr_cdcritic:= vr_cdcritic;
         pr_dscritic:= vr_dscritic;
       WHEN OTHERS THEN
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro na rotina CXON0000.pc_cria_erro. '||SQLERRM;
    END;
  END pc_cria_erro;

  /* Procedure para obter o literal da autenticacao */
  PROCEDURE pc_obtem_literal_autenticacao (pr_cooper   IN INTEGER   --Codigo Cooperativa
                                          ,pr_registro IN ROWID     --ROWID do registro autenticacao
                                          ,pr_literal  OUT VARCHAR2 --Descricao literal
                                          ,pr_cdcritic OUT INTEGER   --C¿digo do erro
                                          ,pr_dscritic OUT VARCHAR2) IS --Descricao do erro
  /***************************************************************************************

    Programa : pc_obtem_literal_autenticacao    Antigo: dbo/b1crap00.p/obtem-literal-autenticacao
    Sistema  : Procedure para obter literal da autenticacao
    Sigla    : CRED
    Autor    : Alisson C. Berrido - Amcom
    Data     : Junho/2013.                   Ultima atualizacao: 02/10/2014

   Dados referentes ao programa:

   Frequencia: -----
   Objetivo  : Procedure para obter o literal da autenticacao

               01/09/2014 - Incluido tratamento de autenticação para pagamento de guias
                            GPS (Adriano).

               02/10/2015 - Inclusao do tratamento do historico 1414 e também quando
                            internet banking - String Autenticacao
                            Observacao: Sempre que retornar o literal para 1414, deve
                            ser feito o replace do XXXX pelo numero retornado do SICREDI
                            (Guilherme/SUPERO)
                            
               28/04/2016 - Acerto string autenticação GPS/1414  (Guilherme/SUPERO)

  *************************************************************************************/

  BEGIN
    DECLARE
      --Cursores Locais

      --Selecionar informacoes da autenticacao
      CURSOR cr_crapaut (pr_rowid IN ROWID) IS
        SELECT crapaut.dtmvtolt
              ,crapaut.hrautent
              ,crapaut.nrsequen
              ,crapaut.nrdcaixa
              ,crapaut.cdagenci
              ,crapaut.tpoperac
              ,crapaut.cdstatus
              ,crapaut.cdhistor
              ,crapaut.vldocmto
              ,crapaut.estorno
              ,crapaut.dsobserv
              ,crapaut.nrseqaut
              ,crapaut.nrdocmto
              ,crapaut.ROWID
        FROM crapaut
        WHERE ROWID = pr_rowid;
      rw_crapaut cr_crapaut%ROWTYPE;

      CURSOR cr_crapscn (pr_cdempres IN crapscn.cdempres%type) IS
        SELECT crapscn.cdempres
              ,crapscn.dssigemp
        FROM crapscn
        WHERE crapscn.cdempres = pr_cdempres;
      rw_crapscn cr_crapscn%ROWTYPE;

      CURSOR cr_crapstn (pr_cdempres IN crapstn.cdempres%type) IS
        SELECT crapstn.cdtransa
        FROM crapstn
        WHERE crapstn.cdempres = pr_cdempres
        AND   crapstn.tpmeiarr = 'C';
      rw_crapstn cr_crapstn%ROWTYPE;

      --Variaveis Locais
      vr_off_line CHAR;
      vr_pg_rc    VARCHAR2(2);
      vr_valor    VARCHAR2(100);
      vr_dssigaut crapcop.dssigaut%TYPE;

      --Variaveis Erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis Excecao
      vr_exc_erro EXCEPTION;
    BEGIN
      --Inicializar variaveis retorno
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;
      pr_literal:= NULL;

      --Selecionar registro autenticacao
      OPEN cr_crapaut (pr_rowid => pr_registro);
      --Posicionar no proximo registro
      FETCH cr_crapaut INTO rw_crapaut;
      --Se nao encontrar
      IF cr_crapaut%FOUND THEN
        --Selecionar a agencia da autenticacao
        OPEN cr_crapage (pr_cdcooper => pr_cooper
                        ,pr_cdagenci => rw_crapaut.cdagenci);
        --Posicionar no proximo registro
        FETCH cr_crapage INTO rw_crapage;
        --Se nao encontrar
        IF cr_crapage%NOTFOUND THEN
          --Fechar Cursores
          CLOSE cr_crapage;
          CLOSE cr_crapaut;
          --Criar Erro
          pc_cria_erro(pr_cdcooper => pr_cooper
                      ,pr_cdagenci => rw_crapaut.cdagenci
                      ,pr_nrdcaixa => rw_crapaut.nrdcaixa
                      ,pr_cod_erro => 15
                      ,pr_dsc_erro => NULL
                      ,pr_flg_erro => TRUE
                      ,pr_cdcritic => vr_cdcritic
                      ,pr_dscritic => vr_dscritic);
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          ELSE
            vr_cdcritic:= 15;
            vr_dscritic:= NULL;
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
        END IF;
        --Fechar Cursor
        CLOSE cr_crapage;

        --Se for operacao
        IF rw_crapaut.tpoperac = 1 THEN
          vr_pg_rc:= 'PG';
        ELSE
          vr_pg_rc:= 'RC';
        END IF;
        IF  rw_crapaut.cdstatus = '2'  THEN /* off-line */
          vr_off_line:= '*';
        ELSE
          vr_off_line:= ' ';
        END IF;
        /* Guias GPS-BANCOOB */
        IF rw_crapaut.cdhistor = 582 THEN
          vr_valor:= LPad('*'||To_Char(rw_crapaut.vldocmto,'fm999g990d00'),11,' ');
          --Sigla Autenticacao
          vr_dssigaut:= 'CEC '||gene0002.fn_mask(rw_crapcop.cdagebcb,'9999');
        ELSIF rw_crapaut.cdhistor = 1414 THEN  -- Guias GPS SICREDI
          vr_valor:= LPad(To_Char(rw_crapaut.vldocmto,'fm999g999g990d00'),11,'*');
          --Sigla Autenticacao
          vr_dssigaut:= 'CCR';
        ELSE
          vr_valor:= LPad('*'||To_Char(rw_crapaut.vldocmto,'fm999g999g990d00'),15,' ');
          --Sigla Autenticacao
          vr_dssigaut:= rw_crapcop.dssigaut;
        END IF;
        --Se nao for estorno
        IF rw_crapaut.estorno = 0 THEN
          /* Nao utilizar a nova sequencia para data inferior a data
             da liberacao do projeto de padronizacao da autenticacao,
             autenticacao dos pac 90 e 91 e de guias GPS */
          IF rw_crapaut.dtmvtolt < To_Date('04/25/2012','MM/DD/YYYY')  OR
             rw_crapaut.cdhistor = 582 OR
             rw_crapaut.cdagenci IN (90,91) THEN   /* Internet ou TAA */
            --Montar literal
            pr_literal:=  vr_dssigaut||' '||
                          gene0002.fn_mask(rw_crapaut.nrsequen,'99999') || ' ' ||
                          To_Char(rw_crapaut.dtmvtolt,'DD') ||
                          vr_tab_mes(To_Char(rw_crapaut.dtmvtolt,'MM'))||
                          To_Char(rw_crapaut.dtmvtolt,'YY')||
                          '      '||
                          vr_valor||
                          vr_pg_rc||
                          vr_off_line||
                          gene0002.fn_mask(rw_crapaut.nrdcaixa,'999')||
                          gene0002.fn_mask(rw_crapaut.cdagenci,'999');
                          
            IF  rw_crapaut.cdhistor = 1414    -- GPS SICREDI
            AND rw_crapaut.cdagenci = 90 THEN -- INTERNET BANKING
                --Montar Literal
                pr_literal:= vr_dssigaut||
                             gene0002.fn_mask(rw_crapcop.nrctasic,'99999-9') ||
                             ' ' ||
                             gene0002.fn_mask(rw_crapaut.nrdcaixa,'999')||
                             ' XXXX '||
                             To_Char(rw_crapaut.dtmvtolt,'DD/MM/YYYY')||
                             vr_valor ||
                             vr_pg_rc ||
                             '      ' ||
                             'GPS/INSS IDENT '; -- 2ª Linha da Autenticacao
            END IF;
          ELSIF  nvl(rw_crapaut.dsobserv,' ') <> ' ' THEN /* DARF */
            --Selecionar informacoes
            OPEN cr_crapscn (pr_cdempres => rw_crapaut.dsobserv);
            --Posicionar no proximo registro
            FETCH cr_crapscn INTO rw_crapscn;
            --Se nao encontrar
            IF cr_crapscn%FOUND THEN
              /* CAIXA */
              --Selecionar informacoes
              OPEN cr_crapstn (pr_cdempres => rw_crapscn.cdempres);
              --Posicionar no proximo registro
              FETCH cr_crapstn INTO rw_crapstn;
              --Se nao encontrar
              IF cr_crapstn%NOTFOUND THEN
                --Fechar Cursor
                CLOSE cr_crapstn;
                CLOSE cr_crapscn;
                --Criar erro
                pc_cria_erro(pr_cdcooper => pr_cooper
                            ,pr_cdagenci => rw_crapaut.cdagenci
                            ,pr_nrdcaixa => rw_crapaut.nrdcaixa
                            ,pr_cod_erro => 0
                            ,pr_dsc_erro => 'Transacao para pagamento nao cadastrada.'
                            ,pr_flg_erro => TRUE
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic);
                IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                  --Levantar Excecao
                  RAISE vr_exc_erro;
                ELSE
                  vr_cdcritic:= 0;
                  vr_dscritic:= 'Transacao para pagamento nao cadastrada.';
                  --Levantar Excecao
                  RAISE vr_exc_erro;
                END IF;
              END IF;
              --Fechar Cursor
              CLOSE cr_crapstn;
              --Montar Literal
              pr_literal:= 'BCS'||
                           '00089-2 '||
                           gene0002.fn_mask(rw_crapcop.cdagesic,'9999')|| ' '||
                           gene0002.fn_mask(rw_crapaut.nrdcaixa,'999')|| ' '||
                           gene0002.fn_mask(rw_crapaut.nrsequen,'99999')|| ' '||
                           '********'||
                           To_Char(rw_crapaut.vldocmto,'fm9g999g999d99')||
                           'RR     '||' '||
                           to_char(rw_crapaut.dtmvtolt,'DD/MM/YYYY')||' '||
                           '* *****-*'||' '||
                           gene0002.fn_mask(rw_crapstn.cdtransa,'999')||' '||
                           gene0002.fn_mask(rw_crapscn.dssigemp,'999999999');
            END IF;
            --Fechar Cursor
            CLOSE cr_crapscn;
          ELSIF  rw_crapaut.cdhistor = 1414 THEN   -- GPS SICREDI
            --Montar Literal
            pr_literal:= vr_dssigaut ||
                         gene0002.fn_mask(rw_crapcop.nrctasic,'99999-9') ||
                         ' ' ||
                         gene0002.fn_mask(rw_crapaut.nrdcaixa,'999')||
                         ' XXXX '||
                         To_Char(rw_crapaut.dtmvtolt,'DD/MM/YYYY')||
                         vr_valor ||
                         vr_pg_rc ||
                         '      ' ||
                         'GPS/INSS IDENT '; -- 2ª Linha da Autenticacao
          ELSE
            --Montar Literal
            pr_literal:= gene0002.fn_mask(rw_crapcop.cdbcoctl,'999')||
                         gene0002.fn_mask(rw_crapcop.cdagectl,'9999')||
                         gene0002.fn_mask(rw_crapage.cdagenci,'999')||
                         gene0002.fn_mask(rw_crapaut.nrdcaixa,'99')||
                         ' '||
                         gene0002.fn_mask(rw_crapaut.nrsequen,'99999')||
                         ' '||
                         To_Char(rw_crapaut.dtmvtolt,'DDMMYY')||
                         '     '||
                         vr_off_line||
                         vr_valor||
                         vr_pg_rc;
          END IF;
        ELSE
          /* Nao utilizar a nova sequencia para data inferior a data
                     da liberacao do projeto de padronizacao da autenticacao,
                     autenticacao dos pac 90 e 91 e de guias GPS */
          IF rw_crapaut.dtmvtolt < To_Date('25/04/2012','DD/MM/YYYY')  OR
             rw_crapaut.cdhistor = 582 OR
             rw_crapaut.cdagenci IN (90,91) THEN   /* Internet ou TAA */
            --Montar literal
            pr_literal:=  vr_dssigaut||' '||
                          gene0002.fn_mask(rw_crapaut.nrsequen,'99999') || ' ' ||
                          To_Char(rw_crapaut.dtmvtolt,'DD') ||
                          vr_tab_mes(To_Char(rw_crapaut.dtmvtolt,'MM'))||
                          To_Char(rw_crapaut.dtmvtolt,'YY')||
                          '-E'||
                          gene0002.fn_mask(rw_crapaut.nrseqaut,'99999')||' '||
                          To_Char(rw_crapaut.vldocmto,'fm999g999g990d00')||
                          vr_pg_rc||
                          vr_valor||
                          vr_off_line||
                          gene0002.fn_mask(rw_crapaut.nrdcaixa,'z99')||
                          gene0002.fn_mask(rw_crapaut.cdagenci,'999');
          ELSE
            --Montar Literal
            pr_literal:= gene0002.fn_mask(rw_crapcop.cdbcoctl,'999')||
                         gene0002.fn_mask(rw_crapcop.cdagectl,'9999')||
                         gene0002.fn_mask(rw_crapage.cdagenci,'999')||
                         gene0002.fn_mask(rw_crapaut.nrdcaixa,'99')||
                         ' '||
                         gene0002.fn_mask(rw_crapaut.nrsequen,'99999')||
                         ' '||
                         To_Char(rw_crapaut.dtmvtolt,'DDMMYY')||
                         'E'||
                         gene0002.fn_mask(rw_crapaut.nrseqaut,'99999')||
                         vr_off_line||
                         To_Char(rw_crapaut.vldocmto,'fm999g999g990d00')||
                         vr_pg_rc;
          END IF;
        END IF; --rw_crapaut.estorno = 0
      END IF;
      --Fechar Cursor
      CLOSE cr_crapaut;

    EXCEPTION
       WHEN vr_exc_erro THEN
         pr_cdcritic:= vr_cdcritic;
         pr_dscritic:= vr_dscritic;
       WHEN OTHERS THEN
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro na rotina CXON0000.pc_obtem_literal_autenticacao. '||SQLERRM;
    END;
  END pc_obtem_literal_autenticacao;


  /* Procedure para gravar a autenticacao */
  PROCEDURE pc_grava_autenticacao (pr_cooper       IN INTEGER --Codigo Cooperativa
                                  ,pr_cod_agencia  IN INTEGER --Codigo Agencia
                                  ,pr_nro_caixa    IN INTEGER --Numero do caixa
                                  ,pr_cod_operador IN VARCHAR2 --Codigo Operador
                                  ,pr_valor        IN NUMBER   --Valor da transacao
                                  ,pr_docto        IN NUMBER   --Numero documento
                                  ,pr_operacao     IN BOOLEAN  --Indicador Operacao
                                  ,pr_status       IN VARCHAR2 --Status da Operacao
                                  ,pr_estorno      IN BOOLEAN  --Indicador Estorno
                                  ,pr_histor       IN INTEGER  --Historico
                                  ,pr_data_off     IN DATE     --Data Transacao
                                  ,pr_sequen_off   IN INTEGER  --Sequencia
                                  ,pr_hora_off     IN INTEGER  --Hora transcao
                                  ,pr_seq_aut_off  IN INTEGER  --Sequencia automatica
                                  ,pr_literal      OUT VARCHAR2 --Descricao literal
                                  ,pr_sequencia    OUT INTEGER  --Sequencia
                                  ,pr_registro     OUT ROWID    --ROWID do registro
                                  ,pr_cdcritic     OUT INTEGER     --C¿digo do erro
                                  ,pr_dscritic     OUT VARCHAR2) IS   --Descricao do erro
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_grava_autenticacao    Antigo: dbo/b1crap00.p/grava-autenticacao
  --  Sistema  : Procedure para gravar autenticacao
  --  Sigla    : CRED
  --  Autor    : Alisson C. Berrido - Amcom
  --  Data     : Junho/2013.                   Ultima atualizacao: 21/03/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para gravar autenticacao
  --
  -- Alteracoes: 16/04/2014 - Utilizar a funcao fn_sequence para buscar o maior valor
  --                          (Andrino/RKAM)
  --
  --             21/03/2016 - Incluir validacao para nao ler a tabela crapcbl caso for o 
  --                          cdagenci 90 e 91 (Lucas Ranghetti/Fabricio)
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE

      --Variaveis Locais
      vr_sequen   INTEGER;
      vr_seq_aut  INTEGER;
      vr_estorno  INTEGER;
      vr_operacao INTEGER;
      vr_literal  VARCHAR2(100);
      vr_literal2 VARCHAR2(100);
      vr_busca    VARCHAR2(100);
      --Variaveis para manipulacao arquivos
      vr_caminho    VARCHAR2(100);
      vr_nmarquivo  VARCHAR2(100);
      vr_setlinha   VARCHAR2(100);
      vr_input_file utl_file.file_type;

      --Tipo de Dados para cursor data
      rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
      --Variaveis Erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis Excecao
      vr_exc_erro EXCEPTION;
    BEGIN
      --Inicializar variaveis retorno
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      --Eliminar erro
      pc_elimina_erro (pr_cooper      => pr_cooper
                      ,pr_cod_agencia => pr_cod_agencia
                      ,pr_nro_caixa   => pr_nro_caixa
                      ,pr_cdcritic    => vr_cdcritic
                      ,pr_dscritic    => vr_dscritic);
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      --Verificar se a cooperativa existe
      OPEN cr_crapcop(pr_cdcooper => pr_cooper);
      FETCH cr_crapcop INTO rw_crapcop;
      --Se nao encontrou
      IF cr_crapcop%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcop;
        vr_cdcritic:= 651;
        vr_dscritic:= 'Registro de cooperativa nao encontrado.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapcop;

      -- Verifica se a data esta cadastrada
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se n¿o encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haver¿ raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;
      /* Autenticacao ON-LINE */
      IF pr_data_off IS NULL AND  -- Autenticacao ON-LINE 
         pr_cod_agencia <> 90 AND  -- Internet
         pr_cod_agencia <> 91 THEN -- TAA
        /*----           Atualiza BL         ------*/
        --Selecionar BL caixa online
        OPEN cr_crapcbl (pr_cdcooper => pr_cooper
                        ,pr_cdagenci => pr_cod_agencia
                        ,pr_nrdcaixa => pr_nro_caixa);
        --Posicionar no proximo registro
        FETCH cr_crapcbl INTO rw_crapcbl;
        --Se nao encontrar
        IF cr_crapcbl%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_crapcbl;
          --Inserir BL do caixa online
          BEGIN
            INSERT INTO crapcbl
            (crapcbl.cdcooper
            ,crapcbl.cdagenci
            ,crapcbl.nrdcaixa)
            VALUES
            (pr_cooper
            ,pr_cod_agencia
            ,pr_nro_caixa)
            RETURNING
             crapcbl.cdcooper
            ,crapcbl.cdagenci
            ,crapcbl.nrdcaixa
            ,crapcbl.rowid
            INTO
             rw_crapcbl.cdcooper
            ,rw_crapcbl.cdagenci
            ,rw_crapcbl.nrdcaixa
            ,rw_crapcbl.rowid;
          EXCEPTION
            WHEN Dup_Val_On_Index THEN
              NULL;
            WHEN OTHERS THEN
              vr_cdcritic:= 0;
              vr_dscritic:= 'Erro ao inserir no BL do caixa online. '||sqlerrm;
              --Levantar Excecao
              RAISE vr_exc_erro;
          END;
        END IF;
        --Fechar Cursor
        IF cr_crapcbl%ISOPEN THEN
          CLOSE cr_crapcbl;
        END IF;

        /* --- Inicio do c¿digo alterado por Robinson --- */
        /* Inclusa a condi¿¿o de verifica¿¿o da id do bl  */
        IF  rw_crapcbl.blidenti <> ' ' THEN
          IF  pr_operacao THEN   /* PG  - Debito */
            --Se for estorno
            IF  pr_estorno THEN
              --Diminuir debito
              rw_crapcbl.vlcompdb:= Nvl(rw_crapcbl.vlcompdb,0) - Nvl(pr_valor,0);
            ELSE
              --Aumentar Debito
              rw_crapcbl.vlcompdb:= Nvl(rw_crapcbl.vlcompdb,0) + Nvl(pr_valor,0);
            END IF;
          ELSE
            --Se for estorno
            IF  pr_estorno THEN
              --Diminuir Credito
              rw_crapcbl.vlcompcr:= Nvl(rw_crapcbl.vlcompcr,0) - Nvl(pr_valor,0);
            ELSE
              --Aumentar Credito
              rw_crapcbl.vlcompcr:= Nvl(rw_crapcbl.vlcompcr,0) + Nvl(pr_valor,0);
            END IF;
          END IF;
          --Atualizar tabela crapcbl
          BEGIN
            UPDATE crapcbl SET crapcbl.vlcompdb = rw_crapcbl.vlcompdb
                              ,crapcbl.vlcompcr = rw_crapcbl.vlcompcr
            WHERE crapcbl.ROWID = rw_crapcbl.ROWID;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic:= 0;
              vr_dscritic:= 'Erro ao atualizar no BL do caixa online. '||sqlerrm;
              --Levantar Excecao
              RAISE vr_exc_erro;
          END;
        END IF;
      END IF;

      /* Autenticacao ON-LINE */
      IF pr_data_off IS NULL THEN
        /* Obter ultima sequencia = Caixa */
        /* Alterado para utilizar sequence atraves do Oracle */
        vr_busca :=  TRIM(pr_cooper)      || ';' ||
                     TRIM(pr_cod_agencia) || ';' ||
                     TRIM(pr_nro_caixa)  || ';' ||
                     TO_char(rw_crapdat.dtmvtocd,'dd/mm/yyyy');

        vr_sequen := fn_sequence('CRAPAUT','NRSEQUEN',vr_busca);

        --Retornar a sequencia encontrada
        pr_sequencia:= vr_sequen;
        /* Atualiza Tabela de Autenticacoes */
        --Se nao for estorno
        IF NOT pr_estorno THEN
          --Transformar boolean em number
          IF pr_estorno THEN
            vr_estorno:= 1;
          ELSE
            vr_estorno:= 0;
          END IF;
          IF pr_operacao THEN
            vr_operacao:= 1;
          ELSE
            vr_operacao:= 0;
          END IF;

          --Inserir autenticacao
          BEGIN
            INSERT INTO crapaut
              (crapaut.cdcooper
              ,crapaut.cdagenci
              ,crapaut.nrdcaixa
              ,crapaut.dtmvtolt
              ,crapaut.nrsequen
              ,crapaut.cdopecxa
              ,crapaut.hrautent
              ,crapaut.vldocmto
              ,crapaut.nrdocmto
              ,crapaut.tpoperac
              ,crapaut.cdstatus
              ,crapaut.estorno
              ,crapaut.cdhistor)
            VALUES
              (pr_cooper
              ,pr_cod_agencia
              ,pr_nro_caixa
              ,rw_crapdat.dtmvtocd
              ,vr_sequen
              ,pr_cod_operador
              ,GENE0002.fn_busca_time
              ,pr_valor
              ,pr_docto
              ,vr_operacao
              ,pr_status
              ,vr_estorno
              ,pr_histor)
             RETURNING
               crapaut.ROWID
             INTO
               rw_crapaut.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic:= 0;
              vr_dscritic:= 'Erro ao atualizar no BL do caixa online. '||sqlerrm;
              --Levantar Excecao
              RAISE vr_exc_erro;
          END;
        ELSE
          /* Ultima sequencia = Autenticacao p/gravar no Estorno */
          vr_seq_aut:= 0;
          --Se for online e enviado pelo 78
          IF pr_status = '1' AND pr_sequen_off <> 0 THEN
            --Sequencia autenticacao
            vr_seq_aut:= pr_sequen_off;
          ELSE
            --Buscar ultima autenticacao
            OPEN cr_crapaut_hist (pr_cdcooper => pr_cooper
                                 ,pr_cdagenci => pr_cod_agencia
                                 ,pr_nrdcaixa => pr_nro_caixa
                                 ,pr_dtmvtolt => rw_crapdat.dtmvtocd
                                 ,pr_cdhistor => pr_histor
                                 ,pr_nrdocmto => pr_docto
                                 ,pr_estorno  => 0);
            --Posicionar no primeiro registro
            FETCH cr_crapaut_hist INTO rw_crapaut;
            --Se Encontrou registro
            IF cr_crapaut_hist%FOUND THEN
              --Sequencial autenticacao
              vr_seq_aut:= rw_crapaut.nrsequen;
            END IF;
            --Fechar Cursor
            CLOSE cr_crapaut_hist;
          END IF;

          --Transformar boolean em number
          IF pr_estorno THEN
            vr_estorno:= 1;
          ELSE
            vr_estorno:= 0;
          END IF;
          IF pr_operacao THEN
            vr_operacao:= 1;
          ELSE
            vr_operacao:= 0;
          END IF;

          --Inserir autenticacao
          BEGIN
            INSERT INTO crapaut
              (crapaut.cdcooper
              ,crapaut.cdagenci
              ,crapaut.nrdcaixa
              ,crapaut.dtmvtolt
              ,crapaut.nrsequen
              ,crapaut.cdopecxa
              ,crapaut.hrautent
              ,crapaut.vldocmto
              ,crapaut.nrdocmto
              ,crapaut.tpoperac
              ,crapaut.cdstatus
              ,crapaut.estorno
              ,crapaut.nrseqaut
              ,crapaut.cdhistor)
            VALUES
              (pr_cooper
              ,pr_cod_agencia
              ,pr_nro_caixa
              ,rw_crapdat.dtmvtocd
              ,vr_sequen
              ,pr_cod_operador
              ,GENE0002.fn_busca_time
              ,pr_valor
              ,pr_docto
              ,vr_operacao
              ,pr_status
              ,vr_estorno
              ,vr_seq_aut
              ,pr_histor)
             RETURNING
              crapaut.ROWID
             INTO
              rw_crapaut.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic:= 0;
              vr_dscritic:= 'Erro ao atualizar no BL do caixa online. '||sqlerrm;
              --Levantar Excecao
              RAISE vr_exc_erro;
          END;
        END IF;
      ELSE  /* Importacao OFF-LINE */
        OPEN cr_crapaut_sequen (pr_cdcooper => pr_cooper
                               ,pr_cdagenci => pr_cod_agencia
                               ,pr_nrdcaixa => pr_nro_caixa
                               ,pr_dtmvtolt => pr_data_off
                               ,pr_nrsequen => pr_sequen_off);
        --Posicionar no proximo registro
        FETCH cr_crapaut_sequen INTO rw_crapaut;
        --Se nao encontrar
        IF cr_crapaut_sequen%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_crapaut_sequen;

          --Transformar boolean em number
          IF pr_estorno THEN
            vr_estorno:= 1;
          ELSE
            vr_estorno:= 0;
          END IF;
          IF pr_operacao THEN
            vr_operacao:= 1;
          ELSE
            vr_operacao:= 0;
          END IF;

          --Inserir autenticacao
          BEGIN
            INSERT INTO crapaut
              (crapaut.cdcooper
              ,crapaut.cdagenci
              ,crapaut.nrdcaixa
              ,crapaut.dtmvtolt
              ,crapaut.nrsequen
              ,crapaut.cdopecxa
              ,crapaut.hrautent
              ,crapaut.vldocmto
              ,crapaut.nrdocmto
              ,crapaut.tpoperac
              ,crapaut.cdstatus
              ,crapaut.estorno
              ,crapaut.nrseqaut
              ,crapaut.cdhistor)
            VALUES
              (pr_cooper
              ,pr_cod_agencia
              ,pr_nro_caixa
              ,pr_data_off
              ,pr_sequen_off
              ,pr_cod_operador
              ,pr_hora_off
              ,pr_valor
              ,pr_docto
              ,vr_operacao
              ,pr_status
              ,vr_estorno
              ,pr_seq_aut_off
              ,pr_histor)
             RETURNING
             crapaut.ROWID
             INTO
             rw_crapaut.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic:= 0;
              vr_dscritic:= 'Erro ao atualizar no BL do caixa online. '||sqlerrm;
              --Levantar Excecao
              RAISE vr_exc_erro;
          END;
        END IF;
        --Fechar Cursor
        IF cr_crapaut_sequen%ISOPEN THEN
          CLOSE cr_crapaut_sequen;
        END IF;
      END IF;

      vr_literal2:= NULL;
      /* Autenticacao ON-LINE */
      IF pr_data_off IS NULL THEN
        /* --- Inicio do c¿digo alterado por Robinson --- */
        IF pr_cod_agencia <> 90 AND  -- Internet
           pr_cod_agencia <> 91 THEN -- TAA
        /* Inclusa a condicao de verificacao da id do bl  */
        IF nvl(rw_crapcbl.blidenti, ' ') <> ' ' THEN
          --Atualizar tabela BL
          BEGIN
            UPDATE crapaut SET crapaut.blidenti = rw_crapcbl.blidenti
                              ,crapaut.blsldini = rw_crapcbl.vlinicial
                              ,crapaut.bltotpag = rw_crapcbl.vlcompdb
                              ,crapaut.bltotrec = rw_crapcbl.vlcompcr
                              ,crapaut.blvalrec = (rw_crapcbl.vlinicial + rw_crapcbl.vlcompdb - rw_crapcbl.vlcompcr)
            WHERE crapaut.ROWID = rw_crapaut.ROWID
            RETURNING
               crapaut.blsldini
              ,crapaut.bltotpag
              ,crapaut.bltotrec
              ,crapaut.blvalrec
            INTO
               rw_crapaut.blsldini
              ,rw_crapaut.bltotpag
              ,rw_crapaut.bltotrec
              ,rw_crapaut.blvalrec;
          EXCEPTION
            WHEN Others THEN
             vr_cdcritic:= 0;
             vr_dscritic:= 'Erro ao atualizar tabela crapcbl. '||sqlerrm;
             --Levantar Excecao
             RAISE vr_exc_erro;
          END;
          --Montar literal 2
          vr_literal2:= rw_crapaut.blidenti||' '||
                        to_char(rw_crapaut.blsldini,'999g999g999d00')||' '||
                        to_char(rw_crapaut.bltotpag,'999g999g999d00')||' '||
                        to_char(rw_crapaut.bltotrec,'999g999g999d00')||' '||
                        to_char(rw_crapaut.blvalrec,'999g999g999d00');
        END IF;
      END IF;
      END IF;
      --Retornar rowid autenticacao
      pr_registro:= rw_crapaut.rowid;

      --Obter Literal da Autenticacao
      pc_obtem_literal_autenticacao (pr_cooper   => pr_cooper
                                    ,pr_registro => rw_crapaut.rowid
                                    ,pr_literal  => vr_literal
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      -- Retornar o literal
      pr_literal := vr_literal;

      /*--- Armazena Literal de Autenticacao na Tabela crapaut --*/
      BEGIN
        UPDATE crapaut SET crapaut.dslitera = vr_literal
        WHERE crapaut.ROWID = rw_crapaut.ROWID;
      EXCEPTION
        WHEN Others THEN
         vr_cdcritic:= 0;
         vr_dscritic:= 'Erro ao atualizar tabela crapaut. '||sqlerrm;
         --Levantar Excecao
         RAISE vr_exc_erro;
      END;

      IF pr_cod_agencia <> 90 AND  -- Internet
         pr_cod_agencia <> 91 THEN -- TAA         
      /*----------Gera Arquivo Texto-----*/
      --Busca o caminho padrao spool web
      vr_caminho:= GENE0001.fn_param_sistema('CRED',pr_cooper,'SPOOL_WEB');
      --Montar o nome do arquivo
      vr_nmarquivo:= rw_crapcop.dsdircop|| gene0002.fn_mask(pr_cod_agencia,'999')||
                     gene0002.fn_mask(pr_nro_caixa,'999')||
                     vr_tab_dia(To_Char(rw_crapdat.dtmvtocd,'D'))||'.txt';

      --Abrir arquivo modo append
      gene0001.pc_abre_arquivo(pr_nmdireto => vr_caminho     --> Diretorio do arquivo
                              ,pr_nmarquiv => vr_nmarquivo   --> Nome do arquivo
                              ,pr_tipabert => 'A'            --> Modo de abertura (R,W,A)
                              ,pr_utlfileh => vr_input_file  --> Handle do arquivo aberto
                              ,pr_des_erro => vr_dscritic);  --> Erro
      IF vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Montar a linha a ser escrita no arquivo
      vr_setlinha:= RPad(vr_literal,48,' ')||' - '||RPad(vr_literal2,48,' ');
      --Escrever a linha no arquivo
      gene0001.pc_escr_linha_arquivo(vr_input_file,vr_setlinha);
      -- Fechar o arquivo
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
      END IF;
    EXCEPTION
       WHEN vr_exc_erro THEN
         pr_cdcritic:= vr_cdcritic;
         pr_dscritic:= vr_dscritic;
       WHEN OTHERS THEN
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro na rotina CXON0000.pc_grava_autenticacao. '||SQLERRM;
    END;
  END pc_grava_autenticacao;

  /* Procedure para gravar autenticacao na internet */
  PROCEDURE pc_grava_autenticacao_internet (pr_cooper       IN INTEGER  --Codigo Cooperativa
                                           ,pr_nrdconta     IN INTEGER  --Numero da Conta
                                           ,pr_idseqttl     IN crapttl.idseqttl%TYPE --Sequencial do titular
                                           ,pr_cod_agencia  IN INTEGER  --Codigo Agencia
                                           ,pr_nro_caixa    IN INTEGER  --Numero do caixa
                                           ,pr_cod_operador IN VARCHAR2 --Codigo Operador
                                           ,pr_valor        IN NUMBER   --Valor da transacao
                                           ,pr_docto        IN NUMBER   --Numero documento
                                           ,pr_operacao     IN BOOLEAN  --Indicador Operacao
                                           ,pr_status       IN VARCHAR2 --Status da Operacao
                                           ,pr_estorno      IN BOOLEAN  --Indicador Estorno
                                           ,pr_histor       IN INTEGER  --Historico
                                           ,pr_data_off     IN DATE     --Data Transacao
                                           ,pr_sequen_off   IN INTEGER  --Sequencia
                                           ,pr_hora_off     IN INTEGER  --Hora transcao
                                           ,pr_seq_aut_off  IN INTEGER  --Sequencia automatica
                                           ,pr_cdempres     IN VARCHAR2 --Descricao Observacao
                                           ,pr_literal      OUT VARCHAR2 --Descricao literal
                                           ,pr_sequencia    OUT INTEGER  --Sequencia
                                           ,pr_registro     OUT ROWID    --ROWID do registro
                                           ,pr_cdcritic     OUT INTEGER     --C¿digo do erro
                                           ,pr_dscritic     OUT INTEGER) IS   --Descricao do erro
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_grava_autenticacao_internet    Antigo: dbo/b1crap22.p/grava-autenticacao-internet
  --  Sistema  : Procedure para gravar a autenticacao na internet
  --  Sigla    : CRED
  --  Autor    : Alisson C. Berrido - Amcom
  --  Data     : Julho/2013.                   Ultima atualizacao: 11/03/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para gravar a autenticacao na internet
  --
  -- Alteracoes: 16/04/2014 - Utilizar a funcao fn_sequence para buscar o maior valor
  --                          (Andrino/RKAM)
  --
  --             10/03/2016 - Incluir log caso ocorra erro na autenticacao (Lucas Ranghetti/Fabricio)
  --
  --             11/03/2016 - Incluir validacao para nao ler a tabela crapcbl caso for o 
  --                          cdagenci 90 e 91 (Lucas Ranghetti/Fabricio)
  --
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE

      vr_sequen   INTEGER;
      vr_seq_aut  INTEGER;
      vr_estorno  INTEGER;
      vr_operacao INTEGER;
      vr_nrdcaixa INTEGER;
      vr_dsobserv VARCHAR2(100);
      vr_literal  VARCHAR2(100);
      vr_literal2 VARCHAR2(100);
      vr_busca    VARCHAR2(100);
      vr_flgerlog   VARCHAR2(50);
      
      --Variaveis para manipulacao arquivos
      vr_caminho    VARCHAR2(100);
      vr_nmarquivo  VARCHAR2(100);
      vr_setlinha   VARCHAR2(100);
      vr_input_file utl_file.file_type;

      --Tipo de Dados para cursor data
      rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
      --Variaveis Erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis Excecao
      vr_exc_erro EXCEPTION;
    BEGIN
      --Inicializar variaveis retorno
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      /* Tratamento de erros para internet */
      IF  pr_cod_agencia IN (90,91)   THEN  /** internet ou TAA **/
        vr_nrdcaixa:= To_Number(pr_nrdconta||pr_idseqttl);
      ELSE
        vr_nrdcaixa:= pr_nro_caixa;
      END IF;

      --Verificar se a cooperativa existe
      OPEN cr_crapcop(pr_cdcooper => pr_cooper);
      FETCH cr_crapcop INTO rw_crapcop;
      --Se nao encontrou
      IF cr_crapcop%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcop;
        vr_cdcritic:= 651;
        vr_dscritic:= 'Registro de cooperativa nao encontrado.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapcop;

      -- Verifica se a data esta cadastrada
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se n¿o encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;

      --Eliminar erro
      pc_elimina_erro (pr_cooper      => pr_cooper       --Codigo cooperativa
                      ,pr_cod_agencia => pr_cod_agencia  --Codigo agencia
                      ,pr_nro_caixa   => vr_nrdcaixa     --Numero Caixa
                      ,pr_cdcritic    => vr_cdcritic     --Codigo do erro
                      ,pr_dscritic    => vr_dscritic);   --Descricao do erro
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      IF pr_data_off IS NULL  AND  -- Autenticacao ON-LINE 
         pr_cod_agencia <> 90 AND  -- Internet
         pr_cod_agencia <> 91 THEN -- TAA
        /*----           Atualiza BL         ------*/
        --Selecionar BL caixa online
        OPEN cr_crapcbl (pr_cdcooper => rw_crapcop.cdcooper
                        ,pr_cdagenci => pr_cod_agencia
                        ,pr_nrdcaixa => pr_nro_caixa);
        --Posicionar no proximo registro
        FETCH cr_crapcbl INTO rw_crapcbl;
        --Se nao encontrar
        IF cr_crapcbl%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_crapcbl;
          --Inserir BL do caixa online
          BEGIN
            INSERT INTO crapcbl
            (crapcbl.cdcooper
            ,crapcbl.cdagenci
            ,crapcbl.nrdcaixa)
            VALUES
            (pr_cooper
            ,pr_cod_agencia
            ,pr_nro_caixa)
            RETURNING
             crapcbl.cdcooper
            ,crapcbl.cdagenci
            ,crapcbl.nrdcaixa
            ,crapcbl.rowid
            INTO
             rw_crapcbl.cdcooper
            ,rw_crapcbl.cdagenci
            ,rw_crapcbl.nrdcaixa
            ,rw_crapcbl.rowid;
          EXCEPTION
            WHEN Dup_Val_On_Index THEN
              NULL;
            WHEN OTHERS THEN
              vr_cdcritic:= 0;
              vr_dscritic:= 'Erro ao inserir no BL do caixa online. '||sqlerrm;
              --Levantar Excecao
              RAISE vr_exc_erro;
          END;
        END IF;
        --Fechar Cursor
        IF cr_crapcbl%ISOPEN THEN
          CLOSE cr_crapcbl;
        END IF;

        /* --- Inicio do c¿digo alterado por Robinson --- */
        /* Inclusa a condicao de verificacao da id do bl  */
        IF  rw_crapcbl.blidenti <> ' ' THEN
          IF  pr_operacao THEN   /* PG  - Debito */
            --Se for estorno
            IF  pr_estorno THEN
              --Diminuir debito
              rw_crapcbl.vlcompdb:= Nvl(rw_crapcbl.vlcompdb,0) - Nvl(pr_valor,0);
            ELSE
              --Aumentar Debito
              rw_crapcbl.vlcompdb:= Nvl(rw_crapcbl.vlcompdb,0) + Nvl(pr_valor,0);
            END IF;
          ELSE
            --Se for estorno
            IF  pr_estorno THEN
              --Diminuir Credito
              rw_crapcbl.vlcompcr:= Nvl(rw_crapcbl.vlcompcr,0) - Nvl(pr_valor,0);
            ELSE
              --Aumentar Credito
              rw_crapcbl.vlcompcr:= Nvl(rw_crapcbl.vlcompcr,0) + Nvl(pr_valor,0);
            END IF;
          END IF;
          --Atualizar tabela crapcbl
          BEGIN
            UPDATE crapcbl SET crapcbl.vlcompdb = rw_crapcbl.vlcompdb
                              ,crapcbl.vlcompcr = rw_crapcbl.vlcompcr
            WHERE crapcbl.ROWID = rw_crapcbl.ROWID;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic:= 0;
              vr_dscritic:= 'Erro ao atualizar no BL do caixa online. '||sqlerrm;
              --Levantar Excecao
              RAISE vr_exc_erro;
          END;
        END IF;
      END IF;

      /* Autenticacao ON-LINE */
      IF pr_data_off IS NULL THEN
        /* Obter ultima sequencia = Caixa */
        /* Alterado para utilizar sequence atraves do Oracle */
        vr_busca :=  TRIM(rw_crapcop.cdcooper)    || ';' ||
                     TRIM(pr_cod_agencia) || ';' ||
                     TRIM(pr_nro_caixa)   || ';' ||
                     TO_char(rw_crapdat.dtmvtocd,'dd/mm/yyyy');

        vr_sequen := fn_sequence('CRAPAUT','NRSEQUEN',vr_busca);

        --Retornar a sequencia encontrada
        pr_sequencia:= vr_sequen;
        /* Atualiza Tabela de Autenticacoes */
        --Se nao for estorno
        IF NOT pr_estorno THEN
          --Transformar boolean em number
          IF pr_estorno THEN
            vr_estorno:= 1;
          ELSE
            vr_estorno:= 0;
          END IF;
          IF pr_operacao THEN
            vr_operacao:= 1;
          ELSE
            vr_operacao:= 0;
          END IF;
          --Se a empresa nao for nula
          IF nvl(pr_cdempres, ' ') <> ' ' THEN
            vr_dsobserv:= pr_cdempres;
          ELSE
            vr_dsobserv:= ' ';
          END IF;
          --Inserir autenticacao
          BEGIN
            INSERT INTO crapaut
              (crapaut.cdcooper
              ,crapaut.cdagenci
              ,crapaut.nrdcaixa
              ,crapaut.dtmvtolt
              ,crapaut.nrsequen
              ,crapaut.cdopecxa
              ,crapaut.hrautent
              ,crapaut.vldocmto
              ,crapaut.nrdocmto
              ,crapaut.tpoperac
              ,crapaut.cdstatus
              ,crapaut.estorno
              ,crapaut.cdhistor
              ,crapaut.dsobserv)
            VALUES
              (rw_crapcop.cdcooper
              ,pr_cod_agencia
              ,pr_nro_caixa
              ,rw_crapdat.dtmvtocd
              ,vr_sequen
              ,pr_cod_operador
              ,GENE0002.fn_busca_time
              ,pr_valor
              ,pr_docto
              ,vr_operacao
              ,pr_status
              ,vr_estorno
              ,pr_histor
              ,vr_dsobserv)
             RETURNING
               crapaut.ROWID
             INTO
               rw_crapaut.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic:= 0;
              vr_dscritic:= 'Erro ao atualizar no BL do caixa online. '||sqlerrm;
              --Levantar Excecao
              RAISE vr_exc_erro;
          END;
        ELSE
          /* Ultima sequencia = Autenticacao p/gravar no Estorno */
          vr_seq_aut:= 0;
          --Se for online e enviado pelo 78
          IF pr_status = '1' AND pr_sequen_off <> 0 THEN
            --Sequencia autenticacao
            vr_seq_aut:= pr_sequen_off;
          ELSE
            --Buscar ultima autenticacao
            OPEN cr_crapaut_hist (pr_cdcooper => rw_crapcop.cdcooper
                                 ,pr_cdagenci => pr_cod_agencia
                                 ,pr_nrdcaixa => pr_nro_caixa
                                 ,pr_dtmvtolt => rw_crapdat.dtmvtocd
                                 ,pr_cdhistor => pr_histor
                                 ,pr_nrdocmto => pr_docto
                                 ,pr_estorno  => 0);
            --Posicionar no primeiro registro
            FETCH cr_crapaut_hist INTO rw_crapaut;
            --Se Encontrou registro
            IF cr_crapaut_hist%FOUND THEN
              --Sequencial autenticacao
              vr_seq_aut:= rw_crapaut.nrsequen;
            END IF;
            --Fechar Cursor
            CLOSE cr_crapaut_hist;
          END IF;

          --Transformar boolean em number
          IF pr_estorno THEN
            vr_estorno:= 1;
          ELSE
            vr_estorno:= 0;
          END IF;
          IF pr_operacao THEN
            vr_operacao:= 1;
          ELSE
            vr_operacao:= 0;
          END IF;

          --Inserir autenticacao
          BEGIN
            INSERT INTO crapaut
              (crapaut.cdcooper
              ,crapaut.cdagenci
              ,crapaut.nrdcaixa
              ,crapaut.dtmvtolt
              ,crapaut.nrsequen
              ,crapaut.cdopecxa
              ,crapaut.hrautent
              ,crapaut.vldocmto
              ,crapaut.nrdocmto
              ,crapaut.tpoperac
              ,crapaut.cdstatus
              ,crapaut.estorno
              ,crapaut.nrseqaut
              ,crapaut.cdhistor)
            VALUES
              (rw_crapcop.cdcooper
              ,pr_cod_agencia
              ,pr_nro_caixa
              ,rw_crapdat.dtmvtocd
              ,vr_sequen
              ,pr_cod_operador
              ,GENE0002.fn_busca_time
              ,pr_valor
              ,pr_docto
              ,vr_operacao
              ,pr_status
              ,vr_estorno
              ,vr_seq_aut
              ,pr_histor)
             RETURNING
              crapaut.ROWID
             INTO
              rw_crapaut.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic:= 0;
              vr_dscritic:= 'Erro ao atualizar no BL do caixa online. '||sqlerrm;
              --Levantar Excecao
              RAISE vr_exc_erro;
          END;
        END IF;
      ELSE  /* Importacao OFF-LINE */
        OPEN cr_crapaut_sequen (pr_cdcooper => rw_crapcop.cdcooper
                               ,pr_cdagenci => pr_cod_agencia
                               ,pr_nrdcaixa => pr_nro_caixa
                               ,pr_dtmvtolt => pr_data_off
                               ,pr_nrsequen => pr_sequen_off);
        --Posicionar no proximo registro
        FETCH cr_crapaut_sequen INTO rw_crapaut;
        --Se nao encontrar
        IF cr_crapaut_sequen%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_crapaut_sequen;

          --Transformar boolean em number
          IF pr_estorno THEN
            vr_estorno:= 1;
          ELSE
            vr_estorno:= 0;
          END IF;
          IF pr_operacao THEN
            vr_operacao:= 1;
          ELSE
            vr_operacao:= 0;
          END IF;

          --Inserir autenticacao
          BEGIN
            INSERT INTO crapaut
              (crapaut.cdcooper
              ,crapaut.cdagenci
              ,crapaut.nrdcaixa
              ,crapaut.dtmvtolt
              ,crapaut.nrsequen
              ,crapaut.cdopecxa
              ,crapaut.hrautent
              ,crapaut.vldocmto
              ,crapaut.nrdocmto
              ,crapaut.tpoperac
              ,crapaut.cdstatus
              ,crapaut.estorno
              ,crapaut.nrseqaut
              ,crapaut.cdhistor)
            VALUES
              (rw_crapcop.cdcooper
              ,pr_cod_agencia
              ,pr_nro_caixa
              ,pr_data_off
              ,pr_sequen_off
              ,pr_cod_operador
              ,pr_hora_off
              ,pr_valor
              ,pr_docto
              ,vr_operacao
              ,pr_status
              ,vr_estorno
              ,pr_seq_aut_off
              ,pr_histor)
             RETURNING
             crapaut.ROWID
             INTO
             rw_crapaut.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic:= 0;
              vr_dscritic:= 'Erro ao atualizar no BL do caixa online. '||sqlerrm;
              --Levantar Excecao
              RAISE vr_exc_erro;
          END;
        END IF;
        --Fechar Cursor
        IF cr_crapaut_sequen%ISOPEN THEN
          CLOSE cr_crapaut_sequen;
        END IF;
      END IF;

      vr_literal2:= NULL;
      /* Autenticacao ON-LINE */
      IF pr_data_off IS NULL THEN
        /* --- Inicio do codigo alterado por Robinson --- */
        IF pr_cod_agencia <> 90 AND  -- Internet
           pr_cod_agencia <> 91 THEN -- TAA
        /* Inclusa a condicao de verificacao da id do bl  */
        IF rw_crapcbl.blidenti <> ' '  THEN
          --Atualizar tabela BL
          BEGIN
            UPDATE crapaut SET crapaut.blidenti = rw_crapcbl.blidenti
                              ,crapaut.blsldini = rw_crapcbl.vlinicial
                              ,crapaut.bltotpag = rw_crapcbl.vlcompdb
                              ,crapaut.bltotrec = rw_crapcbl.vlcompcr
                              ,crapaut.blvalrec = (rw_crapcbl.vlinicial + rw_crapcbl.vlcompdb - rw_crapcbl.vlcompcr)
            WHERE crapaut.ROWID = rw_crapaut.ROWID
            RETURNING
               crapaut.blsldini
              ,crapaut.bltotpag
              ,crapaut.bltotrec
              ,crapaut.blvalrec
            INTO
               rw_crapaut.blsldini
              ,rw_crapaut.bltotpag
              ,rw_crapaut.bltotrec
              ,rw_crapaut.blvalrec;
          EXCEPTION
            WHEN Others THEN
             vr_cdcritic:= 0;
             vr_dscritic:= 'Erro ao atualizar tabela crapcbl. '||sqlerrm;
             --Levantar Excecao
             RAISE vr_exc_erro;
          END;
          --Montar literal 2
          vr_literal2:= rw_crapaut.blidenti||' '||
                        to_char(rw_crapaut.blsldini,'999g999g999d00')||' '||
                        to_char(rw_crapaut.bltotpag,'999g999g999d00')||' '||
                        to_char(rw_crapaut.bltotrec,'999g999g999d00')||' '||
                        to_char(rw_crapaut.blvalrec,'999g999g999d00');
        END IF;
      END IF;
      END IF;
      --Retornar rowid autenticacao
      pr_registro:= rw_crapaut.rowid;

      --Obter Literal da Autenticacao
      pc_obtem_literal_autenticacao (pr_cooper   => pr_cooper
                                    ,pr_registro => rw_crapaut.rowid
                                    ,pr_literal  => vr_literal
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      -- Retornar o literal
      pr_literal := vr_literal;

      /*--- Armazena Literal de Autenticacao na Tabela crapaut --*/
      BEGIN
        UPDATE crapaut SET crapaut.dslitera = vr_literal
        WHERE crapaut.ROWID = rw_crapaut.ROWID;
      EXCEPTION
        WHEN Others THEN
         vr_cdcritic:= 0;
         vr_dscritic:= 'Erro ao atualizar tabela crapaut. '||sqlerrm;
         --Levantar Excecao
         RAISE vr_exc_erro;
      END;
      
      IF pr_cod_agencia <> 90 AND  -- Internet
         pr_cod_agencia <> 91 THEN -- TAA         
      /*----------Gera Arquivo Texto-----*/
      --Busca o caminho padrao spool web
      vr_caminho:= GENE0001.fn_param_sistema('CRED',pr_cooper,'SPOOL_WEB');
      --Montar o nome do arquivo
      vr_nmarquivo:= rw_crapcop.dsdircop|| gene0002.fn_mask(pr_cod_agencia,'999')||
                     gene0002.fn_mask(pr_nro_caixa,'999')||
                     vr_tab_dia(To_Char(rw_crapdat.dtmvtocd,'D'))||'.txt';

      --Abrir arquivo modo append
      gene0001.pc_abre_arquivo(pr_nmdireto => vr_caminho     --> Diretorio do arquivo
                              ,pr_nmarquiv => vr_nmarquivo   --> Nome do arquivo
                              ,pr_tipabert => 'A'            --> Modo de abertura (R,W,A)
                              ,pr_utlfileh => vr_input_file  --> Handle do arquivo aberto
                              ,pr_des_erro => vr_dscritic);  --> Erro
      IF vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Montar a linha a ser escrita no arquivo
      vr_setlinha:= RPad(vr_literal,48,' ')||' - '||RPad(vr_literal2,48,' ');
      --Escrever a linha no arquivo
      gene0001.pc_escr_linha_arquivo(vr_input_file,vr_setlinha);
      -- Fechar o arquivo
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
        END IF;
    EXCEPTION
       WHEN vr_exc_erro THEN
         pr_cdcritic:= vr_cdcritic;
         pr_dscritic:= vr_dscritic;
         
         -- Logar erros na autenticacao
         TARI0001.pc_gera_log_lote_uso(pr_cdcooper => pr_cooper,
                                        pr_nrdconta => pr_nrdconta,
                                        pr_nrdolote => 0,
                                        pr_flgerlog => vr_flgerlog,
                                        pr_des_log  => 'Raise vr_exec_erro -> ' ||
                                                        'cdcooper: ' ||  to_char(pr_cooper) || ' ' ||
                                                        'dtmvtolt: ' ||  to_char(sysdate,'dd/mm/yyyy') || ' ' ||
                                                        'cdagenci: ' ||  to_char(pr_cod_agencia)  || ' ' ||
                                                        'nrdconta: ' ||  to_char(pr_nrdconta) || ' ' ||
                                                        'nrdcaixa: ' ||  to_char(pr_nro_caixa) || ' ' ||
                                                        'Valor: '    ||  to_char(pr_valor) || ' ' ||
                                                        'nrsequen: ' ||  to_char(pr_sequen_off) || ' ' ||
                                                        'critica: ' ||   pr_dscritic || ' ' ||
                                                        'rotina: CXON0000.grava_autenticacao_internet ');
       WHEN OTHERS THEN
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro na rotina CXON0000.pc_grava_autenticacao_internet. '||SQLERRM;
         
         -- Logar erros na autenticacao
         TARI0001.pc_gera_log_lote_uso(pr_cdcooper => pr_cooper,
                                        pr_nrdconta => pr_nrdconta,
                                        pr_nrdolote => 0,
                                        pr_flgerlog => vr_flgerlog,
                                        pr_des_log  => 'Raise vr_exec_erro -> ' ||
                                                        'cdcooper: ' ||  to_char(pr_cooper) || ' ' ||
                                                        'dtmvtolt: ' ||  to_char(sysdate,'dd/mm/yyyy') || ' ' ||
                                                        'cdagenci: ' ||  to_char(pr_cod_agencia)  || ' ' ||
                                                        'nrdconta: ' ||  to_char(pr_nrdconta) || ' ' ||
                                                        'nrdcaixa: ' ||  to_char(pr_nro_caixa) || ' ' ||
                                                        'Valor: '    ||  to_char(pr_valor) || ' ' ||
                                                        'nrsequen: ' ||  to_char(pr_sequen_off) || ' ' ||
                                                        'critica: ' ||   pr_dscritic || ' ' ||
                                                        'rotina: CXON0000.grava_autenticacao_internet ');
    END;
  END pc_grava_autenticacao_internet;

  /* Calcular Digito verificador IPTU e SAMAE Blumenau */
  PROCEDURE pc_calc_digito_iptu_samae (pr_valor    IN OUT VARCHAR2   --> Valor Calculado
                                      ,pr_nrdigito OUT INTEGER     --> Digito Verificador
                                      ,pr_retorno  OUT BOOLEAN) IS --> Retorno digito correto
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_calc_digito_iptu_samae    Antigo: dbo/pcrap04.p
  --  Sistema  : Calcular Digito verificador IPTU e SAMAE Blumenau
  --  Sigla    : CRED
  --  Autor    : Alisson C. Berrido - Amcom
  --  Data     : Junho/2013.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Calcular Digito verificador IPTU e SAMAE Blumenau

  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      --Variaveis Locais
      vr_nrdigbar  INTEGER := 0;
      vr_digito    INTEGER := 0;
      vr_posicao   INTEGER := 0;
      vr_peso      INTEGER := 2;
      vr_calculo   INTEGER := 0;
      vr_resto     INTEGER := 0;
      vr_dscorbar  VARCHAR2(4000);
      vr_dscalcul  VARCHAR2(4000);
      vr_conver    VARCHAR2(4000);
      vr_dscalcll  PLS_INTEGER;

      --Variaveis Excecao
      vr_exc_erro EXCEPTION;

    BEGIN
      vr_dscorbar := LPAD(pr_valor, 44, '0');
      vr_dscalcul := SUBSTR(vr_dscorbar, 1, 3) || SUBSTR(vr_dscorbar, 5, 40);
      vr_nrdigbar := TO_NUMBER(SUBSTR(vr_dscorbar, 4, 1));
      vr_dscalcll := LENGTH(vr_dscalcul);

      --Percorrer o codigo de barras
      FOR vr_posicao IN 1..vr_dscalcll LOOP
        --Valor Convertido
        vr_conver := TO_CHAR(TO_NUMBER(SUBSTR(vr_dscalcul, vr_posicao, 1)) * vr_peso);

        IF LENGTH(vr_conver) = 2 THEN
          vr_calculo := vr_calculo + TO_NUMBER(SUBSTR(vr_conver, 1, 1)) + TO_NUMBER(SUBSTR(vr_conver, 2, 1));
        ELSE
          vr_calculo := vr_calculo + TO_NUMBER(vr_conver);
        END IF;

        --Se peso for 2
        IF vr_peso = 2 THEN
          vr_peso := 1;
        ELSE
          vr_peso := 2;
        END IF;
      END LOOP;

      --Verificar resto
      vr_resto := 10 - MOD(vr_calculo, 10);

      IF vr_resto = 10 THEN
        --Digito recebe zero
        vr_digito := 0;
      ELSE
        --Digito recebe resto
        vr_digito := vr_resto;
      END IF;

      --Verificar se o digito confere
      pr_retorno := vr_digito = vr_nrdigbar;

      --Retornar Digito
      pr_nrdigito := vr_digito;
      --Retornar Numero Calculado
      pr_valor := SUBSTR(vr_dscorbar, 1, 3) || vr_digito || SUBSTR(vr_dscorbar, 5, 40);
    EXCEPTION
       WHEN OTHERS THEN
         pr_retorno := FALSE;
    END;
  END pc_calc_digito_iptu_samae;

  /* Calcular Digito verificador Titulo */
  PROCEDURE pc_calc_digito_verif (pr_valor        IN OUT VARCHAR2   --> Valor Calculado
                                 ,pr_valida_zeros IN BOOLEAN      --> Validar Zeros
                                 ,pr_nro_digito   OUT INTEGER     --> Digito Verificador
                                 ,pr_retorno      OUT BOOLEAN) IS --> Retorno digito correto
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_calc_digito_verif    Antigo: dbo/pcrap03.p
  --  Sistema  : Procedure para calcular digito verificador titulo
  --  Sigla    : CRED
  --  Autor    : Alisson C. Berrido - Amcom
  --  Data     : Junho/2013.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para calcular digito verificador titulo

  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE

      --Variaveis Locais
      vr_digito  INTEGER:= 0;
      vr_peso    INTEGER:= 2;
      vr_calculo INTEGER:= 0;
      vr_dezena  INTEGER:= 0;
      vr_resulta INTEGER:= 0;
      --Variaveis Excecao
      vr_exc_erro EXCEPTION;
    BEGIN
      --Verificar tamanho
      IF pr_valida_zeros AND LENGTH(pr_valor) < 2  THEN
        --Retornar false
        pr_retorno:= FALSE;
      ELSE
        --Percorrer o valor
        FOR idx IN REVERSE 1..Length(pr_valor) - 1 LOOP
          --Resultado
          vr_resulta:= TO_NUMBER(SUBSTR(pr_valor,idx,1)) * vr_peso;
          IF  vr_resulta > 9  THEN
            vr_resulta:= TO_NUMBER(SUBSTR(gene0002.fn_mask(vr_resulta,'99'),1,1)) +
                         To_Number(SUBSTR(gene0002.fn_mask(vr_resulta,'99'),2,1));
          END IF;
          --Valor Calculado
          vr_calculo:= vr_calculo + vr_resulta;
          --Diminuir o peso
          vr_peso:= vr_peso-1;
          --Se o peso = 0
          IF vr_peso = 0 THEN
            vr_peso:= 2;
          END IF;
        END LOOP;
        --Determinar Dezena
        vr_dezena:= (TO_NUMBER(SUBSTR(gene0002.fn_mask(vr_calculo,'999'),1,2)) + 1) * 10;
        --Determinar o digito
        vr_digito:= vr_dezena - vr_calculo;
        --Se o digito=10
        IF vr_digito = 10  THEN
          vr_digito:= 0;
        END IF;
        --Verificar o digito passado com o calculado
        pr_retorno:= TO_NUMBER(SUBSTR(pr_valor,LENGTH(pr_valor),1)) = vr_digito;
        --Retornar numero calculado
        pr_valor:= SUBSTR(pr_valor,1,LENGTH(pr_valor) - 1) || vr_digito;
        --Retornar Digito
        pr_nro_digito:= vr_digito;
      END IF;
    EXCEPTION
       WHEN OTHERS THEN
         pr_retorno:= FALSE;
    END;
  END pc_calc_digito_verif;

  /* Calcular Digito verificador Titulo */
  PROCEDURE pc_calc_digito_titulo (pr_valor        IN OUT VARCHAR2   --> Valor Calculado
                                  ,pr_retorno      OUT BOOLEAN) IS --> Retorno digito correto
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_calc_digito_titulo             Antigo: dbo/pcrap05.p
  --                                               Antigo: fontes/digcbtit.p
  --  Sistema  : Procedure para calcular digito verificador titulo
  --  Sigla    : CRED
  --  Autor    : Alisson C. Berrido - Amcom
  --  Data     : Junho/2013.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para calcular digito verificador titulo

  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE

      --Variaveis Locais
      vr_dscalcul VARCHAR2(100);
      vr_nrdigbar INTEGER:= 0;
      vr_digito   INTEGER:= 0;
      vr_peso     INTEGER:= 2;
      vr_calculo  INTEGER:= 0;
      vr_resto    INTEGER:= 0;
      --Variaveis Excecao
      vr_exc_erro EXCEPTION;
    BEGIN
      --Verificar se o codigo de barras esta zerado
      IF pr_valor = 0  THEN  /* Codigo de barras zerado */
        pr_retorno:= FALSE;
        RETURN;
      ELSIF SUBSTR(gene0002.fn_mask(pr_valor,'99999999999999999999999999999999999999999999'),5,1) = '0' THEN
        /* Nao tem digito verificador */
        pr_retorno:= TRUE;
        RETURN;
      END IF;
      --Calculo
      vr_dscalcul:= gene0002.fn_mask(pr_valor,'99999999999999999999999999999999999999999999');
      pr_valor:= SUBSTR(vr_dscalcul,01,04) || SUBSTR(vr_dscalcul,06,39);
      --Digito Codigo Barras
      vr_nrdigbar:= TO_NUMBER(SUBSTR(vr_dscalcul,5,1));
      --Percorrer o codigo de barras
      FOR idx IN REVERSE 1..LENGTH(pr_valor) LOOP
        --Calcular a posicao com o peso
        vr_calculo:= vr_calculo + (TO_NUMBER(SUBSTR(pr_valor,idx,1)) * vr_peso);
        --Incrementar peso em 1
        vr_peso:= vr_peso+1;
        --Se peso > 9
        IF vr_peso > 9  THEN
          vr_peso:= 2;
        END IF;
      END LOOP;
      --Resto
      vr_resto:= 11 - MOD(vr_calculo,11);
      IF vr_resto > 9  OR vr_resto IN (0,1) THEN
        vr_digito:= 1;
      ELSE
        vr_digito:= vr_resto;
      END IF;
      --Verificar se o digito calculado confere com o do codigo barras
      pr_retorno:= vr_digito = vr_nrdigbar;
      --Retonar numero calculado
      pr_valor:= SUBSTR(vr_dscalcul,01,04) || vr_digito ||SUBSTR(vr_dscalcul,06,39);

    EXCEPTION
       WHEN OTHERS THEN
         pr_retorno:= FALSE;
    END;
  END pc_calc_digito_titulo;


  /* Calcular Digito verificador Titulo */
  PROCEDURE pc_calc_digito_titulo_mod11 (pr_valor      IN OUT VARCHAR2   --> Valor Calculado
                                        ,pr_nro_digito OUT INTEGER     --> Digito verificador
                                        ,pr_retorno    OUT BOOLEAN) IS --> Retorno digito correto
  /* .............................................................................

   Programa: pc_calc_digito_titulo_mod11        Antigo: Siscaixa/web/dbo/pcrap14.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Magui
   Data    : Outubro/2008                    Ultima atualizacao: 10/10/2008

   Dados referentes ao programa:

   Frequencia: Sempre que chamado por outros programas.
   Objetivo  : Calcular e conferir o digito verificador pelo modulo onze.

   Alteracoes: 01/08/2013  Migracao Progress --> Oracle (Alisson - AMcom)

  ............................................................................. */
  BEGIN
    DECLARE

      --Variaveis Locais
      vr_digito   INTEGER:= 0;
      vr_peso     INTEGER:= 9;
      vr_calculo  INTEGER:= 0;
      vr_resto    INTEGER:= 0;
      vr_strnume  VARCHAR2(1000);
      --Variaveis Excecao
      vr_exc_erro EXCEPTION;
    BEGIN

      IF LENGTH(pr_valor) < 44 THEN
        pr_retorno:= FALSE;
      ELSE
        --Separar o digito do codigo de barras
        vr_strnume:= SUBSTR(gene0002.fn_mask(pr_valor,'99999999999999999999999999999999999999999999'),1,3)||
                     SUBSTR(gene0002.fn_mask(pr_valor,'99999999999999999999999999999999999999999999'),5,40);
        --Peso 2
        vr_peso:= 2;
        --Percorrer o codigo de barras
        FOR idx IN REVERSE 1..LENGTH(vr_strnume) LOOP
          --Calcular a posicao com o peso
          vr_calculo:= vr_calculo + (TO_NUMBER(SUBSTR(vr_strnume,idx,1)) * vr_peso);

          --Se peso = 9 volta pra 2, senao incrementa 1 no peso
          IF vr_peso = 9  THEN
            vr_peso:= 2;
          ELSE
            --Incrementar peso em 1
            vr_peso:= vr_peso+1;
          END IF;
        END LOOP;
        --Resto
        vr_resto:= MOD(vr_calculo,11);

        CASE vr_resto
          WHEN 0 THEN  vr_digito:= 0;
          WHEN 1 THEN  vr_digito:= 0;
          WHEN 10 THEN vr_digito:= 1;
          ELSE vr_digito:= 11 - vr_resto;
        END CASE;

        --Verificar se o digito calculado confere com o do codigo barras
        pr_retorno:= vr_digito = to_number(SUBSTR(gene0002.fn_mask(pr_valor,'99999999999999999999999999999999999999999999'),4,1));
        --Retonar digito calculado
        pr_nro_digito:= vr_digito;
      END IF;
    EXCEPTION
       WHEN OTHERS THEN
         pr_retorno:= FALSE;
    END;
  END pc_calc_digito_titulo_mod11;


  /* Procedure para verificar o digito da internet */
  PROCEDURE pc_verifica_digito_internet (pr_cooper       IN INTEGER                    --Codigo Cooperativa
                                        ,pr_nrdconta     IN INTEGER                    --Numero da Conta
                                        ,pr_idseqttl     IN crapttl.idseqttl%TYPE      --Sequencial do titular
                                        ,pr_cod_agencia  IN INTEGER                    --Codigo Agencia
                                        ,pr_nro_caixa    IN INTEGER                    --Numero do caixa
                                        ,pr_nro_conta    IN OUT NUMBER                 --Codigo Da Conta
                                        ,pr_cdcritic     OUT INTEGER     --C¿digo do erro
                                        ,pr_dscritic     OUT VARCHAR2) IS --Descricao do erro
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_verifica_digito_internet    Antigo: dbo/b2crap00.p/verifica-digito-internet
  --  Sistema  : Procedure para verificar digito da internet
  --  Sigla    : CRED
  --  Autor    : Alisson C. Berrido - Amcom
  --  Data     : Julho/2013.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para verificar digito da internet

  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      --Variaveis Locais
      vr_digito   INTEGER:= 0;
      vr_posicao  INTEGER:= 0;
      vr_peso     INTEGER:= 9;
      vr_calculo  INTEGER:= 0;
      vr_resto    INTEGER:= 0;
      vr_nrdcaixa INTEGER;
      vr_ctcefcon INTEGER;
      --Variaveis Erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis Excecao
      vr_exc_saida EXCEPTION;
      vr_exc_erro  EXCEPTION;
    BEGIN
      --Inicializar variaveis retorno
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;
      /* Tratamento de erros para internet e TAA */

      /** Internet ou TAA **/
      IF pr_cod_agencia IN (90,91) THEN
        --Numero da caixa
        vr_nrdcaixa:= TO_NUMBER(pr_nrdconta||pr_idseqttl);
      ELSE
        --Numero da caixa
        vr_nrdcaixa:= pr_nro_caixa;
      END IF;

      --Verificar se a cooperativa existe
      OPEN cr_crapcop(pr_cdcooper => pr_cooper);
      FETCH cr_crapcop INTO rw_crapcop;
      --Se nao encontrou
      IF cr_crapcop%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcop;
        vr_cdcritic:= 651;
        vr_dscritic:= 'Registro de cooperativa nao encontrado.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapcop;
      --Eliminar erro
      pc_elimina_erro (pr_cooper      => pr_cooper
                      ,pr_cod_agencia => pr_cod_agencia
                      ,pr_nro_caixa   => pr_nro_caixa
                      ,pr_cdcritic    => vr_cdcritic
                      ,pr_dscritic    => vr_dscritic);
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      /*Busca parametro - Conta Convenio Caixa-Concredi*/
      vr_ctcefcon:= to_number(gene0001.fn_param_sistema('CRED',pr_cooper,'CTA_CONCREDI_CEF_INTEGRA'));
      /*Identifica conta do convenio com a Caixa-Concredi*/
      IF pr_nro_conta = vr_ctcefcon THEN
        --Sair
        RAISE vr_exc_saida;
      END IF;
      --Se a conta estiver incompleta
      IF LENGTH(pr_nro_conta) < 2 THEN
        --Criar Erro
        pc_cria_erro(pr_cdcooper => pr_cooper
                    ,pr_cdagenci => pr_cod_agencia
                    ,pr_nrdcaixa => vr_nrdcaixa
                    ,pr_cod_erro => 8
                    ,pr_dsc_erro => NULL
                    ,pr_flg_erro => TRUE
                    ,pr_cdcritic => vr_cdcritic
                    ,pr_dscritic => vr_dscritic);
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        ELSE
          vr_cdcritic:= 8;
          vr_dscritic:= NULL;
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
      END IF;
      --Calcular Digito
      FOR vr_posicao IN REVERSE 1..Length(pr_nro_conta) -1 LOOP
        --Calculo
        vr_calculo:= vr_calculo + (TO_NUMBER(SUBSTR(pr_nro_conta,vr_posicao,1)) * vr_peso);
        --Diminuir o peso
        vr_peso:= vr_peso - 1;
        IF vr_peso = 1 THEN
          vr_peso:= 9;
        END IF;
      END LOOP;
      --Resto no Modulo 11
      vr_resto:= Mod(vr_calculo,11);
      IF  vr_resto > 9 THEN
        --Digito
        vr_digito:= 0;
      ELSE
        vr_digito:= vr_resto;
      END IF;

      IF (TO_NUMBER(SUBSTR(pr_nro_conta,LENGTH(pr_nro_conta),1))) <> vr_digito THEN
        --Criar Erro
        pc_cria_erro(pr_cdcooper => pr_cooper
                    ,pr_cdagenci => pr_cod_agencia
                    ,pr_nrdcaixa => vr_nrdcaixa
                    ,pr_cod_erro => 8
                    ,pr_dsc_erro => NULL
                    ,pr_flg_erro => TRUE
                    ,pr_cdcritic => vr_cdcritic
                    ,pr_dscritic => vr_dscritic);
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        ELSE
          vr_cdcritic:= 8;
          vr_dscritic:= NULL;
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
      END IF;
      --Numero da Conta
      pr_nro_conta:= TO_NUMBER(SUBSTR(pr_nro_conta,1,LENGTH(pr_nro_conta)-1)||vr_digito);
    EXCEPTION
       WHEN vr_exc_saida THEN
         NULL;
       WHEN vr_exc_erro THEN
         pr_cdcritic:= vr_cdcritic;
         pr_dscritic:= vr_dscritic;
       WHEN OTHERS THEN
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro na rotina CXON0000.pc_verifica_digito_internet. '||SQLERRM;
    END;
  END pc_verifica_digito_internet;

  PROCEDURE pc_atualiza_previa_cxa(pr_cooper            IN VARCHAR2 -- Codigo Cooperativa
                                  ,pr_cod_agencia       IN INTEGER  -- Codigo Agencia
                                  ,pr_nro_caixa         IN INTEGER -- Codigo do Caixa
                                  ,pr_cod_operador      IN VARCHAR2 -- Codigo Operador
                                  ,pr_dtmvtolt          IN DATE
                                  ,pr_operacao          IN INTEGER
                                  ,pr_retorno           OUT VARCHAR2 -- Retorna OK/NOK
                                  ,pr_cdcritic          OUT INTEGER -- Codigo da Critica
                                  ,pr_dscritic          OUT VARCHAR2) IS -- Descricao da Critica
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_atualiza_previa_cxa Fonte: dbo/b1crap00.p/atualiza-previa-caixa
  --  Sistema  : Procedure que atualiza previas do caixa
  --  Sigla    : CRED
  --  Autor    : Andre Santos - SUPERO
  --  Data     : Julho/2014.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  :

  -- Alteracoes:
  ---------------------------------------------------------------------------------------------------------------

  /* Busca o codigo da Coop. passando como parametro o nome resumido da Coop. */
  CURSOR cr_cod_coop_orig(p_nmrescop IN VARCHAR2) IS
    SELECT cop.cdcooper
          ,cop.cdagectl
          ,cop.cdagebcb
          ,cop.cdbcoctl
          ,cop.cdagedbb
          ,cop.nmrescop
      FROM crapcop cop
     WHERE UPPER(cop.nmrescop) = UPPER(p_nmrescop);
  rw_cod_coop_orig cr_cod_coop_orig%ROWTYPE;

  /* Busca a Data Conforme o Código da Cooperativa */
  CURSOR cr_dat_cop(p_coop IN INTEGER)IS
     SELECT dat.dtmvtolt
           ,dat.dtmvtocd
       FROM crapdat dat
      WHERE dat.cdcooper = p_coop;
  rw_dat_cop cr_dat_cop%ROWTYPE;


  /* Verifica se existe registro na CRAPBCX */
  CURSOR cr_existe_bcx(p_cdcooper IN INTEGER
                      ,p_dtmvtolt IN DATE
                      ,p_cdagenci IN INTEGER
                      ,p_nrdcaixa IN INTEGER
                      ,p_cdopecxa IN VARCHAR2)IS
      SELECT bcx.qtcompln
            ,bcx.nrdmaqui
            ,bcx.qtchqprv
        FROM crapbcx bcx
       WHERE bcx.cdcooper = p_cdcooper
         AND bcx.dtmvtolt = p_dtmvtolt
         AND bcx.cdagenci = p_cdagenci
         AND bcx.nrdcaixa = p_nrdcaixa
         AND UPPER(bcx.cdopecxa) = UPPER(p_cdopecxa);
  rw_existe_bcx cr_existe_bcx%ROWTYPE;

  -- Variaveis Erro
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(4000);
  vr_exc_erro EXCEPTION;

  -- Variavel
  vr_qtchqprv INTEGER;
  vr_retorno  VARCHAR2(10);

  -- Guardar registro dstextab
  vr_dstextab craptab.dstextab%TYPE;

  BEGIN

     -- Busca Cod. Coop de ORIGEM
     OPEN cr_cod_coop_orig(pr_cooper);
     FETCH cr_cod_coop_orig INTO rw_cod_coop_orig;
     CLOSE cr_cod_coop_orig;

     -- Busca Data do Sistema
     OPEN cr_dat_cop(rw_cod_coop_orig.cdcooper);
     FETCH cr_dat_cop INTO rw_dat_cop;
     CLOSE cr_dat_cop;

     OPEN cr_existe_bcx(rw_cod_coop_orig.cdcooper
                       ,rw_dat_cop.dtmvtolt
                       ,pr_cod_agencia
                       ,pr_nro_caixa
                       ,pr_cod_operador);
     FETCH cr_existe_bcx INTO rw_existe_bcx;
        -- Se encontrou registro
        IF cr_existe_bcx%FOUND THEN
           IF pr_operacao = 1 THEN /** Inclusão **/
              BEGIN
                 UPDATE crapbcx bcx
                    SET bcx.qtchqprv = bcx.qtchqprv + 1
                       ,bcx.qtcompln = bcx.qtcompln + 1
                  WHERE bcx.cdcooper = rw_cod_coop_orig.cdcooper
                    AND bcx.dtmvtolt = rw_dat_cop.dtmvtolt
                    AND bcx.cdagenci = pr_cod_agencia
                    AND bcx.nrdcaixa = pr_nro_caixa
                    AND bcx.cdopecxa = pr_cod_operador;
              EXCEPTION
                 WHEN OTHERS THEN
                     pr_cdcritic := 0;
                     pr_dscritic := 'Erro ao atualizar registro da CRAPBCX: '||sqlerrm;
                     RAISE vr_exc_erro;
              END;
           ELSE
              IF pr_operacao = 2 THEN /** Estorno **/
                 BEGIN
                    UPDATE crapbcx bcx
                       SET bcx.qtchqprv = bcx.qtchqprv - 1
                          ,bcx.qtcompln = bcx.qtcompln - 1
                     WHERE bcx.cdcooper = rw_cod_coop_orig.cdcooper
                       AND bcx.dtmvtolt = rw_dat_cop.dtmvtolt
                       AND bcx.cdagenci = pr_cod_agencia
                       AND bcx.nrdcaixa = pr_nro_caixa
                       AND bcx.cdopecxa = pr_cod_operador;
                 EXCEPTION
                    WHEN OTHERS THEN
                       pr_cdcritic := 0;
                       pr_dscritic := 'Erro ao atualizar registro da CRAPBCX: '||sqlerrm;
                       RAISE vr_exc_erro;
                 END;
              ELSE
                 IF pr_operacao = 3 THEN /** 3 - Consulta **/
                   
                    -- Buscar configuração na tabela
                    vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                                             ,pr_nmsistem => 'CRED'
                                                             ,pr_tptabela => 'GENERI'
                                                             ,pr_cdempres => 0
                                                             ,pr_cdacesso => 'EXETRUNCAGEM'
                                                             ,pr_tpregist => pr_cod_agencia);                 
                        
                    IF TRIM(vr_dstextab) IS NOT NULL OR vr_dstextab = 'NAO' THEN
                       pr_retorno  := 'OK';
                    ELSE

                        pc_valida_agencia(pr_cooper      => pr_cooper
                                         ,pr_cod_agencia => pr_cod_agencia
                                         ,pr_nro_caixa   => pr_nro_caixa
                                         ,pr_qtchqprv    => vr_qtchqprv
                                         ,pr_retorno     => vr_retorno
                                         ,pr_cdcritic    => vr_cdcritic
                                         ,pr_dscritic    => vr_dscritic);

                        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                           pr_cdcritic := vr_cdcritic;
                           pr_dscritic := vr_dscritic;

                           cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                                ,pr_cdagenci => pr_cod_agencia
                                                ,pr_nrdcaixa => pr_nro_caixa
                                                ,pr_cod_erro => vr_cdcritic
                                                ,pr_dsc_erro => vr_dscritic
                                                ,pr_flg_erro => TRUE
                                                ,pr_cdcritic => vr_cdcritic
                                                ,pr_dscritic => vr_dscritic);

                           IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                              pr_cdcritic := vr_cdcritic;
                              pr_dscritic := vr_dscritic;
                              RAISE vr_exc_erro;
                           END IF;

                           RAISE vr_exc_erro;

                        END IF;

                        IF rw_existe_bcx.qtchqprv > vr_qtchqprv THEN

                           pr_cdcritic := 0;
                           pr_dscritic := 'Fazer previa dos cheques.';

                           cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                                ,pr_cdagenci => pr_cod_agencia
                                                ,pr_nrdcaixa => pr_nro_caixa
                                                ,pr_cod_erro => vr_cdcritic
                                                ,pr_dsc_erro => vr_dscritic
                                                ,pr_flg_erro => TRUE
                                                ,pr_cdcritic => vr_cdcritic
                                                ,pr_dscritic => vr_dscritic);

                           IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                              pr_cdcritic := vr_cdcritic;
                              pr_dscritic := vr_dscritic;
                              RAISE vr_exc_erro;
                           END IF;

                           RAISE vr_exc_erro;

                        END IF;

                    END IF;

                 END IF;
              END IF;
           END IF;
        END IF;
     CLOSE cr_existe_bcx;

     pr_retorno  := 'OK';

  EXCEPTION
     WHEN vr_exc_erro THEN
        pr_retorno  := 'NOK';
        ROLLBACK; -- Desfazer a operacao

     WHEN OTHERS THEN
         ROLLBACK; -- Desfazer a operacao
         pr_retorno  := 'NOK';
         pr_cdcritic := 0;
         pr_dscritic := 'Erro na rotina CXON0000.pc_atualiza_previa_cxa: '||SQLERRM;

         cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                              ,pr_cdagenci => pr_cod_agencia
                              ,pr_nrdcaixa => pr_nro_caixa
                              ,pr_cod_erro => pr_cdcritic
                              ,pr_dsc_erro => pr_dscritic
                              ,pr_flg_erro => TRUE
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);

         IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := vr_dscritic;
         END IF;

  END pc_atualiza_previa_cxa;

  PROCEDURE pc_valida_agencia(pr_cooper            IN VARCHAR2      --> Codigo Cooperativa
                             ,pr_cod_agencia       IN INTEGER       --> Codigo Agencia
                             ,pr_nro_caixa         IN INTEGER       --> Codigo do Caixa
                             ,pr_qtchqprv          OUT INTEGER      --> Qtd de Previas
                             ,pr_retorno           OUT VARCHAR2     --> Retorna OK/NOK
                             ,pr_cdcritic          OUT INTEGER      --> Codigo da Critica
                             ,pr_dscritic          OUT VARCHAR2) IS --> Descricao da Critica
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_valida_agencia Fonte: dbo/b1crap00.p/valida-agencia
  --  Sistema  : Procedure para Validar Agencias - PA
  --  Sigla    : CRED
  --  Autor    : Andre Santos - SUPERO
  --  Data     : Julho/2014.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  :

  -- Alteracoes:
  ---------------------------------------------------------------------------------------------------------------

  /* Busca o codigo da Coop. passando como parametro o nome resumido da Coop. */
  CURSOR cr_cod_coop_orig(p_nmrescop IN VARCHAR2) IS
    SELECT cop.cdcooper
          ,cop.cdagectl
          ,cop.cdagebcb
          ,cop.cdbcoctl
          ,cop.cdagedbb
          ,cop.nmrescop
      FROM crapcop cop
     WHERE UPPER(cop.nmrescop) = UPPER(p_nmrescop);
  rw_cod_coop_orig cr_cod_coop_orig%ROWTYPE;

  /* Verifica Agencia */
  CURSOR cr_verifica_age(p_cdcooper IN INTEGER
                        ,p_cdagenci IN INTEGER) IS
    SELECT age.qtchqprv
      FROM crapage age
     WHERE age.cdcooper = p_cdcooper
       AND age.cdagenci = p_cdagenci;
  rw_verifica_age cr_verifica_age%ROWTYPE;

  -- Variaveis Erro
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(4000);
  vr_exc_erro EXCEPTION;

  BEGIN

     -- Busca Cod. Coop de ORIGEM
     OPEN cr_cod_coop_orig(pr_cooper);
     FETCH cr_cod_coop_orig INTO rw_cod_coop_orig;
     CLOSE cr_cod_coop_orig;

     -- Busca Data do Sistema
     OPEN cr_verifica_age(rw_cod_coop_orig.cdcooper
                         ,pr_cod_agencia);
     FETCH cr_verifica_age INTO rw_verifica_age;
         IF cr_verifica_age%NOTFOUND THEN

            pr_cdcritic := 962;
            pr_dscritic := '';

            cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                 ,pr_cdagenci => pr_cod_agencia
                                 ,pr_nrdcaixa => pr_nro_caixa
                                 ,pr_cod_erro => pr_cdcritic
                                 ,pr_dsc_erro => pr_dscritic
                                 ,pr_flg_erro => TRUE
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);

            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
               pr_cdcritic := vr_cdcritic;
               pr_dscritic := vr_dscritic;
               RAISE vr_exc_erro;
            END IF;

            RAISE vr_exc_erro;

         ELSE

            IF pr_cod_agencia = 90 OR   /** Internet **/
               pr_cod_agencia = 91 THEN /** TAA      **/

               pr_cdcritic := 0;
               pr_dscritic := 'PA nao permitido.';

               cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                    ,pr_cdagenci => pr_cod_agencia
                                    ,pr_nrdcaixa => pr_nro_caixa
                                    ,pr_cod_erro => vr_cdcritic
                                    ,pr_dsc_erro => vr_dscritic
                                    ,pr_flg_erro => TRUE
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);

               IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                  pr_cdcritic := vr_cdcritic;
                  pr_dscritic := vr_dscritic;
                  RAISE vr_exc_erro;
               END IF;

               RAISE vr_exc_erro;

            END IF;

         END IF;
     CLOSE cr_verifica_age;

     pr_retorno  := 'OK';

  EXCEPTION
     WHEN vr_exc_erro THEN
        pr_retorno  := 'NOK';

     WHEN OTHERS THEN
         pr_retorno  := 'NOK';
         pr_cdcritic := 0;
         pr_dscritic := 'Erro na rotina CXON0000.pc_valida_agencia: '||SQLERRM;

         cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                              ,pr_cdagenci => pr_cod_agencia
                              ,pr_nrdcaixa => pr_nro_caixa
                              ,pr_cod_erro => pr_cdcritic
                              ,pr_dsc_erro => pr_dscritic
                              ,pr_flg_erro => TRUE
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);

         IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := vr_dscritic;
         END IF;

  END pc_valida_agencia;

END CXON0000;
/
