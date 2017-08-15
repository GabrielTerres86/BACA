<? 
/*!
 * FONTE        : carrega_integrante_grupo_economico.php
 * CRIAÇÃO      : Mauro (MOUTS)
 * DATA CRIAÇÃO : 13/07/2017
 * OBJETIVO     : Rotina para carregar os integrantes do grupo economico
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */
    session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();		

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'@')) <> ''){
		exibirErro('error',$msgError,'Alerta - Ayllos','',true);
	}
	
	// Verifica se o número da conta foi informado
	if (!isset($_POST["idgrupo"])){
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
	}
	
	$idgrupo     = $_POST["idgrupo"] == "" ? 0  : $_POST["idgrupo"];
	$listarTodos = (($_POST["listarTodos"] == "true") ? 1 : 0);
	$nrdconta    = $_POST["nrdconta"] == "" ? 0 : $_POST["nrdconta"];
	
	$xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <idgrupo>".$idgrupo."</idgrupo>";
	$xml .= "   <listar_todos>".$listarTodos."</listar_todos>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "TELA_GRUPO_ECONOMICO", "GRUPO_ECONOMICO_CONSULTAR_INTEGRANTES", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);
	
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		if ($msgErro == "") {
			$msgErro = $xmlObjeto->roottag->tags[0]->cdata;
		}
		exibirErro('error',htmlentities($msgErro),'Alerta - Ayllos','bloqueiaFundo(divRotina);',false);
	}
	
	$aRegistros = $xmlObjeto->roottag->tags;
	require_once("tab_integrantes_grupo_economico.php");
?>
<script>
formataTabIntegrantes();
</script>