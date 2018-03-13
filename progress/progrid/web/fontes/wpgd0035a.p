/* ..............................................................................................

  Programa wpgd0035a.p - Listagem de certificados, seleção de usuários para impressão
                         (chamado a partir dos dados de wpgd0035)

  Alterações: 03/11/2008 - Inclusao widget-pool (martin)

             10/12/2008 - Melhoria de performance para a tabela gnapses (Evandro).
			 
			 05/06/2012 - Adaptação dos fontes para projeto Oracle. Alterado
						  busca na gnapses de CONTAINS para MATCHES (Guilherme Maba).
                          
             19/07/2012 - Alterações para trazer valores iniciais aos campos de
                          Ministrante e Assinatura (Lucas).

             18/06/2014 - Incluir validacao para listar somente pessoa fisica
                          Softdesk 153498 (Lucas R)
                          
             13/07/2015 - Adicionar variavel conta na funcao imprimir(), pois o for
                          estava no loop até o registro 100 (Lucas Ranghetti #307054)

              15/12/2016 - Removido campo de assinatura, Prj. 229 Melhorias Progrid (Jean Michel).
              
...................................................................................................*/

create widget-pool.

/*****************************************************************************/
/*                                                                           */
/*   Bloco de variaveis                                                      */
/*                                                                           */
/*****************************************************************************/

DEFINE VARIABLE cookieEmUso           AS CHARACTER.
DEFINE VARIABLE permiteExecutar       AS CHARACTER.
DEFINE VARIABLE IdentificacaoDaSessao AS CHARACTER.
DEFINE VARIABLE msgsDeErro            AS CHARACTER.
DEFINE VARIABLE programaEmUso         AS CHARACTER INITIAL ["wpgd0035a"].

DEFINE VARIABLE idEvento AS INTEGER.
DEFINE VARIABLE cdCooper AS INTEGER.
DEFINE VARIABLE cdAgenci AS INTEGER.
DEFINE VARIABLE dtAnoAge AS INTEGER.
DEFINE VARIABLE cdEvento AS INTEGER.
DEFINE VARIABLE idStaIns AS INTEGER.
DEFINE VARIABLE nrSeqEve AS INTEGER.

DEFINE VARIABLE imagemDoProgrid     AS CHARACTER.
DEFINE VARIABLE imagemDaCooperativa AS CHARACTER.

DEFINE VARIABLE auxiliar          AS CHARACTER.
DEFINE VARIABLE dataInicial       AS DATE.
DEFINE VARIABLE dataFinal         AS DATE.
DEFINE VARIABLE numDeDiasDoEvento AS INTEGER.
DEFINE VARIABLE frequenciaMinima  AS INTEGER.

DEFINE VARIABLE conta          AS INTEGER.
DEFINE VARIABLE situacao       AS CHARACTER.
DEFINE VARIABLE facilitador    AS CHARACTER.
DEFINE VARIABLE facilitadores  AS CHARACTER.
DEFINE VARIABLE nomeDaAgencia  AS CHARACTER.
DEFINE VARIABLE localDoEvento1 AS CHARACTER.
DEFINE VARIABLE localDoEvento2 AS CHARACTER.
/* Lucas */
DEFINE VARIABLE nmminist AS CHARACTER.
DEFINE VARIABLE nmdircop AS CHARACTER.
                    
DEFINE VARIABLE ajuste AS INTEGER.

DEFINE VARIABLE corEmUso AS CHARACTER.
DEFINE VARIABLE valor    AS INTEGER.
DEFINE VARIABLE salvou   AS LOGICAL.

