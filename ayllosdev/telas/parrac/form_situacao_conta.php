<? 
/*!
 * FONTE        : form_situacao_conta.php
 * CRIAÇÃO      : Jonata Cardoso - (RKAM)
 * DATA CRIAÇÃO : 04/02/2015
 * OBJETIVO     : Tela para selecionar as situacoes da conta
 * --------------
 * ALTERAÇÕES   : 
 */
 
?>

<?php
 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	
	
	$nr_operacao =  substr($operacao,10,1) + 1;
?>

<form id="frmSituacaoConta" name="frmSituacaoConta" class="formulario" onSubmit="return false;">

	<fieldset>
		<legend><? echo utf8ToHtml('Situaç&atilde;o Conta'); ?></legend>

		<br />
		<input type="checkbox" name="cdsitcta" id="Normal"                     value="1" <? echo (in_array("1",explode(";",$dssitcta))) ? "checked" : "" ?> > <label> 1 - Normal                     </label><br>
		<br />
		<input type="checkbox" name="cdsitcta" id="Enc. p/assoc."              value="2" <? echo (in_array("2",explode(";",$dssitcta))) ? "checked" : "" ?> > <label> 2 - Enc. p/assoc.              </label><br>
		<br />
		<input type="checkbox" name="cdsitcta" id="Enc. p/coop"                value="3" <? echo (in_array("3",explode(";",$dssitcta))) ? "checked" : "" ?> > <label> 3 - Enc. p/coop    	         </label><br>
		<br />
		<input type="checkbox" name="cdsitcta" id="Enc. p/demissao"            value="4" <? echo (in_array("4",explode(";",$dssitcta))) ? "checked" : "" ?> > <label> 4 - Enc. p/demissao            </label><br>
		<br />
		<input type="checkbox" name="cdsitcta" id="Nao aprovada"               value="5" <? echo (in_array("5",explode(";",$dssitcta))) ? "checked" : "" ?> > <label> 5 - Nao aprovada               </label><br>
		<br />
		<input type="checkbox" name="cdsitcta" id="Normal - Sem talao"         value="6" <? echo (in_array("6",explode(";",$dssitcta))) ? "checked" : "" ?> > <label> 6 - Normal - Sem talao  	     </label><br>
		<br />
		<input type="checkbox" name="cdsitcta" id="Outros motivos"             value="8" <? echo (in_array("8",explode(";",$dssitcta))) ? "checked" : "" ?> > <label> 8 - Outros motivos             </label><br>
		<br />
		<input type="checkbox" name="cdsitcta" id="Encerrada p/ outro motivo"  value="9" <? echo (in_array("9",explode(";",$dssitcta))) ? "checked" : "" ?> > <label> 9 - Encerrada p/ outro motivo  </label><br>
		<br />
	
	</fieldset>	

</form>

<div id="divBotoes" style="margin-bottom:8px">
    <a href="#" class="botao" id="btVoltar" onclick="fechaOpcao(); return false;">Voltar</a>  
	<? if ($cddopcao != 'C') { ?>		
		<a href="#" class="botao" id="btSalvar" onclick="atualizaSituacaoConta(); fechaOpcao(); return false;">Continuar</a>  
	<? } ?>
</div>

<script> 

	<? if ($cddopcao == 'C') { ?>		
		$("input","#frmSituacaoConta").desabilitaCampo();
	<? } ?>
	
	$(document).ready(function(){
		formataSituacaoConta();
	});

</script>