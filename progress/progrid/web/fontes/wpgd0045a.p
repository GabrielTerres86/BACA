/*
 * Programa wpgd0045a.p - Pré-Inscritos (chamado a partir dos dados de wpgd0042)
 *
 * Alteracoes: 03/11/2008 - inclusao widget-pool (martin)

               10/12/2008 - Melhoria de performance para a tabela gnapses (Evandro).
               
               30/04/2009 - Utilizar cdcooper = 0 nas consultas (David).
                           
               16/07/2009 - Corrigido para listar Eventos no ano da Agenda
                            informado (Diego).
                           
               05/06/2012 - Adaptação dos fontes para projeto Oracle. Alterado
                            busca na gnapses de CONTAINS para MATCHES
                            (Guilherme Maba).
                            
               28/11/2012 - Substituir tabela "gncoper" por "crapcop"
                            (David Kruger).
                            
               04/04/2013 - Alteração para receber logo na alto vale,
                            recebendo nome de viacrediav e buscando com
                            o respectivo nome (David Kruger).             

               04/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
*/
/*****************************************************************************/

create widget-pool.

/*   Bloco de variaveis                                                      */
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
DEFINE VARIABLE tipoDeRelatorio              AS INTEGER.
DEFINE VARIABLE nomeDoRelatorio              AS CHARACTER.
DEFINE VARIABLE nmresage                     AS CHARACTER.
DEFINE VARIABLE dtinieve                     AS CHARACTER  FORMAT "x(10)".

DEFINE VARIABLE imagemDoProgrid              AS CHARACTER.
DEFINE VARIABLE imagemDaCooperativa          AS CHARACTER.
DEFINE VARIABLE nomeDaCooperativa            AS CHARACTER.
DEFINE VARIABLE aux_nmrescop                 AS CHARACTER.

DEFINE BUFFER crabtab FOR craptab.

/* Para o Relatorio_2 - por pa */
DEFINE TEMP-TABLE tt_pac                        NO-UNDO
       FIELD cdagenci LIKE crapage.cdagenci
       FIELD qtcancel AS INT
       FIELD qttransf AS INT
       INDEX tt_pac1 cdagenci.

                           
/*****************************************************************************/
/*   Bloco de includes                                                       */
/*****************************************************************************/

{src/web/method/wrap-cgi.i}

/*****************************************************************************/
/*   Bloco de funçoes                                                        */
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

