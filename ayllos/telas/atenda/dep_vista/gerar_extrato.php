<?php 

	/************************************************************************
	   Fonte: gerar_extrato.php
	   Autor: Guilherme
	   Data : Fevereiro/2008                   Última Alteração: 10/04/2015

	   Objetivo  : Gerar o extrato da rotina dep.vista

	   Alterações: 02/10/2009 - Tratamento para listagem de depositos 
                                identificados no extrato (David).
								
				   09/02/2012 - Utilizar BO b1wgen0112 (David).			

				   31/05/2013 - Fixado valor do campo inisenta e retirado o
							    mesmo da verificacao de parametros. (Daniel) 
								
				   10/04/2015 - Alterado parametro cdprogra (David)			
	************************************************************************/
	
	session_cache_limiter("private");
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se n&uacute;mero da conta foi informado
	if (!isset($_POST["nrdconta"]) /* || !isset($_POST["inisenta"]) */ || !isset($_POST["inrelext"]) ) {
		?><script language="javascript">alert('Par&acirc;metros incorretos.');</script><?php
		exit();
	}	

	$nrdconta = $_POST["nrdconta"];
	$inisenta = "0" ; /* $_POST["inisenta"]; */
	$inrelext = $_POST["inrelext"];

	// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		?><script language="javascript">alert('Conta/dv inv&aacute;lida.');</script><?php
		exit();
	}
	
	// Verifica se o identificador de tarifa &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($inisenta)) {
		?><script language="javascript">alert('Identificador de tarifa inv&aacute;lido.');</script><?php
		exit();
	}
	
	// Verifica se o identificador de listagem no extrato &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($inrelext)) {
		?><script language="javascript">alert('Identificador de listagem de extrato inv&aacute;lido.');</script><?php
		exit();
	}		

	$dtiniper = isset($_POST["dtiniper"]) && validaData($_POST["dtiniper"]) ? $_POST["dtiniper"] : $glbvars["dtmvtolt"];
	$dtfimper = isset($_POST["dtfimper"]) && validaData($_POST["dtfimper"]) ? $_POST["dtfimper"] : $glbvars["dtmvtolt"];
	$dsiduser = session_id();	
	
	// Monta o xml de requisição
	$xmlGetExtrato  = '';
	$xmlGetExtrato .= '<Root>';
	$xmlGetExtrato .= '	<Cabecalho>';
	$xmlGetExtrato .= '		<Bo>b1wgen0112.p</Bo>';
	$xmlGetExtrato .= '		<Proc>Gera_Impressao</Proc>';
	$xmlGetExtrato .= '	</Cabecalho>';
	$xmlGetExtrato .= '	<Dados>';
	$xmlGetExtrato .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>'; 
	$xmlGetExtrato .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xmlGetExtrato .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xmlGetExtrato .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xmlGetExtrato .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xmlGetExtrato .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xmlGetExtrato .= '		<dtmvtopr>'.$glbvars['dtmvtopr'].'</dtmvtopr>';
	$xmlGetExtrato .= '		<cdprogra>'.$glbvars['nmdatela'].'</cdprogra>';
	$xmlGetExtrato .= '		<inproces>'.$glbvars['inproces'].'</inproces>';
	$xmlGetExtrato .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xmlGetExtrato .= '		<dsiduser>'.$dsiduser.'</dsiduser>';
	$xmlGetExtrato .= '		<flgrodar>yes</flgrodar>';
	$xmlGetExtrato .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xmlGetExtrato .= '		<idseqttl>1</idseqttl>';
	$xmlGetExtrato .= '		<tpextrat>1</tpextrat>';
	$xmlGetExtrato .= '		<dtrefere>'.$dtiniper.'</dtrefere>';
	$xmlGetExtrato .= '		<dtreffim>'.$dtfimper.'</dtreffim>';
	$xmlGetExtrato .= '		<flgtarif>'.($inisenta == 0 ? 'yes' : 'no').'</flgtarif>';
	$xmlGetExtrato .= '		<inrelext>'.$inrelext.'</inrelext>';
	$xmlGetExtrato .= '		<inselext>0</inselext>';
	$xmlGetExtrato .= '		<nrctremp>0</nrctremp>';
	$xmlGetExtrato .= '		<nraplica>0</nraplica>';
	$xmlGetExtrato .= '		<nranoref>0</nranoref>';
	$xmlGetExtrato .= '		<flgerlog>yes</flgerlog>';
	$xmlGetExtrato .= '	</Dados>';                                  
	$xmlGetExtrato .= '</Root>';
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetExtrato);

	// Cria objeto para classe de tratamento de XML
	$xmlObjExtrato = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjExtrato->roottag->tags[0]->name) == "ERRO") {
		?><script language="javascript">alert('<?php echo $xmlObjExtrato->roottag->tags[0]->tags[0]->tags[4]->cdata; ?>');window.close();</script><?php
		exit();
	} 
	
	// Obtém nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
	$nmarqpdf = $xmlObjExtrato->roottag->tags[0]->attributes["NMARQPDF"];
	
	// Chama função para mostrar PDF do impresso gerado no browser
	visualizaPDF($nmarqpdf);	
	
?>
