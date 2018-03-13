

/*
 *
 * Programa wpgd0034a.p - Listagem de presença, lançamento de frequencia 
 *                        (chamado a partir dos dados de wpgd0034)
 *
 */



/*****************************************************************************/
/*                                                                           */
/*   Bloco de variaveis                                                      */
/*                                                                           */
/*****************************************************************************/


DEFINE VARIABLE cookieEmUso           AS CHARACTER.
DEFINE VARIABLE permiteExecutar       AS CHARACTER.
DEFINE VARIABLE IdentificacaoDaSessao AS CHARACTER.
DEFINE VARIABLE msgsDeErro            AS CHARACTER.
DEFINE VARIABLE programaEmUso         AS CHARACTER INITIAL ["wpgd0034a"].

DEFINE VARIABLE idEvento AS INTEGER.
DEFINE VARIABLE cdCooper AS INTEGER.
DEFINE VARIABLE cdAgenci AS INTEGER.
DEFINE VARIABLE dtAnoAge AS INTEGER.
DEFINE VARIABLE cdEvento AS INTEGER.
DEFINE VARIABLE idStaIns AS INTEGER.
DEFINE VARIABLE nrSeqEve AS INTEGER.

DEFINE VARIABLE imagemDoProgrid     AS CHARACTER.
DEFINE VARIABLE imagemDaCooperativa AS CHARACTER.

DEFINE VARIABLE auxiliar      AS CHARACTER.
DEFINE VARIABLE dataInicial   AS DATE.
DEFINE VARIABLE dataFinal     AS DATE.

DEFINE VARIABLE conta          AS INTEGER.
DEFINE VARIABLE situacao       AS CHARACTER.
DEFINE VARIABLE facilitador    AS CHARACTER.
DEFINE VARIABLE facilitadores  AS CHARACTER.
DEFINE VARIABLE nomeDaAgencia  AS CHARACTER.
DEFINE VARIABLE localDoEvento1 AS CHARACTER.
DEFINE VARIABLE localDoEvento2 AS CHARACTER.

DEFINE VARIABLE ajuste AS INTEGER.

DEFINE VARIABLE corEmUso AS CHARACTER.
DEFINE VARIABLE valor    AS INTEGER.
DEFINE VARIABLE salvou   AS LOGICAL.
DEFINE VARIABLE achou    AS LOGICAL.



                           
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
    

FUNCTION erroNaValidacaoDoLogin RETURNS LOGICAL (opcao AS CHARACTER).

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


