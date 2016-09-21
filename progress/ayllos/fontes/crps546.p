/*..............................................................................

    Programa: Fontes/crps546.p
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Fernando
    Data    : Dezembro/2009                     Ultima alteracao: 26/02/2014

    Dados referentes ao programa:

    Frequencia: Semanal (on-line)
    Objetivo  : - Gerar relatorio semanal das tarifas interbancárias(TIB)- SPB 
                  CECRED.
                  
    Observacoes: - Executado no processo noturno. Cadeia Exclusiva.
                   (Pode rodar na Cecred, efetuando o debito na conta 
                    movimento das cooperativas, ou nas cooperativas
                    gerando somente o relatorio);    
                 - Periodicidade: semanal toda a quinta a noite com base de 
                   quinta (semana anterior) a quarta.       
                                                                    
    Alteracao: 20/04/2009 - Solicitado pela Karina o tratamento de novas
                            mensagens:
                            STR0005R2,STR0007R2,STR0025R2,STR0028R2,STR0034R2
                            STR0006R2 e PAG0105R2
                            PAG0107R2,PAG0106R2,PAG0121R2,PAG0124R2,PAG0134R2
                            STR0006,STR0025,STR0028,STR0034
                            PAG0105,PAG0121,PAG0124,PAG0134
                            (Guilherme).
               
               24/05/2010 - Alterado layout do problema (Valor de Deb. e Cred.)
                            e ajustado o mesmo para nco gerar mais lancamentos
                            negativos (Fernando).
                            
               19/07/2010 - Nao contabilizar TIB para as mensagens STR0010,
                            PAG0111, STR0010R2 e PAG0111R2 (Diego).
                            
               04/05/2011 - Mostrar no relatório "Nao integradas no Ayllos"
                            mensagem PAG 0109R2 ref. credito na conta de 
                            liquidacao da CECRED no B.Central. Joice gera
                            esta mensagem a partir do B.Brasil com numero de
                            conta invalida (Diego).             
                            
               17/10/2011 - Tratamento mensagem PAG0143R2 solicitada pelo
                            Jonathan (Diego).        
                            
               05/01/2012 - Efetuada correcao na funcao 'f_executa' para
                            executar programa na CECRED apos feriado (Diego).
                            
               27/02/2012 - Retirar mensagens nao mais necessarias (Gabriel).
               
               21/06/2012 - Substituida gncoper pela crapcop (Tiago)
                          - Tratar mensagem PAG0142R2 (Diego).      
                          
               12/03/2013 - Retirar STR0028,STR0028R2,PAG0124,PAG0124R2
                            (Gabriel).       
                            
               28/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).  
                            
               13/01/2014 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( Andre Euzebio / SUPERO)
                            
               26/02/2014 - Ajustes para aumento de format do nome resumido da
                            cooperativa de 11 para 20 (Carlos)
..............................................................................*/

{ includes/var_batch.i }

DEFINE STREAM str_1.

DEFINE VARIABLE aux_dtiniprg AS DATE     FORMAT "99/99/9999"           NO-UNDO.
DEFINE VARIABLE aux_dtfimprg AS DATE     FORMAT "99/99/9999"           NO-UNDO.
                                                                    
DEFINE VARIABLE aux_cdagenci AS INTEGER                                NO-UNDO.
DEFINE VARIABLE aux_qtmsgenv AS INTEGER                                NO-UNDO.
DEFINE VARIABLE aux_qtmsgrec AS INTEGER                                NO-UNDO.
DEFINE VARIABLE aux_nrdocmto AS INTEGER                                NO-UNDO.
DEFINE VARIABLE rel_nrmodulo AS INTEGER   FORMAT "9"                   NO-UNDO.

DEFINE VARIABLE aux_vltarifa AS DECIMAL                                NO-UNDO.
DEFINE VARIABLE aux_totalcop AS DECIMAL                  EXTENT 5      NO-UNDO.
DEFINE VARIABLE aux_totalpac AS DECIMAL                  EXTENT 5      NO-UNDO.
DEFINE VARIABLE aux_totalmsg AS DECIMAL                  EXTENT 2      NO-UNDO.

DEFINE VARIABLE aux_nmextcab AS CHARACTER                              NO-UNDO.
DEFINE VARIABLE aux_dscooper AS CHARACTER                              NO-UNDO.
DEFINE VARIABLE aux_dsagenci AS CHARACTER                              NO-UNDO.
DEFINE VARIABLE rel_nmresemp AS CHARACTER                              NO-UNDO.
DEFINE VARIABLE rel_nmempres AS CHARACTER FORMAT "x(15)"               NO-UNDO.
DEFINE VARIABLE rel_nmrelato AS CHARACTER FORMAT "x(40)" EXTENT 5      NO-UNDO.
DEFINE VARIABLE rel_nmmodulo AS CHARACTER FORMAT "x(15)" EXTENT 5      NO-UNDO.
DEFINE VARIABLE rel_dsagenci AS CHARACTER FORMAT "x(40)"               NO-UNDO.
DEFINE VARIABLE aux_fill_67  AS CHARACTER FORMAT "x(67)"               NO-UNDO.

