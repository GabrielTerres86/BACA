/*...........................................................................

    Programa: sistema/generico/procedures/b1wgen0104.p
    Autor   : Guilherme/Gabriel
    Data    : Julho/2011                        Ultima Atualizacao: 12/04/2018
     
    Dados referentes ao programa:
   
    Objetivo  : BO referente as tela CMEDEP/CMESAQ.
                 
    Alteracoes: 22/02/2012 - Alteraç?es para informar conta/dv na tela CMESAQ 
                             (quando tipo 0) e, dessa forma, n?o permitir 
                             encontrar registros duplicados. (Lucas)
                             
                19/07/2012 - Ajustes para telas cmesaq, cmedep e traesp quando
                             tipo 0 (Jorge).

                13/12/2013 - Alteracao referente a integracao Progress X 
                             Dataserver Oracle Inclusao do VALIDATE
                            ( Guilherme / SUPERO )
                            
                06/01/2014 - Critica de busca de crapage alterada de 15 p/ 962
                             (Carlos)
                             
                28/10/2015 - #318705 Adicionado sequencial na descricao da 
                             critica 90 (Carlos)
                
                04/12/2017 - Melhoria 458 ajustes de procs - Antonio R. JR (Mouts)

				08/03/2018 - Alterado tipo do parametro docmto de INT para DECIMAL
                             Chamado 851313 (Antonio R JR)
.............................................................................*/

{ sistema/generico/includes/b1wgen0104tt.i } 
{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/gera_log.i     }                              
{ sistema/generico/includes/gera_erro.i    }


DEF VAR aux_cdcritic AS INTE                                   NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                   NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                   NO-UNDO.                         
DEF VAR aux_dstransa AS CHAR                                   NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                  NO-UNDO.
 
