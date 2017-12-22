<?php
	/*!
	 * FONTE        : form_segmento_cdc.php
	 * CRIAÇÃO      : Jean Michel Deschamps
	 * DATA CRIAÇÃO : 29/11/2017
	 * OBJETIVO     : Formulário da rotina Segmentos de Convenio CDC da tela de CONTAS 
	 * --------------
	 * ALTERAÇÕES   : 
	 *
	 * --------------
	 */	 
?>
<form name="frmSegmentoCdc" id="frmSegmentoCdc" class="formulario">
  <input type="hidden" id="idcooperado_cdc" name="idcooperado_cdc" value="<?php echo $idcooperado_cdc ; ?>" />	
	<label for="cdsubsegmento">Subsegmento:</label>
	<input type="text" id="cdsubsegmento" name="cdsubsegmento" value=""/>
	<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" onclick="controlaPesquisasSegmentos();"></a>		
	<input type="text" id="dssubsegmento" name="dssubsegmento" value="" />
	<fieldset style="padding: 5px; height: 350px;">
		<legend style="margin-top: 10px; padding: 2px 10px 2px 10px">Dados para o Site da Cooperativa</legend>
		<div id="divRegistros" name="divRegistros" class="divRegistros">
			<table id="tableSegmento" name="tableSegmento">
				<thead>
					<tr>
						<th>Cod.</th>
						<th>Segmento</th>
						<th>Cod.</th>
						<th>Subsegmento</th>
						<th>Parcela Máx</th>
						<th>Valor Máximo</th>
					</tr>
				</thead>
				<tbody>
					<?php
						foreach($subsegmentos as $subsegmento){
							echo "<tr onclick=\"selecionaSubsegmento(".$subsegmento->tags[2]->cdata.");\">";
							echo "<td>".$subsegmento->tags[0]->cdata."</td>";
							echo "<td>".$subsegmento->tags[1]->cdata."</td>";
							echo "<td>".$subsegmento->tags[2]->cdata."</td>";
							echo "<td>".$subsegmento->tags[3]->cdata."</td>";
							echo "<td>".$subsegmento->tags[4]->cdata."</td>";
							echo "<td>".$subsegmento->tags[5]->cdata."</td>";
							echo "</tr>";
						}
					?>
				</tbody>
			<table>
		</div>
	</fieldset>
</form>

<div id="divBotoes">	
	<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="fechaRotina(divRotina)" />
	<input type="image" id="btAlterar" src="<? echo $UrlImagens; ?>botoes/incluir.gif" onClick="manterSubsegmento('I')" />
	<input type="image" id="btAlterar" src="<? echo $UrlImagens; ?>botoes/excluir.gif" onClick="showConfirmacao('Deseja excluir subsegmento?'	,'Confirma&ccedil;&atilde;o - CDC','manterSubsegmento(\'E\');','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));','sim.gif','nao.gif');" />
</div>

<script>
	formataTabelaSegmento();
</script>