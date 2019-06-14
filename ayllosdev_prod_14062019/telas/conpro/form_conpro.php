<?php
/* !
 * FONTE        : form_conpro.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 17/03/2016 
 * OBJETIVO     : Formulário de exibição da tela CONPRO
 * --------------
 * ALTERAÇÕES   : 05/07/2017 - P337 - Prever novas situações criadas pela
 *                             pela implantação da análise automática (Motor)
 * --------------
 */
?>
<form name="frmConpro" id="frmConpro" class="formulario" style="display:none">		

    <div id="divFiltros">
        <fieldset>

            <legend><?php echo utf8ToHtml('Filtros 1') ?></legend>

            <label class="tpproduto" for="tpproduto">
             <?php echo utf8ToHtml('Tipo produto:') ?>
            </label>
            <select class="tpproduto" id="tpproduto" name="tpproduto" onchange="alteraProduto(this.value);" >
                <option value="9"> <?php echo utf8ToHtml('Selecione') ?> </option>
                <option value="4" > <?php echo utf8ToHtml('Cartão')?> </option>
                <option value="0"> <?php echo utf8ToHtml('Empréstimo') ?> </option>
            </select>     

            <br style="clear:both" />	

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

            <label for="cdagenci"><?php echo utf8ToHtml('PA:') ?></label>
            <input name="cdagenci" id="cdagenci" type="text" />

            <br style="clear:both" />	

            <label for="dtinicio"><?php echo utf8ToHtml('Data Inicial:') ?></label>
            <input name="dtinicio" id="dtinicio" type="text" />

            <label for="dtafinal"><?php echo utf8ToHtml('Data Final:') ?></label>
            <input name="dtafinal" id="dtafinal" type="text" />

          

            <br style="clear:both" />	

            <label for="insitest"><?php echo utf8ToHtml('Situação:') ?></label>
            <div id="sitSelect">
            <select id="insitest" name="insitest">
            </select>
            </div>                
            <label for="insitefe"><?php echo utf8ToHtml('Efetivação:') ?></label>
            <select id="insitefe" name="insitefe">
                <option value="9"> <?php echo utf8ToHtml('Todos') ?></option> 
                <option value="0"> <?php echo utf8ToHtml('Não') ?></option> 
                <option value="1"> <?php echo utf8ToHtml('Sim') ?></option> 
            </select>


            <label for="insitapr"><?php echo utf8ToHtml('Parecer Esteira:') ?></label>
            <select id="insitapr" name="insitapr">
            </select>
        </fieldset>	
    </div>

    <div id="divResultado"> </div>
	 <div id="divResultado2"> </div>

</form>

<form class="formulario" id="frmImpressao" style="display: none">
</form> 

