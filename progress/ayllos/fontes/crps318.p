/* ..........................................................................

   Programa: Fontes/crps318.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete      
   Data    : Dezembro/2001                   Ultima atualizacao: 20/02/2019

   Dados referentes ao programa:

   Frequencia: Mensal (Batch - Background).
   Objetivo  : Gera arquivo dos movimentos para Hering/EMS
               Atende a solicitacao 002.

   Alteracoes: Alterar codigo de Banco de 756 para 555(Mirtes)
               
               24/03/2004 - Alterar modo de transmissao do extrato da HERING,
                            de transfisc para NEXXERA (Junior).
               27/07/2004 - Alterado com  path /usr/nexxera/envia(Mirtes)

               21/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               16/02/2006 - Unificacao dos bancos - SQLWorks - Eder
               
               09/06/2008 - Incluído o mecanismo de pesquisa no "find" na 
                            tabela CRAPHIS para buscar primeiro pela chave de
                            acesso (craphis.cdcooper = glb_cdcooper). 
                            - Kbase IT Solutions - Paulo Ricardo Maciel.
                             
               20/02/2019 - Inclusao de log de fim de execucao do programa 
                            (Belli - Envolti - Chamado REQ0039739)
               
............................................................................. */

DEF STREAM str_1.     /* Para arquivo */

{ includes/var_batch.i "NEW" } 

/* chamado oracle - 20/02/2019 - Chamado REQ0039739 */
{ sistema/generico/includes/var_oracle.i }

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                                       INIT ["DEP. A VISTA   ",
                                             "CAPITAL        ",
                                             "EMPRESTIMOS    ",
                                             "DIGITACAO      ",
                                             "GENERICO       "]      NO-UNDO.

DEF        VAR rel_nmempres AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmresemp AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.

DEF        VAR aux_nmformul AS CHAR    FORMAT "x(005)" INIT ""       NO-UNDO.
DEF        VAR aux_dsdidade AS CHAR                                  NO-UNDO.
DEF        VAR aux_lsconta1 AS CHAR                                  NO-UNDO.
DEF        VAR aux_indctatb AS INTEGER                               NO-UNDO.
DEF        VAR aux_nrdconta LIKE craplcm.nrdconta                    NO-UNDO.
DEF        VAR aux_strconta AS CHAR    FORMAT "x(10)"                NO-UNDO.
DEF        VAR aux_dshistor AS CHAR                                  NO-UNDO.
DEF        VAR aux_indebcre AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarqsai AS CHAR                                  NO-UNDO.
DEF        VAR aux_flgmvtos AS LOGICAL                               NO-UNDO.

ASSIGN glb_cdprogra = "crps318"
       glb_flgbatch = false.

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   crapcop.cdcooper <> 1   THEN             /*  Somente para a CREDIHERING  */
     DO:
         RUN fontes/fimprg.p. 
         RETURN.
     END.

/*  Le tabela com as contas da Cia Hering  */

FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                   craptab.nmsistem = "CRED"        AND
                   craptab.tptabela = "USUARI"      AND
                   craptab.cdempres = 11            AND
                   craptab.cdacesso = "CTASHERING"  AND
                   craptab.tpregist = 000           NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     DO:
         glb_cdcritic = 55.
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         glb_nmdatela = " ".
         RETURN.
     END.
ELSE
     aux_lsconta1 = craptab.dstextab.

ASSIGN aux_indctatb = 0
       aux_flgmvtos = NO
       aux_nmarqsai = "555" + 
                      STRING(MONTH(glb_dtmvtolt),"99") + 
                      STRING(DAY(glb_dtmvtolt),"99") +
                      ".ok".

OUTPUT STREAM str_1 TO VALUE("arq/" + aux_nmarqsai).
        
