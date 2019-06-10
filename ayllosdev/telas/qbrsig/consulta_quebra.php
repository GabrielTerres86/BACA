<?php
	/*!
	 * FONTE        : consulta_regra.php
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
	$nrdconta = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : 0;
	$nrseq_quebra_sigilo = (isset($_POST["nrseq_quebra_sigilo"])) ? $_POST["nrseq_quebra_sigilo"] : 0;
	$idsitqbr = (isset($_POST["idsitqbr"])) ? $_POST["idsitqbr"] : 0;
	$iniregis = (isset($_POST["iniregis"])) ? $_POST["iniregis"] : 1;
	$qtregpag = (isset($_POST["qtregpag"])) ? $_POST["qtregpag"] : 10;

	// Monta o xml
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";

	if($cddopcao == "CCQ") {
		$xml .= "    <cdcoptel>".$cdcooper."</cdcoptel>";
		$xml .= "    <nrdconta>".$nrdconta."</nrdconta>";
		$nmdeacao = "QBRSIG_CON_CONTA";
	} elseif ($cddopcao == "CQQ") {
		$xml .= "    <nrseq_quebra_sigilo>".$nrseq_quebra_sigilo."</nrseq_quebra_sigilo>";
		$xml .= "    <idsitqbr>".$idsitqbr."</idsitqbr>";
		$xml .= "    <iniregis>".$iniregis."</iniregis>";
		$xml .= "    <qtregpag>".$qtregpag."</qtregpag>";
		$nmdeacao = "QBRSIG_CON_QUEBRA";
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
		exibirErro("error",$msgErro,"Alerta - Aimaro","estadoInicialQuebraSigilo();",false);
	}

	//Comando para ser excutado em caso de sucesso na operação
	$command = "";
	// Verificar se a opção é de consulta
	if ($cddopcao == "CCQ") {
		foreach($xmlObjeto->conta as $conta){
			$command .=  "setarDadosConta('".$conta->nmprimtl.
									   "','".$conta->nrcpfcgc.
									   "');";
		}
	} else if ($cddopcao == "CQQ") {
		foreach($xmlObjeto->quebra as $quebra){
			$command .=  "setarDadosQuebra('".$quebra->cdcooper.
				                        "','".$quebra->nrdconta.
										"','".$quebra->nrcpfcgc.
										"','".$quebra->nmprimtl.
										"','".$quebra->dtiniper.
						        	    "','".$quebra->dtfimper."');";

			$command .=  "incluirContaQuebra('".$quebra->nrdconta.
										  "','".$quebra->dtiniper.
						        	      "','".$quebra->dtfimper."');";
		}

		foreach($xmlObjeto->lancamentos as $lancamentos){
			$command .=  "criaLinhaLancamento('".$lancamentos->dtmvtolt.
										   "','".$lancamentos->cdhistor.
										   "','".$lancamentos->vllanmto.
										   "','".$lancamentos->idsitqbr.
										   "','".$lancamentos->nrseqlcm.
										   "','".$lancamentos->dsobsqbr.
										   "','".$lancamentos->nrdocmto.
										   "','".$lancamentos->cdbandep.
										   "','".$lancamentos->nmextbcc.
										   "','".$lancamentos->cdagedep.
										   "','".$lancamentos->nrctadep.
										   "','".$lancamentos->nrcpfcgc.
										   "','".$lancamentos->nmprimtl.
										   "');";
		}

		foreach($xmlObjeto->registros as $registros){
			$command .=  "atualizaTextoPaginacao('".$registros->qtregist."');";
		}

		$command .= "formataTabQbrSig();";
		$command .= "selecionaPrimeiroLancamento();";
	}

	//Esconde a mensagem de aguardo do processo e executa o comando criado pelas opções
	echo "hideMsgAguardo();" . $command;
?>