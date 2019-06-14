<? 
/*!
 * FONTE        : valida_bens.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 02/05/2011 
 * OBJETIVO     : Valida dados da rotina filha de Bens da rotina de Emprestimos 
 * --------------
 * ALTERAÇÕES   : 15/10/2015 - Removido caracter inválido do xml. SD 320666 (Kelvin). 
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
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '';
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
	$dsrelbem = (isset($_POST['dsrelbem'])) ? retiraAcentos(removeCaracteresInvalidos($_POST['dsrelbem'])) : '';
	$persemon = (isset($_POST['persemon'])) ? $_POST['persemon'] : '';
	$qtprebem = (isset($_POST['qtprebem'])) ? $_POST['qtprebem'] : '';
	$vlprebem = (isset($_POST['vlprebem'])) ? $_POST['vlprebem'] : '';
	$vlrdobem = (isset($_POST['vlrdobem'])) ? $_POST['vlrdobem'] : '';
	$idseqbem = (isset($_POST['idseqbem'])) ? $_POST['idseqbem'] : '';
	$dsrelbem = str_replace("<","",$dsrelbem);
	$dsrelbem = str_replace(">","",$dsrelbem);
	// Monta o xml de requisição
	$xml = "";
	$xml.= "<Root>";
	$xml.= "	<Cabecalho>";
	$xml.= "		<Bo>b1wgen0056.p</Bo>";
	$xml.= "		<Proc>valida-dados</Proc>";
	$xml.= "	</Cabecalho>";
	$xml.= "	<Dados>";
	$xml.= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml.= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml.= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml.= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml.= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml.= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xml.= "		<nrdconta>".$nrdconta."</nrdconta>";
    $xml.= "		<idseqttl>".$idseqttl."</idseqttl>";
	$xml.= "		<cddopcao>".$cddopcao."</cddopcao>";		
	$xml.= "		<dsrelbem>".$dsrelbem."</dsrelbem>";		
	$xml.= "		<persemon>".$persemon."</persemon>";		
	$xml.= "		<qtprebem>".$qtprebem."</qtprebem>";		
	$xml.= "		<vlprebem>".$vlprebem."</vlprebem>";
	$xml.= "		<vlrdobem>".$vlrdobem."</vlrdobem>";
	$xml.= "		<idseqbem>".$idseqbem."</idseqbem>";
	$xml.= "	</Dados>";
	$xml.= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObj = getObjectXML($xmlResult);
	
	if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
		exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo($(\'#divUsoGenerico\'))',false);
		
	}
?>