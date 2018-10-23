var errorMessage = "";

$(function(){
	$('#vlrdobem').maskMoney();
	$('#vlrdobem').val($('#vlrdobem').val()).trigger('mask.maskMoney');
	$('#vlfipbem').maskMoney();
	$('#vlfipbem').val($('#vlfipbem').val()).trigger('mask.maskMoney');		
	intervenienteValidado = false;	
});

function convert_accented_characters(str){
    var conversions = new Object();
    conversions['ae'] = 'ä|æ|ǽ';
    conversions['oe'] = 'ö|œ';
    conversions['ue'] = 'ü';
    conversions['Ae'] = 'Ä';
    conversions['Ue'] = 'Ü';
    conversions['Oe'] = 'Ö';
    conversions['A'] = 'À|Á|Â|Ã|Ä|Å|Ǻ|Ā|Ă|Ą|Ǎ';
    conversions['a'] = 'à|á|â|ã|å|ǻ|ā|ă|ą|ǎ|ª';
    conversions['C'] = 'Ç|Ć|Ĉ|Ċ|Č';
    conversions['c'] = 'ç|ć|ĉ|ċ|č';
    conversions['D'] = 'Ð|Ď|Đ';
    conversions['d'] = 'ð|ď|đ';
    conversions['E'] = 'È|É|Ê|Ë|Ē|Ĕ|Ė|Ę|Ě';
    conversions['e'] = 'è|é|ê|ë|ē|ĕ|ė|ę|ě';
    conversions['G'] = 'Ĝ|Ğ|Ġ|Ģ';
    conversions['g'] = 'ĝ|ğ|ġ|ģ';
    conversions['H'] = 'Ĥ|Ħ';
    conversions['h'] = 'ĥ|ħ';
    conversions['I'] = 'Ì|Í|Î|Ï|Ĩ|Ī|Ĭ|Ǐ|Į|İ';
    conversions['i'] = 'ì|í|î|ï|ĩ|ī|ĭ|ǐ|į|ı';
    conversions['J'] = 'Ĵ';
    conversions['j'] = 'ĵ';
    conversions['K'] = 'Ķ';
    conversions['k'] = 'ķ';
    conversions['L'] = 'Ĺ|Ļ|Ľ|Ŀ|Ł';
    conversions['l'] = 'ĺ|ļ|ľ|ŀ|ł';
    conversions['N'] = 'Ñ|Ń|Ņ|Ň';
    conversions['n'] = 'ñ|ń|ņ|ň|ŉ';
    conversions['O'] = 'Ò|Ó|Ô|Õ|Ō|Ŏ|Ǒ|Ő|Ơ|Ø|Ǿ';
    conversions['o'] = 'ò|ó|ô|õ|ō|ŏ|ǒ|ő|ơ|ø|ǿ|º';
    conversions['R'] = 'Ŕ|Ŗ|Ř';
    conversions['r'] = 'ŕ|ŗ|ř';
    conversions['S'] = 'Ś|Ŝ|Ş|Š';
    conversions['s'] = 'ś|ŝ|ş|š|ſ';
    conversions['T'] = 'Ţ|Ť|Ŧ';
    conversions['t'] = 'ţ|ť|ŧ';
    conversions['U'] = 'Ù|Ú|Û|Ũ|Ū|Ŭ|Ů|Ű|Ų|Ư|Ǔ|Ǖ|Ǘ|Ǚ|Ǜ';
    conversions['u'] = 'ù|ú|û|ũ|ū|ŭ|ů|ű|ų|ư|ǔ|ǖ|ǘ|ǚ|ǜ';
    conversions['Y'] = 'Ý|Ÿ|Ŷ';
    conversions['y'] = 'ý|ÿ|ŷ';
    conversions['W'] = 'Ŵ';
    conversions['w'] = 'ŵ';
    conversions['Z'] = 'Ź|Ż|Ž';
    conversions['z'] = 'ź|ż|ž';
    conversions['AE'] = 'Æ|Ǽ';
    conversions['ss'] = 'ß';
    conversions['IJ'] = 'Ĳ';
    conversions['ij'] = 'ĳ';
    conversions['OE'] = 'Œ';
    conversions['f'] = 'ƒ';

    for(var i in conversions){
        var re = new RegExp(conversions[i],"g");
        str = str.replace(re,i);
    }

    return str;
}

