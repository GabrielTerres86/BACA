/* ............................................................................

   Programa: fontes/crps377.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Mirtes
   Data    : Janeiro/2004.                   Ultima alteracao: 02/01/2014

   Dados referentes ao programa:

   Frequencia: Diario (Batch - Solicitacao 82)
   Objetivo  : Processar impressao dos nomes nos Bloquetos Banco Brasil, e 
               atualizacao lancamentos tarifa cobranca impressao Bloquetos.

   Alteracoes: 20/01/2004 - Ajustado do FORMAT na quantidade de bloquetos
                            (Edson).
               10/03/2004 - Listar Agencia do Associado(rel.327)(Mirtes).

               19/05/2005 - Listar em 2 vias (somente Creditextil) o relatorio
                            327 (Edson).

               30/06/2005 - Alimentado campo cdcooper das tabelas craplcm
                            e craplot (Diego).

               23/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               11/10/2005 - Aumento no numero de Vias rel. 320 (Ze).
               
               31/01/2006 - Alterado para consultar a crapcco ao inves da 
                            craptab (Julio/Ze)
                            
               21/02/2006 - Unificacao dos bancos - SQLWorks - Eder 
                           
               20/03/2006 - Tratamento de Cobranca (Ze).            
               
               07/04/2006 - Acerto na Impressao da Identificacao no bloqueto
                            (Julio)
                            
               03/02/2010 - Incluido FORMAT "x(40)" para crapass.nmprimtl no 
                            FRAME f_taloes (Diego).
               
               25/06/2013 - Busca de valores e historicos da tarifa atraves
                            da b1wgen0153 e gravacao dos lancamentos na
                            craplat e nao mais na craplcm (Tiago).  
               
               30/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).              
                            
               11/10/2013 - Incluido parametro cdprogra nas procedures da 
                            b1wgen0153 que carregam dados de tarifas (Tiago).
                            
               02/01/2014 - Retirado leitura da craptab "FILAIMPRES" (Tiago).
............................................................................ */

{ includes/var_batch.i {1} } 
{ sistema/generico/includes/var_internet.i }

DEF BUFFER crabreq FOR crapreq.

DEF     VAR     aux_ctaconve    AS INT                                NO-UNDO.
DEF     VAR     aux_nmrelat1    AS CHAR INIT "rl/crrl327.lst"         NO-UNDO.
DEF     VAR     aux_nmrelat2    AS CHAR INIT "rl/crrl328.lst"         NO-UNDO.
DEF     VAR     aux_cdbancbb    AS INT  FORMAT "999"                  NO-UNDO.

DEF     VAR     aux_cdagenci    AS INT                                NO-UNDO.
DEF     VAR     aux_cdbccxlt    AS INT                                NO-UNDO.
DEF     VAR     aux_nrdolote    AS INT                                NO-UNDO.
DEF     VAR     aux_cdhistor    AS INT                                NO-UNDO.
DEF     VAR     aux_cdtarhis    AS INT                                NO-UNDO.
DEF     VAR     aux_vlrtarif    AS DECI                               NO-UNDO.
DEF     VAR     aux_nrlotblq    AS INT                                NO-UNDO.
DEF     VAR     aux_cdhisblq    AS INT                                NO-UNDO.
DEF     VAR     aux_vlrtrblq    AS DECI                               NO-UNDO.
DEF     VAR     aux_contador    AS INT                                NO-UNDO.
DEF     VAR     aux_qtreqtal    AS INT FORMAT "zz9"                   NO-UNDO.
DEF     VAR     aux_cdfvlcop    AS INT                                NO-UNDO.

DEF     VAR     rel_nmempres    AS CHAR FORMAT "x(11)"                NO-UNDO.
DEF     VAR     rel_nmrelato    AS CHAR FORMAT "x(40)" EXTENT 5       NO-UNDO.
DEF     VAR     rel_nrmodulo    AS INT  FORMAT "9"                    NO-UNDO.
DEF     VAR     rel_nmmodulo    AS CHAR FORMAT "x(15)" EXTENT 5
                                        INIT    ["ACOMPANHAMENRO ",
                                                 "CHEQUE CONTINUO ",
                                                 "               ",
                                                 "                 ",
                                                 "               "]   NO-UNDO.
