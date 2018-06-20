<?php
/* !
 * FONTE        : form_acionamento.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 22/03/2016 
 * OBJETIVO     : Formulário acionamento da tela CONPRO
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
?>
<form name="frmAciona" id="frmAciona" class="formulario" style="display:none">		

    <div id="divFiltrosAciona">
        <fieldset>

            <legend><?php echo utf8ToHtml('Filtros') ?></legend>

            <label class="tpproduto" for="tpproduto">
             <?php echo utf8ToHtml('Tipo produto:') ?>
            </label>
            <select class="tpproduto acionamentoTpproduto" id="tpproduto" name="tpproduto" onchange="alteraProduto(this.value);" >
                <option value="9"> <?php echo utf8ToHtml('Selecione') ?> </option>
                <option value="4" > <?php echo utf8ToHtml('Cartão')?> </option>
                <option value="0"> <?php echo utf8ToHtml('Empréstimo') ?> </option>
            </select>

            <label for="nrdconta"><?php echo utf8ToHtml('Conta/DV:') ?></label>
            <input name="nrdconta" id="nrdconta" type="text" />
            <a id="lupaConta" style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(1);
                    return false;">
                <img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif"/>
            </a>	

            <label for="nrctremp"><?php echo utf8ToHtml('Proposta/Contrato:') ?></label>
            <input name="nrctremp" id="nrctremp" type="text" />
            <a id="lupaContrato" style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(2);
                    return false;">
                <img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif"/>
            </a>	

            <label for="dtinicio"><?php echo utf8ToHtml('Data Inicial:') ?></label>
            <input name="dtinicio" id="dtinicio" type="text" />

            <label for="dtafinal"><?php echo utf8ToHtml('Data Final:') ?></label>
            <input name="dtafinal" id="dtafinal" type="text" />
			
               
            
		</fieldset>
	</div>

    <div id="divResultadoAciona"> </div>


</form>

