<?
/*!
 * FONTE        : imp_fichacadastral_html.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 08/04/2010 
 * OBJETIVO     : Responsável por apresentar as informações em HTML.
 * ALTERAÇÕES	: 23/07/2014 - Alterado instituição detentora. (Reinert)
 */	 
?>

<? 
	require_once('../../../includes/funcoes.php');
	$registros = $GLOBALS['registros']; 
	$cdcooper = $glbvars['cdcooper'];
	$cdagenci = $glbvars['cdagenci'];	
?>

<html>
	<head>
		<style type="text/css">
			label, div, span, table {
				font-family: monospace, "Courier New" , Courier;
				font-size:9pt;
				text-transform: uppercase;
			}
			label, div, table{margin-left:70px;} 
			#dsdcabec{margin-top:45px;}
			#dstitulo{margin-top:40px;}
			#dssubtit{margin:15px 0px 0px 0px;text-align:center;}
			#dspessoa{margin:40px 0px 25px 0px;text-align:center;}
			#formulario{margin-top:50px;}
			#dsrodape{margin-top:50px;}
			table {width:100%; margin-top:50px;}			
			table tr td{width:50%;vertical-align:top;}
			table tr td label{margin:0px;}
			table tr td div{margin:0px;}
		</style>
	</head>
<body>	
	<div id="dsdcabec"><? echo getByTagName($registros,'dsdcabec') ?></div>
	<div id="dstitulo"><? echo getByTagName($registros,'dstitulo') ?></div>
	<div id="dssubtit"><? echo getByTagName($registros,'dssubtit') ?></div>
	<div id="dspessoa"><? echo getByTagName($registros,'dspessoa') ?></div>
	<div></div>
	<label for="nmrescop"><? echo preencheString('INST. DETENTORA',19,'.'); ?>:</label>
	<span id="nmrescop"><? echo getByTagName($registros,'cdinsdet') ?> - <? echo getByTagName($registros,'nmrescop') ?></span>	
	<br />

	<label for="cdagedet"><? echo preencheString('AGENC. DETENTORA',19,'.'); ?>:</label>
	<span id="cdagedet"><? echo getByTagName($registros,'cdagedet') ?></span>
	<br />

	<label for="cddbanco"><? echo preencheString('INST. DESTINATARIA',19,'.'); ?>:</label>
	<span id="cddbanco"><? echo getByTagName($registros,'cddbanco') ?> - <? echo getByTagName($registros,'nmdbanco') ?></span>
	<br />

	<label for="cdageban"><? echo preencheString('AGENC. DESTINATARIA',19,'.'); ?>:</label>
	<span id="cdageban"><? echo getByTagName($registros,'cdageban') ?> - <? echo getByTagName($registros,'nmageban') ?></span>
	<br />

	<? if (getByTagName($registros,'dspessoa') == 'PESSOA JURIDICA') { ?>
		<label for="nmprimtl"><? echo preencheString('RAZAO SOCIAL',19,'.'); ?>:</label>
		<span id="nmprimtl"><? echo getByTagName($registros,'nmprimtl') ?></span>
		<br />
		<label for="nrcpfcgc"><? echo preencheString('CNPJ',19,'.'); ?>:</label>
		<span id="nrcpfcgc"><? echo getByTagName($registros,'nrcpfcgc') ?></span>
		<br />
	<? } else if ( getByTagName($registros,'dspessoa') == 'PESSOA FISICA' ) { ?>
		<label for="nmprimtl"><? echo preencheString('NOME',19,'.'); ?>:</label>
		<span id="nmprimtl"><? echo getByTagName($registros,'nmprimtl') ?></span>
		<br />
		<label for="nmsegntl"><? echo preencheString('SEGUNDO TITULAR',19,'.'); ?>:</label>
		<span id="nmsegntl"><? echo getByTagName($registros,'nmsegntl') ?></span>
		<br />
		<label for="nrcpfcgc"><? echo preencheString('CPF',19,'.'); ?>:</label>
		<span id="nrcpfcgc"><? echo getByTagName($registros,'nrcpfcgc') ?></span>
		<br />
		<label for="nrcpfstl"><? echo preencheString('CPF SEG. TITULAR',19,'.'); ?>:</label>
		<span id="nrcpfstl"><? echo getByTagName($registros,'nrcpfstl') ?></span>
		<br />
	<? } ?>

	<label for="dtabtcct"><? echo preencheString('ABERTURA DA C/C',19,'.'); ?>:</label>
	<span id="dtabtcct"><? echo getByTagName($registros,'dtabtcct') ?></span>
	<br />

	<label for="dssitdct"><? echo preencheString('SITUACAO C/C',19,'.'); ?>:</label>
	<span id="dssitdct"><? echo getByTagName($registros,'dssitdct') ?></span>
	<br />

	<label for="dsdemiss"><? echo preencheString('DATA ENCERRAMENTO',19,'.'); ?>:</label>
	<span id="dsdemiss"><? echo getByTagName($registros,'dsdemiss') ?></span>
	<div id="dsrodape"><? echo getByTagName($registros,'dsrodape') ?></div>

	<table>
		<tr><td><label for="nmextttl">_________________________</label>
				<div id="nmextttl"><? echo getByTagName($registros,'nmextttl') ?></div></td>
			<td><label for="nmresbr1">_________________________</label>
				<div id="nmresbr1"><? echo getByTagName($registros,'nmresbr1') ?></div>
				<div id="nmresbr2"><? echo getByTagName($registros,'nmresbr2') ?></div></td></tr>
	</table>
</body>
</html>