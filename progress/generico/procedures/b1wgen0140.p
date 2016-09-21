/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | procedures/b1wgen0140.p         | PCAP0001                          |
  | PROCEDURES:                     | PROCEDURES:                       |
  |    busca_procap_ativos          |   PCAP0001.pc_busca_procap_ativos |
  |    busca_procap_desbl_naosac    |   PCAP0001.pc_busca_procap_desbl_naosac |
  |    busca_data_saque             |   PCAP0001.pc_busca_data_saque    |
  |    busca_procap_capital_sacado  |   PCAP0001.pc_busca_procap_capital_sacado |
  |    total_integralizaado         |   PCAP0001.pc_total_integralizaado |                  
  +---------------------------------+-----------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)
   - GUILHERME BOETTCHER (SUPERO)

*******************************************************************************/









/*.............................................................................

  Programa: generico/procedures/b1wgen0140.p
  Sistema : Conta-Corrente - Cooperativa de Credito
  Sigla   : CRED
  Autor   : Tiago
  Data    : Setembro/12                            Ultima alteracao: 19/08/2015

  Objetivo  : Procedures referentes ao PROCAP.

  Alteracao :   23/10/2013 - Removido o uso da global glb_dtmvtolt. Substituido
                             por FIND na crapdat. (Fabricio)
                             
                12/11/2013 - Tratamento historico 1511 (Migracao). (Irlan )             
                
                07/01/2014 - Substituido uso do campo tt-craplct.cdagenci pelo
                             campo tt-craplct.cdageass pois estava dando
                             erro de chave unica (Tiago).        
                             
                19/08/2015 - Remover procedure acesso_opcao (Lucas Ranghetti #322522)
............................................................................ */

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/b1wgen0140tt.i }


DEF BUFFER crablct FOR craplct.

PROCEDURE busca_lanctos:

    DEF INPUT PARAM par_cdcooper    LIKE crapcop.cdcooper               NO-UNDO.
    DEF INPUT PARAM par_cdconsul    AS   INTEGER                        NO-UNDO.
    DEF INPUT PARAM par_cdstatus    AS   INTEGER                        NO-UNDO.
    DEF INPUT PARAM par_nrdconta    LIKE craplct.nrdconta               NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt    LIKE craplct.dtmvtolt               NO-UNDO.
    DEF INPUT PARAM par_cdhistor    LIKE craplct.cdhistor               NO-UNDO.
    DEF INPUT PARAM par_dtlibera    LIKE craplct.dtlibera               NO-UNDO.
    DEF INPUT PARAM par_cddopcao    AS   CHARACTER                      NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-craplct.


    /*Se opcao 'D' muda cdstatus para trazer apenas os 
      registros a serem desbloqueados*/
    IF  par_cddopcao = "D" THEN
        par_cdstatus = 2.


    IF  par_cdconsul = 1 THEN
        DO:
            IF  par_dtmvtolt <> ? THEN
                DO:
                    RUN busca_lanctos_data(INPUT par_cdcooper,
                                           INPUT par_dtmvtolt,
                                           INPUT par_cdhistor,
                                           INPUT par_dtlibera,
                                           INPUT par_cdstatus,
                                           OUTPUT TABLE tt-craplct).
                END.
            ELSE
                DO:
                    RUN busca_lanctos_todos(INPUT par_cdcooper,
                                            INPUT par_cdhistor,
                                            INPUT par_dtlibera,
                                            INPUT par_cdstatus,
                                            OUTPUT TABLE tt-craplct).
                END.
        END.
    ELSE
        DO:
            IF  par_nrdconta > 0 THEN
                DO:
                    RUN busca_lanctos_cta(INPUT par_cdcooper,
                                          INPUT par_nrdconta,
                                          INPUT par_cdhistor,
                                          INPUT par_dtlibera,
                                          INPUT par_cdstatus,
                                          OUTPUT TABLE tt-craplct).
                END.
            ELSE
                DO:
                    RUN busca_lanctos_todos(INPUT par_cdcooper,
                                            INPUT par_cdhistor,
                                            INPUT par_dtlibera,
                                            INPUT par_cdstatus,
                                            OUTPUT TABLE tt-craplct).
                END.
        END.

    FOR EACH tt-craplct EXCLUSIVE-LOCK:

        RUN busca_data_saque(INPUT tt-craplct.cdcooper,
                             INPUT tt-craplct.nrdconta,
                             OUTPUT tt-craplct.dtdsaque).

        IF  tt-craplct.dtlibera = ? THEN
            tt-craplct.dsdesblq = "N".
        ELSE
            tt-craplct.dsdesblq = "S".

    END.


    RETURN "OK".
