<? 
/*!
 * FONTE        : tab_custch.php
 * CRIAÇÃO      : Douglas Quisinski
 * DATA CRIAÇÃO : 11/05/2015
 * OBJETIVO     : Tabela que para reaizar a inclusão dos cheques para custódia
 * --------------
 * ALTERAÇÕES   : 
 */	
?>

<fieldset id='tabConteudo'>

	<form id="frmCustch" name="frmCustch" class="formulario" onSubmit="return false;" style="display:none" >
		<label for="dtchqbom">Data Boa:</label>
		<input type="text" id="dtchqbom" name="dtchqbom"/>
	
		<label for="vlcheque">Valor:</label>
		<input type="text" id="vlcheque" name="vlcheque"/>
	
		<label for="dsdocmc7">CMC-7:</label>
		<input type="text" id="dsdocmc7" name="dsdocmc7"/>
	
		<a href="#" class="botao" id="btnAdd">OK</a>
		<br style="clear:both;" />	
	</form>

	
	<div id="tabCustch">
		<div class="divRegistros">
			<table class="tituloRegistros" id="tbCheques">
				<thead>
					<tr>
						<th><? echo utf8ToHtml('Data Boa')?></th>
						<th><? echo utf8ToHtml('Valor')?></th>
						<th><? echo utf8ToHtml('Banco')?></th>
						<th><? echo utf8ToHtml('Agência')?></th>
						<th><? echo utf8ToHtml('Número do Cheque')?></th>
						<th><? echo utf8ToHtml('Número da Conta')?></th>
						<th><? echo utf8ToHtml('CMC-7')?></th>
						<th></th>
						<th><? echo utf8ToHtml('Crítica')?></th>
					</tr>
				</thead>
				<tbody>
				</tbody>
			</table>
		</div> 
	</div>
	
	<div id="divPesquisaRodape" class="divPesquisaRodape">
		<table>	
			<tr>
				<td id="qtdChequeCustodiar">
					Exibindo 0 cheques para custodiar. Valor Total R$ 0,00
				</td>
			</tr>
		</table>
	</div>
	
	<div id="divBotoes" style='border-top:1px solid #777'>
		<a href="#" class="botao" id="btNovo"      onClick="controlaBotao('N'); return false;">Novo Cheque</a>
		<a href="#" class="botao" id="btVoltar"    onClick="controlaBotao('C'); return false;">Cancelar</a>
		<a href="#" class="botao" id="btFinalizar" onClick="controlaBotao('F'); return false;">Finalizar</a>
	</div>	
</fieldset>

<script type="text/javascript">
	aux_dtmvtolt = "<?php echo $glbvars["dtmvtolt"]; ?>";
	formataCampoCheque();
	formataTabelaCustodia();
	$('#divPesquisaRodape').formataRodapePesquisa();
</script>