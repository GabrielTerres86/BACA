<?php
	/*!
	 * FONTE        : manter_rotina_motivo_cin.php
	 * CRIAÇÃO      : Douglas Quisinski
	 * DATA CRIAÇÃO : 26/08/2015
	 * OBJETIVO     : Rotina para manter as operações da tela CADCMT
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
	$cddopcao  = (isset($_POST["cddopcao"]))    ? $_POST["cddopcao"]    : ""; // Opção (CM-Consulta/IM-Incluir/AM-Alterar/EM-Excluir)
	$cdmotivo  = (isset($_POST["cdmotivocin"])) ? $_POST["cdmotivocin"] : ""; // Código do Motivo CIN
	$dsmotivo  = (isset($_POST["dsmotivocin"])) ? $_POST["dsmotivocin"] : ""; // Descrição do Motivo CIN

	//Validar permissão do usuário
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$cddopcao)) <> "") {
		exibirErro("error",$msgError,"Alerta - Ayllos","",false);
	}

	// Validar os campos e identificar as operações
	switch ($cddopcao) {
		case "CM":
			$procedure = "PARCYB_CONSULTAR_MOTIVOS_CIN";
		break;
		
		case "IM":
			$procedure = "PARCYB_MANTER_MOTIVOS_CIN";
			// Verifica se os parâmetros necessários foram informados
			if ($dsmotivo == "") exibirErro("error","Motivo CIN inv&aacute;lido.","Alerta - Ayllos","",false);
		break;
		
		case "AM":
			$procedure = "PARCYB_MANTER_MOTIVOS_CIN";
			// Verifica se os parâmetros necessários foram informados
			if (!validaInteiro($cdmotivo)) exibirErro("error","C&oacute;digo do motivo CIN inv&aacute;lido.","Alerta - Ayllos","",false);
			if ($dsmotivo == "") exibirErro("error","Motivo CIN inv&aacute;lido.","Alerta - Ayllos","",false);
		break;
		
		case "EM":
			$procedure = "PARCYB_MANTER_MOTIVOS_CIN";
			// Verifica se os parâmetros necessários foram informados
			if (!validaInteiro($cdmotivo)) exibirErro("error","C&oacute;digo do motivo CIN inv&aacute;lido.","Alerta - Ayllos","",false);
		break;
		
		default:
			// Se não for uma opção válida exibe o erro
			exibirErro("error","Op&ccedil;&atilde;o inv&aacute;lida.","Alerta - Ayllos","",false);
		break;
	}
	
	// Monta o xml
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	if($cddopcao == "CM"){
		// Para consulta é necessário apenas o código do motivo CIN, para que seja identificado apenas uma, sem o parametro deve listar todos
		$xml .= "		<cdmotivo>".$cdmotivo."</cdmotivo>";
	} else {
		// Opção e dados da motivos CIN necessários para Incluir, Alterar e Excluir o motivo CIN
		$xml .= "		<cddopcao>".$cddopcao."</cddopcao>";
		$xml .= "		<cdmotivo>".$cdmotivo."</cdmotivo>";
		$xml .= "		<dsmotivo>".$dsmotivo."</dsmotivo>";
	}
	$xml .= "  </Dados>";
	$xml .= "</Root>";

	// Executa script para envio do XML
	 $xmlResult = mensageria($xml, "PARCYB", $procedure, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");

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
	
	//Comando para ser excutado em caso de sucesso na operação
	$command = "";
	// Verificar se a opção é de consulta
	switch ($cddopcao) {
		case "CM" :
			// Se o código do motivo CIN veio preenchida é pq está sendo pesquisado na tela de alteração
			if($cdmotivo != ""){
				if ($xmlObjeto->roottag->tags[0]->name == "MOTIVOS") {
					$cdmotivoCin = getByTagName($xmlObjeto->roottag->tags[0]->tags[0]->tags,'cdmotivo');
					$dsmotivoCin = getByTagName($xmlObjeto->roottag->tags[0]->tags[0]->tags,'dsmotivo');
					// Verificar se foi encontrado o motivo CIN para o código informado
					if ($cdmotivoCin != "" && $dsmotivoCin != "") {
						//Se existir preenche na tela
						$command .= "$('#cdmotivocin').val('" . $cdmotivoCin . "');";
						$command .= "$('#dsmotivocin').val('" . $dsmotivoCin . "').focus();";
					} else {
						//Se não existir exibe o erro
						$command .= "showError('error','Motivo CIN n&atilde;o encontrado!','Alerta - Ayllos','$(\'#cdmotivocin\').val(\'\').focus();')";
					}
				}
			} else {
				// Se não possui codigo de motivo CIN lista todas os motivos CIN encontrados
				if ($xmlObjeto->roottag->tags[0]->name == "MOTIVOS") {
					foreach($xmlObjeto->roottag->tags[0]->tags as $motivo){
						$command .=  "criaLinhaMotivoCin('" . getByTagName($motivo->tags,'cdmotivo') . 
						                              "','" . getByTagName($motivo->tags,'dsmotivo') . "');";
					}
				}
				//Alternar a cor das linhas
				$command .=  "zebradoLinhaTabela($('#tbCadcmt > tbody > tr'));";
			}
		break;
		
		case "IM" :
			//Exibir confirmação da inclusão
			$command .= "showError('inform','Inclu&iacute;do com sucesso.','Alerta - Ayllos','estadoInicialMotivosCin();')";
		break;
		
		case "AM" :
			//Exibir confirmação da alteração
			$command .= "showError('inform','Alterado com sucesso.','Alerta - Ayllos','estadoInicialMotivosCin();')";
		break;
		
		case "EM" :
			//Exibir confirmação da exclusão
			$command .= "showError('inform','Exclu&iacute;do com sucesso.','Alerta - Ayllos','executaConsultaMotivosCin();');";
		break;
	}
	
	//Esconde a mensagem de aguardo do processo e executa o comando criado pelas opções
	echo "hideMsgAguardo();" . $command;
?>