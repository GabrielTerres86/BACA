<? 
/*!
 * FONTE        : busca_linhas_finalidades.php
 * CRIAÇÃO      : Jéssica (DB1)							Última alteração: 22/01/2015
 * DATA CRIAÇÃO : 24/02/2014
 * OBJETIVO     : Rotina para buscar a consulta de movimentação do sistema - MOVTOS
 * --------------
 * ALTERAÇÕES   : 22/01/2015 - Ajustes para liberação (Adriano).
 *
 *                05/12/2016 - P341-Automatização BACENJUD - Alterar a passagem da descrição do 
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
		
	$cddopcao	= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	// Recebe a operação que está sendo realizada	
	$nrregist	= (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 0;
	$nriniseq	= (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 0;
	
	validaDados();
			
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0185.p</Bo>';
	$xml .= '		<Proc>busca_linhas_finalidades</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '       <cddepart>'.$glbvars['cddepart'].'</cddepart>';	
	$xml .= '       <dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';	
	$xml .= '       <cddopcao>'.$cddopcao.'</cddopcao>';
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

	$registros  = $xmlObjeto->roottag->tags[0]->tags;
	$registros1  = $xmlObjeto->roottag->tags[1]->tags;
	$registros2  = $xmlObjeto->roottag->tags[2]->tags;
	
	// Quantidade total de cooperados na pesquisa
	$qtregist = $xmlObjeto->roottag->tags[0]->attributes["QTREGIST"];		
	
	include('tab_linhaCred.php');
	include('tab_finalidade.php');
		
	function validaDados(){
		
		//Código da Finalida
		if ( $GLOBALS["nrregist"] == '' || $GLOBALS['nrregist'] == 0){ 
			exibirErro('error','N&uacute;mero do registro inv&aacute;lido.','Alerta - Ayllos','focaCampoErro(\'btVoltar\',\'divBotoes\');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
		}
		
		//Nome do arquivo
		if ( $GLOBALS["nriniseq"] == ''){ 
			exibirErro('error','N&uacute;mero sequ&ecirc;ncial inv&aacute;lido.','Alerta - Ayllos','focaCampoErro(\'btVoltar\',\'divBotoes\');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
		}
			
	}
			
?>
<script>

	formataLinCred();
	formataFinalidade();
	$('#btVoltar','#divBotoes').focus();	
				
</script>
