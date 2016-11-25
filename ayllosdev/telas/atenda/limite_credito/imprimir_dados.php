<?php 

	/***************************************************************************
		Fonte: imprimir_dados.php                                       
		Autor: David                                                     
		Data : Abril/2008                   Última Alteração: 07/05/2015 
																		
		Objetivo  : Carregar dados para impressões do limite de crédito 
	                                                                 	 
	    Alterações: 16/04/2010 - Adaptar para novo RATING (David).       
	                                                                 	 
	                16/09/2010 - Ajuste para enviar impressoes via email 
	                             para o PAC Sede (David).                
																	 
	   			    18/07/2014 - Ajustes referentes ao Projeto CET	  
				  			    (Lucas R.)							   
								
					07/05/2015 - Consultas automatizadas (Gabriel-RKAM).		
					
					07/11/2016 - Ajustes referente projeto 314 (Daniel)	
	**************************************************************************/
	
	session_cache_limiter("private");
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"I")) <> "") {
		?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
		exit();	
	}	

	// Verifica se parâmetros necessários foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrctrlim"]) || !isset($_POST["idimpres"]) || !isset($_POST["flgemail"]) || !isset($_POST["flgimpnp"])) {
		?><script language="javascript">alert('Par&acirc;metros incorretos.');</script><?php
		exit();
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrctrlim = $_POST["nrctrlim"];
	$idimpres = $_POST["idimpres"];
	$flgemail = $_POST["flgemail"];
	$flgimpnp = $_POST["flgimpnp"];

	$dsiduser = session_id();

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		?><script language="javascript">alert('Conta/dv inv&aacute;lida.');</script><?php
		exit();
	}
	
	// Verifica se número do contrato é um inteiro válido
	if (!validaInteiro($nrctrlim)) {
		?><script language="javascript">alert('Contrato inv&aacute;lido.');</script><?php
		exit();
	}
	
	// Verifica se identificador de impressão é um inteiro válido
	if (!validaInteiro($idimpres)) {
		?><script language="javascript">alert('Identificador de impress&atilde;o inv&aacute;lido.');</script><?php
		exit();
	}		
	
	// Verifica se flag para envio de email é válida
	if ($flgemail <> "yes" && $flgemail <> "no") {
		?><script language="javascript">alert('Identificador de envio de e-mail inv&aacute;lido.');</script><?php
		exit();
	}
	
	// Verifica se flag para impressão da nota promissória é válida
	if ($flgimpnp <> "yes" && $flgimpnp <> "no") {
		?><script language="javascript">alert('Identificador de nota promissória inv&aacute;lido.');</script><?php
		exit();
	}
	
    if ($idimpres == 1 || $idimpres == 2) {
        
        $xml  = "<Root>";
        $xml .= "  <Dados>";
        $xml .= "    <nrdconta>".$nrdconta."</nrdconta>";
        $xml .= "    <idseqttl>1</idseqttl>";
        $xml .= "    <idimpres>".$idimpres."</idimpres>";
        $xml .= "    <nrctrlim>".$nrctrlim."</nrctrlim>";
        $xml .= "    <dsiduser>".$dsiduser."</dsiduser>";
        $xml .= "    <flgimpnp>".($flgimpnp == 'yes' ? 1 : 0)."</flgimpnp>";
        $xml .= "    <flgemail>".($flgemail == 'yes' ? 1 : 0)."</flgemail>";
        $xml .= "  </Dados>";
        $xml .= "</Root>";
        
        $xmlResult = mensageria($xml, "ATENDA", "IMPRES_CTRLIMCRED", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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


        
    }else {
    
	$procedure = ($idimpres == 7) ? 'Imprime_Consulta' : 'gera-impressao-limite';
	$bo        = ($idimpres == 7) ? 'b1wgen0191.p'     : 'b1wgen0019.p';
	
	// Monta o xml de requisição
	$xmlImpressao  = "";
	$xmlImpressao .= "<Root>";
	$xmlImpressao .= "	<Cabecalho>";
	$xmlImpressao .= "		<Bo>".$bo."</Bo>";
	$xmlImpressao .= "		<Proc>".$procedure ."</Proc>";
	$xmlImpressao .= "	</Cabecalho>";
	$xmlImpressao .= "	<Dados>";
	$xmlImpressao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlImpressao .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlImpressao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlImpressao .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlImpressao .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlImpressao .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlImpressao .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlImpressao .= "		<inprodut>3</inprodut>";
	$xmlImpressao .= "		<idseqttl>1</idseqttl>";
	$xmlImpressao .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlImpressao .= "		<dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";
	$xmlImpressao .= "		<inproces>".$glbvars["inproces"]."</inproces>";
	$xmlImpressao .= "		<idimpres>".$idimpres."</idimpres>";
	$xmlImpressao .= "		<nrctrlim>".$nrctrlim."</nrctrlim>";
	$xmlImpressao .= "		<nrctrato>".$nrctrlim."</nrctrato>";
	$xmlImpressao .= "		<flgimpnp>".$flgimpnp."</flgimpnp>";
	$xmlImpressao .= "		<dsiduser>".$dsiduser."</dsiduser>";
	$xmlImpressao .= "		<flgemail>".$flgemail."</flgemail>";
	$xmlImpressao .= "	</Dados>";
	$xmlImpressao .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlImpressao);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjDadosImpres = getObjectXML($xmlResult);
	
		// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjDadosImpres->roottag->tags[0]->name) == "ERRO") {
		$msg = $xmlObjDadosImpres->roottag->tags[0]->tags[0]->tags[4]->cdata;
		?><script language="javascript">alert('<?php echo $msg; ?>');</script><?php
		exit();
	} 
	
	// Obtém nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
	$nmarqpdf = $xmlObjDadosImpres->roottag->tags[0]->attributes["NMARQPDF"];
	
	// Chama função para mostrar PDF do impresso gerado no browser
	visualizaPDF($nmarqpdf);
    }
?>