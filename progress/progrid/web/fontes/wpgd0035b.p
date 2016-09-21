/*
 *
 * Programa wpgd0035b.p - Listagem de certificados, impressão dos usuários selecionados
 *                        (chamado a partir dos dados de wpgd0035a)
 *
 */
/* .............................................................................

Alterações:  03/11/2008 - Inclusao widget-pool (martin)
         
             11/11/2008 - Tratamento na impressão do Certificado (Diego).

             10/12/2008 - Melhoria de performance para a tabela gnapses (Evandro).
                         
                         05/06/2012 - Adaptação dos fontes para projeto Oracle. Alterado
                                                  busca na gnapses de CONTAINS para MATCHES Guilherme Maba).
                          
             19/07/2012 - Removido o campo de assinatura do Ministrante (Lucas).

             28/11/2012 - Substituir tabela "gncoper" por "crapcop"
                          (David Kruger).
                          
             04/04/2013 - Alteração no layout dos certificados
                          (David Kruger).
                          
             22/09/2014 - Incluir crapass na busca pelos incritos (Softdesk 201275 - Lucas R.) 
             
             23/10/2014 - Incluir inpessoa = 1 na busca da crapass (Lucas R.)
            
                          
............................................................................. */

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
DEFINE VARIABLE programaEmUso         AS CHARACTER INITIAL ["wpgd0035b"].

DEFINE VARIABLE idEvento              AS INTEGER.
DEFINE VARIABLE cdCooper              AS INTEGER.
DEFINE VARIABLE cdAgenci              AS INTEGER.
DEFINE VARIABLE dtAnoAge              AS INTEGER.
DEFINE VARIABLE cdEvento              AS INTEGER.
DEFINE VARIABLE idStaIns              AS INTEGER.
DEFINE VARIABLE nrSeqEve              AS INTEGER.

DEFINE VARIABLE imagemDoProgrid       AS CHARACTER.
DEFINE VARIABLE imagemDaCooperativa   AS CHARACTER.
DEFINE VARIABLE nomeDaCooperativa     AS CHARACTER.

DEFINE VARIABLE auxiliar              AS CHARACTER.
DEFINE VARIABLE dataInicial           AS DATE.
DEFINE VARIABLE dataFinal             AS DATE.

DEFINE VARIABLE conta                 AS INTEGER.
DEFINE VARIABLE situacao              AS CHARACTER.
DEFINE VARIABLE facilitador           AS CHARACTER.
DEFINE VARIABLE facilitadores         AS CHARACTER.
DEFINE VARIABLE nomeDaAgencia         AS CHARACTER.
DEFINE VARIABLE nomedacidade          AS CHARACTER.
DEFINE VARIABLE localDoEvento1        AS CHARACTER.
DEFINE VARIABLE localDoEvento2        AS CHARACTER.

DEFINE VARIABLE ajuste                AS INTEGER.

DEFINE VARIABLE corEmUso              AS CHARACTER.
DEFINE VARIABLE valor                 AS INTEGER.
DEFINE VARIABLE salvou                AS LOGICAL.

DEFINE VARIABLE registro              AS INTEGER.
DEFINE VARIABLE assinar1              AS CHARACTER.
DEFINE VARIABLE assinar2              AS CHARACTER.
DEFINE VARIABLE tipoDoEvento          AS CHARACTER.
DEFINE VARIABLE registros             AS CHARACTER.
DEFINE VARIABLE horario               AS CHARACTER.

DEFINE VARIABLE mes                   AS CHARACTER INITIAL["janeiro,fevereiro,março,abril,maio,junho,julho,agosto,setembro,outubro,novembro,dezembro"].

DEFINE VARIABLE aux_msg-erro          AS CHAR                NO-UNDO.
DEFINE VARIABLE h-b1wpgd0009          AS HANDLE              NO-UNDO.
                           
DEFINE TEMP-TABLE cratidp   NO-UNDO   LIKE crapidp.

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

ASSIGN corEmUso = "#000066".

