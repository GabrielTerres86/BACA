
/* ..........................................................................

   Programa: Fontes/crps619.p  
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Adriano     
   Data    : Marco/2012.                        Ultima atualizacao: 25/10/2017

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Gerar arquivos de arrecadacao a cada "x" minutos.
   
                  
   Alteracoes : 02/07/2012 - Substituido 'gncoper' por 'crapcop' (Tiago).

                01/11/2012 - Ajustes na agencia arrecadadora e na autenticacao
                             no arquivo de arrecadacao (Elton).
                             
                15/03/2013 - Substituido destino dos arquivos parciais para:
                             "/usr/coop/cecred/salvar" (Daniele).   
                             
                13/11/2013 - Alterado totalizador de PAs de 99 para 999.
                             (Reinert)   
                
                14/01/2014 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( Andre Euzebio / SUPERO)
                            
                20/05/2014 - Substituido texto do header do arquivo
                             (De: 'ARRECADACAO CAIXA' Para: 'CODIGO DE BARRAS ').
                             (Chamado 154969) - (Fabricio)
                             
                27/07/2015 - Incluir tratamento para data dtmvtopr por tipo
                             de repasse (Lucas Ranghetti #311550 )

               29/02/2016 - Aumentado format do nrautdoc para 9 digitos - 
							Alteracao emergencial (Lucas Ranghetti/Fabricio)
         
 		       06/05/2016 - Correção no if que verifica a agência para buscar 
                            valor da tarifa.  (Chamado 410647 -  Gisele RKAM)  
               
               09/06/2016 - Incluir envio para e-sales na rajada (Lucas Ranghetti #467269)
               
               15/06/2016 - Adicnioar ux2dos para a Van E-sales (Lucas Ranghetti #469980)

			   23/06/2016 - P333.1 - Devolução de arquivos com tipo de envio 
			                6 - WebService (Marcos)
                            
               25/10/2017 - Enviar o cdagectl no arquivo ao invés de mandar a cooperativa 
                            mais o PA (Lucas Ranghetti #767689)
............................................................................. */
                                      
{ includes/var_batch.i "NEW" } 
{ sistema/generico/includes/var_oracle.i }

DEF VAR b1wgen0011   AS HANDLE                                       NO-UNDO.
                                                                   
DEF VAR aux_nmarqdat AS CHAR     FORMAT "x(20)"                      NO-UNDO.
DEF VAR aux_nmarqped AS CHAR     FORMAT "x(20)"                      NO-UNDO.
DEF VAR aux_dtmvtolt AS CHAR                                         NO-UNDO.
DEF VAR aux_dtmvtopr AS CHAR                                         NO-UNDO.
DEF VAR aux_dtproxim AS DATE                                         NO-UNDO.

DEF VAR aux_vltarifa AS DEC                                          NO-UNDO.
DEF VAR aux_dtproces AS DATE                                         NO-UNDO.
DEF VAR aux_nmempcov AS CHAR     FORMAT "x(20)"                      NO-UNDO.
DEF VAR aux_nrconven AS CHAR     FORMAT "x(20)"                      NO-UNDO.
DEF VAR aux_nrseqarq AS INT      FORMAT "999999"                     NO-UNDO.
DEF VAR aux_flgfirst AS LOG                                          NO-UNDO.
DEF VAR aux_nrseqdig AS INT                                          NO-UNDO.
                                                                    
DEF VAR tot_vlfatura AS DEC                                          NO-UNDO.
DEF VAR tot_vltarifa AS DEC                                          NO-UNDO.
DEF VAR tot_vlapagar AS DEC                                          NO-UNDO.
DEF VAR aux_nrsequen AS CHAR                                         NO-UNDO.
DEF VAR aux_nroentries AS INT                                        NO-UNDO.
DEF VAR aux_dsdemail AS CHAR                                         NO-UNDO.
DEF VAR aux_nmdbanco AS CHAR                                         NO-UNDO.
DEF VAR aux_nrdbanco AS INT   FORMAT "999"                           NO-UNDO.

