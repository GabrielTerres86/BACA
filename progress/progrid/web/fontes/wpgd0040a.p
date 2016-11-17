/*
 * Programa : wpgd0040a.p - Agenda Mensal do Progrid (chamado a partir dos dados de wpgd0040)
 * utilizado somente pelo Progrid
 * Criação  : 05/07/06 - Rosangela
 
 * Alteração: 25/01/2008 - Incluído campo "Referência" (Diego).

              03/11/2008 - Incluido widget-pool (Martin). 

              10/12/2008 - Melhoria de performance para a tabela gnapses (Evandro).
              
              30/04/2009 - Utilizar cdcooper = 0 nas consultas (David).
                          
              05/06/2012 - Adaptação dos fontes para projeto Oracle. Alterado
                           busca na gnapses de CONTAINS para MATCHES
                           (Guilherme Maba).
                           
              28/11/2012 - Substituir tabela "gncoper" por "crapcop"
                           (David Kruger).
                           
             04/04/2013 - Alteração para receber logo na alto vale,
                          recebendo nome de viacrediav e buscando com
                          o respectivo nome (David Kruger).
             
             29/08/2013 - Nova forma de chamar as agências, de PAC agora 
                          a escrita será PA (André Euzébio - Supero).    
                          
             10/09/2013 - Incluido validacao de agencia crapadp.cdAgenci <> 0. 
                        - Ajustes para mostrar AGE e AGO. (Lucas R).
                        
             09/08/2016 - Incluir filtro por tipo de evento
                          PRJ229 - Melhorias OQS  (Odirlei-AMcom)
 */

 CREATE WIDGET-POOL.

/*****************************************************************************/
/*   Bloco de variaveis                                                      */
/*****************************************************************************/

DEFINE VARIABLE cookieEmUso                  AS CHARACTER.
DEFINE VARIABLE permiteExecutar              AS CHARACTER.
DEFINE VARIABLE IdentificacaoDaSessao        AS CHARACTER.
DEFINE VARIABLE msgsDeErro                   AS CHARACTER.

DEFINE VARIABLE idEvento                     AS INTEGER.
DEFINE VARIABLE cdCooper                     AS INTEGER.
DEFINE VARIABLE nrmeseve                     AS INTEGER.
DEFINE VARIABLE tpevento                     AS INTEGER.
DEFINE VARIABLE dtAnoAge                     AS INTEGER.
DEFINE VARIABLE cdEvento                     AS INTEGER.
DEFINE VARIABLE aux_tpevento                 AS INTEGER.

DEFINE VARIABLE imagemDoProgrid              AS CHARACTER.
DEFINE VARIABLE imagemDaCooperativa          AS CHARACTER.
DEFINE VARIABLE nomeDaCooperativa            AS CHARACTER.

DEFINE VARIABLE dataDoEvento                 AS CHARACTER.

DEFINE VARIABLE localDoEvento                AS CHARACTER.
DEFINE VARIABLE referencia                   AS CHARACTER.
DEFINE VARIABLE enderecoDoLocal              AS CHARACTER.
DEFINE VARIABLE horarioDoEvento              AS CHARACTER.
DEFINE VARIABLE pessoaAbertura               AS CHARACTER.
DEFINE VARIABLE diasEvento                   AS CHARACTER.
DEFINE VARIABLE linha1                       AS CHARACTER.
DEFINE VARIABLE tipoEvento                   AS CHARACTER.
DEFINE VARIABLE aux_nmrescop                 AS CHARACTER.

DEFINE VARIABLE aux_nmresage                 AS CHARACTER.
DEFINE VARIABLE aux_dscdiase                 AS CHARACTER.
DEFINE VARIABLE aux_dsdiaeve                 AS CHARACTER.
DEFINE VARIABLE aux_contador                 AS INTEGER.

