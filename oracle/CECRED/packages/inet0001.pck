CREATE OR REPLACE PACKAGE CECRED.inet0001 AS

/*..............................................................................

    Programa: inet001                         Antiga: b1wgen0015.p
    Autor   : Evandro
    Data    : Abril/2006                      Ultima Atualizacao: 04/12/2018

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

            06/05/2016 - Incluido o campo nmtitul2 na typ_reg_contas_cadastradas.
                         (Jaison/Marcos - SUPERO)

       			10/05/2016 - Ajuste para retirar a criação do xml com as informações consultas. O 
    	        			     xml será criado pela rotina origem
           						  (Adriano - M117).
               
            25/05/2016 - Ajuste realizados:
                         -> Alterado o index utilizado para montar a tabela de faovericos a fim de 
                            possibilitar a ordenação por nome de favorecido;
                         -> Utilizar rotina genérica para consultar registro da craptab;
                         -> Retirado variáveis não utilizadas;
                         -> Ajustado tamanhdo do index e tamanho do campo nmitutla na pltable
                         (Adriano - M117).

            18/07/2016 - Incluido pr_tpoperac = 10 -> DARF, Prj. 338, nas procedure
                         pc_horario_operacao, pc_busca_limites e pc_verifica_operacao
                         (Jean Michel).         
         
			25/10/2016 - Novo ajuste na validacao do horario, solicitado pelo financeiro (Diego). 
         
            01/09/2018 - Alterações referentes ao projeto 475 - MELHORIAS SPB CONTINGÊNCIA - SPRINT B
                         Marcelo Telles Coelho - Mouts

			04/12/2018 - Ajuste na rotina de validação de agendamento de boletos. (Dionathan/Cechet)

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
           ,qtmesrec INTEGER
           ,qtmesfut INTEGER
           ,idtpdpag INTEGER    /* 1 - Transf / 2 - Pagamento */
           ,hrcancel VARCHAR2(5)
           ,nrhrcanc INTEGER
           ,dsdemail crapage.dsdemail%TYPE);

  --Tipo de tabela de memoria para limites
  TYPE typ_tab_limite IS TABLE OF typ_reg_limite INDEX BY PLS_INTEGER;

  --Tipo de Registro para Limites internet
  TYPE typ_reg_internet IS
    RECORD (idseqttl crapsnh.idseqttl%TYPE
           ,nrcpfope crapopi.nrcpfope%TYPE
           /* Limite totais */
           ,vllimweb crapsnh.vllimweb%TYPE
           ,vllimpgo crapsnh.vllimpgo%TYPE
           ,vllimtrf crapsnh.vllimtrf%TYPE
           ,vllimted crapsnh.vllimted%TYPE
           ,vllimvrb crapsnh.vllimted%TYPE
           ,vllimflp crapsnh.vllimflp%TYPE
           /* Limite utilizado */
           ,vlutlweb crapsnh.vllimweb%TYPE
           ,vlutlpgo crapsnh.vllimpgo%TYPE
           ,vlutltrf crapsnh.vllimtrf%TYPE
           ,vlutlted crapsnh.vllimted%TYPE
           ,vlutlvrb crapsnh.vllimvrb%TYPE
           ,vlutlflp crapsnh.vllimflp%TYPE
           /* Limite disponivel */
           ,vldspweb crapsnh.vllimweb%TYPE
           ,vldsppgo crapsnh.vllimpgo%TYPE
           ,vldsptrf crapsnh.vllimtrf%TYPE
           ,vldspted crapsnh.vllimted%TYPE
           ,vldspvrb crapsnh.vllimvrb%TYPE
           ,vldspflp crapsnh.vllimflp%TYPE     
           /* Limite operacional cadastrado pela cooperativa */
           ,vlwebcop crapsnh.vllimweb%TYPE
           ,vlpgocop crapsnh.vllimpgo%TYPE
           ,vltrfcop crapsnh.vllimtrf%TYPE
           ,vltedcop crapsnh.vllimted%TYPE
           ,vlvrbcop crapsnh.vllimted%TYPE
           ,vlflpcop crapsnh.vllimflp%TYPE );

  --Tipo de tabela para limite internet
  TYPE typ_tab_internet IS TABLE OF typ_reg_internet INDEX BY PLS_INTEGER;
  
  
  --Tipo de Registro para contas-cadastradas
  TYPE typ_reg_contas_cadastradas IS
    RECORD (intipdif crapcti.intipdif%TYPE
           ,cddbanco crapcti.cddbanco%TYPE
           ,cdageban crapcti.cdageban%TYPE
           ,nrctatrf crapcti.nrctatrf%TYPE
           ,nmtitula VARCHAR2(200)
           ,nmtitul2 crapttl.nmextttl%TYPE
           ,nrcpfcgc crapcti.nrcpfcgc%TYPE
           ,dscpfcgc VARCHAR2(20)
           ,dstransa VARCHAR2(255)
           ,dsoperad VARCHAR2(255)
           ,insitcta crapcti.insitcta%TYPE
           ,dssitcta VARCHAR2(255)
           ,inpessoa crapass.inpessoa%TYPE
           ,dsctatrf VARCHAR2(255)
           ,nmextbcc crapban.nmextbcc%TYPE
           ,nrseqcad crapcti.nrseqcad%TYPE
           ,dstipcta VARCHAR2(255)
           ,intipcta crapcti.intipcta%TYPE
           ,dsageban VARCHAR2(100)
           ,nrispbif crapcti.nrispbif%TYPE
           ,nmageban VARCHAR2(100)
           ); 
  TYPE typ_tab_contas_cadastradas IS TABLE OF typ_reg_contas_cadastradas INDEX BY VARCHAR2(210);

  TYPE typ_reg_finalidades IS
  RECORD (cdfinali PLS_INTEGER
         ,dsfinali VARCHAR2(100)
         ,flgselec PLS_INTEGER);
  TYPE typ_tab_finalidades IS TABLE OF typ_reg_finalidades INDEX BY PLS_INTEGER;
  

  /* Procedure para verificar horario permitido para transacoes */
  PROCEDURE pc_horario_operacao (pr_cdcooper IN crapcop.cdcooper%type  --C¿digo Cooperativa
                                ,pr_cdagenci IN crapage.cdagenci%type  --Agencia do Associado
                                ,pr_tpoperac IN INTEGER                --Tipo de Operacao (0=todos)
                                ,pr_inpessoa IN crapass.inpessoa%type  --Tipo de Pessoa
                                ,pr_idagenda IN INTEGER                --Tipo de agendamento
                                ,pr_cdtiptra IN INTEGER                --Tipo de transferencia
                                ,pr_tab_limite OUT INET0001.typ_tab_limite --Tabelas de retorno de horarios limite
                                ,pr_cdcritic   OUT INTEGER     --C¿digo do erro
                                ,pr_dscritic   OUT VARCHAR2);   --Descricao do erro

  PROCEDURE pc_horario_operacao_prog (pr_cdcooper IN crapcop.cdcooper%TYPE        --C¿digo Cooperativa
                                     ,pr_cdagenci IN crapage.cdagenci%type        --Agencia do Associado
                                     ,pr_tpoperac IN INTEGER                      --Tipo de Operacao (0=todos)
                                     ,pr_inpessoa IN crapass.inpessoa%type        --Tipo de Pessoa
                                     ,pr_tab_limite OUT CLOB        --XML de retorno de horarios limite
                                     ,pr_cdcritic   OUT INTEGER     --Código do erro
                                     ,pr_dscritic   OUT VARCHAR2);

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
  --
  /* Buscar limites de transacao do preposto*/                              
  PROCEDURE pc_busca_limites_prepo_trans(pr_cdcooper     IN crapcop.cdcooper%type        --C¿digo Cooperativa
                                        ,pr_nrdconta     IN crapass.nrdconta%TYPE        --Numero da conta
                                        ,pr_idseqttl     IN crapttl.idseqttl%TYPE        --Identificador Sequencial titulo
                                        ,pr_nrcpfope     IN crapopi.nrcpfope%TYPE        --Numero do CPF Preposto
                                        ,pr_dtmvtopg     IN crapdat.dtmvtolt%TYPE        --Data do proximo pagamento
                                        ,pr_dsorigem     IN craplau.dsorigem%TYPE        --Descricao Origem
                                        ,pr_tab_internet OUT INET0001.typ_tab_internet   --Tabelas de retorno de horarios limite
                                        ,pr_cdcritic     OUT INTEGER        --Codigo do erro
                                        ,pr_dscritic     OUT VARCHAR2);                             
  --
  -- Buscar limites operador
  PROCEDURE pc_busca_limites_opera_trans(pr_cdcooper     IN crapcop.cdcooper%type        --C¿digo Cooperativa
                                        ,pr_nrdconta     IN crapass.nrdconta%TYPE        --Numero da conta
                                        ,pr_idseqttl     IN crapttl.idseqttl%TYPE        --Identificador Sequencial titulo
                                        ,pr_nrcpfope     IN crapopi.nrcpfope%TYPE        --Numero do CPF Operador
                                        ,pr_dtmvtopg     IN crapdat.dtmvtolt%TYPE        --Data do proximo pagamento
                                        ,pr_dsorigem     IN craplau.dsorigem%TYPE        --Descricao Origem
                                        ,pr_tab_internet OUT INET0001.typ_tab_internet   --Tabelas de retorno de horarios limite
                                        ,pr_cdcritic     OUT INTEGER        --Codigo do erro
                                        ,pr_dscritic     OUT VARCHAR2);
  --
  /*Buscar os limites de transacao do operador*/                           
  PROCEDURE pc_verifica_idastcjt_pfp (pr_cdcooper IN crapcop.cdcooper%TYPE --Codigo Cooperativa
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE --Conta do Associado
                                     ,pr_idseqttl IN crapttl.idseqttl%type  --> Titularidade do Associado
                                     ,pr_nrcpfope IN crapass.nrcpfcgc%TYPE  --> CPF do Rep. Legal                                   
                                     ,pr_dsorigem IN VARCHAR2                --> Codigo Origem
                                     ,pr_indrowid IN VARCHAR2               --> Lista de Rowid da folha de pagamento
                                     ,pr_flsolest IN tbfolha_trans_pend.idestouro%TYPE          --> Indicador de solicitacao de estouro de conta (0 – Nao / 1 – Sim)
                                     ,pr_dsalerta OUT VARCHAR2
                                     ,pr_cdcritic OUT INTEGER  
                                     ,pr_dscritic OUT VARCHAR2);
                                     

  --
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
                                 ,pr_cdtiptra IN INTEGER  /* 1 - Transferencia / 2 - Pagamento / 3 - Credito Salario / 4 - TED*/
                                 ,pr_cdoperad IN crapope.cdoperad%TYPE  --Codigo Operador
                                 ,pr_tpoperac IN INTEGER  /* 1 - Transferencia intracooperativa / 2 - Pagamento / 3 - Cobranca / 4 - TED / 5 - Transferencia intercooperativa / 10 - DARF */
                                 ,pr_flgvalid IN BOOLEAN                --Indicador validacoes
                                 ,pr_dsorigem IN craplau.dsorigem%TYPE  --Descricao Origem
                                 ,pr_nrcpfope IN crapopi.nrcpfope%TYPE  --CPF Operador
                                 ,pr_flgctrag IN BOOLEAN /* controla validacoes na efetivacao de agendamentos */
                                 ,pr_nmdatela IN VARCHAR2
                                 ,pr_flgexage IN INTEGER DEFAULT 0 -- 1 - Efetua agendamento / 0 - não efetua agendamento
                                 ,pr_dstransa   OUT VARCHAR2               --Descricao da transacao
                                 ,pr_tab_limite OUT INET0001.typ_tab_limite --Tabelas de retorno de horarios limite
                                 ,pr_tab_internet OUT INET0001.typ_tab_internet --Tabelas de retorno de horarios limite
                                 ,pr_cdcritic   OUT INTEGER     --C¿digo do erro
                                 ,pr_dscritic   OUT VARCHAR2 --Descricao do erro
                                 ,pr_assin_conjunta OUT NUMBER);   --Descricao do erro

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

  /* Procedure para consulta de contas de trnsf cadastradas */
  PROCEDURE pc_con_contas_cadastradas ( pr_cdcooper IN crapcop.cdcooper%TYPE  -- Codigo Cooperativa
                                       ,pr_cdagenci IN crapage.cdagenci%TYPE  -- Agencia do Associado
                                       ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE  -- Numero caixa
                                       ,pr_cdoperad IN crapope.cdoperad%TYPE  -- Codigo Operador
                                       ,pr_nmdatela IN VARCHAR2               -- Nome da tela
                                       ,pr_idorigem IN INTEGER                -- Origem                                               
                                       ,pr_nrdconta IN crapass.nrdconta%TYPE  -- Numero da conta                                       
                                       ,pr_idseqttl IN crapttl.idseqttl%TYPE  -- Identificador Sequencial titulo                                       
                                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  -- Data Movimento
                                       ,pr_tppeslst IN INTEGER                
                                       ,pr_intipdif IN INTEGER
                                       ,pr_nmtitula IN VARCHAR2               -- Nome do titular
                                       ,pr_cdcritic OUT INTEGER               --> Código da critica
                                       ,pr_dscritic OUT VARCHAR2              --> Descrição da critica
                                       ,pr_tab_contas_cadastradas OUT typ_tab_contas_cadastradas --> Retorno XML contas cadastradas
                                       ,pr_dsretorn               OUT VARCHAR2); -- Descricao do erro


  /* Procedure para retornar finalidades da TED [consultados na CRAPTAB] */
  PROCEDURE pc_consulta_finalidades (pr_cdcooper IN crapcop.cdcooper%TYPE  -- Codigo Cooperativa
                                    ,pr_cdagenci IN crapage.cdagenci%TYPE  -- Agencia do Associado
                                    ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE  -- Numero caixa
                                    ,pr_cdcritic OUT INTEGER               -- Código do erro
                                    ,pr_dscritic OUT VARCHAR2              -- Descrição do erro
                                    ,pr_tab_finalidades OUT typ_tab_finalidades --> Retorno XML finalidades
                                    ,pr_dsretorn        OUT VARCHAR2);   --> Descricao do erro
    
  /*Procedure para validar reprovacao de transacoes pendentes de um operador*/
  PROCEDURE pc_verifica_limite_ope_prog (pr_cdcooper     IN crapcop.cdcooper%type  --C¿digo Cooperativa
                                        ,pr_nrdconta     IN crapass.nrdconta%TYPE  --Numero da conta
                                        ,pr_idseqttl     IN crapttl.idseqttl%TYPE  --Identificador Sequencial titulo
                                        ,pr_nrcpfope     IN crapopi.nrcpfope%TYPE  --Numero do CPF Operador
                                        ,pr_cdoperad     IN crapope.cdoperad%TYPE  --Codigo Operador
                                        ,pr_cddoitem     IN tbgen_trans_pend.cdtransacao_pendente%TYPE -- Cod da transação
                                        ,pr_dtmvtopg     IN crapdat.dtmvtolt%TYPE  --Data do proximo pagamento
                                        ,pr_dsorigem     IN craplau.dsorigem%TYPE  --Descricao Origem
                                        ,pr_msgretor     OUT VARCHAR2                    
                                        ,pr_cdcritic     OUT INTEGER        --Codigo do erro
                                        ,pr_dscritic     OUT VARCHAR2) ;
    
  /*Procedure para validar reprovacao de agendamento com um operador*/
  PROCEDURE pc_verifica_limite_ope_canc (pr_cdcooper     IN crapcop.cdcooper%type  --C¿digo Cooperativa
                                        ,pr_nrdconta     IN crapass.nrdconta%TYPE  --Numero da conta
                                        ,pr_idseqttl     IN crapttl.idseqttl%TYPE  --Identificador Sequencial titulo
                                        ,pr_nrcpfope     IN crapopi.nrcpfope%TYPE  --Numero do CPF Operador
                                        ,pr_cdoperad     IN crapope.cdoperad%TYPE  --Codigo Operador
                                        ,pr_vllanaut     IN NUMBER -- Valor da transacao
                                        ,pr_cdtiptra     IN NUMBER
                                        ,pr_dtmvtopg     IN crapdat.dtmvtolt%TYPE  --Data do proximo pagamento
                                        ,pr_dsorigem     IN craplau.dsorigem%TYPE  --Descricao Origem
                                        ,pr_msgretor     OUT VARCHAR2                    
                                        ,pr_cdcritic     OUT INTEGER        --Codigo do erro
                                        ,pr_dscritic     OUT VARCHAR2);                                                                       
                                    
  PROCEDURE pc_atu_trans_pend_prep (pr_cdcooper IN crapcop.cdcooper%TYPE   --Codigo Cooperativa
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE   --Numero conta
                                   ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE   --CPF/CGC
                                   ,pr_inpessoa IN crapass.inpessoa%TYPE   --Tipo de Pessoa
                                   ,pr_tpdsenha IN crapsnh.tpdsenha%TYPE   --Tipo de Senha
                                   ,pr_idastcjt IN crapass.idastcjt%TYPE   --Exige Ass.Conjunta Nao=0 Sim=1
                                   ,pr_cdcritic   OUT INTEGER              --Código do erro
                                   ,pr_dscritic   OUT VARCHAR2);
                                    
END INET0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.inet0001 AS

