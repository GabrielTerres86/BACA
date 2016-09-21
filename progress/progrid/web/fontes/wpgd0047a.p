/*
 *
 * Programa wpgd0047a.p - Listagem de sugestoes e eventos (chamado a partir dos dados de wpgd0047)
 *
 * Alteracoes - 05/06/2012 - Adaptação dos fontes para projeto Oracle. Alterado
                             busca na gnapses de CONTAINS para MATCHES 
                             (Guilherme Maba).

                28/11/2012 - Substituir tabela "gncoper" por "crapcop"
                             (David Kruger).
                             
                04/04/2013 - Alteração para receber logo na alto vale,
                             recebendo nome de viacrediav e buscando com
                             o respectivo nome (David Kruger).
                
                04/09/2013 - Nova forma de chamar as agências, de PA agora 
                            a escrita será PA (André Euzébio - Supero).             
 
 */


create widget-pool.

/*****************************************************************************/
/*                                                                           */
/*   Bloco de variaveis                                                      */
/*                                                                           */
/*****************************************************************************/


DEFINE VARIABLE cookieEmUso                  AS CHARACTER.
DEFINE VARIABLE permiteExecutar              AS CHARACTER.
DEFINE VARIABLE IdentificacaoDaSessao        AS CHARACTER.
DEFINE VARIABLE msgsDeErro                   AS CHARACTER.

DEFINE VARIABLE idEvento                     AS INTEGER.
DEFINE VARIABLE cdCooper                     AS INTEGER.
DEFINE VARIABLE cdAgenci                     AS INTEGER.
DEFINE VARIABLE dtAnoAge                     AS INTEGER.
DEFINE VARIABLE cdEvento                     AS INTEGER.
DEFINE VARIABLE nrSeqEve                     AS INTEGER.
DEFINE VARIABLE dataInicial                  AS DATE.
DEFINE VARIABLE dataFinal                    AS DATE.
DEFINE VARIABLE tipoDeRelatorio              AS INTEGER.
DEFINE VARIABLE consideraEventosForaDaAgenda AS LOGICAL.

DEFINE VARIABLE imagemDoProgrid              AS CHARACTER.
DEFINE VARIABLE imagemDaCooperativa          AS CHARACTER.
DEFINE VARIABLE nomeDaCooperativa            AS CHARACTER.
DEFINE VARIABLE nomeDoRelatorio              AS CHARACTER.

DEFINE VARIABLE auxiliar                     AS CHARACTER.
DEFINE VARIABLE facilitador                  AS CHARACTER.
DEFINE VARIABLE facilitadores                AS CHARACTER.
DEFINE VARIABLE nomeDaAgencia                AS CHARACTER.
DEFINE VARIABLE localDoEvento1               AS CHARACTER.
DEFINE VARIABLE localDoEvento2               AS CHARACTER.

DEFINE VARIABLE ajuste                       AS INTEGER.
DEFINE VARIABLE conta                        AS INTEGER.
DEFINE VARIABLE corEmUso                     AS CHARACTER.
DEFINE VARIABLE mes                          AS CHARACTER INITIAL ["janeiro,fevereiro,março,abril,maio,junho,julho,agosto,setembro,outubro,novembro,dezembro"].
DEFINE VARIABLE sobreNomeDoEvento            AS CHARACTER.
DEFINE VARIABLE titCabec                     AS CHARACTER NO-UNDO.
DEFINE VARIABLE valorDaVerba                 AS DECIMAL.

/* variaveis que dependem do tipo de tela */
/* tela por PA */
DEFINE VARIABLE totalPAC         AS INTEGER NO-UNDO.
DEFINE VARIABLE totalGeral       AS INTEGER NO-UNDO.
DEFINE VARIABLE qtidade          AS INTEGER NO-UNDO. 

DEFINE VARIABLE aux_nmrescop     AS CHARACTER NO-UNDO.

/*****************************************************************************/
/*                                                                           */
/*   Bloco de temp-tables                                                    */
/*                                                                           */
/*****************************************************************************/

DEF TEMP-TABLE ttCrapsdp NO-UNDO
    FIELD cdcooper   AS INT
    FIELD cdAgenci   AS INT
    FIELD cdevento   AS INT
    FIELD qtsugeve   AS INT
    FIELD descEvento LIKE crapedp.nmevento
    FIELD nrseqdig   AS INT
    FIELD dssugeve   LIKE crapsdp.dssugeve
    INDEX idx1 cdcooper cdagenci cdevento.

/*****************************************************************************/
/*                                                                           */
/*   Bloco de includes                                                       */
/*                                                                           */
/*****************************************************************************/

{src/web/method/wrap-cgi.i}


/*****************************************************************************/
/*                                                                           */
/*   Bloco de funçoes                                                        */
/*                                                                           */
/*****************************************************************************/

FUNCTION erroNaValidacaoDoLogin RETURNS LOGICAL (opcao AS CHARACTER):

    IF opcao = "1" THEN /* get-cookie em usuario-em-uso voltou valor nulo */
       {&out} '<script language="Javascript">' SKIP
              '   top.close(); ' SKIP
              '   window.open("falha","janela_principal","toolbar=yes,location=yes,diretories=no,status=yes,menubar=yes,scrollbars=yes,resizable=yes");' SKIP
              '</script>' SKIP.

    IF opcao = "2" THEN /* identificacao vinda do cookie bao existe na tabela de log de sessao */ 
       DO: 
          DELETE-COOKIE("cookie-usuario-em-uso",?,?).
          {&out} '<script language="Javascript">' SKIP
                 '   top.close(); ' SKIP
                 '   window.open("falha","janela_principal","toolbar=yes,location=yes,diretories=no,status=yes,menubar=yes,scrollbars=yes,resizable=yes");' SKIP
                 '</script>' SKIP.
       END.

    RETURN TRUE.

