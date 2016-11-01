<? 
/*!
 * FONTE        : formulario_informativos.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 19/04/2010 
 * OBJETIVO     : Forumlário para INFORMATIVOS
 */	
?>	

<div id="divInformativos">
	<form name="frmDadosInformativos" id="frmDadosInformativos" class="formulario">		
		<input type="hidden" id="cdrelato" name="cdrelato" value="<? echo getByTagName($registro,'cdrelato') ?>" />					
		<input type="hidden" id="cdprogra" name="cdprogra" value="<? echo getByTagName($registro,'cdprogra') ?>" />					
		<input type="hidden" id="cddfrenv" name="cddfrenv" value="<? echo getByTagName($registro,'cddfrenv') ?>" />
				
		<label for="nmrelato">Informativo:</label>
		<input name="nmrelato" id="nmrelato" type="text" value="<? echo getByTagName($registro,'nmrelato') ?>" />
		<br />	
		
		<label for="dsdfrenv">Forma Envio:</label>
		<input name="dsdfrenv" id="dsdfrenv" type="text" value="<? echo getByTagName($registro,'dsdfrenv') ?>" />
		<br />
		
		<label for="cdperiod">Per&iacute;odo:</label>
		<select name="cdperiod" id="cdperiod">
			<option value="" selected> - </option>
		</select>
		<br />
		
		<label for="cdseqinc">Recebimento:</label>
		<select name="cdseqinc" id="cdseqinc">
			<option value="" selected> - </option>
		</select>		
		
		<br style="clear:both" />
	</form>	
	<div id="divBotoes">
		<? if ( $operacao == 'CA' ) { ?>
			<input type="image" id="btVoltar" src="<? echo $UrlImagens; ?>botoes/cancelar.gif" onClick="controlaOperacao('AC');" />
			<input type="image" id="btSalvar" src="<? echo $UrlImagens; ?>botoes/concluir.gif" onClick="controlaOperacao('AV');" />	
		<? } else if ( $operacao == 'CI' ) { ?>
			<input type="image" id="btVoltar" src="<? echo $UrlImagens; ?>botoes/cancelar.gif" onClick="controlaOperacao('IC');" />
			<input type="image" id="btSalvar" src="<? echo $UrlImagens; ?>botoes/concluir.gif" onClick="controlaOperacao('IV');" />	
		<? } ?>
	</div>			
</div>