<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Lucas Lunelli         
 * DATA CRIAÇÃO : 06/02/2013 
 * OBJETIVO     : Rotina para manter as operações da tela ADMISS
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
	$procedure 		= '';
	$retornoAposErro= '';
	
	// Recebe a operação que está sendo realizada
	$cddopcao		= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ; 
	$vlcapini		= (isset($_POST['vlcapini'])) ? $_POST['vlcapini'] : 0  ; 
	$vlcapsub		= (isset($_POST['vlcapsub'])) ? $_POST['vlcapsub'] : 0  ; 
	$qtparcap		= (isset($_POST['qtparcap'])) ? $_POST['qtparcap'] : 0  ; 
	$flgabcap		= (isset($_POST['flgabcap'])) ? $_POST['flgabcap'] : '' ; 
	$numdopac		= (isset($_POST['numdopac'])) ? $_POST['numdopac'] : '' ; 	
	$nrregist		= (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 0  ;
	$nriniseq		= (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 0  ;
	$dtdemiss		= (isset($_POST['dtdemiss'])) ? $_POST['dtdemiss'] : '' ;
	$dtdecons		= (isset($_POST['dtdecons'])) ? $_POST['dtdecons'] : '' ;
	$dtatecon		= (isset($_POST['dtatecon'])) ? $_POST['dtatecon'] : '' ;
		
	// Dependendo da operação, chamo uma procedure diferente
	switch($cddopcao) {
		case 'A': $procedure = 'altera-admiss';	  	break;
		case 'C': $procedure = 'consulta-admiss';	break;
		case 'D': $procedure = 'lista-demiss-pac';	break;
		case 'L': $procedure = 'lista-admiss-pac';	break;
		case 'N': $procedure = 'impressao-admiss';	break;
	}
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0150.p</Bo>';
	$xml .= '		<Proc>'.$procedure.'</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';	
	$xml .= '		<flgerlog>YES</flgerlog>';
	$xml .= '		<vlcapini>'.$vlcapini.'</vlcapini>';
	$xml .= '		<qtparcap>'.$qtparcap.'</qtparcap>';
	$xml .= '		<numdopac>'.$numdopac.'</numdopac>';
	$xml .= '		<vlcapsub>'.$vlcapsub.'</vlcapsub>';
	$xml .= '       <nrregist>'.$nrregist.'</nrregist>';
	$xml .= '       <nriniseq>'.$nriniseq.'</nriniseq>';
	$xml .= '		<flgabcap>'.$flgabcap.'</flgabcap>';
	$xml .= '		<dtdemiss>'.$dtdemiss.'</dtdemiss>';
	$xml .= '		<dtdecons>'.$dtdecons.'</dtdecons>';
	$xml .= '		<dtatecon>'.$dtatecon.'</dtatecon>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);
	
	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
	
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}
	
	if ($cddopcao == "C"){
		
		$qtassmes = formataNumericos("zzz.zz9",$xmlObjeto->roottag->tags[0]->attributes["QTASSMES"],".,");
		$qtadmmes = formataNumericos("zzz.zz9",$xmlObjeto->roottag->tags[0]->attributes["QTADMMES"],".,");
		$qtdslmes = formataNumericos("zzz.zz9",$xmlObjeto->roottag->tags[0]->attributes["QTDSLMES"],".,");
		$nrmatric = formataNumericos("zzz.zz9",$xmlObjeto->roottag->tags[0]->attributes["NRMATRIC"],".,");
		$vlcapini = formataMoeda($xmlObjeto->roottag->tags[0]->attributes["VLCAPINI"]);
		$vlcapsub = formataMoeda($xmlObjeto->roottag->tags[0]->attributes["VLCAPSUB"]);
		$qtparcap = formataNumericos("z9",$xmlObjeto->roottag->tags[0]->attributes["QTPARCAP"],".,");
		$flgabcap = $xmlObjeto->roottag->tags[0]->attributes["FLGABCAP"];
		
		$flgabcap = strtoupper($flgabcap);
	
		echo "$('#qtassmes','#frmDadosAdmiss').val('$qtassmes');";
		echo "$('#qtadmmes','#frmDadosAdmiss').val('$qtadmmes');";
		echo "$('#qtdslmes','#frmDadosAdmiss').val('$qtdslmes');";
		echo "$('#vlcapini','#frmDadosAdmiss').val('$vlcapini');";
		echo "$('#nrmatric','#frmDadosAdmiss').val('$nrmatric');";
		echo "$('#qtparcap','#frmDadosAdmiss').val('$qtparcap');";
		echo "$('#vlcapsub','#frmDadosAdmiss').val('$vlcapsub');";
		echo "$('#flgabcap','#frmDadosAdmiss').val('$flgabcap');";
		
	} elseif ($cddopcao == "A") {
	
		echo 'showError("inform","Dados alterados com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';	
		
		
	} elseif ($cddopcao == "L" || $cddopcao == "D") {
	
		$qtadmmes 	= $xmlObjeto->roottag->tags[0]->attributes["QTADMMES"];
		$qtregist 	= $xmlObjeto->roottag->tags[0]->attributes["QTREGIST"];
		$registros 	= $xmlObjeto->roottag->tags[0]->tags;
		
		
		if ($cddopcao == "L") {
			include('tab_admiss.php');
		} else {
			include('tab_demiss.php');
		}
		
		?>
		<script>
		
			 $('#qtadmtot','#frmOpcao').val('<? echo $qtregist; ?>');
			
		</script>
<? } ?>
