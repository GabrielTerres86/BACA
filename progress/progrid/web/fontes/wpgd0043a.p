/*
 * Programa wpgd0043a.p - Listagem de fechamento final (chamado a partir dos dados de wpgd0043)

Alteracoes: 03/11/2008 - Inclusao do widget-pool.

            10/12/2008 - Melhoria de performance para a tabela gnapses (Evandro).
            
            18/03/2009 - Quebra de coluna "realizado" em "Cooperativo", "Comunidade" e "Total" para tabelas com participantes (Martin)

			05/06/2012 - Adaptação dos fontes para projeto Oracle. Alterado
						 busca na gnapses de CONTAINS para MATCHES (Guilherme Maba).
                         
            04/04/2013 - Alteração para receber logo na alto vale,
                         recebendo nome de viacrediav e buscando com
                         o respectivo nome (David Kruger).
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

DEFINE VARIABLE aux_contador                 AS INTEGER                 NO-UNDO.
DEFINE VARIABLE aux_mesatual                 AS INTEGER                 NO-UNDO.

DEFINE VARIABLE aux_nmrescop                 AS CHARACTER               NO-UNDO.

/* Turmas */
DEFINE VARIABLE tur_qtprevis                 AS INTEGER     EXTENT 12   NO-UNDO.
DEFINE VARIABLE tur_qtcancel                 AS INTEGER     EXTENT 12   NO-UNDO.
DEFINE VARIABLE tur_qtrecebi                 AS INTEGER     EXTENT 12   NO-UNDO.
DEFINE VARIABLE tur_qtacresc                 AS INTEGER     EXTENT 12   NO-UNDO.
DEFINE VARIABLE tur_qttransf                 AS INTEGER     EXTENT 12   NO-UNDO.
DEFINE VARIABLE tur_qtrealiz                 AS INTEGER     EXTENT 12   NO-UNDO.
DEFINE VARIABLE tur_andament                 AS INTEGER     EXTENT 12   NO-UNDO.

DEFINE VARIABLE tur_ttprevis                 AS INTEGER                 NO-UNDO.
DEFINE VARIABLE tur_ttcancel                 AS INTEGER                 NO-UNDO.
DEFINE VARIABLE tur_ttrecebi                 AS INTEGER                 NO-UNDO.
DEFINE VARIABLE tur_ttacresc                 AS INTEGER                 NO-UNDO.
DEFINE VARIABLE tur_tttransf                 AS INTEGER                 NO-UNDO.
DEFINE VARIABLE tur_ttrealiz                 AS INTEGER                 NO-UNDO.
DEFINE VARIABLE tur_ttandame                 AS INTEGER                 NO-UNDO.

/* Participantes */
DEFINE VARIABLE prt_qtprevis                 AS INTEGER     EXTENT 12   NO-UNDO.
DEFINE VARIABLE prt_qtrecoop                 AS INTEGER     EXTENT 12   NO-UNDO.
DEFINE VARIABLE prt_qtrecomu                 AS INTEGER     EXTENT 12   NO-UNDO.
DEFINE VARIABLE prt_qtrealiz                 AS INTEGER     EXTENT 12   NO-UNDO.

DEFINE VARIABLE prt_ttprevis                 AS INTEGER                 NO-UNDO.
DEFINE VARIABLE prt_ttrecoop                 AS INTEGER                 NO-UNDO.
DEFINE VARIABLE prt_ttrecomu                 AS INTEGER                 NO-UNDO.
DEFINE VARIABLE prt_ttrealiz                 AS INTEGER                 NO-UNDO.

/* Questionarios */
DEFINE VARIABLE qst_qtprevis                 AS INTEGER     EXTENT 12   NO-UNDO.
DEFINE VARIABLE qst_qtrealiz                 AS INTEGER     EXTENT 12   NO-UNDO.

DEFINE VARIABLE qst_ttprevis                 AS INTEGER                 NO-UNDO.
DEFINE VARIABLE qst_ttrealiz                 AS INTEGER                 NO-UNDO.


