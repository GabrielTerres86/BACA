/* .............................................................................

   Programa: Fontes/crps320.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Junior
   Data    : Marco/2002.                        Ultima atualizacao: 01/03/2016

   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Solicitar novos cartoes magneticos quando os atuais estao 
               vencidos. Gera relatorio crrl448 - Rejeitados.
               Atende a solicitacao 081.
               Ordem do programa na solicitacao: 001.

   Alteracoes: 14/06/2002 - Se houver registro de transferencia nao renovar o
                            cartao magnetico (Deborah).

               17/04/2003 - Bloquear a execucao da Creditextil por falta de 
                            cartoes (Deborah).

               23/07/2003 - Eliminar o bloqueio anterior (Edson).

               09/12/2003 - Melhorar a logica de pesquisa dos cartoes a serem
                            renovados (Deborah).
                            
               03/03/2004 - Elaborar nova rotina para calculo de data para
                            pesquisa dos cartoes a serem renovados (Junior).

               30/06/2005 - Alimentado campo cdcooper do buffer crabcrm (Diego).

               16/02/2006 - Unificacao dos bancos - SQLWorks - Eder

               20/03/2007 - Tratamento no nome do titular do cartao e gerar
                            relatorio de renovacoes rejeitadas (David).
                            
               28/03/2007 - Alterar prazo de vencimento para 5 anos (David). 
               
               19/01/2012 - Alterado nrsencar para dssencar (Guilherme).
               
               05/07/2013 - Incluída verificação para conta encerrada (Douglas).
               
               21/01/2014 - Incluir VALIDATE crabcrm (Lucas R.)
               
               24/03/2014 - Ajuste para buscar a proxima sequencia do campo
                            crapmat.nrseqcar apartir da sequence banco Oracle. 
                            (James)
                            
               11/12/2014 - Conversão da fn_sequence para procedure para não
                            gerar cursores abertos no Oracle. (Dionathan)
                            
               24/07/2015 - Ajuste na gravacao do cartao magnetico. (James)             

               01/03/2016 - Bloquear a solicitacao automatica de cartao magnetico, 
                            gerando as informacoes do cartao como rejeitados no 
                            relatorio 488. Os cartoes de operador devem continuar 
                            sendo solicitados. (Douglas - Chamado 392642)
............................................................................. */

{ includes/var_batch.i {1} }
{ sistema/generico/includes/var_oracle.i }

DEF STREAM str_1.

DEF BUFFER crabcrm FOR crapcrm.

DEF TEMP-TABLE w-rejeitados
    FIELD cdagenci LIKE crapass.cdagenci
    FIELD nrdconta LIKE crapcrm.nrdconta
    FIELD nmtitcrd LIKE crapcrm.nmtitcrd
    FIELD nrcartao LIKE crapcrm.nrcartao
    FIELD dtvalcar LIKE crapcrm.dtvalcar
    FIELD dscritic LIKE crapcri.dscritic
    FIELD tpusucar AS LOGI FORMAT "PRIMEIRO TITULAR/SEGUNDO TITULAR".
    
DEF VAR aux_dtinicrm  AS DATE                                          NO-UNDO.
DEF VAR aux_dtfimcrm  AS DATE                                          NO-UNDO.
DEF VAR flg_cartaoex  AS LOGICAL                                       NO-UNDO.
DEF VAR aux_nrseqcar  AS INT        FORMAT "zzz,zz9"                   NO-UNDO.
DEF VAR aux_nrdeanos  AS INT                                           NO-UNDO.
DEF VAR aux_dtvalnew  AS DATE                                          NO-UNDO.
DEF VAR aux_nmabrevi  AS CHAR                                          NO-UNDO.

DEF VAR rel_nmempres AS CHAR         FORMAT "x(15)"                   NO-UNDO.
DEF VAR rel_nmrelato AS CHAR         FORMAT "x(40)" EXTENT 5          NO-UNDO.

DEF VAR rel_nrmodulo AS INT          FORMAT "9"                       NO-UNDO.
DEF VAR rel_nmmodulo AS CHAR         FORMAT "x(15)" EXTENT 5
                                       INIT ["DEP. A VISTA   ",
                                             "CAPITAL        ",
                                             "EMPRESTIMOS    ",
                                             "DIGITACAO      ",
                                             "GENERICO       "]       NO-UNDO.

