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
	$xml .= "    <dsmotivo>".$nmdbusca."</dsmotivo>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	 $xmlResult = mensageria($xml, "PARCYB", "PARCYB_BUSCAR_MOTIVOS_CIN", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");

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
	
	$achouMotivo = false;
	if ($xmlObjeto->roottag->tags[0]->name == "MOTIVOS") {
		foreach($xmlObjeto->roottag->tags[0]->tags as $motivo){
			$achouMotivo = true;

			$command .=  "criaLinhaMotivoCinPesquisa('" . getByTagName($motivo->tags,'cdmotivo') . 
                      			                  "','" . getByTagName($motivo->tags,'dsmotivo') . "');";
		}
		
		//Alternar a cor das linhas
		$command .=  "zebradoLinhaTabela($('#tbPesqMotivoCin > tbody > tr'));";
	}
	
	if(!$achouMotivo){
		//Se não existir exibe o erro
		$command .= "showError('error','Motivo CIN n&atilde;o encontrado para o nome informado!','Alerta - Ayllos','$(\'#nmdbusca\',\'#frmPesquisaMotivoCin\').val(\'\').focus();')";
	}
	
	//Esconde a mensagem de aguardo do processo e executa o comando criado pelas opções
	echo "hideMsgAguardo();" . $command;
?>