END FUNCTION. /* erroNaValidacaoDoLogin RETURNS LOGICAL () */

FUNCTION montaTelaPAC RETURNS LOGICAL ():

    {&out} '   <table border="0" cellspacing="0" cellpadding="0" width="100%">' SKIP.
    ASSIGN corEmUso = "#FFFFFF".

    FOR EACH crapsdp WHERE crapsdp.idevento = 1
                       AND crapsdp.cdcooper = cdCooper
                       AND crapsdp.dtmvtolt >= dataInicial
                       AND crapsdp.dtmvtolt <= dataFinal
                       AND crapsdp.flgsugca = NO 
                   NO-LOCK:
        IF crapsdp.cdevento = ? THEN NEXT.
        IF cdAgenci <> 0 THEN DO: 
           IF cdAgenci <> crapsdp.cdagenci AND crapsdp.cdagenci <> 0 THEN DO : 
               NEXT.
           END.
        END.
        IF crapsdp.cdagenci = 0 THEN DO:
           IF cdAgenci = 0 THEN DO:
               FOR EACH crapage WHERE crapage.CdCooper = crapsdp.cdcooper
                                NO-LOCK:
                   IF NOT CAN-FIND(crapagp WHERE crapagp.idevento = 1 
                                             AND crapagp.cdcooper = crapsdp.cdcooper
                                             AND crapagp.dtanoage = dtanoage
                                             AND crapagp.cdagenci = crapage.cdagenci) THEN NEXT.
                   FIND FIRST ttCrapsdp WHERE ttCrapsdp.cdcooper = crapsdp.cdcooper
                                          AND ttCrapsdp.cdAgenci = crapage.cdagenci
                                          AND ttCrapsdp.cdevento = crapsdp.cdevento
                                        NO-ERROR.
                   IF NOT AVAIL ttCrapsdp THEN DO:
                      CREATE ttCrapsdp.
                      ASSIGN ttCrapsdp.cdcooper = crapsdp.cdcooper
                             ttCrapsdp.cdAgenci = crapage.cdagenci
                             ttCrapsdp.cdevento = crapsdp.cdevento.
                   END.
                   ASSIGN ttCrapsdp.qtsugeve = ttCrapsdp.qtsugeve + crapsdp.qtsugeve.
               END.
           END.
           ELSE DO:
               IF NOT CAN-FIND(crapagp WHERE crapagp.idevento = 1 
                                         AND crapagp.cdcooper = crapsdp.cdcooper
                                         AND crapagp.dtanoage = dtanoage
                                         AND crapagp.cdagenci = cdagenci) THEN NEXT.
               FIND FIRST ttCrapsdp WHERE ttCrapsdp.cdcooper = crapsdp.cdcooper
                                      AND ttCrapsdp.cdAgenci = cdagenci
                                      AND ttCrapsdp.cdevento = crapsdp.cdevento
                                    NO-ERROR.
               IF NOT AVAIL ttCrapsdp THEN DO:
                  CREATE ttCrapsdp.
                  ASSIGN ttCrapsdp.cdcooper = crapsdp.cdcooper
                         ttCrapsdp.cdAgenci = cdagenci
                         ttCrapsdp.cdevento = crapsdp.cdevento.
               END.
               ASSIGN ttCrapsdp.qtsugeve = ttCrapsdp.qtsugeve + crapsdp.qtsugeve.
           END.
        END.
        ELSE DO:
            IF NOT CAN-FIND(crapagp WHERE crapagp.idevento = 1 
                                      AND crapagp.cdcooper = crapsdp.cdcooper
                                      AND crapagp.dtanoage = dtanoage
                                      AND crapagp.cdagenci = crapsdp.cdagenci) THEN NEXT.
            FIND FIRST ttCrapsdp WHERE ttCrapsdp.cdcooper = crapsdp.cdcooper
                                   AND ttCrapsdp.cdAgenci = crapsdp.cdagenci
                                   AND ttCrapsdp.cdevento = crapsdp.cdevento
                                 NO-ERROR.
            IF NOT AVAIL ttCrapsdp THEN DO:
               CREATE ttCrapsdp.
               ASSIGN ttCrapsdp.cdcooper = crapsdp.cdcooper
                      ttCrapsdp.cdAgenci = crapsdp.cdagenci
                      ttCrapsdp.cdevento = crapsdp.cdevento.
            END.
            ASSIGN ttCrapsdp.qtsugeve = ttCrapsdp.qtsugeve + crapsdp.qtsugeve.
        END.
    END.
    ASSIGN titCabec = "Sugestões por PA".
    IF NOT CAN-FIND(FIRST ttCrapsdp) THEN DO:
        {&out} '      <tr bgcolor="#FFFFFF">' SKIP
               '         <td colspan="5" align="center">Não há registro de sugestões para o filtro informado</td>' SKIP
               '      </tr>' SKIP.
    END.
    ELSE DO:
        FOR EACH ttCrapsdp BREAK BY ttCrapsdp.cdagenci 
                                 BY ttCrapsdp.qtsugeve DESC:
            RUN detalheTelaPAC (FIRST(ttCrapsdp.cdagenci),FIRST-OF(ttCrapsdp.cdagenci),LAST-OF(ttCrapsdp.cdagenci),LAST(ttCrapsdp.cdagenci)).
        END.
    END.

    {&out} '   </table>' SKIP.

    RETURN TRUE.

END FUNCTION. /* montaTelaPAC RETURNS LOGICAL () */

