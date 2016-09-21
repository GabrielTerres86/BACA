
/* ............................................................................

   Programa: sistema/generico/procedures/b1wgen0110.p
   Autor  : Adriano
   Data   : Agosto/2011                      Ultima alteracao: 05/08/2014

   Dados referentes ao programa:

   Objetivo  : BO referente ao envio de e-mail do Cadastro Restritivo.
   
   Alteracoes: 04/02/2013 - Ajustes referente ao projeto Cadastro Restritivo
                            (Adriano).
                            
               08/06/2013 - Ajuste consulta CRAPCOP na alerta_fraude.
                            (Irlan)
               
               10/06/2013 - Alteração função enviar_email_completo p/ nova 
                            versão (Jean Michel).
                            
               26/06/2013 - FIND FIRST na crapttl para verificar se existe
                            mais de um titular para o mesmo CPF. Critica 958.
                            (Fabricio)
                            
               06/02/2014 - Alterado envio dos parametros das procedures                             
                            liberar_cad_restritivo e fget_existe_justificativa
                            para enviarem o numero da conta da tt-dados.nrdconta
                            ao inves da conta parametrizada par_nrdconta. 
                            (Reinert)
                            
               05/08/2014 - Alteração da Nomeclatura para PA (Vanessa).
..............................................................................*/

{ sistema/generico/includes/b1wgen0110tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }


DEF VAR aux_dsorigem AS CHAR                                       NO-UNDO.
DEF VAR h-b1wgen0011 AS HANDLE                                     NO-UNDO.


FUNCTION fget_existe_risco_cpfcnpj RETURNS LOGICAL 
        (INPUT par_nrcpfcgc AS DEC,
         OUTPUT par_nmpessoa AS CHAR) FORWARD.
                                        
FUNCTION fget_existe_justificativa RETURNS LOGICAL 
        (INPUT par_cdcooper AS INT,
         INPUT par_cdagenci AS INT,
         INPUT par_cdoperad AS CHAR,
         INPUT par_dtmvtolt AS DATE,
         INPUT par_nrdconta AS INT,
         INPUT par_nrcpfcgc AS DEC,
         INPUT par_cdoperac AS INT,
         INPUT par_cdpactra AS INT) FORWARD.

