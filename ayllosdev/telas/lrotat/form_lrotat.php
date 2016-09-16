	<? 
	/*!
	 * FONTE        : form_agencia.php
	 * CRIAÇÃO      : David Kruger
	 * DATA CRIAÇÃO : 04/02/2013
	 * OBJETIVO     : Formulario de Agencias.
	 * --------------
	 * ALTERAÇÕES   : 08/01/2014 - Ajustes para homolagação (Adriano)
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

	<form id="frmLrotat" name="frmLrotat" class="formulario" style="display:none;">

		<fieldset id="frmConteudo" style="padding:0px; margin:0px; padding-bottom:10px;">

			<legend><? echo utf8ToHtml("Crédito Rotativo"); ?></legend>

			<label class="rotulo txtNormalBold" for="descricao"><? echo utf8ToHtml("Descrição:"); ?></label>
			<input class="campoTelaSemBorda" type="text" id="descricao" name="descricao" >

			<br style="clear: both;" />

			<label class="rotulo txtNormalBold" for="taxamora"><? echo utf8ToHtml("Tipo de Limite:"); ?></label>
			<select class="campoTelaSemBorda" id="tlimite" name="tlimite">
				<option value="1,000000"><? echo utf8ToHtml("Física"); ?></option>
				<option value="2,000000"><? echo utf8ToHtml("Jurídica"); ?></option>
			</select>


			<label class="rotulo-linha txtNormalBold" for="qtvias"><? echo utf8ToHtml("Situação:"); ?></label>
			<input class="campoTelaSemBorda" type="text" id="situacao" name="situacao" >

			<br />

			<span id="labelBranco">&nbsp;</span>
			<!-- Titulo Esquerda e Direita -->
			<span id="labelOperacional">Operacional</span>

			<span id="labelCecred">CECRED</span>

			<br />

			<!-- Esquerda e Direita -->
			<label class="rotulo txtNormalBold labeltab-form"><? echo utf8ToHtml("Quantidade de Vezes do Capital:"); ?></label>
			<input class="campoTelaSemBorda" type="text" id="QtxCapOp" name="QtxCapOp" > 
			<input class="campoTelaSemBorda" type="text" id="QtxCapCe" name="QtxCapCe" >

			<br />

			<!-- Esquerda e Direita -->
			<label class="rotulo txtNormalBold labeltab-form"><? echo utf8ToHtml("Valor Limite Máximo:"); ?></label>
			<input class="campoTelaSemBorda" type="text" id="DVcontOp" name="DVcontOp" > 
			<input class="campoTelaSemBorda" type="text" id="DVcontCe" name="DVcontCe" >

			<br />

			<!-- Direita -->
			<label class="rotulo txtNormalBold labeltab-form"><? echo utf8ToHtml("Dias de Vigência do Contrato:"); ?></label>
			<span class="label-operacional">&nbsp;</span>
			<input class="campoTelaSemBorda" type="text" id="qtdiavig" name="qtdiavig" > 

			<br />

			<!-- Direita -->
			<label class="rotulo txtNormalBold labeltab-form"><? echo utf8ToHtml("Taxa Fixa (%):"); ?></label>
			<span class="label-operacional">&nbsp;</span>
			<input class="campoTelaSemBorda" type="text" id="Tfixa" name="Tfixa" > 

			<br />

			<!-- Direita -->
			<label class="rotulo txtNormalBold labeltab-form"><? echo utf8ToHtml("Taxa Variável (%):"); ?></label>
			<span class="label-operacional">&nbsp;</span>
			<input class="campoTelaSemBorda" type="text" id="Tvar" name="Tvar" > 

			<br />

			<!-- Direita -->
			<label class="rotulo txtNormalBold labeltab-form"><? echo utf8ToHtml("Taxa Mensal (%):"); ?></label>
			<span class="label-operacional">&nbsp;</span>
			<input class="campoTelaSemBorda" type="text" id="Tmensal" name="Tmensal" > 

			<br />

			<!-- Texto no contrato -->
			
			<label class="rotulo txtNormalBold labeltab-form"><? echo utf8ToHtml("Texto no contrato:"); ?></label>
			<input class="campoTelaSemBorda" type="text" id="dsencfin1" name="dsencfin1" >

			<br />

			<span class="labeltab-form">&nbsp;</span> 
			<input class="campoTelaSemBorda" type="text" id="dsencfin2" name="dsencfin2" > 

			<br />

			<span class="labeltab-form">&nbsp;</span>
			<input class="campoTelaSemBorda" type="text" id="dsencfin3" name="dsencfin3" > 

			<!-- Texto no contrato -->

			<br style="clear:both" />

		</fieldset>

	</form>

	<div id="divBotoesFiltroLdesco" style='text-align:center; margin-bottom: 10px; margin-top: 10px; display:none;' >
		<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(2); return false;">Voltar</a>																
		<a href="#" class="botao" id="btProsseguir" name="btProsseguir" onClick="btnProsseguir();return false;" style="float:none;">Prosseguir</a>																				
	</div>