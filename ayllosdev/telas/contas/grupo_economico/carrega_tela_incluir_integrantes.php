<? 
/*!
 * FONTE        : carrega_tela_incluir_integrantes.php
 * CRIAÇÃO      : Mauro (MOUTS)
 * DATA CRIAÇÃO : 13/07/2017
 * OBJETIVO     : Rotina para carregar a tela de inclusao de integrantes
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

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'I')) <> ''){
		exibirErro('error',$msgError,'Alerta - Ayllos','',true);
	}
	
	if (!isset($_POST["idgrupo"])){
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
	}

	$idgrupo = $_POST["idgrupo"] == "" ? 0  : $_POST["idgrupo"];
		
	$xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <idgrupo>".$idgrupo."</idgrupo>";
	$xml .= " </Dados>";
	$xml .= "</Root>";	
	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "TELA_GRUPO_ECONOMICO", "GRUPO_ECONOMICO_VERIFICA_INTEGRANTES", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);
	
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		if ($msgErro == "") {
			$msgErro = $xmlObjeto->roottag->tags[0]->cdata;
		}
		exibirErro('error',htmlentities($msgErro),'Alerta - Ayllos','bloqueiaFundo(divRotina);',false);
	}
	
    //echo ;

	require_once("grupo_economico_integrantes.php");
?>
<script>
controlaLayoutInclusaoIntegrante();
$('#divUsoGenerico').css('z-index','100');
$('#divUsoGenerico').css('width','480px');

<? if (getByTagName($xmlObjeto->roottag->tags[0]->tags,'inpessoa') == 1){ ?>
	 $('#peparticipacao', '#frmGrupoEconomicoIntegrantes').desabilitaCampo();	
<? } ?>


</script>