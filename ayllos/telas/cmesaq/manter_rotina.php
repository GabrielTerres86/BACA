<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Gabriel
 * DATA CRIAÇÃO : 16/11/2011 
 * OBJETIVO     : Rotina para manter as operações da tela CMESAQ
 * --------------
 * ALTERAÇÕES   : 22/02/2012 - Alterações para tratar conta (quando tipo 0),
 *							   não permitindo registros duplicados. (Lucas)
 *
 *				  21/06/2012 - Adicionado confirmacao para impressao. (Jorge) 
 *					
 *				  29/06/2016 - Ajuste no campo de numero de conta que ao trazer
 *						       numero de conta zero concatenava um traço isso 
 *							   para ajustar o problema do chamado 467402. (Kelvin)									
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

	// Recebe a operação que está sendo realizada
	$operacao 	= (isset($_POST['operacao']))  ? $_POST['operacao']  : '' ; 
	
	// Cabecalho
	$dtdepesq = (isset($_POST['dtdepesq'])) ? $_POST['dtdepesq'] : '' ; 
	$cdagenci = (isset($_POST['cdagenci'])) ? $_POST['cdagenci'] : '' ; 
	$nrdcaixa = (isset($_POST['nrdcaixa'])) ? $_POST['nrdcaixa'] : '' ; 
	$cdbccxlt = (isset($_POST['cdbccxlt'])) ? $_POST['cdbccxlt'] : '' ; 
	$nrdolote = (isset($_POST['nrdolote'])) ? $_POST['nrdolote'] : '' ; 
	$nrdocmto = (isset($_POST['nrdocmto'])) ? $_POST['nrdocmto'] : '' ; 
	$tpdocmto = (isset($_POST['tpdocmto'])) ? $_POST['tpdocmto'] : '' ; 	
	$nrdcaixa = (isset($_POST['nrdcaixa'])) ? $_POST['nrdcaixa'] : '' ; 
	$cdopecxa = (isset($_POST['cdopecxa'])) ? $_POST['cdopecxa'] : '' ; 
	
	// Dados do sacador 
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '' ; 
    $nrccdrcb = (isset($_POST['nrccdrcb'])) ? $_POST['nrccdrcb'] : '' ;                                                         
    $nmpesrcb = (isset($_POST['nmpesrcb'])) ? $_POST['nmpesrcb'] : '' ;                                                         
    $nridercb = (isset($_POST['nridercb'])) ? $_POST['nridercb'] : '' ;                                                         
    $dtnasrcb = (isset($_POST['dtnasrcb'])) ? $_POST['dtnasrcb'] : '' ;                                                         
    $desenrcb = (isset($_POST['desenrcb'])) ? $_POST['desenrcb'] : '' ;                                                         
    $nmcidrcb = (isset($_POST['nmcidrcb'])) ? $_POST['nmcidrcb'] : '' ;                                                         
    $nrceprcb = (isset($_POST['nrceprcb'])) ? $_POST['nrceprcb'] : '' ;                                                         
    $cdufdrcb = (isset($_POST['cdufdrcb'])) ? $_POST['cdufdrcb'] : '' ;                                                         
    $flinfdst = (isset($_POST['flinfdst'])) ? $_POST['flinfdst'] : '' ;                                                         
    $dstrecur = (isset($_POST['dstrecur'])) ? $_POST['dstrecur'] : '' ;                                                         
    $cpfcgrcb = (isset($_POST['cpfcgrcb'])) ? $_POST['cpfcgrcb'] : '' ;	
	$flgimpri = (isset($_POST['flgimpri'])) ? $_POST['flgimpri'] : '' ;	
	$vlretesp = (isset($_POST['vlretesp'])) ? $_POST['vlretesp'] : '' ;	

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
	$xml .= '       <tpdocmto>'.$tpdocmto.'</tpdocmto>';
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
	$xml .= '       <dstrecur>'.$dstrecur.'</dstrecur>';
	$xml .= '       <cpfcgrcb>'.$cpfcgrcb.'</cpfcgrcb>';
	$xml .= '		<flgimpri>'.$flgimpri.'</flgimpri>';	
	$xml .= '		<vlretesp>'.$vlretesp.'</vlretesp>';		
	$xml .= '		<nrdcaixa>'.$nrdcaixa.'</nrdcaixa>';	
	$xml .= '		<cdopecxa>'.$cdopecxa.'</cdopecxa>';		
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
		$form = ( $operacao == 'C2' or $operacao == 'A2' ) ? "frmCab" : "frmCmesaq";
		if (!empty($nmdcampo)) { $mtdErro = $mtdErro . "$('#".$nmdcampo."','#".$form."').focus();";  }
		if (!empty($nmdcampo)) { $mtdErro = "focaCampoErro('".$nmdcampo."','".$form."');";  }
		exibirErro('error',$msgErro,'Alerta - Ayllos',$mtdErro,false);
	}	
	
	
	// Consulta e Alteracao/Inclusao - busca os dados e mostra na tela
	if ( $operacao == 'C1' || $operacao == 'A1' || $operacao == 'A2' || $operacao == 'I1' || $operacao == 'I2') {
		$registros = $xmlObjeto->roottag->tags[0]->tags;

		//Define Conta/DV e nome de Titl. para exibição.
		$nrdconta = getByTagName($registros[0]->tags,'nrdconta');
		$nrdconta = mascara($nrdconta,"####.###.#");
		$nmcooptl = ($nrdconta == "0") ? $nrdconta : $nrdconta. "-" .getByTagName($registros[0]->tags,'nmcooptl') ;		
		echo "$('#nrdconta','#frmCab2').val('".getByTagName($registros[0]->tags,'nrdconta')."');";
		
		echo (getByTagName($registros[0]->tags,'nrseqaut') != "0") ? "$('#nrseqaut','#frmCmesaq').val('".getByTagName($registros[0]->tags,'nrseqaut')."');" : "";
		echo (getByTagName($registros[0]->tags,'nrdconta') != "") ? "$('#dsdconta','#frmCmesaq').val('".$nmcooptl."');" : "";
		echo "$('#nrccdrcb','#frmCmesaq').val('".getByTagName($registros[0]->tags,'nrccdrcb')."').formataDado('INTEGER','zzzz.zzz-z','',false);";
		echo "$('#nmpesrcb','#frmCmesaq').val('".getByTagName($registros[0]->tags,'nmpesrcb')."');";
		echo "$('#cpfcgrcb','#frmCmesaq').val('".getByTagName($registros[0]->tags,'cpfcgrcb')."');";
		echo "$('#nridercb','#frmCmesaq').val('".getByTagName($registros[0]->tags,'nridercb')."');";
		echo "$('#dtnasrcb','#frmCmesaq').val('".getByTagName($registros[0]->tags,'dtnasrcb')."');";
		echo "$('#desenrcb','#frmCmesaq').val('".getByTagName($registros[0]->tags,'desenrcb')."');";
		echo "$('#nmcidrcb','#frmCmesaq').val('".getByTagName($registros[0]->tags,'nmcidrcb')."');";
		echo "$('#nrceprcb','#frmCmesaq').val('".getByTagName($registros[0]->tags,'nrceprcb')."').formataDado('INTEGER','zzzzz-zzz','',false);";
		echo "$('#cdufdrcb','#frmCmesaq').val('".getByTagName($registros[0]->tags,'cdufdrcb')."');";
		
		// mostra flag e valores do cme somente se for opcao diferente da busca de conta
		if ($operacao != "A2" && $operacao != "I2" ) { 
			echo (getByTagName($registros[0]->tags,'vllanmto') != "0") ? "$('#vllanmto','#frmCmesaq').val('".number_format(str_replace(",",".",getByTagName($registros[0]->tags,'vllanmto')),2,",",".")."');" : "";	
			echo "$('#flinfdst','#frmCmesaq').val('".getByTagName($registros[0]->tags,'flinfdst')."');"; 
			echo "$('#vlretesp','#frmCmesaq').val('".number_format(str_replace(",",".",getByTagName($registros[0]->tags,'vlretesp')),2,",",".")."');";
			echo "$('#vlmincen','#frmCmesaq').val('".number_format(str_replace(",",".",getByTagName($registros[0]->tags,'vlmincen')),2,",",".")."');";
		}
		
		echo (getByTagName($registros[0]->tags,'dstrecur') != "") ? "$('#dstrecur','#frmCmesaq').val('".getByTagName($registros[0]->tags,'dstrecur')."');" : "";		
	} elseif ($operacao == 'A3') {
		echo "operacao = 'A4';";
	} elseif ($operacao == 'A4'  || $operacao == 'I4') {
		
		if ($flgimpri == 'true') {
			
			// Obtém nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
			$nmarqpdf = $xmlObjeto->roottag->tags[0]->attributes["NMARQPDF"];
			
			echo 'showConfirmacao("Deseja visualizar a impress&atilde;o?","Confirma&ccedil;&atilde;o - Ayllos","imprimirDados(\''.$nmarqpdf.'\',\'yes\');btnVoltar();hideMsgAguardo();controlaLayout();","imprimirDados(\''.$nmarqpdf.'\',\'no\');btnVoltar();hideMsgAguardo();controlaLayout();","sim.gif","nao.gif");';
			$nrdconta = 0;
			exit();
		}
			
		echo "btnVoltar('voltar');";
		
	} elseif ($operacao == 'I3') {
		echo "operacao = 'I4';";
	}
    $nrdconta = 0;
	echo "hideMsgAguardo();";
	echo "controlaLayout();";
	
?>