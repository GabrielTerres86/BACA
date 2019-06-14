<?
/*!
* FONTE        : imprimir_dados.php
* CRIAÇÃO      : Gabriel Capoia (DB1)
* DATA CRIAÇÃO : 11/01/2013
* OBJETIVO     : Carregar dados para impressões do MANCCF
* --------------
* ALTERAÇÕES   : Adicionado parametro de cddopcao para poder validar as permissoes SD 302218. (Kelvin)
*                24/11/2015 - Mesmo se o CDDOPCAO nao vier por post sempre vai ser opcao I de impressao
*                             (Tiago SD354305).
* -------------- 
*/ 
?>

<?php

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

	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : 'I'; 
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$cddopcao)) <> "") {
		?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
		exit();	
	}	

	// Verifica se parâmetros necessários foram informados
	if (!isset($_POST["nrdcontaImp"]) || 		
		!isset($_POST["dsseqdig"])) {
		?><script language="javascript">alert('Par&acirc;metros incorretos.');</script><?php
		exit();
	}		
		
	// Recebe as variaveis
	$nrdconta 	= $_POST['nrdcontaImp'];
	$dsseqdig 	= $_POST['dsseqdig'];	
	$dsiduser 	= session_id();	
	
	$aux = array(".","-");
	$nrdconta = str_replace($aux,"",$nrdconta);
	

	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0143.p</Bo>';
	$xml .= '		<Proc>Imprime_Carta</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';		
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';		
	$xml .= '       <nrdconta>'.$nrdconta.'</nrdconta>';	
	$xml .= '       <dsseqdig>'.$dsseqdig.'</dsseqdig>';	
	$xml .= '		<dsiduser>'.$dsiduser.'</dsiduser>';	
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