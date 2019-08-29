<? 
/*!
 * FONTE        : busca_opcao.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 01/11/2011 
 * OBJETIVO     : Rotina para busca 
 *
 * 16/04/2013 - Incluir parametro tpcaicof na Busca_Dados (Lucas R.)
 * 28/08/2013 - Incluido o parametro dtrefere na procedure Busca_Dados (Carlos)
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
	$dtrefere = $dtmvtolt = (isset($_POST['dtmvtolt'])) ? $_POST['dtmvtolt'] : '';
	$cdagenci = (isset($_POST['cdagenci'])) ? $_POST['cdagenci'] : 0 ; 
	$nrdcaixa = (isset($_POST['nrdcaixa'])) ? $_POST['nrdcaixa'] : 0 ;
	$cdopecxa = (isset($_POST['cdopecxa'])) ? $_POST['cdopecxa'] : '';
	$cdoplanc = (isset($_POST['cdoplanc'])) ? $_POST['cdoplanc'] : '';
	$tpcaicof = (isset($_POST['tpcaicof'])) ? $_POST['tpcaicof'] : '';
	
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
		$xml .= '		<cdprogra>'.$glbvars['cdprogra'].'</cdprogra>';
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
		
		if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
			exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','',false);
		}

		$boletimcx 	= $xmlObj->roottag->tags[0]->tags;
		$lanctos	= $xmlObj->roottag->tags[1]->tags;
		$crapbcx	= $xmlObj->roottag->tags[2]->tags;
		$msgretor 	= $xmlObj->roottag->tags[0]->attributes['MSGRETOR']; // opcao K
		$saldot   	= $xmlObj->roottag->tags[0]->attributes['SALDOT'];

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
msgretor = '<? echo $msgretor ?>';
</script>