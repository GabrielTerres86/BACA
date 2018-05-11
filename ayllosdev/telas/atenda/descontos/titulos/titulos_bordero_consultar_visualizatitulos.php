<?php 

	/************************************************************************
	 Fonte: titulos_bordero_consultar_visualizatitulos.php                                       
	 Autor: Guilherme                                                 
	 Data : Novembro/2008                Última Alteração: 03/12/2014
	                                                                  
	 Objetivo  : Visualizar os títulos de um Bordero de descontos de títulos        
	                                                                  	 
	 Alterações: 12/07/2011 - Alterado para layout padrão (Gabriel Capoia - DB1)
	 
				 29/08/2012 - Separação por Cob. Reg e Sem Registro (Lucas)

				 03/12/2014 - De acordo com a circula 3.656 do Banco Central,
				 		      substituir nomenclaturas Cedente por Beneficiário e  
							  Sacado por Pagador. Chamado 229313 (Jean Reddiga - RKAM)
							  
	************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");
	require_once("../../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");
	
	
	// Verifica se prâmetros necessários foram informados
	if (!isset($_POST["nrdconta"]) ||
		!isset($_POST["nrborder"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrborder = $_POST["nrborder"];

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se o número do bordero é um inteiro válido
	if (!validaInteiro($nrborder)) {
		exibeErro("N&uacute;mero do border&ocirc; inv&aacute;lida.");
	}	
	
	// Monta o xml de requisição
	$xmlGetTits  = "";
	$xmlGetTits .= "<Root>";
	$xmlGetTits .= "	<Cabecalho>";
	$xmlGetTits .= "		<Bo>b1wgen0030.p</Bo>";
	$xmlGetTits .= "		<Proc>busca_titulos_bordero</Proc>";
	$xmlGetTits .= "	</Cabecalho>";
	$xmlGetTits .= "	<Dados>";
	$xmlGetTits .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetTits .= "		<nrborder>".$nrborder."</nrborder>";
	$xmlGetTits .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetTits .= "	</Dados>";
	$xmlGetTits .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetTits);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjTits = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjTits->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjTits->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$titulos      = $xmlObjTits->roottag->tags[0]->tags;
	$restricoes   = $xmlObjTits->roottag->tags[1]->tags;
	
	//TOTAL
	$qtTitulos    = count($titulos);
	$qtRestricoes = count($restricoes);
	$vlrtotal = 0;
	$vltotliq = 0;
	$vlmedtit = 0;
	
	//TOTAL REGISTRADA
	$qtTitulos_cr = 0;
	$qtRestricoes_cr = 0;
	$vlrtotal_cr = 0;
	$vltotliq_cr = 0;
	$vlmedtit_cr = 0;
		
	//TOTAL SEM REGISTRO
	$qtTitulos_sr = 0;
	$qtRestricoes_sr = 0;
	$vlrtotal_sr = 0;
	$vltotliq_sr = 0;
	$vlmedtit_sr = 0;
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>
<div id="divTitulos" style="overflow-y: scroll; overflow-x: scroll; height: 350px; width: 600px;"  ="alert('teste');">
	<div id="divcr" style="display:block;">
		<table width="860px" border="0" cellpadding="1" cellspacing="2">
			<br/>
			<div width="120"  align="left" class="txtNormal">Tipo de Cobran&ccedil;a: REGISTRADA</div>	
			<br/>		
			<thead>
				<tr style="background-color: #F4D0C9;" height="20">				
					<th width="60"  align="center" class="txtNormalBold">Vencto</th>
					<th width="130" class="txtNormalBold">Nosso n&uacute;mero</th>
					<th width="80"  align="right"  class="txtNormalBold">Valor</th>
					<th width="80"  align="right"  class="txtNormalBold">Valor L&iacute;quido</th>
					<th width="30"  align="right"  class="txtNormalBold">Prz</th>
					<th width="250" align="left"   class="txtNormalBold">Pagador</th>
					<th width="110" align="right"  class="txtNormalBold">CPF/CNPJ</th>
					<th class="txtNormalBold">Situa&ccedil;&atilde;o</th>
				</tr>
			</thead>
			<?php 
			
			//EXIBIÇÃO DOS TITULOS COBRANÇA REGISTRADA
			
			$cor = "";
			$vlrtotal_cr = 0;
			$vltotliq_cr = 0;
					
			for ($i = 0; $i < $qtTitulos; $i++) {
							
				if ($titulos[$i]->tags[13]->cdata == "no"){
					continue;
				}
				
				if ($cor == "#F4F3F0") {
					$cor = "#FFFFFF";
				} else {
					$cor = "#F4F3F0";
				}
				
				$vlrtotal += doubleval(str_replace(",",".",$titulos[$i]->tags[8]->cdata));
				$vltotliq += doubleval(str_replace(",",".",$titulos[$i]->tags[9]->cdata));
				
				$vlrtotal_cr += doubleval(str_replace(",",".",$titulos[$i]->tags[8]->cdata));
				$vltotliq_cr += doubleval(str_replace(",",".",$titulos[$i]->tags[9]->cdata));
				$qtTitulos_cr += 1;
							
			?>
				<tr style="background-color: <?php echo $cor; ?>;" >
					<td width="60"  align="center" class="txtNormal"><?php echo $titulos[$i]->tags[3]->cdata; ?></td>
					<td width="130" class="txtNormal"><?php echo $titulos[$i]->tags[10]->cdata; ?></td>
					<td width="80"  align="right"  class="txtNormal"><?php echo number_format(str_replace(",",".",$titulos[$i]->tags[8]->cdata),2,",","."); ?></td>
					<td width="80"  align="right"  class="txtNormal"><?php echo number_format(str_replace(",",".",$titulos[$i]->tags[9]->cdata),2,",","."); ?></td>
					<td width="30"  align="right"  class="txtNormal"><?php if (trim($titulos[$i]->tags[4]->cdata) != "") echo diffData($titulos[$i]->tags[3]->cdata,$titulos[$i]->tags[4]->cdata); else echo diffData($titulos[$i]->tags[3]->cdata,$glbvars["dtmvtolt"]); ?></td>
					<td width="250" align="left"   class="txtNormal"><?php echo $titulos[$i]->tags[11]->cdata; ?></td>
					<td width="110" align="right"  class="txtNormal"><?php if (strlen($titulos[$i]->tags[5]->cdata) > 11){ echo formataNumericos('99.999.999/9999-99',$titulos[$i]->tags[5]->cdata,'./-'); }else{ echo formataNumericos('999.999.999-99',$titulos[$i]->tags[5]->cdata,'.-'); } ?></td>
					<td class="txtNormal"><?php switch ($titulos[$i]->tags[12]->cdata){ case 0: echo "Pendente";break; case 1: echo "Resgatado";break; case 2: echo "Pago";break; case 3: echo "Vencido";break; case 4: echo "Liberado";break; default: "------";break; }?></td>
				</tr>							
				
				<?php
			
				for ($j = 0; $j < $qtRestricoes; $j++){
					
					if ($restricoes[$j]->tags[2]->cdata == $titulos[$i]->tags[2]->cdata) {
				
						$qtRestricoes_cr += 1;
				?>
					<tr style="background-color: <?php echo $cor; ?>;">
						<td width="20" align="right" class="txtNormal">==></td>
						<td class="txtNormal" colspan="7"><?php echo $restricoes[$j]->tags[0]->cdata; ?></td>	
					</tr>
				
		<?php 
				
					}
				} // Fim do for das restrições
			} // Fim do for COB. REG
			
			$vlmedtit_cr = doubleval($vlrtotal_cr / $qtTitulos_cr);
			
		?>
			<tr>
				<td>&nbsp;</td>
			</tr>
			<tr>
				<td width="120" align="center" class="txtNormal">TOTAL(REGIST) ==></td>
				<td width="130" align="left"   class="txtNormal"><?php if($qtTitulos_cr <= 1){ echo $qtTitulos_cr." T&Iacute;TULO";}else{ echo $qtTitulos_cr." T&Iacute;TULOS";};?></td>
				<td width="80"  align="right"  class="txtNormal"><?php echo number_format(str_replace(",",".",$vlrtotal_cr),2,",","."); ?></td>
				<td width="80"  align="right"  class="txtNormal"><?php echo number_format(str_replace(",",".",$vltotliq_cr),2,",","."); ?></td>
				<td 			align="right"  class="txtNormal"></td>
				<td width="100" align="right"  class="txtNormal">VAL. M&Eacute;DIO: <?php echo number_format(str_replace(",",".",$vlmedtit_cr),2,",","."); ?></td>			
				<td width="85"  align="right"  class="txtNormal"><?php if($qtRestricoes_cr <= 1){echo $qtRestricoes_cr." RESTRI&Ccedil;&Atilde;O";}else{echo $qtRestricoes_cr." RESTRI&Ccedil;&Otilde;ES";} ?></td>
				<td class="txtNormal"></td>
			</tr>
			<tr>
				<td>&nbsp;</td>
			</tr>
		</table>		
	</div>
	
	<div id="divsr" style="display:block;">
		<table width="860px" border="0" cellpadding="1" cellspacing="2">	
			<br/>
			<div width="120"  align="left" class="txtNormal">Tipo de Cobran&ccedil;a: SEM REGISTRO</div>
			<br/>
			<thead>
				<tr style="background-color: #F4D0C9;" height="20">				
					<th width="60"  align="center" class="txtNormalBold">Vencto</th>
					<th width="130" class="txtNormalBold">Nosso n&uacute;mero</th>
					<th width="80"  align="right"  class="txtNormalBold">Valor</th>
					<th width="80"  align="right"  class="txtNormalBold">Valor L&iacute;quido</th>
					<th width="30"  align="right"  class="txtNormalBold">Prz</th>
					<th width="250" align="left"   class="txtNormalBold">Pagador</th>
					<th width="110" align="right"  class="txtNormalBold">CPF/CNPJ</th>
					<th class="txtNormalBold">Situa&ccedil;&atilde;o</th>
				</tr>
			</thead>
		
		<?php 
		
			if ($qtTitulos_cr == 0){		
				echo '<script>$("#divcr").css("display","none");</script>'; 
			}
		
			//EXIBIÇÃO DOS TITULOS COBRANÇA SEM REGISTRO
			
			$cor = "";
			$vlrtotal_sr = 0;
			$vltotliq_sr = 0;
					
			for ($i = 0; $i < $qtTitulos; $i++) {
			
				if ($titulos[$i]->tags[13]->cdata == "yes"){
					continue;
				}
				
				if ($cor == "#F4F3F0") {
					$cor = "#FFFFFF";
				} else {
					$cor = "#F4F3F0";
				}
				
				$vlrtotal += doubleval(str_replace(",",".",$titulos[$i]->tags[8]->cdata));
				$vltotliq += doubleval(str_replace(",",".",$titulos[$i]->tags[9]->cdata));
				
				$vlrtotal_sr += doubleval(str_replace(",",".",$titulos[$i]->tags[8]->cdata));
				$vltotliq_sr += doubleval(str_replace(",",".",$titulos[$i]->tags[9]->cdata));
				$qtTitulos_sr += 1;
						
		?>
				<tr style="background-color: <?php echo $cor; ?>;" >
					<td width="60"  align="center" class="txtNormal"><?php echo $titulos[$i]->tags[3]->cdata; ?></td>
					<td width="130" class="txtNormal"><?php echo $titulos[$i]->tags[10]->cdata; ?></td>
					<td width="80"  align="right"  class="txtNormal"><?php echo number_format(str_replace(",",".",$titulos[$i]->tags[8]->cdata),2,",","."); ?></td>
					<td width="80"  align="right"  class="txtNormal"><?php echo number_format(str_replace(",",".",$titulos[$i]->tags[9]->cdata),2,",","."); ?></td>
					<td width="30"  align="right"  class="txtNormal"><?php if (trim($titulos[$i]->tags[4]->cdata) != ""){ echo diffData($titulos[$i]->tags[3]->cdata,$titulos[$i]->tags[4]->cdata); }else{ echo diffData($titulos[$i]->tags[3]->cdata,$glbvars["dtmvtolt"]);} ?></td>
					<td width="250" align="left"   class="txtNormal"><?php echo $titulos[$i]->tags[11]->cdata; ?></td>
					<td width="110" align="right"  class="txtNormal"><?php if (strlen($titulos[$i]->tags[5]->cdata) > 11){ echo formataNumericos('99.999.999/9999-99',$titulos[$i]->tags[5]->cdata,'./-'); }else{ echo formataNumericos('999.999.999-99',$titulos[$i]->tags[5]->cdata,'.-'); } ?></td>
					<td class="txtNormal"><?php switch ($titulos[$i]->tags[12]->cdata){ case 0: echo "Pendente";break; case 1: echo "Resgatado";break; case 2: echo "Pago";break; case 3: echo "Vencido";break; case 4: echo "Liberado";break; default: "------";break; }?></td>
				</tr>							
		<?php
		
				for ($j = 0; $j < $qtRestricoes; $j++){
				
					if ($restricoes[$j]->tags[2]->cdata == $titulos[$i]->tags[2]->cdata) {
											
						$qtRestricoes_sr += 1;
					
					?>
					
					<tr style="background-color: <?php echo $cor; ?>;">
						<td width="20" align="right" class="txtNormal">==></td>
						<td class="txtNormal" colspan="7"><?php echo $restricoes[$j]->tags[0]->cdata; ?></td>	
					</tr>
					
		<?php 
					}
				} // Fim do for das restrições
			} // Fim do for COB. SEM REGISTRO
				
			$vlmedtit_sr = doubleval($vlrtotal_sr / $qtTitulos_sr);
			$vlmedtit = doubleval($vlrtotal / $qtTitulos);
		?>
		
			<tr>
				<td>&nbsp;</td>
			</tr>
			<tr>
				<td width="120" align="center" class="txtNormal">TOTAL(S/ REG) ==></td>
				<td width="130" align="left"   class="txtNormal"><?php if($qtTitulos_sr <= 1){ echo $qtTitulos_sr." T&Iacute;TULO";}else{ echo $qtTitulos_sr." T&Iacute;TULOS";};?></td>
				<td width="80"  align="right"  class="txtNormal"><?php echo number_format(str_replace(",",".",$vlrtotal_sr),2,",","."); ?></td>
				<td width="80"  align="right"  class="txtNormal"><?php echo number_format(str_replace(",",".",$vltotliq_sr),2,",","."); ?></td>
				<td 			align="right"  class="txtNormal"></td>
				<td width="100" align="right"  class="txtNormal">VAL. M&Eacute;DIO: <?php echo number_format(str_replace(",",".",$vlmedtit_sr),2,",","."); ?></td>			
				<td width="85"  align="right"  class="txtNormal"><?php if($qtRestricoes_sr <= 1){echo $qtRestricoes_sr." RESTRI&Ccedil;&Atilde;O";}else{echo $qtRestricoes_sr." RESTRI&Ccedil;&Otilde;ES";} ?></td>
				<td class="txtNormal"></td>
			</tr>
			
			<?
			
			if ($qtTitulos_sr == 0){
				
				echo '<script>$("#divsr").css("display","none");</script>'; 
				
			}
			
			if ($qtTitulos_cr != 0 &&
				$qtTitulos_sr != 0){
			?>
				<tr>
					<td>&nbsp;</td>
				</tr>
				<tr>
					<td width="120" align="center" class="txtNormal">TOTAL ==></td>			
					<td width="130" align="left"   class="txtNormal"><?php if($qtTitulos <= 1){ echo $qtTitulos." T&Iacute;TULO";}else{ echo $qtTitulos." T&Iacute;TULOS";};?></td>
					<td width="80"  align="right"  class="txtNormal"><?php echo number_format(str_replace(",",".",$vlrtotal),2,",","."); ?></td>
					<td width="80"  align="right"  class="txtNormal"><?php echo number_format(str_replace(",",".",$vltotliq),2,",","."); ?></td>
					<td 			align="right"  class="txtNormal"></td>
					<td width="100" align="right"  class="txtNormal">VAL. M&Eacute;DIO: <?php echo number_format(str_replace(",",".",$vlmedtit),2,",","."); ?></td>			
					<td width="85"  align="right"  class="txtNormal"><?php echo $qtRestricoes; ?> <? if($qtRestricoes <= 1){echo "RESTRI&Ccedil;&Atilde;O";}else{echo "RESTRI&Ccedil;&Otilde;ES";} ?></td>
					<td class="txtNormal"></td>
					
				</tr>
		<?
			}
		?>
		</table>
	</div>	
</div>

<div id="divBotoes">
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="voltaDiv(4,3,4,'CONSULTA DE BORDER&Ocirc;');return false;" />
</div>

<script type="text/javascript">
dscShowHideDiv("divOpcoesDaOpcao4","divOpcoesDaOpcao3");

// Muda o título da tela
$("#tdTitRotina").html("CONSULTA DE T&Iacute;TULOS DO BORDER&Ocirc;");

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conteúdo que está átras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>