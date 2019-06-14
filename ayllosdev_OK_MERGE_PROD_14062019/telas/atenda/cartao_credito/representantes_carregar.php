<?php 

	/*!
	 * FONTE        : representantes_carregar.php
	 * AUTOR        : David
	 * DATA CRIAÇÃO : 10/07/2012 
	 * OBJETIVO     : Script para carregar dados do representante 
	 * 001: [29/10/2010] David: Desenvolver script representantes_carregar.php
	 * 002: [18/01/2011] Jorge: Habilitar campo Titular do Cartao "#nmtitcrd" quando achar numero cpf no sistema
	 * 003: [10/07/2012] Guilherme Maba: Alimentar campo nmextttl no formulário.
	 
	 */
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	// Verifica se os parâmetros necessários foram informados
	if (!isset($_POST["idrepres"]) || !isset($_POST["nrcpfrep"]) || !isset($_POST["cddopcao"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}

	$cddopcao = $_POST["cddopcao"];
	$idrepres = $_POST["idrepres"];
	$nrcpfrep = $_POST["nrcpfrep"];	
	
	// Verifica se identificador do representante é um inteiro válido
	if (!validaInteiro($idrepres)) {
		exibeErro("Identificador de representante inv&aacute;lido.");
	}

	// Verifica se CPF do representante é um inteiro válido
	if (!validaInteiro($nrcpfrep)) {
		exibeErro("CPF do representante inv&aacute;lido.");
	}

	$nmabrevi = $cddopcao == "H" ? "no" : "yes";
	
	// Monta o xml de requisição
	$xmlRepresen  = "";
	$xmlRepresen .= "<Root>";
	$xmlRepresen .= "	<Cabecalho>";
	$xmlRepresen .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlRepresen .= "		<Proc>busca_dados_assoc</Proc>";
	$xmlRepresen .= "	</Cabecalho>";
	$xmlRepresen .= "	<Dados>";
	$xmlRepresen .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlRepresen .= "		<nrcpfrep>".$nrcpfrep."</nrcpfrep>";	
	$xmlRepresen .= "		<nmabrevi>".$nmabrevi."</nmabrevi>";
	$xmlRepresen .= "	</Dados>";
	$xmlRepresen .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlRepresen);

	// Cria objeto para classe de tratamento de XML
	$xmlObjRepresen = getObjectXML($xmlResult);
	
	$nmprimtl = $xmlObjRepresen->roottag->tags[0]->attributes["NMPRIMTL"];
	$dtnasctl = $xmlObjRepresen->roottag->tags[0]->attributes["DTNASCTL"];
	$bfexiste = $xmlObjRepresen->roottag->tags[0]->attributes["BFEXISTE"];
	
	if ($cddopcao == "N") { // Opção NOVO
		// Alimenta e configura campos	
		if ($bfexiste == "yes") { // CPF pertence a um associado			
			echo '$("#nmtitcrd","#frmNovoCartao").val("'.$nmprimtl.'").removeProp("disabled").removeProp("readonly").attr("class","campo");';
			echo '$("#nmextttl","#frmNovoCartao").val("'.$nmprimtl.'").attr("disabled","true").attr("readonly",true).attr("class","campo");';
			echo '$("#dtnasccr","#frmNovoCartao").val("'.$dtnasctl.'").prop("disabled",true).attr("readonly",true).attr("class","campoTelaSemBorda");';
			$dsidfoco = "dsadmcrd";
		} else {					
			echo '$("#nmtitcrd","#frmNovoCartao").val("").removeProp("disabled").removeProp("readonly").attr("class","campo");';
			echo '$("#nmextttl","#frmNovoCartao").val("").removeProp("disabled").removeProp("readonly").attr("class","campo");';
			echo '$("#dtnasccr","#frmNovoCartao").val("").removeProp("disabled").removeProp("readonly").attr("class","campo");';		
			$dsidfoco = "dtnasccr";
		}
		
		echo 'eval("cpfpriat = \''.formataNumericos("999.999.999-99",$nrcpfrep,".-").'\'");';
		
		echo '$("#'.$dsidfoco.'","#frmNovoCartao").focus();';
	} elseif ($cddopcao == "A") { // Opção Alterar
		// Alimenta e configura campos
		if ($bfexiste == "yes") { // CPF pertence a um associado			
			echo '$("#nmextttl","#frmNovoCartao").val("'.$nmprimtl.'").attr("disabled","true").attr("readonly",true).attr("class","campo");';
			echo '$("#dtnasccr","#frmNovoCartao").val("'.$dtnasctl.'").prop("disabled",true).attr("readonly",true).attr("class","campoTelaSemBorda");';
			$dsidfoco = "dsadmcrd";
		} else {
			echo '$("#nmextttl","#frmNovoCartao").val("").removeProp("disabled").removeProp("readonly").attr("class","campo");';
			echo '$("#dtnasccr","#frmNovoCartao").val("").removeProp("disabled").removeProp("readonly").attr("class","campo");';		
			$dsidfoco = "dtnasccr";
		}
		
		echo 'eval("cpfpriat = \''.formataNumericos("999.999.999-99",$nrcpfrep,".-").'\'");';
		
		echo '$("#'.$dsidfoco.'","#frmNovoCartao").focus();';
	} elseif ($cddopcao == "H") { // Op??o Habilitar 
		if ($idrepres == 1) {
			$dsidrepr = "pri";
		} else if ($idrepres == 2) {
			$dsidrepr = "seg";
		} else {
			$dsidrepr = "ter";		
		}
		
		// Alimenta e configura campos	
		if ($bfexiste == "yes") { // CPF pertence a um associado
			if ($idrepres == 1) {
				$dsidfoco = "nrcpfseg";
			} else if ($idrepres == 2) {
				$dsidfoco = "nrcpfter";
			} else {	
				$dsidfoco = "btnVoltarHabilita";
			}
			
			echo '$("#nmpes'.$dsidrepr.'","#frmHabilitaCartao").val("'.$nmprimtl.'").prop("disabled",true).attr("readonly",true).attr("class","campoTelaSemBorda");';
			echo '$("#dtnas'.$dsidrepr.'","#frmHabilitaCartao").val("'.$dtnasctl.'").prop("disabled",true).attr("readonly",true).attr("class","campoTelaSemBorda");';		
		} else {		
			if ($idrepres == 1) {
				$dsidfoco = "nmpespri";
			} else if ($idrepres == 2) {
				$dsidfoco = "nmpesseg";
			} else {	
				$dsidfoco = "nmpester";
			}
			
			echo '$("#nmpes'.$dsidrepr.'","#frmHabilitaCartao").val("").removeProp("disabled").removeProp("readonly").attr("class","campo");';
			echo '$("#dtnas'.$dsidrepr.'","#frmHabilitaCartao").val("").removeProp("disabled").removeProp("readonly").attr("class","campo");';		
		}
		
		echo 'eval("cpf'.$dsidrepr.'at = \''.formataNumericos("999.999.999-99",$nrcpfrep,".-").'\'");';
		
		echo '$("#'.$dsidfoco.'","#frmHabilitaCartao").focus();';
	}
	
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';	
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';
		
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}

?>