<?
/*!
 * FONTE        	: form_vinculacao.php
 * CRIAÇÃO      	: André Clemer - Supero
 * DATA CRIAÇÃO 	: Agosto/2018
 * OBJETIVO     	: Form da tela de vinculação da PARIDR
 * ÚLTIMA ALTERAÇÃO : --/--/----
 * --------------
 * ALTERAÇÕES   	: 
 * --------------
 */ 
?>
<div id="divVinculacao">
    <form name="frmVinculacao" id="frmVinculacao" class="formulario">
		<label for="idvinculacao">Vincula&ccedil&atilde;o:</label>
		<input name="idvinculacao" class="campo" id="idvinculacao" type="text" value=""/>
		<a style="margin-top:5px" href="#" onClick="mostrarPesquisaVinculacoes();return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
		<input name="nmvinculacao" class="campo" id="nmvinculacao" type="text" value="" disabled />
		</br>
		<label for="cdproduto">Produto:</label>
		<input name="cdproduto" class="campo" id="cdproduto" type="text" value=""/>
		<a style="margin-top:5px" href="#" onClick="mostrarPesquisaProdutos();return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
		<input name="dsproduto" class="campo" id="dsproduto" type="text" value="" disabled />
		<label for="inpessoa">Tipo Pessoa:</label>
		<select name="inpessoa" id="inpessoa" class="campo" >
			<option value="1">F&iacute;sica</option>
			<option value="2">Jur&iacute;dica</option>			
		</select>
		</br>
		<label for="perpeso">% Peso:</label>
		<input name="perpeso" class="campo" id="perpeso" type="text" value="" style="text-align: right"/>
		</br>
		<label for="perdesc">% Desconto:</label>
		<input name="perdesc" class="campo" id="perdesc" type="text" value="" style="text-align: right"/>
    </form>
</div>
<script type="text/javascript">
    $( function() {
        highlightObjFocus($('#frmVinculacao'));
    });
</script>