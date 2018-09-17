<?php 

	//************************************************************************//
	//*** Fonte: poupanca_autorizacao_pdf.php                              ***//
	//*** Autor: David                                                     ***//
	//*** Data : Março/2010                   Última Alteração: 00/00/0000 ***//
	//***                                                                  ***//
	//*** Objetivo  : Gerar PDF para Autorização de Débito para Poupança   ***//
	//***                                                                  ***//	 
	//*** Alterações:                                                      ***//
	//************************************************************************//
	
	// Classe para geração de arquivos PDF
	require_once("../../../class/fpdf/fpdf.php");
	
	// Classe para geração da Autorização de Débito em PDF
	class PDF extends FPDF {
	
		// Método Construtor
		function PDF($orientation = "P",$unit = "cm",$format = "A4") {
			$this->FPDF($orientation,$unit,$format);
		}	
		
		// Gerar Layout para Impressão da Autorização em PDF
		function geraAutorizacao($dadosAutorizacao) {										
			$this->AddFont('Letter_Gothic','','letter_gothic.php');
			
			$this->SetFont("Letter_Gothic","",8);			
			$this->SetMargins(1.5,1.5);
		
			$this->AddPage();						
			
			$this->MultiCell(0,0.35,$dadosAutorizacao["NMEXTCOP"]."\nCNPJ ".$dadosAutorizacao["NRDOCNPJ"],0,"C",0);			

			$this->Ln();
			$this->Ln();				
					
			$this->MultiCell(0,0.35,"AUTORIZAÇÃO DE DÉBITO EM CONTA-CORRENTE PARA CRÉDITO NA POUPANÇA PROGRAMADA\n===========================================================================",0,"C",0);		  
			                         
			$this->Ln();
			$this->Ln();	
			$this->Ln();				
			
			$this->Cell(6,0.35,"Conta/dv: ".formataNumericos("zzzz.zzz-9",$dadosAutorizacao["NRDCONTA"],".-"),0,0,"L",0,"");
			$this->Cell(6,0.35,"Número da Poupança: ".formataNumericos("zzz.zzz.zz9",$dadosAutorizacao["NRCTRRPP"],"."),0,0,"C",0,"");
			$this->Cell(6,0.35,"Valor: ".number_format(str_replace(",",".",$dadosAutorizacao["VLPRERPP"]),2,",","."),0,1,"R",0,"");
						
			$this->Ln();						
			
			$this->Cell(9,0.35,"Associado: ".$dadosAutorizacao["NMPRIMTL"],0,0,"L",0,"");	
			$this->Cell(9,0.35,"Dia do Aniversário: ".$dadosAutorizacao["DDANIVER"],0,1,"R",0,"");

			$this->Ln();
			$this->Ln();	

			$this->MultiCell(0,0.35,"O associado acima qualificado, autoriza débito mensal em conta-corrente de depósitos à vista, com vencimento em ".$dadosAutorizacao["DTVCTOPP"].", na importancia de R$ ".number_format(str_replace(",",".",$dadosAutorizacao["VLPRERPP"]),2,",",".")." (".str_replace("*","",$dadosAutorizacao["DSPRERPP"]).") a partir do mês de ".$dadosAutorizacao["DSMESANO"]." de ".$dadosAutorizacao["NRANOINI"].", para crédito na sua POUPANÇA PROGRAMADA ".$dadosAutorizacao["NMRESCOP"].".",0,"J",0);			
			
			$this->Ln();
			$this->Ln();

			if ($dadosAutorizacao["FLGSUBST"] == "yes") {
				$this->MultiCell(0,0.35,"O presente instrumento substitui a autorização anterior com o mesmo número, que fica cancelada.",0,"J",0);			
			}
			
			$this->MultiCell(0,0.35,"O débito será efetuado somente mediante suficiente provisão de fundos.\nQuando a data de aniversário não coincidir com dia útil, o débito será efetuado no primeiro dia útil subsequente.",0,"J",0);
			
			$this->Ln();
			$this->Ln();	

			$this->MultiCell(0,0.35,"A POUPANÇA PROGRAMADA tem as seguintes caracteristicas:",0,"J",0);			
			
			$this->Ln();
			
			$this->MultiCell(0,0.35,"1) Taxa inicial = ".number_format(str_replace(",",".",$dadosAutorizacao["TXAPLICA"]),2,",",".")."% do CDI. Após 30 dias a taxa poderá ser alterada, garantindo-se remuneração igual a caderneta de poupança;",0,"J",0);
			
			$this->Ln();	
			
			$this->MultiCell(0,0.35,"2) Ato cooperativo art. 79 da lei 5764/71;",0,"J",0);			
			
			$this->Ln();				
			
			$this->MultiCell(0,0.35,"3) Classificado como recibo de depósito cooperativa, de acordo com a Resolução 3.454 do Bacen;",0,"J",0);
						
			$this->Ln();				
			
			$this->MultiCell(0,0.35,"4) Rendimento mensal calculado na data do aniversário;",0,"J",0);	

			$this->Ln();				
			
			$this->MultiCell(0,0.35,"5) Saques fora da data de aniversário, admitidos a critério da Cooperativa, não fazem jus a qualquer rendimento proporcional;",0,"J",0);			

			$this->Ln();				
			
			$this->MultiCell(0,0.35,"6) Os saques deverão ser comunicados com antecedência miníma de ".$dadosAutorizacao["NRDIARGT"]." dia(s);",0,"J",0);	
			
			$this->Ln();
			$this->Ln();
									
			$this->MultiCell(0,0.35,$dadosAutorizacao["NMCIDADE"]." ".$dadosAutorizacao["CDUFDCOP"].", ".$dadosAutorizacao["DTMVTOLT"].".",0,"J",0);											
			
			$this->Ln();
			$this->Ln();
			$this->Ln();
			$this->Ln();
			
			$this->Cell(8.5,0.35,"","B",0,"L",0,"");
			$this->Cell(1,0.35,"",0,0,"L",0,"");
			$this->Cell(8.5,0.35,"","B",1,"L",0,"");
			$this->Cell(8.5,0.35,$dadosAutorizacao["NMPRIMTL"],0,0,"L",0,"");	
			$this->Cell(1,0.35,"",0,0,"L",0,"");
			$this->Cell(8.5,0.35,$dadosAutorizacao["NMEXCOP1"],0,1,"C",0,"");	
			$this->Cell(8.5,0.35,"",0,0,"L",0,"");
			$this->Cell(1,0.35,"",0,0,"L",0,"");
			$this->Cell(8.5,0.35,$dadosAutorizacao["NMEXCOP2"],0,1,"C",0,"");
		}
	}
	
?>