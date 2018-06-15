<?php
/*!
 * FONTE        : imp_declaracao_facta_crs_html.php
 * CRIACAO      : Rodrigo Costa (Mouts)
 * DATA CRIACAO : 19/04/2018 
 * OBJETIVO     : Responsavel por fazer a impressao do documento fatca crs.
 *
 * ALTERACOES   :
 */	 

	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");

    $nrdconta =  $GLOBALS['nrdconta'];
	$nrcpfcgc =  $GLOBALS['nrcpfcgc'];

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
	.textoJust
	{
	margin-left:70px;	
	width:430px;
	text-align:justify;
	font-family: monospace, "Courier New", Courier; 
    font-size:9pt;
	}
</style>

<?

    $xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "    <cdcooper>".$GLOBALS["cdcooper"]."</cdcooper>";
	$xml .= "    <nrdconta>".$nrdconta.           "</nrdconta>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	// Executa script para envio do XML
    $xmlResultTtl = mensageria($xml, "REL_DECLARACAO", "BUSCA_CIDADE", $GLOBALS["cdcooper"], $GLOBALS["cdagenci"], $GLOBALS["nrdcaixa"], $GLOBALS["idorigem"], $GLOBALS["cdoperad"], "</Root>");

	$xmlObjImpTtl = getObjectXML($xmlResultTtl);
		
	$registrosTtl = $xmlObjImpTtl->roottag->tags[0]->tags;

	foreach($registrosTtl as $registroTtl){
	    $nmcidade = getByTagName($registroTtl->tags,'nmcidade');
	}
	
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "    <nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
	$xml .= "    <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	// Executa script para envio do XML
    $xmlResultTtl = mensageria($xml, "REL_DECLARACAO", "BUSCA_DADOS_DECLARACAO", $GLOBALS["cdcooper"], $GLOBALS["cdagenci"], $GLOBALS["nrdcaixa"], $GLOBALS["idorigem"], $GLOBALS["cdoperad"], "</Root>");

	$xmlObjImpTtl = getObjectXML($xmlResultTtl);

	$registrosTtl = $xmlObjImpTtl->roottag->tags[0]->tags;
		
	$intQtdRegistros = 0;
	
	foreach($registrosTtl as $registroTtl){

		$dsendereco = getByTagName($registroTtl->tags,'dsendereco');
		$nmpessoa = getByTagName($registroTtl->tags,'nmpessoa');
		$dscidade = getByTagName($registroTtl->tags,'dscidade');
		$dsestado = getByTagName($registroTtl->tags,'dsestado');
		$nrcep = getByTagName($registroTtl->tags,'dscodigo_postal');
		$nmpais_reportavel = getByTagName($registroTtl->tags,'nmpais_reportavel');
		$inreportavel = getByTagName($registroTtl->tags,'inreportavel');

		// Caso o valor de inreportavel seja N então disparar erro e não mostrar o relatorio
		if ($inreportavel == 'N') {		
			?>
			<script type="text/javascript">
				alert("Pessoa nao faz parte de acordo FATCA ou CRS"); 
			</script>
			<?php
			exit();
		}

		$texto_dec = "<div class='textoJust'> Eu, [nmpessoa], titular / representante da conta [nrdconta], residente no endereco [dsendereco], [dscidade], [dsestado], [nrcep], ciente da existencia de obrigacoes internacionais para a troca de informacoes tributarias (FATCA/CRS), declaro possuir residencia/obrigacoes fiscais no(s) [nmpais_reportavel], e <b>AUTORIZO</b> que as informacoes de movimentacoes financeiras desta conta sejam reportadas para as autoridades competentes, haja vista existir(em) titular(es) com obrigacoes fiscais no exterior.
			<br/>
			<br/>
			Declaro, ainda, sob as penas da Lei, que as informacoes apresentadas para esta instituicao, inclusive o Numero de Identificacao Fiscal no exterior, sao veridicas, e que nao estou sujeito(a) a retencao de impostos, pois:
			<br/>
			<br/>
			a) <b>Realizo</b> a retencao quando necessario, bem como o recolhimento de todos os tributos incidentes sobre os valores movimentados na conta;
			<br/>
			<br/>
			b) Nao fui <b>notificado(a)</b> pela Receita Federal do [nmpais_reportavel] para realizar a retencoes de impostos; ou
			<br/>
			<br/>
			c) Existiu a notificacao pela Receita Federal do [nmpais_reportavel] sobre a nao incidencia de retencoes.
			<br/>
			<br/>
			Nada mais, firmo o presente, me comprometendo a informar a esta instituicao qualquer alteracao na minha situacao fiscal no Brasil ou em qualquer outro pais, ciente de que a falta da apresentacao de documentos ou de informacoes, bem como, sobre eventuais exigencias de retencoes de tributos, estao sob minha inteira responsabilidade administrativa, civil e criminal.</div>";
		
		$texto_dec = str_replace('[dsendereco]',$dsendereco,$texto_dec);
		$texto_dec = str_replace('[nmpessoa]',$nmpessoa,$texto_dec);
		$texto_dec = str_replace('[dscidade]',$dscidade,$texto_dec);
		$texto_dec = str_replace('[dsestado]',$dsestado,$texto_dec);
		$texto_dec = str_replace('[nrcep]',$nrcep,$texto_dec);
		$texto_dec = str_replace('[nmpais_reportavel]',$nmpais_reportavel,$texto_dec);
		$texto_dec = str_replace('[nrdconta]',$nrdconta,$texto_dec);

		pulaLinha(1);
		echo "<pre>";
		escreveLinha( preencheString('Declaracao de Obrigacao Fiscal no Exterior',76,' ','C') );
		echo "</pre>";

		pulaLinha(2);

		echo $texto_dec; 
		
		pulaLinha(5);
		$today = date("d/m/Y"); 
		echo "<pre>";
		escreveLinha($nmcidade.", ".$today);
		pulaLinha(5);
		escreveLinha("________________________________________");
		escreveLinha("      ".$nmpessoa);
		echo "</pre>";
	}
	
?>