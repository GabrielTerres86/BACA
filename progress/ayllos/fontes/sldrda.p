/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/sldrda.p                 | APLI0001.pc_calc_sldrda           |
  +---------------------------------+-----------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/




/* .............................................................................

   Programa: Fontes/sldrda.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Junho/94.                       Ultima atualizacao: 16/09/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para montar o saldo das aplicacoes financeiras e mostrar
               o extrato das mesmas para a tela ATENDA.

   Alteracoes: 08/12/94 - Alterado para mostrar saldo e extrato de RDCA no
                          total de aplicacoes (Deborah).

               26/04/95 - Alterado para mostrar o valor aplicado na tela atenda.
                          (Odair).

               21/09/95 - Alterado o indice de leitura para mostrar por data
                          (Deborah).

               17/10/95 - Alterado para mostrar "D" nas aplicacoes RDCA que
                          estao disponiveis (Deborah).

               27/11/96 - Tratar RDCAII (Odair).

               21/05/2001 - Disponibilizar arquivo com Extrato das Aplicacoes
                            para alimentar o auto-atendimento. (Eduardo).

               12/04/2002 - Tratar resgate on_line (Mag).

               06/01/2004 - Desprezar saldo negativos (Margarete).

               09/11/2004 - Aumentado tamanho do campo do numero da aplicacao
                            para 7 posicoes, na leitura da tabela (Evandro).
                            
               21/01/2005 - Mostrar saldo total para resgate (Margarete).
               
               01/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
               
               06/02/2006 - Inclusao de NO-UNDO nas temp-tables - SQLWorks -
                            Eder

               25/04/2007 - Alterado para os novos tipos de aplicacao (Magui).

               03/07/2007 - Tratamento para novos tipo de aplicacao (David).
               
               03/12/2007 - Substituir chamada da include aplicacao.i pela
                            BO b1wgen0004.i e rdca2s pela b1wgen0004a.i
                            (Sidnei - Precise).
                            
               16/09/2013 - Tratamento para Imunidade Tributaria (Ze).                            
............................................................................. */

{ includes/var_online.i }
{ includes/var_atenda.i }
{ includes/var_rdca2.i }
{ includes/var_faixas_ir.i "NEW"}

DEF INPUT  PARAM par_flgextra AS LOGICAL                             NO-UNDO.

DEF  VAR aux_sldresga         AS DECIMAL                             NO-UNDO.
DEF  VAR aux_vlsldrdc         AS DECIMAL DECIMALS 8                  NO-UNDO.
DEF  VAR aux_perirrgt         AS DEC DECIMALS 2                      NO-UNDO.
DEF  VAR aux_indebcre         AS CHAR FORMAT "X(01)"                 NO-UNDO.
DEF  VAR aux_vlrvtfim         LIKE craplap.vllanmto                  NO-UNDO.
DEF  VAR aux_vlrrgtot         LIKE craplap.vllanmto                  NO-UNDO.
DEF  VAR aux_vlirftot         LIKE craplap.vllanmto                  NO-UNDO.
DEF  VAR aux_vlrendmm         LIKE craplap.vlrendmm                  NO-UNDO.

DEF  VAR h-b1wgen0004         AS HANDLE                              NO-UNDO.

/******************* Variaveis RDCA para BO *******************************/

DEF        BUFFER crablap5 FOR craplap.

DEF        VAR aux_ttrenrgt AS DECIMAL DECIMALS 8                    NO-UNDO.
/* total dos rendimentos resgatados no periodo com ajuste no dia do aniver */
                                  
DEF        VAR aux_vlrenrgt AS DECIMAL DECIMALS 8                    NO-UNDO.
                               /* rendimento resgatado periodo */
DEF        VAR aux_ajtirrgt AS DECIMAL DECIMALS 8                    NO-UNDO.
                              /* IRRF pago do que foi resgatado no periodo */
DEF        VAR aux_vlrentot AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_vlrendim AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_vldperda AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_vlsdrdca AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_vlsdrdat AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_vlsdresg AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_vlprovis AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_vlajuste AS DECIMAL                               NO-UNDO.
DEF        VAR aux_vllan117 AS DECIMAL                               NO-UNDO.
DEF        VAR aux_txaplica AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_txaplmes AS DECIMAL DECIMALS 8                    NO-UNDO.

DEF        VAR aux_dtcalajt AS DATE                                  NO-UNDO.
DEF        VAR aux_dtcalcul AS DATE                                  NO-UNDO.
DEF        VAR aux_dtmvtolt AS DATE                                  NO-UNDO.
DEF        VAR aux_dtdolote AS DATE                                  NO-UNDO.
DEF        VAR aux_dtultdia AS DATE                                  NO-UNDO.
DEF        VAR aux_dtrefere AS DATE                                  NO-UNDO.

DEF        VAR aux_cdagenci AS INT     INIT 1                        NO-UNDO.
DEF        VAR aux_cdbccxlt AS INT     INIT 100                      NO-UNDO.
DEF        VAR aux_nrdolote AS INT                                   NO-UNDO.
DEF        VAR aux_cdhistor AS INT                                   NO-UNDO.
DEF        VAR aux_vlajtsld AS DEC                                   NO-UNDO.

