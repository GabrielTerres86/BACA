<form  class="formulario">
	<fieldset>
		<legend>Border&ocirc;s</legend>
		<div id="divBorderosChecagem">
			<div class="divRegistros">
				<table class='borderosRegistros'>
					<thead>
						<tr>
							<th>Border&ocirc;</th>
							<th>Conta</th>
							<th>Valor da Proposta</th>
							<th>Produto de C&eacute;dito</th>
							<th>Situa&ccedil;&atilde;o</th>
							<th>Decis&atilde;o da An&aacute;lise</th>
							<th>Operador</th>
						</tr>			
					</thead>
					<tbody>
					</tbody>
				</table>
			</div>
		</div>
		<div id="divBotoes">
			<input type="button" class="botao" value="Analisar" onClick="analisarTitulo();return false;"/>
		</div>
	</fieldset>
</form>
<script>
	$(document).ready(function(){
		buscarBorderos();
	})
</script>