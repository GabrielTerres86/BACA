<?php 

	/************************************************************************
	  Fonte: imprimir_f2.php
	  Autor: Guilherme
	  Data : Julho/2008                       �ltima Altera��o: 12/07/2012

	  Objetivo  : Gerar o impresso do F2- Ajuda

	  Altera��es: 22/10/2010 - Novo parametro na funcao getDataXML (David).
	  
				  12/07/2012 - Alterado parametro de $pdf->Output,     
							   Condicao para Navegador Chrome (Jorge).			 	   
	************************************************************************/
	
	session_cache_limiter("private");
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../includes/config.php");
	require_once("../includes/funcoes.php");		
	require_once("../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../class/xmlfile.php");
	
	// Verifica se n�mero da conta foi informado
	if (!isset($_POST["nmdatela"]) ||
		!isset($_POST["nmrotina"]) ||
		!isset($_POST["dtmvtolt"]) ||
		!isset($_POST["inrotina"])) {
		?><script language="javascript">alert('Par&acirc;metros incorretos.');</script><?php
		exit();
	}	

	// Monta o xml de requisi��o
	$xmlF2  = "";
	$xmlF2 .= "<Root>";
	$xmlF2 .= "	<Cabecalho>";
	$xmlF2 .= "		<Bo>b1wgen0029.p</Bo>";
	$xmlF2 .= "		<Proc>busca_help</Proc>";
	$xmlF2 .= "	</Cabecalho>";
	$xmlF2 .= "	<Dados>";
	$xmlF2 .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlF2 .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlF2 .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlF2 .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlF2 .= "		<dtmvtolt>".$_POST["dtmvtolt"]."</dtmvtolt>";
	$xmlF2 .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlF2 .= "		<nmdatela>".$_POST["nmdatela"]."</nmdatela>";
	$xmlF2 .= "		<nmrotina>".$_POST["nmrotina"]."</nmrotina>";
	$xmlF2 .= "		<inrotina>".$_POST["inrotina"]."</inrotina>";
	$xmlF2 .= "	</Dados>";
	$xmlF2 .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlF2,false);

	// Cria objeto para classe de tratamento de XML
	$xmlObjF2 = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjF2->roottag->tags[0]->name) == "ERRO") {
		?><script language="javascript">alert('<?php echo $xmlObjF2->roottag->tags[0]->tags[0]->tags[4]->cdata; ?>');</script><?php
		exit();
	} 

	$xmlTags  = $xmlObjF2->roottag->tags[0]->tags; // Help
	
	// Alimenta o Array com o help da(s) rotina(s)
	for ($i = 0; $i < count($xmlTags); $i++) {
		$xmlSubTags = $xmlTags[$i]->tags;
		
		for ($j = 0; $j < count($xmlSubTags); $j++) {
			$dados_F2[$i][$xmlSubTags[$j]->name] = $xmlSubTags[$j]->cdata;
		}
	}
	
	// Classe para gera��o do f2 em PDF
	require_once("imprimir_f2_pdf.php");

	// Instancia Objeto para gerar arquivo PDF
	$pdf = new PDF("P","cm","A4");

	// Inicia gera��o do f2
	$pdf->geraF2($dados_F2);
	
	$navegador = CheckNavigator();
	$tipo = $navegador['navegador'] == 'chrome' ? "I" : "D";
	
	// Gera sa�da do PDF para o Browser
	$pdf->Output("f2ajuda.pdf",$tipo);	

?>
