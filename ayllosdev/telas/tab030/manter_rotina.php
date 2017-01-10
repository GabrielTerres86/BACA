<?php 
	/*******************************************************************************
	 Fonte: manter_rotina.php                                                 
	 Autor: Lucas                                                    
	 Data : Nov/2011                Última Alteração:  22/04/2013
	                                                                  
	 Objetivo  : Tratar as requisicoes da tela TAB030.                                  
	                                                                  
	 Alterações: 25/05/2012 - Incluido campo 'diasatrs(Dias atraso para relatorio)'
                              (Tiago). 	 
							  
				 22/04/2013 - Ajuste para a inslusao do parametro "Dias atraso para inadimplencia"
							  (Adriano).
							  
			     05/12/2016 - P341-Automatização BACENJUD - Alterar a passagem da descrição do 
                              departamento como parametros e passar o o código (Renato Darosci)
							  
	********************************************************************************/
	
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
	$vllimite = $_POST["vllimite"];  
	$vlsalmin = $_POST["vlsalmin"]; 
	$diasatrs = $_POST["diasatrs"];
	$atrsinad = $_POST["atrsinad"];
	
	// Verifica Permissão
	if (($msgError = validaPermissao($glbvars["nmdatela"],"",substr($cddopcao,0,1))) <> "") {
		exibirErro('error',$msgError,'Alerta - Ayllos','voltar()',false);
	}	
			
	// Verifica Opcao 	
	switch($cddopcao) {
		case 'C': {
		  $procedure = 'busca_tab030';	
		} break;
		case 'A': {
		  $procedure = 'altera_tab030';	
		} break;					
	}			
		
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Cabecalho>";
	$xml .= "    <Bo>b1wgen0129.p</Bo>";
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
	$xml .= "    <vllimite>".$vllimite."</vllimite>";
	$xml .= "    <vlsalmin>".$vlsalmin."</vlsalmin>";
	$xml .= "    <diasatrs>".$diasatrs."</diasatrs>";
	$xml .= "    <atrsinad>".$atrsinad."</atrsinad>";
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
	
	// Verifica opcao 	
	switch($cddopcao) {

		case 'A': {
			echo 'hideMsgAguardo();';
						
		} break;
		
		case 'C': {
			$vllimite = $xmlObjLog->roottag->tags[0]->attributes["VLLIMITE"];	
			$vlsalmin = $xmlObjLog->roottag->tags[0]->attributes["VLSALMIN"];	
			$diasatrs = $xmlObjLog->roottag->tags[0]->attributes["DIASATRS"];
			$atrsinad = $xmlObjLog->roottag->tags[0]->attributes["ATRSINAD"];
			echo '$("#vlsalmin","#frmTab030").val("'.$vlsalmin.'");'; 
			echo '$("#vllimite","#frmTab030").val("'.$vllimite.'");'; 			
			echo '$("#diasatrs","#frmTab030").val("'.$diasatrs.'");';
			echo '$("#atrsinad","#frmTab030").val("'.$atrsinad.'");';
			echo '$("#vllimite","#frmTab030").focus();';					
		
		} break;
	} 
	
	echo 'hideMsgAguardo();';	
		
?>
