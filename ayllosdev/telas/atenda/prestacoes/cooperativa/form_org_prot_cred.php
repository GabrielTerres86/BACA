<? 
/*!
 * FONTE        : form_org_prot_cred.php
 * CRIAÇÃO      : André Socoloski - DB1
 * DATA CRIAÇÃO : 30/03/2011 
 * OBJETIVO     : Formulário da rotina Prestações da tela ATENDA
 * ALTERACAO    : 
 *
 * 001 [08/04/2014] Alterado fluxo de botao voltar e continuar. (Jorge)
 * 002 [28/11/2014] Retirar consula do 2.do titular (Jonata-RKAM)
 * 003 [01/12/2014] Incluir telas das consultas automatizadas (Jonata-RKAM)
 * 004 [21/11/2018] Alterado layout da tela Garantias, que agora se chama Rating - PRJ 438 (Mateus Z / Mouts)
 */	
 ?>

<form name="frmOrgProtCred" id="frmOrgProtCred" class="formulario">	

	<input id="nrctremp" name="nrctremp" type="hidden" value="" />
	
	<fieldset style="display: none;">
		<legend><? echo utf8ToHtml('Orgãos de Proteção ao Crédito') ?></legend>
	
		<label for="dtcnsspc"><? echo utf8ToHtml('Consulta 1º Tit.:') ?></label>
		<input name="dtcnsspc" id="dtcnsspc" type="text" value="" />
			
		<label for="nrinfcad">Inf. cadastrais:</label>
		<input name="nrinfcad" id="nrinfcad" type="text" value="" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input name="dsinfcad" id="dsinfcad" type="text" value="" />
		<br />
		
		<label for="dtoutspc"><? echo utf8ToHtml('Consulta 2º Tit/Cônjuge:') ?></label>
		<input name="dtoutspc" id="dtoutspc" type="text" value="" />
		<br />
	</fieldset>
	
	<fieldset style="display: none;">
		<legend><? echo utf8ToHtml('Central de Risco - Bacen') ?></legend>
	
		<label for="dtdrisco"><? echo utf8ToHtml('Consulta 1º Tit.:') ?></label>
		<input name="dtdrisco" id="dtdrisco" type="text" value="" />
		
		<label for="qtifoper">Qtd. IF com ope.:</label>
		<input name="qtifoper" id="qtifoper" type="text" value="" />
		
		<label for="qtopescr"><? echo utf8ToHtml('Qtd. Operações:') ?></label>
		<input name="qtopescr" id="qtopescr" type="text" value="" />
		<br />
						
		<label for="vltotsfn">Endividamento:</label>
		<input name="vltotsfn" id="vltotsfn" type="text" value="" />
						
		<label for="vlopescr">Vencidas:</label>
		<input name="vlopescr" id="vlopescr" type="text" value="" />
						
		<label for="vlrpreju">Prej.:</label>
		<input name="vlrpreju" id="vlrpreju" type="text" value="" />
		<br />
		
		<label for="dtoutris"><? echo utf8ToHtml('Consulta Cônjuge:') ?></label>
		<input name="dtoutris" id="dtoutris" type="text" value="" />
		
		<label for="vlsfnout"><? echo utf8ToHtml('Endiv. Cônjuge:') ?></label>
		<input name="vlsfnout" id="vlsfnout" type="text" value="" />
		<br />
							
	</fieldset>
	
	<fieldset>
		<legend><? echo utf8ToHtml('Rating') ?></legend>

		<label for="nrinfcad">Inf. cadastrais:</label>
		<input name="nrinfcad" id="nrinfcad" type="text" value="" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input name="dsinfcad" id="dsinfcad" type="text" value="" />
		<br />
	
		<label for="nrgarope">Garantia:</label>
		<input name="nrgarope" id="nrgarope" type="text" value="" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input name="dsgarope" id="dsgarope" type="text" value="" />
						
		<label for="nrliquid">Liquidez:</label>
		<input name="nrliquid" id="nrliquid" type="text" value="" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input name="dsliquid" id="dsliquid" type="text" value="" />
		<br />
		
		<label for="nrpatlvr">Patr. pessoal livre:</label>
		<input name="nrpatlvr" id="nrpatlvr" type="text" value="" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input name="dspatlvr" id="dspatlvr" type="text" value="" />
		<br />
	
		<label for="nrperger"><? echo utf8ToHtml('Percepção geral com relação a empresa:') ?></label>
		<input name="nrperger" id="nrperger" type="text" value="" />
		<a id='lupanrperger'><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input name="dsperger" id="dsperger" type="text" value="" />
		<br />
		
							
	</fieldset>
				
</form>

<div id="divBotoes">
	<? if ($operacao == 'C_PROT_CRED') { ?>
		<input type="image" id="btVoltar" src="<?php echo $UrlImagens; ?>botoes/voltar.gif"    onClick="controlaOperacao('C_NOVA_PROP'); return false;" />
		<input type="image" id="btSalvar" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="controlaOperacao('C_PROTECAO_TIT'); return false;" /> <!-- C_COMITE_APROV -->
	<? } ?>
</div>