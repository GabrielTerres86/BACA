/******************************** INCLUDE ZOOM *********************************
PROGRAMA.....:wszo00.i
AUTOR........:B&T/Solusoft 
DESCRIÇÃO....:Rotina de Zoom 

Alterações:   21/12/2015 - Alterado para não mostrar coluna "Tema" quando for 
                           Assembleia. Projeto 229 - Melhorias OQS (Lombardi)
*******************************************************************************/

IF REQUEST_METHOD = "POST" THEN DO:
  RUN MontaTela. 

  {&OUT} '<SCRIPT LANGUAGE="JAVASCRIPT">'.
  {&OUT} "bName = navigator.appName;". 
  {&OUT} "bVer  = parseInt(navigator.appVersion);".
  {&OUT} '</SCRIPT>' SKIP.
  {&OUT} ' </body> </form> '.          
  
  run FindFirst.
  
  IF AVAILABLE {&TabelaPadrao} THEN DO:
    ASSIGN conta = 0.     
    /*{&out} '<PRE>' SKIP. 
    {&out} ' {&LinhaDeCabecalho1}' SKIP
           ' {&LinhaDeCabecalho2}' SKIP.    
    {&out} '</PRE>' SKIP. */

    IF OpcaoNavegacao = "Procurar" or 
       OpcaoNavegacao = "0" THEN DO:                          
      RUN OpenQuery.                  
      run MostraDados.
    END.   

    REPEAT:
      IF OpcaoNavegacao = "" THEN
        CLOSE QUERY QueryPadrao.
      RUN OpenQuery.                  

      IF OpcaoNavegacao = "Anterior" THEN DO:
        IF PonteiroDeInicio <> ? THEN DO:
          REPOSITION QueryPadrao TO ROWID PonteiroDeInicio NO-ERROR.
          IF ERROR-STATUS:ERROR THEN
            GET FIRST QueryPadrao NO-LOCK NO-WAIT. 
          ELSE DO:
            REPOSITION QueryPadrao BACKWARDS 10.
            GET NEXT QueryPadrao NO-LOCK NO-WAIT.
          END.
          IF not AVAILABLE {&TabelaPadrao} then do.
            REPOSITION QueryPadrao TO ROWID PonteiroDeInicio.
            REPOSITION QueryPadrao FORWARDS 10.
          end.
          else 
            GET PREV QueryPadrao NO-LOCK NO-WAIT.                                               
          run MostraDados.                                               
        END.   
      END. /* anterior */
      ELSE
      IF OpcaoNavegacao = "Proximo" THEN DO:
        IF PonteiroDeFim <> ? THEN DO:
          REPOSITION QueryPadrao TO ROWID PonteiroDeFim NO-ERROR.
          IF ERROR-STATUS:ERROR THEN
            GET FIRST QueryPadrao NO-LOCK NO-WAIT. 
          ELSE DO:
            REPOSITION QueryPadrao FORWARDS 10.     
            GET NEXT QueryPadrao NO-LOCK NO-WAIT. 
          END.
          IF not AVAILABLE {&TabelaPadrao} then do.
            REPOSITION QueryPadrao TO ROWID PonteiroDeFim.
            REPOSITION QueryPadrao BACKWARDS 10.
          end.
          else 
            GET PREV QueryPadrao NO-LOCK NO-WAIT.
          run MostraDados.
        END.
      END. /* proximo */
      ELSE
      IF OpcaoNavegacao = "Primeiro" THEN DO:
        run MostraDados.
      END. /* primeiro */
      ELSE
      IF OpcaoNavegacao = "Ultimo" THEN DO:
        IF PonteiroDeInicio <> ? THEN DO:
          GET LAST QueryPadrao NO-LOCK NO-WAIT.
          REPOSITION QueryPadrao BACKWARDS 10.
          run MostraDados.
        END.   
      END. /* ultimo */

      {&out} '<form method="POST" name="formaux">' SKIP
             '   <input type="hidden" name="PonteiroDeInicioAuxiliar" value="' STRING(PonteiroDeInicio) '">' SKIP
             '   <input type="hidden" name="PonteiroDeInicioAuxiliarFim" value="' STRING(PonteiroDeFim) '">' SKIP
             '</form>' SKIP.                           
      LEAVE.     
    END. /* repeat */                                        
  END. /* available TabelaPadrao */
  ELSE
    {&out} '(2) Não existem registros para o padrão de pesquisa fornecido.' SKIP
           '<form method="POST" name="formaux">' SKIP
           '   <input type="hidden" name="PonteiroDeInicioAuxiliar" value="0">' SKIP
           '   <input type="hidden" name="PonteiroDeInicioAuxiliarFim" value="0">' SKIP
           '</form>' SKIP.                                                     
