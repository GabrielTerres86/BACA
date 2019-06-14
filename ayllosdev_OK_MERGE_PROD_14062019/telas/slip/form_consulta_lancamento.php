<?php
	/*!
    * FONTE        : form_contula_lancamento.php
	* CRIAÇÃO      : Alcemir Junior - Mout's
	* DATA CRIAÇÃO : 10/10/2018
	* OBJETIVO     : form para a consulta de lançamentos da tela SLIP
	* --------------
	* ALTERAÇÕES   :
	* --------------
	*/
?>



<div id="divConLancamento" name="divConLancamento">
	<form id="frmConLancamento" name="frmConLancamento" class="formulario" onSubmit="return false;" style="display:block">
	
		<div id="divFiltrosConLanc" name="divFiltrosConLanc">
			<fieldset id="fsConLancamento" style="display:block">
			<legend style="text-align: center" ><? echo utf8ToHtml("Filtros da Consulta") ?></legend>
		
				<label for="dtmvtolt"><? echo utf8ToHtml("Data Lanc.:") ?></label>
				<input name="dtmvtolt" type="text"  id="dtmvtolt" class="data campo" style="width: 55px;">

				<label for="cdhistor_padrao"><? echo utf8ToHtml("Hist. Padrão:") ?></label>
				<input name="cdhistor_padrao" type="text"  id="cdhistor_padrao" class="inteiro campo" style="width: 50px;">
			
				<label for="cdoperad"><? echo utf8ToHtml("Operador:") ?></label>
				<input name="cdoperad" type="text"  id="cdoperad" class="campo" style="width: 100px;">

				<br style="clear:both" />
				
				<label for="vllanmto"><? echo utf8ToHtml("Vlr. Lanc.:") ?></label>
				<input name="vllanmto" type="text"  id="vllanmto" class="campo" style="width: 100px;">

				<select class="campo" id="opevlrlan" name="opevlrlan" style = "margin-left: 2px ">	
						<option value="I"><? echo utf8ToHtml("=")  ?>    </option>	
						<option value="MA"><? echo utf8ToHtml(">") ?>    </option>									
						<option value="ME"><? echo utf8ToHtml("<") ?>    </option>														
				</select>											
		
				<label for="cdhistor"><? echo utf8ToHtml("Hist. Aimaro:") ?></label>
				<input name="cdhistor" type="text"  id="cdhistor" class="inteiro campo" style="width: 55px;">

				<label for="nrctadeb"><? echo utf8ToHtml("Conta Débito:") ?></label>
				<input name="nrctadeb" type="text"  id="nrctadeb" class="inteiro campo" style="width: 50px;">

				<label for="nrctacrd"><? echo utf8ToHtml("Conta Crédito:") ?></label>
				<input name="nrctacrd" type="text"  id="nrctacrd" class="inteiro campo" style="width: 50px;">

				<br style="clear:both" />

				<label for="dslancamento"><? echo utf8ToHtml("Descrição:") ?></label>
				<input name="dslancamento" type="text"  id="dslancamento" class="campo" style="width: 380px;">

				<a href="#" class="botao" id="btConLanc"  style = "margin-left: 46px "name="btConLanc">Consultar</a>	
							          			 					
			</fieldset>
		</div>

		<div id="divResultadoConLanc" style="display:block;">
							
		</div>

	    	
	</form>		
</div>	