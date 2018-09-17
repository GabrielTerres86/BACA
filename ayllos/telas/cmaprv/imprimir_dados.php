<?
/*!
 * FONTE        : imprimir_dados.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 07/10/2011
 * OBJETIVO     : Carregar dados para impressões do CMAPRV	
 * --------------
 * ALTERAÇÕES   : 26/05/2015 - Remover a formatação do número da conta para imprimir o relatorio. Sempre imprimir complemento.(Douglas - Melhoria 018)
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

	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"R")) <> "") {
		?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
		exit();	
	}	

	// Verifica se parâmetros necessários foram informados
	if (!isset($_POST['cddopcao']) || 
		!isset($_POST['cdagenci']) ||
		!isset($_POST['nrdconta']) ||
		!isset($_POST['dtpropos']) ||
		!isset($_POST['dtaprova']) ||
		!isset($_POST['dtaprfim']) ||
		!isset($_POST['aprovad1']) ||
		!isset($_POST['aprovad2']) ||
		!isset($_POST['cdopeapv'])) {
		?><script language="javascript">alert('Par&acirc;metros incorretos.');</script><?php
		exit();
	}	
	
	// Recebe as variaveis
	$cddopcao 	= $_POST['cddopcao'];
	$cdagenc1 	= $_POST['cdagenci'];
	$nrdconta 	= !empty($_POST['nrdconta']) ? $_POST['nrdconta'] : 0;
	$dtpropos 	= $_POST['dtpropos'];
	$dtaprova 	= $_POST['dtaprova'];
	$dtaprfim 	= $_POST['dtaprfim'];
	$aprovad1 	= $_POST['aprovad1'];
	$aprovad2 	= $_POST['aprovad2'];
	$cdopeapv 	= $_POST['cdopeapv'];
	$dsiduser 	= session_id();	
	
	$nrdconta   = str_ireplace(array('.', '-'), '',$nrdconta);
	
	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0114.p</Bo>';
	$xml .= '		<Proc>Gera_Impressao</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>'; 
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<dsiduser>'.$dsiduser.'</dsiduser>';
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';
	$xml .= '		<cdagenc1>'.$cdagenc1.'</cdagenc1>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<dtpropos>'.$dtpropos.'</dtpropos>';
	$xml .= '		<dtaprova>'.$dtaprova.'</dtaprova>';
	$xml .= '		<dtaprfim>'.$dtaprfim.'</dtaprfim>';
	$xml .= '		<aprovad1>'.$aprovad1.'</aprovad1>';
	$xml .= '		<aprovad2>'.$aprovad2.'</aprovad2>';
	$xml .= '		<cdopeapv>'.$cdopeapv.'</cdopeapv>';
	$xml .= '		<confcmpl>S</confcmpl>';
	$xml .= '		<confimpr>N</confimpr>';
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