<div id="divFiltrosBorderos">
	<form name="formFiltrosChecagem" class="formulario">
		<fieldset>
			<legend>Filtrar Border&ocirc;s</legend>


	        <label for="nrdconta">Conta:</label>
	        <input type="text" id="nrdconta" name="nrdconta" value="<?php echo formataContaDV($nrdconta) ?>" class="navigation"/>
	        <a class='lupaConta'><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>

	        <label for="nrcpfcgc">CPF/CNPJ:</label>
	        <input type="text" id="nrcpfcgc" name="nrcpfcgc" value="<?php echo $nrcpfcgc ?>" class="navigation"/>

	        <label for="nmprimtl">Titular:</label>
	        <input type="text" id="nmprimtl" name="nmprimtl" value="<?php echo $nmprimtl ?>"  class="navigation"/>

		    <label for="nrborder">Border&ocirc;</label>
		    <input type="text" id="nrborder" name="nrborder" value="<?php echo $nrborder ?>"  class="navigation"/>

		    <label for="dtborini">De</label>
		    <input type="text" id="dtborini" name="dtborini" value="<?php echo $dtborini ?>"  class="navigation"/>

		    <label for="dtborfim">At&eacute;</label>
		    <input type="text" id="dtborfim" name="dtborfim" value="<?php echo $dtborfim ?>"  class="navigation"/>

		    <br>
		    <div style="float:right;">
				<input type="button" class="botao" onclick="limpaFormulario();" value="Limpar Filtros"/>
				<input type="button" class="botao" onclick="buscarBorderos();" value="Pesquisar"/>
			</div>
			<input type="button" id="btVoltar" onclick="btnVoltar()"/>
		</fieldset>
	</form>
</div>