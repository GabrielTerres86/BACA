<?
/*!
 * FONTE        : imprimir_dados.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 01/12/2011
 * OBJETIVO     : Faz as impressões da tela CONSCR	
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

	// Verifica se parâmetros necessários foram informados
	
	if (!isset($_POST['cddopcao']) ||
		!isset($_POST['tpconsul'])) {
		?><script language="javascript">alert('Par&acirc;metros incorretos.');</script><?php
		exit();
	}
	
	$c 			= array('.', '-'); 
	
	// Recebe as variaveis
	$dsiduser 	= session_id();	
	$cddopcao   = $_POST['cddopcao'];	
	$tpconsul   = $_POST['tpconsul'];	
	$cdagenci   = str_ireplace($c, '',$_POST['cdagenci']);
	$nrcpfcgc   = str_ireplace($c, '',$_POST['nrcpfaux']);
	$nrdconta   = str_ireplace($c, '',$_POST['nrdcoaux']);
	$nmprimtl	= $_POST['nmprimtl'];
	
	
	switch( $cddopcao ) {
		case 'F': $procedure = 'Imprimir_Fluxo'; break;
		case 'R': $procedure = 'Imprimir_Risco'; break;
	
	}
	
	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0125.p</Bo>';
	$xml .= '		<Proc>'.$procedure.'</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>'; 
	$xml .= '		<cdagencx>'.$glbvars['cdagenci'].'</cdagencx>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<cdprogra>'.$glbvars['cdprogra'].'</cdprogra>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<dtmvtopr>'.$glbvars['dtmvtopr'].'</dtmvtopr>';
	$xml .= '		<dsiduser>'.$dsiduser.'</dsiduser>';
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';
	$xml .= '		<tpconsul>'.$tpconsul.'</tpconsul>';
	$xml .= '		<nrcpfcgc>'.$nrcpfcgc.'</nrcpfcgc>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<nmprimtl>'.$nmprimtl.'</nmprimtl>';
	$xml .= '		<cdagenci>'.$cdagenci.'</cdagenci>';
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