FORM
    "Pac"       AT  1
    "Conta/DV"  AT  7
    "Nome"      AT 16
    "Nr.Cartao" AT 55
    "Validade"  AT 65
    "Titular"   AT 76
    "Critica"   AT 93
    WITH NO-LABEL WIDTH 132 FRAME f_cabecalho.
    
FORM 
    w-rejeitados.cdagenci
    w-rejeitados.nrdconta 
    w-rejeitados.nmtitcrd 
    w-rejeitados.nrcartao 
    w-rejeitados.dtvalcar FORMAT "99/99/9999"
    w-rejeitados.tpusucar 
    w-rejeitados.dscritic FORMAT "x(24)"
    WITH NO-LABEL DOWN WIDTH 132 FRAME f_rejeitados.
    
ASSIGN glb_cdprogra = "crps320".

RUN fontes/iniprg.p.
                           
IF  glb_cdcritic > 0   THEN
    RETURN.
                             
/*                                            ***  EDSON - 23/07/2003  ***
IF   glb_cdcooper = 2           AND
     glb_dtmvtolt > 04/17/2003  THEN
     DO:
         ASSIGN glb_infimsol = TRUE.
         RUN fontes/fimprg.p.
         RETURN.
     END.
     
RUN fontes/calcdata.p (INPUT glb_dtmvtolt, INPUT 2, INPUT "M", INPUT 0,
                       OUTPUT aux_dtinicrm).
*/

/*** Nova rotina para calculo da data  - JUNIOR (03/03/2004) ***/

IF   MONTH(glb_dtmvtolt) = 11 THEN
     aux_dtinicrm = DATE(01,31,YEAR(glb_dtmvtolt) + 1).
ELSE
IF   MONTH(glb_dtmvtolt) = 12 THEN
     aux_dtinicrm = DATE(02,28,YEAR(glb_dtmvtolt) + 1).
ELSE
     aux_dtinicrm = DATE(MONTH(glb_dtmvtolt) + 2,28,YEAR(glb_dtmvtolt)).
     
ASSIGN aux_dtinicrm = ((DATE(MONTH(aux_dtinicrm),28,YEAR(aux_dtinicrm)) +
                                   4) - DAY(DATE(MONTH(aux_dtinicrm),28,
                                                  YEAR(aux_dtinicrm)) + 4))     

       aux_dtfimcrm = ((DATE(MONTH(aux_dtinicrm),28,YEAR(aux_dtinicrm)) +
                                   4) - DAY(DATE(MONTH(aux_dtinicrm),28,
                                                  YEAR(aux_dtinicrm)) + 4))
       aux_nrdeanos = 5.