FUNCTION Relatorio_1 RETURNS LOGICAL ():

    DEFINE VARIABLE aux_nmresage AS CHARACTER                                           NO-UNDO.
    DEFINE VARIABLE aux_nmevento AS CHARACTER                                           NO-UNDO.
    DEFINE VARIABLE aux_dsstatus AS CHARACTER                                           NO-UNDO.
    DEFINE VARIABLE aux_lsmvtolt AS CHARACTER                                           NO-UNDO.
    DEFINE VARIABLE vetormes     AS CHAR EXTENT 12
           INITIAL ["Janeiro","Fevereiro","Março","Abril","Maio","Junho",
                    "Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"]        NO-UNDO.


    {&OUT} '<table border="0" cellspacing="0" cellpadding="1" width="100%">' SKIP.

    FOR EACH crapadp  WHERE crapadp.idevento  = idevento                                      AND
                            crapadp.cdcooper  = cdcooper                                      AND
                                                        crapadp.dtanoage  = dtanoage                                      AND
                           (crapadp.cdevento  = cdevento OR cdevento = 0) /*TODOS EVENTOS*/   AND
                           (crapadp.cdagenci  = cdagenci OR cdagenci = 0) /*TODOS PA'S*/      AND
                           (crapadp.nrseqdig  = nrseqeve OR nrseqeve = 0) /*TODOS EVENTOS*/   NO-LOCK,
        
        FIRST crapedp WHERE crapedp.idevento = crapadp.idevento                              AND
                            crapedp.cdcooper = crapadp.cdcooper                              AND
                            crapedp.dtanoage = crapadp.dtanoage                              AND
                            crapedp.cdevento = crapadp.cdevento                              NO-LOCK
                            BREAK BY crapadp.cdagenci
                                    BY crapedp.nmevento:

        IF   FIRST-OF(crapadp.cdagenci)   THEN
             DO:
                 /* Nome do PA */
                 FIND crapage WHERE crapage.cdcooper = crapadp.cdcooper   AND
                                    crapage.cdagenci = crapadp.cdagenci   NO-LOCK NO-ERROR.
     
                 aux_nmresage = STRING(crapage.cdagenci,"99") + " - " + crapage.nmresage.
     
                 /* Verifica se tem PA'S agrupados */
                 FOR EACH crapagp WHERE crapagp.idevento  = idevento           AND
                                        crapagp.cdcooper  = cdcooper           AND
                                        crapagp.dtanoage  = dtanoage           AND
                                        crapagp.cdageagr  = crapadp.cdagenci   AND
                                        crapagp.cdageagr <> crapagp.cdagenci   NO-LOCK:
     
                     FIND crapage WHERE crapage.cdcooper = crapagp.cdcooper   AND
                                        crapage.cdagenci = crapagp.cdagenci   NO-LOCK NO-ERROR.
     
                     aux_nmresage = aux_nmresage + " / " + crapage.nmresage.
                 END.

                 {&OUT} '  <tr>' SKIP
                        '    <td class="tdCab1" colspan="3">PA: ' aux_nmresage '</td>' SKIP
                        '  </tr>' SKIP.
             END.


        /* Nome do evento com as informações adicionais */
        aux_nmevento = crapedp.nmevento.

        IF  crapadp.dtinieve <> ?  THEN
            aux_nmevento = aux_nmevento + " - " + STRING(crapadp.dtinieve,"99/99/9999").
        ELSE
        IF  crapadp.nrmeseve <> 0  AND crapadp.nrmeseve <> ? THEN
            aux_nmevento = aux_nmevento + " - " + vetormes[crapadp.nrmeseve].

        IF  crapadp.dshroeve <> "" THEN
            aux_nmevento = aux_nmevento + " - " + crapadp.dshroeve.

                /* Status do evento */
                FIND FIRST craptab WHERE craptab.cdcooper = 0               AND
                                         craptab.nmsistem = "CRED"          AND
                                                                    craptab.tptabela = "CONFIG"        AND
                                                                    craptab.cdempres = 0               AND
                                                                    craptab.cdacesso = "PGSTEVENTO"    AND
                                                                    craptab.tpregist = 0               NO-LOCK NO-ERROR.
                                                                    
                aux_dsstatus = ENTRY((crapadp.idstaeve * 2) - 1,craptab.dstextab).      

        {&OUT} '  <tr>' SKIP
               '    <td class="tdCab2" colspan="3">Evento: ' aux_nmevento '</td>' SKIP
               '  </tr>' SKIP
               '  <tr>' SKIP
               '    <td class="tdCab3">Previsto: ' vetormes[crapadp.nrmesage] '</td>' SKIP
               '    <td class="tdCab3" colspan="2">Situação Atual: ' aux_dsstatus '</td>' SKIP
               '  </tr>' SKIP.

        /* Listagem dos historicos */
        {&OUT} '  <tr>' SKIP
               '    <td class="tdLabel">Data</td>' SKIP
               '    <td class="tdLabel">Situação</td>' SKIP
               '    <td class="tdLabel">Motivo</td>' SKIP
               '  </tr>' SKIP.

        /* no campo do PA fica guardado o sequencial do evento */
        FOR EACH craphep WHERE craphep.cdcooper = 0                AND
                               craphep.cdagenci = crapadp.nrseqdig NO-LOCK:

            aux_lsmvtolt = STRING(DAY(craphep.dtmvtolt),"99") + '/' +
                           vetormes[MONTH(craphep.dtmvtolt)]  + '/' + 
                           STRING(YEAR(craphep.dtmvtolt),"9999").

            {&OUT} '  <tr>' SKIP
                   '    <td class="tdDados" width="15%">' aux_lsmvtolt '</td>' SKIP
                   '    <td class="tdDados" width="15%">' TRIM(CAPS(ENTRY(2,craphep.dshiseve," "))) '</td>' SKIP
                   '    <td class="tdDados">' craphep.dshiseve '</td>' SKIP
                   '  </tr>' SKIP.
        END.

        {&OUT} '  <tr>' SKIP
               '    <td colspan="3"><br><hr></td>' SKIP
               '  </tr>' SKIP.
    END.

    {&OUT} '</table>' SKIP
           '<br>' SKIP
           '<br>' SKIP.
    
    RETURN TRUE.
