<?
/*!
 * FONTE        : manter_rotina.php
 * CRIA��O      : J�ssica (DB1)        
 * DATA CRIA��O : 19/09/2013
 * OBJETIVO     : Rotina para exclus�o e inclus�o cadastral da tela GT0002
 * --------------
 * ALTERA��ES   : 
 * -------------- 
 */
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	// Inicializa
	$retornoAposErro = '';	
	
	// Recebe a opera��o que est� sendo realizada
		
	$cdcooper	= (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : 0;
	$cddopcao	= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
	$cdconven   = (isset($_POST['cdconven'])) ? $_POST['cdconven'] : 0;

	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	validaDados();
	
	// Monta o xml din�mico de acordo com a opera��o 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0176.p</Bo>';
	$xml .= '		<Proc>Grava_Dados</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '       <cdcooped>'.$cdcooper.'</cdcooped>';
	$xml .= '       <cddopcao>'.$cddopcao.'</cddopcao>';
	$xml .= '       <cdconven>'.$cdconven.'</cdconven>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
    // Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);

	
	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
		
		
	}
		
	$retornoAposErro = 'cCddopcao.focus()';
	
	
?>
	
	<script>
		estadoInicial();
	</script>

<?	
	
	function validaDados() {
	
		//Campo cod. do cooperativa.
		if (!validaInteiro($GLOBALS['cdcooper']) && $GLOBALS['cdcooper'] == "" && $GLOBALS['cdcooper'] == 0) exibirErro('error','Cooperativa inv&aacute;lida.','Alerta - Ayllos','cCdcooper.habilitaCampo();cCdcooper.focus();',false);
			
		
	}
	
	
?>