FUNCTION montaTelaEvento RETURNS LOGICAL ():

    {&out} '   <table border="0" cellspacing="0" cellpadding="0" width="100%">' SKIP.
    ASSIGN corEmUso = "#FFFFFF".

    IF cdAgenci <> 0 THEN DO:
        FOR EACH crapsdp WHERE crapsdp.idevento = 1
                           AND crapsdp.cdcooper = cdCooper
                           AND crapsdp.cdagenci = cdAgenci
                           AND crapsdp.dtmvtolt >= dataInicial
                           AND crapsdp.dtmvtolt <= dataFinal
                           AND crapsdp.flgsugca = NO 
                       NO-LOCK:
            IF crapsdp.cdevento = ? THEN NEXT.
            FIND FIRST ttCrapsdp WHERE ttCrapsdp.cdcooper = crapsdp.cdcooper
                                   AND ttCrapsdp.cdAgenci = crapsdp.cdagenci
                                   AND ttCrapsdp.cdevento = crapsdp.cdevento
                                 NO-ERROR.
            IF NOT AVAIL ttCrapsdp THEN DO:
               CREATE ttCrapsdp.
               ASSIGN ttCrapsdp.cdcooper = crapsdp.cdcooper
                      ttCrapsdp.cdAgenci = crapsdp.cdagenci
                      ttCrapsdp.cdevento = crapsdp.cdevento.
               FIND FIRST crapedp WHERE crapedp.idevento = idEvento
                                    AND crapedp.cdcooper = 0
                                    AND crapedp.dtanoage = 0 
                                    AND crapedp.cdevento = crapsdp.cdevento
                                  NO-LOCK NO-ERROR.
               IF AVAIL crapedp THEN
                  ASSIGN ttCrapsdp.descEvento = crapedp.nmevento.
               ELSE 
                  ASSIGN ttCrapsdp.descEvento = '** Evento código "' + (IF ttCrapsdp.cdEvento = ? THEN '? (indefinido)' ELSE string(ttcrapsdp.cdEvento)) + '" sem descrição **'.
            END.
            ASSIGN ttCrapsdp.qtsugeve = ttCrapsdp.qtsugeve + crapsdp.qtsugeve.
        END.
    END.
    ELSE DO:
        FOR EACH crapsdp WHERE crapsdp.idevento = 1
                           AND crapsdp.cdcooper = cdCooper
                           AND crapsdp.dtmvtolt >= dataInicial
                           AND crapsdp.dtmvtolt <= dataFinal
                           AND crapsdp.flgsugca = NO 
                       NO-LOCK:
            IF crapsdp.cdevento = ? THEN NEXT.
            FIND FIRST ttCrapsdp WHERE ttCrapsdp.cdcooper = crapsdp.cdcooper
                                   AND ttCrapsdp.cdAgenci = 0
                                   AND ttCrapsdp.cdevento = crapsdp.cdevento
                                 NO-ERROR.
            IF NOT AVAIL ttCrapsdp THEN DO:
               CREATE ttCrapsdp.
               ASSIGN ttCrapsdp.cdcooper = crapsdp.cdcooper
                      ttCrapsdp.cdAgenci = 0
                      ttCrapsdp.cdevento = crapsdp.cdevento.
               FIND FIRST crapedp WHERE crapedp.idevento = idEvento
                                    AND crapedp.cdcooper = 0
                                    AND crapedp.dtanoage = 0 
                                    AND crapedp.cdevento = crapsdp.cdevento
                                  NO-LOCK NO-ERROR.
               IF AVAIL crapedp THEN
                  ASSIGN ttCrapsdp.descEvento = crapedp.nmevento.
               ELSE 
                  ASSIGN ttCrapsdp.descEvento = '** Evento código "' + (IF ttCrapsdp.cdEvento = ? THEN '? (indefinido)' ELSE string(ttcrapsdp.cdEvento)) + '" sem descrição **'.
            END.
            ASSIGN ttCrapsdp.qtsugeve = ttCrapsdp.qtsugeve + crapsdp.qtsugeve.
        END.
    END.
    ASSIGN titCabec = "Sugestões por Evento".
    IF NOT CAN-FIND(FIRST ttCrapsdp) THEN DO:
       {&out} '      <tr bgcolor="#FFFFFF">' SKIP
              '         <td colspan="5" align="center">Não há registro de sugestões para o filtro informado</td>' SKIP
              '      </tr>' SKIP.
    END.
    ELSE DO:
        FOR EACH ttCrapsdp BREAK BY ttCrapsdp.cdagenci BY ttCrapsdp.descEvento:
            RUN detalheTelaPAC (FIRST(ttCrapsdp.cdagenci),FIRST-OF(ttCrapsdp.cdagenci),LAST-OF(ttCrapsdp.cdagenci),LAST(ttCrapsdp.cdagenci)).
        END.
    END.

    {&out} '   </table>' SKIP.

    RETURN TRUE.

END FUNCTION. /* montaTelaEvento RETURNS LOGICAL () */


