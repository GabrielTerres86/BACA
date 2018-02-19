package br.coop.cecred.parser;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import net.sf.jasperreports.engine.JRException;
import net.sf.jasperreports.engine.JRField;
import org.apache.commons.beanutils.ConvertUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import com.ximpleware.AutoPilot;
import com.ximpleware.NavException;
import com.ximpleware.VTDGen;
import com.ximpleware.VTDNav;
import com.ximpleware.XPathEvalException;
import com.ximpleware.XPathParseException;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.text.ParseException;
import java.util.Hashtable;
import java.util.Locale;
import java.util.logging.Level;
import java.util.logging.Logger;
import net.sf.jasperreports.engine.util.JRDataUtils;
import org.apache.commons.beanutils.locale.LocaleConvertUtilsBean;

/**
 * Classe que irá sobescrever os recursos para gerar um DataSource a partir de um stream XML.
 * Implementa DTC-XML ao invés de DOM ou SAX para otimizar performance.
 * Realiza CACHE do pool do XPath para otimizar performance.
 * @author Petter - Supero Tecnologia
 * @since Julho/2013
 */
public class WinVTDXMLDataSource implements WinXMLDataSource {

    private static final Log logger = LogFactory.getLog(WinVTDXMLDataSource.class);
    VTDGen vtdGen;
    VTDNav vtdNext;
    AutoPilot autoPi;
    Hashtable apSet = new Hashtable();
    Hashtable valueSet = new Hashtable();
    private Locale locale;
    private LocaleConvertUtilsBean convertBean;

    /**
     * Construtor de classe para implementação a partir do array de bytes.
     * @param aBytes Array de bytes formado pelo XML
     * @param selectExpression XPath de leitura do XML
     * @throws JRException Exceção de erros gerais no JasperReports.
     */
    public WinVTDXMLDataSource(byte[] aBytes, String selectExpression) throws JRException, Exception {
        vtdGen = new VTDGen();
        vtdGen.setDoc(aBytes);
        vtdGen.parse(true);
        vtdNext = vtdGen.getNav();
        autoPi = new AutoPilot(vtdNext);
        autoPi.selectXPath(selectExpression);
    }

    /**
     * Construtor de classe para implementação a partir do stream de entrada do XML
     * @param inputXML Stream de entrada do XML
     * @param selectExpression XPath de leitura do XML
     * @throws JRException Exceção de erros gerais no JasperReports.
     */
    public WinVTDXMLDataSource(InputStream inputXML, String selectExpression) throws JRException, IOException, Exception {
        this(toByteArray(inputXML), selectExpression);
    }

    /**
     * Montar array de bytes a partir do stream de entrada do XML
     * @param inputXML Stream de entrada do XML
     * @return Retorna array de bytes
     */
    private static byte[] toByteArray(InputStream inputXML) throws IOException {
        byte[] xmlByteArray;
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        int readResult;
        byte[] byteBuffer = new byte[1024];
        
        while ((readResult = inputXML.read(byteBuffer)) > -1) {
            baos.write(byteBuffer, 0, readResult);
        }

        xmlByteArray = baos.toByteArray();
        return xmlByteArray;
    }

    /**
     * Override do método de localização do próximo step do XPath
     * @return Retorna positivo em caso de sucesso do AutoPilot
     * @throws JRException Extensão da exceção do JasperReports
     * @see net.sf.jasperreports.engine.JRDataSource#next()
     */
    @Override
    public boolean next() throws JRException {
        try {
            int ind = autoPi.evalXPath();
            if (ind >= 0) {
                return true;
            }
        } catch (Exception e) {
            System.err.print("WinVTDXMLDataSource.next. Ocorreu o erro:  " + e);
        }
        return false;
    }
    
    /**
     * Override do método que captura o valor dos campos do XML.
     * @param jrField Campo do XML
     * @return Retorna o valor do campo
     * @throws JRException Extensão da exceção do JasperReports
     * @see net.sf.jasperreports.engine.JRDataSource#getFieldValue(net.sf.jasperreports.engine.JRField)
     */
    @Override
    public Object getFieldValue(JRField jrField) throws JRException {
        Object valueAsString = getFieldValue(jrField.getDescription());
        Object value = null;
        Class valueClass = jrField.getValueClass();

        if (Object.class != valueClass) {
            if (valueAsString != null) {
                if(String.class == valueClass){
                    value = valueAsString.toString();
                }else if(Double.class == valueClass){
                    try {
                        DecimalFormat dff = (DecimalFormat) DecimalFormat.getInstance();
                        value = Double.valueOf(dff.parse(valueAsString.toString()).toString());
                    } catch (ParseException ex) {;
                        System.err.print("Erro ao executar Double Cast: " + ex);
                    }
                }else{
                    value = ConvertUtils.convert(valueAsString.toString().trim(), valueClass);
                }
            }
        }
        
        return value;
    }
    
