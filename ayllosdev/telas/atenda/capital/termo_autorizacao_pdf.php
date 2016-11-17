<?php 

	/*************************************************************************
	   Fonte: termo_autorizacao_pdf.php                                 
	   Autor: David                                                     
	   Data : Outubro/2007                 Última Alteração: 26/02/2014 
	                                                                     
	   Objetivo  : Gerar PDF do termo de autorização do Plano de        
	               Capital                                             
	                                                                   	 
	   Alterações: 04/11/2008 - UF da data a partir da temp-table       
                              (Guilherme).   

				   10/02/2011 - Aumentar nome para 50 posicoes (Gabriel).
				   26/02/2014 - Adicionado tratamento com 'CDTIPCOR'. (Fabricio)
                   15/08/2014 - Alteracao do conteudo do Termo de Plano de 
                                Capital (Guilherme/SUPERO)
	************************************************************************/
	
	// Classe para geração de arquivos PDF
	require_once("../../../class/fpdf/fpdf.php");
	
	// Classe para geração do termo de autorização de plano de capital em PDF
	class PDF extends FPDF {

		// Método Construtor
		function PDF($orientation = "P",$unit = "cm",$format = "A4") {
			$this->FPDF($orientation,$unit,$format);
		}
		
		// Gerar Layout para Impressão do termo em PDF
		function geraTermo($dados_termo) {		
			// Seta Largura das Margens
			$this->SetMargins(2,3);
			
			// Adicina Nova Página ao PDF
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
			
			// Título do termo
			$this->Cell(17,0.5,"AUTORIZAÇÃO DE DÉBITO EM CONTA-CORRENTE PARA AUMENTO DE CAPITAL",0,1,"C",0,"");	
			
			// Quebra de linhas
			$this->Ln();
			$this->Ln();
			
			// Setando fonte estilo Courier, tamanho 10
			$this->SetFont("Courier","",10);
			
			// Conta/dv, Número e Valor do plano para cancelamento
			$this->Cell(5.82,0.5,"Conta/dv: ".$dados_termo["NRDCONTA"],0,0,"L",0,"");
			$this->Cell(5.5,0.5,"Número do Plano: ".formataNumericos("zzz.zzz.zzz",$dados_termo["NRCTRPLA"],"."),0,0,"L",0,"");
			$this->Cell(5.66,0.5,"Valor: ".number_format(str_replace(",",".",$dados_termo["VLPREPLA"]),2,",","."),0,1,"R",0,"");	
			
			// Quebra de linhas
			$this->Ln();	
			
			// Nome do associado
			$this->Cell(10,0.5,"Associado: ".$dados_termo["NMPRIMTL"],0,0,"L",0,"");	
			
			// Se débito em conta mostra dia do débito
			if ($dados_termo["FLGPAGTO"] == "no") { 			
				$this->Cell(7,0.5,"Dia do débito: ".$dados_termo["DIADEBIT"],0,0,"R",0,"");
			}
			
			// Quebra de linhas
			$this->Ln();
			$this->Ln();
			$this->Ln();
			$this->Ln();
			
			// Descrição do termo
			$this->MultiCell(17,0.5,"O associado acima qualificado autoriza a realização do débito mensal em sua conta corrente de deposito a vista, no valor de R$ ".number_format(str_replace(",",".",$dados_termo["VLPREPLA"]),2,",",".")." (".substr($dados_termo["DSPREPLA.1"],0,strpos($dados_termo["DSPREPLA.1"],"*")).") a partir do mês de ".$dados_termo["DSMESANO"] . ", para integralização de Cotas de CAPITAL.",0,"J",0);			

			// Quebra de linhas
			$this->Ln();
			$this->Ln();
			
			$this->MultiCell(17,0.5,"Este valor será reajustado após o período de 12 meses, com base em:");
			
			if ($dados_termo["CDTIPCOR"] == "0") {
			
				$this->MultiCell(17,0.5,"(   ) Correção monetária pela varição do IPCA (Índice Nacional de Preços ao Consumidor Amplo);");
			
				$this->Ln();
							
				$this->MultiCell(17,0.5,"(   ) Valor fixo;");
			
				$this->Ln();
								
				$this->MultiCell(17,0.5,"( X ) Sem reajuste automático de valor.");
				
			}
			else if ($dados_termo["CDTIPCOR"] == "1") {
			
				$this->MultiCell(17,0.5,"( X ) Correção monetária pela varição do IPCA (Índice Nacional de Preços ao Consumidor Amplo);");
			
				$this->Ln();
			
				$this->MultiCell(17,0.5,"(   ) Valor fixo;");
			
				$this->Ln();
				
				$this->MultiCell(17,0.5,"(   ) Sem reajuste automático de valor.");
			
			} else {
			
				$this->MultiCell(17,0.5,"(   ) Correção monetária pela varição do IPCA (Índice Nacional de Preços ao Consumidor Amplo);");
			
				$this->Ln();
			
				$this->MultiCell(17,0.5,"( X ) Valor fixo de R$ ".number_format(str_replace(",",".",$dados_termo["VLCORFIX"]),2,",",".").";");
			
				$this->Ln();
				
				$this->MultiCell(17,0.5,"(   ) Sem reajuste automático de valor.");
			}
			
			$this->Ln();
			$this->Ln();

			// Descrição do termo
			//$this->MultiCell(17,0.5,"A presente autorização, serve inclusive como instrumento legal de subscrição e integralização de capital na Cooperativa de Crédito, que se dará concomitantemente, no momento do débito em conta-corrente.",0,"J",0);			
			
			// Quebra de linhas
			$this->Ln();
			$this->Ln();
			
			// Descrição do termo
			if ($dados_termo["FLGPAGTO"] == "yes") { // Se débito em folha
				$this->MultiCell(17,0.5,"O débito se dará sempre na data em que ocorrer o crédito do salário, limitado ao saldo líquido do mesmo.",0,"J",0);						
			} else { // Se débito em conta
				$this->MultiCell(17,0.5,"O débito será efetuado desde que haja provisão de fundos na conta corrente.\nCaso a data estabelecida para débito cair no sábado, domingo ou feriado, o lançamento será efetuado no primeiro dia útil subsequente.",0,"J",0);
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