DEFINE VARIABLE aux_flgexist AS LOGICAL                                NO-UNDO.
DEFINE VARIABLE aux_flimpres AS LOGICAL                                NO-UNDO.

DEFINE TEMP-TABLE w-dados-coop                                         NO-UNDO
       FIELD cdcooper AS INTE
       FIELD qtmsgenv AS INTE
       FIELD qtmsgrec AS INTE
       FIELD vltarenv AS DECI
       FIELD vltarrec AS DECI
       FIELD vltotal  AS DECI
INDEX w-dados1 AS PRIMARY cdcooper.

DEFINE TEMP-TABLE w-dados-pac                                          NO-UNDO
       FIELD cdagenci AS INTE
       FIELD qtmsgenv AS INTE
       FIELD qtmsgrec AS INTE
       FIELD vltarenv AS DECI
       FIELD vltarrec AS DECI
       FIELD vltotal  AS DECI
INDEX w-dados1 AS PRIMARY cdagenci.

DEFINE TEMP-TABLE w-msg-desc                                           NO-UNDO
       FIELD cdagenci AS INTE
       FIELD dtmensag AS DATE
       FIELD dsmensag AS CHAR
       FIELD qtmensag AS INTE
       FIELD vltarifa AS DECI  
INDEX w-msg1 AS PRIMARY cdagenci dtmensag dsmensag.

FORM "TED/TEC - DEVOLU TED/TEC"
     "   -   "
     "Valor Tarifas"
     "   -   "
     "  TED/TEC: R$"  aux_vltarifa  FORMAT ">>9.99"
     SKIP(1)
     "PERIODO DE " aux_dtiniprg " A " aux_dtfimprg 
     SKIP(2)
     WITH NO-BOX NO-LABELS WIDTH 80 FRAME f_cabe.
     
FORM aux_nmextcab   FORMAT "x(40)"
     SKIP(1)
     WITH NO-BOX NO-LABELS WIDTH 80 FRAME f_nao_integradas.

FORM "TED/TEC"                          AT 31
     SKIP
     "Nossa Remessa"                    AT 24
     "Sua Remessa"                      AT 46
     SKIP
     "----------------------------------------------------------" AT 22
     SKIP
     "Qtde"                             AT 26
     "Vlr. Debito"                      AT 31
     "Qtde"                             AT 48
     "Vlr. Cred."                     AT 54
     "TOTAL R$"                         AT 72
     SKIP
     "--------------------"             AT 1
     "--------"                         AT 22
     "-----------"                  AT 31
     "--------"                         AT 44
     "-----------"                  AT 53
     "--------------"                AT 66
     WITH NO-BOX NO-LABELS WIDTH 80 FRAME f_label.

FORM SKIP
     "PA"                                                      AT 1
     w-dados-pac.cdagenci  FORMAT ">>9"                        AT 9 
     w-dados-pac.qtmsgenv  FORMAT ">>>,>>9"                    AT 14
     w-dados-pac.vltarenv  FORMAT "->>>,>>>,>>9.99"            AT 22
     w-dados-pac.qtmsgrec  FORMAT ">>>,>>9"                    AT 39
     w-dados-pac.vltarrec  FORMAT "->>>,>>>,>>9.99"            AT 47
     w-dados-pac.vltotal   FORMAT "->>,>>>,>>9.99"             AT 66
     WITH NO-BOX NO-LABELS DOWN WIDTH 80 FRAME f_tarif_pac.

FORM aux_fill_67                                               AT 13 SKIP
     "TOTAL      "                                                       
     aux_totalpac[1]  FORMAT ">>>,>>9"                         AT 14     
     aux_totalpac[2]  FORMAT "->>>,>>>,>>9.99"                 AT 22     
     aux_totalpac[3]  FORMAT ">>>,>>9"                         AT 39     
     aux_totalpac[4]  FORMAT "->>>,>>>,>>9.99"                 AT 47     
     aux_totalpac[5]  FORMAT "->>,>>>,>>9.99"                  AT 66     
     WITH NO-BOX NO-LABELS WIDTH 80 FRAME f_totais_pac.

