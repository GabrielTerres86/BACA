<? 
/*!
 * FONTE        : princiapal.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 01/08/2011 
 * OBJETIVO     : Rotina para manter as operações da tela EXTRAT
 * --------------
 * ALTERAÇÕES   : 31/07/2013 - Implementada opcao A da tela EXTRAT (Lucas).
 *                19/09/2013 - Implementada opcao AC da tela EXTRAT (Tiago).
 *
 *                02/12/2016 - P341-Automatização BACENJUD - Alterar a passagem da descrição do 
 *                             departamento como parametros e passar o o código (Renato Darosci)
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
	$retornoAposErro= '';
	
	// Recebe a operação que está sendo realizada
	$nrdconta		= (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0  ; 
	$cddopcao		= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ; 
	$nmarquiv		= (isset($_POST['nmarquiv'])) ? $_POST['nmarquiv'] : '' ; 
	$dtinimov		= (isset($_POST['dtinimov'])) ? $_POST['dtinimov'] : '' ; 
	$dtfimmov		= (isset($_POST['dtfimmov'])) ? $_POST['dtfimmov'] : '' ; 
	$dsiduser		= session_id();
	$nrregist		= (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 0 ; 
	$nriniseq		= (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 0 ; 
	
	if($cddopcao == "A"){
		$cddopcao = "AC";
	}
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}	
	
	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0103.p</Bo>';
	$xml .= '		<Proc>Busca_Extrato</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmoperad>'.$glbvars['nmoperad'].'</nmoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<cddepart>'.$glbvars['cddepart'].'</cddepart>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<dtinimov>'.$dtinimov.'</dtinimov>';
	$xml .= '		<dtfimmov>'.$dtfimmov.'</dtfimmov>';
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';
	$xml .= '		<nmarquiv>'.$nmarquiv.'</nmarquiv>';
	$xml .= '		<dsiduser>'.$dsiduser.'</dsiduser>';
	$xml .= '		<nrregist>'.$nrregist.'</nrregist>';
	$xml .= '		<nriniseq>'.$nriniseq.'</nriniseq>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Aimaro',$retornoAposErro,false);
	}

	$qtregist	= $xmlObjeto->roottag->tags[1]->attributes['QTREGIST'];
	$dtinimov	= $xmlObjeto->roottag->tags[1]->attributes['DTINIMOV'];
	$dtfimmov	= $xmlObjeto->roottag->tags[1]->attributes['DTFIMMOV'];
	$dados 		= $xmlObjeto->roottag->tags[0]->tags[0]->tags;
	include('form_cabecalho.php');

	if ($cddopcao == "T") {
	
		include('form_extrat.php');
		
		$extrato = $xmlObjeto->roottag->tags[1]->tags;
		$qtExtrato = count($extrato);	
		include("tab_extrat.php");
?>

<script>
	atualizaSeletor();
	formataCabecalho();
	formataDados();
	formataTabela();
	cTodosCabecalho.desabilitaCampo();
</script>

<? } else { ?>

<script>
	hideMsgAguardo();
	showError('inform','Arquivo gerado com sucesso.','Alerta - Aimaro','estadoInicial();');	
</script>	

<? } ?>