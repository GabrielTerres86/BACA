<? 
/*!
 * FONTE        : busca_identificadores.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 07/06/2011 
 * OBJETIVO     : Rotina para busca de identificadores
 */
?>
 
<?
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	// Guardo os parâmetos do POST em variáveis	
	$cdidenti = (isset($_POST['cdidenti'])) ? $_POST['cdidenti'] : 0;
	$nrregist = (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 30;
	$nriniseq = (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 1;

	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Cabecalho>";
	$xml .= "	    <Bo>b1wgen0059.p</Bo>";
	$xml .= "        <Proc>busca_crapcgp</Proc>";
	$xml .= "  </Cabecalho>";
	$xml .= "  <Dados>";
	$xml .= "       <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<cdidenti>".$cdidenti."</cdidenti>";
	$xml .= "		<nriniseq>".$nriniseq."</nriniseq>";
	$xml .= "		<nrregist>".$nrregist."</nrregist>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObj = getObjectXML($xmlResult);
	
	if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
		exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','estadoInicial();',false);
	}
	
	$registros = $xmlObj->roottag->tags[0]->tags;
	$guia      = $xmlObj->roottag->tags[0]->tags[0]->tags;
	$qtregist  = $xmlObj->roottag->tags[0]->attributes["QTREGIST"];

	
	if ($qtregist == 0) {
		exibirErro('error','Guia de Previdencia nao Cadastrada.','Alerta - Ayllos','estadoInicial();',false);
	} 
		
	include('tab_identificadores.php');

?>

<script>
	var qtde = '<? echo $qtregist ?>';
	
	if ( qtde == 1 ) {
		formataIdentificadores();
		selecionaIdentificador();
	} else {
		exibeRotina($('#divRotina'));
		formataIdentificadores();
	}
</script>