<?
//*********************************************************************************************//
//*** Fonte: busca_conta.php                                    						                ***//
//*** Autor: Rafael B. Arins - Envolti                                           						***//
//*** Data : Abril/2018                  Última Alteração: --/--/----  					            ***//
//***                                                                  						          ***//
//*** Objetivo  : busca Conta da tela CUSAPL                   						                  ***//
//***                                                                  						          ***//
//*** Alterações: 																			                                    ***//
//*********************************************************************************************//

	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();

	// Verifica permissões de acessa a tela
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> '') exibirErro('error',$msgError,'Alerta - Ayllos','',false);

	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$cdcooper = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : '';
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '';

	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inválida.','Alerta - Ayllos','',false);
	if (!validaInteiro($idseqttl)) exibirErro('error','Titular inválido.','Alerta - Ayllos','',false);

	$xml  = "";
	$xml .= "<Root>";
	//$xml .= "	<Cabecalho>";
	//$xml .= "		<Bo>b1wgen0040.p</Bo>";
	//$xml .= "		<Proc>verifica-conta</Proc>";
	//$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "		<cdcooper>".$cdcooper."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<nmdatela>CHEQUE</nmdatela>";
	$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
  $xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<idseqttl>".$idseqttl."</idseqttl>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";

	//$xmlResult 	= getDataXML($xml);
	$xmlResult = mensageria($xml, "CHEQUE", "VERIFCONTA",
		//$cdcooper,
		$glbvars["cdcooper"],
		$glbvars["cdagenci"],
		$glbvars["nrdcaixa"],
		$glbvars["idorigem"],
		$glbvars["cdoperad"], "</Root>");
	$xmlObjeto 	= getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		echo 'showError', $msgErro;
	}

	$nmprimtl	= getByTagname($xmlObjeto->roottag->tags[0]->tags,'nmprimtl');
	$qtrequis	= getByTagname($xmlObjeto->roottag->tags[0]->tags,'qtrequis');

	echo $nmprimtl;

?>
