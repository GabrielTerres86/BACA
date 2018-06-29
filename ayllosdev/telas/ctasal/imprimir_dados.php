<?
/*!
 * FONTE        : imprimir_dados.php
 * CRIAÇÃO      : Gabriel Santos (DB1)
 * DATA CRIAÇÃO : 11/01/2013
 * OBJETIVO     : Carregar dados para impressões da CTASAL	
 * --------------
 * ALTERAÇÕES   : 14/05/2018 - Incluido novo campo "Tipo de Conta" (tpctatrf) na tela CTASAL
 *                              Projeto 479-Catalogo de Servicos SPB
 *                              (Mateus Z - Mouts)
 * -------------- 
 */ 
?>

<?
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	session_start();
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");
	require_once('../../class/xmlfile.php');
	isPostMethod();		

	
	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	

	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");

	

	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"C")) <> "") {
		?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
		exit();	
	}	

	// Verifica se parâmetros necessários foram informados
	if (!isset($_POST['nrdconta']) || 
		!isset($_POST['cdagenca']) ||
		!isset($_POST['cdempres']) ||
		!isset($_POST['cdbantrf']) ||
		!isset($_POST['cdagetrf']) ||
		!isset($_POST['flgsolic']) ||
		!isset($_POST['tpctatrf'])) {
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
	$tpctatrf = $_POST['tpctatrf'];	
	$dsiduser 	= session_id();	
	
	$nrdconta = str_replace($aux,"",$nrdconta);
		
	// Monta o xml de requisição
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
	$xml .= '		<tpctatrf>'.$tpctatrf.'</tpctatrf>';	
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