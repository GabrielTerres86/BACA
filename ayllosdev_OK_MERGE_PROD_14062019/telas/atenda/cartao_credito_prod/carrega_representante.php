<? 
/*!
 * FONTE        : carrega_representante.php
 * CRIAÇÃO      : James Prust Junior
 * DATA CRIAÇÃO : 13/10/2015
 * OBJETIVO     : Carregar para selecionar os representantes
 * 
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */	 
?>
<?
    session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();

	// Guardo os parâmetos do POST em variáveis	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;	
	
	// Verifica se o número da conta e o titular são inteiros válidos
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inválida.','Alerta - Aimaro',"fechaRotina($('#divUsoGenerico'),divRotina);",false);
	
	// Montar o xml de Requisicao
	$xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <tpctrato>6</tpctrato>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <nrcpfcgc>0</nrcpfcgc>";	
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "ATENDA", "CONPRO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);
	
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',"fechaRotina($('#divUsoGenerico'),divRotina);",false);
	}

	$avalistas = $xmlObjeto->roottag->tags[0]->tags;
	include('tabela_representante.php');
?>	
<script type="text/javascript">
	controlaLayoutRepresentantes();
</script>