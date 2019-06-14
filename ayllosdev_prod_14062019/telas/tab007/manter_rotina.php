<?php 
	/*********************************************************************
	 Fonte: manter_rotina.php                                                 
	 Autor: Lucas/Gabriel                                                     
	 Data : Nov/2011                Última Alteração:  
	                                                                  
	 Objetivo  : Tratar as requisicoes da tela TAB070.                                  
	                                                                  
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
	$vlmaidep = $_POST["vlmaidep"]; 
	$vlmaisal = $_POST["vlmaisal"];
	$vlmaiapl = $_POST["vlmaiapl"];
	$vlmaicot = $_POST["vlmaicot"];
	$vlsldneg = $_POST["vlsldneg"];
	
	// Verifica Permissão
	if (($msgError = validaPermissao($glbvars["nmdatela"],"",substr($cddopcao,0,1))) <> "") {			
		exibirErro('error',$msgError,'Alerta - Ayllos','voltar()',false);
	}	
			
	// Verifica Opcao 	
	switch($cddopcao) {
		case 'C': {
		  $procedure = 'busca_tab007';
		} break;
		case 'P': {
		  $procedure = 'permiss_tab007';
		} break;
		case 'A': {
		  $procedure = 'altera_tab007';	
		} break;
	}			
	
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Cabecalho>";
	$xml .= "    <Bo>b1wgen0132.p</Bo>";
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
	$xml .= "    <cddopcao>".$cddopcao."</cddopcao>"; 
	$xml .= "    <cddepart>".$glbvars["cddepart"]."</cddepart>";
	$xml .= "    <vlmaidep>".$vlmaidep."</vlmaidep>";
	$xml .= "    <vlmaiapl>".$vlmaiapl."</vlmaiapl>";
	$xml .= "    <vlmaicot>".$vlmaicot."</vlmaicot>";
	$xml .= "    <vlmaisal>".$vlmaisal."</vlmaisal>";
	$xml .= "    <vlsldneg>".$vlsldneg."</vlsldneg>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);

	// Cria objeto para classe de tratamento de XML
	$xmlObjLog = getObjectXML($xmlResult);
		
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjLog->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObjLog->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','',false);
	
	}
	
	$vlmaidep = $xmlObjLog->roottag->tags[0]->attributes["VLMAIDEP"];	
	$vlmaisal = $xmlObjLog->roottag->tags[0]->attributes["VLMAISAL"];	
	$vlmaiapl = $xmlObjLog->roottag->tags[0]->attributes["VLMAIAPL"];	
	$vlmaicot = $xmlObjLog->roottag->tags[0]->attributes["VLMAICOT"];	
	$vlsldneg = $xmlObjLog->roottag->tags[0]->attributes["VLSLDNEG"];	
	
	// Verifica opcao 	
	switch($cddopcao) {

		case 'C': {
			
			echo '$("#vlmaidep","#frmTab007").val("'.$vlmaidep.'");'; 
			echo '$("#vlmaisal","#frmTab007").val("'.$vlmaisal.'");'; 
			echo '$("#vlmaiapl","#frmTab007").val("'.$vlmaiapl.'");'; 
			echo '$("#vlmaicot","#frmTab007").val("'.$vlmaicot.'");'; 
			echo '$("#vlsldneg","#frmTab007").val("'.$vlsldneg.'");'; 			 
		
		} break;
		
		case 'P': {

			echo 'consulta_tab007();';
			echo 'habilita_campos();';
			
		} break; 
				
	} 
	
	echo 'hideMsgAguardo();';	
		
?>
