<? 
/*!
 * FONTE        : busca_associado.php
 * CRIAÇÃO      : Mauro (MOUTS)
 * DATA CRIAÇÃO : Agosto/2017
 * OBJETIVO     : Buscar os dados do associado
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */	
	session_start();
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");
	isPostMethod();		
	
	// Verifica permissões de acessa a tela
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],'@')) <> ""){
		exibirErro('error',$msgError,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	}
	
	$nrdconta = $_POST["nrdconta"] == "" ? 0 : $_POST["nrdconta"];
	$nrcpfcgc = $_POST["nrcpfcgc"] == "" ? 0 : $_POST["nrcpfcgc"];	
	
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Dados>";
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<nrcpfcgc>'.$nrcpfcgc.'</nrcpfcgc>';
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "TELA_GRUPO_ECONOMICO", "GRUPO_ECONOMICO_BUSCA_ASSOCIADO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);
	
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		if ($msgErro == "") {
			$msgErro = $xmlObjeto->roottag->tags[0]->cdata;
		}
		exibirErro('error',htmlentities($msgErro),'Alerta - Aimaro',"bloqueiaFundo($('#divUsoGenerico'));",false);
	}
	
	if (getByTagName($xmlObjeto->roottag->tags[0]->tags,'total') > 1){
		echo "$('#lupa_nrdconta', '#frmGrupoEconomicoIntegrantes').trigger('click');";
	}else if (getByTagName($xmlObjeto->roottag->tags[0]->tags,'total') == 1){
		echo "$('#nmprimtl', '#frmGrupoEconomicoIntegrantes').val('".getByTagName($xmlObjeto->roottag->tags[0]->tags,'nmprimtl')."');";
		echo "$('#nrdconta', '#frmGrupoEconomicoIntegrantes').val('".getByTagName($xmlObjeto->roottag->tags[0]->tags,'nrdconta')."');";
		echo "$('#nrcpfcgc', '#frmGrupoEconomicoIntegrantes').val('".getByTagName($xmlObjeto->roottag->tags[0]->tags,'nrcpfcgc')."');";
	}
	echo "hideMsgAguardo();bloqueiaFundo($('#divUsoGenerico'));";
?>