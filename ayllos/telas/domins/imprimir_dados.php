<?
/*!
 * FONTE        : imprimir_dados.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 25/05/2011
 * OBJETIVO     : Carregar dados para impressões do DOMINS	
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */ 
?>

<? 

	session_cache_limiter("private");
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	

	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"A")) <> "") {
		?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
		exit();	
	}	

	// Verifica se parâmetros necessários foram informados
	if (!isset($_POST["nrdconta"]) || 
		!isset($_POST["idseqttl"]) ||
		!isset($_POST["cdagebcb"]) ||
		!isset($_POST["dstextab"]) ||
		!isset($_POST["nrbenefi"]) ||
		!isset($_POST["nrctacre"]) ||
		!isset($_POST["cdorgpag"]) ||
		!isset($_POST["nrrecben"]) ||
		!isset($_POST["nmrecben"]) ||
		!isset($_POST["dsdircop"]) ||
		!isset($_POST["nmextttl"]) ||
		!isset($_POST["nmoperad"]) ||
		!isset($_POST["nmcidade"]) ||
		!isset($_POST["nmextcop"]) ||
		!isset($_POST["nmrescop"])) {
		?><script language="javascript">alert('Par&acirc;metros incorretos.');</script><?php
		exit();
	}	
	
	// Recebe as variaveis
	$nrdconta = $_POST['nrdconta'];
	$idseqttl = $_POST['idseqttl'];
	$cdagebcb = $_POST['cdagebcb'];
	$dstextab = $_POST['dstextab'];
	$nrbenefi = $_POST['nrbenefi'];
	$nrctacre = $_POST['nrctacre'];
	$cdorgpag = $_POST['cdorgpag'];
	$nrrecben = $_POST['nrrecben'];
	$nmrecben = $_POST['nmrecben'];
	$dsdircop = $_POST['dsdircop'];
	$nmextttl = $_POST['nmextttl'];
	$nmoperad = $_POST['nmoperad'];
	$nmcidade = $_POST['nmcidade'];
	$nmextcop = $_POST['nmextcop'];
	$nmrescop = $_POST['nmrescop'];
	$dsiduser = session_id();	

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		?><script language="javascript">alert('Conta/dv inv&aacute;lida.');</script><?php
		exit();
	}
	
	// Verifica se número do contrato é um inteiro válido
	if (!validaInteiro($idseqttl)) {
		?><script language="javascript">alert('Titular inv&aacute;lido.');</script><?php
		exit();
	}
		
	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0091.p</Bo>';
	$xml .= '		<Proc>gera-impressao</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>'; 
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
	$xml .= '		<cdagebcb>'.$cdagebcb.'</cdagebcb>';
	$xml .= '		<dstextab>'.$dstextab.'</dstextab>';
	$xml .= '		<nrbenefi>'.$nrbenefi.'</nrbenefi>';
	$xml .= '		<nrctacre>'.$nrctacre.'</nrctacre>';
	$xml .= '		<cdorgpag>'.$cdorgpag.'</cdorgpag>';
	$xml .= '		<nrrecben>'.$nrrecben.'</nrrecben>';
	$xml .= '		<nmrecben>'.$nmrecben.'</nmrecben>';
	$xml .= '		<dsdircop>'.$dsdircop.'</dsdircop>';
	$xml .= '		<nmextttl>'.$nmextttl.'</nmextttl>';
	$xml .= '		<nmoperad>'.$nmoperad.'</nmoperad>';
	$xml .= '		<nmcidade>'.$nmcidade.'</nmcidade>';
	$xml .= '		<nmextcop>'.$nmextcop.'</nmextcop>';
	$xml .= '		<nmrescop>'.$nmrescop.'</nmrescop>';
	$xml .= '		<dsiduser>'.$dsiduser.'</dsiduser>';
	$xml .= '	</Dados>';                                  
	$xml .= '</Root>';

	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjDados = getObjectXML($xmlResult);
	
		// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjDados->roottag->tags[0]->name) == "ERRO") {
		$msg = $xmlObjDados->roottag->tags[0]->tags[0]->tags[4]->cdata;
		?><script language="javascript">alert('<?php echo $msg; ?>');</script><?php
		exit();
	} 
	
	// Obtém nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
	$nmarqpdf = $xmlObjDados->roottag->tags[0]->attributes["NMARQPDF"];

	// Chama função para mostrar PDF do impresso gerado no browser
	visualizaPDF($nmarqpdf);

?>