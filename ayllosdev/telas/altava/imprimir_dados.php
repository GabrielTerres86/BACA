<?
/*!
 * FONTE        : imprimir_dados.php
 * CRIA��O      : Rog�rius Milit�o (DB1)
 * DATA CRIA��O : 23/12/2011
 * OBJETIVO     : Faz as impress�es da tela ALTAVA	
 * --------------
 * ALTERA��ES   : 17/11/2014 - Imprimir dados a partir da BO b1wgen0115 (ADITIV) (Jonata-RKAM).
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

	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"A")) <> "") {
		?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
		exit();	
	}	

	// Verifica se par�metros necess�rios foram informados
	
	if (!isset($_POST['nrdconta']) ||
		!isset($_POST['nrctremp'])) {
		?><script language="javascript">alert('Par&acirc;metros incorretos.');</script><?php
		exit();
	}

	$c 			= array('.', '-'); 
	
	// Recebe as variaveis
	$dsiduser 	= session_id();	
	$nrdconta   = str_ireplace($c, '',$_POST['nrdconta']);	
	$nrctremp   = str_ireplace($c, '',$_POST['nrctremp']);	
	$nrcpfava   = $_POST['nrcpfava'];
	$nmdavali   = $_POST['nmdavali'];
	$uladitiv   = $_POST['uladitiv'];
	
	// Monta o xml de requisi��o
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0115.p</Bo>';
	$xml .= '		<Proc>Gera_Impressao</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<cdprogra>'.$glbvars['cdprogra'].'</cdprogra>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<dsiduser>'.$dsiduser.'</dsiduser>';
	$xml .= '		<cdaditiv>4</cdaditiv>';
	$xml .= '		<nraditiv>'.$uladitiv.'</nraditiv>';
	$xml .= '		<nrctremp>'.$nrctremp.'</nrctremp>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<dtmvtopr>'.$glbvars['dtmvtopr'].'</dtmvtopr>';
	$xml .= '		<inproces>'.$glbvars['inproces'].'</inproces>';
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