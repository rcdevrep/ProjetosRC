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

//ExecBlock("AGRFORM",.F.,.F.)         
User Function AGRFORM()

Local _Area    := Alias()
Local _Ordem   := IndexOrd()
Local _Reg     := Recno() 
Local _nICMPad := AllTrim(GetMV("MV_ICMPAD")) // ICMS Padrao 
Local _cCdProd := SB1->B1_COD                 // Codigo do Produto   
Local _nPICMS  := SB1->B1_PICM                // Percentual de ICMS do Produto.  
Local _cTesS   := SB1->B1_TS                  // TES padrao para nota de saída   
Local _cRet    := " "

If  Posicione("SF4",1,xFilial("SF4")+_cTesS,"F4_ICM") == "S" .AND. _nPICMS <> 0 
 _cRet:=  _nPICMS
Else 
 _cRet:= _nICMPad
EndIf 

Return(_cRet)
