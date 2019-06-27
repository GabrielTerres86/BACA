/* ............................................................................

   Programa: sistema/generico/procedures/b1wgen0117.p
   Autor  : Adriano
   Data   : Setembro/2011                         Ultima alteracao: 18/05/2019

   Dados referentes ao programa:

   Objetivo  : BO referente a tela ALERTA.
   
   Alteracoes: 05/02/2013 - Ajustes referentes a tela ALERTA.
    
               12/12/2013 - Adicionado VALIDATE para CREATE. (Jorge)
               
               06/01/2014 - Critica de busca de crapage alterada de 15 para 962
                            (Carlos)
                            
               15/09/2014 - Chamado 152916 (Jonata-RKAM).
               
               20/08/2015 - Removido a validacao de conta igual a zero pois
                            existe a possibilidade do procurado de uma conta
                            PJ nao tenha conta na coopertativa. SD 319604 (Kelvin).  
                            
               18/05/2019 - Perca de aprovacao do pré-aprovado na conta (Christian - Envolti).
..............................................................................*/

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/b1wgen0117tt.i }
{ sistema/generico/includes/var_oracle.i }	

DEF VAR aux_nrregist AS INT                                        NO-UNDO.
DEF VAR aux_contador AS INT                                        NO-UNDO.
                                                                   
/***Cabecalho****/
DEF VAR rel_nmrescop AS CHAR                                       NO-UNDO.
DEF VAR rel_nmresemp AS CHAR  FORMAT "x(15)"                       NO-UNDO.
DEF VAR rel_nmrelato AS CHAR  FORMAT "x(40)"                       NO-UNDO.
DEF VAR rel_nrmodulo AS INTE  FORMAT     "9"                       NO-UNDO.
DEF VAR rel_nmempres AS CHAR  FORMAT "x(15)"                       NO-UNDO.
DEF VAR rel_nmdestin AS CHAR                                       NO-UNDO.
DEF VAR rel_nmmodulo AS CHAR  FORMAT "x(15)" EXTENT 5              
                              INIT ["","","","",""]                NO-UNDO.


DEF STREAM str_1.

PROCEDURE consultar_cad_restritivo:

   DEF INPUT PARAM par_cdcooper AS INT                     NO-UNDO.
   DEF INPUT PARAM par_cdagenci AS INT                     NO-UNDO.
   DEF INPUT PARAM par_nrdcaixa AS INT                     NO-UNDO. 
   DEF INPUT PARAM par_idorigem AS INT                     NO-UNDO.
   DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
   DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
   DEF INPUT PARAM par_cddopcao AS CHAR                    NO-UNDO. 
   DEF INPUT PARAM par_nrcpfcgc AS DEC                     NO-UNDO.
   DEF INPUT PARAM par_nmpessoa AS CHAR                    NO-UNDO.
   DEF INPUT PARAM par_nrregist AS INT                     NO-UNDO.
   DEF INPUT PARAM par_nriniseq AS INT                     NO-UNDO.
   DEF INPUT PARAM par_flgpagin AS LOG                     NO-UNDO.

   DEF OUTPUT PARAM par_qtregist AS INT                    NO-UNDO.
   DEF OUTPUT PARAM TABLE FOR tt-crapcrt.
   DEF OUTPUT PARAM TABLE FOR tt-erro.

   DEF VAR aux_nrregist AS INT                             NO-UNDO.
   DEF VAR aux_nmpessoa AS CHAR                            NO-UNDO.
   DEF VAR aux_stsnrcal AS LOG                             NO-UNDO.
   DEF VAR aux_inpessoa AS INT                             NO-UNDO.

   DEF VAR h-b1wgen9999 AS HANDLE                          NO-UNDO.

   EMPTY TEMP-TABLE tt-crapcrt.
   EMPTY TEMP-TABLE tt-erro.

   ASSIGN aux_nrregist = par_nrregist
          aux_nmpessoa = "*" + par_nmpessoa + "*"
          aux_stsnrcal = FALSE
          aux_inpessoa = 0.


   IF NOT VALID-HANDLE(h-b1wgen9999) THEN
      RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.

   IF par_cddopcao = "C" THEN
      DO:
         FOR EACH crapcrt 
             WHERE ((IF par_nrcpfcgc <> 0                        THEN 
                        TRUE                                    
                     ELSE                                       
                        FALSE)                                   AND
                    crapcrt.cdsitreg > 0                         AND
                    crapcrt.nrcpfcgc = par_nrcpfcgc)             OR
                   ((IF par_nmpessoa <> ""                       THEN
                        TRUE                                    
                     ELSE                                       
                        FALSE)                                   AND
                    crapcrt.cdsitreg > 0                         AND
                    CAPS(crapcrt.nmpessoa) MATCHES aux_nmpessoa)
                    NO-LOCK:

             ASSIGN par_qtregist = par_qtregist + 1.

             /* controles da paginaçao */
             IF  par_flgpagin                                   AND
                (par_qtregist < par_nriniseq                    OR
                 par_qtregist > (par_nriniseq + par_nrregist))  THEN
                 NEXT.
             
             IF  NOT par_flgpagin OR aux_nrregist > 0 THEN
                 DO:
                    CREATE tt-crapcrt.

                    RUN valida-cpf-cnpj IN h-b1wgen9999(INPUT crapcrt.nrcpfcgc,
                                                        OUTPUT aux_stsnrcal,
                                                        OUTPUT aux_inpessoa).
                    
                    ASSIGN tt-crapcrt.nrcpfcgc = (IF aux_inpessoa = 1 THEN 
                                                     STRING((STRING(
                                                     crapcrt.nrcpfcgc,
                                                     "99999999999")),
                                                     "xxx.xxx.xxx-xx")
                                                  ELSE
                                                    STRING((STRING(
                                                    crapcrt.nrcpfcgc,
                                                    "99999999999999")),
                                                    "xx.xxx.xxx/xxxx-xx"))
                           tt-crapcrt.nrregres = crapcrt.nrregres
                           tt-crapcrt.cdsitreg = crapcrt.cdsitreg
                           tt-crapcrt.nmpessoa = SUBSTR(crapcrt.nmpessoa,1,30)
                           tt-crapcrt.cdcopsol = crapcrt.cdcopsol
                           tt-crapcrt.nmpessol = SUBSTR(crapcrt.nmpessol,1,30)
                           tt-crapcrt.cdbccxlt = crapcrt.cdbccxlt
                           tt-crapcrt.dtinclus = crapcrt.dtinclus
                           tt-crapcrt.hrinclus = STRING(crapcrt.hrinclus,"HH:MM:SS")
                           tt-crapcrt.dsjusinc = crapcrt.dsjusinc
                           tt-crapcrt.cdcopinc = crapcrt.cdcopinc
                           tt-crapcrt.cdcopexc = crapcrt.cdcopexc
                           tt-crapcrt.dsjusexc = crapcrt.dsjusexc
                           tt-crapcrt.dtexclus = crapcrt.dtexclus
                           tt-crapcrt.hrexclus = STRING(crapcrt.hrexclus,"HH:MM:SS")
                           tt-crapcrt.tporigem = crapcrt.tporigem.
                           
                              
                   FIND crapope WHERE crapope.cdcooper = crapcrt.cdcopinc AND
                                      crapope.cdoperad = crapcrt.cdopeinc
                                      NO-LOCK NO-ERROR.
               
                   IF AVAIL crapope THEN
                      tt-crapcrt.nmopeinc = crapope.nmoperad.
                     
               
                   FIND crapope WHERE crapope.cdcooper = crapcrt.cdcopexc AND
                                      crapope.cdoperad = crapcrt.cdopeexc
                                      NO-LOCK NO-ERROR.
               
                   IF AVAIL crapope THEN
                      tt-crapcrt.nmopeexc = crapope.nmoperad.
               
               
                   FIND crapcop WHERE crapcop.cdcooper = crapcrt.cdcopsol 
                                      NO-LOCK NO-ERROR.
               
                   IF AVAIL crapcop THEN
                      ASSIGN tt-crapcrt.nmcopsol = crapcop.nmrescop.
               
                   FIND crapcop WHERE crapcop.cdcooper = crapcrt.cdcopinc
                                      NO-LOCK NO-ERROR.
               
                   IF AVAIL crapcop THEN
                      ASSIGN tt-crapcrt.nmcopinc = crapcop.nmrescop.
               
               
                   FIND crapcop WHERE crapcop.cdcooper = crapcrt.cdcopexc 
                                      NO-LOCK NO-ERROR.
               
                   IF AVAIL crapcop THEN
                      ASSIGN tt-crapcrt.nmcopexc = crapcop.nmrescop.

                   FIND crapban WHERE crapban.cdbccxlt = crapcrt.cdbccxlt AND
                                      crapban.cdbccxlt <> 0
                                      NO-LOCK NO-ERROR.

                   IF AVAIL crapban THEN
                      ASSIGN tt-crapcrt.nmextbcc = crapban.nmextbcc.

                 END.
               
             IF  par_flgpagin  THEN
                 ASSIGN aux_nrregist = aux_nrregist - 1.

         END.

      END.
   ELSE
      DO: 
         FOR EACH crapcrt 
             WHERE ((IF par_nrcpfcgc <> 0                       THEN 
                        TRUE                                    
                     ELSE                                       
                        FALSE)                                  AND
                    crapcrt.nrcpfcgc = par_nrcpfcgc             AND
                    crapcrt.cdsitreg = 1)                       OR
                   ((IF par_nmpessoa <> ""                      THEN
                        TRUE                                    
                     ELSE                                      
                        FALSE)                                  AND
                    CAPS(crapcrt.nmpessoa) MATCHES aux_nmpessoa AND
                    crapcrt.cdsitreg = 1)
                    NO-LOCK:

             ASSIGN par_qtregist = par_qtregist + 1.

             /* controles da paginaçao */
             IF  par_flgpagin                                  AND
                (par_qtregist < par_nriniseq                   OR
                 par_qtregist > (par_nriniseq + par_nrregist)) THEN
                 NEXT.
             
             IF  NOT par_flgpagin OR aux_nrregist > 0 THEN
                 DO:
                    CREATE tt-crapcrt.
              
                    RUN valida-cpf-cnpj IN h-b1wgen9999(INPUT crapcrt.nrcpfcgc,
                                                        OUTPUT aux_stsnrcal,
                                                        OUTPUT aux_inpessoa).

                    ASSIGN tt-crapcrt.nrcpfcgc = (IF aux_inpessoa = 1 THEN 
                                                     STRING((STRING(
                                                     crapcrt.nrcpfcgc,
                                                     "99999999999")),
                                                     "xxx.xxx.xxx-xx")
                                                  ELSE
                                                    STRING((STRING(
                                                    crapcrt.nrcpfcgc,
                                                    "99999999999999")),
                                                    "xx.xxx.xxx/xxxx-xx"))
                           tt-crapcrt.nrregres = crapcrt.nrregres
                           tt-crapcrt.cdsitreg = crapcrt.cdsitreg
                           tt-crapcrt.nmpessoa = SUBSTR(crapcrt.nmpessoa,1,30)
                           tt-crapcrt.cdcopsol = crapcrt.cdcopsol
                           tt-crapcrt.nmpessol = SUBSTR(crapcrt.nmpessol,1,30)
                           tt-crapcrt.cdbccxlt = crapcrt.cdbccxlt
                           tt-crapcrt.dtinclus = crapcrt.dtinclus
                           tt-crapcrt.hrinclus = STRING(crapcrt.hrinclus,"HH:MM:SS")
                           tt-crapcrt.dsjusinc = crapcrt.dsjusinc
                           tt-crapcrt.cdcopinc = crapcrt.cdcopinc
                           tt-crapcrt.cdcopexc = crapcrt.cdcopexc
                           tt-crapcrt.dsjusexc = crapcrt.dsjusexc
                           tt-crapcrt.dtexclus = crapcrt.dtexclus
                           tt-crapcrt.hrexclus = STRING(crapcrt.hrexclus,"HH:MM:SS")
                           tt-crapcrt.tporigem = crapcrt.tporigem.
                         
                   FIND crapope WHERE crapope.cdcooper = crapcrt.cdcopinc AND
                                      crapope.cdoperad = crapcrt.cdopeinc
                                      NO-LOCK NO-ERROR.
               
                   IF AVAIL crapope THEN
                      ASSIGN tt-crapcrt.nmopeinc = crapope.nmoperad.
                           
               
                   FIND crapope WHERE crapope.cdcooper = crapcrt.cdcopexc AND
                                      crapope.cdoperad = crapcrt.cdopeexc
                                      NO-LOCK NO-ERROR.
               
                   IF AVAIL crapope THEN
                      ASSIGN tt-crapcrt.nmopeexc = crapope.nmoperad.
               
               
                   FIND crapcop WHERE crapcop.cdcooper = crapcrt.cdcopsol 
                                      NO-LOCK NO-ERROR.
               
                   IF AVAIL crapcop THEN
                      ASSIGN tt-crapcrt.nmcopsol = crapcop.nmrescop.
               
                   FIND crapcop WHERE crapcop.cdcooper = crapcrt.cdcopinc
                                      NO-LOCK NO-ERROR.
               
                   IF AVAIL crapcop THEN
                      ASSIGN tt-crapcrt.nmcopinc = crapcop.nmrescop.
               
               
                   FIND crapcop WHERE crapcop.cdcooper = crapcrt.cdcopexc 
                                      NO-LOCK NO-ERROR.
               
                   IF AVAIL crapcop THEN
                      ASSIGN tt-crapcrt.nmcopexc = crapcop.nmrescop.

                   FIND crapban WHERE crapban.cdbccxlt = crapcrt.cdbccxlt AND
                                      crapban.cdbccxlt <> 0
                                      NO-LOCK NO-ERROR.

                   IF AVAIL crapban THEN
                      ASSIGN tt-crapcrt.nmextbcc = crapban.nmextbcc.

                 END.
               
             IF  par_flgpagin  THEN
                 ASSIGN aux_nrregist = aux_nrregist - 1.

         END.
          
      END.
 
   IF VALID-HANDLE(h-b1wgen9999) THEN
      DELETE PROCEDURE h-b1wgen9999.

   RETURN "OK".