DEFINE VARIABLE imagemDoProgrid              AS CHARACTER               NO-UNDO.
DEFINE VARIABLE imagemDaCooperativa          AS CHARACTER               NO-UNDO.
DEFINE VARIABLE nomeDaCooperativa            AS CHARACTER               NO-UNDO.

DEFINE VARIABLE mes                          AS CHARACTER   EXTENT 12
                                                INITIAL ["Jan","Fev","Mar","Abr","Mai","Jun",
                                                         "Jul","Ago","Set","Out","Nov","Dez"]    NO-UNDO.

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
           '       <td class="td2" align="center" valign="middle" colspan="9">' SKIP
           '         INICIO DAS TURMAS' SKIP
           '       </td>' SKIP
           '     </tr>' SKIP
           '     <tr>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         &nbsp;' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         PREVI.' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         CANCEL.' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         RECEBIDO' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         ACRESCIDO' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         TRANSF.' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         REALIZADO' SKIP
           '       </td>' SKIP
                   '       <td class="td2" align="center">' SKIP
           '        EM ANDAM.' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         %' SKIP
           '       </td>' SKIP
           '     </tr>' SKIP.

    ASSIGN tur_ttprevis = 0
           tur_ttcancel = 0
           tur_ttrecebi = 0
           tur_ttacresc = 0
           tur_tttransf = 0
           tur_ttrealiz = 0
                   tur_ttandame = 0.
    
    DO aux_contador = 1 TO 12:

       {&out} '     <tr>' SKIP
              '       <td class="td2" align="center">' SKIP
                        mes[aux_contador] SKIP
              '       </td>' SKIP
              '       <td class="tdDados2" align="center">' SKIP
                        tur_qtprevis[aux_contador] SKIP
              '       </td>' SKIP
              '       <td class="tdDados2" align="center">' SKIP
                        tur_qtcancel[aux_contador] SKIP
              '       </td>' SKIP
              '       <td class="tdDados2" align="center">' SKIP
                        tur_qtrecebi[aux_contador] SKIP
              '       </td>' SKIP
              '       <td class="tdDados2" align="center">' SKIP
                        tur_qtacresc[aux_contador] SKIP
              '       </td>' SKIP
              '       <td class="tdDados2" align="center">' SKIP
                        tur_qttransf[aux_contador] SKIP
              '       </td>' SKIP
              '       <td class="tdDados2" align="center">' SKIP
                        tur_qtrealiz[aux_contador] SKIP
              '       </td>' SKIP
                          '       <td class="tdDados2" align="center">' SKIP
                      tur_andament[aux_contador] SKIP
              '       </td>' SKIP
              '       <td class="tdDados2" align="center">' SKIP.

       IF   tur_qtprevis[aux_contador] <> 0   THEN
            {&out} '&nbsp;' ROUND((tur_qtrealiz[aux_contador] * 100) / tur_qtprevis[aux_contador],2) '%&nbsp;' SKIP.
       ELSE
            {&out} '&nbsp;0%&nbsp;' SKIP.

       {&out} '       </td>' SKIP
              '     </tr>' SKIP.

       ASSIGN tur_ttprevis = tur_ttprevis + tur_qtprevis[aux_contador]
              tur_ttcancel = tur_ttcancel + tur_qtcancel[aux_contador]
              tur_ttrecebi = tur_ttrecebi + tur_qtrecebi[aux_contador]
              tur_ttacresc = tur_ttacresc + tur_qtacresc[aux_contador]
              tur_tttransf = tur_tttransf + tur_qttransf[aux_contador]
              tur_ttrealiz = tur_ttrealiz + tur_qtrealiz[aux_contador]
              tur_ttandame = tur_ttandame + tur_andament[aux_contador].
    END.
    
    {&out} '     <tr>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         TOTAL' SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     tur_ttprevis SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     tur_ttcancel SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     tur_ttrecebi SKIP
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
                   '       <td class="tdDados2" align="center">' SKIP
                     tur_ttandame SKIP
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

    {&out} '   <table class="tab2" border="1" cellspacing="0" cellpadding="0" width="100%">' SKIP
           '     <tr>' SKIP
           '       <td class="td2" align="center" valign="middle" colspan="8">' SKIP
           '         PARTICIPANTES' SKIP
           '       </td>' SKIP
           '     </tr>' SKIP
           '     <tr>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         &nbsp;' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         PREV' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         COOP' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         COMU' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         TOT' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         %' SKIP
           '       </td>' SKIP
           '     </tr>' SKIP.

    ASSIGN prt_ttprevis = 0
           prt_ttrealiz = 0.
    
    DO aux_contador = 1 TO 12:

       {&out} '     <tr>' SKIP
              '       <td class="td2" align="center">' SKIP
                        mes[aux_contador] SKIP
              '       </td>' SKIP
              '       <td class="tdDados2" align="center">' SKIP
                        prt_qtprevis[aux_contador] SKIP
              '       </td>' SKIP
              '       <td class="tdDados2" align="center">' SKIP
                        prt_qtrecoop[aux_contador] SKIP
              '       </td>' SKIP
              '       <td class="tdDados2" align="center">' SKIP
                        prt_qtrecomu[aux_contador] SKIP
              '       </td>' SKIP
              '       <td class="tdDados2" align="center">' SKIP
                        prt_qtrealiz[aux_contador] SKIP
              '       </td>' SKIP
              '       <td class="tdDados2" align="center">' SKIP.

       IF   prt_qtprevis[aux_contador] <> 0   THEN
            {&out} '&nbsp;' ROUND((prt_qtrealiz[aux_contador] * 100) / prt_qtprevis[aux_contador],2) '%&nbsp;' SKIP.
       ELSE
            {&out} '&nbsp;0%&nbsp;' SKIP.

       {&out} '       </td>' SKIP
              '     </tr>' SKIP.

       ASSIGN prt_ttprevis = prt_ttprevis + prt_qtprevis[aux_contador]
              prt_ttrecoop = prt_ttrecoop + prt_qtrecoop[aux_contador]
              prt_ttrecomu = prt_ttrecomu + prt_qtrecomu[aux_contador]
              prt_ttrealiz = prt_ttrealiz + prt_qtrealiz[aux_contador].
    END.
    
    {&out} '     <tr>' SKIP
           '       <td class="td2" align="center">' SKIP
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

