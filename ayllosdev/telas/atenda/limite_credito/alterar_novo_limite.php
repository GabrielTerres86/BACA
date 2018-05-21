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
	

	// Verifica se os parâmetros necessários foram informados
	$params = array("nrdconta","nrctrlim","cddlinha","vllimite","flgimpnp","vlsalari","vlsalcon","vloutras","vlalugue","dsobserv",
					"nrgarope","nrinfcad","nrliquid","nrpatlvr","nrperger","perfatcl","nrctaav1","nmdaval1","nrcpfav1","tpdocav1",
					"dsdocav1","nmdcjav1","cpfcjav1","tdccjav1","doccjav1","ende1av1","ende2av1","nrcepav1","nmcidav1","cdufava1",
					"nrfonav1","emailav1","vlrenme1","nrctaav2","nmdaval2","nrcpfav2","tpdocav2","dsdocav2","nmdcjav2","cpfcjav2",
					"tdccjav2","doccjav2","ende1av2","ende2av2","nrcepav2","nmcidav2","cdufava2","nrfonav2","emailav2","vlrenme2",
					"idcobope");

	foreach ($params as $nomeParam) {
		if (!in_array($nomeParam,array_keys($_POST))) {			
			exibeErro("Parâmetros incorretos.");
		}	
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
	$nrgarope = $_POST["nrgarope"];
	$nrinfcad = $_POST["nrinfcad"];
	$nrliquid = $_POST["nrliquid"];
	$nrpatlvr = $_POST["nrpatlvr"];
	$nrperger = $_POST["nrperger"];	
	$perfatcl = $_POST["perfatcl"];	
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
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inválida.");
	}
	
	// Verifica se número do contrato é um inteiro válido
	if (!validaInteiro($nrctrlim)) {
		exibeErro("Número de contrato inválido.");
	}	
	
	// Verifica se número da linha de crédito é um inteiro válido
	if (!validaInteiro($nrctrlim)) {
		exibeErro("Linha de crédito inválida.");
	}
	
	// Verifica se valor do limite é um decimal válido
	if (!validaDecimal($vllimite)) {
		exibeErro("Valor do Limite de Crédito inválido.");
	}	
	
	// Valida impressão de nota promissória
	if ($flgimpnp <> "yes" && $flgimpnp <> "no") {
		exibeErro("Indicador de impressão da nota promissória inválido.");		
	}
	
	// Verifica se valor do salário do avalista é um decimal válido
	if (!validaDecimal($vlsalari)) {
		exibeErro("Valor do Salário do Avalista inválido.");
	}	
	
	// Verifica se valor do salário do conjugê é um decimal válido
	if (!validaDecimal($vlsalcon)) {
		exibeErro("Valor do Salário do Conjugê inválido.");
	}	
	
	// Verifica se valor de outras é um decimal válido
	if (!validaDecimal($vloutras)) {
		exibeErro("Outros Valores inválido.");
	}	
	
	// Verifica se valor do aluguel é um decimal válido
	if (!validaDecimal($vlalugue)) {
		exibeErro("Valor do Aluguel inválido.");
	}		
	
	// Verifica se identificador de garantia é um inteiro válido
	if (!validaInteiro($nrgarope)) {
		exibeErro("Garantia inválida.");
	}
	
	// Verifica se identificador de informação cadastral é um inteiro válido
	if (!validaInteiro($nrinfcad)) {
		exibeErro("Informação cadastral inválida.");
	}
	
	// Verifica se identificador de liquidez é um inteiro válido
	if (!validaInteiro($nrliquid)) {
		exibeErro("Liquidez de garantia inválida.");
	}
	
	// Verifica se identificador de patrimônio é um inteiro válido
	if (!validaInteiro($nrpatlvr)) {
		exibeErro("Patrimônio pessoal inválido.");
	}
	
	// Verifica se identificador de percepção é um inteiro válido
	if (!validaInteiro($nrperger)) {
		exibeErro("Percepção geral inválida.");
	}
		
	// Verifica se o percentual de faturamento é um decimal válido
	if (!validaDecimal($perfatcl)) {
		exibeErro("Percentual de Faturamento inválido.");
	}		
	
	// Verifica se número da conta do 1° avalista é um inteiro válido
	if (!validaInteiro($nrctaav1)) {
		exibeErro("Conta/dv do 1o Avalista inválida.");
	}
	
	// Verifica se número da conta do 2° avalista é um inteiro válido
	if (!validaInteiro($nrctaav2)) {
		exibeErro("Conta/dv do 2o Avalista inválida.");
	}	
	
	// Verifica se CPF do 1° avalista é um inteiro válido
	if (!validaInteiro($nrcpfav1)) {
		exibeErro("CPF do 1o Avalista inválido.");
	}	
	
	// Verifica se CPF do Conjugê do 1° avalista é um inteiro válido
	if (!validaInteiro($cpfcjav1)) {
		exibeErro("CPF do Conjugê do 1o Avalista inválido.");
	}	
	
	// Verifica se CPF do 2° avalista é um inteiro válido
	if (!validaInteiro($nrcpfav2)) {
		exibeErro("CPF do 2o Avalista inválido.");
	}	
	
	// Verifica se CPF do Conjugê do 2° avalista é um inteiro válido
	if (!validaInteiro($cpfcjav2)) {
		exibeErro("CPF do Conjugê do 2o Avalista inválido.");
	}	
	
	// Verifica se CEP do 2° avalista é um inteiro válido
	if (!validaInteiro($nrcepav1)) {
		exibeErro("CEP do 1o Avalista inválido.");
	}	
	
	// Verifica se CEP do 2° avalista é um inteiro válido
	if (!validaInteiro($nrcepav2)) {
		exibeErro("CEP do 2o Avalista inválido.");
	}
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($idcobope)) {
		exibeErro("Garantia inválida.");
	}
	
	$dsobserv = str_replace('"','',str_replace('>','',str_replace('<','',retiraAcentos(removeCaracteresInvalidos(utf8_decode($dsobserv))))));
	
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
		echo "showConfirmacao('Deseja efetuar as consultas?','Confirma&ccedil;&atilde;o - Ayllos','blockBackground(parseInt($(\"#divRotina\").css(\"z-index\")));atualizaDadosRating(\"divConteudoOpcao\");','efetuar_consultas();atualizaDadosRating(\"divConteudoOpcao\");','nao.gif','sim.gif');";
	}	
	else {
		// Gravar dados do rating do cooperado
		echo 'atualizaDadosRating("divConteudoOpcao");';
	}
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}	
	
?>