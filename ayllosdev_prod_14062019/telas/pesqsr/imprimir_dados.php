<?
/*!
 * FONTE        : imprimir_dados.php
 * CRIA��O      : Gabriel Santos (DB1)
 * DATA CRIA��O : 11/01/2013
 * OBJETIVO     : Carregar dados para impress�es da PESQDP	
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


	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"C")) <> "") {
		?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
		exit();	
	}	

	// Verifica se par�metros necess�rios foram informados
	if (!isset($_POST["dtcheque"]) ||
        !isset($_POST["nmarqimp"]))	{
		?><script language="javascript">alert('Par&acirc;metros incorretos.');</script><?php
		exit();
	}
		
	// Recebe as variaveis
	$dtcheque	= (isset($_POST['dtcheque'])) ? $_POST['dtcheque'] : $glbvars['dtmvtolt'];
    $nmarqimp	= (isset($_POST['nmarqimp'])) ? $_POST['nmarqimp'] : 'PESQSR_'.rand(1, 9999).'.lst';
	$dsiduser 	= session_id();	
		
	// Monta o xml de requisi��o
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0160.p</Bo>';
	$xml .= '		<Proc>Busca_Opcao_R</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>'; 
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<dtcheque>'.$dtcheque.'</dtcheque>';
	$xml .= '		<nmarqimp>'.$nmarqimp.'</nmarqimp>';
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