FUNCTION questionarios RETURNS LOGICAL ():

    {&out} '   <table class="tab2" border="1" cellspacing="0" cellpadding="0" width="100%">' SKIP
           '     <tr>' SKIP
           '       <td class="td2" align="center" valign="middle" colspan="8">' SKIP
           '         KITS PARTICIPANTES' SKIP
           '       </td>' SKIP
           '     </tr>' SKIP
           '     <tr>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         &nbsp;' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         PREVISTO' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         REALIZADO' SKIP
           '       </td>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         %' SKIP
           '       </td>' SKIP
           '     </tr>' SKIP.

    ASSIGN qst_ttprevis = 0
           qst_ttrealiz = 0.
    
    DO aux_contador = 1 TO 12:

       {&out} '     <tr>' SKIP
              '       <td class="td2" align="center">' SKIP
                        mes[aux_contador] SKIP
              '       </td>' SKIP
              '       <td class="tdDados2" align="center">' SKIP
                        qst_qtprevis[aux_contador] SKIP
              '       </td>' SKIP
              '       <td class="tdDados2" align="center">' SKIP
                        qst_qtrealiz[aux_contador] SKIP
              '       </td>' SKIP
              '       <td class="tdDados2" align="center">' SKIP.

       IF   qst_qtprevis[aux_contador] <> 0   THEN
            {&out} '&nbsp;' ROUND((qst_qtrealiz[aux_contador] * 100) / qst_qtprevis[aux_contador],2) '%&nbsp;' SKIP.
       ELSE
            {&out} '&nbsp;0%&nbsp;' SKIP.

       {&out} '       </td>' SKIP
              '     </tr>' SKIP.

       ASSIGN qst_ttprevis = qst_ttprevis + qst_qtprevis[aux_contador]
              qst_ttrealiz = qst_ttrealiz + qst_qtrealiz[aux_contador].
    END.
    
    {&out} '     <tr>' SKIP
           '       <td class="td2" align="center">' SKIP
           '         TOTAL' SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     qst_ttprevis SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP
                     qst_ttrealiz SKIP
           '       </td>' SKIP
           '       <td class="tdDados2" align="center">' SKIP.

    IF   qst_ttprevis <> 0   THEN
         {&out} '&nbsp;' ROUND((qst_ttrealiz * 100) / qst_ttprevis,2) '%&nbsp;' SKIP.
    ELSE
         {&out} '&nbsp;0%&nbsp;' SKIP.

    {&out} '       </td>' SKIP
           '     </tr>' SKIP
           '   </table>'.

