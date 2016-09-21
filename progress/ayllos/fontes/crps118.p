/* .............................................................................

   Programa: Fontes/crps118.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Maio/95.                            Ultima atualizacao: 11/11/2013

   Dados referentes ao programa:

   Frequencia: Atenda a solicitacao 60.
   Objetivo  : Emitir resumo dos pagamentos e liberacoes de emprestimos.
               Ordem do programa na solicitacao :  1
               Ordem da solicitacao na cadeia   : 57
               Emite relatorio 96.
               Roda com exclusividade 2.

   Alteracoes: 31/05/95 - Tratar o historico 95 (Edson).

               27/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               22/03/2000 - Tratar o historico 353 (Deborah).
               
               16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
               
               11/11/2013 - Alterado totalizador de PAs de 99 para 999.
                           (Reinert)
               
............................................................................. */

DEF STREAM str_1.     /*  Para resumo dos pagamentose lib. de emprestimos */

{ includes/var_batch.i "NEW" }

DEF   VAR rel_nmempres AS CHAR    FORMAT "x(15)"                       NO-UNDO.
DEF   VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5              NO-UNDO.
DEF   VAR rel_nrmodulo AS INT     FORMAT "9"                           NO-UNDO.
DEF   VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                             INIT ["DEP. A VISTA   ","CAPITAL        ",
                                  "EMPRESTIMOS    ","DIGITACAO      ",
                                   "GENERICO       "]                  NO-UNDO.
                                                                   
DEF   VAR rel_dsagenci AS CHAR                                         NO-UNDO.
DEF   VAR rel_nmmesref AS CHAR                                         NO-UNDO.
                                                                   
DEF   VAR aux_dtreffim AS DATE                                         NO-UNDO.
DEF   VAR aux_dtrefini AS DATE                                         NO-UNDO.
DEF   VAR aux_nmmesref AS CHAR                                         NO-UNDO.
DEF   VAR aux_nmarquiv AS CHAR                                         NO-UNDO.

DEF   VAR aux_contador AS INT                                          NO-UNDO.
DEF   VAR tab_qtlanfol AS INT     EXTENT 999 FORMAT "zzz,zz9"          NO-UNDO.
DEF   VAR tab_vllanfol AS DECIMAL EXTENT 999 FORMAT "zzzz,zzz,zz9.99"  NO-UNDO.
DEF   VAR tab_qtlancax AS INT     EXTENT 999 FORMAT "zzz,zz9"          NO-UNDO.
DEF   VAR tab_vllancax AS DECIMAL EXTENT 999 FORMAT "zzzz,zzz,zz9.99"  NO-UNDO.
DEF   VAR tab_qtlanlib AS INT     EXTENT 999 FORMAT "zzz,zz9"          NO-UNDO.
DEF   VAR tab_vllanlib AS DECIMAL EXTENT 999 FORMAT "zzzz,zzz,zz9.99"  NO-UNDO.
DEF   VAR aux_qttotlan AS INT                FORMAT "zzz,zz9"          NO-UNDO.
DEF   VAR aux_vltotlan AS DECIMAL            FORMAT "zzz,zzz,zz9.99"   NO-UNDO.
DEF   VAR aux_vllandif AS DECIMAL            FORMAT "zzzz,zzz,zz9.99-" NO-UNDO.
DEF   VAR aux_nrmaxpas AS INT                                          NO-UNDO.

ASSIGN glb_cdprogra = "crps118".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

FORM SKIP(2)
     rel_nmmesref  AT 01 LABEL "MES DE REFERENCIA"  FORMAT "x(20)"
     SKIP(2)
     "AGENCIA                  PAGAMENTOS P/FOLHA      PAGAMENTOS P/CAIXA" AT 01
     "TOTAL DE PAGAMENTOS              LIBERACOES        DIFERENCA"        AT 73
     SKIP
     "------------------- ----------------------- -----------------------" AT 01
     "----------------------- ----------------------- ----------------"    AT 69
     WITH NO-BOX SIDE-LABELS WIDTH 132 DOWN FRAME f_label.