END.

PROCEDURE busca_lanctos_cta:
    
    DEF INPUT PARAM par_cdcooper    LIKE crapcop.cdcooper               NO-UNDO.
    DEF INPUT PARAM par_nrdconta    LIKE craplct.nrdconta               NO-UNDO.
    DEF INPUT PARAM par_cdhistor    LIKE craplct.cdhistor               NO-UNDO.
    DEF INPUT PARAM par_dtlibera    LIKE craplct.dtlibera               NO-UNDO.
    DEF INPUT PARAM par_cdstatus    AS   INTEGER                        NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-craplct.


    EMPTY TEMP-TABLE tt-craplct.
     
    CASE par_cdstatus:
        WHEN 1 THEN
            DO:
                FOR EACH craplct WHERE craplct.cdcooper = par_cdcooper AND
                                       craplct.nrdconta = par_nrdconta AND
                                       craplct.cdhistor = par_cdhistor NO-LOCK:
        
                    CREATE tt-craplct.
                    BUFFER-COPY craplct TO tt-craplct.
                END.
            END.
        WHEN 2 THEN
            DO:
                FOR EACH craplct WHERE craplct.cdcooper = par_cdcooper AND
                                       craplct.nrdconta = par_nrdconta AND
                                       craplct.cdhistor = par_cdhistor AND
                                       craplct.dtlibera = ? NO-LOCK:
                    
                    CREATE tt-craplct.
                    BUFFER-COPY craplct TO tt-craplct.
                END.
            END.
        WHEN 3 THEN
            DO:
                FOR EACH craplct WHERE craplct.cdcooper = par_cdcooper AND
                                       craplct.nrdconta = par_nrdconta AND
                                       craplct.cdhistor = par_cdhistor AND
                                       craplct.dtlibera <> ? NO-LOCK:
                    
                    CREATE tt-craplct.
                    BUFFER-COPY craplct TO tt-craplct.
                END.
            END.
    END CASE.

    RETURN "OK".
END.

PROCEDURE busca_lanctos_data:
    
    DEF INPUT PARAM par_cdcooper    LIKE crapcop.cdcooper               NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt    LIKE craplct.dtmvtolt               NO-UNDO.
    DEF INPUT PARAM par_cdhistor    LIKE craplct.cdhistor               NO-UNDO.
    DEF INPUT PARAM par_dtlibera    LIKE craplct.dtlibera               NO-UNDO.
    DEF INPUT PARAM par_cdstatus    AS   INTEGER                        NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-craplct.


    EMPTY TEMP-TABLE tt-craplct.

    CASE par_cdstatus:
        WHEN 1 THEN
            DO:
                FOR EACH craplct WHERE craplct.cdcooper = par_cdcooper AND
                                       craplct.dtmvtolt = par_dtmvtolt AND
                                       craplct.cdhistor = par_cdhistor NO-LOCK:
        
                    CREATE tt-craplct.
                    BUFFER-COPY craplct TO tt-craplct.
                END.
            END.
        WHEN 2 THEN
            DO:
                FOR EACH craplct WHERE craplct.cdcooper = par_cdcooper AND
                                       craplct.dtmvtolt = par_dtmvtolt AND
                                       craplct.cdhistor = par_cdhistor AND
                                       craplct.dtlibera = ? NO-LOCK:
                    
                    CREATE tt-craplct.
                    BUFFER-COPY craplct TO tt-craplct.
                END.
            END.
        WHEN 3 THEN
            DO:
                FOR EACH craplct WHERE craplct.cdcooper = par_cdcooper AND
                                       craplct.dtmvtolt = par_dtmvtolt AND
                                       craplct.cdhistor = par_cdhistor AND
                                       craplct.dtlibera <> ? NO-LOCK:
                    
                    CREATE tt-craplct.
                    BUFFER-COPY craplct TO tt-craplct.
                END.
            END.
    END CASE.
    
    RETURN "OK".
END.

