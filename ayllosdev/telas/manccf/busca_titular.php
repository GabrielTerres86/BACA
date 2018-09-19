<? 
/*!
 * FONTE        : busca_titular.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 11/01/2013
 * OBJETIVO     : Rotina para buscar da opção titular
 * --------------
 * ALTERAÇÕES   : 22/03/2016 - No valida permissao passava C de consulta sendo que essa opcao
 *                             nao existe no cadastro da tela, substituido por I (SD421055 Tiago) 
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
	$nrdconta	= (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : ''  ;
	
	$retornoAposErro = 'estadoInicial();';
		
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'I')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}	

	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0143.p</Bo>';
	$xml .= '		<Proc>Busca_Titular</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';			
	$xml .= '       <nrdconta>'.$nrdconta.'</nrdconta>';	
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	$xmlResult = getDataXML($xml);
	
	$xmlObjeto = getObjectXML($xmlResult);
	
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	

		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo	= $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];	
		if (!empty($nmdcampo)) { $mtdErro = " bloqueiaFundo( $(\'#divRotina\') );"; }
		exibirErro('error',$msgErro,'Alerta - Aimaro',$mtdErro,false);		
	} 
	
	$registros = $xmlObjeto->roottag->tags[0]->tags;
	
	include ('tab_titular.php');	
?>
