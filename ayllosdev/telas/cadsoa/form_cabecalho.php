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
		
	<label for="tpServico" id= "servico"><b> Tipo de Servi&ccedil;o: </b></label>
	<input name="tpServico" id="tpObrigatorio" type="radio" class="radio" value="1" />	
	<label for="tpObrigatorio" class="radio"><b>Essencial<b></label>
	<input name="tpServico" id="tpOpcional" type="radio" class="radio" value="2" />	
	<label for="tpOpcional" class="radio"><b>Adicional<b></label>	
	<br>
	
	<label for="tpconta"><b>Tipo Conta:<b></label>
	<select name="tpconta" id="tpconta" class="campo" style="width: 73px;">
		<option value=""> Selecione o tipo</option> 
		<option value="1"> Conta PF</option> 
		<option value="2"> Conta Salário</option>
		<option value="3"> Conta Menor</option>
		<option value="4"> Conta Aplicação</option>
		<option value="5"> Conta PJ</option>
	</select>			
	<a href="#" id="btConsulta" class="botao">Consultar</a>
</form>	
