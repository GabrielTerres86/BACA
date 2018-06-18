<?php
//*********************************************************************************************//
//*** Fonte: retorna_aplicacoes.php                                    						          ***//
//*** Autor: Rafael B. Arins - Envolti                                           						***//
//*** Data : Abril/2018                  Última Alteração: --/--/----  					            ***//
//***                                                                  						          ***//
//*** Objetivo  : Retorna as Aplicação disponiveis para o cooperado e 					            ***//
//***             cooperativa selecionada.                             						          ***//
//*** Alterações: 																			                                    ***//
//*********************************************************************************************//

	session_start();

	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();

	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");

	/*
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		exibeErro($msgError);
	}*/

	// Verifica se número da conta foi informado
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}

	if (!isset($_POST['cdcooper'])) {
		exibeErro("Par&acirc;metros incorretos.");
	}

	$cdcooper = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : '';
	$nrdconta = $_POST["nrdconta"];

	// Verifica se número da conta é um inteiro válido
	if (!isset($nrdconta) || !validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}

	// Montar o xml de Requisicao
	$xml = '';
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <idseqttl>1</idseqttl>";
	$xml .= "   <nraplica>0</nraplica>";
    $xml .= "   <cdprodut>0</cdprodut>";
    $xml .= "   <idconsul>6</idconsul>";
	$xml .= "   <idgerlog>1</idgerlog>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "ATENDA", "LISAPLI", $cdcooper, $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	//$xmlObjAplicacoes = getObjectXML($xmlResult);

	// Cria objeto para classe de tratamento de XML
	$xmlObjAplicacoes = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra crítica
	if (isset($xmlObjAplicacoes->roottag->tags[0]->name) && strtoupper($xmlObjAplicacoes->roottag->tags[0]->name) == "ERRO") {

		$msgErro = ( isset($xmlObjAplicacoes->roottag->tags[0]->cdata) ) ? $xmlObjAplicacoes->roottag->tags[0]->cdata : '';
		if($msgErro == null || $msgErro == ''){
			$msgErro = ( isset($xmlObjAplicacoes->roottag->tags[0]->tags[0]->tags[4]->cdata) ) ? $xmlObjAplicacoes->roottag->tags[0]->tags[0]->tags[4]->cdata : '';
			echo json_encode($msgErro);
		}

		exibeErro($msgErro);
	}
	$aplicacoes = $xmlObjAplicacoes->roottag->tags;

?>
	<?php
	echo '<option value="0">Todas</option>';
		foreach ($aplicacoes as $aplicacao) {
			$NRAPLICA = $aplicacao->tags[1]->cdata;
			$DSAPLICA = $aplicacao->tags[18]->cdata;
			$IDTIPAPL = $aplicacao->tags[16]->cdata;
			$TPAPLICA = $aplicacao->tags[29]->cdata;

			echo '<option value="',$IDTIPAPL,'_',$TPAPLICA,'_',$NRAPLICA,'">',$NRAPLICA,' - ',$DSAPLICA,'</option>';
		}
	?>
