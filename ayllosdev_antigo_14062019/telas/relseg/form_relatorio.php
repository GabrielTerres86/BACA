<?php
/*!
 * FONTE        : form_relatorio.php
 * CRIAÇÃO      : David Kruger
 * DATA CRIAÇÃO : 22/01/2013
 * OBJETIVO     : Formulario de relatorios da tela RELSEG.
 * --------------
 * ALTERAÇÕES   : 25/07/2013 - Inclusão do campo hidden cddopcao. (Carlos)
                  15/08/2013 - Alteração da sigla PAC para PA (Carlos)
				  18/02/2014 - Exportação em .txt para Tp.Relat 5 (Lucas)
                  12/05/2016 - PRJ187.2 - Adicionada opção 6 - Seguro Sicredi (Guilherme/SUPERO)

 */
?>
<form id="frmRel" name="frmRel" class="formulario">
    <fieldset id="frmContRel" style="clear: both; border: 1px solid rgb(119, 119, 119); margin: 3px 0px; padding: 10px 3px 5px;">
	<legend><? echo utf8ToHtml('Relat&#243;rios') ?></legend>
		<div id="divRel">
			<label for="tprelato"><? echo utf8ToHtml('Op&ccedil;&atilde;o:') ?></label>
			<select id="tprelato" name="tprelato" style="width: 477px;">
				<option value="1"> 1 - Seguro auto por PA </option>
				<option value="2"> 2 - Seguro vida por PA </option>
				<option value="3"> 3 - Seguro residencial por PA</option>
				<option value="4"> 4 - Gerencial - consolidado seguros auto, vida e residencial </option>
				<option value="5"> 5 - Motivos de cancelamento Seguro Residencial  </option>
<?php if ($rel_sicredi == '') { ?>
                <option value="6"> 6 - Seguro Auto Sicredi </option>
<?php } ?>
				<option value="7"> 7 - Motivos de cancelamento Seguro de Vida Individual  </option>
			</select>
		</div>
		</br>
        <div id="divParam">
		<label for="telcdage">PA:</label>
		<input type="text" id="telcdage" name="telcdage" value="<? echo $telcdage == 0 ? '' : $telcdage ?>" alt="Informe o PA."/>
		<label for="dtiniper">De:</label>
		<input type="text" id="dtiniper" name="dtiniper" value="<? echo $dtiniper == 0 ? '' : $dtiniper ?>" alt="Informe a data inicial."/>
		<label for="dtfimper">a:</label>
		<input type="text" id="dtfimper" name="dtfimper" value="<? echo $dtfimper == 0 ? '' : $dtfimper ?>" alt="Informe a data final."/>
		<input type="hidden" id="cddopcao" name="cddopcao" value="" />
		<div id="divExpRel" style = 'display:none'>
			<label for="inexprel"><? echo utf8ToHtml('Exp.:') ?></label>
			<select id="inexprel" name="inexprel" style="width: 65px;">
				<option value="1"> PDF </option>
				<option value="2"> TXT </option>
			</select>
		</div>
        </div>
        <div id="divOp6">
            </br>
            <label for="tpseguro">Tipo:</label>
            <select id="tpseguro" name="tpseguro" style="width: 65px;">
                <option value="1"> Proposta </option>
                <option value="2" selected> Ap&oacute;lice </option>
                <option value="3"> Endosso </option>
            </select>
            <label for="tpstaseg">Status:</label>
            <select id="tpstaseg" name="tpstaseg" style="width: 65px;">
                <option value="A" selected> Ativo </option>
                <option value="V" > Vencido </option>
                <option value="C"> Cancelado </option>
            </select>
        </div>
	</fieldset>

	<br style="clear:both" />
	</br>
</form>
