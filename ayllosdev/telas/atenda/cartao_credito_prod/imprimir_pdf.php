<?php 

	/*************************************************************************  
   Fonte: imprimir_pdf.php                                               
   Autor: Guilherme                                                          
   Data : Maio/2008                   Última Alteração: 19/08/2015          
	                                                                            
   Objetivo  : Gerar PDF das impressoes de cartões de crédito              
	                                                                            	 
   Alterações: 14/05/2009 - Acerto na impressão de nota promissória (David)        

			   11/02/2011 - Aumento do campo nome (Gabriel).	
			   
			   07/06/2011 - Ajuste formato cidade e bairro (Gabriel)
			   
			   23/04/2012 - Retirada a funcao  geraCtrBBras (David Kruger).
			   
			   12/08/2013 - Alteração da sigla PAC para PA. (Carlos)
			   
			   19/08/2015 - Reformulacao cadastral (Gabriel-RKAM)
	*************************************************************************/ 
	
	// Classe para geração de arquivos PDF
	require_once("../../../class/fpdf/fpdf.php");
	
	// Classe para geração dos impressos do cartão de crédito em PDF
	class PDF extends FPDF {
	
		var $nrPaginas = 0; // Acumular número de páginas do documento
		
		// Método Construtor
		function PDF($orientation = "P",$unit = "cm",$format = "A4") {
			$this->FPDF($orientation,$unit,$format);
		}
		
		// Gerar Layout para impressos
		function geraImpresso($dadosImpressos,$idImpresso) {		
			if ($idImpresso == "1") {
				$this->geraPropAltLimCred($dadosImpressos["PROPOSTA"],$dadosImpressos["OCARTOES"],$dadosImpressos["AVALISTA"]);
			} elseif ($idImpresso == "2") {
				$this->geraBdnCeVis($dadosImpressos["BDNCEVIS"],$dadosImpressos["AVALISTA"]);
			} elseif ($idImpresso == "3") {
				$this->geraProposta($dadosImpressos["PROPOSTA"],$dadosImpressos["OCARTOES"]);
			} elseif ($idImpresso == "4") {
				$this->geraCancBloq($dadosImpressos["CANCBLOQ"]);
			} elseif ($idImpresso == "5") {
				$this->geraCtrCredi($dadosImpressos["CTRCREDI"],$dadosImpressos["AVALISTA"]);
			} elseif ($idImpresso == "6") {
				$this->geraSol2viaCart($dadosImpressos["2VIACART"]);
			} elseif ($idImpresso == "8"){
				$this->geraAltDtVenctoCrd($dadosImpressos["DTVCTCRD"]);
			}
		}
		
		function geraCabecalhoProposta($dadosProposta){
			$this->AddPage();

			$this->SetFont("Courier","B",10);
			$this->SetTextColor(0,0,0);
			
			$this->Cell(18,0.4,$dadosProposta["NMEXTCOP"],0,1,"L",0,"");			

			$this->Ln();
			
			$this->Cell(18,0.4,"PROPOSTA DE CARTÃO DE CRÉDITO ".$dadosProposta["DSADICIO"],0,1,"L",0,"");
			
			$this->Ln();
			
			$this->Cell(18,0.4,"Número da Proposta: ".formataNumericos("zzz.zzz.zz9",$dadosProposta["NRCTRCRD"],"."),0,1,"R",0,"");
		}

		function geraProposta($dadosProposta,$outrosCartoes) {
			$this->SetMargins(1.5,1.5);
			
			$this->geraCabecalhoProposta($dadosProposta);
			$this->SetFont("Courier","",10);
			$this->Cell(18,0.4,"DADOS DO ASSOCIADO",0,1,"L",0,"");
			
			$this->Ln();			
			
			$this->Cell(4.5,0.4,"Conta/dv: ".formataNumericos("zzzz.zzz-9",$dadosProposta["NRDCONTA"],".-"),0,0,"L",0,"");
			$this->Cell(1.25,0.4,"",0,0,"L",0,"");
			$this->Cell(4.5,0.4,"Matrícula: ".formataNumericos("zzz.zz9",$dadosProposta["NRMATRIC"],"."),0,0,"L",0,"");
			$this->Cell(1.25,0.4,"",0,0,"L",0,"");
			$this->Cell(6.5,0.4,"PA ".$dadosProposta["NMRESAGE"],0,1,"L",0,"");
			
			$this->Ln();
			
			$this->Cell(18,0.4,"Nome do(s) Titular(es): ".$dadosProposta["NMPRIMTL"],0,1,"L",0,"");
			

			$this->Cell(14,0.4,"CPF/CNPJ: ".$dadosProposta["NRCPFCGC"],0,0,"L",0,"");
			$this->Cell(4,0.4,"Admissão: ".$dadosProposta["DTADMISS"],0,1,"R",0,"");
			if (trim($dadosProposta["NMSEGNTL"]) <> "") {
				$this->Cell(18,0.4,"                        ".$dadosProposta["NMSEGNTL"],0,1,"L",0,"");	
			}
			
			$this->Ln();
			
			$this->Cell(9.5,0.4,"Empresa: ".$dadosProposta["NMRESEMP"],0,0,"L",0,"");
			$this->Cell(18,0.4,"Telefone/Ramal: ".$dadosProposta["NRDOFONE"],0,1,"L",0,"");		
			$this->Cell(9.5,0.4,"Tipo de Conta: ".$dadosProposta["DSTIPCTA"],0,0,"L",0,"");
			$this->Cell(8.5,0.4,"Situação da Conta: ".$dadosProposta["DSSITDCT"],0,1,"L",0,"");					
			
			$this->Ln();
			
			$this->Cell(18,0.4,"DADOS DO CARTÃO ".$dadosProposta["TPCARTAO"],0,1,"L",0,"");
			
			$this->Ln();
			
			$this->Cell(11,0.4,"Titular: ".$dadosProposta["NMTITCRD"],0,0,"L",0,"");
			$this->Cell(7,0.4,"CPF: ".formataNumericos('999.999.999-99',$dadosProposta["NRCPFTIT"],'.-'),0,1,"R",0,"");
			$this->Cell(18,0.4,"Parentesco: ".$dadosProposta["DSPARENT"],0,1,"L",0,"");
			
			$this->Ln();

			$this->Cell(18,0.4,"RECIPROCIDADE",0,1,"L",0,"");
			
			$this->Ln();
			
			$this->Cell(8.7,0.4,"Saldo Médio do Trimestre: ".number_format(str_replace(",",".",$dadosProposta["VLSMDTRI"]),2,",","."),0,0,"L",0,"");
			$this->Cell(0.15,0.4,"",0,0,"L",0,"");
			$this->Cell(5.25,0.4,"Capital: ".number_format(str_replace(",",".",$dadosProposta["VLCAPTAL"]),2,",","."),0,0,"L",0,"");
			$this->Cell(0.15,0.4,"",0,0,"L",0,"");
			$this->Cell(3.75,0.4,"Plano: ".number_format(str_replace(",",".",$dadosProposta["VLPREPLA"]),2,",","."),0,1,"L",0,"");	
			$this->Cell(18,0.4,"Aplicações: ".number_format(str_replace(",",".",$dadosProposta["VLAPLICA"]),2,",","."),0,1,"L",0,"");
			
			$this->Ln();			
			
			$this->Cell(18,0.4,"RENDA MENSAL",0,1,"L",0,"");
			
			$this->Ln();					
			
			$this->Cell(4.5,0.4,"Salário: ".number_format(str_replace(",",".",$dadosProposta["VLSALARI"]),2,",","."),0,0,"L",0,"");
			$this->Cell(0.25,0.4,"",0,0,"L",0,"");
			$this->Cell(7,0.4,"Salário do Cônjuge: ".number_format(str_replace(",",".",$dadosProposta["VLSALCON"]),2,",","."),0,0,"L",0,"");
			$this->Cell(0.25,0.4,"",0,0,"L",0,"");
			$this->Cell(6,0.4,"Outras Rendas: ".number_format(str_replace(",",".",$dadosProposta["VLOUTRAS"]),2,",","."),0,1,"L",0,"");				
			$this->Cell(12,0.4,"Limite de Crédito: ".number_format(str_replace(",",".",$dadosProposta["VLLIMCRE"]),2,",","."),0,0,"L",0,"");
			$this->Cell(6,0.4,"Aluguel: ".number_format(str_replace(",",".",$dadosProposta["VLALUGUE"]),2,",","."),0,1,"L",0,"");			
			$this->Cell(18,0.4,"Limite Débito: ".number_format(str_replace(",",".",$dadosProposta["VLLIMDEB"]),2,",","."),0,1,"L",0,"");			
			
			$this->Ln();				
			
			$this->Cell(5,0.4,"DÍVIDA:",0,0,"L",0,"");
			$this->Cell(13,0.4,"TOTAL OP.crédito: ".number_format(str_replace(",",".",$dadosProposta["VLUTILIZ"]),2,",","."),0,1,"L",0,"");
			
			$this->Ln();			
			
			$this->Cell(12,0.4,"Saldo Devedor de Empréstimos: ".number_format(str_replace(",",".",$dadosProposta["VLTOTEMP"]),2,",","."),0,0,"L",0,"");
			$this->Cell(6,0.4,"Prestações: ".number_format(str_replace(",",".",$dadosProposta["VLTOTPRE"]),2,",","."),0,1,"L",0,"");			
						
			for ($i = 0;$i < count($outrosCartoes); $i++){
				if ($i == 0){
					$this->Ln();
					
					$this->Cell(18,0.4,"OUTROS CARTÕES",0,1,"L",0,"");
			
					$this->Ln();
				}
				$this->Cell(5.5,0.4,$outrosCartoes[$i]["DSDNOMES"],0,0,"L",0,"");
				$this->Cell(8.0,0.4,$outrosCartoes[$i]["DSTIPCRD"],0,0,"L",0,"");
				$this->Cell(2.0,0.4,number_format(str_replace(",",".",$outrosCartoes[$i]["VLLIMITE"]),2,",","."),0,0,"R",0,"");
				$this->Cell(2.5,0.4,$outrosCartoes[$i]["DSSITUAC"],0,1,"L",0,"");
			}
			//Se for estourar o tamanho do contrato, preenche com '**' até o final da folha
			if (count($outrosCartoes) > 2){
				for ($i = 1; $i < (24 - count($outrosCartoes)); $i++){
					$this->Cell(18,0.4,str_pad("**", (86 / (24 - count($outrosCartoes)) * $i), " ", STR_PAD_LEFT),0,1,"L",0,"");

				}
				$this->geraCabecalhoProposta($dadosProposta);
				$this->SetFont("Courier","",10);
			}
			
			$this->Ln();
			
			$this->Cell(9,0.4,"Dia do débito em conta corrente: ".formataNumericos('99',$dadosProposta["DDDEBITO"],''),0,0,"L",0,"");
			$this->Cell(9,0.4,"Conta-mae: ".formataNumericos('9999.9999.9999.9999',$dadosProposta["NRCTAMAE"],'.'),0,1,"R",0,"");
			
			$this->Ln();
			
			$this->Cell(18,0.4,"Limite Proposto: ".formataNumericos('999',$dadosProposta["CDLIMCRD"],'')." - ".number_format(str_replace(",",".",$dadosProposta["VLLIMCRD"]),2,",","."),0,1,"L",0,"");

			$this->Ln();						
						
			$this->MultiCell(18,0.4,"AUTORIZO A CONSULTA DE MINHAS INFORMAÇÕES CADASTRAIS NOS SERVIÇOS DE PROTEÇÃO DE CRÉDITO (SPC, SERASA, ...) ALÉM DO CADASTRO DA CENTRAL DE RISCO DO BANCO CENTRAL DO BRASIL.",0,"J",0);			

			$this->Ln();
			$this->Ln();
			
			$this->Cell(18,0.4,"Consultado SPC em:   ___/___/______",0,1,"L",0,"");
			
			$this->Ln();
			
			$this->Cell(18,0.4,"Central de risco em: ___/___/______  Situação: ______________  Visto: ______________",0,1,"L",0,"");			

			$this->Ln();
			$this->Ln();
			
			$this->Cell(18,0.4,"APROVAÇÃO",0,1,"L",0,"");
			
			$this->Ln();
			$this->Ln();	
			$this->Ln();	

			$this->Cell(8.5,0.4,"","B",0,"L",0,"");
			$this->Cell(1,0.4,"",0,0,"L",0,"");
			$this->Cell(8.5,0.4,"","B",1,"L",0,"");	
			$this->Cell(8.5,0.4,"Operador: ".$dadosProposta["NMOPERAD"],0,0,"L",0,"");
			$this->Cell(1,0.4,"",0,0,"L",0,"");
			$this->MultiCell(8.5,0.4,trim($dadosProposta["NMRECOP1"])."\n".trim($dadosProposta["NMRECOP2"]),0,"C",0);						
			
			$this->Ln();
			$this->Ln();		
			
			$this->Cell(8.5,0.4,"","B",0,"L",0,"");
			$this->Cell(9.5,0.4,"",0,1,"L",0,"");			
			$this->Cell(8.5,0.4,$dadosProposta["NMPRIMTL"],0,0,"L",0,"");
			$this->Cell(1,0.4,"",0,0,"L",0,"");
			$this->Cell(8.5,0.4,$dadosProposta["NMCIDADE"].", ".trim($dadosProposta["DSEMSPRP"]).".",0,0,"C",0,"");							
		
		}
		
		function geraPropAltLimCred($dadosProposta,$outrosCartoes,$dadosAvalistas) {
			$this->SetMargins(1.5,1.5);
			
			$this->AddPage();

			$this->SetFont("Courier","B",10);
			$this->SetTextColor(0,0,0);
			
			$this->Cell(18,0.4,$dadosProposta["NMEXTCOP"],0,1,"L",0,"");			

			$this->Ln();
			
			$this->Cell(18,0.4,"PROP.ALTERAÇÃO DE LIMITE DE CARTÃO DE CRÉDITO ".$dadosProposta["DSADICIO"],0,1,"L",0,"");
			
			$this->Ln();
			
			$this->Cell(18,0.4,"Número da Proposta: ".formataNumericos("zzz.zzz.zz9",$dadosProposta["NRCTRCRD"],"."),0,1,"R",0,"");
			
			$this->SetFont("Courier","",10);
			$this->Cell(18,0.4,"DADOS DO ASSOCIADO",0,1,"L",0,"");
			
			$this->Ln();			
			
			$this->Cell(4.5,0.4,"Conta/dv: ".formataNumericos("zzzz.zzz-9",$dadosProposta["NRDCONTA"],".-"),0,0,"L",0,"");
			$this->Cell(1.25,0.4,"",0,0,"L",0,"");
			$this->Cell(4.5,0.4,"Matrícula: ".formataNumericos("zzz.zz9",$dadosProposta["NRMATRIC"],"."),0,0,"L",0,"");
			$this->Cell(1.25,0.4,"",0,0,"L",0,"");
			$this->Cell(6.5,0.4,"PA ".$dadosProposta["NMRESAGE"],0,1,"L",0,"");
			
			$this->Ln();
			
			$this->Cell(18,0.4,"Nome do(s) Titular(es): ".$dadosProposta["NMPRIMTL"],0,1,"L",0,"");
			
			$this->Cell(18,0.4,"Admissão: ".$dadosProposta["DTADMISS"],0,1,"R",0,"");
			if (trim($dadosProposta["NMSEGNTL"]) <> "") {
				$this->Cell(18,0.4,"                        ".$dadosProposta["NMSEGNTL"],0,1,"L",0,"");	
			}
			
			$this->Ln();
			
			$this->Cell(9.5,0.4,"Empresa: ".$dadosProposta["NMRESEMP"],0,0,"L",0,"");
			$this->Cell(18,0.4,"Telefone/Ramal: ".$dadosProposta["NRDOFONE"],0,1,"L",0,"");		
			$this->Cell(9.5,0.4,"Tipo de Conta: ".$dadosProposta["DSTIPCTA"],0,0,"L",0,"");
			$this->Cell(8.5,0.4,"Situação da Conta: ".$dadosProposta["DSSITDCT"],0,1,"L",0,"");					
			
			$this->Ln();
			
			$this->Cell(18,0.4,"DADOS DO CARTÃO ".$dadosProposta["TPCARTAO"],0,1,"L",0,"");
			
			$this->Ln();
			
			$this->Cell(11,0.4,"Titular: ".$dadosProposta["NMTITCRD"],0,0,"L",0,"");
			$this->Cell(7,0.4,"CPF: ".formataNumericos('999.999.999-99',$dadosProposta["NRCPFTIT"],'.-'),0,1,"R",0,"");
			$this->Cell(18,0.4,"Parentesco: ".$dadosProposta["DSPARENT"],0,1,"L",0,"");
			
			$this->Ln();

			$this->Cell(18,0.4,"RECIPROCIDADE",0,1,"L",0,"");
			
			$this->Ln();
			
			$this->Cell(8.7,0.4,"Saldo Médio do Trimestre: ".number_format(str_replace(",",".",$dadosProposta["VLSMDTRI"]),2,",","."),0,0,"L",0,"");
			$this->Cell(0.15,0.4,"",0,0,"L",0,"");
			$this->Cell(5.25,0.4,"Capital: ".number_format(str_replace(",",".",$dadosProposta["VLCAPTAL"]),2,",","."),0,0,"L",0,"");
			$this->Cell(0.15,0.4,"",0,0,"L",0,"");
			$this->Cell(3.75,0.4,"Plano: ".number_format(str_replace(",",".",$dadosProposta["VLPREPLA"]),2,",","."),0,1,"L",0,"");	
			$this->Cell(18,0.4,"Aplicações: ".number_format(str_replace(",",".",$dadosProposta["VLAPLICA"]),2,",","."),0,1,"L",0,"");
			
			$this->Ln();			
			
			$this->Cell(18,0.4,"RENDA MENSAL",0,1,"L",0,"");
			
			$this->Ln();					
			
			$this->Cell(4.5,0.4,"Salário: ".number_format(str_replace(",",".",$dadosProposta["VLSALARI"]),2,",","."),0,0,"L",0,"");
			$this->Cell(0.25,0.4,"",0,0,"L",0,"");
			$this->Cell(7,0.4,"Salário do Cônjuge: ".number_format(str_replace(",",".",$dadosProposta["VLSALCON"]),2,",","."),0,0,"L",0,"");
			$this->Cell(0.25,0.4,"",0,0,"L",0,"");
			$this->Cell(6,0.4,"Outras Rendas: ".number_format(str_replace(",",".",$dadosProposta["VLOUTRAS"]),2,",","."),0,1,"L",0,"");				
			$this->Cell(12,0.4,"Limite de Crédito: ".number_format(str_replace(",",".",$dadosProposta["VLLIMCRE"]),2,",","."),0,0,"L",0,"");
			$this->Cell(6,0.4,"Aluguel: ".number_format(str_replace(",",".",$dadosProposta["VLALUGUE"]),2,",","."),0,1,"L",0,"");			
			
			$this->Ln();				
			
			$this->Cell(18,0.4,"DÍVIDA:",0,1,"L",0,"");
			
			$this->Ln();			
			
			$this->Cell(12,0.4,"Saldo Devedor de Empréstimos: ".number_format(str_replace(",",".",$dadosProposta["VLTOTEMP"]),2,",","."),0,0,"L",0,"");
			$this->Cell(6,0.4,"Prestações: ".number_format(str_replace(",",".",$dadosProposta["VLTOTPRE"]),2,",","."),0,1,"L",0,"");			
						
			for ($i = 0;$i < count($outrosCartoes); $i++){
				if ($i == 0){
					$this->Ln();
					
					$this->Cell(18,0.4,"OUTROS CARTÕES",0,1,"L",0,"");
			
					$this->Ln();
				}
				$this->Cell(5.5,0.4,$outrosCartoes[$i]["DSDNOMES"],0,0,"L",0,"");
				$this->Cell(8.0,0.4,$outrosCartoes[$i]["DSTIPCRD"],0,0,"L",0,"");
				$this->Cell(2.0,0.4,number_format(str_replace(",",".",$outrosCartoes[$i]["VLLIMITE"]),2,",","."),0,0,"R",0,"");
				$this->Cell(2.5,0.4,$outrosCartoes[$i]["DSSITUAC"],0,1,"L",0,"");
			}
			
			$this->Ln();
			
			$this->Cell(9,0.4,"Dia do débito em conta corrente: ".formataNumericos('99',$dadosProposta["DDDEBITO"],''),0,0,"L",0,"");
			$this->Cell(9,0.4,"Conta-mae: ".formataNumericos('9999.9999.9999.9999',$dadosProposta["NRCTAMAE"],'.'),0,1,"R",0,"");
			
			$this->Ln();
			
			$this->Cell(18,0.4,"Limite Proposto: ".formataNumericos('999',$dadosProposta["CDLIMCRD"],'')." - ".number_format(str_replace(",",".",$dadosProposta["VLLIMCRD"]),2,",","."),0,1,"L",0,"");

			$this->Ln();						
						
			$this->Cell(18,0.4,"APROVAÇÃO",0,1,"L",0,"");
			
			$this->Ln();
			$this->Ln();	
			$this->Ln();	

			$this->Cell(8.5,0.4,"","B",0,"L",0,"");
			$this->Cell(1,0.4,"",0,0,"L",0,"");
			$this->Cell(8.5,0.4,"","B",1,"L",0,"");	
			$this->Cell(8.5,0.4,"Operador: ".$dadosProposta["NMOPERAD"],0,0,"L",0,"");
			$this->Cell(1,0.4,"",0,0,"L",0,"");
			$this->MultiCell(8.5,0.4,trim($dadosProposta["NMRECOP1"])."\n".trim($dadosProposta["NMRECOP2"]),0,"C",0);						
			
			$this->Ln();
			$this->Ln();		
			
			$this->Cell(8.5,0.4,"","B",0,"L",0,"");
			$this->Cell(9.5,0.4,"",0,1,"L",0,"");			
			$this->Cell(8.5,0.4,$dadosProposta["NMPRIMTL"],0,0,"L",0,"");
			$this->Cell(1,0.4,"",0,0,"L",0,"");
			$this->Cell(8.5,0.4,$dadosProposta["NMCIDADE"].", ".trim($dadosProposta["DSEMPRP2"]).".",0,0,"C",0,"");							

			$this->AddPage();

			$this->SetFont("Courier","B",13);
			$this->SetTextColor(0,0,0);
			
			$this->Cell(18,0.4,$dadosProposta["NMEXTCOP"],0,1,"L",0,"");
			$this->Cell(18,0.4,$dadosProposta["DSLINHA1"],0,1,"L",0,"");
			$this->Cell(18,0.4,$dadosProposta["DSLINHA2"],0,1,"L",0,"");
			$this->Cell(18,0.4,$dadosProposta["DSLINHA3"],0,1,"L",0,"");
			
			$this->Ln();
			$this->Ln();			
			$this->Ln();
			$this->Ln();
			
			$this->Cell(18,0.4,$dadosProposta["NMCIDADE"].", ".trim($dadosProposta["DSEMPRP2"]).".",0,1,"L",0,"");

			$this->Ln();
			$this->Ln();
			$this->Ln();
			$this->Ln();

			$this->Cell(18,0.4,"A ".$dadosProposta["DSDESTIN"],0,1,"L",0,"");
			$this->Cell(18,0.4,"A/C ".$dadosProposta["DSCONTAT"],0,1,"L",0,"");
			
			$this->Ln();
			$this->Ln();
			$this->Ln();
			$this->Ln();
			
			$this->Cell(18,0.4,"SOLICITAMOS A ALTERAÇÃO NO LIMITE DE CRÉDITO DO CARTÃO ABAIXO:",0,1,"L",0,"");
			
			$this->Ln();
			$this->Ln();
			$this->Ln();
			$this->Ln();			
			
			$this->Cell(5,0.4,"NÚMERO DO CARTÃO:",0,0,"R",0,"");
			$this->Cell(13,0.4,formataNumericos('9999.9999.9999.9999',$dadosProposta["NRCRCARD"],'.'),0,1,"L",0,"");

			$this->Ln();			

			$this->Cell(5,0.4,"NOME:",0,0,"R",0,"");
			$this->Cell(13,0.4,$dadosProposta["NMTITCRD"],0,1,"L",0,"");
			
			$this->Ln();			
			
			$this->Cell(5,0.4,"NOVO LIMITE:",0,0,"R",0,"");
			$this->Cell(13,0.4,number_format(str_replace(",",".",$dadosProposta["VLLIMCRD"]),2,",","."),0,1,"L",0,"");
			
			$this->Ln();
			$this->Ln();
			$this->Ln();
			$this->Ln();			
			
			$this->Cell(18,0.4,"ATENCIOSAMENTE",0,1,"L",0,"");
			
			$this->Ln();			
			$this->Ln();			
			$this->Ln();			
			$this->Ln();			

			$this->Cell(18,0.4,"____________________________________________",0,1,"C",0,"");
			$this->Cell(18,0.4,trim($dadosProposta["NMRECOP1"]),0,1,"C",0,"");
			$this->Cell(18,0.4,trim($dadosProposta["NMRECOP2"]),0,1,"C",0,"");
			
			/***********************NOTA PROMISSORIA***************************/
			$this->AddPage();

			$this->SetFont("Courier","B",10);
			
			$this->Cell(9,0.4,"NOTA PROMISSÓRIA VINCULADA AO",0,0,"L",0,"");
			$this->SetFont("Courier","",10);
			$this->Cell(9,0.4,"Vencimento: ".$dadosProposta["DSEMPRP2"],0,1,"R",0,"");
			$this->SetFont("Courier","B",10);
			$this->Cell(18,0.4,"CONTRATO DE CARTÃO DE CRÉDITO",0,1,"L",0,"");
			$this->SetFont("Courier","",10);
			
			$this->Ln();
			
			$this->Cell(1.5,0.4,"NÚMERO ",0,0,"L",0,"");
			$this->SetFont("Courier","",15);
			$this->Cell(7,0.4,$dadosProposta["DSCTRCRD"],0,0,"R",0,"");
			$this->SetFont("Courier","",10);
			$this->Cell(1,0.4,"",0,0,"L",0,"");
			$this->Cell(1.5,0.4,$dadosProposta["DSDMOEDA"],0,0,"L",0,"");
			$this->SetFont("Courier","",15);
			$this->Cell(7,0.4,number_format(str_replace(",",".",$dadosProposta["VLLIMITE"]),2,",","."),0,1,"R",0,"");
			
			$this->Ln();
			
			$this->SetFont("Courier","",10);
			
			$this->Cell(18,0.4,"Ao(s) ".$dadosProposta["DSDTMVT1"],0,1,"L",0,"");
			$this->Cell(8.25,0.4,$dadosProposta["DSDTMVT2"]." pagarei por está única via de",0,0,"L",0,"");
			$this->SetFont("Courier","",15);
			$this->Cell(9.75,0.4,"N O T A  P R O M I S S Ó R I A",0,1,"L",0,"");
			$this->SetFont("Courier","",10);
			$this->MultiCell(18,0.4,"à ".$dadosProposta["NMRESCOP"]." - ".$dadosProposta["NMEXTCOP"]." ".$dadosProposta["NRDOCNPJ"]." ou a sua ordem a quantia de ".str_replace("*","",$dadosProposta["DSVLNPR1"]).str_replace("*","",$dadosProposta["DSVLNPR2"])." em moeda corrente deste país.",0,"L",0);
			
			$this->Ln();
			
			$this->Cell(9,0.4,"Pagável em ".$dadosProposta["NMCIDPAC"],0,0,"L",0,"");
			$this->Cell(9,0.4,$dadosProposta["NMCIDPAC"].",".$dadosProposta["DSEMPRP2"],0,1,"R",0,"");
			
			$this->Ln();
			
			$this->Cell(18,0.4,$dadosProposta["NMPRIMTL"],0,1,"L",0,"");
			$this->Cell(8.75,0.4,$dadosProposta["DSCPFCGC"],0,0,"L",0,"");
			$this->Cell(0.5,0.4,"",0,0,"L",0,"");
			$this->Cell(8.75,0.4,"________________________________________",0,1,"L",0,"");
			$this->Cell(8.75,0.4,"Conta/dv: ".formataNumericos("zzzz.zzz-9",$dadosProposta["NRDCONTA"],".-"),0,0,"L",0,"");
			$this->Cell(0.5,0.4,"",0,0,"L",0,"");
			$this->Cell(8.75,0.4,"ASSINATURA",0,1,"L",0,"");
			$this->Ln();
			$this->Cell(18,0.4,"Endereço:",0,1,"L",0,"");
			$this->Cell(18,0.4,$dadosProposta["ENDEASS1"],0,1,"L",0,"");
			$this->Cell(18,0.4,$dadosProposta["ENDEASS2"],0,1,"L",0,"");
			
			$this->Ln();
			
			for ($i = 0; $i < count($dadosAvalistas); $i++) {
				if ($i == 0) {
					$this->Cell(8.75,0.4,"Avalistas:",0,0,"L",0,"");
					$this->Cell(0.5,0.4,"",0,0,"L",0,"");
					$this->Cell(8.75,0.4,"Cônjuge:",0,1,"L",0,"");					
				}
							
				$this->Ln();
				$this->Ln();
							
				$this->Cell(8.75,0.4,"________________________________________",0,0,"L",0,"");
				$this->Cell(0.5,0.4,"",0,0,"L",0,"");
				$this->Cell(8.75,0.4,"________________________________________",0,1,"L",0,"");								
				$this->Cell(8.75,0.4,$dadosAvalistas[$i]["NMDAVALI"],0,0,"L",0,"");
				$this->Cell(0.5,0.4,"",0,0,"L",0,"");
				$this->Cell(8.75,0.4,$dadosAvalistas[$i]["NMCONJUG"],0,1,"L",0,"");		
				$this->Cell(8.75,0.4,$dadosAvalistas[$i]["CPFAVALI"],0,0,"L",0,"");
				$this->Cell(0.5,0.4,"",0,0,"L",0,"");
				$this->Cell(8.75,0.4,$dadosAvalistas[$i]["NRCPFCJG"],0,1,"L",0,"");				
				$this->Cell(18,0.4,$dadosAvalistas[$i]["DSENDAV1"],0,1,"L",0,"");
				$this->Cell(18,0.4,$dadosAvalistas[$i]["DSENDAV2"],0,1,"L",0,"");										
			}								
			/************************************************************************/
		}

		function geraCtrCredi($dadosCtrCredi,$dadosAvalistas) {
			$this->SetMargins(0.5,0.8);
			
			$this->AddPage();

			$this->SetFont("Courier","B",11);
			$this->SetTextColor(0,0,0);
			
			$this->Cell(18,0.4,"     ".$dadosCtrCredi["NMEXTCOP"],0,1,"L",0,"");			

			$this->Ln();
			
			$this->Cell(18,0.4,"     CONTRATO PARA UTILIZAÇÃO DO CARTÃO DE CRÉDITO CREDICARD ".$dadosCtrCredi["DSSUBSTI"],0,1,"L",0,"");
			
			$this->Ln();
			$this->Ln();
			
			$this->SetFont("Courier","",8);
			$this->Cell(18,0.4,"1. CONTRATANTES",0,1,"L",0,"");

			$this->Ln();
			$this->SetFont("Courier","B",10);
			$this->Cell(13.5,0.4,"   ".$dadosCtrCredi["NMPRIMTL"],0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(3.5,0.4,", CPF ".formataNumericos('999.999.999-10',$dadosCtrCredi["NRCPFCGC"],'.-').", conta-corrente",0,1,"L",0,"");
			$this->SetFont("Courier","B",10);
			$this->Cell(3,0.4,"   ".formataNumericos('z.zzz.zz9-9',$dadosCtrCredi["NRDCONTA"],'.-'),0,0,"R",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(15,0.4," no PA.: ".formataNumericos('zz9',$dadosCtrCredi["CDAGENCI"],'').", abaixo assinado e doravante denominado ASSOCIADO.",0,1,"L",0,"");

			$this->Ln();			
			$this->SetFont("Courier","B",10);
			$this->Cell(14.3,0.4,"   ".$dadosCtrCredi["NMEXTCOP"],0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(3.7,0.4,"     , ".$dadosCtrCredi["NRDOCNPJ"].",",0,1,"L",0,"");
			$this->Cell(5,0.4,"    doravante denominada ".$dadosCtrCredi["NMRESCOP"].".",0,1,"L",0,"");
			
			$this->Ln();
			
			$this->Cell(18,0.4,"2. OBJETO",0,1,"L",0,"");
			
			$this->Ln();

			$this->Cell(18,0.4,"   Este contrato  regula as condições para  intermediação de prestação de serviços de  administração de cartões de",0,1,"L",0,"");
			$this->Cell(7.1,0.4,"   crédito e seus desdobramentos, entre a",0,0,"L",0,"");
			$this->Cell(2.5,0.4,$dadosCtrCredi["NMRESCOP"],0,0,"L",0,"");
			$this->Cell(8.4,0.4,",  seu  ASSOCIADO  aderente e a empresa  CREDICARD  S.A.,",0,1,"L",0,"");
			$this->Cell(18,0.4,"   ADMINISTRADORA DE CARTÕES DE CRÉDITO, CNPJ 34.098.442/000134, doravante denominada CREDICARD.",0,1,"L",0,"");

			$this->Ln();
			$this->Ln();
			$this->Ln();
			
			$this->Cell(18,0.4,"3. CLÁUSULAS",0,1,"L",0,"");
			
			$this->Ln();
			$this->Ln();
			
			$this->Cell(1.6,0.4,"   3.1. A ",0,0,"L",0,"");
			$this->Cell(2.5,0.4,$dadosCtrCredi["NMRESCOP"],0,0,"L",0,"");
			$this->Cell(13.9,0.4,", na condição  de intermediária para o fornecimento do cartão de crédito do tipo Empresarial",0,1,"L",0,"");
			$this->Cell(18,0.4,"        a  seus  associados, subscreveu  o contrato  de  adesão  ao  sistema  de  cartão de crédito  oferecido  pela",0,1,"L",0,"");
			$this->Cell(18,0.4,"        CREDICARD, de acordo com o  contrato  registrado  no 4.  Registro de  Títulos  e Documentos de São Paulo sob",0,1,"L",0,"");
			$this->Cell(18,0.4,"        n.  2.048.515  e no 3. Ofício  de  Registro  de  Títulos  e  Documentos  do  Rio de Janeiro  sob n. 311.099,",0,1,"L",0,"");
			$this->Cell(18,0.4,"        funcionando naquele contrato como EMPRESA.",0,1,"L",0,"");

			$this->Ln();
			$this->Ln();
			
			$this->Cell(18,0.4,"   3.2. O ASSOCIADO, na  condição  de  usuário  do  cartão de crédito, pelo presente instrumento, declara conhecer o",0,1,"L",0,"");
			$this->Cell(18,0.4,"        contrato  referido  na  cláusula  anterior, aderindo  e  aceitando  suas  condições, as  quais  se  sujeita,",0,1,"L",0,"");
			$this->Cell(18,0.4,"        funcionando naquele contrato como TITULAR.",0,1,"L",0,"");
			
			$this->Ln();
			$this->Ln();
			
			$this->Cell(1.7,0.4,"   3.3. A ",0,0,"L",0,"");
			$this->Cell(2.5,0.4,$dadosCtrCredi["NMRESCOP"],0,0,"L",0,"");
			$this->Cell(13.8,0.4,", ficará  sub-rogada  em  todos  os  direitos da  CREDICARD, perante o ASSOCIADO usuário do",0,1,"L",0,"");
			$this->Cell(18,0.4,"        cartão, sempre que liquidar as faturas  mensais, e até a liquidação total do débito pelo associado perante a",0,1,"L",0,"");
			$this->Cell(18,0.4,"        ".$dadosCtrCredi["NMRESCOP"].".",0,1,"L",0,"");
			
			$this->Ln();
			$this->Ln();
			
			$this->Cell(18,0.4,"   3.4. O relacionamento do ASSOCIADO, para  comunicação  de perda, roubo, furto, fraude ou falsificação de cartão e",0,1,"L",0,"");
			$this->Cell(11.7,0.4,"        outras, será direto com a CREDICARD, podendo eventualmente a",0,0,"L",0,"");			
			$this->Cell(2.5,0.4,$dadosCtrCredi["NMRESCOP"],0,0,"L",0,"");
			$this->Cell(3.3,0.4,"servir de intermediária.",0,1,"L",0,"");
			
			$this->Ln();
			$this->Ln();

			$this->Cell(18,0.4,"   3.5. A remuneração  pelos  serviços  disponibilizados  será de inteira  responsabilidade do ASSOCIADO,  cabendo a",0,1,"L",0,"");
			$this->Cell(3.7,0.4,"        ".$dadosCtrCredi["NMRESCOP"],0,0,"L",0,"");
			$this->Cell(15.3,0.4,"debitá-los na conta corrente do ASSOCIADO.",0,1,"L",0,"");
			
			$this->Ln();
			$this->Ln();
			
			$this->Cell(2.3,0.4,"        3.5.1. A ",0,0,"L",0,"");
			$this->Cell(2.5,0.4,"   ".$dadosCtrCredi["NMRESCOP"],0,0,"L",0,"");
			$this->Cell(13.2,0.4," poderá  repassar, além  da  remuneração  dos  serviços  cobrados  pela  CREDICARD,  uma",0,1,"L",0,"");
			$this->Cell(18,0.4,"               remuneração pelos seus serviços de intermediação, que também serão debitados na conta do ASSOCIADO.",0,1,"L",0,"");
			
			$this->Ln();
			$this->Ln();
			
			$this->Cell(18,0.4,"   3.6. O valor da fatura  mensal  oriundo  da  utilização do cartão, e demais  despesas ou encargos, será  debitado",0,1,"L",0,"");
			$this->Cell(8.5,0.4,"         mensalmente, na data do vencimento, pela ",0,0,"L",0,"");
			$this->Cell(2.5,0.4,$dadosCtrCredi["NMRESCOP"],0,0,"L",0,"");
			$this->Cell(7.5,0.4," associado, ficando  desde  logo,  autorizada  para",0,1,"L",0,"");
			$this->Cell(18,0.4,"         tal,  independentemente de qualquer  notificação ou  aviso prévio, obrigando-se o ASSOCIADO, a manter saldo",0,1,"L",0,"");
			$this->Cell(18,0.4,"         suficiente.",0,1,"L",0,"");

			$this->Ln();
			$this->Ln();
			
			$this->Cell(2.5,0.4,"   3.7. Cabe a",0,0,"L",0,"");
			$this->Cell(2.5,0.4,$dadosCtrCredi["NMRESCOP"],0,0,"L",0,"");
			$this->Cell(13,0.4,", a seu  critério, estabelecer o limite de crédito do ASSOCIADO, podendo  ajustá-lo ou",0,1,"L",0,"");
			$this->Cell(18,0.4,"        até cancelá-lo  integralmente, de acordo  com suas  condições gerais  perante a CREDICARD ou as condições de",0,1,"L",0,"");
			$this->Cell(18,0.4,"        crédito do ASSOCIADO  perante  a Cooperativa, podendo  ainda, reduzí-lo, se o saldo devedor da fatura mensal",0,1,"L",0,"");
			$this->Cell(18,0.4,"        não for liquidado pelo ASSOCIADO.",0,1,"L",0,"");
			
			$this->Ln();
			$this->Ln();
			
			$this->Cell(1.7,0.4,"   3.8. A",0,0,"L",0,"");
			$this->Cell(2.5,0.4,$dadosCtrCredi["NMRESCOP"],0,0,"L",0,"");
			$this->Cell(13.8,0.4,", remetera ao ASSOCIADO,  juntamente  com o aviso  de  débito  em  conta  corrente, toda  a",0,1,"L",0,"");
			$this->Cell(18,0.4,"        documentação, extratos e demonstrativos remetidos pela CREDICARD.",0,1,"L",0,"");

			$this->Ln();
			$this->Ln();
			
			$this->SetFont("Courier","B",11);
			
			$this->Cell(18,0.4,"     ".$dadosCtrCredi["NMEXTCOP"],0,1,"L",0,"");			

			$this->Ln();
			
			$this->Cell(18,0.4,"     CONTRATO PARA UTILIZAÇÃO DO CARTÃO DE CRÉDITO CREDICARD ".$dadosCtrCredi["DSSUBSTI"],0,1,"L",0,"");			
			
			$this->Ln();
			$this->Ln();

			$this->SetFont("Courier","",9);
			
			$this->Cell(12.75,0.4,"   3.9. O ASSOCIADO declara receber o cartão de crédito de número",0,0,"L",0,"");
			$this->SetFont("Courier","B",10);
			$this->Cell(4,0.4,formataNumericos('9999.9999.9999.9999',$dadosCtrCredi["NRCRCARD"],'.'),0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(4,0.4,", conforme",0,1,"L",0,"");
			$this->Cell(18,0.4,"         proposta ".formataNumericos('999.999',$dadosCtrCredi["NRCTRCRD"],'.').", em nome do titular do cartão ".$dadosCtrCredi["NMTITCRD"],0,1,"L",0,"");
			
			$this->Ln();
			$this->Ln();
			$this->Ln();
			
			$this->Cell(18,0.4,"4. DISPOSIÇÕES GERAIS",0,1,"L",0,"");
			
			$this->Ln();
			
			$this->Cell(18,0.4,"   4.1 O foro competente do presente contrato e o de ".$dadosCtrCredi["NMCIDADE"],0,1,"L",0,"");
			$this->Cell(18,0.4,"       - ".$dadosCtrCredi["CDUFDCOP"]." podendo entretanto a ".$dadosCtrCredi["NMRESCOP"].", optar pelo foro estabelecido na",0,1,"L",0,"");
			$this->Cell(18,0.4,"       cláusula décima oitava do contrato com a CREDICARD.",0,1,"L",0,"");
			
			$this->Ln();
			$this->Ln();
			$this->Ln();
			
			$this->Cell(18,0.4,$dadosCtrCredi["NMCIDADE"]." ".$dadosCtrCredi["CDUFDCOP"].", ".$dadosCtrCredi["DSEMSCTR"],0,1,"L",0,"");
			
			$this->Ln();
			$this->Ln();
			$this->Ln();
			
			$this->Cell(18,0.4,"_______________________________  _______________________________  ___________________________________________",0,1,"L",0,"");
			$this->Cell(5,0.4,"Operador: ".$dadosCtrCredi["NMOPERAD"],0,0,"L",0,"");
			$this->Cell(0.5,0.4,"",0,0,"L",0,"");
			$this->Cell(5.6,0.4,trim($dadosCtrCredi["NMRECOP1"]),0,0,"C",0,"");
			$this->Cell(0.15,0.4,"",0,0,"L",0,"");
			$this->Cell(7,0.4,$dadosCtrCredi["NMPRIMTL"],0,1,"L",0,"");
			$this->Cell(5.5,0.4,"",0,0,"L",0,"");
			$this->Cell(5.6,0.4,trim($dadosCtrCredi["NMRECOP2"]),0,0,"C",0,"");
			$this->Cell(7.6,0.4,"",0,1,"L",0,"");
			
			$this->Ln();
			$this->Ln();
			
			$this->Cell(4,0.4,"Testemunhas: ",0,0,"R",0,"");
			$this->Cell(14,0.4,"_________________________________________  _________________________________________",0,1,"L",0,"");
			
			$this->Ln();
			
			$this->Cell(11.25,0.4,"Nome: ___________________________________ ",0,0,"R",0,"");
			$this->Cell(8,0.4,"Nome: ___________________________________",0,1,"L",0,"");
			
			$this->Ln();
			
			$this->Cell(11.25,0.4,"Conta/dv: _______________________________ ",0,0,"R",0,"");
			$this->Cell(8,0.4,"Conta/dv: _______________________________",0,1,"L",0,"");
			
			/***********************NOTA PROMISSORIA***************************/
			$this->AddPage();

			$this->SetFont("Courier","B",10);
			
			$this->Cell(9,0.4,"NOTA PROMISSÓRIA VINCULADA AO",0,0,"L",0,"");
			$this->SetFont("Courier","",10);
			$this->Cell(9,0.4,"Vencimento: ".$dadosCtrCredi["DSECTRNP"],0,1,"R",0,"");
			$this->SetFont("Courier","B",10);
			$this->Cell(18,0.4,"CONTRATO DE CARTÃO DE CRÉDITO",0,1,"L",0,"");
			$this->SetFont("Courier","",10);
			
			$this->Ln();
			
			$this->Cell(1.5,0.4,"NÚMERO ",0,0,"L",0,"");
			$this->SetFont("Courier","",15);
			$this->Cell(7,0.4,$dadosCtrCredi["DSCTRCRD"],0,0,"R",0,"");
			$this->SetFont("Courier","",10);
			$this->Cell(1,0.4,"",0,0,"L",0,"");
			$this->Cell(1.5,0.4,$dadosCtrCredi["DSDMOEDA"],0,0,"L",0,"");
			$this->SetFont("Courier","",15);
			$this->Cell(7,0.4,number_format(str_replace(",",".",$dadosCtrCredi["VLLIMITE"]),2,",","."),0,1,"R",0,"");
			
			$this->Ln();
			
			$this->SetFont("Courier","",10);
			
			$this->Cell(18,0.4,"Ao(s) ".$dadosCtrCredi["DSDTMVT1"],0,1,"L",0,"");
			$this->Cell(8.25,0.4,$dadosCtrCredi["DSDTMVT2"]." pagarei por está única via de",0,0,"L",0,"");
			$this->SetFont("Courier","",15);
			$this->Cell(9.75,0.4,"N O T A  P R O M I S S Ó R I A",0,1,"L",0,"");
			$this->SetFont("Courier","",10);
			$this->MultiCell(18,0.4,"à ".$dadosCtrCredi["NMRESCOP"]." - ".$dadosCtrCredi["NMEXTCOP"]." ".$dadosCtrCredi["NRDOCNPJ"]." ou a sua ordem a quantia de ".str_replace("*","",$dadosCtrCredi["DSVLNPR1"]).str_replace("*","",$dadosCtrCredi["DSVLNPR2"])." em moeda corrente deste país.",0,"L",0);
			
			$this->Ln();
			
			$this->Cell(9,0.4,"Pagável em ".$dadosCtrCredi["NMCIDPAC"],0,0,"L",0,"");
			$this->Cell(9,0.4,$dadosCtrCredi["NMCIDPAC"].",".$dadosCtrCredi["DSECTRNP"],0,1,"R",0,"");
			
			$this->Ln();
			
			$this->Cell(18,0.4,$dadosCtrCredi["NMPRIMTL"],0,1,"L",0,"");
			$this->Cell(8.75,0.4,$dadosCtrCredi["DSCPFCGC"],0,0,"L",0,"");
			$this->Cell(0.5,0.4,"",0,0,"L",0,"");
			$this->Cell(8.75,0.4,"________________________________________",0,1,"L",0,"");
			$this->Cell(8.75,0.4,"Conta/dv: ".formataNumericos("zzzz.zzz-9",$dadosCtrCredi["NRDCONTA"],".-"),0,0,"L",0,"");
			$this->Cell(0.5,0.4,"",0,0,"L",0,"");
			$this->Cell(8.75,0.4,"ASSINATURA",0,1,"L",0,"");
			$this->Ln();
			$this->Cell(18,0.4,"Endereço:",0,1,"L",0,"");
			$this->Cell(18,0.4,$dadosCtrCredi["ENDEASS1"],0,1,"L",0,"");
			$this->Cell(18,0.4,$dadosCtrCredi["ENDEASS2"],0,1,"L",0,"");
			
			$this->Ln();			
			
			for ($i = 0; $i < count($dadosAvalistas); $i++) {
				if ($i == 0) {
					$this->Cell(8.75,0.4,"Avalistas:",0,0,"L",0,"");
					$this->Cell(0.5,0.4,"",0,0,"L",0,"");
					$this->Cell(8.75,0.4,"Cônjuge:",0,1,"L",0,"");				
				}
				
				$this->Ln();
				$this->Ln();
							
				$this->Cell(8.75,0.4,"________________________________________",0,0,"L",0,"");
				$this->Cell(0.5,0.4,"",0,0,"L",0,"");
				$this->Cell(8.75,0.4,"________________________________________",0,1,"L",0,"");								
				$this->Cell(8.75,0.4,$dadosAvalistas[$i]["NMDAVALI"],0,0,"L",0,"");
				$this->Cell(0.5,0.4,"",0,0,"L",0,"");
				$this->Cell(8.75,0.4,$dadosAvalistas[$i]["NMCONJUG"],0,1,"L",0,"");		
				$this->Cell(8.75,0.4,$dadosAvalistas[$i]["CPFAVALI"],0,0,"L",0,"");
				$this->Cell(0.5,0.4,"",0,0,"L",0,"");
				$this->Cell(8.75,0.4,$dadosAvalistas[$i]["NRCPFCJG"],0,1,"L",0,"");				
				$this->Cell(18,0.4,$dadosAvalistas[$i]["DSENDAV1"],0,1,"L",0,"");
				$this->Cell(18,0.4,$dadosAvalistas[$i]["DSENDAV2"],0,1,"L",0,"");										
			}								
			/************************************************************************/
		}
		
		function geraBdnCeVis($dadosBdnCeVis,$dadosAvalistas) {
			$this->SetMargins(0.5,0.8);
			
			$this->AddPage();

			$this->SetFont("Courier","B",11);
			$this->SetTextColor(0,0,0);
			
			$this->Ln();
			$this->Ln();			

			$this->Cell(18,0.4,"     CONTRATO PARA UTILIZAÇÃO CARTÃO DE CRÉDITO ".$dadosBdnCeVis["NMCARTAO"],0,1,"L",0,"");

			$this->Ln();
	
			$this->Cell(5,0.4,"",0,0,"L",0,"");
			$this->Cell(5,0.4,$dadosBdnCeVis["DSSUBSTI"],0,0,"C",0,"");
			$this->Cell(3,0.4,"PROPOSTA: ",0,0,"L",0,"");
			$this->SetFont("Courier","",16);
			$this->Cell(4,0.4,formataNumericos('zzz.zz9',$dadosBdnCeVis["NRCTRCRD"],'.'),0,1,"R",0,"");
			$this->SetFont("Courier","B",11);
			
			$this->Ln();
			$this->Ln();
			$this->Ln();
			
			$this->SetFont("Courier","B",8);
			$this->Cell(3,0.4,"1) DAS PARTES:",0,0,"L",0,"");
			$this->Cell(9,0.4,$dadosBdnCeVis["NMEXTCOP"],0,0,"L",0,"");
			$this->Cell(3,0.4," - ".$dadosBdnCeVis["NMRESCOP"],0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(5,0.4,",  sociedade  cooperativa de",0,1,"L",0,"");
			$this->Cell(20,0.4,"crédito, de responsabilidade  limitada, regida  pela  legislação  vigente, normas  baixadas  pelo Conselho  Monetário",0,1,"L",0,"");
			$this->Cell(20,0.4,"Nacional, pela regulamentação  estabelecida pelo  Banco Central do Brasil  e pelo seu  estatuto  social, arquivado na",0,1,"L",0,"");
			$this->Cell(11.75,0.4,"Junta  Comercial  do   Estado   de   Santa Catarina,  inscrita   no",0,0,"L",0,"");
			$this->Cell(4.75,0.4,$dadosBdnCeVis["NRDOCNPJ"],0,0,"C",0,"");
			$this->Cell(3.5,0.4,",  estabelecida   a",0,1,"L",0,"");
			$this->Cell(7.5,0.4,$dadosBdnCeVis["DSENDCOP"],0,0,"L",0,"");
			$this->Cell(2,0.4,", n. ".formataNumericos('zz.zz9',$dadosBdnCeVis["NRENDCOP"],'.'),0,0,"L",0,"");
			$this->Cell(4.5,0.4,", bairro ".$dadosBdnCeVis["NMBAIRRO"],0,0,"L",0,"");
			$this->Cell(5,0.4,", ".$dadosBdnCeVis["NMCIDADE"],0,0,"L",0,"");
			$this->Cell(1,0.4,", ".$dadosBdnCeVis["CDUFDCOP"],0,1,"L",0,"");
			$this->SetFont("Courier","B",8);
			$this->Cell(7.0,0.4,"COOPERATIVA CENTRAL DE CRÉDITO - CECRED",0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(13,0.4,"Cooperativa Central de Crédito  de  responsabilidade  limitada, inscrita no",0,1,"L",0,"");
			$this->Cell(20,0.4,"CNPJ/MF sob o n. 05.463.212/0001-29,  estabelecida  na  Rua Frei Estanislau Schaette, n. 1201, bairro  Água Verde, na",0,1,"L",0,"");
			$this->Cell(20,0.4,"cidade de Blumenau, Estado de Santa Catarina.",0,1,"L",0,"");
			$this->SetFont("Courier","B",8);
			$this->Cell(2.5,0.4,"COOPERADO(A):",0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(7,0.4,$dadosBdnCeVis["NMPRIMTL"],0,0,"L",0,"");
			$this->Cell(5.5,0.4,", CPF/CNPJ ".$dadosBdnCeVis["NRCPFCGC"],0,0,"L",0,"");
			$this->Cell(5,0.4,", Conta-corrente: ".formataNumericos('z.zzz.zz9-9',$dadosBdnCeVis["NRDCONTA"],'.-').".",0,1,"L",0,"");
			
			$this->Ln();
			$this->Ln();
			
			$this->SetFont("Courier","B",8);
			$this->Cell(2.5,0.4,"2) DO OBJETO:",0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(17.5,0.4,"O presente  contrato tem por objeto  regular as condições para intermediação de prestação de  serviços",0,1,"L",0,"");
			$this->Cell(11.75,0.4,"de administração de cartões de crédito e seus desdobramentos entre a ",0,0,"L",0,"");
			$this->SetFont("Courier","B",8);
			$this->Cell(2,0.4,"COOPERATIVA",0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(1.25,0.4,", o(a) ",0,0,"L",0,"");
			$this->SetFont("Courier","B",8);
			$this->Cell(2.25,0.4,"COOPERADO(A)",0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(2.75,0.4,"e  as  empresas",0,1,"L",0,"");
			$this->SetFont("Courier","B",8);
			$this->Cell(10,0.4,"BRADESCO  ADMINISTRADORA  DE  CARTÕES  DE  CRÉDITO  LTDA.,",0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(5.5,0.4,"CNPJ/MF n. 43.199.330/0001-60 e",0,0,"L",0,"");
			$this->SetFont("Courier","B",8);
			$this->Cell(2.5,0.4,"BRADESCO S.A.,",0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(2,0.4,"CNPJ/MF  n.",0,1,"L",0,"");
			$this->Cell(9.25,0.4,"60.746.948/0001-12, doravante denominadas comumente de",0,0,"L",0,"");
			$this->SetFont("Courier","B",8);
			$this->Cell(1.75,0.4,"BRADESCO,",0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(9,0.4,"autorizada a operar  com  os  cartões de crédito  da",0,1,"L",0,"");
			$this->Cell(1.5,0.4,"bandeira",0,0,"L",0,"");
			$this->SetFont("Courier","B",8);
			$this->Cell(18.5,0.4,"VISA.",0,1,"L",0,"");
			
			$this->Ln();
			$this->Ln();
			
			$this->Cell(5.5,0.4,"3) DO CONTRATO DE INTERMEDIAÇÃO:",0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(0.25,0.4,"A",0,0,"L",0,"");
			$this->SetFont("Courier","B",8);
			$this->Cell(2,0.4,"COOPERATIVA",0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(12.25,0.4,", na  condição  de  intermediária,  para  o fornecimento  do  Cartão de",0,1,"L",0,"");
			$this->Cell(20,0.4,"Crédito do Sistema VISA,  tipo CECRED - EMPRESARIAL a seus associados, subscreveu o contrato/regulamento de adesão ao",0,1,"L",0,""); 
			$this->Cell(20,0.4,"sistema  de  cartão de crédito  oferecido pelo  BRADESCO,  de acordo  com o instrumento  registrado no 1o Cartório de",0,1,"L",0,"");
			$this->Cell(20,0.4,"Registro de Títulos e Documentos de Osasco,  Estado de São Paulo sob n.  64.053,  no  livro 'A',  funcionando naquele",0,1,"L",0,"");
			$this->Cell(4.5,0.4,"contrato/regulamento como",0,0,"L",0,"");
			$this->SetFont("Courier","B",8);
			$this->Cell(15.5,0.4,$dadosBdnCeVis["DSVINCUL"],0,1,"L",0,"");
			
			$this->Ln();
			$this->Ln();
			
			$this->Cell(6,0.4,"Parágrafo único: O(a) COOPERADO(A),",0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(14,0.4,"na condição de  usuário do cartão de crédito, pelo  presente  instrumento, declara",0,1,"L",0,"");
			$this->Cell(7.5,0.4,"conhecer o contrato/regulamento referido no ",0,0,"L",0,"");
			$this->SetFont("Courier","I",8);
			$this->Cell(0.75,0.4,"caput",0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(11.75,0.4,", aderindo e aceitando as condições, as quais se sujeita, funcionando",0,1,"L",0,"");
			$this->Cell(20,0.4,"naquele contrato/regulamento como  BENEFICIÁRIO, assim como, recebe neste ato uma cópia do  Regulamento da Utilização",0,1,"L",0,"");
			$this->Cell(20,0.4,"dos Cartões de Crédito Bradesco Empresariais, fazendo estes parte integrante do presente instrumento.",0,1,"L",0,"");			
			
			$this->Ln();
			$this->Ln();
			
			$this->SetFont("Courier","B",8);
			$this->Cell(5.5,0.4,"4) DA SUB-ROGAÇÃO DE DIREITOS:",0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(0.5,0.4,"A",0,0,"L",0,"");
			$this->SetFont("Courier","B",8);
			$this->Cell(2.25,0.4,"COOPERATIVA",0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(11.75,0.4,"ficará  sub-rogada  em  todos os direitos  do  BRADESCO, perante o(a)",0,1,"L",0,"");
			$this->SetFont("Courier","B",8);
			$this->Cell(2.25,0.4,"COOPERADO(A),",0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(17.75,0.4," usuário do cartão, sempre que liquidar  as  faturas  mensais, e  até a liquidação total do débito deste",0,1,"L",0,"");
			$this->Cell(20,0.4,"perante a mesma.",0,1,"L",0,"");
			
			$this->Ln();
			$this->Ln();
			
			$this->SetFont("Courier","B",8);
			$this->Cell(5.25,0.4,"5) DOS PROBLEMAS COM O CARTÃO:",0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(4.25,0.4," O relacionamento do(a) ",0,0,"L",0,"");
			$this->SetFont("Courier","B",8);
			$this->Cell(2.25,0.4,"COOPERADO(A),",0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(8.25,0.4," para  comunicação de danificação, perda, roubo,",0,1,"L",0,"");
			$this->Cell(20,0.4,"furto, fraude  ou  falsificação  de  cartão e outras,  será  diretamente  com  o  BRADESCO, podendo  eventualmente  a",0,1,"L",0,"");
			$this->SetFont("Courier","B",8);
			$this->Cell(2.05,0.4,"COOPERATIVA",0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(17.95,0.4,"servir de intermediária.",0,1,"L",0,"");
			
			$this->Ln();
			$this->Ln();
			
			$this->SetFont("Courier","B",8);
			$this->Cell(5.5,0.4,"6) DA REMUNERAÇÃO DOS SERVIÇOS:",0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(14.5,0.4,"A remuneração pelos serviços disponibilizados será  de inteira responsabilidade do(a)",0,1,"L",0,"");
			$this->SetFont("Courier","B",8);
			$this->Cell(2.25,0.4,"COOPERADO(A),",0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(1.75,0.4,"cabendo a",0,0,"L",0,"");
			$this->SetFont("Courier","B",8);
			$this->Cell(2.05,0.4,"COOPERATIVA",0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(14.95,0.4,"debitá-la na conta corrente do mesmo.",0,1,"L",0,"");
			
			$this->Ln();
			$this->Ln();
			
			$this->SetFont("Courier","B",8);
			$this->Cell(5.25,0.4,"Parágrafo único: A COOPERATIVA",0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(14.75,0.4," poderá  repassar, além  da  remuneração  dos  serviços  cobrados  pelo  BRADESCO, uma",0,1,"L",0,"");
			$this->Cell(15.25,0.4,"remuneração pelos seus serviços de intermediação, que também sera debitada na conta do(a)",0,0,"L",0,"");
			$this->SetFont("Courier","B",8);
			$this->Cell(4.75,0.4,"COOPERADO(A).",0,1,"L",0,"");
			
			$this->Ln();
			$this->Ln();
			
			$this->SetFont("Courier","B",8);
			$this->Cell(4.5,0.4,"7) DO DÉBITO DAS FATURAS:",0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(1,0.4,"O(a)",0,0,"L",0,"");
			$this->SetFont("Courier","B",8);
			$this->Cell(2.5,0.4,"COOPERADO(A),",0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(1.25,0.4,"e o(s)",0,0,"L",0,"");
			$this->SetFont("Courier","B",8);
			$this->Cell(2,0.4,"FIADOR(ES),",0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(8.75,0.4,"desde logo, em  caráter irrevogável e irretrátavel,",0,1,"L",0,"");
			$this->Cell(20,0.4,"para todos os  efeitos legais e contratuais, autoriza(m)  desde já, o  débito do valor  da fatura  mensal oriunda  da",0,1,"L",0,""); 
			$this->Cell(20,0.4,"utilização  do cartão,  e demais  despesas  ou encargos, inclusive  anuidades,  na data do  seu vencimento, em sua(s)",0,1,"L",0,""); 
			$this->Cell(6.25,0.4,"conta(s) corrente(s) mantida junto a",0,0,"L",0,""); 
			$this->SetFont("Courier","B",8);
			$this->Cell(2.25,0.4,"COOPERATIVA,",0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(11.5,0.4,"podendo esta  utilizar o saldo credor de qualquer conta em nome dos",0,1,"L",0,"");
			$this->Cell(20,0.4,"mesmos, aplicação  financeira e créditos  de seus titulares, em qualquer das  unidades da mesma, efetuando o bloqueio",0,1,"L",0,"");
			$this->Cell(20,0.4,"dos  valores, até o limite  necessário  para  a  liquidação  ou  amortização  das  obrigações assumidas e vencidas no",0,1,"L",0,"");
			$this->Cell(6.5,0.4,"presente contrato, obrigando-se ainda",0,0,"L",0,"");
			$this->SetFont("Courier","B",8);
			$this->Cell(2.5,0.4,"COOPERADO(A),",0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(1.25,0.4,"e o(s)",0,0,"L",0,"");
			$this->SetFont("Courier","B",8);
			$this->Cell(2,0.4,"FIADOR(ES),",0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(7.75,0.4,"a sempre manter(em) saldo em sua(s) conta(s)-",0,1,"L",0,"");
			$this->Cell(20,0.4,"corrente(s) para a realização dos referidos débitos.",0,1,"L",0,"");
			
			$this->AddPage();

			$this->SetFont("Courier","B",11);
			$this->SetTextColor(0,0,0);
			
			$this->Ln();

			$this->Cell(18,0.4,"     CONTRATO PARA UTILIZAÇÃO CARTÃO DE CRÉDITO ".$dadosBdnCeVis["NMCARTAO"],0,1,"L",0,"");

			$this->Ln();
	
			$this->Cell(5,0.4,"",0,0,"L",0,"");
			$this->Cell(5,0.4,$dadosBdnCeVis["DSSUBSTI"],0,0,"C",0,"");
			$this->Cell(3,0.4,"PROPOSTA: ",0,0,"L",0,"");
			$this->SetFont("Courier","",16);
			$this->Cell(4,0.4,formataNumericos('zzz.zz9',$dadosBdnCeVis["NRCTRCRD"],'.'),0,1,"R",0,"");
			$this->SetFont("Courier","B",11);
			
			$this->Ln();
			$this->Ln();
			$this->Ln();
			
			$this->SetFont("Courier","B",8);
			$this->Cell(3,0.4,"Parágrafo único:",0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(1,0.4,"O(a)",0,0,"L",0,"");
			$this->SetFont("Courier","B",8);
			$this->Cell(2.5,0.4,"COOPERADO(A),",0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(13.5,0.4,"poderá efetuar saques na rede de caixas  eletrônicos BDN e Banco 24 Horas sendo",0,1,"L",0,"");
			$this->Cell(16.75,0.4,"que tais saques e respectivas tarifas serão imediatamente debitados de sua conta corrente junto a",0,0,"L",0,"");
			$this->SetFont("Courier","B",8);
			$this->Cell(2.25,0.4,"COOPERATIVA.",0,1,"L",0,"");
			
			$this->Ln();
			$this->Ln();
			
			$this->Cell(4.5,0.4,"8) DO LIMITE DE CRÉDITO:",0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(1.25,0.4,"Cabe a",0,0,"L",0,"");
			$this->SetFont("Courier","B",8);
			$this->Cell(2.25,0.4,"COOPERATIVA,",0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(9.5,0.4,"a seu  critério, estabelecer o limite de  crédito do(a)",0,0,"L",0,"");
			$this->SetFont("Courier","B",8);
			$this->Cell(2.5,0.4,"COOPERADO(A),",0,1,"R",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(20,0.4,"podendo  ajustá-lo ou até  cancelá-lo  integralmente, de acordo com suas condições gerais de crédito do mesmo perante",0,1,"L",0,"");
			$this->Cell(16,0.4,"esta, podendo ainda, reduzí-lo, se o saldo devedor da fatura mensal não for liquidado pelo(a)",0,0,"L",0,"");
			$this->SetFont("Courier","B",8);
			$this->Cell(4,0.4,"COOPERADO(A).",0,1,"L",0,"");
			
			$this->Ln();
			$this->Ln();
			
			$this->Cell(5.4,0.4,"9) DO FORNECIMENTO DE EXTRATOS:",0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(0.25,0.4,"A",0,0,"L",0,"");
			$this->SetFont("Courier","B",8);
			$this->Cell(2.05,0.4,"COOPERATIVA,",0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(12.3,0.4,"na condição de intermediária não terá qualquer controle de administração",0,1,"L",0,"");
			$this->Cell(20,0.4,"sobre  o  cartão  de  crédito,   sendo  que,  inclusive  os  extratos  mensais  de  utilização  das  contas  será  de",0,1,"L",0,"");
			$this->Cell(20,0.4,"responsabilidade exclusiva do BRADESCO.",0,1,"L",0,"");

			$this->Ln();
			$this->Ln();
			
	
			$this->SetFont("Courier","B",8);
			$this->Cell(5.25,0.4,"Parágrafo único: A COOPERATIVA",0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(3.25,0.4,"poderá remeter ao",0,0,"L",0,"");
			$this->SetFont("Courier","B",8);
			$this->Cell(2.5,0.4,"COOPERADO(A),",0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(9,0.4,"juntamente  com o aviso de débito em conta corrente,",0,1,"L",0,"");
			$this->Cell(20,0.4,"toda a documentação, extratos e demonstrativos remetidos pelo BRADESCO.",0,1,"L",0,"");			
			
			$this->Ln();
			$this->Ln();
			
			$this->SetFont("Courier","B",8);
			$this->Cell(5.25,0.4,"10) DO RECEBIMENTO DO CARTÃO:",0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(0.75,0.4,"O(a)",0,0,"L",0,"");
			$this->SetFont("Courier","B",8);
			$this->Cell(2.5,0.4,"COOPERADO(A),",0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(6.5,0.4,"declara receber o cartão de crédito n.",0,0,"L",0,"");
			$this->Cell(3.5,0.4,formataNumericos('9999.9999.9999.9999',$dadosBdnCeVis["NRCRCARD"],'.').",",0,0,"L",0,"");
			$this->Cell(1.5,0.4,"conforme",0,1,"L",0,"");
			$this->Cell(1.5,0.4,"proposta",0,0,"L",0,"");
			$this->Cell(19.5,0.4,formataNumericos('zzz.zz9',$dadosBdnCeVis["NRCTRCRD"],'.').", em nome do titular do cartão ".$dadosBdnCeVis["NMTITCRD"],0,1,"L",0,"");
			
			$this->Ln();
			$this->Ln();
			
			$this->SetFont("Courier","B",8);
			$this->Cell(5.25,0.4,"11) DAS GARANTIAS - DA FIANÇA:",0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(14.75,0.4,"Para garantir o cumprimento das obrigações assumidas no presente contrato, comparecem,",0,1,"L",0,"");
			$this->Cell(4.5,0.4,"igualmente, na condição de",0,0,"L",0,"");
			$this->SetFont("Courier","B",8);
			$this->Cell(2,0.4,"FIADOR(ES),",0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(13.5,0.4,"igualmente, na condição de a(s) pessoa(s) e seu(s) cônjuge(s) nominado(s), o(s)",0,1,"L",0,"");
			$this->Cell(20,0.4,"qual(is)  expressamente  declara(m) que responsabiliza(m)-se,  solidariamente, como  principal(is)  pagador(es), pelo",0,1,"L",0,"");
			$this->Cell(9,0.4,"cumprimento de todas as  obrigações assumidas pelo(a)",0,0,"L",0,"");
			$this->SetFont("Courier","B",8);
			$this->Cell(2.5,0.4,"COOPERADO(A),",0,0,"C",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(8.5,0.4,"neste  contrato, renunciando,  expressamente,  os",0,1,"L",0,"");
			$this->Cell(20,0.4,"benefícios  de ordem  que trata o art.  827, em conformidade com o art.  828, incisos I e II, e art.  838, do  Código",0,1,"L",0,"");
			$this->Cell(20,0.4,"Civil Brasileiro (Lei n. 10.406, de 10/01/2002).",0,1,"L",0,"");
			
			$this->Ln();
			$this->Ln();

			
			$this->SetFont("Courier","B",8);
			$this->Cell(9.5,0.4,"12) DA GARANTIA ADICIONAL  -  DAS NOTAS PROMISSÓRIAS:",0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(5.5,0.4,"Como  garantia  adicional, o(a)",0,0,"L",0,"");
			$this->SetFont("Courier","B",8);
			$this->Cell(2.5,0.4,"COOPERADO(A),",0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(2.5,0.4,"emite  Nota(s)",0,1,"L",0,"");
			$this->Cell(20,0.4,"Promissória(s),  vinculada(s) ao Contrato,  no valor total do  Empréstimo/Financiamento,  inerente(s) a(s) parcela(s)",0,1,"L",0,"");			
			$this->Cell(8.75,0.4,"nele estabelecida(s), igualmente subscrita pelo(s)",0,0,"L",0,"");	
			$this->SetFont("Courier","B",8);
			$this->Cell(2,0.4,"FIADOR(ES),",0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(9.25,0.4,"a(s)  qual(is) passa(m)  a  ser  parte  integrante do",0,1,"L",0,"");	
			$this->Cell(20,0.4,"presente.",0,1,"L",0,"");	
			
			$this->Ln();
			$this->Ln();
			
			$this->SetFont("Courier","B",8);	
			$this->Cell(3.85,0.4,"13) DA EXIGIBILIDADE:",0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(16.15,0.4,"O presente instrumento reverte-se da condição de título executivo extrajudicial, nos termos do ",0,1,"L",0,"");			
			$this->Cell(20,0.4,"Art.  585  do  C.P.C., reconhecendo  as  partes, desde já, a sua liquidez, certeza  e  exigibilidade. Promissória(s),",0,1,"L",0,"");			
			$this->Cell(20,0.4,"vinculada(s) ao Contrato, no valor total do Empréstimo/Financiamento, inerente(s) a(s) parcela(s)",0,1,"L",0,"");
			
			$this->Ln();
			$this->Ln();
			
			$this->SetFont("Courier","B",8);
			$this->Cell(11,0.4,"14) DO PRAZO DE VIGÊNCIA E DAS CONDIÇÕES ESPECIAS DE VENCIMENTO:",0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(9,0.4,"O presente contrato vigorará por prazo indeterminado,",0,1,"L",0,"");
			$this->Cell(20,0.4,"sendo que a falta ou insuficiência de fundos na(s) conta(s)-corrente(s), impossibilitando o pagamento e liquidação no",0,1,"L",0,"");
			$this->Cell(20,0.4,"vencimento, de quaisquer das faturas do cartão  de  crédito, independentemente  de  qualquer  notificação judicial ou",0,1,"L",0,"");
			$this->Cell(8.5,0.4,"extrajudicial, poderá determinar, a  critério da",0,0,"L",0,"");
			$this->SetFont("Courier","B",8);
			$this->Cell(2.25,0.4,"Cooperativa,",0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(9.25,0.4,"o vencimento  antecipado do presente  contrato, com a",0,1,"L",0,"");
			$this->Cell(20,0.4,"cobrança  de  forma amigável e/ou judicial  dos  valores estornados da conta-corrente, mantendo este contrato as suas",0,1,"L",0,"");
			$this->Cell(20,0.4,"características de liquidez, certeza e exigibilidade.",0,1,"L",0,"");
			
			$this->Ln();
			$this->Ln();
			
			$this->SetFont("Courier","B",8);
			$this->Cell(3,0.4,"Parágrafo único:",0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(17,0.4,"Sobre o montante da quantia  devida e não paga, incidirão, além da correção  monetária, com base no",0,1,"L",0,"");
			$this->Cell(20,0.4,"INPC/IBGE, juros moratórios e compensatórios a base do que  preceitua o atr.  406, do Código Civil Brasileiro (Lei n.",0,1,"L",0,"");
			$this->Cell(20,0.4,"10.406, de 10/01/2002), ao mês vigente  entre a data da mora até a data do efetivo  pagamento, multa contratual de 2%",0,1,"L",0,"");
			$this->Cell(20,0.4,"(dois por cento), sobre o montante  apurado, e impostos que incidam ou venham a incidir sobre a operação  contratada,",0,1,"L",0,"");
			$this->Cell(2.25,0.4,"devendo o(a)",0,0,"L",0,"");
			$this->SetFont("Courier","B",8);
			$this->Cell(2.25,0.4,"COOPERADO(A)",0,0,"L",0,"");			
			$this->SetFont("Courier","",8);
			$this->Cell(1.25,0.4,"e seus",0,0,"L",0,"");
			$this->SetFont("Courier","B",8);
			$this->Cell(2.25,0.4,"Coobrigados,",0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(12,0.4,"efetuar  imediatamente o pagamento do montante do débito  apurado, sob ",0,1,"L",0,"");
			$this->Cell(20,0.4,"pena de serem demandados judicialmente.",0,1,"L",0,"");
			
			$this->Ln();
			$this->Ln();
			
			$this->SetFont("Courier","B",8);			
			$this->Cell(5,0.4,"15) DOS EFEITOS DO CONTRATO:",0,0,"L",0,"");			
			$this->SetFont("Courier","",8);			
			$this->Cell(4.5,0.4,"Este  contrato  obriga  a",0,0,"L",0,"");
			$this->SetFont("Courier","B",8);
			$this->Cell(2.25,0.4,"COOPERATIVA,",0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(0.75,0.4,"O(a)",0,0,"L",0,"");
			$this->SetFont("Courier","B",8);
			$this->Cell(2.5,0.4,"COOPERADO(A),",0,0,"C",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(1.25,0.4,"e o(s)",0,0,"L",0,"");
			$this->SetFont("Courier","B",8);
			$this->Cell(2.25,0.4,"FIADOR(ES),",0,0,"C",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(1.5,0.4,"ao  fiel",0,1,"L",0,"");
			$this->Cell(20,0.4,"cumprimento das cláusulas e condições estabelecidas no mesmo, sendo  celebrado em caráter irrevogável e irretratável,",0,1,"L",0,"");
			$this->Cell(20,0.4,"obrigando, também, seus herdeiros, cessionários e sucessores, a qualquer título.",0,1,"L",0,"");
			
			$this->AddPage();

			$this->SetFont("Courier","B",11);
			$this->SetTextColor(0,0,0);
			
			$this->Ln();

			$this->Cell(18,0.4,"     CONTRATO PARA UTILIZAÇÃO CARTÃO DE CRÉDITO ".$dadosBdnCeVis["NMCARTAO"],0,1,"L",0,"");

			$this->Ln();
	
			$this->Cell(5,0.4,"",0,0,"L",0,"");
			$this->Cell(5,0.4,$dadosBdnCeVis["DSSUBSTI"],0,0,"C",0,"");
			$this->Cell(3,0.4,"PROPOSTA: ",0,0,"L",0,"");
			$this->SetFont("Courier","",16);
			$this->Cell(4,0.4,formataNumericos('zzz.zz9',$dadosBdnCeVis["NRCTRCRD"],'.'),0,1,"R",0,"");
			$this->SetFont("Courier","B",11);
			
			$this->Ln();
			$this->Ln();
			$this->Ln();
			
			$this->SetFont("Courier","B",8);			
			$this->Cell(2.25,0.4,"16) DO FORO:",0,0,"L",0,"");						
			$this->SetFont("Courier","",8);
			$this->Cell(12.25,0.4,"As partes, de comum acordo, elegem o foro da Comarca do domicílio do(a)",0,0,"L",0,"");
			$this->SetFont("Courier","B",8);
			$this->Cell(2.5,0.4,"COOPERADO(A),",0,0,"L",0,"");
			$this->SetFont("Courier","",8);
			$this->Cell(3,0.4,"com  exclusão de",0,1,"L",0,"");
			$this->Cell(20,0.4,"qualquer outro, por mais privilegiado que seja, para dirimir quaisquer questões resultantes do presente contrato.",0,1,"L",0,"");
			$this->MultiCell(20,0.4,"E assim, por se acharem justos e contratados, assinam o presente contrato, em 02(duas) vias de igual teor e forma, na presença de duas testemunhas abaixo, que, estando cientes, também assinam, para que produza os devidos e legais efeitos.",0,"J",0);
			
			$this->Ln();
			$this->Ln();

			$this->Cell(20,0.4,$dadosBdnCeVis["NMCIDADE"]." ".$dadosBdnCeVis["CDUFDCOP"].", ".$dadosBdnCeVis["DSEMSCTR"].".",0,1,"L",0,"");
			
			$this->Ln();
			$this->Ln();
			$this->Ln();
			
			$this->Cell(20,0.4,"__________________________________________________                 __________________________________________________",0,1,"L",0,"");
			$this->Cell(8.5,0.4,$dadosBdnCeVis["NMPRIMTL"],0,0,"L",0,"");
			$this->Cell(3,0.4,"",0,0,"L",0,"");
			$this->Cell(8.5,0.4,$dadosBdnCeVis["NMEXTCOP"],0,1,"L",0,"");
			
			$this->Ln();
			$this->Ln();
			$this->Ln();
			
			$this->Cell(20,0.4,"__________________________________________________                 __________________________________________________",0,1,"L",0,"");
			$this->Cell(20,0.4,"Fiador 1: ________________________________________                 Cônjuge Fiador 1: ________________________________",0,1,"L",0,"");
			$this->Cell(20,0.4,"CPF: _______________________                                       CPF: _______________________                      ",0,1,"L",0,"");

			$this->Ln();
			$this->Ln();
			$this->Ln();
			
			$this->Cell(20,0.4,"__________________________________________________                 __________________________________________________",0,1,"L",0,"");
			$this->Cell(20,0.4,"Fiador 2: ________________________________________                 Cônjuge Fiador 2: ________________________________",0,1,"L",0,"");
			$this->Cell(20,0.4,"CPF: _______________________                                       CPF: _______________________                      ",0,1,"L",0,"");			
			
			$this->Ln();
			$this->Ln();
			$this->Ln();
			
			$this->Cell(20,0.4,"__________________________________________________                 __________________________________________________",0,1,"L",0,"");
			$this->Cell(20,0.4,"Testemunha 1: ____________________________________                 Testemunha 2: ____________________________________",0,1,"L",0,"");
			$this->Cell(20,0.4,"CPF/MF: ________________________                                   CPF/MF: ________________________                  ",0,1,"L",0,"");			
			$this->Cell(20,0.4,"CI: ____________________________                                   CI: ____________________________                  ",0,1,"L",0,"");

			$this->Ln();
			$this->Ln();
			$this->Ln();			

			$this->Cell(20,0.4,"                                                                   __________________________________________________",0,1,"L",0,"");
			$this->Cell(20,0.4,"                                                                   Operador: ".$dadosBdnCeVis["NMOPERAD"],0,1,"L",0,"");			
			
			/***********************NOTA PROMISSORIA***************************/
			$this->AddPage();

			$this->SetFont("Courier","B",10);
			
			$this->Cell(9,0.4,"NOTA PROMISSÓRIA VINCULADA AO",0,0,"L",0,"");
			$this->SetFont("Courier","",10);
			$this->Cell(9,0.4,"Vencimento: ".$dadosBdnCeVis["DSEMSCTR"],0,1,"R",0,"");
			$this->SetFont("Courier","B",10);
			$this->Cell(18,0.4,"CONTRATO DE CARTÃO DE CRÉDITO",0,1,"L",0,"");
			$this->SetFont("Courier","",10);
			
			$this->Ln();
			
			$this->Cell(1.5,0.4,"NÚMERO ",0,0,"L",0,"");
			$this->SetFont("Courier","",15);
			$this->Cell(7,0.4,$dadosBdnCeVis["DSCTRCRD"],0,0,"R",0,"");
			$this->SetFont("Courier","",10);
			$this->Cell(1,0.4,"",0,0,"L",0,"");
			$this->Cell(1.5,0.4,$dadosBdnCeVis["DSDMOEDA"],0,0,"L",0,"");
			$this->SetFont("Courier","",15);
			$this->Cell(7,0.4,number_format(str_replace(",",".",$dadosBdnCeVis["VLLIMITE"]),2,",","."),0,1,"R",0,"");
			
			$this->Ln();
			
			$this->SetFont("Courier","",10);
			
			$this->Cell(18,0.4,"Ao(s) ".$dadosBdnCeVis["DSDTMVT1"],0,1,"L",0,"");
			$this->Cell(8.25,0.4,$dadosBdnCeVis["DSDTMVT2"]." pagarei por está única via de",0,0,"L",0,"");
			$this->SetFont("Courier","",15);
			$this->Cell(9.75,0.4,"N O T A  P R O M I S S Ó R I A",0,1,"L",0,"");
			$this->SetFont("Courier","",10);
			$this->MultiCell(18,0.4,"à ".$dadosBdnCeVis["NMRESCOP"]." - ".$dadosBdnCeVis["NMEXTCOP"]." ".$dadosBdnCeVis["NRDOCNPJ"]." ou a sua ordem a quantia de ".str_replace("*","",$dadosBdnCeVis["DSVLNPR1"]).str_replace("*","",$dadosBdnCeVis["DSVLNPR2"])." em moeda corrente deste país.",0,"L",0);
			
			$this->Ln();
			
			$this->Cell(9,0.4,"Pagável em ".$dadosBdnCeVis["NMCIDPAC"],0,0,"L",0,"");
			$this->Cell(9,0.4,$dadosBdnCeVis["NMCIDPAC"].",".$dadosBdnCeVis["DSEMSCTR"],0,1,"R",0,"");
			
			$this->Ln();
			
			$this->Cell(18,0.4,$dadosBdnCeVis["NMPRIMTL"],0,1,"L",0,"");
			$this->Cell(8.75,0.4,$dadosBdnCeVis["DSCPFCGC"],0,0,"L",0,"");
			$this->Cell(0.5,0.4,"",0,0,"L",0,"");
			$this->Cell(8.75,0.4,"________________________________________",0,1,"L",0,"");
			$this->Cell(8.75,0.4,"Conta/dv: ".formataNumericos("zzzz.zzz-9",$dadosBdnCeVis["NRDCONTA"],".-"),0,0,"L",0,"");
			$this->Cell(0.5,0.4,"",0,0,"L",0,"");
			$this->Cell(8.75,0.4,"ASSINATURA",0,1,"L",0,"");
			$this->Ln();		
			$this->Cell(18,0.4,"Endereço:",0,1,"L",0,"");
			$this->Cell(18,0.4,$dadosBdnCeVis["ENDEASS1"],0,1,"L",0,"");
			$this->Cell(18,0.4,$dadosBdnCeVis["ENDEASS2"],0,1,"L",0,"");
			
			$this->Ln();
			
			for ($i = 0; $i < count($dadosAvalistas); $i++) {
				if ($i == 0) {
					$this->Cell(8.75,0.4,"Avalistas:",0,0,"L",0,"");
					$this->Cell(0.5,0.4,"",0,0,"L",0,"");
					$this->Cell(8.75,0.4,"Cônjuge:",0,1,"L",0,"");					
				}
				
				$this->Ln();
				$this->Ln();
							
				$this->Cell(8.75,0.4,"________________________________________",0,0,"L",0,"");
				$this->Cell(0.5,0.4,"",0,0,"L",0,"");
				$this->Cell(8.75,0.4,"________________________________________",0,1,"L",0,"");								
				$this->Cell(8.75,0.4,$dadosAvalistas[$i]["NMDAVALI"],0,0,"L",0,"");
				$this->Cell(0.5,0.4,"",0,0,"L",0,"");
				$this->Cell(8.75,0.4,$dadosAvalistas[$i]["NMCONJUG"],0,1,"L",0,"");		
				$this->Cell(8.75,0.4,$dadosAvalistas[$i]["CPFAVALI"],0,0,"L",0,"");
				$this->Cell(0.5,0.4,"",0,0,"L",0,"");
				$this->Cell(8.75,0.4,$dadosAvalistas[$i]["NRCPFCJG"],0,1,"L",0,"");				
				$this->Cell(18,0.4,$dadosAvalistas[$i]["DSENDAV1"],0,1,"L",0,"");
				$this->Cell(18,0.4,$dadosAvalistas[$i]["DSENDAV2"],0,1,"L",0,"");										
			}								
			/************************************************************************/			
		}
		
		function geraSol2viaCart($dados2viaCart) {
			$this->SetMargins(2,3.5);
			
			$this->AddPage();
			$this->SetTextColor(0,0,0);
			
			$this->SetFont("Courier","",13);
			$this->Cell(17,0.4,$dados2viaCart["NMEXTCOP"],0,1,"C",0,"");
			$this->Cell(17,0.4,formataNumericos('zz.zzz.zzz.zzzz.z9',$dados2viaCart["NRDOCNPJ"],'.'),0,1,"C",0,"");
			
			$this->Ln();
			$this->Ln();	
			$this->Ln();			

			$this->SetFont("Courier","U",11);
			$this->Cell(17,0.4,"SOLICITAÇÃO DE SEGUNDA VIA DE CARTÃO DE CRÉDITO",0,1,"C",0,"");			

			$this->Ln();
			$this->Ln();	
			$this->Ln();			
			$this->Ln();
			
			$this->SetFont("Courier","",10);
			
			$this->Cell(6,0.4,"Conta/dv: ".formataNumericos("zzzz.zzz-9",$dados2viaCart["NRDCONTA"],".-"),0,0,"L",0,"");
			$this->Cell(11,0.4,"Número do cartão: ".formataNumericos('9999.9999.9999.9999',$dados2viaCart["NRCRCARD"],'.'),0,1,"L",0,"");
			
			$this->Ln();

			$this->Cell(17,0.4,"Associado: ".$dados2viaCart["NMPRIMTL"],0,1,"L",0,"");			
			
			$this->Ln();
			$this->Ln();
			$this->Ln();	
			$this->Ln();	
			
			$this->MultiCell(17,0.4,"Solicito pela presente, a segunda via do cartão de crédito ".$dados2viaCart["DSADMCRD"]." número ".formataNumericos('9999.9999.9999.9999',$dados2viaCart["NRCRCARD"],'.').", por motivo de ".$dados2viaCart["DSMOT2VI"].".",0,"J",0);
			
			$this->Ln();
			$this->Ln();	
			$this->Ln();	
			$this->Ln();
			$this->Ln();
			$this->Ln();			
			$this->Ln();	
			
			$this->Cell(17,0.4,$dados2viaCart["LOCALDAT"],0,1,"L",0,"");
			
			$this->Ln();
			$this->Ln();
			$this->Ln();			
			$this->Ln();	
			$this->Ln();	

			$this->Cell(8,0.4,"_______________________________________",0,0,"L",0,"");
			$this->Ln();	
			$this->Cell(8,0.4,$dados2viaCart["NMPRIMTL"],0,0,"L",0,"");
			
			$this->Ln();
			$this->Ln();
			$this->Ln();			
			$this->Ln();	
			$this->Ln();		
			
			$this->Cell(8,0.4,"_______________________________________",0,1,"L",0,"");
			$this->Cell(8,0.4,trim($dados2viaCart["NMRECOP1"]),0,1,"L",0,"");
			$this->Cell(8,0.4,trim($dados2viaCart["NMRECOP2"]),0,1,"L",0,"");			
		}
		
		function geraCancBloq($dadosCancBloq) {
			$this->SetMargins(2,3.5);
			
			$this->AddPage();
			
			$this->SetFont("Courier","UB",10);
			$this->SetTextColor(0,0,0);
			
			$this->Cell(17,0.4,"TERMO DE ".strtoupper($dadosCancBloq["DSDTERMO"])." DO CARTÃO DE CRÉDITO",0,1,"C",0,"");			

			$this->Ln();
			$this->Ln();	
			$this->Ln();			
			$this->Ln();
			
			$this->SetFont("Courier","",10);
			
			$this->Cell(6,0.4,"Conta/dv: ".formataNumericos("zzzz.zzz-9",$dadosCancBloq["NRDCONTA"],".-"),0,0,"L",0,"");
			$this->Cell(11,0.4,"Número da conta cartão: ".formataNumericos('9999.9999.9999.9999',$dadosCancBloq["NRCRCARD"],'.'),0,1,"L",0,"");
			
			$this->Ln();

			$this->Cell(17,0.4,"Associado: ".$dadosCancBloq["NMPRIMTL"],0,1,"L",0,"");			
			
			$this->Ln();
			$this->Ln();
			$this->Ln();	
			$this->Ln();	
			
			$this->MultiCell(17,0.4,"Solicito pela presente, o ".strtolower($dadosCancBloq["DSDTERMO"])." do cartão de crédito ".$dadosCancBloq["DSADMCRD"]." número ".formataNumericos('9999.9999.9999.9999',$dadosCancBloq["NRCRCARD"],'.').".",0,"J",0);
			
			$this->Ln();
			$this->Ln();	
			$this->Ln();	
			$this->Ln();
			$this->Ln();
			$this->Ln();			
			$this->Ln();	
			
			$this->Cell(17,0.4,$dadosCancBloq["LOCALDAT"],0,1,"L",0,"");
			
			$this->Ln();
			$this->Ln();
			$this->Ln();			
			$this->Ln();	
			$this->Ln();	

			$this->Cell(8,0.4,"_______________________________________",0,0,"L",0,"");
			$this->Ln();
			$this->Cell(8,0.4,$dadosCancBloq["NMPRIMTL"],0,0,"L",0,"");
			
			$this->Ln();
			$this->Ln();
			$this->Ln();			
			$this->Ln();	
			$this->Ln();
			
			$this->Cell(8,0.4,"_______________________________________",0,1,"L",0,"");	
			$this->Cell(8,0.4,$dadosCancBloq["OPERADOR"],0,1,"L",0,"");			
		}		
		
		function geraAltDtVenctoCrd($dadosContrato) {
			$this->SetMargins(1.5,1.5);
			
			$this->AddPage();

			$this->SetFont("Courier","B",13);
			$this->SetTextColor(0,0,0);
			
			$this->Cell(18,0.4,$dadosContrato["NMEXTCOP"],0,1,"L",0,"");
			$this->Cell(18,0.4,$dadosContrato["DSLINHA1"],0,1,"L",0,"");
			$this->Cell(18,0.4,$dadosContrato["DSLINHA2"],0,1,"L",0,"");
			$this->Cell(18,0.4,$dadosContrato["DSLINHA3"],0,1,"L",0,"");
			
			$this->Ln();
			$this->Ln();			
			$this->Ln();
			$this->Ln();
			
			$this->Cell(18,0.4,$dadosContrato["DSEMSCTR"].".",0,1,"L",0,"");

			$this->Ln();
			$this->Ln();
			$this->Ln();
			$this->Ln();

			$this->Cell(18,0.4,"A CECRED",0,1,"L",0,"");
			$this->Cell(18,0.4,"A/C ADMINISTRATIVO/FINANCEIRO",0,1,"L",0,"");
			
			$this->Ln();
			$this->Ln();
			$this->Ln();
			$this->Ln();
			
			$this->Cell(18,0.4,"SOLICITAMOS A ALTERAÇÃO DA DATA DE VENCIMENTO DO CARTÃO ABAIXO:",0,1,"L",0,"");
			
			$this->Ln();
			$this->Ln();
			$this->Ln();
			$this->Ln();			
			
			$this->Cell(5,0.4,"NÚMERO DO CARTÃO:",0,0,"R",0,"");
			$this->Cell(13,0.4,formataNumericos('9999.9999.9999.9999',$dadosContrato["NRCRCARD"],'.'),0,1,"L",0,"");

			$this->Ln();			

			$this->Cell(5,0.4,"NOME:",0,0,"R",0,"");
			$this->Cell(13,0.4,$dadosContrato["NMTITCRD"],0,1,"L",0,"");
			
			$this->Ln();			
			
			$this->Cell(5,0.4,"NOVA DATA:",0,0,"R",0,"");
			$this->Cell(13,0.4,formataNumericos('99',$dadosContrato["DDDEBITO"],''),0,1,"L",0,"");
			
			$this->Ln();
			$this->Ln();
			$this->Ln();
			$this->Ln();			
			
			$this->Cell(18,0.4,"ATENCIOSAMENTE",0,1,"L",0,"");
			
			$this->Ln();			
			$this->Ln();			
			$this->Ln();			
			$this->Ln();			

			$this->Cell(18,0.4,"____________________________________________",0,1,"C",0,"");
			$this->Cell(18,0.4,trim($dadosContrato["NMPRIMTL"]),0,1,"C",0,"");
			
			$this->Ln();			
			$this->Ln();			
			$this->Ln();			
			
			$this->Cell(18,0.4,"____________________________________________",0,1,"C",0,"");
			$this->Cell(18,0.4,trim($dadosContrato["DSOPERAD"]),0,1,"C",0,"");

			$this->Ln();			
			$this->Ln();			
			$this->Ln();			
			
			$this->Cell(18,0.4,"____________________________________________",0,1,"C",0,"");
			$this->Cell(18,0.4,trim($dadosContrato["NMRECOP1"]),0,1,"C",0,"");
			$this->Cell(18,0.4,trim($dadosContrato["NMRECOP2"]),0,1,"C",0,"");
		}
	}
	
?>