DEF var aux_cdcoppac AS CHAR  FORMAT "x(04)"                         NO-UNDO.
DEF VAR aux_dtanteri AS DATE                                         NO-UNDO.
DEF VAR aux_contador AS INT                                          NO-UNDO.
DEF VAR aux_dslinreg LIKE gncvuni.dsmovtos                           NO-UNDO.
DEF VAR aux_dsattach AS CHAR                                         NO-UNDO.
DEF VAR aux_qtdcoope AS INT                                          NO-UNDO.
DEF VAR aux_nmdespar AS CHAR                                         NO-UNDO.

DEF VAR aux_tpfatura  AS CHAR      FORMAT "x(1)"                     NO-UNDO.
DEF VAR aux_nrautdoc  AS CHAR      FORMAT "x(14)"                    NO-UNDO.

DEF BUFFER b-gnconve FOR gnconve.
DEF BUFFER b-crapcop FOR crapcop.
DEF BUFFER crabcop FOR crapcop.

DEF STREAM str_1.  


ASSIGN glb_cdprogra = "crps619"
       aux_nmdespar = "/usr/coop/cecred/salvar/"
       glb_cdcooper = 3.

FIND b-crapcop WHERE b-crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF  NOT AVAIL b-crapcop   THEN
    DO:
        ASSIGN glb_cdcritic = 057.
        RUN fontes/critic.p.
        
        UNIX SILENT VALUE("echo " + STRING(TODAY) + " - "               + 
                          STRING(TIME,"HH:MM:SS") + " - "               +
                          glb_cdprogra + "' --> '" + glb_dscritic + " " + 
                          " - Cooperativa: " + STRING(b-crapcop.nmrescop)    +
                          " " + " >> /usr/coop/cecred/log/crps619.log").
        QUIT.
    END.


/* Nao rodar em Finais de semana e Feriados */
IF  CAN-DO("1,7",STRING(WEEKDAY(TODAY)))   OR
    CAN-FIND(crapfer WHERE crapfer.cdcooper = b-crapcop.cdcooper AND
                           crapfer.dtferiad = TODAY) THEN
    DO:
        QUIT.
    END.


FIND crapdat WHERE crapdat.cdcooper = glb_cdcooper  NO-LOCK NO-ERROR.
    
IF  NOT AVAIL crapdat THEN
    DO:
        glb_cdcritic = 1.
        RUN fontes/critic.p.
        UNIX SILENT VALUE("echo " + STRING(TODAY) + " - "               + 
                          STRING(TIME,"HH:MM:SS") + " - "               +
                          glb_cdprogra + "' --> '" + glb_dscritic +
                          " - Cooperativa: " + STRING(glb_cdcooper)    +
                          " " + " >> /usr/coop/cecred/log/crps619.log").
        QUIT.
    END.

ASSIGN  glb_dtmvtolt = crapdat.dtmvtolt
        glb_dtmvtopr = crapdat.dtmvtopr.

/*** Se nao concluiu o processo roda utilizando TODAY ***/
IF  crapdat.inproces > 2 THEN
    DO:
        ASSIGN glb_dtmvtolt = TODAY 
               glb_dtmvtopr = TODAY + 1.  
               
        RUN verifica_dia_util (INPUT-OUTPUT glb_dtmvtopr).
    END.  

