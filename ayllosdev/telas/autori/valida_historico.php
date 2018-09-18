<? 
/*!
 * FONTE        : valida_historico.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 06/07/2011 
 * OBJETIVO     : Rotina para validar o historico da tela AUTORI
 * --------------
 * ALTERAÇÕES   : 19/05/2014 - Ajustes referentes ao Projeto debito Automatico
 * -------------- 			   Softdesk 148330 (Lucas R.)
 *
 *				  19/12/2014 - Incluir controlaOperacao, cddopcao e efetuar 
 *							   inclusao somente se cddopcao for I1 (Lucas R. #235558)
 *
 * 				  14/04/2015 - Retirado Validação de acesso (Lucas R. #275648)
 */
?> 

<?php
	session_start();

	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
   
    $nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '' ; 
	$nrseqdig = (isset($_POST['nrseqdig'])) ? $_POST['nrseqdig'] : 1  ; 
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '' ;
	$cdhistor = (isset($_POST['cdhistor'])) ? $_POST['cdhistor'] : '' ;
	$dshistor = (isset($_POST['dshistor'])) ? $_POST['dshistor'] : '' ;
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ;
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0092.p</Bo>";
	$xml .= "		<Proc>valida-historico</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<idseqttl>".$nrseqdig."</idseqttl>";
	$xml .= "		<cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "		<cdhistor>".$cdhistor."</cdhistor>";
	$xml .= "		<dshistor>".$dshistor."</dshistor>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);
	
	$dshistor	= $xmlObjeto->roottag->tags[0]->attributes['DSHISTOR'];
	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Aimaro','$(\'#dshistor\',\'#frmAutori\').focus();',false);
	}
	echo "$('#dshistor','#frmAutori').val('".$dshistor."');";
	echo "hideMsgAguardo();";
	
	if ($cddopcao == 'I1') {
		echo "$('#btSalvarI5'       ,'#divBotoes').focus();";
		echo "controlaOperacao('I4');";
	}
	
	//echo "buscaHistorico();";
?>
