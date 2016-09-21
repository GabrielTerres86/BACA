<? 
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Lucas R.
 * DATA CRIAÇÃO : 24/05/2013
 * OBJETIVO     : Buscar dados BNDES da rotina de prestações da tela ATENDA 
 * 
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */	 
?>

<?
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");		
	require_once("../../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"])) <> "") {
		exibeErro($msgError);		
	}	

	$nrdconta = $_POST['nrdconta'] == '' ? 0 : $_POST['nrdconta'];	
		
	// Monta o xml de requisi&ccedil;&atilde;o
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Cabecalho>";
	$xml .= "    <Bo>b1wgen0147.p</Bo>";
	$xml .= "    <Proc>dados_bndes</Proc>";
	$xml .= "  </Cabecalho>";
	$xml .= "  <Dados>";
	$xml .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "    <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";
			
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlGetBnd = getObjectXML($xmlResult);
			
	$registros = $xmlGetBnd->roottag->tags[0]->tags;
	
	$vlsaldod = $xmlGetBnd->roottag->tags[0]->attributes['VLSALDOD'];
	$vlparepr = $xmlGetBnd->roottag->tags[0]->attributes['VLPAREPR'];
	
	$registrosBnd = $xmlGetBnd->roottag->tags[0]->tags[0]->tags;
	
	include('tab_bndes.php');	
	
	?><script type="text/javascript">
	var arrayRegistros = new Array();
			
	arrayRegistros['dsdprodu'] = '<? echo getByTagName($registrosBnd,'dsdprodu'); ?>';
	arrayRegistros['nrctremp'] = '<? echo getByTagName($registrosBnd,'nrctremp'); ?>';
	arrayRegistros['vlropepr'] = '<? echo getByTagName($registrosBnd,'vlropepr'); ?>';
	arrayRegistros['vlparepr'] = '<? echo getByTagName($registrosBnd,'vlparepr'); ?>';
	arrayRegistros['vlsdeved'] = '<? echo getByTagName($registrosBnd,'vlsdeved'); ?>';
	arrayRegistros['qtdmesca'] = '<? echo getByTagName($registrosBnd,'qtdmesca'); ?>';
	arrayRegistros['perparce'] = '<? echo getByTagName($registrosBnd,'perparce'); ?>';
	arrayRegistros['dtinictr'] = '<? echo getByTagName($registrosBnd,'dtinictr'); ?>';
	arrayRegistros['dtlibera'] = '<? echo getByTagName($registrosBnd,'dtlibera'); ?>';
	arrayRegistros['qtparctr'] = '<? echo getByTagName($registrosBnd,'qtparctr'); ?>';
	arrayRegistros['dtpripag'] = '<? echo getByTagName($registrosBnd,'dtpripag'); ?>';
	arrayRegistros['dtpricar'] = '<? echo getByTagName($registrosBnd,'dtpricar'); ?>';
	arrayRegistros['percaren'] = '<? echo getByTagName($registrosBnd,'percaren'); ?>';
	
	controlaLayout();
	</script> <?
		
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlGetBnd->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlGetBnd->roottag->tags[0]->tags[0]->tags[4]->cdata);
				
	} 

?>
