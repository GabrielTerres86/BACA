/*.............................................................................
    Programa: b1wgen0146.p
    Autor   : David Kruger
    Data    : Janeiro/2013                     Ultima Atualizacao: 21/01/2015
           
    Dados referentes ao programa:
                
    Objetivo  : BO de uso para tela NOTJUS.
                    
    Alteracoes: 19/11/2013 - Ajustes para homologação (Adriano)
    
                28/04/2014 - Ajuste para buscar a sequence do banco Oracle
                             para a tabela crapneg. (James)
                             
                21/01/2015 - Conversão da fn_sequence para procedure para não
                             gerar cursores abertos no Oracle. (Dionathan)
.............................................................................*/

{ sistema/generico/includes/b1wgen0146tt.i } 
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/var_oracle.i }


/** RETORNA TEMP-TABLE COM DADOS DOS ESTOUROS DA CONTA INFORMADA **/
PROCEDURE busca_estouro:

  DEF INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
  DEF INPUT PARAM par_cdagenci AS INTE                            NO-UNDO.
  DEF INPUT PARAM par_nrdcaixa AS INTE                            NO-UNDO.
  DEF INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
  DEF INPUT PARAM par_nmdatela AS CHAR                            NO-UNDO.
  DEF INPUT PARAM par_idorigem AS INTE                            NO-UNDO.
  DEF INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
  DEF INPUT PARAM par_cddopcao AS CHAR                            NO-UNDO. 
  DEF INPUT PARAM par_nrdconta AS INT                             NO-UNDO.

  DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
  DEF OUTPUT PARAM TABLE FOR tt-estouro.
  DEF OUTPUT PARAM TABLE FOR tt-erro.

  DEF VAR aux_dsobserv AS CHAR                                    NO-UNDO.
  DEF VAR aux_dshisest AS CHAR                                    NO-UNDO.   
  DEF VAR aux_cdcritic AS INTE                                    NO-UNDO.
  DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.

  EMPTY TEMP-TABLE tt-estouro.
  EMPTY TEMP-TABLE tt-erro.

  ASSIGN aux_cdcritic = 0
         aux_dscritic = "".

  
  FOR EACH crapneg WHERE crapneg.cdcooper = par_cdcooper                 AND
                         crapneg.nrdconta = par_nrdconta                 AND
                       ((crapneg.cdhisest = 5 OR  crapneg.cdhisest = 6)  OR
                        (crapneg.cdhisest = 1 AND crapneg.cdobserv = 11) OR
                        (crapneg.cdhisest = 1 AND crapneg.cdobserv = 21))     
                         NO-LOCK:

      ASSIGN aux_dsobserv = ""
             aux_dshisest = "".
             
      IF crapneg.cdhisest = 5 AND   
         crapneg.cdobserv > 0 THEN
         DO:
            FIND crapali WHERE crapali.cdalinea = crapneg.cdobserv 
                               NO-LOCK NO-ERROR.

            IF NOT AVAIL crapali   THEN
               ASSIGN aux_dsobserv = STRING(crapneg.cdobserv,"999").
            ELSE
               ASSIGN aux_dsobserv = crapali.dsalinea.

         END.
      ELSE
         IF crapneg.cdhisest = 1  AND 
            crapneg.dtfimest <> ? THEN
            ASSIGN aux_dsobserv = "Justificado".
         ELSE
            ASSIGN aux_dsobserv = "".

      ASSIGN aux_dshisest = IF crapneg.cdhisest = 5 THEN
                               "Estouro"
                            ELSE
                               IF crapneg.cdhisest = 6 THEN
                                  "Notificacao"
                            ELSE
                               "Devolucao".

      CREATE tt-estouro.

      ASSIGN tt-estouro.nrseqdig = crapneg.nrseqdig
             tt-estouro.dtiniest = crapneg.dtiniest
             tt-estouro.qtdiaest = crapneg.qtdiaest WHEN crapneg.qtdiaest > 0
             tt-estouro.vlestour = crapneg.vlestour WHEN crapneg.vlestour > 0
             tt-estouro.dshisest = aux_dshisest
             tt-estouro.dsobserv = aux_dsobserv.


   END.  /*  Fim do FOR EACH  --  Leitura dos talonarios  */

   IF NOT TEMP-TABLE tt-estouro:HAS-RECORDS THEN
      DO:                         
         ASSIGN aux_cdcritic = 413
                par_nmdcampo = "nrdconta".

         RUN gera_erro ( INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1,            /** Sequencia **/
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic ).

         RETURN "NOK".
                                    
      END.                          

   RETURN "OK".

