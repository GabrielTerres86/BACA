<?php 

	//************************************************************************//
	//*** Fonte: termo_adesao_pdf.php                                      ***//
	//*** Autor: David                                                     ***//
	//*** Data : Julho/2008                   �ltima Altera��o: 00/00/0000 ***//
	//***                                                                  ***//
	//*** Objetivo  : Gerar PDF do termo de adesao de acesso a Internet    ***//
	//***                                                                  ***//	 
	//*** Altera��es:                                                      ***//
	//************************************************************************//
	
	// Classe para gera��o de arquivos PDF
	require_once("../../../class/fpdf/fpdf.php");
	
	// Classe para gera��o do termo de adesao em PDF
	class PDF extends FPDF {

		// M�todo Construtor
		function PDF($orientation = "P",$unit = "cm",$format = "A4") {
			$this->FPDF($orientation,$unit,$format);
		}
		
		// Gerar Layout para Impress�o do Termo de Ades�o em PDF
		function geraTermo($dadosAdesao) {		
			$this->SetMargins(2,3);
			
			$this->AddPage();
						
			$this->SetFont("Courier","B",10);
			
			$this->MultiCell(0,0.5,"TERMO DE ADES�O AOS SERVI�OS DE COBRAN�A BANC�RIA",0,"C",0);			

			$this->Ln();
			$this->Ln();
			$this->Ln();	
			
			$this->SetFont("Courier","",10);
			
			$strTermo = "";
			$strTermo .= $dadosAdesao["NMPRIMTL"].", titular da conta corrente no. ".formataNumericos("zzzz.zzz-9",$dadosAdesao["NRDCONTA"],".-").", na qualidade de Cooperado da ".$dadosAdesao["NMEXTCOP"].", rua ".$dadosAdesao["DSENDCOP"]." no. ".$dadosAdesao["NRENDCOP"].", bairro ".$dadosAdesao["NMBAIRRO"].", CEP ".formataNumericos("99999-999",$dadosAdesao["NRCEPEND"],"-").", ".$dadosAdesao["NMCIDADE"]." - ".$dadosAdesao["CDUFDCOP"].", CNPJ ".$dadosAdesao["NRDOCNPJ"].", resolve firmar o presente TERMO DE ADES�O aos Servi�os de Cobran�a Banc�ria disponibilizados pela Cooperativa, nos exatos termos do disposto nas CONDI��ES GERAIS APL�CAVEIS AO CONTRATO DE CONTA CORRENTE E CONTA INVESTIMENTO, ".trim($dadosAdesao["DSCLACC1"]);
			$strTermo .= $dadosAdesao["DSCLACC2"] <> "" ? " ".trim($dadosAdesao["DSCLACC2"]) : "";
			$strTermo .= $dadosAdesao["DSCLACC3"] <> "" ? " ".trim($dadosAdesao["DSCLACC3"]) : "";
			$strTermo .= $dadosAdesao["DSCLACC4"] <> "" ? " ".trim($dadosAdesao["DSCLACC4"]) : "";
			$strTermo .= $dadosAdesao["DSCLACC5"] <> "" ? " ".trim($dadosAdesao["DSCLACC5"]) : "";
			$strTermo .= $dadosAdesao["DSCLACC6"] <> "" ? " ".trim($dadosAdesao["DSCLACC6"]) : "";			
			$strTermo .= " as quais o subscrevente adere e declara, ao assinar este termo, delas ter pleno conhecimento, estar de acordo com seu teor, ter recebido c�pia das referidas CONDI��ES GERAIS, bem como das informa��es t�cnicas referentes a sistem�tica de transmiss�o e recep��o de dados.";
			
			$this->MultiCell(0,0.5,$strTermo,0,"J",0);			
				
			$this->Ln();
			$this->Ln();
			$this->Ln();
			
			$this->MultiCell(0,0.5,$dadosAdesao["DSMVTOLT"],0,"J",0);							
			
			$this->Ln();
			$this->Ln();
			$this->Ln();
			$this->Ln();
			
			$this->Cell(4,0.5,"",0,0,"L",0,"");
			$this->Cell(9,0.5,"","B",0,"C",0,"");
			$this->Cell(4,0.5,"",0,1,"L",0,"");
			$this->Cell(4,0.5,"",0,0,"L",0,"");
			$this->Cell(9,0.5,$dadosAdesao["NMPRIMTL"],0,0,"C",0,"");
			$this->Cell(4,0.5,"",0,1,"L",0,"");
			$this->Cell(4,0.5,"",0,0,"L",0,"");
			$this->Cell(9,0.5,"CPF/CNPJ: ".$dadosAdesao["NRCPFCGC"],0,0,"C",0,"");
			$this->Cell(4,0.5,"",0,1,"L",0,"");						
			
			$this->Ln();
			$this->Ln();
			
			$this->MultiCell(0,0.5,"De acordo",0,"J",0);
			
			$this->Ln();
			$this->Ln();			
			
			$this->Cell(2.5,0.5,"",0,0,"L",0,"");
			$this->Cell(12,0.5,"","B",0,"C",0,"");
			$this->Cell(2.5,0.5,"",0,1,"L",0,"");
			$this->Cell(2.5,0.5,"",0,0,"L",0,"");
			$this->Cell(12,0.5,$dadosAdesao["NMEXTCOP"],0,0,"C",0,"");
			$this->Cell(2.5,0.5,"",0,1,"L",0,"");
			$this->Cell(2.5,0.5,"",0,0,"L",0,"");
			$this->Cell(12,0.5,$dadosAdesao["NRDOCNPJ"],0,0,"C",0,"");
			$this->Cell(2.5,0.5,"",0,1,"L",0,"");				
			
			$this->Ln();
			$this->Ln();
			$this->Ln();	
			$this->Ln();						
			
			$this->Cell(7,0.5,"","B",1,"L",0,"");
			$this->Cell(7,0.5,$dadosAdesao["NMOPERAD"],0,1,"L",0,"");
			$this->Cell(7,0.5,$dadosAdesao["DSMVTOPE"],0,1,"L",0,"");
		}
	}
	
?>