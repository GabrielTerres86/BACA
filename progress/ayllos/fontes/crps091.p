/* ..........................................................................

   Programa: Fontes/crps091.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Marco/94.                           Ultima atualizacao: 30/05/2014

   Dados referentes ao programa:

   Frequencia: Diario (ON-LINE).
   Objetivo  : Atende a solicitacao 048.
               Emite relatorio com as taxas do mes (77).

   Alteracoes: 14/10/94 - Alterado para inclusao de novos parametros para as
                          linhas de credito: taxa minima e maxima e o indica-
                          dor de linha com saldo devedor (Edson).

               10/11/94 - Incluida linha com a taxa de juros sobre saque de
                          deposito bloqueado (Edson).

               15/08/95 - Alterado para enviar para a impressora mais perto do
                          usuario (Edson).

               17/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               05/10/1999 - Aumentado o numero de casas decimais nas taxas
                            (Edson).

               26/10/1999 - Buscar os dados da cooperativa no crapcop (Deborah)
               
               31/03/2003 - Para a Concredi listar todas as linhas (Deborah).

               01/11/2004 - Listar taxas tabela crapldc(Cadastro Linhas
                            de Desconto)(Mirtes)

               18/05/2005 - Alterado o formulario de TIMBRE para 80col (Edson).
               
               20/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               12/04/2007 - Substituir craptab "JUROSESPEC" pela craplrt. (Ze).
               
               16/09/2008 - Alterada chave de acesso a tabela crapldc
                            (Gabriel).
                            
               16/06/2009 - Incluidas taxas do desconto de titulos (Evandro).
               
               23/03/2012 - Alterado o nome do relatorio para crrl077 (Adriano).
               
               03/08/2012 - Ajuste do format no campo nmrescop (David Kruger).
               
               25/04/2014 - Aumentado o format do campo cdlcremp de 3 para 4
                            posicoes (Tiago/Gielow SD137074).
                            
               30/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
............................................................................. */

DEF STREAM str_1.     /*  Para listagem das taxas do mes  */

{ includes/var_batch.i }

DEF        VAR rel_nmresemp     AS CHAR    FORMAT "x(15)"            NO-UNDO.
DEF        VAR rel_nmrelato     AS CHAR    FORMAT "x(40)" EXTENT 5   NO-UNDO.

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

DEF        VAR rel_dslcremp AS CHAR    FORMAT "x(29)"                NO-UNDO.
DEF        VAR rel_dssitlcr AS CHAR    FORMAT "x(01)"                NO-UNDO.
DEF        VAR rel_dsmesref AS CHAR    FORMAT "x(15)"                NO-UNDO.

DEF        VAR rel_nrgrplcr AS INT     FORMAT "z9"                   NO-UNDO.

DEF        VAR rel_txbaspre AS DECIMAL FORMAT "zz9.999999"           NO-UNDO.
DEF        VAR rel_txjurfix AS DECIMAL FORMAT "zz9.99"               NO-UNDO.
DEF        VAR rel_txjurvar AS DECIMAL FORMAT "zz9.99"               NO-UNDO.
DEF        VAR rel_txmensal AS DECIMAL FORMAT "zz9.999999"           NO-UNDO.
DEF        VAR rel_txjurcal AS DECIMAL FORMAT "zz9.999999"           NO-UNDO.
DEF        VAR rel_txdiaria AS DECIMAL FORMAT "9.99999"              NO-UNDO.
DEF        VAR rel_txjurdia AS DECIMAL FORMAT "9.9999999"            NO-UNDO.

DEF        VAR rel_txrefmes AS DECIMAL FORMAT "zz9.999999"           NO-UNDO.
DEF        VAR rel_txufrmes AS DECIMAL FORMAT "zz9.999999"           NO-UNDO.
DEF        VAR rel_dtiniper AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR rel_dtfimper AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR rel_dsobserv AS CHAR    FORMAT "x(40)" EXTENT 4       NO-UNDO.

DEF        VAR rel_flgtxmes AS LOGICAL FORMAT "T.R./UFIR"            NO-UNDO.

DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmmesref AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmendter AS CHAR                                  NO-UNDO.
DEF        VAR aux_dscomand AS CHAR                                  NO-UNDO.

DEF        VAR aux_primvez  AS LOG                                   NO-UNDO.

ASSIGN glb_cdprogra = "crps091"
       glb_flgbatch = FALSE.

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

FORM "TAXA UTILIZADA NO MES DE" AT  1
     rel_dsmesref               AT 26
     rel_txjurcal               AT 42
     "% -"                      
     rel_flgtxmes               
     SKIP(1)
     WITH COLUMN 7 NO-BOX NO-ATTR-SPACE NO-LABEL WIDTH 80 FRAME f_refere.

FORM "LINHA DE CREDITO"                                       AT  1
     "GR S VARIAVEL    FIXA      MENSAL               DIARIA" AT 31
     SKIP(1)
     WITH COLUMN 8 NO-BOX NO-ATTR-SPACE WIDTH 90 FRAME f_label.

FORM rel_dslcremp AT  1
     rel_nrgrplcr AT 31
     rel_dssitlcr AT 34
     rel_txjurvar AT 37
     "%"          AT 43
     rel_txjurfix AT 45
     "%"          AT 51
     rel_txmensal AT 53
     "%"          AT 63
     rel_txdiaria AT 65
     "%"          AT 72
     "("          AT 74
     rel_txjurdia AT 75
     ")"          AT 84
     WITH COLUMN 8 NO-BOX NO-ATTR-SPACE NO-LABEL DOWN WIDTH 90 FRAME f_taxas.

FORM rel_dslcremp AT  1
     WITH COLUMN 8 NO-BOX NO-ATTR-SPACE NO-LABEL DOWN WIDTH 90 FRAME f_descr.

FORM rel_dslcremp AT  1
     rel_txjurvar AT 37
     "%"          AT 43
     rel_txjurfix AT 45
     "%"          AT 51
     rel_txmensal AT 53
     "%"          AT 63
     WITH COLUMN 8 NO-BOX NO-ATTR-SPACE NO-LABEL DOWN WIDTH 80 FRAME f_juros.

FORM rel_dslcremp AT  1
     rel_txmensal AT 53
     "%"          AT 63
     WITH COLUMN 8 NO-BOX NO-ATTR-SPACE NO-LABEL DOWN WIDTH 80 FRAME f_limite.

FORM SKIP(4) WITH NO-BOX WIDTH 80 FRAME f_salto.

FORM SKIP(1) WITH NO-BOX WIDTH 80 FRAME f_salto_1.

FORM SKIP(2)
     "BASE DE CALCULO:" AT  1
     SKIP(1)
     rel_flgtxmes       AT  1 LABEL "INDEXADOR UTILIZADO NO MES"
     SKIP(1)
     rel_txufrmes       AT  1 LABEL "UFIR" "%"
     rel_txrefmes       AT 20 LABEL "TAXA REFERENCIAL(T.R.)" "%"
     rel_dtiniper       AT 57 LABEL "PERIODO" "A"
     rel_dtfimper       AT 79 NO-LABEL
     SKIP(1)
     "OBSERVACAO:"      AT 17
     rel_dsobserv[1]    AT 29 NO-LABEL SKIP
     rel_dsobserv[2]    AT 29 NO-LABEL SKIP
     rel_dsobserv[3]    AT 29 NO-LABEL SKIP
     rel_dsobserv[4]    AT 29 NO-LABEL
     SKIP(2)
     crapcop.nmrescop AT 1 FORMAT "x(20)" NO-LABEL
     SKIP(4)
     "---------------------------------" AT  1
     WITH COLUMN 8 NO-BOX NO-ATTR-SPACE SIDE-LABELS WIDTH 90 FRAME f_indices.

{ includes/cabrel080_1.i }

/* Busca dados da cooperativa */

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> log/proc_batch.log").
         RETURN.
     END.

