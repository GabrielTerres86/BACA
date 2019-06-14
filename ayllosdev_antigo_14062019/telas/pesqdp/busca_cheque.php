<? 
/*!
 * FONTE        : busca_cheque.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 11/01/2013
 * OBJETIVO     : Rotina para buscar cheques - PESQDP
 * --------------
 * ALTERAÇÕES   : 16/06/2014 - Adicionado campo cdagedst. (Reinert)
 *				  14/08/2015 - Removidos todos os campos da tela menos os campos
 *							   Data do Deposito e Valor do cheque. Adicionado novos campos
 *							   para filtro, numero de conta e numero de cheque, conforme
 *							   solicitado na melhoria 300189 (Kelvin).
 *
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

	// Inicializa
	$procedure 		= '';
	$retornoAposErro= '';
	

	// Recebe a operação que está sendo realizada
	$cddopcao	= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ;
	$dtmvtola	= (isset($_POST['dtmvtola'])) ? $_POST['dtmvtola'] : '' ;
	$tipocons	= (isset($_POST['tipocons'])) ? $_POST['tipocons'] : '' ;
	$vlcheque	= (isset($_POST['vlcheque'])) ? $_POST['vlcheque'] : 0  ;
	$dsdocmc7	= (isset($_POST['dsdocmc7'])) ? $_POST['dsdocmc7'] : '' ;
	$nrcampo1	= (isset($_POST['nrcampo1'])) ? $_POST['nrcampo1'] : 0  ;
	$nrcampo2	= (isset($_POST['nrcampo2'])) ? $_POST['nrcampo2'] : '' ;
	$nrcampo3	= (isset($_POST['nrcampo3'])) ? $_POST['nrcampo3'] : '' ;
	$nrdconta	= (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0 	;
	$nrcheque   = (isset($_POST['nrcheque'])) ? $_POST['nrcheque'] : 0 	;
	$nmprimtl	= (isset($_POST['nmprimtl'])) ? $_POST['nmprimtl'] : '' ;
	$cdagenci	= (isset($_POST['cdagenci'])) ? $_POST['cdagenci'] : 0 	;
	$nmextage	= (isset($_POST['nmextage'])) ? $_POST['nmextage'] : '' ;
	$cdagedst	= (isset($_POST['cdagedst'])) ? $_POST['cdagedst'] : 0  ;
	
	$dtmvtfim	= (isset($_POST['dtmvtfim'])) ? $_POST['dtmvtfim'] : '' ;
	$cdbccxlt	= (isset($_POST['cdbccxlt'])) ? $_POST['cdbccxlt'] : '' ;
	$nrregist	= (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 0  ;
	$nriniseq	= (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 0  ;
	
    $cddopcao	= ($cddopcao == 'null') ? '' : $cddopcao  ;	
	$tipocons	= ($tipocons == 'null') ? '' : $tipocons  ;		
	$cdbccxlt	= ($cdbccxlt == 'null') ? '' : $cdbccxlt  ;		
	
	
	// if ( $qtdeExtemp == '0' ) {
	$retornoAposErro = 'estadoInicial();';
	// } else {
		// $retornoAposErro = 'estadoExtrato();';
	// }
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0144.p</Bo>';
	$xml .= '		<Proc>Busca_Dados</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '       <dtmvtola>'.$dtmvtola.'</dtmvtola>';
	$xml .= '       <tipocons>'.'V'.'</tipocons>';
	$xml .= '       <vlcheque>'.$vlcheque.'</vlcheque>';
	$xml .= '       <nrcheque>'.$nrcheque.'</nrcheque>';
	$xml .= '       <nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '       <nrcampo1>'.$nrcampo1.'</nrcampo1>';
	$xml .= '       <nrcampo2>'.$nrcampo2.'</nrcampo2>';
	$xml .= '       <nrcampo3>'.$nrcampo3.'</nrcampo3>';
	$xml .= '       <nrregist>'.$nrregist.'</nrregist>';
	$xml .= '       <nriniseq>'.$nriniseq.'</nriniseq>';
	$xml .= '       <dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '       <cdagedst>'.$cdagedst.'</cdagedst>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	$xmlResult = getDataXML($xml);
	
	$xmlObjeto = getObjectXML($xmlResult);
	
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	

		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo	= $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];	
		$mtdErro    = '';
		if (!empty($nmdcampo)) 
		   { 
            if (($tipocons == 'C') && (trim($nmdcampo == '1') || trim($nmdcampo == '2') || trim($nmdcampo == '3')))
		       {$mtdErro = " $('#nrcampo".$nmdcampo."','#frmConsulta').focus();"; }
			else             
			   {$mtdErro = " $('#".$nmdcampo."','#frmConsulta').focus();"; }
		   }
		
		exibirErro('error',$msgErro,'Alerta - Ayllos',$mtdErro,false);		
	} 
	
	// if ( $tpdsaida == 'T' ){ /*Exibe em tela*/
	
	$registros = $xmlObjeto->roottag->tags[0]->tags;
	
	// Quantidade total de cooperados na pesquisa
	$qtregist = $xmlObjeto->roottag->tags[0]->attributes["QTREGIST"]; 				
	
	include ('tab_cheque.php');
	include ('form_cheque.php');
?>