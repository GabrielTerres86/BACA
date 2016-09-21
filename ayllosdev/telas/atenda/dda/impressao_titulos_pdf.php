<?php 

	/************************************************************************
	  Fonte: impressao_titulos_pdf.php                                 
	  Autor: Gabriel                                                   
	  Data : Abril/2011               Ultima Alteracao: 03/12/2014         
																		  
	  Objetivo  : Script para impressao do detalhamento de titulo DDA  	                                                                 	 
																			 
	  Alteracoes: 12/07/2012 - Alterado parametro de $pdf->Output,     
							   Condicao para Navegador Chrome (Jorge).	
							   
 				  03/12/2014 - De acordo com a circula 3.656 do Banco Central,
							   substituir nomenclaturas Cedente por Beneficiário e  
							   Sacado por Pagador. Chamado 229313 (Jean Reddiga - RKAM)
							   
	************************************************************************/
		
	// Includes para funcao visualizaPDF
	require_once("../../../includes/funcoes.php");	
	// Classe para geração de arquivos PDF
	require_once("../../../class/fpdf/fpdf.php");
			
	class PDF extends FPDF {
		
			function PDF($orientation = "P",$unit = "mm",$format = "A4") {
				$this->FPDF($orientation,$unit,$format);
			}
						
			function geraImpressaoDDA($tituloDDA,$instrucoes,$descontos,$aux_idobjtit2) {
				
				// Inicia geração do extrato
				$this->SetMargins(1.5,1.2);
				
				// Adicina Nova Página ao PDF
				$this->AddPage();
						
				$this->SetFillColor(0,0,0);				
			
				if ((strtoupper(getByTagName($tituloDDA->tags,"flgvenci")) == "VENCIDO")  || (strtoupper($aux_idobjtit2) == "ALL")) {		
					$this->SetFont("Arial","",9);
					$this->Cell(18,0.4,"RECIBO DO PAGADOR",0,1,"R",0,"");
					
					$this->criaDetalhamento($tituloDDA,$instrucoes,$descontos);
					
					$this->Ln(0.45);
					
					$flgFill = true;
					for ($i = 1; $i <= 171; $i++) {
						if ($flgFill) {
							$this->Cell(0.105,0.03,"",0,0,"",1,"");
							$flgFill = false;
						} else {						
							$this->Cell(0.105,0.03,"",0,0,"",0,"");
							$flgFill = true;
						}
					}
					
					$this->Ln();
					
					$this->SetFont("Arial","",7.5);
					$this->Cell(18,0.4,"Corte na linha pontilhada",0,1,"",0,"");
					
					$this->Ln(0.45);
				
					$this->SetFont("Arial","B",13);
					
					$this->Cell(18,0.4,getByTagName($tituloDDA->tags,"dslindig"),0,1,"R",0,"");			
				}
				
				$this->criaDetalhamento($tituloDDA,$instrucoes,$descontos);
				
				if ((strtoupper(getByTagName($tituloDDA->tags,"flgvenci"))  == "VENCIDO") ||  (strtoupper($aux_idobjtit2) == "ALL")) {	
							
					$this->CodigoDeBarras(getByTagName($tituloDDA->tags,"dscodbar"));
					
					$this->Cell(1.7,0.4,"",0,0,"",0,"");			
					
					$this->SetFont("Arial","",9);
					$this->MultiCell(5,0.35,"FICHA DE COMPENSAÇÃO\nAutenticação mecânica     ",0,0,"R",0,"");				
					
					$this->Ln(1.2);
				
				} else {
					$this->Ln(0.45);
				}			
					
				$flgFill = true;
				for ($i = 1; $i <= 171; $i++) {
					if ($flgFill) {
						$this->Cell(0.105,0.03,"",0,0,"",1,"");
						$flgFill = false;
					} else {						
						$this->Cell(0.105,0.03,"",0,0,"",0,"");
						$flgFill = true;
					}
				
				}
				
				$this->Ln();
					
				$this->SetFont("Arial","",7.5);
				$this->Cell(18,0.4,"Corte na linha pontilhada",0,0,"",0,"");
			}
			
			function criaDetalhamento($tituloDDA,$instrucoes,$descontos) {
				$this->Cell(0,0.04,"",0,1,"L",1,"");
				$this->Cell(0,0.06,"",0,1,"L",0,"");
				
				$this->SetFont("Arial","B",8);
				
				$this->Cell(0.05,0.34,"",0,0,"L",1,"");
				$this->Cell(13.9,0.34,"Banco Beneficiario",0,0,"L",0,"");
				$this->Cell(0.05,0.34,"",0,0,"L",1,"");
				$this->Cell(4,0.34,"Situação",0,1,"R",0,"");			
				
				$this->SetFont("Arial","",8);
				
				$this->Cell(0.05,0.34,"",0,0,"L",1,"");
				$this->Cell(13.9,0.34,getByTagName($tituloDDA->tags,'cdbccced')." - ".getByTagName($tituloDDA->tags,'nmbccced'),0,0,"L",0,"");	
				$this->Cell(0.05,0.34,"",0,0,"L",1,"");
				$this->Cell(4,0.34,getByTagName($tituloDDA->tags,"dssittit"),0,1,"R",0,"");	

				$this->Cell(0,0.04,"",0,1,"L",1,"");
				$this->Cell(0,0.06,"",0,1,"L",0,"");			
				
				$this->SetFont("Arial","B",8);
				
				$this->Cell(0.05,0.34,"",0,0,"L",1,"");
				$this->Cell(13.9,0.34,"Beneficiario",0,0,"L",0,"");	
				$this->Cell(0.05,0.34,"",0,0,"L",1,"");
				$this->Cell(4,0.34,"CPF/CNPJ do Beneficiario",0,1,"R",0,"");
				
				$this->SetFont("Arial","",8);
				
				$this->Cell(0.05,0.34,"",0,0,"L",1,"");
				$this->Cell(13.9,0.34,getByTagName($tituloDDA->tags,"nmcedent"),0,0,"L",0,"");	
				$this->Cell(0.05,0.34,"",0,0,"L",1,"");
				$this->Cell(4,0.34,getByTagName($tituloDDA->tags,"dsdocced"),0,1,"R",0,"");
				
				$this->Cell(0,0.04,"",0,1,"L",1,"");
				$this->Cell(0,0.06,"",0,1,"L",0,"");
				
				$this->SetFont("Arial","B",8);			
				
				$this->Cell(0.05,0.34,"",0,0,"L",1,"");
				$this->Cell(3.3,0.34,"Data de Emissão",0,0,"L",0,"");
				$this->Cell(0.05,0.34,"",0,0,"L",1,"");
				$this->Cell(5,0.34,"Número do Documento",0,0,"L",0,"");
				$this->Cell(0.05,0.34,"",0,0,"L",1,"");
				$this->Cell(9.55,0.34,"Espécie",0,1,"L",0,"");
				
				$this->SetFont("Arial","",8);
				
				$this->Cell(0.05,0.34,"",0,0,"L",1,"");
				$this->Cell(3.3,0.34,getByTagName($tituloDDA->tags,"dtemissa"),0,0,"L",0,"");
				$this->Cell(0.05,0.34,"",0,0,"L",1,"");
				$this->Cell(5,0.34,getByTagName($tituloDDA->tags,"nrdocmto"),0,0,"L",0,"");
				$this->Cell(0.05,0.34,"",0,0,"L",1,"");
				$this->Cell(9.55,0.34,getByTagName($tituloDDA->tags,"dsdmoeda"),0,1,"L",0,"");
				
				$this->Cell(0,0.04,"",0,1,"L",1,"");
				$this->Cell(0,0.06,"",0,1,"L",0,"");
				
				$this->SetFont("Arial","B",8);
				
				$this->Cell(0.05,0.34,"",0,0,"L",1,"");
				$this->Cell(3.3,0.34,"Vencimento",0,0,"L",0,"");
				$this->Cell(0.05,0.34,"",0,0,"L",1,"");
				$this->Cell(5,0.34,"Valor do Documento",0,0,"L",0,"");			
				$this->Cell(0.05,0.34,"",0,0,"L",1,"");
				$this->Cell(3.5,0.34,"Dias de Protesto",0,0,"L",0,"");
				$this->Cell(0.05,0.34,"",0,0,"L",1,"");
				$this->Cell(6,0.34,"Nosso Número",0,1,"R",0,"");
				
				$this->SetFont("Arial","",8);
				
				
				$this->Cell(0.05,0.34,"",0,0,"L",1,"");
				$this->Cell(3.3,0.34,getByTagName($tituloDDA->tags,"dtvencto"),0,0,"L",0,"");
				$this->Cell(0.05,0.34,"",0,0,"L",1,"");
				$this->Cell(5,0.34,getByTagName($tituloDDA->tags,"vltitulo"),0,0,"L",0,"");
				$this->Cell(0.05,0.34,"",0,0,"L",1,"");
				$this->Cell(3.5,0.34,getByTagName($tituloDDA->tags,"qtdiapro"),0,0,"L",0,"");
				$this->Cell(0.05,0.34,"",0,0,"L",1,"");
				$this->Cell(6,0.34,getByTagName($tituloDDA->tags,"nossonum"),0,1,"R",0,"");
				
				$this->Cell(0,0.04,"",0,1,"L",1,"");
				$this->Cell(0,0.06,"",0,1,"L",0,"");
							
				$this->SetFont("Arial","B",8);
				
				$this->Cell(0.05,0.34,"",0,0,"L",1,"");
				$this->Cell(9.6,0.34,"Mora Diária",0,0,"L",0,"");
				$this->Cell(0.05,0.34,"",0,0,"L",1,"");
				$this->Cell(8.3,0.34,"Multa",0,1,"R",0,"");	
				
				$this->SetFont("Arial","",8);			
				
				$this->Cell(0.05,0.34,"",0,0,"L",1,"");
				$this->Cell(9.6,0.34,getByTagName($tituloDDA->tags,"dsdamora"),0,0,"L",0,"");
				$this->Cell(0.05,0.34,"",0,0,"L",1,"");
				$this->Cell(8.3,0.34,getByTagName($tituloDDA->tags,"dsdmulta"),0,1,"R",0,"");						
				
				$this->Cell(0,0.04,"",0,1,"L",1,"");
				$this->Cell(0,0.06,"",0,1,"L",0,"");			
				
				$this->SetFont("Arial","B",8);
				
				$this->Cell(0.05,0.34,"",0,0,"L",1,"");
				$this->Cell(5.65,0.34,"Valor do Abatimento",0,0,"L",0,"");
				$this->Cell(0.05,0.34,"",0,0,"L",1,"");
				$this->Cell(7.25,0.34,"Carteira",0,0,"L",0,"");
				$this->Cell(0.05,0.34,"",0,0,"L",1,"");
				$this->Cell(4.95,0.34,"Título Negociado",0,1,"R",0,"");
				
				$this->SetFont("Arial","",8);			
				
				$this->Cell(0.05,0.34,"",0,0,"L",1,"");
				$this->Cell(5.65,0.34,getByTagName($tituloDDA->tags,"vlrabati"),0,0,"L",0,"");
				$this->Cell(0.05,0.34,"",0,0,"L",1,"");
				$this->Cell(7.25,0.34,getByTagName($tituloDDA->tags,"dscartei"),0,0,"L",0,"");
				$this->Cell(0.05,0.34,"",0,0,"L",1,"");
				$this->Cell(4.95,0.34,getByTagName($tituloDDA->tags,"idtitneg"),0,1,"R",0,"");
				
				$this->Cell(0,0.04,"",0,1,"L",1,"");
				$this->Cell(0,0.06,"",0,1,"L",0,"");
				
				$this->SetFont("Arial","B",8);
				
				$this->Cell(0.05,0.34,"",0,0,"L",1,"");
				$this->Cell(17.95,0.34,"Instruções (Texto de responsabilidade do beneficiario)",0,1,"L",0,"");	
				
				$this->SetFont("Arial","",8);
						
				$qtInstruc = 0;		
						
				// Listar Instrucoes
				foreach($instrucoes as $instrucao) {		
					if (getByTagName($instrucao->tags,"nrorditm") != getByTagName($tituloDDA->tags,"nrorditm")) {
						continue;
					}		
					$qtInstruc++;	
					$this->Cell(0.05,0.34,"",0,0,"L",1,"");
					$this->Cell(17.95,0.34,getByTagName($instrucao->tags,"dsdinstr"),0,1,"L",0,"");				
				}			
												
				if ($qtInstruc == 0) {							
					$this->Cell(0.05,0.34,"",0,0,"L",1,"");
					$this->Cell(17.95,0.34,"",0,1,"L",0,"");
				}	
										
				$this->Cell(0,0.04,"",0,1,"L",1,"");
				$this->Cell(0,0.06,"",0,1,"L",0,"");
				
				$this->SetFont("Arial","B",8);
				
				$this->Cell(0.05,0.34,"",0,0,"L",1,"");
				$this->Cell(17.95,0.34,"Valor do Desconto",0,1,"L",0,"");	
				
				$this->SetFont("Arial","",8);
				
				$qtDescto = 0;
				
				// Listar descontos
				foreach ($descontos as $desconto) {									
					if (getByTagName($desconto->tags,"nrorditm") != getByTagName($tituloDDA->tags,"nrorditm")) {
						continue;
					}
					$qtDescto++;
					$this->Cell(0.05,0.34,"",0,0,"L",1,"");
					$this->Cell(17.95,0.34,getByTagName($desconto->tags,"dsdescto"),0,1,"L",0,"");				
				}		

				if ($qtDescto == 0) {								
					$this->Cell(0.05,0.34,"",0,0,"L",1,"");
					$this->Cell(17.95,0.34,"",0,1,"L",0,"");
				}			
				
				$this->Cell(0,0.04,"",0,1,"L",1,"");
				$this->Cell(0,0.06,"",0,1,"L",0,"");
				
				$this->SetFont("Arial","B",8);
				
				$this->Cell(0.05,0.34,"",0,0,"L",1,"");
				$this->Cell(13.9,0.34,"Pagador",0,0,"L",0,"");	
				$this->Cell(0.05,0.34,"",0,0,"L",1,"");
				$this->Cell(4,0.34,"CPF/CNPJ do Pagador",0,1,"R",0,"");
				
				$this->SetFont("Arial","",8);
				
				$this->Cell(0.05,0.34,"",0,0,"L",1,"");
				$this->Cell(13.9,0.34,getByTagName($tituloDDA->tags,"nmdsacad"),0,0,"L",0,"");	
				$this->Cell(0.05,0.34,"",0,0,"L",1,"");
				$this->Cell(4,0.34,getByTagName($tituloDDA->tags,"dsdocsac"),0,1,"R",0,"");
				
				$this->Cell(0,0.04,"",0,1,"L",1,"");
				$this->Cell(0,0.06,"",0,1,"L",0,"");
				
				$this->SetFont("Arial","B",8);
				
				$this->Cell(0.05,0.34,"",0,0,"L",1,"");
				$this->Cell(13.9,0.34,"Sacador Avalista",0,0,"L",0,"");	
				$this->Cell(0.05,0.34,"",0,0,"L",1,"");
				$this->Cell(4,0.34,"Documento Pagador",0,1,"R",0,"");
				
				$this->SetFont("Arial","",8);
				
				$this->Cell(0.05,0.34,"",0,0,"L",1,"");
				$this->Cell(13.9,0.34,getByTagName($tituloDDA->tags,"nmsacava"),0,0,"L",0,"");	
				$this->Cell(0.05,0.34,"",0,0,"L",1,"");
				$this->Cell(4,0.34,getByTagName($tituloDDA->tags,"dsdocsav"),0,1,"R",0,"");	
				
				$this->Cell(0,0.04,"",0,1,"L",1,"");
				$this->Cell(0,0.15,"",0,1,"L",0,"");
			}
			
			//Gerar o Código de Barras
			function CodigoDeBarras($codigo_barras) {
				$codes[0] = "00110";
				$codes[1] = "10001";
				$codes[2] = "01001";
				$codes[3] = "11000";
				$codes[4] = "00101";
				$codes[5] = "10100";
				$codes[6] = "01100";
				$codes[7] = "00011";
				$codes[8] = "10010";
				$codes[9] = "01010";
				
				for ($i = 9; $i >= 0; $i--) { 
					for ($j = 9; $j >= 0; $j--) { 
						$aux_barCode01 = ($i * 10) + $j;
						$aux_barCode02 = "";
						
						for ($k = 1; $k < 6; $k++) { 
							$aux_barCode02 .= substr($codes[$i],($k-1),1).substr($codes[$j],($k-1),1);
						}
						
						$codes[$aux_barCode01] = $aux_barCode02;
					}
				}		
				
				$this->Cell($this->PixelEmCentimetro(5),$this->PixelEmCentimetro(50),"",0,0,"",0,"");
				$this->SetFillColor(0,0,0);
				$this->Cell($this->PixelEmCentimetro(1),$this->PixelEmCentimetro(50),"",0,0,"",1,"");
				$this->SetFillColor(255,255,255);
				$this->Cell($this->PixelEmCentimetro(1),$this->PixelEmCentimetro(50),"",0,0,"",1,"");
				$this->SetFillColor(0,0,0);
				$this->Cell($this->PixelEmCentimetro(1),$this->PixelEmCentimetro(50),"",0,0,"",1,"");
				$this->SetFillColor(255,255,255);
				$this->Cell($this->PixelEmCentimetro(1),$this->PixelEmCentimetro(50),"",0,0,"",1,"");		
				$this->width_CodeBar = 9;
				
				$aux_barCode02 = $codigo_barras;
				
				if (bcmod(strlen($aux_barCode02),2) <> 0) {
					$aux_barCode02 = "0".$aux_barCode02;
				}
				
				while (strlen($aux_barCode02) > 0) {
					$k             = round(substr($aux_barCode02,0,2));
					$aux_barCode02 = substr($aux_barCode02,strlen($aux_barCode02) - (strlen($aux_barCode02) - 2),strlen($aux_barCode02) - 2);			
					$aux_barCode01 = $codes[$k];
					
					for($k = 1; $k < 11; $k += 2){
						if (substr($aux_barCode01,($k-1),1) == "0") {
							$i = 1;
						} else {
							$i = 3;
						}
				
						$this->SetFillColor(0,0,0);
						$this->Cell($this->PixelEmCentimetro($i),$this->PixelEmCentimetro(50),"",0,0,"",1,"");
						$this->width_CodeBar += $i;
						
						if (substr($aux_barCode01,$k,1) == "0") {
							$j = 1;
						} else {
							$j = 3;
						}
				
						$this->SetFillColor(255,255,255);
						$this->Cell($this->PixelEmCentimetro($j),$this->PixelEmCentimetro(50),"",0,0,"",1,"");
						$this->width_CodeBar += $j;
					}
				}
				
				$this->SetFillColor(0,0,0);
				$this->Cell($this->PixelEmCentimetro(3),$this->PixelEmCentimetro(50),"",0,0,"",1,"");
				$this->SetFillColor(255,255,255);
				$this->Cell($this->PixelEmCentimetro(1),$this->PixelEmCentimetro(50),"",0,0,"",1,"");
				$this->SetFillColor(0,0,0);
				$this->Cell($this->PixelEmCentimetro(1),$this->PixelEmCentimetro(50),"",0,0,"",1,"");		
				$this->width_CodeBar += 5;
			}
			
			//Converter Pixel em Centimetro - Unidade de medidade utilizada no PDF
			//O valor 36.7 foi calculado com base no layout do boleto impresso em HTML
			function PixelEmCentimetro($pixel) {
				return doubleval($pixel / 36.7);
			}
						
	} // Fim Classe	
			 
	// Instancia Objeto para gerar arquivo PDF
	$pdf = new PDF("P","cm","A4");	
					
	// Para cada Titulo
	foreach ($titulos as $titulo) {		
		$pdf->geraImpressaoDDA($titulo,$instrucoes,$descontos,"ALL");	
	}	
	
	$navegador = CheckNavigator();
	$tipo = $navegador['navegador'] == 'chrome' ? "I" : "D";
	
	// Gera saída do PDF para o Browser
	$pdf->Output("titulos_bloqueados.pdf",$tipo);		
	
?>	