FOR EACH crapcrm WHERE crapcrm.cdcooper = glb_cdcooper  AND
                       crapcrm.cdsitcar = 2             AND
                       crapcrm.dtvalcar = aux_dtfimcrm  NO-LOCK:  

    ASSIGN flg_cartaoex = FALSE.
    
    FOR EACH crabcrm WHERE crabcrm.cdcooper = glb_cdcooper      AND
                           crabcrm.nrdconta = crapcrm.nrdconta  AND
                           crabcrm.tpusucar = crapcrm.tpusucar  AND
                           crabcrm.dtvalcar > crapcrm.dtvalcar  AND
                           crabcrm.cdsitcar < 3                 NO-LOCK:

        flg_cartaoex = TRUE.
             
    END. /* Fim do FOR EACH crabcrm */             
    
    IF  NOT flg_cartaoex  THEN
        /* Se a conta foi transferida, nao faz a renovacao */
        FOR EACH craptrf WHERE craptrf.cdcooper = glb_cdcooper     AND
                               craptrf.nrdconta = crapcrm.nrdconta AND 
                               craptrf.tptransa = 1                AND
                               craptrf.insittrs = 2                NO-LOCK:
             
            flg_cartaoex = TRUE.
         
        END.

    IF  flg_cartaoex  THEN
        NEXT.
     
    IF  crapcrm.tptitcar = 9  THEN
        ASSIGN aux_nmabrevi = crapcrm.nmtitcrd.
    ELSE
        DO:
            FIND crapass WHERE crapass.cdcooper = glb_cdcooper     AND
                               crapass.nrdconta = crapcrm.nrdconta 
                               NO-LOCK NO-ERROR.
                       
            IF  NOT AVAILABLE crapass  THEN
                DO:
                    CREATE w-rejeitados.
                    ASSIGN w-rejeitados.cdagenci = 0
                           w-rejeitados.nrdconta = crapcrm.nrdconta
                           w-rejeitados.nrcartao = crapcrm.nrcartao
                           w-rejeitados.nmtitcrd = crapcrm.nmtitcrd
                           w-rejeitados.dtvalcar = crapcrm.dtvalcar
                           w-rejeitados.tpusucar = IF crapcrm.tpusucar = 1 THEN
                                                      TRUE
                                                   ELSE
                                                      FALSE
                           w-rejeitados.dscritic = "ASSOCIADO NAO CADASTRADO".
            
                    NEXT.
                END.

            IF crapass.cdsitdct = 4 THEN
            DO:
                CREATE w-rejeitados.
                ASSIGN w-rejeitados.cdagenci = crapass.cdagenci
                       w-rejeitados.nrdconta = crapcrm.nrdconta
                       w-rejeitados.nrcartao = crapcrm.nrcartao
                       w-rejeitados.nmtitcrd = crapcrm.nmtitcrd
                       w-rejeitados.dtvalcar = crapcrm.dtvalcar
                       w-rejeitados.tpusucar = IF crapcrm.tpusucar = 1 THEN
                                                    TRUE
                                               ELSE
                                                    FALSE
                       w-rejeitados.dscritic = "CONTA ENCERRADA".
                    
                NEXT.
            END.
            ELSE
            IF  crapass.inpessoa > 1  THEN
                ASSIGN aux_nmabrevi = crapass.nmprimtl.
            ELSE
                DO:
                    FIND crapttl WHERE crapttl.cdcooper = glb_cdcooper     AND
                                       crapttl.nrdconta = crapcrm.nrdconta AND
                                       crapttl.idseqttl = crapcrm.tpusucar
                                       NO-LOCK NO-ERROR.
                           
                    IF  NOT AVAILABLE crapttl  THEN
                        DO:
                            CREATE w-rejeitados.
                            ASSIGN w-rejeitados.cdagenci = crapass.cdagenci
                                   w-rejeitados.nrdconta = crapcrm.nrdconta
                                   w-rejeitados.nrcartao = crapcrm.nrcartao
                                   w-rejeitados.nmtitcrd = crapcrm.nmtitcrd
                                   w-rejeitados.dtvalcar = crapcrm.dtvalcar
                           w-rejeitados.tpusucar = IF  crapcrm.tpusucar = 1 THEN
                                                       TRUE
                                                   ELSE
                                                       FALSE
                                   w-rejeitados.dscritic = "TITULAR NAO " +
                                                           "CADASTRADO".
            
                            NEXT.
                        END.
            
                    ASSIGN aux_nmabrevi = crapttl.nmextttl.
                END.
        

            /* Apos todas as validacoes de conta/titular deve ser rejeitado
               a renovacao da solicitacao automatica do cartao magnetico 
               da conta do cooperado */
            CREATE w-rejeitados.
            ASSIGN w-rejeitados.cdagenci = crapass.cdagenci
                   w-rejeitados.nrdconta = crapcrm.nrdconta
                   w-rejeitados.nrcartao = crapcrm.nrcartao
                   w-rejeitados.nmtitcrd = crapcrm.nmtitcrd
                   w-rejeitados.dtvalcar = crapcrm.dtvalcar
                   w-rejeitados.tpusucar = IF  crapcrm.tpusucar = 1 THEN
                                               TRUE
                                           ELSE
                                               FALSE
                   w-rejeitados.dscritic = "RENOVACAO NAO EMITIDA".
            NEXT.
        END.
                
    RUN fontes/abreviar.p (INPUT  aux_nmabrevi, 
                           INPUT  28, 
                           OUTPUT aux_nmabrevi).
         
    DO  TRANSACTION ON ERROR UNDO, RETRY:
    
        /* Busca a proxima sequencia do campo crapmat.nrseqcar */
        RUN STORED-PROCEDURE pc_sequence_progress
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPMAT"
                                            ,INPUT "NRSEQCAR"
                                            ,INPUT STRING(glb_cdcooper)
                                            ,INPUT "N"
                                            ,"").
        
        CLOSE STORED-PROC pc_sequence_progress
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                  
        ASSIGN aux_nrseqcar = INTE(pc_sequence_progress.pr_sequence)
                              WHEN pc_sequence_progress.pr_sequence <> ?.

        IF   MONTH(crapcrm.dtvalcar) = 2    AND
             DAY(crapcrm.dtvalcar) = 29     THEN
             DO:
                 aux_dtvalnew = DATE(MONTH(crapcrm.dtvalcar),
                                     28,
                                     YEAR(crapcrm.dtvalcar) + aux_nrdeanos).
             END.                        
        ELSE 
             DO:
                 aux_dtvalnew = DATE(MONTH(crapcrm.dtvalcar),
                                     DAY(crapcrm.dtvalcar),
                                     YEAR(crapcrm.dtvalcar) + aux_nrdeanos).
             END.
                        
        CREATE crabcrm.
        ASSIGN crabcrm.cdoperad = "1"
               crabcrm.cdsitcar = 1
               crabcrm.dtcancel = ?
               crabcrm.dtemscar = ?
               crabcrm.dtentcrm = ?
               crabcrm.dttransa = glb_dtmvtolt
               crabcrm.dtvalcar = aux_dtvalnew
               crabcrm.dtvalsen = ?
               crabcrm.hrtransa = TIME               
               crabcrm.invalsen = crapcrm.invalsen
               crabcrm.nmtitcrd = aux_nmabrevi
               crabcrm.nrcartao = DECIMAL(STRING(crapcrm.tptitcar,"9")+
                                          STRING(aux_nrseqcar,"999999")+
                                          STRING(crapcrm.nrdconta,"99999999")+
                                          STRING(crapcrm.tpusucar,"9"))
               crabcrm.nrdconta = crapcrm.nrdconta
               crabcrm.dssencar = "NAOTARIFA"
               crabcrm.nrseqcar = aux_nrseqcar
               crabcrm.nrviacar = 2
               crabcrm.tpcarcta = crapcrm.tpcarcta
               crabcrm.tptitcar = crapcrm.tptitcar
               crabcrm.tpusucar = crapcrm.tpusucar               
               crabcrm.cdcooper = glb_cdcooper.
            
        VALIDATE crabcrm.

    END. /* Fim do DO TRANSACTION */ 

