<?php 

	//************************************************************************//
	//*** Fonte: prejuizo.php                                              ***//
	//*** Autor: David                                                     ***//
	//*** Data : Maio/2009                    &Uacute;ltima Altera&ccedil;&atilde;o: 00/00/0000 ***//
	//***                                                                  ***//
	//*** Objetivo  : Mostrar opcao Preju&iacute;zo da rotina Presta&ccedil;&otilde;es da tela  ***//
	//****						ATENDA  												                     ***//
	//***                                                                  ***//	 
	//*** Altera&ccedil;&otilde;es:                   
	//***
	//*** 001: [24/05/2013] Lucas R. (CECRED): Incluir camada nas includes "../". ***//
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");		
	require_once("../../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"C")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>
<table width="510" height="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td valign="middle">
			<form action="" method="post" name="frmDadosPrejuizo" id="frmDadosPrejuizo">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
					<td align="center">
						<table width="430" border="0" cellpadding="0" cellspacing="2">
							<tr>
								<td width="50">
									<table width="100%" border="0" cellpadding="0" cellspacing="0">
										<tr>
											<td height="1" style="background-color:#999999;"></td>
										</tr>
									</table>
								</td>								
								<td height="18" class="txtNormalBold" align="center" style="background-color: #E3E2DD;">PREJU&Iacute;ZOS DO CONTRATO </td>
								<td width="50">
									<table width="100%" border="0" cellpadding="0" cellspacing="0">
										<tr>
											<td height="1" style="background-color:#999999;"></td>
										</tr>
									</table>								
								</td>
							</tr>
						</table>						
					</td>
				</tr>
				<tr>
					<td>
						<table width="100%" border="0" cellpadding="0" cellspacing="2">
							<tr>
								<td class="txtNormalBold" width="132" height="23" align="right">Transferido em:&nbsp;</td>
								<td class="txtNormal" width="125"><input name="dtprejuz" type="text" class="campoTelaSemBorda" id="dtprejuz" style="width: 120px;" readonly></td>
								<td class="txtNormalBold" width="115" align="right">Valor do Abono:&nbsp;</td>
								<td class="txtNormal"><input name="vlrabono" type="text" class="campoTelaSemBorda" id="vlrabono" style="width: 120px;" readonly></td>
							</tr>
							<tr>
								<td class="txtNormalBold" height="23" align="right">Preju&iacute;zo Original:&nbsp;</td>
								<td class="txtNormal"><input name="vlprejuz" type="text" class="campoTelaSemBorda" id="vlprejuz" style="width: 120px;" readonly></td>
								<td class="txtNormalBold" align="right">Juros do M&ecirc;s:&nbsp; </td>
								<td class="txtNormal"><input name="vljrmprj" type="text" class="campoTelaSemBorda" id="vljrmprj" style="width: 120px;" readonly></td>
							</tr>					
							<tr>
								<td class="txtNormalBold" height="23" align="right">Saldo Preju&iacute;zo Original:&nbsp;</td>
								<td class="txtNormal"><input name="slprjori" type="text" class="campoTelaSemBorda" id="slprjori" style="width: 120px;" readonly></td>
								<td class="txtNormalBold" align="right">Juros Acumulados:&nbsp;</td>
								<td class="txtNormal"><input name="vljraprj" type="text" class="campoTelaSemBorda" id="vljraprj" style="width: 120px;" readonly></td>
							</tr>	
							<tr>
								<td class="txtNormalBold" height="23" align="right">Valores Pagos:&nbsp;</td>
								<td class="txtNormal"><input name="vlrpagos" type="text" class="campoTelaSemBorda" id="vlrpagos" style="width: 120px;" readonly></td>
								<td class="txtNormalBold" align="right">Acr&eacute;scimos:&nbsp;</td>
								<td class="txtNormal"><input name="vlacresc" type="text" class="campoTelaSemBorda" id="vlacresc" style="width: 120px;" readonly></td>
							</tr>	
							<tr>
								<td class="txtNormalBold" height="23" align="right">&nbsp;</td>
								<td class="txtNormal">&nbsp;</td>
								<td class="txtNormalBold" align="right"> Saldo Atualizado:&nbsp;</td>
								<td class="txtNormal"><input name="vlsdprej" type="text" class="campoTelaSemBorda" id="vlsdprej" style="width: 120px;" readonly></td>
							</tr>	
						</table>	
					</td>
				</tr>	
				<tr>
					<td height="5"></td>
				</tr>
				<tr>
					<td align="center"><input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="mostraDivDadosEpr();return false;"></td>
				</tr>				
			</table>	
			</form>			
		</td>
	</tr>	
</table>	
<script type="text/javascript">
// Mostra dados do preju&iacute;zo
$("#dtprejuz","#frmDadosPrejuizo").val(emprestimos[idEpr].dtprejuz);
$("#vlrabono","#frmDadosPrejuizo").val(emprestimos[idEpr].vlrabono);
$("#vlprejuz","#frmDadosPrejuizo").val(emprestimos[idEpr].vlprejuz);
$("#vljrmprj","#frmDadosPrejuizo").val(emprestimos[idEpr].vljrmprj);
$("#slprjori","#frmDadosPrejuizo").val(emprestimos[idEpr].slprjori);
$("#vljraprj","#frmDadosPrejuizo").val(emprestimos[idEpr].vljraprj);
$("#vlrpagos","#frmDadosPrejuizo").val(emprestimos[idEpr].vlrpagos);
$("#vlacresc","#frmDadosPrejuizo").val(emprestimos[idEpr].vlacresc);
$("#vlsdprej","#frmDadosPrejuizo").val(emprestimos[idEpr].vlsdprej);	
	
mostraDiv("divConteudoOpcaoRotina","181");	

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>