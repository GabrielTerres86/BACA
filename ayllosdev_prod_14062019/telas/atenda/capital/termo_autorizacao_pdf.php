<?php 

	/*************************************************************************
	   Fonte: termo_autorizacao_pdf.php                                 
	   Autor: David                                                     
	   Data : Outubro/2007                 �ltima Altera��o: 26/02/2014 
	                                                                     
	   Objetivo  : Gerar PDF do termo de autoriza��o do Plano de        
	               Capital                                             
	                                                                   	 
	   Altera��es: 04/11/2008 - UF da data a partir da temp-table       
                              (Guilherme).   

				   10/02/2011 - Aumentar nome para 50 posicoes (Gabriel).
				   26/02/2014 - Adicionado tratamento com 'CDTIPCOR'. (Fabricio)
                   15/08/2014 - Alteracao do conteudo do Termo de Plano de 
                                Capital (Guilherme/SUPERO)
	************************************************************************/
	
	// Classe para gera��o de arquivos PDF
	require_once("../../../class/fpdf/fpdf.php");
	
	// Classe para gera��o do termo de autoriza��o de plano de capital em PDF
	class PDF extends FPDF {

		// M�todo Construtor
		function PDF($orientation = "P",$unit = "cm",$format = "A4") {
			$this->FPDF($orientation,$unit,$format);
		}
		
		// Gerar Layout para Impress�o do termo em PDF
		function geraTermo($dados_termo) {		
			// Seta Largura das Margens
			$this->SetMargins(2,3);
			
			// Adicina Nova P�gina ao PDF
			$this->AddPage();
			
			// Setando fonte estilo Courier, tamanho 10, na cor preta
   	        $this->SetFont("Courier","",10);
			$this->SetTextColor(0,0,0);
			
			// Nome da cooperativa e CNPJ
			$this->MultiCell(17,0.5,$dados_termo["NMEXTCOP"]."\n".$dados_termo["NRDOCNPJ"],0,"C",0);			

			// Quebra de linhas
			$this->Ln();
			$this->Ln();
			
			// Setando fonte estilo Courier, tamanho 10, sublinhada
			$this->SetFont("Courier","U",10);
			
			// T�tulo do termo
			$this->Cell(17,0.5,"AUTORIZA��O DE D�BITO EM CONTA-CORRENTE PARA AUMENTO DE CAPITAL",0,1,"C",0,"");	
			
			// Quebra de linhas
			$this->Ln();
			$this->Ln();
			
			// Setando fonte estilo Courier, tamanho 10
			$this->SetFont("Courier","",10);
			
			// Conta/dv, N�mero e Valor do plano para cancelamento
			$this->Cell(5.82,0.5,"Conta/dv: ".$dados_termo["NRDCONTA"],0,0,"L",0,"");
			$this->Cell(5.5,0.5,"N�mero do Plano: ".formataNumericos("zzz.zzz.zzz",$dados_termo["NRCTRPLA"],"."),0,0,"L",0,"");
			$this->Cell(5.66,0.5,"Valor: ".number_format(str_replace(",",".",$dados_termo["VLPREPLA"]),2,",","."),0,1,"R",0,"");	
			
			// Quebra de linhas
			$this->Ln();	
			
			// Nome do associado
			$this->Cell(10,0.5,"Associado: ".$dados_termo["NMPRIMTL"],0,0,"L",0,"");	
			
			// Se d�bito em conta mostra dia do d�bito
			if ($dados_termo["FLGPAGTO"] == "no") { 			
				$this->Cell(7,0.5,"Dia do d�bito: ".$dados_termo["DIADEBIT"],0,0,"R",0,"");
			}
			
			// Quebra de linhas
			$this->Ln();
			$this->Ln();
			$this->Ln();
			$this->Ln();
			
			// Descri��o do termo
			$this->MultiCell(17,0.5,"O associado acima qualificado autoriza a realiza��o do d�bito mensal em sua conta corrente de deposito a vista, no valor de R$ ".number_format(str_replace(",",".",$dados_termo["VLPREPLA"]),2,",",".")." (".substr($dados_termo["DSPREPLA.1"],0,strpos($dados_termo["DSPREPLA.1"],"*")).") a partir do m�s de ".$dados_termo["DSMESANO"] . ", para integraliza��o de Cotas de CAPITAL.",0,"J",0);			

			// Quebra de linhas
			$this->Ln();
			$this->Ln();
			
			$this->MultiCell(17,0.5,"Este valor ser� reajustado ap�s o per�odo de 12 meses, com base em:");
			
			if ($dados_termo["CDTIPCOR"] == "0") {
			
				$this->MultiCell(17,0.5,"(   ) Corre��o monet�ria pela vari��o do IPCA (�ndice Nacional de Pre�os ao Consumidor Amplo);");
			
				$this->Ln();
							
				$this->MultiCell(17,0.5,"(   ) Valor fixo;");
			
				$this->Ln();
								
				$this->MultiCell(17,0.5,"( X ) Sem reajuste autom�tico de valor.");
				
			}
			else if ($dados_termo["CDTIPCOR"] == "1") {
			
				$this->MultiCell(17,0.5,"( X ) Corre��o monet�ria pela vari��o do IPCA (�ndice Nacional de Pre�os ao Consumidor Amplo);");
			
				$this->Ln();
			
				$this->MultiCell(17,0.5,"(   ) Valor fixo;");
			
				$this->Ln();
				
				$this->MultiCell(17,0.5,"(   ) Sem reajuste autom�tico de valor.");
			
			} else {
			
				$this->MultiCell(17,0.5,"(   ) Corre��o monet�ria pela vari��o do IPCA (�ndice Nacional de Pre�os ao Consumidor Amplo);");
			
				$this->Ln();
			
				$this->MultiCell(17,0.5,"( X ) Valor fixo de R$ ".number_format(str_replace(",",".",$dados_termo["VLCORFIX"]),2,",",".").";");
			
				$this->Ln();
				
				$this->MultiCell(17,0.5,"(   ) Sem reajuste autom�tico de valor.");
			}
			
			$this->Ln();
			$this->Ln();

			// Descri��o do termo
			//$this->MultiCell(17,0.5,"A presente autoriza��o, serve inclusive como instrumento legal de subscri��o e integraliza��o de capital na Cooperativa de Cr�dito, que se dar� concomitantemente, no momento do d�bito em conta-corrente.",0,"J",0);			
			
			// Quebra de linhas
			$this->Ln();
			$this->Ln();
			
			// Descri��o do termo
			if ($dados_termo["FLGPAGTO"] == "yes") { // Se d�bito em folha
				$this->MultiCell(17,0.5,"O d�bito se dar� sempre na data em que ocorrer o cr�dito do sal�rio, limitado ao saldo l�quido do mesmo.",0,"J",0);						
			} else { // Se d�bito em conta
				$this->MultiCell(17,0.5,"O d�bito ser� efetuado desde que haja provis�o de fundos na conta corrente.\nCaso a data estabelecida para d�bito cair no s�bado, domingo ou feriado, o lan�amento ser� efetuado no primeiro dia �til subsequente.",0,"J",0);
			}
			
			// Quebra de linhas
			$this->Ln();
			$this->Ln();
			$this->Ln();
			
			// Cidade e Data
			$this->Cell(17,0.5,$dados_termo["NMCIDADE"]." ".$dados_termo["CDUFDCOP"].", ".$dados_termo["DTMVTOLT"].".",0,1,"L",0,"");	
			
			// Quebra de linhas
			$this->Ln();
			$this->Ln();
			$this->Ln();
			
			// Local para assinaturas - Associado e Cooperativa
		
			$this->Cell(8.25,0.5,"","B",1,"L",0,"");	
			$this->Cell(8.25,0.5,$dados_termo["NMPRIMTL"],0,0,"L",0,"");
			
			// Quebra de linhas
			$this->Ln();
			$this->Ln();
			$this->Ln();
					
			$this->Cell(8.25,0.5,"","B",0,"L",0,"");
			$this->Ln();
			$this->MultiCell(8.25,0.5,trim($dados_termo["NMRESCOP.1"])."\n".trim($dados_termo["NMRESCOP.2"]),0,"C",0);						
		}
	}
	
?>