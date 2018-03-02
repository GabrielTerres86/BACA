<? 
/*!
 * FONTE        : busca_historico.php
 * CRIAÇÃO      : Jéssica (DB1)
 * DATA CRIAÇÃO : 30/09/2013
 * OBJETIVO     : Rotina para buscar históricos do sistema - HISTOR
 * --------------
 * ALTERAÇÕES   : 10/03/2016 - Homologacao e Ajustes da conversao da tela HISTOR (Douglas - Chamado 412552)
 *
 *                05/12/2016 - P341-Automatização BACENJUD - Alterar a passagem da descrição do 
 *                             departamento como parametros e passar o o código (Renato Darosci)
 * -------------- 
 *
 * -------------- 
 */
?>
 
<?
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		

	// Recebe a operação que está sendo realizada
	$cddopcao	= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
	$cdhistor	= (isset($_POST['cdhistor'])) ? $_POST['cdhistor'] : '';
	$cdhinovo	= (isset($_POST['cdhinovo'])) ? $_POST['cdhinovo'] : '';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao,false)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','estadoInicial();',false);
	}
			
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0179.p</Bo>';
	$xml .= '		<Proc>Busca_Dados</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '       <cddepart>'.$glbvars['cddepart'].'</cddepart>';	
	$xml .= '       <dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';	
	$xml .= '       <cddopcao>'.$cddopcao.'</cddopcao>';
	$xml .= '       <cdhistor>'.$cdhistor.'</cdhistor>';
	$xml .= '       <cdhinovo>'.$cdhinovo.'</cdhinovo>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
			
	$xmlResult = getDataXML($xml);
	
	$xmlObjeto = getObjectXML($xmlResult);
		
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
		$msgErro = $xmlObjeto->roottag->tags[0]->cdata;
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}

		$nmdcampo	= $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];	
		if (!empty($nmdcampo)) { $mtdErro = "focaCampoErro('" . $nmdcampo . "','frmHistorico');"; }
		if (empty($mtdErro)) { $mtdErro = "liberaFormulario();"; }
		
		exibirErro('error',$msgErro,'Alerta - Ayllos',$mtdErro,false);
	} 

	$historico = $xmlObjeto->roottag->tags[0]->tags[0]->tags;
	
	// Dados Gerais
	echo "$('#dshistor','#frmHistorico').val('" . getByTagName($historico,'dshistor') . "');";
	echo "$('#indebcre','#frmHistorico').val('" . getByTagName($historico,'indebcre') . "');";
	echo "$('#tplotmov','#frmHistorico').val('" . getByTagName($historico,'tplotmov') . "');";
	echo "$('#inhistor','#frmHistorico').val('" . getByTagName($historico,'inhistor') . "');";
	echo "$('#dsexthst','#frmHistorico').val('" . getByTagName($historico,'dsexthst') . "');";
	echo "$('#dsextrat','#frmHistorico').val('" . getByTagName($historico,'dsextrat') . "');";
	echo "$('#nmestrut','#frmHistorico').val('" . getByTagName($historico,'nmestrut') . "');";
	
	// Indicadores
	echo "$('#indoipmf','#frmHistorico').val('" . getByTagName($historico,'indoipmf') . "');";
	echo "$('#inclasse','#frmHistorico').val('" . getByTagName($historico,'inclasse') . "');";
	echo "$('#inautori','#frmHistorico').val('" . getByTagName($historico,'inautori') . "');";
	echo "$('#inavisar','#frmHistorico').val('" . getByTagName($historico,'inavisar') . "');";
	echo "$('#indcompl','#frmHistorico').val('" . getByTagName($historico,'indcompl') . "');";
	echo "$('#indebcta','#frmHistorico').val('" . getByTagName($historico,'indebcta') . "');";
	echo "$('#incremes','#frmHistorico').val('" . getByTagName($historico,'incremes') . "');";
	
	// Dados Contabeis
	echo "$('#cdhstctb','#frmHistorico').val('" . getByTagName($historico,'cdhstctb') . "');";
	echo "$('#tpctbccu','#frmHistorico').val('" . getByTagName($historico,'tpctbccu') . "');";
	echo "$('#tpctbcxa','#frmHistorico').val('" . getByTagName($historico,'tpctbcxa') . "');";
	echo "$('#nrctacrd','#frmHistorico').val('" . getByTagName($historico,'nrctacrd') . "');";
	echo "$('#nrctadeb','#frmHistorico').val('" . getByTagName($historico,'nrctadeb') . "');";
	echo "$('#ingercre','#frmHistorico').val('" . getByTagName($historico,'ingercre') . "');";
	echo "$('#ingerdeb','#frmHistorico').val('" . getByTagName($historico,'ingerdeb') . "');";
	echo "$('#nrctatrc','#frmHistorico').val('" . getByTagName($historico,'nrctatrc') . "');";
	echo "$('#nrctatrd','#frmHistorico').val('" . getByTagName($historico,'nrctatrd') . "');";
	
	// LABEL - Tarifas
	$vltarayl = number_format(str_replace(',','.',getByTagName($historico,'vltarayl')),2,',','.');
	$vltarcxo = number_format(str_replace(',','.',getByTagName($historico,'vltarcxo')),2,',','.');
	$vltarint = number_format(str_replace(',','.',getByTagName($historico,'vltarint')),2,',','.');
	$vltarcsh = number_format(str_replace(',','.',getByTagName($historico,'vltarcsh')),2,',','.');
	
	echo "$('#vltarayl','#frmHistorico').val('" . $vltarayl . "');";
	echo "$('#vltarcxo','#frmHistorico').val('" . $vltarcxo . "');";
	echo "$('#vltarint','#frmHistorico').val('" . $vltarint . "');";
	echo "$('#vltarcsh','#frmHistorico').val('" . $vltarcsh . "');";
	
	// LABEL - Situacoes de Contas
	$cdgrphis = (getByTagName($historico,'cdgrphis') == "0") ? "" : getByTagName($historico,'cdgrphis');
	echo "$('#cdgrupo_historico','#frmHistorico').val('" . $cdgrphis . "');";
	echo "$('#dsgrupo_historico','#frmHistorico').val('" . getByTagName($historico,'dsgrphis') . "');";
	
	// LABEL - Outros
	$cdprodut = (getByTagName($historico,'cdprodut') == "0") ? "" : getByTagName($historico,'cdprodut');
	$cdagrupa = (getByTagName($historico,'cdagrupa') == "0") ? "" : getByTagName($historico,'cdagrupa');
	echo "$('#flgsenha','#frmHistorico').val('" . getByTagName($historico,'flgsenha') . "');";
	echo "$('#cdprodut','#frmHistorico').val('" . $cdprodut . "');";
	echo "$('#dsprodut','#frmHistorico').val('" . getByTagName($historico,'dsprodut') . "');";
	echo "$('#cdagrupa','#frmHistorico').val('" . $cdagrupa . "');";
	echo "$('#dsagrupa','#frmHistorico').val('" . getByTagName($historico,'dsagrupa') . "');";
	
	

	if( $cddopcao == "X" ){
		echo "$('input[type=\"text\"],select','#frmHistorico').desabilitaCampo().removeClass('campoErro');";
		echo "$('#btSalvar').focus();";
	} else {
		echo "$('input[type=\"text\"],select','#frmHistorico').habilitaCampo().removeClass('campoErro');";
		echo "$(\"#cdhistor\",\"#frmHistorico\").desabilitaCampo();";
		echo "$(\"#cdhinovo\",\"#frmHistorico\").desabilitaCampo();";
		echo "$(\"#dshistor\",\"#frmHistorico\").focus();";
	}
?>