/*  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : INET0001
  --  Sistema  : Procedimentos para o debito de agendamentos feitos na Internet
  --  Sigla    : CRED
  --  Autor    : Alisson C. Berrido - Amcom
  --  Data     : Junho/2013.                   Ultima atualizacao: 12/04/2019
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
  --            
  --             06/05/2016 - Ajuste para validar o banco e agencia da conta destino em operações
  --			    	              de TED (Adriano - M117).
  --
  --		         10/05/2016 - Ajuste para retirar a criação do xml com as informações consultas. O 
  --						              xml será criado pela rotina origem (Adriano - M117).
  --
  --             13/05/2016 - Projeto 117 No procedimento pc_con_contas_cadastradas, passagem de upper() 
  --                          e trim() (campo nmtitula) para a consulta de crapcti diretamente na chamada 
  --                          do cursor (Carlos)
  --
  --             17/05/2016 - Ajuste na mensagem de retorno ao validar o saldo limite
  --                         (Adriano - M117).   
  --
  --             25/05/2016 - Ajuste realizados:
  --                         -> Alterado o index utilizado para montar a tabela de faovericos a fim de 
  --                             possibilitar a ordenação por nome de favorecido;
  --                         -> Utilizar rotina genérica para consultar registro da craptab;
  --                         -> Retirado variáveis não utilizadas;
  --                         --> Ajustado tamanhdo do index e tamanho do campo nmitutla na pltable
  --                          (Adriano - M117).
  --
  --             27/05/2016 - Correção do tamanho do campo nmtitul2 no type typ_reg_contas_cadastradas
  --                          para ficar do tamanho do campo crapass.nmsentl;
  --                         - Retirada a validação de existência de agência. (Carlos)
  --
  --			       31/05/2016 - Ajuste para colocar a validação de saldo disponível (Adriano).
  --
  --             18/07/2016 - Incluido pr_tpoperac = 11 -> DARF, Prj. 338, nas procedure
  --                         pc_horario_operacao, pc_busca_limites e pc_verifica_operacao
  --                        (Jean Michel).
  --
  --			       31/05/2016 - Ajuste para colocar a validação de saldo disponível (Adriano).
  --
  --             12/12/2016 - Ajuste realizados:
  --                          - Não realizar a validação de conta favorecida ativa
  --                          quando for efetivação de agendamentos de TED 
  --                          - Contabilizar corretamente o limite diário de TED
  --                          (Adriano - SD 563147 / 482831)
  --
	--             22/02/2017 - Ajuste retorno horário estourado pagamento DARF/DAS (Lucas Lunelli - P.349.2)
	--
  --            10/03/2017 - Ajustes na pc_verifica_operacao para liberar agendamento de TED 
  --                         para o ultimo dia util do ano (Tiago/Elton SD586106).
  --
  --            25/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
  --		                 crapass, crapttl, crapjur 
  --						(Adriano - P339).
  --
  --            26/12/2017 - Na pc_busca_limites foi inicializado as variaveis da pr_tab_internet e feito NVL 
  --                         nas variaveis que poderiam ter nulo pois estava possibilitando conta PJ sem limite para 
  --                         TED cadastrado realizar esta operação (Tiago #820218).
  --
  --            03/01/2018 - Na pc_verifica_operacao foi Corrigido para verificar saldo da conta mesmo quando 
  --                         for o operador realizando alguma transação (Tiago/Adriano).
  --
  --            03/01/2018 - Considerar apenas registros ativos para busca de limites na SNH
  --                         quando nao localizar registro para o 1 titular.
  --                         (Chamado 823977) - (Fabricio)
  --
  --            05/01/2018 - Na pc_verifica_operacao corrigdo acentuação na frase de critica agendamento 
  --                         e pagamento (Tiago #818723).
  --
  --            08/02/2018 - Criado a procedure pc_atu_trans_pend_prep que faz a atualização das transacoes
  --                         pendentes de aprovação por preposto de conta PJ sem ass conjunta (Tiago #775776).
  --
  --            19/03/2018 - Ajuste na pc_verifica_operacao para impedir agendamentos para data retroativa. (Pablão)
  --
                04/04/2018 - Ajustar para aparecer a critica 'Não é possível agendar para a data de hoje. 
                             Utilize a opção "Nesta Data".' somente quando não for aprovação de transação
                             pendente (Lucas Ranghetti #INC0011082)
  --            12/06/2018 - Ajuste nos tratamentos e na forma de atualizar os prepostos da rotina 
  --                         pc_atu_trans_pend_prep. (Wagner - Sustentação - #PRB0040080).
  --
  --            17/10/2018 - Atualizações referente ao projeto 475 - Sprint C
  --                         Jose Dill - Mouts

  				21/11/2018 - Incluído FlgAtivo nos cursores da crapcop para não permitir operações com cooperativas inativas
                             INC0027280 - Paulo Martins - Mouts
                             
                31/12/2018 - Ajuste para contornar validação do último dia 
                             útil do ano 
                             (Adriano - INC0030017).

				 08/01/2019 - Ajuste para desconsiderar contas favorecidas que pertecem a uma cooperativa inativa
			                 (Adriano - INC0029631).

	            12/04/2019 - Ajuste para remover a condição colocada no fim de ano para atender o ticket INC0030017
                            (Adriano -INC0012268 ).
  ---------------------------------------------------------------------------------------------------------------*/

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
     WHERE crapcop.cdcooper = pr_cdcooper
       AND crapcop.Flgativo = 1;
  rw_crapcop cr_crapcop%ROWTYPE;
  rw_crapcopgrade cr_crapcop%ROWTYPE; -- Projeto 475

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

  CURSOR cr_crapsnh_2 (pr_cdcooper IN crapsnh.cdcooper%type
                      ,pr_nrdconta IN crapsnh.nrdconta%type
                      ,pr_tpdsenha IN crapsnh.tpdsenha%type) IS
      SELECT distinct
             crapsnh.vllimweb
            ,crapsnh.vllimpgo
            ,crapsnh.vllimtrf
            ,crapsnh.vllimted
            ,crapsnh.vllimvrb
      FROM crapsnh
      WHERE crapsnh.cdcooper = pr_cdcooper
      AND   crapsnh.nrdconta = pr_nrdconta
      AND   crapsnh.tpdsenha = pr_tpdsenha
      AND   crapsnh.cdsitsnh = 1 /*ativo*/ ;
  rw_crapsnh_2 cr_crapsnh_2%ROWTYPE;      
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

  /* Procedure para verificar horario permitido para transacoes*/
  PROCEDURE pc_horario_operacao (pr_cdcooper IN crapcop.cdcooper%TYPE      --C¿digo Cooperativa
                                ,pr_cdagenci IN crapage.cdagenci%type      --Agencia do Associado
                                ,pr_tpoperac IN INTEGER                    --Tipo de Operacao (0=todos)
                                ,pr_inpessoa IN crapass.inpessoa%type      --Tipo de Pessoa
                                ,pr_idagenda IN INTEGER                    --Tipo de agendamento
                                ,pr_cdtiptra IN INTEGER                    --Tipo de transferencia
                                ,pr_tab_limite OUT INET0001.typ_tab_limite --Tabelas de retorno de horarios limite
                                ,pr_cdcritic   OUT INTEGER                 --Código do erro
                                ,pr_dscritic   OUT VARCHAR2) IS            --Descricao do erro
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_horario_operacao           Antigo: b1wgen0015.p/horario_operacao
  --  Sistema  : Procedimentos para o debito de agendamentos feitos na Internet
  --  Sigla    : CRED
  --  Autor    : Alisson C. Berrido - Amcom
  --  Data     : Junho/2013.                   Ultima atualizacao: 12/04/2019
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
  --
  --             18/07/2016 - Incluido pr_tpoperac = 10 -> DARF, Prj. 338 (Jean Michel).
  --
  --			 21/09/2016 - Ajuste na validacao do horario para envio de TED (Diego).	  
  --             
  --             25/10/2016 - Novo ajuste na validacao do horario, solicitado pelo financeiro (Diego).         
  --
  --             26/12/2017 - Incluido validacao de horario FGTS/DAE. PRJ406 - FGTS (Odirlei-AMcom)   
  --
  --             12/04/2019 - Ajuste para remover a condição colocada no fim de ano para atender o ticket INC0030017
  --                         (Adriano -INC0012268 ).
  ----------------------------------------- ----------------------------------------------------------------------
  BEGIN
    DECLARE

      --Cursores
      CURSOR cr_hrcancel IS
      SELECT age.hrcancel
            ,age.dsdemail
        FROM crapage age
       WHERE age.cdcooper = pr_cdcooper
         AND age.cdagenci = pr_cdagenci;

      --Variaveis Locais
      vr_flsgproc BOOLEAN;
      vr_hrinipag INTEGER;
      vr_hrfimpag INTEGER;
      vr_hrcancel INTEGER;
      vr_dsdemail crapage.dsdemail%TYPE;
      vr_qtmesagd INTEGER;
      vr_qtmesfut INTEGER;
      vr_qtmesrec INTEGER;
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
      vr_index_limite_aux INTEGER;
      -- Tipo de pessoa para buscar o horario limite
      vr_inpessoa INTEGER;
      vr_inestcri INTEGER;
      vr_clobxmlc CLOB;
      vr_flgutstr BOOLEAN; 
      vr_flgutpag BOOLEAN;
      vr_hrlimtrf crapprm.dsvlrprm%TYPE; --Transf no dia (tipo Crédito Salário);
    BEGIN

      --Inicializar varaivel retorno erro
      vr_cdcritic:= NULL;
      vr_dscritic:= NULL;

      --Limpar tabela memoria
      pr_tab_limite.DELETE;

	  /** Horario diferenciado para finais de semana e feriados **/
      vr_datdodia:= PAGA0001.fn_busca_datdodia(pr_cdcooper => pr_cdcooper);

      -- Se for para todos ou for ted ou for vr-boleto
      IF pr_tpoperac IN (0,4,6)  THEN
        -- Busca o indicador estado de crise
        SSPB0001.pc_estado_crise (pr_inestcri => vr_inestcri
                                 ,pr_clobxmlc => vr_clobxmlc);

        -- Se estiver setado como estado de crise
        IF  vr_inestcri > 0  THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Sistema temporariamente indisponivel para a realizacao da transacao.'||chr(10)||
                           'Por favor, tente novamente mais tarde.'; -- Marcelo Telles Coelho - Projeto 475 - SPRINT B
                        -- 'Sistema indisponivel no momento. Tente mais tarde!';
            RAISE vr_exc_erro;
        END IF;
      END IF;

      --Se o tipo de operacao for Todos (0), Transferencia(1) ou Pagamento(2) ou (5) Intercooperativa
      IF pr_tpoperac IN (0,1,2,4,5)  THEN
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
          vr_qtmesagd := To_Number(gene0002.fn_busca_entrada(5,vr_dstextab,';'));          
          vr_qtmesfut := To_Number(gene0002.fn_busca_entrada(31,vr_dstextab,';')); -- mesested
          vr_qtmesrec := To_Number(gene0002.fn_busca_entrada(33,vr_dstextab,';')); -- mrecoted          
        END IF;
      END IF;

      --Se o tipo de operacao for DARF/DAS
      IF pr_tpoperac IN (0,10)  THEN
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
                                                ,pr_cdacesso => 'HRPGSICRED'
                                                ,pr_tpregist => pr_cdagenci);

        --Se nao encontrou
        IF vr_dstextab IS NULL THEN
          vr_cdcritic:= 0;
          vr_dscritic := 'Tabela (HRPGSICRED) nao cadastrada.';
          --Levantar Excecao
          RAISE vr_exc_erro;
        ELSE
          --Hora de inicio
          vr_hrinipag:= GENE0002.fn_busca_entrada(1,vr_dstextab,' ');
          --Hora Fim
          vr_hrfimpag:= GENE0002.fn_busca_entrada(2,vr_dstextab,' ');
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

        --Se for feriado ou final semana
        IF Trunc(vr_datdodia) <> Trunc(SYSDATE) THEN
          --Nao eh dia util
          vr_iddiauti:= 2;
        ELSE
          vr_iddiauti:= 1;
        END IF;

        --Criar registro para tabela limite horarios
        vr_index_limite:= pr_tab_limite.Count+1;
        pr_tab_limite(vr_index_limite).hrinipag:= GENE0002.fn_converte_time_data(vr_hrinipag);
        pr_tab_limite(vr_index_limite).hrfimpag:= GENE0002.fn_converte_time_data(vr_hrfimpag);
        pr_tab_limite(vr_index_limite).nrhorini:= vr_hrinipag;
        pr_tab_limite(vr_index_limite).nrhorfim:= vr_hrfimpag;
        pr_tab_limite(vr_index_limite).idesthor:= vr_idesthor;
        pr_tab_limite(vr_index_limite).iddiauti:= vr_iddiauti;
        pr_tab_limite(vr_index_limite).flsgproc:= vr_flsgproc;
        pr_tab_limite(vr_index_limite).qtmesagd:= vr_qtmesagd;
        pr_tab_limite(vr_index_limite).idtpdpag:= 15;
      END IF;      

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
          --Determinar se é segundo processo
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

          IF pr_idagenda = 1  AND  /* pagto dia corrente */
             pr_tpoperac = 1  AND  /* Transferencia */
             pr_cdtiptra = 3  AND  /* Credito Salario */
             pr_cdagenci = 90 THEN /* Internet */
             
            vr_hrlimtrf := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                    ,pr_cdcooper => pr_cdcooper
                                                    ,pr_cdacesso => 'FOLHAIB_HR_LIM_TRF_TPSAL');
                    
            vr_hrfimpag := to_number(to_char(to_date(vr_hrlimtrf,'hh24:mi'),'SSSSS'));
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
                                                   ,pr_tipo     => 'P'
                                                   ,pr_feriado => true -- Não executa no feriado
                                                   ,pr_excultdia => true); -- Executa no último dia do ano
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

          OPEN cr_hrcancel;
          FETCH cr_hrcancel
          INTO vr_hrcancel, vr_dsdemail;
          CLOSE cr_hrcancel;

          --Criar registro para tabela limite horarios
          vr_index_limite:= pr_tab_limite.Count+1;
          pr_tab_limite(vr_index_limite).hrinipag:= GENE0002.fn_converte_time_data(vr_hrinipag);
          pr_tab_limite(vr_index_limite).hrfimpag:= GENE0002.fn_converte_time_data(vr_hrfimpag);
          pr_tab_limite(vr_index_limite).hrcancel:= GENE0002.fn_converte_time_data(vr_hrcancel);
          pr_tab_limite(vr_index_limite).nrhorini:= vr_hrinipag;
          pr_tab_limite(vr_index_limite).nrhorfim:= vr_hrfimpag;
          pr_tab_limite(vr_index_limite).nrhrcanc:= vr_hrcancel;
          pr_tab_limite(vr_index_limite).idesthor:= vr_idesthor;
          pr_tab_limite(vr_index_limite).iddiauti:= NULL;
          pr_tab_limite(vr_index_limite).flsgproc:= vr_flsgproc;
          pr_tab_limite(vr_index_limite).qtmesagd:= vr_qtmesagd;
          pr_tab_limite(vr_index_limite).qtmesfut:= vr_qtmesfut;
          pr_tab_limite(vr_index_limite).qtmesrec:= vr_qtmesrec;
          pr_tab_limite(vr_index_limite).idtpdpag:= 2;
          pr_tab_limite(vr_index_limite).dsdemail:= vr_dsdemail;
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
            
            /*****
            Por solicitacao do financeiro, iremos apenas verificar se a cooperativa esta operante
            no STR/PAG, sem a necessidade de verificar o horario de operacao. Devera prevalecer o 
            horario da STR, e somente quando este nao estiver ATIVO mostrara horario da PAG.
            Por regra, o STR sempre terá um período maior    
            *****/
            
            --Operando com mensagens STR
            IF rw_crapcop.flgopstr = 1 THEN -- TRUE
               vr_hrinipag := rw_crapcop.iniopstr;
               vr_hrfimpag := rw_crapcop.fimopstr; 
         
               /**
               IF rw_crapcop.iniopstr <= vr_hratual AND rw_crapcop.fimopstr >= vr_hratual THEN
                  vr_flgutstr := TRUE; -- Esta dentro do horario cadastrado para STR
               END IF;
               **/
            ELSE
                 -- Operando com mensagens PAG  
                 IF rw_crapcop.flgoppag = 1 THEN -- TRUE
                    vr_hrinipag := rw_crapcop.inioppag;
                    vr_hrfimpag := rw_crapcop.fimoppag;
         
                  /**
                  IF rw_crapcop.inioppag <= vr_hratual AND rw_crapcop.fimoppag >= vr_hratual THEN
                     vr_flgutpag := TRUE; -- Esta dentro do horario cadastrado para PAG 
                  END IF;
                  **/
                  END IF;
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
            /* Projeto 475 Sprint C (Req14) - Tratamento para permitir agendar uma TED antes da abertura da sua grade 
               Permite ou não habilitar o campo data atual no IB (vr_idesthor) */
            IF vr_iddiauti = 1 THEN
              -- Faz a validação somente para dias úteis              
              IF vr_hratual < vr_hrinipag 
                 and pr_tpoperac = 4 THEN
                 -- Dentro do limite (antes da abertura da grade)
                vr_idesthor:= 2;              
              END IF; 
            END IF;
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
          pr_tab_limite(vr_index_limite).qtmesagd:= vr_qtmesagd;
          pr_tab_limite(vr_index_limite).qtmesrec:= vr_qtmesrec;
          pr_tab_limite(vr_index_limite).qtmesfut:= vr_qtmesfut;          
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
      
      --Se o tipo de operacao for FGTS/DAE
      IF pr_tpoperac IN (0,12,13)  THEN
      
        --Determinar tipo pessoa para busca limite
        IF pr_inpessoa > 1 THEN
          vr_inpessoa:= 2;
        ELSE
          vr_inpessoa:= pr_inpessoa;
        END IF;   

        OPEN cr_hrcancel;
        FETCH cr_hrcancel
        INTO vr_hrcancel, vr_dsdemail;
        CLOSE cr_hrcancel;
        
        --Limpar variável pois o horário limite de estorno será obitdo na craptab
        vr_hrcancel := NULL;

        --Selecionar Horarios Limites Internet
        vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                ,pr_nmsistem => 'CRED'
                                                ,pr_tptabela => 'GENERI'
                                                ,pr_cdempres => 0
                                                ,pr_cdacesso => 'HRPGBANCOOB'
                                                ,pr_tpregist => pr_cdagenci);

        --Se nao encontrou
        IF vr_dstextab IS NULL THEN
          vr_cdcritic:= 0;
          vr_dscritic := 'Tabela (HRPGBANCOOB) nao cadastrada.';
          --Levantar Excecao
          RAISE vr_exc_erro;
        ELSE
          --Hora de inicio
          vr_hrinipag:= GENE0002.fn_busca_entrada(1,vr_dstextab,' ');
          --Hora Fim
          vr_hrfimpag:= GENE0002.fn_busca_entrada(2,vr_dstextab,' ');
          --Hora Estorno
          vr_hrcancel:= GENE0002.fn_busca_entrada(3,vr_dstextab,' ');
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

        --Se for feriado ou final semana
        IF Trunc(vr_datdodia) <> Trunc(SYSDATE) THEN
          --Nao eh dia util
          vr_iddiauti:= 2;
        ELSE
          vr_iddiauti:= 1;
        END IF;

        
        --Criar registro para tabela limite horarios
        vr_index_limite:= pr_tab_limite.Count+1;
        pr_tab_limite(vr_index_limite).hrinipag:= GENE0002.fn_converte_time_data(vr_hrinipag);
        pr_tab_limite(vr_index_limite).hrfimpag:= GENE0002.fn_converte_time_data(vr_hrfimpag);
        pr_tab_limite(vr_index_limite).hrcancel:= GENE0002.fn_converte_time_data(vr_hrcancel);
        pr_tab_limite(vr_index_limite).nrhorini:= vr_hrinipag;
        pr_tab_limite(vr_index_limite).nrhorfim:= vr_hrfimpag;
        pr_tab_limite(vr_index_limite).idesthor:= vr_idesthor;
        pr_tab_limite(vr_index_limite).iddiauti:= vr_iddiauti;
        pr_tab_limite(vr_index_limite).flsgproc:= vr_flsgproc;
        pr_tab_limite(vr_index_limite).qtmesagd:= vr_qtmesagd;
        pr_tab_limite(vr_index_limite).dsdemail:= vr_dsdemail;
        
        --> Caso for todos, replicar dados para ambos
        IF pr_tpoperac = 0 THEN
          pr_tab_limite(vr_index_limite).idtpdpag:= 20; --FGTS
          
          vr_index_limite_aux := pr_tab_limite.Count+1;
          pr_tab_limite(vr_index_limite_aux) := pr_tab_limite(vr_index_limite);
          pr_tab_limite(vr_index_limite_aux).idtpdpag:= 21; --DAE
          
        -- senao apenas atribuir identificador relativo ao tipo de ope
        ELSE

          pr_tab_limite(vr_index_limite).idtpdpag:= CASE pr_tpoperac 
                                                         WHEN 12 THEN 20 -- FGTS
                                                         WHEN 13 THEN 21 -- DAE
                                                         ELSE NULL
                                                       END;
        
        END IF;
      END IF;
      
      
    EXCEPTION
       WHEN vr_exc_erro THEN
         pr_cdcritic:= vr_cdcritic;
         pr_dscritic:= vr_dscritic;
       WHEN OTHERS THEN
         btch0001.pc_log_internal_exception(pr_cdcooper);
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro na rotina INET0001.pc_horario_operacao. '||SQLERRM;
    END;
  END pc_horario_operacao;