DEF     VAR     fis_cdhistor    AS INTE                               NO-UNDO.
DEF     VAR     fis_vltarifa    AS DECI                               NO-UNDO.
DEF     VAR     fis_cdfvlcop    AS INTE                               NO-UNDO.
DEF     VAR     jur_cdhistor    AS INTE                               NO-UNDO.
DEF     VAR     jur_vltarifa    AS DECI                               NO-UNDO.
DEF     VAR     jur_cdfvlcop    AS INTE                               NO-UNDO.

DEF     VAR     tar_cdhisest    AS INTE                               NO-UNDO.
DEF     VAR     tar_dtdivulg    AS DATE                               NO-UNDO.
DEF     VAR     tar_dtvigenc    AS DATE                               NO-UNDO.

DEF     VAR     h-b1wgen0153    AS HANDLE                             NO-UNDO.

DEF STREAM str_1. /* Impressao do relatorio de acompanhamento */
DEF STREAM str_2. /* Impressao dos Nomes Bloquetos */

/*** STREAM 1 ***/

FORM HEADER "CONTA" AT 07
            "NOME"  AT 13
            "PA"    AT 55
            "QTD.BLOQUETOS" AT 59
            "       NUMERACAO UTILIZADA" AT 101
            SKIP
            "----------"    AT 02
            "----------------------------------------"  AT 13
            "---" AT 54
            "-------------" AT 59
            "--------------------------" AT 101
            WITH NO-BOX NO-LABELS PAGE-TOP WIDTH 132 FRAME f_titulo.

FORM SKIP(1)
     crapass.nrdconta            AT  02  
     crapass.nmprimtl            AT  13  FORMAT "x(40)"
     crapass.cdagenci            AT  54  FORMAT "zz9"
     aux_qtreqtal                AT  60  FORMAT "z,zz9"
    "____________a_____________" AT 101    
     WITH NO-BOX DOWN NO-LABELS WIDTH 132 FRAME f_taloes.
      
FORM "LOCAL: _________________________________" AT 8
     "DATA: ____/____/__________         "
     "OPERADOR:______________________________"
     WITH NO-BOX DOWN NO-LABELS PAGE-BOTTOM WIDTH 132 FRAME f_final.   
     
/*** STREAM 2 ***/

FORM SKIP(3)
     crapass.nmprimtl AT  15 FORMAT "x(40)"
     crapass.nrdconta AT  57 
     " " AT 1 SKIP(27)
     WITH NO-BOX DOWN NO-LABELS WIDTH 132 FRAME f_identifica.

glb_cdprogra = "crps377".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0   THEN
     RETURN.

/*--  Busca dados da cooperativa  --*/

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> log/proc_batch.log").
         RETURN.
     END.

/* Nao podera existir mais de um registro para convenio pre-impresso para uma
   mesma cooperativa */
   
FIND FIRST crapcco WHERE crapcco.cdcooper = glb_cdcooper    AND
                         crapcco.cddbanco = 1               AND /*Bco.Brasil*/
                         crapcco.dsorgarq = "PRE-IMPRESSO"  NO-LOCK NO-ERROR.
                         
IF   AVAILABLE crapcco   THEN
     ASSIGN aux_cdbancbb = 1 /* 001 Banco Brasil */
            aux_cdagenci = crapcco.cdagenci
            aux_cdbccxlt = crapcco.cdbccxlt
            aux_nrdolote = crapcco.nrdolote 
            aux_cdhistor = crapcco.cdhistor
            aux_vlrtarif = crapcco.vlrtarif
            aux_cdtarhis = crapcco.cdtarhis
            aux_nrlotblq = crapcco.nrlotblq
            aux_cdhisblq = crapcco.cdhisblq
            aux_vlrtrblq = crapcco.vlrtrblq.
ELSE
     DO:
         RUN fontes/fimprg.p.     /*  Nao existe convenio cadastrado  */
         RETURN.
     END.


/***************************************************************************/
/**          Leituras dos dados tarifa cobranca com PF e PJ               **/
/***************************************************************************/
RUN sistema/generico/procedures/b1wgen0153.p
    PERSISTENT SET h-b1wgen0153.

