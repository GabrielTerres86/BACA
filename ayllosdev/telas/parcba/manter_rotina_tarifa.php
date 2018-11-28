<?php
	/*!
	 * FONTE        : manter_rotina_parametro.php
	 * CRIAÇÃO      : Alcemir Junior - Mout's
	 * DATA CRIAÇÃO : 21/09/2018
	 * OBJETIVO     : Rotina para manter as operações da tela PARCBA
	 * --------------
	 * ALTERAÇÕES   : 
	 * -------------- 
	 */		

	session_cache_limiter("private");
	session_start();

	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once("../../includes/controla_secao.php");
	require_once("../../class/xmlfile.php");
	isPostMethod();

	// Ler parametros passados via POST
	$cddopcao  = (isset($_POST["cddopcao"]))    ? $_POST["cddopcao"]    : ""; // Opção (C-Consulta/I-Inclusão/E-Exclusão)
	$cdhistor  = (isset($_POST["cdhistor"])) ? $_POST["cdhistor"] : 0; // Código da transacao
	$dscontabil  = (isset($_POST["dscontabil"])) ? $_POST["dscontabil"] : "";
    $nrctadeb_pf  = (isset($_POST["nrctadeb_pf"])) ? $_POST["nrctadeb_pf"] : 0;
	$nrctacrd_pf  = (isset($_POST["nrctacrd_pf"])) ? $_POST["nrctacrd_pf"] : 0;
	$nrctadeb_pj  = (isset($_POST["nrctadeb_pj"])) ? $_POST["nrctadeb_pj"] : 0;
	$nrctacrd_pj  = (isset($_POST["nrctacrd_pj"])) ? $_POST["nrctacrd_pj"] : 0;

	// Validar os campos e identificar as operações
	switch ($cddopcao) {
		// consulta trancao bancoob
		case "PT":
			if ($cdhistor == 0 ) {
				exibirErro('error','C&oacute;digo do hist&oacute;rico inv&aacute;lido.','Alerta - Ayllos',"focaCampoErro('cdhistor','frmCadTarifa');",false);
			}
			
			if ($dscontabil == "" ) {
				exibirErro('error','Descri&ccedil;&atilde;o cont&aacute;bil inv&aacute;lida.','Alerta - Ayllos',"focaCampoErro('dscontabil','frmCadTarifa');",false);
			}
			
			if ($nrctadeb_pf == 0 ) {
				exibirErro('error','N&uacute;mero da conta d&eacute;bito PF inv&aacute;lida.','Alerta - Ayllos',"focaCampoErro('nrctadeb_pf','frmCadTarifa');",false);
			}
			
			if ($nrctacrd_pf == 0 ) {
				exibirErro('error','N&uacute;mero da conta cr&eacute;dito PF inv&aacute;lida.','Alerta - Ayllos',"focaCampoErro('nrctacrd_pf','frmCadTarifa');",false);
			}
			
			if ($nrctadeb_pj == 0 ) {
				exibirErro('error','N&uacute;mero da conta d&eacute;bito PJ inv&aacute;lida.','Alerta - Ayllos',"focaCampoErro('nrctadeb_pj','frmCadTarifa');",false);
			}
			
			if ($nrctacrd_pj == 0 ) {
				exibirErro('error','N&uacute;mero da conta cr&eacute;dito PJ inv&aacute;lida.','Alerta - Ayllos',"focaCampoErro('nrctacrd_pj','frmCadTarifa');",false);
			}

			$nmdeacao = "INSERE_TARIFA";
		break;
		
		case "CT":
			$nmdeacao = "CONSULTA_TARIFA_CBA";
		break;

		case "ET":
			if ($cdhistor == 0 ) {
				exibirErro('error','C&oacute;digo do hist&oacute;rico inv&aacute;lido.','Alerta - Ayllos',"focaCampoErro('cdhistor','frmCadTarifa');",false);
			}

			$nmdeacao = "EXCLUI_TARIFA_CBA";
		break;
		
		default:
			// Se não for uma opção válida exibe o erro
			exibirErro("error","Op&ccedil;&atilde;o inv&aacute;lida.","Alerta - Aimaro","",false);
		break;
	}

	// Monta o xml
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";

	if ($cddopcao == "PT") {
	   $xml .= "<cdhistor>".$cdhistor."</cdhistor>";
	   $xml .= "<dscontabil>".$dscontabil."</dscontabil>";
	   $xml .= "<nrctadeb_pf>".$nrctadeb_pf."</nrctadeb_pf>";
	   $xml .= "<nrctacrd_pf>".$nrctacrd_pf."</nrctacrd_pf>";
	   $xml .= "<nrctadeb_pj>".$nrctadeb_pj."</nrctadeb_pj>";
	   $xml .= "<nrctacrd_pj>".$nrctacrd_pj."</nrctacrd_pj>";
	} else if ($cddopcao == "ET") {
		$xml .= "<cdhistor>".$cdhistor."</cdhistor>";
	}

    $xml .= "  </Dados>";
	$xml .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "PARCBA", $nmdeacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"],  "</Root>");

	// Cria objeto para classe de tratamento de XML
	//$xmlObjeto = getObjectXML($xmlResult);
	$xmlObjeto = simplexml_load_string($xmlResult);

	// Se ocorrer um erro, mostra crítica
 	if ($xmlObjeto->Erro->Registro->dscritic != "") {
		$msgErro = $xmlObjeto->Erro->Registro->dscritic;
		exibirErro("error",$msgErro,"Alerta - Aimaro","",false);
	}

	//Comando para ser excutado em caso de sucesso na operação
	$command = "";
	// Verificar se a opção é de consulta
	switch ($cddopcao) {
		case "PT" :
			$command .=  "finalizaGravacaoTarifa();";			
		break;
		
		case "CT":
			$command .= "limpaTabelaTarifa();";
			
			foreach($xmlObjeto->tarifa as $tarifa){				
				$command .=  "criaLinhaTarifa('".$tarifa->cdhistor.
				                           "','".$tarifa->dscontabil.
										   "','".$tarifa->nrctadeb_pf.
										   "','".$tarifa->nrctacrd_pf.
										   "','".$tarifa->nrctadeb_pj.
										   "','".$tarifa->nrctacrd_pj.
										   "');";
			}
			
			$command .= "formataTabTar();";		
		break;
		
		case "ET" :
			$command .=  "finalizaExclusaoTarifa();";			
		break;
	}
	
	//Esconde a mensagem de aguardo do processo e executa o comando criado pelas opções
	echo "hideMsgAguardo();" . $command;
?>