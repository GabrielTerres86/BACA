<? 

	//************************************************************************//
	//*** Fonte: gera_declaracao.php                                       ***//
	//*** Autor: Gabriel Capoia - DB1                                      ***//
	//*** Data : Maio/2011                    �ltima Altera��o: 00/00/0000 ***//
	//***                                                                  ***//
	//*** Objetivo  : Carregar dados para impress�es da declara��o		   ***//
	//***                                                                  ***//	 
	//*** Altera��es:                                                      ***//
	//***                                                                  ***//	 
	//************************************************************************//
	
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
	if (!isset($_POST["nmrecben"]) || 
		!isset($_POST["nrbenefi"]) || 
		!isset($_POST["auxconta"]) || 
		!isset($_POST["cdagcpac"])) {
		?><script language="javascript">alert('Par&acirc;metros incorretos.');</script><?php
		exit();
	}	
	
	$nrdconta = $_POST['auxconta'];
	$idseqttl = 1;
	$nmrecben = $_POST["nmrecben"];
	$nrbenefi = $_POST["nrbenefi"];
	$dsiduser = session_id();
	$cdagcpac = $_POST['cdagcpac'];	
	
	// Monta o xml de requisi��o
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0091.p</Bo>';
	$xml .= '		<Proc>gera-declaracao</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>'; 
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '       <nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '       <idseqttl>'.$idseqttl.'</idseqttl>';
	$xml .= '       <nmrecben>'.$nmrecben.'</nmrecben>';
	$xml .= '		<nrbenefi>'.$nrbenefi.'</nrbenefi>';    
	$xml .= '		<dsiduser>'.$dsiduser.'</dsiduser>';
	$xml .= '       <cdagcpac>'.$cdagcpac.'</cdagcpac>';
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