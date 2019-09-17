<?php 

/*************************************************************************
	Fonte: realiza_habilitacao.php
	Autor: Gabriel						Ultima atualizacao: 20/02/2019
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

				23/02/2016 - PRJ 213 - Reciprocidade. (Jaison/Marcos)

                17/06/2016 - M181 - Alterar o CDAGENCI para          
                      passar o CDPACTRA (Rafael Maciel - RKAM) 
				04/08/2016 - Adicionado campo de forma de envio de 
						     arquivo de cobran�a. (Reinert)

				13/12/2016 - PRJ340 - Nova Plataforma de Cobranca - Fase II. (Jaison/Cechet)

				20/02/2019 - Novo campo Homologado API (Andrey Formigari - Supero)
						     
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
		exibirErro('error',$msgError,'Alerta - Ayllos','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))',false);
	}

	$convenios = ( (!empty($_POST['convenios'])) ? json_decode($_POST['convenios']) : '' );

	if (count($convenios)) {
		$strConven = array();
		foreach($convenios as $convenio) {
			$strConven[] = $convenio->convenio;
		}
		$convenios = $strConven;
	}

	$nrdconta = $_POST["nrdconta"];
	$insitceb = 1;
	$inarqcbr = $_POST["inarqcbr"];
	$cddemail = $_POST["cddemail"];
	$flgcruni = $_POST["flgcruni"];
	$flgcebhm = $_POST["flgcebhm"];
	$dsdregis = $_POST["dsdregis"]; // Valores da emissao de boletos dos titulares
	$flgregis = trim($_POST["flgregis"]);
    $flgregon = trim($_POST["flgregon"]);
    $flgpgdiv = trim($_POST["flgpgdiv"]);
	$flcooexp = trim($_POST["flcooexp"]);
	$flceeexp = trim($_POST["flceeexp"]);
    $flserasa = trim($_POST["flserasa"]);
    $flseralt = (int) trim($_POST["flseralt"]);
	$nrcpfcgc = $_POST["nrcpfcgc"];
	$cddopcao = trim($_POST["cddopcao"]);
    $qtdfloat = $_POST["qtdfloat"];
    $flprotes = $_POST["flprotes"];
	$insrvprt = $_POST["insrvprt"];
	$flproalt = (int) trim($_POST["flproalt"]);
	$qtlimaxp = $_POST["qtlimaxp"];
	$qtlimmip = $_POST["qtlimmip"];
    $qtdecprz = $_POST["qtdecprz"];
    $idrecipr = (int) $_POST["idrecipr"];
	$inenvcob = (int) $_POST["inenvcob"];
    $idreciprold = (int) $_POST["idreciprold"];
    $perdesconto = $_POST["perdesconto"];
	$executandoProdutos = $_POST['executandoProdutos'];
	$flgapihm = trim($_POST["flgapihm"]);
	
	
	foreach($convenios as $convenio) {
		$xmlHabilitaConvenio  = "";
		$xmlHabilitaConvenio .= "<Root>";
		$xmlHabilitaConvenio .= " <Dados>";
		$xmlHabilitaConvenio .= "	<nrdconta>".$nrdconta."</nrdconta>";
		$xmlHabilitaConvenio .= "   <nrconven>".$convenio."</nrconven>";
		$xmlHabilitaConvenio .= "   <insitceb>".$insitceb."</insitceb>";
		$xmlHabilitaConvenio .= "   <inarqcbr>".$inarqcbr."</inarqcbr>";
		$xmlHabilitaConvenio .= "   <cddemail>".$cddemail."</cddemail>";
		$xmlHabilitaConvenio .= "   <flgcruni>".($flgcruni == "yes" ? 1 : 0)."</flgcruni>";
		$xmlHabilitaConvenio .= "   <flgcebhm>".($flgcebhm == "yes" ? 1 : 0)."</flgcebhm>";
		$xmlHabilitaConvenio .= "   <dsdregis>".$dsdregis."</dsdregis>";
		$xmlHabilitaConvenio .= "   <idseqttl>1</idseqttl>";
		$xmlHabilitaConvenio .= "   <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
		$xmlHabilitaConvenio .= "   <flgregon>".$flgregon."</flgregon>";
		$xmlHabilitaConvenio .= "   <flgpgdiv>".$flgpgdiv."</flgpgdiv>";
		$xmlHabilitaConvenio .= "   <flcooexp>".$flcooexp."</flcooexp>";
		$xmlHabilitaConvenio .= "   <flceeexp>".$flceeexp."</flceeexp>";
		$xmlHabilitaConvenio .= "   <flserasa>".$flserasa."</flserasa>";
		$xmlHabilitaConvenio .= "   <qtdfloat>".$qtdfloat."</qtdfloat>";
		$xmlHabilitaConvenio .= "   <flprotes>".$flprotes."</flprotes>";
		$xmlHabilitaConvenio .= "   <insrvprt>".$insrvprt."</insrvprt>";
		$xmlHabilitaConvenio .= "   <qtlimaxp>".$qtlimaxp."</qtlimaxp>";
		$xmlHabilitaConvenio .= "   <qtlimmip>".$qtlimmip."</qtlimmip>";
		$xmlHabilitaConvenio .= "   <qtdecprz>".$qtdecprz."</qtdecprz>";
		$xmlHabilitaConvenio .= "   <idrecipr>".$idrecipr."</idrecipr>";
		$xmlHabilitaConvenio .= "   <idreciprold>".$idreciprold."</idreciprold>";
		$xmlHabilitaConvenio .= "   <perdesconto>".$perdesconto."</perdesconto>";
		$xmlHabilitaConvenio .= "   <inenvcob>".$inenvcob."</inenvcob>";	
		$xmlHabilitaConvenio .= "   <flgapihm>".($flgapihm == "yes" ? 1 : 0)."</flgapihm>";
		$xmlHabilitaConvenio .= " </Dados>";
		$xmlHabilitaConvenio .= "</Root>";

		$xmlResult = mensageria($xmlHabilitaConvenio, "TELA_ATENDA_COBRAN", "HABILITA_CONVENIO", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObjCarregaDados = getObjectXML($xmlResult);

		if (strtoupper($xmlObjCarregaDados->roottag->tags[0]->name) == 'ERRO') {
			exibirErro('error',utf8_encode($xmlObjCarregaDados->roottag->tags[0]->tags[0]->tags[4]->cdata),'Alerta - Ayllos','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
			exit;
		} 
	}

	echo 'hideMsgAguardo();';

	$xmlDados = $xmlObjCarregaDados->roottag->tags[0];
    $dsdmesag = getByTagName($xmlDados->tags,"DSDMESAG");
	$flgimpri = getByTagName($xmlDados->tags,"FLGIMPRI");

	if ($cddopcao == "A"){
		$opermail = "Alterar Convenio";
	}else{ 
		if ($cddopcao == "I"){
			$opermail = "Novo Convenio";
		}
	}

	$metodo = ($executandoProdutos == 'true') ? 'encerraRotina();' : 'acessaOpcaoContratos();';	

	if ($dsdmesag != "") {  // Se esta incluindo um novo e convenio CEB tem numeracao mostrar o numero 	
		echo 'showError("inform",
					    "'.$dsdmesag.'",
						"Alerta - Ayllos",
						"blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));'.($flgimpri == "1" ? "confirmaImpressao('".$flgregis."','');" : $metodo ).'");';
	}
	else
	if ($flgimpri == 1 || ((int)$flprotes && (int)$flprotes !== $flproalt)) {  // Se tem o PDF a mostrar entao chama fun��o para mostrar PDF do impresso gerado no browser
		echo 'confirmaImpressao("'.$flgregis.'","");';
	} 
	else {	
		echo $metodo;
	}
?>
