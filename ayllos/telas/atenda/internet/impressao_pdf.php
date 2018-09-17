<?php 

	/*************************************************************************
	     Fonte: impressao_pdf.php                                          
	      Autor: David                                                     
	      Data : Junho/2008                   Última Alteração: 11/02/2011 
	                                                                  
	      Objetivo  : Gerar PDF do contrato de acesso a Internet           
	                                                                   	 
	      Alterações:  11/02/2011 - Aumento do nome para 50 posicoes (Gabriel)
		               12/08/2013 - Alteração da sigla PAC para PA. (Carlos)
	*************************************************************************/
	
	// Classe para geração de arquivos PDF
	require_once("../../../class/fpdf/fpdf.php");
	
	// Classe para geração do contrato de acesso ao InternetBank em PDF
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
		
		// Gerar Layout para Impressão do Contrato em PDF
		function geraContrato($dadosContrato,$dadosRepresen) {						
			$qtRepresen = count($dadosRepresen);
					
			if ($dadosContrato["INPESSOA"] == "1" || $qtRepresen == 0) {
				$this->SetMargins(2,3);
			
				$this->AddPage();			
				
				$this->SetFont("Courier","B",10);
				
				$this->MultiCell(0,0.4,"DECLARAÇÃO DE ACESSO E MOVIMENTAÇÃO DE CONTAS POR MEIO DA INTERNET",0,"C",0);			
	
				$this->Ln();
				$this->Ln();
				$this->Ln();	
				
				$this->SetFont("Courier","",10);
				
				$this->MultiCell(0,0.4,"Declaro-me ciente de que poderei acessar de forma personalizada, as minhas contas por meio da internet, diretamente no site (".$dadosContrato["DSENDWEB"].") podendo processar os serviços ali disponibilizados, sendo que, para tanto, autorizo a Cooperativa a disponibilizar no seu site informações referentes a minha conta corrente de número ".formataNumericos("zzzz.zzz-9",$dadosContrato["NRDCONTA"],".-")." e outros dados pessoais, nos termos do estabelecido nas Condições Gerais Aplicáveis ao Contrato de Conta Corrente e Conta Investimento, disponível no site da Cooperativa, cuja cópia, na condição de Cooperado(a), recebi quando da abertura de minha conta corrente e/ou renovação de cadastro.",0,"J",0);			
				
				$this->Ln();			
				
				$this->MultiCell(0,0.4,"Declaro-me igualmente ciente de que, após o cadastramento da(s) senha(s), feito junto ao PA (Posto de Atendimento) onde mantenho minha conta corrente, terei o prazo de ".$dadosContrato["DSDIAACE"]." para estabelecer o primeiro acesso, caso contrário, o mesmo não será permitido, necessitando um recadastramento, ficando sob minha inteira responsabilidade a guarda das senhas e códigos de acesso ao sistema, não cabendo a Cooperativa nenhuma responsabilidade pelo seu uso indevido.",0,"J",0);			
				
				$this->Ln();
				$this->Ln();
				$this->Ln();
				
				$this->MultiCell(0,0.4,$dadosContrato["DSREFERE"],0,"J",0);							
				
				$this->Ln();
				$this->Ln();
				$this->Ln();
				$this->Ln();
				
				$this->Cell(4,0.4,"",0,0,"L",0,"");
				$this->Cell(9,0.4,"","B",0,"C",0,"");
				$this->Cell(4,0.4,"",0,1,"L",0,"");
				$this->Cell(4,0.4,"",0,0,"L",0,"");
				$this->Cell(9,0.4,$dadosContrato["NMPRIMLT"],0,0,"L",0,"");
				$this->Cell(4,0.4,"",0,1,"L",0,"");
				$this->Cell(4,0.4,"",0,0,"L",0,"");
				$this->Cell(9,0.4,"Conta/dv: ".formataNumericos("zzzz.zzz-9",$dadosContrato["NRDCONTA"],".-"),0,0,"L",0,"");
				$this->Cell(4,0.4,"",0,1,"L",0,"");						
				
				$this->Ln();
				$this->Ln();
				
				$this->MultiCell(0,0.4,"De acordo",0,"J",0);
				
				$this->Ln();
				$this->Ln();			
				
				$this->Cell(2.5,0.4,"",0,0,"L",0,"");
				$this->Cell(12,0.4,"","B",0,"C",0,"");
				$this->Cell(2.5,0.4,"",0,1,"L",0,"");
				$this->Cell(2.5,0.4,"",0,0,"L",0,"");
				$this->Cell(12,0.4,$dadosContrato["NMEXTCOP"],0,0,"L",0,"");
				$this->Cell(2.5,0.4,"",0,1,"L",0,"");
				$this->Cell(2.5,0.4,"",0,0,"L",0,"");
				$this->Cell(12,0.4,$dadosContrato["NRDOCNPJ"],0,0,"L",0,"");
				$this->Cell(2.5,0.4,"",0,1,"L",0,"");				
				
				$this->Ln();
				$this->Ln();
				$this->Ln();	
				$this->Ln();						
				
				$this->Cell(7,0.4,"","B",1,"L",0,"");
				$this->Cell(7,0.4,$dadosContrato["NMOPERAD"],0,1,"L",0,"");
				$this->Cell(7,0.4,$dadosContrato["DSMVTOLT"],0,1,"L",0,"");
			} else {
				$this->nrLinhas = 9; // Número de linhas fixas para pessoa jurídica
				
				$this->SetMargins(1.5,1.5);
			
				$this->AddPage();	
							
				$this->SetFont("Courier","B",10);
				
				$this->MultiCell(0,0.4,"ACESSO SERVIÇO INTERNET - SOLICITAÇÃO, AUTORIZAÇÃO DE ACESSO E TERMO DE RESPONSABILIDADE - PESSOA JURÍDICA",0,"C",0);			
	
				$this->Ln();
				$this->Ln();
				
				$this->SetFont("Courier","",10);			
				
				$this->MultiCell(0,0.4,$dadosContrato["NMEXTCOP"]." - ".$dadosContrato["NMRESCOP"],0,"J",0);
				$this->MultiCell(0,0.4,"CNPJ: ".$dadosContrato["NRDOCNPJ"],0,"J",0);
				
				$this->Ln();
				
				$this->MultiCell(0,0.4,"Cooperado: ".$dadosContrato["NMPRIMLT"],0,"J",0);
				$this->MultiCell(0,0.4,"C/C: ".formataNumericos("zzzz.zzz-9",$dadosContrato["NRDCONTA"],".-")." CNPJ: ".$dadosContrato["NRCPFCGC"],0,"J",0);
				
				$this->controlaLinhas(8);

				$this->Ln();
				$this->Ln();				
				
				$this->MultiCell(0,0.4,"Sócio(s)/Proprietário(s) do Cooperado:",0,"J",0);								
				
				for ($i = 0; $i < $qtRepresen; $i++) {			
					if (strtolower($dadosRepresen[$i]["FLGPREPO"]) == "yes") {
						$dadosPreposto = $dadosRepresen[$i];
						
						if ($qtRepresen > 1) {
							continue;
						}
					} 
					
					if ($i > 0) {
						$this->controlaLinhas(5);
					}
						
					$this->Ln();
					
					$this->MultiCell(0,0.4,"Nome: ".$dadosRepresen[$i]["NMDAVALI"],0,"J",0);
					$this->MultiCell(0,0.4,"CPF: ".$dadosRepresen[$i]["NRCPFCGC"]." Estado Civil: ".$dadosRepresen[$i]["DSESTCVL"],0,"J",0);
					$this->MultiCell(0,0.4,"Cargo: ".$dadosRepresen[$i]["DSPROFTL"],0,"J",0);
					$this->Cell(1.3,0.4,"End.:",0,0,"L",0,"");
					$this->MultiCell(16.7,0.4,$dadosRepresen[$i]["DSENDERE"].", ".$dadosRepresen[$i]["NRENDERE"].($dadosRepresen[$i]["COMPLEND "] <> "" ? ", ".$dadosRepresen[$i]["COMPLEND "] : "").", ".$dadosRepresen[$i]["NMBAIRRO"].", ".$dadosRepresen[$i]["NMCIDADE"]." - ".$dadosRepresen[$i]["CDUFENDE"],0,"J",0);					

					
				}				
				
				$this->controlaLinhas(5);
				
				$this->Ln();
				
				$this->MultiCell(0,0.4,"Preposto: ".$dadosPreposto["NMDAVALI"],0,"J",0);
				$this->MultiCell(0,0.4,"CPF: ".$dadosPreposto["NRCPFCGC"]." Estado Civil: ".$dadosPreposto["DSESTCVL"],0,"J",0);
				$this->Cell(1.3,0.4,"End.:",0,0,"L",0,"");
				$this->MultiCell(16.7,0.4,$dadosPreposto["DSENDERE"].", ".$dadosPreposto["NRENDERE"].($dadosPreposto["COMPLEND "] <> "" ? ", ".$dadosPreposto["COMPLEND "] : "").", ".$dadosPreposto["NMBAIRRO"].", ".$dadosPreposto["NMCIDADE"]." - ".$dadosPreposto["CDUFENDE"],0,"J",0);					
				$this->MultiCell(0,0.4,"Tipo de Vínculo: ".$dadosPreposto["DSPROFTL"],0,"J",0);
				
				$this->controlaLinhas(8);
				
				$this->Ln();
				$this->Ln();		
								
				$this->MultiCell(0,0.4,"Solicitamos a Cooperativa acima qualificada, que nos seja dado acesso aos Serviços de Internet, através do seu site (".$dadosContrato["DSENDWEB"]."), com o qual poderemos realizar, através do nosso computador, os serviços e transações financeiras disponíveis, com acesso a nossa conta corrente acima assinalada, em consonância como estabelecido nas Condições Gerais Aplicáveis ao Contrato de Conta Corrente e Investimento, subscrito na data da sua abertura.",0,"J",0);				
				
				$this->controlaLinhas(4);
				
				$this->Ln();
				
				$this->MultiCell(0,0.4,"Para a utilização dos Serviços de Internet, autorizamos o Preposto acima qualificado, para que individualmente, mediante o prévio cadastramento de senha pessoal necessária ao acesso, efetua as transações disponibilizadas.",0,"J",0);				

				$this->controlaLinhas(5);
				
				$this->Ln();
				
				$this->MultiCell(0,0.4,"Pela presente autorização concordamos com a revogação, enquanto perdurar o presente termo, de quaisquer disposições em contrário estabelecidas nas Condições Gerais Aplicáveis ao Contrato de Conta Corrente e Investimento, com o qual anuimos em face da Proposta/Contrato de Abertura de Conta Corrente por nos subscrita.",0,"J",0);				
				
				$this->controlaLinhas(4);
				
				$this->Ln();
				
				$this->MultiCell(0,0.4,"Assumimos plena responsabilidade sobre os atos praticados pelo Preposto acima qualificado, na condição de usuário dos Serviços de Internet disponibilizados pela Cooperativa.",0,"J",0);				
				
				$this->controlaLinhas(4);
				
				$this->Ln();
				
				$this->MultiCell(0,0.4,"Declaramos que é de nosso conhecimento que não estão contempladas neste serviço quaisquer transações que envolvam operações de empréstimos, os quais devem ser formalizados diretamente em qualquer dos Postos de Atendimento da Cooperativa.",0,"J",0);				
				
				$this->controlaLinhas(4);
				
				$this->Ln();
				
				$this->MultiCell(0,0.4,"Obrigamo-nos a comunicar, por escrito, a Cooperativa, qualquer alteração com relação as autorizações concedidas neste instrumento, isentando esta de qualquer responsabilidade pela ausência de sua tempestiva realização.",0,"J",0);				
				
				$this->controlaLinhas(3);
				
				$this->Ln();
				$this->Ln();
				
				$this->MultiCell(0,0.4,$dadosContrato["DSREFERE"],0,"J",0);				
				
				$this->controlaLinhas(8);
				
				$this->Ln();
				$this->Ln();				
				
				$this->MultiCell(0,0.4,"Sócio(s)/Proprietário(s) do Cooperado:",0,"J",0);				
				
				for ($i = 0; $i < $qtRepresen; $i++) {
					if (strtolower($dadosRepresen[$i]["FLGPREPO"]) == "yes" && $qtRepresen > 1) {					
						continue;
					} 
					
					if ($i > 0) {
						$this->controlaLinhas(5);
					}
					
					$this->Ln();
					$this->Ln();
																		
					$this->MultiCell(12,0.4,"","B","J",0);
					$this->MultiCell(0,0.4,"Nome: ".$dadosRepresen[$i]["NMDAVALI"],0,"J",0);
					$this->MultiCell(0,0.4,"CPF: ".$dadosRepresen[$i]["NRCPFCGC"],0,"J",0);
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
				$this->Cell(12,0.4,$dadosContrato["NMEXTCOP"],0,0,"C",0,"");
				$this->Cell(3,0.4,"",0,1,"L",0,"");
				$this->Cell(3,0.4,"",0,0,"L",0,"");
				$this->Cell(12,0.4,$dadosContrato["NRDOCNPJ"],0,0,"C",0,"");
				$this->Cell(3,0.4,"",0,1,"L",0,"");				
				
				$this->Ln();
				$this->Ln();
				$this->Ln();	
				$this->Ln();						
				
				$this->Cell(7,0.4,"","B",1,"L",0,"");
				$this->Cell(7,0.4,$dadosContrato["NMOPERAD"],0,1,"L",0,"");
				$this->Cell(7,0.4,$dadosContrato["DSMVTOLT"],0,1,"L",0,"");				
			} 
		}
	}
	
?>