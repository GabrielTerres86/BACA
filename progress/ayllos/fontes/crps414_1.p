/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps414_1.p              | pc_crps414_1                      |
  +---------------------------------+-----------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/    



    
/* ..........................................................................
   
   Programa: Fontes/crps414_1.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Agosto/2011.                   Ultima atualizacao: 04/08/2014

   Dados referentes ao programa:

   Frequencia: Diario (Batch - Background).
   Objetivo  : Gerar informacoes sobre emprestimos, cotas, desconto de cheques,
               aplicacoes, para os relatorios gerenciais.

   Alteracoes: 10/02/2012 - Utilizar variavel glb_flgresta para nao efetuar
                            controle de restart (David).
                            
               30/01/2013 - Criar registro da gninfpl para cada PA mesmo que
                            seja com valores zerado, exceto 90 e 91 (Evandro).
                            
               06/02/2013 - Atualizar o novo campo crapsda.vlsdcota com o saldo
                            das cotas do dia (Oscar).
                            
               27/02/2013 - Ajuste onde grava o campo crapsda.vlsdcota foi colocado 
                            (DO: END.) no primeiro IF do WHILE, pois não estava gravando 
                            o valor no campo, porque não estava executando o código  
                            do ELSE deste IF principal. (Oscar).
                            
               16/09/2013 - Tratamento para Imunidade Tributaria (Ze).
               
               30/10/2013 - Incluir chamada da procedure controla_imunidade
                            (Lucas R.)
                            
               22/01/2014 - Incluir VALIDATE gnlcred, gninfpl (Lucas R.).
               
               03/02/2014 - Remover a chamada da procedure "saldo_epr.p".(James)
               
               05/06/2014 - Alterado format do cdlcremp de 3 para 4 
                            Softdesk 137074 (Lucas R.)
                            
               04/08/2014 - Alteração da Nomeclatura para PA (Vanessa).
............................................................................ */
{ includes/var_batch.i "NEW" } 
{ includes/var_atenda.i "NEW" }

/* Variaveis para controle da execucao em paralelo */
DEF VAR aux_idparale AS INT                                            NO-UNDO.
DEF VAR aux_idprogra AS INT                                            NO-UNDO.
DEF VAR aux_cdagenci AS INT                                            NO-UNDO.
DEF VAR h_paralelo   AS HANDLE                                         NO-UNDO.

/* Variaveis da rotina de emprestimos */
DEF VAR tmp_qtctremp AS INT                                            NO-UNDO.
DEF VAR tmp_vlemprst AS DEC                                            NO-UNDO.

/* Variaveis da rotina de cotas */
DEF VAR aux_flgfirst AS LOGICAL                                        NO-UNDO.
DEF VAR aux_cdagecot AS INTEGER                                        NO-UNDO.
DEF VAR res_vlcapati AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"            NO-UNDO.
DEF VAR aux_vltotrii AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"            NO-UNDO.
DEF VAR aux_vltotrdc AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"            NO-UNDO.
DEF VAR age_qtcapati AS INTEGER                                        NO-UNDO.

DEF VAR aux_tpaplica AS INTEGER                                        NO-UNDO.
DEF VAR aux_vlsldrdc AS DECIMAL DECIMALS 8                             NO-UNDO.
DEF VAR aux_perirrgt AS DECIMAL DECIMALS 2                             NO-UNDO.
DEF VAR aux_vlrdcpre AS DECIMAL DECIMALS 8                             NO-UNDO.
DEF VAR aux_vlrdcpos AS DECIMAL DECIMALS 8                             NO-UNDO.

DEF VAR h-b1wgen0004 AS HANDLE                                         NO-UNDO.

DEF TEMP-TABLE craterr NO-UNDO LIKE craperr.

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

DEF VAR aux_sequen      AS INTE                        NO-UNDO.
DEF VAR i-cod-erro      AS INTE                        NO-UNDO.
DEF VAR c-dsc-erro      AS CHAR                        NO-UNDO.
DEF VAR aux_dsmsgerr    AS CHAR                        NO-UNDO.
   
DEFINE VARIABLE h-b1wgen05         AS HANDLE  NO-UNDO.    

{ sistema/generico/includes/var_internet.i }

/******************************************************/

