<? 
/*!
 * FONTE        : form_consulta_oficio.php
 * CRIAÇÃO      : Andrey Formigari (Mouts).
 * DATA CRIAÇÃO : Setembro/2017 
 * OBJETIVO     : Listagem de Oficios
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */	
 ?>
<style type="text/css">
	div.divRegistrosOficios {height:150px;width:100%;overflow-x:hidden;overflow-y:scroll;}
	div.divRegistrosOficios table {width:100%;border-collapse:collapse;}
	div.divRegistrosOficios table thead {display:none;}
	div.divRegistrosOficios table tbody tr {height:16px;}
	div.divRegistrosOficios table tbody tr td {padding:0px 5px;border-right:1px dotted #999;font-size:12px;color:#333;}
	div.divRegistrosOficios table tbody tr td span {display:none;}
</style>
<form id="frmConsultaDadosOficio" class="formulario" name="frmConsultaDadosOficio">
	<fieldset>
		<legend>Oficios</legend>
		<div class="divRegistrosOficios">
			<table>
				<thead>
					<tr>
						<th>Conta/dv</th>
						<th>Ofício</th>
						<th>Total Bloqueado</th>
					</tr>			
				</thead>
				<tbody> 
					<? 
						$seq = 0;
						foreach( $oficios as $oficio) { 
						$mtdClick = "selecionaOficio('".preg_replace("/[^0-9]/", "", getByTagName($oficio->tags,'NROFICIO'))."');";
					?>
						<tr onclick= "<? echo $mtdClick; ?>" onFocus="<? echo $mtdClick; ?>"> 
							<td id="nrdconta" ><span style="display: none;"><?php echo formataContaDV(getByTagName($oficio->tags,'NRDCONTA')); ?></span>
									<?php echo formataContaDV(getByTagName($oficio->tags,'NRDCONTA')); ?>
							</td>
							<td id="nroficio"  ><span style="display: none;"><?php echo getByTagName($oficio->tags,'NROFICIO'); ?></span>
									<?php echo getByTagName($oficio->tags,'NROFICIO'); ?>
							</td>
							<td style="" id="vlbloque" ><span style="display: none;"><?php echo number_format(str_replace(",",".",getByTagName($oficio->tags,'VLBLOQUE')),2,",","."); ?></span>
									<?php echo number_format(str_replace(",",".",getByTagName($oficio->tags,'VLBLOQUE')),2,",","."); ?>
							</td>
						</tr>												
					<?  $seq = $seq + 1;
						}
					?>			
				</tbody>		
			</table>
		</div>
	</fieldset>
</form>