ASSIGN aux_nmarqimp = "rl/crrl077_" + STRING(TIME,"99999") + ".lst"

       aux_nmmesref = "  JANEIRO/,FEVEREIRO/,    MARCO/,    ABRIL/," +
                      "     MAIO/,    JUNHO/,    JULHO/,   AGOSTO/," +
                      " SETEMBRO/,  OUTUBRO/, NOVEMBRO/, DEZEMBRO/"

       rel_dsmesref = ENTRY(MONTH(glb_dtmvtolt),aux_nmmesref) +
                      STRING(YEAR(glb_dtmvtolt),"9999") + ":".

FIND craptab WHERE craptab.cdcooper = glb_cdcooper     AND
                   craptab.nmsistem = "CRED"           AND
                   craptab.tptabela = "GENERI"         AND
                   craptab.cdempres = 0                AND
                   craptab.cdacesso = "TAXASDOMES"     AND
                   craptab.tpregist = 1                NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     DO:
         glb_infimsol = TRUE.
         RUN fontes/fimprg.p.
         RETURN.
     END.

ASSIGN rel_flgtxmes = IF SUBSTRING(craptab.dstextab,1,1) = "T"
                         THEN TRUE
                         ELSE FALSE

       rel_txrefmes = DECIMAL(SUBSTRING(craptab.dstextab,03,10))
       rel_txufrmes = DECIMAL(SUBSTRING(craptab.dstextab,14,10))

       rel_dtiniper = DATE(INTEGER(SUBSTR(craptab.dstextab,27,02)),
                           INTEGER(SUBSTR(craptab.dstextab,25,02)),
                           INTEGER(SUBSTR(craptab.dstextab,29,04)))

       rel_dtfimper = DATE(INTEGER(SUBSTR(craptab.dstextab,36,02)),
                           INTEGER(SUBSTR(craptab.dstextab,34,02)),
                           INTEGER(SUBSTR(craptab.dstextab,38,04)))

       rel_txjurcal = IF rel_flgtxmes THEN rel_txrefmes ELSE rel_txufrmes

       rel_dsobserv[1] = SUBSTRING(craptab.dstextab,043,40)
       rel_dsobserv[2] = SUBSTRING(craptab.dstextab,083,40)
       rel_dsobserv[3] = SUBSTRING(craptab.dstextab,123,40)
       rel_dsobserv[4] = SUBSTRING(craptab.dstextab,163,40).

OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

VIEW STREAM str_1 FRAME f_cabrel080_1.

DISPLAY STREAM str_1
        rel_dsmesref  rel_txjurcal  rel_flgtxmes
        WITH FRAME f_refere.

PUT STREAM str_1 CONTROL "\0330\033x0\022\033\115" NULL.

VIEW STREAM str_1 FRAME f_label.

FOR EACH craplcr WHERE  craplcr.cdcooper = glb_cdcooper               AND
                       (craplcr.flgsaldo OR (craplcr.flgsaldo = FALSE AND 
                                             glb_cdcooper = 4)) NO-LOCK:

    ASSIGN rel_dslcremp = STRING(craplcr.cdlcremp,"9999") + "-" +
                          craplcr.dslcremp

           rel_dssitlcr = IF NOT craplcr.flgstlcr THEN "B" ELSE ""

           rel_nrgrplcr = craplcr.nrgrplcr
           rel_txmensal = craplcr.txmensal
           rel_txdiaria = craplcr.txdiaria * 100
           rel_txjurdia = craplcr.txdiaria
           rel_txjurfix = craplcr.txjurfix
           rel_txjurvar = craplcr.txjurvar.

    DISPLAY STREAM str_1
            rel_dslcremp  rel_nrgrplcr  rel_dssitlcr  rel_txjurvar
            rel_txjurfix  rel_txmensal  rel_txdiaria  rel_txjurdia
            WITH FRAME f_taxas.

    DOWN STREAM str_1 WITH FRAME f_taxas.

    IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
         DO:
             PAGE STREAM str_1.

             DISPLAY STREAM str_1
                     rel_dsmesref  rel_txjurcal WITH FRAME f_refere.

             VIEW STREAM str_1 FRAME f_label.
         END.