DEF        VAR aux_flglanca AS LOGICAL                               NO-UNDO.
DEF        VAR aux_vlabcpmf AS DEC                                   NO-UNDO.
DEF        VAR aux_flgncalc AS LOG                                   NO-UNDO.
DEF        VAR aux_sldcaren AS DECIMAL DECIMALS 8                    NO-UNDO.

DEF        VAR dup_vlsdrdca AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR dup_dtcalcul AS DATE                                  NO-UNDO.
DEF        VAR dup_dtmvtolt AS DATE                                  NO-UNDO.
DEF        VAR dup_vlrentot AS DECIMAL DECIMALS 8                    NO-UNDO.

DEF VAR p-cdcooper      AS INTE                        NO-UNDO.
DEF VAR p-cod-agencia   AS INTE                        NO-UNDO.
DEF VAR p-nro-caixa     AS INTE                        NO-UNDO.
DEF VAR p-cdprogra      AS CHAR                        NO-UNDO.

DEF VAR aux_sequen   AS INTE NO-UNDO.
DEF VAR i-cod-erro   AS INTE NO-UNDO.
DEF VAR c-dsc-erro   AS CHAR NO-UNDO.
DEF VAR aux_dsmsgerr AS CHAR NO-UNDO.
   
DEFINE VARIABLE h-b1wgen05         AS HANDLE  NO-UNDO.    

{ sistema/generico/includes/var_internet.i }

/******************************************************/

DEF TEMP-TABLE craterr LIKE craperr.

ASSIGN glb_cdcritic = 0
       aux_vltotrda = 0.

IF   par_flgextra    THEN
     FOR EACH crawext:
         DELETE crawext.
     END.

/********** leituras para include da BO de Aplicacao *******/
FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper
                   NO-LOCK NO-ERROR.

FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                         NO-LOCK NO-ERROR.
                
ASSIGN p-cdcooper    = crapcop.cdcooper
       p-cod-agencia = 0
       p-nro-caixa   = 0 
       p-cdprogra    = glb_cdprogra.
/**********************************************************/      