FORM rel_dsagenci                AT  01 FORMAT "x(19)"
     tab_qtlanfol[aux_contador]  AT  21
     tab_vllanfol[aux_contador]  AT  29
     tab_qtlancax[aux_contador]  AT  45
     tab_vllancax[aux_contador]  AT  53
     aux_qttotlan                AT  69
     aux_vltotlan                AT  78
     tab_qtlanlib[aux_contador]  AT  93
     tab_vllanlib[aux_contador]  AT 101
     aux_vllandif                AT 117
     WITH NO-BOX NO-ATTR-SPACE NO-LABELS WIDTH 132 DOWN FRAME f_dados.

FORM "----------------------- -----------------------"                  AT 21
     "----------------------- ----------------------- ----------------" AT 69
     WITH NO-BOX WIDTH 132 DOWN FRAME f_traco.

FOR LAST crapage FIELDS (cdagenci)
                 WHERE crapage.cdcooper = glb_cdcooper
                 NO-LOCK
                 BY crapage.cdagenci:

   ASSIGN aux_nrmaxpas = crapage.cdagenci.

END.

{ includes/cabrel132_1.i }

FOR EACH crapsol WHERE crapsol.cdcooper = glb_cdcooper  AND
                       crapsol.nrsolici = 60            AND
                       crapsol.dtrefere = glb_dtmvtolt  AND
                       crapsol.insitsol = 1:

    ASSIGN aux_dtrefini = DATE((INTEGER(SUBSTRING(crapsol.dsparame,1,2))),01,
                              (INTEGER(SUBSTRING(crapsol.dsparame,3,4))))

           aux_dtreffim = IF   MONTH(aux_dtrefini) = 12 THEN
                               DATE(01,01,YEAR(aux_dtrefini) + 1)
                          ELSE
                              DATE(MONTH(aux_dtrefini) + 1,1,YEAR(aux_dtrefini))

           aux_nmmesref = "JANEIRO/,FEVEREIRO/,MARCO/, ABRIL/,MAIO/,JUNHO/," +
                         "JULHO/,AGOSTO/,SETEMBRO/,OUTUBRO/,NOVEMBRO/,DEZEMBRO/"

           rel_nmmesref = ENTRY(MONTH(aux_dtrefini),aux_nmmesref) +
                                STRING(YEAR(aux_dtrefini),"9999")

           aux_nmarquiv = "rl/crrl096_" + STRING(crapsol.nrseqsol) + ".lst"
           glb_nrcopias = crapsol.nrdevias
           glb_nmformul = "padrao"
           glb_nmarqimp = aux_nmarquiv
           tab_qtlanfol = 0
           tab_vllanfol = 0
           tab_qtlancax = 0
           tab_vllancax = 0
           tab_qtlanlib = 0
           tab_vllanlib = 0
           aux_vltotlan = 0
           aux_vllandif = 0
           aux_qttotlan = 0.

    FOR EACH crapass WHERE crapass.cdcooper = glb_cdcooper NO-LOCK:

        FOR EACH craplem WHERE craplem.cdcooper =  glb_cdcooper     AND
                               craplem.dtmvtolt >= aux_dtrefini     AND
                               craplem.dtmvtolt <  aux_dtreffim     AND
                               craplem.nrdconta =  crapass.nrdconta AND
                               CAN-DO("92,93,95,353",STRING(craplem.cdhistor))
                               NO-LOCK:

             IF   CAN-DO("92,353",STRING(craplem.cdhistor)) AND
                  craplem.nrdolote > 2099 AND
                  craplem.nrdolote < 2400 THEN

                  ASSIGN tab_qtlancax[crapass.cdagenci] =
                             tab_qtlancax[crapass.cdagenci] + 1
                         tab_vllancax[crapass.cdagenci] =
                             tab_vllancax[crapass.cdagenci] + craplem.vllanmto
                         tab_qtlancax[99] = tab_qtlancax[99] + 1
                         tab_vllancax[99] = tab_vllancax[99] +
                             craplem.vllanmto.
             ELSE
             IF   craplem.cdhistor = 93   OR
                  craplem.cdhistor = 95   THEN
                  ASSIGN tab_qtlanfol[crapass.cdagenci] =
                             tab_qtlanfol[crapass.cdagenci] + 1
                         tab_vllanfol[crapass.cdagenci] =
                             tab_vllanfol[crapass.cdagenci] + craplem.vllanmto
                         tab_qtlanfol[99] = tab_qtlanfol[99] + 1
                         tab_vllanfol[99] = tab_vllanfol[99] +
                             craplem.vllanmto.

        END. /* Fim do FOR EACH craplem */

        FOR EACH craplcm WHERE craplcm.cdcooper =  glb_cdcooper     AND
                               craplcm.dtmvtolt >= aux_dtrefini     AND
                               craplcm.dtmvtolt <  aux_dtreffim     AND
                               craplcm.nrdconta =  crapass.nrdconta AND
                              (craplcm.cdhistor =  2                 OR
                               craplcm.cdhistor =  15) 
                               NO-LOCK USE-INDEX craplcm2:

             ASSIGN  tab_qtlanlib[crapass.cdagenci] =
                         tab_qtlanlib[crapass.cdagenci] + 1
                     tab_vllanlib[crapass.cdagenci] =
                         tab_vllanlib[crapass.cdagenci] + craplcm.vllanmto
                     tab_qtlanlib[99] = tab_qtlanlib[99] + 1
                     tab_vllanlib[99] = tab_vllanlib[99] + craplcm.vllanmto.

         END.  /* Fim do FOR EACH craplcm */

    END. /* Fim do FOR EACH crapass */

    OUTPUT STREAM str_1 TO VALUE(aux_nmarquiv) PAGED PAGE-SIZE 84.

    VIEW STREAM str_1 FRAME f_cabrel132_1 .

    DISPLAY STREAM str_1 rel_nmmesref WITH FRAME f_label.

    DO aux_contador = 1 to (aux_nrmaxpas + 1):

       IF   tab_qtlanfol[aux_contador] = 0 and
            tab_vllanfol[aux_contador] = 0 and
            tab_qtlancax[aux_contador] = 0 and
            tab_vllancax[aux_contador] = 0 and
            tab_qtlanlib[aux_contador] = 0 and
            tab_vllanlib[aux_contador] = 0 THEN
            NEXT.

        FIND crapage WHERE crapage.cdcooper = glb_cdcooper AND
                           crapage.cdagenci = aux_contador NO-LOCK NO-ERROR.

        IF   NOT AVAILABLE crapage THEN
             rel_dsagenci = STRING(aux_contador,"999") + " - NAO CADASTRADA".
        ELSE
        IF   aux_contador = (aux_nrmaxpas + 1) THEN
             rel_dsagenci = " ".
        ELSE
        rel_dsagenci = STRING(crapage.cdagenci,"999") + " - " +
                                 crapage.nmresage.

       ASSIGN aux_vltotlan = (tab_vllanfol[aux_contador] +
                              tab_vllancax[aux_contador])
              aux_qttotlan = (tab_qtlanfol[aux_contador] +
                              tab_qtlancax[aux_contador])
              aux_vllandif = (tab_vllanlib[aux_contador] - aux_vltotlan).

       IF   aux_contador = (aux_nrmaxpas + 1) THEN
            DISPLAY STREAM str_1 WITH FRAME f_traco.

       DISPLAY  STREAM str_1
                rel_dsagenci
                tab_qtlanfol[aux_contador] tab_vllanfol[aux_contador]
                tab_qtlancax[aux_contador] tab_vllancax[aux_contador]
                aux_qttotlan                aux_vltotlan
                tab_qtlanlib[aux_contador] tab_vllanlib[aux_contador]
                aux_vllandif
                WITH FRAME f_dados.

       DOWN STREAM str_1 WITH FRAME f_dados.

    END.

    OUTPUT STREAM str_1 CLOSE.

    DO TRANSACTION ON ERROR UNDO, RETRY:

       crapsol.insitsol = 2.

    END.  /*  Fim da transacao  */

    RUN fontes/imprim.p.

END. /* Fim do FOR EACH do crapsol. */

RUN fontes/fimprg.p.

/* .......................................................................... */

