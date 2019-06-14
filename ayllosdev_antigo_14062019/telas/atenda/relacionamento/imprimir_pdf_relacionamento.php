<?php 

	/************************************************************************  
	      Fonte: imprimir_pdf_relacionamento.php                                               
	      Autor: Guilherme
	      Data : Outubro/2008                   �ltima Altera��o:   /  /

	      Objetivo  : Gerar PDF das impressoes da rotina de RELACIONAMENTO

	      Altera��es:
	************************************************************************/ 
	
	// Classe para gera��o de arquivos PDF
	require_once("../../../class/fpdf/fpdf.php");
	
	// Classe para gera��o dos impressos do desconto de titulos em PDF
	class PDF extends FPDF {
	
		var $nrLinhas = 0; // Acumular n�mero de Linhas da p�gina
		
		// M�todo Construtor
		function PDF($orientation = "P",$unit = "cm",$format = "A4") {
			$this->FPDF($orientation,$unit,$format);
		}
		
		// Gerar Layout para impressos
		function geraImpresso($dadosImpressos,$idImpresso) {		
			if ($idImpresso == "1") {
				$this->geraTermoCompromisso($dadosImpressos["TERMODEC"],$dadosImpressos["TERMODEC"]["TPINSEVE"]);
			}
		}
		
		function geraTermoCompromisso($dadosTermo,$tipoImpressao) {
			$this->SetMargins(1.5,1.5);
			$this->AddPage();

			$this->SetFont("Courier","",9);
			$this->SetTextColor(0,0,0);
			$this->Cell(18,0.4,$dadosTermo["NMEXTCOP"] . " - " . $dadosTermo["NMRESCOP"],0,1,"L",0,"");			

			$this->Ln();
			$this->Ln();
			
			$this->SetFont("Courier","B",16);
			$this->Cell(18,0.4,"TERMO DE COMPROMISSO",0,1,"C",0,"");
			
			$this->Ln();
			$this->Ln();
			$this->Ln();
			
			$this->SetFont("Courier","",10);
			if ($tipoImpressao == 1){ // Inscri��o pr�pria
				$this->MultiCell(18,0.4,"Eu, ".trim($dadosTermo["NMEXTTTL"])." inscrito(a) no curso ".trim($dadosTermo["NMEVENTO"])." promovido pela ".trim($dadosTermo["NMRESCOP"]).", assino este termo, comprometendo-me a participar do curso com frequ�ncia m�nima de ".trim($dadosTermo["PRFREQUE"])."%, caso contr�rio, autorizo o d�bito de R$ ".number_format(str_replace(",",".",$dadosTermo["VLDEBITO"]),2,",",".")." (".trim($dadosTermo["DSDEBITO"]).") correspondente a ".trim($dadosTermo["PRDESCON"])."% do valor do curso, na minha conta corrente n: ".formataNumericos("zzzz.zzz-9",$dadosTermo["NRDCONTA"],".-").".",0,"J",0);						
			}else{ // Incri��o de outra pessoa
				$this->MultiCell(18,0.4,"Eu, ".trim($dadosTermo["NMEXTTTL"])." assino este termo, firmando compromisso de que ".trim($dadosTermo["NMINSEVE"])." inscrito(a) no curso ".trim($dadosTermo["NMEVENTO"])." promovido pela ".trim($dadosTermo["NMRESCOP"]).", participar� do curso com frequ�ncia m�nima de ".trim($dadosTermo["PRFREQUE"])."%, caso contr�rio, autorizo o d�bito de R$ ".number_format(str_replace(",",".",$dadosTermo["VLDEBITO"]),2,",",".")." (".trim($dadosTermo["DSDEBITO"]).") correspondente a ".trim($dadosTermo["PRDESCON"])."% do valor do curso, na minha conta corrente n: ".formataNumericos("zzzz.zzz-9",$dadosTermo["NRDCONTA"],".-").".",0,"J",0);						
			}

			$this->Ln();
			$this->Ln();	
			$this->Ln();
			$this->Ln();
			
			$this->Cell(4.5,0.4,"",0,0,"L",0,"");
			$this->Cell(8.5,0.4,"","B",1,"L",0,"");
			$this->Cell(4.5,0.4,"",0,0,"L",0,"");
			$this->Cell(8.5,0.4,$dadosTermo["NMEXTTTL"],0,1,"L",0,"");
			
			$this->Ln();
			$this->Ln();
			
			$this->Cell(9.5,0.4,"",0,0,"L",0,"");
			$this->Cell(8.5,0.4,$dadosTermo["DSPACDAT"],0,0,"C",0,"");							
		
		}
	}
	
?>