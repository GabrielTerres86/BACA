	<? 
	/*!
	 * FONTE        : form_agencia.php
	 * CRIAÇÃO      : David Kruger
	 * DATA CRIAÇÃO : 04/02/2013
	 * OBJETIVO     : Formulario de Agencias.
	 * --------------
	 * ALTERAÇÕES   : 08/01/2014 - Ajustes para homolagação (Adriano)
	 *
	 *                11/10/2017 - Inclusao dos campos Modelo e % Mínimo Garantia. (Lombardi - PRJ404)
	 * --------------
	 */	


	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();

	require_once("../../includes/carrega_permissoes.php");
	?>

	<form id="frmLdesco" name="frmLdesco" class="formulario" style="display:none;">

		<fieldset id="frmConteudo" style="padding:0px; margin:0px; padding-bottom:10px;">

			<legend><? echo utf8ToHtml("Linha de Crédito"); ?></legend>

			<label class="rotulo txtNormalBold" for="descricao"><? echo utf8ToHtml("Descrição:"); ?></label>
			<input class="campoTelaSemBorda" type="text" id="descricao" name="descricao" >

			<br />

			<label class="rotulo txtNormalBold" for="taxamora"><? echo utf8ToHtml("Taxa Mora (%):"); ?></label>
			<input class="campoTelaSemBorda" type="text" id="taxamora" name="taxamora" >


			<label class="rotulo-linha txtNormalBold" for="qtvias"><? echo utf8ToHtml("Qt. Vias:"); ?></label>
			<input class="campoTelaSemBorda" type="text" id="qtvias" name="qtvias" >

			<br />

			<label class="rotulo txtNormalBold" for="taxamensal"><? echo utf8ToHtml("Taxa Mensal (%):"); ?></label>
			<input class="campoTelaSemBorda" type="text" id="taxamensal" name="taxamensal" > 


			<label class="rotulo-linha txtNormalBold" for="tarifa"><? echo utf8ToHtml("Tarifa:"); ?></label>
			<!-- <input class="campoTelaSemBorda" type="text" id="tarifa" name="tarifa" > -->

			<select class="campoTelaSemBorda" id="tarifa" name="tarifa">
				<option value="0"><? echo utf8ToHtml("Isentar"); ?></option>
				<option value="1"><? echo utf8ToHtml("Cobrar"); ?></option>
			</select>

			<br />

			<label class="rotulo txtNormalBold" for="tpctrato"><? echo utf8ToHtml("Modelo:"); ?></label>
			<select class="campoTelaSemBorda" id="tpctrato" name="tpctrato">
				<option value="0"><? echo utf8ToHtml("Geral"); ?></option>
				<option value="4"><? echo utf8ToHtml("Aplicação"); ?></option>
			</select>
						
			<label class="rotulo-linha txtNormalBold" for="permingr"><? echo utf8ToHtml("% M&iacute;nimo Garantia:"); ?></label>
			<input class="campoTelaSemBorda" type="text" id="permingr" name="permingr" > 

			<br />

			<label class="rotulo txtNormalBold" for="taxadiaria"><? echo utf8ToHtml("Taxa Diária (%):"); ?></label>
			<input class="campoTelaSemBorda" type="text" id="taxadiaria" name="taxadiaria" >

			<label class="rotulo-linha txtNormalBold" for="situacao"><? echo utf8ToHtml("Situação:"); ?></label>
			<input class="campoTelaSemBorda" type="text" id="situacao" name="situacao" >

			<br style="clear:both" />

		</fieldset>

	</form>

	<div id="divBotoesFiltroLdesco" style='text-align:center; margin-bottom: 10px; margin-top: 10px; display:none;' >
		<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(2); return false;">Voltar</a>																
		<a href="#" class="botao" id="btProsseguir" name="btProsseguir" onClick="btnProsseguir();return false;" style="float:none;">Prosseguir</a>																				
	</div>