FOR EACH gncvcop NO-LOCK,

    FIRST gnconve WHERE gnconve.cdconven = gncvcop.cdconven AND
                        gnconve.flgativo = YES              AND
                        gnconve.cdhiscxa > 0                AND
                        gnconve.flgenvpa = TRUE
                        NO-LOCK, /* Somente convenios arrec.caixa */

    FIRST crapcop WHERE crapcop.cdcooper = gnconve.cdcooper
                          NO-LOCK BREAK BY gncvcop.cdconven 
                                        BY gncvcop.cdcooper:

    /* D+1 */
    IF  gnconve.tprepass = 1 THEN
        aux_dtproxim = glb_dtmvtopr.
    ELSE /* D+2 */
        aux_dtproxim = glb_dtmvtopr + 1.

    RUN verifica_dia_util (INPUT-OUTPUT aux_dtproxim). 

    ASSIGN aux_dtmvtolt = STRING(YEAR(glb_dtmvtolt),"9999") +
                          STRING(MONTH(glb_dtmvtolt),"99")  +
                          STRING(DAY(glb_dtmvtolt),"99")
           aux_dtmvtopr = STRING(YEAR(aux_dtproxim),"9999") +
                          STRING(MONTH(aux_dtproxim),"99")  +
                          STRING(DAY(aux_dtproxim),"99").
           
    
    ASSIGN  aux_dtanteri = glb_dtmvtolt - 5
            glb_cdcritic = 0.

    IF FIRST-OF(gncvcop.cdconven) THEN
       ASSIGN aux_flgfirst = TRUE
              aux_nrseqdig = 0
              tot_vlfatura = 0 
              tot_vltarifa = 0 
              tot_vlapagar = 0.

    ASSIGN aux_dtproces = glb_dtmvtolt.
                   
    FIND FIRST craplft WHERE craplft.cdcooper  = gncvcop.cdcooper AND
                             craplft.dtvencto >= aux_dtanteri     AND
                             craplft.dtvencto <= glb_dtmvtolt     AND
                             craplft.insitfat  = 1                AND
                             craplft.cdhistor  = gnconve.cdhiscxa AND
                             craplft.flgenvpa  = FALSE
                             NO-LOCK NO-ERROR.
         
    IF AVAIL craplft THEN
       ASSIGN aux_dtproces = craplft.dtvencto.
    
    RUN efetua_geracao_arquivos.

    IF LAST-OF(gncvcop.cdconven) THEN
       DO:
          IF NOT aux_flgfirst THEN
             DO:
                ASSIGN tot_vlapagar = tot_vlfatura - tot_vltarifa.
          
                PUT STREAM str_1
                    "Z" (aux_nrseqdig + 2) FORMAT "999999"
                        (tot_vlfatura * 100)   FORMAT "99999999999999999"
                        "                                        "
                        "                                        "
                        "                                              " SKIP.
          
                OUTPUT STREAM str_1 CLOSE.
                
                RUN transmite_arquivo.
                
                RUN atualiza_controle.
                 
             END.  /* Fim do flgfirst */
          ELSE
             DO:
                 RUN nomeia_arquivos.
          
                 IF  glb_cdcritic <> 0 THEN
                     NEXT.

                 OUTPUT STREAM str_1 TO VALUE(aux_nmarqped). 
                                        
                 PUT STREAM str_1
                     "A2"   aux_nrconven FORMAT "99999999"
                     "            "
                     aux_nmempcov  FORMAT "x(20)" 
                     aux_nrdbanco  FORMAT "999" 
                     aux_nmdbanco  FORMAT "x(20)"
                     aux_dtmvtolt  FORMAT "x(08)" 
                     aux_nrseqarq  FORMAT "999999"
                     "03CODIGO DE BARRAS " "                              "
                     "                      " SKIP.
          
          
                 PUT STREAM str_1
                 "Z" (aux_nrseqdig + 2) FORMAT "999999"
                     (tot_vlfatura * 100)   FORMAT "99999999999999999"
                     "                                        "
                     "                                        "
                     "                                              " SKIP.
          
                 OUTPUT STREAM str_1 CLOSE.
          
                 RUN transmite_arquivo.
                 
                 RUN atualiza_controle.
          
             END.
          
          UNIX SILENT VALUE("echo " + STRING(TODAY) + " - "      + 
                            STRING(TIME,"HH:MM:SS") + " - "      +
                            "Gerado arquivo do convenio "        + 
                            STRING(gnconve.cdconven) + " - "     +
                            gnconve.nmempres + " de sequencial " + 
                            STRING(aux_nrseqarq)                 + 
                            " >> /usr/coop/cecred/log/crps619.log").
       END.