DEFINE VARIABLE linha     AS CHARACTER.
DEFINE VARIABLE assinar1  AS CHARACTER.
DEFINE VARIABLE assinar2  AS CHARACTER.

                           
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

    DEFINE VARIABLE aux_qtcarhor AS DECIMAL    NO-UNDO.
    DEFINE VARIABLE aux_periodo  AS CHARACTER  FORMAT "x(10)" INIT "Não definido" NO-UNDO.
    DEFINE VARIABLE aux_dtemcert AS CHARACTER  FORMAT "x(08)"                     NO-UNDO.
    
    IF AVAIL gnappdp THEN 
       aux_qtcarhor = gnappdp.qtcarhor.
    ELSE
       aux_qtcarhor = 0.

    /* As datas devem estar preenchidas */
    IF  Crapadp.DtFinEve <> ?  AND
        Crapadp.DtIniEve <> ?  THEN
        DO:
            /* Somente um dia */
            IF (Crapadp.DtFinEve - Crapadp.DtIniEve) < 1 THEN
                aux_periodo = STRING(Crapadp.DtIniEve,"99/99/9999").
            /* Mais de um dia */
            ELSE
                aux_periodo = STRING(Crapadp.DtIniEve,"99/99/9999") +
                              ' a ' +
                              STRING(Crapadp.DtFinEve,"99/99/9999").
        END.

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
           '   .corpo       ~{ height:160px; overflow:auto; }' SKIP
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
           '         <td class="tdDados">' aux_periodo '</td>' SKIP
           '         <td class="tdLabel" align="right">Horário:</td>' SKIP
           '         <td class="tdDados">' Crapadp.DsHroeve '</td>' SKIP
           '         <td class="tdLabel" align="right">Caga horária:</td>' SKIP
           '         <td class="tdDados">' aux_qtcarhor ' horas</td>' SKIP
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

    {&out} '         <td class="tdLabel" align="center" style="width:60px;  height=22px" background="/cecred/images/menu/fnd_title.jpg">Imp?</td>' SKIP.
    
    {&out} '      </tr>' SKIP
           '      <tr>' SKIP
           '         <td colspan="7" align="center">' SKIP
           '            <div class="corpo">' SKIP
           '               <table border="0" cellspacing="0" cellpadding="0" width="100%">' SKIP.

    ASSIGN corEmUso = "#FFFFFF".
    FOR EACH Crapidp WHERE Crapidp.NrSeqEve = nrSeqEve AND
                           Crapidp.IdStaIns = idStaIns NO-LOCK,
        EACH crapass WHERE crapass.cdcooper = crapidp.cdcooper AND
                           crapass.nrdconta = crapidp.nrdconta AND
                           crapass.inpessoa = 1 NO-LOCK BY Crapidp.NmInsEve:
        ASSIGN conta = conta + 1
                aux_dtemcert = IF crapidp.dtemcert <> ? THEN
                                 STRING(crapidp.dtemcert,"99/99/99")
                              ELSE
                                 "". 
        IF corEmUso = "#FFFFFF"
           THEN
               ASSIGN corEmUso = "#F7F7F7".
           ELSE
               ASSIGN corEmuso = "#FFFFFF".

        {&out} '                  <tr>' SKIP
               '                     <td class="tdDados" style="width:20px; background-color: ' corEmUso '" align="center">' conta FORMAT "999" '</td>' SKIP
               '                     <td class="tdLabel" align="center" valign="center" style="width:5px;  height=20px; background-color: ' corEmUso '"> </td>' SKIP
               '                     <td class="tdDados" style="width:200px; background-color: ' corEmUso '">' Crapidp.NmInsEve '</td>' SKIP
               '                     <td class="tdLabel" align="center" valign="center" style="width:5px;  height=20px; background-color: ' corEmUso '"> </td>' SKIP
               '                     <td class="tdDados" style="width:50px; background-color: ' corEmUso '" align="center">' (IF Crapidp.NrdConta > 0 THEN STRING(Crapidp.NrdConta,"zzzz,zzz,9") ELSE '&nbsp;') '</td>' SKIP
               '                     <td class="tdLabel" align="center" valign="center" style="width:5px;  height=20px; background-color: ' corEmUso '"> </td>' SKIP.

        /* Lucas */
        FIND crapcop WHERE crapcop.cdcooper = cdCooper NO-LOCK NO-ERROR NO-WAIT.
        
        IF AVAIL crapcop THEN
            ASSIGN nmdircop = crapcop.nmtitcop.

        FIND FIRST crapcdp WHERE crapcdp.cdevento = cdEvento AND
                                 crapcdp.cdcooper = cdCooper AND
                                 crapcdp.cdagenci = cdAgenci And
                                 crapcdp.dtanoage = dtAnoAge NO-LOCK NO-ERROR NO-WAIT.
        IF  AVAIL crapcdp THEN
            DO:
                FOR EACH gnfacep WHERE gnfacep.cdcooper = 0  AND
                                       gnfacep.nrpropos = crapcdp.nrpropos NO-LOCK:
                        
                    FOR EACH gnapfep WHERE gnapfep.cdcooper = 0  AND
                                           gnapfep.nrcpfcgc = gnfacep.nrcpfcgc AND
                                           gnapfep.cdfacili = gnfacep.cdfacili NO-LOCK :
                        
                        ASSIGN nmminist = gnapfep.nmfacili.
                   END.
                END.
            END.

        /* Se percentual de faltas passar do percentual mínimo exigido, nao pode certificar */
        IF ((crapidp.qtfaleve * 100) / numdediasdoevento) > (100 - frequenciaMinima) THEN
               {&out} '                     <td class="tdDados" style="width:65px; background-color: ' corEmUso '" align="left"><input class="inputFreq" type="checkbox" name="reg' conta '" value="Sim" disabled title="Frequencia insuficiente.Certificado bloqueado.">&nbsp;' aux_dtemcert '</td>' SKIP.        
           ELSE
               {&out} '                     <td class="tdDados" style="width:65px; background-color: ' corEmUso '" align="left"><input class="inputFreq" type="checkbox" name="reg' conta '" value="Sim">&nbsp;' aux_dtemcert '</td>' SKIP.
        {&out} '                  </tr>' SKIP.
    END.

    {&out} '               </table>' SKIP
           '            </div>' SKIP
           '         </td>' SKIP
           '      </tr>' SKIP
           '      <tr>' SKIP                                                                                                      
