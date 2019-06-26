CREATE OR REPLACE PACKAGE CECRED.CYBE0001 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa: CYBE0001                        Antiga: generico/procedures/b1wgen0168.p
  --  Autor   : James Prust Junior
  --  Data    : Agosto/2013                     Ultima Atualizacao: 05/06/2018
  --
  --  Dados referentes ao programa:
  --
  --  Objetivo  : Package referente a regras de geracao de arquivos CYBER
  --
  --  Alteracoes: 26/09/2013 - Atualizar o campo dtatufin da tabela crapcyb.(James)
  --
  --              30/09/2013 - Conversao Progress para oracle (Gabriel).
  --
  --              04/10/2013 - Conversao Progress para oracle da rotina pc_atualiza_dados
  --                           ( Renato-Supero / Odirlei-AMcom )
  --
  --              11/11/2013 - Ajuste na procedure
  --                          "atualiza_data_manutencao_cadastro" para melhorar
  --                           a performance. (James)
  --
  --              14/11/2013 - Ajuste para nao atualizar as flag de judicial e
  --                           vip no cyber (James).
  --
  --              12/12/2013 - Adicionado VALIDATE para CREATE. (Jorge)
  --
  --              27/12/2013 - Ajuste na procedure "atualiza_dados_financeiro"
  --                           para atualizar a data de pagamento (James)
  --
  --              11/02/2014 - Ajuste na procedure "atualiza_dados_fi
  --                           para criar registro no CYBER (James).
  --
  --                           - Removido as procedures "atualiza_emprestimo",
  --                           "atualiza_conta", "atualiza_desconto" e "atualiza_dados_gerais". (James)
  --
  --              26/02/2014 - Manutenção 201402. Adicionadas novas colunas no insert e update
  --                           da tabela crapcyb na rotina pc_atualiza_dados_financeiro (Edison-Amcom)
  --
  --              06/03/2014 - Ajuste na procedure "atualiza_dados_financeiro"
  --                           para somente atualizar os valores, caso nao tiver
  --                           baixado (James)
  --
  --              05/05/2014 - Removido o parametro dtatufin da procedure "pc_atualiza_dados_financeiro". (James)
  --
  --              27/10/2015 - Incluido nova verificacao do campo crapass.indserma na procedure pc_proc_alteracoes_log,
  --                           Prj. 131 - Assinatura Conjunta. (Jean Michel).
  --
  --              29/02/2016 - Trocando o campo flpolexp para inpolexp conforme
  --                           solicitado no chamado 402159 (Kelvin)
  --
  --              11/05/2017 - Modificada a pc_importa_arquivo_cyber, para efetuar leituras de tabelas através de cursor
  --                           atendendo às melhores práticas de programação da Cecred - (Jean / MOut´S)
  --
  --              03/04/2018 - Inserido a procedure pc_altera_dados_crapcyc - (Chamado 806202)
  --
  --              05/06/2018 - Ajuste para adicionar Desconto de Titulos (Andrew Albuquerque - GFT)
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Definir o registro de memória que guardará os dados para atualização
  TYPE typ_crapcyb IS TABLE OF crapcyb%ROWTYPE INDEX BY BINARY_INTEGER;

  -- Atualiza os dados conforme o cdorigem para geração de arquivos cyber
  PROCEDURE pc_atualiza_dados(pr_tbcrapcyb   IN typ_crapcyb           --> pl/table com os registros a serem atualizados
                             ,pr_cdorigem    IN crapcyb.cdorigem%type  --> codigo da origem (1-conta, 2-Desconto, 3-Emprestimo)
                             ,pr_dscritic   OUT VARCHAR2);            --> Descrição da critica

  PROCEDURE pc_atualiza_dados_financeiro
                                    (pr_cdcooper IN INTEGER  -- Codigo da Cooperativa
                                    ,pr_nrdconta IN INTEGER  -- Numero da conta
                                    ,pr_nrctremp IN INTEGER  -- Numero do contrato
                                    ,pr_cdorigem IN INTEGER  -- Origem
                                    ,pr_vlsdeved IN NUMBER   -- Saldo devedor
                                    ,pr_vljura60 IN NUMBER   -- Juros 60 dias
                                    ,pr_vlpreemp IN NUMBER   -- Valor da prestacao
                                    ,pr_qtpreatr IN NUMBER   -- Qtd. Prestacoes
                                    ,pr_vlpreapg IN NUMBER   -- Valor a regularizar
                                    ,pr_vldespes IN NUMBER   -- Valor despesas
                                    ,pr_vlperris IN NUMBER   -- Valor percentual risco
                                    ,pr_nivrisat IN VARCHAR2 -- Risco atual
                                    ,pr_nivrisan IN VARCHAR2 -- Risco anterior
                                    ,pr_dtdrisan IN DATE     -- Data risco anterior
                                    ,pr_qtdiaris IN NUMBER   -- Quantidade dias risco
                                    ,pr_qtdiaatr IN NUMBER   -- Dias de atraso
                                    ,pr_flgrpeco IN NUMBER  -- Grupo Economico
                                    ,pr_flgresid IN NUMBER   -- Flag de residuo
                                    ,pr_qtprepag IN NUMBER   -- Prestacoes Pagas
                                    ,pr_txmensal IN NUMBER   -- Taxa mensal
                                    ,pr_txdiaria IN NUMBER   -- Taxa diaria
                                    ,pr_vlprepag IN NUMBER   -- Vlr. Prest. Pagas
                                    ,pr_qtmesdec IN NUMBER   -- Qtd. meses decorridos
                                    ,pr_dtdpagto IN DATE     -- Data de pagamento
                                    --Manutencao 201402 (Edison-AMcom)
                                    ,pr_dtmvtolt IN DATE     -- Identifica a data de criacao do reg. de cobranca na CYBER.
                                    ,pr_cdlcremp IN crapcyb.cdlcremp%TYPE --Codigo da linha de credito
                                    ,pr_cdfinemp IN crapcyb.cdfinemp%TYPE --Codigo da finalidade.
                                    ,pr_dtefetiv IN crapcyb.dtefetiv%TYPE --Data da efetivacao do emprestimo.
                                    ,pr_vlemprst IN crapcyb.vlemprst%TYPE --Valor emprestado.
                                    ,pr_qtpreemp IN crapcyb.qtpreemp%TYPE --Quantidade de prestacoes.
                                    ,pr_flgfolha IN crapcyb.flgfolha%TYPE --O pagamento e por Folha
                                    ,pr_flgpreju IN crapcyb.flgpreju%TYPE --Esta em prejuizo.
                                    ,pr_flgconsg IN crapcyb.flgconsg%TYPE --Indicador de valor consignado.
                                    ,pr_nrborder IN crapbdt.nrborder%TYPE DEFAULT NULL --> Numero do bordero do titulo em atraso no cyber
                                    ,pr_nrtitulo IN craptdb.nrtitulo%TYPE DEFAULT NULL --> Numero do titulo em atraso no cyber
                                    --Campos atualizar prejuizo (Vitor - GFT)
                                    ,pr_dtprejuz IN DATE DEFAULT NULL --> Numero do titulo em atraso no cyber
                                    ,pr_vlsdprej IN crapcyb.vlsdprej%TYPE DEFAULT 0 --> Numero do titulo em atraso no cyber
                                    ,pr_dtvencto IN crapcyb.dtvencto%TYPE DEFAULT NULL --> Data de vencimento do cartao
                                    ,pr_dscritic OUT VARCHAR2);


  /* Validar Os Dados do Contrato de Emprestimo */
  PROCEDURE pc_valida_dados (pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                            ,pr_cdagenci IN crapass.cdagenci%TYPE --> Código da agência
                            ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Número do caixa
                            ,pr_idorigem IN INTEGER               --> Id do módulo de sistema
                            ,pr_cddopcao IN VARCHAR2              --> Codigo opcao
                            ,pr_cdoperad IN crapdev.cdoperad%TYPE --> Código do Operador
                            ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Número da conta
                            ,pr_nrcpfcgc IN NUMBER                --> Numero Cpf/Cnpj
                            ,pr_tpidenti IN INTEGER               --> Tipo identificacao
                            ,pr_dtvencto IN DATE                  --> Data Vencimento
                            ,pr_dtinclus IN DATE                  --> Data Inclusao
                            ,pr_vldivida IN NUMBER                --> Valor da dívida
                            ,pr_tpinsttu IN INTEGER               --> Tipo Instrucao
                            ,pr_dtdbaixa IN DATE                  --> Data de Baixa
                            ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                            ,pr_dsinsttu OUT VARCHAR2             --> Descricao Instrucao
                            ,pr_operador OUT VARCHAR2             --> Nome operador
                            ,pr_des_reto OUT VARCHAR              --> Retorno OK / NOK
                            ,pr_tab_erro OUT gene0001.typ_tab_erro); --> Tabela com possíves erros

  /* Validar Os Dados do Contrato de Emprestimo */
  PROCEDURE pc_grava_dados  (pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                            ,pr_cdagenci IN crapass.cdagenci%TYPE --> Código da agência
                            ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Número do caixa
                            ,pr_idorigem IN INTEGER               --> Id do módulo de sistema
                            ,pr_nmdatela IN VARCHAR2              --> Nome da tela
                            ,pr_cdoperad IN crapdev.cdoperad%TYPE --> Código do Operador
                            ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data movimento
                            ,pr_cddopcao IN VARCHAR2              --> Codigo Opcao
                            ,pr_nrcpfcgc IN NUMBER                --> Numero Cpf/Cnpj
                            ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Número da conta
                            ,pr_tpidenti IN INTEGER               --> Tipo identificacao
                            ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Numero Contrato
                            ,pr_tpctrdev IN INTEGER               --> Tipo Contrato
                            ,pr_dtinclus IN DATE                  --> Data Inclusao
                            ,pr_nrctrspc IN VARCHAR2              --> Numero Contrato SPC
                            ,pr_dtvencto IN DATE                  --> Data Vencimento
                            ,pr_vldivida IN NUMBER                --> Valor da dívida
                            ,pr_tpinsttu IN INTEGER               --> Tipo Instrucao
                            ,pr_dsoberv1 IN VARCHAR2              --> Observacao 1
                            ,pr_dsoberv2 IN VARCHAR2              --> Observacao 2
                            ,pr_dtdbaixa IN DATE                  --> Data de Baixa
                            ,pr_nrctaavl IN INTEGER               --> Numero Conta Avalista 1
                            ,pr_nrdrowid IN ROWID                 --> ROWID da crapspc
                            ,pr_des_reto OUT VARCHAR              --> Retorno OK / NOK
                            ,pr_tab_erro OUT gene0001.typ_tab_erro); --> Tabela com possíves erros
  /* Melhoria 432 - envio de informações CYBER
     25/01/2017 - Criação da rotina de importação do arquivo de retorno CYBER. (Jean / Mout´S)
  */
  PROCEDURE pc_importa_arquivo_cyber(pr_dtmvto     IN DATE        --> Data de movimento
                                    ,pr_des_reto   OUT VARCHAR2   --> descrição do retorno ("OK" ou "NOK")
                                    ,pr_des_erro   out VARCHAR2); --> descrição do erro

  PROCEDURE pc_altera_dados_crapcyc(pr_cdcooper in     crapcop.cdcooper%type
                                   ,pr_cdagenci in     crapass.cdagenci%type
                                   ,pr_dtmvtolt in     varchar2
                                   ,pr_nrdcaixa in     crapbcx.nrdcaixa%type
                                   ,pr_cdoperad in     crapope.cdoperad%type
                                   ,pr_nmdatela in     craptel.nmdatela%type
                                   ,pr_idorigem in     number
                                   ,pr_nrdconta in     crapass.nrdconta%type
                                   ,pr_nrctremp in     crapepr.nrctremp%type
                                   ,pr_cdorigem in     crapcyc.cdorigem%type
                                   ,pr_flgjudic in     varchar2
                                   ,pr_flextjud in     varchar2
                                   ,pr_flgehvip in     varchar2
                                   ,pr_dtenvcbr in     varchar2
                                   ,pr_cdassess in     crapcyc.cdassess%type
                                   ,pr_cdmotcin in     crapcyc.cdmotcin%type
                                   ,pr_xmllog   IN     VARCHAR2 --> XML com informacoes de LOG
                                   ,pr_cdcritic    OUT PLS_INTEGER --> Codigo da critica
                                   ,pr_dscritic    OUT VARCHAR2 --> Descricao da critica
                                   ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                   ,pr_nmdcampo    OUT VARCHAR2 --> Nome do campo com erro
                                   ,pr_des_erro    OUT VARCHAR2);

