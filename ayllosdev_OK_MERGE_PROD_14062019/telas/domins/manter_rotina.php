<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 25/05/2011 
 * OBJETIVO     : Rotina para manter as operações da tela DOMINS
 * --------------
 * ALTERACOES   : 02/07/2012 - Adicionado confirmacao de impressao na chamada Gera_Impressao(). (Jorge)
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
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '' ; 
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '' ; 
	$nrbenefi = (isset($_POST['nrbenefi'])) ? $_POST['nrbenefi'] : '' ; 
	$nrrecben = (isset($_POST['nrrecben'])) ? $_POST['nrrecben'] : '' ; 
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '' ;	
	
	
	// Dependendo da operação, chamo uma procedure diferente
	$procedure 	= '';
	$mtdErro	= '';
	$retorno 	= '';
	switch($operacao) {
		case 'C1': $procedure = 'busca-domins';		$mtdErro = ''; 						break;
		case 'A1': $procedure = 'valida-nbnit';		$mtdErro = 'manterRotina(\'\');'; 	break;
		default:   $mtdErro   = 'estadoInicial();'; return false; 						break;
	}

	// valida 
	if(in_array($operacao,array('A1'))) validaDados();

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'A')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	// Monta o xml dinâmico de acordo com a operação 
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0091.p</Bo>";
	$xml .= "		<Proc>".$procedure."</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
    $xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<idseqttl>".$idseqttl."</idseqttl>";
	$xml .= "		<nrbenefi>".$nrbenefi."</nrbenefi>";
	$xml .= "		<nrrecben>".$nrrecben."</nrrecben>";
	$xml .= "		<tpregist>30</tpregist>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";


 	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {	
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo	= $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];
		if ( !empty($nmdcampo) ) { $mtdErro = $mtdErro . " $('#".$nmdcampo."', '#frmDomins').focus();";  }
		exibirErro('error',$msgErro,'Alerta - Ayllos',$mtdErro,false);
	}	
	
	
	// consulta
	if ($operacao == 'C1') {

		// retorno da xml
		$registros 	= $xmlObjeto->roottag->tags[0]->tags;
	
		// cabecalho
		echo "$('#cdagenci','#frmCabDomins').val('".getByTagName($registros[0]->tags,'cdagenci')."');";
		echo "$('#nmresage','#frmCabDomins').val('".getByTagName($registros[0]->tags,'nmresage')."');";
		
		// domins text
		echo "$('#nmrecben','#frmDomins').val('".getByTagName($registros[0]->tags,'nmrecben')."');";
		echo "$('#nrbenefi','#frmDomins').val('".getByTagName($registros[0]->tags,'nrbenefi')."').habilitaCampo().focus();";
		echo "$('#nrrecben','#frmDomins').val('".getByTagName($registros[0]->tags,'nrrecben')."').habilitaCampo();";
		echo "$('#nrnovcta','#frmDomins').val('".getByTagName($registros[0]->tags,'nrdconta')."');";
		echo "$('#cdorgpag','#frmDomins').val('".getByTagName($registros[0]->tags,'cdorgpag')."');";

		// domins hidden
		echo "$('#nrdconta','#frmDomins').val('".getByTagName($registros[0]->tags,'nrdconta')."');";
		echo "$('#idseqttl','#frmDomins').val('".getByTagName($registros[0]->tags,'idseqttl')."');";
		echo "$('#cdagenci','#frmDomins').val('".getByTagName($registros[0]->tags,'cdagenci')."');";
		echo "$('#nmresage','#frmDomins').val('".getByTagName($registros[0]->tags,'nmresage')."');";
		echo "$('#cdcooper','#frmDomins').val('".getByTagName($registros[0]->tags,'cdcooper')."');";
		echo "$('#nrctacre','#frmDomins').val('".getByTagName($registros[0]->tags,'nrctacre')."');";
		echo "$('#dsdircop','#frmDomins').val('".getByTagName($registros[0]->tags,'dsdircop')."');";
		echo "$('#nmextttl','#frmDomins').val('".getByTagName($registros[0]->tags,'nmextttl')."');";
		echo "$('#nmoperad','#frmDomins').val('".getByTagName($registros[0]->tags,'nmoperad')."');";
		echo "$('#nmcidade','#frmDomins').val('".getByTagName($registros[0]->tags,'nmcidade')."');";
		echo "$('#nmextcop','#frmDomins').val('".getByTagName($registros[0]->tags,'nmextcop')."');";
		echo "$('#nmrescop','#frmDomins').val('".getByTagName($registros[0]->tags,'nmrescop')."');";
		echo "$('#cdagebcb','#frmDomins').val('".getByTagName($registros[0]->tags,'cdagebcb')."');";

		echo "$('#nrnovcta','#frmDomins').trigger('blur');";
		echo "hideMsgAguardo();";
		
	// atualizacao
	} else if ($operacao == 'A1') {	
		
		// retorno da xml
		$dstextab 	= $xmlObjeto->roottag->tags[0]->attributes['DSTEXTAB'];
	
		echo "$('#dstextab','#frmDomins').val('".$dstextab."');";
		//confirmação para gerar impressao
		echo 'showConfirmacao("Deseja visualizar a impress&atilde;o?","Confirma&ccedil;&atilde;o - Ayllos","Gera_Impressao();","hideMsgAguardo();estadoInicial();","sim.gif","nao.gif");';
	}

	//
	function validaDados() {
		// conta
		if ( $GLOBALS['nrdconta'] == 0 ) exibirErro('error','Conta/dv inválida.','Alerta - Ayllos','bloqueiaFundo($(\'#divTela\'),\'nrdconta\',\'frmCabDomins\')',false);
		// titular
		if ( $GLOBALS['idseqttl'] == 0 ) exibirErro('error','Titular inválido.','Alerta - Ayllos','bloqueiaFundo($(\'#divTela\'),\'idseqttl\',\'frmCabDomins\')',false);
		
	}	
	
?>