/* recebe os parametros de sessao (criterio de separacao) */
ASSIGN glb_cdprogra = "crps414"
       glb_flgresta = FALSE  /* Sem controle de restart */
       aux_idparale = INT(ENTRY(1,SESSION:PARAMETER))
       aux_idprogra = INT(ENTRY(2,SESSION:PARAMETER))
       aux_cdagenci = aux_idprogra.

RUN fontes/iniprg.p.
IF   glb_cdcritic > 0 THEN
     QUIT.

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         ASSIGN glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> log/proc_batch.log").
         QUIT.
     END.

/********** leituras para include da BO de Aplicacao *******/
FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                         NO-LOCK NO-ERROR.
                
ASSIGN p-cdcooper    = crapcop.cdcooper
       p-cod-agencia = 0
       p-nro-caixa   = 0 
       p-cdprogra    = "crps414".
/**********************************************************/ 
  
RUN sistema/generico/procedures/b1wgen0004.p
                PERSISTENT SET h-b1wgen0004.
                
IF  NOT VALID-HANDLE(h-b1wgen0004)  THEN
    DO:
        UNIX SILENT VALUE("echo " + 
                          STRING(TIME,"HH:MM:SS") +
                          " - " + glb_cdprogra + "' --> '" +
                          "Handle Invalido para BO b1wgen0004" +
                          " >> log/proc_batch.log").
                                          
        QUIT.
    END.

/* instancia b1wgen0159 */ 
RUN controla_imunidade IN h-b1wgen0004 
                      (INPUT TRUE, /* instancia */
                       INPUT FALSE, /* deleta */
                       INPUT glb_cdprogra).

{ includes/var_rdca2.i }
{ includes/var_faixas_ir.i "NEW" }

