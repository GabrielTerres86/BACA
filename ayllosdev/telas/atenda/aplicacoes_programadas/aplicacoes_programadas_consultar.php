<?php 

	//**********************************************************************************//
	//*** Fonte: aplicacoes_programadas_consultar.php                                ***//
	//*** Autor: David                                                               ***//
	//*** Data : Mar�o/2010                   �ltima Altera��o: 09/09/2018           ***//
	//***                                                                            ***//
	//*** Objetivo  : Mostrar op��o de consulta para Aplica��o Programada            ***//	
	//***                                                                            ***//	 
	//*** Altera��es: 27/07/2018 - Deriva��o para Aplica��o Programada               ***//
    //***                          (Proj. 411.2 - CIS Corporate)                     ***//
	//***             05/09/2018 - Inclus�o do campo finalidade                      ***//
	//**                           (Proj. 411.2 - CIS Corporate)                     ***//
	//**********************************************************************************//
	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"C")) <> "") {
		exibeErro($msgError);		
	}
	
	// Se par�metros necess�rios n�o foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrctrrpp"])|| !isset($_POST["cdprodut"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	
	
	$nrdconta = $_POST["nrdconta"];
	$nrctrrpp = $_POST["nrctrrpp"];
	$cdprodut = $_POST["cdprodut"];
	
	// Verifica se n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se o contrato da poupan�a � um inteiro v�lido
	if (!validaInteiro($nrctrrpp)) {
		exibeErro("N&uacute;mero de contrato inv&aacute;lido.");
	}	
	// Monta o xml de requisi��o
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
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjConsultar->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjConsultar->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	$poupanca = $xmlObjConsultar->roottag->tags[0]->tags[0]->tags;
	
	//$diadebit = substr($poupanca[6]->cdata,0,2);
	$diadebit = $poupanca[7]->cdata;


	if ($cdprodut>0) {
		// Apl. programada
		// Monta o xml de requisi��o
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
	
	// Flags para montagem do formul�rio
	$flgAlterar   = false;
	$flgSuspender = false;	
	$legend 	  = "Consultar";
	
	include("aplicacoes_programadas_formulario_dados.php");
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}	
	
?>											