END CYBE0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.CYBE0001 AS

  /*---------------------------------------------------------------------------------------------------------------

    Programa: CYBE0001                        Antiga: generico/procedures/b1wgen0168.p
    Autor   : James Prust Junior
    Data    : Agosto/2013                     Ultima Atualizacao: 05/06/2018
  
    Dados referentes ao programa:
  
    Objetivo  : Package referente a regras de geracao de arquivos CYBER
  
    Alteracoes: 30/09/2013 - Conversao Progress para oracle (Gabriel).
  
                04/10/2013 - Conversao Progress para oracle da rotina pc_atualiza_dados
                             ( Renato-Supero / Odirlei-AMcom )
  
                05/05/2014 - Removido o parametro dtatufin da procedure "pc_atualiza_dados_financeiro". (James)
  
                02/06/2014 - Os campos cdestcvl e vlsalari foram removidos da crapass e adicionados
                             na crapttl, portanto foram removidas as validações para crapass na 
                             "pc_proc_alteracoes_log". As validações já exitem para crapttl. 
                             (Douglas - Chamado 131253)
                10/06/2014 - (Chamado 117414) - Troca do campo crapass.nmconjug por crapcje.nmconjug
                             (Tiago Castro - RKAM).   
  
                22/09/2014 - Inserido o campo FLGFOLHA no UPDATE da procedure 
                             "pc_atualiza_dados_financeiro". (Jaison)
  
                08/12/2014 - #213746 Ajuste nas verificações das alterações dos dados de conjuge (Carlos)
  
                27/10/2015 - Incluido nova verificacao do campo crapass.indserma na procedure pc_proc_alteracoes_log,
                             Prj. 131 - Assinatura Conjunta. (Jean Michel).
  
                29/02/2016 - Trocando o campo flpolexp para inpolexp conforme
                             solicitado no chamado 402159 (Kelvin)
  
                26/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
                             crapass, crapttl, crapjur (Adriano - P339).

                05/06/2018 - Ajuste para adicionar Desconto de Titulos (Andrew Albuquerque - GFT)
                
                11/09/2018 - Ajuste para adicionar atualização de prejuizo (Vitor S Assanuma - GFT)

  ---------------------------------------------------------------------------------------------------------------*/

    --Tabela de Memoria com ROWID para log (usado no grava_dados)
    TYPE typ_tab_rowid IS TABLE OF ROWID INDEX BY VARCHAR2(7);

    --Tipo de Tabela para associado
    TYPE typ_tab_crapass IS TABLE OF crapass%ROWTYPE INDEX BY PLS_INTEGER;
    --Tipo de Tabela para titular
    TYPE typ_tab_crapttl IS TABLE OF crapttl%ROWTYPE INDEX BY PLS_INTEGER;
    --Tipo de Tabela para endereco
    TYPE typ_tab_crapenc IS TABLE OF crapenc%ROWTYPE INDEX BY PLS_INTEGER;
    --Tipo de Tabela para pessoa Juridica
    TYPE typ_tab_crapjur IS TABLE OF crapjur%ROWTYPE INDEX BY PLS_INTEGER;
    --Tipo de Tabela para telefone
    TYPE typ_tab_craptfc IS TABLE OF craptfc%ROWTYPE INDEX BY PLS_INTEGER;
    --Tipo de Tabela para controle emissao extrato
    TYPE typ_tab_crapcex IS TABLE OF crapcex%ROWTYPE INDEX BY PLS_INTEGER;
    --Tipo de Tabela para email
    TYPE typ_tab_crapcem IS TABLE OF crapcem%ROWTYPE INDEX BY PLS_INTEGER;
    --Tipo de Tabela para cadastro spc
    TYPE typ_tab_crapspc IS TABLE OF crapspc%ROWTYPE INDEX BY PLS_INTEGER;
    --Tipo de Tabela para alteracoes cadastro crapass
    TYPE typ_tab_crapalt IS TABLE OF crapalt%ROWTYPE INDEX BY PLS_INTEGER;
    --Tipo de Tabela para avalistas
    TYPE typ_tab_crapavt IS TABLE OF crapavt%ROWTYPE INDEX BY PLS_INTEGER;
    --Tipo de Tabela para responsavel legal
    TYPE typ_tab_crapcrl IS TABLE OF crapcrl%ROWTYPE INDEX BY PLS_INTEGER;
    --Tipo de Tabela para conjuge
    TYPE typ_tab_crapcje IS TABLE OF crapcje%ROWTYPE INDEX BY PLS_INTEGER;
    --Tipo de Tabela para dependentes
    TYPE typ_tab_crapdep IS TABLE OF crapdep%ROWTYPE INDEX BY PLS_INTEGER;
    --Tipo de Tabela para bens
    TYPE typ_tab_crapbem IS TABLE OF crapbem%ROWTYPE INDEX BY PLS_INTEGER;
    --Tipo de Tabela para dados financeiros pessoas juridicas
    TYPE typ_tab_crapjfn IS TABLE OF crapjfn%ROWTYPE INDEX BY PLS_INTEGER;

    --Tipo de Registro usado para LOG (sistema/generico/includes/b1wgenalog.i)
    TYPE typ_reg_log IS RECORD
      (crapass typ_tab_crapass
      ,crapttl typ_tab_crapttl
      ,crapenc typ_tab_crapenc
      ,crapjur typ_tab_crapjur
      ,craptfc typ_tab_craptfc
      ,crapcex typ_tab_crapcex
      ,crapcem typ_tab_crapcem
      ,crapspc typ_tab_crapspc
      ,crapalt typ_tab_crapalt
      ,crapavt typ_tab_crapavt
      ,crapcrl typ_tab_crapcrl
      ,crapcje typ_tab_crapcje
      ,crapdep typ_tab_crapdep
      ,crapbem typ_tab_crapbem
      ,crapjfn typ_tab_crapjfn);

    --Tipo de tabela usado para trazer os logs (sistema/generico/includes/b1wgenalog.i)
    TYPE typ_tab_log IS TABLE OF typ_reg_log INDEX BY VARCHAR2(7);

    --Selecionar cadastro spc
    CURSOR cr_crapspc (pr_cdcooper IN crapspc.cdcooper%TYPE
                      ,pr_nrdconta IN crapspc.nrdconta%TYPE
                      ,pr_nrcpfcgc IN crapspc.nrcpfcgc%TYPE
                      ,pr_tpidenti IN crapspc.tpidenti%TYPE) IS
      SELECT crapspc.rowid
            ,crapspc.dtdbaixa
            ,crapspc.dtinclus
      FROM crapspc
      WHERE crapspc.cdcooper = pr_cdcooper
      AND   crapspc.nrdconta = pr_nrdconta
      AND   crapspc.nrcpfcgc = pr_nrcpfcgc
      AND   crapspc.tpidenti = pr_tpidenti
      ORDER BY crapspc.progress_recid ASC;
    rw_crapspc cr_crapspc%ROWTYPE;

    --Selecionar SPC por rowid
    CURSOR cr_crapspc_rowid (pr_rowid IN ROWID) IS
      SELECT crapspc.rowid
            ,crapspc.dtinclus
            ,crapspc.dtdbaixa
      FROM crapspc
      WHERE crapspc.rowid = pr_rowid;
    rw_crapspc_rowid cr_crapspc_rowid%ROWTYPE;

    --Selecionar Operador
    CURSOR cr_crapope (pr_cdoperad IN crapope.cdoperad%TYPE
                      ,pr_cdcooper IN crapope.cdcooper%TYPE) IS
      SELECT crapope.nmoperad
            ,crapope.cdoperad
      FROM crapope
      WHERE upper(crapope.cdoperad) = upper(pr_cdoperad)
      AND   crapope.cdcooper = pr_cdcooper;
    rw_crapope cr_crapope%ROWTYPE;

    --Selecionar os dados da tabela de Associados
    CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE
                      ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT crapass.nrdconta
            ,crapass.cdsitdct
            ,crapass.cdagenci
            ,crapass.cdsitdtl
            ,crapass.nrcpfcgc
            ,crapass.inpessoa
            ,crapass.dtdsdspc
            ,crapass.nrdctitg
            ,crapass.flgctitg
            ,crapass.rowid
      FROM crapass crapass
      WHERE crapass.cdcooper = pr_cdcooper
      AND   crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    --Selecionar dados do conjuge para log
    CURSOR cr_crapcje_rowid (pr_cdcooper IN crapcop.cdcooper%TYPE
                            ,pr_nrdconta IN crapcje.nrdconta%TYPE) IS
      SELECT crapcje.nmconjug, crapcje.dtnasccj, crapcje.dsendcom, crapcje.rowid
      FROM  crapcje
      WHERE crapcje.cdcooper = pr_cdcooper
      AND   crapcje.nrdconta = pr_nrdconta
      AND   crapcje.idseqttl = 1;
    rw_crapcje_rowid cr_crapcje_rowid%ROWTYPE;


  -- Atualiza os dados conforme o cdorigem para geração de arquivos cyber
  PROCEDURE pc_atualiza_dados(pr_tbcrapcyb   IN typ_crapcyb           --> pl/table com os registros a serem atualizados
                             ,pr_cdorigem    IN crapcyb.cdorigem%type --> codigo da origem (1-conta, 2-Desconto, 3-Emprestimo)
                             ,pr_dscritic   OUT VARCHAR2)  IS         --> Descrição da critica


    -- ..........................................................................
    --
    --  Programa : pc_atualiza_dados            Antigo: sistema/generico/procedures/b1wgen0168.p/atualiza_conta
    --                                                                                           atualiza_desconto
    --                                                                                           atualiza_emprestimo
    --  Sistema  : Rotinas genericas para a criação da cyber
    --  Sigla    : CYBE
    --  Autor    : Renato/Odirlei(Supero/Amcom)
    --  Data     : Setembro/2013.                   Ultima atualizacao: 05/06/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Diario (Batch).
    --   Objetivo  : Criar registro ou atualizar informações na tabela crapcyb, conforme pl/temp table e cd origem passados por parametro
    --
    --   Alteracoes: 17/09/2013 - Conversao Progress para Oracle - Odirlei (AMcom)
    --
    --               05/06/2018 - Ajuste para adicionar Desconto de Titulos (Andrew Albuquerque - GFT)
    -- .............................................................................

    -- CURSORES
    -- Verificar se o registro a ser incluído já existe
    CURSOR cr_crapcyb(pr_cdcooper    crapcyb.cdcooper%TYPE

                     ,pr_cdorigem    crapcyb.cdorigem%TYPE
                     ,pr_nrdconta    crapcyb.nrdconta%TYPE
                     ,pr_nrctremp    crapcyb.nrctremp%TYPE) IS
      SELECT dtdbaixa
        FROM crapcyb
       WHERE crapcyb.cdcooper = pr_cdcooper
         AND crapcyb.cdorigem = pr_cdorigem
         AND crapcyb.nrdconta = pr_nrdconta
         AND crapcyb.nrctremp = pr_nrctremp;

    -- VARIÁVEIS
    vr_dtdbaixa     crapcyb.dtdbaixa%TYPE;
    ind             NUMBER;

  BEGIN

    --Validar cdorigem
    IF pr_cdorigem NOT IN (1,2,3,4) THEN --Nova Origem: 4 - Desconto de Título
      pr_dscritic := 'Código de origem invalido para a CYBE0001.pc_atualiza_dados';
    END IF;

    -- Se o registro de memória estiver vazio
    IF pr_tbcrapcyb.COUNT() = 0 THEN
      RETURN; -- Retorna sem efetuar nenhuma ação
    END IF;

    -- Percorre todos os registro enviados para a rotina e altera
    BEGIN
      FORALL ind IN INDICES OF pr_tbcrapcyb SAVE EXCEPTIONS
        UPDATE crapcyb
           SET crapcyb.dtdbaixa = NULL
             , crapcyb.dtmancad = pr_tbcrapcyb(ind).dtmvtolt
             , crapcyb.dtmanavl = pr_tbcrapcyb(ind).dtmvtolt
             , crapcyb.dtmangar = pr_tbcrapcyb(ind).dtmangar
             , crapcyb.dtdpagto = pr_tbcrapcyb(ind).dtdpagto
         WHERE crapcyb.dtdbaixa IS NOT NULL  -- Somente atualiza o registro caso foi baixado
           AND crapcyb.cdcooper = pr_tbcrapcyb(ind).cdcooper
           AND crapcyb.cdorigem = pr_cdorigem
           AND crapcyb.nrdconta = pr_tbcrapcyb(ind).nrdconta
           AND crapcyb.nrctremp = pr_tbcrapcyb(ind).nrctremp;
    EXCEPTION
      WHEN others THEN
        -- Gerar erro
        pr_dscritic := 'Erro ao alterar CRAPCYB(CYBE0001.PC_ATUALIZA_DADOS): '||
                       SQLERRM(-(SQL%BULK_EXCEPTIONS(1).ERROR_CODE));
        RETURN;
    END;

    -- Percorre todos os registro enviados para a rotina e insere
    -- vai ignorar caso o registro ja existir
    BEGIN
      FORALL ind IN INDICES OF pr_tbcrapcyb SAVE EXCEPTIONS
        INSERT INTO crapcyb(cdcooper
                           ,cdorigem
                           ,nrdconta
                           ,nrctremp
                           ,cdagenci
                           ,cdlcremp
                           ,cdfinemp
                           ,dtmvtolt
                           ,dtdbaixa
                           ,vlsdevan
                           ,vljura60
                           ,vlpreemp
                           ,qtpreatr
                           ,vlprapga
                           ,vlpreapg
                           ,vldespes
                           ,vlperris
                           ,nivrisat
                           ,nivrisan
                           ,dtdrisan
                           ,qtdiaris
                           ,qtdiaatr
                           ,flgrpeco
                           ,dtefetiv
                           ,vlemprst
                           ,qtpreemp
                           ,qtprepag
                           ,dtdpagto
                           ,txmensal
                           ,txdiaria
                           ,vlprepag
                           ,qtmesdec
                           ,dtprejuz
                           ,vlsdprej
                           ,flgjudic
                           ,flextjud
                           ,flgehvip
                           ,flgpreju
                           ,flgresid
                           ,flgconsg
                           ,dtmancad
                           ,dtmanavl
                           ,dtmangar
                           ,vlsdeved
                           ,flgfolha
                           ,vlsdprea
                           ,dtatufin)
                     VALUES(pr_tbcrapcyb(ind).cdcooper   -- cdcooper
                           ,pr_cdorigem                  -- cdorigem -- Fixo
                           ,pr_tbcrapcyb(ind).nrdconta   -- nrdconta
                           ,pr_tbcrapcyb(ind).nrctremp   -- nrctremp
                           ,pr_tbcrapcyb(ind).cdagenci   -- cdagenci
                           ,pr_tbcrapcyb(ind).cdlcremp   -- cdlcremp
                           ,pr_tbcrapcyb(ind).cdfinemp   -- cdfinemp
                           ,pr_tbcrapcyb(ind).dtmvtolt   -- dtmvtolt
                           ,pr_tbcrapcyb(ind).dtdbaixa   -- dtdbaixa
                           ,pr_tbcrapcyb(ind).vlsdevan   -- vlsdevan
                           ,pr_tbcrapcyb(ind).vljura60   -- vljura60
                           ,pr_tbcrapcyb(ind).vlpreemp   -- vlpreemp
                           ,pr_tbcrapcyb(ind).qtpreatr   -- qtpreatr
                           ,pr_tbcrapcyb(ind).vlprapga   -- vlprapga
                           ,pr_tbcrapcyb(ind).vlpreapg   -- vlpreapg
                           ,pr_tbcrapcyb(ind).vldespes   -- vldespes
                           ,pr_tbcrapcyb(ind).vlperris   -- vlperris
                           ,pr_tbcrapcyb(ind).nivrisat   -- nivrisat
                           ,pr_tbcrapcyb(ind).nivrisan   -- nivrisan
                           ,pr_tbcrapcyb(ind).dtdrisan   -- dtdrisan
                           ,pr_tbcrapcyb(ind).qtdiaris   -- qtdiaris
                           ,pr_tbcrapcyb(ind).qtdiaatr   -- qtdiaatr
                           ,pr_tbcrapcyb(ind).flgrpeco   -- flgrpeco
                           ,pr_tbcrapcyb(ind).dtefetiv   -- dtefetiv
                           ,pr_tbcrapcyb(ind).vlemprst   -- vlemprst
                           ,pr_tbcrapcyb(ind).qtpreemp   -- qtpreemp
                           ,pr_tbcrapcyb(ind).qtprepag   -- qtprepag
                           ,pr_tbcrapcyb(ind).dtdpagto   -- dtdpagto
                           ,pr_tbcrapcyb(ind).txmensal   -- txmensal
                           ,pr_tbcrapcyb(ind).txdiaria   -- txdiaria
                           ,pr_tbcrapcyb(ind).vlprepag   -- vlprepag
                           ,pr_tbcrapcyb(ind).qtmesdec   -- qtmesdec
                           ,pr_tbcrapcyb(ind).dtprejuz   -- dtprejuz
                           ,pr_tbcrapcyb(ind).vlsdprej   -- vlsdprej
                           ,pr_tbcrapcyb(ind).flgjudic   -- flgjudic
                           ,pr_tbcrapcyb(ind).flextjud   -- flextjud
                           ,pr_tbcrapcyb(ind).flgehvip   -- flgehvip
                           ,pr_tbcrapcyb(ind).flgpreju   -- flgpreju
                           ,pr_tbcrapcyb(ind).flgresid   -- flgresid
                           ,pr_tbcrapcyb(ind).flgconsg   -- flgconsg
                           ,pr_tbcrapcyb(ind).dtmancad   -- dtmancad
                           ,pr_tbcrapcyb(ind).dtmanavl   -- dtmanavl
                           ,pr_tbcrapcyb(ind).dtmangar   -- dtmangar
                           ,pr_tbcrapcyb(ind).vlsdeved   -- vlsdeved
                           ,pr_tbcrapcyb(ind).flgfolha   -- flgfolha
                           ,pr_tbcrapcyb(ind).vlsdprea   -- vlsdprea
                           ,pr_tbcrapcyb(ind).dtatufin); -- dtatufin
    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        NULL;
      WHEN others THEN
        -- Gerar erro
        FOR i IN 1 ..SQL%BULK_EXCEPTIONS.count LOOP
          --Somente apresentar a mensagem se o erro for diferente de ORA-00001
          --(ORA-00001: unique constraint (.) violated)
          IF SQL%BULK_EXCEPTIONS(1).ERROR_CODE <> 1 THEN
            pr_dscritic := 'Erro ao inserir CRAPCYB(CYBE0001.PC_ATUALIZA_DADOS): '||
                            SQLERRM(-(SQL%BULK_EXCEPTIONS(1).ERROR_CODE));
            RETURN;
          END IF;
        END LOOP;
    END;
  END pc_atualiza_dados;

 -- Procedure para atualizar os dados do CYBER (Emprestimo,desconto e conta)
  PROCEDURE pc_atualiza_dados_financeiro
                                    (pr_cdcooper IN INTEGER      -- Codigo da Cooperativa
                                    ,pr_nrdconta IN INTEGER      -- Numero da conta
                                    ,pr_nrctremp IN INTEGER      -- Numero do contrato
                                    ,pr_cdorigem IN INTEGER      -- Origem
                                    ,pr_vlsdeved IN NUMBER       -- Saldo devedor
                                    ,pr_vljura60 IN NUMBER       -- Juros 60 dias
                                    ,pr_vlpreemp IN NUMBER       -- Valor da prestacao
                                    ,pr_qtpreatr IN NUMBER       -- Qtd. Prestacoes
                                    ,pr_vlpreapg IN NUMBER       -- Valor a regularizar
                                    ,pr_vldespes IN NUMBER       -- Valor despesas
                                    ,pr_vlperris IN NUMBER       -- Valor percentual risco
                                    ,pr_nivrisat IN VARCHAR2     -- Risco atual
                                    ,pr_nivrisan IN VARCHAR2     -- Risco anterior
                                    ,pr_dtdrisan IN DATE         -- Data risco anterior
                                    ,pr_qtdiaris IN NUMBER       -- Quantidade dias risco
                                    ,pr_qtdiaatr IN NUMBER       -- Dias de atraso
                                    ,pr_flgrpeco IN NUMBER       -- Grupo Economico
                                    ,pr_flgresid IN NUMBER       -- Flag de residuo
                                    ,pr_qtprepag IN NUMBER       -- Prestacoes Pagas
                                    ,pr_txmensal IN NUMBER       -- Taxa mensal
                                    ,pr_txdiaria IN NUMBER       -- Taxa diaria
                                    ,pr_vlprepag IN NUMBER       -- Vlr. Prest. Pagas
                                    ,pr_qtmesdec IN NUMBER       -- Qtd. meses decorridos
                                    ,pr_dtdpagto IN DATE         -- Data de pagamento
                                    --Manutencao 201402 (Edison-AMcom)
                                    ,pr_dtmvtolt IN DATE         -- Identifica a data de criacao do reg. de cobranca na CYBER.
                                    ,pr_cdlcremp IN crapcyb.cdlcremp%TYPE --Codigo da linha de credito
                                    ,pr_cdfinemp IN crapcyb.cdfinemp%TYPE --Codigo da finalidade.
                                    ,pr_dtefetiv IN crapcyb.dtefetiv%TYPE --Data da efetivacao do emprestimo.
                                    ,pr_vlemprst IN crapcyb.vlemprst%TYPE --Valor emprestado.
                                    ,pr_qtpreemp IN crapcyb.qtpreemp%TYPE --Quantidade de prestacoes.
                                    ,pr_flgfolha IN crapcyb.flgfolha%TYPE --O pagamento e por Folha
                                    ,pr_flgpreju IN crapcyb.flgpreju%TYPE --Esta em prejuizo.
                                    ,pr_flgconsg IN crapcyb.flgconsg%TYPE --Indicador de valor consignado.
                                    ,pr_nrborder IN crapbdt.nrborder%TYPE DEFAULT NULL --> Numero do bordero do titulo em atraso no cyber
                                    ,pr_nrtitulo IN craptdb.nrtitulo%TYPE DEFAULT NULL --> Numero do titulo em atraso no cyber
                                    --Campos atualizar prejuizo (Vitor - GFT)
                                    ,pr_dtprejuz IN DATE                  DEFAULT NULL --> Data do prejuizo
                                    ,pr_vlsdprej IN crapcyb.vlsdprej%TYPE DEFAULT 0    --> Valor do prejuizo
                                    ,pr_dtvencto IN crapcyb.dtvencto%TYPE DEFAULT NULL --> Data de vencimento do cartao
                                    ,pr_dscritic OUT VARCHAR2) AS

    -- ........................................................................
    --
    --  Programa : pc_atualiza_dados_financeiro        Antigo: b1wgen0168.p/atualiza_dados_financeiro
    --  Sistema  : Cred
    --  Sigla    : CYBE0001
    --  Autor    : James Prust Junior
    --  Data     : Agosto/2013.                   Ultima atualizacao: 05/06/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Atualizar os contratos em cobranca do CYBER.
    --
    --   Atualizacao: 01/10/2013 - Conversao Progress => Oracle (Gabriel)
    --
    --                17/12/2013 - Atualizar o campo tt-crapcyb.dtdpagto dos contratos
    --                             de emprestimos que estão no Cyber. (Gabriel)
    --
    --                16/01/2014 - Ajuste na procedure "atualiza_dados_financeiro"
    --                             para atualizar a data de pagamento (Gabriel).
    --
    --                07/03/2014 - Manutenção 201402. Adicionadas novas colunas no insert
    --                             e update da tabela crapcyb  (Edison-Amcom)
    --
    --                05/05/2014 - Ajuste na validação dos dados. (James)
    --
    --                05/06/2018 - Ajuste para adicionar Desconto de Titulos (Andrew Albuquerque - GFT)
    --
    --                05/06/2018 - Adicionado a procedure pc_inserir_titulo_cyber (Paulo Penteado (GFT)) 
    --
    --                06/09/2018 - Adicionar campos de Prejuizo (Vitor S Assanuma - GFT)
    -- ...................................................................................................
  BEGIN
    DECLARE

      vr_flgjudic NUMBER; -- Informa se esta em processo judicial
      vr_flextjud NUMBER; -- Informa se exta extra judicial
      vr_flgehvip NUMBER; -- Pertence a VIP
      vr_dtdpagto DATE;
      vr_dtatufin DATE;
      vr_vlprapga crapcyb.vlprapga%TYPE;
      vr_nrctremp crapcyb.nrctremp%TYPE;
      vr_vlsdeved NUMBER;
      vr_vlpreapg NUMBER;
      

      --Variaveis De Erro
      vr_dscritic VARCHAR2(4000);

      --Variaveis Excecao
      vr_exc_erro EXCEPTION;

      -- Cursor contendo contratos no sistema CYBER
      CURSOR cr_crapcyb (pr_cdcooper IN crapcyb.cdcooper%TYPE
                        ,pr_cdorigem IN crapcyb.cdorigem%TYPE
                        ,pr_nrdconta IN crapcyb.nrdconta%TYPE
                        ,pr_nrctremp IN crapcyb.nrctremp%TYPE) IS
        SELECT crapcyb.flgjudic
              ,crapcyb.flextjud
              ,crapcyb.flgehvip
              ,crapcyb.dtdbaixa
              ,crapcyb.dtmvtolt
              ,crapcyb.vlsdeved
              ,crapcyb.dtdpagto
              ,crapcyb.vlpreapg
              ,crapcyb.rowid
          FROM crapcyb crapcyb
         WHERE crapcyb.cdcooper = pr_cdcooper
           AND crapcyb.nrdconta = pr_nrdconta
           AND crapcyb.cdorigem = pr_cdorigem
           AND crapcyb.nrctremp = pr_nrctremp;
      rw_crapcyb cr_crapcyb%ROWTYPE;

    BEGIN
      vr_nrctremp := pr_nrctremp;
      vr_vlsdeved := pr_vlsdeved;
      vr_vlpreapg := pr_vlpreapg;
      
      -- Se o borderô de desconto de títulos estiver em prejuizo, zerar o valor de saldo a pagar
      IF pr_flgpreju = 1 AND pr_cdorigem = 4 THEN
        vr_vlsdeved := 0;
        vr_vlpreapg := 0;
      END IF;
      
      -- Abrir cursor com os contrato do Cyber
      OPEN cr_crapcyb (pr_cdcooper => pr_cdcooper
                      ,pr_cdorigem => pr_cdorigem
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_nrctremp => vr_nrctremp);
      FETCH cr_crapcyb INTO rw_crapcyb;
      -- Se nao achar o contrato
      IF cr_crapcyb%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcyb;

        --Se valor a pagar ou o de prejuizo for maior zero
        IF (nvl(vr_vlpreapg,0) > 0) OR (nvl(pr_vlsdprej, 0) > 0) THEN
          -- Desconto de Titulos
          IF  pr_cdorigem = 4 THEN
              cybe0003.pc_inserir_titulo_cyber(pr_cdcooper => pr_cdcooper
                                              ,pr_nrdconta => pr_nrdconta
                                              ,pr_nrborder => pr_nrborder
                                              ,pr_nrtitulo => pr_nrtitulo
                                              ,pr_nrctrdsc => vr_nrctremp
                                              ,pr_dscritic => vr_dscritic);
              IF  TRIM(vr_dscritic) IS NOT NULL THEN
                  RAISE vr_exc_erro;
              END IF;
          END IF;               

          --Inserir Registro Cyber
          BEGIN
            INSERT INTO crapcyb cyb
              (/*01*/ cyb.cdcooper
              ,/*02*/ cyb.cdorigem
              ,/*03*/ cyb.nrdconta
              ,/*04*/ cyb.nrctremp
              ,/*05*/ cyb.flgjudic
              ,/*06*/ cyb.flextjud
              ,/*07*/ cyb.flgehvip
              ,/*08*/ cyb.vlsdevan
              ,/*09*/ cyb.vlsdeved
              ,/*10*/ cyb.vljura60
              ,/*11*/ cyb.vlpreemp
              ,/*12*/ cyb.qtpreatr
              ,/*13*/ cyb.vlprapga
              ,/*14*/ cyb.vlpreapg
              ,/*15*/ cyb.vldespes
              ,/*16*/ cyb.vlperris
              ,/*17*/ cyb.nivrisat
              ,/*18*/ cyb.nivrisan
              ,/*19*/ cyb.dtdrisan
              ,/*20*/ cyb.qtdiaris
              ,/*21*/ cyb.qtdiaatr
              ,/*22*/ cyb.flgrpeco
              ,/*23*/ cyb.qtprepag
              ,/*24*/ cyb.txmensal
              ,/*25*/ cyb.txdiaria
              ,/*26*/ cyb.vlprepag
              ,/*27*/ cyb.qtmesdec
              ,/*28*/ cyb.flgresid
              ,/*29*/ cyb.dtatufin
              ,/*30*/ cyb.dtdpagto
              --Manutencao 201402 (Edison-AMcom)
              ,/*31*/ cyb.dtmvtolt -- Identifica a data de criacao do reg. de cobranca na CYBER.
              ,/*32*/ cyb.cdlcremp --Codigo da linha de credito
              ,/*33*/ cyb.cdfinemp --Codigo da finalidade.
              ,/*34*/ cyb.dtefetiv --Data da efetivacao do emprestimo.
              ,/*35*/ cyb.vlemprst --Valor emprestado.
              ,/*36*/ cyb.qtpreemp --Quantidade de prestacoes.
              ,/*37*/ cyb.flgfolha --O pagamento e por Folha
              ,/*38*/ cyb.flgpreju --Esta em prejuizo.
              ,/*39*/ cyb.flgconsg --Indicador de valor consignado.
              ,/*40*/ cyb.dtprejuz --Data que entrou em prejuizo
              ,/*41*/ cyb.vlsdprej --Valor do prejuizo
              ,/*42*/ cyb.dtvencto --Data vencimento do cartao
              )
            VALUES
              (/*01*/ pr_cdcooper
              ,/*02*/ pr_cdorigem
              ,/*03*/ pr_nrdconta
              ,/*04*/ vr_nrctremp
              ,/*05*/ nvl(vr_flgjudic,0)
              ,/*06*/ nvl(vr_flextjud,0)
              ,/*07*/ nvl(vr_flgehvip,0)
              ,/*08*/ 0
              ,/*09*/ nvl(vr_vlsdeved,0)
              ,/*10*/ nvl(pr_vljura60,0)
              ,/*11*/ nvl(pr_vlpreemp,0)
              ,/*12*/ nvl(pr_qtpreatr,0)
              ,/*13*/ 0
              ,/*14*/ nvl(vr_vlpreapg,0)
              ,/*15*/ nvl(pr_vldespes,0)
              ,/*16*/ nvl(pr_vlperris,0)
              ,/*17*/ pr_nivrisat
              ,/*18*/ pr_nivrisan
              ,/*19*/ pr_dtdrisan
              ,/*20*/ pr_qtdiaris
              ,/*21*/ pr_qtdiaatr
              ,/*22*/ nvl(pr_flgrpeco,0)
              ,/*23*/ pr_qtprepag
              ,/*24*/ nvl(pr_txmensal,0)
              ,/*25*/ nvl(pr_txdiaria,0)
              ,/*26*/ nvl(pr_vlprepag,0)
              ,/*27*/ nvl(pr_qtmesdec,0)
              ,/*28*/ nvl(pr_flgresid,0)
              ,/*29*/ pr_dtmvtolt
              ,/*30*/ pr_dtdpagto
              --Manutencao 201402 (Edison-AMcom)
              ,/*31*/ pr_dtmvtolt -- Identifica a data de criacao do reg. de cobranca na CYBER.
              ,/*32*/ pr_cdlcremp --Codigo da linha de credito
              ,/*33*/ pr_cdfinemp --Codigo da finalidade.
              ,/*34*/ pr_dtefetiv --Data da efetivacao do emprestimo.
              ,/*35*/ nvl(pr_vlemprst,0) --Valor emprestado.
              ,/*36*/ nvl(pr_qtpreemp,0) --Quantidade de prestacoes.
              ,/*37*/ nvl(pr_flgfolha,0) --O pagamento e por Folha
              ,/*38*/ nvl(pr_flgpreju,0) --Esta em prejuizo.
              ,/*39*/ nvl(pr_flgconsg,0) --Indicador de valor consignado.
              --Inserção das atualizações de Prejuzio (Vitor - GFT)
              ,/*40*/ pr_dtprejuz -- Data em que entrou em prejuizo
              ,/*41*/ pr_vlsdprej -- Valor do prejuizo
              ,/*42*/ pr_dtvencto -- Data de vencimento do cartao
              );

          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir CRAPCYB(CYBE0001.pc_atualiza_dados_financeiro ): '||SQLERRM;
              --Levantar Excecao
              RAISE vr_exc_erro;
          END;
        END IF;
      ELSE
        --Fechar Cursor
        CLOSE cr_crapcyb;

        /* Caso jah estiver baixado, vamos reativar */
        IF rw_crapcyb.dtdbaixa IS NOT NULL AND nvl(vr_vlpreapg,0) > 0 THEN
          --Atualizar Dados Cyber
          BEGIN
            UPDATE crapcyb SET crapcyb.dtdbaixa = NULL
                              ,crapcyb.dtmancad = pr_dtmvtolt
                              ,crapcyb.dtmanavl = pr_dtmvtolt
                              ,crapcyb.dtmangar = pr_dtmvtolt
                              ,crapcyb.dtdpagto = pr_dtdpagto
            WHERE crapcyb.rowid = rw_crapcyb.rowid
                  RETURNING dtdbaixa
                           ,dtdpagto
                       INTO rw_crapcyb.dtdbaixa
                           ,rw_crapcyb.dtdpagto;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic:= 'Erro ao atualizar crapcyb. '||SQLERRM;
              --Levantar Excecao
              RAISE vr_exc_erro;
          END;
        END IF;

        --Data do Moveimento
        IF rw_crapcyb.dtmvtolt = pr_dtmvtolt AND nvl(vr_vlpreapg,0) = 0 THEN
          vr_dtatufin := NULL;
        ELSE
          vr_dtatufin := pr_dtmvtolt;
        END IF;

        -- [Projeto 403] Incluso tratamento para desconto de títulos
        IF pr_cdorigem IN (2,3,4) THEN
          vr_dtdpagto := pr_dtdpagto;
        ELSE
          vr_dtdpagto := rw_crapcyb.dtdpagto;
        END IF;

        BEGIN
          --Data de Baixa Nula
          IF rw_crapcyb.dtdbaixa IS NULL THEN
            -- Atualizar contratos que estao em cobrança no CYBER
            UPDATE crapcyb cyb
              SET cyb.vlsdevan = nvl(rw_crapcyb.vlsdeved,0)
                 ,cyb.vlsdeved = nvl(vr_vlsdeved,0) -- Saldo Devedor
                 ,cyb.vljura60 = nvl(pr_vljura60,0)
                 ,cyb.vlpreemp = nvl(pr_vlpreemp,0)
                 ,cyb.qtpreatr = nvl(pr_qtpreatr,0)
                 ,cyb.vlprapga = nvl(rw_crapcyb.vlpreapg,0)
                 ,cyb.vlpreapg = nvl(vr_vlpreapg,0) -- Valor total do Atraso
                 ,cyb.vldespes = nvl(pr_vldespes,0)
                 ,cyb.vlperris = nvl(pr_vlperris,0)
                 ,cyb.nivrisat = pr_nivrisat
                 ,cyb.nivrisan = pr_nivrisan
                 ,cyb.dtdrisan = pr_dtdrisan
                 ,cyb.qtdiaris = nvl(pr_qtdiaris,0)
                 ,cyb.qtdiaatr = nvl(pr_qtdiaatr,0)
                 ,cyb.flgrpeco = nvl(pr_flgrpeco,0)
                 ,cyb.qtprepag = nvl(pr_qtprepag,0)
                 ,cyb.txmensal = nvl(pr_txmensal,0)
                 ,cyb.txdiaria = nvl(pr_txdiaria,0)
                 ,cyb.vlprepag = nvl(pr_vlprepag,0)
                 ,cyb.qtmesdec = nvl(pr_qtmesdec,0)
                 ,cyb.flgresid = nvl(pr_flgresid,0)
                 ,cyb.dtatufin = vr_dtatufin
                 ,cyb.dtdpagto = vr_dtdpagto
                 ,cyb.flgfolha = nvl(pr_flgfolha,0)
                 ,cyb.flgpreju = nvl(pr_flgpreju,0) -- Flag de Prejuizo
                 ,cyb.dtprejuz = pr_dtprejuz        -- Data em que entrou em prejuizo
                 ,cyb.vlsdprej = pr_vlsdprej        -- Valor do prejuizo
            WHERE cyb.rowid = rw_crapcyb.rowid;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar CRAPCYB(CYBE0001.pc_atualiza_dados_financeiro ): '||SQLERRM;
            --Levantar Excecao
            RAISE vr_exc_erro;
        END;
      END IF;

    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro na rotina CYBE0001.pc_atualiza_dados_financeiro: '||SQLERRM;
    END;
  END pc_atualiza_dados_financeiro;

  --Validar Alteracao Inclusao
  PROCEDURE pc_valida_alteracao_inclusao  (pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                          ,pr_cdagenci IN crapass.cdagenci%TYPE --> Código da agência
                                          ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Número do caixa
                                          ,pr_idorigem IN INTEGER               --> Id do módulo de sistema
                                          ,pr_cdoperad IN crapdev.cdoperad%TYPE --> Código do Operador
                                          ,pr_cddopcao IN VARCHAR2              --> Codigo opcao
                                          ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Número da conta
                                          ,pr_nrcpfcgc IN NUMBER                --> Numero Cpf/Cnpj
                                          ,pr_tpidenti IN INTEGER               --> Tipo identificacao
                                          ,pr_dtvencto IN DATE                  --> Data Vencimento
                                          ,pr_dtinclus IN DATE                  --> Data Inclusao
                                          ,pr_vldivida IN NUMBER                --> Valor da dívida
                                          ,pr_tpinsttu IN INTEGER               --> Tipo Instrucao
                                          ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                                          ,pr_dsinsttu OUT VARCHAR2             --> Descricao Instrucao
                                          ,pr_operador OUT VARCHAR2             --> Nome operador
                                          ,pr_des_reto OUT VARCHAR              --> Retorno OK / NOK
                                          ,pr_tab_erro OUT gene0001.typ_tab_erro) IS --> Tabela com possíves erros
  BEGIN
    /* .............................................................................

     Programa: pc_valida_dados                       Antigo: b1wgen0133.p/valida_alteracao_inclusao
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Alisson
     Data    : Marco/2014                        Ultima atualizacao: 11/03/2014

     Dados referentes ao programa:

     Frequencia: Diaria - Sempre que for chamada
     Objetivo  : Rotina para Validar a inclusao/alteracao no cadastro SPC

     Alteracoes: 11/03/2014 - Conversão Progress para Oracle (Alisson - AMcom)

  ............................................................................. */

      DECLARE

        --Variaveis Locais
        vr_dstransa VARCHAR2(100);
        vr_dsorigem VARCHAR2(100);
        vr_nrdrowid ROWID;
        vr_flgtrans BOOLEAN;
        vr_cdhistor craphis.cdhistor%TYPE;
        vr_nrdolote craplot.nrdolote%TYPE;

        --Variaveis Erro
        vr_cdcritic INTEGER;
        vr_des_erro VARCHAR2(3);
        vr_dscritic VARCHAR2(4000);

        --Variaveis Excecao
        vr_exc_erro  EXCEPTION;
        vr_exc_saida EXCEPTION;

      BEGIN
        --Inicializar variavel erro
        pr_des_reto:= 'OK';

        --Marcar que nao ocorreu erro
        vr_cdcritic:= 0;
        vr_dscritic:= NULL;

        --Limpar tabela erros
        pr_tab_erro.DELETE;

        BEGIN
          --Criar savepoint para desfazer transacao
          SAVEPOINT save_trans;
          --Se nao for Inclusao
          IF pr_cddopcao = 'A' THEN
            --Selecionar cadastro spc
            OPEN cr_crapspc (pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrcpfcgc => pr_nrcpfcgc
                            ,pr_tpidenti => pr_tpidenti);
            FETCH cr_crapspc INTO rw_crapspc;
            --Se nao encontrou
            IF cr_crapspc%NOTFOUND THEN
              --Fechar Cursor
              CLOSE cr_crapspc;
              vr_cdcritic:= 870;
              --Sair
              RAISE vr_exc_saida;
            END IF;
            --Fechar Cursor
            CLOSE cr_crapspc;
          END IF;
          --verificar Parametros
          IF pr_dtvencto IS NULL THEN
            vr_cdcritic:= 375;
            pr_nmdcampo:= 'dtvencto';
            --Sair
            RAISE vr_exc_saida;
          ELSIF nvl(pr_vldivida,0) = 0 THEN
            vr_cdcritic:= 375;
            pr_nmdcampo:= 'vldivida';
            --Sair
            RAISE vr_exc_saida;
          ELSIF pr_dtinclus IS NULL THEN
            vr_cdcritic:= 375;
            pr_nmdcampo:= 'dtinclus';
            --Sair
            RAISE vr_exc_saida;
          ELSIF pr_tpinsttu NOT IN (1,2) THEN
            vr_cdcritic:= 14;
            pr_nmdcampo:= 'tpinsttu';
            --Sair
            RAISE vr_exc_saida;
          END IF;
          --Tipo Instituicao
          IF pr_tpinsttu = 1 THEN
            pr_dsinsttu:= 'SPC';
          ELSE
            pr_dsinsttu:= 'SERASA';
          END IF;
          --Alteracao
          IF pr_cddopcao = 'A' THEN
            --Data Inclusao diferente cadastro
            IF pr_dtinclus <> rw_crapspc.dtinclus THEN
              --Selecionar Operador
              OPEN cr_crapope (pr_cdoperad => pr_cdoperad
                              ,pr_cdcooper => pr_cdcooper);
              FETCH cr_crapope INTO rw_crapope;
              --Se encontrou
              IF cr_crapope%FOUND THEN
                --Codigo Operador
                pr_operador:= rw_crapope.cdoperad ||'-'||rw_crapope.nmoperad;
              END IF;
              --Fechar Cursor
              CLOSE cr_crapope;
            END IF;
          END IF;
        EXCEPTION
          WHEN vr_exc_saida THEN
            ROLLBACK TO save_trans;
        END;
        --Se ocorreu erro
        IF vr_dscritic IS NOT NULL OR vr_cdcritic <> 0 THEN
          -- Retorno não OK
          pr_des_reto := 'NOK';
          --Se tem erro na tabela
          IF pr_tab_erro.count = 0 THEN
            -- Gerar rotina de gravação de erro
            gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                 ,pr_cdagenci => pr_cdagenci
                                 ,pr_nrdcaixa => pr_nrdcaixa
                                 ,pr_nrsequen => 1 --> Fixo
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic
                                 ,pr_tab_erro => pr_tab_erro);
          END IF;
        ELSE
          -- Retorno OK
          pr_des_reto:= 'OK';
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          -- Retorno não OK
          pr_des_reto := 'NOK';
          -- Montar descrição de erro não tratado
          vr_dscritic := 'Erro não tratado na CYBE0001.pc_valida_dados '||sqlerrm;
          -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 --> Fixo
                               ,pr_cdcritic => 0
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
      END;
  END pc_valida_alteracao_inclusao;

  /* Validar Os Dados do Contrato de Emprestimo */
  PROCEDURE pc_valida_dados (pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                            ,pr_cdagenci IN crapass.cdagenci%TYPE --> Código da agência
                            ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Número do caixa
                            ,pr_idorigem IN INTEGER               --> Id do módulo de sistema
                            ,pr_cddopcao IN VARCHAR2              --> Codigo opcao
                            ,pr_cdoperad IN crapdev.cdoperad%TYPE --> Código do Operador
                            ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Número da conta
                            ,pr_nrcpfcgc IN NUMBER                --> Numero Cpf/Cnpj
                            ,pr_tpidenti IN INTEGER               --> Tipo identificacao
                            ,pr_dtvencto IN DATE                  --> Data Vencimento
                            ,pr_dtinclus IN DATE                  --> Data Inclusao
                            ,pr_vldivida IN NUMBER                --> Valor da dívida
                            ,pr_tpinsttu IN INTEGER               --> Tipo Instrucao
                            ,pr_dtdbaixa IN DATE                  --> Data de Baixa
                            ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                            ,pr_dsinsttu OUT VARCHAR2             --> Descricao Instrucao
                            ,pr_operador OUT VARCHAR2             --> Nome operador
                            ,pr_des_reto OUT VARCHAR              --> Retorno OK / NOK
                            ,pr_tab_erro OUT gene0001.typ_tab_erro) IS --> Tabela com possíves erros
    BEGIN
    /* .............................................................................

     Programa: pc_valida_dados                       Antigo: b1wgen0133.p/valida_dados
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Alisson
     Data    : Fevereiro/2014                        Ultima atualizacao: 10/03/2014

     Dados referentes ao programa:

     Frequencia: Diaria - Sempre que for chamada
     Objetivo  : Rotina para Validar os dados do contrato de emprestimo

     Alteracoes: 10/03/2014 - Conversão Progress para Oracle (Alisson - AMcom)

  ............................................................................. */

      DECLARE


        --Variaveis Locais
        vr_dsinsttu VARCHAR2(100);
        vr_operador VARCHAR2(100);
        vr_nrdrowid ROWID;
        vr_flgtrans BOOLEAN;
        vr_cdhistor craphis.cdhistor%TYPE;
        vr_nrdolote craplot.nrdolote%TYPE;

        --Variaveis Erro
        vr_cdcritic INTEGER;
        vr_des_erro VARCHAR2(3);
        vr_dscritic VARCHAR2(4000);

        --Variaveis Excecao
        vr_exc_erro  EXCEPTION;
        vr_exc_saida EXCEPTION;

      BEGIN
        --Inicializar variavel erro
        pr_des_reto:= 'OK';
        --Marcar que nao ocorreu erro
        vr_cdcritic:= 0;
        vr_dscritic:= NULL;

        --Limpar tabela erros
        pr_tab_erro.DELETE;

        BEGIN
          --Criar savepoint para desfazer transacao
          SAVEPOINT save_trans;
          --Se nao for Inclusao
          IF pr_cddopcao <> 'I' THEN
            --Selecionar cadastro spc
            OPEN cr_crapspc (pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrcpfcgc => pr_nrcpfcgc
                            ,pr_tpidenti => pr_tpidenti);
            FETCH cr_crapspc INTO rw_crapspc;
            --Se nao encontrou
            IF cr_crapspc%NOTFOUND THEN
              --Fechar Cursor
              CLOSE cr_crapspc;
              vr_cdcritic:= 870;
              --Sair
              RAISE vr_exc_saida;
            END IF;
            --Fechar Cursor
            CLOSE cr_crapspc;
          END IF;
          --Alteracao ou Inclusao
          IF pr_cddopcao IN ('A','I') THEN
            --Validar Alteracao Inclusao
            pc_valida_alteracao_inclusao  (pr_cdcooper => pr_cdcooper     --> Cooperativa conectada
                                          ,pr_cdagenci => pr_cdagenci     --> Código da agência
                                          ,pr_nrdcaixa => pr_nrdcaixa     --> Número do caixa
                                          ,pr_idorigem => pr_idorigem     --> Id do módulo de sistema
                                          ,pr_cdoperad => pr_cdoperad     --> Operador
                                          ,pr_cddopcao => pr_cddopcao     --> Codigo opcao
                                          ,pr_nrdconta => pr_nrdconta     --> Número da conta
                                          ,pr_nrcpfcgc => pr_nrcpfcgc     --> Numero Cpf/Cnpj
                                          ,pr_tpidenti => pr_tpidenti     --> Tipo identificacao
                                          ,pr_dtvencto => pr_dtvencto     --> Data Vencimento
                                          ,pr_dtinclus => pr_dtinclus     --> Data Inclusao
                                          ,pr_vldivida => pr_vldivida     --> Valor da dívida
                                          ,pr_tpinsttu => pr_tpinsttu     --> Tipo Instrucao
                                          ,pr_nmdcampo => pr_nmdcampo     --> Nome do Campo
                                          ,pr_dsinsttu => pr_dsinsttu     --> Descricao Instrucao
                                          ,pr_operador => pr_operador     --> Nome operador
                                          ,pr_des_reto => vr_des_erro     --> Retorno OK / NOK
                                          ,pr_tab_erro => pr_tab_erro);   --> Tabela com possíves erros
            --Se ocorreu erro
            IF vr_des_erro <> 'OK' THEN
              --Sair
              RAISE vr_exc_saida;
            END IF;
          ELSIF pr_cddopcao = 'B' THEN
            --Data de Baixa diferente do cadastro
            IF  pr_dtdbaixa <> rw_crapspc.dtdbaixa THEN
              --Selecionar Operador
              OPEN cr_crapope (pr_cdoperad => pr_cdoperad
                              ,pr_cdcooper => pr_cdcooper);
              FETCH cr_crapope INTO rw_crapope;
              --Se encontrou
              IF cr_crapope%FOUND THEN
                --Codigo Operador
                pr_operador:= rw_crapope.cdoperad || '-'||rw_crapope.nmoperad;
              END IF;
              --Fechar Cursor
              CLOSE cr_crapope;
            END IF;
          END IF;

        EXCEPTION
          WHEN vr_exc_saida THEN
            ROLLBACK TO save_trans;
        END;
        --Se ocorreu erro
        IF vr_dscritic IS NOT NULL OR vr_cdcritic <> 0 THEN
          -- Retorno não OK
          pr_des_reto := 'NOK';
          --Se tem erro na tabela
          IF pr_tab_erro.count = 0 THEN
            -- Gerar rotina de gravação de erro
            gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                 ,pr_cdagenci => pr_cdagenci
                                 ,pr_nrdcaixa => pr_nrdcaixa
                                 ,pr_nrsequen => 1 --> Fixo
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic
                                 ,pr_tab_erro => pr_tab_erro);
          END IF;
        ELSE
          -- Retorno OK
          pr_des_reto:= 'OK';
        END IF;
      EXCEPTION
         WHEN OTHERS THEN
          -- Retorno não OK
          pr_des_reto := 'NOK';
          -- Montar descrição de erro não tratado
          vr_dscritic := 'Erro não tratado na CYBE0001.pc_valida_dados '||sqlerrm;
          -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 --> Fixo
                               ,pr_cdcritic => 0
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
      END;
    END pc_valida_dados;

    --Procedure para processar alteracoes do LOG para tabelas
    PROCEDURE  pc_proc_alteracoes_log (pr_log_cdcooper IN crapcop.cdcooper%TYPE --> Codigo Cooperativa
                                      ,pr_log_nrdconta IN crapass.nrdconta%TYPE --> Numero da Conta
                                      ,pr_log_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data Movimento
                                      ,pr_log_cdoperad IN crapope.cdoperad%TYPE --> Codigo Operador
                                      ,pr_log_cddopcao IN VARCHAR2              --> Codigo opcao
                                      ,pr_log_nmdatela IN VARCHAR2              --> Nome da tela
                                      ,pr_log_idseqttl IN crapttl.idseqttl%TYPE --> Sequencia Titular
                                      ,pr_log_nrdctabb IN crapass.nrdconta%TYPE --> mantal - Numero Conta
                                      ,pr_log_nrdocmto IN crapcst.nrcheque%TYPE --> Mantal - Numero Cheque
                                      ,pr_tab_rowid    IN typ_tab_rowid         --> tabelas do log
                                      ,pr_flgcontas    IN BOOLEAN               --> Informacoes Conta
                                      ,pr_flgmatric    IN BOOLEAN               --> Informacoes matricula
                                      ,pr_flgmantal    IN BOOLEAN               --> Informacoes Tela Mantal
                                      ,pr_flgcadspc    IN BOOLEAN               --> Informacoes Tela CADSPC
                                      ,pr_log_flencnet IN BOOLEAN               --> Endereco Internetbank
                                      ,pr_log_dtaltera IN DATE                  --> Data Alteracao
                                      ,pr_tab_log      IN typ_tab_log           --> tabela com informacoes log
                                      ,pr_des_reto     OUT VARCHAR2             --> Informacao erro
                                      ,pr_dscritic     OUT VARCHAR2) IS         --> Descricao Erro
    BEGIN
   /* .............................................................................

   Programa: pc_proc_alteracoes_log          Antigo: includes/b1wgenllog.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Abril/2006.                    Ultima atualizacao: 26/04/2017

   Dados referentes ao programa:

   Frequencia: Sempre que for chamada.
   Objetivo  : Processar a rotina de log das alteracoes feitas.

   Alteracoes: 19/10/2006 - Acerto na Exclusao da Conta de Integracao (Ze).

               05/01/2007 - Verificar se a conta ITG esta ativa para atender
                            tambem as contas do BANCOOB (Evandro).

               11/01/2007 - Corrigida a atribuicao do operador que fez a
                            alteracao (Evandro).

               01/09/2008 - Alteracao cdempres (Kbase IT) - Eduardo Silva.
                          - Retirado tratamento do campo Rec.Arq.Cob
                            e email (Gabriel)

               18/06/2009 - Ajustes  para os campos de rendimento e valor.
                            Logar novo item BENS (Gabriel).

               04/12/2009 - Logar campos do item "INF. ADICIONAL" da pessoa
                            fisica (Elton).

               16/12/2009 - Eliminado campo crapttl.cdgrpext (Diego).

               01/03/2010 - Adaptar p/ uso nas BO's (Jose Luis, DB1)

               11/03/2011 - Retirar campo dsdemail e inarqcbr da crapass
                            (Gabriel).

               20/05/2011 - Substituicao do campo crapenc.nranores por
                            crapenc.dtinires (data que o cooperado passou a
                            residir no endereco informado). Fabricio

               13/06/2011 - Incluir campo de 'Pessoa politicamente exposta'
                            (Gabriel).

               05/07/2011 - Incluidas as variaveis log_nrdoapto e log_cddbloco
                            (Henrique).

               02/12/2011 - Incluido a variavel log_dsjusren (Adriano).

               13/04/2012 - Incluir tratamento para tela CADSPC (DB1).

               16/04/2012 - Incluido tratamento para a tabela crapcrl - Resp.
                            Legal (AdriaNO).

               29/04/2013 - Alterado campo crapass.dsnatura por crapttl.dsnatura.
                          - Incluirdo crapttl.cdufnatu <> log_cdufnatu.
                            (Lucas R)

               20/08/2013 - Alterada posicao de verificacao dos campos dsnatura
                            e cdufnatu para verificar somente se a crapttl
                            estiver disponivel. (Reinert)

               30/09/2013 - Removido campo log_nrfonres.
                          - Alterada String de PAC para PA. (Reinert)

               14/11/2013 - Alterado totalizador de PAs de 99 para 999.
                            (Reinert)

               10/12/2013 - Incluir VALIDATE crapalt (Lucas R.)

               13/03/2014 - Conversao Progress --> Oracle (Alisson - AMcom)

               02/06/2014 - Os campos cdestcvl e vlsalari foram removidos da crapass e adicionados
                            na crapttl, portanto foram removidas as validações para crapass.
                            As validações já exitem para crapttl.
                            (Douglas - Chamado 131253)

               10/06/2014 - (Chamado 117414) - Troca do uso do conjuge na crapass pela
                            crapcje. (Tiago Castro - RKAM).

               27/10/2015 - Incluido a verificacao do campo crapass.idastcjt, Prj. 131 -
                            Assinatura Conjunta. (Jean Michel).

               17/04/2017 - Buscar a nacionalidade com CDNACION. (Jaison/Andrino)
               
               24/07/2017 - Alterar cdoedptl para idorgexp.
                            PRJ339-CRM  (Odirlei-AMcom)

			   26/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                crapass, crapttl, crapjur 
						   (Adriano - P339).
    ............................................................................. */
      DECLARE

        --Selecionar Infomacoes Titulares
        CURSOR cr_crapttl (pr_rowid IN ROWID) IS
          SELECT crapttl.*
          FROM crapttl
          WHERE crapttl.rowid = pr_rowid;
        rw_crapttl cr_crapttl%ROWTYPE;
        --Selecionar Infomacoes Endereco
        CURSOR cr_crapenc (pr_rowid IN ROWID) IS
          SELECT crapenc.*
          FROM crapenc
          WHERE crapenc.rowid = pr_rowid;
        rw_crapenc cr_crapenc%ROWTYPE;
        --Selecionar Infomacoes Pessoa juridica
        CURSOR cr_crapjur (pr_rowid IN ROWID) IS
          SELECT crapjur.*
          FROM crapjur
          WHERE crapjur.rowid = pr_rowid;
        rw_crapjur cr_crapjur%ROWTYPE;
        --Selecionar Infomacoes Telefone
        CURSOR cr_craptfc (pr_rowid IN ROWID) IS
          SELECT craptfc.*
          FROM craptfc
          WHERE craptfc.rowid = pr_rowid;
        rw_craptfc cr_craptfc%ROWTYPE;
        --Selecionar Infomacoes Emissao Extrato
        CURSOR cr_crapcex (pr_rowid IN ROWID) IS
          SELECT crapcex.*
          FROM crapcex
          WHERE crapcex.rowid = pr_rowid;
        rw_crapcex cr_crapcex%ROWTYPE;
        --Selecionar Infomacoes Email
        CURSOR cr_crapcem (pr_rowid IN ROWID) IS
          SELECT crapcem.*
          FROM crapcem
          WHERE crapcem.rowid = pr_rowid;
        rw_crapcem cr_crapcem%ROWTYPE;
        --Selecionar Infomacoes Cadastro SPC
        CURSOR cr_crapspc (pr_rowid IN ROWID) IS
          SELECT crapspc.*
          FROM crapspc
          WHERE crapspc.rowid = pr_rowid;
        rw_crapspc cr_crapspc%ROWTYPE;
        --Selecionar Infomacoes Avalista
        CURSOR cr_crapavt (pr_rowid IN ROWID) IS
          SELECT crapavt.*
          FROM crapavt
          WHERE crapavt.rowid = pr_rowid;
        rw_crapavt cr_crapavt%ROWTYPE;
        --Selecionar Infomacoes Responsavel Legal
        CURSOR cr_crapcrl (pr_rowid IN ROWID) IS
          SELECT crapcrl.*
          FROM crapcrl
          WHERE crapcrl.rowid = pr_rowid;
        rw_crapcrl cr_crapcrl%ROWTYPE;
        --Selecionar Infomacoes Conjuge
        CURSOR cr_crapcje (pr_rowid IN ROWID) IS
          SELECT crapcje.*
          FROM crapcje
          WHERE crapcje.rowid = pr_rowid;
        rw_crapcje cr_crapcje%ROWTYPE;

        --Selecionar dados do conjuge
        CURSOR cr_crapcje1 (pr_cdcooper IN crapcop.cdcooper%TYPE
                           ,pr_nrdconta IN crapcje.nrdconta%TYPE) IS
          SELECT crapcje.nmconjug
                ,crapcje.dtnasccj
                ,crapcje.dsendcom
          FROM  crapcje
          WHERE crapcje.cdcooper = pr_cdcooper
          AND   crapcje.nrdconta = pr_nrdconta
          AND   crapcje.idseqttl = 1;
        rw_crapcje1 cr_crapcje1%ROWTYPE;

        --Selecionar Infomacoes Dependentes
        CURSOR cr_crapdep (pr_rowid IN ROWID) IS
          SELECT crapdep.*
          FROM crapdep
          WHERE crapdep.rowid = pr_rowid;
        rw_crapdep cr_crapdep%ROWTYPE;
        --Selecionar Infomacoes dos bens
        CURSOR cr_crapbem (pr_rowid IN ROWID) IS
          SELECT crapbem.*
          FROM crapbem
          WHERE crapbem.rowid = pr_rowid;
        rw_crapbem cr_crapbem%ROWTYPE;
        --Selecionar Infomacoes Financeiras PJ
        CURSOR cr_crapjfn (pr_rowid IN ROWID) IS
          SELECT crapjfn.*
          FROM crapjfn
          WHERE crapjfn.rowid = pr_rowid;
        rw_crapjfn cr_crapjfn%ROWTYPE;
        --Selecionar Informacoes da Alteracao
        CURSOR cr_crapalt (pr_cdcooper IN crapcop.cdcooper%TYPE
                          ,pr_nrdconta IN crapass.nrdconta%TYPE
                          ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
          SELECT crapalt.dsaltera
                ,crapalt.flgctitg
                ,crapalt.cdcooper
                ,crapalt.nrdconta
                ,crapalt.dtaltera
                ,crapalt.tpaltera
                ,crapalt.cdoperad
                ,crapalt.rowid
          FROM crapalt
          WHERE crapalt.cdcooper = pr_cdcooper
          AND   crapalt.nrdconta = pr_nrdconta
          AND   crapalt.dtaltera = pr_dtmvtolt;
        rw_crapalt cr_crapalt%ROWTYPE;
        --Selecionar Informacoes Associado
        CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE
                          ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
          SELECT crapass.*
                ,crapass.rowid
          FROM crapass
          WHERE crapass.cdcooper = pr_cdcooper
          AND   crapass.nrdconta = pr_nrdconta;
        rw_crapass cr_crapass%ROWTYPE;
        --Selecionar Infomacoes Associado
        CURSOR cr_crapass_rowid (pr_rowid IN ROWID) IS
          SELECT crapass.*
                ,crapass.rowid
          FROM crapass
          WHERE crapass.rowid = pr_rowid;

        --Variaveis Locais
        vr_flgnvalt BOOLEAN;
        vr_crapalt  BOOLEAN;
        vr_index    VARCHAR2(7);
        vr_dsaltera LONG:= ' ';
        vr_flgctitg crapalt.flgctitg%TYPE;

        --Variaveis de LOG Locais
        vr_log_nmdcampo VARCHAR2(4000);
        vr_log_tpaltera INTEGER;
        vr_log_flgctitg INTEGER;
        vr_log_flgrecad BOOLEAN;
        vr_log_flaltera BOOLEAN;

        --Variaveis gerais
        vr_log_msgrecad VARCHAR2(200);
        vr_log_chavealt VARCHAR2(200);
        vr_log_msgatcad VARCHAR2(200);
        vr_log_tpatlcad INTEGER;

        --Variaveis Bloco Mantal
        vr_log_desopcao VARCHAR2(100);
        vr_log_qtletras INTEGER;
        vr_log_qtlinhas INTEGER;

        --Variaveis Erro
        vr_cdcritic INTEGER;
        vr_des_erro VARCHAR2(3);
        vr_dscritic VARCHAR2(4000);

        --Variaveis Excecao
        vr_exc_erro EXCEPTION;

      BEGIN
        -- Retorno OK
        pr_des_reto := 'OK';

        --Inicializar variaveis
        vr_log_nmdcampo:= NULL;
        vr_log_tpaltera:= 2; /* Por default fica como 2 */
        vr_log_flgctitg:= 3;
        vr_log_flgrecad:= FALSE;

        SAVEPOINT save_trans;

        --Nova alteracao
        vr_flgnvalt:= FALSE;

        --Selecionar Alteracao
        OPEN cr_crapalt (pr_cdcooper => pr_log_cdcooper
                        ,pr_nrdconta => pr_log_nrdconta
                        ,pr_dtmvtolt => pr_log_dtmvtolt);
        FETCH cr_crapalt INTO rw_crapalt;
        --Verificar se encontrou
        vr_crapalt:= cr_crapalt%FOUND;
        --Fechar Cursor
        CLOSE cr_crapalt;

        --Se nao encontrou
        IF NOT vr_crapalt THEN
          --Inserir Alteracao
          BEGIN
            INSERT INTO crapalt
              (crapalt.nrdconta
              ,crapalt.dtaltera
              ,crapalt.tpaltera
              ,crapalt.dsaltera
              ,crapalt.cdcooper
              ,crapalt.flgctitg)
            VALUES
              (pr_log_nrdconta
              ,pr_log_dtmvtolt
              ,vr_log_tpaltera
              ,' '
              ,pr_log_cdcooper
              ,0)
            RETURNING crapalt.rowid,crapalt.flgctitg
            INTO rw_crapalt.rowid,vr_flgctitg;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic:= 'Erro ao inserir crapalt. '||SQLERRM;
              --Sair
              RAISE vr_exc_erro;
          END;
          --Marcar que foi criado crapalt
          vr_flgnvalt:= TRUE;
        ELSE
          --Conta Integracao
          vr_flgctitg:= rw_crapalt.flgctitg;
          --Atribuir a descricao para variavel long para permitir updates
          vr_dsaltera:= rw_crapalt.dsaltera;
        END IF;

        --Selecionar Associado
        OPEN cr_crapass (pr_cdcooper => pr_log_cdcooper
                        ,pr_nrdconta => pr_log_nrdconta);
        FETCH cr_crapass INTO rw_crapass;
        --Se nao encontrou
        IF cr_crapass%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_crapass;
          vr_dscritic:= 'Associado nao encontrado.';
          RAISE vr_exc_erro;
        END IF;
        --Fechar Cursor
        CLOSE cr_crapass;
        OPEN cr_crapcje1(pr_cdcooper => pr_log_cdcooper
                        ,pr_nrdconta => rw_crapass.nrdconta);
        FETCH cr_crapcje1 INTO rw_crapcje1;
        CLOSE cr_crapcje1;

        /* Se for conta integracao ativa, seta a flag para enviar ao BB */
        IF trim(rw_crapass.nrdctitg) IS NOT NULL AND rw_crapass.flgctitg = 2 THEN  /* Ativa */
          --Conta Integracao
          vr_log_flgctitg:= 0;
        END IF;

        -- Percorrer Vetor Rowids
        vr_index:= pr_tab_rowid.FIRST;
        WHILE vr_index IS NOT NULL LOOP
          --Por Matricula
          IF pr_flgmatric AND vr_index = 'CRAPASS' THEN
            --Nome Primeiro titular
            IF rw_crapass.nmprimtl <> pr_tab_log(vr_index).crapass(1).nmprimtl THEN
              --Nome do campo
              vr_log_nmdcampo:= 'nome 1.ttl';
              vr_log_flgrecad:= TRUE;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                vr_flgctitg:= vr_log_flgctitg;
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Nome Pai Primeiro titular
            IF rw_crapass.nmpaiptl <> pr_tab_log(vr_index).crapass(1).nmpaiptl THEN
              --Nome do campo
              vr_log_nmdcampo:= 'pai 1.ttl';
              vr_log_flgrecad:= TRUE;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                vr_flgctitg:= vr_log_flgctitg;
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Nome Mae Primeiro titular
            IF rw_crapass.nmmaeptl <> pr_tab_log(vr_index).crapass(1).nmprimtl THEN
              --Nome do campo
              vr_log_nmdcampo:= 'mae 1.ttl';
              vr_log_flgrecad:= TRUE;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                vr_flgctitg:= vr_log_flgctitg;
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Data nascimento primeiro titular
            IF rw_crapass.dtnasctl <> pr_tab_log(vr_index).crapass(1).dtnasctl THEN
              --Nome do campo
              vr_log_nmdcampo:= 'nascto 1.ttl';
              vr_log_flgrecad:= TRUE;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                vr_flgctitg:= vr_log_flgctitg;
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Numero Cpf/cnpj
            IF rw_crapass.nrcpfcgc <> pr_tab_log(vr_index).crapass(1).nrcpfcgc THEN
              --Nome do campo
              vr_log_nmdcampo:= 'cpf 1.ttl';
              vr_log_flgrecad:= TRUE;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                vr_flgctitg:= vr_log_flgctitg;
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Data Consulta Primeiro titular
            IF rw_crapass.dtcnscpf <> pr_tab_log(vr_index).crapass(1).dtcnscpf THEN
              --Nome do campo
              vr_log_nmdcampo:= 'consulta cpf 1.ttl';
              vr_log_flgrecad:= TRUE;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Nacionalidade
            IF rw_crapass.cdnacion <> pr_tab_log(vr_index).crapass(1).cdnacion THEN
              --Nome do campo
              vr_log_nmdcampo:= 'nacion. 1.ttl';
              vr_log_flgrecad:= TRUE;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                vr_flgctitg:= vr_log_flgctitg;
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Profissao Primeiro titular
            IF rw_crapass.dsproftl <> pr_tab_log(vr_index).crapass(1).dsproftl THEN
              --Nome do campo
              vr_log_nmdcampo:= 'funcao';
              vr_log_flgrecad:= TRUE;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                vr_flgctitg:= vr_log_flgctitg;
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Tipo Documento Primeiro titular
            IF rw_crapass.tpdocptl <> pr_tab_log(vr_index).crapass(1).tpdocptl THEN
              --Nome do campo
              vr_log_nmdcampo:= 'tipo doc. 1.ttl';
              vr_log_flgrecad:= TRUE;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                vr_flgctitg:= vr_log_flgctitg;
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --numero Documento titular
            IF rw_crapass.nrdocptl <> pr_tab_log(vr_index).crapass(1).nrdocptl THEN
              --Nome do campo
              vr_log_nmdcampo:= 'doc. 1.ttl';
              vr_log_flgrecad:= TRUE;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                vr_flgctitg:= vr_log_flgctitg;
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Sexo Primeiro titular
            IF rw_crapass.cdsexotl <> pr_tab_log(vr_index).crapass(1).cdsexotl THEN
              --Nome do campo
              vr_log_nmdcampo:= 'sexo 1.ttl';
              vr_log_flgrecad:= TRUE;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                vr_flgctitg:= vr_log_flgctitg;
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;

            --Exclusao Conta Integracao
            IF rw_crapass.nrdctitg <> pr_tab_log(vr_index).crapass(1).nrdctitg AND
               rw_crapass.cdtipcta = pr_tab_log(vr_index).crapass(1).cdtipcta THEN
              --Nome do campo
              vr_log_nmdcampo:= 'exclusao conta-itg('||
                                pr_tab_log(vr_index).crapass(1).nrdctitg||')- ope.'||
                                pr_log_cdoperad;
              vr_log_flgrecad:= TRUE;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                vr_flgctitg:= vr_log_flgctitg;
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;

            /*  Dados para atualizacao (geram tipo de alteracao 2) */
            --Agencia
            IF rw_crapass.cdagenci <> pr_tab_log(vr_index).crapass(1).cdagenci THEN
              --Nome do campo
              vr_log_nmdcampo:= 'pa.'||gene0002.fn_mask(pr_tab_log(vr_index).crapass(1).cdagenci,'999')||'-'||
                                gene0002.fn_mask(rw_crapass.cdagenci,'999');
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Numero Cadastro
            IF rw_crapass.nrcadast <> pr_tab_log(vr_index).crapass(1).nrcadast THEN
              --Nome do campo
              vr_log_nmdcampo:= 'cadastro 1.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Data Demissao
            IF rw_crapass.dtdemiss <> pr_tab_log(vr_index).crapass(1).dtdemiss THEN
              --Nome do campo
              vr_log_nmdcampo:= 'demissao';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Data Admissao
            IF rw_crapass.dtadmemp <> pr_tab_log(vr_index).crapass(1).dtadmemp THEN
              --Nome do campo
              vr_log_nmdcampo:= 'adm.empr.';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                vr_flgctitg:= vr_log_flgctitg;
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            
            --Ramal Empresa
            IF rw_crapass.nrramemp <> pr_tab_log(vr_index).crapass(1).nrramemp THEN
              --Nome do campo
              vr_log_nmdcampo:= 'ramal';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Numero Conta Contato
            IF rw_crapass.nrctacto <> pr_tab_log(vr_index).crapass(1).nrctacto THEN
              --Nome do campo
              vr_log_nmdcampo:= 'ctato1';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Numero Conta
            IF rw_crapass.nrctaprp <> pr_tab_log(vr_index).crapass(1).nrctaprp THEN
              --Nome do campo
              vr_log_nmdcampo:= 'ctato2';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Tipo Conta
            IF rw_crapass.cdtipcta <> pr_tab_log(vr_index).crapass(1).cdtipcta THEN
              --Nome do campo
              vr_log_nmdcampo:= 'tipo cta';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Situacao da Conta
            IF rw_crapass.cdsitdct <> pr_tab_log(vr_index).crapass(1).cdsitdct THEN
              --Nome do campo
              vr_log_nmdcampo:= 'sit.cta';
              vr_log_flgrecad:= TRUE;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Destino Extrato
            IF rw_crapass.cdsecext <> pr_tab_log(vr_index).crapass(1).cdsecext THEN
              --Nome do campo
              vr_log_nmdcampo:= 'dest.extrato';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Consulta ao SPC
            IF rw_crapass.dtcnsspc <> pr_tab_log(vr_index).crapass(1).dtcnsspc THEN
              --Nome do campo
              vr_log_nmdcampo:= 'consulta spc';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --SPC Cooperado
            IF rw_crapass.dtdsdspc <> pr_tab_log(vr_index).crapass(1).dtdsdspc THEN
              --Nome do campo
              vr_log_nmdcampo:= 'spc coop';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Incluido SPC
            IF rw_crapass.inadimpl <> pr_tab_log(vr_index).crapass(1).inadimpl THEN
              --Nome do campo
              vr_log_nmdcampo:= 'spc';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Inclusao CCF
            IF rw_crapass.inlbacen <> pr_tab_log(vr_index).crapass(1).inlbacen THEN
              --Nome do campo
              vr_log_nmdcampo:= 'ccf';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Dependente
            IF rw_crapass.flgiddep <> pr_tab_log(vr_index).crapass(1).flgiddep THEN
              --Nome do campo
              vr_log_nmdcampo:= 'id.dep';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Recebimento Extrato
            IF rw_crapass.tpextcta <> pr_tab_log(vr_index).crapass(1).tpextcta THEN
              --Nome do campo
              vr_log_nmdcampo:= 'recebimento de extrato';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Tipo Aviso Debito
            IF rw_crapass.tpavsdeb <> pr_tab_log(vr_index).crapass(1).tpavsdeb THEN
              --Nome do campo
              vr_log_nmdcampo:= 'tipo aviso deb.';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;

            /* campos 14/10/98 */

            --orgao Emissor Doc. Primeiro titular
            IF rw_crapass.idorgexp <> pr_tab_log(vr_index).crapass(1).idorgexp THEN
              --Nome do campo
              vr_log_nmdcampo:= 'org.ems.doc. 1.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                vr_flgctitg:= vr_log_flgctitg;
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            
            --UF Emissao Doc. Primeiro titular
            IF rw_crapass.cdufdptl <> pr_tab_log(vr_index).crapass(1).cdufdptl THEN
              --Nome do campo
              vr_log_nmdcampo:= 'uf.ems.doc. 1.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                vr_flgctitg:= vr_log_flgctitg;
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            
            --Data Emissao Doc. Primeiro titular
            IF rw_crapass.dtemdptl <> pr_tab_log(vr_index).crapass(1).dtemdptl THEN
              --Nome do campo
              vr_log_nmdcampo:= 'dt.ems.doc. 1.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                vr_flgctitg:= vr_log_flgctitg;
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            
            --Situacao Titular
            IF rw_crapass.cdsitdtl <> pr_tab_log(vr_index).crapass(1).cdsitdtl THEN
              --Nome do campo
              vr_log_nmdcampo:= 'sit.tit.'||pr_tab_log(vr_index).crapass(1).cdsitdtl||'-'||
                                rw_crapass.cdsitdtl;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                vr_flgctitg:= vr_log_flgctitg;
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Atualizar Alteracao
            BEGIN
              UPDATE crapalt SET crapalt.flgctitg = vr_flgctitg
                                ,crapalt.dsaltera = vr_dsaltera
              WHERE crapalt.rowid = rw_crapalt.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic:= 0;
                vr_dscritic:= 'Erro ao atualizar crapalt. '||SQLERRM;
                --Sair
                RAISE vr_exc_erro;
            END;
          ELSIF pr_flgmatric AND vr_index = 'CRAPCJE' THEN
            -- ALTERACOES CONJUGE
            --Selecionar dados conjuge
            OPEN cr_crapcje_rowid (pr_cdcooper => pr_log_cdcooper
                                  ,pr_nrdconta => pr_log_nrdconta);
            FETCH cr_crapcje_rowid INTO rw_crapcje_rowid;
            CLOSE cr_crapcje_rowid;

            --Nome Conjuge
            IF rw_crapcje_rowid.nmconjug <> pr_tab_log(vr_index).crapcje(1).nmconjug THEN
              --Nome do campo
              vr_log_nmdcampo:= 'conjuge 1.ttl';
              vr_log_flgrecad:= TRUE;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                vr_flgctitg:= vr_log_flgctitg;
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Data Nascimento Conjuge
            IF rw_crapcje_rowid.dtnasccj <> pr_tab_log(vr_index).crapcje(1).dtnasccj THEN
              --Nome do campo
              vr_log_nmdcampo:= 'nascto conjuge';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                vr_flgctitg:= vr_log_flgctitg;
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Endereco Conjuge
            IF rw_crapcje_rowid.dsendcom <> pr_tab_log(vr_index).crapcje(1).dsendcom THEN
              --Nome do campo
              vr_log_nmdcampo:= 'end.conjuge';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
          -- fim alteracoes conjuge

          ELSIF pr_flgmatric AND vr_index = 'CRAPTTL' THEN
            --Selecionar Informacoes Titular
            OPEN cr_crapttl (pr_rowid => pr_tab_rowid(vr_index));
            FETCH cr_crapttl INTO rw_crapttl;
            CLOSE cr_crapttl;
            --Codigo Turno
            IF rw_crapttl.cdturnos <> pr_tab_log(vr_index).crapttl(1).cdturnos THEN
              --Nome do campo
              vr_log_nmdcampo:= 'turno '||rw_crapttl.idseqttl||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                vr_flgctitg:= vr_log_flgctitg;
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Tipo nacionalidade
            IF rw_crapttl.tpnacion <> pr_tab_log(vr_index).crapttl(1).tpnacion THEN
              --Nome do campo
              vr_log_nmdcampo:= 'tipo nacion. '||rw_crapttl.idseqttl||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                vr_flgctitg:= vr_log_flgctitg;
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            -- Naturalidade
            IF rw_crapttl.dsnatura <> pr_tab_log(vr_index).crapttl(1).dsnatura THEN
              --Nome do campo
              vr_log_nmdcampo:= 'natural. '||rw_crapttl.idseqttl||'.ttl';
              vr_log_flgrecad:= TRUE;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                vr_flgctitg:= vr_log_flgctitg;
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            -- UF Naturalidade
            IF rw_crapttl.cdufnatu <> pr_tab_log(vr_index).crapttl(1).cdufnatu THEN
              --Nome do campo
              vr_log_nmdcampo:= 'uf naturalidade. '||rw_crapttl.idseqttl||'.ttl';
              vr_log_flgrecad:= TRUE;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                vr_flgctitg:= vr_log_flgctitg;
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            -- Ocupacao
            IF rw_crapttl.cdocpttl <> pr_tab_log(vr_index).crapttl(1).cdocpttl THEN
              --Nome do campo
              vr_log_nmdcampo:= 'ocupacao '||rw_crapttl.idseqttl||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                vr_flgctitg:= vr_log_flgctitg;
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            -- Empresa
            IF rw_crapttl.cdempres <> pr_tab_log(vr_index).crapttl(1).cdempres THEN
              --Nome do campo
              vr_log_nmdcampo:= 'empr.'||
                                gene0002.fn_mask(pr_tab_log(vr_index).crapttl(1).cdempres,'99999')||
                                '-'||gene0002.fn_mask(rw_crapttl.cdempres,'99999')||' 1.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Atualizar Alteracao
            BEGIN
              UPDATE crapalt SET crapalt.flgctitg = vr_flgctitg
                                ,crapalt.dsaltera = vr_dsaltera
              WHERE crapalt.rowid = rw_crapalt.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic:= 0;
                vr_dscritic:= 'Erro ao atualizar crapalt. '||SQLERRM;
                --Sair
                RAISE vr_exc_erro;
            END;
          ELSIF pr_flgmatric AND vr_index = 'CRAPENC' THEN
            --Selecionar Informacoes Titular
            OPEN cr_crapenc (pr_rowid => pr_tab_rowid(vr_index));
            FETCH cr_crapenc INTO rw_crapenc;
            CLOSE cr_crapenc;
            --Endereco
            IF rw_crapenc.dsendere <> pr_tab_log(vr_index).crapenc(1).dsendere THEN
              --Nome do campo
              vr_log_nmdcampo:= 'endereco '||rw_crapenc.idseqttl||'.ttl';
              vr_log_flgrecad:= TRUE;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Nome Bairro
            IF rw_crapenc.nmbairro <> pr_tab_log(vr_index).crapenc(1).nmbairro THEN
              --Nome do campo
              vr_log_nmdcampo:= 'bairro '||rw_crapenc.idseqttl||'.ttl';
              vr_log_flgrecad:= TRUE;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Nome Cidade
            IF rw_crapenc.nmcidade <> pr_tab_log(vr_index).crapenc(1).nmcidade THEN
              --Nome do campo
              vr_log_nmdcampo:= 'cidade '||rw_crapenc.idseqttl||'.ttl';
              vr_log_flgrecad:= TRUE;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --UF Endereco
            IF rw_crapenc.cdufende <> pr_tab_log(vr_index).crapenc(1).cdufende THEN
              --Nome do campo
              vr_log_nmdcampo:= 'uf '||rw_crapenc.idseqttl||'.ttl';
              vr_log_flgrecad:= TRUE;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --CEP Endereco
            IF rw_crapenc.nrcepend <> pr_tab_log(vr_index).crapenc(1).nrcepend THEN
              --Nome do campo
              vr_log_nmdcampo:= 'cep '||rw_crapenc.idseqttl||'.ttl';
              vr_log_flgrecad:= TRUE;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Numero Endereco
            IF rw_crapenc.nrendere <> pr_tab_log(vr_index).crapenc(1).nrendere THEN
              --Nome do campo
              vr_log_nmdcampo:= 'nro.end. '||rw_crapenc.idseqttl||'.ttl';
              vr_log_flgrecad:= TRUE;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                vr_flgctitg:= vr_log_flgctitg;
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Complemento Endereco
            IF rw_crapenc.complend <> pr_tab_log(vr_index).crapenc(1).complend THEN
              --Nome do campo
              vr_log_nmdcampo:= 'compl.end. '||rw_crapenc.idseqttl||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                vr_flgctitg:= vr_log_flgctitg;
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Caixa Postal
            IF rw_crapenc.nrcxapst <> pr_tab_log(vr_index).crapenc(1).nrcxapst THEN
              --Nome do campo
              vr_log_nmdcampo:= 'caixa postal '||rw_crapenc.idseqttl||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                vr_flgctitg:= vr_log_flgctitg;
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Casa Propria
            IF rw_crapenc.incasprp <> pr_tab_log(vr_index).crapenc(1).incasprp THEN
              --Nome do campo
              vr_log_nmdcampo:= 'casa propria';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                vr_flgctitg:= vr_log_flgctitg;
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Valor Aluguel
            IF rw_crapenc.vlalugue <> pr_tab_log(vr_index).crapenc(1).vlalugue THEN
              --Nome do campo
              vr_log_nmdcampo:= 'aluguel';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Tempo Residencia
            IF rw_crapenc.dtinires <> pr_tab_log(vr_index).crapenc(1).dtinires THEN
              --Nome do campo
              vr_log_nmdcampo:= 'tempo resid.';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                vr_flgctitg:= vr_log_flgctitg;
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Atualizar Alteracao
            BEGIN
              UPDATE crapalt SET crapalt.flgctitg = vr_flgctitg
                                ,crapalt.dsaltera = vr_dsaltera
              WHERE crapalt.rowid = rw_crapalt.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic:= 0;
                vr_dscritic:= 'Erro ao atualizar crapalt. '||SQLERRM;
                --Sair
                RAISE vr_exc_erro;
            END;
          ELSIF pr_flgmatric AND vr_index = 'CRAPTFC' THEN
            --Selecionar Informacoes Titular
            OPEN cr_craptfc (pr_rowid => pr_tab_rowid(vr_index));
            FETCH cr_craptfc INTO rw_craptfc;
            CLOSE cr_craptfc;
            --Numero DDD
            IF rw_craptfc.nrdddtfc <> pr_tab_log(vr_index).craptfc(1).nrdddtfc THEN
              --Nome do campo
              vr_log_nmdcampo:= 'DDD';
              vr_log_flgrecad:= TRUE;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Numero Telefone
            IF rw_craptfc.nrtelefo <> pr_tab_log(vr_index).craptfc(1).nrtelefo THEN
              --Nome do campo
              vr_log_nmdcampo:= 'telefone';
              vr_log_flgrecad:= TRUE;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Atualizar Alteracao
            BEGIN
              UPDATE crapalt SET crapalt.dsaltera = vr_dsaltera
              WHERE crapalt.rowid = rw_crapalt.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic:= 0;
                vr_dscritic:= 'Erro ao atualizar crapalt. '||SQLERRM;
                --Sair
                RAISE vr_exc_erro;
            END;
          ELSIF pr_flgmatric AND vr_index = 'CRAPJUR' THEN
            --Selecionar Informacoes Empresa
            OPEN cr_crapjur (pr_rowid => pr_tab_rowid(vr_index));
            FETCH cr_crapjur INTO rw_crapjur;
            CLOSE cr_crapjur;
            --Inicio Atividade
            IF rw_crapjur.dtiniatv <> pr_tab_log(vr_index).crapjur(1).dtiniatv THEN
              --Nome do campo
              vr_log_nmdcampo:= 'ini.ativ.';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                vr_flgctitg:= vr_log_flgctitg;
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Natureza Juridica
            IF rw_crapjur.natjurid <> pr_tab_log(vr_index).crapjur(1).natjurid THEN
              --Nome do campo
              vr_log_nmdcampo:= 'nat.jurid.';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                vr_flgctitg:= vr_log_flgctitg;
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Nome Fantasia
            IF rw_crapjur.nmfansia <> pr_tab_log(vr_index).crapjur(1).nmfansia THEN
              --Nome do campo
              vr_log_nmdcampo:= 'nome fantasia';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                vr_flgctitg:= vr_log_flgctitg;
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Inscricao Estadual
            IF rw_crapjur.nrinsest <> pr_tab_log(vr_index).crapjur(1).nrinsest THEN
              --Nome do campo
              vr_log_nmdcampo:= 'insc.estadual';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                vr_flgctitg:= vr_log_flgctitg;
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Ramo Atividade
            IF rw_crapjur.cdrmativ <> pr_tab_log(vr_index).crapjur(1).cdrmativ THEN
              --Nome do campo
              vr_log_nmdcampo:= 'ramo ativ.';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                vr_flgctitg:= vr_log_flgctitg;
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Atualizar Alteracao
            BEGIN
              UPDATE crapalt SET crapalt.flgctitg = vr_flgctitg
                                ,crapalt.dsaltera = vr_dsaltera
              WHERE crapalt.rowid = rw_crapalt.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic:= 0;
                vr_dscritic:= 'Erro ao atualizar crapalt. '||SQLERRM;
                --Sair
                RAISE vr_exc_erro;
            END;
          END IF; --pr_flgmatric

          IF NOT pr_flgcontas AND vr_index = 'CRAPASS' THEN

            --Selecionar Informacoes Associado
            OPEN cr_crapass_rowid (pr_rowid => pr_tab_rowid(vr_index));
            FETCH cr_crapass_rowid INTO rw_crapass;
            CLOSE cr_crapass_rowid;

            /* Verificacoes para o log dos dados genericos */

            --Codigo Agencia
            IF rw_crapass.cdagenci <> pr_tab_log(vr_index).crapass(1).cdagenci THEN
              --Nome do campo
              vr_log_nmdcampo:= 'PA '||pr_tab_log(vr_index).crapass(1).cdagenci||'-'||
                                rw_crapass.cdagenci;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;

            /* Verificacoes para o log da tela: CONTAS -> CONTA CORRENTE */

            --Tipo Conta
            IF rw_crapass.cdtipcta <> pr_tab_log(vr_index).crapass(1).cdtipcta THEN
              --Nome do campo
              vr_log_nmdcampo:= 'tipo cta';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Situacao Conta
            IF rw_crapass.cdsitdct <> pr_tab_log(vr_index).crapass(1).cdsitdct THEN
              --Nome do campo
              vr_log_nmdcampo:= 'sit.cta';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;

            --Assinatura Conjunta
            IF rw_crapass.idastcjt <> pr_tab_log(vr_index).crapass(1).idastcjt THEN
              --Nome do campo
              vr_log_nmdcampo:= 'exige ass.conj.';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Dependentes
            IF rw_crapass.flgiddep <> pr_tab_log(vr_index).crapass(1).flgiddep THEN
              --Nome do campo
              vr_log_nmdcampo:= 'id.dep';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Folhas Talao
            IF rw_crapass.qtfoltal <> pr_tab_log(vr_index).crapass(1).qtfoltal THEN
              --Nome do campo
              vr_log_nmdcampo:= 'folhas talao';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Aviso Debito
            IF rw_crapass.tpavsdeb <> pr_tab_log(vr_index).crapass(1).tpavsdeb THEN
              --Nome do campo
              vr_log_nmdcampo:= 'aviso debito';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Tipo Extrato
            IF rw_crapass.tpextcta <> pr_tab_log(vr_index).crapass(1).tpextcta THEN
              --Nome do campo
              vr_log_nmdcampo:= 'tipo extrato';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Destino Extrato
            IF rw_crapass.cdsecext <> pr_tab_log(vr_index).crapass(1).cdsecext THEN
              --Nome do campo
              vr_log_nmdcampo:= 'destino extrato'||
                                pr_tab_log(vr_index).crapass(1).cdsecext||'-'||
                                rw_crapass.cdsecext;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Consulta SPC
            IF rw_crapass.dtcnsspc <> pr_tab_log(vr_index).crapass(1).dtcnsspc THEN
              --Nome do campo
              vr_log_nmdcampo:= 'consulta spc';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Consulta SCR
            IF rw_crapass.dtcnsscr <> pr_tab_log(vr_index).crapass(1).dtcnsscr THEN
              --Nome do campo
              vr_log_nmdcampo:= 'consulta scr';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --SPC p/ coop
            IF rw_crapass.dtdsdspc <> pr_tab_log(vr_index).crapass(1).dtdsdspc THEN
              --Nome do campo
              vr_log_nmdcampo:= 'spc p/coop';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Verificar se esta no spc
            IF rw_crapass.inadimpl <> pr_tab_log(vr_index).crapass(1).inadimpl THEN
              --Nome do campo
              vr_log_nmdcampo:= 'esta no spc';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Verificar se esta no CCF
            IF rw_crapass.inlbacen <> pr_tab_log(vr_index).crapass(1).inlbacen THEN
              --Nome do campo
              vr_log_nmdcampo:= 'esta no ccf';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Atualizar Alteracao
            BEGIN
              UPDATE crapalt SET crapalt.flgctitg = vr_flgctitg
                                ,crapalt.cdoperad = pr_log_cdoperad
                                ,crapalt.dsaltera = vr_dsaltera
              WHERE crapalt.rowid = rw_crapalt.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic:= 0;
                vr_dscritic:= 'Erro ao atualizar crapalt. '||SQLERRM;
                --Sair
                RAISE vr_exc_erro;
            END;
          ELSIF NOT pr_flgcontas AND vr_index = 'CRAPTFC' THEN

            --Selecionar Informacoes Associado
            OPEN cr_craptfc (pr_rowid => pr_tab_rowid(vr_index));
            FETCH cr_craptfc INTO rw_craptfc;
            CLOSE cr_craptfc;

            /* Verificacoes para o log da tela: CONTAS -> TELEFONES */

            /* Exclusao de telefone */
            IF pr_log_cddopcao = 'E' THEN
              --Nome do campo
              vr_log_nmdcampo:= 'Exc.Telef.'||rw_craptfc.nrtelefo||' '||pr_log_idseqttl||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
              --Atualizar Alteracao
              BEGIN
                UPDATE crapalt SET crapalt.flgctitg = vr_flgctitg
                                  ,crapalt.cdoperad = pr_log_cdoperad
                                  ,crapalt.dsaltera = vr_dsaltera
                WHERE crapalt.rowid = rw_crapalt.rowid;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_cdcritic:= 0;
                  vr_dscritic:= 'Erro ao atualizar crapalt. '||SQLERRM;
                  --Sair
                  RAISE vr_exc_erro;
              END;
              EXIT;
            END IF;
            --operador telefonico
            IF rw_craptfc.cdopetfn <> pr_tab_log(vr_index).craptfc(1).cdopetfn THEN
              --Nome do campo
              vr_log_nmdcampo:= 'Ope.Telef.'||pr_tab_log(vr_index).craptfc(1).cdopetfn||'-'||
                                rw_craptfc.cdopetfn||' '||pr_log_idseqttl||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --DDD
            IF rw_craptfc.nrdddtfc <> pr_tab_log(vr_index).craptfc(1).nrdddtfc THEN
              --Nome do campo
              vr_log_nmdcampo:= 'DDD '||pr_tab_log(vr_index).craptfc(1).nrdddtfc||'-'||
                                rw_craptfc.nrdddtfc||' '||pr_log_idseqttl||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Numero telefone
            IF rw_craptfc.nrtelefo <> pr_tab_log(vr_index).craptfc(1).nrtelefo THEN
              --Nome do campo
              vr_log_nmdcampo:= 'Telef.'||pr_tab_log(vr_index).craptfc(1).nrtelefo||'-'||
                                rw_craptfc.nrtelefo||' '||pr_log_idseqttl||'.ttl';
              vr_log_flgrecad:= TRUE;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Numero Ramal
            IF rw_craptfc.nrdramal <> pr_tab_log(vr_index).craptfc(1).nrdramal THEN
              --Nome do campo
              vr_log_nmdcampo:= 'Ramal '||pr_tab_log(vr_index).craptfc(1).nrdramal||'-'||
                                rw_craptfc.nrdramal||' '||pr_log_idseqttl||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Tipo Telefone
            IF rw_craptfc.tptelefo <> pr_tab_log(vr_index).craptfc(1).tptelefo THEN
              --Nome do campo
              vr_log_nmdcampo:= 'Ident.Telef.'||pr_tab_log(vr_index).craptfc(1).tptelefo||'-'||
                                rw_craptfc.tptelefo||' '||pr_log_idseqttl||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Setor telefonico
            IF rw_craptfc.secpscto <> pr_tab_log(vr_index).craptfc(1).secpscto THEN
              --Nome do campo
              vr_log_nmdcampo:= 'Setor Telef.'||pr_tab_log(vr_index).craptfc(1).secpscto||'-'||
                                rw_craptfc.secpscto||' '||pr_log_idseqttl||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Contato telefonico
            IF rw_craptfc.nmpescto <> pr_tab_log(vr_index).craptfc(1).nmpescto THEN
              --Nome do campo
              vr_log_nmdcampo:= 'Contato Telef.'||pr_tab_log(vr_index).craptfc(1).nmpescto||'-'||
                                rw_craptfc.nmpescto||' '||pr_log_idseqttl||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Atualizar Alteracao
            BEGIN
              UPDATE crapalt SET crapalt.flgctitg = vr_flgctitg
                                ,crapalt.cdoperad = pr_log_cdoperad
                                ,crapalt.dsaltera = vr_dsaltera
              WHERE crapalt.rowid = rw_crapalt.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic:= 0;
                vr_dscritic:= 'Erro ao atualizar crapalt. '||SQLERRM;
                --Sair
                RAISE vr_exc_erro;
            END;
          ELSIF NOT pr_flgcontas AND vr_index = 'CRAPCEM' THEN

            --Selecionar Informacoes Associado
            OPEN cr_crapcem (pr_rowid => pr_tab_rowid(vr_index));
            FETCH cr_crapcem INTO rw_crapcem;
            CLOSE cr_crapcem;

            /* Verificacoes para o log da tela: CONTAS -> EMAILS */

            /* Exclusao de Email */
            IF pr_log_cddopcao = 'E' THEN
              --Nome do campo
              vr_log_nmdcampo:= 'Exc.Email '||rw_crapcem.dsdemail||' '||pr_log_idseqttl||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
              --Atualizar Alteracao
              BEGIN
                UPDATE crapalt SET crapalt.flgctitg = vr_flgctitg
                                  ,crapalt.cdoperad = pr_log_cdoperad
                                  ,crapalt.dsaltera = vr_dsaltera
                WHERE crapalt.rowid = rw_crapalt.rowid;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_cdcritic:= 0;
                  vr_dscritic:= 'Erro ao atualizar crapalt. '||SQLERRM;
                  --Sair
                  RAISE vr_exc_erro;
              END;
              EXIT;
            END IF;
            --Descricao Email
            IF rw_crapcem.dsdemail <> pr_tab_log(vr_index).crapcem(1).dsdemail THEN
              --Nome do campo
              vr_log_nmdcampo:= 'Email '||pr_tab_log(vr_index).crapcem(1).dsdemail||'-'||
                                rw_crapcem.dsdemail||' '||pr_log_idseqttl||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Setor Email
            IF rw_crapcem.secpscto <> pr_tab_log(vr_index).crapcem(1).secpscto THEN
              --Nome do campo
              vr_log_nmdcampo:= 'Setor Email '||pr_tab_log(vr_index).crapcem(1).secpscto||'-'||
                                rw_crapcem.secpscto||' '||pr_log_idseqttl||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Contato Email
            IF rw_crapcem.nmpescto <> pr_tab_log(vr_index).crapcem(1).nmpescto THEN
              --Nome do campo
              vr_log_nmdcampo:= 'Email '||pr_tab_log(vr_index).crapcem(1).nmpescto||'-'||
                                rw_crapcem.nmpescto||' '||pr_log_idseqttl||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Atualizar Alteracao
            BEGIN
              UPDATE crapalt SET crapalt.flgctitg = vr_flgctitg
                                ,crapalt.cdoperad = pr_log_cdoperad
                                ,crapalt.dsaltera = vr_dsaltera
              WHERE crapalt.rowid = rw_crapalt.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic:= 0;
                vr_dscritic:= 'Erro ao atualizar crapalt. '||SQLERRM;
                --Sair
                RAISE vr_exc_erro;
            END;
          ELSIF NOT pr_flgcontas AND vr_index = 'CRAPENC' THEN

            --Selecionar Informacoes Endereco
            OPEN cr_crapenc (pr_rowid => pr_tab_rowid(vr_index));
            FETCH cr_crapenc INTO rw_crapenc;
            CLOSE cr_crapenc;

            /* Verificacoes para o log da tela: CONTAS -> ENDERECO */

            /* Exclusao somente do endereco cadastrado via InternetBank */
            IF pr_log_cddopcao = 'E' THEN
              --Nome do campo
              vr_log_nmdcampo:= 'exc.end.'||pr_log_idseqttl||'.ttl';
              --InternetBanking
              IF pr_log_flencnet THEN
                vr_log_nmdcampo:= vr_log_nmdcampo || ' NET';
              END IF;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
              --Atualizar Alteracao
              BEGIN
                UPDATE crapalt SET crapalt.flgctitg = vr_flgctitg
                                  ,crapalt.cdoperad = pr_log_cdoperad
                                  ,crapalt.dsaltera = vr_dsaltera
                WHERE crapalt.rowid = rw_crapalt.rowid;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_cdcritic:= 0;
                  vr_dscritic:= 'Erro ao atualizar crapalt. '||SQLERRM;
                  --Sair
                  RAISE vr_exc_erro;
              END;
              EXIT;
            END IF;
            --Imovel
            IF rw_crapenc.incasprp <> pr_tab_log(vr_index).crapenc(1).incasprp THEN
              --Nome do campo
              vr_log_nmdcampo:= 'imovel';
              --Endereco Comercial
              IF rw_crapenc.tpendass = 9 THEN
                vr_log_nmdcampo:= vr_log_nmdcampo || ' com.';
              END IF;
              --Pessoa Fisica
              IF rw_crapass.inpessoa = 1 THEN
                vr_log_nmdcampo:= vr_log_nmdcampo ||' '||pr_log_idseqttl||'.ttl';
              END IF;
              --InternetBanking
              IF pr_log_flencnet THEN
                vr_log_nmdcampo:= vr_log_nmdcampo || ' NET';
              END IF;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Tempo Residencia
            IF rw_crapenc.dtinires <> pr_tab_log(vr_index).crapenc(1).dtinires THEN
              --Nome do campo
              vr_log_nmdcampo:= 'tempo resid.';
              --Endereco Comercial
              IF rw_crapenc.tpendass = 9 THEN
                vr_log_nmdcampo:= vr_log_nmdcampo || ' com.';
              END IF;
              --Pessoa Fisica
              IF rw_crapass.inpessoa = 1 THEN
                vr_log_nmdcampo:= vr_log_nmdcampo ||' '||pr_log_idseqttl||'.ttl';
              END IF;
              --InternetBanking
              IF pr_log_flencnet THEN
                vr_log_nmdcampo:= vr_log_nmdcampo || ' NET';
              END IF;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Valor Aluguel
            IF rw_crapenc.vlalugue <> pr_tab_log(vr_index).crapenc(1).vlalugue THEN
              --Nome do campo
              vr_log_nmdcampo:= 'valor';
              --Endereco Comercial
              IF rw_crapenc.tpendass = 9 THEN
                vr_log_nmdcampo:= vr_log_nmdcampo || ' com.';
              END IF;
              --Pessoa Fisica
              IF rw_crapass.inpessoa = 1 THEN
                vr_log_nmdcampo:= vr_log_nmdcampo ||' '||pr_log_idseqttl||'.ttl';
              END IF;
              --InternetBanking
              IF pr_log_flencnet THEN
                vr_log_nmdcampo:= vr_log_nmdcampo || ' NET';
              END IF;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --CEP
            IF rw_crapenc.nrcepend <> pr_tab_log(vr_index).crapenc(1).nrcepend THEN
              --Nome do campo
              vr_log_nmdcampo:= 'cep';
              --Recadastro
              vr_log_flgrecad:= TRUE;
              --Endereco Comercial
              IF rw_crapenc.tpendass = 9 THEN
                vr_log_nmdcampo:= vr_log_nmdcampo || ' com.';
              END IF;
              --Pessoa Fisica
              IF rw_crapass.inpessoa = 1 THEN
                vr_log_nmdcampo:= vr_log_nmdcampo ||' '||pr_log_idseqttl||'.ttl';
              END IF;
              --InternetBanking
              IF pr_log_flencnet THEN
                vr_log_nmdcampo:= vr_log_nmdcampo || ' NET';
              END IF;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Endereco Residencial
            IF rw_crapenc.dsendere <> pr_tab_log(vr_index).crapenc(1).dsendere THEN
              --Nome do campo
              vr_log_nmdcampo:= 'end.res.';
              --Recadastro
              vr_log_flgrecad:= TRUE;
              --Endereco Comercial
              IF rw_crapenc.tpendass = 9 THEN
                vr_log_nmdcampo:= vr_log_nmdcampo || ' com.';
              END IF;
              --Pessoa Fisica
              IF rw_crapass.inpessoa = 1 THEN
                vr_log_nmdcampo:= vr_log_nmdcampo ||' '||pr_log_idseqttl||'.ttl';
              END IF;
              --InternetBanking
              IF pr_log_flencnet THEN
                vr_log_nmdcampo:= vr_log_nmdcampo || ' NET';
              END IF;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Numero Endereco Residencial
            IF rw_crapenc.nrendere <> pr_tab_log(vr_index).crapenc(1).nrendere THEN
              --Nome do campo
              vr_log_nmdcampo:= 'nr.end.';
              --Endereco Comercial
              IF rw_crapenc.tpendass = 9 THEN
                vr_log_nmdcampo:= vr_log_nmdcampo || ' com.';
              END IF;
              --Pessoa Fisica
              IF rw_crapass.inpessoa = 1 THEN
                vr_log_nmdcampo:= vr_log_nmdcampo ||' '||pr_log_idseqttl||'.ttl';
              END IF;
              --InternetBanking
              IF pr_log_flencnet THEN
                vr_log_nmdcampo:= vr_log_nmdcampo || ' NET';
              END IF;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Complemento Endereco Residencial
            IF rw_crapenc.complend <> pr_tab_log(vr_index).crapenc(1).complend THEN
              --Nome do campo
              vr_log_nmdcampo:= 'complem.';
              --Endereco Comercial
              IF rw_crapenc.tpendass = 9 THEN
                vr_log_nmdcampo:= vr_log_nmdcampo || ' com.';
              END IF;
              --Pessoa Fisica
              IF rw_crapass.inpessoa = 1 THEN
                vr_log_nmdcampo:= vr_log_nmdcampo ||' '||pr_log_idseqttl||'.ttl';
              END IF;
              --InternetBanking
              IF pr_log_flencnet THEN
                vr_log_nmdcampo:= vr_log_nmdcampo || ' NET';
              END IF;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Apto
            IF rw_crapenc.nrdoapto <> pr_tab_log(vr_index).crapenc(1).nrdoapto THEN
              --Nome do campo
              vr_log_nmdcampo:= 'apto.';
              --Endereco Comercial
              IF rw_crapenc.tpendass = 9 THEN
                vr_log_nmdcampo:= vr_log_nmdcampo || ' com.';
              END IF;
              --Pessoa Fisica
              IF rw_crapass.inpessoa = 1 THEN
                vr_log_nmdcampo:= vr_log_nmdcampo ||' '||pr_log_idseqttl||'.ttl';
              END IF;
              --InternetBanking
              IF pr_log_flencnet THEN
                vr_log_nmdcampo:= vr_log_nmdcampo || ' NET';
              END IF;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Bloco
            IF rw_crapenc.cddbloco <> pr_tab_log(vr_index).crapenc(1).cddbloco THEN
              --Nome do campo
              vr_log_nmdcampo:= 'bloco.';
              --Endereco Comercial
              IF rw_crapenc.tpendass = 9 THEN
                vr_log_nmdcampo:= vr_log_nmdcampo || ' com.';
              END IF;
              --Pessoa Fisica
              IF rw_crapass.inpessoa = 1 THEN
                vr_log_nmdcampo:= vr_log_nmdcampo ||' '||pr_log_idseqttl||'.ttl';
              END IF;
              --InternetBanking
              IF pr_log_flencnet THEN
                vr_log_nmdcampo:= vr_log_nmdcampo || ' NET';
              END IF;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Bairro
            IF rw_crapenc.nmbairro <> pr_tab_log(vr_index).crapenc(1).nmbairro THEN
              --Nome do campo
              vr_log_nmdcampo:= 'bairro';
              --Recadastramento
              vr_log_flgrecad:= TRUE;
              --Endereco Comercial
              IF rw_crapenc.tpendass = 9 THEN
                vr_log_nmdcampo:= vr_log_nmdcampo || ' com.';
              END IF;
              --Pessoa Fisica
              IF rw_crapass.inpessoa = 1 THEN
                vr_log_nmdcampo:= vr_log_nmdcampo ||' '||pr_log_idseqttl||'.ttl';
              END IF;
              --InternetBanking
              IF pr_log_flencnet THEN
                vr_log_nmdcampo:= vr_log_nmdcampo || ' NET';
              END IF;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Cidade
            IF rw_crapenc.nmcidade <> pr_tab_log(vr_index).crapenc(1).nmcidade THEN
              --Nome do campo
              vr_log_nmdcampo:= 'cidade';
              --Recadastramento
              vr_log_flgrecad:= TRUE;
              --Endereco Comercial
              IF rw_crapenc.tpendass = 9 THEN
                vr_log_nmdcampo:= vr_log_nmdcampo || ' com.';
              END IF;
              --Pessoa Fisica
              IF rw_crapass.inpessoa = 1 THEN
                vr_log_nmdcampo:= vr_log_nmdcampo ||' '||pr_log_idseqttl||'.ttl';
              END IF;
              --InternetBanking
              IF pr_log_flencnet THEN
                vr_log_nmdcampo:= vr_log_nmdcampo || ' NET';
              END IF;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --UF
            IF rw_crapenc.cdufende <> pr_tab_log(vr_index).crapenc(1).cdufende THEN
              --Nome do campo
              vr_log_nmdcampo:= 'uf';
              --Recadastramento
              vr_log_flgrecad:= TRUE;
              --Endereco Comercial
              IF rw_crapenc.tpendass = 9 THEN
                vr_log_nmdcampo:= vr_log_nmdcampo || ' com.';
              END IF;
              --Pessoa Fisica
              IF rw_crapass.inpessoa = 1 THEN
                vr_log_nmdcampo:= vr_log_nmdcampo ||' '||pr_log_idseqttl||'.ttl';
              END IF;
              --InternetBanking
              IF pr_log_flencnet THEN
                vr_log_nmdcampo:= vr_log_nmdcampo || ' NET';
              END IF;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Caixa Postal
            IF rw_crapenc.nrcxapst <> pr_tab_log(vr_index).crapenc(1).nrcxapst THEN
              --Nome do campo
              vr_log_nmdcampo:= 'cxa.postal';
              --Recadastramento
              vr_log_flgrecad:= TRUE;
              --Endereco Comercial
              IF rw_crapenc.tpendass = 9 THEN
                vr_log_nmdcampo:= vr_log_nmdcampo || ' com.';
              END IF;
              --Pessoa Fisica
              IF rw_crapass.inpessoa = 1 THEN
                vr_log_nmdcampo:= vr_log_nmdcampo ||' '||pr_log_idseqttl||'.ttl';
              END IF;
              --InternetBanking
              IF pr_log_flencnet THEN
                vr_log_nmdcampo:= vr_log_nmdcampo || ' NET';
              END IF;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Atualizar Alteracao
            BEGIN
              UPDATE crapalt SET crapalt.flgctitg = vr_flgctitg
                                ,crapalt.cdoperad = pr_log_cdoperad
                                ,crapalt.dsaltera = vr_dsaltera
              WHERE crapalt.rowid = rw_crapalt.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic:= 0;
                vr_dscritic:= 'Erro ao atualizar crapalt. '||SQLERRM;
                --Sair
                RAISE vr_exc_erro;
            END;
            /* Se for atualizacao de endereco cadastrado no InternetBank,*/
            /* nao faz pergunta sobre recadastramento.                   */
            IF pr_log_flencnet THEN
              --Recadastramento
              vr_log_flgrecad:= FALSE;
            END IF;

          ELSIF NOT pr_flgcontas AND vr_index = 'CRAPJUR' THEN

            --Selecionar Informacoes Endereco
            OPEN cr_crapjur (pr_rowid => pr_tab_rowid(vr_index));
            FETCH cr_crapjur INTO rw_crapjur;
            CLOSE cr_crapjur;

            --Nome Fantasia
            IF rw_crapjur.nmfansia <> pr_tab_log(vr_index).crapjur(1).nmfansia THEN
              --Nome do campo
              vr_log_nmdcampo:= 'nome fantasia';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --natureza juridica
            IF rw_crapjur.natjurid <> pr_tab_log(vr_index).crapjur(1).natjurid THEN
              --Nome do campo
              vr_log_nmdcampo:= 'nat.jurid.';
              --Recadastramento
              vr_log_flgrecad:= TRUE;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Quantidade Filiais
            IF rw_crapjur.qtfilial <> pr_tab_log(vr_index).crapjur(1).qtfilial THEN
              --Nome do campo
              vr_log_nmdcampo:= 'qtd.filiais';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Quantidade Funcionarios
            IF rw_crapjur.qtfuncio <> pr_tab_log(vr_index).crapjur(1).qtfuncio THEN
              --Nome do campo
              vr_log_nmdcampo:= 'qtd.funcionarios';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Inicio Atividade
            IF rw_crapjur.dtiniatv <> pr_tab_log(vr_index).crapjur(1).dtiniatv THEN
              --Nome do campo
              vr_log_nmdcampo:= 'ini.ativ.';
              --Recadastramento
              vr_log_flgrecad:= TRUE;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Setor Economico
            IF rw_crapjur.cdseteco <> pr_tab_log(vr_index).crapjur(1).cdseteco THEN
              --Nome do campo
              vr_log_nmdcampo:= 'setor eco.';
              --Recadastramento
              vr_log_flgrecad:= TRUE;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Ramo Atividade
            IF rw_crapjur.cdrmativ <> pr_tab_log(vr_index).crapjur(1).cdrmativ THEN
              --Nome do campo
              vr_log_nmdcampo:= 'ramo ativ.';
              --Recadastramento
              vr_log_flgrecad:= TRUE;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Site
            IF rw_crapjur.dsendweb <> pr_tab_log(vr_index).crapjur(1).dsendweb THEN
              --Nome do campo
              vr_log_nmdcampo:= 'site';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Nome talao
            IF rw_crapjur.nmtalttl <> pr_tab_log(vr_index).crapjur(1).nmtalttl THEN
              --Nome do campo
              vr_log_nmdcampo:= 'nome talao';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;

            /* Verificacoes para o log da tela: CONTAS -> REGISTRO (juridica) */

            --Inscricao Estadual
            IF rw_crapjur.nrinsest <> pr_tab_log(vr_index).crapjur(1).nrinsest THEN
              --Nome do campo
              vr_log_nmdcampo:= 'insc.estadual';
              --Recadastramento
              vr_log_flgrecad:= TRUE;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            
            --Faturamento Anual
            IF rw_crapjur.vlfatano <> pr_tab_log(vr_index).crapjur(1).vlfatano THEN
              --Nome do campo
              vr_log_nmdcampo:= 'faturamento ano';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Capital Realizado
            IF rw_crapjur.vlcaprea <> pr_tab_log(vr_index).crapjur(1).vlcaprea THEN
              --Nome do campo
              vr_log_nmdcampo:= 'capital realizado';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Registro Empresa
            IF rw_crapjur.dtregemp <> pr_tab_log(vr_index).crapjur(1).dtregemp THEN
              --Nome do campo
              vr_log_nmdcampo:= 'data registro';
              --Recadastramento
              vr_log_flgrecad:= TRUE;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Numero Registro
            IF rw_crapjur.nrregemp <> pr_tab_log(vr_index).crapjur(1).nrregemp THEN
              --Nome do campo
              vr_log_nmdcampo:= 'nro.registro';
              --Recadastramento
              vr_log_flgrecad:= TRUE;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --orgao Registro
            IF rw_crapjur.orregemp <> pr_tab_log(vr_index).crapjur(1).orregemp THEN
              --Nome do campo
              vr_log_nmdcampo:= 'orgao registro';
              --Recadastramento
              vr_log_flgrecad:= TRUE;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Inscricao Municipal
            IF rw_crapjur.dtinsnum <> pr_tab_log(vr_index).crapjur(1).dtinsnum THEN
              --Nome do campo
              vr_log_nmdcampo:= 'dt.insc.municip.';
              --Recadastramento
              vr_log_flgrecad:= TRUE;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Numero inscricao municipal
            IF rw_crapjur.nrinsmun <> pr_tab_log(vr_index).crapjur(1).nrinsmun THEN
              --Nome do campo
              vr_log_nmdcampo:= 'nro.insc.municip.';
              --Recadastramento
              vr_log_flgrecad:= TRUE;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Optante REFIS
            IF rw_crapjur.flgrefis <> pr_tab_log(vr_index).crapjur(1).flgrefis THEN
              --Nome do campo
              vr_log_nmdcampo:= 'optante REFIS';
              --Recadastramento
              vr_log_flgrecad:= TRUE;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Numero NIRE
            IF rw_crapjur.nrcdnire <> pr_tab_log(vr_index).crapjur(1).nrcdnire THEN
              --Nome do campo
              vr_log_nmdcampo:= 'NIRE';
              --Recadastramento
              vr_log_flgrecad:= TRUE;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Atualizar Alteracao
            BEGIN
              UPDATE crapalt SET crapalt.flgctitg = vr_flgctitg
                                ,crapalt.cdoperad = pr_log_cdoperad
                                ,crapalt.dsaltera = vr_dsaltera
              WHERE crapalt.rowid = rw_crapalt.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic:= 0;
                vr_dscritic:= 'Erro ao atualizar crapalt. '||SQLERRM;
                --Sair
                RAISE vr_exc_erro;
            END;
          ELSIF NOT pr_flgcontas AND vr_index = 'CRAPTTL' THEN

            --Selecionar Informacoes Titular PF
            OPEN cr_crapttl (pr_rowid => pr_tab_rowid(vr_index));
            FETCH cr_crapttl INTO rw_crapttl;
            CLOSE cr_crapttl;

            --Consulta SPC
            IF rw_crapttl.dtcnscpf <> pr_tab_log(vr_index).crapttl(1).dtcnscpf THEN
              --Nome do campo
              vr_log_nmdcampo:= 'consulta cpf';
              --Recadastramento
              vr_log_flgrecad:= TRUE;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Situacao CPF
            IF rw_crapttl.cdsitcpf <> pr_tab_log(vr_index).crapttl(1).cdsitcpf THEN
              --Nome do campo
              vr_log_nmdcampo:= 'situacao cpf';
              --Recadastramento
              vr_log_flgrecad:= TRUE;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Tipo Documento
            IF rw_crapttl.tpdocttl <> pr_tab_log(vr_index).crapttl(1).tpdocttl THEN
              --Nome do campo
              vr_log_nmdcampo:= 'tipo doc.';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Numero Documento
            IF rw_crapttl.nrdocttl <> pr_tab_log(vr_index).crapttl(1).nrdocttl THEN
              --Nome do campo
              vr_log_nmdcampo:= 'doc.';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --orgao Emissor Documento
            IF rw_crapttl.idorgexp <> pr_tab_log(vr_index).crapttl(1).idorgexp THEN
              --Nome do campo
              vr_log_nmdcampo:= 'org.ems.doc.';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --UF Emissao doc
            IF rw_crapttl.cdufdttl <> pr_tab_log(vr_index).crapttl(1).cdufdttl THEN
              --Nome do campo
              vr_log_nmdcampo:= 'uf.ems.doc.';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Data Emissao Doc
            IF rw_crapttl.dtemdttl <> pr_tab_log(vr_index).crapttl(1).dtemdttl THEN
              --Nome do campo
              vr_log_nmdcampo:= 'dt.ems.doc.';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Data nascimento
            IF rw_crapttl.dtnasttl <> pr_tab_log(vr_index).crapttl(1).dtnasttl THEN
              --Nome do campo
              vr_log_nmdcampo:= 'nascto';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Sexo
            IF rw_crapttl.cdsexotl <> pr_tab_log(vr_index).crapttl(1).cdsexotl THEN
              --Nome do campo
              vr_log_nmdcampo:= 'sexo';
              --Recadastramento
              vr_log_flgrecad:= TRUE;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Tipo Nacionalidade
            IF rw_crapttl.tpnacion <> pr_tab_log(vr_index).crapttl(1).tpnacion THEN
              --Nome do campo
              vr_log_nmdcampo:= 'tipo nacion.';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Nacionalidade
            IF rw_crapttl.cdnacion <> pr_tab_log(vr_index).crapttl(1).cdnacion THEN
              --Nome do campo
              vr_log_nmdcampo:= 'nacion.';
              --Recadastramento
              vr_log_flgrecad:= TRUE;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Naturalidade
            IF rw_crapttl.dsnatura <> pr_tab_log(vr_index).crapttl(1).dsnatura THEN
              --Nome do campo
              vr_log_nmdcampo:= 'natural.';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --UF Naturalidade
            IF rw_crapttl.cdufnatu <> pr_tab_log(vr_index).crapttl(1).cdufnatu THEN
              --Nome do campo
              vr_log_nmdcampo:= 'uf natural.';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --habilitacao Menor
            IF rw_crapttl.inhabmen <> pr_tab_log(vr_index).crapttl(1).inhabmen THEN
              --Nome do campo
              vr_log_nmdcampo:= 'hab.menor';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Data Hab. Menor
            IF rw_crapttl.dthabmen <> pr_tab_log(vr_index).crapttl(1).dthabmen THEN
              --Nome do campo
              vr_log_nmdcampo:= 'data hab.menor';
              --Recadastramento
              vr_log_flgrecad:= TRUE;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Parentesco
            IF rw_crapttl.cdgraupr <> pr_tab_log(vr_index).crapttl(1).cdgraupr THEN
              --Nome do campo
              vr_log_nmdcampo:= 'parentesco';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Estado Civil
            IF rw_crapttl.cdestcvl <> pr_tab_log(vr_index).crapttl(1).cdestcvl THEN
              --Nome do campo
              vr_log_nmdcampo:= 'est.civil';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Escolaridade
            IF rw_crapttl.grescola <> pr_tab_log(vr_index).crapttl(1).grescola THEN
              --Nome do campo
              vr_log_nmdcampo:= 'escolaridade';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Formacao
            IF rw_crapttl.cdfrmttl <> pr_tab_log(vr_index).crapttl(1).cdfrmttl THEN
              --Nome do campo
              vr_log_nmdcampo:= 'formacao';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            
            --Nome Talao
            IF rw_crapttl.nmtalttl <> pr_tab_log(vr_index).crapttl(1).nmtalttl THEN
              --Nome do campo
              vr_log_nmdcampo:= 'nome talao';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;

            /* Verificacoes para o log da tela: CONTAS -> COMERCIAL */

            --Natureza Ocupacao
            IF rw_crapttl.cdnatopc <> pr_tab_log(vr_index).crapttl(1).cdnatopc THEN
              --Nome do campo
              vr_log_nmdcampo:= 'nat.ocupacao '||pr_log_idseqttl||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Ocupacao
            IF rw_crapttl.cdocpttl <> pr_tab_log(vr_index).crapttl(1).cdocpttl THEN
              --Nome do campo
              vr_log_nmdcampo:= 'ocupacao '||pr_log_idseqttl||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Tipo Contrato Trabalho
            IF rw_crapttl.tpcttrab <> pr_tab_log(vr_index).crapttl(1).tpcttrab THEN
              --Nome do campo
              vr_log_nmdcampo:= 'tp.ctr.trab '||pr_log_idseqttl||'.ttl';
              IF rw_crapttl.tpcttrab = 3 THEN  /* Sem Vinculo */
                vr_log_flgrecad:= FALSE;
              ELSE
                vr_log_flgrecad:= TRUE;
              END IF;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Empresa
            IF rw_crapttl.cdempres <> pr_tab_log(vr_index).crapttl(1).cdempres THEN
              --Nome do campo
              vr_log_nmdcampo:= 'empr.'||gene0002.fn_mask(pr_tab_log(vr_index).crapttl(1).cdempres,'99999')||
                                '-'||gene0002.fn_mask(rw_crapttl.cdempres,'99999')||' '||
                                pr_log_idseqttl||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Nome Empresa
            IF rw_crapttl.nmextemp <> pr_tab_log(vr_index).crapttl(1).nmextemp THEN
              --Nome do campo
              vr_log_nmdcampo:= 'nome empresa '||pr_log_idseqttl||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Cnpj Empresa
            IF rw_crapttl.nrcpfemp <> pr_tab_log(vr_index).crapttl(1).nrcpfemp THEN
              --Nome do campo
              vr_log_nmdcampo:= 'cnpj empresa '||pr_log_idseqttl||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Funcao
            IF rw_crapttl.dsproftl <> pr_tab_log(vr_index).crapttl(1).dsproftl THEN
              --Nome do campo
              vr_log_nmdcampo:= 'funcao '||pr_log_idseqttl||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --nivel Cargo
            IF rw_crapttl.cdnvlcgo <> pr_tab_log(vr_index).crapttl(1).cdnvlcgo THEN
              --Nome do campo
              vr_log_nmdcampo:= 'nivel cargo '||pr_log_idseqttl||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Cadastro
            IF rw_crapttl.nrcadast <> pr_tab_log(vr_index).crapttl(1).nrcadast THEN
              --Nome do campo
              vr_log_nmdcampo:= 'cadastro '||pr_log_idseqttl||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Turnos
            IF rw_crapttl.cdturnos <> pr_tab_log(vr_index).crapttl(1).cdturnos THEN
              --Nome do campo
              vr_log_nmdcampo:= 'turno '||pr_log_idseqttl||'.ttl';
              --Recadastramento
              vr_log_flgrecad:= TRUE;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Data Admissao
            IF rw_crapttl.dtadmemp <> pr_tab_log(vr_index).crapttl(1).dtadmemp THEN
              --Nome do campo
              vr_log_nmdcampo:= 'adm.empr. '||pr_log_idseqttl||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Salario
            IF rw_crapttl.vlsalari <> pr_tab_log(vr_index).crapttl(1).vlsalari THEN
              --Nome do campo
              vr_log_nmdcampo:= 'salario '||pr_log_idseqttl||'.ttl';
              --Recadastramento
              vr_log_flgrecad:= TRUE;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Tipo Renda
            IF (rw_crapttl.tpdrendi##1 <> pr_tab_log(vr_index).crapttl(1).tpdrendi##1) OR
               (rw_crapttl.tpdrendi##2 <> pr_tab_log(vr_index).crapttl(1).tpdrendi##2) OR
               (rw_crapttl.tpdrendi##3 <> pr_tab_log(vr_index).crapttl(1).tpdrendi##3) OR
               (rw_crapttl.tpdrendi##4 <> pr_tab_log(vr_index).crapttl(1).tpdrendi##4) THEN
              --Nome do campo
              vr_log_nmdcampo:= 'tip.ren. '||pr_log_idseqttl||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Valor Renda
            IF (rw_crapttl.vldrendi##1 <> pr_tab_log(vr_index).crapttl(1).vldrendi##1) OR
               (rw_crapttl.vldrendi##2 <> pr_tab_log(vr_index).crapttl(1).vldrendi##2) OR
               (rw_crapttl.vldrendi##3 <> pr_tab_log(vr_index).crapttl(1).vldrendi##3) OR
               (rw_crapttl.vldrendi##4 <> pr_tab_log(vr_index).crapttl(1).vldrendi##4) THEN
              --Nome do campo
              vr_log_nmdcampo:= 'valor ren. '||pr_log_idseqttl||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Justificativa Rendimento
            IF rw_crapttl.dsjusren <> pr_tab_log(vr_index).crapttl(1).dsjusren THEN
              --Nome do campo
              vr_log_nmdcampo:= 'justificativa rend. '||pr_log_idseqttl||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            /* Verificacoes para o log da tela: CONTAS -> INF. CADASTRAL */

            --Informacao Cadastral
            IF rw_crapttl.nrinfcad <> pr_tab_log(vr_index).crapttl(1).nrinfcad THEN
              --Nome do campo
              vr_log_nmdcampo:= 'inf.cadastral '||pr_log_idseqttl||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Patrimonio Livre
            IF rw_crapttl.nrpatlvr <> pr_tab_log(vr_index).crapttl(1).nrpatlvr THEN
              --Nome do campo
              vr_log_nmdcampo:= 'patr.livre '||pr_log_idseqttl||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Pessoa politicamente Exposta
            IF rw_crapttl.inpolexp <> pr_tab_log(vr_index).crapttl(1).inpolexp THEN
              --Nome do campo
              vr_log_nmdcampo:= 'P. politicamente exposta '||pr_log_idseqttl||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Atualizar Alteracao
            BEGIN
              UPDATE crapalt SET crapalt.flgctitg = vr_flgctitg
                                ,crapalt.cdoperad = pr_log_cdoperad
                                ,crapalt.dsaltera = vr_dsaltera
              WHERE crapalt.rowid = rw_crapalt.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic:= 0;
                vr_dscritic:= 'Erro ao atualizar crapalt. '||SQLERRM;
                --Sair
                RAISE vr_exc_erro;
            END;

          ELSIF NOT pr_flgcontas AND vr_index = 'CRAPAVT' THEN

            --Selecionar Informacoes Endereco
            OPEN cr_crapavt (pr_rowid => pr_tab_rowid(vr_index));
            FETCH cr_crapavt INTO rw_crapavt;
            CLOSE cr_crapavt;

            --Selecionar Informacoes Associado
            OPEN cr_crapass (pr_cdcooper => pr_log_cdcooper
                            ,pr_nrdconta => pr_log_nrdconta);
            FETCH cr_crapass INTO rw_crapass;
            CLOSE cr_crapass;

            /* REFERENCIAS (JURIDICA) E CONTATOS (FISICA)*/

            IF rw_crapavt.tpctrato = 5 THEN
              IF pr_log_cddopcao = 'E' THEN /* Exclusao */
                --Pessoa Fisica
                IF rw_crapass.inpessoa = 1 THEN
                  --Nome do campo
                  vr_log_nmdcampo:= 'Exc.Contato ';
                  --Se possui contato
                  IF nvl(pr_tab_log(vr_index).crapavt(1).nrdctato,0) <> 0 THEN
                    vr_log_nmdcampo:= vr_log_nmdcampo||
                                      gene0002.fn_mask(pr_tab_log(vr_index).crapavt(1).nrdctato,'zzzz.zzz.9');
                  ELSE
                    vr_log_nmdcampo:= vr_log_nmdcampo||gene0002.fn_busca_entrada(1,pr_tab_log(vr_index).crapavt(1).nmdavali,' ')||' '||
                                      pr_log_idseqttl||'.ttl';
                  END IF;
                ELSE
                  --Nome do campo
                  vr_log_nmdcampo:= 'Exc.Ref.';
                  --Se possui contato
                  IF nvl(pr_tab_log(vr_index).crapavt(1).nrdctato,0) <> 0 THEN
                    vr_log_nmdcampo:= vr_log_nmdcampo||
                                      gene0002.fn_mask(pr_tab_log(vr_index).crapavt(1).nrdctato,'zzzz.zzz.9');
                  ELSE
                    vr_log_nmdcampo:= vr_log_nmdcampo||gene0002.fn_busca_entrada(1,pr_tab_log(vr_index).crapavt(1).nmdavali,' ');
                  END IF;
                END IF;
                IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                  --Concatenar o campo alterado
                  vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
                END IF;
                --Atualizar Alteracao
                BEGIN
                  UPDATE crapalt SET crapalt.flgctitg = vr_flgctitg
                                    ,crapalt.cdoperad = pr_log_cdoperad
                                    ,crapalt.dsaltera = vr_dsaltera
                  WHERE crapalt.rowid = rw_crapalt.rowid;
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_cdcritic:= 0;
                    vr_dscritic:= 'Erro ao atualizar crapalt. '||SQLERRM;
                    --Sair
                    RAISE vr_exc_erro;
                END;
                EXIT;
              END IF;
              --Nome Avalista
              IF rw_crapavt.nmdavali <> pr_tab_log(vr_index).crapavt(1).nmdavali THEN
                --Pessoa Fisica
                IF rw_crapass.inpessoa = 1 THEN
                  --Nome do campo
                  vr_log_nmdcampo:= 'nome contato';
                ELSE
                  --Nome do campo
                  vr_log_nmdcampo:= 'nome ref.';
                END IF;
                --Verificar se o campo já estah na alteracao
                IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                  --Concatenar o campo alterado
                  vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
                END IF;
              END IF;
              --Nome Empresa
              IF rw_crapavt.nmextemp <> pr_tab_log(vr_index).crapavt(1).nmextemp THEN
                --Nome do campo
                vr_log_nmdcampo:= 'empresa ref.';
                --Verificar se o campo já estah na alteracao
                IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                  --Concatenar o campo alterado
                  vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
                END IF;
              END IF;
              --Codigo banco
              IF rw_crapavt.cddbanco <> pr_tab_log(vr_index).crapavt(1).cddbanco THEN
                --Nome do campo
                vr_log_nmdcampo:= 'banco ref.';
                --Verificar se o campo já estah na alteracao
                IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                  --Concatenar o campo alterado
                  vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
                END IF;
              END IF;
              --Codigo Agencia
              IF rw_crapavt.cdagenci <> pr_tab_log(vr_index).crapavt(1).cdagenci THEN
                --Nome do campo
                vr_log_nmdcampo:= 'age.ref.';
                --Verificar se o campo já estah na alteracao
                IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                  --Concatenar o campo alterado
                  vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
                END IF;
              END IF;
              --Profissao
              IF rw_crapavt.dsproftl <> pr_tab_log(vr_index).crapavt(1).dsproftl THEN
                --Nome do campo
                vr_log_nmdcampo:= 'profis.ref.';
                --Verificar se o campo já estah na alteracao
                IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                  --Concatenar o campo alterado
                  vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
                END IF;
              END IF;
              --CEP Endereco
              IF rw_crapavt.nrcepend <> pr_tab_log(vr_index).crapavt(1).nrcepend THEN
                --Pessoa Fisica
                IF rw_crapass.inpessoa = 1 THEN
                  --Nome do campo
                  vr_log_nmdcampo:= 'cep contato';
                ELSE
                  --Nome do campo
                  vr_log_nmdcampo:= 'cep ref.';
                  --Recadastramento
                  vr_log_flgrecad:= TRUE;
                END IF;
                --Verificar se o campo já estah na alteracao
                IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                  --Concatenar o campo alterado
                  vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
                END IF;
              END IF;
              --Descricao Endereco
              IF rw_crapavt.dsendres##1 <> pr_tab_log(vr_index).crapavt(1).dsendres##1 THEN
                --Pessoa Fisica
                IF rw_crapass.inpessoa = 1 THEN
                  --Nome do campo
                  vr_log_nmdcampo:= 'end.contato';
                ELSE
                  --Nome do campo
                  vr_log_nmdcampo:= 'end.ref.';
                  --Recadastramento
                  vr_log_flgrecad:= TRUE;
                END IF;
                --Verificar se o campo já estah na alteracao
                IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                  --Concatenar o campo alterado
                  vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
                END IF;
              END IF;
              --Numero Endereco
              IF rw_crapavt.nrendere <> pr_tab_log(vr_index).crapavt(1).nrendere THEN
                --Pessoa Fisica
                IF rw_crapass.inpessoa = 1 THEN
                  --Nome do campo
                  vr_log_nmdcampo:= 'nro.contato';
                ELSE
                  --Nome do campo
                  vr_log_nmdcampo:= 'nro.ref.';
                END IF;
                --Verificar se o campo já estah na alteracao
                IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                  --Concatenar o campo alterado
                  vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
                END IF;
              END IF;
              --Complemento Endereco
              IF rw_crapavt.complend <> pr_tab_log(vr_index).crapavt(1).complend THEN
                --Pessoa Fisica
                IF rw_crapass.inpessoa = 1 THEN
                  --Nome do campo
                  vr_log_nmdcampo:= 'complem.contato';
                ELSE
                  --Nome do campo
                  vr_log_nmdcampo:= 'complem.ref.';
                END IF;
                --Verificar se o campo já estah na alteracao
                IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                  --Concatenar o campo alterado
                  vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
                END IF;
              END IF;
              --Bairro
              IF rw_crapavt.nmbairro <> pr_tab_log(vr_index).crapavt(1).nmbairro THEN
                --Pessoa Fisica
                IF rw_crapass.inpessoa = 1 THEN
                  --Nome do campo
                  vr_log_nmdcampo:= 'bairro contato';
                ELSE
                  --Nome do campo
                  vr_log_nmdcampo:= 'bairro ref.';
                  --Recadastramento
                  vr_log_flgrecad:= TRUE;
                END IF;
                --Verificar se o campo já estah na alteracao
                IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                  --Concatenar o campo alterado
                  vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
                END IF;
              END IF;
              --Cidade
              IF rw_crapavt.nmcidade <> pr_tab_log(vr_index).crapavt(1).nmcidade THEN
                --Pessoa Fisica
                IF rw_crapass.inpessoa = 1 THEN
                  --Nome do campo
                  vr_log_nmdcampo:= 'cidade contato';
                ELSE
                  --Nome do campo
                  vr_log_nmdcampo:= 'cidade ref.';
                  --Recadastramento
                  vr_log_flgrecad:= TRUE;
                END IF;
                --Verificar se o campo já estah na alteracao
                IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                  --Concatenar o campo alterado
                  vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
                END IF;
              END IF;
              --UF
              IF rw_crapavt.cdufresd <> pr_tab_log(vr_index).crapavt(1).cdufresd THEN
                --Pessoa Fisica
                IF rw_crapass.inpessoa = 1 THEN
                  --Nome do campo
                  vr_log_nmdcampo:= 'uf contato';
                ELSE
                  --Nome do campo
                  vr_log_nmdcampo:= 'uf ref.';
                  --Recadastramento
                  vr_log_flgrecad:= TRUE;
                END IF;
                --Verificar se o campo já estah na alteracao
                IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                  --Concatenar o campo alterado
                  vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
                END IF;
              END IF;
              --Caixa Postal
              IF rw_crapavt.nrcxapst <> pr_tab_log(vr_index).crapavt(1).nrcxapst THEN
                --Pessoa Fisica
                IF rw_crapass.inpessoa = 1 THEN
                  --Nome do campo
                  vr_log_nmdcampo:= 'cxa.pst.contato';
                ELSE
                  --Nome do campo
                  vr_log_nmdcampo:= 'cxa.pst.ref.';
                END IF;
                --Verificar se o campo já estah na alteracao
                IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                  --Concatenar o campo alterado
                  vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
                END IF;
              END IF;
              --Numero telefone
              IF rw_crapavt.nrtelefo <> pr_tab_log(vr_index).crapavt(1).nrtelefo THEN
                --Pessoa Fisica
                IF rw_crapass.inpessoa = 1 THEN
                  --Nome do campo
                  vr_log_nmdcampo:= 'fone contato';
                ELSE
                  --Nome do campo
                  vr_log_nmdcampo:= 'fone ref.';
                END IF;
                --Verificar se o campo já estah na alteracao
                IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                  --Concatenar o campo alterado
                  vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
                END IF;
              END IF;
              --Email
              IF rw_crapavt.dsdemail <> pr_tab_log(vr_index).crapavt(1).dsdemail THEN
                --Pessoa Fisica
                IF rw_crapass.inpessoa = 1 THEN
                  --Nome do campo
                  vr_log_nmdcampo:= 'email contato';
                ELSE
                  --Nome do campo
                  vr_log_nmdcampo:= 'email ref.';
                END IF;
                --Verificar se o campo já estah na alteracao
                IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                  --Concatenar o campo alterado
                  vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
                END IF;
              END IF;
              --Atualizar Alteracao
              BEGIN
                UPDATE crapalt SET crapalt.flgctitg = vr_flgctitg
                                  ,crapalt.cdoperad = pr_log_cdoperad
                                  ,crapalt.dsaltera = vr_dsaltera
                WHERE crapalt.rowid = rw_crapalt.rowid;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_cdcritic:= 0;
                  vr_dscritic:= 'Erro ao atualizar crapalt. '||SQLERRM;
                  --Sair
                  RAISE vr_exc_erro;
              END;
            END IF;

          ELSIF NOT pr_flgcontas AND vr_index = 'CRAPCRL' THEN

            --Selecionar Informacoes Endereco
            OPEN cr_crapcrl (pr_rowid => pr_tab_rowid(vr_index));
            FETCH cr_crapcrl INTO rw_crapcrl;
            CLOSE cr_crapcrl;

            /*Verificacoes para o log da tela: CONTAS -> RESPONSAVEL LEGAL(fisica)*/

            IF pr_log_cddopcao = 'E' THEN /* Exclusao */
              --Nome do campo
              vr_log_nmdcampo:= 'Exc.Resp. ';
              --Se possui contato
              IF nvl(pr_tab_log(vr_index).crapcrl(1).nrdconta,0) <> 0 THEN
                vr_log_nmdcampo:= vr_log_nmdcampo||
                                  gene0002.fn_mask(pr_tab_log(vr_index).crapcrl(1).nrdconta,'zzzz.zzz.9');
              ELSE
                vr_log_nmdcampo:= vr_log_nmdcampo||gene0002.fn_busca_entrada(1,pr_tab_log(vr_index).crapcrl(1).nmrespon,' ')||' '||
                                  pr_log_idseqttl||'.ttl';
              END IF;
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
              --Atualizar Alteracao
              BEGIN
                UPDATE crapalt SET crapalt.flgctitg = vr_flgctitg
                                  ,crapalt.cdoperad = pr_log_cdoperad
                                  ,crapalt.dsaltera = vr_dsaltera
                WHERE crapalt.rowid = rw_crapalt.rowid;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_cdcritic:= 0;
                  vr_dscritic:= 'Erro ao atualizar crapalt. '||SQLERRM;
                  --Sair
                  RAISE vr_exc_erro;
              END;
              EXIT;
            END IF;
            --Cooperativa
            IF rw_crapcrl.cdcooper <> pr_tab_log(vr_index).crapcrl(1).cdcooper THEN
              --Nome do campo
              vr_log_nmdcampo:= 'cooperativa '||pr_tab_log(vr_index).crapcrl(1).idseqmen||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Numero Conta
            IF rw_crapcrl.nrctamen <> pr_tab_log(vr_index).crapcrl(1).nrctamen THEN
              --Nome do campo
              vr_log_nmdcampo:= 'conta tit/proc. '||pr_tab_log(vr_index).crapcrl(1).idseqmen||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Numero CPF
            IF rw_crapcrl.nrcpfmen <> pr_tab_log(vr_index).crapcrl(1).nrcpfmen THEN
              --Nome do campo
              vr_log_nmdcampo:= 'cpf tit/proc. '||pr_tab_log(vr_index).crapcrl(1).idseqmen||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Sequencial titular/procurador
            IF rw_crapcrl.idseqmen <> pr_tab_log(vr_index).crapcrl(1).idseqmen THEN
              --Nome do campo
              vr_log_nmdcampo:= 'sequencial tit/proc. '||pr_tab_log(vr_index).crapcrl(1).idseqmen||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Numero da Conta
            IF rw_crapcrl.nrdconta <> pr_tab_log(vr_index).crapcrl(1).nrdconta THEN
              --Nome do campo
              vr_log_nmdcampo:= 'conta resp. '||pr_tab_log(vr_index).crapcrl(1).idseqmen||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Numero CPF
            IF rw_crapcrl.nrcpfcgc <> pr_tab_log(vr_index).crapcrl(1).nrcpfcgc THEN
              --Nome do campo
              vr_log_nmdcampo:= 'cpf resp. '||pr_tab_log(vr_index).crapcrl(1).idseqmen||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Nome responsavel
            IF rw_crapcrl.nmrespon <> pr_tab_log(vr_index).crapcrl(1).nmrespon THEN
              --Nome do campo
              vr_log_nmdcampo:= 'nome resp. '||pr_tab_log(vr_index).crapcrl(1).idseqmen||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Numero Identidade
            IF rw_crapcrl.nridenti <> pr_tab_log(vr_index).crapcrl(1).nridenti THEN
              --Nome do campo
              vr_log_nmdcampo:= 'identidade. '||pr_tab_log(vr_index).crapcrl(1).idseqmen||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Tipo Documento
            IF rw_crapcrl.tpdeiden <> pr_tab_log(vr_index).crapcrl(1).tpdeiden THEN
              --Nome do campo
              vr_log_nmdcampo:= 'tipo doc. '||pr_tab_log(vr_index).crapcrl(1).idseqmen||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --orgao Emissor Documento
            IF rw_crapcrl.idorgexp <> pr_tab_log(vr_index).crapcrl(1).idorgexp THEN
              --Nome do campo
              vr_log_nmdcampo:= 'org emi doc. '||pr_tab_log(vr_index).crapcrl(1).idseqmen||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --UF Documento
            IF rw_crapcrl.cdufiden <> pr_tab_log(vr_index).crapcrl(1).cdufiden THEN
              --Nome do campo
              vr_log_nmdcampo:= 'uf doc. '||pr_tab_log(vr_index).crapcrl(1).idseqmen||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Data Emissao Documento
            IF rw_crapcrl.dtemiden <> pr_tab_log(vr_index).crapcrl(1).dtemiden THEN
              --Nome do campo
              vr_log_nmdcampo:= 'data emissao doc. '||pr_tab_log(vr_index).crapcrl(1).idseqmen||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Data nascimento
            IF rw_crapcrl.dtnascin <> pr_tab_log(vr_index).crapcrl(1).dtnascin THEN
              --Nome do campo
              vr_log_nmdcampo:= 'data nascimento. '||pr_tab_log(vr_index).crapcrl(1).idseqmen||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Sexo
            IF rw_crapcrl.cddosexo <> pr_tab_log(vr_index).crapcrl(1).cddosexo THEN
              --Nome do campo
              vr_log_nmdcampo:= 'sexo. '||pr_tab_log(vr_index).crapcrl(1).idseqmen||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Estado Civil
            IF rw_crapcrl.cdestciv <> pr_tab_log(vr_index).crapcrl(1).cdestciv THEN
              --Nome do campo
              vr_log_nmdcampo:= 'estado civil. '||pr_tab_log(vr_index).crapcrl(1).idseqmen||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --nacionalidade
            IF rw_crapcrl.cdnacion <> pr_tab_log(vr_index).crapcrl(1).cdnacion THEN
              --Nome do campo
              vr_log_nmdcampo:= 'nacionalidade. '||pr_tab_log(vr_index).crapcrl(1).idseqmen||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --naturalidade
            IF rw_crapcrl.dsnatura <> pr_tab_log(vr_index).crapcrl(1).dsnatura THEN
              --Nome do campo
              vr_log_nmdcampo:= 'naturalidade. '||pr_tab_log(vr_index).crapcrl(1).idseqmen||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Cep Residencial
            IF rw_crapcrl.cdcepres <> pr_tab_log(vr_index).crapcrl(1).cdcepres THEN
              --Nome do campo
              vr_log_nmdcampo:= 'cep residencial. '||pr_tab_log(vr_index).crapcrl(1).idseqmen||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Endereco Residencial
            IF rw_crapcrl.dsendres <> pr_tab_log(vr_index).crapcrl(1).dsendres THEN
              --Nome do campo
              vr_log_nmdcampo:= 'endreco residencial. '||pr_tab_log(vr_index).crapcrl(1).idseqmen||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Numero Endereco
            IF rw_crapcrl.nrendres <> pr_tab_log(vr_index).crapcrl(1).nrendres THEN
              --Nome do campo
              vr_log_nmdcampo:= 'numero residencial. '||pr_tab_log(vr_index).crapcrl(1).idseqmen||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Complemento Endereco
            IF rw_crapcrl.dscomres <> pr_tab_log(vr_index).crapcrl(1).dscomres THEN
              --Nome do campo
              vr_log_nmdcampo:= 'complemento residencial. '||pr_tab_log(vr_index).crapcrl(1).idseqmen||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Bairro
            IF rw_crapcrl.dsbaires <> pr_tab_log(vr_index).crapcrl(1).dsbaires THEN
              --Nome do campo
              vr_log_nmdcampo:= 'bairro. '||pr_tab_log(vr_index).crapcrl(1).idseqmen||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Caixa Postal
            IF rw_crapcrl.nrcxpost <> pr_tab_log(vr_index).crapcrl(1).nrcxpost THEN
              --Nome do campo
              vr_log_nmdcampo:= 'caixa postal. '||pr_tab_log(vr_index).crapcrl(1).idseqmen||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Cidade Residencia
            IF rw_crapcrl.dscidres <> pr_tab_log(vr_index).crapcrl(1).dscidres THEN
              --Nome do campo
              vr_log_nmdcampo:= 'cidade. '||pr_tab_log(vr_index).crapcrl(1).idseqmen||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --UF Residencia
            IF rw_crapcrl.dsdufres <> pr_tab_log(vr_index).crapcrl(1).dsdufres THEN
              --Nome do campo
              vr_log_nmdcampo:= 'uf. '||pr_tab_log(vr_index).crapcrl(1).idseqmen||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Nome Pai
            IF rw_crapcrl.nmpairsp <> pr_tab_log(vr_index).crapcrl(1).nmpairsp THEN
              --Nome do campo
              vr_log_nmdcampo:= 'nome pai. '||pr_tab_log(vr_index).crapcrl(1).idseqmen||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Nome Mae
            IF rw_crapcrl.nmmaersp <> pr_tab_log(vr_index).crapcrl(1).nmmaersp THEN
              --Nome do campo
              vr_log_nmdcampo:= 'nome mae. '||pr_tab_log(vr_index).crapcrl(1).idseqmen||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;

            --Atualizar Alteracao
            BEGIN
              UPDATE crapalt SET crapalt.flgctitg = vr_flgctitg
                                ,crapalt.cdoperad = pr_log_cdoperad
                                ,crapalt.dsaltera = vr_dsaltera
              WHERE crapalt.rowid = rw_crapalt.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic:= 0;
                vr_dscritic:= 'Erro ao atualizar crapalt. '||SQLERRM;
                --Sair
                RAISE vr_exc_erro;
            END;

          ELSIF NOT pr_flgcontas AND vr_index = 'CRAPCJE' THEN

            --Selecionar Informacoes Endereco
            OPEN cr_crapcje (pr_rowid => pr_tab_rowid(vr_index));
            FETCH cr_crapcje INTO rw_crapcje;
            CLOSE cr_crapcje;

            /* Verificacoes para o log da tela: CONTAS -> CONJUGE (fisica) */

            --Conta Conjuge
            IF rw_crapcje.nrctacje <> pr_tab_log(vr_index).crapcje(1).nrctacje THEN
              --Nome do campo
              vr_log_nmdcampo:= 'conta cje';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Nome Conjuge
            IF rw_crapcje.nmconjug <> pr_tab_log(vr_index).crapcje(1).nmconjug THEN
              --Nome do campo
              vr_log_nmdcampo:= 'nome cje';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Cpf Conjuge
            IF rw_crapcje.nrcpfcjg <> pr_tab_log(vr_index).crapcje(1).nrcpfcjg THEN
              --Nome do campo
              vr_log_nmdcampo:= 'nro cpf cje';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Nascimento Conjuge
            IF rw_crapcje.dtnasccj <> pr_tab_log(vr_index).crapcje(1).dtnasccj THEN
              --Nome do campo
              vr_log_nmdcampo:= 'nasc. cje';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Tipo Documento Conjuge
            IF rw_crapcje.tpdoccje <> pr_tab_log(vr_index).crapcje(1).tpdoccje THEN
              --Nome do campo
              vr_log_nmdcampo:= 'tipo doc.cje';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Numero Doc. Conjuge
            IF rw_crapcje.nrdoccje <> pr_tab_log(vr_index).crapcje(1).nrdoccje THEN
              --Nome do campo
              vr_log_nmdcampo:= 'nro doc.cje';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --orgao Emissor Conjuge
            IF rw_crapcje.idorgexp <> pr_tab_log(vr_index).crapcje(1).idorgexp THEN
              --Nome do campo
              vr_log_nmdcampo:= 'org.emiss.cje';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --UF Conjuge
            IF rw_crapcje.cdufdcje <> pr_tab_log(vr_index).crapcje(1).cdufdcje THEN
              --Nome do campo
              vr_log_nmdcampo:= 'UF cje';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Data Emissao Doc. Conjuge
            IF rw_crapcje.dtemdcje <> pr_tab_log(vr_index).crapcje(1).dtemdcje THEN
              --Nome do campo
              vr_log_nmdcampo:= 'dt.emiss.doc.cje';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Grau Escolaridade Conjuge
            IF rw_crapcje.grescola <> pr_tab_log(vr_index).crapcje(1).grescola THEN
              --Nome do campo
              vr_log_nmdcampo:= 'grau escolar cje';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Formacao Conjuge
            IF rw_crapcje.cdfrmttl <> pr_tab_log(vr_index).crapcje(1).cdfrmttl THEN
              --Nome do campo
              vr_log_nmdcampo:= 'formacao cje';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Naturalidade
            IF rw_crapcje.cdnatopc <> pr_tab_log(vr_index).crapcje(1).cdnatopc THEN
              --Nome do campo
              vr_log_nmdcampo:= 'natural.cje';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Ocupacao Conjuge
            IF rw_crapcje.cdocpcje <> pr_tab_log(vr_index).crapcje(1).cdocpcje THEN
              --Nome do campo
              vr_log_nmdcampo:= 'ocup.cje';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Contrato Trabalhista Conjuge
            IF rw_crapcje.tpcttrab <> pr_tab_log(vr_index).crapcje(1).tpcttrab THEN
              --Nome do campo
              vr_log_nmdcampo:= 'ctrato trab.cje';
              IF rw_crapcje.tpcttrab = 3 THEN  /* Sem Vinculo */
                vr_log_flgrecad:= FALSE;
              ELSE
                vr_log_flgrecad:= TRUE;
              END IF;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Empresa Conjuge
            IF rw_crapcje.nmextemp <> pr_tab_log(vr_index).crapcje(1).nmextemp THEN
              --Nome do campo
              vr_log_nmdcampo:= 'empresa cje';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Cnpj Empresa Conjuge
            IF rw_crapcje.nrdocnpj <> pr_tab_log(vr_index).crapcje(1).nrdocnpj THEN
              --Nome do campo
              vr_log_nmdcampo:= 'CNPJ empr.cje';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Funcao Conjuge
            IF rw_crapcje.dsproftl <> pr_tab_log(vr_index).crapcje(1).dsproftl THEN
              --Nome do campo
              vr_log_nmdcampo:= 'funcao cje';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Nivel Cargo Conjuge
            IF rw_crapcje.cdnvlcgo <> pr_tab_log(vr_index).crapcje(1).cdnvlcgo THEN
              --Nome do campo
              vr_log_nmdcampo:= 'nvl cargo cje';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Fone Empresa Conjuge
            IF rw_crapcje.nrfonemp <> pr_tab_log(vr_index).crapcje(1).nrfonemp THEN
              --Nome do campo
              vr_log_nmdcampo:= 'fone empr.cje';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Numero Ramal Conjuge
            IF rw_crapcje.nrramemp <> pr_tab_log(vr_index).crapcje(1).nrramemp THEN
              --Nome do campo
              vr_log_nmdcampo:= 'ramal empr.cje';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Turno Conjuge
            IF rw_crapcje.cdturnos <> pr_tab_log(vr_index).crapcje(1).cdturnos THEN
              --Nome do campo
              vr_log_nmdcampo:= 'turno cje';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Data Admissao Conjuge
            IF rw_crapcje.dtadmemp <> pr_tab_log(vr_index).crapcje(1).dtadmemp THEN
              --Nome do campo
              vr_log_nmdcampo:= 'dt admiss.cje';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Salario Conjuge
            IF rw_crapcje.vlsalari <> pr_tab_log(vr_index).crapcje(1).vlsalari THEN
              --Nome do campo
              vr_log_nmdcampo:= 'sal. cje';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Atualizar Alteracao
            BEGIN
              UPDATE crapalt SET crapalt.flgctitg = vr_flgctitg
                                ,crapalt.cdoperad = pr_log_cdoperad
                                ,crapalt.dsaltera = vr_dsaltera
              WHERE crapalt.rowid = rw_crapalt.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic:= 0;
                vr_dscritic:= 'Erro ao atualizar crapalt. '||SQLERRM;
                --Sair
                RAISE vr_exc_erro;
            END;

          ELSIF NOT pr_flgcontas AND vr_index = 'CRAPDEP' THEN

            --Selecionar Informacoes Dependentes
            OPEN cr_crapdep (pr_rowid => pr_tab_rowid(vr_index));
            FETCH cr_crapdep INTO rw_crapdep;
            CLOSE cr_crapdep;

            /* Verificacoes para o log da tela: CONTAS -> DEPENDENTES */

            IF pr_log_cddopcao = 'E' THEN /* Exclusao Dependentes */
              --Nome do campo
              vr_log_nmdcampo:= 'Exc.dep.'||gene0002.fn_busca_entrada(1,pr_tab_log(vr_index).crapdep(1).nmdepend,' ')||' '||
                                  pr_log_idseqttl||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Data Nascimento
            IF rw_crapdep.dtnascto <> pr_tab_log(vr_index).crapdep(1).dtnascto THEN
              --Nome do campo
              vr_log_nmdcampo:= 'dt.nasc.';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Tipo Dependente
            IF rw_crapdep.tpdepend <> pr_tab_log(vr_index).crapdep(1).tpdepend THEN
              --Nome do campo
              vr_log_nmdcampo:= 'tp.dep.'||pr_tab_log(vr_index).crapdep(1).tpdepend||'-'||
                                rw_crapdep.tpdepend;
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Atualizar Alteracao
            BEGIN
              UPDATE crapalt SET crapalt.flgctitg = vr_flgctitg
                                ,crapalt.cdoperad = pr_log_cdoperad
                                ,crapalt.dsaltera = vr_dsaltera
              WHERE crapalt.rowid = rw_crapalt.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic:= 0;
                vr_dscritic:= 'Erro ao atualizar crapalt. '||SQLERRM;
                --Sair
                RAISE vr_exc_erro;
            END;

          ELSIF NOT pr_flgcontas AND vr_index = 'CRAPBEM' THEN

            --Selecionar Informacoes Bens
            OPEN cr_crapbem (pr_rowid => pr_tab_rowid(vr_index));
            FETCH cr_crapbem INTO rw_crapbem;
            CLOSE cr_crapbem;

            /* Log dos bens do cooperado */

            IF pr_log_cddopcao = 'E' THEN /* Exclusao Dependentes */
              --Nome do campo
              vr_log_nmdcampo:= 'Exc. do bem '||rw_crapbem.dsrelbem||' '||pr_log_idseqttl||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Descricao bem
            IF rw_crapbem.dsrelbem <> pr_tab_log(vr_index).crapbem(1).dsrelbem THEN
              --Nome do campo
              vr_log_nmdcampo:= 'Descricao do bem '||pr_tab_log(vr_index).crapbem(1).dsrelbem||'-'||
                                rw_crapbem.dsrelbem||' '||pr_log_idseqttl||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Percentual Sem onus
            IF rw_crapbem.persemon <> pr_tab_log(vr_index).crapbem(1).persemon THEN
              --Nome do campo
              vr_log_nmdcampo:= pr_tab_log(vr_index).crapbem(1).dsrelbem||': '||
                                'Percentual s/ onus '||
                                gene0002.fn_mask(pr_tab_log(vr_index).crapbem(1).persemon,'zz9.99')||
                                ' - '||
                                gene0002.fn_mask(rw_crapbem.persemon,'zz9.99')||' '||
                                pr_log_idseqttl||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --parcelas do Bem
            IF rw_crapbem.qtprebem <> pr_tab_log(vr_index).crapbem(1).qtprebem THEN
              --Nome do campo
              vr_log_nmdcampo:= pr_tab_log(vr_index).crapbem(1).dsrelbem||': '||
                                'Parcelas '||
                                gene0002.fn_mask(pr_tab_log(vr_index).crapbem(1).qtprebem,'zz9.99')||
                                ' - '||
                                gene0002.fn_mask(rw_crapbem.qtprebem,'zz9.99')||' '||
                                pr_log_idseqttl||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Valor parcela do Bem
            IF rw_crapbem.vlprebem <> pr_tab_log(vr_index).crapbem(1).vlprebem THEN
              --Nome do campo
              vr_log_nmdcampo:= pr_tab_log(vr_index).crapbem(1).dsrelbem||': '||
                                'Valor Parcela '||
                                to_char(pr_tab_log(vr_index).crapbem(1).vlprebem,'fm999g990d00')||
                                ' - '||
                                to_char(rw_crapbem.vlprebem,'fm999g990d00')||' '||
                                pr_log_idseqttl||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Valor do Bem
            IF rw_crapbem.vlrdobem <> pr_tab_log(vr_index).crapbem(1).vlrdobem THEN
              --Nome do campo
              vr_log_nmdcampo:= pr_tab_log(vr_index).crapbem(1).dsrelbem||': '||
                                'Valor Bem '||
                                to_char(pr_tab_log(vr_index).crapbem(1).vlrdobem,'fm999g990d00')||
                                ' - '||
                                to_char(rw_crapbem.vlrdobem,'fm999g990d00')||' '||
                                pr_log_idseqttl||'.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Atualizar Alteracao
            BEGIN
              UPDATE crapalt SET crapalt.flgctitg = vr_flgctitg
                                ,crapalt.cdoperad = pr_log_cdoperad
                                ,crapalt.dsaltera = vr_dsaltera
              WHERE crapalt.rowid = rw_crapalt.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic:= 0;
                vr_dscritic:= 'Erro ao atualizar crapalt. '||SQLERRM;
                --Sair
                RAISE vr_exc_erro;
            END;

          ELSIF NOT pr_flgcontas AND vr_index = 'CRAPJFN' THEN

            --Selecionar Informacoes Faturamento
            OPEN cr_crapjfn (pr_rowid => pr_tab_rowid(vr_index));
            FETCH cr_crapjfn INTO rw_crapjfn;
            CLOSE cr_crapjfn;

            --Faturamento unico
            IF rw_crapjfn.perfatcl <> pr_tab_log(vr_index).crapjfn(1).perfatcl THEN
              --Nome do campo
              vr_log_nmdcampo:= 'Concentracao faturamento unico cliente 1.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;

            /* Se alterado qualquer um desses loga alteracao de faturamento */
            IF rw_crapjfn.mesftbru##1 <> pr_tab_log(vr_index).crapjfn(1).mesftbru##1 OR
               rw_crapjfn.mesftbru##2 <> pr_tab_log(vr_index).crapjfn(1).mesftbru##2 OR
               rw_crapjfn.mesftbru##3 <> pr_tab_log(vr_index).crapjfn(1).mesftbru##3 OR
               rw_crapjfn.mesftbru##4 <> pr_tab_log(vr_index).crapjfn(1).mesftbru##4 OR
               rw_crapjfn.mesftbru##5 <> pr_tab_log(vr_index).crapjfn(1).mesftbru##5 OR
               rw_crapjfn.mesftbru##6 <> pr_tab_log(vr_index).crapjfn(1).mesftbru##6 OR
               rw_crapjfn.mesftbru##7 <> pr_tab_log(vr_index).crapjfn(1).mesftbru##7 OR
               rw_crapjfn.mesftbru##8 <> pr_tab_log(vr_index).crapjfn(1).mesftbru##8 OR
               rw_crapjfn.mesftbru##9 <> pr_tab_log(vr_index).crapjfn(1).mesftbru##9 OR
               rw_crapjfn.mesftbru##10 <> pr_tab_log(vr_index).crapjfn(1).mesftbru##10 OR
               rw_crapjfn.mesftbru##11 <> pr_tab_log(vr_index).crapjfn(1).mesftbru##11 OR
               rw_crapjfn.mesftbru##12 <> pr_tab_log(vr_index).crapjfn(1).mesftbru##12 OR
               rw_crapjfn.anoftbru##1 <> pr_tab_log(vr_index).crapjfn(1).anoftbru##1 OR
               rw_crapjfn.anoftbru##2 <> pr_tab_log(vr_index).crapjfn(1).anoftbru##2 OR
               rw_crapjfn.anoftbru##3 <> pr_tab_log(vr_index).crapjfn(1).anoftbru##3 OR
               rw_crapjfn.anoftbru##4 <> pr_tab_log(vr_index).crapjfn(1).anoftbru##4 OR
               rw_crapjfn.anoftbru##5 <> pr_tab_log(vr_index).crapjfn(1).anoftbru##5 OR
               rw_crapjfn.anoftbru##6 <> pr_tab_log(vr_index).crapjfn(1).anoftbru##6 OR
               rw_crapjfn.anoftbru##7 <> pr_tab_log(vr_index).crapjfn(1).anoftbru##7 OR
               rw_crapjfn.anoftbru##8 <> pr_tab_log(vr_index).crapjfn(1).anoftbru##8 OR
               rw_crapjfn.anoftbru##9 <> pr_tab_log(vr_index).crapjfn(1).anoftbru##9 OR
               rw_crapjfn.anoftbru##10 <> pr_tab_log(vr_index).crapjfn(1).anoftbru##10 OR
               rw_crapjfn.anoftbru##11 <> pr_tab_log(vr_index).crapjfn(1).anoftbru##11 OR
               rw_crapjfn.anoftbru##12 <> pr_tab_log(vr_index).crapjfn(1).anoftbru##12 OR
               rw_crapjfn.vlrftbru##1 <> pr_tab_log(vr_index).crapjfn(1).vlrftbru##1 OR
               rw_crapjfn.vlrftbru##2 <> pr_tab_log(vr_index).crapjfn(1).vlrftbru##2 OR
               rw_crapjfn.vlrftbru##3 <> pr_tab_log(vr_index).crapjfn(1).vlrftbru##3 OR
               rw_crapjfn.vlrftbru##4 <> pr_tab_log(vr_index).crapjfn(1).vlrftbru##4 OR
               rw_crapjfn.vlrftbru##5 <> pr_tab_log(vr_index).crapjfn(1).vlrftbru##5 OR
               rw_crapjfn.vlrftbru##6 <> pr_tab_log(vr_index).crapjfn(1).vlrftbru##6 OR
               rw_crapjfn.vlrftbru##7 <> pr_tab_log(vr_index).crapjfn(1).vlrftbru##7 OR
               rw_crapjfn.vlrftbru##8 <> pr_tab_log(vr_index).crapjfn(1).vlrftbru##8 OR
               rw_crapjfn.vlrftbru##9 <> pr_tab_log(vr_index).crapjfn(1).vlrftbru##9 OR
               rw_crapjfn.vlrftbru##10 <> pr_tab_log(vr_index).crapjfn(1).vlrftbru##10 OR
               rw_crapjfn.vlrftbru##11 <> pr_tab_log(vr_index).crapjfn(1).vlrftbru##11 OR
               rw_crapjfn.vlrftbru##12 <> pr_tab_log(vr_index).crapjfn(1).vlrftbru##12 THEN
              --Nome do campo
              vr_log_nmdcampo:= 'Faturamento medio bruto mensal 1.ttl';
              --Verificar se o campo já estah na alteracao
              IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
                --Concatenar o campo alterado
                vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              END IF;
            END IF;
            --Atualizar Alteracao
            BEGIN
              UPDATE crapalt SET crapalt.flgctitg = vr_flgctitg
                                ,crapalt.cdoperad = pr_log_cdoperad
                                ,crapalt.dsaltera = vr_dsaltera
              WHERE crapalt.rowid = rw_crapalt.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic:= 0;
                vr_dscritic:= 'Erro ao atualizar crapalt. '||SQLERRM;
                --Sair
                RAISE vr_exc_erro;
            END;
            --Sair
            EXIT;
          END IF;
          --Proximo registro
           vr_index:= pr_tab_rowid.NEXT(vr_index);
        END LOOP; --Vetor Rowids

        --Tela Mantal
        IF pr_flgmantal THEN
          /****** LOG DAS ALTERACOES FEITAS PELA TELA MANTAL *******/
          IF trim(pr_log_cddopcao) IS NOT NULL AND
             nvl(pr_log_nrdctabb,0) <> 0 AND
             nvl(pr_log_nrdocmto,0) <> 0 THEN
            --Baixa
            IF pr_log_cddopcao = 'B' THEN
              vr_log_desopcao:= 'canc.chq.  ';
            ELSE
              vr_log_desopcao:= 'libr.chq.  ';
            END IF;
            --Nome Campo
            vr_log_nmdcampo:= vr_log_desopcao ||gene0002.fn_mask_conta(pr_log_nrdocmto)||
                              ' cta base '||gene0002.fn_mask(pr_log_nrdctabb,'zzzz.zzz.9');
            --Verificar se o campo já estah na alteracao
            IF INSTR(vr_dsaltera,vr_log_nmdcampo) = 0 THEN
              /* corrigir o registro, pois este log exige que o
                tamanho dele seja 41 para mostrar correto na tela altera */
              --Quantidade Linhas
              vr_log_qtlinhas:= LENGTH(vr_dsaltera) / 41;
              --Quantidade Letras
              vr_log_qtletras:= vr_log_qtlinhas * 41;
              --Quantidade letras menor tamanho alteracao
              IF  vr_log_qtletras < LENGTH(vr_dsaltera) THEN
                --Incrementa linha
                vr_log_qtlinhas:= vr_log_qtlinhas + 1;
                --Encontra qdade letras
                vr_log_qtletras:= vr_log_qtlinhas * 41;
              END IF;
              --Se quantidade letras diferente zero
              IF nvl(vr_log_qtletras,0) <> 0 THEN
                --Incluir uma vírgula na posicao das letras
                vr_dsaltera:= substr(vr_dsaltera,1,vr_log_qtletras-1)||','||substr(vr_dsaltera,vr_log_qtletras+1);
              END IF;
              --Concatenar o campo alterado
              vr_dsaltera:= vr_dsaltera || vr_log_nmdcampo || ',';
              --Atualizar Alteracao
              BEGIN
                UPDATE crapalt SET crapalt.dsaltera = vr_dsaltera
                WHERE crapalt.rowid = rw_crapalt.rowid;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_cdcritic:= 0;
                  vr_dscritic:= 'Erro ao atualizar crapalt. '||SQLERRM;
                  --Sair
                  RAISE vr_exc_erro;
              END;
            END IF;
          END IF;
        END IF;

        --Tela CADSPC
        IF pr_flgcadspc THEN
          --Verificar Indice
          vr_index:= 'CRAPSPC';

          --Verificar se existe rowid
          IF pr_tab_rowid.EXISTS(vr_index) THEN
            --Selecionar Informacoes do cadastro
            OPEN cr_crapspc (pr_rowid => pr_tab_rowid(vr_index));
            FETCH cr_crapspc INTO rw_crapspc;
            CLOSE cr_crapspc;

            --Inicializar variaveis
            vr_log_desopcao:= 'CADSPC=';
            vr_log_nmdcampo:= NULL;

            --Data vencimento
            IF rw_crapspc.dtvencto <> pr_tab_log(vr_index).crapspc(1).dtvencto THEN
              --Nome do Campo
              vr_log_nmdcampo:= vr_log_desopcao || ' Vencto '||
                                to_char(pr_tab_log(vr_index).crapspc(1).dtvencto,'DD/MM/YYYY')|| ',';
              --Descricao Opcao
              vr_log_desopcao:= NULL;
            END IF;
            --Valor Divida
            IF rw_crapspc.vldivida <> pr_tab_log(vr_index).crapspc(1).vldivida THEN
              --Nome do Campo
              vr_log_nmdcampo:= vr_log_nmdcampo||vr_log_desopcao|| ' Valor Divida '||
                                to_char(pr_tab_log(vr_index).crapspc(1).vldivida,'999g990d00')|| ',';
              --Descricao Opcao
              vr_log_desopcao:= NULL;
            END IF;
            --Data Inclusao
            IF rw_crapspc.dtinclus <> pr_tab_log(vr_index).crapspc(1).dtinclus THEN
              --Nome do Campo
              vr_log_nmdcampo:= vr_log_nmdcampo||vr_log_desopcao|| ' Data Inclusao '||
                                to_char(pr_tab_log(vr_index).crapspc(1).dtinclus,'DD/MM/YYYY')|| ',';
              --Descricao Opcao
              vr_log_desopcao:= NULL;
            END IF;
            --Data BAixa
            IF rw_crapspc.dtdbaixa <> pr_tab_log(vr_index).crapspc(1).dtdbaixa THEN
              --Nome do Campo
              vr_log_nmdcampo:= vr_log_nmdcampo||vr_log_desopcao|| ' Data Baixa '||
                                to_char(pr_tab_log(vr_index).crapspc(1).dtdbaixa,'DD/MM/YYYY')|| ',';
              --Descricao Opcao
              vr_log_desopcao:= NULL;
            END IF;
            --Observacao Inclusao
            IF rw_crapspc.dsoberva <> pr_tab_log(vr_index).crapspc(1).dsoberva THEN
              --Nome do Campo
              vr_log_nmdcampo:= vr_log_nmdcampo||vr_log_desopcao|| ' Obser.Inclusao '||
                                pr_tab_log(vr_index).crapspc(1).dsoberva||',';
              --Descricao Opcao
              vr_log_desopcao:= NULL;
            END IF;
            --Observacao Baixa
            IF rw_crapspc.dsobsbxa <> pr_tab_log(vr_index).crapspc(1).dsobsbxa THEN
              --Nome do Campo
              vr_log_nmdcampo:= vr_log_nmdcampo||vr_log_desopcao|| ' Obser.Baixa '||
                                pr_tab_log(vr_index).crapspc(1).dsobsbxa||',';
              --Descricao Opcao
              vr_log_desopcao:= NULL;
            END IF;
            --Atualizar variavel que fará o update
            vr_dsaltera:= vr_dsaltera||vr_log_nmdcampo;
            --Atualizar Alteracao
            BEGIN
              UPDATE crapalt SET crapalt.dsaltera = vr_dsaltera
              WHERE crapalt.rowid = rw_crapalt.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic:= 0;
                vr_dscritic:= 'Erro ao atualizar crapalt. '||SQLERRM;
                --Sair
                RAISE vr_exc_erro;
            END;
          END IF;
        END IF;
        --Inicializar variaveis
        vr_log_flaltera:= TRUE;
        vr_log_msgrecad:= NULL; /* mensagem para criacao do recadastramento */
        vr_log_tpatlcad:= 0;    /* tipo de atualizacao do cadastro  */
        vr_log_msgatcad:= NULL; /* mensagem atualizacao do cadastro */
        vr_log_chavealt:= gene0002.fn_mask(rw_crapalt.cdcooper,'999')|| ','||
                          gene0002.fn_mask(rw_crapalt.nrdconta,'999999999')|| ','||
                          to_char(rw_crapalt.dtaltera,'DD/MM/YYYY');
        --Verificar tela sendo processada
        IF upper(pr_log_nmdatela) IN ('ALTRAM','DESEXT','ACESSO') THEN
          --Se Operador nao estiver preenchido
          IF TRIM(rw_crapalt.cdoperad) IS NULL THEN
            --Atualizar Alteracao
            BEGIN
              UPDATE crapalt SET crapalt.cdoperad = pr_log_cdoperad
              WHERE crapalt.rowid = rw_crapalt.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic:= 0;
                vr_dscritic:= 'Erro ao atualizar crapalt. '||SQLERRM;
                --Sair
                RAISE vr_exc_erro;
            END;
          END IF;
        ELSE
          --Atualizar Alteracao
          BEGIN
            UPDATE crapalt SET crapalt.cdoperad = pr_log_cdoperad
            WHERE crapalt.rowid = rw_crapalt.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic:= 0;
              vr_dscritic:= 'Erro ao atualizar crapalt. '||SQLERRM;
              --Sair
              RAISE vr_exc_erro;
          END;
        END IF;

        --Tela Matricula
        IF pr_flgmatric THEN
          --Data Alteracao Nula
          IF pr_log_dtaltera IS NULL THEN
            --Verificar tela sendo processada
            IF upper(pr_log_nmdatela) IN ('ACESSO','CONTA','MATRIC','DESEXT','ALTRAM') THEN
              --nao altera
              vr_log_flaltera:= FALSE;
            ELSE
              --Critica
              vr_log_msgrecad:= gene0001.fn_busca_critica(401);
              /* sera atualizado na procedure 'proc_altcad' */
              vr_log_tpaltera:= 1;
              --Chave Alteracao
              vr_log_chavealt:= vr_log_chavealt ||','||vr_log_tpaltera;
            END IF;
          ELSE
            --Tipo Alteracao
            vr_log_tpaltera:= 2;
          END IF;
        END IF;

        --Recadastro e Alteracao
        IF vr_log_flgrecad AND vr_log_flaltera THEN
          --Mensagem Cadastro
          vr_log_msgatcad:= gene0001.fn_busca_critica(402);
          --Tipo Atualizacao cadastro
          vr_log_tpatlcad:= 1;
        ELSIF vr_log_flaltera AND rw_crapalt.tpaltera = 2 AND pr_log_nmdatela NOT IN ('MANTAL','CADSPC') THEN
          --Mensagem Cadastro
          vr_log_msgatcad:= gene0001.fn_busca_critica(764);
          --Tipo Atualizacao cadastro
          vr_log_tpatlcad:= 2;
        END IF;
        /* Se criou o registro e nao teve alteracao - IF   NEW crapalt*/
        IF vr_flgnvalt THEN
          IF trim(vr_dsaltera) IS NULL AND rw_crapalt.tpaltera = 2 THEN
            --Desfazer transacao
            ROLLBACK TO save_trans;
          END IF;
        END IF;
      EXCEPTION
        WHEN vr_exc_erro THEN
          -- Retorno não OK
          pr_des_reto := 'NOK';
          -- Montar descrição de erro não tratado
          pr_dscritic := vr_dscritic;
        WHEN OTHERS THEN
          -- Retorno não OK
          pr_des_reto := 'NOK';
          -- Montar descrição de erro não tratado
          pr_dscritic := 'Erro não tratado na CYBE0001.pc_proc_alteracoes_log '||sqlerrm;
      END;
    END pc_proc_alteracoes_log;

    --Procedure para Mover os campos das tabelas para LOG
    PROCEDURE  pc_move_campos_tab_log (pr_cdcooper  IN crapcop.cdcooper%TYPE --Codigo Cooperativa
                                      ,pr_nrdconta  IN crapass.nrdconta%TYPE --Numero da Conta
                                      ,pr_tab_rowid IN typ_tab_rowid         --tabelas do log
                                      ,pr_flgcontas IN BOOLEAN               --Informacoes Conta
                                      ,pr_flgmatric IN BOOLEAN               --Informacoes matricula
                                      ,pr_log_flencnet OUT BOOLEAN           --Endereco Internetbank
                                      ,pr_log_dtaltera OUT DATE              --Data Alteracao
                                      ,pr_tab_log   OUT typ_tab_log          --tabela com informacoes log
                                      ,pr_des_reto  OUT VARCHAR2             --Informacao erro
                                      ,pr_dscritic  OUT VARCHAR2) IS         --Descricao Erro
    BEGIN
   /* .............................................................................

   Programa: pc_move_campos_tab_log          Antigo: sistema/generico/includes/b1wgenalog.i (agn_logcontas.i)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Abril/2006.                      Ultima atualizacao: 30/09/2013

   Dados referentes ao programa:

   Frequencia: Sempre que for chamada.
   Objetivo  : Fazer a movimentacao dos campos das tabelas para as variaveis do
               log de alteracoes.

   Alteracoes: 13/04/2008 - Retirada dos campos Rec. Arq. Cobranca (Ze)

               18/06/2009 - Ajuste para tipo de rendimento e o valor (Gabriel)
                            e logar item de BENS.

               04/12/2009 - Incluido campos para o item "INF. ADICIONAL" da
                            pessoa fisica (Elton).

               16/12/2009 - Eliminado campo crapttl.cdgrpext (Diego).

               16/03/2010 - Adaptacao para uso das BO's (Jose Luis)

               14/03/2011 - Retirar da ass o campo dsdemail e inarqcbr
                           (Gabriel).

               20/05/2011 - Substituicao do campo crapenc.nranores por
                            crapenc.dtinires (data que o cooperado passou a
                            residir no endereco informado). Fabricio

               13/06/2011 - Criar campo 'Pessoa Politicamente Exposta'
                            (Gabriel).

               05/07/2011 - Incluidas as variaveis log_nrdoapto e log_cddbloco
                            (Henrique).

               02/12/2011 - Incluido a variavel log_dsjusren (Adriano).

               13/04/2012 - Incluido as variaveis para logar a crapcrl - Respon.
                            Legal (Adriano).

               29/04/2013 - Alterado campo crapass.dsnatura por crapttl.dsnatura
                            (Lucas R.)

               20/08/2013 - Alterado posicao do campo dsnatura para alimentar a
                            variavel somente se a crapttl estiver disponivel.
                            (Reinert)

               30/09/2013 - Removido campo log_nrfonres. (Reinert)

               12/03/2014 - Conversao Progress --> Oracle (Alisson - AMcom)

    ............................................................................. */
      DECLARE

        --Selecionar Infomacoes Associado
        CURSOR cr_crapass (pr_rowid IN ROWID) IS
          SELECT crapass.*
          FROM crapass
          WHERE crapass.rowid = pr_rowid;
        --Selecionar Infomacoes Titulares
        CURSOR cr_crapttl (pr_rowid IN ROWID) IS
          SELECT crapttl.*
          FROM crapttl
          WHERE crapttl.rowid = pr_rowid;
        --Selecionar Infomacoes Endereco
        CURSOR cr_crapenc (pr_rowid IN ROWID) IS
          SELECT crapenc.*
          FROM crapenc
          WHERE crapenc.rowid = pr_rowid;
        --Selecionar Infomacoes Pessoa juridica
        CURSOR cr_crapjur (pr_rowid IN ROWID) IS
          SELECT crapjur.*
          FROM crapjur
          WHERE crapjur.rowid = pr_rowid;
        --Selecionar Infomacoes Telefone
        CURSOR cr_craptfc (pr_rowid IN ROWID) IS
          SELECT craptfc.*
          FROM craptfc
          WHERE craptfc.rowid = pr_rowid;
        --Selecionar Infomacoes Emissao Extrato
        CURSOR cr_crapcex (pr_rowid IN ROWID) IS
          SELECT crapcex.*
          FROM crapcex
          WHERE crapcex.rowid = pr_rowid;
        --Selecionar Infomacoes Email
        CURSOR cr_crapcem (pr_rowid IN ROWID) IS
          SELECT crapcem.*
          FROM crapcem
          WHERE crapcem.rowid = pr_rowid;
        --Selecionar Infomacoes Cadastro SPC
        CURSOR cr_crapspc (pr_rowid IN ROWID) IS
          SELECT crapspc.*
          FROM crapspc
          WHERE crapspc.rowid = pr_rowid;
        --Selecionar Infomacoes Avalista
        CURSOR cr_crapavt (pr_rowid IN ROWID) IS
          SELECT crapavt.*
          FROM crapavt
          WHERE crapavt.rowid = pr_rowid;
        --Selecionar Infomacoes Responsavel Legal
        CURSOR cr_crapcrl (pr_rowid IN ROWID) IS
          SELECT crapcrl.*
          FROM crapcrl
          WHERE crapcrl.rowid = pr_rowid;
        --Selecionar Infomacoes Conjuge
        CURSOR cr_crapcje (pr_rowid IN ROWID) IS
          SELECT crapcje.*
          FROM crapcje
          WHERE crapcje.rowid = pr_rowid;
        --Selecionar Infomacoes Dependentes
        CURSOR cr_crapdep (pr_rowid IN ROWID) IS
          SELECT crapdep.*
          FROM crapdep
          WHERE crapdep.rowid = pr_rowid;
        --Selecionar Infomacoes dos bens
        CURSOR cr_crapbem (pr_rowid IN ROWID) IS
          SELECT crapbem.*
          FROM crapbem
          WHERE crapbem.rowid = pr_rowid;
        --Selecionar Infomacoes Financeiras PJ
        CURSOR cr_crapjfn (pr_rowid IN ROWID) IS
          SELECT crapjfn.*
          FROM crapjfn
          WHERE crapjfn.rowid = pr_rowid;
        --Selecionar Alteracoes cadastro associado
        CURSOR cr_crapalt(pr_cdcooper IN crapalt.cdcooper%TYPE
                         ,pr_nrdconta IN crapalt.nrdconta%TYPE
                         ,pr_tpaltera IN crapalt.tpaltera%TYPE) IS
          SELECT crapalt.dtaltera
          FROM crapalt
          WHERE crapalt.cdcooper = pr_cdcooper
          AND   crapalt.nrdconta = pr_nrdconta
          AND   crapalt.tpaltera = pr_tpaltera;
        rw_crapalt cr_crapalt%ROWTYPE;

        --Variaveis Locais
        vr_index_tab VARCHAR2(7);

        --Variaveis Erro
        vr_cdcritic INTEGER;
        vr_des_erro VARCHAR2(3);
        vr_dscritic VARCHAR2(4000);
      BEGIN
        -- Retorno OK
        pr_des_reto := 'OK';

        --Se for por Matricula
        IF pr_flgmatric THEN
          /* Variaveis de recadastramento (geram tipo de alteracao 1) */
          vr_index_tab:= pr_tab_rowid.FIRST;
          WHILE vr_index_tab IS NOT NULL LOOP
            --Tabela
            CASE vr_index_tab
              WHEN 'CRAPASS' THEN
                OPEN cr_crapass (pr_rowid => pr_tab_rowid(vr_index_tab));
                FETCH cr_crapass BULK COLLECT INTO pr_tab_log(vr_index_tab).crapass;
                CLOSE cr_crapass;
              WHEN 'CRAPTTL' THEN
                OPEN cr_crapttl (pr_rowid => pr_tab_rowid(vr_index_tab));
                FETCH cr_crapttl BULK COLLECT INTO pr_tab_log(vr_index_tab).crapttl;
                CLOSE cr_crapttl;
              WHEN 'CRAPENC' THEN
                OPEN cr_crapenc (pr_rowid => pr_tab_rowid(vr_index_tab));
                FETCH cr_crapenc BULK COLLECT INTO pr_tab_log(vr_index_tab).crapenc;
                CLOSE cr_crapenc;
              WHEN 'CRAPJUR' THEN
                OPEN cr_crapjur (pr_rowid => pr_tab_rowid(vr_index_tab));
                FETCH cr_crapjur BULK COLLECT INTO pr_tab_log(vr_index_tab).crapjur;
                CLOSE cr_crapjur;
              WHEN 'CRAPTFC' THEN
                OPEN cr_craptfc (pr_rowid => pr_tab_rowid(vr_index_tab));
                FETCH cr_craptfc BULK COLLECT INTO pr_tab_log(vr_index_tab).craptfc;
                CLOSE cr_craptfc;
              WHEN 'CRAPCEX' THEN
                OPEN cr_crapcex (pr_rowid => pr_tab_rowid(vr_index_tab));
                FETCH cr_crapcex BULK COLLECT INTO pr_tab_log(vr_index_tab).crapcex;
                CLOSE cr_crapcex;
              WHEN 'CRAPCEM' THEN
                OPEN cr_crapcem (pr_rowid => pr_tab_rowid(vr_index_tab));
                FETCH cr_crapcem BULK COLLECT INTO pr_tab_log(vr_index_tab).crapcem;
                CLOSE cr_crapcem;
              WHEN 'CRAPSPC' THEN
                OPEN cr_crapspc (pr_rowid => pr_tab_rowid(vr_index_tab));
                FETCH cr_crapspc BULK COLLECT INTO pr_tab_log(vr_index_tab).crapspc;
                CLOSE cr_crapspc;
              ELSE NULL;
            END CASE;
            --Proximo registro
            vr_index_tab:= pr_tab_rowid.NEXT(vr_index_tab);
          END LOOP;
          --Selecionar alteracao
          OPEN cr_crapalt(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_tpaltera => 1);
          FETCH cr_crapalt INTO rw_crapalt;
          --Se nao encontrou
          IF cr_crapalt%NOTFOUND THEN
            pr_log_dtaltera:= NULL;
          ELSE
            pr_log_dtaltera:= rw_crapalt.dtaltera;
          END IF;
          --fechar Cursor
          CLOSE cr_crapalt;
        END IF;

        --Se nao for tela Contas
        IF NOT pr_flgcontas THEN
          /* Atribuicoes para o log dos campos genericos */
          vr_index_tab:= pr_tab_rowid.FIRST;
          WHILE vr_index_tab IS NOT NULL LOOP
            --Tabela
            CASE vr_index_tab
              WHEN 'CRAPASS' THEN
                OPEN cr_crapass (pr_rowid => pr_tab_rowid(vr_index_tab));
                FETCH cr_crapass BULK COLLECT INTO pr_tab_log(vr_index_tab).crapass;
                CLOSE cr_crapass;
              WHEN 'CRAPTFC' THEN
                OPEN cr_craptfc (pr_rowid => pr_tab_rowid(vr_index_tab));
                FETCH cr_craptfc BULK COLLECT INTO pr_tab_log(vr_index_tab).craptfc;
                CLOSE cr_craptfc;
              WHEN 'CRAPCEM' THEN
                OPEN cr_crapcem (pr_rowid => pr_tab_rowid(vr_index_tab));
                FETCH cr_crapcem BULK COLLECT INTO pr_tab_log(vr_index_tab).crapcem;
                CLOSE cr_crapcem;
              WHEN 'CRAPENC' THEN NULL;
                OPEN cr_crapenc (pr_rowid => pr_tab_rowid(vr_index_tab));
                FETCH cr_crapenc BULK COLLECT INTO pr_tab_log(vr_index_tab).crapenc;
                CLOSE cr_crapenc;
              WHEN 'CRAPJUR' THEN  NULL;
                OPEN cr_crapjur (pr_rowid => pr_tab_rowid(vr_index_tab));
                FETCH cr_crapjur BULK COLLECT INTO pr_tab_log(vr_index_tab).crapjur;
                CLOSE cr_crapjur;
              WHEN 'CRAPTTL' THEN
                OPEN cr_crapttl (pr_rowid => pr_tab_rowid(vr_index_tab));
                FETCH cr_crapttl BULK COLLECT INTO pr_tab_log(vr_index_tab).crapttl;
                CLOSE cr_crapttl;
              WHEN 'CRAPAVT' THEN
                OPEN cr_crapavt (pr_rowid => pr_tab_rowid(vr_index_tab));
                FETCH cr_crapavt BULK COLLECT INTO pr_tab_log(vr_index_tab).crapavt;
                CLOSE cr_crapavt;
              WHEN 'CRAPCRL' THEN
                OPEN cr_crapcrl (pr_rowid => pr_tab_rowid(vr_index_tab));
                FETCH cr_crapcrl BULK COLLECT INTO pr_tab_log(vr_index_tab).crapcrl;
                CLOSE cr_crapcrl;
              WHEN 'CRAPCJE' THEN
                OPEN cr_crapcje (pr_rowid => pr_tab_rowid(vr_index_tab));
                FETCH cr_crapcje BULK COLLECT INTO pr_tab_log(vr_index_tab).crapcje;
                CLOSE cr_crapcje;
              WHEN 'CRAPDEP' THEN
                OPEN cr_crapdep (pr_rowid => pr_tab_rowid(vr_index_tab));
                FETCH cr_crapdep BULK COLLECT INTO pr_tab_log(vr_index_tab).crapdep;
                CLOSE cr_crapdep;
              WHEN 'CRAPBEM' THEN
                OPEN cr_crapbem (pr_rowid => pr_tab_rowid(vr_index_tab));
                FETCH cr_crapbem BULK COLLECT INTO pr_tab_log(vr_index_tab).crapbem;
                CLOSE cr_crapbem;
              WHEN 'CRAPJFN' THEN
                OPEN cr_crapjfn (pr_rowid => pr_tab_rowid(vr_index_tab));
                FETCH cr_crapjfn BULK COLLECT INTO pr_tab_log(vr_index_tab).crapjfn;
                CLOSE cr_crapjfn;
              ELSE NULL;
            END CASE;
            --Proximo registro
            vr_index_tab:= pr_tab_rowid.NEXT(vr_index_tab);
          END LOOP;

          /* Indica se o endereco atualizado foi cadastrado via InternetBank. */
          /* Sera atribuido como TRUE na procedure que faz essa atualizacao.  */
          pr_log_flencnet:= FALSE;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          -- Retorno não OK
          pr_des_reto := 'NOK';
          -- Montar descrição de erro não tratado
          pr_dscritic := 'Erro não tratado na CYBE0001.pc_move_campos_tab_log '||sqlerrm;
      END;
    END pc_move_campos_tab_log;

    /* Procedure para remover associado do SPC */
    PROCEDURE pc_remove_spc_crapass (pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                    ,pr_cdagenci IN crapass.cdagenci%TYPE --> Código da agência
                                    ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Número do caixa
                                    ,pr_cdoperad IN crapdev.cdoperad%TYPE --> Código do Operador
                                    ,pr_idorigem IN INTEGER               --> Id do módulo de sistema
                                    ,pr_nrcpfcgc IN NUMBER                --> Numero Cpf/Cnpj
                                    ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Número da conta
                                    ,pr_tpidenti IN INTEGER               --> Tipo identificacao
                                    ,pr_nrctaavl IN INTEGER               --> Numero Conta Avalista 1
                                    ,pr_nrdrowid IN ROWID                 --> ROWID da crapspc
                                    ,pr_dtinclus IN DATE                  --> Data Inclusao
                                    ,pr_des_reto OUT VARCHAR              --> Retorno OK / NOK
                                    ,pr_tab_erro OUT gene0001.typ_tab_erro) IS --> Tabela com possíves erros
    BEGIN
    /* .............................................................................

     Programa: pc_remove_spc_crapass             Antigo: b1wgen0133.p/remove_spc_crapass
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Alisson
     Data    : Marco/2014                        Ultima atualizacao: 12/03/2014

     Dados referentes ao programa:

     Frequencia: Diaria - Sempre que for chamada
     Objetivo  : Rotina para remover associado do SPC

     Alteracoes: 12/03/2014 - Conversão Progress para Oracle (Alisson - AMcom)

  ............................................................................. */

      DECLARE

        /* Cursores Locais */

        --Selecionar cadastro SPC pelo Cpf/cnpj
        CURSOR cr_crabspc_cpf (pr_cdcooper IN crapspc.cdcooper%TYPE
                              ,pr_nrcpfcgc IN crapspc.nrcpfcgc%TYPE
                              ,pr_nrdrowid IN ROWID) IS
          SELECT crapspc.cdcooper
          FROM crapspc
          WHERE crapspc.cdcooper = pr_cdcooper
          AND   crapspc.nrcpfcgc = pr_nrcpfcgc
          AND   crapspc.dtdbaixa IS NULL
          AND   crapspc.rowid   <> pr_nrdrowid
          ORDER BY crapspc.progress_recid ASC;
        rw_crabspc cr_crabspc_cpf%ROWTYPE;

        --Selecionar cadastro SPC pela Conta
        CURSOR cr_crabspc_cta (pr_cdcooper IN crapspc.cdcooper%TYPE
                              ,pr_nrdconta IN crapspc.nrdconta%TYPE
                              ,pr_nrdrowid IN ROWID) IS
          SELECT crapspc.cdcooper
          FROM crapspc
          WHERE crapspc.cdcooper = pr_cdcooper
          AND   crapspc.nrdconta = pr_nrdconta
          AND   crapspc.dtdbaixa IS NULL
          AND   crapspc.rowid   <> pr_nrdrowid
          ORDER BY crapspc.progress_recid ASC;

        --Variaveis Locais
        vr_dstransa VARCHAR2(100);
        vr_dsorigem VARCHAR2(100);
        vr_nrctaass INTEGER;
        vr_crabspc  BOOLEAN;
        vr_crapass  BOOLEAN;

        --Variaveis Erro
        vr_cdcritic INTEGER;
        vr_des_erro VARCHAR2(3);
        vr_dscritic VARCHAR2(4000);

        --Variaveis Excecao
        vr_exc_erro  EXCEPTION;
        vr_exc_saida EXCEPTION;

      BEGIN
        --Inicializar variavel erro
        pr_des_reto:= 'NOK';
        vr_cdcritic:= 0;
        vr_dscritic:= NULL;
        vr_nrctaass:= 0;

        --Limpar tabela erros
        pr_tab_erro.DELETE;

        --Selecionar Cadastro SPC
        OPEN cr_crapspc_rowid (pr_rowid => pr_nrdrowid);
        FETCH cr_crapspc_rowid INTO rw_crapspc_rowid;
        --Se nao encontrou
        IF cr_crapspc_rowid%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_crapspc_rowid;
          vr_cdcritic:= 301;
          --Sair
          RAISE vr_exc_saida;
        END IF;
        --Fechar Cursor
        CLOSE cr_crapspc_rowid;

        BEGIN
          --Criar ponto restauração
          SAVEPOINT save_trans;

          /* Caso o Fiador nao seja correntista, limpar apenas crapass do devedor */
          IF pr_tpidenti IN (1,2) OR nvl(pr_nrctaavl,0) = 0 THEN

            /* Verifica se existe algum outro contrato do cooperado no SPC */
            OPEN cr_crabspc_cpf (pr_cdcooper => pr_cdcooper
                                ,pr_nrcpfcgc => pr_nrcpfcgc
                                ,pr_nrdrowid => pr_nrdrowid);
            FETCH cr_crabspc_cpf INTO rw_crabspc;
            --verificar se encontrou
            vr_crabspc:= cr_crabspc_cpf%FOUND;
            --Fechar Cursor
            CLOSE cr_crabspc_cpf;
            --Se Encontrou
            IF vr_crabspc THEN
              --Sair
              RAISE vr_exc_saida;
            END IF;
            --Selecionar associado
            OPEN cr_crapass (pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta);
            FETCH cr_crapass INTO rw_crapass;
            --Determinar se achou
            vr_crapass:= cr_crapass%FOUND;
            --Fechar cursor
            CLOSE cr_crapass;
            --Se Encontrou
            IF vr_crapass THEN
              /* remove do SPC na crapass */
              IF rw_crapspc_rowid.dtdbaixa IS NOT NULL THEN
                BEGIN
                  UPDATE crapass SET crapass.dtdsdspc = NULL
                                    ,crapass.inadimpl = 0
                  WHERE crapass.rowid = rw_crapass.rowid;
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_cdcritic:= 0;
                    vr_dscritic:= 'Erro ao atualizar crapass. '||SQLERRM;
                    --Sair
                    RAISE vr_exc_saida;
                END;
              ELSE
                BEGIN
                  UPDATE crapass SET crapass.dtdsdspc = pr_dtinclus
                                    ,crapass.inadimpl = 1
                  WHERE crapass.rowid = rw_crapass.rowid;
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_cdcritic:= 0;
                    vr_dscritic:= 'Erro ao atualizar crapass. '||SQLERRM;
                    --Sair
                    RAISE vr_exc_saida;
                END;
              END IF;
            END IF;
          ELSE /* Quando o Fiador é correntista */
            FOR idx IN 1..2 LOOP
              --Devedor
              IF idx = 1 THEN /* Devedor */
                --Selecionar cadastro SPC
                OPEN cr_crabspc_cta (pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_nrdrowid => pr_nrdrowid);
                FETCH cr_crabspc_cta INTO rw_crabspc;
                --verificar se achou
                vr_crabspc:= cr_crabspc_cta%FOUND;
                --Fechar Cursor
                CLOSE cr_crabspc_cta;
                --Se Achou
                IF vr_crabspc THEN
                  --Proximo registro
                  CONTINUE;
                END IF;
                --Determinar conta do devedor
                vr_nrctaass:= pr_nrdconta;
              ELSE /* Fiador */
                --Selecionar cadastro SPC
                OPEN cr_crabspc_cpf (pr_cdcooper => pr_cdcooper
                                    ,pr_nrcpfcgc => pr_nrcpfcgc
                                    ,pr_nrdrowid => pr_nrdrowid);
                FETCH cr_crabspc_cpf INTO rw_crabspc;
                --verificar se achou
                vr_crabspc:= cr_crabspc_cpf%FOUND;
                --Fechar Cursor
                CLOSE cr_crabspc_cpf;
                --Se Achou
                IF vr_crabspc THEN
                  --Proximo registro
                  EXIT;
                END IF;
                --Determinar conta do avalista
                vr_nrctaass:= pr_nrctaavl;
              END IF;
              --Selecionar associado
              OPEN cr_crapass (pr_cdcooper => pr_cdcooper
                              ,pr_nrdconta => vr_nrctaass);
              FETCH cr_crapass INTO rw_crapass;
              --Determinar se encontrou
              vr_crapass:= cr_crapass%FOUND;
              --Fechar Cursor
              CLOSE cr_crapass;
              --Se Encontrou
              IF vr_crapass THEN
              /* remove do SPC na crapass */
                IF rw_crapspc_rowid.dtdbaixa IS NOT NULL THEN
                  BEGIN
                    UPDATE crapass SET crapass.dtdsdspc = NULL
                                      ,crapass.inadimpl = 0
                    WHERE crapass.rowid = rw_crapass.rowid;
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_cdcritic:= 0;
                      vr_dscritic:= 'Erro ao atualizar crapass. '||SQLERRM;
                      --Sair
                      RAISE vr_exc_saida;
                  END;
                ELSE
                  BEGIN
                    UPDATE crapass SET crapass.dtdsdspc = pr_dtinclus
                                      ,crapass.inadimpl = 1
                    WHERE crapass.rowid = rw_crapass.rowid;
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_cdcritic:= 0;
                      vr_dscritic:= 'Erro ao atualizar crapass. '||SQLERRM;
                      --Sair
                      RAISE vr_exc_saida;
                  END;
                END IF;
              END IF; --vr_crapass
            END LOOP; --idx 1..2
          END IF;
        EXCEPTION
          WHEN vr_exc_saida THEN
            ROLLBACK TO save_trans;
        END;
        --Se ocorreu erro
        IF vr_dscritic IS NOT NULL OR vr_cdcritic <> 0 THEN
          -- Retorno não OK
          pr_des_reto := 'NOK';
          --Se tem erro na tabela
          IF pr_tab_erro.count = 0 THEN
            -- Gerar rotina de gravação de erro
            gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                 ,pr_cdagenci => pr_cdagenci
                                 ,pr_nrdcaixa => pr_nrdcaixa
                                 ,pr_nrsequen => 1 --> Fixo
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic
                                 ,pr_tab_erro => pr_tab_erro);
          END IF;
        ELSE
          -- Retorno OK
          pr_des_reto:= 'OK';
        END IF;
      EXCEPTION
         WHEN OTHERS THEN
          -- Retorno não OK
          pr_des_reto := 'NOK';
          -- Montar descrição de erro não tratado
          vr_dscritic := 'Erro não tratado na CYBE0001.pc_remove_spc_crapass '||sqlerrm;
          -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 --> Fixo
                               ,pr_cdcritic => 0
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
      END;
    END pc_remove_spc_crapass;

  /* Validar Os Dados do Contrato de Emprestimo */
  PROCEDURE pc_grava_dados  (pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                            ,pr_cdagenci IN crapass.cdagenci%TYPE --> Código da agência
                            ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Número do caixa
                            ,pr_idorigem IN INTEGER               --> Id do módulo de sistema
                            ,pr_nmdatela IN VARCHAR2              --> Nome da tela
                            ,pr_cdoperad IN crapdev.cdoperad%TYPE --> Código do Operador
                            ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data movimento
                            ,pr_cddopcao IN VARCHAR2              --> Codigo Opcao
                            ,pr_nrcpfcgc IN NUMBER                --> Numero Cpf/Cnpj
                            ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Número da conta
                            ,pr_tpidenti IN INTEGER               --> Tipo identificacao
                            ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Numero Contrato
                            ,pr_tpctrdev IN INTEGER               --> Tipo Contrato
                            ,pr_dtinclus IN DATE                  --> Data Inclusao
                            ,pr_nrctrspc IN VARCHAR2              --> Numero Contrato SPC
                            ,pr_dtvencto IN DATE                  --> Data Vencimento
                            ,pr_vldivida IN NUMBER                --> Valor da dívida
                            ,pr_tpinsttu IN INTEGER               --> Tipo Instrucao
                            ,pr_dsoberv1 IN VARCHAR2              --> Observacao 1
                            ,pr_dsoberv2 IN VARCHAR2              --> Observacao 2
                            ,pr_dtdbaixa IN DATE                  --> Data de Baixa
                            ,pr_nrctaavl IN INTEGER               --> Numero Conta Avalista 1
                            ,pr_nrdrowid IN ROWID                 --> ROWID da crapspc
                            ,pr_des_reto OUT VARCHAR              --> Retorno OK / NOK
                            ,pr_tab_erro OUT gene0001.typ_tab_erro) IS --> Tabela com possíves erros
    BEGIN
    /* .............................................................................

     Programa: pc_grava_dados                        Antigo: b1wgen0133.p/grava_dados
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Alisson
     Data    : marco/2014                        Ultima atualizacao: 10/03/2014

     Dados referentes ao programa:

     Frequencia: Diaria - Sempre que for chamada
     Objetivo  : Rotina para gravar os dados do contrato de emprestimo

     Alteracoes: 10/03/2014 - Conversão Progress para Oracle (Alisson - AMcom)

  ............................................................................. */

      DECLARE

        /* Cursores Locais */

        --Selecionar cadastro spc
        CURSOR cr_crapspc (pr_cdcooper IN crapspc.cdcooper%TYPE
                          ,pr_nrdconta IN crapspc.nrdconta%TYPE
                          ,pr_nrcpfcgc IN crapspc.nrcpfcgc%TYPE
                          ,pr_nrctremp IN crapspc.nrctremp%TYPE
                          ,pr_dtinclus IN crapspc.dtinclus%TYPE) IS
          SELECT crapspc.rowid
          FROM crapspc
          WHERE crapspc.cdcooper = pr_cdcooper
          AND   crapspc.nrdconta = pr_nrdconta
          AND   crapspc.nrcpfcgc = pr_nrcpfcgc
          AND   crapspc.nrctremp = pr_nrctremp
          AND   crapspc.dtinclus = pr_dtinclus;
        rw_crapspc cr_crapspc%ROWTYPE;



        --Tabela de Memoria para armazenar informacoes do log por rowid
        vr_tab_rowid typ_tab_rowid;

        --Tabela de Memoria para armazenar os LOGs
        vr_tab_log typ_tab_log;

        --Variaveis Locais
        vr_dstransa VARCHAR2(100);
        vr_dsorigem VARCHAR2(100);
        vr_nrctaass INTEGER;
        vr_idseqttl INTEGER:= 1;

        --Variaveis de LOG
        vr_log_dtaltera DATE;
        vr_log_flencnet BOOLEAN;

        --Variaveis Erro
        vr_cdcritic INTEGER;
        vr_des_erro VARCHAR2(3);
        vr_dscritic VARCHAR2(4000);

        --Variaveis Excecao
        vr_exc_erro  EXCEPTION;
        vr_exc_saida EXCEPTION;

      BEGIN
        --Inicializar variavel erro
        pr_des_reto:= 'NOK';
        vr_cdcritic:= 0;
        vr_dscritic:= NULL;

        --Limpar Tabela Erro
        pr_tab_erro.DELETE;

        --Buscar Descricao origem
        vr_dsorigem:= GENE0001.vr_vet_des_origens(pr_idorigem);
        --Descricao Transacao
        vr_dstransa:= 'Grava Informacoes do Devedor';

        BEGIN
          --Criar ponto restauração
          SAVEPOINT save_trans;
          /* Verifica alteracoes desta conta na crapalt */
          OPEN cr_crapass (pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta);
          FETCH cr_crapass INTO rw_crapass;
          --Fechar Cursor
          CLOSE cr_crapass;

          --Alteracao/baixa/Inclusao
          CASE pr_cddopcao
            WHEN 'A' THEN
              --Selecionar Cadastro SPC
              OPEN cr_crapspc_rowid (pr_rowid => pr_nrdrowid);
              FETCH cr_crapspc_rowid INTO rw_crapspc_rowid;
              --Se nao encontrou
              IF cr_crapspc_rowid%NOTFOUND THEN
                --Fechar Cursor
                CLOSE cr_crapspc_rowid;
                vr_cdcritic:= 301;
                --Sair
                RAISE vr_exc_saida;
              END IF;
              --Fechar Cursor
              CLOSE cr_crapspc_rowid;

              --Selecionar conjuge e incluir na tabela de log
              OPEN cr_crapcje_rowid (pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => pr_nrdconta);
              FETCH cr_crapcje_rowid INTO rw_crapcje_rowid;
              --Se encontrou
              IF cr_crapcje_rowid%FOUND THEN
                  vr_tab_rowid('CRAPCJE'):= rw_crapcje_rowid.rowid;
              END IF;
              --Fechar Cursor
              CLOSE cr_crapcje_rowid;

              --Marcar o rowid da tabela crapass e crapspc
              vr_tab_rowid('CRAPASS'):= rw_crapass.rowid;
              vr_tab_rowid('CRAPSPC'):= rw_crapspc_rowid.rowid;

              --Mover arquivos para tabela log
              pc_move_campos_tab_log (pr_cdcooper     => pr_cdcooper      --Codigo Cooperativa
                                     ,pr_nrdconta     => pr_nrdconta      --Numero da Conta
                                     ,pr_tab_rowid    => vr_tab_rowid     --tabelas do log
                                     ,pr_tab_log      => vr_tab_log       --tabela com informacoes log
                                     ,pr_flgcontas    => FALSE            --Informacoes Conta
                                     ,pr_flgmatric    => TRUE             --Informacoes matricula
                                     ,pr_log_flencnet => vr_log_flencnet  --Endereco Internetbank
                                     ,pr_log_dtaltera => vr_log_dtaltera  --Data Alteracao
                                     ,pr_des_reto     => vr_des_erro      --Informacao erro
                                     ,pr_dscritic     => vr_dscritic);    --Descricao Erro
              --Se ocorreu erro
              IF vr_des_erro <> 'OK' THEN
                RAISE vr_exc_erro;
              END IF;

              --Parametro Data Inclusao <> tabela spc
              IF pr_dtinclus <> rw_crapspc_rowid.dtinclus THEN
                --Atualizar Baixa
                BEGIN
                  UPDATE crapspc SET crapspc.cdoperad = pr_cdoperad
                  WHERE crapspc.rowid = rw_crapspc_rowid.rowid;
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_cdcritic:= 0;
                    vr_dscritic:= 'Erro ao atualizar crapspc. '||SQLERRM;
                    --Sair
                    RAISE vr_exc_saida;
                END;
              END IF;
              --Atualizar Baixa
              BEGIN
                UPDATE crapspc SET crapspc.nrctrspc = pr_nrctrspc
                                  ,crapspc.dtvencto = pr_dtvencto
                                  ,crapspc.vldivida = pr_vldivida
                                  ,crapspc.dtinclus = pr_dtinclus
                                  ,crapspc.tpinsttu = pr_tpinsttu
                                  ,crapspc.dsoberva = pr_dsoberv1
                 WHERE crapspc.rowid = rw_crapspc_rowid.rowid;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_cdcritic:= 0;
                  vr_dscritic:= 'Erro ao atualizar crapspc. '||SQLERRM;
                  --Sair
                  RAISE vr_exc_saida;
              END;

              --Processar Mudanças
              CYBE0001.pc_proc_alteracoes_log (pr_log_cdcooper => pr_cdcooper        --> Codigo Cooperativa
                                              ,pr_log_nrdconta => pr_nrdconta        --> Numero da Conta
                                              ,pr_log_dtmvtolt => pr_dtmvtolt        --> Data Movimento
                                              ,pr_log_cdoperad => pr_cdoperad        --> Codigo Operador
                                              ,pr_log_cddopcao => pr_cddopcao        --> Codigo opcao
                                              ,pr_log_nmdatela => pr_nmdatela        --> Nome da tela
                                              ,pr_log_idseqttl => vr_idseqttl        --> Sequencia Titular
                                              ,pr_log_nrdctabb => NULL               --> Mantal - Numero Conta
                                              ,pr_log_nrdocmto => NULL               --> Mantal - Numero Cheque
                                              ,pr_tab_rowid    => vr_tab_rowid       --> tabelas do log
                                              ,pr_flgcontas    => FALSE              --> Informacoes Conta
                                              ,pr_flgmatric    => FALSE              --> Informacoes matricula
                                              ,pr_flgmantal    => FALSE              --> Informacoes Tela Mantal
                                              ,pr_flgcadspc    => TRUE               --> Informacoes Tela CADSPC
                                              ,pr_log_flencnet => vr_log_flencnet    --> Endereco Internetbank
                                              ,pr_log_dtaltera => vr_log_dtaltera    --> Data Alteracao
                                              ,pr_tab_log      => vr_tab_log         --> tabela com informacoes log
                                              ,pr_des_reto     => vr_des_erro        --> Informacao erro
                                              ,pr_dscritic     => vr_dscritic);      --> Descricao Erro
              --Se ocorreu erro
              IF vr_des_erro <> 'OK' THEN
                --Sair
                RAISE vr_exc_saida;
              END IF;

            WHEN 'B' THEN

              --Selecionar Cadastro SPC
              OPEN cr_crapspc_rowid (pr_rowid => pr_nrdrowid);
              FETCH cr_crapspc_rowid INTO rw_crapspc_rowid;
              --Se nao encontrou
              IF cr_crapspc_rowid%NOTFOUND THEN
                --Fechar Cursor
                CLOSE cr_crapspc_rowid;
                vr_cdcritic:= 301;
                --Sair
                RAISE vr_exc_saida;
              END IF;
              --Fechar Cursor
              CLOSE cr_crapspc_rowid;

              --Selecionar conjuge e incluir na tabela de log
              OPEN cr_crapcje_rowid (pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => pr_nrdconta);
              FETCH cr_crapcje_rowid INTO rw_crapcje_rowid;
              --Se nao encontrou
              IF cr_crapcje_rowid%FOUND THEN
                  vr_tab_rowid('CRAPCJE'):= rw_crapcje_rowid.rowid;
              END IF;
              --Fechar Cursor
              CLOSE cr_crapcje_rowid;

              --Marcar o rowid da tabela crapass e crapspc
              vr_tab_rowid('CRAPASS'):= rw_crapass.rowid;
              vr_tab_rowid('CRAPSPC'):= rw_crapspc_rowid.rowid;

              --Mover arquivos para tabela log
              pc_move_campos_tab_log (pr_cdcooper     => pr_cdcooper      --Codigo Cooperativa
                                     ,pr_nrdconta     => pr_nrdconta      --Numero da Conta
                                     ,pr_tab_rowid    => vr_tab_rowid     --tabelas do log
                                     ,pr_tab_log      => vr_tab_log       --tabela com informacoes log
                                     ,pr_flgcontas    => FALSE            --Informacoes Conta
                                     ,pr_flgmatric    => TRUE             --Informacoes matricula
                                     ,pr_log_flencnet => vr_log_flencnet  --Endereco Internetbank
                                     ,pr_log_dtaltera => vr_log_dtaltera  --Data Alteracao
                                     ,pr_des_reto     => vr_des_erro      --Informacao erro
                                     ,pr_dscritic     => vr_dscritic);    --Descricao Erro
              --Se ocorreu erro
              IF vr_des_erro <> 'OK' THEN
                RAISE vr_exc_erro;
              END IF;

              --Parametro Data baixa <> tabela spc
              IF pr_dtdbaixa <> rw_crapspc_rowid.dtdbaixa THEN
                --Atualizar Operador Baixa
                BEGIN
                  UPDATE crapspc SET crapspc.opebaixa = pr_cdoperad
                  WHERE crapspc.rowid = rw_crapspc_rowid.rowid;
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_cdcritic:= 0;
                    vr_dscritic:= 'Erro ao atualizar crapspc. '||SQLERRM;
                    --Sair
                    RAISE vr_exc_saida;
                END;
              END IF;
              --Atualizar Baixa
              BEGIN
                UPDATE crapspc SET crapspc.dtdbaixa = pr_dtdbaixa
                                  ,crapspc.dsobsbxa = pr_dsoberv2
                 WHERE crapspc.rowid = rw_crapspc_rowid.rowid;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_cdcritic:= 0;
                  vr_dscritic:= 'Erro ao atualizar crapspc. '||SQLERRM;
                  --Sair
                  RAISE vr_exc_saida;
              END;
              --Remove Associado SPC
              CYBE0001.pc_remove_spc_crapass (pr_cdcooper => pr_cdcooper    --> Cooperativa conectada
                                             ,pr_cdagenci => pr_cdagenci    --> Código da agência
                                             ,pr_nrdcaixa => pr_nrdcaixa    --> Número do caixa
                                             ,pr_cdoperad => pr_cdoperad    --> Código do Operador
                                             ,pr_idorigem => pr_idorigem    --> Id do módulo de sistema
                                             ,pr_nrcpfcgc => pr_nrcpfcgc    --> Numero Cpf/Cnpj
                                             ,pr_nrdconta => pr_nrdconta    --> Número da conta
                                             ,pr_tpidenti => pr_tpidenti    --> Tipo identificacao
                                             ,pr_nrctaavl => pr_nrctaavl    --> Numero Conta Avalista 1
                                             ,pr_nrdrowid => pr_nrdrowid    --> ROWID da crapspc
                                             ,pr_dtinclus => pr_dtinclus    --> Data Inclusao
                                             ,pr_des_reto => vr_des_erro    --> Retorno OK / NOK
                                             ,pr_tab_erro => pr_tab_erro);  --> Tabela com possíves erros
              --Se ocorreu erro
              IF vr_des_erro <> 'OK' THEN
                RAISE vr_exc_saida;
              END IF;

              --Verificar se existe crapspc
              IF vr_tab_log.EXISTS('CRAPSPC') THEN
                --Existe Data Baixa
                IF vr_tab_log('CRAPSPC').crapspc(1).dtdbaixa IS NOT NULL THEN
                  --Processar Mudanças
                  CYBE0001.pc_proc_alteracoes_log (pr_log_cdcooper => pr_cdcooper        --> Codigo Cooperativa
                                                  ,pr_log_nrdconta => pr_nrdconta        --> Numero da Conta
                                                  ,pr_log_dtmvtolt => pr_dtmvtolt        --> Data Movimento
                                                  ,pr_log_cdoperad => pr_cdoperad        --> Codigo Operador
                                                  ,pr_log_cddopcao => pr_cddopcao        --> Codigo opcao
                                                  ,pr_log_nmdatela => pr_nmdatela        --> Nome da tela
                                                  ,pr_log_idseqttl => vr_idseqttl        --> Sequencia Titular
                                                  ,pr_log_nrdctabb => NULL               --> Mantal - Numero Conta
                                                  ,pr_log_nrdocmto => NULL               --> Mantal - Numero Cheque
                                                  ,pr_tab_rowid    => vr_tab_rowid       --> tabelas do log
                                                  ,pr_flgcontas    => FALSE              --> Informacoes Conta
                                                  ,pr_flgmatric    => TRUE               --> Informacoes matricula
                                                  ,pr_flgmantal    => FALSE              --> Informacoes Tela Mantal
                                                  ,pr_flgcadspc    => TRUE               --> Informacoes Tela CADSPC
                                                  ,pr_log_flencnet => vr_log_flencnet    --> Endereco Internetbank
                                                  ,pr_log_dtaltera => vr_log_dtaltera    --> Data Alteracao
                                                  ,pr_tab_log      => vr_tab_log         --> tabela com informacoes log
                                                  ,pr_des_reto     => vr_des_erro        --> Informacao erro
                                                  ,pr_dscritic     => vr_dscritic);      --> Descricao Erro
                  --Se ocorreu erro
                  IF vr_des_erro <> 'OK' THEN
                    --Sair
                    RAISE vr_exc_saida;
                  END IF;
                END IF;
              END IF;

            WHEN 'I' THEN

              --Associado/Avalista
              IF pr_tpidenti IN (1,2) THEN
                vr_nrctaass:= pr_nrdconta;
              ELSE
                vr_nrctaass:= pr_nrctaavl;
              END IF;
              --Se Encontrou conta
              IF nvl(vr_nrctaass,0) > 0 THEN
                --Selecionar associado
                OPEN cr_crapass (pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => vr_nrctaass);
                FETCH cr_crapass INTO rw_crapass;
                --Se Encontrou
                IF cr_crapass%FOUND AND rw_crapass.dtdsdspc IS NULL THEN
                  --Data Inadimplencia SPC
                  BEGIN
                    UPDATE crapass SET crapass.dtdsdspc = pr_dtinclus
                                      ,crapass.inadimpl = 1
                    WHERE crapass.rowid = rw_crapass.rowid;
                  EXCEPTION
                    WHEN OTHERS THEN
                      --Fechar Cursor
                      CLOSE cr_crapass;
                      vr_cdcritic:= 0;
                      vr_dscritic:= 'Erro ao atualizar crapass. '||SQLERRM;
                      --Sair
                      RAISE vr_exc_saida;
                  END;
                END IF;
                --Fechar Cursor
                CLOSE cr_crapass;
              END IF;
              --Selecionar Cadastro SPC
              OPEN cr_crapspc (pr_cdcooper => pr_cdcooper
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrcpfcgc => pr_nrcpfcgc
                              ,pr_nrctremp => pr_nrctremp
                              ,pr_dtinclus => pr_dtinclus);
              FETCH cr_crapspc INTO rw_crapspc;
              --Se Encontrou
              IF cr_crapspc%FOUND THEN
                --Fechar Cursor
                CLOSE cr_crapspc;
                vr_dscritic:= 'Ja existe resgistro de inclusao para este contrato nesta data.';
                --Sair
                RAISE vr_exc_saida;
              END IF;
              --Fechar Cursor
              CLOSE cr_crapspc;
              --Inserir cadastro SPC
              BEGIN
                INSERT INTO crapspc
                  (crapspc.cdcooper
                  ,crapspc.nrcpfcgc
                  ,crapspc.cdorigem
                  ,crapspc.nrctremp
                  ,crapspc.tpidenti
                  ,crapspc.nrctrspc
                  ,crapspc.dtvencto
                  ,crapspc.vldivida
                  ,crapspc.dtinclus
                  ,crapspc.tpinsttu
                  ,crapspc.dtdbaixa
                  ,crapspc.dtmvtolt
                  ,crapspc.hrtransa
                  ,crapspc.cdoperad
                  ,crapspc.opebaixa
                  ,crapspc.dsoberva
                  ,crapspc.dsobsbxa
                  ,crapspc.nrdconta)
                VALUES
                  (pr_cdcooper
                  ,pr_nrcpfcgc
                  ,pr_tpctrdev
                  ,pr_nrctremp
                  ,pr_tpidenti
                  ,pr_nrctrspc
                  ,pr_dtvencto
                  ,pr_vldivida
                  ,pr_dtinclus
                  ,pr_tpinsttu
                  ,NULL
                  ,pr_dtmvtolt
                  ,gene0002.fn_busca_time
                  ,pr_cdoperad
                  ,' '
                  ,pr_dsoberv1
                  ,' '
                  ,pr_nrdconta);
              EXCEPTION
                WHEN OTHERS THEN
                  --Fechar Cursor
                  CLOSE cr_crapass;
                  vr_cdcritic:= 0;
                  vr_dscritic:= 'Erro ao atualizar crapass. '||SQLERRM;
                  --Sair
                  RAISE vr_exc_saida;
              END;
            ELSE NULL;
          END CASE;

        EXCEPTION
          WHEN vr_exc_saida THEN
            ROLLBACK TO save_trans;
        END;
        --Se ocorreu erro
        IF vr_dscritic IS NOT NULL OR vr_cdcritic <> 0 THEN
          -- Retorno não OK
          pr_des_reto := 'NOK';
          --Se tem erro na tabela
          IF pr_tab_erro.count = 0 THEN
            -- Gerar rotina de gravação de erro
            gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                 ,pr_cdagenci => pr_cdagenci
                                 ,pr_nrdcaixa => pr_nrdcaixa
                                 ,pr_nrsequen => 1 --> Fixo
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic
                                 ,pr_tab_erro => pr_tab_erro);
          END IF;
        ELSE
          -- Retorno OK
          pr_des_reto:= 'OK';
        END IF;

      EXCEPTION
         WHEN OTHERS THEN
          -- Retorno não OK
          pr_des_reto := 'NOK';
          -- Montar descrição de erro não tratado
          vr_dscritic := 'Erro não tratado na CYBE0001.pc_grava_dados '||sqlerrm;
          -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 --> Fixo
                               ,pr_cdcritic => 0
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
      END;
    END pc_grava_dados;

    PROCEDURE pc_atualiza_crapalt (pr_rowid_crapalt IN ROWID                 --> Rowid Registro Alteracao
                                  ,pr_log_flgctitg  IN crapalt.flgctitg%TYPE --> Flag Conta Integracao
                                  ,pr_log_cdoperad  IN crapalt.cdoperad%TYPE --> Codigo Operador
                                  ,pr_log_nmdcampo  IN LONG                  --> Nome Campo
                                  ,pr_des_reto      OUT VARCHAR              --> Retorno OK / NOK
                                  ,pr_dscritic      OUT VARCHAR2) IS         --> Descricao Erro
    BEGIN
    /* .............................................................................

     Programa: pc_atualiza_crapalt               Antigo: includes/b1wgenvlog.i/atualiza_crapalt
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Alisson
     Data    : Marco/2014                        Ultima atualizacao: 13/03/2014

     Dados referentes ao programa:

     Frequencia: Diaria - Sempre que for chamada
     Objetivo  : Rotina para Atualizar cadastro

     Alteracoes: 13/03/2014 - Conversão Progress para Oracle (Alisson - AMcom)

  ............................................................................. */

      DECLARE

        /* Cursores Locais */
        CURSOR cr_crapalt (pr_nrdrowid IN ROWID) IS
          SELECT crapalt.dsaltera
          FROM crapalt
          WHERE crapalt.rowid = pr_nrdrowid;

        --Variaveis Erro
        vr_cdcritic INTEGER;
        vr_des_erro VARCHAR2(3);
        vr_dscritic VARCHAR2(4000);

        --Valor da Coluna Long
        vr_dsaltera LONG;

        --Variaveis Excecao
        vr_exc_erro  EXCEPTION;

      BEGIN
        --Inicializar variavel erro
        pr_des_reto:= 'OK';
        pr_dscritic:= NULL;

        --Selecionar Alteracao
        OPEN cr_crapalt (pr_nrdrowid => pr_rowid_crapalt);
        FETCH cr_crapalt INTO vr_dsaltera;
        --Se nao encontrou
        IF cr_crapalt%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_crapalt;
          vr_dscritic:= 'Registro da crapalt não encontrado.';
        END IF;
        CLOSE cr_crapalt;

        --Concatenar valor passado
        vr_dsaltera:= vr_dsaltera|| pr_log_nmdcampo || ',';
        --Atualizar cadastro
        BEGIN
          UPDATE crapalt SET crapalt.flgctitg = pr_log_flgctitg
                            ,crapalt.cdoperad = pr_log_cdoperad
                            ,crapalt.dsaltera = vr_dsaltera
          WHERE crapalt.rowid = pr_rowid_crapalt;
        EXCEPTION
          WHEN OTHERS THEN
            pr_des_reto:= 'NOK';
            --mensagem erro
            pr_dscritic:= 'Erro ao atualizar crapalt. '||SQLERRM;
        END;
      EXCEPTION
         WHEN vr_exc_erro THEN
          -- Retorno não OK
          pr_des_reto:= 'NOK';
          -- Montar descrição de erro não tratado
          pr_dscritic:= vr_dscritic;
         WHEN OTHERS THEN
          -- Retorno não OK
          pr_des_reto:= 'NOK';
          -- Montar descrição de erro não tratado
          pr_dscritic:= 'Erro não tratado na CYBE0001.pc_atualiza_crapalt '||sqlerrm;
      END;
    END pc_atualiza_crapalt;

  PROCEDURE pc_importa_arquivo_cyber(pr_dtmvto     IN DATE      --> Data de movimento
                     ,pr_des_reto   OUT VARCHAR2      --> descrição do retorno ("OK" ou "NOK")
                     ,pr_des_erro   out VARCHAR2) IS   --> descrição do erro
     /*
   Programa: pc_importa_arquivo_cyber
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Jean Calão - Mout´S
     Data    : 17/01/2017                        Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Diaria - Sempre que for chamada
     Objetivo  : Rotina para importar aquivo de atualização do CYBER.
           Arquivo a ser importado: AAAAMMDD_HHMMSS_contratos_distrib_out.txt
               Este arquivo irá atualizar a tabela CRAPCYC com dados de marcação dos contratos.
         A chamada da rotina será efetuada diariamente através de DB JOB, sempre após a atualização do CYBER;

		 20/04/2017 - colocado tratamento de excecao no INSERT da crapcyc, estava abortando o programa - Jean (Mout´s)
   */
     vr_exc_erro    EXCEPTION;
     vr_handle_log  utl_file.file_type;
     rw_crapdat     btch0001.cr_crapdat%rowtype;
     vr_des_erro    varchar2(2000);
     vr_des_log      varchar2(2000);
     vr_nm_arquivo  varchar2(2000);
     vr_nm_arqlog   varchar2(2000);
     vr_nm_direto    varchar2(2000);
     vr_linha_arq    varchar2(110);
     vr_inicio      boolean := true;
     vr_gerou_log    boolean := false;
     vr_flgjudic    number;
     vr_flextjud    number;
     vr_flgehvip    number;
     vr_cdcooper    number;
     vr_cdorigem    number;
     vr_nrdconta    number;
     vr_cdctremp    number;
     vr_cdassess    varchar2(8);
     vr_dtdistri    DATE;
     vr_nrlinha     number;
     vr_cdassessx   varchar2(8);
     vr_existecyc   number(1) := 0;

     vr_cdprogra CONSTANT crapprg.cdprogra%TYPE:= 'CYBE0001';
     --Variaveis Locais
     vr_nmtmpzip VARCHAR2(200);
     vr_idx_txt  INTEGER;
     vr_cdcritic number;

     vr_dscritic varchar2(100);
     --vr_nmtmptxt VARCHAR2(200);
     vr_nmarqzip VARCHAR2(200);
     vr_typ_saida VARCHAR2(10);
     vr_comando   VARCHAR2(4000);
     vr_listadir  VARCHAR2(4000);
     vr_endarqtxt VARCHAR2(4000);
     vr_nmtmparq  varchar2(200);
     vr_dtarquiv  date;
     vr_input_file  utl_file.file_type;
     vr_nrindice INTEGER;
     vr_bkpndice integer;
     vr_contarqv integer;

     --Tabela para armazenar arquivos lidos
     vr_tab_arqzip gene0002.typ_split;
     vr_tab_arqtxt gene0002.typ_split;

     cursor c_busca_crapcyc(pr_cdcooper number
                           ,pr_nrdconta number
                           ,pr_nrctremp number
                           ,pr_cdorigem number) is
               select flgjudic
               ,      flgehvip
               from   crapcyc
               where  cdcooper = pr_cdcooper
               and    cdorigem = decode(pr_cdorigem,2,3,pr_cdorigem)
               and    nrdconta = pr_nrdconta
               and    nrctremp = pr_nrctremp;                 
      
     cursor c_busca_assessoria(pr_cdassessoria varchar2) is
           select t.dstexprm
             from   crapprm t
             where  NMSISTEM = 'CRED'
               and  CDACESSO like 'CYBER_CD_SIGLA%'
               and  t.dsvlrprm = rtrim(pr_cdassessoria);

  BEGIN
    OPEN btch0001.cr_crapdat(pr_cdcooper => 3);
               FETCH btch0001.cr_crapdat INTO rw_crapdat;
               CLOSE btch0001.cr_crapdat;

    vr_nm_arquivo := to_char(pr_dtmvto, 'YYYYMMDD_HH24MISS') || '_contratos_distrib_out.txt';
    vr_nm_arqlog  := 'LOG_' || to_char(pr_dtmvto, 'YYYYMMDD_HH24MISS') || '_contratos_distrib.txt';

    vr_nm_direto  := gene0001.fn_diretorio(pr_tpdireto => 'M' -- /micros/coop
                                          ,pr_cdcooper => 3
                                          ,pr_nmsubdir => '/cyber/recebe/');
    vr_nm_arquivo := vr_nm_direto || '/' || vr_nm_arquivo;
    vr_nm_arqlog  := vr_nm_direto || '/' || vr_nm_arqlog;
    --==================================================================================
    -- TRATAR ARQUIVO ZIP
    --==================================================================================
    vr_nmtmpzip:= '%contratos_distrib_out.zip';

       /* Vamos ler todos os arquivos .zip */
       gene0001.pc_lista_arquivos(pr_path     => vr_nm_direto
                                 ,pr_pesq     => vr_nmtmpzip
                                 ,pr_listarq  => vr_listadir
                                 ,pr_des_erro => vr_des_erro);

       -- se ocorrer erro ao recuperar lista de arquivos registra no log
       IF trim(vr_des_erro) IS NOT NULL THEN
         btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                   ,pr_ind_tipo_log => 2 -- Erro tratato
                                   ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                    || vr_cdprogra || ' --> '
                                                    || vr_des_erro);
       END IF;

       --Carregar a lista de arquivos na temp table
       vr_tab_arqzip:= gene0002.fn_quebra_string(pr_string => vr_listadir);

       --Filtrar os arquivos da lista
       IF vr_tab_arqzip.count > 0 THEN
         vr_nrindice:= vr_tab_arqzip.first;
         -- carrega informacoes na cratqrq
         WHILE vr_nrindice IS NOT NULL LOOP
           --Filtrar a data apartir do Nome arquivo
           vr_nmtmparq:= SUBSTR(vr_tab_arqzip(vr_nrindice),1,8);
           --Transformar em Data
           vr_dtarquiv:= TO_DATE(vr_nmtmparq,'YYYYMMDD');
           --Data Arquivo entre a data anterior e proximo dia util
           IF vr_dtarquiv > rw_crapdat.dtmvtoan AND vr_dtarquiv < rw_crapdat.dtmvtopr THEN
             --Incrementar quantidade arquivos
             vr_contarqv:= vr_tab_arqzip.count + 1;
             --Proximo Registro
             vr_nrindice:= vr_tab_arqzip.next(vr_nrindice);
           ELSE
             --Diminuir quantidade arquivos
             vr_contarqv:= vr_tab_arqzip.count - 1;
             --Salvar Proximo Registro
             vr_bkpndice:= vr_tab_arqzip.next(vr_nrindice);
             --Retirar o arquivo da lista
             vr_tab_arqzip.DELETE(vr_nrindice);
             --Setar o proximo (backup) no indice
             vr_nrindice:= vr_bkpndice;
           END IF;
         END LOOP;
       END IF;

       -- Buscar Primeiro arquivo da temp table
       vr_nrindice:= vr_tab_arqzip.FIRST;
       --Processar os arquivos lidos
       WHILE vr_nrindice IS NOT NULL LOOP
         --Nome Arquivo zip
         vr_nmarqzip:= vr_tab_arqzip(vr_nrindice);

         --Nome do arquivo sem extensao
         vr_nmtmparq:= SUBSTR(vr_nmarqzip,1,LENGTH(vr_nmarqzip)-4);

         /* Montar Comando para eliminar arquivos do diretorio */
         vr_comando:= 'rm '||vr_nm_direto ||'/'||vr_nmtmparq||'/*.txt 1> /dev/null';

         --Executar o comando no unix
         GENE0001.pc_OScommand(pr_typ_comando => 'S'
                              ,pr_des_comando => vr_comando
                              ,pr_typ_saida   => vr_typ_saida
                              ,pr_des_saida   => vr_des_erro);

         /* Remover o diretorio caso exista */
         vr_comando:= 'rmdir '||vr_nm_direto||'/'||vr_nmtmparq||' 1> /dev/null';

         --Executar o comando no unix
         GENE0001.pc_OScommand(pr_typ_comando => 'S'
                              ,pr_des_comando => vr_comando
                              ,pr_typ_saida   => vr_typ_saida
                              ,pr_des_saida   => vr_des_erro);

         /*  Executar Extracao do arquivo zip */
         vr_comando:= 'unzip '||vr_nm_direto||'/'||vr_nmarqzip ||' -d ' || vr_nm_direto||'/'||vr_nmtmparq;

         --Executar o comando no unix
         GENE0001.pc_OScommand(pr_typ_comando => 'S'
                              ,pr_des_comando => vr_comando
                              ,pr_typ_saida   => vr_typ_saida
                              ,pr_des_saida   => vr_des_erro);

         --Se ocorreu erro dar RAISE
         IF vr_typ_saida = 'ERR' THEN
           vr_des_erro := 'Nao foi possivel executar comando unix. '||vr_comando||' - '||vr_des_erro;
           RAISE vr_exc_erro;
         END IF;

         /* Lista todos os arquivos .txt do diretorio criado */
         vr_endarqtxt:= vr_nm_direto||'/'||vr_nmtmparq;

         --Buscar todos os arquivos extraidos na nova pasta
         gene0001.pc_lista_arquivos(pr_path     => vr_endarqtxt
                                   ,pr_pesq     => '%contratos_distrib_out.txt'
                                   ,pr_listarq  => vr_listadir
                                   ,pr_des_erro => vr_dscritic);

         -- se ocorrer erro ao recuperar lista de arquivos registra no log
         IF trim(vr_dscritic) IS NOT NULL THEN
            btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                     ,pr_ind_tipo_log => 2 -- Erro tratato
                                     ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                      || vr_cdprogra || ' --> '
                                                      || vr_dscritic);
         END IF;

         --Carregar a lista de arquivos na temp table
         vr_tab_arqtxt:= gene0002.fn_quebra_string(pr_string => vr_listadir);

         --Se possuir arquivos no diretorio
         IF vr_tab_arqtxt.COUNT > 0 THEN

           --Selecionar primeiro arquivo
           vr_idx_txt:= vr_tab_arqtxt.FIRST;
           --Percorrer todos os arquivos lidos
           WHILE vr_idx_txt IS NOT NULL LOOP

             --Nome do arquivo
             vr_nm_arquivo := vr_tab_arqtxt(vr_idx_txt);
             --Montar Mensagem para log
             vr_cdcritic:= 219;
             --Buscar mensagem
             vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
             --Imprimir mensagem no log
             btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                       ,pr_ind_tipo_log => 2 -- Erro tratato
                                       ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                        || vr_cdprogra || ' --> '
                                                        || vr_dscritic || ' --> '||vr_nm_arquivo);
             vr_idx_txt:= vr_tab_arqtxt.NEXT(vr_idx_txt);
           end loop;

         end if;
         -- modifica nome do arquivo zip para "processado".
           vr_comando:= 'mv '||vr_nm_direto ||'/'||vr_nmtmparq||'.zip '||
                        vr_nm_direto ||'/'||vr_nmtmparq||'_processado.pro 1> /dev/null';
           --Executar o comando no unix
           GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                ,pr_des_comando => vr_comando
                                ,pr_typ_saida   => vr_typ_saida
                                ,pr_des_saida   => vr_dscritic);
           --Se ocorreu erro dar RAISE
           IF vr_typ_saida = 'ERR' THEN
             vr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
             RAISE vr_exc_erro;
           END IF;

         --Proximo arquivo zip da/ lista
         vr_nrindice:= vr_tab_arqzip.NEXT(vr_nrindice);
     end loop;
    --================================================================================

    vr_nm_arquivo := vr_endarqtxt || '/' || vr_nm_arquivo;

    /* verificar se o arquivo existe */
    if not gene0001.fn_exis_arquivo(pr_caminho => vr_nm_arquivo) then
       vr_des_erro := 'Erro rotina PC_IMPORTA_ARQUIVO_CYBER: Arquivo inexistente!' || sqlerrm;
       raise vr_exc_erro;
    end if;

    /* Abrir o arquivo */
    gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nm_arquivo
                            ,pr_tipabert => 'R'                --> Modo de abertura (R,W,A)
                            ,pr_utlfileh => vr_input_file      --> Handle do arquivo aberto
                            ,pr_des_erro => vr_des_erro);

    if vr_des_erro is not null then
       raise vr_exc_erro;
    end if;

    /* Abrir o arquivo de LOG */
    gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nm_arqlog
                            ,pr_tipabert => 'W'                --> Modo de abertura (R,W,A)
                            ,pr_utlfileh => vr_handle_log      --> Handle do arquivo aberto
                            ,pr_des_erro => vr_des_erro);

    if vr_des_erro is not null then
       vr_des_erro := 'Erro LOG: ' || vr_des_erro;
       raise vr_exc_erro;
    end if;

    /* Processar linhas do arquivo */
    vr_nrlinha := 1;

    IF utl_file.IS_OPEN(vr_input_file) then
       BEGIN
         LOOP
           vr_gerou_log := false;

           gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file
                                       ,pr_des_text => vr_linha_arq);



          -- Verifica registro Header
          if  vr_inicio
          and substr(vr_linha_arq, 1, 1) <> 'H' then -- nao possui registro Header
              vr_des_erro := 'Layout do arquivo inválido, não possui registro Header';
              raise vr_exc_erro;
          end if;

         /* -- Verifica data de geração
          if vr_inicio
          and substr(vr_linha_arq, 40,8) <> to_char(pr_dtmvto,'MMDDYYYY') then
              vr_des_erro := 'Data de geração do arquivo inválida!';
              raise vr_exc_erro;
          end if;*/

          IF substr(vr_linha_arq, 1,1)='T' THEN
             EXIT;
          END IF;

          if substr(vr_linha_arq,1,3) = '   ' then -- se for registro detalhe
            -- ler numero da cooperativa
            vr_cdcooper := substr(vr_linha_arq, 55, 4);
            -- ler modalidade de emprestimo
            vr_cdorigem := substr(vr_linha_arq, 59, 1);
            -- ler numero da conta
            vr_nrdconta := substr(vr_linha_arq, 60, 8);
            -- ler contrato
            vr_cdctremp := substr(vr_linha_arq, 68, 8);
            -- ler código da assessoria

            vr_cdassessx := rtrim(substr(vr_linha_arq, 76, 8));

            -- ler data da distribuicao para assessoria
            vr_dtdistri := to_date(substr(vr_linha_arq, 84, 8),'MMDDYYYY');

            /* verifica campos obrigatórios */
            if vr_cdcooper is null then
               vr_des_erro := 'Erro no arquivo, campo Código da Cooperativa não está preenchido!';
               raise vr_exc_erro;
            end if;

            if vr_cdorigem is null then
               vr_des_erro := 'Erro no arquivo, campo modalidade de empréstimo não está preenchido!';
               raise vr_exc_erro;
            end if;

            if vr_nrdconta is null then
               vr_des_erro := 'Erro no arquivo, campo número da conta não está preenchido!';
               raise vr_exc_erro;
            end if;

            if vr_cdctremp is null then
               vr_des_erro := 'Erro no arquivo, campo número do contrato não está preenchido!';
               raise vr_exc_erro;
            end if;

            open c_busca_assessoria(pr_cdassessoria => vr_cdassessx);
            fetch c_busca_assessoria into vr_cdassess;
             
            if c_busca_assessoria%Notfound then
               
                if nvl(vr_cdassessx,'        ') = '        ' then
                   vr_cdassess := 0;
                else
                   vr_cdassess := 99;
              end if;
              close c_busca_assessoria;
            else
              close c_busca_assessoria;
            end if;
           
            /*
               Atualizar a tabela CRAPCYC

             Regras: 1) Verificar se o contrato existe, caso contario, gerar LOG
                     2) Se o contrato estiver marcado como Judicial ou VIP (CIN) não pode ser alterado pela carga
                     2) Caso contrário efetuar a atualização do cadastro (CRAPCYC) de acordo com o contrato da
                    carga CYBER, alterando o código da assessoria e os flags judicial, extrajudicial e
                  VIP de acordo com o cadastro da assessoria

            */

            vr_flgjudic := 0;
            vr_flextjud := 0;

            /* Regra 1 - verifica o contrato */
            
            open c_busca_crapcyc(pr_cdcooper => vr_cdcooper
                                ,pr_nrdconta => vr_nrdconta
                                ,pr_nrctremp => vr_cdctremp
                                ,pr_cdorigem => vr_cdorigem);
            fetch c_busca_crapcyc into vr_flgjudic, vr_flgehvip;
            
            if c_busca_crapcyc%notfound then
                 close c_busca_crapcyc;
                 vr_des_log := 'Erro Linha: ' || vr_nrlinha || ' -> Contrato: (Coop:' || vr_cdcooper || ', origem: ' || vr_cdorigem ||
                                                ', conta:' || vr_nrdconta || ', contrato: ' || vr_cdctremp ||
                                ') não encontrado! ';
                             -- Grava arquivo de LOG
               gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                             ,pr_des_text => vr_des_log);
               BEGIN
                  INSERT INTO CRAPCYC
                    (CDCOOPER
                    ,CDORIGEM
                    ,NRDCONTA
                    ,NRCTREMP
                    ,CDOPEINC
                    ,CDASSESS
                    ,CDMOTCIN)
                    VALUES
                    (VR_CDCOOPER
                    ,decode(VR_CDORIGEM,2,3,vr_cdorigem)
                    ,VR_NRDCONTA
                    ,vr_cdctremp
                    ,' '
                    ,0
                    ,0);
                EXCEPTION
                  WHEN OTHERS THEN
                       vr_des_erro := 'Erro no INSERT da CRAPCYC: '|| sqlerrm;
                       raise vr_exc_erro;
                END;
            else 
               close c_busca_crapcyc;
            end if;
    
            /* Regra 2: Se for contrato judicial ou VIP não permite carregar, mas não gera alerta */
            if vr_flgjudic = 1
            or vr_flgehvip = 1 then
                vr_gerou_log := true;
            end if;

            if  not vr_gerou_log  --vr_des_log  is null
            and nvl(vr_cdassess,0) <> 0 then

               -- Busca data de movimento
                OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
                FETCH btch0001.cr_crapdat INTO rw_crapdat;
                CLOSE btch0001.cr_crapdat;

               -- Grava a CRAPCYC com o codigo de asessoria e com os flags de marcacao de cobranca
               BEGIN
                  UPDATE CRAPCYC
                  SET    CDASSESS = decode(vr_cdassess,0 ,null, vr_cdassess)
                  ,      FLGJUDIC = vr_flgjudic
                  ,      FLEXTJUD = 1 --vr_flextjud
                  ,      FLGEHVIP = vr_flgehvip
                  ,      DTENVCBR = decode(vr_flgjudic, 1, DTENVCBR, vr_dtdistri)
                  ,      CDOPERAD = 'cyber'
                  ,      dtaltera = rw_crapdat.dtmvtolt
                  ,      dtinclus = nvl(dtinclus, decode(vr_flgjudic, 1, DTENVCBR, vr_dtdistri)   )
                  ,      cdopeinc = decode(cdopeinc,' ', 'cyber', cdopeinc)
                  WHERE  cdcooper = vr_cdcooper
                  and    cdorigem = decode(vr_cdorigem,2,3,vr_cdorigem)  -- se vier como 2 (descontos) considerar origem 3
                  and    nrdconta = vr_nrdconta
                  and    nrctremp = vr_cdctremp;
               EXCEPTION
                  WHEN OTHERS THEN
                   vr_des_erro := 'Erro de atualizacao da CRAPCYC: '|| sqlerrm;
                   raise vr_exc_erro;
               END;

               -- atualiza CRAPCYB
               BEGIN
                  UPDATE CRAPCYB
                  SET    FLGJUDIC = vr_flgjudic
                  ,      FLEXTJUD = 1
                  ,      FLGEHVIP = vr_flgehvip
                  ,      DTMANCAD = rw_crapdat.dtmvtolt
                  WHERE  cdcooper = vr_cdcooper
                  and    cdorigem = vr_cdorigem
                  and    nrdconta = vr_nrdconta
                  and    nrctremp = vr_cdctremp;
               EXCEPTION
                  WHEN OTHERS THEN
                   vr_des_erro := 'Erro de atualizacao da CRAPCYB: '|| sqlerrm;
                   raise vr_exc_erro;
               END;

            end if;

            if  nvl(vr_cdassess,0) = 0
            and not vr_gerou_log then -- vr_des_log is null then
                BEGIN
                  UPDATE CRAPCYB
                  SET    dtmancad = rw_crapdat.dtmvtolt
                  ,      flextjud = 0
                  WHERE  cdcooper = vr_cdcooper
                  and    cdorigem = vr_cdorigem
                  and    nrdconta = vr_nrdconta
                  and    nrctremp = vr_cdctremp;
               EXCEPTION
                  WHEN OTHERS THEN
                   vr_des_erro := 'Erro de atualizacao da CRAPCYB: '|| sqlerrm;
                   raise vr_exc_erro;
               END;

               BEGIN
                  UPDATE CRAPCYC
                  SET    CDASSESS = 0
                  ,      DTENVCBR = decode(vr_flgjudic, 1, DTENVCBR, vr_dtdistri)
                  ,      CDOPERAD = 'cyber'
                  ,      DTALTERA = rw_crapdat.dtmvtolt
                  ,      flextjud = 0
                  WHERE  cdcooper = vr_cdcooper
                  and    cdorigem = decode(vr_cdorigem,2,3,vr_cdorigem) -- se vier como 2 (descontos) considerar origem 3
                  and    nrdconta = vr_nrdconta
                  and    nrctremp = vr_cdctremp;
               EXCEPTION
                  WHEN OTHERS THEN
                   vr_des_erro := 'Erro de atualizacao da CRAPCYC: '|| sqlerrm;
                   raise vr_exc_erro;
               END;

            end if;
          end if;

          vr_inicio  := false;
          vr_des_log := null;
          vr_nrlinha :=  vr_nrlinha + 1;

         END LOOP;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
          -- Fim das linhas do arquivo
          NULL;
      END;
    END IF;

    COMMIT;

    -- verifica se gerou arquivo de LOG
    if vr_gerou_log then
       vr_des_erro := 'Verifique as informacoes geradas no arquivo de LOG';
       raise vr_exc_erro;
    end if;
    -- Fecha arquivos
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log);

  EXCEPTION
      WHEN vr_exc_erro THEN
       -- fechar arquivos
       if utl_file.IS_OPEN(vr_input_file) then
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
       end if;

       if utl_file.IS_OPEN(vr_handle_log) then
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log);
       end if;

           -- Retorno não OK
           pr_des_reto := 'NOK';
           -- Montar descrição de erro não tratado
           pr_des_erro := vr_des_erro;

  END pc_importa_arquivo_cyber;

    PROCEDURE pc_altera_dados_crapcyc(pr_cdcooper in     crapcop.cdcooper%type
                                   ,pr_cdagenci in     crapass.cdagenci%type
                                   ,pr_dtmvtolt in     varchar2
                                   ,pr_nrdcaixa in     crapbcx.nrdcaixa%type
                                   ,pr_cdoperad in     crapope.cdoperad%type
                                   ,pr_nmdatela in     craptel.nmdatela%type
                                   ,pr_idorigem in     number
                                   ,pr_nrdconta in     crapass.nrdconta%type
                                   ,pr_nrctremp in     crapepr.nrctremp%type
                                   ,pr_cdorigem in     crapcyc.cdorigem%type
                                   ,pr_flgjudic in     varchar2
                                   ,pr_flextjud in     varchar2
                                   ,pr_flgehvip in     varchar2
                                   ,pr_dtenvcbr in     varchar2
                                   ,pr_cdassess in     crapcyc.cdassess%type
                                   ,pr_cdmotcin in     crapcyc.cdmotcin%type
                                   ,pr_xmllog   IN     VARCHAR2 --> XML com informacoes de LOG
                                   ,pr_cdcritic    OUT PLS_INTEGER --> Codigo da critica
                                   ,pr_dscritic    OUT VARCHAR2 --> Descricao da critica
                                   ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                   ,pr_nmdcampo    OUT VARCHAR2 --> Nome do campo com erro
                                   ,pr_des_erro    OUT VARCHAR2) IS
    
    vr_dsmsglog craplgm.dscritic%type;
    vr_contador number(2);
    vr_cdcritic crapcri.cdcritic%type;
    vr_dscritic crapcri.dscritic%type;
    vr_dsorigem craplgm.dsorigem%type;
    vr_dstransa craplgm.dstransa%type;
    vr_cddepart crapope.cddepart%type;
    vr_rowid    rowid;
    vr_exc_erro exception;
    vr_flgehvip crapcyc.flgehvip%type;
    vr_cdmotcin crapcyc.cdmotcin%type;
    vr_msgfinal varchar2(1000);
    vr_dtmvtolt date;
    vr_dtenvcbr date;
    
    cursor cr_crapope is
      select c.cddepart
        from crapope c
       where c.cdcooper = pr_cdcooper
         and c.cdoperad = pr_cdoperad;

    cursor cr_crapcyc is
      select c.rowid
           , c.flgehvip
           , c.cdmotcin
        from crapcyc c
       where c.cdcooper = pr_cdcooper
         and c.nrdconta = pr_nrdconta
         and c.nrctremp = pr_nrctremp
         and c.cdorigem = pr_cdorigem;

    rw_crapcyc cr_crapcyc%rowtype;
    rw_crapope cr_crapope%rowtype;

  begin
    vr_cdcritic := 0;
    vr_dscritic := '';
    vr_dsorigem := gene0001.vr_vet_des_origens(pr_idorigem);
    vr_dstransa := 'Alterar registros da tabela crapcyc.';
    vr_flgehvip := case pr_flgehvip when 'true' then 1 else 0 end;
    vr_cdmotcin := nvl(pr_cdmotcin,0);
    vr_dtmvtolt := to_date(pr_dtmvtolt,'dd/mm/rrrr');
    vr_dtenvcbr := to_date(pr_dtenvcbr,'dd/mm/rrrr');
    
    open cr_crapcyc;
    fetch cr_crapcyc into rw_crapcyc;
    if cr_crapcyc%notfound then
      close cr_crapcyc;
      vr_cdcritic := 0;
      vr_dscritic := 'Registro nao encontrado na tabela crapcyc!';
      raise vr_exc_erro;
    else
      close cr_crapcyc;
    end if;

    open cr_crapope;
    fetch cr_crapope into rw_crapope;
    if cr_crapope%found then
      if (nvl(rw_crapope.cddepart,0) <> 13 and rw_crapcyc.cdmotcin in (2,7) and rw_crapcyc.cdmotcin <> vr_cdmotcin) then
        vr_cdcritic := 0;
        vr_dscritic := 'Somente operadores do departamento juridico podem alterar MOTIVO CIN 2 ou 7 cadastrados previamente!';
        raise vr_exc_erro;
      end if;

      if (nvl(rw_crapope.cddepart,0) <> 13 and vr_cdmotcin in (2,7) and rw_crapcyc.cdmotcin <> vr_cdmotcin) then
        vr_cdcritic := 0;
        vr_dscritic := 'Somente operadores do departamento juridico podem alterar para MOTIVO CIN 2 e 7!';
        raise vr_exc_erro;
      end if;

      if ((rw_crapope.cddepart = 13) and (rw_crapcyc.cdmotcin in (2,7))) then
        recp0001.pc_consistir_alt_cdmotcin(pr_cdcooper => pr_cdcooper,
                                           pr_nrdconta => pr_nrdconta,
                                           pr_nrctremp => pr_nrctremp,
                                           pr_cdorigem => pr_cdorigem,
                                           pr_cdmotcin => vr_cdmotcin,
                                           pr_flgehvip => vr_flgehvip,
                                           pr_dscritic => vr_dscritic,
                                           pr_cdcritic => vr_cdcritic);

        if vr_dscritic is not null or vr_dscritic != '' then
          if vr_dscritic like '%Motivo CIN sera alterado para%' then
            vr_msgfinal := vr_dscritic;
            vr_flgehvip := 1;
            vr_cdmotcin := to_number(trim(substr(vr_dscritic,instr(vr_dscritic,':')+1)));
            vr_dscritic := 0;
            vr_dscritic := '';
          elsif vr_dscritic like '%Motivo CIN sera desabilitado%' then
            vr_msgfinal := vr_dscritic;
            vr_dscritic := 0;
            vr_dscritic := '';
            vr_flgehvip := 0;
            vr_cdmotcin := 0;
          else
            raise vr_exc_erro;
          end if;
        end if;
      end if;

      if ((rw_crapope.cddepart = 13) and (vr_cdmotcin in (2,7)) and (rw_crapcyc.cdmotcin <> vr_cdmotcin)) then
        recp0001.pc_gerar_historico_cdmotcin(pr_cdcooper => pr_cdcooper,
                                             pr_nrdconta => pr_nrdconta,
                                             pr_nrctremp => pr_nrctremp,
                                             pr_cdorigem => pr_cdorigem,
                                             pr_cdmotcin => rw_crapcyc.cdmotcin,
                                             pr_flgehvip => rw_crapcyc.flgehvip,
                                             pr_dscritic => vr_dscritic,
                                             pr_cdcritic => vr_cdcritic);

        if vr_dscritic is not null or vr_dscritic != '' then
          raise vr_exc_erro;
        end if;
      end if;
    end if;

    close cr_crapope;
    
    update crapcyc c
       set c.flgjudic = decode(pr_flgjudic,'true',1,0)
         , c.flextjud = decode(pr_flextjud,'true',1,0)
         , c.flgehvip = vr_flgehvip
         , c.cdoperad = pr_cdoperad
         , c.dtaltera = vr_dtmvtolt
         , c.dtenvcbr = vr_dtenvcbr
         , c.cdassess = nvl(pr_cdassess,0)
         , c.cdmotcin = vr_cdmotcin
     where c.rowid = rw_crapcyc.rowid;
    
    vr_dsmsglog := 'Contrato: ' || trim(gene0002.fn_mask_contrato(pr_nrctremp)) ||
                   '. Jud.: ' || case pr_flgjudic when 'true' then 'Sim' else 'Nao' end ||
                   '. Extra Jud.: ' || case pr_flextjud when 'true' then 'Sim' else 'Nao' end ||
                   '. CIN: ' || case pr_flgehvip when 'true' then 'Sim' else 'Nao' end;

    gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                         pr_cdoperad => pr_cdoperad,
                         pr_dscritic => vr_dsmsglog,
                         pr_dsorigem => vr_dsorigem,
                         pr_dstransa => vr_dstransa,
                         pr_dttransa => trunc(sysdate),
                         pr_flgtrans => 1,
                         pr_hrtransa => to_number(to_char(sysdate,'SSSSS')),
                         pr_idseqttl => 1,
                         pr_nmdatela => pr_nmdatela,
                         pr_nrdconta => pr_nrdconta,
                         pr_nrdrowid => vr_rowid);

    update crapcyb c
       set c.dtmancad = vr_dtmvtolt
     where c.cdcooper = pr_cdcooper
       and c.nrdconta = pr_nrdconta
       and c.cdorigem in (1,2,3);
    
    if vr_msgfinal is not null then
      vr_msgfinal := vr_msgfinal||'. ';
    end if;
    
    pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Msg>' || vr_msgfinal || '</Msg></Root>');

    commit;
  exception
    when vr_exc_erro then
      if vr_cdcritic <> 0 then
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      end if;

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      
      rollback;
    when others then
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela CADCYB: ' || SQLERRM;

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      
      rollback;
  end;

END CYBE0001;
/
