<?php 

	//************************************************************************//
	//*** Fonte: impressao_termo_responsabilidade_pdf.php                  ***//
	//*** Autor: David                                                     ***//
	//*** Data : Março/2009                   Última Alteração: 00/00/0000 ***//
	//***                                                                  ***//
	//*** Objetivo  : Gerar PDF do Termo de Responsabilidade de Magnéticos ***//
	//***                                                                  ***//	 
	//*** Alterações:                                                      ***//
	//************************************************************************//
	
	// Classe para geração de arquivos PDF
	require_once("../../../class/fpdf/fpdf.php");
	
	// Classe para geração do Termo de acesso ao InternetBank em PDF
	class PDF extends FPDF {
	
		var $nrLinhas = 0; // Acumular número de linhas de cada página

		// Método Construtor
		function PDF($orientation = "P",$unit = "cm",$format = "A4") {
			$this->FPDF($orientation,$unit,$format);
		}
		
		function controlaLinhas($linhas) {
			$this->nrLinhas += $linhas;
			
			if ($this->nrLinhas > 65) {
				$this->AddPage();						
				$this->nrLinhas = $linhas;
			}
		}			
		
		// Gerar Layout para Impressão do Termo em PDF
		function geraTermo($dadosTermo,$dadosRepresen) {						
			$qtRepresen = count($dadosRepresen);
					
			$this->nrLinhas = 9; // Número de linhas fixas para pessoa jurídica
			
			$this->SetMargins(1.5,1.5);
		
			$this->AddPage();	
						
			$this->SetFont("Courier","B",10);
			
			$this->MultiCell(0,0.4,"ACESSO CAIXA ELETRÔNICO - SOLICITAÇÃO, AUTORIZAÇÃO DE ACESSO E TERMO DE RESPONSABILIDADE - PESSOA JURÍDICA",0,"C",0);			

			$this->Ln();
			$this->Ln();
			
			$this->SetFont("Courier","",10);			
			
			$this->MultiCell(0,0.4,$dadosTermo["NMEXTCOP"]." - ".$dadosTermo["NMRESCOP"],0,"J",0);
			$this->MultiCell(0,0.4,"CNPJ: ".$dadosTermo["NRDOCNPJ"],0,"J",0);
			
			$this->Ln();
			
			$this->MultiCell(0,0.4,"Cooperado: ".$dadosTermo["NMPRIMTL"],0,"J",0);
			$this->MultiCell(0,0.4,"C/C: ".formataNumericos("zzzz.zzz-9",$dadosTermo["NRDCONTA"],".-")." CNPJ: ".$dadosTermo["NRCPFCGC"],0,"J",0);
			
			$this->controlaLinhas(8);

			$this->Ln();
			$this->Ln();				
			
			$this->MultiCell(0,0.4,"Sócio(s)/Proprietário(s) do Cooperado:",0,"J",0);								
			
			for ($i = 0; $i < $qtRepresen; $i++) {			
				if (strtolower($dadosRepresen[$i]["FLGPREPO"]) == "yes") {
					$dadosPreposto = $dadosRepresen[$i];					
					
					if ($qtRepresen > 1 && strtoupper($dadosRepresen[$i]["DSPROFTL"]) <> "SOCIO/PROPRIETARIO") {
						continue;
					}
				} 
				
				if ($i > 0) {
					$this->controlaLinhas(5);
				}
					
				$this->Ln();
				
				$this->MultiCell(0,0.4,"Nome: ".$dadosRepresen[$i]["NMDAVALI"],0,"J",0);
				$this->MultiCell(0,0.4,"CPF: ".$dadosRepresen[$i]["NRCPFPPT"]." Estado Civil: ".$dadosRepresen[$i]["DSESTCVL"],0,"J",0);
				$this->MultiCell(0,0.4,"Cargo: ".$dadosRepresen[$i]["DSPROFTL"],0,"J",0);
				$this->Cell(1.3,0.4,"End.:",0,0,"L",0,"");
				$this->MultiCell(16.7,0.4,$dadosRepresen[$i]["DSENDERE"].", ".$dadosRepresen[$i]["NRENDERE"].($dadosRepresen[$i]["COMPLEND "] <> "" ? ", ".$dadosRepresen[$i]["COMPLEND "] : "").", ".$dadosRepresen[$i]["NMBAIRRO"].", ".$dadosRepresen[$i]["NMCIDADE"]." - ".$dadosRepresen[$i]["CDUFENDE"],0,"J",0);								
			}				
			
			$this->controlaLinhas(5);
			
			$this->Ln();
			
			$this->MultiCell(0,0.4,"Preposto: ".$dadosPreposto["NMDAVALI"],0,"J",0);
			$this->MultiCell(0,0.4,"CPF: ".$dadosPreposto["NRCPFPPT"]." Estado Civil: ".$dadosPreposto["DSESTCVL"],0,"J",0);
			$this->Cell(1.3,0.4,"End.:",0,0,"L",0,"");
			$this->MultiCell(16.7,0.4,$dadosPreposto["DSENDERE"].", ".$dadosPreposto["NRENDERE"].($dadosPreposto["COMPLEND "] <> "" ? ", ".$dadosPreposto["COMPLEND "] : "").", ".$dadosPreposto["NMBAIRRO"].", ".$dadosPreposto["NMCIDADE"]." - ".$dadosPreposto["CDUFENDE"],0,"J",0);					
			$this->MultiCell(0,0.4,"Tipo de Vínculo: ".$dadosPreposto["DSPROFTL"],0,"J",0);
			
			$this->controlaLinhas(7);
			
			$this->Ln();
			$this->Ln();		
								
			$this->MultiCell(0,0.4,"Solicitamos a Cooperativa acima qualificada, que nos seja dado acesso aos Serviços do Caixa Eletrônico, através do cartão magnético com o qual poderemos realizar as transações financeiras disponíveis com acesso a nossa conta corrente acima assinalada, em consonância com estabelecido nas Condições Gerais Aplicáveis ao Contrato de Conta Corrente e Investimento subscrito na data da sua abertura.",0,"J",0);				
			
			$this->controlaLinhas(4);
			
			$this->Ln();
			
			$this->MultiCell(0,0.4,"Para a utilização dos Serviços do Caixa Eletrônico, autorizamos o Preposto acima qualificado, para que individualmente, mediante o prévio cadastramento de senha pessoal necessária ao acesso, efetua as transações disponibilizadas.",0,"J",0);				

			$this->controlaLinhas(5);
			
			$this->Ln();
			
			$this->MultiCell(0,0.4,"Pela presente autorização concordamos com a revogação, enquanto perdurar o presente termo, de quaisquer disposições em contrário estabelecidas nas Condições Gerais Aplicáveis ao Contrato de Conta Corrente e Investimento, com o qual anuimos em face da Proposta/Termo de Abertura de Conta Corrente por nos subscrita.",0,"J",0);				
			
			$this->controlaLinhas(4);
			
			$this->Ln();
			
			$this->MultiCell(0,0.4,"Assumimos plena responsabilidade sobre os atos praticados pelo Preposto acima qualificado, na condição de usuário dos Serviços do Caixa Eletrônico disponibilizados pela cooperativa.",0,"J",0);				
				
			$this->controlaLinhas(3);
			
			$this->Ln();
			
			$this->MultiCell(0,0.4,"Obrigamo-nos a comunicar imediatamente a Cooperativa o furto ou extravio do cartão magnético, ainda que não tenha fornecido a senha para ninguém.",0,"J",0);				
			
			$this->controlaLinhas(5);
			
			$this->Ln();
			
			$this->MultiCell(0,0.4,"É de nosso conhecimento que a senha é pessoal e não deve ser repassada à qualquer pessoa, ainda que de confiança, da mesma forma estamos cientes que não poderemos aceitar ou solicitar ajuda de estranhos para operar os sistemas eletrônicos. A referida senha é de uso exclusivo.",0,"J",0);										
			
			$this->controlaLinhas(4);

			$this->Ln();
			
			$this->MultiCell(0,0.4,"Declaramos que é de nosso conhecimento que não estão contempladas neste serviço quaisquer transações que envolvam operações de empréstimos, os quais devem ser formalizados diretamente em qualquer dos Postos de Atendimento da Cooperativa.",0,"J",0);										
			
			$this->controlaLinhas(5);
			
			$this->Ln();
			
			$this->MultiCell(0,0.4,"Estamos cientes de que, caso ocorra qualquer alteração societária e a sua devida atualização nos cadastros desta Cooperativa, novo termo deverá ser assinado, e nova senha de acesso aos serviços será providenciada. A não observância deste item acarretará o bloqueio automático dos serviços disponíveis.",0,"J",0);										
			
			$this->controlaLinhas(4);			
			
			$this->Ln();
			
			$this->MultiCell(0,0.4,"Obrigamo-nos a comunicar, por escrito, a Cooperativa, qualquer alteração com relação as autorizações concedidas neste instrumento, isentando esta de qualquer responsabilidade pela ausência de sua tempestiva realização.",0,"J",0);				
			
			$this->controlaLinhas(3);			
			
			$this->Ln();
			$this->Ln();
			
			$this->MultiCell(0,0.4,$dadosTermo["DSREFERE"],0,"J",0);				
			
			$this->controlaLinhas(8);
			
			$this->Ln();
			$this->Ln();				
			
			$this->MultiCell(0,0.4,"Sócio(s)/Proprietário(s):",0,"J",0);				
			
			for ($i = 0; $i < $qtRepresen; $i++) {
				if (strtolower($dadosRepresen[$i]["FLGPREPO"]) == "yes" && strtoupper($dadosRepresen[$i]["DSPROFTL"]) <> "SOCIO/PROPRIETARIO" && $qtRepresen > 1) {					
					continue;
				} 
				
				if ($i > 0) {
					$this->controlaLinhas(5);
				}
				
				$this->Ln();
				$this->Ln();
																	
				$this->MultiCell(12,0.4,"","B","J",0);
				$this->MultiCell(0,0.4,"Nome: ".$dadosRepresen[$i]["NMDAVALI"],0,"J",0);
				$this->MultiCell(0,0.4,"CPF: ".$dadosRepresen[$i]["NRCPFPPT"],0,"J",0);
			}			
			
			$this->controlaLinhas(6);
			
			$this->Ln();
			$this->Ln();				
			
			$this->MultiCell(0,0.4,"Testemunhas:",0,"J",0);		
			
			$this->Ln();
			$this->Ln();				
			
			$this->Cell(8.5,0.4,"","B",0,"L",0,"");
			$this->Cell(1,0.4,"",0,0,"L",0,"");
			$this->Cell(8.5,0.4,"","B",1,"L",0,"");
			
			$this->controlaLinhas(16);
			
			$this->Ln();
			$this->Ln();	
			$this->Ln();
			$this->Ln();									
			
			$this->MultiCell(0,0.4,"De acordo",0,"J",0);
			
			$this->Ln();
			$this->Ln();			
			
			$this->Cell(3,0.4,"",0,0,"L",0,"");
			$this->Cell(12,0.4,"","B",0,"C",0,"");
			$this->Cell(3,0.4,"",0,1,"L",0,"");
			$this->Cell(3,0.4,"",0,0,"L",0,"");
			$this->Cell(12,0.4,$dadosTermo["NMEXTCOP"],0,0,"C",0,"");
			$this->Cell(3,0.4,"",0,1,"L",0,"");
			$this->Cell(3,0.4,"",0,0,"L",0,"");
			$this->Cell(12,0.4,$dadosTermo["NRDOCNPJ"],0,0,"C",0,"");
			$this->Cell(3,0.4,"",0,1,"L",0,"");				
			
			$this->Ln();
			$this->Ln();
			$this->Ln();	
			$this->Ln();						
			
			$this->Cell(7,0.4,"","B",1,"L",0,"");
			$this->Cell(7,0.4,$dadosTermo["NMOPERAD"],0,1,"L",0,"");
			$this->Cell(7,0.4,$dadosTermo["DSMVTOLT"],0,1,"L",0,"");				
		}
	}
	
?>