END. /* Fim do FOR EACH crapcrm */

ASSIGN glb_nmarqimp = "rl/crrl448.lst".
    
{ includes/cabrel132_1.i }
    
OUTPUT STREAM str_1 TO VALUE(glb_nmarqimp) PAGE-SIZE 84.
    
VIEW STREAM str_1 FRAME f_cabrel132_1.

VIEW STREAM str_1 FRAME f_cabecalho.
   
FOR EACH w-rejeitados NO-LOCK BY w-rejeitados.cdagenci 
                                 BY w-rejeitados.nrdconta:

    DISP STREAM str_1 w-rejeitados.nrdconta w-rejeitados.nmtitcrd
                      w-rejeitados.nrcartao w-rejeitados.dtvalcar
                      w-rejeitados.tpusucar w-rejeitados.dscritic
                      w-rejeitados.cdagenci
                      WITH FRAME f_rejeitados.

    DOWN STREAM str_1 WITH FRAME f_rejeitados.
    
    IF  LINE-COUNTER(str_1) > PAGE-SIZE(str_1)  THEN
        DO:
            PAGE STREAM str_1.
            
            VIEW STREAM str_1 FRAME f_cabrel132_1.
            VIEW STREAM str_1 FRAME f_cabecalho.
        END.

END. /* Fim do FOR EACH w-rejeitados */

OUTPUT STREAM str_1 CLOSE.

ASSIGN glb_nrcopias = 1
       glb_nmformul = "132col".
                  
RUN fontes/imprim.p.
               
ASSIGN glb_infimsol = TRUE.

RUN fontes/fimprg.p.

/* .......................................................................... */

