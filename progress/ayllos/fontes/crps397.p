/* ..........................................................................

   Programa: Fontes/crps397.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro      
   Data    : Junho/2004                        Ultima atualizacao: 20/02/2019

   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Atende a solicitacao 4.
               Roda somente na Credifiesc.
               Emite relacao de controle seguro prestamista (358).

   Alteracoes: 12/07/2004 - Incluido o envio do relatorio 358 por e-mail para
                            CREDIFIESC (Evandro).

               23/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               19/10/2005 - Acrescentado str_2 para relatorio separado por 
                            PAC (Diego).

               17/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando. 

               18/03/2008 - Alterado envio de email para BO b1wgen0011
                            (Sidnei - Precise)
               
               09/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                             
               20/02/2019 - Inclusao de log de fim de execucao do programa 
                            (Belli - Envolti - Chamado REQ0039739) 
							
............................................................................. */
DEF STREAM str_1.     /* Para relatorio */
DEF STREAM str_2.     /* Relatorio separado por PA */

{ includes/var_batch.i "NEW" }
/* Chamada Oracle - 20/02/2019 - REQ0039739 */
{ sistema/generico/includes/var_oracle.i }

DEF   VAR b1wgen0011   AS HANDLE                                     NO-UNDO.

DEF        VAR rel_nrmodulo    AS INT     FORMAT "9"                   NO-UNDO.
DEF        VAR rel_nmmodulo    AS CHAR    FORMAT "x(15)" EXTENT 5
                                  INIT ["DEP. A VISTA   ","CAPITAL        ",
                                        "EMPRESTIMOS    ","DIGITACAO      ",
                                        "GENERICO       "]             NO-UNDO.
DEF        VAR rel_nmempres    AS CHAR    FORMAT "x(15)"               NO-UNDO.
DEF        VAR rel_nmresemp    AS CHAR    FORMAT "x(15)"               NO-UNDO.
DEF        VAR rel_nmrelato    AS CHAR    FORMAT "x(40)" EXTENT 5      NO-UNDO.

DEF        VAR aux_nrcpfcgc    AS CHAR    FORMAT "x(18)"               NO-UNDO. 
DEF        VAR aux_vltotdiv    AS DECIMAL                              NO-UNDO.
DEF        VAR aux_qttotdiv    AS INT                                  NO-UNDO.
DEF        VAR aux_vlsldccr    AS DECIMAL                              NO-UNDO.
DEF        VAR aux_qtpreemp    AS INT                                  NO-UNDO.

DEF        VAR aux_flgimpri    AS LOGICAL                              NO-UNDO.
DEF        VAR aux_flgconta    AS LOGICAL                              NO-UNDO.

ASSIGN glb_cdprogra = "crps397"
       glb_flgbatch = FALSE
       aux_qttotdiv = 0
       aux_vltotdiv = 0.

RUN fontes/iniprg.p.
           
FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> log/proc_batch.log").
         QUIT.
     END.

/* para ver se e Credifiesc*/
IF   crapcop.cdcooper <> 6   THEN 
     DO:
         RUN fontes/fimprg.p.
         QUIT.
     END.    

IF   glb_cdcritic > 0 THEN
     QUIT.

{ includes/cabrel234_1.i }
{ includes/cabrel234_2.i }
                                                                        
FORM "CPF/CNPJ            TITULAR                                     CONTA/DV" 
     "DT.NASCIM.   SALDO DEVEDOR C/C   CONTRATO  DT.CONTRATO"      AT 75      
     "SALDO DEVEDOR CTR   PARCELAS A PAGAR   VALOR PRESTACAO"      AT 132
      SKIP(1)
      WITH NO-BOX NO-ATTR-SPACE NO-LABEL WIDTH 234 FRAME f_label.

FORM aux_nrcpfcgc       
     crapass.nmprimtl       FORMAT "x(40)"               AT 21              
     crapass.nrdconta                                    AT 63
     crapass.dtnasctl       FORMAT "99/99/9999"          AT 75
     aux_vlsldccr           FORMAT "zzzzzz,zz9.99-"      AT 92
     crapepr.nrctremp                                    AT 107
     crapepr.dtmvtolt                                    AT 119
     crapepr.vlsdeved                                    AT 131
     aux_qtpreemp                                        AT 158 
     crapepr.vlpreemp                                    AT 168
     WITH NO-BOX DOWN NO-LABEL WIDTH 200 FRAME f_assoc.
     