PROCEDURE busca_lanctos_todos:
    
    DEF INPUT PARAM par_cdcooper    LIKE crapcop.cdcooper               NO-UNDO.
    DEF INPUT PARAM par_cdhistor    LIKE craplct.cdhistor               NO-UNDO.
    DEF INPUT PARAM par_dtlibera    LIKE craplct.dtlibera               NO-UNDO.
    DEF INPUT PARAM par_cdstatus    AS   INTEGER                        NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-craplct.


    EMPTY TEMP-TABLE tt-craplct.

    CASE par_cdstatus:
        WHEN 1 THEN
            DO:
                FOR EACH craplct WHERE craplct.cdcooper = par_cdcooper AND
                                       craplct.cdhistor = par_cdhistor NO-LOCK:
        
                    CREATE tt-craplct.
                    BUFFER-COPY craplct TO tt-craplct.
                END.
            END.
        WHEN 2 THEN
            DO:
                FOR EACH craplct WHERE craplct.cdcooper = par_cdcooper AND
                                       craplct.cdhistor = par_cdhistor AND
                                       craplct.dtlibera = ? NO-LOCK:
                    
                    CREATE tt-craplct.
                    BUFFER-COPY craplct TO tt-craplct.
                END.
            END.
        WHEN 3 THEN
            DO:
                FOR EACH craplct WHERE craplct.cdcooper = par_cdcooper AND
                                       craplct.cdhistor = par_cdhistor AND
                                       craplct.dtlibera <> ? NO-LOCK:
                    
                    CREATE tt-craplct.
                    BUFFER-COPY craplct TO tt-craplct.
                END.
            END.
    END CASE.

    
    RETURN "OK".
END.

PROCEDURE busca_data_saque:

    DEF INPUT PARAM par_cdcooper    LIKE    crapcop.cdcooper            NO-UNDO.
    DEF INPUT PARAM par_nrdconta    LIKE    craplct.nrdconta            NO-UNDO.

    DEF OUTPUT PARAM par_dtdsaque   AS      DATE                        NO-UNDO.
    

    FIND LAST crablct WHERE crablct.cdcooper = par_cdcooper AND
                            crablct.nrdconta = par_nrdconta AND
                           (crablct.cdhistor = 932          OR
                            crablct.cdhistor = 1511         OR
                            crablct.cdhistor = 1093)        NO-LOCK NO-ERROR.

    IF  AVAIL(crablct) THEN
        ASSIGN par_dtdsaque = crablct.dtmvtolt.
    ELSE
        ASSIGN par_dtdsaque = ?.
                
    RETURN "OK".
END.

PROCEDURE desbloqueia_procap:

    DEF INPUT PARAM TABLE FOR tt-craplct.

    DEF OUTPUT PARAM TABLE FOR tt-erro.


    EMPTY TEMP-TABLE tt-erro.

    FOR EACH tt-craplct NO-LOCK:

        RUN grava_dados(INPUT tt-craplct.cdcooper,
                        INPUT tt-craplct.cdagenci,
                        INPUT 1,
                        INPUT tt-craplct.dtmvtolt,
                        INPUT tt-craplct.cdbccxlt,
                        INPUT tt-craplct.nrdolote,
                        INPUT tt-craplct.nrdconta,
                        INPUT tt-craplct.nrdocmto,
                        INPUT tt-craplct.cdhistor,
                        INPUT tt-craplct.nrseqdig,
                        INPUT tt-craplct.vllanmto,
                        INPUT tt-craplct.nrctrpla,
                        INPUT tt-craplct.qtlanmfx,
                        INPUT tt-craplct.nrautdoc,
                        INPUT tt-craplct.nrsequni,
                        INPUT tt-craplct.dtlibera,
                        INPUT tt-craplct.dtcrdcta,
                        INPUT tt-craplct.dsdesblq,
                        INPUT tt-craplct.dtdsaque,
                        OUTPUT TABLE tt-erro).

        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF  AVAIL(tt-erro) THEN
            DO: 
                MESSAGE tt-erro.dscritic + " (Conta: " + STRING(tt-craplct.nrdconta) + ")".
                RETURN "NOK".
            END.

    END.

    RETURN "OK".
END.