REPEAT:

   ASSIGN aux_indctatb = aux_indctatb + 1.

   IF   INTE(ENTRY(aux_indctatb,aux_lsconta1,",")) = 0   THEN
        LEAVE.

   ASSIGN aux_nrdconta = INTE(ENTRY(aux_indctatb,aux_lsconta1,","))
          aux_strconta = STRING(aux_nrdconta,"9999999999").

   FOR EACH craplcm WHERE craplcm.cdcooper  = glb_cdcooper   AND
                          craplcm.nrdconta  = aux_nrdconta   AND
                          craplcm.dtmvtolt  = glb_dtmvtolt   AND
                          craplcm.cdhistor <> 289
                          USE-INDEX craplcm2 NO-LOCK
                          BREAK BY craplcm.nrdconta:

       IF   NOT aux_flgmvtos   THEN
            DO:
                PUT STREAM str_1
                    FILL(" ",35)  FORMAT "x(35)"
                    "0"
                    FILL(" ",240) FORMAT "x(240)"
                    "555"
                    SUBSTR(STRING(YEAR(craplcm.dtmvtolt)),3,2) FORMAT "x(02)"
                    MONTH(craplcm.dtmvtolt)                    FORMAT "99"
                    DAY(craplcm.dtmvtolt)                      FORMAT "99"
                    SKIP.
                ASSIGN aux_flgmvtos = YES.
            END.     
       
       ASSIGN aux_dshistor = ""
              aux_indebcre = "".
              
       FIND craphis WHERE craphis.cdcooper = glb_cdcooper     AND
                          craphis.cdhistor = craplcm.cdhistor NO-LOCK NO-ERROR.
       
       IF   AVAILABLE craphis   THEN
            ASSIGN aux_dshistor = craphis.dshistor
                   aux_indebcre = craphis.indebcre.
                      
       PUT STREAM str_1
           FILL(" ",22)                                       FORMAT "x(22)"
           SUBSTR(aux_strconta,1,9)                           FORMAT "x(09)"
           SUBSTR(aux_strconta,10,1)                          FORMAT "x(01)"
           FILL(" ",3)                                        FORMAT "x(03)"
           "1"
           FILL(" ",7)                                        FORMAT "x(07)"
           SUBSTR(STRING(YEAR(craplcm.dtmvtolt)),3,2)         FORMAT "x(02)"
           MONTH(craplcm.dtmvtolt)                            FORMAT "99"
           DAY(craplcm.dtmvtolt)                              FORMAT "99"
           STRING(craplcm.nrdocmto,"9999999999999999")        FORMAT "x(16)"   
           aux_dshistor                                       FORMAT "x(30)"
           STRING((craplcm.vllanmto * 100),"999999999999999") FORMAT "x(15)"
           aux_indebcre                                       FORMAT "x(01)"
           FILL(" ",171)                                      FORMAT "x(171)"
           "555"
           SKIP.      

   END.
    
END.
 
OUTPUT STREAM str_1 CLOSE.

IF   aux_flgmvtos   THEN  
     DO:  

         UNIX SILENT VALUE("cp arq/" + aux_nmarqsai + " salvar 2> /dev/null").

         UNIX SILENT VALUE("cp arq/" + aux_nmarqsai + 
                           " /usr/nexxera/envia/ 2> /dev/null").

         glb_cdcritic = 748.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                            glb_cdprogra + " >> log/proc_batch.log").
                                   
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                            glb_cdprogra + "' --> '" +
                            glb_dscritic + " " + aux_nmarqsai + 
                            " - EXTRATO HERING V: __________" + 
                            " >> log/proc_batch.log").
               
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                            glb_cdprogra + " >> log/proc_batch.log").

/************   PROCEDIMENTO VIA FTP (ANTIGO)      
         
         UNIX SILENT VALUE("transfisc arq " + aux_nmarqsai + " " +
                               aux_nmarqsai + " " + STRING(TIME)).

            glb_cdcritic = 658.
            RUN fontes/critic.p.
            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                              glb_cdprogra + "' --> '" +
                              glb_dscritic + " arq/" + aux_nmarqsai + 
                              " PARA HERING" + 
                              " >> log/proc_batch.log").
*******************/ 
     END.
 
UNIX SILENT VALUE("rm arq/" + aux_nmarqsai + " 2> /dev/null").

/* Inclusao de log de fim de execucao do programa -  20/02/2019 - Chamado REQ0039739 */

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
   (INPUT "O",
    INPUT "CRPS318.P",
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
    INPUT "CRPS318.P",
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

