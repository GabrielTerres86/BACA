<?php
	/*!
	 * FONTE        : manter_rotina_motivo_cin.php
	 * CRIA��O      : Douglas Quisinski
	 * DATA CRIA��O : 26/08/2015
	 * OBJETIVO     : Rotina para manter as opera��es da tela CADCMT
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
	$cddopcao  = (isset($_POST["cddopcao"]))    ? $_POST["cddopcao"]    : ""; // Op��o (CM-Consulta/IM-Incluir/AM-Alterar/EM-Excluir)
	$cdmotivo  = (isset($_POST["cdmotivocin"])) ? $_POST["cdmotivocin"] : ""; // C�digo do Motivo CIN
	$dsmotivo  = (isset($_POST["dsmotivocin"])) ? $_POST["dsmotivocin"] : ""; // Descri��o do Motivo CIN

	//Validar permiss�o do usu�rio
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$cddopcao)) <> "") {
		exibirErro("error",$msgError,"Alerta - Ayllos","",false);
	}

	// Validar os campos e identificar as opera��es
	switch ($cddopcao) {
		case "CM":
			$procedure = "PARCYB_CONSULTAR_MOTIVOS_CIN";
		break;
		
		case "IM":
			$procedure = "PARCYB_MANTER_MOTIVOS_CIN";
			// Verifica se os par�metros necess�rios foram informados
			if ($dsmotivo == "") exibirErro("error","Motivo CIN inv&aacute;lido.","Alerta - Ayllos","",false);
		break;
		
		case "AM":
			$procedure = "PARCYB_MANTER_MOTIVOS_CIN";
			// Verifica se os par�metros necess�rios foram informados
			if (!validaInteiro($cdmotivo)) exibirErro("error","C&oacute;digo do motivo CIN inv&aacute;lido.","Alerta - Ayllos","",false);
			if ($dsmotivo == "") exibirErro("error","Motivo CIN inv&aacute;lido.","Alerta - Ayllos","",false);
		break;
		
		case "EM":
			$procedure = "PARCYB_MANTER_MOTIVOS_CIN";
			// Verifica se os par�metros necess�rios foram informados
			if (!validaInteiro($cdmotivo)) exibirErro("error","C&oacute;digo do motivo CIN inv&aacute;lido.","Alerta - Ayllos","",false);
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
	if($cddopcao == "CM"){
		// Para consulta � necess�rio apenas o c�digo do motivo CIN, para que seja identificado apenas uma, sem o parametro deve listar todos
		$xml .= "		<cdmotivo>".$cdmotivo."</cdmotivo>";
	} else {
		// Op��o e dados da motivos CIN necess�rios para Incluir, Alterar e Excluir o motivo CIN
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
	
	// Se ocorrer um erro, mostra cr�tica
 	if ($xmlObjeto->roottag->tags[0]->name == "ERRO") {
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		exibirErro("error",$msgErro,"Alerta - Ayllos","",false);
	}
	
	//Comando para ser excutado em caso de sucesso na opera��o
	$command = "";
	// Verificar se a op��o � de consulta
	switch ($cddopcao) {
		case "CM" :
			// Se o c�digo do motivo CIN veio preenchida � pq est� sendo pesquisado na tela de altera��o
			if($cdmotivo != ""){
				if ($xmlObjeto->roottag->tags[0]->name == "MOTIVOS") {
					$cdmotivoCin = getByTagName($xmlObjeto->roottag->tags[0]->tags[0]->tags,'cdmotivo');
					$dsmotivoCin = getByTagName($xmlObjeto->roottag->tags[0]->tags[0]->tags,'dsmotivo');
					// Verificar se foi encontrado o motivo CIN para o c�digo informado
					if ($cdmotivoCin != "" && $dsmotivoCin != "") {
						//Se existir preenche na tela
						$command .= "$('#cdmotivocin').val('" . $cdmotivoCin . "');";
						$command .= "$('#dsmotivocin').val('" . $dsmotivoCin . "').focus();";
					} else {
						//Se n�o existir exibe o erro
						$command .= "showError('error','Motivo CIN n&atilde;o encontrado!','Alerta - Ayllos','$(\'#cdmotivocin\').val(\'\').focus();')";
					}
				}
			} else {
				// Se n�o possui codigo de motivo CIN lista todas os motivos CIN encontrados
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
			//Exibir confirma��o da inclus�o
			$command .= "showError('inform','Inclu&iacute;do com sucesso.','Alerta - Ayllos','estadoInicialMotivosCin();')";
		break;
		
		case "AM" :
			//Exibir confirma��o da altera��o
			$command .= "showError('inform','Alterado com sucesso.','Alerta - Ayllos','estadoInicialMotivosCin();')";
		break;
		
		case "EM" :
			//Exibir confirma��o da exclus�o
			$command .= "showError('inform','Exclu&iacute;do com sucesso.','Alerta - Ayllos','executaConsultaMotivosCin();');";
		break;
	}
	
	//Esconde a mensagem de aguardo do processo e executa o comando criado pelas op��es
	echo "hideMsgAguardo();" . $command;
?>