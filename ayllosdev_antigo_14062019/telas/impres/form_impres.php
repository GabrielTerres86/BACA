<?php
 /*!
 * FONTE        : form_impres.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 31/08/2011
 * OBJETIVO     : Formulário de exibição da IMPRES
 * --------------
 * ALTERAÇÕES   :
 * 10/09/2012 - Guilherme    (SUPERO) : Demonstrativo Aplicações: Alteração de layout e novos campos
 * 29/11/2012 - Daniel       (CECRED) : Alterado botões do tipo tag <input> para tag <a> novo layout.
 * 31/05/2013 - Daniel       (CECRED) : Retirado campo flgtarif.
 * 08/08/2016 - Guilherme    (SUPERO) : M325 - Informe de Rendimentos Trimestral PJ
 * 28/08/2018 - Cassia       (GFT)    : Adicionado campos para extrato de Desconto de Títulos
 * --------------
 */
?>
<form name="frmImpres" id="frmImpres" class="formulario" onSubmit="return false;" style="display:none" >

	<fieldset>

		<legend>Dados do Extrato</legend>
<div id='divTodos0'>
		<label for="tpmodelo"><? echo utf8ToHtml('Modelo:') ?></label>
		<select name="tpmodelo" id="tpmodelo">
            <option value="1">Demonstrativo</option>
            <option value="2"><? echo utf8ToHtml('Extrato Analítico') ?></option>
            <option value="3"><? echo utf8ToHtml('Extrato Sintético') ?></option>
		</select>
        <br />
</div>
		<label for="dtrefere"><? echo utf8ToHtml('Dt. Inic.:') ?></label>
		<input name="dtrefere" id="dtrefere" type="text" value="<? echo $dtrefere ?>" value="" />

		<label for="dtreffim"><? echo utf8ToHtml('Dt. Final:') ?></label>
		<input name="dtreffim" id="dtreffim" type="text" value="<? echo $dtreffim ?>" value="" />

		<label for="inselext"><? echo utf8ToHtml('Sel:') ?></label>
		<select name="inselext" id="inselext">
		<option value="0"></option>
		<option value="1">1-Especifico</option>
		<option value="2">2-Todos</option>
		</select>
		<br />
<div id='divTodos1'>
		<label for="inrelext"><? echo utf8ToHtml('Lista:') ?></label>
		<select name="inrelext" id="inrelext">
		<option value="1">1-Somente Extrato</option>
		<option value="2">2-Cheques</option>
		<option value="3">3-Dep Identificados</option>
		<option value="4">4-Todos</option>
		</select>
		<label for="nrctremp"><? echo utf8ToHtml('Contrato:') ?></label>
		<input name="nrctremp" id="nrctremp" type="text" value="<? echo $nrctremp ?>" value="" />
		<a style="margin-top:5px"><img id="lnrctremp" src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
<!--
		<label for="flgtarif"><? /*echo utf8ToHtml('Tarifar?:') */?></label>
		<select name="flgtarif" id="flgtarif">
		<option value="no">Nao</option>
        <option value="yes">Sim</option>
		</select>
		-->
		<br style="clear:both" />

        <div id="divTipo6" >
		<label for="tpinform"><? echo utf8ToHtml('Informe:') ?></label>
		<select name="tpinform" id="tpinform">
		    <option value=0 selected>Anual</option>
		    <option value=1>Trimestral</option>
		</select>
		</div>
        <div id="divPeriodo" >
		<label for="nrperiod"><? echo utf8ToHtml('Trimestre:') ?></label>
		<select name="nrperiod" id="nrperiod">
		    <option value=1 selected>Jan-Mar</option>
		    <option value=2>Abr-Jun</option>
		    <option value=3>Jul-Set</option>
		    <option value=4>Out-Dez</option>
		</select>
        </div>
</div>
		<label for="nraplica"><? echo utf8ToHtml('Aplicac.:') ?></label>
		<input name="nraplica" id="nraplica" type="text" value="<? echo $nraplica ?>" value="" />
		<a style="margin-top:5px"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>

    <div id='divTodos2'>
		<label for="nranoref"><? echo utf8ToHtml('Ano:') ?></label>
		<input name="nranoref" id="nranoref" type="text" value="<? echo $nranoref ?>" value="" />
    </div>
<div id="divGeral" style="float:left">
		<label for="flgemiss"><? echo utf8ToHtml('Quando?:') ?></label>
		<select name="flgemiss" id="flgemiss">
		<option value="yes">Agora</option>
		<option value="no">Processo</option>
		</select>

</div>
	</fieldset>

</form>
<script type="text/javascript">

//Habilitar e Desabilitar campos de Periodo
var src = $("#tpmodelo","#frmImpres").val();

$("#tpmodelo","#frmImpres").change(function() {
    var src   = $(this).val();

    if (src == '1') {
        var dtArray = dtmvtolt.split('/');
        var dtdozemes = (dtArray[0] + 1) + "/" + dtArray[1] + "/" + (dtArray[2] - 1);

        cDtrefere.habilitaCampo();
        cDtreffim.habilitaCampo();
        cDtreffim.val(dtmvtolt);
        cDtrefere.val(dtdozemes);
    }
    else {
        cDtrefere.val('');
        cDtreffim.val('');
        cDtrefere.desabilitaCampo();
        cDtreffim.desabilitaCampo();
    }

});

$("#tpinform","#frmImpres").change(function() {
    var src   = $(this).val();

    if (src == 0) { // ANUAL
        $('#divPeriodo').hide();
    }else { // TRIMESTRAL
        $('#divPeriodo').show();
    }
});

</script>
<form name="frmImprimir" id="frmImprimir">
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">

	<input name="nrdconta" id="nrdconta" type="hidden" value="" />
	<input name="idseqttl" id="idseqttl" type="hidden" value="" />
	<input name="tpextrat" id="tpextrat" type="hidden" value="" />
	<input name="dtrefere" id="dtrefere" type="hidden" value="" />
	<input name="dtreffim" id="dtreffim" type="hidden" value="" />
	<input name="flgtarif" id="flgtarif" type="hidden" value="" />
	<input name="inrelext" id="inrelext" type="hidden" value="" />
	<input name="inselext" id="inselext" type="hidden" value="" />
    <input name="tpmodelo" id="tpmodelo" type="hidden" value="" />
	<input name="nrctremp" id="nrctremp" type="hidden" value="" />
	<input name="nraplica" id="nraplica" type="hidden" value="" />
	<input name="nranoref" id="nranoref" type="hidden" value="" />
	<input name="nrperiod" id="nrperiod" type="hidden" value="" />
	<input name="tpinform" id="tpinform" type="hidden" value="" />
	<input name="idimpres" id="idimpres" type="hidden" value="" />
	<input name="flgemail" id="flgemail" type="hidden" value="" />
	<input name="nrctrlim" id="nrctrlim" type="hidden" value="" />
	<input name="nrborder" id="nrborder" type="hidden" value="" />
	<input name="limorbor" id="limorbor" type="hidden" value="" />
</form>