END.


FUNCTION Relatorio_2 RETURNS LOGICAL ():

    DEFINE VARIABLE aux_qtcancel AS INTEGER                                             NO-UNDO.
    DEFINE VARIABLE aux_qttransf AS INTEGER                                             NO-UNDO.
    
    DEFINE VARIABLE tot_qtcancel AS INTEGER                                             NO-UNDO.
    DEFINE VARIABLE tot_qttransf AS INTEGER                                             NO-UNDO.

    DEFINE VARIABLE aux_nmresage AS CHARACTER                                           NO-UNDO.
    DEFINE VARIABLE aux_nmevento AS CHARACTER                                           NO-UNDO.
    DEFINE VARIABLE vetormes     AS CHAR EXTENT 12
           INITIAL ["Janeiro","Fevereiro","Março","Abril","Maio","Junho",
                    "Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"]        NO-UNDO.


    {&OUT} '<table border="0" cellspacing="0" cellpadding="1" width="100%">' SKIP
           '  <tr>' SKIP
           '    <td class="tdCab1" colspan="3">Resumo e Totais</td>' SKIP
           '  </tr>' SKIP
           '  <tr>' SKIP
           '    <td class="tdCab2" colspan="3">Resumo por Evento</td>' SKIP
           '  </tr>' SKIP
           '  <tr>' SKIP
           '    <td class="tdCab3">Evento</td>' SKIP
           '    <td class="tdCab3" align="center">Cancelamentos</td>' SKIP
           '    <td class="tdCab3" align="center">Transferências</td>' SKIP
           '  </tr>' SKIP.


    /* Cria um registro pra cada PA agrupador */
    EMPTY TEMP-TABLE tt_pac.

    FOR EACH crapagp WHERE crapagp.idevento = idevento                 AND
                           crapagp.cdcooper = cdcooper                 AND
                           crapagp.dtanoage = dtanoage                 AND
                          (crapagp.cdagenci = cdagenci   OR
                           cdagenci         = 0) /* TODOS OS PA'S */   AND
                           crapagp.cdageagr = crapagp.cdagenci         NO-LOCK:
        
        CREATE tt_pac.
        ASSIGN tt_pac.cdagenci = crapagp.cdagenci.
    END.

    FOR EACH crapadp  WHERE crapadp.idevento  = idevento                                      AND
                            crapadp.cdcooper  = cdcooper                                      AND
                           (crapadp.cdevento  = cdevento OR cdevento = 0) /*TODOS EVENTOS*/   AND
                           (crapadp.cdagenci  = cdagenci OR cdagenci = 0) /*TODOS PA'S*/      AND
                           (crapadp.nrseqdig  = nrseqeve OR nrseqeve = 0) /*TODOS EVENTOS*/   NO-LOCK,
        
        FIRST crapedp WHERE crapedp.idevento = crapadp.idevento                              AND
                            crapedp.cdcooper = crapadp.cdcooper                              AND
                            crapedp.dtanoage = crapadp.dtanoage                              AND
                            crapedp.cdevento = crapadp.cdevento                              NO-LOCK
                            BREAK BY crapedp.nmevento:

        IF   FIRST-OF(crapedp.nmevento)   THEN
             ASSIGN aux_qtcancel = 0
                    aux_qttransf = 0.

        /* no campo do PA fica guardado o sequencial do evento */
        FOR EACH craphep WHERE craphep.cdcooper = 0                AND
                               craphep.cdagenci = crapadp.nrseqdig NO-LOCK:

            /* cria a temp-table para fazer a ordenacao por PA */
            FIND tt_pac WHERE tt_pac.cdagenci = crapadp.cdagenci EXCLUSIVE-LOCK NO-ERROR.

            IF   ENTRY(2,craphep.dshiseve," ") = "cancelado"   THEN
                 ASSIGN aux_qtcancel    = aux_qtcancel + 1
                        tot_qtcancel    = tot_qtcancel + 1
                        tt_pac.qtcancel = tt_pac.qtcancel + 1.
            ELSE
            IF   ENTRY(2,craphep.dshiseve," ") = "transferido"   THEN
                 ASSIGN aux_qttransf    = aux_qttransf + 1
                        tot_qttransf    = tot_qttransf + 1
                        tt_pac.qttransf = tt_pac.qttransf + 1.
        END.


        IF   LAST-OF(crapedp.nmevento)   THEN
             DO:
                 aux_nmevento = crapedp.nmevento.

                 IF   nrseqeve <> 0   THEN
                      DO:
                         /* Adiciona informacoes ao nome do evento */
                         IF  crapadp.dtinieve <> ?  THEN
                             aux_nmevento = aux_nmevento + " - " + STRING(crapadp.dtinieve,"99/99/9999").
                         ELSE
                         IF  crapadp.nrmeseve <> 0  AND crapadp.nrmeseve <> ? THEN
                             aux_nmevento = aux_nmevento + " - " + vetormes[crapadp.nrmeseve].
                         
                         IF  crapadp.dshroeve <> "" THEN
                             aux_nmevento = aux_nmevento + " - " + crapadp.dshroeve.
                      END.

                 {&OUT} '  <tr>' SKIP
                        '    <td class="tdDados">' aux_nmevento '</td>' SKIP
                        '    <td class="tdDados" align="center">' aux_qtcancel '</td>' SKIP
                        '    <td class="tdDados" align="center">' aux_qttransf '</td>' SKIP
                        '  </tr>' SKIP.
             END.
    END.

    /* Total por evento */
    {&OUT} '  <tr>' SKIP
           '    <td colspan="3"><hr></td>' SKIP
           '  </tr>' SKIP
           '  <tr>' SKIP
           '    <td class="tdDados">TOTAIS</td>' SKIP
           '    <td class="tdDados" align="center">' tot_qtcancel '</td>' SKIP
           '    <td class="tdDados" align="center">' tot_qttransf '</td>' SKIP
           '  </tr>' SKIP
           '</table>' SKIP
           '<br>' SKIP
           '<br>' SKIP
           '<table border="0" cellspacing="0" cellpadding="1" width="100%">' SKIP
           '  <tr>' SKIP
           '    <td class="tdCab2" colspan="3">Resumo por PA</td>' SKIP
           '  </tr>' SKIP
           '  <tr>' SKIP
           '    <td class="tdCab3">PA</td>' SKIP
           '    <td class="tdCab3" align="center">Cancelamentos</td>' SKIP
           '    <td class="tdCab3" align="center">Transferências</td>' SKIP
           '  </tr>' SKIP.

    FOR EACH tt_pac NO-LOCK BREAK BY tt_pac.cdagenci:

        /* Nome do PA */
        FIND crapage WHERE crapage.cdcooper = cdcooper          AND
                           crapage.cdagenci = tt_pac.cdagenci   NO-LOCK NO-ERROR.

        aux_nmresage = STRING(crapage.cdagenci,"99") + " - " + crapage.nmresage.

        /* Verifica se tem PA'S agrupados */
        FOR EACH crapagp WHERE crapagp.idevento  = idevento           AND
                               crapagp.cdcooper  = cdcooper           AND
                               crapagp.dtanoage  = dtanoage           AND
                               crapagp.cdageagr  = tt_pac.cdagenci    AND
                               crapagp.cdageagr <> crapagp.cdagenci   NO-LOCK:

            FIND crapage WHERE crapage.cdcooper = crapagp.cdcooper   AND
                               crapage.cdagenci = crapagp.cdagenci   NO-LOCK NO-ERROR.
            
            aux_nmresage = aux_nmresage + " / " + crapage.nmresage.
        END.

        {&OUT} '  <tr>' SKIP
               '    <td class="tdDados">' aux_nmresage '</td>' SKIP
               '    <td class="tdDados" align="center">' tt_pac.qtcancel '</td>' SKIP
               '    <td class="tdDados" align="center">' tt_pac.qttransf '</td>' SKIP
               '  </tr>' SKIP.
    END.

    /* Total por pa */
    {&OUT} '  <tr>' SKIP
           '    <td colspan="3"><hr></td>' SKIP
           '  </tr>' SKIP
           '  <tr>' SKIP
           '    <td class="tdDados">TOTAIS</td>' SKIP
           '    <td class="tdDados" align="center">' tot_qtcancel '</td>' SKIP
           '    <td class="tdDados" align="center">' tot_qttransf '</td>' SKIP
           '  </tr>' SKIP
           '</table>' SKIP
           '<br>' SKIP
           '<br>' SKIP.

    RETURN TRUE.
