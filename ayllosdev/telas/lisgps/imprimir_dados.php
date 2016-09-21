<?
/*!
 * FONTE        : imprimir_dados.php
 * CRIA��O      : Andre Santos - SUPERO
 * DATA CRIA��O :  Setembro/2015
 * OBJETIVO     : Carregar dados para impress�es do LISGPS	
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

	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"V")) <> "") {
		?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
		exit();	
	}	

	// Recebe as variaveis
	$nrdconta 	= $_POST['nrdconta'];
	$nrseqdig 	= $_POST['nrseqdig'];
	$dsidenti 	= $_POST['dsidenti'];
	$dtmvtolt 	= $_POST['dtmvtolt'];
	$dsiduser 	= session_id();	

	// Monta o xml de requisi��o
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>'; 
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';	
	$xml .= '		<nrseqdig>'.$nrseqdig.'</nrseqdig>';
	$xml .= '		<dsiduser>'.$dsiduser.'</dsiduser>';
	$xml .= '		<dsidenti>'.$dsidenti.'</dsidenti>';
	$xml .= '		<dtmvtolt>'.$dtmvtolt.'</dtmvtolt>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "LISGPS", "IMPRGPS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");

	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra cr�tica
 	if ($xmlObjeto->roottag->tags[0]->name == "ERRO") {
	    exibeErro($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata);		 
    }

	// Obt�m nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
	$nmarqpdf = $xmlObjeto->roottag->cdata;
		
	// Chama fun��o para mostrar PDF do impresso gerado no browser
	visualizaPDF($nmarqpdf);
	
	// Fun��o para exibir erros na tela atrav�s de javascript
    function exibeErro($msgErro) { 
	  ?><script language="javascript">alert('<?php echo $msgErro; ?>');</script><?php
		exit();	
    }

?>