<? 
/*!
 * FONTE        : valida_impressao.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 08/06/2011 
 * OBJETIVO     : Valida dados para a impressão
 *************
 * ALTERAÇÃO: 
 *************
 * 001: [24/05/2013] Lucas R.		  (CECRED): Incluir camada nas includes "../".
 * 002: [08/06/2018] Marcos M.   (Envolti): Incluir contrato - P410
 */
?>
 
<?
	session_start();
	require_once('../../../../includes/config.php');
	require_once('../../../../includes/funcoes.php');
	require_once('../../../../includes/controla_secao.php');	
	require_once('../../../../class/xmlfile.php');
	isPostMethod();		
	
	// Guardo os parâmetos do POST em variáveis	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
    $nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : '';
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '';
	$recidepr = (isset($_POST['recidepr'])) ? $_POST['recidepr'] : '';
	$tplcremp = (isset($_POST['tplcremp'])) ? $_POST['tplcremp'] : '';
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
			
	// Monta o xml de requisição
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0002.p</Bo>";
	$xml .= "		<Proc>valida_impressao</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "       <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";		
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";	
	$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<idseqttl>".$idseqttl."</idseqttl>";
	$xml .= "		<recidepr>".$recidepr."</recidepr>";
	$xml .= "		<tplcremp>".$tplcremp."</tplcremp>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObj = getObjectXML($xmlResult);
			
	
	$mtdErro = 'bloqueiaFundo(divRotina);';
		
	if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
		exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',$mtdErro,false);
	}
	
	echo 'mostraDivImpressao("'.$operacao.'");';
				
?>