/** Chamada para ser utilizada no Progress - 
      Procedure para validar limites para transacoes (Transf./Pag./Cob.) **/
  PROCEDURE pc_horario_operacao_prog (pr_cdcooper IN crapcop.cdcooper%TYPE        --C¿digo Cooperativa
                                     ,pr_cdagenci IN crapage.cdagenci%type        --Agencia do Associado
                                     ,pr_tpoperac IN INTEGER                      --Tipo de Operacao (0=todos)
                                     ,pr_inpessoa IN crapass.inpessoa%type        --Tipo de Pessoa
                                     ,pr_tab_limite OUT CLOB        --XML de retorno de horarios limite
                                     ,pr_cdcritic   OUT INTEGER     --Código do erro
                                     ,pr_dscritic   OUT VARCHAR2) IS --Descricao do erro
  BEGIN
  DECLARE
    -------------------------> VARIAVEIS <-------------------------
    vr_tab_limite INET0001.typ_tab_limite;
    vr_aux_flsgproc INTEGER;
    -- Variaveis de XML 
    vr_xml_temp VARCHAR2(32767);
    
    BEGIN
      pc_horario_operacao(
                pr_cdcooper => pr_cdcooper,
                pr_cdagenci => pr_cdagenci, 
                pr_tpoperac => pr_tpoperac, 
                pr_inpessoa => pr_inpessoa, 
                pr_idagenda => 0,
                pr_cdtiptra => 0, 
                pr_tab_limite => vr_tab_limite, 
                pr_cdcritic => pr_cdcritic, 
                pr_dscritic => pr_dscritic);        
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
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><root>'); 

      FOR vr_contador IN nvl(vr_tab_limite.FIRST,0)..nvl(vr_tab_limite.LAST,-1) LOOP        
        
        IF vr_tab_limite(vr_contador).flsgproc THEN
          vr_aux_flsgproc := 1;
        ELSE
          vr_aux_flsgproc := 0;
        END IF;
      
        -- Montar XML com registros de carencia        
        gene0002.pc_escreve_xml(pr_xml            => pr_tab_limite 
                               ,pr_texto_completo => vr_xml_temp 
                               ,pr_texto_novo     => '<horario>' 
                                                  ||   '<hrinipag>'||vr_tab_limite(vr_contador).hrinipag    ||'</hrinipag>'
                                                  ||   '<hrfimpag>'||vr_tab_limite(vr_contador).hrfimpag    ||'</hrfimpag>'
                                                  ||   '<hrcancel>'||vr_tab_limite(vr_contador).hrcancel    ||'</hrcancel>'
                                                  ||   '<nrhorini>'||to_char(vr_tab_limite(vr_contador).nrhorini)  ||'</nrhorini>'
                                                  ||   '<nrhorfim>'||to_char(vr_tab_limite(vr_contador).nrhorfim)  ||'</nrhorfim>'
                                                  ||   '<idesthor>'||to_char(vr_tab_limite(vr_contador).idesthor)  ||'</idesthor>'
                                                  ||   '<iddiauti>'||to_char(vr_tab_limite(vr_contador).iddiauti)  ||'</iddiauti>'
                                                  ||   '<flsgproc>'|| vr_aux_flsgproc ||'</flsgproc>'
                                                  ||   '<qtmesagd>'||to_char(vr_tab_limite(vr_contador).qtmesagd)  ||'</qtmesagd>'
                                                  ||   '<idtpdpag>'||to_char(vr_tab_limite(vr_contador).idtpdpag)  ||'</idtpdpag>'
                                                  ||   '<emailest_pag>'||vr_tab_limite(vr_contador).dsdemail||'</emailest_pag>'
                                                  || '</horario>');
      END LOOP;
         
      -- Encerrar a tag raiz 
      gene0002.pc_escreve_xml(pr_xml            => pr_tab_limite 
                             ,pr_texto_completo => vr_xml_temp 
                             ,pr_texto_novo     => '</root>' 
                             ,pr_fecha_xml      => TRUE);
      
      
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Não foi possivel verificar horarios: '|| SQLERRM;    
    END;
  END pc_horario_operacao_prog;
  --
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
  --  Data     : Junho/2013.                   Ultima atualizacao: 03/01/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para buscar os limites da internet
  
  -- Atualizacao: 09/12/2014 - Ajustado IF do LOOP leitura cr_craplau (Daniel)             

  --              11/05/2016 - Ajuste para fechar o cursor corretamente (Adriano - M117).      

  --              18/07/2016 - Incluido pr_tpoperac = 10 -> DARF, Prj. 338 (Jean Michel).

  --              14/12/2016 - Contabilizar corretamente o limite diário de TED
  --                           (Adriano - SD 482831)
  --
  --              26/12/2017 - Inicializado as variaveis da pr_tab_internet e feito NVL nas variaveis
  --                           que poderiam ter nulo pois estava possibilitando conta PJ sem limite para 
  --                           TED cadastrado realizar esta operação (Tiago #820218).
  --
  --              03/01/2018 - Considerar apenas registros ativos para busca de limites na SNH
  --                           quando nao localizar registro para o 1 titular.
  --                           (Chamado 823977) - (Fabricio)
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
      --        
      CURSOR cr_crapemp (prc_cdcooper IN craplau.cdcooper%type
                        ,prc_nrdconta IN craplau.nrdconta%type) IS
          select c.vllimfol
            from crapemp c 
           where c.nrdconta = prc_nrdconta
             and c.cdcooper = prc_cdcooper;  

      CURSOR cr_crappfp (pr_cdcooper IN craplau.cdcooper%type
                        ,pr_nrdconta IN craplau.nrdconta%type
                        ,pr_dtmvtopg IN craplau.dtmvtopg%type) IS
                        
        SELECT nvl(sum(pfp.VLLCTPAG),0) vllctpag
           FROM crapemp emp
              , crappfp pfp
              , crapass ass
          WHERE emp.cdcooper = pfp.cdcooper
            AND emp.cdempres = pfp.cdempres
            AND pfp.cdcooper = pr_cdcooper
            AND emp.nrdconta = pr_nrdconta
            AND (TRUNC(pfp.dtmvtolt) = pr_dtmvtopg OR
                 TRUNC(pfp.dtcredit) = pr_dtmvtopg OR
                 TRUNC(pfp.dtdebito) = pr_dtmvtopg OR
                 TRUNC(pfp.dthorcre) = pr_dtmvtopg OR
                 TRUNC(pfp.dthordeb) = pr_dtmvtopg)
            AND ass.cdcooper = emp.cdcooper
            AND ass.nrdconta = emp.nrdconta
            AND pfp.idsitapr in (5,6) -- Aprovada
            ;                    

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
      vr_vlutlflp     NUMBER;
      vr_vllimfol     NUMBER;
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
        --Fechar Cursor
        CLOSE cr_crapsnh;
        -- Busca sem preposto
        OPEN cr_crapsnh_2 (pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_tpdsenha => 1);
        --Posicionar no proximo registro
        FETCH cr_crapsnh_2 INTO rw_crapsnh_2;
        --Se nao encontrar
        IF cr_crapsnh_2%NOTFOUND THEN
          --Fechar Cursor          
          CLOSE cr_crapsnh_2;
        pr_cdcritic:= 0;
          pr_dscritic:= 'Não encontrou limites para a conta.';
        --Limite Web
        vr_vllimweb:= 0;
        --Limite Pagamento
        vr_vllimpgo:= 0;
        --Limite Transferencia
        vr_vllimtrf:= 0;
        --Limite TED
        vr_vllimted:= 0;
      ELSE
        --Fechar Cursor
          CLOSE cr_crapsnh_2;

          --Limite Web
          vr_vllimweb:= rw_crapsnh_2.vllimweb;
          --Limite Pagamento
          vr_vllimpgo:= rw_crapsnh_2.vllimpgo;
          --Limite Transferencia
          vr_vllimtrf:= rw_crapsnh_2.vllimtrf;
          --Limite TED
          vr_vllimted:= rw_crapsnh_2.vllimted;
        END IF;
       
      ELSE

	    --Fechar Cursor
        CLOSE cr_crapsnh;

        --Limite Web
        vr_vllimweb:= rw_crapsnh.vllimweb;
        --Limite Pagamento
        vr_vllimpgo:= rw_crapsnh.vllimpgo;
        --Limite Transferencia
        vr_vllimtrf:= rw_crapsnh.vllimtrf;
        --Limite TED
        vr_vllimted:= rw_crapsnh.vllimted;
      END IF;

      --Criar registro limite internet
      vr_index:= pr_idseqttl; --nvl(rw_crapsnh.idseqttl,pr_idseqttl);
      
      pr_tab_internet(vr_index).idseqttl:= rw_crapsnh.idseqttl;
      pr_tab_internet(vr_index).vlwebcop:= NVL(vr_tab_vllimweb,0);
      pr_tab_internet(vr_index).vlpgocop:= NVL(vr_tab_vllimpgo,0);
      pr_tab_internet(vr_index).vltrfcop:= NVL(vr_tab_vllimtrf,0);
      pr_tab_internet(vr_index).vltedcop:= NVL(vr_tab_vllimted,0);
      pr_tab_internet(vr_index).vllimweb:= NVL(vr_vllimweb,0);
      pr_tab_internet(vr_index).vllimpgo:= NVL(vr_vllimpgo,0);
      pr_tab_internet(vr_index).vllimtrf:= NVL(vr_vllimtrf,0);
      pr_tab_internet(vr_index).vllimted:= NVL(vr_vllimted,0);
      pr_tab_internet(vr_index).vlvrbcop:= NVL(vr_tab_vllimvrb,0);
		  pr_tab_internet(vr_index).vllimvrb:= NVL(rw_crapsnh.vllimvrb,0);
      pr_tab_internet(vr_index).vllimflp:= 0;
           /* Limite utilizado */
      pr_tab_internet(vr_index).vlutlweb:= 0;
      pr_tab_internet(vr_index).vlutlpgo:= 0;
      pr_tab_internet(vr_index).vlutltrf:= 0;
      pr_tab_internet(vr_index).vlutlted:= 0;
      pr_tab_internet(vr_index).vlutlvrb:= 0;
      pr_tab_internet(vr_index).vlutlflp:= 0;
           /* Limite disponivel */
      pr_tab_internet(vr_index).vldspweb:= 0;
      pr_tab_internet(vr_index).vldsppgo:= 0;
      pr_tab_internet(vr_index).vldsptrf:= 0;
      pr_tab_internet(vr_index).vldspted:= 0;
      pr_tab_internet(vr_index).vldspvrb:= 0;
      pr_tab_internet(vr_index).vldspflp:= 0;

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
        pr_tab_internet(vr_index).vlwebcop:= NVL(vr_tab_vllimweb,0);
        pr_tab_internet(vr_index).vlpgocop:= NVL(vr_tab_vllimpgo,0);
        pr_tab_internet(vr_index).vltrfcop:= NVL(vr_tab_vllimtrf,0);
        pr_tab_internet(vr_index).vltedcop:= NVL(vr_tab_vllimted,0);
        pr_tab_internet(vr_index).vllimweb:= NVL(vr_vllimweb,0);
        pr_tab_internet(vr_index).vllimpgo:= NVL(vr_vllimpgo,0);
        pr_tab_internet(vr_index).vllimtrf:= NVL(vr_vllimtrf,0);
        pr_tab_internet(vr_index).vllimted:= NVL(vr_vllimted,0);
        pr_tab_internet(vr_index).vlvrbcop:= NVL(vr_tab_vllimvrb,0);
  		  pr_tab_internet(vr_index).vllimvrb:= NVL(rw_crapsnh.vllimvrb,0);
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
            ELSIF rw_craplau.cdtiptra IN (2,10)  THEN
              --Acumular valor utilizado pagamentos
              vr_vlutlpgo:= vr_vlutlpgo + Nvl(rw_craplau.vllanaut,0);
            END IF;
            
            --Acumula valor de TED já agendadas
            IF rw_craplau.cdtiptra = 4 THEN
              
              vr_vlutlted := vr_vlutlted + Nvl(rw_craplau.vllanaut,0);
                
            END IF;
            
          END LOOP;
          
        END IF;  
       
        vr_vllimfol := 0;
        vr_vlutlflp := 0;
        
        FOR rw_crapemp IN cr_crapemp(pr_cdcooper,
                                     pr_nrdconta) LOOP
          vr_vllimfol := rw_crapemp.vllimfol;
        END LOOP;
        -- Buscar valores de pagamentos para o tipo folha de pagamento
        FOR rw_crappfp IN cr_crappfp(pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_dtmvtopg => pr_dtmvtopg) LOOP
            
          vr_vlutlflp := rw_crappfp.vllctpag;
        END LOOP;
       
          vr_index:= pr_idseqttl;
        
          --Se existir valor limite web
          IF  pr_tab_internet.EXISTS(vr_index) AND pr_tab_internet(vr_index).vllimweb > 0  THEN
            --Valor utilizado WEB
            pr_tab_internet(vr_index).vlutlweb:= NVL(vr_vlutlweb,0);
            --Valor disponivel WEB recebe limite menos utilizado web
            pr_tab_internet(vr_index).vldspweb:= NVL(pr_tab_internet(vr_index).vllimweb,0) - NVL(vr_vlutlweb,0);
          END IF;
        
          --Se existir valor limite transferencia
          IF  pr_tab_internet.EXISTS(vr_index) AND pr_tab_internet(vr_index).vllimtrf > 0  THEN
            --Valor utilizado transferencia
            pr_tab_internet(vr_index).vlutltrf:= NVL(vr_vlutltrf,0);
            --Valor disponivel transf. recebe limite menos utilizado transf
            pr_tab_internet(vr_index).vldsptrf:= NVL(pr_tab_internet(vr_index).vllimtrf,0) - NVL(vr_vlutltrf,0);
          END IF;
        
          --Se existir valor limite pagto
          IF  pr_tab_internet.EXISTS(vr_index) AND pr_tab_internet(vr_index).vllimpgo > 0  THEN
            --Valor utilizado pagto
            pr_tab_internet(vr_index).vlutlpgo:= NVL(vr_vlutlpgo,0);
            --Valor disponivel pagto. recebe limite menos utilizado pagto
            pr_tab_internet(vr_index).vldsppgo:= NVL(pr_tab_internet(vr_index).vllimpgo,0) - NVL(vr_vlutlpgo,0);
          END IF;
        
          --Se existir valor limite ted
          IF  pr_tab_internet.EXISTS(vr_index) AND pr_tab_internet(vr_index).vllimted > 0  THEN
            --Valor utilizado ted
            pr_tab_internet(vr_index).vlutlted:= NVL(vr_vlutlted,0);
            --Valor disponivel ted. recebe limite menos utilizado ted
            pr_tab_internet(vr_index).vldspted:= NVL(pr_tab_internet(vr_index).vllimted,0) - NVL(vr_vlutlted,0);
          END IF;

          pr_tab_internet(vr_index).vlutlflp := 0;
          pr_tab_internet(vr_index).vldspflp := 0;
           --Se existir valor limite Folha de pagamento
          IF  vr_vllimfol > 0  THEN
            --Valor utilizado Folha de Pagamento
            pr_tab_internet(vr_index).vlutlflp:= NVL(vr_vlutlflp,0);
            --Valor disponivel folha de pagamento
            pr_tab_internet(vr_index).vldspflp:= NVL(vr_vllimfol,0) - NVL(vr_vlutlflp,0);
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
                ELSIF rw_craplau.cdtiptra IN (2,10)  THEN
                  --Acumular valor utilizado pagamentos
                  vr_vlutlpgo:= vr_vlutlpgo + Nvl(rw_craplau.vllanaut,0);
                END IF;
                
              --Acumula valor de TED já agendadas
              IF rw_craplau.cdtiptra = 4 THEN
                  
                vr_vlutlted := vr_vlutlted + Nvl(rw_craplau.vllanaut,0);
                    
              END IF;
            
              END LOOP;

              vr_index:= 1;
            
              --Se existir valor limite web
              IF  pr_tab_internet.EXISTS(vr_index) AND pr_tab_internet(vr_index).vllimweb > 0  THEN
                --Valor utilizado WEB
                pr_tab_internet(vr_index).vlutlweb:= vr_vlutlweb;
                --Valor disponivel WEB recebe limite menos utilizado web
                pr_tab_internet(vr_index).vldspweb:= NVL(pr_tab_internet(vr_index).vllimweb,0) - vr_vlutlweb;
              END IF;
            
              --Se existir valor limite transferencia
              IF  pr_tab_internet.EXISTS(vr_index) AND pr_tab_internet(vr_index).vllimtrf > 0  THEN
                --Valor utilizado transferencia
                pr_tab_internet(vr_index).vlutltrf:= vr_vlutltrf;
                --Valor disponivel transf. recebe limite menos utilizado transf
                pr_tab_internet(vr_index).vldsptrf:= NVL(pr_tab_internet(vr_index).vllimtrf,0) - vr_vlutltrf;
              END IF;
            
              --Se existir valor limite pagto
              IF  pr_tab_internet.EXISTS(vr_index) AND pr_tab_internet(vr_index).vllimpgo > 0  THEN
                --Valor utilizado pagto
                pr_tab_internet(vr_index).vlutlpgo:= vr_vlutlpgo;
                --Valor disponivel pagto. recebe limite menos utilizado pagto
                pr_tab_internet(vr_index).vldsppgo:= NVL(pr_tab_internet(vr_index).vllimpgo,0) - vr_vlutlpgo;
              END IF;
            
              --Se existir valor limite ted
              IF  pr_tab_internet.EXISTS(vr_index) AND pr_tab_internet(vr_index).vllimted > 0  THEN
                --Valor utilizado ted
                pr_tab_internet(vr_index).vlutlted:= vr_vlutlted;
                --Valor disponivel ted. recebe limite menos utilizado ted
                pr_tab_internet(vr_index).vldspted:= NVL(pr_tab_internet(vr_index).vllimted,0) - vr_vlutlted;
              END IF;
            
              --Verificar os limites disponiveis web
              IF pr_tab_internet(pr_idseqttl).vldspweb > pr_tab_internet(1).vldspweb THEN
                 --Atualizar valor disponivel web
                 pr_tab_internet(pr_idseqttl).vldspweb:= NVL(pr_tab_internet(1).vldspweb,0);
              END IF;
            
              --Verificar os limites disponiveis transferencia
              IF pr_tab_internet(pr_idseqttl).vldsptrf > pr_tab_internet(1).vldsptrf THEN
                 --Atualizar valor disponivel transferencia
                 pr_tab_internet(pr_idseqttl).vldsptrf:= NVL(pr_tab_internet(1).vldsptrf,0);
              END IF;
            
              --Verificar os limites disponiveis pagamento
              IF pr_tab_internet(pr_idseqttl).vldsppgo > pr_tab_internet(1).vldsppgo THEN
                 --Atualizar valor disponivel pagamento
                 pr_tab_internet(pr_idseqttl).vldsppgo:= NVL(pr_tab_internet(1).vldsppgo,0);
              END IF;
            
              --Verificar os limites disponiveis ted
              IF pr_tab_internet(pr_idseqttl).vldspted > pr_tab_internet(1).vldspted THEN
                 --Atualizar valor disponivel ted
                 pr_tab_internet(pr_idseqttl).vldspted:= NVL(pr_tab_internet(1).vldspted,0);
              END IF;

            END IF;
          END IF;
       
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
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa : pc_valida_conta_destino           Antigo: b1wgen0015.p/valida-conta-destino
    Sistema  : Procedimentos para validar conta de destino da transferencia
    Sigla    : CRED
    Autor    : Alisson C. Berrido - Amcom
    Data     : Junho/2013.                   Ultima atualizacao: 25/04/2017
  
   Dados referentes ao programa:
  
   Frequencia: -----
   Objetivo  : Procedimentos para validar conta de destino da transferencia
  
   Alterações: 28/07/2015 - Ajustar o tratamento de erros para quando executar o raise o erro seja
                            carregado na tabela de erros e devolvida a rotina que chamou.
                            (Douglas - Chamado 312756)
  
               24/05/2016 - M118 - Correção na checagem de existência da CRAPCTI (Marcos-Supero)

			   25/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
		                    crapass, crapttl, crapjur 
							(Adriano - P339).
   
  ---------------------------------------------------------------------------------------------------------------*/

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

	  CURSOR cr_crapttl (pr_cdcooper IN crapttl.cdcooper%TYPE,
                         pr_nrdconta IN crapttl.nrdconta%TYPE) IS
      SELECT nmextttl
        FROM crapttl
       WHERE crapttl.cdcooper = pr_cdcooper
         AND crapttl.nrdconta = pr_nrdconta
         AND crapttl.idseqttl = 2;
      rw_crapttl cr_crapttl%ROWTYPE;

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
                      ,pr_cddbanco => rw_crabcop.cdbcoctl
                      ,pr_cdageban => rw_crabcop.cdagectl
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

	  OPEN cr_crapttl(pr_cdcooper => rw_crabass.cdcooper
	                 ,pr_nrdconta => rw_crabass.nrdconta);

	  FETCH cr_crapttl INTO rw_crapttl;

	  IF cr_crapttl%FOUND THEN

      --Nome do segundo titular
        pr_nmtitul2:= rw_crapttl.nmextttl;

	  END IF;

	  CLOSE cr_crapttl;

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
  --
  /* Buscar limites de transacao do preposto*/                              
  PROCEDURE pc_busca_limites_prepo_trans(pr_cdcooper     IN crapcop.cdcooper%type        --C¿digo Cooperativa
                                        ,pr_nrdconta     IN crapass.nrdconta%TYPE        --Numero da conta
                                        ,pr_idseqttl     IN crapttl.idseqttl%TYPE        --Identificador Sequencial titulo
                                        ,pr_nrcpfope     IN crapopi.nrcpfope%TYPE        --Numero do CPF Preposto
                                        ,pr_dtmvtopg     IN crapdat.dtmvtolt%TYPE        --Data do proximo pagamento
                                        ,pr_dsorigem     IN craplau.dsorigem%TYPE        --Descricao Origem
                                        ,pr_tab_internet OUT INET0001.typ_tab_internet   --Tabelas de retorno de horarios limite
                                        ,pr_cdcritic     OUT INTEGER        --Codigo do erro
                                        ,pr_dscritic     OUT VARCHAR2) IS
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_busca_limites_preposto       Antigo: 
    --  Sistema  : Procedure para buscar os limites para preposto - internet
    --  Sigla    : CRED
    --  Autor    : Rafael Muniz Monteiro - Mouts
    --  Data     : Junho/2017.                   Ultima atualizacao: 
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -------
    -- Objetivo  : Procedure para buscar os limites dos preposto para transações da internet
    
    -- Atualizacao: 
    ---------------------------------------------------------------------------------------------------------------
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
     -- Buscar os pagamentos da folha de pagamento Aprovados para o dia
     CURSOR cr_crappfp (pr_cdcooper IN craplau.cdcooper%type
                       ,pr_nrdconta IN craplau.nrdconta%type
                       ,pr_dtmvtopg IN craplau.dtmvtopg%type) IS

      SELECT nvl(sum(pfp.VLLCTPAG),0) vllctpag
         FROM crapemp emp
            , crappfp pfp
            , crapass ass
        WHERE emp.cdcooper = pfp.cdcooper
          AND emp.cdempres = pfp.cdempres
          AND pfp.cdcooper = pr_cdcooper
          AND emp.nrdconta = pr_nrdconta
          AND (TRUNC(pfp.dtmvtolt) = pr_dtmvtopg OR
               TRUNC(pfp.dtcredit) = pr_dtmvtopg OR
               TRUNC(pfp.dtdebito) = pr_dtmvtopg OR
               TRUNC(pfp.dthorcre) = pr_dtmvtopg OR
               TRUNC(pfp.dthordeb) = pr_dtmvtopg)
          AND ass.cdcooper = emp.cdcooper
          AND ass.nrdconta = emp.nrdconta
          AND pfp.idsitapr in (5,6) -- Aprovada
          ;  
      CURSOR CR_TBCC_LIMITE_PREPOSTO (prc_cdcooper TBCC_LIMITE_PREPOSTO.Cdcooper%type,
                                      prc_nrdconta TBCC_LIMITE_PREPOSTO.Nrdconta%type,
                                      prc_nrcpfope TBCC_LIMITE_PREPOSTO.Nrcpf%type ) IS
        SELECT vllimite_pagto,
               vllimite_transf,
               vllimite_ted,
               vllimite_vrboleto,
               vllimite_folha
          FROM TBCC_LIMITE_PREPOSTO
         WHERE cdcooper = prc_cdcooper
           AND nrdconta = prc_nrdconta
           AND nrcpf    = prc_nrcpfope
        ;      
      --
      --Variaveis Locais
      vr_index        INTEGER;
      vr_inpessoa     INTEGER;
      vr_vlutlweb     crapsnh.vllimweb%TYPE;
      vr_vlutltrf     crapsnh.vllimtrf%TYPE;
      vr_vlutlpgo     crapsnh.vllimpgo%TYPE;
      vr_vlutlted     crapsnh.vllimted%TYPE;
      vr_vlutlvrb     NUMBER;
      vr_vlutlflp     NUMBER;
      --
      vr_tab_vllimweb crapsnh.vllimweb%TYPE;
      vr_tab_vllimtrf crapsnh.vllimtrf%TYPE;
      vr_tab_vllimpgo crapsnh.vllimpgo%TYPE;
      vr_tab_vllimted crapsnh.vllimted%TYPE;
      vr_tab_vllimvrb crapsnh.vllimted%TYPE;
      vr_dstextab     craptab.dstextab%TYPE;
      --
       
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
      vr_dscritic:= '2 - Associado nao cadastrado.';
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
      pr_dscritic := '2 - Tabela (LIMINTERNT) nao cadastrada.';
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
    --
    -- Buscar limites preposto
    vr_index:= pr_idseqttl;
    -- LIMITES COOPERATIVA
    pr_tab_internet(vr_index).idseqttl:= pr_idseqttl;
    pr_tab_internet(vr_index).nrcpfope:= pr_nrcpfope;
    pr_tab_internet(vr_index).vlwebcop:= vr_tab_vllimweb;
    pr_tab_internet(vr_index).vlpgocop:= vr_tab_vllimpgo;
    pr_tab_internet(vr_index).vltrfcop:= vr_tab_vllimtrf;
    pr_tab_internet(vr_index).vltedcop:= vr_tab_vllimted;
    pr_tab_internet(vr_index).vlvrbcop:= vr_tab_vllimvrb;  
    pr_tab_internet(vr_index).vllimweb:= 0;
    --
    pr_tab_internet(vr_index).vllimpgo := 0;
    pr_tab_internet(vr_index).vllimtrf := 0;
    pr_tab_internet(vr_index).vllimted := 0;
    pr_tab_internet(vr_index).vllimvrb := 0;
    pr_tab_internet(vr_index).vllimflp := 0;
    /*Valor utilizado*/
    pr_tab_internet(vr_index).vlutlweb := 0; 
    pr_tab_internet(vr_index).vlutlpgo := 0;
    pr_tab_internet(vr_index).vlutltrf := 0;
    pr_tab_internet(vr_index).vlutlted := 0;
    pr_tab_internet(vr_index).vlutlvrb := 0;
    pr_tab_internet(vr_index).vlutlflp := 0;
           /* Limite disponivel */
    pr_tab_internet(vr_index).vldspweb := 0;
    pr_tab_internet(vr_index).vldsppgo := 0;
    pr_tab_internet(vr_index).vldsptrf := 0;
    pr_tab_internet(vr_index).vldspted := 0;
    pr_tab_internet(vr_index).vldspvrb := 0;
    pr_tab_internet(vr_index).vldspflp := 0;   
     
    BEGIN
      FOR RW_TBCC_LIMITE_PREPOSTO in CR_TBCC_LIMITE_PREPOSTO (pr_cdcooper,
                                                              pr_nrdconta,
                                                              pr_nrcpfope) LOOP
        pr_tab_internet(vr_index).vllimpgo := RW_TBCC_LIMITE_PREPOSTO.VLLIMITE_PAGTO;
        pr_tab_internet(vr_index).vllimtrf := RW_TBCC_LIMITE_PREPOSTO.VLLIMITE_TRANSF;
        pr_tab_internet(vr_index).vllimted := RW_TBCC_LIMITE_PREPOSTO.VLLIMITE_TED;
        pr_tab_internet(vr_index).vllimvrb := RW_TBCC_LIMITE_PREPOSTO.VLLIMITE_VRBOLETO;
        pr_tab_internet(vr_index).vllimflp := RW_TBCC_LIMITE_PREPOSTO.VLLIMITE_FOLHA;
      END LOOP;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := '2 - Erro Oracle Cooperativa: '||pr_cdcooper||
                       ' Nr Conta: '||pr_nrdconta||
                       ' CPF: '||pr_nrcpfope||
                       ' '||sqlerrm;
        RAISE vr_exc_erro;                       
    END;
      
    /** Limite Disponivel (Total - Utilizado) **/
      --Zerar variaveis
      vr_vlutlweb:= 0;
      vr_vlutltrf:= 0;
      vr_vlutlpgo:= 0;
      vr_vlutlted:= 0;
      vr_vlutlflp:= 0;
      vr_vlutlvrb:= 0;

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
       -- vr_vlutlweb:= rw_crapmvi.vlmovweb;
        --Valor Utilizado Transferencia
        vr_vlutltrf:= rw_crapmvi.vlmovtrf;
        --Valor Utilizado Pagamento
        vr_vlutlpgo:= rw_crapmvi.vlmovpgo;
        --Valor Utilizado TED
        vr_vlutlted:= rw_crapmvi.vlmovted;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapmvi;

      --Percorrer todos os lancamentos
      FOR rw_craplau IN cr_craplau (pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_idseqttl => pr_idseqttl
                                   ,pr_dtmvtopg => pr_dtmvtopg
                                   ,pr_insitlau => 1
                                   ,pr_dsorigem => pr_dsorigem) LOOP
        IF rw_craplau.cdtiptra IN (1,3,5)  THEN
          --Acumular valor utilizado transferencia
          vr_vlutltrf:= vr_vlutltrf + Nvl(rw_craplau.vllanaut,0);
        ELSIF rw_craplau.cdtiptra = 4 THEN
          --Acumula valor de TED já agendadas  
          vr_vlutlted := vr_vlutlted + Nvl(rw_craplau.vllanaut,0);
        ELSIF rw_craplau.cdtiptra = 6 THEN
          --Acumula valor de VR Boleto já agendadas 
          vr_vlutlvrb := nvl(rw_craplau.vllanaut,0);
        ELSIF rw_craplau.cdtiptra IN (2,10)  THEN
          --Acumular valor utilizado pagamentos
          vr_vlutlpgo:= vr_vlutlpgo + Nvl(rw_craplau.vllanaut,0);
        END IF;
      END LOOP;
      -- vr_vlutlflp
      -- Buscar valores de pagamentos para o tipo folha de pagamento
      FOR rw_crappfp IN cr_crappfp(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_dtmvtopg => pr_dtmvtopg) LOOP
          
        vr_vlutlflp := rw_crappfp.vllctpag;
      END LOOP;
         
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
        

      --Se existir valor limite Vr Boleto
      IF  pr_tab_internet.EXISTS(vr_index) AND pr_tab_internet(vr_index).vllimvrb > 0  THEN
        --Valor utilizado ted
        pr_tab_internet(vr_index).vlutlvrb:= vr_vlutlvrb;
        --Valor disponivel ted. recebe limite menos utilizado ted
        pr_tab_internet(vr_index).vldspvrb:= pr_tab_internet(vr_index).vllimvrb - vr_vlutlvrb;
      END IF;
               
      --Se existir valor limite Folha de pagamento
      IF  pr_tab_internet.EXISTS(vr_index) AND pr_tab_internet(vr_index).vllimflp > 0  THEN
        --Valor utilizado Folha de Pagamento
        pr_tab_internet(vr_index).vlutlflp:= vr_vlutlflp;
        --Valor disponivel folha de pagamento
        pr_tab_internet(vr_index).vldspflp:= pr_tab_internet(vr_index).vllimflp - vr_vlutlflp;
      END IF;             

    EXCEPTION
       WHEN vr_exc_erro THEN
         pr_cdcritic:= vr_cdcritic;
         pr_dscritic:= vr_dscritic;
       WHEN OTHERS THEN
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro na rotina INET0001.pc_busca_limite_preposto. '||SQLERRM;

  END pc_busca_limites_prepo_trans;
  
  --
  --
  /*Buscar os limites de transacao do operador*/                             
  PROCEDURE pc_busca_limites_opera_trans(pr_cdcooper     IN crapcop.cdcooper%type        --C¿digo Cooperativa
                                        ,pr_nrdconta     IN crapass.nrdconta%TYPE        --Numero da conta
                                        ,pr_idseqttl     IN crapttl.idseqttl%TYPE        --Identificador Sequencial titulo
                                        ,pr_nrcpfope     IN crapopi.nrcpfope%TYPE        --Numero do CPF Operador
                                        ,pr_dtmvtopg     IN crapdat.dtmvtolt%TYPE        --Data do proximo pagamento
                                        ,pr_dsorigem     IN craplau.dsorigem%TYPE        --Descricao Origem
                                        ,pr_tab_internet OUT INET0001.typ_tab_internet   --Tabelas de retorno de horarios limite
                                        ,pr_cdcritic     OUT INTEGER        --Codigo do erro
                                        ,pr_dscritic     OUT VARCHAR2) IS

    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_busca_limites_operador       Antigo: 
    --  Sistema  : Procedure para buscar os limites para operador - internet
    --  Sigla    : CRED
    --  Autor    : Rafael Muniz Monteiro - Mouts
    --  Data     : Junho/2017.                   Ultima atualizacao: 
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: Sempre que for chamado
    -- Objetivo  : Procedure para buscar os limites dos operadoroes para transações da internet
    
    -- Atualizacao: 
    ---------------------------------------------------------------------------------------------------------------
      /* Cursores Locais */

      --selecionar movimentacoes internet
/*      CURSOR cr_crapmvi (pr_cdcooper IN crapmvi.cdcooper%type
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
      rw_crapmvi cr_crapmvi%ROWTYPE;*/
      --
      CURSOR cr_crappro (prc_cdcooper IN crappro.cdcooper%type
                        ,prc_nrdconta IN crappro.nrdconta%type
                        ,prc_nrcpfope IN crappro.nrcpfope%type
                        ,prc_dtmvtolt IN crappro.dtmvtolt%type) IS      
      SELECT pro.cdtippro,
             pro.vldocmto
        FROM crappro pro
       WHERE pro.cdcooper = prc_cdcooper
         AND pro.nrdconta = prc_nrdconta
         AND trunc(pro.dtmvtolt) = trunc(prc_dtmvtolt) -- 30 --pr_dtmvtolt
         AND pro.flgativo        = 1 -- Ativo
         AND pro.nrcpfope        = prc_nrcpfope
         AND pro.cdtippro        in (1,2,6,9,13,15,16,17)
        ; 
      --        
      --Selecionar informacoes dos lancamentos automaticos
      CURSOR cr_craplau (pr_cdcooper IN craplau.cdcooper%type
                        ,pr_nrdconta IN craplau.nrdconta%type
                        ,pr_idseqttl IN craplau.idseqttl%type
                        ,pr_dtmvtopg IN craplau.dtmvtopg%type
                        ,pr_insitlau IN craplau.insitlau%type
                        ,pr_dsorigem IN craplau.dsorigem%type
                        ,pr_nrcpfope IN craplau.nrcpfope%type) IS
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
        AND   craplau.dsorigem = pr_dsorigem
        AND   craplau.nrcpfope = pr_nrcpfope;
     --
     -- Buscar os pagamentos da folha de pagamento
     CURSOR cr_crappfp (pr_cdcooper IN craplau.cdcooper%type
                       ,pr_nrdconta IN craplau.nrdconta%type
                       ,pr_dtmvtopg IN craplau.dtmvtopg%type
                       ,pr_nrcpfope IN craplau.nrcpfope%type) IS
                       
      SELECT nvl(sum(pfp.VLLCTPAG),0) vllctpag
         FROM crapemp emp
            , crappfp pfp
            , crapass ass
        WHERE emp.cdcooper = pfp.cdcooper
          AND emp.cdempres = pfp.cdempres
          AND pfp.nrcpfapr = pr_nrcpfope
          AND pfp.cdcooper = pr_cdcooper
          AND emp.nrdconta = pr_nrdconta
          AND (TRUNC(pfp.dtmvtolt) = pr_dtmvtopg OR
               TRUNC(pfp.dtcredit) = pr_dtmvtopg OR
               TRUNC(pfp.dtdebito) = pr_dtmvtopg OR
               TRUNC(pfp.dthorcre) = pr_dtmvtopg OR
               TRUNC(pfp.dthordeb) = pr_dtmvtopg)
          AND ass.cdcooper = emp.cdcooper
          AND ass.nrdconta = emp.nrdconta
          AND pfp.idsitapr in (5,6) -- Aprovada
          ;      
      --
     CURSOR cr_crapopi (prc_cdcooper     IN crapcop.cdcooper%type        --C¿digo Cooperativa
                        ,prc_nrdconta     IN crapass.nrdconta%TYPE        --Numero da conta
                        ,prc_nrcpfope     IN crapopi.nrcpfope%TYPE        --Numero do CPF Operador
                        ) IS
       SELECT opi.vllbolet, --	Valor Limite Boleto, Convenio e Todos os Tributos
              opi.vllimtrf, --	Valor Limite Transferencia
              opi.vllimted, --	Valor Limite TED
              opi.vllimvrb, --	Valor Limite VR Boleto
              opi.vllimflp  --	Valor Limite Folha de Pagamento
         FROM crapopi opi
        WHERE opi.cdcooper = prc_cdcooper
          AND opi.nrdconta = prc_nrdconta
          AND opi.nrcpfope = prc_nrcpfope
         ;      
      --Variaveis Locais
      -- Variaveis Operadores
       
      vr_index        INTEGER;
      vr_inpessoa     INTEGER;
      vr_vlutlweb     crapsnh.vllimweb%TYPE;
      vr_vlutltrf     crapsnh.vllimtrf%TYPE;
      vr_vlutlpgo     crapsnh.vllimpgo%TYPE;
      vr_vlutlted     crapsnh.vllimted%TYPE;
      vr_vlutlvrb     NUMBER;
      vr_vlutlflp     NUMBER;
      --
      vr_tab_vllimweb crapsnh.vllimweb%TYPE;
      vr_tab_vllimtrf crapsnh.vllimtrf%TYPE;
      vr_tab_vllimpgo crapsnh.vllimpgo%TYPE;
      vr_tab_vllimted crapsnh.vllimted%TYPE;
      vr_tab_vllimvrb crapsnh.vllimted%TYPE;
      vr_dstextab     craptab.dstextab%TYPE;
      --
       
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
      vr_dscritic:= '2 - Associado nao cadastrado.';
      --Levantar Excecao
      RAISE vr_exc_erro;
    ELSE
      --Determinar tipo pessoa para busca limite
      IF rw_crapass.inpessoa > 1 THEN
        vr_inpessoa := 2;
      ELSE
        vr_inpessoa := rw_crapass.inpessoa;
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
      pr_dscritic := '2 - Tabela (LIMINTERNT) nao cadastrada.';
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
      -- Incluir o Limite de Folha de Pagamento para a cooperativa
                              
                              
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
       -- Incluir o Limite de Folha de Pagamento para a cooperativa
           
    END IF;
    --
    -- Buscar limites operador
    vr_index:= pr_idseqttl;
    pr_tab_internet(vr_index).idseqttl:= pr_idseqttl;
    pr_tab_internet(vr_index).nrcpfope:= pr_nrcpfope;
    pr_tab_internet(vr_index).vlwebcop:= vr_tab_vllimweb;
    pr_tab_internet(vr_index).vlpgocop:= vr_tab_vllimpgo;
    pr_tab_internet(vr_index).vltrfcop:= vr_tab_vllimtrf;
    pr_tab_internet(vr_index).vltedcop:= vr_tab_vllimted;
    pr_tab_internet(vr_index).vlvrbcop:= vr_tab_vllimvrb; 
    --
    pr_tab_internet(vr_index).vllimweb := 0;
    pr_tab_internet(vr_index).vllimpgo := 0;
    pr_tab_internet(vr_index).vllimtrf := 0;
    pr_tab_internet(vr_index).vllimted := 0;
    pr_tab_internet(vr_index).vllimvrb := 0;
    pr_tab_internet(vr_index).vllimflp := 0;
    /*Valor utilizado*/
    pr_tab_internet(vr_index).vlutlweb := 0; 
    pr_tab_internet(vr_index).vlutlpgo := 0;
    pr_tab_internet(vr_index).vlutltrf := 0;
    pr_tab_internet(vr_index).vlutlted := 0;
    pr_tab_internet(vr_index).vlutlvrb := 0;
    pr_tab_internet(vr_index).vlutlflp := 0;
           /* Limite disponivel */
    pr_tab_internet(vr_index).vldspweb := 0;
    pr_tab_internet(vr_index).vldsppgo := 0;
    pr_tab_internet(vr_index).vldsptrf := 0;
    pr_tab_internet(vr_index).vldspted := 0;
    pr_tab_internet(vr_index).vldspvrb := 0;
    pr_tab_internet(vr_index).vldspflp := 0;
    
      
    
    --
    BEGIN
      FOR rw_crapopi IN cr_crapopi(pr_cdcooper
                                  ,pr_nrdconta
                                  ,pr_nrcpfope) LOOP
        pr_tab_internet(vr_index).vllimpgo := rw_crapopi.vllbolet;
        pr_tab_internet(vr_index).vllimtrf := rw_crapopi.vllimtrf;
        pr_tab_internet(vr_index).vllimted := rw_crapopi.vllimted;
        pr_tab_internet(vr_index).vllimvrb := rw_crapopi.vllimvrb;
        pr_tab_internet(vr_index).vllimflp := rw_crapopi.vllimflp;
      END LOOP;   
         
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := '2 - Erro ao buscar os limtes do operador. cooperativa: '||pr_cdcooper||
                       ' Nr Conta: '||pr_nrdconta||
                       ' CPF: '||pr_nrcpfope;
        RAISE vr_exc_erro;
    END;
    
    /** Limite Disponivel (Total - Utilizado) **/
      --Zerar variaveis
    vr_vlutlweb:= 0;
    vr_vlutltrf:= 0;
    vr_vlutlpgo:= 0;
    vr_vlutlted:= 0;
    vr_vlutlvrb:= 0;
    vr_vlutlflp:= 0;

/*    \** Acumula valores movimentados pelo titular **\
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
    CLOSE cr_crapmvi;*/
    
    --
    
    /* Tipos de transacoes na tabela crappro
    -1 - Transferencia 
    -9 -	TED
    -2 -	Pagamento
    -6 -	Pagamento
    -15 -	Pagamento - Convenio
    -13 -	Pagamento de GPS
    -16 -	DARF
    -17 -	DAS
    */

    FOR rw_crappro IN cr_crappro(pr_cdcooper,
                                 pr_nrdconta,
                                 pr_nrcpfope,
                                 pr_dtmvtopg) LOOP

      IF rw_crappro.cdtippro IN (2,6,13,15,16,17) THEN -- PAGAMENTO
        IF rw_crappro.vldocmto < 250000 THEN 
          vr_vlutlpgo := vr_vlutlpgo + rw_crappro.vldocmto;
        ELSE -- VR BOLETO
          vr_vlutlvrb := vr_vlutlvrb + rw_crappro.vldocmto;
        END IF;
      ELSIF rw_crappro.cdtippro = 1 THEN -- Tranferencia
        vr_vlutltrf := vr_vlutltrf + rw_crappro.vldocmto;
      ELSIF rw_crappro.cdtippro = 9 THEN -- TED
        vr_vlutlted := vr_vlutlted + rw_crappro.vldocmto;
      END IF;
      
    END LOOP;
    

    --Percorrer todos os lancamentos
    FOR rw_craplau IN cr_craplau (pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_idseqttl => pr_idseqttl
                                 ,pr_dtmvtopg => pr_dtmvtopg
                                 ,pr_insitlau => 1
                                 ,pr_dsorigem => pr_dsorigem
                                 ,pr_nrcpfope => pr_nrcpfope) LOOP
      IF rw_craplau.cdtiptra IN (1,3,5)  THEN
        --Acumular valor utilizado transferencia
        vr_vlutltrf:= vr_vlutltrf + Nvl(rw_craplau.vllanaut,0);
      ELSIF rw_craplau.cdtiptra = 4 THEN
        --Acumula valor de TED já agendadas  
        vr_vlutlted := vr_vlutlted + Nvl(rw_craplau.vllanaut,0);
      ELSIF rw_craplau.cdtiptra = 6 THEN
        --Acumula valor de VR Boleto já agendadas 
        vr_vlutlvrb := nvl(rw_craplau.vllanaut,0);
      ELSIF rw_craplau.cdtiptra IN (2,10)  THEN
        --Acumular valor utilizado pagamentos
        vr_vlutlpgo:= vr_vlutlpgo + Nvl(rw_craplau.vllanaut,0);
      END IF;
    END LOOP;
    --
    FOR rw_crappfp IN cr_crappfp(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_dtmvtopg => pr_dtmvtopg
                                ,pr_nrcpfope => pr_nrcpfope) LOOP
          
      vr_vlutlflp := rw_crappfp.vllctpag;
    END LOOP;    

    -- rmm verificar em qual tabela devo buscar para descontar do limite da folha de pagamento
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

    --Se existir valor limite Vr Boleto
    IF  pr_tab_internet.EXISTS(vr_index) AND pr_tab_internet(vr_index).vllimvrb > 0  THEN
      --Valor utilizado ted
      pr_tab_internet(vr_index).vlutlvrb:= vr_vlutlvrb;
      --Valor disponivel ted. recebe limite menos utilizado ted
      pr_tab_internet(vr_index).vldspvrb:= pr_tab_internet(vr_index).vllimvrb - vr_vlutlvrb;
    END IF;
               
    --Se existir valor limite Folha de pagamento
    IF  pr_tab_internet.EXISTS(vr_index) AND pr_tab_internet(vr_index).vllimflp > 0  THEN
      --Valor utilizado ted
      pr_tab_internet(vr_index).vlutlflp:= vr_vlutlflp;
      --Valor disponivel ted. recebe limite menos utilizado ted
      pr_tab_internet(vr_index).vldspflp:= pr_tab_internet(vr_index).vllimflp - vr_vlutlflp;
    END IF;             

  EXCEPTION
     WHEN vr_exc_erro THEN
       pr_cdcritic:= vr_cdcritic;
       pr_dscritic:= vr_dscritic;
     WHEN OTHERS THEN
       pr_cdcritic:= 0;
       pr_dscritic:= 'Erro na rotina INET0001.pc_busca_limite_operador. '||SQLERRM;
  end pc_busca_limites_opera_trans;
  --
  PROCEDURE pc_verifica_idastcjt_pfp (pr_cdcooper IN crapcop.cdcooper%TYPE --Codigo Cooperativa
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE --Conta do Associado
                                     ,pr_idseqttl IN crapttl.idseqttl%type  --> Titularidade do Associado
                                     ,pr_nrcpfope IN crapass.nrcpfcgc%TYPE  --> CPF do Rep. Legal                                   
                                     ,pr_dsorigem IN VARCHAR2                --> Codigo Origem
                                     ,pr_indrowid IN VARCHAR2               --> Lista de Rowid da folha de pagamento
                                     ,pr_flsolest IN tbfolha_trans_pend.idestouro%TYPE          --> Indicador de solicitacao de estouro de conta (0 – Nao / 1 – Sim)
                                     ,pr_dsalerta OUT VARCHAR2
                                     ,pr_cdcritic OUT INTEGER  
                                     ,pr_dscritic OUT VARCHAR2) IS   -->Codigo do erro
  /*---------------------------------------------------------------------------------------------------------------
   Programa : pc_verifica_idastcjt_pfp           Antigo: 
   Sistema  : Procedimentos para o debito de agendamentos feitos na Internet
   Sigla    : CRED
   Autor    : Rafael Muniz Monteiro - Mouts
   Data     : Junho/2017.                   Ultima atualizacao: 
  
  Dados referentes ao programa: Projeto 397
  
  Frequencia: -----
  Objetivo  : Procedure para validar se necessita assinatura conjunta para operarações de folha de
              pagamento.
  
  Alteracoes: 
            
  ---------------------------------------------------------------------------------------------------------------*/
      CURSOR cr_crappfp (prc_indrowid IN VARCHAR2)IS
        SELECT pfp.dtdebito,
               pfp.vllctpag,
               pfp.idsitapr
          FROM crappfp pfp
         WHERE pfp.rowid like prc_indrowid;
       --
       CURSOR cr_crapopi (prc_cdcooper       IN crapcop.cdcooper%TYPE --Codigo Cooperativa
                         ,prc_nrdconta       IN crapass.nrdconta%TYPE --Conta do Associado
                         ,prc_nrcpfope       IN crapass.nrcpfcgc%TYPE) IS
         SELECT 1
            FROM crapopi opi
           WHERE opi.cdcooper = prc_cdcooper
             AND opi.nrdconta = prc_nrdconta
             AND opi.nrcpfope = prc_nrcpfope
             AND rownum       = 1;
       --
       CURSOR cr_crappfp2 (pr_vr_rowid IN VARCHAR2,
                           pr_dtdebito IN DATE) IS
         SELECT nvl(sum(pfp.vllctpag),0) vllctpag
           FROM crappfp pfp
          WHERE pfp.rowid like pr_vr_rowid;
      --
      -- buscar o numero do CPF
      CURSOR cr_crapsnh2 (prc_cdcooper crapsnh.cdcooper%type,
                         prc_nrdconta crapsnh.nrdconta%type,
                         prc_idseqttl crapsnh.idseqttl%type)IS
        SELECT c.nrcpfcgc
          FROM crapsnh c
         WHERE c.cdcooper = prc_cdcooper
           AND c.nrdconta = prc_nrdconta
           AND c.idseqttl = prc_idseqttl
           AND c.tpdsenha = 1 -- INTERNET
           ;      
     -- Verifica se a conta possui operador     
     CURSOR cr_crapopi2 (prc_cdcooper     IN crapcop.cdcooper%type        --C¿digo Cooperativa
                        ,prc_nrdconta     IN crapass.nrdconta%TYPE        --Numero da conta
                        ) IS
       SELECT 1
         FROM crapopi opi
        WHERE opi.cdcooper = prc_cdcooper
          AND opi.nrdconta = prc_nrdconta
          AND rownum       = 1 
         ;               
              
      --Tipo de Dados para cursor data
      rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

      --Variaveis Locais
      vr_vldspptl        crapsnh.vllimflp%TYPE ;
      vr_vldspptl_conta  crapsnh.vllimflp%TYPE ;
      vr_idseqttl        crapttl.idseqttl%TYPE := 0;
      va_existe_operador NUMBER(1);
      vr_dsdmensa        VARCHAR2(100);
      pr_tab_internet    INET0001.typ_tab_internet;
      tab_limite_conta    INET0001.typ_tab_internet;
      vr_dtdebpfp        crappfp.dtdebito%TYPE;
      va_nrcpfcgc        crapsnh.nrcpfcgc%type;
      va_des_reto        VARCHAR2(100);
      va_dsalerta        VARCHAR2(500);
      --Tipo da tabela de saldos
      vr_tab_saldo EXTR0001.typ_tab_saldos;
      
      -- Controladores de rowids
      vr_indrowid  GENE0002.typ_split;
      vr_indrowid2 GENE0002.typ_split;
      vr_rowidexe  VARCHAR2(32000);
      vr_rowid     VARCHAR2(50);
      vr_rowid2     VARCHAR2(50);
      vr_vllanmto  crappfp.vllctpag%type;
      va_data_ant  crappfp.dtdebito%type;
      va_controle_final BOOLEAN;
      
      --Variaveis de Erro
      vr_cdcritic  crapcri.cdcritic%TYPE;
      vr_dscritic  VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro  EXCEPTION;

      --Variaveis de Indice
      --Tabela de memoria de erro
      vr_tab_erro  GENE0001.typ_tab_erro;
      --
      vr_nrdrowid ROWID;
      vr_dstransa VARCHAR2(100);
      vr_tp_transa VARCHAR2(100) := 'Folha de Pagamento'; 
      vr_operador_conta  NUMBER(1);
      
    BEGIN
      --Inicializar varaivel retorno erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;
      -- variaveis de controle
      va_data_ant := null;
      vr_rowidexe := null;
      vr_idseqttl        := nvl(pr_idseqttl,0);
      va_existe_operador := 0;
      va_des_reto        := NULL;
      va_dsalerta        := NULL;
      va_nrcpfcgc        := NULL;
      vr_vllanmto        := 0;      
      
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
      -- Se nao encontrar
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
      --
      -- Se tiver assinatura conjunta habilitado, buscar  limites do prepos
      -- ou limites do preposto.
      -- Quebra a string contendo o rowid separado por virgula
      vr_indrowid := gene0002.fn_quebra_string(pr_string => pr_indrowid, pr_delimit => ',');
      --
      -- LOG VERLOG
      vr_nrdrowid := NULL;
      vr_dstransa := 'Validacoes com limites Folha Pag';
      GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => 0
                          ,pr_dscritic => ''
                          ,pr_dsorigem => 'INTERNET'
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1 --> TRUE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => vr_idseqttl
                          ,pr_nmdatela => 'INTERNET'
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      --
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Parametro CPF do operador'
                               ,pr_dsdadant => ''
                               ,pr_dsdadatu => pr_nrcpfope);    
                               
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Tipo Pessoa'
                               ,pr_dsdadant => ''
                               ,pr_dsdadatu => to_char(rw_crapass.inpessoa)||' Juridico');

      --
      -- Se for tipo de pessoa juridica, buscar  limites do OPERADOR
      -- ou limites do PREPOSTO.      
      IF rw_crapass.inpessoa IN (2,3) THEN
        -- todos os Rowids selecionados 
        FOR vr_index IN 1..vr_indrowid.COUNT() LOOP
          -- ROWID selecionado
          vr_rowid := vr_indrowid(vr_index);
          -- buscar informacao Rowid selecionado 
          FOR rw_crappfp IN cr_crappfp(vr_rowid) LOOP
            
            -- Verificar se folha já foi registrada como transação pendente
            IF rw_crappfp.idsitapr = 6 THEN
              vr_cdcritic:= 0;
              vr_dscritic:= 'Folha de pagamento já foi registrada para aprovação do(s) preposto(s). Verifique as transações pendentes.';
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;
                
            -- Verificar se deve somar o valor ou validara validar os limites
            IF va_data_ant is null or
              va_data_ant = rw_crappfp.dtdebito THEN
              
              va_data_ant := rw_crappfp.dtdebito;
              -- somar as quantidades e ir para o proximo registro   
              vr_vllanmto := vr_vllanmto + rw_crappfp.vllctpag;
              -- montar uma string com os rowid
              IF vr_rowidexe IS NULL THEN
                vr_rowidexe := vr_rowid;
              ELSE
                vr_rowidexe := vr_rowidexe ||',' ||vr_rowid;
              END IF;
              -- executar se somente encontrar a mesma data
              va_controle_final := true;
              
            ELSE -- mudou a data, portanto validar os limites com as datas processadas
              -- mudou a data, executar as validacoes de limites com o valor somado anterior
              gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                       ,pr_nmdcampo => 'Valor da soma lanc'
                                       ,pr_dsdadant => ''
                                       ,pr_dsdadatu => vr_vllanmto);
              -- Verifica se eh operador
              BEGIN
                FOR rw_crapopi IN cr_crapopi(pr_cdcooper,
                                             pr_nrdconta,
                                             pr_nrcpfope) LOOP
                  va_existe_operador := 1;
                END LOOP;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_cdcritic:= 0;
                  vr_dscritic:= '1-INET0001.Erro ao buscar operador: '||sqlerrm||  ' rowid: '||vr_indrowid(1);
                  --Levantar Excecao
                 RAISE vr_exc_erro;
              END;             
              --
              IF va_existe_operador = 0 THEN -- se for preposto
                -- Buscar CPF do preposto, para buscar os limites 
                FOR rw_crapsnh2 IN cr_crapsnh2(pr_cdcooper,
                                               pr_nrdconta,
                                               vr_idseqttl) LOOP
                  va_nrcpfcgc := rw_crapsnh2.nrcpfcgc;
                END LOOP;               
                -- log item
                gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                         ,pr_nmdcampo => 'Tipo usuario'
                                         ,pr_dsdadant => ''
                                         ,pr_dsdadatu => 'Preposto');   
                -- log item
                gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                          ,pr_nmdcampo => 'Data do debito Folha'
                                         ,pr_dsdadant => ''
                                         ,pr_dsdadatu => va_data_ant);          
                IF rw_crapass.idastcjt = 1 THEN         
                -- buscar limites preposto
                pc_busca_limites_prepo_trans(pr_cdcooper     => pr_cdcooper  --Codigo Cooperativa
                                            ,pr_nrdconta     => pr_nrdconta  --Numero da conta
                                            ,pr_idseqttl     => vr_idseqttl  --Identificador Sequencial titulo
                                            ,pr_nrcpfope     => va_nrcpfcgc  --Numero do CPF
                                            ,pr_dtmvtopg     => va_data_ant  --Data do debito da folha de pagamento
                                            ,pr_dsorigem     => pr_dsorigem  --Descricao Origem
                                            ,pr_tab_internet => pr_tab_internet --Tabelas de retorno de horarios limite
                                            ,pr_cdcritic     => vr_cdcritic   --Codigo do erro
                                            ,pr_dscritic     => vr_dscritic); --Descricao do erro;
                --Se ocorreu erro
                IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                  --Levantar Excecao
                  RAISE vr_exc_erro;
                END IF;        
                ELSE
                  /* Buscar Limites da internet DA CONTA */
                  pc_busca_limites (pr_cdcooper     => pr_cdcooper  --Codigo Cooperativa
                                   ,pr_nrdconta     => pr_nrdconta  --Numero da conta
                                   ,pr_idseqttl     => vr_idseqttl  --Identificador Sequencial titulo
                                   ,pr_flglimdp     => TRUE         --Indicador limite deposito
                                   ,pr_dtmvtopg     => va_data_ant  --Data do proximo pagamento
                                   ,pr_flgctrag     => FALSE  --Indicador validacoes
                                   ,pr_dsorigem     => pr_dsorigem  --Descricao Origem
                                   ,pr_tab_internet => pr_tab_internet --Tabelas de retorno de horarios limite
                                   ,pr_cdcritic     => vr_cdcritic   --Codigo do erro
                                   ,pr_dscritic     => vr_dscritic); --Descricao do erro;
                  --Se ocorreu erro
                  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                    --Levantar Excecao
                    RAISE vr_exc_erro;
                  END IF; -- Validar se esá habilitado assinatura conjunta                
                END IF;                                 
 
              ELSE -- Se for operador
                -- log item
                gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                         ,pr_nmdcampo => 'Tipo usuario'
                                         ,pr_dsdadant => ''
                                         ,pr_dsdadatu => 'Operador');   
                -- log item
                gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                         ,pr_nmdcampo => 'Data do debito Folha'
                                         ,pr_dsdadant => ''
                                         ,pr_dsdadatu => va_data_ant); 
                                              
                pc_busca_limites_opera_trans(pr_cdcooper     => pr_cdcooper  --Codigo Cooperativa
                                            ,pr_nrdconta     => pr_nrdconta  --Numero da conta
                                            ,pr_idseqttl     => vr_idseqttl  --Identificador Sequencial titulo
                                            ,pr_nrcpfope     => pr_nrcpfope  --Numero do CPF
                                            ,pr_dtmvtopg     => va_data_ant  --Data do debito da folha de pagamento
                                            ,pr_dsorigem     => pr_dsorigem  --Descricao Origem
                                            ,pr_tab_internet => pr_tab_internet --Tabelas de retorno de horarios limite
                                            ,pr_cdcritic     => vr_cdcritic   --Codigo do erro
                                            ,pr_dscritic     => vr_dscritic); --Descricao do erro;
                             
                --Se ocorreu erro
                IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                  --Levantar Excecao
                  RAISE vr_exc_erro;
                END IF;        
              END IF; -- IF verificar operador - buscar limites
              
              IF NOT pr_tab_internet.EXISTS(vr_idseqttl) THEN
                vr_cdcritic:= 0;
                vr_dscritic:= 'Registro de limite para validar assinatura conjunta nao encontrado.';
                --Levantar Excecao
                RAISE vr_exc_erro;
              END IF;             
              /*Buscar limites da conta*/
              pc_busca_limites (pr_cdcooper     => pr_cdcooper  --Codigo Cooperativa
                               ,pr_nrdconta     => pr_nrdconta  --Numero da conta
                               ,pr_idseqttl     => vr_idseqttl  --Identificador Sequencial titulo
                               ,pr_flglimdp     => TRUE         --Indicador limite deposito
                               ,pr_dtmvtopg     => va_data_ant  --Data do proximo pagamento
                               ,pr_flgctrag     => FALSE  --Indicador validacoes
                               ,pr_dsorigem     => pr_dsorigem  --Descricao Origem
                               ,pr_tab_internet => tab_limite_conta --Tabelas de retorno de horarios limite
                               ,pr_cdcritic     => vr_cdcritic   --Codigo do erro
                               ,pr_dscritic     => vr_dscritic); --Descricao do erro;
              --Se ocorreu erro
              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                --Levantar Excecao
                RAISE vr_exc_erro;
              END IF;                  
              --
              -- Limite disponível Folha de  pagamento
              vr_vldspptl := pr_tab_internet(vr_idseqttl).vldspflp;
              vr_vldspptl_conta := tab_limite_conta(vr_idseqttl).vldspflp;
              --
              -- log item
              gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                       ,pr_nmdcampo => 'Limite Disponivel'
                                       ,pr_dsdadant => ''
                                       ,pr_dsdadatu => vr_vldspptl);  
             vr_operador_conta := 0;
             FOR rw_cr_crapopi2 in cr_crapopi2(pr_cdcooper
                                              ,pr_nrdconta) LOOP
                                                                       
               vr_operador_conta := 1;                        
             END LOOP;                                             
              /** Verifica se pode movimentar em relacao ao que ja foi usado **/
             -- SE NAO FOR ASSINATURA E NAO TIVER OPERADOR E ULTRAPSSOU O LIMITE DA CONTA, MOSTRAR CRITICA
             IF rw_crapass.idastcjt = 0 AND vr_operador_conta = 0 AND
               vr_vllanmto > vr_vldspptl THEN
               vr_cdcritic:= 0;
               vr_dscritic:= 'O saldo do seu limite diario e insuficiente - Folha Pagamento';
               RAISE vr_exc_erro;
             ELSIF rw_crapass.idastcjt = 0 AND pr_nrcpfope <= 0 AND
               vr_vllanmto > vr_vldspptl THEN
               vr_cdcritic:= 0;
               vr_dscritic:= 'O saldo do seu limite diario e insuficiente  - Folha pagamento';
               RAISE vr_exc_erro;
             ELSIF vr_vllanmto > vr_vldspptl_conta THEN
               vr_cdcritic:= 0;
               vr_dscritic:= 'O saldo do seu limite diario e insuficiente  - Folha pagamento';
               RAISE vr_exc_erro;               
             ELSIF vr_vllanmto > vr_vldspptl  THEN
                
                vr_indrowid2 := gene0002.fn_quebra_string(pr_string => vr_rowidexe, pr_delimit => ',');

                -- Para cada registro selecionado, faremos as validacoes necessarias
                FOR vr_index IN 1..vr_indrowid2.COUNT() LOOP
                  -- ROWID do pagamento
                  vr_rowid2 := vr_indrowid2(vr_index);                
                  
                  BEGIN
                    -- Atualiza o pagamento
                    UPDATE crappfp
                       SET crappfp.idsitapr = 6 -- Transacao pendente
                     WHERE crappfp.rowid = vr_rowid2;
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_dscritic := 'INET0002 Erro na atualizacao da CRAPPFP (1): ' || SQLERRM;
                      RAISE vr_exc_erro;
                  END;                 
                END LOOP;
                -- CHAMAR A ROTINA DE PEDENCIA
                BEGIN
                  INET0002.pc_cria_trans_pend_folha(pr_cdagenci => 90, 
                                                    pr_nrdcaixa => 900, 
                                                    pr_cdoperad => '996', 
                                                    pr_nmdatela => 'INTERNET', 
                                                    pr_idorigem => 3, 
                                                    pr_idseqttl => vr_idseqttl, 
                                                    pr_nrcpfope => pr_nrcpfope, 
                                                    pr_nrcpfrep => va_nrcpfcgc, 
                                                    pr_cdcoptfn => 0, 
                                                    pr_cdagetfn => 0, 
                                                    pr_nrterfin => 0, 
                                                    pr_dtmvtolt => rw_crapdat.dtmvtolt, 
                                                    pr_cdcooper => pr_cdcooper, 
                                                    pr_nrdconta => pr_nrdconta, 
                                                    pr_flsolest => pr_flsolest, 
                                                    pr_indrowid => vr_rowidexe, -- Somente os Rowids selecionador da mesma data
                                                    pr_idastcjt => 1, 
                                                    pr_cdcritic => vr_cdcritic, 
                                                    pr_dscritic => vr_dscritic);
                  pr_dsalerta := 'Aguardando aprovação dos prepostos, favor verificar nas transações pendentes';
                  IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
                    RAISE vr_exc_erro;
                  END IF; 
                  --                                                                    
                    
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_cdcritic:= 0;
                    vr_dscritic:= 'INET001 - Erro ao chamar pc_cria_trans_pend_folha '||SQLERRM;
                    RAISE vr_exc_erro;                    
                END;
              ELSE
                -- CHAMAR A ROTINA PARA aprovar
                BEGIN
                  FOLH0002.pc_aprovar_pagto_ib(pr_cdcooper => pr_cdcooper, 
                                               pr_nrdconta => pr_nrdconta, 
                                               pr_dtmvtolt => rw_crapdat.dtmvtolt, 
                                               pr_nrcpfapr => CASE va_existe_operador WHEN 1 
                                                              THEN pr_nrcpfope
                                                              ELSE va_nrcpfcgc END, 
                                               pr_flsolest => pr_flsolest, 
                                               pr_indrowid => vr_rowidexe, 
                                               pr_des_reto => va_des_reto, 
                                               pr_dsalerta => va_dsalerta, 
                                               pr_dscritic => vr_dscritic);
                  pr_dsalerta :=  va_dsalerta;
                  IF  va_des_reto <> 'OK' AND vr_dscritic IS NOT NULL THEN 
                    RAISE vr_exc_erro;
                  END IF;                                               
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_cdcritic:= 0;
                    vr_dscritic:= 'INET001 - Erro ao chamar pc_reprovar_pagto_ib '||SQLERRM;
                    RAISE vr_exc_erro;                    
                END;
              END IF;   
              --          
              -- ATUALIZAR AS VARIAVEIS DE CONTROLE
              -- Gravar as informacoes correntes, da primeira data diferente da processada
              va_data_ant := rw_crappfp.dtdebito;
              vr_rowidexe := vr_rowid;
              vr_vllanmto := rw_crappfp.vllctpag;
              va_controle_final := false;
              
            END IF;  -- fim if principal
          END LOOP; -- fim for de data e valor
          --
        END LOOP; -- Loop do Rowid selecionados na tela
        --
        -- Se foi executado para uma data somente rodar no final
        IF va_controle_final THEN
          -- mudou a data, executar as validacoes de limites com o valor somado anterior
          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                   ,pr_nmdcampo => 'Valor da soma lanc'
                                   ,pr_dsdadant => ''
                                   ,pr_dsdadatu => vr_vllanmto);
          -- Verifica se eh operador
          BEGIN
            FOR rw_crapopi IN cr_crapopi(pr_cdcooper,
                                         pr_nrdconta,
                                         pr_nrcpfope) LOOP
              va_existe_operador := 1;
            END LOOP;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic:= 0;
              vr_dscritic:= '1-INET0001.Erro ao buscar operador: '||sqlerrm||  ' rowid: '||vr_indrowid(1);
              --Levantar Excecao
             RAISE vr_exc_erro;
          END;             
          --
          IF va_existe_operador = 0 THEN -- se for preposto
            -- Buscar CPF do preposto, para buscar os limites 
            FOR rw_crapsnh2 IN cr_crapsnh2(pr_cdcooper,
                                           pr_nrdconta,
                                           vr_idseqttl) LOOP
              va_nrcpfcgc := rw_crapsnh2.nrcpfcgc;
            END LOOP;               
            -- log item
            gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Tipo usuario'
                                     ,pr_dsdadant => ''
                                     ,pr_dsdadatu => 'Preposto');   
            -- log item
            gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                      ,pr_nmdcampo => 'Data do debito Folha'
                                     ,pr_dsdadant => ''
                                     ,pr_dsdadatu => va_data_ant);          
            IF rw_crapass.idastcjt = 1 THEN         
            -- buscar limites preposto
            pc_busca_limites_prepo_trans(pr_cdcooper     => pr_cdcooper  --Codigo Cooperativa
                                        ,pr_nrdconta     => pr_nrdconta  --Numero da conta
                                        ,pr_idseqttl     => vr_idseqttl  --Identificador Sequencial titulo
                                        ,pr_nrcpfope     => va_nrcpfcgc  --Numero do CPF
                                        ,pr_dtmvtopg     => va_data_ant  --Data do debito da folha de pagamento
                                        ,pr_dsorigem     => pr_dsorigem  --Descricao Origem
                                        ,pr_tab_internet => pr_tab_internet --Tabelas de retorno de horarios limite
                                        ,pr_cdcritic     => vr_cdcritic   --Codigo do erro
                                        ,pr_dscritic     => vr_dscritic); --Descricao do erro;
            --Se ocorreu erro
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;        
            ELSE
              /* Buscar Limites da internet DA CONTA */
              pc_busca_limites (pr_cdcooper     => pr_cdcooper  --Codigo Cooperativa
                               ,pr_nrdconta     => pr_nrdconta  --Numero da conta
                               ,pr_idseqttl     => vr_idseqttl  --Identificador Sequencial titulo
                               ,pr_flglimdp     => TRUE         --Indicador limite deposito
                               ,pr_dtmvtopg     => va_data_ant  --Data do proximo pagamento
                               ,pr_flgctrag     => FALSE  --Indicador validacoes
                               ,pr_dsorigem     => pr_dsorigem  --Descricao Origem
                               ,pr_tab_internet => pr_tab_internet --Tabelas de retorno de horarios limite
                               ,pr_cdcritic     => vr_cdcritic   --Codigo do erro
                               ,pr_dscritic     => vr_dscritic); --Descricao do erro;
              --Se ocorreu erro
              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                --Levantar Excecao
                RAISE vr_exc_erro;
              END IF; -- Validar se esá habilitado assinatura conjunta                
            END IF;        
                                               
 
          ELSE -- Se for operador
            -- log item
            gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Tipo usuario'
                                     ,pr_dsdadant => ''
                                     ,pr_dsdadatu => 'Operador');   
            -- log item
            gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Data do debito Folha'
                                     ,pr_dsdadant => ''
                                     ,pr_dsdadatu => va_data_ant); 
                                              
            pc_busca_limites_opera_trans(pr_cdcooper     => pr_cdcooper  --Codigo Cooperativa
                                        ,pr_nrdconta     => pr_nrdconta  --Numero da conta
                                        ,pr_idseqttl     => vr_idseqttl  --Identificador Sequencial titulo
                                        ,pr_nrcpfope     => pr_nrcpfope  --Numero do CPF
                                        ,pr_dtmvtopg     => va_data_ant  --Data do debito da folha de pagamento
                                        ,pr_dsorigem     => pr_dsorigem  --Descricao Origem
                                        ,pr_tab_internet => pr_tab_internet --Tabelas de retorno de horarios limite
                                        ,pr_cdcritic     => vr_cdcritic   --Codigo do erro
                                        ,pr_dscritic     => vr_dscritic); --Descricao do erro;
                             
            --Se ocorreu erro
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;        
          END IF; -- IF verificar operador - buscar limites
              
          IF NOT pr_tab_internet.EXISTS(vr_idseqttl) THEN
            vr_cdcritic:= 0;
            vr_dscritic:= 'Registro de limite para validar assinatura conjunta nao encontrado.';
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;             
         /*Buscar limites da conta*/
          pc_busca_limites (pr_cdcooper     => pr_cdcooper  --Codigo Cooperativa
                           ,pr_nrdconta     => pr_nrdconta  --Numero da conta
                           ,pr_idseqttl     => vr_idseqttl  --Identificador Sequencial titulo
                           ,pr_flglimdp     => TRUE         --Indicador limite deposito
                           ,pr_dtmvtopg     => va_data_ant  --Data do proximo pagamento
                           ,pr_flgctrag     => FALSE  --Indicador validacoes
                           ,pr_dsorigem     => pr_dsorigem  --Descricao Origem
                           ,pr_tab_internet => tab_limite_conta --Tabelas de retorno de horarios limite
                           ,pr_cdcritic     => vr_cdcritic   --Codigo do erro
                           ,pr_dscritic     => vr_dscritic); --Descricao do erro;
          --Se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;                  
          --
          -- Limite disponível Folha de  pagamento
          vr_vldspptl := pr_tab_internet(vr_idseqttl).vldspflp;
          vr_vldspptl_conta := tab_limite_conta(vr_idseqttl).vldspflp;
          --
          -- log item
          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                   ,pr_nmdcampo => 'Limite Disponivel'
                                   ,pr_dsdadant => ''
                                   ,pr_dsdadatu => vr_vldspptl);  
           vr_operador_conta := 0;
           FOR rw_cr_crapopi2 in cr_crapopi2(pr_cdcooper
                                            ,pr_nrdconta) LOOP
                                                                       
             vr_operador_conta := 1;                        
           END LOOP;                                             
          /** Verifica se pode movimentar em relacao ao que ja foi usado **/
           -- SE NAO FOR ASSINATURA E NAO TIVER OPERADOR E ULTRAPSSOU O LIMITE DA CONTA, MOSTRAR CRITICA
           IF rw_crapass.idastcjt = 0 AND vr_operador_conta = 0 AND
             vr_vllanmto > vr_vldspptl THEN
             --vr_cdcritic:= 0;
             vr_dscritic:= 'O saldo do seu limite diario é insuficiente - Folha Pagamento';
             RAISE vr_exc_erro;
           ELSIF rw_crapass.idastcjt = 0 AND pr_nrcpfope <= 0 AND
             vr_vllanmto > vr_vldspptl THEN
             --vr_cdcritic:= 0;
             vr_dscritic:= 'O saldo do seu limite diario é insuficiente  - Folha pagamento.';
             RAISE vr_exc_erro;
           ELSIF vr_vllanmto > vr_vldspptl_conta THEN
             vr_dscritic:= 'O saldo do seu limite diario é insuficiente.  - Folha pagamento.';
             RAISE vr_exc_erro;             
           ELSIF vr_vllanmto > vr_vldspptl  THEN   /** Verifica se pode movimentar em relacao ao que ja foi usado **/
            vr_indrowid2 := gene0002.fn_quebra_string(pr_string => vr_rowidexe, pr_delimit => ',');
            -- Para cada registro selecionado, faremos as validacoes necessarias
            FOR vr_index IN 1..vr_indrowid2.COUNT() LOOP
              -- ROWID do pagamento
              vr_rowid2 := vr_indrowid2(vr_index);                
                  
              BEGIN
                -- Atualiza o pagamento
                UPDATE crappfp
                   SET crappfp.idsitapr = 6 -- Transacao pendente
                 WHERE crappfp.rowid = vr_rowid2;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'INET0002 Erro na atualizacao da CRAPPFP (1): ' || SQLERRM;
                  RAISE vr_exc_erro;
              END;                 
            END LOOP;             
            -- CHAMAR A ROTINA DE PEDENCIA
            BEGIN
              INET0002.pc_cria_trans_pend_folha(pr_cdagenci => 90, 
                                                pr_nrdcaixa => 900, 
                                                pr_cdoperad => '996', 
                                                pr_nmdatela => 'INTERNET', 
                                                pr_idorigem => 3, 
                                                pr_idseqttl => vr_idseqttl, 
                                                pr_nrcpfope => pr_nrcpfope, 
                                                pr_nrcpfrep => va_nrcpfcgc, 
                                                pr_cdcoptfn => 0, 
                                                pr_cdagetfn => 0, 
                                                pr_nrterfin => 0, 
                                                pr_dtmvtolt => rw_crapdat.dtmvtolt, 
                                                pr_cdcooper => pr_cdcooper, 
                                                pr_nrdconta => pr_nrdconta, 
                                                pr_flsolest => pr_flsolest, 
                                                pr_indrowid => vr_rowidexe, -- Somente os Rowids selecionador da mesma data
                                                pr_idastcjt => 1, 
                                                pr_cdcritic => vr_cdcritic, 
                                                pr_dscritic => vr_dscritic);
              pr_dsalerta := 'Aguardando aprovação dos prepostos, favor verificar nas transações pendentes';
              IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_erro;
              END IF;                                                    
                    
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic:= 0;
                vr_dscritic:= 'INET001 - Erro ao chamar pc_cria_trans_pend_folha '||SQLERRM;
                RAISE vr_exc_erro;                    
            END;
          ELSE
            -- CHAMAR A ROTINA PARA aprovar
            BEGIN
              FOLH0002.pc_aprovar_pagto_ib(pr_cdcooper => pr_cdcooper, 
                                           pr_nrdconta => pr_nrdconta, 
                                           pr_dtmvtolt => rw_crapdat.dtmvtolt, 
                                           pr_nrcpfapr => CASE va_existe_operador WHEN 1 
                                                          THEN pr_nrcpfope
                                                          ELSE va_nrcpfcgc END, 
                                           pr_flsolest => pr_flsolest, 
                                           pr_indrowid => vr_rowidexe, 
                                           pr_des_reto => va_des_reto, 
                                           pr_dsalerta => va_dsalerta, 
                                           pr_dscritic => vr_dscritic);
              pr_dsalerta :=  va_dsalerta;                                  
              IF  va_des_reto <> 'OK' AND vr_dscritic IS NOT NULL THEN 
                RAISE vr_exc_erro;
              END IF;                                               
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic:= 0;
                vr_dscritic:= 'INET001 - Erro ao chamar pc_reprovar_pagto_ib '||SQLERRM;
                RAISE vr_exc_erro;                    
            END;
          END IF;
            
        END IF;   
        COMMIT;     
      END IF; -- Validar se esá habilitado assinatura conjunta      

    EXCEPTION
       WHEN vr_exc_erro THEN
         pr_cdcritic:= vr_cdcritic;
         pr_dscritic:= vr_dscritic;
       WHEN OTHERS THEN
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro na rotina INET0001.pc_verifica_idastcjt_pfp. '||SQLERRM;
         
         btch0001.pc_log_internal_exception(pr_cdcooper => pr_cdcooper);
         
  END pc_verifica_idastcjt_pfp;  
  --
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
                                 ,pr_cdtiptra IN INTEGER  /* 1 - Transferencia / 2 - Pagamento / 3 - Credito Salario / 4 - TED*/
                                 ,pr_cdoperad IN crapope.cdoperad%TYPE  --Codigo Operador
                                 ,pr_tpoperac IN INTEGER  /* 1 - Transferencia intracooperativa / 2 - Pagamento / 3 - Cobranca / 4 - TED / 5 - Transferencia intercooperativa / 11 - DARF/DAS */
                                 ,pr_flgvalid IN BOOLEAN                --Indicador validacoes
                                 ,pr_dsorigem IN craplau.dsorigem%TYPE  --Descricao Origem
                                 ,pr_nrcpfope IN crapopi.nrcpfope%TYPE  --CPF operador
                                 ,pr_flgctrag IN BOOLEAN /* controla validacoes na efetivacao de agendamentos */
                                 ,pr_nmdatela IN VARCHAR2
                                 ,pr_flgexage IN INTEGER DEFAULT 0 -- 1 - Efetua agendamento / 0 - não efetua agendamento
                                 ,pr_dstransa   OUT VARCHAR2               --Descricao da transacao
                                 ,pr_tab_limite OUT INET0001.typ_tab_limite --Tabelas de retorno de horarios limite
                                 ,pr_tab_internet OUT INET0001.typ_tab_internet --Tabelas de retorno de horarios limite
                                 ,pr_cdcritic   OUT INTEGER     --C¿digo do erro
                                 ,pr_dscritic   OUT VARCHAR2 --Descricao do erro
                                 ,pr_assin_conjunta OUT NUMBER) IS   
  /*---------------------------------------------------------------------------------------------------------------
    Programa : pc_verifica_operacao           Antigo: b1wgen0015.p/verifica_operacao
   Sistema  : Procedimentos para o debito de agendamentos feitos na Internet
   Sigla    : CRED
   Autor    : Alisson C. Berrido - Amcom
   Data     : Junho/2013.                   Ultima atualizacao: 21/03/2019
  
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

			  06/05/2016 - Ajuste para validar o banco e agencia da conta destino em operações
						               de TED (Adriano - M117).

              10/05/2016 - Adicionado validacao de conta cadastrada no cr_crapcti.
						               (Jaison/Marcos - SUPERO)

              17/05/2016 - Ajuste na mensagem de retorno ao validar o saldo limite
                           (Adriano - M117).    
						   
						  31/05/2016 - Ajuste para colocar a validação de saldo disponível (Adriano).

              18/07/2016 - Incluido pr_tpoperac = 10 -> DARF/DAS, Prj. 338 (Jean Michel).
						   
			  31/05/2016 - Ajuste para colocar a validação de saldo disponível (Adriano).
						            
              12/12/2016 - Ajuste para não realizar a validação de conta favorecida ativa
                           quando for efetivação de agendamentos de TED
                           (Adriano - SD 563147)

              10/03/2017 - Ajustes para liberar agendamento de TED para o ultimo dia util
                           do ano (Tiago/Elton SD586106)
              
			  13/06/2017 - Alteração na mensagem de "Conta destino nao habilitada para receber valores da transferencia."
			               para "Antes de realizar essa transferencia, e necessario ativar a conta do favorecido pela Conta Online"
						   (Rafael Monteiro - Mouts - 690752)

              04/09/2017 - Alteração referente ao Projeto Assinatura conjunta (Proj 397),
                           Incluído novas regras para definir se deve seguir o fluxo de aprovação
                           em transações pendentes ou não de acordo com o limite disponível diário
                           de preposto ou operador para contas PJ.              
                           
              03/01/2018 - Corrigido para verificar saldo da conta mesmo quando for o operador realizando
                           alguma transação (Tiago/Adriano).
              
              05/01/2018 - Incluido validacoes FGTS/DAE. PRJ406 - FGTS (Odirlei-AMcom)                     
             
              05/01/2018 - Corrigdo acentuação na frase de critica agendamento e pagamento (Tiago #818723)
              
              22/01/2018 - Ajuste para qdo a conta do preposto estiver sem saldo e for um operador fazendo uma 
                           transação alem da sua alçada enviar para aprovação do preposto (Tiago/Fabricio)
                           
              04/04/2018 - Ajustar para aparecer a critica 'Não é possível agendar para a data de hoje. 
                           Utilize a opção "Nesta Data".' somente quando não for aprovação de transação
                           pendente (Lucas Ranghetti #INC0011082)
                           
              29/12/2018 - Ajuste emergencial na rotina de validação do último dia não útil do ano. (Cechet/Pablão)
              
              21/03/2019 - Essa rotina faz a validação dos limites da conta online para aprovar as transações, e o caixa eletrônico 
                           passou a utilizar as rotinas da conta online. No caixa eletrônico não existe validação de limite, pois
                           para utilizar o caixa eletrônico não precisamos da senha de internet cadastrada, e é de lá que vem o valor
                           de limite que o cooperado possui. Programa ajustado para não validar limite quando a transação estiver sendo 
                           feita pelo PA 91 (ATM) (Douglas - Projeto 363)

  ---------------------------------------------------------------------------------------------------------------*/
  BEGIN
    DECLARE
      --Cursores Locais

      --Busca o banco da conta destino que não pertencem ao sistema CECRED
      CURSOR cr_crapban (pr_cddbanco IN crapcti.cddbanco%TYPE) IS
      SELECT crapban.cdbccxlt
        FROM crapban
       WHERE crapban.cdbccxlt = pr_cddbanco;
      rw_crapban cr_crapban%ROWTYPE;
    
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
      --
      -- buscar o numero do CPF
      CURSOR cr_crapsnh2 (prc_cdcooper crapsnh.cdcooper%type,
                         prc_nrdconta crapsnh.nrdconta%type,
                         prc_idseqttl crapsnh.idseqttl%type)IS
        SELECT c.nrcpfcgc
          FROM crapsnh c
         WHERE c.cdcooper = prc_cdcooper
           AND c.nrdconta = prc_nrdconta
           AND c.idseqttl = prc_idseqttl
           AND c.tpdsenha = 1 -- INTERNET
           ;

	  -- Verifica se o CPF eh de um operador
      CURSOR cr_crapopi (prc_cdcooper     IN crapcop.cdcooper%type        --C¿digo Cooperativa
                        ,prc_nrdconta     IN crapass.nrdconta%TYPE        --Numero da conta
                        ,prc_nrcpfope     IN crapopi.nrcpfope%TYPE        --Numero do CPF Operador
                        ) IS
       SELECT 1
         FROM crapopi opi
        WHERE opi.cdcooper = prc_cdcooper
          AND opi.nrdconta = prc_nrdconta
          AND opi.nrcpfope = prc_nrcpfope
         ;      

	  -- Verifica se a conta possui operador     
     CURSOR cr_crapopi2 (prc_cdcooper     IN crapcop.cdcooper%type        --C¿digo Cooperativa
                        ,prc_nrdconta     IN crapass.nrdconta%TYPE        --Numero da conta
                        ) IS
       SELECT 1
         FROM crapopi opi
        WHERE opi.cdcooper = prc_cdcooper
          AND opi.nrdconta = prc_nrdconta
          AND rownum       = 1 
         ;       

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
      vr_vldspptl_conta  crapsnh.vllimweb%TYPE;
      vr_vldspttl  crapsnh.vllimweb%TYPE;
      vr_vllimptl  crapsnh.vllimweb%TYPE;
      vr_vllimttl  crapsnh.vllimweb%TYPE;
      vr_vllimcop  crapsnh.vllimweb%TYPE;
      vr_nmtitula  crapass.nmprimtl%TYPE;
      vr_nmtitul2  crapass.nmprimtl%TYPE;
      vr_cdcopctl  crapcop.cdcooper%TYPE;
      vr_flvldrep  NUMBER(1) := 0;
      vr_idseqttl  crapttl.idseqttl%TYPE := 0;
      va_existe_operador NUMBER(1);
	  vr_operador_conta  NUMBER(1);
      vr_dsdmensa  VARCHAR2(100);
      va_nrcpfcgc  crapsnh.nrcpfcgc%type;
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
      --
      vr_nrdrowid ROWID;
      vr_dstransa VARCHAR2(100);
      --vr_dsorigem VARCHAR2(100) := gene0001.vr_vet_des_origens(pr_idorigem);
      vr_tp_transa VARCHAR2(100) := null;     
      --
      tab_limite_conta INET0001.typ_tab_internet; --Tabelas de retorno de horarios limite
      -- Projeto 475 Sprint C
      vr_hratualgrade INTEGER;
      vr_hrinipaggrade INTEGER;
      
    BEGIN
      --Inicializar varaivel retorno erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;
      pr_assin_conjunta := 0; -- Id do fluxo de aprovacao Assinatura conjunta

      /** Monta descricao da transacao **/
      pr_dstransa:= 'Validar ';
      
      --Se for agendamento
      IF pr_idagenda IN (2,3) THEN
        pr_dstransa:= pr_dstransa || 'Agendamento de ';
      END IF;
      
      --Se for transferencia
      IF pr_tpoperac = 1  THEN /** Operacao de Transferencia **/
        IF pr_cdtiptra = 1 THEN
          vr_tp_transa := 'Transf';
          pr_dstransa:= pr_dstransa || 'Transferencia de Valores';
          vr_dsdmensa:= 'essa transferencia';
        ELSIF pr_cdtiptra = 3 THEN
          vr_tp_transa := 'Cred Sal';
          pr_dstransa:= pr_dstransa || 'Credito de Salario';
          vr_dsdmensa:= 'esse pagamento';
        END IF;
      ELSIF pr_tpoperac = 4 THEN
        vr_tp_transa := 'TED';
        pr_dstransa:= pr_dstransa || 'TED';
        vr_dsdmensa:= 'essa transferencia';
      ELSIF pr_tpoperac = 2 OR pr_tpoperac = 10 THEN  /** Operacao de Pagamento / DARF/DAS **/
        vr_tp_transa := 'Pagamento';
        pr_dstransa:= pr_dstransa || 'Pagamento de Titulos e Faturas';
        vr_dsdmensa:= 'esse pagamento';
      ELSIF pr_tpoperac = 5 THEN  /** Operacao de Transferencia Intercooperativa **/
        vr_tp_transa := 'Transf Inter';
        pr_dstransa:= pr_dstransa || 'Transferencia Intercooperativa';
        vr_dsdmensa:= 'essa transferencia';
      ELSIF pr_tpoperac = 6 THEN  /** Operacao de Pagamento VR-Boleto **/
        vr_tp_transa := 'VR Boletos ';
        pr_dstransa:= pr_dstransa || 'Pagamento de VR-Boletos ';
        vr_dsdmensa:= 'esse pagamento';
      ELSIF pr_tpoperac IN (12,13) THEN  --> FGTS, DAE
        vr_tp_transa := 'Pagamento ';
        pr_dstransa:= pr_dstransa || 'Pagamento de tributos ';
        vr_dsdmensa:= 'esse pagamento';  
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
                          ,pr_idagenda   => pr_idagenda   --Tipo de agendamento
                          ,pr_cdtiptra   => pr_cdtiptra   --Tipo de transferencia
                          ,pr_tab_limite => pr_tab_limite --Tabelas de retorno de horarios limite
                          ,pr_cdcritic   => vr_cdcritic   --Codigo do erro
                          ,pr_dscritic   => vr_dscritic); --Descricao do erro
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --
      -- LOG VERLOG
      vr_nrdrowid := NULL;
      vr_dstransa := 'Validacoes com limites de transacoes';
      GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => ''
                          ,pr_dsorigem => pr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1 --> TRUE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => pr_idseqttl
                          ,pr_nmdatela => pr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      --
                                 
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Parametro CPF do operador'
                               ,pr_dsdadant => ''
                               ,pr_dsdadatu => pr_nrcpfope);      
      -- log item
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Tipo Transacao'
                               ,pr_dsdadant => ''
                               ,pr_dsdadatu => vr_tp_transa); 

      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'id titular'
                               ,pr_dsdadant => ''
                               ,pr_dsdadatu => pr_idseqttl);               
      --
      vr_idseqttl := pr_idseqttl;
      va_existe_operador := 0;
      --
      -- Se for tipo de pessoa juridica, buscar  limites do prepos
      -- ou limites do preposto.
      IF rw_crapass.inpessoa IN (2,3) THEN
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'Tipo Pessoa'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => TO_CHAR(rw_crapass.inpessoa)||' Juridica');   
        FOR rw_cr_crapopi in cr_crapopi (pr_cdcooper
                                        ,pr_nrdconta
                                        ,pr_nrcpfope) LOOP

          va_existe_operador := 1;                        
        END LOOP;
                       
        -- Se for preposto
        IF va_existe_operador = 0 THEN
          -- log item
          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                   ,pr_nmdcampo => 'Tipo usuario'
                                   ,pr_dsdadant => ''
                                   ,pr_dsdadatu => 'Preposto');      

          va_nrcpfcgc := null;
          IF pr_nrcpfope IS NULL OR
             pr_nrcpfope <= 0 THEN
            FOR rw_crapsnh2 IN cr_crapsnh2(pr_cdcooper,
                                           pr_nrdconta,
                                           vr_idseqttl) LOOP
              va_nrcpfcgc := rw_crapsnh2.nrcpfcgc;
            END LOOP;     
          END IF;
          -- log item
          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                   ,pr_nmdcampo => 'CPF Preposto'
                                   ,pr_dsdadant => ''
                                   ,pr_dsdadatu => va_nrcpfcgc);  
          -- log item
          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                   ,pr_nmdcampo => 'Data Prox Pagamento'
                                   ,pr_dsdadant => ''
                                   ,pr_dsdadatu => pr_dtmvtopg);              
          -- Se o preposto tem assinatura conjunta, buscar do limite dele
          IF rw_crapass.idastcjt = 1 THEN
            -- buscar limites preposto
            pc_busca_limites_prepo_trans(pr_cdcooper     => pr_cdcooper  --Codigo Cooperativa
                                        ,pr_nrdconta     => pr_nrdconta  --Numero da conta
                                        ,pr_idseqttl     => vr_idseqttl  --Identificador Sequencial titulo
                                        ,pr_nrcpfope	   => NVL(va_nrcpfcgc,pr_nrcpfope)  --Numero do CPF
                                        ,pr_dtmvtopg     => pr_dtmvtopg  --Data do proximo pagamento
                                        ,pr_dsorigem     => pr_dsorigem  --Descricao Origem
                                        ,pr_tab_internet => pr_tab_internet --Tabelas de retorno de horarios limite
                                        ,pr_cdcritic     => vr_cdcritic   --Codigo do erro
                                        ,pr_dscritic     => vr_dscritic); --Descricao do erro;
              --Se ocorreu erro
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;        
          ELSE -- caso nao for assinatura conjunta, buscar do limite da conta
            /* Buscar Limites da internet DA CONTA */
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
              -- A pc_busca_limites vai carregar o valor dos limites da conta, e quando não encontra o valor de limite retorna as mensagens de erro
              -- porém carrega o valor dos limites com 0
              -- A agência 91 (TAA) não realiza validação de limite para as transações, então quando fo agencia 91 e as mensagens de erro que não encontraram 
              -- os limites, elas serão ignoradas e o processo irá continuar
              -- Se for qualquer outra mensagem de erro, ela deverá ser retornada
              IF pr_cdagenci = 91 AND
                 vr_dscritic IN ('Não encontrou limites para a conta.','Senha para conta on-line nao cadastrada.') THEN
                     NULL;
              ELSE
              --Levantar Excecao
              RAISE vr_exc_erro;
              END IF;
            END IF; -- Validar se esá habilitado assinatura conjunta            
        END IF;
        ELSE -- Se for operador
          -- log item
          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                   ,pr_nmdcampo => 'Tipo usuario'
                                   ,pr_dsdadant => ''
                                   ,pr_dsdadatu => 'Operador');
          -- log item
          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                   ,pr_nmdcampo => 'Data Prox Pagamento'
                                   ,pr_dsdadant => ''
                                   ,pr_dsdadatu => pr_dtmvtopg);
                                                                                  
          -- Buscar limites operador do sistema
          pc_busca_limites_opera_trans(pr_cdcooper     => pr_cdcooper  --Codigo Cooperativa
                                      ,pr_nrdconta     => pr_nrdconta  --Numero da conta
                                      ,pr_idseqttl     => vr_idseqttl  --Identificador Sequencial titulo
                                      ,pr_nrcpfope	   => pr_nrcpfope  --Numero do CPF
                                      ,pr_dtmvtopg     => pr_dtmvtopg  --Data do proximo pagamento
                                      ,pr_dsorigem     => pr_dsorigem  --Descricao Origem
                                      ,pr_tab_internet => pr_tab_internet --Tabelas de retorno de horarios limite
                                      ,pr_cdcritic     => vr_cdcritic   --Codigo do erro
                                      ,pr_dscritic     => vr_dscritic); --Descricao do erro;

          --Se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;        
      END IF;
      ELSE  
        -- Log item 
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'Tipo Pessoa'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => 'Fisica');
        -- log item
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'Data Prox Pagamento'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => pr_dtmvtopg);        
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
          -- A pc_busca_limites vai carregar o valor dos limites da conta, e quando não encontra o valor de limite retorna as mensagens de erro
          -- porém carrega o valor dos limites com 0
          -- A agência 91 (TAA) não realiza validação de limite para as transações, então quando fo agencia 91 e as mensagens de erro que não encontraram 
          -- os limites, elas serão ignoradas e o processo irá continuar
          -- Se for qualquer outra mensagem de erro, ela deverá ser retornada
          IF pr_cdagenci = 91 AND
             vr_dscritic IN ('Não encontrou limites para a conta.','Senha para conta on-line nao cadastrada.') THEN
                 NULL;
          ELSE
        --Levantar Excecao
        RAISE vr_exc_erro;
          END IF;
        END IF; -- Validar se esá habilitado assinatura conjunta                                      

      END IF;


      /** Obtem limites do titular **/
      IF NOT pr_tab_internet.EXISTS(vr_idseqttl) THEN
        vr_cdcritic:= 0;
        vr_dscritic:= 'Registro de limite nao encontrado.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --

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
          --Pagamento / DARF/DAS/FGTS/DAE
          IF pr_tpoperac IN(2,10,12,13) THEN
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

      -- LOG dos limites
      -- log item
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Saldo Dispon'
                               ,pr_dsdadant => ''
                               ,pr_dsdadatu => vr_vldspptl); 
      -- log item
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Saldo Todos Titulares'
                               ,pr_dsdadant => ''
                               ,pr_dsdadatu => vr_vldspttl); 
      -- log item
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Limite Diario'
                               ,pr_dsdadant => ''
                               ,pr_dsdadatu => vr_vllimptl); 
      -- log item
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Limite Para Internet'
                               ,pr_dsdadant => ''
                               ,pr_dsdadatu => vr_vllimttl); 
      -- log item
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Limite Ope Coop'
                               ,pr_dsdadant => ''
                               ,pr_dsdadatu => vr_vllimcop);                                
                                                                                                                            
      --Se o limite estiver zerado
      IF vr_vllimcop = 0  THEN
        vr_cdcritic:= 0;
        vr_dscritic:= 'Este servico nao esta habilitado. Duvidas entre em contato com a cooperativa.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      /*Buscar limite da conta para validar quando conta PJ*/
      /* Buscar Limites da internet DA CONTA */
      pc_busca_limites (pr_cdcooper     => pr_cdcooper  --Codigo Cooperativa
                       ,pr_nrdconta     => pr_nrdconta  --Numero da conta
                       ,pr_idseqttl     => vr_idseqttl  --Identificador Sequencial titulo
                       ,pr_flglimdp     => TRUE         --Indicador limite deposito
                       ,pr_dtmvtopg     => pr_dtmvtopg  --Data do proximo pagamento
                       ,pr_flgctrag     => pr_flgctrag  --Indicador validacoes
                       ,pr_dsorigem     => pr_dsorigem  --Descricao Origem
                       ,pr_tab_internet => tab_limite_conta --Tabelas de retorno de horarios limite
                       ,pr_cdcritic     => vr_cdcritic   --Codigo do erro
                       ,pr_dscritic     => vr_dscritic); --Descricao do erro;      
	    
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        -- A pc_busca_limites vai carregar o valor dos limites da conta, e quando não encontra o valor de limite retorna as mensagens de erro
        -- porém carrega o valor dos limites com 0
        -- A agência 91 (TAA) não realiza validação de limite para as transações, então quando fo agencia 91 e as mensagens de erro que não encontraram 
        -- os limites, elas serão ignoradas e o processo irá continuar
        -- Se for qualquer outra mensagem de erro, ela deverá ser retornada
        IF pr_cdagenci = 91 AND
           vr_dscritic IN ('Não encontrou limites para a conta.','Senha para conta on-line nao cadastrada.') THEN
               NULL;
        ELSE
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF; 
      END IF; 
      
      vr_vldspptl_conta := 0;
      
      IF pr_tpoperac = 6 THEN /* VR Boleto */
        --Saldo todos os titulares
        vr_vldspptl_conta:= tab_limite_conta(vr_idseqttl).vllimvrb;
      ELSE
        IF pr_tpoperac = 4 THEN /* TED */
          --Saldo primeiro titular
          vr_vldspptl_conta:= tab_limite_conta(vr_idseqttl).vldspted;
        ELSIF rw_crapass.inpessoa = 1 THEN /* Pessoa Fisica */
          --Saldo primeiro titular
          vr_vldspptl_conta:= tab_limite_conta(vr_idseqttl).vldspweb;
        ELSIF rw_crapass.inpessoa > 1 THEN /* Pessoa Juridica */
          --Pagamento, DARF/DAS, FGTS, DAE
          IF pr_tpoperac IN (2,10,12,13) THEN
            --Saldo primeiro titular
            vr_vldspptl_conta:= tab_limite_conta(vr_idseqttl).vldsppgo;
          ELSE  /* Transferencia */
            --Saldo primeiro titular
            vr_vldspptl_conta:= tab_limite_conta(vr_idseqttl).vldsptrf;
          END IF;
        END IF;
      END IF;      

      /** Obtem limites do primeiro titular se for pessoa fisica **/
      IF rw_crapass.inpessoa = 1 AND pr_idseqttl > 1 THEN
        IF pr_tab_internet.COUNT = 0 THEN
          IF pr_cdagenci <> 91 THEN -- PA 91 - ATM: não valida limite 
          vr_cdcritic:= 0;
          vr_dscritic:= 'Limite para internet nao cadastrado. Entre em contato com seu PA.';
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;

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
            --Pagamento, DARF/DAS, FGTS, DAE
            IF pr_tpoperac IN (2,10,12,13) THEN
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
      IF (vr_vllimptl = 0 OR vr_vllimttl = 0) AND rw_crapass.inpessoa = 1 THEN
        IF pr_cdagenci <> 91 THEN -- PA 91 - ATM: não valida limite 
        vr_cdcritic:= 0;
        vr_dscritic:= 'Limite para internet nao cadastrado. Entre em contato com seu PA.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      END IF;

			IF pr_tpoperac IN (10,12,13) AND -- DARF/DAS,FGTS,DAE 
				 pr_tab_limite(pr_tab_limite.FIRST).iddiauti = 2 THEN
				 	pr_tab_limite(pr_tab_limite.FIRST).idesthor := 1;
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
        IF vr_datdodia >= to_date(vr_dsblqage,'DD/MM/YYYY') AND rw_craptco.cdcopant NOT IN (4,15,17) THEN
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
                                               ,pr_feriado  => TRUE        --> Nao considera feriados
                                               ,pr_excultdia => FALSE);    --> Desconsidera 31/12 com dia útil
      --Se for transferencia ou ted
      IF pr_tpoperac IN (1,4,5) THEN
        
        /** Data do agendamento nao pode ser o ultimo dia util do ano **/
        IF pr_idagenda = 2  AND
           pr_tpoperac <> 4 AND 
           pr_dtmvtopg > vr_dtdialim THEN
           
          vr_dscritic := 'Não é possível efetuar agendamentos para este dia.';
          vr_cdcritic:= 0;
          
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        
        IF pr_idagenda = 1 AND
           pr_tpoperac = 4 AND 
           pr_tab_limite(pr_tab_limite.FIRST).iddiauti = 2 THEN
           
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
              vr_dscritic := 'Problema ao encontrar agencia destino';
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
              vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic|| ' Conta: '||pr_nrctatrf;
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
                 --vr_dscritic := 'Conta destino nao habilitada  para receber valores da transferencia.';
                 vr_dscritic := '1-Antes de realizar essa transferencia, e necessario ativar a conta do favorecido pela Conta Online.';
                 --Levantar Excecao
                 RAISE vr_exc_erro;
               END IF;

            END IF;
      
		  -- Nao permitir transf. intercooperativa para contas da Transulcred, durante e apos a migracao
          IF pr_tpoperac IN (5) AND vr_datdodia >= to_date('31/12/2016','dd/mm/RRRR') AND
             vr_cdcopctl = 17 THEN						  
              vr_cdcritic := 0;
              --vr_dscritic := 'Conta destino nao habilitada para receber valores da transferencia.';
              vr_dscritic := '2-Antes de realizar essa transferencia, e necessario ativar a conta do favorecido pela Conta Online';
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;
      
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
            --vr_dscritic:= 'Conta destino nao habilitada para receber valores da transferencia.';
            vr_dscritic := '3-Antes de realizar essa transferencia, e necessario ativar a conta do favorecido pela Conta Online';
            
            --Fechar Cursor
            CLOSE cr_crapcti;
           
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
          
          --Fechar Cursor
          CLOSE cr_crapcti;

        ELSE
          OPEN cr_crapban (pr_cddbanco => pr_cddbanco);
          
          FETCH cr_crapban INTO rw_crapban;
          
          --Se nao encontrou o banco da conta destino
          IF cr_crapban%NOTFOUND THEN  
            vr_cdcritic:= 0;
            vr_dscritic:= 'Banco da conta destino esta invalido.';
            
            --Fechar Cursor
            CLOSE cr_crapban;
           
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
          
          --Fechar Cursor
          CLOSE cr_crapban;
      
          /** Verifica se a conta que ira receber o valor esta   **/
          /** cadastrada para a conta que ira transferir o valor **/
          OPEN cr_crapcti (pr_cdcooper => pr_cdcooper
                          ,pr_cddbanco => pr_cddbanco
                          ,pr_cdageban => pr_cdageban
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrctatrf => pr_nrctatrf);
                          
          --Posicionar no primeiro registro
          FETCH cr_crapcti INTO rw_crapcti;
          
          /*Quando for efetivação de agendamentos de TED (Processo automatizado através do pc_crps705) não
            deverá ser validado o favorecido, independente dele estar ativou ou não a TED deve ser efetivada.
            SD 563147 */
          IF cr_crapcti%FOUND AND pr_nmdatela <> 'CRPS705' AND rw_crapcti.insitcta <> 2 THEN  /** Ativa **/
            vr_cdcritic:= 0;
            --vr_dscritic:= 'Conta destino nao habilitada para receber valores da transferencia.';
			vr_dscritic := 'Antes de realizar essa transferencia, e necessario ativar a conta do favorecido pela Conta Online';
            
            --Fechar Cursor
            CLOSE cr_crapcti;
           
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
          
          --Fechar Cursor
          CLOSE cr_crapcti;      

        END IF;
      ELSE
        IF pr_tpoperac IN (2,10,12,13) THEN  /** Pagamento, DARF/DAS, FGTS, DAE **/

          IF pr_tpoperac IN (10,12,13) AND pr_idagenda = 1 AND 
             pr_tab_limite(pr_tab_limite.FIRST).iddiauti = 2 THEN
           
            vr_cdcritic := 0;
            vr_dscritic := 'O pagamento de tributo federal deve ser efetuado em dias úteis.';
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;

          /** Critica se data do pagamento for no ultimo dia util do ano **/
          IF (pr_idagenda = 1 AND pr_dtmvtolt > vr_dtdialim) OR
             (pr_idagenda > 1 AND pr_dtmvtopg > vr_dtdialim) THEN
            vr_cdcritic:= 0;
            IF pr_idagenda = 1 THEN
              vr_dscritic:= 'Não é possível efetuar pagamentos neste dia.';
            ELSE
              vr_dscritic:= 'Não é possível efetuar agendamentos para este dia.';
            END IF;
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
        END IF;
      END IF;
      -- log item
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Valor da Transacao'
                               ,pr_dsdadant => ''
                               ,pr_dsdadatu => pr_vllanmto);                                
      --Se o valor da transacao for zero
      IF pr_vllanmto = 0 THEN
        vr_cdcritic:= 0;
        vr_dscritic:= 'O valor da transacao nao pode ser 0 (zero).';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      
      /** Verifica se pode movimentar o valor desejado - limite diario **/
      IF  pr_vllanmto > vr_vllimptl AND rw_crapass.inpessoa = 1 THEN
        IF pr_cdagenci <> 91 THEN -- PA 91 - ATM: não valida limite 
        vr_cdcritic:= 0;
        vr_dscritic:= 'O saldo do seu limite diario e insuficiente para ' || vr_dsdmensa || '.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      END IF;
      
      /** Verifica se pode movimentar o valor desejado - limite cooperativa **/
      IF  pr_vllanmto > vr_vllimcop AND pr_tpoperac = 6 THEN
        IF pr_cdagenci <> 91 THEN -- PA 91 - ATM: não valida limite 
        vr_cdcritic:= 0;
        vr_dscritic:= 'Valor da operacao superior ao limite da cooperativa.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      END IF;
      -- projeto 397
      /** Verifica se titular tem limite para movimentar o valor **/
      IF rw_crapass.inpessoa = 1 AND pr_idseqttl > 1 AND pr_vllanmto > vr_vllimttl THEN
        IF pr_cdagenci <> 91 THEN -- PA 91 - ATM: não valida limite 
        vr_cdcritic:= 0;
        vr_dscritic:= 'O saldo do seu limite diario e insuficiente para ' || vr_dsdmensa || '.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      END IF;
      
      /** Verifica se pode movimentar em relacao ao que ja foi usado **/
      /** no dia por todos os titulares 
       **/
      IF pr_vllanmto > vr_vldspptl AND rw_crapass.inpessoa = 1 THEN
        IF pr_cdagenci <> 91 THEN -- PA 91 - ATM: não valida limite 
        vr_cdcritic:= 0;
        vr_dscritic:= 'O saldo do seu limite diario e insuficiente para ' || vr_dsdmensa || '.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      END IF;
      
      vr_operador_conta := 0;
      FOR rw_cr_crapopi2 in cr_crapopi2(pr_cdcooper
                                      ,pr_nrdconta) LOOP

        vr_operador_conta := 1;                        
      END LOOP;
      -- SE NAO FOR ASSINATURA E NAO TIVER OPERADOR E ULTRAPSSOU O LIMITE DA CONTA, MOSTRAR CRITICA
      IF rw_crapass.idastcjt = 0 AND vr_operador_conta = 0 AND
        pr_vllanmto > vr_vldspptl AND rw_crapass.inpessoa IN (2,3) THEN
        IF pr_cdagenci <> 91 THEN -- PA 91 - ATM: não valida limite 
        vr_cdcritic:= 0;
        vr_dscritic:= 'O saldo do seu limite diario e insuficiente para ' || vr_dsdmensa || '.';
        RAISE vr_exc_erro;
        END IF;
      ELSIF rw_crapass.idastcjt = 0 AND pr_nrcpfope <= 0 AND
        pr_vllanmto > vr_vldspptl AND rw_crapass.inpessoa IN (2,3) THEN
        IF pr_cdagenci <> 91 THEN -- PA 91 - ATM: não valida limite 
        vr_cdcritic:= 0;
        vr_dscritic:= 'O saldo do seu limite diario e insuficiente para ' || vr_dsdmensa || '.';        
        RAISE vr_exc_erro;
        END IF;
      -- Se o valor do lançamento for maior que o limite da conta, nao permitir 
      ELSIF pr_vllanmto > vr_vldspptl_conta and rw_crapass.inpessoa IN (2,3) THEN
        IF pr_cdagenci <> 91 THEN -- PA 91 - ATM: não valida limite 
        vr_cdcritic:= 0;
        vr_dscritic:= 'O saldo do seu limite diario e insuficiente para ' || vr_dsdmensa || '.';        
        RAISE vr_exc_erro;
        END IF;
      ELSIF pr_vllanmto > vr_vldspptl AND rw_crapass.inpessoa IN (2,3) THEN
        pr_assin_conjunta := 1; -- Deverá gerar fluxo de aprovação assinatura conjunta
      END IF;
      
      /** Verifica se pode movimentar em relacao ao que ja foi usado **/
      /** no dia pelo titular                                        **/
      IF rw_crapass.inpessoa = 1 AND pr_idseqttl > 1 AND pr_vllanmto > vr_vldspttl THEN
        IF pr_cdagenci <> 91 THEN -- PA 91 - ATM: não valida limite 
        vr_cdcritic:= 0;
        vr_dscritic:= 'O saldo do seu limite diario e insuficiente para ' || vr_dsdmensa || '.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      END IF;
      
      IF  pr_idagenda = 1 THEN
        IF (pr_nrcpfope <> 0 AND pr_assin_conjunta <> 1) OR 
           (pr_nrcpfope = 0) THEN
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
      
          IF vr_tab_saldo.Count = 0 THEN
            --Montar mensagem erro
            vr_cdcritic:= 0;
            vr_dscritic:= 'Nao foi possivel consultar o saldo para a operacao.';
            --Levantar Excecao
            RAISE vr_exc_erro;
          ELSE
            --Total disponivel recebe valor disponivel + limite credito
            vr_vlsldisp:= nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vlsddisp,0) + nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vllimcre,0);
            -- log item
            gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Saldo disp mais Limite Credito'
                               ,pr_dsdadant => ''
                               ,pr_dsdadatu => vr_vlsldisp);                                            
			      --Se o saldo nao for suficiente
            IF pr_vllanmto > vr_vlsldisp THEN
              --Montar mensagem erro
              vr_cdcritic:= 0;
              vr_dscritic:= 'Nao ha saldo suficiente para a operacao.';
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;
          END IF;      
        END IF;
        /* Nao validar saldo para operadores na internet */
        IF pr_nrcpfope = 0 THEN
         
            /** Obtem valor da tarifa TED **/
            IF pr_tpoperac = 4 AND
               pr_flgexage = 0 THEN
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
                   
        ELSIF pr_tpoperac = 4 AND
              pr_flgexage = 0 THEN
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
        END IF;        
        
      ELSIF pr_idagenda >= 2  THEN /** Agendamento normal e recorrente **/

        IF pr_tpoperac = 4 THEN
          --Buscar tarifa de TED          
          CXON0020.pc_busca_tarifa_ted(pr_cdcooper => pr_cdcooper --Codigo Cooperativa
                                     , pr_cdagenci => 90          --Codigo Agencia
                                     , pr_nrdconta => pr_nrdconta --Número da Conta
                                     , pr_vllanmto => pr_vllanmto --Valor Lançamento
                                     , pr_vltarifa => vr_vltarifa --Valor Tarifa
                                     , pr_cdhistor => vr_cdhistor --Histórico da tarifa
                                     , pr_cdhisest => vr_cdhisest --Histórico estorno
                                     , pr_cdfvlcop => vr_cdfvlcop --Código Filial Cooperativa
                                     , pr_cdcritic => vr_cdcritic --Código do erro
                                     , pr_dscritic => vr_dscritic); --Descricao do erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

          --Somar valor tarifa no lancamento
          pr_vllanmto := nvl(pr_vllanmto,0) + Nvl(vr_vltarifa,0);
        END IF;        

        vr_cdcritic := NULL;
        vr_dscritic := NULL;
        -- Verifica se data de agendamento e uma data futura
        IF pr_tpoperac IN (10,12,13) THEN --DARF/DAS, FGTS, DAE   
          
          IF  pr_dtmvtopg <= Trunc(vr_datdodia) THEN 
            --Montar mensagem erro
            vr_cdcritic:= 0;            
            --Data mínima obtida de dtmvtocd se não for dia útil
            IF pr_tab_limite(pr_tab_limite.FIRST).iddiauti = 2 THEN 
               vr_dscritic:= 'A data mínima para agendamento deve ser '||To_Char(rw_crapdat.dtmvtocd,'DD/MM/YYYY')||'.';
            ELSE
               vr_dscritic:= 'A data mínima para agendamento deve ser '||To_Char(rw_crapdat.dtmvtopr,'DD/MM/YYYY')||'.';
            END IF;
          --  ELSE
          END IF;
          
        ELSE
          
          IF pr_dtmvtopg < vr_datdodia THEN -- Se for agendamento para data retroativa
          --Montar mensagem erro
          vr_cdcritic:= 0;
          vr_dscritic:= 'Agendamento deve ser feito para uma data futura.';
          ELSIF pr_dtmvtopg = vr_datdodia AND -- Se for agendamento para hoje
                pr_assin_conjunta <> 1 THEN -- e não for transacao pendente
            -- Projeto 475 - Sprint C (Req14) - Tratamento para permitir agendar uma TED antes da abertura da sua grade 
            -- Verificar se estourou o limite de grade para TED
            IF sspb0003.fn_valida_horario_ted (pr_cdcooper) AND pr_tpoperac = 4 THEN
               -- Dentro do limite (antes da abertura da grade)
               NULL;              
            ELSE
            --Montar mensagem erro
            vr_cdcritic:= 0;
            vr_dscritic:= 'Não é possível agendar para a data de hoje. Utilize a opção "Nesta Data".';
          END IF;
                        
          END IF;
        
        
          END IF;
        
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
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
          
          
          IF pr_tpoperac = 4 THEN
            --Dia limite recebe dia + quantidade de meses máximo para agendamento
            vr_dtdialim:= ADD_MONTHS(vr_datdodia,pr_tab_limite(pr_tab_limite.FIRST).qtmesfut);
          ELSE  
            --Dia limite recebe dia + quantidade dias lancamento
            vr_dtdialim:= vr_datdodia + rw_crapage.qtddaglf;
          END IF;

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
          
          IF pr_tpoperac = 4 THEN
            --Dia limite recebe dia + quantidade de meses máximo para agendamento
            vr_dtdialim:= ADD_MONTHS(vr_datdodia,pr_tab_limite(pr_tab_limite.FIRST).qtmesrec);
          ELSE  
            -- Dia limite recebe dia + quantidade dias limite para o primeiro lancamento
            vr_dtdialim := ADD_MONTHS(vr_datdodia,120); -- 10 anos
          END IF;
        
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
         
         btch0001.pc_log_internal_exception(pr_cdcooper => pr_cdcooper);
         
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
  --  Data     : maio/2015.                   Ultima atualizacao: 19/07/2019
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Chamada para ser utilizada no Progress -
  --             Procedure para validar limites para transacoes (Transf./Pag./Cob.)
  --
  -- Alteracoes: 24/09/2015 - Realizado a inclusão do pr_nmdatela (Adriano - SD 328034).
  --
  --             19/07/2019 - Problemas no loop da pltable pr_tab_internet por causa do acesso
  --                          a conta pelo 3 titular (Tiago - INC0019543)
  ---------------------------------------------------------------------------------------------------------------
    -------------------------> VARIAVEIS <-------------------------
    vr_tab_limite     INET0001.typ_tab_limite;
    vr_tab_internet   INET0001.typ_tab_internet;
    vr_flsgproc       PLS_INTEGER;
    vr_assin_conjunta number(1);
    -- Variaveis de XML 
    vr_xml_temp VARCHAR2(32767);
    vr_nrcpfope crapopi.nrcpfope%TYPE;
    
  BEGIN
    vr_nrcpfope := pr_nrcpfope;
    
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
                         ,pr_dscritic     => pr_dscritic
                         ,pr_assin_conjunta => vr_assin_conjunta); 
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
    
      IF NOT vr_tab_internet.exists(vr_contador) THEN
         CONTINUE;
      END IF;
    
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
      btch0001.pc_log_internal_exception(pr_cdcooper => pr_cdcooper);
  END pc_verifica_operacao_prog;


  /* Procedure para consulta de contas de trnsf cadastradas */
  PROCEDURE pc_con_contas_cadastradas ( pr_cdcooper IN crapcop.cdcooper%TYPE  -- Codigo Cooperativa
                                       ,pr_cdagenci IN crapage.cdagenci%TYPE  -- Agencia do Associado
                                       ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE  -- Numero caixa
                                       ,pr_cdoperad IN crapope.cdoperad%TYPE  -- Codigo Operador
                                       ,pr_nmdatela IN VARCHAR2
                                       ,pr_idorigem IN INTEGER                                                                              
                                       ,pr_nrdconta IN crapass.nrdconta%TYPE  -- Numero da conta                                       
                                       ,pr_idseqttl IN crapttl.idseqttl%TYPE  -- Identificador Sequencial titulo                                       
                                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  -- Data Movimento
                                       ,pr_tppeslst IN INTEGER
                                       ,pr_intipdif IN INTEGER
                                       ,pr_nmtitula IN VARCHAR2
                                       ,pr_cdcritic OUT INTEGER                --> Código da critica
                                       ,pr_dscritic OUT VARCHAR2               --> Descrição da critica
                                       ,pr_tab_contas_cadastradas OUT typ_tab_contas_cadastradas --> Retorno XML contas cadastradas
                                       ,pr_dsretorn               OUT VARCHAR2) IS -- Descricao do erro
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa : pc_con_contas_cadastradas     Antigo: b1wgen0015.p.consulta-contas-cadastradas
    Sistema  : Procedure para consulta de contas de trnsf cadastradas 
    Sigla    : CRED
    Autor    : Carlos Henrique
    Data     : março/2016.                   Ultima atualizacao: 08/01/2019
  
   Dados referentes ao programa:
  
   Alteracoes: 06/05/2016 - Inclusao do nmsegntl, pesquisa na crapass pelo nome no
                            cr_crapcti e exibicao das contas bloqueadas para a CECRED.
                            (Jaison/Marcos - SUPERO)
  
               25/05/2016 - Ajuste realizados:
                            -> Alterado o index utilizado para montar a tabela de faovericos a fim de 
                               possibilitar a ordenação por nome de favorecido;
                            -> Utilizar rotina genérica para consultar registro da craptab;
                            (Adriano - M117).
  
               20/02/2017 - Ajuste no problema que não filtrava os favorecidos, conforme
                            relatado no chamado 605338. (Kelvin)

			   25/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                crapass, crapttl, crapjur 
							(Adriano - P339).
  
			   08/01/2019 - Ajuste para desconsiderar contas favorecidas que pertecem a uma cooperativa inativa
			                (Adriano - INC0029631).
  
  ---------------------------------------------------------------------------------------------------------------*/
  -------------------------> VARIAVEIS <-------------------------
    
  BEGIN
    DECLARE

    vr_aux_dsoperad VARCHAR2(100);
    vr_aux_dstransa VARCHAR2(100);
    vr_aux_dssitcta VARCHAR2(20);
    vr_aux_inpessoa PLS_INTEGER;
    vr_aux_nmprimtl VARCHAR2(200);
    vr_aux_nmsegntl VARCHAR2(200);
    vr_aux_nrcpfcgc VARCHAR2(20);
    vr_aux_dsctatrf VARCHAR2(20);
    vr_aux_dstipcta VARCHAR2(255);
    vr_aux_nmextbcc VARCHAR2(255);
    vr_aux_nmageban VARCHAR2(50);
    vr_dscritic  VARCHAR2(4000);
    vr_dstextab craptab.dstextab%TYPE;
    
    vr_tab_contas_cadastradas typ_tab_contas_cadastradas;

    vr_index VARCHAR2(210);
    
    CURSOR cr_crapcti (pr_cdcooper IN crapcop.cdcooper%TYPE,
                       pr_nrdconta IN crapass.nrdconta%TYPE,
                       pr_intipdif IN crapcti.intipdif%TYPE,
                       pr_nmtitula IN crapcti.nmtitula%TYPE) IS
    SELECT crapcti.cdcooper
          ,crapcti.nrdconta
          ,crapcti.cdoperad
          ,crapcti.dttransa
          ,crapcti.hrtransa
          ,crapcti.intipdif
          ,crapcti.cdageban
          ,crapcti.nrctatrf
          ,crapcti.nmtitula
          ,crapcti.inpessoa
          ,crapcti.nrcpfcgc
          ,crapcti.intipcta
          ,crapcti.cddbanco
          ,crapcti.nrispbif
          ,crapcti.nrseqcad
          ,crapcti.insitcta
          ,DECODE(crapcti.insitcta, 2, 'Ativa', 'Bloqueada') situacao
     FROM crapcti
    WHERE crapcti.cdcooper = pr_cdcooper
      AND crapcti.nrdconta = pr_nrdconta
      AND (crapcti.insitcta = 2 OR crapcti.insitcta = 3)
      AND crapcti.intipdif = pr_intipdif
      AND (pr_nmtitula IS NULL OR crapcti.intipdif = 1 OR UPPER(crapcti.nmtitula) LIKE '%' || pr_nmtitula || '%');
    rw_crapcti cr_crapcti%ROWTYPE;

    CURSOR cr_crapope (pr_cdcooper IN crapcop.cdcooper%TYPE,
                       pr_cdoperad IN crapcti.cdoperad%TYPE) IS
    SELECT nmoperad
      FROM crapope
     WHERE crapope.cdcooper = pr_cdcooper
       AND UPPER(crapope.cdoperad) = UPPER(pr_cdoperad);
    rw_crapope cr_crapope%ROWTYPE;

    CURSOR cr_crapcop_cdagectl(pr_cdageban IN crapcop.cdagectl%TYPE) IS
    SELECT cdcooper, nmrescop
      FROM crapcop
     WHERE crapcop.cdagectl = pr_cdageban
	   AND crapcop.flgativo = 1;
    rw_crapcop_cdagectl cr_crapcop_cdagectl%ROWTYPE;

    CURSOR cr_crapass (pr_cdcooper IN crapcop.cdcooper%TYPE,
                       pr_nrdconta IN crapcti.nrctatrf%TYPE) IS
    SELECT dtdemiss
          ,inpessoa
          ,nmprimtl
          ,nrcpfcgc
          ,nrdconta
      FROM crapass
     WHERE crapass.cdcooper = pr_cdcooper
       AND crapass.nrdconta = to_number(pr_nrdconta);
    rw_crapass cr_crapass%ROWTYPE;

    CURSOR cr_crapttl (pr_cdcooper IN crapcop.cdcooper%TYPE,
                       pr_nrdconta IN crapass.nrdconta%TYPE,
					   pr_idseqttl IN crapttl.idseqttl%TYPE) IS
    SELECT nmextttl
      FROM crapttl
     WHERE crapttl.cdcooper = pr_cdcooper
       AND crapttl.nrdconta = pr_nrdconta
       AND crapttl.idseqttl = pr_idseqttl;
    rw_crapttl cr_crapttl%ROWTYPE;

    CURSOR cr_crapban (pr_cddbanco IN crapcti.cddbanco%TYPE) IS
    SELECT nmextbcc
      FROM crapban
     WHERE crapban.cdbccxlt = pr_cddbanco;
    rw_crapban cr_crapban%ROWTYPE;

    CURSOR cr_crapban2 (pr_nrispbif IN crapcti.nrispbif%TYPE) IS
    SELECT nmextbcc
      FROM crapban
     WHERE crapban.nrispbif = pr_nrispbif;
    rw_crapban2 cr_crapban2%ROWTYPE;

    CURSOR cr_crapagb (pr_cddbanco IN crapcti.cddbanco%TYPE,
                       pr_cdageban IN crapcti.cdageban%TYPE) IS
    SELECT crapagb.nmageban
      FROM crapagb
     WHERE crapagb.cddbanco = pr_cddbanco
       AND crapagb.cdageban = pr_cdageban;
    rw_crapagb cr_crapagb%ROWTYPE;

    BEGIN
      /* Busca dos favorecidos */
      FOR rw_crapcti IN cr_crapcti (pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_intipdif => pr_intipdif
                                   ,pr_nmtitula => UPPER(TRIM(pr_nmtitula))) LOOP
        /* Busca do operador */
        OPEN cr_crapope(pr_cdcooper => rw_crapcti.cdcooper,
                        pr_cdoperad => rw_crapcti.cdoperad);
       
        FETCH cr_crapope INTO rw_crapope;

        vr_aux_dsoperad := rw_crapcti.cdoperad || ' - ';
        
        IF cr_crapope%FOUND THEN
          vr_aux_dsoperad := vr_aux_dsoperad || rw_crapope.nmoperad;
        ELSE
          vr_aux_dsoperad := vr_aux_dsoperad || 'NAO CADASTRADO';
        END IF;
        
        CLOSE cr_crapope;
              
        vr_aux_dstransa := to_char(rw_crapcti.dttransa,'dd/mm/RRRR') ||
                           ' - ' || TO_DATE(rw_crapcti.hrtransa,'SSSSS');
                           
        vr_aux_dssitcta := rw_crapcti.situacao;
        vr_aux_nmsegntl := ' ';
        
        /* COOPERATIVA */
        IF rw_crapcti.intipdif = 1 THEN 
          
          /* Busca a cooperativa destino */
          OPEN cr_crapcop_cdagectl(pr_cdageban => rw_crapcti.cdageban);
          
          FETCH cr_crapcop_cdagectl INTO rw_crapcop_cdagectl;
          
          IF cr_crapcop_cdagectl%NOTFOUND THEN
            CLOSE cr_crapcop_cdagectl;
            continue;
          END IF;
          
          CLOSE cr_crapcop_cdagectl;
          
          /* Busca cadastro associado no destino */
          OPEN cr_crapass(pr_cdcooper => rw_crapcop_cdagectl.cdcooper,
                          pr_nrdconta => rw_crapcti.nrctatrf);
                          
          FETCH cr_crapass INTO rw_crapass;
          
          IF cr_crapass%NOTFOUND OR 
             (cr_crapass%FOUND AND rw_crapass.dtdemiss IS NOT NULL) THEN
            CLOSE cr_crapass;
            continue;
          END IF;

          -- Verificar quais contas deve carregar (0 para todas)
          IF (pr_tppeslst = 1 AND rw_crapass.inpessoa > 1) OR
             (pr_tppeslst = 2 AND rw_crapass.inpessoa = 1) THEN
             CLOSE cr_crapass;
             continue;
          END IF;  
          
          CLOSE cr_crapass;
          
          IF rw_crapass.inpessoa > 2 THEN
            vr_aux_inpessoa := 2;
          ELSE
            vr_aux_inpessoa := rw_crapass.inpessoa;
          END IF;
          
          /* Para PF */
          IF rw_crapass.inpessoa = 1 THEN
            
            OPEN cr_crapttl(pr_cdcooper => rw_crapcop_cdagectl.cdcooper,
                            pr_nrdconta => to_number(rw_crapcti.nrctatrf),
							pr_idseqttl => 1);
                            
            FETCH cr_crapttl INTO rw_crapttl;
            
            IF cr_crapttl%FOUND THEN
              vr_aux_nmprimtl := rw_crapttl.nmextttl;
            ELSE
              vr_aux_nmprimtl := rw_crapass.nmprimtl;
            END IF;
            
            CLOSE cr_crapttl;
            
			OPEN cr_crapttl(pr_cdcooper => rw_crapcop_cdagectl.cdcooper,
                            pr_nrdconta => to_number(rw_crapcti.nrctatrf),
							pr_idseqttl => 2);
                            
            FETCH cr_crapttl INTO rw_crapttl;
            
            IF cr_crapttl%FOUND THEN
              vr_aux_nmsegntl := rw_crapttl.nmextttl;
            END IF;
            
            CLOSE cr_crapttl;
            
            vr_aux_nmprimtl := vr_aux_nmprimtl || ' ' || vr_aux_nmsegntl;
            vr_aux_nrcpfcgc := gene0002.fn_mask_cpf_cnpj(rw_crapass.nrcpfcgc, 1);
            
          ELSE          
            vr_aux_nmprimtl := rw_crapass.nmprimtl;
            vr_aux_nrcpfcgc := gene0002.fn_mask_cpf_cnpj(rw_crapass.nrcpfcgc, 2);
          END IF;
          
          vr_aux_dsctatrf := to_char(rw_crapass.nrdconta);
          vr_aux_dstipcta := '';
          
          IF TRIM(pr_nmtitula) IS NOT NULL AND
            vr_aux_nmprimtl NOT LIKE '%' || pr_nmtitula || '%' THEN              
            CONTINUE;
          END IF;
          
        ELSE /* Outras instituições financeiras */
          
          vr_aux_nmprimtl := rw_crapcti.nmtitula;
          vr_aux_inpessoa := rw_crapcti.inpessoa;
          
          IF vr_aux_inpessoa = 1 THEN
            vr_aux_nrcpfcgc := gene0002.fn_mask_cpf_cnpj(rw_crapcti.nrcpfcgc,1);
          ELSE
            vr_aux_nrcpfcgc := gene0002.fn_mask_cpf_cnpj(rw_crapcti.nrcpfcgc,2);
          END IF;
          
          vr_aux_dsctatrf := to_char(rw_crapcti.nrctatrf);
          
          vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                   ,pr_nmsistem => 'CRED'
                                                   ,pr_tptabela => 'GENERI'
                                                   ,pr_cdempres => 00
                                                   ,pr_cdacesso => 'TPCTACRTED'
                                                   ,pr_tpregist => rw_crapcti.intipcta);

          IF vr_dstextab IS NULL THEN
            vr_aux_dstipcta := 'NAO CADASTRADO';
          ELSE
            vr_aux_dstipcta := upper(vr_dstextab);
          END IF;
          
        END IF;
        
        OPEN cr_crapban (pr_cddbanco => rw_crapcti.cddbanco);
        
        FETCH cr_crapban INTO rw_crapban;
        
        IF cr_crapban%FOUND THEN
          vr_aux_nmextbcc := replace(upper(trim(rw_crapban.nmextbcc)),'&','e');
          CLOSE cr_crapban;
        ELSE
          CLOSE cr_crapban;
          
          OPEN cr_crapban2 (pr_nrispbif => rw_crapcti.nrispbif);
          
          FETCH cr_crapban2 INTO rw_crapban2;        
          
          IF cr_crapban2%FOUND THEN
            vr_aux_nmextbcc := replace(upper(trim(rw_crapban2.nmextbcc)),'&','e');
            CLOSE cr_crapban2;
          ELSE
            vr_aux_nmextbcc := 'NAO CADASTRADO';
            CLOSE cr_crapban2;
          END IF;
        END IF;

        OPEN cr_crapagb (pr_cddbanco => rw_crapcti.cddbanco,
                         pr_cdageban => rw_crapcti.cdageban);
                         
        FETCH cr_crapagb INTO rw_crapagb;
        
        IF cr_crapagb%FOUND THEN
          vr_aux_nmageban := gene0007.fn_caract_acento(rw_crapagb.nmageban, 1);
        ELSE
          vr_aux_nmageban := 'AGENCIA NAO CADASTRADA';
        END IF;

        CLOSE cr_crapagb;
        
        vr_index := RPAD(vr_aux_nmprimtl,200,' ') || 
                    to_char(rw_crapcti.nrseqcad,'fm0000000000');

        vr_tab_contas_cadastradas(vr_index).intipdif := rw_crapcti.intipdif;
        vr_tab_contas_cadastradas(vr_index).cddbanco := rw_crapcti.cddbanco;
        vr_tab_contas_cadastradas(vr_index).nmextbcc := vr_aux_nmextbcc;
        vr_tab_contas_cadastradas(vr_index).cdageban := rw_crapcti.cdageban;
        vr_tab_contas_cadastradas(vr_index).nrctatrf := rw_crapcti.nrctatrf;
        vr_tab_contas_cadastradas(vr_index).nmtitula := vr_aux_nmprimtl;
        vr_tab_contas_cadastradas(vr_index).nmtitul2 := vr_aux_nmsegntl;
        vr_tab_contas_cadastradas(vr_index).nrcpfcgc := rw_crapcti.nrcpfcgc;
        vr_tab_contas_cadastradas(vr_index).dscpfcgc := vr_aux_nrcpfcgc;
        vr_tab_contas_cadastradas(vr_index).dstransa := vr_aux_dstransa;
        vr_tab_contas_cadastradas(vr_index).dsoperad := vr_aux_dsoperad;
        vr_tab_contas_cadastradas(vr_index).insitcta := rw_crapcti.insitcta;
        vr_tab_contas_cadastradas(vr_index).dssitcta := vr_aux_dssitcta;
        vr_tab_contas_cadastradas(vr_index).inpessoa := vr_aux_inpessoa;
        vr_tab_contas_cadastradas(vr_index).dsctatrf := vr_aux_dsctatrf;
        vr_tab_contas_cadastradas(vr_index).nrseqcad := rw_crapcti.nrseqcad;
        vr_tab_contas_cadastradas(vr_index).dstipcta := vr_aux_dstipcta;
        vr_tab_contas_cadastradas(vr_index).intipcta := rw_crapcti.intipcta;
        vr_tab_contas_cadastradas(vr_index).nrispbif := rw_crapcti.nrispbif;
        vr_tab_contas_cadastradas(vr_index).nmageban := vr_aux_nmageban;

        IF rw_crapcti.intipdif = 1 THEN
          vr_tab_contas_cadastradas(vr_index).dsageban := to_char(rw_crapcti.cdageban,'0000') || 
          ' - ' || rw_crapcop_cdagectl.nmrescop; 
        ELSE
          vr_tab_contas_cadastradas(vr_index).dsageban := vr_aux_nmextbcc;
        END IF;

      END LOOP;

      pr_tab_contas_cadastradas := vr_tab_contas_cadastradas;
      
      pr_dsretorn := 'OK';
    
    EXCEPTION
      WHEN OTHERS THEN

        btch0001.pc_log_internal_exception(pr_cdcooper);
      
        pr_cdcritic := 0;
        pr_dscritic := 'Nao foi possivel consultar as contas cadastradas. Tente novamente ou contacte seu PA';
        pr_dsretorn := 'NOK';
        
    END;
    
  END pc_con_contas_cadastradas;
 
  /* Procedure para retornar finalidades da TED [consultados na CRAPTAB] */
  PROCEDURE pc_consulta_finalidades (pr_cdcooper IN crapcop.cdcooper%TYPE  -- Codigo Cooperativa
                                    ,pr_cdagenci IN crapage.cdagenci%TYPE  -- Agencia do Associado
                                    ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE  -- Numero caixa
                                    ,pr_cdcritic OUT INTEGER               -- Código do erro
                                    ,pr_dscritic OUT VARCHAR2              -- Descrição do erro
                                    ,pr_tab_finalidades OUT typ_tab_finalidades --> Retorno XML finalidades
                                    ,pr_dsretorn        OUT VARCHAR2) IS   --> Descricao do erro
    
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_consulta_finalidades     Antigo: b1wgen0015.p.consulta-finalidades
  --  Sistema  : Procedure para retornar finalidades da TED [consultados na CRAPTAB]   
  --  Sigla    : CRED
  --  Autor    : Carlos Henrique
  --  Data     : março/2016.                   Ultima atualizacao: 25/06/2016 
  -- 
  --
  -- Alteracoes: 25/05/2016 - Ajuste efetuados:
  --                          -> Eliminado variaveis não utilizadas;
  --                          -> Ajuste na letirua de tabelas para melhorar a performance;
  --                          (Adriano - M117).
  --
  ---------------------------------------------------------------------------------------------------------------
  -------------------------> VARIAVEIS <-------------------------    
  BEGIN
    DECLARE

    vr_tab_finalidades typ_tab_finalidades;
    vr_dscritic  VARCHAR2(4000);
    vr_index pls_integer;
    vr_exc_erro EXCEPTION;
    vr_cdcritic INTEGER;

    CURSOR cr_craptab_finteds(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT tpregist
          ,dstextab
     FROM craptab
    WHERE craptab.cdcooper = pr_cdcooper
      AND UPPER(craptab.nmsistem) = 'CRED'
      AND UPPER(craptab.tptabela) = 'GENERI'
      AND craptab.cdempres = 00
      AND UPPER(craptab.cdacesso) = 'FINTRFTEDS';
    rw_craptab_finteds cr_craptab_finteds%ROWTYPE;
    
    BEGIN

      --> DESCARREGAR TEMPTABLE DE pr_tab_finalidades PARA O CLOB <---
      vr_index := 0;
      
      FOR rw_craptab_finteds IN cr_craptab_finteds (pr_cdcooper => pr_cdcooper) LOOP
        
        vr_index := vr_index + 1;
        vr_tab_finalidades(vr_index).cdfinali := rw_craptab_finteds.tpregist;
        vr_tab_finalidades(vr_index).dsfinali := upper(rw_craptab_finteds.dstextab);

        IF (rw_craptab_finteds.tpregist = 10) THEN
          vr_tab_finalidades(vr_index).flgselec := 1;
        ELSE
          vr_tab_finalidades(vr_index).flgselec := 0;
        END IF;
        
      END LOOP;
      
      IF vr_index = 0 THEN
        
        vr_dscritic := 'Finalidades nao cadastradas';
        RAISE vr_exc_erro;
        
      END IF;   
      
      pr_tab_finalidades := vr_tab_finalidades;
      
      pr_dsretorn := 'OK';
    
    EXCEPTION
      WHEN vr_exc_erro THEN
         pr_dsretorn := 'NOK';
        
         IF nvl(vr_cdcritic,0) = 0 and trim(vr_dscritic) is null then
           vr_dscritic:= 'Nao foi possivel consultar as finalidades.';
         END IF;
        
         pr_cdcritic:= vr_cdcritic;
         pr_dscritic:= vr_dscritic;
        
      WHEN OTHERS THEN
        
        btch0001.pc_log_internal_exception(pr_cdcooper);
        
        pr_cdcritic := 0;
        pr_dscritic := 'Nao foi possivel consultar as finalidades. Tente novamente ou contacte seu PA';
        pr_dsretorn := 'NOK';
        
    END;
    
  END pc_consulta_finalidades;
  --
  PROCEDURE pc_verifica_limite_ope_prog (pr_cdcooper     IN crapcop.cdcooper%type  --C¿digo Cooperativa
                                        ,pr_nrdconta     IN crapass.nrdconta%TYPE  --Numero da conta
                                        ,pr_idseqttl     IN crapttl.idseqttl%TYPE  --Identificador Sequencial titulo
                                        ,pr_nrcpfope     IN crapopi.nrcpfope%TYPE  --Numero do CPF Operador
                                        ,pr_cdoperad     IN crapope.cdoperad%TYPE  --Codigo Operador
                                        ,pr_cddoitem     IN tbgen_trans_pend.cdtransacao_pendente%TYPE -- Cod da transação
                                        ,pr_dtmvtopg     IN crapdat.dtmvtolt%TYPE  --Data do proximo pagamento
                                        ,pr_dsorigem     IN craplau.dsorigem%TYPE  --Descricao Origem
                                        ,pr_msgretor     OUT VARCHAR2                    
                                        ,pr_cdcritic     OUT INTEGER        --Codigo do erro
                                        ,pr_dscritic     OUT VARCHAR2) IS
  /*---------------------------------------------------------------------------------------------------------------
   Programa : pc_verifica_limite_ope_prog           Antigo: 
   Sistema  : Fluxo de aprovação de transações pendentes
   Sigla    : CRED
   Autor    : Rafael Muniz Monteiro - Mouts
   Data     : Junho/2017.                   Ultima atualizacao: 
  
  Dados referentes ao programa: Projeto 397
  
  Frequencia: -----
  Objetivo  : Procedure para validar os limites de operadores que estão tentando reprovar uma
              transação pendente.
  
  Alteracoes: 
            
  ---------------------------------------------------------------------------------------------------------------*/                                        
    -- CURSORES
    --
    CURSOR C1 (prc_cdtransacao_pendente IN NUMBER)IS
      select tgen.tptransacao,
             nvl(tpag.vlpagamento,0)     vlpagamento,
             tpag.dtdebito               dtdebito_tpag,
             nvl(tted.vlted,0)           vlted,
             tted.dtdebito               dtbedito_tted,
             nvl(ttra.vltransferencia,0) vltransferencia,
             ttra.dtdebito               dtdebito_ttra,
             nvl(tfol.vlfolha,0)         vlfolha,
             tfol.dtdebito               dtdebito_tfol,
             nvl(tddt.vlpagamento,0)     vlpag_darf_das,
             tddt.dtdebito               dtdebito_tddt    
        from tbgen_trans_pend            tgen,
             tbpagto_trans_pend          tpag,
             tbspb_trans_pend            tted,
             tbtransf_trans_pend         ttra,
             tbfolha_trans_pend          tfol,
             tbpagto_darf_das_trans_pend tddt
       where tgen.cdcooper             = pr_cdcooper
         and tgen.nrdconta             = pr_nrdconta
         and tgen.cdtransacao_pendente = prc_cdtransacao_pendente
         and tgen.cdtransacao_pendente = tpag.cdtransacao_pendente (+)
         and tgen.cdcooper             = tpag.cdcooper             (+)
         and tgen.nrdconta             = tpag.nrdconta             (+)
         and tgen.cdtransacao_pendente = tted.cdtransacao_pendente (+)
         and tgen.cdcooper             = tted.cdcooper             (+)
         and tgen.nrdconta             = tted.nrdconta             (+)
         and tgen.cdtransacao_pendente = ttra.cdtransacao_pendente (+)
         and tgen.cdcooper             = ttra.cdcooper             (+)
         and tgen.nrdconta             = ttra.nrdconta             (+)   
         and tgen.cdtransacao_pendente = tfol.cdtransacao_pendente (+)
         and tgen.cdcooper             = tfol.cdcooper             (+)
         and tgen.nrdconta             = tfol.nrdconta             (+)
         and tgen.cdtransacao_pendente = tddt.cdtransacao_pendente (+)
         and tgen.cdcooper             = tddt.cdcooper             (+)
         and tgen.nrdconta             = tddt.nrdconta             (+);             
         
    -- VARIAVEIS
    vr_cdtransacao_pendente NUMBER;
    ls_cdtransacao          GENE0002.typ_split;      
    vr_inicio               NUMBER;
    vr_qtdade_transa        NUMBER;
    vr_inicio_sub           NUMBER;
    vr_result               VARCHAR2(32000);
    vr_result_final         VARCHAR2(32000);    
    vr_vlpagamento             NUMBER;
    vr_vlvrb                   NUMBER;
    vr_vlted                   NUMBER;
    vr_vltransferencia         NUMBER;
    vr_vlfolha                 NUMBER;
    vr_vlpag_darf_das          NUMBER;  
    --
    vr_tab_internet INET0001.typ_tab_internet;
    vr_cdcritic     crapcri.cdcritic%TYPE;
    vr_dscritic     VARCHAR2(4000);
    vr_nrdrowid     ROWID;
    vr_dstransa     VARCHAR2(100);    
    vr_dtmvtopg     DATE;
    --
    vr_exc_erro  EXCEPTION;
    vr_exit      EXCEPTION;
 
    
    
  BEGIN
    -- Inicializar
    pr_msgretor        := 'OK';
    vr_vlpagamento     := 0;
    vr_vlvrb           := 0;
    vr_vlted           := 0;
    vr_vltransferencia := 0;
    vr_vlfolha         := 0;
    vr_vlpag_darf_das  := 0;
    --
    -- Buscar o valor de pagamento da transação em aprovacao
/*    vr_result_final := NULL;
    -- define a quantidade de cdtransacao_pendente para ser processada
    BEGIN
      SELECT (length(pr_cdditens) - length(replace(pr_cdditens, '|')))
        INTO vr_qtdade_transa
        FROM dual;  
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao buscar vr_qtdade_transa '||sqlerrm;
        RAISE vr_exc_erro;
    END;

    vr_inicio := 2;
    BEGIN
      SELECT instr(pr_cdditens,',',1,vr_inicio) + 1
        INTO vr_inicio_sub
        FROM dual;  
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := '01 - Erro ao buscar vr_inicio_sub '||sqlerrm;
        RAISE vr_exc_erro;
    END;*/
      
    /*FOR vr_index IN 1..vr_qtdade_transa LOOP
      -- Buscar inicio para o substr
      BEGIN
        SELECT SUBSTR(pr_cdditens,vr_inicio_sub,instr(substr(pr_cdditens,vr_inicio_sub),',')-1)
          INTO vr_result
          FROM dual;
      EXCEPTION
        WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao buscar vr_result '||sqlerrm;
        RAISE vr_exc_erro;          
      END;
      --
      vr_inicio := vr_inicio + 4;
      BEGIN
        SELECT instr(pr_cdditens,',',1,vr_inicio) + 1
          INTO vr_inicio_sub
          FROM dual;      
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := '02 - Erro ao buscar vr_inicio_sub '||sqlerrm;
          RAISE vr_exc_erro;
      END;      
      --
      IF vr_result_final IS NULL THEN
        vr_result_final := vr_result;
      ELSE
        vr_result_final := vr_result_final ||','||vr_result;
      END IF;
      
    END LOOP;*/    
    --
    -- Gerar LOG
    vr_nrdrowid := NULL;
    vr_dstransa := 'Validacao limite do operador para aprov';
    GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                        ,pr_cdoperad => pr_cdoperad
                        ,pr_dscritic => ''
                        ,pr_dsorigem => pr_dsorigem
                        ,pr_dstransa => vr_dstransa
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1 --> TRUE
                        ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                        ,pr_idseqttl => pr_idseqttl
                        ,pr_nmdatela => 'INTERNETBANK'
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);
    --
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'Parametro CPF do operador'
                             ,pr_dsdadant => ''
                             ,pr_dsdadatu => pr_nrcpfope); 
                                
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'Cod da Transacao'
                             ,pr_dsdadant => ''
                             ,pr_dsdadatu => pr_cddoitem);                                                      
    --    
    -- gerar uma lista
