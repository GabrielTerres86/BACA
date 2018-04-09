<?php 

/************************************************************************  
	  Fonte: imprimir_dados_titcto_b.php                                             
	  Autor: Alex Sandro                                                         
	  Data : Abril/2018                      Última Alteração: 09/04/2018
	                                                                           
	  Objetivo  : Carregar dados para impressões da opção de borderos não liberados da tela titcto       
	

	************************************************************************/ 
	session_cache_limiter("private");
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();

	
	

	// Verifica permissão
	if (($msgError = validaPermissao($glbvars['nmdatela'], $glbvars['nmrotina'], $cddopcao)) <> '') {
	    exibirErro('error', $msgError, 'Alerta - Ayllos', '', false);
	}	

	// Verifica se parâmetros necessários foram informados
	if (!isset($_POST["dtiniper"]) || 
		!isset($_POST["dtfimper"]) ||
		!isset($_POST["cdagenci"]) ||
		!isset($_POST["nrdconta"]) ||
		!isset($_POST["nrborder"])) {
	?>

		<script language="javascript">alert('Parâmetros incorretos.');</script>
	<?php
		exit();
	}	

	$dtiniper = $_POST["dtiniper"];
	$dtfimper = $_POST["dtfimper"];
	$cdagenci = $_POST["cdagenci"];
	$nrdconta = $_POST["nrdconta"];
	$nrborder = $_POST["nrborder"];

  	$dsiduser = session_id();	

	

    $xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <dtiniper>".$dtiniper."</dtiniper>";
    $xml .= "   <dtfimper>".$dtfimper."</dtfimper>";
    $xml .= "   <cdagenci>".$cdagenci."</cdagenci>";
    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
    $xml .= "   <nrborder>".$nrborder."</nrborder>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "TITCTO", "TITCTO_BORDERO_N_LIBERADO_IMPRESSAO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObject = getObjectXML($xmlResult);

    if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO") {
		$msg = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
		?><script language="javascript">alert('<?php echo $msg; ?>');</script><?php
		exit();
	}

    // Obtém nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
    $nmarqpdf = $xmlObject->roottag->tags[0]->tags[0]->cdata;

    // Chama função para mostrar PDF do impresso gerado no browser
    visualizaPDF($nmarqpdf);

    
?>