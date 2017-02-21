<?php
	/*!
	 * FONTE        : custodia_pdf.php
	 * CRIA��O      : Douglas Quisinski
	 * DATA CRIA��O : 13/05/2015
	 * OBJETIVO     : Gera��o do PDF com as informa��es de cust�dia que est�o em tela
	 * --------------
	 * ALTERA��ES   : 
	 * -------------- 
	 */		

	session_start();
		
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"I",false)) <> "") {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Classe para gera��o de arquivos PDF
	require("../../class/fpdf/fpdf.php");

	$pdf = new FPDF();
	$pdf->AddPage();

	adicionaCabecalhoRelatorio($pdf,$glbvars);
	geraCabecalhoTabela($pdf);
	processaCheques($pdf);
	finalizaRelatorio($pdf);
	
	/**
	 * Gera o cabe�alho para o relat�rio
	 */
	function adicionaCabecalhoRelatorio($pdf,$global){
		$pdf->SetFont('Arial','B',15);
		$pdf->Cell(185,0, 'Cust�dia de Cheques - CECRED', 0, 1, 'C');
		$pdf->Ln(5);

		$pdf->SetFont('Arial','B',12);
		$pdf->Cell(185,0, "Cooperativa: " . strtoupper($global["nmcooper"]), 0, 0, 'L');
		$pdf->Ln(5);
		
		$pdf->Cell(185,0,'Data da Cust�dia: ' . $global["dtmvtolt"], 0, 0, 'L');
		$pdf->Ln(5);
		
		$pdf->Cell(185,0,'Conta: ' . $_POST["nrdconta"] . '  -  ' . $_POST["nmprimtl"], 0, 0, 'L');
		$pdf->Ln(10);
	}
	
	/**
	 * Adiciona uma nova p�gina ao relat�rio
	 */
	function adicionaNovaPagina($pdf){
		$pdf->AddPage();
		// Quando imprimir uma nova p�gina, deve imprimir novamente o cabe�alho
		geraCabecalhoTabela($pdf);
	}
	
	/**
	 * Gera o cabe�alho para os cheques que foram custodiados
	 */
	function geraCabecalhoTabela($pdf){
		$pdf->SetFont('Arial','',10);
		// Imprime a linha de cabe�alho
		$pdf->Cell(21,0,'Data Boa', 0, 0, 'L');
		$pdf->Cell(24,0,'Valor',    0, 0, 'R');
		$pdf->Cell(12,0,'Banco',    0, 0, 'C');
		$pdf->Cell(16,0,'Ag�ncia',  0, 0, 'C');
		$pdf->Cell(17,0,'Cheque',   0, 0, 'R');
		$pdf->Cell(25,0,'Conta',    0, 0, 'R');
		$pdf->Cell(70,0,'CMC-7',    0, 0, 'R');
		$pdf->Ln(2); // Linha de espa�amento

		// Define a cor para gerar a linha abaixo da linha de cabe�alho
		$pdf->SetFillColor(0,0,0);
		// Imprime a linha
		$pdf->Cell(20,0.2,"",0,0,"",1,""); $pdf->Cell(1,0.2,"",0,0,"",0,"");
		$pdf->Cell(23,0.2,"",0,0,"",1,""); $pdf->Cell(1,0.2,"",0,0,"",0,"");
		$pdf->Cell(11,0.2,"",0,0,"",1,""); $pdf->Cell(1,0.2,"",0,0,"",0,"");
		$pdf->Cell(15,0.2,"",0,0,"",1,""); $pdf->Cell(1,0.2,"",0,0,"",0,"");
		$pdf->Cell(16,0.2,"",0,0,"",1,""); $pdf->Cell(1,0.2,"",0,0,"",0,"");
		$pdf->Cell(24,0.2,"",0,0,"",1,""); $pdf->Cell(1,0.2,"",0,0,"",0,"");
		$pdf->Cell(70,0.2,"",0,0,"",1,"");
		$pdf->Ln(3); // Linha de espa�amento
	}
	
	/**
	 * Processa os dados dos cheques que vieram pelo $_POST 
	 * e gera imprime as linhas, al�m de controlar a pagina��o dos cheques
	 */
	function processaCheques($pdf){
		//Controle de pagina��o
		$bFirstPage = true;
		$qtdInPage  = 0;
		$qtdTotal   = 0;
		$vlTotal    = 0;

		// Todas as informa��es do cheque vem separadas por ";" e os cheques por "|"
		$aCheques = explode("|",$_POST["dscheque"]);

		foreach($aCheques as $cheque){
			// Na primeira p�gina a quantidade de cheques � menor que as demais
			if( $bFirstPage ){
				$qtdMax = 60;
			} else {
				$qtdMax = 66;
			}

			// Verifica se deve ser adicionada uma nova p�gina
			if( $qtdInPage >= $qtdMax ){
				adicionaNovaPagina($pdf);
				$bFirstPage = false;
				$qtdInPage = 0;
			}
			// Separa a informacao dos campo
			$aDados = explode(";",$cheque);
			imprimeLinha($pdf,$aDados);
			$qtdInPage++;
			
			// Totalizar a quantidade e o valor dos cheques
			$qtdTotal++;
			$vlTotal += floatval($aDados[1]);
		}
		
		// Define a cor para gerar a linha abaixo da linha de cabe�alho
		$pdf->SetFillColor(0,0,0);
		// Imprime a linha Tracejada
		$pdf->Cell(185,0.2,"",0,0,"",1,"");
		$pdf->Ln(3); 
		$pdf->SetFont('Arial','',11);
		// Imprime a linha de cabe�alho
		$pdf->Cell(185,0,"Quantidade de Cheques Custodiados: " . $qtdTotal . ". Valor Total: R$ " . number_format($vlTotal,2,',','.'), 0, 0, 'C');
		$pdf->Ln(4); // Linha de espa�amento
	}
	
	/**
	 * Define o tamanho de cada campo na linha e imprime as informa��es
	 */
	function imprimeLinha($pdf,$aDados){
		$pdf->SetFont('Arial','',10);
		// Imprime a linha de cabe�alho
		$pdf->Cell(21,0,$aDados[0], 0, 0, 'L');
		$pdf->Cell(24,0,number_format($aDados[1],2,',','.'), 0, 0, 'R');
		$pdf->Cell(12,0,$aDados[2], 0, 0, 'C');
		$pdf->Cell(16,0,$aDados[3], 0, 0, 'C');
		$pdf->Cell(17,0,$aDados[4], 0, 0, 'R');
		$pdf->Cell(25,0,$aDados[5], 0, 0, 'R');
		$pdf->Cell(70,0,$aDados[6], 0, 0, 'R');
		$pdf->Ln(4); // Linha de espa�amento
	}
	
	/**
	 * Finaliza o relat�rio gerando o download do PDF
	 */
	function finalizaRelatorio($pdf){
		// Verifica Navegador para imprimir
		$navegador = CheckNavigator();
		$tipo = $navegador['navegador'] == 'chrome' ? "I" : "D";
		// Gera sa�da do PDF para o Browser
		$pdf->Output("custodia_cheque.pdf",$tipo);
	}
?>