FUNCTION montaTela RETURNS LOGICAL ().

    {&out} '<html>' SKIP
           '<head>' SKIP
           '<title>Progrid - Lista de Presença</title>' SKIP.
    
    {&out} '<style>' SKIP
           '   body         ~{ background-color: #FFFFFF; }' SKIP 
           '   td           ~{ font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: bold; }' SKIP
           '   .inputFreq   ~{ height: 18px; font-size: 10px }' SKIP
           '   .tdLabel     ~{ font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: normal; }' SKIP
           '   .tdDados     ~{ font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: normal; }' SKIP
           '   .tdTitulo1   ~{ font-family: Verdana; font-size: 24px; font-weight: normal;}' SKIP
           '   .corpo       ~{ height:200px; overflow:auto; }' SKIP
           '</style>' SKIP.


    {&out} '</head>' SKIP
           '<body bgcolor="#FFFFFF" topmargin="0" marginwidth="0" marginheight="0">' SKIP
           '<div align="center">' SKIP
           '<form name="form" action="' programaEmUso '" method="post">' SKIP
           '   <input type="hidden" name="parametro1" value="' idEvento '">' SKIP 
           '   <input type="hidden" name="parametro2" value="' cdCooper '">' SKIP 
           '   <input type="hidden" name="parametro3" value="' cdAgenci '">' SKIP 
           '   <input type="hidden" name="parametro4" value="' dtAnoAge '">' SKIP 
           '   <input type="hidden" name="parametro5" value="' cdEvento '">' SKIP 
           '   <input type="hidden" name="parametro6" value="' nrSeqEve '">' SKIP.
    
    /* *** Dados do evento *** */
    {&out} '   <table border="0" cellspacing="1" cellpadding="1" width="100%">' SKIP
           '      <tr>' SKIP
           '         <td class="tdLabel" align="right">Periodo:</td>' SKIP
           '         <td class="tdDados">' IF (Crapadp.DtFinEve - Crapadp.DtIniEve) <= 1 THEN STRING(Crapadp.DtIniEve,"99/99/9999") ELSE (STRING(Crapadp.DtIniEve,"99/99/9999") + ' à ' + STRING(Crapadp.DtFinEve,"99/99/9999")) '</td>' SKIP
           '         <td class="tdLabel" align="right">Horário:</td>' SKIP
           '         <td class="tdDados">' Crapadp.DsHroeve '</td>' SKIP
           '         <td class="tdLabel" align="right">Caga horária:</td>' SKIP
           '         <td class="tdDados">' Gnappdp.QtcarHor ' horas</td>' SKIP
           '      <tr>' SKIP
           '   </table>' SKIP.

    /* *** Corpo da listagem *** */
    {&out} '   <table border="0" cellspacing="0" cellpadding="0" width="100%">' SKIP
           '      <tr>' SKIP
           '         <td class="tdLabel" align="center" style="width:16px;  height=20px" background="/cecred/images/menu/fnd_title.jpg">N°</td>' SKIP
           '         <td class="tdLabel" align="center" valign="center" style="width:6px; height=20px" background="/cecred/images/menu/fnd_title.jpg"><img src="/cecred/images/geral/div.gif" width="2px" height="16px"></td>' SKIP
           '         <td class="tdLabel" align="center" style="width:180px; height=22px" background="/cecred/images/menu/fnd_title.jpg">Nome do participante</td>' SKIP
           '         <td class="tdLabel" align="center" valign="center" style="width:8px;  height=20px" background="/cecred/images/menu/fnd_title.jpg"><img src="/cecred/images/geral/div.gif" width="2px" height="16px"></td>' SKIP
           '         <td class="tdLabel" align="center" style="width:50px;  height=22px" background="/cecred/images/menu/fnd_title.jpg">N°. conta</td>' SKIP
           '         <td class="tdLabel" align="center" valign="center" style="width:5px;  height=20px" background="/cecred/images/menu/fnd_title.jpg"><img src="/cecred/images/geral/div.gif" width="2px" height="16px"></td>' SKIP.

    {&out} '         <td class="tdLabel" align="center" style="width:60px;  height=22px" background="/cecred/images/menu/fnd_title.jpg">Faltas</td>' SKIP.
    
    {&out} '      </tr>' SKIP
           '      <tr>' SKIP
           '         <td colspan="7" align="center">' SKIP
           '            <div class="corpo">' SKIP
           '               <table border="0" cellspacing="0" cellpadding="0" width="100%">' SKIP.

    ASSIGN corEmUso = "#FFFFFF".
    FOR EACH Crapidp WHERE Crapidp.NrSeqEve = nrSeqEve AND
                           Crapidp.IdStaIns = idStaIns EXCLUSIVE-LOCK
                     BY Crapidp.NmInsEve:
        ASSIGN conta = conta + 1.
        IF corEmUso = "#FFFFFF"
           THEN
               ASSIGN corEmUso = "#F7F7F7".
           ELSE
               ASSIGN corEmuso = "#FFFFFF".
        {&out} '                  <tr>' SKIP
               '                     <td class="tdDados" style="width:20px; background-color: ' corEmUso '" align="center">' conta FORMAT "99" '</td>' SKIP
               '                     <td class="tdLabel" align="center" valign="center" style="width:5px;  height=20px; background-color: ' corEmUso '"> </td>' SKIP
               '                     <td class="tdDados" style="width:200px; background-color: ' corEmUso '">' Crapidp.NmInsEve '</td>' SKIP
               '                     <td class="tdLabel" align="center" valign="center" style="width:5px;  height=20px; background-color: ' corEmUso '"> </td>' SKIP
               '                     <td class="tdDados" style="width:50px; background-color: ' corEmUso '" align="center">' (IF Crapidp.NrdConta > 0 THEN STRING(Crapidp.NrdConta,"zzzz,zzz,9") ELSE '&nbsp;') '</td>' SKIP
               '                     <td class="tdLabel" align="center" valign="center" style="width:5px;  height=20px; background-color: ' corEmUso '"> </td>' SKIP.

        /* *** Atualiza dados da frequencia *** */
        IF REQUEST_METHOD = "POST"
           THEN
               DO:
                  ASSIGN valor = INTEGER(GET-VALUE("qtfaleve" + STRING(conta,"99"))) NO-ERROR.
                  IF NOT ERROR-STATUS:ERROR
                     THEN  
                         ASSIGN Crapidp.QtFalEve = valor
                                salvou           = YES.
               END.

        {&out} '         <td class="tdDados" style="width:50px; background-color: ' corEmUso '" align="center"><input class="inputFreq" type="text" name="qtfaleve' STRING(conta,"99") '" value="' IF Crapidp.QtFalEve = 0 THEN "" ELSE STRING(Crapidp.QtFalEve) '" size="3" maxlength="3"></td>' SKIP
               '      </tr>' SKIP.
    END.
    {&out} '               </table>' SKIP
           '            </div>' SKIP
           '         </td>' SKIP
           '      </tr>' SKIP  
           '   </table>' SKIP.

    {&out} '</form>' SKIP
           '</div>' SKIP.
        
    {&out} '<script language="Javascript">' SKIP.

    IF conta > 0
       THEN
           {&out} '   parent.parent.mainFrame.ativa("sim");' SKIP.
       ELSE 
           {&out} '   parent.parent.mainFrame.ativa("nao");' SKIP.
           
    IF salvou
       THEN
           {&out} '   alert("Lançamentos de freqüência salvos com sucesso.");' SKIP.

    {&out} '</script>' SKIP.

    {&out} '</body>' SKIP
           '</html>' SKIP.

    RETURN TRUE.

