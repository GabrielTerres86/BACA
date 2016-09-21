<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 28/07/2011
 * OBJETIVO     : Cabeçalho para a tela CMAPRV
 * --------------
 * ALTERAÇÕES   : 
 * 001: 11/07/2012 - Jorge  (CECRED) : Retirado campo "redirect" popup. (Jorge)
 * 002: 18/01/2013 - Daniel (CECRED) : Implantacao novo layout.
 * 003: 13/08/2013 - Carlos (CECRED) : Alteração da sigla PAC para PA.
 * --------------
 */
?>
<form id="frmCab" name="frmCab" class="formulario cabecalho" >

	<input name="confcmpl" id="confcmpl" type="hidden" value=""  />	
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">

	<label for="cddopcao"><? echo utf8ToHtml('Opção:') ?></label>	
	<select id="cddopcao" name="cddopcao">
	<option value="C" <?php echo $cddopcao == 'C' ? 'selected' : '' ?> >C - Consultar situacao do emprestimo.</option>
	<option value="A" <?php echo $cddopcao == 'A' ? 'selected' : '' ?> >A - Alterar situacao do emprestimo.</option>
	<option value="R" <?php echo $cddopcao == 'R' ? 'selected' : '' ?> >R - Imprimir dados do emprestimo.</option>
	</select>
	<a href="#" class="botao" id="btnOK" onClick="botaoOK();">OK</a>
		
	<label for="cdagenci"><? echo utf8ToHtml('PA:') ?></label>
	<input name="cdagenci" id="cdagenci" type="text" value="<?php echo $cdagenc1 ?>"  />

	<label for="nrdconta">Conta:</label>
	<input type="text" id="nrdconta" name="nrdconta"  value="<?php echo formataContaDV($nrdconta) ?>"  autocomplete="off"  />
	<a href="#" style="margin-top:5px" onClick="buscaAssociado();"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
	
	<label for="dtpropos"><? echo utf8ToHtml('Proposta a Partir de:') ?></label>
	<input name="dtpropos" id="dtpropos" type="text" value="<?php echo $dtpropos ?>" />
	
	<br />
	
	<label for="dtaprova"><? echo utf8ToHtml('Dt.Aprov:') ?></label>
	<input name="dtaprova" id="dtaprova" type="text" value="<?php echo $dtaprova ?>" />
	<label for="dtaprfim"><? echo utf8ToHtml('até:') ?></label>
	<input name="dtaprfim" id="dtaprfim" type="text" value="<?php echo $dtaprfim ?>" />


	<label for="aprovad1"><? echo utf8ToHtml('Situação:') ?></label>
	<select name="aprovad1" id="aprovad1">
	<option value="0" <?php echo $aprovad1 == '0' ? 'selected' : '' ?> >0-Nao Analisado</option>
	<option value="1" <?php echo $aprovad1 == '1' ? 'selected' : '' ?> >1-Aprovado</option>
	<option value="2" <?php echo $aprovad1 == '2' ? 'selected' : '' ?> >2-Nao Aprovado</option>
	<option value="3" <?php echo $aprovad1 == '3' ? 'selected' : '' ?> >3-Com Restricao</option>
	<option value="4" <?php echo $aprovad1 == '4' ? 'selected' : '' ?> >4-Refazer</option>
	</select>

	<label for="aprovad2"><? echo utf8ToHtml('até:') ?></label>
	<select name="aprovad2" id="aprovad2">
	<option value="0" <?php echo $aprovad2 == '0' ? 'selected' : '' ?> >0-Nao Analisado</option>
	<option value="1" <?php echo $aprovad2 == '1' ? 'selected' : '' ?> >1-Aprovado</option>
	<option value="2" <?php echo $aprovad2 == '2' ? 'selected' : '' ?> >2-Nao Aprovado</option>
	<option value="3" <?php echo $aprovad2 == '3' ? 'selected' : '' ?> >3-Com Restricao</option>
	<option value="4" <?php echo $aprovad2 == '4' ? 'selected' : '' ?> >4-Refazer</option>
	</select>

	<label for="cdopeapv"><? echo utf8ToHtml('Operador:') ?></label>
	<input name="cdopeapv" id="cdopeapv" type="text" value="<?php echo $cdopeapv ?>" />
	
	<br style="clear:both" />	
	
</form> 