<?php
	/*!
	 * FONTE        : form_transferir_consultor.php
	 * CRIAÇÃO      : Heitor Augusto Schmitt (RKAM)
	 * DATA CRIAÇÃO : 07/10/2015
	 * OBJETIVO     : Transferência de Consultores para a tela CADCON
	 * --------------
	 * ALTERAÇÕES   : 
	 * --------------
	 */
?>
<div id="divTransferenciaConsultor">
	<form id="frmTrfConsultor" name="frmTrfConsultor" class="formulario" onSubmit="return false;" style="display:block">
		<label for="cdconsultororg"><? echo utf8ToHtml("Posi&ccedil;&atilde;o Origem:") ?></label>
		<input name="cdconsultororg" type="text"  id="cdconsultororg" class="campo"/>
		<a id="pesqconsulorg" name="pesqconsulorg" href="#" onClick="mostrarPesquisaConsultorOrg('#frmConsultor,#divBotoes');return false;" ><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" width="14" height="14" border="0"></a>
		<label for="cdoperadororg"><? echo utf8ToHtml("Consultor:") ?></label>
		<input name="cdoperadororg" type="text"  id="cdoperadororg" class="campo alphanum"/>
		<input name="nmoperadororg" type="text"  id="nmoperadororg" class="campo alphanum"/>
		<br style="clear:both" />
		<label for="cdconsultordst"><? echo utf8ToHtml("Posi&ccedil;&atilde;o Destino:") ?></label>
		<input name="cdconsultordst" type="text"  id="cdconsultordst" class="campo"/>
		<a id="pesqconsuldst" name="pesqconsuldst" href="#" onClick="mostrarPesquisaConsultorDst('#frmConsultor,#divBotoes');return false;" ><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" width="14" height="14" border="0"></a>
		<label for="cdoperadordst"><? echo utf8ToHtml("Consultor:") ?></label>
		<input name="cdoperadordst" type="text"  id="cdoperadordst" class="campo alphanum"/>
		<input name="nmoperadordst" type="text"  id="nmoperadordst" class="campo alphanum"/>
		<br style="clear:both" />

		<label for="tbTrfcon"><? echo utf8ToHtml("Contas associadas ao Consultor:") ?></label>
		<br style="clear:both" />

		<div id="tabTrfcon">
			<div class="divRegistros">
				<table class="tituloRegistros" id="tbTrfcon">
					<thead>
						<tr>
							<th><? echo utf8ToHtml("Conta");?></th>
							<th><? echo utf8ToHtml("Nome do cooperado");?></th>
							<th><? echo utf8ToHtml("PA");?></th>
							<th><? echo utf8ToHtml("Nome do Posto de Atendimento");?></th>
							<th><? echo utf8ToHtml("Transferir");?></th>
						</tr>
					</thead>
					<tbody>
					</tbody>
				</table>
			</div> 
		</div>
	</form>
</div>