END. /*Fim da procedure consultar_cad_restritivo*/


PROCEDURE incluir_cad_restritivo:

    DEF INPUT PARAM par_cdcooper AS INT                     NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INT                     NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INT                     NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INT                     NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nrcpfcgc AS DEC                     NO-UNDO.
    DEF INPUT PARAM par_nmpessoa AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_cdcopsol AS INT                     NO-UNDO.
    DEF INPUT PARAM par_nmpessol AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_cdbccxlt AS INT                     NO-UNDO.
    DEF INPUT PARAM par_dsjusinc AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_tporigem AS INT                     NO-UNDO.
    
    DEF OUTPUT PARAM par_msgretor AS INT                    NO-UNDO.
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                   NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nrregres AS INT                             NO-UNDO. 
    DEF VAR aux_msgretor AS INT                             NO-UNDO.
    DEF VAR aux_cdcritic AS INT                             NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                            NO-UNDO.
    DEF VAR aux_sittrans AS CHAR                            NO-UNDO.
    DEF VAR aux_stsnrcal AS LOG                             NO-UNDO.
    DEF VAR aux_inpessoa AS INT                             NO-UNDO.
    DEF VAR aux_qtregist AS INT                             NO-UNDO.

    DEF VAR h-b1wgen9999 AS HANDLE                          NO-UNDO.

    DEF BUFFER b-crapcrt1 FOR crapcrt.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_contador = 0
           aux_nrregres = 1
           aux_cdcritic = 0
           aux_msgretor = 0
           aux_stsnrcal = FALSE
           aux_inpessoa = 0
           aux_qtregist = 0
           aux_sittrans = "NOK".

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper
                       NO-LOCK NO-ERROR.

    IF NOT AVAIL crapcop THEN
       DO: 
          ASSIGN aux_cdcritic = 794.

          RUN gera_erro (INPUT par_cdcooper,        
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1, /*sequencia*/  
                         INPUT aux_cdcritic,        
                         INPUT-OUTPUT aux_dscritic).
                                                  
          RETURN "NOK". 
    
       END.
    
    FIND crapope WHERE crapope.cdcooper = par_cdcooper AND
                       crapope.cdoperad = par_cdoperad
                       NO-LOCK NO-ERROR.
    
    IF NOT AVAIL crapope THEN
       DO: 
          ASSIGN aux_cdcritic = 67.
            
          RUN gera_erro (INPUT par_cdcooper,        
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1, /*sequencia*/
                         INPUT aux_cdcritic,        
                         INPUT-OUTPUT aux_dscritic).
                                                  
          RETURN "NOK". 
    
       END.

    IF par_nrcpfcgc = 0 THEN
       DO:
          ASSIGN aux_cdcritic = 27
                 par_nmdcampo = "nrcpfcgc".
            
          RUN gera_erro (INPUT par_cdcooper,        
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1, /*sequencia*/
                         INPUT aux_cdcritic,        
                         INPUT-OUTPUT aux_dscritic).
                                                  
          RETURN "NOK". 

       END.

    IF NOT VALID-HANDLE(h-b1wgen9999) THEN
       RUN sistema/generico/procedures/b1wgen9999.p 
           PERSISTENT SET h-b1wgen9999.

    RUN valida-cpf-cnpj IN h-b1wgen9999(INPUT par_nrcpfcgc,
                                        OUTPUT aux_stsnrcal,
                                        OUTPUT aux_inpessoa).

    IF VALID-HANDLE(h-b1wgen9999) THEN
       DELETE PROCEDURE h-b1wgen9999.


    IF NOT aux_stsnrcal THEN
       DO: 
          ASSIGN aux_cdcritic = 27
                 par_nmdcampo = "nrcpfcgc".
            
          RUN gera_erro (INPUT par_cdcooper,        
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1, /*sequencia*/
                         INPUT aux_cdcritic,        
                         INPUT-OUTPUT aux_dscritic).
                                                  
          RETURN "NOK". 

       END.

    IF par_nmpessoa = "" THEN
       DO:
          ASSIGN aux_cdcritic = 375
                 par_nmdcampo = "nmpessoa".
            
          RUN gera_erro (INPUT par_cdcooper,        
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1, /*sequencia*/
                         INPUT aux_cdcritic,        
                         INPUT-OUTPUT aux_dscritic).
                                                  
          RETURN "NOK". 

       END.

    IF par_cdbccxlt = 0 AND
       par_cdcopsol = 0 THEN
       DO: 
          ASSIGN aux_cdcritic = 57
                 par_nmdcampo = "cdbccxlt".
          
          RUN gera_erro (INPUT par_cdcooper,        
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1, /*sequencia*/  
                         INPUT aux_cdcritic,        
                         INPUT-OUTPUT aux_dscritic).
                                                  
          RETURN "NOK". 
          
       END.

    IF par_cdbccxlt <> 0 THEN
       DO:
          FIND crapban WHERE crapban.cdbccxlt = par_cdbccxlt 
                             NO-LOCK NO-ERROR.
                
          IF NOT AVAIL crapban THEN
             DO: 
                ASSIGN aux_cdcritic = 57
                       par_nmdcampo = "cdbccxlt".
          
                RUN gera_erro (INPUT par_cdcooper,        
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1, /*sequencia*/  
                               INPUT aux_cdcritic,        
                               INPUT-OUTPUT aux_dscritic).
                                                        
                RETURN "NOK". 
          
             END.
       END.

    IF par_cdcopsol <> 0 THEN
       DO:
          FIND crapcop WHERE crapcop.cdcooper = par_cdcopsol
                             NO-LOCK NO-ERROR.
          
          IF NOT AVAIL crapcop THEN
             DO: 
                ASSIGN aux_cdcritic = 794
                       par_nmdcampo = "cdcopsol".
          
                RUN gera_erro (INPUT par_cdcooper,        
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1, /*sequencia*/  
                               INPUT aux_cdcritic,        
                               INPUT-OUTPUT aux_dscritic).
                                                        
                RETURN "NOK". 
          
             END.

       END.
   
    IF par_nmpessol = "" THEN
       DO:
          ASSIGN aux_cdcritic = 375
                 par_nmdcampo = "nmpessol".
            
          RUN gera_erro (INPUT par_cdcooper,        
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1, /*sequencia*/
                         INPUT aux_cdcritic,        
                         INPUT-OUTPUT aux_dscritic).
                                                  
          RETURN "NOK". 

       END.
    

    IF par_dsjusinc = "" THEN
       DO:
          ASSIGN aux_cdcritic = 375
                 par_nmdcampo = "dsjusinc".
            
          RUN gera_erro (INPUT par_cdcooper,        
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1, /*sequencia*/
                         INPUT aux_cdcritic,        
                         INPUT-OUTPUT aux_dscritic).
                                                  
          RETURN "NOK". 

       END.

    IF par_tporigem = 0 THEN
       DO:
          ASSIGN aux_dscritic = "Tipo de origem invalida."
                 par_nmdcampo = "tporigem".
            
          RUN gera_erro (INPUT par_cdcooper,        
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1, /*sequencia*/
                         INPUT aux_cdcritic,        
                         INPUT-OUTPUT aux_dscritic).
                                                  
          RETURN "NOK". 

       END.


    Inclui: DO TRANSACTION
            ON ERROR  UNDO Inclui, LEAVE Inclui
            ON QUIT   UNDO Inclui, LEAVE Inclui
            ON STOP   UNDO Inclui, LEAVE Inclui
            ON ENDKEY UNDO Inclui, LEAVE Inclui:

       ContadorLng: DO aux_contador = 1 TO 10:
       
          FIND LAST crapcrt WHERE crapcrt.nrcpfcgc = par_nrcpfcgc
                                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
       
          IF NOT AVAIL crapcrt THEN
             DO:
                IF LOCKED crapcrt THEN
                   DO:
                      IF aux_contador = 10 THEN
                         ASSIGN aux_cdcritic = 341. 
                      
                      NEXT ContadorLng. 
       
                   END.
                ELSE
                   LEAVE ContadorLng.
                
             END.
          ELSE
            DO:
               ASSIGN aux_nrregres = crapcrt.nrregres + 1.
       
               LEAVE ContadorLng.
       
            END.
       
       END. /*Fim do ContadorLng*/
       
       IF aux_cdcritic <> 0  OR 
          aux_dscritic <> "" THEN
          UNDO Inclui, LEAVE Inclui.


       FIND FIRST b-crapcrt1 WHERE b-crapcrt1.nrcpfcgc = par_nrcpfcgc AND
                                   b-crapcrt1.cdsitreg = 1
                                   NO-LOCK NO-ERROR.
       
       IF AVAIL b-crapcrt1 THEN
          ASSIGN aux_msgretor = 1.
       ELSE
         DO:
            FIND FIRST b-crapcrt1 WHERE b-crapcrt1.nrcpfcgc = par_nrcpfcgc AND
                                        b-crapcrt1.cdsitreg = 2
                                        NO-LOCK NO-ERROR.
       
            IF AVAIL b-crapcrt1 THEN
               ASSIGN aux_msgretor = 2.
           
         END.
       
       
       CREATE crapcrt.

       ASSIGN crapcrt.nrcpfcgc = par_nrcpfcgc
              crapcrt.nrregres = aux_nrregres
              crapcrt.cdsitreg = 1
              crapcrt.nmpessoa = par_nmpessoa
              crapcrt.cdcopsol = par_cdcopsol
              crapcrt.nmpessol = par_nmpessol
              crapcrt.cdbccxlt = INT(par_cdbccxlt)
              crapcrt.dtinclus = par_dtmvtolt
              crapcrt.hrinclus = TIME
              crapcrt.dsjusinc = par_dsjusinc
              crapcrt.cdcopinc = par_cdcooper
              crapcrt.cdopeinc = par_cdoperad
              crapcrt.tporigem = par_tporigem
              par_msgretor     = aux_msgretor
              aux_sittrans     = "OK".
       VALIDATE crapcrt.
       
       /*** Traz todos os registros de cada cooperativa ativa ***/
      FOR EACH crapcop WHERE crapcop.flgativo = TRUE
						 NO-LOCK:

      /* Buscar CPF/CNPJ raiz do associado, nr da conta e tipo pessoa */
			FIND FIRST crapass WHERE crapass.cdcooper = crapcop.cdcooper AND
                               crapass.nrcpfcgc = par_nrcpfcgc NO-LOCK NO-ERROR.

        IF AVAIL crapass THEN
        DO:

	        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    

          /* Efetuar a chamada a rotina Oracle */
          RUN STORED-PROCEDURE pc_proces_perca_pre_aprovad
            aux_handproc = PROC-HANDLE NO-ERROR (INPUT crapcop.cdcooper
                                                ,INPUT 0
                                                ,INPUT crapass.nrdconta
                                                ,INPUT crapass.inpessoa
                                                ,INPUT crapass.nrcpfcnpj_base
                                                ,INPUT par_dtmvtolt
                                                ,INPUT 36
                                                ,INPUT 0
                                                ,INPUT 0
                                                ,OUTPUT "").

          /* Fechar o procedimento para buscarmos o resultado */ 
          CLOSE STORED-PROC pc_proces_perca_pre_aprovad
             aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

          { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

          ASSIGN aux_dscritic = ""
              aux_dscritic = pc_proces_perca_pre_aprovad.pr_dscritic WHEN pc_proces_perca_pre_aprovad.pr_dscritic <> ?.   

          IF aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
          DO:
            RUN gera_erro (INPUT par_cdcooper,
                   INPUT par_cdagenci,
                   INPUT par_nrdcaixa,
                   INPUT 1, /*sequencia*/
                   INPUT aux_cdcritic,
                   INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".

          END.
        END.
      END. /* FIM crapcop */

    END. /*Fim do transaction Inclui*/

    IF aux_cdcritic <> 0   OR 
       aux_dscritic <> "" THEN
       DO: 
          RUN gera_erro (INPUT par_cdcooper,        
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1, /*sequencia*/ 
                         INPUT aux_cdcritic,        
                         INPUT-OUTPUT aux_dscritic).
                                                  
          RETURN "NOK".
       
       END.

    RETURN aux_sittrans.


END PROCEDURE. /*Fim da procedure incluir_cad_restritivo*/


PROCEDURE excluir_cad_restritivo:

    DEF INPUT PARAM par_cdcooper AS INT                            NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INT                            NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INT                            NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INT                            NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_nrcpfcgc AS DEC                            NO-UNDO.
    DEF INPUT PARAM par_nrregres AS INT                            NO-UNDO.
    DEF INPUT PARAM par_dsjusexc AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_dtexclus AS DATE                           NO-UNDO.

    DEF OUTPUT PARAM par_nmdcampo AS CHAR                          NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_cdcritic AS INT                                    NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                   NO-UNDO.
    DEF VAR aux_sittrans AS CHAR                                   NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_sittrans = "NOK".

    
    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper
                       NO-LOCK NO-ERROR.

    IF NOT AVAIL crapcop THEN
       DO: 
          ASSIGN aux_cdcritic = 794.
            
          RUN gera_erro (INPUT par_cdcooper,        
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1, /*sequencia*/ 
                         INPUT aux_cdcritic,        
                         INPUT-OUTPUT aux_dscritic).
                                                  
          RETURN "NOK". 
    
       END.

    FIND crapope WHERE crapope.cdcooper = par_cdcooper AND
                       crapope.cdoperad = par_cdoperad
                       NO-LOCK NO-ERROR.
    
    IF NOT AVAIL crapope THEN
       DO: 
          ASSIGN aux_cdcritic = 67.
            
          RUN gera_erro (INPUT par_cdcooper,        
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1, /*sequencia*/ 
                         INPUT aux_cdcritic,        
                         INPUT-OUTPUT aux_dscritic).
                                                  
          RETURN "NOK". 
    
       END.

    IF par_dsjusexc = "" THEN
       DO: 
          ASSIGN aux_cdcritic = 375
                 par_nmdcampo = "dsjusexc".
            
          RUN gera_erro (INPUT par_cdcooper,        
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1, /*sequencia*/ 
                         INPUT aux_cdcritic,        
                         INPUT-OUTPUT aux_dscritic).
                                                  
          RETURN "NOK". 

       END.

    Exclui: DO TRANSACTION
            ON ERROR  UNDO Exclui, LEAVE Exclui
            ON QUIT   UNDO Exclui, LEAVE Exclui
            ON STOP   UNDO Exclui, LEAVE Exclui
            ON ENDKEY UNDO Exclui, LEAVE Exclui:
       
       ContadorLng: DO aux_contador = 1 TO 10:
       
          FIND crapcrt WHERE crapcrt.nrcpfcgc = par_nrcpfcgc AND
                             crapcrt.nrregres = par_nrregres
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
       
          IF NOT AVAIL crapcrt THEN
             DO:
                IF LOCKED crapcrt THEN
                   DO:
                       IF aux_contador = 10 THEN
                          ASSIGN aux_cdcritic = 341.
       
                       NEXT ContadorLng.
       
                   END.
                ELSE
                  DO:
                     ASSIGN aux_dscritic = "Registro nao encontrado.".
       
                     LEAVE ContadorLng.
       
                  END.
       
             END.
       
       
       END.

       IF aux_cdcritic <> 0  OR 
          aux_dscritic <> "" THEN
          UNDO Exclui, LEAVE Exclui.


       ASSIGN crapcrt.cdsitreg = 2
              crapcrt.dsjusexc = par_dsjusexc
              crapcrt.cdcopexc = par_cdcooper
              crapcrt.cdopeexc = par_cdoperad
              crapcrt.dtexclus = par_dtmvtolt
              crapcrt.hrexclus = TIME
              aux_sittrans     = "OK".

    END. /*Fim do transaction Exclui*/

    IF aux_cdcritic <> 0  OR
       aux_dscritic <> "" THEN
       DO:
          RUN gera_erro (INPUT par_cdcooper,        
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1, /*sequencia*/  
                         INPUT aux_cdcritic,        
                         INPUT-OUTPUT aux_dscritic).
                                                  
          RETURN "NOK".  

       END.
   

    RETURN aux_sittrans.


END PROCEDURE. /*Fim da procedure excluir_cad_restritivo*/


PROCEDURE liberar_cad_restritivo:

    DEF INPUT PARAM par_cdcooper AS INT                     NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INT                     NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INT                     NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INT                     NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_cdcoplib AS INT                     NO-UNDO.
    DEF INPUT PARAM par_cdagelib AS INT                     NO-UNDO.
    DEF INPUT PARAM par_cdopelib AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INT                     NO-UNDO.
    DEF INPUT PARAM par_nrcpfcgc AS DEC                     NO-UNDO.
    DEF INPUT PARAM par_dsjuslib AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_cdoperac AS INT                     NO-UNDO.
    DEF INPUT PARAM par_flgsiste AS LOG                     NO-UNDO.
    
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                   NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_cdcritic AS INT                             NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                            NO-UNDO.
    DEF VAR aux_sittrans AS CHAR                            NO-UNDO.
    DEF VAR aux_nrjuslib AS INT                             NO-UNDO.
    DEF VAR aux_nrcpfcgc AS DEC                             NO-UNDO.
    DEF VAR aux_nrdconta AS INT                             NO-UNDO.
    DEF VAR h-b1wgen9999 AS HANDLE                          NO-UNDO.
    DEF VAR aux_inpessoa AS INT                             NO-UNDO.
    DEF VAR aux_stsnrcal AS LOG                             NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_contador = 0
           aux_cdcritic = 0
           aux_nrjuslib = 0
           aux_sittrans = "NOK"
           aux_nrcpfcgc = 0
           aux_nrdconta = 0.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper
                       NO-LOCK NO-ERROR.

    IF NOT AVAIL crapcop THEN
       DO: 
          ASSIGN aux_cdcritic = 794.

          RUN gera_erro (INPUT par_cdcooper,        
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1, /*sequencia*/  
                         INPUT aux_cdcritic,        
                         INPUT-OUTPUT aux_dscritic).
                                                  
          RETURN "NOK". 
    
       END.

    FIND crapope WHERE crapope.cdcooper = par_cdcooper AND
                       crapope.cdoperad = par_cdoperad
                       NO-LOCK NO-ERROR.
    
    IF NOT AVAIL crapope THEN
       DO: 
          ASSIGN aux_cdcritic = 67.
            
          RUN gera_erro (INPUT par_cdcooper,        
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1, /*sequencia*/
                         INPUT aux_cdcritic,        
                         INPUT-OUTPUT aux_dscritic).
                                                  
          RETURN "NOK". 
    
       END.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcoplib
                       NO-LOCK NO-ERROR.

    IF NOT AVAIL crapcop THEN
       DO: 
          ASSIGN aux_cdcritic = 794
                 par_nmdcampo = "cdcopsol".

          RUN gera_erro (INPUT par_cdcooper,        
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1, /*sequencia*/  
                         INPUT aux_cdcritic,        
                         INPUT-OUTPUT aux_dscritic).
                                                  
          RETURN "NOK". 
    
       END.

    FIND crapage WHERE crapage.cdcooper = par_cdcoplib AND
                       crapage.cdagenci = par_cdagelib 
                       NO-LOCK NO-ERROR.

    IF NOT AVAIL crapage THEN
       DO: 
          ASSIGN aux_cdcritic = 962
                 par_nmdcampo = "cdagepac".
            
          RUN gera_erro (INPUT par_cdcooper,        
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1, /*sequencia*/
                         INPUT aux_cdcritic,        
                         INPUT-OUTPUT aux_dscritic).
                                                  
          RETURN "NOK". 
     
       END.

    FIND crapope WHERE crapope.cdcooper = par_cdcoplib AND
                       crapope.cdoperad = par_cdopelib
                       NO-LOCK NO-ERROR.
    
    IF NOT AVAIL crapope THEN
       DO: 
          ASSIGN aux_cdcritic = 67
                 par_nmdcampo = "cdopelib".
            
          RUN gera_erro (INPUT par_cdcooper,        
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1, /*sequencia*/
                         INPUT aux_cdcritic,        
                         INPUT-OUTPUT aux_dscritic).
                                                  
          RETURN "NOK". 
    
       END.


    /*IF par_nrdconta = 0 THEN
       DO: 
          ASSIGN aux_cdcritic = 9
                 par_nmdcampo = "nrdconta".
            
          RUN gera_erro (INPUT par_cdcooper,        
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1, /*sequencia*/
                         INPUT aux_cdcritic,        
                         INPUT-OUTPUT aux_dscritic).
                                                  
          RETURN "NOK". 
      
       END.*/

    IF par_nrcpfcgc = 0 THEN
       DO:
          ASSIGN aux_cdcritic = 27
                 par_nmdcampo = "nrcpfcgc".
            
          RUN gera_erro (INPUT par_cdcooper,        
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1, /*sequencia*/
                         INPUT aux_cdcritic,        
                         INPUT-OUTPUT aux_dscritic).
                                                  
          RETURN "NOK". 
      
       END.
    
    IF NOT VALID-HANDLE(h-b1wgen9999) THEN
       RUN sistema/generico/procedures/b1wgen9999.p 
           PERSISTENT SET h-b1wgen9999.

    RUN valida-cpf-cnpj IN h-b1wgen9999(INPUT par_nrcpfcgc,
                                        OUTPUT aux_stsnrcal,
                                        OUTPUT aux_inpessoa).


    IF VALID-HANDLE(h-b1wgen9999) THEN
       DELETE PROCEDURE h-b1wgen9999.

    IF NOT aux_stsnrcal THEN
       DO: 
          ASSIGN aux_cdcritic = 27
                 par_nmdcampo = "nrcpfcgc".
            
          RUN gera_erro (INPUT par_cdcooper,        
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1, /*sequencia*/
                         INPUT aux_cdcritic,        
                         INPUT-OUTPUT aux_dscritic).
                                                  
          RETURN "NOK". 

       END.

    IF par_nrdconta <> 0 THEN
       DO:
          FIND crapass WHERE crapass.cdcooper = par_cdcoplib AND
                             crapass.nrdconta = par_nrdconta
                             NO-LOCK NO-ERROR.

          IF NOT AVAIL crapass THEN
             DO:
                ASSIGN aux_cdcritic = 9
                       par_nmdcampo = "nrdconta".
                  
                RUN gera_erro (INPUT par_cdcooper,        
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1, /*sequencia*/
                               INPUT aux_cdcritic,        
                               INPUT-OUTPUT aux_dscritic).
                                                        
                RETURN "NOK". 
             
             END.

       END.
    

    FIND craprot WHERE craprot.cdoperac = par_cdoperac
                       NO-LOCK NO-ERROR.

    IF NOT AVAIL craprot THEN
       DO: 
          ASSIGN aux_dscritic = "Operacao nao cadastrada."
                 par_nmdcampo = "cdoperac".
            
          RUN gera_erro (INPUT par_cdcooper,        
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1, /*sequencia*/
                         INPUT aux_cdcritic,        
                         INPUT-OUTPUT aux_dscritic).
                                                  
          RETURN "NOK". 
      
       END.

    IF par_dsjuslib = "" THEN
       DO: 
          ASSIGN aux_cdcritic = 375
                 par_nmdcampo = "dsjuslib".
            
          RUN gera_erro (INPUT par_cdcooper,        
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1, /*sequencia*/
                         INPUT aux_cdcritic,        
                         INPUT-OUTPUT aux_dscritic).
                                                  
          RETURN "NOK". 
      
       END.
    

    Libera: DO TRANSACTION
            ON ERROR  UNDO Libera, LEAVE Libera
            ON QUIT   UNDO Libera, LEAVE Libera
            ON STOP   UNDO Libera, LEAVE Libera
            ON ENDKEY UNDO Libera, LEAVE Libera:

       ContadorLju: DO aux_contador = 1 TO 10:
       
          FIND LAST craplju WHERE craplju.nrcpfcgc = par_nrcpfcgc
                                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
       
          IF NOT AVAIL craplju THEN
             DO:
                IF LOCKED craplju THEN
                   DO:
                      IF aux_contador = 10 THEN
                         ASSIGN aux_cdcritic = 341. 
                      
                      NEXT ContadorLju. 
       
                   END.
                ELSE
                   DO:
                      ASSIGN aux_nrjuslib = aux_nrjuslib + 1.

                      LEAVE ContadorLju.

                   END.
                
             END.
          ELSE
            DO:
               ASSIGN aux_nrjuslib = craplju.nrjuslib + 1.
       
               LEAVE ContadorLju.
       
            END.
       
       END. /*Fim do ContadorLng*/
       
       IF aux_cdcritic <> 0  OR 
          aux_dscritic <> "" THEN
          UNDO Libera, LEAVE Libera.

       CREATE craplju.
       
       ASSIGN craplju.nrcpfcgc = par_nrcpfcgc
              craplju.nrjuslib = aux_nrjuslib
              craplju.cdcoplib = par_cdcoplib
              craplju.cdagenci = par_cdagelib
              craplju.cdopelib = par_cdopelib
              craplju.nrdconta = par_nrdconta
              craplju.dtmvtolt = par_dtmvtolt
              craplju.hrtransa = TIME
              craplju.dsjuslib = par_dsjuslib
              craplju.cdcooper = par_cdcooper
              craplju.cdoperad = par_cdoperad
              craplju.cdoperac = par_cdoperac
              craplju.flgsiste = par_flgsiste
              aux_sittrans     = "OK".
       VALIDATE craplju.
              

    END. /*Fim do transaction Inclui*/

    IF aux_cdcritic <> 0   OR 
       aux_dscritic <> "" THEN
       DO: 
          RUN gera_erro (INPUT par_cdcooper,        
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1, /*sequencia*/ 
                         INPUT aux_cdcritic,        
                         INPUT-OUTPUT aux_dscritic).
                                                  
          RETURN "NOK".
       
       END.


    RETURN aux_sittrans.


END PROCEDURE. /*Fim da procedure liberar_cad_restritivo*/


/*PROCEDURE RESPONSAVEL PELA GERACAO DO RELATORIO*/ 
PROCEDURE gera_relatorio:
    
    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DEC                               NO-UNDO.
    DEF  INPUT PARAM par_nmpessoa AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_tprelato AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_dtinicio AS DATE                              NO-UNDO.
    DEF  INPUT PARAM par_dtdfinal AS DATE                              NO-UNDO.

    DEF OUTPUT PARAM par_nmarqimp AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.                             
                                                                    
    DEF VAR aux_nmarquiv AS CHAR                                       NO-UNDO.
    DEF VAR aux_nmarqimp AS CHAR                                       NO-UNDO.
    DEF VAR aux_nmarqpdf AS CHAR                                       NO-UNDO.
    DEF VAR aux_cdcritic AS INT                                        NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                       NO-UNDO.
    DEF VAR aux_nmpessoa AS CHAR                                       NO-UNDO.
                                                                               
    DEF VAR h-b1wgen0024 AS HANDLE                                     NO-UNDO.

    
    EMPTY TEMP-TABLE tt-erro.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + "/rl/" +
                          par_dsiduser.
    
    UNIX SILENT VALUE("rm " + aux_nmarquiv + "* 2>/dev/null").

    ASSIGN aux_nmarquiv = aux_nmarquiv + STRING(TIME)
           aux_nmarqimp = aux_nmarquiv + ".ex"
           aux_nmarqpdf = aux_nmarquiv + ".pdf"
           aux_nmpessoa = "*" + par_nmpessoa + "*".

    
    Gera: DO WHILE TRUE:

        OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 62.

        IF   par_tprelato = 1   THEN
             DO: 
                 RUN gera_relatorio_alertas (INPUT par_cdcooper,
                                             INPUT par_dtmvtolt,
                                             INPUT par_nrcpfcgc,
                                             INPUT aux_nmpessoa,
                                            OUTPUT aux_cdcritic,
                                            OUTPUT aux_dscritic).                  
             END.
        ELSE
             DO:
                 RUN gera_relatorio_analitico (INPUT par_cdcooper,
                                               INPUT par_dtmvtolt,
                                               INPUT par_nrcpfcgc,
                                               INPUT aux_nmpessoa,
                                               INPUT par_dtinicio,
                                               INPUT par_dtdfinal,
                                              OUTPUT aux_cdcritic,
                                              OUTPUT aux_dscritic). 
             END.

        IF   RETURN-VALUE <> "OK"   THEN
             LEAVE Gera. 

        OUTPUT STREAM str_1 CLOSE.    

        IF par_idorigem = 5  THEN  /** Ayllos Web **/
           DO:
               IF NOT VALID-HANDLE(h-b1wgen0024) THEN
                  RUN sistema/generico/procedures/b1wgen0024.p 
                      PERSISTENT SET h-b1wgen0024.
        
               IF NOT VALID-HANDLE(h-b1wgen0024)  THEN
                  DO:
                     ASSIGN aux_dscritic = "Handle invalido para BO " +
                                           "b1wgen0024.".
                     LEAVE Gera.
        
                  END.
        
               RUN envia-arquivo-web IN h-b1wgen0024 
                   ( INPUT par_cdcooper,
                     INPUT par_cdagenci,
                     INPUT par_nrdcaixa,
                     INPUT aux_nmarqimp,
                    OUTPUT par_nmarqpdf,
                    OUTPUT TABLE tt-erro ).
        
               IF VALID-HANDLE(h-b1wgen0024)  THEN
                  DELETE PROCEDURE h-b1wgen0024.
        
               IF RETURN-VALUE <> "OK" THEN
                  RETURN "NOK".
        
           END.    
        
        ASSIGN par_nmarqimp = aux_nmarqimp.

        LEAVE Gera.

    END.

    IF aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
       DO:
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

PROCEDURE gera_relatorio_alertas:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                              NO-UNDO.
    DEF  INPUT PARAM par_nmpessoa AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE                              NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                              NO-UNDO.


    { sistema/generico/includes/b1cabrel234.i "11" "639"}
       
    VIEW STREAM str_1 FRAME f_cabrel234_1.
                   
    PUT STREAM str_1 "RESTRICOES:"
                    SKIP(1).
                 
    RUN imprime_inclusos (INPUT par_nrcpfcgc,
                          INPUT par_nmpessoa,
                          INPUT ?,
                          INPUT ?,
                         OUTPUT par_cdcritic,
                         OUTPUT par_dscritic).
          
    PUT STREAM str_1 SKIP(3)
                     "LIBERACOES C/ JUSTIFICATIVA:".
    
    RUN imprime_justificativas (INPUT par_nrcpfcgc,
                                INPUT ?,
                                INPUT ?,
                               OUTPUT par_cdcritic,
                               OUTPUT par_dscritic).

    RETURN "OK".

END PROCEDURE.

PROCEDURE gera_relatorio_analitico:

    DEF  INPUT PARAM par_cdcooper AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                             NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                             NO-UNDO.
    DEF  INPUT PARAM par_nmpessoa AS CHAR                             NO-UNDO.
    DEF  INPUT PARAM par_dtinicio AS DATE                             NO-UNDO.
    DEF  INPUT PARAM par_dtdfinal AS DATE                             NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE                             NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                             NO-UNDO.


    { sistema/generico/includes/b1cabrel234.i "11" "689"}
       
    VIEW STREAM str_1 FRAME f_cabrel234_1.

    DISPLAY STREAM str_1 
            SKIP(1) 
            CAPS("Inclusas no cadastro restritivo") FORMAT "x(50)"
            SKIP(1)                                 
            WITH FRAME f_incl.

    RUN imprime_inclusos (INPUT 0,
                          INPUT "**",
                          INPUT par_dtinicio,
                          INPUT par_dtdfinal,
                         OUTPUT par_cdcritic,
                         OUTPUT par_dscritic).

    PAGE STREAM str_1.

    DISPLAY STREAM str_1 
            SKIP(1) 
            CAPS("Exclusas do cadastro restritivo") FORMAT "x(50)"
            SKIP(1) 
            WITH FRAME f_excl.

    RUN imprime_exclusos (INPUT par_dtinicio,
                          INPUT par_dtdfinal,
                          OUTPUT par_cdcritic,
                          OUTPUT par_dscritic). 

    PAGE STREAM str_1.

    DISPLAY STREAM str_1 
            SKIP(1) 
            CAPS("Exclusas com justificativas") FORMAT "x(50)"
            SKIP(1) 
            WITH FRAME f_just.
    
    RUN imprime_justificativas (INPUT par_nrcpfcgc,
                                INPUT par_dtinicio,
                                INPUT par_dtdfinal,
                               OUTPUT par_cdcritic,
                               OUTPUT par_dscritic).

    RETURN "OK".

END PROCEDURE.


PROCEDURE imprime_inclusos:

    DEF  INPUT PARAM par_nrcpfcgc AS DECI                             NO-UNDO.
    DEF  INPUT PARAM par_nmpessoa AS CHAR                             NO-UNDO.
    DEF  INPUT PARAM par_dtinicio AS DATE                             NO-UNDO.
    DEF  INPUT PARAM par_dtdfinal AS DATE                             NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE                             NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                             NO-UNDO.
                                                                     
    DEF VAR aux_nrcpfcgc AS CHAR FORMAT "X(18)"                       NO-UNDO.
    DEF VAR aux_nmextbcc LIKE crapban.nmextbcc                        NO-UNDO. 
    DEF VAR aux_stsnrcal AS LOG                                       NO-UNDO.
    DEF VAR aux_inpessoa AS INTE                                      NO-UNDO.
    DEF VAR aux_nmoperad AS CHAR                                      NO-UNDO.
    DEF VAR aux_dsjusinc AS CHAR                                      NO-UNDO.

    DEF VAR h-b1wgen9999 AS HANDLE                                    NO-UNDO.


    FORM aux_nrcpfcgc     COLUMN-LABEL "CPF/CNPJ"          FORMAT "x(15)"
         crapcrt.dtinclus COLUMN-LABEL "Dt. Inclusao"      FORMAT "99/99/9999"
         crapcrt.nmpessoa COLUMN-LABEL "Nome"              FORMAT "x(30)"
         crapcop.nmrescop COLUMN-LABEL "Cooperativa"       FORMAT "x(15)"
         aux_nmextbcc     COLUMN-LABEL "Inst. Financeira"  FORMAT "x(20)"
         aux_dsjusinc     COLUMN-LABEL "Just. de inclusao" FORMAT "x(80)"
         aux_nmoperad     COLUMN-LABEL "Operador"          FORMAT "x(35)"            
         WITH DOWN WIDTH 230 NO-BOX FRAME f_restricoes_incl.


    FOR EACH crapcrt WHERE (IF par_nrcpfcgc <> 0 THEN 
                               crapcrt.nrcpfcgc = par_nrcpfcgc 
                            ELSE                                       
                               CAPS(crapcrt.nmpessoa) MATCHES par_nmpessoa)
                            NO-LOCK  BY crapcrt.cdcopsol
                                        BY crapcrt.dtinclus
                                           BY crapcrt.nrcpfcgc:

        IF   par_nrcpfcgc = 0      AND
             par_nmpessoa = "**"   THEN
             IF   crapcrt.cdsitreg <> 1   THEN
                  NEXT.

        IF   par_dtinicio <> ?   AND
             crapcrt.dtinclus < par_dtinicio   THEN
             NEXT.

        IF   par_dtdfinal <> ?   AND
             crapcrt.dtinclus > par_dtdfinal   THEN
             NEXT.

        ASSIGN aux_nrcpfcgc = ""
               aux_stsnrcal = FALSE
               aux_inpessoa = 0
               aux_nmextbcc = ""
               aux_dsjusinc = TRIM(crapcrt.dsjusinc).

        IF NOT VALID-HANDLE(h-b1wgen9999) THEN
           RUN sistema/generico/procedures/b1wgen9999.p 
               PERSISTENT SET h-b1wgen9999.
            
        RUN valida-cpf-cnpj IN h-b1wgen9999(INPUT crapcrt.nrcpfcgc,
                                            OUTPUT aux_stsnrcal,
                                            OUTPUT aux_inpessoa).
    
        IF VALID-HANDLE(h-b1wgen9999) THEN
           DELETE PROCEDURE h-b1wgen9999.
    
    
        IF   NOT aux_stsnrcal THEN
             DO: 
                ASSIGN par_cdcritic = 27.
                RETURN "NOK".  
             END.

        IF   aux_inpessoa = 1 THEN
             ASSIGN aux_nrcpfcgc = STRING(crapcrt.nrcpfcgc,"99999999999")
                    aux_nrcpfcgc = STRING(aux_nrcpfcgc,"xxx.xxx.xxx-xx").
        ELSE
             ASSIGN aux_nrcpfcgc = STRING(crapcrt.nrcpfcgc,"99999999999999")
                    aux_nrcpfcgc = STRING(aux_nrcpfcgc,"xx.xxx.xxx/xxxx-xx").


        FIND crapcop WHERE crapcop.cdcooper = crapcrt.cdcopsol
                           NO-LOCK NO-ERROR.

        IF NOT AVAIL crapcop THEN
           DO: 
              ASSIGN par_cdcritic = 794.
              RETURN "NOK". 
           END.
                          
        IF crapcrt.cdbccxlt <> 0 THEN
           DO:
              FIND crapban WHERE crapban.cdbccxlt = crapcrt.cdbccxlt
                                 NO-LOCK NO-ERROR.

              IF NOT AVAIL crapban THEN
                 DO:
                    ASSIGN par_dscritic = "Instituicao financeira nao " + 
                                          "cadastrada.".
                    RETURN "NOK".
                 END.
              ELSE
                 ASSIGN aux_nmextbcc = crapban.nmextbcc.

           END.

        FIND crapope WHERE crapope.cdcooper = crapcrt.cdcopinc AND
                           crapope.cdoperad = crapcrt.cdopeinc
                           NO-LOCK NO-ERROR.

        IF NOT AVAIL crapope THEN
           DO:
              ASSIGN par_cdcritic = 67.
              RETURN "NOK".  
           END.
                                                       
        ASSIGN aux_nmoperad = crapope.nmoperad.

        DISP STREAM str_1 aux_nrcpfcgc              
                          crapcrt.dtinclus          
                          crapcrt.nmpessoa          
                          crapcop.nmrescop          
                          aux_nmextbcc              
                          aux_dsjusinc        
                          aux_nmoperad        
                          WITH FRAME f_restricoes_incl.

        DOWN STREAM str_1 WITH FRAME f_restricoes_incl.
          
               
    END.
  
    RETURN "OK".

END PROCEDURE.
  
PROCEDURE imprime_exclusos:

    DEF  INPUT PARAM par_dtinicio AS DATE                             NO-UNDO.
    DEF  INPUT PARAM par_dtdfinal AS DATE                             NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE                             NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                             NO-UNDO.

    DEF VAR aux_nrcpfcgc AS CHAR FORMAT "X(18)"                       NO-UNDO.
    DEF VAR aux_nmextbcc LIKE crapban.nmextbcc                        NO-UNDO. 
    DEF VAR aux_stsnrcal AS LOG                                       NO-UNDO.
    DEF VAR aux_inpessoa AS INTE                                      NO-UNDO.
    DEF VAR aux_nmoperad AS CHAR                                      NO-UNDO.
    DEF VAR aux_dsjusexc AS CHAR                                      NO-UNDO.

    DEF VAR h-b1wgen9999 AS HANDLE                                    NO-UNDO.


    FORM aux_nrcpfcgc     COLUMN-LABEL "CPF/CNPJ"          FORMAT "x(15)"
         crapcrt.dtexclus COLUMN-LABEL "Dt. Exclusao"      FORMAT "99/99/9999"
         crapcrt.nmpessoa COLUMN-LABEL "Nome"              FORMAT "x(30)"
         crapcop.nmrescop COLUMN-LABEL "Cooperativa"       FORMAT "x(15)"
         aux_nmextbcc     COLUMN-LABEL "Inst. Financeira"  FORMAT "x(20)"
         aux_dsjusexc     COLUMN-LABEL "Just. de exclusao" FORMAT "x(80)"  
         aux_nmoperad     COLUMN-LABEL "Operador"          FORMAT "x(35)"            
         WITH DOWN WIDTH 230 NO-BOX FRAME f_restricoes_excl.


    FOR EACH crapcrt WHERE crapcrt.cdsitreg = 2
                           NO-LOCK  BY crapcrt.cdcopsol
                                       BY crapcrt.dtexclus 
                                          BY crapcrt.nrcpfcgc:

        IF   par_dtinicio <> ?   AND
             crapcrt.dtexclus < par_dtinicio   THEN
             NEXT.

        IF   par_dtdfinal <> ?   AND
             crapcrt.dtexclus > par_dtdfinal   THEN
             NEXT.

        ASSIGN aux_nrcpfcgc = ""
               aux_stsnrcal = FALSE
               aux_inpessoa = 0
               aux_nmextbcc = ""
               aux_dsjusexc = TRIM(crapcrt.dsjusexc).

        IF NOT VALID-HANDLE(h-b1wgen9999) THEN
           RUN sistema/generico/procedures/b1wgen9999.p 
               PERSISTENT SET h-b1wgen9999.
            
        RUN valida-cpf-cnpj IN h-b1wgen9999(INPUT crapcrt.nrcpfcgc,
                                            OUTPUT aux_stsnrcal,
                                            OUTPUT aux_inpessoa).
    
        IF VALID-HANDLE(h-b1wgen9999) THEN
           DELETE PROCEDURE h-b1wgen9999.
        
        IF   NOT aux_stsnrcal THEN
             DO: 
                ASSIGN par_cdcritic = 27.
                RETURN "NOK".  
             END.

        IF   aux_inpessoa = 1 THEN
             ASSIGN aux_nrcpfcgc = STRING(crapcrt.nrcpfcgc,"99999999999")
                    aux_nrcpfcgc = STRING(aux_nrcpfcgc,"xxx.xxx.xxx-xx").
        ELSE
             ASSIGN aux_nrcpfcgc = STRING(crapcrt.nrcpfcgc,"99999999999999")
                    aux_nrcpfcgc = STRING(aux_nrcpfcgc,"xx.xxx.xxx/xxxx-xx").

        FIND crapcop WHERE crapcop.cdcooper = crapcrt.cdcopsol
                           NO-LOCK NO-ERROR.

        IF NOT AVAIL crapcop THEN
           DO: 
              ASSIGN par_cdcritic = 794.
              RETURN "NOK". 
           END.
                          
        IF crapcrt.cdbccxlt <> 0 THEN
           DO:
              FIND crapban WHERE crapban.cdbccxlt = crapcrt.cdbccxlt
                                 NO-LOCK NO-ERROR.

              IF NOT AVAIL crapban THEN
                 DO:
                    ASSIGN par_dscritic = "Instituicao financeira nao " + 
                                          "cadastrada.".
                    RETURN "NOK".
                 END.
              ELSE
                 ASSIGN aux_nmextbcc = crapban.nmextbcc.

           END.

        FIND crapope WHERE crapope.cdcooper = crapcrt.cdcopinc AND
                           crapope.cdoperad = crapcrt.cdopeexc
                           NO-LOCK NO-ERROR.

        IF NOT AVAIL crapope THEN
           DO:
              ASSIGN par_cdcritic = 67.
              RETURN "NOK".  
           END.
                                                       
        ASSIGN aux_nmoperad = crapope.nmoperad.

        DISP STREAM str_1 aux_nrcpfcgc              
                          crapcrt.dtexclus          
                          crapcrt.nmpessoa          
                          crapcop.nmrescop          
                          aux_nmextbcc              
                          aux_dsjusexc          
                          aux_nmoperad        
                          WITH FRAME f_restricoes_excl.

        DOWN STREAM str_1 WITH FRAME f_restricoes_excl.
          
               
    END.
  
    RETURN "OK".

END PROCEDURE.

PROCEDURE imprime_justificativas:

    DEF  INPUT PARAM par_nrcpfcgc AS DECI                            NO-UNDO.
    DEF  INPUT PARAM par_dtinicio AS DATE                            NO-UNDO.
    DEF  INPUT PARAM par_dtdfinal AS DATE                            NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE                            NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                            NO-UNDO.
    

    DEF VAR aux_nrcpfcgc AS CHAR FORMAT "X(18)"                      NO-UNDO.
    DEF VAR aux_nmextbcc LIKE crapban.nmextbcc                       NO-UNDO.
    DEF VAR aux_stsnrcal AS LOG                                      NO-UNDO.
    DEF VAR aux_inpessoa AS INT                                      NO-UNDO.
    DEF VAR aux_nmoperad AS CHAR                                     NO-UNDO.

    DEF VAR h-b1wgen9999 AS HANDLE                                   NO-UNDO.


    FORM aux_nrcpfcgc     COLUMN-LABEL "CPF/CNPJ"      
         craplju.dtmvtolt COLUMN-LABEL "Dt. Liberacao" 
         craplju.nrdconta COLUMN-LABEL "Conta D/v"     
         crapcop.nmrescop COLUMN-LABEL "Cooperativa" 
         craplju.dsjuslib COLUMN-LABEL "Justificativa"  FORMAT "x(140)"
         aux_nmoperad     COLUMN-LABEL "Operador"       FORMAT "x(30)"
         WITH DOWN WIDTH 234 NO-BOX FRAME f_justificativa.

    FOR EACH craplju WHERE (IF par_nrcpfcgc <> 0 THEN 
                               craplju.nrcpfcgc = par_nrcpfcgc 
                            ELSE                                       
                               TRUE)
                           NO-LOCK BY craplju.cdcoplib
                                      BY craplju.dtmvtolt
                                         BY craplju.nrcpfcgc
                                            BY craplju.cdoperac:
    
        IF   par_dtinicio <> ?   AND
             craplju.dtmvtolt < par_dtinicio   THEN
             NEXT.

        IF   par_dtdfinal <> ?   AND
             craplju.dtmvtolt > par_dtdfinal   THEN
             NEXT.

        ASSIGN aux_nrcpfcgc = ""
               aux_stsnrcal = FALSE
               aux_inpessoa = 0.
       
        IF NOT VALID-HANDLE(h-b1wgen9999) THEN
           RUN sistema/generico/procedures/b1wgen9999.p 
               PERSISTENT SET h-b1wgen9999.
        
        RUN valida-cpf-cnpj IN h-b1wgen9999(INPUT craplju.nrcpfcgc,
                                            OUTPUT aux_stsnrcal,
                                            OUTPUT aux_inpessoa).
    
        IF VALID-HANDLE(h-b1wgen9999) THEN
           DELETE PROCEDURE h-b1wgen9999.
        
        
        IF NOT aux_stsnrcal THEN
           DO: 
              ASSIGN par_cdcritic = 27.
              RETURN "NOK". 
           END.
    
        IF aux_inpessoa = 1 THEN
           ASSIGN aux_nrcpfcgc = STRING(craplju.nrcpfcgc,"99999999999")
                  aux_nrcpfcgc = STRING(aux_nrcpfcgc,"xxx.xxx.xxx-xx").
        ELSE
           ASSIGN aux_nrcpfcgc = STRING(craplju.nrcpfcgc,"99999999999999")
                  aux_nrcpfcgc = STRING(aux_nrcpfcgc,"xx.xxx.xxx/xxxx-xx").
    
    
        FIND crapcop WHERE crapcop.cdcooper = craplju.cdcoplib
                           NO-LOCK NO-ERROR.

        IF NOT AVAIL crapcop THEN
           DO: 
              ASSIGN par_cdcritic = 794.
              RETURN "NOK".
           END.
    
        FIND craprot WHERE craprot.cdoperac = craplju.cdoperac 
                           NO-LOCK NO-ERROR.

        IF NOT AVAIL craprot THEN
           DO: 
              ASSIGN par_dscritic = "Rotina nao cadastrada.".
              RETURN "NOK".
           END.

        FIND crapope WHERE crapope.cdcooper = craplju.cdcooper AND
                           crapope.cdoperad = craplju.cdopelib
                           NO-LOCK NO-ERROR.

        IF   AVAIL crapope THEN
             ASSIGN aux_nmoperad = crapope.nmoperad.
        ELSE
             ASSIGN aux_nmoperad = "".
      
        DISP STREAM str_1 aux_nrcpfcgc      
                          craplju.dtmvtolt 
                          craplju.nrdconta 
                          crapcop.nmrescop
                          craplju.dsjuslib
                          aux_nmoperad
                          WITH FRAME f_justificativa.

        DOWN STREAM str_1 WITH FRAME f_justificativa.

    END.

END PROCEDURE.


PROCEDURE consulta_vinculo:

  DEF INPUT PARAM par_cdcooper AS INT                         NO-UNDO.
  DEF INPUT PARAM par_cdagenci AS INT                         NO-UNDO.
  DEF INPUT PARAM par_nrdcaixa AS INT                         NO-UNDO.
  DEF INPUT PARAM par_idorigem AS INT                         NO-UNDO.
  DEF INPUT PARAM par_dtmvtolt AS DATE                        NO-UNDO.
  DEF INPUT PARAM par_cdoperad AS CHAR                        NO-UNDO.
  DEF INPUT PARAM par_nrcpfcgc AS DEC                         NO-UNDO.
  DEF INPUT PARAM par_nriniseq AS INT                         NO-UNDO.
  DEF INPUT PARAM par_nrregist AS INT                         NO-UNDO.
  
  DEF OUTPUT PARAM par_qtregist AS INT                        NO-UNDO.
  DEF OUTPUT PARAM par_nmdcampo AS CHAR                       NO-UNDO.
  DEF OUTPUT PARAM TABLE FOR tt-vinculo.
  DEF OUTPUT PARAM TABLE FOR tt-erro.

  DEF BUFFER b-crapttl1 FOR crapttl.
  DEF BUFFER b-crapass1 FOR crapass.
  DEF BUFFER b-crapjur1 FOR crapjur.
  DEF BUFFER b-gncdntj1 FOR gncdntj.

  DEF VAR aux_cdcritic AS INT                                 NO-UNDO.
  DEF VAR aux_dscritic AS CHAR                                NO-UNDO.
  DEF VAR aux_stsnrcal AS LOG                                 NO-UNDO.
  DEF VAR aux_inpessoa AS INT                                 NO-UNDO.
  DEF VAR h-b1wgen9999 AS HANDLE                              NO-UNDO.

  EMPTY TEMP-TABLE tt-erro.
  EMPTY TEMP-TABLE tt-vinculo.

  
  ASSIGN aux_cdcritic = 0
         aux_dscritic = ""
         aux_inpessoa = 0 
         aux_stsnrcal = FALSE.


  IF par_nrcpfcgc = 0 THEN
     DO:
        ASSIGN aux_cdcritic = 27.
          
        RUN gera_erro (INPUT par_cdcooper,        
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1, /*sequencia*/
                       INPUT aux_cdcritic,        
                       INPUT-OUTPUT aux_dscritic).
                                                
        RETURN "NOK". 

     END.

  IF NOT VALID-HANDLE(h-b1wgen9999) THEN
     RUN sistema/generico/procedures/b1wgen9999.p 
         PERSISTENT SET h-b1wgen9999.

  RUN valida-cpf-cnpj IN h-b1wgen9999(INPUT par_nrcpfcgc,
                                      OUTPUT aux_stsnrcal,
                                      OUTPUT aux_inpessoa).

  IF VALID-HANDLE(h-b1wgen9999) THEN
     DELETE PROCEDURE h-b1wgen9999.

  IF NOT aux_stsnrcal THEN
     DO: 
        ASSIGN aux_cdcritic = 27
               par_nmdcampo = "nrcpfcgc".
          
        RUN gera_erro (INPUT par_cdcooper,        
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1, /*sequencia*/
                       INPUT aux_cdcritic,        
                       INPUT-OUTPUT aux_dscritic).
                                                
        RETURN "NOK". 

     END.

  
  FOR EACH crapcop WHERE crapcop.cdcooper <> 3 NO-LOCK:

      
      /*Busca todas as contas (fisica/juridica) onde o cpf eh 1 titular */
      FOR EACH crapass FIELDS(cdcooper nrcpfcgc nmprimtl nrdconta)
                       WHERE crapass.cdcooper = crapcop.cdcooper AND
                             crapass.nrcpfcgc = par_nrcpfcgc
                             NO-LOCK:

          CREATE tt-vinculo.
                
          ASSIGN tt-vinculo.cdcooper = crapass.cdcooper
                 tt-vinculo.nmrescop = crapcop.nmrescop
                 tt-vinculo.nrdconta = crapass.nrdconta
                 tt-vinculo.nmprimtl = SUBSTR(crapass.nmprimtl,1,18)
                 tt-vinculo.tpdovinc = "1º Titular"
                 par_qtregist = par_qtregist + 1.
      
      END.


      /*Busca todas contas onde o cpf eh 2 titular */
      FOR EACH crapttl FIELDS(cdcooper nrcpfcgc nmextttl idseqttl nrcpfcgc nrdconta)
                       WHERE crapttl.cdcooper = crapcop.cdcooper AND
                             crapttl.nrcpfcgc = par_nrcpfcgc     AND
                             crapttl.idseqttl > 1
                             NO-LOCK,

          FIRST b-crapttl1 WHERE b-crapttl1.cdcooper = crapttl.cdcooper AND
                                 b-crapttl1.nrdconta = crapttl.nrdconta AND
                                 b-crapttl1.idseqttl = 1
                                 NO-LOCK:
              
                CREATE tt-vinculo.
                      
                ASSIGN tt-vinculo.cdcooper = crapttl.cdcooper
                       tt-vinculo.nmrescop = crapcop.nmrescop
                       tt-vinculo.nrdconta = crapttl.nrdconta
                       tt-vinculo.nmprimtl = SUBSTR(crapttl.nmextttl,1,18)
                       tt-vinculo.nrctavin = b-crapttl1.nrdconta
                       tt-vinculo.nmctavin = SUBSTR(b-crapttl1.nmextttl,1,18)
                       tt-vinculo.nrcpfvin = STRING((STRING(b-crapttl1.nrcpfcgc,
                                             "99999999999")),"xxx.xxx.xxx-xx")
                       tt-vinculo.tpdovinc = (IF crapttl.idseqttl = 2 THEN 
                                                 "2º Titular"
                                              ELSE IF crapttl.idseqttl = 3 THEN
                                                      "3º Titular"
                                                  ELSE "4º Titular")
                       par_qtregist = par_qtregist + 1.

      END.
      

       /*Busca todas as contas onde o cpf eh avalista*/
      FOR EACH crapass WHERE crapass.cdcooper = crapcop.cdcooper AND
                             crapass.nrcpfcgc = par_nrcpfcgc
                             NO-LOCK:

          FOR EACH crapavl WHERE crapavl.cdcooper = crapass.cdcooper AND
                                 crapavl.nrctaavd = crapass.nrdconta AND
                                 crapavl.tpctrato = 1 /*Avalista*/
                                 NO-LOCK:
          
              FIND b-crapass1 WHERE b-crapass1.cdcooper = crapavl.cdcooper AND
                                    b-crapass1.nrdconta = crapavl.nrdconta 
                                    NO-LOCK NO-ERROR.
          
              IF AVAIL b-crapass1 THEN
                 DO:
                    CREATE tt-vinculo.
                          
                    ASSIGN tt-vinculo.cdcooper = crapass.cdcooper 
                           tt-vinculo.nmrescop = crapcop.nmrescop
                           tt-vinculo.nrdconta = crapass.nrdconta
                           tt-vinculo.nmprimtl = SUBSTR(crapass.nmprimtl,1,18)
                           tt-vinculo.nrctavin = b-crapass1.nrdconta
                           tt-vinculo.nmctavin = SUBSTR(b-crapass1.nmprimtl,1,18)
                           tt-vinculo.nrcpfvin = (IF b-crapass1.inpessoa = 1 THEN 
                                                     STRING((STRING(
                                                     b-crapass1.nrcpfcgc,
                                                     "99999999999")),
                                                     "xxx.xxx.xxx-xx")
                                                  ELSE
                                                     STRING((STRING(
                                                     b-crapass1.nrcpfcgc,
                                                     "99999999999999")),
                                                     "xx.xxx.xxx/xxxx-xx"))
                           tt-vinculo.tpdovinc = "Avalista"
                           par_qtregist = par_qtregist + 1.
          
                 END.
                                 
          END.

      END.

      /*Busca todas as contas onde o cpf informado eh avalista*/
      FOR EACH crapavt FIELDS(cdcooper nrcpfcgc tpctrato nrdctato nrdconta nmdavali)
                       WHERE crapavt.cdcooper = crapcop.cdcooper AND
                             crapavt.nrcpfcgc = par_nrcpfcgc     AND
                             crapavt.tpctrato = 1 /*Avalista*/
                             NO-LOCK,

          FIRST crapass WHERE crapass.cdcooper = crapavt.cdcooper AND
                              crapass.nrdconta = crapavt.nrdconta
                              NO-LOCK:

                CREATE tt-vinculo.
                          
                ASSIGN tt-vinculo.cdcooper = crapavt.cdcooper
                       tt-vinculo.nmrescop = crapcop.nmrescop
                       tt-vinculo.nmprimtl = SUBSTR(crapavt.nmdavali,1,18)
                       tt-vinculo.nrctavin = crapass.nrdconta 
                       tt-vinculo.nmctavin = SUBSTR(crapass.nmprimtl ,1,18)
                       tt-vinculo.nrcpfvin = (IF crapass.inpessoa = 1 THEN 
                                                 STRING((STRING(crapass.nrcpfcgc,
                                                 "99999999999")),"xxx.xxx.xxx-xx")
                                              ELSE
                                                 STRING((STRING(crapass.nrcpfcgc,
                                                    "99999999999999")),
                                                 "xx.xxx.xxx/xxxx-xx"))
                       tt-vinculo.tpdovinc = "Avalista"
                       par_qtregist = par_qtregist + 1.

      END.

      /*Apenas para pessoa fisica*/
      IF aux_inpessoa = 1 THEN
         DO:
            /*Busca todas as contas onde o cpf informado eh rep.procurador*/
            FOR EACH crapavt FIELDS(cdcooper nrcpfcgc tpctrato nrdctato nrdconta nmdavali)
                             WHERE crapavt.cdcooper = crapcop.cdcooper AND
                                   crapavt.nrcpfcgc = par_nrcpfcgc     AND
                                   crapavt.tpctrato = 6 /*Rep.Procurador*/
                                   NO-LOCK:
            
                IF crapavt.nrdctato <> 0 THEN
                   DO:
                      FIND crapass WHERE crapass.cdcooper = crapavt.cdcooper AND
                                         crapass.nrdconta = crapavt.nrdctato
                                         NO-LOCK NO-ERROR.

                      IF NOT AVAIL crapass THEN
                         DO:
                            ASSIGN aux_cdcritic = 9.
                            
                            RUN gera_erro (INPUT par_cdcooper,        
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT 1, /*sequencia*/
                                           INPUT aux_cdcritic,        
                                           INPUT-OUTPUT aux_dscritic).
                                                                    
                            RETURN "NOK". 

                         END.
                      

                      CREATE tt-vinculo.
                                
                      ASSIGN tt-vinculo.cdcooper = crapass.cdcooper 
                             tt-vinculo.nmrescop = crapcop.nmrescop
                             tt-vinculo.nrdconta = crapass.nrdconta
                             tt-vinculo.nmprimtl = SUBSTR(crapass.nmprimtl,1,18).
                             
            
                      FIND crapass WHERE crapass.cdcooper = crapavt.cdcooper AND
                                         crapass.nrdconta = crapavt.nrdconta
                                         NO-LOCK NO-ERROR.

                      IF NOT AVAIL crapass THEN
                         DO:
                            ASSIGN aux_cdcritic = 9.
                            
                            RUN gera_erro (INPUT par_cdcooper,        
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT 1, /*sequencia*/
                                           INPUT aux_cdcritic,        
                                           INPUT-OUTPUT aux_dscritic).
                                                                    
                            RETURN "NOK". 

                         END.
            
                      ASSIGN tt-vinculo.nrctavin = crapass.nrdconta
                             tt-vinculo.nmctavin = SUBSTR(crapass.nmprimtl,1,18)
                             tt-vinculo.nrcpfvin = (IF crapass.inpessoa = 1 THEN 
                                                     STRING((STRING(
                                                     crapass.nrcpfcgc,
                                                     "99999999999")),
                                                     "xxx.xxx.xxx-xx")
                                                  ELSE
                                                    STRING((STRING(
                                                    crapass.nrcpfcgc,
                                                    "99999999999999")),
                                                    "xx.xxx.xxx/xxxx-xx"))
                             tt-vinculo.tpdovinc = "Rep/Procurador"
                             par_qtregist = par_qtregist + 1.
                     
                   END.
                ELSE
                   DO:
                      FIND crapass WHERE crapass.cdcooper = crapavt.cdcooper AND
                                         crapass.nrdconta = crapavt.nrdconta
                                         NO-LOCK NO-ERROR.

                      IF NOT AVAIL crapass THEN
                         DO:
                            ASSIGN aux_cdcritic = 9.
                            
                            RUN gera_erro (INPUT par_cdcooper,        
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT 1, /*sequencia*/
                                           INPUT aux_cdcritic,        
                                           INPUT-OUTPUT aux_dscritic).
                                                                    
                            RETURN "NOK". 

                         END.

                      
                      CREATE tt-vinculo.
                                
                      ASSIGN tt-vinculo.cdcooper = crapavt.cdcooper 
                             tt-vinculo.nmrescop = crapcop.nmrescop
                             tt-vinculo.nrdconta = crapavt.nrdctato
                             tt-vinculo.nmprimtl = SUBSTR(crapavt.nmdavali,1,18)
                             tt-vinculo.nrctavin = crapass.nrdconta
                             tt-vinculo.nmctavin = SUBSTR(crapass.nmprimtl,1,18)
                             tt-vinculo.nrcpfvin = (IF crapass.inpessoa = 1 THEN 
                                                     STRING((STRING(
                                                     crapass.nrcpfcgc,
                                                     "99999999999")),
                                                     "xxx.xxx.xxx-xx")
                                                  ELSE
                                                    STRING((STRING(
                                                    crapass.nrcpfcgc,
                                                    "99999999999999")),
                                                    "xx.xxx.xxx/xxxx-xx"))
                             tt-vinculo.tpdovinc = "Rep/Procurador"
                             par_qtregist = par_qtregist + 1.


                   END.
            
            END.

            /*Busca todas as contas onde o cpf eh responsavel legal*/
            FOR EACH crapcrl FIELDS(cdcooper nrcpfcgc nrdconta nrctamen nmrespon)
                             WHERE crapcrl.cdcooper = crapcop.cdcooper AND
                                   crapcrl.nrcpfcgc = par_nrcpfcgc
                                   NO-LOCK:
            
                IF crapcrl.nrdconta <> 0 THEN
                   DO:
                      FIND crapass WHERE crapass.cdcooper = crapcrl.cdcooper AND
                                         crapass.nrdconta = crapcrl.nrdconta
                                         NO-LOCK NO-ERROR.

                      IF NOT AVAIL crapass THEN
                         DO:
                            ASSIGN aux_cdcritic = 9.
                            
                            RUN gera_erro (INPUT par_cdcooper,        
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT 1, /*sequencia*/
                                           INPUT aux_cdcritic,        
                                           INPUT-OUTPUT aux_dscritic).
                                                                    
                            RETURN "NOK". 

                         END.

                      CREATE tt-vinculo.
                                
                      ASSIGN tt-vinculo.cdcooper = crapass.cdcooper 
                             tt-vinculo.nmrescop = crapcop.nmrescop
                             tt-vinculo.nrdconta = crapass.nrdconta
                             tt-vinculo.nmprimtl = SUBSTR(crapass.nmprimtl,1,18).
            
                   END.
                ELSE
                   DO:
                      CREATE tt-vinculo.
                                
                      ASSIGN tt-vinculo.cdcooper = crapcrl.cdcooper 
                             tt-vinculo.nmrescop = crapcop.nmrescop
                             tt-vinculo.nrdconta = crapcrl.nrdconta
                             tt-vinculo.nmprimtl = SUBSTR(crapcrl.nmrespon,1,18).
                      
                   END.

                IF crapcrl.nrctamen <> 0 THEN
                   DO:
                      FIND crapass WHERE crapass.cdcooper = crapcrl.cdcooper AND
                                         crapass.nrdconta = crapcrl.nrctamen
                                         NO-LOCK NO-ERROR.

                      IF NOT AVAIL crapass THEN
                         DO:
                            ASSIGN aux_cdcritic = 9.
                            
                            RUN gera_erro (INPUT par_cdcooper,        
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT 1, /*sequencia*/
                                           INPUT aux_cdcritic,        
                                           INPUT-OUTPUT aux_dscritic).
                                                                    
                            RETURN "NOK". 

                         END.

                      ASSIGN tt-vinculo.nrctavin = crapass.nrdconta
                             tt-vinculo.nmctavin = SUBSTR(crapass.nmprimtl,1,18)
                             tt-vinculo.nrcpfvin = (IF crapass.inpessoa = 1 THEN 
                                                     STRING((STRING(
                                                     crapass.nrcpfcgc,
                                                     "99999999999")),
                                                     "xxx.xxx.xxx-xx")
                                                  ELSE
                                                    STRING((STRING(
                                                    crapass.nrcpfcgc,
                                                    "99999999999999")),
                                                    "xx.xxx.xxx/xxxx-xx"))
                             tt-vinculo.tpdovinc = "Resp. Legal"
                             par_qtregist = par_qtregist + 1.

                   END.
                ELSE
                   DO:
                      FIND FIRST crapavt 
                           WHERE crapavt.cdcooper = crapcrl.cdcooper AND
                                 crapavt.tpctrato = 6 /*Rep.Proc*/   AND
                                 crapavt.nrdctato = crapcrl.nrctamen
                                 NO-LOCK NO-ERROR.

                      IF NOT AVAIL crapavt THEN
                         DO:
                            ASSIGN aux_dscritic = "Avalista nao encontrado.".
                            
                            RUN gera_erro (INPUT par_cdcooper,        
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT 1, /*sequencia*/
                                           INPUT aux_cdcritic,        
                                           INPUT-OUTPUT aux_dscritic).
                                                                    
                            RETURN "NOK". 

                         END.
                      
                      IF NOT VALID-HANDLE(h-b1wgen9999) THEN
                         RUN sistema/generico/procedures/b1wgen9999.p 
                             PERSISTENT SET h-b1wgen9999.
                    
                      RUN valida-cpf-cnpj IN h-b1wgen9999(INPUT par_nrcpfcgc,
                                                          OUTPUT aux_stsnrcal,
                                                          OUTPUT aux_inpessoa).
                    
                      IF VALID-HANDLE(h-b1wgen9999) THEN
                         DELETE PROCEDURE h-b1wgen9999.
                      
                      ASSIGN tt-vinculo.nrctavin = crapavt.nrdctato
                             tt-vinculo.nmctavin = SUBSTR(crapavt.nmdavali,1,18)
                             tt-vinculo.nrcpfvin = (IF aux_inpessoa = 1 THEN 
                                                     STRING((STRING(
                                                     crapavt.nrcpfcgc,
                                                     "99999999999")),
                                                     "xxx.xxx.xxx-xx")
                                                  ELSE
                                                    STRING((STRING(
                                                    crapavt.nrcpfcgc,
                                                    "99999999999999")),
                                                    "xx.xxx.xxx/xxxx-xx"))
                             tt-vinculo.tpdovinc = "Resp. Legal"
                             par_qtregist = par_qtregist + 1.

                   END.

            END.

         END.

      
      /* Busca todas empresas onde o cpf seja socio */
      FOR EACH crapepa WHERE crapepa.cdcooper = crapcop.cdcooper
                             NO-LOCK,
     
          FIRST crapass WHERE crapass.cdcooper = crapepa.cdcooper AND
                              crapass.nrdconta = crapepa.nrdconta 
                              NO-LOCK:
         
          FIND crapjur WHERE crapjur.cdcooper = crapass.cdcooper AND   
                             crapjur.nrdconta = crapass.nrdconta
                             NO-LOCK NO-ERROR.
          
          IF AVAIL crapjur THEN
             DO:
                FIND b-crapjur1 
                    WHERE b-crapjur1.cdcooper = crapepa.cdcooper AND
                          b-crapjur1.nrdconta = crapepa.nrctasoc 
                          NO-LOCK NO-ERROR.
                
                IF AVAIL b-crapjur1 THEN
                   DO:
                      FIND b-crapass1 
                          WHERE b-crapass1.cdcooper = b-crapjur1.cdcooper AND
                                b-crapass1.nrdconta = b-crapjur1.nrdconta AND
                                b-crapass1.nrcpfcgc = par_nrcpfcgc
                                NO-LOCK NO-ERROR.

                      IF AVAIL b-crapass1 THEN
                         DO:
                             CREATE tt-vinculo.
                   
                             ASSIGN tt-vinculo.cdcooper = b-crapass1.cdcooper 
                                    tt-vinculo.nmrescop = crapcop.nmrescop
                                    tt-vinculo.nrdconta = b-crapass1.nrdconta
                                    tt-vinculo.nmprimtl = SUBSTR(b-crapass1.nmprimtl,1,18)
                                    tt-vinculo.nrctavin = crapass.nrdconta
                                    tt-vinculo.nmctavin = SUBSTR(crapass.nmprimtl,1,18)
                                    tt-vinculo.nrcpfvin = (IF crapass.inpessoa = 1 THEN 
                                               STRING((STRING(
                                               crapass.nrcpfcgc,
                                               "99999999999")),
                                               "xxx.xxx.xxx-xx")
                                            ELSE
                                              STRING((STRING(
                                              crapass.nrcpfcgc,
                                              "99999999999999")),
                                              "xx.xxx.xxx/xxxx-xx"))
                                    tt-vinculo.tpdovinc = "Part. Societaria"
                                    par_qtregist = par_qtregist + 1. 

                         END.
                
                   END.

             END.

      END.
  
  END.  

  RETURN "OK".

END PROCEDURE.