END FUNCTION. /* montaTela RETURNS LOGICAL () */


FUNCTION mostraApenasCabecalho RETURNS LOGICAL ().

    {&out} '<html>' SKIP
           '<head>' SKIP
           '<title>Progrid - Lista de Presença</title>' SKIP.

    {&out} '<style>' SKIP
           '   body         ~{ background-color: #FFFFFF; }' SKIP 
           '   td           ~{ font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: bold; }' SKIP
           '   .inputFreq   ~{ height: 18px; font-size: 10px }' SKIP
           '   .tdLabel     ~{ font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: normal; }' SKIP
           '   .tdDados     ~{ font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: normal; }' SKIP
           '   .tdTitulo1   ~{ font-family: Verdana; font-size: 24px; font-weight: normal;}' SKIP
           '   .corpo       ~{ height:200px; overflow:auto; }' SKIP
           '</style>' SKIP.


    {&out} '</head>' SKIP
           '<body bgcolor="#FFFFFF" topmargin="0" marginwidth="0" marginheight="0">' SKIP
           '<div align="center">' SKIP.
    
    /* *** Dados do evento *** */
    {&out} '   <table border="0" cellspacing="1" cellpadding="1" width="100%">' SKIP
           '      <tr>' SKIP
           '         <td class="tdLabel" align="right">Periodo:</td>' SKIP
           '         <td class="tdDados">?</td>' SKIP
           '         <td class="tdLabel" align="right">Horário:</td>' SKIP
           '         <td class="tdDados"> </td>' SKIP
           '         <td class="tdLabel" align="right">Caga horária:</td>' SKIP
           '         <td class="tdDados">? horas</td>' SKIP
           '      <tr>' SKIP
           '   </table>' SKIP.

    /* *** Corpo da listagem *** */
    {&out} '   <table border="0" cellspacing="0" cellpadding="0" width="100%">' SKIP
           '      <tr>' SKIP
           '         <td class="tdLabel" align="center" style="width:16px;  height=20px" background="/cecred/images/menu/fnd_title.jpg">N°</td>' SKIP
           '         <td class="tdLabel" align="center" valign="center" style="width:6px; height=20px" background="/cecred/images/menu/fnd_title.jpg"><img src="/cecred/images/geral/div.gif" width="2px" height="16px"></td>' SKIP
           '         <td class="tdLabel" align="center" style="width:180px; height=22px" background="/cecred/images/menu/fnd_title.jpg">Nome do participante</td>' SKIP
           '         <td class="tdLabel" align="center" valign="center" style="width:8px;  height=20px" background="/cecred/images/menu/fnd_title.jpg"><img src="/cecred/images/geral/div.gif" width="2px" height="16px"></td>' SKIP
           '         <td class="tdLabel" align="center" style="width:50px;  height=22px" background="/cecred/images/menu/fnd_title.jpg">N°. conta</td>' SKIP
           '         <td class="tdLabel" align="center" valign="center" style="width:5px;  height=20px" background="/cecred/images/menu/fnd_title.jpg"><img src="/cecred/images/geral/div.gif" width="2px" height="16px"></td>' SKIP.

    {&out} '         <td class="tdLabel" align="center" style="width:60px;  height=22px" background="/cecred/images/menu/fnd_title.jpg">Faltas</td>' SKIP.
          
    {&out} '      </tr>' SKIP
           '   </table>' SKIP.

    {&out} '</div>' SKIP
           '</body>' SKIP
           '</html>' SKIP.
          

    RETURN TRUE.

END FUNCTION. /* mostraApenasCabecalho RETURNS LOGICAL () */



/*****************************************************************************/
/*                                                                           */
/*   Bloco de principal do programa                                          */
/*                                                                           */
/*****************************************************************************/


output-content-type("text/html").

ASSIGN cookieEmUso = GET-COOKIE("cookie-usuario-em-uso").
FIND Gnapses WHERE Gnapses.IdSessao = cookieEmUso NO-LOCK NO-ERROR.
RUN PermissaoDeAcesso("", OUTPUT IdentificacaoDaSessao, OUTPUT permiteExecutar).