/*           '         <td colspan="7" class="tdDados">Assinatura: <input type="text" class="inputFreq" name="assinar1" value="' nmdircop '" size="30" maxlength="50">' SKIP
           '                                        Ministrante: <input type="text" class="inputFreq" name="assinar2" value="' nmminist '" size="30" maxlength="50">' SKIP
           '         </td>' SKIP*/
           '         <td colspan="7" class="tdDados">Ministrante: <input type="text" class="inputFreq" name="assinar2" value="' nmminist '" size="30" maxlength="50"></td>' SKIP
           '      </tr>' SKIP
           '   </table>' SKIP.

    {&out} '</form>' SKIP
           '</div>' SKIP.

    ASSIGN linha = 'wpgd0035b?parametro1=1&parametro2=' + STRING(cdCooper) + '&parametro3=' + STRING(cdAgenci) + '&parametro4=' + STRING(dtAnoAge) + '&parametro5=' + STRING(cdEvento) + '&parametro6=' + STRING(nrSeqEve)
           linha = URL-ENCODE(linha,"default").

    {&out} '<script language="Javascript">' SKIP.
           
    {&out} '   function imprimir()' SKIP
           '      ~{' SKIP
           '         var lista = "";' SKIP
           '         for (i=0; i <= "' conta '"; i++) ' SKIP
           '             ~{' SKIP
           '                campo = eval("document.form.reg" + i); ' SKIP        
           '                if (campo!=null)' SKIP
           '                   if (campo.checked)' SKIP
           '                     lista = lista + i + "I";' SKIP
           '             }' SKIP 
           '         if (lista=="")' SKIP
           '                alert("-> Não foi selecionado nenhum participante.");' SKIP
           '            else ' SKIP
           '                ~{' SKIP
           '                   linha = "' linha '" + "&assinar1=0&assinar2=" + document.form.assinar2.value + "&registros=" + lista;' SKIP
           '                   impC = window.open(linha,"impC","toolbar=no,location=no,diretories=no,status=yes,menubar=yes,scrollbars=yes,resizable=yes,top=10,left=10,width=640,height=400");' SKIP
           '                }' SKIP
           '      } ' SKIP.

    IF conta > 0
       THEN
           {&out} '   parent.parent.mainFrame.ativa("sim");' SKIP.
       ELSE 
           {&out} '   parent.parent.mainFrame.ativa("nao");' SKIP.

    {&out} '</script>' SKIP.

    {&out} '</body>' SKIP
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

