<?php
	/*!
	 * FONTE        : manter_rotina_assessoria.php
	 * CRIA��O      : Douglas Quisinski
	 * DATA CRIA��O : 25/08/2015
	 * OBJETIVO     : Rotina para manter as opera��es da tela de Assessorias
	 * --------------
	 * ALTERA��ES   : 19/09/2016 - Inclusao do campo de codigo de acessoria do CYBER, Prj. 302 (Jean Michel)
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
	$cddopcao      = (isset($_POST["cddopcao"]))      ? $_POST["cddopcao"]      : ""; // Op��o (CA-Consulta/IA-Incluir/AA-Alterar/EA-Excluir)
	$cdassessoria  = (isset($_POST["cdassessoria"]))  ? $_POST["cdassessoria"]  : ""; // C�digo da Assessoria
	$nmassessoria  = (isset($_POST["nmassessoria"]))  ? $_POST["nmassessoria"]  : ""; // Descri��o da Assessoria
	$cdasscyb      = (isset($_POST["cdasscyb"]))  ? $_POST["cdasscyb"]  : "";		  // C�digo da Assessoria CYBER

	//Validar permiss�o do usu�rio
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$cddopcao)) <> "") {
		exibirErro("error",$msgError,"Alerta - Ayllos","",false);
	}

	// Validar os campos e identificar as opera��es
	switch ($cddopcao) {
		case "CA":
			$procedure = "PARCYB_CONSULTAR_ASSESSORIAS";
		break;
		
		case "IA":
			$procedure = "PARCYB_MANTER_ASSESSORIAS";
			// Verifica se os par�metros necess�rios foram informados
			if ($nmassessoria == "") exibirErro("error","Nome da Assessoria inv&aacute;lido.","Alerta - Ayllos","",false);
		break;
		
		case "AA":
			$procedure = "PARCYB_MANTER_ASSESSORIAS";
			// Verifica se os par�metros necess�rios foram informados
			if (!validaInteiro($cdassessoria)) exibirErro("error","C&oacute;digo da Assessoria inv&aacute;lido.","Alerta - Ayllos","",false);
			if ($nmassessoria == "") exibirErro("error","Nome da Assessoria inv&aacute;lido.","Alerta - Ayllos","",false);
		break;
		
		case "EA":
			if($cdassessoria != ""){
				$procedure = "PARCYB_MANTER_ASSESSORIAS";
				// Verifica se os par�metros necess�rios foram informados
				if (!validaInteiro($cdassessoria)) exibirErro("error","C&oacute;digo da Assessoria inv&aacute;lido.","Alerta - Ayllos","",false);
			} else {
				$procedure = "PARCYB_CONSULTAR_ASSESSORIAS";
			}
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
	if($cddopcao == "CA"){
		// Para consulta � necess�rio apenas o c�digo da assessoria, para que seja identificado apenas uma, sem o parametro deve listar todas
		$xml .= "		<cdassess>".$cdassessoria."</cdassess>";
	} else {
		// Op��o e dados da assessoria necess�rios para Incluir, Alterar e Excluir a assessoria
		$xml .= "		<cddopcao>".$cddopcao."</cddopcao>";
		$xml .= "		<cdassess>".$cdassessoria."</cdassess>";
		$xml .= "		<dsassess>".$nmassessoria."</dsassess>";
		$xml .= "		<cdasscyb>".$cdasscyb."</cdasscyb>";
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
		case "CA" :
			// Se o c�digo da assessoria veio preenchida � pq est� sendo pesquisado na tela de altera��o
			if($cdassessoria != ""){
				if ($xmlObjeto->roottag->tags[0]->name == "ASSESSORIAS") {
					$cdassess = getByTagName($xmlObjeto->roottag->tags[0]->tags[0]->tags,'cdassessoria');
					$nmassess = getByTagName($xmlObjeto->roottag->tags[0]->tags[0]->tags,'nmassessoria');
					$cdasscyb = getByTagName($xmlObjeto->roottag->tags[0]->tags[0]->tags,'cdasscyb');
					// Verificar se foi encontrada a assessoria para o c�digo informado
					if ($cdassess != "" && $nmassess != "") {
						//Se existir preenche na tela
						$command .= "$('#cdassessoria').val('" . $cdassess . "');";
						$command .= "$('#cdasscyb').val('" . $cdasscyb . "').focus();";
						$command .= "$('#nmassessoria').val('" . $nmassess . "');";
					} else {
						//Se n�o existir exibe o erro
						$command .= "showError('error','Assessoria n&atilde;o encontrada!','Alerta - Ayllos','$(\'#cdassessoria\').val(\'\').focus();')";
					}
				}
			} else {
				// Se n�o possui codigo de assessoria lista todas as assessorias encontradas
				if ($xmlObjeto->roottag->tags[0]->name == "ASSESSORIAS") {
					foreach($xmlObjeto->roottag->tags[0]->tags as $assessoria){
						$command .=  "criaLinhaAssessoriaConsulta('" . getByTagName($assessoria->tags,'cdassessoria') . 
															   "','" . getByTagName($assessoria->tags,'nmassessoria') . 
						                                       "','" . getByTagName($assessoria->tags,'cdasscyb') . "');";
					}
				}
				//Alternar a cor das linhas
				$command .=  "zebradoLinhaTabela($('#tbCadcas > tbody > tr'));";
			}
		break;
		
		case "IA" :
			//Exibir confirma��o da inclus�o
			$command .= "showError('inform','Inclu&iacute;do com sucesso.','Alerta - Ayllos','estadoInicialAssessorias();')";
		break;
		
		case "AA" :
			//Exibir confirma��o da altera��o
			$command .= "showError('inform','Alterado com sucesso.','Alerta - Ayllos','estadoInicialAssessorias();')";
		break;
		
		case "EA" :
			if($cdassessoria != ""){
				//Exibir confirma��o da exclus�o
				$command .= "showError('inform','Exclu&iacute;do com sucesso.','Alerta - Ayllos','executaConsultaAssessoriasExclusao();');";
			} else {
				// Se n�o possui codigo de assessoria lista todas as assessorias encontradas
				if ($xmlObjeto->roottag->tags[0]->name == "ASSESSORIAS") {
					foreach($xmlObjeto->roottag->tags[0]->tags as $assessoria){
						$command .=  "criaLinhaAssessoria('" . getByTagName($assessoria->tags,'cdassessoria') . 
						                               "','" . getByTagName($assessoria->tags,'nmassessoria') .
													   "','" . getByTagName($assessoria->tags,'cdasscyb') . "');";
					}
				}
				//Alternar a cor das linhas
				$command .=  "zebradoLinhaTabela($('#tbCadcas > tbody > tr'));";
			}
		break;
	}
	
	//Esconde a mensagem de aguardo do processo e executa o comando criado pelas op��es
	echo "hideMsgAguardo();" . $command;
?>