FORM SKIP
     aux_dscooper           FORMAT "x(20)"                     AT 1
     w-dados-coop.qtmsgenv  FORMAT ">>>,>>9"                   AT 23
     w-dados-coop.vltarenv  FORMAT "->>>,>>9.99"               AT 31
     w-dados-coop.qtmsgrec  FORMAT ">>>,>>9"                   AT 45
     w-dados-coop.vltarrec  FORMAT "->>>,>>9.99"               AT 53
     w-dados-coop.vltotal   FORMAT "->,>>>,>>9.99"             AT 67
     WITH NO-BOX NO-LABELS DOWN WIDTH 80 FRAME f_tarif_coop.

FORM "----------------------------------------------------------" AT 22 SKIP
     "TOTAL      "
     aux_totalcop[1]  FORMAT ">>>,>>9"                         AT 23
     aux_totalcop[2]  FORMAT "->>>,>>9.99"                 AT 31
     aux_totalcop[3]  FORMAT ">>>,>>9"                         AT 45
     aux_totalcop[4]  FORMAT "->>>,>>9.99"                 AT 53
     aux_totalcop[5]  FORMAT "->,>>>,>>9.99"                  AT 67
     WITH NO-BOX NO-LABELS WIDTH 80 FRAME f_totais_cop.

FORM 
     w-msg-desc.cdagenci LABEL "Agencia"       FORMAT "zzz9"
     w-msg-desc.dtmensag LABEL "Dt. Mensagem"  FORMAT "99/99/9999"
     w-msg-desc.dsmensag LABEL "Mensagem"      FORMAT "x(20)"
     w-msg-desc.qtmensag LABEL "Quantidade"    FORMAT "z,zzz,zz9"
     w-msg-desc.vltarifa LABEL "Valor"         FORMAT "-zzz,zzz,zz9.99"
     WITH DOWN NO-LABELS WIDTH 132 FRAME f_outras_tarifas.

FORM
     "TOTAL GERAL" AT 32
     aux_totalmsg[1] FORMAT "z,zzz,zz9"
     aux_totalmsg[2] FORMAT "-zzz,zzz,zz9.99"
     WITH NO-LABELS WIDTH 132 FRAME f_totais_msg.

/* Verifica se a o programa pode ser executado. */
FUNCTION f_executa RETURN LOGICAL (INPUT par_dtmvtolt AS DATE):

    DEFINE VARIABLE aux_dtmvtolt AS DATE        NO-UNDO.
    DEFINE VARIABLE aux_flgferia AS LOG         NO-UNDO.

    IF  WEEKDAY(par_dtmvtolt) = 5  THEN  /* Quinta-Feira */ 
        DO:
           /* Programa sempre rodará com base de quarta a quinta */
           ASSIGN aux_dtiniprg = glb_dtmvtolt - 7
                  aux_dtfimprg = glb_dtmvtolt - 1. 
           RETURN TRUE.
        END.
     
  /* ***********************************************************************
     Tratado para rodar no proximo dia util quando existir feriado na semana
    ************************************************************************ */

    /* Obtem dia do feriado */
    IF   glb_cdcooper = 3  THEN
         /* Se estiver executando na CECRED apos o feriado, o processo estara
            com data de um dia antes do feriado */ 
         ASSIGN par_dtmvtolt = par_dtmvtolt + 1.  
    ELSE
         /* Nas demais cooperativas, a data do processo sera o dia atual */ 
         ASSIGN par_dtmvtolt = par_dtmvtolt - 1.  
   
    ASSIGN aux_flgferia = FALSE.
    
    DO WHILE TRUE:
     
       IF  WEEKDAY(par_dtmvtolt) = 4 AND aux_flgferia  THEN /* Quarta-Feira */ 
           DO:  
               /* Programa sempre rodará com base de quinta a quarta*/
               ASSIGN aux_dtiniprg = par_dtmvtolt - 6
                      aux_dtfimprg = par_dtmvtolt.
      
               RETURN TRUE.
           END.
       ELSE
       IF  CAN-FIND(crapfer WHERE 
                    crapfer.cdcooper = glb_cdcooper AND
                    crapfer.dtferiad = par_dtmvtolt    )  OR
          (WEEKDAY(par_dtmvtolt) = 1 OR WEEKDAY(par_dtmvtolt) = 7) THEN
           DO:
              ASSIGN par_dtmvtolt = par_dtmvtolt - 1
                     aux_flgferia = TRUE.
              NEXT.
           END.
      
       LEAVE.
    END. /* Fim do DO WHILE */
   
    RETURN FALSE.
END. /* Fim da FUNCTION */

ASSIGN glb_cdprogra = "crps546"
       aux_fill_67  = FILL("-",67).

RUN fontes/iniprg.p.

IF  glb_cdcritic > 0  THEN
    RETURN.      

