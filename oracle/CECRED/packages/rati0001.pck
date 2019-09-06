CREATE OR REPLACE PACKAGE CECRED."RATI0001" is
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : RATI0001                     Antiga: sistema/generico/procedures/b1wgen0043.p
  --  Sistema  : Rotinas para Rating dos Cooperados
  --  Sigla    : RATI
  --  Autor    : Alisson C. Berrido - AMcom
  --  Data     : Maio/2013.                   Ultima atualizacao: 29/05/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para Rating dos Cooperados.

  --Alteracoes:    /  /    - Alterações para Ayllos WEB:
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
  --            20/05/2010 - Implementar a re-ativaçao do Rating.
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
  --            15/02/2011 - Se a empresa não atender a condição de tempo dos
  --                         sócios na empresa com a cláusula
  --                         CAN-DO ("27,39,44,45,46,48",STRING(crapjur.natjurid));
  --                         fazer o mesmo tratamento que é feito com o campo
  --                         crapjur.natjurid para o campo crapjur.dtiniatv.
  --                         Os anos em que a empresa atua é que deverão ser
  --                         encaixados na faixa. (Fabrício)
  --
  --            01/03/2011 - Alterações nas rotinas de cálculo e classificação
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
  --            11/08/2011 - Alterações p/ Grupo Economico
  --                         Parametro dtrefere na obtem_risco
  --                       - Adaptacao Rating das Singulares (Guilherme).
  --
  --            04/11/2011 - Rezalizado alteração na procedure valida-itens-rating
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
  --            03/07/2015 - Projeto 217 Reformulaçao Cadastral IPP Entrada
  --                         Ajuste nos codigos de natureza juridica para o
  --                         existente na receita federal (Tiago Castro - RKAM)
  --
  --
  --            30/11/2015 - Ajuste na pc_verifica_contrato_rating para Correção da conversão que não estava
  --                         conforme com a versão do Progress.
  --                         Ajuste na pc_desativa_rating para passar o ROWID correto para pc_grava_rating_origem
  --                         e TRIM na variável pr_flgefeti(erro quando vem pela EMPR0001)
  --                         Ajuste na pc_ativa_rating para atribuir ROWID à variavel(Guilherme/SUPERO)
  --
  --            03/06/2016   Alteracao na atribuicao de notas do rating, se for AA, deve
  --                         assumir a nota referente ao risco A.
  --                         Chamado 431839 (Andrey - RKAM)
   --
  --            10/05/2016 - Ajustes referente a conversão da tela ATURAT
  --                         (Andrei - RKAM).
  --
  --            13/10/2016 - Ajuste na leitura da craptab para utilização de cursor padrão (Rodrigo)
  --
  --            08/11/2016 - Salvar o valor de endividamento em uma variavel de escopo global, pois em
  --                         algumas situacoes, nao estava gravando o valor considerado para rateio
  --                         Heitor (Mouts) - Chamado 544076
  --
  --            01/02/2017 - Incluir busca na central de risco tambem para os limites rotativos.
  --                         Ajustada a rotina pc_verifica_atualizacao, que nao estava retornando a mensagem de erro
  --                         corretamente para a tela ATURAT. Heitor (Mouts)
  --
  --            15/05/2017 - Tornado procedure pc_nivel_comprometimento publica. (Reinert)
  --
  --            28/06/2017 - Acerto da logica procedure pc_param_valor_rating
  --                       - Acerto do padrão de retorno das situações de mensagem
  --                       - Inclusão para setar o modulo de todas procedures da Package
  --                         ( Belli - Envolti - 28/06/2017 - Chamado 660306).
  --
  --            27/07/2017 - Alterado para ignorar algumas validacoes para os emprestimos de cessao da
  --                         fatura de cartao de credito (Anderson).
  --
  --            11/10/2017 - Liberacao da melhoria 442 (Heitor - Mouts)
  --
  --            30/01/2018 - Ajuste na flgcriar para que faca o update na tabela crapnrc antes da rotina de limpeza de ratings antigos.
  --                         Heitor (Mouts) - Chamado 839107.
  --
  --            31/01/2018 - Criado função nova para qualificação da operação.
  --                         Alterado pc_natureza_operacao para demais parâmetros.
  --                         (Diego Simas - AMcom)
  --
  --            28/03/2018 - Alterar conversao de char para number, ao inves de usar o to_number,
  --                         vai utilizar funcao generica da gene0002. Essa funcao ja le os parametros
  --                         de formatacao numerica do banco de dados e converte adequadamente, evitando
  --                         problemas ao executar a rati0001 por job. Heitor (Mouts)
  --
  --            29/05/2018 - Expostas as funções fn_valor_operacao e fn_busca_descricao_situacao (GFT)
  --
  --            24/04/2019 - P450 - disponibilização de consulta e alteração apenas para Ratings 
  --                         de operações do BNDES (Fabio Adriano - AMcom).
  --
  --            03/05/2019 - P450 - Retirado a validação da etapa rating, mantido apenas para cooper 3 
  --                         central Ailos (Luiz Otávio Olinger Momm - AMcom).
  --
  --            06/05/2019 - P450 - Utilizar o Rating antigo apenas para a central Ailos. 
  --                         (Luiz Otávio Olinger Momm - AMcom).
  -- 
  ---------------------------------------------------------------------------------------------------------------
  -- Tipo de Tabela para dados provisao CL
  TYPE typ_tab_dsdrisco IS TABLE OF VARCHAR2(5) INDEX BY PLS_INTEGER;

  -- Tipo para registros para armazenamento da efetivação do Rating
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

  -- Registro genérico para Nota e risco do cooperado naquele Rating - PROVISAOCL e PROVISAOTL
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

  /* Tipo para retornar uma lista de contrados a liquidar */
  TYPE typ_vet_nrctrliq IS VARRAY(10) OF PLS_INTEGER;

  /* Rotina responsavel por buscar a descrição da operacao do tipo de contrato */
  FUNCTION fn_busca_descricao_operacao (pr_tpctrrat IN INTEGER) --Tipo Contrato Rating
    RETURN VARCHAR2;

  /* Rotina responsável por obter o nivel de risco */
  PROCEDURE pc_obtem_risco (pr_cdcooper       IN crapcop.cdcooper%TYPE --Código da Cooperativa
                           ,pr_nrdconta       IN crapass.nrdconta%TYPE --Numero da Conta do Associado
                           ,pr_tab_dsdrisco   IN RATI0001.typ_tab_dsdrisco --Vetor com dados das provisoes
                           ,pr_dstextab_bacen IN craptab.dstextab%TYPE --Descricao da craptab do RISCOBACEN
                           ,pr_dtmvtolt       IN crapdat.dtmvtolt%TYPE --Data Movimento
                           ,pr_nivrisco       OUT VARCHAR2             --Nivel de Risco
                           ,pr_dtrefere       OUT DATE                 --Data de Referencia do Risco
                           ,pr_cdcritic       OUT INTEGER              --Código da Critica de Erro
                           ,pr_dscritic       OUT VARCHAR2);           --Descricao do erro

  /* Calcula endividamento total SCR. Itens 3_3 (Fisica) e 5_1 (Juridica). */
  PROCEDURE pc_calcula_endividamento(pr_cdcooper   IN crapcop.cdcooper%TYPE     --> Código da Cooperativa
                                    ,pr_cdagenci   IN crapass.cdagenci%TYPE     --> Código da agência
                                    ,pr_nrdcaixa   IN craperr.nrdcaixa%TYPE     --> Número do caixa
                                    ,pr_cdoperad   IN crapnrc.cdoperad%TYPE     --> Código do operador
                                    ,pr_rw_crapdat IN btch0001.rw_crapdat%TYPE  --> Vetor com dados de parâmetro (CRAPDAT)
                                    ,pr_nrdconta   IN crapass.nrdconta%TYPE     --> Conta do associado
                                    ,pr_dsliquid   IN VARCHAR2                  --> Lista de contratos a liquidar
                                    ,pr_idseqttl   IN crapttl.idseqttl%TYPE     --> Sequencia de titularidade da conta
                                    ,pr_idorigem   IN INTEGER                   --> Indicador da origem da chamada
                                    ,pr_inusatab   IN BOOLEAN                   --> Indicador de utilização da tabela de juros
                                    ,pr_tpdecons   IN INTEGER DEFAULT 2         --> Tipo da consulta,defalut 2 saldo disponivel emprestimo sem considerar data atual, 3 saldo disponivel data atual (Ver observações da rotina GENE0005.pc_saldo_utiliza)
                                    ,pr_vlutiliz  OUT NUMBER                    --> Valor da dívida
                                    ,pr_cdcritic  OUT crapcri.cdcritic%TYPE     --> Critica encontrada no processo
                                    ,pr_dscritic  OUT VARCHAR2);                --> Saída de erro

  /* Desativar Rating. Usada quando emprestimo é liquidado ou limite é cancelado. */
  PROCEDURE pc_desativa_rating(pr_cdcooper   IN crapcop.cdcooper%TYPE    --> Código da Cooperativa
                              ,pr_cdagenci   IN crapass.cdagenci%TYPE    --> Código da agência
                              ,pr_nrdcaixa   IN craperr.nrdcaixa%TYPE    --> Número do caixa
                              ,pr_cdoperad   IN crapnrc.cdoperad%TYPE    --> Código do operador
                              ,pr_rw_crapdat IN btch0001.rw_crapdat%TYPE --> Vetor com dados de parâmetro (CRAPDAT)
                              ,pr_nrdconta   IN crapass.nrdconta%TYPE    --> Conta do associado
                              ,pr_tpctrrat   IN NUMBER                   --> Tipo do Rating
                              ,pr_nrctrrat   IN NUMBER                   --> Número do contrato de Rating
                              ,pr_flgefeti   IN VARCHAR2                 --> Flag para efetivação ou não do Rating
                              ,pr_idseqttl   IN crapttl.idseqttl%TYPE    --> Sequencia de titularidade da conta
                              ,pr_idorigem   IN INTEGER                  --> Indicador da origem da chamada
                              ,pr_inusatab   IN BOOLEAN                  --> Indicador de utilização da tabela de juros
                              ,pr_nmdatela   IN VARCHAR2                 --> Nome datela conectada
                              ,pr_flgerlog   IN VARCHAR2                 --> Gerar log S/N
                              ,pr_des_reto  OUT VARCHAR                  --> Retorno OK / NOK
                              ,pr_tab_erro  OUT gene0001.typ_tab_erro);  --> Tabela com possíves erros

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
                                 ,pr_rw_crapdat IN btch0001.rw_crapdat%TYPE  --> Vetor com dados de parâmetro (CRAPDAT)
                                 ,pr_tpctrato IN crapnrc.tpctrrat%TYPE --> Tipo Contrato Rating
                                 ,pr_nrctrato IN crapnrc.nrctrrat%TYPE --> Numero Contrato Rating
                                 ,pr_inusatab IN BOOLEAN  --> Indicador de utilização da tabela de juros
                                 ,pr_flgcriar IN INTEGER  --> Indicado se deve criar o rating
                                 ,pr_flgttris    IN BOOLEAN             --> Indicado se deve carregar toda a crapris
                                 ,pr_tab_crapras IN OUT typ_tab_crapras --> Tabela com os registros a serem processados
                                 ,pr_notacoop OUT NUMBER                --> Retorna a nota da classificação
                                 ,pr_clascoop OUT VARCHAR2              --> retorna classificação
                                 ,pr_tab_erro OUT GENE0001.typ_tab_erro --> Tabela de retorno de erro
                                 ,pr_des_reto OUT VARCHAR2);            --> Indicação de retorno OK/NOK

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
                                 ,pr_rw_crapdat IN btch0001.rw_crapdat%TYPE  --> Vetor com dados de parâmetro (CRAPDAT)
                                 ,pr_tpctrato IN crapnrc.tpctrrat%TYPE       --> Tipo Contrato Rating
                                 ,pr_nrctrato IN crapnrc.nrctrrat%TYPE       --> Numero Contrato Rating
                                 ,pr_inusatab IN BOOLEAN                     --> Indicador de utilização da tabela de juros
                                 ,pr_flgcriar IN INTEGER                     --> Indicado se deve criar o rating
                                 ,pr_flgttris IN BOOLEAN                     --> Indicado se deve carregar toda a crapris
                                 ,pr_tab_crapras IN OUT typ_tab_crapras      --> Tabela com os registros a serem processados
                                 ,pr_notacoop OUT NUMBER                     --> Retorna a nota da classificação
                                 ,pr_clascoop OUT VARCHAR2                   --> retorna classificação
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
                             ,pr_flgerlog IN VARCHAR2                                        --> Identificador de geração de log
                             ,pr_tab_rating_sing       IN RATI0001.typ_tab_crapras           --> Registros gravados para rating singular
                             ,pr_flghisto IN INTEGER                                         --> Indicador se deve gerar historico
                             ----- OUT ----
                             ,pr_tab_impress_coop     OUT RATI0001.typ_tab_impress_coop     --> Registro impressão da Cooperado
                             ,pr_tab_impress_rating   OUT RATI0001.typ_tab_impress_rating   --> Registro itens do Rating
                             ,pr_tab_impress_risco_cl OUT RATI0001.typ_tab_impress_risco    --> Registro Nota e risco do cooperado naquele Rating - PROVISAOCL
                             ,pr_tab_impress_risco_tl OUT RATI0001.typ_tab_impress_risco    --> Registro Nota e risco do cooperado naquele Rating - PROVISAOTL
                             ,pr_tab_impress_assina   OUT RATI0001.typ_tab_impress_assina   --> Assinatura na impressao do Rating
                             ,pr_tab_efetivacao       OUT RATI0001.typ_tab_efetivacao       --> Registro dos itens da efetivação
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
                                 ,pr_rw_crapdat  IN btch0001.rw_crapdat%TYPE    --> Vetor com dados de parâmetro (CRAPDAT)
                                 ,pr_nrdconta    IN crapass.nrdconta%TYPE       --> Numero da Conta
                                 ,pr_idseqttl    IN crapttl.idseqttl%TYPE       --> Sequencia de titularidade da conta
                                 ,pr_idorigem    IN INTEGER                     --> Indicador da origem da chamada
                                 ,pr_nmdatela    IN craptel.nmdatela%TYPE       --> Nome da tela
                                 ,pr_flgerlog    IN VARCHAR2                    --> Identificador de geração de log
                                 ----- OUT ----
                                 ,pr_flgopera   OUT INTEGER               --> Tabela com os registros processados
                                 ,pr_tab_erro   OUT GENE0001.typ_tab_erro --> Tabela de retorno de erro
                                 ,pr_des_reto   OUT VARCHAR2);            --> Ind. de retorno OK/NOK

  /* Procedure efetivar o Rating */
  PROCEDURE pc_ratings_cooperado(pr_cdcooper   IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                ,pr_cdagenci   IN crapass.cdagenci%TYPE --> Código da agência
                                ,pr_nrdconta   IN crapass.nrdconta%TYPE --> Conta do associado
                                ,pr_nrregist   IN INTEGER                 --> Número de registros
                                ,pr_nriniseq   IN INTEGER                 --> Número sequencial
                                ,pr_dtinirat   IN DATE                  --> Data de início do Rating
                                ,pr_dtfinrat   IN DATE                  --> Data de termino do Rating
                                ,pr_insitrat   IN PLS_INTEGER           --> Situação do Rating
                                ,pr_qtregist    OUT INTEGER             --> Quantidade de registros encontrados
                                ,pr_tab_ratings OUT RATI0001.typ_tab_ratings    --> Registro com os ratings do associado
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
                                   ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE                           --> Data do próximo dia útil
                                   ,pr_inproces IN crapdat.inproces%TYPE                           --> Situação do processo
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE                           --> Numero da Conta
                                   ,pr_tpctrrat IN crapnrc.tpctrrat%TYPE                           --> Tipo Contrato Rating
                                   ,pr_nrctrrat IN crapnrc.nrctrrat%TYPE                           --> Numero Contrato Rating
                                   ,pr_idseqttl IN crapttl.idseqttl%TYPE                           --> Sequencial do Titular
                                   ,pr_idorigem IN INTEGER                                         --> Identificador Origem
                                   ,pr_nmdatela IN craptel.nmdatela%TYPE                           --> Nome da tela
                                   ,pr_flgerlog IN VARCHAR2                                        --> Identificador de geração de log
                                   ,pr_dsretorn IN BOOLEAN                                         --> Retornar
                                   ,pr_tab_rating_sing       IN RATI0001.typ_tab_crapras           --> Registros gravados para rating singular
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
                           ,pr_tab_rating_sing       IN RATI0001.typ_tab_crapras           --> Registros gravados para rating singular
                           ,pr_tab_impress_risco_tl OUT RATI0001.typ_tab_impress_risco     --> Registro Nota e risco do cooperado naquele Rating - PROVISAOTL
                           ,pr_indrisco OUT VARCHAR2                                       --> Indicador do risco
                           ,pr_nrnotrat OUT crapnrc.nrnotrat%TYPE                          --> Número da nota
                           ,pr_tab_erro OUT GENE0001.typ_tab_erro                          --> Tabela de retorno de erro
                           ,pr_des_reto OUT VARCHAR2                                       --> Ind. de retorno OK/NOK
                           ) ;


  PROCEDURE pc_gera_rating(pr_cdcooper             IN crapcop.cdcooper%TYPE            --> Codigo Cooperativa
                          ,pr_cdagenci             IN crapass.cdagenci%TYPE            --> Codigo Agencia
                          ,pr_nrdcaixa             IN craperr.nrdcaixa%TYPE            --> Numero Caixa
                          ,pr_cdoperad             IN crapnrc.cdoperad%TYPE            --> Codigo Operador
                          ,pr_nmdatela             IN craptel.nmdatela%TYPE            --> Nome da tela
                          ,pr_idorigem             IN INTEGER                          --> Identificador Origem
                          ,pr_nrdconta             IN crapass.nrdconta%TYPE            --> Numero da Conta
                          ,pr_idseqttl             IN crapttl.idseqttl%TYPE            --> Sequencial do Titular
                          ,pr_dtmvtolt             IN crapdat.dtmvtolt%TYPE            --> Data de movimento
                          ,pr_dtmvtopr             IN crapdat.dtmvtopr%TYPE            --> Data do próximo dia útil
                          ,pr_inproces             IN crapdat.inproces%TYPE            --> Situação do processo
                          ,pr_tpctrrat             IN crapnrc.tpctrrat%TYPE            --> Tipo Contrato Rating
                          ,pr_nrctrrat             IN crapnrc.nrctrrat%TYPE            --> Numero Contrato Rating
                          ,pr_flgcriar             IN INTEGER                          --> Criar rating
                          ,pr_flgerlog             IN INTEGER                          --> Identificador de geração de log
                          ,pr_tab_rating_sing      IN RATI0001.typ_tab_crapras  --> Registros gravados para rating singular
                          ,pr_tab_impress_coop     OUT RATI0001.typ_tab_impress_coop     --> Registro impressão da Cooperado
                          ,pr_tab_impress_rating   OUT RATI0001.typ_tab_impress_rating   --> Registro itens do Rating
                          ,pr_tab_impress_risco_cl OUT RATI0001.typ_tab_impress_risco    --> Registro Nota e risco do cooperado naquele Rating - PROVISAOCL
                          ,pr_tab_impress_risco_tl OUT RATI0001.typ_tab_impress_risco    --> Registro Nota e risco do cooperado naquele Rating - PROVISAOTL
                          ,pr_tab_impress_assina   OUT RATI0001.typ_tab_impress_assina   --> Assinatura na impressao do Rating
                          ,pr_tab_efetivacao       OUT RATI0001.typ_tab_efetivacao       --> Registro dos itens da efetivação
                          ,pr_tab_ratings          OUT RATI0001.typ_tab_ratings          --> Informacoes com os Ratings do Cooperado
                          ,pr_tab_crapras          OUT RATI0001.typ_tab_crapras          --> Tabela com os registros processados
                          ,pr_tab_erro             OUT GENE0001.typ_tab_erro             --> Tabela de retorno de erro
                          ,pr_des_reto             OUT VARCHAR2                          --> Ind. de retorno OK/NOK
                          );

  /* Obter as descricoes do risco, provisao , etc ...  */
  PROCEDURE pc_descricoes_risco(pr_cdcooper    IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                               ,pr_inpessoa    IN crapass.inpessoa%TYPE --> Tipo de pessoa
                               ,pr_nrnotrat    IN NUMBER                --> Valor baseado no calculo do rating
                               ,pr_nrnotatl    IN NUMBER                --> Valor baseado no calculo do risco
                               ,pr_nivrisco    IN pls_integer           --> Nivel do Risco
                               ,pr_tab_impress_risco_cl OUT RATI0001.typ_tab_impress_risco --> Registro Nota e risco do cooperado naquele Rating - PROVISAOCL
                               ,pr_tab_impress_risco_tl OUT RATI0001.typ_tab_impress_risco --> Registro Nota e risco do cooperado naquele Rating - PROVISAOTL
                               ,pr_des_reto             OUT VARCHAR2);          --> Indicador erro IS

  /* Item 3_1 (Pessoa Fisica) e  5_2 (Pessoa juridica) do Rating */
  PROCEDURE pc_nivel_comprometimento(pr_cdcooper     IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                    ,pr_cdoperad     IN crapnrc.cdoperad%TYPE --> Código do operador
                                    ,pr_idseqttl     IN crapttl.idseqttl%TYPE --> Sq do titular da conta
                                    ,pr_idorigem     IN pls_integer           --> Indicador da origem da chamada
                                    ,pr_nrdconta     IN crapass.nrdconta%TYPE --> Conta do associado
                                    ,pr_tpctrato     IN crapnrc.tpctrrat%TYPE --> Tipo do Rating
                                    ,pr_nrctrato     IN crapnrc.nrctrrat%TYPE --> Número do contrato de Rating
                                    ,pr_vet_nrctrliq IN typ_vet_nrctrliq      --> Vetor de contratos a liquidar
                                    ,pr_vlpreemp     IN crapepr.vlpreemp%TYPE --> Valor da parcela
                                    ,pr_rw_crapdat   IN btch0001.cr_crapdat%rowtype --> Calendário do movimento atual
                                    ,pr_flgdcalc     IN PLS_INTEGER           --> Flag para calcular sim ou não
                                    ,pr_inusatab     IN BOOLEAN               --> Indicador de utilização da tabela de juros
                                    ,pr_vltotpre    OUT NUMBER                --> Valor calculado da prestação
                                    ,pr_dscritic    OUT VARCHAR2);            --> Descrição de erro

  PROCEDURE pc_historico_cooperado(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo Cooperativa
                                  ,pr_cdoperad IN crapnrc.cdoperad%TYPE --> Codigo Operador
                                  ,pr_dtmvtolt IN DATE                  --> Data do movimento
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE --> Numero da Conta
                                  ,pr_idorigem IN INTEGER               --> Identificador Origem
                                  ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Sequencial do Titular
                                  ,pr_nrseqite OUT NUMBER        --> sequencial do item do risco
                                  ,pr_dscritic OUT VARCHAR2);

  /*****************************************************************************
                  Gravar dados do rating do cooperado
  *****************************************************************************/
  PROCEDURE pc_grava_rating(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo Cooperativa
                           ,pr_cdagenci IN crapass.cdagenci%TYPE --> Codigo Agencia
                           ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Numero Caixa
                           ,pr_cdoperad IN crapnrc.cdoperad%TYPE --> Codigo Operador
                           ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data de movimento
                           ,pr_nrdconta IN crapass.nrdconta%TYPE --> Numero da Conta
                           ,pr_inpessoa IN crapass.inpessoa%TYPE --> Tipo Pessoa
                           ,pr_nrinfcad IN crapprp.nrinfcad%TYPE --> Informacoes Cadastrais
                           ,pr_nrpatlvr IN crapprp.nrpatlvr%TYPE --> Patrimonio pessoal livre
                           ,pr_nrperger IN crapprp.nrperger%TYPE --> Percepção Geral Empresa
                           ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Sequencial do Titular
                           ,pr_idorigem IN INTEGER               --> Identificador Origem
                           ,pr_nmdatela IN craptel.nmdatela%TYPE --> Nome da tela
                           ,pr_flgerlog IN INTEGER               --> Identificador de geração de log
                           ,pr_cdcritic OUT NUMBER               --> Codigo Critica
                           ,pr_dscritic OUT VARCHAR2);           --> Descricao critica

  PROCEDURE pc_grava_his_crapnrc(pr_cdcooper IN crapcop.cdcooper%type
                                ,pr_nrdconta IN crapass.nrdconta%type
                                ,pr_nrctrrat IN crapnrc.nrctrrat%type
                                ,pr_tpctrrat IN crapnrc.tpctrrat%type
                                ,pr_indrisco IN crapnrc.indrisco%type
                                ,pr_dtmvtolt IN crapnrc.dtmvtolt%type
                                ,pr_cdoperad IN crapope.cdoperad%type
                                ,pr_nrnotrat IN crapnrc.nrnotrat%type
                                ,pr_vlutlrat IN crapnrc.vlutlrat%type
                                ,pr_nrnotatl IN crapnrc.nrnotatl%type
                                ,pr_inrisctl IN crapnrc.inrisctl%type
                                ,pr_cdcritic OUT crapcri.cdcritic%type
                                ,pr_dscritic OUT crapcri.dscritic%type);
  PROCEDURE pc_grava_his_crapnrc2(pr_cdcooper IN crapcop.cdcooper%type
                                ,pr_nrdconta IN crapass.nrdconta%type
                                ,pr_nrctrrat IN crapnrc.nrctrrat%type
                                ,pr_tpctrrat IN crapnrc.tpctrrat%type
                                ,pr_indrisco IN crapnrc.indrisco%type
                                ,pr_dtmvtolt IN crapnrc.dtmvtolt%type
                                ,pr_cdoperad IN crapope.cdoperad%type
                                ,pr_nrnotrat IN crapnrc.nrnotrat%type
                                ,pr_vlutlrat IN crapnrc.vlutlrat%type
                                ,pr_nrnotatl IN crapnrc.nrnotatl%type
                                ,pr_inrisctl IN crapnrc.inrisctl%type
                                ,pr_dtadmiss IN cecred.tbrat_informacao_rating.dtadmiss_cooperado%type
                                ,pr_qtmaxatr IN cecred.tbrat_informacao_rating.qtdias_max_atraso%type
                                ,pr_flgreneg IN cecred.tbrat_informacao_rating.flgrenegoc%type
                                ,pr_dtadmemp IN cecred.tbrat_informacao_rating.dtadmiss_emprego%type
                                ,pr_cdnatocp IN cecred.tbrat_informacao_rating.cdnatureza_ocupacao%type
                                ,pr_qtresext IN cecred.tbrat_informacao_rating.qtrestricao_externa%type
                                ,pr_vlnegext IN cecred.tbrat_informacao_rating.vlnegativacao_externa%type
                                ,pr_flgresre IN cecred.tbrat_informacao_rating.flgrestricao_relevante%type
                                ,pr_qtadidep IN cecred.tbrat_informacao_rating.qtadiantamento_depositante%type
                                ,pr_qtchqesp IN cecred.tbrat_informacao_rating.qtcheque_especial%type
                                ,pr_qtdevalo IN cecred.tbrat_informacao_rating.qtdev_alinea_onze%type
                                ,pr_qtdevald IN cecred.tbrat_informacao_rating.qtdev_alinea_doze%type
                                ,pr_cdsitres IN cecred.tbrat_informacao_rating.cdsituacao_residencia%type
                                ,pr_vlpreatv IN cecred.tbrat_informacao_rating.vlprestacao_ativa%type
                                ,pr_vlsalari IN cecred.tbrat_informacao_rating.vlsalario%type
                                ,pr_vlrendim IN cecred.tbrat_informacao_rating.vloutros_rendimentos%type
                                ,pr_vlsalcje IN cecred.tbrat_informacao_rating.vlsalario_conjuge%type
                                ,pr_vlendivi IN cecred.tbrat_informacao_rating.vlendividamento%type
                                ,pr_vlbemtit IN cecred.tbrat_informacao_rating.vlbem_titular%type
                                ,pr_flgcjeco IN cecred.tbrat_informacao_rating.flgconjuge_corresponsavel%type
                                ,pr_vlbemcje IN cecred.tbrat_informacao_rating.vlbem_conjuge%type
                                ,pr_vlsldeve IN cecred.tbrat_informacao_rating.vlsaldo_devedor%type
                                ,pr_vlopeatu IN cecred.tbrat_informacao_rating.vloperacao_atual%type
                                ,pr_vlslcota IN cecred.tbrat_informacao_rating.vlsaldo_cotas%type
                                ,pr_cdquaope IN cecred.tbrat_informacao_rating.cdqualificacao_operacao%type
                                ,pr_cdtpoper IN cecred.tbrat_informacao_rating.cdtipo_operacao%type
                                ,pr_cdlincre IN cecred.tbrat_informacao_rating.cdlinha_credito%type
                                ,pr_cdmodali IN cecred.tbrat_informacao_rating.cdmodalidade_linha_cred%type
                                ,pr_cdsubmod IN cecred.tbrat_informacao_rating.cdsubmodalidade_linha_cred%type
                                ,pr_cdgarope IN cecred.tbrat_informacao_rating.cdgarantia_operacao%type
                                ,pr_cdliqgar IN cecred.tbrat_informacao_rating.cdliquidez_garantia%type
                                ,pr_qtpreope IN cecred.tbrat_informacao_rating.qtprestacao_operacao%type
                                ,pr_dtfunemp IN cecred.tbrat_informacao_rating.dtfundacao_empresa%type
                                ,pr_cdseteco IN cecred.tbrat_informacao_rating.cdsetor_economico%type
                                ,pr_dtprisoc IN cecred.tbrat_informacao_rating.dtprimeiro_socio%type
                                ,pr_prfatcli IN cecred.tbrat_informacao_rating.prfaturamento_cliente%type
                                ,pr_vlmedfat IN cecred.tbrat_informacao_rating.vlmedia_faturamento_anual%type
                                ,pr_vlbemavt IN cecred.tbrat_informacao_rating.vlbem_avalista%type
                                ,pr_vlbemsoc IN cecred.tbrat_informacao_rating.vlbem_socio%type
                                ,pr_vlparope IN cecred.tbrat_informacao_rating.vlparcela_operacao%type
                                ,pr_cdperemp IN cecred.tbrat_informacao_rating.cdpercepcao_empresa%type
                                ,pr_dstpoper IN cecred.tbrat_informacao_rating.dstipo_operacao%type
                                ,pr_cdcritic OUT crapcri.cdcritic%type
                                ,pr_dscritic OUT crapcri.dscritic%type);
  PROCEDURE pc_grava_his_crapras(pr_cdcooper IN crapcop.cdcooper%type
                                ,pr_nrdconta IN crapass.nrdconta%type
                                ,pr_nrctrrat IN crapnrc.nrctrrat%type
                                ,pr_tpctrrat IN crapnrc.tpctrrat%type
                                ,pr_nrtopico IN crapras.nrtopico%type
                                ,pr_nritetop IN crapras.nritetop%type
                                ,pr_nrseqite IN crapras.nrseqite%type
                                ,pr_dsvalite IN crapras.dsvalite%type
                                ,pr_cdcritic OUT crapcri.cdcritic%type
                                ,pr_dscritic OUT crapcri.dscritic%type
                                );
  PROCEDURE pc_param_valor_rating(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Código da Cooperativa
                                 ,pr_vlrating OUT NUMBER                --> Valor parametrizado
                                 ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                 ,pr_dscritic OUT VARCHAR2);
  PROCEDURE pc_gera_arq_impress_rating(pr_cdcooper    IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                      ,pr_cdagenci    IN crapass.cdagenci%TYPE --> Código da agência
                                      ,pr_nrdcaixa    IN craperr.nrdcaixa%TYPE --> Número do caixa
                                      ,pr_cdoperad    IN crapnrc.cdoperad%TYPE --> Código do operador
                                      ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE --> Data do movimento atual
                                      ,pr_nrdconta    IN crapass.nrdconta%TYPE --> Conta do associado
                                      ,pr_tpctrato    IN crapnrc.tpctrrat%TYPE --> Tipo do Rating
                                      ,pr_nrctrato    IN crapnrc.nrctrrat%TYPE --> Número do contrato de Rating
                                      ,pr_flgcriar    IN pls_integer           --> Flag para criação ou não do arquivo
                                      ,pr_flgcalcu    IN pls_integer           --> Flag para calculo ou não
                                      ,pr_idseqttl    IN crapttl.idseqttl%TYPE --> Sq do titular da conta
                                      ,pr_idorigem    IN pls_integer           --> Indicador da origem da chamada
                                      ,pr_nmdatela    IN craptel.nmdatela%TYPE --> Nome da tela conectada
                                      ,pr_flgerlog    IN VARCHAR2              --> Gerar log S/N
                                      ,pr_tab_crapras IN typ_tab_crapras       --> Interna da BO, para o calculo do Rating
                                      ,pr_tab_impress_coop     OUT RATI0001.typ_tab_impress_coop     --> Registro impressão da Cooperado
                                      ,pr_tab_impress_rating   OUT RATI0001.typ_tab_impress_rating   --> Registro itens do Rating
                                      ,pr_tab_impress_risco_cl OUT RATI0001.typ_tab_impress_risco    --> Registro Nota e risco do cooperado naquele Rating - PROVISAOCL
                                      ,pr_tab_impress_risco_tl OUT RATI0001.typ_tab_impress_risco    --> Registro Nota e risco do cooperado naquele Rating - PROVISAOTL
                                      ,pr_tab_impress_assina   OUT RATI0001.typ_tab_impress_assina   --> Assinatura na impressao do Rating
                                      ,pr_tab_efetivacao       OUT RATI0001.typ_tab_efetivacao       --> Registro dos itens da efetivação
                                      ,pr_tab_erro             OUT gene0001.typ_tab_erro --> Tabela de retorno de erro
                                      ,pr_des_reto             OUT VARCHAR2);

  /* ***************************************************************************

     Procedimento para atualização das perguntas de Garantia e Liquidez após
     alteração dos avalistas na proposta de Empréstimo

     *************************************************************************** */
  PROCEDURE pc_atuali_garant_liquid_epr(pr_cdcooper     IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                       ,pr_nrdconta     IN crapass.nrdconta%TYPE --> Conta do associado
                                       ,pr_nrctrato     IN crapnrc.nrctrrat%TYPE --> Número do contrato de Rating
                                       ,pr_nrgarope     OUT crapprp.nrgarope%TYPE
                                       ,pr_nrliquid     OUT crapprp.nrliquid%TYPE
                                       ,pr_dscritic    OUT VARCHAR2);            --> Descrição de erro

  /***************************************************************************
    Função para retornar ID Qualificação quando alterado pelo controle.
  ****************************************************************************/

  FUNCTION fn_verifica_qualificacao(pr_nrdconta IN NUMBER  --> Número da conta
                                   ,pr_nrctremp IN NUMBER  --> Contrato
                                   ,pr_idquapro IN NUMBER  --> Id Qualif Operacao
                                   ,pr_cdcooper IN NUMBER) --> Código da Cooperativa
                            RETURN INTEGER;

  FUNCTION fn_valor_operacao(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                            ,pr_nrdconta IN crapass.nrdconta%TYPE --> Conta do associado
                            ,pr_tpctrato IN crapnrc.tpctrrat%TYPE --> Tipo do Rating
                            ,pr_nrctrato IN crapnrc.nrctrrat%TYPE --> Número do contrato de Rating
                            ) RETURN NUMBER;


   FUNCTION fn_busca_descricao_situacao (pr_insitrat IN INTEGER) RETURN VARCHAR2;
END RATI0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED."RATI0001" IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : RATI0001                     Antiga: sistema/generico/procedures/b1wgen0043.p
  --  Sistema  : Rotinas para Rating dos Cooperados
  --  Sigla    : RATI
  --  Autor    : Alisson C. Berrido - AMcom
  --  Data     : Maio/2013.                   Ultima atualizacao: 31/01/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para Rating dos Cooperados.
  --
  -- Alteracao: 16/11/2015 - UPPER para comparacao do cdoperad no cursor da crapope (Tiago SD339476)
  --
  --            10/05/2016 - Ajustes referente a conversão da tela ATURAT
  --                         (Andrei - RKAM).
  --
  --            28/06/2017 - Acerto do padrão de retorno das situações de mensagem
  --                       - Inclusão para setar o modulo de todas procedures da Package
  --                         ( Belli - Envolti - 28/06/2017 - Chamado 660306).
  --
  --            31/01/2018 - Criado função nova para qualificação da operação.
  --                       Alterado pc_natureza_operacao para demais parâmetros.
  --                       (Diego Simas - AMcom)
  --
  --            24/04/2019 - P450 - disponibilização de consulta e alteração apenas para Ratings 
  --                         de operações do BNDES (Fabio Adriano - AMcom).
  --
  --            03/05/2019 - P450 - Retirado a validação da etapa rating, mantido apenas para cooper 3 
  --                         central Ailos (Luiz Otávio Olinegr Momm - AMcom).
  --
  --            06/05/2019 - P450 - Adicionada validação na fn_valida_item_rating para fazer somente na cooperativa 3 
  --                         central Ailos (Heckmann - AMcom).
  --
  --            06/05/2019 - P450 - Utilizar o Rating antigo apenas para a central Ailos. 
  --                         (Luiz Otávio Olinegr Momm - AMcom).
  -- 
  ---------------------------------------------------------------------------------------------------------------

  /* Tipo que compreende o vetor com valor do rating da TAB036 por coop */
  TYPE typ_tab_vlrating IS
    TABLE OF NUMBER
      INDEX BY BINARY_INTEGER; --> Utilizaremos a cooperativa como índice
  vr_vet_vlrating typ_tab_vlrating;

  /* Tipo para armazenamento das informações de risco e rating */
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
  vr_dsvalite             varchar2(50);
  vr_flghisto             number;

  /*Variaveis para gravar informacoes utilizadas no rating*/
  rat_dtadmiss   cecred.tbrat_informacao_rating.dtadmiss_cooperado%type;
  rat_qtmaxatr   cecred.tbrat_informacao_rating.qtdias_max_atraso%type;
  rat_flgreneg   cecred.tbrat_informacao_rating.flgrenegoc%type;
  rat_dtadmemp   cecred.tbrat_informacao_rating.dtadmiss_emprego%type;
  rat_cdnatocp   cecred.tbrat_informacao_rating.cdnatureza_ocupacao%type;
  rat_qtresext   cecred.tbrat_informacao_rating.qtrestricao_externa%type;
  rat_vlnegext   cecred.tbrat_informacao_rating.vlnegativacao_externa%type;
  rat_flgresre   cecred.tbrat_informacao_rating.flgrestricao_relevante%type;
  rat_qtadidep   cecred.tbrat_informacao_rating.qtadiantamento_depositante%type;
  rat_qtchqesp   cecred.tbrat_informacao_rating.qtcheque_especial%type;
  rat_qtdevalo   cecred.tbrat_informacao_rating.qtdev_alinea_onze%type;
  rat_qtdevald   cecred.tbrat_informacao_rating.qtdev_alinea_doze%type;
  rat_cdsitres   cecred.tbrat_informacao_rating.cdsituacao_residencia%type;
  rat_vlpreatv   cecred.tbrat_informacao_rating.vlprestacao_ativa%type;
  rat_vlsalari   cecred.tbrat_informacao_rating.vlsalario%type;
  rat_vlrendim   cecred.tbrat_informacao_rating.vloutros_rendimentos%type;
  rat_vlsalcje   cecred.tbrat_informacao_rating.vlsalario_conjuge%type;
  rat_vlendivi   cecred.tbrat_informacao_rating.vlendividamento%type;
  rat_vlbemtit   cecred.tbrat_informacao_rating.vlbem_titular%type;
  rat_flgcjeco   cecred.tbrat_informacao_rating.flgconjuge_corresponsavel%type;
  rat_vlbemcje   cecred.tbrat_informacao_rating.vlbem_conjuge%type;
  rat_vlsldeve   cecred.tbrat_informacao_rating.vlsaldo_devedor%type;
  rat_vlopeatu   cecred.tbrat_informacao_rating.vloperacao_atual%type;
  rat_vlslcota   cecred.tbrat_informacao_rating.vlsaldo_cotas%type;
  rat_cdquaope   cecred.tbrat_informacao_rating.cdqualificacao_operacao%type;
  rat_cdtpoper   cecred.tbrat_informacao_rating.cdtipo_operacao%type;
  rat_cdlincre   cecred.tbrat_informacao_rating.cdlinha_credito%type;
  rat_cdmodali   cecred.tbrat_informacao_rating.cdmodalidade_linha_cred%type;
  rat_cdsubmod   cecred.tbrat_informacao_rating.cdsubmodalidade_linha_cred%type;
  rat_cdgarope   cecred.tbrat_informacao_rating.cdgarantia_operacao%type;
  rat_cdliqgar   cecred.tbrat_informacao_rating.cdliquidez_garantia%type;
  rat_qtpreope   cecred.tbrat_informacao_rating.qtprestacao_operacao%type;
  rat_dtfunemp   cecred.tbrat_informacao_rating.dtfundacao_empresa%type;
  rat_cdseteco   cecred.tbrat_informacao_rating.cdsetor_economico%type;
  rat_dtprisoc   cecred.tbrat_informacao_rating.dtprimeiro_socio%type;
  rat_prfatcli   cecred.tbrat_informacao_rating.prfaturamento_cliente%type;
  rat_vlmedfat   cecred.tbrat_informacao_rating.vlmedia_faturamento_anual%type;
  rat_vlbemavt   cecred.tbrat_informacao_rating.vlbem_avalista%type;
  rat_vlbemsoc   cecred.tbrat_informacao_rating.vlbem_socio%type;
  rat_vlparope   cecred.tbrat_informacao_rating.vlparcela_operacao%type;
  rat_cdperemp   cecred.tbrat_informacao_rating.cdpercepcao_empresa%type;
  rat_dstpoper   cecred.tbrat_informacao_rating.dstipo_operacao%type;
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
          ,cdfinemp
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
          ,flgdocje
      FROM crapprp
     WHERE crapprp.cdcooper = pr_cdcooper
       AND crapprp.nrdconta = pr_nrdconta
       AND crapprp.tpctrato = pr_tpctrato
       AND crapprp.nrctrato = pr_nrctrato;

  -- Ler Cadastro de Linhas de Credito
  CURSOR cr_craplcr(pr_cdcooper craplcr.cdcooper%type
                   ,pr_cdlcremp craplcr.cdlcremp%type) IS
    SELECT dsoperac
         , cdmodali
         , cdsubmod
      FROM craplcr
     WHERE craplcr.cdcooper = pr_cdcooper
       AND craplcr.cdlcremp = pr_cdlcremp;

  -- Ler Cadastro de Finalidades
  CURSOR cr_crapfin(pr_cdcooper crapfin.cdcooper%type
                   ,pr_cdfinemp crapfin.cdfinemp%type) IS
    SELECT crapfin.tpfinali
      FROM crapfin
     WHERE crapfin.cdcooper = pr_cdcooper
       AND crapfin.cdfinemp = pr_cdfinemp;

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

  -- Ler Proposta de Limite de credito
  CURSOR cr_crawlim(pr_cdcooper IN crawlim.cdcooper%TYPE
                   ,pr_nrdconta IN crawlim.nrdconta%TYPE
                   ,pr_tpctrato IN crawlim.tpctrlim%TYPE
                   ,pr_nrctrato IN crawlim.nrctrlim%TYPE) IS
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
      FROM crawlim
     WHERE crawlim.cdcooper = pr_cdcooper
       AND crawlim.nrdconta = pr_nrdconta
       AND crawlim.tpctrlim = pr_tpctrato
       AND crawlim.nrctrlim = pr_nrctrato;

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
       AND crapris.cdmodali in (299, 499) --> Somente de empréstimos
     GROUP BY cdcooper, nrdconta;

  CURSOR cr_crapris_all (pr_dtmvtolt crapris.dtrefere%TYPE)IS
    SELECT cdcooper, nrdconta, nvl(max(nvl(qtdiaatr,0)),0) qtdiaatr
      FROM crapris
     WHERE crapris.dtrefere >= add_months(pr_dtmvtolt,-12) -- 12 meses atras
       AND crapris.dtrefere <= (pr_dtmvtolt - to_char(pr_dtmvtolt,'DD')) -- Ult dia mes anterior
       AND crapris.inddocto = 1            --> Somente ativos
       AND crapris.cdmodali in (299, 499) --> Somente de empréstimos
     GROUP BY cdcooper, nrdconta;

  -- Busca dos sócios cadastrados
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

  /* Rotina responsavel por buscar a descrição da operacao do tipo de contrato */
  FUNCTION fn_busca_descricao_operacao (pr_tpctrrat IN INTEGER) RETURN VARCHAR2 IS
  BEGIN
  /* ..........................................................................

     Programa: fn_busca_descricao_operacao         Antigo: b1wgen0043.p/descricao-operacao
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Alisson C. Berrido
     Data    : Maio/2013.                          Ultima Atualizacao:29/05/2013

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  : Buscar a descricao da operacao

     Alteracoes: 29/05/2013 - Conversão Progress -> Oracle - Alisson (AMcom)

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

  /* Rotina responsavel por buscar a descrição da situacao do contrato */
  FUNCTION fn_busca_descricao_situacao (pr_insitrat IN INTEGER) RETURN VARCHAR2 IS
  BEGIN
  /* ..........................................................................

     Programa: fn_busca_descricao_situacao         Antigo: b1wgen0043.p/descricao-situacao
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Marcos E. Martini
     Data    : Agosto/2014.                          Ultima Atualizacao: 27/07/2014

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  : Buscar a descricao da situação do contrato

     Alteracoes: 27/07/2014 - Conversão Progress -> Oracle - Marcos (Supero)

  ............................................................................. */
    BEGIN
      -- Retonar a situação conforme o código (Domínio)
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
     Data    : Maio/2016.                          Ultima Atualizacao: 01/05/2016

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
      IF pr_cdcooper <> 3 THEN
        RETURN TRUE;
      END IF;

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

  /* Rotina responsável por obter o nivel de risco */
  PROCEDURE pc_obtem_risco (pr_cdcooper       IN crapcop.cdcooper%TYPE --Código da Cooperativa
                           ,pr_nrdconta       IN crapass.nrdconta%TYPE --Numero da Conta do Associado
                           ,pr_tab_dsdrisco   IN RATI0001.typ_tab_dsdrisco --Vetor com dados das provisoes
                           ,pr_dstextab_bacen IN craptab.dstextab%TYPE --Descricao da craptab do RISCOBACEN
                           ,pr_dtmvtolt       IN crapdat.dtmvtolt%TYPE --Data Movimento
                           ,pr_nivrisco       OUT VARCHAR2             --Nivel de Risco
                           ,pr_dtrefere       OUT DATE                 --Data de Referencia do Risco
                           ,pr_cdcritic       OUT INTEGER              --Código da Critica de Erro
                           ,pr_dscritic       OUT VARCHAR2) IS         --Descricao do erro
  BEGIN
  /* ..........................................................................

     Programa: pc_obtem_risco         Antigo: b1wgen9999.p/obtem_risco
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Alisson C. Berrido
     Data    : Maio/2013.                          Ultima Atualizacao: 28/06/2017

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  : Buscar o nivel de risco da conta

     Alteracoes: 29/05/2013 - Conversão Progress -> Oracle - Alisson (AMcom)

                 25/06/2014 - Ajuste leitura crapris. SoftDesk 137892 (Daniel)

                 14/08/2015 - Ajuste na leitura crapris para as operacoes menor que o
                              valor do arrasto. (James)

                 29/03/2016 - Replicar manutenção realizada no progress SD352945 (Odirlei-AMcom)

                 28/06/2017 - Inclusão para setar o modulo de todas procedures da Package
                              ( Belli - Envolti - 28/06/2017 - Chamado 660306).

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

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_obtem_risco');

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

      --Verificar se são contratos antigos
      IF Upper(Trim(pr_nivrisco)) = 'AA' THEN
        pr_nivrisco:= NULL;
        pr_dtrefere:= NULL;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 29/06/2018 - Chamado 660306
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na rotina RATI0001.pc_obtem_risco '||SQLERRM;
    END;
  END;

  /* Retornar o valor de parâmetro de rating da TAB036 */
  PROCEDURE pc_param_valor_rating(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Código da Cooperativa
                                 ,pr_vlrating OUT NUMBER                --> Valor parametrizado
                                 ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                 ,pr_dscritic OUT VARCHAR2) IS          --> Descrição erro encontrado
  BEGIN
    /* ..........................................................................

       Programa: pc_param_valor_rating         Antigo: b1wgen0043 --> parametro_valor_rating
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Marcos Ernani Martini
       Data    : Junho/2013.                          Ultima Atualizacao: 28/06/2017

       Dados referentes ao programa:

       Frequencia: Sempre que chamado por outros programas.
       Objetivo  : Retornar valor parametrizado de rating na TAB036 para a Cooperativa.

       Alteracoes: 04/06/2013 - Conversão Progress -> Oracle - Marcos (Supero)

                   28/06/2017 - Acerto do padrão de retorno das situações de mensagem
                              - Inclusão para setar o modulo de todas procedures da Package
                                ( Belli - Envolti - 28/06/2017 - Chamado 660306).

    ............................................................................. */
    DECLARE
      /* Cursor genérico de parametrização */
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

      -- Variável de críticas
      vr_cdcritic   crapcri.cdcritic%TYPE;
      vr_dscritic   VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;

    BEGIN

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_param_valor_rating');

      pr_dscritic := NULL;
      pr_cdcritic := NULL;
      pr_vlrating := NULL;

      -- Se a tabela com as informações de valor por coop estiver vazia
      IF NOT vr_vet_vlrating.EXISTS(pr_cdcooper) THEN
        -- Busca de todos registros para atualizar o vetor
        FOR rw_craptab IN cr_craptab(pr_nmsistem => 'CRED'
                                    ,pr_tptabela => 'GENERI'
                                    ,pr_cdempres => 00
                                    ,pr_cdacesso => 'PROVISAOCL'
                                    ,pr_tpregist => 999) LOOP
          -- Adicionar no vetor cmfe a cooperativa do registro e o valor
          -- de rating está nas 11 posições a partir do caracter 15 do parâmetro
          vr_vet_vlrating(rw_craptab.cdcooper) := gene0002.fn_char_para_number(substr(rw_craptab.dstextab,15,11));

        -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_param_valor_rating');
        END LOOP;
      END IF;
      -- Com a temp-table carregada, iremos buscar o valor correspondente a cooperativa solicitada
      pr_vlrating := vr_vet_vlrating(pr_cdcooper);
      -- Se não encontrou informação
      IF pr_vlrating IS NULL THEN
        -- Gerar critica 55
        pr_cdcritic := 55;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 29/06/2018 - Chamado 660306
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
        -- Gerar erro não tratado
        pr_cdcritic := 9999;
        pr_dscritic := 'RATI0001.pc_param_valor_rating. Detalhes: '||sqlerrm;
    END;
  END pc_param_valor_rating;

  /* Retornar o valor maximo legal da Cooperativa */
  PROCEDURE pc_valor_maximo_legal(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Código da Cooperativa
                                 ,pr_vlmaxleg OUT NUMBER                --> Valor parametrizado
                                 ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                 ,pr_dscritic OUT VARCHAR2) IS          --> Descrição erro encontrado
  BEGIN
    /* ..........................................................................

       Programa: pc_valor_maximo_legal         Antigo: b1wgen0043 --> valor_maximo_legal
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Marcos Ernani Martini
       Data    : Junho/2013.                          Ultima Atualizacao: 28/06/2017

       Dados referentes ao programa:

       Frequencia: Sempre que chamado por outros programas.
       Objetivo  : Retornar valor maximo legal cadastrado na CADCOP

       Alteracoes: 04/06/2013 - Conversão Progress -> Oracle - Marcos (Supero)

                   28/06/2017 - Inclusão para setar o modulo de todas procedures da Package
                               ( Belli - Envolti - 28/06/2017 - Chamado 660306).

    ............................................................................. */
    DECLARE
      -- Busca da cooperativa
      CURSOR cr_crapcop IS
        SELECT vlmaxleg
          FROM crapcop
         WHERE cdcooper = pr_cdcooper;
    BEGIN

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_valor_maximo_legal');

      -- Buscar na CADCOP
      OPEN cr_crapcop;
      FETCH cr_crapcop
       INTO pr_vlmaxleg;
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Gerar critica 651
        pr_cdcritic := 651;
      END IF;
      -- Fechar o cursor
      CLOSE cr_crapcop;
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 29/06/2018 - Chamado 660306
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
        -- Gerar erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na rotina RATI0001.pc_valor_maximo_legal. Detalhes: '||sqlerrm;
    END;
  END pc_valor_maximo_legal;

  /* Limpar campo da origem do Rating */
  PROCEDURE pc_limpa_rating_origem(pr_cdcooper  IN crapcop.cdcooper%TYPE     --> Código da Cooperativa
                                  ,pr_nrdconta  IN crapass.nrdconta%TYPE     --> Conta do associado
                                  ,pr_dscritic OUT VARCHAR2) IS              --> Descritivo do erro
  BEGIN
    /* ..........................................................................

       Programa: pc_limpa_rating_origem         Antigo: b1wgen0043 --> limpa_rating_origem
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Marcos Ernani Martini
       Data    : Junho/2013.                          Ultima Atualizacao: 28/06/2017

       Dados referentes ao programa:

       Frequencia: Sempre que chamado por outros programas.
       Objetivo  : Limpar campo da origem do Rating.

       Alteracoes: 03/06/2013 - Conversão Progress -> Oracle - Marcos (Supero)

                   28/06/2017 - Inclusão para setar o modulo de todas procedures da Package
                               ( Belli - Envolti - 28/06/2017 - Chamado 660306).

    ............................................................................. */
    BEGIN

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_limpa_rating_origem');

      UPDATE crapnrc
         SET flgorige = 0 -- False
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta;
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 29/06/2018 - Chamado 660306
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
        -- Gerar erro
        pr_dscritic := 'Erro na rotina RATI0001.pc_limpa_rating_origem. Detalhes: '||sqlerrm;
    END;
  END pc_limpa_rating_origem;

  /* Gravar o Rating que deu origem ao efetivo. */
  PROCEDURE pc_grava_rating_origem(pr_cdcooper  IN crapcop.cdcooper%TYPE     --> Código da Cooperativa
                                  ,pr_nrdconta  IN crapass.nrdconta%TYPE     --> Conta do associado
                                  ,pr_rowidnrc  IN ROWID DEFAULT NULL        --> Rowid para gravação do rating
                                  ,pr_tpctrato  IN PLS_INTEGER DEFAULT 0     --> Tipo do contrato de rating
                                  ,pr_nrctrato  IN PLS_INTEGER DEFAULT 0     --> Número do contrato do rating
                                  ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Critica encontrada no processo
                                  ,pr_dscritic OUT VARCHAR2) IS              --> Descritivo do erro
  BEGIN
    /* ..........................................................................

       Programa: pc_grava_rating_origem         Antigo: b1wgen0043 --> grava_rating_origem
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Marcos Ernani Martini
       Data    : Junho/2013.                          Ultima Atualizacao: 28/06/2017

       Dados referentes ao programa:

       Frequencia: Sempre que chamado por outros programas.
       Objetivo  : Gravar o Rating que deu origem ao efetivo.

       Alteracoes: 03/06/2013 - Conversão Progress -> Oracle - Marcos (Supero)

                   28/06/2017 - Inclusão para setar o modulo de todas procedures da Package
                               ( Belli - Envolti - 28/06/2017 - Chamado 660306).

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

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_grava_rating_origem');

      -- Se já foi passado o Rowid a processar
      IF pr_rowidnrc IS NOT NULL THEN
        -- Utilizaremos o mesmo
        vr_rowidnrc := pr_rowidnrc;
      ELSE
        -- Buscar o mesmo com base nos parâmetros passados
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
        -- No caso de erro de programa gravar tabela especifica de log - 29/06/2018 - Chamado 660306
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
        -- Retorno não OK
        pr_cdcritic := 0;
        -- Gerar erro
        pr_dscritic := 'Erro não tratado na rotina RATI0001.pc_grava_rating_origem. Detalhes: '||sqlerrm;
    END;
  END pc_grava_rating_origem;

  /* Mudar situacao do Rating para efetivo */
  PROCEDURE pc_muda_situacao_efetivo(pr_rowidnrc  IN ROWID DEFAULT NULL        --> Rowid para gravação do rating
                                    ,pr_cdoperad  IN crapnrc.cdoperad%TYPE     --> Código do operador
                                    ,pr_dtmvtolt  IN DATE                      --> Data atual
                                    ,pr_vlutiliz  IN NUMBER                    --> Valor para lançamento
                                    ,pr_flgatual  IN BOOLEAN                   --> Flag para atualização sim/nao
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Critica encontrada no processo
                                    ,pr_dscritic OUT VARCHAR2) IS              --> Descritivo do erro
  BEGIN
    /* ..........................................................................

       Programa: pc_muda_situacao_efetivo         Antigo: b1wgen0043 --> muda_situacao_efetivo
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Marcos Ernani Martini
       Data    : Junho/2013.                          Ultima Atualizacao: 28/06/2017

       Dados referentes ao programa:

       Frequencia: Sempre que chamado por outros programas.
       Objetivo  : Mudar situacao do Rating para Efetivo.

       Alteracoes: 04/06/2013 - Conversão Progress -> Oracle - Marcos (Supero)

                   28/06/2017 - Inclusão para setar o modulo de todas procedures da Package
                               ( Belli - Envolti - 28/06/2017 - Chamado 660306).

    ............................................................................. */
    DECLARE
      -- Saída com erro
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

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_muda_situacao_efetivo');

      -- Buscar as informações do rating a partir do Rowid
      OPEN cr_crapnrc;
      FETCH cr_crapnrc
       INTO rw_crapnrc;
      -- Se não encontrou informações
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
          -- No caso de erro de programa gravar tabela especifica de log - 29/06/2018 - Chamado 660306
          CECRED.pc_internal_exception (pr_cdcooper => rw_crapnrc.cdcooper);
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
          -- No caso de erro de programa gravar tabela especifica de log - 29/06/2018 - Chamado 660306
          CECRED.pc_internal_exception (pr_cdcooper => NULL);
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
        -- No caso de erro de programa gravar tabela especifica de log - 29/06/2018 - Chamado 660306
        CECRED.pc_internal_exception (pr_cdcooper => NULL);
        -- Retorno não OK
        pr_cdcritic := 0;
        -- Gerar erro
        pr_dscritic := 'Erro não tratado na rotina RATI0001.pc_muda_situacao_efetivo. Detalhes: '||sqlerrm;
    END;
  END pc_muda_situacao_efetivo;

  /* Mudar situacao do Rating para proposto */
  PROCEDURE pc_muda_situacao_proposto(pr_cdcooper  IN crapcop.cdcooper%TYPE     --> Código da Cooperativa
                                     ,pr_nrdconta  IN crapass.nrdconta%TYPE     --> Conta do associado
                                     ,pr_dtmvtolt  IN DATE                      --> Data atual
                                     ,pr_vlutiliz  IN NUMBER                    --> Valor para lançamento
                                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Critica encontrada no processo
                                     ,pr_dscritic OUT VARCHAR2) IS              --> Descritivo do erro
  BEGIN
    /* ..........................................................................

       Programa: pc_muda_situacao_proposto         Antigo: b1wgen0043 --> muda_situacao_proposto
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Marcos Ernani Martini
       Data    : Junho/2013.                          Ultima Atualizacao: 28/06/2017

       Dados referentes ao programa:

       Frequencia: Sempre que chamado por outros programas.
       Objetivo  : Mudar situacao do Rating para proposto.

       Alteracoes: 04/06/2013 - Conversão Progress -> Oracle - Marcos (Supero)

                   28/06/2017 - Inclusão para setar o modulo de todas procedures da Package
                               ( Belli - Envolti - 28/06/2017 - Chamado 660306).

    ............................................................................. */
    DECLARE
      -- Saída com erro
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
      vr_flgativo crapnrc.flgativo%TYPE; -- Flag para ativação ou não do rating
    BEGIN

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_muda_situacao_proposto');

      -- Buscar as informações do rating a partir do Rowid
      OPEN cr_crapnrc;
      FETCH cr_crapnrc
       INTO rw_crapnrc;
      -- Se não encontrou informações
      IF cr_crapnrc%NOTFOUND THEN
        -- Apenas fechar o cursor e não é necessária nenhuma atualização
        CLOSE cr_crapnrc;
      ELSE
        -- Fechar e continuar
        CLOSE cr_crapnrc;
        -- Adicionar 6 meses a data do rating
        vr_dtmvtolt := ADD_MONTHS(rw_crapnrc.dtmvtolt,6);
        -- Se hoje eh maior ou igual a efetivacao + 6 meses Ou se é um Rating antigo ... entao DESATIVA
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
            -- No caso de erro de programa gravar tabela especifica de log - 29/06/2018 - Chamado 660306
            CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
            pr_cdcritic := 0;
            pr_dscritic := 'Erro ao atualizar o rating(CRAPNRC), Rowid: '||rw_crapnrc.rowid||'. Detalhes: '||sqlerrm;
            -- Sair
            RAISE vr_exc_erro;
        END;
        -- Como esta desefetivando, limpa a origem do Rating
        pc_limpa_rating_origem(pr_cdcooper => pr_cdcooper   --> Código da Cooperativa
                              ,pr_nrdconta => pr_nrdconta   --> Conta do associado
                              ,pr_dscritic => pr_dscritic); --> Descritivo do erro

        -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_muda_situacao_proposto');

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
        -- No caso de erro de programa gravar tabela especifica de log - 29/06/2018 - Chamado 660306
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
        -- Retorno não OK
        pr_cdcritic := 0;
        -- Gerar erro
        pr_dscritic := 'Erro não tratado na rotina RATI0001.pc_muda_situacao_proposto. Detalhes: '||sqlerrm;
    END;
  END pc_muda_situacao_proposto;

  /* Retornar o Rating Proposto com pior nota. */
  PROCEDURE pc_procura_pior_nota(pr_cdcooper  IN crapcop.cdcooper%TYPE     --> Código da Cooperativa
                                ,pr_nrdconta  IN crapass.nrdconta%TYPE     --> Conta do associado
                                ,pr_indrisco OUT crapnrc.indrisco%TYPE     --> Risco do pior rating
                                ,pr_rowidnrc OUT ROWID                     --> Rowid do pior rating
                                ,pr_nrctrrat OUT crapnrc.nrctrrat%TYPE     --> Número do contrato do pior rating
                                ,pr_dsoperac OUT VARCHAR2                  --> Descrição da operação do rating
                                ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Critica encontrada no processo
                                ,pr_dscritic OUT VARCHAR2) IS              --> Descritivo do erro
  BEGIN
    /* ..........................................................................

       Programa: pc_procura_pior_nota         Antigo: b1wgen0043 --> procura_pior_nota
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Marcos Ernani Martini
       Data    : Junho/2013.                          Ultima Atualizacao: 28/06/2017

       Dados referentes ao programa:

       Frequencia: Sempre que chamado por outros programas.
       Objetivo  : Retornar o rating com pior nota

       Alteracoes: 04/06/2013 - Conversão Progress -> Oracle - Marcos (Supero)

                   28/06/2017 - Inclusão para setar o modulo de todas procedures da Package
                               ( Belli - Envolti - 28/06/2017 - Chamado 660306).

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

      -- Busca de rating com pior nota com contrato no BNDES
      CURSOR cr_crapnrc_crapebn IS
        SELECT rowid
              ,nrc.indrisco
              ,nrc.nrctrrat
              ,nrc.tpctrrat
          FROM crapnrc nrc
         WHERE nrc.cdcooper = pr_cdcooper
           AND nrc.nrdconta = pr_nrdconta
           AND nrc.flgativo = 1  -- Yes
           AND nrc.insitrat = 1  -- Proposto
           AND (EXISTS (SELECT 1
                        FROM crapebn b
                        WHERE b.cdcooper = nrc.cdcooper
                          AND b.nrdconta = nrc.nrdconta
                          AND b.nrctremp = nrc.nrctrrat))
         ORDER BY nrc.nrnotrat,
                  nrc.dtmvtolt desc;

      vr_habrat VARCHAR2(1) := 'N'; -- P450 - Paramentro para Habilitar Novo Ratin (S/N)

    BEGIN

      vr_habrat := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                             pr_cdcooper => pr_cdcooper,
                                             pr_cdacesso => 'HABILITA_RATING_NOVO');

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_procura_pior_nota');

      -- Para cada registro de rating
      -- P450 SPT13 - alteracao para habilitar rating novo
      IF (pr_cdcooper = 3 OR vr_habrat = 'N') THEN
        FOR rw_crapnrc IN cr_crapnrc LOOP
          -- Copiar as informações aos parâmetros de saída
          pr_rowidnrc := rw_crapnrc.ROWID;
          pr_indrisco := rw_crapnrc.indrisco;
          pr_nrctrrat := rw_crapnrc.nrctrrat;
          -- Buscar a descrição da operação
          pr_dsoperac := fn_busca_descricao_operacao(rw_crapnrc.tpctrrat);
        END LOOP;
      ELSE
         FOR rw_crapnrc_crapebn IN cr_crapnrc_crapebn LOOP
             -- Copiar as informações aos parâmetros de saída
             pr_rowidnrc := rw_crapnrc_crapebn.ROWID;
             pr_indrisco := rw_crapnrc_crapebn.indrisco;
             pr_nrctrrat := rw_crapnrc_crapebn.nrctrrat;
             -- Buscar a descrição da operação
             pr_dsoperac := fn_busca_descricao_operacao(rw_crapnrc_crapebn.tpctrrat);
         END LOOP;
      END IF;
      -- P450 SPT13 - alteracao para habilitar rating novo

    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 29/06/2018 - Chamado 660306
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
        -- Retorno não OK
        pr_cdcritic := 0;
        -- Gerar erro
        pr_dscritic := 'Erro não tratado na rotina RATI0001.pc_procura_pior_nota. Detalhes: '||sqlerrm;
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
     Data    : Setembro/2014.                          Ultima Atualizacao: 28/06/2017

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  : Trazer os emprestimos que estao sendo liquidados em lista.

     Alteracoes: 01/09/2014 - Conversão Progress -> Oracle - Marcos (Supero)

                 28/06/2017 - Inclusão para setar o modulo de todas procedures da Package
                             ( Belli - Envolti - 28/06/2017 - Chamado 660306).

  ............................................................................. */

    -- Lista dos contratos a liquidar
    vr_dsliquid VARCHAR2(4000);
    -- Auxiliar para guardar o contrato cfme o loop
    vr_nrctrliq crawepr.nrctremp%TYPE;
  BEGIN

    -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.fn_traz_liquidacoes');

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
      -- Se existe informação na posição atual
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
  PROCEDURE pc_calcula_endividamento(pr_cdcooper   IN crapcop.cdcooper%TYPE     --> Código da Cooperativa
                                    ,pr_cdagenci   IN crapass.cdagenci%TYPE     --> Código da agência
                                    ,pr_nrdcaixa   IN craperr.nrdcaixa%TYPE     --> Número do caixa
                                    ,pr_cdoperad   IN crapnrc.cdoperad%TYPE     --> Código do operador
                                    ,pr_rw_crapdat IN btch0001.rw_crapdat%TYPE  --> Vetor com dados de parâmetro (CRAPDAT)
                                    ,pr_nrdconta   IN crapass.nrdconta%TYPE     --> Conta do associado
                                    ,pr_dsliquid   IN VARCHAR2                  --> Lista de contratos a liquidar
                                    ,pr_idseqttl   IN crapttl.idseqttl%TYPE     --> Sequencia de titularidade da conta
                                    ,pr_idorigem   IN INTEGER                   --> Indicador da origem da chamada
                                    ,pr_inusatab   IN BOOLEAN                   --> Indicador de utilização da tabela de juros
                                    ,pr_tpdecons   IN INTEGER DEFAULT 2         --> Tipo da consulta,defalut 2 saldo disponivel emprestimo sem considerar data atual, 3 saldo disponivel data atual (Ver observações da rotina GENE0005.pc_saldo_utiliza)
                                    ,pr_vlutiliz  OUT NUMBER                    --> Valor da dívida
                                    ,pr_cdcritic  OUT crapcri.cdcritic%TYPE     --> Critica encontrada no processo
                                    ,pr_dscritic  OUT VARCHAR2) IS              --> Saída de erro
  BEGIN
    /* ..........................................................................

       Programa: pc_calcula_endividamento         Antigo: b1wgen0043 --> calcula_endividamento
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Marcos Ernani Martini
       Data    : Junho/2013.                          Ultima Atualizacao: 28/06/2017

       Dados referentes ao programa:

       Frequencia: Sempre que chamado por outros programas.
       Objetivo  : Retornar o rating com pior nota

       Alteracoes: 04/06/2013 - Conversão Progress -> Oracle - Marcos (Supero)

                   28/04/2016 - Incluido parametro pr_tpdecons para permitir selecionar
                                o tipo de consulta ao buscar saldo utilizado, sendo 2(defalut) saldo utilizado dia anterior
                                e 3 saldo utilizado data atual PRJ207-Esteira (Odirlei-AMcom)

                   28/06/2017 - Inclusão para setar o modulo de todas procedures da Package
                               ( Belli - Envolti - 28/06/2017 - Chamado 660306).

    ............................................................................. */
    DECLARE
      -- Buscar o CPF da conta
      CURSOR cr_crapass IS
        SELECT nrcpfcgc
          FROM crapass
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      vr_nrcpfcgc crapass.nrcpfcgc%TYPE;

      -- Retornar todos os empréstimos não liquidados
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
      -- Lista dos contratos a liquidar nos empréstimos em aberto
      vr_dsliquid VARCHAR2(4000);

      rw_crawepr1 cr_crawepr%ROWTYPE;

    BEGIN

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_calcula_endividamento');

      -- Buscar o CPF da conta
      OPEN cr_crapass;
      FETCH cr_crapass
       INTO vr_nrcpfcgc;
      CLOSE cr_crapass;
      -- Efetuar split dos contratos passados para facilitar os testes
      vr_split_pr_dsliquid := gene0002.fn_quebra_string(replace(pr_dsliquid,';',','),',');
      -- Para todos os empréstimos não liquidados
      FOR rw_crapepr IN cr_crapepr LOOP
        -- Buscar a proposta do mesmo
        OPEN cr_crawepr(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrctrato => rw_crapepr.nrctremp);
        FETCH cr_crawepr
         INTO rw_crawepr1;
        CLOSE cr_crawepr;
        -- Traz as liquidações do mesmo
        vr_dsliquid := fn_traz_liquidacoes(pr_rw_crawepr => rw_crawepr1);
        -- Efetuar split dos contratos retornados para facilitar os testes
        vr_split_vr_dsliquid := gene0002.fn_quebra_string(vr_dsliquid,',');
        -- Ler um a um para em caso de não existir na lista, adicioná-los
        IF vr_split_vr_dsliquid.COUNT > 0 THEN
          FOR vr_cont IN vr_split_vr_dsliquid.FIRST..vr_split_vr_dsliquid.LAST LOOP
            IF NOT vr_split_pr_dsliquid.EXISTS(vr_split_vr_dsliquid(vr_cont)) THEN
              -- Adicioná-lo ao vetor
              vr_split_pr_dsliquid.EXTEND;
              vr_split_pr_dsliquid(vr_split_pr_dsliquid.COUNT) := vr_split_vr_dsliquid(vr_cont);
            END IF;
          END LOOP;
        END IF;
      END LOOP; -- Fim, contratos a liquidar

      -- Ao final, varrer o vetor para transformá-lo novamente em uma string separada por virgulas
      vr_dsliquid := '';
      IF vr_split_pr_dsliquid.COUNT > 0 THEN
        FOR vr_cont IN vr_split_pr_dsliquid.FIRST..vr_split_pr_dsliquid.LAST LOOP
          -- Adicionar o valor atual + uma virgula separadora
          vr_dsliquid := vr_dsliquid || vr_split_pr_dsliquid(vr_cont) || ',';
        END LOOP;
      END IF;
      -- Remover virgula desnecessária a direita
      vr_dsliquid := rtrim(vr_dsliquid,',');

      -- Chamar rotina para retorno do saldo em utilização
      GENE0005.pc_saldo_utiliza(pr_cdcooper => pr_cdcooper              --> Código da Cooperativa
                               ,pr_tpdecons => pr_tpdecons              --> Tipo da consulta (Ver observações da rotina)
                               ,pr_cdagenci => pr_cdagenci              --> Código da agência
                               ,pr_nrdcaixa => pr_nrdcaixa              --> Número do caixa
                               ,pr_cdoperad => pr_cdoperad              --> Código do operador
                               ,pr_nrdconta => NULL                     --> OU Consulta pela conta
                               ,pr_nrcpfcgc => vr_nrcpfcgc              --> OU Consulta pelo Numero do cpf ou cgc do associado
                               ,pr_idseqttl => pr_idseqttl              --> Sequencia de titularidade da conta
                               ,pr_idorigem => pr_idorigem              --> Indicador da origem da chamada
                               ,pr_dsctrliq => vr_dsliquid              --> Numero do contrato de liquidacao
                               ,pr_cdprogra => 'RATI0001'               --> Código do programa chamador
                               ,pr_tab_crapdat => pr_rw_crapdat         --> Tipo de registro de datas
                               ,pr_inusatab => pr_inusatab              --> Indicador de utilização da tabela de juros
                               ,pr_vlutiliz => pr_vlutiliz              --> Valor utilizado do credito
                               ,pr_cdcritic => pr_cdcritic              --> Código de retorno da critica
                               ,pr_dscritic => pr_dscritic);            --> Mensagem de retorno da critica

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_calcula_endividamento');

    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 29/06/2018 - Chamado 660306
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
        -- Retorno não OK
        pr_cdcritic := 0;
        -- Gerar erro
        pr_dscritic := 'Erro não tratado na rotina RATI0001.pc_calcula_endividamento. Detalhes: '||sqlerrm;
    END;
  END pc_calcula_endividamento;

  /* Desativar Rating. Usada quando emprestimo é liquidado ou limite é cancelado. */
  PROCEDURE pc_desativa_rating(pr_cdcooper   IN crapcop.cdcooper%TYPE     --> Código da Cooperativa
                              ,pr_cdagenci   IN crapass.cdagenci%TYPE     --> Código da agência
                              ,pr_nrdcaixa   IN craperr.nrdcaixa%TYPE     --> Número do caixa
                              ,pr_cdoperad   IN crapnrc.cdoperad%TYPE     --> Código do operador
                              ,pr_rw_crapdat IN btch0001.rw_crapdat%TYPE  --> Vetor com dados de parâmetro (CRAPDAT)
                              ,pr_nrdconta   IN crapass.nrdconta%TYPE     --> Conta do associado
                              ,pr_tpctrrat   IN NUMBER                    --> Tipo do Rating
                              ,pr_nrctrrat   IN NUMBER                    --> Número do contrato de Rating
                              ,pr_flgefeti   IN VARCHAR2                  --> Flag para efetivação ou não do Rating
                              ,pr_idseqttl   IN crapttl.idseqttl%TYPE     --> Sequencia de titularidade da conta
                              ,pr_idorigem   IN INTEGER                   --> Indicador da origem da chamada
                              ,pr_inusatab   IN BOOLEAN                   --> Indicador de utilização da tabela de juros
                              ,pr_nmdatela   IN VARCHAR2                  --> Nome datela conectada
                              ,pr_flgerlog   IN VARCHAR2                  --> Gerar log S/N
                              ,pr_des_reto  OUT VARCHAR                   --> Retorno OK / NOK
                              ,pr_tab_erro  OUT gene0001.typ_tab_erro) IS --> Tabela com possíves erros
  BEGIN
    /* ..........................................................................

       Programa: pc_desativa_rating         Antigo: b1wgen0043 --> desativa_rating
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Marcos Ernani Martini
       Data    : Junho/2013.                          Ultima Atualizacao: 28/06/2017

       Dados referentes ao programa:

       Frequencia: Sempre que chamado por outros programas.
       Objetivo  : Desativar Rating. Usada quando emprestimo é liquidado ou limite é cancelado.

       Alteracoes: 03/06/2013 - Conversão Progress -> Oracle - Marcos (Supero)

                   28/06/2017 - Inclusão para setar o modulo de todas procedures da Package
                               ( Belli - Envolti - 28/06/2017 - Chamado 660306).

    ............................................................................. */
    DECLARE
      -- Descrição e código da critica
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      -- Rowid para inserção de log
      vr_nrdrowid ROWID;
      -- Exceção de saída
      vr_exc_erro EXCEPTION;
      -- Var genérica para guardar Rowid de registro encontrado de Rating
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
      vr_vlutiliz NUMBER; -- Valor de crédito utilizado pelo cooperado
      vr_vlrating NUMBER; -- Valor parametrizado de rating
      vr_vlmaxleg NUMBER; -- Valor máximo legal
      vr_indrisco VARCHAR2(2);           -- Risco do pior rating
      vr_rowidnrc ROWID;                 -- Rowid do pior rating
      vr_nrctrrat crapnrc.nrctrrat%TYPE; -- Contrato do pior rating
      vr_dsoperac VARCHAR2(100);         -- Descrição da operação do pior rating

    BEGIN

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'RATI0001.pc_desativa_rating');

      -- Procura o rating para a proposta solicitada
      OPEN cr_crapnrc;
      FETCH cr_crapnrc
       INTO vr_ncr_rowid;
      CLOSE cr_crapnrc;
      -- Se existe rating para esta proposta
      IF vr_ncr_rowid IS NOT NULL THEN
        -- Desativá-lo
        BEGIN
          UPDATE crapnrc
             SET flgativo = 0    /* Nao ativo */
                ,insitrat = 1    /* Proposto*/
                ,dteftrat = null /* Limpa efetivacao */
                ,flgorige = 0    /* Nao é origem */
           WHERE rowid = vr_ncr_rowid;
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 29/06/2018 - Chamado 660306
            CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
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
        -- Se não tiver encontrado rating de Origem
        IF vr_ncr_rowid IS NULL THEN
          -- Cria a origem como o efetivo
          pc_grava_rating_origem(pr_cdcooper => pr_cdcooper     --> Código da Cooperativa
                                ,pr_nrdconta => pr_nrdconta     --> Conta do associado
                                ,pr_rowidnrc => vr_ncr_efetiv_rowid    --> Rowid para gravação do rating
                                ,pr_cdcritic => vr_cdcritic     --> Critica encontrada no processo
                                ,pr_dscritic => vr_dscritic);   --> Descritivo do erro

          -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
          GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'RATI0001.pc_desativa_rating');

          --------------------------------------------------------------------
          ----- Não versão progress não testava se retornou erro aqui...  ----
          --------------------------------------------------------------------

          -- Se encontrou erro
          --IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
          --  -- Gerar o erro
          --  RAISE vr_exc_erro;
          --END IF;
        END IF;
      ELSE
        -- Limpar campo da origem do Rating
        pc_limpa_rating_origem(pr_cdcooper => pr_cdcooper   --> Código da Cooperativa
                              ,pr_nrdconta => pr_nrdconta   --> Conta do associado
                              ,pr_dscritic => vr_dscritic); --> Descritivo do erro

        -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
        GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'RATI0001.pc_desativa_rating');

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
        pc_calcula_endividamento(pr_cdcooper   => pr_cdcooper     --> Código da Cooperativa
                                ,pr_cdagenci   => pr_cdagenci     --> Código da agência
                                ,pr_nrdcaixa   => pr_nrdcaixa     --> Número do caixa
                                ,pr_cdoperad   => pr_cdoperad     --> Código do operador
                                ,pr_rw_crapdat => pr_rw_crapdat   --> Vetor com dados de parâmetro (CRAPDAT)
                                ,pr_nrdconta   => pr_nrdconta     --> Conta do associado
                                ,pr_dsliquid   => ''              --> Lista de contratos a liquidar
                                ,pr_idseqttl   => pr_idseqttl     --> Sequencia de titularidade da conta
                                ,pr_idorigem   => pr_idorigem     --> Indicador da origem da chamada
                                ,pr_inusatab   => pr_inusatab     --> Indicador de utilização da tabela de juros
                                ,pr_vlutiliz   => vr_vlutiliz     --> Valor da dívida
                                ,pr_cdcritic   => vr_cdcritic     --> Critica encontrada no processo
                                ,pr_dscritic   => vr_dscritic);   --> Saída de erro

        -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
        GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'RATI0001.pc_desativa_rating');

        -- Se houve erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          -- Encerrar o processo
          RAISE vr_exc_erro;
        END IF;
        -- Retornar valor de parametrização do rating cadastrado na TAB036
        pc_param_valor_rating(pr_cdcooper => pr_cdcooper --> Código da Cooperativa
                             ,pr_vlrating => vr_vlrating --> Valor parametrizado
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);

        -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
        GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'RATI0001.pc_desativa_rating');

        -- Se houve erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          -- Encerrar o processo
          RAISE vr_exc_erro;
        END IF;
        -- Buscar valor maximo legal cadastrado pela CADCOP
        pc_valor_maximo_legal(pr_cdcooper => pr_cdcooper --> Código da Cooperativa
                             ,pr_vlmaxleg => vr_vlmaxleg --> Valor parametrizado
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);

        -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
        GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'RATI0001.pc_desativa_rating');

        -- Se houve erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          -- Encerrar o processo
          RAISE vr_exc_erro;
        END IF;
        -- Se o cooperado esta utilizando mais do que o valor legal E nao tem Rating
        IF (vr_vlutiliz >= vr_vlrating OR vr_vlutiliz >= (vr_vlmaxleg / 3))
        AND vr_ncr_efetiv_rowid IS NULL THEN
          -- Retornar o Rating Proposto com pior nota.
          pc_procura_pior_nota(pr_cdcooper => pr_cdcooper --> Código da Cooperativa
                              ,pr_nrdconta => pr_nrdconta --> Conta do associado
                              ,pr_indrisco => vr_indrisco --> Risco do pior rating
                              ,pr_rowidnrc => vr_rowidnrc --> Rowid do pior rating
                              ,pr_nrctrrat => vr_nrctrrat --> Número do contrato do pior rating
                              ,pr_dsoperac => vr_dsoperac --> Descrição da operação do rating
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);

          -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
          GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'RATI0001.pc_desativa_rating');

          -- Se houve erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            -- Encerrar o processo
            RAISE vr_exc_erro;
          END IF;
          -- Se existe Rating a efetivar
          IF vr_rowidnrc IS NOT NULL THEN
            -- Mudar situacao do Rating para efetivo
            pc_muda_situacao_efetivo(pr_rowidnrc  => vr_rowidnrc            --> Rowid para gravação do rating
                                    ,pr_cdoperad  => pr_cdoperad            --> Código do operador
                                    ,pr_dtmvtolt  => pr_rw_crapdat.dtmvtolt --> Data atual
                                    ,pr_vlutiliz  => vr_vlutiliz            --> Valor para lançamento
                                    ,pr_flgatual  => FALSE                  --> Não atualizar
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);

            -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
            GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'RATI0001.pc_desativa_rating');

            --------------------------------------------------------------------
            ----- Não versão progress não testava se retornou erro aqui...  ----
            --------------------------------------------------------------------

            -- Se houve erro
            --IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            --  -- Encerrar o processo
            --  RAISE vr_exc_erro;
            --END IF;
            -- Gravar o rating de origem
            pc_grava_rating_origem(pr_cdcooper => pr_cdcooper     --> Código da Cooperativa
                                  ,pr_nrdconta => pr_nrdconta     --> Conta do associado
                                  ,pr_rowidnrc => vr_rowidnrc     --> Rowid para gravação do rating
                                  ,pr_cdcritic => vr_cdcritic     --> Critica encontrada no processo
                                  ,pr_dscritic => vr_dscritic);   --> Descritivo do erro

            -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
            GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'RATI0001.pc_desativa_rating');

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
        pc_muda_situacao_proposto(pr_cdcooper  => pr_cdcooper            --> Código da Cooperativa
                                 ,pr_nrdconta  => pr_nrdconta            --> Conta do associado
                                 ,pr_dtmvtolt  => pr_rw_crapdat.dtmvtolt --> Data atual
                                 ,pr_vlutiliz  => vr_vlutiliz            --> Valor para lançamento
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);

        -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
        GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'RATI0001.pc_desativa_rating');

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

        -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
        GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'RATI0001.pc_desativa_rating');

      END IF;
      -- Retorno OK
      pr_des_reto := 'OK';
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
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
        -- No caso de erro de programa gravar tabela especifica de log - 29/06/2018 - Chamado 660306
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Montar descrição de erro não tratado
        vr_dscritic := 'Erro não tratado na RATI0001.pc_desativa_rating> '||sqlerrm;
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
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


  /* Ativar Rating. Usada quando emprestimo é liquidado ou limite é cancelado. */
  PROCEDURE pc_ativa_rating(pr_cdcooper   IN crapcop.cdcooper%TYPE     --> Código da Cooperativa
                           ,pr_cdagenci   IN crapass.cdagenci%TYPE     --> Código da agência
                           ,pr_nrdcaixa   IN craperr.nrdcaixa%TYPE     --> Número do caixa
                           ,pr_cdoperad   IN crapnrc.cdoperad%TYPE     --> Código do operador
                           ,pr_rw_crapdat IN btch0001.rw_crapdat%TYPE  --> Vetor com dados de parâmetro (CRAPDAT)
                           ,pr_nrdconta   IN crapass.nrdconta%TYPE     --> Conta do associado
                           ,pr_tpctrrat   IN NUMBER                    --> Tipo do Rating
                           ,pr_nrctrrat   IN NUMBER                    --> Número do contrato de Rating
                           ,pr_idseqttl   IN crapttl.idseqttl%TYPE     --> Sequencia de titularidade da conta
                           ,pr_idorigem   IN INTEGER                   --> Indicador da origem da chamada
                           ,pr_inusatab   IN BOOLEAN                   --> Indicador de utilização da tabela de juros
                           ,pr_nmdatela   IN VARCHAR2                  --> Nome datela conectada
                           ,pr_flgerlog   IN VARCHAR2                  --> Gerar log S/N
                           ,pr_des_reto  OUT VARCHAR2                  --> Retorno OK / NOK
                           ,pr_dscritic  OUT VARCHAR2                  --> Mensagem de erro
                           ,pr_tab_erro  OUT gene0001.typ_tab_erro) IS --> Tabela com possíves erros
  BEGIN
    /* ..........................................................................

       Programa: pc_ativa_rating         Antigo: b1wgen0043 --> ativa_rating
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Alisson C. Berrido
       Data    : Julho/2013.                          Ultima Atualizacao: 28/06/2017

       Dados referentes ao programa:

       Frequencia: Sempre que chamado por outros programas.
       Objetivo  : Desativar Rating. Usada quando emprestimo é liquidado ou limite é cancelado.

       Alteracoes: 25/07/2013 - Conversão Progress -> Oracle - Alisson (AMcom)

                   28/06/2017 - Inclusão para setar o modulo de todas procedures da Package
                               ( Belli - Envolti - 28/06/2017 - Chamado 660306).

    ............................................................................. */
    DECLARE
      -- Descrição e código da critica
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      -- Rowid para inserção de log
      vr_nrdrowid ROWID;
      -- Exceção de saída
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
      vr_vlutiliz NUMBER; -- Valor de crédito utilizado pelo cooperado
      vr_vlrating NUMBER; -- Valor parametrizado de rating
      vr_vlmaxleg NUMBER; -- Valor máximo legal
      vr_indrisco VARCHAR2(2);           -- Risco do pior rating
      vr_rowidnrc ROWID;                 -- Rowid do pior rating
      vr_nrctrrat crapnrc.nrctrrat%TYPE; -- Contrato do pior rating
      vr_dsoperac VARCHAR2(100);         -- Descrição da operação do pior rating

    BEGIN

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_ativa_rating');

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
      pc_calcula_endividamento(pr_cdcooper   => pr_cdcooper     --> Código da Cooperativa
                              ,pr_cdagenci   => pr_cdagenci     --> Código da agência
                              ,pr_nrdcaixa   => pr_nrdcaixa     --> Número do caixa
                              ,pr_cdoperad   => pr_cdoperad     --> Código do operador
                              ,pr_rw_crapdat => pr_rw_crapdat   --> Vetor com dados de parâmetro (CRAPDAT)
                              ,pr_nrdconta   => pr_nrdconta     --> Conta do associado
                              ,pr_dsliquid   => ''              --> Lista de contratos a liquidar
                              ,pr_idseqttl   => pr_idseqttl     --> Sequencia de titularidade da conta
                              ,pr_idorigem   => pr_idorigem     --> Indicador da origem da chamada
                              ,pr_inusatab   => pr_inusatab     --> Indicador de utilização da tabela de juros
                              ,pr_vlutiliz   => vr_vlutiliz     --> Valor da dívida
                              ,pr_cdcritic   => vr_cdcritic     --> Critica encontrada no processo
                              ,pr_dscritic   => vr_dscritic);   --> Saída de erro

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_ativa_rating');

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
          -- No caso de erro de programa gravar tabela especifica de log - 29/06/2018 - Chamado 660306
          CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
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
        /* Nota deste contrato é pior do que nota do Efetivo */
        IF rw_crapnrc.nrnotrat > rw_crapnrc_efetivo.nrnotrat THEN

      vr_rowidnrc := rw_crapnrc.ROWID;

          /* Volta para Proposto o efetivo atual */
          pc_muda_situacao_proposto(pr_cdcooper  => pr_cdcooper            --> Código da Cooperativa
                                   ,pr_nrdconta  => pr_nrdconta            --> Conta do associado
                                   ,pr_dtmvtolt  => pr_rw_crapdat.dtmvtolt --> Data atual
                                   ,pr_vlutiliz  => vr_vlutiliz            --> Valor para lançamento
                                   ,pr_cdcritic  => vr_cdcritic
                                   ,pr_dscritic  => vr_dscritic);
          -- Se houve erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            -- Encerrar o processo
            RAISE vr_exc_erro;
          END IF;
          /* Efetivar este contrato (pior nota) */
          -- Mudar situacao do Rating para efetivo
          pc_muda_situacao_efetivo(pr_rowidnrc  => vr_rowidnrc            --> Rowid para gravação do rating
                                  ,pr_cdoperad  => pr_cdoperad            --> Código do operador
                                  ,pr_dtmvtolt  => pr_rw_crapdat.dtmvtolt --> Data atual
                                  ,pr_vlutiliz  => vr_vlutiliz            --> Valor para lançamento
                                  ,pr_flgatual  => FALSE                  --> Não atualizar
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => vr_dscritic);
          -- Se houve erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            -- Encerrar o processo
            RAISE vr_exc_erro;
          END IF;
          -- Gravar o rating de origem
          pc_grava_rating_origem(pr_cdcooper => pr_cdcooper     --> Código da Cooperativa
                                ,pr_nrdconta => pr_nrdconta     --> Conta do associado
                                ,pr_rowidnrc => vr_rowidnrc     --> Rowid para gravação do rating
                                ,pr_cdcritic => vr_cdcritic     --> Critica encontrada no processo
                                ,pr_dscritic => vr_dscritic);   --> Descritivo do erro

          -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
          GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_ativa_rating');

          -- Se encontrou erro
          IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
            -- Gerar o erro
            RAISE vr_exc_erro;
          END IF;
        END IF;
      ELSE /* Nao tem rating efetivo */
        /* Cadastrado na TAB036 */
        -- Retornar valor de parametrização do rating cadastrado na TAB036
        pc_param_valor_rating(pr_cdcooper => pr_cdcooper --> Código da Cooperativa
                             ,pr_vlrating => vr_vlrating --> Valor parametrizado
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);

        -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_ativa_rating');

        -- Se houve erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          -- Encerrar o processo
          RAISE vr_exc_erro;
        END IF;
        -- Buscar valor maximo legal cadastrado pela CADCOP
        pc_valor_maximo_legal(pr_cdcooper => pr_cdcooper --> Código da Cooperativa
                             ,pr_vlmaxleg => vr_vlmaxleg --> Valor parametrizado
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);

        -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_ativa_rating');

        -- Se houve erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          -- Encerrar o processo
          RAISE vr_exc_erro;
        END IF;
         /* Operacao atual maior/igual  do que valor Rating ou 5 % PR */
        IF (vr_vlutiliz >= vr_vlrating OR vr_vlutiliz >= (vr_vlmaxleg / 3)) THEN
          -- Retornar o Rating Proposto com pior nota.
          pc_procura_pior_nota(pr_cdcooper => pr_cdcooper --> Código da Cooperativa
                              ,pr_nrdconta => pr_nrdconta --> Conta do associado
                              ,pr_indrisco => vr_indrisco --> Risco do pior rating
                              ,pr_rowidnrc => vr_rowidnrc --> Rowid do pior rating
                              ,pr_nrctrrat => vr_nrctrrat --> Número do contrato do pior rating
                              ,pr_dsoperac => vr_dsoperac --> Descrição da operação do rating
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);

          -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
          GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_ativa_rating');

          --------------------------------------------------------------------
          ----- Não versão progress não testava se retornou erro aqui...  ----
          --------------------------------------------------------------------
          -- Se houve erro
          --IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --  -- Encerrar o processo
          --  RAISE vr_exc_erro;
          --END IF;
          -- Se existe Rating a efetivar
          IF vr_rowidnrc IS NOT NULL THEN
            -- Mudar situacao do Rating para efetivo
            pc_muda_situacao_efetivo(pr_rowidnrc  => vr_rowidnrc            --> Rowid para gravação do rating
                                    ,pr_cdoperad  => pr_cdoperad            --> Código do operador
                                    ,pr_dtmvtolt  => pr_rw_crapdat.dtmvtolt --> Data atual
                                    ,pr_vlutiliz  => vr_vlutiliz            --> Valor para lançamento
                                    ,pr_flgatual  => FALSE                  --> Não atualizar
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);

            -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
            GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_ativa_rating');

            -- Se houve erro
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              -- Encerrar o processo
              RAISE vr_exc_erro;
            END IF;
            -- Gravar o rating de origem
            pc_grava_rating_origem(pr_cdcooper => pr_cdcooper     --> Código da Cooperativa
                                  ,pr_nrdconta => pr_nrdconta     --> Conta do associado
                                  ,pr_rowidnrc => vr_rowidnrc     --> Rowid para gravação do rating
                                  ,pr_cdcritic => vr_cdcritic     --> Critica encontrada no processo
                                  ,pr_dscritic => vr_dscritic);   --> Descritivo do erro

            -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
            GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_ativa_rating');

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
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
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
        -- No caso de erro de programa gravar tabela especifica de log - 29/06/2018 - Chamado 660306
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Montar descrição de erro não tratado
        vr_dscritic := 'Erro não tratado na RATI0001.pc_ativa_rating> '||sqlerrm;
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
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
     Data    : Julho/2013.                          Ultima Atualizacao: 28/06/2017

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  : Verificar contrato rating

     Alteracoes: 24/07/2013 - Conversão Progress -> Oracle - Alisson (AMcom)

                 28/06/2017 - Inclusão para setar o modulo de todas procedures da Package
                             ( Belli - Envolti - 28/06/2017 - Chamado 660306).

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

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'RATI0001.pc_verifica_contrato_rating');

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
      -- Se não encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
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
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

        -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
        GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'RATI0001.pc_verifica_contrato_rating');

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

          -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
          GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'RATI0001.pc_verifica_contrato_rating');

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
      -- Se a primeira posição do campo
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
          pc_ativa_rating(pr_cdcooper   => pr_cdcooper    --> Código da Cooperativa
                         ,pr_cdagenci   => pr_cdagenci    --> Código da agência
                         ,pr_nrdcaixa   => pr_nrdcaixa    --> Número do caixa
                         ,pr_cdoperad   => pr_cdoperad    --> Código do operador
                         ,pr_rw_crapdat => rw_crapdat     --> Vetor com dados de parâmetro (CRAPDAT)
                         ,pr_nrdconta   => pr_nrdconta    --> Conta do associado
                         ,pr_tpctrrat   => pr_tpctrrat    --> Tipo do Rating
                         ,pr_nrctrrat   => pr_nrctrrat    --> Número do contrato de Rating
                         ,pr_idseqttl   => pr_idseqttl    --> Sequencia de titularidade da conta
                         ,pr_idorigem   => pr_idorigem    --> Indicador da origem da chamada
                         ,pr_inusatab   => vr_inusatab    --> Indicador de utilização da tabela de juros
                         ,pr_nmdatela   => pr_nmdatela    --> Nome datela conectada
                         ,pr_flgerlog   => vr_flgerlog    --> Gerar log S/N
                         ,pr_des_reto   => vr_des_erro    --> Retorno OK / NOK
                         ,pr_dscritic   => vr_dscritic    --> Descricao do erro
                         ,pr_tab_erro   => vr_tab_erro);  --> Tabela com possíves erros

          -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
          GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'RATI0001.pc_verifica_contrato_rating');

          --Se ocorreu erro
          IF vr_des_erro = 'NOK' THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
        END IF;

      ELSE  /* Liquidado */

        IF  rw_crapnrc.flgativo = 1  THEN /* Ativo */
          --Desativar o Rating
          pc_desativa_rating(pr_cdcooper   => pr_cdcooper    --> Código da Cooperativa
                            ,pr_cdagenci   => pr_cdagenci    --> Código da agência
                            ,pr_nrdcaixa   => pr_nrdcaixa    --> Número do caixa
                            ,pr_cdoperad   => pr_cdoperad    --> Código do operador
                            ,pr_rw_crapdat => rw_crapdat     --> Vetor com dados de parâmetro (CRAPDAT)
                            ,pr_nrdconta   => pr_nrdconta    --> Conta do associado
                            ,pr_tpctrrat   => pr_tpctrrat    --> Tipo do Rating
                            ,pr_nrctrrat   => pr_nrctrrat    --> Número do contrato de Rating
                            ,pr_flgefeti   => 'S'            --> Flag para efetivação ou não do Rating
                            ,pr_idseqttl   => pr_idseqttl    --> Sequencia de titularidade da conta
                            ,pr_idorigem   => pr_idorigem    --> Indicador da origem da chamada
                            ,pr_inusatab   => vr_inusatab    --> Indicador de utilização da tabela de juros
                            ,pr_nmdatela   => pr_nmdatela    --> Nome datela conectada
                            ,pr_flgerlog   => vr_flgerlog    --> Gerar log S/N
                            ,pr_des_reto   => vr_des_erro    --> Retorno OK / NOK
                            ,pr_tab_erro   => vr_tab_erro);  --> Tabela com possíves erros

          -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
          GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'RATI0001.pc_verifica_contrato_rating');

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
                                ,pr_dsvalite IN VARCHAR2
                                ,pr_tab_crapras IN OUT typ_tab_crapras
                                ,pr_dscritic OUT VARCHAR2) IS           --Descricao do erro

  /* ..........................................................................

     Programa: pc_grava_item_rating         Antigo: b1wgen0043.p/grava_item_rating
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Odirlei Busana - AMcom
     Data    :Aagosto/2014.                          Ultima Atualizacao: 28/06/2017

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  : Gravar itens do rating na crapras quando for efetivada a proposta ou em
                 temp temp-table quando for somente criada uma proposta.

     Alteracoes: 27/08/2014 - Conversão Progress -> Oracle - Odirlei (AMcom)

                 28/06/2017 - Inclusão para setar o modulo de todas procedures da Package
                             ( Belli - Envolti - 28/06/2017 - Chamado 660306).

  ............................................................................. */
  --------------- VARIAVEIS ----------------
    -- Descrição da critica
    vr_cdcritic crapcri.cdcritic%type;
    vr_dscritic VARCHAR2(4000);
    -- Exceção de saída
    vr_exc_erro EXCEPTION;
    --indice temptable
    vr_index VARCHAR2(50);

  BEGIN

    -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_grava_item_rating');

    /* Criar Rating proposto */
    IF pr_flgcriar = 1 THEN  /* Criar Rating proposto */
      BEGIN
        /* Atualizacao Rating */
        UPDATE crapras
           SET crapras.nrseqite = pr_nrseqite
             , crapras.dsvalite = pr_dsvalite
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
                      tpctrrat,
                      dsvalite)
               VALUES(pr_nrdconta,  --nrdconta,
                      pr_nrtopico,  --nrtopico,
                      pr_nritetop,  --nritetop,
                      pr_nrseqite,  --nrseqite,
                      pr_cdcooper,  --cdcooper,
                      pr_nrctrato,  --nrctrrat,
                      pr_tpctrato,  --tpctrrat
                      pr_dsvalite); --dsvalite
        END IF;
      EXCEPTION
        -- tratar erros
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - 29/06/2018 - Chamado 660306
          CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
          vr_dscritic := 'Não foi possivel gravar item rating (nrdconta='||pr_nrdconta||
                         ' nrctrrat='||pr_nrctrato||'): '||SQLerrm;
         raise vr_exc_erro;
      END;
    ELSE
      -- caso não grave deve gerar temptable
      -- definir indice
      if nvl(vr_flghisto,1) = 1 then
        pc_grava_his_crapras(pr_cdcooper => pr_cdcooper
                           , pr_nrdconta => pr_nrdconta
                           , pr_nrctrrat => pr_nrctrato
                           , pr_tpctrrat => pr_tpctrato
                           , pr_nrtopico => pr_nrtopico
                           , pr_nritetop => pr_nritetop
                           , pr_nrseqite => pr_nrseqite
                           , pr_dsvalite => pr_dsvalite
                           , pr_cdcritic => vr_cdcritic
                           , pr_dscritic => vr_dscritic);
      end if;
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
      -- No caso de erro de programa gravar tabela especifica de log - 29/06/2018 - Chamado 660306
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
      pr_dscritic := 'Erro na pc_grava_item_rating: '||SQLErrm;
  END pc_grava_item_rating;

  /* Valor da operacao do Rating */
  FUNCTION fn_valor_operacao(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                            ,pr_nrdconta IN crapass.nrdconta%TYPE --> Conta do associado
                            ,pr_tpctrato IN crapnrc.tpctrrat%TYPE --> Tipo do Rating
                            ,pr_nrctrato IN crapnrc.nrctrrat%TYPE --> Número do contrato de Rating
                            ) RETURN NUMBER IS
  /* ..........................................................................

       Programa: fn_valor_operacao         Antigo: b1wgen0043 --> valor-operacao
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Marcos Ernani Martini
       Data    : Agosto/2014.                          Ultima Atualizacao: 28/06/2017

       Dados referentes ao programa:

       Frequencia: Sempre que chamado por outros programas.
       Objetivo  :  Valor da operacao do Rating

       Alteracoes: 27/08/2014 - Conversão Progress -> Oracle - Marcos (Supero)

                   10/05/2016 - Ajuste para utitlizar rowtype locais
                                (Andrei  - RKAM).

                   28/06/2017 - Inclusão para setar o modulo de todas procedures da Package
                                ( Belli - Envolti - 28/06/2017 - Chamado 660306).
    ............................................................................. */

  BEGIN
    DECLARE
      -- Valor para retorno
      vr_vloperac NUMBER := 0;

      rw_crawepr2 cr_crawepr%ROWTYPE;
      rw_crapprp1 cr_crapprp%ROWTYPE;
      rw_craplim1 cr_craplim%ROWTYPE;

    BEGIN

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.fn_valor_operacao');

      -- Para empréstimos
      IF pr_tpctrato = 90 THEN
        -- Testar se existe informação complementar do empréstimo
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
          -- Testar se existe a informação da proposta do empréstimo
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
      ELSIF pr_tpctrato = 3 THEN
            rw_craplim1 := null;
            OPEN  cr_crawlim(pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_tpctrato => pr_tpctrato
                            ,pr_nrctrato => pr_nrctrato);
            FETCH cr_crawlim INTO rw_craplim1;
            IF    cr_crawlim%NOTFOUND THEN
                  CLOSE cr_crawlim;
                  OPEN  cr_craplim(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_tpctrato => pr_tpctrato
                                  ,pr_nrctrato => pr_nrctrato);
                  FETCH cr_craplim INTO rw_craplim1;
                  CLOSE cr_craplim;

                  vr_vloperac := rw_craplim1.vllimite;
      ELSE
                  CLOSE cr_crawlim;

                  vr_vloperac := rw_craplim1.vllimite;
            END   IF;
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
                                ,pr_cdagenci   IN crapass.cdagenci%TYPE --> Código da agência
                                ,pr_nrdconta   IN crapass.nrdconta%TYPE --> Conta do associado
                                ,pr_nrregist   IN INTEGER               --> Número de registros
                                ,pr_nriniseq   IN INTEGER               --> Número sequencial
                                ,pr_dtinirat   IN DATE                  --> Data de início do Rating
                                ,pr_dtfinrat   IN DATE                  --> Data de termino do Rating
                                ,pr_insitrat   IN PLS_INTEGER           --> Situação do Rating
                                ,pr_qtregist   OUT INTEGER              --> Quantidade de registros encontrados
                                ,pr_tab_ratings OUT RATI0001.typ_tab_ratings    --> Registro com os ratings do associado
                                ,pr_des_reto    OUT VARCHAR2) IS                --> Indicador erro
  BEGIN
    /* ..........................................................................

       Programa: pc_ratings_cooperado         Antigo: b1wgen0043 --> ratings_cooperado
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Marcos Ernani Martini
       Data    : Agosto/2014.                          Ultima Atualizacao: 28/06/2017

       Dados referentes ao programa:

       Frequencia: Sempre que chamado por outros programas.
       Objetivo  : Procedure que traz todas as informacoes de todos os ratings do cooperado.
                   Usada na ATURAT e na hora de alteracao dos ratings

       Alteracoes: 27/08/2014 - Conversão Progress -> Oracle - Marcos (Supero)

                 10/05/2016 - Ajuste para inserir controle de paginação devido a conversão da
                        tela ATURAT
                                (Andrei - RKAM).

                   28/06/2017 - Inclusão para setar o modulo de todas procedures da Package
                               ( Belli - Envolti - 28/06/2017 - Chamado 660306).

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
           -- OS testes abaixo garantem que se não foi enviado nada
           -- no parametro ou zero, usar o próprio valor do campo
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

      -- Busca dos ratings com BNDES
      CURSOR cr_crapnrc_crapebn IS
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
           -- OS testes abaixo garantem que se não foi enviado nada
           -- no parametro ou zero, usar o próprio valor do campo
           -- na tabela, ou seja, sempre trazer
           AND nrc.nrdconta = DECODE(nvl(pr_nrdconta,0),0,nrc.nrdconta,pr_nrdconta)
           AND nrc.insitrat = DECODE(nvl(pr_insitrat,0),0,nrc.insitrat,pr_insitrat)
           AND ass.cdagenci = DECODE(nvl(pr_cdagenci,0),0,ass.cdagenci,pr_cdagenci)
           AND nrc.dtmvtolt >= NVL(pr_dtinirat,nrc.dtmvtolt)
           AND nrc.dtmvtolt <= NVL(pr_dtfinrat,nrc.dtmvtolt)
           AND (EXISTS (SELECT 1
                        FROM crapebn b
                        WHERE b.cdcooper = nrc.cdcooper
                          AND b.nrdconta = nrc.nrdconta
                          AND b.nrctremp = nrc.nrctrrat))
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

      -- Valor da operação
      vr_vloperac NUMBER;
      -- Indice para a pltable
      vr_indratng PLS_INTEGER;

    --Variaveis locais
      vr_nrregist  INTEGER;
      vr_qtregist  INTEGER := 0;

      vr_habrat VARCHAR2(1) := 'N'; -- P450 - Paramentro para Habilitar Novo Ratin (S/N)

    BEGIN

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_ratings_cooperado');

      vr_nrregist := pr_nrregist;

      vr_habrat := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                             pr_cdcooper => pr_cdcooper,
                                             pr_cdacesso => 'HABILITA_RATING_NOVO');

      -- Efetuar laço para retornar todos os registros
      IF (pr_cdcooper = 3 OR vr_habrat = 'N') THEN
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

            -- O valor só será enviado em caso de diferente de zero
            IF vr_vloperac <> 0 THEN
              pr_tab_ratings(vr_indratng).vloperac := vr_vloperac;
            END IF;

            -- Buscar a descrição da operação
            pr_tab_ratings(vr_indratng).dsdopera := fn_busca_descricao_operacao(pr_tpctrrat => rw_crapnrc.tpctrrat);

            -- Buscar a descrição da situação
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
      ELSE
        FOR rw_crapnrc_crapebn IN cr_crapnrc_crapebn LOOP

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
                                            ,pr_nrdconta => rw_crapnrc_crapebn.nrdconta
                                            ,pr_tpctrato => rw_crapnrc_crapebn.tpctrrat
                                            ,pr_nrctrato => rw_crapnrc_crapebn.nrctrrat);
            -- Enfim, criar o registro do Rating
            vr_indratng := pr_tab_ratings.count()+1;
            pr_tab_ratings(vr_indratng).cdagenci := rw_crapnrc_crapebn.cdagenci;
            pr_tab_ratings(vr_indratng).nrdconta := rw_crapnrc_crapebn.nrdconta;
            pr_tab_ratings(vr_indratng).nmprimtl := rw_crapnrc_crapebn.nmprimtl;
            pr_tab_ratings(vr_indratng).nrctrrat := rw_crapnrc_crapebn.nrctrrat;
            pr_tab_ratings(vr_indratng).tpctrrat := rw_crapnrc_crapebn.tpctrrat;
            pr_tab_ratings(vr_indratng).indrisco := rw_crapnrc_crapebn.indrisco;
            pr_tab_ratings(vr_indratng).dtmvtolt := rw_crapnrc_crapebn.dtmvtolt;
            pr_tab_ratings(vr_indratng).dteftrat := rw_crapnrc_crapebn.dteftrat;
            pr_tab_ratings(vr_indratng).cdoperad := rw_crapnrc_crapebn.cdoperad;
            pr_tab_ratings(vr_indratng).insitrat := rw_crapnrc_crapebn.insitrat;
            pr_tab_ratings(vr_indratng).nrnotrat := rw_crapnrc_crapebn.nrnotrat;
            pr_tab_ratings(vr_indratng).nrnotatl := rw_crapnrc_crapebn.nrnotatl;
            pr_tab_ratings(vr_indratng).inrisctl := rw_crapnrc_crapebn.inrisctl;
            pr_tab_ratings(vr_indratng).vlutlrat := rw_crapnrc_crapebn.vlutlrat;
            pr_tab_ratings(vr_indratng).flgorige := rw_crapnrc_crapebn.flgorige;

            -- O valor só será enviado em caso de diferente de zero
            IF vr_vloperac <> 0 THEN
               pr_tab_ratings(vr_indratng).vloperac := vr_vloperac;
            END IF;

            -- Buscar a descrição da operação
            pr_tab_ratings(vr_indratng).dsdopera := fn_busca_descricao_operacao(pr_tpctrrat => rw_crapnrc_crapebn.tpctrrat);

            -- Buscar a descrição da situação
            pr_tab_ratings(vr_indratng).dsditrat := fn_busca_descricao_situacao(pr_insitrat => rw_crapnrc_crapebn.insitrat);

            OPEN cr_crapope(pr_cdcooper => pr_cdcooper
                           ,pr_cdoperad => rw_crapnrc_crapebn.cdoperad);

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
      END IF;

      pr_qtregist := vr_qtregist;

      -- Retorno OK
      pr_des_reto := 'OK';

    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 29/06/2018 - Chamado 660306
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
        -- Retorno não OK
        pr_des_reto := 'NOK';
    END;
  END pc_ratings_cooperado;

  /* Procedure para verificar se é possível efetivar o Rating */
  PROCEDURE pc_verifica_efetivacao(pr_cdcooper   IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                  ,pr_cdagenci   IN crapass.cdagenci%TYPE --> Código da agência
                                  ,pr_nrdcaixa   IN craperr.nrdcaixa%TYPE --> Número do caixa
                                  ,pr_nrdconta   IN crapass.nrdconta%TYPE --> Conta do associado
                                  ,pr_nrnotrat   IN crapnrc.nrnotrat%TYPE --> Nota atingida na soma dos itens do rating.
                                  ,pr_vlutiliz   IN NUMBER                --> Valor utilizado para gravação
                                  ,pr_flgefeti  OUT pls_integer           --> Flag do resultado da efetivação do Rating
                                  ,pr_tab_erro  OUT GENE0001.typ_tab_erro --> Tabela de retorno de erro
                                  ,pr_des_reto  OUT VARCHAR2) IS          --> Indicador erro
  BEGIN
    /* ..........................................................................

       Programa: pc_verifica_efetivacao         Antigo: b1wgen0043 --> verifica_efetivacao
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Marcos Ernani Martini
       Data    : Agosto/2014.                          Ultima Atualizacao: 28/06/2017

       Dados referentes ao programa:

       Frequencia: Sempre que chamado por outros programas.
       Objetivo  : Verificar se o Rating deve ser ativado.

       Alteracoes: 27/08/2014 - Conversão Progress -> Oracle - Marcos (Supero)

                   28/06/2017 - Inclusão para setar o modulo de todas procedures da Package
                                ( Belli - Envolti - 28/06/2017 - Chamado 660306).

    ............................................................................. */
    DECLARE
      -- Tratamento de erros
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      vr_exc_erro EXCEPTION;
      -- Variaveis auxiliares ao calculo
      vr_vlrating NUMBER; -- Valor parametrizado de rating
      vr_vlmaxleg NUMBER; -- Valor máximo legal
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

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_verifica_efetivacao');

      -- Default da efetivação é nao
      pr_flgefeti := 0;
      -- Retornar valor de parametrização do rating cadastrado na TAB036
      pc_param_valor_rating(pr_cdcooper => pr_cdcooper --> Código da Cooperativa
                           ,pr_vlrating => vr_vlrating --> Valor parametrizado
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic);

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_verifica_efetivacao');

      -- Se houve erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        -- Encerrar o processo
        RAISE vr_exc_erro;
      END IF;
      -- Buscar valor maximo legal cadastrado pela CADCOP
      pc_valor_maximo_legal(pr_cdcooper => pr_cdcooper --> Código da Cooperativa
                           ,pr_vlmaxleg => vr_vlmaxleg --> Valor parametrizado
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic);

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_verifica_efetivacao');

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
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
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
        -- No caso de erro de programa gravar tabela especifica de log - 29/06/2018 - Chamado 660306
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Montar descrição de erro não tratado
        vr_dscritic := 'Erro não tratado na RATI0001.pc_verifica_efetivacao> '||sqlerrm;
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
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
                              ,pr_nrctrato   IN crapnrc.nrctrrat%TYPE --> Número do contrato de Rating
                              ,pr_cdoperad   IN crapnrc.cdoperad%TYPE --> Código do operador
                              ,pr_dtmvtolt   IN crapdat.dtmvtolt%TYPE --> Data do movimento atual
                              ,pr_vlutiliz   IN NUMBER                --> Valor utilizado para gravação
                              ,pr_flgatual   IN BOOLEAN               --> Flag para efetuar ou não a atualização
                              ,pr_tab_efetivacao OUT RATI0001.typ_tab_efetivacao --> Registro de efetivação
                              ,pr_tab_ratings    OUT RATI0001.typ_tab_ratings    --> Registro com os ratings do associado
                              ,pr_tab_erro       OUT gene0001.typ_tab_erro       --> Tabela de retorno de erro
                              ,pr_des_reto       OUT VARCHAR2) IS                --> Indicador erro
  BEGIN
    /* ..........................................................................

       Programa: pc_efetivar_rating         Antigo: b1wgen0043 --> efetivar_rating
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Marcos Ernani Martini
       Data    : Agosto/2014.                          Ultima Atualizacao: 28/06/2017

       Dados referentes ao programa:

       Frequencia: Sempre que chamado por outros programas.
       Objetivo  : Efetivar o Rating do Cooperado

       Alteracoes: 27/08/2014 - Conversão Progress -> Oracle - Marcos (Supero)

           10/05/2016 - Ajuste para enviar novos parametros a rotina que efetua
                a busca dos ratings do cooperado
                (Andrei - RKAM).

                   28/06/2017 - Inclusão para setar o modulo de todas procedures da Package
                                ( Belli - Envolti - 28/06/2017 - Chamado 660306).

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
      vr_dsoperac VARCHAR2(100);         -- Descrição da operação do pior rating
    vr_qtregist INTEGER;
    BEGIN

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_efetivar_rating');

      -- Se tiver um Rating efetivo, mudar para proposto
      pc_muda_situacao_proposto(pr_cdcooper => pr_cdcooper --> Código da Cooperativa
                               ,pr_nrdconta => pr_nrdconta --> Conta do associado
                               ,pr_dtmvtolt => pr_dtmvtolt --> Data atual
                               ,pr_vlutiliz => pr_vlutiliz --> Valor para lançamento
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_efetivar_rating');

      -- Se houve erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        -- Encerrar o processo
        RAISE vr_exc_erro;
      END IF;
      -- Procurar o Rating Proposto com pior nota.
      pc_procura_pior_nota(pr_cdcooper => pr_cdcooper --> Código da Cooperativa
                          ,pr_nrdconta => pr_nrdconta --> Conta do associado
                          ,pr_indrisco => vr_indrisco --> Risco do pior rating
                          ,pr_rowidnrc => vr_rowidnrc --> Rowid do pior rating
                          ,pr_nrctrrat => vr_nrctrrat --> Número do contrato do pior rating
                          ,pr_dsoperac => vr_dsoperac --> Descrição da operação do rating
                          ,pr_cdcritic => vr_cdcritic
                          ,pr_dscritic => vr_dscritic);

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_efetivar_rating');

      -- Não era tratado retorno de erro no Progress
      ---- Se houve erro
      --IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --  -- Encerrar o processo
      --  RAISE vr_exc_erro;
      --END IF;
      -- Efetivar o rating de pior nota
      pc_muda_situacao_efetivo(pr_rowidnrc => vr_rowidnrc --> Rowid para gravação do rating
                              ,pr_cdoperad => pr_cdoperad --> Código do operador
                              ,pr_dtmvtolt => pr_dtmvtolt --> Data atual
                              ,pr_vlutiliz => pr_vlutiliz --> Valor para lançamento
                              ,pr_flgatual => pr_flgatual --> Não atualizar
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_efetivar_rating');

      -- Se houve erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        -- Encerrar o processo
        RAISE vr_exc_erro;
      END IF;

      -- Retornar os Ratings do Cooperado
      pc_ratings_cooperado(pr_cdcooper    => pr_cdcooper    --> Cooperativa conectada
                          ,pr_cdagenci    => 0              --> Código da agência
                          ,pr_nrdconta    => pr_nrdconta    --> Conta do associado
                          ,pr_nrregist    => 999999         --> Número de registros
                          ,pr_nriniseq    => 1              --> Número sequencial
                          ,pr_dtinirat    => null           --> Data de início do Rating
                          ,pr_dtfinrat    => null           --> Data de termino do Rating
                          ,pr_insitrat    => 0              --> Situação do Rating
                          ,pr_qtregist    => vr_qtregist    --> Quantidade de registros encontrados
                          ,pr_tab_ratings => pr_tab_ratings --> Registro com os ratings do associado
                          ,pr_des_reto    => pr_des_reto);

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_efetivar_rating');

      -- Quando esta voltando atras operacao
      IF pr_tpctrato = 0 AND pr_nrctrato = 0 THEN
        -- Grava como origem aquele q estiver sendo efetivado
        pc_grava_rating_origem(pr_cdcooper => pr_cdcooper   --> Código da Cooperativa
                              ,pr_nrdconta => pr_nrdconta   --> Conta do associado
                              ,pr_rowidnrc => vr_rowidnrc   --> Rowid para gravação do rating
                              ,pr_cdcritic => vr_cdcritic   --> Critica encontrada no processo
                              ,pr_dscritic => vr_dscritic); --> Descritivo do erro

        -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_efetivar_rating');

      ELSE
        -- Senao grava aquele que realmente originou o efetivo
        pc_grava_rating_origem(pr_cdcooper => pr_cdcooper   --> Código da Cooperativa
                              ,pr_nrdconta => pr_nrdconta   --> Conta do associado
                              ,pr_rowidnrc => null          --> Rowid para gravação do rating
                              ,pr_cdcritic => vr_cdcritic   --> Critica encontrada no processo
                              ,pr_dscritic => vr_dscritic); --> Descritivo do erro

        -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_efetivar_rating');

      END IF;
      --------------------------------------------------------------------
      ----- Não versão progress não testava se retornou erro aqui...  ----
      --------------------------------------------------------------------
      -- Se encontrou erro
      --IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
      --  -- Gerar o erro
      --  RAISE vr_exc_erro;
      --END IF;

      -- Criar o registro de efetivação
      pr_tab_efetivacao(1).idseqmen := 1;
      pr_tab_efetivacao(1).dsdefeti := 'Efetivado para a Central de Risco o risco ' || vr_indrisco
                                              || ' do contrato ' || to_char(vr_nrctrrat) ||'.';

      -- Efetuar loop para busca o Rating Efetivo
      FOR vr_indratng IN pr_tab_ratings.FIRST..pr_tab_ratings.LAST LOOP
        -- Assim que encontrar o rating efetivo
        IF pr_tab_ratings(vr_indratng).insitrat = 2 THEN
          -- Retornar valor da operação
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
          -- Sair do loop pois só precisamos do efetivado
          EXIT;
        END IF;
      END LOOP;

      -- Retorno OK
      pr_des_reto := 'OK';
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
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
        -- No caso de erro de programa gravar tabela especifica de log - 29/06/2018 - Chamado 660306
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Montar descrição de erro não tratado
        vr_dscritic := 'Erro não tratado na RATI0001.pc_efetivar_rating > '||sqlerrm;
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
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
                                     ,pr_tab_provisao       IN typ_tab_provisao      --> Tabela com informações da craptab cfme opção
                                     ,pr_tab_impress_risco OUT RATI0001.typ_tab_impress_risco --> Registro Nota e risco do cooperado no Rating solicitado
                                     ,pr_des_reto          OUT VARCHAR2) IS          --> Indicador erro IS
  BEGIN
    /* ..........................................................................

       Programa: pc_descricoes_risco_busca         Antigo: b1wgen0043 --> descricoes_risco
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Marcos Ernani Martini
       Data    : Agosto/2014.                          Ultima Atualizacao: 28/06/2017

       Dados referentes ao programa:

       Frequencia: Sempre que chamado por outros programas.
       Objetivo  : Obter as descricoes do risco, provisao , etc ...

       Alteracoes: 28/08/2014 - Conversão Progress -> Oracle - Marcos (Supero)

                   28/06/2017 - Inclusão para setar o modulo de todas procedures da Package
                                ( Belli - Envolti - 28/06/2017 - Chamado 660306).

    ............................................................................. */
    DECLARE
      -- Contador para as informações da tabela de provisões
      vr_contador number;
      -- Indice para gravação na tabela de impressao dos riscos
      vr_indimpri number;
    BEGIN

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_descricoes_risco_busca');

      -- Efetuar LOOP sob a temp-table com os riscos
      vr_contador := pr_tab_provisao.first;
      LOOP
        -- Sair quando não existir o registro na tabela
        EXIT WHEN vr_contador IS NULL;
        -- Testar valores para pessoa fisica ou Juridica
        -- Ou se o nivel passado é igual ao contador
        IF (pr_inpessoa = 1 AND pr_nrnoveri >= pr_tab_provisao(vr_contador).notadefi AND pr_nrnoveri <= pr_tab_provisao(vr_contador).notatefi)
        OR (pr_inpessoa > 1 AND pr_nrnoveri >= pr_tab_provisao(vr_contador).notadeju AND pr_nrnoveri <= pr_tab_provisao(vr_contador).notateju)
        OR (pr_nivrisco <> 0 AND pr_nivrisco = vr_contador) THEN
          -- Criar novo registro de impressão nesta faixa de risco
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
        -- Buscar o próximo risco
        vr_contador := pr_tab_provisao.next(vr_contador);
      END LOOP;
      -- Retorno OK
      pr_des_reto := 'OK';
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 29/06/2018 - Chamado 660306
        CECRED.pc_internal_exception (pr_cdcooper => NULL);
        -- Retorno não OK
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
       Data    : Agosto/2014.                          Ultima Atualizacao: 28/06/2017

       Dados referentes ao programa:

       Frequencia: Sempre que chamado por outros programas.
       Objetivo  : Direcionar a obtenção as descricoes do risco, provisao , etc ...

       Alteracoes: 28/08/2014 - Conversão Progress -> Oracle - Marcos (Supero)

                   25/10/2016 - Correção do problema relatado no chamado 541414. (Kelvin)

                   28/06/2017 - Inclusão para setar o modulo de todas procedures da Package
                                ( Belli - Envolti - 28/06/2017 - Chamado 660306).

    ............................................................................. */
    DECLARE
    /* Cursor genérico de parametrização */
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

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_descricoes_risco');

      -- Se ainda não foram carregadas as informações na tabela de memória de provisao risco
      IF vr_tab_provisao_cl.count() = 0 THEN
        -- Busca de todos os riscos conforme chave de acesso enviada
        FOR rw_craptab IN cr_craptab(pr_nmsistem => 'CRED'
                                    ,pr_tptabela => 'GENERI'
                                    ,pr_cdempres => '00'
                                    ,pr_cdacesso => 'PROVISAOCL'
                                    ,pr_tpregist => null) LOOP
          -- Carregar na tabela
          vr_contador := gene0002.fn_char_para_number(SUBSTR(rw_craptab.dstextab,12,2));
          vr_tab_provisao_cl(vr_contador).dsdrisco := TRIM(SUBSTR(rw_craptab.dstextab,8,3));
          vr_tab_provisao_cl(vr_contador).percentu := gene0002.fn_char_para_number(SUBSTR(rw_craptab.dstextab,1,6));
          vr_tab_provisao_cl(vr_contador).notadefi := gene0002.fn_char_para_number(SUBSTR(rw_craptab.dstextab,27,6));
          vr_tab_provisao_cl(vr_contador).notatefi := gene0002.fn_char_para_number(SUBSTR(rw_craptab.dstextab,34,6));
          vr_tab_provisao_cl(vr_contador).parecefi := SUBSTR(rw_craptab.dstextab,41,15);
          vr_tab_provisao_cl(vr_contador).notadeju := gene0002.fn_char_para_number(SUBSTR(rw_craptab.dstextab,56,6));
          vr_tab_provisao_cl(vr_contador).notateju := gene0002.fn_char_para_number(SUBSTR(rw_craptab.dstextab,62,6));
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

      -- Se ainda não foram carregadas as informações na tabela de memória de provisao rating
      IF vr_tab_provisao_tl.count() = 0 THEN
        -- Busca de todos os riscos conforme chave de acesso enviada
        FOR rw_craptab IN cr_craptab(pr_nmsistem => 'CRED'
                                    ,pr_tptabela => 'GENERI'
                                    ,pr_cdempres => '00'
                                    ,pr_cdacesso => 'PROVISAOTL'
                                    ,pr_tpregist => null) LOOP
          -- Carregar na tabela
          vr_contador := gene0002.fn_char_para_number(SUBSTR(rw_craptab.dstextab,12,2));
          vr_tab_provisao_tl(vr_contador).dsdrisco := TRIM(SUBSTR(rw_craptab.dstextab,8,3));
          vr_tab_provisao_tl(vr_contador).percentu := gene0002.fn_char_para_number(SUBSTR(rw_craptab.dstextab,1,6));
          vr_tab_provisao_tl(vr_contador).notadefi := gene0002.fn_char_para_number(SUBSTR(rw_craptab.dstextab,27,6));
          vr_tab_provisao_tl(vr_contador).notatefi := gene0002.fn_char_para_number(SUBSTR(rw_craptab.dstextab,34,6));
          vr_tab_provisao_tl(vr_contador).parecefi := SUBSTR(rw_craptab.dstextab,41,15);
          vr_tab_provisao_tl(vr_contador).notadeju := gene0002.fn_char_para_number(SUBSTR(rw_craptab.dstextab,56,6));
          vr_tab_provisao_tl(vr_contador).notateju := gene0002.fn_char_para_number(SUBSTR(rw_craptab.dstextab,62,6));
          vr_tab_provisao_tl(vr_contador).pareceju := SUBSTR(rw_craptab.dstextab,70,15);

      IF vr_tab_provisao_tl(vr_contador).dsdrisco = 'A' THEN
            vr_percentu_temp := vr_tab_provisao_tl(vr_contador).percentu;
          END IF;
          IF vr_tab_provisao_tl(vr_contador).dsdrisco = 'AA' THEN
            vr_tab_provisao_tl(vr_contador).percentu := vr_percentu_temp;
          END IF;

        END LOOP; --> Para cada risco
      END IF;

      -- Chamar rotina genérica para gravação das informações da PROVISAOCL (Baseada no Risco)
      pc_descricoes_risco_busca(pr_inpessoa    => pr_inpessoa --> Tipo de pessoa
                               ,pr_nrnoveri    => pr_nrnotrat --> Valor a verificar
                               ,pr_nivrisco    => pr_nivrisco --> Nivel do Risco
                               ,pr_tab_provisao      => vr_tab_provisao_cl --> Tabela com informações da tab para esta opção
                               ,pr_tab_impress_risco => pr_tab_impress_risco_cl --> Registro Nota e risco do cooperado no Rating solicitado
                               ,pr_des_reto          => pr_des_reto);

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_descricoes_risco');

      -- Chamar rotina genérica para gravação das informações da PROVISAOTL (Baseada no Rating)
      pc_descricoes_risco_busca(pr_inpessoa    => pr_inpessoa --> Tipo de pessoa
                               ,pr_nrnoveri    => pr_nrnotatl --> Valor a verificar
                               ,pr_nivrisco    => pr_nivrisco --> Nivel do Risco
                               ,pr_tab_provisao      => vr_tab_provisao_tl --> Tabela com informações da tab para esta opção
                               ,pr_tab_impress_risco => pr_tab_impress_risco_tl --> Registro Nota e risco do cooperado no Rating solicitado
                               ,pr_des_reto          => pr_des_reto);

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_descricoes_risco');

      -- Retorno OK
      pr_des_reto := 'OK';
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 29/06/2018 - Chamado 660306
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
        -- Retorno não OK
        pr_des_reto := 'NOK';
    END;
  END pc_descricoes_risco;

  /* Ler o rating do associado e gerar o arquivo correnpondente  */
  PROCEDURE pc_gera_arq_impress_rating(pr_cdcooper    IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                      ,pr_cdagenci    IN crapass.cdagenci%TYPE --> Código da agência
                                      ,pr_nrdcaixa    IN craperr.nrdcaixa%TYPE --> Número do caixa
                                      ,pr_cdoperad    IN crapnrc.cdoperad%TYPE --> Código do operador
                                      ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE --> Data do movimento atual
                                      ,pr_nrdconta    IN crapass.nrdconta%TYPE --> Conta do associado
                                      ,pr_tpctrato    IN crapnrc.tpctrrat%TYPE --> Tipo do Rating
                                      ,pr_nrctrato    IN crapnrc.nrctrrat%TYPE --> Número do contrato de Rating
                                      ,pr_flgcriar    IN pls_integer           --> Flag para criação ou não do arquivo
                                      ,pr_flgcalcu    IN pls_integer           --> Flag para calculo ou não
                                      ,pr_idseqttl    IN crapttl.idseqttl%TYPE --> Sq do titular da conta
                                      ,pr_idorigem    IN pls_integer           --> Indicador da origem da chamada
                                      ,pr_nmdatela    IN craptel.nmdatela%TYPE --> Nome da tela conectada
                                      ,pr_flgerlog    IN VARCHAR2              --> Gerar log S/N
                                      ,pr_tab_crapras IN typ_tab_crapras       --> Interna da BO, para o calculo do Rating
                                      ,pr_tab_impress_coop     OUT RATI0001.typ_tab_impress_coop     --> Registro impressão da Cooperado
                                      ,pr_tab_impress_rating   OUT RATI0001.typ_tab_impress_rating   --> Registro itens do Rating
                                      ,pr_tab_impress_risco_cl OUT RATI0001.typ_tab_impress_risco    --> Registro Nota e risco do cooperado naquele Rating - PROVISAOCL
                                      ,pr_tab_impress_risco_tl OUT RATI0001.typ_tab_impress_risco    --> Registro Nota e risco do cooperado naquele Rating - PROVISAOTL
                                      ,pr_tab_impress_assina   OUT RATI0001.typ_tab_impress_assina   --> Assinatura na impressao do Rating
                                      ,pr_tab_efetivacao       OUT RATI0001.typ_tab_efetivacao       --> Registro dos itens da efetivação
                                      ,pr_tab_erro             OUT gene0001.typ_tab_erro --> Tabela de retorno de erro
                                      ,pr_des_reto             OUT VARCHAR2) IS          --> Indicador erro IS
  BEGIN
    /* ..........................................................................

       Programa: pc_gera_arq_impress_rating         Antigo: b1wgen0043 --> gera-arquivo-impressao-rating
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Marcos Ernani Martini
       Data    : Agosto/2014.                          Ultima Atualizacao: 28/06/2017

       Dados referentes ao programa:

       Frequencia: Sempre que chamado por outros programas.
       Objetivo  : Ler o rating do associado e gerar o arquivo correnpondente

       Alteracoes: 28/08/2014 - Conversão Progress -> Oracle - Marcos (Supero)

           10/05/2016 - Ajuste decorrente a reestruturação das PL/TABLE
                (Andrei - RKAM).

                   28/06/2017 - Inclusão para setar o modulo de todas procedures da Package
                                ( Belli - Envolti - 28/06/2017 - Chamado 660306).
    ............................................................................. */
    DECLARE
      -- Tratamento de exceção
      vr_exc_erro exception;
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);

      -- Rowid para inserção de log
      vr_nrdrowid ROWID;
      -- Sequencia para a tab_impress_rating
      vr_sqtb_imprat PLS_INTEGER;
    vr_index_sub PLS_INTEGER;
      vr_index_itens PLS_INTEGER;
      -- Sequencia para a tab_efetivacao
      vr_sqtb_efetiv PLS_INTEGER;
      -- Flag para teste de existência da crapras
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

      -- Cursor para retornar topicos, itens e descrição de ratings
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

           FROM craprad rad --> Descrição do Rating
               ,craprai rai --> Itens do Rating
               ,craprat rat --> Topicos do Rating

         WHERE rad.cdcooper = rai.cdcooper
           AND rad.nrtopico = rai.nrtopico
           AND rad.nritetop = rai.nritetop

           AND rat.cdcooper = rai.cdcooper
           AND rat.nrtopico = rai.nrtopico

           AND rat.cdcooper = pr_cdcooper
           AND rat.flgativo = 1 --> Somente tópicos ativos
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
                 -- Ou traz o contratro dos parâmetros
                 (tpctrrat = pr_tpctrato AND nrctrrat = pr_nrctrato)
                );
      rw_crapnrc cr_crapnrc%ROWTYPE;

    BEGIN

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_gera_arq_impress_rating');

      -- Validar associado enviado
      OPEN cr_crapass(pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      IF cr_crapass%NOTFOUND THEN
        -- Fecha o cursor
        CLOSE cr_crapass;
        -- Monta critica
        vr_cdcritic := 9;
        vr_dscritic := NULL;
        -- Gera exceção
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
        -- Gera exceção
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
      -- Laço para retornar os Topicos do rating
      FOR rw_craprat IN cr_craprat(pr_inpessoa => rw_crapass.inpessoa) LOOP

        -- First-of rat.nrtopico
        IF rw_craprat.nrsqtopi = 1 THEN

          -- Criar registros do Tópico
          vr_sqtb_imprat := pr_tab_impress_rating.COUNT+1;
          pr_tab_impress_rating(vr_sqtb_imprat).intopico := rw_craprat.intopico;
          pr_tab_impress_rating(vr_sqtb_imprat).nrtopico := rw_craprat.nrtopico;
          pr_tab_impress_rating(vr_sqtb_imprat).dsitetop := rw_craprat.dstopico;

        END IF;

        -- First-of rai.nritetop
        IF rw_craprat.nrsqittp = 1 THEN

          -- Criar registros do Item do tópico
          vr_index_sub:= pr_tab_impress_rating(vr_sqtb_imprat).tab_subtopico.count + 1;
          pr_tab_impress_rating(vr_sqtb_imprat).tab_subtopico(vr_index_sub).nritetop := rw_craprat.nritetop;
          pr_tab_impress_rating(vr_sqtb_imprat).tab_subtopico(vr_index_sub).dsitetop := gene0002.fn_mask(rw_craprat.nrtopico,'z9')||'.'||gene0002.fn_mask(rw_craprat.nritetop,'z9')||' '||rw_craprat.dsitetop;
          pr_tab_impress_rating(vr_sqtb_imprat).tab_subtopico(vr_index_sub).dspesoit := to_char(rw_craprat.pesoitem,'990d00');

        END IF;

        -- Reiniciar teste de existência da crapras
        vr_flg_crapras := 'N';

        -- Se foi solicitada a criação OU ainda não foi calculado
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

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_gera_arq_impress_rating');

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
      --Se encontrou e é de origem
      IF cr_crapnrc%FOUND AND rw_crapnrc.flgorige = 1 THEN
        -- Fechar o cursor para nova busca
        CLOSE cr_crapnrc;
        -- Buscar o efetivo desta vez
        OPEN cr_crapnrc(pr_flefetivo => 'S');
        FETCH cr_crapnrc
         INTO rw_crapnrc;
        CLOSE cr_crapnrc;
        -- Criar o registro de efetivação
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

        -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_gera_arq_impress_rating');

      END IF;
      -- Retorno OK
      pr_des_reto := 'OK';
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
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
        -- No caso de erro de programa gravar tabela especifica de log - 29/06/2018 - Chamado 660306
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Montar descrição de erro não tratado
        vr_dscritic := 'Erro não tratado na RATI0001.pc_gera_arq_impress_rating > '||sqlerrm;
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
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
                                    ,pr_cdoperad     IN crapnrc.cdoperad%TYPE --> Código do operador
                                    ,pr_idseqttl     IN crapttl.idseqttl%TYPE --> Sq do titular da conta
                                    ,pr_idorigem     IN pls_integer           --> Indicador da origem da chamada
                                    ,pr_nrdconta     IN crapass.nrdconta%TYPE --> Conta do associado
                                    ,pr_tpctrato     IN crapnrc.tpctrrat%TYPE --> Tipo do Rating
                                    ,pr_nrctrato     IN crapnrc.nrctrrat%TYPE --> Número do contrato de Rating
                                    ,pr_vet_nrctrliq IN typ_vet_nrctrliq      --> Vetor de contratos a liquidar
                                    ,pr_vlpreemp     IN crapepr.vlpreemp%TYPE --> Valor da parcela
                                    ,pr_rw_crapdat   IN btch0001.cr_crapdat%rowtype --> Calendário do movimento atual
                                    ,pr_flgdcalc     IN PLS_INTEGER           --> Flag para calcular sim ou não
                                    ,pr_inusatab     IN BOOLEAN               --> Indicador de utilização da tabela de juros
                                    ,pr_vltotpre    OUT NUMBER                --> Valor calculado da prestação
                                    ,pr_dscritic    OUT VARCHAR2) IS          --> Descrição de erro
  BEGIN
    /* ..........................................................................

       Programa: pc_nivel_comprometimento         Antigo: b1wgen0043 --> nivel_comprometimento
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Marcos Ernani Martini
       Data    : Agosto/2014.                          Ultima Atualizacao: 28/06/2017

       Dados referentes ao programa:

       Frequencia: Sempre que chamado por outros programas.
       Objetivo  : Item 3_1 (Pessoa Fisica) e  5_2 (Pessoa juridica) do Rating

       Alteracoes: 29/08/2014 - Conversão Progress -> Oracle - Marcos (Supero)

                   19/01/2015 - Ajuste para nao verificar a data fim quando o
                                limite de credito for cheque especial. (James)

                   28/06/2017 - Inclusão para setar o modulo de todas procedures da Package
                                ( Belli - Envolti - 28/06/2017 - Chamado 660306).

    ............................................................................. */
    DECLARE
      -- Tratamento de possíveis erros
      vr_exc_erro exception;
      vr_tab_erro gene0001.typ_tab_erro;
      vr_des_reto VARCHAR2(10);
      -- Variaveis do retorno da pc_calc_saldo_epr
      vr_vlsdeved NUMBER(20,8) := 0;     --> Valor de saldo devedor
      vr_valorpre NUMBER := 0;           --> Auxiliar para soma de todas as parcelas que o usuário está liquidando
      vr_qtprecal NUMBER := 0;           --> Quantidade calculada das parcelas
      -- registro de datas
      rw_crapdat  btch0001.cr_crapdat%rowtype;

      -- Busca do total pendente dos empréstimos BNDES ativos na conta
      CURSOR cr_soma_crapebn IS
        SELECT nvl(sum(nvl(vlparepr,0)),0) vlparepr
          FROM crapebn
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND insitctr in('N','A')
           AND vlsdeved > 0;
      -- Busca do valor da parcela do empréstimo
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
           AND (   -- 3-Desc Tit - Verificar a data da vigência
                  (tpctrlim = 3 AND dtfimvig > pr_rw_crapdat.dtmvtolt)
                OR -- 2-Desc Chq.
                  (tpctrlim = 2)
                OR -- 1-Chq Esp
                  (tpctrlim = 1)
               );
      -- Verificação de existência do contrato atual
      CURSOR cr_craplim_atual IS
        SELECT vllimite
          FROM craplim
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND tpctrlim = pr_tpctrato
           AND nrctrlim = pr_nrctrato
        AND    insitlim    <> 2 --> Não Ativo
        AND    pr_tpctrato <> 3

        UNION  ALL

        SELECT vllimite
        FROM   crawlim
        WHERE  cdcooper    = pr_cdcooper
        AND    nrdconta    = pr_nrdconta
        AND    tpctrlim    = pr_tpctrato
        AND    nrctrlim    = pr_nrctrato
        AND    insitlim   <> 2 --> Não Ativo
        AND    pr_tpctrato = 3;

    BEGIN

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_nivel_comprometimento');

      -- Se emprestimo/ financiamento OU se foi solicitado o cálculo para outros casos
      IF pr_tpctrato = 90 OR pr_flgdcalc = 1 THEN
        -- Busca do total pendente dos empréstimos BNDES ativos na conta
        -- Obs:  BNDES - nao tera tratamento ref. liquidacao de contratos inicialmente
        OPEN cr_soma_crapebn;
        FETCH cr_soma_crapebn
         INTO vr_valorpre;
        CLOSE cr_soma_crapebn;
        -- Acumular
        pr_vltotpre := NVL(vr_valorpre,0);
        -- Solução de contorno para usar o mesmo comportamento progres, ou seja,
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
                                     ,pr_nrctremp => 0 -- Todos os empréstimos
                                     ,pr_cdprogra => ''
                                     ,pr_inusatab => pr_inusatab
                                     ,pr_flgerlog => 'N'
                                     ,pr_vlsdeved => vr_vlsdeved
                                     ,pr_vltotpre => vr_valorpre
                                     ,pr_qtprecal => vr_qtprecal
                                     ,pr_des_reto => vr_des_reto
                                     ,pr_tab_erro => vr_tab_erro);

        -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_nivel_comprometimento');

        -- Se retornou erro
        IF vr_des_reto <> 'OK' THEN
          -- Buscar da tabela de erro
          IF vr_tab_erro.count > 0 THEN
            pr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
          ELSE
            pr_dscritic := 'Erro na pck empr0001.';
          END IF;
          -- Gerar exceção
          RAISE vr_exc_erro;
        ELSE
          -- Acumular valor calculado
          pr_vltotpre := nvl(pr_vltotpre,0) + nvl(vr_valorpre,0);
        END IF;
      END IF;
      -- Regras específicas
      -- Se emprestimo/ financiamento
      IF pr_tpctrato = 90 THEN
        -- Reiniciar temporária
        vr_valorpre := 0;
        -- Somar todas as parcelas que esta liquidando
        FOR vr_contador IN 1..10 LOOP
          -- Se foi enviado
          IF pr_vet_nrctrliq(vr_contador) <> 0 THEN
            -- Somar valor da parcela do empréstimo
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
        -- Testa existência contrato EPR
        OPEN cr_crapepr(pr_nrctrato);
        FETCH cr_crapepr
         INTO vr_vlpreemp;
        -- Testa existência contrato BNDES
        OPEN cr_crapebn(pr_nrctrato);
        FETCH cr_crapebn
         INTO vr_vlpreemp;
        -- Se não existe nas duas tabelas
        IF cr_crapepr%NOTFOUND AND cr_crapebn%NOTFOUND THEN
          -- Se esta efetivando ele ja considera a parcela atual
          pr_vltotpre := pr_vltotpre + pr_vlpreemp;
        END IF;
        -- Senão, apenas fechar os cursores
        CLOSE cr_crapepr;
        CLOSE cr_crapebn;
      ELSE
        -- Contabilizar todos os descontos / cheque especial
        -- Obs: Somente se não foi solicitado o cálculo
        IF pr_flgdcalc = 0 THEN
          -- Sobre 12, para considerar como parcela
          OPEN cr_craplim;
          FETCH cr_craplim
           INTO vr_valorpre;
          CLOSE cr_craplim;
          -- Acumular
          pr_vltotpre := nvl(pr_vltotpre,0) + vr_valorpre;
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
        -- No caso de erro de programa gravar tabela especifica de log - 29/06/2018 - Chamado 660306
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
        -- Montar descrição de erro não tratado
        pr_dscritic := 'Erro não tratado na RATI0001.pc_nivel_comprometimento > '||sqlerrm;
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
     Data    : Agosto/2014.                          Ultima Atualizacao: 28/06/2017

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  :  Verifica o historico do cooperado referente a estouros.
                  Item 1_5 de pessoa fisica e 6_4 de pessoa juridica.

     Alteracoes: 29/08/2014 - Conversão Progress -> Oracle - Odirlei (AMcom)

                 06/08/2015 - Alterado procedimento pc_historico_cooperado para melhorias de performace
                              verificado se a conta possuia contrato de limite de credito no periodo,
                              caso nao tenha, nao precisa verificar dias que usa o limite de credito SD281898 (Odirlei-Amcom)

                   28/06/2017 - Inclusão para setar o modulo de todas procedures da Package
                                ( Belli - Envolti - 28/06/2017 - Chamado 660306).

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

    cursor cr_crapali(pr_dsalinea in crapali.dsalinea%type) is
      select c.cdalinea
        from crapali c
       where c.dsalinea = pr_dsalinea
         and c.cdalinea in (11,12);
    vr_cdalinea crapali.cdalinea%type;
  -------------- VARIAVEIS -----------------
    vr_tab_estouros risc0001.typ_tab_estouros;

    -- Descrição e código da critica
    vr_dscritic VARCHAR2(4000);
    -- Exceção de saída
    vr_exc_erro EXCEPTION;
    -- dia inicial de estorno
    vr_dtiniest DATE;
    -- contar dias
    vr_qtestour INTEGER := 0;
    vr_qtdiaatr INTEGER := 0;
    vr_qtdiaat2 INTEGER := 0;
    vr_qtdiasav INTEGER := 0;

  BEGIN

    -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_historico_cooperado');

    /* Obter as informaões de estouro do cooperado */
    RISC0001.pc_lista_estouros( pr_cdcooper      => pr_cdcooper     --> Codigo Cooperativa
                               ,pr_cdoperad      => pr_cdoperad      --> Operador conectado
                               ,pr_nrdconta      => pr_nrdconta     --> Numero da Conta
                               ,pr_idorigem      => pr_idorigem     --> Identificador Origem
                               ,pr_idseqttl      => pr_idseqttl     --> Sequencial do Titular
                               ,pr_nmdatela      => 'RATI0001'      --> Nome da tela
                               ,pr_dtmvtolt      => pr_dtmvtolt     --> Data do movimento
                               ,pr_tab_estouros  => vr_tab_estouros --> Informações de estouro na conta
                               ,pr_dscritic      => vr_dscritic);   --> Retorno de erro

    -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_historico_cooperado');

    -- verificar se retornou critica
    IF vr_dscritic is not null THEN
      raise vr_exc_erro;
    END IF;

    /* Data do inicio do estouro a partir de um ano atras */
    vr_dtiniest := add_months(pr_dtmvtolt, -12);
    rat_qtdevalo := 0;
    rat_qtdevald := 0;
    rat_qtchqesp := 0;

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
      FOR I IN vr_tab_estouros.FIRST..vr_tab_estouros.LAST LOOP
        IF vr_tab_estouros(I).dtiniest >= vr_dtiniest AND
           vr_tab_estouros(I).cdhisest  = 'Devolucao Chq.' THEN
          vr_cdalinea := 0;
          open cr_crapali(vr_tab_estouros(I).dsobserv);
          fetch cr_crapali into vr_cdalinea;
          close cr_crapali;
          if vr_cdalinea = 11 then
            rat_qtdevalo := rat_qtdevalo + 1;
          elsif vr_cdalinea = 12 then
            rat_qtdevald := rat_qtdevald + 1;
    END IF;
        END IF;
      END LOOP;
    END IF;

    -- Verificar se cooperado possui contrato de
    -- limite de credito no periodo
    OPEN cr_craplim( pr_cdcooper => pr_cdcooper,
                     pr_nrdconta => pr_nrdconta,
                     pr_dtiniest => vr_dtiniest);
    FETCH cr_craplim INTO rw_craplim;

    -- se não possuir contrato de limite de credito, não precisa
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
          rat_qtchqesp := rat_qtchqesp + 1;
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

    vr_dsvalite := vr_qtestour || ' est., ' || vr_qtdiaatr || ' dias atr., ' || vr_qtdiasav || ' dias ch. esp.';
    rat_qtadidep := vr_qtestour;
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 29/06/2018 - Chamado 660306
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
      pr_dscritic := 'Erro na rotina pc_historico_cooperado: '||SQLerrm;
  END pc_historico_cooperado;

  /* Tratamento das criticas para o calculo de pessoa juridica.
     Foi desenvolvido para mostrar todas as criticas do calculo. */
  PROCEDURE pc_criticas_rating_jur(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                  ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Conta do associado
                                  ,pr_tpctrrat  IN crapnrc.tpctrrat%TYPE --> Tipo do Rating
                                  ,pr_nrctrrat  IN crapnrc.nrctrrat%TYPE --> Número do contrato de Rating
                                  ,pr_cdagenci  IN crapass.cdagenci%TYPE --> Código da agência
                                  ,pr_nrdcaixa  IN craperr.nrdcaixa%TYPE --> Número do caixa
                                  ,pr_tab_erro OUT GENE0001.typ_tab_erro --> Tabela de retorno de erro
                                  ,pr_des_reto OUT VARCHAR2) IS          --> Retorno OK/NOK
  BEGIN
    /* ..........................................................................

       Programa: pc_criticas_rating_jur         Antigo: b1wgen0043 --> criticas_rating_jur
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Marcos Ernani Martini
       Data    : Agosto/2014.                          Ultima Atualizacao: 28/06/2017

       Dados referentes ao programa:

       Frequencia: Sempre que chamado por outros programas.
       Objetivo  : Tratamento das criticas para o calculo de pessoa juridica.
                   Foi desenvolvido para mostrar todas as criticas do calculo.

       Alteracoes: 29/08/2014 - Conversão Progress -> Oracle - Marcos (Supero)

                   03/07/2015 - Projeto 217 Reformulaçao Cadastral IPP Entrada
                                Ajuste nos codigos de natureza juridica para o
                                existente na receita federal (Tiago Castro - RKAM)

                   10/05/2016 - Ajuste para utitlizar rowtype locais
                (Andrei  - RKAM).

                   28/06/2017 - Inclusão para setar o modulo de todas procedures da Package
                                ( Belli - Envolti - 28/06/2017 - Chamado 660306).
       ............................................................................. */
    DECLARE
      -- Tratamento de possíveis erros
      vr_dscritic VARCHAR2(4000);
      vr_tab_erro GENE0001.typ_tab_erro;
      -- Sequencia para geração dos erros
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
      -- Guardar a data de admissão e existencia da crapavt
      vr_dtadmsoc DATE;
      vr_flexiavt BOOLEAN := FALSE;
      -- Guardar faturamento médio mensal
      vr_vlmedfat NUMBER;
      vr_flgcescr BOOLEAN := FALSE;

      rw_crawepr3 cr_crawepr%ROWTYPE;
      rw_crapprp2 cr_crapprp%ROWTYPE;
      rw_craplcr1 cr_craplcr%rowtype;
      rw_craplim2 cr_craplim%ROWTYPE;
      rw_crapfin  cr_crapfin%ROWTYPE;

    BEGIN

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_criticas_rating_jur');

      -- Nao validar para calculo do Risco cooperado
      IF pr_tpctrrat <> 0 AND pr_nrctrrat <> 0  THEN
        -- Para empréstimos / Financiamentos
        IF pr_tpctrrat = 90 THEN
          -- Testar se existe informação complementar do empréstimo
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
            -- Se não encontrar
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

            -- Ler Cadastro de Finalidades
            OPEN cr_crapfin(pr_cdcooper => pr_cdcooper,
                            pr_cdfinemp => rw_crawepr3.cdfinemp);
            FETCH cr_crapfin INTO rw_crapfin;
            IF cr_crapfin%FOUND AND
               rw_crapfin.tpfinali = 1 THEN
               /* Verifica se eh cessao de credito */
               vr_flgcescr := TRUE;
            END IF;
            CLOSE cr_crapfin;

          ELSE
            CLOSE cr_crawepr;
            -- Testar se existe a informação da proposta do empréstimo
            OPEN cr_crapprp(pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_tpctrato => pr_tpctrrat
                           ,pr_nrctrato => pr_nrctrrat);
            FETCH cr_crapprp
             INTO rw_crapprp2;
            -- Se não encontrar
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

        ELSIF pr_tpctrrat = 3 THEN
              OPEN  cr_crawlim(pr_cdcooper => pr_cdcooper
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_tpctrato => pr_tpctrrat
                              ,pr_nrctrato => pr_nrctrrat);
              FETCH cr_crawlim INTO rw_craplim2;
              IF    cr_crawlim%NOTFOUND THEN
                    CLOSE cr_crawlim;
          OPEN cr_craplim(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_tpctrato => pr_tpctrrat
                         ,pr_nrctrato => pr_nrctrrat);
                    FETCH cr_craplim INTO rw_craplim2;
          IF cr_craplim%NOTFOUND THEN
            CLOSE cr_craplim;
            vr_nrsequen := vr_nrsequen + 1;
                          vr_dscritic := NULL;

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
              ELSE
                    CLOSE cr_crawlim;
        END IF;
      ELSE /* Demais operacoes */
        -- Ler Contratos de Limite de credito
        OPEN cr_craplim(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_tpctrato => pr_tpctrrat
                       ,pr_nrctrato => pr_nrctrrat);
        FETCH cr_craplim INTO rw_craplim2;

        -- se não localizou
        IF cr_craplim%NOTFOUND THEN
      vr_dscritic := null;

      vr_nrsequen := vr_nrsequen + 1;
      -- gerar erro na temptable
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => vr_nrsequen
                           ,pr_cdcritic => 484 /* Contrato nao encontrado. */
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
        END IF;

        CLOSE cr_craplim;

      END IF; -- Fim pr_tpctrrat = 90
      END IF;

      /* Nao validaremos os itens a seguir em caso de cessao de credito */
      IF vr_flgcescr THEN
        IF pr_tab_erro.COUNT > 0 THEN
           pr_des_reto := 'NOK';
        ELSE
           pr_des_reto := 'OK';
        END IF;
        RETURN;
      END IF;

      -- Busca do Registro da empresa
      OPEN cr_crapjur;
      FETCH cr_crapjur
       INTO rw_crapjur;
      -- Se não houver gerar critica 331
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
        -- Se não houver setor econômico
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
          -- E também a 830
          vr_nrsequen := vr_nrsequen + 1;
          vr_dscritic := null;
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => vr_nrsequen
                               ,pr_cdcritic => 830
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);

          -- gravar a flag do erro 830 para evitar gravação duplicada deste
          vr_flprbcad := TRUE;
        END IF;
      END IF;
      -- TEstar existencia dos dados financeiros PJ
      OPEN cr_crapjfn;
      FETCH cr_crapjfn
       INTO vr_ind_exis;
      -- Se não encontrar
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
        -- Se ainda não foi enviada a 830
        IF NOT vr_flprbcad THEN
          -- E também a 830
          vr_nrsequen := vr_nrsequen + 1;
          vr_dscritic := null;
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => vr_nrsequen
                               ,pr_cdcritic => 830
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);

          -- gravar a flag do erro 830 para evitar gravação duplicada deste
          vr_flprbcad := TRUE;
        END IF;
      ELSE
        CLOSE cr_crapjfn;
      END IF;
      -- Verificar se existem Socios cadastrados
      -- Esta busca trará os mais antigos primeiro
      OPEN cr_crapavt(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      LOOP
        FETCH cr_crapavt
         INTO vr_dtadmsoc;
        -- Sair quando não existir mais registros
        EXIT WHEN cr_crapavt%NOTFOUND;
        -- Indicar que encontrou pelo menos um sócio
        vr_flexiavt := TRUE;
        -- Sair também se já encontrou aquele de admissão mais antiga
        EXIT WHEN vr_dtadmsoc IS NOT NULL;
      END LOOP;
      CLOSE cr_crapavt;
      -- Somente em naturezas específicas
      IF rw_crapjur.natjurid IN(2062,2135,4081,2089) THEN
        -- Se não encontrou sócio
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
          -- Se ainda não foi enviada a 830
          IF NOT vr_flprbcad THEN
            -- E também a 830
            vr_nrsequen := vr_nrsequen + 1;
            vr_dscritic := null;
            gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                 ,pr_cdagenci => pr_cdagenci
                                 ,pr_nrdcaixa => pr_nrdcaixa
                                 ,pr_nrsequen => vr_nrsequen
                                 ,pr_cdcritic => 830
                                 ,pr_dscritic => vr_dscritic
                                 ,pr_tab_erro => pr_tab_erro);

            -- gravar a flag do erro 830 para evitar gravação duplicada deste
            vr_flprbcad := TRUE;
          END IF;
        END IF;
        -- Se não encontrou data de admissão do sócio mais antigo
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
          -- Se ainda não foi enviada a 830
          IF NOT vr_flprbcad THEN
            -- E também a 830
            vr_nrsequen := vr_nrsequen + 1;
            vr_dscritic := null;
            gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                 ,pr_cdagenci => pr_cdagenci
                                 ,pr_nrdcaixa => pr_nrdcaixa
                                 ,pr_nrsequen => vr_nrsequen
                                 ,pr_cdcritic => 830
                                 ,pr_dscritic => vr_dscritic
                                 ,pr_tab_erro => pr_tab_erro);

            -- gravar a flag do erro 830 para evitar gravação duplicada deste
            vr_flprbcad := TRUE;
          END IF;
        END IF;
      END IF;
      -- Buscar faturamento médio mensal
      cada0001.pc_calcula_faturamento(pr_cdcooper => pr_cdcooper
                                     ,pr_cdagenci => pr_cdagenci
                                     ,pr_nrdcaixa => pr_nrdcaixa
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_vlmedfat => vr_vlmedfat
                                     ,pr_tab_erro => vr_tab_erro
                                     ,pr_des_reto => pr_des_reto);

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_criticas_rating_jur');

      -- Se retornou erro
      -- Progress não trata retorno dos erro
      /*IF pr_des_reto = 'NOK' THEN
        -- Varrer a tabela de erro para copiar para a atual
        FOR vr_ind IN vr_tab_erro.first..vr_tab_erro.last LOOP
          pr_tab_erro(pr_tab_erro.last+1) := vr_tab_erro(vr_ind);
        END LOOP;
      END IF;*/

      -- Se não houve faturamento
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
        -- Se ainda não foi enviada a 830
        IF NOT vr_flprbcad THEN
          -- E também a 830
          vr_nrsequen := vr_nrsequen + 1;
          vr_dscritic := null;
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => vr_nrsequen
                               ,pr_cdcritic => 830
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);

          -- gravar a flag do erro 830 para evitar gravação duplicada deste
          vr_flprbcad := TRUE;
        END IF;
      END IF;

      -- Se não gerou nenhum critica
      IF pr_tab_erro.count = 0 THEN
        pr_des_reto := 'OK';
      ELSE
        pr_des_reto := 'NOK';
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 29/06/2018 - Chamado 660306
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Montar descrição de erro não tratado
        vr_dscritic := 'Erro não tratado na RATI0001.pc_criticas_rating_jur > '||sqlerrm;
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
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
  /*
                   28/06/2017 - Inclusão para setar o modulo de todas procedures da Package
                                ( Belli - Envolti - 28/06/2017 - Chamado 660306).
  */

    vr_idx VARCHAR2(50);
  BEGIN

    -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_carrega_temp_qtdiaatr');

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
                                  ,pr_rw_crapdat  IN btch0001.rw_crapdat%TYPE    --> Vetor com dados de parâmetro (CRAPDAT)
                                  ,pr_tpctrato    IN crapnrc.tpctrrat%TYPE       --> Tipo Contrato Rating
                                  ,pr_nrctrato    IN crapnrc.nrctrrat%TYPE       --> Numero Contrato Rating
                                  ,pr_inusatab    IN BOOLEAN                     --> Indicador de utilização da tabela de juros
                                  ,pr_flgcriar    IN INTEGER                     --> Indicado se deve criar o rating
                                  ,pr_flgttris    IN BOOLEAN                     --> Indicado se deve carregar toda a crapris
                                  ,pr_tab_crapras IN OUT typ_tab_crapras         --> Tabela com os registros a serem processados
                                  ,pr_notacoop   OUT NUMBER                      --> Retorna a nota da classificação
                                  ,pr_clascoop   OUT VARCHAR2                    --> retorna classificação
                                  ,pr_tab_erro   OUT GENE0001.typ_tab_erro       --> Tabela de retorno de erro
                                  ,pr_des_reto   OUT VARCHAR2                    --> Ind. de retorno OK/NOK
                                  ) IS

  /* ..........................................................................

     Programa: pc_risco_cooperado_pj         Antigo: b1wgen0043.p/risco_cooperado_pj
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Marcos Martini - Supero
     Data    : Setembro/2014.                         Ultima Atualizacao: 28/06/2017

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  : Procedure para calcular o risco cooperado para PF.

     Alteracoes: 01/09/2014 - Conversão Progress -> Oracle - Marcos (Supero)

                 05/11/2014 - Ajuste na procedure para carregar a crapris
                              com a conta a qual esta sendo passada ou
                              tudo na temp table. (Jaison)

                 03/07/2015 - Projeto 217 Reformulaçao Cadastral IPP Entrada
                              Ajuste nos codigos de natureza juridica para o
                              existente na receita federal. (Tiago Castro - RKAM)

                 10/05/2016 - Ajuste para iniciar corretamente a pltable
                              (Andrei - RKAM).

                 25/10/2016 - Ajuste no calculo da quantidade de anos, permitindo
                              duas posições decimais. (Kelvin)

                 28/06/2017 - Inclusão para setar o modulo de todas procedures da Package
                              ( Belli - Envolti - 28/06/2017 - Chamado 660306).

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
    -- Descrição e código da critica
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    -- Exceção de saída
    vr_exc_erro EXCEPTION;
    -- Indicador se encontrou registro
    vr_fcrawepr  BOOLEAN := FALSE;
    vr_fcrapprp  BOOLEAN := FALSE;
    vr_fcraplim  BOOLEAN := FALSE;
    vr_fcrapjfn  BOOLEAN := FALSE;
    -- Tempo de operação da empresa no mercado
    vr_nranoope NUMBER(6,2);
    vr_nrseqite PLS_INTEGER;
    -- Valor da nota
    vr_vldanota  NUMBER := 0;
    -- Pior pontualidade no ultimo ano
    vr_qtdiaatr NUMBER;
    -- Guardar a data de admissão do socio mais antigo E tempo em anos da sociedade
    vr_dtadmsoc DATE;
    vr_qtanosoc NUMBER;
    -- Lista de contratos a liquidar
    vr_dsliquid VARCHAR2(4000);
    -- Valor utilizado no endividamento
    vr_vlutiliz NUMBER;
    -- Tabela de central de risco
    vr_tab_central_risco risc0001.typ_reg_central_risco;
    -- Indice para retorno da posição na tt de central de risco
    vr_index_cr PLS_INTEGER;
    -- Guardar faturamento médio mensal
    vr_vlmedfat NUMBER;
    -- Valor endividamento
    vr_vlendivi NUMBER;
    -- Valor da prestação
    vr_vlpresta NUMBER;
    -- Vetor de contratos a liquidar
    vr_vet_nrctrliq typ_vet_nrctrliq := typ_vet_nrctrliq(0,0,0,0,0,0,0,0,0,0);
    -- Valor total de prestação
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

    -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_risco_cooperado_pj');

    vr_dsvalite := '';
    -- Todas as criticas do calculo (juridica) estao aqui
    pc_criticas_rating_jur (pr_cdcooper => pr_cdcooper   --> Codigo Cooperativa
                           ,pr_nrdconta => pr_nrdconta   --> Numero da Conta
                           ,pr_tpctrrat => pr_tpctrato   --> Tipo Contrato Rating
                           ,pr_nrctrrat => pr_nrctrato   --> Numero Contrato Rating
                           ,pr_cdagenci => pr_cdagenci   --> Codigo Agencia
                           ,pr_nrdcaixa => pr_nrdcaixa   --> Numero Caixa
                           ,pr_tab_erro => pr_tab_erro   --> Tabela de retorno de erro
                           ,pr_des_reto => pr_des_reto); --> Ind. de retorno OK/NOK

    -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_risco_cooperado_pj');

    -- Se retornou critica, abortar rotina
    IF pr_des_reto <> 'OK' THEN
      RETURN;
    END IF;

    -- Busca registro da empresa
    OPEN cr_crapjur;
    FETCH cr_crapjur
     INTO rw_crapjur;
    CLOSE cr_crapjur;

    -- Busca das informações cadastrais da PJ
    OPEN cr_crapjfn;
    FETCH cr_crapjfn
     INTO rw_crapjfn;
    vr_fcrapjfn := cr_crapjfn%FOUND;
    CLOSE cr_crapjfn;

    -- Para Risco Cooperado o calculo eh diferenciado
    IF pr_tpctrato <> 0 AND pr_nrctrato <> 0  THEN
      -- Emprestimo/Financiamento
      IF pr_tpctrato = 90 THEN
        -- Ler informações da proposta do emprestimo
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
      ELSIF pr_tpctrato = 3 THEN
            OPEN  cr_crawlim(pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_tpctrato => pr_tpctrato
                            ,pr_nrctrato => pr_nrctrato);
            FETCH cr_crawlim INTO rw_craplim3;
            IF    cr_crawlim%NOTFOUND THEN
                  CLOSE cr_crawlim;
                  OPEN  cr_craplim(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_tpctrato => pr_tpctrato
                                  ,pr_nrctrato => pr_nrctrato);
                  FETCH cr_craplim INTO rw_craplim3;
                  CLOSE cr_craplim;

                  vr_fcraplim := cr_craplim%found;
      ELSE
                  CLOSE cr_crawlim;

                  vr_fcraplim := TRUE;
            END   IF;
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
    -- Gerar valor do item conforme o periodo de operação
    IF vr_nranoope > 8    THEN
      vr_nrseqite := 1;
    ELSIF vr_nranoope  >= 5  THEN
      vr_nrseqite := 2;
    ELSIF vr_nranoope  >= 2  THEN
      vr_nrseqite := 3;
    ELSE
      vr_nrseqite := 4;
    END IF;

    rat_dtfunemp := rw_crapjur.dtiniatv;
    vr_dsvalite := round(vr_nranoope,2) || ' anos de operacao';
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
                           ,pr_dsvalite    => vr_dsvalite
                           ,pr_tab_crapras => pr_tab_crapras       --
                           ,pr_dscritic    => vr_dscritic);        -- Descricao do erro

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_risco_cooperado_pj');

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

    -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_risco_cooperado_pj');

    IF vr_dscritic IS NOT NULL THEN
      raise vr_exc_erro;
    END IF;
    -- Se solicitado o calculo
    IF pr_flgdcalc = 1 THEN
      -- gerar classificação
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
                           ,pr_dsvalite    => vr_dsvalite
                           ,pr_tab_crapras => pr_tab_crapras          --
                           ,pr_dscritic    => vr_dscritic);           -- Descricao do erro

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_risco_cooperado_pj');

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
      -- Usar sequencial de informações cadastrais se houver
      IF rw_crapjur.nrinfcad > 0 THEN
        vr_nrseqite := rw_crapjur.nrinfcad;
      ELSE
        vr_nrseqite := 1;
      END IF;
      -- gerar classificação
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
        -- Senão pegar do proposta ou do limite
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
                           ,pr_dsvalite    => ' '
                           ,pr_tab_crapras => pr_tab_crapras          --
                           ,pr_dscritic    => vr_dscritic);           -- Descricao do erro

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_risco_cooperado_pj');

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

    vr_dsvalite := nvl(vr_qtdiaatr,0) || ' dias de atraso';
    rat_qtmaxatr := nvl(vr_qtdiaatr,0);
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
                            ,pr_dsvalite => vr_dsvalite
                            ,pr_tab_crapras => pr_tab_crapras       --
                            ,pr_dscritic    => vr_dscritic);        -- Descricao do erro

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_risco_cooperado_pj');

      -- Se retornou erro, deve abortar
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END IF;

    -------------------------------------------------------------------
    -- 5_3 - Capacidade de geracao de resultados - SET.ECONOMICO     --
    -------------------------------------------------------------------
    -- Conforme setor
    CASE nvl(rw_crapjur.cdseteco,0)
       WHEN 0 THEN vr_nrseqite := 4; --Agronegocio
       WHEN 1 THEN vr_nrseqite := 4; --Agronegocio
       WHEN 2 THEN vr_nrseqite := 2; -- Comercio
       WHEN 3 THEN vr_nrseqite := 3; -- Industria
       WHEN 4 THEN vr_nrseqite := 1; -- Servicos
       ELSE vr_nrseqite := 0;
    END CASE;

    rat_cdseteco := nvl(rw_crapjur.cdseteco,0);
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
                            ,pr_dsvalite => ' '
                            ,pr_tab_crapras => pr_tab_crapras       --
                            ,pr_dscritic    => vr_dscritic);        -- Descricao do erro

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_risco_cooperado_pj');

      -- Se retornou erro, deve abortar
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END IF;

    /********************************************************************
     Item 4_1 - TEMPO DOS SÓCIOS NA EMPRESA
    ********************************************************************/
    -- Trazer os sócios da empresa, o mais antigo primeiro
    OPEN cr_crapavt(pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => pr_nrdconta);
    LOOP
      FETCH cr_crapavt
       INTO vr_dtadmsoc;

      -- Sair quando não existir mais registros
      EXIT WHEN cr_crapavt%NOTFOUND;
    END LOOP;
    CLOSE cr_crapavt;
    rat_dtprisoc := vr_dtadmsoc;
    -- Naturezas específicas testam tempo do sócio mais antigo
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

    vr_dsvalite := round(vr_qtanosoc,2) || ' anos dos socios na empresa';
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
                            ,pr_dsvalite => vr_dsvalite
                            ,pr_tab_crapras => pr_tab_crapras       --
                            ,pr_dscritic    => vr_dscritic);        -- Descricao do erro

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_risco_cooperado_pj');

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
    vr_dsvalite := rw_crapjfn.perfatcl|| '% faturamento unico cliente';
    rat_prfatcli := rw_crapjfn.perfatcl;
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
                            ,pr_dsvalite => vr_dsvalite
                            ,pr_tab_crapras => pr_tab_crapras       --
                            ,pr_dscritic    => vr_dscritic);        -- Descricao do erro

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_risco_cooperado_pj');

      -- Se retornou erro, deve abortar
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END IF;

    /********************************************************************
     Item 5_1 - Endividamento total SCR versus faturamento medio.
    ********************************************************************/
    -- Para empréstimos e financiamentos com crawepr
    IF pr_tpctrato = 90 AND vr_fcrawepr THEN
      -- Trazer lista de liquidações
      vr_dsliquid := fn_traz_liquidacoes(rw_crawepr4);
    END IF;

    -- Buscar o saldo utilizado pelo Cooperado
    pc_calcula_endividamento(pr_cdcooper   => pr_cdcooper     --> Código da Cooperativa
                            ,pr_cdagenci   => pr_cdagenci     --> Código da agência
                            ,pr_nrdcaixa   => pr_nrdcaixa     --> Número do caixa
                            ,pr_cdoperad   => pr_cdoperad     --> Código do operador
                            ,pr_rw_crapdat => pr_rw_crapdat   --> Vetor com dados de parâmetro (CRAPDAT)
                            ,pr_nrdconta   => pr_nrdconta     --> Conta do associado
                            ,pr_dsliquid   => vr_dsliquid     --> Lista de contratos a liquidar
                            ,pr_idseqttl   => pr_idseqttl     --> Sequencia de titularidade da conta
                            ,pr_idorigem   => pr_idorigem     --> Indicador da origem da chamada
                            ,pr_inusatab   => pr_inusatab     --> Indicador de utilização da tabela de juros
                            ,pr_vlutiliz   => vr_vlutiliz     --> Valor da dívida
                            ,pr_cdcritic   => vr_cdcritic     --> Critica encontrada no processo
                            ,pr_dscritic   => vr_dscritic);   --> Saída de erro

    -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_risco_cooperado_pj');

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
      -- Ler informações do emprestimo
      OPEN cr_crapepr(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctrato => pr_nrctrato);
      FETCH cr_crapepr
       INTO rw_crapepr1;
      IF vr_fcrawepr THEN
        rat_vlopeatu := rw_crawepr4.vlemprst;
      ELSE -- BNDES
        rat_vlopeatu := rw_crapprp3.vlctrbnd;
      END IF;
      -- Se não localizou
      IF cr_crapepr%NOTFOUND THEN
        -- Se há a proposta
        IF vr_fcrawepr THEN
          vr_vlendivi := rw_crawepr4.vlemprst;
        ELSE -- BNDES
          vr_vlendivi := rw_crapprp3.vlctrbnd;
        END IF;
      END IF;
      CLOSE cr_crapepr;
      -- Se houver Valor Total SFN exceto na cooperativa
      IF rw_crapprp3.vltotsfn <> 0 THEN
        -- Usá-lo
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
          rat_vlopeatu := rw_craplim3.vllimite;
        END IF;
        -- Se houver Valor Total SFN exceto na cooperativa
        IF rw_craplim3.vltotsfn <> 0 THEN
          -- Usá-lo
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
                                              ,pr_tab_central_risco => vr_tab_central_risco --> Informações da Central de Risco
                                              ,pr_tab_erro => pr_tab_erro  --> Tabela Erro
                                              ,pr_des_reto => pr_des_reto);

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_risco_cooperado_pj');

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
                                                ,pr_tab_central_risco => vr_tab_central_risco --> Informações da Central de Risco
                                                ,pr_tab_erro => pr_tab_erro  --> Tabela Erro
                                                ,pr_des_reto => pr_des_reto);

        -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_risco_cooperado_pj');

        IF pr_des_reto <> 'OK' THEN
          RETURN;
        END IF;

        -- se possuir valor, somar valor valor
        IF NVL(vr_tab_central_risco.vltotsfn,0) <> 0  THEN
          vr_vlendivi := nvl(vr_vlendivi,0) + vr_tab_central_risco.vltotsfn;
        ELSE
          -- Usar valor já calculado
          vr_vlendivi := nvl(vr_vlendivi,0) + nvl(vr_vlutiliz,0);
        END IF;
        /*-- Buscar primeiro registro      -- Alterado por: Renato Darosci - Supero - 30/04/2015
                                                  Não utilizar mais tabela de memória, apenas um record.
        vr_index_cr := vr_tab_central_risco.first;
        -- verificar se existe
        IF vr_tab_central_risco.EXISTS(vr_index_cr) THEN
          -- se possuir valor, somar valor valor
          IF vr_tab_central_risco(vr_index_cr).vltotsfn <> 0  THEN
            vr_vlendivi := nvl(vr_vlendivi,0) + vr_tab_central_risco(vr_index_cr).vltotsfn;
          ELSE
            -- Usar valor já calculado
            vr_vlendivi := nvl(vr_vlendivi,0) + nvl(vr_vlutiliz,0);
          END IF;
        ELSE
          -- Usar valor já calculado
          vr_vlendivi := nvl(vr_vlendivi,0) + nvl(vr_vlutiliz,0);
        END IF;*/
      ELSE
        -- Sem dívidas
        vr_vlendivi := 0;
      END IF;
    END IF;
    rat_vlendivi := nvl(vr_vlendivi,0);
    rat_vlsldeve := nvl(vr_vlendivi,0);

    -- Buscar também o faturamento médio
    cada0001.pc_calcula_faturamento(pr_cdcooper => pr_cdcooper
                                   ,pr_cdagenci => pr_cdagenci
                                   ,pr_nrdcaixa => pr_nrdcaixa
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_vlmedfat => vr_vlmedfat
                                   ,pr_tab_erro => pr_tab_erro
                                   ,pr_des_reto => pr_des_reto);

    -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_risco_cooperado_pj');

    -- Se retornou erro
    IF pr_des_reto = 'NOK' THEN
      RETURN;
    END IF;

    IF nvl(vr_vlmedfat,0) > 0 THEN
    -- Calcular proporação da dívida X faturamento
      vr_vlendivi := (nvl(vr_vlendivi,0) / nvl(vr_vlmedfat,0));

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
      vr_dsvalite := round(vr_vlendivi,2)||' vezes o faturamento';
    ELSE
      vr_dsvalite := ' ';
      vr_nrseqite := 4;
    END IF;

    rat_vlmedfat := nvl(vr_vlmedfat,0);
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
                           ,pr_dsvalite => vr_dsvalite
                           ,pr_tab_crapras => pr_tab_crapras       --
                           ,pr_dscritic    => vr_dscritic);        -- Descricao do erro

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_risco_cooperado_pj');

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
        -- Senão pegar do proposta ou do limite
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
                           ,pr_dsvalite    => ' '
                           ,pr_tab_crapras => pr_tab_crapras       --
                           ,pr_dscritic    => vr_dscritic);        -- Descricao do erro

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_risco_cooperado_pj');

      -- Se retornou erro, deve abortar
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END IF;

    /********************************************************************
     Item 5_2 - Grau de endividamento. (Parcelas versus faturamento medio)
    ********************************************************************/

    -- Para empréstimos / Financiamentos
    IF pr_tpctrato = 90 THEN
      -- Empréstimos Cecred
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
                            ,pr_idorigem     => pr_idorigem     --> Origem da requisição
                            ,pr_nrdconta     => pr_nrdconta     --> Conta do associado
                            ,pr_tpctrato     => pr_tpctrato     --> Tipo do Rating
                            ,pr_nrctrato     => pr_nrctrato     --> Número do contrato de Rating
                            ,pr_vet_nrctrliq => vr_vet_nrctrliq --> Vetor de contratos a liquidar
                            ,pr_vlpreemp     => vr_vlpresta     --> Valor da parcela
                            ,pr_rw_crapdat   => pr_rw_crapdat   --> Calendário do movimento atual
                            ,pr_flgdcalc     => pr_flgdcalc     --> Flag para calcular sim ou não
                            ,pr_inusatab     => pr_inusatab     --> Indicador de utilização da tabela de juros
                            ,pr_vltotpre     => vr_vltotpre     --> Valor calculado da prestação
                            ,pr_dscritic     => vr_dscritic);

    -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_risco_cooperado_pj');

    -- Se retornou erro, deve abortar
    IF nvl(vr_cdcritic,0) > 0 THEN
      RAISE vr_exc_erro;
    END IF;

    rat_vlpreatv := vr_vltotpre;
    rat_vlparope := vr_vlpresta;
    IF vr_vlmedfat > 0 THEN
    -- Gerar média a partir do faturamento
    vr_vltotpre := vr_vltotpre / vr_vlmedfat;
    -- Testar intervalo
    IF vr_vltotpre <= 0.07 THEN
      -- Ate 7%
      vr_nrseqite := 1;
    ELSIF vr_vltotpre <= 0.1 THEN
      -- Até 10%
      vr_nrseqite := 2;
    ELSE
      -- Mais do que 10%
      vr_nrseqite := 3;
    END IF;
      vr_dsvalite := round(vr_vltotpre*100,2) || '% de endividamento';
    ELSE
      vr_dsvalite := ' ';
      vr_nrseqite := 3;
    END IF;

    -- Em caso de solicitação do cálculo
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
                           ,pr_dsvalite => vr_dsvalite
                           ,pr_tab_crapras => pr_tab_crapras       --
                           ,pr_dscritic    => vr_dscritic);        -- Descricao do erro

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_risco_cooperado_pj');

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
      -- Se houver percentual geral com relação a empresa (rating)
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
        -- Senão pegar do proposta ou do limite
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
                           ,pr_dsvalite    => ' '
                           ,pr_tab_crapras => pr_tab_crapras          --
                           ,pr_dscritic    => vr_dscritic);           -- Descricao do erro

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_risco_cooperado_pj');

      -- Se retornou erro, deve abortar
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END IF;

    rat_cdperemp := vr_nrseqite;
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
      -- Retorno não OK
      pr_des_reto := 'NOK';
      -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 29/06/2018 - Chamado 660306
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
      -- Retorno não OK
      pr_des_reto := 'NOK';

      -- Montar descrição de erro não tratado
      vr_dscritic := 'Erro não tratado na RATI0001.pc_risco_cooperado_pj> '||sqlerrm;
      -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
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
                                      ,pr_rw_crapdat IN btch0001.rw_crapdat%TYPE  --> Vetor com dados de parâmetro (CRAPDAT)
                                      ,pr_tpctrato IN crapnrc.tpctrrat%TYPE    --> Tipo Contrato Rating
                                      ,pr_nrctrato IN crapnrc.nrctrrat%TYPE    --> Numero Contrato Rating
                                      ,pr_inusatab IN BOOLEAN                  --> Indicador de utilização da tabela de juros
                                      ,pr_flgcriar IN INTEGER                  --> Indicado se deve criar o rating
                                      ,pr_tab_crapras IN OUT typ_tab_crapras   --> Tabela com os registros a serem processados
                                      ,pr_tab_erro OUT GENE0001.typ_tab_erro   --> Tabela de retorno de erro
                                      ,pr_des_reto OUT VARCHAR2) IS            --> Ind. de retorno OK/NOK IS           --> Descricao do erro
  /* ..........................................................................

     Programa: pc_calcula_rating_juridica         Antigo: b1wgen0043.p/calcula_rating_juridica
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Marcos Martini - Supero
     Data    : Agosto/2014.                          Ultima Atualizacao: 28/06/2017

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  : Procedure para calular o rating para as pessoas fisicas.

     Alteracoes: 28/08/2014 - Conversão Progress -> Oracle - Marcos (Supero)

             10/05/2016 - Ajuste para utitlizar rowtype locais
               (Andrei  - RKAM).

                 28/06/2017 - Inclusão para setar o modulo de todas procedures da Package
                              ( Belli - Envolti - 28/06/2017 - Chamado 660306).
  ............................................................................. */

    -- Variaveis de erro
    vr_exc_erro EXCEPTION;
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);

    -- Indicador se encontrou registro
    vr_fcrawepr  BOOLEAN := FALSE;
    vr_fcraplcr  BOOLEAN := FALSE;
    -- Sequenciais para gravações dos itens
    vr_nrseqite  NUMBER;
    vr_qtdiapra  NUMBER;
    -- Classificação e Nota do cooperado
    vr_notacoop NUMBER;
    vr_clascoop VARCHAR2(10);

    vr_idqualif NUMBER;

    rw_crawepr5 cr_crawepr%ROWTYPE;
    rw_crapprp4 cr_crapprp%ROWTYPE;
    rw_craplcr3 cr_craplcr%ROWTYPE;
    rw_craplim4 cr_craplim%ROWTYPE;

  BEGIN

    -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_calcula_rating_juridica');

    -- Para Risco Cooperado o calculo eh diferenciado
    IF pr_tpctrato <> 0 AND pr_nrctrato <> 0 THEN
      -- Emprestimo/Financiamento
      IF pr_tpctrato = 90 THEN
        -- Ler informações complementares emprestimo
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

        -- Ler Contratos de Limite de credito
      ELSIF pr_tpctrato = 3 THEN
            OPEN  cr_crawlim(pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_tpctrato => pr_tpctrato
                            ,pr_nrctrato => pr_nrctrato);
            FETCH cr_crawlim INTO rw_craplim4;
            IF    cr_crawlim%NOTFOUND THEN
                  CLOSE cr_crawlim;
                  OPEN  cr_craplim(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_tpctrato => pr_tpctrato
                                  ,pr_nrctrato => pr_nrctrato);
                  FETCH cr_craplim  INTO rw_craplim4;
                  CLOSE cr_craplim;
            ELSE
                  CLOSE cr_crawlim;
            END   IF;

      ELSE
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
                          ,pr_rw_crapdat => pr_rw_crapdat  --> Vetor com dados de parâmetro (CRAPDAT)
                          ,pr_tpctrato => pr_tpctrato      --> Tipo Contrato Rating
                          ,pr_nrctrato => pr_nrctrato      --> Numero Contrato Rating
                          ,pr_inusatab => pr_inusatab      --> Indicador de utilização da tabela de juros
                          ,pr_flgcriar => pr_flgcriar      --> Indicado se deve criar o rating
                          ,pr_flgttris => FALSE            --> Indicado se deve carregar toda a crapris
                          ,pr_tab_crapras => pr_tab_crapras--> Tabela com os registros a serem processados
                          ,pr_notacoop => vr_notacoop      --> Retorna a nota da classificação
                          ,pr_clascoop => vr_clascoop      --> Retorna classificação
                          ,pr_tab_erro => pr_tab_erro      --> Tabela de retorno de erro
                          ,pr_des_reto => pr_des_reto );   --> Ind. de retorno OK/NOK

    -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_calcula_rating_juridica');

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
        rat_cdquaope := rw_crawepr5.idquapro;
        rat_cdlincre := rw_crawepr5.cdlcremp;
        rat_cdmodali := rw_craplcr3.cdmodali;
        rat_cdsubmod := rw_craplcr3.cdsubmod;
        rat_dstpoper := rw_craplcr3.dsoperac;
        -- Renegociacao / Composicao de divida

    --simas--
    vr_idqualif := fn_verifica_qualificacao(pr_nrdconta => pr_nrdconta,
                        pr_nrctremp => pr_nrctrato,
                        pr_idquapro => rw_crawepr5.idquapro,
                        pr_cdcooper => pr_cdcooper);

        -- IF rw_crawepr5.idquapro > 2 THEN
    IF vr_idqualif > 2 THEN
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
        rat_cdquaope := 1;
        rat_cdlincre := 0;
        rat_cdmodali := '';
        rat_cdsubmod := '';
        rat_dstpoper := 'FINANCIAMENTO';
        -- Se não encontrou linha de credito
        IF NOT vr_fcraplcr THEN
          vr_nrseqite := 2;
        END IF;
      END IF;
    ELSE
      rat_cdquaope := 0;
      rat_cdlincre := 0;
      rat_cdmodali := '';
      rat_cdsubmod := '';
      -- Limite
      IF rw_craplim4.tpctrlim = 1 THEN
        vr_nrseqite := 5;
        rat_dstpoper := 'Limite de Credito';
      ELSE
        -- Descontos
        vr_nrseqite := 2;
        rat_dstpoper := 'Limite de Desconto';
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
                         ,pr_dsvalite    => ' '
                         ,pr_tab_crapras => pr_tab_crapras       -- Tabela generica de rating do associado
                         ,pr_dscritic    => vr_dscritic);        -- Descricao do erro

    -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_calcula_rating_juridica');

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
      rat_flgcjeco := rw_crapprp4.flgdocje;
    -- Descontos / Limite rotativo
    ELSE
      vr_nrseqite := rw_craplim4.nrgarope;
    END IF;

    rat_cdgarope := vr_nrseqite;
    -- Grava o item de Rating
    pc_grava_item_rating (pr_cdcooper    => pr_cdcooper             -- Codigo Cooperativa
                         ,pr_nrdconta    => pr_nrdconta             -- Numero da Conta
                         ,pr_tpctrato    => pr_tpctrato             -- Tipo Contrato Rating
                         ,pr_nrctrato    => pr_nrctrato             -- Numero Contrato Rating
                         ,pr_nrtopico    => 4                       -- Numero do topico
                         ,pr_nritetop    => 2                       -- Numero Contrato Rating
                         ,pr_nrseqite    => vr_nrseqite             -- Numero Contrato Rating
                         ,pr_flgcriar    => pr_flgcriar             -- Indicado se deve criar o rating
                         ,pr_dsvalite    => ' '
                         ,pr_tab_crapras => pr_tab_crapras       -- Tabela generica de rating do associado
                         ,pr_dscritic    => vr_dscritic);        -- Descricao do erro

    -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_calcula_rating_juridica');

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

    rat_cdliqgar := vr_nrseqite;
    -- Grava o item de Rating
    pc_grava_item_rating (pr_cdcooper    => pr_cdcooper             -- Codigo Cooperativa
                         ,pr_nrdconta    => pr_nrdconta             -- Numero da Conta
                         ,pr_tpctrato    => pr_tpctrato             -- Tipo Contrato Rating
                         ,pr_nrctrato    => pr_nrctrato             -- Numero Contrato Rating
                         ,pr_nrtopico    => 4                       -- Numero do topico
                         ,pr_nritetop    => 3                       -- Numero Contrato Rating
                         ,pr_nrseqite    => vr_nrseqite             -- Numero Contrato Rating
                         ,pr_flgcriar    => pr_flgcriar             -- Indicado se deve criar o rating
                         ,pr_dsvalite    => ' '
                         ,pr_tab_crapras => pr_tab_crapras       -- Tabela generica de rating do associado
                         ,pr_dscritic    => vr_dscritic);        -- Descricao do erro

    -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_calcula_rating_juridica');

    -- Se retornou erro, deve abortar
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -------------------------------------
    -- Item 4_5 - Prazo da operacao -----
    -------------------------------------
    -- Emprestimo / Financiamento
    IF pr_tpctrato = 90 THEN
      -- Se há o cadastro complementar
      IF vr_fcrawepr THEN
         -- Usamos do complemento
         vr_qtdiapra := rw_crawepr5.qtpreemp * 30; -- Sempre vezes 30
         rat_qtpreope := rw_crawepr5.qtpreemp;
      ELSE
         -- Buscar da proposta
         vr_qtdiapra := rw_crapprp4.qtparbnd * 30; -- Sempre vezes 30
         rat_qtpreope := rw_crapprp4.qtparbnd;
      END IF;
    -- Descontos / Limite rotativo
    ELSE
      -- Usar dias de vigencia do limite
      vr_qtdiapra := rw_craplim4.qtdiavig;
      rat_qtpreope := rw_craplim4.qtdiavig / 30;
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
    vr_dsvalite := vr_qtdiapra || ' dias de prazo da operacao';
    -- Grava o item de Rating
    pc_grava_item_rating (pr_cdcooper    => pr_cdcooper          -- Codigo Cooperativa
                         ,pr_nrdconta    => pr_nrdconta          -- Numero da Conta
                         ,pr_tpctrato    => pr_tpctrato          -- Tipo Contrato Rating
                         ,pr_nrctrato    => pr_nrctrato          -- Numero Contrato Rating
                         ,pr_nrtopico    => 4                    -- Numero do topico
                         ,pr_nritetop    => 4                    -- Numero Contrato Rating
                         ,pr_nrseqite    => vr_nrseqite          -- Numero Contrato Rating
                         ,pr_flgcriar    => pr_flgcriar          -- Indicado se deve criar o rating
                         ,pr_dsvalite    => vr_dsvalite
                         ,pr_tab_crapras => pr_tab_crapras       -- Tabela generica de rating do associado
                         ,pr_dscritic    => vr_dscritic);        -- Descricao do erro

    -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_calcula_rating_juridica');

    -- Se retornou erro, deve abortar
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Retorno OK
    pr_des_reto := 'OK';
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK
      pr_des_reto := 'NOK';
      -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 29/06/2018 - Chamado 660306
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
      -- Retorno não OK
      pr_des_reto := 'NOK';
      -- Montar descrição de erro não tratado
      vr_dscritic := 'Erro não tratado na RATI0001.pc_calcula_rating_juridica> '||sqlerrm;
      -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
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
                                ,pr_rw_crapdat IN btch0001.rw_crapdat%TYPE --> Vetor com dados de parâmetro (CRAPDAT)
                                ,pr_nrdconta IN crapass.nrdconta%TYPE      --> Numero da Conta
                                ,pr_tpctrato IN crapnrc.tpctrrat%TYPE      --> Tipo Contrato Rating
                                ,pr_nrctrato IN crapnrc.nrctrrat%TYPE      --> Numero Contrato Rating
                                ,pr_idseqttl IN crapttl.idseqttl%TYPE      --> Sequencial do Titular
                                ,pr_idorigem IN INTEGER                    --> Identificador Origem
                                ,pr_inusatab IN BOOLEAN                    --> Indicador de utilização da tabela de juros
                                ,pr_flgcriar OUT INTEGER                   --> Indicado se deve criar o rating
                                ,pr_tab_erro OUT GENE0001.typ_tab_erro     --> Tabela de retorno de erro
                                ,pr_des_reto OUT VARCHAR2) IS              --> Ind. de retorno OK/NOK

  /* ..........................................................................

     Programa: pc_verifica_criacao         Antigo: b1wgen0043.p/verifica_criacao
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Odirlei Busana - AMcom
     Data    :Aagosto/2014.                          Ultima Atualizacao: 28/06/2017

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  : Verificar se o Rating tem que ser criado.

     Alteracoes: 27/08/2014 - Conversão Progress -> Oracle - Odirlei (AMcom)

             10/05/2016 - Ajuste para utitlizar rowtype locais
                (Andrei  - RKAM).

                 28/06/2017 - Inclusão para setar o modulo de todas procedures da Package
                              ( Belli - Envolti - 28/06/2017 - Chamado 660306).

  ............................................................................. */

  ---------------- CURSOR ---------------

    -- Verificar se já existe Notas do rating para contrato
    CURSOR cr_crapnrc IS
      SELECT 1
        FROM crapnrc
       WHERE crapnrc.cdcooper = pr_cdcooper
         AND crapnrc.nrdconta = pr_nrdconta
         AND crapnrc.tpctrrat = pr_tpctrato
         AND crapnrc.nrctrrat = pr_nrctrato;
    rw_crapnrc cr_crapnrc%ROWTYPE;

  ----------------- VARIAVEIS -----------------
    -- Descrição e código da critica
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    -- Exceção de saída
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
    -- Valor máximo legal
    vr_vlmaxleg NUMBER;

    rw_crawepr6 cr_crawepr%ROWTYPE;

  BEGIN

    -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_verifica_criacao');

    -- Se for tipo de contrato 90
    IF pr_tpctrato = 90 THEN
      -- Buscar dados dos emprestimos
      OPEN cr_crawepr(pr_cdcooper
                     ,pr_nrdconta
                     ,pr_nrctrato);
      FETCH cr_crawepr
       INTO rw_crawepr6;
      -- Se não encontrar
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
    pc_calcula_endividamento(pr_cdcooper   => pr_cdcooper     --> Código da Cooperativa
                            ,pr_cdagenci   => pr_cdagenci     --> Código da agência
                            ,pr_nrdcaixa   => pr_nrdcaixa     --> Número do caixa
                            ,pr_cdoperad   => pr_cdoperad     --> Código do operador
                            ,pr_rw_crapdat => pr_rw_crapdat   --> Vetor com dados de parâmetro (CRAPDAT)
                            ,pr_nrdconta   => pr_nrdconta     --> Conta do associado
                            ,pr_dsliquid   => vr_dsliquid     --> Lista de contratos a liquidar
                            ,pr_idseqttl   => pr_idseqttl     --> Sequencia de titularidade da conta
                            ,pr_idorigem   => pr_idorigem     --> Indicador da origem da chamada
                            ,pr_inusatab   => pr_inusatab     --> Indicador de utilização da tabela de juros
                            ,pr_vlutiliz   => vr_vlutiliz     --> Valor da dívida
                            ,pr_cdcritic   => vr_cdcritic     --> Critica encontrada no processo
                            ,pr_dscritic   => vr_dscritic);   --> Saída de erro

    -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_verifica_criacao');

    -- Se houve erro
    IF vr_cdcritic IS NOT NULL OR trim(vr_dscritic) IS NOT NULL THEN
      -- Encerrar o processo
      RAISE vr_exc_erro;
    END IF;

  wglb_vlutiliz := vr_vlutiliz;

    -- Retornar valor de parametrização do rating cadastrado na TAB036
    pc_param_valor_rating(pr_cdcooper => pr_cdcooper --> Código da Cooperativa
                         ,pr_vlrating => vr_vlrating --> Valor parametrizado
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic);

    -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_verifica_criacao');

    -- Se houve erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      -- Encerrar o processo
      RAISE vr_exc_erro;
    END IF;

    -- Buscar valor maximo legal cadastrado pela CADCOP
    pc_valor_maximo_legal(pr_cdcooper => pr_cdcooper --> Código da Cooperativa
                         ,pr_vlmaxleg => vr_vlmaxleg --> Valor parametrizado
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic);

    -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_verifica_criacao');

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

    /* Se ja existe é porq esta atualizando */
    ELSE
      -- Verificar se já existe Notas do rating para contrato
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
      -- Retorno não OK
      pr_des_reto := 'NOK';
      -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 29/06/2018 - Chamado 660306
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
      -- Retorno não OK
      pr_des_reto := 'NOK';
      -- Montar descrição de erro não tratado
      vr_dscritic := 'Erro não tratado na RATI0001.pc_verifica_criacao> '||sqlerrm;
      -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
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
                                 ,pr_rw_crapdat      IN btch0001.rw_crapdat%TYPE  --> Vetor com dados de parâmetro (CRAPDAT)
                                 ,pr_tpctrato        IN crapnrc.tpctrrat%TYPE     --> Tipo Contrato Rating
                                 ,pr_nrctrato        IN crapnrc.nrctrrat%TYPE     --> Numero Contrato Rating
                                 ,pr_inusatab        IN BOOLEAN                   --> Indicador de utilização da tabela de juros
                                 ,pr_flgcriar        IN INTEGER                   --> Indicado se deve criar o rating
                                 ,pr_tab_rating_sing IN typ_tab_crapras     --> Tabela com os registros a serem processados
                                 ,pr_tab_crapras     IN OUT typ_tab_crapras --> Tabela com os registros a serem processados
                                 ,pr_vlutiliz           OUT NUMBER          --> Valor da dívida
                                 ,pr_dscritic           OUT VARCHAR2) IS    --> Descricao do erro

  /* ..........................................................................

     Programa: pc_calcula_singulares         Antigo: b1wgen0043.p/calcula_singulares
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Odirlei Busana - AMcom
     Data    :Aagosto/2014.                          Ultima Atualizacao: 28/06/2017

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  : Procedure para calcular o rating das cooperativas singulares com c/c na
                 CECRED

     Alteracoes: 27/08/2014 - Conversão Progress -> Oracle - Odirlei (AMcom)

                 28/06/2017 - Inclusão para setar o modulo de todas procedures da Package
                              ( Belli - Envolti - 28/06/2017 - Chamado 660306).

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

    -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_calcula_singulares');

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
                            ,pr_dsvalite => ' '
                            ,pr_tab_crapras => pr_tab_crapras  --
                            ,pr_dscritic    => pr_dscritic);        -- Descricao do erro

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_calcula_singulares');

      -- Se retornou erro, deve abortar
      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- buscar proximo
      vr_index := pr_tab_rating_sing.next(vr_index);
    END LOOP;

    -- Buscar o saldo utilizado pelo Cooperado
    pc_calcula_endividamento(pr_cdcooper   => pr_cdcooper     --> Código da Cooperativa
                            ,pr_cdagenci   => pr_cdagenci     --> Código da agência
                            ,pr_nrdcaixa   => pr_nrdcaixa     --> Número do caixa
                            ,pr_cdoperad   => pr_cdoperad     --> Código do operador
                            ,pr_rw_crapdat => pr_rw_crapdat   --> Vetor com dados de parâmetro (CRAPDAT)
                            ,pr_nrdconta   => pr_nrdconta     --> Conta do associado
                            ,pr_dsliquid   => null            --> Lista de contratos a liquidar
                            ,pr_idseqttl   => pr_idseqttl     --> Sequencia de titularidade da conta
                            ,pr_idorigem   => pr_idorigem     --> Indicador da origem da chamada
                            ,pr_inusatab   => pr_inusatab     --> Indicador de utilização da tabela de juros
                            ,pr_vlutiliz   => vr_valoruti     --> Valor da dívida
                            ,pr_cdcritic   => vr_cdcritic     --> Critica encontrada no processo
                            ,pr_dscritic   => vr_dscritic);   --> Saída de erro

    -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_calcula_singulares');

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
      -- No caso de erro de programa gravar tabela especifica de log - 29/06/2018 - Chamado 660306
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
      pr_dscritic := 'Erro na pc_calcula_singulares: '||SQLErrm;
  END pc_calcula_singulares;

  /*****************************************************************************
   Natureza da operacao Pessoa fisica (2_1).
  *****************************************************************************/
  PROCEDURE pc_natureza_operacao(pr_tpctrato IN crapnrc.tpctrrat%TYPE --> Tipo Contrato Rating
                                ,pr_idquapro IN INTEGER       --> Numero Contrato Rating
                                ,pr_dsoperac IN VARCHAR2      --> Indicado se deve criar o rating
                                ,pr_cdcooper IN INTEGER       --> Código da cooperativa
                                ,pr_nrctrato IN INTEGER       --> Número do Contrato
                                ,pr_nrdconta IN INTEGER       --> Número da Conta
                                ,pr_nrseqite OUT NUMBER       --> Valor da dívida
                                ,pr_dscritic OUT VARCHAR2) IS --> Descricao do erro

  /* ..........................................................................

     Programa: pc_natureza_operacao         Antigo: b1wgen0043.p/natureza_operacao
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Odirlei Busana - AMcom
     Data    : Agosto/2014.                          Ultima Atualizacao: 28/06/2017

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  : Natureza da operacao Pessoa fisica (2_1).

     Alteracoes: 27/08/2014 - Conversão Progress -> Oracle - Odirlei (AMcom)

                 28/06/2017 - Inclusão para setar o modulo de todas procedures da Package
                              ( Belli - Envolti - 28/06/2017 - Chamado 660306).

                 31/01/2018 - Alteração para novos parâmetros de entrada
                              (Atendendo a qualificação da Oper. Controle)
                              (Diego Simas - AMcom)

  ............................................................................. */
  --------------- VARIAVEIS ----------------
  BEGIN

    -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_natureza_operacao');

    IF pr_tpctrato = 90 THEN  -- Emprestimo / Financiamento
      IF pr_idquapro > 2 THEN
        -- Renegociacao / Composicao de divida / Cessao de Cartao
        IF pr_idquapro in (3,4,5) THEN
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
      -- No caso de erro de programa gravar tabela especifica de log - 29/06/2018 - Chamado 660306
      CECRED.pc_internal_exception (pr_cdcooper => NULL);
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
     Data    : Agosto/2014.                          Ultima Atualizacao: 28/06/2017

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  : Tratamento das criticas para o calculo de pessoa fisica.
                 Foi desenvolvido para mostrar todas as criticas do calculo.

     Alteracoes: 27/08/2014 - Conversão Progress -> Oracle - Odirlei (AMcom)

               10/05/2016 - Ajuste para utitlizar rowtype locais
               (Andrei  - RKAM).

                 28/06/2017 - Inclusão para setar o modulo de todas procedures da Package
                              ( Belli - Envolti - 28/06/2017 - Chamado 660306).


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
    -- Descrição e código da critica
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    -- Exceção de saída
    vr_exc_erro EXCEPTION;
    -- sequencial do erro
    vr_nrsequen NUMBER;
    -- identifica se ja gerou critica 830
    vr_flgcadin BOOLEAN := FALSE;
    vr_flgcescr BOOLEAN := FALSE;

    rw_crawepr7 cr_crawepr%ROWTYPE;
    rw_crapprp5 cr_crapprp%ROWTYPE;
    rw_craplcr4 cr_craplcr%ROWTYPE;
    rw_craplim5 cr_craplim%ROWTYPE;
    rw_crapfin  cr_crapfin%ROWTYPE;

  BEGIN

    -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_criticas_rating_fis');

    -- Iniciar variaveis
    vr_nrsequen := 0;
    vr_dscritic := null;
    vr_cdcritic := 0;

    -- verificar conta do associado
    OPEN cr_crapass;
    FETCH cr_crapass INTO rw_crapass;
    -- se não encontrar gerar critica
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
    -- se não encontrar gerar critica
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
    -- se não encontrar gerar critica
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

    /* Nao efetuar validacoes quando for calcular soh a nota cooperado */
    IF pr_tpctrrat <> 0 AND pr_nrctrrat <> 0 THEN
      /* Para emprestimos */
      IF pr_tpctrrat = 90 THEN
        --ler informações do emprestimo
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
          -- se não localizou
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
          -- Ler Cadastro de Finalidades
          OPEN cr_crapfin(pr_cdcooper => pr_cdcooper,
                          pr_cdfinemp => rw_crawepr7.cdfinemp);
          FETCH cr_crapfin INTO rw_crapfin;
          IF cr_crapfin%FOUND AND
             rw_crapfin.tpfinali = 1 THEN
             /* Verifica se eh cessao de credito */
             vr_flgcescr := TRUE;
    END IF;
          CLOSE cr_crapfin;

    END IF;
        CLOSE cr_crawepr;

        ELSIF pr_tpctrrat = 3 THEN
              OPEN  cr_crawlim(pr_cdcooper => pr_cdcooper
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_tpctrato => pr_tpctrrat
                              ,pr_nrctrato => pr_nrctrrat);
              FETCH cr_crawlim INTO rw_craplim5;
              IF    cr_crawlim%NOTFOUND THEN
                    CLOSE cr_crawlim;
                    OPEN  cr_craplim(pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_tpctrato => pr_tpctrrat
                                    ,pr_nrctrato => pr_nrctrrat);
                    FETCH cr_craplim INTO rw_craplim5;
                    IF    cr_craplim%NOTFOUND THEN
                          CLOSE cr_craplim;
                          vr_nrsequen := vr_nrsequen + 1;
                          vr_dscritic := null;
                          vr_cdcritic := 484; /* Contrato nao encontrado. */

                          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                               ,pr_cdagenci => pr_cdagenci
                                               ,pr_nrdcaixa => pr_nrdcaixa
                                               ,pr_nrsequen => vr_nrsequen
                                               ,pr_cdcritic => vr_cdcritic
                                               ,pr_dscritic => vr_dscritic
                                               ,pr_tab_erro => pr_tab_erro);
                    ELSE
                          CLOSE cr_craplim;
                    END   IF;
              ELSE
                    CLOSE cr_crawlim;
              END   IF;

      ELSE /* Demais operacoes */
        -- Ler Contratos de Limite de credito
        OPEN cr_craplim(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_tpctrato => pr_tpctrrat
                       ,pr_nrctrato => pr_nrctrrat);
        FETCH cr_craplim INTO rw_craplim5;
            -- se não localizou o contrato gera a critica para contrato
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

    /* Nao validaremos os itens a seguir em caso de cessao de credito */
    IF vr_flgcescr THEN
      IF pr_tab_erro.COUNT > 0 THEN
         pr_des_reto := 'NOK';
      ELSE
         pr_des_reto := 'OK';
      END IF;
      RETURN;
    END IF;

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

      -- flag para marcar que já gerou critica de dados incompletos
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
    -- se não encontrar gerar critica
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

      -- se ainda não gerou critica de cadastro incompleto
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

        -- se ainda não gerou critica de cadastro incompleto
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

    IF pr_tab_erro.COUNT > 0 THEN
      pr_des_reto := 'NOK';
    ELSE
      pr_des_reto := 'OK';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 29/06/2018 - Chamado 660306
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
      -- Retorno não OK
      pr_des_reto := 'NOK';
      vr_nrsequen := vr_nrsequen + 1;

      -- Montar descrição de erro não tratado
      vr_dscritic := 'Erro não tratado na RATI0001.pc_criticas_rating_fis> '||sqlerrm;
      -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
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
                                 ,pr_rw_crapdat  IN btch0001.rw_crapdat%TYPE --> Vetor com dados de parâmetro (CRAPDAT)
                                 ,pr_tpctrato    IN crapnrc.tpctrrat%TYPE    --> Tipo Contrato Rating
                                 ,pr_nrctrato    IN crapnrc.nrctrrat%TYPE    --> Numero Contrato Rating
                                 ,pr_inusatab    IN BOOLEAN                  --> Indicador de utilização da tabela de juros
                                 ,pr_flgcriar    IN INTEGER                  --> Indicado se deve criar o rating
                                 ,pr_flgttris    IN BOOLEAN                  --> Indicado se deve carregar toda a crapris
                                 ,pr_tab_crapras IN OUT typ_tab_crapras      --> Tabela com os registros a serem processados
                                 ,pr_notacoop       OUT NUMBER               --> Retorna a nota da classificação
                                 ,pr_clascoop       OUT VARCHAR2             --> Retorna classificação
                                 ,pr_tab_erro       OUT GENE0001.typ_tab_erro--> Tabela de retorno de erro
                                 ,pr_des_reto       OUT VARCHAR2             --> Ind. de retorno OK/NOK
                                 ) IS

  /* ..........................................................................

     Programa: pc_risco_cooperado_pf         Antigo: b1wgen0043.p/risco_cooperado_pf
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Odirlei Busana - AMcom
     Data    : Agosto/2014.                          Ultima Atualizacao: 28/06/2017

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  : Procedure para calcular o risco cooperado para PF.

     Alteracoes: 27/08/2014 - Conversão Progress -> Oracle - Odirlei (AMcom)

                 05/11/2014 - Ajuste na procedure para carregar a crapris
                              com a conta a qual esta sendo passada ou
                              tudo na temp table. (Jaison)

               10/05/2016 - Ajuste para iniciar corretamente a pltable
                (Andrei - RKAM).

                 28/06/2017 - Inclusão para setar o modulo de todas procedures da Package
                              ( Belli - Envolti - 28/06/2017 - Chamado 660306).

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
    -- Descrição e código da critica
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    -- Exceção de saída
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
    -- Valor da prestação
    vr_vlpresta NUMBER;
    -- Valor total de prestação
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
  vr_idqualif NUMBER;

    rw_crawepr8 cr_crawepr%ROWTYPE;
    rw_crapepr2 cr_crapepr%ROWTYPE;
    rw_crapprp6 cr_crapprp%ROWTYPE;
    rw_craplcr5 cr_craplcr%ROWTYPE;
    rw_craplim6 cr_craplim%ROWTYPE;
    rw_crapnrc2 cr_crapnrc%ROWTYPE;

  BEGIN

    -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_risco_cooperado_pf');

    vr_dsvalite := '';
    -- gera criticas rating
    pc_criticas_rating_fis ( pr_cdcooper => pr_cdcooper   --> Codigo Cooperativa
                            ,pr_nrdconta => pr_nrdconta   --> Numero da Conta
                            ,pr_tpctrrat => pr_tpctrato   --> Tipo Contrato Rating
                            ,pr_nrctrrat => pr_nrctrato   --> Numero Contrato Rating
                            ,pr_cdagenci => pr_cdagenci   --> Codigo Agencia
                            ,pr_nrdcaixa => pr_nrdcaixa   --> Numero Caixa
                            ,pr_tab_erro => pr_tab_erro   --> Tabela de retorno de erro
                            ,pr_des_reto => pr_des_reto); --> Ind. de retorno OK/NOK

    -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_risco_cooperado_pf');

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

        --ler informações do emprestimo
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

      ELSIF pr_tpctrato = 3 THEN
            OPEN  cr_crawlim(pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_tpctrato => pr_tpctrato
                            ,pr_nrctrato => pr_nrctrato);
            FETCH cr_crawlim INTO rw_craplim6;
            IF    cr_crawlim%NOTFOUND THEN
                  CLOSE cr_crawlim;
                  OPEN  cr_craplim(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_tpctrato => pr_tpctrato
                                  ,pr_nrctrato => pr_nrctrato);
                  FETCH cr_craplim INTO rw_craplim6;
                  CLOSE cr_craplim;

                  vr_fcraplim := cr_craplim%found;
            ELSE
                  CLOSE cr_crawlim;

                  vr_fcraplim := TRUE;
            END   IF;
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

    vr_dsvalite := round(vr_anodcoop,2) || ' anos';
    rat_dtadmiss := rw_crapass.dtadmiss;
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
                            ,pr_dsvalite => vr_dsvalite
                            ,pr_tab_crapras => pr_tab_crapras       --
                            ,pr_dscritic    => vr_dscritic);        -- Descricao do erro

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_risco_cooperado_pf');

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
     vr_idqualif := fn_verifica_qualificacao(pr_nrdconta => pr_nrdconta,
                        pr_nrctremp => pr_nrctrato,
                        pr_idquapro => rw_crawepr8.idquapro,
                        pr_cdcooper => pr_cdcooper);

      IF vr_fcrawepr AND vr_idqualif = 3 THEN
       -- simas
       -- rw_crawepr8.idquapro = 3   THEN  /* Renegociacao */
     -- vr_idqualif = 3 THEN /* Renegociacao */
        vr_nrseqite := 3;
      END IF;
    END IF;

    vr_dsvalite := nvl(vr_qtdiaatr,0) || ' dias de atraso';
    rat_qtmaxatr := nvl(vr_qtdiaatr,0);
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
                            ,pr_dsvalite => vr_dsvalite
                            ,pr_tab_crapras => pr_tab_crapras       --
                            ,pr_dscritic    => vr_dscritic);        -- Descricao do erro

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_risco_cooperado_pf');

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

    vr_dsvalite := round(vr_anodexpe,2) || ' anos de experiencia';
    rat_dtadmemp := rw_crapttl.dtadmemp;
    rat_cdnatocp := rw_crapttl.cdnatopc;
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
                            ,pr_dsvalite => vr_dsvalite
                            ,pr_tab_crapras => pr_tab_crapras       --
                            ,pr_dscritic    => vr_dscritic);        -- Descricao do erro

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_risco_cooperado_pf');

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
                            ,pr_dsvalite => ' '
                            ,pr_tab_crapras => pr_tab_crapras       --
                            ,pr_dscritic    => vr_dscritic);        -- Descricao do erro

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_risco_cooperado_pf');

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

    -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_risco_cooperado_pf');

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
                            ,pr_dsvalite => vr_dsvalite
                            ,pr_tab_crapras => pr_tab_crapras       --
                            ,pr_dscritic    => vr_dscritic);        -- Descricao do erro

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_risco_cooperado_pf');

      -- Se retornou erro, deve abortar
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END IF;

    -------------------------------------------------------------------
    --               Item 1_6 - Tipo de residencia.                  --
    -------------------------------------------------------------------
    CASE nvl(rw_crapenc.incasprp,0)
        WHEN 1  THEN vr_nrseqite := 1;  -- Quitado
        WHEN 2  THEN vr_nrseqite := 2;  -- Financiado
        WHEN 4  THEN vr_nrseqite := 3;  -- Familiar
        WHEN 5  THEN vr_nrseqite := 3;  -- Cedido
        WHEN 3  THEN vr_nrseqite := 4;  -- Alugado
        WHEN 0  then vr_nrseqite := 4;  -- Alugado
    END CASE;

    rat_cdsitres := rw_crapenc.incasprp;
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
                            ,pr_dsvalite => ' '
                            ,pr_tab_crapras => pr_tab_crapras       --
                            ,pr_dscritic    => vr_dscritic);        -- Descricao do erro

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_risco_cooperado_pf');

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
                            ,pr_idorigem     => pr_idorigem     --> Origem da requisição
                            ,pr_nrdconta     => pr_nrdconta     --> Conta do associado
                            ,pr_tpctrato     => pr_tpctrato     --> Tipo do Rating
                            ,pr_nrctrato     => pr_nrctrato     --> Número do contrato de Rating
                            ,pr_vet_nrctrliq => vr_vet_nrctrliq --> Vetor de contratos a liquidar
                            ,pr_vlpreemp     => vr_vlpresta     --> Valor da parcela
                            ,pr_rw_crapdat   => pr_rw_crapdat   --> Calendário do movimento atual
                            ,pr_flgdcalc     => pr_flgdcalc     --> Flag para calcular sim ou não
                            ,pr_inusatab     => pr_inusatab     --> Indicador de utilização da tabela de juros
                            ,pr_vltotpre     => vr_vltotpre     --> Valor calculado da prestação
                            ,pr_dscritic     => vr_dscritic);

    -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_risco_cooperado_pf');

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

    rat_vlpreatv := vr_vltotpre;
    rat_vlparope := vr_vlpresta;
    rat_vlsalari := rw_crapttl.vlsalari;
    rat_vlrendim := rw_crapttl.vldrendi##1 + rw_crapttl.vldrendi##2 + rw_crapttl.vldrendi##3 +
                    rw_crapttl.vldrendi##4 + rw_crapttl.vldrendi##5 + rw_crapttl.vldrendi##6;
    rat_vlsalcje := vr_vlsalari;
    IF ((rw_crapttl.vlsalari +
         rw_crapttl.vldrendi##1 + rw_crapttl.vldrendi##2 +
         rw_crapttl.vldrendi##3 + rw_crapttl.vldrendi##4 +
         rw_crapttl.vldrendi##5 + rw_crapttl.vldrendi##6 +
         nvl(vr_vlsalari,0)) > 0) THEN
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
      vr_dsvalite := round(vr_vltotpre*100,2) || '% de comprometimento';
    ELSE
      vr_dsvalite := ' ';
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
                            ,pr_dsvalite => vr_dsvalite
                            ,pr_tab_crapras => pr_tab_crapras       --
                            ,pr_dscritic    => vr_dscritic);        -- Descricao do erro

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_risco_cooperado_pf');

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
                            ,pr_dsvalite => ' '
                            ,pr_tab_crapras => pr_tab_crapras       --
                            ,pr_dscritic    => vr_dscritic);        -- Descricao do erro

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_risco_cooperado_pf');

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
    pc_calcula_endividamento(pr_cdcooper   => pr_cdcooper     --> Código da Cooperativa
                            ,pr_cdagenci   => pr_cdagenci     --> Código da agência
                            ,pr_nrdcaixa   => pr_nrdcaixa     --> Número do caixa
                            ,pr_cdoperad   => pr_cdoperad     --> Código do operador
                            ,pr_rw_crapdat => pr_rw_crapdat   --> Vetor com dados de parâmetro (CRAPDAT)
                            ,pr_nrdconta   => pr_nrdconta     --> Conta do associado
                            ,pr_dsliquid   => vr_dsliquid     --> Lista de contratos a liquidar
                            ,pr_idseqttl   => pr_idseqttl     --> Sequencia de titularidade da conta
                            ,pr_idorigem   => pr_idorigem     --> Indicador da origem da chamada
                            ,pr_inusatab   => pr_inusatab     --> Indicador de utilização da tabela de juros
                            ,pr_vlutiliz   => vr_vlutiliz     --> Valor da dívida
                            ,pr_cdcritic   => vr_cdcritic     --> Critica encontrada no processo
                            ,pr_dscritic   => vr_dscritic);   --> Saída de erro

    -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_risco_cooperado_pf');

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

      --ler informações do emprestimo
      OPEN cr_crapepr(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctrato => pr_nrctrato);
      FETCH cr_crapepr INTO rw_crapepr2;
      IF vr_fcrawepr THEN
        rat_vlopeatu := rw_crawepr8.vlemprst;
      ELSE
        rat_vlopeatu := rw_crapprp6.vlctrbnd;
      END IF;
      -- se não localizou
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
          rat_vlopeatu := rw_craplim6.vllimite;
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
                                                ,pr_tab_central_risco => vr_tab_central_risco --> Informações da Central de Risco
                                                ,pr_tab_erro => pr_tab_erro  --> Tabela Erro
                                                ,pr_des_reto => pr_des_reto);

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_risco_cooperado_pf');

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
                                                ,pr_tab_central_risco => vr_tab_central_risco --> Informações da Central de Risco
                                                ,pr_tab_erro => pr_tab_erro  --> Tabela Erro
                                                ,pr_des_reto => pr_des_reto);

        -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_risco_cooperado_pf');

        IF pr_des_reto <> 'OK' THEN
          RETURN;
        END IF;

        -- se possuir valor, somar valor valor
        IF NVL(vr_tab_central_risco.vltotsfn,0) <> 0  THEN
          vr_vlendivi := nvl(vr_vlendivi,0) + vr_tab_central_risco.vltotsfn;
        ELSE
          -- Usar valor já calculado
          vr_vlendivi := nvl(vr_vlendivi,0) + nvl(vr_vlutiliz,0);
        END IF;
        /*-- Buscar primeiro registro      -- Alterado por: Renato Darosci - Supero - 30/04/2015
                                                  Não utilizar mais tabela de memória, apenas um record.
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

    rat_vlendivi := nvl(vr_vlendivi,0);
    rat_vlsldeve := nvl(vr_vlendivi,0);

    IF ((rw_crapttl.vlsalari    + rw_crapttl.vldrendi##1 +
         rw_crapttl.vldrendi##2 + rw_crapttl.vldrendi##3 +
         rw_crapttl.vldrendi##4 + rw_crapttl.vldrendi##5 +
         rw_crapttl.vldrendi##6 + nvl(vr_vlsalari,0)) > 0) THEN
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
      vr_dsvalite := round(vr_vlendivi,2) || ' vezes a renda bruta';
    ELSE
      vr_dsvalite := ' ';
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
                            ,pr_dsvalite => vr_dsvalite
                            ,pr_tab_crapras => pr_tab_crapras       --
                            ,pr_dscritic    => vr_dscritic);        -- Descricao do erro

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_risco_cooperado_pf');

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
      --ler informações do emprestimo
      OPEN cr_crapepr(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctrato => pr_nrctrato);
      FETCH cr_crapepr INTO rw_crapepr2;
      -- se não localizou
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

    -- se não foi passado tipo de contrado e não calcular
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

    vr_dsvalite := round(vr_vlendiv2,2) || ' vezes o valor de cotas';
    rat_vlslcota := nvl(rw_crapcot.vldcotas,0);
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
                            ,pr_dsvalite => vr_dsvalite
                            ,pr_tab_crapras => pr_tab_crapras       --
                            ,pr_dscritic    => vr_dscritic);        -- Descricao do erro

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_risco_cooperado_pf');

      -- Se retornou erro, deve abortar
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END IF;

    IF pr_flgdcalc = 1 THEN
      -- gerar classificação
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
      -- Retorno não OK
      pr_des_reto := 'NOK';
      -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 29/06/2018 - Chamado 660306
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
      -- Retorno não OK
      pr_des_reto := 'NOK';

      -- Montar descrição de erro não tratado
      vr_dscritic := 'Erro não tratado na RATI0001.pc_risco_cooperado_pf> '||sqlerrm;
      -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
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
                                    ,pr_rw_crapdat IN btch0001.rw_crapdat%TYPE  --> Vetor com dados de parâmetro (CRAPDAT)
                                    ,pr_tpctrato IN crapnrc.tpctrrat%TYPE  --> Tipo Contrato Rating
                                    ,pr_nrctrato IN crapnrc.nrctrrat%TYPE  --> Numero Contrato Rating
                                    ,pr_inusatab IN BOOLEAN                --> Indicador de utilização da tabela de juros
                                    ,pr_flgcriar IN INTEGER                --> Indicado se deve criar o rating
                                    ,pr_tab_crapras IN OUT typ_tab_crapras --> Tabela com os registros a serem processados
                                    ,pr_tab_erro OUT GENE0001.typ_tab_erro --> Tabela de retorno de erro
                                    ,pr_des_reto OUT VARCHAR2) IS          --> Ind. de retorno OK/NOK

  /* ..........................................................................

     Programa: pc_calcula_rating_fisica         Antigo: b1wgen0043.p/calcula_rating_fisica
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Odirlei Busana - AMcom
     Data    : Agosto/2014.                          Ultima Atualizacao: 28/06/2017

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  : Procedure para calular o rating para as pessoas fisicas.

     Alteracoes: 27/08/2014 - Conversão Progress -> Oracle - Odirlei (AMcom)

            10/05/2016 - Ajuste para utitlizar rowtype locais
              (Andrei  - RKAM).

                 28/06/2017 - Inclusão para setar o modulo de todas procedures da Package
                              ( Belli - Envolti - 28/06/2017 - Chamado 660306).

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
  -- Classificação e Nota do cooperado
  vr_notacoop NUMBER;
  vr_clascoop VARCHAR2(10);
  vr_idqualif NUMBER;
  ----------------- CURSOR ------------------

  rw_crawepr9 cr_crawepr%ROWTYPE;
  rw_crapprp7 cr_crapprp%ROWTYPE;
  rw_craplcr6 cr_craplcr%ROWTYPE;
  rw_craplim7 cr_craplim%ROWTYPE;

  BEGIN

    -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_calcula_rating_fisica');

    /* Para Risco Cooperado o calculo eh diferenciado */
    IF pr_tpctrato <> 0  AND
       pr_nrctrato <> 0  THEN
      /* REGISTROS NECESSARIOS */
      IF pr_tpctrato = 90   THEN  /* Emprestimo/Financiamento */

        --ler informações do emprestimo
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

        -- Ler Contratos de Limite de credito
      ELSIF pr_tpctrato = 3 THEN
            OPEN  cr_crawlim(pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_tpctrato => pr_tpctrato
                            ,pr_nrctrato => pr_nrctrato);
            FETCH cr_crawlim INTO rw_craplim7;
            IF    cr_crawlim%NOTFOUND THEN
                  CLOSE cr_crawlim;
                  OPEN  cr_craplim(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_tpctrato => pr_tpctrato
                                  ,pr_nrctrato => pr_nrctrato);
                  FETCH cr_craplim INTO rw_craplim7;
                  CLOSE cr_craplim;
            ELSE
                  CLOSE cr_crawlim;
            END   IF;

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
                          ,pr_rw_crapdat => pr_rw_crapdat  --> Vetor com dados de parâmetro (CRAPDAT)
                          ,pr_tpctrato => pr_tpctrato      --> Tipo Contrato Rating
                          ,pr_nrctrato => pr_nrctrato      --> Numero Contrato Rating
                          ,pr_inusatab => pr_inusatab      --> Indicador de utilização da tabela de juros
                          ,pr_flgcriar => pr_flgcriar      --> Indicado se deve criar o rating
                          ,pr_flgttris => FALSE            --> Indicado se deve carregar toda a crapris
                          ,pr_tab_crapras => pr_tab_crapras--> Tabela com os registros a serem processados
                          ,pr_notacoop => vr_notacoop      --> Retorna a nota da classificação
                          ,pr_clascoop => vr_clascoop      --> Retorna classificação
                          ,pr_tab_erro => pr_tab_erro      --> Tabela de retorno de erro
                          ,pr_des_reto => pr_des_reto );   --> Ind. de retorno OK/NOK

    -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_calcula_rating_fisica');

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

  vr_idqualif := fn_verifica_qualificacao(pr_nrdconta => pr_nrdconta,
                        pr_nrctremp => pr_nrctrato,
                        pr_idquapro => rw_crawepr9.idquapro,
                        pr_cdcooper => pr_cdcooper);

    IF pr_tpctrato = 90 THEN  /* Emprestimo / Financiamento */
      -- se encontrou registro na crawepr
      IF vr_fcrawepr THEN
        rat_cdquaope := rw_crawepr9.idquapro;
        rat_cdlincre := rw_crawepr9.cdlcremp;
        rat_cdmodali := rw_craplcr6.cdmodali;
        rat_cdsubmod := rw_craplcr6.cdsubmod;
        rat_dstpoper := rw_craplcr6.dsoperac;
        pc_natureza_operacao ( pr_tpctrato => pr_tpctrato          --> Tipo Contrato Rating
                              ,pr_idquapro => vr_idqualif          --> Numero Contrato Rating
                              ,pr_dsoperac => rw_craplcr6.dsoperac  --> Indicado se deve criar o rating
                              ,pr_cdcooper => pr_cdcooper          --> Código da cooperativa
                              ,pr_nrctrato => pr_nrctrato          --> Número do Contrato
                              ,pr_nrdconta => pr_nrdconta          --> Número da Conta
                              ,pr_nrseqite => vr_nrseqite          --> Valor da dívida
                              ,pr_dscritic => vr_dscritic);        --> Descricao do erro

        -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_calcula_rating_fisica');

        -- Se retornou erro
        IF vr_dscritic IS NOT NULL THEN
          raise vr_exc_erro;
        END IF;
      ELSE /* BNDES */
        rat_cdquaope := 1;
        rat_cdlincre := 0;
        rat_cdmodali := '';
        rat_cdsubmod := '';
        rat_dstpoper := 'FINANCIAMENTO';
        pc_natureza_operacao ( pr_tpctrato => pr_tpctrato          --> Tipo Contrato Rating
                              ,pr_idquapro => 1  /* Normal */      --> Numero Contrato Rating
                              ,pr_dsoperac => 'FINANCIAMENTO'      --> Indicado se deve criar o rating
                              ,pr_cdcooper => pr_cdcooper          --> Código da Cooperativa
                              ,pr_nrctrato => pr_nrctrato          --> Número do Contrato
                              ,pr_nrdconta => pr_nrdconta          --> Número da Conta
                              ,pr_nrseqite => vr_nrseqite          --> Valor da dívida
                              ,pr_dscritic => vr_dscritic);        --> Descricao do erro
        -- Se retornou erro
        IF vr_dscritic IS NOT NULL THEN
          raise vr_exc_erro;
        END IF;
      END IF;

    ELSE /* Cheque especial / Descontos */
      rat_cdquaope := 0;
      rat_cdlincre := 0;
      rat_cdmodali := '';
      rat_cdsubmod := '';
      if pr_tpctrato = 1 then
        rat_dstpoper := 'Limite de Credito';
      else
        rat_dstpoper := 'Limite de Desconto';
      end if;
      pc_natureza_operacao ( pr_tpctrato => pr_tpctrato          --> Tipo Contrato Rating
                            ,pr_idquapro => 0                    --> Numero Contrato Rating
                            ,pr_dsoperac => null                 --> Indicado se deve criar o rating
                            ,pr_cdcooper => pr_cdcooper          --> Código da Cooperativa
                            ,pr_nrctrato => pr_nrctrato          --> Número do Contrato
                            ,pr_nrdconta => pr_nrdconta          --> Número da Conta
                            ,pr_nrseqite => vr_nrseqite          --> Valor da dívida
                            ,pr_dscritic => vr_dscritic);        --> Descricao do erro

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_calcula_rating_fisica');

      -- Se retornou erro
      IF vr_dscritic IS NOT NULL THEN
        raise vr_exc_erro;
      END IF;
    END IF;

    rat_cdtpoper := pr_tpctrato;
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
                          ,pr_dsvalite => ' '
                          ,pr_tab_crapras => pr_tab_crapras       --
                          ,pr_dscritic    => vr_dscritic);        -- Descricao do erro

    -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_calcula_rating_fisica');

    -- Se retornou erro, deve abortar
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    /********************************************************************
     Item 2_2 - Garantia da operacao.
    ********************************************************************/

    IF pr_tpctrato = 90   THEN /* Emprestimo / Financiamento */
      vr_nrseqite := rw_crapprp7.nrgarope;
      rat_flgcjeco := rw_crapprp7.flgdocje;
    ELSE                         /* Cheque especial / Desconto */
      vr_nrseqite := rw_craplim7.nrgarope;
    END IF;

    rat_cdgarope := vr_nrseqite;
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
                          ,pr_dsvalite => ' '
                          ,pr_tab_crapras => pr_tab_crapras       --
                          ,pr_dscritic    => vr_dscritic);        -- Descricao do erro

    -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_calcula_rating_fisica');

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

    rat_cdliqgar := vr_nrseqite;
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
                          ,pr_dsvalite => vr_dsvalite
                          ,pr_tab_crapras => pr_tab_crapras       --
                          ,pr_dscritic    => vr_dscritic);        -- Descricao do erro

    -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_calcula_rating_fisica');

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
        rat_qtpreope := rw_crawepr9.qtpreemp;
      ELSE /* BNDES */
        vr_qtdiapra := rw_crapprp7.qtparbnd * 30; /* Sempre vezes 30 */
        rat_qtpreope := rw_crapprp7.qtparbnd;
      END IF;
    ELSE                          /* Cheque especial / Desconto */
      vr_qtdiapra := rw_craplim7.qtdiavig;
      rat_qtpreope := rw_craplim7.qtdiavig / 30;
    END IF;

    -- definir sequencial
    IF vr_qtdiapra <= 720   THEN
      vr_nrseqite := 1;
    ELSIF  vr_qtdiapra <= 1440  THEN
      vr_nrseqite := 2;
    ELSE
      vr_nrseqite := 3;
    END IF;

    vr_dsvalite := vr_qtdiapra || ' dias de prazo da operacao';
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
                          ,pr_dsvalite => vr_dsvalite
                          ,pr_tab_crapras => pr_tab_crapras       --
                          ,pr_dscritic    => vr_dscritic);        -- Descricao do erro

    -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'RATI0001.pc_calcula_rating_fisica');

    -- Se retornou erro, deve abortar
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Retorno OK
    pr_des_reto := 'OK';
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK
      pr_des_reto := 'NOK';
      -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 29/06/2018 - Chamado 660306
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
      -- Retorno não OK
      pr_des_reto := 'NOK';
      -- Montar descrição de erro não tratado
      vr_dscritic := 'Erro não tratado na RATI0001.pc_calcula_rating_fisica> '||sqlerrm;
      -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
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
                             ,pr_flgerlog IN VARCHAR2                                        --> Identificador de geração de log
                             ,pr_tab_rating_sing       IN RATI0001.typ_tab_crapras           --> Registros gravados para rating singular
                             ,pr_flghisto IN INTEGER                                         --> Indicador se deve gerar historico
                             ----- OUT ----
                             ,pr_tab_impress_coop     OUT RATI0001.typ_tab_impress_coop     --> Registro impressão da Cooperado
                             ,pr_tab_impress_rating   OUT RATI0001.typ_tab_impress_rating   --> Registro itens do Rating
                             ,pr_tab_impress_risco_cl OUT RATI0001.typ_tab_impress_risco    --> Registro Nota e risco do cooperado naquele Rating - PROVISAOCL
                             ,pr_tab_impress_risco_tl OUT RATI0001.typ_tab_impress_risco    --> Registro Nota e risco do cooperado naquele Rating - PROVISAOTL
                             ,pr_tab_impress_assina   OUT RATI0001.typ_tab_impress_assina   --> Assinatura na impressao do Rating
                             ,pr_tab_efetivacao       OUT RATI0001.typ_tab_efetivacao       --> Registro dos itens da efetivação
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
     Data    : Agosto/2014.                          Ultima Atualizacao: 28/06/2017

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  : Procedure para calcular o rating do associado e gravar os registros na
                 crapras.

     Alteracoes: 27/08/2014 - Conversão Progress -> Oracle - Odirlei (AMcom)

         29/03/2016 - Replicar manutenção realizada no progress SD352945 (Odirlei-AMcom)

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
    -- Vetor com dados de parâmetro (CRAPDAT)
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

    -- Efetivação ou não do rating
    vr_flgefeti INTEGER;

    rw_crapnrc3 cr_crapnrc%ROWTYPE;

    -- Index temptable
    vr_idxrisco PLS_INTEGER;

    -- verifica se deve atualizar crapass
    vr_flgatuas BOOLEAN;


  BEGIN

    -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
    GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'RATI0001.pc_calcula_rating');

    --Limpeza das variaveis utilizadas para salvar informacoes do rating
    rat_dtadmiss := null;
    rat_qtmaxatr := null;
    rat_flgreneg := null;
    rat_dtadmemp := null;
    rat_cdnatocp := 0;
    rat_qtresext := null;
    rat_vlnegext := null;
    rat_flgresre := null;
    rat_qtadidep := null;
    rat_qtchqesp := null;
    rat_qtdevalo := null;
    rat_qtdevald := null;
    rat_cdsitres := 0;
    rat_vlpreatv := null;
    rat_vlsalari := 0;
    rat_vlrendim := 0;
    rat_vlsalcje := 0;
    rat_vlendivi := null;
    rat_vlbemtit := null;
    rat_flgcjeco := null;
    rat_vlbemcje := null;
    rat_vlsldeve := null;
    rat_vlopeatu := null;
    rat_vlslcota := 0;
    rat_cdquaope := null;
    rat_cdtpoper := 0;
    rat_cdlincre := null;
    rat_cdmodali := null;
    rat_cdsubmod := null;
    rat_cdgarope := null;
    rat_cdliqgar := null;
    rat_qtpreope := null;
    rat_dtfunemp := null;
    rat_cdseteco := null;
    rat_dtprisoc := null;
    rat_prfatcli := null;
    rat_vlmedfat := null;
    rat_vlbemavt := null;
    rat_vlbemsoc := null;
    rat_vlparope := null;
    rat_cdperemp := null;
    rat_dstpoper := null;
    vr_flghisto := pr_flghisto;
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
    -- se não encontrar gerar critica
    IF cr_crapass%NOTFOUND THEN
      vr_dscritic := null;
      vr_cdcritic := 9; -- Socio nao encontrado
      raise vr_exc_erro;
    END IF;

    -- Busca do calendário
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
    -- Se a primeira posição do campo dstextab for diferente de zero
    vr_inusatab := SUBSTR(vr_dstextab,1,1) != '0';

    -- Verifica se tem que criar Rating
    IF pr_flgcriar = 1 THEN

    vr_flgatuas := TRUE;

      -- Verificar se o Rating tem que ser criado.
      pc_verifica_criacao (pr_cdcooper => pr_cdcooper    --> Codigo Cooperativa
                          ,pr_cdagenci => 0              --> Codigo Agencia
                          ,pr_nrdcaixa => 0              --> Numero Caixa
                          ,pr_cdoperad => pr_cdoperad    --> Codigo Operador
                          ,pr_rw_crapdat => rw_crapdat--> Vetor com dados de parâmetro (CRAPDAT)
                          ,pr_nrdconta => pr_nrdconta    --> Numero da Conta
                          ,pr_tpctrato => pr_tpctrato    --> Tipo Contrato Rating
                          ,pr_nrctrato => pr_nrctrato    --> Numero Contrato Rating
                          ,pr_idseqttl => pr_idseqttl    --> Sequencial do Titular
                          ,pr_idorigem => pr_idorigem    --> Identificador Origem
                          ,pr_inusatab => vr_inusatab    --> Indicador de utilização da tabela de juros
                          ,pr_flgcriar => pr_flgcriar    --> Indicado se deve criar o rating
                          ,pr_tab_erro => pr_tab_erro    --> Tabela de retorno de erro
                          ,pr_des_reto => pr_des_reto ); --> Ind. de retorno OK/NOK

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'RATI0001.pc_calcula_rating');

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
                             ,pr_rw_crapdat      => rw_crapdat   --> Vetor com dados de parâmetro (CRAPDAT)
                             ,pr_tpctrato        => pr_tpctrato  --> Tipo Contrato Rating
                             ,pr_nrctrato        => pr_nrctrato  --> Numero Contrato Rating
                             ,pr_inusatab        => vr_inusatab  --> Indicador de utilização da tabela de juros
                             ,pr_flgcriar        => pr_flgcriar  --> Indicado se deve criar o rating
                             ,pr_tab_rating_sing => pr_tab_rating_sing --> Tabela com os registros a serem processados
                             ,pr_tab_crapras     => pr_tab_crapras     --> Tabela com os registros a serem processados
                             ,pr_vlutiliz        => vr_vlutiliz        --> Valor da dívida
                             ,pr_dscritic        => vr_dscritic);      --> Saída de erros

        -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
        GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'RATI0001.pc_calcula_rating');

        -- Em caso de erro
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      ELSE
        -- Chamaremos rotinas específicas conforme o tipo da pessoa
        IF rw_crapass.inpessoa = 1 THEN
          -- Fisica
          pc_calcula_rating_fisica(pr_cdcooper => pr_cdcooper       --> Codigo Cooperativa
                                  ,pr_cdagenci => pr_cdagenci       --> Codigo Agencia
                                  ,pr_nrdcaixa => pr_nrdcaixa       --> Numero Caixa
                                  ,pr_cdoperad => pr_cdoperad       --> Codigo Operador
                                  ,pr_idorigem => pr_idorigem       --> Identificador Origem
                                  ,pr_nrdconta => pr_nrdconta       --> Numero da Conta
                                  ,pr_idseqttl => pr_idseqttl       --> Sequencial do Titular
                                  ,pr_rw_crapdat => rw_crapdat      --> Vetor com dados de parâmetro (CRAPDAT)
                                  ,pr_tpctrato => pr_tpctrato       --> Tipo Contrato Rating
                                  ,pr_nrctrato => pr_nrctrato       --> Numero Contrato Rating
                                  ,pr_inusatab => vr_inusatab       --> Indicador de utilização da tabela de juros
                                  ,pr_flgcriar => pr_flgcriar       --> Indicado se deve criar o rating
                                  ,pr_tab_crapras => pr_tab_crapras --> Tabela com os registros a serem processados
                                  ,pr_tab_erro => pr_tab_erro       --> Tabela de retorno de erro
                                  ,pr_des_reto => pr_des_reto);     --> Ind. de retorno OK/NOK

          -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
          GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'RATI0001.pc_calcula_rating');

        ELSE
          -- Juridica
          pc_calcula_rating_juridica(pr_cdcooper => pr_cdcooper       --> Codigo Cooperativa
                                    ,pr_cdagenci => pr_cdagenci       --> Codigo Agencia
                                    ,pr_nrdcaixa => pr_nrdcaixa       --> Numero Caixa
                                    ,pr_cdoperad => pr_cdoperad       --> Codigo Operador
                                    ,pr_idorigem => pr_idorigem       --> Identificador Origem
                                    ,pr_nrdconta => pr_nrdconta       --> Numero da Conta
                                    ,pr_idseqttl => pr_idseqttl       --> Sequencial do Titular
                                    ,pr_rw_crapdat => rw_crapdat      --> Vetor com dados de parâmetro (CRAPDAT)
                                    ,pr_tpctrato => pr_tpctrato       --> Tipo Contrato Rating
                                    ,pr_nrctrato => pr_nrctrato       --> Numero Contrato Rating
                                    ,pr_inusatab => vr_inusatab       --> Indicador de utilização da tabela de juros
                                    ,pr_flgcriar => pr_flgcriar       --> Indicado se deve criar o rating
                                    ,pr_tab_crapras => pr_tab_crapras --> Tabela com os registros a serem processados
                                    ,pr_tab_erro => pr_tab_erro       --> Tabela de retorno de erro
                                    ,pr_des_reto => pr_des_reto);     --> Ind. de retorno OK/NOK

          -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
          GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'RATI0001.pc_calcula_rating');

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
                              ,pr_cdagenci    => pr_cdagenci          --> Código da agência
                              ,pr_nrdcaixa    => pr_nrdcaixa          --> Número do caixa
                              ,pr_cdoperad    => pr_cdoperad          --> Código do operador
                              ,pr_dtmvtolt    => rw_crapdat.dtmvtolt  --> Data do movimento atual
                              ,pr_nrdconta    => pr_nrdconta          --> Conta do associado
                              ,pr_tpctrato    => pr_tpctrato          --> Tipo do Rating
                              ,pr_nrctrato    => pr_nrctrato          --> Número do contrato de Rating
                              ,pr_flgcriar    => pr_flgcriar          --> Flag para criação ou não do arquivo
                              ,pr_flgcalcu    => pr_flgcalcu          --> Flag para calculo ou não
                              ,pr_idseqttl    => pr_idseqttl          --> Sq do titular da conta
                              ,pr_idorigem    => pr_idorigem          --> Indicador da origem da chamada
                              ,pr_nmdatela    => pr_nmdatela          --> Nome da tela conectada
                              ,pr_flgerlog    => pr_flgerlog          --> Gerar log S/N
                              ,pr_tab_crapras => pr_tab_crapras       --> Interna da BO, para o calculo do Rating
                              ,pr_tab_impress_coop     => pr_tab_impress_coop     --> Registro impressão da Cooperado
                              ,pr_tab_impress_rating   => pr_tab_impress_rating   --> Registro itens do Rating
                              ,pr_tab_impress_risco_cl => pr_tab_impress_risco_cl --> Registro Nota e risco do cooperado naquele Rating - PROVISAOCL
                              ,pr_tab_impress_risco_tl => pr_tab_impress_risco_tl --> Registro Nota e risco do cooperado naquele Rating - PROVISAOTL
                              ,pr_tab_impress_assina   => pr_tab_impress_assina   --> Assinatura na impressao do Rating
                              ,pr_tab_efetivacao       => pr_tab_efetivacao       --> Registro dos itens da efetivação
                              ,pr_tab_erro             => pr_tab_erro             --> Tabela de retorno de erro
                              ,pr_des_reto             => pr_des_reto);           --> Indicador erro IS

    -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
    GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'RATI0001.pc_calcula_rating');

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
             -- No caso de erro de programa gravar tabela especifica de log - 29/06/2018 - Chamado 660306
             CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
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
             -- No caso de erro de programa gravar tabela especifica de log - 29/06/2018 - Chamado 660306
             CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
             vr_dscritic := 'Nao foi possivel atualizar associado: '|| SQLERRM;
             CLOSE cr_crapass_lock;
             RAISE vr_exc_erro;
         END;

    END IF;
    END IF; -- Fim IF vr_flgatuas

    -- Se está setada a criação
    IF pr_flgcriar = 1 THEN
    IF vr_vlutiliz is null and wglb_vlutiliz is not null then
        vr_vlutiliz := wglb_vlutiliz;
      end if;

      -- Testar informações necessárias nas tabelas
      IF pr_tab_impress_risco_cl.COUNT = 0 THEN
        vr_dscritic := 'Risco da operacao nao encontrado.';
        RAISE vr_exc_erro;
      END IF;
      -- Testar informações necessárias nas tabelas
      IF pr_tab_impress_risco_tl.COUNT = 0 THEN
        vr_dscritic := 'Risco do cooperado nao encontrado.';
        RAISE vr_exc_erro;
      END IF;
      -- Busca do rating para atualização / criação
      OPEN cr_crapnrc(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_tpctrrat => pr_tpctrato
                     ,pr_nrctrrat => pr_nrctrato);
      FETCH cr_crapnrc
       INTO rw_crapnrc3;
      -- Se não existir
      IF cr_crapnrc%NOTFOUND THEN
        CLOSE cr_crapnrc;
        -- Então devemos criá-los
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
                             ,1 -- Operação ativa
                             ,pr_tab_impress_risco_cl(1).dsdrisco
                             ,rw_crapdat.dtmvtolt
                             ,pr_cdoperad
                             ,pr_tab_impress_risco_cl(1).vlrtotal
                             ,vr_vlutiliz -- Valor utilizado
                             ,pr_tab_impress_risco_tl(1).vlrtotal
                             ,pr_tab_impress_risco_tl(1).dsdrisco);
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 29/06/2018 - Chamado 660306
            CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
            vr_dscritic := 'Erro ao criar crapnrc: '||SQLERRM;
            RAISE vr_exc_erro;
        END;
      ELSE
        CLOSE cr_crapnrc;
        -- Atualizar a informação
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
            -- No caso de erro de programa gravar tabela especifica de log - 29/06/2018 - Chamado 660306
            CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
            vr_dscritic := 'Erro ao atualizar crapnrc: '||SQLERRM;
            RAISE vr_exc_erro;
        END;
      END IF;
      -- Verifica se tem que efetivar
      pc_verifica_efetivacao(pr_cdcooper  => pr_cdcooper   --> Cooperativa conectada
                            ,pr_cdagenci  => 0             --> Código da agência
                            ,pr_nrdcaixa  => 0             --> Número do caixa
                            ,pr_nrdconta  => pr_nrdconta   --> Conta do associado
                            ,pr_nrnotrat  => pr_tab_impress_risco_cl(1).vlrtotal   --> Nota atingida na soma dos itens do rating.
                            ,pr_vlutiliz  => vr_vlutiliz   --> Valor utilizado para gravação
                            ,pr_flgefeti  => vr_flgefeti   --> Flag do resultado da efetivação do Rating
                            ,pr_tab_erro  => pr_tab_erro   --> Tabela de retorno de erro
                            ,pr_des_reto  => pr_des_reto); --> Indicador erro

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'RATI0001.pc_calcula_rating');

      -- Em caso de erro
      IF pr_des_reto <> 'OK' THEN
        -- Sair
        RAISE vr_exc_erro;
      END IF;
      -- Se tiver que efetivar
      IF vr_flgefeti = 1 THEN
        -- Chamar o processo de efetivação do Rating
        pc_efetivar_rating(pr_cdcooper   => pr_cdcooper           --> Cooperativa conectada
                          ,pr_nrdconta   => pr_nrdconta           --> Conta do associado
                          ,pr_tpctrato   => 0                     --> Tipo do Rating
                          ,pr_nrctrato   => 0                     --> Número do contrato de Rating
                          ,pr_cdoperad   => pr_cdoperad           --> Código do operador
                          ,pr_dtmvtolt   => rw_crapdat.dtmvtolt   --> Data do movimento atual
                          ,pr_vlutiliz   => vr_vlutiliz           --> Valor utilizado para gravação
                          ,pr_flgatual   => TRUE                  --> Flag para efetuar ou não a atualização
                          ,pr_tab_efetivacao => pr_tab_efetivacao --> Registro de efetivação
                          ,pr_tab_ratings    => pr_tab_ratings    --> Registro com os ratings do associado
                          ,pr_tab_erro       => pr_tab_erro       --> Tabela de retorno de erro
                          ,pr_des_reto       => pr_des_reto);     --> Indicador erro

        -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
        GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'RATI0001.pc_calcula_rating');

        -- No Progress não é validado o retorno
        ---- Em caso de erro
        --IF pr_des_reto <> 'OK' THEN
        --  -- Sair
        --  RAISE vr_exc_erro;
        --END IF;
      END IF;
      if nvl(vr_flghisto,1) = 1 then
        pc_grava_his_crapnrc2(pr_cdcooper => pr_cdcooper
                            , pr_nrdconta => pr_nrdconta
                            , pr_nrctrrat => pr_nrctrato
                            , pr_tpctrrat => pr_tpctrato
                            , pr_indrisco => pr_tab_impress_risco_cl(1).dsdrisco
                            , pr_dtmvtolt => rw_crapdat.dtmvtolt
                            , pr_cdoperad => pr_cdoperad
                            , pr_nrnotrat => pr_tab_impress_risco_cl(1).vlrtotal
                            , pr_vlutlrat => vr_vlutiliz
                            , pr_nrnotatl => pr_tab_impress_risco_tl(1).vlrtotal
                            , pr_inrisctl => pr_tab_impress_risco_tl(1).dsdrisco
                            , pr_dtadmiss => rat_dtadmiss
                            , pr_qtmaxatr => rat_qtmaxatr
                            , pr_flgreneg => rat_flgreneg
                            , pr_dtadmemp => rat_dtadmemp
                            , pr_cdnatocp => rat_cdnatocp
                            , pr_qtresext => rat_qtresext
                            , pr_vlnegext => rat_vlnegext
                            , pr_flgresre => rat_flgresre
                            , pr_qtadidep => rat_qtadidep
                            , pr_qtchqesp => rat_qtchqesp
                            , pr_qtdevalo => rat_qtdevalo
                            , pr_qtdevald => rat_qtdevald
                            , pr_cdsitres => rat_cdsitres
                            , pr_vlpreatv => rat_vlpreatv
                            , pr_vlsalari => rat_vlsalari
                            , pr_vlrendim => rat_vlrendim
                            , pr_vlsalcje => rat_vlsalcje
                            , pr_vlendivi => rat_vlendivi
                            , pr_vlbemtit => rat_vlbemtit
                            , pr_flgcjeco => rat_flgcjeco
                            , pr_vlbemcje => rat_vlbemcje
                            , pr_vlsldeve => rat_vlsldeve
                            , pr_vlopeatu => rat_vlopeatu
                            , pr_vlslcota => rat_vlslcota
                            , pr_cdquaope => rat_cdquaope
                            , pr_cdtpoper => rat_cdtpoper
                            , pr_cdlincre => rat_cdlincre
                            , pr_cdmodali => rat_cdmodali
                            , pr_cdsubmod => rat_cdsubmod
                            , pr_cdgarope => rat_cdgarope
                            , pr_cdliqgar => rat_cdliqgar
                            , pr_qtpreope => rat_qtpreope
                            , pr_dtfunemp => rat_dtfunemp
                            , pr_cdseteco => rat_cdseteco
                            , pr_dtprisoc => rat_dtprisoc
                            , pr_prfatcli => rat_prfatcli
                            , pr_vlmedfat => rat_vlmedfat
                            , pr_vlbemavt => rat_vlbemavt
                            , pr_vlbemsoc => rat_vlbemsoc
                            , pr_vlparope => rat_vlparope
                            , pr_cdperemp => rat_cdperemp
                            , pr_dstpoper => rat_dstpoper
                            , pr_cdcritic => vr_cdcritic
                            , pr_dscritic => vr_dscritic);
      end if;
    ELSE
      if nvl(vr_flghisto,1) = 1 then
        pc_grava_his_crapnrc2(pr_cdcooper => pr_cdcooper
                           , pr_nrdconta => pr_nrdconta
                           , pr_nrctrrat => pr_nrctrato
                           , pr_tpctrrat => pr_tpctrato
                           , pr_indrisco => pr_tab_impress_risco_cl(1).dsdrisco
                           , pr_dtmvtolt => rw_crapdat.dtmvtolt
                           , pr_cdoperad => pr_cdoperad
                           , pr_nrnotrat => pr_tab_impress_risco_cl(1).vlrtotal
                           , pr_vlutlrat => vr_vlutiliz
                           , pr_nrnotatl => pr_tab_impress_risco_tl(1).vlrtotal
                           , pr_inrisctl => pr_tab_impress_risco_tl(1).dsdrisco
                            , pr_dtadmiss => rat_dtadmiss
                            , pr_qtmaxatr => rat_qtmaxatr
                            , pr_flgreneg => rat_flgreneg
                            , pr_dtadmemp => rat_dtadmemp
                            , pr_cdnatocp => rat_cdnatocp
                            , pr_qtresext => rat_qtresext
                            , pr_vlnegext => rat_vlnegext
                            , pr_flgresre => rat_flgresre
                            , pr_qtadidep => rat_qtadidep
                            , pr_qtchqesp => rat_qtchqesp
                            , pr_qtdevalo => rat_qtdevalo
                            , pr_qtdevald => rat_qtdevald
                            , pr_cdsitres => rat_cdsitres
                            , pr_vlpreatv => rat_vlpreatv
                            , pr_vlsalari => rat_vlsalari
                            , pr_vlrendim => rat_vlrendim
                            , pr_vlsalcje => rat_vlsalcje
                            , pr_vlendivi => rat_vlendivi
                            , pr_vlbemtit => rat_vlbemtit
                            , pr_flgcjeco => rat_flgcjeco
                            , pr_vlbemcje => rat_vlbemcje
                            , pr_vlsldeve => rat_vlsldeve
                            , pr_vlopeatu => rat_vlopeatu
                            , pr_vlslcota => rat_vlslcota
                            , pr_cdquaope => rat_cdquaope
                            , pr_cdtpoper => rat_cdtpoper
                            , pr_cdlincre => rat_cdlincre
                            , pr_cdmodali => rat_cdmodali
                            , pr_cdsubmod => rat_cdsubmod
                            , pr_cdgarope => rat_cdgarope
                            , pr_cdliqgar => rat_cdliqgar
                            , pr_qtpreope => rat_qtpreope
                            , pr_dtfunemp => rat_dtfunemp
                            , pr_cdseteco => rat_cdseteco
                            , pr_dtprisoc => rat_dtprisoc
                            , pr_prfatcli => rat_prfatcli
                            , pr_vlmedfat => rat_vlmedfat
                            , pr_vlbemavt => rat_vlbemavt
                            , pr_vlbemsoc => rat_vlbemsoc
                            , pr_vlparope => rat_vlparope
                            , pr_cdperemp => rat_cdperemp
                            , pr_dstpoper => rat_dstpoper
                           , pr_cdcritic => vr_cdcritic
                           , pr_dscritic => vr_dscritic);
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
    -- Se chegamos neste ponto, não houve erro
    pr_des_reto := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK
      pr_des_reto := 'NOK';

      -- Se ainda não tem registro de erro, criar com a critica
      IF pr_tab_erro.COUNT = 0 THEN
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
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
      -- No caso de erro de programa gravar tabela especifica de log - 29/06/2018 - Chamado 660306
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
      -- Retorno não OK
      pr_des_reto := 'NOK';
      -- Montar descrição de erro não tratado
      vr_dscritic := 'Erro não tratado na RATI0001.pc_calcula_rating> '||sqlerrm;
      -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
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
                                 ,pr_rw_crapdat  IN btch0001.rw_crapdat%TYPE    --> Vetor com dados de parâmetro (CRAPDAT)
                                 ,pr_nrdconta    IN crapass.nrdconta%TYPE       --> Numero da Conta
                                 ,pr_idseqttl    IN crapttl.idseqttl%TYPE       --> Sequencia de titularidade da conta
                                 ,pr_idorigem    IN INTEGER                     --> Indicador da origem da chamada
                                 ,pr_nmdatela    IN craptel.nmdatela%TYPE       --> Nome da tela
                                 ,pr_flgerlog    IN VARCHAR2                    --> Identificador de geração de log
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
     Data    : Abril/2015.                          Ultima Atualizacao: 28/06/2017

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  :  Verifica se alguma operacao de Credito esta ativa.
                  Limite de credito, descontos e emprestimo.
                  Usada para ver se o Rating antigo pode ser desativado..

     Alteracoes: 13/04/2015 - Conversão Progress -> Oracle - Odirlei (AMcom)

                 28/06/2017 - Inclusão para setar o modulo de todas procedures da Package
                              ( Belli - Envolti - 28/06/2017 - Chamado 660306).


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
    -- Vetor com dados de parâmetro (CRAPDAT)
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

    -- Efetivação ou não do rating
    vr_flgefeti INTEGER;

  BEGIN

    -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
    GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'RATI0001.pc_verifica_operacoes');

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

    -- Se chegamos neste ponto, não houve erro
    pr_des_reto := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK
      pr_des_reto := 'NOK';

      -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
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
      -- No caso de erro de programa gravar tabela especifica de log - 29/06/2018 - Chamado 660306
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
      -- Retorno não OK
      pr_des_reto := 'NOK';
      -- Montar descrição de erro não tratado
      vr_dscritic := 'Erro não tratado na RATI0001.pc_verifica_operacoes> '||sqlerrm;
      -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
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
     Data    : Maio/2016.                          Ultima Atualizacao: 28/06/2017

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  :  Procedure para atualizar ratings efetivos. Se existir algum rating com nota
                  pior do que este entao efetiva o de pior nota.

     Alteracoes:

                 28/06/2017 - Inclusão para setar o modulo de todas procedures da Package
                              ( Belli - Envolti - 28/06/2017 - Chamado 660306).


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
    vr_flgcriar := pr_flgcriar;

    -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
    GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'RATI0001.pc_atualiza_rating');

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

    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
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
                              ,pr_flgerlog => pr_flgerlog   --> Identificador de geração de log
                              ,pr_tab_rating_sing      => vr_tab_rating_sing      --> Registros gravados para rati
                              ,pr_flghisto => vr_flghisto
                              ,pr_tab_impress_coop     => vr_tab_impress_coop     --> Registro impressão da Cooper
                              ,pr_tab_impress_rating   => vr_tab_impress_rating   --> Registro itens do Rating
                              ,pr_tab_impress_risco_cl => vr_tab_impress_risco_cl --> Registro Nota e risco do coo
                              ,pr_tab_impress_risco_tl => pr_tab_impress_risco_tl --> Registro Nota e risco do coo
                              ,pr_tab_impress_assina   => vr_tab_impress_assina   --> Assinatura na impressao do R
                              ,pr_tab_efetivacao       => pr_tab_efetivacao       --> Registro dos itens da efetiv
                              ,pr_tab_ratings          => vr_tab_ratings          --> Informacoes com os Ratings d
                              ,pr_tab_crapras          => vr_tab_crapras          --> Tabela com os registros proc
                              ,pr_tab_erro             => vr_tab_erro             --> Tabela de retorno de erro
                              ,pr_des_reto             => vr_des_erro);           --> Ind. de retorno OK/NOK

    -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
    GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'RATI0001.pc_atualiza_rating');

    -- Em caso de erro
    IF pr_des_reto <> 'OK' THEN

      --Se não tem erro na tabela
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

    -- Chamar o processo de efetivação do Rating
    pc_efetivar_rating(pr_cdcooper   => pr_cdcooper           --> Cooperativa conectada
                      ,pr_nrdconta   => pr_nrdconta           --> Conta do associado
                      ,pr_tpctrato   => 0                     --> Tipo do Rating
                      ,pr_nrctrato   => 0                     --> Número do contrato de Rating
                      ,pr_cdoperad   => pr_cdoperad           --> Código do operador
                      ,pr_dtmvtolt   => rw_crapdat.dtmvtolt   --> Data do movimento atual
                      ,pr_vlutiliz   => rw_crapnrc_efe.vlutlrat   --> Valor utilizado para gravação
                      ,pr_flgatual   => FALSE                 --> Flag para efetuar ou não a atualização
                      ,pr_tab_efetivacao => pr_tab_efetivacao --> Registro de efetivação
                      ,pr_tab_ratings    => vr_tab_ratings    --> Registro com os ratings do associado
                      ,pr_tab_erro       => pr_tab_erro       --> Tabela de retorno de erro
                      ,pr_des_reto       => pr_des_reto);     --> Indicador erro

    -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
    GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'RATI0001.pc_atualiza_rating');

    -- Comentado pois no Progress não é testado o retorno
    ---- Em caso de erro
    --IF pr_des_reto <> 'OK' THEN
    --
    --  --Se não tem erro na tabela
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

    -- Se chegamos neste ponto, não houve erro
    pr_des_reto := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK
      pr_des_reto := 'NOK';

      -- Se ainda não tem registro de erro, criar com a critica
      IF pr_tab_erro.COUNT = 0 THEN
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
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
      -- No caso de erro de programa gravar tabela especifica de log - 29/06/2018 - Chamado 660306
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
      -- Retorno não OK
      pr_des_reto := 'NOK';

      -- Montar descrição de erro não tratado
      vr_dscritic := 'Erro não tratado na RATI0001.pc_atualiza_rating> '||sqlerrm;

      -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
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
                           ,pr_nrnotrat OUT crapnrc.nrnotrat%TYPE                          --> Número da nota
                           ,pr_tab_erro OUT GENE0001.typ_tab_erro                          --> Tabela de retorno de erro
                           ,pr_des_reto OUT VARCHAR2                                       --> Ind. de retorno OK/NOK
                           ) IS


  /* ..........................................................................

     Programa: pc_proc_calcula         Antigo: b1wgen0043.p/proc_calcula
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Andrei - RKAM
     Data    : Maio/2016                          Ultima Atualizacao: 28/06/2017

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  : Realiza calculo do rating, alteracao solicitada pela ATURAT

     Alteracoes:

                 28/06/2017 - Inclusão para setar o modulo de todas procedures da Package
                              ( Belli - Envolti - 28/06/2017 - Chamado 660306).


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

    -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
    GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'RATI0001.pc_proc_calcula');

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
                                ,pr_flgerlog => 'N'           --> Identificador de geração de log
                                ,pr_tab_rating_sing      => pr_tab_rating_sing      --> Registros gravados para rati
                                ,pr_flghisto => vr_flgcriar
                                ,pr_tab_impress_coop     => vr_tab_impress_coop     --> Registro impressão da Cooper
                                ,pr_tab_impress_rating   => vr_tab_impress_rating   --> Registro itens do Rating
                                ,pr_tab_impress_risco_cl => vr_tab_impress_risco_cl --> Registro Nota e risco do coo
                                ,pr_tab_impress_risco_tl => pr_tab_impress_risco_tl --> Registro Nota e risco do coo
                                ,pr_tab_impress_assina   => vr_tab_impress_assina   --> Assinatura na impressao do R
                                ,pr_tab_efetivacao       => vr_tab_efetivacao       --> Registro dos itens da efetiv
                                ,pr_tab_ratings          => vr_tab_ratings          --> Informacoes com os Ratings d
                                ,pr_tab_crapras          => vr_tab_crapras          --> Tabela com os registros proc
                                ,pr_tab_erro             => vr_tab_erro             --> Tabela de retorno de erro
                                ,pr_des_reto             => vr_des_erro);           --> Ind. de retorno OK/NOK

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'RATI0001.pc_proc_calcula');

      -- Em caso de erro
      IF pr_des_reto <> 'OK' THEN

        --Se não tem erro na tabela
        IF pr_tab_erro.COUNT = 0 THEN
          vr_cdcritic:= 0;
          vr_dscritic:= 'Erro ao calcular rating.';
        END IF;

        -- Sair
        RAISE vr_exc_erro;

      END IF;


    ELSE

      IF pr_flgcriar = 1 THEN
        vr_flghisto := 0;

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

        -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
        GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'RATI0001.pc_proc_calcula');


        -- Em caso de erro
        IF pr_des_reto <> 'OK' THEN

          --Se não tem erro na tabela
          IF pr_tab_erro.COUNT = 0 THEN
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro ao atualizar rating.';
          END IF;

          -- Sair
          RAISE vr_exc_erro;

        END IF;

      END IF;

      vr_flgcriar := pr_flgcriar;
      vr_flghisto := pr_flgcriar;
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
                                ,pr_flgerlog => 'N'           --> Identificador de geração de log
                                ,pr_tab_rating_sing      => pr_tab_rating_sing      --> Registros gravados para rating singular
                                ,pr_flghisto => vr_flgcriar
                                ,pr_tab_impress_coop     => vr_tab_impress_coop     --> Registro impressão da Cooperado
                                ,pr_tab_impress_rating   => vr_tab_impress_rating   --> Registro itens do Rating
                                ,pr_tab_impress_risco_cl => vr_tab_impress_risco_cl --> Registro Nota e risco do cooperado naquele Rating - PROVISAOCL
                                ,pr_tab_impress_risco_tl => pr_tab_impress_risco_tl --> Registro Nota e risco do cooperado naquele Rating - PROVISAOTL
                                ,pr_tab_impress_assina   => vr_tab_impress_assina   --> Assinatura na impressao do Rating
                                ,pr_tab_efetivacao       => vr_tab_efetivacao       --> Registro dos itens da efetivação
                                ,pr_tab_ratings          => vr_tab_ratings          --> Informacoes com os Ratings do Cooperado
                                ,pr_tab_crapras          => vr_tab_crapras          --> Tabela com os registros processados
                                ,pr_tab_erro             => vr_tab_erro             --> Tabela de retorno de erro
                                ,pr_des_reto             => vr_des_erro);           --> Ind. de retorno OK/NOK)

      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'RATI0001.pc_proc_calcula');

      -- Em caso de erro
      IF pr_des_reto <> 'OK' THEN

        --Se não tem erro na tabela
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

    -- Se chegamos neste ponto, não houve erro
    pr_des_reto := 'OK';


  EXCEPTION

    WHEN vr_exc_erro THEN
      -- Retorno não OK
      pr_des_reto := 'NOK';

      -- Se ainda não tem registro de erro, criar com a critica
      IF pr_tab_erro.COUNT = 0 THEN
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
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
      -- No caso de erro de programa gravar tabela especifica de log - 29/06/2018 - Chamado 660306
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

      -- Retorno não OK
      pr_des_reto := 'NOK';

      -- Montar descrição de erro não tratado
      vr_dscritic := 'Erro não tratado na RATI0001.pc_proc_calcula> '||sqlerrm;

      -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
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
                                   ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE               --> Data do próximo dia útil
                                   ,pr_inproces IN crapdat.inproces%TYPE               --> Situação do processo
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE               --> Numero da Conta
                                   ,pr_tpctrrat IN crapnrc.tpctrrat%TYPE               --> Tipo Contrato Rating
                                   ,pr_nrctrrat IN crapnrc.nrctrrat%TYPE               --> Numero Contrato Rating
                                   ,pr_idseqttl IN crapttl.idseqttl%TYPE               --> Sequencial do Titular
                                   ,pr_idorigem IN INTEGER                             --> Identificador Origem
                                   ,pr_nmdatela IN craptel.nmdatela%TYPE               --> Nome da tela
                                   ,pr_flgerlog IN VARCHAR2                            --> Identificador de geração de log
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
     Data    : Maio/2016.                          Ultima Atualizacao: 28/06/2017

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  : Procedure para veririficar se um rating pode ser atualizado.

     Alteracoes:

                 28/06/2017 - Inclusão para setar o modulo de todas procedures da Package
                              ( Belli - Envolti - 28/06/2017 - Chamado 660306).


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

    --Cursor para buscar o rating do cooperado com contrato do BNDES
    CURSOR cr_crapnrc_crapebn(pr_cdcooper IN crapcop.cdcooper%TYPE
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
       AND nrc.tpctrrat = pr_tpctrrat
       AND (EXISTS (SELECT 1
                    FROM crapebn b
                    WHERE b.cdcooper = nrc.cdcooper
                      AND b.nrdconta = nrc.nrdconta
                      AND b.nrctremp = nrc.nrctrrat));
    rw_crapnrc_crapebn cr_crapnrc_crapebn%ROWTYPE;

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

    --Cursor para buscar o rating do cooperado com contrato no BNDES
    CURSOR cr_crapnrc2_crapebn(pr_rowidnrc IN ROWID) IS
    SELECT nrc.tpctrrat
          ,nrc.nrctrrat
          ,nrc.nrnotrat
          ,nrc.progress_recid
          ,nrc.rowid
      FROM crapnrc nrc
     WHERE ROWID = pr_rowidnrc
      AND (EXISTS (SELECT 1
                   FROM crapebn b
                   WHERE b.cdcooper = nrc.cdcooper
                     AND b.nrdconta = nrc.nrdconta
                     AND b.nrctremp = nrc.nrctrrat));
    rw_crapnrc2_crapebn cr_crapnrc2_crapebn%ROWTYPE;

  --------------- VARIAVEIS ----------------
    -- Variaveis para manter critica
    vr_exc_erro EXCEPTION;
    vr_exc_saida EXCEPTION;
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);

    -- Vetor com dados de parâmetro (CRAPDAT)
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

    vr_habrat VARCHAR2(1) := 'N'; -- P450 - Paramentro para Habilitar Novo Ratin (S/N)

  BEGIN

    -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
    GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'RATI0001.pc_verifica_atualizacao');

    vr_habrat := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                           pr_cdcooper => pr_cdcooper,
                                           pr_cdacesso => 'HABILITA_RATING_NOVO');

    -- Montar variaveis para log
    IF pr_flgerlog = 'S'  THEN
      vr_dsorigem := TRIM(gene0001.vr_vet_des_origens(pr_idorigem));
      vr_dstransa := 'Verificar se o Rating em questao pode ser atualizado.';
    END IF;

    -- P450 SPT13 - alteracao para habilitar rating novo
    IF (pr_cdcooper = 3 OR vr_habrat = 'N') THEN
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
    ELSE
      OPEN cr_crapnrc_crapebn(pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_nrctrrat => pr_nrctrrat
                             ,pr_tpctrrat => pr_tpctrrat);

      FETCH cr_crapnrc_crapebn INTO rw_crapnrc_crapebn;

      IF cr_crapnrc_crapebn%NOTFOUND THEN

        --Fecha o cursor
        CLOSE cr_crapnrc_crapebn;

        vr_dscritic := NULL;
        vr_cdcritic := 925;

        RAISE vr_exc_erro;

      ELSE

        --Fecha o cursor
        CLOSE cr_crapnrc_crapebn;

      END IF;
    END IF;
    -- P450 SPT13 - alteracao para habilitar rating novo

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

        /* Se hoje nao é maior do que a ult. alteraçao  mais 6 meses*/
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
    -- P450 SPT13 - alteracao para habilitar rating novo
    IF (pr_cdcooper = 3 OR vr_habrat = 'N') THEN
       IF rw_crapnrc.insitrat <> 2 THEN

         RAISE vr_exc_saida;

       END IF;
    ELSE
       IF rw_crapnrc_crapebn.insitrat <> 2 THEN

         RAISE vr_exc_saida;

       END IF;
    END IF;
    -- P450 SPT13 - alteracao para habilitar rating novo

    /* Para cooperativas singulares na central nao verifica atualizacao */
    IF pr_cdcooper = 3 THEN

      IF pr_dsretorn THEN

        RAISE vr_exc_saida;

      END IF;

    END IF;

    /* No mesmo mes e ano pode atualizar qualquer Rating. */
    /* Ratings propostos */
    pc_procura_pior_nota(pr_cdcooper => pr_cdcooper --> Código da Cooperativa
                        ,pr_nrdconta => pr_nrdconta --> Conta do associado
                        ,pr_indrisco => pr_indrisco --> Risco do pior rating
                        ,pr_rowidnrc => pr_rowidnrc --> Rowid do pior rating
                        ,pr_nrctrrat => vr_nrctrrat --> Número do contrato do pior rating
                        ,pr_dsoperac => vr_dsoperac --> Descrição da operação do rating
                        ,pr_cdcritic => vr_cdcritic
                        ,pr_dscritic => vr_dscritic);

    -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
    GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'RATI0001.pc_verifica_atualizacao');

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
                              ,pr_flgerlog => 'N'           --> Identificador de geração de log
                              ,pr_tab_rating_sing      => pr_tab_rating_sing      --> Registros gravados para rati
                              ,pr_flghisto => 0
                              ,pr_tab_impress_coop     => vr_tab_impress_coop     --> Registro impressão da Cooper
                              ,pr_tab_impress_rating   => vr_tab_impress_rating   --> Registro itens do Rating
                              ,pr_tab_impress_risco_cl => vr_tab_impress_risco_cl --> Registro Nota e risco do coo
                              ,pr_tab_impress_risco_tl => vr_tab_impress_risco_tl --> Registro Nota e risco do coo
                              ,pr_tab_impress_assina   => vr_tab_impress_assina   --> Assinatura na impressao do R
                              ,pr_tab_efetivacao       => vr_tab_efetivacao       --> Registro dos itens da efetiv
                              ,pr_tab_ratings          => vr_tab_ratings          --> Informacoes com os Ratings d
                              ,pr_tab_crapras          => vr_tab_crapras          --> Tabela com os registros proc
                              ,pr_tab_erro             => pr_tab_erro             --> Tabela de retorno de erro
                              ,pr_des_reto             => pr_des_reto);           --> Ind. de retorno OK/NOK

    -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
    GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'RATI0001.pc_verifica_atualizacao');

    -- Em caso de erro
    IF pr_des_reto <> 'OK' THEN

      --Se não tem erro na tabela
      IF pr_tab_erro.COUNT = 0 THEN
        vr_cdcritic:= 0;
        vr_dscritic:= 'Erro ao calcular rating.';
      END IF;

      -- Sair
      RAISE vr_exc_erro;

    END IF;

    /* O pior rating proposto */
    -- P450 SPT13 - alteracao para habilitar rating novo
    IF (pr_cdcooper = 3 OR vr_habrat = 'N') THEN
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
    ELSE
        OPEN cr_crapnrc2_crapebn(pr_rowidnrc => pr_rowidnrc);

        FETCH cr_crapnrc2_crapebn INTO rw_crapnrc2_crapebn;

        /* Usar a pior nota */
        IF cr_crapnrc2_crapebn%NOTFOUND OR
           vr_tab_impress_risco_cl(vr_tab_impress_risco_cl.first).vlrtotal >= rw_crapnrc2_crapebn.nrnotrat THEN

          pr_nrnotrat := vr_tab_impress_risco_cl(vr_tab_impress_risco_cl.first).vlrtotal;
          pr_indrisco := vr_tab_impress_risco_cl(vr_tab_impress_risco_cl.first).dsdrisco;
          pr_rowidnrc := rw_crapnrc2_crapebn.rowid;

        ELSE

          /* O indrisco e rowid nao precisa atribuir pois */
          /* ja veio da procedure procura_pior_nota */
          pr_nrnotrat := rw_crapnrc2_crapebn.nrnotrat;

        END IF;

        --Fechar o cursor
        CLOSE cr_crapnrc2_crapebn;
    END IF;
    -- P450 SPT13 - alteracao para habilitar rating novo

    -- Se chegamos neste ponto, não houve erro
    pr_des_reto := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK
      pr_des_reto := 'NOK';

      -- Se ainda não tem registro de erro, criar com a critica
      IF pr_tab_erro.COUNT = 0 THEN
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
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
      -- No caso de erro de programa gravar tabela especifica de log - 29/06/2018 - Chamado 660306
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
      -- Retorno não OK
      pr_des_reto := 'NOK';

      -- Montar descrição de erro não tratado
      vr_dscritic := 'Erro não tratado na RATI0001.pc_verifica_atualizacao> '||sqlerrm;

      -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
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
                                  ,pr_flgerlog IN INTEGER               --> Identificador de geração de log
                                  ,pr_tab_erro OUT GENE0001.typ_tab_erro--> Tabela de retorno de erro
                                  ,pr_des_reto OUT VARCHAR2             --> Ind. de retorno OK/NOK
                                  ) IS

  /* ..........................................................................

     Programa: pc_valida_itens_rating         Antigo: b1wgen0043.p/valida-itens-rating
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Andrei - RKAM
     Data    : Maio/2016.                          Ultima Atualizacao: 28/06/2017

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  :  Validacao dos campos que envolvem <F7> do rating na proposta de emprestimo,
                  contratos de cheque especial e descontos

     Alteracoes:

                 28/06/2017 - Inclusão para setar o modulo de todas procedures da Package
                              ( Belli - Envolti - 28/06/2017 - Chamado 660306).


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

    -- Vetor com dados de parâmetro (CRAPDAT)
    rw_crapdat btch0001.rw_crapdat%TYPE;

    -- Variaveis para manter o log
    vr_dsorigem  VARCHAR2(50);
    vr_dstransa  VARCHAR2(50);
    vr_nrdrowid  ROWID;

  BEGIN

    -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
    GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'RATI0001.pc_valida_itens_rating');

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

      -- Se chegamos neste ponto, não houve erro
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

    -- Se chegamos neste ponto, não houve erro
    pr_des_reto := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK
      pr_des_reto := 'NOK';

      -- Se ainda não tem registro de erro, criar com a critica
      IF pr_tab_erro.COUNT = 0 THEN
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
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
      -- No caso de erro de programa gravar tabela especifica de log - 29/06/2018 - Chamado 660306
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
      -- Retorno não OK
      pr_des_reto := 'NOK';

      -- Montar descrição de erro não tratado
      vr_dscritic := 'Erro não tratado na RATI0001.pc_valida_itens_rating> '||sqlerrm;

      -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
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
                              ,pr_flgerlog IN INTEGER               --> Identificador de geração de log
                              ,pr_flgcalcu OUT INTEGER                  --> Indicador do risco
                              ,pr_tab_erro OUT GENE0001.typ_tab_erro    --> Tabela de retorno de erro
                              ,pr_des_reto OUT VARCHAR2                 --> Ind. de retorno OK/NOK
                              ) IS

  /* ..........................................................................

     Programa: pc_verifica_rating         Antigo: b1wgen0043.p/verifica_rating
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Andrei - RKAM
     Data    : Maio/2016.                          Ultima Atualizacao: 28/06/2017

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  :  Verificar se existe algum rating relacionado a proposta em questao.
                  Utilizada para verificar se precisa ser re calculado na hora da impressao.
                  Se existir pega os dados da tabela crapnrc senao re calcula.
                  Chamar procedure para validar os campos obrigatorios do Rating.

     Alteracoes:

                 28/06/2017 - Inclusão para setar o modulo de todas procedures da Package
                              ( Belli - Envolti - 28/06/2017 - Chamado 660306).


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

    vr_habrat VARCHAR2(1) := 'N'; -- P450 - Paramentro para Habilitar Novo Ratin (S/N)

  BEGIN

    vr_habrat := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                           pr_cdcooper => pr_cdcooper,
                                           pr_cdacesso => 'HABILITA_RATING_NOVO');

    -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
    GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'RATI0001.pc_verifica_rating');

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

    ELSIF pr_tpctrrat = 3 THEN
          OPEN  cr_crawlim(pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_tpctrato => pr_tpctrrat
                          ,pr_nrctrato => pr_nrctrrat);
          FETCH cr_crawlim INTO rw_craplim;
          IF    cr_crawlim%NOTFOUND THEN
                CLOSE cr_crawlim;
                OPEN  cr_craplim(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_tpctrato => pr_tpctrrat
                                ,pr_nrctrato => pr_nrctrrat);
                FETCH cr_craplim INTO rw_craplim;
                IF    cr_craplim%NOTFOUND THEN
                      CLOSE cr_craplim;
                      vr_cdcritic:= 484;
                      vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_dscritic);
                      RAISE vr_exc_erro;
                ELSE
                     CLOSE cr_craplim;
                END   IF;
          ELSE
                CLOSE cr_crawlim;
          END   IF;

          vr_nrgarope := rw_craplim.nrgarope;
          vr_nrinfcad := rw_craplim.nrinfcad;
          vr_nrliquid := rw_craplim.nrliquid;
          vr_nrpatlvr := rw_craplim.nrpatlvr;
          vr_nrperger := rw_craplim.nrperger;

    --Descontos/ Cheque Especial
    ELSE

      OPEN cr_craplim(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_tpctrato => pr_tpctrrat
                     ,pr_nrctrato => pr_nrctrrat);

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
                          ,pr_flgerlog => pr_flgerlog --> Identificador de geração de log
                          ,pr_tab_erro => pr_tab_erro --> Tabela de retorno de erro
                          ,pr_des_reto => pr_des_reto --> Ind. de retorno OK/NOK
                          );

    -- P450 SPT13 - alteracao para habilitar rating novo
    IF (pr_cdcooper = 3 OR vr_habrat = 'N') THEN
      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'RATI0001.pc_verifica_rating');

      -- Em caso de erro
      IF pr_des_reto <> 'OK' THEN

        --Se não tem erro na tabela
        IF pr_tab_erro.COUNT = 0 THEN
          vr_cdcritic:= 0;
          vr_dscritic:= 'Campos obrigatorios para o Rating nao preenchidos.';
        END IF;

        -- Sair
        RAISE vr_exc_erro;

      END IF;
    END IF;
    -- P450 SPT13 - alteracao para habilitar rating novo

    -- Se chegamos neste ponto, não houve erro
    pr_des_reto := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK
      pr_des_reto := 'NOK';

      -- Se ainda não tem registro de erro, criar com a critica
      IF pr_tab_erro.COUNT = 0 THEN
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
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
      -- No caso de erro de programa gravar tabela especifica de log - 29/06/2018 - Chamado 660306
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
      -- Retorno não OK
      pr_des_reto := 'NOK';

      -- Montar descrição de erro não tratado
      vr_dscritic := 'Erro não tratado na RATI0001.pc_verifica_rating '||sqlerrm;

      -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
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
   Adaptação do fonte fontes/gera_rating.p para utilização no Ayllos WEB
               Gerar o rating do cooperado e dados de impressao
  *****************************************************************************/
  PROCEDURE pc_gera_rating(pr_cdcooper             IN crapcop.cdcooper%TYPE            --> Codigo Cooperativa
                          ,pr_cdagenci             IN crapass.cdagenci%TYPE            --> Codigo Agencia
                          ,pr_nrdcaixa             IN craperr.nrdcaixa%TYPE            --> Numero Caixa
                          ,pr_cdoperad             IN crapnrc.cdoperad%TYPE            --> Codigo Operador
                          ,pr_nmdatela             IN craptel.nmdatela%TYPE            --> Nome da tela
                          ,pr_idorigem             IN INTEGER                          --> Identificador Origem
                          ,pr_nrdconta             IN crapass.nrdconta%TYPE            --> Numero da Conta
                          ,pr_idseqttl             IN crapttl.idseqttl%TYPE            --> Sequencial do Titular
                          ,pr_dtmvtolt             IN crapdat.dtmvtolt%TYPE            --> Data de movimento
                          ,pr_dtmvtopr             IN crapdat.dtmvtopr%TYPE            --> Data do próximo dia útil
                          ,pr_inproces             IN crapdat.inproces%TYPE            --> Situação do processo
                          ,pr_tpctrrat             IN crapnrc.tpctrrat%TYPE            --> Tipo Contrato Rating
                          ,pr_nrctrrat             IN crapnrc.nrctrrat%TYPE            --> Numero Contrato Rating
                          ,pr_flgcriar             IN INTEGER                          --> Criar rating
                          ,pr_flgerlog             IN INTEGER                          --> Identificador de geração de log
                          ,pr_tab_rating_sing      IN RATI0001.typ_tab_crapras  --> Registros gravados para rating singular
                          ,pr_tab_impress_coop     OUT RATI0001.typ_tab_impress_coop     --> Registro impressão da Cooperado
                          ,pr_tab_impress_rating   OUT RATI0001.typ_tab_impress_rating   --> Registro itens do Rating
                          ,pr_tab_impress_risco_cl OUT RATI0001.typ_tab_impress_risco    --> Registro Nota e risco do cooperado naquele Rating - PROVISAOCL
                          ,pr_tab_impress_risco_tl OUT RATI0001.typ_tab_impress_risco    --> Registro Nota e risco do cooperado naquele Rating - PROVISAOTL
                          ,pr_tab_impress_assina   OUT RATI0001.typ_tab_impress_assina   --> Assinatura na impressao do Rating
                          ,pr_tab_efetivacao       OUT RATI0001.typ_tab_efetivacao       --> Registro dos itens da efetivação
                          ,pr_tab_ratings          OUT RATI0001.typ_tab_ratings          --> Informacoes com os Ratings do Cooperado
                          ,pr_tab_crapras          OUT RATI0001.typ_tab_crapras          --> Tabela com os registros processados
                          ,pr_tab_erro             OUT GENE0001.typ_tab_erro             --> Tabela de retorno de erro
                          ,pr_des_reto             OUT VARCHAR2                          --> Ind. de retorno OK/NOK
                          ) IS

  /* ..........................................................................

     Programa: pc_gera_rating         Antigo: b1wgen0043.p/gera_rating
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Andrei - RKAM
     Data    : Maio/2016.                          Ultima Atualizacao: 28/06/2017

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  :  Gerar o rating do cooperado e dados de impressao

     Alteracoes:

                 28/06/2017 - Inclusão para setar o modulo de todas procedures da Package
                              ( Belli - Envolti - 28/06/2017 - Chamado 660306).


  ............................................................................. */

    ------------- VARIAVEIS ----------------
    -- Variaveis para manter critica
    vr_exc_erro EXCEPTION;
    vr_exc_saida EXCEPTION;
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);

    -- Vetor com dados de parâmetro (CRAPDAT)
    rw_crapdat btch0001.rw_crapdat%TYPE;

    -- Variaveis para manter o log
    vr_dsorigem  VARCHAR2(50);
    vr_dstransa  VARCHAR2(54);
    vr_nrdrowid  ROWID;
    vr_flgcalcu  INTEGER;
    vr_flgcriar  INTEGER := pr_flgcriar;

    vr_habrat VARCHAR2(1) := 'N'; -- P450 - Paramentro para Habilitar Novo Ratin (S/N)

  BEGIN
    vr_habrat := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                           pr_cdcooper => pr_cdcooper,
                                           pr_cdacesso => 'HABILITA_RATING_NOVO');

    -- P450 SPT13 - alteracao para habilitar rating novo
    IF (pr_cdcooper <> 3 AND vr_habrat = 'S') THEN
      pr_des_reto := 'OK';
      RETURN;
    END IF;
    -- P450 SPT13 - alteracao para habilitar rating novo

    -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
    GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'RATI0001.pc_gera_rating');

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
                      ,pr_flgerlog => pr_flgerlog --> Identificador de geração de log
                      ,pr_flgcalcu => vr_flgcalcu --> Rating já calculado
                      ,pr_tab_erro => pr_tab_erro --> Tabela de retorno de erro
                      ,pr_des_reto => pr_des_reto); --> Ind. de retorno OK/NOK

    -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
    GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'RATI0001.pc_gera_rating');

    -- Em caso de erro
    IF pr_des_reto <> 'OK' THEN

      /*************************************************************/
      /** Retornar critica se nao for limite de credito ou se for **/
      /** limite de credito e estiver tentando imprimir           **/
      /*************************************************************/
      IF pr_tpctrrat = 1 AND /*Limite de Crédito*/
         pr_flgcriar = 1 THEN

        RAISE vr_exc_saida;

      ELSE

        --Se não tem erro na tabela
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
                     ,pr_flgerlog => 'S'         --> Identificador de geração de log
                     ,pr_tab_rating_sing     => pr_tab_rating_sing --> Registros gravados para rating singular
                     ,pr_flghisto => vr_flgcriar
                     ,pr_tab_impress_coop    => pr_tab_impress_coop     --> Registro impressão da Cooperado
                     ,pr_tab_impress_rating  => pr_tab_impress_rating   --> Registro itens do Rating
                     ,pr_tab_impress_risco_cl => pr_tab_impress_risco_cl   --> Registro Nota e risco do cooperado naquele Rating - PROVISAOCL
                     ,pr_tab_impress_risco_tl => pr_tab_impress_risco_tl   --> Registro Nota e risco do cooperado naquele Rating - PROVISAOTL
                     ,pr_tab_impress_assina  => pr_tab_impress_assina   --> Assinatura na impressao do Rating
                     ,pr_tab_efetivacao      => pr_tab_efetivacao       --> Registro dos itens da efetivação
                     ,pr_tab_ratings         => pr_tab_ratings          --> Informacoes com os Ratings do Cooperado
                     ,pr_tab_crapras         => pr_tab_crapras          --> Tabela com os registros processados
                     ,pr_tab_erro            => pr_tab_erro             --> Tabela de retorno de erro
                     ,pr_des_reto            => pr_des_reto             --> Ind. de retorno OK/NOK
                     );

    -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
    GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'RATI0001.pc_gera_rating');

    -- Em caso de erro
    IF pr_des_reto <> 'OK' THEN

      --Se não tem erro na tabela
      IF pr_tab_erro.COUNT = 0 THEN
        vr_cdcritic:= 0;
        vr_dscritic:= 'Nao foi possivel gerar o rating.';
      END IF;

      -- Sair
      RAISE vr_exc_erro;

    END IF;

    -- Se chegamos neste ponto, não houve erro
    pr_des_reto := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK
      pr_des_reto := 'NOK';

      -- Se ainda não tem registro de erro, criar com a critica
      IF pr_tab_erro.COUNT = 0 THEN
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
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
      -- No caso de erro de programa gravar tabela especifica de log - 29/06/2018 - Chamado 660306
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
      -- Retorno não OK
      pr_des_reto := 'NOK';

      -- Montar descrição de erro não tratado
      vr_dscritic := 'Erro não tratado na RATI0001.pc_gera_rating '||sqlerrm;

      -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
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

  /*****************************************************************************
                  Gravar dados do rating do cooperado
  *****************************************************************************/
  PROCEDURE pc_grava_rating(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo Cooperativa
                           ,pr_cdagenci IN crapass.cdagenci%TYPE --> Codigo Agencia
                           ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Numero Caixa
                           ,pr_cdoperad IN crapnrc.cdoperad%TYPE --> Codigo Operador
                           ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data de movimento
                           ,pr_nrdconta IN crapass.nrdconta%TYPE --> Numero da Conta
                           ,pr_inpessoa IN crapass.inpessoa%TYPE --> Tipo Pessoa
                           ,pr_nrinfcad IN crapprp.nrinfcad%TYPE --> Informacoes Cadastrais
                           ,pr_nrpatlvr IN crapprp.nrpatlvr%TYPE --> Patrimonio pessoal livre
                           ,pr_nrperger IN crapprp.nrperger%TYPE --> Percepção Geral Empresa
                           ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Sequencial do Titular
                           ,pr_idorigem IN INTEGER               --> Identificador Origem
                           ,pr_nmdatela IN craptel.nmdatela%TYPE --> Nome da tela
                           ,pr_flgerlog IN INTEGER               --> Identificador de geração de log
                           ,pr_cdcritic OUT NUMBER               --> Codigo Critica
                           ,pr_dscritic OUT VARCHAR2             --> Descricao critica
                              ) IS

  /* ..........................................................................

     Programa: pc_grava_rating         Antigo: b1wgen0043.p/grava_rating
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Marcos - Supero
     Data    : Julho/2017.                          Ultima Atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  :  Gravar dados do rating do cooperado

     Alteracoes:

  ............................................................................. */
    /*--Cursor para buscar o rating do cooperado
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
    rw_craplim cr_craplim%ROWTYPE;*/

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

  BEGIN

    -- Montar variaveis para log
    IF pr_flgerlog = 1 THEN
      vr_dsorigem := TRIM(gene0001.vr_vet_des_origens(pr_idorigem));
      vr_dstransa := 'Gravar dados de rating do cooperado.';
    END IF;

    -- Para PF
    IF pr_inpessoa = 1 THEN
      UPDATE crapttl
         SET crapttl.nrinfcad = pr_nrinfcad
            ,crapttl.nrpatlvr = pr_nrpatlvr
       WHERE crapttl.cdcooper = pr_cdcooper
         AND crapttl.nrdconta = pr_nrdconta
         AND crapttl.idseqttl = pr_idseqttl;
    ELSE -- PJ
      UPDATE crapjur
         SET crapjur.nrinfcad = pr_nrinfcad
            ,crapjur.nrpatlvr = pr_nrpatlvr
            ,crapjur.nrperger = pr_nrperger
       WHERE crapjur.cdcooper = pr_cdcooper
         AND crapjur.nrdconta = pr_nrdconta;

    END IF;

    -- Se foi solicitado o envio de LOG
    IF pr_flgerlog = 1 THEN
      -- Gerar LOG de envio do e-mail
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => null
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

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK
      pr_cdcritic := vr_cdcritic;
      IF vr_dscritic IS NULL AND pr_cdcritic > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      END IF;
      pr_dscritic := vr_dscritic;

      -- Se foi solicitado o envio de LOG
      IF pr_flgerlog = 1 THEN
        -- Gerar LOG de envio do e-mail
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => pr_dscritic
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

    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na atualizado em RATI0001.pc_grava_rating --> '||sqlerrm;

      -- Se foi solicitado o envio de LOG
      IF pr_flgerlog = 1 THEN
        -- Gerar LOG de envio do e-mail
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => pr_dscritic
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

  END pc_grava_rating;

  /* ***************************************************************************

     Procedimento para atualização das perguntas de Garantia e Liquidez após
     alteração dos avalistas na proposta de Empréstimo

     *************************************************************************** */
  PROCEDURE pc_atuali_garant_liquid_epr(pr_cdcooper     IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                       ,pr_nrdconta     IN crapass.nrdconta%TYPE --> Conta do associado
                                       ,pr_nrctrato     IN crapnrc.nrctrrat%TYPE --> Número do contrato de Rating
                                       ,pr_nrgarope     OUT crapprp.nrgarope%TYPE
                                       ,pr_nrliquid     OUT crapprp.nrliquid%TYPE
                                       ,pr_dscritic    OUT VARCHAR2) IS          --> Descrição de erro
  /* ..........................................................................

     Programa: pc_atuali_garant_liquid_epr
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Marcos - Supero
     Data    : Setembro/2017.                          Ultima Atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  :  Contar a quantidade de avalistas da proposta
                  e responder as perguntas de garantia e liquidez

     Alteracoes: Retornando pr_nrgarope e pr_nrliquid para bo2 PRJ438 - Paulo Martins

  ............................................................................. */

    -- Variaveis para manter critica
    vr_exc_erro EXCEPTION;
    vr_dscritic VARCHAR2(4000);

    -- Variaveis para contagem
    vr_qtdavali PLS_INTEGER := 0;
    vr_qtavlter PLS_INTEGER := 0;
    vr_qtavlsoc PLS_INTEGER := 0;

    -- Busca dados da proposta
    CURSOR cr_crawepr IS
      SELECT ass.inpessoa
            ,wpr.nrctaav1
            ,wpr.nrctaav2
        FROM crawepr wpr
            ,crapass ass
       WHERE wpr.cdcooper = ass.cdcooper
         AND wpr.nrdconta = ass.nrdconta
         AND wpr.cdcooper = pr_cdcooper
         AND wpr.nrdconta = pr_nrdconta
         AND wpr.nrctremp = pr_nrctrato;
    rw_crawepr cr_crawepr%ROWTYPE;

    -- Busca CPF do Avalista com conta na Cooperativa
    CURSOR cr_crapass(pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT nrcpfcgc
        FROM crapass
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta;
    vr_nrcpfcgc crapass.nrcpfcgc%TYPE;

    -- Buscar avalistas terceiros
    CURSOR cr_crapavt IS
      SELECT crapavt.nrcpfcgc
        FROM crapavt
       WHERE crapavt.cdcooper = pr_cdcooper
         AND crapavt.nrdconta = pr_nrdconta
         AND crapavt.nrctremp = pr_nrctrato
         AND crapavt.tpctrato = 1; -- Aval

    -- Testar se o avalista é sócio da empresa
    CURSOR cr_crapavt_socio(pr_nrcpfcgc crapass.nrcpfcgc%TYPE) IS
      SELECT 1
        FROM crapavt
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrcpfcgc = pr_nrcpfcgc
         AND nrctremp = 0 -- Não é vinculado a contrato
         AND tpctrato = 6 -- Socio
         AND UPPER(dsproftl) IN('SOCIO/PROPRIETARIO'
                               ,'SOCIO ADMINISTRADOR'
                               ,'DIRETOR/ADMINISTRADOR'
                               ,'SINDICO'
                               ,'ADMINISTRADOR');
    vr_indsocio NUMBER;

    -- Respostas do Rating
    vr_nrgarope crapprp.nrgarope%TYPE;
    vr_nrliquid crapprp.nrliquid%TYPE;

  BEGIN

    -- Busca dados da proposta
    OPEN cr_crawepr;
    FETCH cr_crawepr
     INTO rw_crawepr;
    -- Se nao encontrar
    IF cr_crawepr%NOTFOUND THEN
      vr_dscritic := gene0001.fn_busca_critica(535);
      close cr_crawepr;
      raise vr_exc_erro;
    END IF;
    CLOSE cr_crawepr;

    -- Testar se o avalista 1 existe
    IF rw_crawepr.nrctaav1 <> 0 THEN
      -- Somente para PJ
      IF rw_crawepr.inpessoa = 2 THEN
        -- Testar se o avalista não é sócio também, busca CPF dele
        vr_nrcpfcgc := NULL;
        OPEN cr_crapass(pr_nrdconta => rw_crawepr.nrctaav1);
        FETCH cr_crapass
         INTO vr_nrcpfcgc;
        CLOSE cr_crapass;
        -- Com o CPF verificar se o mesmo é
        vr_indsocio := 0;
        OPEN cr_crapavt_socio(pr_nrcpfcgc => vr_nrcpfcgc);
        FETCH cr_crapavt_socio
         INTO vr_indsocio;
        CLOSE cr_crapavt_socio;
        -- Se for o mesmo
        IF vr_indsocio = 1 THEN
          -- Incrementar avalista socio
          vr_qtavlsoc := vr_qtavlsoc + 1;
        ELSE
          -- Incrementar avalista terceiro
          vr_qtavlter := vr_qtavlter + 1;
        END IF;
      ELSE
        -- Incrementar avalistas
        vr_qtdavali := vr_qtdavali + 1;
      END IF;
    END IF;

    -- Testar se o avalista 2 existe
    IF rw_crawepr.nrctaav2 <> 0 THEN
      -- Somente para PJ
      IF rw_crawepr.inpessoa = 2 THEN
        -- Testar se o avalista não é sócio também, busca CPF dele
        vr_nrcpfcgc := NULL;
        OPEN cr_crapass(pr_nrdconta => rw_crawepr.nrctaav2);
        FETCH cr_crapass
         INTO vr_nrcpfcgc;
        CLOSE cr_crapass;
        -- Com o CPF verificar se o mesmo é
        vr_indsocio := 0;
        OPEN cr_crapavt_socio(pr_nrcpfcgc => vr_nrcpfcgc);
        FETCH cr_crapavt_socio
         INTO vr_indsocio;
        CLOSE cr_crapavt_socio;
        -- Se for o mesmo
        IF vr_indsocio = 1 THEN
          -- Incrementar avalista socio
          vr_qtavlsoc := vr_qtavlsoc + 1;
        ELSE
          -- Incrementar avalista terceiro
          vr_qtavlter := vr_qtavlter + 1;
        END IF;
      ELSE
        -- Incrementar avalistas
        vr_qtdavali := vr_qtdavali + 1;
      END IF;
    END IF;

    -- Trazer todos avalistas externos
    FOR rw_crapavt IN cr_crapavt LOOP
      -- Somente para PJ
      IF rw_crawepr.inpessoa = 2 THEN
        -- Com o CPF verificar se o mesmo é
        vr_indsocio := 0;
        OPEN cr_crapavt_socio(pr_nrcpfcgc => rw_crapavt.nrcpfcgc);
        FETCH cr_crapavt_socio
         INTO vr_indsocio;
        CLOSE cr_crapavt_socio;
        -- Se for o mesmo
        IF vr_indsocio = 1 THEN
          -- Incrementar avalista socio
          vr_qtavlsoc := vr_qtavlsoc + 1;
        ELSE
          -- Incrementar avalista terceiro
          vr_qtavlter := vr_qtavlter + 1;
        END IF;
      ELSE
        -- Incrementar avalistas
        vr_qtdavali := vr_qtdavali + 1;
      END IF;
    END LOOP;

    -- Respostas do Rating conforme tipo de pessoa
    IF rw_crawepr.inpessoa = 1 THEN
      -- Para PF soh contamos a quantidade de avalistas
      IF vr_qtdavali > 0 THEN
        vr_nrgarope := 9; -- Garantia Pessoal
        -- Para Liquidez temos de verificar 1 ou mais
        IF vr_qtdavali = 1 THEN
          vr_nrliquid := 11; -- Até uma garantia pessoal
        ELSE
          vr_nrliquid := 10; -- Acima de uma garantia pessoal
        END IF;
      ELSE
        vr_nrgarope := 10; -- Sem Garantia
        vr_nrliquid := 9;  -- Sem Garantia
      END IF;
    ELSE
      -- Para PJ temos de responder conforme avalistas sócios ou terceiros
      IF vr_qtavlsoc + vr_qtavlter = 0 THEN
        vr_nrgarope := 11; -- Sem Garantia
        vr_nrliquid := 11; -- Sem Garantia
      ELSE
        -- Havendo pelo menos uma garantia sócio
        IF vr_qtavlsoc > 0 THEN
          -- Se houver pelo menos uma terceira
          IF vr_qtavlter > 0 THEN
            vr_nrgarope := 9; --Garantia Pessoal Terceiros
          ELSE
            vr_nrgarope := 10; --Garantia Pessoal Sócios
          END IF;
          -- Liquidez temos de verificar 1 ou mais / Se teve pelo menos 1 terceiro
          IF vr_qtavlsoc > 1 OR vr_qtavlter > 0 THEN
            vr_nrliquid := 14; -- Acima 1 gar. sóc. ou 1 sócio e 1 terc
          ELSE
            vr_nrliquid := 16; -- Até uma garantia pessoal Sócios
          END IF;
        ELSE
          vr_nrgarope := 9; --Garantia Pessoal Terceiros
          -- Liquidez temos de verificar 1 ou mais
          IF vr_qtavlter > 1 THEN
            vr_nrliquid := 12; -- Acima de uma garantia pessoal terceiros
          ELSE
            vr_nrliquid := 15; -- Até uma garantia pessoal terceiros
          END IF;
        END IF;
      END IF;
    END IF;

    -- Finalmente, efetuar a atualização do registro de pergunta da proposta
    UPDATE crapprp prp
       SET prp.nrgarope = vr_nrgarope
          ,prp.nrliquid = vr_nrliquid
     WHERE prp.cdcooper = pr_cdcooper
       AND prp.nrdconta = pr_nrdconta
       AND prp.nrctrato = pr_nrctrato;
       --
       pr_nrgarope := vr_nrgarope;
       pr_nrliquid := vr_nrliquid;

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro tratado em RATI0001.pc_atuali_garant_liquid_epr --> '||vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado RATI0001.pc_atuali_garant_liquid_epr --> '||sqlerrm;
  END pc_atuali_garant_liquid_epr;

  PROCEDURE pc_grava_his_crapnrc(pr_cdcooper IN crapcop.cdcooper%type
                                ,pr_nrdconta IN crapass.nrdconta%type
                                ,pr_nrctrrat IN crapnrc.nrctrrat%type
                                ,pr_tpctrrat IN crapnrc.tpctrrat%type
                                ,pr_indrisco IN crapnrc.indrisco%type
                                ,pr_dtmvtolt IN crapnrc.dtmvtolt%type
                                ,pr_cdoperad IN crapope.cdoperad%type
                                ,pr_nrnotrat IN crapnrc.nrnotrat%type
                                ,pr_vlutlrat IN crapnrc.vlutlrat%type
                                ,pr_nrnotatl IN crapnrc.nrnotatl%type
                                ,pr_inrisctl IN crapnrc.inrisctl%type
                                ,pr_cdcritic OUT crapcri.cdcritic%type
                                ,pr_dscritic OUT crapcri.dscritic%type) IS
    vr_nrseqrat number(3);
    vr_vlrating number;
    vr_insitrat number;
    vr_cdcritic crapcri.cdcritic%type;
    vr_dscritic crapcri.dscritic%type;
    vr_exc_erro exception;
    function fn_retorna_sequencia return number is
      cursor c1 is
        select nvl(max(nrseqrat),0) + 1
          from tbrat_hist_nota_contrato
         where cdcooper = pr_cdcooper
           and nrdconta = pr_nrdconta
           and nrctrrat = pr_nrctrrat
           and tpctrrat = pr_tpctrrat;
      vr_sequen number(3);
    begin
      open c1;
      fetch c1 into vr_sequen;
      close c1;
      return vr_sequen;
    exception
      when others then
        vr_dscritic := 'Erro ao buscar sequencia - TABELA tbhis_nota_rating - '||sqlerrm;
    end fn_retorna_sequencia;
  BEGIN
    vr_nrseqrat := fn_retorna_sequencia;
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    pc_param_valor_rating(pr_cdcooper => pr_cdcooper --> Código da Cooperativa
                         ,pr_vlrating => vr_vlrating --> Valor parametrizado
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic);
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    if nvl(pr_vlutlrat,0) >= nvl(vr_vlrating,0) then
      vr_insitrat := 2;
    else
      vr_insitrat := 1;
    end if;
    insert into tbrat_hist_nota_contrato(cdcooper
                                        ,nrdconta
                                        ,nrctrrat
                                        ,tpctrrat
                                        ,nrseqrat
                                        ,indrisco
                                        ,insitrat
                                        ,nrnotrat
                                        ,vlutlrat
                                        ,dtmvtolt
                                        ,nrnotatl
                                        ,inrisctl) values (pr_cdcooper
                                                          ,pr_nrdconta
                                                          ,pr_nrctrrat
                                                          ,pr_tpctrrat
                                                          ,vr_nrseqrat
                                                          ,pr_indrisco
                                                          ,vr_insitrat
                                                          ,pr_nrnotrat
                                                          ,pr_vlutlrat
                                                          ,pr_dtmvtolt
                                                          ,pr_nrnotatl
                                                          ,pr_inrisctl);
  EXCEPTION
    WHEN vr_exc_erro THEN
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro não tratado na pc_grava_his_crapnrc ' ||
                     SQLERRM;
  END pc_grava_his_crapnrc;
  PROCEDURE pc_grava_his_crapnrc2(pr_cdcooper IN crapcop.cdcooper%type
                                ,pr_nrdconta IN crapass.nrdconta%type
                                ,pr_nrctrrat IN crapnrc.nrctrrat%type
                                ,pr_tpctrrat IN crapnrc.tpctrrat%type
                                ,pr_indrisco IN crapnrc.indrisco%type
                                ,pr_dtmvtolt IN crapnrc.dtmvtolt%type
                                ,pr_cdoperad IN crapope.cdoperad%type
                                ,pr_nrnotrat IN crapnrc.nrnotrat%type
                                ,pr_vlutlrat IN crapnrc.vlutlrat%type
                                ,pr_nrnotatl IN crapnrc.nrnotatl%type
                                ,pr_inrisctl IN crapnrc.inrisctl%type
                                ,pr_dtadmiss IN cecred.tbrat_informacao_rating.dtadmiss_cooperado%type
                                ,pr_qtmaxatr IN cecred.tbrat_informacao_rating.qtdias_max_atraso%type
                                ,pr_flgreneg IN cecred.tbrat_informacao_rating.flgrenegoc%type
                                ,pr_dtadmemp IN cecred.tbrat_informacao_rating.dtadmiss_emprego%type
                                ,pr_cdnatocp IN cecred.tbrat_informacao_rating.cdnatureza_ocupacao%type
                                ,pr_qtresext IN cecred.tbrat_informacao_rating.qtrestricao_externa%type
                                ,pr_vlnegext IN cecred.tbrat_informacao_rating.vlnegativacao_externa%type
                                ,pr_flgresre IN cecred.tbrat_informacao_rating.flgrestricao_relevante%type
                                ,pr_qtadidep IN cecred.tbrat_informacao_rating.qtadiantamento_depositante%type
                                ,pr_qtchqesp IN cecred.tbrat_informacao_rating.qtcheque_especial%type
                                ,pr_qtdevalo IN cecred.tbrat_informacao_rating.qtdev_alinea_onze%type
                                ,pr_qtdevald IN cecred.tbrat_informacao_rating.qtdev_alinea_doze%type
                                ,pr_cdsitres IN cecred.tbrat_informacao_rating.cdsituacao_residencia%type
                                ,pr_vlpreatv IN cecred.tbrat_informacao_rating.vlprestacao_ativa%type
                                ,pr_vlsalari IN cecred.tbrat_informacao_rating.vlsalario%type
                                ,pr_vlrendim IN cecred.tbrat_informacao_rating.vloutros_rendimentos%type
                                ,pr_vlsalcje IN cecred.tbrat_informacao_rating.vlsalario_conjuge%type
                                ,pr_vlendivi IN cecred.tbrat_informacao_rating.vlendividamento%type
                                ,pr_vlbemtit IN cecred.tbrat_informacao_rating.vlbem_titular%type
                                ,pr_flgcjeco IN cecred.tbrat_informacao_rating.flgconjuge_corresponsavel%type
                                ,pr_vlbemcje IN cecred.tbrat_informacao_rating.vlbem_conjuge%type
                                ,pr_vlsldeve IN cecred.tbrat_informacao_rating.vlsaldo_devedor%type
                                ,pr_vlopeatu IN cecred.tbrat_informacao_rating.vloperacao_atual%type
                                ,pr_vlslcota IN cecred.tbrat_informacao_rating.vlsaldo_cotas%type
                                ,pr_cdquaope IN cecred.tbrat_informacao_rating.cdqualificacao_operacao%type
                                ,pr_cdtpoper IN cecred.tbrat_informacao_rating.cdtipo_operacao%type
                                ,pr_cdlincre IN cecred.tbrat_informacao_rating.cdlinha_credito%type
                                ,pr_cdmodali IN cecred.tbrat_informacao_rating.cdmodalidade_linha_cred%type
                                ,pr_cdsubmod IN cecred.tbrat_informacao_rating.cdsubmodalidade_linha_cred%type
                                ,pr_cdgarope IN cecred.tbrat_informacao_rating.cdgarantia_operacao%type
                                ,pr_cdliqgar IN cecred.tbrat_informacao_rating.cdliquidez_garantia%type
                                ,pr_qtpreope IN cecred.tbrat_informacao_rating.qtprestacao_operacao%type
                                ,pr_dtfunemp IN cecred.tbrat_informacao_rating.dtfundacao_empresa%type
                                ,pr_cdseteco IN cecred.tbrat_informacao_rating.cdsetor_economico%type
                                ,pr_dtprisoc IN cecred.tbrat_informacao_rating.dtprimeiro_socio%type
                                ,pr_prfatcli IN cecred.tbrat_informacao_rating.prfaturamento_cliente%type
                                ,pr_vlmedfat IN cecred.tbrat_informacao_rating.vlmedia_faturamento_anual%type
                                ,pr_vlbemavt IN cecred.tbrat_informacao_rating.vlbem_avalista%type
                                ,pr_vlbemsoc IN cecred.tbrat_informacao_rating.vlbem_socio%type
                                ,pr_vlparope IN cecred.tbrat_informacao_rating.vlparcela_operacao%type
                                ,pr_cdperemp IN cecred.tbrat_informacao_rating.cdpercepcao_empresa%type
                                ,pr_dstpoper IN cecred.tbrat_informacao_rating.dstipo_operacao%type
                                ,pr_cdcritic OUT crapcri.cdcritic%type
                                ,pr_dscritic OUT crapcri.dscritic%type) IS
    vr_nrseqrat number(3);
    vr_vlrating number;
    vr_insitrat number;
    vr_cdcritic crapcri.cdcritic%type;
    vr_dscritic crapcri.dscritic%type;
    vr_exc_erro exception;
    --
    --flgreneg
    cursor cr_flgreneg is
      select 1
        from crawepr c
       where c.cdcooper = pr_cdcooper
         and c.nrdconta = pr_nrdconta
         and c.dtaprova is not null
         and c.idquapro = 3;
    rw_flgreneg number(1);
    --qtresext, vlnegext, flgresre
    cursor cr_restricao_epr is
      select nvl(SUM(NVL(c.qtnegati,0)),0) qtnegati
           , nvl(SUM(NVL(c.vlnegati,0)),0) vlnegati
           , nvl(SUM(NVL(b.vlprejui,0)),0) vlprejuz
           , nvl(SUM(NVL(DECODE(c.innegati,3,c.qtnegati,0),0)),0) qtprotest
           , nvl(SUM(NVL(DECODE(c.innegati,4,c.qtnegati,0),0)),0) qtacaojud
           , nvl(SUM(NVL(DECODE(c.innegati,5,c.qtnegati,0),0)),0) qtfalenci
           , nvl(SUM(NVL(DECODE(c.innegati,6,c.qtnegati,0),0)),0) qtchqsemf
           , nvl(MAX(NVL(c.vlnegati,0)),0) vlmaxneg
        from craprpf c
           , crapcbd b
           , crawepr a
       where c.nrconbir = b.nrconbir
         and c.nrseqdet = b.nrseqdet
         and b.cdcooper = a.cdcooper
         and b.nrdconta = a.nrdconta
         and b.nrconbir = a.nrconbir
         and b.inreterr = 0
         and a.cdcooper = pr_cdcooper
         and a.nrdconta = pr_nrdconta
         and a.nrctremp = pr_nrctrrat;
    --qtresext, vlnegext, flgresre
    cursor cr_restricao_lim is
      select nvl(SUM(NVL(c.qtnegati,0)),0) qtnegati
           , nvl(SUM(NVL(c.vlnegati,0)),0) vlnegati
           , nvl(SUM(NVL(b.vlprejui,0)),0) vlprejuz
           , nvl(SUM(NVL(DECODE(c.innegati,3,c.qtnegati,0),0)),0) qtprotest
           , nvl(SUM(NVL(DECODE(c.innegati,4,c.qtnegati,0),0)),0) qtacaojud
           , nvl(SUM(NVL(DECODE(c.innegati,5,c.qtnegati,0),0)),0) qtfalenci
           , nvl(SUM(NVL(DECODE(c.innegati,6,c.qtnegati,0),0)),0) qtchqsemf
           , nvl(MAX(NVL(c.vlnegati,0)),0) vlmaxneg
        from craprpf c
           , crapcbd b
           , craplim d
       where c.nrconbir = b.nrconbir
         and c.nrseqdet = b.nrseqdet
         and b.cdcooper = d.cdcooper
         and b.nrdconta = d.nrdconta
         and b.nrconbir = d.nrconbir
         and b.inreterr = 0
         and d.cdcooper = pr_cdcooper
         and d.nrdconta = pr_nrdconta
         and d.nrctrlim = pr_nrctrrat
         and d.tpctrlim = pr_tpctrrat;

    cursor cr_restricao_wlim is
      select nvl(SUM(NVL(c.qtnegati,0)),0) qtnegati
           , nvl(SUM(NVL(c.vlnegati,0)),0) vlnegati
           , nvl(SUM(NVL(b.vlprejui,0)),0) vlprejuz
           , nvl(SUM(NVL(DECODE(c.innegati,3,c.qtnegati,0),0)),0) qtprotest
           , nvl(SUM(NVL(DECODE(c.innegati,4,c.qtnegati,0),0)),0) qtacaojud
           , nvl(SUM(NVL(DECODE(c.innegati,5,c.qtnegati,0),0)),0) qtfalenci
           , nvl(SUM(NVL(DECODE(c.innegati,6,c.qtnegati,0),0)),0) qtchqsemf
           , nvl(MAX(NVL(c.vlnegati,0)),0) vlmaxneg
        from craprpf c
           , crapcbd b
           , crawlim d
       where c.nrconbir = b.nrconbir
         and c.nrseqdet = b.nrseqdet
         and b.cdcooper = d.cdcooper
         and b.nrdconta = d.nrdconta
         and b.nrconbir = d.nrconbir
         and b.inreterr = 0
         and d.cdcooper = pr_cdcooper
         and d.nrdconta = pr_nrdconta
         and d.nrctrlim = pr_nrctrrat
         and d.tpctrlim = pr_tpctrrat;
    rw_restricao cr_restricao_epr%rowtype;
    rw_flgresre  number(1);
    --vlbemtit
    cursor cr_vlbemtit is
      select nvl(sum(c.vlrdobem),0) vlbemtit
        from crapbem c
       where c.idseqttl = 1
         and c.cdcooper = pr_cdcooper
         and c.nrdconta = pr_nrdconta;
    rw_vlbemtit cr_vlbemtit%rowtype;
    --vlbemcje
    cursor cr_vlbemcje is
      select nvl(sum(x.vlrdobem),0) vlbemcje
        from crapbem x
           , crapcje c
       where x.cdcooper = c.cdcooper
         and x.nrdconta = c.nrctacje
         and x.idseqttl = 1
         and c.cdcooper = pr_cdcooper
         and c.nrdconta = pr_nrdconta
         and c.idseqttl = 1;
    rw_vlbemcje cr_vlbemcje%rowtype;
    --vlbemsoc
    cursor cr_vlbemsoc is
      select nvl(sum(x.vlrdobem),0) vlbemsoc
        from crapbem x
           , crapavt c
       where x.cdcooper = c.cdcooper
         and x.nrdconta = c.nrdctato
         and x.idseqttl = 1
         and c.cdcooper = pr_cdcooper
         and c.nrdconta = pr_nrdconta
         and c.tpctrato = 6
         and c.nrdctato <> 0
         and c.dsproftl in ('SOCIO/PROPRIETARIO','SOCIO ADMINISTRADOR','DIRETOR/ADMINISTRADOR','SINDICO','ADMINISTRADOR');
    rw_vlbemsoc cr_vlbemsoc%rowtype;
    --vlbemavt
    cursor cr_vlbemavt_epr is
      select nvl(sum(x.vlrdobem),0) vlbemavt
        from crapbem x
           , crawepr c
       where x.cdcooper = c.cdcooper
         and x.nrdconta in (c.nrctaav1, c.nrctaav2)
         and x.idseqttl = 1
         and c.cdcooper = pr_cdcooper
         and c.nrdconta = pr_nrdconta
         and c.nrctremp = pr_nrctrrat;
    --vlbemavt
    cursor cr_vlbemavt_lim is
      select nvl(sum(x.vlrdobem),0) vlbemavt
        from crapbem x
           , craplim c
       where x.cdcooper = c.cdcooper
         and x.nrdconta in (c.nrctaav1, c.nrctaav2)
         and x.idseqttl = 1
         and c.cdcooper = pr_cdcooper
         and c.nrdconta = pr_nrdconta
         and c.nrctrlim = pr_nrctrrat
         and c.tpctrlim = pr_tpctrrat;

    cursor cr_vlbemavt_wlim is
      select nvl(sum(x.vlrdobem),0) vlbemavt
        from crapbem x
           , craplim c
       where x.cdcooper = c.cdcooper
         and x.nrdconta in (c.nrctaav1, c.nrctaav2)
         and x.idseqttl = 1
         and c.cdcooper = pr_cdcooper
         and c.nrdconta = pr_nrdconta
         and c.nrctrlim = pr_nrctrrat
         and c.tpctrlim = pr_tpctrrat;
    rw_vlbemavt cr_vlbemavt_epr%rowtype;
    --
    function fn_retorna_sequencia return number is
      cursor c1 is
        select nvl(max(nrseqrat),0) + 1
          from tbrat_hist_nota_contrato
         where cdcooper = pr_cdcooper
           and nrdconta = pr_nrdconta
           and nrctrrat = pr_nrctrrat
           and tpctrrat = pr_tpctrrat;
      vr_sequen number(3);
    begin
      open c1;
      fetch c1 into vr_sequen;
      close c1;
      return vr_sequen;
    exception
      when others then
        vr_dscritic := 'Erro ao buscar sequencia - TABELA tbhis_nota_rating - '||sqlerrm;
    end fn_retorna_sequencia;
  BEGIN
    vr_nrseqrat := fn_retorna_sequencia;
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    pc_param_valor_rating(pr_cdcooper => pr_cdcooper --> Código da Cooperativa
                         ,pr_vlrating => vr_vlrating --> Valor parametrizado
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic);
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    if nvl(pr_vlutlrat,0) >= nvl(vr_vlrating,0) then
      vr_insitrat := 2;
    else
      vr_insitrat := 1;
    end if;
    --cr_flgreneg
    open cr_flgreneg;
    fetch cr_flgreneg into rw_flgreneg;
    if cr_flgreneg%found then
      rw_flgreneg := 1;
    else
      rw_flgreneg := 0;
    end if;
    close cr_flgreneg;
    --cr_vlbemtit
    open cr_vlbemtit;
    fetch cr_vlbemtit into rw_vlbemtit;
    close cr_vlbemtit;
    --cr_vlbemcje
    open cr_vlbemcje;
    fetch cr_vlbemcje into rw_vlbemcje;
    close cr_vlbemcje;
    --cr_vlbemsoc
    open cr_vlbemsoc;
    fetch cr_vlbemsoc into rw_vlbemsoc;
    close cr_vlbemsoc;
    --cr_restricao_epr ou cr_restricao_lim
    --cr_vlbemavt_epr ou cr_vlbemavt_lim
    if pr_tpctrrat = 90 then
      open cr_restricao_epr;
      fetch cr_restricao_epr into rw_restricao;
      close cr_restricao_epr;
      open cr_vlbemavt_epr;
      fetch cr_vlbemavt_epr into rw_vlbemavt;
      close cr_vlbemavt_epr;
    ELSIF pr_tpctrrat = 3 THEN
          OPEN  cr_restricao_wlim;
          FETCH cr_restricao_wlim INTO rw_restricao;
          IF    cr_restricao_wlim%NOTFOUND THEN
                CLOSE cr_restricao_wlim;

                OPEN  cr_restricao_lim;
                FETCH cr_restricao_lim into rw_restricao;
                CLOSE cr_restricao_lim;
          ELSE
                CLOSE cr_restricao_wlim;
          END   IF;

          OPEN  cr_vlbemavt_wlim;
          FETCH cr_vlbemavt_wlim INTO rw_vlbemavt;
          IF    cr_vlbemavt_wlim%NOTFOUND THEN
                CLOSE cr_vlbemavt_wlim;

                OPEN  cr_vlbemavt_lim;
                FETCH cr_vlbemavt_lim into rw_vlbemavt;
                CLOSE cr_vlbemavt_lim;
          ELSE
                CLOSE cr_vlbemavt_wlim;
          END   IF;
    else
      open cr_restricao_lim;
      fetch cr_restricao_lim into rw_restricao;
      close cr_restricao_lim;
      open cr_vlbemavt_lim;
      fetch cr_vlbemavt_lim into rw_vlbemavt;
      close cr_vlbemavt_lim;
    end if;
    if rw_restricao.vlprejuz   + rw_restricao.qtprotest +
        rw_restricao.qtacaojud + rw_restricao.qtfalenci + rw_restricao.qtchqsemf > 0 then
      rw_flgresre := 1;
    else
      rw_flgresre := 0;
    end if;
    insert into tbrat_hist_nota_contrato(cdcooper
                                        ,nrdconta
                                        ,nrctrrat
                                        ,tpctrrat
                                        ,nrseqrat
                                        ,indrisco
                                        ,insitrat
                                        ,nrnotrat
                                        ,vlutlrat
                                        ,dtmvtolt
                                        ,nrnotatl
                                        ,inrisctl) values (pr_cdcooper
                                                          ,pr_nrdconta
                                                          ,pr_nrctrrat
                                                          ,pr_tpctrrat
                                                          ,vr_nrseqrat
                                                          ,pr_indrisco
                                                          ,vr_insitrat
                                                          ,pr_nrnotrat
                                                          ,pr_vlutlrat
                                                          ,pr_dtmvtolt
                                                          ,pr_nrnotatl
                                                          ,pr_inrisctl);
    insert into cecred.tbrat_informacao_rating(cdcooper
                                              ,nrdconta
                                              ,nrctrrat
                                              ,tpctrrat
                                              ,nrseqrat
                                              ,dtadmiss_cooperado
                                              ,qtdias_max_atraso
                                              ,flgrenegoc
                                              ,dtadmiss_emprego
                                              ,cdnatureza_ocupacao
                                              ,qtrestricao_externa
                                              ,vlnegativacao_externa
                                              ,flgrestricao_relevante
                                              ,qtadiantamento_depositante
                                              ,qtcheque_especial
                                              ,qtdev_alinea_onze
                                              ,qtdev_alinea_doze
                                              ,cdsituacao_residencia
                                              ,vlprestacao_ativa
                                              ,vlsalario
                                              ,vloutros_rendimentos
                                              ,vlsalario_conjuge
                                              ,vlendividamento
                                              ,vlbem_titular
                                              ,flgconjuge_corresponsavel
                                              ,vlbem_conjuge
                                              ,vlsaldo_devedor
                                              ,vloperacao_atual
                                              ,vlsaldo_cotas
                                              ,cdqualificacao_operacao
                                              ,cdtipo_operacao
                                              ,cdlinha_credito
                                              ,cdmodalidade_linha_cred
                                              ,cdsubmodalidade_linha_cred
                                              ,cdgarantia_operacao
                                              ,cdliquidez_garantia
                                              ,qtprestacao_operacao
                                              ,dtfundacao_empresa
                                              ,cdsetor_economico
                                              ,dtprimeiro_socio
                                              ,prfaturamento_cliente
                                              ,vlmedia_faturamento_anual
                                              ,vlbem_avalista
                                              ,vlbem_socio
                                              ,vlparcela_operacao
                                              ,cdpercepcao_empresa
                                              ,dstipo_operacao) values (pr_cdcooper --cdcooper
                                                                       ,pr_nrdconta --nrdconta
                                                                       ,pr_nrctrrat --nrctrrat
                                                                       ,pr_tpctrrat --tpctrrat
                                                                       ,vr_nrseqrat --nrseqrat
                                                                       ,pr_dtadmiss --dtadmiss_cooperado
                                                                       ,pr_qtmaxatr --qtdias_max_atraso
                                                                       ,rw_flgreneg --flgrenegoc
                                                                       ,pr_dtadmemp --dtadmiss_emprego
                                                                       ,pr_cdnatocp --cdnatureza_ocupacao
                                                                       ,rw_restricao.qtnegati --qtrestricao_externa
                                                                       ,rw_restricao.vlmaxneg --vlnegativacao_externa
                                                                       ,rw_flgresre --flgrestricao_relevante
                                                                       ,pr_qtadidep --qtadiantamento_depositante
                                                                       ,pr_qtchqesp --qtcheque_especial
                                                                       ,pr_qtdevalo --qtdev_alinea_onze
                                                                       ,pr_qtdevald --qtdev_alinea_doze
                                                                       ,pr_cdsitres --cdsituacao_residencia
                                                                       ,pr_vlpreatv --vlprestacao_ativa
                                                                       ,pr_vlsalari --vlsalario
                                                                       ,pr_vlrendim --vloutros_rendimentos
                                                                       ,pr_vlsalcje --vlsalario_conjuge
                                                                       ,pr_vlendivi --vlendividamento
                                                                       ,rw_vlbemtit.vlbemtit --vlbem_titular
                                                                       ,pr_flgcjeco --flgconjuge_corresponsavel
                                                                       ,rw_vlbemcje.vlbemcje --vlbem_conjuge
                                                                       ,pr_vlsldeve --vlsaldo_devedor
                                                                       ,pr_vlopeatu --vloperacao_atual
                                                                       ,pr_vlslcota --vlsaldo_cotas
                                                                       ,pr_cdquaope --cdqualificacao_operacao
                                                                       ,pr_cdtpoper --cdtipo_operacao
                                                                       ,pr_cdlincre --cdlinha_credito
                                                                       ,pr_cdmodali --cdmodalidade_linha_cred
                                                                       ,pr_cdsubmod --cdsubmodalidade_linha_cred
                                                                       ,pr_cdgarope --cdgarantia_operacao
                                                                       ,pr_cdliqgar --cdliquidez_garantia
                                                                       ,pr_qtpreope --qtprestacao_operacao
                                                                       ,pr_dtfunemp --dtfundacao_empresa
                                                                       ,pr_cdseteco --cdsetor_economico
                                                                       ,pr_dtprisoc --dtprimeiro_socio
                                                                       ,pr_prfatcli --prfaturamento_cliente
                                                                       ,pr_vlmedfat --vlmedia_faturamento_anual
                                                                       ,rw_vlbemavt.vlbemavt --vlbem_avalista
                                                                       ,rw_vlbemsoc.vlbemsoc --vlbem_socio
                                                                       ,pr_vlparope --vlparcela_operacao
                                                                       ,pr_cdperemp --cdpercepcao_empresa
                                                                       ,pr_dstpoper --dstipo_operacao
                                                                       );
  EXCEPTION
    WHEN vr_exc_erro THEN
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro não tratado na pc_grava_his_crapnrc ' ||
                     SQLERRM;
  END pc_grava_his_crapnrc2;
  PROCEDURE pc_grava_his_crapras(pr_cdcooper IN crapcop.cdcooper%type
                                ,pr_nrdconta IN crapass.nrdconta%type
                                ,pr_nrctrrat IN crapnrc.nrctrrat%type
                                ,pr_tpctrrat IN crapnrc.tpctrrat%type
                                ,pr_nrtopico IN crapras.nrtopico%type
                                ,pr_nritetop IN crapras.nritetop%type
                                ,pr_nrseqite IN crapras.nrseqite%type
                                ,pr_dsvalite IN crapras.dsvalite%type
                                ,pr_cdcritic OUT crapcri.cdcritic%type
                                ,pr_dscritic OUT crapcri.dscritic%type
                                ) IS
    vr_nrseqrat number(3);
    vr_cdcritic crapcri.cdcritic%type;
    vr_dscritic crapcri.dscritic%type;
    vr_exc_erro exception;
    function fn_retorna_sequencia return number is
      cursor c1 is
        select nvl(max(nrseqrat),0) + 1
          from tbrat_hist_cooperado
         where cdcooper = pr_cdcooper
           and nrdconta = pr_nrdconta
           and nrctrrat = pr_nrctrrat
           and tpctrrat = pr_tpctrrat
           and nrtopico = pr_nrtopico
           and nritetop = pr_nritetop;
      vr_sequen number(3);
    begin
      open c1;
      fetch c1 into vr_sequen;
      close c1;
      return vr_sequen;
    exception
      when others then
        vr_dscritic := 'Erro ao buscar sequencia - TABELA tbhis_rating_associado - '||sqlerrm;
    end fn_retorna_sequencia;
  BEGIN
    vr_nrseqrat := fn_retorna_sequencia;
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    insert into tbrat_hist_cooperado(cdcooper
                                    ,nrdconta
                                    ,nrctrrat
                                    ,tpctrrat
                                    ,nrseqrat
                                    ,nrtopico
                                    ,nritetop
                                    ,nrseqite
                                    ,dsvalite
                                    ,dtmvtolt) values (pr_cdcooper
                                                      ,pr_nrdconta
                                                      ,pr_nrctrrat
                                                      ,pr_tpctrrat
                                                      ,vr_nrseqrat
                                                      ,pr_nrtopico
                                                      ,pr_nritetop
                                                      ,pr_nrseqite
                                                      ,pr_dsvalite
                                                      ,sysdate);
  EXCEPTION
    WHEN vr_exc_erro THEN
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro não tratado na pc_grava_his_crapras ' ||
                     SQLERRM;
  END pc_grava_his_crapras;


  /* Rotina responsavel por buscar a qualificacao da operacao alterada pelo controle */
  FUNCTION fn_verifica_qualificacao (pr_nrdconta IN NUMBER  --> Número da conta
                                    ,pr_nrctremp IN NUMBER  --> Contrato
                                    ,pr_idquapro IN NUMBER  --> Id Qualif Operacao
                                    ,pr_cdcooper IN NUMBER) RETURN INTEGER IS
  BEGIN
  /* ..........................................................................

     Programa: pc_verifica_qualificacao         Antigo: b1wgen0043.p/verificaQualificacao
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Diego Simas (AMcom)
     Data    : Janeiro/2018.                          Ultima Atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  : Buscar o id da qualificação da operação
                 quando alterada pelo Controle.

     Alteracoes:

  ............................................................................. */
    DECLARE

    CURSOR cr_consulta_qualificacao (pr_nrdconta IN crapepr.nrdconta%TYPE
                                    ,pr_nrctremp IN crapepr.nrctremp%TYPE
                                    ,pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        select crapepr.idquaprc
          from crapepr
         where crapepr.cdcooper = pr_cdcooper
           and crapepr.nrdconta = pr_nrdconta
           and crapepr.nrctremp = pr_nrctremp;
           rw_consulta_qualificacao cr_consulta_qualificacao%ROWTYPE;
    BEGIN
      OPEN cr_consulta_qualificacao(pr_nrdconta => pr_nrdconta  --> Número da conta
                                   ,pr_nrctremp => pr_nrctremp  --> Contrato
                                   ,pr_cdcooper => pr_cdcooper);

      FETCH cr_consulta_qualificacao INTO rw_consulta_qualificacao;

      IF cr_consulta_qualificacao%NOTFOUND THEN

        --Fechar o cursor
        CLOSE cr_consulta_qualificacao;

        RETURN pr_idquapro;

      ELSE
        --Fechar o cursor
        CLOSE cr_consulta_qualificacao;

        RETURN rw_consulta_qualificacao.idquaprc;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;
    END;
  END;

END RATI0001;
/
