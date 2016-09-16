<?
/*!
 * FONTE        : imprimir_dados.php
 * CRIAÇÃO      : Jéssica (DB1)
 * DATA CRIAÇÃO : 13/03/2014
 * OBJETIVO     : Realiza as impressões da tela LISLOT.	
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
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$_POST['cddopcao'])) <> "") {
		?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
		exit();	
	}	
	
	$c 			= array('.', '-'); 
	
	// Recebe as variaveis
	$dsiduser 	= session_id();	
	$cddopcao	= $_POST['cddopcao'];
	$tpdopcao	= $_POST['tpdopcao'];
	$nrdconta   = str_ireplace($c, '',$_POST['nrdconta']);	
	$dtinicio   = $_POST['dtinicio'];
	$dttermin   = $_POST['dttermin'];
	$cdagenci	= $_POST['cdagenci']; 
	$nrdocmto	= $_POST['nrdocmto']; 
	$vldocmto	= $_POST['vldocmto']; 
	$nmdopcao	= $_POST['nmdopcao']; 
	$cdhistor	= $_POST['cdhistor'];
	$dsiduser 	= $_POST['dsiduser'];	
		
	
	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0184.p</Bo>';
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
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';	
	$xml .= '		<cdagenci>'.$cdagenci.'</cdagenci>';	
	$xml .= '		<tpdopcao>'.$tpdopcao.'</tpdopcao>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<dtinicio>'.$dtinicio.'</dtinicio>';
	$xml .= '		<dttermin>'.$dttermin.'</dttermin>';
	$xml .= '		<nrdocmto>'.$nrdocmto.'</nrdocmto>';
	$xml .= '		<vldocmto>'.$vldocmto.'</vldocmto>';
	$xml .= '		<dsiduser>'.$dsiduser.'</dsiduser>';
	$xml .= '		<nmdopcao>'.$nmdopcao.'</nmdopcao>';
	$xml .= '		<cdhistor>'.$cdhistor.'</cdhistor>';
	$xml .= '	</Dados>';                                  
	$xml .= '</Root>';

	//Executa script para envio do XML
	$xmlResult = getDataXML($xml);

	// Cria objeto para classe de tratamento de XML
	$xmlObjDados = getObjectXML($xmlResult);
	
	
	if (strtoupper($xmlObjDados->roottag->tags[0]->name) == 'ERRO') {
		$msgErro	= $xmlObjDados->roottag->tags[0]->tags[0]->tags[4]->cdata;	
		
		?><script language="javascript">alert('<?php echo $msgErro; ?>');</script><?php
		exit();
				
	}
	
	
	$nmarqpdf = $xmlObjDados->roottag->tags[0]->attributes["NMARQPDF"];
		
	// Chama função para mostrar PDF do impresso gerado no browser
	visualizaPDF($nmarqpdf);
		
?>