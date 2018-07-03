/*
 * Programa wpgd0042a.p - Pr�-Inscritos (chamado a partir dos dados de wpgd0042) 
 
*/
/*****************************************************************************

 Altera��es: 17/01/08 - Listar somente participantes que compareceram ao evento (David).

             03/11/08 - Incluido widget-pool (Martin)

             10/12/2008 - Melhoria de performance para a tabela gnapses (Evandro).
             
             09/06/2011 - Corre��o da quebra de p�gina (Isara - RKAM).
             
             30/08/2011 - Aumentado em 20 posicoes, o tamanho do campo para
                          e-mail. (Fabricio)
                                                  
             05/06/2012 - Adapta��o dos fontes para projeto Oracle. Alterado
                          busca na gnapses de CONTAINS para MATCHES
                          (Guilherme Maba).
                                                    
             28/11/2012 - Substituir tabela "gncoper" por "crapcop"
                          (David Kruger).
                          
             04/04/2013 - Altera��o para receber logo na alto vale,
                          recebendo nome de viacrediav e buscando com
                          o respectivo nome (David Kruger).
             
             11/09/2013 - Nova forma de chamar as ag�ncias, de PAC agora 
                          a escrita ser� PA (Andr� Euz�bio - Supero).
                          
             03/01/2014 - Incluir telefone celular se for inscricao de 
                          cooperado (Carlos)
                          
             27/06/2016 - Alterado o nome do relatorio de Pre-Inscritos para Inscri��es e 
                          inclusao da opcao faltantes.
                          PRJ229 - Melhorias OQS(Odirlei-AMcom)
                             
             05/06/2017 - Alterado as colunas de exibi�ao conforme tipo de evento,
                          Prj. 322 (Jean Michel).   
						  
             22/02/2018 - Pj 322 - SM 10 - Altera��o Relat�rio de Inscri��es (M�rcio Mouts)
                        - Incluir as colunas de Telefone, Celular e e-mail no relat�rio de inscri��es no menu Assembleias		
						
			 06/06/2018 - Ajustes referente alteracao da nova marca (P413 - Jonata Mouts).	 
                          
 ****************************************************************************/
 
 create widget-pool.
 
/*****************************************************************************/
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
DEFINE VARIABLE aux_tptitrel                 AS CHARACTER. 
DEFINE VARIABLE nomeDoRelatorio              AS CHARACTER.
DEFINE VARIABLE nmresage                     AS CHARACTER.
DEFINE VARIABLE dtinieve                     AS CHARACTER  FORMAT "x(10)".
DEFINE VARIABLE flginter                     AS LOGICAL.

DEFINE VARIABLE imagemDoProgrid              AS CHARACTER.
DEFINE VARIABLE imagemDaCooperativa          AS CHARACTER.
DEFINE VARIABLE nomeDaCooperativa            AS CHARACTER.

DEFINE VARIABLE primeiroRegistro             AS LOGICAL.
DEFINE VARIABLE aux_nmrescop                 AS CHARACTER.

DEFINE BUFFER crabtab FOR craptab.


                           
/*****************************************************************************/
/*   Bloco de includes                                                       */
/*****************************************************************************/

{src/web/method/wrap-cgi.i}

/*****************************************************************************/
/*   Bloco de fun�oes                                                        */
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