function TrataDados(){
	$('#nrrenava', '#frmTipo').val($('#nrrenava', '#frmTipo').val().replace(".",""));
}
function validaCamposAditiv(){
	var invalidos=0;
	errorMessage = "";
	if ( $('#dsmarbem', '#frmTipo').val() == '-1' || dsmarbem == "") {
		if(!validaCampo('dsmarbemC', '#frmTipo')){invalidos=invalidos+1;}
		if(!validaCampo('dsbemfinC', '#frmTipo')){invalidos=invalidos+1;}
		if(!validaCampo('nrmodbemC', '#frmTipo')){invalidos=invalidos+1;}
	} else {
	if(!validaCampo('dsmarbem', '#frmTipo')){invalidos=invalidos+1;}
	if(!validaCampo('dsbemfin', '#frmTipo')){invalidos=invalidos+1;}
	if(!validaCampo('nrmodbem', '#frmTipo')){invalidos=invalidos+1;}
	}
	if(!validaCampo('dscatbem', '#frmTipo')){invalidos=invalidos+1;}
	if(!validaCampo('dstipbem', '#frmTipo')){invalidos=invalidos+1;}
	if(!validaCampo('nranobem', '#frmTipo')){invalidos=invalidos+1;}	
	if(!validaCampo('vlrdobem', '#frmTipo')){invalidos=invalidos+1;}

	if(!validaCampo('tpchassi', '#frmTipo')){invalidos=invalidos+1;}
	if(!validaCampo('dschassi', '#frmTipo')){invalidos=invalidos+1;}
	if(!validaCampo('dscorbem', '#frmTipo')){invalidos=invalidos+1;}

	if(!$('#ufdplaca').prop( "disabled"))
	{
		if(!validaCampo('ufdplaca', '#frmTipo')){invalidos=invalidos+1;}
		if(!validaCampo('nrdplaca', '#frmTipo')){invalidos=invalidos+1;}
		if(!validaCampo('nrrenava', '#frmTipo')){invalidos=invalidos+1;}
	}
	if(!validaRadio($('input[name=nrbem]'))){invalidos=invalidos+1;}

	if(invalidos>0)
	{
		$("#msgErro").show();
		showError('error','Preencha os seguintes campos obrigatorios:<br/><br/>'+errorMessage ,'Alerta - Aimaro','');
		return false;
	}
	else{
		$("#msgErro").hide();
		return true;
	}
}

function bloqueiaCamposVeiculoZero(valor)
{	
	var renavam =$('#nrrenava');
	var ufPlaca =$('#ufdplaca');
	var nrPlaca =$('#nrdplaca');
	
	if(valor==="ZERO KM") 
	{
		renavam.addClass("campoTelaSemBorda");
		ufPlaca.addClass("campoTelaSemBorda");
		nrPlaca.addClass("campoTelaSemBorda");
		
		renavam.removeClass("campo");
		ufPlaca.removeClass("campo");
		nrPlaca.removeClass("campo");
		
		renavam.val("").prop( "disabled", true );
		ufPlaca.val(null);
		ufPlaca.prop( "disabled", true );
		nrPlaca.val("").prop( "disabled", true );
		removeErroCampo(renavam);
		removeErroCampo(ufPlaca);
		removeErroCampo(nrPlaca);
	}
	else{
		
		renavam.prop( "disabled", false );
		ufPlaca.prop( "disabled", false );
		nrPlaca.prop( "disabled", false );
		
		renavam.addClass("campo");
		ufPlaca.addClass("campo");
		nrPlaca.addClass("campo");
		
		renavam.removeClass("campoTelaSemBorda");
		ufPlaca.removeClass("campoTelaSemBorda");
		nrPlaca.removeClass("campoTelaSemBorda");		
	}
}