FORM SKIP(2)
     aux_qttotdiv       FORMAT "zzz,zz9"        LABEL "QTD DE ASSOCIADOS"
     aux_vltotdiv AT 32 FORMAT "zzz,zzz,zz9.99" LABEL "TOTAL DO SALDO DEVEDOR"
     WITH NO-BOX SIDE-LABELS NO-LABEL WIDTH 132 FRAME f_total.
     
FORM SKIP(1)
     "PA -"  AT 2
     crapass.cdagenci    FORMAT "zz9"
     SKIP(1)
     WITH NO-BOX SIDE-LABELS NO-LABEL WIDTH 132 FRAME f_pac.

OUTPUT STREAM str_1 TO rl/crrl358.lst PAGED PAGE-SIZE 62.
             
VIEW STREAM str_1 FRAME f_cabrel234_1.
VIEW STREAM str_1 FRAME f_label.

FOR EACH crapass WHERE crapass.cdcooper = glb_cdcooper NO-LOCK.

    /*FIND crapsld OF crapass NO-LOCK.*/
    FIND crapsld WHERE crapsld.cdcooper = glb_cdcooper  AND
                       crapsld.nrdconta = crapass.nrdconta 
                       NO-LOCK.

     ASSIGN aux_vlsldccr = crapsld.vlsddisp 
            aux_flgimpri = FALSE
            aux_flgconta = TRUE.
           
     /* Tratamento de CPF/CGC */
     IF   crapass.inpessoa = 1   THEN
          ASSIGN  aux_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999")
                  aux_nrcpfcgc = STRING(aux_nrcpfcgc,"    xxx.xxx.xxx-xx").
     ELSE
          ASSIGN  aux_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999999")
                  aux_nrcpfcgc = STRING(aux_nrcpfcgc,"xx.xxx.xxx/xxxx-xx").
     
     
     IF   aux_vlsldccr >= 0   THEN
          aux_vlsldccr = 0.
     ELSE
          DO:
              ASSIGN  aux_vlsldccr = aux_vlsldccr * -1
                      aux_flgimpri = TRUE
                      aux_vltotdiv = aux_vltotdiv + aux_vlsldccr
                      aux_qttotdiv = aux_qttotdiv + 1
                      aux_flgconta = FALSE.
              
              IF   LINE-COUNTER(str_1) >= PAGE-SIZE(str_1)  THEN
                   DO:
                        PAGE STREAM str_1.
                        VIEW STREAM str_1 FRAME f_label.
                    END.
 
              DISPLAY STREAM str_1 aux_nrcpfcgc crapass.nmprimtl
                                   crapass.dtnasctl aux_vlsldccr
                                   crapass.nrdconta WITH FRAME f_assoc.
          END.
     
     FOR EACH crapepr WHERE crapepr.cdcooper = glb_cdcooper       AND
                            crapepr.nrdconta = crapass.nrdconta   AND
                            crapepr.vlsdeved > 0                  NO-LOCK:
        
        ASSIGN aux_qtpreemp = crapepr.qtpreemp - crapepr.qtprecal
               aux_vltotdiv = aux_vltotdiv + crapepr.vlsdeved
               aux_flgimpri = FALSE.     
  
               IF   aux_qtpreemp < 0   THEN
                    aux_qtpreemp = 1.

               IF   LINE-COUNTER(str_1) >= PAGE-SIZE(str_1)  THEN
                    DO:
                        PAGE STREAM str_1.
                        VIEW STREAM str_1 FRAME f_label.
                    END.

               /* Verifica se deve imprimir */
               IF   aux_flgconta    THEN
                    DO:
                        ASSIGN aux_qttotdiv = aux_qttotdiv + 1
                               aux_flgconta = FALSE.
                         
                        DISPLAY STREAM str_1 aux_nrcpfcgc crapass.nmprimtl
                                             crapass.dtnasctl aux_vlsldccr
                                             crapass.nrdconta 
                                             WITH FRAME f_assoc.
                    END.
                    
               DISPLAY STREAM str_1 crapepr.dtmvtolt crapepr.nrctremp
                                    crapepr.vlsdeved aux_qtpreemp
                                    crapepr.vlpreemp WITH FRAME f_assoc.
    
               DOWN STREAM str_1 WITH FRAME f_assoc.
               
     END.
     
     IF   aux_flgimpri   THEN
          DOWN STREAM str_1 WITH FRAME f_assoc.
          