FUNCTION Relatorio RETURNS LOGICAL ():

    DEFINE VARIABLE aux_cor      AS CHARACTER        NO-UNDO.
    DEFINE VARIABLE aux_contador AS INTEGER          NO-UNDO.
                
    ASSIGN primeiroRegistro = TRUE
           aux_cor          = ""
           aux_contador     = 4. /* 4, por causa do cabe�alho */
   FOR EACH crapidp WHERE crapidp.idevento = crapadp.idevento        AND
                           crapidp.cdcooper = crapadp.cdcooper        AND
                          (crapidp.cdageins = cdagenci                OR
                           cdagenci         = 0) /*Assembleia*/       AND
                           crapidp.dtanoage = crapadp.dtanoage        AND
                           crapidp.nrseqeve = crapadp.nrseqdig        AND 
                          (crapidp.idstains = tipoDeRelatorio         OR
                          ((tipoDeRelatorio = 6 OR tipoDeRelatorio = 7 )AND
                           crapidp.idstains = 2)                      OR
                           tipoDeRelatorio  = 0) /*TODOS*/            AND
                          (crapidp.flginsin = flginter                OR
                           flginter         = FALSE) /*INTERNET*/     NO-LOCK
                           BY crapidp.nminseve BY crapidp.nrdconta :

        IF  tipoDeRelatorio   = 6 AND 
            crapidp.qtfaleve  > 0 AND 
            crapadp.idstaeve <> 2 AND
          ((crapidp.qtfaleve * 100) / crapadp.qtdiaeve) > (100 - crapedp.prfreque) THEN
            NEXT.
            
        /* Regra faltantes � inversa a de participantes*/    
        IF  tipoDeRelatorio   = 7 AND 
            NOT (crapidp.qtfaleve  > 0 AND 
                 crapadp.idstaeve <> 2 AND
               ((crapidp.qtfaleve * 100) / crapadp.qtdiaeve) > (100 - crapedp.prfreque)) THEN
            NEXT.                                                                                                   
        
        IF   primeiroRegistro   THEN
        DO:
            ASSIGN primeiroRegistro = FALSE.
                        
            {&out}  '<table class="tab2" border="1" width="100%">' SKIP
                    '  <tr bgColor="#DBDBDB">' SKIP
                    '    <td>Nome</td>' SKIP
                    '    <td>Conta</td>' SKIP.
                    IF crapadp.idevento = 1 THEN
                      DO:
                        {&out}  '    <td style="width:77px;padding-left:2px">Telefone</td>' SKIP
                    '    <td style="width:77px;padding-left:2px">Celular</td>' SKIP
                        IF tipoDeRelatorio <> 6 AND tipoDeRelatorio <> 7 THEN '    <td>E-mail</td>' ELSE '' SKIP.
                      END.
                    Else
                      DO: /* PJ 322 - SM 10*/
                        {&out}  '    <td style="width:77px;padding-left:2px">PA</td>' SKIP
                    '   <td style="width:77px;padding-left:2px">Telefone</td>' SKIP        /* PJ 322 - SM 10*/
					'   <td style="width:77px;padding-left:2px">Celular</td>' SKIP         /* PJ 322 - SM 10*/
                        IF tipoDeRelatorio <> 6 AND tipoDeRelatorio <> 7 THEN '    <td>E-mail</td>' ELSE '' SKIP.	/* PJ 322 - SM 10*/				  
                      END. /* PJ 322 - SM 10*/
                      
            {&out}  '    <td align="center">V�nc./Inscr.</td>' SKIP
                    '    <td>Observa��o</td>' SKIP
                    IF tipoDeRelatorio <> 6 AND tipoDeRelatorio <> 7 THEN '    <td>Uso manual</td>' ELSE '' SKIP
                    '  </tr>' SKIP.                        
        END.             

        IF  aux_cor = "#FFFFFF"   THEN
            aux_cor = "#F7F7F7".
        ELSE
            aux_cor = "#FFFFFF".

        aux_contador = aux_contador + 1.

        {&out} '  <tr bgColor=' aux_cor ' height="42">' SKIP
               '    <td width="260">' crapidp.nminseve '</td>' SKIP
               '    <td class="tab2" align="right" width="60">' IF crapidp.nrdconta <> 0 THEN STRING(crapidp.nrdconta,"zzzz,zzz,9") ELSE '&nbsp;' '</td>' SKIP.
       
       IF crapadp.idevento = 1 THEN
        DO:
          {&out} '    <td class="tab2" align="left" >(' crapidp.nrdddins ') ' crapidp.nrtelins '</td>' SKIP
               '    <td class="tab2" align="left" >'.
        
        /* Incluir telefone celular se for inscricao de cooperado */
        IF  crapidp.nrdconta <> 0 THEN 
        DO:
            FIND FIRST craptfc WHERE craptfc.cdcooper = crapidp.cdcooper AND
                                     craptfc.nrdconta = crapidp.nrdconta AND
                                     craptfc.idseqttl = crapidp.idseqttl AND
                                     craptfc.tptelefo = 2
                                     NO-LOCK NO-ERROR.
                
            IF AVAIL craptfc THEN
            {&out} '(' craptfc.nrdddtfc ') ' craptfc.nrtelefo.
        END.

        {&out} '</td>' SKIP
          IF tipoDeRelatorio <> 6 AND tipoDeRelatorio <> 7 THEN '    <td class="tab2" width="160">' + crapidp.dsdemail + '</td>' ELSE '' SKIP.
        END.
        Else
          DO:
            FIND FIRST crapage WHERE crapage.cdcooper = crapidp.cdcooper
                                 AND crapage.cdagenci = crapidp.cdageins NO-LOCK NO-ERROR NO-WAIT.
            IF AVAILABLE crapage THEN   
              DO:			
              {&out} '<td class="tab2" width="160">' + crapage.nmresage + '</td>' SKIP.
			  
			  /*In�cio PJ 322 - SM 10 */
              {&out} '    <td class="tab2" align="left" >(' crapidp.nrdddins ') ' crapidp.nrtelins '</td>' SKIP
               '    <td class="tab2" align="left" >'.
                /* Incluir telefone celular se for inscricao de cooperado */
                IF  crapidp.nrdconta <> 0 THEN 
                  DO:
                    FIND FIRST craptfc WHERE craptfc.cdcooper = crapidp.cdcooper AND
                                             craptfc.nrdconta = crapidp.nrdconta AND
                                             craptfc.idseqttl = crapidp.idseqttl AND
                                             craptfc.tptelefo = 2
                                             NO-LOCK NO-ERROR.
                
                    IF AVAIL craptfc THEN
                      {&out} '(' craptfc.nrdddtfc ') ' craptfc.nrtelefo.
                  END.

                {&out} '</td>' SKIP
                IF tipoDeRelatorio <> 6 AND tipoDeRelatorio <> 7 THEN '    <td class="tab2" width="160">' + crapidp.dsdemail + '</td>' ELSE '' SKIP.
			  /*Fim PJ 322 - SM 10  */
			  END.
            ELSE
			  DO:
              {&out} '<td class="tab2" width="160">SEM PA</td>' SKIP.
        
			  /*In�cio PJ 322 - SM 10 */
              {&out} '    <td class="tab2" align="left" >(' crapidp.nrdddins ') ' crapidp.nrtelins '</td>' SKIP
                     '    <td class="tab2" align="left" >'.
        /* Incluir telefone celular se for inscricao de cooperado */
        IF  crapidp.nrdconta <> 0 THEN 
        DO:
            FIND FIRST craptfc WHERE craptfc.cdcooper = crapidp.cdcooper AND
                                     craptfc.nrdconta = crapidp.nrdconta AND
                                     craptfc.idseqttl = crapidp.idseqttl AND
                                     craptfc.tptelefo = 2
                                     NO-LOCK NO-ERROR.
                
            IF AVAIL craptfc THEN
            {&out} '(' craptfc.nrdddtfc ') ' craptfc.nrtelefo.
        END.

        {&out} '</td>' SKIP
                IF tipoDeRelatorio <> 6 AND tipoDeRelatorio <> 7 THEN '    <td class="tab2" width="160">' + crapidp.dsdemail + '</td>' ELSE '' SKIP.
			  /*Fim PJ 322 - SM 10  */
			  END.
			
          END.
         {&out}       
               '    <td class="tab2" align="center" width="70">' 
                      IF crapidp.tpinseve = 1 THEN 'PR�PRIA' ELSE ENTRY(LOOKUP(STRING(crapidp.cdgraupr), crabtab.dstextab) - 1, crabtab.dstextab) 
                      IF tipoDeRelatorio = 0 THEN '<br>(' + ENTRY(crapidp.idstains * 2 - 1,craptab.dstextab) + ')' ELSE '' 
               '    </td>' SKIP
               '    <td class="tab2">' IF tipoDeRelatorio <> 6 AND tipoDeRelatorio <> 7 THEN crapidp.dsobsins ELSE '&nbsp;' '</td>' SKIP
               IF tipoDeRelatorio <> 6 AND tipoDeRelatorio <> 7 THEN '    <td class="tab2" width="150">_________________________<br>_________________________<br>_________________________</td>' ELSE '' SKIP
               '  </tr>' SKIP.

        /* Faz a quebra de p�gina */
        IF   aux_contador = 22   THEN  /* 25 */
        DO:
            {&out} '</table>' SKIP
                   '<br style="page-break-before:always;">' SKIP 
                   '<table class="tab2" border="1" width="100%">' SKIP
                   '  <tr bgColor="#DBDBDB">' SKIP
                   '    <td>Nome</td>' SKIP
                   '    <td>Conta</td>' SKIP.
				   
				   IF crapadp.idevento = 1 THEN
				     DO:
							{&out}  ' <td style="width:77px;padding-left:2px" align="left">Telefone</td>' SKIP
                      ' <td style="width:77px;padding-left:2px" align="left">Celular</td>' SKIP
								  	 IF tipoDeRelatorio <> 6 AND tipoDeRelatorio <> 7 THEN '    <td>E-mail</td>' ELSE '' SKIP.
				     END.
					 Else
					  DO:
						{&out}  '    <td style="width:77px;padding-left:2px">PA</td>' SKIP
                                 '   <td style="width:77px;padding-left:2px">Telefone</td>' SKIP        /* PJ 322 - SM 10*/
					             '   <td style="width:77px;padding-left:2px">Celular</td>' SKIP         /* PJ 322 - SM 10*/
                        IF tipoDeRelatorio <> 6 AND tipoDeRelatorio <> 7 THEN '    <td>E-mail</td>' ELSE '' SKIP.	/* PJ 322 - SM 10*/								
					  END.
						
				   {&out} '    <td align="center">V�nc./Inscr.</td>' SKIP
                   '    <td>Observa��o</td>' SKIP
                   IF tipoDeRelatorio <> 6 AND tipoDeRelatorio <> 7 THEN '    <td>Uso manual</td>' ELSE '' SKIP
                   '  </tr>' SKIP.

            aux_contador = 0.
        END.
    END.
           
    IF   primeiroRegistro   THEN
    DO:
       IF tipoDeRelatorio = 6 THEN 
          aux_tptitrel = "participantes".
       ELSE IF tipoDeRelatorio = 7 THEN    
          aux_tptitrel = "faltantes".
       ELSE 
          aux_tptitrel = "inscritos".
    
        msgsDeErro = "N�o h� registros de " + aux_tptitrel + " para o filtro informado.".

        RETURN FALSE.
    END.
    
    RETURN TRUE.