END.

QUIT.

/*--- PROCEDURES INTERNAS ---*/

PROCEDURE efetua_geracao_arquivos.

  FOR EACH craplft WHERE craplft.cdcooper  = gncvcop.cdcooper AND
                         craplft.dtvencto >= aux_dtproces     AND
                         craplft.dtvencto <= glb_dtmvtolt     AND
                         craplft.insitfat  = 1                AND
                         craplft.cdhistor  = gnconve.cdhiscxa AND
                         craplft.flgenvpa  = FALSE
                         EXCLUSIVE-LOCK BY craplft.cdagenci
                                         BY craplft.cdbccxlt
                                          BY craplft.nrdolote:
  
      IF  craplft.cdagenci = 90 THEN     /** Internet **/
          ASSIGN aux_tpfatura = "3"      
                 aux_vltarifa = gnconve.vltrfnet.
      ELSE
         IF  craplft.cdagenci = 91 THEN     /** TAA **/
             ASSIGN aux_tpfatura = "2"     
                    aux_vltarifa = gnconve.vltrftaa.
         ELSE
             ASSIGN aux_tpfatura = "1"     /** Caixa **/
                    aux_vltarifa = gnconve.vltrfcxa. 
            
  
      IF aux_flgfirst THEN
         DO: 
            RUN nomeia_arquivos.
            IF  glb_cdcritic <> 0 THEN
                NEXT.

            OUTPUT STREAM str_1 TO VALUE(aux_nmarqped). 
                                   
            PUT STREAM str_1
                "A2"   aux_nrconven FORMAT "99999999"
                "            "
                aux_nmempcov  FORMAT "x(20)" 
                aux_nrdbanco  FORMAT "999" 
                aux_nmdbanco  FORMAT "x(20)"
                aux_dtmvtolt  FORMAT "x(08)" 
                aux_nrseqarq  FORMAT "999999"
                "03CODIGO DE BARRAS " "                              "
                "                      " SKIP.
  
            aux_flgfirst = FALSE.
  
         END.
  
       ASSIGN aux_nrseqdig = aux_nrseqdig + 1
              tot_vlfatura = tot_vlfatura + craplft.vllanmto
              tot_vltarifa = tot_vltarifa + aux_vltarifa.
       
       
       /* Buscar a agencia do pagamento */
       FIND FIRST crabcop WHERE crabcop.cdcooper = gncvcop.cdcooper
                          NO-LOCK NO-ERROR.       
       
       ASSIGN aux_cdcoppac = STRING(crabcop.cdagectl, "99999").
              
       ASSIGN aux_nrautdoc = STRING(craplft.cdcooper,"99")          + 
                             STRING(craplft.cdagenci,"999")         +
                             SUBSTR(STRING(craplft.nrdolote),3,3)   +
                             STRING(craplft.nrautdoc,"999999999").

       ASSIGN aux_dslinreg = "G" + aux_cdcoppac + FILL(" ", 15)            + 
                             STRING(aux_dtmvtolt, "99999999")              +
                             STRING(aux_dtmvtopr, "99999999")              +
                             STRING(craplft.cdbarras, "x(44)")             + 
                             STRING(craplft.vllanmto * 100,"999999999999") +
                             STRING(aux_vltarifa * 100, "9999999")         +
                             STRING(aux_nrseqdig, "99999999")              + 
                             STRING(aux_cdcoppac, "99999999")              + 
                             aux_tpfatura  +  FILL(" ",6)                  +
                             aux_nrautdoc                                  + 
                             "1"           +  FILL(" ",9). 

       
       PUT STREAM str_1 aux_dslinreg FORMAT "x(150)" SKIP.
  
       ASSIGN craplft.flgenvpa = TRUE.

  END.  /* For each craplft */
  

