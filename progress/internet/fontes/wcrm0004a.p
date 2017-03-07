/*
 * Programa wpgd004a.p - Exibe certificado do evento do Progrid no Internet Bank, Prj. 229 (Jean Michel)
 * 
 * Alterações:  28/10/2016 - Inclusão da chamada da procedure pc_informa_acesso_progrid
 *							 para gravar log de acesso. (Jean Michel)
 *
 *	            17/11/2016 - Inclusão de assinatura. (Jean Michel)
 *
 *	            07/03/2017 - Alteração de diretório da cooperativa Viacredi Alto Vale. (Jean Michel)
*/

	{ sistema/generico/includes/var_log_progrid.i }
	
  CREATE WIDGET-POOL.

  DEF VAR aux_idevento AS INTEGER.
  DEF VAR aux_cdcooper AS INTEGER.
  DEF VAR aux_cdagenci AS INTEGER.
  DEF VAR aux_dtanoage AS INTEGER.
  DEF VAR aux_cdevento AS INTEGER.
  DEF VAR aux_nrseqeve AS INTEGER.
  DEF VAR aux_tpevento AS INTEGER.
  DEF VAR aux_nrdconta AS INTEGER.
  DEF VAR aux_idseqttl AS INTEGER.
  DEF VAR aux_contador AS INTEGER.
  
  DEF VAR aux_idstains AS INTEGER INIT 2.

  DEF VAR aux_nmrescop AS CHARACTER NO-UNDO.
  DEF VAR aux_nmtipeve AS CHARACTER NO-UNDO.
  DEF VAR aux_nmcondut AS CHARACTER NO-UNDO.
  DEF VAR aux_qtcarhor AS CHARACTER NO-UNDO.
  DEF VAR aux_nmcidade AS CHARACTER NO-UNDO.
  DEF VAR aux_dscritic AS CHARACTER NO-UNDO.
  DEF VAR aux_nmdircop AS CHARACTER NO-UNDO.
  
  DEF VAR aux_nommeses AS CHARACTER INITIAL["janeiro,fevereiro,março,abril,maio,junho,julho,agosto,setembro,outubro,novembro,dezembro"].
                             
  {src/web/method/wrap-cgi.i}

