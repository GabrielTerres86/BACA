/* ..........................................................................

   Programa: Fontes/crps063.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Agosto/93.                   Ultima atualizacao: 14/01/2014

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 034.
               Efetuar os debitos do IPMF nas contas.

   Alteracoes: 05/07/94 - Alterado o literal "cruzeiros reais".

               06/12/94 - Alterado para nao gerar lancamento zerado (Deborah).

               16/12/94 - Alterado para nao rodar depois de 06/01/95 (Deborah).

               14/01/97 - Alterado para rodar a partir de 23/01/97 (Deborah).

               22/01/97 - Alteracao na data de recolhimento da CPMF (Deborah).

               10/03/97 - Se for conta 85448 (Consumo) gerar aviso de debito
                          (Odair).

               17/03/97 - Gerar aviso de debito para inpessoa <> 1 (Odair)

               27/08/97 - Alterado para incluir o campo flgproce na criacao
                          do crapavs (Deborah).

               16/02/98 - Alterar a data final da CPMF (Odair)

               23/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               08/07/98 - Incluir novas contas para CCOH (Odair)

               07/06/1999 - Tratar CPMF (Deborah).

               07/07/99 - Colocar cod da DARF (Odair)

               19/07/99 - Alterado para chamar a rotina de impressao (Edson).

               02/02/2000 - Gerar pedido de impressao (Deborah).
               
               02/01/2001 - Mostrar o periodo de apuracao do CPMF no lugar do
                            numero do documento. (Eduardo).

               04/09/2002 - Tratar contas com mandado de seguranca e deposito
                            em juizo (Deborah).

               14/10/2002 - Acerto da ultima alteracao (Deborah).

               31/03/2003 - Incluir c/c Administrativa Concredi (Ze Eduardo).
               
               16/04/2003 - Acerto nos valores das c/c isentas (Ze Eduardo).

               28/06/2005 - Alimentado campo cdcooper das tabelas craplot,
                            craplcm e crapavs (Diego).

               30/12/2005 - Alterado a data do recolhimento - 5 dias uteis
                            depois do encerramento (Deborah)

               06/03/2006 - Unificacao Bancos(Mirtes)

               31/01/2007 - Tratamento para contas administrativas (Julio) 
               
               19/12/2007 - Incluidos valores do INSS - BANCOOB (Evandro).
               
               14/01/2014 - Inclusao de VALIDATE craplot, craplcm e crapavs
                            (Carlos)
               
............................................................................. */

DEF STREAM str_1.

{ includes/var_batch.i }  

{ includes/var_cpmf.i } 

DEF        VAR tot_qtlancto AS INT     FORMAT "zzz,zz9"              NO-UNDO.
DEF        VAR tot_vlbasipm AS DECIMAL FORMAT "zzzzz,zzz,zzz,zz9.99" NO-UNDO.
DEF        VAR tot_vldoipmf AS DECIMAL FORMAT "zzzzz,zzz,zzz,zz9.99" NO-UNDO.
DEF        VAR tot_qtipmmfx AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.9999" NO-UNDO.

DEF        VAR ass_qtlancto AS INT     FORMAT "zzz,zz9"              NO-UNDO.
DEF        VAR ass_vlbasipm AS DECIMAL FORMAT "zzzzz,zzz,zzz,zz9.99" NO-UNDO.
DEF        VAR ass_vldoipmf AS DECIMAL FORMAT "zzzzz,zzz,zzz,zz9.99" NO-UNDO.
DEF        VAR ass_qtipmmfx AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.9999" NO-UNDO.

DEF        VAR cch_qtlancto AS INT     FORMAT "zzz,zz9"              NO-UNDO.
DEF        VAR cch_vlbasipm AS DECIMAL FORMAT "zzzzz,zzz,zzz,zz9.99" NO-UNDO.
DEF        VAR cch_vldoipmf AS DECIMAL FORMAT "zzzzz,zzz,zzz,zz9.99" NO-UNDO.
DEF        VAR cch_qtipmmfx AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.9999" NO-UNDO.