END.

FUNCTION montaTela RETURNS LOGICAL ():

    IF tipoDeRelatorio = 6 THEN 
        aux_tptitrel = "Participantes".
    ELSE IF tipoDeRelatorio = 7 THEN    
        aux_tptitrel = "Faltantes".
    ELSE 
        aux_tptitrel = "Inscri��es".
        
    {&out} '<html>' SKIP
           '<head>' SKIP
           '<title>Progrid - ' aux_tptitrel '</title>' SKIP.

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
           '            <img src="/cecred/images/botoes/btn_imprimir.gif" alt="Imprimir" style="cursor: hand" onClick="alert(~'ATEN��O! Certifique-se que a p�gina esteja como papel A4.~'); document.all.botoes.style.visibility = ~'hidden~'; print(); document.all.botoes.style.visibility = ~'visible~';">' SKIP
           '         </td>' SKIP
           '      </tr>' SKIP
           '   </table>' SKIP
           '</div>' SKIP.

    {&out} '   <table border="0" cellspacing="0" cellpadding="0" width="100%">' SKIP
           '      <tr>' SKIP
           '         <td class="tdprogra" colspan="5" align="right">wpgd0042a - ' TODAY '</td>' SKIP
           '   </table>' SKIP. 

    /* *** Logo *** */
    {&out} '   <table border="0" cellspacing="0" cellpadding="0" width="100%" class="tab1">' SKIP
           '      <tr>' SKIP
           '         <td align="center"><img src="' imagemDoProgrid '" border="0"></td>' SKIP
           '         <td class="tdTitulo1" colspan="4" align="center">' nomeDaCooperativa ' - ' aux_tptitrel ' - ' dtAnoAge '</td>' SKIP
           '         <td align="center"><img src="' imagemDaCooperativa '" border="0"></td>' SKIP
           '      </tr>' SKIP
           '      <tr>' SKIP 
           '        <td colspan="6">&nbsp;</td>' SKIP
           '      </tr>' SKIP
           '      <tr>' SKIP
           '         <td align="center" class="tdTitulo2" colspan="6">' crapedp.nmevento '</td>' SKIP
           '      </tr>' SKIP
           '      <tr>' SKIP 
           '        <td colspan="6">&nbsp;</td>' SKIP
           '      </tr>' SKIP
           '      <tr>' SKIP
           '         <td align="left" class="tdTitulo2" colspan="4">&nbsp;&nbsp;PA: ' nmresage '</td>' SKIP
           '         <td align="right" class="tdTitulo2" colspan="2">STATUS: ' IF tipoDeRelatorio = 0 THEN "TODOS" 
                                                                               ELSE IF tipoDeRelatorio = 6 THEN "Participantes" 
                                                                               ELSE IF tipoDeRelatorio = 7 THEN "Faltantes" 
                                                                               ELSE ENTRY(tipoDeRelatorio * 2 - 1,craptab.dstextab) '&nbsp;&nbsp;</td>' SKIP
           '      </tr>' SKIP.

    IF   flginter   THEN
         {&OUT} ' <tr>' SKIP
                '   <td align="left" class="tdTitulo2" colspan="4">&nbsp;</td>' SKIP
                '   <td align="right" class="tdLabel" colspan="2">Somente inscritos pela internet&nbsp;</td>' SKIP
                ' </tr>' SKIP.

    {&OUT} '   </table>' SKIP
           '   <br>' SKIP.

    IF   tipoDeRelatorio >= 0   AND  tipoDeRelatorio <= 7   THEN
         Relatorio().
    ELSE
         msgsDeErro = msgsDeErro + "-> Tipo de relat�rio ainda n�o implementado.<br>".

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
                 flginter                     = LOGICAL(GET-VALUE("parametro7")) NO-ERROR.          

          FIND crapcop WHERE crapcop.cdcooper = cdCooper NO-LOCK NO-ERROR.

          IF AVAILABLE crapcop   THEN
             DO:
                ASSIGN imagemDoProgrid      = "/cecred/images/geral/logo_ailos.gif"
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

          /* Busca o evento */
          FIND FIRST crapadp WHERE crapadp.idevento = idevento           AND
                                   crapadp.cdcooper = cdcooper           AND
                                  (crapadp.cdagenci = cdagenci   OR
                                   crapadp.cdagenci = 0) /*Assembleia*/  AND
                                   crapadp.nrseqdig = nrseqeve           NO-LOCK NO-ERROR.

          /* Busca o PA */
          FIND crapage WHERE crapage.cdcooper = crapadp.cdcooper   AND
                             crapage.cdagenci = cdagenci           NO-LOCK NO-ERROR.
        
          IF   AVAILABLE crapage   THEN
               nmresage = crapage.nmresage.
          ELSE
          IF   cdagenci = 0   THEN
               nmresage = "TODOS OS PA'S".

          /* se for PROGRID, verifica se h� PA's agrupados */
          IF   crapadp.idevento = 1    THEN
               FOR EACH crapagp WHERE crapagp.cdcooper  = crapadp.cdcooper  AND
                                      crapagp.dtanoage  = crapadp.dtanoage  AND
                                      crapagp.cdagenci <> crapagp.cdageagr  AND
                                      crapagp.cdageagr  = crapadp.cdagenci  NO-LOCK:
               
                   FIND crapage WHERE crapage.cdcooper = crapagp.cdcooper   AND
                                      crapage.cdagenci = crapagp.cdagenci   NO-LOCK NO-ERROR.
               
                   ASSIGN nmresage = nmresage + " ~/ " + crapage.nmresage.
               END.
          
          /* Busca o nome do EVENTO */
          FIND crapedp WHERE crapedp.idevento = crapadp.idevento   AND
                             crapedp.cdcooper = crapadp.cdcooper   AND
                             crapedp.dtanoage = crapadp.dtanoage   AND
                             crapedp.cdevento = crapadp.cdevento   NO-LOCK NO-ERROR.

          /* Status das pr�-inscri��es */
          FIND FIRST craptab WHERE craptab.cdcooper = 0               AND
                                   craptab.nmsistem = "CRED"          AND
                                   craptab.tptabela = "CONFIG"        AND    
                                   craptab.cdempres = 0               AND  
                                   craptab.cdacesso = "PGSTINSCRI"    AND  
                                   craptab.tpregist = 0               NO-LOCK NO-ERROR.

          /* Grau de parentesco */
          FIND FIRST crabtab WHERE crabtab.cdcooper = crapadp.cdcooper   AND
                                   crabtab.nmsistem = "CRED"             AND
                                   crabtab.tptabela = "GENERI"           AND
                                   crabtab.cdempres = 0                  AND
                                   crabtab.cdacesso = "VINCULOTTL"       AND
                                   crabtab.tpregist = 0                  NO-LOCK NO-ERROR.

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

