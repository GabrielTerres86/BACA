<? 
/*!
 * FONTE        : titulos_limite_grava_proposta.php
 * CRIAÇÃO      : David
 * DATA CRIAÇÃO : Junho/2010
 * OBJETIVO     : Gravar proposta do limite de desconto de títulos	             		        				   
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 000: [22/10/2010] David           (CECRED) : Validar permissão de acesso a operação (David) 
 * 001: [06/05/2011] Rogérius Militão   (DB1) : Adaptação no formulário de avalista genérico
 * 002: [12/09/2011] Adriano		 (CECRED) : Incluido chamada para a procedure alerta_fraude
 * 003: [26/03/2013] Adriano		 (CECRED) : Retirado a chamada para a procedure alerta_fraude.
 * 004: [20/08/2015] Kelvin 		 (CECRED) : Ajuste feito para não inserir caracters 
 *								         	    especiais na observação, conforme solicitado
 *	   										    no chamado 315453. 
         17/06/2016 - M181 - Alterar o CDAGENCI para          
                      passar o CDPACTRA (Rafael Maciel - RKAM) 
		 28/07/2017 - Desenvolvimento da melhoria 364 - Grupo Economico Novo. (Mauro)
 */
?>


<?php 

	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");
	require_once("../../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");
	
	// Verifica se os parâmetros necessários foram informados
	$params = array("nrdconta","nrctrlim","cddlinha","vllimite","dsramati","vlmedtit","vlfatura","vloutras","vlsalari","vlsalcon","dsdbens1","dsdbens2","dsobserv",
                    "nrctaav1","nmdaval1","nrcpfav1","tpdocav1","dsdocav1","nmdcjav1","cpfcjav1","tdccjav1","doccjav1","ende1av1","ende2av1","nrcepav1","nmcidav1","cdufava1","nrfonav1","emailav1",
                    "nrctaav2","nmdaval2","nrcpfav2","tpdocav2","dsdocav2","nmdcjav2","cpfcjav2","tdccjav2","doccjav2","ende1av2","ende2av2","nrcepav2","nmcidav2","cdufava2","nrfonav2","emailav2",
					"nrgarope","nrinfcad","nrliquid","nrpatlvr","nrperger","vltotsfn","perfatcl","idcobope",
					"cddopcao","nrcpfcgc","redirect");

	foreach ($params as $nomeParam) {
		if (!in_array($nomeParam,array_keys($_POST))) {			
			exibeErro("Par&acirc;metros incorretos.");
		}	
	}				  

	$nrdconta = $_POST["nrdconta"];
	$nrcpfcgc = $_POST["nrcpfcgc"];
	
	$nrctrlim = $_POST["nrctrlim"];	
	$vllimite = $_POST["vllimite"];
	$dsramati = $_POST["dsramati"];
	$vlmedtit = $_POST["vlmedtit"];
	$vlfatura = $_POST["vlfatura"];
	$vloutras = $_POST["vloutras"];
	$vlsalari = $_POST["vlsalari"];
	$vlsalcon = $_POST["vlsalcon"];
	$dsdbens1 = $_POST["dsdbens1"];
	$dsdbens2 = $_POST["dsdbens2"];
	$dsobserv = retiraAcentos(removeCaracteresInvalidos($_POST["dsobserv"]));
	$cddlinha = $_POST["cddlinha"];
	$qtdiavig = $_POST["qtdiavig"];

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
	$nrender1 = $_POST['nrender1'];	
	$complen1 = $_POST['complen1'];	
	$nrcxaps1 = $_POST['nrcxaps1'];	

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
	$nrender2 = $_POST['nrender2'];	
	$complen2 = $_POST['complen2'];	
	$nrcxaps2 = $_POST['nrcxaps2'];	

	$nrgarope = $_POST["nrgarope"];
	$nrinfcad = $_POST["nrinfcad"];
	$nrliquid = $_POST["nrliquid"];
	$nrpatlvr = $_POST["nrpatlvr"];
	$nrperger = $_POST["nrperger"];	
	$vltotsfn = $_POST["vltotsfn"];	
	$perfatcl = $_POST["perfatcl"];
    $idcobope = $_POST["idcobope"];

	$cddopcao = $_POST["cddopcao"];
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$cddopcao)) <> "") {
		exibeErro($msgError);		
	}
	
	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}

	// Verifica se o do contrato é um inteiro válido
	if (!validaInteiro($nrctrlim)) {
		exibeErro("N&uacute;mero do contrato inv&aacute;lido.");
	}
	
	// Verifica se o código do contrato é um inteiro válido
	if (!validaInteiro($cddlinha)) {
		exibeErro("C&oacute;digo da linha de desconto inv&aacute;lido.");
	}	
	
	// Verifica se identificador de garantia é um inteiro válido
	if (!validaInteiro($nrgarope)) {
		exibeErro("Garantia inv&aacute;lida.");
	}
	
	// Verifica se identificador de informação cadastral é um inteiro válido
	if (!validaInteiro($nrinfcad)) {
		exibeErro("Informa&ccedil;&etilde;o cadastral inv&aacute;lida.");
	}
	
	// Verifica se identificador de liquidez é um inteiro válido
	if (!validaInteiro($nrliquid)) {
		exibeErro("Liquidez de garantia inv&aacute;lida.");
	}
	
	// Verifica se identificador de patrimônio é um inteiro válido
	if (!validaInteiro($nrpatlvr)) {
		exibeErro("Patrim&ocirc;nio pessoal inv&aacute;lido.");
	}
	
	// Verifica se identificador de percepção é um inteiro válido
	if (!validaInteiro($nrperger)) {
		exibeErro("Percep&ccedil;&atilde;o geral inv&aacute;lida.");
	}
	
	// Verifica se valor total sfn é um decimal válido
	if (!validaDecimal($vltotsfn)) {
		exibeErro("Valor Total SFN inv&aacute;lido.");
	}	
	
	// Verifica se o percentual de faturamento é um decimal válido
	if (!validaDecimal($perfatcl)) {
		exibeErro("Percentual de Faturamento inv&aacute;lido.");
	}
	
	// Verifica se número da conta do 1° avalista é um inteiro válido
	if (!validaInteiro($nrctaav1)) {
		exibeErro("Conta/dv do 1o Avalista inv&aacute;lida.");
	}
	
	// Verifica se número da conta do 2° avalista é um inteiro válido
	if (!validaInteiro($nrctaav2)) {
		exibeErro("Conta/dv do 2o Avalista inv&aacute;lida.");
	}	
	
	// Verifica se CPF do 1° avalista é um inteiro válido
	if (!validaInteiro($nrcpfav1)) {
		exibeErro("CPF do 1o Avalista inv&aacute;lido.");
	}	
	
	// Verifica se CPF do Conjugê do 1° avalista é um inteiro válido
	if (!validaInteiro($cpfcjav1)) {
		exibeErro("CPF do C&ocirc;njuge do 1o Avalista inv&aacute;lido.");
	}	
	
	// Verifica se CPF do 2° avalista é um inteiro válido
	if (!validaInteiro($nrcpfav2)) {
		exibeErro("CPF do 2o Avalista inv&aacute;lido.");
	}	
	
	// Verifica se CPF do Conjugê do 2° avalista é um inteiro válido
	if (!validaInteiro($cpfcjav2)) {
		exibeErro("CPF do C&ocirc;njuge do 2o Avalista inv&aacute;lido.");
	}	
	
	// Verifica se CEP do 2° avalista é um inteiro válido
	if (!validaInteiro($nrcepav1)) {
		exibeErro("CEP do 1o Avalista inv&aacute;lido.");
	}	
	
	// Verifica se CEP do 2° avalista é um inteiro válido
	if (!validaInteiro($nrcepav2)) {
		exibeErro("CEP do 2o Avalista inv&aacute;lido.");
	}		
	
	// Verifica se o CPF/CNPJ &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrcpfcgc)) {
		exibeErro("N&uacute;mero de CPF/CNPJ inv&aacute;lido.");
	}		

	// Monta o xml de requisição
	$xmlSetGravarLimite  = "";
	$xmlSetGravarLimite .= "<Root>";
	$xmlSetGravarLimite .= "	<Cabecalho>";
	$xmlSetGravarLimite .= "		<Bo>b1wgen0030.p</Bo>";
	$xmlSetGravarLimite .= "		<Proc>".($cddopcao == "A" ? "efetua_alteracao_limite" : "efetua_inclusao_limite")."</Proc>";
	$xmlSetGravarLimite .= "	</Cabecalho>";
	$xmlSetGravarLimite .= "	<Dados>";
	$xmlSetGravarLimite .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetGravarLimite .= "		<cdagenci>".$glbvars["cdpactra"]."</cdagenci>";
	$xmlSetGravarLimite .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetGravarLimite .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSetGravarLimite .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlSetGravarLimite .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlSetGravarLimite .= "		<idseqttl>1</idseqttl>";
	$xmlSetGravarLimite .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSetGravarLimite .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetGravarLimite .= "		<vllimite>".$vllimite."</vllimite>";
	$xmlSetGravarLimite .= "		<dsramati>".$dsramati."</dsramati>";
	$xmlSetGravarLimite .= "		<vlmedtit>".$vlmedtit."</vlmedtit>";
	$xmlSetGravarLimite .= "		<vlfatura>".$vlfatura."</vlfatura>";
	$xmlSetGravarLimite .= "		<vloutras>".$vloutras."</vloutras>";
	$xmlSetGravarLimite .= "		<vlsalari>".$vlsalari."</vlsalari>";
	$xmlSetGravarLimite .= "		<vlsalcon>".$vlsalcon."</vlsalcon>";
	$xmlSetGravarLimite .= "		<dsdbens1>".$dsdbens1."</dsdbens1>";
	$xmlSetGravarLimite .= "		<dsdbens2>".$dsdbens2."</dsdbens2>";
	$xmlSetGravarLimite .= "		<nrctrlim>".$nrctrlim."</nrctrlim>";
	$xmlSetGravarLimite .= "		<cddlinha>".$cddlinha."</cddlinha>";
	$xmlSetGravarLimite .= "		<dsobserv>".$dsobserv."</dsobserv>";
	$xmlSetGravarLimite .= "		<qtdiavig>".$qtdiavig."</qtdiavig>";
	$xmlSetGravarLimite .= "		<nrctaav1>".$nrctaav1."</nrctaav1>";
	$xmlSetGravarLimite .= "		<nmdaval1>".$nmdaval1."</nmdaval1>";
	$xmlSetGravarLimite .= "		<nrcpfav1>".$nrcpfav1."</nrcpfav1>";
	$xmlSetGravarLimite .= "		<tpdocav1>".$tpdocav1."</tpdocav1>";
	$xmlSetGravarLimite .= "		<dsdocav1>".$dsdocav1."</dsdocav1>";
	$xmlSetGravarLimite .= "		<nmdcjav1>".$nmdcjav1."</nmdcjav1>";
	$xmlSetGravarLimite .= "		<cpfcjav1>".$cpfcjav1."</cpfcjav1>";
	$xmlSetGravarLimite .= "		<tdccjav1>".$tdccjav1."</tdccjav1>";
	$xmlSetGravarLimite .= "		<doccjav1>".$doccjav1."</doccjav1>";
	$xmlSetGravarLimite .= "		<ende1av1>".$ende1av1."</ende1av1>";
	$xmlSetGravarLimite .= "		<ende2av1>".$ende2av1."</ende2av1>";
	$xmlSetGravarLimite .= "		<nrcepav1>".$nrcepav1."</nrcepav1>";
	$xmlSetGravarLimite .= "		<nmcidav1>".$nmcidav1."</nmcidav1>";
	$xmlSetGravarLimite .= "		<cdufava1>".$cdufava1."</cdufava1>";
	$xmlSetGravarLimite .= "		<nrfonav1>".$nrfonav1."</nrfonav1>";
	$xmlSetGravarLimite .= "		<emailav1>".$emailav1."</emailav1>";
	$xmlSetGravarLimite .= "		<nrender1>".$nrender1."</nrender1>";
	$xmlSetGravarLimite .= "		<complen1>".$complen1."</complen1>";
	$xmlSetGravarLimite .= "		<nrcxaps1>".$nrcxaps1."</nrcxaps1>";	
	$xmlSetGravarLimite .= "		<nrctaav2>".$nrctaav2."</nrctaav2>";
	$xmlSetGravarLimite .= "		<nmdaval2>".$nmdaval2."</nmdaval2>";
	$xmlSetGravarLimite .= "		<nrcpfav2>".$nrcpfav2."</nrcpfav2>";
	$xmlSetGravarLimite .= "		<tpdocav2>".$tpdocav2."</tpdocav2>";
	$xmlSetGravarLimite .= "		<dsdocav2>".$dsdocav2."</dsdocav2>";
	$xmlSetGravarLimite .= "		<nmdcjav2>".$nmdcjav2."</nmdcjav2>";
	$xmlSetGravarLimite .= "		<cpfcjav2>".$cpfcjav2."</cpfcjav2>";
	$xmlSetGravarLimite .= "		<tdccjav2>".$tdccjav2."</tdccjav2>";
	$xmlSetGravarLimite .= "		<doccjav2>".$doccjav2."</doccjav2>";
	$xmlSetGravarLimite .= "		<ende1av2>".$ende1av2."</ende1av2>";
	$xmlSetGravarLimite .= "		<ende2av2>".$ende2av2."</ende2av2>";
	$xmlSetGravarLimite .= "		<nrcepav2>".$nrcepav2."</nrcepav2>";
	$xmlSetGravarLimite .= "		<nmcidav2>".$nmcidav2."</nmcidav2>";
	$xmlSetGravarLimite .= "		<cdufava2>".$cdufava2."</cdufava2>";
	$xmlSetGravarLimite .= "		<nrfonav2>".$nrfonav2."</nrfonav2>";
	$xmlSetGravarLimite .= "		<emailav2>".$emailav2."</emailav2>";
	$xmlSetGravarLimite .= "		<nrender2>".$nrender2."</nrender2>";
	$xmlSetGravarLimite .= "		<complen2>".$complen2."</complen2>";
	$xmlSetGravarLimite .= "		<nrcxaps2>".$nrcxaps2."</nrcxaps2>";	
	$xmlSetGravarLimite .= "		<nrgarope>".$nrgarope."</nrgarope>";
	$xmlSetGravarLimite .= "		<nrinfcad>".$nrinfcad."</nrinfcad>";
	$xmlSetGravarLimite .= "		<nrliquid>".$nrliquid."</nrliquid>";
	$xmlSetGravarLimite .= "		<nrpatlvr>".$nrpatlvr."</nrpatlvr>";
	$xmlSetGravarLimite .= "		<nrperger>".$nrperger."</nrperger>";	
	$xmlSetGravarLimite .= "		<vltotsfn>".$vltotsfn."</vltotsfn>";
	$xmlSetGravarLimite .= "		<perfatcl>".$perfatcl."</perfatcl>";
    $xmlSetGravarLimite .= "		<idcobope>".$idcobope."</idcobope>";
	$xmlSetGravarLimite .= "	</Dados>";
	$xmlSetGravarLimite .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetGravarLimite);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjLimite = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjLimite->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjLimite->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 	
	
	if ($cddopcao == "A"){
		$opermail = "Alterar Limite de Desconto de Titulos";
	}else{  if ($cddopcao == "I"){
				$opermail = "Novo Limite de Desconto de Titulos";
			}
	}
		
	// Esconde mensagem de aguardo
	// Bloqueia conteúdo que está átras do div da rotina
	echo 'hideMsgAguardo();';
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';

	if ($cddopcao == "I") {
		echo 'nrcontrato = '.$nrctrlim.';';
		echo 'idLinhaL   = 0;';
	}
	
	// Dados globais rating
	echo 'tpctrrat = 3;';
	echo 'nrctrrat = '.$nrctrlim.';';

	$mensagens = $xmlObjLimite->roottag->tags[0]->tags;
	// Mensagens de alerta
	$msg = Array();
	foreach( $mensagens as $mensagem ) {
		$msg[] = str_replace('|@|','<br>',getByTagName($mensagem->tags,'dsmensag'));
	}
	$stringArrayMsg = implode( "|", $msg);
	echo 'exibirMensagens("'.$stringArrayMsg.'","atualizaDadosRating(\"divOpcoesDaOpcao3\");");';
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
		
	
?>