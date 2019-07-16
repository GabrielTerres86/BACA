<? 
	/*!
	 * FONTE        : form_seguro_casa_sigas.php
	 * CRIAÇÃO      : Darlei Fernando Zillmer (Supero)
	 * DATA CRIAÇÃO : 01/07/2019
	 * OBJETIVO     : Exibição dos detalhes dos seguros SIGAS
	 * --------------
	 * ALTERAÇÕES   : 
	 *
	 * --------------
	 */
?>
<form name="frmSeguroCasaSigas" id="frmSeguroCasaSigas" class="formulario condensado">
	
    <div id="part_2">
        <!-- Linha 1 -->
        <fieldset style="padding: 5px">
            <legend>Segurado</legend>
            <label for="segurado">Segurado:</label>
            <input name="segurado" id="segurado" type="text" alt=""/>
        </fieldset>
		<fieldset style="padding: 5px">
            <!-- Linha 2 -->
            <legend>Dados do Seguro</legend>
            <!-- Linha 3 -->
            <label for="dstipseg">Tipo do Seguro:</label>
            <input name="dstipseg" id="dstipseg" type="text" alt="" value="" />
            <label for="nmressegSIGAS">Seguradora:</label>
            <input name="nmressegSIGAS" id="nmressegSIGAS" type="text" alt="" value=""/>
            <!-- Linha 4 -->
            <label for="dtinivig">Início Vigência:</label>
            <input name="dtinivig" id="dtinivig" type="text" alt="" value="" />
            <label for="dtfimvig">Final Vigência:</label>
            <input name="dtfimvig" id="dtfimvig" type="text" alt="" value="" />
            <!-- Linha 5 -->
            <label for="nrpropostaSIGAS">Proposta nº:</label>
            <input name="nrpropostaSIGAS" id="nrpropostaSIGAS" type="text" alt="" value="" />
            <label for="nrapoliceSIGAS">Apólice nº:</label>
            <input name="nrapoliceSIGAS" id="nrapoliceSIGAS" type="text" alt="" value="" />
            <label for="nrendossoSIGAS">Endosso nº:</label>
            <input name="nrendossoSIGAS" id="nrendossoSIGAS" type="text" alt="" value="" />
            <!-- Linha 6 -->
            <label for="dsplanoSIGAS">Plano:</label>
            <input name="dsplanoSIGAS" id="dsplanoSIGAS" type="text" alt="" value="" />
            <label for="dsmoradiaSIGAS">Tp Moradia:</label>
            <input name="dsmoradiaSIGAS" id="dsmoradiaSIGAS" type="text" alt="" value="" />
        </fieldset>
    </div>
	<div id="part_3">
		<fieldset style="padding: 5px">
            <!-- Linha 7 -->
            <legend>Local do Risco</legend>
            <!-- Linha 8 -->
            <label for="dsendres">Rua:</label>
            <input name="dsendres" id="dsendres" type="text" alt=""/>
            <label for="nrendere">Nº:</label>
            <input name="nrendere" id="nrendere" type="text" alt=""/>
            <!-- Linha 9 -->
            <label for="complend">Compl.:</label>
            <input name="complend" id="complend" type="text" alt=""/>		
            <!-- Linha 10 -->
            <label for="nmbairro">Bairro:</label> 
            <input name="nmbairro" id="nmbairro" type="text" alt=""/>		
            <label for="nmcidade">Cidade:</label>
            <input name="nmcidade" id="nmcidade" type="text" alt=""/>
            <label for="cdufresd">U.F.:</label>
            <input name="cdufresd" id="cdufresd" type="text" alt=""/>
        </fieldset>
	</div>
    
    <div id="part_4">
        <fieldset style="padding: 5px">
            <!-- Linha 11 -->
            <legend>Dados Complementares</legend>
            <!-- Linha 12 -->
            <label for="nrpreliq">Prêmio Liquido:</label>
            <input name="nrpreliq" id="nrpreliq" type="text" alt=""/>
            <label for="nrpretot">Prêmio Total:</label>
            <input name="nrpretot" id="nrpretot" type="text" alt=""/>
            <!-- Linha 13 -->
            <label for="nrqtparce">Qtd Parcelas:</label>
            <input name="nrqtparce" id="nrqtparce" type="text" alt=""/>		
            <label for="nrvalparc">Valor da Parcela:</label> 
            <input name="nrvalparc" id="nrvalparc" type="text" alt=""/>		
            <!-- Linha 14 -->
            <label for="nrmdiaven">Melhor Venc.:</label>
            <input name="nrmdiaven" id="nrmdiaven" type="text" alt=""/>
            <label for="nrpercomi">Perc. Comissão:</label>
            <input name="nrpercomi" id="nrpercomi" type="text" alt=""/>
            <input name="cdidsegp" id="cdidsegp" type="hidden" alt=""/>
        </fieldset>
	</div>
</form>
<div id="divBotoes">
    <a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
    <a href="#" class="botao" onclick="cancelarSeguroSigas(); return false;" ><? echo utf8ToHtml('Alterar status para cancelado'); ?></a>
</div>
<script type="text/javascript">
	hideMsgAguardo();
	
	$(document).ready(function(){
		highlightObjFocus($('#frmSeguroCasaSigas'));
	});
</script>