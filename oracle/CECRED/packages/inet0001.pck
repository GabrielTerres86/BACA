CREATE OR REPLACE PACKAGE CECRED.inet0001 AS

/*..............................................................................

    Programa: inet001                         Antiga: b1wgen0015.p
    Autor   : Evandro
    Data    : Abril/2006                      Ultima Atualizacao: 17/02/2016

    Dados referentes ao programa:

    Objetivo  : BO para controlar horarios, limites e saldo em operacoes da
                internet e executar a transferencia entre contas.

    Alteracoes: 09/08/2007 - Preparada procedure para validar diversas
                             operacoes da internet e nao somente a
                             transferencia (Evandro).
                28/09/2007 - Acrescentada validacao do limite quando for = 0 na
                             procedure verifica_operacao (David);
                           - Deletar procedures persistentes (Evandro).

                31/10/2007 - Incluida procedure verifica_limite_saque (Diego).

                16/11/2007 - Alterar param para BO que gera protocolo (David).

                20/11/2007 - Alteracao para o Sistema EXTRACASH (Ze).

                21/12/2007 - Horario especial para pagamentos em finais de
                             semana e feriados (David).

                27/12/2007 - Alteracao para o Sistema EXTRACASH (Ze).

                28/12/2007 - Tratamento para contas juridicas (David).

                31/01/2008 - Incluir nro cartao no executa transferencia (Ze).

                14/02/2008 - Incluir procedures para rotina de Tele-Atendimento
                           - Incluir procedures para rotina de Internet
                             (David).

                12/03/2008 - Alterar crapnsu para uma transacao isolada (Ze).

                08/04/2008 - Implementar agendamento de pagamentos e
                             transferencias (David).

                19/06/2008 - Incluir procedures para rotina de Internet (David)

                02/09/2008 - Nao permitir transferencia para mesma Conta
                            (Diego).

                19/12/2008 - Nao permitir pagamentos e agendamentos (pagamentos
                             e transferencias) para o dia 31/12 (David).

                20/05/2009 - Alterar tratamento para verificacao de registros
                             que estao com EXCLUSIVE-LOCK (David).

                27/07/2009 - Alteracoes do Projeto de Transferencia para
                             Credito de Salario (David).

                02/10/2009 - Aumento do campo nrterfin (Diego).

                04/01/2010 - Alterar tratamento para nao permitir pagamentos
                             no ultimo dia util do ano (David).

                22/04/2010 - Verificar se existem agendamentos pendentes no
                             cancelamento do acesso ao InternetBank (David).

                30/04/2010 - Adequacoes para o novo sistema cash, criada a
                             origem como 3 para manter o funcionamento da
                             BO para o cash da foton (Evandro).

                19/05/2010 - Acerto no SUBSTRING do campo craplcm.cdpesqbb
                             (Diego).

                24/09/2010 - Bloquear agendamentos para o PAC 5 da Creditextil,
                             referente a sobreposicao de PACs (David).

                21/10/2010 - Bloquear recebimento de transferencia para contas
                             do PAC 5 da Creditextil, referente a sobreposicao
                             de PAC (David).

                10/01/2011 - Retirar tratamentos que tratam de cobranca na
                             rotina de INTERNET da ATENDA (Gabriel).

                24/02/2011 - Validar agendamento recorrente de transferenci
                             para data passada (David).

                01/05/2011 - Ajustes para a utilizacao das rotinas de
                             transferencias no TAA Compartilhado (Henrique).

                22/06/2011 - Ajustes na proc. horario_operacao, retirado o
                             return NOK quando estouro de tempo (Jorge).

                05/08/2011 - Efetuar geracao de protocolo (Gabriel).

                05/10/2011 - Adaptacoes para Operadores internet (Guilherme).

                25/11/2011 - Ajustar posicao do termo AGENDADO no campo
                             cdpesqbb na execucao de transferencia (David).

                25/04/2012 - Criadas novas procedures para rotina INTERNET da
                             tela ATENDA (Lucas).

                11/05/2012 - Projeto TED Internet (David);
                           - Eliminar EXTENT vldmovto (Evandro).

                19/06/2012 - Alteracao na leitura da craptco (David Kruger).

                02/07/2012 - Alterado o campo aux_dslitera (David Kruger).
                           - Validar caracteres especiais no nome do favorecido
                             para transferencia de TED (David Kistner).

                09/07/2012 - Alterado valor do par¿metro com C¿d. do Hist¿rico
                             da chamada da procedure 'grava-autenticacao' (Lucas).

                20/07/2012 - Tratamento dos valores de limite pessoa juridica e
                             pessoa fisica na procedure valida-dados-limites (Lucas R.).

                08/11/2012 - Tratamento para Viacredi Alto Vale (David).

                28/11/2012 - Tratamento para evitar agendamentos de contas
                             migradas - tabela craptco - TAA (Evandro).

                11/12/2012 - Tratamento para buscar valores e gravar dos novos campos
                             dtlimtrf, dtlimpgo, dtlimted e  dtlimweb (Daniel).

                17/12/2012 - Tratamento para impedir credito de transferencia
                             para conta migrada (David).

                02/01/2013 - Ajuste bloqueio pagamentos no ultimo dia util do
                             ano (David).
                           - Alterada a procedure 'liberar-senha-internet' para
                             verificar se o cooperado possui letras cadastradas (Lucas).

                14/01/2013 - Retirado controle de registro em LOCK para a tabela craptab
                             na procedure horario_operacao (Daniel).

                27/03/2013 - Transferencia intercooperativa (Gabriel).

                18/04/2013 - Cadastro de limites Vr Boleto (David Kruger).

                25/06/2013 - Convers¿o Progress para Oracle (Alisson - AMcom)

                11/07/2013   Altera¿¿es na procedure 'executa-transferencia-intercooperativa':
                           - Gravar campos corretos da crapmvi de acordo com tipo de pessoa
                           - Alterada cr¿tica "TED invalida"
                           - Tratamento para informar flag de agendamento
                             na chamada da procedure 'gera_protocolo' (Lucas).

                22/07/2013 - Implementacao de bloqueio de senha. (Jorge)


                23/07/2013 - Retirado buscar valor tarifa TED da craptab na
                             procedure verifica_operacao, sera utilizado
                             procedure busca-tarifa-ted da b1crap20 (Daniel).

                17/09/2013 - Ajuste Tranf.Intercooperativa TAA. Separar
                             validacoes especificas da Internet. (David).

                20/09/2013 - Alteracao de PAC/P.A.C para PA. (James)

                23/09/2013 - Ajuste na leitura de preposto na Tranferencia
                             Intercooperativa via Internet (David).

                27/09/2013 - Ajustar bloqueio de agendamentos para migracao
                             Acredi-Viacredi (David).

                30/10/2013 - Incluida procedure cria_senha_ura para permitir
                             criar senha da ura pela tela atenda (Oliver - GATI).

                16/12/2013 - Retirar bloqueio de transferencia para PAC migrado.
                             Validacao ja esta sendo feita na procedure
                             verifica_operacao, verificando se o cooperado
                             esta demitido (David).

                19/12/2013 - Adicionado validate para as tabelas crapmvi,
                             crapltr, crablcm, crapsnh, crapcti (Tiago).

                13/01/2014 - Alterada critica de "Agencia nao cadastrada" para
                             "PA nao cadastrado". (Reinert)

                24/01/2014 - Incluir procedure valida_senha_ura para validar
                             criacao/alteracao da senha URA.
                           - Adicionar bloco de transacao e validacoes na
                             procedure cria_senha_ura.
                           - Incluir parametro aux_dtmvtolt na procedure
                             altera_senha_ura;
                           - Remodelar procedure carrega_dados_ura. (Reinert)

		        19/02/2014 - Alterações do progress entre 30/10/2013 e 24/01/2014.
				                 Somente implementei a alteração do dia 13/01/2014, as
							           demais não foram necessárias. (Daniel - Supero)

            20/05/2014 - Ajuste em proc. pc_verifica_operacao. para verificar
                         se conta destino corresponde a cooperativa.
                         (Jorge/Adriano) SD - Emergencial

            20/05/2014 - Alteração procedure "pc_horario_operacao" para
                         quando pr_inpessoa for maior que 1 utilizar 2.
                         Alterado procedure "pc_horario_operacao" para
                         utilizar as variáveis de critica e somente no
                         tratamento da exceção utilizar a pr_cdcritic e
                         pr_dscritic (Douglas - Chamado 158501)

            03/09/2014 - Incluido verificacao na procedure pc_verifica_operacao
                         para migracao (Jean Michel).

            17/02/2016 - Excluido validacao de conta nao cadastrada para TED, 
						 pc_verifica_operacao (Jean Michel).

..............................................................................*/

  --Tipo de Registro para limites
  TYPE typ_reg_limite IS
    RECORD (hrinipag VARCHAR2(5)
           ,hrfimpag VARCHAR2(5)
           ,nrhorini INTEGER
           ,nrhorfim INTEGER
           ,idesthor INTEGER
           ,iddiauti INTEGER       /* 1 - Dia util / 2 - Dia nao util */
           ,flsgproc BOOLEAN
           ,qtmesagd INTEGER
           ,idtpdpag INTEGER);    /* 1 - Transf / 2 - Pagamento */

  --Tipo de tabela de memoria para limites
  TYPE typ_tab_limite IS TABLE OF typ_reg_limite INDEX BY PLS_INTEGER;

  --Tipo de Registro para Limites internet
  TYPE typ_reg_internet IS
    RECORD (idseqttl crapsnh.idseqttl%TYPE
           /* Limite totais */
           ,vllimweb crapsnh.vllimweb%TYPE
           ,vllimpgo crapsnh.vllimpgo%TYPE
           ,vllimtrf crapsnh.vllimtrf%TYPE
           ,vllimted crapsnh.vllimted%TYPE
           ,vllimvrb crapsnh.vllimted%TYPE
           /* Limite utilizado */
           ,vlutlweb crapsnh.vllimweb%TYPE
           ,vlutlpgo crapsnh.vllimpgo%TYPE
           ,vlutltrf crapsnh.vllimtrf%TYPE
           ,vlutlted crapsnh.vllimted%TYPE
           /* Limite disponivel */
           ,vldspweb crapsnh.vllimweb%TYPE
           ,vldsppgo crapsnh.vllimpgo%TYPE
           ,vldsptrf crapsnh.vllimtrf%TYPE
           ,vldspted crapsnh.vllimted%TYPE
           /* Limite operacional cadastrado pela cooperativa */
           ,vlwebcop crapsnh.vllimweb%TYPE
           ,vlpgocop crapsnh.vllimpgo%TYPE
           ,vltrfcop crapsnh.vllimtrf%TYPE
           ,vltedcop crapsnh.vllimted%TYPE
           ,vlvrbcop crapsnh.vllimted%TYPE);

  --Tipo de tabela para limite internet
  TYPE typ_tab_internet IS TABLE OF typ_reg_internet INDEX BY PLS_INTEGER;

  /* Procedure para verificar horario permitido para transacoes */
  PROCEDURE pc_horario_operacao (pr_cdcooper IN crapcop.cdcooper%type  --C¿digo Cooperativa
                                ,pr_cdagenci IN crapage.cdagenci%type  --Agencia do Associado
                                ,pr_tpoperac IN INTEGER                --Tipo de Operacao (0=todos)
                                ,pr_inpessoa IN crapass.inpessoa%type  --Tipo de Pessoa
                                ,pr_tab_limite OUT INET0001.typ_tab_limite --Tabelas de retorno de horarios limite
                                ,pr_cdcritic   OUT INTEGER     --C¿digo do erro
                                ,pr_dscritic   OUT VARCHAR2);   --Descricao do erro

  /* Procedure para buscar os limites para internet */
  PROCEDURE pc_busca_limites (pr_cdcooper     IN crapcop.cdcooper%type        --C¿digo Cooperativa
                             ,pr_nrdconta     IN crapass.nrdconta%TYPE        --Numero da conta
                             ,pr_idseqttl     IN crapttl.idseqttl%TYPE        --Identificador Sequencial titulo
                             ,pr_flglimdp     IN BOOLEAN                      --Indicador limite deposito
                             ,pr_dtmvtopg     IN crapdat.dtmvtolt%TYPE        --Data do proximo pagamento
                             ,pr_flgctrag     IN BOOLEAN                      --Indicador validacoes
                             ,pr_dsorigem     IN craplau.dsorigem%TYPE        --Descricao Origem
                             ,pr_tab_internet OUT INET0001.typ_tab_internet   --Tabelas de retorno de horarios limite
                             ,pr_cdcritic     OUT INTEGER        --Codigo do erro
                             ,pr_dscritic     OUT VARCHAR2);     -- Descricao do Erro

  /** Procedure para validar limites para transacoes (Transf./Pag./Cob.) **/
  PROCEDURE pc_verifica_operacao (pr_cdcooper IN crapcop.cdcooper%type  --C¿digo Cooperativa
                                 ,pr_cdagenci IN crapage.cdagenci%type  --Agencia do Associado
                                 ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE  --Numero caixa
                                 ,pr_nrdconta IN crapass.nrdconta%TYPE  --Numero da conta
                                 ,pr_idseqttl IN crapttl.idseqttl%TYPE  --Identificador Sequencial titulo
                                 ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --Data Movimento
                                 ,pr_idagenda IN INTEGER                --Indicador agenda
                                 ,pr_dtmvtopg IN craplau.dtmvtopg%TYPE  --Data Pagamento
                                 ,pr_vllanmto IN OUT craplcm.vllanmto%TYPE  --Valor Lancamento
                                 ,pr_cddbanco IN crapcti.cddbanco%TYPE  --Codigo banco
                                 ,pr_cdageban IN crapcti.cdageban%TYPE  --Codigo Agencia
                                 ,pr_nrctatrf IN crapcti.nrctatrf%TYPE  --Numero Conta Transferencia
                                 ,pr_cdtiptra IN INTEGER  /* 1 - Transferencia / 2 - Pagamento / 3 - Credito Salario / 4 - TED */
                                 ,pr_cdoperad IN crapope.cdoperad%TYPE  --Codigo Operador
                                 ,pr_tpoperac IN INTEGER  /* 1 - Transferencia intracooperativa / 2 - Pagamento / 3 - Cobranca /  */     /* 4 - TED / 5 - Transferencia intercooperativa */
                                 ,pr_flgvalid IN BOOLEAN                --Indicador validacoes
                                 ,pr_dsorigem IN craplau.dsorigem%TYPE  --Descricao Origem
                                 ,pr_nrcpfope IN crapopi.nrcpfope%TYPE  --CPF Operador
                                 ,pr_flgctrag IN BOOLEAN /* controla validacoes na efetivacao de agendamentos */
                                 ,pr_nmdatela IN VARCHAR2
                                 ,pr_dstransa   OUT VARCHAR2               --Descricao da transacao
                                 ,pr_tab_limite OUT INET0001.typ_tab_limite --Tabelas de retorno de horarios limite
                                 ,pr_tab_internet OUT INET0001.typ_tab_internet --Tabelas de retorno de horarios limite
                                 ,pr_cdcritic   OUT INTEGER     --C¿digo do erro
                                 ,pr_dscritic   OUT VARCHAR2);   --Descricao do erro

  /** Chamada para ser utilizada no Progress -
      Procedure para validar limites para transacoes (Transf./Pag./Cob.) **/
  PROCEDURE pc_verifica_operacao_prog ( pr_cdcooper IN crapcop.cdcooper%type  -- Codigo Cooperativa
                                       ,pr_cdagenci IN crapage.cdagenci%type  -- Agencia do Associado
                                       ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE  -- Numero caixa
                                       ,pr_nrdconta IN crapass.nrdconta%TYPE  -- Numero da conta
                                       ,pr_idseqttl IN crapttl.idseqttl%TYPE  -- Identificador Sequencial titulo
                                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  -- Data Movimento
                                       ,pr_idagenda IN INTEGER                -- Indicador agenda
                                       ,pr_dtmvtopg IN craplau.dtmvtopg%TYPE  -- Data Pagamento
                                       ,pr_vllanmto IN OUT craplcm.vllanmto%TYPE  --Valor Lancamento
                                       ,pr_cddbanco IN crapcti.cddbanco%TYPE  -- Codigo banco
                                       ,pr_cdageban IN crapcti.cdageban%TYPE  -- Codigo Agencia
                                       ,pr_nrctatrf IN crapcti.nrctatrf%TYPE  -- Numero Conta Transferencia
                                       ,pr_cdtiptra IN INTEGER                -- 1 - Transferencia / 2 - Pagamento /3 - Credito Salario / 4 - TED
                                       ,pr_cdoperad IN crapope.cdoperad%TYPE  -- Codigo Operador
                                       ,pr_tpoperac IN INTEGER                -- 1 - Transferencia intracooperativa /2 - Pagamento /3 - Cobranca /4 - TED / 5 - Transferencia intercooperativa
                                       ,pr_flgvalid IN INTEGER                -- (0- False, 1-True)Indicador validacoes
                                       ,pr_dsorigem IN craplau.dsorigem%TYPE  -- Descricao Origem
                                       ,pr_nrcpfope IN crapopi.nrcpfope%TYPE  -- CPF operador
                                       ,pr_flgctrag IN INTEGER                -- (0- False, 1-True)controla validacoes na efetivacao de agendamentos
                                       ,pr_nmdatela IN VARCHAR2
                                       ,pr_dstransa   OUT VARCHAR2            -- Descricao da transacao
                                       ,pr_tab_limite OUT CLOB                -- Tabelas de retorno de horarios limite
                                       ,pr_tab_internet OUT CLOB              -- Tabelas de retorno de horarios limite
                                       ,pr_cdcritic   OUT INTEGER             -- Codigo do erro
                                       ,pr_dscritic   OUT VARCHAR2);          -- Descricao do erro

  /* Validar a conta de destino da transferencia */
  PROCEDURE pc_valida_conta_destino (pr_cdcooper IN crapcop.cdcooper%type  --Codigo Cooperativa
                                    ,pr_cdagenci IN crapage.cdagenci%type  --Agencia do Associado
                                    ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE  --Numero caixa
                                    ,pr_cdoperad IN crapope.cdoperad%TYPE  --Codigo Operador
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE  --Numero da conta
                                    ,pr_idseqttl IN crapttl.idseqttl%TYPE  --Identificador Sequencial titulo
                                    ,pr_cdagectl IN crapcti.cdageban%TYPE  --Codigo Agencia
                                    ,pr_nrctatrf IN crapcti.nrctatrf%TYPE  --Numero Conta Transferencia
                                    ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --Data Movimento
                                    ,pr_cdtiptra IN INTEGER                --Tipo de Transferencia
                                    ,pr_flgctafa OUT BOOLEAN               --Indicador conta cadastrada
                                    ,pr_nmtitula OUT VARCHAR2              --Nome titular
                                    ,pr_nmtitul2 OUT VARCHAR2              --Nome segundo titular
                                    ,pr_cddbanco OUT INTEGER               --Codigo banco
                                    ,pr_dscritic OUT VARCHAR2              --Retorno OK/NOK
                                    ,pr_tab_erro OUT GENE0001.typ_tab_erro); --Tabela de retorno de erro
  
