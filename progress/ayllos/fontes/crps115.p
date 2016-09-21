/* ..........................................................................

   Programa: Fontes/crps115.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Marco/95.                         Ultima atualizacao: 15/01/2014

   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Atende a solicitacao 41.
               Atualizacao do historico de taxas.

   Alteracoes: 26/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               05/10/1999 - Aumentado o numero de casas decimais na taxa
                            (Edson).

               02/04/2001 - Usar 9999 para cdlcremp (Margarete/Planner).

               20/06/2001 - Atualizar JUROSPREJU (Margarete).

               07/07/2005 - Alimentado campo cdcooper da tabela craptax (Diego).

               15/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
               
               12/04/2007 - Substituir craptab "JUROSESPEC" pela craplrt. (Ze).
               
               15/01/2014 - Inclusao de VALIDATE craptax (Carlos)
............................................................................. */

{ includes/var_batch.i }

glb_cdprogra = "crps115".
RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

FOR EACH craptax WHERE craptax.cdcooper = glb_cdcooper AND
                       craptax.dtmvtolt = glb_dtmvtolt EXCLUSIVE-LOCK :
    DELETE craptax.
END.

/*  Leitura da tabela TAXASDOMES */

FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                   craptab.nmsistem = "CRED"       AND
                   craptab.tptabela = "GENERI"     AND
                   craptab.cdempres = 00           AND
                   craptab.cdacesso = "TAXASDOMES" AND
                   craptab.tpregist = 1 NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     DO:
         glb_cdcritic = 55.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                           glb_cdprogra + "' --> '" +
                           glb_dscritic + " >> log/proc_batch.log").
         RETURN.
     END.
ELSE
     DO  TRANSACTION:

         CREATE craptax.
         ASSIGN craptax.cdlcremp = 9999
                craptax.dslcremp = (IF   SUBSTRING(craptab.dstextab,1,1) = "T"
                                         THEN "T.R.   "
                                         ELSE "UFIR   ")                    +
                                              "PER."                        +
                                STRING(DATE(INT(SUBSTR(craptab.dstextab,27,2)),
                                            INT(SUBSTR(craptab.dstextab,25,2)),
                                            INT(SUBSTR(craptab.dstextab,29,4))),
                                            "99/99/9999")    + " A "  +
                                STRING(DATE(INT(SUBSTR(craptab.dstextab,36,2)),
                                            INT(SUBSTR(craptab.dstextab,34,2)),
                                            INT(SUBSTR(craptab.dstextab,38,4))),
                                            "99/99/9999")   +
                                            SUBSTRING(craptab.dstextab,43,228)

                craptax.dtmvtolt = glb_dtmvtolt
                craptax.grlcremp = 1
                craptax.insitlcr = 0
                craptax.tpdetaxa = 1
                craptax.txdiaria = DECIMAL(SUBSTRING(craptab.dstextab,03,10))
                craptax.txmensal = DECIMAL(SUBSTRING(craptab.dstextab,14,10))
                craptax.cdcooper = glb_cdcooper.
         VALIDATE craptax.

     END. /*Fim da Transacao */

/*  Leitura da Estrutura de Limites de Cheques e Limite Empresarial */

FOR EACH craplrt WHERE craplrt.cdcooper = glb_cdcooper NO-LOCK:

    DO  TRANSACTION:

        CREATE craptax.
        ASSIGN craptax.cdlcremp = craplrt.cddlinha
               craptax.dslcremp = craplrt.dsdlinha
               craptax.dtmvtolt = glb_dtmvtolt
               craptax.grlcremp = 1
               craptax.insitlcr = 0
               craptax.tpdetaxa = 2
               craptax.txdiaria = 0
               craptax.txmensal = craplrt.txmensal
               craptax.cdcooper = glb_cdcooper.
        VALIDATE craptax.

     END. /* FIM DA TRANSACAO */

END.

/*  Leitura da tabela JUROSSAQUE */

FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                   craptab.nmsistem = "CRED"       AND
                   craptab.tptabela = "USUARI"     AND
                   craptab.cdempres = 11           AND
                   craptab.cdacesso = "JUROSSAQUE" AND
                   craptab.tpregist = 1 NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     DO:
        glb_cdcritic = 418.
        RUN fontes/critic.p.
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - " + glb_cdprogra + "' --> '" +
                           glb_dscritic + " >> log/proc_batch.log").
     END.
ELSE
     DO  TRANSACTION:

         CREATE craptax.
         ASSIGN craptax.cdlcremp = 00
                craptax.dslcremp = "JUROS SAQUE S/BLOQUEADO"
                craptax.dtmvtolt = glb_dtmvtolt
                craptax.grlcremp = 1
                craptax.insitlcr = 0
                craptax.tpdetaxa = 3
                craptax.txdiaria = 0
                craptax.txmensal = DECIMAL(SUBSTRING(craptab.dstextab,1,10))
                craptax.cdcooper = glb_cdcooper.
         VALIDATE craptax.

     END. /* FIM DA TRANSACAO */

