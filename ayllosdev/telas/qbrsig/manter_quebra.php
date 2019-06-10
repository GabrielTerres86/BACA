<?php
	/*!
	 * FONTE        : manter_regra.php
	 * CRIAÇÃO      : Heitor - Mouts
	 * DATA CRIAÇÃO : 07/12/2018
	 * OBJETIVO     : Rotina para manter as operações da tela QBRSIG
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
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : "";
	$cdcooper = (isset($_POST["cdcooper"])) ? $_POST["cdcooper"] : 0;
	$nrdconta = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : "";
	$nrseq_quebra_sigilo = (isset($_POST["nrseq_quebra_sigilo"])) ? $_POST["nrseq_quebra_sigilo"] : 0;
    $dtiniper = (isset($_POST["dtiniper"])) ? $_POST["dtiniper"] : "";
	$dtfimper = (isset($_POST["dtfimper"])) ? $_POST["dtfimper"] : "";
	$cdbandep = (isset($_POST["cdbandep"])) ? $_POST["cdbandep"] : 0;
	$cdagedep = (isset($_POST["cdagedep"])) ? $_POST["cdagedep"] : 0;
	$nrctadep = (isset($_POST["nrctadep"])) ? $_POST["nrctadep"] : 0;
	$nrcpfcgc = (isset($_POST["nrcpfcgc"])) ? $_POST["nrcpfcgc"] : 0;
	$nmprimtl = (isset($_POST["nmprimtl"])) ? $_POST["nmprimtl"] : "";
	$nrseqlcm = (isset($_POST["nrseqlcm"])) ? $_POST["nrseqlcm"] : 0;
	
	//if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		//exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	//}
	
	if ($cddopcao == "QBR") {
		//Validacoes Quebra
		if ($cdcooper == "" || $cdcooper == 0) {
			exibirErro('error',"Obrigat&oacute;rio informar a cooperativa!",'Alerta - Ayllos','',false);
		}

		if ($nrdconta == "") {
			exibirErro('error',"Obrigat&oacute;rio informar a conta!",'Alerta - Ayllos','',false);
		}

		if ($dtiniper == "") {
			exibirErro('error',"Obrigat&oacute;rio informar a data inicial!",'Alerta - Ayllos','',false);
		}

		if ($dtfimper == "") {
			exibirErro('error',"Obrigat&oacute;rio informar a data final!",'Alerta - Ayllos','',false);
		}
	} elseif ($cddopcao == "ARQ") {
		//Validacoes Geracao de Arquivos
		if ($nrseq_quebra_sigilo == "" || $nrseq_quebra_sigilo == 0) {
			exibirErro('error',"Obrigat&oacute;rio informar o n&uacute;mero da quebra!",'Alerta - Ayllos','',false);
		}
	} elseif ($cddopcao == "SLV") {
		//Validacoes Salvar
		if ($nrseq_quebra_sigilo == "" || $nrseq_quebra_sigilo == 0) {
			exibirErro('error',"Obrigat&oacute;rio informar o n&uacute;mero da quebra!",'Alerta - Ayllos','',false);
		}

		if ($nrseqlcm == "" || $nrseqlcm == 0) {
			exibirErro('error',"Obrigat&oacute;rio informar o sequencial do lan&ccedil;amento!",'Alerta - Ayllos','',false);
		}
	} elseif ($cddopcao == "RPC") {
		//Validacoes Reprocessar
		if ($nrseq_quebra_sigilo == "" || $nrseq_quebra_sigilo == 0) {
			exibirErro('error',"Obrigat&oacute;rio informar o n&uacute;mero da quebra!",'Alerta - Ayllos','',false);
		}
	}

	// Monta o xml
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";

	if($cddopcao == "QBR") {
		$xml .= "    <cdcoptel>".$cdcooper."</cdcoptel>";
		$xml .= "    <nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "    <dtiniper>".$dtiniper."</dtiniper>";
		$xml .= "    <dtfimper>".$dtfimper."</dtfimper>";
		$nmdeacao = "QBRSIG_QUEBRA_SIGILO";
	} elseif ($cddopcao == "ARQ") {
		$xml .= "    <nrseq_quebra_sigilo>".$nrseq_quebra_sigilo."</nrseq_quebra_sigilo>";
		$nmdeacao = "QBRSIG_GERA_ARQUIVO";
	} elseif ($cddopcao == "SLV") {
		$xml .= "    <nrseq_quebra_sigilo>".$nrseq_quebra_sigilo."</nrseq_quebra_sigilo>";
		$xml .= "    <nrseqlcm>".$nrseqlcm."</nrseqlcm>";
		$xml .= "    <cdbandep>".$cdbandep."</cdbandep>";
		$xml .= "    <cdagedep>".$cdagedep."</cdagedep>";
		$xml .= "    <nrctadep>".$nrctadep."</nrctadep>";
		$xml .= "    <nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
		$xml .= "    <nmprimtl>".$nmprimtl."</nmprimtl>";
		$nmdeacao = "QBRSIG_SALVAR_INFO";
	} elseif ($cddopcao == "RPC") {
		$xml .= "    <nrseq_quebra_sigilo>".$nrseq_quebra_sigilo."</nrseq_quebra_sigilo>";
		$nmdeacao = "QBRSIG_REPROCESSAR_QUEBRA";
	}

	$xml .= "  </Dados>";
	$xml .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "QBRSIG", $nmdeacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"],  "</Root>");

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
	if ($cddopcao == "QBR") {
		$command .=  "msgSucessoQbr();";
	} else if ($cddopcao == "ARQ") {
		$command .= "msgSucessoArq();";
	} else if ($cddopcao == "SLV") {
		$command .= "msgSucessoSlv('".$nrseq_quebra_sigilo.
					 		    "','".$nrseqlcm.
								"');";
	} else if ($cddopcao == "RPC") {
		$command .= "msgSucessoRpc();";
	}

	//Esconde a mensagem de aguardo do processo e executa o comando criado pelas opções
	echo "hideMsgAguardo();" . $command;
?>