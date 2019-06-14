<? 
 /*!
 * FONTE        : form_titulos.php
 * CRIAÇÃO      : Adriano 
 * DATA CRIAÇÃO : Agosto/2011                             Última Alteração: 12/05/2016
 * OBJETIVO     : Formulário de exibição
 * --------------
 * ALTERAÇÕES   : 17/06/2015 - Ajuste decorrente a melhoria no layout da tela (Adriano).
 * 
 *                12/05/2016 - Adicionado o campo de linha digitavel (Douglas - Chamad 426870)
 *
 *                08/01/2019 - Alterações P510, campo Tipo Pgto (Christian Grauppe - Envolti).
 * --------------
 */	
?>


<form name="frmTitulos" id="frmTitulos" class="formulario" style="display:none" >	
	<fieldset>
		<legend><? echo utf8ToHtml('Detalhes do Titulo') ?></legend>

		<label for="dspactaa"><? echo utf8ToHtml('COOPERATIVA/PA/TAA:') ?></label>
		<input name="dspactaa" id="dspactaa" type="text" />
		
		<br/>
		
		<label for="nrautdoc"><? echo utf8ToHtml('Autenticação:') ?></label>
		<input name="nrautdoc" id="nrautdoc" type="text" />

		<label for="nrdocmto"><? echo utf8ToHtml('Docto.:') ?></label>
		<input name="nrdocmto" id="nrdocmto" type="text" />
			
		<label for="flgpgdda"><? echo utf8ToHtml('Pago DDA:') ?></label>
		<input name="flgpgdda" id="flgpgdda" type="text" />
			
		<br/>
		
		<label for="cdbandst"><? echo utf8ToHtml('Banco Destin.:') ?></label>
		<input name="cdbandst" id="cdbandst" type="text" />
		
		<label for="nrdconta"><? echo utf8ToHtml('Conta/dv:') ?></label>
		<input name="nrdconta" id="nrdconta" type="text" />
	
		<br/>
		
		<label for="dscodbar"><? echo utf8ToHtml('Cod. de Barras:') ?></label>
		<input name="dscodbar" id="dscodbar" type="text" />	
	
		<br/>
		
		<label for="dslindig"><? echo utf8ToHtml('Linha Digitavel:') ?></label>
		<input name="dslindig" id="dslindig" type="text" />	

		<br/>
		
		<label for="dscptdoc"><? echo utf8ToHtml('Origem pagto:') ?></label>
		<input name="dscptdoc" id="dscptdoc" type="text" />	
		
		<br/>
		
		<label for="tppagmto"><? echo utf8ToHtml('Tipo pagto:') ?></label>    
    <select name="tppagmto" id="tppagmto">
      <option value="0">Conta</option>
      <option value="1">Especie</option>
    </select>
		
	</fieldset>	
	
</form>