/*  Leitura da tabela JUROSNEGAT */

FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                   craptab.nmsistem = "CRED"       AND
                   craptab.tptabela = "USUARI"     AND
                   craptab.cdempres = 11           AND
                   craptab.cdacesso = "JUROSNEGAT" AND
                   craptab.tpregist = 1 NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     DO:
        glb_cdcritic = 187.
        RUN fontes/critic.p.
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - " + glb_cdprogra + "' --> '" +
                           glb_dscritic + " >> log/proc_batch.log").
     END.
ELSE
     DO  TRANSACTION:

         CREATE craptax.
         ASSIGN craptax.cdlcremp = 00
                craptax.dslcremp = "MULTA CONTA CORRENTE"
                craptax.dtmvtolt = glb_dtmvtolt
                craptax.grlcremp = 1
                craptax.insitlcr = 0
                craptax.tpdetaxa = 4
                craptax.txdiaria = 0
                craptax.txmensal = DECIMAL(SUBSTRING(craptab.dstextab,1,10))
                craptax.cdcooper = glb_cdcooper.
         VALIDATE craptax.

     END. /* FIM DA TRANSACAO */

/*  Leitura da tabela REAJLIMITE */

FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                   craptab.nmsistem = "CRED"       AND
                   craptab.tptabela = "USUARI"     AND
                   craptab.cdempres = 11           AND
                   craptab.cdacesso = "REAJLIMITE" AND
                   craptab.tpregist = 1 NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     DO:
        glb_cdcritic = 418.
        RUN fontes/critic.p.
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - " + glb_cdprogra + "' --> '" +
                           glb_dscritic + " >> log/proc_batch.log").
     END.
ELSE
     DO  TRANSACTION:

         CREATE craptax.
         ASSIGN craptax.cdlcremp = 00
                craptax.dslcremp = "REAJUSTE LIMITE DE CREDITO"
                craptax.dtmvtolt = glb_dtmvtolt
                craptax.grlcremp = 1
                craptax.insitlcr = 0
                craptax.tpdetaxa = 5
                craptax.txdiaria = 0
                craptax.txmensal = DECIMAL(SUBSTRING(craptab.dstextab,1,10))
                craptax.cdcooper = glb_cdcooper.
         VALIDATE craptax.

     END. /* FIM DA TRANSACAO */

/*  Leitura da tabela JUROSPREJU */

FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                   craptab.nmsistem = "CRED"       AND
                   craptab.tptabela = "USUARI"     AND
                   craptab.cdempres = 11           AND
                   craptab.cdacesso = "JUROSPREJU" AND
                   craptab.tpregist = 1 NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     DO:
        glb_cdcritic = 719.
        RUN fontes/critic.p.
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - " + glb_cdprogra + "' --> '" +
                           glb_dscritic + " >> log/proc_batch.log").
     END.
ELSE
     DO  TRANSACTION:

         CREATE craptax.
         ASSIGN craptax.cdlcremp = 00
                craptax.dslcremp = "JUROS PREJUIZO"
                craptax.dtmvtolt = glb_dtmvtolt
                craptax.grlcremp = 1
                craptax.insitlcr = 0
                craptax.tpdetaxa = 6
                craptax.txdiaria = 0
                craptax.txmensal = DECIMAL(SUBSTRING(craptab.dstextab,1,10))
                craptax.cdcooper = glb_cdcooper.
         VALIDATE craptax.

     END. /* FIM DA TRANSACAO */

/*  Leitura das linhas de credito  */

FOR EACH craplcr WHERE craplcr.cdcooper = glb_cdcooper NO-LOCK:

    DO  TRANSACTION:

        CREATE craptax.
        ASSIGN craptax.cdlcremp = craplcr.cdlcremp
               craptax.dslcremp = craplcr.dslcremp
               craptax.dtmvtolt = glb_dtmvtolt
               craptax.grlcremp = craplcr.nrgrplcr
               craptax.insitlcr = IF NOT craplcr.flgstlcr THEN 1 ELSE  0
               craptax.tpdetaxa = 1
               craptax.txdiaria = craplcr.txdiaria
               craptax.txmensal = craplcr.txmensal
               craptax.cdcooper = glb_cdcooper.
        VALIDATE craptax.

    END. /* FIM DA TRANSACAO */

END. /* Fim do FOR EACH */

glb_infimsol = TRUE.

RUN fontes/fimprg.p.

/* .......................................................................... */

