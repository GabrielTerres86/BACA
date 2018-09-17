<?php
/*!
 * FONTE        : imprime_cartao_ass.php
 * CRIAÇÃO      : Jean Michel
 * DATA CRIAÇÃO : 23/07/2013
 * OBJETIVO     : Impressao de Cartao Assinatura
 *
 * ALTERACOES   : 
 */	 
	
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');	
	require_once('../../../class/xmlfile.php');
	
	isPostMethod();		
	
	$cdcooper = $glbvars['cdcooper'];
	$cdagenci = $glbvars['cdagenci'];
	$nrdcaixa = $glbvars['nrdcaixa'];
	$cdoperad = $glbvars['cdoperad'];
	$nmdatela = $glbvars['nmdatela'];
	$idorigem = $glbvars['idorigem'];
	$dtmvtolt = $glbvars['dtmvtolt'];
    $cddopcao = "C";
	
	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : "";
	$tppessoa = (isset($_POST['tppessoa'])) ? $_POST['tppessoa'] : 0;
	$nrcpfcgc = (isset($_POST['nrcpfcgc'])) ? $_POST['nrcpfcgc'] : 0;
	$nrdctato = (isset($_POST['nrdctato'])) ? $_POST['nrdctato'] : 0;
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : 0;
		
	$nmendter = session_id();
	
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0063.p</Bo>';
	$xml .= '		<Proc>Imprime_Assinatura</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$cdcooper.'</cdcooper>';
	$xml .= '		<cdagenci>'.$cdagenci.'</cdagenci>'; 
	$xml .= '		<nrdcaixa>'.$nrdcaixa.'</nrdcaixa>'; 
	$xml .= '		<cdoperad>'.$cdoperad.'</cdoperad>'; 
	$xml .= '		<nmdatela>'.$nmdatela.'</nmdatela>'; 
	$xml .= '		<idorigem>'.$idorigem.'</idorigem>'; 
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';
	$xml .= '		<dtmvtolt>'.$dtmvtolt.'</dtmvtolt>';
	$xml .= '       <nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '       <nrdctato>'.$nrdctato.'</nrdctato>';
	$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
	$xml .= '		<tppessoa>'.$tppessoa.'</tppessoa>'; 	
	$xml .= '		<nrcpfcgc>'.$nrcpfcgc.'</nrcpfcgc>';
	$xml .= '       <nmendter>'.$nmendter.'</nmendter>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);

	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
		
		$msgErro = 	$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		?>
		<script type="text/javascript">
			alert("<?php echo $msgErro; ?>"); 
		</script>
		<?php
		exit();
	}
	
	$nmarqimp = $xmlObjeto->roottag->tags[0]->attributes['NMARQIMP'];
	
	visualizaPDF($nmarqimp);
?>