DEF        VAR isn_qtlancto AS INT     FORMAT "zzz,zz9"              NO-UNDO.
DEF        VAR isn_vlbasipm AS DECIMAL FORMAT "zzzzz,zzz,zzz,zz9.99" NO-UNDO.
DEF        VAR isn_vldoipmf AS DECIMAL FORMAT "zzzzz,zzz,zzz,zz9.99" NO-UNDO.
DEF        VAR isn_qtipmmfx AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.9999" NO-UNDO.

DEF        VAR juz_qtlancto AS INT     FORMAT "zzz,zz9"              NO-UNDO.
DEF        VAR juz_vlbasipm AS DECIMAL FORMAT "zzzzz,zzz,zzz,zz9.99" NO-UNDO.
DEF        VAR juz_vldoipmf AS DECIMAL FORMAT "zzzzz,zzz,zzz,zz9.99" NO-UNDO.
DEF        VAR juz_qtipmmfx AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.9999" NO-UNDO.

DEF        VAR rel_dsperiod AS CHAR    FORMAT "x(30)"                NO-UNDO.
DEF        VAR rel_nmempres AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmresemp AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA","CAPITAL","EMPRESTIMOS",
                                     "DIGITACAO","GENERICO"]         NO-UNDO.

DEF        VAR aux_qtipmmfx AS DECIMAL FORMAT "zzz,zzz,zz9.9999"     NO-UNDO.

DEF        VAR aux_nrdocmto AS INT                                   NO-UNDO.
DEF        VAR aux_dtrecolh AS DATE FORMAT "99/99/9999"              NO-UNDO.
DEF        VAR aux_ddsemana AS INT                                   NO-UNDO.
DEF        VAR aux_nrdiauti AS INT                                   NO-UNDO.

DEF        VAR aux_lscontas AS CHAR                                  NO-UNDO.
DEF        VAR aux_lsctaadm AS CHAR                                  NO-UNDO.

FORM SKIP(2)
     rel_dsperiod     AT 13 LABEL "PERIODO DE APURACAO" SKIP(1)
     crapper.dtdebito AT 05 LABEL "DEBITO NA CONTA-CORRENTE EM"
                            FORMAT "99/99/9999"
     SKIP(1)
     aux_dtrecolh     AT 17 LABEL "RECOLHIMENTO EM" SKIP(2)
     "** C.P.M.F. DOS ASSOCIADOS/NAO ASSOCIADOS **" AT 14 
     "COD. DARF  5869" AT 60    SKIP(1)
     ass_qtlancto     AT 12 LABEL "TOTAL DE LANCAMENTOS EFETUADOS" SKIP(1)
     ass_vlbasipm     AT 18 LABEL "TOTAL DA BASE DE CALCULO" SKIP(1)
     ass_vldoipmf     AT 27 LABEL "TOTAL DO DEBITO" SKIP(1)
     ass_qtipmmfx     AT 19 LABEL "TOTAL DO DEBITO EM UFIR" SKIP(2)
     "** C.P.M.F. DA COOPERATIVA DE CREDITO **" AT 18
     "COD. DARF  5884" AT 60    SKIP(1)
     cch_qtlancto     AT 12 LABEL "TOTAL DE LANCAMENTOS EFETUADOS" SKIP(1)
     cch_vlbasipm     AT 18 LABEL "TOTAL DA BASE DE CALCULO" SKIP(1)
     cch_vldoipmf     AT 27 LABEL "TOTAL DO DEBITO" SKIP(1)
     cch_qtipmmfx     AT 19 LABEL "TOTAL DO DEBITO EM UFIR" SKIP(2)
     "** C.P.M.F. DEPOSITO JUDICIAL **" AT 24
     "COD. DARF DEP.JUD." AT 60    SKIP(1)
     juz_qtlancto     AT 12 LABEL "TOTAL DE LANCAMENTOS EFETUADOS" SKIP(1)
     juz_vlbasipm     AT 18 LABEL "TOTAL DA BASE DE CALCULO" SKIP(1)
     juz_vldoipmf     AT 27 LABEL "TOTAL DO DEBITO" SKIP(1)
     juz_qtipmmfx     AT 19 LABEL "TOTAL DO DEBITO EM UFIR" SKIP(2)
     "** TOTAL DA C.P.M.F. COBRADO **" AT 28 SKIP(1)
     tot_qtlancto     AT 12 LABEL "TOTAL DE LANCAMENTOS EFETUADOS" SKIP(1)
     tot_vlbasipm     AT 18 LABEL "TOTAL DA BASE DE CALCULO" SKIP(1)
     tot_vldoipmf     AT 27 LABEL "TOTAL DO DEBITO" SKIP(1)
     tot_qtipmmfx     AT 19 LABEL "TOTAL DO DEBITO EM UFIR" SKIP(2)
     "** VALORES DAS CONTAS ISENTAS **" AT 28 SKIP(1)
     isn_qtlancto     AT 14 LABEL "TOTAL DE LANCAMENTOS ISENTOS" SKIP(1)
     isn_vlbasipm     AT 18 LABEL "TOTAL DA BASE DE CALCULO" SKIP(1)
     isn_vldoipmf     AT 24 LABEL "TOTAL NAO DEBITADO" SKIP(1)
     isn_qtipmmfx     AT 16 LABEL "TOTAL NAO DEBITADO EM UFIR" SKIP(1)
     WITH NO-BOX SIDE-LABELS WIDTH 80 FRAME f_resumo.

