/*
 * Programa wpgd0043c.p - Listagem de fechamento final (chamado a partir dos dados de wpgd0043)

Alteracoes: 03/11/2008 - Incluido widget-pool.

            10/12/2008 - Melhoria de performance para a tabela gnapses (Evandro).
            
            19/12/2009 - Troca da coluna realizados por colunas cooperados comunidade e total.
            
            09/06/2011 - Correção da quebra de página (Isara - RKAM).

                        05/06/2012 - Adaptação dos fontes para projeto Oracle. Alterado
                                                 busca na gnapses de CONTAINS para MATCHES (Guilherme Maba).
                         
            04/04/2013 - Alteração para receber logo na alto vale,
                         recebendo nome de viacrediav e buscando com
                         o respectivo nome (David Kruger).
            
            11/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).             
*/

create widget-pool.

/*****************************************************************************/
/*   Bloco de variaveis                                                      */
/*****************************************************************************/

DEFINE VARIABLE cookieEmUso                  AS CHARACTER               NO-UNDO.
DEFINE VARIABLE permiteExecutar              AS CHARACTER               NO-UNDO.
DEFINE VARIABLE IdentificacaoDaSessao        AS CHARACTER               NO-UNDO.
DEFINE VARIABLE msgsDeErro                   AS CHARACTER               NO-UNDO.

DEFINE VARIABLE idEvento                     AS INTEGER                 NO-UNDO.
DEFINE VARIABLE cdCooper                     AS INTEGER                 NO-UNDO.
DEFINE VARIABLE dtAnoAge                     AS INTEGER                 NO-UNDO.
DEFINE VARIABLE detalhar                     AS LOGICAL                 NO-UNDO.

DEFINE VARIABLE aux_contador                 AS INTEGER                 NO-UNDO.
DEFINE VARIABLE aux_nmresage                 LIKE crapage.nmresage      NO-UNDO.
DEFINE VARIABLE aux_nmevento                 LIKE crapedp.nmevento      NO-UNDO.

DEFINE VARIABLE aux_nmrescop                 AS CHARACTER               NO-UNDO.

/* Turmas */
DEFINE TEMP-TABLE turmas
       FIELD cdagenci AS INTEGER
       FIELD qtprevis AS INTEGER
       FIELD qtcancel AS INTEGER
       FIELD qtacresc AS INTEGER
       FIELD qttransf AS INTEGER /* pode ser transferido e/ou recebido */
       FIELD qtrealiz AS INTEGER
       FIELD percentu AS DECIMAL
       FIELD nmresage AS CHARACTER.

DEFINE VARIABLE tur_ttprevis                 AS INTEGER                 NO-UNDO.
DEFINE VARIABLE tur_ttcancel                 AS INTEGER                 NO-UNDO.
DEFINE VARIABLE tur_ttrecebi                 AS INTEGER                 NO-UNDO.
DEFINE VARIABLE tur_ttacresc                 AS INTEGER                 NO-UNDO.
DEFINE VARIABLE tur_tttransf                 AS INTEGER                 NO-UNDO.
DEFINE VARIABLE tur_ttrealiz                 AS INTEGER                 NO-UNDO.

/* Participantes */
DEFINE TEMP-TABLE participantes
       FIELD cdagenci AS INTEGER
       FIELD qtprevis AS INTEGER
       FIELD qtrecoop AS INTEGER
       FIELD qtrecomu AS INTEGER
       FIELD qtrealiz AS INTEGER
       FIELD precentu AS DECIMAL
       FIELD nmresage AS CHARACTER.

DEFINE VARIABLE prt_qtrealiz                 AS INTEGER                 NO-UNDO.
DEFINE VARIABLE prt_qtrecoop                 AS INTEGER                 NO-UNDO.
DEFINE VARIABLE prt_qtrecomu                 AS INTEGER                 NO-UNDO.
DEFINE VARIABLE prt_ttprevis                 AS INTEGER                 NO-UNDO.
DEFINE VARIABLE prt_ttrealiz                 AS INTEGER                 NO-UNDO.
DEFINE VARIABLE prt_ttrecoop                 AS INTEGER                 NO-UNDO.
DEFINE VARIABLE prt_ttrecomu                 AS INTEGER                 NO-UNDO.


