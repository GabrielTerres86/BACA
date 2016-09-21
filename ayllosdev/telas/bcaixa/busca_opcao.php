<?php
/*!
 * FONTE        : busca_opcao.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 01/11/2011 
 * OBJETIVO     : Rotina para busca 
 *
 * 16/04/2013 - Incluir parametro tpcaicof na Busca_Dados (Lucas R.)
 * 28/08/2013 - Incluido o parametro dtrefere na procedure Busca_Dados (Carlos)
 * 27/07/2016 - Correcao no tratamento do retorno XML. SD 479874 (Carlos R.)
 */

	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	// Guardo os parâmetos do POST em variáveis	
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
	$dtrefere = $dtmvtolt = (isset($_POST['dtmvtolt'])) ? $_POST['dtmvtolt'] : '';
	$cdagenci = (isset($_POST['cdagenci'])) ? $_POST['cdagenci'] : 0 ; 
	$nrdcaixa = (isset($_POST['nrdcaixa'])) ? $_POST['nrdcaixa'] : 0 ;
	$cdopecxa = (isset($_POST['cdopecxa'])) ? $_POST['cdopecxa'] : '';
	$cdoplanc = (isset($_POST['cdoplanc'])) ? $_POST['cdoplanc'] : '';
	$tpcaicof = (isset($_POST['tpcaicof'])) ? $_POST['tpcaicof'] : '';
	$dsiduser = (isset($_POST['dsiduser'])) ? $_POST['dsiduser'] : '';
	$cdprogra = ( isset($glbvars['cdprogra']) ) ? $glbvars['cdprogra'] : 0;

	$auxiliar = $cddopcao.$cdoplanc;

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}	
	
	if ( $auxiliar != 'L' ) {	
	
		// Monta o xml de requisição
		$xml  = "";
		$xml .= "<Root>";
		$xml .= "  <Cabecalho>";
		$xml .= "	    <Bo>b1wgen0120.p</Bo>";
		$xml .= "        <Proc>Busca_Dados</Proc>";
		$xml .= "  </Cabecalho>";
		$xml .= "  <Dados>";
		$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
		$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
		$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
		$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
		$xml .= '		<cdprogra>'.$cdprogra.'</cdprogra>';
		$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
		$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
		$xml .= '		<dtmvtopr>'.$glbvars['dtmvtopr'].'</dtmvtopr>';
		$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
		$xml .= '		<dsiduser>'.$dsiduser.'</dsiduser>';	
		$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';	
		$xml .= '		<cdopecxa>'.$cdopecxa.'</cdopecxa>';	
		$xml .= '		<dtmvtolx>'.$dtmvtolt.'</dtmvtolx>';	
		$xml .= '		<cdagencx>'.$cdagenci.'</cdagencx>';	
		$xml .= '		<nrdcaixx>'.$nrdcaixa.'</nrdcaixx>';
		$xml .= '		<dtrefere>'.$dtrefere.'</dtrefere>';
		$xml .= '		<cdoplanc>'.$cdoplanc.'</cdoplanc>';
		$xml .= '       <tpcaicof>'.$tpcaicof.'</tpcaicof>';
		$xml .= "  </Dados>";
		$xml .= "</Root>";	
		
		// Executa script para envio do XML
		$xmlResult = getDataXML($xml);
		
		// Cria objeto para classe de tratamento de XML
		$xmlObj = getObjectXML($xmlResult);
		
		if ( isset($xmlObj->roottag->tags[0]->name) && strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
			exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','',false);
		}

		$boletimcx 	= ( isset($xmlObj->roottag->tags[0]->tags) ) ? $xmlObj->roottag->tags[0]->tags : array();
		$lanctos	= ( isset($xmlObj->roottag->tags[1]->tags) ) ? $xmlObj->roottag->tags[1]->tags : array();
		$crapbcx	= ( isset($xmlObj->roottag->tags[2]->tags) ) ? $xmlObj->roottag->tags[2]->tags : array();
		$msgretor 	= ( isset($xmlObj->roottag->tags[0]->attributes['MSGRETOR']) ) ? $xmlObj->roottag->tags[0]->attributes['MSGRETOR'] : ''; // opcao K
		$saldot   	= ( isset($xmlObj->roottag->tags[0]->attributes['SALDOT']) ) ? $xmlObj->roottag->tags[0]->attributes['SALDOT'] : 0;

	}			
	
	if ( $cddopcao == 'C' ) {
		include('tab_opcaoC.php');
		
	} else if ( ($cddopcao == 'L' or $cddopcao == 'K') and $cdoplanc == 'C' ) {
		include('tab_opcaoLK.php');
	
	} else if ( $cddopcao == 'L' or $cddopcao == 'K' ) {
		include('form_opcaoLK.php');
	
	} else if ( $cddopcao == 'S' ) {
		include('tab_opcaoS.php');

	} else if ( $cddopcao == 'T' ) { 
		include('tab_opcaoT.php');

	}
?>
<script>
msgretor = '<?php echo $msgretor; ?>';
</script>