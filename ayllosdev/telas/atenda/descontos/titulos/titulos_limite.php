<?php 

	/************************************************************************
	 Fonte: titulos_limite.php                                        
	 Autor: Guilherme                                                 
	 Data : Novembro/2008                �ltima Altera��o: 15/04/2018
	                                                                  
	 Objetivo  : Mostrar opcao Limites de descontos da rotina         
	             Descontos da tela ATENDA                 		   	  
	                                                                  	 
	 Altera��es: 09/06/2010 - Mostrar descri��o da situa��o (David).

				 25/06/2010 - Mostar campo de envio a sede (Gabriel).
				 
				 12/07/2011 - Alterado para layout padr�o (Gabriel Capoia - DB1)
				 
				 18/11/2011 - Ajustes para nao mostrar botao quando nao tiver permissao (Jorge)
				 
				 21/05/2015 - Alterado para apresentar mensagem ao realizar inclusao
 							  de proposta de novo limite de desconto de titulo para
 							  menores nao emancipados (Reinert).

				 17/12/2015 - Edi��o de n�mero do contrato de limite (Lunelli - SD 360072 [M175])

				 26/06/2017 - Ajuste para rotina ser chamada atrav�s da tela ATENDA > Produtos (Jonata - RKAM / P364).

                 11/12/2017 - P404 - Inclus�o de Garantia de Cobertura das Opera��es de Cr�dito (Augusto / Marcos (Supero))

				 28/03/2018 - Altera��o nos bot�es para as novas funcionalidades da tela (Andre Avila GFT).

				 15/04/2018 - Altera��o no bot�o 'Detalhes da Proposta' (Leonardo Oliveira - GFT).

				 26/04/2018 - Ajuste no bot�o de voltar, uso da fun��o generica (Leonardo Oliveira - GFT).
	************************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");
	require_once("../../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");
	
	setVarSession("nmrotina","DSC TITS - CONTRATO");

	// Carrega permiss�es do operador
	include("../../../../includes/carrega_permissoes.php");	
	
	setVarSession("opcoesTela",$opcoesTela);
	
	// Verifica se o n�mero da conta foi informado
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];

	// Verifica se o n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Monta o xml de requisi��o
	$xmlGetLimites  = "";
	$xmlGetLimites .= "<Root>";
	$xmlGetLimites .= "	<Cabecalho>";
	$xmlGetLimites .= "		<Bo>b1wgen0030.p</Bo>";
	$xmlGetLimites .= "		<Proc>busca_limites</Proc>";
	$xmlGetLimites .= "	</Cabecalho>";
	$xmlGetLimites .= "	<Dados>";
	$xmlGetLimites .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetLimites .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetLimites .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlGetLimites .= "	</Dados>";
	$xmlGetLimites .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetLimites);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjLimites = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjLimites->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjLimites->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$limites   = $xmlObjLimites->roottag->tags[0]->tags;
	$qtLimites = count($limites);
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}	
?>

<div id="divContratos">
	<div class="divRegistros">
		<table>
			<thead>
				<tr>
					<th>Data Efetiva&ccedil;&atilde;o</th>
					<th>In&iacute;cio Vig&ecirc;ncia</th>
					<th>Contrato</th>
					<th>Limite</th>
					<th>Dias de Vig&ecirc;ncia</th>
					<th>Linha de Desconto</th>
					<th >Situa&ccedil;&atilde;o do Limite</th>
				</tr>			
			</thead>
			<tbody>
				
				<?  for ($i = 0; $i < $qtLimites; $i++) {
												
					    $pr_dtpropos = getByTagName($limites[$i]->tags,"dtpropos");//0
					    $pr_dtinivig = getByTagName($limites[$i]->tags,"dtinivig");//1
					    $pr_vllimite = getByTagName($limites[$i]->tags,"vllimite");//2
						$pr_nrctrlim = getByTagName($limites[$i]->tags,"nrctrlim");//3
						$pr_qtdiavig = getByTagName($limites[$i]->tags,"qtdiavig");//4
						$pr_cddlinha = getByTagName($limites[$i]->tags,"cddlinha");//5
						$pr_tpctrlim = getByTagName($limites[$i]->tags,"tpctrlim");//6
						$pr_dssitlim = getByTagName($limites[$i]->tags,"dssitlim");//7
						$pr_dssitest = getByTagName($limites[$i]->tags,"dssitest");//8
						$pr_dssitapr = getByTagName($limites[$i]->tags,"dssitapr");//9
						$pr_flgenvio = getByTagName($limites[$i]->tags,"flgenvio");//10
						$pr_insitlim = getByTagName($limites[$i]->tags,"flgenvio");//11
						$pr_idcobope = getByTagName($limites[$i]->tags,"idcobope");//12
						$pr_cdageori = getByTagName($limites[$i]->tags,"cdageori");//13
									
						$mtdClick = "selecionaLimiteTitulos('"
							.($i + 1)."', '"
							.$qtLimites."', '"
							.$pr_nrctrlim."', '"
							.$pr_dssitlim."', '"
							.$pr_dssitest."', '"
							.$pr_dssitapr."', '"
							.$pr_vllimite."');";
				?>

					<tr id="trLimite<? echo $i + 1; ?>" onFocus="<? echo $mtdClick; ?>" onClick="<? echo $mtdClick; ?>">
					
						<td><?php
							  // Vamos salvar o numero do contrato ativo para usar na tela de garantia (Merge GFT)
              if ($limites[$i]->tags[9]->cdata == 2) {
								echo '<input type="hidden" name="nrcontratoativo" id="nrcontratoativo" value="'.$pr_nrctrlim.'"/>';
              }
							  echo $pr_dtpropos; ?>
            </td>
						
						<td><? echo $pr_dtinivig; ?></td>
						
						<td>
							<span><? echo $pr_nrctrlim ?></span>
							<? echo formataNumericos('zzz.zzz.zzz',$pr_nrctrlim,'.'); ?>
						</td>

						<td>
							<span><? echo $pr_vllimite; ?></span>
							<? echo number_format(str_replace(",",".",$pr_vllimite),2,",","."); ?>
						</td>
						
						<td><? echo $pr_qtdiavig; ?></td>
						<td><? echo $pr_cddlinha; ?></td>
						<td><? echo $pr_dssitlim; ?></td>
				
												
					</tr>
				<?} // Fim do for ?>			
			</tbody>
		</table>
	</div>
</div>

<div id="divBotoesTitulosLimite" style="margin-bottom:10px; margin-top: 10px;">
	
	<input 
		type="button" 
		class="botao" 
		value="Voltar"  
		onClick="
			voltaDiv(2,1,4,'DESCONTO DE T&Iacute;TULOS','DSC TITS');
			carregaTitulos();
			return false;" 
		/>

	<input 
		type="button"
		class="botao"
		value="Cancelar"
		<?php if ($qtLimites == 0) {
			echo 'onClick="return false;"';
		} else {
			echo 'style="'.$dispX.'" onClick="showConfirmacao(\'Deseja cancelar o Contrato?\',\'Confirma&ccedil;&atilde;o - Ayllos\',\'cancelaLimiteDscTit()\',\'metodoBlock()\',\'sim.gif\',\'nao.gif\');return false;"';
		} ?>  />
	
	<input 
		type="button"
		class="botao"
		value="Consultar"
		<?php if ($qtLimites == 0) {
			echo 'onClick="return false;"';
			} else {
				echo 'onClick="carregaDadosConsultaLimiteDscTit();return false;"'; 
		} ?> />
	
	<input 
		type="button"
		class="botao"
		value="Imprimir"
		<?php if ($qtLimites == 0) { 
			echo 'onClick="return false;"';
		} else {
			echo 'onClick="mostraImprimirLimite(\'CONTRATO\');return false;"';
		} ?> />

	<input 
		type="button" 
		class="botao" 
		value="Detalhes da Proposta"  
		id="btnDetalhesProposta" name="btnDetalhesProposta" 
		<?php if ($qtLimites == 0) { 
			echo 'onClick="return false;"';
		} else { 
			echo 'onClick="carregaDadosDetalhesProposta(\'CONTRATO\', nrcontrato, 0);return false;"'; 
		} ?> />

</div>

<script type="text/javascript">
dscShowHideDiv("divOpcoesDaOpcao2","divOpcoesDaOpcao1;divOpcoesDaOpcao3");

// Muda o t�tulo da tela
$("#tdTitRotina").html("DESCONTO DE T&Iacute;TULOS - LIMITE");

	formataLayout('divContratos');

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte�do que est� �tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
	
	//Se esta tela foi chamada atrav�s da rotina "Produtos" ent�o acessa a op��o conforme definido pelos respons�veis do projeto P364
	if (executandoProdutos == true) {
		
		$("#btnIncluirLimite", "#divBotoesTitulosLimite").click();
		
	}
	
</script>