END PROCEDURE.

/** EXCLUI REGISTRO DA CRAPNEG PELO NUMERO DE SEQUENCIA **/
PROCEDURE exclui_registro:

  DEF INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
  DEF INPUT PARAM par_cdagenci AS INTE                            NO-UNDO.
  DEF INPUT PARAM par_nrdcaixa AS INTE                            NO-UNDO.
  DEF INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
  DEF INPUT PARAM par_nmdatela AS CHAR                            NO-UNDO.
  DEF INPUT PARAM par_idorigem AS INTE                            NO-UNDO.
  DEF INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
  DEF INPUT PARAM par_cddopcao AS CHAR                            NO-UNDO.
  DEF INPUT PARAM par_nrdconta AS INTE                            NO-UNDO.
  DEF INPUT PARAM par_nrseqdig AS INTE                            NO-UNDO.

  DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
  DEF OUTPUT PARAM TABLE FOR tt-erro.

  DEF VAR aux_cdcritic AS INTE                                    NO-UNDO.
  DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.
  DEF VAR aux_contador AS INTE                                    NO-UNDO.

  EMPTY TEMP-TABLE tt-erro.

  ASSIGN aux_cdcritic = 0
         aux_dscritic = ""
         aux_contador = 0.
  
  IF par_nrseqdig = 0 THEN
     DO:
        ASSIGN aux_cdcritic = 166
               par_nmdcampo = "nrdconta".

        RUN gera_erro ( INPUT par_cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_nrdcaixa,
                        INPUT 1,            /** Sequencia **/
                        INPUT aux_cdcritic,
                        INPUT-OUTPUT aux_dscritic ).

        RETURN "NOK".
          
     END.   

  DO WHILE TRUE TRANSACTION ON ENDKEY UNDO, LEAVE
                            ON ERROR  UNDO, LEAVE
                            ON STOP   UNDO, LEAVE
                            ON QUIT   UNDO, LEAVE:

     Contador:
     DO aux_contador = 1 TO 10:
     
        FIND crapneg WHERE crapneg.cdcooper = par_cdcooper AND
                           crapneg.nrdconta = par_nrdconta AND
                           crapneg.nrseqdig = par_nrseqdig
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
      
        IF NOT AVAILABLE crapneg   THEN
           IF LOCKED crapneg   THEN
              DO:
                 IF aux_contador = 10 THEN
                    DO:
                       ASSIGN aux_cdcritic = 77.
                       LEAVE Contador.

                    END.

                 ASSIGN aux_contador = aux_contador + 1.
                 NEXT Contador.

              END.
           ELSE
               DO:
                  ASSIGN aux_cdcritic = 419.
                  LEAVE Contador.

               END.

     END. /* FIM DO CONTADOR */

     IF aux_cdcritic <> 0 THEN
        LEAVE.

     IF NOT CAN-DO("1,5,6",STRING(crapneg.cdhisest)) THEN
        DO:
           ASSIGN aux_cdcritic = 421.
           LEAVE.

        END.

     IF crapneg.cdhisest = 5 THEN
        DO:
           IF crapneg.cdobserv = 0 THEN
              DO:
                 ASSIGN aux_cdcritic = 423.
                 LEAVE.

              END.
           ELSE
              DO:
                 ASSIGN crapneg.cdobserv = 0
                        crapneg.cdoperad = par_cdoperad.
                 LEAVE.

              END.

           LEAVE.

        END.
     ELSE
        IF crapneg.cdhisest = 6 THEN
           DELETE crapneg.
        ELSE
           IF crapneg.cdhisest = 1 THEN
              ASSIGN crapneg.dtfimest = ?
                     crapneg.cdoperad = par_cdoperad.
                  
     LEAVE.

  END.  /*  Fim do DO WHILE TRUE e da transacao  */

  RELEASE crapneg.

  IF aux_cdcritic <> 0  OR 
     aux_dscritic <> "" THEN
     DO:
         ASSIGN par_nmdcampo = "nrdconta".

         RUN gera_erro ( INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1,            /** Sequencia **/
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic ).

         RETURN "NOK".

     END.

  RETURN "OK".

END PROCEDURE.