END FUNCTION. /* fim questionarios */

FUNCTION total_geral RETURNS LOGICAL ():

    {&out} '   <table class="tab2" border="1" cellspacing="0" cellpadding="0" width="100%">' SKIP
           '     <tr>' SKIP
           '       <td class="td2" align="center" valign="middle">' SKIP
           '         TOTAL PARTICIPANTES' SKIP
           '       </td>' SKIP
           '     </tr>' SKIP
           '     <tr>' SKIP

           '       <td class="td2" align="center" valign="middle">' SKIP
           '         <table class="tab2" border="0" cellspacing="0" cellpadding="0" width="100%">' SKIP
           '           <tr>' SKIP
           '             <td class="tdDados2" align="right" width="60%">' SKIP
           '               PREVISTO:&nbsp;&nbsp;' SKIP
           '             </td>' SKIP
           '             <td class="tdDados2" align="left">' SKIP
                           prt_ttprevis + qst_ttprevis SKIP
           '             </td>' SKIP
           '           </tr>' SKIP
           '         </table>' SKIP
           '       </td>' SKIP
           '     </tr>' SKIP

           '     <tr>' SKIP
           '       <td class="td2" align="center" valign="middle">' SKIP
           '         <table class="tab2" border="0" cellspacing="0" cellpadding="0" width="100%">' SKIP
           '           <tr>' SKIP
           '             <td class="tdDados2" align="right" width="60%">' SKIP
           '               COOPERADOS:&nbsp;&nbsp;' SKIP
           '             </td>' SKIP
           '             <td class="tdDados2" align="left">' SKIP
                            prt_ttrecoop + qst_ttrealiz SKIP
           '             </td>' SKIP
           '           </tr>' SKIP
           '         </table>' SKIP
           '       </td>' SKIP
           '     </tr>' SKIP
              
            '     <tr>' SKIP
            '       <td class="td2" align="center" valign="middle">' SKIP
            '         <table class="tab2" border="0" cellspacing="0" cellpadding="0" width="100%">' SKIP
            '           <tr>' SKIP
            '             <td class="tdDados2" align="right" width="60%">' SKIP
            '               COMUNIDADE:&nbsp;&nbsp;' SKIP
            '             </td>' SKIP
            '             <td class="tdDados2" align="left">' SKIP
                            prt_ttrecomu  SKIP
            '             </td>' SKIP
            '           </tr>' SKIP
            '         </table>' SKIP
            '       </td>' SKIP
            '     </tr>' SKIP
        
           '     <tr>' SKIP
           '       <td class="td2" align="center" valign="middle">' SKIP
           '         <table class="tab2" border="0" cellspacing="0" cellpadding="0" width="100%">' SKIP
           '           <tr>' SKIP
           '             <td class="tdDados2" align="right" width="60%">' SKIP
           '               REALIZADO:&nbsp;&nbsp;' SKIP
           '             </td>' SKIP
           '             <td class="tdDados2" align="left">' SKIP
                           prt_ttrecomu + prt_ttrecoop + qst_ttrealiz SKIP
           '             </td>' SKIP
           '           </tr>' SKIP
           '         </table>' SKIP
           '       </td>' SKIP
           '     </tr>' SKIP

           '     <tr>' SKIP
           '       <td class="td2" align="center" valign="middle">' SKIP
           '         <table class="tab2" border="0" cellspacing="0" cellpadding="0" width="100%">' SKIP
           '           <tr>' SKIP
           '             <td class="tdDados2" align="right" width="60%">' SKIP
           '               ATINGIDO:&nbsp;&nbsp;' SKIP
           '             </td>' SKIP
           '             <td class="tdDados2" align="left">' SKIP
                           ROUND(((prt_ttrecoop + prt_ttrecomu + qst_ttrealiz) * 100) / (prt_ttprevis + qst_ttprevis),2) '%&nbsp;' SKIP
           '             </td>' SKIP
           '           </tr>' SKIP
           '         </table>' SKIP
           '       </td>' SKIP
           '     </tr>' SKIP
           '   </table>' SKIP.