PROCEDURE envia_email_alerta:

    DEF INPUT PARAM par_cdcooper AS INT                         NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INT                         NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INT                         NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                        NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                        NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE FORMAT "99/99/9999"    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INT                         NO-UNDO.
    DEF INPUT PARAM par_nrcpfcgc LIKE crapass.nrcpfcgc          NO-UNDO.
    DEF INPUT PARAM par_nrdconta LIKE crapass.nrdconta          NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INT                         NO-UNDO.
    DEF INPUT PARAM par_nmprimtl LIKE crapass.nmprimtl          NO-UNDO.
    DEF INPUT PARAM par_nmpessoa LIKE crapcrt.nmpessoa          NO-UNDO.
    DEF INPUT PARAM par_cdoperac AS INT                         NO-UNDO.
    DEF INPUT PARAM par_dsoperac AS CHAR                        NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_cdagenci LIKE crapage.cdagenci                  NO-UNDO.
    DEF VAR aux_nmextage LIKE crapage.nmextage                  NO-UNDO.
    DEF VAR aux_lsemails AS CHAR                                NO-UNDO.
    DEF VAR aux_conteudo AS CHAR                                NO-UNDO.
    DEF VAR aux_nrdrowid AS ROWID                               NO-UNDO.
    DEF VAR aux_cdcritic AS INT                                 NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                NO-UNDO.
    DEF VAR aux_nmoperad AS CHAR                                NO-UNDO.
    DEF VAR aux_inpessoa AS INT                                 NO-UNDO.
    DEF VAR aux_stsnrcal AS LOG                                 NO-UNDO.
    DEF VAR aux_nrcpfcgc AS CHAR                                NO-UNDO.
    DEF VAR aux_contador AS INT                                 NO-UNDO.
    DEF VAR aux_emailenv AS CHAR                                NO-UNDO.
    
    DEF VAR h-b1wgen9999 AS HANDLE                              NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdagenci = 0
           aux_nmextage = ""
           aux_cdcritic = 0
           aux_dscritic = ""
           aux_lsemails = ""
           aux_conteudo = ""
           aux_nrdrowid = ?
           aux_nmoperad = ""
           aux_inpessoa = 0
           aux_stsnrcal = FALSE
           aux_nrcpfcgc = "".

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

    IF AVAIL crapope THEN
       DO:
          ASSIGN aux_nmoperad = crapope.nmoperad. 

          FIND crapage WHERE crapage.cdcooper = crapope.cdcooper AND 
                             crapage.cdagenci = crapope.cdpactra
                        NO-LOCK NO-ERROR.

          IF AVAIL crapage THEN
             ASSIGN aux_cdagenci = crapage.cdagenci
                    aux_nmextage = crapage.nmextage.
          ELSE
            DO:
               ASSIGN aux_cdcritic = 15.
                        
               RUN gera_erro (INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT 1, /*sequencia*/
                              INPUT aux_cdcritic,
                              INPUT-OUTPUT aux_dscritic).
        
               RETURN "NOK".
        
          END.
        
       END.

    FIND craptab WHERE craptab.cdcooper = par_cdcooper         AND
                       craptab.nmsistem = "CRED"               AND
                       craptab.tptabela = "GENERI"             AND
                       craptab.cdempres = 0                    AND
                       craptab.tpregist = 1                    AND
                       craptab.cdacesso = "EMAILCADRESTRITIVO"
                       NO-LOCK NO-ERROR.
    
    IF NOT AVAIL craptab THEN
       DO:
          ASSIGN aux_cdcritic = 812.

          RUN gera_erro (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1, /*sequencia*/
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic).

          RETURN "NOK".

       END.
    ELSE
       ASSIGN aux_lsemails = craptab.dstextab.

    FIND craprot WHERE craprot.cdoperac = par_cdoperac
                       NO-LOCK NO-ERROR.

    IF NOT AVAIL craptab THEN
       DO:
          ASSIGN aux_dscritic = "Rotina nao cadastrada.".

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
          ASSIGN aux_cdcritic = 27.
                 
          RUN gera_erro (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1, /*sequencia*/
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic).

          RETURN "NOK".
    
       END.

    IF aux_inpessoa = 1 THEN
       ASSIGN aux_nrcpfcgc = STRING(crapcrt.nrcpfcgc,"99999999999")
              aux_nrcpfcgc = STRING(aux_nrcpfcgc,"xxx.xxx.xxx-xx").
    ELSE
       ASSIGN aux_nrcpfcgc = STRING(crapcrt.nrcpfcgc,"99999999999999")
              aux_nrcpfcgc = STRING(aux_nrcpfcgc,"xx.xxx.xxx/xxxx-xx").


    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_conteudo = " - Cooperativa.............: " + crapcop.nmrescop  +
                          ".\n" + " - PA........................: "          +
                          STRING(aux_cdagenci) + " - " + aux_nmextage + ".\n" +
                          " - Operador.................: " + par_cdoperad     +
                          " - " + aux_nmoperad  + ".\n"                       +
                         (IF par_nrdconta = 0 THEN 
                             " - O CPF/CNPJ " + aux_nrcpfcgc +
                             " esta no cadastro restritivo. \n"
                          ELSE
                          IF aux_inpessoa = 1 THEN
                             " - O " + STRING(par_idseqttl) + "º titular "    +
                             "da conta " + STRING(par_nrdconta,"zzzz,zzz,9")  +
                             " - CPF/CNPJ " + aux_nrcpfcgc + " esta no "      +
                             "cadastro restritivo.\n"
                          ELSE
                             " - A conta " + STRING(par_nrdconta,"zzzz,zzz,9")+
                             " - CPF/CNPJ " + aux_nrcpfcgc + " esta no "      +
                             "cadastro restritivo.\n")                        +
                          " - Operacao realizada..: " + par_dsoperac + ".\n"  +
                          " - Rotina......................: "                 +
                          STRING(craprot.cdoperac) + " - "                    +
                          craprot.dsoperac + ".\n"                            +
                          " - Nome/Cooperado....: " + par_nmprimtl + ".\n"    +
                          " - Nome/Cad.Restritivo: " + par_nmpessoa + ".".   


    IF NOT VALID-HANDLE(h-b1wgen0011) THEN
       RUN sistema/generico/procedures/b1wgen0011.p 
           PERSISTENT SET h-b1wgen0011.

    IF NOT VALID-HANDLE(h-b1wgen0011)  THEN
       DO:
           ASSIGN aux_cdcritic = 0
                  aux_dscritic = "Handle invalido para BO b1wgen0011.".
                              
           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1, /*sequencia*/
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
       
           RETURN "NOK".

       END.      
    

    RUN enviar_email_completo IN h-b1wgen0011 (INPUT par_cdcooper,
                                               INPUT par_nmdatela,
                                               INPUT crapcop.dsdemail,
                                               INPUT aux_lsemails,
                                               INPUT (crapcop.nmrescop + " - " +
                                                      "CADASTRO RESTRITIVO!"),
                                               INPUT "controles.internos@cecred.coop.br",
                                               INPUT "",
                                               INPUT aux_conteudo,
                                               INPUT FALSE).
                    
    IF VALID-HANDLE(h-b1wgen0011) THEN
       DELETE PROCEDURE h-b1wgen0011.

    
    DO aux_contador = 1 TO NUM-ENTRIES(aux_lsemails):

       IF ENTRY(aux_contador,aux_lsemails) <> "" THEN             
          IF NUM-ENTRIES(aux_emailenv) = 0 THEN
             ASSIGN aux_emailenv = aux_emailenv                     + 
                                   ENTRY(aux_contador,aux_lsemails).
          ELSE
             ASSIGN aux_emailenv = aux_emailenv + ", "              +
                                   ENTRY(aux_contador,aux_lsemails).


    END.

    UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") +
                " " + STRING(TIME,"HH:MM:SS") + "' --> '"         +
                "Operador " + par_cdoperad + ", operacao: "       +
                par_dsoperac + " rotina: " + craprot.dsoperac     +
                ". Enviado e-mail para "                          + 
                (IF aux_emailenv = "" THEN
                    "nenhum destinatario"
                 ELSE
                    aux_emailenv)                                 +
                ". >> /usr/coop/" + TRIM(crapcop.dsdircop)        + 
                "/log/alerta.log").

      
    RETURN "OK".