/** JUSTIFICA ESTOURO NA TELA NOTJUS **/
PROCEDURE justifica_estouro:

  DEF INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
  DEF INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
  DEF INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
  DEF INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
  DEF INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
  DEF INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
  DEF INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
  DEF INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
  DEF INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
  DEF INPUT PARAM par_nrseqdig AS INTE                           NO-UNDO.

  DEF OUTPUT PARAM par_nmdcampo AS CHAR                          NO-UNDO.
  DEF OUTPUT PARAM TABLE FOR tt-erro.

  DEF VAR aux_cdcritic AS INTE                                   NO-UNDO.
  DEF VAR aux_dscritic AS CHAR                                   NO-UNDO.
  DEF VAR aux_contador AS INTE                                   NO-UNDO.

  EMPTY TEMP-TABLE tt-erro.

  ASSIGN aux_cdcritic = 0
         aux_dscritic = ""
         aux_contador = 0.

  IF par_nrseqdig = 0 THEN
     DO:
        ASSIGN aux_cdcritic = 166
               par_nmdcampo = "nrdconta".

        RUN gera_erro ( INPUT par_cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_nrdcaixa,
                        INPUT 1,            /** Sequencia **/
                        INPUT aux_cdcritic,
                        INPUT-OUTPUT aux_dscritic ).

        RETURN "NOK".

     END.

  DO WHILE TRUE TRANSACTION ON ENDKEY UNDO, LEAVE
                            ON ERROR  UNDO, LEAVE
                            ON STOP   UNDO, LEAVE
                            ON QUIT   UNDO, LEAVE:
     
     Contador:
     DO aux_contador = 1 TO 10:
     
        FIND crapneg WHERE crapneg.cdcooper = par_cdcooper AND
                           crapneg.nrdconta = par_nrdconta AND
                           crapneg.nrseqdig = par_nrseqdig
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
      
        IF NOT AVAILABLE crapneg THEN
           IF LOCKED crapneg   THEN
              DO:
                 IF aux_contador = 10 THEN
                    DO:
                       ASSIGN aux_cdcritic = 77.
                       LEAVE Contador.

                    END.

                 ASSIGN aux_contador = aux_contador + 1.
                 NEXT Contador.

              END.
           ELSE
              DO:
                  ASSIGN aux_cdcritic = 419.
                  LEAVE Contador.

              END.

     END. /* FIM DO CONTADOR */

     IF aux_cdcritic <> 0 THEN
        LEAVE.

     IF crapneg.cdhisest <> 5 AND
        crapneg.cdhisest <> 1 THEN
        DO: 
           ASSIGN aux_cdcritic = 421.
           LEAVE.

        END.

     IF (crapneg.cdhisest = 5    AND 
         crapneg.cdobserv > 0)   OR
        (crapneg.cdhisest = 1    AND
         crapneg.cdobserv <> 11  AND
         crapneg.cdobserv <> 21) THEN
        DO:
            ASSIGN aux_cdcritic = 422.
            LEAVE.

        END.
     ELSE
        DO:
           IF crapneg.cdhisest = 5   THEN
              ASSIGN crapneg.cdobserv = 100.
           ELSE
              ASSIGN crapneg.dtfimest = par_dtmvtolt.
                 
           ASSIGN crapneg.cdoperad = par_cdoperad.
                 
        END.

     LEAVE.

  END.  /*  Fim do DO WHILE TRUE e da transacao  */
  
  RELEASE crapneg.

  IF aux_cdcritic <> 0  OR 
     aux_dscritic <> "" THEN
     DO:
         ASSIGN par_nmdcampo = "nrdconta".

         RUN gera_erro ( INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1,            /** Sequencia **/
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic ).

         RETURN "NOK".

     END.

  RETURN "OK".

END PROCEDURE.

