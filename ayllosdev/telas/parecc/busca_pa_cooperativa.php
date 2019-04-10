<? 
/*!
 * FONTE        : busca_pa_cooperativa.php
 * CRIAÇÃO      : Luis Fernando (Supero)
 * DATA CRIAÇÃO : 28/01/2019
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
	$idfuncionalidade = isset($_POST["idfuncionalidade"]) ? $_POST["idfuncionalidade"] : ""; // Funcionalidade
	$idtipoenvio = isset($_POST["idtipoenvio"]) ? $_POST["idtipoenvio"] : ""; // Tipo de envio
	
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao,false)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','estadoInicial();',false);
	}
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= "    <cdcooperativa>".$cdcooperativa."</cdcooperativa>";
	$xml .= "    <idfuncionalidade>".$idfuncionalidade."</idfuncionalidade>";
	$xml .= "    <idtipoenvio>".$idtipoenvio."</idtipoenvio>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_PARECC", "BUSCA_PA_PARECC", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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

	$listaPa = $xmlObj->roottag->tags[0]->tags;

	foreach ($listaPa as $pa) {
		echo 'populaCampos("dsservico", "'.getByTagName($pa->tags,'cdagenci').'","'.getByTagName($pa->tags,'nmresage').'");';
	}
	
	$listaPa = $xmlObj->roottag->tags[1]->tags;

	foreach ($listaPa as $pa) {
		echo 'populaCampos("dsaderido", "'.getByTagName($pa->tags,'cdagenci').'","'.getByTagName($pa->tags,'nmresage').'");';
	}
?>