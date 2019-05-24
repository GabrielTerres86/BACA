<!-- FORM OPCAO C -->
<div class="row">

    <fieldset id="opcaoC" class="add10MarginTop divOpcoes">
        <legend align="left">Filtro</legend>

        <!-- HORARIO -->
        <label for="horaConciliacao">Mensagem: </label>
        <select name="mensagem" id="mensagem" class="campo">
            <option value="T">Todas</option>
            <option value="E">Enviadas</option>
            <option value="R">Recebidas</option>
        </select>

        <!-- PERIODO -->
        <!-- DE -->
        <label for="horaConciliacao">Per&iacute;odo: </label>
        <input type="text" name="periodoDe" id="periodoDe" class="campo data" value='' />
        <!-- ATE -->
        <span> 	&agrave; </span>
        <input type="text" name="periodoAte" id="periodoAte" class="campo data" value='' />

        <br>

        <div class="mensagemOpcaoC">
            Antes da execu&ccedil;&atilde;o da Concilia&ccedil;&atilde;o Contingencial deve ser acionada
            a &aacute;rea de BI, para que a mesma execute a rotina INTEGRA_JDSPB, na ferramenta ODI.
        </div>

    </fieldset>

</div> <!-- FIM FORM OPCAO C -->