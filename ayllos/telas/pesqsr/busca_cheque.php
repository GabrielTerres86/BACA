<?
/*!
 * FONTE        : busca_cheque.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)					Última alteração: 24/06/2016
 * DATA CRIAÇÃO : 11/01/2013
 * OBJETIVO     : Rotina para buscar cheques - PESQDP
 * --------------
 * ALTERAÇÕES   : 19/08/2015 - Retirar campo secao (Gabriel-RKAM)
					
			      24/062016 - Ajustes referente a homologação da tela para liberação 
                              (Adriano - SD 412556).
 * --------------
 *
 * --------------
 */
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();

	// Recebe a operação que está sendo realizada
	$cddopcao   = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ;

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	$dtmvtolt   = (isset($_POST['dtmvtolt'])) ? $_POST['dtmvtolt'] : '' ;
	$cdagenci	= (isset($_POST['cdagenci'])) ? $_POST['cdagenci'] : '' ;
	$cdbccxlt	= (isset($_POST['cdbccxlt'])) ? $_POST['cdbccxlt'] : 0  ;
	$nrdolote	= (isset($_POST['nrdolote'])) ? $_POST['nrdolote'] : 0  ;
	$nrdconta	= (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0  ;
	$nrdocmto	= (isset($_POST['nrdocmto'])) ? $_POST['nrdocmto'] : '' ;
	$nrdctabb	= (isset($_POST['nrdctabb'])) ? $_POST['nrdctabb'] : '' ;
	$cdbaninf	= (isset($_POST['cdbaninf'])) ? $_POST['cdbaninf'] : '' ;
	$vllanmto	= (isset($_POST['vllanmto'])) ? $_POST['vllanmto'] : '' ;
	$nmprimtl	= (isset($_POST['nmprimtl'])) ? $_POST['nmprimtl'] : '' ;
	$dsagenci	= (isset($_POST['dsagenci'])) ? $_POST['dsagenci'] : 0  ;
	$cdturnos	= (isset($_POST['cdturnos'])) ? $_POST['cdturnos'] : 0  ;
	$nrfonemp	= (isset($_POST['nrfonemp'])) ? $_POST['nrfonemp'] : '' ;
	$nrramemp	= (isset($_POST['nrramemp'])) ? $_POST['nrramemp'] : '' ;
	$cdbanchq	= (isset($_POST['cdbanchq'])) ? $_POST['cdbanchq'] : '' ;
	$cdcmpchq	= (isset($_POST['cdcmpchq'])) ? $_POST['cdcmpchq'] : '' ;
	$nrlotchq	= (isset($_POST['nrlotchq'])) ? $_POST['nrlotchq'] : '' ;
	$sqlotchq	= (isset($_POST['sqlotchq'])) ? $_POST['sqlotchq'] : 0  ;
	$nrctachq	= (isset($_POST['nrctachq'])) ? $_POST['nrctachq'] : 0  ;
	
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0160.p</Bo>';
	$xml .= '		<Proc>Busca_Dados</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>' . $glbvars['cdcooper'] . '</cdcooper>';
	$xml .= '		<cdagenci>' . $glbvars['cdagenci'] . '</cdagenci>';
	$xml .= '		<nrdcaixa>' . $glbvars['nrdcaixa'] . '</nrdcaixa>';
	$xml .= '		<cdoperad>' . $glbvars['cdoperad'] . '</cdoperad>';
	$xml .= '		<nmdatela>' . $glbvars['nmdatela'] . '</nmdatela>';
	$xml .= '		<idorigem>' . $glbvars['idorigem'] . '</idorigem>';
	$xml .= '       <dtmvtolt>' . $glbvars['dtmvtolt'] . '</dtmvtolt>';
	$xml .= '       <dtmvtola>' . $dtmvtolt . '</dtmvtola>';
	$xml .= '       <cddopcao>' . $cddopcao . '</cddopcao>';
	$xml .= '       <nrdocmto>' . $nrdocmto . '</nrdocmto>';
	$xml .= '       <nrdctabb>' . $nrdctabb . '</nrdctabb>';
	$xml .= '       <cdbaninf>' . $cdbaninf . '</cdbaninf>';
	$xml .= '       <nrdconta>' . $nrdconta . '</nrdconta>';
	$xml .= '       <cdbccxlt>' . $cdbccxlt . '</cdbccxlt>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	$xmlResult = getDataXML($xml);

	$xmlObjeto = getObjectXML($xmlResult);

	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {

		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo	= $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];		
		
		if ($nmdcampo == 'nrdconta') { 
			$nmdcampo = 'nrdconta';			             
		}

		if (!empty($nmdcampo)) { 
			$mtdErro = " btnVoltar('2');focaCampoErro('" . $nmdcampo . "','frmFiltro'); "; 
		}else{
			 $mtdErro = "btnVoltar('2');"; 
		}
		
		exibirErro('error',$msgErro,'Alerta - Ayllos',$mtdErro,false);		
	}

	if ($cddopcao == "C") {
		$registros  = $xmlObjeto->roottag->tags[0]->tags;
		$anteriores = $xmlObjeto->roottag->tags[1]->tags;

		$qtregist = count($anteriores);

		include ('tab_cheque.php');

		?>
		<script text="text/javascript">
			$('#nrdctabb','#frmFiltro').val('<?php echo mascara(getByTagName($registros[0]->tags,'nrdctabb'),'#.###.###.#')?>');
			formataTabela();
		</script>
		<?

	} else if ($cddopcao == "D") {
	
		$registros  = $xmlObjeto->roottag->tags[0]->tags;
		
		?>
		<script text="text/javascript">
			$('#nrdocmto','#frmFiltro').val('<?php echo getByTagName($registros[0]->tags,'nrdocmto')?>');
			$('#nrdctabb','#frmFiltro').val('<?php echo getByTagName($registros[0]->tags,'nrdctabb')?>');
			$('#cdbaninf','#frmFiltro').val('<?php echo getByTagName($registros[0]->tags,'cdbaninf')?>');
			$('#nrdctabb','#frmFiltro').val('<?php
			echo mascara((in_array(getByTagName($registros[0]->tags,'cdbccxlt'),array(756,85))) ?
							getByTagName($registros[0]->tags,'nrdctabb') : getByTagName($registros[0]->tags,'nrdctabx'),'#.###.###.#');?>');
		    
		</script>
		<?
				
	}
		
	?>
	<script text="text/javascript">

		$('#dtmvtolt','#frmFiltro').val('<?php echo getByTagName($registros[0]->tags,'dtmvtolt')?>');
		$('#nrdconta','#frmFiltro').val('<?php echo mascara(getByTagName($registros[0]->tags,'nrdconta'),'####.###.#')?>');    
		$('#cdbccxlt','#frmFiltro').val('<?php echo getByTagName($registros[0]->tags,'cdbccxlt')?>');
		$('#nrdolote','#frmFiltro').val('<?php echo mascara(getByTagName($registros[0]->tags,'nrdolote'),'###.###')?>');
		$('#cdagenci','#frmFiltro').val('<?php echo getByTagName($registros[0]->tags,'cdagenci')?>');
		$('#vllanmto','#frmFiltro').val('<?php echo formataMoeda(getByTagName($registros[0]->tags,'vllanmto'))?>');	
		$('#nrseqimp','#frmFiltro').val('<?php echo getByTagName($registros[0]->tags,'nrseqimp')?>');
		$('#cdpesqbb','#frmFiltro').val('<?php echo getByTagName($registros[0]->tags,'cdpesqbb')?>');
		$('#vldoipmf','#frmFiltro').val('<?php echo formataMoeda(getByTagName($registros[0]->tags,'vldoipmf'))?>');
		$('#cdbanchq','#frmFiltro').val('<?php echo getByTagName($registros[0]->tags,'cdbanchq')?>');
		$('#cdagechq','#frmFiltro').val('<?php echo getByTagName($registros[0]->tags,'cdagechq')?>');
		$('#nrctachq','#frmFiltro').val('<?php echo mascara(getByTagName($registros[0]->tags,'nrctachq'),'############')?>');
		$('#nmprimtl','#frmFiltro').val('<?php echo getByTagName($registros[0]->tags,'nmprimtl')?>');
		$('#dsagenci','#frmFiltro').val('<?php echo getByTagName($registros[0]->tags,'dsagenci')?>');
		$('#cdturnos','#frmFiltro').val('<?php echo getByTagName($registros[0]->tags,'cdturnos')?>');
		$('#nrfonemp','#frmFiltro').val('<?php echo getByTagName($registros[0]->tags,'nrfonemp')?>');
		$('#nrramemp','#frmFiltro').val('<?php echo getByTagName($registros[0]->tags,'nrramemp')?>');
		$('#cdcmpchq','#frmFiltro').val('<?php echo getByTagName($registros[0]->tags,'cdcmpchq')?>');
		$('#sqlotchq','#frmFiltro').val('<?php echo getByTagName($registros[0]->tags,'sqlotchq')?>');
		$('#nrlotchq','#frmFiltro').val('<?php echo getByTagName($registros[0]->tags,'nrlotchq')?>');	
		
		$('#divBotoes','#divTela').css({'display':'block'});
		$('#divBotoesConsulta','#divTela').css({'display':'none'});
							
	    $('#btVoltar','#divBotoes').focus();

	</script>
	<?