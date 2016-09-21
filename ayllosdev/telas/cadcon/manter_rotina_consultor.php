<?php
	/*!
	 * FONTE        : manter_rotina_consultor.php
	 * CRIA��O      : Heitor Schmitt (RKAM)
	 * DATA CRIA��O : 08/10/2015
	 * OBJETIVO     : Rotina para manter as opera��es da tela de Consultores
	 * --------------
	 * ALTERA��ES   : 
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
	$cddopcao     = (isset($_POST["cddopcao"]))    ? $_POST["cddopcao"]    : ""; // Op��o (C-Consulta/I-Inclus�o/A-Altera��o/E-Exclus�o)
	$cdconsultor  = (isset($_POST["cdconsultor"])) ? $_POST["cdconsultor"] : ""; // C�digo do Consultor
	$cdoperad     = (isset($_POST["cdoperad"]))    ? $_POST["cdoperad"]    : ""; // C�digo do Operador
	$cdagenci     = (isset($_POST["cdagenci"]))    ? $_POST["cdagenci"]    : ""; // C�digo da Agencia
	$nrdconta     = (isset($_POST["nrdconta"]))    ? $_POST["nrdconta"]    : ""; // N�mero da Conta

	//Validar permiss�o do usu�rio
	//if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$cddopcao)) <> "") {
	//	exibirErro("error",$msgError,"Alerta - Ayllos","",false);
	//}

	// Validar os campos e identificar as opera��es
	switch ($cddopcao) {
		case "C":
			$nmdeacao = "CADCON_CONSULTAR_CONSULTORES";
		break;

		case "CA":
			$nmdeacao = "CADCON_CONSULTAR_AGENCIAS";
		break;

		case "I":
			$nmdeacao = "CADCON_INCLUIR_CONSULTOR";
			// Verifica se os par�metros necess�rios foram informados
			if ($cdconsultor == "") {
				exibirErro("error","&Eacute; obrigat&oacuterio informar o c&oacute;digo da posi&ccedil;&atilde;o","Alerta - Ayllos","",false);
			}
		break;

		case "II":
			$nmdeacao = "CADCON_INCLUIR_AGENCIA";
		break;

		case "IO":
			$nmdeacao = "CADCON_CONSULTA_OPERADOR";
		break;

		case "IA":
			$nmdeacao = "CADCON_CONSULTA_AGENCIA";
		break;

		case "AO":
			$nmdeacao = "CADCON_CONSULTAR_AGENCIAS";
		break;

		case "AOA":
			$nmdeacao = "CADCON_CONSULTA_OPERADOR";
		break;

		case "AA":
			$nmdeacao = "CADCON_CONSULTA_AGENCIA";
		break;

		case "TO":
			$nmdeacao = "CADCON_CONSULTAR_AGENCIAS";
		break;

		case "TD":
			$nmdeacao = "CADCON_CONSULTAR_AGENCIAS";
		break;
		
		case "TA":
			$nmdeacao = "CADCON_CONSULTAR_CONTAS";
		break;

		case "AB":
			$nmdeacao = "CADCON_INATIVAR_CONSULTOR";

			if ($cdconsultor == "") {
				exibirErro("error","&Eacute; obrigat&oacuterio informar o c&oacute;digo da posi&ccedil;&atilde;o","Alerta - Ayllos","",false);
			}
		break;
		
		case "AC":
			$nmdeacao = "CADCON_INCLUIR_CONSULTOR";
			// Verifica se os par�metros necess�rios foram informados
			if ($cdconsultor == "") {
				exibirErro("error","&Eacute; obrigat&oacuterio informar o c&oacute;digo da posi&ccedil;&atilde;o","Alerta - Ayllos","",false);
			}
		break;
		
		case "AD":
			$nmdeacao = "CADCON_INCLUIR_AGENCIA";
			
			if ($cdconsultor == "") {
				exibirErro("error","&Eacute; obrigat&oacuterio informar o c&oacute;digo da posi&ccedil;&atilde;o","Alerta - Ayllos","",false);
			}
		break;
		
		case "T":
			$nmdeacao = "CADCON_TRANSFERE_CONTA";
		break;
		//Valida��o de permiss�o
		case "VA":
			$nmdeacao = "CADCON_CONSULTA_OPERADOR";
		break;
		
		case "ATIN":
			$nmdeacao = "CADCON_ATIVA_INATIVA_CONSULTOR";
		break;
		
		default:
			// Se n�o for uma op��o v�lida exibe o erro
			exibirErro("error","Op&ccedil;&atilde;o inv&aacute;lida.","Alerta - Ayllos","",false);
		break;
	}

	// Monta o xml
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	if($cddopcao == "C") {
		// Para consulta � necess�rio apenas o c�digo da cooperativa
		$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	} elseif ($cddopcao == "CA") {
		$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xml .= "		<cdconsultor>".$cdconsultor."</cdconsultor>";
	} elseif ($cddopcao == "I") {
		$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xml .= "		<cdconsultor>".$cdconsultor."</cdconsultor>";
		$xml .= "		<cdoperad>".$cdoperad."</cdoperad>";
	} elseif ($cddopcao == "IO") {
		$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xml .= "		<cdoperad>".$cdoperad."</cdoperad>";
	} elseif ($cddopcao == "IA") {
		$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xml .= "		<cdagenci>".$cdagenci."</cdagenci>";
	} elseif ($cddopcao == "II") {
		$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xml .= "		<cdconsultor>".$cdconsultor."</cdconsultor>";
		$xml .= "		<cdagenci>".$cdagenci."</cdagenci>";
	} elseif ($cddopcao == "AO") {
		$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xml .= "		<cdconsultor>".$cdconsultor."</cdconsultor>";
	} elseif ($cddopcao == "AOA") {
		$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xml .= "		<cdoperad>".$cdoperad."</cdoperad>";
	} elseif ($cddopcao == "AA") {
		$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xml .= "		<cdagenci>".$cdagenci."</cdagenci>";
	} elseif ($cddopcao == "TO") {
		$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xml .= "		<cdconsultor>".$cdconsultor."</cdconsultor>";
	} elseif ($cddopcao == "TD") {
		$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xml .= "		<cdconsultor>".$cdconsultor."</cdconsultor>";
	} elseif ($cddopcao == "TA") {
		$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xml .= "		<cdconsultororg>".$cdconsultor."</cdconsultororg>";
		$xml .= "		<cdconsultordst>".$cdoperad."</cdconsultordst>";
	} elseif ($cddopcao == "AB") {
		$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xml .= "		<cdconsultor>".$cdconsultor."</cdconsultor>";
	} elseif ($cddopcao == "AC") {
		$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xml .= "		<cdconsultor>".$cdconsultor."</cdconsultor>";
		$xml .= "		<cdoperad>".$cdoperad."</cdoperad>";
	} elseif ($cddopcao == "AD") {
		$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xml .= "		<cdconsultor>".$cdconsultor."</cdconsultor>";
		$xml .= "		<cdagenci>".$cdagenci."</cdagenci>";
	} elseif ($cddopcao == "T") {
		$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xml .= "		<cdconsultordst>".$cdconsultor."</cdconsultordst>";
		$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	} elseif ($cddopcao == "VA") {
		$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	} elseif ($cddopcao == "ATIN") {
		$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xml .= "		<cdconsultor>".$cdconsultor."</cdconsultor>";
	}

	$xml .= "  </Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "CADCON", $nmdeacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"],  "</Root>");

	// Cria objeto para classe de tratamento de XML
	//$xmlObjeto = getObjectXML($xmlResult);
	$xmlObjeto = simplexml_load_string($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
 	if ($xmlObjeto->Erro->Registro->dscritic != "") {
		$msgErro = $xmlObjeto->Erro->Registro->dscritic;
		exibirErro("error",$msgErro,"Alerta - Ayllos","",false);
	}

	//Comando para ser excutado em caso de sucesso na opera��o
	$command = "";
	// Verificar se a op��o � de consulta
	switch ($cddopcao) {
		case "C" :
			foreach($xmlObjeto->consultor as $consultor){
				$command .=  "criaLinhaConsulta('" . $consultor->cdconsultor . 
				                             "','" . $consultor->dtinclus .
										     "','" . $consultor->cdoperad .
											 "','" . $consultor->nmoperad ."');";
			}

			//Alternar a cor das linhas
			$command .= "zebradoLinhaTabela($('#tbConcon > tbody > tr'));";
			$command .= "formataTabCon();";
		break;
		
		case "CA" :
			$command .= "limpaTabelaAgencia();";
			foreach($xmlObjeto->agencia as $agencia){
				$command .=  "criaLinhaConsultaAgencia('" . $agencia->cdagenci . 
				                                    "','" . $agencia->nmextage ."');";
			}

			//Alternar a cor das linhas
			$command .= "zebradoLinhaTabela($('#tbConage > tbody > tr'));";
			$command .= "formataTabAge();";
		break;
		
		case "IO":
			foreach($xmlObjeto->operador as $operador){
				$command .= "associaOperadorCad('" . $operador->cdoperad . 
				                             "','" . $operador->nmoperad ."');";
			}
		break;
		
		case "IA":
			foreach($xmlObjeto->agencia as $agencia){
				$command .= "associaAgenciaCad('" . $agencia->cdagenci . 
				                            "','" . $agencia->nmextage ."');";
			}
		break;
		
		case "AO":
			foreach($xmlObjeto->operador as $operador){
				$command .= "associaOperadorAlt('" . $operador->cdoperad . 
				                             "','" . $operador->nmoperad ."');";
			}
			
			$command .= "limpaTabelaAgenciaAlt();";
			foreach($xmlObjeto->agencia as $agencia){
				$command .=  "criaLinhaAlteracaoAgencia('" . $agencia->cdagenci . 
				                                     "','" . $agencia->nmextage ."');";
			}

			//Alternar a cor das linhas
			$command .= "zebradoLinhaTabela($('#tbAltcon > tbody > tr'));";
			$command .= "formataTabAlt(0);";
			
			foreach($xmlObjeto->operador as $operador){
				if ($operador->situacao == "INATIVO") {
					$command .= "consultorInativo();";
				}
			}
		break;

		case "AOA":
			foreach($xmlObjeto->operador as $operador){
				$command .= "associaOperadorAlteracao('" . $operador->cdoperad . 
				                                   "','" . $operador->nmoperad ."');";
			}
		break;

		case "AA":
			foreach($xmlObjeto->agencia as $agencia){
				$command .= "associaAgenciaAlt('" . $agencia->cdagenci . 
				                            "','" . $agencia->nmextage ."');";
			}
		break;

		case "TO":
			foreach($xmlObjeto->operador as $operador){
				$command .= "associaOperadorTrfOrg('" . $operador->cdoperad . 
				                                "','" . $operador->nmoperad ."');";
			}
		break;

		case "TD":
		foreach($xmlObjeto->operador as $operador){
			$command .= "associaOperadorTrfDst('" . $operador->cdoperad . 
										    "','" . $operador->nmoperad ."');";
		}
		break;
		
		case "TA":
			foreach($xmlObjeto->conta as $conta){
				$command .= "criaLinhaContaTrf('" . $conta->nrdconta . 
											"','" . $conta->nmprimtl .
											"','" . $conta->cdagenci .
											"','" . $conta->nmextage ."');";
			}
		
			$command .= "zebradoLinhaTabela($('#tbTrfcon > tbody > tr'));";
			$command .= "formataTabTrf(0);";
		break;
		
		case "VA":
			foreach($xmlObjeto->operador as $operador){
				if ($operador->nvoperad == 1 || $operador->nvoperad == 0) {
					exibirErro("error","Usu&aacute;rio n&atilde;o possui permiss&atilde;o para utilizar essa op&ccedil;&atilde;o.","Alerta - Ayllos","",false);
				}
			}
		break;
	}
	
	//Esconde a mensagem de aguardo do processo e executa o comando criado pelas op��es
	echo "hideMsgAguardo();" . $command;
?>