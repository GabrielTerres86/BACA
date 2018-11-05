<? 
/*!
 * FONTE        : form_filtro.php
 * CRIA��O      : Augusto Henrique da Conceição - (Supero)
 * DATA CRIA��O : 30/05/2018 
 * OBJETIVO     : Formulario para filtrar os cartórios.
 */
 
?>

<style>
    .labelFrmManCar {
        width:200px;
    } 
</style>

<form id="frmOpcao" class="formulario" onSubmit="return false;">

	<div id="divFiltro">
		<div>
			<label for="uf" class="labelFrmManCar">UF:</label>
    		<input name="uf" id="uf" type="text" class="campo" maxlength="2" style="margin-right: 5px">

			<br style="clear:both" />
			
			<label for="idcidade" class="labelFrmManCar">Cidade:</label>
			<input type="text" id="idcidade" name="idcidade" class="inteiro" style="width:80px" maxlength="8" />
			<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
			<input type="text" id="dscidade" name="dscidade" style="width:310px" />

			<br style="clear:both" />

			<label for="nrcpf_cnpj" class="labelFrmManCar"><? echo utf8ToHtml('CPF/CNPJ:') ?></label>
    		<input name="nrcpf_cnpj" id="nrcpf_cnpj" type="text" class="inteiro campo" maxlength="14" style="margin-right: 5px">

			<br style="clear:both" />
		</div>
	</div>		
</form>





