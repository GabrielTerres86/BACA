<?
/*!
 * FONTE        	: form_paridr.php
 * CRIAÇÃO      	: Lucas Reinert
 * DATA CRIAÇÃO 	: Março/2016
 * OBJETIVO     	: Form da tela PARIDR
 * ÚLTIMA ALTERAÇÃO : --/--/----
 * --------------
 * ALTERAÇÕES   	: 
 * --------------
 */ 
?>
<div id="divIndicador">
    <form name="frmIndicador" id="frmIndicador" class="formulario">
            
		<label for="idindicador">Indicador:</label>
		<input name="idindicador" class="campo" id="idindicador" type="text" value=""/>
		<a style="margin-top:5px" href="#" onClick="mostrarPesquisaIndicadores();return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
		<input name="nmindicador" class="campo" id="nmindicador" type="text" value="" disabled />
		<label for="tpindicador">Tipo:</label>		
		<select name="tpindicador" id="tpindicador" class="campo" disabled>
			<option value="Q">Quantidade</option>
			<option value="M">Moeda</option>
			<option value="A">Ades&atilde;o</option>
		</select>			
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
		<label for="vlminimo">Valor M&iacute;nimo:</label>
		<input name="vlminimo" class="campo" id="vlminimo" type="text" value="" style="text-align: right"/>
		<label for="vlmaximo">Valor M&aacute;ximo:</label>
		<input name="vlmaximo" class="campo" id="vlmaximo" type="text" value="" style="text-align: right"/>
		<label for="perpeso">% Peso:</label>
		<input name="perpeso" class="campo" id="perpeso" type="text" value="" style="text-align: right"/>
		</br>
		<label for="perscore">% Score:</label>
		<input name="perscore" class="campo" id="perscore" type="text" value="" style="text-align: right"/>
		<label for="pertolera">% Toler&acirc;ncia:</label>
		<input name="pertolera" class="campo" id="pertolera" type="text" value="" style="text-align: right"/>
		<label for="perdesc">% Desconto:</label>
		<input name="perdesc" class="campo" id="perdesc" type="text" value="" style="text-align: right"/>
    </form>
</div>
<script type="text/javascript">
    $( function() {
        highlightObjFocus($('#frmIndicador'));
    });
</script>    
