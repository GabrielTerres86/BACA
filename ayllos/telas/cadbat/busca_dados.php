<? 
/*!
 * FONTE        : busca_dados.php
 * CRIAÇÃO      : Tiago Machado        
 * DATA CRIAÇÃO : 19/04/2013 
 * OBJETIVO     : Rotina para buscar grupo na tela CADGRU
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
	$cdbattar		= (isset($_POST['cdbattar'])) ? $_POST['cdbattar'] : ''  ; 
	

	// Dependendo da operação, chamo uma procedure diferente
	$procedure = 'buscar-cadbat';
	
	$retornoAposErro = 'focaCampoErro(\'cdbattar\', \'frmCab\');';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
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
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';	
	$xml .= '		<cdbattar>'.$cdbattar.'</cdbattar>';	
	$xml .= '		<flgerlog>YES</flgerlog>';
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
	
	$nmidenti = $xmlObjeto->roottag->tags[0]->attributes["NMIDENTI"];
	$cdprogra = $xmlObjeto->roottag->tags[0]->attributes["CDPROGRA"];
	$tpcadast = $xmlObjeto->roottag->tags[0]->attributes["TPCADAST"];
	$cdcadast = $xmlObjeto->roottag->tags[0]->attributes["CDCADAST"];
	
	echo "$('#cdbattar','#frmCab').desabilitaCampo();";
	echo "$('#nmidenti','#frmCab').val('$nmidenti');";
	echo "$('#tpcadast','#frmCab').val('$tpcadast');";
	echo "$('#cdprogra','#frmCab').val('$cdprogra');";
	
	
	if($tpcadast == 1){
		echo "$('#tpcadast','#frmCab').val(1);";
		echo "$('label[for=\"cdprogra\"]','#frmCab').show();";
		echo "$('#cdprogra','#frmCab').show();";
		echo "$('#frmDadosTarifa').show();";
		echo "$('#frmDadosParametro').hide();";
		
		if ( $cdcadast == "0"){
			echo "$('#cdtarifa','#frmDadosTarifa').val('');";	
		}else{
			echo "$('#cdtarifa','#frmDadosTarifa').val('$cdcadast');";
		}
		
		echo "$('#cdtarifa','#frmDadosTarifa').focus();";
	} else {
		echo "$('#tpcadast','#frmCab').val(2);";
		echo "$('label[for=\"cdprogra\"]','#frmCab').hide();";
		echo "$('#cdprogra','#frmCab').hide();";
		echo "$('#frmDadosTarifa').hide();";
		echo "$('#frmDadosParametro').show();";
		
		if ( $cdcadast == "0" ){
			echo "$('#cdpartar','#frmDadosParametro').val('');";
		}else{
			echo "$('#cdpartar','#frmDadosParametro').val('$cdcadast');";
		}
	
		echo "$('#cdpartar','#frmDadosTarifa').focus();";
	}		
		
	if ($cddopcao == "C"){
		echo "$('#cdpartar','#frmDadosParametro').desabilitaCampo();";
		echo "$('#cdtarifa','#frmDadosTarifa').desabilitaCampo();";		
		echo "$('#btnVoltar','#frmCab').focus();";
		echo "trocaBotao('');";
		
		if($cdcadast > 0){		
			if($tpcadast == 1){
				echo "buscarTarifa();";
			}

			if($tpcadast == 2){
				echo "buscarParametro();";
			}
		}
	}
		
	if ($cddopcao == "A"){	
		echo "trocaBotao('Alterar');";
		
		echo "$('#frmDadosParametro').hide();";
		echo "$('#frmDadosTarifa').hide();";
		
		echo "$('#nmidenti','#frmCab').habilitaCampo();";
		
		if($tpcadast == 1){
			echo "$('#cdprogra','#frmCab').habilitaCampo();";
		}
		
		echo "$('#nmidenti','#frmCab').focus();";
	}

	if ($cddopcao == "I"){
		echo "trocaBotao('Incluir');";
		
		echo "$('#frmDadosParametro').hide();";
		echo "$('#frmDadosTarifa').hide();";
	}
	
	if ($cddopcao == "E"){
		echo "$('#cdbattar','#frmCab').desabilitaCampo();";
		echo "trocaBotao('Excluir');";
	}
			
	if ($cddopcao == "V"){
		echo "$('#cdbattar','#frmCab').desabilitaCampo();";

		if($cdcadast > 0){		
			if($tpcadast == 1){
				echo "buscarTarifa();";
				
				echo "$('#cdtarifa','#frmDadosTarifa').focus();";
			}

			if($tpcadast == 2){
				echo "buscarParametro();";				
			}
		}

		
		echo "trocaBotao('Vincular');";
	}
?>
