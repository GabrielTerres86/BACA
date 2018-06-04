<? 
/*!
 * FONTE        : busca_tarifas_estorno.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 20/03/2013
 * OBJETIVO     : Rotina para buscar tarifas de determinada conta na tela ESTTAR
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
	$retornoAposErro	= 'cCdhistor.focus();';
	
	// Recebe a operação que está sendo realizada
	$nrdconta			= (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0 ; 
	$cddopcap			= (isset($_POST['cddopcap'])) ? $_POST['cddopcap'] : 0 ; 
	$dtinicio			= (isset($_POST['dtinicio'])) ? $_POST['dtinicio'] : 0 ; 
	$dtafinal			= (isset($_POST['dtafinal'])) ? $_POST['dtafinal'] : 0 ; 
	$cdhistor			= (isset($_POST['cdhistor'])) ? $_POST['cdhistor'] : 0 ; 
	
  $cddopcap = ($cddopcap == 3 ? 1 : $cddopcap);

	$procedure = 'lista_tarifas_estorno';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> '') {		
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
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<cddopcap>'.$cddopcap.'</cddopcap>';
	$xml .= '		<dtinicio>'.$dtinicio.'</dtinicio>';
	$xml .= '		<dtafinal>'.$dtafinal.'</dtafinal>';
	$xml .= '		<cdhistor>'.$cdhistor.'</cdhistor>';
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

	$estorno 	= $xmlObjeto->roottag->tags[0]->tags;
	
	$vlrtotal = $xmlObjeto->roottag->tags[0]->attributes["VLRTOTAL"];
	$qtregist = $xmlObjeto->roottag->tags[0]->attributes["QTREGIST"];
	
	echo '<form id="formTabEsttar" name="formTabEsttar" class="formulario" onSubmit="return false;" >';	
	echo '	<div class="divRegistros">';
	echo '		<table>';
	echo '			<thead>';
	echo '				<tr>';	
	echo '					<th><input type="checkbox" name="checkTodos" id="checkTodos" value="no" style="float:none; height:16;"/></th>';
	echo '					<th>'.utf8ToHtml('Data').'</th>';
	echo '					<th>'.utf8ToHtml('Hist.').'</th>';
	echo '					<th>'.utf8ToHtml('Sigla').'</th>';
	echo '					<th>'.utf8ToHtml('Documento').'</th>';
	echo '					<th>'.utf8ToHtml('Valor').'</th>';
	echo '					<th>'.utf8ToHtml('Motivo').'</th>';
	echo '				</tr>';
	echo '			</thead>';
	echo '			<tbody>';	
	
	$conta = 0;
	foreach( $estorno as $r ) { 	
	
		$conta++;
		echo "<tr>";
		echo	"<td id='tabflgcheck'>";
		echo '		<input class="flgcheck" type="checkbox" name="flgcheck'.$conta.'" id="flgcheck'.$conta.'" value="no" style="float:none; height:16;"/>';
		echo    "</td>";
		echo	"<td id='tabdtmvtolt'><span>".getByTagName($r->tags,'dtmvtolt')."</span>";
		echo                 getByTagName($r->tags,'dtmvtolt');
		echo 				'<input type="hidden" name="cdlantar'.$conta.'" id="cdlantar'.$conta.'" value="'.getByTagName($r->tags,'cdlantar').'" />';
		echo    "</td>";
		echo	"<td id='tabcdhistor'><span>".getByTagName($r->tags,'cdhistor')."</span>";
		echo                 getByTagName($r->tags,'cdhistor'); 
		echo    "</td>";
		echo	"<td id='tabdshistor'><span>".getByTagName($r->tags,'dshistor')."</span>";
		echo                 getByTagName($r->tags,'dshistor'); 
		echo    "</td>";
		echo	"<td id='tabnrdocmto'><span>".getByTagName($r->tags,'nrdocmto')."</span>";
		echo                 getByTagName($r->tags,'nrdocmto'); 
		echo    "</td>";
		echo	"<td id='tabvltarifa'><span>".converteFloat(getByTagName($r->tags,'vltarifa'),'MOEDA')."</span>";
		echo                 formataMoeda(getByTagName($r->tags,'vltarifa')); 
		echo 	'<input type="hidden" name="vltarifa'.$conta.'" id="vltarifa'.$conta.'" value="'.converteFloat(getByTagName($r->tags,'vltarifa'),'MOEDA').'" />';
		echo	"</td>";
		echo	"<td id='cdhisest'>";
		echo 		'<input type="hidden" name="cdmotest'.$conta.'" id="cdmotest'.$conta.'" value="'.getByTagName($r->tags,'cdmotest').'" />';
		echo 		'<input style="width:150px" class="campo motivo" type="text"   name="dsmotest'.$conta.'" id="dsmotest'.$conta.'" value="'.getByTagName($r->tags,'dsmotest').'" />';
		echo 		'<a style="padding: 3px 0 0 3px;" href="#" onClick="pesquisaMotivo('.$conta.');return false;"><img class="lupa" name="lupa'.$conta.'" id="lupa'.$conta.'" src="'.$UrlImagens.'geral/ico_lupa.gif"/></a>';
		echo    "</td>";
		echo "</tr>";
		
		?>
		<script>
		
			var qtd = 0;
			var valor = 0;
			var valor_aux = 0;
			
			$('<? echo '#flgcheck'.$conta;?>').unbind('click').bind('click',
				function(e){
					if( $(this).prop('checked') == true ){
						$('<? echo '#dsmotest'.$conta;?>','#formTabEsttar').css("visibility","visible"); //.habilitaCampo();
						$('<? echo '#lupa'.$conta;?>','#formTabEsttar').css("visibility","visible"); 
						
						qtd = parseInt( $('#qtdselec','#formRodape').val() ) ;
						qtd = qtd + 1;
						$('#qtdselec','#formRodape').val(qtd);
						
						valor_aux = $('<? echo '#vltarifa'.$conta;?>','#formTabEsttar').val();
						valor_aux  = number_format(parseFloat(valor_aux.replace(',','.')),2,',','');
						
						valor = $('#totselec','#formRodape').val();
						
						valor = number_format(parseFloat(valor.replace(',','.')),2,',','');
						
						valor =  converteMoedaFloat(valor) + converteMoedaFloat(valor_aux);
						
						valor = number_format(valor,2,',','');
						
						$('#totselec','#formRodape').val(valor);
						
					} else {
						$('<? echo '#dsmotest'.$conta;?>','#formTabEsttar').css("visibility","hidden"); //desabilitaCampo();
						$('<? echo '#dsmotest'.$conta;?>','#formTabEsttar').val('');
						$('<? echo '#lupa'.$conta;?>','#formTabEsttar').css("visibility","hidden"); 
						
						qtd = $('#qtdselec','#formRodape').val() ;
						qtd = qtd - 1;
						$('#qtdselec','#formRodape').val(qtd) ;
						
						valor_aux = $('<? echo '#vltarifa'.$conta;?>','#formTabEsttar').val();
						valor_aux  = number_format(parseFloat(valor_aux.replace(',','.')),2,',','');
						
						valor = $('#totselec','#formRodape').val();
						
						valor = number_format(parseFloat(valor.replace(',','.')),2,',','');
						
						valor =  converteMoedaFloat(valor) - converteMoedaFloat(valor_aux);
						
						valor = number_format(valor,2,',','');
						
						$('#totselec','#formRodape').val(valor);
						
					}
				}
			)
					
		
		</script>
		<?
		
	} 	
	?>
	<script>
		$('#qtdtotal','#formRodape').val(<? echo $qtregist ?>);
		
		valor_aux = ('<? echo $vlrtotal ?>');
		valor_aux = number_format(parseFloat(valor_aux.replace(',','.')),2,',','');
		$('#vlrtotal','#formRodape').val(valor_aux);
		
	</script>
		
	<?
			
	echo '			</tbody>';
	echo '		</table>';
	echo '	</div>';
	
	echo 		'<input class="campo" type="hidden" name="cdmotest" id="cdmotest" />';
	echo 		'<input class="campo" type="hidden" name="dsmotest" id="dsmotest" />';
	
	echo '</form>';
	
	
	
	echo 	"<form id='formRodape' class='formulario'>";
	echo 		"<div id='rodapeTabEsttar'>";
	echo 			"<table width='100%' style='border-top: 1px solid #777777;border-bottom: 1px solid #777777;margin-bottom: 5px;'>";
	echo 				"<tr>";
	echo 					"<td>";
	echo 						"<label for='qtdselec'>Selecionados:</label>";
	echo 						"<input type='text' id='qtdselec' name='qtdselec' value='0' />";
	echo 						"<label for='totselec'>TOTAL:</label>";
	echo 						"<input class='monetario' type='text' id='totselec' name='totselec' value='0,00' />";
	echo 						"<label for='qtdtotal'>Quantidade de registros:</label>";
	echo 						"<input type='text' id='qtdtotal' name='qtdtotal' value='0'/>";
	echo 						"<label for='vlrtotal'>TOTAL:</label>";
	echo 						"<input type='text' id='vlrtotal' name='vlrtotal' value='0' />";
	echo						"<br style='clear:both' />";
	echo					"</td>";
	echo 				"</tr>";
	echo 			"</table>";
	echo 		"</div>";
	echo 	"</form>";
	
?>