<?php
	/*!
    * FONTE        : form_cabecalho.php
	* CRIA��O      : Amasonas Borges Vieira Junior(Supero)
	* DATA CRIA��O : 19/02/2018
	* OBJETIVO     : Cabecalho para a tela LIMCRD
	* --------------
	* ALTERA��ES   :
	* --------------
	*/
?>
<form id="frmCab" name="frmCab" class="formulario cabecalho">
	<table width="100%">
		<tr>
			<td>
				<label for="cddotipo"><? echo utf8ToHtml("Op&ccedil;&atilde;o:") ?></label>
				<select class="campo" id="cddotipo" name="cddotipo" >
					<option value="I"><? echo utf8ToHtml("I - Incluir Limite") ?></option>
					<option value="C"><? echo utf8ToHtml("C - Consultar Limites") ?></option>
					<option value="A"><? echo utf8ToHtml("A - Alterar Limites") ?></option>
					<option value="E"><? echo utf8ToHtml("E - Excluir Limites") ?></option>
				</select>
				<select class="campo" id="tplimcrd">
					<option value="0"><? echo utf8ToHtml("C - Concessão") ?></option>
					<option value="1"><? echo utf8ToHtml("A - Alteração") ?></option>
				</select>
				<? build_card_adm_select("mainAdmCrd", $glbvars);?> 
				<a href="#" class="botao" id="btnOK" name="btnOK" style = "text-align:right;">OK</a>
			</td>
		</tr>
	</table>
</form>