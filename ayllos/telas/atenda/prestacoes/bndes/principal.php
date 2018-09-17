<?php
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Lucas R.
 * DATA CRIAÇÃO : 24/05/2013
 * OBJETIVO     : Buscar dados BNDES da rotina de prestações da tela ATENDA 
 * 
 * --------------
 * ALTERAÇÕES   : 21/07/2016 - Corrigi a chamada da funcao validaPermissao que estava incompleta, corrigi tambem
 *							   a forma de carregamento da variavel $registrosBnd, e a forma de recuperacao do retorno
 *							   XML "ERRO". SD 479874 (Carlos R.) 
 * --------------
 */	 

	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");		
	require_once("../../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"], $glbvars['nmrotina'], '@')) <> "") {
		exibeErro($msgError);		
	}	

	$nrdconta = ( isset($_POST['nrdconta']) && $_POST['nrdconta'] != '' ) ? $_POST['nrdconta'] : 0;	
		
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
	
	$registrosBnd = ( isset($xmlGetBnd->roottag->tags[0]->tags[0]->tags) ) ? $xmlGetBnd->roottag->tags[0]->tags[0]->tags : array();
	
	include('tab_bndes.php');	
	
	?><script type="text/javascript">
	var arrayRegistros = new Array();
			
	arrayRegistros['dsdprodu'] = '<?php echo getByTagName($registrosBnd,'dsdprodu'); ?>';
	arrayRegistros['nrctremp'] = '<?php echo getByTagName($registrosBnd,'nrctremp'); ?>';
	arrayRegistros['vlropepr'] = '<?php echo getByTagName($registrosBnd,'vlropepr'); ?>';
	arrayRegistros['vlparepr'] = '<?php echo getByTagName($registrosBnd,'vlparepr'); ?>';
	arrayRegistros['vlsdeved'] = '<?php echo getByTagName($registrosBnd,'vlsdeved'); ?>';
	arrayRegistros['qtdmesca'] = '<?php echo getByTagName($registrosBnd,'qtdmesca'); ?>';
	arrayRegistros['perparce'] = '<?php echo getByTagName($registrosBnd,'perparce'); ?>';
	arrayRegistros['dtinictr'] = '<?php echo getByTagName($registrosBnd,'dtinictr'); ?>';
	arrayRegistros['dtlibera'] = '<?php echo getByTagName($registrosBnd,'dtlibera'); ?>';
	arrayRegistros['qtparctr'] = '<?php echo getByTagName($registrosBnd,'qtparctr'); ?>';
	arrayRegistros['dtpripag'] = '<?php echo getByTagName($registrosBnd,'dtpripag'); ?>';
	arrayRegistros['dtpricar'] = '<?php echo getByTagName($registrosBnd,'dtpricar'); ?>';
	arrayRegistros['percaren'] = '<?php echo getByTagName($registrosBnd,'percaren'); ?>';
	
	controlaLayout();
	</script> <?php
		
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (isset($xmlGetBnd->roottag->tags[0]->name) && strtoupper($xmlGetBnd->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlGetBnd->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 

?>
