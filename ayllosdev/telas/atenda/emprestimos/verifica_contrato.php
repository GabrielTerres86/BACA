<? 
/*!
 * FONTE        : verifica_contrato.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 26/04/2011 
 * OBJETIVO     : Rotina de verificação do contrato impresso
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
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : '';
	$nrctrem2 = (isset($_POST['nrctrem2'])) ? $_POST['nrctrem2'] : '';
	$inusatab = (isset($_POST['inusatab'])) ? $_POST['inusatab'] : '';
	$nralihip = (isset($_POST['nralihip'])) ? $_POST['nralihip'] : '';
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
					
	// Monta o xml de requisição
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0002.p</Bo>";
	$xml .= "		<Proc>verifica-contrato</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "       <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<nrctremp>".$nrctremp."</nrctremp>";
	$xml .= "		<nrctrem2>".$nrctrem2."</nrctrem2>";
	$xml .= "		<inusatab>".$inusatab."</inusatab>";
	$xml .= "		<nralihip>".$nralihip."</nralihip>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObj = getObjectXML($xmlResult);
	
	if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
		exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo($(\'#divUsoGenerico\'));$(\'#nrctremp\',\'#frmContrato\').focus();',false);
	}
	
	echo "confirmaContrato('');";
					
?>