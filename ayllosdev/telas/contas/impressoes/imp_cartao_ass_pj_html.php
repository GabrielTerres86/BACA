<?
/*!
 * FONTE        : imprime_cartao_ass_pj_html.php
 * CRIAÇÃO      : Jean Michel
 * DATA CRIAÇÃO : 01/10/2013 
 * OBJETIVO     : Responsável por fazer a impressao do cartao assinatura de pessoa juridica.
 *
 * ALTERAÇÕES   : 17/10/2013 - Inclusão de tratamento de erro (Jean Michel)
 *			
 *				  02/06/2014 - Ajuste para pegar poderes conforme cpf do procurador.
 *							   (Jorge/Rosangela) - SD 155408
 *                
 *                05/11/2015 - Inclusão de novo Poder, PRJ. 131 - Ass. Conjunta (Jean Michel) 
 *			  
 *				  07/12/2017 - Realizado ajuste onde o relatório completo para contas menores de idade
 *							   com dois responsaveis legais sem conta na viacredi não estava abrindo. 
 *							   SD 802764. (Kelvin)
 */	 

	require_once('../../../includes/funcoes.php');
	require_once('../../../class/xmlfile.php');

	$arrpoder = array(1 => "Emitir Cheques", 2 =>  "Endossar Cheques",  
                    3 => "Autorizar Debitos", 4 => "Requisitar Taloes",
                    5 => "Assinar Contratos de Emprst/Financ",
					6 => "Substabelecer", 7 => "Receber", 8 => "Passar Recibo",
                    10 => "Assinar Operacao Autoatendimento", 9 => "Outros Poderes");

?>

<style type="text/css">
	pre, b { 
		font-family: monospace, "Courier New", Courier; 
		font-size:9pt;
	}
	p {
		 page-break-before: always;
		 padding: 0px;
		 margin:0px;	
	}
</style>