DEFINE VARIABLE imagemDoProgrid              AS CHARACTER               NO-UNDO.
DEFINE VARIABLE imagemDaCooperativa          AS CHARACTER               NO-UNDO.
DEFINE VARIABLE nomeDaCooperativa            AS CHARACTER               NO-UNDO.


DEFINE BUFFER crabage FOR crapage.

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

FUNCTION turmas RETURNS LOGICAL ():

    {&out} '   <table class="tab2" border="1" cellspacing="0" cellpadding="0" width="100%">' SKIP
           '     <tr>' SKIP
           '       <td class="td2" align="center" valign="middle" colspan="8">' SKIP
           '         TURMAS' SKIP
           '       </td>' SKIP
           '     </tr>' SKIP
           '     <tr>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         PA' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         PREVISTO' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         CANCELADO' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         ACRESCIDO' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         TRANSFERIDO/RECEBIDO' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         REALIZADO' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         %' SKIP
           '       </td>' SKIP
           '     </tr>' SKIP.

    ASSIGN tur_ttprevis = 0
           tur_ttcancel = 0
           tur_ttacresc = 0
           tur_tttransf = 0
           tur_ttrealiz = 0.

    FOR EACH turmas NO-LOCK BY turmas.nmresage:

        {&out} '     <tr>' SKIP
               '       <td class="td2" align="left">' SKIP
                         turmas.nmresage SKIP
               '       </td>' SKIP
               '       <td class="tdDados2" align="center">' SKIP
                         turmas.qtprevis SKIP
               '       </td>' SKIP
               '       <td class="tdDados2" align="center">' SKIP
                         turmas.qtcancel SKIP
               '       </td>' SKIP
               '       <td class="tdDados2" align="center">' SKIP
                         turmas.qtacresc SKIP
               '       </td>' SKIP
               '       <td class="tdDados2" align="center">' SKIP
                         turmas.qttransf SKIP
               '       </td>' SKIP
               '       <td class="tdDados2" align="center">' SKIP
                         turmas.qtrealiz SKIP
               '       </td>' SKIP
               '       <td class="tdDados2" align="center">' SKIP.

        IF   turmas.qtprevis <> 0   THEN
             {&out} '&nbsp;' ROUND((turmas.qtrealiz * 100) / turmas.qtprevis,2) '%&nbsp;' SKIP.
        ELSE
             {&out} '&nbsp;0%&nbsp' SKIP.

        {&out} '       </td>' SKIP
               '     </tr>' SKIP.
     
        ASSIGN tur_ttprevis = tur_ttprevis + turmas.qtprevis
               tur_ttcancel = tur_ttcancel + turmas.qtcancel
               tur_ttacresc = tur_ttacresc + turmas.qtacresc
               tur_tttransf = tur_tttransf + turmas.qttransf
               tur_ttrealiz = tur_ttrealiz + turmas.qtrealiz.
    END.
    
    {&out} '     <tr>' SKIP
           '       <td class="td2" align="left">' SKIP
           '         TOTAL' SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     tur_ttprevis SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     tur_ttcancel SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     tur_ttacresc SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     tur_tttransf SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     tur_ttrealiz SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP.

    IF   tur_ttprevis <> 0   THEN
         {&out} '&nbsp;' ROUND((tur_ttrealiz * 100) / tur_ttprevis,2) '%&nbsp;' SKIP.
    ELSE
         {&out} '&nbsp;0%&nbsp;' SKIP.

    {&out} '       </td>' SKIP
           '     </tr>' SKIP
           '   </table>'.

END FUNCTION. /* fim turmas */

