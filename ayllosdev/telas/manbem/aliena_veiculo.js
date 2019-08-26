$(function(){
	$('#vlrdobem').maskMoney();
	$('#vlrdobem').val($('#vlrdobem').val()).trigger('mask.maskMoney');
	$('#vlfipbem').maskMoney();
	$('#vlfipbem').val($('#vlfipbem').val()).trigger('mask.maskMoney');		
});

function TrataDados(){
	$('#nrrenava', '#frmTipo').val($('#nrrenava', '#frmTipo').val().replace(".",""));
}
function validaCamposAditiv(){
	var invalidos=0;
	if(!validaCampo($('#dscatbem', '#frmTipo'))){invalidos=invalidos+1;}
	if(!validaCampo($('#dstipbem', '#frmTipo'))){invalidos=invalidos+1;}
	if(!validaCampo($('#tpchassi', '#frmTipo'))){invalidos=invalidos+1;}

	if(!$('#ufdplaca').prop( "disabled"))
	{
		if(!validaCampo($('#ufdplaca', '#frmTipo'))){invalidos=invalidos+1;}
		if(!validaCampo($('#nrrenava', '#frmTipo'))){invalidos=invalidos+1;}
		if(!validaCampo($('#nrdplaca', '#frmTipo'))){invalidos=invalidos+1;}
	}
	if(!validaCampo($('#dsbemfin', '#frmTipo'))){invalidos=invalidos+1;}
	if(!validaCampo($('#vlfipbem', '#frmTipo'))){invalidos=invalidos+1;}
	if(!validaCampo($('#vlrdobem', '#frmTipo'))){invalidos=invalidos+1;}

	if(!validaCampo($('#dschassi', '#frmTipo'))){invalidos=invalidos+1;}
	if(!validaCampo($('#dscorbem', '#frmTipo'))){invalidos=invalidos+1;}
	if(!validaCampo($('#dsmarbem', '#frmTipo'))){invalidos=invalidos+1;}
	if(!validaCampo($('#nrmodbem', '#frmTipo'))){invalidos=invalidos+1;}
	if(!validaCampo($('#nranobem', '#frmTipo'))){invalidos=invalidos+1;}	
	if(!validaRadio($('input[name=nrbem]'))){invalidos=invalidos+1;}


	if(invalidos>0)
	{
		$("#msgErro").show();
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
	}
}
function validaCampo(obj){
	var value = obj.val();	
	var valido =true;
	
	if(value===null||value==="")
	{
		addErroCampo(obj);	
		valido =false;
	}
	else{
		removeErroCampo(obj);		
	}
	return valido;
}
function removeErroCampo(obj)
{
	var name =obj.attr('name');		
	var label =$("label[for='"+name+"']");
	if(obj.hasClass('errorInput'))
	{
		obj.removeClass('errorInput');		
		label.text( label.text().replace("* ",""));
		label.removeClass('errorLabel');
	}
}
function addErroCampo(obj){
	var name =obj.attr('name');		
	var label =$("label[for='"+name+"']");
	if(!obj.hasClass('errorInput'))
	{
		obj.addClass('errorInput');
		label.text( "* "+label.text());
		label.addClass('errorLabel');
	}	
}
function validaRadio(obj)
{
	var radios = obj;
	var check=false;
	for (var i = 0, length = radios.length; i < length; i++)
	{
		if (radios[i].checked)
		{
			check=true;
		}
	}

	if(!check)
	{
		$('.table_alie_veiculo').addClass('errorInput');
		return false;
	}
	else {		
		$('.table_alie_veiculo').removeClass('errorInput');
		return true;
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
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
			},
			success: function(response) {
				try {
					eval(response);
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				}
			}
		});



}
function SenhaCoordenador(){
	pedeSenhaCoordenador(2,'SubstituiBem();','divRotina');
}
function CancelaSubstituicao(){
}
function SubstituiBem(){
	
	var dscatbem = $('#dscatbem', '#frmTipo') .val();	
	var dstipbem = $('#dstipbem', '#frmTipo') .val();
	var dsmarbem =  $('#dsmarbem option:selected', '#frmTipo').text(); 
	var nrmodbem = $('#nranobem option:selected', '#frmTipo').text();
	var nranobem = normalizaNumero(  $('#nranobem', '#frmTipo').val()); // inteiro
	var dsbemfin =  $('#dsbemfin option:selected', '#frmTipo').text(); // string
	var vlrdobem =  $('#vlrdobem', '#frmTipo') .val();
	var vlfipbem =  $('#vlfipbem', '#frmTipo') .val();
	var tpchassi = normalizaNumero(  $('#tpchassi', '#frmTipo').val()); // inteiro
	var dschassi =  $('#dschassi', '#frmTipo') .val(); // string

	var dscorbem =  $('#dscorbem', '#frmTipo') .val();; // string
	var ufdplaca =  $('#ufdplaca', '#frmTipo') .val(); // string
	var nrdplaca =  $('#nrdplaca', '#frmTipo') .val(); // string
	var nrrenava = normalizaNumero(  $('#nrrenava', '#frmTipo').val()); // inteiro
	var uflicenc =  $('#uflicenc', '#frmTipo').val(); // string
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
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
			},
			success: function(response) {
				try {
					eval(response);					
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				}
			}
		});

	return false;
	
}
$("#nrdplaca").keydown(function(){ 
	 $("#nrdplaca").mask("AAA-9999");
});

function VerificaPessoa( campo ){
	if ( verificaTipoPessoa( campo ) == 1 ) {
	$('#nrcpfcgc', '#frmTipo').setMask('INTEGER','999.999.999-99','.-','');
} else if( verificaTipoPessoa( campo ) == 2 ) {
		$('#nrcpfcgc', '#frmTipo').setMask('INTEGER','z.zzz.zzz/zzzz-zz','/.-','');
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
            showError('error', 'Não foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
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