/*
 *
 * Programa wpgd0033a.p - Listagem de presen�a (chamado a partir dos dados de
                                                wpgd0033)
 * Ultima altera��o: 14/06/2006 - Rosangela - tarefa 7459.
                
                     24/01/2008 - Inclu�do campo Refer�ncia (Diego).
                     
                     04/11/2008 - Incluido widget-pool.

                     10/12/2008 - Melhoria de performance para a tabela
                                  gnapses (Evandro).
                     
                     05/05/2009 - Utilizar cdcooper = 0 nas consultas (David).
                                         
                     05/06/2012 - Adapta��o dos fontes para projeto Oracle.
                                  Alterado busca na gnapses de CONTAINS para
                                  MATCHES (Guilherme Maba).

                     28/11/2012 - Substituir tabela "gncoper" por "crapcop"
                                  (David Kruger).
                                  
                     04/04/2013 - Altera��o para receber logo na alto vale,
                                  recebendo nome de viacrediav e buscando com
                                  o respectivo nome (David Kruger).
                     
                     11/09/2013 - Nova forma de chamar as ag�ncias, de PAC agora 
                                  a escrita ser� PA (Andr� Euz�bio - Supero).             

 */                         
/*****************************************************************************/
/*                                                                           */
/*   Bloco de variaveis                                                      */
/*                                                                           */
/*****************************************************************************/

create widget-pool.

DEFINE VARIABLE cookieEmUso           AS CHARACTER.
DEFINE VARIABLE permiteExecutar       AS CHARACTER.
DEFINE VARIABLE IdentificacaoDaSessao AS CHARACTER.
DEFINE VARIABLE msgsDeErro            AS CHARACTER.

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
DEFINE VARIABLE referencia     AS CHARACTER.

DEFINE VARIABLE ajuste         AS INTEGER.
DEFINE VARIABLE aux_linhas     AS INTEGER.
DEFINE VARIABLE aux_tpevento   AS CHARACTER.

DEFINE VARIABLE aux_nmrescop   AS CHARACTER.
                           
/*****************************************************************************/
/*                                                                           */
/*   Bloco de includes                                                       */
/*                                                                           */
/*****************************************************************************/

{src/web/method/wrap-cgi.i}