FUNCTION participantes RETURNS LOGICAL ():

    {&out} '   <table class="tab2" border="1" cellspacing="0" cellpadding="0" width="80%" align="left">' SKIP
           '     <tr>' SKIP
           '       <td class="td2" align="center" valign="middle" colspan="8">' SKIP
           '         PARTICIPANTES' SKIP
           '       </td>' SKIP
           '     </tr>' SKIP
           '     <tr>' SKIP
           '       <td class="td2" align="left">' SKIP
           '         PA' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         PREVISTO' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         COOPERADO' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         COMUNIDADE' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         TOTAL' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         %' SKIP
           '       </td>' SKIP
           '     </tr>' SKIP.

    ASSIGN prt_ttprevis = 0
           prt_ttrecoop = 0
           prt_ttrecomu = 0
           prt_ttrealiz = 0.
    
    FOR EACH participantes NO-LOCK BY participantes.nmresage:

        {&out} '     <tr>' SKIP
               '       <td class="td2" align="left">' SKIP
                         participantes.nmresage SKIP
               '       </td>' SKIP
               '       <td class="tdDados2" align="center">' SKIP
                         participantes.qtprevis SKIP
               '       </td>' SKIP
               '       <td class="tdDados2" align="center">' SKIP
                         participantes.qtrecoop SKIP
               '       </td>' SKIP
               '       <td class="tdDados2" align="center">' SKIP
                         participantes.qtrecomu SKIP
               '       </td>' SKIP
               '       <td class="tdDados2" align="center">' SKIP
                         participantes.qtrealiz SKIP
               '       </td>' SKIP
               '       <td class="tdDados2" align="center">' SKIP.

        
                IF   participantes.qtprevis <> 0   THEN
             {&out} '&nbsp;' ROUND((participantes.qtrealiz * 100) / participantes.qtprevis,2) '%&nbsp;' SKIP.
        ELSE
             {&out} '&nbsp;0%&nbsp;' SKIP.

        {&out} '       </td>' SKIP
               '     </tr>' SKIP.
     
        ASSIGN prt_ttprevis = prt_ttprevis + participantes.qtprevis
               prt_ttrecoop = prt_ttrecoop + participantes.qtrecoop
               prt_ttrecomu = prt_ttrecomu + participantes.qtrecomu
               prt_ttrealiz = prt_ttrealiz + participantes.qtrealiz.
    END.
    
    {&out} '     <tr>' SKIP
           '       <td class="td2" align="left">' SKIP
           '         TOTAL' SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     prt_ttprevis SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     prt_ttrecoop SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     prt_ttrecomu SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     prt_ttrealiz SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP.

    IF   prt_ttprevis <> 0   THEN
         {&out} '&nbsp;' ROUND((prt_ttrealiz * 100) / prt_ttprevis,2) '%&nbsp;' SKIP.
    ELSE
         {&out} '&nbsp;0%&nbsp;' SKIP.

    {&out} '       </td>' SKIP
           '     </tr>' SKIP
           '   </table>'.

END FUNCTION. /* fim participantes */


