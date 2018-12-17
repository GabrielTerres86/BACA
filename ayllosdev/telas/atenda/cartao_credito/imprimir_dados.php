<?php 

	/************************************************************************  
	  Fonte: imprimir_dados.php                                             
	  Autor: Guilherme                                                         
	  Data : Maio/2008                   �ltima Altera��o: 12/07/2012         
																			
	  Objetivo  : Carregar dados para impress�es de cart�o de cr�dito       
																			 
	  Altera��es: 03/11/2010 - Adapta��es para cart�o PJ (David).

				  23/03/2011 - Adicionado condicao de $idimpres 16, 
							   cancelamento de cartao de credito de PJ(Jorge).
				
				  20/04/2012 - Adicionado chamada da procedure 
				               gera_impressao_contrato_bb. (David Kruger).
					
				  12/07/2012 - Alterado parametro de $pdf->Output,     
							   Condicao para Navegador Chrome (Jorge).	
							   
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
		!isset($_POST["nrctrcrd"]) || 
		!isset($_POST["idimpres"]) || 
		!isset($_POST["cdmotivo"])) {
		?><script language="javascript">alert('Par&acirc;metros incorretos.');</script><?php
		exit();
	}	

	$nrdconta = $_POST["nrdconta"];	
	$nrctrcrd = $_POST["nrctrcrd"];
	$idimpres = $_POST["idimpres"];
	$cdmotivo = $_POST["cdmotivo"];

	// Verifica se o n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		?><script language="javascript">alert('Conta/dv inv&aacute;lida.');</script><?php
		exit();
	}
	
	// Verifica se n�mero do contrato � um inteiro v�lido
	if (!validaInteiro($nrctrcrd)) {
		?><script language="javascript">alert('Contrato inv&aacute;lido.');</script><?php
		exit();
	}
	
	// Verifica se identificador de impress�o � um inteiro v�lido
	if (!validaInteiro($idimpres)) {
		?><script language="javascript">alert('Identificador de impress&atilde;o inv&aacute;lido.');</script><?php
		exit();
	}		
	
	// Verifica se c�digo do motivo da solicita��o de segunda via � um inteiro v�lido
	if (!validaInteiro($cdmotivo)) {
		?><script language="javascript">alert('C&oacute;digo da solicita&ccedil;&atilde;o de segunda via inv&aacute;lido.');</script><?php
		exit();
	}	

	if ($idimpres == 1  || $idimpres == 2  || $idimpres == 3  || $idimpres == 7  || $idimpres == 8  || $idimpres == 9  || 
	    $idimpres == 10 || $idimpres == 11 || $idimpres == 12 || $idimpres == 13 || $idimpres == 14 || $idimpres == 15 || 
		$idimpres == 16){
		switch ($idimpres) { 
		    case  1: $nmproced = "imprimi_limite_pf";              		  break;
			case  2: $nmproced = "gera_impressao_contrato_cartao"; 		  break;
			case  3: $nmproced = "gera_impressao_proposta_cartao"; 		  break;
			case  7: $nmproced = "gera_impressao_contrato_bb";     		  break;
			case  8: $nmproced = "imprime_Alt_data_PF";            		  break;
			case  9: $nmproced = "gera_impressao_entrega_carta";   		  break;
			case 10: $nmproced = "gera_impressao_emissao_cartao";  		  break;
			case 11: $nmproced = "segunda_via_cartao";             		  break;
			case 12: $nmproced = "segunda_via_senha_cartao";       		  break;
			case 13: $nmproced = "termo_cancela_cartao";           		  break;
			case 14: $nmproced = "altera_limite_pj";               		  break;
			case 15: $nmproced = "imprime_Alt_data_PJ";            		  break;
			case 16: $nmproced = "termo_encerra_cartao";		   		  break;	//encerramento cartao credito de PJ,quase identico ao 13
			default: exit();
		}
		
		// Monta o xml de requisi��o
		$xmlDadosImpres  = "";
		$xmlDadosImpres .= "<Root>";
		$xmlDadosImpres .= "	<Cabecalho>";
		$xmlDadosImpres .= "		<Bo>b1wgen0028.p</Bo>";
		$xmlDadosImpres .= "		<Proc>".$nmproced."</Proc>";
		$xmlDadosImpres .= "	</Cabecalho>";
		$xmlDadosImpres .= "	<Dados>";
		$xmlDadosImpres .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xmlDadosImpres .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
		$xmlDadosImpres .= "		<nrdcaixa>0</nrdcaixa>";
		$xmlDadosImpres .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";		
		$xmlDadosImpres .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
		$xmlDadosImpres .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
		$xmlDadosImpres .= "		<nrdconta>".$nrdconta."</nrdconta>";
		$xmlDadosImpres .= "		<idseqttl>1</idseqttl>";
		$xmlDadosImpres .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
		$xmlDadosImpres .= "		<dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";
		$xmlDadosImpres .= "		<inproces>".$glbvars["inproces"]."</inproces>";		
		$xmlDadosImpres .= "		<nrctrcrd>".$nrctrcrd."</nrctrcrd>";
		$xmlDadosImpres .= "		<flgimpnp>no</flgimpnp>";
		$xmlDadosImpres .= "		<nmendter>".session_id().getmypid()."</nmendter>";
		$xmlDadosImpres .= "		<flgimp2v>no</flgimp2v>";
		$xmlDadosImpres .= "		<flgerlog>no</flgerlog>";
	    $xmlDadosImpres .= "		<cdmotivo>0</cdmotivo>";		
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
	} else if ($idimpres == 18) {

		$xml = "<Root>";
		$xml .= " <Dados>";
		$xml .= "   <nrctrcrd>".$nrctrcrd."</nrctrcrd>";
		$xml .= " </Dados>";
		$xml .= "</Root>";
	
		$validaresult = mensageria($xml, "ATENDA_CRD", "VALIDA_DTCORTE_PROTOCOLO", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$validaxmlObj = getObjectXML($validaresult);

		if (strtoupper($validaxmlObj->roottag->tags[0]->name) == "ERRO") {
			$msg = $validaxmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
			?><script language="javascript">alert('<?php echo $msg; ?>');</script><?php
			exit();
		}
		$layout = $validaxmlObj->roottag->cdata;
		if ($layout == 0) {

			// Monta o xml de requisi��o
			$xmlDadosImpres  = "";
			$xmlDadosImpres .= "<Root>";
			$xmlDadosImpres .= "	<Cabecalho>";
			$xmlDadosImpres .= "		<Bo>b1wgen0028.p</Bo>";
			$xmlDadosImpres .= "		<Proc>gera_impressao_entrega_cartao_bancoob</Proc>";
			$xmlDadosImpres .= "	</Cabecalho>";
			$xmlDadosImpres .= "	<Dados>";
			$xmlDadosImpres .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
			$xmlDadosImpres .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
			$xmlDadosImpres .= "		<nrdcaixa>0</nrdcaixa>";
			$xmlDadosImpres .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";		
			$xmlDadosImpres .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
			$xmlDadosImpres .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
			$xmlDadosImpres .= "		<nrdconta>".$nrdconta."</nrdconta>";
			$xmlDadosImpres .= "		<idseqttl>1</idseqttl>";
			$xmlDadosImpres .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
			$xmlDadosImpres .= "		<dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";
			$xmlDadosImpres .= "		<inproces>".$glbvars["inproces"]."</inproces>";		
			$xmlDadosImpres .= "		<nrctrcrd>".$nrctrcrd."</nrctrcrd>";
			$xmlDadosImpres .= "		<flgimpnp>no</flgimpnp>";
			$xmlDadosImpres .= "		<nmendter>".session_id().getmypid()."</nmendter>";
			$xmlDadosImpres .= "		<flgimp2v>no</flgimp2v>";
			$xmlDadosImpres .= "		<flgerlog>no</flgerlog>";
			$xmlDadosImpres .= "		<cdmotivo>0</cdmotivo>";		
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

		} else {
			$xml = "<Root>";
			$xml .= " <Dados>";
			$xml .= "   <nrctrcrd>".$nrctrcrd."</nrctrcrd>";
			$xml .= " </Dados>";
			$xml .= "</Root>";
		
			$impresult = mensageria($xml, "ATENDA_CRD", "IMPRIMIR_PROTOCOLO_CARTAO_CREDITO", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
			$impxmlObj = getObjectXML($impresult);

			// Se ocorrer um erro, mostra cr�tica
			if ($impxmlObj->roottag->tags[0]->name == "ERRO") {
				$msg = $impxmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
				?><script language="javascript">alert('<?php echo $msg; ?>');</script><?php
				exit();
			}

			//Obt�m nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
			$nmarqpdf = $impxmlObj->roottag->cdata;
		}

		// Chama fun��o para mostrar PDF do impresso gerado no browser
		visualizaPDF($nmarqpdf);


	} else {
		// Monta o xml de requisi��o
		$xmlDadosImpres  = "";
		$xmlDadosImpres .= "<Root>";
		$xmlDadosImpres .= "	<Cabecalho>";
		$xmlDadosImpres .= "		<Bo>b1wgen0028.p</Bo>";
		$xmlDadosImpres .= "		<Proc>impressoes_cartoes</Proc>";
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
		$xmlDadosImpres .= "		<nrctrcrd>".$nrctrcrd."</nrctrcrd>";
		$xmlDadosImpres .= "		<flgerlog>TRUE</flgerlog>";
		$xmlDadosImpres .= "		<flgimpnp>TRUE</flgimpnp>";
		$xmlDadosImpres .= "		<cdmotivo>".$cdmotivo."</cdmotivo>";
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

		// Armazena dados para impress�es
		$xmlTagsProposta = $xmlObjDadosImpres->roottag->tags[0]->tags; // Dados para Proposta
		$xmlTagsOCartoes = $xmlObjDadosImpres->roottag->tags[1]->tags; // Dados de outros cartoes
		$xmlTagsCancBloq = $xmlObjDadosImpres->roottag->tags[2]->tags; // Dados do termo de cancelamento
		$xmlTagsCtrCredi = $xmlObjDadosImpres->roottag->tags[3]->tags; // Dados para Contrato Credicard
		$xmlTagsBdnCeVis = $xmlObjDadosImpres->roottag->tags[4]->tags; // Dados para Contrato Cecred/Visa e Bradesco/Visa
		$xmlTags2viaCart = $xmlObjDadosImpres->roottag->tags[5]->tags; // Dados para termo de solicita��o de segunda via
		$xmlTagsAvalista = $xmlObjDadosImpres->roottag->tags[6]->tags; // Dados dos Avalistas
		$xmlTagsCtrBBras = $xmlObjDadosImpres->roottag->tags[7]->tags; // Dados dos contratos para ADM BB
		$xmlTagsDtVctCrd = $xmlObjDadosImpres->roottag->tags[8]->tags; // Dados dos contratos para ADM BB
		
		// Armazena dados da Proposta em array
		if (count($xmlTagsProposta) > 0) {	
			$xmlTags = $xmlTagsProposta[0]->tags;
			
			for ($i = 0; $i < count($xmlTags); $i++) {
				$dadosProposta[$xmlTags[$i]->name] = $xmlTags[$i]->cdata;
			}
			
			$dadosImpressos["PROPOSTA"] = $dadosProposta;
		}

		// Armazena dados dos Outros Cartoes em array
		if (count($xmlTagsOCartoes) > 0) {	
			for ($i = 0; $i < count($xmlTagsOCartoes); $i++) {
				$xmlTags = $xmlTagsOCartoes[$i]->tags;
			
				for ($j = 0; $j < count($xmlTags); $j++) {
					$dadosOCartoes[$i][$xmlTags[$j]->name] = $xmlTags[$j]->cdata;
				}
			}
			
			$dadosImpressos["OCARTOES"] = $dadosOCartoes;
		}	
		
		// Armazena dados da Proposta em array
		if (count($xmlTagsCancBloq) > 0) {	
			$xmlTags = $xmlTagsCancBloq[0]->tags;
			
			for ($i = 0; $i < count($xmlTags); $i++) {
				$dadosCancBloq[$xmlTags[$i]->name] = $xmlTags[$i]->cdata;
			}
			
			$dadosImpressos["CANCBLOQ"] = $dadosCancBloq;
		}


		// Armazena dados do Contrato Credicard em array
		if (count($xmlTagsCtrCredi) > 0) {	
			$xmlTags = $xmlTagsCtrCredi[0]->tags;
			
			for ($i = 0; $i < count($xmlTags); $i++) {
				$dadosCtrCredi[$xmlTags[$i]->name] = $xmlTags[$i]->cdata;
			}
			
			$dadosImpressos["CTRCREDI"] = $dadosCtrCredi;
		}
		
		// Armazena dados do Contrato Cecred/Visa Bdn/Visa em array
		if (count($xmlTagsBdnCeVis) > 0) {	
			$xmlTags = $xmlTagsBdnCeVis[0]->tags;
			
			for ($i = 0; $i < count($xmlTags); $i++) {
				$dadosBdnCeVis[$xmlTags[$i]->name] = $xmlTags[$i]->cdata;
			}
			
			$dadosImpressos["BDNCEVIS"] = $dadosBdnCeVis;
		}	
		
		// Armazena dados do termo de solicita��o de segunda via em array
		if (count($xmlTags2viaCart) > 0) {	
			$xmlTags = $xmlTags2viaCart[0]->tags;
			
			for ($i = 0; $i < count($xmlTags); $i++) {
				$dados2viaCart[$xmlTags[$i]->name] = $xmlTags[$i]->cdata;
			}
			
			$dadosImpressos["2VIACART"] = $dados2viaCart;
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
		
		// Armazena dados do Contrato das ADMS's BB em array
		if (count($xmlTagsCtrBBras) > 0) {	
			$xmlTags = $xmlTagsCtrBBras[0]->tags;
			
			for ($i = 0; $i < count($xmlTags); $i++) {
				$dadosCtrBBras[$xmlTags[$i]->name] = $xmlTags[$i]->cdata;
			}
			
			$dadosImpressos["CTRBBRAS"] = $dadosCtrBBras;
		}	
		
		// Armazena dados do Contrato das ADMS's BB em array
		if (count($xmlTagsDtVctCrd) > 0) {	
			$xmlTags = $xmlTagsDtVctCrd[0]->tags;
			
			for ($i = 0; $i < count($xmlTags); $i++) {
				$dadosDtVctCrd[$xmlTags[$i]->name] = $xmlTags[$i]->cdata;
			}
			
			$dadosImpressos["DTVCTCRD"] = $dadosDtVctCrd;
		}	

		// Classe para gera��o dos impressos em PDF
		require_once("imprimir_pdf.php");

		// Instancia Objeto para gerar arquivo PDF
		$pdf = new PDF("P","cm","A4");
		
		// Inicia gera��o do impresso
		$pdf->geraImpresso($dadosImpressos,$idimpres);
		
		$navegador = CheckNavigator();
		$tipo = $navegador['navegador'] == 'chrome' ? "I" : "D";
		
		// Gera sa�da do PDF para o Browser
		$pdf->Output("cartao_credito.pdf",$tipo);	
	}
	
?>