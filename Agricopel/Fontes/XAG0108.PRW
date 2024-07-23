#INCLUDE "TOTVS.CH" 
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"


WSRESTFUL DUPLICATAS DESCRIPTION "DUPLICATAS"

WSMETHOD GET DESCRIPTION "" WSSYNTAX ""

END WSRESTFUL

// O metodo GET nao precisa necessariamente receber parametros de querystring, por exemplo:
// WSMETHOD GET WSSERVICE sample
WSMETHOD GET WSSERVICE DUPLICATAS

// define o tipo de retorno do método
    ::SetContentType("application/json")

    if !(SELECT("SM0") > 0 )
        cLog := "Nao foi possivel preparar o Ambiente no Serviço KITS fonte ARCOW14."
        RpcSetEnv('01','01')
    endif

    cQuery := " SELECT * FROM CAP_DUPLICATAS "

    IF Select("T01") > 0
        T01->(DbCloseArea())
    endif

    TcQuery cQuery new Alias T01
   
    ::SetResponse('[')

    IF T01->(EOF())
        ::SetResponse(']')
    ENDIF
    

    WHILE !T01->(EOF())

        ::SetResponse('{')
        ::SetResponse('"PREF": "'						+  EncodeUTF8(T01->PREF) 					+'",')
        ::SetResponse('"NUMERO": "'				        +  EncodeUTF8(AllTrim(T01->NUMERO)) 		+'",')
        ::SetResponse('"PARCELA": "'					+  EncodeUTF8(AllTrim(T01->PARCELA)) 		+'",')
        ::SetResponse('"TIPO": "'				        +  EncodeUTF8(AllTrim(T01->TIPO)) 			+'",')
        ::SetResponse('"COD. FORN": "'					+ EncodeUTF8(T01->COD_FORN)		        +'",')
        ::SetResponse('"RAZAO SOCIAL": "'				+ EncodeUTF8(AllTrim(T01->RAZAO_SOCIAL))	+'",')
        ::SetResponse('"NOME FANTASIA": "'				+ EncodeUTF8(AllTrim(T01->NOME_FANTASIA))	+'",')
        ::SetResponse('"EMISSAO": "'					+ EncodeUTF8(AllTrim(T01->EMISSAO)) 		+'",')
        ::SetResponse('"VENCIMENTO": "'			        + EncodeUTF8(AllTrim(T01->VENCIMENTO))		+'",')
        ::SetResponse('"VALOR": "'	            		+ cValToChar(T01->VALOR )					+'",')
        ::SetResponse('"PORTADOR": "'			        + EncodeUTF8(AllTrim(T01->PORTADOR))		+'",')
        
        T01->(DbSkip())
    
        If !T01->(EOF())
            ::SetResponse('},')
        ElseIf T01->(EOF())
            ::SetResponse('}]')
        EndIf
    EndDo

    T01->(DbCloseArea())

Return .T.
