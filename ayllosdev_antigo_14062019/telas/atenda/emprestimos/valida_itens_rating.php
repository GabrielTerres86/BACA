<? 
/*!
 * FONTE        : valida_itens_rating.php
 * CRIAÇÃO      : Gabriel Ramirez
 * DATA CRIAÇÃO : 03/09/2012 							Alterações: 14/10/2013
 * OBJETIVO     : Valida dados da rotina da analise da proposta 
 *				
 *				  14/10/2013 - Alterado a chamada da função buscaObs para atualizaArray (Adriano)
 *				  02/09/2014 - Projeto automatizacao de consultas (Jonata-RKAM)
 *                26/06/2015 - Validar Inf. Cadastrais quando possui consulta ao Conjuge (Gabriel-RKAM). 
 *				  25/04/2017 - Incluido tratamento para não validar o Rating quando inobriga for 'S'. Projeto 337 - Motor de crédito (Reinert)
 */
?>
 
<?

	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');	
	require_once('../../../class/xmlfile.php');
	isPostMethod();		

	
	// Guardo os parâmetos do POST em variáveis	
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : '';
	$nrgarope = (isset($_POST['nrgarope'])) ? $_POST['nrgarope'] : '';
	$nrinfcad = (isset($_POST['nrinfcad'])) ? $_POST['nrinfcad'] : '';
	$nrliquid = (isset($_POST['nrliquid'])) ? $_POST['nrliquid'] : '';
	$nrpatlvr = (isset($_POST['nrpatlvr'])) ? $_POST['nrpatlvr'] : '';
	$nrperger = (isset($_POST['nrperger'])) ? $_POST['nrperger'] : '';
	
	$inprodut = (isset($_POST['inprodut'])) ? $_POST['inprodut'] : '';
	$inpessoa = (isset($_POST['inpessoa'])) ? $_POST['inpessoa'] : '';
	$vlprodut = (isset($_POST['vlprodut'])) ? $_POST['vlprodut'] : '';
	$cdfinemp = (isset($_POST['cdfinemp'])) ? $_POST['cdfinemp'] : '';
	$cdlcremp = (isset($_POST['cdlcremp'])) ? $_POST['cdlcremp'] : '';
	$inobriga2 = "S";//(isset($_POST['inobriga'])) ? $_POST['inobriga'] : 'N';
		
	
	if ($inobriga2 == 'N'){

		// Monta o xml de requisição
		$xml  = "";
		$xml .= "<Root>";
		$xml .= "	<Cabecalho>";
		$xml .= "		<Bo>b1wgen0043.p</Bo>";
		$xml .= "		<Proc>valida-itens-rating</Proc>";
		$xml .= "	</Cabecalho>";
		$xml .= "	<Dados>";
		$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
		$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
		$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
		$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";	
		$xml .= "		<nrgarope>".$nrgarope."</nrgarope>";
		$xml .= "		<nrinfcad>".$nrinfcad."</nrinfcad>";
		$xml .= "		<nrliquid>".$nrliquid."</nrliquid>";
		$xml .= "		<nrpatlvr>".$nrpatlvr."</nrpatlvr>";
		$xml .= "		<nrperger>".$nrperger."</nrperger>";	
		$xml .= "		<idseqttl>1</idseqttl>";
		$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
		$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
		$xml .= "	</Dados>";
		$xml .= "</Root>";
				
		
		// Executa script para envio do XML
		$xmlResult = getDataXML($xml);
		
		// Cria objeto para classe de tratamento de XML
		$xmlObj = getObjectXML($xmlResult);
		
		
		if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
			exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo($(\'#divRotina\'))',false);
		}
	}
	
	if ($operacao == 'A_PROT_CRED') {
        if ($inobriga2 == 'N') {
            echo 'atualizaArray("A_PROTECAO_TIT", ' . $glbvars["cdcooper"] . ');';			
        } else {
            echo 'atualizaArray("A_BUSCA_OBS", ' . $glbvars["cdcooper"] . ');';
        }
	}
	else if ($operacao == 'A_PROTECAO_TIT') {
		echo 'atualizaArray("A_BUSCA_OBS", ' . $glbvars["cdcooper"] . ');';	
	}
	else if ($operacao == 'A_PROTECAO_TIT_CONJ') {
		echo 'arrayProtCred["nrinfcad"] = ' . $nrinfcad . ';';
		echo 'controlaOperacao("A_PROTECAO_CONJ");';
	}
	else if ($operacao == 'I_PROT_CRED'){
	
		$strnomacao = ' SSPC0001_OBRIGACAO_CNS_CPL';
		// Montar o xml para requisicao
		$xml  = "";
		$xml .= "<Root>";
		$xml .= " <Dados>";
		$xml .= "    <cdcooper>".$glbvars['cdcooper']."</cdcooper>";
		$xml .= "    <inprodut>".$inprodut."</inprodut>";
		$xml .= "    <inpessoa>".$inpessoa."</inpessoa>";
		$xml .= "    <vlprodut>".str_replace(",",".",str_replace(".","",$vlprodut))."</vlprodut>";
		$xml .= "    <cdfinemp>".$cdfinemp."</cdfinemp>";
		$xml .= "    <cdlcremp>".$cdlcremp."</cdlcremp>";		
		$xml .= " </Dados>";
		$xml .= "</Root>";
		
		$xmlResult = mensageria($xml, "SSPC0001" , $strnomacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["nmoperad"], "</Root>");	

		$xml_geral = simplexml_load_string($xmlResult);
		$inobriga = $xml_geral->inobriga;	
	
		if (($inobriga == 'N' || $inobriga == "C") && $inobriga2 == 'N') {
			echo 'atualizaArray("I_PROTECAO_TIT");';
		} else {
			echo 'arrayProtCred["nrinfcad"] = 1;';
			echo 'atualizaArray("I_BUSCA_OBS", ' . $glbvars["cdcooper"] . ');';

		}
	} 
	else if ($operacao == 'I_PROTECAO_TIT') {
		echo 'atualizaArray("I_BUSCA_OBS", ' . $glbvars["cdcooper"] . ');';
	}
				
?>