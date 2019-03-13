/* ..........................................................................

   Programa: Fontes/crps645.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Douglas Pagel
   Data    : Julho/2013.                         Ultima atualizacao: 20/02/2019

   Dados referentes ao programa:

   Frequencia: Primeiro dia do Mes. (Batch - Background).
   Objetivo  : Emite relatorio de Tarifas pagas no mes anterior ao SICREDI.
               Disponibiliza arquivos na intranet. 

   Alteracoes: 12/03/2014 - Ajustes para liberacao (Adriano).
    
               05/05/2014 - Ajuste para rodar e gerar relatorio apenas da 
                            cooperativa em questão (Adriano).
                            
               05/09/2014 - Ajustes realizados:
                            - Utilizar o lote 10132 ao inves de historico 1399
                            - Utilizar o campo vlcompcr ao inves do vlcompdb
                            (Adriano). 
                            
               25/09/2015 - adicionados totais das colunas e removido o total de tarifa SICREDI
                            Projeto 255. (Lombardi).            
                             
               20/02/2019 - Inclusao de log de fim de execucao do programa 
                            (Belli - Envolti - Chamado REQ0039739) 
                           
............................................................................. */
{ includes/var_batch.i "NEW" }

/* Chamada Oracle - 20/02/2019 - REQ0039739 */
{ sistema/generico/includes/var_oracle.i }

DEF VAR rel_nmrelato AS CHAR FORMAT "x(40)" EXTENT 5               NO-UNDO.
DEF VAR rel_nmempres AS CHAR FORMAT "x(15)"                        NO-UNDO.
DEF VAR rel_nrmodulo AS INT  FORMAT "9"                            NO-UNDO.
DEF VAR rel_nmresemp AS CHAR FORMAT "x(15)"                        NO-UNDO.
DEF VAR rel_nmmodulo AS CHAR FORMAT "x(15)" EXTENT 5
                     INIT ["DEP. A VISTA   ","CAPITAL        ",
                           "EMPRESTIMOS    ","DIGITACAO      ",
                           "GENERICO       "]                      NO-UNDO.
DEF VAR aux_nmmesref AS CHAR FORMAT "x(10)" EXTENT 12
                        INIT ["JANEIRO/","FEVEREIRO/",
                              "MARCO/","ABRIL/",
                              "MAIO/","JUNHO/",
                              "JULHO/","AGOSTO/",
                              "SETEMBRO/","OUTUBRO/",
                              "NOVEMBRO/","DEZEMBRO/"]             NO-UNDO.

DEF VAR rel_nmmesref AS CHAR FORMAT "x(014)"                       NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR INIT "rl/crrl654"                     NO-UNDO.
DEF VAR aux_nmarqrel AS CHAR                                       NO-UNDO.
DEF VAR rel_dsagenci AS CHAR                                       NO-UNDO.
                                                                   
DEF VAR aux_datainic AS DATE                                       NO-UNDO.
DEF VAR aux_datafina AS DATE                                       NO-UNDO.
DEF VAR aux_datarepe AS DATE                                       NO-UNDO.
DEF VAR aux_vltottar AS DECIMAL FORMAT "zzz,zzz,zz9.99"            NO-UNDO.
DEF VAR aux_qtdbenef AS INTEGER FORMAT "zzz,zz9"                   NO-UNDO. 
DEF VAR aux_vlbenefi AS DECIMAL FORMAT "zzz,zzz,zz9.99"            NO-UNDO.
DEF VAR aux_vltarifa AS DECIMAL FORMAT "zzz,zzz,zz9.99"            NO-UNDO.
DEF VAR aux_qtdtotbe AS INTEGER FORMAT "zzz,zz9"                   NO-UNDO. 
DEF VAR aux_vlrtotbe AS DECIMAL FORMAT "zzz,zzz,zz9.99"            NO-UNDO.
DEF VAR aux_vlrtotta AS DECIMAL FORMAT "zzz,zzz,zz9.99"            NO-UNDO.
DEF VAR aux_dtcalcul AS DATE                                       NO-UNDO.

DEF STREAM str_1.

DEF TEMP-TABLE tt-dados                                            NO-UNDO
    FIELD cdagenci LIKE craplot.cdagenci
    FIELD nrbenefi LIKE craplot.qtinfoln
    FIELD vlbenefi LIKE craplot.vlcompcr
    FIELD vltarifa AS DECIMAL
    FIELD dtmvtolt AS DATE.

FORM SKIP(2)
     "PA"                                      AT  3
     "QUANT. BENEFICIOS PAGOS"                 AT 12
     "VALOR BENEFICIOS PAGOS"                  AT 42
     "TARIFA SICREDI"                          AT 71 
     SKIP
     "---"                                     AT  2
     "-----------------------"                 AT 12
     "----------------------"                  AT 42
     "--------------"                          AT 71
     WITH NO-BOX NO-ATTR-SPACE NO-LABEL WIDTH 132 FRAME f_label.

FORM tt-dados.cdagenci     AT  2   
     aux_qtdbenef          AT 28   
     aux_vlbenefi          AT 50
     aux_vltarifa          AT 71
     WITH NO-BOX NO-ATTR-SPACE NO-LABEL DOWN WIDTH 132 FRAME f_dados.