FUNCTION montaTelaQuantidade RETURNS LOGICAL ():

    {&out} '   <table border="0" cellspacing="0" cellpadding="0" width="100%">' SKIP.
    ASSIGN corEmUso = "#FFFFFF".

    IF cdAgenci <> 0 THEN DO:
        FOR EACH crapsdp WHERE crapsdp.idevento = 1
                           AND crapsdp.cdcooper = cdCooper
                           AND crapsdp.cdagenci = cdAgenci
                           AND crapsdp.dtmvtolt >= dataInicial
                           AND crapsdp.dtmvtolt <= dataFinal
                           AND crapsdp.flgsugca = NO 
                       NO-LOCK:
            IF crapsdp.cdevento = ? THEN NEXT.
            FIND FIRST ttCrapsdp WHERE ttCrapsdp.cdcooper = crapsdp.cdcooper
                                   AND ttCrapsdp.cdAgenci = crapsdp.cdagenci
                                   AND ttCrapsdp.cdevento = crapsdp.cdevento
                                 NO-ERROR.
            IF NOT AVAIL ttCrapsdp THEN DO:
               CREATE ttCrapsdp.
               ASSIGN ttCrapsdp.cdcooper = crapsdp.cdcooper
                      ttCrapsdp.cdAgenci = crapsdp.cdagenci
                      ttCrapsdp.cdevento = crapsdp.cdevento.
            END.
            ASSIGN ttCrapsdp.qtsugeve = ttCrapsdp.qtsugeve + crapsdp.qtsugeve.
        END.
    END.
    ELSE DO:
        FOR EACH crapsdp WHERE crapsdp.idevento = 1
                           AND crapsdp.cdcooper = cdCooper
                           AND crapsdp.dtmvtolt >= dataInicial
                           AND crapsdp.dtmvtolt <= dataFinal
                           AND crapsdp.flgsugca = NO 
                       NO-LOCK:
            IF crapsdp.cdevento = ? THEN NEXT.
            FIND FIRST ttCrapsdp WHERE ttCrapsdp.cdcooper = crapsdp.cdcooper
                                   AND ttCrapsdp.cdAgenci = 0
                                   AND ttCrapsdp.cdevento = crapsdp.cdevento
                                 NO-ERROR.
            IF NOT AVAIL ttCrapsdp THEN DO:
               CREATE ttCrapsdp.
               ASSIGN ttCrapsdp.cdcooper = crapsdp.cdcooper
                      ttCrapsdp.cdAgenci = 0
                      ttCrapsdp.cdevento = crapsdp.cdevento.
            END.
            ASSIGN ttCrapsdp.qtsugeve = ttCrapsdp.qtsugeve + crapsdp.qtsugeve.
        END.
    END.
    ASSIGN titCabec = "Sugestões por Quantidade".
    IF NOT CAN-FIND(FIRST ttCrapsdp) THEN DO:
       {&out} '      <tr bgcolor="#FFFFFF">' SKIP
              '         <td colspan="5" align="center">Não há registro de sugestões para o filtro informado</td>' SKIP
              '      </tr>' SKIP.
    END.
    ELSE DO:
       FOR EACH ttCrapsdp BREAK BY ttCrapsdp.cdagenci BY ttCrapsdp.qtsugeve DESC:
           RUN detalheTelaPAC (FIRST(ttCrapsdp.cdagenci),FIRST-OF(ttCrapsdp.cdagenci),LAST-OF(ttCrapsdp.cdagenci),LAST(ttCrapsdp.cdagenci)).
       END.
    END.

    {&out} '   </table>' SKIP.

    RETURN TRUE.

END FUNCTION. /* montaTelaQuantidade RETURNS LOGICAL () */


FUNCTION montaTelaTodos RETURNS LOGICAL ():

    {&out} '   <table border="0" cellspacing="0" cellpadding="0" width="100%">' SKIP.
    ASSIGN corEmUso = "#FFFFFF".

    IF cdAgenci <> 0 THEN DO:
       FOR EACH crapsdp WHERE crapsdp.idevento = 1
                          AND crapsdp.cdcooper = cdCooper
                          AND crapsdp.cdagenci = cdAgenci
                          AND crapsdp.dtmvtolt >= dataInicial
                          AND crapsdp.dtmvtolt <= dataFinal
                          AND crapsdp.flgsugca = NO 
                      NO-LOCK:
           CREATE ttCrapsdp.
           ASSIGN ttCrapsdp.cdcooper = crapsdp.cdcooper
                  ttCrapsdp.cdAgenci = crapsdp.cdagenci
                  ttCrapsdp.cdevento = crapsdp.cdevento
                  ttCrapsdp.qtsugeve = crapsdp.qtsugeve
                  ttCrapsdp.nrseqdig = crapsdp.nrseqdig
                  ttCrapsdp.dssugeve = crapsdp.dssugeve.
           FIND FIRST crapedp WHERE crapedp.idevento = idEvento
                                AND crapedp.cdcooper = 0
                                AND crapedp.dtanoage = 0 
                                AND crapedp.cdevento = crapsdp.cdevento
                              NO-LOCK NO-ERROR.
           IF AVAIL crapedp THEN
              ASSIGN ttCrapsdp.descEvento = crapedp.nmevento.
           ELSE 
              ASSIGN ttCrapsdp.descEvento = "".
       END.
    END.
    ELSE DO:
       FOR EACH crapsdp WHERE crapsdp.idevento = 1
                          AND crapsdp.cdcooper = cdCooper
                          AND crapsdp.dtmvtolt >= dataInicial
                          AND crapsdp.dtmvtolt <= dataFinal
                          AND crapsdp.flgsugca = NO 
                      NO-LOCK:
           CREATE ttCrapsdp.
           ASSIGN ttCrapsdp.cdcooper = crapsdp.cdcooper
                  ttCrapsdp.cdAgenci = 0
                  ttCrapsdp.cdevento = crapsdp.cdevento
                  ttCrapsdp.qtsugeve = crapsdp.qtsugeve
                  ttCrapsdp.nrseqdig = crapsdp.nrseqdig
                  ttCrapsdp.dssugeve = crapsdp.dssugeve.
           FIND FIRST crapedp WHERE crapedp.idevento = idEvento
                                AND crapedp.cdcooper = 0
                                AND crapedp.dtanoage = 0 
                                AND crapedp.cdevento = crapsdp.cdevento
                              NO-LOCK NO-ERROR.
           IF AVAIL crapedp THEN
              ASSIGN ttCrapsdp.descEvento = crapedp.nmevento.
           ELSE 
              ASSIGN ttCrapsdp.descEvento = "".
       END.
    END.
    IF NOT CAN-FIND(FIRST ttCrapsdp) THEN DO:
       {&out} '      <tr bgcolor="#FFFFFF">' SKIP
              '         <td colspan="5" align="center">Não há registro de sugestões para o filtro informado</td>' SKIP
              '      </tr>' SKIP.
    END.
    ELSE DO:
       FOR EACH ttCrapsdp BREAK BY ttCrapsdp.cdagenci BY ttCrapsdp.descEvento:
           RUN detalheTelaTodos (FIRST(ttCrapsdp.cdagenci),FIRST-OF(ttCrapsdp.cdagenci),LAST-OF(ttCrapsdp.cdagenci),LAST(ttCrapsdp.cdagenci)).
       END.
    END.

    {&out} '   </table>' SKIP.

    RETURN TRUE.