/*    ls_cdtransacao := gene0002.fn_quebra_string(pr_string => vr_result_final, pr_delimit => ',');*/

    -- Para cada registro selecionado, faremos as validacoes necessarias
    --FOR vr_index IN 1..ls_cdtransacao.COUNT() LOOP
     -- ROWID do pagamento
     vr_cdtransacao_pendente := pr_cddoitem ;--ls_cdtransacao(vr_index);
     -- Abre o cursor para buscar os valores e somar conforme tipo de transacao
     FOR R1 IN C1(vr_cdtransacao_pendente) LOOP
      IF r1.tptransacao in (1,3,5)  THEN /** Operacao de Transferencia **/
        vr_vltransferencia := vr_vltransferencia + r1.vltransferencia;
        vr_dtmvtopg        := r1.dtdebito_ttra;
      ELSIF r1.tptransacao = 4 THEN /** Operacao de TED **/
        vr_vlted    := vr_vlted + r1.vlted;
        vr_dtmvtopg := r1.dtbedito_tted;
      ELSIF r1.tptransacao = 2 OR r1.tptransacao in (6,10,11) THEN  /** Operacao de Pagamento / DARF/DAS **/
        IF r1.vlpagamento < 25000 THEN -- Pagamento boleto
          vr_vlpagamento := vr_vlpagamento + r1.vlpagamento + r1.vlpag_darf_das;
          vr_dtmvtopg := r1.dtdebito_tpag;
        ELSE -- VR-Boleto
          vr_vlvrb := vr_vlvrb + r1.vlpagamento;
          vr_dtmvtopg := r1.dtdebito_tpag;
        END IF;  
      ELSIF r1.tptransacao = 9 THEN  /** Operacao de Pagamento Folha de Pagamento **/      
        vr_vlfolha := vr_vlfolha + r1.vlfolha;
        vr_dtmvtopg := r1.dtdebito_tfol;
      END IF;
             
     END LOOP;
     
    --END LOOP;
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'Vl Tranferencia'
                             ,pr_dsdadant => ''
                             ,pr_dsdadatu => vr_vltransferencia);    
    --
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'Vl TED'
                             ,pr_dsdadant => ''
                             ,pr_dsdadatu => vr_vlted);                                  
    --
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'Vl Pagamento'
                             ,pr_dsdadant => ''
                             ,pr_dsdadatu => vr_vlpagamento);                                  
    --
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'Vl Vr Boleto'
                             ,pr_dsdadant => ''
                             ,pr_dsdadatu => vr_vlvrb);                                  
    --
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'Vl Folha'
                             ,pr_dsdadant => ''
                             ,pr_dsdadatu => vr_vlfolha);                                  
    --
    BEGIN
      -- Buscar limites operador do sistema
      pc_busca_limites_opera_trans(pr_cdcooper     => pr_cdcooper  --Codigo Cooperativa
                                  ,pr_nrdconta     => pr_nrdconta  --Numero da conta
                                  ,pr_idseqttl     => pr_idseqttl  --Identificador Sequencial titulo
                                  ,pr_nrcpfope	   => pr_nrcpfope  --Numero do CPF
                                  ,pr_dtmvtopg     => vr_dtmvtopg  --Data do proximo pagamento
                                  ,pr_dsorigem     => pr_dsorigem  --Descricao Origem
                                  ,pr_tab_internet => vr_tab_internet --Tabelas de retorno de horarios limite
                                  ,pr_cdcritic     => vr_cdcritic   --Codigo do erro
                                  ,pr_dscritic     => vr_dscritic); --Descricao do erro; 
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF; -- Validar se esá habilitado assinatura conjunta                                                                        
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao buscar os limites '||sqlerrm;
        RAISE vr_exc_erro;
    END; 
    /** Obtem limites  **/
    IF NOT vr_tab_internet.EXISTS(pr_idseqttl) THEN
      vr_cdcritic:= 0;
      vr_dscritic:= 'Registro de limite nao encontrado.';
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    --
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'Limite Transf'
                             ,pr_dsdadant => ''
                             ,pr_dsdadatu => vr_tab_internet(pr_idseqttl).vllimtrf);
    --
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'Limite Pagamento'
                             ,pr_dsdadant => ''
                             ,pr_dsdadatu => vr_tab_internet(pr_idseqttl).vldsppgo);    
    --
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'Limite vrb'
                             ,pr_dsdadant => ''
                             ,pr_dsdadatu => vr_tab_internet(pr_idseqttl).vllimvrb);        
    --
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'Limite TED'
                             ,pr_dsdadant => ''
                             ,pr_dsdadatu => vr_tab_internet(pr_idseqttl).vllimted);
    --
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'Limite FP'
                             ,pr_dsdadant => ''
                             ,pr_dsdadatu => vr_tab_internet(pr_idseqttl).vllimflp);
                                             
    -- Validar limites de Transferencia
    IF vr_vltransferencia > 0 THEN
      IF vr_tab_internet(pr_idseqttl).vllimtrf <= 0 THEN
        pr_msgretor := 'Operador nao possui limite de pagamento cadastrado';
        RAISE vr_exit;
      END IF;
      --
      IF vr_vltransferencia > vr_tab_internet(pr_idseqttl).vllimtrf THEN
        pr_msgretor := 'O valor de transferencia que esta tentando reprovar e maior que o limite do operador'; 
        RAISE vr_exit;        
      END IF;      
    END IF; 
    -- Validar limites de Pagamento
    IF vr_vlpagamento > 0 THEN                                 
      IF vr_tab_internet(pr_idseqttl).vldsppgo <= 0 THEN
        pr_msgretor := 'Operador nao possui limite de pagamento cadastrado';
        RAISE vr_exit;
      END IF;
      --
      IF vr_vlpagamento > vr_tab_internet(pr_idseqttl).vldsppgo THEN
        pr_msgretor := 'O valor de pagamento que esta tentando reprovar e maior que o limite do operador'; 
        RAISE vr_exit;        
      END IF;
    END IF;
    -- Validar limites de Vr boleto
    IF vr_vlvrb > 0 THEN
      IF vr_tab_internet(pr_idseqttl).vllimvrb <= 0 THEN
        pr_msgretor := 'Operador nao possui limite de pagamento VR-Boleto cadastrado';
        RAISE vr_exit;
      END IF;    
      --
      IF vr_vlvrb > vr_tab_internet(pr_idseqttl).vllimvrb THEN
        pr_msgretor := 'O valor de pagamento VR-Boleto que esta tentando reprovar e maior que o limite do operador'; 
        RAISE vr_exit;        
      END IF;
    END IF;
    --
    IF vr_vlpag_darf_das > 0 THEN
      IF vr_tab_internet(pr_idseqttl).vldsppgo <= 0 THEN
        pr_msgretor := 'Operador nao possui limite de pagamento Darf ou Das cadastrado';
        RAISE vr_exit;
      END IF;    
      --
      IF vr_vlvrb > vr_tab_internet(pr_idseqttl).vldsppgo THEN
        pr_msgretor := 'O valor de pagamento Darf ou DAs que esta tentando reprovar e maior que o limite do operador'; 
        RAISE vr_exit;        
      END IF;      
    END IF;   
    
    IF vr_vlted > 0 THEN
      IF vr_tab_internet(pr_idseqttl).vllimted <= 0 THEN
        pr_msgretor := 'Operador nao possui limite de TED cadastrado';
        RAISE vr_exit;
      END IF;    
      --
      IF vr_vlted > vr_tab_internet(pr_idseqttl).vllimted THEN
        pr_msgretor := 'O valor de TED que esta tentando reprovar e maior que o limite do operador'; 
        RAISE vr_exit;        
      END IF;       
    END IF;
    
    IF vr_vlfolha > 0 THEN
      IF vr_tab_internet(pr_idseqttl).vllimflp <= 0 THEN
        pr_msgretor := 'Operador nao possui limite de folha de pagamento cadastrado';
        RAISE vr_exit;
      END IF;    
      --
      IF vr_vlfolha > vr_tab_internet(pr_idseqttl).vllimflp THEN
        pr_msgretor := 'O valor folha de pagamento que esta tentando reprovar e maior que o limite do operador'; 
        RAISE vr_exit;        
      END IF;       
    END IF;    
  
  EXCEPTION
    WHEN vr_exit THEN
      NULL;
    WHEN  vr_exc_erro  THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na proc pc_verifica_limite_ope_prog '||sqlerrm;
  
  END pc_verifica_limite_ope_prog;