    /**
     * Método de busca do valor do campo do XML utilizando buferização.
     * A otimização vai impactar principalmente arquivos XML grandes. Quando executado a partir de "/" irá 
     * controlar para ser executado somente uma vez.
     * @param xpath XPath de pesquisa do XML
     * @return Retorna valor do campo
     * @throws JRException Extensão da exceção do JasperReports
     */
    public Object getFieldValue(String xpath) throws JRException {
        String result = null;

        if (xpath == null || xpath.trim().equals("")) {
            return null;
        }
        
        try {
            vtdNext.push();
            if (xpath.indexOf("/") == 0) {
                result = getConstantValue(xpath);
            }else{
                if (vtdNext.toElement(VTDNav.FIRST_CHILD, xpath)) {
                    int valorCampo = vtdNext.getText();
                    
                    if (valorCampo != -1) {
                        result = vtdNext.toString(valorCampo);
                    }
                    
                    vtdNext.toElement(VTDNav.PARENT);
                }else{
                    AutoPilot subAp = getAutoPilot(xpath);
                    result = getXpathResultValue(subAp);
                }
            }
        } catch (Exception e) {
            result = "error:" + xpath;
            System.err.print("Erro na extração " + xpath + ". Erro: " + e);
        } finally {
            vtdNext.pop();
        }
        
        return result;
    }

    /**
     * Capturar o valor do XPath da iteração atual.
     * @param xpath XPath de pesquisa
     * @return Retorna XPath filho
     */
    private String getFromSubquery(String xpath) throws Exception  {
        String result = null;

        AutoPilot subAp = new AutoPilot(vtdNext);
        subAp.selectXPath(xpath);
        result = getXpathResultValue(subAp);
        
        return result;
    }

    /**
     * Capturar posição atual do AutoPilot.
     * @param subAp AutoPilot filho
     * @return Retorna próxima posição
     * @throws XPathEvalException Exceção para erros no XPath.
     * @throws NavException Exceção para erros na localização do próximo nodo.
     */
    private String getXpathResultValue(AutoPilot subAp) throws XPathEvalException, NavException {
        String result = null;
        subAp.evalXPath();
        
        if (vtdNext.getTokenType(vtdNext.getCurrentIndex()) == VTDNav.TOKEN_ATTR_NAME) {
            result = vtdNext.toString(vtdNext.getAttrVal(vtdNext.toString(vtdNext.getCurrentIndex())));
        } else {
            if (vtdNext.getText() >= 0) {
                result = vtdNext.toString(vtdNext.getText());
            }
        }
        
        subAp.resetXPath();
        return result;
    }

    /**
     * Definição do AutoPilot para otimizar as consultas XPath.
     * @param xpath XPath do arquivo XML
     * @return Retorna AutoPilot filho
     */
    private AutoPilot getAutoPilot(String xpath) throws XPathParseException {
        AutoPilot subAp = null;
        
        if (apSet.get(xpath) == null) {
            subAp = new AutoPilot(vtdNext);

            subAp.selectXPath(xpath);
            apSet.put(xpath, subAp);
        } else {
            Object obj = apSet.get(xpath);
            subAp = (AutoPilot) obj;
        }
        
        return subAp;
    }

    /**
     * Captura valores constantes contidos no XML, é requerido pela interface do JasperReports.
     * @param xpath XPath do arquivo XML
     * @return Retorna busca do XPath
     */
    private String getConstantValue(String xpath) throws Exception {
        String value = null;
        
        if (valueSet.get(xpath) == null) {
            value = getFromSubquery(xpath);
            
            if (value == null) {
                value = "";
            }
            
            valueSet.put(xpath, value);
        } else {
            Object obj = valueSet.get(xpath);
            value = (String) obj;
        }
        
        return value;
    }
    
    /**
     * Método para retornar o local da JVM
     * @return Retorna o local
     */
    public Locale getLocale() {
            return locale;
    }

    /**
     * Define o local para o XML e limpa o bean de conversão.
     * @param locale Local a ser definido
     */
    public void setLocale(Locale locale) {
            this.locale = locale;
            convertBean = null;
    }

    /**
     * Define o local para o XML
     * @param locale Local a ser definido
     */
    public void setLocale(String locale) {
            setLocale(JRDataUtils.getLocale(locale));
    }
}