glb_cdprogra = "crps063".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

{ includes/cpmf.i } 

glb_cdempres = 11.

{ includes/cabrel080_1.i }

FIND crapmfx WHERE crapmfx.cdcooper = glb_cdcooper   AND
                   crapmfx.dtmvtolt = glb_dtmvtolt   AND
                   crapmfx.tpmoefix = 2 NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapmfx   THEN
     DO:
         glb_cdcritic = 140.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                           glb_cdprogra + "' --> '" + glb_dscritic + " - UFIR" +
                           " >> log/proc_batch.log").
         RETURN.
     END.

FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                   craptab.nmsistem = "CRED"       AND
                   craptab.tptabela = "USUARI"     AND
                   craptab.cdempres = 11           AND
                   craptab.cdacesso = "DEPJUDCPMF" AND 
                   craptab.tpregist = 001 NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab THEN
     aux_lscontas = "".
ELSE
     aux_lscontas = craptab.dstextab.
     
FOR EACH crapass WHERE crapass.cdcooper = glb_cdcooper AND
                       crapass.inpessoa = 3            AND
                       crapass.iniscpmf = 0        NO-LOCK:
    
    ASSIGN aux_lsctaadm = aux_lsctaadm + "," +           
                          TRIM(STRING(crapass.nrdconta, "zzzzzzz9")).
END.                       
     
IF   glb_inrestar = 0   THEN
     DO:
         OUTPUT STREAM str_1 TO rl/crrl052.lst PAGED PAGE-SIZE 84.

         ASSIGN tot_qtlancto = 0
                tot_vlbasipm = 0
                tot_vldoipmf = 0
                tot_qtipmmfx = 0
                cch_qtlancto = 0
                cch_vlbasipm = 0
                cch_vldoipmf = 0
                cch_qtipmmfx = 0
                isn_qtlancto = 0
                isn_vlbasipm = 0
                isn_vldoipmf = 0
                isn_qtipmmfx = 0
                juz_qtlancto = 0
                juz_vlbasipm = 0
                juz_vldoipmf = 0
                juz_qtipmmfx = 0.
      END.
