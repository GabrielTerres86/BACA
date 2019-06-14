<?php
	/*!
	* FONTE        : buscar_assessorias.php
	* CRIAÇÃO      : Douglas Quisinski
	* DATA CRIAÇÃO : 27/08/2015
	* OBJETIVO     : Rotina para buscar todas as assessorias que contém a descrição informada
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
	$nmdbusca  = (isset($_POST["nmdbusca"]))  ? $_POST["nmdbusca"]  : ""; // Descrição da Assessoria para pesquisar
	$nmdbusca  = retiraAcentos(removeCaracteresInvalidos($nmdbusca));     // Remover os caracteres inválidos depois troca os acentos

	//Validar permissão do usuário
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"C")) <> "") {
		exibirErro("error",$msgError,"Alerta - Ayllos","",false);
	}

	// Monta o xml
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= "    <dsassess>".$nmdbusca."</dsassess>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "PARCYB", "PARCYB_BUSCAR_ASSESSORIAS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");

	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
 	if ($xmlObjeto->roottag->tags[0]->name == "ERRO") {
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		exibirErro("error",$msgErro,"Alerta - Ayllos","",false);
	}
	
	$achouAssessoria = false;
	if ($xmlObjeto->roottag->tags[0]->name == "ASSESSORIAS") {
		foreach($xmlObjeto->roottag->tags[0]->tags as $assessoria){
			$achouAssessoria = true;

			$command .=  "criaLinhaAssessoriaPesquisa('" . getByTagName($assessoria->tags,'cdassessoria') . 
                      			                   "','" . getByTagName($assessoria->tags,'nmassessoria') . "');";
		}
		
		//Alternar a cor das linhas
		$command .=  "zebradoLinhaTabela($('#tbPesqAssessoria > tbody > tr'));";
	}
	
	if(!$achouAssessoria){
		//Se não existir exibe o erro
		$command .= "showError('error','Assessoria n&atilde;o encontrada para o nome informado!','Alerta - Ayllos','$(\'#nmdbusca\',\'#frmPesquisaAssessoria\').val(\'\').focus();')";
	}
	
	//Esconde a mensagem de aguardo do processo e executa o comando criado pelas opções
	echo "hideMsgAguardo();" . $command;
?>