function ValidaSubstituicaoBem(operacao, dscatbem, dstipbem, nrmodbem, nranobem, dsbemfin, vlrdobem, tpchassi, dschassi, dscorbem,
								 ufdplaca, nrdplaca, nrrenava, uflicenc, nrcpfcgc, idseqbem, dsmarbem, vlfipbem)
{
	$.ajax({
			type  : 'POST',
			url   : UrlSite + 'telas/aditiv/valida_substitui_bem.php',
			data: {
				operacao	: operacao,
				cddopcao	: cddopcao, // global
				nraditiv	: nraditiv, // global
				cdaditiv	: cdaditiv, // global
				nrdconta	: nrdconta, // global
				nrctremp	: nrctremp, // global
                tpctrato    : tpctrato, // global

				dscatbem    : dscatbem,
				dstipbem	: dstipbem,
				nrmodbem    : nrmodbem,
				nranobem  	: nranobem,
				dsbemfin	: dsbemfin,
				vlrdobem	: vlrdobem,
				tpchassi    : tpchassi,
				dschassi	: dschassi,
				dscorbem	: dscorbem,

				ufdplaca    : ufdplaca,
				nrdplaca	: nrdplaca,
				nrrenava    : nrrenava,
				uflicenc    : uflicenc,
                nrcpfcgc    : nrcpfcgc,
				idseqbem	: idseqbem,
				dsmarbem    : dsmarbem,
				vlfipbem	: vlfipbem,
				
				redirect	: 'script_ajax'
			},
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','estadoInicial();');
			},
			success: function(response) {
				try {
					eval(response);
					//console.log("success valida substitui");
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','estadoInicial();');
				}
			}
		});



}
function SenhaCoordenador(){
	//console.log('senha');
	
	pedeSenhaCoordenador(2,'SubstituiBem();','divRotina');
}
function CancelaSubstituicao()
{
	intervenienteValidado=false;
}
function SubstituiBem(){
	if(intervenienteValidado)
	{
		gravaInterveniente();
	}
	
	var dscatbem = $('#dscatbem', '#frmTipo') .val();	
	var dstipbem = $('#dstipbem', '#frmTipo') .val();
	var dsmarbem = $('#dsmarbem option:selected', '#frmTipo').text(); 
	var dsbemfin =  $('#dsbemfin option:selected', '#frmTipo').text(); // string
	var nrmodbem = $('#nrmodbem option:selected', '#frmTipo').text();
	if ( $('#dsmarbem', '#frmTipo').val() == '-1' || dsmarbem == "") {
		dsmarbem = removeAcentos(removeCaracteresInvalidos($("#dsmarbemC","#frmTipo").val()));
		dsbemfin = removeAcentos(removeCaracteresInvalidos($("#dsbemfinC","#frmTipo").val()));
		nrmodbem = removeAcentos(removeCaracteresInvalidos($("#nrmodbemC","#frmTipo").val()));
	}
	var nranobem = normalizaNumero(  $('#nranobem', '#frmTipo').val()); // inteiro
	var vlrdobem =  $('#vlrdobem', '#frmTipo') .val();
	var vlfipbem =  $('#vlfipbem', '#frmTipo') .val();
	var tpchassi = normalizaNumero(  $('#tpchassi', '#frmTipo').val()); // inteiro
	var dschassi =  $('#dschassi', '#frmTipo') .val(); // string

	var dscorbem =  $('#dscorbem', '#frmTipo') .val(); // string
	var ufdplaca =  $('#ufdplaca', '#frmTipo') .val(); // string
	var nrdplaca =  $('#nrdplaca', '#frmTipo') .val(); // string
	var nrrenava = normalizaNumero(  $('#nrrenava', '#frmTipo').val()); // inteiro
	var uflicenc =  $('#uflicenc option:selected', '#frmTipo').val(); // string
    var nrcpfcgc =  normalizaNumero( $('#nrcpfcgc', '#frmTipo').val()); // inteiro

	var radios = $('input[name=nrbem]');
	var idseqbem = "";
	var cdoperad =1;
	for (var i = 0, length = radios.length; i < length; i++)
	{
		if (radios[i].checked)
		{
			idseqbem = normalizaNumero($.trim(radios[i].value));			
			break;
		}
	}
	vlrdobem = vlrdobem.replace('R$','').replace(/\./g,'').replace(',','.');
	vlfipbem = vlfipbem.replace('R$','').replace(/\./g,'').replace(',','.');

  // Converter caracteres especiais na Marca e Modelo
  dsmarbem = convert_accented_characters(dsmarbem);
  dsbemfin = convert_accented_characters(dsbemfin);

 	$.trim(dscatbem);
	$.trim(dstipbem);
	$.trim(dsmarbem);
	$.trim(nrmodbem);
	$.trim(nranobem);
	$.trim(dsbemfin);
	$.trim(vlrdobem);
	$.trim(vlfipbem);
	$.trim(tpchassi);
	$.trim(dschassi);
	$.trim(dscorbem);
	$.trim(ufdplaca);
	$.trim(nrdplaca);
	$.trim(nrrenava);
	$.trim(uflicenc);
	$.trim(nrcpfcgc);	
	
	$.ajax({
			type  : 'POST',
			url   : UrlSite + 'telas/aditiv/substitui_bem.php',
			data: 
			{						
				nraditiv	: nraditiv, // global
				nrdconta	: nrdconta, // global
				nrctremp	: nrctremp, // global
				tpctrato    : tpctrato, // global
				dscatbem    : dscatbem,
				dstipbem	: dstipbem,
				dsmarbem    : dsmarbem,				
				nrmodbem    : nrmodbem,
				nranobem  	: nranobem,
				dsbemfin	: dsbemfin,
				vlrdobem	: vlrdobem,
				vlfipbem	: vlfipbem,
				tpchassi    : tpchassi,
				dschassi	: dschassi,
				dscorbem	: dscorbem,
				ufdplaca    : ufdplaca,
				nrdplaca	: nrdplaca,
				nrrenava    : nrrenava,
				uflicenc    : uflicenc,
				nrcpfcgc    : nrcpfcgc,
				idseqbem	: idseqbem,
				cdoperad 	: cdoperad,
				redirect	: 'script_ajax'
			},
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','estadoInicial();');
			},
			success: function(response) {
				try {
					eval(response);					
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','estadoInicial();');
				}
			}
		});

	return false;
	
}
$("#nrdplaca").keydown(function(){ 
	 $("#nrdplaca").mask("AAAAAAA");
});

