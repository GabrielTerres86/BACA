<?php 

	/************************************************************************  
	      Fonte: imprimir_dados_relacionamento.php                                             
	      Autor: Guilherme                                                         
	      Data : Mar&ccedil;o/2009                   Ultima Alteracao: 12/07/2012          
	                                                                            
	      Objetivo  : Carregar dados para impress&otilde;es de desconto de titulos       
	                                                                            	 
	      Alteracoes: 12/07/2012 - Alterado parametro de $pdf->Output,     
							   Condicao para Navegador Chrome (Jorge).                                                         
	  ************************************************************************/ 

	session_cache_limiter("private");
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	// Verifica se o n&uacute;mero da conta foi informado
	if (!isset($_POST["nrdconta"]) || 
		!isset($_POST["idimpres"]) || 
		!isset($_POST["rowididp"]) || 
		!isset($_POST["rowidedp"])) {
		?><script language="javascript">alert('Par&acirc;metros incorretos.');</script><?php
		exit();
	}	

	$nrdconta = $_POST["nrdconta"];
	$idimpres = $_POST["idimpres"];
	$rowididp = $_POST["rowididp"];
	$rowidedp = $_POST["rowidedp"];

	// Verifica se o n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		?><script language="javascript">alert('Conta/dv inv&aacute;lida.');</script><?php
		exit();
	}
	
	// Verifica se identificador de impress&atilde;o &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($idimpres)) {
		?><script language="javascript">alert('Identificador de impress&atilde;o inv&aacute;lido.');</script><?php
		exit();
	}		
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlDadosImpres  = "";
	$xmlDadosImpres .= "<Root>";
	$xmlDadosImpres .= "	<Cabecalho>";
	$xmlDadosImpres .= "		<Bo>b1wgen0039.p</Bo>";
	$xmlDadosImpres .= "		<Proc>termo-de-compromisso</Proc>";
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
	$xmlDadosImpres .= "		<rowidedp>".$rowidedp."</rowidedp>";
	$xmlDadosImpres .= "		<rowididp>".$rowididp."</rowididp>";	
	$xmlDadosImpres .= "	</Dados>";
	$xmlDadosImpres .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlDadosImpres);

	// Cria objeto para classe de tratamento de XML
	$xmlObjDadosImpres = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
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

	// Armazena dados para impress&otilde;es
	$xmlTagsTermodeC = $xmlObjDadosImpres->roottag->tags[0]->tags; // Dados do termo
	
	// Armazena dados do termo em array
	/*if (count($xmlTagsTermodeC) > 0) {	
		for ($i = 0; $i < count($xmlTagsTermodeC); $i++) {
			$xmlTags = $xmlTagsTermodeC[$i]->tags;
		
			for ($j = 0; $j < count($xmlTags); $j++) {
				$dadosTermodeC[$i][$xmlTags[$j]->name] = $xmlTags[$j]->cdata;
			}
		}
		
		$dadosImpressos["TERMODEC"] = $dadosTermodeC;
	}	*/
	if (count($xmlTagsTermodeC) > 0) {	
		$xmlTags = $xmlTagsTermodeC[0]->tags;
		
		for ($i = 0; $i < count($xmlTags); $i++) {
			$dadosTermodeC[$xmlTags[$i]->name] = $xmlTags[$i]->cdata;
		}
		
		$dadosImpressos["TERMODEC"] = $dadosTermodeC;
	}

	// Classe para gera&ccedil;&atilde;o dos impressos em PDF
	require_once("imprimir_pdf_relacionamento.php");

	// Instancia Objeto para gerar arquivo PDF
	$pdf = new PDF("P","cm","A4");
	
	// Inicia gera&ccedil;&atilde;o do impresso
	$pdf->geraImpresso($dadosImpressos,$idimpres);
	
	$navegador = CheckNavigator();
	$tipo = $navegador['navegador'] == 'chrome' ? "I" : "D";
	
	// Gera sa&iacute;da do PDF para o Browser
	$pdf->Output("impressao_relacionamento.pdf",$tipo);	

?>