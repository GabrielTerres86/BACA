
<div class="divRegistros">	
	<table id="tituloRegistros" class="tituloRegistros">
		<thead>
			<tr>
				<th><? echo utf8ToHtml('Grupo'); ?></th>
				<th><? echo utf8ToHtml('Cota'); ?></th>
				<th><? echo utf8ToHtml('Tipo');  ?></th>
				<th><? echo utf8ToHtml('Inicio');  ?></th>
				<th><? echo utf8ToHtml('Valor Carta');  ?></th>
				<th><? echo utf8ToHtml('Parc.');  ?></th>
				<th><? echo utf8ToHtml('Valor Parcela');  ?></th>
				<th>Situação</th>
			</tr>
		</thead>
		<tbody>
			<? foreach( $consorcio as $banco ) {  $contador++;  ?>
			
				<tr>
						<input type="hidden" id="contador" name="contador" value="<? echo $contador ?>" />
						<input type="hidden" id="dtdebito" name="qtparctr" value="<? echo getByTagName($banco->tags,'dtdebito'); ?>" />
						<input type="hidden" id="dtfimcns" name="dtfimcns" value="<? echo getByTagName($banco->tags,'dtfimcns'); ?>" />
						<input type="hidden" id="parcpaga" name="parcpaga" value="<? echo getByTagName($banco->tags,'parcpaga'); ?>" />
						<input type="hidden" id="nrdgrupo" name="nrdgrupo" value="<? echo getByTagName($banco->tags,'nrdgrupo'); ?>" />
						<input type="hidden" id="nrcotcns" name="nrcotcns" value="<? echo getByTagName($banco->tags,'nrcotcns'); ?>" />
						<input type="hidden" id="nrctacns" name="nrctacns" value="<? echo getByTagName($banco->tags,'nrctacns'); ?>" />
						<input type="hidden" id="dsconsor" name="dsconsor" value="<? echo getByTagName($banco->tags,'dsconsor'); ?>" />
						<input type="hidden" id="vlrcarta" name="vlrcarta" value="<? echo getByTagName($banco->tags,'vlrcarta'); ?>" />
						<input type="hidden" id="nrctrato" name="nrctrato" value="<? echo getByTagName($banco->tags,'nrctrato'); ?>" />
						
						
									
					<td><? echo getByTagName($banco->tags,'nrdgrupo'); ?></td>
					
					<td id="nrcotcns"><? echo getByTagName($banco->tags,'nrcotcns');  ?>
						<input type="hidden" id="tbnrcotcns" name="tbnrcotcns" value="<? echo getByTagName($banco->tags,'nrcotcns'); ?>" />
					</td>	
					<td><? echo getByTagName($banco->tags,'dsconsor'); ?></td>
					<td><? echo getByTagName($banco->tags,'dtinicns'); ?></td>
					<td><? echo number_format(str_replace(",",".",getByTagName($banco->tags,'vlrcarta')),2,",","."); ?></td>
					<td><? echo formataNumericos("zz9",getByTagName($banco->tags,'qtparcns'),"."); ?></td>
					<td style="text-align: right;"><? echo number_format(str_replace(",",".",getByTagName($banco->tags,'vlparcns')),2,",","."); ?></td>
					<td style="text-align: right;"><? echo getByTagName($banco->tags,'instatus'); ?></td>
					
					
				</tr>
				
				<script>
					criaObjetoConsorcio('<? echo getByTagName($banco->tags,'nrcotcns'); ?>', 
										'<? echo getByTagName($banco->tags,'vlrcarta'); ?>',
										'<? echo getByTagName($banco->tags,'qtparcns'); ?>',
										'<? echo getByTagName($banco->tags,'vlparcns'); ?>',
										'<? echo getByTagName($banco->tags,'dtinicns'); ?>', 
										'<? echo getByTagName($banco->tags,'dtdebito'); ?>',
										'<? echo getByTagName($banco->tags,'dtfimcns'); ?>',
										'<? echo getByTagName($banco->tags,'instatus'); ?>',
										'<? echo getByTagName($banco->tags,'dsconsor'); ?>',
										'<? echo getByTagName($banco->tags,'parcpaga'); ?>',
										'<? echo getByTagName($banco->tags,'nrdgrupo'); ?>',
										'<? echo getByTagName($banco->tags,'nrctacns'); ?>',
										'<? echo getByTagName($banco->tags,'nrdiadeb'); ?>',
										'<? echo getByTagName($banco->tags,'nrctrato'); ?>');
											
				</script>
		<? } ?>	
		</tbody>
	</table>
</div>	

<script type="text/javascript">
	controlaLayout();
</script>

<div id="divBotoes">
	<input type="image" id="btVoltar" src="<? echo $UrlImagens; ?>botoes/voltar.gif" onClick="encerraRotina(true);return false;" />
	<input class="FluxoNavega" id="btndossie" style="margin-left: 3px;" onclick="dossieDigdoc(3);return false;" type="image" src="http://aylloshomol2.cecred.coop.br/imagens/botoes/dossie.gif">
	<input type="image" id="btConsultar" src="<? echo $UrlImagens; ?>botoes/consultar.gif" onClick="btConsultar();" /> 
</div>
