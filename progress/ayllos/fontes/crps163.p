/*  ..........................................................................

   Programa: Fontes/crps163.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Junho/96.                          Ultima atualizacao: 23/11/2009.

   Dados referentes ao programa:

   Frequencia: Mensal - Primeiro dia util do mes.
   Objetivo  : Atende a solicitacao 53.
               Emite arquivo com o movimento mensal em conta-corrente para
               conciliacao com o sistema de contabilidade HERCULES.

   Alteracoes: 28/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               26/06/98 - Alterado para NAO tratar o historico 289 (Edson).

               06/01/2000 - Tratar mais de uma cooperativa e nao gerar mais    
                            arquivo (Deborah).

               21/05/2001 - Enviar arquivo para Cooper. (Ze Eduardo).
               
               02/08/2002 - Tratamento de Erro - craplcm.nrdocmto (Ze Eduardo).
               
               19/09/2002 - Alterado para enviar arquivo de conciliacao
                            automaticamente (Junior).
                            
               22/11/2002 - Colocar "&" no fim do comando "MT SEND" (Junior).
               
               02/10/2003 - Nao imprimir o relatorio - Pitanga (Ze Eduardo).

               20/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               15/02/2006 - Unificacao dos bancos - SQLWorks - Eder      
                      
               20/11/2006 - Envio de email pela BO b1wgen0011 (David).

               12/04/2007 - Retirar rotina de email em comentario (David).
                      
               18/03/2008 - Retirado comentario da rotina de envio de email
                            (Sidnei - Precise)

               08/05/2008 - Ajuste comando FIND(craphis) utilizava FOR p/ acesso
                            (Sidnei - Precise)
            
               07/04/2009 - Tipo da variavel aux_nrdocmto trocado para
                            decimal para armazenar valores maiores e 
                            aumentado o formato de craplcm.nrdocmto (Gabriel).
                            
               29/09/2009 - Aumentado o format da variavel aux_nrdocmto
                            (Fernando).              

               23/11/2009 - Alteracao Codigo Historico (Kbase). 
............................................................................. */

DEF STREAM str_1.     /*  Para arquivo de conciliacao  */

{ includes/var_batch.i "NEW" }

DEF        VAR b1wgen0011   AS HANDLE                                NO-UNDO.

DEF        VAR rel_nmresemp AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                                       INIT ["DEP. A VISTA   ",
                                             "CAPITAL        ",
                                             "EMPRESTIMOS    ",
                                             "DIGITACAO      ",
                                             "GENERICO       "]      NO-UNDO.

DEF        VAR tab_dosmeses  AS CHAR   FORMAT "x(15)" EXTENT 12
                                       INIT ["JANEIRO/","FEVEREIRO/",
                                             "MARCO/","ABRIL/","MAIO/",
                                             "JUNHO/","JULHO/",
                                             "AGOSTO/","SETEMBRO/",
                                             "OUTUBRO/","NOVEMBRO/",
                                             "DEZEMBRO/"].

DEF        VAR rel_dtlimite AS DATE                                  NO-UNDO.
DEF        VAR aux_dtlimite AS DATE                                  NO-UNDO.
DEF        VAR aux_nrdocmto AS DEC                                   NO-UNDO.

DEF        VAR aux_vllanmto AS DECIMAL                               NO-UNDO.
DEF        VAR aux_dssinal1 AS CHAR                                  NO-UNDO.
DEF        VAR aux_vlinimes AS DECIMAL                               NO-UNDO.
DEF        VAR aux_dssinal2 AS CHAR                                  NO-UNDO.
DEF        VAR aux_vlfimmes AS DECIMAL                               NO-UNDO.
DEF        VAR aux_dssinal3 AS CHAR                                  NO-UNDO.

DEF        VAR aux_nmarqsai AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarqsal AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.

DEF        VAR aux_mesrefer AS CHAR                                  NO-UNDO.
DEF        VAR aux_dshistor AS CHAR                                  NO-UNDO.

FORM   crapsld.nrdconta AT 12 LABEL "CONTA/DV" FORMAT "zzzz,zz9,9"
       aux_mesrefer     AT 40 LABEL "MES DE REFERENCIA" FORMAT "x(15)"
       SKIP(1)
       WITH NO-BOX DOWN SIDE-LABELS FRAME f_cab.