END.

FUNCTION montaTela RETURNS LOGICAL ():

    {&out} '<html>' SKIP
           '<head>' SKIP
           '<title>Progrid - Histórico de Eventos</title>' SKIP.

    {&out} '<style>' SKIP
           '   body         ~{ background-color: #FFFFFF; }' SKIP
           '   td           ~{ font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: bold; }' SKIP
           '   .tdCab1      ~{ background-color: #B1B1B1; font-family: Arial, Helvetica, sans-serif; font-size: 14px; font-weight: bold; }' SKIP
           '   .tdCab2      ~{ background-color: #C6C6C6; font-family: Arial, Helvetica, sans-serif; font-size: 12px; font-weight: bold; }' SKIP
           '   .tdCab3      ~{ background-color: #DBDBDB; font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: bold; }' SKIP
           '   .tdLabel     ~{ font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: bold; }' SKIP
           '   .tdDados     ~{ font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: normal; border-bottom: #000000 0px solid }' SKIP
           '   .tdTitulo1   ~{ font-family: Verdana; font-size: 24px; font-weight: normal;}' SKIP
           '   .tdTitulo2   ~{ font-family: Verdana; font-size: 16px; font-weight: bold;}' SKIP
           '   .tab1        ~{ border-collapse:collapse; border-top: #000000 1px solid; border-bottom: #000000 1px solid; border-right: #000000 1px solid; border-left: #000000 1px solid; }' SKIP
           '   .tab2        ~{ border-collapse:collapse; font-weight: normal; font-size: 10px}' SKIP           
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
           '            <img src="/cecred/images/botoes/btn_imprimir.gif" alt="Imprimir" style="cursor: hand" onClick="alert(~'ATENÇÃO! Certifique-se que a página esteja como papel A4.~'); document.all.botoes.style.visibility = ~'hidden~'; print(); document.all.botoes.style.visibility = ~'visible~';">' SKIP
           '         </td>' SKIP
           '      </tr>' SKIP
           '   </table>' SKIP
           '</div>' SKIP.

    {&out} '   <table border="0" cellspacing="0" cellpadding="0" width="100%">' SKIP
           '      <tr>' SKIP
           '         <td class="tdprogra" colspan="5" align="right">wpgd0045a - ' TODAY '</td>' SKIP
           '   </table>' SKIP. 

    /* *** Logo *** */
    {&out} '   <table border="0" cellspacing="0" cellpadding="0" width="100%" class="tab1">' SKIP
           '      <tr>' SKIP
           '         <td align="center"><img src="' imagemDoProgrid '" border="0"></td>' SKIP
           '         <td class="tdTitulo1" colspan="4" align="center">' nomeDaCooperativa ' - Histórico de Eventos - ' dtAnoAge '</td>' SKIP
           '         <td align="center"><img src="' imagemDaCooperativa '" border="0"></td>' SKIP
           '      </tr>' SKIP
           '      <tr>' SKIP
           '        <td>' SKIP
           '          &nbsp;' SKIP
           '        </td>' SKIP
           '      </tr>' SKIP
           '      <tr>' SKIP
           '         <td align="center" class="tdTitulo2" colspan="6">RELATORIO: '.
        
    IF tipoDeRelatorio = 1 THEN
       {&OUT} "Detalhado".
    ELSE 
    IF tipoDeRelatorio = 2 THEN
       {&OUT} "Consolidado".
    ELSE
    IF tipoDeRelatorio = 3 THEN
       {&OUT} "Completo".
        
    {&OUT} '&nbsp;&nbsp;</td>' SKIP
           '      </tr>' SKIP
           '   </table>' SKIP. 

    {&out} '<br>' SKIP.

    IF   tipoDeRelatorio = 1   THEN
         Relatorio_1().
    ELSE
    IF   tipoDeRelatorio = 2   THEN
         Relatorio_2().
    ELSE
    IF   tipoDeRelatorio = 3   THEN
         DO:
             Relatorio_1().
             Relatorio_2().
         END.
    
    IF   msgsDeErro <> ""   THEN
         {&out} '   <table border="0" cellspacing="1" cellpadding="1">' SKIP
                '      <tr>' SKIP
                '         <td>' msgsDeErro '</td>' SKIP
                '      </tr>' SKIP
                '   </table>' SKIP.

    {&out} '</div>'  SKIP
           '</body>' SKIP
           '</html>' SKIP.

    RETURN TRUE.

