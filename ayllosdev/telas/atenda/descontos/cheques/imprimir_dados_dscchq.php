<?php 

	/************************************************************************  
	  Fonte: imprimir_dados_dscchq.php                                             
	  Autor: Guilherme                                                         
	  Data : Mar�o/2009                   �ltima Altera��o: 12/07/2012
																			
	  Objetivo  : Carregar dados para impress&otilde;es de desconto de cheques       
																				 
	  Altera��es: 14/06/2010 - Adaptar para novo RATING (David). 

                  21/09/2010 - Ajuste para enviar impressoes via email para 
				               o PAC Sede (David).

				  12/07/2012 - Alterado parametro de $pdf->Output,     
							   Condicao para Navegador Chrome (Jorge).
							   
				  23/07/2014 - Ajustes para imprimir o contrato do cet (Lucas R./Gielow - Projeto Cet)
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

	// Verifica se o n�mero da conta foi informado
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
	
	// Verifica se n�mero da conta � um inteiro v�lido
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
	
	// Verifica se identificador de tipo de impress�o � um inteiro v�lido
	if (!validaInteiro($limorbor)) {
		?><script language="javascript">alert('Identificador de tipo de impress&atilde;o inv&aacute;lido.');</script><?php
		exit();
	}	

	if ($idimpres <= 4 || $idimpres == 9) { 
	    $nmproced = "gera-impressao-limite"; 
	}else{
		$nmproced = "busca_dados_impressao_dscchq";
	}
	
	$dsiduser = session_id();	
	
	// Monta o xml de requisi��o
	$xmlDadosImpres  = "";
	$xmlDadosImpres .= "<Root>";
	$xmlDadosImpres .= "	<Cabecalho>";
	$xmlDadosImpres .= "		<Bo>b1wgen0009.p</Bo>";
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
	
	if ($idimpres <= 4 || $idimpres == 9) { // Impress�es do limite
		// Obt�m nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
		$nmarqpdf = $xmlObjDadosImpres->roottag->tags[0]->attributes["NMARQPDF"];
		
		// Chama fun��o para mostrar PDF do impresso gerado no browser
		visualizaPDF($nmarqpdf);
	} else { // Impress�es do bordero
		// Armazena dados para impress�es
		$xmlTagsEmpresti = $xmlObjDadosImpres->roottag->tags[0]->tags; // Dados de empr�stimo
		$xmlTagsPropLimi = $xmlObjDadosImpres->roottag->tags[1]->tags; // Dados da proposta de limite
		$xmlTagsCtrLimit = $xmlObjDadosImpres->roottag->tags[2]->tags; // Dados do contrato de limite
		$xmlTagsAvalista = $xmlObjDadosImpres->roottag->tags[3]->tags; // Dados dos Avalistas
		$xmlTagsNotaProm = $xmlObjDadosImpres->roottag->tags[4]->tags; // Dados para nota promiss�ria
		$xmlTagsPropBord = $xmlObjDadosImpres->roottag->tags[5]->tags; // Dados da proposta de bordero
		$xmlTagsCabecTit = $xmlObjDadosImpres->roottag->tags[6]->tags; // Dados para os cheques do bordero
		$xmlTagsTitsBord = $xmlObjDadosImpres->roottag->tags[7]->tags; // Dados dos cheques do bordero
		$xmlTagsTBRestri = $xmlObjDadosImpres->roottag->tags[8]->tags; // Dados das restri��es dos cheques do bordero
		$xmlTagsSacadNPg = $xmlObjDadosImpres->roottag->tags[9]->tags; // Dados do sacado que n�o pagou

		// Armazena dados de empr�stimo em array
		if (count($xmlTagsEmpresti) > 0) {	
			for ($i = 0; $i < count($xmlTagsEmpresti); $i++) {
				$xmlTags = $xmlTagsEmpresti[$i]->tags;
			
				for ($j = 0; $j < count($xmlTags); $j++) {
					$dadosEmpresti[$i][$xmlTags[$j]->name] = $xmlTags[$j]->cdata;
				}
			}
			
			$dadosImpressos["EMPRESTI"] = $dadosEmpresti;
		}

		// Armazena dados da proposta de limite em array
		if (count($xmlTagsPropLimi) > 0) {	
			$xmlTags = $xmlTagsPropLimi[0]->tags;
			
			for ($i = 0; $i < count($xmlTags); $i++) {
				$dadosPropLimi[$xmlTags[$i]->name] = $xmlTags[$i]->cdata;
			}
			
			$dadosImpressos["PROPLIMI"] = $dadosPropLimi;
		}	
		
		// Armazena dados do contrato de limite em array
		if (count($xmlTagsCtrLimit) > 0) {	
			$xmlTags = $xmlTagsCtrLimit[0]->tags;
			
			for ($i = 0; $i < count($xmlTags); $i++) {
				$dadosCtrLimit[$xmlTags[$i]->name] = $xmlTags[$i]->cdata;
			}
			
			$dadosImpressos["CTRLIMIT"] = $dadosCtrLimit;
		}

		// Armazena dados dos avalistas em array
		if (count($xmlTagsAvalista) > 0) {			
			for ($i = 0; $i < count($xmlTagsAvalista); $i++) {
				$xmlTags = $xmlTagsAvalista[$i]->tags;
			
				for ($j = 0; $j < count($xmlTags); $j++) {
					$dadosAvalista[$i][$xmlTags[$j]->name] = $xmlTags[$j]->cdata;
				}
			}
			
			$dadosImpressos["AVALISTA"] = $dadosAvalista;
		}		

		// Armazena dados da nota promiss�ria em array
		if (count($xmlTagsNotaProm) > 0) {	
			$xmlTags = $xmlTagsNotaProm[0]->tags;
			
			for ($i = 0; $i < count($xmlTags); $i++) {
				$dadosNotaProm[$xmlTags[$i]->name] = $xmlTags[$i]->cdata;
			}
			
			$dadosImpressos["NOTAPROM"] = $dadosNotaProm;
		}
		
		// Armazena dados da proposta de bordero em array
		if (count($xmlTagsPropBord) > 0) {	
			$xmlTags = $xmlTagsPropBord[0]->tags;
			
			for ($i = 0; $i < count($xmlTags); $i++) {
				$dadosPropBord[$xmlTags[$i]->name] = $xmlTags[$i]->cdata;
			}
			
			$dadosImpressos["PROPBORD"] = $dadosPropBord;
		}	
		
		// Armazena dados dos cheques do bordero em array
		if (count($xmlTagsCabecTit) > 0) {	
			$xmlTags = $xmlTagsCabecTit[0]->tags;
			
			for ($i = 0; $i < count($xmlTags); $i++) {
				$dadosCabecTit[$xmlTags[$i]->name] = $xmlTags[$i]->cdata;
			}
			
			$dadosImpressos["CABECTIT"] = $dadosCabecTit;
		}
		
		// Armazena dados dos cheques do bordero em array
		if (count($xmlTagsTitsBord) > 0) {	
			for ($i = 0; $i < count($xmlTagsTitsBord); $i++) {
				$xmlTags = $xmlTagsTitsBord[$i]->tags;
			
				for ($j = 0; $j < count($xmlTags); $j++) {
					$dadosTitsBord[$i][$xmlTags[$j]->name] = $xmlTags[$j]->cdata;
				}
			}
			
			$dadosImpressos["TITSBORD"] = $dadosTitsBord;
		}	
		
		// Armazena dados as restri��es dos cheques do bordero em array
		if (count($xmlTagsTBRestri) > 0) {	
			for ($i = 0; $i < count($xmlTagsTBRestri); $i++) {
				$xmlTags = $xmlTagsTBRestri[$i]->tags;
			
				for ($j = 0; $j < count($xmlTags); $j++) {
					$dadosTBRestri[$i][$xmlTags[$j]->name] = $xmlTags[$j]->cdata;
				}
			}
			
			
			$dadosImpressos["TBRESTRI"] = $dadosTBRestri;
		}
		
		// Armazena dados do sacado que n�o pagou em array
		if (count($xmlTagsSacadNPg) > 0) {	
			for ($i = 0; $i < count($xmlTagsSacadNPg); $i++) {
				$xmlTags = $xmlTagsSacadNPg[$i]->tags;
			
				for ($j = 0; $j < count($xmlTags); $j++) {
					$dadosSacadNPg[$i][$xmlTags[$j]->name] = $xmlTags[$j]->cdata;
				}
			}
			
			$dadosImpressos["SACADNPG"] = $dadosSacadNPg;
		}

		// Classe para gera��o dos impressos em PDF
		require_once("imprimir_pdf_dscchq.php");

		// Instancia Objeto para gerar arquivo PDF
		$pdf = new PDF("P","cm","A4");
		
		// Inicia gera��o do impresso
		$pdf->geraImpresso($dadosImpressos,$idimpres);
		
		$navegador = CheckNavigator();
		$tipo = $navegador['navegador'] == 'chrome' ? "I" : "D";
		
		// Gera sa�da do PDF para o Browser
		$pdf->Output("impressao_desconto_cheques.pdf",$tipo);	
	}	

?>