PROCEDURE grava_dados:

    DEF INPUT  PARAM par_cdcooper    LIKE crapcop.cdcooper              NO-UNDO.
    DEF INPUT  PARAM par_cdagenci    LIKE crapope.cdagenci              NO-UNDO.
    DEF INPUT  PARAM par_cdoperad    LIKE crapope.cdoperad              NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt    AS   DATE                          NO-UNDO.
    DEF INPUT  PARAM par_cdbccxlt    AS   INTE                          NO-UNDO.
    DEF INPUT  PARAM par_nrdolote    AS   INTE                          NO-UNDO.
    DEF INPUT  PARAM par_nrdconta    AS   INTE                          NO-UNDO.
    DEF INPUT  PARAM par_nrdocmto    AS   DECI                          NO-UNDO.
    DEF INPUT  PARAM par_cdhistor    AS   INTE                          NO-UNDO.
    DEF INPUT  PARAM par_nrseqdig    AS   INTE                          NO-UNDO.
    DEF INPUT  PARAM par_vllanmto    AS   DECI                          NO-UNDO.
    DEF INPUT  PARAM par_nrctrpla    AS   INTE                          NO-UNDO.
    DEF INPUT  PARAM par_qtlanmfx    AS   DECI                          NO-UNDO.
    DEF INPUT  PARAM par_nrautdoc    AS   INTE                          NO-UNDO.
    DEF INPUT  PARAM par_nrsequni    AS   INTE                          NO-UNDO.
    DEF INPUT  PARAM par_dtlibera    AS   DATE                          NO-UNDO.
    DEF INPUT  PARAM par_dtcrdcta    AS   DATE                          NO-UNDO.
    DEF INPUT  PARAM par_dsdesblq    AS   CHAR                          NO-UNDO.
    DEF INPUT  PARAM par_dtdsaque    AS   DATE                          NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_dstextab    AS   CHAR                                   NO-UNDO.
    DEF VAR aux_cdcritic    AS   INTEGER                                NO-UNDO.
    DEF VAR aux_dscritic    AS   CHAR                                   NO-UNDO.      

    ASSIGN aux_dstextab = ""
           aux_cdcritic = 0
           aux_dscritic = "".

    EMPTY TEMP-TABLE tt-erro.


    FIND craplct WHERE craplct.cdcooper = par_cdcooper AND
                       craplct.dtmvtolt = par_dtmvtolt AND
                       craplct.cdagenci = par_cdagenci AND
                       craplct.cdbccxlt = par_cdbccxlt AND
                       craplct.nrdolote = par_nrdolote AND
                       craplct.nrdconta = par_nrdconta AND
                       craplct.nrdocmto = par_nrdocmto NO-ERROR.


    IF  AVAIL(craplct) THEN
        DO:
            IF  par_dsdesblq <> "N" AND
                par_dtlibera =  ?   THEN
                DO:
                    FIND crapdat WHERE crapdat.cdcooper = par_cdcooper
                                                            NO-LOCK NO-ERROR.

                    IF AVAIL crapdat THEN
                        ASSIGN craplct.dtlibera = crapdat.dtmvtolt.
                    ELSE
                    DO:
                        ASSIGN aux_cdcritic = 1
                               aux_dscritic = "".

                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT 0,
                                       INPUT 1,     /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
    
                        RETURN "NOK".
                    END.
                END.
            ELSE
                DO:
                    IF  par_dsdesblq = "N" AND
                        par_dtlibera <> ?  THEN
                        DO:
                            ASSIGN aux_cdcritic = 0
                                   aux_dscritic = "Acao nao permitida, registro ja se encontra desbloqueado.".
    
                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT 0,
                                           INPUT 1,     /** Sequencia **/
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).
    
                            RETURN "NOK".
                        END.
                END.
        END.
    ELSE
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Problema na gravacao dos dados.".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT 0,
                           INPUT 1,     /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.

    RETURN "OK".
END PROCEDURE.

PROCEDURE total_integralizado:

    DEF INPUT PARAM par_cdcooper    LIKE craplct.cdcooper       NO-UNDO.
    DEF INPUT PARAM par_nrdconta    LIKE craplct.nrdconta       NO-UNDO.

    DEF OUTPUT PARAM par_totinteg   AS  DECI                    NO-UNDO.
    DEF OUTPUT PARAM par_qtprocap   AS  INT                     NO-UNDO.

    ASSIGN par_totinteg = 0
           par_qtprocap = 0.

    FOR EACH craplct WHERE craplct.cdcooper = par_cdcooper AND
                           craplct.nrdconta = par_nrdconta AND
                           craplct.cdhistor = 930 NO-LOCK:

        ASSIGN par_totinteg = par_totinteg + craplct.vllanmto
               par_qtprocap = par_qtprocap + 1.
    END.

    RETURN "OK".
END PROCEDURE.

