<?php 

	//************************************************************************//
	//*** Fonte: lista_cheques_pdf.php                                     ***//
	//*** Autor: David                                                     ***//
	//*** Data : Fevereiro/2008               Última Alteração: 00/00/0000 ***//
	//***                                                                  ***//
	//*** Objetivo  : Gerar PDF com cheques não compensados                ***//
	//***                                                                  ***//	 
	//*** Alterações:                                                      ***//
	//************************************************************************//
	
	// Classe para geração de arquivos PDF
	require_once("../../../class/fpdf/fpdf.php");
	
	// Classe para geração do extrato de autorização de plano de capital em PDF
	class PDF extends FPDF {
	
		var $nrPaginas = 0; // Acumular número de páginas do documento

		// Método Construtor
		function PDF($orientation = "P",$unit = "cm",$format = "A4") {
			$this->FPDF($orientation,$unit,$format);
		}
		
		// Método para criar nova página no documento com cabeçalho
		function geraCabecalho($dados) {
			// Adicina Nova Página ao PDF
			$this->AddPage();		
			
			$this->nrPaginas++;
			
			// Cabeçalho Relatório
			$this->Cell(18,0.65,$dados["NMRESCOP"]." - ".$dados["NMRELATO"]." - REF.".$dados["DTMVTOLT"]." - ".$dados["CDRELATO"]."/ATENDA - ".date("d/m/Y H:i")." - Página: ".$this->nrPaginas,0,1,"L",0,"");
			
			// Destino Relatório
			$this->Cell(18,0.65,"DESTINO: ".$dados["NMDESTIN"],0,1,"L",0,"");
						
			// Número da Conta
			$this->Cell(18,0.65,"Conta Corrente: ".$dados["NRDCONTA"]."   ".$dados["NMPRIMTL"],0,1,"L",0,"");			

			// Quebra de linha
			$this->Ln();
			
			// Cabeçalho - Data, Histórico, Documento, Valor, D/C, Saldo
			$this->Cell(2,0.5,"Emissão","B",0,"C",0,"");
			$this->Cell(0.25,0.5,"",0,0,"L",0,"");
			$this->Cell(2,0.5,"Retirada","B",0,"C",0,"");
			$this->Cell(0.25,0.5,"",0,0,"L",0,"");
			$this->Cell(2.5,0.5,"Conta Base","B",0,"R",0,"");
			$this->Cell(0.25,0.5,"",0,0,"L",0,"");
			$this->Cell(3,0.5,"Cheque","B",0,"R",0,"");
			$this->Cell(0.25,0.5,"",0,0,"L",0,"");
			$this->Cell(0.75,0.5,"TB","B",0,"C",0,"");	
			$this->Cell(0.25,0.5,"",0,0,"L",0,"");
			$this->Cell(6.5,0.5,"Observação","B",1,"L",0,"");		
		}
		
		// Gerar Layout para Impressão da lista de cheques em PDF
		function geraLista($dados) {		
			// Seta Largura das Margens
			$this->SetMargins(1.5,1.5);
			
			// Setando fonte estilo Courier, tamanho 10, na cor preta
   		$this->SetFont("Courier","",9);
			$this->SetTextColor(0,0,0);
			
			$contador = 45;

			// Dados - Data, Histórico, Documento, Valor, D/C, Saldo
			for ($i = 0; $i < count($dados["DADOSCHQ"]); $i++) {
				$contador++;
				
				// Se foram listadas 45 cheques na página, cria próxima página
				if ($contador == 46) {
					$this->geraCabecalho($dados);					
					$contador = 0;
				}
				
				$this->Cell(2,0.5,$dados["DADOSCHQ"][$i]["DTEMSCHQ"],0,0,"C",0,"");
				$this->Cell(0.25,0.5,"",0,0,"L",0,"");
				$this->Cell(2,0.5,$dados["DADOSCHQ"][$i]["DTRETCHQ"],0,0,"C",0,"");
				$this->Cell(0.25,0.5,"",0,0,"L",0,"");
				$this->Cell(2.5,0.5,formataContaDV($dados["DADOSCHQ"][$i]["NRDCTABB"]),0,0,"R",0,"");
				$this->Cell(0.25,0.5,"",0,0,"L",0,"");
				$this->Cell(3,0.5,formataNumericos("zzz.zzz.zzz-9",$dados["DADOSCHQ"][$i]["NRCHEQUE"],".-"),0,0,"R",0,"");
				$this->Cell(0.25,0.5,"",0,0,"L",0,"");
				$this->Cell(0.75,0.5,(strtolower($dados["DADOSCHQ"][$i]["CHQTALTB"]) == "yes" ? "Sim" : "Não"),0,0,"C",0,"");	
				$this->Cell(0.25,0.5,"",0,0,"L",0,"");
				$this->Cell(6.5,0.5,($dados["DADOSCHQ"][$i]["DSOBSERV"] <> "" ? $dados["DADOSCHQ"][$i]["DSOBSERV"] : "_________________________________"),0,0,"L",0,"");
				
				// Quebra de linha
				$this->Ln();				
			}

			// Dados quantitativos
			$this->Cell(5,0.5,"Quantidade de Cheques:",0,0,"R",0,"");
			$this->Cell(4,0.5,formataNumericos("zzz.zzz.zzz",$dados["QTCHEQUE"],"."),0,0,"L",0,"");
			$this->Cell(5,0.5,"Quantidade de Contra-Ordens:",0,0,"R",0,"");
			$this->Cell(4,0.5,formataNumericos("zzz.zzz.zzz",$dados["QTCORDEM"],"."),0,0,"L",0,"");			
		}
	}
	
?>