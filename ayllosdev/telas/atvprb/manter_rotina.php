<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 07/03/2012 
 * OBJETIVO     : Rotina para manter as operações da tela CADSOC
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
	$retornoAposErro= '';
	
	// Recebe a operação que está sendo realizada
	$operacao		= (isset($_POST['operacao']))   ? $_POST['operacao']  : '' ;
	$cddopcao		= (isset($_POST['cddopcao']))   ? $_POST['cddopcao']  : '' ;
	$nrdconta		= (isset($_POST['nrdconta']))   ? $_POST['nrdconta']  : '' ;
/*	$nrcpfcgc		= (isset($_POST['nrcpfcgc']))   ? $_POST['nrcpfcgc']  : '' ;
	$nrctremp		= (isset($_POST['nrctremp']))   ? $_POST['nrctremp']  : '' ;
	$tpidenti		= (isset($_POST['tpidenti']))   ? $_POST['tpidenti']  : '' ;
	$tpctrdev		= (isset($_POST['tpctrdev']))   ? $_POST['tpctrdev']  : '' ;
	$nrctaavl		= (isset($_POST['nrctaavl']))   ? $_POST['nrctaavl']  : '' ;

	$nrctrspc		= (isset($_POST['nrctrspc']))   ? $_POST['nrctrspc']  : '' ;
	$dtvencto		= (validaData($_POST['dtvencto']))   ? $_POST['dtvencto']  : '' ;
	$vldivida		= (isset($_POST['vldivida']))   ? $_POST['vldivida']  : '' ;

	$dtinclus		= (validaData($_POST['dtinclus']))   ? $_POST['dtinclus']  : '' ;
	$tpinsttu		= (isset($_POST['tpinsttu']))   ? $_POST['tpinsttu']  : '' ;
	$dsoberv1		= (isset($_POST['dsoberv1']))   ? $_POST['dsoberv1']  : '' ;
	
	$dtdbaixa		= (validaData($_POST['dtdbaixa']))   ? $_POST['dtdbaixa']  : '' ;
	$dsoberv2		= (isset($_POST['dsoberv2']))   ? $_POST['dsoberv2']  : '' ;
	$nrdrowid		= (isset($_POST['nrdrowid']))   ? $_POST['nrdrowid']  : 0 ;

	$procedure 		= $operacao;
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	// Monta o xml dinâmico de acordo com a operação 
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Cabecalho>";
	$xml .= "	    <Bo>b1wgen0133.p</Bo>";
	$xml .= "        <Proc>".$procedure."</Proc>";
	$xml .= "  </Cabecalho>";
	$xml .= "  <Dados>";
	$xml .= "       <cdcooper>".$glbvars['cdcooper']."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars['cdagenci']."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars['nrdcaixa']."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars['cdoperad']."</cdoperad>";
	$xml .= "		<cdprogra>".$glbvars['cdprogra']."</cdprogra>";	
	$xml .= "		<nmdatela>".$glbvars['nmdatela']."</nmdatela>";	
	$xml .= "		<idorigem>".$glbvars['idorigem']."</idorigem>";	
	$xml .= "		<dtmvtolt>".$glbvars['dtmvtolt']."</dtmvtolt>";	
	$xml .= "		<cddopcao>".$cddopcao."</cddopcao>";	
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";	
	$xml .= "		<nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
	$xml .= "		<nrctremp>".$nrctremp."</nrctremp>";
	$xml .= "		<tpidenti>".$tpidenti."</tpidenti>";
	$xml .= "		<tpctrdev>".$tpctrdev."</tpctrdev>";
	$xml .= "		<nrctaavl>".$nrctaavl."</nrctaavl>";
	$xml .= "		<nrctrspc>".$nrctrspc."</nrctrspc>";
	$xml .= "		<dtvencto>".$dtvencto."</dtvencto>";
	$xml .= "		<dtinclus>".$dtinclus."</dtinclus>";
	$xml .= "		<dsoberv1>".$dsoberv1."</dsoberv1>";
	$xml .= "		<vldivida>".$vldivida."</vldivida>";
	$xml .= "		<tpinsttu>".$tpinsttu."</tpinsttu>";
	$xml .= "		<dtdbaixa>".$dtdbaixa."</dtdbaixa>";
	$xml .= "		<dsoberv2>".$dsoberv2."</dsoberv2>";
	$xml .= "		<nrdrowid>".$nrdrowid."</nrdrowid>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";	

	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo	= $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];
		if (!empty($nmdcampo)) { $retornoAposErro = $retornoAposErro . " $('#".$nmdcampo."','#frmCadSPC').focus();"; }
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}

	$registro 	= $xmlObjeto->roottag->tags[0]->tags;
	$qtregist	= $xmlObjeto->roottag->tags[0]->attributes['QTREGIST'];
	$dados 		= $xmlObjeto->roottag->tags[0]->tags[0]->tags; 
	
	$flgassoc	= $xmlObjeto->roottag->tags[0]->attributes['FLGASSOC'];
	$dsinsttu	= $xmlObjeto->roottag->tags[0]->attributes['DSINSTTU'];
	$operador	= $xmlObjeto->roottag->tags[0]->attributes['OPERADOR'];
	
	if ( $operacao == 'Busca_Devedor' or $operacao == 'Busca_Fiador' ) {
		echo "cNmprimtl.val('".getByTagName($dados,'nmprimtl')."');";
		echo "cCdagenci.val('".getByTagName($dados,'cdagenci')."');";
		echo "cNmresage.val('".getByTagName($dados,'nmresage')."');";				
		echo "cNrdconta.desabilitaCampo();";
		
		if ( $operacao == 'Busca_Fiador' and $flgassoc == 'yes' ) {
			echo "cNrctaavl.habilitaCampo().focus();";
		} else {
			echo "cNmpriavl.val('".getByTagName($dados,'nmpriavl')."');";
			echo "cTpctrdev.habilitaCampo().focus();";
		}		
		
	} else if ( $operacao == 'Verifica_Fiador' ) {
		echo "cNrctaavl.val('".formataContaDV(getByTagName($dados,'nrctaavl'))."').desabilitaCampo().trigger('blur');";
		echo "cNmpriavl.val('".getByTagName($dados,'nmpriavl')."');";
		echo "cTpctrdev.habilitaCampo().focus();";
	
	} else if ( $operacao == 'Busca_Contratos' || $operacao == 'Valida_Contrato' ) {
		echo "cTpctrdev.desabilitaCampo();";
		echo "cNrctremp.desabilitaCampo();";
		echo "cNrctrspc.habilitaCampo();";
		echo "cDtvencto.habilitaCampo().focus();";
		echo "cVldivida.habilitaCampo();";
		echo "cDtinclus.habilitaCampo();";
		echo "cTpinsttu.habilitaCampo();";
	
	} else if ( $operacao == 'Busca_Dados' ) {
		echo "cTpctrdev.desabilitaCampo();";
		echo "cNrctremp.desabilitaCampo();";
		
		echo "cNrctrspc.val('".getByTagName($dados,'nrctrspc')."');";
		echo "cDtvencto.val('".getByTagName($dados,'dtvencto')."');";
		echo "cVldivida.val('".formataMoeda(getByTagName($dados,'vldivida'))."');";
		echo "cDtinclus.val('".getByTagName($dados,'dtinclus')."');";
		echo "cTpinsttu.val('".getByTagName($dados,'tpinsttu')."');";
		echo "cDsoberv1.val('".getByTagName($dados,'dsoberv1')."');";
		echo "cOperador.val('".getByTagName($dados,'operador')."');";
		echo "cDtdbaixa.val('".getByTagName($dados,'dtdbaixa')."');";
		echo "cOpebaixa.val('".getByTagName($dados,'opebaixa')."');";
		echo "cDsoberv2.val('".getByTagName($dados,'dsoberv2')."');";
		echo "nrdrowid='".getByTagName($dados,'nrdrowid')."';";

		if ( $cddopcao == 'A' ) {
			echo "cNrctrspc.habilitaCampo();";
			echo "cDtvencto.habilitaCampo().focus();";
			echo "cVldivida.habilitaCampo();";
			echo "cDtinclus.habilitaCampo();";
			echo "cTpinsttu.habilitaCampo();";
		} else if ( $cddopcao == 'B' ) {
			echo "cDtdbaixa.habilitaCampo().focus();";
		}
		
	} else if ( $operacao == 'Valida_Dados' ) {
		echo "cNrctrspc.desabilitaCampo();";
		echo "cDtvencto.desabilitaCampo();";
		echo "cVldivida.desabilitaCampo();";
		echo "cDtinclus.desabilitaCampo();";
		echo "cTpinsttu.desabilitaCampo();";
		echo "cDtdbaixa.desabilitaCampo();";
	
		if ( $cddopcao == 'B' ) {
			echo "cOpebaixa.val('".$operador."');";
			echo "cDsoberv2.habilitaCampo().focus();";
		} else {
			echo "cOperador.val('".$operador."');";
			echo "cDsoberv1.habilitaCampo().focus();";
		}
		
	} else if ( $operacao == 'Grava_Dados' ) {
		echo "estadoInicial();";
	}

	echo "controlaPesquisas();";	
	echo "hideMsgAguardo();"; */

/*	echo "console.log(".operacao.");";
	echo "console.log(".cddopcao.");";
	echo "console.log(".nrdconta.");";
	echo "console.log(".nrctrato.");"; */

	if ($operacao == "Inclui_Dados"){
		echo 'showError("inform","Registro incluido com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';		
	} else if ($operacao == "Altera_Dados"){
		echo 'showError("inform","Registro alterado com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';		
	} else if ($operacao == "Exclui_Dados"){
		echo 'showError("inform","Registro excluido com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';
	} 
	
	if ($cddopcao == 'H') {
		include "tab_historico.php";
	} else {
		echo "exibeFrmAtvPrb();";	
	}
?>