END.  /*  Fim do FOR EACH  --  Leitura das linhas de credito  */

VIEW STREAM str_1 FRAME f_salto_1.

IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
     DO:
         PAGE STREAM str_1.

         DISPLAY STREAM str_1
                 rel_dsmesref  rel_txjurcal WITH FRAME f_refere.

         VIEW STREAM str_1 FRAME f_label.
     END.


/* Taxas Desconto de Cheques */
ASSIGN aux_primvez = YES.

FOR EACH crapldc WHERE crapldc.cdcooper = glb_cdcooper   AND
                       crapldc.tpdescto = 2              NO-LOCK:

    IF  aux_primvez = YES THEN
        DO:
           DISPLAY STREAM str_1
                   "DESCONTO DE CHEQUES " @ rel_dslcremp
                   WITH FRAME f_descr.
           DOWN STREAM str_1 WITH FRAME f_descr.

           DISPLAY STREAM str_1
                   " " @ rel_dslcremp
                   WITH FRAME f_descr.
           DOWN STREAM str_1 WITH FRAME f_descr.

           ASSIGN aux_primvez = NO.
           
        END.

    ASSIGN rel_dslcremp = STRING(crapldc.cddlinha,"999") + "-" +
                          crapldc.dsdlinha

           rel_dssitlcr = IF NOT crapldc.flgstlcr THEN "B" ELSE ""

           rel_nrgrplcr = 0                    
           rel_txmensal = crapldc.txmensal
           rel_txdiaria = crapldc.txdiaria     
           rel_txjurdia = crapldc.txdiaria / 100
           rel_txjurfix = 0                  
           rel_txjurvar = 0.                   

    DISPLAY STREAM str_1
            rel_dslcremp  rel_nrgrplcr  rel_dssitlcr  rel_txjurvar
            rel_txjurfix  rel_txmensal  rel_txdiaria  rel_txjurdia
            WITH FRAME f_taxas.

    DOWN STREAM str_1 WITH FRAME f_taxas.

    IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
         DO:
             PAGE STREAM str_1.

             DISPLAY STREAM str_1
                     rel_dsmesref  rel_txjurcal WITH FRAME f_refere.

             VIEW STREAM str_1 FRAME f_label.
         END.

END.  /*  Fim do FOR EACH  --  Leitura das taxas desconto de cheques  */

VIEW STREAM str_1 FRAME f_salto_1.
                                   
IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
     DO:
         PAGE STREAM str_1.

         DISPLAY STREAM str_1
                 rel_dsmesref  rel_txjurcal WITH FRAME f_refere.

         VIEW STREAM str_1 FRAME f_label.
     END.


/* Taxas Desconto de Titulos */
ASSIGN aux_primvez = YES.

FOR EACH crapldc WHERE crapldc.cdcooper = glb_cdcooper   AND
                       crapldc.tpdescto = 3              NO-LOCK:

    IF  aux_primvez = YES THEN
        DO:
           DISPLAY STREAM str_1
                   "DESCONTO DE TITULOS " @ rel_dslcremp
                   WITH FRAME f_descr.
           DOWN STREAM str_1 WITH FRAME f_descr.

           DISPLAY STREAM str_1
                   " " @ rel_dslcremp
                   WITH FRAME f_descr.
           DOWN STREAM str_1 WITH FRAME f_descr.

           ASSIGN aux_primvez = NO.
        END.

    ASSIGN rel_dslcremp = STRING(crapldc.cddlinha,"999") + "-" +
                          crapldc.dsdlinha

           rel_dssitlcr = IF NOT crapldc.flgstlcr THEN "B" ELSE ""

           rel_nrgrplcr = 0                    
           rel_txmensal = crapldc.txmensal
           rel_txdiaria = crapldc.txdiaria     
           rel_txjurdia = crapldc.txdiaria / 100
           rel_txjurfix = 0                  
           rel_txjurvar = 0.                   

    DISPLAY STREAM str_1
            rel_dslcremp  rel_nrgrplcr  rel_dssitlcr  rel_txjurvar
            rel_txjurfix  rel_txmensal  rel_txdiaria  rel_txjurdia
            WITH FRAME f_taxas.

    DOWN STREAM str_1 WITH FRAME f_taxas.

    IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
         DO:
             PAGE STREAM str_1.

             DISPLAY STREAM str_1
                     rel_dsmesref  rel_txjurcal WITH FRAME f_refere.

             VIEW STREAM str_1 FRAME f_label.
         END.