FORM   craplcm.dtmvtolt AT  4 LABEL "DATA"         FORMAT "99/99/9999"
       aux_dshistor     AT 15 LABEL "HISTORICO"    FORMAT "x(21)"
       craplcm.nrdocmto AT 40 LABEL "DOCUMENTO"    FORMAT "zzz,zzz,zzz,zz9"
       craplcm.vllanmto AT 57 LABEL "VALOR DO LANCAMENTO"
       craphis.indebcre AT 77 LABEL "D/C"
       WITH NO-BOX DOWN NO-LABELS FRAME f_lanctos.

glb_cdprogra = "crps163".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

/*  Busca dados da cooperativa  */

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

IF   crapcop.cdcooper <> 1 THEN
     DO:
         RUN fontes/fimprg.p.
         QUIT.
     END.

ASSIGN aux_dtlimite = glb_dtmvtolt - DAY(glb_dtmvtolt)
       aux_dtlimite = aux_dtlimite - DAY(aux_dtlimite)

       rel_dtlimite = aux_dtlimite + 1

       aux_mesrefer = tab_dosmeses[MONTH(rel_dtlimite)] +
                      STRING(YEAR(rel_dtlimite),"9999")

       aux_nmarqimp = "rl/crrl134.lst"

       aux_nmarqsai = "cons" +
                      STRING(MONTH(aux_dtlimite + 1),"99") +
                      STRING(YEAR(aux_dtlimite + 1),"9999") +
                      ".ext".

FIND crapsld WHERE crapsld.cdcooper = glb_cdcooper  AND
                   crapsld.nrdconta = 85448         NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapsld   THEN
     DO:
         glb_cdcritic = 10.
         RUN fontes/critic.p.
         UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                            glb_cdprogra + "' --> '" + glb_dscritic +
                            " CONTA = 8.544-8 " + " >> log/proc_batch.log").
         QUIT.
     END.

OUTPUT STREAM str_1 TO VALUE("arq/" + aux_nmarqsai).

ASSIGN aux_nrdocmto = 0
       aux_vllanmto = 0
       aux_dssinal1 = ""
       aux_vlinimes = IF crapsld.vlsdextr < 0
                         THEN crapsld.vlsdextr * -1
                         ELSE crapsld.vlsdextr
       aux_dssinal2 = IF crapsld.vlsdextr < 0
                         THEN "-"
                         ELSE "+"
       aux_vlfimmes = 0
       aux_dssinal3 = "".

PUT STREAM str_1
    (aux_dtlimite + 1) FORMAT "99/99/9999"  " "
    aux_nrdocmto       FORMAT "999,999,999,999.99" " "
    aux_vllanmto       FORMAT "999,999,999,999.99" " "
    aux_dssinal1       FORMAT "x" " "
    aux_vlinimes       FORMAT "999,999,999,999.99" " "
    aux_dssinal2       FORMAT "x" " "
    aux_vlfimmes       FORMAT "999,999,999,999.99" " "
    aux_dssinal3       FORMAT "x" SKIP.

FOR EACH craplcm WHERE craplcm.cdcooper  = glb_cdcooper      AND
                       craplcm.nrdconta  = crapsld.nrdconta  AND
                       craplcm.dtmvtolt  > aux_dtlimite      AND
                       craplcm.dtmvtolt  < glb_dtmvtolt      AND
                       craplcm.cdhistor <> 289               
                       NO-LOCK USE-INDEX craplcm2:

    FIND craphis NO-LOCK WHERE craphis.cdcooper = craplcm.cdcooper AND 
                               craphis.cdhistor = craplcm.cdhistor NO-ERROR.
    
    IF   NOT AVAILABLE craphis   THEN
         DO:
              glb_cdcritic = 80.
              RUN fontes/critic.p.
              UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                 glb_cdprogra + "' --> '" + glb_dscritic +
                                 " CONTA = 8.544-8 " + " Documento " +
                                 STRING(craplcm.nrdocmto) + " Hit. " +
                                 STRING(craplcm.cdhistor) +
                                 " >> log/proc_batch.log").
              QUIT.
         END.

        
    
    ASSIGN aux_nrdocmto = craplcm.nrdocmto
           aux_vllanmto = craplcm.vllanmto

           aux_dssinal1 = IF craphis.indebcre = "D"
                             THEN "-"
                             ELSE "+"

           aux_vlinimes = 0
           aux_dssinal2 = ""

           aux_vlfimmes = 0
           aux_dssinal3 = "".

    PUT STREAM str_1
        craplcm.dtmvtolt FORMAT "99/99/9999"  " "
        aux_nrdocmto     FORMAT "999,999,999,999.99" " "
        aux_vllanmto     FORMAT "999,999,999,999.99" " "
        aux_dssinal1     FORMAT "x" " "
        aux_vlinimes     FORMAT "999,999,999,999.99" " "
        aux_dssinal2     FORMAT "x" " "
        aux_vlfimmes     FORMAT "999,999,999,999.99" " "
        aux_dssinal3     FORMAT "x" SKIP.