FUNCTION montaTela RETURNS LOGICAL ():

    /* Eventos */
    FOR EACH crapadp WHERE crapadp.idevento = idevento   AND
                           crapadp.cdcooper = cdcooper   AND
                           crapadp.dtanoage = dtanoage   NO-LOCK:
        /* Turmas */
        FIND turmas WHERE turmas.cdagenci = crapadp.cdagenci EXCLUSIVE-LOCK NO-ERROR.

        IF   NOT AVAILABLE turmas   THEN
             DO:
                 CREATE turmas.
                 ASSIGN turmas.cdagenci = crapadp.cdagenci.
             END.

        /* Participantes */
        FIND participantes WHERE participantes.cdagenci = crapadp.cdagenci EXCLUSIVE-LOCK NO-ERROR.

        IF   NOT AVAILABLE participantes   THEN
             DO:
                 CREATE participantes.
                 ASSIGN participantes.cdagenci = crapadp.cdagenci.
             END.            



        IF   CAN-FIND(FIRST craphep WHERE craphep.idevento = 0                   AND
                                                  craphep.cdcooper = 0                   AND
                                                                                  craphep.dtanoage = 0                   AND
                                                                                  craphep.cdevento = 0                   AND
                                                  craphep.cdagenci = crapadp.nrseqdig    AND 
                                          craphep.dshiseve MATCHES "*acrescido*" NO-LOCK)   THEN
             /* acrescido */ 
             turmas.qtacresc = turmas.qtacresc + 1.
        ELSE
             /* previsto */
             turmas.qtprevis = turmas.qtprevis + 1.

        /* transferido e/ou recebido */
        IF   crapadp.nrmesage <> crapadp.nrmeseve   THEN
             turmas.qttransf = turmas.qttransf + 1.
                    
        /* cancelado */
        IF   crapadp.idstaeve = 2   THEN
             turmas.qtcancel = turmas.qtcancel + 1.
        ELSE
             DO:
                 /* realizado */
                 IF   crapadp.dtfineve < TODAY   THEN
                      turmas.qtrealiz = turmas.qtrealiz + 1.
             END.

        /* para a frequencia minima */
                FIND FIRST crapedp WHERE crapedp.idevento = crapadp.idevento   AND 
                                 crapedp.cdcooper = crapadp.cdcooper   AND
                                 crapedp.dtanoage = crapadp.dtanoage   AND 
                                 crapedp.cdevento = crapadp.cdevento   NO-LOCK.        
                
                /* Participantes previstos (desconsidera eventos acrescidos) - vagas ofertadas */
        IF   NOT CAN-FIND(FIRST craphep WHERE craphep.idevento = 0                   AND
                                                            craphep.cdcooper = 0                   AND
                                                                                            craphep.dtanoage = 0                   AND
                                                                                            craphep.cdevento = 0                   AND
                                                      craphep.cdagenci = crapadp.nrseqdig    AND 
                                              craphep.dshiseve MATCHES "*acrescido*" NO-LOCK)   THEN
             DO:
                 participantes.qtprevis = participantes.qtprevis + crapedp.qtmaxtur.
             END.
                         
        /* Participantes realizados */
        FOR EACH crapidp WHERE crapidp.idevento = crapadp.idevento   AND
                               crapidp.cdcooper = crapadp.cdcooper   AND
                               crapidp.dtanoage = crapadp.dtanoage   AND
                               crapidp.cdagenci = crapadp.cdagenci   AND
                               crapidp.cdevento = crapadp.cdevento   AND
                               crapidp.nrseqeve = crapadp.nrseqdig   AND
                               crapidp.idstains = 2 /*Confirmado*/   NO-LOCK:
           
                        /* Se o evento já ocorreu e NAO FOI CANCELADO, conta os que COMPARECERAM */
            IF   crapadp.dtfineve  < TODAY   AND
                 crapadp.idstaeve <> 2       THEN
                 DO:    
                     /* Se percentual de faltas for suficiente em relacao ao percentual mínimo exigido */
                     IF  ((crapidp.qtfaleve * 100) / crapadp.qtdiaeve) <= (100 - crapedp.prfreque) THEN DO:
                         participantes.qtrealiz = participantes.qtrealiz + 1.
                         IF crapidp.tpinseve = 1 THEN 
                             participantes.qtrecoop = participantes.qtrecoop + 1.
                         ELSE
                             participantes.qtrecomu = participantes.qtrecomu + 1.
                     END.
                 END.
        END.

        FIND crapage WHERE crapage.cdcooper = crapadp.cdcooper   AND
                           crapage.cdagenci = crapadp.cdagenci   NO-LOCK NO-ERROR.

        /* Monta o nome do PA com os PA'S agrupados, caso houver */
        aux_nmresage = crapage.nmresage.

        FOR EACH crapagp  WHERE crapagp.cdcooper  = crapadp.cdcooper   AND
                                crapagp.idevento  = crapadp.idevento   AND
                                crapagp.dtanoage  = crapadp.dtanoage   AND
                                crapagp.cdageagr  = crapadp.cdagenci   AND
                                crapagp.cdageagr <> crapagp.cdagenci   NO-LOCK, 
            FIRST crabage WHERE crabage.cdcooper  = crapagp.cdcooper   AND
                                crabage.cdagenci  = crapagp.cdagenci   NO-LOCK
                                BY crabage.nmresage:

            aux_nmresage = aux_nmresage + " / " + crabage.nmresage.
        END.

        ASSIGN turmas.nmresage        = aux_nmresage
               participantes.nmresage = aux_nmresage.
    END.
    /* FIM - Eventos */

    {&out} '<html>' SKIP
           '<head>' SKIP
           '<title>Progrid - Fechamento Final</title>' SKIP.

    {&out} '<style>' SKIP
           '   body         ~{ background-color: #FFFFFF; }' SKIP
           '   td           ~{ font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: bold; }' SKIP
           '   .tdCab1      ~{ background-color: #B1B1B1; font-family: Arial, Helvetica, sans-serif; font-size: 14px; font-weight: bold; }' SKIP
           '   .tdCab2      ~{ background-color: #C6C6C6; font-family: Arial, Helvetica, sans-serif; font-size: 12px; font-weight: bold; }' SKIP
           '   .tdCab3      ~{ background-color: #DBDBDB; font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: bold; }' SKIP
           '   .tdLabel     ~{ font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: bold; }' SKIP
           '   .tdDados     ~{ font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: normal; border-bottom: #000000 0px solid }' SKIP
           '   .tdTitulo1   ~{ font-family: Verdana; font-size: 24px; font-weight: normal;}' SKIP
           '   .tdTitulo2   ~{ font-family: Verdana; font-size: 18px; font-weight: bold;}' SKIP
           '   .tab1        ~{ border-collapse:collapse; border-top: #000000 1px solid; border-bottom: #000000 1px solid; border-right: #000000 1px solid; border-left: #000000 1px solid; }' SKIP
           
           '   .tab2        ~{ border-color:black }' SKIP
           '   .td2         ~{ border-color:black }' SKIP
           '   .tdDados2    ~{ font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: normal; border-color:black}' SKIP
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
           '         <td class="tdprogra" colspan="5" align="right">wpgd0043c - ' TODAY '</td>' SKIP
           '   </table>' SKIP. 

    /* *** Logo *** */
    {&out} '   <table border="0" cellspacing="0" cellpadding="0" width="100%" class="tab1">' SKIP
           '      <tr>' SKIP
           '         <td align="center"><img src="' imagemDoProgrid '" border="0"></td>' SKIP
           '         <td class="tdTitulo1" colspan="4" align="center">' nomeDaCooperativa ' - Fechamento Geral - ' dtAnoAge '</td>' SKIP
           '         <td align="center"><img src="' imagemDaCooperativa '" border="0"></td>' SKIP
           '      </tr>' SKIP
           '      <tr>' SKIP
           '         <td align="center" colspan="6"> &nbsp; </td>' SKIP
           '      </tr>' SKIP
           '      <tr>' SKIP
           '         <td class="tdTitulo2" colspan="6" align="center">POR PA</td>' SKIP
           '      </tr>' SKIP
           '   </table>' SKIP. 

    {&out} '<br>' SKIP.

    turmas().

    {&out} '<br>' SKIP.
                               
    participantes().

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


