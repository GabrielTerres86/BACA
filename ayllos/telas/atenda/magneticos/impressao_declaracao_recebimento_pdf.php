<?php 

	/************************************************************************
	  Fonte: impressao_declaracao_recebimento_pdf.php                  
	  Autor: David                                                     
	  Data : Março/2009                   Última Alteração: 20/07/2015
	                                                                     
	  Objetivo  : Gerar PDF Declaração de Recebimento de Magnéticos    
	                                                                    	 
	  Alterações:  11/02/2011 - Aumentar o nome para 50 posicoes (Gabriel)
	  
				   20/07/2015 - Remover os campos Limite, Forma de Saque e Recibo
								de entrega. (James)
	**********************************************************************/
	
	// Classe para geração de arquivos PDF
	require_once("../../../class/fpdf/fpdf.php");
	
	// Classe para geração da Declaracao de acesso ao InternetBank em PDF
	class PDF extends FPDF {
	
		// Método Construtor
		function PDF($orientation = "P",$unit = "cm",$format = "A4") {
			$this->FPDF($orientation,$unit,$format);
		}	
		
		// Gerar Layout para Impressão da Declaracao em PDF
		function geraDeclaracao($dadosDeclaracao) {										
			$this->SetMargins(1.5,1);
		
			$this->AddPage();			
			
			$this->SetFont("Courier","B",9);
			
			$this->MultiCell(0,0.35,"** CARTÃO ".$dadosDeclaracao["NMRESCOP"]." - AUTO ATENDIMENTO **",0,"C",0);			

			$this->Ln();
			$this->Ln();	
			
			$this->SetFont("Courier","",9);
			
			$this->MultiCell(0,0.35,"DECLARAÇÃO DE RECEBIMENTO",0,"C",0);		
			
			$this->Ln();
			$this->Ln();	
			$this->Ln();				
			
			if ($dadosDeclaracao["INPESSOA"] == "1") {			
				$this->MultiCell(0,0.35,"EU, ".$dadosDeclaracao["NMPRIMTL"].", CONTA ".formataNumericos("zzzz.zzz-9",$dadosDeclaracao["NRDCONTA"],".-").", DECLARO TER RECEBIDO O CARTÃO ".$dadosDeclaracao["NMRESCOP"].", COM PROPÓSITO DE PERMITIR SAQUES E CONSULTA DE SALDOS NOS TERMINAIS DE AUTO-ATENDIMENTO DA ".$dadosDeclaracao["NMEXTCOP"].".",0,"J",0);			
			} else {
				$this->MultiCell(0,0.35,"EU, ".$dadosDeclaracao["NMPRIMTL"].", PREPOSTO DA CONTA ".formataNumericos("zzzz.zzz-9",$dadosDeclaracao["NRDCONTA"],".-").", CONFORME TERMO 'ACESSO CAIXA-ELETRÔNICO - SOLICITAÇÃO, AUTORIZAÇÃO DE ACESSO E TERMO DE RESPONSABILIDADE - PESSOA JURÍDICA', DECLARO TER RECEBIDO O CARTÃO ".$dadosDeclaracao["NMRESCOP"].", COM PROPÓSITO DE PERMITIR SAQUES E CONSULTA DE SALDOS NOS TERMINAIS DE AUTO-ATENDIMENTO DA ".$dadosDeclaracao["NMEXTCOP"].".",0,"J",0);			
			}
			
			$this->Ln();
			$this->Ln();			
			
			$this->Cell(3.8,0.35,"NÚMERO DO CARTÃO:",0,0,"R",0,"");
			$this->Cell(14.2,0.35,formataNumericos("9999.9999.9999.9999",$dadosDeclaracao["NRCARTAO"],"."),0,1,"L",0,"");			

			$this->Ln();			
			
			$this->Cell(3.8,0.35,"DATA DE VALIDADE:",0,0,"R",0,"");
			$this->Cell(14.2,0.35,$dadosDeclaracao["DTVALCAR"],0,1,"L",0,"");				
			
			$this->Ln();			
			
			$this->Cell(3.8,0.35,"DATA DE EMISSÃO:",0,0,"R",0,"");
			$this->Cell(14.2,0.35,$dadosDeclaracao["DTEMSCAR"],0,1,"L",0,"");												
			
			$this->Ln();
			$this->Ln();
			
			$this->MultiCell(0,0.35,$dadosDeclaracao["DSREFERE"],0,"J",0);							
			
			$this->Ln();
			$this->Ln();
			$this->Ln();
			
			$this->Cell(8.6,0.35,($dadosDeclaracao["INPESSOA"] == "1" ? "TITULAR" : "PREPOSTO"),0,0,"L",0,"");
			$this->Cell(1.5,0.35,"",0,0,"L",0,"");
			$this->Cell(7.9,0.35,"OPERADOR",0,1,"L",0,"");
			
			$this->Ln();
			$this->Ln();
			$this->Ln();			
			
			$this->Cell(8.6,0.35,"--------------------------------------------",0,0,"L",0,"");
			$this->Cell(1.5,0.35,"",0,0,"L",0,"");
			$this->Cell(7.9,0.35,"----------------------------------------",0,1,"L",0,"");	
			$this->Cell(8.6,0.35,$dadosDeclaracao["NMPRIMTL"],0,0,"L",0,"");
			$this->Cell(1.5,0.35,"",0,0,"L",0,"");
			$this->Cell(7.9,0.35,$dadosDeclaracao["NMOPERAD"],0,1,"L",0,"");		
			$this->Cell(8.6,0.35,"",0,0,"L",0,"");
			$this->Cell(1.5,0.35,"",0,0,"L",0,"");
			$this->Cell(7.9,0.35,$dadosDeclaracao["DSMVTOLT"],0,1,"L",0,"");									
					
			$this->Ln();	
			$this->Ln();			
			
			$this->MultiCell(0,0.35,"--(Corte aqui)-------------------------------------------------------------------------------",0,"L",0);			
						
			$this->Ln();	
			$this->Ln();		
			
			$this->SetFont("Courier","B",9);
			
			$this->MultiCell(0,0.35,"** CARTÃO ".$dadosDeclaracao["NMRESCOP"]." - AUTO ATENDIMENTO **",0,"C",0);			

			$this->Ln();
			$this->Ln();	
			
			$this->SetFont("Courier","",9);
			
			$this->MultiCell(0,0.35,"DICAS DE UTILIZAÇÃO",0,"C",0);		
			
			$this->Ln();
			$this->Ln();	
			$this->Ln();				
			
			$this->Cell(0.5,0.35,"1)",0,0,"L",0,"");
			$this->Cell(17.5,0.35,"GUARDE SEMPRE EM UM LUGAR SEGURO E LONGE DE FONTES ELETRO-MAGNÉTICAS (IMÃS, TELEFONES,",0,1,"L",0,"");
			$this->Cell(0.5,0.35,"",0,0,"L",0,""); 
			$this->Cell(17.5,0.35,"CAIXAS DE SOM, ETC);",0,1,"L",0,""); 
			
			$this->Ln();	
			
			$this->Cell(0.5,0.35,"2)",0,0,"L",0,"");
			$this->Cell(17.5,0.35,"NUNCA DIGA A SUA SENHA A NINGUÉM;",0,1,"L",0,"");						
			
			$this->Ln();				
			
			$this->Cell(0.5,0.35,"3)",0,0,"L",0,"");
			$this->Cell(17.5,0.35,"NÃO PEÇA AJUDA À PESSOAS ESTRANHAS!",0,1,"L",0,"");
			$this->Cell(0.5,0.35,"",0,0,"L",0,""); 
			$this->Cell(17.5,0.35,"PROCURE SEMPRE UM POSTO DA ".$dadosDeclaracao["NMRESCOP"].".",0,1,"L",0,""); 
			
			$this->Ln();
			$this->Ln();
			
			$this->MultiCell(0,0.35,"DADOS DO CARTÃO",0,"C",0);			

			$this->Ln();
			$this->Ln();							
			
			$this->Cell(3.8,0.35,"CONTA:",0,0,"R",0,"");
			$this->Cell(14.2,0.35,formataNumericos("zzzz.zzz-9",$dadosDeclaracao["NRDCONTA"],".-"),0,1,"L",0,"");		

			$this->Ln();	
			
			$this->Cell(3.8,0.35,($dadosDeclaracao["INPESSOA"] == "1" ? "TITULAR: " : "PREPOSTO: "),0,0,"R",0,"");
			$this->Cell(14.2,0.35,$dadosDeclaracao["NMPRIMTL"],0,1,"L",0,"");			

			$this->Ln();				

			$this->Cell(3.8,0.35,"NÚMERO DO CARTÃO:",0,0,"R",0,"");
			$this->Cell(14.2,0.35,formataNumericos("9999.9999.9999.9999",$dadosDeclaracao["NRCARTAO"],"."),0,1,"L",0,"");			

			$this->Ln();			
			
			$this->Cell(3.8,0.35,"DATA DE VALIDADE:",0,0,"R",0,"");
			$this->Cell(14.2,0.35,$dadosDeclaracao["DTVALCAR"],0,1,"L",0,"");				
			
			$this->Ln();			
			
			$this->Cell(3.8,0.35,"DATA DE EMISSÃO:",0,0,"R",0,"");
			$this->Cell(14.2,0.35,$dadosDeclaracao["DTEMSCAR"],0,1,"L",0,"");											
			
			$this->Ln();
			$this->Ln();
			
			$this->Cell(3.8,0.35,"OPERADOR:",0,0,"R",0,"");
			$this->Cell(14.2,0.35,$dadosDeclaracao["NMOPERAD"]." - ".$dadosDeclaracao["DSMVTOLT"],0,1,"L",0,"");		
		}
	}
	
?>