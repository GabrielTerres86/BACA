<?php
	/*!
	 * FONTE        : manter_rotina_parametrizar_historico.php
	 * CRIAÇÃO      : Douglas Quisinski
	 * DATA CRIAÇÃO : 10/09/2015
	 * OBJETIVO     : Rotina para manter as operações da tela de parametrização de histórico
	 * --------------
	 * ALTERAÇÕES   : 13/01/2016 - Inclusão da coluna Código de Transação CYBER - PRJ 432 - Jean Calão
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
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : ""; // Opção (CH-Consulta/AH-Alterar)
	$pesquisa = (isset($_POST["pesquisa"])) ? $_POST["pesquisa"] : ""; // Pesquisa (C-Codigo/D-Descricao/F-Filtro/T-Todos)
	$cdfiltro = (isset($_POST["cdfiltro"])) ? $_POST["cdfiltro"] :  0; // Código do filtro
	$cdhistor = (isset($_POST["cdhistor"])) ? $_POST["cdhistor"] : ""; // Código do Histórico
	$dshistor = (isset($_POST["dshistor"])) ? $_POST["dshistor"] : ""; // Descrição do Histórico
	$historicos = (isset($_POST["historicos"])) ? $_POST["historicos"] : ""; // Históricos para alterar

	//Validar permissão do usuário
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$cddopcao)) <> "") {
		exibirErro("error",$msgError,"Alerta - Ayllos","",false);
	}

	// Validar os campos e identificar as operações
	switch ($cddopcao) {
		case "CH":
			$procedure = "PARCYB_CONSULTAR_PARAM_HISTOR";
			
			switch ($pesquisa) {
				case "C": // Pesquisar por código
					// Verifica se os parâmetros necessários foram informados
					if (!validaInteiro($cdhistor)) exibirErro("error","Filtro inv&aacute;lido.","Alerta - Ayllos","",false);
				break;
				
				case "F": // Pesquisar por filtro
					// Verifica se os parâmetros necessários foram informados
					if (!validaInteiro($cdfiltro) || ($cdfiltro != 1 && $cdfiltro != 2 && $cdfiltro != 3))
						exibirErro("error","Filtro inv&aacute;lido.","Alerta - Ayllos","",false);
				break;
				case "D": // Pesquisar por descrição
				case "T": // Pesquisar Todos
					// Não existem validações para essas pesquisas
				break;
			}
			
			// Monta o xml para a opção de consulta dos dados
			$xml  = "";
			$xml .= "<Root>";
			$xml .= "  <Dados>";
			$xml .= "    <cddopcao>".$pesquisa."</cddopcao>";
			$xml .= "	 <cdfiltro>".$cdfiltro."</cdfiltro>";
			$xml .= "	 <cdhistor>".$cdhistor."</cdhistor>";
			$xml .= "	 <dshistor>".$dshistor."</dshistor>";
			$xml .= "  </Dados>";
			$xml .= "</Root>";
			
		break;
		
		case "AH":
			$procedure = "PARCYB_MANTER_PARAM_HISTOR";
			// Verifica se os parâmetros necessários foram informados
			if ($historicos == "") exibirErro("error","Nenhum historico foi alterado.","Alerta - Ayllos","",false);
		
			// Monta o xml para a opção de consulta dos dados
			$xml  = "";
			$xml .= "<Root>";
			$xml .= "  <Dados>";
			$xml .= "    <cddopcao>".$cddopcao."</cddopcao>";
			$xml .= "	 <dshistor>".$historicos."</dshistor>";
			$xml .= "  </Dados>";
			$xml .= "</Root>";
		break;
		
		default:
			// Se não for uma opção válida exibe o erro
			exibirErro("error","Op&ccedil;&atilde;o inv&aacute;lida.","Alerta - Ayllos","",false);
		break;
	}
	
	// Executa script para envio do XML
    $xmlResult = mensageria($xml, "PARCYB", $procedure, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");

	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra crítica
 	if ($xmlObjeto->roottag->tags[0]->name == "ERRO") {
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[5]->cdata;
		}
		exibirErro("error",$msgErro,"Alerta - Ayllos","",false);
	}
	
	//Comando para ser excutado em caso de sucesso na operação
	$command = "";
	switch ($cddopcao) {
		case "CH":
			if ($xmlObjeto->roottag->tags[0]->name == "PARAMETRIZAR_HISTORICOS") {
				foreach($xmlObjeto->roottag->tags[0]->tags as $parametro){
					$command .=  "criaLinhaParametrizarHistorico('" . getByTagName($parametro->tags,"cdhistor") . 
															  "','" . getByTagName($parametro->tags,"dshistor") . 
															  "','" . getByTagName($parametro->tags,"indebcre") . 
															  "','" . getByTagName($parametro->tags,"indcalem") . 
															  "','" . getByTagName($parametro->tags,"indcalcc") . 
															  "','" . getByTagName($parametro->tags,"cdtrscyb") ."');";
				}
			}

			//Alternar a cor das linhas
			$command .= "zebradoLinhaTabela($('#tbParhis > tbody > tr'));";
		break;
		
		case "AH":
			$command .= "showError('inform','Parametriza&ccedil;&atilde;o alterada com sucesso.','Alerta - Ayllos','estadoInicialParametrizarHistorico();')";
		break;
	}
	//Esconde a mensagem de aguardo do processo e executa o comando criado pelas opções
	echo "hideMsgAguardo();" . $command;	
?>
