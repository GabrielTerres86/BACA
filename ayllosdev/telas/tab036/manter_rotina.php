<?php 
	/*********************************************************************
	 Fonte: manter_rotina.php                                                 
	 Autor: Lucas/Gabriel                                                     
	 Data : Nov/2011                �ltima Altera��o:  
	                                                                  
	 Objetivo  : Tratar as requisicoes da tela TAB036.                                  
	                                                                  
	 Altera��es: 				
	**********************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");	
		
				
	$cddopcao = $_POST["cddopcao"]; /* Opcao */
	$vlrating = $_POST["vlrating"];  /*Vl vlrating para Atualiza��o dos dados */
	$vlgrecon = $_POST["vlgrecon"]; /* Vl GE para Atualiza��o dos dados */
	
	// Verifica Permiss�o
	if (($msgError = validaPermissao($glbvars["nmdatela"],"",substr($cddopcao,0,1))) <> "") {
		exibirErro('error',$msgError,'Alerta - Ayllos','voltar()',false);
	}	
			
	// Verifica Opcao 	
	if ($cddopcao == 'C') {
		  $procedure = '';	
	}
	
	if ($cddopcao == 'A') {
		  $procedure = '';	
	}
	
	// Verifica Opcao 	
	switch($cddopcao) {
		case 'C': {
		  $procedure = 'busca_tab036';
		} break;
		case 'P': {
		  $procedure = 'permiss_tab036';
		} break;
		case 'A': {
		  $procedure = 'altera_tab036';	
		} break;
	}			
		
	// Monta o xml de requisi��o
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Cabecalho>";
	$xml .= "    <Bo>b1wgen0124.p</Bo>";
	$xml .= "    <Proc>".$procedure."</Proc>";
	$xml .= "  </Cabecalho>";
	$xml .= "  <Dados>";
	$xml .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "    <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "    <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "    <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "    <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml .= "    <idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xml .= "    <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xml .= "    <dstextab>".$dstextab."</dstextab>"; 
	$xml .= "    <dsdepart>".$glbvars["dsdepart"]."</dsdepart>";
	$xml .= "    <vlrating>".$vlrating."</vlrating>";
	$xml .= "    <vlgrecon>".$vlgrecon."</vlgrecon>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);

	// Cria objeto para classe de tratamento de XML
	$xmlObjLog = getObjectXML($xmlResult);
		
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjLog->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObjLog->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','',false);
	} 	
	
	// Verifica opcao 	
	switch($cddopcao) {

		case 'A': {
		
			echo 'hideMsgAguardo();';
									
		} break;
				
		case 'C': {
		
			$vlrating = $xmlObjLog->roottag->tags[0]->attributes["VLRATING"];	
			$vlgrecon = $xmlObjLog->roottag->tags[0]->attributes["VLGRECON"];
			
			echo '$("#vlgrecon","#frmTab036").val("'.$vlgrecon.'");'; 
			echo '$("#vlrating","#frmTab036").val("'.$vlrating.'");'; 
			
		} break;
		
		case 'P': {

			echo 'busca_tab036();';
			echo 'habilita_campos();';
			
		} break; 

	} 
	
	echo 'hideMsgAguardo();';	
		
?>