FOR EACH crapass WHERE crapass.cdcooper = glb_cdcooper   AND
                       crapass.cdagenci = aux_cdagenci   NO-LOCK:

    /***  Rotina para gravacao de dados de emprestimo  ***/
    FOR EACH crapepr WHERE crapepr.cdcooper = glb_cdcooper      AND
                           crapepr.nrdconta = crapass.nrdconta  AND
                           crapepr.inliquid <> 1                NO-LOCK
                           BREAK BY crapepr.cdlcremp:

        IF   FIRST-OF(crapepr.cdlcremp)   THEN
             ASSIGN tmp_qtctremp = 0
                    tmp_vlemprst = 0.

        IF  (MONTH(glb_dtmvtolt) <> MONTH(glb_dtmvtopr))  THEN   /* Mensal */
            /* Saldo calculado pelo 78*/
            ASSIGN aux_vlsdeved = crapepr.vlsdeved.
        ELSE
            DO:
                /* Saldo calculado pelo crps616.p e crps665.p */
                ASSIGN aux_vlsdeved = crapepr.vlsdevat.
                
                IF crapepr.tpemprst = 0 THEN
                   ASSIGN aux_qtprecal = crapepr.qtlcalat.
                ELSE
                   ASSIGN aux_qtprecal = crapepr.qtpcalat.
            END.

        /* contabiliza somente se o emprestimo tem saldo */
        IF  aux_vlsdeved > 0  THEN
            ASSIGN tmp_qtctremp = tmp_qtctremp + 1
                   tmp_vlemprst = tmp_vlemprst + aux_vlsdeved.

        /* grava somente se teve valor */
        IF  LAST-OF(crapepr.cdlcremp)  AND
            tmp_vlemprst > 0           THEN
            DO:
                DO  WHILE TRUE:

                    FIND gnlcred WHERE
                         gnlcred.dtmvtolt = glb_dtmvtolt     AND
                         gnlcred.cdcooper = crapcop.cdcooper AND
                         gnlcred.cdagenci = crapass.cdagenci AND
                         gnlcred.cdlcremp = crapepr.cdlcremp
                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF   NOT AVAILABLE gnlcred THEN
                         IF   LOCKED gnlcred THEN
                              DO:
                                 PAUSE 1 NO-MESSAGE.
                                 NEXT.
                              END.
                         ELSE
                              DO:
                                 CREATE gnlcred.
                                 ASSIGN gnlcred.cdcooper = crapcop.cdcooper
                                        gnlcred.cdagenci = crapass.cdagenci
                                        gnlcred.dtmvtolt = glb_dtmvtolt
                                        gnlcred.cdlcremp = crapepr.cdlcremp.
                                 
                             END.

                    LEAVE.
                END.

                FIND craplcr WHERE craplcr.cdcooper = glb_cdcooper     AND
                                   craplcr.cdlcremp = gnlcred.cdlcremp NO-LOCK.

                IF   NOT AVAILABLE craplcr   THEN
                     ASSIGN gnlcred.dslcremp = STRING(craplcr.cdlcremp,"9999")
                                               + " - NAO CADASTRADA!".
                ELSE
                     ASSIGN gnlcred.dslcremp = STRING(craplcr.cdlcremp,"9999")
                                               + " - " + craplcr.dslcremp.
                
                ASSIGN gnlcred.qtassoci = gnlcred.qtassoci + 1
                       gnlcred.qtctremp = gnlcred.qtctremp + tmp_qtctremp
                       gnlcred.vlemprst = gnlcred.vlemprst + tmp_vlemprst.
                VALIDATE gnlcred.

            END. /* Fim LAST-OF */

    END.   /*  Fim do FOR EACH crapepr  */


    
    /***  Rotina para gravacao de dados de cotas  ***/
    IF  crapass.dtdemiss = ?  THEN
        DO:
            FIND crapcot WHERE crapcot.cdcooper = glb_cdcooper      AND
                               crapcot.nrdconta = crapass.nrdconta
                               NO-LOCK NO-ERROR.
   
            ASSIGN res_vlcapati = res_vlcapati + crapcot.vldcotas.

            IF  crapass.inmatric = 1 THEN
                ASSIGN age_qtcapati = age_qtcapati + 1.

            /* Atualizar crapsda o novo campo o valor do saldo de cotas do dia             */
            DO WHILE TRUE:
               
               FIND crapsda WHERE crapsda.cdcooper = glb_cdcooper
                              AND crapsda.nrdconta = crapass.nrdconta
                              AND crapsda.dtmvtolt = glb_dtmvtolt
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
               
               IF   NOT AVAILABLE crapsda THEN
                    DO:
                        IF   LOCKED crapsda THEN
                             DO:
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                             END.
                    END. 
               ELSE
                    DO:
                        ASSIGN crapsda.vlsdcota = crapcot.vldcotas.
                    END.           

               RELEASE crapsda NO-ERROR.
               
               LEAVE.
            END.  /*  Fim do DO WHILE TRUE  */
        END.






    /*  Totaliza o montante de cheques descontados por agencia */
    FOR EACH crapcdb WHERE crapcdb.cdcooper = glb_cdcooper      AND 
                           crapcdb.nrdconta = crapass.nrdconta  AND
                           crapcdb.insitchq = 2                 AND
                           crapcdb.dtlibera > glb_dtmvtolt      NO-LOCK:

        ASSIGN aux_vldscchq = aux_vldscchq + crapcdb.vlcheque.
    END.
    



    /*  Totaliza o montante de titulos descontados por agencia */
    FOR EACH craptdb WHERE (craptdb.cdcooper = glb_cdcooper      AND 
                            craptdb.nrdconta = crapass.nrdconta  AND
                            craptdb.insittit = 4                 AND
                            craptdb.dtvencto >= glb_dtmvtolt)
                           OR
                           (craptdb.cdcooper = glb_cdcooper      AND
                            craptdb.nrdconta = crapass.nrdconta  AND
                            craptdb.insittit = 2                 AND
                            craptdb.dtdpagto = glb_dtmvtolt)     NO-LOCK:
        
        FIND crapcob WHERE crapcob.cdcooper = glb_cdcooper     AND
                           crapcob.cdbandoc = craptdb.cdbandoc AND
                           crapcob.nrdctabb = craptdb.nrdctabb AND
                           crapcob.nrcnvcob = craptdb.nrcnvcob AND
                           crapcob.nrdconta = craptdb.nrdconta AND
                           crapcob.nrdocmto = craptdb.nrdocmto 
                           NO-LOCK NO-ERROR.
                                   
        IF   NOT AVAILABLE crapcob   THEN
             DO:
                 UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + 
                                   " - " + glb_cdprogra + "' --> '" + 
                                   "'Titulo em desconto nao encontrado" +
                                   " no crapcob - ROWID(craptdb) = " +
                                   STRING(ROWID(craptdb)) +
                                   "' >> log/proc_batch.log").
                 NEXT.
             END.
                
        /*  Se foi pago via CAIXA, InternetBank ou TAA
            Despreza, pois ja esta pago, o dinheiro ja entrou para a
            cooperativa */
        IF  craptdb.insittit = 2  AND
           (crapcob.indpagto = 1  OR
            crapcob.indpagto = 3  OR
            crapcob.indpagto = 4) THEN  /** TAA **/
            NEXT.    
        
        ASSIGN aux_vldsctit = aux_vldsctit + craptdb.vltitulo.
    END.  /*  Fim do FOR EACH craptdb  */



    /* Calcula aplicacoes RDCA30 e RDCA60 por PA */
    TRANS_1:
    
    DO  aux_tpaplica = 1 TO 8:
    
        IF  NOT CAN-DO("3,5,7,8",STRING(aux_tpaplica))  THEN
            NEXT.
    
        FOR EACH craprda WHERE craprda.cdcooper = glb_cdcooper      AND
                               craprda.tpaplica = aux_tpaplica      AND
                               craprda.insaqtot = 0                 AND
                               craprda.cdageass = crapass.cdagenci  AND
                               craprda.nrdconta = crapass.nrdconta  NO-LOCK:
                         
            /* Calcular o Saldo da aplicacao ate a data do movimento */
            IF  craprda.tpaplica = 3  THEN
                DO:
                   { sistema/generico/includes/b1wgen0004.i }
                                 
                    IF  aux_vlsdrdca > 0  THEN
                        ASSIGN aux_vltotrdc = aux_vltotrdc + aux_vlsdrdca.
                END.
            ELSE
            IF  craprda.tpaplica = 5  THEN
                DO:
                   { includes/rdca2c.i }
                                       
                    IF  rd2_vlsdrdca > 0  THEN
                        ASSIGN aux_vltotrii = aux_vltotrii + rd2_vlsdrdca.
                END.
            ELSE
                DO:
                    FIND crapdtc WHERE crapdtc.cdcooper = glb_cdcooper     AND
                                       crapdtc.tpaplica = craprda.tpaplica
                                       NO-LOCK NO-ERROR.
        
                    IF  NOT AVAILABLE crapdtc  THEN
                        DO:
                            ASSIGN glb_cdcritic = 346.
                            RUN fontes/critic.p.
                                 
                            UNIX SILENT VALUE(
                                 "echo " + STRING(TIME,"HH:MM:SS") +
                                 " - " + glb_cdprogra + "' --> '" +
                                 glb_dscritic + " Conta/dv: " +
                                 STRING(craprda.nrdconta,"zzzz,zzz,9") +
                                 " Nr.Aplicacao: " +
                                 STRING(craprda.nraplica,"zzz,zz9") +
                                 " >> log/proc_batch.log").
                                
                            ASSIGN glb_cdcritic = 0.
                            NEXT.      
                        END.
        
                    EMPTY TEMP-TABLE craterr.
                                      
                    ASSIGN aux_vlsldrdc = 0.    
        
                    IF  crapdtc.tpaplrdc = 1  THEN /* RDCPRE */
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
                             
                            IF  RETURN-VALUE = "NOK"  THEN
                                DO:
                                    FIND FIRST craterr NO-LOCK NO-ERROR.
                                          
                                    IF  AVAILABLE craterr  THEN
                                        ASSIGN glb_dscritic = craterr.dscritic.
        
                                    UNIX SILENT VALUE(
                                         "echo " + STRING(TIME,"HH:MM:SS") +
                                         " - " + glb_cdprogra + "' --> '" +
                                         glb_dscritic + " Conta/dv: " +
                                         STRING(craprda.nrdconta,"zzzz,zzz,9")
                                         + " Nr.Aplicacao: " +
                                         STRING(craprda.nraplica,"zzz,zz9") +
                                         " >> log/proc_batch.log").
                                    NEXT.
                                END.
        
                            IF  aux_vlsldrdc > 0  THEN
                                ASSIGN aux_vlrdcpre = aux_vlrdcpre +
                                                      aux_vlsldrdc.
                        END.
                    ELSE
                    IF  crapdtc.tpaplrdc = 2  THEN /* RDCPOS */
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
        
                            IF  RETURN-VALUE = "NOK"  THEN
                                DO:
                                    FIND FIRST craterr NO-LOCK NO-ERROR.
                                         
                                    IF  AVAILABLE craterr  THEN
                                        ASSIGN glb_dscritic = craterr.dscritic.
        
                                    UNIX SILENT VALUE(
                                         "echo " + STRING(TIME,"HH:MM:SS") +
                                         " - " + glb_cdprogra + "' --> '" +
                                         glb_dscritic + " Conta/dv: " +
                                         STRING(craprda.nrdconta,"zzzz,zzz,9")
                                         + " Nr.Aplicacao: " +
                                         STRING(craprda.nraplica,"zzz,zz9") +
                                         " >> log/proc_batch.log").          
                                    NEXT.   
                                END. 
                                 
                            IF  aux_vlsldrdc > 0  THEN
                                ASSIGN aux_vlrdcpos = aux_vlrdcpos +
                                                      aux_vlsldrdc.     
                        END.
                END.
        
        END. /* Fim do FOR EACH craprda */
        
    
    END. /* Fim DO..TO */
