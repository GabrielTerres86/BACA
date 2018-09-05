<?php
	/*!
	 * FONTE        : form_usuarios.php
	 * CRIAÇÃO      : Diego Simas (AMcom)
	 * DATA CRIAÇÃO : 24/05/2018
	 * OBJETIVO     : Aba Usuários da Tela Convênio CDC 
	 * --------------
	 * ALTERAÇÕES   : 
	 *
	 * --------------
	 */	 
?>
<form name="frmUsuarios" id="frmUsuarios" class="formulario">
	<fieldset style="padding: 5px; height: 350px;">
		<input type="hidden" id="idcooperado_cdc" name="idcooperado_cdc" value="<?php echo $idcooperado_cdc; ?>" />	
		<legend style="margin-top: 10px; padding: 2px 10px 2px 10px">Dados para o Site da Cooperativa</legend>
		<div id="divRegistros" name="divRegistros" class="divRegistros">
			<table id="tableUsuarios" name="tableUsuarios" style="table-layout: fixed;">
				<thead>
					<tr>
						<th>Login</th>
						<th>Dt. Cria&ccedil;&atilde;o</th>
						<th>Ativo</th>
						<th>Bloqueado</th>
						<th>Tipo</th>
            <th>V&iacute;nculo</th>
					</tr>
				</thead>
				<tbody>
					<?php
						foreach($usuarios as $usuario){
							echo "<tr onclick=\"selecionaUsuario(".$usuario->tags[0]->cdata.");\">";
							echo "<td>".$usuario->tags[1]->cdata."</td>";
							echo "<td>".$usuario->tags[3]->cdata."</td>";
							echo "<td>".$usuario->tags[4]->cdata."</td>";
							echo "<td>".$usuario->tags[5]->cdata."</td>";
							echo "<td>".$usuario->tags[6]->cdata."</td>";							
              			    echo "<td>".$usuario->tags[7]->cdata."</td>";							
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
  	<input type="image" id="btAlterar" src="<? echo $UrlImagens; ?>botoes/alterar.gif" onClick="mostraFormUsuAlterar('<? echo $idcooperado_cdc; ?>'); return false;" />
</div>

<script>
	formataTabelaUsuarios();
</script>
