<? 
/*!
 * FONTE        : busca_gt0002.php
 * CRIAÇÃO      : Jéssica (DB1)
 * DATA CRIAÇÃO : 19/09/2013
 * OBJETIVO     : Rotina para buscar convenios por cooperativas - GT0002
 * --------------
 * ALTERAÇÕES   : 02/12/2016 - P341-Automatização BACENJUD - Alterar a passagem da descrição do 
 *                             departamento como parametros e passar o o código (Renato Darosci)
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
		
	// Recebe a operação que está sendo realizada
	
	$cdcooper	= (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : 0;
	$cddopcao	= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
	$cdconven   = (isset($_POST['cdconven'])) ? $_POST['cdconven'] : 0;
	$nrregist	= (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 0;
	$nriniseq	= (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 0;

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') { 
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	validaDados();
	
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0176.p</Bo>';
	$xml .= '		<Proc>Busca_Dados</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '       <cddepart>'.$glbvars['cddepart'].'</cddepart>';	
	$xml .= '       <cdcooped>'.$cdcooper.'</cdcooped>';
	$xml .= '       <cddopcao>'.$cddopcao.'</cddopcao>';
	$xml .= '       <cdconven>'.$cdconven.'</cdconven>';
	$xml .= '       <nrregist>'.$nrregist.'</nrregist>';
	$xml .= '       <nriniseq>'.$nriniseq.'</nriniseq>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
			
	$xmlResult = getDataXML($xml);
	
	$xmlObjeto = getObjectXML($xmlResult);
		
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	

		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo	= $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];	
		
		if (!empty($nmdcampo)) { $mtdErro = " focaCampoErro('" . $nmdcampo . "','frmConsulta'); "; }		
		
		exibirErro('error',$msgErro,'Alerta - Ayllos',$mtdErro,false);		  
	} 

	// $registros  = $xmlObjeto->roottag->tags[0]->tags[0]->tags;
	$registros1  = $xmlObjeto->roottag->tags[0]->tags[0]->tags;
	$registros  = $xmlObjeto->roottag->tags[0]->tags;
	
	// Quantidade total de cooperados na pesquisa
	$qtregist = $xmlObjeto->roottag->tags[0]->attributes["QTREGIST"];
	
	if($GLOBALS['cddopcao'] != "E" && $GLOBALS['cddopcao'] != "I"){
	
		include('tab_gt0002.php');
	
	}

	
?>
<script>

	if(cCdcooper.val() != 0 && cCdconven.val() != 0){
		cNmrescop.val("<? echo getByTagName($registros1,'nmrescop') ?>");
		cNmempres.val("<? echo getByTagName($registros1,'nmempres') ?>");
	}else{
		cNmrescop.val("");
	    cNmempres.val("");
	}
	
	if(cCddopcao.val() != "C"){
	
		showConfirmacao('Confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','manterRotina();','','sim.gif','nao.gif');

	}else{

		formataTabela();

	}	
	
</script>

<?	
	
	function validaDados() {
	
		if($GLOBALS['cddopcao'] != "C" ){
	
			//Campo cod. da cooperativa.
			if (!validaInteiro($GLOBALS['cdcooper']) || $GLOBALS['cdcooper'] == '' || $GLOBALS['cdcooper'] == 0) exibirErro('error','Cooperativa inv&aacute;lida.','Alerta - Ayllos','cCdcooper.habilitaCampo();cCdcooper.focus();',false);

			//Campo cod. do convenio.
			if (!validaInteiro($GLOBALS['cdconven']) || $GLOBALS['cdconven'] == '' || $GLOBALS['cdconven'] == 0) exibirErro('error','Convênio inv&aacute;lido.','Alerta - Ayllos','cCdconven.habilitaCampo();cCdconven.focus();',false);
		
		}
	}
	
	
?>