DEFINE VARIABLE mes                          AS CHARACTER INITIAL ["JANEIRO,1,FEVEREIRO,2,MARÇO,3,
                                                                    ABRIL,4,MAIO,5,JUNHO,6,JULHO,7,
                                                                    AGOSTO,8,SETEMBRO,9,OUTUBRO,10,
                                                                    NOVEMBRO,11,DEZEMBRO,12"].

/*DEFINE VARIABLE sobrenomeDoEvento            AS CHARACTER.*/

/*****************************************************************************/
/*   Bloco de includes                                                       */
/*****************************************************************************/

{src/web/method/wrap-cgi.i}

/*****************************************************************************/
/*   Bloco de funçoes                                                        */
/*****************************************************************************/

FUNCTION erroNaValidacaoDoLogin RETURNS LOGICAL (opcao AS CHARACTER):

    IF  opcao = "1" THEN /* get-cookie em usuario-em-uso voltou valor nulo */
        {&out} '<script language="Javascript">' SKIP
               '   top.close(); ' SKIP
               '   window.open("falha","janela_principal","toolbar=yes,location=yes,diretories=no,status=yes,menubar=yes,scrollbars=yes,resizable=yes");' SKIP
               '</script>' SKIP.

    IF  opcao = "2" THEN /* identificacao vinda do cookie bao existe na tabela de log de sessao */ 
        DO: 
           DELETE-COOKIE("cookie-usuario-em-uso",?,?).
           {&out} '<script language="Javascript">' SKIP
                  '   top.close(); ' SKIP
                  '   window.open("falha","janela_principal","toolbar=yes,location=yes,diretories=no,status=yes,menubar=yes,scrollbars=yes,resizable=yes");' SKIP
                  '</script>' SKIP.
        END.

    RETURN TRUE.

END FUNCTION. /* erroNaValidacaoDoLogin RETURNS LOGICAL () */

FUNCTION montaTela RETURNS LOGICAL ():

    {&out} '<html>' SKIP
           '<head>' SKIP
           '<title>Agenda Mensal</title>' SKIP.

    {&out} '<style>' SKIP
           '   body         ~{ background-color: #FFFFFF; }' SKIP
           '   td           ~{ font-family: Arial, Helvetica, sans-serif; font-size: 12px; font-weight: bold; }' SKIP
           '   .tdLabel     ~{ font-family: Arial, Helvetica, sans-serif; font-size: 12px; font-weight: bold; }' SKIP
           '   .tdDados     ~{ font-family: Arial, Helvetica, sans-serif; font-size: 12px; font-weight: normal; border-bottom: #000000 0px solid }' SKIP
           '   .tdprogra    ~{ font-family: Arial, Helvetica, sans-serif; font-size:  8px; font-weight: normal; border-bottom: #000000 0px solid }' SKIP
           '   .tdTitulo1   ~{ font-family: Verdana; font-size: 24px; font-weight: normal;}' SKIP
           '   .tdEventos   ~{ font-family: Verdana; font-size: 14px; font-weight: normal;}' SKIP
           '   .tab1        ~{ border-collapse:collapse; border-top: #000000 1px solid; border-bottom: #000000 1px solid; border-right: #000000 1px solid; border-left: #000000 1px solid; }' SKIP
           '   .tdStatus    ~{ font-family: Verdana; font-size: 12px; font-weight: bold; color: #FF0000;}' SKIP
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
           '         <td class="tdprogra" colspan="5" align="right">wpgd0040a - ' TODAY '</td>' SKIP
           '   </table>' SKIP. 
    
    /* *** Logo *** */
    {&out} '   <table border="0" cellspacing="0" cellpadding="0" width="100%" class="tab1">' SKIP
           '      <tr>' SKIP
           '         <td align="center"><img src="' imagemDoProgrid '" border="0"></td>' SKIP
           '         <td class="tdTitulo1" colspan="4" align="center">PROGRID ' ENTRY(LOOKUP(STRING(nrmeseve), mes) - 1, mes)'/' dtanoage '</td>' SKIP
           '         <td align="center"><img src="' imagemDaCooperativa '" border="0"></td>' SKIP
           '      <tr>' SKIP
           '      <tr>' SKIP
           '      <tr>' SKIP
           '   </table>' SKIP. 
    {&out} '<br>' SKIP.
    
    ASSIGN aux_tpevento = 0.
    
    IF idEvento = 1 THEN
      DO:
        ASSIGN aux_tpevento = 10.
      END.
    ELSE
      IF idEvento = 2 THEN
        DO:        
          ASSIGN aux_tpevento = 11.
        END.
        
      /*Seleciona os eventos que satisfaçam os parametros*/
      FOR EACH Crapadp WHERE Crapadp.IdEvento = idEvento  AND
                             Crapadp.CdCooper = cdCooper  AND
                             Crapadp.DtAnoAge = dtAnoAge  AND
                             crapadp.nrmeseve = nrmeseve  
                             NO-LOCK
                         BY  crapadp.dtinieve:                   

          IF  crapadp.cdAgenci <> 0 THEN
              DO:
                  /**** Busca Nome do pa *** */
                  FIND Crapage WHERE Crapage.CdCooper = cdCooper         AND
                                     Crapage.CdAgenci = crapadp.cdAgenci 
                                     NO-LOCK NO-ERROR.
                  
                  IF  NOT AVAILABLE Crapage THEN
                      DO:
                          ASSIGN msgsDeErro = msgsDeErro + "-> Pa não encontrado. PA: " + STRING(crapadp.cdAgenci) + "<br>".
                      END.
                  ELSE
                      ASSIGN aux_nmresage = " - " + Crapage.NmResAge.
                      END.
          ELSE
              ASSIGN aux_nmresage = "".

          /* *** Nome do evento *** */
          FIND FIRST Crapedp WHERE Crapedp.IdEvento = Crapadp.IdEvento AND
                                   Crapedp.CdCooper = Crapadp.CdCooper AND
                                   Crapedp.DtAnoAge = Crapadp.DtAnoAge AND
                                   Crapedp.CdEvento = Crapadp.CdEvento 
                                   NO-LOCK NO-ERROR.
          
          IF AVAILABLE Crapedp THEN
              ASSIGN linha1 = Crapedp.NmEvento + aux_nmresage.
          ELSE
              ASSIGN msgsDeErro = msgsDeErro + "-> Problemas na leitura da crapedp - Evento." + STRING(Crapadp.CdEvento) + "<br>".
          
          /* Se escolheu somente EAD e o evento for diferente de EAD,
             deve ignorar e ir para o proximo */          
          IF tpevento = 1 AND              
             Crapedp.tpevento <> aux_tpevento THEN
              DO:
                NEXT.
              END.            
          ELSE
              /* Se escolheu somente Presencial e o evento for igual EAD,
                 deve ignorar e ir para o proximo */
              IF tpevento = 2 AND 
                 Crapedp.tpevento = aux_tpevento THEN
                  DO:
                    NEXT.
                  END.
          
          /* Se os tipos forem 1-curso 3-gincana 4-palestra 5-teatro imprime o tipo antes do nome do evento*/
          IF  crapedp.tpevento = 1 OR 
              crapedp.tpevento = 3 OR 
              crapedp.tpevento = 4 OR 
              crapedp.tpevento = 5 THEN
              DO:
                  /* Busca as listas de Tipo de Evento */
                  FIND FIRST craptab WHERE craptab.cdcooper = 0              AND
                                           craptab.nmsistem = "CRED"         AND
                                           craptab.tptabela = "CONFIG"       AND
                                           craptab.cdempres = 0              AND
                                           craptab.cdacesso = "PGTPEVENTO"   AND
                                           craptab.tpregist = 0              
                                           NO-LOCK NO-ERROR.
                    
                  IF  AVAILABLE craptab   THEN
                      ASSIGN tipoEvento = ENTRY(LOOKUP(STRING(crapedp.tpevento),  craptab.dstextab) - 1, craptab.dstextab)
                             linha1 = tipoEvento + " : " + linha1.
              END.

          /*Se o evento estiver cancelado, não imprime todos os dados*/
          IF  crapadp.idstaeve <> 2 THEN
              DO:  
                  IF  crapadp.idevento = 2 OR 
                      /* ou se for eventos EAD */
                      crapedp.tpevento = 10 OR 
                      crapedp.tpevento = 11 THEN
                      FIND Crapldp WHERE Crapldp.CdCooper = cdCooper         AND
                                         Crapldp.NrSeqDig = Crapadp.CdLocali 
                                         NO-LOCK NO-ERROR. 
                  ELSE
                      FIND Crapldp WHERE Crapldp.CdCooper = cdCooper         AND
                                         Crapldp.CdAgenci = Crapadp.cdAgenci AND
                                         Crapldp.NrSeqDig = Crapadp.CdLocali 
                                         NO-LOCK NO-ERROR.
                          
                  IF  AVAILABLE Crapldp THEN
                    DO:
                        ASSIGN localDoEvento   = Crapldp.DsLocali.
                        IF crapedp.tpevento = 10 OR 
                           crapedp.tpevento = 11 THEN
                           ASSIGN enderecoDoLocal = " "
                                  referencia      = " ".
                        ELSE    
                           ASSIGN enderecoDoLocal = Crapldp.DsEndLoc + ", " + Crapldp.NmBaiLoc + ", " + Crapldp.NmCidLoc + ", fone (" + STRING(Crapldp.NrDddTel) + ") " + STRING(Crapldp.NrTelefo)
                                  referencia      = Crapldp.DsRefLoc.
                           
                    END.           
                  ELSE
                      ASSIGN localDoEvento   = "Indefinido"
                             enderecoDoLocal = "Indefinido"
                             referencia      = " ".
              
                  /**** Nome da pessoa que fará a abertura ****/
                  FIND FIRST Crapaep WHERE Crapaep.IdEvento = Crapadp.IdEvento AND
                                           Crapaep.CdCooper = Crapadp.CdCooper AND
                                           Crapaep.nrseqdig = Crapadp.cdabrido 
                                           NO-LOCK NO-ERROR.
              
                  IF  AVAILABLE Crapaep THEN
                      ASSIGN pessoaAbertura = crapaep.nmabreve.
                  ELSE
                      ASSIGN pessoaAbertura = "Indefinido".
              
                  IF  (Crapadp.DsHroeve = ? OR Crapadp.DsHroeve = "")  THEN
                      ASSIGN horarioDoEvento = "Indefinido".
                  ELSE
                      ASSIGN horarioDoEvento = Crapadp.DsHroeve.
              
                  IF  Crapadp.Dsdiaeve = "?" THEN
                      ASSIGN diasEvento = Crapadp.Dsdiaeve.
                  ELSE
                      ASSIGN diasEvento = "Indefinido".
              END.
          
          IF  msgsDeErro <> "" THEN
              DO:
                {&out} "Erro grave.<br>" msgsDeErro.
                {&DISPLAY} idEvento 
                           cdCooper 
                           dtAnoAge 
                           nrmeseve.
              END.
        
          /*Se o evento estiver cancelado, não imprime todos os dados*/
          IF  crapadp.idstaeve = 2 THEN
              DO:
                  FIND LAST craphep WHERE craphep.cdcooper = 0                AND
                                          craphep.cdagenci = crapadp.nrseqdig 
                                          NO-LOCK NO-ERROR.
                                          
                  IF  AVAILABLE craphep THEN
                        /* *** Dados do evento *** */              
                        {&out} '   <table border="0" cellspacing="1" cellpadding="1" width="100%">' SKIP
                               '      <tr>' SKIP
                               '         <td class="tdDados" align="right" width="15%">' IF  (Crapadp.DtFinEve - Crapadp.DtIniEve) = ? THEN 
                                                                                             '00/' + string(crapadp.nrmeseve,"99") + substring(string(dtanoage),3,4) 
                                                                                         ELSE 
                                                                                         IF  (Crapadp.DtFinEve - Crapadp.DtIniEve) < 1 THEN 
                                                                                             STRING(Crapadp.DtIniEve,"99/99/99") 
                                                                                         ELSE 
                                                                                         IF  Crapadp.QtDiaEve = 2  THEN
                                                                                             (STRING(DAY(Crapadp.DtIniEve)) + '/' + STRING(MONTH(Crapadp.DtIniEve)) + ' e ' + STRING(Crapadp.DtFinEve,"99/99/99"))
                                                                                         ELSE                 
                                                                                         IF  STRING(MONTH(Crapadp.DtIniEve)) = STRING(MONTH(Crapadp.DtFinEve)) THEN
                                                                                             (STRING(DAY(Crapadp.DtIniEve)) + ' a ' + STRING(Crapadp.DtFinEve,"99/99/99"))
                                                                                         ELSE
                                                                                                        (STRING(DAY(Crapadp.DtIniEve)) + '/' + STRING(MONTH(Crapadp.DtIniEve)) + ' a ' + STRING(Crapadp.DtFinEve,"99/99/99")) '</td>' SKIP 
                                '         <td class="tdLabel" align="left" colspan="1" >' linha1 '</td>' SKIP
                                '      <tr>' SKIP
                                '         <td class="tdLabel" colspan="1" ></td>' SKIP
                                '         <td class="tdStatus" align="left" colspan="1">** CANCELADO EM ' craphep.dtmvtolt ' ** </td>' SKIP
                                '      <tr><td colspan="4" align="center"><hr></td></tr>' SKIP
                                '   </table>' SKIP.                               
                         {&out} '   </table>' SKIP.
              END.
          ELSE    
              DO:
                
                  ASSIGN aux_dsdiaeve = TRIM(crapadp.dsdiaeve)
                         aux_dscdiase = "".
                
                  /*ALTERACAO JEAN 29/06/2016*/
                  IF aux_dsdiaeve <> ? AND aux_dsdiaeve <> "" THEN
                    DO:
                    
                      DO aux_contador = 1 TO NUM-ENTRIES(aux_dsdiaeve,","):
                    
                        IF INT(ENTRY(aux_contador,aux_dsdiaeve,",")) = 1 THEN
                        DO:
                          ASSIGN aux_dscdiase = aux_dscdiase + ", Segunda-Feira".
                        END.
                        
                        IF INT(ENTRY(aux_contador,aux_dsdiaeve,",")) = 2 THEN
                        DO:
                          ASSIGN aux_dscdiase = aux_dscdiase + ", Terça-Feira".
                        END.
                        
                        IF INT(ENTRY(aux_contador,aux_dsdiaeve,",")) = 3 THEN
                        DO:
                          ASSIGN aux_dscdiase = aux_dscdiase + ", Quarta-Feira".
                        END.
                        
                        IF INT(ENTRY(aux_contador,aux_dsdiaeve,",")) = 4 THEN
                        DO:
                          ASSIGN aux_dscdiase = aux_dscdiase + ", Quinta-Feira".
                        END.
                        
                        IF INT(ENTRY(aux_contador,aux_dsdiaeve,",")) = 5 THEN
                        DO:
                          ASSIGN aux_dscdiase = aux_dscdiase + ", Sexta-Feira".
                        END.
                        
                        IF INT(ENTRY(aux_contador,aux_dsdiaeve,",")) = 6 THEN
                        DO:
                          ASSIGN aux_dscdiase = aux_dscdiase + ", Sábado".
                        END.
                        
                        IF INT(ENTRY(aux_contador,aux_dsdiaeve,",")) = 0 THEN
                        DO:
                          ASSIGN aux_dscdiase = aux_dscdiase + ", Domingo".
                        END.
                      END.
                      
                  END.
  
                  IF aux_dscdiase <> ? AND aux_dscdiase <> "" THEN
                    DO:
                      
                      ASSIGN aux_dscdiase = TRIM(aux_dscdiase).
                      
                      IF SUBSTRING(aux_dscdiase,1,1) = "," then
                        DO:
                          ASSIGN aux_dscdiase = SUBSTRING(aux_dscdiase,2).
                        END.
                      
                      IF SUBSTRING(aux_dscdiase,LENGTH(aux_dscdiase) - 1,1) = "," then
                        DO:
                          ASSIGN aux_dscdiase = SUBSTRING(aux_dscdiase,1,LENGTH(aux_dscdiase) - 1).
                        END.
                      
                      ASSIGN aux_dscdiase = aux_dscdiase + "."
                             aux_dsdiaeve = aux_dscdiase.
                    END.
              
                  /* *** Dados do evento *** */              
                  {&out} '   <table border="0" cellspacing="1" cellpadding="1" width="100%">' SKIP
                         '      <tr>' SKIP
                         '         <td class="tdDados" align="right" width="15%">' IF  (Crapadp.DtFinEve - Crapadp.DtIniEve) = ? THEN 
                                                                                       '00/' + string(crapadp.nrmeseve,"99") + '/' + substring(string(dtanoage),3,4) 
                                                                                   ELSE 
                                                                                   IF  (Crapadp.DtFinEve - Crapadp.DtIniEve) < 1 THEN 
                                                                                       STRING(Crapadp.DtIniEve,"99/99/99") 
                                                                                   ELSE 
                                                                                   IF  Crapadp.QtDiaEve = 2  THEN
                                                                                       (STRING(DAY(Crapadp.DtIniEve)) + '/' + STRING(MONTH(Crapadp.DtIniEve)) + ' e ' + STRING(Crapadp.DtFinEve,"99/99/99"))
                                                                                   ELSE   
                                                                                   IF  STRING(MONTH(Crapadp.DtIniEve)) = STRING(MONTH(Crapadp.DtFinEve)) THEN
                                                                                       (STRING(DAY(Crapadp.DtIniEve)) + ' a ' + STRING(Crapadp.DtFinEve,"99/99/99"))
                                                                                   ELSE
                                                                                                  (STRING(DAY(Crapadp.DtIniEve)) + '/' + STRING(MONTH(Crapadp.DtIniEve)) + ' a ' + STRING(Crapadp.DtFinEve,"99/99/99")) '</td>' SKIP 
                          '         <td class="tdLabel" align="left" colspan="1" >' linha1 '</td>' SKIP
                          '      <tr>' SKIP
                          '         <td class="tdLabel" colspan="1" ></td>' SKIP
                          '         <td class="tdDados" align="left" colspan="3">' IF ((aux_dscdiase) = ?  OR (aux_dscdiase) = "") THEN 
                                                                                       "" 
                                                                                    ELSE 
                                                                                       "Dias: " aux_dscdiase '</td>' SKIP 
                          '      <tr>' SKIP
                          '         <td class="tdLabel" colspan="1" ></td>' SKIP
                          '         <td class="tdDados" align="left" colspan="3">Local: ' localDoEvento '</td>' SKIP
                          '      <tr>' SKIP
                          '         <td class="tdLabel" colspan="1" ></td>' SKIP
                          '         <td class="tdDados" align="left" colspan="3">Referência: ' referencia '</td>' SKIP
                          '      <tr>' SKIP
                          '         <td class="tdLabel" colspan="1" ></td>' SKIP
                          '         <td class="tdDados" align="left" colspan="3">Rua: ' enderecoDoLocal '</td>' SKIP
                          '      <tr>' SKIP
                          '         <td class="tdLabel" colspan="1" ></td>' SKIP
                          '         <td class="tdDados" align="left" colspan="3">Horário: ' horarioDoEvento '</td>' SKIP.
                  
                   /* Imprime pessoa para a abertura somente para o PROGRID */
                   IF  crapadp.idevento = 1   THEN
                       {&OUT} '      <tr>' SKIP
                              '         <td class="tdLabel" colspan="1" ></td>' SKIP
                              '         <td class="tdDados" align="left" colspan="3">Abertura: ' pessoaAbertura '</td>' SKIP
                              '      </tr>' SKIP.
                  
                   {&out} '      <tr>' SKIP
                          '         <td colspan="4" align="center"><hr></td>' SKIP
                          '      </tr>' SKIP
                          '   </table>' SKIP
                          '<br>' SKIP.
              END.

      END. /*Seleciona os eventos que satisfaçam os parametros*/
      
      /* Verifica se existem evenos para o mes informado*/
      IF  linha1 = "" THEN
          ASSIGN msgsDeErro = msgsDeErro + "-> Não existe movimento para o mes informados.<br>".

      IF  msgsDeErro <> "" THEN
          DO:
              {&out} "Erro grave.<br>" msgsDeErro.
          END.
      ELSE
          {&out} '<br>' SKIP.
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

IF  permiteExecutar = "1" OR permiteExecutar = "2" THEN
    erroNaValidacaoDoLogin(permiteExecutar).
ELSE
DO:
    ASSIGN idEvento  = INTEGER(GET-VALUE("parametro1"))
           cdCooper  = INTEGER(GET-VALUE("parametro2"))
           dtAnoAge  = INTEGER(GET-VALUE("parametro3"))
           nrmeseve  = INTEGER(GET-VALUE("parametro4"))            
           tpevento  = INTEGER(GET-VALUE("parametro5")) NO-ERROR.  
           
    FIND crapcop WHERE crapcop.cdcooper = cdCooper 
                       NO-LOCK NO-ERROR.
    
    IF  AVAILABLE crapcop THEN
        DO:
           ASSIGN imagemDoProgrid      = "/cecred/images/geral/logo_cecred.gif".

           IF  INDEX(crapcop.nmrescop, " ") <> 0  THEN
               DO: 
                   aux_nmrescop = LC(TRIM(crapcop.nmrescop)).
                   SUBSTRING( aux_nmrescop, (INDEX(aux_nmrescop, " ")),1) = "_".
                   imagemDaCooperativa =  "/cecred/images/admin/logo_" +  aux_nmrescop.
               END.
           ELSE
               imagemDaCooperativa  = "/cecred/images/admin/logo_" + TRIM(LC(crapcop.nmrescop)) + ".gif".
          
       END.

        IF  msgsDeErro <> "" THEN
            DO:
               {&out} "Erro grave.<br>" msgsDeErro.
               {&DISPLAY} idEvento 
                          cdCooper 
                          dtAnoAge 
                          nrmeseve.
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