PROCEDURE pc_verifica_limite_ope_canc (pr_cdcooper     IN crapcop.cdcooper%type  --C¿digo Cooperativa
                                      ,pr_nrdconta     IN crapass.nrdconta%TYPE  --Numero da conta
                                      ,pr_idseqttl     IN crapttl.idseqttl%TYPE  --Identificador Sequencial titulo
                                      ,pr_nrcpfope     IN crapopi.nrcpfope%TYPE  --Numero do CPF Operador
                                      ,pr_cdoperad     IN crapope.cdoperad%TYPE  --Codigo Operador
                                      ,pr_vllanaut     IN NUMBER -- Valor da transacao
                                      ,pr_cdtiptra     IN NUMBER
                                      ,pr_dtmvtopg     IN crapdat.dtmvtolt%TYPE  --Data do proximo pagamento
                                      ,pr_dsorigem     IN craplau.dsorigem%TYPE  --Descricao Origem
                                      ,pr_msgretor     OUT VARCHAR2                    
                                      ,pr_cdcritic     OUT INTEGER        --Codigo do erro
                                      ,pr_dscritic     OUT VARCHAR2) IS
  /*---------------------------------------------------------------------------------------------------------------
   Programa : pc_verifica_limite_ope_prog           Antigo: 
   Sistema  : Fluxo de aprovação de transações pendentes
   Sigla    : CRED
   Autor    : Rafael Muniz Monteiro - Mouts
   Data     : Junho/2017.                   Ultima atualizacao: 
  
  Dados referentes ao programa: Projeto 397
  
  Frequencia: -----
  Objetivo  : Procedure para validar os limites de operadores que estão tentando reprovar uma
              agendamento pendente.
  
  Alteracoes: 
            
  ---------------------------------------------------------------------------------------------------------------*/                                      
    -- CURSORES
    --
                 
         
    -- VARIAVEIS
    --
    vr_tab_internet INET0001.typ_tab_internet;
    vr_cdcritic     crapcri.cdcritic%TYPE;
    vr_dscritic     VARCHAR2(4000);
    vr_nrdrowid     ROWID;
    vr_dstransa     VARCHAR2(100);    
    vr_dtmvtopg     DATE;
    --
    vr_exc_erro  EXCEPTION;
    vr_exit      EXCEPTION;
   
  BEGIN
    -- Inicializar
    pr_msgretor        := 'OK';

    --
    --
    -- Gerar LOG
    vr_nrdrowid := NULL;
    vr_dstransa := 'Validacao limite do operador cancelamento de agendamento';
    GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                        ,pr_cdoperad => pr_cdoperad
                        ,pr_dscritic => ''
                        ,pr_dsorigem => pr_dsorigem
                        ,pr_dstransa => vr_dstransa
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1 --> TRUE
                        ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                        ,pr_idseqttl => pr_idseqttl
                        ,pr_nmdatela => 'INTERNETBANK'
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);
    --
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'Parametro CPF do operador'
                             ,pr_dsdadant => ''
                             ,pr_dsdadatu => pr_nrcpfope); 
    --    
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'Valor Agendamento'
                             ,pr_dsdadant => ''
                             ,pr_dsdadatu => pr_vllanaut);    
                        
    --
    BEGIN
      -- Buscar limites operador do sistema
      pc_busca_limites_opera_trans(pr_cdcooper     => pr_cdcooper  --Codigo Cooperativa
                                  ,pr_nrdconta     => pr_nrdconta  --Numero da conta
                                  ,pr_idseqttl     => pr_idseqttl  --Identificador Sequencial titulo
                                  ,pr_nrcpfope	   => pr_nrcpfope  --Numero do CPF
                                  ,pr_dtmvtopg     => vr_dtmvtopg  --Data do proximo pagamento
                                  ,pr_dsorigem     => pr_dsorigem  --Descricao Origem
                                  ,pr_tab_internet => vr_tab_internet --Tabelas de retorno de horarios limite
                                  ,pr_cdcritic     => vr_cdcritic   --Codigo do erro
                                  ,pr_dscritic     => vr_dscritic); --Descricao do erro; 
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF; -- Validar se esá habilitado assinatura conjunta                                                                        
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao buscar os limites '||sqlerrm;
        RAISE vr_exc_erro;
    END; 
    /** Obtem limites  **/
    IF NOT vr_tab_internet.EXISTS(pr_idseqttl) THEN
      vr_cdcritic:= 0;
      vr_dscritic:= 'Registro de limite nao encontrado.';
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    --
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'Limite Transf'
                             ,pr_dsdadant => ''
                             ,pr_dsdadatu => vr_tab_internet(pr_idseqttl).vllimtrf);
    --
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'Limite Pagamento'
                             ,pr_dsdadant => ''
                             ,pr_dsdadatu => vr_tab_internet(pr_idseqttl).vldsppgo);    
    --
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'Limite vrb'
                             ,pr_dsdadant => ''
                             ,pr_dsdadatu => vr_tab_internet(pr_idseqttl).vllimvrb);        
    --
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'Limite TED'
                             ,pr_dsdadant => ''
                             ,pr_dsdadatu => vr_tab_internet(pr_idseqttl).vllimted);
    --
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'Limite FP'
                             ,pr_dsdadant => ''
                             ,pr_dsdadatu => vr_tab_internet(pr_idseqttl).vllimflp);
                                             
    -- Validar limites de Transferencia
    IF pr_cdtiptra in (1,3,5) THEN
      IF vr_tab_internet(pr_idseqttl).vllimtrf <= 0 THEN
        pr_msgretor := 'Operador nao possui limite de pagamento cadastrado (1)';
        RAISE vr_exit;
      END IF;
      --
      IF pr_vllanaut > vr_tab_internet(pr_idseqttl).vllimtrf THEN
        pr_msgretor := 'O valor de transferencia que esta tentando reprovar e maior que o limite do operador(1)'; 
        RAISE vr_exit;        
      END IF;      
    END IF; 
    -- Validar limites de Pagamento
    IF pr_cdtiptra = 2 THEN                                 
      IF vr_tab_internet(pr_idseqttl).vldsppgo <= 0 THEN
        pr_msgretor := 'Operador nao possui limite de pagamento cadastrado (2)';
        RAISE vr_exit;
      END IF;
      --
      IF pr_vllanaut > vr_tab_internet(pr_idseqttl).vldsppgo THEN
        pr_msgretor := 'O valor de pagamento que esta tentando reprovar e maior que o limite do operador(2)'; 
        RAISE vr_exit;        
      END IF;
    END IF;
    -- Validar limites de Vr boleto
    IF pr_cdtiptra = 6 THEN
      IF vr_tab_internet(pr_idseqttl).vllimvrb <= 0 THEN
        pr_msgretor := 'Operador nao possui limite de pagamento VR-Boleto cadastrado (6)';
        RAISE vr_exit;
      END IF;    
      --
      IF pr_vllanaut > vr_tab_internet(pr_idseqttl).vllimvrb THEN
        pr_msgretor := 'O valor de pagamento VR-Boleto que esta tentando reprovar e maior que o limite do operador (6)'; 
        RAISE vr_exit;        
      END IF;
    END IF;
    --
    IF pr_cdtiptra in (10,11) THEN
      IF vr_tab_internet(pr_idseqttl).vldsppgo <= 0 THEN
        pr_msgretor := 'Operador nao possui limite de pagamento Darf ou Das cadastrado (10)';
        RAISE vr_exit;
      END IF;    
      --
      IF pr_vllanaut > vr_tab_internet(pr_idseqttl).vldsppgo THEN
        pr_msgretor := 'O valor de pagamento Darf ou DAs que esta tentando reprovar e maior que o limite do operador(10)'; 
        RAISE vr_exit;        
      END IF;      
    END IF; 
    
    IF pr_cdtiptra = 4 THEN -- TED
      IF vr_tab_internet(pr_idseqttl).vllimted <= 0 THEN
        pr_msgretor := 'Operador nao possui limite de TED cadastrado (2)';
        RAISE vr_exit;
      END IF;    
      --
      IF pr_vllanaut > vr_tab_internet(pr_idseqttl).vllimted THEN
        pr_msgretor := 'O valor de TED que esta tentando reprovar e maior que o limite do operador (2)'; 
        RAISE vr_exit;        
      END IF;       
    END IF;
    
    /*IF vr_vlfolha > 0 THEN
      IF vr_tab_internet(pr_idseqttl).vllimflp <= 0 THEN
        pr_msgretor := 'Operador nao possui limite de folha de pagamento cadastrado';
        RAISE vr_exit;
      END IF;    
      --
      IF vr_vlted > vr_tab_internet(pr_idseqttl).vllimflp THEN
        pr_msgretor := 'O valor folha de pagamento que esta tentando reprovar e maior que o limite do operador'; 
        RAISE vr_exit;        
      END IF;       
    END IF; */   
  
  EXCEPTION
    WHEN vr_exit THEN
      NULL;
    WHEN  vr_exc_erro  THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na proc pc_verifica_limite_ope_canc '||sqlerrm;
  
  END pc_verifica_limite_ope_canc;    

  /*Atualiza as transacoes pendentes para o novo preposto*/
  PROCEDURE pc_atu_trans_pend_prep (pr_cdcooper IN crapcop.cdcooper%TYPE   --Codigo Cooperativa
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE   --Numero conta
                                   ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE   --CPF/CGC
                                   ,pr_inpessoa IN crapass.inpessoa%TYPE   --Tipo de Pessoa
                                   ,pr_tpdsenha IN crapsnh.tpdsenha%TYPE   --Tipo de Senha
                                   ,pr_idastcjt IN crapass.idastcjt%TYPE   --Exige Ass.Conjunta Nao=0 Sim=1
                                   ,pr_cdcritic   OUT INTEGER              --Código do erro
                                   ,pr_dscritic   OUT VARCHAR2) IS         --Descricao do erro
  BEGIN
    
  DECLARE
    
      CURSOR cur_trans_pend IS
        SELECT ttp.cdtransacao_pendente
          FROM tbgen_trans_pend ttp
         WHERE ttp.cdcooper = pr_cdcooper -- cooperativa
           AND ttp.nrdconta = pr_nrdconta -- conta
           AND ttp.idsituacao_transacao = 1 -- pendentes       
         ORDER BY ttp.cdtransacao_pendente;
    
      vr_idprglog tbgen_prglog.idprglog%TYPE := 0;
       
    BEGIN
      
      IF pr_tpdsenha =  1 /*Internet*/ AND
         pr_inpessoa > 1 /*PJ*/        AND 
         pr_idastcjt = 0 /*Nao exige Ass.Conj*/ THEN
         
        FOR reg IN cur_trans_pend LOOP          
         BEGIN
           UPDATE tbgen_trans_pend
               SET tbgen_trans_pend.nrcpf_representante  = pr_nrcpfcgc
             WHERE tbgen_trans_pend.cdtransacao_pendente = reg.cdtransacao_pendente -- pela pk
               AND tbgen_trans_pend.nrcpf_representante  <> pr_nrcpfcgc; -- CPF diferente apenas, se for o mesmo não atualiza.
              
           UPDATE tbgen_aprova_trans_pend
              SET tbgen_aprova_trans_pend.nrcpf_responsavel_aprov = pr_nrcpfcgc
             WHERE tbgen_aprova_trans_pend.cdtransacao_pendente    = reg.cdtransacao_pendente -- por parte da pk
               AND tbgen_aprova_trans_pend.idsituacao_aprov        = 1 -- somente pendentes
               AND tbgen_aprova_trans_pend.nrcpf_responsavel_aprov <> pr_nrcpfcgc; -- CPF diferente apenas, se for o mesmo não atualiza.
              
         EXCEPTION           
            WHEN dup_val_on_index THEN
              -- Conforme constatado com o INC0016955, há casos em que o novo preposto (CPF)
              -- já existe para a mesma transação, gerando erro de PK.
              -- Com isso, para não parar o processo iremos desconsiderar erros de PK para essa
              -- atualização de prepostos.
              NULL;
              
              -- Registra o erro para log
              cecred.pc_log_programa(pr_dstiplog            => 'E', -- Erro
                                     pr_cdprograma          => 'INET0001',
                                     pr_cdcooper            => 3, -- CECRED
                                     pr_tpexecucao          => 3, -- Online
                                     pr_tpocorrencia        => 1, -- Erro de negócio
                                     pr_cdcriticidade       => 0,
                                     pr_cdmensagem          => 0, -- critica
                                     pr_dsmensagem          => 'INET0001.pc_atu_trans_pend_prep. Chave duplicada na atualização da tabela tbgen_aprova_trans_pend. Parametros: pr_cdcooper ='||pr_cdcooper||
                                                               ', pr_nrdconta ='||pr_nrdconta||', pr_nrcpfcgc ='||pr_nrcpfcgc||', pr_inpessoa ='||pr_inpessoa||
                                                               ', pr_tpdsenha ='||pr_tpdsenha||', pr_idastcjt ='||pr_idastcjt, -- descrição da critica
                                     pr_flgsucesso          => 1,
                                     pr_nmarqlog            => NULL,
                                     pr_flabrechamado       => 0,
                                     pr_texto_chamado       => NULL,
                                     pr_destinatario_email  => NULL,
                                     pr_flreincidente       => 0,
                                     pr_idprglog            => vr_idprglog);
         END;
        END LOOP;
         
      END IF;
      
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral na rotina INET0001.pc_atu_trans_pend_prep. Descrição: '|| SQLERRM;    

        -- No caso de erro de programa gravar tabela especifica de log  
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);                                                                            
        
        -- Registra o erro para log
        cecred.pc_log_programa(pr_dstiplog            => 'E', -- Erro
                               pr_cdprograma          => 'INET0001',
                               pr_cdcooper            => 3, -- CECRED
                               pr_tpexecucao          => 3, -- Online
                               pr_tpocorrencia        => 2, -- Erro não tratado
                               pr_cdcriticidade       => 0,
                               pr_cdmensagem          => pr_cdcritic, -- critica
                               pr_dsmensagem          => pr_dscritic||CHR(10)||
                                                         'INET0001.pc_atu_trans_pend_prep. Parametros: pr_cdcooper ='||pr_cdcooper||
                                                         ', pr_nrdconta ='||pr_nrdconta||', pr_nrcpfcgc ='||pr_nrcpfcgc||', pr_inpessoa ='||pr_inpessoa||
                                                         ', pr_tpdsenha ='||pr_tpdsenha||', pr_idastcjt ='||pr_idastcjt, -- descrição da critica
                               pr_flgsucesso          => 1,
                               pr_nmarqlog            => NULL,
                               pr_flabrechamado       => 0,
                               pr_texto_chamado       => NULL,
                               pr_destinatario_email  => NULL,
                               pr_flreincidente       => 0,
                               pr_idprglog            => vr_idprglog);        
    END;
    
  END pc_atu_trans_pend_prep;
  

END INET0001;
/