END FUNCTION. /* montaTelaTodos RETURNS LOGICAL () */


FUNCTION montaTela RETURNS LOGICAL ():

    DEFINE VARIABLE totalPrevisto        AS DECIMAL.
    DEFINE VARIABLE totalRealizado       AS DECIMAL.
    DEFINE VARIABLE totalDiferenca       AS DECIMAL.
    DEFINE VARIABLE totalPercentual      AS DECIMAL.
    
    DEFINE VARIABLE totalPrevistoGeral   AS DECIMAL.
    DEFINE VARIABLE totalRealizadoGeral  AS DECIMAL.
    DEFINE VARIABLE totalDiferencaGeral  AS DECIMAL.
    DEFINE VARIABLE totalPercentualGeral AS DECIMAL.
    DEFINE VARIABLE totalVerbaGeral      AS DECIMAL.
    

    {&out} '<html>' SKIP
           '<head>' SKIP
           '<title>Progrid - Orçamento</title>' SKIP.

    {&out} '<style>' SKIP
           '   body         ~{ background-color: #FFFFFF; }' SKIP
           '   td           ~{ font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: bold; }' SKIP
           '   .tdCab1      ~{ background-color: #B1B1B1; font-family: Arial, Helvetica, sans-serif; font-size: 14px; font-weight: bold; }' SKIP
           '   .tdCab2      ~{ background-color: #C6C6C6; font-family: Arial, Helvetica, sans-serif; font-size: 12px; font-weight: bold; }' SKIP
           '   .tdCab3      ~{ background-color: #DBDBDB; font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: bold; }' SKIP
           '   .tdLabel     ~{ font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: bold; }' SKIP
           '   .tdDados     ~{ font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: normal; border-bottom: #000000 0px solid }' SKIP
           '   .tdTitulo1   ~{ font-family: Verdana; font-size: 24px; font-weight: normal;}' SKIP
           '   .tab1        ~{ border-collapse:collapse; border-top: #000000 1px solid; border-bottom: #000000 1px solid; border-right: #000000 1px solid; border-left: #000000 1px solid; }' SKIP
           '</style>' SKIP.

    {&out} '</head>' SKIP
           '<body bgcolor="#FFFFFF" topmargin="0" marginwidth="0" marginheight="0">' SKIP
           '<div align="center">' SKIP.
    
    /* *** Botoes de fechar e imprimir *** */
    {&out} '<div align="right" id="botoes">' SKIP
           '   <table border="0" cellspacing="0" cellpadding="0" width="100%">' SKIP
           '      <tr>' SKIP
           '         <td align="right">' SKIP
           '            <img src="/cecred/images/botoes/btn_fechar.gif" alt="Fechar esta janela" style="cursor: hand" onClick="top.close()">' SKIP
           '            <img src="/cecred/images/botoes/btn_imprimir.gif" alt="Imprimir" style="cursor: hand" onClick="document.all.botoes.style.visibility = ~'hidden~'; print(); document.all.botoes.style.visibility = ~'visible~';">' SKIP
           '         </td>' SKIP
           '      </tr>' SKIP
           '   </table>' SKIP
           '</div>' SKIP.

    {&out} '   <table border="0" cellspacing="0" cellpadding="0" width="100%">' SKIP
           '      <tr>' SKIP
           '         <td class="tdprogra" colspan="5" align="right">wpgd0047a - ' TODAY '</td>' SKIP
           '   </table>' SKIP. 

    /* *** Logo *** */
    {&out} '   <table border="0" cellspacing="0" cellpadding="0" width="100%" class="tab1">' SKIP
           '      <tr>' SKIP
           '         <td align="center"><img src="' imagemDoProgrid '" border="0"></td>' SKIP
           '         <td class="tdTitulo1" colspan="4" align="center">' nomeDaCooperativa ' - Sugestões - ' dtAnoAge '</td>' SKIP
           '         <td align="center"><img src="' imagemDaCooperativa '" border="0"></td>' SKIP
           '      </tr>' SKIP
           '      <tr>' SKIP
           '         <td align="center" colspan="6"> &nbsp; </td>' SKIP
           '      </tr>' SKIP
           '      <tr>' SKIP
           '         <td align="center" colspan="6">Periodo de ' STRING(dataInicial,"99/99/9999") ' a ' STRING(dataFinal,"99/99/9999")  nomeDoRelatorio  '</td>' SKIP
           '      </tr>' SKIP
           '   </table>' SKIP. 

    {&out} '<br>' SKIP.

    CASE tipoDeRelatorio:
         WHEN 1 THEN
              montaTelaPAC().
         WHEN 2 THEN
              montaTelaEvento().
         WHEN 3 THEN
              montaTelaQuantidade().
         WHEN 4 THEN
              montaTelaTodos().
         OTHERWISE
             ASSIGN msgsDeErro = msgsDeErro + "-> Tipo de relatório ainda não implementado.<br>".
    END CASE.

    IF msgsDeErro <> ""
       THEN
           {&out} '   <table border="0" cellspacing="1" cellpadding="1">' SKIP
                  '      <tr>' SKIP
                  '         <td>' msgsDeErro '</td>' SKIP
                  '      </tr>' SKIP
                  '   </table>' SKIP.

    {&out} '</div>' SKIP
           '</body>' SKIP
           '</html>' SKIP.

    RETURN TRUE.

