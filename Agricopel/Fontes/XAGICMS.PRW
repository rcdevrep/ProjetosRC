#INCLUDE "rwmake.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "Protheus.ch"

//----------------------------------------------------------------------------------------------------------------------------------------//
/*/{Protheus.doc} XAGICMS
Esta rotina calcula o % do ICMS para o produto
Criado para ser usado na rotina TMKR03
Copiado cálculo da rotina AGRFICM.PRW
@type function
@author Leandro F Silveira
@since 14/06/2021
@version 1.0
@param aParam, array, parametros passados pelo schedule 
       aParam[1], caracter, empresa associada ao agendamento da rotina 
       aParam[2], caracter, filial associada ao agendamento da rotina 
       aParam[3], caracter, usuário associado ao agendamento
       aParam[4], caracter, id do agendamento
@return nenhum
@see http://tdn.totvs.com/pages/releaseview.action?pageId=6089284
@obs
/*/
//----------------------------------------------------------------------------------------------------------------------------------------//
User Function XAGICMS(_cCodSB1, _cCodSF4)

	Local _nICMPad   := GetMV("MV_ICMPAD")   // ICMS Padrao
	Local _nPICMS    := 0 // SB1->B1_PICM         // Percentual de ICMS do Produto.
	Local _nRet      := 0
	Local _cICMDIF   := "" // Posicione("SF4",1,xFilial("SF4")+_cTesS,"F4_ICMSDIF")  // Se o Tes possui Icms diferido.
	Local _nPICMDIF  := 0  // Posicione("SF4",1,xFilial("SF4")+_cTesS,"F4_PICMDIF")  // % de Icms diferido.
   Local _cAliasSB1 := ""
   Local _cAliasSF4 := ""

	Local _cCICMS    := "" // Posicione("SF4",1,xFilial("SF4")+_cTesS,"F4_ICM")   // Se Calcula ICMS o TES
   // 1=Diferido;2=Não Diferido;3=Diferimento de Redução;4=Diferimento Incentivo

	Default _cCodSF4 := ""

   _cAliasSB1 := GetSB1(_cCodSB1)

   If (Empty(_cCodSF4))
      _cCodSF4 := (_cAliasSB1)->B1_TS
   EndIf

   _cAliasSF4 := GetSF4(_cCodSF4)

   _nPICMS   := (_cAliasSB1)->B1_PICM
   _cICMDIF  := (_cAliasSF4)->F4_ICMSDIF
   _nPICMDIF := (_cAliasSF4)->F4_PICMDIF
   _cCICMS   := (_cAliasSF4)->F4_ICM

	If (_cCICMS == "S" .And. _nPICMS <> 0)
		// Se ICMS possui diferimento, reduz a base de calculo.
		If (_cICMDIF == '3')
			_nRet := ROUND(_nPICMS -(_nPICMS *(_nPICMDIF/100)),2)
		Else
			_nRet := _nPICMS
		Endif

	ElseIf (_cCICMS == "S")
		// Se ICMS possui diferimento, reduz a base de calculo.
		If (_cICMDIF =='3')
			_nRet := ROUND(_nICMPad -(_nICMPad *(_nPICMDIF/100)),2)
		Else
			_nRet := _nICMPad
		Endif
	Else
		_nRet  := 0
	EndIf

   (_cAliasSB1)->(DbCloseArea())
   (_cAliasSF4)->(DbCloseArea())

Return(_nRet)

Static Function GetSB1(_cCodSB1)

   Local _cQuery := ""
   Local _cRet   := ""

   _cQuery += " SELECT B1_PICM, B1_TS "
   _cQuery += " FROM " + RetSQLName("SB1") + " SB1 (NOLOCK) "
   _cQuery += " WHERE B1_FILIAL = '" + FwFilial("SB1") + "'"
   _cQuery += " AND   B1_COD = '" + _cCodSB1 + "'"

   _cRet := MpSysOpenQuery(_cQuery)

Return(_cRet)

Static Function GetSF4(_cCodSF4)

   Local _cQuery := ""
   Local _cRet   := ""

   _cQuery += " SELECT F4_ICMSDIF, F4_PICMDIF, F4_ICM "
   _cQuery += " FROM " + RetSQLName("SF4") + " SF4 (NOLOCK) "
   _cQuery += " WHERE F4_FILIAL = '" + FwFilial("SF4") + "'"
   _cQuery += " AND   F4_CODIGO = '" + _cCodSF4 + "'"

   _cRet := MpSysOpenQuery(_cQuery)

Return(_cRet)
