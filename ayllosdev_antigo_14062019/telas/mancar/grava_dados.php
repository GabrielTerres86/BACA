<?php
	/*************************************************************************
	  Fonte: grava_dados.php                                               
	  Autor: André Clemer
	  Data : Abril/2018                       Última Alteração: --/--/----
	                                                                   
	  Objetivo  : Grava os dados.
	                                                                 
	  Alterações: 
	                                                                  
	***********************************************************************/

	session_start();

	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	

	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");

	$cddopcao   = (($_POST['cddopcao']) ? $_POST['cddopcao'] : 'A');
	$nmdeacao   = 'MANCAR_ATUALIZA';

	$idcartorio = $_POST['idcartorio'];
	$nrcpf_cnpj = $_POST['nrcpf_cnpj'];
	$nmcartorio = $_POST['nmcartorio'];
    $idcidade 	= $_POST['idcidade'];
	$flgativo 	= $_POST['flgativo'];

    $dsmensag = 'Parâmetros alterados com sucesso!';

	// Montar o xml de Requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "	<idcartorio>".$idcartorio."</idcartorio>";
	if ($cddopcao != 'E') {
		$xml .= "	<nrcpf_cnpj>".$nrcpf_cnpj."</nrcpf_cnpj>";
		$xml .= "	<nmcartorio>".$nmcartorio."</nmcartorio>";
		$xml .= "	<idcidade>".$idcidade."</idcidade>";
		$xml .= "	<flgativo>".$flgativo."</flgativo>";
	} else {
		$nmdeacao = 'MANCAR_EXCLUI';
	}
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "MANCAR", $nmdeacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);

	echo 'hideMsgAguardo();';

	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObj->roottag->tags[0]->cdata,'Alerta - Ayllos',"bloqueiaFundo($('#divRotina'));",false);
	}

    echo "showError('inform','".$dsmensag."','ManCar','fechaRotina($(\'#divRotina\'));estadoInicial();');";
?>