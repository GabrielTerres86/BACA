<? 
/*!
 * FONTE        : replica_parametro_coop.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 05/03/2013
 * OBJETIVO     : Rotina para busca parametro por cooperativa.
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
	$cdcopatu		= (isset($_POST['cdcopatu'])) ? $_POST['cdcopatu'] : 0  ; 	
	$cdpartar		= (isset($_POST['cdpartar'])) ? $_POST['cdpartar'] : 0  ; 	
	$dsconteu       = (isset($_POST['dsconteu'])) ? $_POST['dsconteu'] : '' ; 	
	$tpdedado		= (isset($_POST['tpdedado'])) ? $_POST['tpdedado'] : 0  ; 
	

	// Dependendo da operação, chamo uma procedure diferente
	$procedure = 'replica-cooperativas';
	
	$retornoAposErro = 'focaCampoErro(\'cdtarifa\', \'frmCab\');';
	
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
	$xml .= '		<cdcopatu>'.$cdcopatu.'</cdcopatu>';
	$xml .= '		<cdpartar>'.$cdpartar.'</cdpartar>';
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

	echo '<form id="frmReplicaCoop" name="frmReplicaCoop" class="formulario cabecalho" onSubmit="return false;" >';
	
	echo	'<div class="divRegistros" style="height: 300px; padding-bottom: 2px; border-right:0px">';
		
	echo		'<table width="100%" border="1" valign="center">';

	echo	'<tr>';
	echo		'<td style="border-right:none;padding:0;" width="30" align="center" valign="center">';
	echo			'<input type="checkbox" name="flgcheckall" id="flgcheckall" checked value="no" style="float:none; height:16;"/>';
	echo		'</td>';
	echo		'<td style="border-right:none;padding:0;" valign="center">';
	echo			'<label for="dsconteu">'.utf8ToHtml('Cooperativa').'</label>';
	echo		'</td>';
	echo		'<td style="border-right:none;padding:0;" valign="center">';
	echo			'<label for="dsconteu2">'.utf8ToHtml('Conteudo').'</label>';
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
		echo '		<label for="dsconteu">'.getByTagName($r->tags,'nmrescop').'</label>';
		echo '	</td>';
		echo '	<td style="border-right:none;padding:0;" valign="center">';		
		echo '		<input class="cdsconteu" type="text" id="dsconteu'.$conta.'" name="dsconteu'.$conta.'" value="'.$dsconteu.'" maxlength="255" />	';
		echo '	</td>';
		echo '</tr>';		
		
		if ( $tpdedado == 1 ) {
			?>
				<script>
				
					$('<? echo '#dsconteu'.$conta;?>','#frmReplicaCoop').unbind('keypress').bind('keypress', function(e) {
						$('<? echo '#dsconteu'.$conta;?>','#frmReplicaCoop').val(retirarZeros($('<? echo '#dsconteu'.$conta;?>','#frmReplicaCoop').val())) ;
					});
				</script>
			<?
		}
		
	} 	
			
	echo		'</table>';
	echo	'</div>';
	echo 	'<input type="hidden" id="numocorr" name="numocorr" value="'.$conta.'" />';
	echo '</form>';
	
	echo '<div id="divBotoesReplicaCoop" style="margin-top:5px; margin-bottom :10px; text-align:center;">';
	echo 	'<a href="#" class="botao" id="btVoltar"   onClick="fechaTela();return false;">&nbsp;Voltar&nbsp;</a>';	
	echo	'<a href="#" class="botao" id="btAlterar"   onClick="realizaOperacaoPco(\'R\');">Concluir</a>';
	echo '</div>';
			
			
?>
