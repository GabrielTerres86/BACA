<? 

	//************************************************************************//
	//*** Fonte: imprimir_dados.php                                        ***//
	//*** Autor: Gabriel Capoia - DB1                                      ***//
	//*** Data : Fevereiro/2011               �ltima Altera��o: 00/00/0000 ***//
	//***                                                                  ***//
	//*** Objetivo  : Carregar dados para impress�es das anota��es		   ***//
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
			
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"C")) <> "") {
		?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
		exit();	
	}	

	// Verifica se par�metros necess�rios foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrseqdig"])) {
		?><script language="javascript">alert('Par&acirc;metros incorretos.');</script><?php
		exit();
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrseqdig = $_POST["nrseqdig"];
	
	// Verifica se o n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		?><script language="javascript">alert('Conta/dv inv&aacute;lida.');</script><?php
		exit();
	}
	
	// Verifica se n�mero do contrato � um inteiro v�lido
	if (!validaInteiro($nrseqdig)) {
		?><script language="javascript">alert('Contrato inv&aacute;lido.');</script><?php
		exit();
	}
		
	$dsiduser = session_id();
		
	// Monta o xml de requisi��o
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0085.p</Bo>';
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
	$xml .= '       <nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<idseqttl>1</idseqttl>';
	$xml .= '		<nrseqdig>'.$nrseqdig.'</nrseqdig>';    
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