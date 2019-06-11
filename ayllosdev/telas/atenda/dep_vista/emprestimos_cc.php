<?
/*
 * FONTE        : emprestimos_cc.php
 * CRIAÇÃO      : Diego Simas (AMcom)
 * DATA CRIAÇÃO : 03/08/2018
 * OBJETIVO     : Tela para entrada de informações de pagamento de empréstimo.
   ALTERACOES   :
 */
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	
?>
<table id="tdImp"cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">
			<table border="0" cellpadding="0" cellspacing="0" width="300">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><?php echo utf8ToHtml('Pagamento de Empréstimo'); ?></td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="mostraDetalhesCT(); return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
								<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td class="tdConteudoTela" align="center">
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px 2px 8px;">
										<form id="frmEmpCC" name="frmEmpCC" class="formulario">
											
											<table width="100%"> 
                                                												
                                                <tr>
													<td><label for="nrctremp">&nbsp;&nbsp;<?php echo utf8ToHtml('Contrato:') ?></label></td>
													<td><input type="text" id="nrctremp" name="nrctremp" class="campo"/>
                                                        <a onClick="mostraContrato('#nrctremp','#frmEmpCC'); return false;">
                                                            <img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" />
                                                        </a>
                                                    </td>
												</tr>

												<tr>
													<td><label for="vlpagto">&nbsp;&nbsp;<?php echo utf8ToHtml('Pagamento:') ?></label></td>
													<td><input type="text" id="vlpagto" name="vlpagto" class="moeda campo" /></td>
												</tr>

												<tr>
													<td><label for="vlabono">&nbsp;&nbsp;<?php echo utf8ToHtml('Abono:') ?></label></td>
													<td><input type="text" id="vlabono" name="vlabono" class="moeda campo" /></td>
												</tr>

											</table>
										
										</form>
										
										<div id="divBotoes">
											<input type="image" id="btVoltar" src="<?php echo $UrlImagens; ?>botoes/voltar.gif"    onClick="mostraDetalhesCT(); return false;" />
											<input type="image" id="btSalvar" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="pedeSenha($('#nrctremp', '#frmEmpCC').val(),$('#vlpagto', '#frmEmpCC').val(),$('#vlabono', '#frmEmpCC').val());" />
										</div>                    
                    									
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>

<script type="text/javascript">

	// Formata layout
	formataEmprestimo();  

	function pedeSenha(nrctremp, valorPagto, valorAbono){	
		var vlpagto = retiraMascara(valorPagto) || 0; 
		var vlabono = retiraMascara(valorAbono) || 0; 
		var nrctrato = normalizaNumero(nrctremp) || 0; 		 
		efetuaPagamentoEmp(nrctrato, vlpagto, vlabono);		 	     
	}

	$("#nrctremp", "#frmEmpCC").blur(function() {
		var nrctremp = $('#nrctremp', '#frmEmpCC').val();
		consultaSituacaoEmpr(nrctremp);
	});	
	
</script>
