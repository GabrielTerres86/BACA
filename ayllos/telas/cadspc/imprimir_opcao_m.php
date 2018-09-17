<?
/*!
 * FONTE        : imprimir_opcao_M.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 06/03/2012
 * OBJETIVO     : Faz as impressões da tela CADSPC	
 * --------------
 * ALTERAÇÕES   : 15/03/2012 - Correção tipo SPC/SERASA na impressão (Oscar).
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
	
	// Recebe as variaveis
	$dsiduser 	= session_id();	
	$cddopcao	= $_POST['cddopcao'];
	$cdagencx	= $_POST['cdagenci'];
	

	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0133.p</Bo>';
	$xml .= '		<Proc>Gera_Impressao</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<cdprogra>'.$glbvars['cdprogra'].'</cdprogra>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<dsiduser>'.$dsiduser.'</dsiduser>';
	$xml .= '		<cdagencx>'.$cdagencx.'</cdagencx>';
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
	
	function visualizaTXT($nmarquiv) {
		global $glbvars;
		$nmarqpdf  = "/var/www/ayllos/documentos/".$glbvars["dsdircop"]."/temp/".$nmarquiv;

		if (!file_exists($nmarqpdf) || !is_file($nmarqpdf)) {			
			?><script language="javascript">alert('Arquivo PDF nao foi gerado.<? echo $nmarqpdf ?>');</script><?php
			return false;
		}
		
		$fp = fopen($nmarqpdf,"r");
		$strPDF = fread($fp,filesize($nmarqpdf));
		fclose($fp);

		unlink($nmarqpdf);	
		
		$navegador = CheckNavigator();
		
		if ($navegador['navegador'] != 'chrome') {		
			header('Content-Type: application/x-download');			
			header('Content-disposition: attachment; filename="'.$nmarquiv.'"');				
		} else { 
			header('Content-Type: application/txt');			
			header('Content-disposition: inline; filename="'.$nmarquiv.'"');
		}			
		
		header("Expires: 0"); 
		header("Cache-Control: no-cache");
		header('Cache-Control: private, max-age=0, must-revalidate');
		header("Pragma: public");
		
		echo $strPDF;	
	}
	
	// Chama função para mostrar PDF do impresso gerado no browser
	visualizaTXT($nmarqpdf);
	
?>