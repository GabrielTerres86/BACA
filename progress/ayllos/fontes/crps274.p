/* ..........................................................................

   Programa: Fontes/crps274.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah 
   Data    : Agosto/1999                         Ultima alteracao: 12/12/2013

   Dados referentes ao programa:

   Frequencia: Diario (Batch - Background).
   Objetivo  : Emite relatorio com totais a credito do mes 
               Atende solicitacao 002.
               Relatorio 222
               Ordem do programa na solicitacao : apos o programa 212
               Exclusividade 2.

   Alteracoes: 13/01/2000 - Colocar a data de referencia (Deborah).
    
               16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               09/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               12/12/2013 - Alterado label da variavel aux_nrcpfcgc do form
                            f_saldos de CPF/CGC para CPF/CNPJ. (Reinert)
............................................................................. */

DEF STREAM str_1.
DEF STREAM str_2.  /* Para  uso de arquivo temporario */

{ includes/var_batch.i "NEW" }

DEF        VAR rel_cdagenci AS INT   FORMAT "zz9"                      NO-UNDO.
DEF        VAR aux_nrdconta AS INT                                     NO-UNDO.
DEF        VAR aux_nrcpfcgc AS CHAR  FORMAT "x(20)"                    NO-UNDO.
DEF        VAR aux_vlcremes AS DECI  FORMAT "zzz,zzz,zzz,zz9.99"       NO-UNDO.
DEF        VAR aux_vltotcre AS DECI  FORMAT "zzz,zzz,zzz,zz9.99"       NO-UNDO.
DEF        VAR aux_acrescim AS DECI                                    NO-UNDO.
DEF        VAR aux_nmprimtl AS CHAR  FORMAT "x(40)"                    NO-UNDO.
DEF        VAR aux_dtrefere AS DATE  FORMAT "99/99/9999"               NO-UNDO.
DEF        VAR inp_cdagenci AS INT   FORMAT "zz9"                      NO-UNDO.

DEF        VAR rel_dsagenci AS CHAR                                    NO-UNDO.
DEF        VAR rel_nmmesref AS CHAR                                    NO-UNDO.
DEF        VAR rel_vlmaidep AS DECI                                    NO-UNDO.
DEF        VAR rel_vlpercen AS DECI                                    NO-UNDO.

DEF        VAR tot_qtcremes AS INT                                     NO-UNDO.
DEF        VAR tot_dstotais AS CHAR FORMAT "x(030)" INIT
               "QUANTIDADE DE CONTAS ==>"                              NO-UNDO.
DEF        VAR ger_qtcremes AS INT                                     NO-UNDO.

DEF        VAR rel_nmempres     AS CHAR    FORMAT "x(15)"              NO-UNDO.
DEF        VAR rel_nmrelato     AS CHAR    FORMAT "x(40)" EXTENT 5     NO-UNDO.

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                      NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]                NO-UNDO.

DEF        VAR aux_nmmesref AS CHAR                                    NO-UNDO.

glb_cdprogra = "crps274".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     QUIT.

FORM rel_dsagenci AT  1 FORMAT "x(21)" LABEL "PA"
     rel_nmmesref       FORMAT "x(20)" LABEL "MES DE REFERENCIA"
     rel_vlmaidep AT 79 LABEL "CREDITOS ACIMA DE"
     SKIP(1)
     WITH COL 8 NO-BOX NO-ATTR-SPACE SIDE-LABELS WIDTH 132 FRAME f_agencia.

FORM aux_nrdconta   FORMAT "zzzz,zzz,9"        LABEL "CONTA/DV"
     aux_nmprimtl   FORMAT "x(40)"             LABEL "TITULAR"
     aux_nrcpfcgc   FORMAT "x(20)"             LABEL "CPF/CNPJ"
     aux_vlcremes   FORMAT "z,zzz,zzz,zz9.99"  LABEL "CREDITO DO MES"
     aux_vltotcre   FORMAT "z,zzz,zzz,zz9.99"  LABEL "MEDIA HISTORICA"
     aux_acrescim   FORMAT "z,zzz,zzz,zz9.99-" LABEL "VARIACAO %"
     WITH COL 8 NO-BOX NO-ATTR-SPACE DOWN NO-LABEL WIDTH 132 FRAME f_saldos.

FORM SKIP(1)
     tot_dstotais   FORMAT "x(030)"
     tot_qtcremes   FORMAT "zzz,zz9"
     SKIP(2)
     WITH COL 8 NO-BOX NO-ATTR-SPACE NO-LABEL WIDTH 132 FRAME f_totais.

