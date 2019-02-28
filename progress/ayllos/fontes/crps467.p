/* .............................................................................

   Programa: Fontes/crps467.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Diego   
   Data    : Janeiro/2007                       Ultima atualizacao: 20/02/2019
      
   Dados referentes ao programa:

   Frequencia : Mensal.
   Solicitacao: 89 - Paralelo
   Ordem      : 2 
   Objetivo   : Verificar convenios pendentes de fechamento.

   Alteracoes: 09/08/2007 - Retirado envio de e-mail para Suzana@cecred.coop.br
                           (Guilherme) 
   
               01/04/2008 - Alterado envio de email para BO b1wgen0011
                            (Sidnei - Precise)

               15/05/2015 - Projeto 158 - Servico Folha de Pagto
                            (Andre Santos - SUPERO)

			   26/05/2018 - Ajustes referente alteracao da nova marca (P413 - Jonata Mouts).
                             
               20/02/2019 - Inclusao de log de fim de execucao do programa 
                            (Belli - Envolti - Chamado REQ0039739)
							
............................................................................. */

DEF STREAM str_1.  

DEF   VAR b1wgen0011   AS HANDLE                                     NO-UNDO.

{ includes/var_batch.i "NEW" }

/* Chamada Oracle - 20/02/2019 - REQ0039739 */
{ sistema/generico/includes/var_oracle.i }

DEF   VAR aux_nmarqimp AS CHAR                                      NO-UNDO.
DEF   VAR aux_dtfimmes AS DATE    FORMAT "99/99/9999"               NO-UNDO.
DEF   VAR aux_dsempres AS CHAR    FORMAT "x(20)"                    NO-UNDO.
DEF   VAR aux_convenio AS CHAR    FORMAT "x(45)"                    NO-UNDO.
DEF   VAR aux_flgconve AS LOGICAL                                   NO-UNDO.
DEF   VAR aux_flgempre AS LOGICAL                                   NO-UNDO.


DEF  TEMP-TABLE w-pendentes                                         NO-UNDO
     FIELD nrconven AS INT
     FIELD dsconven AS CHAR
     FIELD cdempres AS INT
     FIELD nmresemp AS CHAR.                                         
     

ASSIGN glb_cdprogra = "crps467"
       aux_nmarqimp = "rl/pendencia_convenios.txt"
       aux_flgconve = FALSE
       aux_flgempre = FALSE.

RUN fontes/iniprg.p.
               
ASSIGN aux_dtfimmes = glb_dtmvtolt - DAY(glb_dtmvtolt).

FOR EACH crapepc WHERE crapepc.cdcooper = glb_cdcooper  AND
                       crapepc.dtrefere = aux_dtfimmes  NO-LOCK:

    ASSIGN aux_flgconve = TRUE.
    
    IF   NOT((crapepc.incvcta1 = 2 AND crapepc.incvcta2 <> 1) OR
             (crapepc.incvfol1 = 2 AND crapepc.incvfol2 = 2 ))  THEN
         DO:
             FIND crapcnv WHERE crapcnv.cdcooper = glb_cdcooper   AND
                                crapcnv.nrconven = crapepc.nrconven
                                NO-LOCK NO-ERROR.
                                 
             FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper   AND
                                crapemp.cdempres = crapepc.cdempres
                                NO-LOCK NO-ERROR.
              
             CREATE w-pendentes.
             ASSIGN w-pendentes.nrconven = crapcnv.nrconven
                    w-pendentes.dsconven = crapcnv.dsconven
                    w-pendentes.cdempres = crapemp.cdempres
                    w-pendentes.nmresemp = crapemp.nmresemp.
                     
         END.
                          
END.

FOR EACH crapemp WHERE crapemp.cdcooper = glb_cdcooper
                   AND (crapemp.flgpagto = TRUE
                    OR  crapemp.flgpgtib = TRUE)  NO-LOCK:
                       
    ASSIGN aux_flgempre = TRUE.
    
    FIND FIRST crapfol WHERE crapfol.cdcooper = glb_cdcooper     AND
                             crapfol.cdempres = crapemp.cdempres AND
                             crapfol.dtrefere = aux_dtfimmes 
                             NO-LOCK NO-ERROR.
                             
    IF   NOT AVAILABLE crapfol  THEN
         DO:
             CREATE w-pendentes.
             ASSIGN w-pendentes.nrconven = 0
                    w-pendentes.dsconven = ""
                    w-pendentes.cdempres = crapemp.cdempres.
                    w-pendentes.nmresemp = crapemp.nmresemp.
         END.
         
END.
         

OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

FORM HEADER
     crapcop.nmrescop "-" crapcop.nmextcop 
     SKIP(1)
     "DATA DE REFERENCIA: " STRING(aux_dtfimmes, "99/99/9999") FORMAT "x(10)"
     SKIP(2)
     WITH WIDTH 90 CENTERED PAGE-TOP FRAME f_cabecalho.

VIEW STREAM str_1 FRAME f_cabecalho.

IF   aux_flgconve  THEN
     PUT STREAM str_1 " => CONVENIOS PENDENTES DE FECHAMENTO" SKIP(1).
     
FOR EACH w-pendentes WHERE w-pendentes.nrconven <> 0 
         BY w-pendentes.nrconven:

    ASSIGN aux_convenio = STRING(w-pendentes.nrconven) + "-" + 
                          w-pendentes.dsconven
           aux_dsempres = STRING(w-pendentes.cdempres) + "-" +
                          w-pendentes.nmresemp.
    
    DISPLAY STREAM str_1 
            aux_convenio  LABEL "CONVENIO"
            aux_dsempres  LABEL "EMPRESA".

END.

PUT STREAM str_1 SKIP(2).

IF   aux_flgempre  THEN
     PUT STREAM str_1 " => EMPRESAS PENDENTES DE CREDITO DO SALARIO" SKIP(1).

FOR EACH w-pendentes WHERE w-pendentes.nrconven = 0
         BREAK BY w-pendentes.cdempres:
         
    ASSIGN aux_dsempres = STRING(w-pendentes.cdempres) + "-" +
                          w-pendentes.nmresemp.
    
    DISPLAY STREAM str_1 
            aux_dsempres  LABEL "EMPRESA".
END.

OUTPUT STREAM str_1 CLOSE.
                                       
IF   aux_flgconve OR aux_flgempre  THEN
DO:
     /* Move para diretorio converte para utilizar na BO */
     UNIX SILENT VALUE 
           ("cp " + aux_nmarqimp + " /usr/coop/" +
            crapcop.dsdircop + "/converte" + 
            " 2> /dev/null").
         
     /* envio de email */ 
     RUN sistema/generico/procedures/b1wgen0011.p
         PERSISTENT SET b1wgen0011.
         
     RUN enviar_email IN b1wgen0011
                   (INPUT glb_cdcooper,
                    INPUT glb_cdprogra,
                    INPUT "willian@ailos.coop.br",
                    INPUT '"PENDENCIAS COM CONVENIOS"',
                    INPUT SUBSTRING(aux_nmarqimp, 4),
                    INPUT FALSE).
                                 
     DELETE PROCEDURE b1wgen0011.
END.

/* Inclusao de log de fim de execucao do programa -  20/02/2019 - Chamado REQ0039739 */

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
   (INPUT "O",
    INPUT "CRPS467.P",
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
    INPUT "CRPS467.P",
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

/* ......................................................................... */
