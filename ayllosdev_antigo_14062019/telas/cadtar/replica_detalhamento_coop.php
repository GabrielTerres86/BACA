<? 
/*!
 * FONTE        : replica_detalhamento_coop.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 05/04/2013
 * OBJETIVO     : Rotina para replicar detalhamento por cooperativa.
 * --------------
 * ALTERAÇÕES   : 02/08/2013 - Incluso tratamento para replicacao registros
 *							   de cobranca (Daniel). 
 *
 *                26/11/2015 - Ajustado para buscar os convenios de folha de pagamento
 *                             (Andre Santos - SUPERO)
 *
 *				  11/07/2017 - Inclusao das novas colunas e campos "Tipo de tarifacao", "Percentual", "Valor Minimo" e 
 *                             "Valor Maximo" (Mateus - MoutS)
 *
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
	$cdfaixav		= (isset($_POST['cdfaixav'])) ? $_POST['cdfaixav'] : 0  ; 	
	$cdcopatu		= (isset($_POST['cdcopatu'])) ? $_POST['cdcopatu'] : '' ; 
	$vlrepass		= (isset($_POST['vlrepass'])) ? $_POST['vlrepass'] : 0  ; 	
	$vltarifa       = (isset($_POST['vltarifa'])) ? $_POST['vltarifa'] : 0  ; 		
	$dtdivulg       = (isset($_POST['dtdivulg'])) ? $_POST['dtdivulg'] : 0  ; 		
	$dtvigenc       = (isset($_POST['dtvigenc'])) ? $_POST['dtvigenc'] : 0  ; 		
	$cddopcao		= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ; 
//	$flgcoban		= (isset($_POST['flgcoban'])) ? $_POST['flgcoban'] : 0 ; 
	$nrcnvatu 		= (isset($_POST['nrcnvatu'])) ? $_POST['nrcnvatu'] : 0  ;
	$cdocorre		= (isset($_POST['cdocorre'])) ? $_POST['cdocorre'] : 0  ;
	
	$cdtipcat		= (isset($_POST['cdtipcat'])) ? $_POST['cdtipcat'] : 0 ; 
	$cdlcratu		= (isset($_POST['cdlcratu'])) ? $_POST['cdlcratu'] : 0 ; 
	$cdinctar		= (isset($_POST['cdinctar'])) ? $_POST['cdinctar'] : 0 ;

	$flgtiptar      = (isset($_POST['flgtiptar'])) ? $_POST['flgtiptar'] : 0 ;
	$vlperc         = (isset($_POST['vlperc'])) ? $_POST['vlperc'] : 0 ;
	$vlminimo       = (isset($_POST['vlminimo'])) ? $_POST['vlminimo'] : 0 ;
	$vlmaximo       = (isset($_POST['vlmaximo'])) ? $_POST['vlmaximo'] : 0 ;

	$procedure = 'replica-cooperativas-det';
	
	if ( $cdtipcat == 2 ) { // 2 - Convenio
		$procedure = 'replica-cooperativas-det-cob';
	}

	$retornoAposErro = 'focaCampoErro(\'cdcooper\', \'frmAtribuicaoDetalhamento\');';
	
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
	$xml .= '		<cdfaixav>'.$cdfaixav.'</cdfaixav>';
	$xml .= '		<cdcopatu>'.$cdcopatu.'</cdcopatu>';
	$xml .= '		<vlinifvl>'.$vlinifvl.'</vlinifvl>';
	$xml .= '		<vlfinfvl>'.$vlfinfvl.'</vlfinfvl>';
	$xml .= '		<nrcnvatu>'.$nrcnvatu.'</nrcnvatu>';
	$xml .= '		<cdocorre>'.$cdocorre.'</cdocorre>';
	$xml .= '		<cdlcratu>'.$cdlcratu.'</cdlcratu>';
	$xml .= '		<cdtipcat>'.$cdtipcat.'</cdtipcat>';
	$xml .= '		<cdinctar>'.$cdinctar.'</cdinctar>';
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
	
	$cooperativas = $xmlObjeto->roottag->tags[0]->tags; 

	echo '<form id="formAtribuicaoDetalhamento" name="formAtribuicaoDetalhamento" class="formulario" onSubmit="return false;" >';
	
	echo	'<div class="divRegistros" style="height: 210px; padding-bottom: 2px; border-right:0px">';
		
	echo		'<table width="100%" border="1" valign="center">';

	echo	'<tr>';
	echo		'<td style="border-right:none;padding:0;" width="30" align="center" valign="center">';
	echo			'<input type="checkbox" name="flgcheckall" id="flgcheckall" checked value="no" style="float:none; height:16;"/>';
	echo		'</td>';
	echo		'<td style="border-right:none;padding:0;" valign="center">';
	echo			'<label for="cdcooper3">'.utf8ToHtml('Cooperativa').'</label>';
	echo		'</td>';
	echo		'<td style="border-right:none;padding:0;" valign="center">';
	echo			'<label class="oculta" for="nrconven3">'.utf8ToHtml('Conv&ecirc;nio').'</label>';
	echo		'</td>';
	echo		'<td style="border-right:none;padding:0;" valign="center">';
	echo			'<label class="linhaCredito" for="cdlcremp3">'.utf8ToHtml('Linha Credito').'</label>';
	echo		'</td>';
	echo		'<td style="border-right:none;padding:0;" valign="center">';
	echo			'<label for="dtdivulg3">'.utf8ToHtml('Data divulga&ccedil;&atilde;o').'</label>';
	echo		'</td>';
	echo		'<td style="border-right:none;padding:0;" valign="center">';
	echo			'<label for="dtvigenc3">'.utf8ToHtml('Data vig&ecirc;ncia').'</label>';
	echo		'</td>';
	echo		'<td style="border-right:none;padding:0;" valign="center">';
	echo			'<label for="vltarifa3">'.utf8ToHtml('Tarifa').'</label>';
	echo		'</td>';	
	echo		'<td style="border-right:none;padding:0;" valign="center">';
	echo			'<label for="vlperc2">'.utf8ToHtml('Percentual').'</label>';
	echo		'</td>';
	echo		'<td style="border-right:none;padding:0;" valign="center">';
	echo			'<label for="vlminimo2">'.utf8ToHtml('Vl.Min').'</label>';
	echo		'</td>';
	echo		'<td style="border-right:none;padding:0;" valign="center">';
	echo			'<label for="vlmaximo2">'.utf8ToHtml('Vl.Max').'</label>';
	echo		'</td>';
	echo		'<td style="border-right:none;padding:0;" valign="center">';
	echo			'<label for="vlrepass3">'.utf8ToHtml('Custo').'</label>';
	echo		'</td>';
	echo	'</tr>';
	
	
	$conta = 0;
	foreach( $cooperativas as $r ) { 	
		
		$conta++;
		echo '<tr>';
		echo '	<td style="border-right:none;padding:0;" width="30" align="center" valign="center">';
		
		if( getByTagName($r->tags,'cdcooper') == "3" ){
			echo '		<input class="flgcheck" type="checkbox" name="flgcheck'.$conta.'" id="flgcheck'.$conta.'" value="no" style="float:none; height:16;"/>';
		}else{		
			echo '		<input class="flgcheck" type="checkbox" name="flgcheck'.$conta.'" id="flgcheck'.$conta.'" checked value="no" style="float:none; height:16;"/>';
		}	
		echo '	</td>';
		echo '	<td style="border-right:none;padding:0;" valign="center">';
		echo '		<input type="hidden" id="cdcooper'.$conta.'" name="cdcooper'.$conta.'" value="'.getByTagName($r->tags,'cdcooper').'" />';
		echo '		<input type="hidden" id="cdfvlcop'.$conta.'" name="cdfvlcop'.$conta.'" value="'.getByTagName($r->tags,'cdfvlcop').'" />';
		echo '		<label for="cdcooper">'.getByTagName($r->tags,'nmrescop').'</label>';
		echo '	</td>';
		echo '	<td style="border-right:none;padding:0;" valign="center">';		
		echo '		<input class="oculta campoTelaSemBorda" style="width:100;text-align:right" readonly disabled type="text" id="nrconventab'.$conta.'" name="nrconven'.$conta.'" value="'.getByTagName($r->tags,'nrconven').'" />	';
		echo '	</td>';
		echo '	<td style="border-right:none;padding:0;" valign="center">';		
		echo '		<input class="linhaCredito campoTelaSemBorda" style="width:100;text-align:right" readonly disabled type="text" id="cdlcremptab'.$conta.'" name="cdlcremp'.$conta.'" value="'.getByTagName($r->tags,'cdlcremp').'" />	';
		echo '	</td>';
		echo '	<td style="border-right:none;padding:0;" valign="center">';		
		echo '		<input class="campo dataDet" style="width:100" type="text" id="dtdivulg'.$conta.'" name="dtdivulg'.$conta.'" value="'.$dtdivulg.'"  />	';
		echo '	</td>';
		echo '	<td style="border-right:none;padding:0;" valign="center">';		
		echo '		<input class="campo dataDet" style="width:100" type="text" id="dtvigenc'.$conta.'" name="dtvigenc'.$conta.'" value="'.$dtvigenc.'"  />	';
		echo '	</td>';
		echo '	<td style="border-right:none;padding:0;" valign="center">';		
		echo '		<input class="campo moedaDet" style="width:100" type="text" id="vltarifatab'.$conta.'" name="vltarifa'.$conta.'" value="'.$vltarifa.'" onchange="limparCamposTipoPerc(this.id);"  />	';
		echo '	</td>';		
		echo '	<td style="border-right:none;padding:0;" valign="center">';		
		echo '		<input class="campo moedaDet" style="width:100" type="text" id="vlperctab'.$conta.'" name="vlperc'.$conta.'" value="'.$vlperc.'" onchange="limparCamposTipoFixo(this.id);"  />	';
		echo '	</td>';
		echo '	<td style="border-right:none;padding:0;" valign="center">';		
		echo '		<input class="campo moedaDet" style="width:100" type="text" id="vlminimotab'.$conta.'" name="vlminimo'.$conta.'" value="'.$vlminimo.'" onchange="limparCamposTipoFixo(this.id);"  />	';
		echo '	</td>';		
		echo '	<td style="border-right:none;padding:0;" valign="center">';		
		echo '		<input class="campo moedaDet" style="width:100" type="text" id="vlmaximotab'.$conta.'" name="vlmaximo'.$conta.'" value="'.$vlmaximo.'" onchange="limparCamposTipoFixo(this.id);"  />	';
		echo '	</td>';
		echo '	<td style="border-right:none;padding:0;" valign="center">';		
		echo '		<input class="campo moedaDet" style="width:100" type="text" id="vlrepasstab'.$conta.'" name="vlrepass'.$conta.'" value="'.$vlrepass.'"  />	';
		echo '	</td>';
		echo '</tr>';		
		
	} 	
			
	echo		'</table>';
	echo	'</div>';
	echo 	'<input type="hidden" id="numocorr" name="numocorr" value="'.$conta.'" />';
	echo '</form>';
	
?>
