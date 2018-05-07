<? 
	/*!
	 * FONTE        : manter_parametros.php
	 * CRIAÇÃO      : Jean Michel
	 * DATA CRIAÇÃO : 07/12/2017
	 * OBJETIVO     : Rotina geral de Parametros CDC
	 * --------------
	 * ALTERAÇÕES   :
	 * -------------- 
	 */
  
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	$cdcooper         = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : '';
	$inintegra_cont   = (isset($_POST['inintegra_cont'])) ? $_POST['inintegra_cont'] : '';
	$nrprop_env       = (isset($_POST['nrprop_env'])) ? $_POST['nrprop_env'] : '';
	$intempo_prop_env = (isset($_POST['intempo_prop_env'])) ? $_POST['intempo_prop_env'] : '';

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml de requisicao
	$xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= "  <cddopcao>I</cddopcao>";
	$xml .= "  <cdcooper_param>".$cdcooper."</cdcooper_param>";
	$xml .= "  <inintegra_cont>".$inintegra_cont."</inintegra_cont>";
	$xml .= "  <nrprop_env>".$nrprop_env."</nrprop_env>";
	$xml .= "  <intempo_prop_env>".$intempo_prop_env."</intempo_prop_env>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "TELA_PARCDC", "MANTER_PARAMETROS_CDC", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		if ($msgErro == "") {
			$msgErro = $xmlObjeto->roottag->tags[0]->cdata;
		}
		exibirErro('error',$msgErro,'Alerta - Ayllos',"bloqueiaFundo($('#divRotina'));",false);
	}
	
?>