END FUNCTION. /* montaTela RETURNS LOGICAL () */

/*****************************************************************************/
/*                                                                           */
/*   Bloco de principal do programa                                          */
/*                                                                           */
/*****************************************************************************/
output-content-type("text/html").

ASSIGN cookieEmUso = GET-COOKIE("cookie-usuario-em-uso").

/* Usado FOR EACH para poder utilizar o CONTAINS e WORD-INDEX, alterado para MATCHES */
FOR EACH gnapses WHERE gnapses.idsessao MATCHES "*" + cookieEmUso + "*" NO-LOCK:
    LEAVE.
END.

RUN PermissaoDeAcesso("", OUTPUT IdentificacaoDaSessao, OUTPUT permiteExecutar).
  
IF permiteExecutar = "1" OR permiteExecutar = "2" THEN
   erroNaValidacaoDoLogin(permiteExecutar).
ELSE DO:
   ASSIGN idEvento                     = 1                                   /* INTEGER(GET-VALUE("parametro1"))  */
          cdCooper                     = INTEGER(GET-VALUE("parametro2"))
          cdAgenci                     = INTEGER(GET-VALUE("parametro3"))
          dtAnoAge                     = INTEGER(GET-VALUE("parametro4"))
          cdEvento                     = 0                                   /* INTEGER(GET-VALUE("parametro5")) */
          nrSeqEve                     = 0                                   /* INTEGER(GET-VALUE("parametro6")) */
          dataInicial                  = DATE(GET-VALUE("parametro7"))
          dataFinal                    = DATE(GET-VALUE("parametro8")) 
          consideraEventosForaDaAgenda = FALSE                               /* GET-VALUE("parametro6") */
          tipoDeRelatorio              = INTEGER(GET-VALUE("parametro10"))
      NO-ERROR.          
                  
   FIND crapcop WHERE crapcop.cdcooper = cdCooper NO-LOCK NO-ERROR.

   IF AVAILABLE crapcop THEN
      DO:
         ASSIGN imagemDoProgrid      = "/cecred/images/geral/logo_cecred.gif"
                nomedacooperativa    = TRIM(crapcop.nmrescop).
         
         IF INDEX(crapcop.nmrescop, " ") <> 0  THEN
            DO: 
               aux_nmrescop = LC(TRIM(crapcop.nmrescop)).
               SUBSTRING( aux_nmrescop, (INDEX(aux_nmrescop, " ")),1) = "_".
               imagemDaCooperativa =  "/cecred/images/admin/logo_" +  aux_nmrescop.
            END.
         ELSE
            imagemDaCooperativa  = "/cecred/images/admin/logo_" + TRIM(LC(crapcop.nmrescop)) + ".gif" .
            
      END.

   IF tipoDeRelatorio = 1 THEN
      ASSIGN nomeDoRelatorio = " - Analisadas por Pa".
   ELSE IF tipoDeRelatorio = 2 THEN
      ASSIGN nomeDoRelatorio = " - Analisadas por Evento". 
   ELSE IF tipoDeRelatorio = 3 THEN
      ASSIGN nomeDoRelatorio = " - Analisadas por Quantidade". 
   ELSE
      ASSIGN nomeDoRelatorio = " - Todas Cadastradas". 
  
   montaTela().

END.

/*****************************************************************************/
/*                                                                           */
/*   Bloco de procdures                                                      */
/*                                                                           */
/*****************************************************************************/

PROCEDURE PermissaoDeAcesso :

    {includes/wpgd0009.i}

END PROCEDURE.

PROCEDURE agrupaAgencias:
    DEF INPUT PARAM descEntrada AS CHAR NO-UNDO.
    DEF OUTPUT PARAM descSaida  AS CHAR NO-UNDO.

    /* Agrupa agencias */
    ASSIGN descSaida = descEntrada. 
    IF CAN-FIND(FIRST crapadp WHERE crapadp.idevento = 1                  AND
                                    crapadp.cdcooper = ttCrapsdp.cdCooper AND
                                    crapadp.dtanoage = dtAnoAge           AND 
                                    crapadp.cdagenci = ttCrapsdp.cdagenci)  THEN DO:
       FOR EACH crapadp WHERE crapadp.idevento = 1                  AND
                crapadp.cdcooper = ttCrapsdp.cdCooper AND
                crapadp.dtanoage = dtAnoAge AND 
                crapadp.cdagenci = ttCrapsdp.cdagenci  NO-LOCK:
           IF CAN-FIND(FIRST crapagp WHERE crapagp.idevento  = crapadp.idevento AND
                                           crapagp.cdcooper  = crapadp.cdcooper  AND
                                           crapagp.dtanoage  = crapadp.dtanoage  AND
                                           crapagp.cdagenci <> crapagp.cdageagr  AND
                                           crapagp.cdageagr  = crapadp.cdagenci) THEN DO:
              FOR EACH crapagp WHERE crapagp.idevento  = crapadp.idevento  AND
                                     crapagp.cdcooper  = crapadp.cdcooper  AND
                                     crapagp.dtanoage  = crapadp.dtanoage  AND
                                     crapagp.cdagenci <> crapagp.cdageagr  AND
                                     crapagp.cdageagr  = crapadp.cdagenci  NO-LOCK:
                  FIND crapage WHERE crapage.cdcooper = crapagp.cdcooper   AND
                                     crapage.cdagenci = crapagp.cdagenci   NO-LOCK NO-ERROR.
                  ASSIGN descSaida = descSaida + " ~/ " + crapage.nmresage.
              END.
              LEAVE.
           END.
       END.
    END.
