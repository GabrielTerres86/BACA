<?php
	/*!
	 * FONTE        : form_cadastro_assessoria.php
	 * CRIAÇÃO      : Douglas Quisinski
	 * DATA CRIAÇÃO : 25/08/2015
	 * OBJETIVO     : Cadastro de Assessorias para a tela CADCAS
	 * --------------
	 * ALTERAÇÕES   : Inclusão do campo "cdasscyb" Código de Acessoria do CYBER, Prj. 302 (Jean Michel)
     *
     *                17/01/2017 - inclusao campos flgjudic e fljudext - prj 432 (Jean Calão / Mout´S)
     *                15/02/2017 - inclusao campo sigla cyber - melhoria 432 (Jean Calão / Mout´s)  
	 * --------------
	 */
?>
<form id="frmAssessoria" name="frmAssessoria" class="formulario" onSubmit="return false;" style="display:block">
	<label for="cdassessoria"><? echo utf8ToHtml("C&oacute;digo:") ?></label>
	<input name="cdassessoria" type="text"  id="cdassessoria" class="campo"/>
	<a id="pesqassess" name="pesqassess" href="#" onClick="mostrarPesquisaAssessoria('#frmAssessoria,#divBotoes');return false;" ><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" width="14" height="14" border="0"></a>
	<br/>
	<label for="cdasscyb"><? echo utf8ToHtml("C&oacute;digo CYBER:") ?></label>
	<input name="cdasscyb" type="text"  id="cdasscyb" class="campo alphanum"/>
	<br />
	<label for="nmassessoria"><? echo utf8ToHtml("Nome da Assessoria:") ?></label>
	<input name="nmassessoria" type="text"  id="nmassessoria" class="campo alphanum"/>
	<br />
	<label for="flgjudic"><? echo utf8ToHtml("Judicial:") ?></label>
    <input name="flgjudic" type="checkbox"  id="flgjudic" class="inteiro"/>
    <br />
    <label for="flextjud"><? echo utf8ToHtml("Extra Judicial:")?></label>
    <input name="flextjud" type="checkbox"  id="flextjud" class="inteiro"/>
    <br>
	<label for="cdsigcyb"><? echo utf8ToHtml("Sigla no Cyber:")?></label>
    <input name="cdsigcyb" type="text"  id="cdsigcyb" class="campo alphanum"/>
    <br>
    <br style="clear:both" />
  
</form>
