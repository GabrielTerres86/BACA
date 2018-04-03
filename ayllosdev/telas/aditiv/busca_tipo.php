<? 
/*!
 * FONTE        : busca_tipo.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 28/09/2011 
 * OBJETIVO     : Rotina para busca dos tipos
 *
 * ALTERACOES   : 26/11/2012 - Ajustado erro fechamento if no tipo 5 (Daniel).
 *				  03/04/2013 - Correcao tratamento dos includes quando cdaditiv
 *				  igual a 5 (Daniel)					
 *
 *                01/11/2017 - Passagem do tpctrato. (Jaison/Marcos Martini - PRJ404)
 *
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
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0 ;
	$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : 0 ; 
	$nraditiv = (isset($_POST['nraditiv'])) ? $_POST['nraditiv'] : 0 ;
	$cdaditiv = (isset($_POST['cdaditiv'])) ? $_POST['cdaditiv'] : 0 ;
	$tpaplica = (isset($_POST['tpaplica'])) ? $_POST['tpaplica'] : '';
	$tpctrato = (isset($_POST['tpctrato'])) ? $_POST['tpctrato'] : 0;
	
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Cabecalho>";
	$xml .= "	    <Bo>b1wgen0115.p</Bo>";
	$xml .= "        <Proc>Busca_Dados</Proc>";
	$xml .= "  </Cabecalho>";
	$xml .= "  <Dados>";
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<dtmvtopr>'.$glbvars['dtmvtopr'].'</dtmvtopr>';
	$xml .= '		<inproces>'.$glbvars['inproces'].'</inproces>';
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';	
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';	
	$xml .= '		<nrctremp>'.$nrctremp.'</nrctremp>';	
	$xml .= '		<dtmvtolx>'.$dtmvtolx.'</dtmvtolx>';	
	$xml .= '		<nraditiv>'.$nraditiv.'</nraditiv>';	
	$xml .= '		<cdaditiv>'.$cdaditiv.'</cdaditiv>';
	$xml .= '		<tpaplica>'.$tpaplica.'</tpaplica>';
	$xml .= '		<nrctagar>'.$nrctagar.'</nrctagar>';
	$xml .= '		<tpctrato>'.$tpctrato.'</tpctrato>';
	$xml .= "  </Dados>";
	$xml .= "</Root>";	

	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObj = getObjectXML($xmlResult);
	
	if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
		exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','',false);
	}
	
	$registros 	= $xmlObj->roottag->tags[0]->tags;
	$dados 		= $xmlObj->roottag->tags[0]->tags[0]->tags;
	$aplicacao	= $xmlObj->roottag->tags[1]->tags;
	$cdaditiv 	= empty($cdaditiv) ? getByTagName($dados,'cdaditiv') : $cdaditiv;
	$regtotal	= count($registros);
	
	if ( $cdaditiv == 1 ) {
		include('form_tipo1.php');
		
	} else if ( $cdaditiv == 2 ) {
		if ( $cddopcao == 'I') {
			include('form_tipo2.php');
		} else {
			include('tab_tipo2.php');
		}
	} else if ( $cdaditiv == 3 ) {
		if ( $cddopcao == 'I') {
			include('form_tipo3.php');
		} else {
			include('tab_tipo3.php');
		}
	} else if ( $cdaditiv == 4 ) {
		include('form_tipo4.php');

	} else if ( $cdaditiv == 5 ) {
		if ( $cddopcao == 'X' ) {
			if (  $regtotal > 0 ){
				include('tab_tipo5.php');
			} 
		}else { 
				include('form_tipo5.php');
		}
	} else if ( $cdaditiv == 6 ) {
		include('form_tipo6.php');

	} else if ( $cdaditiv == 7 ) {
		include('form_tipo7.php');
		
	} else if ( $cdaditiv == 8 ) {
		include('form_tipo8.php');

	}	
	
?>

<script>
	regtotal = '<?php echo $regtotal ?>';
	cdaditiv = '<? echo $cdaditiv ?>';
	$("#cdaditiv option[value='<? echo $cdaditiv ?>']",'#frmCab').prop('selected',true);

	var i = 0;
	
	<?php
	// cria um array com os bens para 
	// verificar qual vai ser substituido na opcao I
	if ( $cddopcao == 'I' ) {
		foreach( $registros as $r ) { 
	?>
		var a = new Array();
	
		a['nrsequen'] = '<?php echo getByTagName($r->tags,'nrsequen') ?>'; 
		a['dsbemfin'] = '<?php echo getByTagName($r->tags,'dsbemfin') ?>'; 
		a['idseqbem'] = '<?php echo getByTagName($r->tags,'idseqbem') ?>'; 
		
		if ( a['idseqbem'] != '0' )  {
			arrayAditiv[i] = a; 
			i = i + 1;
		}
		
	<? 
		} // foreach( $registros as $r ) { 
	} // if ( $cddopcao == 'I' ) {
	?>		
</script>