<? 
/*!
 * FONTE        : valida_valor_adesao_produto.php
 * CRIAÇÃO      : Lombardi
 * DATA CRIAÇÃO : 12/04/2018
 * OBJETIVO     : Verificar se o valor contratado para o produto 31 - Emprestimo é permitido pelo tipo de conta.
 */

	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');	
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();
	
	$nrdconta = 		(isset($_POST['nrdconta'])) 		? $_POST['nrdconta'] 	 	: 0;
	$cdfinemp = 		(isset($_POST['cdfinemp'])) 		? $_POST['cdfinemp'] 	 	: 0;
	$vlemprst = 		(isset($_POST['vlemprst'])) 		? $_POST['vlemprst'] 	 	: 0;
	$dsctrliq = 		(isset($_POST['dsctrliq'])) 		? $_POST['dsctrliq'] 	 	: '';
	$operacao =  		(isset($_POST['operacao']))  		? $_POST['operacao'] 		: '';
	$cdcooper =  		(isset($_POST['cdcooper']))  		? $_POST['cdcooper'] 		: '';
	$idquapro =  		(isset($_POST['idquapro']))  		? $_POST['idquapro'] 		: 0;
	$vlemprst_antigo =  (isset($_POST['vlemprst_antigo']))  ? $_POST['vlemprst_antigo'] : 0;
	$dsctrliq_antigo =  (isset($_POST['dsctrliq_antigo']))  ? $_POST['dsctrliq_antigo'] : '';
	$dsauxliq = '';
	
	$executar = "showMsgAguardo(\"Aguarde, validando dados ...\");";
	$executar = "setTimeout(\"attArray(\\\"".$operacao."\\\",\\\"".$cdcooper."\\\")\", 400);";

	/* Buscamos a modalidade do cooperado */
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Dados>";
	$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	$xmlModalidadeResult = mensageria($xml, "CADA0006", "BUSCA_MODALIDADE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlModalidadeObject = getObjectXML($xmlModalidadeResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlModalidadeObject->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlModalidadeObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
	}	
	$modalidade = $xmlModalidadeObject->roottag->tags[0]->cdata;
	$flgConsignadoSalario = ($modalidade == 2 && $cdfinemp == 57);
	
	/* Desconsidera CDC e consignado para conta salário */
	if ($cdfinemp <> 0 && $cdfinemp <> 58 && $cdfinemp <> 59 && $idquapro <> 2 && $idquapro <> 4 && !$flgConsignadoSalario) {
		
		// Monta o xml de requisição
		$xml  = "";
		$xml .= "<Root>";
		$xml .= "	<Dados>";
		$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "		<cdprodut>".    31   ."</cdprodut>";
		$xml .= "	</Dados>";
		$xml .= "</Root>";
		
		// Executa script para envio do XML
		$xmlResult = mensageria($xml, "CADA0006", "VALIDA_ADESAO_PRODUTO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObject = getObjectXML($xmlResult);
		
		// Se ocorrer um erro, mostra crítica
		if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO") {
			$msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
			exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
		}
		
		$vlemprst = str_replace(',','.',str_replace('.','',$vlemprst));
		$vlemprst_antigo = str_replace(',','.',str_replace('.','',$vlemprst_antigo));
		$dsctrliq = str_replace('.','',$dsctrliq);
		$dsctrliq_antigo = str_replace('.','',$dsctrliq_antigo);
		
		// Verificar se está sendo enviado a string "Sem liquidacoes"  
		if (strcasecmp($dsctrliq, 'Sem liquidacoes') == 0) {
			$dsauxliq = '';
		} else {
			$dsauxliq = $dsctrliq;
		}

		// Verificar se está sendo enviado a string "Sem liquidacoes"  
		if (strcasecmp($dsctrliq_antigo, 'Sem liquidacoes') == 0) {
			$dsctrliq_antigo = '';
		} else {
			$dsctrliq_antigo = $dsctrliq_antigo;
		}

		// Monta o xml de requisição
		$xml  = "";
		$xml .= "<Root>";
		$xml .= "	<Dados>";
		$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "		<vlcontra>".$vlemprst."</vlcontra>";
		$xml .= "		<dsctrliq>".$dsauxliq."</dsctrliq>";
		$xml .= "	</Dados>";
		$xml .= "</Root>";
		
		// Executa script para envio do XML
		$xmlResult = mensageria($xml, "CADA0006", "VALIDA_VALOR_ADESAO_EMP", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObject = getObjectXML($xmlResult);
		
		// Se ocorrer um erro, mostra crítica
		if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO") {
			$msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
			exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
		}
		
		$solcoord = $xmlObject->roottag->tags[0]->cdata;
		$mensagem = $xmlObject->roottag->tags[1]->cdata;
		
		// Se ocorrer um erro, mostra crítica
		if ($solcoord == 1 && ((float) $vlemprst != (float) $vlemprst_antigo || $dsauxliq != $dsctrliq_antigo)) {
			//Guarda valores para futura consulta
			$executar .= "vlemprst_antigo = ".$vlemprst.";dsctrliq_antigo = \"".$dsauxliq."\";";
			//Necessario para usar a funcao senhaCoordenador
			$executar = str_replace("\"","\\\"", str_replace("\\", "\\\\", $executar));
			$executar = str_replace("\"","\\\"", str_replace("\\", "\\\\", $executar));
			$executar = str_replace("\"","\\\"", str_replace("\\", "\\\\", $executar));
			
			exibirErro("error",$mensagem,"Alerta - Ayllos", "senhaCoordenador(\\\"".$executar."\\\");",false);
		} else {
			echo $executar;
		}
	} else {
		echo $executar;
	}
?>