PROCEDURE total_integralizado_desbloqueado:

    DEF INPUT PARAM par_cdcooper    LIKE craplct.cdcooper       NO-UNDO.
    DEF INPUT PARAM par_nrdconta    LIKE craplct.nrdconta       NO-UNDO.

    DEF OUTPUT PARAM par_totdesbl   AS  DECI                    NO-UNDO.


    ASSIGN par_totdesbl = 0.

    FOR EACH craplct WHERE craplct.cdcooper = par_cdcooper AND
                           craplct.nrdconta = par_nrdconta AND
                           craplct.cdhistor = 930          AND 
                           craplct.dtlibera <> ?      NO-LOCK:

        ASSIGN par_totdesbl = par_totdesbl + craplct.vllanmto.
    END.

    RETURN "OK".
END PROCEDURE.

PROCEDURE total_resgatado:

    DEF INPUT PARAM par_cdcooper    LIKE craplct.cdcooper       NO-UNDO.
    DEF INPUT PARAM par_nrdconta    LIKE craplct.nrdconta       NO-UNDO.

    DEF OUTPUT PARAM par_totresgt   AS  DECI                    NO-UNDO.

    ASSIGN par_totresgt = 0.

    FOR EACH craplct WHERE craplct.cdcooper = par_cdcooper AND
                           craplct.nrdconta = par_nrdconta AND
                          (craplct.cdhistor = 932          OR
                           craplct.cdhistor = 1511         OR
                           craplct.cdhistor = 1093)   NO-LOCK:

        ASSIGN par_totresgt = par_totresgt + craplct.vllanmto.
    END.

    RETURN "OK".
END PROCEDURE.

PROCEDURE saldo_procap:

    DEF INPUT PARAM par_cdcooper    LIKE craplct.cdcooper           NO-UNDO.
    DEF INPUT PARAM par_nrdconta    LIKE craplct.nrdconta           NO-UNDO.

    DEF OUTPUT PARAM par_slprocap   AS  DECI                        NO-UNDO.

    DEF VAR aux_totinteg            AS  DECI                        NO-UNDO.
    DEF VAR aux_totresgt            AS  DECI                        NO-UNDO.
    DEF VAR aux_qtprocap            AS  INT                         NO-UNDO.


    RUN total_integralizado(INPUT  par_cdcooper,
                            INPUT  par_nrdconta,
                            OUTPUT aux_totinteg,
                            OUTPUT aux_qtprocap).

    RUN total_resgatado(INPUT  par_cdcooper,
                        INPUT  par_nrdconta,
                        OUTPUT aux_totresgt).

    ASSIGN par_slprocap = aux_totinteg - aux_totresgt.

    RETURN "OK".
END PROCEDURE.

PROCEDURE saldo_procap_desbloqueado:

    DEF INPUT PARAM par_cdcooper    LIKE craplct.cdcooper           NO-UNDO.
    DEF INPUT PARAM par_nrdconta    LIKE craplct.nrdconta           NO-UNDO.

    DEF OUTPUT PARAM par_sldesblo   AS  DECI                        NO-UNDO.


    DEF VAR aux_totdesbl            AS  DECI                        NO-UNDO.
    DEF VAR aux_totresgt            AS  DECI                        NO-UNDO.

    RUN total_integralizado_desbloqueado(INPUT  par_cdcooper,
                                         INPUT  par_nrdconta,
                                         OUTPUT aux_totdesbl).

    RUN total_resgatado(INPUT  par_cdcooper,
                        INPUT  par_nrdconta,
                        OUTPUT aux_totresgt).

    ASSIGN par_sldesblo = aux_totdesbl - aux_totresgt.

    RETURN "OK".
END PROCEDURE.

PROCEDURE saldo_cotas_normal:

    DEF INPUT PARAM par_cdcooper    LIKE craplct.cdcooper       NO-UNDO.
    DEF INPUT PARAM par_nrdconta    LIKE craplct.nrdconta       NO-UNDO.

    DEF OUTPUT PARAM par_slcotnor   AS   DECI                   NO-UNDO.


    DEF VAR aux_slprocap            AS   DECI                   NO-UNDO.

                            
    RUN saldo_procap(INPUT  par_cdcooper,
                     INPUT  par_nrdconta,
                     OUTPUT aux_slprocap).

    FIND crapcot WHERE crapcot.cdcooper = par_cdcooper AND
                       crapcot.nrdconta = par_nrdconta 
                       NO-LOCK NO-ERROR.

    IF  AVAIL(crapcot) THEN
        par_slcotnor = crapcot.vldcotas - aux_slprocap.
    ELSE
        RETURN "NOK".
              
    RETURN "OK".
