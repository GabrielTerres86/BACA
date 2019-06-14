<?php
/*!
 * FONTE        : form_cadastro.php
 * CRIAÇÃO      : Douglas Quisinski
 * DATA CRIAÇÃO : 15/04/2016
 * OBJETIVO     : Formulario de alteracao dos horarios de pagamento da COMPE
 * --------------
 * ALTERAÇÕES   : 19/06/2017 - Removida a linha com informações da Devolução VLB, e alterada
                               a descrição "Devolução Noturna" para "Devolução Fraude/Imp.:".
				               PRJ367 - Compe Sessao Unica (Lombardi)
 * --------------
 */ 
?>

<?
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');	
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
?>

<form id="frmHorarios" name="frmHorarios" class="formulario condensado">
	<div id="divHorarios" >

		<!-- Fieldset para os campos de HORARIO DE PAGAMENTO -->
		<fieldset id="fsetDadosHorarioPagamento" name="fsetDadosHorarioPagamento" style="padding-bottom:10px;">
			
			<legend>Hor&aacute;rio de Pagamento</legend>

			<table width="100%">
				<tr>
					<td>
						<label for="hrsicred"><? echo utf8ToHtml('SICREDI:') ?></label>
						<select class="campo" id="hrsicatu" name="hrsicatu">
							<option value="S"><? echo utf8ToHtml('Atualizar')?></option>
							<option value="N"><? echo utf8ToHtml('N&atilde;o Atualizar')?></option>
						</select>
						<label for="hrsicini"><? echo utf8ToHtml('- In&iacute;cio:') ?></label>
						<input id="hrsicini" name="hrsicini" type="text"/>
						<label for="hrsicfim"><? echo utf8ToHtml('Fim:') ?></label>
						<input id="hrsicfim" name="hrsicfim" type="text"/>
					</td>
				</tr>
				<tr>
					<td>
						<label for="hrtitulo"><? echo utf8ToHtml('T&iacute;tulos/Faturas:') ?></label>
						<select class="campo" id="hrtitatu" name="hrtitatu">
							<option value="S"><? echo utf8ToHtml('Atualizar')?></option>
							<option value="N"><? echo utf8ToHtml('N&atilde;o Atualizar')?></option>
						</select>
						<label for="hrtitini"><? echo utf8ToHtml('- In&iacute;cio:') ?></label>
						<input id="hrtitini" name="hrtitini" type="text"/>
						<label for="hrtitfim"><? echo utf8ToHtml('Fim:') ?></label>
						<input id="hrtitfim" name="hrtitfim" type="text"/>
					</td>
				</tr>
				<tr>
					<td>
						<label for="hrnetmob"><? echo utf8ToHtml('Internet/Mobile:') ?></label>
						<select class="campo" id="hrnetatu" name="hrnetatu">
							<option value="S"><? echo utf8ToHtml('Atualizar')?></option>
							<option value="N"><? echo utf8ToHtml('N&atilde;o Atualizar')?></option>
						</select>
						<label for="hrnetini"><? echo utf8ToHtml('- In&iacute;cio:') ?></label>
						<input id="hrnetini" name="hrnetini" type="text"/>
						<label for="hrnetfim"><? echo utf8ToHtml('Fim:') ?></label>
						<input id="hrnetfim" name="hrnetfim" type="text"/>
					</td>
				</tr>
				<tr>
					<td>
						<label for="hrpagtaa"><? echo utf8ToHtml('TAA:') ?></label>
						<select class="campo" id="hrtaaatu" name="hrtaaatu">
							<option value="S"><? echo utf8ToHtml('Atualizar')?></option>
							<option value="N"><? echo utf8ToHtml('N&atilde;o Atualizar')?></option>
						</select>
						<label for="hrtaaini"><? echo utf8ToHtml('- In&iacute;cio:') ?></label>
						<input id="hrtaaini" name="hrtaaini" type="text"/>
						<label for="hrtaafim"><? echo utf8ToHtml('Fim:') ?></label>
						<input id="hrtaafim" name="hrtaafim" type="text"/>
					</td>
				</tr>
				<tr>
					<td>
						<label for="hrpaggps"><? echo utf8ToHtml('GPS:') ?></label>
						<select class="campo" id="hrgpsatu" name="hrgpsatu">
							<option value="S"><? echo utf8ToHtml('Atualizar')?></option>
							<option value="N"><? echo utf8ToHtml('N&atilde;o Atualizar')?></option>
						</select>
						<label for="hrgpsini"><? echo utf8ToHtml('- In&iacute;cio:') ?></label>
						<input id="hrgpsini" name="hrgpsini" type="text"/>
						<label for="hrgpsfim"><? echo utf8ToHtml('Fim:') ?></label>
						<input id="hrgpsfim" name="hrgpsfim" type="text"/>
					</td>
				</tr>
			</table>
		</fieldset>
	
		<!-- Fieldset para os campos de HORARIO DE ESTORNO DE PAGAMENTO -->
		<fieldset id="fsetDadosHorarioPagamento" name="fsetDadosHorarioPagamento" style="padding-bottom:10px;">
			
			<legend>Hor&aacute;rio de Estorno de Pagamento</legend>

			<table width="100%">
				<tr>
					<td>
						<label for="hrsiccan"><? echo utf8ToHtml('SICREDI:') ?></label>
						<select class="campo" id="hrsiccau" name="hrsiccau">
							<option value="S"><? echo utf8ToHtml('Atualizar')?></option>
							<option value="N"><? echo utf8ToHtml('N&atilde;o Atualizar')?></option>
						</select>
						<label for="hrsiclim"><? echo utf8ToHtml('- Limite:') ?></label>
						<input id="hrsiccan" name="hrsiccan" type="text"/>
					</td>
				</tr>
				<tr>
					<td>
						<label for="hrtitcan"><? echo utf8ToHtml('T&iacute;tulos/Faturas:') ?></label>
						<select class="campo" id="hrtitcau" name="hrtitcau">
							<option value="S"><? echo utf8ToHtml('Atualizar')?></option>
							<option value="N"><? echo utf8ToHtml('N&atilde;o Atualizar')?></option>
						</select>
						<label for="hrtitlim"><? echo utf8ToHtml('- Limite:') ?></label>
						<input id="hrtitcan" name="hrtitcan" type="text"/>
					</td>
				</tr>
				<tr>
					<td>
						<label for="hrnetcan"><? echo utf8ToHtml('Internet/Mobile:') ?></label>
						<select class="campo" id="hrnetcau" name="hrnetcau">
							<option value="S"><? echo utf8ToHtml('Atualizar')?></option>
							<option value="N"><? echo utf8ToHtml('N&atilde;o Atualizar')?></option>
						</select>
						<label for="hrnetlim"><? echo utf8ToHtml('- Limite:') ?></label>
						<input id="hrnetcan" name="hrnetcan" type="text"/>
					</td>
				</tr>
				<tr>
					<td>
						<label for="hrtaacan"><? echo utf8ToHtml('TAA:') ?></label>
						<select class="campo" id="hrtaacau" name="hrtaacau">
							<option value="S"><? echo utf8ToHtml('Atualizar')?></option>
							<option value="N"><? echo utf8ToHtml('N&atilde;o Atualizar')?></option>
						</select>
						<label for="hrtaalim"><? echo utf8ToHtml('- Limite:') ?></label>
						<input id="hrtaacan" name="hrtaacan" type="text"/>
					</td>
				</tr>
			</table>
		</fieldset>
		
		<!-- Fieldset para os campos de DEVOLUCAO DE CHEQUES -->
		<fieldset id="fsetDadosDevolucaoCheque" name="fsetDadosDevolucaoCheque" style="padding-bottom:10px;">
			
			<legend>Devolu&ccedil;&atilde;o de Cheques</legend>

			<table width="100%">
				<tr>
					<td>
						<label for="hrdevdiu"><? echo utf8ToHtml('Devolu&ccedil;&atilde;o Diurna:') ?></label>
						<select class="campo" id="hrdiuatu" name="hrdiuatu">
							<option value="S"><? echo utf8ToHtml('Atualizar')?></option>
							<option value="N"><? echo utf8ToHtml('N&atilde;o Atualizar')?></option>
						</select>
						<label for="hrdiuini"><? echo utf8ToHtml('- In&iacute;cio:') ?></label>
						<input id="hrdiuini" name="hrdiuini" type="text"/>
						<label for="hrdiufim"><? echo utf8ToHtml('Fim:') ?></label>
						<input id="hrdiufim" name="hrdiufim" type="text"/>
					</td>
				</tr>
				<tr>
					<td>
						<label for="hrdevnot"><? echo utf8ToHtml('Devolu&ccedil;&atilde;o Fraude/Imp:') ?></label>
						<select class="campo" id="hrnotatu" name="hrnotatu">
							<option value="S"><? echo utf8ToHtml('Atualizar')?></option>
							<option value="N"><? echo utf8ToHtml('N&atilde;o Atualizar')?></option>
						</select>
						<label for="hrnotini"><? echo utf8ToHtml('- In&iacute;cio:') ?></label>
						<input id="hrnotini" name="hrnotini" type="text"/>
						<label for="hrnotfim"><? echo utf8ToHtml('Fim:') ?></label>
						<input id="hrnotfim" name="hrnotfim" type="text"/>
					</td>
				</tr>
			</table>
		</fieldset>
	</div>
</form>
