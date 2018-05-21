/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/geradev.p                | CHEQ0001.pc_gera_devolucao_cheque |
  +---------------------------------+-----------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)
   
*******************************************************************************/



/* .............................................................................

   Programa: Fontes/geradev.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Outubro/94.                     Ultima atualizacao: 23/12/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para criar registros de devolucao/taxa de cheques.

   Alteracoes: 16/05/95 - Alterado para incluir o parametro aux_cdalinea
                          (Edson).

               21/01/96 - Alterado para nao gerar taxa de devolucao para as
                          alineas 28 e 29 (Deborah).

               24/01/97 - Alterado para tratar historico 191 no lugar do
                          47 (Deborah).

               22/06/99 - Tratar novos parametros para devolucao(Odair)

               28/08/2001 - Tratar alinea 20 (Deborah).
               
               11/10/2004 - Tratar alinea 72 (Ze).
               
               17/12/2004 - Tratar RECID do craplcm (Edson).

               22/04/2005 - Tratar alinea 32 (Edson).
               
               27/06/2005 - Melhorar a forma como mostra a SOMA dos lotes
                            na pesquisa da devolucao (Edson).

               01/07/2005 - Alimentado campo cdcooper da tabela crapdev (Diego).
               
               11/07/2005 - Melhorar a forma como mostra a SOMA dos lotes
                            na pesquisa da devolucao (Edson).

               01/11/2005 - Tratar conta integracao (Edson).
               
               09/12/2005 - Tratamento da estratura do crapfdc (ZE).
               
               22/12/2005 - Identificacao se eh conta integracao (ZE).
                
               10/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando. 
               
               15/12/2006 - Tratar Alinea 35 para nao cobrar tarifa (Ze).
               
               12/02/2007 - Efetuada alteracao para nova estrutura crapdev
                            (Diego).
                            
               06/03/2007 - Ajustes para o Bancoob (Magui).
               
               03/08/2007 - Tratar Alinea 30 para nao cobrar tarifa (Ze).
               
               30/03/2010 - Passa a utilizar o par_cdcooper ao inves do
                            glb_cdcooper (Ze).
                            
               25/06/2009 - Inclusao de tratamento para Devolucoes banco CECRED
                            (Guilherme/Supero).
                            
               06/06/2011 - Tratamento para a alinea 37 e 39 - Truncagem (Ze).
               
               07/07/2011 - Nao tarifar devolucao de alinea 31 (Diego).
               
               03/08/2012 - Enviar email quando inchqdev = 1 ou 3 e cdbanchq = 1
                            ou 756. (Fabricio)
                            
               06/08/2012 - Adicionado parametro de entrada par_cdprogra. 
                            (Fabricio)
                            
               20/12/2012 - Adaptacao para a Migracao AltoVale (Ze).
               
               10/06/2013 - Alteração função enviar_email_completo para
                            nova versão (Jean Michel). 
                            
               13/08/2013 - Exclusao da alinea 29. (Fabricio)
               
               13/11/2013 - Tratamento para Migracao para Viacredi (Ze).
               
               10/12/2013 - Inclusao de VALIDATE crapdev (Carlos)
               
               09/01/2014 - Tratamento Migracao Acredi/Viacredi (Ze).
               
               23/12/2015 - Adicionar parametro de saida para a descricao da 
                            critica, e utilizar a procedure convertida em 
                            Oracle (Douglas - Melhoria 100)
                            
               20/06/2017 - Removida leitura da craptab.cdacesso = “VALORESVLB” 
                            e atribuir ZERO para a variável aux_vlchqvlb. 
                            PRJ367 - Compe Sessao Unica (Lombardi)
                            
............................................................................. */

{ sistema/generico/includes/var_oracle.i }

{ includes/var_online.i }