FUNCTION montaCertificado RETURNS LOGICAL():
    
  IF aux_dscritic <> "" THEN  
    DO:
      {&out} '<script>alert("Houve erro na geraçao do certificado. ERRO: ' + aux_dscritic + '"); window.close();</script>'.
    END.
  ELSE
    DO:
      {&out} '<html>' SKIP
             '<head>' SKIP
             '<title>Progrid - Certificado</title>' SKIP.
             {&out} '<style>' SKIP
                    'body ~{ background-color: #FFFFFF; size: landscape;}' SKIP
                    '   .inputFreq     ~{ height: 18px; font-size: 10px ; color:#000066;}' SKIP
                    '   .a3            ~{ font-family: DIN-BLACK, sans-serif; color:#2d5495;font-size: 28px; font-weight: bold;}' SKIP
                    '   .a4            ~{ font-family: DIN-REGULAR, sans-serif; color:#2d5495;font-size: 26px; font-weight: bold;}' SKIP
                    '   .a5            ~{ font-family: DIN-REGULAR, sans-serif; color:#2d5495;font-size: 28px; font-weight: bold;}' SKIP
                    '   .data          ~{ font-family: DIN-REGULAR, sans-serif; color:#2d5495;font-size: 26px; font-weight: bold;}' SKIP
                    '</style><style type="text/css" media="print">@page ~{size: landscape; }</style><body onload="imprimir();">' SKIP.
                                
       FOR EACH crapidp WHERE crapidp.cdcooper = aux_cdcooper
                          AND crapidp.nrseqeve = aux_nrseqeve
                          AND crapidp.nrdconta = aux_nrdconta
                          AND crapidp.idstains = aux_idstains NO-LOCK,
           EACH crapass WHERE crapass.cdcooper = crapidp.cdcooper
                          AND crapass.nrdconta = crapidp.nrdconta
                          AND crapass.inpessoa = 1 NO-LOCK
                           BY crapidp.nminseve:
            /*{&out} '<div id="imprimir" name="imprimir" align="right" style="border: 0px solid orange; height:848px; float: left; position: relative; text-align: center; "><img src="/extrato-' + (IF aux_nmrescop <> 'VIACREDI AV' THEN LOWER(aux_nmrescop) ELSE 'viacrediav') + '/crm/images/icones/imprimir.gif" onclick="imprimir();"/></div>' SKIP.*/
            {&out} '<div id="conteudo" name="conteudo" align="center" style="border: 0px solid orange; height:848px; float: left; position: relative; text-align: center; ">' SKIP.
            
            {&out} '<div style="position: absolute; height:848px; border: 0px solid green; float:left; z-index:1; text-alig:center; padding-top: 10px; padding-left: 20px; ">' SKIP.
            
            {&out}  '<img style=" height:848px;" src="/extrato-' + (IF aux_nmrescop <> 'VIACREDI AV' THEN LOWER(aux_nmrescop) ELSE 'viacrediav') + '/crm/images/certificados/' + 
                    (IF aux_nmrescop <> 'VIACREDI AV' THEN LOWER(aux_nmrescop) ELSE 'altovale') + '.jpg"/></div>' SKIP.
                    
            {&out} '<div id="texto" name="texto" style="position: absolute; padding-top:300px; text-align:center; border: 0px solid red; z-index:2; width:1200px;" >'.
            
            {&out} '<p>'
                   '   <a class="a5">Certificamos que&nbsp;</a>'
                   '   <a class="a3">' crapidp.nminseve '</a>'
                   '   <a class="a5">&nbsp;participou</br></a>'
				   '   <a class="a5">&nbsp;' IF aux_nmtipeve = "evento" THEN ' do evento' ELSE IF aux_nmtipeve = "palestra" THEN ' da palestra' ELSE (' do ' + LC(aux_nmtipeve)) ' </a>'.
                   
                
            {&out} '<a class="a3">' crapedp.nmevento ',</br></a>'
            '   <a CLASS="a5">conduzido por </a>'
            '   <a CLASS="a3">' aux_nmcondut  '.</a>'
            '</p>' SKIP.
            
            /* Verifica se o curso foi em um único dia, se foi coloca apenas dia, mes, ano e a duração senão, mostra o periodo em que o evento foi realizado */
            
            IF (crapadp.dtfineve - crapadp.dtinieve) = 0 THEN
              {&out} '<p>'
                     '   <a class="a5">O evento foi realizado em ' DAY(crapadp.dtinieve) ' de ' ENTRY(MONTH(crapadp.dtinieve),aux_nommeses) ' de ' YEAR(crapadp.dtinieve) ',</a>'.
            ELSE
            {&out} '<p>'
            '   <a class="a5">O evento foi realizado no período de&nbsp;</a>'
            '   <a class="a5">' DAY(crapadp.dtinieve) ' de ' ENTRY(MONTH(crapadp.dtinieve),aux_nommeses) ' a ' DAY(crapadp.dtfineve) ' de ' ENTRY(MONTH(crapadp.dtfineve),aux_nommeses) ' de ' YEAR(crapadp.dtfineve) ',</a></br>'.
            
            /* Verifica se foi mais de 1 hora mostrando um 's' após a hora de duração */
            
            IF INT(ENTRY(2,aux_qtcarhor,",")) <> 0  THEN
              {&out} '   <a class="a5">com duração de ' ENTRY(1,aux_qtcarhor,",") 'h' ENTRY(2,aux_qtcarhor,",") 'min.</a>'
                     '</p></div>' SKIP.
            ELSE
              {&out} '   <a class="a5">com duração de ' ENTRY(1,aux_qtcarhor,",") ' hora(s).</a>'
                     '</p></div>' SKIP.
            
            /* Verifica se a data do evento foi concluido em um unico dia para ajusta os espaçamentos entre o texto e a assinatura.
               Obs: primeira situação do if é que foi realizado em um unico dia */
            
            {&out} '<div style="clear:both">'
                    '<div id="assinatura_imagem" name="assinatura_imagem" style="position: absolute; padding-left: 450px; padding-top: 430px; z-index:4;">'
                    '<img style=" height:400px;" src="/extrato-' + (IF aux_nmrescop <> 'VIACREDI AV' THEN LOWER(aux_nmrescop) ELSE 'viacrediav') + '/crm/images/assinaturas/moacir_krambeck.png"/>'
                    '</div>'
                    '<div id="assinatura_texto" name="assinatura_texto" style="position: absolute; padding-left: 270px; margin-top: 580px; z-index:5;">'
                    '<a align="center" class="a4">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ________________________________________________________ </a>'
                    '</br>'
                    '<a align="center" class="a4">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Moacir Krambeck - Presidente Sistema CECRED</a>' 
                    '</div><div style="clear:both">' SKIP.
            
            {&out} '<div style="clear:both"><div id="data" name="data" style="position: relative; padding-left: 260px; border: 0px solid red; padding-top: 700px; z-index:3;">'
                   '   <p align="LEFT"> <a CLASS="data">' aux_nmcidade ', ' DAY(TODAY) ' de ' ENTRY(MONTH(TODAY),aux_nommeses) ' de ' YEAR(TODAY) '.</a> </p>'
                   '</div><div style="clear:both">' SKIP.
            
            {&out} '</div></div></div>' SKIP.
                          
        END. /* for each */

				{&out} '<script> function imprimir() ~{alert(~'ATENÇÃO! Certifique-se que a página esteja configurada no modo PAISAGEM.\\r\\rCASO QUEIRA IMPRIMIR NOVAMENTE PRESSIONE A TECLA ALT -> MENU ARQUIVO -> IMPRIMIR~'); print();~} </script>' SKIP.
				
        {&out} '</body>' SKIP
               '</html>' SKIP.
    END.
    
  RETURN TRUE.

