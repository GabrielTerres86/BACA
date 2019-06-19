<?php 

	/************************************************************************
	  Fonte: obtem_saldos.php
	  Autor: Guilherme
	  Data : Fevereiro/2008                    Última Alteração: 06/02/2019

	  Objetivo  : Mostrar Saldos da rotina dep.vista tela ATENDA

	  Alterações: 02/09/2010 - Ajustes para nova procedure (David).
				  03/07/2013 - Incluir echo de vlblqjud (Lucas R.)
				  11/07/2017 - Novo campo Limite Pre Aprovado Disponivel na tela Saldos Anteriores, Melhoria M441. ( Mateus Zimmermann/MoutS )
				  06/02/2019 - P442 - Remoção de informações de Pre-Aprovado da tela (Marcos-Envolti)

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
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["dtrefere"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$dtrefere = $_POST["dtrefere"];   

	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se data do saldo anterior é válida
	if (!validaData($dtrefere)) {
		exibeErro("Data de pesquisa inv&aacute;lida.");
	}
			
	// Monta o xml de requisição
	$xmlGetDepVista  = "";
	$xmlGetDepVista .= "<Root>";
	$xmlGetDepVista .= "	<Cabecalho>";
	$xmlGetDepVista .= "		<Bo>b1wgen0001.p</Bo>";
	$xmlGetDepVista .= "		<Proc>obtem-saldos-anteriores</Proc>";
	$xmlGetDepVista .= "	</Cabecalho>";
	$xmlGetDepVista .= "	<Dados>";
	$xmlGetDepVista .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetDepVista .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetDepVista .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetDepVista .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetDepVista .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetDepVista .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlGetDepVista .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetDepVista .= "		<idseqttl>1</idseqttl>";
	$xmlGetDepVista .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";	
	$xmlGetDepVista .= "		<dtmvtolt>".$glbvars["dtmvtoan"]."</dtmvtolt>";	
	$xmlGetDepVista .= "		<dtrefere>".$dtrefere."</dtrefere>";	
	$xmlGetDepVista .= "	</Dados>";
	$xmlGetDepVista .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetDepVista);

	// Cria objeto para classe de tratamento de XML
	$xmlGetDepVista = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlGetDepVista->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlGetDepVista->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}

	$depvista = $xmlGetDepVista->roottag->tags[0]->tags[0]->tags;
		
	// Mostrar dados da busca
	echo '$("#vlsddisp","#frmSaldoAnt").val("'.number_format(str_replace(",",".",getByTagName($depvista,'vlsddisp')),2,",",".").'");';
	echo '$("#vlsdchsl","#frmSaldoAnt").val("'.number_format(str_replace(",",".",getByTagName($depvista,'vlsdchsl')),2,",",".").'");';
	echo '$("#vlsdbloq","#frmSaldoAnt").val("'.number_format(str_replace(",",".",getByTagName($depvista,'vlsdbloq')),2,",",".").'");';
	echo '$("#vlsdblpr","#frmSaldoAnt").val("'.number_format(str_replace(",",".",getByTagName($depvista,'vlsdblpr')),2,",",".").'");';
	echo '$("#vlsdblfp","#frmSaldoAnt").val("'.number_format(str_replace(",",".",getByTagName($depvista,'vlsdblfp')),2,",",".").'");';			
	echo '$("#vlsdindi","#frmSaldoAnt").val("'.number_format(str_replace(",",".",getByTagName($depvista,'vlsdindi')),2,",",".").'");';
	echo '$("#vllimcre","#frmSaldoAnt").val("'.number_format(str_replace(",",".",getByTagName($depvista,'vllimcre')),2,",",".").'");';
	echo '$("#vlstotal","#frmSaldoAnt").val("'.number_format(str_replace(",",".",getByTagName($depvista,'vlstotal')),2,",",".").'");';			
	echo '$("#vlblqjud","#frmSaldoAnt").val("'.number_format(str_replace(",",".",getByTagName($depvista,'vlblqjud')),2,",",".").'");';

  	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}

?>
