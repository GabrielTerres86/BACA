CREATE OR REPLACE PACKAGE CECRED.rati0001 is
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : RATI0001                     Antiga: sistema/generico/procedures/b1wgen0043.p
  --  Sistema  : Rotinas para Rating dos Cooperados
  --  Sigla    : RATI
  --  Autor    : Alisson C. Berrido - AMcom
  --  Data     : Maio/2013.                   Ultima atualizacao: 10/05/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para Rating dos Cooperados.

  --Alteracoes:    /  /    - Altera��es para Ayllos WEB:
  --                       - Incluir procedure gera_rating(gera_rating.p)
  --                       - Incluir procedure busca_dados_rating
  --                       - Incluir procedure grava_rating
  --                         (Guilherme)
  --
  --            24/02/2010 - Procedure para criticas na hora de geracao
  --                         do Rating.
  --                       - Deixar o cooperado sem Rating para a central
  --                         quando ele estiver abaixo do valor legal.
  --                       - Sempre migrar para o novo Rating , quando criado
  --                         um novo, independente da nota/risco.
  --                       - Retirar criticas fixas para cadastro na crapcri.
  --                         (Gabriel).
  --
  --            17/03/2010 - Arrumar data de referencia para o mes passado
  --                         na procedure de riscos_sem_rating (Gabriel).
  --                       - Arrumar critica quando imovel nao cadastrado
  --                         (Gabriel).
  --
  --            16/04/2010 - Adaptar para Ayllos WEB (David).
  --
  --            05/05/2010 - Acerto no item 1.3 (Pessoa fisica) para o devido
  --                         enquadramento quando aposentados sem um trabalho
  --                         previo cadastrado.
  --                         Acerto na hora do calculo do saldo utiliza quando
  --                         se esta liquidando outros emprestimos.
  --                         Acerto na procedure desativa_rating para desfazer
  --                         operacao caso <F4> / <END> (Gabriel).
  --
  --            20/05/2010 - Implementar a re-ativa�ao do Rating.
  --                       - Implementar a procedure obtem_emprestimo_risco, que
  --                         trata dos riscos das propostas de emprestimo.
  --                       - Tratar para nao poder ter estouro de conta na
  --                         crapris na procedure riscos_sem_rating e os
  --                         nem contratos de emprestiimo com menos de 6 meses
  --                         (Gabriel).
  --
  --            25/08/2010 - Feito tratamento, Emprestimos/Financiamentos
  --                         (Adriano).
  --
  --           09/09/2010 - Migracao para a tabela crapprp quando proposta
  --                         de emprestimo.
  --                         Retirar procedures nao mais utilizadas (Gabriel).
  --
  --            26/11/2010 - Quando impressao dos ratings para as propostas,
  --                         imprimir o rating proposto com a pior nota
  --                         e maior valor da operacao (Gabriel).
  --
  --            15/02/2011 - Se a empresa n�o atender a condi��o de tempo dos
  --                         s�cios na empresa com a cl�usula
  --                         CAN-DO ("27,39,44,45,46,48",STRING(crapjur.natjurid));
  --                         fazer o mesmo tratamento que � feito com o campo
  --                         crapjur.natjurid para o campo crapjur.dtiniatv.
  --                         Os anos em que a empresa atua � que dever�o ser
  --                         encaixados na faixa. (Fabr�cio)
  --
  --            01/03/2011 - Altera��es nas rotinas de c�lculo e classifica��o
  --                         dos ratings
  --                       - Adaptacoes  para o calculo do Risco Cooperado
  --                         (Guilherme).
  --
  --            14/04/2011 - Incluido campo tt-impressao-rating.intopico na
  --                         procedure gera-arquivo-impressao-rating. (Fabricio)
  --
  --            14/04/2011 - Incluido a temp-table tt-impressao-risco-tl como
  --                         parametro de saida da procedure atualiza_rating,
  --                         para atualizar a crapass no retorna para a tela
  --                         ATURAT. (Fabricio)
  --
  --            28/07/2011 - Correcao no calculo do item 1.10 (Gabriel).
  --
  --            11/08/2011 - Altera��es p/ Grupo Economico
  --                         Parametro dtrefere na obtem_risco
  --                       - Adaptacao Rating das Singulares (Guilherme).
  --
  --            04/11/2011 - Rezalizado altera��o na procedure valida-itens-rating
  --                         para que, quando cdcooper = 3, sejam validados
  --                         apenas a liquidez e as inf. cadastrais (Adriano).
  --
  --            09/11/2011 - Criado a procedure proc_calcula (Adriano).
  --
  --            02/07/2012 - Tratamento do cdoperad "operador" de INTE para CHAR.
  --                         (Lucas R.)
  --
  --            11/10/2012 - Incluido a passagem de um novo parametro na chamada
  --                         da procedure saldo_utiliza - Projeto GE (Adriano).
  --
  --            13/03/2013 - Ajuste na procedure obtem_emprestimo_risco para
  --                         ustilizar o campo crapris.inindris
  --                         (risco individual) ao inves do crapris.innivris
  --                         (risco do grupo) (Adriano).
  --            13/05/2013 - Alterar regra do rating item 2_1(natureza da operacao)  conforme  chamado 62561 - Rosangela.
  --
  --            05/11/2014 - Ajuste na procedure pc_risco_cooperado_pf e
  --                         pc_risco_cooperado_pj para carregar a crapris 
  --                         com a conta a qual esta sendo passada ou 
  --                         tudo na temp table. (Jaison)
  --
  --            06/08/2015 - Alterado procedimento pc_historico_cooperado para melhorias de performace
  --                         verificado se a conta possuia contrato de limite de credito no periodo,
  --                         caso nao tenha, nao precisa verificar dias que usa o limite de credito SD281898 (Odirlei-Amcom)
  --
  --            03/07/2015 - Projeto 217 Reformula�ao Cadastral IPP Entrada
  --                         Ajuste nos codigos de natureza juridica para o
  --                         existente na receita federal (Tiago Castro - RKAM)
  --
  --
  --            30/11/2015 - Ajuste na pc_verifica_contrato_rating para Corre��o da convers�o que n�o estava
  --                         conforme com a vers�o do Progress.
  --                         Ajuste na pc_desativa_rating para passar o ROWID correto para pc_grava_rating_origem
  --                            e TRIM na vari�vel pr_flgefeti(erro quando vem pela EMPR0001)
  --                         Ajuste na pc_ativa_rating para atribuir ROWID � variavel(Guilherme/SUPERO)
  --
  --			03/06/2016	 Alteracao na atribuicao de notas do rating, se for AA, deve
  --			             assumir a nota referente ao risco A.
  --						 Chamado 431839 (Andrey - RKAM)
   --
  --            10/05/2016 - Ajustes referente a convers�o da tela ATURAT
  --                         (Andrei - RKAM).
  --
  --			13/10/2016 - Ajuste na leitura da craptab para utiliza��o de cursor padr�o (Rodrigo)
  --
  --            08/11/2016 - Salvar o valor de endividamento em uma variavel de escopo global, pois em
  --                         algumas situacoes, nao estava gravando o valor considerado para rateio
  --                         Heitor (Mouts) - Chamado 544076
  --  
  --            01/02/2017 - Incluir busca na central de risco tambem para os limites rotativos.
  --                         Ajustada a rotina pc_verifica_atualizacao, que nao estava retornando a mensagem de erro
  --                         corretamente para a tela ATURAT. Heitor (Mouts)
  --
  ---------------------------------------------------------------------------------------------------------------
  -- Tipo de Tabela para dados provisao CL
  TYPE typ_tab_dsdrisco IS TABLE OF VARCHAR2(5) INDEX BY PLS_INTEGER;

  -- Tipo para registros para armazenamento da efetiva��o do Rating
  TYPE typ_reg_efetivacao IS
    RECORD (dsdefeti VARCHAR2(300)
           ,idseqmen INTEGER);
  TYPE typ_tab_efetivacao IS
    TABLE OF typ_reg_efetivacao
      INDEX BY BINARY_INTEGER;

  -- Tipo para registros para armazenamento dos Ratings do Cooperado
  -- Antigo: tt-ratings
  TYPE typ_reg_ratings IS
    RECORD (cdagenci crapass.cdagenci%TYPE
           ,nrdconta crapnrc.nrdconta%TYPE
           ,nrctrrat crapnrc.nrctrrat%TYPE
           ,tpctrrat crapnrc.tpctrrat%TYPE
           ,indrisco crapnrc.indrisco%TYPE
           ,dtmvtolt crapnrc.dtmvtolt%TYPE
           ,dteftrat crapnrc.dteftrat%TYPE
           ,cdoperad crapnrc.cdoperad%TYPE
           ,insitrat crapnrc.insitrat%TYPE
           ,dsditrat VARCHAR2(300)
           ,nrnotrat crapnrc.nrnotrat%TYPE
           ,vlutlrat crapnrc.vlutlrat%TYPE
           ,vloperac NUMBER
           ,dsdopera VARCHAR2(300)
           ,dsdrisco VARCHAR2(300)
           ,flgorige crapnrc.flgorige%TYPE
           ,inrisctl crapnrc.inrisctl%TYPE
           ,nrnotatl crapnrc.nrnotatl%TYPE
           ,dtrefere DATE
           ,nmprimtl crapass.nmprimtl%TYPE
           ,nmoperad crapope.nmoperad%TYPE);
  TYPE typ_tab_ratings IS
    TABLE OF typ_reg_ratings
      INDEX BY BINARY_INTEGER;

  -- Informacoes do cooperado na impressao do Rating
  -- Antigo: tt-impressao-coop
  TYPE typ_reg_impress_coop IS
    RECORD (nrdconta NUMBER
           ,nmprimtl VARCHAR2(100)
           ,dspessoa VARCHAR2(15)
           ,dsdopera VARCHAR2(15)
           ,nrctrrat crapnrc.nrctrrat%TYPE
           ,tpctrrat crapnrc.tpctrrat%TYPE);
  TYPE typ_tab_impress_coop IS
    TABLE OF typ_reg_impress_coop
      INDEX BY BINARY_INTEGER;

  -- Itens do Rating
  -- Antigo: tt-itens-rating
   TYPE typ_reg_itens IS
    RECORD (nrseqite NUMBER     
           ,dsitetop VARCHAR2(100)      
           ,dspesoit VARCHAR2(200)
           ,vlrdnota VARCHAR2(10));
  TYPE typ_tab_itens IS
    TABLE OF typ_reg_itens
      INDEX BY BINARY_INTEGER;
      
  -- Itens do Rating
  -- Antigo: tt-itens-rating
  TYPE typ_reg_subtopico IS
    RECORD (nritetop NUMBER
           ,dsitetop VARCHAR2(100)
           ,dspesoit VARCHAR2(200)
           ,tab_itens  typ_tab_itens);
           
  TYPE typ_tab_subtopico IS
    TABLE OF typ_reg_subtopico
      INDEX BY BINARY_INTEGER;
      
  -- Itens do Rating
  -- Antigo: tt-itens-rating
  TYPE typ_reg_impress_rating IS
    RECORD (intopico NUMBER
           ,nrtopico NUMBER
           ,dsitetop VARCHAR2(100)
           ,tab_subtopico  typ_tab_subtopico);
  TYPE typ_tab_impress_rating IS
    TABLE OF typ_reg_impress_rating
      INDEX BY BINARY_INTEGER;

  -- Registro gen�rico para Nota e risco do cooperado naquele Rating - PROVISAOCL e PROVISAOTL
  -- Antigos: tt-impressao-risco e tt-impressao-risco-cl
  TYPE typ_reg_impress_risco IS
    RECORD (vlrtotal NUMBER
           ,dsdrisco VARCHAR2(30)
           ,vlprovis NUMBER
           ,dsparece VARCHAR2(150)
           ,vlrcoope NUMBER);
  TYPE typ_tab_impress_risco IS
    TABLE OF typ_reg_impress_risco
      INDEX BY BINARY_INTEGER;

  -- Assinatura na impressao do Rating
  -- Antigo: tt-impressao-assina
  TYPE typ_reg_impress_assina IS
    RECORD (dsdedata VARCHAR2(100)
           ,nmoperad crapope.nmoperad%TYPE
           ,dsrespon VARCHAR2(12));
  TYPE typ_tab_impress_assina IS
    TABLE OF typ_reg_impress_assina
      INDEX BY BINARY_INTEGER;

 -- Type para registros de rating
 -- Antigos tt-rating-singulares, tt-singulares, tt-crapras
  TYPE typ_reg_crapras IS
       RECORD(nrtopico NUMBER,
              nritetop NUMBER,
              nrseqite NUMBER);
  TYPE typ_tab_crapras IS TABLE OF typ_reg_crapras
    INDEX BY varchar2(15); --nrtopico(5) + nritetop(5) +nrseqite(5)

  /* Rotina responsavel por buscar a descri��o da operacao do tipo de contrato */
  FUNCTION fn_busca_descricao_operacao (pr_tpctrrat IN INTEGER) --Tipo Contrato Rating
    RETURN VARCHAR2;

  /* Rotina respons�vel por obter o nivel de risco */
  PROCEDURE pc_obtem_risco (pr_cdcooper       IN crapcop.cdcooper%TYPE --C�digo da Cooperativa
                           ,pr_nrdconta       IN crapass.nrdconta%TYPE --Numero da Conta do Associado
                           ,pr_tab_dsdrisco   IN RATI0001.typ_tab_dsdrisco --Vetor com dados das provisoes
                           ,pr_dstextab_bacen IN craptab.dstextab%TYPE --Descricao da craptab do RISCOBACEN
                           ,pr_dtmvtolt       IN crapdat.dtmvtolt%TYPE --Data Movimento
                           ,pr_nivrisco       OUT VARCHAR2             --Nivel de Risco
                           ,pr_dtrefere       OUT DATE                 --Data de Referencia do Risco
                           ,pr_cdcritic       OUT INTEGER              --C�digo da Critica de Erro
                           ,pr_dscritic       OUT VARCHAR2);           --Descricao do erro

  /* Calcula endividamento total SCR. Itens 3_3 (Fisica) e 5_1 (Juridica). */
  PROCEDURE pc_calcula_endividamento(pr_cdcooper   IN crapcop.cdcooper%TYPE     --> C�digo da Cooperativa
                                    ,pr_cdagenci   IN crapass.cdagenci%TYPE     --> C�digo da ag�ncia
                                    ,pr_nrdcaixa   IN craperr.nrdcaixa%TYPE     --> N�mero do caixa
                                    ,pr_cdoperad   IN crapnrc.cdoperad%TYPE     --> C�digo do operador
                                    ,pr_rw_crapdat IN btch0001.rw_crapdat%TYPE  --> Vetor com dados de par�metro (CRAPDAT)
                                    ,pr_nrdconta   IN crapass.nrdconta%TYPE     --> Conta do associado
                                    ,pr_dsliquid   IN VARCHAR2                  --> Lista de contratos a liquidar
                                    ,pr_idseqttl   IN crapttl.idseqttl%TYPE     --> Sequencia de titularidade da conta
                                    ,pr_idorigem   IN INTEGER                   --> Indicador da origem da chamada
                                    ,pr_inusatab   IN BOOLEAN                   --> Indicador de utiliza��o da tabela de juros
                                    ,pr_tpdecons   IN INTEGER DEFAULT 2         --> Tipo da consulta,defalut 2 saldo disponivel emprestimo sem considerar data atual, 3 saldo disponivel data atual (Ver observa��es da rotina GENE0005.pc_saldo_utiliza)
                                    ,pr_vlutiliz  OUT NUMBER                    --> Valor da d�vida
                                    ,pr_cdcritic  OUT crapcri.cdcritic%TYPE     --> Critica encontrada no processo
                                    ,pr_dscritic  OUT VARCHAR2);                --> Sa�da de erro
                                    
  /* Desativar Rating. Usada quando emprestimo � liquidado ou limite � cancelado. */
  PROCEDURE pc_desativa_rating(pr_cdcooper   IN crapcop.cdcooper%TYPE    --> C�digo da Cooperativa
                              ,pr_cdagenci   IN crapass.cdagenci%TYPE    --> C�digo da ag�ncia
                              ,pr_nrdcaixa   IN craperr.nrdcaixa%TYPE    --> N�mero do caixa
                              ,pr_cdoperad   IN crapnrc.cdoperad%TYPE    --> C�digo do operador
                              ,pr_rw_crapdat IN btch0001.rw_crapdat%TYPE --> Vetor com dados de par�metro (CRAPDAT)
                              ,pr_nrdconta   IN crapass.nrdconta%TYPE    --> Conta do associado
                              ,pr_tpctrrat   IN NUMBER                   --> Tipo do Rating
                              ,pr_nrctrrat   IN NUMBER                   --> N�mero do contrato de Rating
                              ,pr_flgefeti   IN VARCHAR2                 --> Flag para efetiva��o ou n�o do Rating
                              ,pr_idseqttl   IN crapttl.idseqttl%TYPE    --> Sequencia de titularidade da conta
                              ,pr_idorigem   IN INTEGER                  --> Indicador da origem da chamada
                              ,pr_inusatab   IN BOOLEAN                  --> Indicador de utiliza��o da tabela de juros
                              ,pr_nmdatela   IN VARCHAR2                 --> Nome datela conectada
                              ,pr_flgerlog   IN VARCHAR2                 --> Gerar log S/N
                              ,pr_des_reto  OUT VARCHAR                  --> Retorno OK / NOK
                              ,pr_tab_erro  OUT gene0001.typ_tab_erro);  --> Tabela com poss�ves erros

  /* Procedure para verificar contrato rating */
  PROCEDURE pc_verifica_contrato_rating (pr_cdcooper IN INTEGER  --Codigo Cooperativa
                                        ,pr_cdagenci IN INTEGER  --Codigo Agencia
                                        ,pr_nrdcaixa IN INTEGER  --Numero Caixa
                                        ,pr_cdoperad IN VARCHAR2 --Codigo Operador
                                        ,pr_dtmvtolt IN DATE     --Data Movimentacao
                                        ,pr_dtmvtopr IN DATE     --Data proxima operacao
                                        ,pr_nrdconta IN INTEGER  --Numero da Conta
                                        ,pr_tpctrrat IN INTEGER  --Tipo Contrato Rating
                                        ,pr_nrctrrat IN INTEGER  --Numero Contrato Rating
                                        ,pr_idseqttl IN INTEGER  --Sequencial do Titular
                                        ,pr_idorigem IN INTEGER  --Identificador Origem
                                        ,pr_nmdatela IN VARCHAR2 --Nome da tela
                                        ,pr_inproces IN INTEGER  --Indicador do Processo
                                        ,pr_flgerlog IN BOOLEAN  --Gravar erro log
                                        ,pr_tab_erro OUT GENE0001.typ_tab_erro  --Tabela de retorno de erro
                                        ,pr_des_erro OUT VARCHAR2               --Indicador erro
                                        ,pr_dscritic OUT VARCHAR2);             --Descricao do erro

  /*****************************************************************************
   Procedure para calcular o risco cooperado para PF.
  *****************************************************************************/
  PROCEDURE pc_risco_cooperado_pf(pr_flgdcalc IN INTEGER  --> Indicador de calculo
                                 ,pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo Cooperativa
                                 ,pr_cdagenci IN crapass.cdagenci%TYPE --> Codigo Agencia
                                 ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Numero Caixa
                                 ,pr_cdoperad IN crapnrc.cdoperad%TYPE --> Codigo Operador
                                 ,pr_idorigem IN INTEGER               --> Identificador Origem
                                 ,pr_nrdconta IN crapass.nrdconta%TYPE --> Numero da Conta
                                 ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Sequencial do Titular
                                 ,pr_rw_crapdat IN btch0001.rw_crapdat%TYPE  --> Vetor com dados de par�metro (CRAPDAT)
                                 ,pr_tpctrato IN crapnrc.tpctrrat%TYPE --> Tipo Contrato Rating
                                 ,pr_nrctrato IN crapnrc.nrctrrat%TYPE --> Numero Contrato Rating
                                 ,pr_inusatab IN BOOLEAN  --> Indicador de utiliza��o da tabela de juros
                                 ,pr_flgcriar IN INTEGER  --> Indicado se deve criar o rating
                                 ,pr_flgttris    IN BOOLEAN             --> Indicado se deve carregar toda a crapris
                                 ,pr_tab_crapras IN OUT typ_tab_crapras --> Tabela com os registros a serem processados
                                 ,pr_notacoop OUT NUMBER                --> Retorna a nota da classifica��o
                                 ,pr_clascoop OUT VARCHAR2              --> retorna classifica��o
                                 ,pr_tab_erro OUT GENE0001.typ_tab_erro --> Tabela de retorno de erro
                                 ,pr_des_reto OUT VARCHAR2);            --> Indica��o de retorno OK/NOK

  /*****************************************************************************
   Procedure para calcular o risco cooperado para PJ.
  *****************************************************************************/
  PROCEDURE pc_risco_cooperado_pj(pr_flgdcalc IN INTEGER                     --> Indicador de calculo
                                 ,pr_cdcooper IN crapcop.cdcooper%TYPE       --> Codigo Cooperativa
                                 ,pr_cdagenci IN INTEGER                     --> Codigo Agencia
                                 ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE       --> Numero Caixa
                                 ,pr_cdoperad IN crapnrc.cdoperad%TYPE       --> Codigo Operador
                                 ,pr_idorigem IN INTEGER                     --> Identificador Origem
                                 ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Numero da Conta
                                 ,pr_idseqttl IN crapttl.idseqttl%TYPE       --> Sequencial do Titular
                                 ,pr_rw_crapdat IN btch0001.rw_crapdat%TYPE  --> Vetor com dados de par�metro (CRAPDAT)
                                 ,pr_tpctrato IN crapnrc.tpctrrat%TYPE       --> Tipo Contrato Rating
                                 ,pr_nrctrato IN crapnrc.nrctrrat%TYPE       --> Numero Contrato Rating
                                 ,pr_inusatab IN BOOLEAN                     --> Indicador de utiliza��o da tabela de juros
                                 ,pr_flgcriar IN INTEGER                     --> Indicado se deve criar o rating
                                 ,pr_flgttris IN BOOLEAN                     --> Indicado se deve carregar toda a crapris
                                 ,pr_tab_crapras IN OUT typ_tab_crapras      --> Tabela com os registros a serem processados
                                 ,pr_notacoop OUT NUMBER                     --> Retorna a nota da classifica��o
                                 ,pr_clascoop OUT VARCHAR2                   --> retorna classifica��o
                                 ,pr_tab_erro OUT GENE0001.typ_tab_erro      --> Tabela de retorno de erro
                                 ,pr_des_reto OUT VARCHAR2);                 --> Ind. de retorno OK/NOK

  /*****************************************************************************
   Procedure para calcular o rating do associado e gravar os registros na crapras.
  *****************************************************************************/
  PROCEDURE pc_calcula_rating(pr_cdcooper IN crapcop.cdcooper%TYPE                           --> Codigo Cooperativa
                             ,pr_cdagenci IN crapass.cdagenci%TYPE                           --> Codigo Agencia
                             ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE                           --> Numero Caixa
                             ,pr_cdoperad IN crapnrc.cdoperad%TYPE                           --> Codigo Operador
                             ,pr_nrdconta IN crapass.nrdconta%TYPE                           --> Numero da Conta
                             ,pr_tpctrato IN crapnrc.tpctrrat%TYPE                           --> Tipo Contrato Rating
                             ,pr_nrctrato IN crapnrc.nrctrrat%TYPE                           --> Numero Contrato Rating
                             ,pr_flgcriar IN OUT INTEGER                                     --> Indicado se deve criar o rating
                             ,pr_flgcalcu IN INTEGER                                         --> Indicador de calculo
                             ,pr_idseqttl IN crapttl.idseqttl%TYPE                           --> Sequencial do Titular
                             ,pr_idorigem IN INTEGER                                         --> Identificador Origem
                             ,pr_nmdatela IN craptel.nmdatela%TYPE                           --> Nome da tela
                             ,pr_flgerlog IN VARCHAR2                                        --> Identificador de gera��o de log
                             ,pr_tab_rating_sing       IN RATI0001.typ_tab_crapras           --> Registros gravados para rating singular
                             ----- OUT ----
                             ,pr_tab_impress_coop     OUT RATI0001.typ_tab_impress_coop     --> Registro impress�o da Cooperado
                             ,pr_tab_impress_rating   OUT RATI0001.typ_tab_impress_rating   --> Registro itens do Rating
                             ,pr_tab_impress_risco_cl OUT RATI0001.typ_tab_impress_risco    --> Registro Nota e risco do cooperado naquele Rating - PROVISAOCL
                             ,pr_tab_impress_risco_tl OUT RATI0001.typ_tab_impress_risco    --> Registro Nota e risco do cooperado naquele Rating - PROVISAOTL
                             ,pr_tab_impress_assina   OUT RATI0001.typ_tab_impress_assina   --> Assinatura na impressao do Rating
                             ,pr_tab_efetivacao       OUT RATI0001.typ_tab_efetivacao       --> Registro dos itens da efetiva��o
                             ,pr_tab_ratings          OUT RATI0001.typ_tab_ratings          --> Informacoes com os Ratings do Cooperado
                             ,pr_tab_crapras          OUT RATI0001.typ_tab_crapras          --> Tabela com os registros processados
                             ,pr_tab_erro             OUT GENE0001.typ_tab_erro             --> Tabela de retorno de erro
                             ,pr_des_reto             OUT VARCHAR2);                          --> Ind. de retorno OK/NOK
                             
                             
  /******************************************************************************
    Verifica se alguma operacao de Credito esta ativa.
    Limite de credito, descontos e emprestimo.
    Usada para ver se o Rating antigo pode ser desativado.
  ******************************************************************************/
  PROCEDURE pc_verifica_operacoes(pr_cdcooper    IN crapcop.cdcooper%TYPE       --> Codigo Cooperativa
                                 ,pr_cdagenci    IN crapass.cdagenci%TYPE       --> Codigo Agencia
                                 ,pr_nrdcaixa    IN craperr.nrdcaixa%TYPE       --> Numero Caixa
                                 ,pr_cdoperad    IN crapnrc.cdoperad%TYPE       --> Codigo Operador
                                 ,pr_rw_crapdat  IN btch0001.rw_crapdat%TYPE    --> Vetor com dados de par�metro (CRAPDAT)                                 
                                 ,pr_nrdconta    IN crapass.nrdconta%TYPE       --> Numero da Conta
                                 ,pr_idseqttl    IN crapttl.idseqttl%TYPE       --> Sequencia de titularidade da conta
                                 ,pr_idorigem    IN INTEGER                     --> Indicador da origem da chamada
                                 ,pr_nmdatela    IN craptel.nmdatela%TYPE       --> Nome da tela
                                 ,pr_flgerlog    IN VARCHAR2                    --> Identificador de gera��o de log
                                 ----- OUT ----
                                 ,pr_flgopera   OUT INTEGER               --> Tabela com os registros processados
                                 ,pr_tab_erro   OUT GENE0001.typ_tab_erro --> Tabela de retorno de erro
                                 ,pr_des_reto   OUT VARCHAR2);            --> Ind. de retorno OK/NOK
 
  /* Procedure efetivar o Rating */
  PROCEDURE pc_ratings_cooperado(pr_cdcooper   IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                ,pr_cdagenci   IN crapass.cdagenci%TYPE --> C�digo da ag�ncia
                                ,pr_nrdconta   IN crapass.nrdconta%TYPE --> Conta do associado
                                ,pr_nrregist IN INTEGER                 --> N�mero de registros
                                ,pr_nriniseq IN INTEGER                 --> N�mero sequencial 
                                ,pr_dtinirat   IN DATE                  --> Data de in�cio do Rating
                                ,pr_dtfinrat   IN DATE                  --> Data de termino do Rating
                                ,pr_insitrat   IN PLS_INTEGER           --> Situa��o do Rating
                                ,pr_qtregist    OUT INTEGER             --> Quantidade de registros encontrados
                                ,pr_tab_ratings OUT rati0001.typ_tab_ratings    --> Registro com os ratings do associado
                                ,pr_des_reto    OUT VARCHAR2);                --> Indicador erro
  
   
  /*****************************************************************************
   Verificar se um Rating efetivo pode ser Atualizado.
   Trazer o Contrato e risco a ser efetivado.      
  *****************************************************************************/
  PROCEDURE pc_verifica_atualizacao(pr_cdcooper IN crapcop.cdcooper%TYPE                           --> Codigo Cooperativa
                                   ,pr_cdagenci IN crapass.cdagenci%TYPE                           --> Codigo Agencia
                                   ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE                           --> Numero Caixa
                                   ,pr_cdoperad IN crapnrc.cdoperad%TYPE                           --> Codigo Operador
                                   ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE                           --> Data de movimento
                                   ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE                           --> Data do pr�ximo dia �til
                                   ,pr_inproces IN crapdat.inproces%TYPE                           --> Situa��o do processo
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE                           --> Numero da Conta
                                   ,pr_tpctrrat IN crapnrc.tpctrrat%TYPE                           --> Tipo Contrato Rating
                                   ,pr_nrctrrat IN crapnrc.nrctrrat%TYPE                           --> Numero Contrato Rating
                                   ,pr_idseqttl IN crapttl.idseqttl%TYPE                           --> Sequencial do Titular
                                   ,pr_idorigem IN INTEGER                                         --> Identificador Origem
                                   ,pr_nmdatela IN craptel.nmdatela%TYPE                           --> Nome da tela
                                   ,pr_flgerlog IN VARCHAR2                                        --> Identificador de gera��o de log
                                   ,pr_dsretorn IN BOOLEAN                                         --> Retornar
                                   ,pr_tab_rating_sing       IN rati0001.typ_tab_crapras           --> Registros gravados para rating singular
                                   ,pr_indrisco OUT VARCHAR2                                       --> Indicador do risco
                                   ,pr_nrnotrat OUT NUMBER                                         --> Nota do rating
                                   ,pr_rowidnrc OUT ROWID                                          --> Rowid do rating
                                   ,pr_tab_erro             OUT GENE0001.typ_tab_erro              --> Tabela de retorno de erro
                                   ,pr_des_reto             OUT VARCHAR2                           --> Ind. de retorno OK/NOK
                                   );
                                   
  /*****************************************************************************
   Realiza calculo do rating, alteracao solicitada pela ATURAT
  *****************************************************************************/
  PROCEDURE pc_proc_calcula(pr_cdcooper IN crapcop.cdcooper%TYPE                           --> Codigo Cooperativa
                           ,pr_cdagenci IN crapass.cdagenci%TYPE                           --> Codigo Agencia
                           ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE                           --> Numero Caixa
                           ,pr_cdoperad IN crapnrc.cdoperad%TYPE                           --> Codigo Operador
                           ,pr_nrdconta IN crapass.nrdconta%TYPE                           --> Numero da Conta
                           ,pr_tpctrato IN crapnrc.tpctrrat%TYPE                           --> Tipo Contrato Rating
                           ,pr_nrctrato IN crapnrc.nrctrrat%TYPE                           --> Numero Contrato Rating
                           ,pr_flgcriar IN INTEGER                                         --> Indicado se deve criar o rating
                           ,pr_idorigem IN INTEGER                                         --> Identificador Origem
                           ,pr_nmdatela IN craptel.nmdatela%TYPE                           --> Nome da tela
                           ,pr_inproces IN INTEGER
                           ,pr_insitrat IN INTEGER
                           ,pr_rowidnrc IN ROWID                                           --> Registro de rating
                           ,pr_tab_rating_sing       IN rati0001.typ_tab_crapras           --> Registros gravados para rating singular
                           ,pr_tab_impress_risco_tl OUT rati0001.typ_tab_impress_risco     --> Registro Nota e risco do cooperado naquele Rating - PROVISAOTL
                           ,pr_indrisco OUT VARCHAR2                                       --> Indicador do risco
                           ,pr_nrnotrat OUT crapnrc.nrnotrat%TYPE                          --> N�mero da nota
                           ,pr_tab_erro OUT GENE0001.typ_tab_erro                          --> Tabela de retorno de erro
                           ,pr_des_reto OUT VARCHAR2                                       --> Ind. de retorno OK/NOK
                           ) ;


  PROCEDURE pc_gera_rating(pr_cdcooper IN crapcop.cdcooper%TYPE            --> Codigo Cooperativa
                          ,pr_cdagenci IN crapass.cdagenci%TYPE            --> Codigo Agencia
                          ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE            --> Numero Caixa
                          ,pr_cdoperad IN crapnrc.cdoperad%TYPE            --> Codigo Operador
                          ,pr_nmdatela IN craptel.nmdatela%TYPE            --> Nome da tela
                          ,pr_idorigem IN INTEGER                          --> Identificador Origem
                          ,pr_nrdconta IN crapass.nrdconta%TYPE            --> Numero da Conta
                          ,pr_idseqttl IN crapttl.idseqttl%TYPE            --> Sequencial do Titular
                          ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE            --> Data de movimento
                          ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE            --> Data do pr�ximo dia �til
                          ,pr_inproces IN crapdat.inproces%TYPE            --> Situa��o do processo
                          ,pr_tpctrrat IN crapnrc.tpctrrat%TYPE            --> Tipo Contrato Rating
                          ,pr_nrctrrat IN crapnrc.nrctrrat%TYPE            --> Numero Contrato Rating
                          ,pr_flgcriar IN INTEGER                          --> Criar rating
                          ,pr_flgerlog IN INTEGER                          --> Identificador de gera��o de log
                          ,pr_tab_rating_sing IN rati0001.typ_tab_crapras  --> Registros gravados para rating singular
                          ,pr_tab_impress_coop     OUT rati0001.typ_tab_impress_coop     --> Registro impress�o da Cooperado
                          ,pr_tab_impress_rating   OUT rati0001.typ_tab_impress_rating   --> Registro itens do Rating
                          ,pr_tab_impress_risco_cl OUT rati0001.typ_tab_impress_risco    --> Registro Nota e risco do cooperado naquele Rating - PROVISAOCL
                          ,pr_tab_impress_risco_tl OUT rati0001.typ_tab_impress_risco    --> Registro Nota e risco do cooperado naquele Rating - PROVISAOTL
                          ,pr_tab_impress_assina   OUT rati0001.typ_tab_impress_assina   --> Assinatura na impressao do Rating
                          ,pr_tab_efetivacao       OUT rati0001.typ_tab_efetivacao       --> Registro dos itens da efetiva��o
                          ,pr_tab_ratings          OUT rati0001.typ_tab_ratings          --> Informacoes com os Ratings do Cooperado
                          ,pr_tab_crapras          OUT rati0001.typ_tab_crapras          --> Tabela com os registros processados
                          ,pr_tab_erro             OUT GENE0001.typ_tab_erro             --> Tabela de retorno de erro
                          ,pr_des_reto             OUT VARCHAR2                          --> Ind. de retorno OK/NOK
                          );

END RATI0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.RATI0001 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : RATI0001                     Antiga: sistema/generico/procedures/b1wgen0043.p
  --  Sistema  : Rotinas para Rating dos Cooperados
  --  Sigla    : RATI
  --  Autor    : Alisson C. Berrido - AMcom
  --  Data     : Maio/2013.                   Ultima atualizacao: 16/11/2015
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para Rating dos Cooperados.
  --
  -- Alteracao: 16/11/2015 - UPPER para comparacao do cdoperad no cursor da crapope (Tiago SD339476)
  --
  --            10/05/2016 - Ajustes referente a convers�o da tela ATURAT
  --                         (Andrei - RKAM).
  ---------------------------------------------------------------------------------------------------------------

  /* Tipo que compreende o vetor com valor do rating da TAB036 por coop */
  TYPE typ_tab_vlrating IS
    TABLE OF NUMBER
      INDEX BY BINARY_INTEGER; --> Utilizaremos a cooperativa como �ndice
  vr_vet_vlrating typ_tab_vlrating;

  /* Tipo para armazenamento das informa��es de risco e rating */
  TYPE typ_reg_provisao IS
    RECORD(dsdrisco VARCHAR2(3)
          ,percentu NUMBER
          ,notadefi NUMBER
          ,notatefi NUMBER
          ,parecefi VARCHAR2(15)
          ,notadeju NUMBER
          ,notateju NUMBER
          ,pareceju VARCHAR2(15));
  TYPE typ_tab_provisao IS
    TABLE OF typ_reg_provisao
      INDEX BY BINARY_INTEGER;
  vr_tab_provisao_cl typ_tab_provisao;
  vr_tab_provisao_tl typ_tab_provisao;

  /* Tipo para retornar uma lista de contrados a liquidar */
  TYPE typ_vet_nrctrliq IS VARRAY(10) OF PLS_INTEGER;

  -- Tipos para Vetores para armazenar valores das notas
  TYPE typ_vet_nota3 IS VARRAY(3) OF NUMBER;
  TYPE typ_vet_nota4 IS VARRAY(4) OF NUMBER;
  TYPE typ_vet_nota5 IS VARRAY(5) OF NUMBER;

  -- Temptable para armazenar qtd de dias de atrado riscos por cooperado
  type typ_reg_crapris_qtdiaatr is record
       (qtdiaatr  crapris.qtdiaatr%type,
        nrdconta  crapris.nrdconta%type,
        cdcooper  crapris.cdcooper%type);

  type typ_tab_crapris_qtdiaatr is table of typ_reg_crapris_qtdiaatr
  index by varchar2(30); --cdcooper(10) + nrdconta(10)

  vr_tab_crapris_qtdiaatr typ_tab_crapris_qtdiaatr;
  wglb_vlutiliz           number;

  /* CURSORES GENERICOS PARA OS CALCULOS DE RATING JUR E FIS */
  -- Buscar dados do emprestimo
  CURSOR cr_crawepr(pr_cdcooper IN crapcop.cdcooper%TYPE
                   ,pr_nrdconta IN crawepr.nrdconta%TYPE
                   ,pr_nrctrato IN crawepr.nrctremp%TYPE) IS
    SELECT idquapro
          ,qtpreemp
          ,cdlcremp
          ,vlemprst
          ,vlpreemp
          ,NRCTRLIQ##1
          ,NRCTRLIQ##2
          ,NRCTRLIQ##3
          ,NRCTRLIQ##4
          ,NRCTRLIQ##5
          ,NRCTRLIQ##6
          ,NRCTRLIQ##7
          ,NRCTRLIQ##8
          ,NRCTRLIQ##9
          ,NRCTRLIQ##10
      FROM crawepr
     WHERE crawepr.cdcooper = pr_cdcooper
       AND crawepr.nrdconta = pr_nrdconta
       AND crawepr.nrctremp = pr_nrctrato;

  -- Buscar dados do emprestimo
  CURSOR cr_crapepr(pr_cdcooper IN crapcop.cdcooper%TYPE
                   ,pr_nrdconta IN crawepr.nrdconta%TYPE
                   ,pr_nrctrato IN crawepr.nrctremp%TYPE) IS
    SELECT qtpreemp
          ,cdlcremp
          ,vlemprst
          ,vlpreemp
      FROM crapepr
     WHERE crapepr.cdcooper = pr_cdcooper
       AND crapepr.nrdconta = pr_nrdconta
       AND crapepr.nrctremp = pr_nrctrato;

  -- Ler Cadastros de propostas.
  CURSOR cr_crapprp(pr_cdcooper IN crapprp.cdcooper%TYPE
                   ,pr_nrdconta IN crapprp.nrdconta%TYPE
                   ,pr_tpctrato IN crapprp.tpctrato%TYPE
                   ,pr_nrctrato IN crapprp.nrctrato%TYPE) IS
    SELECT nrgarope
          ,qtparbnd
          ,nrliquid
          ,vlctrbnd
          ,nrinfcad
          ,nrpatlvr
          ,vltotsfn
          ,nrperger
      FROM crapprp
     WHERE crapprp.cdcooper = pr_cdcooper
       AND crapprp.nrdconta = pr_nrdconta
       AND crapprp.tpctrato = pr_tpctrato
       AND crapprp.nrctrato = pr_nrctrato;

  -- Ler Cadastro de Linhas de Credito
  CURSOR cr_craplcr(pr_cdcooper craplcr.cdcooper%type
                   ,pr_cdlcremp craplcr.cdlcremp%type) IS
    SELECT dsoperac
      FROM craplcr
     WHERE craplcr.cdcooper = pr_cdcooper
       AND craplcr.cdlcremp = pr_cdlcremp;

  -- Ler Contratos de Limite de credito
  CURSOR cr_craplim(pr_cdcooper IN craplim.cdcooper%TYPE
                   ,pr_nrdconta IN craplim.nrdconta%TYPE
                   ,pr_tpctrato IN craplim.tpctrlim%TYPE
                   ,pr_nrctrato IN craplim.nrctrlim%TYPE) IS
    SELECT nrgarope
          ,nrliquid
          ,qtdiavig
          ,vllimite
          ,tpctrlim
          ,nrinfcad
          ,nrpatlvr
          ,insitlim
          ,vltotsfn
          ,nrperger
      FROM craplim
     WHERE craplim.cdcooper = pr_cdcooper
       AND craplim.nrdconta = pr_nrdconta
       AND craplim.tpctrlim = pr_tpctrato
       AND craplim.nrctrlim = pr_nrctrato;

  -- Selecionar rating
  CURSOR cr_crapnrc (pr_cdcooper IN crapnrc.cdcooper%type
                    ,pr_nrdconta IN crapnrc.nrdconta%type
                    ,pr_tpctrrat IN crapnrc.tpctrrat%type
                    ,pr_nrctrrat IN crapnrc.nrctrrat%type) IS
    SELECT crapnrc.flgativo
          ,ROWID
      FROM crapnrc
     WHERE crapnrc.cdcooper = pr_cdcooper
       AND crapnrc.nrdconta = pr_nrdconta
       AND crapnrc.tpctrrat = pr_tpctrrat
       AND crapnrc.nrctrrat = pr_nrctrrat;

  -- Pegar o registro com mais dias de atrasos - Modalidade emprestimo
  -- Nos ultimos 12 meses
  CURSOR cr_crapris (pr_cdcooper crapris.cdcooper%TYPE
                    ,pr_nrdconta crapris.nrdconta%TYPE
                    ,pr_dtmvtolt crapris.dtrefere%TYPE)IS
    SELECT cdcooper, nrdconta, nvl(max(nvl(qtdiaatr,0)),0) qtdiaatr
      FROM crapris
     WHERE crapris.cdcooper = pr_cdcooper
       AND crapris.nrdconta = pr_nrdconta
       AND crapris.dtrefere >= add_months(pr_dtmvtolt,-12) -- 12 meses atras
       AND crapris.dtrefere <= (pr_dtmvtolt - to_char(pr_dtmvtolt,'DD')) -- Ult dia mes anterior
       AND crapris.inddocto = 1            --> Somente ativos
       AND crapris.cdmodali in (299, 499) --> Somente de empr�stimos
     GROUP BY cdcooper, nrdconta;

  CURSOR cr_crapris_all (pr_dtmvtolt crapris.dtrefere%TYPE)IS
    SELECT cdcooper, nrdconta, nvl(max(nvl(qtdiaatr,0)),0) qtdiaatr
      FROM crapris
     WHERE crapris.dtrefere >= add_months(pr_dtmvtolt,-12) -- 12 meses atras
       AND crapris.dtrefere <= (pr_dtmvtolt - to_char(pr_dtmvtolt,'DD')) -- Ult dia mes anterior
       AND crapris.inddocto = 1            --> Somente ativos
       AND crapris.cdmodali in (299, 499) --> Somente de empr�stimos
     GROUP BY cdcooper, nrdconta;

  -- Busca dos s�cios cadastrados
  -- (Traz o mais antigo primeiro)
  CURSOR cr_crapavt(pr_cdcooper crapris.cdcooper%TYPE
                   ,pr_nrdconta crapris.nrdconta%TYPE) IS
    SELECT dtadmsoc
      FROM crapavt
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND tpctrato = 6
       AND dsproftl IN ('SOCIO/PROPRIETARIO','SOCIO ADMINISTRADOR',
                        'DIRETOR/ADMINISTRADOR','SINDICO','ADMINISTRADOR')
     ORDER BY dtadmsoc DESC;

  /* Rotina responsavel por buscar a descri��o da operacao do tipo de contrato */
  FUNCTION fn_busca_descricao_operacao (pr_tpctrrat IN INTEGER) RETURN VARCHAR2 IS
  BEGIN
  /* ..........................................................................

     Programa: fn_busca_descricao_operacao         Antigo: b1wgen0043.p/descricao-operacao
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Alisson C. Berrido
     Data    : Maio/2013.                          Ultima Atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  : Buscar a descricao da operacao

     Alteracoes: 29/05/2013 - Convers�o Progress -> Oracle - Alisson (AMcom)

  ............................................................................. */
    DECLARE

      /* Tipo de tabela para as descricoes dos tipos de Rating */
      TYPE typ_tab_dsctrrat IS VARRAY(4) OF VARCHAR2(20);
      /* Vetor Contendo os tipos de contrato */
      vr_tab_dsctrrat typ_tab_dsctrrat := typ_tab_dsctrrat
                                          ('Limite Credito','Descto. Cheque'
                                          ,'Descto. Titulo','Emprestimo');
    BEGIN
      --Verificar o tipo de contrato passado como parametro
      CASE pr_tpctrrat
        WHEN 1 THEN
          RETURN (vr_tab_dsctrrat(1));
        WHEN 2 THEN
          RETURN (vr_tab_dsctrrat(2));
        WHEN 3 THEN
          RETURN (vr_tab_dsctrrat(3));
        WHEN 90 THEN
          RETURN (vr_tab_dsctrrat(4));
        ELSE
          RETURN NULL;
      END CASE;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;
    END;
  END;

  /* Rotina responsavel por buscar a descri��o da situacao do contrato */
  FUNCTION fn_busca_descricao_situacao (pr_insitrat IN INTEGER) RETURN VARCHAR2 IS
  BEGIN
  /* ..........................................................................

     Programa: fn_busca_descricao_situacao         Antigo: b1wgen0043.p/descricao-situacao
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Marcos E. Martini
     Data    : Agosto/2014.                          Ultima Atualizacao: 27/08/2014

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  : Buscar a descricao da situa��o do contrato

     Alteracoes: 27/07/2014 - Convers�o Progress -> Oracle - Marcos (Supero)

  ............................................................................. */
    BEGIN
      -- Retonar a situa��o conforme o c�digo (Dom�nio)
      CASE pr_insitrat
        WHEN 1 THEN
          RETURN 'Proposto';
        WHEN 2 THEN
          RETURN 'Efetivo';
        ELSE
          RETURN ' ';
      END CASE;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;
    END;
  END;

  /*Verificar se o item digitado existe.*/
  FUNCTION fn_valida_item_rating (pr_cdcooper IN crapcop.cdcooper%TYPE
                                 ,pr_nrtopico IN craprad.nrtopico%TYPE
                                 ,pr_nritetop IN craprad.nritetop%TYPE
                                 ,pr_nrseqite IN craprad.nrseqite%TYPE) RETURN BOOLEAN IS
  BEGIN
  /* ..........................................................................

     Programa: fn_valida_item_rating         Antigo: b1wgen0043.p/valida-item-rating
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Andrei
     Data    : Maio/2016.                          Ultima Atualizacao: 

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  : Verificar se o item digitado existe.

     Alteracoes: 

  ............................................................................. */
    DECLARE 
     
      CURSOR cr_craprad(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrtopico IN craprad.nrtopico%TYPE
                       ,pr_nritetop IN craprad.nritetop%TYPE
                       ,pr_nrseqite IN craprad.nrseqite%TYPE) IS
      SELECT craprad.nrtopico
        FROM craprad
       WHERE craprad.cdcooper = pr_cdcooper
         AND craprad.nrtopico = pr_nrtopico
         AND craprad.nritetop = pr_nritetop
         AND craprad.nrseqite = pr_nrseqite;
      rw_craprad cr_craprad%ROWTYPE;   
    
    BEGIN
      OPEN cr_craprad(pr_cdcooper => pr_cdcooper
                     ,pr_nrtopico => pr_nrtopico
                     ,pr_nritetop => pr_nritetop
                     ,pr_nrseqite => pr_nrseqite);
                     
      FETCH cr_craprad INTO rw_craprad;
      
      IF cr_craprad%NOTFOUND THEN
         
        --Fechar o cursor
        CLOSE cr_craprad;
        
        RETURN FALSE;
      
      ELSE
        --Fechar o cursor
        CLOSE cr_craprad;
        
        RETURN TRUE;
        
      END IF;                 
                     
    EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;
    END;
    
  END;

  /* Rotina respons�vel por obter o nivel de risco */
  PROCEDURE pc_obtem_risco (pr_cdcooper       IN crapcop.cdcooper%TYPE --C�digo da Cooperativa
                           ,pr_nrdconta       IN crapass.nrdconta%TYPE --Numero da Conta do Associado
                           ,pr_tab_dsdrisco   IN RATI0001.typ_tab_dsdrisco --Vetor com dados das provisoes
                           ,pr_dstextab_bacen IN craptab.dstextab%TYPE --Descricao da craptab do RISCOBACEN
                           ,pr_dtmvtolt       IN crapdat.dtmvtolt%TYPE --Data Movimento
                           ,pr_nivrisco       OUT VARCHAR2             --Nivel de Risco
                           ,pr_dtrefere       OUT DATE                 --Data de Referencia do Risco
                           ,pr_cdcritic       OUT INTEGER              --C�digo da Critica de Erro
                           ,pr_dscritic       OUT VARCHAR2) IS         --Descricao do erro
  BEGIN
  /* ..........................................................................

     Programa: pc_obtem_risco         Antigo: b1wgen9999.p/obtem_risco
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Alisson C. Berrido
     Data    : Maio/2013.                          Ultima Atualizacao: 29/03/2016

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  : Buscar o nivel de risco da conta

     Alteracoes: 29/05/2013 - Convers�o Progress -> Oracle - Alisson (AMcom)

               25/06/2014 - Ajuste leitura crapris. SoftDesk 137892 (Daniel)
               
               14/08/2015 - Ajuste na leitura crapris para as operacoes menor que o
                            valor do arrasto. (James)
                            
               29/03/2016 - Replicar manuten��o realizada no progress SD352945 (Odirlei-AMcom)

  ............................................................................. */
    DECLARE

      --Cursores Locais

      --Selecionar informacoes do risco
      CURSOR cr_crapris (pr_cdcooper IN crapris.cdcooper%TYPE
                        ,pr_nrdconta IN crapris.nrdconta%TYPE
                        ,pr_inddocto IN crapris.inddocto%TYPE
                        ,pr_vldivida IN crapris.vldivida%TYPE
                        ,pr_dtrefere IN crapris.dtrefere%TYPE) IS
        SELECT crapris.dtrefere
              ,crapris.innivris
        FROM crapris crapris
        WHERE crapris.cdcooper = pr_cdcooper
        AND   crapris.nrdconta = pr_nrdconta
        AND   crapris.inddocto = pr_inddocto
        AND   crapris.vldivida > pr_vldivida
        AND   crapris.dtrefere <= pr_dtrefere
        ORDER BY crapris.progress_recid DESC;

      --Selecionar informacoes do risco
      CURSOR cr_crapris2 (pr_cdcooper IN crapris.cdcooper%TYPE
                         ,pr_nrdconta IN crapris.nrdconta%TYPE
                         ,pr_inddocto IN crapris.inddocto%TYPE
                         ,pr_dtrefere IN crapris.dtrefere%TYPE) IS
        SELECT crapris.dtrefere
              ,crapris.innivris
        FROM crapris crapris
        WHERE crapris.cdcooper = pr_cdcooper
        AND   crapris.nrdconta = pr_nrdconta
        AND   crapris.inddocto = pr_inddocto
        AND   crapris.dtrefere <= pr_dtrefere
        ORDER BY crapris.progress_recid DESC;
      rw_crapris cr_crapris%ROWTYPE;

      --Variaveis Locais
      vr_vlarrast NUMBER:= 0;

      vr_dtultdma DATE;
      vr_dtmvtolt DATE;

    BEGIN
      --Inicializar variavei de retorno
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      --verificar se foi passado parametro RISCOBACEN
      IF pr_dstextab_bacen IS NOT NULL THEN
        --Valor arrasto
        vr_vlarrast:= GENE0002.fn_char_para_number(SubStr(pr_dstextab_bacen,3,9));
      END IF;

      --> Ultimo dia do mes passado 
      vr_dtultdma := pr_dtmvtolt - to_char(pr_dtmvtolt,'DD');

      /** Valor Arrasto **/
      OPEN cr_crapris (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_inddocto => 1
                      ,pr_vldivida => vr_vlarrast
                      ,pr_dtrefere => vr_dtultdma);
      --Posicionar no primeiro registro
      FETCH cr_crapris INTO rw_crapris;
      IF cr_crapris%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapris;
        --Selecionar risco sem considerar valor
        OPEN cr_crapris2 (pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_inddocto => 1
                         ,pr_dtrefere => vr_dtultdma);
        --Posicionar no primeiro registro
        FETCH cr_crapris2 INTO rw_crapris;
        --Se Encontrou
        IF cr_crapris2%FOUND THEN
          --Retornar o nivel de risco
          IF rw_crapris.innivris = 10 THEN
            pr_nivrisco := pr_tab_dsdrisco(rw_crapris.innivris);
          ELSE
            pr_nivrisco := pr_tab_dsdrisco(2);
            
          END IF;
          
          --Retornar a data de referencia
          pr_dtrefere:= rw_crapris.dtrefere;
        END IF;
        --Fechar Cursor
        CLOSE cr_crapris2;
      ELSE
        --Retornar o nivel de risco
        pr_nivrisco:= pr_tab_dsdrisco(rw_crapris.innivris);
        --Retornar a data de referencia
        pr_dtrefere:= rw_crapris.dtrefere;
      END IF;
      --Fechar Cursor
      IF cr_crapris%ISOPEN THEN
        CLOSE cr_crapris;
      END IF;

      --Verificar se s�o contratos antigos
      IF Upper(Trim(pr_nivrisco)) = 'AA' THEN
        pr_nivrisco:= NULL;
        pr_dtrefere:= NULL;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na rotina RATI0001.pc_obtem_risco '||SQLERRM;
    END;
  END;

  /* Retornar o valor de par�metro de rating da TAB036 */
  PROCEDURE pc_param_valor_rating(pr_cdcooper  IN crapcop.cdcooper%TYPE --> C�digo da Cooperativa
                                 ,pr_vlrating OUT NUMBER                --> Valor parametrizado
                                 ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                 ,pr_dscritic OUT VARCHAR2) IS          --> Descri��o erro encontrado
  BEGIN
    /* ..........................................................................

       Programa: pc_param_valor_rating         Antigo: b1wgen0043 --> parametro_valor_rating
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Marcos Ernani Martini
       Data    : Junho/2013.                          Ultima Atualizacao: 25/10/2016

       Dados referentes ao programa:

       Frequencia: Sempre que chamado por outros programas.
       Objetivo  : Retornar valor parametrizado de rating na TAB036 para a Cooperativa.

       Alteracoes: 04/06/2013 - Convers�o Progress -> Oracle - Marcos (Supero)
                                      
    ............................................................................. */
    DECLARE
      /* Cursor gen�rico de parametriza��o */
      CURSOR cr_craptab(pr_nmsistem IN craptab.nmsistem%TYPE
                       ,pr_tptabela IN craptab.tptabela%TYPE
                       ,pr_cdempres IN craptab.cdempres%TYPE
                       ,pr_cdacesso IN craptab.cdacesso%TYPE
                       ,pr_tpregist IN craptab.tpregist%TYPE) IS
        SELECT tab.cdcooper
              ,tab.dstextab
          FROM craptab tab
         WHERE tab.cdcooper        = pr_cdcooper
           AND UPPER(tab.nmsistem) = pr_nmsistem
           AND UPPER(tab.tptabela) = pr_tptabela
           AND tab.cdempres        = pr_cdempres
           AND UPPER(tab.cdacesso) = pr_cdacesso
           AND tab.tpregist        = pr_tpregist;
    BEGIN
      -- Se a tabela com as informa��es de valor por coop estiver vazia
      IF vr_vet_vlrating.COUNT = 0 THEN
        -- Busca de todos registros para atualizar o vetor
        FOR rw_craptab IN cr_craptab(pr_nmsistem => 'CRED'
                                    ,pr_tptabela => 'GENERI'
                                    ,pr_cdempres => 00
                                    ,pr_cdacesso => 'PROVISAOCL'
                                    ,pr_tpregist => 999) LOOP
          -- Adicionar no vetor cmfe a cooperativa do registro e o valor
          -- de rating est� nas 11 posi��es a partir do caracter 15 do par�metro
          vr_vet_vlrating(rw_craptab.cdcooper) := gene0002.fn_char_para_number(substr(rw_craptab.dstextab,15,11));
        END LOOP;
      END IF;
      -- Com a temp-table carregada, iremos buscar o valor correspondente a cooperativa solicitada
      pr_vlrating := vr_vet_vlrating(pr_cdcooper);
      -- Se n�o encontrou informa��o
      IF pr_vlrating IS NULL THEN
        -- Gerar critica 55
        pr_cdcritic := 55;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- Gerar erro n�o tratado
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na rotina RATI0001.pc_param_valor_rating. Detalhes: '||sqlerrm;
    END;
  END pc_param_valor_rating;

  /* Retornar o valor maximo legal da Cooperativa */
  PROCEDURE pc_valor_maximo_legal(pr_cdcooper  IN crapcop.cdcooper%TYPE --> C�digo da Cooperativa
                                 ,pr_vlmaxleg OUT NUMBER                --> Valor parametrizado
                                 ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                 ,pr_dscritic OUT VARCHAR2) IS          --> Descri��o erro encontrado
  BEGIN
    /* ..........................................................................

       Programa: pc_valor_maximo_legal         Antigo: b1wgen0043 --> valor_maximo_legal
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Marcos Ernani Martini
       Data    : Junho/2013.                          Ultima Atualizacao: 04/06/2013

       Dados referentes ao programa:

       Frequencia: Sempre que chamado por outros programas.
       Objetivo  : Retornar valor maximo legal cadastrado na CADCOP

       Alteracoes: 04/06/2013 - Convers�o Progress -> Oracle - Marcos (Supero)

    ............................................................................. */
    DECLARE
      -- Busca da cooperativa
      CURSOR cr_crapcop IS
        SELECT vlmaxleg
          FROM crapcop
         WHERE cdcooper = pr_cdcooper;
    BEGIN
      -- Buscar na CADCOP
      OPEN cr_crapcop;
      FETCH cr_crapcop
       INTO pr_vlmaxleg;
      -- Se n�o encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Gerar critica 651
        pr_cdcritic := 651;
      END IF;
      -- Fechar o cursor
      CLOSE cr_crapcop;
    EXCEPTION
      WHEN OTHERS THEN
        -- Gerar erro n�o tratado
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na rotina RATI0001.pc_valor_maximo_legal. Detalhes: '||sqlerrm;
    END;
  END pc_valor_maximo_legal;

  /* Limpar campo da origem do Rating */
  PROCEDURE pc_limpa_rating_origem(pr_cdcooper  IN crapcop.cdcooper%TYPE     --> C�digo da Cooperativa
                                  ,pr_nrdconta  IN crapass.nrdconta%TYPE     --> Conta do associado
                                  ,pr_dscritic OUT VARCHAR2) IS              --> Descritivo do erro
  BEGIN
    /* ..........................................................................

       Programa: pc_limpa_rating_origem         Antigo: b1wgen0043 --> limpa_rating_origem
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Marcos Ernani Martini
       Data    : Junho/2013.                          Ultima Atualizacao: 03/06/2013

       Dados referentes ao programa:

       Frequencia: Sempre que chamado por outros programas.
       Objetivo  : Limpar campo da origem do Rating.

       Alteracoes: 03/06/2013 - Convers�o Progress -> Oracle - Marcos (Supero)

    ............................................................................. */
    BEGIN
      UPDATE crapnrc
         SET flgorige = 0 -- False
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta;
    EXCEPTION
      WHEN OTHERS THEN
        -- Gerar erro
        pr_dscritic := 'Erro na rotina RATI0001.pc_limpa_rating_origem. Detalhes: '||sqlerrm;
    END;
  END pc_limpa_rating_origem;

  /* Gravar o Rating que deu origem ao efetivo. */
  PROCEDURE pc_grava_rating_origem(pr_cdcooper  IN crapcop.cdcooper%TYPE     --> C�digo da Cooperativa
                                  ,pr_nrdconta  IN crapass.nrdconta%TYPE     --> Conta do associado
                                  ,pr_rowidnrc  IN ROWID DEFAULT NULL        --> Rowid para grava��o do rating
                                  ,pr_tpctrato  IN PLS_INTEGER DEFAULT 0     --> Tipo do contrato de rating
                                  ,pr_nrctrato  IN PLS_INTEGER DEFAULT 0     --> N�mero do contrato do rating
                                  ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Critica encontrada no processo
                                  ,pr_dscritic OUT VARCHAR2) IS              --> Descritivo do erro
  BEGIN
    /* ..........................................................................

       Programa: pc_grava_rating_origem         Antigo: b1wgen0043 --> grava_rating_origem
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Marcos Ernani Martini
       Data    : Junho/2013.                          Ultima Atualizacao: 03/06/2013

       Dados referentes ao programa:

       Frequencia: Sempre que chamado por outros programas.
       Objetivo  : Gravar o Rating que deu origem ao efetivo.

       Alteracoes: 03/06/2013 - Convers�o Progress -> Oracle - Marcos (Supero)

    ............................................................................. */
    DECLARE
      -- Var auxiliar para armazenar o Rowid a processar
      vr_rowidnrc rowid;
      -- Busca de rating para a proposta solicitada
      CURSOR cr_crapnrc IS
        SELECT rowid
          FROM crapnrc
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND tpctrrat = pr_tpctrato
           AND nrctrrat = pr_nrctrato;
    BEGIN
      -- Se j� foi passado o Rowid a processar
      IF pr_rowidnrc IS NOT NULL THEN
        -- Utilizaremos o mesmo
        vr_rowidnrc := pr_rowidnrc;
      ELSE
        -- Buscar o mesmo com base nos par�metros passados
        OPEN cr_crapnrc;
        FETCH cr_crapnrc
         INTO vr_rowidnrc;
        CLOSE cr_crapnrc;
      END IF;
      -- Se chegou neste ponto sem o Rowid
      IF vr_rowidnrc IS NULL THEN
        -- Gerar critica 55
        pr_cdcritic := 55;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      ELSE
        -- Salvar Origem do Rating efetivo
        UPDATE crapnrc
           SET flgorige = 1 -- True
         WHERE rowid = vr_rowidnrc;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- Retorno n�o OK
        pr_cdcritic := 0;
        -- Gerar erro
        pr_dscritic := 'Erro n�o tratado na rotina RATI0001.pc_grava_rating_origem. Detalhes: '||sqlerrm;
    END;
  END pc_grava_rating_origem;

  /* Mudar situacao do Rating para efetivo */
  PROCEDURE pc_muda_situacao_efetivo(pr_rowidnrc  IN ROWID DEFAULT NULL        --> Rowid para grava��o do rating
                                    ,pr_cdoperad  IN crapnrc.cdoperad%TYPE     --> C�digo do operador
                                    ,pr_dtmvtolt  IN DATE                      --> Data atual
                                    ,pr_vlutiliz  IN NUMBER                    --> Valor para lan�amento
                                    ,pr_flgatual  IN BOOLEAN                   --> Flag para atualiza��o sim/nao
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Critica encontrada no processo
                                    ,pr_dscritic OUT VARCHAR2) IS              --> Descritivo do erro
  BEGIN
    /* ..........................................................................

       Programa: pc_muda_situacao_efetivo         Antigo: b1wgen0043 --> muda_situacao_efetivo
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Marcos Ernani Martini
       Data    : Junho/2013.                          Ultima Atualizacao: 04/06/2013

       Dados referentes ao programa:

       Frequencia: Sempre que chamado por outros programas.
       Objetivo  : Mudar situacao do Rating para Efetivo.

       Alteracoes: 04/06/2013 - Convers�o Progress -> Oracle - Marcos (Supero)

    ............................................................................. */
    DECLARE
      -- Sa�da com erro
      vr_exc_erro EXCEPTION;
      -- Busca de rating para a proposta solicitada
      CURSOR cr_crapnrc IS
        SELECT cdcooper
              ,nrdconta
              ,dtmvtolt
              ,inrisctl
              ,nrnotatl
          FROM crapnrc
         WHERE rowid = pr_rowidnrc;
      rw_crapnrc cr_crapnrc%ROWTYPE;
    BEGIN
      -- Buscar as informa��es do rating a partir do Rowid
      OPEN cr_crapnrc;
      FETCH cr_crapnrc
       INTO rw_crapnrc;
      -- Se n�o encontrou informa��es
      IF cr_crapnrc%NOTFOUND THEN
        -- Gerar critica 55
        CLOSE cr_crapnrc;
        pr_cdcritic := 55;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
        RAISE vr_exc_erro;
      ELSE
        -- Apenar fechar e continuar
        CLOSE cr_crapnrc;
      END IF;
      -- Quando o rating for efetivado, atualizar os dados do cooperado
      BEGIN
        UPDATE crapass
           SET dtrisctl = rw_crapnrc.dtmvtolt
              ,inrisctl = rw_crapnrc.inrisctl
              ,nrnotatl = rw_crapnrc.nrnotatl
         WHERE cdcooper = rw_crapnrc.cdcooper
           AND nrdconta = rw_crapnrc.nrdconta;
      EXCEPTION
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro ao atualizar os dados do Cooperado(CRAPASS), Conta: '||rw_crapnrc.nrdconta||'. Detalhes: '||sqlerrm;
          -- Sair
          RAISE vr_exc_erro;
      END;
      -- Se esta atualizando ou criando
      IF pr_flgatual THEN
        -- Utilizar a data atual para atualizar o rating
        rw_crapnrc.dtmvtolt := pr_dtmvtolt;
      END IF;
      -- Enfim, atualizar o rating
      BEGIN
        UPDATE crapnrc
           SET insitrat = 2 -- Efetivado
              ,cdoperad = nvl(pr_cdoperad,' ')
              ,dtmvtolt = rw_crapnrc.dtmvtolt --> Cfme F acima
              ,dteftrat = pr_dtmvtolt
              ,vlutlrat = nvl(pr_vlutiliz,0)
         WHERE rowid = pr_rowidnrc;
      EXCEPTION
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro ao atualizar o rating(CRAPNRC), Rowid: '||pr_rowidnrc||'. Detalhes: '||sqlerrm;
          -- Sair
          RAISE vr_exc_erro;
      END;
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Concatenar o nome do rotina e retornar
        pr_dscritic := 'Erro na rotina RATI0001.pc_muda_situacao_efetivo. Detalhes: '||pr_dscritic;
      WHEN OTHERS THEN
        -- Retorno n�o OK
        pr_cdcritic := 0;
        -- Gerar erro
        pr_dscritic := 'Erro n�o tratado na rotina RATI0001.pc_muda_situacao_efetivo. Detalhes: '||sqlerrm;
    END;
  END pc_muda_situacao_efetivo;

  /* Mudar situacao do Rating para proposto */
  PROCEDURE pc_muda_situacao_proposto(pr_cdcooper  IN crapcop.cdcooper%TYPE     --> C�digo da Cooperativa
                                     ,pr_nrdconta  IN crapass.nrdconta%TYPE     --> Conta do associado
                                     ,pr_dtmvtolt  IN DATE                      --> Data atual
                                     ,pr_vlutiliz  IN NUMBER                    --> Valor para lan�amento
                                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Critica encontrada no processo
                                     ,pr_dscritic OUT VARCHAR2) IS              --> Descritivo do erro
  BEGIN
    /* ..........................................................................

       Programa: pc_muda_situacao_proposto         Antigo: b1wgen0043 --> muda_situacao_proposto
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Marcos Ernani Martini
       Data    : Junho/2013.                          Ultima Atualizacao: 04/06/2013

       Dados referentes ao programa:

       Frequencia: Sempre que chamado por outros programas.
       Objetivo  : Mudar situacao do Rating para proposto.

       Alteracoes: 04/06/2013 - Convers�o Progress -> Oracle - Marcos (Supero)

    ............................................................................. */
    DECLARE
      -- Sa�da com erro
      vr_exc_erro EXCEPTION;
      -- Busca de rating para a proposta solicitada
      CURSOR cr_crapnrc IS
        SELECT rowid
              ,nrdconta
              ,dtmvtolt
              ,tpctrrat
              ,nrctrrat
              ,flgativo
          FROM crapnrc
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND insitrat = 2; -- Efetivo
      rw_crapnrc cr_crapnrc%ROWTYPE;
      -- Variaveis auxiliares
      vr_dtmvtolt crapnrc.dtmvtolt%TYPE; -- Data do rating + 6 meses
      vr_flgativo crapnrc.flgativo%TYPE; -- Flag para ativa��o ou n�o do rating
    BEGIN
      -- Buscar as informa��es do rating a partir do Rowid
      OPEN cr_crapnrc;
      FETCH cr_crapnrc
       INTO rw_crapnrc;
      -- Se n�o encontrou informa��es
      IF cr_crapnrc%NOTFOUND THEN
        -- Apenas fechar o cursor e n�o � necess�ria nenhuma atualiza��o
        CLOSE cr_crapnrc;
      ELSE
        -- Fechar e continuar
        CLOSE cr_crapnrc;
        -- Adicionar 6 meses a data do rating
        vr_dtmvtolt := ADD_MONTHS(rw_crapnrc.dtmvtolt,6);
        -- Se hoje eh maior ou igual a efetivacao + 6 meses Ou se � um Rating antigo ... entao DESATIVA
        IF pr_dtmvtolt >= vr_dtmvtolt  OR (rw_crapnrc.tpctrrat = 0 AND rw_crapnrc.nrctrrat = 0) THEN
          -- Desativaremos o Rating
          vr_flgativo := 0;
        ELSE
          -- Manteremos o valor da tabela
          vr_flgativo := rw_crapnrc.flgativo;
        END IF;
        -- Muda para proposto e atualiza saldo utilizado
        BEGIN
          UPDATE crapnrc
             SET insitrat = 1 -- Proposto
                ,flgativo = vr_flgativo -- Cfme if acima
                ,dteftrat = null
                ,vlutlrat = nvl(pr_vlutiliz,0)
           WHERE rowid = rw_crapnrc.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            pr_cdcritic := 0;
            pr_dscritic := 'Erro ao atualizar o rating(CRAPNRC), Rowid: '||rw_crapnrc.rowid||'. Detalhes: '||sqlerrm;
            -- Sair
            RAISE vr_exc_erro;
        END;
        -- Como esta desefetivando, limpa a origem do Rating
        pc_limpa_rating_origem(pr_cdcooper => pr_cdcooper   --> C�digo da Cooperativa
                              ,pr_nrdconta => pr_nrdconta   --> Conta do associado
                              ,pr_dscritic => pr_dscritic); --> Descritivo do erro
        -- Se encontrou erro
        IF pr_dscritic IS NOT NULL THEN
          -- Gerar o erro
          pr_cdcritic := 0;
          RAISE vr_exc_erro;
        END IF;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Concatenar o nome do rotina e retornar
        pr_dscritic := 'Erro na rotina RATI0001.pc_muda_situacao_proposto. Detalhes: '||pr_dscritic;
      WHEN OTHERS THEN
        -- Retorno n�o OK
        pr_cdcritic := 0;
        -- Gerar erro
        pr_dscritic := 'Erro n�o tratado na rotina RATI0001.pc_muda_situacao_proposto. Detalhes: '||sqlerrm;
    END;
  END pc_muda_situacao_proposto;

  /* Retornar o Rating Proposto com pior nota. */
  PROCEDURE pc_procura_pior_nota(pr_cdcooper  IN crapcop.cdcooper%TYPE     --> C�digo da Cooperativa
                                ,pr_nrdconta  IN crapass.nrdconta%TYPE     --> Conta do associado
                                ,pr_indrisco OUT crapnrc.indrisco%TYPE     --> Risco do pior rating
                                ,pr_rowidnrc OUT ROWID                     --> Rowid do pior rating
                                ,pr_nrctrrat OUT crapnrc.nrctrrat%TYPE     --> N�mero do contrato do pior rating
                                ,pr_dsoperac OUT VARCHAR2                  --> Descri��o da opera��o do rating
                                ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Critica encontrada no processo
                                ,pr_dscritic OUT VARCHAR2) IS              --> Descritivo do erro
  BEGIN
    /* ..........................................................................

       Programa: pc_procura_pior_nota         Antigo: b1wgen0043 --> procura_pior_nota
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Marcos Ernani Martini
       Data    : Junho/2013.                          Ultima Atualizacao: 04/06/2013

       Dados referentes ao programa:

       Frequencia: Sempre que chamado por outros programas.
       Objetivo  : Retornar o rating com pior nota

       Alteracoes: 04/06/2013 - Convers�o Progress -> Oracle - Marcos (Supero)

    ............................................................................. */
    DECLARE
      -- Busca de rating com pior nota
      CURSOR cr_crapnrc IS
        SELECT rowid
              ,indrisco
              ,nrctrrat
              ,tpctrrat
          FROM crapnrc
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND flgativo = 1  -- Yes
           AND insitrat = 1  -- Proposto
         ORDER BY nrnotrat,
                  dtmvtolt desc;
    BEGIN
      -- Para cada registro de rating
      FOR rw_crapnrc IN cr_crapnrc LOOP
        -- Copiar as informa��es aos par�metros de sa�da
        pr_rowidnrc := rw_crapnrc.ROWID;
        pr_indrisco := rw_crapnrc.indrisco;
        pr_nrctrrat := rw_crapnrc.nrctrrat;
        -- Buscar a descri��o da opera��o
        pr_dsoperac := fn_busca_descricao_operacao(rw_crapnrc.tpctrrat);
      END LOOP;
    EXCEPTION
      WHEN OTHERS THEN
        -- Retorno n�o OK
        pr_cdcritic := 0;
        -- Gerar erro
        pr_dscritic := 'Erro n�o tratado na rotina RATI0001.pc_procura_pior_nota. Detalhes: '||sqlerrm;
    END;
  END pc_procura_pior_nota;

  /*****************************************************************************
   Trazer os emprestimos que estao sendo liquidados em lista.
  *****************************************************************************/

  FUNCTION fn_traz_liquidacoes(pr_rw_crawepr IN cr_crawepr%ROWTYPE) --> Registro da crawepr
                               RETURN VARCHAR2 IS

  /* ..........................................................................

     Programa: fn_traz_liquidacoes         Antigo: b1wgen0043.p/traz_liquidacoes
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Marcos Martini - Supero
     Data    : Setembro/2014.                          Ultima Atualizacao: 01/09/2014

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  : Trazer os emprestimos que estao sendo liquidados em lista.

     Alteracoes: 01/09/2014 - Convers�o Progress -> Oracle - Marcos (Supero)

  ............................................................................. */

    -- Lista dos contratos a liquidar
    vr_dsliquid VARCHAR2(4000);
    -- Auxiliar para guardar o contrato cfme o loop
    vr_nrctrliq crawepr.nrctremp%TYPE;
  BEGIN
    -- Efetuar loop de 1 a 10 para varrer as 10 colunas
    FOR vr_ind IN 1..10 LOOP
      -- Guardar o contrato cfme o loop
      CASE vr_ind
        WHEN 1 THEN vr_nrctrliq := pr_rw_crawepr.nrctrliq##1;
        WHEN 2 THEN vr_nrctrliq := pr_rw_crawepr.nrctrliq##2;
        WHEN 3 THEN vr_nrctrliq := pr_rw_crawepr.nrctrliq##3;
        WHEN 4 THEN vr_nrctrliq := pr_rw_crawepr.nrctrliq##4;
        WHEN 5 THEN vr_nrctrliq := pr_rw_crawepr.nrctrliq##5;
        WHEN 6 THEN vr_nrctrliq := pr_rw_crawepr.nrctrliq##6;
        WHEN 7 THEN vr_nrctrliq := pr_rw_crawepr.nrctrliq##7;
        WHEN 8 THEN vr_nrctrliq := pr_rw_crawepr.nrctrliq##8;
        WHEN 9 THEN vr_nrctrliq := pr_rw_crawepr.nrctrliq##9;
        WHEN 10 THEN vr_nrctrliq := pr_rw_crawepr.nrctrliq##10;
        ELSE vr_nrctrliq := 0;
      END CASE;
      -- Se existe informa��o na posi��o atual
      IF vr_nrctrliq > 0 THEN
        -- Incluir na lista separando por virgula
        IF vr_dsliquid is not null THEN
          vr_dsliquid := vr_dsliquid||','||vr_nrctrliq;
        ELSE
          vr_dsliquid := vr_nrctrliq;
        END IF;
      END IF;
    END LOOP;
    RETURN vr_dsliquid;
  END fn_traz_liquidacoes;

  /* Calcula endividamento total SCR. Itens 3_3 (Fisica) e 5_1 (Juridica). */
  PROCEDURE pc_calcula_endividamento(pr_cdcooper   IN crapcop.cdcooper%TYPE     --> C�digo da Cooperativa
                                    ,pr_cdagenci   IN crapass.cdagenci%TYPE     --> C�digo da ag�ncia
                                    ,pr_nrdcaixa   IN craperr.nrdcaixa%TYPE     --> N�mero do caixa
                                    ,pr_cdoperad   IN crapnrc.cdoperad%TYPE     --> C�digo do operador
                                    ,pr_rw_crapdat IN btch0001.rw_crapdat%TYPE  --> Vetor com dados de par�metro (CRAPDAT)
                                    ,pr_nrdconta   IN crapass.nrdconta%TYPE     --> Conta do associado
                                    ,pr_dsliquid   IN VARCHAR2                  --> Lista de contratos a liquidar
                                    ,pr_idseqttl   IN crapttl.idseqttl%TYPE     --> Sequencia de titularidade da conta
                                    ,pr_idorigem   IN INTEGER                   --> Indicador da origem da chamada
                                    ,pr_inusatab   IN BOOLEAN                   --> Indicador de utiliza��o da tabela de juros
                                    ,pr_tpdecons   IN INTEGER DEFAULT 2         --> Tipo da consulta,defalut 2 saldo disponivel emprestimo sem considerar data atual, 3 saldo disponivel data atual (Ver observa��es da rotina GENE0005.pc_saldo_utiliza)
                                    ,pr_vlutiliz  OUT NUMBER                    --> Valor da d�vida
                                    ,pr_cdcritic  OUT crapcri.cdcritic%TYPE     --> Critica encontrada no processo
                                    ,pr_dscritic  OUT VARCHAR2) IS              --> Sa�da de erro
  BEGIN
    /* ..........................................................................

       Programa: pc_calcula_endividamento         Antigo: b1wgen0043 --> calcula_endividamento
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Marcos Ernani Martini
       Data    : Junho/2013.                          Ultima Atualizacao: 04/06/2013

       Dados referentes ao programa:

       Frequencia: Sempre que chamado por outros programas.
       Objetivo  : Retornar o rating com pior nota

       Alteracoes: 04/06/2013 - Convers�o Progress -> Oracle - Marcos (Supero)

                   28/04/2016 - Incluido parametro pr_tpdecons para permitir selecionar
                                o tipo de consulta ao buscar saldo utilizado, sendo 2(defalut) saldo utilizado dia anterior
                                e 3 saldo utilizado data atual PRJ207-Esteira (Odirlei-AMcom)  

    ............................................................................. */
    DECLARE
      -- Buscar o CPF da conta
      CURSOR cr_crapass IS
        SELECT nrcpfcgc
          FROM crapass
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      vr_nrcpfcgc crapass.nrcpfcgc%TYPE;
      
      -- Retornar todos os empr�stimos n�o liquidados
      CURSOR cr_crapepr IS
        SELECT epr.nrctremp
          FROM crapepr epr
         WHERE epr.cdcooper = pr_cdcooper
           AND epr.nrdconta = pr_nrdconta
           AND epr.inliquid = 0;
           
      -- Var para criar uma lista com os contratos
      -- passados e com os separados nos contratos a liquidar
      vr_split_pr_dsliquid GENE0002.typ_split;
      vr_split_vr_dsliquid GENE0002.typ_split;
      -- Lista dos contratos a liquidar nos empr�stimos em aberto
      vr_dsliquid VARCHAR2(4000);
      
      rw_crawepr1 cr_crawepr%ROWTYPE;
      
    BEGIN
      -- Buscar o CPF da conta
      OPEN cr_crapass;
      FETCH cr_crapass
       INTO vr_nrcpfcgc;
      CLOSE cr_crapass;
      -- Efetuar split dos contratos passados para facilitar os testes
      vr_split_pr_dsliquid := gene0002.fn_quebra_string(pr_dsliquid,',');
      -- Para todos os empr�stimos n�o liquidados
      FOR rw_crapepr IN cr_crapepr LOOP
        -- Buscar a proposta do mesmo
        OPEN cr_crawepr(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrctrato => rw_crapepr.nrctremp);
        FETCH cr_crawepr
         INTO rw_crawepr1;
        CLOSE cr_crawepr;
        -- Traz as liquida��es do mesmo
        vr_dsliquid := fn_traz_liquidacoes(pr_rw_crawepr => rw_crawepr1);
        -- Efetuar split dos contratos retornados para facilitar os testes
        vr_split_vr_dsliquid := gene0002.fn_quebra_string(vr_dsliquid,',');
        -- Ler um a um para em caso de n�o existir na lista, adicion�-los
        IF vr_split_vr_dsliquid.COUNT > 0 THEN
          FOR vr_cont IN vr_split_vr_dsliquid.FIRST..vr_split_vr_dsliquid.LAST LOOP
            IF NOT vr_split_pr_dsliquid.EXISTS(vr_split_vr_dsliquid(vr_cont)) THEN
              -- Adicion�-lo ao vetor
              vr_split_pr_dsliquid.EXTEND;
              vr_split_pr_dsliquid(vr_split_pr_dsliquid.COUNT) := vr_split_vr_dsliquid(vr_cont);
            END IF;
          END LOOP;
        END IF;
      END LOOP; -- Fim, contratos a liquidar

      -- Ao final, varrer o vetor para transform�-lo novamente em uma string separada por virgulas
      vr_dsliquid := '';
      IF vr_split_pr_dsliquid.COUNT > 0 THEN
        FOR vr_cont IN vr_split_pr_dsliquid.FIRST..vr_split_pr_dsliquid.LAST LOOP
          -- Adicionar o valor atual + uma virgula separadora
          vr_dsliquid := vr_dsliquid || vr_split_pr_dsliquid(vr_cont) || ',';
        END LOOP;
      END IF;
      -- Remover virgula desnecess�ria a direita
      vr_dsliquid := rtrim(vr_dsliquid,',');

      -- Chamar rotina para retorno do saldo em utiliza��o
      GENE0005.pc_saldo_utiliza(pr_cdcooper => pr_cdcooper              --> C�digo da Cooperativa
                               ,pr_tpdecons => pr_tpdecons              --> Tipo da consulta (Ver observa��es da rotina)
                               ,pr_cdagenci => pr_cdagenci              --> C�digo da ag�ncia
                               ,pr_nrdcaixa => pr_nrdcaixa              --> N�mero do caixa
                               ,pr_cdoperad => pr_cdoperad              --> C�digo do operador
                               ,pr_nrdconta => NULL                     --> OU Consulta pela conta
                               ,pr_nrcpfcgc => vr_nrcpfcgc              --> OU Consulta pelo Numero do cpf ou cgc do associado
                               ,pr_idseqttl => pr_idseqttl              --> Sequencia de titularidade da conta
                               ,pr_idorigem => pr_idorigem              --> Indicador da origem da chamada
                               ,pr_dsctrliq => vr_dsliquid              --> Numero do contrato de liquidacao
                               ,pr_cdprogra => 'RATI0001'               --> C�digo do programa chamador
                               ,pr_tab_crapdat => pr_rw_crapdat         --> Tipo de registro de datas
                               ,pr_inusatab => pr_inusatab              --> Indicador de utiliza��o da tabela de juros
                               ,pr_vlutiliz => pr_vlutiliz              --> Valor utilizado do credito
                               ,pr_cdcritic => pr_cdcritic              --> C�digo de retorno da critica
                               ,pr_dscritic => pr_dscritic);            --> Mensagem de retorno da critica
    EXCEPTION
      WHEN OTHERS THEN
        -- Retorno n�o OK
        pr_cdcritic := 0;
        -- Gerar erro
        pr_dscritic := 'Erro n�o tratado na rotina RATI0001.pc_calcula_endividamento. Detalhes: '||sqlerrm;
    END;
  END pc_calcula_endividamento;

  /* Desativar Rating. Usada quando emprestimo � liquidado ou limite � cancelado. */
  PROCEDURE pc_desativa_rating(pr_cdcooper   IN crapcop.cdcooper%TYPE     --> C�digo da Cooperativa
                              ,pr_cdagenci   IN crapass.cdagenci%TYPE     --> C�digo da ag�ncia
                              ,pr_nrdcaixa   IN craperr.nrdcaixa%TYPE     --> N�mero do caixa
                              ,pr_cdoperad   IN crapnrc.cdoperad%TYPE     --> C�digo do operador
                              ,pr_rw_crapdat IN btch0001.rw_crapdat%TYPE  --> Vetor com dados de par�metro (CRAPDAT)
                              ,pr_nrdconta   IN crapass.nrdconta%TYPE     --> Conta do associado
                              ,pr_tpctrrat   IN NUMBER                    --> Tipo do Rating
                              ,pr_nrctrrat   IN NUMBER                    --> N�mero do contrato de Rating
                              ,pr_flgefeti   IN VARCHAR2                  --> Flag para efetiva��o ou n�o do Rating
                              ,pr_idseqttl   IN crapttl.idseqttl%TYPE     --> Sequencia de titularidade da conta
                              ,pr_idorigem   IN INTEGER                   --> Indicador da origem da chamada
                              ,pr_inusatab   IN BOOLEAN                   --> Indicador de utiliza��o da tabela de juros
                              ,pr_nmdatela   IN VARCHAR2                  --> Nome datela conectada
                              ,pr_flgerlog   IN VARCHAR2                  --> Gerar log S/N
                              ,pr_des_reto  OUT VARCHAR                   --> Retorno OK / NOK
                              ,pr_tab_erro  OUT gene0001.typ_tab_erro) IS --> Tabela com poss�ves erros
  BEGIN
    /* ..........................................................................

       Programa: pc_desativa_rating         Antigo: b1wgen0043 --> desativa_rating
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Marcos Ernani Martini
       Data    : Junho/2013.                          Ultima Atualizacao: 03/06/2013

       Dados referentes ao programa:

       Frequencia: Sempre que chamado por outros programas.
       Objetivo  : Desativar Rating. Usada quando emprestimo � liquidado ou limite � cancelado.

       Alteracoes: 03/06/2013 - Convers�o Progress -> Oracle - Marcos (Supero)

    ............................................................................. */
    DECLARE
      -- Descri��o e c�digo da critica
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      -- Rowid para inser��o de log
      vr_nrdrowid ROWID;
      -- Exce��o de sa�da
      vr_exc_erro EXCEPTION;
      -- Var gen�rica para guardar Rowid de registro encontrado de Rating
      vr_ncr_rowid rowid;
      vr_ncr_efetiv_rowid rowid;
      -- Busca de rating para a proposta solicitada
      CURSOR cr_crapnrc IS
        SELECT rowid
          FROM crapnrc
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND tpctrrat = pr_tpctrrat
           AND nrctrrat = pr_nrctrrat;
      -- Busca de rating efetivo
      CURSOR cr_crapnrc_efetivo IS
        SELECT rowid
          FROM crapnrc
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND insitrat = 2; -- Efetivo
      -- Busca de rating de origem
      CURSOR cr_crapnrc_origem IS
        SELECT rowid
          FROM crapnrc
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND flgorige = 1; -- Possui origem
      -- Variaveis auxiliar
      vr_vlutiliz NUMBER; -- Valor de cr�dito utilizado pelo cooperado
      vr_vlrating NUMBER; -- Valor parametrizado de rating
      vr_vlmaxleg NUMBER; -- Valor m�ximo legal
      vr_indrisco VARCHAR2(2);           -- Risco do pior rating
      vr_rowidnrc ROWID;                 -- Rowid do pior rating
      vr_nrctrrat crapnrc.nrctrrat%TYPE; -- Contrato do pior rating
      vr_dsoperac VARCHAR2(100);         -- Descri��o da opera��o do pior rating

    BEGIN
      -- Procura o rating para a proposta solicitada
      OPEN cr_crapnrc;
      FETCH cr_crapnrc
       INTO vr_ncr_rowid;
      CLOSE cr_crapnrc;
      -- Se existe rating para esta proposta
      IF vr_ncr_rowid IS NOT NULL THEN
        -- Desativ�-lo
        BEGIN
          UPDATE crapnrc
             SET flgativo = 0    /* Nao ativo */
                ,insitrat = 1    /* Proposto*/
                ,dteftrat = null /* Limpa efetivacao */
                ,flgorige = 0    /* Nao � origem */
           WHERE rowid = vr_ncr_rowid;
        EXCEPTION
          WHEN OTHERS THEN
            -- Gerar erro
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao desativar o Rating para o contrato proposto.'
                        || ' Conta: '||pr_nrdconta
                        || ' Tpctrrat: '||pr_tpctrrat
                        || ' Nrctrrat: '||pr_nrctrrat||'.'
                        || ' Detalhes: '||sqlerrm;
            RAISE vr_exc_erro;
        END;
      END IF;
      -- Verificar se existe um rating efetivo
      vr_ncr_efetiv_rowid := NULL;
      OPEN cr_crapnrc_efetivo;
      FETCH cr_crapnrc_efetivo
       INTO vr_ncr_efetiv_rowid;
      CLOSE cr_crapnrc_efetivo;
      -- Se existe
      IF vr_ncr_efetiv_rowid IS NOT NULL THEN
        -- Verificar se tem rating de Origem
        vr_ncr_rowid := NULL;
        OPEN cr_crapnrc_origem;
        FETCH cr_crapnrc_origem
         INTO vr_ncr_rowid;
        CLOSE cr_crapnrc_origem;
        -- Se n�o tiver encontrado rating de Origem
        IF vr_ncr_rowid IS NULL THEN
          -- Cria a origem como o efetivo
          pc_grava_rating_origem(pr_cdcooper => pr_cdcooper     --> C�digo da Cooperativa
                                ,pr_nrdconta => pr_nrdconta     --> Conta do associado
                                ,pr_rowidnrc => vr_ncr_efetiv_rowid    --> Rowid para grava��o do rating
                                ,pr_cdcritic => vr_cdcritic     --> Critica encontrada no processo
                                ,pr_dscritic => vr_dscritic);   --> Descritivo do erro

          --------------------------------------------------------------------
          ----- N�o vers�o progress n�o testava se retornou erro aqui...  ----
          --------------------------------------------------------------------

          -- Se encontrou erro
          --IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
          --  -- Gerar o erro
          --  RAISE vr_exc_erro;
          --END IF;
        END IF;
      ELSE
        -- Limpar campo da origem do Rating
        pc_limpa_rating_origem(pr_cdcooper => pr_cdcooper   --> C�digo da Cooperativa
                              ,pr_nrdconta => pr_nrdconta   --> Conta do associado
                              ,pr_dscritic => vr_dscritic); --> Descritivo do erro
        -- Se encontrou erro
        IF vr_dscritic IS NOT NULL THEN
          -- Gerar o erro
          vr_cdcritic := 0;
          RAISE vr_exc_erro;
        END IF;
      END IF;

      -- Findado, o tratamento origem do Rating
      -- Se foi solicitado para efetivar o novo Rating
      IF pr_flgefeti = 'S' THEN
        -- Buscar o saldo utilizado pelo Cooperado
        pc_calcula_endividamento(pr_cdcooper   => pr_cdcooper     --> C�digo da Cooperativa
                                ,pr_cdagenci   => pr_cdagenci     --> C�digo da ag�ncia
                                ,pr_nrdcaixa   => pr_nrdcaixa     --> N�mero do caixa
                                ,pr_cdoperad   => pr_cdoperad     --> C�digo do operador
                                ,pr_rw_crapdat => pr_rw_crapdat   --> Vetor com dados de par�metro (CRAPDAT)
                                ,pr_nrdconta   => pr_nrdconta     --> Conta do associado
                                ,pr_dsliquid   => ''              --> Lista de contratos a liquidar
                                ,pr_idseqttl   => pr_idseqttl     --> Sequencia de titularidade da conta
                                ,pr_idorigem   => pr_idorigem     --> Indicador da origem da chamada
                                ,pr_inusatab   => pr_inusatab     --> Indicador de utiliza��o da tabela de juros
                                ,pr_vlutiliz   => vr_vlutiliz     --> Valor da d�vida
                                ,pr_cdcritic   => vr_cdcritic     --> Critica encontrada no processo
                                ,pr_dscritic   => vr_dscritic);   --> Sa�da de erro
        -- Se houve erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          -- Encerrar o processo
          RAISE vr_exc_erro;
        END IF;
        -- Retornar valor de parametriza��o do rating cadastrado na TAB036
        pc_param_valor_rating(pr_cdcooper => pr_cdcooper --> C�digo da Cooperativa
                             ,pr_vlrating => vr_vlrating --> Valor parametrizado
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
        -- Se houve erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          -- Encerrar o processo
          RAISE vr_exc_erro;
        END IF;
        -- Buscar valor maximo legal cadastrado pela CADCOP
        pc_valor_maximo_legal(pr_cdcooper => pr_cdcooper --> C�digo da Cooperativa
                             ,pr_vlmaxleg => vr_vlmaxleg --> Valor parametrizado
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
        -- Se houve erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          -- Encerrar o processo
          RAISE vr_exc_erro;
        END IF;
        -- Se o cooperado esta utilizando mais do que o valor legal E nao tem Rating
        IF (vr_vlutiliz >= vr_vlrating OR vr_vlutiliz >= (vr_vlmaxleg / 3))
        AND vr_ncr_efetiv_rowid IS NULL THEN
          -- Retornar o Rating Proposto com pior nota.
          pc_procura_pior_nota(pr_cdcooper => pr_cdcooper --> C�digo da Cooperativa
                              ,pr_nrdconta => pr_nrdconta --> Conta do associado
                              ,pr_indrisco => vr_indrisco --> Risco do pior rating
                              ,pr_rowidnrc => vr_rowidnrc --> Rowid do pior rating
                              ,pr_nrctrrat => vr_nrctrrat --> N�mero do contrato do pior rating
                              ,pr_dsoperac => vr_dsoperac --> Descri��o da opera��o do rating
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);
          -- Se houve erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            -- Encerrar o processo
            RAISE vr_exc_erro;
          END IF;
          -- Se existe Rating a efetivar
          IF vr_rowidnrc IS NOT NULL THEN
            -- Mudar situacao do Rating para efetivo
            pc_muda_situacao_efetivo(pr_rowidnrc  => vr_rowidnrc            --> Rowid para grava��o do rating
                                    ,pr_cdoperad  => pr_cdoperad            --> C�digo do operador
                                    ,pr_dtmvtolt  => pr_rw_crapdat.dtmvtolt --> Data atual
                                    ,pr_vlutiliz  => vr_vlutiliz            --> Valor para lan�amento
                                    ,pr_flgatual  => FALSE                  --> N�o atualizar
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);

            --------------------------------------------------------------------
            ----- N�o vers�o progress n�o testava se retornou erro aqui...  ----
            --------------------------------------------------------------------

            -- Se houve erro
            --IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            --  -- Encerrar o processo
            --  RAISE vr_exc_erro;
            --END IF;
            -- Gravar o rating de origem
            pc_grava_rating_origem(pr_cdcooper => pr_cdcooper     --> C�digo da Cooperativa
                                  ,pr_nrdconta => pr_nrdconta     --> Conta do associado
                                  ,pr_rowidnrc => vr_rowidnrc     --> Rowid para grava��o do rating
                                  ,pr_cdcritic => vr_cdcritic     --> Critica encontrada no processo
                                  ,pr_dscritic => vr_dscritic);   --> Descritivo do erro
            -- Se encontrou erro
            IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
              -- Gerar o erro
              RAISE vr_exc_erro;
            END IF;
          END IF;
        END IF;
      END IF; -- Fim efetivar novo rating

      -- Se esta abaixo do valor legal e tem Rating
      IF NOT (vr_vlutiliz >= vr_vlrating OR vr_vlutiliz >= (vr_vlmaxleg / 3))
      AND vr_ncr_efetiv_rowid IS NOT NULL THEN
        -- Nao pode ter Rating, entao deixa proposto
        pc_muda_situacao_proposto(pr_cdcooper  => pr_cdcooper            --> C�digo da Cooperativa
                                 ,pr_nrdconta  => pr_nrdconta            --> Conta do associado
                                 ,pr_dtmvtolt  => pr_rw_crapdat.dtmvtolt --> Data atual
                                 ,pr_vlutiliz  => vr_vlutiliz            --> Valor para lan�amento
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
        -- Se houve erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          -- Encerrar o processo
          RAISE vr_exc_erro;
        END IF;
      END IF;

      -- Se foi solicitado o envio de LOG
      IF pr_flgerlog = 'S' THEN
        -- Gerar LOG de envio do e-mail
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => NULL
                            ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem) --> Origem enviada
                            ,pr_dstransa => 'Desativar o Rating do cooperado.'
                            ,pr_dttransa => pr_rw_crapdat.dtmvtolt
                            ,pr_flgtrans => 1 --> TRUE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;
      -- Retorno OK
      pr_des_reto := 'OK';
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        -- Se foi solicitado o envio de LOG
        IF pr_flgerlog = 'S' THEN
          -- Gerar LOG de envio do e-mail
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem) --> Origem enviada
                              ,pr_dstransa => 'Desativar o Rating do cooperado.'
                              ,pr_dttransa => pr_rw_crapdat.dtmvtolt
                              ,pr_flgtrans => 0 --> FALSE
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
        END IF;
      WHEN OTHERS THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        -- Montar descri��o de erro n�o tratado
        vr_dscritic := 'Erro n�o tratado na RATI0001.pc_desativa_rating> '||sqlerrm;
        -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        -- Se foi solicitado o envio de LOG
        IF pr_flgerlog = 'S' THEN
          -- Gerar LOG de envio do e-mail
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem) --> Origem enviada
                              ,pr_dstransa => 'Desativar o Rating do cooperado.'
                              ,pr_dttransa => pr_rw_crapdat.dtmvtolt
                              ,pr_flgtrans => 0 --> FALSE
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
        END IF;
    END;
  END pc_desativa_rating;


  /* Ativar Rating. Usada quando emprestimo � liquidado ou limite � cancelado. */
  PROCEDURE pc_ativa_rating(pr_cdcooper   IN crapcop.cdcooper%TYPE     --> C�digo da Cooperativa
                           ,pr_cdagenci   IN crapass.cdagenci%TYPE     --> C�digo da ag�ncia
                           ,pr_nrdcaixa   IN craperr.nrdcaixa%TYPE     --> N�mero do caixa
                           ,pr_cdoperad   IN crapnrc.cdoperad%TYPE     --> C�digo do operador
                           ,pr_rw_crapdat IN btch0001.rw_crapdat%TYPE  --> Vetor com dados de par�metro (CRAPDAT)
                           ,pr_nrdconta   IN crapass.nrdconta%TYPE     --> Conta do associado
                           ,pr_tpctrrat   IN NUMBER                    --> Tipo do Rating
                           ,pr_nrctrrat   IN NUMBER                    --> N�mero do contrato de Rating
                           ,pr_idseqttl   IN crapttl.idseqttl%TYPE     --> Sequencia de titularidade da conta
                           ,pr_idorigem   IN INTEGER                   --> Indicador da origem da chamada
                           ,pr_inusatab   IN BOOLEAN                   --> Indicador de utiliza��o da tabela de juros
                           ,pr_nmdatela   IN VARCHAR2                  --> Nome datela conectada
                           ,pr_flgerlog   IN VARCHAR2                  --> Gerar log S/N
                           ,pr_des_reto  OUT VARCHAR2                  --> Retorno OK / NOK
                           ,pr_dscritic  OUT VARCHAR2                  --> Mensagem de erro
                           ,pr_tab_erro  OUT gene0001.typ_tab_erro) IS --> Tabela com poss�ves erros
  BEGIN
    /* ..........................................................................

       Programa: pc_ativa_rating         Antigo: b1wgen0043 --> ativa_rating
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Alisson C. Berrido
       Data    : Julho/2013.                          Ultima Atualizacao:

       Dados referentes ao programa:

       Frequencia: Sempre que chamado por outros programas.
       Objetivo  : Desativar Rating. Usada quando emprestimo � liquidado ou limite � cancelado.

       Alteracoes: 25/07/2013 - Convers�o Progress -> Oracle - Alisson (AMcom)

    ............................................................................. */
    DECLARE
      -- Descri��o e c�digo da critica
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      -- Rowid para inser��o de log
      vr_nrdrowid ROWID;
      -- Exce��o de sa�da
      vr_exc_saida EXCEPTION;
      vr_exc_erro  EXCEPTION;
      -- Busca de rating para a proposta solicitada
      CURSOR cr_crapnrc (pr_cdcooper IN crapnrc.cdcooper%type
                        ,pr_nrdconta IN crapnrc.nrdconta%type
                        ,pr_tpctrrat IN crapnrc.tpctrrat%type
                        ,pr_nrctrrat IN crapnrc.nrctrrat%type) IS
        SELECT crapnrc.ROWID
              ,crapnrc.flgativo
              ,crapnrc.nrnotrat
          FROM crapnrc
         WHERE crapnrc.cdcooper = pr_cdcooper
           AND crapnrc.nrdconta = pr_nrdconta
           AND crapnrc.tpctrrat = pr_tpctrrat
           AND crapnrc.nrctrrat = pr_nrctrrat;
      rw_crapnrc cr_crapnrc%ROWTYPE;
      -- Busca de rating efetivo
      CURSOR cr_crapnrc_efetivo (pr_cdcooper IN crapnrc.cdcooper%type
                                ,pr_nrdconta IN crapnrc.nrdconta%type
                                ,pr_insitrat IN crapnrc.insitrat%TYPE) IS
        SELECT crapnrc.ROWID
              ,crapnrc.nrnotrat
          FROM crapnrc
         WHERE crapnrc.cdcooper = pr_cdcooper
           AND crapnrc.nrdconta = pr_nrdconta
           AND crapnrc.insitrat = pr_insitrat; -- Efetivo
      rw_crapnrc_efetivo cr_crapnrc_efetivo%ROWTYPE;
      -- Variaveis auxiliar
      vr_vlutiliz NUMBER; -- Valor de cr�dito utilizado pelo cooperado
      vr_vlrating NUMBER; -- Valor parametrizado de rating
      vr_vlmaxleg NUMBER; -- Valor m�ximo legal
      vr_indrisco VARCHAR2(2);           -- Risco do pior rating
      vr_rowidnrc ROWID;                 -- Rowid do pior rating
      vr_nrctrrat crapnrc.nrctrrat%TYPE; -- Contrato do pior rating
      vr_dsoperac VARCHAR2(100);         -- Descri��o da opera��o do pior rating

    BEGIN
      --Inicializar parametro saida erro
      pr_des_reto:= 'OK';
      pr_dscritic:= NULL;
      --Inicializar variaveis erro
      vr_cdcritic:= 0;
      vr_dscritic:= NULL;
      OPEN cr_crapnrc (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_tpctrrat => pr_tpctrrat
                      ,pr_nrctrrat => pr_nrctrrat);
      --Posicionar no proximo registro
      FETCH cr_crapnrc INTO rw_crapnrc;
      --Se nao encontrar
      IF cr_crapnrc%NOTFOUND OR rw_crapnrc.flgativo = 1 THEN
        --Fechar Cursor
        CLOSE cr_crapnrc;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapnrc;
      /* Saldo utilizado */
      -- Buscar o saldo utilizado pelo Cooperado
      pc_calcula_endividamento(pr_cdcooper   => pr_cdcooper     --> C�digo da Cooperativa
                              ,pr_cdagenci   => pr_cdagenci     --> C�digo da ag�ncia
                              ,pr_nrdcaixa   => pr_nrdcaixa     --> N�mero do caixa
                              ,pr_cdoperad   => pr_cdoperad     --> C�digo do operador
                              ,pr_rw_crapdat => pr_rw_crapdat   --> Vetor com dados de par�metro (CRAPDAT)
                              ,pr_nrdconta   => pr_nrdconta     --> Conta do associado
                              ,pr_dsliquid   => ''              --> Lista de contratos a liquidar
                              ,pr_idseqttl   => pr_idseqttl     --> Sequencia de titularidade da conta
                              ,pr_idorigem   => pr_idorigem     --> Indicador da origem da chamada
                              ,pr_inusatab   => pr_inusatab     --> Indicador de utiliza��o da tabela de juros
                              ,pr_vlutiliz   => vr_vlutiliz     --> Valor da d�vida
                              ,pr_cdcritic   => vr_cdcritic     --> Critica encontrada no processo
                              ,pr_dscritic   => vr_dscritic);   --> Sa�da de erro
      -- Se houve erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        -- Encerrar o processo
        RAISE vr_exc_erro;
      END IF;
      /* - Re-ativar
           - Atualiza Valor Utilizado
           - Verifica se tem Rating efetivo */
      BEGIN
        UPDATE crapnrc SET crapnrc.flgativo = 1
                          ,crapnrc.vlutlrat = nvl(vr_vlutiliz,0)
        WHERE crapnrc.rowid = rw_crapnrc.ROWID;
      EXCEPTION
        WHEN Others THEN
          vr_cdcritic:= 0;
          vr_dscritic:= 'Erro ao atualizar a tabela crapnrc.'||sqlerrm;
          --Levantar Excecao
          RAISE vr_exc_erro;
      END;
      --Verifica se tem rating efetivo
      OPEN cr_crapnrc_efetivo (pr_cdcooper => pr_cdcooper
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_insitrat => 2); -- 2-Efetivo
      FETCH cr_crapnrc_efetivo INTO rw_crapnrc_efetivo;
      -- Se existe
      IF cr_crapnrc_efetivo%FOUND THEN
        --Fechar Cursor
        CLOSE cr_crapnrc_efetivo;
        /* Nota deste contrato � pior do que nota do Efetivo */
        IF rw_crapnrc.nrnotrat > rw_crapnrc_efetivo.nrnotrat THEN

		  vr_rowidnrc := rw_crapnrc.ROWID;

          /* Volta para Proposto o efetivo atual */
          pc_muda_situacao_proposto(pr_cdcooper  => pr_cdcooper            --> C�digo da Cooperativa
                                   ,pr_nrdconta  => pr_nrdconta            --> Conta do associado
                                   ,pr_dtmvtolt  => pr_rw_crapdat.dtmvtolt --> Data atual
                                   ,pr_vlutiliz  => vr_vlutiliz            --> Valor para lan�amento
                                   ,pr_cdcritic  => vr_cdcritic
                                   ,pr_dscritic  => vr_dscritic);
          -- Se houve erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            -- Encerrar o processo
            RAISE vr_exc_erro;
          END IF;
          /* Efetivar este contrato (pior nota) */
          -- Mudar situacao do Rating para efetivo
          pc_muda_situacao_efetivo(pr_rowidnrc  => vr_rowidnrc            --> Rowid para grava��o do rating
                                  ,pr_cdoperad  => pr_cdoperad            --> C�digo do operador
                                  ,pr_dtmvtolt  => pr_rw_crapdat.dtmvtolt --> Data atual
                                  ,pr_vlutiliz  => vr_vlutiliz            --> Valor para lan�amento
                                  ,pr_flgatual  => FALSE                  --> N�o atualizar
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => vr_dscritic);
          -- Se houve erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            -- Encerrar o processo
            RAISE vr_exc_erro;
          END IF;
          -- Gravar o rating de origem
          pc_grava_rating_origem(pr_cdcooper => pr_cdcooper     --> C�digo da Cooperativa
                                ,pr_nrdconta => pr_nrdconta     --> Conta do associado
                                ,pr_rowidnrc => vr_rowidnrc     --> Rowid para grava��o do rating
                                ,pr_cdcritic => vr_cdcritic     --> Critica encontrada no processo
                                ,pr_dscritic => vr_dscritic);   --> Descritivo do erro
          -- Se encontrou erro
          IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
            -- Gerar o erro
            RAISE vr_exc_erro;
          END IF;
        END IF;
      ELSE /* Nao tem rating efetivo */
        /* Cadastrado na TAB036 */
        -- Retornar valor de parametriza��o do rating cadastrado na TAB036
        pc_param_valor_rating(pr_cdcooper => pr_cdcooper --> C�digo da Cooperativa
                             ,pr_vlrating => vr_vlrating --> Valor parametrizado
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
        -- Se houve erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          -- Encerrar o processo
          RAISE vr_exc_erro;
        END IF;
        -- Buscar valor maximo legal cadastrado pela CADCOP
        pc_valor_maximo_legal(pr_cdcooper => pr_cdcooper --> C�digo da Cooperativa
                             ,pr_vlmaxleg => vr_vlmaxleg --> Valor parametrizado
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
        -- Se houve erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          -- Encerrar o processo
          RAISE vr_exc_erro;
        END IF;
         /* Operacao atual maior/igual  do que valor Rating ou 5 % PR */
        IF (vr_vlutiliz >= vr_vlrating OR vr_vlutiliz >= (vr_vlmaxleg / 3)) THEN
          -- Retornar o Rating Proposto com pior nota.
          pc_procura_pior_nota(pr_cdcooper => pr_cdcooper --> C�digo da Cooperativa
                              ,pr_nrdconta => pr_nrdconta --> Conta do associado
                              ,pr_indrisco => vr_indrisco --> Risco do pior rating
                              ,pr_rowidnrc => vr_rowidnrc --> Rowid do pior rating
                              ,pr_nrctrrat => vr_nrctrrat --> N�mero do contrato do pior rating
                              ,pr_dsoperac => vr_dsoperac --> Descri��o da opera��o do rating
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);
          --------------------------------------------------------------------
          ----- N�o vers�o progress n�o testava se retornou erro aqui...  ----
          --------------------------------------------------------------------
          -- Se houve erro
          --IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --  -- Encerrar o processo
          --  RAISE vr_exc_erro;
          --END IF;
          -- Se existe Rating a efetivar
          IF vr_rowidnrc IS NOT NULL THEN
            -- Mudar situacao do Rating para efetivo
            pc_muda_situacao_efetivo(pr_rowidnrc  => vr_rowidnrc            --> Rowid para grava��o do rating
                                    ,pr_cdoperad  => pr_cdoperad            --> C�digo do operador
                                    ,pr_dtmvtolt  => pr_rw_crapdat.dtmvtolt --> Data atual
                                    ,pr_vlutiliz  => vr_vlutiliz            --> Valor para lan�amento
                                    ,pr_flgatual  => FALSE                  --> N�o atualizar
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);

            -- Se houve erro
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              -- Encerrar o processo
              RAISE vr_exc_erro;
            END IF;
            -- Gravar o rating de origem
            pc_grava_rating_origem(pr_cdcooper => pr_cdcooper     --> C�digo da Cooperativa
                                  ,pr_nrdconta => pr_nrdconta     --> Conta do associado
                                  ,pr_rowidnrc => vr_rowidnrc     --> Rowid para grava��o do rating
                                  ,pr_cdcritic => vr_cdcritic     --> Critica encontrada no processo
                                  ,pr_dscritic => vr_dscritic);   --> Descritivo do erro
            -- Se encontrou erro
            IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
              -- Gerar o erro
              RAISE vr_exc_erro;
            END IF;
          END IF;
        END IF;
      END IF;
      --Fechar Cursor
      IF cr_crapnrc_efetivo%ISOPEN THEN
        CLOSE cr_crapnrc_efetivo;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        -- Se foi solicitado o envio de LOG
        IF pr_flgerlog = 'S' THEN
          -- Gerar LOG de envio do e-mail
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem) --> Origem enviada
                              ,pr_dstransa => 'Ativar o Rating do cooperado.'
                              ,pr_dttransa => pr_rw_crapdat.dtmvtolt
                              ,pr_flgtrans => 0 --> FALSE
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
        END IF;
      WHEN OTHERS THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        -- Montar descri��o de erro n�o tratado
        vr_dscritic := 'Erro n�o tratado na RATI0001.pc_ativa_rating> '||sqlerrm;
        -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        -- Se foi solicitado o envio de LOG
        IF pr_flgerlog = 'S' THEN
          -- Gerar LOG de envio do e-mail
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem) --> Origem enviada
                              ,pr_dstransa => 'Ativar o Rating do cooperado.'
                              ,pr_dttransa => pr_rw_crapdat.dtmvtolt
                              ,pr_flgtrans => 0 --> FALSE
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
        END IF;
    END;
  END pc_ativa_rating;

  /* Procedure para verificar contrato rating */
  PROCEDURE pc_verifica_contrato_rating (pr_cdcooper IN INTEGER  --Codigo Cooperativa
                                        ,pr_cdagenci IN INTEGER  --Codigo Agencia
                                        ,pr_nrdcaixa IN INTEGER  --Numero Caixa
                                        ,pr_cdoperad IN VARCHAR2 --Codigo Operador
                                        ,pr_dtmvtolt IN DATE     --Data Movimentacao
                                        ,pr_dtmvtopr IN DATE     --Data proxima operacao
                                        ,pr_nrdconta IN INTEGER  --Numero da Conta
                                        ,pr_tpctrrat IN INTEGER  --Tipo Contrato Rating
                                        ,pr_nrctrrat IN INTEGER  --Numero Contrato Rating
                                        ,pr_idseqttl IN INTEGER  --Sequencial do Titular
                                        ,pr_idorigem IN INTEGER  --Identificador Origem
                                        ,pr_nmdatela IN VARCHAR2 --Nome da tela
                                        ,pr_inproces IN INTEGER  --Indicador do Processo
                                        ,pr_flgerlog IN BOOLEAN  --Gravar erro log
                                        ,pr_tab_erro OUT GENE0001.typ_tab_erro  --Tabela de retorno de erro
                                        ,pr_des_erro OUT VARCHAR2               --Indicador erro
                                        ,pr_dscritic OUT VARCHAR2) IS --Descricao do erro
  BEGIN
  /* ..........................................................................

     Programa: pc_verifica_contrato_rating         Antigo: b1wgen0043.p/verifica_contrato_rating
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Alisson C. Berrido
     Data    : Julho/2013.                          Ultima Atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  : Verificar contrato rating

     Alteracoes: 24/07/2013 - Convers�o Progress -> Oracle - Alisson (AMcom)

  ............................................................................. */
    DECLARE
      --Selecionar rating
      CURSOR cr_crapnrc (pr_cdcooper IN crapnrc.cdcooper%type
                        ,pr_nrdconta IN crapnrc.nrdconta%type
                        ,pr_tpctrrat IN crapnrc.tpctrrat%type
                        ,pr_nrctrrat IN crapnrc.nrctrrat%type) IS
        SELECT crapnrc.flgativo
        FROM crapnrc
        WHERE crapnrc.cdcooper = pr_cdcooper
        AND   crapnrc.nrdconta = pr_nrdconta
        AND   crapnrc.tpctrrat = pr_tpctrrat
        AND   crapnrc.nrctrrat = pr_nrctrrat;
      rw_crapnrc cr_crapnrc%ROWTYPE;
      --Selecionar emprestimos
      CURSOR cr_crapepr (pr_cdcooper IN crapepr.cdcooper%type
                        ,pr_nrctremp IN crapepr.nrctremp%type
                        ,pr_nrdconta IN crapepr.nrdconta%type) IS
        SELECT crapepr.cdcooper
              ,crapepr.nrdconta
              ,crapepr.nrctremp
              ,crapepr.dtdpagto
              ,crapepr.indpagto
              ,crapepr.inliquid
              ,crapepr.ROWID
        FROM crapepr
        WHERE crapepr.cdcooper = pr_cdcooper
        AND   crapepr.nrctremp = pr_nrctremp
        AND   crapepr.nrdconta = pr_nrdconta;
      rw_crapepr cr_crapepr%ROWTYPE;
      --Variaveis Locais
      vr_nrdrowid ROWID;
      vr_inusatab BOOLEAN;
      vr_flgerlog VARCHAR2(1);
      vr_dstextab VARCHAR2(1000);
      --Variaveis de erro
      vr_des_erro VARCHAR2(4000);
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Tipo de registro do tipo data
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
      --Tabela de Memoria de erros
      vr_tab_erro GENE0001.typ_tab_erro;
      --Variaveis de Excecao
      vr_exc_erro  EXCEPTION;
      vr_exc_saida EXCEPTION;
    BEGIN
      --Inicializar parametros erro
      pr_des_erro:= 'OK';
      pr_dscritic:= NULL;
      --Inicializar variaveis erro
      vr_cdcritic:= 0;
      vr_dscritic:= NULL;
      --Limpar tabela erro
      pr_tab_erro.DELETE;
      --Verificar se a data existe
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se n�o encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haver� raise
        CLOSE BTCH0001.cr_crapdat;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;
      --Selecionar rating
      OPEN cr_crapnrc (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_tpctrrat => pr_tpctrrat
                      ,pr_nrctrrat => pr_nrctrrat);
      --Posicionar no proximo registro
      FETCH cr_crapnrc INTO rw_crapnrc;
      --Se nao encontrar
      IF cr_crapnrc%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapnrc;
        --Levantar Excecao
        RAISE vr_exc_saida;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapnrc;
      --Selecionar emprestimos
      OPEN cr_crapepr (pr_cdcooper => pr_cdcooper
                      ,pr_nrctremp => pr_nrctrrat
                      ,pr_nrdconta => pr_nrdconta);
      --Posicionar no proximo registro
      FETCH cr_crapepr INTO rw_crapepr;
      --Se nao encontrar
      IF cr_crapepr%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapepr;
        vr_cdcritic:= 356;
        vr_dscritic:= NULL;
        -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        -- Se foi solicitado o envio de LOG
        IF pr_flgerlog THEN
          -- Gerar LOG de envio do e-mail
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem) --> Origem enviada
                              ,pr_dstransa => NULL
                              ,pr_dttransa => SYSDATE
                              ,pr_flgtrans => 0 --> FALSE
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
        END IF;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapepr;

      --Verificar se usa tabela juros
      vr_dstextab:= TABE0001.fn_busca_dstextab (pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'TAXATABELA'
                                               ,pr_tpregist => 0);
      -- Se a primeira posi��o do campo
      -- dstextab for diferente de zero
      vr_inusatab:= SUBSTR(vr_dstextab,1,1) != '0';

      --Verificar se deve logar
      IF pr_flgerlog THEN
        vr_flgerlog:= 'S';
      ELSE
        vr_flgerlog:= 'N';
      END IF;
      --Verifica se possui emprestimo em aberto
      IF rw_crapepr.inliquid = 0   THEN /* Em aberto */
        IF  rw_crapnrc.flgativo = 0  THEN /* Desativado */
          --Ativar o Rating
          pc_ativa_rating(pr_cdcooper   => pr_cdcooper    --> C�digo da Cooperativa
                         ,pr_cdagenci   => pr_cdagenci    --> C�digo da ag�ncia
                         ,pr_nrdcaixa   => pr_nrdcaixa    --> N�mero do caixa
                         ,pr_cdoperad   => pr_cdoperad    --> C�digo do operador
                         ,pr_rw_crapdat => rw_crapdat     --> Vetor com dados de par�metro (CRAPDAT)
                         ,pr_nrdconta   => pr_nrdconta    --> Conta do associado
                         ,pr_tpctrrat   => pr_tpctrrat    --> Tipo do Rating
                         ,pr_nrctrrat   => pr_nrctrrat    --> N�mero do contrato de Rating
                         ,pr_idseqttl   => pr_idseqttl    --> Sequencia de titularidade da conta
                         ,pr_idorigem   => pr_idorigem    --> Indicador da origem da chamada
                         ,pr_inusatab   => vr_inusatab    --> Indicador de utiliza��o da tabela de juros
                         ,pr_nmdatela   => pr_nmdatela    --> Nome datela conectada
                         ,pr_flgerlog   => vr_flgerlog    --> Gerar log S/N
                         ,pr_des_reto   => vr_des_erro    --> Retorno OK / NOK
                         ,pr_dscritic   => vr_dscritic    --> Descricao do erro
                         ,pr_tab_erro   => vr_tab_erro);  --> Tabela com poss�ves erros
          --Se ocorreu erro
          IF vr_des_erro = 'NOK' THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
        END IF;

      ELSE  /* Liquidado */

        IF  rw_crapnrc.flgativo = 1  THEN /* Ativo */
          --Desativar o Rating
          pc_desativa_rating(pr_cdcooper   => pr_cdcooper    --> C�digo da Cooperativa
                            ,pr_cdagenci   => pr_cdagenci    --> C�digo da ag�ncia
                            ,pr_nrdcaixa   => pr_nrdcaixa    --> N�mero do caixa
                            ,pr_cdoperad   => pr_cdoperad    --> C�digo do operador
                            ,pr_rw_crapdat => rw_crapdat     --> Vetor com dados de par�metro (CRAPDAT)
                            ,pr_nrdconta   => pr_nrdconta    --> Conta do associado
                            ,pr_tpctrrat   => pr_tpctrrat    --> Tipo do Rating
                            ,pr_nrctrrat   => pr_nrctrrat    --> N�mero do contrato de Rating
                            ,pr_flgefeti   => 'S'            --> Flag para efetiva��o ou n�o do Rating
                            ,pr_idseqttl   => pr_idseqttl    --> Sequencia de titularidade da conta
                            ,pr_idorigem   => pr_idorigem    --> Indicador da origem da chamada
                            ,pr_inusatab   => vr_inusatab    --> Indicador de utiliza��o da tabela de juros
                            ,pr_nmdatela   => pr_nmdatela    --> Nome datela conectada
                            ,pr_flgerlog   => vr_flgerlog    --> Gerar log S/N
                            ,pr_des_reto   => vr_des_erro    --> Retorno OK / NOK
                            ,pr_tab_erro   => vr_tab_erro);  --> Tabela com poss�ves erros
          --Se ocorreu erro
          IF vr_des_erro = 'NOK' THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
        END IF;
      END IF;
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_des_erro:= 'OK';
        pr_dscritic:= NULL;
      WHEN vr_exc_erro THEN
        pr_des_erro:= 'NOK';
        pr_dscritic:= NULL;
      WHEN OTHERS THEN
        NULL;
    END;
  END pc_verifica_contrato_rating;

  /*****************************************************************************
   Gravar itens do rating na crapras quando for efetivada a proposta ou em
   temp temp-table quando for somente criada uma proposta.
  *****************************************************************************/
  PROCEDURE pc_grava_item_rating(pr_cdcooper IN INTEGER  --Codigo Cooperativa
                                ,pr_nrdconta IN INTEGER  --Numero da Conta
                                ,pr_tpctrato IN INTEGER  --Tipo Contrato Rating
                                ,pr_nrctrato IN INTEGER  --Numero Contrato Rating
                                ,pr_nrtopico IN INTEGER  --Numero do topico
                                ,pr_nritetop IN INTEGER  --Numero Contrato Rating
                                ,pr_nrseqite IN INTEGER  --Numero Contrato Rating
                                ,pr_flgcriar IN INTEGER --Indicado se deve criar o rating
                                ,pr_tab_crapras IN OUT typ_tab_crapras
                                ,pr_dscritic OUT VARCHAR2) IS           --Descricao do erro

  /* ..........................................................................

     Programa: pc_grava_item_rating         Antigo: b1wgen0043.p/grava_item_rating
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Odirlei Busana - AMcom
     Data    :Aagosto/2014.                          Ultima Atualizacao: 27/08/2014

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  : Gravar itens do rating na crapras quando for efetivada a proposta ou em
                 temp temp-table quando for somente criada uma proposta.

     Alteracoes: 27/08/2014 - Convers�o Progress -> Oracle - Odirlei (AMcom)

  ............................................................................. */
  --------------- VARIAVEIS ----------------
    -- Descri��o da critica
    vr_dscritic VARCHAR2(4000);
    -- Exce��o de sa�da
    vr_exc_erro EXCEPTION;
    --indice temptable
    vr_index VARCHAR2(50);

  BEGIN

    /* Criar Rating proposto */
    IF pr_flgcriar = 1 THEN  /* Criar Rating proposto */
      BEGIN
        /* Atualizacao Rating */
        UPDATE crapras
           SET crapras.nrseqite = pr_nrseqite
         WHERE crapras.cdcooper = pr_cdcooper
           AND crapras.nrdconta = pr_nrdconta
           AND crapras.nrctrrat = pr_nrctrato
           AND crapras.tpctrrat = pr_tpctrato
           AND crapras.nrtopico = pr_nrtopico
           AND crapras.nritetop = pr_nritetop;

        -- senao atualizou nenhum registro, deve inserir
        IF SQL%Rowcount = 0 THEN
          /* Inserir Rating */
          INSERT INTO crapras
                    ( nrdconta,
                      nrtopico,
                      nritetop,
                      nrseqite,
                      cdcooper,
                      nrctrrat,
                      tpctrrat)
               VALUES(pr_nrdconta,  --nrdconta,
                      pr_nrtopico,  --nrtopico,
                      pr_nritetop,  --nritetop,
                      pr_nrseqite,  --nrseqite,
                      pr_cdcooper,  --cdcooper,
                      pr_nrctrato,  --nrctrrat,
                      pr_tpctrato); --tpctrrat
        END IF;
      EXCEPTION
        -- tratar erros
        WHEN OTHERS THEN
          vr_dscritic := 'N�o foi possivel gravar item rating (nrdconta='||pr_nrdconta||
                         ' nrctrrat='||pr_nrctrato||'): '||SQLerrm;
         raise vr_exc_erro;
      END;
    ELSE
      -- caso n�o grave deve gerar temptable
      -- definir indice
      vr_index := lpad(pr_nrtopico,5,'0') || lpad(pr_nritetop,5,'0') || lpad(pr_nrseqite,5,'0');
      -- incluir dados na temptable
      pr_tab_crapras(vr_index).nrtopico := pr_nrtopico;
      pr_tab_crapras(vr_index).nritetop := pr_nritetop;
      pr_tab_crapras(vr_index).nrseqite := pr_nrseqite;
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na pc_grava_item_rating: '||SQLErrm;
  END pc_grava_item_rating;

  /* Valor da operacao do Rating */
  FUNCTION fn_valor_operacao(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                            ,pr_nrdconta IN crapass.nrdconta%TYPE --> Conta do associado
                            ,pr_tpctrato IN crapnrc.tpctrrat%TYPE --> Tipo do Rating
                            ,pr_nrctrato IN crapnrc.nrctrrat%TYPE --> N�mero do contrato de Rating
                            ) RETURN NUMBER IS
  /* ..........................................................................

       Programa: fn_valor_operacao         Antigo: b1wgen0043 --> valor-operacao
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Marcos Ernani Martini
       Data    : Agosto/2014.                          Ultima Atualizacao: 10/05/2016

       Dados referentes ao programa:

       Frequencia: Sempre que chamado por outros programas.
       Objetivo  :  Valor da operacao do Rating

       Alteracoes: 27/08/2014 - Convers�o Progress -> Oracle - Marcos (Supero)

				   10/05/2016 - Ajuste para utitlizar rowtype locais 
								(Andrei  - RKAM).
    ............................................................................. */

  BEGIN
    DECLARE
      -- Valor para retorno
      vr_vloperac NUMBER := 0;
      
      rw_crawepr2 cr_crawepr%ROWTYPE;
      rw_crapprp1 cr_crapprp%ROWTYPE;
      rw_craplim1 cr_craplim%ROWTYPE;
      
    BEGIN
      -- Para empr�stimos
      IF pr_tpctrato = 90 THEN
        -- Testar se existe informa��o complementar do empr�stimo
        rw_crawepr2 := NULL;
        OPEN cr_crawepr(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrctrato => pr_nrctrato);
        FETCH cr_crawepr
         INTO rw_crawepr2;
        -- Se existir
        IF cr_crawepr%FOUND THEN
          CLOSE cr_crawepr;
          -- Usar daqui
          vr_vloperac := rw_crawepr2.vlemprst;
        ELSE
          CLOSE cr_crawepr;
          -- Testar se existe a informa��o da proposta do empr�stimo
          rw_crapprp1 := null;
          OPEN cr_crapprp(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_tpctrato => pr_tpctrato
                         ,pr_nrctrato => pr_nrctrato);
          FETCH cr_crapprp
           INTO rw_crapprp1;
          CLOSE cr_crapprp;
          -- Usar da proposta
          vr_vloperac := rw_crapprp1.vlctrbnd;
        END IF;
      ELSE
        -- Busca do valor da tabela de limites
        rw_craplim1 := null;
        OPEN cr_craplim(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_tpctrato => pr_tpctrato
                       ,pr_nrctrato => pr_nrctrato);
        FETCH cr_craplim
         INTO rw_craplim1;
        CLOSE cr_craplim;
        -- Usar do limite
        vr_vloperac := rw_craplim1.vllimite;
      END IF;
      -- Efetuar o retorno
      RETURN vr_vloperac;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN 0;
    END;
  END fn_valor_operacao;

  /* Procedure efetivar o Rating */
  PROCEDURE pc_ratings_cooperado(pr_cdcooper   IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                ,pr_cdagenci   IN crapass.cdagenci%TYPE --> C�digo da ag�ncia
                                ,pr_nrdconta   IN crapass.nrdconta%TYPE --> Conta do associado
                                ,pr_nrregist   IN INTEGER               --> N�mero de registros
                                ,pr_nriniseq   IN INTEGER               --> N�mero sequencial 
                                ,pr_dtinirat   IN DATE                  --> Data de in�cio do Rating
                                ,pr_dtfinrat   IN DATE                  --> Data de termino do Rating
                                ,pr_insitrat   IN PLS_INTEGER           --> Situa��o do Rating
                                ,pr_qtregist   OUT INTEGER              --> Quantidade de registros encontrados
                                ,pr_tab_ratings OUT RATI0001.typ_tab_ratings    --> Registro com os ratings do associado
                                ,pr_des_reto    OUT VARCHAR2) IS                --> Indicador erro
  BEGIN
    /* ..........................................................................

       Programa: pc_ratings_cooperado         Antigo: b1wgen0043 --> ratings_cooperado
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Marcos Ernani Martini
       Data    : Agosto/2014.                          Ultima Atualizacao: 10/05/2016

       Dados referentes ao programa:

       Frequencia: Sempre que chamado por outros programas.
       Objetivo  : Procedure que traz todas as informacoes de todos os ratings do cooperado.
                   Usada na ATURAT e na hora de alteracao dos ratings

       Alteracoes: 27/08/2014 - Convers�o Progress -> Oracle - Marcos (Supero)

	               10/05/2016 - Ajuste para inserir controle de pagina��o devido a convers�o da 
				                tela ATURAT
                                (Andrei - RKAM).

    ............................................................................. */
    DECLARE
      -- Busca dos ratings
      CURSOR cr_crapnrc IS
        SELECT nrc.nrdconta
              ,nrc.tpctrrat
              ,nrc.nrctrrat
              ,ass.cdagenci
			        ,ass.nmprimtl
              ,nrc.indrisco
              ,nrc.dtmvtolt
              ,nrc.dteftrat
              ,nrc.insitrat
              ,nrc.nrnotrat
              ,nrc.nrnotatl
              ,nrc.inrisctl
              ,nrc.vlutlrat
              ,nrc.flgorige
			        ,nrc.cdoperad
          FROM crapass ass
              ,crapnrc nrc
         WHERE nrc.cdcooper = ass.cdcooper
           AND nrc.nrdconta = ass.nrdconta
           -- Filtros
           AND nrc.cdcooper = pr_cdcooper
           AND nrc.flgativo = 1 -- SIM
           -- OS testes abaixo garantem que se n�o foi enviado nada
           -- no parametro ou zero, usar o pr�prio valor do campo
           -- na tabela, ou seja, sempre trazer
           AND nrc.nrdconta = DECODE(nvl(pr_nrdconta,0),0,nrc.nrdconta,pr_nrdconta)
           AND nrc.insitrat = DECODE(nvl(pr_insitrat,0),0,nrc.insitrat,pr_insitrat)
           AND ass.cdagenci = DECODE(nvl(pr_cdagenci,0),0,ass.cdagenci,pr_cdagenci)
           AND nrc.dtmvtolt >= NVL(pr_dtinirat,nrc.dtmvtolt)
           AND nrc.dtmvtolt <= NVL(pr_dtfinrat,nrc.dtmvtolt)
         ORDER BY ass.cdagenci 
			           ,nrc.nrdconta
                 ,nrc.tpctrrat
                 ,nrc.nrctrrat
                 ,nrc.insitrat DESC
                 ,nrc.nrnotrat DESC
                 ,nrc.dtmvtolt;

      --Busca o operador      
      CURSOR cr_crapope(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_cdoperad IN crapope.cdoperad%TYPE) IS
      SELECT crapope.nmoperad
        FROM crapope
       WHERE crapope.cdcooper = pr_cdcooper
         AND crapope.cdoperad = pr_cdoperad;
      rw_crapope cr_crapope%ROWTYPE;

      -- Valor da opera��o
      vr_vloperac NUMBER;
      -- Indice para a pltable
      vr_indratng PLS_INTEGER;

	  --Variaveis locais
      vr_nrregist  INTEGER; 
      vr_qtregist  INTEGER := 0;

    BEGIN

	  vr_nrregist := pr_nrregist;

      -- Efetuar la�o para retornar todos os registros
      FOR rw_crapnrc IN cr_crapnrc LOOP

		  --Incrementar contador
		  vr_qtregist:= nvl(vr_qtregist,0) + 1;
          
		  -- controles da paginacao 
		  IF (vr_qtregist < pr_nriniseq) OR
			 (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN

			--Proximo
			CONTINUE;  
              
		  END IF; 
          
		  IF vr_nrregist >= 1 THEN

        -- Buscar o valor da operacao
        vr_vloperac := fn_valor_operacao(pr_cdcooper => pr_cdcooper
                                        ,pr_nrdconta => rw_crapnrc.nrdconta
                                        ,pr_tpctrato => rw_crapnrc.tpctrrat
                                        ,pr_nrctrato => rw_crapnrc.nrctrrat);
        -- Enfim, criar o registro do Rating
        vr_indratng := pr_tab_ratings.count()+1;
        pr_tab_ratings(vr_indratng).cdagenci := rw_crapnrc.cdagenci;
        pr_tab_ratings(vr_indratng).nrdconta := rw_crapnrc.nrdconta;
			pr_tab_ratings(vr_indratng).nmprimtl := rw_crapnrc.nmprimtl;
        pr_tab_ratings(vr_indratng).nrctrrat := rw_crapnrc.nrctrrat;
        pr_tab_ratings(vr_indratng).tpctrrat := rw_crapnrc.tpctrrat;
        pr_tab_ratings(vr_indratng).indrisco := rw_crapnrc.indrisco;
        pr_tab_ratings(vr_indratng).dtmvtolt := rw_crapnrc.dtmvtolt;
        pr_tab_ratings(vr_indratng).dteftrat := rw_crapnrc.dteftrat;
        pr_tab_ratings(vr_indratng).cdoperad := rw_crapnrc.cdoperad;
        pr_tab_ratings(vr_indratng).insitrat := rw_crapnrc.insitrat;
        pr_tab_ratings(vr_indratng).nrnotrat := rw_crapnrc.nrnotrat;
        pr_tab_ratings(vr_indratng).nrnotatl := rw_crapnrc.nrnotatl;
        pr_tab_ratings(vr_indratng).inrisctl := rw_crapnrc.inrisctl;
        pr_tab_ratings(vr_indratng).vlutlrat := rw_crapnrc.vlutlrat;
        pr_tab_ratings(vr_indratng).flgorige := rw_crapnrc.flgorige;

        -- O valor s� ser� enviado em caso de diferente de zero
        IF vr_vloperac <> 0 THEN
          pr_tab_ratings(vr_indratng).vloperac := vr_vloperac;
        END IF;

        -- Buscar a descri��o da opera��o
        pr_tab_ratings(vr_indratng).dsdopera := fn_busca_descricao_operacao(pr_tpctrrat => rw_crapnrc.tpctrrat);
			
        -- Buscar a descri��o da situa��o
        pr_tab_ratings(vr_indratng).dsditrat := fn_busca_descricao_situacao(pr_insitrat => rw_crapnrc.insitrat);

			OPEN cr_crapope(pr_cdcooper => pr_cdcooper
			  			   ,pr_cdoperad => rw_crapnrc.cdoperad);
                         
			FETCH cr_crapope INTO rw_crapope;
          
			IF cr_crapope%FOUND THEN
            
			  --Fecha o cursor
			  CLOSE cr_crapope;
            
			  pr_tab_ratings(vr_indratng).nmoperad := rw_crapope.nmoperad;
          
			ELSE
            
			  --Fecha o cursor
			  CLOSE cr_crapope;
          
			END IF;               
          
			--Diminuir registros
			vr_nrregist:= nvl(vr_nrregist,0) - 1;
          
			END IF;

      END LOOP;

	  pr_qtregist := vr_qtregist;

      -- Retorno OK
      pr_des_reto := 'OK';

    EXCEPTION
      WHEN OTHERS THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
    END;
  END pc_ratings_cooperado;

  /* Procedure para verificar se � poss�vel efetivar o Rating */
  PROCEDURE pc_verifica_efetivacao(pr_cdcooper   IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                  ,pr_cdagenci   IN crapass.cdagenci%TYPE --> C�digo da ag�ncia
                                  ,pr_nrdcaixa   IN craperr.nrdcaixa%TYPE --> N�mero do caixa
                                  ,pr_nrdconta   IN crapass.nrdconta%TYPE --> Conta do associado
                                  ,pr_nrnotrat   IN crapnrc.nrnotrat%TYPE --> Nota atingida na soma dos itens do rating.
                                  ,pr_vlutiliz   IN NUMBER                --> Valor utilizado para grava��o
                                  ,pr_flgefeti  OUT pls_integer           --> Flag do resultado da efetiva��o do Rating
                                  ,pr_tab_erro  OUT GENE0001.typ_tab_erro --> Tabela de retorno de erro
                                  ,pr_des_reto  OUT VARCHAR2) IS          --> Indicador erro
  BEGIN
    /* ..........................................................................

       Programa: pc_verifica_efetivacao         Antigo: b1wgen0043 --> verifica_efetivacao
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Marcos Ernani Martini
       Data    : Agosto/2014.                          Ultima Atualizacao: 27/08/2014

       Dados referentes ao programa:

       Frequencia: Sempre que chamado por outros programas.
       Objetivo  : Verificar se o Rating deve ser ativado.

       Alteracoes: 27/08/2014 - Convers�o Progress -> Oracle - Marcos (Supero)

    ............................................................................. */
    DECLARE
      -- Tratamento de erros
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      vr_exc_erro EXCEPTION;
      -- Variaveis auxiliares ao calculo
      vr_vlrating NUMBER; -- Valor parametrizado de rating
      vr_vlmaxleg NUMBER; -- Valor m�ximo legal
      -- Busca de rating para a proposta solicitada
      CURSOR cr_crapnrc IS
        SELECT nrnotrat
              ,tpctrrat
              ,nrctrrat
          FROM crapnrc
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND insitrat = 2; -- Efetivo
      rw_crapnrc cr_crapnrc%ROWTYPE;
    BEGIN
      -- Default da efetiva��o � nao
      pr_flgefeti := 0;
      -- Retornar valor de parametriza��o do rating cadastrado na TAB036
      pc_param_valor_rating(pr_cdcooper => pr_cdcooper --> C�digo da Cooperativa
                           ,pr_vlrating => vr_vlrating --> Valor parametrizado
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic);
      -- Se houve erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        -- Encerrar o processo
        RAISE vr_exc_erro;
      END IF;
      -- Buscar valor maximo legal cadastrado pela CADCOP
      pc_valor_maximo_legal(pr_cdcooper => pr_cdcooper --> C�digo da Cooperativa
                           ,pr_vlmaxleg => vr_vlmaxleg --> Valor parametrizado
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic);
      -- Se houve erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        -- Encerrar o processo
        RAISE vr_exc_erro;
      END IF;

      -- Valor deve estar acima do legal
      IF NOT (pr_vlutiliz >= vr_vlrating OR pr_vlutiliz >= (vr_vlmaxleg / 3)) THEN
         RAISE vr_exc_erro;
      END IF;

      -- Busca de rating para a proposta solicitada
      OPEN cr_crapnrc;
      FETCH cr_crapnrc
       INTO rw_crapnrc;
      -- Se encontrou
      IF cr_crapnrc%FOUND THEN
        -- Se o Rating da operacao atual for pior que o Rating efetivo
        IF rw_crapnrc.nrnotrat < pr_nrnotrat THEN
          -- Efetiva
           pr_flgefeti := 1;
        -- Se o RATING for o antigo
        ELSIF rw_crapnrc.tpctrrat = 0 AND rw_crapnrc.nrctrrat = 0 THEN
          -- Sempre migra para o novo
          pr_flgefeti := 1;
        END IF;
      ELSE
        -- Nao existe nenhum Rating Efetivo
        pr_flgefeti := 1;
      END IF;
      -- Fechar o cursor do rating
      CLOSE cr_crapnrc;

      -- Retorno OK
      pr_des_reto := 'OK';
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
        IF vr_cdcritic IS NOT NULL THEN
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 --> Fixo
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
        END IF;
      WHEN OTHERS THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        -- Montar descri��o de erro n�o tratado
        vr_dscritic := 'Erro n�o tratado na RATI0001.pc_verifica_efetivacao> '||sqlerrm;
        -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
  END pc_verifica_efetivacao;

  /* Procedure efetivar o Rating */
  PROCEDURE pc_efetivar_rating(pr_cdcooper   IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                              ,pr_nrdconta   IN crapass.nrdconta%TYPE --> Conta do associado
                              ,pr_tpctrato   IN crapnrc.tpctrrat%TYPE --> Tipo do Rating
                              ,pr_nrctrato   IN crapnrc.nrctrrat%TYPE --> N�mero do contrato de Rating
                              ,pr_cdoperad   IN crapnrc.cdoperad%TYPE --> C�digo do operador
                              ,pr_dtmvtolt   IN crapdat.dtmvtolt%TYPE --> Data do movimento atual
                              ,pr_vlutiliz   IN NUMBER                --> Valor utilizado para grava��o
                              ,pr_flgatual   IN BOOLEAN               --> Flag para efetuar ou n�o a atualiza��o
                              ,pr_tab_efetivacao OUT RATI0001.typ_tab_efetivacao --> Registro de efetiva��o
                              ,pr_tab_ratings    OUT RATI0001.typ_tab_ratings    --> Registro com os ratings do associado
                              ,pr_tab_erro       OUT gene0001.typ_tab_erro       --> Tabela de retorno de erro
                              ,pr_des_reto       OUT VARCHAR2) IS                --> Indicador erro
  BEGIN
    /* ..........................................................................

       Programa: pc_efetivar_rating         Antigo: b1wgen0043 --> efetivar_rating
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Marcos Ernani Martini
       Data    : Agosto/2014.                          Ultima Atualizacao: 10/05/2016

       Dados referentes ao programa:

       Frequencia: Sempre que chamado por outros programas.
       Objetivo  : Efetivar o Rating do Cooperado

       Alteracoes: 27/08/2014 - Convers�o Progress -> Oracle - Marcos (Supero)

				   10/05/2016 - Ajuste para enviar novos parametros a rotina que efetua
								a busca dos ratings do cooperado
								(Andrei - RKAM).
    ............................................................................. */
    DECLARE
      -- Tratamento de erros
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      vr_exc_erro EXCEPTION;
      -- Variaveis auxiliares
      vr_indrisco VARCHAR2(2);           -- Risco do pior rating
      vr_rowidnrc ROWID;                 -- Rowid do pior rating
      vr_nrctrrat crapnrc.nrctrrat%TYPE; -- Contrato do pior rating
      vr_dsoperac VARCHAR2(100);         -- Descri��o da opera��o do pior rating
	  vr_qtregist INTEGER;
    BEGIN
      -- Se tiver um Rating efetivo, mudar para proposto
      pc_muda_situacao_proposto(pr_cdcooper => pr_cdcooper --> C�digo da Cooperativa
                               ,pr_nrdconta => pr_nrdconta --> Conta do associado
                               ,pr_dtmvtolt => pr_dtmvtolt --> Data atual
                               ,pr_vlutiliz => pr_vlutiliz --> Valor para lan�amento
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);
      -- Se houve erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        -- Encerrar o processo
        RAISE vr_exc_erro;
      END IF;
      -- Procurar o Rating Proposto com pior nota.
      pc_procura_pior_nota(pr_cdcooper => pr_cdcooper --> C�digo da Cooperativa
                          ,pr_nrdconta => pr_nrdconta --> Conta do associado
                          ,pr_indrisco => vr_indrisco --> Risco do pior rating
                          ,pr_rowidnrc => vr_rowidnrc --> Rowid do pior rating
                          ,pr_nrctrrat => vr_nrctrrat --> N�mero do contrato do pior rating
                          ,pr_dsoperac => vr_dsoperac --> Descri��o da opera��o do rating
                          ,pr_cdcritic => vr_cdcritic
                          ,pr_dscritic => vr_dscritic);
      -- N�o era tratado retorno de erro no Progress
      ---- Se houve erro
      --IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --  -- Encerrar o processo
      --  RAISE vr_exc_erro;
      --END IF;
      -- Efetivar o rating de pior nota
      pc_muda_situacao_efetivo(pr_rowidnrc => vr_rowidnrc --> Rowid para grava��o do rating
                              ,pr_cdoperad => pr_cdoperad --> C�digo do operador
                              ,pr_dtmvtolt => pr_dtmvtolt --> Data atual
                              ,pr_vlutiliz => pr_vlutiliz --> Valor para lan�amento
                              ,pr_flgatual => pr_flgatual --> N�o atualizar
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);
      -- Se houve erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        -- Encerrar o processo
        RAISE vr_exc_erro;
      END IF;

      -- Retornar os Ratings do Cooperado
      pc_ratings_cooperado(pr_cdcooper    => pr_cdcooper    --> Cooperativa conectada
                          ,pr_cdagenci    => 0              --> C�digo da ag�ncia
                          ,pr_nrdconta    => pr_nrdconta    --> Conta do associado
                          ,pr_nrregist    => 999999         --> N�mero de registros
                          ,pr_nriniseq    => 1              --> N�mero sequencial 
                          ,pr_dtinirat    => null           --> Data de in�cio do Rating
                          ,pr_dtfinrat    => null           --> Data de termino do Rating
                          ,pr_insitrat    => 0              --> Situa��o do Rating
                          ,pr_qtregist    => vr_qtregist    --> Quantidade de registros encontrados
                          ,pr_tab_ratings => pr_tab_ratings --> Registro com os ratings do associado
                          ,pr_des_reto    => pr_des_reto);

      -- Quando esta voltando atras operacao
      IF pr_tpctrato = 0 AND pr_nrctrato = 0 THEN
        -- Grava como origem aquele q estiver sendo efetivado
        pc_grava_rating_origem(pr_cdcooper => pr_cdcooper   --> C�digo da Cooperativa
                              ,pr_nrdconta => pr_nrdconta   --> Conta do associado
                              ,pr_rowidnrc => vr_rowidnrc   --> Rowid para grava��o do rating
                              ,pr_cdcritic => vr_cdcritic   --> Critica encontrada no processo
                              ,pr_dscritic => vr_dscritic); --> Descritivo do erro
      ELSE
        -- Senao grava aquele que realmente originou o efetivo
        pc_grava_rating_origem(pr_cdcooper => pr_cdcooper   --> C�digo da Cooperativa
                              ,pr_nrdconta => pr_nrdconta   --> Conta do associado
                              ,pr_rowidnrc => null          --> Rowid para grava��o do rating
                              ,pr_cdcritic => vr_cdcritic   --> Critica encontrada no processo
                              ,pr_dscritic => vr_dscritic); --> Descritivo do erro
      END IF;
      --------------------------------------------------------------------
      ----- N�o vers�o progress n�o testava se retornou erro aqui...  ----
      --------------------------------------------------------------------
      -- Se encontrou erro
      --IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
      --  -- Gerar o erro
      --  RAISE vr_exc_erro;
      --END IF;

      -- Criar o registro de efetiva��o
      pr_tab_efetivacao(1).idseqmen := 1;
      pr_tab_efetivacao(1).dsdefeti := 'Efetivado para a Central de Risco o risco ' || vr_indrisco
                                              || ' do contrato ' || to_char(vr_nrctrrat) ||'.';

      -- Efetuar loop para busca o Rating Efetivo
      FOR vr_indratng IN pr_tab_ratings.FIRST..pr_tab_ratings.LAST LOOP
        -- Assim que encontrar o rating efetivo
        IF pr_tab_ratings(vr_indratng).insitrat = 2 THEN
          -- Retornar valor da opera��o
          pr_tab_efetivacao(2).idseqmen := 2;
          pr_tab_efetivacao(2).dsdefeti := 'Efetivado para a Central de Risco o risco "';
          -- Substituir Risco AA por A
          IF pr_tab_ratings(vr_indratng).indrisco = 'AA' THEN
            pr_tab_efetivacao(2).dsdefeti := pr_tab_efetivacao(2).dsdefeti || 'A';
          ELSE
            pr_tab_efetivacao(2).dsdefeti := pr_tab_efetivacao(2).dsdefeti || pr_tab_ratings(vr_indratng).indrisco;
          END IF;
          -- Continuar a montagem
          pr_tab_efetivacao(2).dsdefeti := pr_tab_efetivacao(2).dsdefeti
                                        || '" do contrato no '||trim(gene0002.fn_mask_contrato(pr_tab_ratings(vr_indratng).nrctrrat))
                                        || ' do ' ||pr_tab_ratings(vr_indratng).dsdopera||' no valor de R$ '
                                        || to_char(pr_tab_ratings(vr_indratng).vloperac,'fm99g999g990d00') || '.' ;
          -- Sair do loop pois s� precisamos do efetivado
          EXIT;
        END IF;
      END LOOP;

      -- Retorno OK
      pr_des_reto := 'OK';
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
        IF vr_cdcritic IS NOT NULL THEN
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => 0
                               ,pr_nrdcaixa => 0
                               ,pr_nrsequen => 1 --> Fixo
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
        END IF;
      WHEN OTHERS THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        -- Montar descri��o de erro n�o tratado
        vr_dscritic := 'Erro n�o tratado na RATI0001.pc_efetivar_rating > '||sqlerrm;
        -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => 0
                             ,pr_nrdcaixa => 0
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
  END pc_efetivar_rating;

  /* Obter as descricoes do risco, provisao , etc ...  */
  PROCEDURE pc_descricoes_risco_busca(pr_inpessoa           IN crapass.inpessoa%TYPE --> Tipo de pessoa
                                     ,pr_nrnoveri           IN NUMBER                --> Valor a verificar
                                     ,pr_nivrisco           IN pls_integer           --> Nivel do Risco
                                     ,pr_tab_provisao       IN typ_tab_provisao      --> Tabela com informa��es da craptab cfme op��o
                                     ,pr_tab_impress_risco OUT RATI0001.typ_tab_impress_risco --> Registro Nota e risco do cooperado no Rating solicitado
                                     ,pr_des_reto          OUT VARCHAR2) IS          --> Indicador erro IS
  BEGIN
    /* ..........................................................................

       Programa: pc_descricoes_risco_busca         Antigo: b1wgen0043 --> descricoes_risco
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Marcos Ernani Martini
       Data    : Agosto/2014.                          Ultima Atualizacao: 28/08/2014

       Dados referentes ao programa:

       Frequencia: Sempre que chamado por outros programas.
       Objetivo  : Obter as descricoes do risco, provisao , etc ...

       Alteracoes: 28/08/2014 - Convers�o Progress -> Oracle - Marcos (Supero)

    ............................................................................. */
    DECLARE
      -- Contador para as informa��es da tabela de provis�es
      vr_contador number;
      -- Indice para grava��o na tabela de impressao dos riscos
      vr_indimpri number;
    BEGIN
      -- Efetuar LOOP sob a temp-table com os riscos
      vr_contador := pr_tab_provisao.first;
      LOOP
        -- Sair quando n�o existir o registro na tabela
        EXIT WHEN vr_contador IS NULL;
        -- Testar valores para pessoa fisica ou Juridica
        -- Ou se o nivel passado � igual ao contador
        IF (pr_inpessoa = 1 AND pr_nrnoveri >= pr_tab_provisao(vr_contador).notadefi AND pr_nrnoveri <= pr_tab_provisao(vr_contador).notatefi)
        OR (pr_inpessoa > 1 AND pr_nrnoveri >= pr_tab_provisao(vr_contador).notadeju AND pr_nrnoveri <= pr_tab_provisao(vr_contador).notateju)
        OR (pr_nivrisco <> 0 AND pr_nivrisco = vr_contador) THEN
          -- Criar novo registro de impress�o nesta faixa de risco
          vr_indimpri := pr_tab_impress_risco.count()+1;
          pr_tab_impress_risco(vr_indimpri).vlrtotal := pr_nrnoveri;
          pr_tab_impress_risco(vr_indimpri).dsdrisco := pr_tab_provisao(vr_contador).dsdrisco;
          pr_tab_impress_risco(vr_indimpri).vlprovis := pr_tab_provisao(vr_contador).percentu;
          -- Parecer cfme tipo de pessoa
          IF pr_inpessoa = 1 THEN
            pr_tab_impress_risco(vr_indimpri).dsparece := pr_tab_provisao(vr_contador).parecefi;
          ELSE
            pr_tab_impress_risco(vr_indimpri).dsparece := pr_tab_provisao(vr_contador).pareceju;
          END IF;
          -- Risco antigo, nao mais utilizado
          IF pr_tab_impress_risco(vr_indimpri).dsdrisco = 'AA' THEN
            pr_tab_impress_risco(vr_indimpri).dsdrisco := 'A';
          END IF;
        END IF;
        -- Buscar o pr�ximo risco
        vr_contador := pr_tab_provisao.next(vr_contador);
      END LOOP;
      -- Retorno OK
      pr_des_reto := 'OK';
    EXCEPTION
      WHEN OTHERS THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
    END;
  END pc_descricoes_risco_busca;

  /* Obter as descricoes do risco, provisao , etc ...  */
  PROCEDURE pc_descricoes_risco(pr_cdcooper    IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                               ,pr_inpessoa    IN crapass.inpessoa%TYPE --> Tipo de pessoa
                               ,pr_nrnotrat    IN NUMBER                --> Valor baseado no calculo do rating
                               ,pr_nrnotatl    IN NUMBER                --> Valor baseado no calculo do risco
                               ,pr_nivrisco    IN pls_integer           --> Nivel do Risco
                               ,pr_tab_impress_risco_cl OUT RATI0001.typ_tab_impress_risco --> Registro Nota e risco do cooperado naquele Rating - PROVISAOCL
                               ,pr_tab_impress_risco_tl OUT RATI0001.typ_tab_impress_risco --> Registro Nota e risco do cooperado naquele Rating - PROVISAOTL
                               ,pr_des_reto             OUT VARCHAR2) IS          --> Indicador erro IS
  BEGIN
    /* ..........................................................................

       Programa: pc_descricoes_risco         Antigo: b1wgen0043 --> descricoes_risco
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Marcos Ernani Martini
       Data    : Agosto/2014.                          Ultima Atualizacao: 28/08/2014

       Dados referentes ao programa:

       Frequencia: Sempre que chamado por outros programas.
       Objetivo  : Direcionar a obten��o as descricoes do risco, provisao , etc ...

       Alteracoes: 28/08/2014 - Convers�o Progress -> Oracle - Marcos (Supero)
                   
                   25/10/2016 - Corre��o do problema relatado no chamado 541414. (Kelvin)
    ............................................................................. */
    DECLARE
	  /* Cursor gen�rico de parametriza��o */
      CURSOR cr_craptab(pr_nmsistem IN craptab.nmsistem%TYPE
                       ,pr_tptabela IN craptab.tptabela%TYPE
                       ,pr_cdempres IN craptab.cdempres%TYPE
                       ,pr_cdacesso IN craptab.cdacesso%TYPE
                       ,pr_tpregist IN craptab.tpregist%TYPE) IS
        SELECT tab.cdcooper
              ,tab.dstextab
          FROM craptab tab
         WHERE tab.cdcooper        = pr_cdcooper
           AND UPPER(tab.nmsistem) = pr_nmsistem
           AND UPPER(tab.tptabela) = pr_tptabela
           AND tab.cdempres        = pr_cdempres
           AND UPPER(tab.cdacesso) = pr_cdacesso;

      -- Indice para gravacao nas temptables
      vr_contador NUMBER;
	  vr_percentu_temp NUMBER;
    BEGIN
      -- Se ainda n�o foram carregadas as informa��es na tabela de mem�ria de provisao risco
      IF vr_tab_provisao_cl.count() = 0 THEN
        -- Busca de todos os riscos conforme chave de acesso enviada
        FOR rw_craptab IN cr_craptab(pr_nmsistem => 'CRED'
                                    ,pr_tptabela => 'GENERI'
                                    ,pr_cdempres => '00'
                                    ,pr_cdacesso => 'PROVISAOCL'
                                    ,pr_tpregist => null) LOOP
          -- Carregar na tabela
          vr_contador := to_number(SUBSTR(rw_craptab.dstextab,12,2));
          vr_tab_provisao_cl(vr_contador).dsdrisco := TRIM(SUBSTR(rw_craptab.dstextab,8,3));
          vr_tab_provisao_cl(vr_contador).percentu := to_number(SUBSTR(rw_craptab.dstextab,1,6));
          vr_tab_provisao_cl(vr_contador).notadefi := to_number(SUBSTR(rw_craptab.dstextab,27,6));
          vr_tab_provisao_cl(vr_contador).notatefi := to_number(SUBSTR(rw_craptab.dstextab,34,6));
          vr_tab_provisao_cl(vr_contador).parecefi := SUBSTR(rw_craptab.dstextab,41,15);
          vr_tab_provisao_cl(vr_contador).notadeju := to_number(SUBSTR(rw_craptab.dstextab,56,6));
          vr_tab_provisao_cl(vr_contador).notateju := to_number(SUBSTR(rw_craptab.dstextab,62,6));
          vr_tab_provisao_cl(vr_contador).pareceju := SUBSTR(rw_craptab.dstextab,70,15);
		  
		  IF vr_tab_provisao_cl(vr_contador).dsdrisco = 'A' THEN
            vr_percentu_temp := vr_tab_provisao_cl(vr_contador).percentu;
          END IF; 
          IF vr_tab_provisao_cl(vr_contador).dsdrisco = 'AA' THEN
            vr_tab_provisao_cl(vr_contador).percentu := vr_percentu_temp;
          END IF;
		  
        END LOOP; --> Para cada risco
      END IF;

	  vr_percentu_temp := 0;

      -- Se ainda n�o foram carregadas as informa��es na tabela de mem�ria de provisao rating
      IF vr_tab_provisao_tl.count() = 0 THEN
        -- Busca de todos os riscos conforme chave de acesso enviada
        FOR rw_craptab IN cr_craptab(pr_nmsistem => 'CRED'
                                    ,pr_tptabela => 'GENERI'
                                    ,pr_cdempres => '00'
                                    ,pr_cdacesso => 'PROVISAOTL'
                                    ,pr_tpregist => null) LOOP
          -- Carregar na tabela
          vr_contador := to_number(SUBSTR(rw_craptab.dstextab,12,2));
          vr_tab_provisao_tl(vr_contador).dsdrisco := TRIM(SUBSTR(rw_craptab.dstextab,8,3));
          vr_tab_provisao_tl(vr_contador).percentu := to_number(SUBSTR(rw_craptab.dstextab,1,6));
          vr_tab_provisao_tl(vr_contador).notadefi := to_number(SUBSTR(rw_craptab.dstextab,27,6));
          vr_tab_provisao_tl(vr_contador).notatefi := to_number(SUBSTR(rw_craptab.dstextab,34,6));
          vr_tab_provisao_tl(vr_contador).parecefi := SUBSTR(rw_craptab.dstextab,41,15);
          vr_tab_provisao_tl(vr_contador).notadeju := to_number(SUBSTR(rw_craptab.dstextab,56,6));
          vr_tab_provisao_tl(vr_contador).notateju := to_number(SUBSTR(rw_craptab.dstextab,62,6));
          vr_tab_provisao_tl(vr_contador).pareceju := SUBSTR(rw_craptab.dstextab,70,15);
		  
		  IF vr_tab_provisao_tl(vr_contador).dsdrisco = 'A' THEN
            vr_percentu_temp := vr_tab_provisao_tl(vr_contador).percentu;
          END IF;
          IF vr_tab_provisao_tl(vr_contador).dsdrisco = 'AA' THEN
            vr_tab_provisao_tl(vr_contador).percentu := vr_percentu_temp;
          END IF;
		  
        END LOOP; --> Para cada risco
      END IF;

      -- Chamar rotina gen�rica para grava��o das informa��es da PROVISAOCL (Baseada no Risco)
      pc_descricoes_risco_busca(pr_inpessoa    => pr_inpessoa --> Tipo de pessoa
                               ,pr_nrnoveri    => pr_nrnotrat --> Valor a verificar
                               ,pr_nivrisco    => pr_nivrisco --> Nivel do Risco
                               ,pr_tab_provisao      => vr_tab_provisao_cl --> Tabela com informa��es da tab para esta op��o
                               ,pr_tab_impress_risco => pr_tab_impress_risco_cl --> Registro Nota e risco do cooperado no Rating solicitado
                               ,pr_des_reto          => pr_des_reto);

      -- Chamar rotina gen�rica para grava��o das informa��es da PROVISAOTL (Baseada no Rating)
      pc_descricoes_risco_busca(pr_inpessoa    => pr_inpessoa --> Tipo de pessoa
                               ,pr_nrnoveri    => pr_nrnotatl --> Valor a verificar
                               ,pr_nivrisco    => pr_nivrisco --> Nivel do Risco
                               ,pr_tab_provisao      => vr_tab_provisao_tl --> Tabela com informa��es da tab para esta op��o
                               ,pr_tab_impress_risco => pr_tab_impress_risco_tl --> Registro Nota e risco do cooperado no Rating solicitado
                               ,pr_des_reto          => pr_des_reto);

      -- Retorno OK
      pr_des_reto := 'OK';
    EXCEPTION
      WHEN OTHERS THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
    END;
  END pc_descricoes_risco;

  /* Ler o rating do associado e gerar o arquivo correnpondente  */
  PROCEDURE pc_gera_arq_impress_rating(pr_cdcooper    IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                      ,pr_cdagenci    IN crapass.cdagenci%TYPE --> C�digo da ag�ncia
                                      ,pr_nrdcaixa    IN craperr.nrdcaixa%TYPE --> N�mero do caixa
                                      ,pr_cdoperad    IN crapnrc.cdoperad%TYPE --> C�digo do operador
                                      ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE --> Data do movimento atual
                                      ,pr_nrdconta    IN crapass.nrdconta%TYPE --> Conta do associado
                                      ,pr_tpctrato    IN crapnrc.tpctrrat%TYPE --> Tipo do Rating
                                      ,pr_nrctrato    IN crapnrc.nrctrrat%TYPE --> N�mero do contrato de Rating
                                      ,pr_flgcriar    IN pls_integer           --> Flag para cria��o ou n�o do arquivo
                                      ,pr_flgcalcu    IN pls_integer           --> Flag para calculo ou n�o
                                      ,pr_idseqttl    IN crapttl.idseqttl%TYPE --> Sq do titular da conta
                                      ,pr_idorigem    IN pls_integer           --> Indicador da origem da chamada
                                      ,pr_nmdatela    IN craptel.nmdatela%TYPE --> Nome da tela conectada
                                      ,pr_flgerlog    IN VARCHAR2              --> Gerar log S/N
                                      ,pr_tab_crapras IN typ_tab_crapras       --> Interna da BO, para o calculo do Rating
                                      ,pr_tab_impress_coop     OUT RATI0001.typ_tab_impress_coop     --> Registro impress�o da Cooperado
                                      ,pr_tab_impress_rating   OUT RATI0001.typ_tab_impress_rating   --> Registro itens do Rating
                                      ,pr_tab_impress_risco_cl OUT RATI0001.typ_tab_impress_risco    --> Registro Nota e risco do cooperado naquele Rating - PROVISAOCL
                                      ,pr_tab_impress_risco_tl OUT RATI0001.typ_tab_impress_risco    --> Registro Nota e risco do cooperado naquele Rating - PROVISAOTL
                                      ,pr_tab_impress_assina   OUT RATI0001.typ_tab_impress_assina   --> Assinatura na impressao do Rating
                                      ,pr_tab_efetivacao       OUT RATI0001.typ_tab_efetivacao       --> Registro dos itens da efetiva��o
                                      ,pr_tab_erro             OUT gene0001.typ_tab_erro --> Tabela de retorno de erro
                                      ,pr_des_reto             OUT VARCHAR2) IS          --> Indicador erro IS
  BEGIN
    /* ..........................................................................

       Programa: pc_gera_arq_impress_rating         Antigo: b1wgen0043 --> gera-arquivo-impressao-rating
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Marcos Ernani Martini
       Data    : Agosto/2014.                          Ultima Atualizacao: 10/05/2016

       Dados referentes ao programa:

       Frequencia: Sempre que chamado por outros programas.
       Objetivo  : Ler o rating do associado e gerar o arquivo correnpondente

       Alteracoes: 28/08/2014 - Convers�o Progress -> Oracle - Marcos (Supero)

				   10/05/2016 - Ajuste decorrente a reestrutura��o das PL/TABLE
								(Andrei - RKAM).
    ............................................................................. */
    DECLARE
      -- Tratamento de exce��o
      vr_exc_erro exception;
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);

      -- Rowid para inser��o de log
      vr_nrdrowid ROWID;
      -- Sequencia para a tab_impress_rating
      vr_sqtb_imprat PLS_INTEGER;
	  vr_index_sub PLS_INTEGER;
      vr_index_itens PLS_INTEGER;
      -- Sequencia para a tab_efetivacao
      vr_sqtb_efetiv PLS_INTEGER;
      -- Flag para teste de exist�ncia da crapras
      vr_flg_crapras varchar2(1);
      -- Valores totais de cooperado, da nota e geral
      vr_notacoop NUMBER := 0;
      vr_vlrdnota NUMBER := 0;
      vr_vlrtotal NUMBER := 0;

      -- Cursor para encontrar o associado
      CURSOR cr_crapass(pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT ass.nmprimtl
            ,ass.inpessoa
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;

      -- Cursor para encontrar o operador
      CURSOR cr_crapope(pr_cdoperad IN crapope.cdoperad%TYPE) IS
      SELECT ope.nmoperad
        FROM crapope ope
       WHERE ope.cdcooper = pr_cdcooper
         AND upper(ope.cdoperad) = upper(pr_cdoperad);
      rw_crapope cr_crapope%ROWTYPE;

      -- Cursor para retornar topicos, itens e descri��o de ratings
      CURSOR cr_craprat(pr_inpessoa crapass.inpessoa%TYPE) IS
        SELECT rat.nrtopico
              ,rai.nritetop
              ,rad.nrseqite
              ,rat.intopico
              ,rat.dstopico
              ,rai.dsitetop
              ,rai.pesoitem
              ,rad.pesosequ
              ,rad.dsseqite
              ,row_number() over (partition by rat.nrtopico order by rat.nrtopico) nrsqtopi
              ,row_number() over (partition by rat.nrtopico,rai.nritetop order by rat.nrtopico,rai.nritetop) nrsqittp

           FROM craprad rad --> Descri��o do Rating
               ,craprai rai --> Itens do Rating
               ,craprat rat --> Topicos do Rating

         WHERE rad.cdcooper = rai.cdcooper
           AND rad.nrtopico = rai.nrtopico
           AND rad.nritetop = rai.nritetop

           AND rat.cdcooper = rai.cdcooper
           AND rat.nrtopico = rai.nrtopico

           AND rat.cdcooper = pr_cdcooper
           AND rat.flgativo = 1 --> Somente t�picos ativos
           AND rat.inpessoa = pr_inpessoa

         ORDER BY rat.nrtopico
                 ,rai.nritetop
                 ,rad.nrseqite;

      -- Testar existencia da crapras
      CURSOR cr_crapras(pr_nrtopico craprad.nrtopico%TYPE
                       ,pr_nritetop craprad.nritetop%TYPE
                       ,pr_nrseqite craprad.nrseqite%TYPE) IS
        SELECT 'S' --> Gravar na Flag se encontrar
          FROM crapras
         WHERE crapras.cdcooper = pr_cdcooper
           AND crapras.nrdconta = pr_nrdconta
           AND crapras.nrctrrat = pr_nrctrato
           AND crapras.tpctrrat = pr_tpctrato
           AND crapras.nrtopico = pr_nrtopico
           AND crapras.nritetop = pr_nritetop
           AND crapras.nrseqite = pr_nrseqite;

      -- Buscar as notas do rating do contrato
      CURSOR cr_crapnrc(pr_flefetivo varchar2 default 'N') IS
        SELECT flgorige
              ,DECODE(indrisco,'AA','A',indrisco) indrisco
              ,tpctrrat
              ,nrctrrat
          FROM crapnrc
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND ( -- Se foi solicitado o efetivo
                 (pr_flefetivo = 'S' AND insitrat = 2)
                or
                 -- Ou traz o contratro dos par�metros
                 (tpctrrat = pr_tpctrato AND nrctrrat = pr_nrctrato)
                );
      rw_crapnrc cr_crapnrc%ROWTYPE;

    BEGIN
      -- Validar associado enviado
      OPEN cr_crapass(pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      IF cr_crapass%NOTFOUND THEN
        -- Fecha o cursor
        CLOSE cr_crapass;
        -- Monta critica
        vr_cdcritic := 9;
        vr_dscritic := NULL;
        -- Gera exce��o
        RAISE vr_exc_erro;
      ELSE
        -- Fecha o cursor
        CLOSE cr_crapass;
      END IF;
      -- Validar operador enviado
      OPEN cr_crapope(pr_cdoperad => pr_cdoperad);
      FETCH cr_crapope INTO rw_crapope;
      IF cr_crapope%NOTFOUND THEN
        -- Fecha o cursor
        CLOSE cr_crapope;
        -- Monta critica
        vr_cdcritic := 67;
        vr_dscritic := NULL;
        -- Gera exce��o
        RAISE vr_exc_erro;
      ELSE
        -- Fecha o cursor
        CLOSE cr_crapope;
      END IF;
      -- Gravar as informacoes do cooperado
      pr_tab_impress_coop(1).nrdconta := pr_nrdconta;
      pr_tab_impress_coop(1).nmprimtl := rw_crapass.nmprimtl;
      pr_tab_impress_coop(1).nrctrrat := pr_nrctrato;
      pr_tab_impress_coop(1).tpctrrat := pr_tpctrato;
      IF rw_crapass.inpessoa = 1 THEN
        pr_tab_impress_coop(1).dspessoa := 'Pessoa Fisica';
      ELSE
        pr_tab_impress_coop(1).dspessoa := 'Pessoa Juridica';
      END IF;
      pr_tab_impress_coop(1).dsdopera := fn_busca_descricao_operacao(pr_tpctrrat => pr_tpctrato);
      -- La�o para retornar os Topicos do rating
      FOR rw_craprat IN cr_craprat(pr_inpessoa => rw_crapass.inpessoa) LOOP
        
        -- First-of rat.nrtopico
        IF rw_craprat.nrsqtopi = 1 THEN

          -- Criar registros do T�pico
          vr_sqtb_imprat := pr_tab_impress_rating.COUNT+1;
          pr_tab_impress_rating(vr_sqtb_imprat).intopico := rw_craprat.intopico;
          pr_tab_impress_rating(vr_sqtb_imprat).nrtopico := rw_craprat.nrtopico;
          pr_tab_impress_rating(vr_sqtb_imprat).dsitetop := rw_craprat.dstopico;

        END IF;

        -- First-of rai.nritetop
        IF rw_craprat.nrsqittp = 1 THEN

          -- Criar registros do Item do t�pico
          vr_index_sub:= pr_tab_impress_rating(vr_sqtb_imprat).tab_subtopico.count + 1;          
          pr_tab_impress_rating(vr_sqtb_imprat).tab_subtopico(vr_index_sub).nritetop := rw_craprat.nritetop;
          pr_tab_impress_rating(vr_sqtb_imprat).tab_subtopico(vr_index_sub).dsitetop := gene0002.fn_mask(rw_craprat.nrtopico,'z9')||'.'||gene0002.fn_mask(rw_craprat.nritetop,'z9')||' '||rw_craprat.dsitetop;
          pr_tab_impress_rating(vr_sqtb_imprat).tab_subtopico(vr_index_sub).dspesoit := to_char(rw_craprat.pesoitem,'990d00');
          
        END IF;

        -- Reiniciar teste de exist�ncia da crapras
        vr_flg_crapras := 'N';

        -- Se foi solicitada a cria��o OU ainda n�o foi calculado
        IF pr_flgcriar = 1 OR pr_flgcalcu = 0 THEN
          -- Busca na tabela
          OPEN cr_crapras(pr_nrtopico => rw_craprat.nrtopico
                         ,pr_nritetop => rw_craprat.nritetop
                         ,pr_nrseqite => rw_craprat.nrseqite);
          FETCH cr_crapras
            INTO vr_flg_crapras;
          CLOSE cr_crapras;
        ELSE
          -- Busca na temp-table
          IF pr_tab_crapras.exists(lpad(rw_craprat.nrtopico,5,'0')||lpad(rw_craprat.nritetop,5,'0')||lpad(rw_craprat.nrseqite,5,'0')) THEN
            vr_flg_crapras := 'S';
          END IF;
        END IF;
        -- Se encontrou crapras
        IF vr_flg_crapras = 'S' THEN
          -- Se for rating de cooperado
          IF rw_craprat.intopico = 1 THEN
            -- Acumular nota do cooperado
            vr_notacoop := vr_notacoop + (rw_craprat.pesoitem * rw_craprat.pesosequ);
          END IF;
          -- Calcular valor da nota geral
          vr_vlrdnota := rw_craprat.pesoitem * rw_craprat.pesosequ;
        ELSE
          -- Inicializar valor
          vr_vlrdnota := 0;
        END IF;

        -- Cria somente aqueles que ele pontuou
        IF vr_vlrdnota > 0 THEN

          -- Criar registros da sequencia do rating
          vr_index_itens := pr_tab_impress_rating(vr_sqtb_imprat).tab_subtopico(vr_index_sub).tab_itens.COUNT+1;
          pr_tab_impress_rating(vr_sqtb_imprat).tab_subtopico(vr_index_sub).tab_itens(vr_index_itens).nrseqite := rw_craprat.nrseqite;          
          pr_tab_impress_rating(vr_sqtb_imprat).tab_subtopico(vr_index_sub).tab_itens(vr_index_itens).dsitetop := gene0002.fn_mask(rw_craprat.nrtopico,'z9')||'.'||gene0002.fn_mask(rw_craprat.nritetop,'z9')||'.'||gene0002.fn_mask(rw_craprat.nrseqite,'z9')||' '||rw_craprat.dsseqite;
          pr_tab_impress_rating(vr_sqtb_imprat).tab_subtopico(vr_index_sub).tab_itens(vr_index_itens).dspesoit := to_char(rw_craprat.pesosequ,'990d00');
          pr_tab_impress_rating(vr_sqtb_imprat).tab_subtopico(vr_index_sub).tab_itens(vr_index_itens).vlrdnota := (CASE vr_vlrdnota WHEN 0 THEN NULL ELSE to_char(vr_vlrdnota,'fm999g990d00') END);
        
        END IF;

        -- Acumular valor total
        vr_vlrtotal := vr_vlrtotal + vr_vlrdnota;

      END LOOP; --> Fim calculo do Rating

      -- Obter as descricoes do risco, provisao , etc ...
      pc_descricoes_risco(pr_cdcooper             => pr_cdcooper           --> Cooperativa conectada
                         ,pr_inpessoa             => rw_crapass.inpessoa   --> Tipo de pessoa
                         ,pr_nrnotrat             => vr_vlrtotal           --> Valor baseado no calculo do rating
                         ,pr_nrnotatl             => vr_notacoop           --> Valor baseado no calculo do risco
                         ,pr_nivrisco             => 0                     --> Nivel do Risco
                         ,pr_tab_impress_risco_cl => pr_tab_impress_risco_cl --> Registro Nota e risco do cooperado naquele Rating - PROVISAOCL
                         ,pr_tab_impress_risco_tl => pr_tab_impress_risco_tl --> Registro Nota e risco do cooperado naquele Rating - PROVISAOTL
                         ,pr_des_reto             => pr_des_reto);

      -- Gravar Tabela com o operador e responsavel para assinatura
      pr_tab_impress_assina(1).dsdedata := to_char(pr_dtmvtolt,'dd') || ' de '
                                     || gene0001.vr_vet_nmmesano(to_char(pr_dtmvtolt,'mm'))
                                     || ' de ' || to_char(pr_dtmvtolt,'yyyy');
      pr_tab_impress_assina(1).nmoperad := rw_crapope.nmoperad;
      pr_tab_impress_assina(1).dsrespon := 'RESPONSAVEL';

      -- Buscar as nota do rating do contrato
      OPEN cr_crapnrc;
      FETCH cr_crapnrc
       INTO rw_crapnrc;
      --Se encontrou e � de origem
      IF cr_crapnrc%FOUND AND rw_crapnrc.flgorige = 1 THEN
        -- Fechar o cursor para nova busca
        CLOSE cr_crapnrc;
        -- Buscar o efetivo desta vez
        OPEN cr_crapnrc(pr_flefetivo => 'S');
        FETCH cr_crapnrc
         INTO rw_crapnrc;
        CLOSE cr_crapnrc;
        -- Criar o registro de efetiva��o
        vr_sqtb_efetiv := pr_tab_efetivacao.count()+1;
        pr_tab_efetivacao(vr_sqtb_efetiv).idseqmen := 2;
        pr_tab_efetivacao(vr_sqtb_efetiv).dsdefeti := 'Efetivado para a Central de Risco'
                                                   || ' o risco "' || rw_crapnrc.indrisco  || '" do contrato no '
                                                   || TRIM(gene0002.fn_mask_contrato(rw_crapnrc.nrctrrat))|| ' do '
                                                   || fn_busca_descricao_operacao(pr_tpctrrat => rw_crapnrc.tpctrrat) || ' no valor de R$ '
                                                   || to_char(fn_valor_operacao(pr_cdcooper => pr_cdcooper,pr_nrdconta => pr_nrdconta,pr_tpctrato => rw_crapnrc.tpctrrat,pr_nrctrato => rw_crapnrc.nrctrrat),'fm99g999g990d00')
                                                   || '.';
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapnrc;
      END IF;

      -- Se foi solicitado o envio de LOG
      IF pr_flgerlog = 'S' THEN
        -- Gerar LOG de envio do e-mail
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => NULL
                            ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem) --> Origem enviada
                            ,pr_dstransa => 'Gerar o arquivo para impressao do RATING'
                            ,pr_dttransa => pr_dtmvtolt
                            ,pr_flgtrans => 1 --> TRUE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;
      -- Retorno OK
      pr_des_reto := 'OK';
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
        IF vr_cdcritic IS NOT NULL THEN
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 --> Fixo
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
          -- Se foi solicitado o envio de LOG
          IF pr_flgerlog = 'S' THEN
            -- Gerar LOG de envio do e-mail
            gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                ,pr_cdoperad => pr_cdoperad
                                ,pr_dscritic => vr_dscritic
                                ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem) --> Origem enviada
                                ,pr_dstransa => 'Gerar o arquivo para impressao do RATING'
                                ,pr_dttransa => pr_dtmvtolt
                                ,pr_flgtrans => 0 --> FALSE
                                ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate,'SSSSS'))
                                ,pr_idseqttl => pr_idseqttl
                                ,pr_nmdatela => pr_nmdatela
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrdrowid => vr_nrdrowid);
          END IF;
        END IF;
      WHEN OTHERS THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        -- Montar descri��o de erro n�o tratado
        vr_dscritic := 'Erro n�o tratado na RATI0001.pc_gera_arq_impress_rating > '||sqlerrm;
        -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        -- Se foi solicitado o envio de LOG
        IF pr_flgerlog = 'S' THEN
          -- Gerar LOG de envio do e-mail
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem) --> Origem enviada
                              ,pr_dstransa => 'Gerar o arquivo para impressao do RATING'
                              ,pr_dttransa => pr_dtmvtolt
                              ,pr_flgtrans => 0 --> FALSE
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
        END IF;
    END;
  END pc_gera_arq_impress_rating;

  /* Item 3_1 (Pessoa Fisica) e  5_2 (Pessoa juridica) do Rating */
  PROCEDURE pc_nivel_comprometimento(pr_cdcooper     IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                    ,pr_cdoperad     IN crapnrc.cdoperad%TYPE --> C�digo do operador
                                    ,pr_idseqttl     IN crapttl.idseqttl%TYPE --> Sq do titular da conta
                                    ,pr_idorigem     IN pls_integer           --> Indicador da origem da chamada
                                    ,pr_nrdconta     IN crapass.nrdconta%TYPE --> Conta do associado
                                    ,pr_tpctrato     IN crapnrc.tpctrrat%TYPE --> Tipo do Rating
                                    ,pr_nrctrato     IN crapnrc.nrctrrat%TYPE --> N�mero do contrato de Rating
                                    ,pr_vet_nrctrliq IN typ_vet_nrctrliq      --> Vetor de contratos a liquidar
                                    ,pr_vlpreemp     IN crapepr.vlpreemp%TYPE --> Valor da parcela
                                    ,pr_rw_crapdat   IN btch0001.cr_crapdat%rowtype --> Calend�rio do movimento atual
                                    ,pr_flgdcalc     IN PLS_INTEGER           --> Flag para calcular sim ou n�o
                                    ,pr_inusatab     IN BOOLEAN               --> Indicador de utiliza��o da tabela de juros
                                    ,pr_vltotpre    OUT NUMBER                --> Valor calculado da presta��o
                                    ,pr_dscritic    OUT VARCHAR2) IS          --> Descri��o de erro
  BEGIN
    /* ..........................................................................

       Programa: pc_nivel_comprometimento         Antigo: b1wgen0043 --> nivel_comprometimento
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Marcos Ernani Martini
       Data    : Agosto/2014.                          Ultima Atualizacao: 19/01/2015

       Dados referentes ao programa:

       Frequencia: Sempre que chamado por outros programas.
       Objetivo  : Item 3_1 (Pessoa Fisica) e  5_2 (Pessoa juridica) do Rating

       Alteracoes: 29/08/2014 - Convers�o Progress -> Oracle - Marcos (Supero)

                   19/01/2015 - Ajuste para nao verificar a data fim quando o
                                limite de credito for cheque especial. (James)
    ............................................................................. */
    DECLARE
      -- Tratamento de poss�veis erros
      vr_exc_erro exception;
      vr_tab_erro gene0001.typ_tab_erro;
      vr_des_reto VARCHAR2(10);
      -- Variaveis do retorno da pc_calc_saldo_epr
      vr_vlsdeved NUMBER(20,8);          --> Valor de saldo devedor
      vr_valorpre NUMBER;                --> Auxiliar para soma de todas as parcelas que o usu�rio est� liquidando
      vr_qtprecal NUMBER;                --> Quantidade calculada das parcelas
      -- registro de datas
      rw_crapdat  btch0001.cr_crapdat%rowtype;

      -- Busca do total pendente dos empr�stimos BNDES ativos na conta
      CURSOR cr_soma_crapebn IS
        SELECT nvl(sum(nvl(vlparepr,0)),0) vlparepr
          FROM crapebn
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND insitctr in('N','A')
           AND vlsdeved > 0;
      -- Busca do valor da parcela do empr�stimo
      CURSOR cr_crapepr(pr_nrctrliq crapepr.nrctremp%TYPE) IS
        SELECT vlpreemp
          FROM crapepr
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctrliq;
      vr_vlpreemp crapepr.vlpreemp%TYPE;
      -- Busca valor parcela emprestimo bndes
      CURSOR cr_crapebn(pr_nrctrliq crapepr.nrctremp%TYPE) IS
        SELECT vlparepr
          FROM crapebn
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctrato;
      -- Contabilizar todos os descontos / cheque especial
      -- Sobre 12, para considerar como parcela
      CURSOR cr_craplim IS
        SELECT nvl(SUM(vllimite/12),0)
          FROM craplim
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND insitlim = 2  --> Ativo
           AND (   -- 3-Desc Tit - Verificar a data da vig�ncia
                  (tpctrlim = 3 AND dtfimvig > pr_rw_crapdat.dtmvtolt)
                OR -- 2-Desc Chq.
                  (tpctrlim = 2)
                OR -- 1-Chq Esp
                  (tpctrlim = 1)
               );
      -- Verifica��o de exist�ncia do contrato atual
      CURSOR cr_craplim_atual IS
        SELECT vllimite
          FROM craplim
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND tpctrlim = pr_tpctrato
           AND nrctrlim = pr_nrctrato
           AND insitlim <> 2; --> N�o Ativo

    BEGIN
      -- Se emprestimo/ financiamento OU se foi solicitado o c�lculo para outros casos
      IF pr_tpctrato = 90 OR pr_flgdcalc = 1 THEN
        -- Busca do total pendente dos empr�stimos BNDES ativos na conta
        -- Obs:  BNDES - nao tera tratamento ref. liquidacao de contratos inicialmente
        OPEN cr_soma_crapebn;
        FETCH cr_soma_crapebn
         INTO vr_valorpre;
        CLOSE cr_soma_crapebn;
        -- Acumular
        pr_vltotpre := NVL(vr_valorpre,0);
        -- Solu��o de contorno para usar o mesmo comportamento progres, ou seja,
        -- dtmvtopr passada por parametro nula
        rw_crapdat := pr_rw_crapdat;
        rw_crapdat.dtmvtopr := null;

        -- Trazer o valor de todas as prestacoes de emprestimo
        EMPR0001.pc_saldo_devedor_epr(pr_cdcooper => pr_cdcooper
                                     ,pr_cdagenci => 0
                                     ,pr_nrdcaixa => 0
                                     ,pr_cdoperad => pr_cdoperad
                                     ,pr_nmdatela => 'RATI0001'
                                     ,pr_idorigem => pr_idorigem
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_idseqttl => pr_idseqttl
                                     ,pr_rw_crapdat => rw_crapdat
                                     ,pr_nrctremp => 0 -- Todos os empr�stimos
                                     ,pr_cdprogra => ''
                                     ,pr_inusatab => pr_inusatab
                                     ,pr_flgerlog => 'N'
                                     ,pr_vlsdeved => vr_vlsdeved
                                     ,pr_vltotpre => vr_valorpre
                                     ,pr_qtprecal => vr_qtprecal
                                     ,pr_des_reto => vr_des_reto
                                     ,pr_tab_erro => vr_tab_erro);
        -- Se retornou erro
        IF vr_des_reto <> 'OK' THEN
          -- Buscar da tabela de erro
          IF vr_tab_erro.count > 0 THEN
            pr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
          ELSE
            pr_dscritic := 'Erro na pck empr0001.';
          END IF;
          -- Gerar exce��o
          RAISE vr_exc_erro;
        ELSE
          -- Acumular valor calculado
          pr_vltotpre := nvl(pr_vltotpre,0) + nvl(vr_valorpre,0);
        END IF;
      END IF;
      -- Regras espec�ficas
      -- Se emprestimo/ financiamento
      IF pr_tpctrato = 90 THEN
        -- Reiniciar tempor�ria
        vr_valorpre := 0;
        -- Somar todas as parcelas que esta liquidando
        FOR vr_contador IN 1..10 LOOP
          -- Se foi enviado
          IF pr_vet_nrctrliq(vr_contador) <> 0 THEN
            -- Somar valor da parcela do empr�stimo
            vr_vlpreemp := 0;
            OPEN cr_crapepr(pr_vet_nrctrliq(vr_contador));
            FETCH cr_crapepr
             INTO vr_vlpreemp;
            CLOSE cr_crapepr;
            -- Acumular
            vr_valorpre := vr_valorpre + vr_vlpreemp;
          END IF;
        END LOOP;
        -- Restar as parcelas pois estes emprestimos estao sendo liquidados
        pr_vltotpre := pr_vltotpre - vr_valorpre;
        -- Testa exist�ncia contrato EPR
        OPEN cr_crapepr(pr_nrctrato);
        FETCH cr_crapepr
         INTO vr_vlpreemp;
        -- Testa exist�ncia contrato BNDES
        OPEN cr_crapebn(pr_nrctrato);
        FETCH cr_crapebn
         INTO vr_vlpreemp;
        -- Se n�o existe nas duas tabelas
        IF cr_crapepr%NOTFOUND AND cr_crapebn%NOTFOUND THEN
          -- Se esta efetivando ele ja considera a parcela atual
          pr_vltotpre := pr_vltotpre + pr_vlpreemp;
        END IF;
        -- Sen�o, apenas fechar os cursores
        CLOSE cr_crapepr;
        CLOSE cr_crapebn;
      ELSE
        -- Contabilizar todos os descontos / cheque especial
        -- Obs: Somente se n�o foi solicitado o c�lculo
        IF pr_flgdcalc = 0 THEN
          -- Sobre 12, para considerar como parcela
          OPEN cr_craplim;
          FETCH cr_craplim
           INTO vr_valorpre;
          CLOSE cr_craplim;
          -- Acumular
          pr_vltotpre := pr_vltotpre + vr_valorpre;
          -- Se esta efetivando ele ja considera a parcela atual
          OPEN cr_craplim_atual;
          FETCH cr_craplim_atual
           INTO vr_valorpre;
          -- Se encontrou
          IF cr_craplim_atual%FOUND THEN
            -- Somar contrato atual
            pr_vltotpre := nvl(pr_vltotpre,0) + (nvl(pr_vlpreemp,0) / 12);
          END IF;
          CLOSE cr_craplim_atual;
        END IF;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        NULL; --> Apenas desviar o fluxo e sair
      WHEN OTHERS THEN
        -- Montar descri��o de erro n�o tratado
        pr_dscritic := 'Erro n�o tratado na RATI0001.pc_nivel_comprometimento > '||sqlerrm;
    END;
  END pc_nivel_comprometimento;

  /*****************************************************************************
    Verifica o historico do cooperado referente a estouros.
    Item 1_5 de pessoa fisica e 6_4 de pessoa juridica.
  *****************************************************************************/
  PROCEDURE pc_historico_cooperado(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo Cooperativa
                                  ,pr_cdoperad IN crapnrc.cdoperad%TYPE --> Codigo Operador
                                  ,pr_dtmvtolt IN DATE                  --> Data do movimento
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE --> Numero da Conta
                                  ,pr_idorigem IN INTEGER               --> Identificador Origem
                                  ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Sequencial do Titular
                                  ,pr_nrseqite OUT NUMBER        --> sequencial do item do risco
                                  ,pr_dscritic OUT VARCHAR2) IS   --> Descricao do erro

  /* ..........................................................................

     Programa: pc_historico_cooperado         Antigo: b1wgen0043.p/historico_cooperado
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Odirlei Busana - AMcom
     Data    : Agosto/2014.                          Ultima Atualizacao: 06/08/2015

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  :  Verifica o historico do cooperado referente a estouros.
                  Item 1_5 de pessoa fisica e 6_4 de pessoa juridica.

     Alteracoes: 29/08/2014 - Convers�o Progress -> Oracle - Odirlei (AMcom)
     
                 06/08/2015 - Alterado procedimento pc_historico_cooperado para melhorias de performace
                              verificado se a conta possuia contrato de limite de credito no periodo,
                              caso nao tenha, nao precisa verificar dias que usa o limite de credito SD281898 (Odirlei-Amcom)

  ............................................................................. */
  ---------------- CURSORES ----------------
    -- Buscar saldos diarios dos associados
    CURSOR cr_crapsda (pr_cdcooper crapsda.cdcooper%type,
                       pr_nrdconta crapsda.nrdconta%type,
                       pr_dtiniest crapsda.dtmvtolt%type) IS
      SELECT vlsddisp,
             vllimcre
        FROM crapsda
       WHERE crapsda.cdcooper = pr_cdcooper
         AND crapsda.nrdconta = pr_nrdconta
         AND crapsda.dtmvtolt >= pr_dtiniest         
        ORDER BY crapsda.dtmvtolt DESC;

    -- Buscar Cadastro de controle dos saldos negativos e devolucoes de cheques.
    CURSOR cr_crapneg (pr_cdcooper crapneg.cdcooper%type,
                       pr_nrdconta crapneg.nrdconta%type,
                       pr_dtmvtolt crapneg.dtiniest%type) IS
      SELECT 1
        FROM crapneg
       WHERE crapneg.cdcooper = pr_cdcooper
         AND crapneg.cdhisest = 1
         AND crapneg.nrdconta = pr_nrdconta
         AND crapneg.dtiniest >= add_months(pr_dtmvtolt,-12)
         AND crapneg.cdobserv in (11,12)
         -- buscar apenas 1 registro
         AND rownum < 2;
    rw_crapneg cr_crapneg%rowtype;
    
    -- Cursor para verificar se o cooperado teve linha de credito no periodo
    CURSOR cr_craplim (pr_cdcooper craplim.cdcooper%TYPE,
                       pr_nrdconta craplim.nrdconta%TYPE,
                       pr_dtiniest craplim.dtinivig%TYPE) IS
      SELECT 1 
        FROM craplim lim
       WHERE lim.cdcooper = pr_cdcooper
         AND lim.nrdconta = pr_nrdconta
         AND lim.insitlim IN (2,3)
         AND--(lim.dtinivig >= pr_dtiniest OR 
             nvl(lim.dtfimvig,pr_dtiniest) >= pr_dtiniest--)
              ;
    rw_craplim cr_craplim%ROWTYPE;
    
    
  -------------- VARIAVEIS -----------------
    vr_tab_estouros risc0001.typ_tab_estouros;

    -- Descri��o e c�digo da critica
    vr_dscritic VARCHAR2(4000);
    -- Exce��o de sa�da
    vr_exc_erro EXCEPTION;
    -- dia inicial de estorno
    vr_dtiniest DATE;
    -- contar dias
    vr_qtestour INTEGER := 0;
    vr_qtdiaatr INTEGER := 0;
    vr_qtdiaat2 INTEGER := 0;
    vr_qtdiasav INTEGER := 0;

  BEGIN
    /* Obter as informa�es de estouro do cooperado */
    RISC0001.pc_lista_estouros( pr_cdcooper      => pr_cdcooper     --> Codigo Cooperativa
                               ,pr_cdoperad      => pr_cdoperad      --> Operador conectado
                               ,pr_nrdconta      => pr_nrdconta     --> Numero da Conta
                               ,pr_idorigem      => pr_idorigem     --> Identificador Origem
                               ,pr_idseqttl      => pr_idseqttl     --> Sequencial do Titular
                               ,pr_nmdatela      => 'RATI0001'      --> Nome da tela
                               ,pr_dtmvtolt      => pr_dtmvtolt     --> Data do movimento
                               ,pr_tab_estouros  => vr_tab_estouros --> Informa��es de estouro na conta
                               ,pr_dscritic      => vr_dscritic);   --> Retorno de erro

    -- verificar se retornou critica
    IF vr_dscritic is not null THEN
      raise vr_exc_erro;
    END IF;

    /* Data do inicio do estouro a partir de um ano atras */
    vr_dtiniest := add_months(pr_dtmvtolt, -12);

    -- varrer temptable de estouro
    IF vr_tab_estouros.count > 0 THEN
      FOR I IN vr_tab_estouros.FIRST..vr_tab_estouros.LAST LOOP
        IF vr_tab_estouros(I).dtiniest >= vr_dtiniest AND
           vr_tab_estouros(I).cdhisest  = 'Estouro' THEN

          vr_qtestour := nvl(vr_qtestour,0) + 1;       /* Ocorrencias */
           /* Maior qtd de dias*/
          vr_qtdiaatr := greatest( vr_tab_estouros(I).qtdiaest,vr_qtdiaatr);

        END IF;
      END LOOP;
    END IF;
    
    -- Verificar se cooperado possui contrato de
    -- limite de credito no periodo
    OPEN cr_craplim( pr_cdcooper => pr_cdcooper,
                     pr_nrdconta => pr_nrdconta,
                     pr_dtiniest => vr_dtiniest);
    FETCH cr_craplim INTO rw_craplim;
    
    -- se n�o possuir contrato de limite de credito, n�o precisa
    -- verificar a sda
    IF cr_craplim%NOTFOUND THEN                 
      CLOSE cr_craplim;
    ELSE
      CLOSE cr_craplim;                  
      -- Varrer tabela de saldo do dia
      FOR rw_crapsda IN cr_crapsda ( pr_cdcooper => pr_cdcooper,
                                     pr_nrdconta => pr_nrdconta,
                                     pr_dtiniest => vr_dtiniest) LOOP

        -- se o saldo for negativo e o maior que o limite de credito
        IF rw_crapsda.vlsddisp < 0  AND
           rw_crapsda.vlsddisp >= (rw_crapsda.vllimcre * -1)  THEN
          vr_qtdiaat2 := nvl(vr_qtdiaat2,0) + 1;
        ELSE
          -- armazenar maior data
          IF nvl(vr_qtdiaat2,0) > nvl(vr_qtdiasav,0) THEN
            vr_qtdiasav := nvl(vr_qtdiaat2,0);
          END IF;
          vr_qtdiaat2 := 0;
        END IF;

      END LOOP;
    END IF; -- FIM IF cr_craplim%NOTFOUND 

    IF vr_qtdiasav = 0  THEN
      vr_qtdiasav := vr_qtdiaat2;
    END IF;

    IF vr_qtdiaat2 > vr_qtdiasav THEN
      vr_qtdiasav := vr_qtdiaat2;
    END IF;
    
    IF vr_qtestour <= 24    AND   -- Ate 24 estouros
       vr_qtdiaatr <= 30    AND   -- com no maximo 30 dias
       vr_qtdiasav <= 124   THEN  -- Chq. esp ate 124 dias seguidos
      pr_nrseqite := 1;

    ELSIF vr_qtdiaatr <= 30    AND  -- No maximo 30 dias
      vr_qtdiasav <= 249   THEN     -- 249 dias de cheque especial
      pr_nrseqite := 2;
    ELSE
      pr_nrseqite := 3;
    END IF;

    IF pr_nrseqite <> 3 THEN

      -- verificar saldos negativos e devolucoes de cheques
      OPEN cr_crapneg (pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => pr_nrdconta,
                       pr_dtmvtolt => pr_dtmvtolt);
      FETCH cr_crapneg INTO rw_crapneg;
      -- se existir
      IF cr_crapneg%FOUND THEN
        pr_nrseqite := 4;
      END IF;
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na rotina pc_historico_cooperado: '||SQLerrm;
  END pc_historico_cooperado;

  /* Tratamento das criticas para o calculo de pessoa juridica.
     Foi desenvolvido para mostrar todas as criticas do calculo. */
  PROCEDURE pc_criticas_rating_jur(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                  ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Conta do associado
                                  ,pr_tpctrrat  IN crapnrc.tpctrrat%TYPE --> Tipo do Rating
                                  ,pr_nrctrrat  IN crapnrc.nrctrrat%TYPE --> N�mero do contrato de Rating
                                  ,pr_cdagenci  IN crapass.cdagenci%TYPE --> C�digo da ag�ncia
                                  ,pr_nrdcaixa  IN craperr.nrdcaixa%TYPE --> N�mero do caixa
                                  ,pr_tab_erro OUT GENE0001.typ_tab_erro --> Tabela de retorno de erro
                                  ,pr_des_reto OUT VARCHAR2) IS          --> Retorno OK/NOK
  BEGIN
    /* ..........................................................................

       Programa: pc_criticas_rating_jur         Antigo: b1wgen0043 --> criticas_rating_jur
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Marcos Ernani Martini
       Data    : Agosto/2014.                          Ultima Atualizacao: 10/05/2016

       Dados referentes ao programa:

       Frequencia: Sempre que chamado por outros programas.
       Objetivo  : Tratamento das criticas para o calculo de pessoa juridica.
                   Foi desenvolvido para mostrar todas as criticas do calculo.

       Alteracoes: 29/08/2014 - Convers�o Progress -> Oracle - Marcos (Supero)
       
                   03/07/2015 - Projeto 217 Reformula�ao Cadastral IPP Entrada
                                Ajuste nos codigos de natureza juridica para o
                                existente na receita federal (Tiago Castro - RKAM)

                   10/05/2016 - Ajuste para utitlizar rowtype locais 
								(Andrei  - RKAM).
       ............................................................................. */
    DECLARE
      -- Tratamento de poss�veis erros
      vr_dscritic VARCHAR2(4000);
      vr_tab_erro GENE0001.typ_tab_erro;
      -- Sequencia para gera��o dos erros
      vr_nrsequen PLS_INTEGER := 0;
      -- Flag para indicar problemas cadastrais (830)
      vr_flprbcad BOOLEAN := FALSE;
      -- Busca do cadastro da pessoa juridica
      CURSOR cr_crapjur IS
        SELECT cdseteco
              ,natjurid
          FROM crapjur
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      rw_crapjur cr_crapjur%ROWTYPE;
      -- Busca dos dados cadastrais PJ
      CURSOR cr_crapjfn IS
        SELECT 1
          FROM crapjfn
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      vr_ind_exis NUMBER;
      -- Guardar a data de admiss�o e existencia da crapavt
      vr_dtadmsoc DATE;
      vr_flexiavt BOOLEAN := FALSE;
      -- Guardar faturamento m�dio mensal
      vr_vlmedfat NUMBER;
      
      rw_crawepr3 cr_crawepr%ROWTYPE;
      rw_crapprp2 cr_crapprp%ROWTYPE;
      rw_craplcr1 cr_craplcr%rowtype;
      rw_craplim2 cr_craplim%ROWTYPE;
      
    BEGIN
      -- Busca do Registro da empresa
      OPEN cr_crapjur;
      FETCH cr_crapjur
       INTO rw_crapjur;
      -- Se n�o houver gerar critica 331
      IF cr_crapjur%NOTFOUND THEN
        CLOSE cr_crapjur;
        -- Gerar erro 331
        vr_nrsequen := vr_nrsequen + 1;
        vr_dscritic := null;
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => vr_nrsequen
                             ,pr_cdcritic => 331
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
      ELSE
        CLOSE cr_crapjur;
        -- Se n�o houver setor econ�mico
        IF rw_crapjur.cdseteco = 0 THEN
          -- Gerar erro 879
          vr_nrsequen := vr_nrsequen + 1;
          vr_dscritic := null;
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => vr_nrsequen
                               ,pr_cdcritic => 879
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
          -- E tamb�m a 830
          vr_nrsequen := vr_nrsequen + 1;
          vr_dscritic := null;
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => vr_nrsequen
                               ,pr_cdcritic => 830
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);

          -- gravar a flag do erro 830 para evitar grava��o duplicada deste
          vr_flprbcad := TRUE;
        END IF;
      END IF;
      -- TEstar existencia dos dados financeiros PJ
      OPEN cr_crapjfn;
      FETCH cr_crapjfn
       INTO vr_ind_exis;
      -- Se n�o encontrar
      IF cr_crapjfn%NOTFOUND THEN
        CLOSE cr_crapjfn;
        -- Gerar erro 861
        vr_nrsequen := vr_nrsequen + 1;
        vr_dscritic := null;
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => vr_nrsequen
                             ,pr_cdcritic => 861
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        -- Se ainda n�o foi enviada a 830
        IF NOT vr_flprbcad THEN
          -- E tamb�m a 830
          vr_nrsequen := vr_nrsequen + 1;
          vr_dscritic := null;
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => vr_nrsequen
                               ,pr_cdcritic => 830
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);

          -- gravar a flag do erro 830 para evitar grava��o duplicada deste
          vr_flprbcad := TRUE;
        END IF;
      ELSE
        CLOSE cr_crapjfn;
      END IF;
      -- Verificar se existem Socios cadastrados
      -- Esta busca trar� os mais antigos primeiro
      OPEN cr_crapavt(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      LOOP
        FETCH cr_crapavt
         INTO vr_dtadmsoc;
        -- Sair quando n�o existir mais registros
        EXIT WHEN cr_crapavt%NOTFOUND;
        -- Indicar que encontrou pelo menos um s�cio
        vr_flexiavt := TRUE;
        -- Sair tamb�m se j� encontrou aquele de admiss�o mais antiga
        EXIT WHEN vr_dtadmsoc IS NOT NULL;
      END LOOP;
      CLOSE cr_crapavt;
      -- Somente em naturezas espec�ficas
      IF rw_crapjur.natjurid IN(2062,2135,4081,2089) THEN
        -- Se n�o encontrou s�cio
        IF NOT vr_flexiavt THEN
          -- Gerar erro 917
          vr_nrsequen := vr_nrsequen + 1;
          vr_dscritic := null;
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => vr_nrsequen
                               ,pr_cdcritic => 917
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
          -- Se ainda n�o foi enviada a 830
          IF NOT vr_flprbcad THEN
            -- E tamb�m a 830
            vr_nrsequen := vr_nrsequen + 1;
            vr_dscritic := null;
            gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                 ,pr_cdagenci => pr_cdagenci
                                 ,pr_nrdcaixa => pr_nrdcaixa
                                 ,pr_nrsequen => vr_nrsequen
                                 ,pr_cdcritic => 830
                                 ,pr_dscritic => vr_dscritic
                                 ,pr_tab_erro => pr_tab_erro);

            -- gravar a flag do erro 830 para evitar grava��o duplicada deste
            vr_flprbcad := TRUE;
          END IF;
        END IF;
        -- Se n�o encontrou data de admiss�o do s�cio mais antigo
        IF vr_dtadmsoc IS NULL THEN
          -- Gerar erro 923
          vr_nrsequen := vr_nrsequen + 1;
          vr_dscritic := null;
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => vr_nrsequen
                               ,pr_cdcritic => 923
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
          -- Se ainda n�o foi enviada a 830
          IF NOT vr_flprbcad THEN
            -- E tamb�m a 830
            vr_nrsequen := vr_nrsequen + 1;
            vr_dscritic := null;
            gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                 ,pr_cdagenci => pr_cdagenci
                                 ,pr_nrdcaixa => pr_nrdcaixa
                                 ,pr_nrsequen => vr_nrsequen
                                 ,pr_cdcritic => 830
                                 ,pr_dscritic => vr_dscritic
                                 ,pr_tab_erro => pr_tab_erro);

            -- gravar a flag do erro 830 para evitar grava��o duplicada deste
            vr_flprbcad := TRUE;
          END IF;
        END IF;
      END IF;
      -- Buscar faturamento m�dio mensal
      cada0001.pc_calcula_faturamento(pr_cdcooper => pr_cdcooper
                                     ,pr_cdagenci => pr_cdagenci
                                     ,pr_nrdcaixa => pr_nrdcaixa
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_vlmedfat => vr_vlmedfat
                                     ,pr_tab_erro => vr_tab_erro
                                     ,pr_des_reto => pr_des_reto);
      -- Se retornou erro
      -- Progress n�o trata retorno dos erro
      /*IF pr_des_reto = 'NOK' THEN
        -- Varrer a tabela de erro para copiar para a atual
        FOR vr_ind IN vr_tab_erro.first..vr_tab_erro.last LOOP
          pr_tab_erro(pr_tab_erro.last+1) := vr_tab_erro(vr_ind);
        END LOOP;
      END IF;*/

      -- Se n�o houve faturamento
      IF nvl(vr_vlmedfat,0) = 0 THEN
        -- Gerar erro 924
        vr_nrsequen := vr_nrsequen + 1;
        vr_dscritic := null;
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => vr_nrsequen
                             ,pr_cdcritic => 924
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        -- Se ainda n�o foi enviada a 830
        IF NOT vr_flprbcad THEN
          -- E tamb�m a 830
          vr_nrsequen := vr_nrsequen + 1;
          vr_dscritic := null;
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => vr_nrsequen
                               ,pr_cdcritic => 830
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);

          -- gravar a flag do erro 830 para evitar grava��o duplicada deste
          vr_flprbcad := TRUE;
        END IF;
      END IF;
      -- Nao validar para calculo do Risco cooperado
      IF pr_tpctrrat <> 0 AND pr_nrctrrat <> 0  THEN
        -- Para empr�stimos / Financiamentos
        IF pr_tpctrrat = 90 THEN
          -- Testar se existe informa��o complementar do empr�stimo
          OPEN cr_crawepr(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_nrctrato => pr_nrctrrat);
          FETCH cr_crawepr
           INTO rw_crawepr3;
          -- Se existir
          IF cr_crawepr%FOUND THEN
            CLOSE cr_crawepr;
            -- Ler Cadastro de Linhas de Credito
            OPEN cr_craplcr(pr_cdcooper => pr_cdcooper
                           ,pr_cdlcremp => rw_crawepr3.cdlcremp);
            FETCH cr_craplcr
             INTO rw_craplcr1;
            -- Se n�o encontrar
            IF cr_craplcr%NOTFOUND THEN
              CLOSE cr_craplcr;
              -- Gerar critica 363
              vr_nrsequen := vr_nrsequen + 1;
              vr_dscritic := null;
              gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                   ,pr_cdagenci => pr_cdagenci
                                   ,pr_nrdcaixa => pr_nrdcaixa
                                   ,pr_nrsequen => vr_nrsequen
                                   ,pr_cdcritic => 363
                                   ,pr_dscritic => vr_dscritic
                                   ,pr_tab_erro => pr_tab_erro);
            ELSE
              CLOSE cr_craplcr;
            END IF;
          ELSE
            CLOSE cr_crawepr;
            -- Testar se existe a informa��o da proposta do empr�stimo
            OPEN cr_crapprp(pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_tpctrato => pr_tpctrrat
                           ,pr_nrctrato => pr_nrctrrat);
            FETCH cr_crapprp
             INTO rw_crapprp2;
            -- Se n�o encontrar
            IF cr_crapprp%NOTFOUND THEN
              CLOSE cr_crapprp;
              -- Gerar critica 356
              vr_nrsequen := vr_nrsequen + 1;
              vr_dscritic := null;
              gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                   ,pr_cdagenci => pr_cdagenci
                                   ,pr_nrdcaixa => pr_nrdcaixa
                                   ,pr_nrsequen => vr_nrsequen
                                   ,pr_cdcritic => 356
                                   ,pr_dscritic => vr_dscritic
                                   ,pr_tab_erro => pr_tab_erro);
            ELSE
              CLOSE cr_crapprp;
            END IF;
          END IF;
        ELSE
          -- Busca do valor da tabela de limites
          OPEN cr_craplim(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_tpctrato => pr_tpctrrat
                         ,pr_nrctrato => pr_nrctrrat);
          FETCH cr_craplim
           INTO rw_craplim2;
          -- Se n�o encontrar
          IF cr_craplim%NOTFOUND THEN
            CLOSE cr_craplim;
            -- Gerar erro 484
            vr_nrsequen := vr_nrsequen + 1;
            vr_dscritic := null;
            gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                 ,pr_cdagenci => pr_cdagenci
                                 ,pr_nrdcaixa => pr_nrdcaixa
                                 ,pr_nrsequen => vr_nrsequen
                                 ,pr_cdcritic => 484
                                 ,pr_dscritic => vr_dscritic
                                 ,pr_tab_erro => pr_tab_erro);
          ELSE
            CLOSE cr_craplim;
          END IF;
        END IF;
      END IF;
      -- Se n�o gerou nenhum critica
      IF pr_tab_erro.count = 0 THEN
        pr_des_reto := 'OK';
      ELSE
        pr_des_reto := 'NOK';
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        -- Montar descri��o de erro n�o tratado
        vr_dscritic := 'Erro n�o tratado na RATI0001.pc_criticas_rating_jur > '||sqlerrm;
        -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
  END pc_criticas_rating_jur;

  PROCEDURE pc_carrega_temp_qtdiaatr(pr_dtmvtolt IN DATE) IS

    vr_idx VARCHAR2(50);
  BEGIN

    -- varrer risco para buscar dias de atraso
    FOR rw_crapris IN cr_crapris_all(pr_dtmvtolt => pr_dtmvtolt) LOOP
      -- definir index
      vr_idx := lpad(rw_crapris.cdcooper,10,'0')||lpad(rw_crapris.nrdconta,10,'0');
      -- carregar temptable
      vr_tab_crapris_qtdiaatr(vr_idx).cdcooper := rw_crapris.cdcooper;
      vr_tab_crapris_qtdiaatr(vr_idx).nrdconta := rw_crapris.nrdconta;
      vr_tab_crapris_qtdiaatr(vr_idx).qtdiaatr := rw_crapris.qtdiaatr;
    END LOOP;

  END;

  /*****************************************************************************
   Procedure para calcular o risco cooperado para PJ.
  *****************************************************************************/
  PROCEDURE pc_risco_cooperado_pj (pr_flgdcalc    IN INTEGER                     --> Indicador de calculo
                                  ,pr_cdcooper    IN crapcop.cdcooper%TYPE       --> Codigo Cooperativa
                                  ,pr_cdagenci    IN INTEGER                     --> Codigo Agencia
                                  ,pr_nrdcaixa    IN craperr.nrdcaixa%TYPE       --> Numero Caixa
                                  ,pr_cdoperad    IN crapnrc.cdoperad%TYPE       --> Codigo Operador
                                  ,pr_idorigem    IN INTEGER                     --> Identificador Origem
                                  ,pr_nrdconta    IN crapass.nrdconta%TYPE       --> Numero da Conta
                                  ,pr_idseqttl    IN crapttl.idseqttl%TYPE       --> Sequencial do Titular
                                  ,pr_rw_crapdat  IN btch0001.rw_crapdat%TYPE    --> Vetor com dados de par�metro (CRAPDAT)
                                  ,pr_tpctrato    IN crapnrc.tpctrrat%TYPE       --> Tipo Contrato Rating
                                  ,pr_nrctrato    IN crapnrc.nrctrrat%TYPE       --> Numero Contrato Rating
                                  ,pr_inusatab    IN BOOLEAN                     --> Indicador de utiliza��o da tabela de juros
                                  ,pr_flgcriar    IN INTEGER                     --> Indicado se deve criar o rating
                                  ,pr_flgttris    IN BOOLEAN                     --> Indicado se deve carregar toda a crapris
                                  ,pr_tab_crapras IN OUT typ_tab_crapras         --> Tabela com os registros a serem processados
                                  ,pr_notacoop   OUT NUMBER                      --> Retorna a nota da classifica��o
                                  ,pr_clascoop   OUT VARCHAR2                    --> retorna classifica��o
                                  ,pr_tab_erro   OUT GENE0001.typ_tab_erro       --> Tabela de retorno de erro
                                  ,pr_des_reto   OUT VARCHAR2                    --> Ind. de retorno OK/NOK
                                  ) IS

  /* ..........................................................................

     Programa: pc_risco_cooperado_pj         Antigo: b1wgen0043.p/risco_cooperado_pj
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Marcos Martini - Supero
     Data    : Setembro/2014.                         Ultima Atualizacao: 10/05/2016

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  : Procedure para calcular o risco cooperado para PF.

     Alteracoes: 01/09/2014 - Convers�o Progress -> Oracle - Marcos (Supero)

                 05/11/2014 - Ajuste na procedure para carregar a crapris
                              com a conta a qual esta sendo passada ou
                              tudo na temp table. (Jaison)
                              
                 03/07/2015 - Projeto 217 Reformula�ao Cadastral IPP Entrada
                              Ajuste nos codigos de natureza juridica para o
                              existente na receita federal. (Tiago Castro - RKAM)

		             10/05/2016 - Ajuste para iniciar corretamente a pltable
							                (Andrei - RKAM).
                 
                 25/10/2016 - Ajuste no calculo da quantidade de anos, permitindo
                              duas posi��es decimais. (Kelvin)
                
  ............................................................................. */
  ---------------- CURSORES ----------------

    -- Busca do cadastro da pessoa juridica
    CURSOR cr_crapjur IS
      SELECT dtiniatv
            ,nrinfcad
            ,cdseteco
            ,natjurid
            ,nrpatlvr
            ,nrperger
        FROM crapjur
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta;
    rw_crapjur cr_crapjur%ROWTYPE;

    -- Busca dos dados cadastrais PJ
    CURSOR cr_crapjfn IS
      SELECT perfatcl
        FROM crapjfn
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta;
    rw_crapjfn cr_crapjfn%ROWTYPE;

    -- Valores das notas PJ
    vr_vet_nota_001 typ_vet_nota4 := typ_vet_nota4(1,3,5,6);
    vr_vet_nota_002 typ_vet_nota4 := typ_vet_nota4(1,5,9,9);
    vr_vet_nota_003 typ_vet_nota4 := typ_vet_nota4(2.5,5,7.5,12.5);
    vr_vet_nota_004 typ_vet_nota5 := typ_vet_nota5(2.5,5,10,15,17.5);
    vr_vet_nota_005 typ_vet_nota4 := typ_vet_nota4(1,2,4,6);
    vr_vet_nota_006 typ_vet_nota4 := typ_vet_nota4(0.5,1,1.5,2);
    vr_vet_nota_007 typ_vet_nota4 := typ_vet_nota4(0.5,1.5,2.5,3);
    vr_vet_nota_008 typ_vet_nota4 := typ_vet_nota4(4.5,7.5,9,10.5);
    vr_vet_nota_009 typ_vet_nota5 := typ_vet_nota5(1,2,3,4,5);
    vr_vet_nota_010 typ_vet_nota3 := typ_vet_nota3(2,4,6);
    vr_vet_nota_011 typ_vet_nota4 := typ_vet_nota4(1,3,5,9);

    --------------- VARIAVEIS ----------------
    -- Descri��o e c�digo da critica
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    -- Exce��o de sa�da
    vr_exc_erro EXCEPTION;
    -- Indicador se encontrou registro
    vr_fcrawepr  BOOLEAN := FALSE;
    vr_fcrapprp  BOOLEAN := FALSE;
    vr_fcraplim  BOOLEAN := FALSE;
    vr_fcrapjfn  BOOLEAN := FALSE;
    -- Tempo de opera��o da empresa no mercado
    vr_nranoope NUMBER(6,2);
    vr_nrseqite PLS_INTEGER;
    -- Valor da nota
    vr_vldanota  NUMBER := 0;
    -- Pior pontualidade no ultimo ano
    vr_qtdiaatr NUMBER;
    -- Guardar a data de admiss�o do socio mais antigo E tempo em anos da sociedade
    vr_dtadmsoc DATE;
    vr_qtanosoc NUMBER;
    -- Lista de contratos a liquidar
    vr_dsliquid VARCHAR2(4000);
    -- Valor utilizado no endividamento
    vr_vlutiliz NUMBER;
    -- Tabela de central de risco
    vr_tab_central_risco risc0001.typ_reg_central_risco;
    -- Indice para retorno da posi��o na tt de central de risco
    vr_index_cr PLS_INTEGER;
    -- Guardar faturamento m�dio mensal
    vr_vlmedfat NUMBER;
    -- Valor endividamento
    vr_vlendivi NUMBER;
    -- Valor da presta��o
    vr_vlpresta NUMBER;
    -- Vetor de contratos a liquidar
    vr_vet_nrctrliq typ_vet_nrctrliq := typ_vet_nrctrliq(0,0,0,0,0,0,0,0,0,0);
    -- Valor total de presta��o
    vr_vltotpre NUMBER;
    vr_idx      VARCHAR2(50);
    vr_cdcooper crapass.cdcooper%TYPE;
    vr_nrdconta crapass.nrdconta%TYPE;

    rw_crawepr4 cr_crawepr%ROWTYPE;
    rw_crapepr1 cr_crapepr%ROWTYPE;
    rw_crapprp3 cr_crapprp%ROWTYPE;
    rw_craplcr2 cr_craplcr%ROWTYPE;
    rw_craplim3 cr_craplim%ROWTYPE;
    rw_crapnrc1 cr_crapnrc%ROWTYPE;

 BEGIN

    -- Todas as criticas do calculo (juridica) estao aqui
    pc_criticas_rating_jur (pr_cdcooper => pr_cdcooper   --> Codigo Cooperativa
                           ,pr_nrdconta => pr_nrdconta   --> Numero da Conta
                           ,pr_tpctrrat => pr_tpctrato   --> Tipo Contrato Rating
                           ,pr_nrctrrat => pr_nrctrato   --> Numero Contrato Rating
                           ,pr_cdagenci => pr_cdagenci   --> Codigo Agencia
                           ,pr_nrdcaixa => pr_nrdcaixa   --> Numero Caixa
                           ,pr_tab_erro => pr_tab_erro   --> Tabela de retorno de erro
                           ,pr_des_reto => pr_des_reto); --> Ind. de retorno OK/NOK
    -- Se retornou critica, abortar rotina
    IF pr_des_reto <> 'OK' THEN
      RETURN;
    END IF;

    -- Busca registro da empresa
    OPEN cr_crapjur;
    FETCH cr_crapjur
     INTO rw_crapjur;
    CLOSE cr_crapjur;

    -- Busca das informa��es cadastrais da PJ
    OPEN cr_crapjfn;
    FETCH cr_crapjfn
     INTO rw_crapjfn;
    vr_fcrapjfn := cr_crapjfn%FOUND;
    CLOSE cr_crapjfn;

    -- Para Risco Cooperado o calculo eh diferenciado
    IF pr_tpctrato <> 0 AND pr_nrctrato <> 0  THEN
      -- Emprestimo/Financiamento
      IF pr_tpctrato = 90 THEN
        -- Ler informa��es da proposta do emprestimo
        OPEN cr_crawepr(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrctrato => pr_nrctrato);
        FETCH cr_crawepr
         INTO rw_crawepr4;
        -- Se localizou
        IF cr_crawepr%FOUND THEN
          vr_fcrawepr := TRUE;
          -- Ler Cadastro de Linhas de Credito
          OPEN cr_craplcr(pr_cdcooper => pr_cdcooper,
                          pr_cdlcremp => rw_crawepr4.cdlcremp);
          FETCH cr_craplcr
           INTO rw_craplcr2;
          CLOSE cr_craplcr;
        END IF;
        CLOSE cr_crawepr;
        --Ler Cadastros de propostas.
        OPEN cr_crapprp(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_tpctrato => pr_tpctrato
                       ,pr_nrctrato => pr_nrctrato);
        FETCH cr_crapprp
         INTO rw_crapprp3;
        vr_fcrapprp := cr_crapprp%found;
        CLOSE cr_crapprp;
      ELSE
        -- Ler Contratos de Limite de credito
        OPEN cr_craplim(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_tpctrato => pr_tpctrato
                       ,pr_nrctrato => pr_nrctrato);
        FETCH cr_craplim
         INTO rw_craplim3;
        vr_fcraplim := cr_craplim%found;
        CLOSE cr_craplim;
      END IF;
    END IF;

    /*************************************************************************
       Item 6_1 - Tempo de operacao no mercado
    *************************************************************************/

    -- Calcular a qtd de anos do associado na cooperativa
    vr_nranoope := trunc(((pr_rw_crapdat.dtmvtolt - rw_crapjur.dtiniatv) / 365),2);
    -- Gerar valor do item conforme o periodo de opera��o
    IF vr_nranoope > 8    THEN
      vr_nrseqite := 1;
    ELSIF vr_nranoope  >= 5  THEN
      vr_nrseqite := 2;
    ELSIF vr_nranoope  >= 2  THEN
      vr_nrseqite := 3;
    ELSE
      vr_nrseqite := 4;
    END IF;

    -- Se solicitado o calculo
    IF pr_flgdcalc = 1 THEN
      vr_vldanota := vr_vldanota + vr_vet_nota_001(vr_nrseqite);
    ELSE
      -- Gravar itens do rating na crapras
      pc_grava_item_rating (pr_cdcooper    => pr_cdcooper             --Codigo Cooperativa
                           ,pr_nrdconta    => pr_nrdconta             --Numero da Conta
                           ,pr_tpctrato    => pr_tpctrato             --Tipo Contrato Rating
                           ,pr_nrctrato    => pr_nrctrato             --Numero Contrato Rating
                           ,pr_nrtopico    => 3                       --Numero do topico
                           ,pr_nritetop    => 1                       --Numero Contrato Rating
                           ,pr_nrseqite    => vr_nrseqite             --Numero Contrato Rating
                           ,pr_flgcriar    => pr_flgcriar             -- Indicado se deve criar o rating
                           ,pr_tab_crapras => pr_tab_crapras       --
                           ,pr_dscritic    => vr_dscritic);        -- Descricao do erro
      -- Se retornou erro, deve abortar
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END IF;

    -------------------------------------------------------------------
    -- Item 6_4 - Historico do cooperado                             --
    -------------------------------------------------------------------
    pc_historico_cooperado (pr_cdcooper => pr_cdcooper  --> Codigo Cooperativa
                           ,pr_cdoperad => pr_cdoperad  --> Codigo Operador
                           ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt  --> Data do movimento
                           ,pr_nrdconta => pr_nrdconta  --> Numero da Conta
                           ,pr_idorigem => pr_idorigem  --> Identificador Origem
                           ,pr_idseqttl => pr_idseqttl  --> Sequencial do Titular
                           ,pr_nrseqite => vr_nrseqite  --> sequencial do item do risco
                           ,pr_dscritic => vr_dscritic);--> Descricao do erro
    IF vr_dscritic IS NOT NULL THEN
      raise vr_exc_erro;
    END IF;
    -- Se solicitado o calculo
    IF pr_flgdcalc = 1 THEN
      -- gerar classifica��o
      vr_vldanota := vr_vldanota + vr_vet_nota_002(vr_nrseqite);
    ELSE
      -- Gravar itens do rating na crapras
      pc_grava_item_rating (pr_cdcooper    => pr_cdcooper             --Codigo Cooperativa
                           ,pr_nrdconta    => pr_nrdconta             --Numero da Conta
                           ,pr_tpctrato    => pr_tpctrato             --Tipo Contrato Rating
                           ,pr_nrctrato    => pr_nrctrato             --Numero Contrato Rating
                           ,pr_nrtopico    => 3                       --Numero do topico
                           ,pr_nritetop    => 2                       --Numero Contrato Rating
                           ,pr_nrseqite    => vr_nrseqite             --Numero Contrato Rating
                           ,pr_flgcriar    => pr_flgcriar             -- Indicado se deve criar o rating
                           ,pr_tab_crapras => pr_tab_crapras          --
                           ,pr_dscritic    => vr_dscritic);           -- Descricao do erro
      -- Se retornou erro, deve abortar
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END IF;

    -------------------------------------------------------------------
    -- Item 6_2 - Informacoes Cadastrais                             --
    -------------------------------------------------------------------
    -- Se solicitado o calculo
    IF pr_flgdcalc = 1 THEN
      -- Usar sequencial de informa��es cadastrais se houver
      IF rw_crapjur.nrinfcad > 0 THEN
        vr_nrseqite := rw_crapjur.nrinfcad;
      ELSE
        vr_nrseqite := 1;
      END IF;
      -- gerar classifica��o
      vr_vldanota := vr_vldanota + vr_vet_nota_003(vr_nrseqite);
    ELSE
      -- Se ja existe rating
      OPEN cr_crapnrc (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_tpctrrat => pr_tpctrato
                      ,pr_nrctrrat => pr_nrctrato);
      FETCH cr_crapnrc
       INTO rw_crapnrc1;
      IF cr_crapnrc%FOUND THEN
        -- entao pegar do cadastro da pessoa
        vr_nrseqite := rw_crapjur.nrinfcad;
      ELSE
        -- Sen�o pegar do proposta ou do limite
        IF pr_tpctrato = 90 THEN
          IF vr_fcrapprp THEN
            vr_nrseqite := rw_crapprp3.nrinfcad;
          END IF;
        ELSE
          IF vr_fcraplim THEN
            vr_nrseqite := rw_craplim3.nrinfcad;
          END IF;
        END IF;
      END IF;
      CLOSE cr_crapnrc;
      -- Gravar itens do rating na crapras
      pc_grava_item_rating (pr_cdcooper    => pr_cdcooper             --Codigo Cooperativa
                           ,pr_nrdconta    => pr_nrdconta             --Numero da Conta
                           ,pr_tpctrato    => pr_tpctrato             --Tipo Contrato Rating
                           ,pr_nrctrato    => pr_nrctrato             --Numero Contrato Rating
                           ,pr_nrtopico    => 3                       --Numero do topico
                           ,pr_nritetop    => 3                       --Numero Contrato Rating
                           ,pr_nrseqite    => vr_nrseqite             --Numero Contrato Rating
                           ,pr_flgcriar    => pr_flgcriar             -- Indicado se deve criar o rating
                           ,pr_tab_crapras => pr_tab_crapras          --
                           ,pr_dscritic    => vr_dscritic);           -- Descricao do erro
      -- Se retornou erro, deve abortar
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END IF;

    -------------------------------------------------------------------
    -- Item 6_5 - Pontualidade                                       --
    -------------------------------------------------------------------
    --Pegar o registro com mais dias de atrasos - Modalidade emprestimo dos ultimos 12 meses

    -- Caso seja para carregar toda a crapris numa temp table para performance
    IF pr_flgttris THEN

      -- verificar se temptable esta vazia
      IF vr_tab_crapris_qtdiaatr.COUNT = 0 THEN
        pc_carrega_temp_qtdiaatr(pr_dtmvtolt => pr_rw_crapdat.dtmvtolt);
      END IF;

      -- definir index
      vr_idx := lpad(pr_cdcooper,10,'0')||lpad(pr_nrdconta,10,'0');
      -- se localizar deve utilizar essa qtd
      IF vr_tab_crapris_qtdiaatr.exists(vr_idx) AND
         vr_tab_crapris_qtdiaatr(vr_idx).qtdiaatr > 0 THEN
        vr_qtdiaatr := vr_tab_crapris_qtdiaatr(vr_idx).qtdiaatr;
      ELSE
        -- senao atribuir zero
        vr_qtdiaatr := 0;
      END IF;

    ELSE

      -- Busca apenas o Risco da conta em questao
      OPEN cr_crapris(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt);
      FETCH cr_crapris
       INTO vr_cdcooper
           ,vr_nrdconta
           ,vr_qtdiaatr;
      CLOSE cr_crapris;

    END IF;

    -- Testar range
    IF nvl(vr_qtdiaatr,0) = 0 THEN
      -- Sem atrasos
      vr_nrseqite := 1;
    ELSIF vr_qtdiaatr <= 16   THEN
      -- Atraso de 16 dias
      vr_nrseqite := 2;
    ELSIF vr_qtdiaatr <= 30   THEN
      -- Atraso no maximo 30 dias
      vr_nrseqite := 3;
    ELSIF vr_qtdiaatr <= 60   THEN
      -- Atraso no maximo 60 dias
      vr_nrseqite := 4;
    ELSE
      -- Atraso acima de 60 dias
      vr_nrseqite := 5;
    END IF;

    -- Se solicitado o calculo
    IF pr_flgdcalc = 1 THEN
      vr_vldanota := vr_vldanota + vr_vet_nota_004(vr_nrseqite);
    ELSE
      -- Gravar itens do rating na crapras
      pc_grava_item_rating ( pr_cdcooper => pr_cdcooper             --Codigo Cooperativa
                            ,pr_nrdconta => pr_nrdconta             --Numero da Conta
                            ,pr_tpctrato => pr_tpctrato             --Tipo Contrato Rating
                            ,pr_nrctrato => pr_nrctrato             --Numero Contrato Rating
                            ,pr_nrtopico => 3                       --Numero do topico
                            ,pr_nritetop => 4                       --Numero Contrato Rating
                            ,pr_nrseqite => vr_nrseqite             --Numero Contrato Rating
                            ,pr_flgcriar => pr_flgcriar             -- Indicado se deve criar o rating
                            ,pr_tab_crapras => pr_tab_crapras       --
                            ,pr_dscritic    => vr_dscritic);        -- Descricao do erro

      -- Se retornou erro, deve abortar
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END IF;

    -------------------------------------------------------------------
    -- 5_3 - Capacidade de geracao de resultados - SET.ECONOMICO     --
    -------------------------------------------------------------------
    -- Conforme setor
    CASE rw_crapjur.cdseteco
       WHEN 1 THEN vr_nrseqite := 4; --Agronegocio
       WHEN 2 THEN vr_nrseqite := 2; -- Comercio
       WHEN 3 THEN vr_nrseqite := 3; -- Industria
       WHEN 4 THEN vr_nrseqite := 1; -- Servicos
       ELSE vr_nrseqite := 0;
    END CASE;

    -- Se solicitado o calculo
    IF pr_flgdcalc = 1 THEN
      vr_vldanota := vr_vldanota + vr_vet_nota_005(vr_nrseqite);
    ELSE
      -- Gravar itens do rating na crapras
      pc_grava_item_rating ( pr_cdcooper => pr_cdcooper             --Codigo Cooperativa
                            ,pr_nrdconta => pr_nrdconta             --Numero da Conta
                            ,pr_tpctrato => pr_tpctrato             --Tipo Contrato Rating
                            ,pr_nrctrato => pr_nrctrato             --Numero Contrato Rating
                            ,pr_nrtopico => 3                       --Numero do topico
                            ,pr_nritetop => 5                       --Numero Contrato Rating
                            ,pr_nrseqite => vr_nrseqite             --Numero Contrato Rating
                            ,pr_flgcriar => pr_flgcriar             -- Indicado se deve criar o rating
                            ,pr_tab_crapras => pr_tab_crapras       --
                            ,pr_dscritic    => vr_dscritic);        -- Descricao do erro

      -- Se retornou erro, deve abortar
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END IF;

    /********************************************************************
     Item 4_1 - TEMPO DOS S�CIOS NA EMPRESA
    ********************************************************************/
    -- Trazer os s�cios da empresa, o mais antigo primeiro
    OPEN cr_crapavt(pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => pr_nrdconta);
    LOOP
      FETCH cr_crapavt
       INTO vr_dtadmsoc;

      -- Sair quando n�o existir mais registros
      EXIT WHEN cr_crapavt%NOTFOUND;
    END LOOP;
    CLOSE cr_crapavt;
    -- Naturezas espec�ficas testam tempo do s�cio mais antigo
    IF rw_crapjur.natjurid IN(2062,2135,4081,2089) THEN
      vr_qtanosoc := ((pr_rw_crapdat.dtmvtolt - vr_dtadmsoc) / 365); -- em anos
    ELSE -- Restante usara a data de inicio das atividades da empresa
      vr_qtanosoc := ((pr_rw_crapdat.dtmvtolt - rw_crapjur.dtiniatv) / 365); -- em anos
    END IF;

    -- Testar range
    IF vr_qtanosoc > 8 THEN
      vr_nrseqite := 1;
    ELSIF vr_qtanosoc >= 5 THEN
      vr_nrseqite := 2;
    ELSIF vr_qtanosoc >= 2 THEN
      vr_nrseqite := 3;
    ELSE
      vr_nrseqite := 4;
    END IF;

    -- Se solicitado o calculo
    IF pr_flgdcalc = 1 THEN
      vr_vldanota := vr_vldanota + vr_vet_nota_006(vr_nrseqite);
    ELSE
      -- Gravar itens do rating na crapras
      pc_grava_item_rating ( pr_cdcooper => pr_cdcooper             --Codigo Cooperativa
                            ,pr_nrdconta => pr_nrdconta             --Numero da Conta
                            ,pr_tpctrato => pr_tpctrato             --Tipo Contrato Rating
                            ,pr_nrctrato => pr_nrctrato             --Numero Contrato Rating
                            ,pr_nrtopico => 3                       --Numero do topico
                            ,pr_nritetop => 6                       --Numero Contrato Rating
                            ,pr_nrseqite => vr_nrseqite             --Numero Contrato Rating
                            ,pr_flgcriar => pr_flgcriar             -- Indicado se deve criar o rating
                            ,pr_tab_crapras => pr_tab_crapras       --
                            ,pr_dscritic    => vr_dscritic);        -- Descricao do erro

      -- Se retornou erro, deve abortar
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END IF;

    /********************************************************************
     Item 6_6 - Concentracao unico cliente.
    ********************************************************************/
    -- Se a busca anterior retornou registros
    IF vr_fcrapjfn THEN
      -- Usar percentual de faturamento do maior cliente
      IF rw_crapjfn.perfatcl > 80 THEN
        vr_nrseqite := 4;
      ELSIF rw_crapjfn.perfatcl >= 50 THEN
        vr_nrseqite := 3;
      ELSIF rw_crapjfn.perfatcl >= 30 THEN
        vr_nrseqite := 2;
      ELSE
        vr_nrseqite := 1;
      END IF;
    ELSE
      vr_nrseqite := 1;
    END IF;
    -- Se solicitado o calculo
    IF pr_flgdcalc = 1 THEN
      vr_vldanota := vr_vldanota + vr_vet_nota_007(vr_nrseqite);
    ELSE
      -- Gravar itens do rating na crapras
      pc_grava_item_rating ( pr_cdcooper => pr_cdcooper             --Codigo Cooperativa
                            ,pr_nrdconta => pr_nrdconta             --Numero da Conta
                            ,pr_tpctrato => pr_tpctrato             --Tipo Contrato Rating
                            ,pr_nrctrato => pr_nrctrato             --Numero Contrato Rating
                            ,pr_nrtopico => 3                       --Numero do topico
                            ,pr_nritetop => 7                       --Numero Contrato Rating
                            ,pr_nrseqite => vr_nrseqite             --Numero Contrato Rating
                            ,pr_flgcriar => pr_flgcriar             -- Indicado se deve criar o rating
                            ,pr_tab_crapras => pr_tab_crapras       --
                            ,pr_dscritic    => vr_dscritic);        -- Descricao do erro

      -- Se retornou erro, deve abortar
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END IF;

    /********************************************************************
     Item 5_1 - Endividamento total SCR versus faturamento medio.
    ********************************************************************/
    -- Para empr�stimos e financiamentos com crawepr
    IF pr_tpctrato = 90 AND vr_fcrawepr THEN
      -- Trazer lista de liquida��es
      vr_dsliquid := fn_traz_liquidacoes(rw_crawepr4);
    END IF;

    -- Buscar o saldo utilizado pelo Cooperado
    pc_calcula_endividamento(pr_cdcooper   => pr_cdcooper     --> C�digo da Cooperativa
                            ,pr_cdagenci   => pr_cdagenci     --> C�digo da ag�ncia
                            ,pr_nrdcaixa   => pr_nrdcaixa     --> N�mero do caixa
                            ,pr_cdoperad   => pr_cdoperad     --> C�digo do operador
                            ,pr_rw_crapdat => pr_rw_crapdat   --> Vetor com dados de par�metro (CRAPDAT)
                            ,pr_nrdconta   => pr_nrdconta     --> Conta do associado
                            ,pr_dsliquid   => vr_dsliquid     --> Lista de contratos a liquidar
                            ,pr_idseqttl   => pr_idseqttl     --> Sequencia de titularidade da conta
                            ,pr_idorigem   => pr_idorigem     --> Indicador da origem da chamada
                            ,pr_inusatab   => pr_inusatab     --> Indicador de utiliza��o da tabela de juros
                            ,pr_vlutiliz   => vr_vlutiliz     --> Valor da d�vida
                            ,pr_cdcritic   => vr_cdcritic     --> Critica encontrada no processo
                            ,pr_dscritic   => vr_dscritic);   --> Sa�da de erro
    -- Se houve erro
    IF vr_cdcritic IS NOT NULL OR trim(vr_dscritic) IS NOT NULL THEN
      -- Encerrar o processo
      RAISE vr_exc_erro;
    END IF;

    -- No caso de proposta, somar valor de operacao corrente
    -- Quando emprestimo ou Cheque especial.
    -- Desconto de cheque e titulo nao sao considerados
    -- no saldo_utiliza do cooperado (Valor limite)

    -- Emprestimo / Financiamento
    IF pr_tpctrato = 90 THEN
      -- Ler informa��es do emprestimo
      OPEN cr_crapepr(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctrato => pr_nrctrato);
      FETCH cr_crapepr
       INTO rw_crapepr1;
      -- Se n�o localizou
      IF cr_crapepr%NOTFOUND THEN
        -- Se h� a proposta
        IF vr_fcrawepr THEN
          vr_vlendivi := rw_crawepr4.vlemprst;
        ELSE -- BNDES
          vr_vlendivi := rw_crapprp3.vlctrbnd;
        END IF;
      END IF;
      CLOSE cr_crapepr;
      -- Se houver Valor Total SFN exceto na cooperativa
      IF rw_crapprp3.vltotsfn <> 0 THEN
        -- Us�-lo
        vr_vlendivi := nvl(vr_vlendivi,0) + rw_crapprp3.vltotsfn;
      ELSE
        -- Usar valor do endividamento
        vr_vlendivi := nvl(vr_vlendivi,0) + nvl(vr_vlutiliz,0);
      END IF;
    -- Desconto / Cheque especial
    ELSIF pr_tpctrato <> 0 THEN
      -- Ch. Especial
      IF pr_tpctrato = 1 THEN
        -- Diferente de ativo
        IF rw_craplim3.insitlim <> 2 THEN
          -- Usaremos o limite da conta
          vr_vlendivi := rw_craplim3.vllimite;
        END IF;
        -- Se houver Valor Total SFN exceto na cooperativa
        IF rw_craplim3.vltotsfn <> 0 THEN
          -- Us�-lo
          vr_vlendivi := nvl(vr_vlendivi,0) + rw_craplim3.vltotsfn;
        ELSE
          -- Usar valor do endividamento
          vr_vlendivi := nvl(vr_vlendivi,0) + nvl(vr_vlutiliz,0);
        END IF;
      END IF;
      
      RISC0001.pc_obtem_valores_central_risco( pr_cdcooper => pr_cdcooper  --> Codigo Cooperativa
                                              ,pr_cdagenci => pr_cdagenci  --> Codigo Agencia
                                              ,pr_nrdcaixa => pr_nrdcaixa  --> Numero Caixa
                                              ,pr_nrdconta => pr_nrdconta  --> Numero da Conta
                                              ,pr_nrcpfcgc => 0  -- CPF    --> CPF/CGC do associado
                                              ,pr_tab_central_risco => vr_tab_central_risco --> Informa��es da Central de Risco
                                              ,pr_tab_erro => pr_tab_erro  --> Tabela Erro
                                              ,pr_des_reto => pr_des_reto);
      IF pr_des_reto <> 'OK' THEN
        RETURN;
      END IF;

      -- se possuir valor, somar valor valor
      IF NVL(vr_tab_central_risco.vltotsfn,0) <> 0  THEN
        vr_vlendivi := nvl(vr_vlendivi,0) + vr_tab_central_risco.vltotsfn;
      END IF;
    ELSE
      -- Se solicitado o calculo
      IF pr_flgdcalc = 1 THEN
        -- Obter os dados do banco cetral para analise da proposta, consulta de SCR. (Tela CONSCR)
        RISC0001.pc_obtem_valores_central_risco( pr_cdcooper => pr_cdcooper  --> Codigo Cooperativa
                                                ,pr_cdagenci => pr_cdagenci  --> Codigo Agencia
                                                ,pr_nrdcaixa => pr_nrdcaixa  --> Numero Caixa
                                                ,pr_nrdconta => pr_nrdconta  --> Numero da Conta
                                                ,pr_nrcpfcgc => 0  -- CPF    --> CPF/CGC do associado
                                                ,pr_tab_central_risco => vr_tab_central_risco --> Informa��es da Central de Risco
                                                ,pr_tab_erro => pr_tab_erro  --> Tabela Erro
                                                ,pr_des_reto => pr_des_reto);
        IF pr_des_reto <> 'OK' THEN
          RETURN;
        END IF;
        
        -- se possuir valor, somar valor valor
        IF NVL(vr_tab_central_risco.vltotsfn,0) <> 0  THEN
          vr_vlendivi := nvl(vr_vlendivi,0) + vr_tab_central_risco.vltotsfn;
        ELSE 
          -- Usar valor j� calculado
          vr_vlendivi := nvl(vr_vlendivi,0) + nvl(vr_vlutiliz,0);
        END IF;
        /*-- Buscar primeiro registro      -- Alterado por: Renato Darosci - Supero - 30/04/2015
                                                  N�o utilizar mais tabela de mem�ria, apenas um record.
        vr_index_cr := vr_tab_central_risco.first;
        -- verificar se existe
        IF vr_tab_central_risco.EXISTS(vr_index_cr) THEN
          -- se possuir valor, somar valor valor
          IF vr_tab_central_risco(vr_index_cr).vltotsfn <> 0  THEN
            vr_vlendivi := nvl(vr_vlendivi,0) + vr_tab_central_risco(vr_index_cr).vltotsfn;
          ELSE
            -- Usar valor j� calculado
            vr_vlendivi := nvl(vr_vlendivi,0) + nvl(vr_vlutiliz,0);
          END IF;
        ELSE
          -- Usar valor j� calculado
          vr_vlendivi := nvl(vr_vlendivi,0) + nvl(vr_vlutiliz,0);
        END IF;*/
      ELSE
        -- Sem d�vidas
        vr_vlendivi := 0;
      END IF;
    END IF;
    -- Buscar tamb�m o faturamento m�dio
    cada0001.pc_calcula_faturamento(pr_cdcooper => pr_cdcooper
                                   ,pr_cdagenci => pr_cdagenci
                                   ,pr_nrdcaixa => pr_nrdcaixa
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_vlmedfat => vr_vlmedfat
                                   ,pr_tab_erro => pr_tab_erro
                                   ,pr_des_reto => pr_des_reto);
    -- Se retornou erro
    IF pr_des_reto = 'NOK' THEN
      RETURN;
    END IF;
    -- Calcular propora��o da d�vida X faturamento
    IF nvl(vr_vlmedfat,0) = 0 THEN -- Tratar divisor zero
      vr_vlendivi := 0;
    ELSE
      vr_vlendivi := (nvl(vr_vlendivi,0) / nvl(vr_vlmedfat,0));
    END IF;
    -- Verificar valor conforme faixa
    IF vr_vlendivi <= 3 THEN
      vr_nrseqite := 1;
    ELSIF vr_vlendivi <= 8 THEN
      vr_nrseqite := 2;
    ELSIF vr_vlendivi <= 20 THEN
      vr_nrseqite := 3;
    ELSE
      vr_nrseqite := 4;
    END IF;
    -- Se solicitado o calculo
    IF pr_flgdcalc = 1 THEN
       vr_vldanota := vr_vldanota + vr_vet_nota_008(vr_nrseqite);
    ELSE
      -- Gravar itens do rating na crapras
      pc_grava_item_rating (pr_cdcooper => pr_cdcooper             --Codigo Cooperativa
                           ,pr_nrdconta => pr_nrdconta             --Numero da Conta
                           ,pr_tpctrato => pr_tpctrato             --Tipo Contrato Rating
                           ,pr_nrctrato => pr_nrctrato             --Numero Contrato Rating
                           ,pr_nrtopico => 3                       --Numero do topico
                           ,pr_nritetop => 8                       --Numero Contrato Rating
                           ,pr_nrseqite => vr_nrseqite             --Numero Contrato Rating
                           ,pr_flgcriar => pr_flgcriar             -- Indicado se deve criar o rating
                           ,pr_tab_crapras => pr_tab_crapras       --
                           ,pr_dscritic    => vr_dscritic);        -- Descricao do erro

      -- Se retornou erro, deve abortar
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END IF;

    /********************************************************************
     Item 5_4 - Pat. pessoal dos garant. / socios liv. de onus
    ********************************************************************/
    -- Se solicitado o calculo
    IF pr_flgdcalc = 1 THEN
      -- Se houver sequencia patrimonio empresa
      IF rw_crapjur.nrpatlvr > 0 THEN
        vr_nrseqite := rw_crapjur.nrpatlvr;
      ELSE
        vr_nrseqite := 5;
      END IF;
      vr_vldanota := vr_vldanota + vr_vet_nota_009(vr_nrseqite);
    ELSE
      -- Se ja existe rating
      OPEN cr_crapnrc (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_tpctrrat => pr_tpctrato
                      ,pr_nrctrrat => pr_nrctrato);
      FETCH cr_crapnrc
       INTO rw_crapnrc1;
      IF cr_crapnrc%FOUND THEN
        -- entao pegar do cadastro da pessoa
        vr_nrseqite := rw_crapjur.nrpatlvr;
      ELSE
        -- Sen�o pegar do proposta ou do limite
        IF pr_tpctrato = 90 THEN
          IF vr_fcrapprp THEN
            vr_nrseqite := rw_crapprp3.nrpatlvr;
          END IF;
        ELSE
          IF vr_fcraplim THEN
            vr_nrseqite := rw_craplim3.nrpatlvr;
          END IF;
        END IF;
      END IF;
      CLOSE cr_crapnrc;
      -- Gravar itens do rating na crapras
      pc_grava_item_rating (pr_cdcooper    => pr_cdcooper             --Codigo Cooperativa
                           ,pr_nrdconta    => pr_nrdconta             --Numero da Conta
                           ,pr_tpctrato    => pr_tpctrato             --Tipo Contrato Rating
                           ,pr_nrctrato    => pr_nrctrato             --Numero Contrato Rating
                           ,pr_nrtopico    => 3                       --Numero do topico
                           ,pr_nritetop    => 9                       --Numero Contrato Rating
                           ,pr_nrseqite    => vr_nrseqite             --Numero Contrato Rating
                           ,pr_flgcriar    => pr_flgcriar             -- Indicado se deve criar o rating
                           ,pr_tab_crapras => pr_tab_crapras       --
                           ,pr_dscritic    => vr_dscritic);        -- Descricao do erro
      -- Se retornou erro, deve abortar
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END IF;

    /********************************************************************
     Item 5_2 - Grau de endividamento. (Parcelas versus faturamento medio)
    ********************************************************************/

    -- Para empr�stimos / Financiamentos
    IF pr_tpctrato = 90 THEN
      -- Empr�stimos Cecred
      IF vr_fcrawepr THEN
        vr_vlpresta := rw_crawepr4.vlpreemp;

        -- Contratos que ele esta liquidando
        vr_vet_nrctrliq(1) := rw_crawepr4.nrctrliq##1;
        vr_vet_nrctrliq(2) := rw_crawepr4.nrctrliq##2;
        vr_vet_nrctrliq(3) := rw_crawepr4.nrctrliq##3;
        vr_vet_nrctrliq(4) := rw_crawepr4.nrctrliq##4;
        vr_vet_nrctrliq(5) := rw_crawepr4.nrctrliq##5;
        vr_vet_nrctrliq(6) := rw_crawepr4.nrctrliq##6;
        vr_vet_nrctrliq(7) := rw_crawepr4.nrctrliq##7;
        vr_vet_nrctrliq(8) := rw_crawepr4.nrctrliq##8;
        vr_vet_nrctrliq(9) := rw_crawepr4.nrctrliq##9;
        vr_vet_nrctrliq(10) := rw_crawepr4.nrctrliq##10;

      -- Operacao BNDES
      ELSIF vr_fcrapprp THEN
        vr_vlpresta := rw_crapprp3.vlctrbnd / rw_crapprp3.qtparbnd;
      END IF;
    -- Limite / Cheque especial
    ELSIF pr_tpctrato <> 0 THEN
      vr_vlpresta := rw_craplim3.vllimite;
    ELSE
      vr_vlpresta := 0;
    END IF;

    -- calcular nivel de comprometimento
    pc_nivel_comprometimento(pr_cdcooper     => pr_cdcooper     --> Cooperativa conectada
                            ,pr_cdoperad     => pr_cdoperad     --> Operador conectado
                            ,pr_idseqttl     => pr_idseqttl     --> Sequencia do titular
                            ,pr_idorigem     => pr_idorigem     --> Origem da requisi��o
                            ,pr_nrdconta     => pr_nrdconta     --> Conta do associado
                            ,pr_tpctrato     => pr_tpctrato     --> Tipo do Rating
                            ,pr_nrctrato     => pr_nrctrato     --> N�mero do contrato de Rating
                            ,pr_vet_nrctrliq => vr_vet_nrctrliq --> Vetor de contratos a liquidar
                            ,pr_vlpreemp     => vr_vlpresta     --> Valor da parcela
                            ,pr_rw_crapdat   => pr_rw_crapdat   --> Calend�rio do movimento atual
                            ,pr_flgdcalc     => pr_flgdcalc     --> Flag para calcular sim ou n�o
                            ,pr_inusatab     => pr_inusatab     --> Indicador de utiliza��o da tabela de juros
                            ,pr_vltotpre     => vr_vltotpre     --> Valor calculado da presta��o
                            ,pr_dscritic     => vr_dscritic);
    -- Se retornou erro, deve abortar
    IF nvl(vr_cdcritic,0) > 0 THEN
      RAISE vr_exc_erro;
    END IF;

    -- Gerar m�dia a partir do faturamento
    vr_vltotpre := vr_vltotpre / vr_vlmedfat;
    -- Testar intervalo
    IF vr_vltotpre <= 0.07 THEN
      -- Ate 7%
      vr_nrseqite := 1;
    ELSIF vr_vltotpre <= 0.1 THEN
      -- At� 10%
      vr_nrseqite := 2;
    ELSE
      -- Mais do que 10%
      vr_nrseqite := 3;
    END IF;

    -- Em caso de solicita��o do c�lculo
    IF pr_flgdcalc = 1 THEN
      vr_vldanota := vr_vldanota + vr_vet_nota_010(vr_nrseqite);
    ELSE
      -- Gravar itens do rating na crapras
      pc_grava_item_rating (pr_cdcooper => pr_cdcooper             --Codigo Cooperativa
                           ,pr_nrdconta => pr_nrdconta             --Numero da Conta
                           ,pr_tpctrato => pr_tpctrato             --Tipo Contrato Rating
                           ,pr_nrctrato => pr_nrctrato             --Numero Contrato Rating
                           ,pr_nrtopico => 3                       --Numero do topico
                           ,pr_nritetop => 10                      --Numero Contrato Rating
                           ,pr_nrseqite => vr_nrseqite             --Numero Contrato Rating
                           ,pr_flgcriar => pr_flgcriar             -- Indicado se deve criar o rating
                           ,pr_tab_crapras => pr_tab_crapras       --
                           ,pr_dscritic    => vr_dscritic);        -- Descricao do erro
      -- Se retornou erro, deve abortar
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END IF;

    /********************************************************************
     Item 6_3 - Percepcao geral com relacao a empresa.
    ********************************************************************/
    -- Se solicitado o calculo
    IF pr_flgdcalc = 1 THEN
      -- Se houver percentual geral com rela��o a empresa (rating)
      IF rw_crapjur.nrperger > 0 THEN
        vr_nrseqite := rw_crapjur.nrperger;
      ELSE
        vr_nrseqite := 1;
      END IF;
      vr_vldanota := vr_vldanota + vr_vet_nota_011(vr_nrseqite);
    ELSE
      -- Se ja existe rating
      OPEN cr_crapnrc (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_tpctrrat => pr_tpctrato
                      ,pr_nrctrrat => pr_nrctrato);
      FETCH cr_crapnrc
       INTO rw_crapnrc1;
      IF cr_crapnrc%FOUND THEN
        -- entao pegar do cadastro da pessoa
        vr_nrseqite := rw_crapjur.nrperger;
      ELSE
        -- Sen�o pegar do proposta ou do limite
        IF pr_tpctrato = 90 THEN
          IF vr_fcrapprp THEN
            vr_nrseqite := rw_crapprp3.nrperger;
          END IF;
        ELSE
          IF vr_fcraplim THEN
            vr_nrseqite := rw_craplim3.nrperger;
          END IF;
        END IF;
      END IF;
      CLOSE cr_crapnrc;
      -- Gravar itens do rating na crapras
      pc_grava_item_rating (pr_cdcooper    => pr_cdcooper             --Codigo Cooperativa
                           ,pr_nrdconta    => pr_nrdconta             --Numero da Conta
                           ,pr_tpctrato    => pr_tpctrato             --Tipo Contrato Rating
                           ,pr_nrctrato    => pr_nrctrato             --Numero Contrato Rating
                           ,pr_nrtopico    => 3                       --Numero do topico
                           ,pr_nritetop    => 11                      --Numero Contrato Rating
                           ,pr_nrseqite    => vr_nrseqite             --Numero Contrato Rating
                           ,pr_flgcriar    => pr_flgcriar             -- Indicado se deve criar o rating
                           ,pr_tab_crapras => pr_tab_crapras          --
                           ,pr_dscritic    => vr_dscritic);           -- Descricao do erro
      -- Se retornou erro, deve abortar
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END IF;

    -- Ao final, classificar o cooperado conforme a nota
    IF pr_flgdcalc = 1 THEN
      IF vr_vldanota >= 0 AND vr_vldanota <= 22.5 THEN
        pr_clascoop := 'A'; /* AA */
      ELSIF vr_vldanota >= 23 AND vr_vldanota <= 29.5 THEN
        pr_clascoop := 'A';
      ELSIF vr_vldanota >= 30 AND vr_vldanota <= 36.5 THEN
        pr_clascoop := 'B';
      ELSIF vr_vldanota >= 37 AND vr_vldanota <= 43.5 THEN
        pr_clascoop := 'C';
      ELSIF vr_vldanota >= 44 AND vr_vldanota <= 50.5 THEN
        pr_clascoop := 'D';
      ELSIF vr_vldanota >= 51 AND vr_vldanota <= 55.5 THEN
        pr_clascoop := 'E';
      ELSIF vr_vldanota >= 56 AND vr_vldanota <= 60.5 THEN
        pr_clascoop := 'F';
      ELSIF vr_vldanota >= 61 AND vr_vldanota <= 65.5 THEN
        pr_clascoop := 'G';
      ELSE
        pr_clascoop := 'H'; /* >= 66 e <= 999.9 */
      END IF;
      pr_notacoop := vr_vldanota;
    END IF;

    pr_des_reto := 'OK';
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno n�o OK
      pr_des_reto := 'NOK';
      -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
    WHEN OTHERS THEN
      -- Retorno n�o OK
      pr_des_reto := 'NOK';

      -- Montar descri��o de erro n�o tratado
      vr_dscritic := 'Erro n�o tratado na RATI0001.pc_risco_cooperado_pj> '||sqlerrm;
      -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1
                           ,pr_cdcritic => 0
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
  END pc_risco_cooperado_pj;

  /* Procedure para calcular o rating de pessoas juridicas. Tratamento divido em itens. */
  PROCEDURE pc_calcula_rating_juridica(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Codigo Cooperativa
                                      ,pr_cdagenci IN crapass.cdagenci%TYPE   --> Codigo Agencia
                                      ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE   --> Numero Caixa
                                      ,pr_cdoperad IN crapnrc.cdoperad%TYPE   --> Codigo Operador
                                      ,pr_idorigem IN INTEGER                 --> Identificador Origem
                                      ,pr_nrdconta IN crapass.nrdconta%TYPE   --> Numero da Conta
                                      ,pr_idseqttl IN crapttl.idseqttl%TYPE   --> Sequencial do Titular
                                      ,pr_rw_crapdat IN btch0001.rw_crapdat%TYPE  --> Vetor com dados de par�metro (CRAPDAT)
                                      ,pr_tpctrato IN crapnrc.tpctrrat%TYPE    --> Tipo Contrato Rating
                                      ,pr_nrctrato IN crapnrc.nrctrrat%TYPE    --> Numero Contrato Rating
                                      ,pr_inusatab IN BOOLEAN                  --> Indicador de utiliza��o da tabela de juros
                                      ,pr_flgcriar IN INTEGER                  --> Indicado se deve criar o rating
                                      ,pr_tab_crapras IN OUT typ_tab_crapras   --> Tabela com os registros a serem processados
                                      ,pr_tab_erro OUT GENE0001.typ_tab_erro   --> Tabela de retorno de erro
                                      ,pr_des_reto OUT VARCHAR2) IS            --> Ind. de retorno OK/NOK IS           --> Descricao do erro
  /* ..........................................................................

     Programa: pc_calcula_rating_juridica         Antigo: b1wgen0043.p/calcula_rating_juridica
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Marcos Martini - Supero
     Data    : Agosto/2014.                          Ultima Atualizacao: 10/05/2016

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  : Procedure para calular o rating para as pessoas fisicas.

     Alteracoes: 28/08/2014 - Convers�o Progress -> Oracle - Marcos (Supero)

		         10/05/2016 - Ajuste para utitlizar rowtype locais 
							 (Andrei  - RKAM).
  ............................................................................. */

    -- Variaveis de erro
    vr_exc_erro EXCEPTION;
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);

    -- Indicador se encontrou registro
    vr_fcrawepr  BOOLEAN := FALSE;
    vr_fcraplcr  BOOLEAN := FALSE;
    -- Sequenciais para grava��es dos itens
    vr_nrseqite  NUMBER;
    vr_qtdiapra  NUMBER;
    -- Classifica��o e Nota do cooperado
    vr_notacoop NUMBER;
    vr_clascoop VARCHAR2(10);

    rw_crawepr5 cr_crawepr%ROWTYPE;
    rw_crapprp4 cr_crapprp%ROWTYPE;
    rw_craplcr3 cr_craplcr%ROWTYPE;
    rw_craplim4 cr_craplim%ROWTYPE;
    
  BEGIN

    -- Para Risco Cooperado o calculo eh diferenciado
    IF pr_tpctrato <> 0 AND pr_nrctrato <> 0 THEN
      -- Emprestimo/Financiamento
      IF pr_tpctrato = 90 THEN
        -- Ler informa��es complementares emprestimo
        OPEN cr_crawepr(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrctrato => pr_nrctrato);
        FETCH cr_crawepr
         INTO rw_crawepr5;
        -- Se localizou
        IF cr_crawepr%FOUND THEN
          -- Guardar flag de encontro
          vr_fcrawepr := true;
          -- Ler Cadastro de Linhas de Credito
          OPEN cr_craplcr(pr_cdcooper => pr_cdcooper
                         ,pr_cdlcremp => rw_crawepr5.cdlcremp);
          FETCH cr_craplcr
           INTO rw_craplcr3;
          -- Guardar flag de encontro
          vr_fcraplcr := cr_craplcr%FOUND;
          CLOSE cr_craplcr;
        END IF;
        CLOSE cr_crawepr;
        -- Ler Cadastros de propostas.
        OPEN cr_crapprp(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_tpctrato => pr_tpctrato
                       ,pr_nrctrato => pr_nrctrato);
        FETCH cr_crapprp
         INTO rw_crapprp4;
        CLOSE cr_crapprp;
      ELSE
        -- Ler Contratos de Limite de credito
        OPEN cr_craplim(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_tpctrato => pr_tpctrato
                       ,pr_nrctrato => pr_nrctrato);
        FETCH cr_craplim
         INTO rw_craplim4;
        CLOSE cr_craplim;
      END IF;
    END IF;

    -- Calclula o Risco Cooperado
    pc_risco_cooperado_pj (pr_flgdcalc => 0                --> Indicador de calculo
                          ,pr_cdcooper => pr_cdcooper      --> Codigo Cooperativa
                          ,pr_cdagenci => pr_cdagenci      --> Codigo Agencia
                          ,pr_nrdcaixa => pr_nrdcaixa      --> Numero Caixa
                          ,pr_cdoperad => pr_cdoperad      --> Codigo Operador
                          ,pr_idorigem => pr_idorigem      --> Identificador Origem
                          ,pr_nrdconta => pr_nrdconta      --> Numero da Conta
                          ,pr_idseqttl => pr_idseqttl      --> Sequencial do Titular
                          ,pr_rw_crapdat => pr_rw_crapdat  --> Vetor com dados de par�metro (CRAPDAT)
                          ,pr_tpctrato => pr_tpctrato      --> Tipo Contrato Rating
                          ,pr_nrctrato => pr_nrctrato      --> Numero Contrato Rating
                          ,pr_inusatab => pr_inusatab      --> Indicador de utiliza��o da tabela de juros
                          ,pr_flgcriar => pr_flgcriar      --> Indicado se deve criar o rating
                          ,pr_flgttris => FALSE            --> Indicado se deve carregar toda a crapris
                          ,pr_tab_crapras => pr_tab_crapras--> Tabela com os registros a serem processados
                          ,pr_notacoop => vr_notacoop      --> Retorna a nota da classifica��o
                          ,pr_clascoop => vr_clascoop      --> Retorna classifica��o
                          ,pr_tab_erro => pr_tab_erro      --> Tabela de retorno de erro
                          ,pr_des_reto => pr_des_reto );   --> Ind. de retorno OK/NOK

    -- se gerou critica, abortar programa
    IF pr_des_reto <> 'OK' THEN
      return;
    END IF;

    -- Para calculo cooperado somente topico 3
    IF pr_tpctrato = 0  AND pr_nrctrato = 0  THEN
      pr_des_reto := 'OK';
      RETURN;
    END IF;

    -------------------------------------------------------
    -- Item 4_4 - Limite de credito (dados da proposta)  --
    -------------------------------------------------------
    IF pr_tpctrato = 90 THEN  /* Emprestimo / Financiamento */
      -- Se encontrou registro na crawepr
      IF vr_fcrawepr THEN
        -- Renegociacao / Composicao de divida
        IF rw_crawepr5.idquapro > 2 THEN
          vr_nrseqite := 6;
        ELSE
          -- Buscar conforme linha de credito
          CASE rw_craplcr3.dsoperac
            WHEN 'CAPITAL DE GIRO ATE 30 DIAS' THEN
              vr_nrseqite := 1;
            WHEN 'FINANCIAMENTO' THEN
              vr_nrseqite := 2;
            WHEN 'CAPITAL DE GIRO ACIMA 30 DIAS' THEN
              vr_nrseqite := 3;
            WHEN 'EMPRESTIMO' THEN
              vr_nrseqite := 4;
            ELSE
              -- Mantem valor anterior
              vr_nrseqite := vr_nrseqite;
          END CASE;
        END IF;
      ELSE
        -- Se n�o encontrou linha de credito
        IF NOT vr_fcraplcr THEN
          vr_nrseqite := 2;
        END IF;
      END IF;
    ELSE
      -- Limite
      IF rw_craplim4.tpctrlim = 1 THEN
        vr_nrseqite := 5;
      ELSE
        -- Descontos
        vr_nrseqite := 2;
      END IF;
    END IF;

    -- Grava o item de Rating
    pc_grava_item_rating (pr_cdcooper    => pr_cdcooper          -- Codigo Cooperativa
                         ,pr_nrdconta    => pr_nrdconta          -- Numero da Conta
                         ,pr_tpctrato    => pr_tpctrato          -- Tipo Contrato Rating
                         ,pr_nrctrato    => pr_nrctrato          -- Numero Contrato Rating
                         ,pr_nrtopico    => 4                    -- Numero do topico
                         ,pr_nritetop    => 1                    -- Numero Contrato Rating
                         ,pr_nrseqite    => vr_nrseqite          -- Numero Contrato Rating
                         ,pr_flgcriar    => pr_flgcriar          -- Indicado se deve criar o rating
                         ,pr_tab_crapras => pr_tab_crapras       -- Tabela generica de rating do associado
                         ,pr_dscritic    => vr_dscritic);        -- Descricao do erro
    -- Se retornou erro, deve abortar
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -------------------------------------------------------
    --     Item 4_2 - Garantias (Dados da proposta)      --
    -------------------------------------------------------
    -- Emprestimo / Financiamento
    IF pr_tpctrato = 90 THEN
      vr_nrseqite := rw_crapprp4.nrgarope;
    -- Descontos / Limite rotativo
    ELSE
      vr_nrseqite := rw_craplim4.nrgarope;
    END IF;

    -- Grava o item de Rating
    pc_grava_item_rating (pr_cdcooper    => pr_cdcooper             -- Codigo Cooperativa
                         ,pr_nrdconta    => pr_nrdconta             -- Numero da Conta
                         ,pr_tpctrato    => pr_tpctrato             -- Tipo Contrato Rating
                         ,pr_nrctrato    => pr_nrctrato             -- Numero Contrato Rating
                         ,pr_nrtopico    => 4                       -- Numero do topico
                         ,pr_nritetop    => 2                       -- Numero Contrato Rating
                         ,pr_nrseqite    => vr_nrseqite             -- Numero Contrato Rating
                         ,pr_flgcriar    => pr_flgcriar             -- Indicado se deve criar o rating
                         ,pr_tab_crapras => pr_tab_crapras       -- Tabela generica de rating do associado
                         ,pr_dscritic    => vr_dscritic);        -- Descricao do erro
    -- Se retornou erro, deve abortar
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    ------------------------------------------------------------
    -- Item 4_3 - Liquidez das garantias (Dados da proposta)  --
    ------------------------------------------------------------
    -- Emprestimo / Financiamento
    IF pr_tpctrato = 90 THEN
      vr_nrseqite := rw_crapprp4.nrliquid;
    -- Descontos / Limite rotativo
    ELSE
      vr_nrseqite := rw_craplim4.nrliquid;
    END IF;

    -- Grava o item de Rating
    pc_grava_item_rating (pr_cdcooper    => pr_cdcooper             -- Codigo Cooperativa
                         ,pr_nrdconta    => pr_nrdconta             -- Numero da Conta
                         ,pr_tpctrato    => pr_tpctrato             -- Tipo Contrato Rating
                         ,pr_nrctrato    => pr_nrctrato             -- Numero Contrato Rating
                         ,pr_nrtopico    => 4                       -- Numero do topico
                         ,pr_nritetop    => 3                       -- Numero Contrato Rating
                         ,pr_nrseqite    => vr_nrseqite             -- Numero Contrato Rating
                         ,pr_flgcriar    => pr_flgcriar             -- Indicado se deve criar o rating
                         ,pr_tab_crapras => pr_tab_crapras       -- Tabela generica de rating do associado
                         ,pr_dscritic    => vr_dscritic);        -- Descricao do erro
    -- Se retornou erro, deve abortar
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -------------------------------------
    -- Item 4_5 - Prazo da operacao -----
    -------------------------------------
    -- Emprestimo / Financiamento
    IF pr_tpctrato = 90 THEN
      -- Se h� o cadastro complementar
      IF vr_fcrawepr THEN
         -- Usamos do complemento
         vr_qtdiapra := rw_crawepr5.qtpreemp * 30; -- Sempre vezes 30
      ELSE
         -- Buscar da proposta
         vr_qtdiapra := rw_crapprp4.qtparbnd * 30; -- Sempre vezes 30
      END IF;
    -- Descontos / Limite rotativo
    ELSE
      -- Usar dias de vigencia do limite
      vr_qtdiapra := rw_craplim4.qtdiavig;
    END IF;
    -- Geramos o sequncial conforme o range de datas
    IF vr_qtdiapra <= 360 THEN
      vr_nrseqite := 1;
    ELSIF vr_qtdiapra <= 720 THEN
      vr_nrseqite := 2;
    ELSIF vr_qtdiapra <= 1440 THEN
      vr_nrseqite := 3;
    ELSE
      vr_nrseqite := 4;
    END IF;
    -- Grava o item de Rating
    pc_grava_item_rating (pr_cdcooper    => pr_cdcooper          -- Codigo Cooperativa
                         ,pr_nrdconta    => pr_nrdconta          -- Numero da Conta
                         ,pr_tpctrato    => pr_tpctrato          -- Tipo Contrato Rating
                         ,pr_nrctrato    => pr_nrctrato          -- Numero Contrato Rating
                         ,pr_nrtopico    => 4                    -- Numero do topico
                         ,pr_nritetop    => 4                    -- Numero Contrato Rating
                         ,pr_nrseqite    => vr_nrseqite          -- Numero Contrato Rating
                         ,pr_flgcriar    => pr_flgcriar          -- Indicado se deve criar o rating
                         ,pr_tab_crapras => pr_tab_crapras       -- Tabela generica de rating do associado
                         ,pr_dscritic    => vr_dscritic);        -- Descricao do erro
    -- Se retornou erro, deve abortar
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Retorno OK
    pr_des_reto := 'OK';
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno n�o OK
      pr_des_reto := 'NOK';
      -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
    WHEN OTHERS THEN
      -- Retorno n�o OK
      pr_des_reto := 'NOK';
      -- Montar descri��o de erro n�o tratado
      vr_dscritic := 'Erro n�o tratado na RATI0001.pc_calcula_rating_juridica> '||sqlerrm;
      -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => 0
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
  END pc_calcula_rating_juridica;

  /*****************************************************************************
   Verificar se o Rating tem que ser criado.
  *****************************************************************************/
  PROCEDURE pc_verifica_criacao (pr_cdcooper IN crapcop.cdcooper%TYPE      --> Codigo Cooperativa
                                ,pr_cdagenci IN crapass.cdagenci%TYPE      --> Codigo Agencia
                                ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE      --> Numero Caixa
                                ,pr_cdoperad IN crapnrc.cdoperad%TYPE      --> Codigo Operador
                                ,pr_rw_crapdat IN btch0001.rw_crapdat%TYPE --> Vetor com dados de par�metro (CRAPDAT)
                                ,pr_nrdconta IN crapass.nrdconta%TYPE      --> Numero da Conta
                                ,pr_tpctrato IN crapnrc.tpctrrat%TYPE      --> Tipo Contrato Rating
                                ,pr_nrctrato IN crapnrc.nrctrrat%TYPE      --> Numero Contrato Rating
                                ,pr_idseqttl IN crapttl.idseqttl%TYPE      --> Sequencial do Titular
                                ,pr_idorigem IN INTEGER                    --> Identificador Origem
                                ,pr_inusatab IN BOOLEAN                    --> Indicador de utiliza��o da tabela de juros
                                ,pr_flgcriar OUT INTEGER                   --> Indicado se deve criar o rating
                                ,pr_tab_erro OUT GENE0001.typ_tab_erro     --> Tabela de retorno de erro
                                ,pr_des_reto OUT VARCHAR2) IS              --> Ind. de retorno OK/NOK

  /* ..........................................................................

     Programa: pc_verifica_criacao         Antigo: b1wgen0043.p/verifica_criacao
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Odirlei Busana - AMcom
     Data    :Aagosto/2014.                          Ultima Atualizacao: 10/05/2016

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  : Verificar se o Rating tem que ser criado.

     Alteracoes: 27/08/2014 - Convers�o Progress -> Oracle - Odirlei (AMcom)

		         10/05/2016 - Ajuste para utitlizar rowtype locais 
							  (Andrei  - RKAM).
  ............................................................................. */

  ---------------- CURSOR ---------------

    -- Verificar se j� existe Notas do rating para contrato
    CURSOR cr_crapnrc IS
      SELECT 1
        FROM crapnrc
       WHERE crapnrc.cdcooper = pr_cdcooper
         AND crapnrc.nrdconta = pr_nrdconta
         AND crapnrc.tpctrrat = pr_tpctrato
         AND crapnrc.nrctrrat = pr_nrctrato;
    rw_crapnrc cr_crapnrc%ROWTYPE;

  ----------------- VARIAVEIS -----------------
    -- Descri��o e c�digo da critica
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    -- Exce��o de sa�da
    vr_exc_erro EXCEPTION;
    vr_exc_saida EXCEPTION;
    -- Lista dos contratos a liquidar
    vr_dsliquid VARCHAR2(4000);

    -- Valor utilizado
    vr_vlutiliz NUMBER;
    -- Indicador de BNDES
    vr_flgbndes BOOLEAN := FALSE;
    -- Valor parametrizado de rating
    vr_vlrating NUMBER;
    -- Valor m�ximo legal
    vr_vlmaxleg NUMBER;
    
    rw_crawepr6 cr_crawepr%ROWTYPE;
    
  BEGIN

    -- Se for tipo de contrato 90
    IF pr_tpctrato = 90 THEN
      -- Buscar dados dos emprestimos
      OPEN cr_crawepr(pr_cdcooper
                     ,pr_nrdconta
                     ,pr_nrctrato);
      FETCH cr_crawepr
       INTO rw_crawepr6;
      -- Se n�o encontrar
      IF cr_crawepr%NOTFOUND THEN
        vr_flgbndes := TRUE;
      -- Se encontrou gerar lista
      ELSE
        -- Chamar rotina para separar a lista a liquidar
        vr_dsliquid := fn_traz_liquidacoes(pr_rw_crawepr => rw_crawepr6); --> Registro da crawepr);
      END IF;
      CLOSE cr_crawepr;
    END IF; -- FIm pr_tpctrato = 90

    -- Buscar o saldo utilizado pelo Cooperado
    pc_calcula_endividamento(pr_cdcooper   => pr_cdcooper     --> C�digo da Cooperativa
                            ,pr_cdagenci   => pr_cdagenci     --> C�digo da ag�ncia
                            ,pr_nrdcaixa   => pr_nrdcaixa     --> N�mero do caixa
                            ,pr_cdoperad   => pr_cdoperad     --> C�digo do operador
                            ,pr_rw_crapdat => pr_rw_crapdat   --> Vetor com dados de par�metro (CRAPDAT)
                            ,pr_nrdconta   => pr_nrdconta     --> Conta do associado
                            ,pr_dsliquid   => vr_dsliquid     --> Lista de contratos a liquidar
                            ,pr_idseqttl   => pr_idseqttl     --> Sequencia de titularidade da conta
                            ,pr_idorigem   => pr_idorigem     --> Indicador da origem da chamada
                            ,pr_inusatab   => pr_inusatab     --> Indicador de utiliza��o da tabela de juros
                            ,pr_vlutiliz   => vr_vlutiliz     --> Valor da d�vida
                            ,pr_cdcritic   => vr_cdcritic     --> Critica encontrada no processo
                            ,pr_dscritic   => vr_dscritic);   --> Sa�da de erro
    -- Se houve erro
    IF vr_cdcritic IS NOT NULL OR trim(vr_dscritic) IS NOT NULL THEN
      -- Encerrar o processo
      RAISE vr_exc_erro;
    END IF;

	wglb_vlutiliz := vr_vlutiliz;

    -- Retornar valor de parametriza��o do rating cadastrado na TAB036
    pc_param_valor_rating(pr_cdcooper => pr_cdcooper --> C�digo da Cooperativa
                         ,pr_vlrating => vr_vlrating --> Valor parametrizado
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic);
    -- Se houve erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      -- Encerrar o processo
      RAISE vr_exc_erro;
    END IF;

    -- Buscar valor maximo legal cadastrado pela CADCOP
    pc_valor_maximo_legal(pr_cdcooper => pr_cdcooper --> C�digo da Cooperativa
                         ,pr_vlmaxleg => vr_vlmaxleg --> Valor parametrizado
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic);
    -- Se houve erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      -- Encerrar o processo
      RAISE vr_exc_erro;
    END IF;

    /* Operacao atual maior/igual  do que */
    /* valor Rating ou 5 % PR  */
    IF vr_vlutiliz >= vr_vlrating        OR
       vr_vlutiliz >= (vr_vlmaxleg / 3)  THEN
      pr_flgcriar := 1;

    /* Se ja existe � porq esta atualizando */
    ELSE
      -- Verificar se j� existe Notas do rating para contrato
      OPEN cr_crapnrc;
      FETCH cr_crapnrc into rw_crapnrc;
      IF cr_crapnrc%FOUND THEN
        -- Se encontrou retornar true;
        pr_flgcriar := 1;
      END IF;
      CLOSE cr_crapnrc;
    END IF;

    -- Verificar se pode utilizar o valor
    IF pr_flgcriar = 0 AND
       vr_flgbndes = TRUE THEN

      vr_cdcritic := 0;
      vr_dscritic := 'Valor utilizado pelo cooperado nao permite efetivacao!';

      raise vr_exc_erro;
    END IF;

    -- Retorno OK
    pr_des_reto := 'OK';
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno n�o OK
      pr_des_reto := 'NOK';
      -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
    WHEN OTHERS THEN
      -- Retorno n�o OK
      pr_des_reto := 'NOK';
      -- Montar descri��o de erro n�o tratado
      vr_dscritic := 'Erro n�o tratado na RATI0001.pc_verifica_criacao> '||sqlerrm;
      -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => 0
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);

  END pc_verifica_criacao;

  /*****************************************************************************
   Procedure para calcular o rating das cooperativas singulares com c/c na
   CECRED
  *****************************************************************************/
  PROCEDURE pc_calcula_singulares(pr_cdcooper        IN crapcop.cdcooper%TYPE     --> Codigo Cooperativa
                                 ,pr_cdagenci        IN crapass.cdagenci%TYPE     --> Codigo Agencia
                                 ,pr_nrdcaixa        IN craperr.nrdcaixa%TYPE     --> Numero Caixa
                                 ,pr_cdoperad        IN crapnrc.cdoperad%TYPE     --> Codigo Operador
                                 ,pr_idorigem        IN INTEGER                   --> Identificador Origem
                                 ,pr_nrdconta        IN crapass.nrdconta%TYPE     --> Numero da Conta
                                 ,pr_idseqttl        IN crapttl.idseqttl%TYPE     --> Sequencial do Titular
                                 ,pr_rw_crapdat      IN btch0001.rw_crapdat%TYPE  --> Vetor com dados de par�metro (CRAPDAT)
                                 ,pr_tpctrato        IN crapnrc.tpctrrat%TYPE     --> Tipo Contrato Rating
                                 ,pr_nrctrato        IN crapnrc.nrctrrat%TYPE     --> Numero Contrato Rating
                                 ,pr_inusatab        IN BOOLEAN                   --> Indicador de utiliza��o da tabela de juros
                                 ,pr_flgcriar        IN INTEGER                   --> Indicado se deve criar o rating
                                 ,pr_tab_rating_sing IN typ_tab_crapras     --> Tabela com os registros a serem processados
                                 ,pr_tab_crapras     IN OUT typ_tab_crapras --> Tabela com os registros a serem processados
                                 ,pr_vlutiliz           OUT NUMBER          --> Valor da d�vida
                                 ,pr_dscritic           OUT VARCHAR2) IS    --> Descricao do erro

  /* ..........................................................................

     Programa: pc_calcula_singulares         Antigo: b1wgen0043.p/calcula_singulares
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Odirlei Busana - AMcom
     Data    :Aagosto/2014.                          Ultima Atualizacao: 27/08/2014

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  : Procedure para calcular o rating das cooperativas singulares com c/c na
                 CECRED

     Alteracoes: 27/08/2014 - Convers�o Progress -> Oracle - Odirlei (AMcom)

  ............................................................................. */
  --------------- VARIAVEIS ----------------
    --Variaveis de erro
    vr_exc_erro EXCEPTION;
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    vr_index    VARCHAR2(50);

    -- valor utilizado
    vr_valoruti NUMBER;

  BEGIN
    -- Varrer temptable
    vr_index := pr_tab_rating_sing.first;

    -- enquanto encontra registro
    WHILE vr_index IS NOT NULL LOOP
      /*****************************************************************************
       Gravar itens do rating na crapras quando for efetivada a proposta ou em
       temp temp-table quando for somente criada uma proposta.
      *****************************************************************************/
      pc_grava_item_rating ( pr_cdcooper => pr_cdcooper             --Codigo Cooperativa
                            ,pr_nrdconta => pr_nrdconta             --Numero da Conta
                            ,pr_tpctrato => pr_tpctrato             --Tipo Contrato Rating
                            ,pr_nrctrato => pr_nrctrato             --Numero Contrato Rating
                            ,pr_nrtopico => pr_tab_rating_sing(vr_index).nrtopico  --Numero do topico
                            ,pr_nritetop => pr_tab_rating_sing(vr_index).nritetop  --Numero Contrato Rating
                            ,pr_nrseqite => pr_tab_rating_sing(vr_index).nrseqite  --Numero Contrato Rating
                            ,pr_flgcriar => pr_flgcriar             -- Indicado se deve criar o rating
                            ,pr_tab_crapras => pr_tab_crapras  --
                            ,pr_dscritic    => pr_dscritic);        -- Descricao do erro

      -- Se retornou erro, deve abortar
      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- buscar proximo
      vr_index := pr_tab_rating_sing.next(vr_index);
    END LOOP;

    -- Buscar o saldo utilizado pelo Cooperado
    pc_calcula_endividamento(pr_cdcooper   => pr_cdcooper     --> C�digo da Cooperativa
                            ,pr_cdagenci   => pr_cdagenci     --> C�digo da ag�ncia
                            ,pr_nrdcaixa   => pr_nrdcaixa     --> N�mero do caixa
                            ,pr_cdoperad   => pr_cdoperad     --> C�digo do operador
                            ,pr_rw_crapdat => pr_rw_crapdat   --> Vetor com dados de par�metro (CRAPDAT)
                            ,pr_nrdconta   => pr_nrdconta     --> Conta do associado
                            ,pr_dsliquid   => null            --> Lista de contratos a liquidar
                            ,pr_idseqttl   => pr_idseqttl     --> Sequencia de titularidade da conta
                            ,pr_idorigem   => pr_idorigem     --> Indicador da origem da chamada
                            ,pr_inusatab   => pr_inusatab     --> Indicador de utiliza��o da tabela de juros
                            ,pr_vlutiliz   => vr_valoruti     --> Valor da d�vida
                            ,pr_cdcritic   => vr_cdcritic     --> Critica encontrada no processo
                            ,pr_dscritic   => vr_dscritic);   --> Sa�da de erro
    -- Se houve erro
    IF vr_cdcritic IS NOT NULL OR trim(vr_dscritic) IS NOT NULL THEN
      -- Encerrar o processo
      RAISE vr_exc_erro;
    END IF;
    -- Acrescentar valor
    pr_vlutiliz := nvl(pr_vlutiliz,0) + nvl(vr_valoruti,0);
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na pc_calcula_singulares: '||SQLErrm;
  END pc_calcula_singulares;

  /*****************************************************************************
   Natureza da operacao Pessoa fisica (2_1).
  *****************************************************************************/
  PROCEDURE pc_natureza_operacao(pr_tpctrato IN crapnrc.tpctrrat%TYPE --> Tipo Contrato Rating
                                ,pr_idquapro IN INTEGER       --> Numero Contrato Rating
                                ,pr_dsoperac IN VARCHAR2      --> Indicado se deve criar o rating
                                ,pr_nrseqite OUT NUMBER       --> Valor da d�vida
                                ,pr_dscritic OUT VARCHAR2) IS --> Descricao do erro

  /* ..........................................................................

     Programa: pc_natureza_operacao         Antigo: b1wgen0043.p/natureza_operacao
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Odirlei Busana - AMcom
     Data    : Agosto/2014.                          Ultima Atualizacao: 27/08/2014

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  : Natureza da operacao Pessoa fisica (2_1).

     Alteracoes: 27/08/2014 - Convers�o Progress -> Oracle - Odirlei (AMcom)

  ............................................................................. */
  --------------- VARIAVEIS ----------------
  BEGIN
    IF pr_tpctrato = 90 THEN  -- Emprestimo / Financiamento
      IF pr_idquapro > 2 THEN
        -- Renegociacao / Composicao de divida
        IF pr_idquapro in (3,4) THEN
          pr_nrseqite := 4;
        END IF;
      ELSE
         IF pr_dsoperac = 'FINANCIAMENTO' THEN
           pr_nrseqite := 1;
         ELSE
           pr_nrseqite := 2;
         END IF;
      END IF;
    ELSE -- Cheque especial / Descontos
      CASE pr_tpctrato
        WHEN 1 THEN pr_nrseqite := 3; -- Ch.especial
        WHEN 2 THEN pr_nrseqite := 2; -- Des.cheque
        WHEN 3 THEN pr_nrseqite := 2; -- Des.Tit.
        ELSE pr_nrseqite := NULL;
      END CASE;

    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na pc_natureza_operacao: '|| SQLErrm;
  END pc_natureza_operacao;

  /*****************************************************************************
   Tratamento das criticas para o calculo de pessoa fisica.
   Foi desenvolvido para mostrar todas as criticas do calculo.
  *****************************************************************************/
  PROCEDURE pc_criticas_rating_fis(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo Cooperativa
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Numero da Conta
                                  ,pr_tpctrrat IN crapnrc.tpctrrat%TYPE  --> Tipo Contrato Rating
                                  ,pr_nrctrrat IN crapnrc.nrctrrat%TYPE  --> Numero Contrato Rating
                                  ,pr_cdagenci IN crapass.cdagenci%TYPE  --> Codigo Agencia
                                  ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE  --> Numero Caixa
                                  ,pr_tab_erro OUT GENE0001.typ_tab_erro --> Tabela de retorno de erro
                                  ,pr_des_reto OUT VARCHAR2) IS          --> Ind. de retorno OK/NOK

  /* ..........................................................................

     Programa: pc_criticas_rating_fis         Antigo: b1wgen0043.p/criticas_rating_fis
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Odirlei Busana - AMcom
     Data    : Agosto/2014.                          Ultima Atualizacao: 10/05/2016

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  : Tratamento das criticas para o calculo de pessoa fisica.
                 Foi desenvolvido para mostrar todas as criticas do calculo.

     Alteracoes: 27/08/2014 - Convers�o Progress -> Oracle - Odirlei (AMcom)

	             10/05/2016 - Ajuste para utitlizar rowtype locais 
							 (Andrei  - RKAM).

  ............................................................................. */
  --------------- CURSORES  ----------------
    -- verificar conta do associado
    CURSOR cr_crapass IS
      SELECT 1
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%rowtype;

    -- verificar titular da conta do associado
    CURSOR cr_crapttl IS
      SELECT crapttl.vldrendi##1,
             crapttl.vldrendi##2,
             crapttl.vldrendi##3,
             crapttl.vldrendi##4,
             crapttl.vldrendi##5,
             crapttl.vldrendi##6,
             vlsalari
        FROM crapttl
       WHERE crapttl.cdcooper = pr_cdcooper
         AND crapttl.nrdconta = pr_nrdconta
         AND crapttl.idseqttl = 1 ;
    rw_crapttl cr_crapttl%rowtype;

    -- verificar Cadastro de cotas e recursos
    CURSOR cr_crapcot IS
      SELECT 1
        FROM crapcot
       WHERE crapcot.cdcooper = pr_cdcooper
         AND crapcot.nrdconta = pr_nrdconta;
    rw_crapcot cr_crapcot%rowtype;

    -- Buscar os enderecos do cooperado.
    CURSOR cr_crapenc IS
      SELECT incasprp
        FROM crapenc
       WHERE crapenc.cdcooper = pr_cdcooper
         AND crapenc.nrdconta = pr_nrdconta
         AND crapenc.idseqttl = 1
         AND crapenc.tpendass = 10
       ORDER BY cdcooper, nrdconta, idseqttl, cdseqinc desc;
    rw_crapenc cr_crapenc%rowtype;

  --------------- VARIAVEIS ----------------
    -- Descri��o e c�digo da critica
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    -- Exce��o de sa�da
    vr_exc_erro EXCEPTION;
    -- sequencial do erro
    vr_nrsequen NUMBER;
    -- identifica se ja gerou critica 830
    vr_flgcadin BOOLEAN := FALSE;

    rw_crawepr7 cr_crawepr%ROWTYPE;
    rw_crapprp5 cr_crapprp%ROWTYPE;
    rw_craplcr4 cr_craplcr%ROWTYPE;
    rw_craplim5 cr_craplim%ROWTYPE;
    
  BEGIN

    -- Iniciar variaveis
    vr_nrsequen := 0;
    vr_dscritic := null;
    vr_cdcritic := 0;

    -- verificar conta do associado
    OPEN cr_crapass;
    FETCH cr_crapass INTO rw_crapass;
    -- se n�o encontrar gerar critica
    IF cr_crapass%NOTFOUND THEN
      vr_dscritic := null;
      vr_cdcritic := 9; /** Socio nao encontrado **/

      vr_nrsequen := vr_nrsequen + 1;
      -- gerar erro na temptable
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => vr_nrsequen
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);

    END IF;
    CLOSE cr_crapass;

    -- verificar titular da conta do associado
    OPEN cr_crapttl;
    FETCH cr_crapttl INTO rw_crapttl;
    -- se n�o encontrar gerar critica
    IF cr_crapttl%NOTFOUND THEN
      vr_dscritic := null;
      vr_cdcritic := 821; /** Primeiro titular nao cadastrado para a conta. **/

      vr_nrsequen := vr_nrsequen + 1;
      -- gerar erro na temptable
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => vr_nrsequen
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);

    END IF;
    CLOSE cr_crapttl;

    -- verificar Cadastro de cotas e recursos
    OPEN cr_crapcot;
    FETCH cr_crapcot INTO rw_crapcot;
    -- se n�o encontrar gerar critica
    IF cr_crapcot%NOTFOUND THEN
      vr_dscritic := null;
      vr_cdcritic := 169; /** Associado sem registro de cotas **/

      vr_nrsequen := vr_nrsequen + 1;
      -- gerar erro na temptable
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => vr_nrsequen
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);

    END IF;
    CLOSE cr_crapcot;

    -- verificar rendimentos do titular
    IF rw_crapttl.vlsalari    = 0 AND
       rw_crapttl.vldrendi##1 = 0 AND
       rw_crapttl.vldrendi##2 = 0 AND
       rw_crapttl.vldrendi##3 = 0 AND
       rw_crapttl.vldrendi##4 = 0 AND
       rw_crapttl.vldrendi##5 = 0 AND
       rw_crapttl.vldrendi##6 = 0 THEN

      vr_dscritic := null;
      vr_cdcritic := 246; -- Sem rendimento

      vr_nrsequen := vr_nrsequen + 1;
      -- gerar erro na temptable
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => vr_nrsequen
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);

      vr_dscritic := null;
      vr_cdcritic := 830; --* Dados cadastrais inc. *--

      -- flag para marcar que j� gerou critica de dados incompletos
      vr_flgcadin := TRUE;

      vr_nrsequen := vr_nrsequen + 1;
      -- gerar erro na temptable
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => vr_nrsequen
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);

    END IF;

    -- Buscar os enderecos do cooperado.
    OPEN cr_crapenc;
    FETCH cr_crapenc INTO rw_crapenc;
    -- se n�o encontrar gerar critica
    IF cr_crapenc%NOTFOUND THEN
      vr_dscritic := null;
      vr_cdcritic := 247; --* Endereco nao cad. *--

      vr_nrsequen := vr_nrsequen + 1;
      -- gerar erro na temptable
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => vr_nrsequen
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);

      -- se ainda n�o gerou critica de cadastro incompleto
      IF NOT vr_flgcadin THEN
        vr_dscritic := null;
        vr_cdcritic := 830; --* Dados cadastrais inc. *--

        vr_flgcadin := TRUE;
        vr_nrsequen := vr_nrsequen + 1;
        -- gerar erro na temptable
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => vr_nrsequen
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
      END IF;

    ELSE
      IF rw_crapenc.incasprp = 0 THEN --* Cadastrar imovel !! *--

        vr_dscritic := null;
        vr_cdcritic := 926; --* Tela Contas, item Endereco, campo Imovel nao cadastrado. *--

        vr_nrsequen := vr_nrsequen + 1;
        -- gerar erro na temptable
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => vr_nrsequen
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

        -- se ainda n�o gerou critica de cadastro incompleto
        IF NOT vr_flgcadin THEN
          vr_dscritic := null;
          vr_cdcritic := 830; --* Dados cadastrais inc. *--
          vr_flgcadin := TRUE;

          vr_nrsequen := vr_nrsequen + 1;
          -- gerar erro na temptable
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => vr_nrsequen
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
        END IF;
      END IF;
    END IF;
    CLOSE cr_crapenc;

    /* Nao efetuar validacoes quando for calcular soh a nota cooperado */
    IF pr_tpctrrat <> 0 AND
       pr_nrctrrat <> 0 THEN
      /* Para emprestimos */
      IF pr_tpctrrat = 90 THEN
        --ler informa��es do emprestimo
        OPEN cr_crawepr(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrctrato => pr_nrctrrat);
        FETCH cr_crawepr INTO rw_crawepr7;

        -- se localizou
        IF cr_crawepr%NOTFOUND THEN

          --Ler Cadastros de propostas.
          OPEN cr_crapprp(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_tpctrato => pr_tpctrrat
                         ,pr_nrctrato => pr_nrctrrat);
          FETCH cr_crapprp INTO rw_crapprp5;

          IF cr_crapprp%NOTFOUND THEN
            vr_dscritic := null;
            vr_cdcritic := 356; /* Contrato de emprestimo nao encontrado. */

            vr_nrsequen := vr_nrsequen + 1;
            -- gerar erro na temptable
            gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                 ,pr_cdagenci => pr_cdagenci
                                 ,pr_nrdcaixa => pr_nrdcaixa
                                 ,pr_nrsequen => vr_nrsequen
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic
                                 ,pr_tab_erro => pr_tab_erro);
          END IF;
          CLOSE cr_crapprp;

        ELSE

          -- Ler Cadastro de Linhas de Credito
          OPEN cr_craplcr(pr_cdcooper => pr_cdcooper,
                          pr_cdlcremp => rw_crawepr7.cdlcremp);
          FETCH cr_craplcr INTO rw_craplcr4;
          -- se n�o localizou
          IF cr_craplcr%NOTFOUND THEN
            vr_dscritic := null;
            vr_cdcritic := 363; /* Linha nao cadastrada. */

            vr_nrsequen := vr_nrsequen + 1;
            -- gerar erro na temptable
            gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                 ,pr_cdagenci => pr_cdagenci
                                 ,pr_nrdcaixa => pr_nrdcaixa
                                 ,pr_nrsequen => vr_nrsequen
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic
                                 ,pr_tab_erro => pr_tab_erro);
          END IF;

          CLOSE cr_craplcr;
        END IF;
        CLOSE cr_crawepr;

      ELSE /* Demais operacoes */
        -- Ler Contratos de Limite de credito
        OPEN cr_craplim(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_tpctrato => pr_tpctrrat
                       ,pr_nrctrato => pr_nrctrrat);
        FETCH cr_craplim INTO rw_craplim5;

        -- se n�o localizou
        IF cr_craplim%NOTFOUND THEN
          vr_dscritic := null;
          vr_cdcritic := 484; /* Contrato nao encontrado. */

          vr_nrsequen := vr_nrsequen + 1;
          -- gerar erro na temptable
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => vr_nrsequen
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
        END IF;

        CLOSE cr_craplim;

      END IF; -- Fim pr_tpctrrat = 90
    END IF;

    IF pr_tab_erro.COUNT > 0 THEN
      pr_des_reto := 'NOK';
    ELSE
      pr_des_reto := 'OK';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      -- Retorno n�o OK
      pr_des_reto := 'NOK';
      vr_nrsequen := vr_nrsequen + 1;

      -- Montar descri��o de erro n�o tratado
      vr_dscritic := 'Erro n�o tratado na RATI0001.pc_criticas_rating_fis> '||sqlerrm;
      -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => vr_nrsequen
                           ,pr_cdcritic => 0
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);

  END pc_criticas_rating_fis;

  /*****************************************************************************
   Procedure para calcular o risco cooperado para PF.
  *****************************************************************************/
  PROCEDURE pc_risco_cooperado_pf(pr_flgdcalc    IN INTEGER                  --> Indicador de calculo
                                 ,pr_cdcooper    IN crapcop.cdcooper%TYPE    --> Codigo Cooperativa
                                 ,pr_cdagenci    IN crapass.cdagenci%TYPE    --> Codigo Agencia
                                 ,pr_nrdcaixa    IN craperr.nrdcaixa%TYPE    --> Numero Caixa
                                 ,pr_cdoperad    IN crapnrc.cdoperad%TYPE    --> Codigo Operador
                                 ,pr_idorigem    IN INTEGER                  --> Identificador Origem
                                 ,pr_nrdconta    IN crapass.nrdconta%TYPE    --> Numero da Conta
                                 ,pr_idseqttl    IN crapttl.idseqttl%TYPE    --> Sequencial do Titular
                                 ,pr_rw_crapdat  IN btch0001.rw_crapdat%TYPE --> Vetor com dados de par�metro (CRAPDAT)
                                 ,pr_tpctrato    IN crapnrc.tpctrrat%TYPE    --> Tipo Contrato Rating
                                 ,pr_nrctrato    IN crapnrc.nrctrrat%TYPE    --> Numero Contrato Rating
                                 ,pr_inusatab    IN BOOLEAN                  --> Indicador de utiliza��o da tabela de juros
                                 ,pr_flgcriar    IN INTEGER                  --> Indicado se deve criar o rating
                                 ,pr_flgttris    IN BOOLEAN                  --> Indicado se deve carregar toda a crapris
                                 ,pr_tab_crapras IN OUT typ_tab_crapras      --> Tabela com os registros a serem processados
                                 ,pr_notacoop       OUT NUMBER               --> Retorna a nota da classifica��o
                                 ,pr_clascoop       OUT VARCHAR2             --> Retorna classifica��o
                                 ,pr_tab_erro       OUT GENE0001.typ_tab_erro--> Tabela de retorno de erro
                                 ,pr_des_reto       OUT VARCHAR2             --> Ind. de retorno OK/NOK
                                 ) IS

  /* ..........................................................................

     Programa: pc_risco_cooperado_pf         Antigo: b1wgen0043.p/risco_cooperado_pf
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Odirlei Busana - AMcom
     Data    : Agosto/2014.                          Ultima Atualizacao: 10/05/2016

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  : Procedure para calcular o risco cooperado para PF.

     Alteracoes: 27/08/2014 - Convers�o Progress -> Oracle - Odirlei (AMcom)

                 05/11/2014 - Ajuste na procedure para carregar a crapris
                              com a conta a qual esta sendo passada ou
                              tudo na temp table. (Jaison)

	             10/05/2016 - Ajuste para iniciar corretamente a pltable
							  (Andrei - RKAM).
  ............................................................................. */
  ---------------- CURSORES ----------------
    -- verificar conta do associado
    CURSOR cr_crapass IS
      SELECT dtadmiss
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%rowtype;

    -- verificar titular da conta do associado
    CURSOR cr_crapttl IS
      SELECT crapttl.vldrendi##1,
             crapttl.vldrendi##2,
             crapttl.vldrendi##3,
             crapttl.vldrendi##4,
             crapttl.vldrendi##5,
             crapttl.vldrendi##6,
             vlsalari,
             cdnatopc,
             dtadmemp,
             nrinfcad,
             nrpatlvr
        FROM crapttl
       WHERE crapttl.cdcooper = pr_cdcooper
         AND crapttl.nrdconta = pr_nrdconta
         AND crapttl.idseqttl = 1 ;
    rw_crapttl cr_crapttl%rowtype;

    -- verificar Cadastro de cotas e recursos
    CURSOR cr_crapcot IS
      SELECT vldcotas
        FROM crapcot
       WHERE crapcot.cdcooper = pr_cdcooper
         AND crapcot.nrdconta = pr_nrdconta;
    rw_crapcot cr_crapcot%rowtype;

    -- Buscar os enderecos do cooperado.
    CURSOR cr_crapenc IS
      SELECT incasprp
        FROM crapenc
       WHERE crapenc.cdcooper = pr_cdcooper
         AND crapenc.nrdconta = pr_nrdconta
         AND crapenc.idseqttl = 1
         AND crapenc.tpendass = 10
       ORDER BY cdcooper, nrdconta, idseqttl, cdseqinc desc;
    rw_crapenc cr_crapenc%rowtype;

    -- Pegar salario do Conjuge
    CURSOR cr_crapcje (pr_cdcooper IN crapnrc.cdcooper%type
                      ,pr_nrdconta IN crapnrc.nrdconta%type) IS
      SELECT nvl(sum(nvl(vlsalari,0)),0) vlsalari
        FROM crapcje
       WHERE crapcje.cdcooper = pr_cdcooper
         AND crapcje.nrdconta = pr_nrdconta
         AND crapcje.idseqttl = 1;
    rw_crapcje cr_crapcje%rowtype;

    -- Valores das notas PF
    vr_vet_nota_001 typ_vet_nota3 := typ_vet_nota3(7,14,21);
    vr_vet_nota_002 typ_vet_nota3 := typ_vet_nota3(10,20,30);
    vr_vet_nota_003 typ_vet_nota3 := typ_vet_nota3(3,6,9);
    vr_vet_nota_004 typ_vet_nota4 := typ_vet_nota4(20,40,60,80);
    vr_vet_nota_005 typ_vet_nota4 := typ_vet_nota4(5,10,15,15);
    vr_vet_nota_006 typ_vet_nota4 := typ_vet_nota4(3,6,9,12);
    vr_vet_nota_007 typ_vet_nota3 := typ_vet_nota3(15,30,45);
    vr_vet_nota_008 typ_vet_nota4 := typ_vet_nota4(3,6,9,9);
    vr_vet_nota_009 typ_vet_nota3 := typ_vet_nota3(10,20,30);
    vr_vet_nota_010 typ_vet_nota4 := typ_vet_nota4(3,6,9,12);

  --------------- VARIAVEIS ----------------
    -- Descri��o e c�digo da critica
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    -- Exce��o de sa�da
    vr_exc_erro EXCEPTION;
    -- indicador se encontrou registro
    vr_fcrawepr  BOOLEAN := FALSE;
    vr_fcrapprp  BOOLEAN := FALSE;
    vr_fcraplim  BOOLEAN := FALSE;
    --qtd de ano do associado na cooperativa
    vr_anodcoop  NUMBER;
    vr_anodexpe  NUMBER;
    vr_nrseqite  NUMBER;
    -- Valor da nota
    vr_vldanota  NUMBER := 0;
    -- quantidade de dias de atraso
    vr_qtdiaatr NUMBER;
    vr_idx      VARCHAR2(50);
    --vetor de contrato
    vr_vet_nrctrliq typ_vet_nrctrliq := typ_vet_nrctrliq(0,0,0,0,0,0,0,0,0,0);
    -- tabela de central de risco
    vr_tab_central_risco risc0001.typ_reg_central_risco;
    -- Valor da presta��o
    vr_vlpresta NUMBER;
    -- Valor total de presta��o
    vr_vltotpre NUMBER;
    -- Valor de salario
    vr_vlsalari NUMBER;
    -- lista de contratos
    vr_dsliquid VARCHAR2(2000);
    -- valor utilizado
    vr_vlutiliz NUMBER;
    -- valor endividamento
    vr_vlendivi NUMBER;
    vr_vlendiv2 NUMBER;
    -- indice da temptable
    vr_index varchar2(100);
    vr_cdcooper crapass.cdcooper%TYPE;
    vr_nrdconta crapass.nrdconta%TYPE;

    rw_crawepr8 cr_crawepr%ROWTYPE;
    rw_crapepr2 cr_crapepr%ROWTYPE;
    rw_crapprp6 cr_crapprp%ROWTYPE;
    rw_craplcr5 cr_craplcr%ROWTYPE;
    rw_craplim6 cr_craplim%ROWTYPE;
    rw_crapnrc2 cr_crapnrc%ROWTYPE;

  BEGIN

    -- gera criticas rating
    pc_criticas_rating_fis ( pr_cdcooper => pr_cdcooper   --> Codigo Cooperativa
                            ,pr_nrdconta => pr_nrdconta   --> Numero da Conta
                            ,pr_tpctrrat => pr_tpctrato   --> Tipo Contrato Rating
                            ,pr_nrctrrat => pr_nrctrato   --> Numero Contrato Rating
                            ,pr_cdagenci => pr_cdagenci   --> Codigo Agencia
                            ,pr_nrdcaixa => pr_nrdcaixa   --> Numero Caixa
                            ,pr_tab_erro => pr_tab_erro   --> Tabela de retorno de erro
                            ,pr_des_reto => pr_des_reto); --> Ind. de retorno OK/NOK


    -- se retornou critica, abortar rotina
    IF pr_des_reto <> 'OK' THEN
      RETURN;
    END IF;

    -- verificar conta do associado
    OPEN cr_crapass;
    FETCH cr_crapass INTO rw_crapass;
    CLOSE cr_crapass;

    -- verificar titular da conta do associado
    OPEN cr_crapttl;
    FETCH cr_crapttl INTO rw_crapttl;
    CLOSE cr_crapttl;

    -- Buscar os enderecos do cooperado.
    OPEN cr_crapenc;
    FETCH cr_crapenc INTO rw_crapenc;
    CLOSE cr_crapenc;

    /* Para Risco Cooperado o calculo eh diferenciado */
    IF pr_tpctrato <> 0  AND
       pr_nrctrato <> 0  THEN
      /* REGISTROS NECESSARIOS */
      IF pr_tpctrato = 90   THEN  /* Emprestimo/Financiamento */

        --ler informa��es do emprestimo
        OPEN cr_crawepr(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrctrato => pr_nrctrato);
        FETCH cr_crawepr INTO rw_crawepr8;
        -- se localizou
        IF cr_crawepr%FOUND THEN
          vr_fcrawepr := TRUE;

          -- Ler Cadastro de Linhas de Credito
          OPEN cr_craplcr(pr_cdcooper => pr_cdcooper,
                          pr_cdlcremp => rw_crawepr8.cdlcremp);
          FETCH cr_craplcr INTO rw_craplcr5;
          close cr_craplcr;
        END IF;
        CLOSE cr_crawepr;

        --Ler Cadastros de propostas.
        OPEN cr_crapprp(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_tpctrato => pr_tpctrato
                       ,pr_nrctrato => pr_nrctrato);
        FETCH cr_crapprp INTO rw_crapprp6;
        vr_fcrapprp := cr_crapprp%found;

        CLOSE cr_crapprp;


      ELSE
        -- Ler Contratos de Limite de credito
        OPEN cr_craplim(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_tpctrato => pr_tpctrato
                       ,pr_nrctrato => pr_nrctrato);
        FETCH cr_craplim INTO rw_craplim6;
        vr_fcraplim := cr_craplim%found;
        CLOSE cr_craplim;
      END IF;

    END IF;

    /*************************************************************************
     Item 1_1 - Quanto tempo o associado opera com a Cooperativa. Anos exatos
    *************************************************************************/

    -- calcular a qtd de anos do associado na cooperativa
    vr_anodcoop := ((pr_rw_crapdat.dtmvtolt - rw_crapass.dtadmiss) / 365);

    IF vr_anodcoop > 3    THEN
      vr_nrseqite := 1;
    ELSIF vr_anodcoop  >= 1  THEN
      vr_nrseqite := 2;
    ELSE
      vr_nrseqite := 3;
    END IF;

    -- verificar se deve calcular
    IF pr_flgdcalc = 1 THEN
      vr_vldanota := vr_vldanota + vr_vet_nota_001(vr_nrseqite);
    ELSE

      -- Gravar itens do rating na crapras
      pc_grava_item_rating ( pr_cdcooper => pr_cdcooper             --Codigo Cooperativa
                            ,pr_nrdconta => pr_nrdconta             --Numero da Conta
                            ,pr_tpctrato => pr_tpctrato             --Tipo Contrato Rating
                            ,pr_nrctrato => pr_nrctrato             --Numero Contrato Rating
                            ,pr_nrtopico => 1                       --Numero do topico
                            ,pr_nritetop => 1                       --Numero Contrato Rating
                            ,pr_nrseqite => vr_nrseqite             --Numero Contrato Rating
                            ,pr_flgcriar => pr_flgcriar             -- Indicado se deve criar o rating
                            ,pr_tab_crapras => pr_tab_crapras       --
                            ,pr_dscritic    => vr_dscritic);        -- Descricao do erro

      -- Se retornou erro, deve abortar
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END IF;

    ---------------------------------------------
    -- Item 1_2 - Comportamento nas operacoes. --
    ---------------------------------------------
    --Pegar o registro com mais dias de atrasos - Modalidade emprestimo dos ultimos 12 meses

    -- Caso seja para carregar toda a crapris numa temp table para performance
    IF pr_flgttris THEN

      -- verificar se temptable esta vazia
      IF vr_tab_crapris_qtdiaatr.COUNT = 0 THEN
        pc_carrega_temp_qtdiaatr(pr_dtmvtolt => pr_rw_crapdat.dtmvtolt);
      END IF;

      -- definir index
      vr_idx := lpad(pr_cdcooper,10,'0')||lpad(pr_nrdconta,10,'0');
      -- se localizar deve utilizar essa qtd
      IF vr_tab_crapris_qtdiaatr.exists(vr_idx) and
         vr_tab_crapris_qtdiaatr(vr_idx).qtdiaatr > 0 THEN
        vr_qtdiaatr := vr_tab_crapris_qtdiaatr(vr_idx).qtdiaatr;
      ELSE
        -- senao atribuir zero
        vr_qtdiaatr := 0;
      END IF;

    ELSE

      -- Busca apenas o Risco da conta em questao
      OPEN cr_crapris(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt);
      FETCH cr_crapris
       INTO vr_cdcooper
           ,vr_nrdconta
           ,vr_qtdiaatr;
      CLOSE cr_crapris;

    END IF;


    -- Testar range
    IF nvl(vr_qtdiaatr,0) = 0 THEN
      vr_nrseqite := 1;  /* Sem atrasos  */
    ELSIF vr_qtdiaatr <= 60   THEN
      vr_nrseqite := 2;  /* Atraso no maximo 60 dias */
    /* Inclusive 0 (zero) dias */
    ELSE
      vr_nrseqite := 3;  /* Atraso acima de 60 dias  */
    END IF;

    IF pr_tpctrato = 90  THEN  /* Emprestimo / Financiamento */
      IF vr_fcrawepr AND
         rw_crawepr8.idquapro = 3   THEN  /* Renegociacao */
        vr_nrseqite := 3;
      END IF;
    END IF;

    IF pr_flgdcalc = 1 THEN
      vr_vldanota := vr_vldanota + vr_vet_nota_002(vr_nrseqite);



    ELSE
      -- Gravar itens do rating na crapras
      pc_grava_item_rating ( pr_cdcooper => pr_cdcooper             --Codigo Cooperativa
                            ,pr_nrdconta => pr_nrdconta             --Numero da Conta
                            ,pr_tpctrato => pr_tpctrato             --Tipo Contrato Rating
                            ,pr_nrctrato => pr_nrctrato             --Numero Contrato Rating
                            ,pr_nrtopico => 1                       --Numero do topico
                            ,pr_nritetop => 2                       --Numero Contrato Rating
                            ,pr_nrseqite => vr_nrseqite             --Numero Contrato Rating
                            ,pr_flgcriar => pr_flgcriar             -- Indicado se deve criar o rating
                            ,pr_tab_crapras => pr_tab_crapras       --
                            ,pr_dscritic    => vr_dscritic);        -- Descricao do erro

      -- Se retornou erro, deve abortar
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END IF;

    -------------------------------------------------------------
    -- Item 1_3 - Tempo de experiencia na atividade (Emprego). --
    -------------------------------------------------------------
    IF rw_crapttl.cdnatopc = 8   THEN  -- Aposentado
      vr_nrseqite := 1;
    ELSIF rw_crapttl.dtadmemp IS NULL THEN  -- Sem experiencia
      vr_nrseqite := 3; -- Considera como ate 1 ano
    ELSE
      -- Classifica por anos de experiencia
      vr_anodexpe := ((pr_rw_crapdat.dtmvtolt - rw_crapttl.dtadmemp) / 365);

      IF vr_anodexpe > 3    THEN
        vr_nrseqite := 1;
      ELSIF vr_anodexpe  > 1  THEN
        vr_nrseqite := 2;
      ELSE
        vr_nrseqite := 3;
      END IF;
    END IF;

    IF pr_flgdcalc = 1 THEN
      vr_vldanota := vr_vldanota + vr_vet_nota_003(vr_nrseqite);
    ELSE
      -- Gravar itens do rating na crapras
      pc_grava_item_rating ( pr_cdcooper => pr_cdcooper             --Codigo Cooperativa
                            ,pr_nrdconta => pr_nrdconta             --Numero da Conta
                            ,pr_tpctrato => pr_tpctrato             --Tipo Contrato Rating
                            ,pr_nrctrato => pr_nrctrato             --Numero Contrato Rating
                            ,pr_nrtopico => 1                       --Numero do topico
                            ,pr_nritetop => 3                       --Numero Contrato Rating
                            ,pr_nrseqite => vr_nrseqite             --Numero Contrato Rating
                            ,pr_flgcriar => pr_flgcriar             -- Indicado se deve criar o rating
                            ,pr_tab_crapras => pr_tab_crapras       --
                            ,pr_dscritic    => vr_dscritic);        -- Descricao do erro

      -- Se retornou erro, deve abortar
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END IF;

    -------------------------------------------------------------------------
    -- Item 1_4 - Item Consultas Cadastrais - EXTERNAS (dados da proposta) --
    -------------------------------------------------------------------------
    IF pr_flgdcalc = 1 THEN
       IF rw_crapttl.nrinfcad > 0 THEN
         vr_nrseqite := rw_crapttl.nrinfcad;
       ELSE
         vr_nrseqite := 1;
       END IF;

       vr_vldanota := vr_vldanota + vr_vet_nota_004(vr_nrseqite);
    ELSE
      --Selecionar rating
      OPEN cr_crapnrc (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_tpctrrat => pr_tpctrato
                      ,pr_nrctrrat => pr_nrctrato);
      --Posicionar no proximo registro
      FETCH cr_crapnrc INTO rw_crapnrc2;
      -- Se ja existe , entao pegar do cadastro
      IF cr_crapnrc%FOUND THEN
        vr_nrseqite := rw_crapttl.nrinfcad;

      ELSE  -- Senao da proposta
        IF pr_tpctrato <> 0  THEN
          IF pr_tpctrato = 90   THEN  -- Emprestimo / Finaciamento
            IF vr_fcrapprp  THEN
              vr_nrseqite := rw_crapprp6.nrinfcad;
            END IF;
          ELSE                        -- Cheque especial / Descontos
            IF vr_fcraplim  THEN
              vr_nrseqite := rw_craplim6.nrinfcad;
            END IF;
          END IF;
        END IF;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapnrc;

      -- Gravar itens do rating na crapras
      pc_grava_item_rating ( pr_cdcooper => pr_cdcooper             --Codigo Cooperativa
                            ,pr_nrdconta => pr_nrdconta             --Numero da Conta
                            ,pr_tpctrato => pr_tpctrato             --Tipo Contrato Rating
                            ,pr_nrctrato => pr_nrctrato             --Numero Contrato Rating
                            ,pr_nrtopico => 1                       --Numero do topico
                            ,pr_nritetop => 4                       --Numero Contrato Rating
                            ,pr_nrseqite => vr_nrseqite             --Numero Contrato Rating
                            ,pr_flgcriar => pr_flgcriar             -- Indicado se deve criar o rating
                            ,pr_tab_crapras => pr_tab_crapras       --
                            ,pr_dscritic    => vr_dscritic);        -- Descricao do erro

      -- Se retornou erro, deve abortar
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END IF;

    -------------------------------------------------------------------
    -- Item 1_5 - Item do Historico do cooperado - Ultimos 12 meses. --
    -------------------------------------------------------------------

    pc_historico_cooperado ( pr_cdcooper => pr_cdcooper  --> Codigo Cooperativa
                            ,pr_cdoperad => pr_cdoperad  --> Codigo Operador
                            ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt  --> Data do movimento
                            ,pr_nrdconta => pr_nrdconta  --> Numero da Conta
                            ,pr_idorigem => pr_idorigem  --> Identificador Origem
                            ,pr_idseqttl => pr_idseqttl  --> Sequencial do Titular
                            ,pr_nrseqite => vr_nrseqite  --> sequencial do item do risco
                            ,pr_dscritic => vr_dscritic);--> Descricao do erro
    IF vr_dscritic IS NOT NULL THEN
      raise vr_exc_erro;
    END IF;

    IF pr_flgdcalc = 1 THEN
      vr_vldanota := vr_vldanota + vr_vet_nota_005(vr_nrseqite);
    ELSE
      -- Gravar itens do rating na crapras
      pc_grava_item_rating ( pr_cdcooper => pr_cdcooper             --Codigo Cooperativa
                            ,pr_nrdconta => pr_nrdconta             --Numero da Conta
                            ,pr_tpctrato => pr_tpctrato             --Tipo Contrato Rating
                            ,pr_nrctrato => pr_nrctrato             --Numero Contrato Rating
                            ,pr_nrtopico => 1                       --Numero do topico
                            ,pr_nritetop => 5                       --Numero Contrato Rating
                            ,pr_nrseqite => vr_nrseqite             --Numero Contrato Rating
                            ,pr_flgcriar => pr_flgcriar             -- Indicado se deve criar o rating
                            ,pr_tab_crapras => pr_tab_crapras       --
                            ,pr_dscritic    => vr_dscritic);        -- Descricao do erro

      -- Se retornou erro, deve abortar
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END IF;

    -------------------------------------------------------------------
    --               Item 1_6 - Tipo de residencia.                  --
    -------------------------------------------------------------------
    CASE rw_crapenc.incasprp
        WHEN 1  THEN vr_nrseqite := 1;  -- Quitado
        WHEN 2  THEN vr_nrseqite := 2;  -- Financiado
        WHEN 4  THEN vr_nrseqite := 3;  -- Familiar
        WHEN 5  THEN vr_nrseqite := 3;  -- Cedido
        WHEN 3  THEN vr_nrseqite := 4;  --  Alugado
    END CASE;

    IF pr_flgdcalc = 1 THEN
      vr_vldanota := vr_vldanota + vr_vet_nota_006(vr_nrseqite);
    ELSE
      -- Gravar itens do rating na crapras
      pc_grava_item_rating ( pr_cdcooper => pr_cdcooper             --Codigo Cooperativa
                            ,pr_nrdconta => pr_nrdconta             --Numero da Conta
                            ,pr_tpctrato => pr_tpctrato             --Tipo Contrato Rating
                            ,pr_nrctrato => pr_nrctrato             --Numero Contrato Rating
                            ,pr_nrtopico => 1                       --Numero do topico
                            ,pr_nritetop => 6                       --Numero Contrato Rating
                            ,pr_nrseqite => vr_nrseqite             --Numero Contrato Rating
                            ,pr_flgcriar => pr_flgcriar             -- Indicado se deve criar o rating
                            ,pr_tab_crapras => pr_tab_crapras       --
                            ,pr_dscritic    => vr_dscritic);        -- Descricao do erro

      -- Se retornou erro, deve abortar
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END IF;

    -------------------------------------------------------------------
    -- Item 3_1 - Nivel de comprometimento. (Parcelas versus renda bruta) Passou para 1_7 --
    -------------------------------------------------------------------
    IF pr_tpctrato = 90  THEN
      IF vr_fcrawepr THEN
        vr_vlpresta := rw_crawepr8.vlpreemp;

         -- Contratos que ele esta liquidando
         vr_vet_nrctrliq(1)  := rw_crawepr8.nrctrliq##1;
         vr_vet_nrctrliq(2)  := rw_crawepr8.nrctrliq##2;
         vr_vet_nrctrliq(3)  := rw_crawepr8.nrctrliq##3;
         vr_vet_nrctrliq(4)  := rw_crawepr8.nrctrliq##4;
         vr_vet_nrctrliq(5)  := rw_crawepr8.nrctrliq##5;
         vr_vet_nrctrliq(6)  := rw_crawepr8.nrctrliq##6;
         vr_vet_nrctrliq(7)  := rw_crawepr8.nrctrliq##7;
         vr_vet_nrctrliq(8)  := rw_crawepr8.nrctrliq##8;
         vr_vet_nrctrliq(9)  := rw_crawepr8.nrctrliq##9;
         vr_vet_nrctrliq(10) := rw_crawepr8.nrctrliq##10;

      -- Operacao BNDES
      ELSIF vr_fcrapprp THEN
        vr_vlpresta := nvl(rw_crapprp6.vlctrbnd,0) / nvl(rw_crapprp6.qtparbnd,0);
      END IF;
    ELSIF pr_tpctrato <> 0 THEN
      vr_vlpresta := rw_craplim6.vllimite;
    ELSE
      vr_vlpresta := 0;
    END IF;

    -- calcular nivel de comprometimento
    pc_nivel_comprometimento(pr_cdcooper     => pr_cdcooper     --> Cooperativa conectada
                            ,pr_cdoperad     => pr_cdoperad     --> Operador conectado
                            ,pr_idseqttl     => pr_idseqttl     --> Sequencia do titular
                            ,pr_idorigem     => pr_idorigem     --> Origem da requisi��o
                            ,pr_nrdconta     => pr_nrdconta     --> Conta do associado
                            ,pr_tpctrato     => pr_tpctrato     --> Tipo do Rating
                            ,pr_nrctrato     => pr_nrctrato     --> N�mero do contrato de Rating
                            ,pr_vet_nrctrliq => vr_vet_nrctrliq --> Vetor de contratos a liquidar
                            ,pr_vlpreemp     => vr_vlpresta     --> Valor da parcela
                            ,pr_rw_crapdat   => pr_rw_crapdat   --> Calend�rio do movimento atual
                            ,pr_flgdcalc     => pr_flgdcalc     --> Flag para calcular sim ou n�o
                            ,pr_inusatab     => pr_inusatab     --> Indicador de utiliza��o da tabela de juros
                            ,pr_vltotpre     => vr_vltotpre     --> Valor calculado da presta��o
                            ,pr_dscritic     => vr_dscritic);
    -- Se retornou erro, deve abortar
    IF nvl(vr_cdcritic,0) > 0 THEN
      RAISE vr_exc_erro;
    END IF;

    --Pegar salario do Conjuge
    OPEN cr_crapcje (pr_cdcooper => pr_cdcooper
                    ,pr_nrdconta => pr_nrdconta);
    --Posicionar no proximo registro
    FETCH cr_crapcje INTO rw_crapcje;
    -- Se ja existe , entao pegar do cadastro
    IF cr_crapcje%FOUND THEN
      vr_vlsalari := rw_crapcje.vlsalari;
    END IF;

    /* Dividir pelo ( salario + rendimentos + Salario conjuge ) */
    vr_vltotpre := nvl(vr_vltotpre,0) /
                  (rw_crapttl.vlsalari +
                   rw_crapttl.vldrendi##1 + rw_crapttl.vldrendi##2 +
                   rw_crapttl.vldrendi##3 + rw_crapttl.vldrendi##4 +
                   rw_crapttl.vldrendi##5 + rw_crapttl.vldrendi##6 +
                   nvl(vr_vlsalari,0));

    IF vr_vltotpre <= 0.20 THEN /* Ate 20% */
      vr_nrseqite := 1;
    ELSIF vr_vltotpre <= 0.30 THEN /* Ate 30 % */
      vr_nrseqite := 2;
    ELSE
      vr_nrseqite := 3;  /* Mais do que 30 % */
    END IF;

    IF pr_flgdcalc = 1 THEN
      vr_vldanota := vr_vldanota + vr_vet_nota_007(vr_nrseqite);
    ELSE
      -- Gravar itens do rating na crapras
      pc_grava_item_rating ( pr_cdcooper => pr_cdcooper             --Codigo Cooperativa
                            ,pr_nrdconta => pr_nrdconta             --Numero da Conta
                            ,pr_tpctrato => pr_tpctrato             --Tipo Contrato Rating
                            ,pr_nrctrato => pr_nrctrato             --Numero Contrato Rating
                            ,pr_nrtopico => 1                       --Numero do topico
                            ,pr_nritetop => 7                       --Numero Contrato Rating
                            ,pr_nrseqite => vr_nrseqite             --Numero Contrato Rating
                            ,pr_flgcriar => pr_flgcriar             -- Indicado se deve criar o rating
                            ,pr_tab_crapras => pr_tab_crapras       --
                            ,pr_dscritic    => vr_dscritic);        -- Descricao do erro
      -- Se retornou erro, deve abortar
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END IF;

    ----------------------------------------------------------------------
    -- Item 3_2 - Patrimonio pessoal livre em relacao ao endividamento. --
    -- Passou para 1_8                                                  --
    ----------------------------------------------------------------------

    IF pr_flgdcalc = 1 THEN
      IF rw_crapttl.nrpatlvr > 0 THEN
        vr_nrseqite := rw_crapttl.nrpatlvr;
      ELSE
        vr_nrseqite := 3;
      END IF;

      vr_vldanota := vr_vldanota + vr_vet_nota_008(vr_nrseqite);
    ELSE
      --Selecionar rating
      OPEN cr_crapnrc (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_tpctrrat => pr_tpctrato
                      ,pr_nrctrrat => pr_nrctrato);
      --Posicionar no proximo registro
      FETCH cr_crapnrc INTO rw_crapnrc2;
      -- Se ja existe , entao pegar do cadastro
      IF cr_crapnrc%FOUND THEN
        vr_nrseqite := rw_crapttl.nrpatlvr;
      ELSE
        IF pr_tpctrato = 90 THEN
          vr_nrseqite := rw_crapprp6.nrpatlvr;
        ELSIF pr_tpctrato <> 0  THEN
          vr_nrseqite := rw_craplim6.nrpatlvr;
        ELSE
          vr_nrseqite := 1;
        END IF;
      END IF;
      CLOSE cr_crapnrc;

      -- Gravar itens do rating na crapras
      pc_grava_item_rating ( pr_cdcooper => pr_cdcooper             --Codigo Cooperativa
                            ,pr_nrdconta => pr_nrdconta             --Numero da Conta
                            ,pr_tpctrato => pr_tpctrato             --Tipo Contrato Rating
                            ,pr_nrctrato => pr_nrctrato             --Numero Contrato Rating
                            ,pr_nrtopico => 1                       --Numero do topico
                            ,pr_nritetop => 8                       --Numero Contrato Rating
                            ,pr_nrseqite => vr_nrseqite             --Numero Contrato Rating
                            ,pr_flgcriar => pr_flgcriar             -- Indicado se deve criar o rating
                            ,pr_tab_crapras => pr_tab_crapras       --
                            ,pr_dscritic    => vr_dscritic);        -- Descricao do erro

      -- Se retornou erro, deve abortar
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

    END IF;

    ----------------------------------------------------------------------
    -- Item 3_3 - Endividamento total em relacao a renda bruta.         --
    -- Passou para 1_9                                                  --
    ----------------------------------------------------------------------

    IF pr_tpctrato = 90 AND vr_fcrawepr THEN
      vr_dsliquid := fn_traz_liquidacoes(rw_crawepr8);
    END IF;

    -- Buscar o saldo utilizado pelo Cooperado
    pc_calcula_endividamento(pr_cdcooper   => pr_cdcooper     --> C�digo da Cooperativa
                            ,pr_cdagenci   => pr_cdagenci     --> C�digo da ag�ncia
                            ,pr_nrdcaixa   => pr_nrdcaixa     --> N�mero do caixa
                            ,pr_cdoperad   => pr_cdoperad     --> C�digo do operador
                            ,pr_rw_crapdat => pr_rw_crapdat   --> Vetor com dados de par�metro (CRAPDAT)
                            ,pr_nrdconta   => pr_nrdconta     --> Conta do associado
                            ,pr_dsliquid   => vr_dsliquid     --> Lista de contratos a liquidar
                            ,pr_idseqttl   => pr_idseqttl     --> Sequencia de titularidade da conta
                            ,pr_idorigem   => pr_idorigem     --> Indicador da origem da chamada
                            ,pr_inusatab   => pr_inusatab     --> Indicador de utiliza��o da tabela de juros
                            ,pr_vlutiliz   => vr_vlutiliz     --> Valor da d�vida
                            ,pr_cdcritic   => vr_cdcritic     --> Critica encontrada no processo
                            ,pr_dscritic   => vr_dscritic);   --> Sa�da de erro
    -- Se houve erro
    IF vr_cdcritic IS NOT NULL OR trim(vr_dscritic) IS NOT NULL THEN
      -- Encerrar o processo
      RAISE vr_exc_erro;
    END IF;

    -- No caso de proposta, somar valor de operacao corrente
    -- Quando emprestimo ou Cheque especial.
    -- Desconto de cheque e titulo nao sao considerados
    -- no saldo_utiliza do cooperado (Valor limite)

    IF pr_tpctrato = 90  THEN /* Emprestimo / Financiamento */

      --ler informa��es do emprestimo
      OPEN cr_crapepr(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctrato => pr_nrctrato);
      FETCH cr_crapepr INTO rw_crapepr2;
      -- se n�o localizou
      IF cr_crapepr%NOTFOUND THEN
        IF vr_fcrawepr THEN
          vr_vlendivi := rw_crawepr8.vlemprst;
        ELSE
          vr_vlendivi := rw_crapprp6.vlctrbnd;
        END IF;
      END IF;
      CLOSE cr_crapepr;

      IF rw_crapprp6.vltotsfn <> 0 THEN
        vr_vlendivi := nvl(vr_vlendivi,0) + rw_crapprp6.vltotsfn;
      ELSE
        vr_vlendivi := nvl(vr_vlendivi,0) + nvl(vr_vlutiliz,0);
      END IF;

    /* Desconto / Cheque especial */
    ELSIF pr_tpctrato <> 0  THEN
      IF pr_tpctrato = 1 THEN /* Ch. Especial */
        IF rw_craplim6.insitlim <> 2  THEN /* Diferente de ativo */
          vr_vlendivi := rw_craplim6.vllimite;
        END IF;

        IF rw_craplim6.vltotsfn <> 0  THEN
          vr_vlendivi := nvl(vr_vlendivi,0) + nvl(rw_craplim6.vltotsfn,0);
        ELSE
          vr_vlendivi := nvl(vr_vlendivi,0) + nvl(vr_vlutiliz,0);
        END IF;
      END IF;
      
      RISC0001.pc_obtem_valores_central_risco( pr_cdcooper => pr_cdcooper  --> Codigo Cooperativa
                                                ,pr_cdagenci => pr_cdagenci  --> Codigo Agencia
                                                ,pr_nrdcaixa => pr_nrdcaixa  --> Numero Caixa
                                                ,pr_nrdconta => pr_nrdconta  --> Numero da Conta
                                                ,pr_nrcpfcgc => 0  -- CPF    --> CPF/CGC do associado
                                                ,pr_tab_central_risco => vr_tab_central_risco --> Informa��es da Central de Risco
                                                ,pr_tab_erro => pr_tab_erro  --> Tabela Erro
                                                ,pr_des_reto => pr_des_reto);
      IF pr_des_reto <> 'OK' THEN
        RETURN;
      END IF;
        
      -- se possuir valor, somar valor valor
      IF NVL(vr_tab_central_risco.vltotsfn,0) <> 0  THEN
        vr_vlendivi := nvl(vr_vlendivi,0) + vr_tab_central_risco.vltotsfn;
      END IF;
    ELSE
      IF pr_flgdcalc = 1 THEN
        -- Obter os dados do banco cetral para analise da proposta, consulta de SCR. (Tela CONSCR)
        RISC0001.pc_obtem_valores_central_risco( pr_cdcooper => pr_cdcooper  --> Codigo Cooperativa
                                                ,pr_cdagenci => pr_cdagenci  --> Codigo Agencia
                                                ,pr_nrdcaixa => pr_nrdcaixa  --> Numero Caixa
                                                ,pr_nrdconta => pr_nrdconta  --> Numero da Conta
                                                ,pr_nrcpfcgc => 0  -- CPF    --> CPF/CGC do associado
                                                ,pr_tab_central_risco => vr_tab_central_risco --> Informa��es da Central de Risco
                                                ,pr_tab_erro => pr_tab_erro  --> Tabela Erro
                                                ,pr_des_reto => pr_des_reto);
        IF pr_des_reto <> 'OK' THEN
          RETURN;
        END IF;
        
        -- se possuir valor, somar valor valor
        IF NVL(vr_tab_central_risco.vltotsfn,0) <> 0  THEN
          vr_vlendivi := nvl(vr_vlendivi,0) + vr_tab_central_risco.vltotsfn;
        ELSE 
          -- Usar valor j� calculado
          vr_vlendivi := nvl(vr_vlendivi,0) + nvl(vr_vlutiliz,0);
        END IF;
        /*-- Buscar primeiro registro      -- Alterado por: Renato Darosci - Supero - 30/04/2015
                                                  N�o utilizar mais tabela de mem�ria, apenas um record.
        vr_index := vr_tab_central_risco.first;
        -- verificar se existe
        IF vr_tab_central_risco.EXISTS(vr_index) THEN
          -- se possuir valor, somar valor valor
          IF vr_tab_central_risco(vr_index).vltotsfn <> 0  THEN
            vr_vlendivi := nvl(vr_vlendivi,0) + vr_tab_central_risco(vr_index).vltotsfn;
          ELSE
            vr_vlendivi := nvl(vr_vlendivi,0) + nvl(vr_vlutiliz,0);
          END IF;
        ELSE
          vr_vlendivi := nvl(vr_vlendivi,0) + nvl(vr_vlutiliz,0);
        END IF;*/

      ELSE
        vr_vlendivi := 0;
      END IF;
    END IF;

    /* Dividir pelo salario mais os rendimentos */
    vr_vlendivi := (vr_vlendivi /
                   (rw_crapttl.vlsalari     + rw_crapttl.vldrendi##1 +
                    rw_crapttl.vldrendi##2 + rw_crapttl.vldrendi##3 +
                    rw_crapttl.vldrendi##4 + rw_crapttl.vldrendi##5 +
                    rw_crapttl.vldrendi##6 + nvl(vr_vlsalari,0)));

    IF vr_vlendivi <= 7 THEN
      vr_nrseqite := 1;
    ELSIF  vr_vlendivi <= 14 THEN
      vr_nrseqite := 2;
    ELSE
      vr_nrseqite := 3;
    END IF;

    IF pr_flgdcalc = 1 THEN
       vr_vldanota := vr_vldanota + vr_vet_nota_009(vr_nrseqite);
    ELSE
      -- Gravar itens do rating na crapras
      pc_grava_item_rating ( pr_cdcooper => pr_cdcooper             --Codigo Cooperativa
                            ,pr_nrdconta => pr_nrdconta             --Numero da Conta
                            ,pr_tpctrato => pr_tpctrato             --Tipo Contrato Rating
                            ,pr_nrctrato => pr_nrctrato             --Numero Contrato Rating
                            ,pr_nrtopico => 1                       --Numero do topico
                            ,pr_nritetop => 9                       --Numero Contrato Rating
                            ,pr_nrseqite => vr_nrseqite             --Numero Contrato Rating
                            ,pr_flgcriar => pr_flgcriar             -- Indicado se deve criar o rating
                            ,pr_tab_crapras => pr_tab_crapras       --
                            ,pr_dscritic    => vr_dscritic);        -- Descricao do erro

      -- Se retornou erro, deve abortar
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END IF;


    ----------------------------------------------------------------------
    --   Item 3_4 - Total de endividamento na cooperativa.              --
    --   Passou 1_10                                                    --
    ----------------------------------------------------------------------
    -- verificar Cadastro de cotas e recursos
    OPEN cr_crapcot;
    FETCH cr_crapcot INTO rw_crapcot;
    CLOSE cr_crapcot;

    /* Se esta efetivando, ele ja considera esta operacao.

       No caso de proposta, somar valor de operacao
       Quando emprestimo ou Cheque especial.

       Desconto de cheque e titulo nao sao considerados
       no saldo_utiliza do cooperado (Valor limite) */

    vr_vlendivi := vr_vlutiliz;

    IF pr_tpctrato = 90  THEN
      --ler informa��es do emprestimo
      OPEN cr_crapepr(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctrato => pr_nrctrato);
      FETCH cr_crapepr INTO rw_crapepr2;
      -- se n�o localizou
      IF cr_crapepr%NOTFOUND THEN
        IF vr_fcrawepr THEN
          vr_vlendivi := rw_crawepr8.vlemprst;
        ELSE
          vr_vlendivi := rw_crapprp6.vlctrbnd;
        END IF;
      END IF;
      CLOSE cr_crapepr;
    ELSIF pr_tpctrato = 1 THEN /* Ch. Especial */
      IF rw_craplim6.insitlim <> 2  THEN /* Diferente de ativo */
        vr_vlendivi := nvl(vr_vlendivi,0) + nvl(rw_craplim6.vllimite,0);
      END IF;

    -- se n�o foi passado tipo de contrado e n�o calcular
    ELSIF pr_tpctrato = 0 AND
          pr_flgdcalc = 0  THEN
      vr_vlendivi := 0;
    END IF;

    --* aux_vlutiliz vem do saldo utiliza. Dividir pelas cotas *--
    IF rw_crapcot.vldcotas = 0 THEN -- Tratar divisor zero
      vr_vlendiv2 := NULL;
    ELSE
      vr_vlendiv2 := (nvl(vr_vlendivi,0) / rw_crapcot.vldcotas);
    END IF;
    -- * Se sem endividamento e sem cotas considera como 1 *--
    IF (nvl(vr_vlendivi,0) = 0 AND rw_crapcot.vldcotas = 0) OR
       (vr_vlendiv2 <= 4)  THEN
      vr_nrseqite := 1;
    ELSIF vr_vlendiv2 <= 8 THEN
      vr_nrseqite :=  2;
    ELSIF vr_vlendiv2 <= 12   THEN
      vr_nrseqite := 3;
    ELSE
      vr_nrseqite := 4;
    END IF;

    IF pr_flgdcalc = 1 THEN
       vr_vldanota := vr_vldanota + vr_vet_nota_010(vr_nrseqite);
    ELSE
      -- Gravar itens do rating na crapras
      pc_grava_item_rating ( pr_cdcooper => pr_cdcooper             --Codigo Cooperativa
                            ,pr_nrdconta => pr_nrdconta             --Numero da Conta
                            ,pr_tpctrato => pr_tpctrato             --Tipo Contrato Rating
                            ,pr_nrctrato => pr_nrctrato             --Numero Contrato Rating
                            ,pr_nrtopico => 1                       --Numero do topico
                            ,pr_nritetop => 10                      --Numero Contrato Rating
                            ,pr_nrseqite => vr_nrseqite             --Numero Contrato Rating
                            ,pr_flgcriar => pr_flgcriar             -- Indicado se deve criar o rating
                            ,pr_tab_crapras => pr_tab_crapras       --
                            ,pr_dscritic    => vr_dscritic);        -- Descricao do erro

      -- Se retornou erro, deve abortar
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END IF;

    IF pr_flgdcalc = 1 THEN
      -- gerar classifica��o
      IF vr_vldanota >= 0 AND vr_vldanota <= 85 THEN
        pr_clascoop := 'A'; --> AA <--
      ELSIF vr_vldanota >= 86 AND vr_vldanota <= 130 THEN
        pr_clascoop := 'A';
      ELSIF vr_vldanota >= 131 AND vr_vldanota <= 170 THEN
        pr_clascoop := 'B';
      ELSIF vr_vldanota >= 171 AND vr_vldanota <= 205 THEN
        pr_clascoop := 'C';
      ELSIF vr_vldanota >= 206 AND vr_vldanota <= 225 THEN
        pr_clascoop := 'D';
      ELSIF vr_vldanota >= 226 AND vr_vldanota <= 232 THEN
        pr_clascoop := 'E';
      ELSIF vr_vldanota >= 233 AND vr_vldanota <= 239 THEN
        pr_clascoop := 'F';
      ELSIF vr_vldanota >= 240 AND vr_vldanota <= 246 THEN
        pr_clascoop := 'G';
      ELSE
        pr_clascoop := 'H'; /* >= 247 e <= 999.9 */
      END IF;
      pr_notacoop := vr_vldanota;
    END IF;

    pr_des_reto := 'OK';
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno n�o OK
      pr_des_reto := 'NOK';
      -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
    WHEN OTHERS THEN
      -- Retorno n�o OK
      pr_des_reto := 'NOK';

      -- Montar descri��o de erro n�o tratado
      vr_dscritic := 'Erro n�o tratado na RATI0001.pc_risco_cooperado_pf> '||sqlerrm;
      -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1
                           ,pr_cdcritic => 0
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
  END pc_risco_cooperado_pf;


  /*****************************************************************************
   Procedure para calular o rating para as pessoas fisicas.
  *****************************************************************************/
  PROCEDURE pc_calcula_rating_fisica(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo Cooperativa
                                    ,pr_cdagenci IN crapass.cdagenci%TYPE --> Codigo Agencia
                                    ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Numero Caixa
                                    ,pr_cdoperad IN crapnrc.cdoperad%TYPE --> Codigo Operador
                                    ,pr_idorigem IN INTEGER               --> Identificador Origem
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE --> Numero da Conta
                                    ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Sequencial do Titular
                                    ,pr_rw_crapdat IN btch0001.rw_crapdat%TYPE  --> Vetor com dados de par�metro (CRAPDAT)
                                    ,pr_tpctrato IN crapnrc.tpctrrat%TYPE  --> Tipo Contrato Rating
                                    ,pr_nrctrato IN crapnrc.nrctrrat%TYPE  --> Numero Contrato Rating
                                    ,pr_inusatab IN BOOLEAN                --> Indicador de utiliza��o da tabela de juros
                                    ,pr_flgcriar IN INTEGER                --> Indicado se deve criar o rating
                                    ,pr_tab_crapras IN OUT typ_tab_crapras --> Tabela com os registros a serem processados
                                    ,pr_tab_erro OUT GENE0001.typ_tab_erro --> Tabela de retorno de erro
                                    ,pr_des_reto OUT VARCHAR2) IS          --> Ind. de retorno OK/NOK

  /* ..........................................................................

     Programa: pc_calcula_rating_fisica         Antigo: b1wgen0043.p/calcula_rating_fisica
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Odirlei Busana - AMcom
     Data    : Agosto/2014.                          Ultima Atualizacao: 10/05/2016

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  : Procedure para calular o rating para as pessoas fisicas.

     Alteracoes: 27/08/2014 - Convers�o Progress -> Oracle - Odirlei (AMcom)

		        10/05/2016 - Ajuste para utitlizar rowtype locais 
							(Andrei  - RKAM).
  ............................................................................. */
  --------------- VARIAVEIS ----------------
  -- indicador se encontrou registro
  vr_fcrawepr  BOOLEAN := FALSE;
  vr_nrseqite  NUMBER;
  vr_qtdiapra  NUMBER;
  --Variaveis de erro
  vr_exc_erro EXCEPTION;
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(4000);
  -- Classifica��o e Nota do cooperado
  vr_notacoop NUMBER;
  vr_clascoop VARCHAR2(10);
  ----------------- CURSOR ------------------

  rw_crawepr9 cr_crawepr%ROWTYPE;
  rw_crapprp7 cr_crapprp%ROWTYPE;
  rw_craplcr6 cr_craplcr%ROWTYPE;
  rw_craplim7 cr_craplim%ROWTYPE;

  BEGIN

    /* Para Risco Cooperado o calculo eh diferenciado */
    IF pr_tpctrato <> 0  AND
       pr_nrctrato <> 0  THEN
      /* REGISTROS NECESSARIOS */
      IF pr_tpctrato = 90   THEN  /* Emprestimo/Financiamento */

        --ler informa��es do emprestimo
        OPEN cr_crawepr(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrctrato => pr_nrctrato);
        FETCH cr_crawepr INTO rw_crawepr9;
        -- se localizou
        IF cr_crawepr%FOUND THEN
          vr_fcrawepr := TRUE;

          -- Ler Cadastro de Linhas de Credito
          OPEN cr_craplcr(pr_cdcooper => pr_cdcooper,
                          pr_cdlcremp => rw_crawepr9.cdlcremp);
          FETCH cr_craplcr INTO rw_craplcr6;
          close cr_craplcr;
        END IF;
        CLOSE cr_crawepr;

        --Ler Cadastros de propostas.
        OPEN cr_crapprp(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_tpctrato => pr_tpctrato
                       ,pr_nrctrato => pr_nrctrato);
        FETCH cr_crapprp INTO rw_crapprp7;
        CLOSE cr_crapprp;

      ELSE
        -- Ler Contratos de Limite de credito
        OPEN cr_craplim(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_tpctrato => pr_tpctrato
                       ,pr_nrctrato => pr_nrctrato);
        FETCH cr_craplim INTO rw_craplim7;
        CLOSE cr_craplim;
      END IF;

    END IF;

    -- Calclula o Risco Cooperado
    pc_risco_cooperado_pf (pr_flgdcalc => 0                --> Indicador de calculo
                          ,pr_cdcooper => pr_cdcooper      --> Codigo Cooperativa
                          ,pr_cdagenci => pr_cdagenci      --> Codigo Agencia
                          ,pr_nrdcaixa => pr_nrdcaixa      --> Numero Caixa
                          ,pr_cdoperad => pr_cdoperad      --> Codigo Operador
                          ,pr_idorigem => pr_idorigem      --> Identificador Origem
                          ,pr_nrdconta => pr_nrdconta      --> Numero da Conta
                          ,pr_idseqttl => pr_idseqttl      --> Sequencial do Titular
                          ,pr_rw_crapdat => pr_rw_crapdat  --> Vetor com dados de par�metro (CRAPDAT)
                          ,pr_tpctrato => pr_tpctrato      --> Tipo Contrato Rating
                          ,pr_nrctrato => pr_nrctrato      --> Numero Contrato Rating
                          ,pr_inusatab => pr_inusatab      --> Indicador de utiliza��o da tabela de juros
                          ,pr_flgcriar => pr_flgcriar      --> Indicado se deve criar o rating
                          ,pr_flgttris => FALSE            --> Indicado se deve carregar toda a crapris
                          ,pr_tab_crapras => pr_tab_crapras--> Tabela com os registros a serem processados
                          ,pr_notacoop => vr_notacoop      --> Retorna a nota da classifica��o
                          ,pr_clascoop => vr_clascoop      --> Retorna classifica��o
                          ,pr_tab_erro => pr_tab_erro      --> Tabela de retorno de erro
                          ,pr_des_reto => pr_des_reto );   --> Ind. de retorno OK/NOK

    -- se gerou critica, abortar programa
    IF pr_des_reto <> 'OK' THEN
      return;
    END IF;

    --> calculo do risco cooperado nao calcula o topico 2 <--
    IF pr_tpctrato = 0 AND pr_nrctrato = 0  THEN
      pr_des_reto := 'OK';
      RETURN;
    END IF;

    /**********************************************************************
     Item 2_1 - Finalidade da operacao
    **********************************************************************/
    IF pr_tpctrato = 90 THEN  /* Emprestimo / Financiamento */
      -- se encontrou registro na crawepr
      IF vr_fcrawepr THEN
        pc_natureza_operacao ( pr_tpctrato => pr_tpctrato          --> Tipo Contrato Rating
                              ,pr_idquapro => rw_crawepr9.idquapro  --> Numero Contrato Rating
                              ,pr_dsoperac => rw_craplcr6.dsoperac  --> Indicado se deve criar o rating
                              ,pr_nrseqite => vr_nrseqite          --> Valor da d�vida
                              ,pr_dscritic => vr_dscritic);        --> Descricao do erro
        -- Se retornou erro
        IF vr_dscritic IS NOT NULL THEN
          raise vr_exc_erro;
        END IF;
      ELSE /* BNDES */
        pc_natureza_operacao ( pr_tpctrato => pr_tpctrato          --> Tipo Contrato Rating
                              ,pr_idquapro => 1  /* Normal */      --> Numero Contrato Rating
                              ,pr_dsoperac => 'FINANCIAMENTO'      --> Indicado se deve criar o rating
                              ,pr_nrseqite => vr_nrseqite          --> Valor da d�vida
                              ,pr_dscritic => vr_dscritic);        --> Descricao do erro
        -- Se retornou erro
        IF vr_dscritic IS NOT NULL THEN
          raise vr_exc_erro;
        END IF;
      END IF;

    ELSE /* Cheque especial / Descontos */
      pc_natureza_operacao ( pr_tpctrato => pr_tpctrato          --> Tipo Contrato Rating
                            ,pr_idquapro => 0                    --> Numero Contrato Rating
                            ,pr_dsoperac => null                 --> Indicado se deve criar o rating
                            ,pr_nrseqite => vr_nrseqite          --> Valor da d�vida
                            ,pr_dscritic => vr_dscritic);        --> Descricao do erro
      -- Se retornou erro
      IF vr_dscritic IS NOT NULL THEN
        raise vr_exc_erro;
      END IF;
    END IF;

    /**********************************************************
     Gravar itens do rating na crapras
    ***********************************************************/
    pc_grava_item_rating ( pr_cdcooper => pr_cdcooper             --Codigo Cooperativa
                          ,pr_nrdconta => pr_nrdconta             --Numero da Conta
                          ,pr_tpctrato => pr_tpctrato             --Tipo Contrato Rating
                          ,pr_nrctrato => pr_nrctrato             --Numero Contrato Rating
                          ,pr_nrtopico => 2                       --Numero do topico
                          ,pr_nritetop => 1                       --Numero Contrato Rating
                          ,pr_nrseqite => vr_nrseqite             --Numero Contrato Rating
                          ,pr_flgcriar => pr_flgcriar             -- Indicado se deve criar o rating
                          ,pr_tab_crapras => pr_tab_crapras       --
                          ,pr_dscritic    => vr_dscritic);        -- Descricao do erro

    -- Se retornou erro, deve abortar
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    /********************************************************************
     Item 2_2 - Garantia da operacao.
    ********************************************************************/

    IF pr_tpctrato = 90   THEN /* Emprestimo / Financiamento */
      vr_nrseqite := rw_crapprp7.nrgarope;
    ELSE                         /* Cheque especial / Desconto */
      vr_nrseqite := rw_craplim7.nrgarope;
    END IF;

    /**********************************************************
     Gravar itens do rating na crapras
    ***********************************************************/
    pc_grava_item_rating ( pr_cdcooper => pr_cdcooper             --Codigo Cooperativa
                          ,pr_nrdconta => pr_nrdconta             --Numero da Conta
                          ,pr_tpctrato => pr_tpctrato             --Tipo Contrato Rating
                          ,pr_nrctrato => pr_nrctrato             --Numero Contrato Rating
                          ,pr_nrtopico => 2                       --Numero do topico
                          ,pr_nritetop => 2                       --Numero Contrato Rating
                          ,pr_nrseqite => vr_nrseqite             --Numero Contrato Rating
                          ,pr_flgcriar => pr_flgcriar             -- Indicado se deve criar o rating
                          ,pr_tab_crapras => pr_tab_crapras       --
                          ,pr_dscritic    => vr_dscritic);        -- Descricao do erro

    -- Se retornou erro, deve abortar
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    /********************************************************************
     Item 2_3 - Liquidez das garantias.
    ********************************************************************/
    IF pr_tpctrato = 90    THEN  /* Emprestimo / Financiamento */
      vr_nrseqite := rw_crapprp7.nrliquid;
    ELSE                           /* Cheque especial / Desconto */
      vr_nrseqite := rw_craplim7.nrliquid;
    END IF;

    /**********************************************************
     Gravar itens do rating na crapras
    ***********************************************************/
    pc_grava_item_rating ( pr_cdcooper => pr_cdcooper             --Codigo Cooperativa
                          ,pr_nrdconta => pr_nrdconta             --Numero da Conta
                          ,pr_tpctrato => pr_tpctrato             --Tipo Contrato Rating
                          ,pr_nrctrato => pr_nrctrato             --Numero Contrato Rating
                          ,pr_nrtopico => 2                       --Numero do topico
                          ,pr_nritetop => 3                       --Numero Contrato Rating
                          ,pr_nrseqite => vr_nrseqite             --Numero Contrato Rating
                          ,pr_flgcriar => pr_flgcriar             -- Indicado se deve criar o rating
                          ,pr_tab_crapras => pr_tab_crapras       --
                          ,pr_dscritic    => vr_dscritic);        -- Descricao do erro

    -- Se retornou erro, deve abortar
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    /********************************************************************
     Item 2_4 - Prazo da operacao.
    ********************************************************************/
    IF pr_tpctrato = 90   THEN  /* Emprestimo / Financiamento */
      IF vr_fcrawepr THEN
        vr_qtdiapra := rw_crawepr9.qtpreemp * 30; /* Sempre vezes 30 */
      ELSE /* BNDES */
        vr_qtdiapra := rw_crapprp7.qtparbnd * 30; /* Sempre vezes 30 */
      END IF;
    ELSE                          /* Cheque especial / Desconto */
      vr_qtdiapra := rw_craplim7.qtdiavig;
    END IF;

    -- definir sequencial
    IF vr_qtdiapra <= 720   THEN
      vr_nrseqite := 1;
    ELSIF  vr_qtdiapra <= 1440  THEN
      vr_nrseqite := 2;
    ELSE
      vr_nrseqite := 3;
    END IF;

    /**********************************************************
     Gravar itens do rating na crapras
    ***********************************************************/
    pc_grava_item_rating ( pr_cdcooper => pr_cdcooper             --Codigo Cooperativa
                          ,pr_nrdconta => pr_nrdconta             --Numero da Conta
                          ,pr_tpctrato => pr_tpctrato             --Tipo Contrato Rating
                          ,pr_nrctrato => pr_nrctrato             --Numero Contrato Rating
                          ,pr_nrtopico => 2                       --Numero do topico
                          ,pr_nritetop => 4                       --Numero Contrato Rating
                          ,pr_nrseqite => vr_nrseqite             --Numero Contrato Rating
                          ,pr_flgcriar => pr_flgcriar             -- Indicado se deve criar o rating
                          ,pr_tab_crapras => pr_tab_crapras       --
                          ,pr_dscritic    => vr_dscritic);        -- Descricao do erro

    -- Se retornou erro, deve abortar
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Retorno OK
    pr_des_reto := 'OK';
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno n�o OK
      pr_des_reto := 'NOK';
      -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
    WHEN OTHERS THEN
      -- Retorno n�o OK
      pr_des_reto := 'NOK';
      -- Montar descri��o de erro n�o tratado
      vr_dscritic := 'Erro n�o tratado na RATI0001.pc_calcula_rating_fisica> '||sqlerrm;
      -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => 0
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
  END pc_calcula_rating_fisica;


  /*****************************************************************************
   Procedure para calcular o rating do associado e gravar os registros na crapras.
  *****************************************************************************/
  PROCEDURE pc_calcula_rating(pr_cdcooper IN crapcop.cdcooper%TYPE                           --> Codigo Cooperativa
                             ,pr_cdagenci IN crapass.cdagenci%TYPE                           --> Codigo Agencia
                             ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE                           --> Numero Caixa
                             ,pr_cdoperad IN crapnrc.cdoperad%TYPE                           --> Codigo Operador
                             ,pr_nrdconta IN crapass.nrdconta%TYPE                           --> Numero da Conta
                             ,pr_tpctrato IN crapnrc.tpctrrat%TYPE                           --> Tipo Contrato Rating
                             ,pr_nrctrato IN crapnrc.nrctrrat%TYPE                           --> Numero Contrato Rating
                             ,pr_flgcriar IN OUT INTEGER                                     --> Indicado se deve criar o rating
                             ,pr_flgcalcu IN INTEGER                                         --> Indicador de calculo
                             ,pr_idseqttl IN crapttl.idseqttl%TYPE                           --> Sequencial do Titular
                             ,pr_idorigem IN INTEGER                                         --> Identificador Origem
                             ,pr_nmdatela IN craptel.nmdatela%TYPE                           --> Nome da tela
                             ,pr_flgerlog IN VARCHAR2                                        --> Identificador de gera��o de log
                             ,pr_tab_rating_sing       IN RATI0001.typ_tab_crapras           --> Registros gravados para rating singular
                             ----- OUT ----
                             ,pr_tab_impress_coop     OUT RATI0001.typ_tab_impress_coop     --> Registro impress�o da Cooperado
                             ,pr_tab_impress_rating   OUT RATI0001.typ_tab_impress_rating   --> Registro itens do Rating
                             ,pr_tab_impress_risco_cl OUT RATI0001.typ_tab_impress_risco    --> Registro Nota e risco do cooperado naquele Rating - PROVISAOCL
                             ,pr_tab_impress_risco_tl OUT RATI0001.typ_tab_impress_risco    --> Registro Nota e risco do cooperado naquele Rating - PROVISAOTL
                             ,pr_tab_impress_assina   OUT RATI0001.typ_tab_impress_assina   --> Assinatura na impressao do Rating
                             ,pr_tab_efetivacao       OUT RATI0001.typ_tab_efetivacao       --> Registro dos itens da efetiva��o
                             ,pr_tab_ratings          OUT RATI0001.typ_tab_ratings          --> Informacoes com os Ratings do Cooperado
                             ,pr_tab_crapras          OUT RATI0001.typ_tab_crapras          --> Tabela com os registros processados
                             ,pr_tab_erro             OUT GENE0001.typ_tab_erro             --> Tabela de retorno de erro
                             ,pr_des_reto             OUT VARCHAR2                          --> Ind. de retorno OK/NOK
                             ) IS

  /* ..........................................................................

     Programa: pc_calcula_rating         Antigo: b1wgen0043.p/calcula-rating
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Odirlei Busana - AMcom
     Data    : Agosto/2014.                          Ultima Atualizacao: 10/05/2016

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  : Procedure para calcular o rating do associado e gravar os registros na
                 crapras.

     Alteracoes: 27/08/2014 - Convers�o Progress -> Oracle - Odirlei (AMcom)

				 29/03/2016 - Replicar manuten��o realizada no progress SD352945 (Odirlei-AMcom)

		         10/05/2016 - Ajuste para utitlizar rowtype locais 
							 (Andrei  - RKAM).

  ............................................................................. */
  --------------- CURSORES  ----------------
    -- verificar conta do associado
    CURSOR cr_crapass IS
      SELECT inpessoa
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%rowtype;

	-- Lockar conta do associado
    CURSOR cr_crapass_lock (pr_cdcooper crapass.cdcooper%TYPE,
                            pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT crapass.rowid
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta         
         FOR UPDATE WAIT 10; --aguardar 10 segundos
    rw_crapass_lock cr_crapass_lock%rowtype;

  --------------- VARIAVEIS ----------------
    -- Variaveis para manter critica
    vr_exc_erro EXCEPTION;
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    -- Vetor com dados de par�metro (CRAPDAT)
    rw_crapdat btch0001.rw_crapdat%TYPE;

    -- Variaveis para manter o log
    vr_dsorigem  VARCHAR2(50);
    vr_dstransa  VARCHAR2(50);
    vr_nrdrowid  ROWID;

    -- Variaveis para busca na craptab
    vr_dstextab craptab.dstextab%type;
    vr_inusatab BOOLEAN;

    -- Valores calculados
    vr_vlutiliz NUMBER;

    -- Efetiva��o ou n�o do rating
    vr_flgefeti INTEGER;

    rw_crapnrc3 cr_crapnrc%ROWTYPE;
    
    -- Index temptable
    vr_idxrisco PLS_INTEGER;
    
    -- verifica se deve atualizar crapass
    vr_flgatuas BOOLEAN;
    

  BEGIN
    -- Montar variaveis para log
    IF pr_flgerlog = 'S'  THEN
      vr_dsorigem := TRIM(gene0001.vr_vet_des_origens(pr_idorigem));
      vr_dstransa := 'Calcular o rating do associado';
    END IF;

    vr_flgatuas := FALSE;
    vr_cdcritic := 0;
    vr_dscritic := NULL;

    -- verificar conta do associado
    OPEN cr_crapass;
    FETCH cr_crapass INTO rw_crapass;
    -- se n�o encontrar gerar critica
    IF cr_crapass%NOTFOUND THEN
      vr_dscritic := null;
      vr_cdcritic := 9; -- Socio nao encontrado
      raise vr_exc_erro;
    END IF;

    -- Busca do calend�rio
    OPEN btch0001.cr_crapdat(pr_cdcooper);
    FETCH btch0001.cr_crapdat
     INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;

    -- Verificar se usa tabela juros
    vr_dstextab:= TABE0001.fn_busca_dstextab (pr_cdcooper => pr_cdcooper
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'USUARI'
                                             ,pr_cdempres => 11
                                             ,pr_cdacesso => 'TAXATABELA'
                                             ,pr_tpregist => 0);
    -- Se a primeira posi��o do campo dstextab for diferente de zero
    vr_inusatab := SUBSTR(vr_dstextab,1,1) != '0';

    -- Verifica se tem que criar Rating
    IF pr_flgcriar = 1 THEN
	  
	  vr_flgatuas := TRUE;  

      -- Verificar se o Rating tem que ser criado.
      pc_verifica_criacao (pr_cdcooper => pr_cdcooper    --> Codigo Cooperativa
                          ,pr_cdagenci => 0              --> Codigo Agencia
                          ,pr_nrdcaixa => 0              --> Numero Caixa
                          ,pr_cdoperad => pr_cdoperad    --> Codigo Operador
                          ,pr_rw_crapdat => rw_crapdat--> Vetor com dados de par�metro (CRAPDAT)
                          ,pr_nrdconta => pr_nrdconta    --> Numero da Conta
                          ,pr_tpctrato => pr_tpctrato    --> Tipo Contrato Rating
                          ,pr_nrctrato => pr_nrctrato    --> Numero Contrato Rating
                          ,pr_idseqttl => pr_idseqttl    --> Sequencial do Titular
                          ,pr_idorigem => pr_idorigem    --> Identificador Origem
                          ,pr_inusatab => vr_inusatab    --> Indicador de utiliza��o da tabela de juros
                          ,pr_flgcriar => pr_flgcriar    --> Indicado se deve criar o rating
                          ,pr_tab_erro => pr_tab_erro    --> Tabela de retorno de erro
                          ,pr_des_reto => pr_des_reto ); --> Ind. de retorno OK/NOK
      -- Aborta procedimento se retornou critica
      IF pr_des_reto <> 'OK' THEN
        RAISE vr_exc_erro;
      END IF;
    END IF;

    -- Verifica se tem de calcular o Rating
    IF pr_flgcalcu = 1 THEN
      -- Exclusivo para a Cecred
      IF pr_cdcooper = 3 THEN
        -- Calcula sigulares
        pc_calcula_singulares(pr_cdcooper        => pr_cdcooper  --> Codigo Cooperativa
                             ,pr_cdagenci        => pr_cdagenci  --> Codigo Agencia
                             ,pr_nrdcaixa        => pr_nrdcaixa  --> Numero Caixa
                             ,pr_cdoperad        => pr_cdoperad  --> Codigo Operador
                             ,pr_idorigem        => pr_idorigem  --> Identificador Origem
                             ,pr_nrdconta        => pr_nrdconta  --> Numero da Conta
                             ,pr_idseqttl        => pr_idseqttl  --> Sequencial do Titular
                             ,pr_rw_crapdat      => rw_crapdat   --> Vetor com dados de par�metro (CRAPDAT)
                             ,pr_tpctrato        => pr_tpctrato  --> Tipo Contrato Rating
                             ,pr_nrctrato        => pr_nrctrato  --> Numero Contrato Rating
                             ,pr_inusatab        => vr_inusatab  --> Indicador de utiliza��o da tabela de juros
                             ,pr_flgcriar        => pr_flgcriar  --> Indicado se deve criar o rating
                             ,pr_tab_rating_sing => pr_tab_rating_sing --> Tabela com os registros a serem processados
                             ,pr_tab_crapras     => pr_tab_crapras     --> Tabela com os registros a serem processados
                             ,pr_vlutiliz        => vr_vlutiliz        --> Valor da d�vida
                             ,pr_dscritic        => vr_dscritic);      --> Sa�da de erros
        -- Em caso de erro
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      ELSE
        -- Chamaremos rotinas espec�ficas conforme o tipo da pessoa
        IF rw_crapass.inpessoa = 1 THEN
          -- Fisica
          pc_calcula_rating_fisica(pr_cdcooper => pr_cdcooper       --> Codigo Cooperativa
                                  ,pr_cdagenci => pr_cdagenci       --> Codigo Agencia
                                  ,pr_nrdcaixa => pr_nrdcaixa       --> Numero Caixa
                                  ,pr_cdoperad => pr_cdoperad       --> Codigo Operador
                                  ,pr_idorigem => pr_idorigem       --> Identificador Origem
                                  ,pr_nrdconta => pr_nrdconta       --> Numero da Conta
                                  ,pr_idseqttl => pr_idseqttl       --> Sequencial do Titular
                                  ,pr_rw_crapdat => rw_crapdat      --> Vetor com dados de par�metro (CRAPDAT)
                                  ,pr_tpctrato => pr_tpctrato       --> Tipo Contrato Rating
                                  ,pr_nrctrato => pr_nrctrato       --> Numero Contrato Rating
                                  ,pr_inusatab => vr_inusatab       --> Indicador de utiliza��o da tabela de juros
                                  ,pr_flgcriar => pr_flgcriar       --> Indicado se deve criar o rating
                                  ,pr_tab_crapras => pr_tab_crapras --> Tabela com os registros a serem processados
                                  ,pr_tab_erro => pr_tab_erro       --> Tabela de retorno de erro
                                  ,pr_des_reto => pr_des_reto);     --> Ind. de retorno OK/NOK
        ELSE
          -- Juridica
          pc_calcula_rating_juridica(pr_cdcooper => pr_cdcooper       --> Codigo Cooperativa
                                    ,pr_cdagenci => pr_cdagenci       --> Codigo Agencia
                                    ,pr_nrdcaixa => pr_nrdcaixa       --> Numero Caixa
                                    ,pr_cdoperad => pr_cdoperad       --> Codigo Operador
                                    ,pr_idorigem => pr_idorigem       --> Identificador Origem
                                    ,pr_nrdconta => pr_nrdconta       --> Numero da Conta
                                    ,pr_idseqttl => pr_idseqttl       --> Sequencial do Titular
                                    ,pr_rw_crapdat => rw_crapdat      --> Vetor com dados de par�metro (CRAPDAT)
                                    ,pr_tpctrato => pr_tpctrato       --> Tipo Contrato Rating
                                    ,pr_nrctrato => pr_nrctrato       --> Numero Contrato Rating
                                    ,pr_inusatab => vr_inusatab       --> Indicador de utiliza��o da tabela de juros
                                    ,pr_flgcriar => pr_flgcriar       --> Indicado se deve criar o rating
                                    ,pr_tab_crapras => pr_tab_crapras --> Tabela com os registros a serem processados
                                    ,pr_tab_erro => pr_tab_erro       --> Tabela de retorno de erro
                                    ,pr_des_reto => pr_des_reto);     --> Ind. de retorno OK/NOK
        END IF;
        -- Em caso de erro
        IF pr_des_reto <> 'OK' THEN
          -- Sair
          RAISE vr_exc_erro;
        END IF;
      END IF;
    END IF;

    -- Traz registros contendo o rating para imprimir
    pc_gera_arq_impress_rating(pr_cdcooper    => pr_cdcooper          --> Cooperativa conectada
                              ,pr_cdagenci    => pr_cdagenci          --> C�digo da ag�ncia
                              ,pr_nrdcaixa    => pr_nrdcaixa          --> N�mero do caixa
                              ,pr_cdoperad    => pr_cdoperad          --> C�digo do operador
                              ,pr_dtmvtolt    => rw_crapdat.dtmvtolt  --> Data do movimento atual
                              ,pr_nrdconta    => pr_nrdconta          --> Conta do associado
                              ,pr_tpctrato    => pr_tpctrato          --> Tipo do Rating
                              ,pr_nrctrato    => pr_nrctrato          --> N�mero do contrato de Rating
                              ,pr_flgcriar    => pr_flgcriar          --> Flag para cria��o ou n�o do arquivo
                              ,pr_flgcalcu    => pr_flgcalcu          --> Flag para calculo ou n�o
                              ,pr_idseqttl    => pr_idseqttl          --> Sq do titular da conta
                              ,pr_idorigem    => pr_idorigem          --> Indicador da origem da chamada
                              ,pr_nmdatela    => pr_nmdatela          --> Nome da tela conectada
                              ,pr_flgerlog    => pr_flgerlog          --> Gerar log S/N
                              ,pr_tab_crapras => pr_tab_crapras       --> Interna da BO, para o calculo do Rating
                              ,pr_tab_impress_coop     => pr_tab_impress_coop     --> Registro impress�o da Cooperado
                              ,pr_tab_impress_rating   => pr_tab_impress_rating   --> Registro itens do Rating
                              ,pr_tab_impress_risco_cl => pr_tab_impress_risco_cl --> Registro Nota e risco do cooperado naquele Rating - PROVISAOCL
                              ,pr_tab_impress_risco_tl => pr_tab_impress_risco_tl --> Registro Nota e risco do cooperado naquele Rating - PROVISAOTL
                              ,pr_tab_impress_assina   => pr_tab_impress_assina   --> Assinatura na impressao do Rating
                              ,pr_tab_efetivacao       => pr_tab_efetivacao       --> Registro dos itens da efetiva��o
                              ,pr_tab_erro             => pr_tab_erro             --> Tabela de retorno de erro
                              ,pr_des_reto             => pr_des_reto);           --> Indicador erro IS
    -- Em caso de erro
    IF pr_des_reto <> 'OK' THEN
      -- Sair
      RAISE vr_exc_erro;
    END IF;

	/* Verifica se atualiza o risco do cooperado */
    IF vr_flgatuas THEN
      vr_idxrisco := pr_tab_impress_risco_tl.first;
      
      IF pr_tab_impress_risco_tl.exists(vr_idxrisco) THEN
         
         BEGIN
           --> Buscar e locar associado
           OPEN cr_crapass_lock(pr_cdcooper => pr_cdcooper,
                                pr_nrdconta => pr_nrdconta);
           FETCH cr_crapass_lock INTO rw_crapass_lock;
           IF cr_crapass%NOTFOUND THEN

             vr_cdcritic := 9; --> 009 - Associado nao cadastrado.
             CLOSE cr_crapass_lock;
             RAISE vr_exc_erro;
           END IF;
           CLOSE cr_crapass_lock;
         EXCEPTION
           WHEN OTHERS THEN
             vr_cdcritic := 77; --> 077 - Tabela sendo alterada p/ outro terminal.
             IF cr_crapass_lock%ISOPEN THEN
               CLOSE cr_crapass_lock;
             END IF;
             RAISE vr_exc_erro;
           
         END;

         --> Atualizar associado
         BEGIN
           UPDATE crapass
              SET crapass.inrisctl = pr_tab_impress_risco_tl(vr_idxrisco).dsdrisco,
                  crapass.nrnotatl = pr_tab_impress_risco_tl(vr_idxrisco).vlrtotal,
                  crapass.dtrisctl = rw_crapdat.dtmvtolt
            WHERE crapass.rowid = rw_crapass_lock.rowid;
         EXCEPTION 
           WHEN OTHERS THEN
             vr_dscritic := 'Nao foi possivel atualizar associado: '|| SQLERRM;
             CLOSE cr_crapass_lock;
             RAISE vr_exc_erro;
         END;

    END IF;
    END IF; -- Fim IF vr_flgatuas 

    -- Se est� setada a cria��o
    IF pr_flgcriar = 1 THEN
	  IF vr_vlutiliz is null and wglb_vlutiliz is not null then
        vr_vlutiliz := wglb_vlutiliz;
      end if;

      -- Testar informa��es necess�rias nas tabelas
      IF pr_tab_impress_risco_cl.COUNT = 0 THEN
        vr_dscritic := 'Risco da operacao nao encontrado.';
        RAISE vr_exc_erro;
      END IF;
      -- Testar informa��es necess�rias nas tabelas
      IF pr_tab_impress_risco_tl.COUNT = 0 THEN
        vr_dscritic := 'Risco do cooperado nao encontrado.';
        RAISE vr_exc_erro;
      END IF;
      -- Busca do rating para atualiza��o / cria��o
      OPEN cr_crapnrc(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_tpctrrat => pr_tpctrato
                     ,pr_nrctrrat => pr_nrctrato);
      FETCH cr_crapnrc
       INTO rw_crapnrc3;
      -- Se n�o existir
      IF cr_crapnrc%NOTFOUND THEN
        CLOSE cr_crapnrc;
        -- Ent�o devemos cri�-los
        BEGIN
          INSERT INTO crapnrc(cdcooper
                             ,nrdconta
                             ,nrctrrat
                             ,tpctrrat
                             ,insitrat
                             ,flgativo
                             ,indrisco
                             ,dtmvtolt
                             ,cdoperad
                             ,nrnotrat
                             ,vlutlrat
                             ,nrnotatl
                             ,inrisctl)
                       VALUES(pr_cdcooper
                             ,pr_nrdconta
                             ,pr_nrctrato
                             ,pr_tpctrato
                             ,1 -- Proposto
                             ,1 -- Opera��o ativa
                             ,pr_tab_impress_risco_cl(1).dsdrisco
                             ,rw_crapdat.dtmvtolt
                             ,pr_cdoperad
                             ,pr_tab_impress_risco_cl(1).vlrtotal
                             ,vr_vlutiliz -- Valor utilizado
                             ,pr_tab_impress_risco_tl(1).vlrtotal
                             ,pr_tab_impress_risco_tl(1).dsdrisco);
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao criar crapnrc: '||SQLERRM;
            RAISE vr_exc_erro;
        END;
      ELSE
        CLOSE cr_crapnrc;
        -- Atualizar a informa��o
        BEGIN
          UPDATE crapnrc
             SET indrisco = pr_tab_impress_risco_cl(1).dsdrisco
                ,dtmvtolt = rw_crapdat.dtmvtolt
                ,cdoperad = pr_cdoperad
                ,nrnotrat = pr_tab_impress_risco_cl(1).vlrtotal
                ,vlutlrat = vr_vlutiliz -- Valor utilizado
                ,nrnotatl = pr_tab_impress_risco_tl(1).vlrtotal
                ,inrisctl = pr_tab_impress_risco_tl(1).dsdrisco
            WHERE ROWID = rw_crapnrc3.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar crapnrc: '||SQLERRM;
            RAISE vr_exc_erro;
        END;
      END IF;
      -- Verifica se tem que efetivar
      pc_verifica_efetivacao(pr_cdcooper  => pr_cdcooper   --> Cooperativa conectada
                            ,pr_cdagenci  => 0             --> C�digo da ag�ncia
                            ,pr_nrdcaixa  => 0             --> N�mero do caixa
                            ,pr_nrdconta  => pr_nrdconta   --> Conta do associado
                            ,pr_nrnotrat  => pr_tab_impress_risco_cl(1).vlrtotal   --> Nota atingida na soma dos itens do rating.
                            ,pr_vlutiliz  => vr_vlutiliz   --> Valor utilizado para grava��o
                            ,pr_flgefeti  => vr_flgefeti   --> Flag do resultado da efetiva��o do Rating
                            ,pr_tab_erro  => pr_tab_erro   --> Tabela de retorno de erro
                            ,pr_des_reto  => pr_des_reto); --> Indicador erro
      -- Em caso de erro
      IF pr_des_reto <> 'OK' THEN
        -- Sair
        RAISE vr_exc_erro;
      END IF;
      -- Se tiver que efetivar
      IF vr_flgefeti = 1 THEN
        -- Chamar o processo de efetiva��o do Rating
        pc_efetivar_rating(pr_cdcooper   => pr_cdcooper           --> Cooperativa conectada
                          ,pr_nrdconta   => pr_nrdconta           --> Conta do associado
                          ,pr_tpctrato   => 0                     --> Tipo do Rating
                          ,pr_nrctrato   => 0                     --> N�mero do contrato de Rating
                          ,pr_cdoperad   => pr_cdoperad           --> C�digo do operador
                          ,pr_dtmvtolt   => rw_crapdat.dtmvtolt   --> Data do movimento atual
                          ,pr_vlutiliz   => vr_vlutiliz           --> Valor utilizado para grava��o
                          ,pr_flgatual   => TRUE                  --> Flag para efetuar ou n�o a atualiza��o
                          ,pr_tab_efetivacao => pr_tab_efetivacao --> Registro de efetiva��o
                          ,pr_tab_ratings    => pr_tab_ratings    --> Registro com os ratings do associado
                          ,pr_tab_erro       => pr_tab_erro       --> Tabela de retorno de erro
                          ,pr_des_reto       => pr_des_reto);     --> Indicador erro
        -- No Progress n�o � validado o retorno 
        ---- Em caso de erro
        --IF pr_des_reto <> 'OK' THEN
        --  -- Sair
        --  RAISE vr_exc_erro;
        --END IF;
      END IF;
    END IF;

    -- Se foi solicitado o envio de LOG
    IF pr_flgerlog = 'S' THEN
      -- Gerar LOG de envio do e-mail
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => ''
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => rw_crapdat.dtmvtolt
                          ,pr_flgtrans => 0 --> FALSE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate,'SSSSS'))
                          ,pr_idseqttl => pr_idseqttl
                          ,pr_nmdatela => pr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
    END IF;
    -- Se chegamos neste ponto, n�o houve erro
    pr_des_reto := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno n�o OK
      pr_des_reto := 'NOK';

      -- Se ainda n�o tem registro de erro, criar com a critica
      IF pr_tab_erro.COUNT = 0 THEN
        -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
      END IF;

      -- Se foi solicitado o envio de LOG
      IF pr_flgerlog = 'S' THEN
        -- Gerar LOG de envio do e-mail
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => rw_crapdat.dtmvtolt
                            ,pr_flgtrans => 0 --> FALSE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;
      -- Se esta marcado para criar registro, entao deve dar rollback
      IF pr_flgcriar = 1 THEN
        ROLLBACK;
      END IF;
    WHEN OTHERS THEN
      -- Retorno n�o OK
      pr_des_reto := 'NOK';
      -- Montar descri��o de erro n�o tratado
      vr_dscritic := 'Erro n�o tratado na RATI0001.pc_calcula_rating> '||sqlerrm;
      -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => 0
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
      -- Se foi solicitado o envio de LOG
      IF pr_flgerlog = 'S' THEN
        -- Gerar LOG de envio do e-mail
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => rw_crapdat.dtmvtolt
                            ,pr_flgtrans => 0 --> FALSE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);

      END IF;
      ROLLBACK;
  END pc_calcula_rating;
  
  /******************************************************************************
    Verifica se alguma operacao de Credito esta ativa.
    Limite de credito, descontos e emprestimo.
    Usada para ver se o Rating antigo pode ser desativado.
  ******************************************************************************/
  PROCEDURE pc_verifica_operacoes(pr_cdcooper    IN crapcop.cdcooper%TYPE       --> Codigo Cooperativa
                                 ,pr_cdagenci    IN crapass.cdagenci%TYPE       --> Codigo Agencia
                                 ,pr_nrdcaixa    IN craperr.nrdcaixa%TYPE       --> Numero Caixa
                                 ,pr_cdoperad    IN crapnrc.cdoperad%TYPE       --> Codigo Operador
                                 ,pr_rw_crapdat  IN btch0001.rw_crapdat%TYPE    --> Vetor com dados de par�metro (CRAPDAT)                                 
                                 ,pr_nrdconta    IN crapass.nrdconta%TYPE       --> Numero da Conta
                                 ,pr_idseqttl    IN crapttl.idseqttl%TYPE       --> Sequencia de titularidade da conta
                                 ,pr_idorigem    IN INTEGER                     --> Indicador da origem da chamada
                                 ,pr_nmdatela    IN craptel.nmdatela%TYPE       --> Nome da tela
                                 ,pr_flgerlog    IN VARCHAR2                    --> Identificador de gera��o de log
                                 ----- OUT ----
                                 ,pr_flgopera   OUT INTEGER               --> Tabela com os registros processados
                                 ,pr_tab_erro   OUT GENE0001.typ_tab_erro --> Tabela de retorno de erro
                                 ,pr_des_reto   OUT VARCHAR2              --> Ind. de retorno OK/NOK
                                 ) IS

  /* ..........................................................................

     Programa: pc_verifica_operacoes         Antigo: b1wgen0043.p/verifica_operacoes
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Odirlei Busana - AMcom
     Data    : Abril/2015.                          Ultima Atualizacao: 13/04/2015

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  :  Verifica se alguma operacao de Credito esta ativa.
                  Limite de credito, descontos e emprestimo.
                  Usada para ver se o Rating antigo pode ser desativado..

     Alteracoes: 13/04/2015 - Convers�o Progress -> Oracle - Odirlei (AMcom)

  ............................................................................. */
  --------------- CURSORES  ----------------
    -- verificar conta do associado
    CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%TYPE,
                      pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT inpessoa
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%rowtype;
    
    -- verificar emprestimo
    CURSOR cr_crapepr(pr_cdcooper crapass.cdcooper%TYPE,
                      pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT crapepr.nrdconta
        FROM crapepr
       WHERE crapepr.cdcooper = pr_cdcooper
         AND crapepr.nrdconta = pr_nrdconta
         AND crapepr.inliquid = 0;
    rw_crapepr cr_crapepr%ROWTYPE;     
    
    -- Verificar Contratos de Limite de credito
    CURSOR cr_craplim(pr_cdcooper crapass.cdcooper%TYPE,
                      pr_nrdconta crapass.nrdconta%TYPE,
                      pr_dtmvtolt craplim.dtfimvig%TYPE) IS
      SELECT craplim.nrdconta
        FROM craplim
       WHERE craplim.cdcooper = pr_cdcooper
         AND craplim.nrdconta = pr_nrdconta
         AND craplim.insitlim = 2 /* Ativo*/
         AND ((craplim.tpctrlim = 3 AND craplim.dtfimvig > pr_dtmvtolt) OR
               craplim.tpctrlim IN (1, 2)
             );
    rw_craplim cr_craplim%ROWTYPE;
    
    
  --------------- VARIAVEIS ----------------
    -- Variaveis para manter critica
    vr_exc_erro EXCEPTION;
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    -- Vetor com dados de par�metro (CRAPDAT)
    rw_crapdat btch0001.rw_crapdat%TYPE;

    -- Variaveis para manter o log
    vr_dsorigem  VARCHAR2(50);
    vr_dstransa  VARCHAR2(50);
    vr_nrdrowid  ROWID;

    -- Variaveis para busca na craptab
    vr_dstextab craptab.dstextab%type;
    vr_inusatab BOOLEAN;

    -- Valores calculados
    vr_vlutiliz NUMBER;

    -- Efetiva��o ou n�o do rating
    vr_flgefeti INTEGER;

  BEGIN
  
    IF pr_flgerlog = 'S' THEN
      vr_dsorigem := GENE0001.vr_vet_des_origens(pr_idorigem);
      vr_dstransa := 'Verificar se alguma operacao de credito esta ativa';
    END IF;
    
    LOOP
      -- validar associado
      OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      
      -- senao encontrar, gerar critica e sair
      IF cr_crapass%NOTFOUND THEN
        vr_cdcritic := 9; --> 009 - Associado nao cadastrado.
        CLOSE cr_crapass;
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crapass;
      END IF;
      
      -- Emprestimo em aberto ...
      OPEN cr_crapepr (pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => pr_nrdconta);
      FETCH cr_crapepr INTO rw_crapepr;
      
      -- se encontrar emprestimo
      IF cr_crapepr%FOUND THEN
        pr_flgopera := 1; --TRUE.
        CLOSE cr_crapepr;
        EXIT;
      ELSE
        CLOSE cr_crapepr;
      END IF;
      
      -- Verificar Limite ou desconto ativo ... 
      OPEN cr_craplim (pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => pr_nrdconta,
                       pr_dtmvtolt => pr_rw_crapdat.dtmvtolt);
      FETCH cr_craplim INTO rw_craplim;
      
      -- se encontrar
      IF cr_craplim%FOUND THEN
        pr_flgopera := 1; --TRUE.
        CLOSE cr_craplim;
        EXIT;
      ELSE
        CLOSE cr_craplim;
      END IF;
      
      pr_flgopera := 0; --FALSE - Nao possui operacao ativa ...
      EXIT;
    
    END LOOP;
    
    -- Se foi solicitado o envio de LOG
    IF pr_flgerlog = 'S' THEN
      -- Gerar LOG de envio do e-mail
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => NULL
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => rw_crapdat.dtmvtolt
                          ,pr_flgtrans => 1 --> TRUE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate,'SSSSS'))
                          ,pr_idseqttl => pr_idseqttl
                          ,pr_nmdatela => pr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
    END IF;
    
    -- Se chegamos neste ponto, n�o houve erro
    pr_des_reto := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno n�o OK
      pr_des_reto := 'NOK';

      -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);

      -- Se foi solicitado o envio de LOG
      IF pr_flgerlog = 'S' THEN
        -- Gerar LOG de envio do e-mail
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => rw_crapdat.dtmvtolt
                            ,pr_flgtrans => 0 --> FALSE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;
     
    WHEN OTHERS THEN
      -- Retorno n�o OK
      pr_des_reto := 'NOK';
      -- Montar descri��o de erro n�o tratado
      vr_dscritic := 'Erro n�o tratado na RATI0001.pc_verifica_operacoes> '||sqlerrm;
      -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => 0
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
      -- Se foi solicitado o envio de LOG
      IF pr_flgerlog = 'S' THEN
        -- Gerar LOG de envio do e-mail
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => rw_crapdat.dtmvtolt
                            ,pr_flgtrans => 0 --> FALSE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);

      END IF;
      ROLLBACK;
  END pc_verifica_operacoes;
  
/*****************************************************************************
   Procedure para atualizar ratings efetivos. Se existir algum rating com nota
   pior do que este entao efetiva o de pior nota.    
  *****************************************************************************/
  PROCEDURE pc_atualiza_rating(pr_cdcooper IN crapcop.cdcooper%TYPE                           --> Codigo Cooperativa
                              ,pr_cdagenci IN crapass.cdagenci%TYPE                           --> Codigo Agencia
                              ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE                           --> Numero Caixa
                              ,pr_cdoperad IN crapnrc.cdoperad%TYPE                           --> Codigo Operador
                              ,pr_nrdconta IN crapass.nrdconta%TYPE                           --> Numero da Conta
                              ,pr_tpctrato IN crapnrc.tpctrrat%TYPE                           --> Tipo Contrato Rating
                              ,pr_nrctrato IN crapnrc.nrctrrat%TYPE                           --> Numero Contrato Rating
                              ,pr_rowidnrc IN ROWID                                           --> Registro de rating
                              ,pr_flgcriar IN INTEGER                                         --> Indicado se deve criar o rating
                              ,pr_idorigem IN INTEGER                                         --> Identificador Origem
                              ,pr_nmdatela IN craptel.nmdatela%TYPE                           --> Nome da tela
                              ,pr_inproces IN INTEGER                                         --> Situacao do sistema
                              ,pr_idseqttl IN crapttl.idseqttl%TYPE                           --> Sequencial do titular
                              ,pr_flgerlog IN VARCHAR2                                        --> Gera log
                              ,pr_tab_efetivacao       OUT rati0001.typ_tab_efetivacao        --> Registros gravados para rating singular
                              ,pr_tab_impress_risco_tl OUT rati0001.typ_tab_impress_risco     --> Registro Nota e risco do cooperado naquele Rating - PROVISAOTL
                              ,pr_tab_erro             OUT GENE0001.typ_tab_erro              --> Tabela de retorno de erro
                              ,pr_des_reto             OUT VARCHAR2                           --> Ind. de retorno OK/NOK
                              ) IS

  /* ..........................................................................

     Programa: pc_atualiza_rating         Antigo: b1wgen0043.p/atualiza_rating
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Andrei - RKAM
     Data    : Maio/2016.                          Ultima Atualizacao:  

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  :  Procedure para atualizar ratings efetivos. Se existir algum rating com nota
                  pior do que este entao efetiva o de pior nota.    

     Alteracoes:  

  ............................................................................. */
    
    --Cursor para buscar a nota de rating ativa do cooperado
    CURSOR cr_crapnrc(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT nrc.tpctrrat
          ,nrc.nrctrrat
          ,nrc.progress_recid
      FROM crapnrc nrc
     WHERE nrc.cdcooper = pr_cdcooper
       AND nrc.nrdconta = pr_nrdconta
       AND nrc.insitrat = 2; /*Efetivo*/
    rw_crapnrc cr_crapnrc%ROWTYPE;
    
    --Cursor para buscar a nota de rating a ser efetivada
    CURSOR cr_crapnrc_efe(pr_rowidnrc IN ROWID) IS
    SELECT nrc.vlutlrat
      FROM crapnrc nrc
     WHERE rowid = pr_rowidnrc;
    rw_crapnrc_efe cr_crapnrc_efe%ROWTYPE;
    
    -- Variaveis para manter critica
    vr_exc_erro EXCEPTION;
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    
    --PL tables  
    vr_tab_rating_sing      RATI0001.typ_tab_crapras;
    vr_tab_impress_coop     RATI0001.typ_tab_impress_coop;
    vr_tab_impress_rating   RATI0001.typ_tab_impress_rating;
    vr_tab_impress_risco_cl RATI0001.typ_tab_impress_risco;
    vr_tab_impress_assina   RATI0001.typ_tab_impress_assina;
    vr_tab_ratings          RATI0001.typ_tab_ratings;
    vr_tab_crapras          RATI0001.typ_tab_crapras;
    vr_tab_erro             GENE0001.typ_tab_erro;
    
    --Variaveis locais
    vr_des_erro VARCHAR2(4000);
    vr_dsorigem VARCHAR2(100);
    vr_dstransa VARCHAR2(100);
    vr_flgcriar INTEGER := 1;
    vr_nrdrowid ROWID;
    
    --Tipo de Dados para cursor data
    rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

  BEGIN
    
    -- Montar variaveis para log
    IF pr_flgerlog = 'S'  THEN
      vr_dsorigem := TRIM(gene0001.vr_vet_des_origens(pr_idorigem));
      vr_dstransa := 'Atualizar o Rating do cooperado.';
    END IF;
    
    --Busca a nota de rating do cooperado
    OPEN cr_crapnrc(pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => pr_nrdconta);

    FETCH cr_crapnrc INTO rw_crapnrc;
    
    IF cr_crapnrc%NOTFOUND THEN
    
      --Fecha o cursor
      CLOSE cr_crapnrc;
      
      vr_dscritic := NULL;
      vr_cdcritic := 925; 
      
      RAISE vr_exc_erro;      
      
    ELSE
      
      --Fecha o cursor
      CLOSE cr_crapnrc; 
    
    END IF;
    
    -- Verifica se a data esta cadastrada
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    
    -- Se n�o encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois haver� raise
      CLOSE BTCH0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;
         
    RATI0001.pc_calcula_rating(pr_cdcooper => pr_cdcooper   --> Codigo Cooperativa
                              ,pr_cdagenci => pr_cdagenci   --> Codigo Agencia
                              ,pr_nrdcaixa => pr_nrdcaixa   --> Numero Caixa
                              ,pr_cdoperad => pr_cdoperad   --> Codigo Operador
                              ,pr_nrdconta => pr_nrdconta   --> Numero da Conta
                              ,pr_tpctrato => pr_tpctrato   --> Tipo Contrato Rating
                              ,pr_nrctrato => pr_nrctrato   --> Numero Contrato Rating
                              ,pr_flgcriar => vr_flgcriar   --> Indicado se deve criar o rating
                              ,pr_flgcalcu => 1             --> Indicador de calculo
                              ,pr_idseqttl => pr_idseqttl   --> Sequencial do Titular
                              ,pr_idorigem => pr_idorigem   --> Identificador Origem
                              ,pr_nmdatela => 'b1wgen0043'  --> Nome da tela
                              ,pr_flgerlog => pr_flgerlog   --> Identificador de gera��o de log
                              ,pr_tab_rating_sing      => vr_tab_rating_sing      --> Registros gravados para rati
                              ,pr_tab_impress_coop     => vr_tab_impress_coop     --> Registro impress�o da Cooper
                              ,pr_tab_impress_rating   => vr_tab_impress_rating   --> Registro itens do Rating
                              ,pr_tab_impress_risco_cl => vr_tab_impress_risco_cl --> Registro Nota e risco do coo
                              ,pr_tab_impress_risco_tl => pr_tab_impress_risco_tl --> Registro Nota e risco do coo
                              ,pr_tab_impress_assina   => vr_tab_impress_assina   --> Assinatura na impressao do R
                              ,pr_tab_efetivacao       => pr_tab_efetivacao       --> Registro dos itens da efetiv
                              ,pr_tab_ratings          => vr_tab_ratings          --> Informacoes com os Ratings d
                              ,pr_tab_crapras          => vr_tab_crapras          --> Tabela com os registros proc
                              ,pr_tab_erro             => vr_tab_erro             --> Tabela de retorno de erro
                              ,pr_des_reto             => vr_des_erro);           --> Ind. de retorno OK/NOK
                            
    -- Em caso de erro
    IF pr_des_reto <> 'OK' THEN
        
      --Se n�o tem erro na tabela
      IF pr_tab_erro.COUNT = 0 THEN          
        vr_cdcritic:= 0;
        vr_dscritic:= 'Erro ao calcular rating.';
      END IF;
          
      -- Sair
      RAISE vr_exc_erro;
        
    END IF;
    
    /* Neste caso, o Rating efetivo se mantem o mesmo */
    IF rw_crapnrc.progress_recid = pr_rowidnrc THEN
      
      pr_des_reto := 'OK';
      
      RETURN;
      
    END IF;
        
    OPEN cr_crapnrc_efe(pr_rowidnrc => pr_rowidnrc);
    
    FETCH cr_crapnrc_efe INTO rw_crapnrc_efe;
    
    IF cr_crapnrc_efe%NOTFOUND THEN
      
      --Fecha o cursor
      CLOSE cr_crapnrc_efe;
      
    ELSE
      
      --Fecha o cursor
      CLOSE cr_crapnrc_efe;
    
    END IF;
        
    -- Chamar o processo de efetiva��o do Rating
    pc_efetivar_rating(pr_cdcooper   => pr_cdcooper           --> Cooperativa conectada
                      ,pr_nrdconta   => pr_nrdconta           --> Conta do associado
                      ,pr_tpctrato   => 0                     --> Tipo do Rating
                      ,pr_nrctrato   => 0                     --> N�mero do contrato de Rating
                      ,pr_cdoperad   => pr_cdoperad           --> C�digo do operador
                      ,pr_dtmvtolt   => rw_crapdat.dtmvtolt   --> Data do movimento atual
                      ,pr_vlutiliz   => rw_crapnrc_efe.vlutlrat   --> Valor utilizado para grava��o
                      ,pr_flgatual   => FALSE                 --> Flag para efetuar ou n�o a atualiza��o
                      ,pr_tab_efetivacao => pr_tab_efetivacao --> Registro de efetiva��o
                      ,pr_tab_ratings    => vr_tab_ratings    --> Registro com os ratings do associado
                      ,pr_tab_erro       => pr_tab_erro       --> Tabela de retorno de erro
                      ,pr_des_reto       => pr_des_reto);     --> Indicador erro
                      
    -- Comentado pois no Progress n�o � testado o retorno 
    ---- Em caso de erro
    --IF pr_des_reto <> 'OK' THEN
    --    
    --  --Se n�o tem erro na tabela
    --  IF pr_tab_erro.COUNT = 0 THEN          
    --    vr_cdcritic:= 0;
    --    vr_dscritic:= 'Erro ao efetivar rating.';
    --  END IF;
          
    --  -- Sair
    --  RAISE vr_exc_erro;
        
    --END IF;
          
    -- Se foi solicitado o envio de LOG
    IF pr_flgerlog = 'S' THEN
      -- Gerar LOG de envio do e-mail
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => ''
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => rw_crapdat.dtmvtolt
                          ,pr_flgtrans => 0 --> FALSE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate,'SSSSS'))
                          ,pr_idseqttl => pr_idseqttl
                          ,pr_nmdatela => pr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
    END IF;
    
    -- Se chegamos neste ponto, n�o houve erro
    pr_des_reto := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno n�o OK
      pr_des_reto := 'NOK';

      -- Se ainda n�o tem registro de erro, criar com a critica
      IF pr_tab_erro.COUNT = 0 THEN
        -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
      END IF;

      -- Se foi solicitado o envio de LOG
      IF pr_flgerlog = 'S' THEN
        -- Gerar LOG de envio do e-mail
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => rw_crapdat.dtmvtolt
                            ,pr_flgtrans => 0 --> FALSE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;
      
      ROLLBACK;
     
    WHEN OTHERS THEN
      -- Retorno n�o OK
      pr_des_reto := 'NOK';
      
      -- Montar descri��o de erro n�o tratado
      vr_dscritic := 'Erro n�o tratado na RATI0001.pc_atualiza_rating> '||sqlerrm;
      
      -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => 0
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
                           
      -- Se foi solicitado o envio de LOG
      IF pr_flgerlog = 'S' THEN
        -- Gerar LOG de envio do e-mail
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => rw_crapdat.dtmvtolt
                            ,pr_flgtrans => 0 --> FALSE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);

      END IF;
      
      ROLLBACK;
      
  END pc_atualiza_rating;
  
  /*****************************************************************************
   Realiza calculo do rating, alteracao solicitada pela ATURAT
  *****************************************************************************/
  PROCEDURE pc_proc_calcula(pr_cdcooper IN crapcop.cdcooper%TYPE                           --> Codigo Cooperativa
                           ,pr_cdagenci IN crapass.cdagenci%TYPE                           --> Codigo Agencia
                           ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE                           --> Numero Caixa
                           ,pr_cdoperad IN crapnrc.cdoperad%TYPE                           --> Codigo Operador
                           ,pr_nrdconta IN crapass.nrdconta%TYPE                           --> Numero da Conta
                           ,pr_tpctrato IN crapnrc.tpctrrat%TYPE                           --> Tipo Contrato Rating
                           ,pr_nrctrato IN crapnrc.nrctrrat%TYPE                           --> Numero Contrato Rating
                           ,pr_flgcriar IN INTEGER                                         --> Indicado se deve criar o rating
                           ,pr_idorigem IN INTEGER                                         --> Identificador Origem
                           ,pr_nmdatela IN craptel.nmdatela%TYPE                           --> Nome da tela
                           ,pr_inproces IN INTEGER
                           ,pr_insitrat IN INTEGER
                           ,pr_rowidnrc IN ROWID                                           --> Registro de rating
                           ,pr_tab_rating_sing       IN rati0001.typ_tab_crapras           --> Registros gravados para rating singular
                           ,pr_tab_impress_risco_tl OUT rati0001.typ_tab_impress_risco     --> Registro Nota e risco do cooperado naquele Rating - PROVISAOTL
                           ,pr_indrisco OUT VARCHAR2                                       --> Indicador do risco
                           ,pr_nrnotrat OUT crapnrc.nrnotrat%TYPE                          --> N�mero da nota
                           ,pr_tab_erro OUT GENE0001.typ_tab_erro                          --> Tabela de retorno de erro
                           ,pr_des_reto OUT VARCHAR2                                       --> Ind. de retorno OK/NOK
                           ) IS

   
  /* ..........................................................................

     Programa: pc_proc_calcula         Antigo: b1wgen0043.p/proc_calcula
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Andrei - RKAM
     Data    : Maio/2016                          Ultima Atualizacao:  

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  : Realiza calculo do rating, alteracao solicitada pela ATURAT

     Alteracoes:  

  ............................................................................. */
    --------------- VARIAVEIS ----------------
    -- Variaveis para manter critica
    vr_exc_erro EXCEPTION;
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    
    --PL tables  
    vr_tab_impress_coop     RATI0001.typ_tab_impress_coop;
    vr_tab_impress_rating   RATI0001.typ_tab_impress_rating;
    vr_tab_impress_risco_cl RATI0001.typ_tab_impress_risco;
    vr_tab_impress_risco_tl RATI0001.typ_tab_impress_risco;
    vr_tab_impress_assina   RATI0001.typ_tab_impress_assina;
    vr_tab_efetivacao       RATI0001.typ_tab_efetivacao;
    vr_tab_ratings          RATI0001.typ_tab_ratings;
    vr_tab_crapras          RATI0001.typ_tab_crapras;
    vr_tab_erro             GENE0001.typ_tab_erro;
    
    --Variaveis locais
    vr_flgcriar INTEGER;
    vr_des_erro VARCHAR2(4000);

  BEGIN
    
    vr_flgcriar := pr_flgcriar;   

    IF pr_insitrat = 1 THEN
      
      RATI0001.pc_calcula_rating(pr_cdcooper => pr_cdcooper   --> Codigo Cooperativa
                                ,pr_cdagenci => pr_cdagenci   --> Codigo Agencia
                                ,pr_nrdcaixa => pr_nrdcaixa   --> Numero Caixa
                                ,pr_cdoperad => pr_cdoperad   --> Codigo Operador
                                ,pr_nrdconta => pr_nrdconta   --> Numero da Conta
                                ,pr_tpctrato => pr_tpctrato   --> Tipo Contrato Rating
                                ,pr_nrctrato => pr_nrctrato   --> Numero Contrato Rating
                                ,pr_flgcriar => vr_flgcriar   --> Indicado se deve criar o rating
                                ,pr_flgcalcu => 1             --> Indicador de calculo
                                ,pr_idseqttl => 1             --> Sequencial do Titular
                                ,pr_idorigem => pr_idorigem   --> Identificador Origem
                                ,pr_nmdatela => pr_nmdatela   --> Nome da tela
                                ,pr_flgerlog => 'N'           --> Identificador de gera��o de log
                                ,pr_tab_rating_sing      => pr_tab_rating_sing      --> Registros gravados para rati
                                ,pr_tab_impress_coop     => vr_tab_impress_coop     --> Registro impress�o da Cooper
                                ,pr_tab_impress_rating   => vr_tab_impress_rating   --> Registro itens do Rating
                                ,pr_tab_impress_risco_cl => vr_tab_impress_risco_cl --> Registro Nota e risco do coo
                                ,pr_tab_impress_risco_tl => pr_tab_impress_risco_tl --> Registro Nota e risco do coo
                                ,pr_tab_impress_assina   => vr_tab_impress_assina   --> Assinatura na impressao do R
                                ,pr_tab_efetivacao       => vr_tab_efetivacao       --> Registro dos itens da efetiv
                                ,pr_tab_ratings          => vr_tab_ratings          --> Informacoes com os Ratings d
                                ,pr_tab_crapras          => vr_tab_crapras          --> Tabela com os registros proc
                                ,pr_tab_erro             => vr_tab_erro             --> Tabela de retorno de erro
                                ,pr_des_reto             => vr_des_erro);           --> Ind. de retorno OK/NOK
                            
      -- Em caso de erro
      IF pr_des_reto <> 'OK' THEN
        
        --Se n�o tem erro na tabela
        IF pr_tab_erro.COUNT = 0 THEN          
          vr_cdcritic:= 0;
          vr_dscritic:= 'Erro ao calcular rating.';
        END IF;
          
        -- Sair
        RAISE vr_exc_erro;
        
      END IF;
          
    
    ELSE
      
      IF pr_flgcriar = 1 THEN        
      
        pc_atualiza_rating(pr_cdcooper             => pr_cdcooper          --> Codigo Cooperativa
                          ,pr_cdagenci             => pr_cdagenci          --> Codigo Agencia
                          ,pr_nrdcaixa             => pr_nrdcaixa          --> Numero Caixa
                          ,pr_cdoperad             => pr_cdoperad          --> Codigo Operador
                          ,pr_nrdconta             => pr_nrdconta          --> Numero da Conta
                          ,pr_tpctrato             => pr_tpctrato          --> Tipo Contrato Rating
                          ,pr_nrctrato             => pr_nrctrato          --> Numero Contrato Rating
                          ,pr_rowidnrc             => pr_rowidnrc          --> Registro de rating
                          ,pr_flgcriar             => 1                    --> Indicado se deve criar o rating
                          ,pr_idorigem             => pr_idorigem          --> Identificador Origem
                          ,pr_nmdatela             => pr_nmdatela          --> Nome da tela
                          ,pr_inproces             => pr_inproces          --> Situacao do sistema
                          ,pr_idseqttl             => 1                    --> Sequencial do titular
                          ,pr_flgerlog             => 'N'                  --> Gera log
                          ,pr_tab_efetivacao       => vr_tab_efetivacao    --> Registros gravados para rating singular
                          ,pr_tab_impress_risco_tl => pr_tab_impress_risco_tl --> Registro Nota e risco do cooperado naquele Rating - PROVISAOTL
                          ,pr_tab_erro             => vr_tab_erro          --> Tabela de retorno de erro
                          ,pr_des_reto             => pr_des_reto);        --> Ind. de retorno OK/NOK
                              
        -- Em caso de erro
        IF pr_des_reto <> 'OK' THEN
          
          --Se n�o tem erro na tabela
          IF pr_tab_erro.COUNT = 0 THEN           
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro ao atualizar rating.';
          END IF;
            
          -- Sair
          RAISE vr_exc_erro;
       
        END IF;
       
      END IF;
        
      RATI0001.pc_calcula_rating(pr_cdcooper => pr_cdcooper   --> Codigo Cooperativa
                                ,pr_cdagenci => pr_cdagenci   --> Codigo Agencia
                                ,pr_nrdcaixa => pr_nrdcaixa   --> Numero Caixa
                                ,pr_cdoperad => pr_cdoperad   --> Codigo Operador
                                ,pr_nrdconta => pr_nrdconta   --> Numero da Conta
                                ,pr_tpctrato => pr_tpctrato   --> Tipo Contrato Rating
                                ,pr_nrctrato => pr_nrctrato   --> Numero Contrato Rating
                                ,pr_flgcriar => vr_flgcriar   --> Indicado se deve criar o rating
                                ,pr_flgcalcu => 1             --> Indicador de calculo
                                ,pr_idseqttl => 1             --> Sequencial do Titular
                                ,pr_idorigem => pr_idorigem   --> Identificador Origem
                                ,pr_nmdatela => pr_nmdatela   --> Nome da tela
                                ,pr_flgerlog => 'N'           --> Identificador de gera��o de log
                                ,pr_tab_rating_sing      => pr_tab_rating_sing      --> Registros gravados para rating singular
                                ,pr_tab_impress_coop     => vr_tab_impress_coop     --> Registro impress�o da Cooperado
                                ,pr_tab_impress_rating   => vr_tab_impress_rating   --> Registro itens do Rating
                                ,pr_tab_impress_risco_cl => vr_tab_impress_risco_cl --> Registro Nota e risco do cooperado naquele Rating - PROVISAOCL
                                ,pr_tab_impress_risco_tl => pr_tab_impress_risco_tl --> Registro Nota e risco do cooperado naquele Rating - PROVISAOTL
                                ,pr_tab_impress_assina   => vr_tab_impress_assina   --> Assinatura na impressao do Rating
                                ,pr_tab_efetivacao       => vr_tab_efetivacao       --> Registro dos itens da efetiva��o
                                ,pr_tab_ratings          => vr_tab_ratings          --> Informacoes com os Ratings do Cooperado
                                ,pr_tab_crapras          => vr_tab_crapras          --> Tabela com os registros processados
                                ,pr_tab_erro             => vr_tab_erro             --> Tabela de retorno de erro
                                ,pr_des_reto             => vr_des_erro);           --> Ind. de retorno OK/NOK)�
                                
      -- Em caso de erro
      IF pr_des_reto <> 'OK' THEN
          
        --Se n�o tem erro na tabela
        IF pr_tab_erro.COUNT = 0 THEN           
          vr_cdcritic:= 0;
          vr_dscritic:= 'Erro ao calcular rating.';
        END IF;
            
        -- Sair
        RAISE vr_exc_erro;
       
      END IF;
     
    END IF;
    
    pr_indrisco:= vr_tab_impress_risco_cl(vr_tab_impress_risco_cl.first).dsdrisco;
    pr_nrnotrat:= vr_tab_impress_risco_cl(vr_tab_impress_risco_cl.first).vlrtotal; 
    
    -- Se chegamos neste ponto, n�o houve erro
    pr_des_reto := 'OK';
    

  EXCEPTION

    WHEN vr_exc_erro THEN
      -- Retorno n�o OK
      pr_des_reto := 'NOK';

      -- Se ainda n�o tem registro de erro, criar com a critica
      IF pr_tab_erro.COUNT = 0 THEN
        -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
      END IF;      
      
      -- Se esta marcado para criar registro, entao deve dar rollback
      IF pr_flgcriar = 1 THEN
        ROLLBACK;
      END IF;
      
    WHEN OTHERS THEN
      
      -- Retorno n�o OK
      pr_des_reto := 'NOK';
      
      -- Montar descri��o de erro n�o tratado
      vr_dscritic := 'Erro n�o tratado na RATI0001.pc_calcula_rating> '||sqlerrm;
      
      -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => 0
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);                           
                
      ROLLBACK;
      
  END pc_proc_calcula;
     
  /*****************************************************************************
   Verificar se um Rating efetivo pode ser Atualizado.
   Trazer o Contrato e risco a ser efetivado.      
  *****************************************************************************/
  PROCEDURE pc_verifica_atualizacao(pr_cdcooper IN crapcop.cdcooper%TYPE               --> Codigo Cooperativa
                                   ,pr_cdagenci IN crapass.cdagenci%TYPE               --> Codigo Agencia
                                   ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE               --> Numero Caixa
                                   ,pr_cdoperad IN crapnrc.cdoperad%TYPE               --> Codigo Operador
                                   ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE               --> Data de movimento
                                   ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE               --> Data do pr�ximo dia �til
                                   ,pr_inproces IN crapdat.inproces%TYPE               --> Situa��o do processo
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE               --> Numero da Conta
                                   ,pr_tpctrrat IN crapnrc.tpctrrat%TYPE               --> Tipo Contrato Rating
                                   ,pr_nrctrrat IN crapnrc.nrctrrat%TYPE               --> Numero Contrato Rating
                                   ,pr_idseqttl IN crapttl.idseqttl%TYPE               --> Sequencial do Titular
                                   ,pr_idorigem IN INTEGER                             --> Identificador Origem
                                   ,pr_nmdatela IN craptel.nmdatela%TYPE               --> Nome da tela
                                   ,pr_flgerlog IN VARCHAR2                            --> Identificador de gera��o de log
                                   ,pr_dsretorn IN BOOLEAN                             --> Retornar
                                   ,pr_tab_rating_sing IN rati0001.typ_tab_crapras     --> Registros gravados para rating singular
                                   ,pr_indrisco OUT VARCHAR2                           --> Indicador do risco
                                   ,pr_nrnotrat OUT NUMBER                             --> Nota do rating
                                   ,pr_rowidnrc OUT ROWID                              --> Rowid do rating
                                   ,pr_tab_erro             OUT GENE0001.typ_tab_erro  --> Tabela de retorno de erro
                                   ,pr_des_reto             OUT VARCHAR2               --> Ind. de retorno OK/NOK
                                   ) IS

  /* ..........................................................................

     Programa: pc_verifica_atualizacao         Antigo: b1wgen0043.p/verifica_atualizacao
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Andrei - RKAM
     Data    : Maio/2016.                          Ultima Atualizacao: 

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  : Procedure para veririficar se um rating pode ser atualizado.

     Alteracoes:  

  ............................................................................. */
  --------------- CURSORES  ----------------
    --Cursor para buscar o rating do cooperado
    CURSOR cr_crapnrc(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE
                     ,pr_nrctrrat IN crapnrc.nrctrrat%TYPE
                     ,pr_tpctrrat IN crapnrc.tpctrrat%TYPE) IS
    SELECT nrc.tpctrrat
          ,nrc.nrctrrat
          ,nrc.dtmvtolt
          ,nrc.insitrat
          ,nrc.progress_recid
      FROM crapnrc nrc
     WHERE nrc.cdcooper = pr_cdcooper
       AND nrc.nrdconta = pr_nrdconta
       AND nrc.nrctrrat = pr_nrctrrat
       AND nrc.tpctrrat = pr_tpctrrat;
    rw_crapnrc cr_crapnrc%ROWTYPE;
    
    --Cursor para buscar o rating do cooperado
    CURSOR cr_crapnrc2(pr_rowidnrc IN ROWID) IS
    SELECT nrc.tpctrrat
          ,nrc.nrctrrat
          ,nrc.nrnotrat
          ,nrc.progress_recid
          ,nrc.rowid
      FROM crapnrc nrc
     WHERE ROWID = pr_rowidnrc;
    rw_crapnrc2 cr_crapnrc2%ROWTYPE;

  --------------- VARIAVEIS ----------------
    -- Variaveis para manter critica
    vr_exc_erro EXCEPTION;
    vr_exc_saida EXCEPTION;
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    
    -- Vetor com dados de par�metro (CRAPDAT)
    rw_crapdat btch0001.rw_crapdat%TYPE;
    
    --PL tables  
    vr_tab_impress_coop     RATI0001.typ_tab_impress_coop;
    vr_tab_impress_rating   RATI0001.typ_tab_impress_rating;
    vr_tab_impress_risco_cl RATI0001.typ_tab_impress_risco;
    vr_tab_impress_risco_tl RATI0001.typ_tab_impress_risco;
    vr_tab_impress_assina   RATI0001.typ_tab_impress_assina;
    vr_tab_efetivacao       RATI0001.typ_tab_efetivacao;
    vr_tab_ratings          RATI0001.typ_tab_ratings;
    vr_tab_crapras          RATI0001.typ_tab_crapras;
    vr_tab_erro             GENE0001.typ_tab_erro;
    

    -- Variaveis para manter o log
    vr_dsorigem  VARCHAR2(50);
    vr_dstransa  VARCHAR2(50);
    vr_nrdrowid  ROWID;

    -- Variaveis locais
    vr_dtmvtolt DATE;
    vr_nrctrrat crapnrc.nrctrrat%TYPE;
    vr_dsoperac VARCHAR2(20);
    vr_flgcriar INTEGER := 0;
    
  BEGIN
    
    -- Montar variaveis para log
    IF pr_flgerlog = 'S'  THEN
      vr_dsorigem := TRIM(gene0001.vr_vet_des_origens(pr_idorigem));
      vr_dstransa := 'Verificar se o Rating em questao pode ser atualizado.';
    END IF;

    OPEN cr_crapnrc(pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => pr_nrdconta
                   ,pr_nrctrrat => pr_nrctrrat
                   ,pr_tpctrrat => pr_tpctrrat);
                   
    FETCH cr_crapnrc INTO rw_crapnrc;
    
    IF cr_crapnrc%NOTFOUND THEN
    
      --Fecha o cursor
      CLOSE cr_crapnrc;
      
      vr_dscritic := NULL;
      vr_cdcritic := 925; 
      
      RAISE vr_exc_erro;      
      
    ELSE
      
      --Fecha o cursor
      CLOSE cr_crapnrc; 
    
    END IF;        
    
    /* Se passou do mes, so apos 6 meses da ult. Atualizacao */
    /* Rosangela */
    IF pr_cdcooper <> 3 THEN
    
      IF TRUNC(pr_dtmvtolt,'MM') <> TRUNC(rw_crapnrc.dtmvtolt,'MM')      OR 
         TRUNC(pr_dtmvtolt,'RRRR') <>  TRUNC(rw_crapnrc.dtmvtolt,'RRRR') THEN
         
        vr_dtmvtolt := add_months(rw_crapnrc.dtmvtolt, + 6 );
   
        /* Validacao para nao verificar o 6 meses, para poder
          piorar o ranting da cooperativa, solicitacao 
          Rodrigo Imthu, Debora. Alteracao sera registrada 
          em ata pela cooperativa Alto Vale                */
        IF ((pr_cdcooper = 16)           AND 
           (pr_dtmvtolt = '12/30/2014'   OR
            pr_dtmvtolt = '12/31/2014'   OR
            pr_dtmvtolt = '11/30/2015'   OR
            pr_dtmvtolt = '12/22/2015'   OR
            pr_dtmvtolt = '12/23/2015'   OR
            pr_dtmvtolt = '12/29/2015')) THEN
         
          NULL;
         
        /* Se hoje nao � maior do que a ult. altera�ao  mais 6 meses*/
        ELSIF NOT pr_dtmvtolt >= vr_dtmvtolt THEN
         
          IF NOT(TRUNC(pr_dtmvtolt,'MM') = TRUNC(vr_dtmvtolt,'MM')      AND
                 TRUNC(pr_dtmvtolt,'RRRR') = TRUNC(vr_dtmvtolt,'RRRR')) THEN
            
            vr_cdcritic := 0;
            vr_dscritic := 'Atualizacao so permitida 6 meses apos a alteracao.';
                      
            RAISE vr_exc_erro;   
          
          END IF;                         
           
        END IF; 
        
      END IF;
      
    END IF;
    
    /* Se o Rating nao for o efetivo volta ... */
    IF rw_crapnrc.insitrat <> 2 THEN
      
      RAISE vr_exc_saida; 
      
    END IF;
    
    /* Para cooperativas singulares na central nao verifica atualizacao */
    IF pr_cdcooper = 3 THEN
      
      IF pr_dsretorn THEN
        
        RAISE vr_exc_saida; 
      
      END IF;
    
    END IF;
    
    /* No mesmo mes e ano pode atualizar qualquer Rating. */
    /* Ratings propostos */
    pc_procura_pior_nota(pr_cdcooper => pr_cdcooper --> C�digo da Cooperativa
                        ,pr_nrdconta => pr_nrdconta --> Conta do associado
                        ,pr_indrisco => pr_indrisco --> Risco do pior rating
                        ,pr_rowidnrc => pr_rowidnrc --> Rowid do pior rating
                        ,pr_nrctrrat => vr_nrctrrat --> N�mero do contrato do pior rating
                        ,pr_dsoperac => vr_dsoperac --> Descri��o da opera��o do rating
                        ,pr_cdcritic => vr_cdcritic
                        ,pr_dscritic => vr_dscritic);
                        
    -- Se houve erro
    IF vr_cdcritic IS NOT NULL OR 
       vr_dscritic IS NOT NULL THEN
      -- Encerrar o processo
      RAISE vr_exc_erro;
    END IF;
    
    /* Calculo imaginario para verificar a nota com a qual ficaria */
    RATI0001.pc_calcula_rating(pr_cdcooper => pr_cdcooper   --> Codigo Cooperativa
                              ,pr_cdagenci => pr_cdagenci   --> Codigo Agencia
                              ,pr_nrdcaixa => pr_nrdcaixa   --> Numero Caixa
                              ,pr_cdoperad => pr_cdoperad   --> Codigo Operador
                              ,pr_nrdconta => pr_nrdconta   --> Numero da Conta
                              ,pr_tpctrato => pr_tpctrrat   --> Tipo Contrato Rating
                              ,pr_nrctrato => pr_nrctrrat   --> Numero Contrato Rating
                              ,pr_flgcriar => vr_flgcriar   --> Indicado se deve criar o rating
                              ,pr_flgcalcu => 1             --> Indicador de calculo
                              ,pr_idseqttl => 1             --> Sequencial do Titular
                              ,pr_idorigem => pr_idorigem   --> Identificador Origem
                              ,pr_nmdatela => pr_nmdatela   --> Nome da tela
                              ,pr_flgerlog => 'N'           --> Identificador de gera��o de log
                              ,pr_tab_rating_sing      => pr_tab_rating_sing      --> Registros gravados para rati
                              ,pr_tab_impress_coop     => vr_tab_impress_coop     --> Registro impress�o da Cooper
                              ,pr_tab_impress_rating   => vr_tab_impress_rating   --> Registro itens do Rating
                              ,pr_tab_impress_risco_cl => vr_tab_impress_risco_cl --> Registro Nota e risco do coo
                              ,pr_tab_impress_risco_tl => vr_tab_impress_risco_tl --> Registro Nota e risco do coo
                              ,pr_tab_impress_assina   => vr_tab_impress_assina   --> Assinatura na impressao do R
                              ,pr_tab_efetivacao       => vr_tab_efetivacao       --> Registro dos itens da efetiv
                              ,pr_tab_ratings          => vr_tab_ratings          --> Informacoes com os Ratings d
                              ,pr_tab_crapras          => vr_tab_crapras          --> Tabela com os registros proc
                              ,pr_tab_erro             => pr_tab_erro             --> Tabela de retorno de erro
                              ,pr_des_reto             => pr_des_reto);           --> Ind. de retorno OK/NOK
                            
    -- Em caso de erro
    IF pr_des_reto <> 'OK' THEN
        
      --Se n�o tem erro na tabela
      IF pr_tab_erro.COUNT = 0 THEN          
        vr_cdcritic:= 0;
        vr_dscritic:= 'Erro ao calcular rating.';
      END IF;
          
      -- Sair
      RAISE vr_exc_erro;
        
    END IF;
    
    /* O pior rating proposto */
    OPEN cr_crapnrc2(pr_rowidnrc => pr_rowidnrc);
       
    FETCH cr_crapnrc2 INTO rw_crapnrc2;
    
    /* Usar a pior nota */
    IF cr_crapnrc2%NOTFOUND OR
       vr_tab_impress_risco_cl(vr_tab_impress_risco_cl.first).vlrtotal >= rw_crapnrc2.nrnotrat THEN
       
      pr_nrnotrat := vr_tab_impress_risco_cl(vr_tab_impress_risco_cl.first).vlrtotal;
      pr_indrisco := vr_tab_impress_risco_cl(vr_tab_impress_risco_cl.first).dsdrisco;
      pr_rowidnrc := rw_crapnrc2.rowid;
       
    ELSE
      
      /* O indrisco e rowid nao precisa atribuir pois */
      /* ja veio da procedure procura_pior_nota */
      pr_nrnotrat := rw_crapnrc2.nrnotrat;
       
    END IF;  
    
    --Fechar o cursor
    CLOSE cr_crapnrc2;
    
    -- Se chegamos neste ponto, n�o houve erro
    pr_des_reto := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno n�o OK
      pr_des_reto := 'NOK';

      -- Se ainda n�o tem registro de erro, criar com a critica
      IF pr_tab_erro.COUNT = 0 THEN
        -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
      END IF;

      -- Se foi solicitado o envio de LOG
      IF pr_flgerlog = 'S' THEN
        -- Gerar LOG de envio do e-mail
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => rw_crapdat.dtmvtolt
                            ,pr_flgtrans => 0 --> FALSE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;
      
    WHEN vr_exc_saida THEN
        
      -- Retorno OK
      pr_des_reto := 'OK';
    
    WHEN OTHERS THEN
      -- Retorno n�o OK
      pr_des_reto := 'NOK';
      
      -- Montar descri��o de erro n�o tratado
      vr_dscritic := 'Erro n�o tratado na RATI0001.pc_verifica_atualizacao> '||sqlerrm;
      
      -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => 0
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
                           
      -- Se foi solicitado o envio de LOG
      IF pr_flgerlog = 'S' THEN
        -- Gerar LOG de envio do e-mail
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => rw_crapdat.dtmvtolt
                            ,pr_flgtrans => 0 --> FALSE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);

      END IF;
            
  END pc_verifica_atualizacao;
  
  /*****************************************************************************
   Validacao dos campos que envolvem <F7> do rating na proposta de emprestimo,
   contratos de cheque especial e descontos
  *****************************************************************************/
  PROCEDURE pc_valida_itens_rating(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo Cooperativa
                                  ,pr_cdagenci IN crapass.cdagenci%TYPE --> Codigo Agencia
                                  ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Numero Caixa
                                  ,pr_cdoperad IN crapnrc.cdoperad%TYPE --> Codigo Operador
                                  ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data de movimento
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE --> Numero da Conta
                                  ,pr_nrgarope IN craprad.nrseqite%TYPE --> Numero da garantia da operacao
                                  ,pr_nrinfcad IN craprad.nrseqite%TYPE --> Sequencia do Item relacionado a Informacoes cadastrais
                                  ,pr_nrliquid IN craprad.nrseqite%TYPE --> Sequencia relacionada ao item liquidez das Garantias (rating)
                                  ,pr_nrpatlvr IN craprad.nrseqite%TYPE --> Sequencia do item relativo ao patrimonio pessoal livre do endividamento (rating)
                                  ,pr_nrperger IN craprad.nrseqite%TYPE --> Percepcao geral com relacao a empresa (rating)
                                  ,pr_idseqttl IN INTEGER               --> Sequencial do titular
                                  ,pr_idorigem IN INTEGER               --> Identificador Origem
                                  ,pr_nmdatela IN craptel.nmdatela%TYPE --> Nome da tela
                                  ,pr_flgerlog IN INTEGER               --> Identificador de gera��o de log
                                  ,pr_tab_erro OUT GENE0001.typ_tab_erro--> Tabela de retorno de erro
                                  ,pr_des_reto OUT VARCHAR2             --> Ind. de retorno OK/NOK
                                  ) IS

  /* ..........................................................................

     Programa: pc_valida_itens_rating         Antigo: b1wgen0043.p/valida-itens-rating
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Andrei - RKAM
     Data    : Maio/2016.                          Ultima Atualizacao: 

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  :  Validacao dos campos que envolvem <F7> do rating na proposta de emprestimo,
                  contratos de cheque especial e descontos

     Alteracoes:  

  ............................................................................. */
  --------------- CURSORES  ----------------
    --Busca associado
    CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%TYPE,
                      pr_nrdconta crapass.nrdconta%TYPE) IS
    SELECT inpessoa
      FROM crapass
     WHERE crapass.cdcooper = pr_cdcooper
       AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%rowtype;
    

  --------------- VARIAVEIS ----------------
    -- Variaveis para manter critica
    vr_exc_erro EXCEPTION;
    vr_exc_saida EXCEPTION;
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    
    -- Vetor com dados de par�metro (CRAPDAT)
    rw_crapdat btch0001.rw_crapdat%TYPE;
    
    -- Variaveis para manter o log
    vr_dsorigem  VARCHAR2(50);
    vr_dstransa  VARCHAR2(50);
    vr_nrdrowid  ROWID;
 
  BEGIN
    
    -- Montar variaveis para log
    IF pr_flgerlog = 1 THEN
      vr_dsorigem := TRIM(gene0001.vr_vet_des_origens(pr_idorigem));
      vr_dstransa := 'Validar itens que compoem o RATING.';
    END IF;

    OPEN cr_crapass(pr_cdcooper => pr_cdcooper       
                   ,pr_nrdconta => pr_nrdconta);
                   
    FETCH cr_crapass INTO rw_crapass;
    
    IF cr_crapass%NOTFOUND THEN
      
      --Fechar o cursor
      CLOSE cr_crapass;
      
      --Monta mensagem de critica
      vr_cdcritic:= 9;
      vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_dscritic);
        
      RAISE vr_exc_erro;
      
    ELSE
      
      --Fechar o cursor
      CLOSE cr_crapass; 
    
    END IF;                   
    
    /* Para cooperativa 3 somente sera necessario validar o campo Liquidez*/
    IF pr_cdcooper = 3 THEN
      
      IF NOT fn_valida_item_rating (pr_cdcooper => pr_cdcooper
                               ,pr_nrtopico => 3 /*6*/
                               ,pr_nritetop => 3 /*2*/
                               ,pr_nrseqite => pr_nrinfcad) THEN
     
        --Monta mensagem de critica
        vr_cdcritic:= 0;
        vr_dscritic:= '014 - Opcao errada - Informacoes cadastrais.';
          
        RAISE vr_exc_erro;                                 
                               
      END IF; 
      
      IF NOT fn_valida_item_rating (pr_cdcooper => pr_cdcooper
                               ,pr_nrtopico => 4
                               ,pr_nritetop => 3
                               ,pr_nrseqite => pr_nrliquid) THEN
     
        --Monta mensagem de critica
        vr_cdcritic:= 0;
        vr_dscritic:= '014 - Opcao errada - Liquidez das garantias.';
          
        RAISE vr_exc_erro;                                 
                               
      END IF;                               
            
      -- Se chegamos neste ponto, n�o houve erro
      pr_des_reto := 'OK';   
      
      RETURN;                   
    
    END IF;
    
    IF rw_crapass.inpessoa = 1 THEN
      
      IF NOT fn_valida_item_rating (pr_cdcooper => pr_cdcooper
                                   ,pr_nrtopico => 2
                                   ,pr_nritetop => 2
                                   ,pr_nrseqite => pr_nrgarope) THEN
         
        --Monta mensagem de critica
        vr_cdcritic:= 0;
        vr_dscritic:= '014 - Opcao errada - Garantia.';
          
        RAISE vr_exc_erro;                                 
                               
      END IF;   
    
      IF NOT fn_valida_item_rating (pr_cdcooper => pr_cdcooper
                                   ,pr_nrtopico => 1
                                   ,pr_nritetop => 4
                                   ,pr_nrseqite => pr_nrinfcad) THEN
         
        --Monta mensagem de critica
        vr_cdcritic:= 0;
        vr_dscritic:= '014 - Opcao errada - Informacoes cadastrais.';
          
        RAISE vr_exc_erro;                                 
                               
      END IF; 
    
      IF NOT fn_valida_item_rating (pr_cdcooper => pr_cdcooper
                                   ,pr_nrtopico => 2
                                   ,pr_nritetop => 3
                                   ,pr_nrseqite => pr_nrliquid) THEN
         
        --Monta mensagem de critica
        vr_cdcritic:= 0;
        vr_dscritic:= '014 - Opcao errada - Liquidez das garantias.';
          
        RAISE vr_exc_erro;                                 
                               
      END IF; 
      
      IF NOT fn_valida_item_rating (pr_cdcooper => pr_cdcooper
                                   ,pr_nrtopico => 1 /*3*/
                                   ,pr_nritetop => 8 /*3*/
                                   ,pr_nrseqite => pr_nrpatlvr) THEN
         
        --Monta mensagem de critica
        vr_cdcritic:= 0;
        vr_dscritic:= '014 - Opcao errada - Patrimonio pessoal livre.';
          
        RAISE vr_exc_erro;                                 
                               
      END IF; 
      
    --Pessoa juridica
    ELSE
      
      IF NOT fn_valida_item_rating (pr_cdcooper => pr_cdcooper
                                   ,pr_nrtopico => 4
                                   ,pr_nritetop => 2
                                   ,pr_nrseqite => pr_nrgarope) THEN
         
        --Monta mensagem de critica
        vr_cdcritic:= 0;
        vr_dscritic:= '014 - Opcao errada - Garantia.';
          
        RAISE vr_exc_erro;                                 
                               
      END IF; 
      
      IF NOT fn_valida_item_rating (pr_cdcooper => pr_cdcooper
                                   ,pr_nrtopico => 3 /*6*/
                                   ,pr_nritetop => 11 /*3*/
                                   ,pr_nrseqite => pr_nrperger) THEN
         
        --Monta mensagem de critica
        vr_cdcritic:= 0;
        vr_dscritic:= '014 - Opcao errada - Percepcao geral (Empresa).';
          
        RAISE vr_exc_erro;                                 
                               
      END IF; 
    
      IF NOT fn_valida_item_rating (pr_cdcooper => pr_cdcooper
                                   ,pr_nrtopico => 3 /*6*/
                                   ,pr_nritetop => 3 /*2*/
                                   ,pr_nrseqite => pr_nrinfcad) THEN
         
        --Monta mensagem de critica
        vr_cdcritic:= 0;
        vr_dscritic:= '014 - Opcao errada - Informacoes cadastrais.';
          
        RAISE vr_exc_erro;                                 
                               
      END IF; 
      
      IF NOT fn_valida_item_rating (pr_cdcooper => pr_cdcooper
                               ,pr_nrtopico => 4
                               ,pr_nritetop => 3
                               ,pr_nrseqite => pr_nrliquid) THEN
     
        --Monta mensagem de critica
        vr_cdcritic:= 0;
        vr_dscritic:= '014 - Opcao errada - Liquidez das garantias.';
          
        RAISE vr_exc_erro;                                 
                               
      END IF;  
      
      IF NOT fn_valida_item_rating (pr_cdcooper => pr_cdcooper
                               ,pr_nrtopico => 3 /*5*/
                               ,pr_nritetop => 9 /*4*/
                               ,pr_nrseqite => pr_nrpatlvr) THEN
     
        --Monta mensagem de critica
        vr_cdcritic:= 0;
        vr_dscritic:= '014 - Opcao errada -  Patrimonio pessoal livre.';
          
        RAISE vr_exc_erro;                                 
                               
      END IF;  
      
      
    END IF;   
    
    -- Se chegamos neste ponto, n�o houve erro
    pr_des_reto := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno n�o OK
      pr_des_reto := 'NOK';

      -- Se ainda n�o tem registro de erro, criar com a critica
      IF pr_tab_erro.COUNT = 0 THEN
        -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
      END IF;

      -- Se foi solicitado o envio de LOG
      IF pr_flgerlog = 1 THEN
        -- Gerar LOG de envio do e-mail
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => pr_dtmvtolt
                            ,pr_flgtrans => 0 --> FALSE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;
      
    WHEN vr_exc_saida THEN
        
      -- Retorno OK
      pr_des_reto := 'OK';
    
    WHEN OTHERS THEN
      -- Retorno n�o OK
      pr_des_reto := 'NOK';
      
      -- Montar descri��o de erro n�o tratado
      vr_dscritic := 'Erro n�o tratado na RATI0001.pc_valida_itens_rating> '||sqlerrm;
      
      -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => 0
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
                           
      -- Se foi solicitado o envio de LOG
      IF pr_flgerlog = 1 THEN
        -- Gerar LOG de envio do e-mail
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => pr_dtmvtolt
                            ,pr_flgtrans => 0 --> FALSE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);

      END IF;
            
  END pc_valida_itens_rating;
  
  /*****************************************************************************
   Verificar se existe algum rating relacionado a proposta em questao.
   Utilizada para verificar se precisa ser re calculado na hora da impressao.
   Se existir pega os dados da tabela crapnrc senao re calcula.
   Chamar procedure para validar os campos obrigatorios do Rating.
  *****************************************************************************/
  PROCEDURE pc_verifica_rating(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo Cooperativa
                              ,pr_cdagenci IN crapass.cdagenci%TYPE --> Codigo Agencia
                              ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Numero Caixa
                              ,pr_cdoperad IN crapnrc.cdoperad%TYPE --> Codigo Operador
                              ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data de movimento
                              ,pr_nrdconta IN crapass.nrdconta%TYPE --> Numero da Conta
                              ,pr_nrctrrat IN crapnrc.nrctrrat%TYPE --> Numero Contrato Rating
                              ,pr_tpctrrat IN crapnrc.tpctrrat%TYPE --> Tipo Contrato Rating
                              ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Sequencial do Titular
                              ,pr_idorigem IN INTEGER               --> Identificador Origem
                              ,pr_nmdatela IN craptel.nmdatela%TYPE --> Nome da tela
                              ,pr_flgcriar IN INTEGER               --> Criar
                              ,pr_flgerlog IN INTEGER               --> Identificador de gera��o de log
                              ,pr_flgcalcu OUT INTEGER                  --> Indicador do risco
                              ,pr_tab_erro OUT GENE0001.typ_tab_erro    --> Tabela de retorno de erro
                              ,pr_des_reto OUT VARCHAR2                 --> Ind. de retorno OK/NOK
                              ) IS

  /* ..........................................................................

     Programa: pc_verifica_rating         Antigo: b1wgen0043.p/verifica_rating
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Andrei - RKAM
     Data    : Maio/2016.                          Ultima Atualizacao: 

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  :  Verificar se existe algum rating relacionado a proposta em questao.
                  Utilizada para verificar se precisa ser re calculado na hora da impressao.
                  Se existir pega os dados da tabela crapnrc senao re calcula.
                  Chamar procedure para validar os campos obrigatorios do Rating.

     Alteracoes:  

  ............................................................................. */
  --------------- CURSORES  ----------------
    --Cursor para buscar o rating do cooperado
    CURSOR cr_crapnrc(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE
                     ,pr_nrctrrat IN crapnrc.nrctrrat%TYPE
                     ,pr_tpctrrat IN crapnrc.tpctrrat%TYPE) IS
    SELECT nrc.tpctrrat
          ,nrc.nrctrrat
          ,nrc.dtmvtolt
          ,nrc.insitrat
          ,nrc.progress_recid
      FROM crapnrc nrc
     WHERE nrc.cdcooper = pr_cdcooper
       AND nrc.nrdconta = pr_nrdconta
       AND nrc.nrctrrat = pr_nrctrrat
       AND nrc.tpctrrat = pr_tpctrrat;
    rw_crapnrc cr_crapnrc%ROWTYPE;
    
    --Cursor para buscar o cadastro de proposta
    CURSOR cr_crapprp(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE
                     ,pr_nrctrato IN crapprp.nrctrato%TYPE
                     ,pr_tpctrato IN crapprp.tpctrato%TYPE) IS
    SELECT prp.nrgarope
          ,prp.nrinfcad
          ,prp.nrliquid
          ,prp.nrpatlvr
          ,prp.nrperger          
      FROM crapprp prp
     WHERE prp.cdcooper = pr_cdcooper
       AND prp.nrdconta = pr_nrdconta
       AND prp.nrctrato = pr_nrctrato 
       AND prp.nrctrato = pr_nrctrato;
    rw_crapprp cr_crapprp%ROWTYPE;

    --Cursor para buscar o limite
    CURSOR cr_craplim(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE
                     ,pr_nrctrlim IN craplim.nrctrlim%TYPE
                     ,pr_tpctrlim IN craplim.tpctrlim%TYPE) IS
    SELECT lim.nrgarope
          ,lim.nrinfcad
          ,lim.nrliquid
          ,lim.nrpatlvr
          ,lim.nrperger          
      FROM craplim lim
     WHERE lim.cdcooper = pr_cdcooper
       AND lim.nrdconta = pr_nrdconta
       AND lim.nrctrlim = pr_nrctrlim 
       AND lim.nrctrlim = pr_nrctrlim;
    rw_craplim cr_craplim%ROWTYPE;

  --------------- VARIAVEIS ----------------
    -- Variaveis para manter critica
    vr_exc_erro EXCEPTION;
    vr_exc_saida EXCEPTION;
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    
    -- Variaveis para manter o log
    vr_dsorigem  VARCHAR2(50);
    vr_dstransa  VARCHAR2(54);
    vr_nrdrowid  ROWID;

    -- Variaveis locais
    vr_nrgarope INTEGER;
    vr_nrinfcad INTEGER;
    vr_nrliquid INTEGER;
    vr_nrpatlvr INTEGER;
    vr_nrperger INTEGER;  
    
  BEGIN
    
    -- Montar variaveis para log
    IF pr_flgerlog = 1 THEN
      vr_dsorigem := TRIM(gene0001.vr_vet_des_origens(pr_idorigem));
      vr_dstransa := 'Verifica se existe Rating para a proposta em questao.';
    END IF;

    OPEN cr_crapnrc(pr_cdcooper => pr_cdcooper       
                   ,pr_nrdconta => pr_nrdconta
                   ,pr_nrctrrat => pr_nrctrrat
                   ,pr_tpctrrat => pr_tpctrrat);
                   
    FETCH cr_crapnrc INTO rw_crapnrc;
    
    IF cr_crapnrc%NOTFOUND THEN
      
      pr_flgcalcu := 1;
      
    ELSE
      
      pr_flgcalcu := 0;
    
    END IF;                   

    --Fechar o cursor
    CLOSE cr_crapnrc;
    
    --Emprestimo
    IF pr_tpctrrat = 90 THEN
      
      OPEN cr_crapprp(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_tpctrato => pr_tpctrrat
                     ,pr_nrctrato => pr_nrctrrat);
                     
      FETCH cr_crapprp INTO rw_crapprp;
      
      IF cr_crapprp%NOTFOUND THEN
        
        --Fechar o cursor
        CLOSE cr_crapprp;
        
        --Monta mensagem de critica
        vr_cdcritic:= 356;
        vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_dscritic);
        
        -- Sair
        RAISE vr_exc_erro;
      
      END IF;
                           
      --Fechar o cursor
      CLOSE cr_crapprp;
      
      vr_nrgarope := rw_crapprp.nrgarope;
      vr_nrinfcad := rw_crapprp.nrinfcad;
      vr_nrliquid := rw_crapprp.nrliquid;
      vr_nrpatlvr := rw_crapprp.nrpatlvr;
      vr_nrperger := rw_crapprp.nrperger;  
    
    --Descontos/ Cheque Especial
    ELSE
      
      OPEN cr_craplim(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_tpctrlim => pr_tpctrrat
                     ,pr_nrctrlim => pr_nrctrrat);
                     
      FETCH cr_craplim INTO rw_craplim;
      
      IF cr_craplim%NOTFOUND THEN
        
        --Fechar o cursor
        CLOSE cr_craplim;
        
        --Monta mensagem de critica
        vr_cdcritic:= 484;
        vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_dscritic);
        
        -- Sair
        RAISE vr_exc_erro;
      
      END IF;
                           
      --Fechar o cursor
      CLOSE cr_craplim;
      
      vr_nrgarope := rw_craplim.nrgarope;
      vr_nrinfcad := rw_craplim.nrinfcad;
      vr_nrliquid := rw_craplim.nrliquid;
      vr_nrpatlvr := rw_craplim.nrpatlvr;
      vr_nrperger := rw_craplim.nrperger;  
    
    END IF;
    
    pc_valida_itens_rating(pr_cdcooper => pr_cdcooper --> Codigo Cooperativa
                          ,pr_cdagenci => pr_cdagenci --> Codigo Agencia
                          ,pr_nrdcaixa => pr_nrdcaixa --> Numero Caixa
                          ,pr_cdoperad => pr_cdoperad --> Codigo Operador
                          ,pr_dtmvtolt => pr_dtmvtolt --> Data de movimento
                          ,pr_nrdconta => pr_nrdconta --> Numero da Conta
                          ,pr_nrgarope => vr_nrgarope --> Numero da garantia da operacao
                          ,pr_nrinfcad => vr_nrinfcad --> Sequencia do Item relacionado a Informacoes cadastrais
                          ,pr_nrliquid => vr_nrliquid --> Sequencia relacionada ao item liquidez das Garantias (rating)
                          ,pr_nrpatlvr => vr_nrpatlvr --> Sequencia do item relativo ao patrimonio pessoal livre do endividamento (rating)
                          ,pr_nrperger => vr_nrperger --> Percepcao geral com relacao a empresa (rating)
                          ,pr_idseqttl => pr_idseqttl --> Sequencial do titular
                          ,pr_idorigem => pr_idorigem --> Identificador Origem
                          ,pr_nmdatela => pr_nmdatela --> Nome da tela
                          ,pr_flgerlog => pr_flgerlog --> Identificador de gera��o de log
                          ,pr_tab_erro => pr_tab_erro --> Tabela de retorno de erro
                          ,pr_des_reto => pr_des_reto --> Ind. de retorno OK/NOK
                          );
                          
    -- Em caso de erro
    IF pr_des_reto <> 'OK' THEN
        
      --Se n�o tem erro na tabela
      IF pr_tab_erro.COUNT = 0 THEN          
        vr_cdcritic:= 0;
        vr_dscritic:= 'Campos obrigatorios para o Rating nao preenchidos.';
      END IF;
          
      -- Sair
      RAISE vr_exc_erro;
        
    END IF;                      
                                  
    -- Se chegamos neste ponto, n�o houve erro
    pr_des_reto := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno n�o OK
      pr_des_reto := 'NOK';

      -- Se ainda n�o tem registro de erro, criar com a critica
      IF pr_tab_erro.COUNT = 0 THEN
        -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
      END IF;

      -- Se foi solicitado o envio de LOG
      IF pr_flgerlog = 1 THEN
        -- Gerar LOG de envio do e-mail
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => pr_dtmvtolt
                            ,pr_flgtrans => 0 --> FALSE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;
      
    WHEN vr_exc_saida THEN
        
      -- Retorno OK
      pr_des_reto := 'OK';
    
    WHEN OTHERS THEN
      -- Retorno n�o OK
      pr_des_reto := 'NOK';
      
      -- Montar descri��o de erro n�o tratado
      vr_dscritic := 'Erro n�o tratado na RATI0001.pc_verifica_rating '||sqlerrm;
      
      -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => 0
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
                           
      -- Se foi solicitado o envio de LOG
      IF pr_flgerlog = 1 THEN
        -- Gerar LOG de envio do e-mail
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => pr_dtmvtolt
                            ,pr_flgtrans => 0 --> FALSE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);

      END IF;
            
  END pc_verifica_rating;
  
  /*****************************************************************************
   Adapta��o do fonte fontes/gera_rating.p para utiliza��o no Ayllos WEB
               Gerar o rating do cooperado e dados de impressao    
  *****************************************************************************/
  PROCEDURE pc_gera_rating(pr_cdcooper IN crapcop.cdcooper%TYPE            --> Codigo Cooperativa
                          ,pr_cdagenci IN crapass.cdagenci%TYPE            --> Codigo Agencia
                          ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE            --> Numero Caixa
                          ,pr_cdoperad IN crapnrc.cdoperad%TYPE            --> Codigo Operador
                          ,pr_nmdatela IN craptel.nmdatela%TYPE            --> Nome da tela
                          ,pr_idorigem IN INTEGER                          --> Identificador Origem
                          ,pr_nrdconta IN crapass.nrdconta%TYPE            --> Numero da Conta
                          ,pr_idseqttl IN crapttl.idseqttl%TYPE            --> Sequencial do Titular
                          ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE            --> Data de movimento
                          ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE            --> Data do pr�ximo dia �til
                          ,pr_inproces IN crapdat.inproces%TYPE            --> Situa��o do processo
                          ,pr_tpctrrat IN crapnrc.tpctrrat%TYPE            --> Tipo Contrato Rating
                          ,pr_nrctrrat IN crapnrc.nrctrrat%TYPE            --> Numero Contrato Rating
                          ,pr_flgcriar IN INTEGER                          --> Criar rating
                          ,pr_flgerlog IN INTEGER                          --> Identificador de gera��o de log
                          ,pr_tab_rating_sing IN rati0001.typ_tab_crapras  --> Registros gravados para rating singular
                          ,pr_tab_impress_coop     OUT rati0001.typ_tab_impress_coop     --> Registro impress�o da Cooperado
                          ,pr_tab_impress_rating   OUT rati0001.typ_tab_impress_rating   --> Registro itens do Rating
                          ,pr_tab_impress_risco_cl OUT rati0001.typ_tab_impress_risco    --> Registro Nota e risco do cooperado naquele Rating - PROVISAOCL
                          ,pr_tab_impress_risco_tl OUT rati0001.typ_tab_impress_risco    --> Registro Nota e risco do cooperado naquele Rating - PROVISAOTL
                          ,pr_tab_impress_assina   OUT rati0001.typ_tab_impress_assina   --> Assinatura na impressao do Rating
                          ,pr_tab_efetivacao       OUT rati0001.typ_tab_efetivacao       --> Registro dos itens da efetiva��o
                          ,pr_tab_ratings          OUT rati0001.typ_tab_ratings          --> Informacoes com os Ratings do Cooperado
                          ,pr_tab_crapras          OUT rati0001.typ_tab_crapras          --> Tabela com os registros processados
                          ,pr_tab_erro             OUT GENE0001.typ_tab_erro             --> Tabela de retorno de erro
                          ,pr_des_reto             OUT VARCHAR2                          --> Ind. de retorno OK/NOK
                          ) IS

  /* ..........................................................................

     Programa: pc_gera_rating         Antigo: b1wgen0043.p/gera_rating
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Andrei - RKAM
     Data    : Maio/2016.                          Ultima Atualizacao: 

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  :  Gerar o rating do cooperado e dados de impressao

     Alteracoes:  

  ............................................................................. */

    ------------- VARIAVEIS ----------------
    -- Variaveis para manter critica
    vr_exc_erro EXCEPTION;
    vr_exc_saida EXCEPTION;
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    
    -- Vetor com dados de par�metro (CRAPDAT)
    rw_crapdat btch0001.rw_crapdat%TYPE;
    
    -- Variaveis para manter o log
    vr_dsorigem  VARCHAR2(50);
    vr_dstransa  VARCHAR2(54);
    vr_nrdrowid  ROWID;
    vr_flgcalcu  INTEGER;
    vr_flgcriar  INTEGER := pr_flgcriar;    
    
  BEGIN
    
    -- Montar variaveis para log
    IF pr_flgerlog = 1 THEN
      vr_dsorigem := TRIM(gene0001.vr_vet_des_origens(pr_idorigem));
      vr_dstransa := 'Gerar rating do cooperado.';
    END IF;

    pc_verifica_rating(pr_cdcooper => pr_cdcooper --> Codigo Cooperativa
                      ,pr_cdagenci => pr_cdagenci --> Codigo Agencia
                      ,pr_nrdcaixa => pr_nrdcaixa --> Numero Caixa
                      ,pr_cdoperad => pr_cdoperad --> Codigo Operador
                      ,pr_dtmvtolt => pr_dtmvtolt --> Data de movimento
                      ,pr_nrdconta => pr_nrdconta --> Numero da Conta
                      ,pr_nrctrrat => pr_nrctrrat --> Numero Contrato Rating
                      ,pr_tpctrrat => pr_tpctrrat --> Tipo Contrato Rating
                      ,pr_idseqttl => pr_idseqttl --> Sequencial do Titular
                      ,pr_idorigem => pr_idorigem --> Identificador Origem
                      ,pr_nmdatela => pr_nmdatela --> Nome da tela
                      ,pr_flgcriar => pr_flgcriar --> Criar
                      ,pr_flgerlog => pr_flgerlog --> Identificador de gera��o de log
                      ,pr_flgcalcu => vr_flgcalcu --> Rating j� calculado
                      ,pr_tab_erro => pr_tab_erro --> Tabela de retorno de erro
                      ,pr_des_reto => pr_des_reto); --> Ind. de retorno OK/NOK
    
    -- Em caso de erro
    IF pr_des_reto <> 'OK' THEN
        
      /*************************************************************/
      /** Retornar critica se nao for limite de credito ou se for **/
      /** limite de credito e estiver tentando imprimir           **/
      /*************************************************************/
      IF pr_tpctrrat = 1 AND /*Limite de Cr�dito*/
         pr_flgcriar = 1 THEN
      
        RAISE vr_exc_saida;
          
      ELSE
        
        --Se n�o tem erro na tabela
        IF pr_tab_erro.COUNT = 0 THEN          
          vr_cdcritic:= 0;
          vr_dscritic:= 'Nao foi possivel gerar o rating.';
        END IF;
        
        -- Sair
        RAISE vr_exc_erro;
        
      END IF;
        
    END IF;
    
    pc_calcula_rating(pr_cdcooper => pr_cdcooper --> Codigo Cooperativa
                     ,pr_cdagenci => pr_cdagenci --> Codigo Agencia
                     ,pr_nrdcaixa => pr_nrdcaixa --> Numero Caixa
                     ,pr_cdoperad => pr_cdoperad --> Codigo Operador
                     ,pr_nrdconta => pr_nrdconta --> Numero da Conta
                     ,pr_tpctrato => pr_tpctrrat --> Tipo Contrato Rating
                     ,pr_nrctrato => pr_nrctrrat --> Numero Contrato Rating
                     ,pr_flgcriar => vr_flgcriar --> Indicado se deve criar o rating
                     ,pr_flgcalcu => vr_flgcalcu --> Indicador de calculo
                     ,pr_idseqttl => pr_idseqttl --> Sequencial do Titular
                     ,pr_idorigem => pr_idorigem --> Identificador Origem
                     ,pr_nmdatela => pr_nmdatela --> Nome da tela
                     ,pr_flgerlog => 'S'         --> Identificador de gera��o de log
                     ,pr_tab_rating_sing     => pr_tab_rating_sing --> Registros gravados para rating singular
                     ,pr_tab_impress_coop    => pr_tab_impress_coop     --> Registro impress�o da Cooperado
                     ,pr_tab_impress_rating  => pr_tab_impress_rating   --> Registro itens do Rating
                     ,pr_tab_impress_risco_cl => pr_tab_impress_risco_cl   --> Registro Nota e risco do cooperado naquele Rating - PROVISAOCL
                     ,pr_tab_impress_risco_tl => pr_tab_impress_risco_tl   --> Registro Nota e risco do cooperado naquele Rating - PROVISAOTL
                     ,pr_tab_impress_assina  => pr_tab_impress_assina   --> Assinatura na impressao do Rating
                     ,pr_tab_efetivacao      => pr_tab_efetivacao       --> Registro dos itens da efetiva��o
                     ,pr_tab_ratings         => pr_tab_ratings          --> Informacoes com os Ratings do Cooperado
                     ,pr_tab_crapras         => pr_tab_crapras          --> Tabela com os registros processados
                     ,pr_tab_erro            => pr_tab_erro             --> Tabela de retorno de erro
                     ,pr_des_reto            => pr_des_reto             --> Ind. de retorno OK/NOK
                     );
    
    -- Em caso de erro
    IF pr_des_reto <> 'OK' THEN
        
      --Se n�o tem erro na tabela
      IF pr_tab_erro.COUNT = 0 THEN          
        vr_cdcritic:= 0;
        vr_dscritic:= 'Nao foi possivel gerar o rating.';
      END IF;
        
      -- Sair
      RAISE vr_exc_erro;
        
    END IF;
    
    -- Se chegamos neste ponto, n�o houve erro
    pr_des_reto := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno n�o OK
      pr_des_reto := 'NOK';

      -- Se ainda n�o tem registro de erro, criar com a critica
      IF pr_tab_erro.COUNT = 0 THEN
        -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
      END IF;

      -- Se foi solicitado o envio de LOG
      IF pr_flgerlog = 1 THEN
        -- Gerar LOG de envio do e-mail
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => pr_dtmvtolt
                            ,pr_flgtrans => 0 --> FALSE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;
      
    WHEN vr_exc_saida THEN
      
      -- Retorno OK
      pr_des_reto := 'OK';
      
      -- Se foi solicitado o envio de LOG
      IF pr_flgerlog = 1 THEN
        -- Gerar LOG de envio do e-mail
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => pr_dtmvtolt
                            ,pr_flgtrans => 1 --> TRUE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);

          
      END IF;
      
    WHEN OTHERS THEN
      -- Retorno n�o OK
      pr_des_reto := 'NOK';
      
      -- Montar descri��o de erro n�o tratado
      vr_dscritic := 'Erro n�o tratado na RATI0001.pc_gera_rating '||sqlerrm;
      
      -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => 0
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
                           
      -- Se foi solicitado o envio de LOG
      IF pr_flgerlog = 1 THEN
        -- Gerar LOG de envio do e-mail
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => pr_dtmvtolt
                            ,pr_flgtrans => 0 --> FALSE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);

      END IF;
            
  END pc_gera_rating;
 
END RATI0001;
/
