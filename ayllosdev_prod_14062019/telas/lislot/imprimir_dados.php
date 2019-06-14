<?
/*!
 * FONTE        : imprimir_dados.php
 * CRIAÇÃO      : Jéssica (DB1)
 * DATA CRIAÇÃO : 13/03/2014
 * OBJETIVO     : Realiza as impressões da tela LISLOT.	
 * --------------
 * ALTERAÇÕES   : 09/05/2016 - Ajustado os parametros para enviar e receber pelo metodo GET
 *							   para ajustar problema de permissão solicitado no chamado 447548. (Kelvin)
 *
 *				  11/11/2016 - Ajustes referente ao chamado 492589. (Kelvin)
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
	
	$c 			= array('.', '-'); 
	
	// Recebe as variaveis
	$dsiduser 	= session_id();	
	$cddopcao	= isset($_POST['cddopcao']) ? $_POST['cddopcao'] : '';
	$tpdopcao	= isset($_POST['tpdopcao']) ? $_POST['tpdopcao'] : 0;
	$nrdconta   = isset($_POST['nrdconta']) ? str_ireplace($c, '',$_POST['nrdconta']) : 0;	
	$dtinicio   = isset($_POST['dtinicio']) ? $_POST['dtinicio'] : '';
	$dttermin   = isset($_POST['dttermin']) ? $_POST['dttermin'] : '';
	$cdagenci	= isset($_POST['cdagenci']) ? $_POST['cdagenci'] : 0; 
	$nrdocmto	= isset($_POST['nrdocmto']) ? $_POST['nrdocmto'] : ''; 
	$vldocmto	= isset($_POST['vldocmto']) ? $_POST['vldocmto'] : 0; 
	$nmdopcao	= isset($_POST['nmdopcao']) ? $_POST['nmdopcao'] : ''; 
	$cdhistor	= isset($_POST['cdhistor']) ? $_POST['cdhistor'] : 0;
	$dsiduser 	= isset($_POST['dsiduser']) ? $_POST['dsiduser'] : '';
	
		
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$cddopcao)) <> "") {
		?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
		exit();	
	}	
	
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