IF permiteExecutar = "1" OR permiteExecutar = "2"
   THEN
       erroNaValidacaoDoLogin(permiteExecutar).
   ELSE
       DO:
          IF GET-VALUE("acao") = "cabecalho"
             THEN
                 mostraApenasCabecalho().
             ELSE 
                 IF GET-VALUE("acao") = "telabranca" 
                    THEN
                        DO:
                           {&out} '<html>' SKIP
                                  '<head>' SKIP
                                  '<title>Progrid - Lista de Presença</title>' SKIP
                                  '</head>' SKIP
                                  '<body bgcolor="#FFFFFF">' SKIP
                                  '   &nbsp; ' SKIP
                                  '</body>' SKIP
                                  '</html>' SKIP.
                         END.
                    ELSE
                        DO:
                           ASSIGN idEvento = INTEGER(GET-VALUE("parametro1"))
                                  cdCooper = INTEGER(GET-VALUE("parametro2"))
                                  cdAgenci = INTEGER(GET-VALUE("parametro3"))
                                  dtAnoAge = INTEGER(GET-VALUE("parametro4"))
                                  cdEvento = INTEGER(GET-VALUE("parametro5"))
                                  nrSeqEve = INTEGER(GET-VALUE("parametro6"))
                                  idStaIns = 2.
                
                           /* *** 1-Pendente,2-Confirmado,3-Desistente,4-Excedente,5-Cancelado *** */
                           ASSIGN situacao = "Pendente,Confirmado,Desistente,Excedente,Cancelado".
                           
                           /* *** Dados do PAC *** */
                           FIND Crapage WHERE Crapage.CdCooper = cdCooper AND Crapage.CdAgenci = cdAgenci NO-LOCK NO-ERROR.
                           IF AVAILABLE Crapage 
                              THEN
                                  ASSIGN nomeDaAgencia = Crapage.NmResAge + " - " + Crapage.NmExtAge.
                              ELSE
                                  ASSIGN nomeDaAgencia = "Agencia " + STRING(cdAgenci,"999").
                
                           /* ***  Informações da Agenda do Progrid por PAC *** */
                           FIND Crapadp WHERE Crapadp.NrSeqDig = nrSeqEve NO-LOCK NO-ERROR.
                           IF NOT AVAILABLE Crapadp 
                              THEN
                                  ASSIGN msgsDeErro = msgsDeErro + "-> Registro Crapadp não esta disponivel.<br>".
                              ELSE
                                  DO:
                                     ASSIGN dataInicial = Crapadp.DtIniEve
                                            dataFinal   = Crapadp.DtFinEve
                                            cdEvento    = Crapadp.CdEvento.
                                  END.
                            
                           /* *** Localiza evento *** */
                           FIND Crapedp WHERE Crapedp.IdEvento = idEvento AND
                                              Crapedp.CdCooper = cdCooper AND
                                              Crapedp.DtAnoAge = dtAnoAge AND
                                              Crapedp.CdEvento = cdEvento NO-LOCK NO-ERROR.
                           IF NOT AVAILABLE Crapedp
                              THEN
                                  ASSIGN msgsDeErro = msgsDeErro + "-> Registro Crapedp não esta disponivel.<br>".
                           
                           /* *** Localiza custo do evento *** */
                           FIND Crapcdp WHERE Crapcdp.IdEvento = idEvento AND
                                              Crapcdp.CdCooper = cdCooper AND
                                              Crapcdp.CdAgenci = cdAgenci AND
                                              Crapcdp.DtAnoAge = dtAnoAge AND
                                              Crapcdp.TpCusEve  = 1 AND       /* direto */
                                              Crapcdp.CdEvento = cdEvento AND
                                              Crapcdp.CdCusEve = 1 /* honorários */  NO-LOCK NO-ERROR.
                           IF NOT AVAILABLE Crapcdp
                              THEN
                                  ASSIGN msgsDeErro = msgsDeErro + "-> Registro Crapcdp não esta disponivel.<br>".
                
                           /* *** Localiza proposta do evento *** */
                           FIND Gnappdp WHERE Gnappdp.IdEvento = idEvento AND
                                              Gnappdp.CdCooper = 0 AND
                                              Gnappdp.NrCpfCgc = Crapcdp.NrCpfCgc AND
                                              Gnappdp.NrPropos = Crapcdp.NrPropos NO-LOCK NO-ERROR.
                           IF NOT AVAILABLE Gnappdp
                              THEN
                                  ASSIGN msgsDeErro = msgsDeErro + "-> Registro Gnappdp não esta disponivel.<br>".              
                
                           montaTela().
                        END.
 
       END.



/*****************************************************************************/
/*                                                                           */
/*   Bloco de procdures                                                      */
/*                                                                           */
/*****************************************************************************/

PROCEDURE PermissaoDeAcesso :

    {includes/wpgd0009.i}

END PROCEDURE.