END.  /*  Fim do FOR EACH  --  Leitura dos lancamentos  */

ASSIGN aux_nrdocmto = 0
       aux_vllanmto = 0
       aux_dssinal1 = ""
       aux_vlinimes = 0
       aux_dssinal2 = ""
       aux_vlfimmes = IF crapsld.vlsdmesa < 0
                         THEN crapsld.vlsdmesa * -1
                         ELSE crapsld.vlsdmesa
       aux_dssinal3 = IF crapsld.vlsdmesa < 0
                         THEN "-"
                         ELSE "+".

PUT STREAM str_1
    (glb_dtmvtolt - DAY(glb_dtmvtolt)) FORMAT "99/99/9999"  " "
    aux_nrdocmto       FORMAT "999,999,999,999.99" " "
    aux_vllanmto       FORMAT "999,999,999,999.99" " "
    aux_dssinal1       FORMAT "x" " "
    aux_vlinimes       FORMAT "999,999,999,999.99" " "
    aux_dssinal2       FORMAT "x" " "
    aux_vlfimmes       FORMAT "999,999,999,999.99" " "
    aux_dssinal3       FORMAT "x" SKIP.

OUTPUT STREAM str_1 CLOSE.

{ includes/cabrel080_1.i }

OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

VIEW STREAM str_1 FRAME f_cabrel080_1.

DISPLAY STREAM str_1 crapsld.nrdconta aux_mesrefer WITH FRAME f_cab.

DOWN STREAM str_1 WITH FRAME f_cab.

FOR EACH craplcm WHERE craplcm.cdcooper = glb_cdcooper      AND
                       craplcm.nrdconta = crapsld.nrdconta  AND
                       craplcm.dtmvtolt > aux_dtlimite      AND
                       craplcm.dtmvtolt < glb_dtmvtolt      AND
                       craplcm.cdhistor <> 289              
                       NO-LOCK USE-INDEX craplcm2
                       BY craplcm.vllanmto
                          BY  craplcm.nrdocmto:

    FIND craphis NO-LOCK WHERE craphis.cdcooper = craplcm.cdcooper AND 
                               craphis.cdhistor = craplcm.cdhistor NO-ERROR.
                               
    aux_dshistor = STRING(craphis.cdhistor,"zzz9") + " - " + craphis.dshistor.

    IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1) THEN
         DO:
             PAGE STREAM str_1.
             DISPLAY STREAM str_1 crapsld.nrdconta aux_mesrefer
                                  WITH FRAME f_cab.

             DOWN STREAM str_1 WITH FRAME f_cab.
         END.

    DISPLAY STREAM str_1 craplcm.dtmvtolt  
                         aux_dshistor 
                         craplcm.nrdocmto 
                         craplcm.vllanmto
                         craphis.indebcre  WITH FRAME f_lanctos.

    DOWN STREAM str_1 WITH FRAME f_lanctos.

END.  /*  Fim do FOR EACH  --  Leitura dos lancamentos  */

OUTPUT STREAM str_1 CLOSE.

RUN sistema/generico/procedures/b1wgen0011.p
PERSISTENT SET b1wgen0011.
             
RUN converte_arquivo IN b1wgen0011 (INPUT glb_cdcooper,
                                    INPUT "arq/" + aux_nmarqsai,
                                    INPUT aux_nmarqsai).

RUN enviar_email IN b1wgen0011 (INPUT glb_cdcooper,
                                INPUT glb_cdprogra,
                                INPUT "adilson@coopermix.com.br",
                                INPUT "ARQUIVO DE CONCILIACAO VIACREDI", 
                                INPUT aux_nmarqsai,
                                INPUT false).
                                   
DELETE PROCEDURE b1wgen0011.
 
ASSIGN glb_nmarqimp = aux_nmarqimp
       glb_nrcopias = 1
       glb_nmformul = "80col".

RUN fontes/fimprg.p.

/* .......................................................................... */
