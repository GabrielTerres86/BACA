<?php 

/*************************************************************************
	Fonte: realiza_habilitacao.php
	Autor: Gabriel						Ultima atualizacao: 24/11/2015
	Data : Dezembro/2010
	
	Objetivo: Efetuar a habilitacao do convenio CEB.
	
	Alteracoes: 26/07/2011 - Incluir parametro de cobranca Registrada
							 (Gabriel)

				08/09/2011 - Incluido a chamda da procedure alerta_fraude 
							(Adriano).
							
				26/03/2013 - Retirado a chamada da procedure alerta_fraude
							 (Adriano).
							 
				10/05/2013 - Retirado campo de valor maximo do boleto. 
						     vllbolet (Jorge)			 
							 
				19/09/2013 - Inclusao do campo e parametro flgcebhm (Carlos)
							 
				28/04/2015 - Incluido campos cooperativa emite e expede e
							 cooperado emite e expede. (Reinert)
							 
				06/10/2015 - Reformulacao cadastral (Gabriel-RKAM).			 

                24/11/2015 - Inclusao do indicador de negativacao pelo Serasa.
                             (Jaison/Andrino)

*************************************************************************/

	session_start();

	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	

	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");	

	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"H")) <> "") {
		exibeErro($msgError);		
	}
		
	$nrdconta = $_POST["nrdconta"];
	$nrconven = $_POST["nrconven"];
	$dssitceb = $_POST["dssitceb"];
	$inarqcbr = $_POST["inarqcbr"];
	$cddemail = $_POST["cddemail"];
	$flgcruni = $_POST["flgcruni"];
	$flgcebhm = $_POST["flgcebhm"];
	$dsdregis = $_POST["dsdregis"]; // Valores da emissao de boletos dos titulares
	$flgregis = trim($_POST["flgregis"]);
	$flcooexp = trim($_POST["flcooexp"]);
	$flceeexp = trim($_POST["flceeexp"]);
    $flserasa = trim($_POST["flserasa"]);
    $flseralt = (int) trim($_POST["flseralt"]);
	$nrcpfcgc = $_POST["nrcpfcgc"];
	$cddopcao = trim($_POST["cddopcao"]);
	$executandoProdutos = $_POST['executandoProdutos'];

	$xmlHabilitaConvenio  = "";
	$xmlHabilitaConvenio .= "<Root>";
	$xmlHabilitaConvenio .= " <Cabecalho>";
	$xmlHabilitaConvenio .= "  <Bo>b1wgen0082.p</Bo>";
	$xmlHabilitaConvenio .= "  <Proc>habilita-convenio</Proc>";
	$xmlHabilitaConvenio .= " </Cabecalho>";
	$xmlHabilitaConvenio .= " <Dados>";
	$xmlHabilitaConvenio .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlHabilitaConvenio .= "   <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlHabilitaConvenio .= "   <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlHabilitaConvenio .= "   <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlHabilitaConvenio .= "   <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlHabilitaConvenio .= "   <idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlHabilitaConvenio .= "	<nrdconta>".$nrdconta."</nrdconta>";
	$xmlHabilitaConvenio .= "   <nrconven>".$nrconven."</nrconven>";
	$xmlHabilitaConvenio .= "   <dssitceb>".$dssitceb."</dssitceb>";
	$xmlHabilitaConvenio .= "   <inarqcbr>".$inarqcbr."</inarqcbr>";
	$xmlHabilitaConvenio .= "   <cddemail>".$cddemail."</cddemail>";
	$xmlHabilitaConvenio .= "   <flgcruni>".$flgcruni."</flgcruni>";
	$xmlHabilitaConvenio .= "   <flgcebhm>".$flgcebhm."</flgcebhm>";
	$xmlHabilitaConvenio .= "   <dsdregis>".$dsdregis."</dsdregis>";
	$xmlHabilitaConvenio .= "   <idseqttl>1</idseqttl>";
	$xmlHabilitaConvenio .= "   <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlHabilitaConvenio .= "   <flcooexp>".$flcooexp."</flcooexp>";
	$xmlHabilitaConvenio .= "   <flceeexp>".$flceeexp."</flceeexp>";
    $xmlHabilitaConvenio .= "   <flserasa>".$flserasa."</flserasa>";
	$xmlHabilitaConvenio .= " </Dados>";
	$xmlHabilitaConvenio .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlHabilitaConvenio);

	$xmlObjCarregaDados = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjCarregaDados->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjCarregaDados->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 

	// Se foi alterado a flag de Serasa
	if ($flseralt == 1) {
		$flposbol = $_POST["flposbol"];

		// Montar o xml de Requisicao
		$xmlCarregaDados  = "";
		$xmlCarregaDados .= "<Root>";
		$xmlCarregaDados .= " <Dados>";
		$xmlCarregaDados .= "   <flserasa>".$flserasa."</flserasa>";
		$xmlCarregaDados .= "   <flposbol>".$flposbol."</flposbol>";
		$xmlCarregaDados .= "   <nrdconta>".$nrdconta."</nrdconta>";
		$xmlCarregaDados .= "   <nrconven>".$nrconven."</nrconven>";
		$xmlCarregaDados .= " </Dados>";
		$xmlCarregaDados .= "</Root>";

		$xmlResult = mensageria($xmlCarregaDados, "SSPC0002", 'ALTERA_NEGATIVACAO', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObj = getObjectXML($xmlResult);
	}

	echo 'hideMsgAguardo();';

	$dsdmesag = $xmlObjCarregaDados->roottag->tags[0]->attributes["DSDMESAG"];
	$dsdtitul = $xmlObjCarregaDados->roottag->tags[0]->attributes["DSDTITUL"];
	$flgimpri = $xmlObjCarregaDados->roottag->tags[0]->attributes["FLGIMPRI"];


	if ($cddopcao == "A"){
		$opermail = "Alterar Convenio";
	}else{ 
		if ($cddopcao == "I"){
			$opermail = "Novo Convenio";
		}
	}

	$metodo = ($executandoProdutos == 'true') ? 'encerraRotina();' : 'acessaOpcaoAba();';	

	if ($dsdmesag != "") {  // Se esta incluindo um novo e convenio CEB tem numeracao mostrar o numero 	
		echo 'showError("inform",
					    "'.$dsdmesag.'",
						"Alerta - Ayllos",
						"blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));'.($dsdtitul != "" || $flgimpri == "yes" ? "confirmaImpressao('".$flgregis."','".$dsdtitul . "');" : $metodo ).'");';			
	}
	else
	if ($dsdtitul != "" || $flgimpri == "yes") {  // Se tem o PDF a mostrar entao chama função para mostrar PDF do impresso gerado no browser	 	
		echo 'confirmaImpressao("'.$flgregis.'","'.$dsdtitul.'");';
	} 
	else {	
		echo $metodo;
	}

	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) {
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}

?>