END. /* Fim crapass */

FIND crapage WHERE crapage.cdcooper = glb_cdcooper  AND
                   crapage.cdagenci = aux_cdagenci  NO-LOCK NO-ERROR.

/* se contabilizou algo OU é PA ATIVO, grava as contabilizacoes na tabela */
IF (age_qtcapati + res_vlcapati + aux_vldscchq + aux_vldsctit +
    aux_vltotrdc + aux_vltotrii + aux_vlrdcpre + aux_vlrdcpos > 0)   
    OR
   (aux_cdagenci     <> 90  AND   /* INTERNET  */
    aux_cdagenci     <> 91  AND   /* TAA       */
    crapage.insitage  = 1)        /* PA ATIVO */
    THEN
    DO:
        DO WHILE TRUE:
            
           FIND gninfpl WHERE gninfpl.cdcooper = glb_cdcooper  AND
                              gninfpl.cdagenci = aux_cdagenci  AND
                              gninfpl.dtmvtolt = glb_dtmvtolt
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        
           IF   NOT AVAILABLE gninfpl THEN
                IF   LOCKED gninfpl THEN
                     DO:
                         PAUSE 1 NO-MESSAGE.
                         NEXT.
                     END.
                ELSE
                     DO:
                         CREATE gninfpl.
                         ASSIGN gninfpl.cdcooper = glb_cdcooper
                                gninfpl.cdagenci = aux_cdagenci
                                gninfpl.dtmvtolt = glb_dtmvtolt.
                     END.           
           
           LEAVE.
        END.  /*  Fim do DO WHILE TRUE  */
        
        ASSIGN gninfpl.qtcotati = age_qtcapati
               gninfpl.vldcotas = res_vlcapati
               gninfpl.vltotdsc = aux_vldscchq
               gninfpl.vltottit = aux_vldsctit
               gninfpl.vlrdca30 = aux_vltotrdc
               gninfpl.vlrdca60 = aux_vltotrii
               gninfpl.vlrdcpre = aux_vlrdcpre
               gninfpl.vlrdcpos = aux_vlrdcpos.
        VALIDATE gninfpl.
    END.

/* deletar instancia da b1wgen0159 */
RUN controla_imunidade IN h-b1wgen0004 
                      (INPUT FALSE, /* instancia */
                       INPUT TRUE, /* deleta */
                       INPUT glb_cdprogra).

DELETE PROCEDURE h-b1wgen0004.

RUN sistema/generico/procedures/bo_paralelo.p PERSISTENT SET h_paralelo.

RUN finaliza_paralelo IN h_paralelo (INPUT aux_idparale,
                                     INPUT aux_idprogra).
DELETE PROCEDURE h_paralelo.
UNIX SILENT VALUE("echo " + 
                  STRING(glb_dtmvtolt,"99/99/9999") + " - " +
                  STRING(TIME,"HH:MM:SS") +
                  " - " + glb_cdprogra + "' -->    '" +
                  "Fim da Execucao Paralela - PA: " +
                  STRING(aux_cdagenci,"zz9") +
                  " >> log/crps414.log").

QUIT.


/* .......................................................................... */


