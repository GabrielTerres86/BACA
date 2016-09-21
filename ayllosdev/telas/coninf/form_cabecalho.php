<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 29/11/2011
 * OBJETIVO     : Cabeçalho para a tela Coninf
 * --------------
 * ALTERAÇÕES   : 14/08/2013 - Alteração da sigla PAC para PA (Carlos).
 * --------------
 */

?>

<form id="frmCab" name="frmCab" class="formulario cabecalho">
				
	<label for="cdcoopea"><? echo utf8ToHtml('Cooperativa:') ?></label>
	<select id="cdcoopea" name="cdcoopea">	
		<?
		foreach ( $cooperativas as $c ) {
			?><option value="<? echo getByTagName($c->tags,'cdcooper')?>" ><?echo getByTagName($c->tags,'nmrescop')?></option><?			
		}	
		?>		
	</select>
	
	<a href="#" class="botao" id="btnOK" >OK</a>
	
	<label for="dtmvtol1"><? echo utf8ToHtml('Período:') ?></label>
	<input id="dtmvtol1" name="dtmvtol1" type="text"/>
	
	<label for="dtmvtol2"><? echo utf8ToHtml(' à ') ?></label>
	<input id="dtmvtol2" name="dtmvtol2" type="text"/>
	
	<br style="clear:both" />	

	<label for="cdagenca"><? echo utf8ToHtml('PA:') ?></label>
	<input id="cdagenca" name="cdagenca" type="text"/>
	
	<label for="tpdocmto"><? echo utf8ToHtml('Tipo Carta:') ?></label>
	<select id="tpdocmto" name="tpdocmto">	
		<?
		foreach ( $documentos as $d ) {
			?><option value="<? getByTagName($d->tags,'tpdocmto') ?>" ><?echo getByTagName($d->tags,'nmtpdcto')?></option><?			
		}	
		?>		
	</select>
	
	<br style="clear:both" />	
	
	<label for="indespac"><? echo utf8ToHtml('Destino:') ?></label>
	<select id="indespac" name="indespac">	
		<option value="0" selected > 0 - Todos </option>		
		<option value="1" > 1 - Correio </option>		
		<option value="2" > 2 - Balcao </option>		
	</select>
	
	<label for="cdfornec"><? echo utf8ToHtml('Fornecedor:') ?></label>
	<select id="cdfornec" name="cdfornec">	
		<option value="0" selected > 0 - Todos </option>		
		<option value="1" > 1 - Postmix </option>		
		<option value="2" > 2 - Engecopy </option>		
	</select>
	
	<label for="tpdsaida"><? echo utf8ToHtml('Saida:') ?></label>
	<select id="tpdsaida" name="tpdsaida">	
		<option value="T" selected > Tela </option>		
		<option value="A" > Arquivo </option>				
	</select>
	
	<br style="clear:both" />
	
</form>