ELSE
     DO:
         OUTPUT STREAM str_1 TO rl/crrl052.lst PAGED PAGE-SIZE 84 APPEND.

         ASSIGN tot_qtlancto = INTEGER(SUBSTRING(glb_dsrestar,001,06))
                tot_vlbasipm = DECIMAL(SUBSTRING(glb_dsrestar,008,17))
                tot_vldoipmf = DECIMAL(SUBSTRING(glb_dsrestar,026,17))
                tot_qtipmmfx = DECIMAL(SUBSTRING(glb_dsrestar,044,17))

                cch_qtlancto = INTEGER(SUBSTRING(glb_dsrestar,062,06))
                cch_vlbasipm = DECIMAL(SUBSTRING(glb_dsrestar,069,17))
                cch_vldoipmf = DECIMAL(SUBSTRING(glb_dsrestar,087,17))
                cch_qtipmmfx = DECIMAL(SUBSTRING(glb_dsrestar,105,17))
 
                isn_qtlancto = INTEGER(SUBSTRING(glb_dsrestar,123,06))
                isn_vlbasipm = DECIMAL(SUBSTRING(glb_dsrestar,130,17))
                isn_vldoipmf = DECIMAL(SUBSTRING(glb_dsrestar,148,17))
                isn_qtipmmfx = DECIMAL(SUBSTRING(glb_dsrestar,166,17))

                juz_qtlancto = INTEGER(SUBSTRING(glb_dsrestar,184,06))
                juz_vlbasipm = DECIMAL(SUBSTRING(glb_dsrestar,191,17))
                juz_vldoipmf = DECIMAL(SUBSTRING(glb_dsrestar,209,17))
                juz_qtipmmfx = DECIMAL(SUBSTRING(glb_dsrestar,227,17)).
     END.

VIEW STREAM str_1 FRAME f_cabrel080_1.

/*  Leitura dos periodos de apuracao  */

