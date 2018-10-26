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
							  
				 02/04/2018 - Padronização da tabela, retirada das restrições e adição do saldo devedor (Leonardo Oliveira -GFT)
							  
				 07/05/2018 - Adicionada verificação para definir se o bordero vai seguir o fluxo novo ou o antigo (Luis Fernando - GFT)

				 19/05/2018 - Insert do campo de Decisão (Vitor Shimada Assanuma - GFT)

				 13/08/2018 - Novo botão "Ver Detalhes do Título" (Vitor Shimada Assanuma - GFT)

                 14/08/2018 - Rename do botão para: "Ver Detalhes da An&aacute;lise" (Vitor Shimada Assanuma - GFT)

                 15/08/2018 - Alteração da situação e prazo para 0 do título quando a decisão estiver como NÃO APROVADO (Vitor Shimada Assanuma - GFT)

                 19/09/2018 - Alterado a descrição da situação do titulo (Paulo Penteado - GFT)

                 04/10/2018 - Alterado a mensagem quando for pago após vencimento (Vitor S Assanuma - GFT)
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
	
	/*Verifica se o borderô deve ser utilizado no sistema novo ou no antigo*/
	$xml = "<Root>";
	$xml .= " <Dados>";
	$xml .= "		<nrborder>".$nrborder."</nrborder>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	$xmlResult = mensageria($xml,"TELA_ATENDA_DESCTO","VIRADA_BORDERO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getClassXML($xmlResult);
	$root = $xmlObj->roottag;
	// Se ocorrer um erro, mostra crítica
	if ($root->erro){
		exibeErro(htmlentities($root->erro->registro->dscritic));
		exit;
	}
	$flgverbor = $root->dados->flgverbor->cdata;
	$flgnewbor = $root->dados->flgnewbor->cdata;

	if($flgnewbor){
		$xml =  "<Root>";
		$xml .= " <Dados>";
		$xml .= "		<nrborder>".$nrborder."</nrborder>";
		$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
		$xml .= " </Dados>";
		$xml .= "</Root>";


		$xmlResult = mensageria($xml, "TELA_ATENDA_DESCTO", "BUSCAR_TIT_BORDERO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	}
	else{
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
	}
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjTits = getClassXML($xmlResult);
    $root = $xmlObjTits->roottag;
	$dados = $root->dados;
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjTits->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjTits->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	//TOTAL
	$vlrtotal = 0;
	$vltotliq = 0;
	$vlmedtit = 0;
	
	//TOTAL REGISTRADA
	$qtTitulos_cr = 0;
	$vlrtotal_cr = 0;
	$vltotliq_cr = 0;
	$vlmedtit_cr = 0;
	if(!$flgnewbor){
		$titulos      = $xmlObjTits->roottag->tags[0]->tags;
		$restricoes   = $xmlObjTits->roottag->tags[1]->tags;
		$qtRestricoes = count($restricoes);
		$qtRestricoes_cr = 0;
	//TOTAL SEM REGISTRO
	$qtTitulos_sr = 0;
	$qtRestricoes_sr = 0;
	$vlrtotal_sr = 0;
	$vltotliq_sr = 0;
	$vlmedtit_sr = 0;
	}
	else{
		$titulos      = $dados->find("titulo");
	}
	$qtTitulos    = count($titulos);

	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>


<?if($flgnewbor){?>
	<form class="formulario">
		<div id="divTitulosBorderos">

			<input type="hidden" id="nrdconta" name="nrdconta" value="<? echo $nrdconta; ?>" />

			<fieldset>
				<legend>N. Border&ocirc;: <?=formataNumericos('z.zzz.zz9',$nrborder,'.')?></legend>
					
				<div id="divcr" class="divRegistros" >
						<table  class="tituloRegistros">
							<thead>
								<tr>
									<th>Vencto</th>
									<th>Nosso n&uacute;mero</th>
									<th>Valor</th>
									<th>Valor L&iacute;quido</th>
									<th>Prz</th>
									<th>Pagador</th>
									<th>CPF/CNPJ</th>
									<th>Situa&ccedil;&atilde;o</th>
									<th>Decis&atilde;o</th>
									<th>Saldo Devedor</th>
									<th>Nr. Ctr. Cyber</th>
								</tr>
							</thead>
							<tbody>
							<?php
									$vlrtotal_cr = 0;
									$vltotliq_cr = 0;
											
									for ($i = 0; $i < $qtTitulos; $i++) {
										$t = $titulos[$i];
										if ($t->tags[13]->cdata == "no"){
											continue;
										}
										
										$vlrtotal += doubleval(str_replace(",",".",$t->tags[8]->cdata));
										$vltotliq += doubleval(str_replace(",",".",$t->tags[9]->cdata));
										
										$vlrtotal_cr += doubleval(str_replace(",",".",$t->tags[8]->cdata));
										$vltotliq_cr += doubleval(str_replace(",",".",$t->tags[9]->cdata));
										$qtTitulos_cr += 1;
										
										$mtdClick = "selecionarTituloDeBordero('"
											.($i + 1)."','"
											.$qtBorderos."','"
											.getByTagName($t->tags,'nossonum')."');";
								?>
								<tr 
									id="trTitBordero<?echo $i + 1; ?>" 
									onFocus="<? echo $mtdClick; ?>"
									onClick="<? echo $mtdClick; ?>"
									>
									<td>
									<input type='hidden' name='selecionados' value='<? echo $t->tags[0]->cdata; ?>;<? echo $t->tags[7]->cdata; ?>;<? echo $t->tags[6]->cdata; ?>;<? echo $t->tags[2]->cdata; ?>'/>
										<?php echo $t->tags[3]->cdata;?>
									</td> 
									<td><?php echo $t->tags[10]->cdata; ?></td> 
									<td><?php echo number_format(str_replace(",",".",$t->tags[8]->cdata),2,",",".");?></td> 
									<td><?php echo number_format(str_replace(",",".",$t->tags[9]->cdata),2,",","."); ?></td> 
									<td><?php 
											//Verifica se o título já está liberado, caso esteja é a diferença de data de lib-venc, senão utiliza a data de movimento.
											if (trim($t->tags[4]->cdata) != ""){ 
												echo diffData($t->tags[3]->cdata,$t->tags[4]->cdata); 
											}else{
												//Caso o título esteja APROVADO é a lib-dtmvtolt senão é zerado.
												if ($t->tags[14]->cdata != 2){
													echo diffData($t->tags[3]->cdata,$glbvars["dtmvtolt"]);
												}else{
													echo "0";
												}
											}
									?></td>
									<td><?php echo $t->tags[11]->cdata;
									?></td> 
									<td><?php 
										if (strlen($t->tags[5]->cdata) > 11){ 
											echo formataNumericos('99.999.999/9999-99',$t->tags[5]->cdata,'./-');
										}else{ 
											echo formataNumericos('999.999.999-99',$t->tags[5]->cdata,'.-');
										} 
									?></td>
									
									<td><?php 
										$dssittit = explode(' ',getByTagName($t->tags,'dssittit'));
										for ($j = 0; $j < count($dssittit); $j++){
											if ($j == 2){
												echo "<br>";
											}
											echo " ".$dssittit[$j];
										}
									?></td>
									<td>
										<?php 
											switch ($t->tags[14]->cdata){ 
												case 0: echo "Aguardando An&aacute;lise";break;
												case 1: echo "Aprovado";break;
												case 2: echo "N&atilde;o Aprovado";break;
												default: "------";break;
											}
										?>	
									</td>
									<td><?php echo number_format(str_replace(",",".",$t->tags[16]->cdata),2,",",".");?></td> 
									<td><?php echo $t->tags[17]->cdata; ?></td> 
								</tr>							
							<?php 
								}
							?>
							</tbody>
						</table>	
					</div>
			</fieldset>
		</div>

		<?php
			$vlmedtit_cr = doubleval($vlrtotal_cr / $qtTitulos_cr);
		?>
		<table width="95%" border="0" cellpadding="1" cellspacing="2" style="margin: 10px 0 0 0">
				<tbody>
				<tr>
						<td width="140" align="center" class="txtNormal">TOTAL(REGIST) ==></td>
						<td width="65"  align="center"   class="txtNormal"><?php if($qtTitulos_cr <= 1){ echo $qtTitulos_cr." T&Iacute;TULO";}else{ echo $qtTitulos_cr." T&Iacute;TULOS";};?></td>
						<td width="65"  align="center"  class="txtNormal"><?php echo number_format(str_replace(",",".",$vlrtotal_cr),2,",","."); ?></td>
						<td width="80"  align="right"  class="txtNormal"><?php echo number_format(str_replace(",",".",$vltotliq_cr),2,",","."); ?></td>
						<td 			align="right"  class="txtNormal"></td>
						<td width="100" align="right"  class="txtNormal">VAL. M&Eacute;DIO: <?php echo number_format(str_replace(",",".",$vlmedtit_cr),2,",","."); ?></td>			
					</tr>
				</tbody>
		</table>
	</form>

	<?include('criticas_bordero.php');?>

	<div id="divBotoes">
		<a href="#" class="botao"  name="btnvoltar"   id="btnvoltar"   onClick="voltaDiv(4,3,4,'CONSULTA DE BORDER&Ocirc;');return false;" > Voltar</a>
		<a href="#" class="botao"  name="btnvoltar"   id="btnvoltar"   onClick="visualizarTituloDeBordero();return false;" > Ver Detalhes da An&aacute;lise</a>
		<a href="#" class="botao"  name="btnDetalhes" id="btnDetalhes" onClick="visualizarDetalhesTitulo();return false;" > Ver detalhes do T&iacute;tulo</a>
	</div>

	<script type="text/javascript">
		dscShowHideDiv("divOpcoesDaOpcao4","divOpcoesDaOpcao3");

		// Muda o título da tela
		$("#tdTitRotina").html("CONSULTA DE T&Iacute;TULOS DO BORDER&Ocirc;");
		formataLayout('divTitulosBorderos');
		    
		// Esconde mensagem de aguardo
		hideMsgAguardo();

		// Bloqueia conteúdo que está átras do div da rotina
		blockBackground(parseInt($("#divRotina").css("z-index")));
	</script>
<?}
else{?>
	<div id="divTitulos" style="overflow-y: scroll; overflow-x: scroll; height: 350px; width: 600px;"  >
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
<?}