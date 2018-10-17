<?php
	/*!
	 * FONTE        : manter_rotina_parametro.php
	 * CRIAÇÃO      : Alcemir Junior - Mout's
	 * DATA CRIAÇÃO : 21/09/2018
	 * OBJETIVO     : Rotina para manter as operações da tela PARCBA
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
	$cddopcao     = (isset($_POST["cddopcao"]))    ? $_POST["cddopcao"]    : ""; // Opção (C-Consulta/I-Inclusão/E-Exclusão)
	$cdtransa  = (isset($_POST["cdtransa"])) ? $_POST["cdtransa"] : ""; // Código da transacao
	$cdhistor  = (isset($_POST["cdhistor"])) ? $_POST["cdhistor"] : ""; // Código da transacao
	$dstransa  = (isset($_POST["dstransa"])) ? $_POST["dstransa"] : "";
    $indebcre_transa  = (isset($_POST["indebcre_transa"])) ? $_POST["indebcre_transa"] : "";
    $indebcre_histor  = (isset($_POST["indebcre_histor"])) ? $_POST["indebcre_histor"] : "";


	//Validar permissão do usuário
	//if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$cddopcao)) <> "") {
	//	exibirErro("error",$msgError,"Alerta - Aimaro","",false);
	//}

	// Validar os campos e identificar as operações
	switch ($cddopcao) {
		
		case "C":
			$nmdeacao = "CONSULTA_TRANSACAO";
		break;
		
		case "CH":
			$nmdeacao = "CONSULTA_HISTORICO";
		break;

		case "BH":
			$nmdeacao = "CONSULTA_HISTORICO";
		break;
		
		case "BLH":
			$nmdeacao = "CONSULTA_HISTORICO";
		break;

        case "BT":
			$nmdeacao = "CONSULTA_TRANSACAO";
		break;
        
        case "BTE":
			$nmdeacao = "CONSULTA_TRANSACAO";
		break;

		case "I":
			$nmdeacao = "INSERE_PARAMETRO";
		break;
        
		case "E":
			$nmdeacao = "DELETA_TRANSACAO";
		break;

		case "EH":
			$nmdeacao = "DELETA_HISTORICO";			
		break;
		
		default:
			// Se não for uma opção válida exibe o erro
			exibirErro("error","Op&ccedil;&atilde;o inv&aacute;lida.","Alerta - Aimaro","",false);
		break;
	}

	// Monta o xml
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " incluirTransacaoBancoob <Dados>";
	
	if ($cddopcao == "C" || $cddopcao == "CH" || $cddopcao == "BH" || $cddopcao == "BT" ||
	    $cddopcao == "BLH" || $cddopcao == "BTE" ) {
	   $xml .= "<cdtransa>".$cdtransa."</cdtransa>";
	   $xml .= "<cdhistor>".$cdhistor."</cdhistor>";
	}

	if ($cddopcao == "I"){
	   $xml .= "<cdtransa>".$cdtransa."</cdtransa>";
	   $xml .= "<dstransa>".$dstransa."</dstransa>";	
	   $xml .= "<cdhistor>".$cdhistor."</cdhistor>";
	   $xml .= "<indebcre_transa>".$indebcre_transa."</indebcre_transa>";
	   $xml .= "<indebcre_histor>".$indebcre_histor."</indebcre_histor>";
	}

    if ($cddopcao == "E"){
	   $xml .= "<cdtransa>".$cdtransa."</cdtransa>";	   
	}
	
	
	
	if ($cddopcao == "EH"){
	  
	   $xml .= "<cdhistor>".$cdhistor."</cdhistor>";	   
	   $xml .= "<cdtransa>".$cdtransa."</cdtransa>";	
       
	}

	
	$xml .= "  </Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "PARCBA", $nmdeacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"],  "</Root>");

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
	switch ($cddopcao) {
		case "C" :
		    $command .= "limpaTabelaTransacao();";	
		    $flgconsulta = False;	    
			foreach($xmlObjeto->transacao as $transacao){
				$flgconsulta = True;
				$command .=  "criaLinhaTransacao('" . $transacao->cdtransa . 
				                                "','" . $transacao->dstransa .
										        "','" . $transacao->indebcre ."');";
			}

         	if (!$flgconsulta){
         		$command .=  "criaLinhaTransacao('','','');";
			}
			
			$command .= "formataTabCon();formataTabCad();";

		break;
		
		case "CH" :
			$command .= "limpaTabelaHistorico();";
			
			foreach($xmlObjeto->historico as $historico){				
				$command .=  "criaLinhaHistorico('" . $historico->cdhistor . 
				                                "','" . $historico->dshistor .
										        "','" . $historico->indebcre ."');";
			}
			
			$command .= "formataTabHis();formataTabCad();";
			
		break;

        // buscar descrição historico ailos
		case "BH" :
		    
			foreach($xmlObjeto->historico as $historico){
               
				$command .=  "setarDesHistoricoAilos('".$historico->dshistor."');";
			}

		break;

		// buscar descrição historico ailos
		case "BT" :		    
		    $flgbusca = False;	 
			foreach($xmlObjeto->transacao as $transacao){
				$flgbusca = True;
				$command .=  "setarDestransacaoBancoob('BT','" . $transacao->cdtransa . 
				                                      "','" . $transacao->dstransa .
										              "','" . $transacao->indebcre ."');";

			}
			
			if (!$flgbusca){
				$command .=  "setarDestransacaoBancoob('BT','','','C');";
			}


		break;

				// buscar descrição historico ailos
		case "BTE" :		    
		    $flgbusca = False;	 
			foreach($xmlObjeto->transacao as $transacao){
				$flgbusca = True;
				$command .=  "setarDestransacaoBancoob('BTE','" . $transacao->cdtransa . 
				                                      "','" . $transacao->dstransa .
										              "','" . $transacao->indebcre ."');";

			}
			
			if (!$flgbusca){
				$command .=  "setarDestransacaoBancoob('BTE','','','C');";
			}

		break;


		case "BLH":
		    foreach($xmlObjeto->historico as $historico){
			    $command .= "criaLinhaCadastroHistorico('" . $historico->cdhistor . 
				                                       "','" . $historico->dshistor .
										               "','" . $historico->indebcre ."');";
            }	

            $command .= "formataTabCad();formataTabExc();";									        
		break;

		case "E" :				   		   					
			$command .=  "finalizaExclusao('".$msgErro."');";			
		break;

	}
	
	//Esconde a mensagem de aguardo do processo e executa o comando criado pelas opções
	echo "hideMsgAguardo();" . $command;
?>