TRANS_1:

    FOR EACH craprda WHERE craprda.cdcooper = glb_cdcooper  AND
                           craprda.nrdconta = tel_nrdconta  AND
                           craprda.insaqtot = 0             NO-LOCK
                           USE-INDEX craprda3:
          
        IF   craprda.tpaplica = 3 THEN
             DO:
                { sistema/generico/includes/b1wgen0004.i }
             END.
        ELSE
        IF   craprda.tpaplica = 5 THEN
             DO:
                { sistema/generico/includes/b1wgen0004a.i }

             END.
        ELSE
             DO:
                 FIND crapdtc WHERE crapdtc.cdcooper = glb_cdcooper     AND
                                    crapdtc.tpaplica = craprda.tpaplica
                                    NO-LOCK NO-ERROR.

                 IF   NOT AVAILABLE crapdtc THEN
                      NEXT.
                      
                 RUN sistema/generico/procedures/b1wgen0004.p 
                     PERSISTENT SET h-b1wgen0004.
                
                 IF  NOT VALID-HANDLE(h-b1wgen0004)  THEN
                     NEXT.
                
                 FOR EACH craterr:
                     DELETE craterr.
                 END.
                 
                 IF   crapdtc.tpaplrdc = 1 THEN /* RDCPRE */
                      DO:
                          RUN saldo_rdc_pre IN h-b1wgen0004 
                                                  (INPUT glb_cdcooper,
                                                   INPUT craprda.nrdconta,
                                                   INPUT craprda.nraplica,
                                                   INPUT glb_dtmvtolt,
                                                   INPUT ?,
                                                   INPUT ?,
                                                   INPUT 0,
                                                   INPUT FALSE,
                                                   INPUT-OUTPUT aux_vlsldrdc,
                                                   OUTPUT aux_vlrdirrf,
                                                   OUTPUT aux_perirrgt,
                                                   OUTPUT TABLE craterr).
                          IF   RETURN-VALUE = "NOK" THEN
                               DO:
                                   DELETE PROCEDURE h-b1wgen0004.
                                   NEXT.
                               END.
                        
                          ASSIGN aux_sldpresg = aux_vlsldrdc.
                      END.
                 ELSE
                 IF   crapdtc.tpaplrdc = 2 THEN /* RDCPOS */
                      DO:
                          RUN saldo_rdc_pos IN h-b1wgen0004
                                               (INPUT glb_cdcooper,
                                                INPUT craprda.nrdconta,
                                                INPUT craprda.nraplica,
                                                INPUT glb_dtmvtolt,
                                                INPUT glb_dtmvtolt,
                                                INPUT FALSE,
                                                INPUT FALSE,
                                                OUTPUT aux_vlsldrdc,
                                                OUTPUT aux_vlrentot,
                                                OUTPUT aux_vlrdirrf,
                                                OUTPUT aux_perirrgt,
                                                OUTPUT TABLE craterr).
                                                
                          IF   RETURN-VALUE = "NOK" THEN
                               DO:
                                   DELETE PROCEDURE h-b1wgen0004.
                                   NEXT.
                               END.
                          
                          RUN saldo_rgt_rdc_pos IN h-b1wgen0004
                                                   (INPUT glb_cdcooper,
                                                    INPUT craprda.nrdconta,
                                                    INPUT craprda.nraplica,
                                                    INPUT glb_dtmvtolt,
                                                    INPUT glb_dtmvtolt,
                                                    INPUT 0,
                                                    INPUT FALSE,
                                                    OUTPUT aux_sldpresg,
                                                    OUTPUT aux_vlrenrgt,
                                                    OUTPUT aux_vlrdirrf,
                                                    OUTPUT aux_perirrgt,
                                                    OUTPUT aux_vlrrgtot,
                                                    OUTPUT aux_vlirftot,
                                                    OUTPUT aux_vlrendmm,
                                                    OUTPUT aux_vlrvtfim,
                                                    OUTPUT TABLE craterr).
                    
                          IF   RETURN-VALUE = "NOK" THEN
                               DO:
                                   DELETE PROCEDURE h-b1wgen0004.
                                   NEXT.
                               END.
                          ASSIGN aux_sldpresg = IF   aux_vlrrgtot > 0   THEN
                                                     aux_vlrrgtot
                                                ELSE
                                                     craprda.vlsdrdca. 
                      END.
                      
                 DELETE PROCEDURE h-b1wgen0004.         
             END.
             
        ASSIGN aux_sldresga = aux_sldpresg.
        IF   aux_sldresga = ? THEN 
             ASSIGN aux_sldresga = IF   craprda.tpaplica = 3 THEN 
                                        aux_vlsdrdca
                                   ELSE
                                   IF   craprda.tpaplica = 5 THEN 
                                        rd2_vlsdrdca
                                   ELSE
                                        aux_vlsldrdc. 

        ASSIGN aux_vltotrda = aux_vltotrda + aux_sldresga
               aux_flgexlrg = YES.

        IF   craprda.tpaplica = 3 THEN
             DO:
                 IF   craprda.inaniver  = 1             OR
                     (craprda.inaniver  = 0             AND
                      craprda.dtfimper <= glb_dtmvtolt) THEN
                      ASSIGN aux_indebcre = "D". 
                 ELSE 
                      ASSIGN aux_indebcre = " ".
             END.                             
        ELSE
        IF   craprda.tpaplica = 5 THEN
             DO:
                 IF   craprda.inaniver  = 1                      OR
                    ((craprda.dtfimper <= glb_dtmvtolt)          AND 
                     (craprda.dtfimper - craprda.dtmvtolt) > 50) THEN
                      ASSIGN aux_indebcre = "D". 
                 ELSE 
                      ASSIGN aux_indebcre = " ".
             END.
        ELSE
             ASSIGN aux_indebcre = "".
             
        IF   par_flgextra THEN
             DO:
                CREATE crawext.
                ASSIGN crawext.dtmvtolt = craprda.dtmvtolt

                       crawext.dshistor = (IF   craprda.tpaplica = 3 THEN 
                                                "Apl. RDCA  :"
                                           ELSE 
                                           IF   craprda.tpaplica = 5 THEN
                                                "Apl. RDCA60:"
                                           ELSE
                                                "Apl. " + crapdtc.dsaplica + ":"
                                           ) +     
                                          STRING(craprda.vlaplica,"zzzz,zz9.99")

                       crawext.nrdocmto = STRING(craprda.nraplica,"zzzzz9") +
                                          "/001"
                       crawext.indebcre = aux_indebcre

                       crawext.vllanmto = IF   craprda.tpaplica = 3 THEN
                                               aux_vlsdrdca
                                          ELSE 
                                          IF   craprda.tpaplica = 5 THEN
                                               rd2_vlsdrdca
                                          ELSE
                                               aux_vlsldrdc.

                FIND FIRST craptab WHERE craptab.cdcooper = glb_cdcooper    AND
                                         craptab.nmsistem = "CRED"          AND
                                         craptab.tptabela = "BLQRGT"        AND
                                         craptab.cdempres = 0               AND
                                         craptab.cdacesso = 
                                                  STRING(craprda.nrdconta,
                                                             "9999999999")  AND
                                         INT(SUBSTRING(craptab.dstextab,1,7)) =
                                                       craprda.nraplica
                                         NO-LOCK NO-ERROR.

                IF   AVAILABLE craptab   THEN
                      crawext.indebcre = "B".
             END.

    END.  /*  Fim do FOR EACH  --  craprda  */

IF   glb_cdcritic > 0   THEN
     RETURN.

IF   par_flgextra          AND
     (glb_inproces = 1)    THEN
     RUN fontes/atenda_e.p.

/* .......................................................................... */
