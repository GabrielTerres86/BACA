<?php
	/*!
	 * FONTE        : form_alteracao_consultor.php
	 * CRIAÇÃO      : Heitor Augusto Schmitt (RKAM)
	 * DATA CRIAÇÃO : 07/10/2015
	 * OBJETIVO     : Alteracao de Consultores para a tela CADCON
	 * --------------
	 * ALTERAÇÕES   : 
	 * --------------
	 */
?>
<div id="divAlteracaoConsultor">
	<form id="frmAltConsultor" name="frmAltConsultor" class="formulario" onSubmit="return false;" style="display:block">
		<label for="cdconsultor"><? echo utf8ToHtml("Posi&ccedil;&atilde;o:") ?></label>
		<input name="cdconsultor" type="text"  id="cdconsultor" class="campo"/>
		<a href="#" class="botao" id="btnAtivarInativar" name="btnAtivarInativar" onclick="ativarInativar(); return false;" style = "text-align:right;">Ativar/Inativar</a>
		<label for="cdoperador"><? echo utf8ToHtml("Consultor:") ?></label>
		<input name="cdoperador" type="text"  id="cdoperador" class="campo alphanum"/>
		<a id="pesqoperad" name="pesqoperad" href="#" onClick="mostrarPesquisaOperador('#frmAltConsultor,#divBotoes');return false;" ><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" width="14" height="14" border="0"></a>
		<input name="nmoperador" type="text"  id="nmoperador" class="campo alphanum"/>
		<br style="clear:both" />
		
		<label for="cdagenci"><? echo utf8ToHtml("Posto de Atendimento:") ?></label>
		<input name="cdagenci" type="text"  id="cdagenci" class="campo"/>
		<a id="pesqagenci" name="pesqagenci" href="#" onClick="mostrarPesquisaAgencia('#frmAltConsultor,#divBotoes');return false;" ><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" width="14" height="14" border="0"></a>
		<input name="nmextage" type="text"  id="nmextage" class="campo"/>
		<a href="#" class="botao" id="btnIncluirAgencia" name="btnIncluirAgencia" style = "text-align:right;" onclick="incluirAgenciaAlt(); return false;"><? echo utf8ToHtml("Incluir PA");?></a>
		<br style="clear:both" />
		<label for="tbAltcon"><? echo utf8ToHtml("PAs atendidos pelo Consultor:") ?></label>
		<br style="clear:both" />

		<div id="tabAltcon">
			<div class="divRegistros">
				<table class="tituloRegistros" id="tbAltcon">
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