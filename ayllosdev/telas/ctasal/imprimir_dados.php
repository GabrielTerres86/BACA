<?
/*!
 * FONTE        : imprimir_dados.php
 * CRIA��O      : Gabriel Santos (DB1)
 * DATA CRIA��O : 11/01/2013
 * OBJETIVO     : Carregar dados para impress�es da CTASAL	
 * --------------
 * ALTERA��ES   : 
 * -------------- 
 */ 
?>

<?
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	session_start();
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");
	require_once('../../class/xmlfile.php');
	isPostMethod();		

	
	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	

	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");

	

	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"C")) <> "") {
		?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
		exit();	
	}	

	// Verifica se par�metros necess�rios foram informados
	if (!isset($_POST['nrdconta']) || 
		!isset($_POST['cdagenca']) ||
		!isset($_POST['cdempres']) ||
		!isset($_POST['cdbantrf']) ||
		!isset($_POST['cdagetrf']) ||
		!isset($_POST['flgsolic'])) {
		?><script language="javascript">alert('Par&acirc;metros incorretos.');</script><?php
		exit();
	}
	
	$aux = array('.', '-');
	
	// Recebe as variaveis
	$nrdconta = $_POST['nrdconta'];
	$cdagenca = $_POST['cdagenca'];
	$cdempres = $_POST['cdempres'];
	$cdbantrf = $_POST['cdbantrf'];
	$cdagetrf = $_POST['cdagetrf'];
	$flgsolic = $_POST['flgsolic'];	
	$dsiduser 	= session_id();	
	
	$nrdconta = str_replace($aux,"",$nrdconta);
		
	// Monta o xml de requisi��o
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0151.p</Bo>';
	$xml .= '		<Proc>Gera_Impressao</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>'; 
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<dsiduser>'.$dsiduser.'</dsiduser>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<cdagenca>'.$cdagenca.'</cdagenca>';
	$xml .= '		<cdempres>'.$cdempres.'</cdempres>';
	$xml .= '		<cdbantrf>'.$cdbantrf.'</cdbantrf>';
	$xml .= '		<cdagetrf>'.$cdagetrf.'</cdagetrf>';
	$xml .= '		<flgsolic>'.$flgsolic.'</flgsolic>';	
	$xml .= '	</Dados>';                                  
	$xml .= '</Root>';

	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);

	// Cria objeto para classe de tratamento de XML
	$xmlObjDados = getObjectXML($xmlResult);
	
		// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjDados->roottag->tags[0]->name) == "ERRO") {
		$msg = $xmlObjDados->roottag->tags[0]->tags[0]->tags[4]->cdata;
		?><script language="javascript">alert('<?php echo $msg; ?>');</script><?php
		exit();
	} 
	
	// Obt�m nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
	$nmarqpdf = $xmlObjDados->roottag->tags[0]->attributes["NMARQPDF"];
	
	// Chama fun��o para mostrar PDF do impresso gerado no browser
	visualizaPDF($nmarqpdf);

?>