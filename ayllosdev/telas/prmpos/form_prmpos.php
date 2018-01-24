<?php
/*!
 * FONTE        : form_prmpos.php
 * CRIA��O      : Jaison
 * DATA CRIA��O : 24/03/2017
 * OBJETIVO     : Formulario do cadastro.
 * --------------
 * ALTERA��ES   : 
 * --------------
 */
?>
<form id="frmPrmpos" name="frmPrmpos" class="formulario">
<fieldset>
    <fieldset style="margin-top: 15px; padding: 10 0 10 0;">
        <legend>Valor Emprestado</legend>
        <label for="vlminimo_emprestado">Valor M�nimo:</label>
        <input type="text" id="vlminimo_emprestado" name="vlminimo_emprestado" />
        <label for="vlmaximo_emprestado">Valor M�ximo:</label>
        <input type="text" id="vlmaximo_emprestado" name="vlmaximo_emprestado" />
    </fieldset>

    <fieldset style="margin-top: 15px; padding: 10 0 10 0;">
        <legend>Quantidade de Parcelas</legend>
        <label for="qtdminima_parcela">Quantidade M�nima:</label>
        <input type="text" id="qtdminima_parcela" name="qtdminima_parcela" />
        <label for="qtdmaxima_parcela">Quantidade M�xima:</label>
        <input type="text" id="qtdmaxima_parcela" name="qtdmaxima_parcela" />
    </fieldset>

    <fieldset style="margin-top: 15px; padding: 10 0 10 0;">
        <legend>Periodicidade de Atualiza��o do Indexador</legend>
        <div id="htmFieldIndex">
            <label for="tpatualizacao_1" style="width: 140px;">CDI:</label>
            <select class="clsList clsInput" name="tpatualizacao_1" id="tpatualizacao_1">
                <option value="1">Diario</option>
                <option value="2">Quinzenal</option>
                <option value="3">Mensal</option>
            </select>
            <label for="tpatualizacao_2" style="width: 153px;">TR:</label>
            <select class="clsList clsInput" name="tpatualizacao_2" id="tpatualizacao_2">
                <option value="1">Diario</option>
                <option value="2">Quinzenal</option>
                <option value="3">Mensal</option>
            </select>
        </div>
    </fieldset>

    <fieldset style="margin-top: 15px; padding: 10 0 10 0;">
        <legend>Periodicidade de Car�ncia</legend>
        <div align="center">
            <table width="530" cellspacing="1">
            <thead class="tituloRegistros" style="background-color: #f7d3ce;">
                <tr>
                    <th width="10%" style="padding:5px;">&nbsp;</th>
                    <th width="60%" style="padding:5px;">Car�ncia</th>
                    <th width="30%" style="padding:5px;">Quantidade Dias</th>
                </tr>
            </thead>
            <tbody id="htmBodyCarencia"></tbody>
            </table>
        </div>
    </fieldset>
</fieldset>
</form>