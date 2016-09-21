<?php 

	//************************************************************************//
	//*** Fonte: rating_imprimir_pdf.php                                   ***//
	//*** Autor: David                                                     ***//
	//*** Data : Junho/2010                   Última Alteração: 07/04/2011 ***//
	//***                                                                  ***//
	//*** Objetivo  : Gerar PDF para impressão do RATING do cooperado      ***//
	//***                                                                  ***//	 
	//*** Alterações: 07/04/2011 - Incluido dados do Risco_Cooperado       ***//	
	//***						   (Adriano).                              ***//
	//************************************************************************//
	
	
	
	// Classe para geração de arquivos PDF
	require_once("../../class/fpdf/fpdf.php");
	
	// Classe para gerar impressão do RATING em PDF
	
	
	class PDF extends FPDF {
	
		// Método Construtor
		function PDF($orientation = "P",$unit = "cm",$format = "A4") {
			$this->FPDF($orientation,$unit,$format);
		}
		
		// Gerar Layout para impressão
		function geraRating($relatorio,$cooperado,$rating,$risco,$assinatura,$efetivacao,$risco_cooperado) {		
			$this->AddFont("Letter_Gothic","","letter_gothic.php");
			
			$this->SetMargins(1.5,1);
			
			$this->AddPage();
			
   			$this->SetFont("Letter_Gothic","",8.5);
			$this->SetTextColor(0,0,0);
			
			$this->Cell(18,0.35,$relatorio["NMRESCOP"]." - ".$relatorio["NMRELATO"]." - REF.".$relatorio["DTMVTREF"]." ".trim($relatorio["NMMODULO"])." ".$relatorio["CDRELATO"]."/".$relatorio["PROGERAD"]." EM ".$relatorio["DTMVTOLT"]." AS ".$relatorio["DSHORAAT"]." HR PAG.: 1",0,1,"L",0,"");
			
			$this->PulaLinha();
			$this->PulaLinha();
			$this->PulaLinha();
						
			$this->Cell(9,0.35,"Conta: ".formataNumericos("zzzz.zzz-9",$cooperado["NRDCONTA"],".-")." - ".$cooperado["NMPRIMTL"],0,0,"L",0,"");			
			$this->Cell(9,0.35,"Contrato: ".formataNumericos("zzz.zzz.zz9",$cooperado["NRCTRRAT"],".")." ( ".$cooperado["DSDOPERA"]." ) - ".$cooperado["DSPESSOA"],0,1,"R",0,"");

			$this->PulaLinha();
			
			foreach ($rating as $codRating => $itensRating) {				
				$this->Cell(00.4,0.55,$codRating,0,0,"L",0,"");
				$this->Cell(13.0,0.55,$itensRating[0][0]["DSITETOP"],0,0,"L",0,"");
				$this->Cell(02.0,0.55,"PESO",0,0,"C",0,"");
				$this->Cell(02.0,0.55,"NOTA",0,1,"C",0,"");
				
				foreach ($itensRating as $item => $subItensRating) {
					if ($item > 0) {
						$this->Cell(00.4,0.55,"",0,0,"L",0,"");
						$this->Cell(00.7,0.55,$codRating.".".$item,0,0,"L",0,"");
						$this->Cell(12.3,0.55,$subItensRating[0]["DSITETOP"],0,0,"L",0,"");
						$this->Cell(02.0,0.55,$subItensRating[0]["DSPESOIT"],0,0,"C",0,"");
						$this->Cell(02.0,0.55,$subItensRating[0]["DSNOTAIT"],0,1,"C",0,"");
						
						foreach ($subItensRating as $subItem => $dadosSubItem) {
							if ($subItem > 0) {
								$this->Cell(00.4,0.55,"",0,0,"L",0,"");
								$this->Cell(00.7,0.55,"",0,0,"L",0,"");
								$this->Cell(01.1,0.55,$codRating.".".$item.".".$subItem,0,0,"L",0,"");
								$this->Cell(11.2,0.55,$dadosSubItem["DSITETOP"],0,0,"L",0,"");
								$this->Cell(02.0,0.55,$dadosSubItem["DSPESOIT"],0,0,"C",0,"");
								$this->Cell(02.0,0.55,$dadosSubItem["DSNOTAIT"],0,1,"C",0,"");
							}
						}
					}
				}
			}
			
			$this->PulaLinha();
			
			$this->Cell(4.0,0.35,"NOTA COOPERADO: ".number_format(str_replace(",",".",$risco_cooperado["VLRTOTAL"]),2,",","."),0,0,"L",0,"");
			$this->Cell(4.5,0.35,"RISCO: ".$risco_cooperado["DSDRISCO"],0,0,"L",0,"");
			
			$this->PulaLinha();
			$this->PulaLinha();
			
			$this->Cell(4.0,0.35,"NOTA: ".number_format(str_replace(",",".",$risco["VLRTOTAL"]),2,",","."),0,0,"L",0,"");
			$this->Cell(3.8,0.35,"RISCO: ".$risco["DSDRISCO"],0,0,"L",0,"");
			$this->Cell(3.4,0.35,"PROVISAO: ".number_format(str_replace(",",".",$risco["VLPROVIS"]),2,",","."),0,0,"L",0,"");
			$this->Cell(4.0,0.35,$risco["DSPARECE"],0,1,"L",0,"");
			
			
			$this->PulaLinha();
			
			$this->Cell(18,0.35,$assinatura["DSDEDATA"],0,1,"L",0,"");
			
			$this->PulaLinha();
			
			$this->Cell(4.00,0.35,"",0,0,"L",0,"");
			$this->Cell(6.25,0.35,$assinatura["NMOPERAD"],"T",0,"L",0,"");
			$this->Cell(1.00,0.35,"",0,0,"L",0,"");
			$this->Cell(6.25,0.35,$assinatura["DSRESPON"],"T",1,"L",0,"");			
			
			$dsdefeti = $efetivacao[2];
			
			if ($dsdefeti <> "") {
				$this->PulaLinha();				
				$this->Cell(18,0.35,$dsdefeti,0,1,"L",0,"");
			} 
		}
		
		function PulaLinha() {
			$this->Cell(18,0.4,"",0,1,"L",0,"");
		}			
	}
	
?>