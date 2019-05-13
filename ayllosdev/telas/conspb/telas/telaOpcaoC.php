<!-- FORM OPCAO C -->
<div class="row">

    <div id="opcaoC" class="add10MarginTop divOpcoes">

        <!-- HORARIO -->
        <label for="horaConciliacao">Hor&aacute;rio: </label>
        <select name="mensagem" id="mensagem" class="campo">
            <option value="T">Todas</option>
            <option value="E">Enviadas</option>
            <option value="R">Recebidas</option>
        </select>

        <!-- PERIODO -->
        <!-- DE -->
        <label for="horaConciliacao">Periodo: </label>
        <input type="text" name="periodoDe" id="periodoDe" class="campo data" value='' />
        <!-- ATE -->
        <span> 	&agrave; </span>
        <input type="text" name="periodoAte" id="periodoAte" class="campo data" value='' />

        <br>

        <div class="mensagemOpcaoC">
            Antes da execu&ccedil;&atilde;o da Concilia&ccedil;&atilde;o Contingencial deve ser acionada
            a &aacute;rea de BI, para que a mesma execute a rotina INTEGRA_JDSPB, na ferramenta ODI.
        </div>

    </div>

</div> <!-- FIM FORM OPCAO C -->