IF permiteExecutar = "1" OR permiteExecutar = "2"
   THEN
       erroNaValidacaoDoLogin(permiteExecutar).
   ELSE
       DO:
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
        
                    /* *** Dados do PA *** */
                    FIND Crapage WHERE Crapage.CdCooper = cdCooper AND Crapage.CdAgenci = cdAgenci NO-LOCK NO-ERROR.
                    IF AVAILABLE Crapage 
                       THEN
                           ASSIGN nomeDaAgencia = Crapage.NmResAge + " - " + Crapage.NmExtAge.
                       ELSE
                           ASSIGN nomeDaAgencia = "Agencia " + STRING(cdAgenci,"999").
        
                    /* ***  Informações da Agenda do Progrid por PA *** */
                    FIND Crapadp WHERE Crapadp.NrSeqDig = nrSeqEve NO-LOCK NO-ERROR.
                    IF NOT AVAILABLE Crapadp 
                       THEN
                           ASSIGN msgsDeErro = msgsDeErro + "-> Registro Crapadp não esta disponivel.<br>".
                       ELSE
                           ASSIGN dataInicial       = Crapadp.DtIniEve
                                  dataFinal         = Crapadp.DtFinEve
                                  cdEvento          = Crapadp.CdEvento
                                  numDeDiasDoEvento = Crapadp.QtDiaEve. 
        
                    /* *** Localiza evento *** */
                    FIND Crapedp WHERE Crapedp.IdEvento = idEvento AND
                                       Crapedp.CdCooper = cdCooper AND
                                       Crapedp.DtAnoAge = dtAnoAge AND
                                       Crapedp.CdEvento = cdEvento NO-LOCK NO-ERROR.
                    IF NOT AVAILABLE Crapedp THEN
                       ASSIGN msgsDeErro = msgsDeErro + "-> Registro Crapedp não esta disponivel.<br>".
                    ELSE
                       frequenciaMinima = crapedp.prfreque.
        
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
        
                    /* *** Localiza e trata facilitador *** */
                    FOR EACH Gnfacep WHERE Gnfacep.IdEvento = idEvento AND
                                           Gnfacep.CdCooper = 0 AND
                                           Gnfacep.NrCpfCgc = Gnappdp.NrcpfCgc AND
                                           Gnfacep.NrPropos = Gnappdp.NrPropos NO-LOCK:

                        FIND Gnapfep WHERE Gnapfep.IdEvento = idEvento AND
                                           Gnapfep.CdCooper = 0 AND
                                           Gnapfep.NrCpfCgc = Gnfacep.NrCpfCgc AND
                                           Gnapfep.CdFacili = Gnfacep.CdFacili NO-LOCK NO-ERROR.
                        IF AVAILABLE Gnapfep
                           THEN
                               ASSIGN facilitadores = facilitadores + Gnapfep.nmfacili + ",".
                    END.
                    IF LENGTH(facilitadores) > 0
                       THEN
                           ASSIGN facilitadores = SUBSTRING(facilitadores,1,LENGTH(facilitadores) - 1).
                    IF NUM-ENTRIES(facilitadores) > 1
                       THEN
                           ASSIGN facilitador = "Diversos".
                       ELSE
                           ASSIGN facilitador = facilitadores
                                  facilitadores = "".

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

