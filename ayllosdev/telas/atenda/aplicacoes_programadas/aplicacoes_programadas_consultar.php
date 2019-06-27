<?php 

	//**********************************************************************************//
	//*** Fonte: aplicacoes_programadas_consultar.php                                ***//
	//*** Autor: David                                                               ***//
	//*** Data : Março/2010                   Última Alteração: 09/09/2018           ***//
	//***                                                                            ***//
	//*** Objetivo  : Mostrar opção de consulta para Aplicação Programada            ***//	
	//***                                                                            ***//	 
	//*** Alterações: 27/07/2018 - Derivação para Aplicação Programada               ***//
    //***                          (Proj. 411.2 - CIS Corporate)                     ***//
	//***             05/09/2018 - Inclusão do campo finalidade                      ***//
	//**                           (Proj. 411.2 - CIS Corporate)                     ***//
	//**********************************************************************************//
	
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
		exibeErro($msgError);		
	}
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrctrrpp"])|| !isset($_POST["cdprodut"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	
	
	$nrdconta = $_POST["nrdconta"];
	$nrctrrpp = $_POST["nrctrrpp"];
	$cdprodut = $_POST["cdprodut"];
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se o contrato da poupança é um inteiro válido
	if (!validaInteiro($nrctrrpp)) {
		exibeErro("N&uacute;mero de contrato inv&aacute;lido.");
	}	
	// Monta o xml de requisição
	$xmlConsultar  = "";
	$xmlConsultar .= "<Root>";
	$xmlConsultar .= "	<Cabecalho>";
	$xmlConsultar .= "		<Bo>b1wgen0006.p</Bo>";
	$xmlConsultar .= "		<Proc>consulta-poupanca</Proc>";
	$xmlConsultar .= "	</Cabecalho>";
	$xmlConsultar .= "	<Dados>";
	$xmlConsultar .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlConsultar .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlConsultar .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlConsultar .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlConsultar .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlConsultar .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlConsultar .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlConsultar .= "		<idseqttl>1</idseqttl>";
	$xmlConsultar .= "		<nrctrrpp>".$nrctrrpp."</nrctrrpp>";
	$xmlConsultar .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlConsultar .= "		<dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";
	$xmlConsultar .= "		<inproces>".$glbvars["inproces"]."</inproces>";
	$xmlConsultar .= "		<cdprogra>".$glbvars["nmdatela"]."</cdprogra>";	
	$xmlConsultar .= "	</Dados>";
	$xmlConsultar .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlConsultar);

	// Cria objeto para classe de tratamento de XML
	$xmlObjConsultar = getObjectXML($xmlResult);
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjConsultar->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjConsultar->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	$poupanca = $xmlObjConsultar->roottag->tags[0]->tags[0]->tags;
	
	//$diadebit = substr($poupanca[6]->cdata,0,2);
	$diadebit = $poupanca[7]->cdata;


	if ($cdprodut>0) {
		// Apl. programada
		// Monta o xml de requisição
		$xmlDet = "<Root>";
		$xmlDet .= " <Dados>";
		$xmlDet .= "  <nrdconta>".$nrdconta."</nrdconta>";    
		$xmlDet .= "  <idseqttl>1</idseqttl>";    
		$xmlDet .= "  <nrctrrpp>".$nrctrrpp."</nrctrrpp>";
		$xmlDet .= "  <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";			
		$xmlDet .= " </Dados>";
		$xmlDet .= "</Root>";
		$xmlResultDet = mensageria($xmlDet, "APLI0008", "DETALHE_APL_PGM", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObjDet = getObjectXML($xmlResultDet);
		if (strtoupper($xmlObjDet->roottag->tags[0]->name) == "ERRO") {
			$msgErro = $xmlObjDet->roottag->tags[0]->tags[0]->tags[4]->cdata;
			if ($msgErro == "") {
				$msgErro = $xmlObjDet->roottag->tags[0]->cdata;
			}
			exibeErro($msgErro);
			exit();
		}
		$apl_prog = $xmlObjDet->roottag->tags[0]->tags[0]->tags;	

		//Vamos adequar o saldo da app progr para igual ao formato da poupanca. ex. 1564,49
		$saldo = str_replace(".","",$apl_prog[10]->cdata);
		$poupanca[12]->cdata=$saldo; // Saldo
		$poupanca[13]->cdata=$apl_prog[11]->cdata; // Juros Acumulado
	 	$poupanca[15]->cdata=$apl_prog[12]->cdata; // dtinirpp
		$dsfinali = $apl_prog[18]->cdata; // Finalidade
		}
	else {
		$dsfinali ='Poupanca Programada'; // Finalidade
		}
	
	// Flags para montagem do formulário
	$flgAlterar   = false;
	$flgSuspender = false;	
	$legend 	  = "Consultar";
	
	include("aplicacoes_programadas_formulario_dados.php");
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}	
	
?>											
