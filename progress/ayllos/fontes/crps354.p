/* ..........................................................................

   Programa: Fontes/crps354.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio     
   Data    : Agosto/2003                      Ultima atualizacao: 08/05/2008
                                                                          
   Dados referentes ao programa:

   Frequencia: Mensal.                     
   Objetivo  : Atende a solicitacao 4
               Ordem do programa na solicitacao: 28.
               Automatizar a geracao do arquivos de controle do SEGURO VIDA.
               Arquivo de saida = /micros/COOPERATIVA/segvida

   Alteracoes: 02/01/2004 - Alteracao na rotina de calculo do ultimo dia do mes
                            (Julio)

               21/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               17/02/2006 - Unificacao dos bancos - SQLWorks - Eder            

               08/05/2008 - Ajuste comando FIND(craphis) utilizava FOR p/ acesso
                            (Sidnei - Precise)
                            
               19/10/2009 - Alteracao Codigo Historico (Kbase).
............................................................................. */

DEF STREAM str_1.

{ includes/var_batch.i "NEW" }

DEF        VAR aux_nmarquiv AS CHAR     FORMAT "x(20)"               NO-UNDO.
DEF        VAR aux_dtinicio AS DATE                                  NO-UNDO.
DEF        VAR aux_dttermin AS DATE                                  NO-UNDO.
DEF        VAR aux_flgunico AS LOGICAL                               NO-UNDO.
DEF        VAR tot_vllanmto AS DECIMAL  INIT 0                       NO-UNDO.
DEF        VAR tot_lancamen AS INT      INIT 0                       NO-UNDO.

DEF        VAR aux_nmmesano AS CHAR     EXTENT 12 INIT
                                        ["JANEIRO/","FEVEREIRO/",
                                         "MARCO/","ABRIL/",
                                         "MAIO/","JUNHO/",
                                         "JULHO/","AGOSTO/",
                                         "SETEMBRO/","OUTUBRO/",
                                         "NOVEMBRO/","DEZEMBRO/"]    NO-UNDO.

DEF        VAR aux_nmmesref AS CHAR                                  NO-UNDO.

glb_cdprogra = "crps354".
RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     QUIT.
      
/* Busca dados da cooperativa */

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> logo/proc_bath").
         QUIT.
     END.                 

ASSIGN aux_flgunico = TRUE
       aux_nmmesref = aux_nmmesano[MONTH(glb_dtmvtoan)] +
                                   STRING(YEAR(glb_dtmvtoan),"9999")
       aux_dtinicio = DATE(MONTH(glb_dtmvtoan),01,YEAR(glb_dtmvtoan))
       aux_dttermin = ((DATE(MONTH(glb_dtmvtoan),28,YEAR(glb_dtmvtoan)) + 4) -
                                   DAY(DATE(MONTH(glb_dtmvtoan),28,
                                            YEAR(glb_dtmvtoan)) + 4))
       aux_nmarquiv = "sv" + STRING(DAY(glb_dtmvtoan),"99") +
                             STRING(MONTH(glb_dtmvtoan),"99") +
                             SUBSTR(STRING(YEAR(glb_dtmvtoan),"9999"),3,2) +
                             ".txt".                                           

FOR EACH craplcm WHERE craplcm.cdcooper  = glb_cdcooper     AND
                       craplcm.dtmvtolt >= aux_dtinicio     AND
                       craplcm.dtmvtolt <= aux_dttermin     AND
                       craplcm.cdagenci  = 1                AND
                       craplcm.cdbccxlt  = 100              AND
                       craplcm.nrdolote  = 4154             AND
                       craplcm.cdhistor  = 341            
                       USE-INDEX craplcm1 NO-LOCK:

   IF   aux_flgunico THEN
        DO:
            OUTPUT STREAM str_1 TO VALUE("salvar/" + aux_nmarquiv).
            
            PUT STREAM str_1 SKIP(1)
                             "RELACAO DE SEGURO VIDA - REF. " AT 31
                             aux_nmmesref FORMAT "x(20)"      AT 61
                             SKIP(2).
              
            PUT STREAM str_1 "Data"              AT 01
                             "Conta"             AT 17
                             "Nome do Associado" AT 23
                             "Documento"         AT 55
                             "Historico"         AT 65
                             "D/C"               AT 90
                             "Valor"             AT 103
                             SKIP.

            PUT STREAM str_1 "---------- ----------" 
                             " ------------------------------ ----------"
                             " ------------------------ ---"
                             " --------------"
                             SKIP.

            aux_flgunico = FALSE.
        END.    

   /* FIND crapass OF craplcm NO-LOCK. */
   FIND crapass WHERE crapass.cdcooper = glb_cdcooper       AND
                      crapass.nrdconta = craplcm.nrdconta   NO-LOCK.
    
   IF   NOT AVAILABLE crapass THEN
        DO:
            PUT STREAM str_1 
                       craplcm.dtmvtolt  FORMAT "99/99/9999"
                       craplcm.nrdconta  FORMAT "zzzz,zzz,9"
                       craplcm.nrdocmto  FORMAT "zz,zzz,zz9"
                       craplcm.vllanmto  FORMAT "zzz,zzz,zzz,zz9"
                       "  Erro - Crapass nao cadastrado ".
            NEXT.           
        END.             

   FIND craphis NO-LOCK WHERE craphis.cdcooper = craplcm.cdcooper AND 
                              craphis.cdhistor = craplcm.cdhistor NO-ERROR.
   IF   NOT AVAILABLE craphis THEN
        DO:
            PUT STREAM str_1 craplcm.dtmvtolt  FORMAT "99/99/9999"
                             craplcm.nrdconta  FORMAT "zzzz,zzz,9"
                             craplcm.nrdocmto  FORMAT "zz,zzz,zz9"
                             craplcm.vllanmto  FORMAT "zzz,zzz,zzz,zz9"
                             "  Erro - Craphis nao cadastrado ".
            NEXT.           
        END.             

   PUT STREAM str_1 craplcm.dtmvtolt  FORMAT "99/99/9999" " "
                    craplcm.nrdconta  FORMAT "zzzz,zzz,9" " "
                    crapass.nmprimtl  FORMAT "x(30)"      " "
                    craplcm.nrdocmto  FORMAT "zz,zzz,zz9" " "
                    craplcm.cdhistor  FORMAT "9999"       "-"
                    craphis.dshistor  FORMAT "x(19)"      " "
                    craphis.indebcre  FORMAT "x"          " "
                    craplcm.vllanmto  FORMAT "zzzz,zzz,zzz.99"
                    SKIP.
                     
   tot_vllanmto = tot_vllanmto + craplcm.vllanmto.
   tot_lancamen = tot_lancamen + 1.
END.
                                                                    
IF   NOT aux_flgunico   THEN
     DO:                                         
         PUT STREAM str_1 SKIP
                          FILL("-", 107)    FORMAT "x(107)"
                          SKIP
                          "TOTAL DE LANCAMENTOS " 
                          tot_lancamen      FORMAT "zzzz9"
                          "VALOR TOTAL R$ " AT 50
                          tot_vllanmto      FORMAT "zzzz,zzz,zzz.99"  
                          SKIP.                 

         OUTPUT STREAM str_1 CLOSE.

         UNIX SILENT VALUE("ux2dos salvar/" + aux_nmarquiv + " > /micros/" + 
                            crapcop.dsdircop + "/segvida/" + aux_nmarquiv).
  
     END.
     
RUN fontes/fimprg.p. 
   
/*............................................................................*/