/****************************PROCEDURES EXTERNAS******************************/
PROCEDURE busca_dados:

    DEFINE INPUT  PARAMETER par_cdcooper AS INTE               NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE               NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTE               NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad AS CHAR               NO-UNDO.
    DEFINE INPUT  PARAMETER par_idorigem AS INTE               NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdatela AS CHAR               NO-UNDO. 
    DEFINE INPUT  PARAMETER par_cdagenci AS INTE               NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdbccxlt AS INTE               NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdopecxa AS CHAR               NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdolote AS INTE               NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdocmto AS DECIMAL            NO-UNDO.
    DEFINE INPUT  PARAMETER par_tpdocmto AS INTE               NO-UNDO.
    DEFINE INPUT  PARAMETER par_cddopcao AS CHAR               NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdconta AS INTE               NO-UNDO.

    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-crapcme.

    DEFINE VARIABLE aux_nmcooptl AS CHAR                       NO-UNDO.
    DEFINE VARIABLE aux_vllanmto LIKE crapcme.vllanmto         NO-UNDO.                                                          
    DEFINE VARIABLE aux_nrseqaut LIKE crapcme.nrseqaut         NO-UNDO.                                                          
    DEFINE VARIABLE aux_nrccdrcb LIKE crapcme.nrccdrcb         NO-UNDO.                                                          
    DEFINE VARIABLE aux_nmpesrcb LIKE crapcme.nmpesrcb         NO-UNDO.                                                          
    DEFINE VARIABLE aux_inpesrcb AS INTE                       NO-UNDO.
    DEFINE VARIABLE aux_nridercb LIKE crapcme.nridercb         NO-UNDO.                                                          
    DEFINE VARIABLE aux_dtnasrcb LIKE crapcme.dtnasrcb         NO-UNDO.                                                          
    DEFINE VARIABLE aux_desenrcb LIKE crapcme.desenrcb         NO-UNDO.                                                          
    DEFINE VARIABLE aux_nmcidrcb LIKE crapcme.nmcidrcb         NO-UNDO.                                                          
    DEFINE VARIABLE aux_nrceprcb LIKE crapcme.nrceprcb         NO-UNDO.                                                          
    DEFINE VARIABLE aux_cdufdrcb LIKE crapcme.cdufdrcb         NO-UNDO.                                                          
    DEFINE VARIABLE aux_flinfdst LIKE crapcme.flinfdst         NO-UNDO.                                                          
    DEFINE VARIABLE aux_recursos LIKE crapcme.recursos         NO-UNDO.
    DEFINE VARIABLE aux_dstrecur LIKE crapcme.dstrecur         NO-UNDO.
    DEFINE VARIABLE aux_cpfcgrcb AS CHAR                       NO-UNDO.
    DEFINE VARIABLE aux_vlmincen AS DECIMAL                    NO-UNDO.
    DEFINE VARIABLE aux_vlretesp LIKE crapcme.vlretesp         NO-UNDO.                                                           


    EMPTY TEMP-TABLE tt-crapcme.
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    DO WHILE TRUE:
    
       FIND crapage WHERE crapage.cdcooper = par_cdcooper   AND
                          crapage.cdagenci = par_cdagenci   NO-LOCK NO-ERROR.

       IF   NOT AVAIL crapage   THEN
            DO:
                ASSIGN aux_cdcritic = 962.
                LEAVE.
            END.

       /* Se Banco/Caixa Informado */
       IF   par_cdbccxlt <> 0   THEN
            DO:
                FIND crapbcl WHERE crapbcl.cdbccxlt = par_cdbccxlt
                                   NO-LOCK NO-ERROR.

                IF   NOT AVAIL crapbcl   THEN
                     DO:
                         aux_cdcritic = 57.
                         LEAVE.
                     END.
            END.

       /* Se nao eh Transferencia Intercooperativa , valida Lote */
       IF   par_tpdocmto <> 4   THEN 
            DO:         
                RUN valida_lote (INPUT par_cdcooper,
                                 INPUT par_dtmvtolt,
                                 INPUT par_cdagenci,
                                 INPUT par_cdbccxlt,
                                 INPUT par_nrdolote,
                                OUTPUT aux_cdcritic).
                
                IF  RETURN-VALUE <> "OK" THEN
                    LEAVE.
            END.

       /* SAQUE normal / DEPOSITO normal */
       IF  par_tpdocmto = 0 THEN
           DO:
               FIND FIRST craplcm WHERE craplcm.cdcooper = par_cdcooper   AND
                                        craplcm.dtmvtolt = par_dtmvtolt   AND
                                        craplcm.cdagenci = par_cdagenci   AND
                                        craplcm.cdbccxlt = par_cdbccxlt   AND
                                        craplcm.nrdolote = par_nrdolote   AND
                                        craplcm.nrdocmto = par_nrdocmto   AND
                                        craplcm.nrdconta = par_nrdconta   
                                        NO-LOCK NO-ERROR.

              IF AVAIL craplcm THEN
                    DO:
               IF   par_nmdatela = "CMEDEP"   THEN
                    DO:
                        IF   craplcm.cdhistor <> 1   THEN
                             DO:
                                 ASSIGN aux_cdcritic = 83.
                                 LEAVE.
                             END.
                    END.
               ELSE
               IF   par_nmdatela = "CMESAQ"   THEN
                    DO:
                        IF   craplcm.cdhistor <> 21   AND 
                             craplcm.cdhistor <> 22   AND
                             craplcm.cdhistor <> 1030 THEN
                             DO:
                                 ASSIGN aux_cdcritic = 83.
                                 LEAVE.
                             END.
                    END.
           END.
       ELSE
                DO:
                  FIND FIRST craplft WHERE craplft.cdcooper = par_cdcooper AND
                                           craplft.dtmvtolt = par_dtmvtolt AND
                                           craplft.cdagenci = par_cdagenci AND
                                           craplft.cdbccxlt = par_cdbccxlt AND
                                           craplft.nrdolote = par_nrdolote AND
                                           craplft.nrseqdig = par_nrdocmto AND
                                           craplft.nrdconta = par_nrdconta
                                           NO-LOCK NO-ERROR.
                  IF NOT AVAIL craplft THEN
                    DO:
                      FIND FIRST craptit WHERE craptit.cdcooper = par_cdcooper AND
                                               craptit.dtmvtolt = par_dtmvtolt AND
                                               craptit.cdagenci = par_cdagenci AND
                                               craptit.cdbccxlt = par_cdbccxlt AND
                                               craptit.nrdolote = par_nrdolote AND
                                               craptit.nrseqdig = par_nrdocmto AND
                                               craptit.nrdconta = par_nrdconta
                                               NO-LOCK NO-ERROR.
                      IF NOT AVAIL craptit THEN
                        DO:
                          ASSIGN aux_cdcritic = 90
                          aux_dscritic = "(#01)".
                          LEAVE.
                        END.
                    END.
                END.
           END.                              
       ELSE
       IF   CAN-DO("1,2,3",STRING(par_tpdocmto))    THEN   
            DO:
                /* Somente para CMESAQ  1 - DOC C, 2-DOC D, 3- TED */

                FIND craptvl WHERE craptvl.cdcooper = par_cdcooper   AND
                                   craptvl.tpdoctrf = par_tpdocmto   AND
                                   craptvl.nrdocmto = par_nrdocmto
                                   NO-LOCK NO-ERROR. 

                IF   NOT AVAIL craptvl   THEN
                     DO:
                         ASSIGN aux_cdcritic = 90
                                aux_dscritic = "(#02)".
                         LEAVE.
                     END.
            END.
       ELSE     /* Tipo 4 - Transferencia intercooperativa */
            DO:

                ASSIGN par_cdbccxlt  = 11.
                FIND FIRST craplcx WHERE craplcx.cdcooper = par_cdcooper   AND
                                         craplcx.dtmvtolt = par_dtmvtolt   AND
                                         craplcx.cdagenci = par_cdagenci   AND
                                         craplcx.nrdcaixa = par_nrdcaixa   AND
                                         craplcx.cdopecxa = par_cdopecxa   AND
                                         craplcx.nrdocmto = par_nrdocmto 
                                         NO-LOCK NO-ERROR.

                IF   NOT AVAIL craplcx   THEN
                     DO:
                         ASSIGN aux_cdcritic = 90
                                aux_dscritic = "(#03)".
                         LEAVE.
                     END.

                ASSIGN par_nrdolote = 11000 + craplcx.nrdcaixa.

            END.
       
       IF   AVAIL craptvl   THEN  
            FIND crapcme WHERE crapcme.cdcooper = par_cdcooper       AND
                               crapcme.dtmvtolt = craptvl.dtmvtolt   AND
                               crapcme.cdagenci = craptvl.cdagenci   AND
                               crapcme.cdbccxlt = craptvl.cdbccxlt   AND
                               crapcme.nrdolote = craplot.nrdolote   AND
                               crapcme.nrdctabb = craptvl.nrdconta   AND
                               crapcme.nrdocmto = craptvl.nrdocmto   
                               NO-LOCK NO-ERROR. 
       ELSE 
            DO:
                IF   par_tpdocmto = 0 THEN
                     DO:
                  IF AVAIL craplcm THEN
                         FIND crapcme WHERE 
                              crapcme.cdcooper = par_cdcooper       AND
                              crapcme.dtmvtolt = craplcm.dtmvtolt   AND
                              crapcme.cdagenci = craplcm.cdagenci   AND
                              crapcme.cdbccxlt = craplcm.cdbccxlt   AND
                              crapcme.nrdolote = craplcm.nrdolote   AND
                              crapcme.nrdctabb = craplcm.nrdctabb   AND
                              crapcme.nrdocmto = craplcm.nrdocmto
                              NO-LOCK NO-ERROR.
                  IF AVAIL craplft THEN
                    FIND crapcme WHERE
                         crapcme.cdcooper = par_cdcooper AND
                         crapcme.dtmvtolt = craplft.dtmvtolt AND
                         crapcme.cdagenci = craplft.cdagenci AND
                         crapcme.cdbccxlt = craplft.cdbccxlt AND
                         crapcme.nrdolote = craplft.nrdolote AND
                         crapcme.nrdctabb = craplft.nrdconta AND
                         crapcme.nrdocmto = craplft.nrseqdig
                         NO-LOCK NO-ERROR.
                  IF AVAIL craptit THEN
                    FIND crapcme WHERE
                         crapcme.cdcooper = par_cdcooper AND
                         crapcme.dtmvtolt = craptit.dtmvtolt AND
                         crapcme.cdagenci = craptit.cdagenci AND
                         crapcme.cdbccxlt = craptit.cdbccxlt AND
                         crapcme.nrdolote = craptit.nrdolote AND
                         crapcme.nrdctabb = craptit.nrdconta AND
                         crapcme.nrdocmto = craptit.nrseqdig
                         NO-LOCK NO-ERROR.
                     END.
                ELSE
                     DO:
                         FIND crapcme WHERE 
                              crapcme.cdcooper = par_cdcooper   AND
                              crapcme.dtmvtolt = par_dtmvtolt   AND
                              crapcme.cdagenci = par_cdagenci   AND
                              crapcme.cdbccxlt = par_cdbccxlt   AND
                              crapcme.nrdolote = par_nrdolote   AND
                              crapcme.nrdocmto = par_nrdocmto  
                              NO-LOCK NO-ERROR.
                     END.
            END.

       IF   CAN-DO ("C,A",par_cddopcao)  THEN
            DO:
                IF   NOT AVAILABLE crapcme  THEN
                     DO:
                         ASSIGN aux_cdcritic = 90
                                aux_dscritic = "(#04)".
                         LEAVE.
                     END. 
            END.      
       ELSE
       IF   CAN-DO("I",par_cddopcao)   THEN
            DO:
                IF   AVAIL crapcme   THEN
                     DO:
                         ASSIGN aux_cdcritic = 675.
                         LEAVE.
                     END.
            END.

       IF   par_tpdocmto <> 4   THEN
            DO:
               IF   par_tpdocmto <> 0   THEN
                    DO:
                        ASSIGN par_nrdconta = IF   AVAIL craplcm   THEN
                                                    craplcm.nrdconta
                                               ELSE
                                                    craptvl.nrdconta.
                                                    
                    END.

               IF   par_nmdatela = "CMEDEP" THEN
                    ASSIGN par_nrdconta = IF AVAIL craplcm THEN
                                               craplcm.nrdconta
                                          ELSE IF AVAIL craplft THEN
                                               craplft.nrdconta
                                          ELSE
                                               craptit.nrdconta.

               FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                  crapass.nrdconta = par_nrdconta 
                                  NO-LOCK NO-ERROR.
           
               /* Na transferencia de valor pode ser que nao tenha nrdconta 
                  alimentado */
               IF  AVAIL craptvl   THEN
                   IF  NOT AVAILABLE crapass  AND craptvl.nrdconta <> 0 THEN 
                       DO:
                           ASSIGN aux_cdcritic = 9.
                           LEAVE.
                       END. 

               ASSIGN aux_nmcooptl = IF   AVAIL crapass  THEN 
                                          crapass.nmprimtl 
                                     ELSE "".     
            END.

       ASSIGN aux_vllanmto = IF   AVAIL craplcm   THEN 
                                  craplcm.vllanmto
                             ELSE 
                             IF   AVAIL craptvl   THEN
                                  craptvl.vldocrcb  
                             ELSE
                             IF   AVAIL craplcx   THEN
                                  craplcx.vldocmto
                             ELSE
                             IF   AVAIL craplft THEN
                                  craplft.vllanmto
                             ELSE
                                  craptit.vldpagto.

              aux_nrseqaut = IF   AVAIL craplcm   THEN 
                                  craplcm.nrautdoc
                             ELSE
                             IF   AVAIL craptvl   THEN
                                  craptvl.nrautdoc
                             ELSE
                             IF   AVAIL craplcx   THEN
                                  craplcx.vldocmto
                             ELSE
                                  IF avail craplft then
                                   craplft.nrautdoc
                             ELSE
                                  craptit.nrautdoc.

       IF   AVAIL crapcme   THEN
            ASSIGN aux_nrccdrcb = crapcme.nrccdrcb                                                          
                   aux_nmpesrcb = crapcme.nmpesrcb                                                          
                   aux_inpesrcb = IF crapcme.inpesrcb = 1 THEN 1 ELSE 2                     
                   aux_nridercb = crapcme.nridercb                                                          
                   aux_dtnasrcb = crapcme.dtnasrcb                                                          
                   aux_desenrcb = crapcme.desenrcb                                                          
                   aux_nmcidrcb = crapcme.nmcidrcb                                                          
                   aux_nrceprcb = crapcme.nrceprcb                                                          
                   aux_cdufdrcb = crapcme.cdufdrcb                                                          
                   aux_flinfdst = crapcme.flinfdst                                                          
                   aux_recursos = crapcme.recursos    
                   aux_dstrecur = crapcme.dstrecur
                   aux_vlretesp = crapcme.vlretesp
                   aux_cpfcgrcb = IF crapcme.inpesrcb = 1 THEN                                              
         STRING(STRING(crapcme.cpfcgrcb,"99999999999"),"999.999.999-99")        
               ELSE                                                                      
         STRING(STRING(crapcme.cpfcgrcb,"99999999999999"),"99.999.999/9999-99").

       RUN busca_vlmin( INPUT par_cdcooper,
                       OUTPUT aux_vlmincen).

       CREATE tt-crapcme.
       ASSIGN tt-crapcme.nrdconta = par_nrdconta
              tt-crapcme.nmcooptl = aux_nmcooptl
              tt-crapcme.vllanmto = aux_vllanmto
              tt-crapcme.nrseqaut = aux_nrseqaut
              tt-crapcme.nrccdrcb = aux_nrccdrcb
              tt-crapcme.nmpesrcb = aux_nmpesrcb
              tt-crapcme.inpesrcb = aux_inpesrcb
              tt-crapcme.nridercb = aux_nridercb
              tt-crapcme.dtnasrcb = aux_dtnasrcb
              tt-crapcme.desenrcb = aux_desenrcb
              tt-crapcme.nmcidrcb = aux_nmcidrcb
              tt-crapcme.nrceprcb = aux_nrceprcb
              tt-crapcme.cdufdrcb = aux_cdufdrcb
              tt-crapcme.flinfdst = aux_flinfdst
              tt-crapcme.recursos = aux_recursos
              tt-crapcme.dstrecur = aux_dstrecur
              tt-crapcme.cpfcgrcb = aux_cpfcgrcb
              tt-crapcme.vlmincen = aux_vlmincen
              tt-crapcme.vlretesp = aux_vlretesp.

       LEAVE.

    END. /* Tratamento de Criticas */

    IF   aux_cdcritic <> 0    OR
         aux_dscritic <> ""   THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".
         END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE busca_dados_assoc:

    DEFINE INPUT  PARAMETER par_cdcooper AS INTE               NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE               NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTE               NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad AS CHAR               NO-UNDO.
    DEFINE INPUT  PARAMETER par_idorigem AS INTE               NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTE               NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdbccxlt AS INTE               NO-UNDO.
    DEFINE INPUT  PARAMETER par_cddopcao AS CHAR               NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdconta AS INTE               NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrccdrcb AS INTE               NO-UNDO.
    DEFINE INPUT  PARAMETER par_tpdocmto AS INTE               NO-UNDO.

    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-crapcme.

    DEFINE VARIABLE aux_nrdconta LIKE crapcme.nrdconta         NO-UNDO.                                                          
    DEFINE VARIABLE aux_nrccdrcb LIKE crapcme.nrccdrcb         NO-UNDO.                                                          
    DEFINE VARIABLE aux_nmpesrcb LIKE crapcme.nmpesrcb         NO-UNDO.                                                          
    DEFINE VARIABLE aux_inpesrcb AS INTE                       NO-UNDO.
    DEFINE VARIABLE aux_nridercb LIKE crapcme.nridercb         NO-UNDO.                                                          
    DEFINE VARIABLE aux_dtnasrcb LIKE crapcme.dtnasrcb         NO-UNDO.                                                          
    DEFINE VARIABLE aux_desenrcb LIKE crapcme.desenrcb         NO-UNDO.                                                          
    DEFINE VARIABLE aux_nmcidrcb LIKE crapcme.nmcidrcb         NO-UNDO.                                                          
    DEFINE VARIABLE aux_nrceprcb LIKE crapcme.nrceprcb         NO-UNDO.                                                          
    DEFINE VARIABLE aux_cdufdrcb LIKE crapcme.cdufdrcb         NO-UNDO.                                                          
    DEFINE VARIABLE aux_flinfdst LIKE crapcme.flinfdst         NO-UNDO.                                                          
    DEFINE VARIABLE aux_recursos LIKE crapcme.recursos         NO-UNDO.                                                          
    DEFINE VARIABLE aux_cpfcgrcb AS CHAR                       NO-UNDO.                                                              

    DEFINE VARIABLE h_b1wgen9999 AS HANDLE                     NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-crapcme.
    
    RUN sistema/generico/procedures/b1wgen9999.p 
                PERSISTENT SET h_b1wgen9999.

    IF  NOT VALID-HANDLE(h_b1wgen9999)  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para h_b1wgen9999.".
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    ASSIGN aux_nrdconta = par_nrdconta
           aux_nrccdrcb = par_nrccdrcb.

    RUN dig_fun IN h_b1wgen9999 (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT-OUTPUT aux_nrccdrcb,
                                 OUTPUT TABLE tt-erro).
    
    DELETE PROCEDURE h_b1wgen9999.
    
    IF   RETURN-VALUE = "NOK"   THEN
         RETURN "NOK".

    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND 
                       crapass.nrdconta = par_nrccdrcb
                       NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapass   THEN 
         DO:
             ASSIGN aux_cdcritic = 9
                    aux_dscritic = "".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".
         END.

         /* Deve ser pessoa fisica */
    IF   crapass.inpessoa <> 1   THEN
         DO:
             ASSIGN aux_cdcritic = 436.
            
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".
         END.

    FIND crapenc WHERE
         crapenc.cdcooper = crapass.cdcooper  AND
         crapenc.nrdconta = crapass.nrdconta  AND
         crapenc.idseqttl = 1                 AND
         crapenc.cdseqinc = 1 NO-LOCK NO-ERROR.

    ASSIGN aux_nmpesrcb = crapass.nmprimtl
           aux_nridercb = crapass.nrdocptl
           aux_dtnasrcb = crapass.dtnasctl
           aux_desenrcb = SUBSTRING(crapenc.dsendere,1,32)
                          + " " +
                          TRIM(STRING(crapenc.nrendere,
                                      "zzz,zzz" ))
           aux_nmcidrcb = crapenc.nmcidade
           aux_cdufdrcb = crapenc.cdufende
           aux_nrceprcb = crapenc.nrcepend
           aux_nrccdrcb = crapass.nrdconta
           aux_inpesrcb = 1
           aux_cpfcgrcb = STRING(crapass.nrcpfcgc,"99999999999")
           aux_cpfcgrcb = STRING(aux_cpfcgrcb,"xxx.xxx.xxx-xx").

    IF par_tpdocmto <> 4 THEN
       DO:
         /* Procura Prim.ttl. da Conta para exibiçao */
         IF par_nrdconta <> 0 THEN
           DO:
         RELEASE crapass.
         FIND crapass WHERE crapass.cdcooper = par_cdcooper AND 
                            crapass.nrdconta = par_nrdconta
                            NO-LOCK NO-ERROR.
        
          IF   NOT AVAILABLE crapass   THEN 
              DO:
                  ASSIGN aux_cdcritic = 9
                         aux_dscritic = "".
        
                  RUN gera_erro (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT 1,            /** Sequencia **/
                                 INPUT aux_cdcritic,
                                 INPUT-OUTPUT aux_dscritic).
                  RETURN "NOK".
              END.
       END.
       END.

    CREATE tt-crapcme.               
    ASSIGN tt-crapcme.nrdconta = par_nrdconta
           tt-crapcme.nmcooptl = IF par_tpdocmto <> 4 THEN crapass.nmprimtl ELSE ""                     
           tt-crapcme.nrccdrcb = aux_nrccdrcb
           tt-crapcme.nmpesrcb = aux_nmpesrcb
           tt-crapcme.inpesrcb = aux_inpesrcb
           tt-crapcme.nridercb = aux_nridercb
           tt-crapcme.dtnasrcb = aux_dtnasrcb
           tt-crapcme.desenrcb = aux_desenrcb
           tt-crapcme.nmcidrcb = aux_nmcidrcb
           tt-crapcme.nrceprcb = aux_nrceprcb
           tt-crapcme.cdufdrcb = aux_cdufdrcb
           tt-crapcme.cpfcgrcb = aux_cpfcgrcb.

    RETURN "OK".

