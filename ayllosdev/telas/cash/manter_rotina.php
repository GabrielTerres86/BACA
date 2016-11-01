<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 11/11/2011 
 * OBJETIVO     : Rotina para manter as operações da tela CASH
 * --------------
 * ALTERAÇÕES   : 24/07/2013 - Ajustado para permitir imprimir o relatório de cartões magnéticos "busca_dados_cartoes_magneticos". (James)
 *
 *				  18/11/2013 - Adcionado operacao 'bloquearSaq' referente ao bloqueio de saque. (Jorge)
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
	$cddoptrs		= '';
	
	// Recebe a operação que está sendo realizada
	$operacao		= (isset($_POST['operacao']))   ? $_POST['operacao']   : 0  ; 
	$cddopcao		= (isset($_POST['cddopcao']))   ? $_POST['cddopcao']   : 0  ; 
	$nrterfin		= (isset($_POST['nrterfin']))   ? $_POST['nrterfin']   : 0  ; 
	$cdagencx		= (isset($_POST['cdagencx']))   ? $_POST['cdagencx']   : 0  ; 
	$dsfabtfn		= (isset($_POST['dsfabtfn']))   ? $_POST['dsfabtfn']   : '' ; 
	$dsmodelo		= (isset($_POST['dsmodelo']))   ? $_POST['dsmodelo']   : '' ; 
	$dsdserie		= (isset($_POST['dsdserie']))   ? $_POST['dsdserie']   : '' ; 
	$nmnarede		= (isset($_POST['nmnarede']))   ? $_POST['nmnarede']   : '' ; 
	$nrdendip		= (isset($_POST['nrdendip']))   ? $_POST['nrdendip']   : '' ; 
	$cdsitfin		= (isset($_POST['cdsitfin']))   ? $_POST['cdsitfin']   : 0  ; 
	$qtcasset		= (isset($_POST['qtcasset']))   ? $_POST['qtcasset']   : 0  ; 
	$flsistaa		= (isset($_POST['flsistaa']))   ? $_POST['flsistaa']   : '' ; 
	$dsterfin		= (isset($_POST['dsterfin']))   ? $_POST['dsterfin']   : '' ; 
	$qttotalp		= (isset($_POST['qttotalp']))   ? $_POST['qttotalp']   : 0  ; 

	$tprecolh		= (isset($_POST['tprecolh']))   ? $_POST['tprecolh']   : 'yes' ; 
	
	$dtlimite		= (isset($_POST['dtlimite']))   ? $_POST['dtlimite']   : '' ; 
	
	$cddoptel		= (isset($_POST['cddoptel']))   ? $_POST['cddoptel']   : '' ; 
	$opcaorel		= (isset($_POST['opcaorel']))   ? $_POST['opcaorel']   : '' ; 
	$cdagetfn		= (isset($_POST['cdagetfn']))   ? $_POST['cdagetfn']   : '' ; 
	$lgagetfn		= (isset($_POST['lgagetfn']))   ? $_POST['lgagetfn']   : '' ; 
	$dtmvtini		= (isset($_POST['dtmvtini']))   ? $_POST['dtmvtini']   : '' ; 
	$dtmvtfim		= (isset($_POST['dtmvtfim']))   ? $_POST['dtmvtfim']   : '' ; 
	$tiprelat		= (isset($_POST['tiprelat']))   ? $_POST['tiprelat']   : '' ; 
	$nmarqimp		= ((isset($_POST['nmarqimp'])) && ($_POST['nmarqimp'] != "")) ? $_POST['nmarqimp'] : session_id();	

	switch( $operacao ) {
		case 'bloquear'	   : $procedure = 'Opcao_Transacao';  $cddoptrs = 'B'; break;
		case 'bloquearSaq' : $procedure = 'Opcao_Transacao';  $cddoptrs = 'S'; break;
		case 'BD'		   : $procedure = 'Busca_Dados';  					   break;
		case 'BDCM'		   : $procedure = 'busca_dados_cartoes_magneticos';    break;
		case 'VP'		   : $procedure = 'Valida_Pac';   				       break;
		case 'VD'		   : $procedure = 'Valida_Dados';   				   break;
		case 'GD'		   : $procedure = 'Grava_Dados';   					   break;
	}
	
	if ( $cddopcao == 'I' or $cddopcao == 'A' or $cddopcao == 'B' ) {
		$retornoAposErro = "bloqueiaFundo($('#divRotina'));";		
	} else if ( $cddopcao == 'L' or $cddopcao == 'R' ) {
		$retornoAposErro = "fechaOpcao();";		
	}
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0123.p</Bo>';
	$xml .= '		<Proc>'.$procedure.'</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmoperad>'.$glbvars['nmoperad'].'</nmoperad>';
	$xml .= '		<cdprogra>'.$glbvars['cdprogra'].'</cdprogra>';	
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '		<dsdepart>'.$glbvars['dsdepart'].'</dsdepart>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<dtmvtopr>'.$glbvars['dtmvtopr'].'</dtmvtopr>';
	$xml .= '		<dtmvtoan>'.$glbvars['dtmvtoan'].'</dtmvtoan>';
	$xml .= '		<dsiduser>'.$dsiduser.'</dsiduser>';
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';
	$xml .= '		<cddoptrs>'.$cddoptrs.'</cddoptrs>';
	$xml .= '		<nrterfin>'.$nrterfin.'</nrterfin>';
	$xml .= '		<cdagencx>'.$cdagencx.'</cdagencx>';
	$xml .= '		<dsfabtfn>'.$dsfabtfn.'</dsfabtfn>';
	$xml .= '		<dsmodelo>'.$dsmodelo.'</dsmodelo>';
	$xml .= '		<dsdserie>'.$dsdserie.'</dsdserie>';
	$xml .= '		<nmnarede>'.$nmnarede.'</nmnarede>';
	$xml .= '		<nrdendip>'.$nrdendip.'</nrdendip>';
	$xml .= '		<cdsitfin>'.$cdsitfin.'</cdsitfin>';
	$xml .= '		<qtcasset>'.$qtcasset.'</qtcasset>';
	$xml .= '		<flsistaa>'.$flsistaa.'</flsistaa>';
	$xml .= '		<dsterfin>'.$dsterfin.'</dsterfin>';
	$xml .= '		<tprecolh>'.$tprecolh.'</tprecolh>';
	$xml .= '		<qttotalp>'.$qttotalp.'</qttotalp>';
	$xml .= '		<dtlimite>'.$dtlimite.'</dtlimite>';
	$xml .= '		<cddoptel>'.$cddoptel.'</cddoptel>';
	$xml .= '		<cdagetfn>'.$cdagetfn.'</cdagetfn>';
	$xml .= '		<lgagetfn>'.$lgagetfn.'</lgagetfn>';
	$xml .= '		<dtmvtini>'.$dtmvtini.'</dtmvtini>';
	$xml .= '		<dtmvtfim>'.$dtmvtfim.'</dtmvtfim>';
	$xml .= '		<tiprelat>'.$tiprelat.'</tiprelat>';
	$xml .= '		<nmarqimp>'.$nmarqimp.'</nmarqimp>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo	= $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];
		if (!empty($nmdcampo)) { $retornoAposErro = $retornoAposErro . " focaCampoErro('".$nmdcampo."','frmCab');"; }
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}
	
	$cdsitfin = $xmlObjeto->roottag->tags[0]->attributes['CDSITFIN'];
	$nmarqimp = $xmlObjeto->roottag->tags[0]->attributes['NMARQIMP'];
	$nmarqpdf = $xmlObjeto->roottag->tags[0]->attributes['NMARQPDF'];
	$nmdireto = $xmlObjeto->roottag->tags[0]->attributes['NMDIRETO'];
	$flgblsaq = $xmlObjeto->roottag->tags[0]->attributes['FLGBLSAQ'];
	
	if ( $operacao == 'bloquear' ) {
		echo "$('#cdsitfin', '#frmCash').val('".$cdsitfin."');";
		echo "hideMsgAguardo();";
		echo "fechaRotina( $('#divUsoGenerico') );";
		echo "showError('inform','Operacao efetuada com sucesso!','Alerta - Ayllos','');";
			
	} else if ( $operacao == 'bloquearSaq' ) {
		echo "$('#flgblsaq', '#frmCash').val('".$flgblsaq."');";
		echo "hideMsgAguardo();";
		echo "fechaRotina( $('#divUsoGenerico') );";
		echo "showError('inform','Operacao efetuada com sucesso!','Alerta - Ayllos','');";
			
	} else if ( $cddopcao == 'A' and $operacao == 'VD' ) {
		echo "controlaLayout('VD');";
	
	} else if ( $cddopcao == 'A' and $operacao == 'GD' ) {
		echo "controlaLayout('GD');";

	} else if ( $cddopcao == 'B' and $operacao == 'GD' ) {
		echo "controlaLayout('GD');";
	
	} else if ( $cddopcao == 'L' and $operacao == 'GD' ) {
		echo "controlaLayout('GD');";

	} else if ( $cddopcao == 'I' and $operacao == 'VD' ) {
		echo "controlaLayout('VD');";
	
	} else if ( $cddopcao == 'I' and $operacao == 'GD' ) {
		echo "controlaLayout('GD');";

	} else if ( $cddopcao == 'I' and $operacao == 'BD' ) {
		$iProximoTerminal = $xmlObjeto->roottag->tags[1]->tags[0]->tags[3]->cdata;
	    echo "$('#nrterfin','#frmCab').val(". $iProximoTerminal .");";
		echo "hideMsgAguardo();";		
	
	} else if ( $cddopcao == 'R' and $operacao == 'VP' ) {
		echo "nmdireto='".$nmdireto."';";
		echo "controlaLayout('VP');";

	} else if (( $cddopcao == 'R' ) && (($operacao == 'BD') || ($operacao == 'BDCM'))){		
		echo "nmarqpdf='".$nmarqpdf."';";	
		echo "controlaLayout('".$operacao."');";
	}
?>