FORM SKIP(2)
     "**************************************************************" AT 35
     "*                                                            *" AT 35
     "*   RELATORIO REFERENTE PROCEDIMENTOS ADOTADOS COM RELACAO   *" AT 35
     "*   ******************************************************   *" AT 35
     "*     A CIRCULAR NUMERO 2852 DO BANCO CENTRAL DO BRASIL.     *" AT 35
     "*     **************************************************     *" AT 35
     "*                                                            *" AT 35
     "*                                                            *" AT 35 
     "* OBS: CREDITOS REFERENTES A ESTORNOS DE DEBITOS E EMPRES-   *" AT 35 
     "*            TIMOS NAO FORAM CONSIDERADOS.                   *" AT 35 
     "*                                                            *" AT 35  
     "*                                                            *" AT 35
     "*   ASSINATURA DA GERENCIA: ______________________________   *" AT 35
     "*                                                            *" AT 35
     "**************************************************************" AT 35
     SKIP(3)
     WITH COL 8 NO-BOX NO-ATTR-SPACE WIDTH 132 FRAME f_termo.

{ includes/cabrel132_1.i }

/* Roda somente no dia 10 (ou seguinte) de cada mes */

IF   DAY(glb_dtmvtolt) >= 10 AND
     DAY(glb_dtmvtoan) <  10 THEN
     . 
ELSE
     DO:
         RUN fontes/fimprg.p.
         QUIT.
     END.

/*  Procura tabela com valor de referencia  */

FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                   craptab.nmsistem = "CRED"         AND
                   craptab.tptabela = "USUARI"       AND
                   craptab.cdempres = 11             AND
                   craptab.cdacesso = "PARLAVAGEM"   AND
                   craptab.tpregist = 000            NO-LOCK NO-ERROR.

IF   AVAILABLE craptab   THEN
     DO:
         ASSIGN rel_vlmaidep = DECIMAL(SUBSTR(craptab.dstextab,1,12))
                rel_vlpercen = DECIMAL(SUBSTR(craptab.dstextab,14,6)).
     END.

ASSIGN aux_nmmesref = "JANEIRO/,FEVEREIRO/,MARCO/,ABRIL/,MAIO/,JUNHO/,JULHO/," +
                      "AGOSTO/,SETEMBRO/,OUTUBRO/,NOVEMBRO/,DEZEMBRO/"

       aux_dtrefere = glb_dtmvtolt - DAY(glb_dtmvtolt)
       rel_nmmesref = ENTRY(MONTH(aux_dtrefere),aux_nmmesref) +
                      STRING(YEAR(aux_dtrefere),"9999").

OUTPUT STREAM str_1 TO arq/crrl274.tmp.

FOR EACH crapsld WHERE crapsld.cdcooper  = glb_cdcooper   AND
                       crapsld.vlcremes >= rel_vlmaidep   NO-LOCK:

    /*FIND  crapass OF crapsld NO-LOCK NO-ERROR.*/
    FIND  crapass WHERE crapass.cdcooper = glb_cdcooper AND
                        crapass.nrdconta = crapsld.nrdconta
                        NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapass THEN
         DO:
            glb_cdcritic = 251.
            RUN fontes/critic.p.
            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                      glb_cdprogra + "' --> '" + glb_dscritic +
                                     " >> log/proc_batch.log").
            RETURN.
         END.

    IF   LENGTH(STRING(crapass.nrcpfcgc)) = 11 OR
         LENGTH(STRING(crapass.nrcpfcgc)) = 10 OR
         LENGTH(STRING(crapass.nrcpfcgc)) =  9   THEN
         ASSIGN aux_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999")
                aux_nrcpfcgc = STRING(aux_nrcpfcgc,"      xxx.xxx.xxx-xx").
    ELSE
         ASSIGN aux_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999999")
                aux_nrcpfcgc = STRING(aux_nrcpfcgc,"  xx.xxx.xxx/xxxx-xx").

    aux_vltotcre = (crapsld.vltotcre[1]  + crapsld.vltotcre[2]  +
                    crapsld.vltotcre[3]  + crapsld.vltotcre[4]  +
                    crapsld.vltotcre[5]  + crapsld.vltotcre[6]  +
                    crapsld.vltotcre[7]  + crapsld.vltotcre[8]  +
                    crapsld.vltotcre[9]  + crapsld.vltotcre[10] +
                    crapsld.vltotcre[11] + crapsld.vltotcre[12]) / 12.
                     
    IF   aux_vltotcre > 0 THEN
         aux_acrescim = (((crapsld.vlcremes / aux_vltotcre) - 1) * 100).
    ELSE  
         aux_acrescim = 100.
    
    PUT STREAM str_1
               crapass.cdagenci      FORMAT "999"              " "
               crapsld.nrdconta      FORMAT "99999999"         " "
               aux_nrcpfcgc          FORMAT "x(020)"           " "
               crapsld.vlcremes      FORMAT "999999999999.99"  " "
               aux_vltotcre          FORMAT "999999999999.99"  " "
               aux_acrescim          FORMAT "999999999999.99-" ' "'
               crapass.nmprimtl      FORMAT "x(40)"           '"'  SKIP.

