<?php
	/*!
	 * FONTE        : form_cadastro_assessoria.php
	 * CRIAÇÃO      : Douglas Quisinski
	 * DATA CRIAÇÃO : 25/08/2015
	 * OBJETIVO     : Cadastro de Assessorias para a tela CADCAS
	 * --------------
	 * ALTERAÇÕES   : Inclusão do campo "cdasscyb" Código de Acessoria do CYBER, Prj. 302 (Jean Michel)
	 * --------------
	 */
?>
<form id="frmAssessoria" name="frmAssessoria" class="formulario" onSubmit="return false;" style="display:block">
	<label for="cdassessoria"><? echo utf8ToHtml("C&oacute;digo:") ?></label>
	<input name="cdassessoria" type="text"  id="cdassessoria" class="campo"/>
	<a id="pesqassess" name="pesqassess" href="#" onClick="mostrarPesquisaAssessoria('#frmAssessoria,#divBotoes');return false;" ><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" width="14" height="14" border="0"></a>
	<br/>
	<label for="cdasscyb"><? echo utf8ToHtml("C&oacute;digo CYBER:") ?></label>
	<input name="cdasscyb" type="text"  id="cdasscyb" class="inteiro"/>
	<br />
	<label for="nmassessoria"><? echo utf8ToHtml("Nome da Assessoria:") ?></label>
	<input name="nmassessoria" type="text"  id="nmassessoria" class="campo alphanum"/>
	<br style="clear:both" />
</form>