END FUNCTION. /* fim total_geral */

FUNCTION montaTela RETURNS LOGICAL ():


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
           '         <td class="tdprogra" colspan="5" align="right">wpgd0043a - ' TODAY '</td>' SKIP
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
           '         <td class="tdTitulo2" colspan="6" align="center">DADOS QUANTITATIVOS</td>' SKIP
           '      </tr>' SKIP
           '   </table>' SKIP. 

    {&out} '<br>' SKIP.


    {&out} '   <table border="0" width="100%">' SKIP
           '     <tr>' SKIP
           '       <td width="73%">' SKIP.

    turmas().

    {&out} '       </td>' SKIP
           '       <td width="4%">' SKIP
           '       </td>' SKIP
           '       <td width="23%">'  SKIP.

    participantes().
                               

    {&out} '       </td>' SKIP
           '     </tr>' SKIP
           '   </table>' SKIP.


    {&out} '   <br>' SKIP
           '   <table border="0" width="100%" align="left">' SKIP
           '     <tr>' SKIP
           '       <td width="55%">' SKIP.

    questionarios().

    {&out} '       </td>' SKIP
           '       <td width="10%">' SKIP
           '       </td>' SKIP
           '       <td width="25%">'  SKIP.

    total_geral().

    {&out} '       </td>' SKIP
           '       <td width="10%">' SKIP
           '       </td>' SKIP
           '     </tr>' SKIP
           '   </table>' SKIP.


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
          ASSIGN idevento  = INTEGER(GET-VALUE("parametro1"))
                 cdcooper  = INTEGER(GET-VALUE("parametro2"))
                 dtanoage  = INTEGER(GET-VALUE("parametro3")) NO-ERROR.          

          FIND LAST gnpapgd WHERE gnpapgd.idevento = idevento   AND 
                                  gnpapgd.cdcooper = cdcooper   AND 
                                  gnpapgd.dtanonov = dtanoage   NO-LOCK NO-ERROR.

          ASSIGN tur_qtprevis = 0
                 tur_qtcancel = 0
                 tur_qtrecebi = 0
                 tur_qtacresc = 0
                 tur_qttransf = 0
                 tur_qtrealiz = 0
                                 tur_andament = 0
              
                 prt_qtprevis = 0
                 prt_qtrecoop = 0
                 prt_qtrecomu = 0
                 prt_qtrealiz = 0
              
                 qst_qtprevis = gnpapgd.qtretque / 12
                 qst_qtrealiz = 0.

          DO aux_contador = 1 TO 12:

             /* eventos originados no mes */
             FOR EACH crapadp WHERE crapadp.idevento = idevento       AND
                                    crapadp.cdcooper = cdcooper       AND
                                    crapadp.dtanoage = dtanoage       AND 
                                    crapadp.nrmesage = aux_contador   NO-LOCK:
                
                                 IF   CAN-FIND(FIRST craphep WHERE craphep.idevento = 0                   AND
                                                                   craphep.cdcooper = 0                   AND
                                                                   craphep.dtanoage = 0                   AND
                                                                   craphep.cdevento = 0                   AND
                                                                   craphep.cdagenci = crapadp.nrseqdig    AND 
                                                                   craphep.dshiseve MATCHES "*acrescido*" NO-LOCK)   THEN
                      /* acrescido */ 
                      tur_qtacresc[aux_contador] = tur_qtacresc[aux_contador] + 1.
                 ELSE
                      /* previsto */
                      tur_qtprevis[aux_contador] = tur_qtprevis[aux_contador] + 1.

                 /* transferido */
                 IF   crapadp.nrmesage <> crapadp.nrmeseve   THEN
                      tur_qttransf[aux_contador] = tur_qttransf[aux_contador] + 1.
                 ELSE
                      DO:
                          /* cancelado */
                          IF   crapadp.idstaeve = 2   THEN 
                               tur_qtcancel[aux_contador] = tur_qtcancel[aux_contador] + 1.
                                                  ELSE
                               DO:
                                                                   /* realizado */ 
                                                                   IF   crapadp.dtfineve < TODAY   THEN
                                                                                DO:
                                                                                    /* Considerar mês da data final do evento para Realizado */ 
                                                                                    tur_qtrealiz[MONTH(crapadp.dtfineve)] = tur_qtrealiz[MONTH(crapadp.dtfineve)] + 1.
                                                                                        
                                            /* Contabiliza "Em andamento" para os meses anteriores ao mês final do evento */ 
                                                                                        IF   MONTH(crapadp.dtinieve) <> MONTH(crapadp.dtfineve)  THEN
                                                                                             DO:
                                                                                                 DO  aux_mesatual = MONTH(crapadp.dtinieve) TO MONTH(crapadp.dtfineve) - 1:
                                                 
                                                                                                         tur_andament[aux_mesatual] = tur_andament[aux_mesatual] + 1.
                                                                                        
                                                                                                 END.
                                                                                                 END.
                                                                                END.
                                                                   ELSE
                                                                        DO:
                                                                                        IF   MONTH(crapadp.dtinieve) <= MONTH(TODAY)  THEN
                                                                                             DO:
                                                                                                 /* Contabiliza "Em andamento" do mês inicial até o mês da data de consulta */ 
                                                                                                         DO  aux_mesatual = MONTH(crapadp.dtinieve) TO MONTH(TODAY):
                                                                                        
                                                                                                     /* em andamento */ 
                                                                                                 tur_andament[aux_mesatual] = tur_andament[aux_mesatual] + 1.
                                                                                                 END.
                                                                                                 END.
                                                                            END.
                                                           END.
                      END.

                 /* Participantes previstos (desconsidera eventos acrescidos) - vagas ofertadas */
                 IF   NOT CAN-FIND(FIRST craphep WHERE craphep.idevento = 0                   AND
                                                                              craphep.cdcooper = 0                   AND
                                                                                                             craphep.dtanoage = 0                   AND
                                                                                                             craphep.cdevento = 0                   AND
                                                                       craphep.cdagenci = crapadp.nrseqdig    AND 
                                                       craphep.dshiseve MATCHES "*acrescido*" NO-LOCK)   THEN
                 DO:

                    FIND FIRST crapedp WHERE crapedp.idevento = crapadp.idevento   AND 
                                             crapedp.cdcooper = crapadp.cdcooper   AND
                                             crapedp.dtanoage = crapadp.dtanoage   AND 
                                             crapedp.cdevento = crapadp.cdevento   NO-LOCK.

                      prt_qtprevis[aux_contador] = prt_qtprevis[aux_contador] + crapedp.qtmaxtur.
                 END.
                                 
             END.
             /* FIM - eventos originados no mes */
             
             /* eventos executados no mes */
             FOR EACH crapadp WHERE crapadp.idevento  = idevento           AND
                                    crapadp.cdcooper  = cdcooper           AND
                                    crapadp.dtanoage  = dtanoage           AND 
                                    crapadp.nrmeseve  = aux_contador       NO-LOCK:

                                 IF   crapadp.nrmeseve <> crapadp.nrmesage   THEN
                      DO:
                          /* recebido */
                          tur_qtrecebi[aux_contador] = tur_qtrecebi[aux_contador] + 1.

                          /* cancelado */
                          IF   crapadp.idstaeve = 2   THEN
                               tur_qtcancel[aux_contador] = tur_qtcancel[aux_contador] + 1.
                          ELSE
                               DO:
                                   /* realizado */
                                   IF   crapadp.dtfineve < TODAY   THEN
                                                           DO: 
                                                                                        tur_qtrealiz[MONTH(crapadp.dtfineve)] = tur_qtrealiz[MONTH(crapadp.dtfineve)] + 1.
                                                                                        
                                            /* Contabiliza "Em andamento" para os meses anteriores ao mês final do evento */ 
                                                                                        IF   MONTH(crapadp.dtinieve) <> MONTH(crapadp.dtfineve)  THEN
                                                                                             DO:
                                                                                                          DO   aux_mesatual = MONTH(crapadp.dtinieve) TO MONTH(crapadp.dtfineve) - 1:
                                                 
                                                                                                          tur_andament[aux_mesatual] = tur_andament[aux_mesatual] + 1.
                                                                                        
                                                                                             END.
                                                                                             END.
                                                                            END.        
                                                                   ELSE
                                                                        DO:
                                                                                    IF   MONTH(crapadp.dtinieve) <= MONTH(TODAY)  THEN
                                                                                             DO:
                                                                                         /* Contabiliza "Em andamento" do mês inicial até o mês da data de consulta */ 
                                                                                             DO   aux_mesatual = MONTH(crapadp.dtinieve) TO MONTH(TODAY):
                                                 
                                                                                                      tur_andament[aux_mesatual] = tur_andament[aux_mesatual] + 1.
                                                                                        
                                                                                                 END.
                                                                                                 END.
                                                                                END.        
                               END.
                      END.

                 /* para a frequencia minima */
                 FIND FIRST crapedp WHERE crapedp.idevento = crapadp.idevento   AND 
                                          crapedp.cdcooper = crapadp.cdcooper   AND
                                          crapedp.dtanoage = crapadp.dtanoage   AND 
                                          crapedp.cdevento = crapadp.cdevento   NO-LOCK.
                      
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
                              IF   ((crapidp.qtfaleve * 100) / crapadp.qtdiaeve) <= (100 - crapedp.prfreque) THEN DO:
                                  IF crapidp.tpinseve = 1 THEN
                                     ASSIGN prt_qtrecoop[MONTH(crapadp.dtfineve)] = prt_qtrecoop[MONTH(crapadp.dtfineve)] + 1.
                                  ELSE 
                                     ASSIGN prt_qtrecomu[MONTH(crapadp.dtfineve)] = prt_qtrecomu[MONTH(crapadp.dtfineve)] + 1.
                                  ASSIGN prt_qtrealiz[MONTH(crapadp.dtfineve)] = prt_qtrealiz[MONTH(crapadp.dtfineve)] + 1.
                              END.
                                          END.
                                 END.
                                 
             END.
             /* FIM - eventos executados no mes */
                         
             /* Questionários realizados no mes */
             FOR EACH crapkbq WHERE crapkbq.idevento        = idevento              AND
                                    crapkbq.cdcooper        = cdcooper              AND
                                    crapkbq.dtanoage        = dtanoage              AND
                                    crapkbq.tpdeitem        = 3 /*Questionários*/   AND
                                    MONTH(crapkbq.dtdenvio) = aux_contador          NO-LOCK:
                 
                 ASSIGN qst_qtrealiz[aux_contador] = qst_qtrealiz[aux_contador] + crapkbq.qtdenvio.
             END.
             /* FIM - Questionários realizados no mes */

          END. /* fim do DO .. TO */

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

