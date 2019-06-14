<? 
/*!
 * FONTE        : busca_informativo.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 29/11/2012
 * OBJETIVO     : Rotina para buscar informativos na tela Coninf
 * --------------
 * ALTERAÇÕES   : 06/05/2016 - Ajustes nas permissões da tela onde se estava passando o parâmetro
							   de opção fixo. Ajuste feito para finalizar o chamado 441753. (Kelvin)
 * -------------- 
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
	$cddopcao	= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : ''  ;
	$dsiduser	= (isset($_POST['dsiduser'])) ? $_POST['dsiduser'] : ''  ;
	$cdcoopea	= (isset($_POST['cdcoopea'])) ? $_POST['cdcoopea'] : 0  ;
	$cdagenca	= (isset($_POST['cdagenca'])) ? $_POST['cdagenca'] : 0  ;
	$tpdocmto	= (isset($_POST['tpdocmto'])) ? $_POST['tpdocmto'] : 0  ;
	$indespac	= (isset($_POST['indespac'])) ? $_POST['indespac'] : ''  ;
	$cdfornec	= (isset($_POST['cdfornec'])) ? $_POST['cdfornec'] : ''  ;
	$dtmvtol1	= (isset($_POST['dtmvtol1'])) ? $_POST['dtmvtol1'] : ''  ;
	$dtmvtol2	= (isset($_POST['dtmvtol2'])) ? $_POST['dtmvtol2'] : ''  ;
	$tpdsaida	= (isset($_POST['tpdsaida'])) ? $_POST['tpdsaida'] : ''  ;
	$nrregist	= (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 0  ;
	$nriniseq	= (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 0  ;
	
	$cdcoopea	= ($cdcoopea == 'null') ? 0 : $cdcoopea  ;	
	$tpdocmto	= ($tpdocmto == 'null') ? 0 : $tpdocmto  ;		
	
	
	// if ( $qtdeExtemp == '0' ) {
	$retornoAposErro = 'estadoInicial();';
	// } else {
		// $retornoAposErro = 'estadoExtrato();';
	// }
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'@')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0142.p</Bo>';
	$xml .= '		<Proc>Busca_Dados</Proc>';
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
	$xml .= '       <dtmvtola>'.$dtmvtol1.'</dtmvtola>';
	$xml .= '       <dtmvtol2>'.$dtmvtol2.'</dtmvtol2>';
	$xml .= '       <tpdsaida>'.$tpdsaida.'</tpdsaida>';
	$xml .= '       <nrregist>'.$nrregist.'</nrregist>';
	$xml .= '       <nriniseq>'.$nriniseq.'</nriniseq>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	$xmlResult = getDataXML($xml);
	
	$xmlObjeto = getObjectXML($xmlResult);
	
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	

		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo	= $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];	
		if (!empty($nmdcampo)) { $mtdErro = " $('#".$nmdcampo."','#frmCab').focus();"; }
		exibirErro('error',$msgErro,'Alerta - Ayllos',$mtdErro,false);		
	} 
	
	if ( $tpdsaida == 'T' ){ /*Exibe em tela*/
	
	$registros = $xmlObjeto->roottag->tags[0]->tags;
	
	// Quantidade total de cooperados na pesquisa
	$qtregist = $xmlObjeto->roottag->tags[0]->attributes["QTREGIST"]; 				
	
	include ('tab_inform.php');
?>
<script type="text/javascript">
	formataTabela();	
</script>
<?	}else{ //Gera arquivo
		$msgErro  = 'Arquivo gerado com sucesso.';
		exibirErro('inform',$msgErro,'Alerta - Ayllos','fechaRotina($(\'#divRotina\'));estadoInicial();',true);

	}?>