<?php 

	/************************************************************************  
	  Fonte: imprimir_pdf_dscchq.php                                               
	  Autor: Guilherme                                                          
	  Data : Março/2008                   Última Alteração: 15/08/2016          
																			
	  Objetivo  : Gerar PDF das impressoes de desconto de cheques              
	                                                                            	 
	  Alterações: 14/06/2010 - Adaptar para novo RATING (David).                                                            
				  19/03/2012 - Adicionada área para uso da Digitalização (Lucas).
				  22/08/2012 - Inclusão de area para visualizar nrdconta,
							   nrbordero, pac (Lucas R.).
				  13/02/2013 - Alterações para o Projeto GED - Fase 2 (Lucas).
				  12/08/2013 - Alteração da sigla PAC para PA. (Carlos)
				  19/08/2015 - Reformulacao cadastral (Gabriel-RKAM).
                  21/06/2016 - Inclusao do coordenador que liberou/analisou as 
                               restricoes. (Jaison/James)
				  
				  15/08/2016 - Ajuste no numero do banco conforme solicitado no chamado
							   492081. (Kelvin)
	************************************************************************/ 
	
	// Classe para geração de arquivos PDF
	require_once("../../../../class/fpdf/fpdf.php");
	
	// Classe para geração dos impressos do desconto de cheque em PDF
	class PDF extends FPDF {
	
		var $nrLinhas = 0; // Acumular número de Linhas da página
		
		// Método Construtor
		function PDF($orientation = "P",$unit = "cm",$format = "A4") {
			$this->FPDF($orientation,$unit,$format);
		}
		
		// Gerar Layout para impressos
		function geraImpresso($dadosImpressos,$idImpresso) {		
			if ($idImpresso == "1") {
				$this->geraPropostaLimite($dadosImpressos["PROPLIMI"],$dadosImpressos["EMPRESTI"],$dadosImpressos["RATING"]);
				$this->geraContratoLimite($dadosImpressos["CTRLIMIT"],$dadosImpressos["AVALISTA"]);
				$this->geraNPLimite($dadosImpressos["AVALISTA"],$dadosImpressos["NOTAPROM"]);
			} elseif ($idImpresso == "2") {
				$this->geraContratoLimite($dadosImpressos["CTRLIMIT"],$dadosImpressos["AVALISTA"]);
			} elseif ($idImpresso == "3") {
				$this->geraPropostaLimite($dadosImpressos["PROPLIMI"],$dadosImpressos["EMPRESTI"],$dadosImpressos["RATING"]);
			} elseif ($idImpresso == "4") {
				$this->geraNPLimite($dadosImpressos["AVALISTA"],$dadosImpressos["NOTAPROM"]);			
			} elseif ($idImpresso == "5") {
				$this->geraPropostaBordero($dadosImpressos["PROPBORD"],$dadosImpressos["EMPRESTI"]);
				$this->geraChequesBordero($dadosImpressos["CABECTIT"],$dadosImpressos["TITSBORD"],$dadosImpressos["TBRESTRI"],$dadosImpressos["SACADNPG"]);
			} elseif ($idImpresso == "6") {
				$this->geraPropostaBordero($dadosImpressos["PROPBORD"],$dadosImpressos["EMPRESTI"]);
			} elseif ($idImpresso == "7"){
				$this->geraChequesBordero($dadosImpressos["CABECTIT"],$dadosImpressos["TITSBORD"],$dadosImpressos["TBRESTRI"],$dadosImpressos["SACADNPG"]);
			}
		}
		
		function controlaString($str,$tamanho) {
			if (strlen($str) <= $tamanho) {
				return array($str,"");
			}

			$newStr = substr($str,0,$tamanho);

			if (substr($newStr,$tamanho - 1,1) <> " " && substr($str,$tamanho,1) <> " ") {
				$newStr = substr($newStr,0,strrpos($newStr," ") + 1);
			}

			$arStr[0] = $newStr;
			$arStr[1] = trim(substr($str,strlen($arStr[0])));
			
			$strPos = $arStr[0];
			
			if (strrpos($strPos," ") == strlen($strPos) - 1) {
				$strPos = substr($strPos,0,strrpos($strPos," ") - 1);
			}
			
			while (strlen($arStr[0]) < $tamanho) {				
				$pos    = strrpos($strPos," ");
				$strPos = substr($strPos,0,$pos);

				$arStr[0] = substr($arStr[0],0,$pos + 1)." ".substr($arStr[0],$pos + 1);				
			}

			return $arStr;			
		}
		
		function controlaLinhas($linhas) {
			$this->nrLinhas += $linhas;
			
			if ($this->nrLinhas > 60) {
				$this->AddPage();						
				$this->nrLinhas = $linhas;
			}
		}		
		
		function geraPropostaLimite($dadosProposta,$Emprestimos,$dadosRating) {
			$this->SetMargins(1.5,1.5);
			$this->AddPage();

			$this->SetFont("Courier","",9);
			$this->SetTextColor(0,0,0);
			$this->Cell(18,0.4,$dadosProposta["NMEXTCOP"],0,1,"L",0,"");			

			$this->Ln();
			$this->SetFont("Courier","",11);
			$this->Cell(18,0.4,"PROPOSTA DE LIMITE DE DESCONTO DE CHEQUES",0,1,"L",0,"");
			
			$this->Ln();
			
			$this->SetFont("Courier","B",10);
			$this->Cell(18,0.4,"DADOS DO ASSOCIADO",0,1,"L",0,"");
			
			$this->Ln();			
			$this->SetFont("Courier","",10);
			$this->Cell(4.5,0.4,"Conta/dv: ".formataNumericos("zzzz.zzz-9",$dadosProposta["NRDCONTA"],".-"),0,0,"L",0,"");
			$this->Cell(1.25,0.4,"",0,0,"L",0,"");
			$this->Cell(4.5,0.4,"Matrícula: ".formataNumericos("zzz.zz9",$dadosProposta["NRMATRIC"],"."),0,0,"L",0,"");
			$this->Cell(1.25,0.4,"",0,0,"L",0,"");
			$this->Cell(6.5,0.4,"PA: ".$dadosProposta["DSAGENCI"],0,1,"L",0,"");
			
			$this->Ln();
			
			$this->Cell(18,0.4,"Nome: ".$dadosProposta["NMPRIMTL"],0,1,"L",0,"");
			
			$this->Cell(14,0.4,"CPF/CNPJ: ".$dadosProposta["NRCPFCGC"],0,0,"L",0,"");
			$this->Cell(4,0.4,"Adm COOP: ".$dadosProposta["DTADMISS"],0,1,"R",0,"");
			
			$this->Ln();
			
			$this->Cell(9.5,0.4,"Empresa: ".$dadosProposta["NMEMPRES"],0,0,"L",0,"");
			$this->Cell(9.5,0.4,"Telefone/Ramal: ".$dadosProposta["TELEFONE"],0,0,"L",0,"");		
			$this->Cell(8.5,0.4,"Adm Empr: ".$dadosProposta["DTADMEMP"],0,1,"L",0,"");		
			$this->Cell(9.5,0.4,"Tipo de Conta: ".$dadosProposta["DSTIPCTA"],0,0,"L",0,"");
			$this->Cell(8.5,0.4,"Situação da Conta: ".$dadosProposta["DSSITDCT"],0,1,"L",0,"");					
			$this->Cell(8.5,0.4,"Ramo de Atividade: ".$dadosProposta["DSRAMATI"],0,1,"L",0,"");					
			
			$this->Ln();
			$this->SetFont("Courier","B",10);
			$this->Cell(18,0.4,"RECIPROCIDADE",0,1,"L",0,"");
			$this->SetFont("Courier","",10);
			
			$this->Cell(8.7,0.4,"Saldo Médio do Trimestre: ".number_format(str_replace(",",".",$dadosProposta["VLSMDTRI"]),2,",","."),0,0,"L",0,"");
			$this->Cell(0.15,0.4,"",0,0,"L",0,"");
			$this->Cell(5.25,0.4,"Capital: ".number_format(str_replace(",",".",$dadosProposta["VLCAPTAL"]),2,",","."),0,0,"L",0,"");
			$this->Cell(0.15,0.4,"",0,0,"L",0,"");
			$this->Cell(3.75,0.4,"Plano: ".number_format(str_replace(",",".",$dadosProposta["VLPREPLA"]),2,",","."),0,1,"L",0,"");	
			$this->Cell(18,0.4,"Aplicações: ".number_format(str_replace(",",".",$dadosProposta["VLAPLICA"]),2,",","."),0,1,"L",0,"");
			
			$this->Ln();
			
			$this->SetFont("Courier","B",10);
			$this->Cell(18,0.4,"RENDA MENSAL",0,1,"L",0,"");
			$this->SetFont("Courier","",10);

			$this->Cell(4.5,0.4,"Salário: ".number_format(str_replace(",",".",$dadosProposta["VLSALARI"]),2,",","."),0,0,"L",0,"");
			$this->Cell(0.25,0.4,"",0,0,"L",0,"");
			$this->Cell(7,0.4,"Salário do Cônjuge: ".number_format(str_replace(",",".",$dadosProposta["VLSALCON"]),2,",","."),0,0,"L",0,"");
			$this->Cell(0.25,0.4,"",0,0,"L",0,"");
			$this->Cell(6,0.4,"Outras Rendas: ".number_format(str_replace(",",".",$dadosProposta["VLOUTRAS"]),2,",","."),0,1,"L",0,"");				
			$this->Cell(18,0.4,"Faturamento Mensal: ".number_format(str_replace(",",".",$dadosProposta["VLFATURA"]),2,",","."),0,1,"L",0,"");			

			$this->Ln();			
			
			$this->SetFont("Courier","B",10);
			$this->Cell(18,0.4,"LIMITES",0,1,"L",0,"");
			$this->SetFont("Courier","",10);
			
			$this->Cell(9,0.4,"Cheque Especial: ".number_format(str_replace(",",".",$dadosProposta["VLLIMCRE"]),2,",","."),0,0,"L",0,"");
			$this->Cell(9,0.4,"Cartões de Crédito: ".number_format(str_replace(",",".",$dadosProposta["VLTOTCR"]),2,",","."),0,1,"L",0,"");
			$this->Cell(18,0.4,"Desconto de Títulos: ".number_format(str_replace(",",".",$dadosProposta["VLLIMTIT"]),2,",","."),0,1,"L",0,"");
			
			$this->Ln();
			
			$this->SetFont("Courier","B",10);
			$this->Cell(3,0.4,"BENS:",0,0,"L",0,"");
			$this->SetFont("Courier","",10);
			$this->Cell(15,0.4,$dadosProposta["DSDEBEN1"],0,1,"L",0,"");
			$this->Cell(3,0.4,"",0,0,"L",0,"");
			$this->Cell(15,0.4,$dadosProposta["DSDEBEN2"],0,1,"L",0,"");
			
			$this->Ln();			
			
			$this->SetFont("Courier","B",10);
			$this->Cell(18,0.4,"LIMITE PROPOSTO",0,1,"L",0,"");
			$this->SetFont("Courier","",10);
				
			$this->Cell(2.5,0.4,"Contrato",0,0,"R",0,"");
			$this->Cell(3.5,0.4,"Valor",0,0,"R",0,"");
			$this->Cell(6,0.4,"Linha de Desconto",0,0,"L",0,"");
			$this->Cell(6,0.4,"Valor Médio dos cheques",0,1,"R",0,"");
			$this->Cell(2.5,0.4,formataNumericos("zzz.zz9",$dadosProposta["NRCTRLIM"],"."),0,0,"R",0,"");
			$this->Cell(3.5,0.4,number_format(str_replace(",",".",$dadosProposta["VLLIMPRO"]),2,",","."),0,0,"R",0,"");
			$this->Cell(6,0.4,$dadosProposta["DSDLINHA"],0,0,"L",0,"");
			$this->Cell(6,0.4,number_format(str_replace(",",".",$dadosProposta["VLMEDCHQ"]),2,",","."),0,1,"R",0,"");			
			
			$this->Ln();
			
			if (count($Emprestimos) == 0) {
				$this->SetFont("Courier","B",10);
				$this->Cell(18,0.4,"SEM ENDIVIDAMENTO NA COOPERATIVA",0,1,"L",0,"");			
				$this->SetFont("Courier","",10);
			}else{
				for ($i = 0;$i < count($Emprestimos); $i++){
					if ($Emprestimos[$i]["VLSDEVED"] == 0){
						continue;
					}
					if ($i == 0){
						$this->controlaLinhas(2);
						$this->SetFont("Courier","B",10);
						$this->Cell(18,0.4,"ENDIVIDAMENTO NA COOPERATIVA EM: ".$dadosProposta["DTCALCUL"],0,1,"L",0,"");
						$this->SetFont("Courier","",10);

						$this->Cell(2,0.4,"Contrato",0,0,"R",0,"");
						$this->Cell(3,0.4,"Saldo Devedor",0,0,"R",0,"");
						$this->Cell(4.3,0.4,"Prestações",0,0,"R",0,"");
						$this->Cell(4.7,0.4,"Linha de Crédito",0,0,"L",0,"");
						$this->Cell(4,0.4,"Finalidade",0,1,"L",0,"");
						
						
					}
					$this->controlaLinhas(1);
					$this->Cell(2,0.4,formataNumericos("z.zzz.zz9",$Emprestimos[$i]["NRCTREMP"],"."),0,0,"R",0,"");
					$this->Cell(3,0.4,number_format(str_replace(",",".",$Emprestimos[$i]["VLSDEVED"]),2,",","."),0,0,"R",0,"");
					$this->SetFont("Courier","",8);
					$this->Cell(4.3,0.4,substr($Emprestimos[$i]["DSPREAPG"],5,11). " " . number_format(str_replace(",",".",$Emprestimos[$i]["VLPREEMP"]),2,",","."),0,0,"R",0,"");
					$this->SetFont("Courier","",7);
					$this->Cell(4.7,0.4,$Emprestimos[$i]["DSLCREMP"],0,0,"L",0,"");
					$this->Cell(4,0.4,$Emprestimos[$i]["DSFINEMP"],0,1,"L",0,"");
					$this->SetFont("Courier","",10);
					if ($i == (count($Emprestimos) - 1)){
						$this->Cell(2,0.4,"",0,0,"R",0,"");
						$this->Cell(3,0.4,number_format(str_replace(",",".",$dadosProposta["VLSDEVED"]),2,",","."),"T",0,"R",0,"");
						$this->Cell(4.3,0.4,number_format(str_replace(",",".",$dadosProposta["VLPREEMP"]),2,",","."),"T",0,"R",0,"");
						$this->Cell(8.7,0.4,"",0,1,"L",0,"");
					}
				}			
			}
			$this->controlaLinhas(2);

			$this->Ln();			

			$this->Cell(18,0.4,"TOTAL OP.crédito: ".number_format(str_replace(",",".",$dadosProposta["VLUTILIZ"]),2,",","."),0,1,"L",0,"");

			$this->controlaLinhas(3);

			$this->Ln();			

			$this->MultiCell(18,0.4,"AUTORIZO A CONSULTA DE MINHAS INFORMAÇÕES CADASTRAIS NOS SERVIÇOS DE PROTEÇÃO DE CRÉDITO (SPC, SERASA, ...) ALÉM DO CADASTRO DA CENTRAL DE RISCO DO BANCO CENTRAL DO BRASIL.",0,"J",0);			

			$this->controlaLinhas(6);
			$this->Ln();

			$this->SetFont("Courier","B",10);
			$this->Cell(18,0.4,"OBSERVAÇÕES",0,1,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->MultiCell(18,0.4,$dadosProposta["DSOBSER1"],0,"J",0);
			$this->MultiCell(18,0.4,$dadosProposta["DSOBSER2"],0,"J",0);
			$this->MultiCell(18,0.4,$dadosProposta["DSOBSER3"],0,"J",0);
			$this->MultiCell(18,0.4,$dadosProposta["DSOBSER4"],0,"J",0);

			$this->controlaLinhas(2);

			$this->Ln();

			$this->Cell(18,0.4,"Consultado SPC em:   ___/___/______",0,1,"L",0,"");

			$this->controlaLinhas(2);
		
			$this->Ln();
			
			$this->Cell(18,0.4,"Central de risco em: ___/___/______  Situação: ______________  Visto: ______________",0,1,"L",0,"");			

			$this->controlaLinhas(3);

			$this->Ln();
			$this->Ln();
			
			$this->SetFont("Courier","B",10);
			$this->Cell(18,0.4,"A P R O V A Ç Ã O",0,1,"L",0,"");
			$this->SetFont("Courier","",10);
			
			$this->controlaLinhas(5);			

			$this->Ln();
			$this->Ln();	
			$this->Ln();	

			$this->Cell(8.5,0.4,"","B",0,"L",0,"");
			$this->Cell(1,0.4,"",0,0,"L",0,"");
			$this->Cell(8.5,0.4,"","B",1,"L",0,"");	
			$this->Cell(8.5,0.4,"Operador: ".$dadosProposta["NMOPERAD"],0,0,"L",0,"");
			$this->Cell(1,0.4,"",0,0,"L",0,"");
			$this->MultiCell(8.5,0.4,trim($dadosProposta["NMRESCO1"])."\n".trim($dadosProposta["NMRESCO2"]),0,"C",0);						

			$this->controlaLinhas(4);
			
			$this->Ln();
			$this->Ln();		
			
			$this->Cell(8.5,0.4,"","B",0,"L",0,"");
			$this->Cell(9.5,0.4,"",0,1,"L",0,"");			
			$this->Cell(8.5,0.4,$dadosProposta["NMPRIMTL"],0,0,"L",0,"");
			$this->Cell(1,0.4,"",0,0,"L",0,"");
			$this->Cell(8.5,0.4,$dadosProposta["NMCIDADE"].", ".$dadosProposta["DDMVTOLT"]." de ".$dadosProposta["DSMESREF"]." de ".$dadosProposta["AAMVTOLT"].".",0,0,"C",0,"");							
		
			$qtRatings = count($dadosRating);						
			
			if ($qtRatings > 0) {							
				$this->Ln();
				$this->Ln();
				
				$this->Cell(18,0.35,"Risco da Proposta:",0,1,"L",0,"");
				
				$this->Ln();
				
				$this->Cell(2.0,0.35,"Operação:",0,0,"L",0,"");
				$this->Cell(3.5,0.35,$dadosRating[0]["DSDOPERA"],0,0,"L",0,"");
				$this->Cell(2.0,0.35,"Contrato:",0,0,"L",0,"");
				$this->Cell(2.2,0.35,number_format($dadosRating[0]["NRCTRRAT"],0,",","."),0,0,"L",0,"");
				$this->Cell(1.4,0.35,"Risco:",0,0,"L",0,"");
				$this->Cell(0.8,0.35,$dadosRating[0]["INDRISCO"],0,0,"L",0,"");
				$this->Cell(1.15,0.35,"Nota:",0,0,"L",0,"");
				$this->Cell(1.8,0.35,number_format($dadosRating[0]["NRNOTRAT"],2,",","."),0,0,"L",0,"");
				$this->Cell(3.15,0.35,$dadosRating[0]["DSDRISCO"],0,1,"L",0,"");
				
				for ($i = 1; $i < $qtRatings; $i++) {
					if ($i == 1) {
						$this->Ln();						
						
						$this->Cell(18,0.35,"Histórico dos Ratings:",0,1,"L",0,"");
						
						$this->Ln();
						
						$this->Cell(3.3,0.35,"Operação",0,0,"L",0,"");
						$this->Cell(2.15,0.35,"Contrato",0,0,"R",0,"");
						$this->Cell(1.4,0.35,"Risco",0,0,"C",0,"");
						$this->Cell(1.7,0.35,"Nota",0,0,"R",0,"");
						$this->Cell(3.15,0.35,"Valor Operação",0,0,"R",0,"");
						$this->Cell(2.0,0.35,"Situação",0,1,"L",0,"");
						
						$this->Cell(3.3,0.35,"---------------",0,0,"L",0,"");						
						$this->Cell(2.15,0.35,"---------",0,0,"R",0,"");						
						$this->Cell(1.4,0.35,"------",0,0,"C",0,"");
						$this->Cell(1.7,0.35,"-------",0,0,"R",0,"");
						$this->Cell(3.15,0.35,"--------------",0,0,"R",0,"");
						$this->Cell(2.0,0.35,"---------",0,1,"L",0,"");
					}
					
					$this->Cell(3.3,0.35,$dadosRating[$i]["DSDOPERA"],0,0,"L",0,"");
					$this->Cell(2.15,0.35,number_format($dadosRating[$i]["NRCTRRAT"],0,",","."),0,0,"R",0,"");
					$this->Cell(1.4,0.35,$dadosRating[$i]["INDRISCO"],0,0,"C",0,"");
					$this->Cell(1.7,0.35,number_format($dadosRating[$i]["NRNOTRAT"],2,",","."),0,0,"R",0,"");
					$this->Cell(3.15,0.35,number_format($dadosRating[$i]["VLOPERAC"],2,",","."),0,0,"R",0,"");
					$this->Cell(2.0,0.35,$dadosRating[$i]["DSDITRAT"],0,1,"L",0,"");					
				}
			}
		}
		
		function geraContratoLimite($dadosContrato,$dadosAvalistas) {
			$this->SetMargins(1.5,1.5);
			
			$this->AddPage();

			$this->SetFont("Courier","B",10);
			$this->SetTextColor(0,0,0);
			
			$this->Cell(18,0.4,"CONTRATO DE DESCONTO DE CHEQUES PRÉ-DATADOS E GARATIA REAL",0,1,"C",0,"");			

			$this->Ln();
			
			$this->Cell(2.7,0.4,"CONTRATO N.:",0,0,"L",0,"");
			$this->SetFont("Courier","",10);
			$this->Cell(15.3,0.4,formataNumericos("zzz.zz9",$dadosContrato["NRCTRLIM"],"."),0,1,"L",0,"");
			
			$this->Ln();
			
			$this->SetFont("Courier","B",10);
			
			$this->Cell(18,0.4,"FOLHA DE ROSTO",0,1,"C",0,"");
			
			$this->Ln();
			
			$this->Cell(18,0.4,"1. DA IDENTIFICAÇÃO:",0,1,"L",0,"");
		
			$this->Ln();
			
			$strCell = $this->controlaString($dadosContrato["DSLINHA1"]." ".$dadosContrato["DSLINHA2"]." ".$dadosContrato["DSLINHA3"],68);			
		
			$this->Cell(3.45,0.4,"1.1 COOPERATIVA:",0,0,"L",0,"");
			$this->SetFont("Courier","",10);
			$this->Cell(14.55,0.4,$dadosContrato["NMEXTCOP"]. " - PA: ".formataNumericos('999',$dadosContrato["CDAGENCI"],''),0,1,"L",0,""); 
			$this->Cell(0.8,0.4,"",0,0,"L",0,"");
			$this->MultiCell(17.2,0.4,$dadosContrato["DSLINHA1"]. " ".$dadosContrato["DSLINHA2"]. " ". $dadosContrato["DSLINHA3"],0,"J",0);			
			
			$this->Ln();			
			
			$this->SetFont("Courier","B",10);
			
			$strCell = $this->controlaString($dadosContrato["NMPRIMT1"].", CPF/CNPJ: ".$dadosContrato["NRCPFCGC"].", CONTA CORRENTE: ".formataNumericos("zzzz.zzz-9",$dadosContrato["NRDCONTA"],".-").".",67);
			
			$this->Cell(3.7,0.4,"1.2 COOPERADO(A):",0,0,"L",0,"");
			$this->SetFont("Courier","",10);
			$this->Cell(14.3,0.4,$strCell[0],0,1,"L",0,""); 
			
			if ($strCell[1] <> "") {
				$this->MultiCell(18,0.4,$strCell[1],0,"J",0);
			}
			
			$strCell = $this->controlaString("Valor: ".$dadosContrato["DSDMOEDA"]." ".number_format(str_replace(",",".",$dadosContrato["VLLIMITE"]),2,",",".").str_replace("*","",$dadosContrato["DSLIMIT1"]).str_replace("*","",$dadosContrato["DSLIMIT2"]),75);
			
			$this->Ln();			
			
			$this->SetFont("Courier","B",10);
					
			$this->Cell(18,0.4,"2. DO VALOR DE LIMITE DESCONTO: ",0,1,"L",0,"");
			$this->Ln();
			$this->SetFont("Courier","",10);
			$this->Cell(18,0.4,"2.1 ".$strCell[0],0,1,"L",0,"");			 
			
			if ($strCell[1] <> "") {				
				$this->MultiCell(18,0.4,$strCell[1],0,"J",0);
			}
			
			$this->Ln();		
			
			$this->SetFont("Courier","B",10);
					
			$this->Cell(18,0.4,"3. DA LINHA DE DESCONTO DE CHEQUES PRÉ-DATADOS: ",0,1,"L",0,"");
			$this->Ln();
			$this->SetFont("Courier","",10);
			$this->Cell(18,0.4,"3.1 Linha de Desconto: ".$dadosContrato["DSDLINHA"],0,1,"L",0,"");			 

			$this->Ln();		
			
			$this->SetFont("Courier","B",10);
					
			$this->Cell(18,0.4,"4. DO PRAZO DE VIGÊNCIA DO CONTRATO:",0,1,"L",0,"");
			$this->Ln();
			$this->SetFont("Courier","",10);
			$this->Cell(18,0.4,"4.1 Prazo de vigência do contrato: ".$dadosContrato["QTDIAVIG"]." ".$dadosContrato["TXQTDVI1"],0,1,"L",0,"");			 
			
			$strCell = $this->controlaString($dadosContrato["DSENCFI1"]." ".$dadosContrato["DSENCFI2"],54);
			
			$this->Ln();			
			
			$this->SetFont("Courier","B",10);
					
			$this->Cell(18,0.4,"5. DOS ENCARGOS FINANCEIROS:",0,1,"L",0,"");
			$this->Ln();
			$this->SetFont("Courier","",10);
			$this->Cell(18,0.4,"5.1 Juros de Mora: ".str_replace("*","",$dadosContrato["DSJURMO1"]),0,1,"L",0,"");
			$this->Cell(18,0.4,"                   ".str_replace("*","",$dadosContrato["DSJURMO2"]),0,1,"L",0,"");

			$this->Ln();			

			$this->Cell(9,0.4,"5.2 Multa por inadimplência: ".$dadosContrato["TXDMULTA"]." % ",0,0,"L",0,"");
			$this->MultiCell(9,0.4,$dadosContrato["TXMULEX1"]. " " .$dadosContrato["TXMULEX2"],0,"J",0);
			
			$this->Ln();			
			
			$this->MultiCell(18,0.4,"5.3 Os encargos de desconto serão apurados na forma do estabelecimento no item 4 (quatro) das CONDIÇÕES GERAIS.",0,"J",0);
			
			$this->Ln();			

			$this->SetFont("Courier","B",10);
			
			$this->Cell(18,0.4,"6. DA DECLARAÇÃO INERENTE A FOLHA DE ROSTO:",0,1,"L",0,"");
			$this->Ln();
			$this->SetFont("Courier","",10);
			$this->MultiCell(18,0.4,"Declaram as partes, abaixo assinadas, que a presente Folha de Rosto é parte integrante das CONDIÇÕES GERAIS do Contrato de Desconto de Cheques Pré-Datados e Garantia Real, cujas condições aceitam, outorgam e prometem cumprir.",0,"J",0);																		
			
			$this->Ln();
			
			$this->Cell(18,0.4,$dadosContrato["NMCIDADE"],0,1,"L",0,"");
			
			$this->Ln();
			$this->Ln();
			$this->Ln();
			$this->Ln();
			
			$this->Cell(8.75,0.4,"________________________________________",0,0,"L",0,"");
			$this->Cell(0.5,0.4,"",0,0,"L",0,"");
			$this->Cell(8.75,0.4,"________________________________________",0,1,"L",0,"");	
			$this->Cell(8.75,0.4,$dadosContrato["NMPRIMT1"],0,0,"L",0,"");
			$this->Cell(0.5,0.4,"",0,0,"L",0,"");
			$this->MultiCell(8.75,0.4,trim($dadosContrato["NMRESCO1"])."\n".trim($dadosContrato["NMRESCO2"]),0,"C",0);				
					
			for ($i = 0; $i < count($dadosAvalistas); $i++) {
				$this->Ln();
				$this->Ln();
							
				$this->Cell(8.75,0.4,"________________________________________",0,0,"L",0,"");
				$this->Cell(0.5,0.4,"",0,0,"L",0,"");
				$this->Cell(8.75,0.4,"________________________________________",0,1,"L",0,"");								
				$this->Cell(8.75,0.4,$dadosAvalistas[$i]["NMDAVALI"],0,0,"L",0,"");
				$this->Cell(0.5,0.4,"",0,0,"L",0,"");
				$this->Cell(8.75,0.4,$dadosAvalistas[$i]["NMCONJUG"],0,1,"L",0,"");
				$docava = $dadosAvalistas[$i]["NRDOCAVA"] == "________________________________________" ? $dadosAvalistas[$i]["NRDOCAVA"] : $dadosAvalistas[$i]["NRDOCAVA"]. " - ". formataNumericos('zzzz.zz9-9',$dadosAvalistas[$i]["NRCTAAVA"],'.-');				
				$this->Cell(8.75,0.4,$docava,0,0,"L",0,"");
				$this->Cell(0.5,0.4,"",0,0,"L",0,"");
				$this->Cell(8.75,0.4,$dadosAvalistas[$i]["NRDOCCJG"],0,1,"L",0,"");				
				$this->Cell(18,0.4,$dadosAvalistas[$i]["DSENDRE1"],0,1,"L",0,"");
				$this->Cell(18,0.4,$dadosAvalistas[$i]["DSENDRE2"],0,1,"L",0,"");										
			}	
			
			$this->Ln();
			$this->Ln();			
			$this->Ln();
			
			$this->Cell(8.75,0.4,"________________________________________",0,0,"L",0,"");
			$this->Cell(0.5,0.4,"",0,0,"L",0,"");
			$this->Cell(8.75,0.4,"________________________________________",0,1,"L",0,"");							
			$this->Cell(8.75,0.4,"TESTEMUNHA 1: __________________________",0,0,"L",0,"");
			$this->Cell(0.5,0.4,"",0,0,"L",0,"");
			$this->Cell(8.75,0.4,"TESTEMUNHA 2: __________________________",0,1,"L",0,"");								
			$this->Cell(8.75,0.4,"CPF/MF: ________________________________",0,0,"L",0,"");
			$this->Cell(0.5,0.4,"",0,0,"L",0,"");
			$this->Cell(8.75,0.4,"CPF/MF: ________________________________",0,1,"L",0,"");		
			$this->Cell(8.75,0.4,"CI: ____________________________________",0,0,"L",0,"");
			$this->Cell(0.5,0.4,"",0,0,"L",0,"");
			$this->Cell(8.75,0.4,"CI: ____________________________________",0,1,"L",0,"");				
			
			$this->Ln();
			$this->Ln();
			$this->Ln();	
			
			$this->Cell(8.75,0.4,"",0,0,"L",0,"");
			$this->Cell(0.5,0.4,"",0,0,"L",0,"");
			$this->Cell(8.75,0.4,"________________________________________",0,1,"L",0,"");
			$this->Cell(8.75,0.4,"",0,0,"L",0,"");
			$this->Cell(0.5,0.4,"",0,0,"L",0,"");
			$this->Cell(8.75,0.4,"Operador: ".$dadosContrato["NMOPERAD"],0,1,"L",0,"");	
			
			$this->Ln();	
			$this->Ln();			
			$this->Ln();	
			$this->Ln();			
			
			$this->MultiCell(18,0.4,"---------------------------> PARA USO DA DIGITAÇÃO <---------------------------",0,"C",0);							
			
			$this->Ln();	
			
			$this->Cell(3,0.4,"Conta/dv",0,0,"R",0,"");
			$this->Cell(2.5,0.4,"Contrato",0,0,"R",0,"");
			$this->Cell(3.5,0.4,"Prestação",0,0,"R",0,"");
			$this->Cell(4,0.4,"1o. Avalista",0,0,"R",0,"");
			$this->Cell(4,0.4,"2o. Avalista",0,0,"R",0,"");
			$this->Cell(1,0.4,"",0,1,"R",0,"");
			
			$this->Ln();	
			$this->Ln();

			$this->SetFont("Courier","B",10);
			$this->Cell(3,0.4,formataNumericos("zzzz.zzz-9",$dadosContrato["NRDCONTA"],".-"),0,0,"R",0,"");
			$this->Cell(2.5,0.4,formataNumericos("zzz.zz9",$dadosContrato["NRCTRLIM"],"."),0,0,"R",0,"");
			$this->Cell(3.5,0.4,formataNumericos('zzz.zz9,99',$dadosContrato["VLLIMITE"],'.,'),0,0,"R",0,"");
			$this->Cell(4,0.4,"[_______________]",0,0,"R",0,"");
			$this->Cell(4,0.4,"[_______________]",0,0,"R",0,"");
			$this->Cell(1,0.4,"",0,1,"R",0,"");
			$this->SetFont("Courier","",10);
			
		}

		function geraNPLimite($dadosAvalistas,$dadosNP) {
			$this->SetMargins(0.5,0.8);
			
			$this->AddPage();

			$this->SetFont("Courier","B",10);
			
			$this->Cell(9,0.4,"NOTA PROMISSÓRIA VINCULADA AO",0,0,"L",0,"");
			$this->SetFont("Courier","",10);
			$this->Cell(9,0.4,"Vencimento: ".$dadosNP["DDMVTOLT"]." de ".$dadosNP["DSMESREF"]." de ".$dadosNP["AAMVTOLT"],0,1,"R",0,"");
			$this->SetFont("Courier","B",10);
			$this->Cell(18,0.4,"CONTRATO DE DESCONTO DE CHEQUES",0,1,"L",0,"");
			$this->SetFont("Courier","",10);
			
			$this->Ln();
			
			$this->Cell(1.5,0.4,"NÚMERO ",0,0,"L",0,"");
			$this->SetFont("Courier","",15);
			$this->Cell(7,0.4,$dadosNP["DSCTREMP"],0,0,"R",0,"");
			$this->SetFont("Courier","",10);
			$this->Cell(1,0.4,"",0,0,"L",0,"");
			$this->Cell(1.5,0.4,$dadosNP["DSDMOEDA"],0,0,"L",0,"");
			$this->SetFont("Courier","",15);
			$this->Cell(7,0.4,number_format(str_replace(",",".",$dadosNP["VLPREEMP"]),2,",","."),0,1,"R",0,"");
			
			$this->Ln();
			
			$this->SetFont("Courier","",10);
			
			$this->Cell(18,0.4,"Ao(s) ".$dadosNP["DSMVTOL1"],0,1,"L",0,"");
			$this->Cell(8.25,0.4,$dadosNP["DSMVTOL2"]." pagarei por esta única via de",0,0,"L",0,"");
			$this->SetFont("Courier","",15);
			$this->Cell(9.75,0.4,"N O T A  P R O M I S S Ó R I A",0,1,"L",0,"");
			$this->SetFont("Courier","",10);
			$this->MultiCell(18,0.4,"à ".$dadosNP["NMRESCOP"]." - ".$dadosNP["NMEXTCOP"]." ".$dadosNP["NRDOCNPJ"]." ou a sua ordem a quantia de ".str_replace("*","",$dadosNP["DSPREMP1"]).str_replace("*","",$dadosNP["DSPREMP2"])." em moeda corrente deste país.",0,"L",0);
			
			$this->Ln();
			
			$this->Cell(9,0.4,$dadosNP["NMCIDPAC"],0,0,"L",0,"");
			$this->Cell(9,0.4,$dadosNP["DSEMSNOT"],0,1,"R",0,"");
			
			$this->Ln();
			
			$this->Cell(18,0.4,$dadosNP["NMPRIMTL"],0,1,"L",0,"");
			$this->Cell(8.75,0.4,$dadosNP["DSCPFCGC"],0,0,"L",0,"");
			$this->Cell(0.5,0.4,"",0,0,"L",0,"");
			$this->Cell(8.75,0.4,"________________________________________",0,1,"L",0,"");
			$this->Cell(8.75,0.4,"Conta/dv: ".formataNumericos("zzzz.zzz-9",$dadosNP["NRDCONTA"],".-"),0,0,"L",0,"");
			$this->Cell(0.5,0.4,"",0,0,"L",0,"");
			$this->Cell(8.75,0.4,"ASSINATURA",0,1,"L",0,"");
			$this->Ln();
			$this->Cell(18,0.4,"Endereço:",0,1,"L",0,"");
			$this->Cell(18,0.4,$dadosNP["DSENDCO1"],0,1,"L",0,"");
			$this->Cell(18,0.4,$dadosNP["DSENDCO2"],0,1,"L",0,"");
			
			$this->Ln();
			
			$this->Cell(8.75,0.4,"Avalistas:",0,0,"L",0,"");
			$this->Cell(0.5,0.4,"",0,0,"L",0,"");
			$this->Cell(8.75,0.4,"Cônjuge:",0,1,"L",0,"");			
			
			for ($i = 0; $i < count($dadosAvalistas); $i++) {
				$this->Ln();
				$this->Ln();
							
				$this->Cell(8.75,0.4,"________________________________________",0,0,"L",0,"");
				$this->Cell(0.5,0.4,"",0,0,"L",0,"");
				$this->Cell(8.75,0.4,"________________________________________",0,1,"L",0,"");								
				$this->Cell(8.75,0.4,$dadosAvalistas[$i]["NMDAVALI"],0,0,"L",0,"");
				$this->Cell(0.5,0.4,"",0,0,"L",0,"");
				$this->Cell(8.75,0.4,$dadosAvalistas[$i]["NMCONJUG"],0,1,"L",0,"");		
				$docava = $dadosAvalistas[$i]["NRDOCAVA"] == "________________________________________" ? $dadosAvalistas[$i]["NRDOCAVA"] : $dadosAvalistas[$i]["NRDOCAVA"]. " - ". formataNumericos('zzzz.zz9-9',$dadosAvalistas[$i]["NRCTAAVA"],'.-');
				$this->Cell(8.75,0.4,$docava,0,0,"L",0,"");
				$this->Cell(0.5,0.4,"",0,0,"L",0,"");
				$this->Cell(8.75,0.4,$dadosAvalistas[$i]["NRDOCCJG"],0,1,"L",0,"");				
				$this->Cell(18,0.4,$dadosAvalistas[$i]["DSENDRE1"],0,1,"L",0,"");
				$ende2 = $dadosAvalistas[$i]["DSENDRE2"] == "________________________________________" ? $dadosAvalistas[$i]["DSENDRE2"] : $dadosAvalistas[$i]["DSENDRE2"]. " - ". $dadosAvalistas[$i]["NMCIDADE"]."/".$dadosAvalistas[$i]["CDUFRESD"]." - ".formataNumericos('zz.zzz.zzz',$dadosAvalistas[$i]["NRCEPEND"],'.');
				$this->Cell(18,0.4,$ende2,0,1,"L",0,"");
			}								
		}

		function geraPropostaBordero($dadosProposta,$Emprestimos) {
			$this->nrLinhas = 35;
			$this->SetMargins(1.5,1.5);
			$this->AddPage();

			$this->SetFont("Courier","",9);
			$this->SetTextColor(0,0,0);
			$this->Cell(18,0.4,$dadosProposta["NMEXTCOP"],0,1,"L",0,"");			

			$this->Ln();
			$this->SetFont("Courier","",11);
			$this->Cell(10,0.4,"PROPOSTA DESCONTO DE CHEQUES",0,0,"L",0,"");
			$this->Cell(8,0.4,"PARA USO DA DIGITALIZACAO",0,1,"R",0,"");		
						
			$this->Ln();
			$this->Cell(10.6,0.4,"",0,0,"R",0,"");
			$this->Cell(2.6,0.4,formataNumericos("zzzz.zzz.9",$dadosProposta["NRDCONTA"],"."),0,0,"R",0,"");					
			$this->Cell(0.8,0.4,"",0,0,"R",0,"");		
			$this->Cell(2.4,0.4,formataNumericos("z.zzz.zz9",$dadosProposta["NRBORDER"],"."),0,0,"R",0,"");			
			$this->Cell(0.8,0.4,"",0,0,"R",0,"");		
			$this->Cell(0.8,0.4," 87",0,1,"R",0,"");	
			
			$this->Ln();
			
			$this->SetFont("Courier","B",10);
			$this->Cell(18,0.4,"DADOS DO ASSOCIADO",0,1,"L",0,"");
			
			$this->Ln();			
			$this->SetFont("Courier","",10);
			$this->Cell(4.5,0.4,"Conta/dv: ".formataNumericos("zzzz.zzz-9",$dadosProposta["NRDCONTA"],".-"),0,0,"L",0,"");
			$this->Cell(1.25,0.4,"",0,0,"L",0,"");
			$this->Cell(4.5,0.4,"Matrícula: ".formataNumericos("zzz.zz9",$dadosProposta["NRMATRIC"],"."),0,0,"L",0,"");
			$this->Cell(1.25,0.4,"",0,0,"L",0,"");
			$this->Cell(6.5,0.4,"PA: ".$dadosProposta["DSAGENCI"],0,1,"L",0,"");
			
			$this->Ln();
			
			$this->Cell(18,0.4,"Nome: ".$dadosProposta["NMPRIMTL"],0,1,"L",0,"");
			
			$this->Cell(14,0.4,"CPF/CNPJ: ".$dadosProposta["NRCPFCGC"],0,0,"L",0,"");
			$this->Cell(4,0.4,"Adm COOP: ".$dadosProposta["DTADMISS"],0,1,"R",0,"");
			
			$this->Ln();
			
			$this->Cell(9.5,0.4,"Empresa: ".$dadosProposta["NMEMPRES"],0,0,"L",0,"");
			$this->Cell(9.5,0.4,"Telefone/Ramal: ".$dadosProposta["TELEFONE"],0,0,"L",0,"");		
			$this->Cell(8.5,0.4,"Adm Empr: ".$dadosProposta["DTADMEMP"],0,1,"L",0,"");		
			$this->Cell(9.5,0.4,"Tipo de Conta: ".$dadosProposta["DSTIPCTA"],0,0,"L",0,"");
			$this->Cell(8.5,0.4,"Situação da Conta: ".$dadosProposta["DSSITDCT"],0,1,"L",0,"");					
			$this->Cell(8.5,0.4,"Ramo de Atividade: ".$dadosProposta["DSRAMATI"],0,1,"L",0,"");					
			
			$this->Ln();
			$this->SetFont("Courier","B",10);
			$this->Cell(18,0.4,"RECIPROCIDADE",0,1,"L",0,"");
			$this->SetFont("Courier","",10);
			
			$this->Cell(8.7,0.4,"Saldo Médio do Trimestre: ".number_format(str_replace(",",".",$dadosProposta["VLSMDTRI"]),2,",","."),0,0,"L",0,"");
			$this->Cell(0.15,0.4,"",0,0,"L",0,"");
			$this->Cell(5.25,0.4,"Capital: ".number_format(str_replace(",",".",$dadosProposta["VLCAPTAL"]),2,",","."),0,0,"L",0,"");
			$this->Cell(0.15,0.4,"",0,0,"L",0,"");
			$this->Cell(3.75,0.4,"Plano: ".number_format(str_replace(",",".",$dadosProposta["VLPREPLA"]),2,",","."),0,1,"L",0,"");	
			$this->Cell(18,0.4,"Aplicações: ".number_format(str_replace(",",".",$dadosProposta["VLAPLICA"]),2,",","."),0,1,"L",0,"");
			
			$this->Ln();
			
			$this->SetFont("Courier","B",10);
			$this->Cell(18,0.4,"RENDA MENSAL",0,1,"L",0,"");
			$this->SetFont("Courier","",10);

			$this->Cell(4.5,0.4,"Salário: ".number_format(str_replace(",",".",$dadosProposta["VLSALARI"]),2,",","."),0,0,"L",0,"");
			$this->Cell(0.25,0.4,"",0,0,"L",0,"");
			$this->Cell(7,0.4,"Salário do Cônjuge: ".number_format(str_replace(",",".",$dadosProposta["VLSALCON"]),2,",","."),0,0,"L",0,"");
			$this->Cell(0.25,0.4,"",0,0,"L",0,"");
			$this->Cell(6,0.4,"Outras Rendas: ".number_format(str_replace(",",".",$dadosProposta["VLOUTRAS"]),2,",","."),0,1,"L",0,"");				
			$this->Cell(18,0.4,"Faturamento Mensal: ".number_format(str_replace(",",".",$dadosProposta["VLFATURA"]),2,",","."),0,1,"L",0,"");			

			$this->Ln();			
			
			$this->SetFont("Courier","B",10);
			$this->Cell(18,0.4,"LIMITES",0,1,"L",0,"");
			$this->SetFont("Courier","",10);
			
			$this->Cell(9,0.4,"Cheque Especial: ".number_format(str_replace(",",".",$dadosProposta["VLLIMCRE"]),2,",","."),0,0,"L",0,"");
			$this->Cell(9,0.4,"Cartões de Crédito: ".number_format(str_replace(",",".",$dadosProposta["VLTOTCR"]),2,",","."),0,1,"L",0,"");
			$this->Cell(9,0.4,"Desconto de Cheques: ".number_format(str_replace(",",".",$dadosProposta["VLLIMCHQ"]),2,",","."),0,0,"L",0,"");
			$this->Cell(9,0.4,"Desconto de Títulos: ".number_format(str_replace(",",".",$dadosProposta["VLLIMTIT"]),2,",","."),0,1,"L",0,"");
			
			$this->Ln();

			$this->SetFont("Courier","B",10);
			$this->Cell(2,0.4,"BENS:",0,0,"L",0,"");
			$this->SetFont("Courier","",10);
			$this->Cell(16,0.4,$dadosProposta["DSDEBEN1"],0,1,"L",0,"");
			$this->Cell(2,0.4,"",0,0,"L",0,"");
			$this->Cell(16,0.4,$dadosProposta["DSDEBEN2"],0,1,"L",0,"");
			
			$this->Ln();			
			
			$this->SetFont("Courier","B",10);
			$this->Cell(5,0.4,"DESCONTO PROPOSTO:",0,0,"L",0,"");
			$this->SetFont("Courier","",10);
			$this->Cell(13,0.4,number_format(str_replace(",",".",$dadosProposta["VLBORCHQ"]),2,",","."). " (".formataNumericos("zzz.zz9",$dadosProposta["QTBORCHQ"],"."). ($dadosProposta["QTBORCHQ"] > 0 ? " Cheques)" : " Cheque)"),0,1,"L",0,"");

			if (count($Emprestimos) == 0) {
				$this->Ln();
				$this->SetFont("Courier","B",10);
				$this->Cell(18,0.4,"SEM ENDIVIDAMENTO NA COOPERATIVA",0,1,"L",0,"");			
				$this->SetFont("Courier","",10);
			}else{
				for ($i = 0;$i < count($Emprestimos); $i++){
					if ($Emprestimos[$i]["VLSDEVED"] == 0){
						continue;
					}
					if ($i == 0){
						$this->controlaLinhas(5);
						$this->Ln();
						$this->SetFont("Courier","B",10);
						$this->Cell(18,0.4,"ENDIVIDAMENTO NA COOPERATIVA EM: ".$dadosProposta["DTCALCUL"],0,1,"L",0,"");
						$this->SetFont("Courier","",10);

			 			$this->Ln();
						$this->Cell(5,0.4,"Saldo do Desconto:",0,0,"L",0,"");
						$this->Cell(13,0.4,number_format(str_replace(",",".",$dadosProposta["VLSLDDSC"]),2,",",".")."           ".formataNumericos("zz.zz9",$dadosProposta["QTDSCSLD"],".")." Cheques",0,1,"L",0,"");						
						$this->Cell(18,0.4,"Maior Cheque: ".number_format(str_replace(",",".",$dadosProposta["VLMAXDSC"]),2,",","."),0,1,"L",0,"");
						$this->Cell(18,0.4,"Valor Médio: ".number_format(str_replace(",",".",$dadosProposta["VLSLDDSC"]/$dadosProposta["QTDSCSLD"]),2,",","."),0,1,"L",0,"");

						$this->controlaLinhas(2);

						$this->Ln();

						$this->Cell(2,0.4,"Contrato",0,0,"R",0,"");
						$this->Cell(3,0.4,"Saldo Devedor",0,0,"R",0,"");
						$this->Cell(4.3,0.4,"Prestacoes",0,0,"R",0,"");
						$this->Cell(4.7,0.4,"Linha de Credito",0,0,"L",0,"");
						$this->Cell(4,0.4,"Finalidade",0,1,"L",0,"");
						
						
					}
					$this->controlaLinhas(1);
					$this->Cell(2,0.4,formataNumericos("z.zzz.zz9",$Emprestimos[$i]["NRCTREMP"],"."),0,0,"R",0,"");
					$this->Cell(3,0.4,number_format(str_replace(",",".",$Emprestimos[$i]["VLSDEVED"]),2,",","."),0,0,"R",0,"");
					$this->SetFont("Courier","",8);
					$this->Cell(4.3,0.4,substr($Emprestimos[$i]["DSPREAPG"],5,11). " " . number_format(str_replace(",",".",$Emprestimos[$i]["VLPREEMP"]),2,",","."),0,0,"R",0,"");
					$this->SetFont("Courier","",7);
					$this->Cell(4.7,0.4,$Emprestimos[$i]["DSLCREMP"],0,0,"L",0,"");
					$this->Cell(4,0.4,$Emprestimos[$i]["DSFINEMP"],0,1,"L",0,"");
					$this->SetFont("Courier","",10);
					if ($i == (count($Emprestimos) - 1)){
						$this->Cell(2,0.4,"",0,0,"R",0,"");
						$this->Cell(3,0.4,number_format(str_replace(",",".",$dadosProposta["VLSDEVED"]),2,",","."),"T",0,"R",0,"");
						$this->Cell(4.3,0.4,number_format(str_replace(",",".",$dadosProposta["VLPREEMP"]),2,",","."),"T",0,"R",0,"");
						$this->Cell(8.7,0.4,"",0,1,"L",0,"");
					}					
				}			
			}

			$this->controlaLinhas(3);

			$this->Ln();			

			$this->MultiCell(18,0.4,"AUTORIZO A CONSULTA DE MINHAS INFORMAÇÕES CADASTRAIS NOS SERVIÇOS DE PROTEÇÃO DE CRÉDITO (SPC, SERASA, ...) ALÉM DO CADASTRO DA CENTRAL DE RISCO DO BANCO CENTRAL DO BRASIL.",0,"J",0);			

			$this->controlaLinhas(5);
			$this->Ln();

			$this->SetFont("Courier","B",10);
			$this->Cell(18,0.4,"OBSERVAÇÕES",0,1,"L",0,"");
			$this->SetFont("Courier","",10);
			$this->MultiCell(18,0.4,$dadosProposta["DSOBSER1"],0,"J",0);
			$this->MultiCell(18,0.4,$dadosProposta["DSOBSER2"],0,"J",0);
			$this->MultiCell(18,0.4,$dadosProposta["DSOBSER3"],0,"J",0);
			$this->MultiCell(18,0.4,$dadosProposta["DSOBSER4"],0,"J",0);

			$this->controlaLinhas(2);

			$this->Ln();

			$this->Cell(18,0.4,"Consultado SPC em:   ___/___/______",0,1,"L",0,"");

			$this->controlaLinhas(2);
		
			$this->Ln();
			
			$this->Cell(18,0.4,"Central de risco em: ___/___/______  Situação: ______________  Visto: ______________",0,1,"L",0,"");			

			$this->controlaLinhas(3);

			$this->Ln();
			$this->Ln();
			
			$this->SetFont("Courier","B",10);
			$this->Cell(18,0.4,"A P R O V A Ç Ã O",0,1,"L",0,"");
			$this->SetFont("Courier","",10);
			
			$this->controlaLinhas(5);			

			$this->Ln();
			$this->Ln();	
			$this->Ln();	

			$this->Cell(8.5,0.4,"","B",0,"L",0,"");
			$this->Cell(1,0.4,"",0,0,"L",0,"");
			$this->Cell(8.5,0.4,"","B",1,"L",0,"");	
			$this->Cell(8.5,0.4,"Operador: ".$dadosProposta["NMOPERAD"],0,0,"L",0,"");
			$this->Cell(1,0.4,"",0,0,"L",0,"");
			$this->MultiCell(8.5,0.4,trim($dadosProposta["NMRESCO1"])."\n".trim($dadosProposta["NMRESCO2"]),0,"C",0);						

			$this->controlaLinhas(4);
			
			$this->Ln();
			$this->Ln();		
			
			$this->Cell(8.5,0.4,"","B",0,"L",0,"");
			$this->Cell(9.5,0.4,"",0,1,"L",0,"");			
			$this->Cell(8.5,0.4,$dadosProposta["NMPRIMTL"],0,0,"L",0,"");
			$this->Cell(1,0.4,"",0,0,"L",0,"");
			$this->Cell(8.5,0.4,$dadosProposta["NMCIDADE"].", ".$dadosProposta["DDMVTOLT"]." de ".$dadosProposta["DSMESREF"]." de ".$dadosProposta["AAMVTOLT"].".",0,0,"C",0,"");							
		
		}	
		function geraChequesBordero($dadosCabecalho,$dadosCheques,$dadosRestricoes,$dadosSacadNPG) {
			$this->nrLinhas = 12;
			$this->SetMargins(0.6,0.2);
			$this->AddPage();

			$this->SetFont("Courier","",8);
			$this->SetTextColor(0,0,0);
			$this->Cell(18,0.3,trim($dadosCabecalho["NMRESCO1"])." ".trim($dadosCabecalho["NMRESCO2"],". - "),0,1,"L",0,"");	

			$this->Ln();
			$this->SetFont("Courier","",8);
			$this->Cell(12,0.3,"BORDERÔ DE DESCONTO DE CHEQUES E TERMO DE CUSTÓDIA",0,0,"L",0,"");			
			$this->Cell(6,0.3,"PARA USO DA DIGITALIZAÇÃO",0,1,"L",0,"");

			$this->Ln();
			$this->SetFont("Courier","B",8);
			$this->Cell(12.2,0.3,"",0,0,"L",0,"");
			$this->Cell(2.7,0.4,"".formataNumericos('zzzz.zzz.9',$dadosCabecalho["NRDCONTA"],"."),0,0,"L",0,"");
			$this->Cell(1.8,0.4,"".formataNumericos('zzz.zzz.zzz',$dadosCabecalho["NRBORDER"],'.'),0,0,"L",0,"");
			$this->Cell(1,0.4," 87",0,1,"L",0,"");
			
			$this->Ln();
			$this->SetFont("Courier","",8);
			$this->Cell(4.5,0.4,"Conta/dv: ".formataNumericos("zzzz.zzz.9",$dadosCabecalho["NRDCONTA"],".")." - ".$dadosCabecalho["NMPRIMTL"]." PA: ".$dadosCabecalho["CDAGENCI"],0,1,"L",0,"");
			
			$this->Ln();
		
			$this->Cell(6,0.4,"Bordero: ".formataNumericos('zzz.zzz.zzz',$dadosCabecalho["NRBORDER"],'.'),0,0,"L",0,"");
			$this->Cell(6,0.4,"Contrato: ".formataNumericos('zzz.zzz.zzz',$dadosCabecalho["NRCTRLIM"],'.'),0,0,"L",0,"");
			$this->Cell(6,0.4,"Limite: ".number_format(str_replace(",",".",$dadosCabecalho["VLLIMITE"]),2,",","."),0,1,"L",0,"");
			
			$this->Ln();
			
			$this->Cell(18,0.4,"Taxa Aplicada: ".number_format(str_replace(",",".",$dadosCabecalho["TXDANUAL"]),6,",",".")." % aa       ".number_format(str_replace(",",".",$dadosCabecalho["TXMENSAL"]),6,",","."). " % am       ".number_format(str_replace(",",".",$dadosCabecalho["TXDIARIA"]),6,",",".")." % ad",0,1,"L",0,"");
			
			$this->Ln();

			$this->Cell(18,0.4,"CHEQUES ENTREGUES PARA DESCONTO E CUSTÓDIA:",0,1,"L",0,"");			

			$this->Ln();
			$this->SetFont("Courier","",7);

			$arrRestricaoCoordenador = array();

            for ($i = 0;$i < count($dadosCheques); $i++){
				if ($i == 0){
					$this->Cell(1.6,0.4,"Bom Para","B",0,"L",0,"");
					$this->Cell(0.6,0.4,"Cmp","B",0,"L",0,"");
					$this->Cell(0.6,0.4,"Bco","B",0,"L",0,"");
					$this->Cell(0.8,0.4,"Ag.","B",0,"R",0,"");
					$this->Cell(2,0.4,"Conta","B",0,"R",0,"");
					$this->Cell(1.2,0.4,"Cheque","B",0,"R",0,"");
					$this->Cell(2,0.4,"Valor","B",0,"R",0,"");
					$this->Cell(2,0.4,"Vlr Líquido","B",0,"R",0,"");
					$this->Cell(0.7,0.4,"Prz","B",0,"C",0,"");
					$this->Cell(3.6,0.4,"Emitente","B",0,"L",0,"");
					$this->Cell(2.9,0.4,"CPF/CNPJ","B",1,"L",0,"");
				}
				$vlrtotal += doubleval(str_replace(",",".",$dadosCheques[$i]["VLCHEQUE"]));
				$qttotal += 1;
				$vltotliq += doubleval(str_replace(",",".",$dadosCheques[$i]["VLLIQUID"]));				
				$this->controlaLinhas(1);
				$vlrmaior = $dadosCheques[$i]["VLCHEQUE"] > $vlrmaior ? $dadosCheques[$i]["VLCHEQUE"] : $vlrmaior;
				$this->Cell(1.6,0.4,$dadosCheques[$i]["DTLIBERA"],0,0,"L",0,"");
				$this->Cell(0.6,0.4,formataNumericos('999',$dadosCheques[$i]["CDCMPCHQ"],''),0,0,"L",0,"");
				$this->Cell(0.6,0.4,formataNumericos('999',$dadosCheques[$i]["CDBANCHQ"],''),0,0,"L",0,"");
				$this->Cell(0.8,0.4,formataNumericos('9999',$dadosCheques[$i]["CDAGECHQ"],''),0,0,"R",0,"");
				$this->Cell(2,0.4,formataNumericos('zzzzzzz.zzz.9',$dadosCheques[$i]["NRCTACHQ"],'.'),0,0,"R",0,"");
				$this->Cell(1.2,0.4,formataNumericos('zzz.zz9',$dadosCheques[$i]["NRCHEQUE"],'.'),0,0,"R",0,"");
				$this->Cell(2,0.4,number_format(str_replace(",",".",$dadosCheques[$i]["VLCHEQUE"]),2,",","."),0,0,"R",0,"");
				$this->Cell(2,0.4,number_format(str_replace(",",".",$dadosCheques[$i]["VLLIQUID"]),2,",","."),0,0,"R",0,"");
				$this->Cell(0.7,0.4,$dadosCheques[$i]["DTLIBBDC"] != "" ? diffData($dadosCheques[$i]["DTLIBERA"],$dadosCheques[$i]["DTLIBBDC"]) : diffData($dadosCheques[$i]["DTLIBERA"],$dadosCheques[$i]["DTMVTOLT"]),0,0,"C",0,"");
				$this->Cell(3.6,0.4,substr($dadosCheques[$i]["NMCHEQUE"],0,23),0,0,"L",0,"");
				$this->Cell(2.9,0.4,$dadosCheques[$i]["DSCPFCGC"],0,1,"L",0,"");
				
				for ($j = 0;$j < count($dadosRestricoes); $j++){
					if ($dadosRestricoes[$j]["NRCHEQUE"] == $dadosCheques[$i]["NRCHEQUE"]){
						$qtrestricoes += 1;
						$this->controlaLinhas(1);
						$this->SetFont("Courier","B",7);
						$this->MultiCell(18,0.4,"    --->    ".$dadosRestricoes[$j]["DSRESTRI"],0,"L",0);
						$this->SetFont("Courier","",7);
                        // Se foi liberado/aprovado pelo coordenador
                        if (strtoupper($dadosRestricoes[$j]["FLAPRCOO"]) ==  'YES' && ! in_array($dadosRestricoes[$j]["DSRESTRI"], $arrRestricaoCoordenador)) {
                            $arrRestricaoCoordenador[] = $dadosRestricoes[$j]["DSRESTRI"];
                        }
					}
				}
			}
			$this->SetFont("Courier","B",7);
			$this->Ln();
			for ($i = 0;$i < count($dadosRestricoes); $i++){
				if ($dadosRestricoes[$i]["NRCHEQUE"] == "888888"){
					$this->controlaLinhas(1);
					$this->MultiCell(18,0.4,"    --->    ".$dadosRestricoes[$i]["DSRESTRI"],0,"L",0);
                    // Se foi liberado/aprovado pelo coordenador
                    if (strtoupper($dadosRestricoes[$i]["FLAPRCOO"]) ==  'YES' && ! in_array($dadosRestricoes[$i]["DSRESTRI"], $arrRestricaoCoordenador)) {
                        $arrRestricaoCoordenador[] = $dadosRestricoes[$i]["DSRESTRI"];
                    }
				}
			}
			$this->controlaLinhas(3);
			$this->Ln();
			$this->Cell(6.8,0.4,"TOTAL: ".intval(count($dadosCheques))." CHEQUE(S) ".intval($qtrestricoes)." RESTRIÇÃO(ÕES)",0,0,"L",0,"");
			$this->Cell(2,0.4,number_format(str_replace(",",".",$vlrtotal),2,",","."),0,0,"R",0,"");
			$this->Cell(2,0.4,number_format(str_replace(",",".",$vltotliq),2,",","."),0,0,"R",0,"");
			$this->Cell(7.2,0.4," VALOR MÉDIO: " .number_format(doubleval($vlrtotal / $qttotal),2,",","."),0,1,"L",0,"");
			
			$this->Ln();
			
			$this->controlaLinhas(3);

			// Se possui liberacao/analise de coordenador
            if ($dadosCabecalho["DSOPECOO"] != "") {
                $this->SetFont("Courier","B",8);
                $this->Cell(7.8,0.4,"RESTRIÇÃO(ÕES) APROVADA(AS)",0,0,"L",0,"");

                $this->Ln();

                foreach ($arrRestricaoCoordenador as $arrValor) {
                    $this->SetFont("Courier","",7);
                    $this->controlaLinhas(1);
                    $this->MultiCell(18,0.4,$arrValor,0,"L",0);
                }
            }

			$this->Ln();
			$this->Ln();

			$this->SetFont("Courier","",10);
			$this->Cell(18,0.4,$dadosCabecalho["NMCIDADE"].", ".$dadosCabecalho["DDMVTOLT"]." de ".$dadosCabecalho["DSMESREF"]." de ".$dadosCabecalho["AAMVTOLT"],0,1,"L",0,"");

			$this->Ln();
			
			$this->controlaLinhas(6);
			
			$this->Ln();
			$this->Ln();
			$this->Ln();
			
			$this->Cell(8.5,0.4,"","B",0,"L",0,"");
			$this->Cell(1,0.4,"",0,0,"L",0,"");
			$this->Cell(8.5,0.4,"","B",1,"L",0,"");	
			$this->Cell(8.5,0.4,"Operador: ".$dadosCabecalho["NMOPERAD"],0,0,"L",0,"");
			$this->Cell(1,0.4,"",0,0,"L",0,"");
			$this->MultiCell(8.5,0.4,trim($dadosCabecalho["NMRESCO1"])."\n".trim($dadosCabecalho["NMRESCO2"]),0,"C",0);						

			$this->controlaLinhas(5);
			
			$this->Ln();
			$this->Ln();		
			$this->Ln();
			$this->Ln();
			
			$this->Cell(8.5,0.4,"","B",0,"L",0,"");
			$this->Cell(9.5,0.4,"",0,1,"L",0,"");			
			$this->Cell(8.5,0.4,$dadosCabecalho["NMPRIMTL"],0,1,"L",0,"");			
			
			$this->controlaLinhas(6);
			
			$this->Ln();
			$this->Ln();
			$this->Ln();
			$this->Ln();		

			$this->Cell(8.5,0.4,"","B",0,"L",0,"");
			$this->Cell(1,0.4,"",0,0,"L",0,"");			
			$this->Cell(8.5,0.4,"","B",1,"L",0,"");
			$this->Cell(8.5,0.4,"Testemunha",0,0,"L",0,"");			
			$this->Cell(1,0.4,"",0,0,"L",0,"");			
			$this->Cell(8.5,0.4,"Testemunha",0,1,"L",0,"");			
						
		}

	}
	
?>