/*........................................................................... */
FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF  NOT AVAILABLE crapcop  THEN
    DO:
       glb_cdcritic = 651.
       RUN fontes/critic.p.
       UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                         " - " + glb_cdprogra + "' --> '"  +
                         glb_dscritic + " >> log/proc_batch.log").
       RETURN.
    END.

/*........................................................................... */
FIND crapdat WHERE crapdat.cdcooper = glb_cdcooper  NO-LOCK NO-ERROR.

IF  NOT AVAILABLE crapdat  THEN 
    DO:
       glb_cdcritic = 1.
       RUN fontes/critic.p.
       UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                         " - " + glb_cdprogra + "' --> '"  +
                         glb_dscritic + " >> log/proc_batch.log").
       RETURN.
    END.

/*........................................................................... */
FIND FIRST gncdtrf NO-LOCK NO-ERROR.

IF  AVAILABLE gncdtrf  THEN
    ASSIGN aux_vltarifa = gncdtrf.vltedtec.

/*........................................................................... */
IF   f_executa(glb_dtmvtolt) THEN 
     DO:
        IF  glb_cdcooper = 3 THEN      
            RUN pi_executa_por_coop.     
        ELSE                               
            /* Executa para todos os PAs da Cooperativa selecionada */
            RUN pi_executa_por_pac.   
     END.
ELSE 
     DO:
        RUN fontes/fimprg.p.
        RETURN.
     END.
                                        
RUN fontes/fimprg.p.
/*........................................................................... */
PROCEDURE pi_executa_por_pac.

    FOR EACH gntarcp WHERE gntarcp.cdcooper  = glb_cdcooper     AND
                           gntarcp.dtmvtolt >= aux_dtiniprg     AND
                           gntarcp.dtmvtolt <= aux_dtfimprg     AND
                          (gntarcp.cdtipdoc  = 14           OR
                           gntarcp.cdtipdoc  = 15             ) NO-LOCK:

        FIND w-dados-pac WHERE
             w-dados-pac.cdagenci = gntarcp.cdagenci EXCLUSIVE-LOCK NO-ERROR.
     
        IF  NOT AVAILABLE w-dados-pac  THEN
            DO:
               CREATE w-dados-pac.
               ASSIGN w-dados-pac.cdagenci = gntarcp.cdagenci.
            END.

        /* Debitadas em conta corrente */
        IF   gntarcp.cdtipdoc = 15    THEN
             ASSIGN w-dados-pac.qtmsgenv = w-dados-pac.qtmsgenv +
                                                          gntarcp.qtdocmto
                    w-dados-pac.vltarenv = w-dados-pac.vltarenv + 
                                                          gntarcp.vldocmto.
        ELSE
             ASSIGN w-dados-pac.qtmsgrec = w-dados-pac.qtmsgrec +
                                                          gntarcp.qtdocmto
                    w-dados-pac.vltarrec = w-dados-pac.vltarrec +
                                                          gntarcp.vldocmto.
    
    END. /* END FOREACH */

    FOR EACH gnmvspb WHERE gnmvspb.cdcooper =  glb_cdcooper AND
                           gnmvspb.dtmensag >= aux_dtiniprg AND
                           gnmvspb.dtmensag <= aux_dtfimprg NO-LOCK:

        IF  NOT CAN-DO("STR0008,PAG0108,STR0005,PAG0107," +
                       "STR0037,PAG0137,STR0010,PAG0111,STR0008R2,PAG0108R2," +
                       "STR0037R2,PAG0137R2,STR0010R2,"  +
                       "PAG0111R2,STR0006R2," +
                       "STR0005R2,STR0007R2,STR0025R2,STR0034R2," +
                       "PAG0107R2,PAG0121R2,PAG0134R2,PAG0142R2," +
                       "PAG0143R2,STR0006,STR0025,STR0034," +
                       "PAG0121,PAG0134",
                       STRING(gnmvspb.dsmensag))              THEN
            DO:
                IF   gnmvspb.dsdebcre = "C"  THEN
                     ASSIGN aux_cdagenci = gnmvspb.cdagencr.
                ELSE
                     ASSIGN aux_cdagenci = gnmvspb.cdagendb.

                RUN cria_msg_desc. 
            END.
        ELSE
            NEXT.

    END. /* Fim do FOR EACH - gnmvspb */

    RUN imprime_pac.