END.

PROCEDURE detalheTelaPAC:
    DEF INPUT PARAM lfirst AS LOG NO-UNDO.
    DEF INPUT PARAM lfirstof AS LOG NO-UNDO.
    DEF INPUT PARAM llastof AS LOG NO-UNDO.
    DEF INPUT PARAM llast AS LOG NO-UNDO. 

    DEF VAR descEvento AS CHAR NO-UNDO.
    DEF VAR descAgencia AS CHAR NO-UNDO.

    IF lFIRST THEN DO:
        {&out} '      <tr>' SKIP
               '         <td class="tdCab1" colspan="5">' titCabec '</td>' SKIP
               '      </tr>' SKIP.
    END.

    IF lFIRSTOF THEN DO:
        /* *** Nome do PA *** */
        IF ttCrapsdp.cdAgenci = 0 THEN DO:
           ASSIGN descAgencia = "Pa: Todos os PA's".
        END.
        ELSE DO:
            FIND Crapage WHERE Crapage.CdCooper = ttCrapsdp.cdCooper AND 
                               Crapage.CdAgenci = ttCrapsdp.cdAgenci NO-LOCK NO-ERROR.
            RUN agrupaAgencias((IF AVAILABLE Crapage THEN crapage.NmResAge ELSE ("Agencia " + STRING(ttCrapsdp.cdagenci,"999"))),
                               OUTPUT descAgencia).
            ASSIGN descAgencia = "Pa: " + string(ttCrapsdp.cdagenci) + " - " + descAgencia.
        END.

        {&out} '      <tr>'                                                       SKIP
               '         <td class="tdCab2" colspan="5">' descAgencia '</td>' SKIP
               '      </tr>' SKIP.
        {&out} '      <tr class="tdCab3">'                                        SKIP
               '         <td>Qtde</td>'                                           SKIP
               '         <td align="left" colspan="4">Descrição do Evento</td>'  SKIP
               '      </tr>'                                                      SKIP.
    END.

    FIND FIRST crapedp WHERE crapedp.idevento = idEvento
                         AND crapedp.cdcooper = 0
                         AND crapedp.dtanoage = 0 
                         AND crapedp.cdevento = ttCrapsdp.cdevento
                       NO-LOCK NO-ERROR.

    IF AVAIL crapedp THEN
       ASSIGN descEvento = crapedp.nmevento.
    ELSE 
       ASSIGN descEvento = '** Evento código "' + (IF ttCrapsdp.cdEvento = ? THEN '? (indefinido)' ELSE string(ttcrapsdp.cdEvento)) + '" sem descrição **'.

    {&out} '      <tr bgcolor="' corEmUso '">' SKIP
           '         <td align="right">' ttCrapsdp.qtsugeve FORMAT ">,>>9" '&nbsp;&nbsp;</td>' SKIP
           '         <td align="left" colspan="4">' descEvento '&nbsp;&nbsp;</td>' SKIP
           '      </tr>' SKIP.

    ASSIGN totalPac = totalPac + ttCrapsdp.qtsugeve
           totalGeral = totalGeral + ttCrapsdp.qtsugeve.

    IF corEmUso = "#FFFFFF" THEN
        ASSIGN corEmUso = "#F5F5F5".
    ELSE
        ASSIGN corEmUso = "#FFFFFF".

    IF lLASTOF THEN DO:
       {&out} '      <tr bgcolor="' corEmUso '">' SKIP
              '         <td colspan="5" bgcolor="' corEmUso '">&nbsp;&nbsp;&nbsp;</td>' SKIP
              '      </tr>' SKIP.

       IF corEmUso = "#FFFFFF" THEN
           ASSIGN corEmUso = "#F5F5F5".
       ELSE
           ASSIGN corEmUso = "#FFFFFF".

       /* *** Nome do PA *** */
       IF ttCrapsdp.cdAgenci = 0 THEN DO:
          ASSIGN descAgencia = "Total para o Pa: Todos os PA's".
       END.
       ELSE DO:
          FIND Crapage WHERE Crapage.CdCooper = ttCrapsdp.cdCooper AND 
                             Crapage.CdAgenci = ttCrapsdp.cdAgenci NO-LOCK NO-ERROR.
          RUN agrupaAgencias((IF AVAILABLE Crapage THEN crapage.NmResAge ELSE ("Agencia " + STRING(ttCrapsdp.cdagenci,"999"))),
                             OUTPUT descAgencia).
          ASSIGN descAgencia = "Total para o Pa: " + string(ttCrapsdp.cdagenci) + " - " + descAgencia.
       END.

       {&out} '      <tr class="tdCab3">' SKIP
              '         <td colspan="5">' descAgencia ' (Quantidade = ' totalPac FORMAT ">>>,>>9" ')</td>' SKIP
              '      </tr>' SKIP
              '      <tr><td colspan="5" align="center"> &nbsp; </td></tr>' SKIP
              '      <tr><td colspan="5" align="center"><hr></td></tr>' SKIP
              '      <tr><td colspan="5" align="center"> &nbsp; </td></tr>' SKIP.
       ASSIGN totalPac = 0.
    END.

    IF lLAST THEN DO:
       {&out} '      <tr class="tdCab3">' SKIP
              '         <td colspan="5">Total GERAL: ' totalGeral FORMAT ">>>,>>9" '</td>' SKIP
              '      </tr>' SKIP
              '      <tr><td colspan="5" align="center"> &nbsp; </td></tr>' SKIP
              '      <tr><td colspan="5" align="center"><hr></td></tr>' SKIP
              '      <tr><td colspan="5" align="center"> &nbsp; </td></tr>' SKIP.
    END.

END.