END.  /*  Fim do FOR EACH  --  Leitura das taxas desconto de titulos  */

VIEW STREAM str_1 FRAME f_salto_1.
                                   
IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
     DO:
         PAGE STREAM str_1.

         DISPLAY STREAM str_1
                 rel_dsmesref  rel_txjurcal WITH FRAME f_refere.

         VIEW STREAM str_1 FRAME f_label.
     END.


/*  Taxa de juros sobre o uso do limite de cheque especial  */

FOR EACH craplrt WHERE craplrt.cdcooper = glb_cdcooper NO-LOCK:

    ASSIGN rel_dslcremp = STRING(craplrt.cddlinha,"999") + "-" +
                          STRING(craplrt.dsdlinha,"x(25)")
           rel_txmensal = craplrt.txmensal
           rel_txjurfix = craplrt.txjurfix
           rel_txjurvar = craplrt.txjurvar.

    DISPLAY STREAM str_1
            rel_dslcremp  rel_txjurvar rel_txjurfix  rel_txmensal
            WITH FRAME f_juros.

    DOWN STREAM str_1 WITH FRAME f_juros.

    IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
         DO:
             PAGE STREAM str_1.

             DISPLAY STREAM str_1
                     rel_dsmesref  rel_txjurcal WITH FRAME f_refere.

             VIEW STREAM str_1 FRAME f_label.
         END.
END.

/*  Taxa de juros sobre saque deposito bloqueado  */

FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                   craptab.nmsistem = "CRED"         AND
                   craptab.tptabela = "USUARI"       AND
                   craptab.cdempres = 11             AND
                   craptab.cdacesso = "JUROSSAQUE"   AND
                   craptab.tpregist = 1
                   NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     ASSIGN rel_dslcremp = "SAQUE DEP. BLOQUEADO - N/C"
            rel_txmensal = 0
            rel_txjurfix = 0
            rel_txjurvar = 0.
ELSE
     ASSIGN rel_dslcremp = "SAQUE DEP. BLOQUEADO"
            rel_txmensal = DECIMAL(SUBSTRING(craptab.dstextab,01,10))
            rel_txjurfix = DECIMAL(SUBSTRING(craptab.dstextab,12,06))
            rel_txjurvar = DECIMAL(SUBSTRING(craptab.dstextab,19,06)).

DISPLAY STREAM str_1
        rel_dslcremp  rel_txjurvar rel_txjurfix  rel_txmensal
        WITH FRAME f_juros.

DOWN STREAM str_1 WITH FRAME f_juros.

IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
     DO:
         PAGE STREAM str_1.

         DISPLAY STREAM str_1
                 rel_dsmesref  rel_txjurcal WITH FRAME f_refere.

         VIEW STREAM str_1 FRAME f_label.
     END.

/*  Taxa de juros de multa em conta-corrente  */

FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                   craptab.nmsistem = "CRED"         AND
                   craptab.tptabela = "USUARI"       AND
                   craptab.cdempres = 11             AND
                   craptab.cdacesso = "JUROSNEGAT"   AND
                   craptab.tpregist = 1
                   NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     ASSIGN rel_dslcremp = "TAXA C/C NEGATIVA - N/C"
            rel_txmensal = 0
            rel_txjurfix = 0
            rel_txjurvar = 0.
