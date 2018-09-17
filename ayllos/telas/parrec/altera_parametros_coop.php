<? 
/*!
 * FONTE        : altera_parametros_coop.php
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 31/01/2017
 * OBJETIVO     : Rotina para alterar os parametros da recarga de celular 
 * 				  das cooperativas singulares
 * --------------
 * ALTERAÇÕES   : 
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
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : 0 ; 
	$cdcooper = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : 0 ; 
	$flsitsac = (isset($_POST['flsitsac'])) ? $_POST['flsitsac'] : 0 ; 
	$flsittaa = (isset($_POST['flsittaa'])) ? $_POST['flsittaa'] : 0 ; 
	$flsitibn = (isset($_POST['flsitibn'])) ? $_POST['flsitibn'] : 0 ; 
	$vlrmaxpf = (isset($_POST['vlrmaxpf'])) ? $_POST['vlrmaxpf'] : 0 ; 
	$vlrmaxpj = (isset($_POST['vlrmaxpj'])) ? $_POST['vlrmaxpj'] : 0 ; 
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','estadoInicial();',false);
	}

	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcoppar>'.$cdcooper.'</cdcoppar>';
	$xml .= '       <flsitsac>'.$flsitsac.'</flsitsac>';
	$xml .= '       <flsittaa>'.$flsittaa.'</flsittaa>';
	$xml .= '       <flsitibn>'.$flsitibn.'</flsitibn>';
	$xml .= '       <vlrmaxpf>'.$vlrmaxpf.'</vlrmaxpf>';
	$xml .= '       <vlrmaxpj>'.$vlrmaxpj.'</vlrmaxpj>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	$xmlResult = mensageria($xml, "TELA_PARREC", "ALTERA_PARAM_COOP", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= utf8_encode($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata);
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
	}
	
	exibirErro('inform','Opera&ccedil;&atilde;o efetuada com sucesso!','Alerta - Ayllos','estadoInicial();',false);
?>