END PROCEDURE.
/*........................................................................... */
PROCEDURE pi_executa_por_coop.
    FOR EACH gntarcp WHERE gntarcp.dtmvtolt >= aux_dtiniprg     AND
                           gntarcp.dtmvtolt <= aux_dtfimprg     AND
                          (gntarcp.cdtipdoc  = 14           OR
                           gntarcp.cdtipdoc  = 15             ) NO-LOCK:
    
        FIND crapcop WHERE crapcop.cdagectl = gntarcp.cdagectl NO-LOCK NO-ERROR.
    
        FIND w-dados-coop WHERE 
             w-dados-coop.cdcooper = crapcop.cdcooper EXCLUSIVE-LOCK NO-ERROR.
     
        IF  NOT AVAILABLE w-dados-coop  THEN
            DO:
               CREATE w-dados-coop.
               ASSIGN w-dados-coop.cdcooper = crapcop.cdcooper.
            END.
     
        /* Debitadas em conta corrente */
        IF   gntarcp.cdtipdoc = 15    THEN
             ASSIGN w-dados-coop.qtmsgenv = w-dados-coop.qtmsgenv +
                                                            gntarcp.qtdocmto
                    w-dados-coop.vltarenv = w-dados-coop.vltarenv + 
                                                            gntarcp.vldocmto.
        ELSE
             ASSIGN w-dados-coop.qtmsgrec = w-dados-coop.qtmsgrec +
                                                            gntarcp.qtdocmto
                    w-dados-coop.vltarrec = w-dados-coop.vltarrec +
                                                            gntarcp.vldocmto.

    END. /* Fim do FOR EACH - gntarcp */

    FOR EACH gnmvspb WHERE gnmvspb.dtmensag >= aux_dtiniprg AND
                           gnmvspb.dtmensag <= aux_dtfimprg NO-LOCK:

        IF  (gnmvsp.cdcooper = 0  AND  /* Agencia inexistente */ 
             NOT CAN-DO("STR0004,STR0010,STR0010R2,PAG0111,PAG0111R2",
             STRING(gnmvspb.dsmensag)))  OR
             gnmvspb.cdcooper = 3  AND gnmvspb.cdagenci = 0  OR 
             NOT CAN-DO("STR0004,STR0010,STR0010R2,PAG0111,PAG0111R2," + 
                        "STR0008,PAG0108,STR0005,PAG0107," +
                        "STR0037,PAG0137,STR0008R2,PAG0108R2," +
                        "STR0037R2,PAG0137R2,"  +
                        "STR0005R2,STR0007R2,STR0025R2,STR0034R2," +
                        "PAG0107R2,PAG0121R2,PAG0134R2,PAG0142R2," +
                        "PAG0143R2,STR0006,STR0025,STR0034," +
                        "PAG0121,PAG0134",
                        STRING(gnmvspb.dsmensag))   THEN
             DO:
                IF   gnmvspb.dsdebcre = "C"  THEN
                     ASSIGN aux_cdagenci = gnmvspb.cdagencr.
                ELSE
                     ASSIGN aux_cdagenci = gnmvspb.cdagendb.

                RUN cria_msg_desc. 
             END.
        ELSE
             NEXT.

    END. /* Fim do FOR EACH - gnmvspb */

    RUN imprime_coop.

