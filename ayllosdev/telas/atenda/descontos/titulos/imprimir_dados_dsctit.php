<?php 

	/************************************************************************  
	  Fonte: imprimir_dados_dsctit.php                                             
	  Autor: Guilherme                                                         
	  Data : Mar�o/2009                      �ltima Altera��o: 12/09/2016
	                                                                           
	  Objetivo  : Carregar dados para impress�es de desconto de titulos       
	
	  Altera��es: 11/06/2010 - Adaptar para novo RATING (David).    

                  22/09/2010 - Ajuste para enviar impressoes via email para 
				               o PAC Sede (David).

				  12/07/2012 - Alterado parametro de $pdf->Output,     
							   Condicao para Navegador Chrome (Jorge).
							   
				  20/08/2012 - Unifica��o de impress�es na BO30i, chamada da
							   procedure 'carrega-impressao-dsctit' (Lucas).
							   
				  12/09/2016 - Alteracao para chamar a rotina do Oracle na
							   geracao da impressao. (Jaison/Daniel)

	************************************************************************/ 

	session_cache_limiter("private");
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");		
	require_once("../../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");
	
	// Verifica permiss�o
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"M")) <> "") {
		?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
		exit();
	}	

	// Verifica se par�metros necess�rios foram informados
	if (!isset($_POST["nrdconta"]) || 
		!isset($_POST["nrctrlim"]) || 
		!isset($_POST["nrborder"]) ||
		!isset($_POST["limorbor"]) ||
		!isset($_POST["idimpres"]) ||
		!isset($_POST["flgemail"])) {
		?><script language="javascript">alert('Par&acirc;metros incorretos.');</script><?php
		exit();
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrctrlim = $_POST["nrctrlim"];
	$nrborder = $_POST["nrborder"];
	$idimpres = $_POST["idimpres"];
	$limorbor = $_POST["limorbor"];
	$flgemail = $_POST["flgemail"];

	// Verifica se o n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		?><script language="javascript">alert('Conta/dv inv&aacute;lida.');</script><?php
		exit();
	}
	
	// Verifica se n�mero do contrato � um inteiro v�lido
	if (!validaInteiro($nrctrlim)) {
		?><script language="javascript">alert('Contrato inv&aacute;lido.');</script><?php
		exit();
	}
	
	// Verifica se n�mero do bordero � um inteiro v�lido
	if ((!validaInteiro($nrborder)) && ($nrborder != "")) {
		?><script language="javascript">alert('Bordero inv&aacute;lido.');</script><?php
		exit();
	}	
	
	// Verifica se identificador de impress�o � um inteiro v�lido
	if (!validaInteiro($idimpres)) {
		?><script language="javascript">alert('Identificador de impress&atilde;o inv&aacute;lido.');</script><?php
		exit();
	}		
	
	// Verifica se flag para envio de email � v�lida
	if ($flgemail <> "yes" && $flgemail <> "no") {
		?><script language="javascript">alert('Identificador de envio de e-mail inv&aacute;lido.');</script><?php
		exit();
	}
	
	// Verifica se identificador de impress�o � um inteiro v�lido
	if (!validaInteiro($limorbor)) {
		?><script language="javascript">alert('Identificador de tipo de impress&atilde;o inv&aacute;lido.');</script><?php
		exit();
	}	
	
    if ($idimpres == 1 || // COMPLETA
        $idimpres == 2 || // CONTRATO
        $idimpres == 4 || // NOTA PROMISSORIA
        $idimpres == 7) { // BORDERO DE CHEQUES
        $xml  = "<Root>";
        $xml .= "  <Dados>";
        $xml .= "    <nrdconta>".$nrdconta."</nrdconta>";
        $xml .= "    <idseqttl>1</idseqttl>";
        $xml .= "    <idimpres>".$idimpres."</idimpres>";
        $xml .= "    <tpctrlim>3</tpctrlim>"; // 3-Titulo
        $xml .= "    <nrctrlim>".$nrctrlim."</nrctrlim>";
        $xml .= "    <nrborder>".$nrborder."</nrborder>";
        $xml .= "    <dsiduser>".$dsiduser."</dsiduser>";
        $xml .= "    <flgemail>".($flgemail == 'yes' ? 1 : 0)."</flgemail>";
        $xml .= "    <flgerlog>0</flgerlog>";
        $xml .= "  </Dados>";
        $xml .= "</Root>";

        $xmlResult = mensageria($xml, "ATENDA", "DESC_IMPRESSAO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObject = getObjectXML($xmlResult);

        if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO") {
			$msg = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
			?><script language="javascript">alert('<?php echo $msg; ?>');</script><?php
			exit();
		}

        // Obt�m nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
        $nmarqpdf = $xmlObject->roottag->tags[0]->tags[0]->cdata;

        // Chama fun��o para mostrar PDF do impresso gerado no browser
        visualizaPDF($nmarqpdf);

    } else {
	
	$nmproced = "carrega-impressao-dsctit";	
	$dsiduser = session_id();	
	
	// Monta o xml de requisi��o
	$xmlDadosImpres  = "";
	$xmlDadosImpres .= "<Root>";
	$xmlDadosImpres .= "	<Cabecalho>";
	$xmlDadosImpres .= "		<Bo>b1wgen0030.p</Bo>";
	$xmlDadosImpres .= "		<Proc>".$nmproced."</Proc>";
	$xmlDadosImpres .= "	</Cabecalho>";
	$xmlDadosImpres .= "	<Dados>";
	$xmlDadosImpres .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlDadosImpres .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlDadosImpres .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlDadosImpres .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlDadosImpres .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlDadosImpres .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlDadosImpres .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlDadosImpres .= "		<idseqttl>1</idseqttl>";
	$xmlDadosImpres .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlDadosImpres .= "		<dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";
	$xmlDadosImpres .= "		<inproces>".$glbvars["inproces"]."</inproces>";
	$xmlDadosImpres .= "		<idimpres>".$idimpres."</idimpres>";
	$xmlDadosImpres .= "		<nrctrlim>".$nrctrlim."</nrctrlim>";
	$xmlDadosImpres .= "		<nrborder>".$nrborder."</nrborder>";
	$xmlDadosImpres .= "		<limorbor>".$limorbor."</limorbor>";	
	$xmlDadosImpres .= "		<dsiduser>".$dsiduser."</dsiduser>";
	$xmlDadosImpres .= "		<flgemail>".$flgemail."</flgemail>";
	$xmlDadosImpres .= "	</Dados>";
	$xmlDadosImpres .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlDadosImpres);

	// Cria objeto para classe de tratamento de XML
	$xmlObjDadosImpres = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjDadosImpres->roottag->tags[0]->name) == "ERRO") {
		$msg = $xmlObjDadosImpres->roottag->tags[0]->tags[0]->tags[4]->cdata;
		?><script language="javascript">alert('<?php echo $msg; ?>');</script><?php
		exit();
	} 
	
	// Obt�m nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
	$nmarqpdf = $xmlObjDadosImpres->roottag->tags[0]->attributes["NMARQPDF"];
		
	// Chama fun��o para mostrar PDF do impresso gerado no browser
	visualizaPDF($nmarqpdf);
    }
?>