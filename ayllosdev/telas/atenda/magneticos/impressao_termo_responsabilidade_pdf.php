<?php 

	//************************************************************************//
	//*** Fonte: impressao_termo_responsabilidade_pdf.php                  ***//
	//*** Autor: David                                                     ***//
	//*** Data : Mar�o/2009                   �ltima Altera��o: 00/00/0000 ***//
	//***                                                                  ***//
	//*** Objetivo  : Gerar PDF do Termo de Responsabilidade de Magn�ticos ***//
	//***                                                                  ***//	 
	//*** Altera��es:                                                      ***//
	//************************************************************************//
	
	// Classe para gera��o de arquivos PDF
	require_once("../../../class/fpdf/fpdf.php");
	
	// Classe para gera��o do Termo de acesso ao InternetBank em PDF
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
		
		// Gerar Layout para Impress�o do Termo em PDF
		function geraTermo($dadosTermo,$dadosRepresen) {						
			$qtRepresen = count($dadosRepresen);
					
			$this->nrLinhas = 9; // N�mero de linhas fixas para pessoa jur�dica
			
			$this->SetMargins(1.5,1.5);
		
			$this->AddPage();	
						
			$this->SetFont("Courier","B",10);
			
			$this->MultiCell(0,0.4,"ACESSO CAIXA ELETR�NICO - SOLICITA��O, AUTORIZA��O DE ACESSO E TERMO DE RESPONSABILIDADE - PESSOA JUR�DICA",0,"C",0);			

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
			
			$this->MultiCell(0,0.4,"S�cio(s)/Propriet�rio(s) do Cooperado:",0,"J",0);								
			
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
			$this->MultiCell(0,0.4,"Tipo de V�nculo: ".$dadosPreposto["DSPROFTL"],0,"J",0);
			
			$this->controlaLinhas(7);
			
			$this->Ln();
			$this->Ln();		
								
			$this->MultiCell(0,0.4,"Solicitamos a Cooperativa acima qualificada, que nos seja dado acesso aos Servi�os do Caixa Eletr�nico, atrav�s do cart�o magn�tico com o qual poderemos realizar as transa��es financeiras dispon�veis com acesso a nossa conta corrente acima assinalada, em conson�ncia com estabelecido nas Condi��es Gerais Aplic�veis ao Contrato de Conta Corrente e Investimento subscrito na data da sua abertura.",0,"J",0);				
			
			$this->controlaLinhas(4);
			
			$this->Ln();
			
			$this->MultiCell(0,0.4,"Para a utiliza��o dos Servi�os do Caixa Eletr�nico, autorizamos o Preposto acima qualificado, para que individualmente, mediante o pr�vio cadastramento de senha pessoal necess�ria ao acesso, efetua as transa��es disponibilizadas.",0,"J",0);				

			$this->controlaLinhas(5);
			
			$this->Ln();
			
			$this->MultiCell(0,0.4,"Pela presente autoriza��o concordamos com a revoga��o, enquanto perdurar o presente termo, de quaisquer disposi��es em contr�rio estabelecidas nas Condi��es Gerais Aplic�veis ao Contrato de Conta Corrente e Investimento, com o qual anuimos em face da Proposta/Termo de Abertura de Conta Corrente por nos subscrita.",0,"J",0);				
			
			$this->controlaLinhas(4);
			
			$this->Ln();
			
			$this->MultiCell(0,0.4,"Assumimos plena responsabilidade sobre os atos praticados pelo Preposto acima qualificado, na condi��o de usu�rio dos Servi�os do Caixa Eletr�nico disponibilizados pela cooperativa.",0,"J",0);				
				
			$this->controlaLinhas(3);
			
			$this->Ln();
			
			$this->MultiCell(0,0.4,"Obrigamo-nos a comunicar imediatamente a Cooperativa o furto ou extravio do cart�o magn�tico, ainda que n�o tenha fornecido a senha para ningu�m.",0,"J",0);				
			
			$this->controlaLinhas(5);
			
			$this->Ln();
			
			$this->MultiCell(0,0.4,"� de nosso conhecimento que a senha � pessoal e n�o deve ser repassada � qualquer pessoa, ainda que de confian�a, da mesma forma estamos cientes que n�o poderemos aceitar ou solicitar ajuda de estranhos para operar os sistemas eletr�nicos. A referida senha � de uso exclusivo.",0,"J",0);										
			
			$this->controlaLinhas(4);

			$this->Ln();
			
			$this->MultiCell(0,0.4,"Declaramos que � de nosso conhecimento que n�o est�o contempladas neste servi�o quaisquer transa��es que envolvam opera��es de empr�stimos, os quais devem ser formalizados diretamente em qualquer dos Postos de Atendimento da Cooperativa.",0,"J",0);										
			
			$this->controlaLinhas(5);
			
			$this->Ln();
			
			$this->MultiCell(0,0.4,"Estamos cientes de que, caso ocorra qualquer altera��o societ�ria e a sua devida atualiza��o nos cadastros desta Cooperativa, novo termo dever� ser assinado, e nova senha de acesso aos servi�os ser� providenciada. A n�o observ�ncia deste item acarretar� o bloqueio autom�tico dos servi�os dispon�veis.",0,"J",0);										
			
			$this->controlaLinhas(4);			
			
			$this->Ln();
			
			$this->MultiCell(0,0.4,"Obrigamo-nos a comunicar, por escrito, a Cooperativa, qualquer altera��o com rela��o as autoriza��es concedidas neste instrumento, isentando esta de qualquer responsabilidade pela aus�ncia de sua tempestiva realiza��o.",0,"J",0);				
			
			$this->controlaLinhas(3);			
			
			$this->Ln();
			$this->Ln();
			
			$this->MultiCell(0,0.4,$dadosTermo["DSREFERE"],0,"J",0);				
			
			$this->controlaLinhas(8);
			
			$this->Ln();
			$this->Ln();				
			
			$this->MultiCell(0,0.4,"S�cio(s)/Propriet�rio(s):",0,"J",0);				
			
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