END PROCEDURE.
/*........................................................................... */
PROCEDURE imprime_coop.

    ASSIGN glb_nmformul = ""
           glb_nrcopias = 1
    
           aux_flgexist = FALSE
           glb_nmarqimp = "rl/crrl535.lst".
    
    OUTPUT STREAM str_1 TO  VALUE(glb_nmarqimp)  PAGED PAGE-SIZE 84.
    
    { includes/cabrel080_1.i }          /*  Monta cabecalho do relatorio  */

    VIEW STREAM str_1 FRAME f_cabrel080_1.

    FIND FIRST w-dados-coop NO-LOCK NO-ERROR.
    
    IF   AVAILABLE w-dados-coop   THEN
         DO:
             ASSIGN aux_flimpres = TRUE.
    
             DISPLAY STREAM str_1 aux_dtiniprg aux_dtfimprg  
                                  aux_vltarifa WITH FRAME f_cabe.

             DISPLAY STREAM str_1 /* aux_fill_67 */ WITH FRAME f_label.
         END.
    
    /* Imprime registros das cooperativas filiadas 
       Nas mensagens da Central nao é informado o número da agencia
       Sempre irá cair nas não integradas no ayllos */
    FOR EACH w-dados-coop WHERE w-dados-coop.cdcooper <> 3
                                BREAK BY w-dados-coop.cdcooper:
    
        FIND crapcop WHERE crapcop.cdcooper = w-dados-coop.cdcooper 
                           NO-LOCK NO-ERROR. 
    
               /* Nossa Remessa - o que enviamos - valor negativo */
        ASSIGN w-dados-coop.vltarenv = w-dados-coop.vltarenv
               w-dados-coop.vltotal  = w-dados-coop.vltarrec -
                                       w-dados-coop.vltarenv
               aux_dscooper          = TRIM(crapcop.nmrescop)
               
               /* Incrementa Totais */
               aux_totalcop[1]  = aux_totalcop[1] +  w-dados-coop.qtmsgenv
               aux_totalcop[2]  = aux_totalcop[2] +  w-dados-coop.vltarenv
               aux_totalcop[3]  = aux_totalcop[3] +  w-dados-coop.qtmsgrec
               aux_totalcop[4]  = aux_totalcop[4] +  w-dados-coop.vltarrec
               
               aux_flgexist            = TRUE.
    
        DOWN STREAM str_1 WITH FRAME f_tarif_coop.
        
        IF   LAST-OF(w-dados-coop.cdcooper)   THEN
             DO:
                IF   w-dados-coop.vltotal <> 0 THEN
                     RUN cria_lancamento(INPUT crapcop.nrctacmp,
                                         INPUT w-dados-coop.vltotal).
             END.
        
        DISPLAY STREAM str_1 aux_dscooper          w-dados-coop.qtmsgenv
                             w-dados-coop.vltarenv w-dados-coop.qtmsgrec
                             w-dados-coop.vltarrec w-dados-coop.vltotal
                             WITH FRAME f_tarif_coop.
    
    END. /* Fim do FOR EACH w-dados-coop */
    
    IF  aux_flgexist  THEN
        DO:
           ASSIGN aux_totalcop[5] = aux_totalcop[4] - aux_totalcop[2].   
               
           DISPLAY STREAM str_1 aux_totalcop[1] aux_totalcop[2] aux_totalcop[3] 
                                aux_totalcop[4] aux_totalcop[5] /* aux_fill_67 */
                                WITH FRAME f_totais_cop.
        END.
    
    ASSIGN aux_flgexist = FALSE.
    
    FIND FIRST w-msg-desc NO-LOCK NO-ERROR.
    
    IF   AVAILABLE w-msg-desc   THEN
         DO:
            PAGE STREAM str_1.
    
            ASSIGN aux_nmextcab = "==> Nao integradas no Ayllos <=="
                   aux_flimpres = TRUE.
    
            DISPLAY STREAM str_1 aux_dtiniprg aux_dtfimprg 
                                 aux_vltarifa WITH FRAME f_cabe.
                                 
            DISPLAY STREAM str_1 aux_nmextcab WITH FRAME f_nao_integradas.
         END.
    
    /* Mensages nao esperadas ou de agencias nao cadastradas */
    FOR EACH w-msg-desc BY w-msg-desc.dtmensag 
                        BY w-msg-desc.cdagenci:
    
        ASSIGN w-msg-desc.vltarifa = w-msg-desc.qtmensag * aux_vltarifa
               aux_flgexist        = TRUE
               aux_totalmsg[1]     = aux_totalmsg[1] + w-msg-desc.qtmensag
               aux_totalmsg[2]     = aux_totalmsg[2] + w-msg-desc.vltarifa.
    
        DISPLAY STREAM str_1 w-msg-desc.cdagenci w-msg-desc.dtmensag
                             w-msg-desc.dsmensag w-msg-desc.vltarifa
                             w-msg-desc.qtmensag WITH FRAME f_outras_tarifas.
    
        DOWN STREAM str_1 WITH FRAME f_outras_tarifas.
    END.
    
    IF  aux_flgexist  THEN
        DISPLAY STREAM str_1 aux_totalmsg[1] aux_totalmsg[2] 
                             WITH FRAME f_totais_msg.
    
    IF  aux_flimpres = FALSE  THEN
        PUT STREAM str_1 UNFORMAT "NAO HA MENSAGENS TARIFADAS NO PERIODO DE " + 
                         STRING(aux_dtiniprg, "99/99/9999") + " A " +
                         STRING(aux_dtfimprg, "99/99/9999") + ".".
    
    OUTPUT STREAM str_1 CLOSE.
    
    RUN fontes/imprim.p.