END.
ELSE DO:   /* GET */
  if vtippesquisa = "" then 
    vtippesquisa = "{&NomeCampoDePesquisa}".
  if vcriterio = "" then 
    vcriterio = "{&NomeCriterio}".

  RUN MontaTela.

  {&OUT} '<SCRIPT LANGUAGE="JAVASCRIPT">'.
  {&OUT} "bName = navigator.appName;". 
  {&OUT} "bVer  = parseInt(navigator.appVersion);".
  {&OUT} '</SCRIPT>' SKIP.
  {&OUT} ' </body> </form> '.          

  run FindFirst.

  IF AVAILABLE {&TabelaPadrao} THEN DO:                
    ASSIGN conta = 0.     
    /*{&out} '<PRE>' SKIP. 
    {&out} '<table border="1" valign="top" cellpadding="0" cellspacing="0" width="100%">' SKIP
           '  <tr>' SKIP
           '    <td height="27" align="left"  background="/cecred/images/menu/fnd_title.jpg">' SKIP
           '      <table  border="0" cellpadding="0" cellspacing="0">' SKIP
           '        <tr>' SKIP
           '          <td width="15" class="txtMenuTitulos">&nbsp;</td>' SKIP
           '          <td width="30" class="txtMenuTitulos">&nbsp;</td>' SKIP
           '          <td width="100" class="txtMenuTitulos">{&LinhaDeCabecalho1}</td>' SKIP
           '        <tr>' SKIP
           '      </table>' SKIP
           '    </td>' SKIP 
           '  </tr>' SKIP 
           '</table>' SKIP.
    */
    run OpenQuery.
    run MostraDados.      

    {&out} '<form method="POST" name="formaux">' SKIP
           '   <input type="hidden" name="PonteiroDeInicioAuxiliar" value="' STRING(PonteiroDeInicio) '">' SKIP
           '   <input type="hidden" name="PonteiroDeInicioAuxiliarFim" value="' STRING(PonteiroDeFim) '">' SKIP
           '</form>' SKIP.                           
  END. /* available TabelaPadrao */
  ELSE
    {&out} '(1) Não existem registros para o padrão de pesquisa fornecido.' SKIP
           '<form method="POST" name="formaux">' SKIP
           '   <input type="hidden" name="PonteiroDeInicioAuxiliar" value="0">' SKIP
           '   <input type="hidden" name="PonteiroDeInicioAuxiliarFim" value="0">' SKIP
           '</form>' SKIP.                                                     
END. 


