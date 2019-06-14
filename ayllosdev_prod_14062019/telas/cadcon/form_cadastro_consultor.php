<?php
	/*!
	 * FONTE        : form_cadastro_consultor.php
	 * CRIAÇÃO      : Heitor Augusto Schmitt (RKAM)
	 * DATA CRIAÇÃO : 07/10/2015
	 * OBJETIVO     : Cadastro de Consultores para a tela CADCON
	 * --------------
	 * ALTERAÇÕES   : 
	 * --------------
	 */
?>
<div id="divCadastroConsultor">
	<form id="frmCadConsultor" name="frmCadConsultor" class="formulario" onSubmit="return false;" style="display:block">
		<label for="cdconsultor"><? echo utf8ToHtml("Posi&ccedil;&atilde;o:") ?></label>
		<input name="cdconsultor" type="text"  id="cdconsultor" class="campo"/>
		<label for="cdoperador"><? echo utf8ToHtml("Consultor:") ?></label>
		<input name="cdoperador" type="text"  id="cdoperador" class="campo alphanum"/>
		<a id="pesqoperad" name="pesqoperad" href="#" onClick="mostrarPesquisaOperador('#frmCadConsultor,#divBotoes');return false;" ><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" width="14" height="14" border="0"></a>
		<input name="nmoperador" type="text"  id="nmoperador" class="campo alphanum"/>
		<label for="cdagenci"><? echo utf8ToHtml("Posto de Atendimento:") ?></label>
		<input name="cdagenci" type="text"  id="cdagenci" class="campo"/>
		<a id="pesqagenci" name="pesqagenci" href="#" onClick="mostrarPesquisaAgencia('#frmCadConsultor,#divBotoes');return false;" ><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" width="14" height="14" border="0"></a>
		<input name="nmextage" type="text"  id="nmextage" class="campo"/>
		<a href="#" class="botao" id="btnIncluirAgencia" name="btnIncluirAgencia" style = "text-align:right;" onclick="incluirAgenciaCad(); return false;"><? echo utf8ToHtml("Incluir PA");?></a>
		<br style="clear:both" />

		<label for="tbCadcon"><? echo utf8ToHtml("PAs atendidos pelo Consultor:") ?></label>
		<br style="clear:both" />

		<div id="tabCadcon">
			<div class="divRegistros">
				<table class="tituloRegistros" id="tbCadcon">
					<thead>
						<tr>
							<th><? echo utf8ToHtml("C&oacute;digo");?></th>
							<th><? echo utf8ToHtml("Nome do Posto de Atendimento");?></th>
							<th><? echo utf8ToHtml("Exclus&atilde;o");?></th>
						</tr>
					</thead>
					<tbody>
					</tbody>
				</table>
			</div> 
		</div>
	</form>
</div>