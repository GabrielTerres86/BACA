<? 
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Mauro (MOUTS)
 * DATA CRIAÇÃO : Agosto/2017
 * OBJETIVO     : Mostrar opcao Principal da rotina do Grupo Economico da tela de CONTAS
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 
 20/02/2018 - #846981 Utilização da função removeCaracteresInvalidos (Carlos)
 
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
	
	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrdconta"])){
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	}
	
	$nrdconta = $_POST["nrdconta"] == "" ? 0 : $_POST["nrdconta"];
	
	// Verifica se o número da conta e o titular são inteiros válidos
	if (!validaInteiro($nrdconta)) {
		exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	}
	
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Dados>";
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "TELA_GRUPO_ECONOMICO", "GRUPO_ECONOMICO_CONSULTAR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML(removeCaracteresInvalidos($xmlResult));
	
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		if ($msgErro == "") {
			$msgErro = $xmlObjeto->roottag->tags[0]->cdata;
		}
		exibirErro('error',htmlentities($msgErro),'Alerta - Aimaro','bloqueiaFundo(divRotina);',false);
	}
	include('form_grupo_economico.php');	
?>
<script type='text/javascript'>
	controlaLayout();
	
	$('#idgrupo','#frmGrupoEconomico').val('<?= getByTagName($xmlObjeto->roottag->tags[0]->tags,'idgrupo') ?>');
	$('#nmgrupo','#frmGrupoEconomico').val('<?= getByTagName($xmlObjeto->roottag->tags[0]->tags,'nmgrupo') ?>');
	$('#dtinclusao','#frmGrupoEconomico').val('<?= getByTagName($xmlObjeto->roottag->tags[0]->tags,'dtinclusao') ?>');
	$('#dsobservacao','#frmGrupoEconomico').val('<?= getByTagName($xmlObjeto->roottag->tags[0]->tags,'dsobservacao') ?>');
	
	if ($('#idgrupo','#frmGrupoEconomico').val() == ''){
		showConfirmacao('Deseja Incluir o Grupo Econ&ocirc;mico?', 'Confirma&ccedil;&atilde;o - Aimaro', 'abreTelaInclusaoGrupoEconomico()', 'bloqueiaFundo(divRotina)', 'sim.gif', 'nao.gif');
	}
</script>