END PROCEDURE.
/*........................................................................... */
PROCEDURE imprime_pac.

    ASSIGN glb_nmformul = ""
           glb_nrcopias = 1
    
           aux_flgexist = FALSE
           glb_nmarqimp = "rl/crrl546.lst".
    
    OUTPUT STREAM str_1 TO  VALUE(glb_nmarqimp)  PAGED PAGE-SIZE 84.

    { includes/cabrel080_1.i }          /*  Monta cabecalho do relatorio  */
    
    VIEW STREAM str_1 FRAME f_cabrel080_1.
    
    FIND FIRST w-dados-pac NO-LOCK NO-ERROR.
    
    IF   AVAILABLE w-dados-pac   THEN
         DO:
             ASSIGN aux_flimpres = TRUE.
    
             DISPLAY STREAM str_1 aux_dtiniprg aux_dtfimprg  
                                  aux_vltarifa WITH FRAME f_cabe.

             DISPLAY STREAM str_1 aux_fill_67 WITH FRAME f_label.
         END.
    
    /* Imprime registros das cooperativas filiadas */
    FOR EACH w-dados-pac
          BY w-dados-pac.cdagenci:
        /* Nossa Remessa - o que enviamos - valor negativo */
        ASSIGN w-dados-pac.vltarenv = w-dados-pac.vltarenv 
               w-dados-pac.vltotal  = w-dados-pac.vltarrec -
                                      w-dados-pac.vltarenv.
               
               /* Incrementa Totais */
               ASSIGN aux_totalpac[1] = aux_totalpac[1] +  w-dados-pac.qtmsgenv
                      aux_totalpac[2] = aux_totalpac[2] +  w-dados-pac.vltarenv
                      aux_totalpac[3] = aux_totalpac[3] +  w-dados-pac.qtmsgrec
                      aux_totalpac[4] = aux_totalpac[4] +  w-dados-pac.vltarrec
               
                      aux_flgexist            = TRUE.
    
        DISPLAY STREAM str_1 w-dados-pac.cdagenci w-dados-pac.qtmsgenv
                             w-dados-pac.vltarenv w-dados-pac.qtmsgrec
                             w-dados-pac.vltarrec w-dados-pac.vltotal
                             WITH FRAME f_tarif_pac.
    
        DOWN STREAM str_1 WITH FRAME f_tarif_pac.
    END. /* Fim do FOR EACH w-dados-pac */
    
    IF  aux_flgexist  THEN
        DO:
           ASSIGN aux_totalpac[5] = aux_totalpac[4] - aux_totalpac[2]. 
      
           DISPLAY STREAM str_1 aux_totalpac[1] aux_totalpac[2] aux_totalpac[3] 
                                aux_totalpac[4] aux_totalpac[5] 
                                WITH FRAME f_totais_pac.
        END.
    
    ASSIGN aux_flgexist = FALSE.
    
    FIND FIRST w-msg-desc NO-LOCK NO-ERROR.
    
    IF   AVAILABLE w-msg-desc   THEN
         DO:
            PAGE STREAM str_1.
    
            ASSIGN aux_nmextcab = "Nao integradas no Ayllos"
                   aux_flimpres = TRUE.
    
            DISPLAY STREAM str_1 aux_dtiniprg aux_dtfimprg   
                                 aux_vltarifa WITH FRAME f_cabe.
                                 
            DISPLAY STREAM str_1 aux_nmextcab WITH FRAME f_nao_integradas.
         END.
    
    /* Mensages nao esperadas ou de agencias nao cadastradas */
    FOR EACH w-msg-desc BY w-msg-desc.dtmensag 
                           BY w-msg-desc.cdagenci:
    
        ASSIGN w-msg-desc.vltarifa = w-msg-desc.qtmensag * aux_vltarifa
               aux_flgexist        = TRUE
               aux_totalmsg[1]     = aux_totalmsg[1] + w-msg-desc.qtmensag
               aux_totalmsg[2]     = aux_totalmsg[2] + w-msg-desc.vltarifa. 
    
        DISPLAY STREAM str_1 w-msg-desc.cdagenci w-msg-desc.dtmensag
                             w-msg-desc.dsmensag w-msg-desc.vltarifa
                             w-msg-desc.qtmensag WITH FRAME f_outras_tarifas.
    
        DOWN STREAM str_1 WITH FRAME f_outras_tarifas.
    END.
    
    IF  aux_flgexist  THEN
        DISPLAY STREAM str_1 aux_totalmsg[1] aux_totalmsg[2] 
                             WITH FRAME f_totais_msg.
    
    IF  aux_flimpres = FALSE  THEN
        PUT STREAM str_1 UNFORMAT "NAO HA MENSAGENS TARIFADAS NO PERIODO DE " + 
                         STRING(aux_dtiniprg, "99/99/9999") + " A " +
                         STRING(aux_dtfimprg, "99/99/9999") + ".".
    
    OUTPUT STREAM str_1 CLOSE.
    
    RUN fontes/imprim.p.

END PROCEDURE.
/*........................................................................... */
PROCEDURE cria_msg_desc:

    FIND w-msg-desc WHERE w-msg-desc.cdagenci = gnmvspb.cdagenci AND
                          w-msg-desc.dtmensag = gnmvspb.dtmensag AND
                          w-msg-desc.dsmensag = gnmvspb.dsmensag 
                          EXCLUSIVE-LOCK NO-ERROR.

    IF   NOT AVAILABLE w-msg-desc  THEN
         DO:
            CREATE w-msg-desc.
            ASSIGN w-msg-desc.cdagenci = aux_cdagenci
                   w-msg-desc.dtmensag = gnmvspb.dtmensag
                   w-msg-desc.dsmensag = gnmvspb.dsmensag
                   w-msg-desc.qtmensag = 1.
         END.
    ELSE
         ASSIGN w-msg-desc.qtmensag = w-msg-desc.qtmensag + 1.
