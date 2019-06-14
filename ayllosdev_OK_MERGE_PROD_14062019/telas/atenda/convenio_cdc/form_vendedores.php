<?php
	/*!
	 * FONTE        : form_vendedores.php
	 * CRIAÇÃO      : Diego Simas (AMcom)
	 * DATA CRIAÇÃO : 21/05/2018
	 * OBJETIVO     : Aba Vendedores da Tela Convênio CDC 
	 * --------------
	 * ALTERAÇÕES   : 
	 *
	 * --------------
	 */	 
?>
<form name="frmVendedores" id="frmVendedores" class="formulario">
	<fieldset style="padding: 5px; height: 350px;">
		<input type="hidden" id="idcooperado_cdc" name="idcooperado_cdc" value="<?php echo $idcooperado_cdc; ?>" />	
		<legend style="margin-top: 10px; padding: 2px 10px 2px 10px">Dados para o Site da Cooperativa</legend>
		<div id="divRegistros" name="divRegistros" class="divRegistros">
			<table id="tableVendedores" name="tableVendedores" style="table-layout: fixed;">
				<thead>
					<tr>
						<th>C&oacuted.</th>
						<th>Nome</th>
						<th>CPF</th>
						<th>E-mail</th>
						<th>Ativo</th>
						<th>Comiss&atildeo</th>
					</tr>
				</thead>
				<tbody>
					<?php
						foreach($vendedores as $vendedor){
							echo "<tr>";
							echo "<td>".$vendedor->tags[0]->cdata."</td>";
							echo "<td>".$vendedor->tags[1]->cdata."</td>";
							echo "<td>".$vendedor->tags[2]->cdata."</td>";
							echo "<td style='word-wrap:break-word'>".$vendedor->tags[3]->cdata."</td>";
							echo "<td>".$vendedor->tags[4]->cdata."</td>";
							echo "<td>".$vendedor->tags[5]->cdata."</td>";							
							echo "</tr>";
						}
					?>
				</tbody>
			<table>
		</div>
	</fieldset>
</form>

<div id="divBotoes">	
	<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="acessaOpcaoAba('P',0); return false;" />	
</div>

<script>
	formataTabelaVendedores();
</script>