/*****************************************************************************/
/*                                                                           */
/*   Bloco de fun�oes                                                        */
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
           '<title>Progrid - Lista de Presen�a</title>' SKIP.

    {&out} '<style>' SKIP
           '   body         ~{ background-color: #FFFFFF; }' SKIP
           '   td           ~{ font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: bold; }' SKIP
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

    /* *** Logo *** */
    {&out} '   <table border="0" cellspacing="0" cellpadding="0" width="100%" class="tab1">' SKIP
           '      <tr>' SKIP
           '         <td align="center"><img src="' imagemDoProgrid '" border="0"></td>' SKIP
           '         <td class="tdTitulo1" colspan="4" align="center">Ficha de Presen�a</td>' SKIP
           '         <td align="center"><img src="' imagemDaCooperativa '" border="0"></td>' SKIP
           '      <tr>' SKIP
           '   </table>' SKIP. 

    {&out} '<br>' SKIP.

    
    /* Cabecalho para o PROGRID */
    IF   idevento = 1   THEN 
         /* *** Dados do evento *** */
         {&out} '   <table border="0" cellspacing="1" cellpadding="1" width="100%">' SKIP
                '      <tr>' SKIP
                '         <td class="tdLabel" align="right">Pa:</td>' SKIP
                '         <td class="tdLabel" colspan="3">' nomeDaAgencia '</td>' SKIP
                '         <td class="tdLabel" align="right">Tipo de Evento:</td>' SKIP
                '         <td class="tdDados">' aux_tpevento '</td>' SKIP
                '      <tr>' SKIP
                '      <tr>' SKIP
                '         <td class="tdLabel" align="right">Evento:</td>' SKIP
                '         <td class="tdDados" colspan="3">' Crapedp.NmEvento '</td>' SKIP
                '         <td class="tdLabel" align="right">Periodo:</td>' SKIP
                '         <td class="tdDados">' IF (Crapadp.DtFinEve - Crapadp.DtIniEve) <= 1 THEN STRING(Crapadp.DtIniEve,"99/99/9999") ELSE (STRING(Crapadp.DtIniEve,"99/99/9999") + ' a ' + STRING(Crapadp.DtFinEve,"99/99/9999")) '</td>' SKIP
                '      <tr>' SKIP
                '      <tr>' SKIP
                '         <td class="tdLabel" align="right">Ministrante:</td>' SKIP
                '         <td class="tdDados">' facilitador '</td>' SKIP
                '         <td class="tdLabel" align="right">Hor�rio:</td>' SKIP
                '         <td class="tdDados">' Crapadp.DsHroeve '</td>' SKIP
                '         <td class="tdLabel" align="right">Carga hor�ria:</td>' SKIP
                '         <td class="tdDados">' Gnappdp.QtcarHor ' horas</td>' SKIP
                '      <tr>' SKIP
                '      <tr>' SKIP
                '         <td class="tdLabel" align="right">Local do evento:</td>' SKIP
                '         <td class="tdDados" colspan="6">' localDoEvento1 '</td>' SKIP
                '      <tr>' SKIP
                '      <tr>' SKIP
                '         <td class="tdLabel" align="right"> </td>' SKIP
                '         <td class="tdDados" colspan="6">' localDoEvento2 '</td>' SKIP
                '      <tr>' SKIP
                '      <tr>' SKIP
                '         <td class="tdLabel" align="right">Refer�ncia: </td>' SKIP
                '         <td class="tdDados" colspan="6">' referencia '</td>' SKIP
                '      <tr>' SKIP
                    '   </table>' SKIP.
    ELSE
    /* Cabecalho para as ASSEMBLEIAS */
        /* *** Dados do evento *** */
        {&out} '   <table border="0" cellspacing="1" cellpadding="1" width="100%">' SKIP
               '      <tr>' SKIP
               '         <td class="tdLabel" align="right">Pa:</td>' SKIP
               '         <td class="tdLabel" colspan="3">' nomeDaAgencia '</td>' SKIP
               '         <td class="tdLabel" align="right">Tipo de Evento:</td>' SKIP
               '         <td class="tdDados">' aux_tpevento '</td>' SKIP
               '      <tr>' SKIP
               '      <tr>' SKIP
               '         <td class="tdLabel" align="right">Evento:</td>' SKIP
               '         <td class="tdDados" colspan="3">' Crapedp.NmEvento '</td>' SKIP
               '         <td class="tdLabel" align="right">Periodo:</td>' SKIP
               '         <td class="tdDados">' IF (Crapadp.DtFinEve - Crapadp.DtIniEve) <= 1 THEN STRING(Crapadp.DtIniEve,"99/99/9999") ELSE (STRING(Crapadp.DtIniEve,"99/99/9999") + ' a ' + STRING(Crapadp.DtFinEve,"99/99/9999")) '</td>' SKIP
               '      <tr>' SKIP
               '      <tr>' SKIP
               '         <td class="tdLabel" align="right">Hor�rio:</td>' SKIP
               '         <td class="tdDados">' Crapadp.DsHroeve '</td>' SKIP
               '      <tr>' SKIP
               '      <tr>' SKIP
               '         <td class="tdLabel" align="right">Local do evento:</td>' SKIP
               '         <td class="tdDados" colspan="6">' localDoEvento1 '</td>' SKIP
               '      <tr>' SKIP
               '      <tr>' SKIP
               '         <td class="tdLabel" align="right"> </td>' SKIP
               '         <td class="tdDados" colspan="6">' localDoEvento2 '</td>' SKIP
               '      <tr>' SKIP
                           '      <tr>' SKIP
               '         <td class="tdLabel" align="right">Refer�ncia: </td>' SKIP
               '         <td class="tdDados" colspan="6">' referencia '</td>' SKIP
               '      <tr>' SKIP
               '   </table>' SKIP.

    {&out} '<br>' SKIP.

    /* *** Corpo da listagem *** */
    {&out} '   <table border="1" cellspacing="0" cellpadding="2" width="100%" class="tab1">' SKIP
           '      <tr>' SKIP
           '         <td class="tdLabel" width=5% align="center">N�</td>' SKIP
           '         <td class="tdLabel" width=35% align="center">Nome do participante</td>' SKIP
           '         <td class="tdLabel" width=10% align="center">Conta</td>' SKIP.
    /*Controle para inserir colunas na linha de assinatura do participante*/
    IF  crapadp.qtdiaeve < 1 OR crapedp.tpevento = 4
        THEN
            {&out} '<td class="tdLabel" width=50% align="center" colspan="7">Assinatura do participante</td>' SKIP.
        ELSE   
            IF  crapadp.qtdiaeve = 1 
                THEN
                {&out} '<td class="tdDados" width=5%>&nbsp</td>'  SKIP
                       '<td class="tdLabel" width=50% align="center" colspan="7">Assinatura do participante</td>' SKIP.
            ELSE
                IF  crapadp.qtdiaeve = 2 
                    THEN
                        {&out} '<td class="tdDados" width=5%>&nbsp</td>'  SKIP
                               '<td class="tdDados" width=5%>&nbsp</td>'  SKIP
                               '<td class="tdLabel" width=50% align="center" colspan="7">Assinatura do participante</td>' SKIP.
                ELSE
                        IF  crapadp.qtdiaeve = 3 
                            THEN
                                {&out} '<td class="tdDados" width=5%>&nbsp</td>'  SKIP
                                       '<td class="tdDados" width=5%>&nbsp</td>'  SKIP
                                       '<td class="tdDados" width=5%>&nbsp</td>'  SKIP
                                       '<td class="tdLabel" width=50% align="center" colspan="7">Assinatura do participante</td>' SKIP.
                        
                            ELSE   
                                IF  crapadp.qtdiaeve = 4 
                                    THEN
                                        {&out} '<td class="tdDados" width=5%>&nbsp</td>'  SKIP 
                                               '<td class="tdDados" width=5%>&nbsp</td>'  SKIP 
                                               '<td class="tdDados" width=5%>&nbsp</td>'  SKIP
                                               '<td class="tdDados" width=5%>&nbsp</td>'  SKIP
                                               '<td class="tdLabel" width=50% align="center" colspan="7">Assinatura do participante</td>' SKIP.
                                               
                                    ELSE
                                        IF  crapadp.qtdiaeve >= 5 
                                            THEN
                                                {&out} '<td class="tdDados" width=5%>&nbsp</td>'  SKIP
                                                       '<td class="tdDados" width=5%>&nbsp</td>'  SKIP
                                                       '<td class="tdDados" width=5%>&nbsp</td>'  SKIP
                                                       '<td class="tdDados" width=5%>&nbsp</td>'  SKIP
                                                       '<td class="tdDados" width=5%>&nbsp</td>'  SKIP
                                                       '<td class="tdLabel" width=50% align="center" colspan="7">Assinatura do participante</td>' SKIP.


    {&out} '      <tr>' SKIP.
        
    FOR EACH Crapidp WHERE Crapidp.NrSeqEve = nrSeqEve AND
                           Crapidp.IdStaIns = idStaIns AND
                           /* PROGRID */
                          (idevento         = 1 OR
                           /* ASSEMBLEIAS */
                          (idevento         = 2 AND
                          (crapidp.cdageins = cdagenci OR
                           cdagenci         = 0))) NO-LOCK
                        BY Crapidp.NmInsEve:
        ASSIGN conta = conta + 1.
        {&out} '      <tr>' SKIP
               '         <td class="tdDados" align="center">' conta FORMAT "999" '</td>' SKIP
               '         <td class="tdDados">' Crapidp.NmInsEve '</td>' SKIP
               '         <td class="tdDados" align="center">' (IF Crapidp.NrdConta > 0 THEN STRING(Crapidp.NrdConta,"zzzz,zzz,9") ELSE '&nbsp;') '</td>' SKIP.
        
         IF  crapadp.qtdiaeve < 1 OR crapedp.tpevento = 4
            THEN
               {&out} '<td class="tdLabel" width=50% align="center" colspan="7">&nbsp</td>' SKIP.
        ELSE   
            IF  crapadp.qtdiaeve = 1 
                THEN
                {&out} '<td class="tdDados" width=5%>&nbsp</td>'  SKIP
                       '<td class="tdLabel" width=50% align="center" colspan="7">&nbsp</td>' SKIP.
            ELSE
                IF  crapadp.qtdiaeve = 2 
                    THEN
                        {&out} '<td class="tdDados" width=5%>&nbsp</td>'  SKIP
                               '<td class="tdDados" width=5%>&nbsp</td>'  SKIP
                               '<td class="tdDados" width=95%">&nbsp</td>' SKIP.

                    ELSE
                        IF  crapadp.qtdiaeve = 3 
                            THEN
                                {&out} '<td class="tdDados" width=5%>&nbsp</td>'  SKIP
                                       '<td class="tdDados" width=5%>&nbsp</td>'  SKIP
                                       '<td class="tdDados" width=5%>&nbsp</td>'  SKIP
                                       '<td class="tdDados" width=90%>&nbsp</td>' SKIP.
                        
                            ELSE   
                                IF  crapadp.qtdiaeve = 4 
                                    THEN
                                        {&out} '<td class="tdDados" width=5%>&nbsp</td>'  SKIP 
                                               '<td class="tdDados" width=5%>&nbsp</td>'  SKIP 
                                               '<td class="tdDados" width=5%>&nbsp</td>'  SKIP
                                               '<td class="tdDados" width=5%>&nbsp</td>'  SKIP
                                               '<td class="tdDados" width=85%>&nbsp</td>' SKIP.
                                               
                                    ELSE
                                        IF  crapadp.qtdiaeve >= 5 
                                            THEN
                                                {&out} '<td class="tdDados" width=5%>&nbsp</td>'  SKIP
                                                       '<td class="tdDados" width=5%>&nbsp</td>'  SKIP
                                                       '<td class="tdDados" width=5%>&nbsp</td>'  SKIP
                                                       '<td class="tdDados" width=5%>&nbsp</td>'  SKIP
                                                       '<td class="tdDados" width=5%>&nbsp</td>'  SKIP
                                                       '<td class="tdDados" width=80%>&nbsp</td>' SKIP.

        {&out} '      <tr>' SKIP.
    END.
    /*insere 4 linha em branco para incluir inscri��es no dia */
    
    DO aux_linhas = 1 TO 4:
    
    ASSIGN conta = conta + 1.
        {&out} '      <tr>' SKIP
               '         <td class="tdDados" align="center">' conta FORMAT "999" '</td>' SKIP
               '         <td class="tdDados">&nbsp</td>' SKIP
               '         <td class="tdDados" align="center">&nbsp</td>' SKIP.
         IF  crapadp.qtdiaeve < 1 OR crapedp.tpevento = 4
            THEN
               {&out} '<td class="tdLabel" width=50% align="center" colspan="7">&nbsp</td>' SKIP.
        ELSE   
            IF  crapadp.qtdiaeve = 1 
                THEN
                {&out} '<td class="tdDados" width=5%>&nbsp</td>'  SKIP
                       '<td class="tdLabel" width=50%>&nbsp</td>' SKIP.
            ELSE
                IF  crapadp.qtdiaeve = 2 
                    THEN                 
                        {&out} '<td class="tdDados" width=5%>&nbsp</td>'  SKIP
                               '<td class="tdDados" width=5%>&nbsp</td>'  SKIP
                               '<td class="tdDados" width=95%">&nbsp</td>' SKIP.

                    ELSE
                        IF  crapadp.qtdiaeve = 3 
                            THEN
                                {&out} '<td class="tdDados" width=5%>&nbsp</td>'  SKIP
                                       '<td class="tdDados" width=5%>&nbsp</td>'  SKIP
                                       '<td class="tdDados" width=5%>&nbsp</td>'  SKIP
                                       '<td class="tdDados" width=90%>&nbsp</td>' SKIP.

                            ELSE   
                                IF  crapadp.qtdiaeve = 4 
                                    THEN
                                        {&out} '<td class="tdDados" width=5%>&nbsp</td>'  SKIP 
                                               '<td class="tdDados" width=5%>&nbsp</td>'  SKIP 
                                               '<td class="tdDados" width=5%>&nbsp</td>'  SKIP
                                               '<td class="tdDados" width=5%>&nbsp</td>'  SKIP
                                               '<td class="tdDados" width=85%>&nbsp</td>' SKIP.

                                    ELSE
                                        IF  crapadp.qtdiaeve >= 5 
                                            THEN
                                                {&out} '<td class="tdDados" width=5%>&nbsp</td>'  SKIP
                                                       '<td class="tdDados" width=5%>&nbsp</td>'  SKIP
                                                       '<td class="tdDados" width=5%>&nbsp</td>'  SKIP
                                                       '<td class="tdDados" width=5%>&nbsp</td>'  SKIP
                                                       '<td class="tdDados" width=5%>&nbsp</td>'  SKIP
                                                       '<td class="tdDados" width=80%>&nbsp</td>' SKIP.


                {&out} '      <tr>' SKIP.
    END.

    {&out} '   </table>' SKIP.

    {&out} '   <br><br>' SKIP.  

    /* *** Ministrantes para assinar *** */
    {&out} '   <div align="left">' SKIP.

    /* PROGRID */
    IF   idevento = 1   THEN
         DO:
            IF facilitadores = "" THEN 
               {&out} '      <span class="tdLabel">Ministrante:</span>' SKIP.
            ELSE 
               {&out} '      <span class="tdLabel">Ministrantes:</span>' SKIP.
         END.

    {&out} '      <br><br>' SKIP
           '      <table border="0" cellspacing="5" cellpadding="1">' SKIP.
    IF facilitadores = ""
       THEN
           {&out} '         <tr>' SKIP
                  '            <td align="center" style="border-collapse:collapse; border-top: #000000 1px solid">' facilitador FORMAT "x(40)" '</td>' SKIP
                  '         </tr>' SKIP.
       ELSE
           DO:
              {&out} '         <tr>' SKIP.
              ASSIGN ajuste = 0.
              DO conta = 1 TO NUM-ENTRIES(facilitadores):
                 ASSIGN ajuste = IF NUM-ENTRIES(facilitadores) > 4 THEN (40 - LENGTH(TRIM(ENTRY(conta,facilitadores)))) ELSE (30 - LENGTH(TRIM(STRING(ENTRY(conta,facilitadores),"X(20)")))).
                 IF ajuste <= 0 
                    THEN 
                        ASSIGN ajuste = 2.
                 ASSIGN ajuste = ajuste / 2.
                 {&out} '            <td align="center" style="font-size: ' (IF NUM-ENTRIES(facilitadores) > 4 THEN '9' ELSE '10') 'px; border-collapse:collapse; border-top: #000000 1px solid">' FILL("&nbsp;",ajuste) ENTRY(conta,facilitadores) FILL("&nbsp;",ajuste) '</td>' SKIP.
                 
              END.
              {&out} '         </tr>' SKIP.
           END.
    {&out} '      </table>' SKIP.

    /* *** Agnaldo - 08/12/05 - Dispensada a impress�o do conte�do do evento *** */
    /*
    {&out} '      <br><br>'
           '      <span class="tdLabel">Conte�do:</span><br>' SKIP
           '      <span class="tdDados">' Gnappdp.DsConteu '</span>' SKIP.
    */

    {&out} '   </div>' SKIP.

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

