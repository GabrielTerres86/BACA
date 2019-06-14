<?
/*!
 * FONTE        : grava_dados.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : Maio/2015
 * OBJETIVO     : Rotina para gravar dados
 * --------------
 * ALTERAÇÕES   : 21/10/2015 - Envio da cddopcao conforme a situação (Inserção ou Atualização) (Marcos-Supero)
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

	// Recebe o POST
	$rowid       = (isset($_POST['rowid'])) ? $_POST['rowid'] : ''  ;
	$cdoriflh    = (isset($_POST['cdoriflh'])) ? $_POST['cdoriflh'] : '' ;
	$dsoriflh    = (isset($_POST['dsoriflh'])) ? $_POST['dsoriflh'] : '' ;
	$idvarmes    = (isset($_POST['idvarmes'])) ? $_POST['idvarmes'] : '' ;
	$cdhisdeb    = (isset($_POST['cdhisdeb'])) ? $_POST['cdhisdeb'] : 0  ;
	$cdhsdbcp    = (isset($_POST['cdhsdbcp'])) ? $_POST['cdhsdbcp'] : 0  ;
	$cdhiscre    = (isset($_POST['cdhiscre'])) ? $_POST['cdhiscre'] : 0  ;
	$cdhscrcp    = (isset($_POST['cdhscrcp'])) ? $_POST['cdhscrcp'] : 0  ;
	$fldebfol    = (isset($_POST['fldebfol'])) ? $_POST['fldebfol'] : '' ;
    
	if ($rowid != ""){
		$cddopcao = "A";
	}else{
		$cddopcao = "I";
	}
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<cdoriflh>'.$cdoriflh.'</cdoriflh>';
	$xml .= '		<dsoriflh>'.$dsoriflh.'</dsoriflh>';
	$xml .= '		<idvarmes>'.$idvarmes.'</idvarmes>';
	$xml .= '		<cdhisdeb>'.$cdhisdeb.'</cdhisdeb>';
	$xml .= '		<cdhsdbcp>'.$cdhsdbcp.'</cdhsdbcp>';
	$xml .= '		<cdhiscre>'.$cdhiscre.'</cdhiscre>';
	$xml .= '		<cdhscrcp>'.$cdhscrcp.'</cdhscrcp>';
	$xml .= '		<fldebfol>'.$fldebfol.'</fldebfol>';
	$xml .= '		<rowid>'.$rowid.'</rowid>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "ORIFOL", "GRAVOFP", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
		$campo    = ucfirst($xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO']);
		$retornoAposErro = 'c'.$campo.'.focus();'.'c'.$campo.'.addClass(\'campoErro\');'."blockBackground(parseInt($('#divRotina').css('z-index')));";
		$codErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[3]->cdata;
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		
		switch ($codErro) {
			case 0:
				$msgErro = "J&aacute; existe origem com este c&oacute;digo, favor ajustar!";
				break;
			case 1:
				$msgErro = "J&aacute; existe par&acirc;metriza&ccedil;&atilde;o para a mesma combina&ccedil;&atilde;o, favor alterar o cadastro!";
				break;
			case 2:
				$msgErro = "O c&oacute;digo para Origem &eacute; obrigat&oacute;ria!";
				break;
			case 3:
				$msgErro = "A descri&ccedil;&atilde;o para Origem &eacute; obrigat&oacute;ria!";
				break;
			case 4:
				$msgErro = "Hist&oacute;rico de d&eacute;bito p/Empresa deve ser informado!";
				break;
			case 5:
				$msgErro = "Hist&oacute;rico de cr&eacute;dito p/Empresa deve ser informado!";
				break;
			case 6:
				$msgErro = "Hist&oacute;rico de d&eacute;bito p/Cooperativa deve ser informado!";
				break;
			case 7:
				$msgErro = "Hist&oacute;rico de cr&eacute;dito p/Cooperativa deve ser informado!";
				break;
			case 8:
				$msgErro = "Hist&oacute;rico Inexistente!";
				break;
			case 9:
				$msgErro = "Favor informar um Hist&oacute;rico do tipo D&eacute;bito p/Empresa!";
				break;
			case 10:
				$msgErro = "Favor informar um Hist&oacute;rico do tipo Cr&eacute;dito p/Empresa!";
				break;
			case 11:
				$msgErro = "Favor informar um Hist&oacute;rico do tipo D&eacute;bito p/Cooperativa!";
				break;
			case 12:
				$msgErro = "Favor informar um Hist&oacute;rico do tipo Cr&eacute;dito p/Cooperativa!";
				break;
			case 13:
			    $retornoAposErro = "blockBackground(parseInt($('#divRotina').css('z-index')));";
				$msgErro = "Hist&oacute;ricos p/ Empresa e/ou p/ Cooperativa devem ser informados!";
				break;
			case 9999:
			    $retornoAposErro = "blockBackground(parseInt($('#divRotina').css('z-index')));";
				break;
		}
		
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}

?>