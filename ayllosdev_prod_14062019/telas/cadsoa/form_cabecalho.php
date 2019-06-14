<?php  
	/*********************************************************************
	 Fonte: form_cabecalho.php                                                 
	 Autor: Tiago Castro - RKAM                                                     
	 Data : Jul/2015                Última Alteração: 
	                                                                  
	 Objetivo  : Mostrar o form do cabecalho da CADSOA.                                  
	                                                                  
	 Alterações: 
	 
	 <a href="#" class="botao" id="btnOK" name="btnOK" onclick="define_operacao(); return false;">OK</a>
	
	**********************************************************************/
?>

<form name="frmCabCadsoa" id="frmCabCadsoa" class="formulario cabecalho" style= "height: 50px">
		
	<label for="inpessoa" id= "servico"> Tipo de Pessoa: </label>
	
	<input name="inpessoa" id="inpessoa_1" type="radio" class="radio" value="1" />	
	<label for="inpessoa_1" class="radio">F&iacute;sica</label>
	
	<input name="inpessoa" id="inpessoa_2" type="radio" class="radio" value="2" />	
	<label for="inpessoa_2" class="radio">Jur&iacute;dica</label>	
	
	<input name="inpessoa" id="inpessoa_3" type="radio" class="radio" value="3" <? echo (validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'P',false) <> '') ? 'style="display: none;"' : '';?> />	
	<label for="inpessoa_3" class="radio" <? echo (validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'P',false) <> '') ? 'style="display: none;"' : '';?> >Jur&iacute;dica – Cooperativa</label>	
	
	<label for="tpconta">Tipo de Conta:</label>
	<select name="tpconta" id="tpconta" class="campo" style="width: 73px;">
		<option value=""> Selecione o tipo</option> 
	</select>			
	<a href="#" id="btConsulta" class="botao">Consultar</a>
</form>	
