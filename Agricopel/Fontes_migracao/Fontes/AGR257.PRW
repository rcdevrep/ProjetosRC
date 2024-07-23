#include "rwmake.ch"
#INCLUDE "COLORS.CH"

User Function AGR257()

PRIVATE oDlg    := Nil, oCon := Nil, oCan := Nil, oPar := Nil

/*
¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
¤¤ ¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥ ¤¤
¤¤ ¥¥+-------------+---------------------------------------------+¥¥ ¤¤
¤¤ ¥¥| Cliente     | Agricopel                                   |¥¥ ¤¤
¤¤ ¥¥+-------------+---------------------------------------------+¥¥ ¤¤
¤¤ ¥¥| DescriCAO   | Atualizaçao cadastro de Clientes/Vendedos   |¥¥ ¤¤
¤¤ ¥¥+-------------+---------------------------------------------+¥¥ ¤¤
¤¤ ¥¥| Programador | Deco                                        |¥¥ ¤¤
¤¤ ¥¥+-------------+---------------------------------------------+¥¥ ¤¤
¤¤ ¥¥| Elaborado em| 09/10/06                                    |¥¥ ¤¤
¤¤ ¥¥+-------------+---------------------------------------------+¥¥ ¤¤
¤¤ ¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥ ¤¤
¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
*/                  

If !MsgYesNO("Programa Aualizara Cadastro Clientes com Vendedor deseja continuar?")
	Return
Endif

cPerg       := "AGX257"   
cPerg := cPerg+SPACE(10-Len(cPerg))

aRegistros  := {}

Aadd(aRegistros,{cPerg,"01","Arquivo Origem ?	","mv_ch1","C",40,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})

AjustaPar(cPerg,aRegistros)

cCliente   := ""
cLoja      := ""
cVend3     := ""

if pergunte(cPerg,.t.)
	Processa( CONVVend() )
endif

Return

Static Function CONVVend()

LOCAL nHandle  := 0, nConta := 0
LOCAL cArquivo := Alltrim(mv_par01), cStr := ""
LOCAL cMsg     := ""

SA1->(DbSetOrder(1))                 // filial+cod+LOJA

If (nHandle := FT_FUSE(AllTrim(cArquivo))) == -1
	Return
EndIf                

ProcRegua(1)
FT_FGOTOP()
While !FT_FEOF()
	
	cStr := FT_FREADLN()

   cMsg := "Gravando Cliente......."+alltrim(Substr(cStr,001,06))
	Incproc(cMsg)	   

                 
   cCliente   := Substr(cStr,001,06)
   cLoja      := Substr(cStr,007,02)
   
   
	cVend3     := alltrim(Substr(cStr,009,06))
		
	dbSelectArea("SA1")                // * Cadastro de Cliente  
	dbSetOrder(1)
	If dbSeek(xFilial("SA1")+cCliente+cLoja)
   
		RecLock("SA1",.F.)
		SA1->A1_VEND3 := cVend3
		MsUnlock("SA1")
		
	EndIf      

   FT_FSKIP()

   nConta := nConta + 1
   
End

FT_FUSE()

msgstop("Quantidade de Clientes importados = "+str(nConta))
fClose(nHandle) // Fecha o arquivo                              


Static Function AjustaPar(cGrupo,aPer)
	lRetu := .T.
	aReg  := {}
	dbSelectArea("SX1")
	If (FCount() == 43)
		For _l := 1 to Len(aPer)
			Aadd(aReg,{cGrupo,aPer[_l,02],aPer[_l,03],""        ,""        ,aPer[_l,4],aPer[_l,5],;
												aPer[_l,06],aPer[_l,07],aPer[_l,8],aPer[_l,9],aPer[_l,10],;
												aPer[_l,11],aPer[_l,12],""       ,""         ,aPer[_l,13],aPer[_l,14],;
												aPer[_l,15],""         ,""       ,aPer[_l,16],aPer[_l,17],aPer[_l,18],"","",;
												aPer[_l,19],aPer[_l,20],aPer[_l,21],""       ,""         ,aPer[_l,22],;
												aPer[_l,23],aPer[_l,24],""         ,""       ,aPer[_l,25],aPer[_l,26],"","","","","",""})
		Next _l
	Elseif (FCount() == 28)
		aReg := aPer
	Endif
	
	dbSelectArea("SX1")
	For _l := 1 to Len(aReg)
		If !dbSeek(cGrupo+StrZero(_l,02,00))
			RecLock("SX1",.T.)
			For _m := 1 to FCount()
				FieldPut(_m,aReg[_l,_m])
			Next _m
			MsUnlock("SX1")
		Elseif Alltrim(aReg[_l,3]) <> Alltrim(SX1->X1_PERGUNT)
			RecLock("SX1",.F.)
			For _k := 1 to FCount()
				FieldPut(_k,aReg[_l,_k])
			Next _k
			MsUnlock("SX1")
		Endif
	Next _l
	
Return lRetu
