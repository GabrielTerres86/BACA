<?php
	/*!
	 * FONTE        : form_cadastro_parametro.php
	 * CRIAÇÃO      : Alcemir Junior - Mout's
	 * DATA CRIAÇÃO : 21/09/2018
	 * OBJETIVO     : Cadastro de parametros para a tela PARCBA
	 * --------------
	 * ALTERAÇÕES   : 
	 * --------------
	 */
?>
<div id="divCadastroParametro" name="divCadastroParametro">
	<form id="frmCadParametro" name="frmCadParametro" class="formulario" onSubmit="return false;" style="display:block">
		<fieldset id="fscadtra" style="display: none">
		<legend>Transação Bancoob</legend>
					<label for="cdtransa"><? echo utf8ToHtml("C&oacute;digo:") ?></label>
					<input name="cdtransa" type="text"  id="cdtransa" class="inteiro campo" style="width: 50px;">
					<label for="dstransa"><? echo utf8ToHtml("Descri&ccedil;&atilde;o:") ?></label>
					<input name="dstransa" type="text"  id="dstransa" class="campo" style="width: 300px;">		

					<label for="indebcre"><? echo utf8ToHtml("C/D:") ?></label>
					<select class="campo" id="indebcre" name="indebcre">
						<option value="C"><? echo utf8ToHtml("C") ?></option>
						<option value="D"><? echo utf8ToHtml("D") ?></option>
					</select>
			        
			        <a href="#" class="botao" id="btnOK" name="btnOK" style = "text-align:right;" onclick="incluirTransacaoBancoob(); return false;"><? 
			                   echo utf8ToHtml("OK");?></a>
                    
                    <a href="#" class="botao" id="btnIncluirTransacao" name="btnIncluirTransacao" style = "text-align:right;" onclick="incluirTransacaoBancoob(); return false;"><? 
			                   echo utf8ToHtml("Incluir");?></a>


			        <a href="#" class="botao" id="btnAlterarTransacao" name="btnAlterarTransacao" style = "text-align:right;" onclick="alterarTransacaoBancoob(); return false;"><? 
			                   echo utf8ToHtml("Alterar");?></a>       
        </fieldset>

        <fieldset id="fscadhis" style="display: none">
		<legend>Histórico Ailos</legend>		

		<label for="cdhistor"><? echo utf8ToHtml("C&oacute;digo:") ?></label>
		<input name="cdhistor" type="text"  id="cdhistor" class="inteiro campo" style="width: 50px;">

		<label for="dshistor"><? echo utf8ToHtml("Descri&ccedil;&atilde;o:") ?></label>
		<input name="dshistor" type="text"  id="dshistor" class="campoTelaSemBorda" style="width: 300px;" readonly disabled>
		

		<label for="indebcre1"><? echo utf8ToHtml("C/D:") ?></label>		
		<select class="campo" id="indebcre1" name="indebcre1">
			<option value="C"><? echo utf8ToHtml("C") ?></option>
			<option value="D"><? echo utf8ToHtml("D") ?></option>
		</select>

        <a href="#" class="botao" id="btnIncluirHistorico" name="btnIncluirHistorico" style = "text-align:right;" onclick="incluirHistoricoAilos(); return false;"><? 
                   echo utf8ToHtml("Incluir");?></a>


		<br style="clear:both" />

		<div id="tabCadpar">
			<div class="divRegistros">			
				<table class="tituloRegistros" id="tbCadpar">
					<thead>
						<tr>
							<th><? echo utf8ToHtml("C&oacute;digo");?></th>							
							<th><? echo utf8ToHtml("Descri&ccedil;&atilde;o");?></th>
							<th><? echo utf8ToHtml("D/C");?></th>
							<th><? echo utf8ToHtml("Exclus&atilde;o");?></th>
						</tr>
					</thead>
					<tbody>
					</tbody>
				</table>		
			</div> 
		</div>		
		</fieldset>  

        
	</form>
</div>