RUN carrega_dados_tarifa_cobranca IN
    h-b1wgen0153(INPUT  glb_cdcooper,
                 INPUT  crapcco.nrconven,
                 INPUT  "REM",
                 INPUT  00,     /* cdocorre */
                 INPUT  "20",   /* cdmotivo - Boleto Pré-Impresso */
                 INPUT  1,      /* inpessoa */
                 INPUT  1,
                 INPUT  glb_cdprogra,
                 OUTPUT fis_cdhistor,
                 OUTPUT tar_cdhisest,
                 OUTPUT fis_vltarifa,
                 OUTPUT tar_dtdivulg,
                 OUTPUT tar_dtvigenc,
                 OUTPUT fis_cdfvlcop,
                 OUTPUT TABLE tt-erro).

DELETE PROCEDURE h-b1wgen0153.

IF  RETURN-VALUE <> "OK"   THEN
    DO: 
       FIND FIRST tt-erro NO-LOCK NO-ERROR.

       IF  AVAIL tt-erro THEN
                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                " - " + glb_cdprogra + "' --> '"  +
                tt-erro.dscritic + " >> log/proc_batch.log").
    END. 

RUN sistema/generico/procedures/b1wgen0153.p
    PERSISTENT SET h-b1wgen0153.

RUN carrega_dados_tarifa_cobranca IN
    h-b1wgen0153(INPUT  glb_cdcooper,
                 INPUT  crapcco.nrconven,
                 INPUT  "REM",
                 INPUT  00,     /* cdocorre */
                 INPUT  "20",   /* cdmotivo - Boleto Pré-Impresso */
                 INPUT  2,      /* inpessoa */
                 INPUT  1,
                 INPUT  glb_cdprogra,
                 OUTPUT jur_cdhistor,
                 OUTPUT tar_cdhisest,
                 OUTPUT jur_vltarifa,
                 OUTPUT tar_dtdivulg,
                 OUTPUT tar_dtvigenc,
                 OUTPUT jur_cdfvlcop,
                 OUTPUT TABLE tt-erro).

DELETE PROCEDURE h-b1wgen0153.

IF  RETURN-VALUE <> "OK"   THEN
    DO:

       FIND FIRST tt-erro NO-LOCK NO-ERROR.

       IF  AVAIL tt-erro THEN
                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                " - " + glb_cdprogra + "' --> '"  +
                tt-erro.dscritic + " >> log/proc_batch.log").
    END. 
/* fim leituras */


FIND FIRST crapreq WHERE crapreq.cdcooper = glb_cdcooper    AND
                         crapreq.tprequis = 8               AND
                         crapreq.insitreq = 1               NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapreq   THEN
     DO:
         RUN fontes/fimprg.p.
         RETURN.
     END.     

IF  glb_nrctares = 0 THEN  /* Regerar Arquivo apenas se nao ocorreu erro */
    DO:
       OUTPUT STREAM str_1 TO VALUE(aux_nmrelat1) PAGED PAGE-SIZE 84. 
       OUTPUT STREAM str_2 TO VALUE(aux_nmrelat2).

       PUT STREAM str_2 CONTROL 
           "\033@\033\117\022\024\0330\033\120\033\017\033G\015" NULL.
           /*--
           "\033@\033\117\033C\030\022\024\0330\033\120\033\017\033G\015" NULL.
           --*/
           
       {includes/cabrel132_1.i }

       VIEW STREAM str_1 FRAME f_cabrel132_1.

       VIEW STREAM str_1 FRAME f_titulo.
       /*----
       RUN p_testaimpressao.                 
       -----*/
       FOR EACH crapreq WHERE crapreq.cdcooper = glb_cdcooper       AND
                              crapreq.tprequis = 8                  AND
                              crapreq.insitreq = 1   /* Nao Impresso */
                              NO-LOCK,
           /* EACH crapass OF crapreq NO-LOCK */
           EACH crapass WHERE crapass.cdcooper = glb_cdcooper       AND
                              crapass.nrdconta = crapreq.nrdconta   NO-LOCK:

            ASSIGN aux_qtreqtal = crapreq.qtreqtal.
            
            DISP STREAM str_1 crapass.nrdconta
                              crapass.nmprimtl
                              crapass.cdagenci
                              aux_qtreqtal
                              WITH FRAME f_taloes.         

            DOWN STREAM str_1 WITH FRAME f_taloes.

            ASSIGN aux_contador = 1.

            DO  WHILE aux_contador <= aux_qtreqtal:
        
                DISPLAY STREAM str_2 crapass.nrdconta
                                     crapass.nmprimtl
                                     WITH FRAME f_identifica.
                
                DOWN STREAM str_2 WITH FRAME f_identifica.

                ASSIGN aux_contador = aux_contador + 1.
            END.
       END.

       VIEW STREAM str_1 FRAME f_final.

       OUTPUT STREAM str_1 CLOSE.
       OUTPUT STREAM str_2 CLOSE.
                                         
     END.    /* Geracao arquivo para Impressao */

