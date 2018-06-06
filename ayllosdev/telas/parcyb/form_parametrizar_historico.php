<?php
	/*!
	 * FONTE        : form_parametrizar_historico.php
	 * CRIAÇÃO      : Douglas Quisinski
	 * DATA CRIAÇÃO : 26/08/2015
	 * OBJETIVO     : Cabecalho para a tela de Parametrização de Históricos
	 * --------------
	 * ALTERAÇÕES   : 13/01/2016 - Inclusão da coluna Código de Transação CYBER - PRJ 432 - Jean Calão
	 * --------------
	 */
?>
<div id="divTelaParametrizarHistorico">
	<form id="frmCabParametrizarHistorico" name="frmCabParametrizarHistorico" class="formulario" style="display:none">
		<table width="100%">
			<tr>
				<td>
					<label for="cddopcao_parametrizar_historico"><? echo utf8ToHtml("Op&ccedil;&atilde;o") ?></label>
					<select class="campo" id="cddopcao_parametrizar_historico" name="cddopcao_parametrizar_historico">
						<option value="CH">C - Consultar</option> 
						<option value="AH">A - Alterar</option> 
					</select>
					<a href="#" class="botao" id="btnOkParametrizarHistorico" name="btnOkParametrizarHistorico" style="text-align:right;">OK</a>
				</td>
			</tr>
		</table>
	</form>
	
	<div id="divFiltrosParametrizarHistorico" name="divFiltrosParametrizarHistorico">
		<form id="frmFiltrosParametrizarHistorico" name="frmFiltrosParametrizarHistorico" class="formulario" style="display:none">
			<table width="100%">
				<tr>
					<td id="tdPesquisarHistorico">
						<label for="cdhistor"><? echo utf8ToHtml("C&oacute;digo") ?></label>
						<input name="cdhistor" type="text"  id="cdhistor" class="campo" />
						<label for="dshistor"><? echo utf8ToHtml("Descri&ccedil;&atilde;o") ?></label>
						<input name="dshistor" type="text"  id="dshistor" class="campo" />
						<a href="#" class="botao" id="btnPesquisarHistorico" name="btnPesquisarHistorico" style="text-align:right;">Pesquisar</a>
					</td>
				</tr>
				<tr>
					<td id="tdFiltrarHistorico">
						<input type="radio" id="rdfiltro1" class="campo" name="rdfiltro" value="1"/> <label for="rdfiltro1"><? echo utf8ToHtml("C&aacute;lculo Empr&eacute;stimo/Descontos");?></label>
						<input type="radio" id="rdfiltro2" class="campo" name="rdfiltro" value="2"/> <label for="rdfiltro2"><? echo utf8ToHtml("C&aacute;lculo Conta Corrente");?></label>
						<input type="radio" id="rdfiltro3" class="campo" name="rdfiltro" value="3"/> <label for="rdfiltro3"><? echo utf8ToHtml("Ambos");?></label>					
						<a href="#" class="botao" id="btnFiltrarHistorico" name="btnFiltrarHistorico" style="text-align:right;">Pesquisar</a>
					</td>
				</tr>
			</table>
		</form>
	</div>
	
	<div id="divConsultaParametrizarHistorico" name="divConsultaParametrizarHistorico">
		<div id="tabParhis">
			<div class="divRegistros">
				<table class="tituloRegistros" id="tbParhis">
					<thead>
						<tr>
							<th><? echo utf8ToHtml("C&oacute;digo");?></th>
							<th><? echo utf8ToHtml("Descri&ccedil;&atilde;o");?></th>
							<th><? echo utf8ToHtml("Indicador");?></th>
							<th><? echo utf8ToHtml("C&aacute;lculo Empr&eacute;stimo/Descontos");?></th>
							<th><? echo utf8ToHtml("C&aacute;lculo Conta Corrente");?></th>
                            <th><? echo utf8ToHtml("C&oacute;digo Trans.CYBER");?></th>
						</tr>
					</thead>
					<tbody>
					</tbody>
				</table>
			</div> 
		</div>
	</div>
</div>
