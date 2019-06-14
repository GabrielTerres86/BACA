<? 
/*!
 * FONTE        : atualizar_valor_seguro.php
 * CRIAÇÃO      : Adriano Marchi
 * DATA CRIAÇÃO : 21/12/2015
 * OBJETIVO     : Atualzar valor do plano
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */
?> 
<?
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	$cddopcao		= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ; 
	
	// Verifica Permiss&atilde;o
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$cddopcao)) <> "") {
		exibeErro($msgError);		
	}	
	
	$tpseguro = (isset($_POST['tpseguro']))? $_POST['tpseguro'] : '';
	$tpplaseg = (isset($_POST['tpplaseg']))? $_POST['tpplaseg'] : 0;
	$nrtabela = (isset($_POST['nrtabela']))? $_POST['nrtabela'] : 0;
	$datdespr = (isset($_POST['datdespr']))? $_POST['datdespr'] : '';
	$datdebit = (isset($_POST['datdebit']))? $_POST['datdebit'] : '';
	$vlpercen = (isset($_POST['vlpercen']))? $_POST['vlpercen'] : 0;
	
	$retornoCampo = "$('#btVoltar', '#divBotoes').focus();";
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlSetPesquisa  = "";
	$xmlSetPesquisa .= "<Root>";
	$xmlSetPesquisa .= "  <Cabecalho>";
	$xmlSetPesquisa .= "	    <Bo>b1wgen0033.p</Bo>";
	$xmlSetPesquisa .= "        <Proc>pi_atualizar_valor_seg</Proc>";
	$xmlSetPesquisa .= "  </Cabecalho>";
	$xmlSetPesquisa .= "  <Dados>";
	$xmlSetPesquisa .= "        <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetPesquisa .= "        <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSetPesquisa .= "        <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetPesquisa .= "        <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetPesquisa .= "        <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSetPesquisa .= "        <nrdconta>".$glbvars["nrdconta"]."</nrdconta>";
	$xmlSetPesquisa .= "        <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlSetPesquisa .= "        <idseqttl>".$glbvars["idseqttl"]."</idseqttl>";
	$xmlSetPesquisa .= "        <idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlSetPesquisa .= "        <flgerlog>FALSE</flgerlog>";
	$xmlSetPesquisa .= "		<tpseguro>".$tpseguro."</tpseguro>";
	$xmlSetPesquisa .= "		<tpplaseg>".$tpplaseg."</tpplaseg>";	
	$xmlSetPesquisa .= "		<nrtabela>".$nrtabela."</nrtabela>";	
	$xmlSetPesquisa .= "		<datdebit>".$datdebit."</datdebit>";	
	$xmlSetPesquisa .= "		<vlpercen>".$vlpercen."</vlpercen>";	
	$xmlSetPesquisa .= "		<datdespr>".$datdespr."</datdespr>";	
	$xmlSetPesquisa .= "  </Dados>";
	$xmlSetPesquisa .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetPesquisa );
	
	$xmlObjPesquisa = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjPesquisa->roottag->tags[0]->name) == "ERRO") {
		$msgErro	= $xmlObjPesquisa->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$erros = exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoCampo,false);
	} 	
	
	echo 'showError("inform", "Plano atualizado com sucesso.", "Alerta - Ayllos", "estadoInicial();");';
	
?>