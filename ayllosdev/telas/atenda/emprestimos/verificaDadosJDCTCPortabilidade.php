<? 

	/**************************************************************************
	      Fonte: verificaDadosJDCTCPortabilidade.php                                        
	      Autor: Lucas Moreira
	      Data : Junho/2015                   Última Alteração: 22/05/2015 
	                                                                  
	      Objetivo  : Verifica dados de portabilidade no JDCTC
	                    
	**************************************************************************/
	
	session_cache_limiter("private");
	session_start();
	

	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"C")) <> "") {
		?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
		exit();	
	}

	// Verifica se parâmetros necessários foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrctremp"])) {
		?><script language="javascript">alert('Par&acirc;metros incorretos.');</script><?php
		exit();
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrctremp = $_POST['nrctremp'];
	
	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		?><script language="javascript">alert('Conta/dv inv&aacute;lida.');</script><?php
		exit();
	}
				
	$dsiduser = session_id();
	
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>'; 
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<nrctremp>'.$nrctremp.'</nrctremp>';
	$xml .= '	</Dados>';                                  
	$xml .= '</Root>';
	
	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "PORTAB_CRED", "VER_PORTAB", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjDados = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjDados->roottag->tags[0]->name) == "ERRO") {
		$msg = $xmlObjDados->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msg,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	}
	echo $xmlObjDados->roottag->tags[0]->cdata;
	
?>