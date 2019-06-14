<?
/*!
 * FONTE        : busca_regional.php				Última alteração: 27/11/2015
 * CRIAÇÃO      : Jéssica - DB1
 * DATA CRIAÇÃO : 19/09/2015
 * OBJETIVO     : Rotina para buscar os dados de regionais da tela CADREG
 * --------------
 * ALTERAÇÕES   :  27/11/2015 - Ajuste decorrente a homologação de conversão realizada pela DB1
                                (Adriano). 
 * --------------
 */
?>
<?
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();

	$retornoAposErro = '';
	
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
	$nriniseq = (isset($_POST["nriniseq"])) ? $_POST["nriniseq"] : 1;
	$nrregist = (isset($_POST["nrregist"])) ? $_POST["nrregist"] : 30;
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
	$flgerlog = (isset($_POST["flgerlog"])) ? $_POST["flgerlog"] : 0;

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Dados>";
	$xml .= "       <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xml .= "		<cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "		<flgerlog>".$flgerlog."</flgerlog>";
	$xml .= "		<nriniseq>".$nriniseq."</nriniseq>";
	$xml .= "		<nrregist>".$nrregist."</nrregist>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";

	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "CADREG", "BUSCACRAPREG", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);
		
	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}
		
	$registros 	= $xmlObjeto->roottag->tags;
	$qtregist   = $xmlObjeto->roottag->attributes["QTREGIST"];
	
	include('tab_regional.php');
?>

<script text="text/javascript">

	$('a.paginacaoAnt').unbind('click').bind('click', function() {

		buscaRegional(<? echo ($nriniseq - $nrregist)?>,<?php echo $nrregist?>);

	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		
		buscaRegional(<? echo ($nriniseq + $nrregist)?>,<?php echo $nrregist?>);
		
	});		
	
	formataTabela();
	controlaLayout();
	
</script>