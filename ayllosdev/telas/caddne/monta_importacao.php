<?php
/**************************************************************************************
	ATEN��O: SE ESTA TELA ALGUM DIA FOR LIBERADA PARA A PRODU��O TEM QUE SER ALTERADA
			 PARA O NOVO LAYOUT DO AYLLOS WEB.
			 FALAR COM O GABRIEL OU DANIEL. 19/02/2013.
****************************************************************************************/

	/*************************************************************************
	  Fonte: monta_importacao.php                                               
	  Autor: Jorge Issamu Hamaguchi                                             
	  Data : Dezembro/2011                       �ltima Altera��o: 13/08/2015
	  
	  Objetivo  : Montar importacao de enderecos dos arquivos do correio.          
	  
	  Altera��es: 13/08/2015 - Remover o caminho fixo. (James)
	  
	***********************************************************************/
	
	if( !ini_get('safe_mode') ){ 
		set_time_limit(300); 
	} 
	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	$cduflogr  = $_POST["cduflogr"];
	$dirArqDne = dirname(__FILE__) ."/arquivos/";
	$controle  = "";	
	
	// abre o diret�rio
	$diretorio = opendir($dirArqDne);
	while (($nome_item = readdir($diretorio)) !== false) {
		
		if ((strtoupper(substr($nome_item,0,3)) == strtoupper($cduflogr)."_") || 
		    (($cduflogr == "UNID_OPER") && strpos(strtoupper($nome_item),$cduflogr."_") === 0) ||
			(($cduflogr == "CPC") && strpos(strtoupper($nome_item),$cduflogr."_") === 0) ||
			(($cduflogr == "GRANDE_USUARIO") && strpos(strtoupper($nome_item),$cduflogr."_") === 0)) {		
			$controle = "OK";
			$filename = $nome_item;
			$nmarquiv = $dirArqDne.$filename;
			$Arq = $nmarquiv;
			
			//encriptacao e envio do arquivo
			require("../../includes/gnuclient_upload_file.php");			
		}
	}
	
	if ($controle != "OK") {
		exibeErro("Arquivo de transi&ccedil;&atilde;o do arquivo n&atilde;o encontrado.");
	} else {		
		unlink($Arq);			 	
		
		$xmlCarregaDados  = "";
		$xmlCarregaDados .= "<Root>";
		$xmlCarregaDados .= "	<Cabecalho>";
		$xmlCarregaDados .= "		<Bo>b1wgen0038.p</Bo>";
		$xmlCarregaDados .= "		<Proc>grava-importacao</Proc>";
		$xmlCarregaDados .= "	</Cabecalho>";
		$xmlCarregaDados .= "	<Dados>";
		$xmlCarregaDados .= "    	<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xmlCarregaDados .= "    	<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
		$xmlCarregaDados .= "    	<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
		$xmlCarregaDados .= "	 	<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
		$xmlCarregaDados .= "	 	<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
		$xmlCarregaDados .= "	 	<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
		$xmlCarregaDados .= "		<cdufende>".$cduflogr."</cdufende>";
		$xmlCarregaDados .= "	</Dados>";
		$xmlCarregaDados .= "</Root>";

		// Executa script para envio do XML
		$xmlResult = getDataXML($xmlCarregaDados);
		
		$xmlObjCarregaDados = getObjectXML($xmlResult);
		
		$dados = $xmlObjCarregaDados->roottag->tags[0]->tags[0];
		
		// Se ocorrer um erro, mostra cr�tica
		if (strtoupper($xmlObjCarregaDados->roottag->tags[0]->name) == "ERRO") {
			exibeErro($xmlObjCarregaDados->roottag->tags[0]->tags[0]->tags[4]->cdata);
		}
	}
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 		
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","hideMsgAguardo()");';
		exit();
	}
	
?>