procedure MontaTela:

  DEFINE VAR aux_lincab AS CHAR NO-UNDO.
  
  {&out} '<link href="/cecred/estilos/progrid.css" rel="stylesheet" type="text/css">' SKIP
         '<table border="0" align="center" cellpadding="0" cellspacing="0" width="85%">' SKIP
         
         '<tr>' SKIP
         
         '<td width="11" align="left"><img src="/cecred/images/geral/guia_esquerda.gif" width="11" height="21"></td>' SKIP
         '</td>' SKIP
         
         '<td align="center" width="500" class="linkGuia" background="/cecred/images/geral/guia_fundo.gif">{&TitulodoPrograma}' SKIP 
         '</td>' SKIP
         
         '<td width="11" align="left"><img src="/cecred/images/geral/guia_direita.gif" width="11" height="21"></td>' SKIP
         '</td>' SKIP
         
         '<td width="60%">&nbsp;' SKIP
         '</td>' SKIP
         '</tr>' SKIP
         
		 '<tr>' SKIP
		 '<td colspan="4" height="2" bgcolor="#999999">' SKIP
		 '</td>' SKIP
		 '</tr>' SKIP
		 
         '<tr>' SKIP
         '<td colspan="4" bgColor="#FFFFFF">' SKIP.

         
  {&out} '<form method="POST" action="{&NomeDoProgramaDeZoom}" name="form" onsubmit="return SetaFlag()">' SKIP
         '   <input type="hidden" name="PonteiroDeInicio" value="">' SKIP
         '   <input type="hidden" name="PonteiroDeFim" value="">' SKIP
         '   <input type="hidden" name="LinkRowid" value="">' SKIP
         '   <input type="hidden" name="chave" value="">' SKIP
         '   <input type="hidden" name="aux_cdcopope" value="' ValorCampo2 '">' SKIP
         '   <input type="hidden" name="btnopcao" value="0">' SKIP
         '   <input type="hidden" name="NomeDoCampo" value="' NomeDoCampo '">' SKIP
         '   <input type="hidden" name="ValorCampo"  value="' ValorCampo  '">' SKIP
         '   <input type="hidden" name="ValorCampo2" value="' ValorCampo2 '">' SKIP
         '   <input type="hidden" name="ValorCampo3" value="' ValorCampo3 '">' SKIP
         '   <input type="hidden" name="ValorCampo4" value="' ValorCampo4 '">' SKIP
         '   <input type="hidden" name="ValorCampo5" value="' ValorCampo5 '">' SKIP
         '   <input type="hidden" name="ValorCampo6" value="' ValorCampo6 '">' SKIP
         '   <table border="0" cellspacing="0" height="50" >' SKIP
         '     <tr> <td width="12" class="linkMenuAdmin">&nbsp;</td>' SKIP
         '          <td class="linkMenuAdmin" align="right">Busca:</td>   ' skip
         '          <td><select class="Campo" name="vtippesquisa">'.


  /* teste de 1o campo */       
  if vtippesquisa = "{&NomeCampoDePesquisa}" then 
    {&out}    '     <option selected>{&NomeCampoDePesquisa}</option>  '.
  else
  if "{&NomeCampoDePesquisa}" <> "" then   
    {&out} '   <option>{&NomeCampoDePesquisa}</option>  '.

  /* teste de 2o campo */       
  if vtippesquisa = "{&NomeCampoDePesquisa1}" then 
    {&out}    '     <option selected>{&NomeCampoDePesquisa1}</option>  '.
  else
  if "{&NomeCampoDePesquisa1}" <> "" then   
    {&out} '   <option>{&NomeCampoDePesquisa1}</option>  '.

  /* teste de 3o campo */       
  if vtippesquisa = "{&NomeCampoDePesquisa2}" then 
    {&out}    '     <option selected>{&NomeCampoDePesquisa2}</option>  '.
  else
  if "{&NomeCampoDePesquisa2}" <> "" then   
    {&out} '   <option>{&NomeCampoDePesquisa2}</option>  '.

  /* teste de 4o campo */       
  if vtippesquisa = "{&NomeCampoDePesquisa3}" then 
    {&out}    '     <option selected>{&NomeCampoDePesquisa3}</option>  '.
  else
  if "{&NomeCampoDePesquisa3}" <> "" then   
    {&out} '   <option>{&NomeCampoDePesquisa3}</option>  '.

  /* teste de 5o campo */       
  if vtippesquisa = "{&NomeCampoDePesquisa4}" then 
    {&out}    '     <option selected>{&NomeCampoDePesquisa4}</option>  '.
  else
  if "{&NomeCampoDePesquisa4}" <> "" then   
    {&out} '   <option>{&NomeCampoDePesquisa4}</option>  '.

  {&out} '</td><td class="linkMenuAdmin" align="right">Critério:</td>'
         '<td><select class="Campo" name="vcriterio" >'.

  /* teste de 1o campo */       
  if vcriterio = "{&NomeCriterio}" then 
    {&out}    '     <option selected>{&NomeCriterio}</option>  '.
  else
  if "{&NomeCriterio}" <> "" then   
    {&out} '   <option>{&NomeCriterio}</option>  '.

  /* teste de 2o campo */       
  if vcriterio = "{&NomeCriterio1}" then 
    {&out}    '     <option selected>{&NomeCriterio1}</option>  '.
  else
  if "{&NomeCriterio1}" <> "" then   
    {&out} '   <option>{&NomeCriterio1}</option>  '.

  /* teste de 3o campo */       
  if vcriterio = "{&NomeCriterio2}" then 
    {&out}    '     <option selected>{&NomeCriterio2}</option>  '.
  else
   if "{&NomeCriterio2}" <> "" then   
    {&out} '   <option>{&NomeCriterio2}</option>  '.

  IF ValorCampo = "2" AND valorcampo3 = "CEventos" THEN
    aux_lincab = '{&LinhaDeCabecalho3}'.
  ELSE
    aux_lincab = '{&LinhaDeCabecalho1}'.


  {&out} '</td><td class="linkMenuAdmin" align="right">Pesquisa:</td>' 
         '<td><input type="text" class="Campo" size="20" name="pesquisa" value="' pesquisa '"></td>'
         '<td><a href="#."'
         "onclick="
         '"Fbtnprocurar('
         "'" opcao-pesquisa "','{&NomeDoProgramaDeZoom}','Procurar')"
         '"'              
         "'>"     
         '<INPUT TYPE="image" src="/cecred/images/botoes/btn_ok.gif" alt="Procurar" border="0">'
         "</a></td>" skip.
  {&out} "<td>"
         /* SUBSTITUICAO DO BOTAO"*/
         '<img src="/cecred/images/botoes/btn_navegacao.gif" alt="Procurar" border="0" usemap="#Map">'
         "</a></td></table>" SKIP.      
  /*{&out} "teste".*/
  /*monta linha de descrição*/
  {&out} '<table border="0" valign="top" cellpadding="0" cellspacing="0" width="100%">' SKIP
           '  <tr>' SKIP
           '    <td height="27" align="left">' SKIP
           '      <table  border="1" cellpadding="0" cellspacing="0" width="100%" heigth="100%">' SKIP
           '        <tr>' SKIP
           '          <td width="15"  background="/cecred/images/menu/fnd_title.jpg">&nbsp;</td>' SKIP
           /*'          <td width="30" class="txtMenuTitulos">&nbsp;</td>' SKIP*/
           /* '          {&LinhaDeCabecalho1}       ' */
           aux_lincab
           '        </tr>' SKIP.
  
  /* INCLUSAO DO NOVO PROCEDIMENTO*/
  {&out} '<map name="Map">'
  '<area shape="rect" coords="4,1,24,16"  href=# onclick="Fbtnprocurar(''' opcao-pesquisa ''',''{&NomeDoProgramaDeZoom}'',''Primeiro'')">'
  '<area shape="rect" coords="29,3,42,16" href=# onClick="Fbtnprocurar(''' opcao-pesquisa ''',''{&NomeDoProgramaDeZoom}'',''Anterior'')">'
  '<area shape="rect" coords="45,3,58,16" href=# onClick="Fbtnprocurar(''' opcao-pesquisa ''',''{&NomeDoProgramaDeZoom}'',''Proximo'')">'
  '<area shape="rect" coords="62,3,82,18" href=# onClick="Fbtnprocurar(''' opcao-pesquisa ''',''{&NomeDoProgramaDeZoom}'',''Ultimo'')">'
  '</map>'.  
end procedure.

/*=======================================*/
procedure MostraDados:
/*MESSAGE "aux_cdcopope1: " + aux_cdcopope.*/
  DEF VAR vprograma AS CHAR NO-UNDO.  
  DEF VAR i AS INT NO-UNDO.
  
  IF '{&NomeDoProgramaPrincipal}' <> '/wpgd0012.w' THEN
    DEF VAR aux_cdcopope AS CHAR NO-UNDO.  
  
  vprograma = AppURL + '{&NomeDoProgramaPrincipal}'.
  {&out} '<PRE>'.

  DO ContadorDeRegistros = 1 TO 10:
    GET NEXT QueryPadrao NO-LOCK NO-WAIT.
    IF AVAILABLE {&TabelaPadrao} THEN DO:
      run TrocaCaracter.
      
      IF contadorderegistros = 1 THEN
        ASSIGN PonteiroDeInicio = ROWID({&TabelaPadrao}).
      ASSIGN PonteiroDeFim = ROWID({&TabelaPadrao}).
      
      {&out}
          '<tr>'
          '<td>'.

/*      RUN PosicionaPonteiro.*/
      {&out} '<a href="#."' skip.
      {&out} "onclick=".
      {&out} '"SelecaoZoom'.
      
      IF opcao-pesquisa = "P" THEN
      DO:
        IF '{&NomeDoProgramaPrincipal}' = '/wpgd0012.w' THEN
           {&out} "('" vprograma "','" STRING(ROWID({&TabelaPadrao})) "','" {&CampoChaveParaRetorno} "','" aux_cdcopope "')".
        ELSE  
           {&out} "('" vprograma "','" STRING(ROWID({&TabelaPadrao})) "','" {&CampoChaveParaRetorno} "')".
      END.
      ELSE
          {&out} "('','','" {&CampoChaveParaRetorno} "','" {&CampoCompltoParaRetorno} "','" {&CampoCompl2toParaRetorno} "','" {&CampoCompl3toParaRetorno} "','" {&CampoCompl4toParaRetorno} "','" {&CampoCompl5toParaRetorno} "','" {&CampoCompl6toParaRetorno} "','" {&CampoCompl7toParaRetorno} "','" {&CampoCompl8toParaRetorno} "','" {&CampoCompl9toParaRetorno} "')".
      {&out} '"'. 
      {&out} "'>".
      {&out} '<img src="/cecred/images/icones/ico_seleciona.gif" alt="Selecionar" border="0" heigth="15" width="15">'.
      {&out} "</a></td>".
      IF ValorCampo = "2" AND valorcampo3 = "CEventos" THEN
        {&out}  {&CamposDisplay2}.
      ELSE 
        {&out}  {&CamposDisplay}.

      {&out}
          '</tr>'.
       

    END.          

  END. /* do ContadorDeRegistros */   

  {&out} '</PRE>'.

  {&out}
      '</table>'  SKIP
      '    </td>' SKIP 
      '  </tr>'   SKIP 
      '</table>'  SKIP.

  {&out} '</td>' SKIP
         '</tr>' SKIP
         '</table>' SKIP.

  end procedure.
  
    

{includes/subs.i}

 
