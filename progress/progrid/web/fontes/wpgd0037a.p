/*
 *
 * Programa wpgd0037a.p - Listagem de check list do evento (chamado a partir dos dados de wpgd0037)
 *
 */
/* .............................................................................

Alterações:  03/11/2008 - Inclusao widget-pool (martin)

             10/12/2008 - Melhoria de performance para a tabela gnapses (Evandro).
                         
                         05/06/2012 - Adaptação dos fontes para projeto Oracle. Alterado
                                                  busca na gnapses de CONTAINS para MATCHES (Guilherme Maba).

             28/11/2012 - Substituir tabela "gncoper" por "crapcop"
                          (David Kruger).
                          
             04/04/2013 - Alteração para receber logo na alto vale,
                          recebendo nome de viacrediav e buscando com
                          o respectivo nome (David Kruger).                          
             
             11/09/2013 - Nova forma de chamar as agências, de PAC agora 
                          a escrita será PA (André Euzébio - Supero).
                          
             12/02/2015 - Alterado Observações por Observação (Lucas R. #251982)
             
             09/10/2015 - Incluido leitura de recursos das tabelas craprpe craprdf,
                          criado a TT gnatrdp para facilitar a ordenacao em ordem
                          alfabética dos recursos, PRJ 229 (Jean Michel).
                          
            16/12/2015 - Ajustes solicitados pelo Márcio (Vanessa).
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

DEFINE VARIABLE ajuste     AS INTEGER.
DEFINE VARIABLE aux_linhas AS INTEGER.
DEFINE VARIABLE aux_nmrescop AS CHARACTER.


DEFINE VARIABLE descricaoDoRecurso AS CHARACTER.

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE gnatrdp
       FIELD dsrecurs AS CHARACTER.
                           
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
           '         <td class="tdTitulo1" colspan="4" align="center">Check List</td>' SKIP
           '         <td align="center"><img src="' imagemDaCooperativa '" border="0"></td>' SKIP
           '      <tr>' SKIP
           '   </table>' SKIP. 

    {&out} '<br>' SKIP.
    
    /* Cabecalho para o PROGRID */
    IF   idevento = 1   THEN 
      DO:
         /* *** Dados do evento *** */
         {&out} '   <table border="0" cellspacing="1" cellpadding="1" width="100%">' SKIP
                '      <tr>' SKIP
                '         <td class="tdLabel" align="right">Pa:</td>' SKIP
                '         <td class="tdLabel" colspan="6">' nomeDaAgencia '</td>' SKIP
                '      <tr>' SKIP
                '      <tr>' SKIP
                '         <td class="tdLabel" align="right">Evento:</td>' SKIP
                '         <td class="tdDados" colspan="3">' Crapedp.NmEvento '</td>' SKIP
                '         <td class="tdLabel" align="right">Período:</td>' SKIP
                '         <td class="tdDados">' IF (Crapadp.DtFinEve - Crapadp.DtIniEve) = ? THEN 
                                                   " " 
                                                ELSE  
                                                    IF (Crapadp.DtFinEve - Crapadp.DtIniEve) < 1 THEN 
                                                        STRING(Crapadp.DtIniEve,"99/99/9999") 
                                                    ELSE (STRING(Crapadp.DtIniEve,"99/99/9999") + ' a ' + STRING(Crapadp.DtFinEve,"99/99/9999")) '</td>' SKIP 
                '      <tr>' SKIP
                '      <tr>' SKIP
                '         <td class="tdLabel" align="right">Ministrante:</td>' SKIP
                '         <td class="tdDados">' facilitador '</td>' SKIP
                '         <td class="tdLabel" align="right">Horário:</td>' SKIP
                '         <td class="tdDados">' Crapadp.DsHroeve '</td>' SKIP
                '         <td class="tdLabel" align="right">Carga horária:</td>' SKIP
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
                '         <td class="tdLabel" align="right">Referência:</td>' SKIP
                '         <td class="tdDados" colspan="6">' referencia '</td>' SKIP
                '      <tr>' SKIP
                '   </table>' SKIP.
      END.
    ELSE
      DO:
        /* Cabecalho para as ASSEMBLEIAS */
        /* *** Dados do evento *** */
        {&out} '   <table border="0" cellspacing="1" cellpadding="1" width="100%">' SKIP
               '      <tr>' SKIP
               '         <td class="tdLabel" align="right">Pa:</td>' SKIP
               '         <td class="tdLabel" colspan="6">' nomeDaAgencia '</td>' SKIP
               '      <tr>' SKIP
               '      <tr>' SKIP
               '         <td class="tdLabel" align="right">Evento:</td>' SKIP
               '         <td class="tdDados" colspan="3">' Crapedp.NmEvento '</td>' SKIP
               '         <td class="tdLabel" align="right">Período:</td>' SKIP
               '         <td class="tdDados">' IF (Crapadp.DtFinEve - Crapadp.DtIniEve) = ? THEN 
                                                  " " 
                                               ELSE  
                                                   IF (Crapadp.DtFinEve - Crapadp.DtIniEve) < 1 THEN 
                                                       STRING(Crapadp.DtIniEve,"99/99/9999") 
                                                   ELSE (STRING(Crapadp.DtIniEve,"99/99/9999") + ' a ' + STRING(Crapadp.DtFinEve,"99/99/9999")) '</td>' SKIP 
               '      <tr>' SKIP
               '      <tr>' SKIP
               '         <td class="tdLabel" align="right">Horário:</td>' SKIP
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
               '         <td class="tdLabel" align="right">Referência:</td>' SKIP
               '         <td class="tdDados" colspan="6">' referencia '</td>' SKIP
               '      <tr>' SKIP

               '   </table>' SKIP.
      END.
      
    {&out} '<br>' SKIP.

    /* *** Corpo da listagem *** */
    {&out} '   <table border="1" cellspacing="1" cellpadding="3" width="100%" class="tab1">' SKIP
           '      <tr>' SKIP
           '         <td class="tdLabel" align="center">N°</td>' SKIP
           '         <td class="tdLabel" width="30%" align="center">Recursos a providenciar</td>' SKIP
           '         <td class="tdLabel" width="10%" align="center">Data</td>' SKIP
           '         <td class="tdLabel" width="60%" align="center">Obervação</td>' SKIP
       '      </tr>' SKIP.

    FOR EACH craprep WHERE craprep.idevento = idevento
                       AND craprep.cdcooper = 0
                       AND craprep.cdevento = cdevento
                       NO-LOCK:
    
      FIND gnaprdp WHERE gnaprdp.idevento = craprep.idevento
                     AND gnaprdp.cdcooper = 0
                     AND gnaprdp.nrseqdig = craprep.nrseqdig
                     AND gnaprdp.idsitrec = 1 NO-LOCK NO-ERROR.        
   
      IF AVAILABLE gnaprdp THEN
        DO:
          CREATE gnatrdp.
          ASSIGN gnatrdp.dsrecurs = gnaprdp.dsrecurs.
        END.
    END.
      
    /* Novas Leituras - Jean Michel */
    FOR EACH craprpe WHERE craprpe.idevento = idEvento
                       AND craprpe.cdcooper = 0
                       AND craprpe.cdagenci = cdAgenci
                       AND craprpe.cdcopage = cdCooper
                       and craprpe.cdevento = cdevento NO-LOCK:
    
      FIND gnaprdp WHERE gnaprdp.idevento = craprpe.idevento
                     AND gnaprdp.cdcooper = 0
                     AND gnaprdp.nrseqdig = craprpe.nrseqdig
                     AND gnaprdp.idsitrec = 1 NO-LOCK NO-ERROR.        
   
      IF AVAILABLE gnaprdp THEN
        DO:
          CREATE gnatrdp.
          ASSIGN gnatrdp.dsrecurs = gnaprdp.dsrecurs.
        END.
    END.
    
    FOR EACH craprdf WHERE craprdf.idevento = idEvento
                       AND craprdf.cdcooper = 0 NO-LOCK:
    
      FIND crapcdp WHERE crapcdp.idevento = idEvento
                     AND crapcdp.cdcooper = cdCooper 
                     AND crapcdp.dtanoage = dtAnoAge  
                     AND crapcdp.cdagenci = cdAgenci
                     AND crapcdp.cdevento = cdevento 
                     AND crapcdp.cdcuseve = 1 
                     AND craprdf.nrcpfcgc = crapcdp.nrcpfcgc
                     AND craprdf.dspropos = crapcdp.nrpropos NO-LOCK NO-ERROR.
      
      IF AVAILABLE crapcdp THEN
        DO:
          FIND gnaprdp WHERE gnaprdp.idevento = craprdf.idevento
                         AND gnaprdp.cdcooper = 0
                         AND gnaprdp.nrseqdig = craprdf.nrseqdig
                         AND gnaprdp.idsitrec = 1 NO-LOCK NO-ERROR.        
       
          IF AVAILABLE gnaprdp THEN
            DO:
              CREATE gnatrdp.
              ASSIGN gnatrdp.dsrecurs = gnaprdp.dsrecurs.
            END.
        END.
    END.
    
    FOR EACH gnatrdp NO-LOCK BY gnatrdp.dsrecurs:
      ASSIGN conta = conta + 1.
      {&out} '      <tr>' SKIP
             '         <td class="tdDados" align="center">' conta FORMAT "99" '</td>' SKIP
             '         <td class="tdDados">' UPPER(gnatrdp.dsrecurs) '</td>' SKIP
             '         <td class="tdDados" align="center"> &nbsp; </td>' SKIP
             '         <td class="tdDados" align="center"> &nbsp; </td>' SKIP
             '      </tr>' SKIP.
    END.    
    /* Fim novas leituras - Jean Michel */
    
    DO aux_linhas = 1 TO 5:
    
      ASSIGN conta = conta + 1.
          {&out} '      <tr>' SKIP
                 '         <td class="tdDados" align="center">' conta FORMAT "99" '</td>' SKIP
                 '         <td class="tdDados">&nbsp</td>' SKIP
                 '         <td class="tdDados">&nbsp</td>' SKIP
                 '         <td class="tdDados">&nbsp</td>' SKIP
                 '      </tr>' SKIP.
    END.
    
    {&out} '   </table>' SKIP
           '</div>'      SKIP
           '</body>'     SKIP
           '</html>'     SKIP.

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
                                 nrSeqEve = INTEGER(GET-VALUE("parametro5"))
                 idStaIns = 2.

                  /*cdEvento = 5.*/
    
          /* *** Dados do PA *** */
          FIND Crapage WHERE Crapage.CdCooper = cdCooper AND Crapage.CdAgenci = cdAgenci NO-LOCK NO-ERROR.
          IF AVAILABLE Crapage 
             THEN
                 ASSIGN nomeDaAgencia = Crapage.NmResAge.
             ELSE
                 /*ASSIGN nomeDaAgencia = "Pa " + STRING(cdAgenci,"999").*/
                 ASSIGN nomeDaAgencia = "TODOS OS PA'S".


          /* ***  Informações da Agenda do Progrid por PA *** */

          /* Esta é a linha correta
          FIND Crapadp WHERE Crapadp.NrSeqDig = nrSeqEve NO-LOCK NO-ERROR. 
          */

          /* Esta linha de FIND é apenas para os testes enquanto a base não esta carrega com dados corretos */
          /*FIND FIRST Crapadp NO-LOCK NO-ERROR. */
                
                  FIND Crapadp WHERE Crapadp.cdcooper = cdcooper  AND
                                     Crapadp.NrSeqDig = nrSeqEve NO-LOCK NO-ERROR. 
                  
          IF NOT AVAILABLE Crapadp 
             THEN
                 ASSIGN msgsDeErro = msgsDeErro + "-> Registro Crapadp não esta disponivel.<br>".
             ELSE
                 DO:
                    ASSIGN dataInicial = Crapadp.DtIniEve
                           dataFinal   = Crapadp.DtFinEve
                           cdEvento    = Crapadp.CdEvento.

                    /* **** Local do evento *** */
                    FIND Crapldp WHERE Crapldp.CdCooper = cdCooper AND
                                      (Crapldp.CdAgenci = cdAgenci OR
                                       /* Assembléia */
                                       cdagenci         = 0)       AND
                                       Crapldp.NrSeqDig = Crapadp.CdLocali NO-LOCK NO-ERROR.
                    IF AVAILABLE Crapldp
                       THEN
                           ASSIGN localDoEvento1 = Crapldp.DsLocali
                                  localDoEvento2 = Crapldp.DsEndLoc + ", " + Crapldp.NmBaiLoc + ", " + Crapldp.NmCidLoc + ", fone (" + STRING(Crapldp.NrDddTel) + ") " + STRING(Crapldp.NrTelefo)
                                                                  referencia     = Crapldp.Dsrefloc.
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
                 ASSIGN msgsDeErro = msgsDeErro + "-> Registro Crapedp não esta disponivel.<br>".
          
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
                                     Crapcdp.CdCusEve = 1 /* honorários */  NO-LOCK NO-ERROR.
                  IF NOT AVAILABLE Crapcdp
                     THEN
                         ASSIGN msgsDeErro = msgsDeErro + "-> Registro Crapcdp não esta disponivel.<br>".
                  
                  
                  /* *** Localiza proposta do evento *** */
                  FIND Gnappdp WHERE Gnappdp.IdEvento = idEvento AND
                                     Gnappdp.CdCooper = 0 AND
                                     Gnappdp.NrCpfCgc = Crapcdp.NrCpfCgc AND
                                     Gnappdp.NrPropos = Crapcdp.NrPropos NO-LOCK NO-ERROR.
                  /*IF NOT AVAILABLE Gnappdp
                     THEN
                         ASSIGN msgsDeErro = msgsDeErro + "-> Registro Gnappdp não esta disponivel.<br>".
                  
                  
                  */
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
               /* Nas assembléias nao tem facilitadores */
               ASSIGN facilitador   = ""
                      facilitadores = "".

 
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