/* Atualizacoes */
FOR  EACH crapreq WHERE crapreq.cdcooper = glb_cdcooper         AND
                        crapreq.tprequis = 8                    AND
                        crapreq.insitreq = 1  /* Nao Impresso */
                        NO-LOCK,
     EACH crapass WHERE crapass.cdcooper = glb_cdcooper         AND
                        crapass.nrdconta = crapreq.nrdconta     AND
                        crapass.nrdconta > glb_nrctares         NO-LOCK:
 

    /* atribuir valor tarifa e codigo historico dependendo do tipo de 
       pessoa */
     IF  crapass.inpessoa = 1 THEN
         ASSIGN aux_cdhisblq = fis_cdhistor
                aux_vlrtrblq = fis_vltarifa
                aux_cdfvlcop = fis_cdfvlcop.
     ELSE
         ASSIGN aux_cdhisblq = jur_cdhistor
                aux_vlrtrblq = jur_vltarifa
                aux_cdfvlcop = jur_cdfvlcop.


     TRANS_1:
     
     DO TRANSACTION ON ERROR UNDO TRANS_1, RETURN:
 
        IF  aux_vlrtrblq > 0 THEN 
            DO:
                RUN efetua-lanc-craplat(
                           INPUT glb_cdcooper,             /* cdcooper */
                           INPUT crapass.nrdconta,         /* nrdconta */
                           INPUT glb_dtmvtolt,             /* dtmvtolt */
                           INPUT aux_cdhisblq,             /* cdhistor */
                           INPUT aux_vlrtrblq,             /* vllanaut */
                           INPUT "1",                      /* cdoperad */
                           INPUT aux_cdagenci,             /* cdagenci */
                           INPUT aux_cdbccxlt,             /* cdbccxlt */
                           INPUT aux_nrlotblq,             /* nrdolote */
                           INPUT 1,                        /* tpdolote */
                           INPUT 0,                        /* nrdocmto */
                           INPUT crapass.nrdconta,         /* nrdctabb */
                           INPUT STRING(crapass.nrdconta,"99999999"),  /* nrdcitg */
                           INPUT "",                       /* cdpesqbb */
                           INPUT 0,                        /* cdbanchq */
                           INPUT 0,                        /* cdagechq */
                           INPUT 0,                        /* nrctachq */
                           INPUT FALSE,                    /* flgaviso */
                           INPUT 0,                        /* tpdaviso */
                           INPUT aux_cdfvlcop,             /* cdfvlcop */
                           INPUT glb_inproces,             /* inprocess */
                           OUTPUT TABLE tt-erro).

            END.

         FIND crabreq WHERE RECID(crabreq) = RECID(crapreq) 
                            EXCLUSIVE-LOCK NO-ERROR.
                            
         ASSIGN crabreq.insitreq = 2.
         RELEASE crabreq.
         
         FIND crapres WHERE crapres.cdcooper = glb_cdcooper     AND
                            crapres.cdprogra = glb_cdprogra
                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

         IF   NOT AVAILABLE crapres   THEN
              DO:
                 glb_cdcritic = 151.
                 RUN fontes/critic.p.
                 UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                   " - " + glb_cdprogra + "' --> '" +
                                   glb_dscritic + " >> log/proc_batch.log").
                 UNDO TRANS_1, RETURN.
              END.

         crapres.nrdconta = crapass.nrdconta.

    END. /* END TRANSACTION */