DEF INPUT  PARAM par_cdcooper AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_dtmvtolt AS DATE                                NO-UNDO.
DEF INPUT  PARAM par_cdbccxlt AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_inchqdev AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_nrdconta AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_nrdocmto AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_nrdctitg AS CHAR                                NO-UNDO.
DEF INPUT  PARAM par_vllanmto AS DECIMAL                             NO-UNDO.
DEF INPUT  PARAM par_cdalinea AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_cdhistor AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_cdoperad AS CHAR                                NO-UNDO.
DEF INPUT  PARAM par_cdagechq LIKE crapfdc.cdagechq                  NO-UNDO.
DEF INPUT  PARAM par_nrctachq LIKE crapfdc.nrctachq                  NO-UNDO.
DEF INPUT  PARAM par_cdprogra AS CHAR                                NO-UNDO.
DEF OUTPUT PARAM par_cdcritic AS INT                                 NO-UNDO.
DEF OUTPUT PARAM par_dscritic AS CHAR                                NO-UNDO.

DEF        VAR aux_cdbanchq AS INT                                   NO-UNDO.
DEF        VAR aux_vlchqvlb AS DECI                                  NO-UNDO.

DEF        VAR aux_cdcritic AS INTE                                  NO-UNDO.
DEF        VAR aux_des_erro AS CHAR                                  NO-UNDO.


/*  Busca dados da cooperativa  */

FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         MESSAGE glb_dscritic.
         BELL.
         glb_cdcritic = 0.
         NEXT.
     END.

aux_vlchqvlb = 0.

ASSIGN par_cdcritic = 0
       aux_cdbanchq = IF   par_cdbccxlt = 756 THEN
                           756
                      ELSE
                      IF   par_cdbccxlt = crapcop.cdbcoctl THEN
                           crapcop.cdbcoctl
                      ELSE 1.

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }    

/* Gera a devolução */
RUN STORED-PROCEDURE pc_gera_devolu_cheque_car
   aux_handproc = PROC-HANDLE NO-ERROR ( INPUT par_cdcooper, /* pr_cdcooper */
                                         INPUT STRING(par_dtmvtolt,"99/99/9999"), /* pr_dtmvtolt */
                                         INPUT par_cdbccxlt, /* pr_cdbccxlt */
                                         INPUT aux_cdbanchq, /* pr_cdbcoctl */
                                         INPUT par_inchqdev, /* pr_inchqdev */
                                         INPUT par_nrdconta, /* pr_nrdconta */
                                         INPUT par_nrdocmto, /* pr_nrdocmto */
                                         INPUT par_nrdctitg, /* pr_nrdctitg */
                                         INPUT par_vllanmto, /* pr_vllanmto */
                                         INPUT par_cdalinea, /* pr_cdalinea */
                                         INPUT par_cdhistor, /* pr_cdhistor */
                                         INPUT par_cdoperad, /* pr_cdoperad */
                                         INPUT par_cdagechq, /* pr_cdagechq */
                                         INPUT par_nrctachq, /* pr_nrctachq */
                                         INPUT par_cdprogra, /* pr_cdprogra */
                                         INPUT INTE(glb_nrdrecid), /* pr_nrdrecid */
                                         INPUT aux_vlchqvlb, /* pr_vlchqvlb */
                                        OUTPUT 0,            /* pr_cdcritic */
                                        OUTPUT "").          /* pr_des_erro */

CLOSE STORED-PROC pc_gera_devolu_cheque_car
   aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN aux_cdcritic = 0
       aux_des_erro = ""
       aux_cdcritic = pc_gera_devolu_cheque_car.pr_cdcritic 
                          WHEN pc_gera_devolu_cheque_car.pr_cdcritic <> ?
       aux_des_erro = pc_gera_devolu_cheque_car.pr_des_erro
                          WHEN pc_gera_devolu_cheque_car.pr_des_erro <> ?. 

IF aux_cdcritic > 0 THEN
    ASSIGN par_cdcritic = aux_cdcritic.

IF aux_des_erro <> "" THEN
    ASSIGN par_dscritic = aux_des_erro.
/* .......................................................................... */
