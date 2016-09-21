<?php 

	/************************************************************************  
	  Fonte: imprimir_relatorio.php                                             
	  Autor: Guilherme/Supero
	  Data : Junho/2012                   �ltima Altera��o: 00/00/0000

	  Objetivo  : Carregar dados para impress�es dos relat�rios de aplica��es


	  Altera��es: 

	************************************************************************/ 

	session_cache_limiter("private");
	session_start();

	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	

	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	// Verifica permiss�o
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"M")) <> "") {
		?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
		exit();
	}

	// Verifica se o n�mero da conta foi informado
	if (!isset($_POST["nrdconta"]) ||
        !isset($_POST["tpmodelo"]) ||
		!isset($_POST["dtiniper"]) ||
        !isset($_POST["dtfimper"]) ||
		!isset($_POST["tprelato"]) ||
		!isset($_POST["tpaplic2"])) {
		?><script language="javascript">alert('Par�metros incorretos.');</script><?php
		exit();
	}
    
    $nrdconta = $_POST["nrdconta"];	
	$tpmodelo = $_POST["tpmodelo"];	
	$dtparini = $_POST["dtiniper"];
	$dtparfim = $_POST["dtfimper"];
	$tprelato = $_POST["tprelato"];
	$tpaplic2 = $_POST["tpaplic2"];

	$dtiniper = $dtparini;
	$dtextini = explode("/",$dtiniper);

    $dtfimper = $dtparfim;
    $dtextfim = explode("/",$dtfimper);

	$dtvctini = date("d/m/Y", mktime(0, 0, 0, $dtextini[0], 1, $dtextini[1])); // Primeiro data do mes
    $dtvctfim = date("d/m/Y", mktime(0, 0, 0, $dtextfim[0], 1, $dtextfim[1])); // Primeiro data do mes


	// Monta o xml de requisi��o
	$xmlDadosImpres  = "";
	$xmlDadosImpres .= "<Root>";
	$xmlDadosImpres .= "	<Cabecalho>";
	$xmlDadosImpres .= "		<Bo>b1wgen0112.p</Bo>";
    $xmlDadosImpres .= "		<Proc>Gera_Impressao_Aplicacao</Proc>";
	$xmlDadosImpres .= "	</Cabecalho>";
	$xmlDadosImpres .= "	<Dados>";
	$xmlDadosImpres .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
    $xmlDadosImpres .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
    $xmlDadosImpres .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
    $xmlDadosImpres .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
    $xmlDadosImpres .= "		<nmdatela>IMPRES</nmdatela>";
	$xmlDadosImpres .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlDadosImpres .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
    $xmlDadosImpres .= "		<dtvctfim>".$dtvctfim."</dtvctfim>";
    $xmlDadosImpres .= "		<cdprogra>IMPRES</cdprogra>";
	$xmlDadosImpres .= '		<inproces>'.$glbvars['inproces'].'</inproces>';
	$xmlDadosImpres .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
    $xmlDadosImpres .= "		<idseqttl>1</idseqttl>"; 
	$xmlDadosImpres .= "		<dsiduser>".session_id().getmypid()."</dsiduser>";
    $xmlDadosImpres .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlDadosImpres .= "		<tpmodelo>".$tpmodelo."</tpmodelo>"; // Demonstrativo/Sintetico/Analitico
	$xmlDadosImpres .= "		<dtvctini>".$dtvctini."</dtvctini>";
	$xmlDadosImpres .= "		<tprelato>".$tprelato."</tprelato>"; // Especifico/Todos/Com Saldo/Sem Saldo
	$xmlDadosImpres .= "		<nraplica>".$tpaplic2."</nraplica>"; // Nr da Aplicacao
    
	$xmlDadosImpres .= "		<idimpres>".$idimpres."</idimpres>";
	$xmlDadosImpres .= "	</Dados>";
	$xmlDadosImpres .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlDadosImpres);

	// Cria objeto para classe de tratamento de XML
	$xmlObjDadosImpres = getObjectXML($xmlResult);

    // Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjDadosImpres->roottag->tags[0]->name) == "ERRO") {
		$msg = $xmlObjDadosImpres->roottag->tags[0]->tags[0]->tags[4]->cdata;
		?>
		<script language="javascript">
			alert('<?php echo $msg; ?>'); 
			window.close();
		</script>
		<?php
		exit();
	}

	// Obt�m nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
	$nmarqpdf = $xmlObjDadosImpres->roottag->tags[0]->attributes["NMARQPDF"];

    //var_dump($xmlObjDadosImpres);
    
    
	// Chama fun��o para mostrar PDF do impresso gerado no browser
	visualizaPDF($nmarqpdf);
    
?>