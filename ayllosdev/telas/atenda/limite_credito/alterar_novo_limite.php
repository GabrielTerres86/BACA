<?php 

	/************************************************************************
	 Fonte: alterar_novo_limite.php                                   
	 Autor: Tiago                                                     
	 Data : Janeiro/2015                 Última Alteração: 05/12/2017
	                                                                  
	 Objetivo  : Alterar Novo Limite de Crédito - rotina de Limite    
	             de Crédito da tela ATENDA                            
	                                                                  
	 Alterações: 13/02/2015 - Retirado Validação do campo valor total sfn (Lucas R./Gielow)
	     																  
	    		 23/02/2015 - Adicionado a validação do campo sfn    
	        				  e corrigido o erro onde fazia com que  
	     				      validações criticassem indevidamente   
         					  (Kelvin)	

				 13/04/2015	- Consultas automatizadas (Gabriel-RKAM)

				 08/07/2015 - Remoção de acentuação do campo de observação
							  (Lunelli - SD SD 300819 | 300893)
	             
				 20/07/2015 - Ajuste no tratamento de caracteres (Kelvin)
	             17/06/2016 - M181 - Alterar o CDAGENCI para          
                             passar o CDPACTRA (Rafael Maciel - RKAM) 
	
                 05/12/2017 - Insersão do campo idcobope. Projeto 404 (Lombardi) 
	
                 21/03/2019 - Remover Etapa Rating Projeto 450 (Luiz Otávio Olinger Momm - AMCOM)
	
	************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();

	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");

	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"N")) <> "") {
		exibeErro($msgError);
	}

	$xml = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "   <cdacesso>HABILITA_RATING_NOVO</cdacesso>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "TELA_PARRAT", "CONSULTA_PARAM_CRAPPRM", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjPRM = getObjectXML($xmlResult);

	$habrat = 'N';
	if (strtoupper($xmlObjPRM->roottag->tags[0]->name) == "ERRO") {
		$habrat = 'N';
	} else {
		$habrat = $xmlObjPRM->roottag->tags[0]->tags;
		$habrat = getByTagName($habrat[0]->tags, 'PR_DSVLRPRM');
	}

	// Verifica se os parâmetros necessários foram informados
	if ($glbvars["cdcooper"] == 3 || $habrat == 'N') {
		$params = array("nrdconta","nrctrlim","cddlinha","vllimite","flgimpnp","vlsalari","vlsalcon","vloutras","vlalugue","dsobserv",
						"nrgarope","nrinfcad","nrliquid","nrpatlvr","nrperger","perfatcl","nrctaav1","nmdaval1","nrcpfav1","tpdocav1",
						"dsdocav1","nmdcjav1","cpfcjav1","tdccjav1","doccjav1","ende1av1","ende2av1","nrcepav1","nmcidav1","cdufava1",
						"nrfonav1","emailav1","vlrenme1","nrctaav2","nmdaval2","nrcpfav2","tpdocav2","dsdocav2","nmdcjav2","cpfcjav2",
						"tdccjav2","doccjav2","ende1av2","ende2av2","nrcepav2","nmcidav2","cdufava2","nrfonav2","emailav2","vlrenme2",
						"idcobope");
	} else {
		$params = array("nrdconta","nrctrlim","cddlinha","vllimite","flgimpnp","vlsalari","vlsalcon","vloutras","vlalugue","dsobserv",
						"perfatcl","nrctaav1","nmdaval1","nrcpfav1","tpdocav1",
						"dsdocav1","nmdcjav1","cpfcjav1","tdccjav1","doccjav1","ende1av1","ende2av1","nrcepav1","nmcidav1","cdufava1",
						"nrfonav1","emailav1","vlrenme1","nrctaav2","nmdaval2","nrcpfav2","tpdocav2","dsdocav2","nmdcjav2","cpfcjav2",
						"tdccjav2","doccjav2","ende1av2","ende2av2","nrcepav2","nmcidav2","cdufava2","nrfonav2","emailav2","vlrenme2",
						"idcobope");
	}

	foreach ($params as $nomeParam) {
		if (!in_array($nomeParam,array_keys($_POST))) {
			exibeErro(utf8ToHtml("Parâmetros incorretos. " . $nomeParam)); //bruno - prj 438 - sprint 7 - novo limite
		}
	}

	if ($glbvars["cdcooper"] == 3 || $habrat == 'N') {
		$nrgarope = $_POST["nrgarope"];
		$nrliquid = $_POST["nrliquid"];
		$nrpatlvr = $_POST["nrpatlvr"];
		$nrinfcad = $_POST["nrinfcad"];
		$nrperger = $_POST["nrperger"];
	} else {
		$nrgarope = 0;
		$nrliquid = 0;
		$nrpatlvr = 0;
		$nrinfcad = 0;
		$nrperger = 0;
	}

	$nrdconta = $_POST["nrdconta"];
	$nrctrlim = $_POST["nrctrlim"];
	$cddlinha = $_POST["cddlinha"];
	$vllimite = $_POST["vllimite"];
	$flgimpnp = $_POST["flgimpnp"];
	$vlsalari = $_POST["vlsalari"];
	$vlsalcon = $_POST["vlsalcon"];
	$vloutras = $_POST["vloutras"];
	$vlalugue = $_POST["vlalugue"];
	$dsobserv = $_POST["dsobserv"];

	$nrctaav1 = $_POST["nrctaav1"];
	$nmdaval1 = $_POST["nmdaval1"];
	$nrcpfav1 = $_POST["nrcpfav1"];
	$tpdocav1 = $_POST["tpdocav1"];
	$dsdocav1 = $_POST["dsdocav1"];
	$nmdcjav1 = $_POST["nmdcjav1"];
	$cpfcjav1 = $_POST["cpfcjav1"];
	$tdccjav1 = $_POST["tdccjav1"];
	$doccjav1 = $_POST["doccjav1"];
	$ende1av1 = $_POST["ende1av1"];
	$ende2av1 = $_POST["ende2av1"];
	$nrcepav1 = $_POST["nrcepav1"];
	$nmcidav1 = $_POST["nmcidav1"];
	$cdufava1 = $_POST["cdufava1"];
	$nrfonav1 = $_POST["nrfonav1"];	
	$emailav1 = $_POST["emailav1"];	
	$nrender1 = $_POST["nrender1"];	
	$complen1 = $_POST["complen1"];	
	$nrcxaps1 = $_POST["nrcxaps1"];	
	$vlrenme1 = $_POST["vlrenme1"];
	$nrctaav2 = $_POST["nrctaav2"];
	$nmdaval2 = $_POST["nmdaval2"];
	$nrcpfav2 = $_POST["nrcpfav2"];
	$tpdocav2 = $_POST["tpdocav2"];
	$dsdocav2 = $_POST["dsdocav2"];
	$nmdcjav2 = $_POST["nmdcjav2"];
	$cpfcjav2 = $_POST["cpfcjav2"];
	$tdccjav2 = $_POST["tdccjav2"];
	$doccjav2 = $_POST["doccjav2"];
	$ende1av2 = $_POST["ende1av2"];
	$ende2av2 = $_POST["ende2av2"];
	$nrcepav2 = $_POST["nrcepav2"];
	$nmcidav2 = $_POST["nmcidav2"];
	$cdufava2 = $_POST["cdufava2"];
	$nrfonav2 = $_POST["nrfonav2"];
	$emailav2 = $_POST["emailav2"];
	$nrender2 = $_POST["nrender2"];
	$complen2 = $_POST["complen2"];
	$nrcxaps2 = $_POST["nrcxaps2"];
	$vlrenme2 = $_POST["vlrenme2"];
	$inconcje = $_POST['inconcje'];
	$dtconbir = $_POST['dtconbir'];
	$idcobope = $_POST['idcobope'];
	// PRJ 438 - Sprint 7
	$vlrecjg1 = isset($_POST["vlrecjg1"]) ? $_POST["vlrecjg1"] : "0,00";
	$vlrecjg2 = isset($_POST["vlrecjg2"]) ? $_POST["vlrecjg2"] : "0,00";
	$cdnacio1 = $_POST["cdnacio1"];
	$cdnacio2 = $_POST["cdnacio2"];
	$inpesso1 = $_POST["inpesso1"];
	$inpesso2 = $_POST["inpesso2"];
	$dtnasct1 = $_POST["dtnasct1"];
	$dtnasct2 = $_POST["dtnasct2"];
	
	// Monta o xml de requisição
	$xmlSetLimite  = "";
	$xmlSetLimite .= "<Root>";
	$xmlSetLimite .= "	<Cabecalho>";
	$xmlSetLimite .= "		<Bo>b1wgen0019.p</Bo>";
	$xmlSetLimite .= "		<Proc>alterar-novo-limite</Proc>";
	$xmlSetLimite .= "	</Cabecalho>";
	$xmlSetLimite .= "	<Dados>";
	$xmlSetLimite .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetLimite .= "		<cdagenci>".$glbvars["cdpactra"]."</cdagenci>";
	$xmlSetLimite .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetLimite .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetLimite .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlSetLimite .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlSetLimite .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSetLimite .= "		<idseqttl>1</idseqttl>";
	$xmlSetLimite .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSetLimite .= "		<dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";
	$xmlSetLimite .= "		<inproces>".$glbvars["inproces"]."</inproces>";
	$xmlSetLimite .= "		<inconfir>".$inconfir."</inconfir>";
	$xmlSetLimite .= "		<nrctrlim>".$nrctrlim."</nrctrlim>";
	$xmlSetLimite .= "		<cddlinha>".$cddlinha."</cddlinha>";
	$xmlSetLimite .= "		<vllimite>".$vllimite."</vllimite>";
	$xmlSetLimite .= "		<flgimpnp>".$flgimpnp."</flgimpnp>";
	$xmlSetLimite .= "		<vlsalari>".$vlsalari."</vlsalari>";
	$xmlSetLimite .= "		<vlsalcon>".$vlsalcon."</vlsalcon>";
	$xmlSetLimite .= "		<vloutras>".$vloutras."</vloutras>";
	$xmlSetLimite .= "		<vlalugue>".$vlalugue."</vlalugue>";
	$xmlSetLimite .= "		<dsobserv>".$dsobserv."</dsobserv>";
	$xmlSetLimite .= "		<nrgarope>".$nrgarope."</nrgarope>";
	$xmlSetLimite .= "		<nrinfcad>".$nrinfcad."</nrinfcad>";
	$xmlSetLimite .= "		<nrliquid>".$nrliquid."</nrliquid>";
	$xmlSetLimite .= "		<nrpatlvr>".$nrpatlvr."</nrpatlvr>";
	$xmlSetLimite .= "		<nrperger>".$nrperger."</nrperger>";
	$xmlSetLimite .= "		<perfatcl>".$perfatcl."</perfatcl>";
	$xmlSetLimite .= "		<nrctaav1>".$nrctaav1."</nrctaav1>";
	$xmlSetLimite .= "		<nmdaval1>".$nmdaval1."</nmdaval1>";
	$xmlSetLimite .= "		<nrcpfav1>".$nrcpfav1."</nrcpfav1>";
	$xmlSetLimite .= "		<tpdocav1>".$tpdocav1."</tpdocav1>";
	$xmlSetLimite .= "		<dsdocav1>".$dsdocav1."</dsdocav1>";
	$xmlSetLimite .= "		<nmdcjav1>".$nmdcjav1."</nmdcjav1>";
	$xmlSetLimite .= "		<cpfcjav1>".$cpfcjav1."</cpfcjav1>";
	$xmlSetLimite .= "		<tdccjav1>".$tdccjav1."</tdccjav1>";
	$xmlSetLimite .= "		<doccjav1>".$doccjav1."</doccjav1>";
	$xmlSetLimite .= "		<ende1av1>".$ende1av1."</ende1av1>";
	$xmlSetLimite .= "		<ende2av1>".$ende2av1."</ende2av1>";
	$xmlSetLimite .= "		<nrcepav1>".$nrcepav1."</nrcepav1>";
	$xmlSetLimite .= "		<nmcidav1>".$nmcidav1."</nmcidav1>";
	$xmlSetLimite .= "		<cdufava1>".$cdufava1."</cdufava1>";
	$xmlSetLimite .= "		<nrfonav1>".$nrfonav1."</nrfonav1>";
	$xmlSetLimite .= "		<emailav1>".$emailav1."</emailav1>";
	$xmlSetLimite .= "		<nrender1>".$nrender1."</nrender1>";
	$xmlSetLimite .= "		<complen1>".$complen1."</complen1>";
	$xmlSetLimite .= "		<nrcxaps1>".$nrcxaps1."</nrcxaps1>";
	$xmlSetLimite .= "		<vlrenme1>".$vlrenme1."</vlrenme1>";
	$xmlSetLimite .= "		<nrctaav2>".$nrctaav2."</nrctaav2>";
	$xmlSetLimite .= "		<nmdaval2>".$nmdaval2."</nmdaval2>";
	$xmlSetLimite .= "		<nrcpfav2>".$nrcpfav2."</nrcpfav2>";
	$xmlSetLimite .= "		<tpdocav2>".$tpdocav2."</tpdocav2>";
	$xmlSetLimite .= "		<dsdocav2>".$dsdocav2."</dsdocav2>";
	$xmlSetLimite .= "		<nmdcjav2>".$nmdcjav2."</nmdcjav2>";
	$xmlSetLimite .= "		<cpfcjav2>".$cpfcjav2."</cpfcjav2>";
	$xmlSetLimite .= "		<tdccjav2>".$tdccjav2."</tdccjav2>";
	$xmlSetLimite .= "		<doccjav2>".$doccjav2."</doccjav2>";
	$xmlSetLimite .= "		<ende1av2>".$ende1av2."</ende1av2>";
	$xmlSetLimite .= "		<ende2av2>".$ende2av2."</ende2av2>";
	$xmlSetLimite .= "		<nrcepav2>".$nrcepav2."</nrcepav2>";
	$xmlSetLimite .= "		<nmcidav2>".$nmcidav2."</nmcidav2>";
	$xmlSetLimite .= "		<cdufava2>".$cdufava2."</cdufava2>";
	$xmlSetLimite .= "		<nrfonav2>".$nrfonav2."</nrfonav2>";
	$xmlSetLimite .= "		<emailav2>".$emailav2."</emailav2>";
	$xmlSetLimite .= "		<nrender2>".$nrender2."</nrender2>";
	$xmlSetLimite .= "		<complen2>".$complen2."</complen2>";
	$xmlSetLimite .= "		<nrcxaps2>".$nrcxaps2."</nrcxaps2>";
	$xmlSetLimite .= "		<vlrenme2>".$vlrenme2."</vlrenme2>";
	$xmlSetLimite .= "		<inconcje>".$inconcje."</inconcje>";
	$xmlSetLimite .= "		<dtconbir>".$dtconbir."</dtconbir>";
	$xmlSetLimite .= "		<idcobope>".$idcobope."</idcobope>";
	// PRJ 438 - Sprint 7
	$xmlSetLimite .= "		<vlrecjg1>".$vlrecjg1."</vlrecjg1>";
	$xmlSetLimite .= "		<vlrecjg2>".$vlrecjg2."</vlrecjg2>";
	$xmlSetLimite .= "		<cdnacio1>".$cdnacio1."</cdnacio1>";
	$xmlSetLimite .= "		<cdnacio2>".$cdnacio2."</cdnacio2>";
	$xmlSetLimite .= "		<inpesso1>".$inpesso1."</inpesso1>";
	$xmlSetLimite .= "		<inpesso2>".$inpesso2."</inpesso2>";
	$xmlSetLimite .= "		<dtnasct1>".$dtnasct1."</dtnasct1>";
	$xmlSetLimite .= "		<dtnasct2>".$dtnasct2."</dtnasct2>";

	$xmlSetLimite .= "	</Dados>";
	$xmlSetLimite .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetLimite);

	// Cria objeto para classe de tratamento de XML
	$xmlObjLimite = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjLimite->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjLimite->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}

	$flmudfai  = $xmlObjLimite->roottag->tags[0]->attributes["FLMUDFAI"];
	$mensagens = $xmlObjLimite->roottag->tags[0]->tags;

	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';
	
	// Dados globais
	echo 'nrctrimp = '.$nrctrlim.';';
	echo 'tpctrrat = 1;';
	echo 'nrctrrat = '.$nrctrlim.';';
	
	// Mensagens de alerta
	$msg = Array();

	foreach( $mensagens as $mensagem ) {
		$msg[] = getByTagName($mensagem->tags,'dsmensag');
	}

	$stringArrayMsg = implode( "|", $msg);
	echo 'exibirMensagens("'.$stringArrayMsg.'","blockBackground(parseInt($(\"#divRotina\").css(\"z-index\")));");';
		
	if ($flmudfai == 'N') {
		echo "showConfirmacao('Deseja efetuar as consultas?','Confirma&ccedil;&atilde;o - Aimaro','blockBackground(parseInt($(\"#divRotina\").css(\"z-index\")));acessaOpcaoAba(\"\",\"\",\"IA\");','efetuar_consultas();acessaOpcaoAba(\"\",\"\",\"IA\");','nao.gif','sim.gif');";
		// echo "showConfirmacao('Deseja efetuar as consultas?','Confirma&ccedil;&atilde;o - Aimaro','blockBackground(parseInt($(\"#divRotina\").css(\"z-index\")));acessaTela(\"@\");','efetuar_consultas();acessaTela(\"@\");','nao.gif','sim.gif');";
	}else{
		echo "acessaOpcaoAba('','',\"IA\");";
		// echo "acessaTela(\"@\");";
	}

		// Gravar dados do rating do cooperado
		// bruno - prj 438 - sprint 7 - tela rating
	if ($glbvars["cdcooper"] == 3 || $habrat == 'N') {
		echo "
			var aux_dataRating = {
			nrdconta: '".$nrdconta."',
			nrgarope: '".$nrgarope."',
			nrinfcad: '".$nrinfcad."',
			nrliquid: '".$nrliquid."',
			nrpatlvr: '".$nrpatlvr."',
			nrperger: '".$nrperger."',
			tpctrrat: tpctrrat,
			nrctrrat: nrctrrat,
			iddivcri: 'nop',
			redirect: 'script_ajax'
		};
		";
		echo 'atualizarDadosRating(aux_dataRating, "");';
	}
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}	
	
?>