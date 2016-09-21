<?php 

	//************************************************************************//
	//*** Fonte: poupanca_autorizacao_pdf.php                              ***//
	//*** Autor: David                                                     ***//
	//*** Data : Mar�o/2010                   �ltima Altera��o: 00/00/0000 ***//
	//***                                                                  ***//
	//*** Objetivo  : Gerar PDF para Autoriza��o de D�bito para Poupan�a   ***//
	//***                                                                  ***//	 
	//*** Altera��es:                                                      ***//
	//************************************************************************//
	
	// Classe para gera��o de arquivos PDF
	require_once("../../../class/fpdf/fpdf.php");
	
	// Classe para gera��o da Autoriza��o de D�bito em PDF
	class PDF extends FPDF {
	
		// M�todo Construtor
		function PDF($orientation = "P",$unit = "cm",$format = "A4") {
			$this->FPDF($orientation,$unit,$format);
		}	
		
		// Gerar Layout para Impress�o da Autoriza��o em PDF
		function geraAutorizacao($dadosAutorizacao) {										
			$this->AddFont('Letter_Gothic','','letter_gothic.php');
			
			$this->SetFont("Letter_Gothic","",8);			
			$this->SetMargins(1.5,1.5);
		
			$this->AddPage();						
			
			$this->MultiCell(0,0.35,$dadosAutorizacao["NMEXTCOP"]."\nCNPJ ".$dadosAutorizacao["NRDOCNPJ"],0,"C",0);			

			$this->Ln();
			$this->Ln();				
					
			$this->MultiCell(0,0.35,"AUTORIZA��O DE D�BITO EM CONTA-CORRENTE PARA CR�DITO NA POUPAN�A PROGRAMADA\n===========================================================================",0,"C",0);		  
			                         
			$this->Ln();
			$this->Ln();	
			$this->Ln();				
			
			$this->Cell(6,0.35,"Conta/dv: ".formataNumericos("zzzz.zzz-9",$dadosAutorizacao["NRDCONTA"],".-"),0,0,"L",0,"");
			$this->Cell(6,0.35,"N�mero da Poupan�a: ".formataNumericos("zzz.zzz.zz9",$dadosAutorizacao["NRCTRRPP"],"."),0,0,"C",0,"");
			$this->Cell(6,0.35,"Valor: ".number_format(str_replace(",",".",$dadosAutorizacao["VLPRERPP"]),2,",","."),0,1,"R",0,"");
						
			$this->Ln();						
			
			$this->Cell(9,0.35,"Associado: ".$dadosAutorizacao["NMPRIMTL"],0,0,"L",0,"");	
			$this->Cell(9,0.35,"Dia do Anivers�rio: ".$dadosAutorizacao["DDANIVER"],0,1,"R",0,"");

			$this->Ln();
			$this->Ln();	

			$this->MultiCell(0,0.35,"O associado acima qualificado, autoriza d�bito mensal em conta-corrente de dep�sitos � vista, com vencimento em ".$dadosAutorizacao["DTVCTOPP"].", na importancia de R$ ".number_format(str_replace(",",".",$dadosAutorizacao["VLPRERPP"]),2,",",".")." (".str_replace("*","",$dadosAutorizacao["DSPRERPP"]).") a partir do m�s de ".$dadosAutorizacao["DSMESANO"]." de ".$dadosAutorizacao["NRANOINI"].", para cr�dito na sua POUPAN�A PROGRAMADA ".$dadosAutorizacao["NMRESCOP"].".",0,"J",0);			
			
			$this->Ln();
			$this->Ln();

			if ($dadosAutorizacao["FLGSUBST"] == "yes") {
				$this->MultiCell(0,0.35,"O presente instrumento substitui a autoriza��o anterior com o mesmo n�mero, que fica cancelada.",0,"J",0);			
			}
			
			$this->MultiCell(0,0.35,"O d�bito ser� efetuado somente mediante suficiente provis�o de fundos.\nQuando a data de anivers�rio n�o coincidir com dia �til, o d�bito ser� efetuado no primeiro dia �til subsequente.",0,"J",0);
			
			$this->Ln();
			$this->Ln();	

			$this->MultiCell(0,0.35,"A POUPAN�A PROGRAMADA tem as seguintes caracteristicas:",0,"J",0);			
			
			$this->Ln();
			
			$this->MultiCell(0,0.35,"1) Taxa inicial = ".number_format(str_replace(",",".",$dadosAutorizacao["TXAPLICA"]),2,",",".")."% do CDI. Ap�s 30 dias a taxa poder� ser alterada, garantindo-se remunera��o igual a caderneta de poupan�a;",0,"J",0);
			
			$this->Ln();	
			
			$this->MultiCell(0,0.35,"2) Ato cooperativo art. 79 da lei 5764/71;",0,"J",0);			
			
			$this->Ln();				
			
			$this->MultiCell(0,0.35,"3) Classificado como recibo de dep�sito cooperativa, de acordo com a Resolu��o 3.454 do Bacen;",0,"J",0);
						
			$this->Ln();				
			
			$this->MultiCell(0,0.35,"4) Rendimento mensal calculado na data do anivers�rio;",0,"J",0);	

			$this->Ln();				
			
			$this->MultiCell(0,0.35,"5) Saques fora da data de anivers�rio, admitidos a crit�rio da Cooperativa, n�o fazem jus a qualquer rendimento proporcional;",0,"J",0);			

			$this->Ln();				
			
			$this->MultiCell(0,0.35,"6) Os saques dever�o ser comunicados com anteced�ncia min�ma de ".$dadosAutorizacao["NRDIARGT"]." dia(s);",0,"J",0);	
			
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