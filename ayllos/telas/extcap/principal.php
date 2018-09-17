<? 
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 25/08/2011 
 * OBJETIVO     : Rotina para manter as operações da tela EXTCAP
 * --------------
 * ALTERAÇÕES   : 05/06/2013 - Incluir chamada da procedure retorna-valor-blqjud (Lucas R.)
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
	$retornoAposErro	= 'cDtmovmto.focus();';
	$procedure			= '';
	
	// Recebe a operação que está sendo realizada
	$operacao			= (isset($_POST['operacao'])) ? $_POST['operacao'] : ''; 
	$nrdconta			= (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0 ; 
	$nmprimtl			= (isset($_POST['nmprimtl'])) ? $_POST['nmprimtl'] : ''; 
	$dtmovmto			= (isset($_POST['dtmovmto'])) ? $_POST['dtmovmto'] : ''; 
	$nrregist			= (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 0 ; 
	$nriniseq			= (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 0 ; 
	
	switch( $operacao ) {
		case 'associado': $procedure = 'Busca_Extcap'; 			break;
		case 'extrato'	: $procedure = 'Busca_Extrato_Cotas'; 	break;
	}
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0103.p</Bo>';
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
	$xml .= '		<dtmovano>'.$dtmovmto.'</dtmovano>';
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
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}

	
	$dados 		= $xmlObjeto->roottag->tags[0]->tags[0]->tags;
	$nrdconta	= getByTagName($dados,'nrdconta') != '' ? getByTagName($dados,'nrdconta') : $nrdconta;
	$nmprimtl	= getByTagName($dados,'nmprimtl') != '' ? getByTagName($dados,'nmprimtl') : $nmprimtl;

	$extrato 	= $xmlObjeto->roottag->tags[0]->tags;
	$qtregist	= $xmlObjeto->roottag->tags[0]->attributes['QTREGIST'];
	$vlsldant	= $xmlObjeto->roottag->tags[0]->attributes['VLSLDANT'];
	$vlsldtot	= $xmlObjeto->roottag->tags[0]->attributes['VLSLDTOT'];
	
	if ( $operacao == 'extrato' ) {
		$data		= explode('/',$glbvars['dtmvtolt']);
		$dtmovmto	= !empty($dtmovmto) ? $dtmovmto : $data[2]; 
	}

	 // Monta o xml de requisição
	$xmlJud  = "";
	$xmlJud .= "<Root>";
	$xmlJud .= "	<Cabecalho>";
	$xmlJud .= "		<Bo>b1wgen0155.p</Bo>";
	$xmlJud .= "		<Proc>retorna-valor-blqjud</Proc>";
	$xmlJud .= "	</Cabecalho>";
	$xmlJud .= "	<Dados>";
	$xmlJud .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlJud .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlJud .= "		<nrcpfcgc>0</nrcpfcgc>";
	$xmlJud .= "		<cdtipmov>0</cdtipmov>";
	$xmlJud .= "		<cdmodali>4</cdmodali>";
	$xmlJud .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlJud .= "	</Dados>";
	$xmlJud .= "</Root>";
	
		// Executa script para envio do XML
	$xmlResult = getDataXML($xmlJud);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjBlqJud = getObjectXML($xmlResult);
	
	$vlbloque = $xmlObjBlqJud->roottag->tags[0]->attributes['VLBLOQUE']; 
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjBlqJud->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjBlqJud->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	include('form_cabecalho.php');
	include('form_extcap.php');
	include("tab_extcap.php");
?>

<script>
controlaLayout('<? echo $operacao ?>');
</script>
