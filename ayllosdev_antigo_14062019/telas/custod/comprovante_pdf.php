<?php
/*!
 * FONTE        : comprovante_pdf.php
 * CRIAÇÃO      : Mateus Zimmermann (Mouts)
 * DATA CRIAÇÃO : 13/12/2017
 * OBJETIVO     : Geração do PDF comprovante de resgate de cheques custodiados
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */		

session_start();
	
// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');

// Verifica se tela foi chamada pelo método POST
isPostMethod();	

if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"I",false)) <> "") {
	exibirErro('error',$msgError,'Alerta - Aimaro','',false);
}

// Classe para geração de arquivos PDF
require("../../class/fpdf/fpdf.php");

$pdf = new FPDF();
$pdf->AddPage();

adicionaCabecalhoRelatorio($pdf,$glbvars);
processaCheques($pdf);
processaAssinaturas($pdf);
finalizaRelatorio($pdf);

/**
 * Gera o cabeçalho para o relatório
 */
function adicionaCabecalhoRelatorio($pdf,$global){

	$pdf->SetFont('Arial','',12);
	$pdf->Cell(185,0, strtoupper($global["nmcooper"]) . ':  –  Comprovante de Resgate de Cheque Custodiado – Emissão:' . $global['dtmvtolt'], 0, 0, 'L');
	$pdf->Ln(5);
	
	$pdf->Cell(185,0,'Conta: ' . $_POST["nrdconta"], 0, 0, 'L');
	$pdf->Ln(10);

	// $pdf->Cell(185,0,'Nome: ' . $_POST["nomeresg"], 0, 0, 'L');
	// $pdf->Ln(5);

	// $pdf->Cell(185,0,'Documento de Identificação: ' . $_POST["docuresg"], 0, 0, 'L');
	// $pdf->Ln(10);
}

/**
 * Processa os dados dos cheques que vieram pelo $_POST 
 * e gera imprime as linhas, além de controlar a paginação dos cheques
 */
function processaCheques($pdf){
	//Controle de paginação
	$qtdTotal   = 0;

	// Todas as informações do cheque vem separadas por ";" e os cheques por "|"
	$aCheques = explode("|",$_POST["dscheque"]);

	foreach($aCheques as $cheque){
		// Separa a informacao dos campo
		$aDados = explode(";",$cheque);
		
		$pdf->SetFont('Arial','',10);
		// Imprime a linha de cabeçalho
		$pdf->Cell(21,0,'Número do Cheque: ' . $aDados[0], 0, 0, 'L');
		$pdf->Ln(5);
		$pdf->Cell(24,0,'Valor: ' . $aDados[1], 0, 0, 'L');
		$pdf->Ln(5);
		$pdf->Cell(16,0,'CMC-7: ' . $aDados[2], 0, 0, 'L');
		$pdf->Ln(10); // Linha de espaçamento
		
		// Totalizar a quantidade e o valor dos cheques
		$qtdTotal++;
	}
}

/**
 * Processa os dados dos cheques que vieram pelo $_POST 
 * e gera imprime as linhas, além de controlar a paginação dos cheques
 */
function processaAssinaturas($pdf){
	
	$pdf->Ln(20);		
	$pdf->SetFont('Arial','',10);
	
	if($_POST["inpessoa"] > 1 && $_POST["idastcjt"] == 1){
		
		for ($i=0; $i < $_POST["qtdresp"]; $i++) {
			
			$pdf->Cell(21,0,'______________________________', 0, 0, 'L');
			$pdf->Ln(5);
			$pdf->Cell(24,0,$_POST["resp" . $i], 0, 0, 'L');
			$pdf->Ln(30); // Linha de espaçamento
		
		}

	} else {

		$pdf->Cell(21,0,'______________________________', 0, 0, 'L');
		$pdf->Ln(5);
		$pdf->Cell(24,0,$_POST["nmprimtl"], 0, 0, 'L');
		$pdf->Ln(10); // Linha de espaçamento

	}
		
}

/**
 * Finaliza o relatório gerando o download do PDF
 */
function finalizaRelatorio($pdf){
	// Verifica Navegador para imprimir
	$navegador = CheckNavigator();
	$tipo = $navegador['navegador'] == 'chrome' ? "I" : "D";
	// Gera saída do PDF para o Browser
	$pdf->Output("custodia_cheque.pdf",$tipo);
}
?>