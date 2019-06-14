<? /************************************************************************
	 Fonte: principal_tabela.php
	 Autor: Lucas R.                                                  
	 Data : Junho/2013                Última Alteração: 01/12/2017 
	                                                                  
	 Objetivo  : Monta tabela de aplicações da tela ATENDA            
	                                                                  
	 Alterações: 04/06/2013 - Incluir Valor Bloq. Judicial na ul      
	                          complemento (Lucas R).                  
	
				 29/04/2014 - Ajuste referente ao projeto Captação							  
							  (Adriano)
			     
				 08/09/2014 - Inclusao do campo CDPRODUT (Jean Michel)
							  
				 09/09/2014 - Adicionado opção para o agendamento
				              (Douglas - Projeto Captação Internet 2014/2)
				
				 14/04/2015 - Adicionado novo campo com a data de carência 
						      da aplicação SD - 266191 (Kelvin)

                 27/11/2017 - Inclusao do valor de bloqueio em garantia.
                              PRJ404 - Garantia(Odirlei-AMcom)              

		         01/12/2017 - Não permitir acesso a opção de incluir quando conta demitida (Jonata - RKAM P364).

	************************************************************************/	
?> 

<div id="divAplicacoesPrincipal">

	<div class="divRegistros">	
		<table>
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Data'); ?></th>
					<th><? echo utf8ToHtml('Hist&oacute;rico');  ?></th>
					<th><? echo utf8ToHtml('Car.');   ?></th>
					<th><? echo utf8ToHtml('Valor');  ?></th>
					<th><? echo utf8ToHtml('Vencto');  ?></th>
					<th><? echo utf8ToHtml('Saldo');  ?></th>
					<th><? echo utf8ToHtml('Sl Resg.');  ?></th>
					<th><? echo utf8ToHtml('Dt Car.'); ?></th>
				</tr>
			</thead>
			<?php 				
				if($qtAplicacoes > 0 && getByTagName($aplicacoes[0]->tags,"NRAPLICA") != 0){
			?>
			<tbody>
				<script type="text/javascript">
					lstAplicacoes = new Array(); // Inicializar lista de aplicações
				</script>
				<? 
				for ($i = 0; $i < $qtAplicacoes; $i++) { 
					
					$dtmvtolt = getByTagName($aplicacoes[$i]->tags,"DTMVTOLT");
					$nraplica = getByTagName($aplicacoes[$i]->tags,"NRAPLICA");
					$qtdiauti = getByTagName($aplicacoes[$i]->tags,"QTDIAUTI");
					$dshistor = getByTagName($aplicacoes[$i]->tags,"DSHISTOR");
					$vlaplica = getByTagName($aplicacoes[$i]->tags,"VLAPLICA");
					$nrdocmto = getByTagName($aplicacoes[$i]->tags,"NRDOCMTO");
					$dtvencto = getByTagName($aplicacoes[$i]->tags,"DTVENCTO");
					$indebcre = getByTagName($aplicacoes[$i]->tags,"INDEBCRE");
					$vllanmto = getByTagName($aplicacoes[$i]->tags,"VLLANMTO");
					$sldresga = getByTagName($aplicacoes[$i]->tags,"SLDRESGA");
					$cddresga = getByTagName($aplicacoes[$i]->tags,"CDDRESGA");
					$dtresgat = getByTagName($aplicacoes[$i]->tags,"DTRESGAT");
					$dssitapl = getByTagName($aplicacoes[$i]->tags,"DSSITAPL");
					$txaplmax = getByTagName($aplicacoes[$i]->tags,"TXAPLMAX");
					$txaplmin = getByTagName($aplicacoes[$i]->tags,"TXAPLMIN");
					$cdprodut = getByTagName($aplicacoes[$i]->tags,"CDPRODUT");
					$idtipapl = getByTagName($aplicacoes[$i]->tags,"IDTIPAPL");
					$dtcarenc = getByTagName($aplicacoes[$i]->tags,"DTCARENC");											
					
				?>
					<script type="text/javascript">
					objAplica = new Object();						
					objAplica.dtmvtolt = "<?php echo $dtmvtolt; ?>";
					objAplica.nraplica = "<?php echo $nraplica; ?>";
					objAplica.dshistor = "<?php echo $dshistor; ?>";
					objAplica.nrdocmto = "<?php echo $nrdocmto; ?>";
					objAplica.dtvencto = "<?php echo $dtvencto; ?>";
					objAplica.indebcre = "<?php echo $indebcre; ?>";
					objAplica.vllanmto = "<?php echo $vllanmto; ?>";
					objAplica.sldresga = "<?php echo $sldresga; ?>";
					objAplica.cddresga = "<?php echo $cddresga; ?>";
					objAplica.dtresgat = "<?php echo $dtresgat; ?>";
					objAplica.dssitapl = "<?php echo $dssitapl; ?>";
					objAplica.txaplmax = "<?php echo $txaplmax; ?>";
					objAplica.txaplmin = "<?php echo $txaplmin; ?>";
					objAplica.cdprodut = "<?php echo $cdprodut; ?>";
					objAplica.idtipapl = "<?php echo $idtipapl; ?>";
					objAplica.dtcarenc = "<?php echo $dtcarenc; ?>";
					
					lstAplicacoes[<?php echo $i; ?>] = objAplica;
					
					</script>
				
					<tr id="trAplicacao<?php echo $i; ?>" style="cursor: pointer;" onCLick="selecionaAplicacao(<?php echo $i; ?>,<?php echo $qtAplicacoes; ?>,'<?php echo $nraplica; ?>','<?php echo $idtipapl; ?>');" onFocus="selecionaAplicacao(<?php echo $i; ?>,<?php echo $qtAplicacoes; ?>,'<?php echo $nraplica; ?>','<?php echo $idtipapl; ?>');">
						<td><span><?php echo dataParaTimestamp($dtmvtolt); ?></span>
								  <?php echo $dtmvtolt; ?>
								  <a href="#" id="linkApl<?php echo $i; ?>" style="cursor: default;" onClick="return false;"></a>
						</td>
						<td><span><?php echo $dshistor; ?></span>
								  <?php echo $dshistor; ?>
						</td>
						<td><span><?php echo $qtdiauti; ?></span>
								  <?php echo $qtdiauti; ?>
						</td>
						<td><span><?php echo str_replace(",",".",$vlaplica); ?></span>
								  <?php echo number_format(str_replace(",",".",$vlaplica),2,",","."); ?>
						</td>
						<td><span><?php echo dataParaTimestamp($dtvencto); ?></span>
								  <?php echo $dtvencto; ?>
						</td>
						<td><span><?php echo str_replace(",",".",$vllanmto); ?></span>
								  <?php echo number_format(str_replace(",",".",$vllanmto),2,",","."); ?>
						</td>
						<td><span><?php echo str_replace(",",".",$sldresga); ?></span>
								  <?php echo number_format(str_replace(",",".",$sldresga),2,",","."); ?>
						</td>
						<td><span><?php echo dataParaTimestamp($dtcarenc); ?></span>
								  <?php echo $dtcarenc; ?>
					    </td>
					</tr>
			<? } ?>	
			
			</tbody>
			<? } else{
				?>
				<tbody>
					<tr id="trAplicacao">
						<td></td>
						<td></td>
						<td></td>
						<td></td>
						<td></td>
						<td></td>
						<td></td>
					</tr>
				</tbody>
				<?php
			} ?>	
		</table>
	</div>	

	<ul class="complemento">
		<li>Sit:</li>
		<li id="tdSit"></li>
		<li>Tx.Ctr:</li>
		<li id="tdTxCtr"></li>
		<li>Tx.Min:</li>
		<li id="tdTxMin"></li>
		<li>Resg:</li>
		<li id="tdResg"></li>
		<li>Dt.Resg:</li>
		<li id="tdDtResg"></li>
        <br style="clear: both">
		<li id="VlBloq" class="txtNormalBold" align="left" >Valor Bloq. Judicial:</li>
		<li id="VlBloq"><? echo number_format(str_replace(",",".", $vlbloque),2,",","."); ?></li>
		<li id="Vlblqapl" class="txtNormalBold" align="left" >Valor Bloq. Garantia:</li>
		<li id="Vlblqapl"><? echo number_format(str_replace(",",".", $vlblqapl),2,",","."); ?></li>
		<li id="VlSldCntInvest" style="display: none;"><? echo number_format(str_replace(",",".", $vlsldinv),2,",","."); ?></li>		
		<li>Numero da Aplicacao:</li>
		<li id="tdNrApl"></li>	
	</ul>

	<div id="divBotoes" style="margin-top:5px; margin-bottom :10px; text-align: center;">
	 
		<?php if(!($sitaucaoDaContaCrm == '4' || 
				 $sitaucaoDaContaCrm == '7' || 
				 $sitaucaoDaContaCrm == '8' )){?>

			<a href="#" class="botao" id="btAplicacao" <?php if (!in_array("I",$glbvars["opcoesTela"])) { echo 'style="cursor: default" onClick="return false;"'; } else { echo 'onClick="buscaDadosAplicacao(\'I\');return false;"'; } ?>>Aplica&ccedil;&atilde;o</a>
			
		<?}?>
		
		<a href="#" class="botao" id="btExcluir" <?php if (!in_array("E",$glbvars["opcoesTela"])) { echo 'style="cursor: default" onClick="return false;"'; } else { echo 'onClick="buscaDadosAplicacao(\'E\');return false;"'; } ?>>Excluir</a>
		<a href="#" class="botao" id="btResgate" <?php if (!in_array("R",$glbvars["opcoesTela"])) { echo 'style="cursor: default" onClick="return false;"'; } else { echo 'onClick="acessaOpcaoResgate();return false;"'; } ?>>Resgate</a>
		<a href="#" class="botao" id="btResgateVarias" <?php if (!in_array("R",$glbvars["opcoesTela"])) { echo 'style="cursor: default" onClick="return false;"'; } else { echo 'onClick="acessaOpcaoResgatarVarias();return false;"'; } ?>>Resgatar V&aacute;rias</a>
		<a href="#" class="botao" id="btAcumula" <?php if (!in_array("A",$glbvars["opcoesTela"])) { echo 'style="cursor: default" onClick="return false;"'; } else { echo 'onClick="acessaOpcaoAcumula();return false;"'; } ?>>Acumula</a>
		
		
		<?php 
			// As cooperativas 4 (CONCREDI) e 15 (CREDIMILSUL) não podem realizar o agendamento de aplicações e resgates
			if($glbvars["cdcooper"] != 4 && $glbvars["cdcooper"] != 15) { 
		?>
				<a href="#" class="botao" id="btAgendamento" <?php if (!in_array("G",$glbvars["opcoesTela"])) { echo 'style="cursor: default" onClick="return false;"'; } else { echo 'onClick="acessaOpcaoAgendamento(); return false;"'; } ?>>Agendamento</a>
		<?php 
			}
		?>

		<a href="#" class="botao" id="btImprimir" <?php if (!in_array("M",$glbvars["opcoesTela"])) { echo 'style="cursor: default" onClick="return false;"'; } else { echo 'onClick="exibeParamImpressao(); return false;"'; } ?>>Imprimir</a>
		
	</div>
	
</div>

<div id="divAgendamentoPrincipal" style="margin-top:5px; margin-bottom :10px; text-align: center; display: none;"> </div>