FUNCTION montaTela_detalhado RETURNS LOGICAL ():
    
    /*DEFINE VARIABLE aux_nrdlinha AS INTEGER         NO-UNDO.*/
    
    {&out} '<html>' SKIP
           '<head>' SKIP
           '<title>Progrid - Fechamento Final</title>' SKIP.

    {&out} '<style>' SKIP
           '   body         ~{ background-color: #FFFFFF; }' SKIP
           '   td           ~{ font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: bold; }' SKIP
           '   .tdCab1      ~{ background-color: #B1B1B1; font-family: Arial, Helvetica, sans-serif; font-size: 14px; font-weight: bold; }' SKIP
           '   .tdCab2      ~{ background-color: #C6C6C6; font-family: Arial, Helvetica, sans-serif; font-size: 12px; font-weight: bold; }' SKIP
           '   .tdCab3      ~{ background-color: #DBDBDB; font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: bold; }' SKIP
           '   .tdLabel     ~{ font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: bold; }' SKIP
           '   .tdDados     ~{ font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: normal; border-bottom: #000000 0px solid }' SKIP
           '   .tdTitulo1   ~{ font-family: Verdana; font-size: 24px; font-weight: normal;}' SKIP
           '   .tdTitulo2   ~{ font-family: Verdana; font-size: 18px; font-weight: bold;}' SKIP
           '   .tab1        ~{ border-collapse:collapse; border-top: #000000 1px solid; border-bottom: #000000 1px solid; border-right: #000000 1px solid; border-left: #000000 1px solid; }' SKIP
           
           '   .tab2        ~{ border-color:black }' SKIP
           '   .td2         ~{ border-color:black }' SKIP
           '   .tdDados2    ~{ font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: normal; border-color:black}' SKIP
           '</style>' SKIP.

    {&out} '</head>' SKIP
           '<body bgcolor="#FFFFFF" topmargin="0" marginwidth="0" marginheight="0">' SKIP
           '<div align="left">' SKIP.
    
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
           '         <td class="tdprogra" colspan="5" align="right">wpgd0043c - ' TODAY '</td>' SKIP
           '   </table>' SKIP. 

    /* *** Logo *** */
    {&out} '   <table border="0" cellspacing="0" cellpadding="0" width="100%" class="tab1">' SKIP
           '      <tr>' SKIP
           '         <td align="center"><img src="' imagemDoProgrid '" border="0"></td>' SKIP
           '         <td class="tdTitulo1" colspan="4" align="center">' nomeDaCooperativa ' - Fechamento Final - ' dtAnoAge '</td>' SKIP
           '         <td align="center"><img src="' imagemDaCooperativa '" border="0"></td>' SKIP
           '      </tr>' SKIP
           '      <tr>' SKIP
           '         <td align="center" colspan="6"> &nbsp; </td>' SKIP
           '      </tr>' SKIP
           '      <tr>' SKIP
           '         <td class="tdTitulo2" colspan="6" align="center">POR PA - DETALHADO</td>' SKIP
           '      </tr>' SKIP
           '   </table>' SKIP
           '   <br>' SKIP. 

    /* Eventos */

    /*aux_nrdlinha = 9 /* cabecalho */.*/

    FOR EACH crapadp  WHERE crapadp.idevento = idevento           AND
                            crapadp.cdcooper = cdcooper           AND
                            crapadp.dtanoage = dtanoage           NO-LOCK,
                FIRST crapedp WHERE crapedp.idevento = crapadp.idevento   AND 
                            crapedp.cdcooper = crapadp.cdcooper   AND
                            crapedp.dtanoage = crapadp.dtanoage   AND 
                            crapedp.cdevento = crapadp.cdevento   NO-LOCK, 
        FIRST crapage WHERE crapage.cdcooper = crapadp.cdcooper   AND
                            crapage.cdagenci = crapadp.cdagenci   NO-LOCK
                            BREAK BY crapage.nmresage 
                                    BY crapedp.nmevento:

        /* Monta o nome do PAC com os PACS agrupados, caso houver */
        IF   FIRST-OF(crapage.nmresage)    THEN
             DO:
                 aux_nmresage = crapage.nmresage.

                 FOR EACH crapagp  WHERE crapagp.cdcooper  = crapadp.cdcooper   AND
                                         crapagp.idevento  = crapadp.idevento   AND
                                         crapagp.dtanoage  = crapadp.dtanoage   AND
                                         crapagp.cdageagr  = crapadp.cdagenci   AND
                                         crapagp.cdageagr <> crapagp.cdagenci   NO-LOCK, 
                     FIRST crabage WHERE crabage.cdcooper  = crapagp.cdcooper   AND
                                         crabage.cdagenci  = crapagp.cdagenci   NO-LOCK
                                         BY crabage.nmresage:

                     aux_nmresage = aux_nmresage + " / " + crabage.nmresage.
                 END.
             END.

        IF   FIRST-OF(crapage.nmresage)   /*OR
             aux_nrdlinha > 65*/          THEN
             DO:
                /*IF   aux_nrdlinha > 65                AND
                     NOT FIRST-OF(crapage.nmresage)   THEN
                     DO:
                         {&out} '</table>' SKIP
                                '<br style="page-break-after: always">' SKIP
                                '<br>' SKIP
                                '   <font align="left" style="font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: bold;">' SKIP
                                      aux_nmresage ' (CONT.)' SKIP
                                '   </font>' SKIP.
                             
                         aux_nrdlinha = 0.
                     END.
                ELSE
                     DO:*/
                         {&out} '   <font align="left" style="font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: bold;">' SKIP
                                      aux_nmresage SKIP
                                '   </font>' SKIP.

                         ASSIGN prt_ttprevis = 0
                                prt_ttrealiz = 0
                                prt_ttrecoop = 0
                                prt_ttrecomu = 0.
                     /*END.*/


                {&out} '   <br>' SKIP
                       '   <br>' SKIP
                       '   <table class="tab2" border="1" cellspacing="0" cellpadding="0" width="100%" align="center">' SKIP
                       '     <tr>' SKIP
                       '       <td class="td2" align="center" width="50%">' SKIP
                       '         EVENTO' SKIP
                       '       </td>' SKIP
                       '       <td class="td2" align="center" width="20%">' SKIP
                       '         DATA' SKIP
                       '       </td>' SKIP
                       '       <td class="td2" align="center" width="15%">' SKIP
                       '         PREVISTO' SKIP
                       '       </td>' SKIP
                       '       <td class="td2" align="center" width="15%">' SKIP
                       '         COOP' SKIP
                       '       </td>' SKIP
                       '       <td class="td2" align="center" width="15%">' SKIP
                       '         COMU' SKIP
                       '       </td>' SKIP
                       '       <td class="td2" align="center" width="15%">' SKIP
                       '         TOTAL' SKIP
                       '       </td>' SKIP
                       '     </tr>' SKIP.

                /*aux_nrdlinha = aux_nrdlinha + 2.*/
             END.

            /* Participantes realizados */
        ASSIGN prt_qtrealiz = 0
               prt_qtrecoop = 0
               prt_qtrecomu = 0.
        FOR EACH crapidp WHERE crapidp.idevento = crapadp.idevento   AND
                               crapidp.cdcooper = crapadp.cdcooper   AND
                               crapidp.dtanoage = crapadp.dtanoage   AND
                               crapidp.cdagenci = crapadp.cdagenci   AND
                               crapidp.cdevento = crapadp.cdevento   AND
                               crapidp.nrseqeve = crapadp.nrseqdig   AND
                               crapidp.idstains = 2 /*Confirmado*/   NO-LOCK:

            /* Se o evento já ocorreu e NAO FOI CANCELADO, conta os que COMPARECERAM */
            IF   crapadp.dtfineve  < TODAY   AND
                 crapadp.idstaeve <> 2       THEN DO:    
                 /* Se percentual de faltas for suficiente em relacao ao percentual mínimo exigido */
                 IF ((crapidp.qtfaleve * 100) / crapadp.qtdiaeve) <= (100 - crapedp.prfreque) THEN DO:
                    prt_qtrealiz = prt_qtrealiz + 1.
                    IF crapidp.tpinseve = 1 THEN 
                       prt_qtrecoop = prt_qtrecoop + 1.
                    ELSE
                       prt_qtrecomu = prt_qtrecomu + 1.
                 END.
            END.
                        
        END.

        /* nome do evento */
        IF   FIRST-OF(crapedp.nmevento)   THEN   
             aux_nmevento = crapedp.nmevento.
            ELSE
             aux_nmevento = "&nbsp;".

        {&out} '     <tr>' SKIP
               '       <td class="td2" align="left">' SKIP
                         aux_nmevento SKIP
               '       </td>' SKIP
               '       <td class="tdDados2" align="center">' SKIP.

        IF   crapadp.dtinieve = ?   THEN
             {&out} 'INDEFINIDO' SKIP.
        ELSE
        IF   crapadp.dtinieve = crapadp.dtfineve   THEN
             {&out} crapadp.dtinieve SKIP.
        ELSE
             {&out} crapadp.dtinieve ' a ' crapadp.dtfineve SKIP.

        {&out} '       </td>' SKIP
               '       <td class="tdDados2" align="center">' SKIP.

        /* Participantes previstos (desconsidera eventos acrescidos) - vagas ofertadas */
        IF   NOT CAN-FIND(FIRST craphep WHERE craphep.idevento = 0                   AND
                                                            craphep.cdcooper = 0                   AND
                                                                                            craphep.dtanoage = 0                   AND
                                                                                            craphep.cdevento = 0                   AND
                                                      craphep.cdagenci = crapadp.nrseqdig    AND 
                                              craphep.dshiseve MATCHES "*acrescido*" NO-LOCK)   THEN
             {&out} crapedp.qtmaxtur SKIP.
        ELSE
             {&out} "0" SKIP.

        {&out} '       </td>' SKIP.

        IF   crapadp.idstaeve = 2 THEN  do: /* cancelado */
            {&out} '       <td class="tdDados2" align="center" colspan="3">' SKIP
                   'CANCELADO' SKIP
                   '       </td>' SKIP.
        END.
        ELSE DO:
            {&out} '       <td class="tdDados2" align="center">' SKIP
                   prt_qtrecoop SKIP
                   '       </td>' SKIP.
            {&out} '       <td class="tdDados2" align="center">' SKIP
                   prt_qtrecomu SKIP
                   '       </td>' SKIP.
            {&out} '       <td class="tdDados2" align="center">' SKIP
                   prt_qtrealiz SKIP
                   '       </td>' SKIP.
        END.

        {&out} '     </tr>' SKIP.

        /* Participantes previstos (desconsidera eventos acrescidos) - vagas ofertadas */
        IF   NOT CAN-FIND(FIRST craphep WHERE craphep.idevento = 0                   AND
                                                            craphep.cdcooper = 0                   AND
                                                                                      craphep.dtanoage = 0                   AND
                                                                                            craphep.cdevento = 0                   AND
                                                      craphep.cdagenci = crapadp.nrseqdig    AND 
                                              craphep.dshiseve MATCHES "*acrescido*" NO-LOCK)   THEN
             prt_ttprevis = prt_ttprevis + crapedp.qtmaxtur.
        
        ASSIGN prt_ttrealiz = prt_ttrealiz + prt_qtrealiz
               prt_ttrecoop = prt_ttrecoop + prt_qtrecoop
               prt_ttrecomu = prt_ttrecomu + prt_qtrecomu.
               /*aux_nrdlinha = aux_nrdlinha + 1*/


        IF   LAST-OF(crapage.nmresage)   THEN
             DO:
                 {&out} '     <tr>' SKIP
                        '       <td class="td2" align="left">' SKIP
                        '         &nbsp;' SKIP
                        '       </td>' SKIP
                        '       <td class="td2" align="left">' SKIP
                        '         &nbsp;' SKIP
                        '       </td>' SKIP
                        '       <td class="tdDados2" align="center">' SKIP
                                  prt_ttprevis SKIP
                        '       </td>' SKIP
                        '       <td class="tdDados2" align="center">' SKIP
                                  prt_ttrecoop SKIP
                        '       </td>' SKIP
                        '       <td class="tdDados2" align="center">' SKIP
                                  prt_ttrecomu SKIP
                        '       </td>' SKIP
                        '       <td class="tdDados2" align="center">' SKIP
                                  prt_ttrealiz SKIP
                        '       </td>' SKIP
                        '     </tr>' SKIP
                        '   </table>' SKIP
                        '   <br>' SKIP.
                 
                 /*aux_nrdlinha = aux_nrdlinha + 3.*/
             END.
    END.
    /* FIM - Eventos */

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