END PROCEDURE.


PROCEDURE obtem_atualiza_sequencia:

  DO TRANSACTION:

     DO WHILE TRUE:
        
        FIND b-gnconve WHERE RECID(b-gnconve) = RECID(gnconve)
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF NOT AVAIL b-gnconve THEN
           IF LOCKED b-gnconve THEN
              DO:
                  PAUSE 1 NO-MESSAGE.
                  NEXT.

              END.
           ELSE
              DO: 
                  glb_cdcritic = 474.
                  RUN fontes/critic.p.
                  UNIX SILENT VALUE("echo " + STRING(TODAY) + " - "     + 
                                 STRING(TIME,"HH:MM:SS") + " - "        +
                                 glb_cdprogra + "' --> '"               +
                                 glb_dscritic + " - Convenio: "   + 
                                 STRING(gncvcop.cdconven)               +
                                 " " + " >> /usr/coop/cecred/log/crps619.log").
                  UNDO, RETURN.
              END.
        LEAVE.
     
     END. /* do while true */    
       
     ASSIGN aux_nrseqarq = b-gnconve.nrseqpar.
     
     CREATE gncontr.

     ASSIGN gncontr.cdcooper = glb_cdcooper  
            gncontr.tpdcontr = 5            /*** Arquivo Parcial ***/    
            gncontr.cdconven = gnconve.cdconven 
            gncontr.dtmvtolt = glb_dtmvtolt 
            gncontr.nrsequen = aux_nrseqarq
            b-gnconve.nrseqpar = aux_nrseqarq + 1.
     VALIDATE gncontr.
            
     RELEASE b-gnconve.
     
  END.

END PROCEDURE. /* FIM da procedure obtem_atualiza_sequencia */        