END INET0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.inet0001 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : INET0001
  --  Sistema  : Procedimentos para o debito de agendamentos feitos na Internet
  --  Sigla    : CRED
  --  Autor    : Alisson C. Berrido - Amcom
  --  Data     : Junho/2013.                   Ultima atualizacao: 28/07/2015
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos para agendamentos na Internet
  
  -- Alteracoes: 20/05/2014 - Alteração procedure "pc_horario_operacao" para
  --                          quando pr_inpessoa for maior que 1 utilizar 2.
  --                          Alterado procedure "pc_horario_operacao" para
  --                          utilizar as variáveis de critica e somente na 
  --                          tratamento da exceção utilizar a pr_cdcritic e 
  --                          pr_dscritic (Douglas - Chamado 158501)
  --
  --             03/09/2014 - Incluido verificacao na procedure pc_verifica_operacao
  --                          para migracao (Jean Michel).
  --
  --             28/07/2015 - Ajustar o tratamento de erros para quando executar o raise 
  --                          o erro seja carregado na tabela de erros e devolvida a rotina 
  --                          que chamou. (Douglas - Chamado 312756)
  --
  --             17/03/2016 - Alteracao da mensagem de limite diário onde faltava acento na letra
  --                          "e" conforme solicitado no chamado 415482 (Kelvin)             
  --
  --             04/04/2016 - Correcao no tratamento de uso dos sistema PAG e STR na 
  --                          pc_horario_operacao para que ao usar ambos seja verificado 
  --                          a hora inicio e fim de operacao quando habilitados. 
  --                          (SD 428886 - Carlos Rafael Tanholi)                      
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
          ,crapcop.hriniatr
          ,crapcop.hrfimatr
      FROM crapcop
     WHERE crapcop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

  /* Buscar dados das agencias */
  CURSOR cr_crapage (pr_cdcooper IN crapage.cdcooper%type
                    ,pr_cdagenci IN crapage.cdagenci%type) IS
    SELECT crapage.nmresage
          ,crapage.qtddaglf
    FROM crapage
    WHERE crapage.cdcooper = pr_cdcooper
    AND   crapage.cdagenci = pr_cdagenci;
  rw_crapage cr_crapage%ROWTYPE;

  /* Busca dos dados do associado */
  CURSOR cr_crapass(pr_cdcooper IN craptab.cdcooper%TYPE
                   ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT crapass.cdcooper
          ,crapass.nrdconta
          ,crapass.nmprimtl
          ,crapass.nmsegntl
          ,crapass.inpessoa
          ,crapass.cdagenci
          ,crapass.vllimcre
          ,crapass.dtdemiss
          ,crapass.idastcjt
      FROM crapass
     WHERE crapass.cdcooper = pr_cdcooper
     AND   crapass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;

  --Selecionar informacoes de senhas
  CURSOR cr_crapsnh (pr_cdcooper IN crapsnh.cdcooper%type
                    ,pr_nrdconta IN crapsnh.nrdconta%type
                    ,pr_idseqttl IN crapsnh.idseqttl%type
                    ,pr_tpdsenha IN crapsnh.tpdsenha%type) IS
    SELECT crapsnh.nrcpfcgc
          ,crapsnh.cdcooper
          ,crapsnh.nrdconta
          ,crapsnh.idseqttl
          ,crapsnh.vllimweb
          ,crapsnh.vllimpgo
          ,crapsnh.vllimtrf
          ,crapsnh.vllimted
          ,crapsnh.vllimvrb
    FROM crapsnh
    WHERE crapsnh.cdcooper = pr_cdcooper
    AND   crapsnh.nrdconta = pr_nrdconta
    AND   crapsnh.idseqttl = pr_idseqttl
    AND   crapsnh.tpdsenha = pr_tpdsenha;
  rw_crapsnh cr_crapsnh%ROWTYPE;

  --Selecionar contas transferencia cadastradas internet
  CURSOR cr_crapcti (pr_cdcooper IN crapcti.cdcooper%type
                    ,pr_cddbanco IN crapcti.cddbanco%type
                    ,pr_cdageban IN crapcti.cdageban%type
                    ,pr_nrdconta IN crapcti.nrdconta%type
                    ,pr_nrctatrf IN crapcti.nrctatrf%type) IS
    SELECT crapcti.insitcta
    FROM crapcti
    WHERE crapcti.cdcooper = pr_cdcooper
    AND   crapcti.cddbanco = pr_cddbanco
    AND   crapcti.cdageban = pr_cdageban
    AND   crapcti.nrdconta = pr_nrdconta
    AND   crapcti.nrctatrf = pr_nrctatrf;
  rw_crapcti cr_crapcti%ROWTYPE;

  /* Procedure para verificar horario permitido para transacoes */
  PROCEDURE pc_horario_operacao (pr_cdcooper IN crapcop.cdcooper%TYPE        --C¿digo Cooperativa
                                ,pr_cdagenci IN crapage.cdagenci%type        --Agencia do Associado
                                ,pr_tpoperac IN INTEGER                      --Tipo de Operacao (0=todos)
                                ,pr_inpessoa IN crapass.inpessoa%type        --Tipo de Pessoa
                                ,pr_tab_limite OUT INET0001.typ_tab_limite   --Tabelas de retorno de horarios limite
                                ,pr_cdcritic   OUT INTEGER     --C¿digo do erro
                                ,pr_dscritic   OUT VARCHAR2) IS --Descricao do erro
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_horario_operacao           Antigo: b1wgen0015.p/horario_operacao
  --  Sistema  : Procedimentos para o debito de agendamentos feitos na Internet
  --  Sigla    : CRED
  --  Autor    : Alisson C. Berrido - Amcom
  --  Data     : Junho/2013.                   Ultima atualizacao: 17/12/2015
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para verificar horario permitido para transacoes
  --
  -- Alteração : 26/10/2015 - Inclusao de verificacao indicador estado de crise. (Jaison/Andrino)
  --
  --             17/12/2015 - Alterado idtpdpag de VRBOLETO de 3 para 6. 
  --                          Adicionado verificacao de horario para Debito Automatico Facil
  --                          (Jorge/David) Proj. 131 - Assinatura Multipla.
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      --Variaveis Locais
      vr_flsgproc BOOLEAN;
      vr_hrinipag INTEGER;
      vr_hrfimpag INTEGER;
      vr_qtmesagd INTEGER;
      vr_hratual  INTEGER;
      vr_idesthor INTEGER;
      vr_iddiauti INTEGER;
      vr_datdodia DATE;
      --Variaveis de Erro
      vr_dstextab craptab.dstextab%TYPE;
      --Variaveis de Erro
      vr_cdcritic crapcri.cdcritic%type;
      vr_dscritic VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;
      --Variaveis de Indice
      vr_index_limite INTEGER;
      -- Tipo de pessoa para buscar o horario limite
      vr_inpessoa INTEGER;
      vr_inestcri INTEGER;
      vr_clobxmlc CLOB;
      vr_flgutstr BOOLEAN; 
      vr_flgutpag BOOLEAN;      
    BEGIN
      --Inicializar varaivel retorno erro
      vr_cdcritic:= NULL;
      vr_dscritic:= NULL;

      --Limpar tabela memoria
      pr_tab_limite.DELETE;

      -- Se for para todos ou for ted ou for vr-boleto
      IF pr_tpoperac IN (0,4,6)  THEN
        -- Busca o indicador estado de crise
        SSPB0001.pc_estado_crise (pr_inestcri => vr_inestcri
                                 ,pr_clobxmlc => vr_clobxmlc);

        -- Se estiver setado como estado de crise
        IF  vr_inestcri > 0  THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Sistema indisponivel no momento. Tente mais tarde!';
            RAISE vr_exc_erro;
        END IF;
      END IF;

      --Se o tipo de operacao for Todos (0), Transferencia(1) ou Pagamento(2) ou (5) Intercooperativa
      IF pr_tpoperac IN (0,1,2,5)  THEN
        --Determinar tipo pessoa para busca limite
        IF pr_inpessoa > 1 THEN
          vr_inpessoa:= 2;
        ELSE
          vr_inpessoa:= pr_inpessoa;
        END IF;      
        --Selecionar Horarios Limites Internet
        vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                ,pr_nmsistem => 'CRED'
                                                ,pr_tptabela => 'GENERI'
                                                ,pr_cdempres => 0
                                                ,pr_cdacesso => 'LIMINTERNT'
                                                ,pr_tpregist => vr_inpessoa);

        --Se nao encontrou
        IF vr_dstextab IS NULL THEN
          vr_cdcritic:= 0;
          vr_dscritic := 'Tabela (LIMINTERNT) nao cadastrada.';
          --Levantar Excecao
          RAISE vr_exc_erro;
        ELSE
          --Atribuir quantidade meses agendados
          vr_qtmesagd:= To_Number(gene0002.fn_busca_entrada(5,vr_dstextab,';'));
        END IF;
      END IF;

      /** Horario diferenciado para finais de semana e feriados **/
      vr_datdodia:= PAGA0001.fn_busca_datdodia(pr_cdcooper => pr_cdcooper);

      --Se for para todos ou for transferencia
      IF pr_tpoperac IN (0,1,5)  THEN
        /** Verifica horario inicial e final para transferencias **/
        vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                ,pr_nmsistem => 'CRED'
                                                ,pr_tptabela => 'GENERI'
                                                ,pr_cdempres => 0
                                                ,pr_cdacesso => 'HRTRANSFER'
                                                ,pr_tpregist => pr_cdagenci);
        --Se nao encontrou
        IF vr_dstextab IS NULL THEN
          vr_cdcritic:= 0;
          vr_dscritic := 'Tabela (HRTRANSFER) nao cadastrada.';
          --Levantar Excecao
          RAISE vr_exc_erro;
        ELSE
          --Determinar se ¿ segundo processo
          vr_flsgproc:=  SUBSTR(Upper(vr_dstextab),15,3) = 'SIM';
          /** Horario diferenciado para finais de semana e feriados **/
          vr_datdodia:= GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                   ,pr_dtmvtolt => SYSDATE
                                                   ,pr_tipo     => 'P');
          --Se for feriado
          IF Trunc(vr_datdodia) <> Trunc(SYSDATE) THEN
            --Hora de inicio
            vr_hrinipag:= 21600; /** 06:00 horas **/
            --Hora Fim
            vr_hrfimpag:= 82800; /** 23:00 horas **/
          ELSE
            --Hora de inicio
            vr_hrinipag:= SubStr(vr_dstextab,9,5);
            --Hora Fim
            vr_hrfimpag:= SubStr(vr_dstextab,3,5);
          END IF;

          --Determinar a hora atual
          vr_hratual:= GENE0002.fn_busca_time;

          --Verificar se estourou o limite
          IF vr_hratual < vr_hrinipag OR vr_hratual > vr_hrfimpag THEN
            --Estourou limite
            vr_idesthor:= 1;
          ELSE
            --Dentro do Horario limite
            vr_idesthor:= 2;
          END IF;

          --Criar registro para tabela limite horarios
          vr_index_limite:= pr_tab_limite.Count+1;
          pr_tab_limite(vr_index_limite).hrinipag:= GENE0002.fn_converte_time_data(vr_hrinipag);
          pr_tab_limite(vr_index_limite).hrfimpag:= GENE0002.fn_converte_time_data(vr_hrfimpag);
          pr_tab_limite(vr_index_limite).nrhorini:= vr_hrinipag;
          pr_tab_limite(vr_index_limite).nrhorfim:= vr_hrfimpag;
          pr_tab_limite(vr_index_limite).idesthor:= vr_idesthor;
          pr_tab_limite(vr_index_limite).iddiauti:= NULL;
          pr_tab_limite(vr_index_limite).flsgproc:= vr_flsgproc;
          pr_tab_limite(vr_index_limite).qtmesagd:= vr_qtmesagd;
          pr_tab_limite(vr_index_limite).idtpdpag:= 1;
        END IF;
      END IF;

      --Se for para todos ou for pagamento
      IF pr_tpoperac IN (0,2)  THEN
        /** Verifica horario limite para pagamentos via internet **/
        vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                ,pr_nmsistem => 'CRED'
                                                ,pr_tptabela => 'GENERI'
                                                ,pr_cdempres => 0
                                                ,pr_cdacesso => 'HRTRTITULO'
                                                ,pr_tpregist => pr_cdagenci);
        --Se nao encontrou
        IF vr_dstextab IS NULL THEN
          vr_cdcritic:= 0;
          vr_dscritic := 'Tabela (HRTRTITULO) nao cadastrada.';
          --Levantar Excecao
          RAISE vr_exc_erro;
        ELSE
          --Determinar se ¿ segundo processo
          vr_flsgproc:=  SUBSTR(Upper(vr_dstextab),15,3) = 'SIM';
          /** Horario diferenciado para finais de semana e feriados **/
          vr_datdodia:= GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                   ,pr_dtmvtolt => SYSDATE
                                                   ,pr_tipo     => 'P');
          --Se for feriado
          IF Trunc(vr_datdodia) <> Trunc(SYSDATE) THEN
            --Hora de inicio
            vr_hrinipag:= 21600; /** 06:00 horas **/
            --Hora Fim
            vr_hrfimpag:= 82800; /** 23:00 horas **/
          ELSE
            --Hora de inicio
            vr_hrinipag:= SubStr(vr_dstextab,9,5);
            --Hora Fim
            vr_hrfimpag:= SubStr(vr_dstextab,3,5);
          END IF;

          --Determinar a hora atual
          vr_hratual:= GENE0002.fn_busca_time;

          --Verificar se estourou o limite
          IF vr_hratual < vr_hrinipag OR vr_hratual > vr_hrfimpag THEN
            --Estourou limite
            vr_idesthor:= 1;
          ELSE
            --Dentro do Horario limite
            vr_idesthor:= 2;
          END IF;

          --Criar registro para tabela limite horarios
          vr_index_limite:= pr_tab_limite.Count+1;
          pr_tab_limite(vr_index_limite).hrinipag:= GENE0002.fn_converte_time_data(vr_hrinipag);
          pr_tab_limite(vr_index_limite).hrfimpag:= GENE0002.fn_converte_time_data(vr_hrfimpag);
          pr_tab_limite(vr_index_limite).nrhorini:= vr_hrinipag;
          pr_tab_limite(vr_index_limite).nrhorfim:= vr_hrfimpag;
          pr_tab_limite(vr_index_limite).idesthor:= vr_idesthor;
          pr_tab_limite(vr_index_limite).iddiauti:= NULL;
          pr_tab_limite(vr_index_limite).flsgproc:= vr_flsgproc;
          pr_tab_limite(vr_index_limite).qtmesagd:= vr_qtmesagd;
          pr_tab_limite(vr_index_limite).idtpdpag:= 2;
        END IF;
      END IF;

      --Se for para todos ou for cobranca
      IF pr_tpoperac IN (0,3)  THEN
        /** Verifica horario inicial e final para geracao de cobranca **/
        vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                ,pr_nmsistem => 'CRED'
                                                ,pr_tptabela => 'GENERI'
                                                ,pr_cdempres => 0
                                                ,pr_cdacesso => 'HRCOBRANCA'
                                                ,pr_tpregist => pr_cdagenci);
        --Se nao encontrou
        IF vr_dstextab IS NULL THEN
          vr_cdcritic:= 0;
          vr_dscritic := 'Tabela (HRCOBRANCA) nao cadastrada.';
          --Levantar Excecao
          RAISE vr_exc_erro;
        ELSE
          --Hora de inicio
          vr_hrinipag:= SubStr(vr_dstextab,6,6);
          --Hora Fim
          vr_hrfimpag:= SubStr(vr_dstextab,1,5);

          --Criar registro para tabela limite horarios
          vr_index_limite:= pr_tab_limite.Count+1;
          pr_tab_limite(vr_index_limite).hrinipag:= GENE0002.fn_converte_time_data(vr_hrinipag);
          pr_tab_limite(vr_index_limite).hrfimpag:= GENE0002.fn_converte_time_data(vr_hrfimpag);
          pr_tab_limite(vr_index_limite).nrhorini:= vr_hrinipag;
          pr_tab_limite(vr_index_limite).nrhorfim:= vr_hrfimpag;
          pr_tab_limite(vr_index_limite).iddiauti:= NULL;
          pr_tab_limite(vr_index_limite).flsgproc:= NULL;
          pr_tab_limite(vr_index_limite).qtmesagd:= NULL;
          pr_tab_limite(vr_index_limite).idtpdpag:= 3;

          --Se for feriado ou final semana
          IF Trunc(vr_datdodia) <> Trunc(SYSDATE) THEN
            --Fora do horario
            pr_tab_limite(vr_index_limite).idesthor:= 1;
          ELSE
            --Determinar a hora atual
            vr_hratual:= GENE0002.fn_busca_time;
            --Verificar se estourou o limite
            IF vr_hratual < vr_hrinipag OR vr_hratual > vr_hrfimpag THEN
              --Estourou limite
              vr_idesthor:= 1;
            ELSE
              --Dentro do Horario limite
              vr_idesthor:= 2;
            END IF;
            pr_tab_limite(vr_index_limite).idesthor:= vr_idesthor;
          END IF;
        END IF;
      END IF;

      --Se for para todos ou for ted
      IF pr_tpoperac IN (0,4)  THEN
        --Se a cooperativa nao existir
        OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
        FETCH cr_crapcop INTO rw_crapcop;
        --Se nao encontrou
        IF cr_crapcop%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_crapcop;
          vr_cdcritic:= 0;
          vr_dscritic:= 'Registro de cooperativa nao encontrado.';
          --Levantar Excecao
          RAISE vr_exc_erro;
        ELSE
          --Fechar Cursor
          CLOSE cr_crapcop;

          IF rw_crapcop.flgoppag = 0 AND rw_crapcop.flgopstr = 0 THEN -- FALSE
            
            vr_cdcritic:= 0;
            vr_dscritic:= 'Cooperativa nao esta operando no SPB.';
            --Levantar Excecao
            RAISE vr_exc_erro;
            
          ELSE
            --Determinar a hora atual
            vr_hratual:= GENE0002.fn_busca_time;          
            
            --Operando com mensagens STR
            IF rw_crapcop.flgopstr = 1 THEN -- TRUE
              IF rw_crapcop.iniopstr <= vr_hratual AND rw_crapcop.fimopstr >= vr_hratual THEN
                 vr_flgutstr := TRUE;
              END IF;
            END IF;          
            
            -- Operando com mensagens PAG  
            IF rw_crapcop.flgoppag = 1 THEN -- TRUE
              IF rw_crapcop.inioppag <= vr_hratual AND rw_crapcop.fimoppag >= vr_hratual THEN
                 vr_flgutpag := TRUE;  
              END IF;
            END IF;    
              
            --Se opera no sistema pagamento
            IF vr_flgutpag THEN -- TRUE
              vr_hrinipag := rw_crapcop.inioppag;
              vr_hrfimpag := rw_crapcop.fimoppag;
              
            ELSIF vr_flgutstr THEN -- TRUE
              vr_hrinipag := rw_crapcop.iniopstr;
              vr_hrfimpag := rw_crapcop.fimopstr;            
            END IF;            
              
          END IF;
          
          --Se for feriado ou final semana
          IF Trunc(vr_datdodia) <> Trunc(SYSDATE) THEN
            --Nao eh dia util
            vr_iddiauti:= 2;
          ELSE
            vr_iddiauti:= 1;
          END IF;

          --Determinar a hora atual
          vr_hratual:= GENE0002.fn_busca_time;
          --Verificar se estourou o limite
          IF vr_hratual < vr_hrinipag OR vr_hratual > vr_hrfimpag THEN
            --Estourou limite
            vr_idesthor:= 1;
          ELSE
            --Dentro do Horario limite
            vr_idesthor:= 2;
          END IF;

          --Criar registro para tabela limite horarios
          vr_index_limite:= pr_tab_limite.Count+1;
          pr_tab_limite(vr_index_limite).hrinipag:= GENE0002.fn_converte_time_data(vr_hrinipag);
          pr_tab_limite(vr_index_limite).hrfimpag:= GENE0002.fn_converte_time_data(vr_hrfimpag);
          pr_tab_limite(vr_index_limite).nrhorini:= vr_hrinipag;
          pr_tab_limite(vr_index_limite).nrhorfim:= vr_hrfimpag;
          pr_tab_limite(vr_index_limite).idesthor:= vr_idesthor;
          pr_tab_limite(vr_index_limite).iddiauti:= vr_iddiauti;
          pr_tab_limite(vr_index_limite).flsgproc:= NULL;
          pr_tab_limite(vr_index_limite).qtmesagd:= NULL;
          pr_tab_limite(vr_index_limite).idtpdpag:= 4;

        END IF;
      END IF;

      --Se for para todos ou for vr-boleto
      IF pr_tpoperac IN (0,6)  THEN
        /** Verifica horario inicial e final para geracao de boleto **/
        vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                ,pr_nmsistem => 'CRED'
                                                ,pr_tptabela => 'GENERI'
                                                ,pr_cdempres => 0
                                                ,pr_cdacesso => 'HRVRBOLETO'
                                                ,pr_tpregist => NULL);
        --Se nao encontrou
        IF vr_dstextab IS NULL THEN
          vr_cdcritic:= 0;
          vr_dscritic := 'Tabela (HRVRBOLETO) nao cadastrada.';
          --Levantar Excecao
          RAISE vr_exc_erro;
        ELSE
          --Hora de inicio
          vr_hrinipag:= to_number(gene0002.fn_busca_entrada(2,vr_dstextab,';'));
          --Hora Fim
          vr_hrfimpag:= to_number(gene0002.fn_busca_entrada(3,vr_dstextab,';'));

          --Criar registro para tabela limite horarios
          vr_index_limite:= pr_tab_limite.Count+1;
          pr_tab_limite(vr_index_limite).hrinipag:= GENE0002.fn_converte_time_data(vr_hrinipag);
          pr_tab_limite(vr_index_limite).hrfimpag:= GENE0002.fn_converte_time_data(vr_hrfimpag);
          pr_tab_limite(vr_index_limite).nrhorini:= vr_hrinipag;
          pr_tab_limite(vr_index_limite).nrhorfim:= vr_hrfimpag;
          pr_tab_limite(vr_index_limite).iddiauti:= NULL;
          pr_tab_limite(vr_index_limite).flsgproc:= NULL;
          pr_tab_limite(vr_index_limite).qtmesagd:= NULL;
          pr_tab_limite(vr_index_limite).idtpdpag:= 6;

          --Se for feriado ou final semana
          IF Trunc(vr_datdodia) <> Trunc(SYSDATE) THEN
            --Fora do horario
            pr_tab_limite(vr_index_limite).idesthor:= 1;
          ELSE
            --Determinar a hora atual
            vr_hratual:= GENE0002.fn_busca_time;
            --Verificar se estourou o limite
            IF vr_hratual < vr_hrinipag OR vr_hratual > vr_hrfimpag THEN
              --Estourou limite
              vr_idesthor:= 1;
            ELSE
              --Dentro do Horario limite
              vr_idesthor:= 2;
            END IF;
            pr_tab_limite(vr_index_limite).idesthor:= vr_idesthor;
          END IF;
        END IF;
      END IF;
      
      --Se for para todos ou horário limite para operacao de Credito Pre-aprovado
      IF pr_tpoperac IN (0,7)  THEN
        --Selecionar Horarios Limites Credito Pre-Aprovado
        vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                ,pr_nmsistem => 'CRED'
                                                ,pr_tptabela => 'GENERI'
                                                ,pr_cdempres => 0
                                                ,pr_cdacesso => 'HRCTRPREAPROV'
                                                ,pr_tpregist => pr_cdagenci);
        --Se nao encontrou
        IF vr_dstextab IS NULL THEN
          vr_cdcritic:= 0;
          vr_dscritic := 'Tabela (HRCTRPREAPROV) nao cadastrada.';
          --Levantar Excecao
          RAISE vr_exc_erro;
        ELSE
          --Atribuir horario limite
          vr_hrinipag:= gene0002.fn_busca_entrada(1,vr_dstextab,' ');
          vr_hrfimpag:= gene0002.fn_busca_entrada(2,vr_dstextab,' ');
        END IF;   
      
        --Se for feriado ou final semana
        IF Trunc(vr_datdodia) <> Trunc(SYSDATE) THEN
          --Nao eh dia util
          vr_iddiauti:= 2;
        ELSE
          vr_iddiauti:= 1;
        END IF;

        --Determinar a hora atual
        vr_hratual:= GENE0002.fn_busca_time;
        --Verificar se estourou o limite
        IF vr_hratual < vr_hrinipag OR vr_hratual > vr_hrfimpag THEN
          --Estourou limite
          vr_idesthor:= 1;
        ELSE
          --Dentro do Horario limite
          vr_idesthor:= 2;
        END IF;

        --Criar registro para tabela limite horarios
        vr_index_limite:= pr_tab_limite.Count+1;
        pr_tab_limite(vr_index_limite).hrinipag:= GENE0002.fn_converte_time_data(vr_hrinipag);
        pr_tab_limite(vr_index_limite).hrfimpag:= GENE0002.fn_converte_time_data(vr_hrfimpag);
        pr_tab_limite(vr_index_limite).nrhorini:= vr_hrinipag;
        pr_tab_limite(vr_index_limite).nrhorfim:= vr_hrfimpag;
        pr_tab_limite(vr_index_limite).idesthor:= vr_idesthor;
        pr_tab_limite(vr_index_limite).iddiauti:= vr_iddiauti;
        pr_tab_limite(vr_index_limite).flsgproc:= NULL;
        pr_tab_limite(vr_index_limite).qtmesagd:= NULL;
        pr_tab_limite(vr_index_limite).idtpdpag:= 7;

      END IF;
      
      --Se for para todos ou for Debito Automatico Facil
      IF pr_tpoperac IN (0,11)  THEN
        --Se a cooperativa nao existir
        OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
        FETCH cr_crapcop INTO rw_crapcop;
        --Se nao encontrou
        IF cr_crapcop%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_crapcop;
          vr_cdcritic:= 0;
          vr_dscritic:= 'Registro de cooperativa nao encontrado.';
          --Levantar Excecao
          RAISE vr_exc_erro;
        ELSE
          --Fechar Cursor
          CLOSE cr_crapcop;
          vr_hrinipag := rw_crapcop.hriniatr;
          vr_hrfimpag := rw_crapcop.hrfimatr;
          
          --Se for feriado ou final semana
          IF Trunc(vr_datdodia) <> Trunc(SYSDATE) THEN
            --Nao eh dia util
            vr_iddiauti:= 2;
          ELSE
            vr_iddiauti:= 1;
          END IF;

          --Determinar a hora atual
          vr_hratual:= GENE0002.fn_busca_time;
          --Verificar se estourou o limite
          IF vr_hratual < vr_hrinipag OR vr_hratual > vr_hrfimpag THEN
            --Estourou limite
            vr_idesthor:= 1;
          ELSE
            --Dentro do Horario limite
            vr_idesthor:= 2;
          END IF;

          --Criar registro para tabela limite horarios
          vr_index_limite:= pr_tab_limite.Count+1;
          pr_tab_limite(vr_index_limite).hrinipag:= GENE0002.fn_converte_time_data(vr_hrinipag);
          pr_tab_limite(vr_index_limite).hrfimpag:= GENE0002.fn_converte_time_data(vr_hrfimpag);
          pr_tab_limite(vr_index_limite).nrhorini:= vr_hrinipag;
          pr_tab_limite(vr_index_limite).nrhorfim:= vr_hrfimpag;
          pr_tab_limite(vr_index_limite).idesthor:= vr_idesthor;
          pr_tab_limite(vr_index_limite).iddiauti:= vr_iddiauti;
          pr_tab_limite(vr_index_limite).flsgproc:= NULL;
          pr_tab_limite(vr_index_limite).qtmesagd:= NULL;
          pr_tab_limite(vr_index_limite).idtpdpag:= 11;

        END IF;
      END IF;
      
    EXCEPTION
       WHEN vr_exc_erro THEN
         pr_cdcritic:= vr_cdcritic;
         pr_dscritic:= vr_dscritic;
       WHEN OTHERS THEN
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro na rotina INET0001.pc_horario_operacao. '||SQLERRM;
    END;
  END pc_horario_operacao;

  /* Procedure para buscar os limites para internet */
  PROCEDURE pc_busca_limites (pr_cdcooper     IN crapcop.cdcooper%type        --C¿digo Cooperativa
                             ,pr_nrdconta     IN crapass.nrdconta%TYPE        --Numero da conta
                             ,pr_idseqttl     IN crapttl.idseqttl%TYPE        --Identificador Sequencial titulo
                             ,pr_flglimdp     IN BOOLEAN                      --Indicador limite deposito
                             ,pr_dtmvtopg     IN crapdat.dtmvtolt%TYPE        --Data do proximo pagamento
                             ,pr_flgctrag     IN BOOLEAN                      --Indicador validacoes
                             ,pr_dsorigem     IN craplau.dsorigem%TYPE        --Descricao Origem
                             ,pr_tab_internet OUT INET0001.typ_tab_internet   --Tabelas de retorno de horarios limite
                             ,pr_cdcritic     OUT INTEGER        --Codigo do erro
                             ,pr_dscritic     OUT VARCHAR2) IS   --Descricao do erro
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_busca_limites           Antigo: b1wgen0015.p/busca_limites
  --  Sistema  : Procedure para buscar os limites para internet
  --  Sigla    : CRED
  --  Autor    : Alisson C. Berrido - Amcom
  --  Data     : Junho/2013.                   Ultima atualizacao: 09/12/2014
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para buscar os limites da internet
  
  -- Atualizacao: 09/12/2014 - Ajustado IF do LOOP leitura cr_craplau (Daniel)             

  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      /* Cursores Locais */

      --selecionar movimentacoes internet
      CURSOR cr_crapmvi (pr_cdcooper IN crapmvi.cdcooper%type
                        ,pr_nrdconta IN crapmvi.nrdconta%type
                        ,pr_idseqttl IN crapmvi.idseqttl%type
                        ,pr_dtmvtolt IN crapmvi.dtmvtolt%type) IS
        SELECT crapmvi.vlmovweb
              ,crapmvi.vlmovtrf
              ,crapmvi.vlmovpgo
              ,crapmvi.vlmovted
        FROM crapmvi
        WHERE crapmvi.cdcooper = pr_cdcooper
        AND   crapmvi.nrdconta = pr_nrdconta
        AND   (pr_idseqttl = -1 OR (pr_idseqttl <> -1 AND crapmvi.idseqttl = pr_idseqttl))
        AND   crapmvi.dtmvtolt = pr_dtmvtopg;
      rw_crapmvi cr_crapmvi%ROWTYPE;
      --Selecionar informacoes dos lancamentos automaticos
      CURSOR cr_craplau (pr_cdcooper IN craplau.cdcooper%type
                        ,pr_nrdconta IN craplau.nrdconta%type
                        ,pr_idseqttl IN craplau.idseqttl%type
                        ,pr_dtmvtopg IN craplau.dtmvtopg%type
                        ,pr_insitlau IN craplau.insitlau%type
                        ,pr_dsorigem IN craplau.dsorigem%type) IS
        SELECT craplau.cdcooper
              ,craplau.dtmvtopg
              ,craplau.nrdconta
              ,craplau.cdtiptra
              ,craplau.vllanaut
        FROM craplau craplau
        WHERE craplau.cdcooper = pr_cdcooper
        AND   craplau.nrdconta = pr_nrdconta
        AND   (pr_idseqttl = -1 OR (pr_idseqttl <> -1 AND craplau.idseqttl = pr_idseqttl))
        AND   craplau.dtmvtopg = pr_dtmvtopg
        AND   craplau.insitlau = pr_insitlau
        AND   craplau.dsorigem = pr_dsorigem;

      --Variaveis Locais
      vr_index        INTEGER;
      vr_inpessoa     INTEGER;
      vr_vlutlweb     crapsnh.vllimweb%TYPE;
      vr_vlutltrf     crapsnh.vllimtrf%TYPE;
      vr_vlutlpgo     crapsnh.vllimpgo%TYPE;
      vr_vlutlted     crapsnh.vllimted%TYPE;
      vr_vllimweb     crapsnh.vllimweb%TYPE;
      vr_vllimpgo     crapsnh.vllimpgo%TYPE;
      vr_vllimtrf     crapsnh.vllimtrf%TYPE;
      vr_vllimted     crapsnh.vllimted%TYPE;
      vr_tab_vllimweb crapsnh.vllimweb%TYPE;
      vr_tab_vllimtrf crapsnh.vllimtrf%TYPE;
      vr_tab_vllimpgo crapsnh.vllimpgo%TYPE;
      vr_tab_vllimted crapsnh.vllimted%TYPE;
      vr_tab_vllimvrb crapsnh.vllimted%TYPE;
      vr_dstextab     craptab.dstextab%TYPE;
      --Variaveis de Erro
      vr_cdcritic     crapcri.cdcritic%TYPE;
      vr_dscritic     VARCHAR2(4000);
      --Variaveis Excecao
      vr_exc_erro EXCEPTION;
    BEGIN
      --Inicializar variaveis retorno
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;
      --Inicializar tabela retorno
      pr_tab_internet.DELETE;

      --Verificar se o associado existe
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      -- Se n¿o encontrar
      IF cr_crapass%NOTFOUND THEN
        -- Fechar o cursor pois haver¿ raise
        CLOSE cr_crapass;
        -- Montar mensagem de critica
        vr_cdcritic:= 0;
        vr_dscritic:= 'Associado nao cadastrado.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      ELSE
        --Determinar tipo pessoa para busca limite
        IF rw_crapass.inpessoa > 1 THEN
          vr_inpessoa:= 2;
        ELSE
          vr_inpessoa:= rw_crapass.inpessoa;
        END IF;

      END IF;
      -- Fechar o cursor pois haver¿ raise
      CLOSE cr_crapass;
      /** Obtem limites da cooperativa **/
      vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                              ,pr_nmsistem => 'CRED'
                                              ,pr_tptabela => 'GENERI'
                                              ,pr_cdempres => 0
                                              ,pr_cdacesso => 'LIMINTERNT'
                                              ,pr_tpregist => vr_inpessoa);

      --Se nao encontrou
      IF vr_dstextab IS NULL THEN
        pr_cdcritic:= 0;
        pr_dscritic := 'Tabela (LIMINTERNT) nao cadastrada.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Zerar Variaveis
      vr_tab_vllimweb:= 0;
      vr_tab_vllimtrf:= 0;
      vr_tab_vllimpgo:= 0;
      vr_tab_vllimted:= 0;
      vr_tab_vllimvrb:= 0;
      /** Pessoa fisica **/
      IF vr_inpessoa = 1 THEN
        --Limite web
        vr_tab_vllimweb:= GENE0002.fn_char_para_number(
                            GENE0002.fn_busca_entrada(01,vr_dstextab,';'));
        --Limite TED
        vr_tab_vllimted:= GENE0002.fn_char_para_number(
                            GENE0002.fn_busca_entrada(13,vr_dstextab,';'));
        --Limite Diario
        vr_tab_vllimvrb:= GENE0002.fn_char_para_number(
                            GENE0002.fn_busca_entrada(15,vr_dstextab,';'));
      ELSE
        --Limite transferencia
        vr_tab_vllimtrf:= GENE0002.fn_char_para_number(
                            GENE0002.fn_busca_entrada(01,vr_dstextab,';'));
        --Limite Pagamento
        vr_tab_vllimpgo:= GENE0002.fn_char_para_number(
                            GENE0002.fn_busca_entrada(06,vr_dstextab,';'));
        --Limite TED
        vr_tab_vllimted:= GENE0002.fn_char_para_number(
                            GENE0002.fn_busca_entrada(13,vr_dstextab,';'));
        --Limite Diario
        vr_tab_vllimvrb:= GENE0002.fn_char_para_number(
                            GENE0002.fn_busca_entrada(16,vr_dstextab,';'));
      END IF;
      /** Valor limite para operacoes do titular **/
      OPEN cr_crapsnh (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_idseqttl => pr_idseqttl
                      ,pr_tpdsenha => 1);
      --Posicionar no proximo registro
      FETCH cr_crapsnh INTO rw_crapsnh;
      --Se nao encontrar
      IF cr_crapsnh%NOTFOUND THEN
        pr_cdcritic:= 0;
        pr_dscritic:= 'Senha para conta on-line nao cadastrada.';
        --Fechar Cursor
        CLOSE cr_crapsnh;
        --Limite Web
        vr_vllimweb:= 0;
        --Limite Pagamento
        vr_vllimpgo:= 0;
        --Limite Transferencia
        vr_vllimtrf:= 0;
        --Limite TED
        vr_vllimted:= 0;
      ELSE
        --Limite Web
        vr_vllimweb:= rw_crapsnh.vllimweb;
        --Limite Pagamento
        vr_vllimpgo:= rw_crapsnh.vllimpgo;
        --Limite Transferencia
        vr_vllimtrf:= rw_crapsnh.vllimtrf;
        --Limite TED
        vr_vllimted:= rw_crapsnh.vllimted;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapsnh;

      --Criar registro limite internet
      vr_index:= rw_crapsnh.idseqttl;
      pr_tab_internet(vr_index).idseqttl:= rw_crapsnh.idseqttl;
      pr_tab_internet(vr_index).vlwebcop:= vr_tab_vllimweb;
      pr_tab_internet(vr_index).vlpgocop:= vr_tab_vllimpgo;
      pr_tab_internet(vr_index).vltrfcop:= vr_tab_vllimtrf;
      pr_tab_internet(vr_index).vltedcop:= vr_tab_vllimted;
      pr_tab_internet(vr_index).vllimweb:= vr_vllimweb;
      pr_tab_internet(vr_index).vllimpgo:= vr_vllimpgo;
      pr_tab_internet(vr_index).vllimtrf:= vr_vllimtrf;
      pr_tab_internet(vr_index).vllimted:= vr_vllimted;
      pr_tab_internet(vr_index).vlvrbcop:= vr_tab_vllimvrb;
		  pr_tab_internet(vr_index).vllimvrb:= rw_crapsnh.vllimvrb;

      --Se for pessoa fisica e o sequencial titular > 1
      IF  rw_crapass.inpessoa = 1 AND pr_idseqttl > 1  THEN
        /** Valor limite para operacoes de todos titulares **/
        OPEN cr_crapsnh (pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_idseqttl => 1
                        ,pr_tpdsenha => 1);
        --Posicionar no proximo registro
        FETCH cr_crapsnh INTO rw_crapsnh;
        --Se nao encontrar
        IF cr_crapsnh%NOTFOUND THEN
          pr_cdcritic:= 0;
          pr_dscritic:= 'Senha para conta on-line nao cadastrada.';
          --Fechar Cursor
          CLOSE cr_crapsnh;
          --Limite Web
          vr_vllimweb:= 0;
          --Limite Pagamento
          vr_vllimpgo:= 0;
          --Limite Transferencia
          vr_vllimtrf:= 0;
          --Limite TED
          vr_vllimted:= 0;
        ELSE
          --Limite Web
          vr_vllimweb:= rw_crapsnh.vllimweb;
          --Limite Pagamento
          vr_vllimpgo:= rw_crapsnh.vllimpgo;
          --Limite Transferencia
          vr_vllimtrf:= rw_crapsnh.vllimtrf;
          --Limite TED
          vr_vllimted:= rw_crapsnh.vllimted;
        END IF;
        --Fechar Cursor
        CLOSE cr_crapsnh;
        --Criar registro limite internet
        vr_index:= rw_crapsnh.idseqttl;
        pr_tab_internet(vr_index).idseqttl:= vr_index;
        pr_tab_internet(vr_index).vlwebcop:= vr_tab_vllimweb;
        pr_tab_internet(vr_index).vlpgocop:= vr_tab_vllimpgo;
        pr_tab_internet(vr_index).vltrfcop:= vr_tab_vllimtrf;
        pr_tab_internet(vr_index).vltedcop:= vr_tab_vllimted;
        pr_tab_internet(vr_index).vllimweb:= vr_vllimweb;
        pr_tab_internet(vr_index).vllimpgo:= vr_vllimpgo;
        pr_tab_internet(vr_index).vllimtrf:= vr_vllimtrf;
        pr_tab_internet(vr_index).vllimted:= vr_vllimted;
        pr_tab_internet(vr_index).vlvrbcop:= vr_tab_vllimvrb;
  		  pr_tab_internet(vr_index).vllimvrb:= rw_crapsnh.vllimvrb;
      END IF;
      /** Limite Disponivel (Total - Utilizado) **/
      IF pr_flglimdp THEN
        --Zerar variaveis
        vr_vlutlweb:= 0;
        vr_vlutltrf:= 0;
        vr_vlutlpgo:= 0;
        vr_vlutlted:= 0;

        /** Acumula valores movimentados pelo titular **/
        OPEN cr_crapmvi (pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_idseqttl => pr_idseqttl
                        ,pr_dtmvtolt => pr_dtmvtopg);
        --Posicionar no primeiro registro
        FETCH cr_crapmvi INTO rw_crapmvi;
        --Se encontrou
        IF cr_crapmvi%FOUND THEN
          --Valor Utilizado web
          vr_vlutlweb:= rw_crapmvi.vlmovweb;
          --Valor Utilizado Transferencia
          vr_vlutltrf:= rw_crapmvi.vlmovtrf;
          --Valor Utilizado Pagamento
          vr_vlutlpgo:= rw_crapmvi.vlmovpgo;
          --Valor Utilizado TED
          vr_vlutlted:= rw_crapmvi.vlmovted;
        END IF;
        --Fechar Cursor
        CLOSE cr_crapmvi;

        /** Acumular valor de agendamentos do titular **/
        IF  pr_flgctrag  THEN
          --Percorrer todos os lancamentos
          FOR rw_craplau IN cr_craplau (pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_idseqttl => pr_idseqttl
                                       ,pr_dtmvtopg => pr_dtmvtopg
                                       ,pr_insitlau => 1
                                       ,pr_dsorigem => pr_dsorigem) LOOP
            --Se for pessoa fisica
            IF rw_crapass.inpessoa = 1  THEN
              --Acumular valor utilizado web
              vr_vlutlweb:= vr_vlutlweb + Nvl(rw_craplau.vllanaut,0);
            ELSIF rw_craplau.cdtiptra IN (1,3,5)  THEN
              --Acumular valor utilizado transferencia
              vr_vlutltrf:= vr_vlutltrf + Nvl(rw_craplau.vllanaut,0);
            ELSIF rw_craplau.cdtiptra = 2  THEN
              --Acumular valor utilizado pagamentos
              vr_vlutlpgo:= vr_vlutlpgo + Nvl(rw_craplau.vllanaut,0);
            END IF;
          END LOOP;
          
        END IF;  
          vr_index:= pr_idseqttl;
          --Se existir valor limite web
          IF  pr_tab_internet.EXISTS(vr_index) AND pr_tab_internet(vr_index).vllimweb > 0  THEN
            --Valor utilizado WEB
            pr_tab_internet(vr_index).vlutlweb:= vr_vlutlweb;
            --Valor disponivel WEB recebe limite menos utilizado web
            pr_tab_internet(vr_index).vldspweb:= pr_tab_internet(vr_index).vllimweb - vr_vlutlweb;
          END IF;
          --Se existir valor limite transferencia
          IF  pr_tab_internet.EXISTS(vr_index) AND pr_tab_internet(vr_index).vllimtrf > 0  THEN
            --Valor utilizado transferencia
            pr_tab_internet(vr_index).vlutltrf:= vr_vlutltrf;
            --Valor disponivel transf. recebe limite menos utilizado transf
            pr_tab_internet(vr_index).vldsptrf:= pr_tab_internet(vr_index).vllimtrf - vr_vlutltrf;
          END IF;
          --Se existir valor limite pagto
          IF  pr_tab_internet.EXISTS(vr_index) AND pr_tab_internet(vr_index).vllimpgo > 0  THEN
            --Valor utilizado pagto
            pr_tab_internet(vr_index).vlutlpgo:= vr_vlutlpgo;
            --Valor disponivel pagto. recebe limite menos utilizado pagto
            pr_tab_internet(vr_index).vldsppgo:= pr_tab_internet(vr_index).vllimpgo - vr_vlutlpgo;
          END IF;
          --Se existir valor limite ted
          IF  pr_tab_internet.EXISTS(vr_index) AND pr_tab_internet(vr_index).vllimted > 0  THEN
            --Valor utilizado ted
            pr_tab_internet(vr_index).vlutlted:= vr_vlutlted;
            --Valor disponivel ted. recebe limite menos utilizado ted
            pr_tab_internet(vr_index).vldspted:= pr_tab_internet(vr_index).vllimted - vr_vlutlted;
          END IF;
          --Se for pessoa fisica e sequencial titular > 1
          IF rw_crapass.inpessoa = 1 AND pr_idseqttl > 1 THEN
            --Zerar variaveis valor utilizado
            vr_vlutlweb:= 0;
            vr_vlutltrf:= 0;
            vr_vlutlpgo:= 0;
            vr_vlutlted:= 0;
            /** Acumula valores movimentados por todos os titulares **/
            FOR rw_crapmvi IN cr_crapmvi (pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_idseqttl => -1
                                         ,pr_dtmvtolt => pr_dtmvtopg) LOOP
              --Acumular valor utilizado web
              vr_vlutlweb:= vr_vlutlweb + Nvl(rw_crapmvi.vlmovweb,0);
              --Acumular valor utilizado transferencia
              vr_vlutltrf:= vr_vlutltrf + Nvl(rw_crapmvi.vlmovtrf,0);
              --Acumular valor utilizado pagamentos
              vr_vlutlpgo:= vr_vlutlpgo + Nvl(rw_crapmvi.vlmovpgo,0);
              --Acumular valor utilizado ted
              vr_vlutlted:= vr_vlutlted + Nvl(rw_crapmvi.vlmovted,0);
            END LOOP;
            /** Acumular valor de agendamentos para todos os titulares **/
            IF pr_flgctrag THEN
              --Percorrer todos os lancamentos
              FOR rw_craplau IN cr_craplau (pr_cdcooper => pr_cdcooper
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_idseqttl => -1
                                           ,pr_dtmvtopg => pr_dtmvtopg
                                           ,pr_insitlau => 1
                                           ,pr_dsorigem => pr_dsorigem) LOOP
                --Se for pessoa fisica
                IF rw_crapass.inpessoa = 1  THEN
                  --Acumular valor utilizado web
                  vr_vlutlweb:= vr_vlutlweb + Nvl(rw_craplau.vllanaut,0);
                ELSIF rw_craplau.cdtiptra IN (1,3,5)  THEN
                  --Acumular valor utilizado transferencia
                  vr_vlutltrf:= vr_vlutltrf + Nvl(rw_craplau.vllanaut,0);
                ELSIF rw_craplau.cdtiptra = 2  THEN
                  --Acumular valor utilizado pagamentos
                  vr_vlutlpgo:= vr_vlutlpgo + Nvl(rw_craplau.vllanaut,0);
                END IF;
              END LOOP;

              vr_index:= 1;
              --Se existir valor limite web
              IF  pr_tab_internet.EXISTS(vr_index) AND pr_tab_internet(vr_index).vllimweb > 0  THEN
                --Valor utilizado WEB
                pr_tab_internet(vr_index).vlutlweb:= vr_vlutlweb;
                --Valor disponivel WEB recebe limite menos utilizado web
                pr_tab_internet(vr_index).vldspweb:= pr_tab_internet(vr_index).vllimweb - vr_vlutlweb;
              END IF;
              --Se existir valor limite transferencia
              IF  pr_tab_internet.EXISTS(vr_index) AND pr_tab_internet(vr_index).vllimtrf > 0  THEN
                --Valor utilizado transferencia
                pr_tab_internet(vr_index).vlutltrf:= vr_vlutltrf;
                --Valor disponivel transf. recebe limite menos utilizado transf
                pr_tab_internet(vr_index).vldsptrf:= pr_tab_internet(vr_index).vllimtrf - vr_vlutltrf;
              END IF;
              --Se existir valor limite pagto
              IF  pr_tab_internet.EXISTS(vr_index) AND pr_tab_internet(vr_index).vllimpgo > 0  THEN
                --Valor utilizado pagto
                pr_tab_internet(vr_index).vlutlpgo:= vr_vlutlpgo;
                --Valor disponivel pagto. recebe limite menos utilizado pagto
                pr_tab_internet(vr_index).vldsppgo:= pr_tab_internet(vr_index).vllimpgo - vr_vlutlpgo;
              END IF;
              --Se existir valor limite ted
              IF  pr_tab_internet.EXISTS(vr_index) AND pr_tab_internet(vr_index).vllimted > 0  THEN
                --Valor utilizado ted
                pr_tab_internet(vr_index).vlutlted:= vr_vlutlted;
                --Valor disponivel ted. recebe limite menos utilizado ted
                pr_tab_internet(vr_index).vldspted:= pr_tab_internet(vr_index).vllimted - vr_vlutlted;
              END IF;
              --Verificar os limites disponiveis web
              IF pr_tab_internet(pr_idseqttl).vldspweb > pr_tab_internet(1).vldspweb THEN
                 --Atualizar valor disponivel web
                 pr_tab_internet(pr_idseqttl).vldspweb:= pr_tab_internet(1).vldspweb;
              END IF;
              --Verificar os limites disponiveis transferencia
              IF pr_tab_internet(pr_idseqttl).vldsptrf > pr_tab_internet(1).vldsptrf THEN
                 --Atualizar valor disponivel transferencia
                 pr_tab_internet(pr_idseqttl).vldsptrf:= pr_tab_internet(1).vldsptrf;
              END IF;
              --Verificar os limites disponiveis pagamento
              IF pr_tab_internet(pr_idseqttl).vldsppgo > pr_tab_internet(1).vldsppgo THEN
                 --Atualizar valor disponivel pagamento
                 pr_tab_internet(pr_idseqttl).vldsppgo:= pr_tab_internet(1).vldsppgo;
              END IF;
              --Verificar os limites disponiveis ted
              IF pr_tab_internet(pr_idseqttl).vldspted > pr_tab_internet(1).vldspted THEN
                 --Atualizar valor disponivel ted
                 pr_tab_internet(pr_idseqttl).vldspted:= pr_tab_internet(1).vldspted;
              END IF;

            END IF;
          END IF;
       -- END IF;
      END IF;
    EXCEPTION
       WHEN vr_exc_erro THEN
         pr_cdcritic:= vr_cdcritic;
         pr_dscritic:= vr_dscritic;
       WHEN OTHERS THEN
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro na rotina INET0001.pc_busca_limite. '||SQLERRM;
    END;
  END pc_busca_limites;

  /* Validar a conta de destino da transferencia */
  PROCEDURE pc_valida_conta_destino (pr_cdcooper IN crapcop.cdcooper%type  --C¿digo Cooperativa
                                    ,pr_cdagenci IN crapage.cdagenci%type  --Agencia do Associado
                                    ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE  --Numero caixa
                                    ,pr_cdoperad IN crapope.cdoperad%TYPE  --Codigo Operador
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE  --Numero da conta
                                    ,pr_idseqttl IN crapttl.idseqttl%TYPE  --Identificador Sequencial titulo
                                    ,pr_cdagectl IN crapcti.cdageban%TYPE  --Codigo Agencia
                                    ,pr_nrctatrf IN crapcti.nrctatrf%TYPE  --Numero Conta Transferencia
                                    ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --Data Movimento
                                    ,pr_cdtiptra IN INTEGER                --Tipo de Transferencia
                                    ,pr_flgctafa OUT BOOLEAN               --Indicador conta cadastrada
                                    ,pr_nmtitula OUT VARCHAR2              --Nome titular
                                    ,pr_nmtitul2 OUT VARCHAR2              --Nome segundo titular
                                    ,pr_cddbanco OUT INTEGER               --Codigo banco
                                    ,pr_dscritic OUT VARCHAR2              --Retorno OK/NOK
                                    ,pr_tab_erro OUT GENE0001.typ_tab_erro) IS --Tabela de retorno de erro
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_valida_conta_destino           Antigo: b1wgen0015.p/valida-conta-destino
  --  Sistema  : Procedimentos para validar conta de destino da transferencia
  --  Sigla    : CRED
  --  Autor    : Alisson C. Berrido - Amcom
  --  Data     : Junho/2013.                   Ultima atualizacao: 28/07/2015
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos para validar conta de destino da transferencia
  --
  -- Alterações: 28/07/2015 - Ajustar o tratamento de erros para quando executar o raise o erro seja
  --                          carregado na tabela de erros e devolvida a rotina que chamou.
  --                          (Douglas - Chamado 312756)
  ---------------------------------------------------------------------------------------------------------------

  BEGIN
    DECLARE
      --Selecionar informacoes cooperativa

      /* Busca dos dados da cooperativa */
      CURSOR cr_crapcop2(pr_cdagectl IN crapcop.cdagectl%TYPE) IS
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
        FROM crapcop
        WHERE crapcop.cdagectl = pr_cdagectl;

      --Variaveis de Erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Tipo de registro de cooperativa
      rw_crabcop cr_crapcop2%ROWTYPE;
      --Tipo de registro de associado
      rw_crabass cr_crapass%ROWTYPE;
      --Variaveis de Excecao
      vr_exc_saida EXCEPTION;
      vr_exc_erro  EXCEPTION;
    BEGIN
      --Inicializar varaivel retorno erro
      pr_tab_erro.DELETE;

      /* Cooperativa do assoc. logado */
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      -- Se n¿o encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haver¿ raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic:= 651;
        vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;
      /* Conta do cooperado logado */
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      -- Se n¿o encontrar
      IF cr_crapass%NOTFOUND THEN
        -- Fechar o cursor pois haver¿ raise
        CLOSE cr_crapass;
        -- Montar mensagem de critica
        vr_cdcritic:= 9;
        vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapass;
      END IF;
      /* Cooperativa de destino */
      OPEN cr_crapcop2(pr_cdagectl => pr_cdagectl);
      FETCH cr_crapcop2 INTO rw_crabcop;
      -- Se n¿o encontrar
      IF cr_crapcop2%NOTFOUND THEN
        -- Fechar o cursor pois haver¿ raise
        CLOSE cr_crapcop2;
        -- Montar mensagem de critica
        vr_cdcritic:= 0;
        vr_dscritic:= 'Cooperativa selecionada nao existe no sistema.';
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop2;
      END IF;
      /* Conta destino */
      OPEN cr_crapass(pr_cdcooper => rw_crabcop.cdcooper
                     ,pr_nrdconta => pr_nrctatrf);
      FETCH cr_crapass INTO rw_crabass;
      -- Se n¿o encontrar
      IF cr_crapass%NOTFOUND THEN
        -- Fechar o cursor pois haver¿ raise
        CLOSE cr_crapass;
        -- Montar mensagem de critica
        vr_cdcritic:= 0;
        vr_dscritic:= 'Conta destino nao possui cadastro na cooperativa.';
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapass;
      END IF;
      /* Se mesma coop. e conta */
      IF  rw_crapass.cdcooper = rw_crabass.cdcooper   AND
          rw_crapass.nrdconta = rw_crabass.nrdconta   THEN
        vr_cdcritic:= 0;
        vr_dscritic:= 'Nao e possivel transferir para sua conta.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --verificar se a conta est¿ encerrada
      IF rw_crabass.dtdemiss IS NOT NULL THEN
        vr_cdcritic:= 0;
        vr_dscritic:= 'Conta destino encerrada. Nao sera possivel efetuar a transferencia.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      IF pr_cdtiptra = 3  THEN /* Credito Salario */
        IF  rw_crapcop.cdagectl <> rw_crabcop.cdagectl  THEN
          vr_cdcritic:= 0;
          vr_dscritic:= 'Credito de Salario deve ser efetuado em contas de sua cooperativa.';
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        --Se conta destino nao for de pessoa fisica
        IF rw_crabass.inpessoa <> 1 THEN
          vr_cdcritic:= 0;
          vr_dscritic:= 'Credito de Salario deve ser efetuado para pessoa fisica.';
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
      END IF;
      --Selecionar Cadastro transferencias pela internet
      OPEN cr_crapcti (pr_cdcooper => pr_cdcooper
                      ,pr_cddbanco => rw_crapcop.cdbcoctl
                      ,pr_cdageban => rw_crapcop.cdagectl
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_nrctatrf => pr_nrctatrf);
      --Posicionar no primeiro registro
      FETCH cr_crapcti INTO rw_crapcti;
      --Se nao encontrou ou a conta naoesta ativa
      pr_flgctafa:= cr_crapcti%FOUND;
      --Fechar Cursor
      CLOSE cr_crapcti;
      --Nome do titular
      pr_nmtitula:= rw_crabass.nmprimtl;
      --Nome do segundo titular
      pr_nmtitul2:= rw_crabass.nmsegntl;
      --Codigo do Banco
      pr_cddbanco:= rw_crabcop.cdbcoctl;
      --Retornar OK
      pr_dscritic:= 'OK';
    EXCEPTION
       WHEN vr_exc_erro THEN
         pr_tab_erro(1).cdcritic:= vr_cdcritic;
         pr_tab_erro(1).dscritic:= vr_dscritic;
         pr_dscritic:= 'NOK';
       WHEN OTHERS THEN
         pr_tab_erro(1).cdcritic:= 0;
         pr_tab_erro(1).dscritic:= 'Erro na rotina INET0001.pc_valida_conta_destino. '||SQLERRM;
         pr_dscritic:= 'NOK';
    END;
  END pc_valida_conta_destino;

  /** Procedure para validar limites para transacoes (Transf./Pag./Cob.) **/
  PROCEDURE pc_verifica_operacao (pr_cdcooper IN crapcop.cdcooper%type  --C¿digo Cooperativa
                                 ,pr_cdagenci IN crapage.cdagenci%type  --Agencia do Associado
                                 ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE  --Numero caixa
                                 ,pr_nrdconta IN crapass.nrdconta%TYPE  --Numero da conta
                                 ,pr_idseqttl IN crapttl.idseqttl%TYPE  --Identificador Sequencial titulo
                                 ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --Data Movimento
                                 ,pr_idagenda IN INTEGER                --Indicador agenda
                                 ,pr_dtmvtopg IN craplau.dtmvtopg%TYPE  --Data Pagamento
                                 ,pr_vllanmto IN OUT craplcm.vllanmto%TYPE  --Valor Lancamento
                                 ,pr_cddbanco IN crapcti.cddbanco%TYPE  --Codigo banco
                                 ,pr_cdageban IN crapcti.cdageban%TYPE  --Codigo Agencia
                                 ,pr_nrctatrf IN crapcti.nrctatrf%TYPE  --Numero Conta Transferencia
                                 ,pr_cdtiptra IN INTEGER  /* 1 - Transferencia / 2 - Pagamento / 3 - Credito Salario / 4 - TED */
                                 ,pr_cdoperad IN crapope.cdoperad%TYPE  --Codigo Operador
                                 ,pr_tpoperac IN INTEGER  /* 1 - Transferencia intracooperativa / 2 - Pagamento / 3 - Cobranca /  */     /* 4 - TED / 5 - Transferencia intercooperativa */
                                 ,pr_flgvalid IN BOOLEAN                --Indicador validacoes
                                 ,pr_dsorigem IN craplau.dsorigem%TYPE  --Descricao Origem
                                 ,pr_nrcpfope IN crapopi.nrcpfope%TYPE  --CPF operador
                                 ,pr_flgctrag IN BOOLEAN /* controla validacoes na efetivacao de agendamentos */
                                 ,pr_nmdatela IN VARCHAR2
                                 ,pr_dstransa   OUT VARCHAR2               --Descricao da transacao
                                 ,pr_tab_limite OUT INET0001.typ_tab_limite --Tabelas de retorno de horarios limite
                                 ,pr_tab_internet OUT INET0001.typ_tab_internet --Tabelas de retorno de horarios limite
                                 ,pr_cdcritic   OUT INTEGER     --C¿digo do erro
                                 ,pr_dscritic   OUT VARCHAR2) IS   --Descricao do erro
  /*---------------------------------------------------------------------------------------------------------------
    Programa : pc_verifica_operacao           Antigo: b1wgen0015.p/verifica_operacao
   Sistema  : Procedimentos para o debito de agendamentos feitos na Internet
   Sigla    : CRED
   Autor    : Alisson C. Berrido - Amcom
   Data     : Junho/2013.                   Ultima atualizacao: 17/02/2016
  
  Dados referentes ao programa:
  
  Frequencia: -----
  Objetivo  : Procedure para validar limites para transacoes (Transf./Pag./Cob.)
  
  Alteracoes: 20/02/2014 - Adicionado verificacap de cooperativa atraves da conta destino.
                           (Jorge/Adriano) SD - Emergencial
  
              03/09/2014 - Adicionado verificacao de cooperativa atraves de coop anterior.
                           (Jean Michel)
  
              06/11/2014 - (Chamado 161844) Retirar critica para agendamento de dia 
                            nao util, tratamento agora sera feito na BO16
                           (Tiago Castro - RKAM).
  
              16/09/2015 - Melhoria performace, inclusao do parametro de tipo de busca na chamada do procedimento
                           EXTR0001.pc_obtem_saldo_dia, para utilizar a dtmvtoan como base na busca(Odirlei-AMcom)
  
              24/09/2015 - Realizado ajustes para que seja possível informar a rotina pc_obtem_saldo_dia 
                           se a consulta será por uma conta especifica ou não, de acordo com o programa
                           que chamou a rotina pc_verifica_operacao (Adriano - SD 328034).
                           
              12/11/2015 - Utilizar variável vr_dscritic quando crítica for descritiva (David).
              
              03/12/2015 - Ajuste na chamada da pc_obtem_saldo_dia para melhoria de performace 
                           SD358495 (Odirlei-AMcom)
  
              08/12/2015 - Adicionado validacao de conta PJ quanto a exigencia de assinatura multipla.
						               (Jorge/David) - Proj. 131 Assinatura Multipla PJ 
                          
              23/12/2015 - Adicionado condicao Agendamento Recorrente.
                           Renato Darosci - Supero - chamado 348637 
                     
              28/01/2016 - Ajustes para permitir TED no ultimo dia do ano (Tiago/Elton)

			  17/02/2016 - Excluido validacao de conta nao cadastrada para TED (Jean Michel).
  ---------------------------------------------------------------------------------------------------------------*/
  BEGIN
    DECLARE
      --Cursores Locais

      --Selecionar contas migradas
      CURSOR cr_craptco (pr_cdcopant IN craptco.cdcopant%type
                        ,pr_nrctaant IN craptco.nrctaant%type
                        ,pr_tpctatrf IN craptco.tpctatrf%type) IS
        SELECT craptco.cdcopant
        FROM craptco
        WHERE craptco.cdcopant = pr_cdcopant
        AND   craptco.nrctaant = pr_nrctaant
        AND   craptco.tpctatrf = pr_tpctatrf;
      rw_craptco cr_craptco%ROWTYPE;

      --Selecionar contas migradas
      CURSOR cr_craptco_trf (pr_cdcooper IN craptco.cdcopant%type
                            ,pr_nrdconta IN craptco.nrctaant%type
                            ,pr_tpctatrf IN craptco.tpctatrf%type) IS
        SELECT craptco.cdcopant
        FROM craptco
        WHERE craptco.cdcooper = pr_cdcooper
        AND   craptco.nrdconta = pr_nrdconta
        AND   craptco.tpctatrf = pr_tpctatrf;

      --Tipo de Dados para cursor data
      rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

      CURSOR cr_crapsnh(pr_cdcooper IN crapsnh.cdcooper%TYPE
                       ,pr_nrdconta IN crapsnh.nrdconta%TYPE
                       ,pr_tpdsenha IN crapsnh.tpdsenha%TYPE
                       ,pr_cdsitsnh IN crapsnh.cdsitsnh%TYPE) IS

        SELECT snh.idseqttl
          FROM crapsnh snh
         WHERE snh.cdcooper = pr_cdcooper
           AND snh.nrdconta = pr_nrdconta
           AND snh.tpdsenha = pr_tpdsenha
           AND snh.cdsitsnh = pr_cdsitsnh;

      rw_crapsnh cr_crapsnh%ROWTYPE ;     

      --Variaveis Locais
      vr_vlsldisp  NUMBER;
      vr_dtdialim  DATE;
      vr_vltarifa  NUMBER;
      vr_cdhistor  INTEGER;
      vr_cdhisest  INTEGER;
      vr_cdfvlcop  INTEGER;
      vr_flgctafa  BOOLEAN;
      vr_datdodia  DATE;
      vr_dtferiado DATE;
      vr_dsblqage  VARCHAR2(100);
      vr_cddbanco  crapcti.cddbanco%TYPE;
      vr_vldspptl  crapsnh.vllimweb%TYPE;
      vr_vldspttl  crapsnh.vllimweb%TYPE;
      vr_vllimptl  crapsnh.vllimweb%TYPE;
      vr_vllimttl  crapsnh.vllimweb%TYPE;
      vr_vllimcop  crapsnh.vllimweb%TYPE;
      vr_nmtitula  crapass.nmprimtl%TYPE;
      vr_nmtitul2  crapass.nmprimtl%TYPE;
      vr_cdcopctl  crapcop.cdcooper%TYPE;
      vr_flvldrep  NUMBER(1) := 0;
      vr_idseqttl  crapttl.idseqttl%TYPE := 0;

      --Variaveis de Erro
      vr_cdcritic  crapcri.cdcritic%TYPE;
      vr_dscritic  VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_saida EXCEPTION;
      vr_exc_erro  EXCEPTION;
      --Variaveis de Indice
      --Tabela de memoria de erro
      vr_tab_erro  GENE0001.typ_tab_erro;
      --Tipo da tabela de saldos
      vr_tab_saldo EXTR0001.typ_tab_saldos;
    BEGIN
      --Inicializar varaivel retorno erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      /** Monta descricao da transacao **/
      pr_dstransa:= 'Validar ';
      --Se for agendamento
      IF pr_idagenda IN (2,3) THEN
        pr_dstransa:= pr_dstransa || 'Agendamento de ';
      END IF;
      --Se for transferencia
      IF pr_tpoperac = 1  THEN /** Operacao de Transferencia **/
        IF pr_cdtiptra = 1 THEN
          pr_dstransa:= pr_dstransa || 'Transferencia de Valores';
        ELSIF pr_cdtiptra = 3 THEN
          pr_dstransa:= pr_dstransa || 'Credito de Salario';
        END IF;
      ELSIF pr_tpoperac = 4 THEN
        pr_dstransa:= pr_dstransa || 'TED';
      ELSIF pr_tpoperac = 2 THEN  /** Operacao de Pagamento **/
        pr_dstransa:= pr_dstransa || 'Pagamento de Titulos e Faturas';
      ELSIF pr_tpoperac = 5 THEN  /** Operacao de Transferencia Intercooperativa **/
        pr_dstransa:= pr_dstransa || 'Transferencia Intercooperativa';
      ELSIF pr_tpoperac = 6 THEN  /** Operacao de Pagamento VR-Boleto **/
        pr_dstransa:= pr_dstransa || 'Pagamento de VR-Boletos ';
      END IF;

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      -- Se n¿o encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic:= 651;
        vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;
      -- Verifica se a data esta cadastrada
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
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
      --Verificar se o associado existe
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      -- Se n¿o encontrar
      IF cr_crapass%NOTFOUND THEN
        -- Fechar o cursor pois haver¿ raise
        CLOSE cr_crapass;
        -- Montar mensagem de critica
        vr_cdcritic:= 9;
        vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapass;
      END IF;

      /** Verifica o horario inicial e final para a operacao **/
      pc_horario_operacao (pr_cdcooper   => pr_cdcooper  --Codigo Cooperativa
                          ,pr_cdagenci   => pr_cdagenci  --Agencia do Associado
                          ,pr_tpoperac   => pr_tpoperac  --Tipo de Operacao (0=todos)
                          ,pr_inpessoa   => rw_crapass.inpessoa --Tipo de Pessoa
                          ,pr_tab_limite => pr_tab_limite --Tabelas de retorno de horarios limite
                          ,pr_cdcritic   => vr_cdcritic   --Codigo do erro
                          ,pr_dscritic   => vr_dscritic); --Descricao do erro
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      vr_idseqttl := pr_idseqttl;

      IF rw_crapass.idastcjt = 1 AND pr_idseqttl = 1 THEN 
        OPEN cr_crapsnh(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_tpdsenha => 1           
                       ,pr_cdsitsnh => 1);
                       
        FETCH cr_crapsnh INTO rw_crapsnh;

        IF cr_crapsnh%NOTFOUND THEN
          CLOSE cr_crapsnh;
          vr_idseqttl := pr_idseqttl;
        ELSE                               
          CLOSE cr_crapsnh;
          vr_idseqttl := rw_crapsnh.idseqttl;
        END IF;

      END IF;

      /* Buscar Limites da internet */
      pc_busca_limites (pr_cdcooper     => pr_cdcooper  --Codigo Cooperativa
                       ,pr_nrdconta     => pr_nrdconta  --Numero da conta
                       ,pr_idseqttl     => vr_idseqttl  --Identificador Sequencial titulo
                       ,pr_flglimdp     => TRUE         --Indicador limite deposito
                       ,pr_dtmvtopg     => pr_dtmvtopg  --Data do proximo pagamento
                       ,pr_flgctrag     => pr_flgctrag  --Indicador validacoes
                       ,pr_dsorigem     => pr_dsorigem  --Descricao Origem
                       ,pr_tab_internet => pr_tab_internet --Tabelas de retorno de horarios limite
                       ,pr_cdcritic     => vr_cdcritic   --Codigo do erro
                       ,pr_dscritic     => vr_dscritic); --Descricao do erro;
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      /** Obtem limites do titular **/
      IF NOT pr_tab_internet.EXISTS(vr_idseqttl) THEN
        vr_cdcritic:= 0;
        vr_dscritic:= 'Registro de limite nao encontrado.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      IF pr_tpoperac = 6 THEN /* VR Boleto */
        --Saldo todos os titulares
        vr_vldspptl:= pr_tab_internet(vr_idseqttl).vllimvrb;
        --Limite para internet
        vr_vllimttl:= pr_tab_internet(vr_idseqttl).vllimvrb;
        --Limite diario
        vr_vllimptl:= pr_tab_internet(vr_idseqttl).vllimvrb;
        --Limite da operacao na cooperativa
        vr_vllimcop:= pr_tab_internet(vr_idseqttl).vlvrbcop;
      ELSE
        IF pr_tpoperac = 4 THEN /* TED */
          --Saldo primeiro titular
          vr_vldspptl:= pr_tab_internet(vr_idseqttl).vldspted;
          --Saldo todos titulares
          vr_vldspttl:= pr_tab_internet(vr_idseqttl).vldspted;
          --Limite diario
          vr_vllimptl:= pr_tab_internet(vr_idseqttl).vllimted;
          --Limite para internet
          vr_vllimttl:= pr_tab_internet(vr_idseqttl).vllimted;
          --Limite da operacao na cooperativa
          vr_vllimcop:= pr_tab_internet(vr_idseqttl).vltedcop;
        ELSIF rw_crapass.inpessoa = 1 THEN /* Pessoa Fisica */
          --Saldo primeiro titular
          vr_vldspptl:= pr_tab_internet(vr_idseqttl).vldspweb;
          --Saldo todos titulares
          vr_vldspttl:= pr_tab_internet(vr_idseqttl).vldspweb;
          --Limite diario
          vr_vllimptl:= pr_tab_internet(vr_idseqttl).vllimweb;
          --Limite para internet
          vr_vllimttl:= pr_tab_internet(vr_idseqttl).vllimweb;
          --Limite da operacao na cooperativa
          vr_vllimcop:= pr_tab_internet(vr_idseqttl).vlwebcop;
        ELSIF rw_crapass.inpessoa > 1 THEN /* Pessoa Juridica */
          --Pagamento
          IF pr_tpoperac = 2  THEN
            --Saldo primeiro titular
            vr_vldspptl:= pr_tab_internet(vr_idseqttl).vldsppgo;
            --Saldo todos titulares
            vr_vldspttl:= pr_tab_internet(vr_idseqttl).vldsppgo;
            --Limite diario
            vr_vllimptl:= pr_tab_internet(vr_idseqttl).vllimpgo;
            --Limite para internet
            vr_vllimttl:= pr_tab_internet(vr_idseqttl).vllimpgo;
            --Limite da operacao na cooperativa
            vr_vllimcop:= pr_tab_internet(vr_idseqttl).vlpgocop;
          ELSE  /* Transferencia */
            --Saldo primeiro titular
            vr_vldspptl:= pr_tab_internet(vr_idseqttl).vldsptrf;
            --Saldo todos titulares
            vr_vldspttl:= pr_tab_internet(vr_idseqttl).vldsptrf;
            --Limite diario
            vr_vllimptl:= pr_tab_internet(vr_idseqttl).vllimtrf;
            --Limite para internet
            vr_vllimttl:= pr_tab_internet(vr_idseqttl).vllimtrf;
            --Limite da operacao na cooperativa
            vr_vllimcop:= pr_tab_internet(vr_idseqttl).vltrfcop;
          END IF;
        END IF;
      END IF;

      --Se o limite estiver zerado
      IF vr_vllimcop = 0  THEN
        vr_cdcritic:= 0;
        vr_dscritic:= 'Este servico nao esta habilitado. Duvidas entre em contato com a cooperativa.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      /** Obtem limites do primeiro titular se for pessoa fisica **/
      IF rw_crapass.inpessoa = 1 AND pr_idseqttl > 1 THEN
        IF pr_tab_internet.COUNT = 0 THEN
          vr_cdcritic:= 0;
          vr_dscritic:= 'Limite para internet nao cadastrado. Entre em contato com seu PA.';
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        IF pr_tpoperac = 6 THEN /* VR Boleto */
          --Limite diario
          vr_vllimptl:= pr_tab_internet(vr_idseqttl).vllimvrb;
        ELSE
          IF pr_tpoperac = 4 THEN /* TED */
            --Saldo primeiro titular
            vr_vldspptl:= pr_tab_internet(vr_idseqttl).vldspted;
            --Limite diario
            vr_vllimptl:= pr_tab_internet(vr_idseqttl).vllimted;
          ELSIF rw_crapass.inpessoa = 1 THEN /* Pessoa Fisica */
            --Saldo primeiro titular
            vr_vldspptl:= pr_tab_internet(vr_idseqttl).vldspweb;
            --Limite diario
            vr_vllimptl:= pr_tab_internet(vr_idseqttl).vllimweb;
          ELSIF rw_crapass.inpessoa > 1 THEN /* Pessoa Juridica */
            --Pagamento
            IF pr_tpoperac = 2  THEN
              --Saldo primeiro titular
              vr_vldspptl:= pr_tab_internet(vr_idseqttl).vldsppgo;
              --Limite diario
              vr_vllimptl:= pr_tab_internet(vr_idseqttl).vllimpgo;
            ELSE  /* Transferencia */
              --Saldo primeiro titular
              vr_vldspptl:= pr_tab_internet(vr_idseqttl).vldsptrf;
              --Limite diario
              vr_vllimptl:= pr_tab_internet(vr_idseqttl).vllimtrf;
            END IF;
          END IF;
        END IF;
      END IF;

      --Se o limite estiver zerado
      IF vr_vllimptl = 0 OR vr_vllimttl = 0 THEN
        vr_cdcritic:= 0;
        vr_dscritic:= 'Limite para internet nao cadastrado. Entre em contato com seu PA.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      --Se nao for para validar retorna
      IF NOT pr_flgvalid THEN
        --Sair
        RAISE vr_exc_saida;
      END IF;

      --Buscar a data do dia
      vr_datdodia:= trunc(sysdate); /*PAGA0001.fn_busca_datdodia(pr_cdcooper => pr_cdcooper);*/
      /** Verificar se a conta pertence a um PAC migrado e eh agendamento **/
      OPEN cr_craptco (pr_cdcopant => pr_cdcooper
                      ,pr_nrctaant => pr_nrdconta
                      ,pr_tpctatrf => 1);
      FETCH cr_craptco INTO rw_craptco;
      IF cr_craptco%FOUND AND pr_idagenda >= 2 THEN

        --Buscar parametro com data limite conta bloqueada
        vr_dsblqage:= gene0001.fn_param_sistema('CRED',pr_cdcooper,'DT_BLOQ_AGEN_CTA_MIGRADA');
        --Se nao encontrou parametro
        IF vr_dsblqage IS NULL THEN
          --Montar mensagem de erro
          vr_dscritic:= 'Não foi encontrado parametro de bloqueio de agendamento de contas migradas.';
          --Levantar Exceção
          RAISE vr_exc_erro;
        END IF;
        /** Bloquear agendamentos para conta migrada **/
        IF vr_datdodia >= to_date(vr_dsblqage,'DD/MM/YYYY') AND rw_craptco.cdcopant NOT IN (4,15) THEN
          vr_cdcritic:= 0;
          vr_dscritic:= 'Operacao de agendamento bloqueada. Entre em contato com seu PA.';
          --Fechar Cursor
          CLOSE cr_craptco;
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
      END IF;
      --Fechar Cursor
      CLOSE cr_craptco;
      --Verificar se existe informacao na tabela limite
      IF pr_tab_limite.Count = 0 THEN
        vr_cdcritic:= 0;
        vr_dscritic:= 'Tabela de limites nao encontrada.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      /** Validar horario para pagamento **/

      --Se for pagamento na data e estourou horario
      IF pr_flgctrag AND pr_idagenda = 1 AND pr_tab_limite(pr_tab_limite.FIRST).idesthor = 1 THEN
        IF pr_tpoperac IN (1,5) THEN
          vr_dscritic:= 'Horario esgotado para transferencias.';
        ELSIF pr_tpoperac = 4 THEN
          vr_dscritic:= 'Horario esgotado para envio de TED.';
        ELSE
          vr_dscritic:= 'Horario esgotado para pagamentos.';
        END IF;
        vr_cdcritic:= 0;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      /** Ultimo dia util do ano da data do pagamento/agendamento **/
      IF  pr_idagenda = 1 THEN
        --Dia Limite
        vr_dtdialim:= To_Date('31/12/'||To_Char(vr_datdodia,'YYYY'),'DD/MM/YYYY');
      ELSE
        --Dia limite
        vr_dtdialim:= To_Date('31/12/'||To_Char(pr_dtmvtopg,'YYYY'),'DD/MM/YYYY');
      END IF;
      --Retonar Dia Util
      vr_dtdialim:= GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                               ,pr_dtmvtolt => vr_dtdialim --> Data do movimento
                                               ,pr_tipo     => 'A'         --> Dia Anterior
                                               ,pr_feriado  => FALSE);     --> Nao considera feriados
      --Se for transferencia ou ted
      IF pr_tpoperac IN (1,4,5) THEN
        /** Data do agendamento nao pode ser o ultimo dia util do ano **/
        IF (pr_tpoperac IN (1,5) AND pr_idagenda = 2) AND
           pr_dtmvtopg = vr_dtdialim THEN
           
            vr_dscritic := 'Nao e possivel efetuar agendamentos para este dia.';
          vr_cdcritic:= 0;
          
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        IF  pr_tpoperac = 4 AND pr_tab_limite(pr_tab_limite.FIRST).iddiauti = 2 THEN
          vr_cdcritic := 0;
          vr_dscritic := 'O envio de TED deve ser efetuado em dias uteis.';
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        --Validar conta destino se for transferencia
        IF pr_tpoperac IN (1,5) THEN /** Transf ou Transf. intercop. **/
          
          --Validar operacao com cooperativa destino
          --Seleciona cooperativa atraves de campo cdagectl
          BEGIN
            SELECT cdcooper INTO vr_cdcopctl FROM crapcop WHERE crapcop.cdagectl = pr_cdageban;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Problema ao cncontrar agencia destino';
              RAISE vr_exc_erro;  
          END;
          IF pr_tpoperac = 1 AND 
            (pr_cdcooper <> vr_cdcopctl) THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Cooperativa destino diferente do esperado';
            RAISE vr_exc_erro;
          END IF;
        
          --Inicializar tabela erros
          vr_tab_erro.DELETE;
          --Validar Conta Destino
          pc_valida_conta_destino (pr_cdcooper => pr_cdcooper  --Codigo Cooperativa
                                  ,pr_cdagenci => pr_cdagenci  --Agencia do Associado
                                  ,pr_nrdcaixa => pr_nrdcaixa  --Numero caixa
                                  ,pr_cdoperad => pr_cdoperad  --Codigo Operador
                                  ,pr_nrdconta => pr_nrdconta  --Numero da conta
                                  ,pr_idseqttl => pr_idseqttl  --Identificador Sequencial titular
                                  ,pr_cdagectl => pr_cdageban  --Codigo Agencia
                                  ,pr_nrctatrf => pr_nrctatrf  --Numero Conta Transferencia
                                  ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento
                                  ,pr_cdtiptra => pr_cdtiptra  --Tipo de Transferencia
                                  ,pr_flgctafa => vr_flgctafa  --Indicador conta cadastrada
                                  ,pr_nmtitula => vr_nmtitula  --Nome titular
                                  ,pr_nmtitul2 => vr_nmtitul2  --Nome segundo titular
                                  ,pr_cddbanco => vr_cddbanco   --Codigo banco
                                  ,pr_dscritic => vr_dscritic   --Retorno OK/NOK
                                  ,pr_tab_erro => vr_tab_erro); --Tabela retorno erro
          --Se ocorreu erro
          IF vr_dscritic = 'NOK' THEN
            -- Tenta buscar o erro no vetor de erro
            IF vr_tab_erro.COUNT > 0 THEN
              vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
              vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic|| ' Conta: '||pr_nrdconta;
            ELSE
              vr_cdcritic:= 0;
              vr_dscritic:= 'Erro na validacao da conta destino.';
            END IF;
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;

          -- Nao permitir transf. intercooperativa para contas da Concredi e Credimilsul, durante e apos a migracao
          IF pr_tpoperac IN (5) AND vr_datdodia >= to_date('29/11/2014','dd/mm/RRRR') AND
            vr_cdcopctl IN (4,15)THEN

               OPEN cr_craptco_trf(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrctatrf
                                  ,pr_tpctatrf => 1);

               IF cr_craptco_trf%FOUND THEN
                 vr_cdcritic := 0;
                 vr_dscritic := 'Conta destino nao habilitada  para receber valores da transferencia.';
                 --Levantar Excecao
                 RAISE vr_exc_erro;
               END IF;

            END IF;

        ELSE
          /** Verifica se a conta que ira receber o valor esta   **/
          /** cadastrada para a conta que ira transferir o valor **/
          OPEN cr_crapcti (pr_cdcooper => pr_cdcooper
                          ,pr_cddbanco => pr_cddbanco
                          ,pr_cdageban => pr_cdageban
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrctatrf => pr_nrctatrf);
          --Posicionar no primeiro registro
          FETCH cr_crapcti INTO rw_crapcti;
          --Se nao encontrou ou a conta naoesta ativa
          IF cr_crapcti%FOUND AND rw_crapcti.insitcta <> 2 THEN  /** Ativa **/
            vr_cdcritic:= 0;
            vr_dscritic:= 'Conta destino nao habilitada para receber valores da transferencia.';
            --Fechar Cursor
            CLOSE cr_crapcti;
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
          --Fechar Cursor
          CLOSE cr_crapcti;
        END IF;
      ELSE
        IF pr_tpoperac = 2 THEN  /** Pagamento **/
          /** Critica se data do pagamento for no ultimo dia util do ano **/
          IF (pr_idagenda = 1 AND pr_dtmvtolt = vr_dtdialim) OR
             (pr_idagenda > 1 AND pr_dtmvtopg = vr_dtdialim) THEN
            vr_cdcritic:= 0;
            IF pr_idagenda = 1 THEN
              vr_dscritic:= 'Nao e possivel efetuar pagamentos neste dia.';
            ELSE
              vr_dscritic:= 'Nao e possivel efetuar agendamentos para este dia.';
            END IF;
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
        END IF;
      END IF;
      --Se o valor da transacao for zero
      IF pr_vllanmto = 0 THEN
        vr_cdcritic:= 0;
        vr_dscritic:= 'O valor da transacao nao pode ser 0 (zero).';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      /** Verifica se pode movimentar o valor desejado - limite diario **/
      IF  pr_vllanmto > vr_vllimptl  THEN
        vr_cdcritic:= 0;
        vr_dscritic:= 'O saldo do seu limite diario é insuficiente para esse pagamento.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      /** Verifica se pode movimentar o valor desejado - limite cooperativa **/
      IF  pr_vllanmto > vr_vllimcop AND pr_tpoperac = 6 THEN
        vr_cdcritic:= 0;
        vr_dscritic:= 'Valor da operacao superior ao limite da cooperativa.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      /** Verifica se titular tem limite para movimentar o valor **/
      IF rw_crapass.inpessoa = 1 AND pr_idseqttl > 1 AND pr_vllanmto > vr_vllimttl THEN
        vr_cdcritic:= 0;
        vr_dscritic:= 'O saldo do seu limite diario é insuficiente para esse pagamento.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      /** Verifica se pode movimentar em relacao ao que ja foi usado **/
      /** no dia por todos os titulares                              **/
      IF pr_vllanmto > vr_vldspptl  THEN
        vr_cdcritic:= 0;
        vr_dscritic:= 'O saldo do seu limite diario é insuficiente para esse pagamento.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      /** Verifica se pode movimentar em relacao ao que ja foi usado **/
      /** no dia pelo titular                                        **/
      IF rw_crapass.inpessoa = 1 AND pr_idseqttl > 1 AND pr_vllanmto > vr_vldspttl THEN
        vr_cdcritic:= 0;
        vr_dscritic:= 'O saldo do seu limite diario é insuficiente para esse pagamento.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      IF  pr_idagenda = 1 THEN
        /* Nao validar saldo para operadores na internet */
        IF pr_nrcpfope = 0 THEN
          --Limpar tabela saldo e erro
          vr_tab_saldo.DELETE;
          vr_tab_erro.DELETE;
          /** Verifica se possui saldo para fazer a operacao **/
          EXTR0001.pc_obtem_saldo_dia (pr_cdcooper   => pr_cdcooper
                                      ,pr_rw_crapdat => rw_crapdat
                                      ,pr_cdagenci   => pr_cdagenci
                                      ,pr_nrdcaixa   => pr_nrdcaixa
                                      ,pr_cdoperad   => pr_cdoperad
                                      ,pr_nrdconta   => pr_nrdconta
                                      ,pr_vllimcre   => rw_crapass.vllimcre
                                      ,pr_tipo_busca => 'A' --> tipo de busca(A-dtmvtoan)
                                      ,pr_dtrefere   => vr_datdodia
                                      ,pr_flgcrass   => FALSE                                                        
                                      ,pr_des_reto   => vr_dscritic
                                      ,pr_tab_sald   => vr_tab_saldo
                                      ,pr_tab_erro   => vr_tab_erro);
                                      
          --Se ocorreu erro
          IF vr_dscritic = 'NOK' THEN
            -- Tenta buscar o erro no vetor de erro
            IF vr_tab_erro.COUNT > 0 THEN
              vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
              vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic|| ' Conta: '||pr_nrdconta;
            ELSE
              vr_cdcritic:= 0;
              vr_dscritic:= 'Retorno "NOK" na extr0001.pc_obtem_saldo_dia e sem informacao na pr_tab_erro, Conta: '||pr_nrdconta;
            END IF;
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
          --Verificar o saldo retornado
          IF vr_tab_saldo.Count = 0 THEN
            --Montar mensagem erro
            vr_cdcritic:= 0;
            vr_dscritic:= 'Nao foi possivel consultar o saldo para a operacao.';
            --Levantar Excecao
            RAISE vr_exc_erro;
          ELSE
            --Total disponivel recebe valor disponivel + limite credito
            vr_vlsldisp:= nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vlsddisp,0) + nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vllimcre,0);
            --Se o saldo nao for suficiente
            IF pr_vllanmto > vr_vlsldisp THEN
              --Montar mensagem erro
              vr_cdcritic:= 0;
              vr_dscritic:= 'Nao ha saldo suficiente para a operacao.';
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;
            /** Obtem valor da tarifa TED **/
            IF pr_tpoperac = 4 THEN
              --Buscar tarifa da TED
              CXON0020.pc_busca_tarifa_ted (pr_cdcooper => pr_cdcooper  --Codigo Cooperativa
                                           ,pr_cdagenci => 90           --Codigo Agencia
                                           ,pr_nrdconta => pr_nrdconta  --Numero da Conta
                                           ,pr_vllanmto => pr_vllanmto  --Valor Lancamento
                                           ,pr_vltarifa => vr_vltarifa  --Valor Tarifa
                                           ,pr_cdhistor => vr_cdhistor  --Historico da tarifa
                                           ,pr_cdhisest => vr_cdhisest  --Historico estorno
                                           ,pr_cdfvlcop => vr_cdfvlcop  --Codigo Filial Cooperativa
                                           ,pr_cdcritic => vr_cdcritic  --C¿digo do erro
                                           ,pr_dscritic => vr_dscritic);  --Descricao do erro
              --Se ocorreu erro
              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                --Levantar Excecao
                RAISE vr_exc_erro;
              END IF;
              --Somar valor tarifa no lancamento
              pr_vllanmto:= nvl(pr_vllanmto,0) + Nvl(vr_vltarifa,0);
            ELSIF  pr_tpoperac = 5  THEN /** Tarifa Transf.Intercoop. **/
              --Buscar tarifa da TED
              TARI0001.pc_busca_tar_transf_intercoop (pr_cdcooper => pr_cdcooper  --Codigo Cooperativa
                                                     ,pr_cdagenci => 90           --Codigo Agencia
                                                     ,pr_nrdconta => pr_nrdconta  --Numero da Conta
                                                     ,pr_vllanmto => pr_vllanmto  --Valor Lancamento
                                                     ,pr_vltarifa => vr_vltarifa  --Valor Tarifa
                                                     ,pr_cdhistor => vr_cdhistor  --Historico da tarifa
                                                     ,pr_cdhisest => vr_cdhisest  --Historico estorno
                                                     ,pr_cdfvlcop => vr_cdfvlcop  --Codigo Filial Cooperativa
                                                     ,pr_cdcritic => vr_cdcritic  --C¿digo do erro
                                                     ,pr_dscritic => vr_dscritic);  --Descricao do erro
              --Se ocorreu erro
              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                --Levantar Excecao
                RAISE vr_exc_erro;
              END IF;
              --Somar valor tarifa no lancamento
              pr_vllanmto:= nvl(pr_vllanmto,0) + Nvl(vr_vltarifa,0);
            END IF;
            --Se o valor do lancamento maior valor disponivel
            IF pr_vllanmto > vr_vlsldisp THEN
              --Montar mensagem erro
              vr_cdcritic:= 0;
              vr_dscritic:= 'Saldo insuficiente para debito da tarifa.';
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;
          END IF;
        END IF;
      ELSIF pr_idagenda >= 2  THEN /** Agendamento normal e recorrente **/
        /** Verifica se data de debito e uma data futura **/
        IF  pr_dtmvtopg <= Trunc(vr_datdodia)  THEN
          --Montar mensagem erro
          vr_cdcritic:= 0;
          vr_dscritic:= 'Agendamento deve ser feito para uma data futura.';
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        /** Agendamento normal **/
        IF pr_idagenda = 2 THEN
          --Verificar se eh feriado
          vr_dtferiado:= GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                                    ,pr_dtmvtolt => vr_datdodia --> Data do movimento
                                                    ,pr_tipo     => 'P'         --> Dia Anterior
                                                    ,pr_feriado  => TRUE);      --> Considera feriados

          IF NOT pr_tab_limite(pr_tab_limite.FIRST).flsgproc AND
             pr_dtmvtopg = pr_dtmvtolt AND
             vr_dtferiado <> vr_datdodia THEN
            --Dia limite recebe data atual + 1
            vr_dtdialim:= pr_dtmvtolt + 1;
            --Busca proximo dia util
            vr_dtdialim:= GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                                     ,pr_dtmvtolt => vr_dtdialim --> Data do movimento
                                                     ,pr_tipo     => 'A'         --> Dia Anterior
                                                     ,pr_feriado  => FALSE);      --> Nao Considera feriados
            --Montar mensagem erro
            vr_cdcritic:= 0;
            vr_dscritic:= 'A data minima para efetuar agendamento e '||To_Char(vr_dtdialim,'DD/MM/YYYY')||'.';
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;          
          --Verifcar se a agencia existe
          OPEN cr_crapage (pr_cdcooper => pr_cdcooper
                          ,pr_cdagenci => pr_cdagenci);
          --Posicionar primeiro registro
          FETCH cr_crapage INTO rw_crapage;
          --Se nao encontrou
          IF cr_crapage%NOTFOUND THEN
            --Fechar Cursor
            CLOSE cr_crapage;
            --Montar mensagem erro
            vr_cdcritic:= 0;
            vr_dscritic:= 'PA nao cadastrado';
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
          --Fechar Cursor
          CLOSE cr_crapage;
          --Dia limite recebe dia + quantidade dias lancamento
          vr_dtdialim:= vr_datdodia + rw_crapage.qtddaglf;
          --Se data agendamento > data Limite
          IF  pr_dtmvtopg > vr_dtdialim  THEN
            --Busca proximo dia util
            vr_dtdialim:= GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                                     ,pr_dtmvtolt => vr_dtdialim --> Data do movimento
                                                     ,pr_tipo     => 'A'         --> Dia Anterior
                                                     ,pr_feriado  => TRUE);      --> Considera feriados
            --Montar mensagem erro
            vr_cdcritic:= 0;
            vr_dscritic:= 'A data limite para efetuar agendamentos e '||To_Char(vr_dtdialim,'DD/MM/YYYY')||'.';
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
        END IF;
        
        --Agendamento Recorrente
        IF pr_idagenda = 3 THEN
          
          -- Dia limite recebe dia + quantidade dias limite para o primeiro lancamento
          vr_dtdialim := ADD_MONTHS(vr_datdodia,120); -- 10 anos
          --Se data agendamento > data Limite
          IF  pr_dtmvtopg > vr_dtdialim  THEN
            --Busca proximo dia util
            vr_dtdialim:= GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                                     ,pr_dtmvtolt => vr_dtdialim --> Data do movimento
                                                     ,pr_tipo     => 'A'         --> Dia Anterior
                                                     ,pr_feriado  => TRUE);      --> Considera feriados
            --Montar mensagem erro
            vr_cdcritic:= 0;
            vr_dscritic:= 'A data limite para inicio dos agendamentos e '||To_Char(vr_dtdialim,'DD/MM/YYYY')||'.';
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
        END IF;

      END IF;

    EXCEPTION
       WHEN vr_exc_saida THEN
         --OK
         pr_cdcritic:= NULL;
         pr_dscritic:= NULL;
       WHEN vr_exc_erro THEN
         pr_cdcritic:= vr_cdcritic;
         pr_dscritic:= vr_dscritic;
       WHEN OTHERS THEN
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro na rotina INET0001.pc_verifica_operacao. '||SQLERRM;
    END;
  END pc_verifica_operacao;
  
  /** Chamada para ser utilizada no Progress - 
      Procedure para validar limites para transacoes (Transf./Pag./Cob.) **/
  PROCEDURE pc_verifica_operacao_prog ( pr_cdcooper IN crapcop.cdcooper%type  -- Codigo Cooperativa
                                       ,pr_cdagenci IN crapage.cdagenci%type  -- Agencia do Associado
                                       ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE  -- Numero caixa
                                       ,pr_nrdconta IN crapass.nrdconta%TYPE  -- Numero da conta
                                       ,pr_idseqttl IN crapttl.idseqttl%TYPE  -- Identificador Sequencial titulo
                                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  -- Data Movimento
                                       ,pr_idagenda IN INTEGER                -- Indicador agenda
                                       ,pr_dtmvtopg IN craplau.dtmvtopg%TYPE  -- Data Pagamento
                                       ,pr_vllanmto IN OUT craplcm.vllanmto%TYPE  --Valor Lancamento
                                       ,pr_cddbanco IN crapcti.cddbanco%TYPE  -- Codigo banco
                                       ,pr_cdageban IN crapcti.cdageban%TYPE  -- Codigo Agencia
                                       ,pr_nrctatrf IN crapcti.nrctatrf%TYPE  -- Numero Conta Transferencia
                                       ,pr_cdtiptra IN INTEGER                -- 1 - Transferencia / 2 - Pagamento /3 - Credito Salario / 4 - TED 
                                       ,pr_cdoperad IN crapope.cdoperad%TYPE  -- Codigo Operador
                                       ,pr_tpoperac IN INTEGER                -- 1 - Transferencia intracooperativa /2 - Pagamento /3 - Cobranca /4 - TED / 5 - Transferencia intercooperativa 
                                       ,pr_flgvalid IN INTEGER                -- (0- False, 1-True)Indicador validacoes
                                       ,pr_dsorigem IN craplau.dsorigem%TYPE  -- Descricao Origem
                                       ,pr_nrcpfope IN crapopi.nrcpfope%TYPE  -- CPF operador
                                       ,pr_flgctrag IN INTEGER                -- (0- False, 1-True)controla validacoes na efetivacao de agendamentos 
                                       ,pr_nmdatela IN VARCHAR2
                                       ,pr_dstransa     OUT VARCHAR2          -- Descricao da transacao
                                       ,pr_tab_limite   OUT CLOB              -- Tabelas de retorno de horarios limite
                                       ,pr_tab_internet OUT CLOB              -- Tabelas de retorno de horarios limite
                                       ,pr_cdcritic     OUT INTEGER           -- Codigo do erro
                                       ,pr_dscritic     OUT VARCHAR2) IS      -- Descricao do erro
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_verifica_operacao_prog           Antigo: b1wgen0015.p/verifica_operacao
  --  Sistema  : Procedimentos para o debito de agendamentos feitos na Internet
  --  Sigla    : CRED
  --  Autor    : Odirlei Busana - Amcom
  --  Data     : maio/2015.                   Ultima atualizacao: 24/09/2015
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Chamada para ser utilizada no Progress -
  --             Procedure para validar limites para transacoes (Transf./Pag./Cob.)
  --
  -- Alteracoes: 24/09/2015 - Realizado a inclusão do pr_nmdatela (Adriano - SD 328034).
  --
  --
  ---------------------------------------------------------------------------------------------------------------
    -------------------------> VARIAVEIS <-------------------------
    vr_tab_limite     INET0001.typ_tab_limite;
    vr_tab_internet   INET0001.typ_tab_internet;
    vr_flsgproc       PLS_INTEGER;
    -- Variaveis de XML 
    vr_xml_temp VARCHAR2(32767);
    
  BEGIN
    
    /** Procedure para validar limites para transacoes (Transf./Pag./Cob.) **/
    pc_verifica_operacao (pr_cdcooper     => pr_cdcooper         --> Codigo Cooperativa
                         ,pr_cdagenci     => pr_cdagenci         --> Agencia do Associado
                         ,pr_nrdcaixa     => pr_nrdcaixa         --> Numero caixa
                         ,pr_nrdconta     => pr_nrdconta         --> Numero da conta
                         ,pr_idseqttl     => pr_idseqttl         --> Identificador Sequencial titulo
                         ,pr_dtmvtolt     => pr_dtmvtolt         --> Data Movimento
                         ,pr_idagenda     => pr_idagenda         --> Indicador agenda
                         ,pr_dtmvtopg     => pr_dtmvtopg         --> Data Pagamento
                         ,pr_vllanmto     => pr_vllanmto         --> Valor Lancamento
                         ,pr_cddbanco     => pr_cddbanco         --> Codigo banco
                         ,pr_cdageban     => pr_cdageban         --> Codigo Agencia
                         ,pr_nrctatrf     => pr_nrctatrf         --> Numero Conta Transferencia
                         ,pr_cdtiptra     => pr_cdtiptra         --> 1 - Transferencia / 2 - Pagamento / 3 - Credito Salario / 4 - TED */
                         ,pr_cdoperad     => pr_cdoperad         --> Codigo Operador
                         ,pr_tpoperac     => pr_tpoperac         --> 1 - Transferencia intracooperativa / 2 - Pagamento / 3 - Cobranca /  */     /* 4 - TED / 5 - Transferencia intercooperativa */
                         ,pr_flgvalid     => (pr_flgvalid = 1)   --> Indicador validacoes
                         ,pr_dsorigem     => pr_dsorigem         --> Descricao Origem
                         ,pr_nrcpfope     => pr_nrcpfope         --> CPF operador
                         ,pr_flgctrag     => (pr_flgctrag = 1)   --> controla validacoes na efetivacao de agendamentos */
                         ,pr_nmdatela     => pr_nmdatela         --> Nome da tela/programa que esta chamado a rotina
                         ,pr_dstransa     => pr_dstransa         --> Descricao da transacao
                         ,pr_tab_limite   => vr_tab_limite       --> INET0001.typ_tab_limite --Tabelas de retorno de horarios limite
                         ,pr_tab_internet => vr_tab_internet     --> INET0001.typ_tab_internet --Tabelas de retorno de horarios limite
                         ,pr_cdcritic     => pr_cdcritic         --> Codigo do erro
                         ,pr_dscritic     => pr_dscritic);       --> Descricao do erro
    -- se possui codigo, porém não possui descrição                     
    IF nvl(pr_cdcritic,0) > 0 AND 
       TRIM(pr_dscritic) IS NULL THEN
      -- buscar descrição
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic); 
       
    END IF;   
    
    --> DESCARREGAR TEMPTABLE DE LIMITES PARA O CLOB <---
    -- Criar documento XML
    dbms_lob.createtemporary(pr_tab_limite, TRUE); 
    dbms_lob.open(pr_tab_limite, dbms_lob.lob_readwrite);       

    -- Insere o cabeçalho do XML 
    gene0002.pc_escreve_xml(pr_xml            => pr_tab_limite 
                           ,pr_texto_completo => vr_xml_temp 
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><raiz>'); 

    FOR vr_contador IN nvl(vr_tab_limite.FIRST,0)..nvl(vr_tab_limite.LAST,-1) LOOP
      -- tratar boolean
      IF vr_tab_limite(vr_contador).flsgproc THEN
        vr_flsgproc := 1;
      ELSE
        vr_flsgproc := 0;
      END IF;  
    
      -- Montar XML com registros de carencia
      gene0002.pc_escreve_xml(pr_xml            => pr_tab_limite 
                             ,pr_texto_completo => vr_xml_temp 
                             ,pr_texto_novo     => '<limite>' 
                                                ||   '<hrinipag>'||vr_tab_limite(vr_contador).hrinipag    ||'</hrinipag>'
                                                ||   '<hrfimpag>'||vr_tab_limite(vr_contador).hrfimpag    ||'</hrfimpag>'
                                                ||   '<nrhorini>'||vr_tab_limite(vr_contador).nrhorini    ||'</nrhorini>'
                                                ||   '<nrhorfim>'||vr_tab_limite(vr_contador).nrhorfim    ||'</nrhorfim>'
                                                ||   '<idesthor>'||vr_tab_limite(vr_contador).idesthor    ||'</idesthor>'
                                                ||   '<iddiauti>'||vr_tab_limite(vr_contador).iddiauti    ||'</iddiauti>'
                                                ||   '<flsgproc>'||vr_flsgproc                            ||'</flsgproc>'
                                                ||   '<qtmesagd>'||vr_tab_limite(vr_contador).qtmesagd    ||'</qtmesagd>'
                                                ||   '<idtpdpag>'||vr_tab_limite(vr_contador).idtpdpag    ||'</idtpdpag>'
                                                || '</limite>');
    END LOOP;
       
    -- Encerrar a tag raiz 
    gene0002.pc_escreve_xml(pr_xml            => pr_tab_limite 
                           ,pr_texto_completo => vr_xml_temp 
                           ,pr_texto_novo     => '</raiz>' 
                           ,pr_fecha_xml      => TRUE);
                             
    
    --> DESCARREGAR TEMPTABLE DE TAB_INTERNET PARA O CLOB <---
    -- Criar documento XML
    dbms_lob.createtemporary(pr_tab_internet, TRUE); 
    dbms_lob.open(pr_tab_internet, dbms_lob.lob_readwrite);  
    vr_xml_temp := NULL;     

    -- Insere o cabeçalho do XML 
    gene0002.pc_escreve_xml(pr_xml            => pr_tab_internet 
                           ,pr_texto_completo => vr_xml_temp 
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><raiz>'); 

    FOR vr_contador IN nvl(vr_tab_internet.FIRST,0)..nvl(vr_tab_internet.LAST,-1) LOOP
    
      -- Montar XML com registros de carencia
      gene0002.pc_escreve_xml(pr_xml            => pr_tab_internet 
                             ,pr_texto_completo => vr_xml_temp 
                             ,pr_texto_novo     => '<internet>' 
                                                ||   '<idseqttl>'|| vr_tab_internet(vr_contador).idseqttl     ||   '</idseqttl>'
                                                /* Limite totais */                                        
                                                ||   '<vllimweb>'|| vr_tab_internet(vr_contador).vllimweb     ||   '</vllimweb>'
                                                ||   '<vllimpgo>'|| vr_tab_internet(vr_contador).vllimpgo     ||   '</vllimpgo>'
                                                ||   '<vllimtrf>'|| vr_tab_internet(vr_contador).vllimtrf     ||   '</vllimtrf>'
                                                ||   '<vllimted>'|| vr_tab_internet(vr_contador).vllimted     ||   '</vllimted>'
                                                ||   '<vllimvrb>'|| vr_tab_internet(vr_contador).vllimvrb     ||   '</vllimvrb>'
                                                /* Limite utilizado */                                     
                                                ||   '<vlutlweb>'|| vr_tab_internet(vr_contador).vlutlweb     ||   '</vlutlweb>'
                                                ||   '<vlutlpgo>'|| vr_tab_internet(vr_contador).vlutlpgo     ||   '</vlutlpgo>'
                                                ||   '<vlutltrf>'|| vr_tab_internet(vr_contador).vlutltrf     ||   '</vlutltrf>'
                                                ||   '<vlutlted>'|| vr_tab_internet(vr_contador).vlutlted     ||   '</vlutlted>'
                                                /* Limite disponivel */                             
                                                ||   '<vldspweb>'|| vr_tab_internet(vr_contador).vldspweb     ||   '</vldspweb>'
                                                ||   '<vldsppgo>'|| vr_tab_internet(vr_contador).vldsppgo     ||   '</vldsppgo>'
                                                ||   '<vldsptrf>'|| vr_tab_internet(vr_contador).vldsptrf     ||   '</vldsptrf>'
                                                ||   '<vldspted>'|| vr_tab_internet(vr_contador).vldspted     ||   '</vldspted>'
                                                /* Limite operacional cadastrado pela cooperativa */
                                                ||   '<vlwebcop>'|| vr_tab_internet(vr_contador).vlwebcop     ||   '</vlwebcop>'
                                                ||   '<vlpgocop>'|| vr_tab_internet(vr_contador).vlpgocop     ||   '</vlpgocop>'
                                                ||   '<vltrfcop>'|| vr_tab_internet(vr_contador).vltrfcop     ||   '</vltrfcop>'
                                                ||   '<vltedcop>'|| vr_tab_internet(vr_contador).vltedcop     ||   '</vltedcop>'
                                                ||   '<vlvrbcop>'|| vr_tab_internet(vr_contador).vlvrbcop     ||   '</vlvrbcop>'
                                                || '</internet>');
    END LOOP;
       
    -- Encerrar a tag raiz 
    gene0002.pc_escreve_xml(pr_xml            => pr_tab_internet 
                           ,pr_texto_completo => vr_xml_temp 
                           ,pr_texto_novo     => '</raiz>' 
                           ,pr_fecha_xml      => TRUE);
                           
                                                  
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Não foi possivel verificar operacao:'|| SQLERRM;
  END pc_verifica_operacao_prog;
 
END INET0001;
/