ELSE
     ASSIGN rel_dslcremp = "TAXA C/C NEGATIVA"
            rel_txmensal = DECIMAL(SUBSTRING(craptab.dstextab,01,10))
            rel_txjurfix = DECIMAL(SUBSTRING(craptab.dstextab,12,06))
            rel_txjurvar = DECIMAL(SUBSTRING(craptab.dstextab,19,06)).

DISPLAY STREAM str_1
        rel_dslcremp  rel_txjurvar rel_txjurfix  rel_txmensal
        WITH FRAME f_juros.

DOWN STREAM str_1 WITH FRAME f_juros.

IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
     DO:
         PAGE STREAM str_1.

         DISPLAY STREAM str_1
                 rel_dsmesref  rel_txjurcal WITH FRAME f_refere.

         VIEW STREAM str_1 FRAME f_label.
     END.

VIEW STREAM str_1 FRAME f_salto_1.

IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
     DO:
         PAGE STREAM str_1.

         DISPLAY STREAM str_1
                 rel_dsmesref  rel_txjurcal WITH FRAME f_refere.

         VIEW STREAM str_1 FRAME f_label.
     END.

/*  Taxa de reajuste dos limites de credito  */

FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                   craptab.nmsistem = "CRED"         AND
                   craptab.tptabela = "USUARI"       AND
                   craptab.cdempres = 11             AND
                   craptab.cdacesso = "REAJLIMITE"   AND
                   craptab.tpregist = 1
                   NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     ASSIGN rel_dslcremp = "REAJUSTE LIMITES DE CREDITO"
            rel_txmensal = 0.
ELSE
     ASSIGN rel_dslcremp = "REAJUSTE LIMITES DE CREDITO"
            rel_txmensal = DECIMAL(SUBSTRING(craptab.dstextab,1,10)).

DISPLAY STREAM str_1 rel_dslcremp rel_txmensal WITH FRAME f_limite.

DOWN STREAM str_1 WITH FRAME f_limite.

IF   LINE-COUNTER(str_1) > 64   THEN
     DO:
         PAGE STREAM str_1.
         VIEW STREAM str_1 FRAME f_salto.
     END.

DISPLAY STREAM str_1
        rel_flgtxmes  rel_txufrmes  rel_txrefmes
        rel_dtiniper  rel_dtfimper  rel_dsobserv crapcop.nmrescop
        WITH FRAME f_indices.

PUT STREAM str_1 CONTROL "\0330\033x0\022\033\120" NULL.

OUTPUT STREAM str_1 CLOSE.

glb_infimsol = TRUE.

RUN fontes/fimprg.p.

IF   glb_cdcritic > 0   THEN
     RETURN.

IF   glb_inproces = 1   THEN
     DO:
         INPUT THROUGH basename `tty` NO-ECHO.

         SET aux_nmendter WITH FRAME f_terminal.

         INPUT CLOSE.
         
         aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                               aux_nmendter. 

         FIND crapter WHERE crapter.cdcooper = glb_cdcooper  AND
                            crapter.nmendter = aux_nmendter  NO-LOCK NO-ERROR.

         IF   AVAILABLE crapter   THEN
              DO:
                  IF   NOT CAN-DO("Limbo,Escrava",crapter.nmdafila)   THEN
                       DO:
                           aux_dscomand = "lp -d" + crapter.nmdafila + " -n " +
                                          STRING(glb_nrdevias) + " " +
                                          aux_nmarqimp + " > /dev/null".

                           UNIX SILENT VALUE(aux_dscomand).
                       END.
              END.
         ELSE
         IF   glb_flgmicro   THEN
              DO:
                  aux_dscomand = "lp -d" + glb_nmdafila + " -n " + 
                                 STRING(glb_nrdevias) + " " +
                                 aux_nmarqimp + " > /dev/null".

                  UNIX SILENT VALUE(aux_dscomand).
              END.
     END.

IF   aux_dscomand = ""   THEN
     DO:
         ASSIGN glb_nrcopias = glb_nrdevias
                glb_nmformul = "80col"
                glb_nmarqimp = aux_nmarqimp.

         RUN fontes/imprim.p.
     END.

/* .......................................................................... */

