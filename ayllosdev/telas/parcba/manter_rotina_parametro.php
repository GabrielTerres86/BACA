<?php
	/*!
	 * FONTE        : manter_rotina_parametro.php
	 * CRIAÇÃO      : Alcemir Junior - Mout's
	 * DATA CRIAÇÃO : 21/09/2018
	 * OBJETIVO     : Rotina para manter as operações da tela PARCBA
	 * --------------
	 * ALTERAÇÕES   : RITM0011945 - Gabriel (Mouts) 15/04/2019 - Adicionado campo dtmvtolt
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
    $lscdhistor = (isset($_POST["lscdhistor"]))    ? $_POST["lscdhistor"]    : "";
    $lsindebcre = (isset($_POST["lsindebcre"]))    ? $_POST["lsindebcre"]    : "";
    $dtmvtolt   = (isset($_POST["dtmvtolt"]))      ? $_POST["dtmvtolt"]      : "";

	//Validar permissão do usuário
	//if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$cddopcao)) <> "") {
	//	exibirErro("error",$msgError,"Alerta - Aimaro","",false);
	//}

	// Validar os campos e identificar as operações
	switch ($cddopcao) {
		// consulta trancao bancoob
		case "C":
			$nmdeacao = "CONSULTA_TRANSACAO";
		break;
		//consulta historico ailos
		case "CH":
			$nmdeacao = "CONSULTA_HISTORICO";
		break;
 		//busca historico ailos
		case "BH":
			$nmdeacao = "CONSULTA_HISTORICO";
		break;
		// busca lista de historico ailos
		case "BLH":
			$nmdeacao = "CONSULTA_HISTORICO";
		break;
		// busca lista de historico ailos para a opcao exclusao
		case "BLHE":
			$nmdeacao = "CONSULTA_HISTORICO";
		break;

		case "BHT":
			$nmdeacao = "CONSULTA_HISTORICO";
		break;

		// busca transacao bancoob
        case "BT":
			$nmdeacao = "CONSULTA_TRANSACAO";
		break;
        //busca transacao bancoob para a opcao exclusao
        case "BTE":
			$nmdeacao = "CONSULTA_TRANSACAO";
		break;
 		// inclusao de paramerto
		case "I":
			$nmdeacao = "INSERE_PARAMETRO";
		break;
        //exclusao de parametro
		case "E":
			$nmdeacao = "DELETA_TRANSACAO";
		break;
        // exclusao de historico ailos
		case "EH":
			$nmdeacao = "DELETA_HISTORICO";			
		break;
		
		// Executar conciliacao
		case "G":
			$nmdeacao = "EXECUTA_CONCILIACAO";			
		break;
		
		//mesagem padrao 
		default:
			// Se não for uma opção válida exibe o erro
			exibirErro("error","Op&ccedil;&atilde;o inv&aacute;lida.","Alerta - Aimaro","",false);
		break;
	}

	// Monta o xml
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	
	if ($cddopcao == "C" || $cddopcao == "CH" || $cddopcao == "BH" || $cddopcao == "BT" ||
	    $cddopcao == "BLH" || $cddopcao == "BTE" || $cddopcao == "BLHE" || $cddopcao == "BHT" ) {
	   $xml .= "<cdtransa>".$cdtransa."</cdtransa>";
	   $xml .= "<cdhistor>".$cdhistor."</cdhistor>";
	}

	if ($cddopcao == "I"){
	   $xml .= "<cdtransa>".$cdtransa."</cdtransa>";
	   $xml .= "<dstransa>".$dstransa."</dstransa>";	
	   $xml .= "<cdhistor>".$cdhistor."</cdhistor>";
	   $xml .= "<indebcre_transa>".$indebcre_transa."</indebcre_transa>";
	   $xml .= "<indebcre_histor>".$indebcre_histor."</indebcre_histor>";
	   $xml .= "<lscdhistor>".$lscdhistor."</lscdhistor>";
       $xml .= "<lsindebcre>".$lsindebcre."</lsindebcre>";
	   
	}

    if ($cddopcao == "E"){
	   $xml .= "<cdtransa>".$cdtransa."</cdtransa>";	   
	}
	
	
	
	if ($cddopcao == "EH"){
	  
	   $xml .= "<cdhistor>".$cdhistor."</cdhistor>";	   
	   $xml .= "<cdtransa>".$cdtransa."</cdtransa>";	
       
	}
	
	if ($cddopcao == "G") {
	   $xml .= "<dtmvtolt>".$dtmvtolt."</dtmvtolt>";
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
		
		//consultar hitorico ailos
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
		case "BHT" :
			$flgconsulta = False;

			foreach($xmlObjeto->historico as $historico){
				$flgconsulta = True;

				$command .=  "setarDesHistoricoAilosTarifa('".$historico->dshistor.
				                                        "','".$historico->dscontabil.
														"','".$historico->nrctadeb_pf.
														"','".$historico->nrctacrd_pf.
														"','".$historico->nrctadeb_pj.
														"','".$historico->nrctacrd_pj."');";
			}

			if (!$flgconsulta){
         		$command .=  "setarDesHistoricoAilosTarifa('','','','','','');";
			}
		break;

		// buscar transacao bancoob		
		case "BT" :		    
		    $flgbusca = False;	 
		    $command .= "limpaTabelaHistorico();"; 
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

		// buscar transacao bancoob para opção exclusao
		case "BTE" :		    
		    $flgbusca = False;	 
		    $command .= "limpaTabelaHistorico();";
			foreach($xmlObjeto->transacao as $transacao){
				$flgbusca = True;
				$command .=  "setarDestransacaoBancoob('BTE','" . $transacao->cdtransa . 
				                                      "','" . $transacao->dstransa .
										              "','" . $transacao->indebcre ."');";

			}
			
			if (!$flgbusca){
				$command .=  "setarDestransacaoBancoob('BTE','','','C',);";
			}

			$command .= "formataTabExc();";

		break;

		// busca lista de historicos ailos	
		case "BLH":
			$command .= "limpaTabelaHistorico();";
		    foreach($xmlObjeto->historico as $historico){
			    $command .= "criaLinhaCadastroHistorico('BLH','" . $historico->cdhistor . 
				                                       "','" . $historico->dshistor .
										               "','" . $historico->indebcre ."');";
            }	

            $command .= "formataTabCad();";									        
		break;

		//busca lista de historicos ailos para a opcao exclusao
		case "BLHE":
			$command .= "limpaTabelaHistorico();";
		    foreach($xmlObjeto->historico as $historico){
			    $command .= "criaLinhaCadastroHistorico('BLHE','" . $historico->cdhistor . 
				                                       "','" . $historico->dshistor .
										               "','" . $historico->indebcre ."');";
            }	

            $command .= "formataTabExc();";									        
		break;

		case "E" :				   		   					
			$command .=  "finalizaExclusao();";			
		break;
		
		case "G" :				   		   					
			$command .=  "finalizaConciliacao();";			
		break;

	}
	
	//Esconde a mensagem de aguardo do processo e executa o comando criado pelas opções
	echo "hideMsgAguardo();" . $command;
?>