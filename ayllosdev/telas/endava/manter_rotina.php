<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Jéssica (DB1)      
 * DATA CRIAÇAO : 30/10/2013
 * OBJETIVO     : Rotina para alteração cadastral da tela ENDAVA
 * --------------
 * ALTERA��ES   : 
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
	$retornoAposErro = '';
	$procedure 	= '';
	
	$cep = $_POST['nrcepend'];
	
	$cep = str_replace("-","",$cep); 
	
	
	// Recebe a operação que está sendo realizada
		
	$cddopcao   = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
	$pro_cpfcgc = (isset($_POST['pro_cpfcgc'])) ? $_POST['pro_cpfcgc']   : 0;
	$nrctremp   = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : 0;
	$nrdconta   = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
	$tpctrato   = (isset($_POST['tpctrato'])) ? $_POST['tpctrato'] : 0;
	$dsendav1   = (isset($_POST['dsendav1'])) ? $_POST['dsendav1'] : '';
	$dsendav2   = (isset($_POST['dsendav2'])) ? $_POST['dsendav2'] : '';
	$nrendere   = (isset($_POST['nrendere'])) ? $_POST['nrendere'] : 0;
	$nrfonres   = (isset($_POST['nrfonres'])) ? $_POST['nrfonres'] : '';
	$complend   = (isset($_POST['complend'])) ? $_POST['complend'] : '';
	$nrcxapst   = (isset($_POST['nrcxapst'])) ? $_POST['nrcxapst'] : 0;
	$dsdemail   = (isset($_POST['dsdemail'])) ? $_POST['dsdemail'] : '';
	$nmcidade   = (isset($_POST['nmcidade'])) ? $_POST['nmcidade'] : '';
	$cdufresd   = (isset($_POST['cdufresd'])) ? $_POST['cdufresd'] : '';
	$nrcepend   = (isset($cep)) ? $cep : 0;

	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
		
	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0164.p</Bo>';
	$xml .= '		<Proc>grava_crapavt</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '       <pro_cpfcgc>'.$pro_cpfcgc.'</pro_cpfcgc>';
	$xml .= '       <nrctremp>'.$nrctremp.'</nrctremp>';
	$xml .= '       <nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '       <tpctrato>'.$tpctrato.'</tpctrato>';
	$xml .= '       <dsendav1>'.$dsendav1.'</dsendav1>';
	$xml .= '       <dsendav2>'.$dsendav2.'</dsendav2>';
	$xml .= '       <nrendere>'.$nrendere.'</nrendere>';
	$xml .= '       <nrfonres>'.$nrfonres.'</nrfonres>';
	$xml .= '       <complend>'.$complend.'</complend>';
	$xml .= '       <nrcxapst>'.$nrcxapst.'</nrcxapst>';
	$xml .= '       <dsdemail>'.$dsdemail.'</dsdemail>';
	$xml .= '       <nmcidade>'.$nmcidade.'</nmcidade>';
	$xml .= '       <cdufresd>'.$cdufresd.'</cdufresd>';
	$xml .= '       <nrcepend>'.$nrcepend.'</nrcepend>';
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
	showError("inform","Registro alterado com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","estadoInicial();");
					
	</script>