END FUNCTION. /* montaTela RETURNS LOGICAL () */

  output-content-type("text/html").

  ASSIGN aux_idevento = INTEGER(GET-VALUE("aux_idevento"))
         aux_cdcooper = INTEGER(GET-VALUE("aux_cdcooper"))
         aux_nrdconta = INTEGER(GET-VALUE("aux_nrdconta"))
         aux_dtanoage = INTEGER(GET-VALUE("aux_dtanoage"))
         aux_cdevento = INTEGER(GET-VALUE("aux_cdevento"))
         aux_nrseqeve = INTEGER(GET-VALUE("aux_nrseqeve"))
         aux_idseqttl = INTEGER(GET-VALUE("aux_idseqttl"))
         aux_tpevento = INTEGER(GET-VALUE("aux_tpevento")).
  
  RUN insere_log_progrid("WPGD0004a.p",STRING(aux_idevento) + "|" + STRING(aux_cdcooper) + "|" + STRING(aux_nrdconta) + "|" + STRING(aux_dtanoage)).
	
  FOR FIRST crapass FIELDS(cdagenci) WHERE crapass.cdcooper = aux_cdcooper
                                       AND crapass.nrdconta = aux_nrdconta NO-LOCK. END.
  
  IF AVAILABLE crapass THEN
    ASSIGN aux_cdagenci = crapass.cdagenci.
  /* Informações da Agenda do Progrid por PAC */
  FIND crapadp WHERE crapadp.nrseqdig = aux_nrseqeve NO-LOCK NO-ERROR.
	
	IF NOT AVAILABLE crapadp THEN
    ASSIGN aux_dscritic = aux_dscritic + "-> Registro CRAPADP não esta disponivel.".
	ELSE
		ASSIGN aux_cdagenci = crapadp.cdagenci.
		
  /* Dados do PA */
  FIND crapage WHERE crapage.cdcooper = aux_cdcooper
                 AND crapage.cdagenci = aux_cdagenci NO-LOCK NO-ERROR.

  IF AVAILABLE crapage THEN
    DO:
      ASSIGN aux_nmcidade = crapage.nmcidade.
    END.
  ELSE
    ASSIGN aux_nmcidade  = "".

  /* Informações da Agenda do Progrid por PAC */
  /*FIND crapadp WHERE crapadp.nrseqdig = aux_nrseqeve NO-LOCK NO-ERROR.
  
  IF NOT AVAILABLE crapadp THEN
    ASSIGN aux_dscritic = aux_dscritic + "-> Registro CRAPADP não esta disponivel.".*/
  
  /* Localiza evento */
  FIND crapedp WHERE crapedp.idevento = aux_idevento
                 AND crapedp.cdcooper = aux_cdcooper
                 AND crapedp.dtanoage = aux_dtanoage
                 AND crapedp.cdevento = aux_cdevento NO-LOCK NO-ERROR.

  IF NOT AVAILABLE crapedp THEN
    ASSIGN aux_dscritic = aux_dscritic + "-> Registro CRAPEDP não esta disponivel.".
  ELSE
    DO:
      FIND craptab WHERE craptab.cdcooper = 0
                     AND craptab.nmsistem = "CRED"
                     AND craptab.tptabela = "CONFIG"
                     AND craptab.cdempres = 0
                     AND craptab.cdacesso = "PGTPEVENTO"
                     AND craptab.tpregist = 0 NO-LOCK NO-ERROR.
      
      IF AVAILABLE craptab THEN
        IF craptab.dstextab = "" THEN
          ASSIGN aux_nmtipeve = "evento".
        ELSE
          IF NUM-ENTRIES(craptab.dstextab) >= 2 THEN
            DO:
              ASSIGN aux_nmtipeve = "evento".
              DO aux_contador = 2 TO NUM-ENTRIES(craptab.dstextab) BY 2:
                IF INTEGER(ENTRY(aux_contador,craptab.dstextab)) = crapedp.tpevento THEN
                  ASSIGN aux_nmtipeve = ENTRY(aux_contador - 1,craptab.dstextab).
              END.
            END.
          ELSE
            ASSIGN aux_nmtipeve = "evento".
      ELSE
        ASSIGN aux_nmtipeve = "evento".
    END.

  /* *** Localiza custo do evento *** */
  FIND crapcdp WHERE crapcdp.idevento = aux_idevento
                 AND crapcdp.cdcooper = aux_cdcooper
                 AND crapcdp.cdagenci = aux_cdagenci
                 AND crapcdp.dtanoage = aux_dtanoage
                 AND crapcdp.tpcuseve = 1             /* direto */
                 AND crapcdp.cdevento = aux_cdevento
                 AND crapcdp.cdcuseve = 1 /* honorários */  NO-LOCK NO-ERROR.

  IF NOT AVAILABLE crapcdp THEN
    ASSIGN aux_dscritic = aux_dscritic + "-> Registro CRAPCDP não esta disponivel.".

  /* Localiza proposta do evento */
  FIND gnappdp WHERE gnappdp.idevento = aux_idevento
                 AND gnappdp.cdcooper = 0
                 AND gnappdp.nrcpfcgc = crapcdp.nrcpfcgc
                 AND gnappdp.nrpropos = crapcdp.nrpropos NO-LOCK NO-ERROR.

  IF NOT AVAILABLE gnappdp THEN
    ASSIGN aux_dscritic = aux_dscritic + "-> Registro GNAPPDP não esta disponivel.".
  ELSE
    ASSIGN aux_qtcarhor = STRING(gnappdp.qtcarhor,"zzz9.99").

  FIND crapcop WHERE crapcop.cdcooper = aux_cdcooper NO-LOCK NO-ERROR.

  IF NOT AVAILABLE crapcop THEN
    ASSIGN aux_dscritic = aux_dscritic + "-> Registro CRAPCOP não esta disponivel.".
  ELSE
    ASSIGN aux_nmrescop = TRIM(LOWER(crapcop.nmrescop))
           aux_nmdircop = TRIM(UPPER(crapcop.nmtitcop)).

  IF aux_nmcondut = "" THEN
    ASSIGN aux_nmcondut = aux_nmdircop.
  
  FIND FIRST crapcdp WHERE crapcdp.cdevento = aux_cdevento
                       AND crapcdp.cdcooper = aux_cdcooper
                       AND crapcdp.cdagenci = aux_cdagenci
                       AND crapcdp.dtanoage = aux_dtanoage NO-LOCK NO-ERROR NO-WAIT.
                       
  IF AVAILABLE crapcdp THEN
    DO:
      FOR EACH gnfacep WHERE gnfacep.cdcooper = 0  AND
                             gnfacep.nrpropos = crapcdp.nrpropos NO-LOCK:
              
        FOR EACH gnapfep WHERE gnapfep.cdcooper = 0  AND
                               gnapfep.nrcpfcgc = gnfacep.nrcpfcgc AND
                               gnapfep.cdfacili = gnfacep.cdfacili NO-LOCK :
            
          ASSIGN aux_nmcondut = gnapfep.nmfacili.
        END.
      END.
    END.
      
  montaCertificado().