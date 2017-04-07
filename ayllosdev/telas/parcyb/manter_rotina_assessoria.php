<?php
	/*!
	 * FONTE        : manter_rotina_assessoria.php
	 * CRIAÇÃO      : Douglas Quisinski
	 * DATA CRIAÇÃO : 25/08/2015
	 * OBJETIVO     : Rotina para manter as operações da tela de Assessorias
	 * --------------
	 * ALTERAÇÕES   : 19/09/2016 - Inclusao do campo de codigo de acessoria do CYBER, Prj. 302 (Jean Michel)
   *
   *                17/01/2017 - Inclusao campos flgjudic e flextjud, Prj. 432 (Jean Calão / Mout´S)
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
	$cddopcao      = (isset($_POST["cddopcao"]))      ? $_POST["cddopcao"]      : ""; // Opção (CA-Consulta/IA-Incluir/AA-Alterar/EA-Excluir)
	$cdassessoria  = (isset($_POST["cdassessoria"]))  ? $_POST["cdassessoria"]  : ""; // Código da Assessoria
	$nmassessoria  = (isset($_POST["nmassessoria"]))  ? $_POST["nmassessoria"]  : ""; // Descrição da Assessoria
	$cdasscyb      = (isset($_POST["cdasscyb"]))  ? $_POST["cdasscyb"]  : "";		  // Código da Assessoria CYBER
    $flgjudic      = (isset($_POST["flgjudic"]))  ? $_POST["flgjudic"]  : "";		  // flag de cobrança judicial
    $flextjud      = (isset($_POST["flextjud"]))  ? $_POST["flextjud"]  : "";		  // flag de cobrança extra judicial
	$cdsigcyb      = (isset($_POST["cdsigcyb"]))  ? $_POST["cdsigcyb"]  : "";		  // flag de cobrança extra judicial

	//Validar permissão do usuário
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$cddopcao)) <> "") {
		exibirErro("error",$msgError,"Alerta - Ayllos","",false);
	}

	// Validar os campos e identificar as operações
	switch ($cddopcao) {
		case "CA":
			$procedure = "PARCYB_CONSULTAR_ASSESSORIAS";
		break;
		
		case "IA":
			$procedure = "PARCYB_MANTER_ASSESSORIAS";
			// Verifica se os parâmetros necessários foram informados
			if ($nmassessoria == "") exibirErro("error","Nome da Assessoria inv&aacute;lido.","Alerta - Ayllos","",false);
		break;
		
		case "AA":
			$procedure = "PARCYB_MANTER_ASSESSORIAS";
			// Verifica se os parâmetros necessários foram informados
			if (!validaInteiro($cdassessoria)) exibirErro("error","C&oacute;digo da Assessoria inv&aacute;lido.","Alerta - Ayllos","",false);
			if ($nmassessoria == "") exibirErro("error","Nome da Assessoria inv&aacute;lido.","Alerta - Ayllos","",false);
		break;
		
		case "EA":
			if($cdassessoria != ""){
				$procedure = "PARCYB_MANTER_ASSESSORIAS";
				// Verifica se os parâmetros necessários foram informados
				if (!validaInteiro($cdassessoria)) exibirErro("error","C&oacute;digo da Assessoria inv&aacute;lido.","Alerta - Ayllos","",false);
			} else {
				$procedure = "PARCYB_CONSULTAR_ASSESSORIAS";
			}
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
	if($cddopcao == "CA"){
		// Para consulta é necessário apenas o código da assessoria, para que seja identificado apenas uma, sem o parametro deve listar todas
		$xml .= "		<cdassess>".$cdassessoria."</cdassess>";
	} else {
		// Opção e dados da assessoria necessários para Incluir, Alterar e Excluir a assessoria
		$xml .= "		<cddopcao>".$cddopcao."</cddopcao>";
		$xml .= "		<cdassess>".$cdassessoria."</cdassess>";
		$xml .= "		<dsassess>".$nmassessoria."</dsassess>";
		$xml .= "		<cdasscyb>".$cdasscyb."</cdasscyb>";
    $xml .= "		<flgjudic>".$flgjudic."</flgjudic>";
    $xml .= "		<flextjud>".$flextjud."</flextjud>";
		$xml .= "		<cdsigcyb>".$cdsigcyb."</cdsigcyb>";
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
		case "CA" :
			// Se o código da assessoria veio preenchida é pq está sendo pesquisado na tela de alteração
			if($cdassessoria != ""){
				if ($xmlObjeto->roottag->tags[0]->name == "ASSESSORIAS") {
					$cdassess = getByTagName($xmlObjeto->roottag->tags[0]->tags[0]->tags,'cdassessoria');
					$nmassess = getByTagName($xmlObjeto->roottag->tags[0]->tags[0]->tags,'nmassessoria');
					$cdasscyb = getByTagName($xmlObjeto->roottag->tags[0]->tags[0]->tags,'cdasscyb');
					$flgjudic = getByTagName($xmlObjeto->roottag->tags[0]->tags[0]->tags,'flgjudic');
					$flextjud = getByTagName($xmlObjeto->roottag->tags[0]->tags[0]->tags,'flextjud');
					$cdsigcyb = getByTagName($xmlObjeto->roottag->tags[0]->tags[0]->tags,'cdsigcyb');
					// Verificar se foi encontrada a assessoria para o código informado
					if ($cdassess != "" && $nmassess != "") {
						//Se existir preenche na tela
						$command .= "$('#cdassessoria').val('" . $cdassess . "');";
						$command .= "$('#cdasscyb').val('" . $cdasscyb . "').focus();";
						$command .= "$('#nmassessoria').val('" . $nmassess . "');";
					  $command .= "$('#flgjudic').val('" . $flgjudic . "');";
            $command .= "$('#flextjud').val('" . $flextjud . "');";						
						$command .= "$('#cdsigcyb').val('" . $cdsigcyb . "');";		
						if ($flgjudic == 1) {
							$command .= "$('#flgjudic').attr('checked','checked');";							
						} else {
							$command .= "$('#flgjudic').removeAttr('checked','checked');";
						}
						if ($flextjud == 1) {
							$command .= "$('#flextjud').attr('checked','checked');";
						} else {
							$command .= "$('#flextjud').removeAttr('checked','checked');";
						}
					} else {
						//Se não existir exibe o erro
						$command .= "showError('error','Assessoria n&atilde;o encontrada!','Alerta - Ayllos','$(\'#cdassessoria\').val(\'\').focus();')";
					}
				}
			} else {
				// Se não possui codigo de assessoria lista todas as assessorias encontradas
				if ($xmlObjeto->roottag->tags[0]->name == "ASSESSORIAS") {
					foreach($xmlObjeto->roottag->tags[0]->tags as $assessoria){
						$command .=  "criaLinhaAssessoriaConsulta('" . getByTagName($assessoria->tags,'cdassessoria') . 
															   "','" . getByTagName($assessoria->tags,'nmassessoria') . 
						                                       "','" . getByTagName($assessoria->tags,'cdasscyb') .
                                                               "','" . getByTagName($assessoria->tags,'flgjudic') .
                                                               "','" . getByTagName($assessoria->tags,'flextjud') .
                                                               "','" . getByTagName($assessoria->tags,'cdsigcyb') .	"');";
					}
				}
				//Alternar a cor das linhas
				$command .=  "zebradoLinhaTabela($('#tbCadcas > tbody > tr'));";
			}
		break;
		
		case "IA" :
			//Exibir confirmação da inclusão			
			$command .= "showError('inform','Inclu&iacute;do com sucesso.','Alerta - Ayllos','estadoInicialAssessorias();')";
		break;
		
		case "AA" :
			//Exibir confirmação da alteração
			$command .= "showError('inform','Alterado com sucesso.','Alerta - Ayllos','estadoInicialAssessorias();')";
		break;
		
		case "EA" :
			if($cdassessoria != ""){
				//Exibir confirmação da exclusão
				$command .= "showError('inform','Exclu&iacute;do com sucesso.','Alerta - Ayllos','executaConsultaAssessoriasExclusao();');";
			} else {
				// Se não possui codigo de assessoria lista todas as assessorias encontradas
				if ($xmlObjeto->roottag->tags[0]->name == "ASSESSORIAS") {
					foreach($xmlObjeto->roottag->tags[0]->tags as $assessoria){
						$command .=  "criaLinhaAssessoria('" . getByTagName($assessoria->tags,'cdassessoria') . 
						                               "','" . getByTagName($assessoria->tags,'nmassessoria') .
													   "','" . getByTagName($assessoria->tags,'cdasscyb') . 
                                                       "','" . getByTagName($assessoria->tags,'flgjudic') . 
													   "','" . getByTagName($assessoria->tags,'flextjud') .
													   "','" . getByTagName($assessoria->tags,'cdsigcyb') . "');";
					}
				}
				//Alternar a cor das linhas
				$command .=  "zebradoLinhaTabela($('#tbCadcas > tbody > tr'));";
			}
		break;
	}
	
	//Esconde a mensagem de aguardo do processo e executa o comando criado pelas opções
	echo "hideMsgAguardo();" . $command;
?>
