<?
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 28/11/2012
 * OBJETIVO     : Capturar dados para tela CONINF
 * --------------
 * ALTERAÇÕES   :  06/05/2016 - Ajustes nas permissões da tela onde se estava passando o parâmetro
								de opção fixo. Ajuste feito para finalizar o chamado 441753. (Kelvin)
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
		
	// Recebe o POST
	$cddopcao	= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : ''  ;
	$dsiduser	= (isset($_POST['dsiduser'])) ? $_POST['dsiduser'] : ''  ;
	$cdcoopea	= (isset($_POST['cdcoopea'])) ? $_POST['cdcoopea'] : 0  ;
	$cdagenca	= (isset($_POST['cdagenca'])) ? $_POST['cdagenca'] : 0  ;
	$tpdocmto	= (isset($_POST['tpdocmto'])) ? $_POST['tpdocmto'] : 0  ;
	$indespac	= (isset($_POST['indespac'])) ? $_POST['indespac'] : ''  ;
	$cdfornec	= (isset($_POST['cdfornec'])) ? $_POST['cdfornec'] : ''  ;
	$dtmvtola	= (isset($_POST['dtmvtola'])) ? $_POST['dtmvtola'] : ''  ;
	$dtmvtol2	= (isset($_POST['dtmvtol2'])) ? $_POST['dtmvtol2'] : ''  ;
	$tpdsaida	= (isset($_POST['tpdsaida'])) ? $_POST['tpdsaida'] : ''  ;
	$nrregist	= (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 0  ;
	$nriniseq	= (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 0  ;
	
	$cdcoopea	= ($cdcoopea == 'null') ? 0 : $cdcoopea  ;	
	$tpdocmto	= ($tpdocmto == 'null') ? 0 : $tpdocmto  ;		
			
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'@')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	switch ($cddopcao) {
		case '' : $procedure = 'Carrega_Tela'; break;
		case 'C': $procedure = 'Busca_Dados' ; break;
		default : $procedure = 'Carrega_Tela'; break;			
	}
	
	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0142.p</Bo>';
	$xml .= '		<Proc>'.$procedure.'</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '       <cddopcao>'.$cddopcao.'</cddopcao>';
	$xml .= '       <dsiduser>'.$dsiduser.'</dsiduser>';
	$xml .= '       <cdcoopea>'.$cdcoopea.'</cdcoopea>';
	$xml .= '       <cdagenca>'.$cdagenca.'</cdagenca>';
	$xml .= '       <tpdocmto>'.$tpdocmto.'</tpdocmto>';
	$xml .= '       <indespac>'.$indespac.'</indespac>';
	$xml .= '       <cdfornec>'.$cdfornec.'</cdfornec>';
	$xml .= '       <dtmvtola>'.$dtmvtola.'</dtmvtola>';
	$xml .= '       <dtmvtol2>'.$dtmvtol2.'</dtmvtol2>';
	$xml .= '       <tpdsaida>'.$tpdsaida.'</tpdsaida>';
	$xml .= '       <nrregist>2'.$nrregist.'</nrregist>';
	$xml .= '       <nriniseq>'.$nriniseq.'</nriniseq>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult 	= getDataXML($xml);
	$xmlObjeto 	= getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;								
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);		
	} 
	
	$dsdircop = $xmlObjeto->roottag->tags[0]->attributes["DSDIRCOP"];
	
	$cooperativas = $xmlObjeto->roottag->tags[0]->tags;
	$documentos   = $xmlObjeto->roottag->tags[1]->tags;
	
	include('form_cabecalho.php');
		
		
?>

<script>
	
	cdcooper = "<? echo $glbvars['cdcooper'];?>";
	dsdircop = "<? echo $dsdircop;?>";
		
	formataCabecalho();
	//controlaLayout();
</script>