END.
/*............................................................................*/
PROCEDURE cria_lancamento:

 DEFINE INPUT PARAMETER par_nrctacmp AS INTEGER             NO-UNDO.
 DEFINE INPUT PARAMETER par_vlrlamto AS DECIMAL             NO-UNDO. 

 DEFINE VARIABLE aux_cdhistor        AS INTEGER             NO-UNDO.

 IF   par_vlrlamto < 0   THEN
      ASSIGN aux_cdhistor = 812 /* Debito TED/TEC Conta da Cooperativa */
             par_vlrlamto = par_vlrlamto * -1. 
 ELSE
      ASSIGN aux_cdhistor = 813. /* Credito TED/TEC Conta da Cooperativa */

  /* Pegar número da IF - CECRED */
 FIND crapcop WHERE crapcop.cdcooper = 3 NO-LOCK NO-ERROR.

 DO WHILE TRUE:

    FIND craplot WHERE craplot.cdcooper = glb_cdcooper     AND
                       craplot.dtmvtolt = glb_dtmvtopr     AND
                       craplot.cdagenci = 1                AND 
                       craplot.cdbccxlt = crapcop.cdbcoctl AND 
                       craplot.nrdolote = 7102             
                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
   
    IF   NOT AVAILABLE craplot   THEN
         IF   LOCKED craplot   THEN
              DO:
                 PAUSE 1 NO-MESSAGE.
                 NEXT.
              END.
         ELSE
              DO:
                 CREATE craplot.
                 ASSIGN craplot.dtmvtolt = glb_dtmvtopr
                        craplot.cdagenci = 1   
                        craplot.cdbccxlt = crapcop.cdbcoctl 
                        craplot.nrdolote = 7102 
                        craplot.tplotmov = 1    
                        craplot.cdcooper = glb_cdcooper.
                  VALIDATE craplot.
              END.  

    LEAVE.
 END. /* Fim do DO WHILE TRUE */

 ASSIGN aux_nrdocmto = craplot.nrseqdig + 1.

 DO WHILE TRUE:

    FIND craplcm WHERE craplcm.cdcooper = glb_cdcooper     AND
                       craplcm.dtmvtolt = craplot.dtmvtolt AND
                       craplcm.cdagenci = craplot.cdagenci AND
                       craplcm.cdbccxlt = craplot.cdbccxlt AND
                       craplcm.nrdolote = craplot.nrdolote AND
                       craplcm.nrdctabb = par_nrctacmp     AND
                       craplcm.nrdocmto = aux_nrdocmto
                       USE-INDEX craplcm1 NO-LOCK NO-ERROR.

    IF   AVAILABLE craplcm THEN
         aux_nrdocmto = (aux_nrdocmto + 10000).
    ELSE
         LEAVE.

 END. /* Fim do DO WHILE TRUE */

 CREATE craplcm.
 ASSIGN craplcm.cdcooper = glb_cdcooper
        craplcm.nrdconta = par_nrctacmp
        craplcm.nrdctabb = par_nrctacmp
        craplcm.dtmvtolt = craplot.dtmvtolt
        craplcm.dtrefere = craplot.dtmvtolt
        craplcm.cdagenci = craplot.cdagenci
        craplcm.cdbccxlt = craplot.cdbccxlt
        craplcm.nrdolote = craplot.nrdolote
        craplcm.nrdocmto = aux_nrdocmto
        craplcm.cdhistor = aux_cdhistor
        craplcm.vllanmto = par_vlrlamto
        craplcm.nrseqdig = craplot.nrseqdig + 1.
 VALIDATE craplcm.

 ASSIGN craplot.qtinfoln = craplot.qtinfoln + 1
        craplot.qtcompln = craplot.qtcompln + 1
        craplot.nrseqdig = craplcm.nrseqdig.
 
 IF   aux_cdhistor = 812   THEN /* Debito de TIB */                
      ASSIGN craplot.vlinfodb = craplot.vlinfodb + craplcm.vllanmto
             craplot.vlcompdb = craplot.vlcompdb + craplcm.vllanmto.
 ELSE
      ASSIGN craplot.vlinfocr = craplot.vlinfocr + craplcm.vllanmto
             craplot.vlcompcr = craplot.vlcompcr + craplcm.vllanmto.

 FIND CURRENT craplot NO-LOCK NO-ERROR.

END.
                                   
