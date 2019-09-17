<? 
/*!
 * FONTE        : form_regras.php
 * CRIAÇÃO      : James Prust Junior
 * DATA CRIAÇÃO : 15/12/2014
 * OBJETIVO     : Formulario de Regras.
 * --------------
 * ALTERAÇÕES   : 21/09/2016 - Inclusão dos campos "pcliqdez" e "qtdialiq" no formulario de regras. Projeto 300. (Lombardi)
 *
 *                16/03/2018 - Inclusão de novo campo (Quantidade de Meses do novo limite após o cancelamento) (Diego Simas - AMcom)
 *
 *                27/04/2018 - Alteração  da situação de "1,2,3,4,5,6,8,9" para "1,2,3,4,5,7,8,9". 
 *                             Projeto 366. (Lombardi)
 * --------------
 */	
?>
<form id="frmRegra" name="frmRegra" class="formulario">

	<fieldset id="frmConteudo">
	
		<legend><? echo ('Regra') ?></legend>
				
		<table width="100%">
			<tr>
				<td>
					<label for="vlmaxren">Valor M&aacute;ximo do Limite:</label>	
					<input name="vlmaxren" type="text"  id="vlmaxren" /> <label>&nbsp;(R$)</label>
				</td>
			</tr>
			<tr>
				<td>
					<label for="qtdiaren">Tentativas Di&aacute;rias de Renova&ccedil;&otilde;es:</label>	
					<input name="qtdiaren" type="text"  id="qtdiaren" /> <label>&nbsp;Dias Corridos</label>
				</td>
			</tr>
			<tr>
				<td>
					<label for="qtmaxren">Qtde. M&aacute;xima de Renova&ccedil;&otilde;es:</label>	
					<input name="qtmaxren" type="text"  id="qtmaxren" />
				</td>
			</tr>
			<?if($tplimite==3){?>
			<tr>
				<td>
					<label for="qtdiaatr">Opera&ccedil;&otilde;es de Cr&eacute;dito em Atraso:</label>	
					<input name="qtdiaatr" type="text"  id="qtdiaatr" /> 
					<label>&nbsp;</label>
				</td>
			</tr>
			<?}
			else{?>
			<tr>
				<td>
					<label for="qtdiaatr">Empr&eacute;stimo em Atraso:</label>	
					<input name="qtdiaatr" type="text"  id="qtdiaatr" /> <label>&nbsp;Dias</label>
				</td>
			</tr>
			<?}?>
			<tr>
				<td>
					<label for="qtatracc">Conta Corrente em Atraso:</label>	
					<input name="qtatracc" type="text"  id="qtatracc" /> <label>&nbsp;Dias</label>
				</td>
			</tr>
			<!-- DIEGO SIMAS (AMcom) !-->
			<tr class="cmpsLimCred">
				<td>
					<label for="qtmeslic">Inclusão Novo Limite após o Cancelamento:</label>
					<input name="qtmeslic" type="text"  id="qtmeslic" /> <label>&nbsp;Meses</label>
				</td>
			</tr>
			<tr class="cmpsLimCred">
				<td>
					<label for="cnauinad">Cancelamento automático por inadimplência:</label>
					<select name="cnauinad" id="cnauinad" onchange="defineCamposCancAuto()">
						<option value="1">Sim</option>
						<option value="0">Não</option>
					</select>
				<td>
			</tr>
			<tr class="cmpsLimCred">
				<td class="cancelautoinad">
					<label for="qtdiatin">Quantidade de Dias de Atraso:</label>
					<input name="qtdiatin" type="text"  id="qtdiatin" onblur="validaDiasAtraso()" /> <label> &nbsp;Dias</label>
				</td>
			</tr>
			<tr>		
				<td>
					<label for="dssitdop">Situa&ccedil;&atilde;o da Conta:</label>
					<?
					$arrsitua = array('1','2','3','4','5','7','8','9');
					foreach ($arrsitua as $flgsitua) {
						echo '<label for="sit' . $flgsitua . '">' . $flgsitua . '</label>';
						echo '<input type="checkbox" name="dssitdop" id="sit' . $flgsitua . '" value="' . $flgsitua . '"/>';
					}
					?>
				</td>
			</tr>
			<tr>		
				<td>
					<label for="dsriscop">Risco da Conta:</label>
					<?
					$aRisco = array('A','B','C','D','E','F','G','H');
					foreach ($aRisco as $value) {
						echo '<label for="ris' . $value . '">' . $value . '</label>';
						echo '<input type="checkbox" name="dsriscop" id="ris' . $value . '" value="' . $value . '"/>';
					}
					?>
				</td>
			</tr>			
			<tr>
				<td>
					<label for="qtmincta">Tempo de Conta:</label>
					<select name="qtmincta" id="qtmincta">
						<? for ($i = 1; $i <= 24;$i++){ ?>
							<option value="<?= $i ?>"><?= $i ?></option>
						<? } ?>
					</select>
					<label>&nbsp;Meses</label>
				</td>
			</tr>
			<tr>
				<td>
					<label for="nrrevcad">Revis&atilde;o Cadastral:</label>	
					<select name="nrrevcad" id="nrrevcad">
						<? for ($i = 1; $i <= 36;$i++){ ?>
							<option value="<?= $i ?>"><?= $i ?></option>
						<? } ?>
					</select>
					<label>&nbsp;Meses</label>
				</td>
			</tr>
			<tr class="cmpstlim">
				<td>
					<label for="pcliqdez">Percentual de Liquidez:</label>	
					<input name="pcliqdez" type="text"  id="pcliqdez" />
					<label>&nbsp;%</label>
				</td>
			</tr>
			<tr class="cmpstlim">
				<td>
					<label for="qtdialiq">Qtd. Dias Calculo % de Liquidez:</label>	
					<input name="qtdialiq" type="text"  id="qtdialiq" />
				</td>
			</tr>
			<?if($tplimite==3){?>
			<tr>
				<td>
					<label for="qtcarpag">Per&iacute;odo de Car&ecirc;ncia de Pagamento:</label>	
					<input name="qtcarpag" type="text"  id="qtcarpag" /> 
					<label>&nbsp; Dias</label>
				</td>
			</tr>
			<tr>
				<td>
					<label for="qtaltlim">Per&iacute;odo de Altera&ccedil;&atilde;o de Limites Rejeitados:</label>	
					<input name="qtaltlim" type="text"  id="qtaltlim" /> 
					<label>&nbsp; Dias</label>
				</td>
			</tr>
			<?}?>
		</table>
	</fieldset>	
				
</form>