END PROCEDURE.


PROCEDURE valida_dados_nao_assoc:

    DEFINE INPUT  PARAMETER par_cdcooper AS INTE               NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE               NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTE               NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad AS CHAR               NO-UNDO.
    DEFINE INPUT  PARAMETER par_idorigem AS INTE               NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTE               NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdbccxlt AS INTE               NO-UNDO.
    DEFINE INPUT  PARAMETER par_cddopcao AS CHAR               NO-UNDO.
    DEFINE INPUT  PARAMETER par_cpfcgrcb AS CHAR               NO-UNDO.
    DEFINE INPUT  PARAMETER par_nridercb LIKE crapcme.nridercb NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtnasrcb LIKE crapcme.dtnasrcb NO-UNDO.

    DEFINE OUTPUT PARAMETER par_nmdcampo AS CHAR               NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.                 

    DEF VAR aux_inpessoa AS INTE NO-UNDO.
    DEF VAR aux_stsnrcal AS LOGI NO-UNDO.

    DEFINE VARIABLE h_b1wgen9999 AS HANDLE                     NO-UNDO.


    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".
    
    DO WHILE TRUE:

       FIND crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    
       IF   NOT AVAIL crapdat   THEN
            DO:
                ASSIGN aux_cdcritic = 1.
                LEAVE.
            END.

       /* Se houve erro na conversao para DEC, faz a critica */
       DEC(par_cpfcgrcb) NO-ERROR.
       
       IF  ERROR-STATUS:ERROR THEN
           DO:
              ASSIGN aux_dscritic = "CPF contem caracteres invalidos, deve" +
                                    " possuir apenas numeros."
                     par_nmdcampo = "cpfcgrcb".
              LEAVE. 
           END.

       RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h_b1wgen9999.
       
       IF  NOT VALID-HANDLE(h_b1wgen9999)  THEN
           DO:
               ASSIGN aux_dscritic = "Handle invalido para h_b1wgen9999.".
               LEAVE.
           END.

       RUN valida-cpf-cnpj IN h_b1wgen9999
                       (INPUT DECIMAL(par_cpfcgrcb),
                        OUTPUT aux_stsnrcal,
                        OUTPUT aux_inpessoa).

       DELETE PROCEDURE h_b1wgen9999.

       IF  NOT aux_stsnrcal  THEN
           DO:
               ASSIGN aux_dscritic = "CPF/CNPJ informado invalido."
                      par_nmdcampo = "cpfcgrcb".      
               LEAVE.
           END.

       /* Deve ser pessoa fisica */
       IF   aux_inpessoa <> 1   THEN
            DO:
                ASSIGN aux_cdcritic = 436
                       par_nmdcampo = "cpfcgrcb".
                LEAVE.
            END.

       IF   par_dtnasrcb = ?                         OR
            par_dtnasrcb > crapdat.dtmvtolt - 3500   THEN
            DO:
                ASSIGN aux_dscritic = "Data nascimento invalida."
                       par_nmdcampo = "dtnasrcb".
                LEAVE.                
            END.
             
       IF   par_nridercb = ""   THEN
            DO:
                ASSIGN aux_dscritic = "Campo nr.ide deve ser preenchido"
                       par_nmdcampo = "nridercb".
                LEAVE.             
            END.

       LEAVE.

    END.

    IF   aux_cdcritic <> 0   OR
         aux_dscritic <> ""  THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,     /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             
             RETURN "NOK".
         END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE inclui_altera_dados:

    DEFINE INPUT  PARAMETER par_cdcooper AS INTE               NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE               NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTE               NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad AS CHAR               NO-UNDO.
    DEFINE INPUT  PARAMETER par_idorigem AS INTE               NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdatela AS CHAR               NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTE               NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdopecxa AS CHAR               NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdbccxlt AS INTE               NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdolote AS INTE               NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdocmto AS DECIMAL            NO-UNDO.
    DEFINE INPUT  PARAMETER par_tpdocmto AS INTE               NO-UNDO.
    DEFINE INPUT  PARAMETER par_cddopcao AS CHAR               NO-UNDO.
    DEFINE INPUT  PARAMETER par_flgimpri AS LOGI               NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdconta AS INTE               NO-UNDO.

    DEFINE INPUT  PARAMETER par_nrccdrcb LIKE crapcme.nrccdrcb NO-UNDO.                                                          
    DEFINE INPUT  PARAMETER par_nmpesrcb LIKE crapcme.nmpesrcb NO-UNDO.                                                          
    DEFINE INPUT  PARAMETER par_nridercb LIKE crapcme.nridercb NO-UNDO.                                                          
    DEFINE INPUT  PARAMETER par_dtnasrcb LIKE crapcme.dtnasrcb NO-UNDO.                                                          
    DEFINE INPUT  PARAMETER par_desenrcb LIKE crapcme.desenrcb NO-UNDO.                                                          
    DEFINE INPUT  PARAMETER par_nmcidrcb LIKE crapcme.nmcidrcb NO-UNDO.                                                          
    DEFINE INPUT  PARAMETER par_nrceprcb LIKE crapcme.nrceprcb NO-UNDO.                                                          
    DEFINE INPUT  PARAMETER par_cdufdrcb LIKE crapcme.cdufdrcb NO-UNDO.                                                          
    DEFINE INPUT  PARAMETER par_flinfdst LIKE crapcme.flinfdst NO-UNDO.                                                          
    DEFINE INPUT  PARAMETER par_recursos LIKE crapcme.recursos NO-UNDO.    
    DEFINE INPUT  PARAMETER par_dstrecur LIKE crapcme.dstrecur NO-UNDO.
    DEFINE INPUT  PARAMETER par_cpfcgrcb AS CHAR               NO-UNDO.
    DEFINE INPUT  PARAMETER par_vlretesp LIKE crapcme.vlretesp NO-UNDO.

    DEFINE OUTPUT PARAMETER par_nmarqimp AS CHAR               NO-UNDO.
    DEFINE OUTPUT PARAMETER par_nmarqpdf AS CHAR               NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.


    DEFINE VARIABLE aux_nrdconta AS INTE                       NO-UNDO.
    DEFINE VARIABLE aux_cdagenci AS INTE                       NO-UNDO.
    DEFINE VARIABLE aux_cdbccxlt AS INTE                       NO-UNDO.
    DEFINE VARIABLE aux_nrdctabb AS INTE                       NO-UNDO.
    DEFINE VARIABLE aux_nrseqdig AS INTE                       NO-UNDO.
    DEFINE VARIABLE aux_vllanmto AS DECI                       NO-UNDO.
    DEFINE VARIABLE aux_nrautdoc AS INTE                       NO-UNDO.
    DEFINE VARIABLE aux_dtmvtolt AS DATE                       NO-UNDO.
    DEFINE VARIABLE aux_inpessoa AS INTE                       NO-UNDO.
    DEFINE VARIABLE aux_nrdcaixa AS INTE                       NO-UNDO.
    DEFINE VARIABLE aux_cdopecxa AS CHAR                       NO-UNDO.

    DEFINE VARIABLE aux_nmdbloco AS CHAR                       NO-UNDO.
    DEFINE VARIABLE aux_cddopcao AS INTE                       NO-UNDO.
    DEFINE VARIABLE aux_vlmincen AS DECIMAL                    NO-UNDO.
    DEFINE VARIABLE aux_flgtrans AS LOGI                       NO-UNDO.
    DEFINE VARIABLE h-b1wgen9998 AS HANDLE                     NO-UNDO.


    RUN busca_vlmin( INPUT par_cdcooper,
                     OUTPUT aux_vlmincen).

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_nmdbloco = IF   par_cddopcao = "A"   THEN 
                               "ALTERACAO"
                          ELSE   
                               "INCLUSAO"
           aux_cddopcao = IF   par_cddopcao = "A"   THEN
                               2
                          ELSE
                               1
           par_cpfcgrcb = REPLACE(par_cpfcgrcb,"-","").

    EMPTY TEMP-TABLE tt-erro.

    aux_nmdbloco:
    DO TRANSACTION ON ERROR UNDO aux_nmdbloco, LEAVE aux_nmdbloco:

        /* Se nao eh Transferencia Intercooperativa , valida Lote */
        IF   par_tpdocmto <> 4   THEN 
             DO:         
                 RUN valida_lote (INPUT par_cdcooper,
                                  INPUT par_dtmvtolt,
                                  INPUT par_cdagenci,
                                  INPUT par_cdbccxlt,
                                  INPUT par_nrdolote,
                                 OUTPUT aux_cdcritic).
                 
                 IF  RETURN-VALUE <> "OK" THEN
                     LEAVE aux_nmdbloco.

                 ASSIGN aux_nrdcaixa = craplot.nrdcaixa
                        aux_cdopecxa = craplot.cdopecxa.
             END.

        IF   par_tpdocmto = 0   THEN /* Deposito / Saque */
             DO:
                 FIND FIRST craplcm WHERE craplcm.cdcooper = par_cdcooper   AND
                                          craplcm.dtmvtolt = par_dtmvtolt   AND
                                          craplcm.cdagenci = par_cdagenci   AND
                                          craplcm.cdbccxlt = par_cdbccxlt   AND
                                          craplcm.nrdolote = par_nrdolote   AND
                                          craplcm.nrdocmto = par_nrdocmto   AND 
                                          craplcm.nrdconta = par_nrdconta
                                          NO-LOCK NO-ERROR.
                 
                 IF NOT AVAIL craplcm THEN
                   FIND FIRST craplft WHERE craplft.cdcooper = par_cdcooper AND
                                            craplft.dtmvtolt = par_dtmvtolt AND
                                            craplft.cdagenci = par_cdagenci AND
                                            craplft.cdbccxlt = par_cdbccxlt AND
                                            craplft.nrdolote = par_nrdolote AND
                                            craplft.nrseqdig = par_nrdocmto AND
                                            craplft.nrdconta = par_nrdconta
                                            NO-LOCK NO-ERROR.
                                            
                  IF NOT AVAIL craplft THEN
                    FIND FIRST craptit WHERE craptit.cdcooper = par_cdcooper AND
                                             craptit.dtmvtolt = par_dtmvtolt AND
                                             craptit.cdagenci = par_cdagenci AND
                                             craptit.cdbccxlt = par_cdbccxlt AND
                                             craptit.nrdolote = par_nrdolote AND
                                             craptit.nrseqdig = par_nrdocmto AND
                                             craptit.nrdconta = par_nrdconta
                                             NO-LOCK NO-ERROR.
             END.                       
        ELSE
        IF   CAN-DO("1,2,3",STRING(par_tpdocmto))   THEN /* Transferencia */
             DO:
                 FIND craptvl WHERE craptvl.cdcooper = par_cdcooper AND
                                    craptvl.tpdoctrf = par_tpdocmto AND
                                    craptvl.nrdocmto = par_nrdocmto
                                    NO-LOCK NO-ERROR.   
             END.
        ELSE        /* Transferencia Intercooperativa */
             DO:
                 FIND FIRST craplcx WHERE craplcx.cdcooper = par_cdcooper   AND
                                          craplcx.dtmvtolt = par_dtmvtolt   AND
                                          craplcx.cdagenci = par_cdagenci   AND
                                          craplcx.nrdcaixa = par_nrdcaixa   AND
                                          craplcx.cdopecxa = par_cdopecxa   AND
                                          craplcx.nrdocmto = par_nrdocmto 
                                          NO-LOCK NO-ERROR. 

                 ASSIGN par_cdbccxlt = 11.

                 IF   AVAIL craplcx   THEN
                      ASSIGN par_nrdolote = 11000 + craplcx.nrdcaixa
                             aux_nrdcaixa = craplcx.nrdcaixa
                             aux_cdopecxa = craplcx.cdopecxa.
                     
             END.

        IF   NOT AVAIL craplcm   AND   
             NOT AVAIL craptvl   AND 
             NOT AVAIL craplft AND
             NOT AVAIL craptit AND 
             NOT AVAIL craplcx   THEN
             DO:
                 ASSIGN aux_cdcritic = 90
                        aux_dscritic = "(#05)".
                 LEAVE aux_nmdbloco.
             END.

        IF   AVAIL craplcm   THEN
             ASSIGN aux_nrdconta = craplcm.nrdconta
                    aux_cdagenci = craplcm.cdagenci
                    aux_cdbccxlt = craplcm.cdbccxlt
                    aux_nrdctabb = craplcm.nrdctabb
                    aux_nrseqdig = craplcm.nrseqdig
                    aux_vllanmto = craplcm.vllanmto 
                    aux_nrautdoc = craplcm.nrautdoc
                    aux_dtmvtolt = craplcm.dtmvtolt.                    
        ELSE
        IF   AVAIL craptvl   THEN
             ASSIGN aux_nrdconta = craptvl.nrdconta
                    aux_cdagenci = craptvl.cdagenci
                    aux_cdbccxlt = craptvl.cdbccxlt
                    aux_nrdctabb = craptvl.nrdconta
                    aux_nrseqdig = craptvl.nrseqdig
                    aux_vllanmto = craptvl.vldocrcb
                    aux_nrautdoc = craptvl.nrautdoc
                    aux_dtmvtolt = craptvl.dtmvtolt.
        ELSE
        IF   AVAIL craplcx   THEN
             ASSIGN aux_nrdconta = 0 
                    aux_cdagenci = craplcx.cdagenci 
                    aux_cdbccxlt = 11 
                    aux_nrdctabb = 0 
                    aux_nrseqdig = craplcx.nrseqdig 
                    aux_vllanmto = craplcx.vldocmto 
                    aux_nrautdoc = craplcx.nrautdoc 
                    aux_dtmvtolt = craplcx.dtmvtolt.

        ELSE
        IF   AVAIL craplft THEN
             ASSIGN aux_nrdconta = craplft.nrdconta
                    aux_cdagenci = craplft.cdagenci
                    aux_cdbccxlt = craplft.cdbccxlt
                    aux_nrdctabb = craplft.nrdconta
                    aux_nrseqdig = craplft.nrseqdig
                    aux_vllanmto = craplft.vllanmto
                    aux_nrautdoc = craplft.nrautdoc
                    aux_dtmvtolt = craplft.dtmvtolt.
        ELSE
        IF   AVAIL craptit THEN
             ASSIGN aux_nrdconta = craptit.nrdconta
                    aux_cdagenci = craptit.cdagenci
                    aux_cdbccxlt = craptit.cdbccxlt
                    aux_nrdctabb = craptit.nrdconta
                    aux_nrseqdig = craptit.nrseqdig
                    aux_vllanmto = craptit.vldpagto
                    aux_nrautdoc = craptit.nrautdoc
                    aux_dtmvtolt = craptit.dtmvtolt. 

        IF   aux_nrdconta <> 0   THEN
             DO:
                 FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                    crapass.nrdconta = aux_nrdconta
                                    NO-LOCK NO-ERROR.
        
                 /* Na transferencia de valor pode ser que nao tenha nrdconta */
                 IF   NOT AVAILABLE crapass      THEN
                      DO:
                          ASSIGN aux_cdcritic = 9.
                          LEAVE aux_nmdbloco.
                      END.
                 
                 ASSIGN aux_inpessoa = IF   AVAIL crapass   THEN 
                                            crapass.inpessoa
                                       ELSE
                                            1.
             END.
        
        FIND crapcme WHERE crapcme.cdcooper = par_cdcooper   AND
                           crapcme.dtmvtolt = aux_dtmvtolt   AND
                           crapcme.cdagenci = par_cdagenci   AND
                           crapcme.cdbccxlt = par_cdbccxlt   AND
                           crapcme.nrdolote = par_nrdolote   AND
                           crapcme.nrdctabb = aux_nrdctabb   AND
                           crapcme.nrdocmto = par_nrdocmto
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF   par_cddopcao = "A"   THEN
             DO:
                 IF   NOT AVAILABLE crapcme   THEN 
                      DO:
                          ASSIGN aux_cdcritic = 90
                                 aux_dscritic = "(#06)".
                          LEAVE aux_nmdbloco.                     
                      END.
             END.
        ELSE
        IF   par_cddopcao = "I"   THEN
             DO:
                 IF   AVAILABLE crapcme    THEN
                      DO:
                          ASSIGN aux_cdcritic = 675.
                          LEAVE aux_nmdbloco.
                      END.

                 CREATE crapcme.
                 ASSIGN crapcme.cdcooper = par_cdcooper
                        crapcme.dtmvtolt = aux_dtmvtolt
                        crapcme.cdagenci = aux_cdagenci
                        crapcme.cdbccxlt = aux_cdbccxlt
                        crapcme.nrdolote = par_nrdolote
                        crapcme.nrseqdig = aux_nrseqdig
                        crapcme.nrdcaixa = aux_nrdcaixa
                        crapcme.nrdconta = aux_nrdconta
                        crapcme.cdopecxa = aux_cdopecxa
                        crapcme.nrdocmto = par_nrdocmto
                        crapcme.nrdctabb = aux_nrdctabb
                        crapcme.vllanmto = aux_vllanmto
                        crapcme.nrseqaut = aux_nrautdoc
                        crapcme.tpoperac = IF   par_nmdatela = "CMEDEP"   THEN 
                                             IF AVAIL craplft OR AVAIL craptit THEN
                                                3 /* pagamento */
                                             ELSE
                                                1  /* deposito */
                                           ELSE
                                                2. /* Saque */

                 VALIDATE crapcme.
        END.
             
        ASSIGN crapcme.nmpesrcb = par_nmpesrcb
               crapcme.nrccdrcb = par_nrccdrcb
               crapcme.cpfcgrcb = DECIMAL(par_cpfcgrcb)
               crapcme.dtnasrcb = par_dtnasrcb                                  
               crapcme.desenrcb = par_desenrcb
               crapcme.nmcidrcb = par_nmcidrcb
               crapcme.cdufdrcb = par_cdufdrcb
               crapcme.nridercb = par_nridercb                                 
               crapcme.recursos = par_recursos
               crapcme.dstrecur = par_dstrecur
               crapcme.inpesrcb = 1
               crapcme.nrceprcb = par_nrceprcb
               crapcme.flinfdst = par_flinfdst
               crapcme.vlretesp = par_vlretesp.
        
        IF   crapcme.vllanmto >= aux_vlmincen   AND 
             aux_inpessoa <> 2                  THEN
             ASSIGN crapcme.sisbacen = YES.
        ELSE 
             ASSIGN crapcme.sisbacen = NO.

        IF   crapcme.vllanmto >= aux_vlmincen   AND 
             aux_inpessoa < 3                   THEN
             DO:           
                 ASSIGN crapcme.infrepcf = 1. /* Informar ao COAF */
                            
                 RUN sistema/generico/procedures/b1wgen9998.p 
                                 PERSISTENT SET h-b1wgen9998.
                
                 RUN email-controle-movimentacao IN h-b1wgen9998
                                    (INPUT par_cdcooper,
                                     INPUT 0,
                                     INPUT 0,
                                     INPUT par_cdoperad,
                                     INPUT par_nmdatela,
                                     INPUT 1, /* Ayllos*/
                                     INPUT crapcme.nrdconta,
                                     INPUT 1,  /* Tit. */
                                     INPUT aux_cddopcao, /* Inclui/Altera */
                                     INPUT ROWID(crapcme),
                                     INPUT TRUE, /* Envia */
                                     INPUT par_dtmvtolt,
                                     INPUT TRUE,
                                    OUTPUT TABLE tt-erro).
                                                                                         
                 DELETE PROCEDURE h-b1wgen9998.
        
                 IF   RETURN-VALUE <> "OK"   THEN
                      DO:
                          FIND FIRST tt-erro NO-LOCK NO-ERROR.
                 
                          IF   AVAIL tt-erro   THEN
                               aux_dscritic =  tt-erro.dscritic.
                          ELSE
                               aux_dscritic = "Erro no envio do e-mail.".
                 
                          UNDO aux_nmdbloco, LEAVE aux_nmdbloco.
                      END.           
             END.           
        ELSE
             ASSIGN crapcme.infrepcf = 0. /* Nao informar ao COAF */


        IF   par_flgimpri   THEN
             DO: 
                 RUN imprimir_dados (INPUT par_cdcooper,
                                     INPUT par_dtmvtolt,
                                     INPUT par_nrdcaixa,
                                     INPUT par_cdoperad,
                                     INPUT par_cdopecxa,
                                     INPUT par_idorigem,
                                     INPUT par_nmdatela,
                                     INPUT par_cdagenci,
                                     INPUT par_cddopcao,
                                    OUTPUT par_nmarqimp,
                                    OUTPUT par_nmarqpdf,
                                    OUTPUT TABLE tt-erro).

                 IF  RETURN-VALUE <> "OK"   THEN
                     UNDO aux_nmdbloco, LEAVE aux_nmdbloco.

             END.

        ASSIGN aux_flgtrans = TRUE.

    END.  /*  Fim da transacao  */

    IF  NOT aux_flgtrans   THEN
        DO:
            /* Se nao criou nenhum erro */
            IF   NOT TEMP-TABLE tt-erro:HAS-RECORDS   THEN
                 RUN gera_erro (INPUT par_cdcooper,
                                INPUT par_cdagenci,
                                INPUT par_nrdcaixa,
                                INPUT 1,            /** Sequencia **/
                                INPUT aux_cdcritic,
                                INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.


/****************************PROCEDURES INTERNAS******************************/

PROCEDURE imprimir_dados:

    DEFINE INPUT  PARAMETER par_cdcooper AS INTE               NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE               NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTE               NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad AS CHAR               NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdopecxa AS CHAR               NO-UNDO.
    DEFINE INPUT  PARAMETER par_idorigem AS INTE               NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdatela AS CHAR               NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTE               NO-UNDO.
    DEFINE INPUT  PARAMETER par_cddopcao AS CHAR               NO-UNDO.

    DEFINE OUTPUT PARAMETER par_nmarqimp AS CHAR               NO-UNDO.
    DEFINE OUTPUT PARAMETER par_nmarqpdf AS CHAR               NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.


    DEFINE VARIABLE aux_cdagenci AS INTE                       NO-UNDO.
    DEFINE VARIABLE aux_nrdcaixa AS INTE                       NO-UNDO.
    DEFINE VARIABLE aux_nrdolote AS INTE                       NO-UNDO.
    DEFINE VARIABLE aux_nrautdoc AS INTE                       NO-UNDO.
    DEFINE VARIABLE aux_nrdocmto AS DECIMAL                    NO-UNDO.
    DEFINE VARIABLE aux_flgdelcm AS LOGI                       NO-UNDO.
    DEFINE VARIABLE aux_data_inf AS INTE                       NO-UNDO.
    DEFINE VARIABLE aux_flgtrans AS LOGI                       NO-UNDO.
    
    DEFINE VARIABLE h-b1wgen0024 AS HANDLE                     NO-UNDO.
    DEFINE VARIABLE h-bo-depos   AS HANDLE                     NO-UNDO.
    DEFINE VARIABLE h-bo-saque   AS HANDLE                     NO-UNDO.


    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    EMPTY TEMP-TABLE tt-erro.

    IMPRESSAO:
    DO:
        FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

        IF   NOT AVAIL crapcop   THEN
             DO:
                 ASSIGN aux_cdcritic = 651.
                 LEAVE IMPRESSAO.
             END.
        
        IF   AVAIL craplcm   THEN
             ASSIGN aux_cdagenci = craplcm.cdagenci
                    aux_nrdcaixa = craplot.nrdcaixa
                    aux_nrdolote = craplot.nrdolote
                    aux_nrautdoc = craplcm.nrautdoc
                    aux_nrdocmto = craplcm.nrdocmto
                    aux_flgdelcm = NO.
        ELSE
        IF   AVAIL craptvl   THEN
             ASSIGN aux_cdagenci = craptvl.cdagenci
                    aux_nrdcaixa = craplot.nrdcaixa
                    aux_nrdolote = craptvl.nrdolote 
                    aux_nrautdoc = craptvl.nrautdoc
                    aux_nrdocmto = craptvl.nrdocmto
                    aux_flgdelcm = YES.
        ELSE
        IF   AVAIL craplcx   THEN
             ASSIGN aux_cdagenci = craplcx.cdagenci
                    aux_nrdcaixa = craplcx.nrdcaixa
                    aux_nrdolote = 11000 + craplcx.nrdcaixa
                    aux_nrautdoc = craplcx.nrautdoc
                    aux_nrdocmto = craplcx.nrdocmto
                    aux_flgdelcm = YES.
        ELSE  
        IF   AVAIL craplft THEN
             ASSIGN aux_cdagenci = craplft.cdagenci
                    aux_nrdcaixa = craplot.nrdcaixa
                    aux_nrdolote = craplot.nrdolote
                    aux_nrautdoc = craplft.nrautdoc
                    aux_nrdocmto = craplft.nrseqdig
                    aux_flgdelcm = NO.
        ELSE            
        IF   AVAIL craptit THEN
             ASSIGN aux_cdagenci = craptit.cdagenci
             aux_nrdcaixa = craplot.nrdcaixa
             aux_nrdolote = craplot.nrdolote
             aux_nrautdoc = craptit.nrautdoc 
             aux_nrdocmto = craptit.nrseqdig
             aux_flgdelcm = NO.

        IF   par_cddopcao = "A"   THEN
             ASSIGN aux_data_inf = INTE(STRING(DAY(par_dtmvtolt),"99") +
                                   STRING(MONTH(par_dtmvtolt),"99") +
                                   STRING(YEAR(par_dtmvtolt),"9999")).
        ELSE
             ASSIGN aux_data_inf = 0.
                     
        IF   par_nmdatela = "CMEDEP"   THEN
             DO:
                 RUN siscaixa/web/dbo/bo_controla_depositos.p 
                     PERSISTENT SET h-bo-depos.
                
                 RUN bo_imp_ctr_depositos IN h-bo-depos 
                                                    (INPUT crapcop.nmrescop,
                                                     INPUT par_cdoperad,
                                                     INPUT aux_cdagenci,
                                                     INPUT aux_nrdcaixa,
                                                     INPUT aux_nrdolote,
                                                     INPUT aux_nrautdoc,
                                                     INPUT NO, /* Nao Imprime */
                                                     INPUT aux_data_inf,
                                                    OUTPUT par_nmarqimp).
                 DELETE PROCEDURE h-bo-depos.
             END.
        ELSE      /* CMESAQ */
             DO:
                 RUN siscaixa/web/dbo/bo_controla_saques.p
                         PERSISTENT SET h-bo-saque.

                 RUN bo_imp_ctr_saques IN h-bo-saque 
                                                    (INPUT crapcop.nmrescop,
                                                     INPUT par_cdoperad,
                                                     INPUT aux_cdagenci,
                                                     INPUT aux_nrdcaixa,
                                                     INPUT aux_nrdolote,
                                                     INPUT aux_nrdocmto,
                                                     INPUT aux_nrautdoc,
                                                     INPUT NO, /* Nao Imprime */
                                                     INPUT aux_data_inf,
                                                     INPUT aux_flgdelcm, 
                                                     INPUT par_cdopecxa,
                                                    OUTPUT par_nmarqimp).                                                               
                 DELETE PROCEDURE h-bo-saque.
             END.

        IF   RETURN-VALUE <> "OK"   THEN
             DO:
                 FIND FIRST craperr WHERE 
                            craperr.cdcooper = crapcop.cdcooper AND
                            craperr.cdagenci = aux_cdagenci     AND
                            craperr.nrdcaixa = aux_nrdcaixa   
                            NO-LOCK NO-ERROR.
                 
                 IF   AVAIL craperr   THEN
                      ASSIGN aux_dscritic = craperr.dscritic. 
                 ELSE
                      ASSIGN aux_dscritic = 
                          "Erro na execucao da impressao.".
        
                 LEAVE IMPRESSAO.
             END.

        IF   par_idorigem = 5   THEN /* Ayllos Web */
             DO:
                 RUN sistema/generico/procedures/b1wgen0024.p 
                     PERSISTENT SET h-b1wgen0024.
            
                 RUN envia-arquivo-web IN h-b1wgen0024 
                     ( INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT par_nmarqimp,
                      OUTPUT par_nmarqpdf,
                      OUTPUT TABLE tt-erro ).
            
                 DELETE PROCEDURE h-b1wgen0024.
            
                 IF  RETURN-VALUE <> "OK"   THEN
                     LEAVE IMPRESSAO.                     
             END.

        ASSIGN aux_flgtrans = TRUE.

    END.

    IF  NOT aux_flgtrans   THEN
        DO:
            /* Se nao criou nenhum erro */
            IF   NOT TEMP-TABLE tt-erro:HAS-RECORDS   THEN
                 RUN gera_erro (INPUT par_cdcooper,
                                INPUT par_cdagenci,
                                INPUT par_nrdcaixa,
                                INPUT 1,            /** Sequencia **/
                                INPUT aux_cdcritic,
                                INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE valida_lote:

    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER            NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE               NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER            NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdbccxlt AS INTEGER            NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdolote AS INTEGER            NO-UNDO.
    DEFINE OUTPUT PARAMETER par_cdcritic AS INTEGER            NO-UNDO.
    
    FIND craplot WHERE craplot.cdcooper = par_cdcooper   AND
                       craplot.dtmvtolt = par_dtmvtolt   AND
                       craplot.cdagenci = par_cdagenci   AND
                       craplot.cdbccxlt = par_cdbccxlt   AND
                       craplot.nrdolote = par_nrdolote   NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE craplot  THEN
        DO:
            par_cdcritic = 60.
            RETURN "NOK".
        END.
    
    RETURN "OK".

END PROCEDURE.


PROCEDURE busca_vlmin:

    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER            NO-UNDO.
    DEFINE OUTPUT PARAMETER par_vlmincen AS DECIMAL            NO-UNDO.

    FIND craptab WHERE craptab.cdcooper = par_cdcooper    AND
                       craptab.nmsistem = "CRED"          AND
                       craptab.tptabela = "GENERI"        AND
                       craptab.cdempres = 0               AND
                       craptab.cdacesso = "VMINCTRCEN"    AND
                       craptab.tpregist = 0               NO-LOCK NO-ERROR.

    ASSIGN par_vlmincen = IF AVAILABLE craptab THEN DEC(craptab.dstextab)
                          ELSE 0.

    RETURN "OK".

END PROCEDURE.


/* ......................................................................... */


