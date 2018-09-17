<?
/*!
 * FONTE        : busca_cheque.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 11/05/2011
 * OBJETIVO     : Realiza a pesquisa dos cheques da conta informada
 * --------------
 * ALTERAÇÕES   : 06/08/2014 - Conversão Progress >> Oracle ( Renato - Supero )

				  18/11/2017 - Retirado envio de parametros, não serão usados (Jonata - RKAM P364).
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
	
	// Verifica permissões de acessa a tela
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> '') exibirErro('error',$msgError,'Alerta - Ayllos','',false);	
	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '';	
	$nrtipoop = (isset($_POST['nrtipoop'])) ? $_POST['nrtipoop'] : '';	
	$nrcheque = (isset($_POST['nrcheque'])) ? $_POST['nrcheque'] : 0;	
	$nriniseq = (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 0;	
	$nrregist = (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 0;	
	$execimpe = (isset($_POST['execimpe'])) ? $_POST['execimpe'] : 0;	
	$tppeschq = (isset($_POST['tppeschq'])) ? $_POST['tppeschq'] : 0;	
	
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inválida.','Alerta - Ayllos','',false);
	if (!validaInteiro($idseqttl)) exibirErro('error','Titular inválido.','Alerta - Ayllos','',false);
	if (!validaInteiro($nrtipoop)) exibirErro('error','Titular inválido.','Alerta - Ayllos','',false);
	if (!validaInteiro($nrcheque)) exibirErro('error','Nr. Cheque inválido.','Alerta - Ayllos','',false);
	if (!validaInteiro($nriniseq)) exibirErro('error','Nr. Inicial para pagináção inválido.','Alerta - Ayllos','',false);
	if (!validaInteiro($nrregist)) exibirErro('error','Qtde. Registros para paginação inválido.','Alerta - Ayllos','',false);
	else if ($nrregist > 100) exibirErro('error','Qtde. Registros para paginacao nao pode ultrapassar 100.','Alerta - Ayllos','$(\'#nrregist\',\'#frmTipoCheque\').focus(); $(\'#nrregist\',\'#frmTipoCheque\').val(\'100\');',false);

	$xml  = "";
	$xml .= "<Root>";
	//$xml .= "	<Cabecalho>";
	//$xml .= "		<Bo>b1wgen0040.p</Bo>";
	//$xml .= "		<Proc>busca-cheques</Proc>";
	//$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
    $xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<idseqttl>".$idseqttl."</idseqttl>";
	$xml .= "		<nrtipoop>".$nrtipoop."</nrtipoop>";
	$xml .= "		<nrcheque>".$nrcheque."</nrcheque>";
	$xml .= "		<nriniseq>".$nriniseq."</nriniseq>";
	$xml .= "		<nrregist>".$nrregist."</nrregist>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	//$xmlResult 	= getDataXML($xml);
	$xmlResult = mensageria($xml, "CHEQUE", "BUSCACHQ", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObjeto 	= getObjectXML($xmlResult);		

	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;			
		exibirErro('error',$msgErro,'Alerta - Ayllos','$(\'#nrregist\',\'#frmTipoCheque\').focus();', false);
	} 
		
	$registros = $xmlObjeto->roottag->tags[0]->tags;
	
	// Quantidade total de cooperados na pesquisa
	$qtregist = $xmlObjeto->roottag->tags[0]->attributes["QTREGIST"]; 			
	
	include 'tabela_cheque.php';
?>
<script type="text/javascript">
	formataTabela();	
</script>