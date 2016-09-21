/* ..........................................................................

   Programa: Fontes/crps098.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Novembro/94                         Ultima atualizacao: 15/02/2006

   Dados referentes ao programa:

   Frequencia: Mensal (Batch - Background).
   Objetivo  : Atende a solicitacao 054.
               Emitir a listagem das taxas de RDC e Poupanca.

   Alteracoes: 06/11/94 - Alterado para emitir a observacao que nos dias 29,30 e
                          31 de cada mes nao existe poupanca (Odair).

               24/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               19/07/99 - Alterado para chamar a rotina de impressao (Edson).

               11/02/2000 - Gerar pedido de impressao (Deborah).

               13/03/2001 - Alterar formulario para 80col (Deborah).
               
               15/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
............................................................................. */

DEF STREAM str_1.     /*  Para tabela mensal da poupanca e rdc  */

{ includes/var_batch.i "NEW" }

DEF        VAR rel_nmresemp AS CHAR    FORMAT "x(15)"               NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5      NO-UNDO.
DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                   NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                                   INIT ["DEP. A VISTA   ","CAPITAL        ",
                                        "EMPRESTIMOS    ","DIGITACAO      ",
                                        "GENERICO       "]          NO-UNDO.

DEF        VAR rel_nmmesref AS CHAR                                 NO-UNDO.
DEF        VAR rel_nrdiames AS INT                                  NO-UNDO.
DEF        VAR rel_vldifere AS DECIMAL FORMAT "zz,zzz,zz9.9999+"    NO-UNDO.

DEF        VAR tab_vldapoup AS DECIMAL EXTENT 31                    NO-UNDO.
DEF        VAR tab_vlrdcrdc AS DECIMAL EXTENT 31                    NO-UNDO.

DEF        VAR aux_nmmesref AS CHAR                                 NO-UNDO.
DEF        VAR aux_nmarquiv AS CHAR                                 NO-UNDO.

DEF        VAR aux_dtrefere AS DATE                                 NO-UNDO.
DEF        VAR aux_dtultdia AS DATE                                 NO-UNDO.

ASSIGN glb_cdprogra = "crps098".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

FORM SKIP(5)
     "Mes de referencia:"
     rel_nmmesref AT 20 FORMAT "x(20)"
     SKIP(2)
     WITH NO-BOX NO-ATTR-SPACE NO-LABELS WIDTH 80 FRAME f_refere.

FORM "DIA           RDC          POUPANCA         DIFERENCA "      AT 12
     "----------------------------------------------------------"  AT 12
     WITH NO-BOX NO-ATTR-SPACE WIDTH 80 FRAME f_label.

FORM rel_nrdiames                AT 13 FORMAT "99"
     tab_vlrdcrdc[rel_nrdiames]  AT 19 FORMAT "zz,zzz,zz9.9999"
     tab_vldapoup[rel_nrdiames]  AT 37 FORMAT "zz,zzz,zz9.9999"
     rel_vldifere                AT 55 FORMAT "zz,zzz,zz9.9999+"
     "----------------------------------------------------------"  AT 12
     WITH NO-BOX NO-ATTR-SPACE NO-LABELS WIDTH 80 FRAME f_dados.

FORM SKIP(5)
     "**********************************************************"  AT 12
     "*                                                        *"  AT 12
     "* OBS:  NAO  HA  VENCIMENTO  DE  CADERNETA  DE POUPANCA  *"  AT 12
     "*                  NOS  DIAS  29, 30 E 31                *"  AT 12
     "*                                                        *"  AT 12
     "**********************************************************"  AT 12
     WITH NO-BOX NO-ATTR-SPACE WIDTH 80 FRAME f_observ.

{includes/cabrel080_1.i}

