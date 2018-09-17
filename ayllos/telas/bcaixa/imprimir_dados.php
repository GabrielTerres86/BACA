<?
/*!
 * FONTE        : imprimir_dados.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 01/11/2011
 * OBJETIVO     : Faz as impressões da tela BCAIXA	
 * --------------
 * ALTERAÇÕES   : 20/12/2011 - alterado parametro tipconsu para geração de cabelho no relatorio(Tiago). 
 * -------------- 
 *                27/01/2012 - Alteracoes para imprimir cabeçalho ou não (Tiago).
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

	// Recebe as variaveis
	$dsiduser 	= session_id();	
	$operacao   = $_POST['operacao'];	
	$cddopcao   = $_POST['cddopcao'];	
	$ndrrecid   = $_POST['ndrrecid'];	
	$nrdlacre   = $_POST['nrdlacre'];
	
	$tipconsu   = isset($_POST['tipconsu']) ? $_POST['tipconsu'] : 'no';
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$cddopcao)) <> "") {
	    $teste = $glbvars["nmdatela"];
		$teste2 = $glbvars["nmrotina"];
		?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
		exit();	
	}	

	// Verifica se parâmetros necessários foram informados
	
	if (!isset($_POST['operacao']) ||
		!isset($_POST['cddopcao'])) {
		?><script language="javascript">alert('Par&acirc;metros incorretos.');</script><?php
		exit();
	}
	
	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0120.p</Bo>';
	$xml .= '		<Proc>'.$operacao.'</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>'; 
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<dsiduser>'.$dsiduser.'</dsiduser>';
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';
	$xml .= '		<ndrrecid>'.$ndrrecid.'</ndrrecid>';
	$xml .= '		<nrdlacre>'.$nrdlacre.'</nrdlacre>';
	$xml .= '		<tipconsu>'.$tipconsu.'</tipconsu>';
	$xml .= '	</Dados>';  	
	$xml .= '</Root>';

	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);

	// Cria objeto para classe de tratamento de XML
	$xmlObjDados = getObjectXML($xmlResult);
		
	?><?php
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