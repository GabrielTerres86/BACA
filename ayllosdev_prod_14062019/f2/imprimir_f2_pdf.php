<?php 

	/************************************************************************
	      Fonte: imprimir_ef2_pdf.php
	      Autor: Guilherme
	      Data : Marco/2008                 Última Alteração:   /  /

	      Objetivo  : Gerar PDF do f2- ajuda

	      Alterações:
	 ************************************************************************/
	
	// Classe para geração de arquivos PDF
	require_once("../class/fpdf/fpdf.php");
	
	// Classe para geração do f2 em PDF
	class PDF extends FPDF {
		// Método Construtor
		function PDF($orientation = "P",$unit = "cm",$format = "A4") {
			$this->FPDF($orientation,$unit,$format);
		}

		function geraCabecalho($dados_F2) {
			$this->AddPage();		
			
			$this->SetFont("Courier","B",9);
			$this->Cell(18,0.5,"MANUAL DE AJUDA DAS TELAS - Sistema AIMARO",0,1,"C",0,"");
			$this->Ln();
			
			$this->Cell(18,0.5,"TELA  : ".$dados_F2["NMDATELA"]." - ".$dados_F2["TLDATELA"],0,1,"L",0,"");
			$this->Cell(18,0.5,"ROTINA: ".$dados_F2["NMROTINA"],0,1,"L",0,"");
			$this->Ln();
			$this->SetFont("Courier","",9);
			$this->Cell(6,0.5,"Versão: ".$dados_F2["NRVERSAO"],0,0,"L",0,"");
			$this->Cell(12,0.5,"Por: ".$dados_F2["NMOPERAD"],0,1,"L",0,"");
			$this->Cell(9,0.5,"Última Alteração: ".$dados_F2["DTMVTOLT"],0,0,"L",0,"");
			$this->Cell(9,0.5,"Data de Liberação: ".$dados_F2["DTLIBERA"],0,1,"L",0,"");
			$this->Ln();
		}	

		// Gerar Layout para Impressão do f2 em PDF
		function geraF2($dados_F2) {		
			// Seta Largura das Margens
			$this->SetMargins(1.5,1.5);
			
			// Setando fonte estilo Courier, tamanho 9, na cor preta
			$this->SetFont("Courier","",9);
			$this->SetTextColor(0,0,0);

			for ($i = 0; $i < count($dados_F2); $i++) {
				$this->geraCabecalho($dados_F2[$i]);
				$this->MultiCell(18,0.4,$dados_F2[$i]["DSDOHELP"],0,"J",0);			
		
			}
		}
	}
	
?>