END PROCEDURE.

PROCEDURE busca_procap_ativos:

    DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper             NO-UNDO.

    DEF OUTPUT PARAM par_totativo AS   DECI                         NO-UNDO.
    DEF OUTPUT PARAM par_vlativos AS   DECI                         NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-craplct.


    ASSIGN par_totativo = 0
           par_vlativos = 0.

    EMPTY TEMP-TABLE tt-craplct.

    FOR EACH craplct WHERE craplct.cdcooper = par_cdcooper AND
                           craplct.cdhistor = 930          AND
                           craplct.dtlibera = ?            NO-LOCK,

       FIRST crapass WHERE crapass.cdcooper = craplct.cdcooper AND
                           crapass.nrdconta = craplct.nrdconta NO-LOCK:

           CREATE tt-craplct.
           
           BUFFER-COPY craplct TO tt-craplct.
           ASSIGN tt-craplct.nmprimtl = crapass.nmprimtl
                  tt-craplct.cdageass = crapass.cdagenci
                  par_totativo = par_totativo + 1
                  par_vlativos = par_vlativos + craplct.vllanmto.

    END.

    RETURN "OK".
END PROCEDURE.

PROCEDURE busca_procap_desbl_naosac:

    DEF INPUT  PARAM  par_cdcooper  LIKE    crapcop.cdcooper            NO-UNDO.

    DEF OUTPUT PARAM  par_todbnsac  AS      DECI                        NO-UNDO.
    DEF OUTPUT PARAM  par_vldbnsac  AS      DECI                        NO-UNDO.
    DEF OUTPUT PARAM  TABLE FOR tt-craplct.


    DEF VAR aux_dtdsaque    AS      DATE                                NO-UNDO.


    EMPTY TEMP-TABLE tt-craplct.

    FOR EACH craplct WHERE craplct.cdcooper = par_cdcooper AND 
                           craplct.cdhistor = 930          AND 
                           craplct.dtlibera <> ?           NO-LOCK,

       FIRST crapass WHERE crapass.cdcooper = craplct.cdcooper AND
                           crapass.nrdconta = craplct.nrdconta NO-LOCK:

           RUN busca_data_saque( INPUT craplct.cdcooper,
                                 INPUT craplct.nrdconta,
                                OUTPUT aux_dtdsaque).

           IF  aux_dtdsaque = ? THEN
               DO:
                    CREATE tt-craplct.
                    BUFFER-COPY craplct TO tt-craplct.
                    ASSIGN tt-craplct.nmprimtl = crapass.nmprimtl
                           tt-craplct.cdageass = crapass.cdagenci
                           par_todbnsac = par_todbnsac + 1
                           par_vldbnsac = par_vldbnsac + craplct.vllanmto.

               END.

    END.

    RETURN "OK".
END PROCEDURE.

PROCEDURE busca_procap_capital_sacado:

    DEF INPUT  PARAM  par_cdcooper  LIKE    crapcop.cdcooper            NO-UNDO.

    DEF OUTPUT PARAM  par_tocapsac  AS      DECI                        NO-UNDO.
    DEF OUTPUT PARAM  par_vlcapsac  AS      DECI                        NO-UNDO.
    DEF OUTPUT PARAM  TABLE FOR tt-craplct.


    EMPTY TEMP-TABLE tt-craplct.

    FOR EACH craplct WHERE craplct.cdcooper = par_cdcooper AND 
                          (craplct.cdhistor = 932          OR
                           craplct.cdhistor = 1511         OR 
                           craplct.cdhistor = 1093)        NO-LOCK,

       FIRST crapass WHERE crapass.cdcooper = craplct.cdcooper AND
                           crapass.nrdconta = craplct.nrdconta NO-LOCK:

            CREATE tt-craplct.
            BUFFER-COPY craplct TO tt-craplct.
            ASSIGN tt-craplct.nmprimtl = crapass.nmprimtl
                   tt-craplct.cdageass = crapass.cdagenci
                   par_tocapsac = par_tocapsac + 1
                   par_vlcapsac = par_vlcapsac + craplct.vllanmto.

    END.

    RETURN "OK".  
END PROCEDURE.