PROCEDURE cria_notificacao:

  DEF INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
  DEF INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
  DEF INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
  DEF INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
  DEF INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
  DEF INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
  DEF INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
  DEF INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
  DEF INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
  
  DEF OUTPUT PARAM par_nmdcampo AS CHAR                          NO-UNDO.
  DEF OUTPUT PARAM TABLE FOR tt-erro.

  DEF VAR aux_cdcritic AS INTE                                   NO-UNDO.
  DEF VAR aux_dscritic AS CHAR                                   NO-UNDO.
  DEF VAR aux_nrseqdig LIKE crapneg.nrseqdig                     NO-UNDO.
  
  EMPTY TEMP-TABLE tt-erro.

  ASSIGN aux_cdcritic = 0
         aux_dscritic = ""
         aux_nrseqdig = 0.

  DO WHILE TRUE TRANSACTION ON ENDKEY UNDO, LEAVE
                            ON ERROR  UNDO, LEAVE
                            ON STOP   UNDO, LEAVE
                            ON QUIT   UNDO, LEAVE:

    /* Busca a proxima sequencia do campo crapmat.nrseqcar */
	 RUN STORED-PROCEDURE pc_sequence_progress
	 aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPNEG"
										 ,INPUT "NRSEQDIG"
										 ,INPUT STRING(par_cdcooper) + ";" + STRING(par_nrdconta) 
										 ,INPUT "N"
										 ,"").
	
	 CLOSE STORED-PROC pc_sequence_progress
	 aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
			  
	 ASSIGN aux_nrseqdig = INTE(pc_sequence_progress.pr_sequence)
	       				   WHEN pc_sequence_progress.pr_sequence <> ?.
          
     CREATE crapneg.
     ASSIGN crapneg.nrdconta = par_nrdconta
            crapneg.nrseqdig = aux_nrseqdig
            crapneg.dtiniest = par_dtmvtolt
            crapneg.cdhisest = 6
            crapneg.cdobserv = 0
            crapneg.nrdctabb = 0
            crapneg.nrdocmto = 0
            crapneg.vlestour = 0
            crapneg.vllimcre = 0
            crapneg.qtdiaest = 0
            crapneg.cdtctant = 0
            crapneg.cdtctatu = 0
            crapneg.cdoperad = par_cdoperad
            crapneg.cdbanchq = 0
            crapneg.cdagechq = 0
            crapneg.nrctachq = 0
            crapneg.cdcooper = par_cdcooper.

     LEAVE.

  END.  /*  Fim da transacao  */

  RELEASE crapneg.

  IF aux_cdcritic <> 0  OR 
     aux_dscritic <> "" THEN
     DO:
         ASSIGN par_nmdcampo = "nrdconta".

         RUN gera_erro ( INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1,            /** Sequencia **/
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic ).

         RETURN "NOK".

     END.

  RETURN "OK".

END PROCEDURE.


/** PROCEDURE PARA RETORNAR O NOME DO ASSOCIADO **/
PROCEDURE busca_associado: 
    
  DEF INPUT PARAM par_cdcooper AS INTE                           NO-UNDO. 
  DEF INPUT PARAM par_cdagenci AS INTE                           NO-UNDO. 
  DEF INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO. 
  DEF INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO. 
  DEF INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO. 
  DEF INPUT PARAM par_idorigem AS INTE                           NO-UNDO. 
  DEF INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
  DEF INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
  DEF INPUT PARAM par_nrdconta AS INT                            NO-UNDO.

  DEF OUTPUT PARAM par_nmdcampo AS CHAR                          NO-UNDO.
  DEF OUTPUT PARAM par_nmprimtl AS CHAR                          NO-UNDO.
  DEF OUTPUT PARAM TABLE FOR tt-erro.

  DEF VAR aux_cdcritic AS INT                                    NO-UNDO.
  DEF VAR aux_dscritic AS CHAR                                   NO-UNDO.

  EMPTY TEMP-TABLE tt-erro.

  ASSIGN aux_cdcritic = 0
         aux_dscritic = "".

  IF par_nrdconta = 0 THEN
     DO:
        ASSIGN aux_dscritic = "Conta nao informada."
               par_nmdcampo = "nrdconta".

        RUN gera_erro ( INPUT par_cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_nrdcaixa,
                        INPUT 1,            /** Sequencia **/
                        INPUT aux_cdcritic,
                        INPUT-OUTPUT aux_dscritic ).

        RETURN "NOK".

     END.

  FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                     crapass.nrdconta = par_nrdconta
                     NO-LOCK NO-ERROR.
  
  IF AVAIL crapass THEN
     ASSIGN par_nmprimtl = crapass.nmprimtl.
  ELSE
     DO: 
        ASSIGN par_nmdcampo = "nrdconta".
               aux_cdcritic = 9.

        RUN gera_erro ( INPUT par_cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_nrdcaixa,
                        INPUT 1,            /** Sequencia **/
                        INPUT aux_cdcritic,
                        INPUT-OUTPUT aux_dscritic ).

        RETURN "NOK".
           
     END.

  RETURN "OK". 

END PROCEDURE.
