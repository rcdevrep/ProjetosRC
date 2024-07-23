#INCLUDE 'TOTVS.CH'
#INCLUDE 'TOPCONN.CH'

/*/{Protheus.doc} XAG0089
Validação de Faixa de Nosso Numero (DA3_ZZNNEM) para Venda embarcada
@author Leandro Spiller
@since 01/07/2022
@version 1.0
/*/
User Function XAG0089()         
   
    Local cValAtual := ''
    Local nRecno    := 0 
    Local cQuery    := ''
    Local lRet      := .T.
    Local cAlias    := "XAG0089"


    nRecno := DA3->(recno())
    cValAtual := &(ReadVar())

    cQuery += " SELECT DA3_COD,DA3_DESC,SUBSTRING(DA3_ZZNNEM,1,6) AS FAIXA FROM "+RetSqlname('DA3')+"(NOLOCK) "
    cQuery += " WHERE DA3_FILIAL = '"+xFilial('DA3')+"' AND DA3_ZZNNEM <> ''  "
    cQuery += " AND SUBSTRING(DA3_ZZNNEM,1,6) = '"+Substr(M->DA3_ZZNNEM,1,6) + "' AND D_E_L_E_T_ ='' "
    
    If ALTERA 
        cQuery += " AND R_E_C_N_O_ <> "+Alltrim(Str(nRecno))+ " "
    Endif 

    If Select(cAlias) <> 0
  		dbSelectArea(cAlias)
   		(cAlias)->(dbclosearea())
  	Endif  

	TCQuery cQuery NEW ALIAS (cAlias)

    If (cAlias)->(!eof())
        MsgAlert(" Faixa de Nosso Numero("+(cAlias)->FAIXA+") já utilizada no veículo: "+(cAlias)->DA3_COD + "-"+ Alltrim((cAlias)->DA3_DESC)+", Verifique!","Atenção")
        lRet := .F.
    Endif 

    If Select(cAlias) <> 0
  		dbSelectArea(cAlias)
   		(cAlias)->(dbclosearea())
  	Endif  
    
   Return lRet
