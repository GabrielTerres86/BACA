<?php
/*!
 * FONTE        : valida_cnpjempresa.php
 * CRIAÇÃO      : CIS Corporate
 * DATA CRIAÇÃO : 12/10/2018 
 *
 */
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();	
    
    $nrdocnpj = $_POST['nrdocnpj'];
    
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	$xml .= '       <nmextemp></nmextemp>';
	$xml .= '       <nmresemp></nmresemp>';
	$xml .= '       <nrdocnpj>'.$nrdocnpj.'</nrdocnpj>';
	$xml .= '       <cdempres>-1</cdempres>';
	$xml .= '       <cddopcao></cddopcao>';
	$xml .= '       <nriniseq>1</nriniseq>';
	$xml .= '       <nrregist>1</nrregist>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';


	$xmlResult = mensageria(
		$xml,
		"TELA_CADEMP",
		"OBTEM_DADOS_EMPRESA",
		$glbvars["cdcooper"],
		$glbvars["cdagenci"],
		$glbvars["nrdcaixa"],
		$glbvars["idorigem"],
		$glbvars["cdoperad"],
		"</Root>");

	$xmlObj = getObjectXML($xmlResult);

	if ( strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO" ) {
		echo 'showError("error","'.$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata.'","Alerta - Ayllos","");';
		return;
	} //erro
	
	$inf = $xmlObj->roottag->tags[0]->tags[0]->tags;

	$cdemprescnpj = (getByTagName($inf,'cdempres'));
	$js .= 'cdemprescnpj = "'.$cdemprescnpj.'";';
	echo $js;
	return;				
?>