END PROCEDURE.



PROCEDURE alerta_fraude:

    DEF INPUT PARAM par_cdcooper AS INT                         NO-UNDO. 
    DEF INPUT PARAM par_cdagenci AS INT                         NO-UNDO. 
    DEF INPUT PARAM par_nrdcaixa AS INT                         NO-UNDO. 
    DEF INPUT PARAM par_cdoperad AS CHAR                        NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                        NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE FORMAT "99/99/9999"    NO-UNDO. 
    DEF INPUT PARAM par_idorigem AS INT                         NO-UNDO. 
    DEF INPUT PARAM par_nrcpfcgc LIKE crapass.nrcpfcgc          NO-UNDO.
    DEF INPUT PARAM par_nrdconta LIKE crapass.nrdconta          NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INT                         NO-UNDO.
    DEF INPUT PARAM par_bloqueia AS LOG                         NO-UNDO.
    DEF INPUT PARAM par_cdoperac AS INT                         NO-UNDO.
    DEF INPUT PARAM par_dsoperac AS CHAR                        NO-UNDO.
                                                                
    DEF OUTPUT PARAM TABLE FOR tt-erro.                         
                                                                
    DEF VAR aux_nmpessoa LIKE crapcrt.nmpessoa                  NO-UNDO.
    DEF VAR aux_nrdrowid AS ROWID                               NO-UNDO.
    DEF VAR aux_cdcritic AS INT                                 NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                NO-UNDO.
    DEF VAR aux_cdpactra AS INT                                 NO-UNDO.
    DEF VAR aux_blqopera AS LOG                                 NO-UNDO.
    DEF VAR aux_temjusti AS LOG                                 NO-UNDO.
    DEF VAR aux_inpessoa AS INT                                 NO-UNDO.
    DEF VAR aux_stsnrcal AS LOG                                 NO-UNDO.

    DEF VAR h-b1wgen0117 AS HANDLE                              NO-UNDO.
    DEF VAR h-b1wgen9999 AS HANDLE                              NO-UNDO.
                                                                
    DEF VAR aux_nmdcampo AS CHAR                                NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-dados.

    DEF BUFFER b-crapttl1 FOR crapttl.
    DEF BUFFER b-crapass1 FOR crapass.

    ASSIGN aux_nmpessoa = ""
           aux_cdcritic = 0
           aux_dscritic = ""
           aux_nrdrowid = ?
           aux_cdpactra = 0
           aux_blqopera = FALSE
           aux_temjusti = FALSE
           aux_nmdcampo = "".
    /*
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
     */

    FIND crapope WHERE crapope.cdcooper = par_cdcooper AND
                       crapope.cdoperad = par_cdoperad
                       NO-LOCK NO-ERROR.

    IF AVAIL crapope THEN
       DO:
        FIND crapage WHERE crapage.cdcooper = crapope.cdcooper AND 
                           crapage.cdagenci = crapope.cdpactra
                           NO-LOCK NO-ERROR.
    
        IF AVAIL crapage THEN
           ASSIGN aux_cdpactra = crapage.cdagenci.
        ELSE
           DO:
              ASSIGN aux_cdcritic = 15.
                     
              RUN gera_erro (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 1, /*sequencia*/
                             INPUT aux_cdcritic,
                             INPUT-OUTPUT aux_dscritic).
    
              RETURN "NOK".
    
           END.
    END.
    
    IF par_nrdconta = 0 AND
       par_nrcpfcgc = 0 THEN
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
          ASSIGN aux_cdcritic = 27.
                 
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
          IF aux_inpessoa = 1 THEN  
             DO:
                FIND crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                                   crapttl.nrcpfcgc = par_nrcpfcgc AND
                                   crapttl.nrdconta = par_nrdconta 
                                   NO-LOCK NO-ERROR.

                IF NOT AVAIL crapttl THEN
                   DO:
                      FIND FIRST crapttl WHERE crapttl.cdcooper = par_cdcooper
                                           AND crapttl.nrcpfcgc = par_nrcpfcgc
                                           AND crapttl.nrdconta = par_nrdconta
                                           NO-LOCK NO-ERROR.

                      IF AVAIL crapttl THEN
                      DO:
                          ASSIGN aux_cdcritic = 958.
                 
                          RUN gera_erro (INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT 1, /*sequencia*/
                                         INPUT aux_cdcritic,
                                         INPUT-OUTPUT aux_dscritic).
                   
                          RETURN "NOK".
                      END.

                      ASSIGN aux_cdcritic = 9.
                 
                      RUN gera_erro (INPUT par_cdcooper,
                                     INPUT par_cdagenci,
                                     INPUT par_nrdcaixa,
                                     INPUT 1, /*sequencia*/
                                     INPUT aux_cdcritic,
                                     INPUT-OUTPUT aux_dscritic).
                   
                      RETURN "NOK".

                   END.
                
                /* Busca todos os titulares da conta em questao */
                FOR EACH b-crapttl1 
                    WHERE b-crapttl1.cdcooper = crapttl.cdcooper AND
                          b-crapttl1.nrdconta = crapttl.nrdconta
                          NO-LOCK:

                    CREATE tt-dados.

                    ASSIGN tt-dados.nrdconta = b-crapttl1.nrdconta
                           tt-dados.nrcpfcgc = b-crapttl1.nrcpfcgc
                           tt-dados.idseqttl = b-crapttl1.idseqttl
                           tt-dados.nmextttl = b-crapttl1.nmextttl.

                END.

                /* Busca todos os responsavel legal */
                FOR EACH crapcrl WHERE crapcrl.cdcooper = crapttl.cdcooper AND
                                       crapcrl.nrctamen = crapttl.nrdconta AND
                                       crapcrl.idseqmen = crapttl.idseqttl
                                       NO-LOCK:

                    CREATE tt-dados.
                    
                    IF crapcrl.nrdconta <> 0 THEN
                       DO:
                          FIND b-crapass1 
                               WHERE b-crapass1.cdcooper = crapcrl.cdcooper AND
                                     b-crapass1.nrdconta = crapcrl.nrdconta
                                     NO-LOCK NO-ERROR.
                            
                          IF NOT AVAIL b-crapass1 THEN
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

                          ASSIGN tt-dados.nrdconta = b-crapass1.nrdconta
                                 tt-dados.nrcpfcgc = b-crapass1.nrcpfcgc
                                 tt-dados.idseqttl = 1
                                 tt-dados.nmextttl = b-crapass1.nmprimtl.

                       END.
                    ELSE
                       ASSIGN tt-dados.nrdconta = crapcrl.nrdconta
                              tt-dados.nrcpfcgc = crapcrl.nrcpfcgc
                              tt-dados.nmextttl = crapcrl.nmrespon.

                END.

                /* Busca todos rep/procuradores  */
                FOR EACH crapavt WHERE crapavt.cdcooper = crapttl.cdcooper AND
                                       crapavt.tpctrato = 6                AND
                                       crapavt.nrdconta = crapttl.nrdconta AND
                                       crapavt.nrctremp = crapttl.idseqttl
                                       NO-LOCK:

                    CREATE tt-dados.

                    IF crapavt.nrdctato <> 0 THEN
                       DO:
                          FIND b-crapass1
                               WHERE b-crapass1.cdcooper = crapavt.cdcooper AND
                                     b-crapass1.nrdconta = crapavt.nrdctato
                                     NO-LOCK NO-ERROR.
                            
                          IF NOT AVAIL b-crapass1 THEN
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

                          ASSIGN tt-dados.nrdconta = b-crapass1.nrdconta
                                 tt-dados.nrcpfcgc = b-crapass1.nrcpfcgc
                                 tt-dados.idseqttl = 1
                                 tt-dados.nmextttl = b-crapass1.nmprimtl.

                       END.
                    ELSE
                       ASSIGN tt-dados.nrdconta = crapavt.nrdctato
                              tt-dados.nrcpfcgc = crapavt.nrcpfcgc
                              tt-dados.nmextttl = crapavt.nmdavali.

                END.

             END.
          ELSE
             DO:
                FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                   crapass.nrdconta = par_nrdconta
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

                CREATE tt-dados.

                ASSIGN tt-dados.nrdconta = crapass.nrdconta
                       tt-dados.nrcpfcgc = crapass.nrcpfcgc
                       tt-dados.idseqttl = 1 
                       tt-dados.nmextttl = crapass.nmprimtl.

                /* Busca todos rep/procuradores  */
                FOR EACH crapavt WHERE crapavt.cdcooper = crapass.cdcooper AND
                                       crapavt.nrdconta = crapass.nrdconta AND
                                       crapavt.tpctrato = 6
                                       NO-LOCK:

                    CREATE tt-dados.

                    IF crapavt.nrdctato <> 0 THEN
                       DO:
                          FIND b-crapass1
                               WHERE b-crapass1.cdcooper = crapavt.cdcooper AND
                                     b-crapass1.nrdconta = crapavt.nrdctato
                                     NO-LOCK NO-ERROR.
                            
                          IF NOT AVAIL b-crapass1 THEN
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

                          ASSIGN tt-dados.nrdconta = b-crapass1.nrdconta
                                 tt-dados.nrcpfcgc = b-crapass1.nrcpfcgc
                                 tt-dados.idseqttl = 1
                                 tt-dados.nmextttl = b-crapass1.nmprimtl.

                       END.
                    ELSE
                       ASSIGN tt-dados.nrdconta = crapavt.nrdctato
                              tt-dados.nrcpfcgc = crapavt.nrcpfcgc
                              tt-dados.nmextttl = crapavt.nmdavali.

                END.

                /* Busca todas empresas participantes */
                FOR EACH crapepa WHERE crapepa.cdcooper = crapass.cdcooper AND
                                       crapepa.nrdconta = crapass.nrdconta
                                       NO-LOCK:

                    CREATE tt-dados.

                    IF crapepa.nrctasoc <> 0 THEN
                       DO:
                          FIND b-crapass1
                               WHERE b-crapass1.cdcooper = crapepa.cdcooper AND
                                     b-crapass1.nrdconta = crapepa.nrctasoc
                                     NO-LOCK NO-ERROR.
                            
                          IF NOT AVAIL b-crapass1 THEN
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

                          ASSIGN tt-dados.nrdconta = b-crapass1.nrdconta
                                 tt-dados.nrcpfcgc = b-crapass1.nrcpfcgc
                                 tt-dados.idseqttl = 1
                                 tt-dados.nmextttl = b-crapass1.nmprimtl.

                       END.
                    ELSE
                       ASSIGN tt-dados.nrdconta = crapepa.nrctasoc
                              tt-dados.nrcpfcgc = crapepa.nrdocsoc
                              tt-dados.nmextttl = crapepa.nmprimtl.
                
                
                END.

             END.

       END.
    ELSE
       DO:
          CREATE tt-dados.

          ASSIGN tt-dados.nrdconta = par_nrdconta
                 tt-dados.nrcpfcgc = par_nrcpfcgc
                 tt-dados.idseqttl = par_idseqttl.

       END.

    FOR EACH tt-dados NO-LOCK:

        ASSIGN aux_nmpessoa = "".

        /*Se o cpf em questao estiver no cadastro restritivo*/
        IF fget_existe_risco_cpfcnpj(INPUT tt-dados.nrcpfcgc,
                                     OUTPUT aux_nmpessoa) THEN
           DO: 
              /*Se nao bloqueia operacao, cria uma liberacao para a mesma*/
              IF NOT par_bloqueia THEN 
                 DO: 
                     IF NOT VALID-HANDLE(h-b1wgen0117) THEN
                        RUN sistema/generico/procedures/b1wgen0117.p 
                            PERSISTENT SET h-b1wgen0117.
                     
                     RUN liberar_cad_restritivo IN h-b1wgen0117
                                                (INPUT par_cdcooper,
                                                 INPUT par_cdagenci,
                                                 INPUT par_nrdcaixa,
                                                 INPUT par_idorigem,
                                                 INPUT par_dtmvtolt,
                                                 INPUT par_cdoperad,
                                                 INPUT par_cdcooper,
                                                 INPUT aux_cdpactra,
                                                 INPUT par_cdoperad,
                                                 INPUT tt-dados.nrdconta,
                                                 INPUT tt-dados.nrcpfcgc,
                                                 INPUT par_dsoperac,
                                                 INPUT par_cdoperac,
                                                 INPUT TRUE, /*Gerado pelo sistema*/
                                                 OUTPUT aux_nmdcampo,
                                                 OUTPUT TABLE tt-erro). 
        
                     IF VALID-HANDLE(h-b1wgen0117) THEN
                        DELETE PROCEDURE(h-b1wgen0117).
        
                     IF RETURN-VALUE <> "OK" THEN
                        DO: 
                            IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
                               DO:
                                  ASSIGN aux_cdcritic = 0
                                         aux_dscritic = "Nao foi possivel gerar " + 
                                                        "justificativa.".
                                                     
                                  RUN gera_erro (INPUT par_cdcooper,
                                                 INPUT par_cdagenci,
                                                 INPUT par_nrdcaixa,
                                                 INPUT 1, /*sequencia*/
                                                 INPUT aux_cdcritic,
                                                 INPUT-OUTPUT aux_dscritic).
        
                               END.
        
                            RETURN "NOK".
                            
                        END. 
        
                 END.

              ASSIGN aux_temjusti = fget_existe_justificativa(INPUT par_cdcooper,
                                                              INPUT par_cdagenci,
                                                              INPUT par_cdoperad,
                                                              INPUT par_dtmvtolt,
                                                              INPUT tt-dados.nrdconta,
                                                              INPUT tt-dados.nrcpfcgc,
                                                              INPUT par_cdoperac,
                                                              INPUT aux_cdpactra).
        
              RUN envia_email_alerta(INPUT par_cdcooper,
                                     INPUT par_cdagenci,
                                     INPUT par_nrdcaixa,
                                     INPUT par_cdoperad,
                                     INPUT par_nmdatela,
                                     INPUT par_dtmvtolt,
                                     INPUT par_idorigem,
                                     INPUT tt-dados.nrcpfcgc,
                                     INPUT tt-dados.nrdconta,
                                     INPUT tt-dados.idseqttl,
                                     INPUT tt-dados.nmextttl,
                                     INPUT aux_nmpessoa,
                                     INPUT par_cdoperac,
                                     INPUT par_dsoperac,
                                     OUTPUT TABLE tt-erro).
        
              IF RETURN-VALUE <> "OK" THEN
                 DO:                         

                    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper
                                       NO-LOCK NO-ERROR.

                    IF AVAIL crapcop THEN

                    DO:
                        UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") +
                                " " + STRING(TIME,"HH:MM:SS") + "' --> '"         +
                                "Operador " + par_cdoperad + ", operacao: "       +
                                par_dsoperac + 
                                ". Nao foi possivel enviar o(s) email(s)"         +
                                ". >> /usr/coop/" + TRIM(crapcop.dsdircop)        +
                                "/log/alerta.log").
                    END.

                    RETURN "NOK".
        
                 END.
        
              /*Se nao houver uma justificatia, bloqueia operacao*/
              IF NOT aux_temjusti THEN
                 ASSIGN aux_blqopera = TRUE.

           END.         

    END. /*Fim do FOR EACH tt-dados*/

    IF aux_blqopera = TRUE THEN
       DO:
          ASSIGN aux_cdcritic = 0
                 aux_dscritic = "Operacao indisponivel, consulte " + 
                                "o Gerente/Coordenador.".
                        
          RUN gera_erro (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1, /*sequencia*/
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic).
          
          RETURN "NOK".

       END. 

    RETURN "OK".                                 
        
   
