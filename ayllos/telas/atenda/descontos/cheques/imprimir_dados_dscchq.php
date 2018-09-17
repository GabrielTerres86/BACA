<?php 

	/************************************************************************  
	  Fonte: imprimir_dados_dscchq.php                                             
	  Autor: Guilherme                                                         
	  Data : Março/2009                   Última Alteração: 23/11/2016
																			
	  Objetivo  : Carregar dados para impress&otilde;es de desconto de cheques       
																				 
	  Alterações: 14/06/2010 - Adaptar para novo RATING (David). 

                  21/09/2010 - Ajuste para enviar impressoes via email para 
				               o PAC Sede (David).

				  12/07/2012 - Alterado parametro de $pdf->Output,     
							   Condicao para Navegador Chrome (Jorge).
							   
				  23/07/2014 - Ajustes para imprimir o contrato do cet (Lucas R./Gielow - Projeto Cet)

				  12/09/2016 - Alteracao para chamar a rotina do Oracle na
							   geracao da impressao. (Jaison/Daniel)
                 
          23/11/2016 - Alterado para atribuir variavel $dsiduser ao carregar variavel
                       PRJ314 - Indexacao Centralizada (Odirlei-Amcom)       

                  26/05/2017 - Alterado para tipo de impressao 10 - Analise bordero - PRJ300 - Desconto de cheque 
                              (Odirlei-AMcom)          
	************************************************************************/ 

	session_cache_limiter("private");
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");		
	require_once("../../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");
	
	// Verifica permissão
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"M")) <> "") {
		?>
                 <script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
		exit();
	}	

	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrdconta"]) || 
		!isset($_POST["nrctrlim"]) || 
		!isset($_POST["nrborder"]) ||
		!isset($_POST["limorbor"]) ||
		!isset($_POST["idimpres"]) ||
		!isset($_POST["flgemail"])) {
		?><script language="javascript">alert('Par&acirc;metros incorretos.');</script>
  <?php
		exit();
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrctrlim = $_POST["nrctrlim"];
	$nrborder = $_POST["nrborder"];
	$idimpres = $_POST["idimpres"];
	$limorbor = $_POST["limorbor"];
	$flgemail = $_POST["flgemail"];
	$flgrestr = isset($_POST["flgrestr"]) ? $_POST["flgrestr"] : 1;
	$dsiduser = session_id();	
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		?>
  <script language="javascript">alert('Conta/dv inv&aacute;lida.');</script><?php
		exit();
	}
	
	// Verifica se número do contrato é um inteiro válido
	if (!validaInteiro($nrctrlim)) {
		?><script language="javascript">alert('Contrato inv&aacute;lido.');</script><?php
		exit();
	}
	
	// Verifica se número do bordero é um inteiro válido
	if ((!validaInteiro($nrborder)) && ($nrborder != "")) {
		?><script language="javascript">alert('Bordero inv&aacute;lido.');</script><?php
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
	
	// Verifica se identificador de tipo de impressão é um inteiro válido
	if (!validaInteiro($limorbor)) {
		?><script language="javascript">alert('Identificador de tipo de impress&atilde;o inv&aacute;lido.');</script><?php
		exit();
	}	

    if ($idimpres == 1 || // COMPLETA
        $idimpres == 2 || // CONTRATO
        $idimpres == 4 || // NOTA PROMISSORIA
        $idimpres == 7 ||  // BORDERO DE CHEQUES
        $idimpres == 10) { // BORDERO DE CHEQUES PARA ANALISE
        $xml  = "<Root>";
        $xml .= "  <Dados>";
        $xml .= "    <nrdconta>".$nrdconta."</nrdconta>";
        $xml .= "    <idseqttl>1</idseqttl>";
        $xml .= "    <idimpres>".$idimpres."</idimpres>";
        $xml .= "    <tpctrlim>2</tpctrlim>"; // 2-Cheque
        $xml .= "    <nrctrlim>".$nrctrlim."</nrctrlim>";
        $xml .= "    <nrborder>".$nrborder."</nrborder>";
        $xml .= "    <dsiduser>".$dsiduser."</dsiduser>";
        $xml .= "    <flgemail>".($flgemail == 'yes' ? 1 : 0)."</flgemail>";
        $xml .= "    <flgerlog>0</flgerlog>";
		$xml .= "    <flgrestr>".$flgrestr."</flgrestr>";
        $xml .= "  </Dados>";
        $xml .= "</Root>";

        $xmlResult = mensageria($xml, "ATENDA", "DESC_IMPRESSAO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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

    } else {

	if ($idimpres <= 4 || $idimpres == 9) { 
	    $nmproced = "gera-impressao-limite"; 
	}else{
		$nmproced = "busca_dados_impressao_dscchq";
	}
	
	
	
	// Monta o xml de requisição
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
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjDadosImpres->roottag->tags[0]->name) == "ERRO") {
		$msg = $xmlObjDadosImpres->roottag->tags[0]->tags[0]->tags[4]->cdata;
		?><script language="javascript">alert('<?php echo $msg; ?>');</script><?php
		exit();
	} 
	
	if ($idimpres <= 4 || $idimpres == 9) { // Impressões do limite
		// Obtém nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
		$nmarqpdf = $xmlObjDadosImpres->roottag->tags[0]->attributes["NMARQPDF"];
		
		// Chama função para mostrar PDF do impresso gerado no browser
		visualizaPDF($nmarqpdf);
	} else { // Impressões do bordero
		// Armazena dados para impressões
		$xmlTagsEmpresti = $xmlObjDadosImpres->roottag->tags[0]->tags; // Dados de empréstimo
		$xmlTagsPropLimi = $xmlObjDadosImpres->roottag->tags[1]->tags; // Dados da proposta de limite
		$xmlTagsCtrLimit = $xmlObjDadosImpres->roottag->tags[2]->tags; // Dados do contrato de limite
		$xmlTagsAvalista = $xmlObjDadosImpres->roottag->tags[3]->tags; // Dados dos Avalistas
		$xmlTagsNotaProm = $xmlObjDadosImpres->roottag->tags[4]->tags; // Dados para nota promissória
		$xmlTagsPropBord = $xmlObjDadosImpres->roottag->tags[5]->tags; // Dados da proposta de bordero
		$xmlTagsCabecTit = $xmlObjDadosImpres->roottag->tags[6]->tags; // Dados para os cheques do bordero
		$xmlTagsTitsBord = $xmlObjDadosImpres->roottag->tags[7]->tags; // Dados dos cheques do bordero
		$xmlTagsTBRestri = $xmlObjDadosImpres->roottag->tags[8]->tags; // Dados das restrições dos cheques do bordero
		$xmlTagsSacadNPg = $xmlObjDadosImpres->roottag->tags[9]->tags; // Dados do sacado que não pagou

		// Armazena dados de empréstimo em array
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

		// Armazena dados da nota promissória em array
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
		
		// Armazena dados as restrições dos cheques do bordero em array
		if (count($xmlTagsTBRestri) > 0) {	
			for ($i = 0; $i < count($xmlTagsTBRestri); $i++) {
				$xmlTags = $xmlTagsTBRestri[$i]->tags;
			
				for ($j = 0; $j < count($xmlTags); $j++) {
					$dadosTBRestri[$i][$xmlTags[$j]->name] = $xmlTags[$j]->cdata;
				}
			}
			
			
			$dadosImpressos["TBRESTRI"] = $dadosTBRestri;
		}
		
		// Armazena dados do sacado que não pagou em array
		if (count($xmlTagsSacadNPg) > 0) {	
			for ($i = 0; $i < count($xmlTagsSacadNPg); $i++) {
				$xmlTags = $xmlTagsSacadNPg[$i]->tags;
			
				for ($j = 0; $j < count($xmlTags); $j++) {
					$dadosSacadNPg[$i][$xmlTags[$j]->name] = $xmlTags[$j]->cdata;
				}
			}
			
			$dadosImpressos["SACADNPG"] = $dadosSacadNPg;
		}

		// Classe para geração dos impressos em PDF
		require_once("imprimir_pdf_dscchq.php");

		// Instancia Objeto para gerar arquivo PDF
		$pdf = new PDF("P","cm","A4");
		
		// Inicia geração do impresso
		$pdf->geraImpresso($dadosImpressos,$idimpres);
		
		$navegador = CheckNavigator();
		$tipo = $navegador['navegador'] == 'chrome' ? "I" : "D";
		
		// Gera saída do PDF para o Browser
		$pdf->Output("impressao_desconto_cheques.pdf",$tipo);	
	}	
    }
?>