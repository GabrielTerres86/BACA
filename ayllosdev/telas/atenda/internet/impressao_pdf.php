<?php 

	/*************************************************************************
	     Fonte: impressao_pdf.php                                          
	      Autor: David                                                     
	      Data : Junho/2008                   �ltima Altera��o: 11/02/2011 
	                                                                  
	      Objetivo  : Gerar PDF do contrato de acesso a Internet           
	                                                                   	 
	      Altera��es:  11/02/2011 - Aumento do nome para 50 posicoes (Gabriel)
		               12/08/2013 - Altera��o da sigla PAC para PA. (Carlos)
	*************************************************************************/
	
	// Classe para gera��o de arquivos PDF
	require_once("../../../class/fpdf/fpdf.php");
	
	// Classe para gera��o do contrato de acesso ao InternetBank em PDF
	class PDF extends FPDF {
	
		var $nrLinhas = 0; // Acumular n�mero de linhas de cada p�gina

		// M�todo Construtor
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
		
		// Gerar Layout para Impress�o do Contrato em PDF
		function geraContrato($dadosContrato,$dadosRepresen) {						
			$qtRepresen = count($dadosRepresen);
					
			if ($dadosContrato["INPESSOA"] == "1" || $qtRepresen == 0) {
				$this->SetMargins(2,3);
			
				$this->AddPage();			
				
				$this->SetFont("Courier","B",10);
				
				$this->MultiCell(0,0.4,"DECLARA��O DE ACESSO E MOVIMENTA��O DE CONTAS POR MEIO DA INTERNET",0,"C",0);			
	
				$this->Ln();
				$this->Ln();
				$this->Ln();	
				
				$this->SetFont("Courier","",10);
				
				$this->MultiCell(0,0.4,"Declaro-me ciente de que poderei acessar de forma personalizada, as minhas contas por meio da internet, diretamente no site (".$dadosContrato["DSENDWEB"].") podendo processar os servi�os ali disponibilizados, sendo que, para tanto, autorizo a Cooperativa a disponibilizar no seu site informa��es referentes a minha conta corrente de n�mero ".formataNumericos("zzzz.zzz-9",$dadosContrato["NRDCONTA"],".-")." e outros dados pessoais, nos termos do estabelecido nas Condi��es Gerais Aplic�veis ao Contrato de Conta Corrente e Conta Investimento, dispon�vel no site da Cooperativa, cuja c�pia, na condi��o de Cooperado(a), recebi quando da abertura de minha conta corrente e/ou renova��o de cadastro.",0,"J",0);			
				
				$this->Ln();			
				
				$this->MultiCell(0,0.4,"Declaro-me igualmente ciente de que, ap�s o cadastramento da(s) senha(s), feito junto ao PA (Posto de Atendimento) onde mantenho minha conta corrente, terei o prazo de ".$dadosContrato["DSDIAACE"]." para estabelecer o primeiro acesso, caso contr�rio, o mesmo n�o ser� permitido, necessitando um recadastramento, ficando sob minha inteira responsabilidade a guarda das senhas e c�digos de acesso ao sistema, n�o cabendo a Cooperativa nenhuma responsabilidade pelo seu uso indevido.",0,"J",0);			
				
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
				$this->nrLinhas = 9; // N�mero de linhas fixas para pessoa jur�dica
				
				$this->SetMargins(1.5,1.5);
			
				$this->AddPage();	
							
				$this->SetFont("Courier","B",10);
				
				$this->MultiCell(0,0.4,"ACESSO SERVI�O INTERNET - SOLICITA��O, AUTORIZA��O DE ACESSO E TERMO DE RESPONSABILIDADE - PESSOA JUR�DICA",0,"C",0);			
	
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
				
				$this->MultiCell(0,0.4,"S�cio(s)/Propriet�rio(s) do Cooperado:",0,"J",0);								
				
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
				$this->MultiCell(0,0.4,"Tipo de V�nculo: ".$dadosPreposto["DSPROFTL"],0,"J",0);
				
				$this->controlaLinhas(8);
				
				$this->Ln();
				$this->Ln();		
								
				$this->MultiCell(0,0.4,"Solicitamos a Cooperativa acima qualificada, que nos seja dado acesso aos Servi�os de Internet, atrav�s do seu site (".$dadosContrato["DSENDWEB"]."), com o qual poderemos realizar, atrav�s do nosso computador, os servi�os e transa��es financeiras dispon�veis, com acesso a nossa conta corrente acima assinalada, em conson�ncia como estabelecido nas Condi��es Gerais Aplic�veis ao Contrato de Conta Corrente e Investimento, subscrito na data da sua abertura.",0,"J",0);				
				
				$this->controlaLinhas(4);
				
				$this->Ln();
				
				$this->MultiCell(0,0.4,"Para a utiliza��o dos Servi�os de Internet, autorizamos o Preposto acima qualificado, para que individualmente, mediante o pr�vio cadastramento de senha pessoal necess�ria ao acesso, efetua as transa��es disponibilizadas.",0,"J",0);				

				$this->controlaLinhas(5);
				
				$this->Ln();
				
				$this->MultiCell(0,0.4,"Pela presente autoriza��o concordamos com a revoga��o, enquanto perdurar o presente termo, de quaisquer disposi��es em contr�rio estabelecidas nas Condi��es Gerais Aplic�veis ao Contrato de Conta Corrente e Investimento, com o qual anuimos em face da Proposta/Contrato de Abertura de Conta Corrente por nos subscrita.",0,"J",0);				
				
				$this->controlaLinhas(4);
				
				$this->Ln();
				
				$this->MultiCell(0,0.4,"Assumimos plena responsabilidade sobre os atos praticados pelo Preposto acima qualificado, na condi��o de usu�rio dos Servi�os de Internet disponibilizados pela Cooperativa.",0,"J",0);				
				
				$this->controlaLinhas(4);
				
				$this->Ln();
				
				$this->MultiCell(0,0.4,"Declaramos que � de nosso conhecimento que n�o est�o contempladas neste servi�o quaisquer transa��es que envolvam opera��es de empr�stimos, os quais devem ser formalizados diretamente em qualquer dos Postos de Atendimento da Cooperativa.",0,"J",0);				
				
				$this->controlaLinhas(4);
				
				$this->Ln();
				
				$this->MultiCell(0,0.4,"Obrigamo-nos a comunicar, por escrito, a Cooperativa, qualquer altera��o com rela��o as autoriza��es concedidas neste instrumento, isentando esta de qualquer responsabilidade pela aus�ncia de sua tempestiva realiza��o.",0,"J",0);				
				
				$this->controlaLinhas(3);
				
				$this->Ln();
				$this->Ln();
				
				$this->MultiCell(0,0.4,$dadosContrato["DSREFERE"],0,"J",0);				
				
				$this->controlaLinhas(8);
				
				$this->Ln();
				$this->Ln();				
				
				$this->MultiCell(0,0.4,"S�cio(s)/Propriet�rio(s) do Cooperado:",0,"J",0);				
				
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