<?php
/*!
 * FONTE        : imprime_cartao_ass_pf_html.php
 * CRIAÇÃO      : Jean Michel
 * DATA CRIAÇÃO : 26/09/2013 
 * OBJETIVO     : Responsável por fazer a impressao do cartao assinatura de pessoa física.
 *
 * ALTERAÇÕES   :
 */	 
	require_once('../../../includes/funcoes.php');
	require_once('../../../class/xmlfile.php');
	
	$cdcooper =  $GLOBALS['cdcooper'];
	$nrdconta =  $GLOBALS['nrdconta'];
	
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
	$xmlTtl  = "";
	$xmlTtl .= "<Root>";
	$xmlTtl .= "	<Cabecalho>";
	$xmlTtl .= "		<Bo>b1wgen0063.p</Bo>";
	$xmlTtl .= "		<Proc>busca_titulares_impressao</Proc>";
	$xmlTtl .= "	</Cabecalho>";
	$xmlTtl .= "	<Dados>";
	$xmlTtl .= "    	<cdcooper>".$cdcooper."</cdcooper>";
	$xmlTtl .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlTtl .= "	</Dados>";
	$xmlTtl .= "</Root>";
	
	
	// Executa script para envio do XML
	$xmlResultTtl = getDataXML($xmlTtl);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjImpTtl = getObjectXML($xmlResultTtl);
	
	$registrosTtl = $xmlObjImpTtl->roottag->tags[0]->tags;
		
	$intQtdRegistros = 0;
	
	
	foreach($registrosTtl as $registroTtl){		
		$intQtdRegistros = $intQtdRegistros + 1;
	}
		
	if ($intQtdRegistros > 0){
	
		foreach($registrosTtl as $registroTtl){
		
			echo "<p>&nbsp;</p>";
			$GLOBALS['numPagina']++;
			$GLOBALS['numLinha'] = 0;
			echo "<pre>";
			escreveLinha("===========================================================================");			
			pulaLinha(1);
			escreveLinha("                          REGISTRO DE ASSINATURA");
			escreveLinha("                              Pessoa Fisica");
			pulaLinha(1);
			escreveLinha("===========================================================================");
			pulaLinha(2);
			escreveLinha("Filiada: ".getByTagName($registroTtl->tags,'nmrescop')."   PA: ".getByTagName($registroTtl->tags,'cdagenci')."     Conta Corrente: ".formataContaDVsimples(getByTagName($registroTtl->tags,'nrdconta'))."   Titular: ".getByTagName($registroTtl->tags,'idseqttl'));
			pulaLinha(1);
			escreveLinha("Nome: ".getByTagName($registroTtl->tags,'nmextttl')."    CPF: ".formatar(getByTagName($registroTtl->tags,'nrcpfcgc'),"cpf"));
			pulaLinha(1);
			escreveLinha("Assinaturas:");
			pulaLinha(2);
			escreveLinha(" ____________________________________");
			pulaLinha(2);
			escreveLinha("                                      ____________________________________");
			pulaLinha(2);
			escreveLinha(" ____________________________________");
			pulaLinha(3);
			escreveLinha("Observacoes:");		
			pulaLinha(1);
			escreveLinha("__________________________________________________________________________");
			pulaLinha(1);
			escreveLinha("__________________________________________________________________________");
			pulaLinha(1);
			escreveLinha("__________________________________________________________________________");
			pulaLinha(5);
			escreveLinha("        ___________________________________      _____/_____/________     ");
			escreveLinha("          Cadastro e Visto do Funcionario              Data");
			echo "</pre>";
		}
		
	}
	
?>