<?php
	
	// Monta o xml de requisição
	$xmlAvt  = "";
	$xmlAvt .= "<Root>";
	$xmlAvt .= "	<Cabecalho>";
	$xmlAvt .= "		<Bo>b1wgen0063.p</Bo>";
	$xmlAvt .= "		<Proc>busca_procuradores_impressao</Proc>";
	$xmlAvt .= "	</Cabecalho>";
	$xmlAvt .= "	<Dados>";
	$xmlAvt .= "    	<cdcooper>".$cdcooper."</cdcooper>";
	$xmlAvt .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlAvt .= "		<cdagenci>".$cdagenci."</cdagenci>";
	$xmlAvt .= "		<nrdcaixa>".$nrdcaixa."</nrdcaixa>";
	$xmlAvt .= "	</Dados>";
	$xmlAvt .= "</Root>";
	
	
	// Executa script para envio do XML
	$xmlResultAvt = getDataXML($xmlAvt);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjImpAvt = getObjectXML($xmlResultAvt);
	
	if (strtoupper($xmlObjImpAvt->roottag->tags[0]->name) == 'ERRO') {
		
		$msgErro = 	$xmlObjImpAvt->roottag->tags[0]->tags[0]->tags[4]->cdata;
		?>
		<script type="text/javascript">
			alert("<?php echo $msgErro; ?>"); 
		</script>
		<?php
		exit();
	}
	
	$registrosAvt = $xmlObjImpAvt->roottag->tags[0]->tags;
	$regPoderes   = $xmlObjImpAvt->roottag->tags[1]->tags;
		
	$intQtdRegistros = 0;
	
	$nrdctaprt = 0;
	
	foreach($registrosAvt as $registroAvt){		
		$intQtdRegistros = $intQtdRegistros + 1;
	}
		
	if ($intQtdRegistros > 0){
	
		foreach($registrosAvt as $registroAvt){		
		
			if (getByTagName($registroAvt->tags,'nrdconta') <> "")
				$nrdctaprt = formataContaDVsimples(getByTagName($registroAvt->tags,'nrdconta'));
			
			echo "<p>&nbsp;</p>";	
			$GLOBALS['numPagina']++;
			$GLOBALS['numLinha'] = 0;	
			echo "<pre>";	
			escreveLinha("==========================================================================");
			escreveLinha("                        REGISTRO DE ASSINATURA");
			escreveLinha("                   Pessoa Juridica e/ou Procurador");
			escreveLinha("==========================================================================");
			pulaLinha(1);
			escreveLinha("FILIADA: ".getByTagName($registroAvt->tags,'nmrescop')."     PA: ".getByTagName($registroAvt->tags,'cdagenci')."     Conta: ".$nrdctaprt."     Titular:".getByTagName($registroAvt->tags,'idseqttl'));
			escreveLinha("CPF/CNPJ: ".getByTagName($registroAvt->tags,'nrcpfcgc'));
			escreveLinha("Outorgante(titular da conta ou razao social):".getByTagName($registroAvt->tags,'nmtitula'));
			escreveLinha("CPF: ".getByTagName($registroAvt->tags,'nrcpfpro')."    Outorgado: ".getByTagName($registroAvt->tags,'nmprocur'));
			escreveLinha("Telefone: ".getByTagName($registroAvt->tags,'nrtelefo')." Funcao: ".getByTagName($registroAvt->tags,'dsfuncao'));
			pulaLinha(1);
			escreveLinha("Assinaturas:");
			pulaLinha(1);
			escreveLinha("   ______________________________");
			pulaLinha(1);
			escreveLinha("                                           ______________________________");
			pulaLinha(1);
			escreveLinha("   ______________________________");
			pulaLinha(1);
			escreveLinha("Poderes (C= em conjunto, I= isolado)");
			pulaLinha(1);
			escreveLinha("Descricao do Poder                                      C       I");
			pulaLinha(1);
			
			foreach($regPoderes as $poder ) {
					
				if((getByTagName($poder->tags,'nrdctato') == getByTagName($registroAvt->tags,'nrdctato')) and
				   (getByTagName($poder->tags,'nrcpfcgc') == getByTagName($registroAvt->tags,'nrcpfpro'))){
				
					if(getByTagName($poder->tags,'codpoder') != 9){
					
						$linha = "".
						
						$linha = preencheString($arrpoder[getByTagName($poder->tags,'codpoder')], 55);
						$linha .= preencheString(getByTagName($poder->tags,'flgconju'), 8);
						$linha .= preencheString(getByTagName($poder->tags,'flgisola'), 4);
						
						escreveLinha($linha);
					}else{
						
						$arrdspod = explode("#", getByTagName($poder->tags,'dsoutpod'));

					}				
				}			
			}
			
			pulaLinha(1);
			escreveLinha("==========================================================================");
			escreveLinha("                          Dados do Instrumento de Mandato");
			escreveLinha("==========================================================================");
			pulaLinha(1);
			escreveLinha("Tipo:________________________ Tabeliao:________________________________");
			pulaLinha(1);
			escreveLinha("Municipio:_________________________________________ UF:_______");
			pulaLinha(1);
			escreveLinha("N do Registro:____________ N do Livro:______ N da Folha:______");
			pulaLinha(1);
			escreveLinha("Data do Instrumento:___/___/_____ Prazo do mandato: ".getByTagName($registroAvt->tags,'dtvencim'));
			pulaLinha(1);
			escreveLinha("Assina em conjunto: _________________________________________________");
			pulaLinha(1);
			escreveLinha("Outros Poderes:");
			$dscbranc = "     - ";
			escreveLinha($dscbranc.$arrdspod[0]);
			escreveLinha($dscbranc.$arrdspod[1]);
			escreveLinha($dscbranc.$arrdspod[2]);
			escreveLinha($dscbranc.$arrdspod[3]);
			escreveLinha($dscbranc.$arrdspod[4]);
			pulaLinha(1);				
			escreveLinha("Quaisquer alteracoes relativas ao uso das assinaturas aqui autorizadas");
			escreveLinha("serao imediatamente comunicadas, ficando a Cooperativa inteiramente isenta");
			escreveLinha("de responsabilidade pelos prejuizos que possam ocorrer em virtude do");
			escreveLinha("nao-cumprimento dessa providencia no devido tempo.");
			pulaLinha(3);
			escreveLinha("              ________________________________________________");
			escreveLinha("                          Assinatura do outorgante");
			
			escreveLinha("__________________________________________________________________________");
			escreveLinha("Abono das firmas lancadas no presente cartao.");
			pulaLinha(3);
			escreveLinha("   ________________________________________   Data: ____/____/________   ");
			escreveLinha("       Cadastro e Visto do Funcionario");
			echo "</pre>";
			
		}

	}
	
?>