END.

/*  Imprime total geral  */
IF   LINE-COUNTER(str_1) >= 56  THEN
     DO:
          PAGE STREAM str_1.
          VIEW STREAM str_1 FRAME f_label.
     END.

DISPLAY STREAM str_1  aux_vltotdiv 
                      aux_qttotdiv WITH FRAME f_total.

OUTPUT STREAM str_1 CLOSE.

/* Para relatorio separado por PA */
OUTPUT STREAM str_2 TO rl/crrl431.lst PAGED PAGE-SIZE 62.

VIEW STREAM str_2 FRAME f_cabrel234_2.

ASSIGN aux_vltotdiv = 0
       aux_qttotdiv = 0.

FOR EACH crapass WHERE crapass.cdcooper = glb_cdcooper NO-LOCK
                       BREAK BY crapass.cdagenci 
                                BY crapass.nrdconta.

    /*FIND crapsld OF crapass NO-LOCK.*/
    FIND crapsld WHERE crapsld.cdcooper = glb_cdcooper AND
                       crapsld.nrdconta = crapass.nrdconta
                       NO-LOCK.

    IF   FIRST-OF(crapass.cdagenci)  THEN
         DO:
             PAGE STREAM str_2.
             DISPLAY STREAM str_2 crapass.cdagenci WITH FRAME f_pac.
             VIEW STREAM str_2 FRAME f_label. 
         END.
     
    ASSIGN aux_vlsldccr = crapsld.vlsddisp 
           aux_flgimpri = FALSE
           aux_flgconta = TRUE.
           
    /* Tratamento de CPF/CGC */
    IF   crapass.inpessoa = 1   THEN
         ASSIGN  aux_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999")
                 aux_nrcpfcgc = STRING(aux_nrcpfcgc,"    xxx.xxx.xxx-xx").
    ELSE
         ASSIGN  aux_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999999")
                 aux_nrcpfcgc = STRING(aux_nrcpfcgc,"xx.xxx.xxx/xxxx-xx").
     
     
    IF   aux_vlsldccr >= 0   THEN
         aux_vlsldccr = 0.
    ELSE
         DO:
             ASSIGN  aux_vlsldccr = aux_vlsldccr * -1
                     aux_flgimpri = TRUE
                     aux_vltotdiv = aux_vltotdiv + aux_vlsldccr
                     aux_qttotdiv = aux_qttotdiv + 1
                     aux_flgconta = FALSE.
              
             IF   LINE-COUNTER(str_2) >= PAGE-SIZE(str_2)  THEN
                  DO:
                       PAGE STREAM str_2.
                       VIEW STREAM str_2 FRAME f_label.
                  END.
 
             DISPLAY STREAM str_2 aux_nrcpfcgc crapass.nmprimtl
                                  crapass.dtnasctl aux_vlsldccr
                                  crapass.nrdconta WITH FRAME f_assoc.
         END.
     
    FOR EACH crapepr WHERE crapepr.cdcooper = glb_cdcooper       AND
                           crapepr.nrdconta = crapass.nrdconta   AND
                           crapepr.vlsdeved > 0                  NO-LOCK:
        
        ASSIGN aux_qtpreemp = crapepr.qtpreemp - crapepr.qtprecal
               aux_vltotdiv = aux_vltotdiv + crapepr.vlsdeved
               aux_flgimpri = FALSE.     
  
               IF   aux_qtpreemp < 0   THEN
                    aux_qtpreemp = 1.

               IF   LINE-COUNTER(str_2) >= PAGE-SIZE(str_2)  THEN
                    DO:
                        PAGE STREAM str_2.
                        VIEW STREAM str_2 FRAME f_label.
                    END.

               /* Verifica se deve imprimir */
               IF   aux_flgconta    THEN
                    DO:
                        ASSIGN aux_qttotdiv = aux_qttotdiv + 1
                               aux_flgconta = FALSE.
                         
                        DISPLAY STREAM str_2 aux_nrcpfcgc crapass.nmprimtl
                                             crapass.dtnasctl aux_vlsldccr
                                             crapass.nrdconta 
                                             WITH FRAME f_assoc.
                    END.
                    
               DISPLAY STREAM str_2 crapepr.dtmvtolt crapepr.nrctremp
                                    crapepr.vlsdeved aux_qtpreemp
                                    crapepr.vlpreemp WITH FRAME f_assoc.
    
               DOWN STREAM str_2 WITH FRAME f_assoc.
               
     END.
     
     IF   aux_flgimpri   THEN
          DOWN STREAM str_2 WITH FRAME f_assoc.
     
     /*  Imprime total geral  */
     IF   LINE-COUNTER(str_2) >= 56  THEN
          DO:
              PAGE STREAM str_2.
              VIEW STREAM str_2 FRAME f_label.
          END.     
          
     IF   LAST-OF(crapass.cdagenci)  THEN
          DO:
              DISPLAY STREAM str_2 
                             aux_vltotdiv aux_qttotdiv WITH FRAME f_total.
                             
              ASSIGN aux_vltotdiv = 0
                     aux_qttotdiv = 0.
          END.