FUNCTION montaTela RETURNS LOGICAL ().

    /** ATENÇÃO: A fonte que está sendo usada atualmente não é padrão do windows
                 o computador que for imprimir estes certificados deverá ter estas 
                 fontes devidamente instaladas, caso contrario a pegará a fonte 
                 padrão do sistema operacional, assim desconfigurando todo o layout
                 do certificado. 
    **/

    {&out} '<html>' SKIP
           '<head>' SKIP
           '<title>Progrid - Emissão de Certificados</title>' SKIP.
    
    {&out} '<style>' SKIP
           '   body         ~{ background-color: #FFFFFF; }' SKIP 
           '   .inputFreq   ~{ height: 18px; font-size: 10px ; color:#000066}' SKIP
           '   .a3          ~{ font-family: DIN-BLACK, sans-serif; color:#2d5495;font-size: 32px; font-weight: bold;}' SKIP
           '   .a4          ~{ font-family: DIN-REGULAR, sans-serif; color:#2d5495;font-size: 23px; font-weight: bold;}' SKIP
           '   .a5          ~{ font-family: DIN-REGULAR, sans-serif; color:#2d5495;font-size: 32px; font-weight: bold;}' SKIP
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
           '   <input type="hidden" name="parametro6" value="' nrSeqEve '">' SKIP
           '   <input type="hidden" name="registro" value="' registro '">' SKIP
           '   <input type="hidden" name="assinar1" value="' assinar1 '">' SKIP
           '   <input type="hidden" name="assinar2" value="' assinar2 '">' SKIP.
    
    IF msgsDeErro <> "" THEN
       {&out} '<h2>Atenção</h2>'      SKIP
              '<b>' msgsDeErro '</b>' SKIP.
       ELSE
           DO:
              ASSIGN conta = 0.

              FOR EACH Crapidp WHERE crapidp.cdcooper = cdCooper AND
                                     Crapidp.NrSeqEve = nrSeqEve AND
                                     Crapidp.IdStaIns = idStaIns NO-LOCK,
                  EACH crapass WHERE crapass.cdcooper = crapidp.cdcooper AND
                                     crapass.nrdconta = crapidp.nrdconta AND
                                     crapass.inpessoa = 1 NO-LOCK 
                                     BY Crapidp.NmInsEve:

                  ASSIGN conta = conta + 1.
                  
                  IF LOOKUP(STRING(conta),registros,"I") > 0
                     THEN
                         DO:              

                            /* Verifica se ainda não foi impresso certificado, para preencher a data de impressão */
                            IF   crapidp.dtemcert = ?   THEN
                                 DO:
                                    /* Instancia a BO para executar as procedures */
                                    RUN dbo/b1wpgd0009.p PERSISTENT SET h-b1wpgd0009.
                     
                                    /* Se BO foi instanciada */
                                    IF VALID-HANDLE(h-b1wpgd0009) THEN
                                       DO:
                                          EMPTY TEMP-TABLE cratidp.
                     
                                          CREATE cratidp.
                     
                                          BUFFER-COPY crapidp TO cratidp.
                                          ASSIGN cratidp.dtemcert = TODAY.
                     
                                          RUN altera-registro IN h-b1wpgd0009(INPUT TABLE cratidp, OUTPUT aux_msg-erro).
                                    
                                          /* "mata" a instância da BO */
                                          DELETE PROCEDURE h-b1wpgd0009 NO-ERROR.
                                   
                                      END.
                                 END.

                            /* Espaçamento entre o texto e o cabeçalho do certificado */

                            {&out} '</br>' SKIP
                                   '</br>' SKIP
                                   '</br>' SKIP
                                   '</br>' SKIP
                                   '</br>' SKIP
                                   '</br>' SKIP
                                   '</br>' SKIP
                                   '</br>' SKIP
                                   '</br>' SKIP
                                   '</br>' SKIP
                                   '</br>' SKIP.
                
                            {&out} '      <p>'
                                   '         <a class="a5">Certificamos que </a>' 
                                   '         <a class="a3">' Crapidp.NmInsEve '</a>' 
                                   '         <a class="a5"> participou ' IF tipoDoEvento = "evento" THEN ' do evento' ELSE IF tipoDoEvento = "palestra" THEN ' da palestra' ELSE (' do ' + LC(tipoDoEvento)) ' de </a>'
                                   '      </p>' SKIP.

                            {&out} '      <p>'
                                   '         <a class="a3">' Crapedp.NmEvento '</a>'
                                   '         <a CLASS="a5"> conduzido por </a>'
                                   '         <a CLASS="a3">' assinar2  '.</a>'
                                   '      </p>' SKIP.

                            /* Verifica se o curso foi em um único dia, se foi
                               coloca apenas dia, mes, ano e a duração senão,
                               mostra o periodo em que o evento foi realizado */

                            IF (Crapadp.DtFinEve - Crapadp.DtIniEve) = 0
                               THEN
                                   {&out} '      <p>'
                                          '         <a class="a5">O evento foi realizado em ' DAY(Crapadp.DtIniEve) ' de ' ENTRY(MONTH(Crapadp.DtIniEve),mes) ' de ' YEAR(Crapadp.DtIniEve) ',</a>'.
                
                            ELSE
                                   {&out} '      <p>'
                                          '         <a class="a5">O evento foi realizado no período de</a>'
                                          '         <a class="a5">' DAY(Crapadp.DtIniEve) ' de ' ENTRY(MONTH(Crapadp.DtIniEve),mes) ' a ' DAY(Crapadp.DtFinEve) ' de ' ENTRY(MONTH(Crapadp.DtFinEve),mes) ' de ' YEAR(Crapadp.DtFinEve) ',</a></br></br>'. 

                            /* Verifica se foi mais de 1 hora mostrando um 's'
                               após a hora de duração */

                            IF   INT(ENTRY(2,horario,",")) <> 0  THEN
                                 {&out} '           <a class="a5">com duração de ' ENTRY(1,horario,",") 'h' ENTRY(2,horario,",") 'min.</a>'
                                        '        </p>' SKIP.
                            ELSE
                                 {&out} '           <a class="a5">com duração de ' ENTRY(1,horario,",") ' hora(s).</a>'
                                        '        </p>' SKIP.

                            /* Verifica se a data do evento foi concluido em
                               um unico dia para ajusta os espaçamentos entre 
                               o texto e a assinatura.
                               
                               Obs: primeira situação do if é que foi realizado
                                    em um unico dia */
                           
                            IF (Crapadp.DtFinEve - Crapadp.DtIniEve) = 0
                               THEN
                                   {&out} '      </br>' SKIP
                                          '      </br>' SKIP
                                          '      </br>' SKIP
                                          '      </br>' SKIP
                                          '      </br>' SKIP
                                          '      </br>' SKIP   
                                          '      </br>' SKIP 
                                          '      </br>' SKIP.
                               ELSE
                                   {&out} '      </br>' SKIP
                                          '      </br>' SKIP
                                          '      </br>' SKIP
                                          '      </br>' SKIP
                                          '      </br>' SKIP.
                                         
                            IF assinar1 = assinar2 
                               THEN
                                   {&out} '      <p>' 
                                          '         <a align="center" class="a4">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; _____________________________________________________________ </a>'
                                          '         </br>'
                                          '         <a align="center" class="a4">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' assinar1 ' - Presidente</a>' 
                                          '         <a align="center" class="a4">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'nomeDaCooperativa '</a>' 
                                          '      </p>' .
                               ELSE
                                   {&out} '      <p>' 
                                          '         <a align="center" class="a4">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; _____________________________________________________________ </a>' 
                                          '         </br>' 
                                          '         <a align="center" class="a4">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' assinar1 ' - Presidente</a>'  
                                          '         <a align="center" class="a4">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'nomeDaCooperativa '</a>' 
                                          '      </p>'.

                                   {&out} '      </br>' SKIP
                                          '      </br>' SKIP
                                          '      </br>' SKIP.

                                   {&out} '      <div style="margin-left:120px; margin-top:80px;">' 
                                          '         <p align="LEFT"> <a CLASS="a4">' nomedacidade ', ' DAY(TODAY) ' de ' ENTRY(MONTH(TODAY),mes) ' de ' YEAR(TODAY) '.</a> </p>' 
                                          '      </div>' SKIP.
                        
                            {&out} '<br style="page-break-after: always">' SKIP.

                         END. /* IF INDEX(registros,"I" + (STRING(conta))) > 0 */
              END. /* for each */
           END.
    {&out} '</form>' SKIP
           '</div>' SKIP.

    {&out} '<script language="Javascript">' SKIP
           '   print();' SKIP
           '</script>' SKIP.

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