END.  /* for each crapass */
    
ASSIGN glb_nrcopias = 2
       glb_nmformul = "132col"
       glb_nmarqimp = aux_nmrelat1.
       
RUN fontes/imprim.p.

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> log/proc_batch.log").
         RETURN.
     END.

/* 
FIND craptab WHERE craptab.cdcooper = glb_cdcooper      AND
                   craptab.nmsistem = "CRED"            AND
                   craptab.tptabela = "CONFIG"          AND
                   craptab.cdempres = crapcop.cdcooper  AND 
                   craptab.cdacesso = "FILAIMPRES"      AND
                   craptab.tpregist = 000               NO-LOCK NO-ERROR.
                   
IF   NOT AVAILABLE craptab THEN
     DO:
         glb_cdcritic = 652.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + 
                           " - CRED-CONFIG-NN-FILAIMPRES-000" +
                           " >> log/proc_batch.log").
         RETURN.
     END.


UNIX SILENT VALUE("lp -d " + TRIM(SUBSTR(craptab.dstextab,3,11)) + 
                  " -oMTfbloqueto " + aux_nmrelat2 + " > /dev/null").
*/

RUN fontes/fimprg.p.

/********** Procedimento utilizado para imprimir um talao de Teste ************/

PROCEDURE p_testaimpressao: 
 
  PUT STREAM str_2 CONTROL 
      "\033@\033\117\022\024\0330\033\120\033\017\033G\015" NULL.
      /*--
      "\033@\033\117\033C\030\022\024\0330\033\120\033\017\033G\015" NULL.
       --*/
           
  DISP STREAM str_1 "9999.999.9"      @ crapass.nrdconta
                    "TESTE IMPRESSAO" @ crapass.nmprimtl
                     "999"            @ crapass.cdagenci
                     "999"            @ aux_qtreqtal
                     WITH FRAME f_taloes.         

  DOWN STREAM str_1 WITH FRAME f_taloes.

  aux_contador = 1.
  
  DO WHILE aux_contador <= 20:
     DISPLAY STREAM str_2 
            "TESTE IMPRESSAO" @ crapass.nmprimtl      
            "9999.999.9"      @ crapass.nrdconta
             WITH FRAME f_identifica.
     DOWN STREAM str_2 WITH FRAME f_identifica.

     aux_contador = aux_contador + 1.
  END.
END.

/*........................................................................... */

PROCEDURE efetua-lanc-craplat:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF  INPUT PARAM par_cdhistor AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_vllanaut AS DECI                              NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdbccxlt AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdolote AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_tpdolote AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdocmto AS DECI                              NO-UNDO.
    DEF  INPUT PARAM par_nrdctabb AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdctitg AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_cdpesqbb AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_cdbanchq AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagechq AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrctachq AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_flgaviso AS LOGI                              NO-UNDO.
    DEF  INPUT PARAM par_tpdaviso AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdfvlcop AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                              NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro. 

    RUN sistema/generico/procedures/b1wgen0153.p
    PERSISTENT SET h-b1wgen0153.
        
    RUN cria_lan_auto_tarifa 
        IN h-b1wgen0153(INPUT par_cdcooper,
                        INPUT par_nrdconta,
                        INPUT par_dtmvtolt,
                        INPUT par_cdhistor,
                        INPUT par_vllanaut,
                        INPUT par_cdoperad,
                        INPUT par_cdagenci,
                        INPUT par_cdbccxlt,
                        INPUT par_nrdolote,
                        INPUT par_tpdolote,
                        INPUT par_nrdocmto,
                        INPUT par_nrdctabb,
                        INPUT par_nrdctitg,
                        INPUT par_cdpesqbb,
                        INPUT par_cdbanchq,
                        INPUT par_cdagechq,
                        INPUT par_nrctachq,
                        INPUT par_flgaviso,
                        INPUT par_tpdaviso,
                        INPUT par_cdfvlcop,
                        INPUT par_inproces,
                        OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen0153.

    IF RETURN-VALUE = "NOK" THEN
       RETURN "NOK".

    RETURN "OK".
END.
