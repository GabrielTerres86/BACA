<?
/*!
 * FONTE        : gerar_impressao.php
 * CRIA��O      : Daniel Zimmermann	
 * DATA CRIA��O : 16/01/2015
 * OBJETIVO     : Carregar dados para impress�es da tela HISTOR	
 * --------------
 * ALTERA��ES   : 
 * -------------- 
 */ 
?>

<?
	session_cache_limiter("private");
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");
	
	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	

	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");

	$cddopcao = $_POST['cddopcao'];

	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$cddopcao,false)) <> "") {
		?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
		exit();	
	}	
	
	
	if ( $cddopcao == 'B' ) {
		$procedure = 'Gera_ImpressaoB';
	} else {
		$procedure = 'Gera_ImpressaoO';
	}
	
	$dsiduser 	= session_id();

	// Monta o xml de requisi��o
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0179.p</Bo>';
	$xml .= '		<Proc>'.$procedure.'</Proc>';
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
	
	// Obt�m nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
	$nmarqpdf = $xmlObjDados->roottag->tags[0]->attributes["NMARQPDF"];
		
	// Chama fun��o para mostrar PDF do impresso gerado no browser
	visualizaPDF($nmarqpdf);
?>