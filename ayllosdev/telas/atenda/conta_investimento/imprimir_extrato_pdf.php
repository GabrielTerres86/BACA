<?php 

	//************************************************************************//
	//*** Fonte: imprimir_extrato_pdf.php                                 ***//
	//*** Autor: David                                                     ***//
	//*** Data : Outubro/2007                 �ltima Altera��o: 00/00/0000 ***//
	//***                                                                  ***//
	//*** Objetivo  : Gerar PDF do extrato da Conta Investimento           ***//
	//***                                                                  ***//	 
	//*** Altera��es:                                                      ***//
	//************************************************************************//
	
	// Classe para gera��o de arquivos PDF
	require_once("../../../class/fpdf/fpdf.php");
	
	// Classe para gera��o do extrato de autoriza��o de plano de capital em PDF
	class PDF extends FPDF {

		// M�todo Construtor
		function PDF($orientation = "P",$unit = "cm",$format = "A4") {
			$this->FPDF($orientation,$unit,$format);
		}
		
		// Gerar Layout para Impress�o do extrato em PDF
		function geraExtrato($dados_cabecalho,$dados_extrato) {		
			// Seta Largura das Margens
			$this->SetMargins(1,3);
			
			// Adicina Nova P�gina ao PDF
			$this->AddPage();
			
			// Setando fonte estilo Courier, tamanho 10, na cor preta
   		$this->SetFont("Courier","",10);
			$this->SetTextColor(0,0,0);
			
			// N�mero da Conta
			$this->Cell(19,0.65,"Conta Corrente: ".$dados_cabecalho["NRDCONTA"],0,1,"L",0,"");			
			// N�mero da Conta Investimento
			$this->Cell(19,0.65,"Conta Investimento: ".$dados_cabecalho["NRCTAINV"],0,1,"L",0,"");
			// Saldo Anterior
			$this->Cell(19,0.65,"Saldo Anterior: ".number_format(str_replace(",",".",$dados_cabecalho["VLSLDANT"]),2,",","."),0,1,"L",0,"");
			
			// Quebra de linha
			$this->Ln();
			
			// Cabe�alho - Data, Hist�rico, Documento, Valor, D/C, Saldo
			$this->Cell(2.25,0.5,"Data","B",0,"L",0,"");
			$this->Cell(0.25,0.5,"",0,0,"L",0,"");
			$this->Cell(6.5,0.5,"Hist�rico","B",0,"L",0,"");
			$this->Cell(0.25,0.5,"",0,0,"L",0,"");
			$this->Cell(2.25,0.5,"Documento","B",0,"R",0,"");
			$this->Cell(0.25,0.5,"",0,0,"L",0,"");
			$this->Cell(3,0.5,"Valor","B",0,"R",0,"");
			$this->Cell(0.25,0.5,"",0,0,"L",0,"");
			$this->Cell(0.75,0.5,"D/C","B",0,"C",0,"");	
			$this->Cell(0.25,0.5,"",0,0,"L",0,"");
			$this->Cell(3,0.5,"Saldo","B",1,"R",0,"");
			
			// Dados - Data, Hist�rico, Documento, Valor, D/C, Saldo
			for ($i = 0; $i < count($dados_extrato); $i++) {
				$this->Cell(2.25,0.5,$dados_extrato[$i]["DTMVTOLT"],0,0,"L",0,"");
				$this->Cell(0.25,0.5,"",0,0,"L",0,"");
				$this->Cell(6.5,0.5,$dados_extrato[$i]["DSHISTOR"],0,0,"L",0,"");
				$this->Cell(0.25,0.5,"",0,0,"L",0,"");
				$this->Cell(2.25,0.5,$dados_extrato[$i]["NRDOCMTO"],0,0,"R",0,"");
				$this->Cell(0.25,0.5,"",0,0,"L",0,"");
				$this->Cell(3,0.5,number_format(str_replace(",",".",$dados_extrato[$i]["VLLANMTO"]),2,",","."),0,0,"R",0,"");
				$this->Cell(0.25,0.5,"",0,0,"L",0,"");
				$this->Cell(0.75,0.5,$dados_extrato[$i]["INDEBCRE"],0,0,"C",0,"");	
				$this->Cell(0.25,0.5,"",0,0,"L",0,"");
				$this->Cell(3,0.5,number_format(str_replace(",",".",$dados_extrato[$i]["VLSLDTOT"]),2,",","."),0,1,"R",0,"");
			}
		}
	}
	
?>