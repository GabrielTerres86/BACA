<div id="divFiltroGrid">
    <form id="frmFiltroGrid" name="frmFiltroGrid" class="formulario" style="display:block;">

    <br style="clear:both" />

     <div id="divFiltroGridCampos" style="height:20px;padding-left:265px">
        <label for="flgstatus"><? echo utf8ToHtml('Status:') ?></label>
        <select id="flgstatus" name="flgstatus" >
            <option value="1"> Ativo</option>
            <option value="0"> Inativo</option>
        </select>
    </div>

	<br style="clear:both" />	   
    <br style="clear:both" />

    <hr style="background-color:#666; height:1px;" />
	
	<div id="divBotoes" style="margin-bottom: 10px;">	
		<a href="#" class="botao" id="btVoltar" onClick="estadoInicial();">Voltar</a>	
		<a href="#" class="botao" id="btProsseguir" onClick="FiltroGridAlcadas.onClick_Prosseguir();">Prosseguir</a>	
	</div>        

    </form>
</div>
