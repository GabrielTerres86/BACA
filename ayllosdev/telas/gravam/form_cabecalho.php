<?php  
	/*********************************************************************
	 Fonte: form_cabecalho.php                                                 
	 Autor: Andrei - RKAM                                                     
	 Data : Maio/2016                Última Alteração: 11/04/2017
	                                                                  
	 Objetivo  : Mostrar o form do cabecalho da GRAVAM.                                  
	                                                                  
	 Alterações: 11/04/2017 - Permitir acessar o Ayllos mesmo vindo do CRM. (Jaison/Andrino)
	
	**********************************************************************/
  
  session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');		
	isPostMethod();	
  
?>

<form name="frmCab" id="frmCab" class="formulario cabecalho" style= "display:none;">
	<input type="hidden" name="crm_inacesso" id="crm_inacesso" value="<?php echo $_SESSION["glbvars"][$glbvars["sidlogin"]]['CRM_INACESSO']; ?>" />
	<input type="hidden" name="crm_nrdconta" id="crm_nrdconta" value="<?php echo $_SESSION["glbvars"][$glbvars["sidlogin"]]['CRM_NRDCONTA']; ?>" />
		
	<label for="cddopcao"><? echo utf8ToHtml('Opcao:') ?></label>
	<select id="cddopcao" name="cddopcao">
    <option value="A"><? echo utf8ToHtml('A - Alterar') ?></option>
    <option value="B"><? echo utf8ToHtml('B - Baixar') ?></option>
    <option value="C"><? echo utf8ToHtml('C - Consultar') ?></option>
    <option value="G"><? echo utf8ToHtml('G - Gerar arquivo') ?></option>
		<option value="H"><? echo utf8ToHtml('H - Hist&oacute;rico') ?></option>
    <option value="I"><? echo utf8ToHtml('I - Imprimir') ?></option>
    <option value="J"><? echo utf8ToHtml('J - Bloqueio Judicial') ?></option>
    <option value="L"><? echo utf8ToHtml('L - Libera&ccedil;&atilde;o Judicial') ?></option>
    <option value="M"><? echo utf8ToHtml('M - Inclus&atilde;o manual do gravame') ?></option>
    <option value="R"><? echo utf8ToHtml('R - Retorno de arquivos') ?></option>
    <option value="S"><? echo utf8ToHtml('S - Alterar dados de bens substituidos via aditivo') ?></option>
    <option value="X"><? echo utf8ToHtml('X - Cancelamento manual ou automatico') ?></option>
  </select>
  
  <a href="#" class="botao" id="btnOK" name="btnOK" style = "text-align:right;">OK</a>

  <br style="clear:both" />
  
</form>	
