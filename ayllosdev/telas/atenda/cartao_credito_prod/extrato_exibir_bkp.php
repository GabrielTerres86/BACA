<?php 

	/************************************************************************
	    Fonte: extrato_exibir.php
	    Autor: Guilherme/Supero
	    Data : Agosto/2011      &Uacute;ltima Altera&ccedil;&atilde;o:   /  /

	    Objetivo  : Listar o Extrato do Cartao Cecred Visa

        Altera&ccedil;&otilde;es:
              

	  ************************************************************************/

	session_start();
	
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	

	// Verifica permissão
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"T")) <> "") {
		exibirErro('error',$msgError,'Alerta - Aimaro',$funcaoAposErro);
	}
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");

	// Se par&acirc;metros necess&aacute;rios n&atilde;o foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrcrcard"]) || !isset($_POST["dtextrat"])) {
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro',$funcaoAposErro);
	}

	$nrcrcard = $_POST["nrcrcard"];
	$nrdconta = $_POST["nrdconta"];
	$dtextrat = $_POST["dtextrat"];
	
	$dtperiod = $dtextrat;
	$dtextrat = explode("/",$dtextrat);
	$dtvctini = date("d/m/Y", mktime(0, 0, 0, $dtextrat[0], 1, $dtextrat[1])); // Primeiro dia do mes
    $dtvctfim = date("t/m/Y", mktime(0, 0, 0, $dtextrat[0], 1, $dtextrat[1])); // Ultimo dia do mes
	
	// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Monta o xml de requisição
	$xmlSetExtrato  = "";
	$xmlSetExtrato .= "<Root>";
	$xmlSetExtrato .= "	<Cabecalho>";
	$xmlSetExtrato .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlSetExtrato .= "		<Proc>extrato_cartao_bradesco</Proc>";
	$xmlSetExtrato .= "	</Cabecalho>";
	$xmlSetExtrato .= "	<Dados>";
	$xmlSetExtrato .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetExtrato .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSetExtrato .= "		<nrcrcard>".$nrcrcard."</nrcrcard>";
	$xmlSetExtrato .= "		<dtvctini>".$dtvctini."</dtvctini>";
	$xmlSetExtrato .= "		<dtvctfim>".$dtvctfim."</dtvctfim>";
	$xmlSetExtrato .= "	</Dados>";
	$xmlSetExtrato .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetExtrato);

	// Cria objeto para classe de tratamento de XML
	$xmlObjExtrato = getObjectXML($xmlResult);
	
	//print_r($xmlObjExtrato);

	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjExtrato->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjExtrato->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 

	// Seta a tag de lancamentos para a variavel
	$lancamentos = $xmlObjExtrato->roottag->tags[0]->tags[0]->tags;
	
	//print_r($lancamentos);

	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) {
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
	$nmprimtl     = getByTagName($lancamentos,"nmprimtl");
	$nmtitcrd     = getByTagName($lancamentos,"nmtitcrd");
	$vllimite     = getByTagName($lancamentos,"vllimite");
	$tot_vlcrdolr = 0;
	$tot_vldbdolr = 0;
	$tot_vlcrreal = 0;
	$tot_vldbreal = 0;
	
	echo "VARS: " . $nmprimtl . " " . $nmtitcrd . " " . $vllimite;
?>