IF permiteExecutar = "1" OR permiteExecutar = "2"
   THEN
       erroNaValidacaoDoLogin(permiteExecutar).
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
                 /*ASSIGN nomeDaAgencia = Crapage.NmResAge + " - " + Crapage.NmExtAge.*/
                 ASSIGN nomeDaAgencia = Crapage.NmResAge.
             ELSE
             IF   cdagenci = 0   THEN
                  ASSIGN nomedaagencia = "TODOS OS PA'S".
             ELSE
                  ASSIGN nomeDaAgencia = "Pa " + STRING(cdAgenci,"999").


          /* ***  Informa��es da Agenda do Progrid por PA *** */
         
          FIND Crapadp WHERE Crapadp.NrSeqDig = nrSeqEve NO-LOCK NO-ERROR.
          IF NOT AVAILABLE Crapadp 
             THEN
                 ASSIGN msgsDeErro = msgsDeErro + "-> Registro Crapadp n�o esta disponivel.<br>".
             ELSE
                 DO:
                    ASSIGN dataInicial = Crapadp.DtIniEve
                           dataFinal   = Crapadp.DtFinEve
                           cdEvento    = Crapadp.CdEvento.

                    /* **** Local do evento *** */
                    FIND Crapldp WHERE Crapldp.CdCooper = cdCooper AND
                                      (Crapldp.CdAgenci = cdAgenci OR
                                       /* Assembl�ia */
                                       cdagenci         = 0)       AND
                                       Crapldp.NrSeqDig = Crapadp.CdLocali NO-LOCK NO-ERROR.
                    IF AVAILABLE Crapldp
                       THEN
                           ASSIGN localDoEvento1 = Crapldp.DsLocali
                                  localDoEvento2 = Crapldp.DsEndLoc + ", " + Crapldp.NmBaiLoc + ", " + Crapldp.NmCidLoc + ", fone (" + STRING(Crapldp.NrDddTel) + ") " + STRING(Crapldp.NrTelefo)
                                                                  referencia     = Crapldp.dsrefloc.
                       ELSE
                           ASSIGN localDoEvento1 = ""
                                  localDoEvento2 = ""
                                                                  referencia     = "".

                 END.
            

          /* *** Localiza evento *** */
          FIND Crapedp WHERE Crapedp.IdEvento = idEvento AND
                             Crapedp.CdCooper = cdCooper AND
                             Crapedp.DtAnoAge = dtAnoAge AND
                             Crapedp.CdEvento = cdEvento NO-LOCK NO-ERROR.
          IF NOT AVAILABLE Crapedp
             THEN
                 ASSIGN msgsDeErro = msgsDeErro + "-> Registro Crapedp n�o esta disponivel.<br>".

          
          /* PROGRID */
          IF   idevento = 1   THEN
               DO:
                  /* *** Localiza custo do evento *** */
                  FIND Crapcdp WHERE Crapcdp.IdEvento = idEvento AND
                                     Crapcdp.CdCooper = cdCooper AND
                                     Crapcdp.CdAgenci = cdAgenci AND
                                     Crapcdp.DtAnoAge = dtAnoAge AND
                                     Crapcdp.TpCusEve  = 1 AND       /* direto */
                                     Crapcdp.CdEvento = cdEvento AND
                                     Crapcdp.CdCusEve = 1 /* honor�rios */  NO-LOCK NO-ERROR.
                  IF NOT AVAILABLE Crapcdp
                     THEN
                         ASSIGN msgsDeErro = msgsDeErro + "-> Registro Crapcdp n�o esta disponivel.<br>".
                  
                                  /* *** Localiza proposta do evento *** */
                  FIND Gnappdp WHERE Gnappdp.IdEvento = idEvento AND
                                     Gnappdp.CdCooper = 0 AND
                                     Gnappdp.NrCpfCgc = Crapcdp.NrCpfCgc AND
                                     Gnappdp.NrPropos = Crapcdp.NrPropos NO-LOCK NO-ERROR.
                 
                                  IF NOT AVAILABLE Gnappdp
                     THEN 
                         ASSIGN msgsDeErro = msgsDeErro + "-> Registro Gnappdp n�o esta disponivel.<br>".
                                  
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
               END. /* Fim PROGRID */
          ELSE
               /* Nas assembl�ias nao tem facilitadores */
               ASSIGN facilitador   = ""
                      facilitadores = "".

          /* Busca as listas de Tipo de Evento */
          FIND FIRST craptab WHERE craptab.cdcooper = 0              AND
                                   craptab.nmsistem = "CRED"         AND
                                   craptab.tptabela = "CONFIG"       AND
                                   craptab.cdempres = 0              AND
                                   craptab.cdacesso = "PGTPEVENTO"   AND
                                   craptab.tpregist = 0              NO-LOCK NO-ERROR.
            
          IF   AVAILABLE craptab   THEN
               ASSIGN aux_tpevento = ENTRY(LOOKUP(STRING(crapedp.tpevento),  craptab.dstextab) - 1, craptab.dstextab).
          
          
          FIND crapcop WHERE crapcop.cdcooper = cdCooper NO-LOCK NO-ERROR.

          IF AVAILABLE crapcop THEN
             DO:
                ASSIGN imagemDoProgrid      = "/cecred/images/geral/logo_cecred.gif".
             
                IF INDEX(crapcop.nmrescop, " ") <> 0  THEN
                   DO: 
                    aux_nmrescop = LC(TRIM(crapcop.nmrescop)).
                    SUBSTRING( aux_nmrescop, (INDEX(aux_nmrescop, " ")),1) = "_".
                    imagemDaCooperativa =  "/cecred/images/admin/logo_" +  aux_nmrescop.
                   END.
                ELSE
                   imagemDaCooperativa  = "/cecred/images/admin/logo_" + TRIM(LC(crapcop.nmrescop)) + ".gif" .

             END.

          IF msgsDeErro <> ""
             THEN
                 DO:
                    {&out} "Erro grave.<br>" msgsDeErro.
                    {&DISPLAY} idEvento 
                               cdCooper 
                               cdAgenci 
                               dtAnoAge 
                               cdEvento 
                               nrSeqEve 
                               idStaIns.
                 END.
             ELSE
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