FOR EACH crapsol WHERE crapsol.cdcooper = glb_cdcooper  AND
                       crapsol.nrsolici = 54            AND
                       crapsol.dtrefere = glb_dtmvtolt  AND
                       crapsol.insitsol = 1:

    ASSIGN aux_dtrefere = DATE(INTEGER(SUBSTRING(crapsol.dsparame,1,2)),01,
                               INTEGER(SUBSTRING(crapsol.dsparame,3,4)))

           aux_nmmesref = "JANEIRO/,FEVEREIRO/,MARCO/, ABRIL/,MAIO/,JUNHO/," +
                         "JULHO/,AGOSTO/,SETEMBRO/,OUTUBRO/,NOVEMBRO/,DEZEMBRO/"

           aux_dtultdia = ((DATE(MONTH(aux_dtrefere),28,YEAR(aux_dtrefere)) + 4)
                          - DAY(DATE(MONTH(aux_dtrefere),28,
                                                  YEAR(aux_dtrefere)) + 4))

           rel_nmmesref = ENTRY(MONTH(aux_dtrefere),aux_nmmesref) +
                                STRING(YEAR(aux_dtrefere),"9999")

           aux_nmarquiv = "rl/crrl083_" + STRING(crapsol.nrseqsol) + ".lst"
           glb_nrcopias = crapsol.nrdevias
           glb_nmformul = "80col"
           glb_nmarqimp = aux_nmarquiv
           tab_vldapoup = 0
           tab_vlrdcrdc = 0.

    FOR EACH crapmfx WHERE crapmfx.cdcooper  = glb_cdcooper   AND
                           crapmfx.dtmvtolt >= aux_dtrefere   AND
                           crapmfx.dtmvtolt <= aux_dtultdia   AND
                           (crapmfx.tpmoefix = 6 OR 
                            crapmfx.tpmoefix = 8)             NO-LOCK:

        IF   crapmfx.tpmoefix = 6   THEN
             tab_vlrdcrdc[DAY(crapmfx.dtmvtolt)] = crapmfx.vlmoefix.
        ELSE
             tab_vldapoup[DAY(crapmfx.dtmvtolt)] = crapmfx.vlmoefix.

    END.  /*  Fim do FOR EACH -- Leitura das moedas fixas do mes corrente  */

    OUTPUT STREAM str_1 TO VALUE(aux_nmarquiv) PAGED PAGE-SIZE 84.

    VIEW STREAM str_1 FRAME f_cabrel080_1 .

    DISPLAY STREAM str_1 rel_nmmesref WITH FRAME f_refere.

    DISPLAY STREAM str_1  WITH FRAME f_label.

    /*  Lista RDC E POUPANCA   */

    DO rel_nrdiames = 1 TO DAY(aux_dtultdia):

        IF   tab_vlrdcrdc[rel_nrdiames] = 0 THEN
             NEXT.

        IF   rel_nrdiames < 29  THEN
             rel_vldifere = tab_vlrdcrdc[rel_nrdiames] -
                            tab_vldapoup[rel_nrdiames].
        ELSE
             rel_vldifere = 0.

        DISPLAY STREAM str_1
                rel_nrdiames
                tab_vlrdcrdc[rel_nrdiames] WHEN tab_vlrdcrdc[rel_nrdiames] > 0
                tab_vldapoup[rel_nrdiames] WHEN tab_vldapoup[rel_nrdiames] > 0
                rel_vldifere WHEN rel_vldifere <> 0  WITH FRAME f_dados.

        DOWN STREAM str_1 WITH FRAME f_dados.

    END.  /*  Fim do DO .. TO  */

    DISPLAY STREAM str_1 WITH FRAME f_observ.

    OUTPUT STREAM str_1 CLOSE.

    DO TRANSACTION ON ERROR UNDO, RETRY:

       crapsol.insitsol = 2.

    END.  /*  Fim da transacao  */
                            
    RUN fontes/imprim.p.
            
END. /* Fim do FOR EACH do crapsol. */

RUN fontes/fimprg.p.

/* .......................................................................... */