function VerificaPessoa( campo ){
	if ( verificaTipoPessoa( campo ) == 1 ) {
	$('#nrcpfcgc', '#frmTipo').setMask('INTEGER','999.999.999-99','.-','');
} else if( verificaTipoPessoa( campo ) == 2 ) {
		$('#nrcpfcgc', '#frmTipo').setMask('INTEGER','zz.zzz.zzz/zzzz-zz','/.-','');
	} else {
		$('#nrcpfcgc', '#frmTipo').setMask('INTEGER', 'zzzzzzzzzzzzzz','','');
	}
};
function VerificaNumero( evt ){
  var charCode = (evt.which) ? evt.which : event.keyCode
    if (charCode > 31 && (charCode < 48 || charCode > 57))
        return false;
    return true;
}

function busca_uf_pa(nrdconta) {
    var xnrdconta = normalizaNumero(nrdconta);

    $.ajax({
		type  : 'POST',
		url   : UrlSite + 'telas/aditiv/busca_uf_pa.php',
        data: {
            nrdconta: xnrdconta,
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {			
            showError('error', 'Não foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'estadoInicial();');
        },
        success: function(response) {
            eval(response);
        }
    });

}

function formataValor(valor){
    if(valor.length>3||valor.length<6)
    {         
        valor=valor.substring(valor.length-3,0) + '.' + valor.substring(valor.length,valor.length-3);        
    }else if(valor.length > 6||valor.length < 9){
        valor=valor.substring(0,3)+ '.' +
                valor.substring(3,6) + '.'+
                valor.substring(6,valor.length-1);
    }
    return valor;
}

function formataDoc()
{
    var objDoc =$("#nrcpfbem");
    var valObjDoc =objDoc.val();
   
    if(valObjDoc==='0')
    {
        //objDoc.val('xxx.xxx.xxx-xx');
    }
    else if(valObjDoc.length ===11)
    {
        objDoc.val(
                    valObjDoc.substring(0,3) +'.'+
                    valObjDoc.substring(3,6) +'.'+
                    valObjDoc.substring(6,9) +'-'+
                    valObjDoc.substring(9,11)
                    );   
    }
    else if(valObjDoc.length === 14)
    {
        objDoc.val(
                        valObjDoc.substring(0,2) +'.'+
                        valObjDoc.substring(2,5) +'.'+
                        valObjDoc.substring(5,8) +'/'+
                        valObjDoc.substring(8,12) +'-'+
                        valObjDoc.substring(12,14)
                    );
    }
}