END.

OUTPUT STREAM str_2 CLOSE.
                   
ASSIGN glb_nmformul = "234dh"
       glb_nrcopias = glb_nrdevias
       glb_nmarqimp = "rl/crrl358.lst".
       
RUN fontes/imprim.p.
       
ASSIGN glb_nmformul = "234dh"
       glb_nrcopias = glb_nrdevias
       glb_nmarqimp = "rl/crrl431.lst".
                
RUN fontes/imprim.p. 

/* Move para diretorio converte para utilizar na BO */
UNIX SILENT VALUE 
           ("cp " + "rl/crrl358.lst" + " /usr/coop/" +
            crapcop.dsdircop + "/converte" + 
            " 2> /dev/null").

/* envio do relatorio por e-mail */
RUN sistema/generico/procedures/b1wgen0011.p
    PERSISTENT SET b1wgen0011.
             
RUN enviar_email IN b1wgen0011
                   (INPUT glb_cdcooper,
                    INPUT glb_cdprogra,
                    INPUT crapcop.dsdemail,
                    INPUT '"RELATORIO 358"',
                    INPUT "crrl358.lst",
                    INPUT FALSE).

DELETE PROCEDURE b1wgen0011.


/* Inclusao de log de fim de execucao do programa -  20/02/2019 - Chamado REQ0039739 */

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
   (INPUT "O",
    INPUT "CRPS397.P",
    input glb_cdcooper,
    input 1,
    input 4,
    input 0,
    input 912,
    input "912 - FINALIZADO LEGAL",
    input 1,
    INPUT "", /* nmarqlog */
    INPUT 0,  /* flabrechamado */
    INPUT "", /* texto_chamado */
    INPUT "", /* destinatario_email */
    INPUT 0,  /* flreincidente */
    INPUT 0).
CLOSE STORED-PROCEDURE pc_log_programa WHERE PROC-HANDLE = aux_handproc.
{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
   (INPUT "PF",
    INPUT "CRPS397.P",
    input glb_cdcooper,
    input 1,
    input 4,
    input 0,
    input 0,
    input "",
    input 1,
    INPUT "", /* nmarqlog */
    INPUT 0,  /* flabrechamado */
    INPUT "", /* texto_chamado */
    INPUT "", /* destinatario_email */
    INPUT 0,  /* flreincidente */
    INPUT 0).
CLOSE STORED-PROCEDURE pc_log_programa WHERE PROC-HANDLE = aux_handproc.
{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
                       
RUN fontes/fimprg.p.
/* .......................................................................... */