END.  /*  Fim do FOR EACH  --  Leitura do crapsld  */

OUTPUT STREAM str_1 CLOSE.

UNIX SILENT VALUE("sort -o arq/crrl274.tmp"+ " arq/crrl274.tmp").

INPUT STREAM str_2 FROM arq/crrl274.tmp NO-ECHO.

OUTPUT STREAM str_1 TO "rl/crrl222.lst" PAGED PAGE-SIZE 84.

VIEW STREAM str_1 FRAME f_cabrel132_1.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:     /*  Leitura do arquivo temporario  */

   SET STREAM str_2
       rel_cdagenci FORMAT "999"
       aux_nrdconta FORMAT "99999999"
       aux_nrcpfcgc FORMAT "x(20)"         
       aux_vlcremes FORMAT "999999999999.99"
       aux_vltotcre FORMAT "999999999999.99"
       aux_acrescim FORMAT "999999999999.99-"
       aux_nmprimtl FORMAT "x(40)".

   IF   inp_cdagenci <> rel_cdagenci   THEN     /*  Quebra de agencia  */
        DO:
            IF   inp_cdagenci <> 0 THEN
                 DO:
                     IF   LINE-COUNTER(str_1) >= 83   THEN
                          DO:
                              PAGE STREAM str_1.

                              DISPLAY STREAM str_1
                                             rel_dsagenci rel_nmmesref 
                                             rel_vlmaidep
                                             WITH FRAME f_agencia.
                          END.

                     DISPLAY STREAM str_1 tot_dstotais 
                             tot_qtcremes WITH FRAME f_totais.

                     tot_qtcremes = 0.

                 END.

            PAGE STREAM str_1.

            FIND crapage WHERE crapage.cdcooper = glb_cdcooper AND
                               crapage.cdagenci = rel_cdagenci NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE crapage THEN
                 rel_dsagenci = STRING(rel_cdagenci,"zz9") + " - Desconhecida".
            ELSE
                 rel_dsagenci = STRING(rel_cdagenci,"zz9") + " - " +
                               crapage.nmresage.

            DISPLAY STREAM str_1
                           rel_dsagenci rel_nmmesref rel_vlmaidep 
                           WITH FRAME f_agencia.

            inp_cdagenci = rel_cdagenci.

        END.     /*  Fim da quebra de agencia  */

   ASSIGN tot_qtcremes = tot_qtcremes + 1
          ger_qtcremes = ger_qtcremes + 1.

   DISPLAY STREAM str_1
           aux_nrdconta  aux_nmprimtl
           aux_nrcpfcgc  aux_vlcremes 
           aux_vltotcre  aux_acrescim WHEN aux_acrescim > 0 
                         WITH FRAME f_saldos.

   DOWN STREAM str_1 WITH FRAME f_saldos.

   IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
        DO:
            PAGE STREAM str_1.

            DISPLAY STREAM str_1
                    rel_dsagenci  rel_nmmesref rel_vlmaidep 
                    WITH FRAME f_agencia.
        END.

END.   /*  Fim do DO WHILE TRUE  --  Leitura do arquivo temporario  */

INPUT STREAM str_2 CLOSE.

UNIX SILENT "rm arq/crrl274.tmp 2> /dev/null". 

IF   LINE-COUNTER(str_1) >= 83   THEN
     DO:
         PAGE STREAM str_1.

         DISPLAY STREAM str_1
                 rel_dsagenci  rel_nmmesref rel_vlmaidep 
                 WITH FRAME f_agencia.
     END.

DISPLAY STREAM str_1 tot_dstotais tot_qtcremes WITH FRAME f_totais.

DOWN STREAM str_1 WITH FRAME f_totais.

ASSIGN tot_qtcremes = ger_qtcremes
       tot_dstotais = "QUANTIDADE GERAL DE CONTAS ==> ".

DISPLAY STREAM str_1 tot_dstotais tot_qtcremes WITH FRAME f_totais.

VIEW STREAM str_1 FRAME f_termo.

OUTPUT STREAM str_1 CLOSE.

ASSIGN glb_nmarqimp = "rl/crrl222.lst"
       glb_nmformul = "132dm"
       glb_nrcopias = 1.

RUN fontes/imprim.p. 

RUN fontes/fimprg.p.

/* .......................................................................... */

