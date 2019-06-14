<? 
/*!
 * FONTE        : tab_beneficios.php
 * CRIAÇÃO      : Rogérius Militão - (DB1)
 * DATA CRIAÇÃO : 01/06/2011 
 * OBJETIVO     : Tabela que apresenta os beneficios
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */	
?>

<fieldset>
<legend><? echo utf8ToHtml('Dados do Benefício');?></legend>
<div class="divRegistros">	
	<table>
		<thead>
			<tr>
				<th><? echo utf8ToHtml('NB');   					?></th>
				<th><? echo utf8ToHtml('Início');   				?></th>
				<th><? echo utf8ToHtml('Final');   					?></th>
				<th><? echo utf8ToHtml('Crédito');   				?></th>
				<th><? echo utf8ToHtml('Meio Pgto');   		?></th>
				<th><? echo utf8ToHtml('Conta/dv');   				?></th>
				<th><? echo utf8ToHtml('Data <br /> Pgto'); 		?></th>
	
		</tr>
		</thead>
		<tbody>
			<? foreach( $registros as $registro ) { ?>
				<tr>


					<td><span><? echo dataParaTimestamp(getByTagName($registro->tags,'nrbenefi')) ?></span>
							  <? echo getByTagName($registro->tags,'nrbenefi') ?>
							  <input type="hidden" id="flgcredi" name="flgcredi" value="<? echo getByTagName($registro->tags,'flgcredi') ?>" />								  
							  <input type="hidden" id="dtflgcre" name="dtflgcre" value="<? echo getByTagName($registro->tags,'dtflgcre') ?>" />								  
							  <input type="hidden" id="cdagenci" name="cdagenci" value="<? echo getByTagName($registro->tags,'cdagenci') ?>" />								  
							  <input type="hidden" id="dsespeci" name="dsespeci" value="<? echo stringTabela(getByTagName($registro->tags,'dsespeci'),30,'maiuscula') ?>" />								  
							  <input type="hidden" id="flgcredi" name="flgcredi" value="<? echo getByTagName($registro->tags,'flgcredi')  ?>" />								  

							  <input type="hidden" id="flgexist" name="flgexist" value="<? echo getByTagName($registro->tags,'flgexist') ?>" />								  
							  <input type="hidden" id="nmprocur" name="nmprocur" value="<? echo getByTagName($registro->tags,'nmprocur') ?>" />								  
							  <input type="hidden" id="dsdocpcd" name="dsdocpcd" value="<? echo getByTagName($registro->tags,'dsdocpcd') ?>" />								  
							  <input type="hidden" id="cdoedpcd" name="cdoedpcd" value="<? echo getByTagName($registro->tags,'cdoedpcd') ?>" />								  
							  <input type="hidden" id="cdufdpcd" name="cdufdpcd" value="<? echo getByTagName($registro->tags,'cdufdpcd') ?>" />								  
							  <input type="hidden" id="dtvalprc" name="dtvalprc" value="<? echo getByTagName($registro->tags,'dtvalprc') ?>" />								  
							  
					</td>

					<td><span><? echo dataParaTimestamp(getByTagName($registro->tags,'dtinipag')) ?></span>
							  <? echo getByTagName($registro->tags,'dtinipag') ?>
							  
					</td>
					
					<td><span><? echo dataParaTimestamp(getByTagName($registro->tags,'dtfimpag')) ?></span>
							  <? echo getByTagName($registro->tags,'dtfimpag') ?>
					</td>

					<td><span><? echo getByTagName($registro->tags,'vlliqcre') ?></span>
							  <? echo number_format(str_replace(',','.',getByTagName($registro->tags,'vlliqcre')),2,',','.') ?>
					</td>

					<td><span><? echo getByTagName($registro->tags,'tpmepgto') ?></span>
							  <? echo getByTagName($registro->tags,'tpmepgto') ?>
					</td>

					<td><span><? echo getByTagName($registro->tags,'nrdconta') ?></span>
							  <? echo formataContaDV(getByTagName($registro->tags,'nrdconta')) ?>
					</td>

					<td><span><? echo dataParaTimestamp(getByTagName($registro->tags,'dtdpagto')) ?></span>
							  <? echo getByTagName($registro->tags,'dtdpagto') ?>
					</td>

				</tr>
		<? } ?>	
		</tbody>
	</table>
</div>	

<div id="divBeneficiosMais">
<table width="100%">
<tr>
<td width="9%"><b style="font-size:11px;font-family:Arial,Helvetica,san"><? echo utf8ToHtml('Situação:'); ?></b></td>
<td width="14%"><span id="flgcredi"  style="font-size:11px;font-family:Arial,Helvetica,san"></span></td>

<td width="8%"><b style="font-size:11px;font-family:Arial,Helvetica,san"><? echo utf8ToHtml('Data Sit:'); ?></b></td>
<td width="12%"><span id="dtflgcre"  style="font-size:11px;font-family:Arial,Helvetica,san"></span></td>

<td width="5%"><b style="font-size:11px;font-family:Arial,Helvetica,san"><? echo utf8ToHtml('PAC:'); ?></b></td>
<td width="5%"><span id="cdagenci"  style="font-size:11px;font-family:Arial,Helvetica,san"></span></td>

<td width="12%"><b style="font-size:11px;font-family:Arial,Helvetica,san"><? echo utf8ToHtml('Desc Benef:'); ?></b></td>
<td width="35%"><span id="dsespeci"  style="font-size:11px;font-family:Arial,Helvetica,san"></span></td>
</tr>
</table>
</div>

</fieldset>


<? include ('form_procurador.php') ?>
	

<script type="text/javascript">

	$('#dtdinici','#'+frmPeriodo).desabilitaCampo();
	$('#dtdfinal','#'+frmPeriodo).desabilitaCampo();
	
</script>
