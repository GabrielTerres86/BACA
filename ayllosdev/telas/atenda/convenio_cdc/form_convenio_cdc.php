<? 
/*!
 * FONTE        : form_convenio_cdc.php
 * CRIA��O      : Andre Santos (SUPERO)
 * DATA CRIA��O : Janeiro/2015
 * OBJETIVO     : Formul�rio da rotina Convenio CDC da tela de CONTAS 
 * --------------
 * ALTERA��ES   :
 * --------------
 */	
?>
<form name="frmConvenioCdc" id="frmConvenioCdc" class="formulario" >

    <label for="flgativo"><? echo utf8ToHtml(' Possui Conv&ecirc;nio CDC:') ?></label>
	<select id="flgativo" name="flgativo" onChange="mostraData();" >
        <option value="S" <? echo ($flgativo == 'yes' ? '' : 'selected') ?> >Sim</option>
		<option value="N" <? echo ($flgativo == 'yes' ? '' : 'selected') ?> >N�o</option>
	</select>
	
	<div id="divDataConvnio" style="display:none">
		<label for="dtcnvcdc"><? echo utf8ToHtml('Data Inicio Conv&ecirc;nio:') ?></label>
		<input name="dtcnvcdc" id="dtcnvcdc" type="text" value="<? echo $dtcnvcdc ; ?>" autocomplete="off" />
	</div>
</form>

<div id="divBotoes">	
	<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"   onClick="fechaRotina(divRotina)" />
	<input type="image" id="btAlterar" src="<? echo $UrlImagens; ?>botoes/alterar.gif"  onClick="manterRotina()" />
</div>