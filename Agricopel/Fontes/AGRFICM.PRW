#INCLUDE "rwmake.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "Protheus.ch"

/*/
=============================================================
Programa     :
Autor        : João Edenilson Lopes
Data         : 20/07/2016
Alterado por :
Data         :
-------------------------------------------------------------
Descricao    : FORMACAO PRECOS  -  AGRICOPEL
Módulo (Uso) : SIGAEST
=============================================================
/*/

//ExecBlock("AGRFICM",.F.,.F.)
User Function AGRFICM()

Local _Area     := Alias()
Local _Ordem    := IndexOrd()
Local _Reg      := Recno()
Local _nICMPad  := GetMV("MV_ICMPAD")   // ICMS Padrao
Local _cCdProd  := SB1->B1_COD          // Codigo do Produto
Local _nPICMS   := SB1->B1_PICM         // Percentual de ICMS do Produto.
Local _cTesS    := SB1->B1_TS           // TES padrao para nota de saída
Local _cTipo    := SB1->B1_TIPO         // Tipo do produto 
Local _cRet     := " "
Local _cCICMS   := Posicione("SF4",1,xFilial("SF4")+_cTesS,"F4_ICM")   // Se Calcula ICMS o TES
// 1=Diferido;2=Não Diferido;3=Diferimento de Redução;4=Diferimento Incentivo
Local _cICMDIF  := Posicione("SF4",1,xFilial("SF4")+_cTesS,"F4_ICMSDIF")  // Se o Tes possui Icms diferido.
Local _nPICMDIF := Posicione("SF4",1,xFilial("SF4")+_cTesS,"F4_PICMDIF")  // % de Icms diferido.
Local _cProd16   := SB1->B1_PROC   

If  _cCICMS == "S" .AND. _nPICMS <> 0
   // Se ICMS possui diferimento, reduz a base de calculo.
   If _cICMDIF =='3'
      _cRet := ROUND(_nPICMS -(_nPICMS *(_nPICMDIF/100)),2)
   Else
      _cRet :=  _nPICMS
   Endif
	
ElseIf  _cCICMS == "S"
   // Se ICMS possui diferimento, reduz a base de calculo.
   If _cICMDIF =='3'
      _cRet := ROUND(_nICMPad -(_nICMPad *(_nPICMDIF/100)),2)
   Else
      _cRet := _nICMPad
   Endif
Else
   //_cRet  := " "
   _cRet  := 0
EndIf

Return(_cRet)