<? 
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 15/04/2013 
 * OBJETIVO     : Rotina para manter as operações da tela LANTAR
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

	// Inicializa
	$retornoAposErro	= 'cNrdconta.focus();';
	$procedure			= 'busca-associado-lantar';
	
	// Recebe a operação que está sendo realizada
	//$operacao			= (isset($_POST['operacao'])) ? $_POST['operacao'] : ''; 
	$nrdconta			= (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0 ; 
	$telinpes			= (isset($_POST['telinpes'])) ? $_POST['telinpes'] : 0 ; 
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0153.p</Bo>';
	$xml .= '		<Proc>'.$procedure.'</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<telinpes>'.$telinpes.'</telinpes>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}
	
	$cdagenci = $xmlObjeto->roottag->tags[0]->attributes["CDAGENCI"];
	$nrmatric = $xmlObjeto->roottag->tags[0]->attributes["NRMATRIC"];
	$cdtipcta = $xmlObjeto->roottag->tags[0]->attributes["CDTIPCTA"];
	$dstipcta = $xmlObjeto->roottag->tags[0]->attributes["DSTIPCTA"];
	$nmprimtl = $xmlObjeto->roottag->tags[0]->attributes["NMPRIMTL"];
	$inpessoa = $xmlObjeto->roottag->tags[0]->attributes["INPESSOA"];
		
	include("tab_lantar.php");
?>

<script>
	criaObjetoAssociado('<? echo $cdagenci ?>', '<? echo $nrdconta ?>', '<? echo $nrmatric ?>','<? echo $cdtipcta ?>','<? echo $dstipcta ?>','<? echo $nmprimtl ?>', '<? echo $inpessoa ?>', '0');
	var objPesqAssociado = new pesquisa('<? echo $cdagenci ?>', '<? echo $nrdconta ?>', '<? echo $nrmatric ?>','<? echo $cdtipcta ?>','<? echo $dstipcta ?>','<? echo $nmprimtl ?>', '0');
	arrPesqAssociado.push( objPesqAssociado );
	carregaTabela();
	formataTabela();
	controlaLayout();
	$('#nrdconta','#frmCab').focus(); 
</script>