END FUNCTION. /* montaTela_detalhado RETURNS LOGICAL () */

/*****************************************************************************/
/*   Bloco de principal do programa                                          */
/*****************************************************************************/

output-content-type("text/html").

ASSIGN cookieEmUso = GET-COOKIE("cookie-usuario-em-uso").

/* Usado FOR EACH para poder utilizar o CONTAINS e WORD-INDEX. alterado para MATCHES */
FOR EACH gnapses WHERE gnapses.idsessao MATCHES "*" + cookieEmUso + "*" NO-LOCK:
    LEAVE.
END.

RUN PermissaoDeAcesso("", OUTPUT IdentificacaoDaSessao, OUTPUT permiteExecutar).

IF permiteExecutar = "1" OR permiteExecutar = "2"
   THEN
       erroNaValidacaoDoLogin(permiteExecutar).
   ELSE
       DO:
          ASSIGN idevento  = INTEGER(GET-VALUE("parametro1"))
                 cdcooper  = INTEGER(GET-VALUE("parametro2"))
                 dtanoage  = INTEGER(GET-VALUE("parametro3")) 
                 detalhar  = LOGICAL(GET-VALUE("parametro4")) NO-ERROR.          

          FIND LAST gnpapgd WHERE gnpapgd.idevento = idevento   AND 
                                  gnpapgd.cdcooper = cdcooper   AND 
                                  gnpapgd.dtanonov = dtanoage   NO-LOCK NO-ERROR.


          FIND crapcop WHERE crapcop.cdcooper = cdcooper NO-LOCK NO-ERROR.
      
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

          IF   detalhar   THEN
               montatela_detalhado().
          ELSE
               montatela().
       END.
          
/*****************************************************************************/
/*                                                                           */
/*   Bloco de procdures                                                      */
/*                                                                           */
/*****************************************************************************/

PROCEDURE PermissaoDeAcesso :

    {includes/wpgd0009.i}

END PROCEDURE.