IF permiteExecutar = "1" OR permiteExecutar = "2" THEN
       erroNaValidacaoDoLogin(permiteExecutar).
   ELSE
       DO:
          ASSIGN idEvento  = INTEGER(GET-VALUE("parametro1"))
                 cdCooper  = INTEGER(GET-VALUE("parametro2"))
                 cdAgenci  = INTEGER(GET-VALUE("parametro3"))
                 dtAnoAge  = INTEGER(GET-VALUE("parametro4"))
                 cdEvento  = INTEGER(GET-VALUE("parametro5"))
                 nrSeqEve  = INTEGER(GET-VALUE("parametro6"))
                 registro  = INTEGER(GET-VALUE("registro"))
                 assinar1  = GET-VALUE("assinar1")
                 assinar2  = GET-VALUE("assinar2")
                 registros = GET-VALUE("registros")
                 idStaIns  = 2.

          IF registros = "" 
             THEN
                 ASSIGN msgsDeErro = msgsDeErro + "-> Não foi selecionado nenhum participante do evento.<br>".
             ELSE
                 ASSIGN registros = SUBSTRING(registros,1,LENGTH(registros)).
             
          /* *** 1-Pendente,2-Confirmado,3-Desistente,4-Excedente,5-Cancelado *** */
          ASSIGN situacao = "Pendente,Confirmado,Desistente,Excedente,Cancelado".

          /* *** Dados do PAC *** */
          FIND Crapage WHERE Crapage.CdCooper = cdCooper AND 
                             Crapage.CdAgenci = cdAgenci NO-LOCK NO-ERROR.
          
          IF AVAILABLE Crapage THEN
             DO:
                 ASSIGN nomeDaAgencia = Crapage.NmResAge + " - " + Crapage.NmExtAge
                        nomedacidade  = crapage.nmcidade.
             END.
          ELSE
             ASSIGN nomeDaAgencia = "Agencia " + STRING(cdAgenci,"999")
                    nomedacidade  = "".

          /* ***  Informações da Agenda do Progrid por PAC *** */
          FIND Crapadp WHERE Crapadp.NrSeqDig = nrSeqEve NO-LOCK NO-ERROR.
          IF NOT AVAILABLE Crapadp 
             THEN
                 ASSIGN msgsDeErro = msgsDeErro + "-> Registro Crapadp não esta disponivel.<br>".
             ELSE
                 ASSIGN dataInicial = Crapadp.DtIniEve
                        dataFinal   = Crapadp.DtFinEve
                        cdEvento    = Crapadp.CdEvento.

          /* *** Localiza evento *** */
          FIND Crapedp WHERE Crapedp.IdEvento = idEvento AND
                             Crapedp.CdCooper = cdCooper AND
                             Crapedp.DtAnoAge = dtAnoAge AND
                             Crapedp.CdEvento = cdEvento NO-LOCK NO-ERROR.
          IF NOT AVAILABLE Crapedp
             THEN
                 ASSIGN msgsDeErro = msgsDeErro + "-> Registro Crapedp não esta disponivel.<br>".
             ELSE
                 DO:
                    FIND Craptab WHERE Craptab.cdcooper = 0             AND
                                       Craptab.NmSistem = "CRED"        AND
                                       Craptab.TpTabela = "CONFIG"      AND 
                                       Craptab.CdEmpres = 0             AND 
                                       Craptab.CdAcesso = "PGTPEVENTO"  AND
                                       Craptab.TpRegist = 0 
                                       NO-LOCK NO-ERROR.
                    IF AVAILABLE CrapTab
                       THEN
                           IF Craptab.DsTexTab = "" 
                              THEN
                                  ASSIGN tipoDoEvento = "evento".
                              ELSE
                                  IF NUM-ENTRIES(Craptab.DsTexTab) >= 2
                                     THEN
                                         DO:
                                            ASSIGN tipoDoEvento = "evento".
                                            DO conta = 2 TO NUM-ENTRIES(Craptab.DsTexTab) BY 2:
                                               IF INTEGER(ENTRY(conta,Craptab.DsTexTab)) = Crapedp.TpEvento
                                                  THEN
                                                      ASSIGN tipoDoEvento = ENTRY(conta - 1,Craptab.DsTexTab).
                                            END.
                                         END.
                                     ELSE
                                         ASSIGN tipoDoEvento = "evento".
                       ELSE
                           ASSIGN tipoDoEvento = "evento".
                 END.

          /* *** Localiza custo do evento *** */
          FIND Crapcdp WHERE Crapcdp.IdEvento = idEvento            AND
                             Crapcdp.CdCooper = cdCooper            AND
                             Crapcdp.CdAgenci = cdAgenci            AND
                             Crapcdp.DtAnoAge = dtAnoAge            AND
                             Crapcdp.TpCusEve  = 1                  AND       /* direto */
                             Crapcdp.CdEvento = cdEvento            AND
                             Crapcdp.CdCusEve = 1 /* honorários */  NO-LOCK NO-ERROR.
          IF NOT AVAILABLE Crapcdp
             THEN
                 ASSIGN msgsDeErro = msgsDeErro + "-> Registro Crapcdp não esta disponivel.<br>".

          /* *** Localiza proposta do evento *** */
          FIND Gnappdp WHERE Gnappdp.IdEvento = idEvento            AND
                             Gnappdp.CdCooper = 0                   AND
                             Gnappdp.NrCpfCgc = Crapcdp.NrCpfCgc    AND
                             Gnappdp.NrPropos = Crapcdp.NrPropos    NO-LOCK NO-ERROR.
          IF NOT AVAILABLE Gnappdp
             THEN
                 ASSIGN msgsDeErro = msgsDeErro + "-> Registro Gnappdp não esta disponivel.<br>".
                  ELSE
                       ASSIGN horario = STRING(Gnappdp.Qtcarhor,"zzz9.99").          

          FIND crapcop WHERE crapcop.cdcooper = cdCooper            NO-LOCK NO-ERROR.
          IF NOT AVAILABLE crapcop 
             THEN
                 ASSIGN msgsDeErro = msgsDeErro + "-> Registro crapcop não esta disponivel.<br>".
             ELSE
                 ASSIGN nomeDaCooperativa = crapcop.nmrescop.

          IF assinar2 = "" 
             THEN
                 ASSIGN assinar2 = assinar1.

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

