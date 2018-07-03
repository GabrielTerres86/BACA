<?
//*******************************************************************************
//Autor : Jonathan - Supero
//Criação: 29/10/2010
//Função : Gerar PDF
//
//Alteracoes: 23/07/2012 - Alterado parametros de output do FPDF. (Jorge)
//			
//			  12/05/2015 - Adicionado "unlink" para apagar arquivos da temp. (Jorge/Elton) - SD 283911
//*******************************************************************************

session_start();
	
// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
require_once("../../includes/config.php");
require_once("../../includes/funcoes.php");		
require_once("../../includes/controla_secao.php");

// Verifica se tela foi chamada pelo método POST
isPostMethod();	

if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@",false)) <> "") {				
	?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
	exit();
}

if (!isset($lstcmc7) || !is_array($lstcmc7) || !count($lstcmc7)) {
	$msgError = 'Erro ao gerar pdf. Cheque não encontrado';
	?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
	exit;
}

// Classe para geração de arquivos PDF
require("../../class/fpdf/fpdf.php");


$qtd_imgs = 0;

$pdf = new FPDF();
$pdf->AddPage();
// 210 x 297

$pdf->SetFont('Arial','B',15);
$pdf->Cell(40,15, 'Consulta de Imagem - AILOS', 0, 1);

$pdf->SetFont('Arial','B',12);
$pdf->Cell(60,10, "Cooperativa: $nmrescop");
$pdf->Cell(130,10, 'Remessa: ' . ($tpremess=='nr' ? 'Cheques Depositados (Nossa Remessa)' : 'Cheques da Cooperativa (Sua Remessa)'), 0, 1);

$pdf->Cell(40,10, 'Data Compensação: ' . $dtcompen, 0, 1);

// Compe do Cheque / Banco do Cheque / Agencia do Cheque
$pdf->Cell(60,10, "Compe do Cheque: $cdcmpchq");
$pdf->Cell(60,10, "Banco do Cheque: $cdbanchq");
$pdf->Cell(60,10, "Agencia do Cheque: $cdagechq", 0, 1);

// Conta do Cheque / Número do Cheque
$pdf->Cell(95,10, "Conta do Cheque: $nrctachq");
$pdf->Cell(95,10, "Número do Cheque: $nrcheque", 0, 1);
$pdf->Ln(10);

$pdf->SetLineWidth(1);

if (is_array($lstcmc7) && count($lstcmc7)) {
    
	foreach ($lstcmc7 as $gif) {
		
		if (file_exists($gif)) {			
			
			$qtd_imgs++;
			
			list($imWidth,$imHeigh) = getimagesize($gif);
			$w = 186;
			$y = $pdf->GetY();
			$h = $w * ($imHeigh / $imWidth);
			$pdf->Rect(198-$w, $y-2, $w+4, $h+4 );
			$pdf->Image($gif, 200-$w, $y, $w);
			$pdf->SetY($y + $h + 10);						
		
			/** 24/10/2011 - Guilherme/Supero **/
			if ($qtd_imgs % 2 == 0 && $qtd_imgs > 2){
				$pdf->AddPage();
			}
			// apaga os arquivos da  temp
			unlink($gif);
			
		}
		
	}

}

$pdf->Cell($w+4,10, 'Data da Consulta: ' . date('d/m/Y'), 0, 0, 'R');

$navegador = CheckNavigator();
$tipo = $navegador['navegador'] == 'chrome' ? "I" : "D";

// Gera saída do PDF para o Browser
$pdf->Output("imagem_cheque.pdf",$tipo);
