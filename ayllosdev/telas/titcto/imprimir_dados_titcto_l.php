<?php 

/************************************************************************  
	  Fonte: imprimir_dados_titcto.php                                             
	  Autor: Alex Sandro                                                         
	  Data : Março/2018                      Última Alteração: 13/13/2018
	                                                                           
	  Objetivo  : Carregar dados para impressões da opção lote da tela titcto       
	

	************************************************************************/ 
	session_cache_limiter("private");
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();

	
	

	// Verifica permissão
	if (($msgError = validaPermissao($glbvars['nmdatela'], $glbvars['nmrotina'], "L")) <> '') {
	    exibirErro('error', $msgError, 'Alerta - Ayllos', '', false);
	}	

	// Verifica se parâmetros necessários foram informados
	if (!isset($_POST["dtvencto"]) || 
		!isset($_POST["cdagenci"])) {
	?>

		<script language="javascript">alert('Parâmetros incorretos.');</script>
	<?php
		exit();
	}	

	$dtmvtolt = $_POST["dtvencto"];
	$cdagenci = $_POST["cdagenci"];
  	$dsiduser = session_id();	

	

    $xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <dtmvtolt>".$dtmvtolt."</dtmvtolt>";
    $xml .= "   <cdagenci>".$cdagenci."</cdagenci>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "TITCTO", "TITCTO_LOTE_IMPRESSAO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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