PROCEDURE transmite_arquivo:

  ASSIGN aux_contador = 0.

  IF  gnconve.tpdenvio = 1  OR
      gnconve.tpdenvio = 2  OR      /* E-Sales */
      gnconve.tpdenvio = 4  THEN    /* Internet */ 
      DO:
         RUN sistema/generico/procedures/b1wgen0011.p 
                                PERSISTENT SET b1wgen0011.
         
         RUN converte_arquivo IN b1wgen0011 (INPUT glb_cdcooper,
                                             INPUT aux_nmarqped,
                                             INPUT aux_nmarqdat).
         
         IF  gnconve.tpdenvio = 2 THEN /* E-Sales */
             DO:
                ASSIGN glb_cdcritic = 696.                  
                /* copiar arquivo convertido para o connect/esales */
                UNIX SILENT VALUE("cp " + "converte/" + aux_nmarqdat + " /usr/connect/esales/envia/").                  
             END.         
         ELSE 
             ASSIGN glb_cdcritic = 657. /* Intranet - tpdenvio = 1 */

         aux_dsattach = aux_nmarqdat.
         
      END.        

  IF gnconve.tpdenvio = 3 THEN /* Nexxera */
     DO:
        ASSIGN glb_cdcritic = 748.
               
        UNIX SILENT VALUE("cp " + aux_nmarqped + " /usr/nexxera/envia/").

     END.     

  IF gnconve.tpdenvio <> 2 AND          /** Interchange **/
     gnconve.tpdenvio <> 5 THEN         /** Accesstage **/
     DO:                                     
        UNIX SILENT VALUE("mv " + aux_nmarqped + " " +
                           aux_nmdespar + aux_nmarqdat + " 2> /dev/null").

     END.   
  ELSE
     UNIX SILENT VALUE("cp " + aux_nmarqped + " /usr/coop/cecred/salvar"). 
                 
  IF  gnconve.tpdenvio = 6 THEN  /* WebServices */
     DO:
             
         ASSIGN glb_cdcritic = 982.
		 
		 { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
         
         /* Efetuar a chamada a rotina Oracle  */
         RUN STORED-PROCEDURE pc_armazena_arquivo_conven
             aux_handproc = PROC-HANDLE NO-ERROR (INPUT gnconve.cdconven,
                                                  INPUT glb_dtmvtolt,
                                                  INPUT 'G', /* Arrecadacao caixa */
												  INPUT 0, /* Nao retornado ainda */
                                                  INPUT '/usr/coop/cecred/salvar', 
                                                  INPUT aux_nmarqdat,
                                                  OUTPUT 0, 
                                                  OUTPUT "").
         
         /* Fechar o procedimento para buscarmos o resultado */ 
         CLOSE STORED-PROC pc_armazena_arquivo_conven
                 aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

         { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
         
         /* Busca possíveis erros */
         IF pc_armazena_arquivo_conven.pr_cdretorn <> 202 THEN
            DO:
               UNIX SILENT VALUE("echo " + STRING(TODAY) + " - "     + 
                                 STRING(TIME,"HH:MM:SS") + " - "        +
                                 glb_cdprogra + "' --> '"               +
                                 pc_armazena_arquivo_conven.pr_dsmsgret + " - Convenio: "   + 
                                 STRING(gncvcop.cdconven)               +
                                 " " + " >> /usr/coop/cecred/log/crps619.log").
            END.
     END.
  
  RUN fontes/critic.p.

  IF gnconve.tpdenvio = 1 OR gnconve.tpdenvio = 4 THEN  
     DO:
         ASSIGN aux_nroentries = NUM-ENTRIES(gnconve.dsendcxa).
          
         ASSIGN aux_contador   = 1.

         DO WHILE aux_contador LE aux_nroentries:

            ASSIGN aux_dsdemail = TRIM(ENTRY(aux_contador,   
                                             gnconve.dsendcxa)).
         
            IF TRIM(aux_dsdemail) = ""   THEN
               DO:
                   aux_contador = aux_contador + 1.
                   NEXT.

               END.
                                            
            IF gnconve.tpdenvio = 1 THEN
               RUN enviar_email IN b1wgen0011 
                               (INPUT glb_cdcooper,
                                INPUT glb_cdprogra,
                                INPUT aux_dsdemail,
                                INPUT "ARQUIVO DE ARRECADACAO DA " +
                                      b-crapcop.nmrescop + 
                                      " REFERENTE A DATA " +
                                      STRING(glb_dtmvtolt,"99/99/9999"),
                                INPUT aux_dsattach,
                                INPUT FALSE).
            ELSE
               IF gnconve.tpdenvio = 4 THEN
                  RUN enviar_email IN b1wgen0011 
                                  (INPUT glb_cdcooper,
                                   INPUT glb_cdprogra,
                                   INPUT aux_dsdemail,
                                   INPUT "ARQUIVO DE ARRECADACAO DA " +
                                         b-crapcop.nmrescop + 
                                         " REFERENTE A DATA " +
                                         STRING(glb_dtmvtolt,"99/99/9999"),
                                   INPUT aux_dsattach,
                                   INPUT TRUE).
                                     
            ASSIGN aux_contador = aux_contador + 1.

         END. 
             
         DELETE PROCEDURE b1wgen0011.    

     END.
                
 
END. /* transmite_arquivo */

PROCEDURE atualiza_controle:
          
 
  /*----Atualizar Arquivo de Controle ---*/
  ASSIGN gncontr.dtcredit = aux_dtproxim
         gncontr.nmarquiv = aux_nmarqdat
         gncontr.qtdoctos = aux_nrseqdig
         gncontr.vldoctos = tot_vlfatura
         gncontr.vltarifa = tot_vltarifa
         gncontr.vlapagar = tot_vlapagar.
             
  RELEASE gncontr.


END PROCEDURE. /* FIM da procedure atualiza_controle */


PROCEDURE nomeia_arquivos:

  RUN obtem_atualiza_sequencia. 

  IF  glb_cdcritic <> 0 THEN
      RETURN. 

  ASSIGN aux_nmdbanco = crapcop.nmrescop
         aux_nrdbanco = gnconve.cddbanco
         aux_nrconven = gnconve.nrcnvfbr
         aux_nmempcov = gnconve.nmempres
         aux_nrsequen = STRING(aux_nrseqarq,"999999").
     

  ASSIGN aux_nmarqdat = TRIM(SUBSTR(gnconve.nmarqpar,1,4))    +
                        STRING(MONTH(glb_dtmvtolt),"99")      +
                        STRING(DAY(glb_dtmvtolt),"99") +  "." +
                        SUBSTR(aux_nrsequen,4,3) .
  
  
  IF SUBSTR(gnconve.nmarqpar,5,2)  = "MM"  AND
     SUBSTR(gnconve.nmarqpar,7,2)  = "DD"  AND
     SUBSTR(gnconve.nmarqpar,10,3) = "TXT" THEN 
     ASSIGN  aux_nmarqdat = TRIM(SUBSTR(gnconve.nmarqpar,1,4))   +  
                            STRING(MONTH(glb_dtmvtolt),"99")     +
                            STRING(DAY(glb_dtmvtolt),"99") + "." +
                           "txt".
  
  IF SUBSTR(gnconve.nmarqpar,5,2)  = "DD"  AND
     SUBSTR(gnconve.nmarqpar,7,2)  = "MM"  AND
     SUBSTR(gnconve.nmarqpar,10,3) = "RET" THEN 
     ASSIGN  aux_nmarqdat = TRIM(SUBSTR(gnconve.nmarqpar,1,4))     + 
                            STRING(DAY(glb_dtmvtolt),"99")         +
                            STRING(MONTH(glb_dtmvtolt),"99") + "." +
                            "ret".
 
  IF SUBSTR(gnconve.nmarqpar,5,2)  = "CP"  AND   /* Cooperativa */
     SUBSTR(gnconve.nmarqpar,7,2)  = "MM"  AND
     SUBSTR(gnconve.nmarqpar,9,2)  = "DD"  AND
     SUBSTR(gnconve.nmarqpar,12,3) = "SEQ" THEN 
     ASSIGN  aux_nmarqdat = TRIM(SUBSTR(gnconve.nmarqpar,1,4)) +
                            STRING(gnconve.cdcooper,"99")      +
                            STRING(MONTH(glb_dtmvtolt),"99")   +
                            STRING(DAY(glb_dtmvtolt),"99")     +
                            "." +  SUBSTR(aux_nrsequen,4,3).
                                  
  IF SUBSTR(gnconve.nmarqpar,4,1)  = "C"    AND
     SUBSTR(gnconve.nmarqpar,5,4)  = "SEQU" AND
     SUBSTR(gnconve.nmarqpar,10,3) = "RET"  THEN 
     ASSIGN  aux_nmarqdat = TRIM(SUBSTR(gnconve.nmarqpar,1,3)) +
                            STRING(gnconve.cdcooper,"9")       +
                            SUBSTR(aux_nrsequen,3,4) + "."     +
                            "ret".
       
  ASSIGN  aux_nmarqped = "/usr/coop/cecred/arq/" + aux_nmarqdat.
   
END PROCEDURE. /* FIM da procedure nomeia_arquivos */


PROCEDURE verifica_dia_util:
    
    DEF INPUT-OUTPUT PARAM par_dtmvtolt AS DATE.
    
    DO WHILE TRUE:          /*  Procura pela proxima data */
        
       IF NOT CAN-DO("1,7",STRING(WEEKDAY(par_dtmvtolt)))              AND
          NOT CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper   AND
                                     crapfer.dtferiad = par_dtmvtolt)  THEN
          LEAVE.
            
          par_dtmvtolt = par_dtmvtolt + 1.
    END.  /*  Fim do DO WHILE TRUE  */

END.

/* ......................................................................... */


