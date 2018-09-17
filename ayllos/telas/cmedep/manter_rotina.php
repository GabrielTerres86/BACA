<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Guilherme
 * DATA CRIAÇÃO : 21/07/2011 
 * OBJETIVO     : Rotina para manter as operações da tela CMEDEP
 * --------------
 * ALTERAÇÕES   : 06/03/2012 - Alterações para trabalhar com novos parâmetros
 *							   da BO104 (Lucas).
 *					
 *				  21/06/2012 - Adicionado confirmacao para impressao. (Jorge) 
 *
 *				  19/07/2012 - Ajustes para receber nrdconta do cabecalho. (Jorge)
 * -------------- 
 */
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	// Inicializa
	$procedure 	= '';
	$mtdErro	= '';
	$mtdRetorno	= '';
	$dsdctitg	= '';
	$posvalid	= '';

	// Recebe a operação que está sendo realizada
	$operacao 	= (isset($_POST['operacao']))  ? $_POST['operacao']  : '' ; 
	
	// Cabecalho
	$dtdepesq = (isset($_POST['dtdepesq'])) ? $_POST['dtdepesq'] : '' ; 
	$cdagenci = (isset($_POST['cdagenci'])) ? $_POST['cdagenci'] : '' ; 
	$nrdcaixa = (isset($_POST['nrdcaixa'])) ? $_POST['nrdcaixa'] : '' ; 
	$cdbccxlt = (isset($_POST['cdbccxlt'])) ? $_POST['cdbccxlt'] : '' ; 
	$nrdolote = (isset($_POST['nrdolote'])) ? $_POST['nrdolote'] : '' ; 
	$nrdocmto = (isset($_POST['nrdocmto'])) ? $_POST['nrdocmto'] : '' ;
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '' ;	
	
	// Dados do depositante 
    $nrccdrcb = (isset($_POST['nrccdrcb'])) ? $_POST['nrccdrcb'] : '' ;                                                         
    $nmpesrcb = (isset($_POST['nmpesrcb'])) ? $_POST['nmpesrcb'] : '' ;                                                         
    $nridercb = (isset($_POST['nridercb'])) ? $_POST['nridercb'] : '' ;                                                         
    $dtnasrcb = (isset($_POST['dtnasrcb'])) ? $_POST['dtnasrcb'] : '' ;                                                         
    $desenrcb = (isset($_POST['desenrcb'])) ? $_POST['desenrcb'] : '' ;                                                         
    $nmcidrcb = (isset($_POST['nmcidrcb'])) ? $_POST['nmcidrcb'] : '' ;                                                         
    $nrceprcb = (isset($_POST['nrceprcb'])) ? $_POST['nrceprcb'] : '' ;                                                         
    $cdufdrcb = (isset($_POST['cdufdrcb'])) ? $_POST['cdufdrcb'] : '' ;                                                         
    $flinfdst = (isset($_POST['flinfdst'])) ? $_POST['flinfdst'] : '' ;                                                         
    $recursos = (isset($_POST['recursos'])) ? $_POST['recursos'] : '' ;                                                         
    $cpfcgrcb = (isset($_POST['cpfcgrcb'])) ? $_POST['cpfcgrcb'] : '' ;	
	$flgimpri = (isset($_POST['flgimpri'])) ? $_POST['flgimpri'] : '' ;	


	// Dependendo da operação, chamo uma procedure diferente
	switch($operacao) {
	
		// Consulta 
		case 'C1': $cddopcao = 'C'; $procedure = 'busca_dados'; 			     $mtdErro = 'cDocmto.focus();';		break;			
		// Alteracao				
		case 'A1': $cddopcao = 'A'; $procedure = 'busca_dados'; 			     $mtdErro = 'cDocmto.focus();';		break;
		case 'A2': $cddopcao = 'A'; $procedure = 'busca_dados_assoc'; 		     $mtdErro = 'cConta.focus();';		break;
		case 'A3': $cddopcao = 'A'; $procedure = 'valida_dados_nao_assoc';	     $mtdErro = 'cUf.focus();';			break;
		case 'A4': $cddopcao = 'A'; $procedure = 'inclui_altera_dados';			 $mtdErro = '';						break;		 
		// Inclusao
		case 'I1': $cddopcao = 'I'; $procedure = 'busca_dados'; 				 $mtdErro = 'cDocmto.focus();';     break;
		case 'I2': $cddopcao = 'I'; $procedure = 'busca_dados_assoc'; 			 $mtdErro = 'cConta.focus();';		break;
		case 'I3': $cddopcao = 'I'; $procedure = 'valida_dados_nao_assoc';	     $mtdErro = 'cUf.focus();';			break;
		case 'I4': $cddopcao = 'I'; $procedure = 'inclui_altera_dados'; 		 $mtdErro = 'cUf.focus();';			break;

		default:    $mtdErro   = 'estadoInicial();'; return false; 													break;
	}
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	
	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0104.p</Bo>';
	$xml .= '		<Proc>'.$procedure.'</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$cdagenci.'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$nrdcaixa.'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
    $xml .= '       <dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';
	$xml .= '       <dtdepesq>'.$dtdepesq.'</dtdepesq>';
	$xml .= '       <nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '       <nrdocmto>'.$nrdocmto.'</nrdocmto>';
	$xml .= '       <nrdolote>'.$nrdolote.'</nrdolote>';
	$xml .= '       <cdbccxlt>'.$cdbccxlt.'</cdbccxlt>';	
	$xml .= '       <nrccdrcb>'.$nrccdrcb.'</nrccdrcb>';
	$xml .= '       <nmpesrcb>'.$nmpesrcb.'</nmpesrcb>';
	$xml .= '       <nridercb>'.$nridercb.'</nridercb>';
	$xml .= '       <dtnasrcb>'.$dtnasrcb.'</dtnasrcb>';
	$xml .= '       <desenrcb>'.$desenrcb.'</desenrcb>';
	$xml .= '       <nmcidrcb>'.$nmcidrcb.'</nmcidrcb>';
	$xml .= '       <nrceprcb>'.$nrceprcb.'</nrceprcb>';
	$xml .= '       <cdufdrcb>'.$cdufdrcb.'</cdufdrcb>';
	$xml .= '       <flinfdst>'.$flinfdst.'</flinfdst>';
	$xml .= '       <recursos>'.$recursos.'</recursos>';
	$xml .= '       <cpfcgrcb>'.$cpfcgrcb.'</cpfcgrcb>';
	$xml .= '		<flgimpri>'.$flgimpri.'</flgimpri>';	
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {	
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo	= $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];
		$form = ( $operacao == 'C2' or $operacao == 'A2' ) ? "frmCab" : "frmCmedep";
		if (!empty($nmdcampo)) { $mtdErro = $mtdErro . "$('#".$nmdcampo."','#".$form."').focus();";  }
		if (!empty($nmdcampo)) { $mtdErro = "focaCampoErro('".$nmdcampo."','".$form."');";  }
				
		exibirErro('error',$msgErro,'Alerta - Ayllos',$mtdErro,false);
	}	
	
	// Consulta e Alteracao/Inclusao - busca os dados e mostra na tela
	if ( $operacao == 'C1' || $operacao == 'A1' || $operacao == 'A2' || $operacao == 'I1' || $operacao == 'I2') {
		$registros = $xmlObjeto->roottag->tags[0]->tags;
		
		$nrdconta = getByTagName($registros[0]->tags,'nrdconta');
		$nrdconta = mascara($nrdconta,"####.###.#");
		$nmcooptl = $nrdconta. "-" .getByTagName($registros[0]->tags,'nmcooptl');
		
		echo (getByTagName($registros[0]->tags,'nrseqaut') != "0") ? "$('#nrseqaut','#frmCmedep').val('".getByTagName($registros[0]->tags,'nrseqaut')."');" : "";		
		echo (getByTagName($registros[0]->tags,'vllanmto') != "0") ? "$('#vllanmto','#frmCmedep').val('".number_format(str_replace(",",".",getByTagName($registros[0]->tags,'vllanmto')),2,",",".")."');" : "";
		
		echo (getByTagName($registros[0]->tags,'nrdconta') != "") ? "$('#dsdconta','#frmCmedep').val('".$nmcooptl."');" : "";
		echo "$('#nrdconta','#frmCmedep').val('".getByTagName($registros[0]->tags,'nrdconta')."');";
		
		echo (getByTagName($registros[0]->tags,'dsdconta') != "") ? "$('#dsdconta','#frmCmedep').val('".getByTagName($registros[0]->tags,'dsdconta')."');" : "";
		echo "$('#nrccdrcb','#frmCmedep').val('".getByTagName($registros[0]->tags,'nrccdrcb')."').formataDado('INTEGER','zzzz.zzz-z','',false);";
		echo "$('#nmpesrcb','#frmCmedep').val('".getByTagName($registros[0]->tags,'nmpesrcb')."');";
		echo "$('#cpfcgrcb','#frmCmedep').val('".getByTagName($registros[0]->tags,'cpfcgrcb')."');";
		echo "$('#nridercb','#frmCmedep').val('".getByTagName($registros[0]->tags,'nridercb')."');";
		echo "$('#dtnasrcb','#frmCmedep').val('".getByTagName($registros[0]->tags,'dtnasrcb')."');";
		echo "$('#desenrcb','#frmCmedep').val('".getByTagName($registros[0]->tags,'desenrcb')."');";
		echo "$('#nmcidrcb','#frmCmedep').val('".getByTagName($registros[0]->tags,'nmcidrcb')."');";
		echo "$('#nrceprcb','#frmCmedep').val('".getByTagName($registros[0]->tags,'nrceprcb')."').formataDado('INTEGER','zzzzz-zzz','',false);";
		echo "$('#cdufdrcb','#frmCmedep').val('".getByTagName($registros[0]->tags,'cdufdrcb')."');";
		// mostra flag somente se for opcao diferente da busca de conta
		if ($operacao != "A2")  echo "$('#flinfdst','#frmCmedep').val('".getByTagName($registros[0]->tags,'flinfdst')."');";
		
		echo (getByTagName($registros[0]->tags,'recursos') != "") ? "$('#recursos','#frmCmedep').val('".getByTagName($registros[0]->tags,'recursos')."');" : "";		
	} elseif ($operacao == 'A3') {
		echo "operacao = 'A4';";
	} elseif ($operacao == 'A4'  || $operacao == 'I4') {
		echo "operacao = 'Aok';";
		
		if ($flgimpri == 'true') {
			
			// Obtém nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
			$nmarqpdf = $xmlObjeto->roottag->tags[0]->attributes["NMARQPDF"];
		
			echo 'showConfirmacao("Deseja visualizar a impress&atilde;o?","Confirma&ccedil;&atilde;o - Ayllos","imprimirDados(\''.$nmarqpdf.'\',\'yes\');btnVoltar();hideMsgAguardo();controlaLayout();","imprimirDados(\''.$nmarqpdf.'\',\'no\');btnVoltar();hideMsgAguardo();controlaLayout();","sim.gif","nao.gif");';
			exit();
		}
		
		echo "btnVoltar();";
		
	} elseif ($operacao == 'I3') {
		echo "operacao = 'I4';";
	}

	echo "hideMsgAguardo();";
	echo "controlaLayout();";
	
?>