FORM SKIP(2)
     "TOTAL: "    AT  2
     aux_qtdtotbe AT 28
     aux_vlrtotbe AT 50
     aux_vlrtotta AT 71
     WITH NO-BOX NO-ATTR-SPACE NO-LABEL DOWN WIDTH 132 FRAME f_total.

ASSIGN glb_cdrelato[1] = 654
       glb_cdprogra = "crps645".

RUN fontes/iniprg.p.

IF glb_cdcritic > 0 THEN
   RETURN.

/*Encontra o primeiro dia util do mes.*/
ASSIGN aux_dtcalcul = DATE(MONTH(glb_dtmvtolt),01,YEAR(glb_dtmvtolt)).

DO WHILE TRUE:

   IF CAN-DO("1,7",STRING(WEEKDAY(aux_dtcalcul)))                   OR
      CAN-FIND(FIRST crapfer WHERE crapfer.cdcooper = glb_cdcooper  AND
                                   crapfer.dtferiad = aux_dtcalcul) THEN
      DO:
         ASSIGN aux_dtcalcul = aux_dtcalcul + 1.

         NEXT.

      END.

   LEAVE.
      
END.
/*
/*Executa somente no primeiro dia util do mes.*/
IF glb_dtmvtolt <> aux_dtcalcul THEN
   RETURN.
*/
FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF NOT AVAILABLE crapcop THEN
   DO:
   
       ASSIGN glb_cdcritic = 651.

       RUN fontes/critic.p.
       UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                         " - " + glb_cdprogra + "' --> '"  +
                         glb_dscritic + " >> log/proc_batch.log").

       RETURN.

   END.

{ includes/cabrel132_1.i }               /* Monta cabecalho do relatorio */

ASSIGN aux_datafina = glb_dtmvtolt - DAY(glb_dtmvtolt)
       aux_datainic = aux_datafina - DAY(aux_datafina) + 1
       aux_datarepe = aux_datainic
       aux_vltottar = 0
       aux_nmarqrel = "/usr/coop/" + TRIM(crapcop.dsdircop) +
                      "/rl/crrl654.lst".

EMPTY TEMP-TABLE tt-dados NO-ERROR.

for-data:
REPEAT:

   IF aux_datarepe <= aux_datafina THEN
      DO:
         FOR EACH craplot WHERE craplot.cdcooper = crapcop.cdcooper AND
                                craplot.dtmvtolt = aux_datarepe     AND
                                craplot.nrdolote = 10132             
                                NO-LOCK:
      
             CREATE tt-dados.

             ASSIGN tt-dados.cdagenci = craplot.cdagenci
                    tt-dados.nrbenefi = craplot.qtinfoln
                    tt-dados.vlbenefi = craplot.vlcompcr
                    tt-dados.vltarifa = craplot.qtinfoln * 
                                        crapcop.vltarsic
                    tt-dados.dtmvtolt = craplot.dtmvtolt. 

         END.

         ASSIGN aux_datarepe = aux_datarepe + 1.

      END.
   ELSE
      LEAVE for-data.

 END.

OUTPUT STREAM str_1 TO VALUE(aux_nmarqrel) PAGED PAGE-SIZE 84.

VIEW STREAM str_1 FRAME f_cabrel132_1.

DISPLAY STREAM str_1 WITH FRAME f_label.

ASSIGN aux_qtdtotbe = 0
       aux_vlrtotbe = 0
       aux_vlrtotta = 0.

FOR EACH tt-dados BREAK BY tt-dados.cdagenci:

    IF FIRST-OF(tt-dados.cdagenci) THEN
       ASSIGN aux_qtdbenef = 0
              aux_vlbenefi = 0
              aux_vltarifa = 0.

    ASSIGN aux_qtdbenef = aux_qtdbenef + tt-dados.nrbenefi
           aux_vlbenefi = aux_vlbenefi + tt-dados.vlbenefi
           aux_vltarifa = aux_vltarifa + tt-dados.vltarifa.
    
    IF LAST-OF(tt-dados.cdagenci) THEN
       DO:
           DISPLAY STREAM str_1 tt-dados.cdagenci 
                                aux_qtdbenef
                                aux_vlbenefi 
                                aux_vltarifa
                                WITH FRAME f_dados.
       
           DOWN STREAM str_1 WITH FRAME f_dados.

           ASSIGN aux_qtdtotbe = aux_qtdtotbe + aux_qtdbenef
                  aux_vlrtotbe = aux_vlrtotbe + aux_vlbenefi
                  aux_vlrtotta = aux_vlrtotta + aux_vltarifa.
       END.


END.

DISPLAY STREAM str_1 aux_qtdtotbe
                     aux_vlrtotbe
                     aux_vlrtotta
                     WITH FRAME f_total.

OUTPUT STREAM str_1 CLOSE.

ASSIGN glb_nmarqimp = "rl/crrl654.lst"
       glb_nmformul = "132col".

RUN fontes/imprim_unif.p (INPUT crapcop.cdcooper).

/* Inclusao de log de fim de execucao do programa -  20/02/2019 - Chamado REQ0039739 */

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
   (INPUT "O",
    INPUT "CRPS645.P",
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
    INPUT "CRPS645.P",
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