END FUNCTION. /* montaTela RETURNS LOGICAL () */

/*****************************************************************************/
/*   Bloco de principal do programa                                          */
/*****************************************************************************/

output-content-type("text/html").

ASSIGN cookieEmUso = GET-COOKIE("cookie-usuario-em-uso").

/* Usado FOR EACH para poder utilizar o CONTAINS e WORD-INDEX, alterado para MATCHES */
FOR EACH gnapses WHERE gnapses.idsessao MATCHES "*" + cookieEmUso + "*" NO-LOCK:
    LEAVE.
END.

RUN PermissaoDeAcesso("", OUTPUT IdentificacaoDaSessao, OUTPUT permiteExecutar).

IF permiteExecutar = "1" OR permiteExecutar = "2"
   THEN
       erroNaValidacaoDoLogin(permiteExecutar).
   ELSE
       DO:
          ASSIGN idEvento                     = INTEGER(GET-VALUE("parametro1"))
                 cdCooper                     = INTEGER(GET-VALUE("parametro2"))
                 cdAgenci                     = INTEGER(GET-VALUE("parametro3"))
                 dtAnoAge                     = INTEGER(GET-VALUE("parametro4"))
                 nrseqeve                     = INTEGER(GET-VALUE("parametro5"))
                 tipoDeRelatorio              = INTEGER(GET-VALUE("parametro6"))
                 cdevento                     = INTEGER(GET-VALUE("parametro7")) NO-ERROR.          

          FIND crapcop WHERE crapcop.cdcooper = cdCooper NO-LOCK NO-ERROR.

          IF AVAILABLE crapcop THEN
             DO:
                ASSIGN imagemDoProgrid      = "/cecred/images/geral/logo_cecred.gif"
                       nomeDaCooperativa    = TRIM(crapcop.nmrescop).
               
                IF INDEX(crapcop.nmrescop, " ") <> 0  THEN
                   DO: 
                      aux_nmrescop = LC(TRIM(crapcop.nmrescop)).
                      SUBSTRING( aux_nmrescop, (INDEX(aux_nmrescop, " ")),1) = "_".
                      imagemDaCooperativa =  "/cecred/images/admin/logo_" +  aux_nmrescop.
                   END.
                ELSE
                   imagemDaCooperativa  = "/cecred/images/admin/logo_" + TRIM(LC(crapcop.nmrescop)) + ".gif" .
            
             END.

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

