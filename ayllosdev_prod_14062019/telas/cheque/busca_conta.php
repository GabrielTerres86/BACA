<?
/*!
 * FONTE        : busca_conta.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 11/05/2011
 * OBJETIVO     : Realiza a pesquisa do titular pela conta informada
 * --------------
 * ALTERAÇÕES   : 06/08/2014 - Conversão Progress >> Oracle ( Renato - Supero )
 * -------------- 
 */ 
?>

<?	
	session_start();	
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();	

	// Verifica permissões de acessa a tela
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> '') exibirErro('error',$msgError,'Alerta - Aimaro','',false);	
	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '';	
	
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inválida.','Alerta - Aimaro','',false);
	if (!validaInteiro($idseqttl)) exibirErro('error','Titular inválido.','Alerta - Aimaro','',false);

	$xml  = "";
	$xml .= "<Root>";
	//$xml .= "	<Cabecalho>";
	//$xml .= "		<Bo>b1wgen0040.p</Bo>";
	//$xml .= "		<Proc>verifica-conta</Proc>";
	//$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
    $xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<idseqttl>".$idseqttl."</idseqttl>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
		
	//$xmlResult 	= getDataXML($xml);
	$xmlResult = mensageria($xml, "CHEQUE", "VERIFCONTA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto 	= getObjectXML($xmlResult);		
	
	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;			
		exibirErro('error',$msgErro,'Alerta - Aimaro','$(\'#nrdconta\',\'#frmCabCheque\').focus();',false);
	} 
		
	$nmprimtl	= getByTagname($xmlObjeto->roottag->tags[0]->tags,'nmprimtl');
	$qtrequis	= getByTagname($xmlObjeto->roottag->tags[0]->tags,'qtrequis');
	
	echo "setTitular('".$nmprimtl."','".$qtrequis."');";
	
?>