<? 
/*!
 * FONTE        : busca_flghabiliar.php
 * CRIAÇÃO      : Anderson-Alan (Supero)
 * DATA CRIAÇÃO : 06/02/2019
 * OBJETIVO     : Rotina para buscar os parametros - PARECC
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

	$cdcooperativa = (isset($_POST["cdcooperativa"])) ? $_POST["cdcooperativa"] : ''; // Cooperativa selecionada
	$idfuncionalidade = isset($_POST["idfuncionalidade"]) ? $_POST["idfuncionalidade"] : ''; // Funcionalidade
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao,false)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','estadoInicial();',false);
	}
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= "    <cdcooperativa>".$cdcooperativa."</cdcooperativa>";
	$xml .= "    <idfuncionalidade>".$idfuncionalidade."</idfuncionalidade>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_PARECC", "BUSCA_FLGHABILITAR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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

	$flghabilitar = getByTagName($xmlObj->roottag->tags[0]->tags, 'flghabilitar');

	if ($flghabilitar == 0) {
		echo '$("#flghabilitar", "#frmCadsoa").attr("checked", false);';
	} else {
		echo '$("#flghabilitar", "#frmCadsoa").attr("checked", true);';
	}
?>