END PROCEDURE.                                   
                                                 
                                                 
/*Verifica se o cpf em questao esta no cadastro restritivo*/
FUNCTION fget_existe_risco_cpfcnpj RETURNS LOG 
        (INPUT par_nrcpfcgc AS DEC,
         OUTPUT par_nmpessoa AS CHAR):

    FIND FIRST crapcrt WHERE crapcrt.cdsitreg = 1            AND
                             crapcrt.nrcpfcgc = par_nrcpfcgc 
                             NO-LOCK NO-ERROR.

    IF AVAIL crapcrt THEN
       DO: 
           ASSIGN par_nmpessoa = crapcrt.nmpessoa.
           RETURN TRUE.

       END.
    ELSE
       RETURN FALSE.

END.
                                                 
/*Encontra uma justificativa para a operacao informada*/
FUNCTION fget_existe_justificativa RETURNS LOG
         (INPUT par_cdcooper AS INT,
          INPUT par_cdagenci AS INT,
          INPUT par_cdoperad AS CHAR,
          INPUT par_dtmvtolt AS DATE,
          INPUT par_nrdconta AS INT,
          INPUT par_nrcpfcgc AS DEC,
          INPUT par_cdoperac AS INT,
          INPUT par_cdpactra AS INT):

    FIND LAST craplju WHERE craplju.nrcpfcgc = par_nrcpfcgc AND
                            craplju.cdcoplib = par_cdcooper AND
                            craplju.cdagenci = par_cdpactra AND
                            craplju.cdopelib = par_cdoperad AND
                            craplju.nrdconta = par_nrdconta AND
                            craplju.dtmvtolt = par_dtmvtolt AND
                            craplju.cdoperac = par_cdoperac
                            NO-LOCK NO-ERROR.

    IF NOT AVAIL craplju THEN
       FIND LAST craplju WHERE craplju.nrcpfcgc = par_nrcpfcgc AND
                               craplju.cdcoplib = par_cdcooper AND
                               craplju.cdagenci = par_cdpactra AND
                               craplju.cdopelib = par_cdoperad AND
                               craplju.nrdconta = par_nrdconta AND
                               craplju.dtmvtolt = par_dtmvtolt AND
                               craplju.cdoperac = 0
                               NO-LOCK NO-ERROR.

    IF AVAIL craplju THEN
       RETURN TRUE.
    ELSE
       RETURN FALSE.


END FUNCTION.


