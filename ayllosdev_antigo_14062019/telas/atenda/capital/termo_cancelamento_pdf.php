<?php 

	/************************************************************************
	      Fonte: termo_cancelamento_pdf.php                                
	      Autor: David                                                     
	      Data : Outubro/2007                 кltima Alteraчуo: 10/09/2013 
	                                                                     
	      Objetivo  : Gerar PDF do termo de cancelamento do Plano de       
	                  Capital                                              
	                                                                  	 
	      Alteraчѕes: 04/11/2008 - UF da data a partir da temp-table       
	                              (Guilherme).  

					  10/02/2011 - Aumentar nome para 50 posicoes (Gabriel)

					  10/09/2013 - Removido cabecalho de informacoes para
					               o operador. (Fabricio)
	************************************************************************/
	
	// Classe para geraчуo de arquivos PDF
	require_once("../../../class/fpdf/fpdf.php");
	
	// Classe para geraчуo do termo de cancelamento de plano de capital em PDF
	class PDF extends FPDF {

		// Mщtodo Construtor
		function PDF($orientation = "P",$unit = "cm",$format = "A4") {
			$this->FPDF($orientation,$unit,$format);
		}
		
		// Gerar Layout para Impressуo do termo em PDF
		function geraTermo($dados_termo) {		
			// Seta Largura das Margens
			$this->SetMargins(2,3);
			
			// Adicina Nova Pсgina ao PDF
			$this->AddPage();
			
			// Setando fonte estilo Courier, tamanho 10, na cor preta
   		$this->SetFont("Courier","",10);
			$this->SetTextColor(0,0,0);
			
			// Nome da cooperativa e CNPJ
			$this->MultiCell(17,0.5,$dados_termo["NMEXTCOP"]."\n".$dados_termo["NRDOCNPJ"],0,"C",0);			

			// Quebra de linhas
			$this->Ln();
			$this->Ln();
			$this->Ln();
			$this->Ln();
			
			// Setando fonte estilo Courier, tamanho 10, sublinhada
			$this->SetFont("Courier","U",10);
			
			// Tэtulo do termo
			$this->Cell(17,0.5,"TERMO DE CANCELAMENTO DE DЩBITO MENSAL PARA AUMENTO DE CAPITAL",0,1,"C",0,"");	
			
			// Quebra de linhas
			$this->Ln();
			$this->Ln();
			$this->Ln();
			
			// Setando fonte estilo Courier, tamanho 10
			$this->SetFont("Courier","",10);
			
			// Conta/dv, Nњmero e Valor do plano para cancelamento
			$this->Cell(5.66,0.5,"Conta/dv: ".$dados_termo["NRDCONTA"],0,0,"L",0,"");
			$this->Cell(5.66,0.5,"Nњmero do Plano: ".$dados_termo["NRCANCEL"],0,0,"L",0,"");
			$this->Cell(5.66,0.5,"Valor: ".number_format(str_replace(",",".",$dados_termo["VLCANCEL"]),2,",","."),0,1,"L",0,"");	
			
			// Quebra de linhas
			$this->Ln();	
			
			// Nome do associado
			$this->Cell(17,0.5,"Associado: ".$dados_termo["NMPRIMTL"],0,1,"L",0,"");	
			
			// Quebra de linhas
			$this->Ln();
			$this->Ln();
			$this->Ln();
			$this->Ln();
			
			// Descriчуo do termo
			$this->MultiCell(17,0.5,"Solicito pela presente, o cancelamento da autorizaчуo de dщbito mensal em conta-corrente para aumento de capital sob o nњmero ".$dados_termo["NRCTRPLA"]." efetuado em ".$dados_termo["DTINIPLA"].".",0,"J",0);			

			// Quebra de linhas
			$this->Ln();
			$this->Ln();
			$this->Ln();
			$this->Ln();
			
			// Cidade e Data
			$this->Cell(17,0.5,$dados_termo["NMCIDADE"]." ".$dados_termo["CDUFDCOP"].", ".$dados_termo["DTMVTOLT"].".",0,1,"L",0,"");	
			
			// Quebra de linhas
			$this->Ln();
			$this->Ln();
			$this->Ln();
			$this->Ln();			
			
			// Local para assinaturas - Associado e Cooperativa
			$this->Cell(8.25,0.5,"","B",0,"L",0,"");
			$this->Ln();
			///$this->Cell(0.5,0.5,"",0,0,"L",0,"");
			//$this->Cell(8.25,0.5,"","B",1,"L",0,"");	
			$this->Cell(8.25,0.5,$dados_termo["NMPRIMTL"],0,0,"L",0,"");
			
			// Quebra de linhas
			$this->Ln();
			$this->Ln();
			$this->Ln();
			$this->Ln();
			$this->Ln();
			
			$this->Cell(8.25,0.5,"","B",0,"L",0,"");
			$this->Ln();
			$this->Cell(8.25,0.5,$dados_termo["NMRESCOP"],0,0,"L",0,"");
			
		}
	}
	
?>