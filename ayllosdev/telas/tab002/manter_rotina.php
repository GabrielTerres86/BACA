<?php 
	/*********************************************************************
	 Fonte: manter_rotina.php                                                 
	 Autor: Lucas                                                    
	 Data : Nov/2011                Última Alteração:  
	                                                                  
	 Objetivo  : Tratar as requisicoes da tela Tab002.                                  
	                                                                  
	 Alterações: 				
	      05/12/2016 - P341-Automatização BACENJUD - Alterar a passagem da descrição do 
                       departamento como parametros e passar o o código (Renato Darosci)		
	**********************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");	
		
				
	$cddopcao = $_POST["cddopcao"]; /* Opcao */
	$qtfolind = $_POST["qtfolind"];  
	$qtfolcjt = $_POST["qtfolcjt"]; 
	
	// Verifica Permissão
	if (($msgError = validaPermissao($glbvars["nmdatela"],"",substr($cddopcao,0,1))) <> "") {
		exibirErro('error',$msgError,'Alerta - Ayllos','voltar()',false);
	}	
			
	// Verifica Opcao 	
	switch($cddopcao) {
		case 'C': {
		  $procedure = 'busca_tab002';
		} break;
		case 'A': {
		  $procedure = 'altera_tab002';	
		} break;
		case 'E': {
		  $procedure = 'deleta_tab002';	
		} break;		
		case 'I': {
		  $procedure = 'cria_tab002';	
		} break;		
	}			
		
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Cabecalho>";
	$xml .= "    <Bo>b1wgen0130.p</Bo>";
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
	$xml .= "    <cddepart>".$glbvars["cddepart"]."</cddepart>";
	$xml .= "    <qtfolind>".$qtfolind."</qtfolind>";
	$xml .= "    <qtfolcjt>".$qtfolcjt."</qtfolcjt>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);

	// Cria objeto para classe de tratamento de XML
	$xmlObjLog = getObjectXML($xmlResult);
		
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjLog->roottag->tags[0]->name) == "ERRO") {
	
		echo '$("#frmTab002").limpaFormulario();';
		
		//Esconde botões em caso de erro
		echo '$("#btAlterar","#divMsgAjuda").hide();';
		echo '$("#btSalvar","#divMsgAjuda").hide();';
		echo '$("#btExcluir","#divMsgAjuda").hide();';
		echo '$("#btExcluir","#divMsgAjuda").hide();';
		
		exibirErro('error',$xmlObjLog->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','',false);
	}
 	
	$qtfolind = $xmlObjLog->roottag->tags[0]->attributes["QTFOLIND"];	
	$qtfolcjt = $xmlObjLog->roottag->tags[0]->attributes["QTFOLCJT"];	
			
	// Verifica opcao 	
	switch($cddopcao) {
		
		case 'I': {
			
			echo "$('#qtfolind','#frmTab002').desabilitaCampo();";
			echo "$('#qtfolcjt','#frmTab002').desabilitaCampo();";
						
		} break; 
		
		case 'E': {
		
			echo '$("#frmTab002").limpaFormulario();';
						
		} break;
		
		case 'C': {
			
			echo '$("#qtfolcjt","#frmTab002").val("'.$qtfolcjt.'");'; 
			echo '$("#qtfolind","#frmTab002").val("'.$qtfolind.'");'; 
			
		} break;
		
	} 
	
	echo 'hideMsgAguardo();';	
		
?>
