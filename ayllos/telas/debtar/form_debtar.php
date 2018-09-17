<?php
/*!
 * FONTE        : form_debtar.php
 * CRIAÇÃO      : Tiago
 * DATA CRIAÇÃO : 19/03/2015 
 * OBJETIVO     : Form da tela debtar
 * --------------
 * ALTERAÇÕES   : 01/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
 * --------------
 */
 
	set_time_limit(999999999);
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();		
?>

<style>
.ui-datepicker-trigger{
	float:left;
	margin-left:6px;
	margin-top:6px;
}
</style> 

<form id="frmDebtar" name="frmDebtar" style="display:none" class="formulario">
	
	<table width="100%">
		<tr>		
			<td>					
				<label for="cddgrupo">Grupo:</label>
				<input type="text" id="cddgrupo" name="cddgrupo" value="<? echo $cddgrupo ?>" />
				<a href="#" onclick="controlaPesquisas(7); return false;"  style="padding: 3px 0 0 3px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
				<input type="text" id="dsdgrupo" name="dsdgrupo" value="<? echo $dsdgrupo ?>" />
			</td>
		</tr>
		<tr>		
			<td>					
				<label for="cdsubgru">SubGrupo:</label>
				<input type="text" id="cdsubgru" name="cdsubgru" value="<? echo $cdsubgru ?>" />
				<a href="#" onclick="controlaPesquisas(8); return false;"  style="padding: 3px 0 0 3px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
				<input type="text" id="dssubgru" name="dssubgru" value="<? echo $dssubgru ?>" />
			</td>
		</tr>				
	</table>
	
	<div id="divHistorico" name="divHistorico" style="display:none">
		<table width="100%">
			<tr>		
				<td>					
					<label for="cdhistor">Hist&oacute;rico:</label>
					<input type="text" id="cdhistor" name="cdhistor" value="<? echo $cdhistor ?>" />
					<a href="#" onclick="controlaPesquisas(1); return false;"  style="padding: 3px 0 0 3px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
					<input type="text" id="dshistor" name="dshistor" value="<? echo $dshistor ?>" />
				</td>
			</tr>			
		</table>
	</div>
				
	<div id="divEstorno" name="divEstorno" style="display:none">
		<table width="100%">
			<tr>		
				<td>
					<label for="cdhisest">Hist&oacute;rico :</label>
					<input type="text" id="cdhisest" name="cdhisest" value="<? echo $cdhisest ?>" />
					<a href="#" onclick="controlaPesquisas(2); return false;"  style="padding: 3px 0 0 3px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
					<input type="text" id="dshisest" name="dshisest" value="<? echo $dshisest ?>" />
				</td>
			</tr>
			<tr>		
				<td>		
					<label for="cdmotest">Motivo:</label>
					<input type="text" id="cdmotest" name="cdmotest" value="<? echo $cdmotest ?>" />
					<a href="#" onclick="controlaPesquisas(3); return false;"  style="padding: 3px 0 0 3px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
					<input type="text" id="dsmotest" name="dsmotest" value="<? echo $dsmotest ?>" />
				</td>
			</tr>
		</table>
	</div>
				
	<table width="100%">
				
			
			<tr>		
				<td>
					<div id="divCdcooper" name="divCdcooper">
						<label name="label_cdcooper" for="cdcopaux">Cooperativa:</label>
						<input type="text" id="cdcopaux" name="cdcopaux" value="<? echo $cdcooper ?>" />
						<a name="lupa_cdcooper" href="#" onclick="controlaPesquisas(4); return false;"  style="padding: 3px 0 0 3px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
						<input type="text" id="nmrescop" name="nmrescop" value="<? echo $nmrescop ?>" />
					</div>
				</td>
			</tr>
			
			<tr>		
				<td>
					<label for="cdagenci">PA:</label>
					<input type="text" id="cdagenci" name="cdagenci" value="<? echo $cdagenci ?>" />
					<a href="#" onclick="controlaPesquisas(5); return false;"  style="padding: 3px 0 0 3px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
					<input type="text" id="nmresage" name="nmresage" value="<? echo $nmresage ?>" />
				</td>
			</tr>
			<tr>		
				<td> 
					<label for="inpessoa">Tipo:</label>
					<select id="inpessoa" name="inpessoa" style="width: 200px;">
						<option value="0"></option> 
						<option value="1">Pessoa F&iacute;sica</option> 
						<option value="2">Pessoa Jur&iacute;dica</option>
					</select>
				</td>
			</tr>
			<tr>		
				<td>
					<label for="nrdconta">Conta:</label>
					<input type="text" id="nrdconta" name="nrdconta" value="<? echo $nrdconta ?>" />
					<a href="#" onclick="controlaPesquisas(6); return false;"  style="padding: 3px 0 0 3px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
					<input id="nmprimtl" name="nmprimtl" type="text" value="<? echo $nmprimtl ?>"/>
				</td>
			</tr>			
			<tr>		
				<td>
					<br style="clear:both" />
					<label  style="width:100px;">Per&iacute;odo</label>
				</td>
			</tr>
	</table>	
	<table width="100%" style="border-top: 1px solid #777777;">
		<tr>		
			<td> 
				<label for="dtinicio">De:</label>
				<input type="text" id="dtinicio" name="dtinicio" value="<? echo $dtinicio ?>" />
				<br style="clear:both" />
				<label for="dtafinal"> At&eacute;: </label>
				<input type="text" id="dtafinal" name="dtafinal" value="<? echo $dtafinal ?>" />
			</td>
		</tr>
	</table>
		<input type="hidden" id="tprelato1" name="tprelato1" />	
		<input type="hidden" id="cdhistor1" name="cdhistor1" />	
		<input type="hidden" id="cddgrupo1" name="cddgrupo1" />	
		<input type="hidden" id="cdsubgru1" name="cdsubgru1" />	
		<input type="hidden" id="cdhisest1" name="cdhisest1" />	
		<input type="hidden" id="cdmotest1" name="cdmotest1" />	
		<input type="hidden" id="cdcooper1" name="cdcooper1" />	
		<input type="hidden" id="cdagenci1" name="cdagenci1" />	
		<input type="hidden" id="inpessoa1" name="inpessoa1" />	
		<input type="hidden" id="nrdconta1" name="nrdconta1" />	
		<input type="hidden" id="nmarqpdf1" name="nmarqpdf1" />	
		
</form>

<script>

  $.datepicker.setDefaults( $.datepicker.regional[ "pt-BR" ] );	
  
  $(function() {
	  $( "#dtinicio" ).datepicker({
	  showOn: "button",
	  maxDate: "<?php echo $glbvars["dtmvtolt"]; ?>",
	  defaultDate: "<?php echo $glbvars["dtmvtolt"]; ?>",	
	  buttonImage: "../../imagens/geral/btn_calendario.gif",
	  buttonImageOnly: true    }); 
  });
  
  $(function() {
	  $( "#dtafinal" ).datepicker({
	  showOn: "button",
	  maxDate: "<?php echo $glbvars["dtmvtolt"]; ?>",
	  defaultDate: "<?php echo $glbvars["dtmvtolt"]; ?>",	
	  buttonImage: "../../imagens/geral/btn_calendario.gif",
	  buttonImageOnly: true    }); 
  });

  glbDtmvtolt = "<?php echo $glbvars["dtmvtolt"]; ?>";

</script>