PROCEDURE detalheTelaTodos:
    DEF INPUT PARAM lfirst AS LOG NO-UNDO.
    DEF INPUT PARAM lfirstof AS LOG NO-UNDO.
    DEF INPUT PARAM llastof AS LOG NO-UNDO.
    DEF INPUT PARAM llast AS LOG NO-UNDO. 

    DEF VAR descEvento AS CHAR NO-UNDO.
    DEF VAR descAgencia AS CHAR NO-UNDO.

    IF lFIRST THEN DO:
        {&out} '      <tr>' SKIP
               '         <td class="tdCab1" colspan="5">Todas as Sugestões</td>' SKIP
               '      </tr>' SKIP.
    END.

    IF lFIRSTOF THEN DO:
        /* *** Nome do PA *** */
        IF ttCrapsdp.cdAgenci = 0 THEN DO:
           ASSIGN descAgencia = "Pa: Todos os PA's".
        END.
        ELSE DO:
           FIND Crapage WHERE Crapage.CdCooper = ttCrapsdp.cdCooper AND 
                              Crapage.CdAgenci = ttCrapsdp.cdAgenci NO-LOCK NO-ERROR.
           RUN agrupaAgencias((IF AVAILABLE Crapage THEN crapage.NmResAge ELSE ("Agencia " + STRING(ttCrapsdp.cdagenci,"999"))),
                              OUTPUT descAgencia).
           ASSIGN descAgencia = "Pa: " + string(ttCrapsdp.cdagenci) + " - " + descAgencia.
        END.

        {&out} '      <tr>'                                                       SKIP
               '         <td class="tdCab2" colspan="5">' descAgencia '</td>' SKIP
               '      </tr>' SKIP.
        {&out} '      <tr class="tdCab3">'                                        SKIP
               '         <td align="left">Evento Vinculado</td>'  SKIP
               '         <td>Qtde</td>'                                           SKIP
               '         <td align="left" colspan="2">Sugestão</td>'  SKIP
               '         <td>Cod</td>'  SKIP
               '      </tr>'                                                      SKIP.
        ASSIGN totalPac = 0.
    END.

    FIND FIRST crapedp WHERE crapedp.idevento = idEvento
                         AND crapedp.cdcooper = 0
                         AND crapedp.dtanoage = 0 
                         AND crapedp.cdevento = ttCrapsdp.cdevento
                       NO-LOCK NO-ERROR.

    IF AVAIL crapedp THEN
       ASSIGN descEvento = crapedp.nmevento.
    ELSE 
       ASSIGN descEvento = "".

    {&out} '      <tr bgcolor="' corEmUso '">' SKIP
           '         <td align="left">' descEvento '&nbsp;&nbsp;</td>' SKIP
           '         <td align="right">' ttCrapsdp.qtsugeve FORMAT ">,>>9" '&nbsp;&nbsp;</td>' SKIP
           '         <td align="left" colspan="2">' ttCrapsdp.dssugeve '&nbsp;&nbsp;</td>' SKIP
           '         <td align="right">' ttCrapsdp.nrseqdig FORMAT ">>,>>9" '&nbsp;&nbsp;</td>' SKIP
           '      </tr>' SKIP.

    ASSIGN totalPac = totalPac + ttCrapsdp.qtsugeve
           totalGeral = totalGeral + ttCrapsdp.qtsugeve.

    IF corEmUso = "#FFFFFF" THEN
        ASSIGN corEmUso = "#F5F5F5".
    ELSE
        ASSIGN corEmUso = "#FFFFFF".

    IF lLASTOF THEN DO:
        {&out} '      <tr bgcolor="' corEmUso '">' SKIP
               '         <td colspan="5" bgcolor="' corEmUso '">&nbsp;&nbsp;&nbsp;</td>' SKIP
               '      </tr>' SKIP.

        IF corEmUso = "#FFFFFF" THEN
            ASSIGN corEmUso = "#F5F5F5".
        ELSE
            ASSIGN corEmUso = "#FFFFFF".

       /* *** Nome do PA *** */
       IF ttCrapsdp.cdAgenci = 0 THEN DO:
          ASSIGN descAgencia = "Total para o Pa: Todos os PA's".
       END.
       ELSE DO:
           FIND Crapage WHERE Crapage.CdCooper = ttCrapsdp.cdCooper AND 
                              Crapage.CdAgenci = ttCrapsdp.cdAgenci NO-LOCK NO-ERROR.
           RUN agrupaAgencias((IF AVAILABLE Crapage THEN crapage.NmResAge ELSE ("Agencia " + STRING(ttCrapsdp.cdagenci,"999"))),
                              OUTPUT descAgencia).
           ASSIGN descAgencia = "Total para o Pa: " + string(ttCrapsdp.cdagenci) + " - " + descAgencia.
       END.
       {&out} '      <tr class="tdCab3">' SKIP
              '         <td colspan="5">' descAgencia ' (Quantidade = ' totalPac FORMAT ">>>,>>9" ')</td>' SKIP
              '      </tr>' SKIP
              '      <tr><td colspan="5" align="center"> &nbsp; </td></tr>' SKIP
              '      <tr><td colspan="5" align="center"><hr></td></tr>' SKIP
              '      <tr><td colspan="5" align="center"> &nbsp; </td></tr>' SKIP.
    END.

    IF lLAST THEN DO:
       {&out} '      <tr class="tdCab3">' SKIP
              '         <td colspan="5">Total GERAL: ' totalGeral FORMAT ">>>,>>9" '</td>' SKIP
              '      </tr>' SKIP
              '      <tr><td colspan="5" align="center"> &nbsp; </td></tr>' SKIP
              '      <tr><td colspan="5" align="center"><hr></td></tr>' SKIP
              '      <tr><td colspan="5" align="center"> &nbsp; </td></tr>' SKIP.
    END.

END.


