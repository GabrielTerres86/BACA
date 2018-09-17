<? 
/*!
 * FONTE        : form_opcao_c.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 14/02/2012 
 * OBJETIVO     : Formulario que apresenta a consulta da opcao C da tela COBRAN
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * [03/12/2014] Jean Reddiga  (RKAM)   : De acordo com a circula 3.656 do Banco Central,substituir nomenclaturas Cedente
 *	             			             por Beneficiário e  Sacado por Pagador  Chamado 229313 (Jean Reddiga - RKAM).
 *[16/11/2015] Jorge I. Hamaguchi      : Adicionado campo "Somente Crise". (Jorge/Andrino).
 */
 
?>

<?php
 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();
	
	include('form_cabecalho.php');
?>

<form id="frmOpcao" class="formulario" onSubmit="return false;">

	<fieldset>
		<legend> <? echo utf8ToHtml('Cobrança');  ?> </legend>	
		
		<label for="tpconsul">Consulta:</label>
		<select id="tpconsul" name="tpconsul" onchange="tipoOptionC();">
		<option value="1" <?php echo $tpconsul == '1' ? 'selected' : '' ?> ><? echo utf8ToHtml('1-Boletos Não Cobrados') ?></option>
		<option value="2" <?php echo $tpconsul == '2' ? 'selected' : '' ?> ><? echo utf8ToHtml('2-Boletos Cobrados') ?></option>
		<option value="3" <?php echo $tpconsul == '3' ? 'selected' : '' ?> ><? echo utf8ToHtml('3-Todos Boletos') ?></option>
		</select>

		<label for="flgregis">Cobran&ccedil;a Registrada:</label>
		<select id="flgregis" name="flgregis" onchange="tipoOptionC();">
		<option value="no"  <?php echo $flgregis == 'no' ? 'selected' : '' ?> > <? echo utf8ToHtml('Não') ?></option>
		<option value="yes" <?php echo $flgregis == 'yes' ? 'selected' : '' ?> ><? echo utf8ToHtml('Sim') ?></option>
		</select>
		<br style="clear:both" /> 
		<label for="consulta">Tipo:</label>
		<select id="consulta" name="consulta">
		<option value="1"<?php echo $consulta == '1' ? 'selected' : '' ?> >1-Numero da Conta</option>
		<option value="2"<?php echo $consulta == '2' ? 'selected' : '' ?> >2-Numero do Boleto</option>
		<option value="3"<?php echo $consulta == '3' ? 'selected' : '' ?> >3-Data Emissao</option>
		<option value="4"<?php echo $consulta == '4' ? 'selected' : '' ?> >4-Data Pagamento</option>
		<option value="5"<?php echo $consulta == '5' ? 'selected' : '' ?> >5-Data Vencimento</option>
		<option value="6"<?php echo $consulta == '6' ? 'selected' : '' ?> >6-Nome do Pagador</option>
		<option value="8"<?php echo $consulta == '8' ? 'selected' : '' ?> >8-Nro. Conta/Nro. Doc.</option>
		</select>
		
		<label for="inestcri">Somente Crise:</label>
		<select id="inestcri" name="inestcri" onchange="tipoOptionC();">
		<option value="0"  <?php echo $inestcri == '0' ? 'selected' : '' ?> > <? echo utf8ToHtml('Não') ?></option>
		<option value="1"  <?php echo $inestcri == '1' ? 'selected' : '' ?> > <? echo utf8ToHtml('Sim') ?></option>
		</select>
		
	</fieldset>		
	
	<fieldset>
		<legend> <? echo utf8ToHtml('Número da Conta');  ?> </legend>	
		
		<label for="nrdconta">Conta:</label>
		<input type="text" id="nrdconta" name="nrdconta" value="<?php echo formataContaDV($nrdconta) ?>"/>
		<a id="lupaConta" style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(1);return false;">
        <img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>

		<label for="nmprimtx">Titular:</label>
		<input type="text" id="nmprimtx" name="nmprimtx" value="<?php echo $nmprimtx ?>" />
		
	</fieldset>		

	<fieldset>
		<legend> <? echo utf8ToHtml('Número do Boleto');  ?> </legend>	
		
		<label for="ininrdoc">De:</label>
		<input type="text" id="ininrdoc" name="ininrdoc" value="<?php echo $ininrdoc ?>"/>

		<label for="fimnrdoc"><? echo utf8ToHtml('Até:');  ?></label>
		<input type="text" id="fimnrdoc" name="fimnrdoc" value="<?php echo $tpconsul == '3' ? $fimnrdoc : '' ?>" />
		
	</fieldset>		

	<fieldset>
		<legend> <? echo utf8ToHtml('Data de Emissão');  ?> </legend>	
		
		<label for="inidtmvt"><? echo utf8ToHtml('De');  ?>:</label>
		<input type="text" id="inidtmvt" name="inidtmvt" value="<?php echo $inidtmvt ?>"/>

		<label for="fimdtmvt"><? echo utf8ToHtml('Até:');  ?></label>
		<input type="text" id="fimdtmvt" name="fimdtmvt" value="<?php echo $fimdtmvt ?>" />
		
	</fieldset>		

	<fieldset>
		<legend> <? echo utf8ToHtml('Data de Pagamento');  ?> </legend>	
		
		<label for="inidtdpa"><? echo utf8ToHtml('De');  ?>:</label>
		<input type="text" id="inidtdpa" name="inidtdpa" value="<?php echo $inidtdpa ?>"/>

		<label for="fimdtdpa"><? echo utf8ToHtml('Até:');  ?></label>
		<input type="text" id="fimdtdpa" name="fimdtdpa" value="<?php echo $fimdtdpa ?>" />
		
	</fieldset>		

	<fieldset>
		<legend> <? echo utf8ToHtml('Data de Vencimento');  ?> </legend>	
		
		<label for="inidtven"><? echo utf8ToHtml('De');  ?>:</label>
		<input type="text" id="inidtven" name="inidtven" value="<?php echo $inidtven ?>"/>

		<label for="fimdtven"><? echo utf8ToHtml('Até:');  ?></label>
		<input type="text" id="fimdtven" name="fimdtven" value="<?php echo $fimdtven ?>" />
		
	</fieldset>		

	<fieldset>
		<legend> <? echo utf8ToHtml('Nome do Pagador');  ?> </legend>	
		
		<label for="nmprimtl"><? echo utf8ToHtml('Pagador');  ?>:</label>
		<input type="text" id="nmprimtl" name="nmprimtl" value="<?php echo $nmprimtl ?>"/>

	</fieldset>		
	
	<fieldset>
		<legend> <? echo utf8ToHtml('Número da Conta / Número do Documento');  ?> </legend>	
		
		<label for="nrdcontx">Conta:</label>
		<input type="text" id="nrdcontx" name="nrdcontx" value="<?php echo formataContaDV($nrdcontx) ?>"/>
		<a id="lupaConta" style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(2);return false;">
        <img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>

		<label for="nmprimtl">Titular:</label>
		<input type="text" id="nmprimtl" name="nmprimtl" value="<?php echo $nmprimtl ?>" />

		<label for="dsdoccop">Nr. Doc.:</label>
		<input type="text" id="dsdoccop" name="dsdoccop" value="<?php echo $dsdoccop ?>" />
		
	</fieldset>		

	
</form>


<div id="divBotoes" style="padding-bottom:10px">
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
	<a href="#" class="botao" onclick="btnContinuar(); return false;" ><? echo utf8ToHtml('Avançar'); ?></a>
</div>


