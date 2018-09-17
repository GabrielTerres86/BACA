<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 31/05/2011 
 * OBJETIVO     : Rotina para manter (validar e alterar) as operações da tela CADINS
 *
 * ALTERACOES   : 11/06/2012 - Adicionado confirmacao de impressao quando chamado funcao trataImpressao() (Jorge).
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
	$cddopcao = 'A';
	$cdaltera = (isset($_POST['cdaltera'])) ? $_POST['cdaltera'] : '' ;
	$nrbenefi = (isset($_POST['nrbenefi'])) ? $_POST['nrbenefi'] : '' ;
	$nrrecben = (isset($_POST['nrrecben'])) ? $_POST['nrrecben'] : '' ;
	$nmrecben = (isset($_POST['nmrecben'])) ? $_POST['nmrecben'] : '' ;
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '' ;
	$nrnovcta = (isset($_POST['nrnovcta'])) ? $_POST['nrnovcta'] : '' ;
	$cdaltcad = (isset($_POST['cdaltcad'])) ? $_POST['cdaltcad'] : '' ;
	$cdagcpac = (isset($_POST['cdagcpac'])) ? $_POST['cdagcpac'] : 0;
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '' ;
	$dsiduser = session_id();
	$idseqttl = 0;
	
	// Dependendo da operação, chamo uma procedure diferente
	$procedure = '';
	switch($operacao) { 
		case 'V' : $procedure = 'valida-opcao';   $mtdErro = 'unblockBackground();cOpcao.focus();';  break;
		case 'V2': $procedure = 'valida-nvconta'; $mtdErro = 'unblockBackground();cNConta.focus();'; break;
		case 'V9': $procedure = 'valida-nvconta'; $mtdErro = 'unblockBackground();cNConta.focus();'; break;
		case 'T' : $procedure = 'trata-opcao';    $mtdErro = 'unblockBackground();cOpcao.focus();';  break;
		case 'T2': $procedure = 'trata-opcao';    $mtdErro = 'unblockBackground();cNConta.focus();'; break;
		case 'T9': $procedure = 'trata-opcao';    $mtdErro = 'unblockBackground();cNConta.focus();'; break;
		default:   $mtdErro   = 'unblockBackground();'; return false;
	}
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
				
	// Monta o xml dinâmico de acordo com a operação
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0091.p</Bo>';
	$xml .= '		<Proc>'.$procedure.'</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>'; 
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '       <cdaltera>'.$cdaltera.'</cdaltera>'; 	
	$xml .= '       <nrbenefi>'.$nrbenefi.'</nrbenefi>'; 	
	$xml .= '       <nrrecben>'.$nrrecben.'</nrrecben>'; 	
	$xml .= '       <nmrecben>'.$nmrecben.'</nmrecben>'; 	
	$xml .= '       <nrdconta>'.$nrdconta.'</nrdconta>'; 	
	$xml .= '       <idseqttl>'.$idseqttl.'</idseqttl>'; 	
	$xml .= '       <nrnovcta>'.$nrnovcta.'</nrnovcta>';    	
	$xml .= '       <cdaltcad>'.$cdaltcad.'</cdaltcad>';    	
	$xml .= '       <dsiduser>'.$dsiduser.'</dsiduser>';    	
	$xml .= '       <cdagcpac>'.$cdagcpac.'</cdagcpac>';    	
	$xml .= '	</Dados>';                                  
	$xml .= '</Root>';                                      
	
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {	
		$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo	= $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];
		if ( !empty($nmdcampo) ) { $mtdErro = $mtdErro . " $('#".$nmdcampo."').focus();";  }
		exibirErro('error',$msgErro,'Alerta - Ayllos',$mtdErro,false);
	}	
	
	$msgRetorno = $xmlObjeto->roottag->tags[0]->attributes['MSGRETOR'];
	$nmprimtl   = $xmlObjeto->roottag->tags[0]->attributes['NMPRIMTL'];
	$tpnovmpg   = $xmlObjeto->roottag->tags[0]->attributes['TPNOVMPG'];
	$nrnovcta   = $xmlObjeto->roottag->tags[0]->attributes['NRNOVCTA'];
	$nmarqpdf   = $xmlObjeto->roottag->tags[0]->attributes['NMARQPDF'];
	
	if( $operacao == 'V' ){
					
		if ( $cdaltera == 2 || $cdaltera == 9 ){
			if( $msgRetorno != '' ){
				$mtdConfirm = 'showConfirmacao(\'078 - Confirma a operacao?\'	,\'Confirma&ccedil;&atilde;o - Anota\',\'controlaOperacao();\',\'cOpcao.focus();\',\'sim.gif\',\'nao.gif\');';
				echo "rNMeio.css('display','block');";
				echo "cNMeio.css('display','block');";
				echo "cNMeio.val(".$tpnovmpg.");";
				
				echo "rNome1.css('display','block');";
				echo "cNome1.css('display','block');";
				echo "cNome1.val('".$nmprimtl."');";
				
				echo "cNConta.val('".$nrnovcta."');";
				echo "cNConta.trigger('blur');";
				
				exibirErro('inform',$msgRetorno,'Alerta - Ayllos',$mtdConfirm,false);
			}else{
				echo 'controlaOperacao()';
			}
			
		}else if ( $cdaltera == 91 ) {
			echo "rNMeio.css('display','block');";
			echo "cNMeio.css('display','block');";
			echo "rNome1.css('display','block');";
			echo "cNome1.css('display','block');";
			
			echo "cNConta.val('".formataContaDV($nrnovcta)."');";
			echo "cNMeio.val('".$tpnovmpg."');" ;
			echo "cNome1.val('".$nmprimtl."');" ;
		
			echo 'controlaOperacao();';
			echo 'cOpcao.focus();';

		}else if ( $cdaltera == 93 ) {
			echo 'controlaOperacao();';
			echo 'cOpcao.focus();';
			
		} else {
			exibirConfirmacao('1078 - Confirma a operacao?','Confirmação - Ayllos','controlaOperacao()','cOpcao.focus();',false);
		}
	
	}else if( $operacao == 'V2' ){
					
		echo "rNMeio.css('display','block');";
		echo "cNMeio.css('display','block');";
		echo "rNome1.css('display','block');";
		echo "cNome1.css('display','block');";
		echo "cNMeio.val(2);" ;
		echo "cNome1.val('".$nmprimtl."');" ;
		
		$mtdSim  = "cNData.val('');";
		$mtdSim .= "cData.val('".$glbvars['dtmvtolt']."');";
		$mtdSim .= "manterRotina('T2');";
				
		$mtdNao  = "cNMeio.val('');";
		$mtdNao .= "cNConta.val('');";
		$mtdNao .= "cNome1.val('');";
		$mtdNao .= "rNMeio.css('display','none');";
		$mtdNao .= "cNMeio.css('display','none');";
		$mtdNao .= "rNome1.css('display','none');";
		$mtdNao .= "cNome1.css('display','none');";
				
		exibirConfirmacao('078 - Confirma a operacao?','Confirmação - Ayllos',$mtdSim,$mtdNao,false);
		
	}else if( $operacao == 'V9' ){
					
		echo "rNMeio.css('display','block');";
		echo "cNMeio.css('display','block');";
		echo "rNome1.css('display','block');";
		echo "cNome1.css('display','block');";
		echo "cNMeio.val(2);" ;
		echo "cNome1.val('".$nmprimtl."');" ;
		
		$mtdSim  = "cNData.val('');";
		$mtdSim .= "cData.val('".$glbvars['dtmvtolt']."');";
		$mtdSim .= "manterRotina('T9');";
				
		$mtdNao  = "cNMeio.val('');";
		$mtdNao .= "cNConta.val('');";
		$mtdNao .= "cNome1.val('');";
		$mtdNao .= "rNMeio.css('display','none');";
		$mtdNao .= "cNMeio.css('display','none');";
		$mtdNao .= "rNome1.css('display','none');";
		$mtdNao .= "cNome1.css('display','none');";
				
		exibirConfirmacao('078 - Confirma a operacao?','Confirmação - Ayllos',$mtdSim,$mtdNao,false);
		
	}else if( $operacao == 'T' ){
		
		if( $cdaltera == 1 ){
			echo "rNMeio.css('display','block');";
			echo "cNMeio.css('display','block');";
			echo "cNMeio.val(1);" ;
			echo "cData.val( '".$glbvars['dtmvtolt']."');";
			exibirConfirmacao('Deseja visualizar a impress&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','trataImpressao(\"'.$nmarqpdf.'\")','cOpcao.focus();',false);
		
		}else if( $cdaltera == 90 ){
		
			echo "cNMeio.val('');" ;
			echo "cData.val('');"  ;
			echo "cNConta.val('');";
			echo "cNData.val('');" ;
			echo "cNome1.val('');" ;
			
			echo "rNMeio.css('display','none');";
			echo "cNMeio.css('display','none');";
			echo "rNome1.css('display','none');";
			echo "cNome1.css('display','none');";
					
		}else if( $cdaltera == 92 ){
			echo "cData.val('".$glbvars['dtmvtolt']."');";
	
		}
		
		echo "cOpcao.focus();";
		
	}else if( $operacao == 'T2' ){
	
		$nmarqpdf = $xmlObjeto->roottag->tags[0]->attributes['NMARQPDF'];
	
		echo "cNConta.desabilitaCampo();";
		echo "cOpcao.habilitaCampo();";
		
		exibirConfirmacao('Deseja visualizar a impress&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','trataImpressao(\"'.$nmarqpdf.'\")','cOpcao.focus();',false);
		
		echo "cOpcao.focus();";
	
	}else if( $operacao == 'T9' ){
		
		echo "cNConta.desabilitaCampo();";
		echo "cOpcao.habilitaCampo();";
	
		exibirConfirmacao('Deseja visualizar a impress&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','trataImpressao(\"'.$nmarqpdf.'\")','cOpcao.focus();',false);
		
		echo "cOpcao.focus();";
	}
					
?>