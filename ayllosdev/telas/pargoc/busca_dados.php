<? 
/*!
 * FONTE        : busca_dados.php
 * CRIAÇÃO      : Lucas Afonso
 * DATA CRIAÇÃO : 05/10/2017
 * OBJETIVO     : Rotina para buscar os parametros - PARGOC
 * --------------
 * ALTERAÇÕES   : 
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

	$cdcooper = (isset($_POST["cdcooper"])) ? $_POST["cdcooper"] : '';
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao,false)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= "    <cdcooper>".$cdcooper."</cdcooper>";
	$xml .= "    <cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_PARGOC", "BUSCA_PARAMS_PARGOC", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);		
		
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
	}

	$parametros = $xmlObj->roottag->tags[0]->tags;
	
	echo 'populaCampos('.getByTagName($parametros,'inresgate_automatico').','.getByTagName($parametros,'qtdias_atraso_permitido').',"'.getByTagName($parametros,'peminimo_cobertura').'");';
?>