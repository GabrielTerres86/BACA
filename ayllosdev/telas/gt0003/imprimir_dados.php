<?
/*!
 * FONTE        : imprimir_dados.php
 * CRIA��O      : J�ssica (DB1)
 * DATA CRIA��O : 24/09/2013
 * OBJETIVO     : Carregar dados para impress�es da tela GT0003	
 * --------------
 * ALTERA��ES   : 
 * -------------- 
 */
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
	if (!isset($_POST["cdcooper"]) || 
		!isset($_POST["dtinici"]) ||
		!isset($_POST["dtfinal"])) {
		?><script language="javascript">alert('Par&acirc;metros incorretos.');</script><?
		exit();
	}

	// Recebe as variaveis
	$tiporel  = $_POST['tiporel'];
	$cdcooper = $_POST['cdcooper'];
	$dtinici  = $_POST['dtinici'];
	$dtfinal  = $_POST['dtfinal'];		

	$dsiduser 	= session_id();		

	// Monta o xml de requisi��o
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0177.p</Bo>';
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
	$xml .= '		<tiporel>'.$tiporel.'</tiporel>';
	$xml .= '		<cdcooped>'.$cdcooper.'</cdcooped>';
	$xml .= '		<dtinici>'.$dtinici.'</dtinici>';
	$xml .= '		<dtfinal>'.$dtfinal.'</dtfinal>';
	$xml .= '	</Dados>';                                  
	$xml .= '</Root>';

	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);

	// Cria objeto para classe de tratamento de XML
	$xmlObjDados = getObjectXML($xmlResult);

	if (strtoupper($xmlObjDados->roottag->tags[0]->name) == 'ERRO') {
		$msgErro	= $xmlObjDados->roottag->tags[0]->tags[0]->tags[4]->cdata;	
        exibirErro('error',$msgErro,'Alerta - Ayllos','$(\'#cdcooper\',\'#frmRelatorio\').habilitaCampo(); formataRelatorio(); focaCampoErro(\'cdcooper\',\'frmRelatorio\');',false);
	} 

	// Obt�m nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
	$nmarqpdf = $xmlObjDados->roottag->tags[0]->attributes["NMARQPDF"];

	// Chama fun��o para mostrar PDF do impresso gerado no browser
	echo 'Gera_Impressao("'.$nmarqpdf.'","formataRelatorio()");';		
		
	
?>