FOR EACH crapper WHERE crapper.cdcooper  = glb_cdcooper   AND
                       crapper.dtdebito <= glb_dtmvtolt   AND
                       crapper.indebito  = 1:    

    ASSIGN rel_dsperiod = STRING(crapper.dtiniper,"99/99/9999") + " A " +
                          STRING(crapper.dtfimper,"99/99/9999")

           aux_nrdocmto = INTEGER(SUBSTRING(STRING(crapper.dtdebito,
                                                   "999999"),1,4) + "100").

    /* Calcula data de recolhimento */

    aux_dtrecolh = crapper.dtfimper.
    
    aux_nrdiauti = 0.

    /* Soma 1 dia no inicio pois sempre saira da rotina anterior num domingo */

    DO WHILE TRUE:

       aux_dtrecolh = aux_dtrecolh + 1.

       IF   WEEKDAY(aux_dtrecolh) = 1 OR
            WEEKDAY(aux_dtrecolh) = 7 OR
            CAN-FIND(crapfer WHERE 
                     crapfer.cdcooper = glb_cdcooper AND
                     crapfer.dtferiad = aux_dtrecolh) THEN
            NEXT.

       aux_nrdiauti = aux_nrdiauti + 1.

       IF   aux_nrdiauti = 5 THEN
            LEAVE.

    END.

    TRANS_1:

    FOR EACH crapipm WHERE crapipm.cdcooper = glb_cdcooper   AND
                           crapipm.nrdconta > glb_nrctares   AND
                           crapipm.dtdebito = crapper.dtdebito
                           TRANSACTION ON ERROR UNDO TRANS_1, RETURN:

        DO WHILE TRUE:

           FIND crapsld EXCLUSIVE-LOCK WHERE
                crapsld.cdcooper = glb_cdcooper AND
                crapsld.nrdconta = crapipm.nrdconta NO-ERROR NO-WAIT.
        
           IF   NOT AVAILABLE crapsld   THEN
                IF   LOCKED crapsld   THEN
                     DO:
                         PAUSE 1 NO-MESSAGE.
                         NEXT.
                     END.
                ELSE
                     DO:
                         glb_cdcritic = 10.
                         RUN fontes/critic.p.
                         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                           " - " + glb_cdprogra + "' --> '" +
                                           glb_dscritic + " CONTA = " +
                                           STRING(crapipm.nrdconta) +
                                           " >> log/proc_batch.log").
                         RETURN.
                     END.

           LEAVE.

        END.  /*  Fim do DO WHILE TRUE  */

        FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                           crapass.nrdconta = crapsld.nrdconta
                           NO-LOCK NO-ERROR.

        IF   NOT AVAILABLE crapass THEN
             DO:
                 glb_cdcritic = 9.
                 RUN fontes/critic.p.
                 UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                               " - " + glb_cdprogra + "' --> '" +
                               glb_dscritic + " Conta --> " +
                               STRING(crapsld.nrdconta,"zzzz,zz9,9") +
                               " >> log/proc_batch.log").
                 UNDO TRANS_1, RETURN.
             END.

        DO WHILE TRUE:

           FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                              craplot.dtmvtolt = glb_dtmvtolt   AND
                              craplot.cdagenci = 1              AND
                              craplot.cdbccxlt = 100            AND
                              craplot.nrdolote = 8460
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

                         ASSIGN craplot.dtmvtolt = glb_dtmvtolt
                                craplot.cdagenci = 1
                                craplot.cdbccxlt = 100
                                craplot.nrdolote = 8460
                                craplot.tplotmov = 1
                                craplot.cdcooper = glb_cdcooper.

                         VALIDATE craplot.
                     END.

           LEAVE.

        END.  /*  Fim do DO WHILE TRUE  */

        IF   crapipm.vldoipmf > 0 THEN
             DO:
                 IF   crapass.iniscpmf = 0 THEN
                      DO:
                          CREATE craplcm.
                          ASSIGN craplcm.dtmvtolt = craplot.dtmvtolt
                                 craplcm.cdagenci = craplot.cdagenci
                                 craplcm.cdbccxlt = craplot.cdbccxlt
                                 craplcm.nrdolote = craplot.nrdolote
                                 craplcm.nrdconta = crapipm.nrdconta
                                 craplcm.nrdctabb = crapipm.nrdconta
                                 craplcm.nrdctitg = STRING(crapipm.nrdconta,
                                                           "99999999")
                                 craplcm.nrdocmto = aux_nrdocmto
                                 craplcm.cdhistor = 100
                                 craplcm.nrseqdig = craplot.nrseqdig + 1
                                 craplcm.vllanmto = crapipm.vldoipmf
                                 craplcm.cdpesqbb = SUBSTRING(STRING(
                                                    crapper.dtiniper), 01, 05) 
                                                    + "-" + 
                                                    SUBSTRING(STRING(
                                                    crapper.dtfimper), 01, 05)
                                 craplcm.cdcooper = glb_cdcooper
                                 craplot.vlinfodb = craplot.vlinfodb + 
                                                    crapipm.vldoipmf
                                 craplot.vlcompdb = craplot.vlcompdb + 
                                                    crapipm.vldoipmf
                                 craplot.qtinfoln = craplot.qtinfoln + 1
                                 craplot.qtcompln = craplot.qtcompln + 1
                                 craplot.nrseqdig = craplot.nrseqdig + 1.
                          VALIDATE craplcm.

                          IF   crapass.inpessoa <> 1 THEN
                               DO:
                                   CREATE crapavs.
                      
                                   ASSIGN crapavs.cdagenci = crapass.cdagenci
                                          crapavs.cdempres = 0
                                          crapavs.cdhistor = craplcm.cdhistor
                                          crapavs.cdsecext = crapass.cdsecext
                                          crapavs.dtdebito = glb_dtmvtolt
                                          crapavs.dtmvtolt = glb_dtmvtolt
                                          crapavs.dtrefere = glb_dtmvtolt
                                          crapavs.insitavs = 0
                                          crapavs.nrdconta = craplcm.nrdconta
                                          crapavs.nrdocmto = craplcm.nrdocmto
                                          crapavs.nrseqdig = craplcm.nrseqdig
                                          crapavs.tpdaviso = 2
                                          crapavs.vldebito = 0
                                          crapavs.vlestdif = 0
                                          crapavs.vllanmto = craplcm.vllanmto
                                          crapavs.flgproce = false
                                          crapavs.cdcooper = glb_cdcooper.
                                   VALIDATE crapavs.
                               END.
                      END.
             END.

        ASSIGN aux_qtipmmfx     = TRUNC(crapipm.vldoipmf / crapmfx.vlmoefix,4)

               crapsld.vlipmfpg = crapsld.vlipmfpg - crapipm.vldoipmf
               crapsld.qtipamfx = crapsld.qtipamfx + aux_qtipmmfx
               crapipm.indebito = IF crapass.iniscpmf = 0 
                                     THEN 2
                                     ELSE 3.

        IF   crapass.iniscpmf = 0 THEN
             ASSIGN tot_qtlancto     = tot_qtlancto + 1
                    tot_vlbasipm     = tot_vlbasipm + crapipm.vlbasipm
                    tot_vldoipmf     = tot_vldoipmf + crapipm.vldoipmf
                    tot_qtipmmfx     = tot_qtipmmfx + aux_qtipmmfx.

        IF   CAN-DO(aux_lscontas,STRING(crapipm.nrdconta)) THEN
             ASSIGN juz_qtlancto     = juz_qtlancto + 1
                    juz_vlbasipm     = juz_vlbasipm + crapipm.vlbasipm
                    juz_vldoipmf     = juz_vldoipmf + crapipm.vldoipmf
                    juz_qtipmmfx     = juz_qtipmmfx + aux_qtipmmfx.
 
        IF   CAN-DO(aux_lsctaadm, STRING(crapipm.nrdconta)) THEN
             ASSIGN cch_qtlancto = cch_qtlancto + 1
                    cch_vlbasipm = cch_vlbasipm + crapipm.vlbasipm
                    cch_vldoipmf = cch_vldoipmf + crapipm.vldoipmf
                    cch_qtipmmfx = cch_qtipmmfx + aux_qtipmmfx.

        IF   crapass.iniscpmf <> 0 THEN
             ASSIGN isn_qtlancto = isn_qtlancto + 1
                    isn_vlbasipm = isn_vlbasipm + crapipm.vlbasipm
                    isn_vldoipmf = isn_vldoipmf + crapipm.vldoipmf
                    isn_qtipmmfx = isn_qtipmmfx + aux_qtipmmfx.

        DO WHILE TRUE:

           FIND crapres WHERE crapres.cdcooper = glb_cdcooper AND
                              crapres.cdprogra = glb_cdprogra
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

           IF   NOT AVAILABLE crapres   THEN
                IF   LOCKED crapres   THEN
                     DO:
                         PAUSE 1 NO-MESSAGE.
                         NEXT.
                     END.
                ELSE
                     DO:
                         glb_cdcritic = 151.
                         RUN fontes/critic.p.
                         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                           " - " + glb_cdprogra + "' --> '" +
                                           glb_dscritic +
                                           " >> log/proc_batch.log").
                         UNDO TRANS_1, RETURN.      
                     END.

           LEAVE.

        END.  /*  Fim do DO WHILE TRUE  */
  
        ASSIGN crapres.nrdconta = crapipm.nrdconta

               crapres.dsrestar = STRING(tot_qtlancto,"999999") + " " +
                                  STRING(tot_vlbasipm,"99999999999999.99") +
                                  " " +
                                  STRING(tot_vldoipmf,"99999999999999.99") +
                                  " " +
                                  STRING(tot_qtipmmfx,"999999999999.9999") +
                                  " " +
                                  STRING(cch_qtlancto,"999999") + " " +
                                  STRING(cch_vlbasipm,"99999999999999.99") +
                                  " " +
                                  STRING(cch_vldoipmf,"99999999999999.99") +
                                  " " +
                                  STRING(cch_qtipmmfx,"999999999999.9999") + 
                                  " " +
                                  STRING(isn_qtlancto,"999999") + " " +
                                  STRING(isn_vlbasipm,"99999999999999.99") +
                                  " " +
                                  STRING(isn_vldoipmf,"99999999999999.99") +
                                  " " +
                                  STRING(isn_qtipmmfx,"999999999999.9999") +
                                  " " +
                                  STRING(juz_qtlancto,"999999") + " " +
                                  STRING(juz_vlbasipm,"99999999999999.99") +
                                  " " +
                                  STRING(juz_vldoipmf,"99999999999999.99") +
                                  " " +
                                  STRING(juz_qtipmmfx,"999999999999.9999").
    
    END.  /*  Fim do FOR EACH e da transacao -- TRANS_1  --  crapipm  */

    ASSIGN ass_qtlancto = tot_qtlancto - cch_qtlancto - juz_qtlancto
           ass_vlbasipm = tot_vlbasipm - cch_vlbasipm - juz_vlbasipm
           ass_vldoipmf = tot_vldoipmf - cch_vldoipmf - juz_vldoipmf
           ass_qtipmmfx = tot_qtipmmfx - cch_qtipmmfx - juz_qtipmmfx.

    /* Lancamentos do INSS - BANCOOB */
    FOR EACH craplpi WHERE craplpi.cdcooper  = glb_cdcooper       AND
                           craplpi.dtmvtolt >= crapper.dtiniper   AND
                           craplpi.dtmvtolt <= crapper.dtfimper   NO-LOCK:
                          
        ASSIGN ass_qtlancto = ass_qtlancto + 1
               ass_vlbasipm = ass_vlbasipm + craplpi.vllanmto
               ass_vldoipmf = ass_vldoipmf + craplpi.vldoipmf
               ass_qtipmmfx = ass_qtipmmfx +
                                  TRUNC(craplpi.vldoipmf / crapmfx.vlmoefix,4).
    END.
    
    DISPLAY STREAM str_1
            rel_dsperiod  crapper.dtdebito  aux_dtrecolh
            ass_qtlancto  ass_vlbasipm      ass_vldoipmf  ass_qtipmmfx
            cch_qtlancto  cch_vlbasipm      cch_vldoipmf  cch_qtipmmfx
            tot_qtlancto  tot_vlbasipm      tot_vldoipmf  tot_qtipmmfx
            isn_qtlancto  isn_vlbasipm      isn_vldoipmf  isn_qtipmmfx
            juz_qtlancto  juz_vlbasipm      juz_vldoipmf  juz_qtipmmfx
            WITH FRAME f_resumo.

    PAGE STREAM str_1.

    TRANS_2:

    DO TRANSACTION ON ERROR UNDO TRANS_2, RETURN:
  
       ASSIGN crapper.indebito = 2
              crapper.dtrecolh = aux_dtrecolh
              crapper.dtdebito = glb_dtmvtolt
                     
              glb_nrctares     = 0
              glb_dsrestar     = ""                    

              tot_qtlancto     = 0
              tot_vlbasipm     = 0
              tot_vldoipmf     = 0
              tot_qtipmmfx     = 0

              cch_qtlancto     = 0
              cch_vlbasipm     = 0
              cch_vldoipmf     = 0
              cch_qtipmmfx     = 0
              
              isn_qtlancto     = 0
              isn_vlbasipm     = 0
              isn_vldoipmf     = 0
              isn_qtipmmfx     = 0
              
              juz_qtlancto     = 0
              juz_vlbasipm     = 0
              juz_vldoipmf     = 0
              juz_qtipmmfx     = 0.
   
    END.  /*  Fim da transacao  --  TRANS_2  */
      
END.  /*  Fim do FOR EACH  --  Leitura dos periodos de apuracao  */

OUTPUT STREAM str_1 CLOSE.

ASSIGN glb_nmarqimp = "rl/crrl052.lst"
       glb_nrcopias = 1
       glb_nmformul = "80col".

RUN fontes/imprim.p.

glb_infimsol = TRUE.

RUN fontes/fimprg.p.

/* .......................................................................... */
