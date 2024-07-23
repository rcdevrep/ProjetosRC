#include "rwmake.ch" 
#Include "Font.ch"
#Include "Colors.ch" 
#Include "cheque.ch"

User Function AGR155()


xcCMC7     := Space(35)
xcTipo1    := Space(03)
xcBanco    := Space(03)
xcAgencia  := Space(05)
xcConta    := Space(10)
xcCheque   := Space(06)
xcDigito1  := Space(01)
xcDigito2  := Space(01)
xcDigito3  := Space(01)
xcComp     := Space(03) 
xcDtVenc   := CToD("  /  /  ")
xcVlCheque := 0
xcVlJuros  := 0
xlReturn   := .f.
xlCMC7     := .f.
xxEscolha  := .f.
xxEscolha1 := .f.
xoFnt      := nil
xcPrefixo  := Alltrim(SM0->M0_CODFIL)+'1'
xcTipo1    := 'CH'
Private xoV1, xoV2, xoV3, xoV4
xcTipo     := 'Leitora'
xlFaz      := .f.
DEFINE FONT oFnt  NAME "Arial" SIZE 10,13.5 BOLD
DEFINE FONT oFnt1 NAME "Arial" SIZE 10,13.5 BOLD
DEFINE FONT oFnt2 NAME "Arial" SIZE 08,11


_NumCH := 1
xcVlCheque := 0
xTotCheque := 0

While .T.
   xcCMC7     := Space(35)
   xcBanco    := Space(03)
   xcAgencia  := Space(05)
   xcConta    := Space(10)
   xcCheque   := Space(06)
   xcDigito1  := Space(01)
   xcDigito2  := Space(01)
   xcDigito3  := Space(01)
   xcComp     := Space(03)
//   xcDtVenc   := CToD("  /  /  ")
   xcDtVenc   := dDataBase
   xcVlCheque := 0
   xcVlJuros  := 0

	If GetValChq()
		If xcVlCheque > 0
			If _NumCH == 1
//				aCols[1,1] := "CHQ"  
				aCols[1,1] := xcPrefixo
				aCols[1,2] := xcTipo1
				aCols[1,3] := xcCheque
				aCols[1,4] := xcBanco
				aCols[1,5] := xcAgencia
				aCols[1,6] := xcVlCheque
				aCols[1,7] := xcConta
				aCols[1,8] := xcDtVenc
				aCols[1,9] := xcCMC7
				aCols[1,10] := .f.
				n := 1
				_NumCH++
			Else
				If aScan(aCols,{|x| AllTrim(x[2])==AllTrim(xcBanco)   }) = 0 .or. ;
					aScan(aCols,{|x| AllTrim(x[5])==AllTrim(xcAgencia) }) = 0 .or. ;
					aScan(aCols,{|x| AllTrim(x[7])==AllTrim(xcConta)   }) = 0 .or. ;
					aScan(aCols,{|x| AllTrim(x[3])==AllTrim(xcCheque)  }) = 0               
//					Aadd(aCols,{"CHQ",xcBanco,xcAgencia,xcConta,xcCheque,xcDtVenc,xcVlCheque,0,0,xcVlCheque,.F.})
					Aadd(aCols,{xcPrefixo,xcTipo1,xcCheque,xcBanco,xcAgencia,xcVlCheque,xcConta,xcDtVenc,xcCMC7,.F.})
					_NumCH++
					n++
				Else
					MsgBox("Cheque ja Incluido ! Desprezado.","Atencao","STOP")
					_NumCH--
					n--
				Endif
			EndIf
		Endif
	Endif
	xTotCheque := xTotCheque + xcVlCheque
	If !MsgBox("Deseja incluir mais cheques?","Liquidacao","YESNO")
	   MsgStop("Total dos Cheques incluidos no lote: "+Str(xTotCheque))
		Exit
	EndIf
EndDo

n := Len(aCols)
Return(NIL)

**********************************************************
Static Function GetValChq()

DEFINE FONT oFnt  NAME "Arial" SIZE 10,15.5 BOLD
DEFINE FONT oFnt1 NAME "Arial" SIZE 08,09.5 BOLD

DEFINE MSDIALOG oDlgChq TITLE OemToAnsi("Inclusão de Cheques Para Compensação") FROM 01,01 TO 210,725 PIXEL


@ 07,014 SAY xoV3 var OemToAnsi("Venc.Cheque:") of oDlgchq FONT oFnt2 PIXEL SIZE 050,010 COLOR CLR_BLUE
@ 07,060 Get xcDtVenc Size 040,010 object xoDtVenc

@ 07,120 SAY xoV4 var OemToAnsi("Valor: ") of oDlgchq FONT oFnt2 PIXEL SIZE 050,010 COLOR CLR_BLUE
@ 07,146 Get xcVlCheque Picture "@E 999,999.99" Size 040,010 object xoVlCheque

//@ 07,220 SAY xoV4 var OemToAnsi("Juros: ") of oDlgchq FONT oFnt2 PIXEL SIZE 050,010 COLOR CLR_BLUE
//@ 07,246 Get xcVlJuros Picture "@E 999,999.99" Size 040,010 object xoVlJuros

@ 20,038 SAY "CMC7" of oDlgchq FONT oFnt1 PIXEL SIZE 050,010 COLOR CLR_RED
@ 20,100 GET xcCMC7 valid PegaCMC7() size 120,10 object xoCMC7
@ 43,014 SAY xoV3 var OemToAnsi("Banco: ") of oDlgchq FONT oFnt2 PIXEL SIZE 030,010 COLOR CLR_BLUE
@ 40,038 GET xcBanco valid NaoVazio() F3 "SA6" When .f. object xoBanco
@ 43,070 SAY xoV3 var OemToAnsi("Agencia: ") of oDlgchq FONT oFnt2 PIXEL SIZE 030,010 COLOR CLR_BLUE
@ 40,101 GET xcAgencia valid NaoVazio() When .f. object xoAgencia
@ 43,135 SAY xoV3 var OemToAnsi("Conta: ") of oDlgchq FONT oFnt2 PIXEL SIZE 030,010 COLOR CLR_BLUE
@ 40,165 GET xcConta   valid NaoVazio() When .f. SIZE 060,010 object xoConta
@ 55,014 SAY xoV3 var OemToAnsi("Num Cheque: ") of oDlgchq FONT oFnt2 PIXEL SIZE 030,010 COLOR CLR_BLUE
@ 55,055 GET xcCheque  valid Jaexiste() When .f. object xoCheque
@ 55,108 GET xcComp valid Calcdv123() When .f. object xoComp
@ 58,132 SAY xoV3 var OemToAnsi("Dv.1: ") of oDlgchq FONT oFnt2 PIXEL SIZE 030,010 COLOR CLR_BLUE
@ 55,155 GET xcDigito1  valid CalcDv1() When .f. object xodigito1
@ 58,165 SAY xoV3 var OemToAnsi("Dv.2: ") of oDlgchq FONT oFnt2 PIXEL SIZE 030,010 COLOR CLR_BLUE
@ 55,182 GET xcDigito2  Valid CalcDv2() When .f. object xodigito2
@ 58,192 SAY xoV3 var OemToAnsi("Dv.3: ") of oDlgchq FONT oFnt2 PIXEL SIZE 030,010 COLOR CLR_BLUE
@ 55,212 GET xcDigito3 valid CalcDv3() When .f. object xodigito3


@ 80,200 BMPBUTTON TYPE 1   ACTION MaisCheque()
@ 80,230 BMPBUTTON TYPE 2   ACTION Finaliza()

ACTIVATE MSDIALOG oDlgChq CENTERED

Return .t.

***************************************************
Static Function MaisCheque()

Close(oDlgChq)
_ret := .T.
Return(.T.)


***************************************************
Static Function Finaliza()

Close(oDlgChq)
_ret := .F.

Return(.F.)

***********************************************
Static function PegaCMC7()

//xcCmc7   := SubStr(xcCmc7,3,35)

xcBanco  := Subs(xcCMC7,2,3)
xcAgencia:= Subs(xcCMC7,5,4)+" "
xcConta  := StrZero(Val(Subs(xcCMC7,26,7)),10)
xcConta1 := StrZero(Val(Subs(xcCMC7,23,10)),10)
xcCheque := Subs(xcCMC7,14,6)+Space(9)
xcComp   := Subs(xcCMC7,11,3)

xoBanco:Refresh()
xoAgencia:Refresh()
xoConta:Refresh()
xoCheque:Refresh()

xx:=0

xcBancoV := xcBanco+xcAgencia
	
nByte11 := 2 * Val(Subs(xcBancoV  ,7,1))
nByte10 := 1 * Val(Subs(xcBancoV  ,6,1))
nByte9  := 2 * Val(Subs(xcBancoV  ,5,1))
nByte8  := 1 * Val(Subs(xcBancoV  ,4,1))
nByte7  := 2 * Val(Subs(xcBancoV  ,3,1))
nByte6  := 1 * Val(Subs(xcBancoV  ,2,1))
nByte5  := 2 * Val(Subs(xcBancoV  ,1,1))
nByte11 := IIf(nByte11>9,Val(SubStr(AllTrim(Str(nByte11)),1,1))+Val(SubStr(AllTrim(Str(nByte11)),2,1)),nByte11)
nByte10 := IIf(nByte10>9,Val(SubStr(AllTrim(Str(nByte10)),1,1))+Val(SubStr(AllTrim(Str(nByte10)),2,1)),nByte10)
nByte9  := IIf(nByte9>9,Val(SubStr(AllTrim(Str(nByte9)),1,1))+Val(SubStr(AllTrim(Str(nByte9)),2,1)),nByte9)
nByte8  := IIf(nByte8>9,Val(SubStr(AllTrim(Str(nByte8)),1,1))+Val(SubStr(AllTrim(Str(nByte8)),2,1)),nByte8)
nByte7  := IIf(nByte7>9,Val(SubStr(AllTrim(Str(nByte7)),1,1))+Val(SubStr(AllTrim(Str(nByte7)),2,1)),nByte7)
nByte6  := IIf(nByte6>9,Val(SubStr(AllTrim(Str(nByte6)),1,1))+Val(SubStr(AllTrim(Str(nByte6)),2,1)),nByte6)
nByte5  := IIf(nByte5>9,Val(SubStr(AllTrim(Str(nByte5)),1,1))+Val(SubStr(AllTrim(Str(nByte5)),2,1)),nByte5)
nTotByte:= (nByte5+nByte6+nByte7+nByte8+nByte9+nByte10+nByte11)
	
nAchaC1 := mod(nTotByte,10)

if nAchaC1 == 0
	xcC1 := "0"
else
	xcC1 := Alltrim(Str((10 - nAchaC1)))
endif
	
xcChequeV := xcComp+AllTrim(xcCheque)+"5"
	
nByte11 := 2 * Val(Subs(xcChequeV,10,1))
nByte10 := 1 * Val(Subs(xcChequeV ,9,1))
nByte9  := 2 * Val(Subs(xcChequeV ,8,1))
nByte8  := 1 * Val(Subs(xcChequeV ,7,1))
nByte7  := 2 * Val(Subs(xcChequeV ,6,1))
nByte6  := 1 * Val(Subs(xcChequeV ,5,1))
nByte5  := 2 * Val(Subs(xcChequeV ,4,1))
nByte4  := 1 * Val(Subs(xcChequeV ,3,1))
nByte3  := 2 * Val(Subs(xcChequeV ,2,1))
nByte2  := 1 * Val(Subs(xcChequeV ,1,1))
	
nByte11 := IIf(nByte11>9,Val(SubStr(AllTrim(Str(nByte11)),1,1))+Val(SubStr(AllTrim(Str(nByte11)),2,1)),nByte11)
nByte10 := IIf(nByte10>9,Val(SubStr(AllTrim(Str(nByte10)),1,1))+Val(SubStr(AllTrim(Str(nByte10)),2,1)),nByte10)
nByte9  := IIf(nByte9>9,Val(SubStr(AllTrim(Str(nByte9)),1,1))+Val(SubStr(AllTrim(Str(nByte9)),2,1)),nByte9)
nByte8  := IIf(nByte8>9,Val(SubStr(AllTrim(Str(nByte8)),1,1))+Val(SubStr(AllTrim(Str(nByte8)),2,1)),nByte8)
nByte7  := IIf(nByte7>9,Val(SubStr(AllTrim(Str(nByte7)),1,1))+Val(SubStr(AllTrim(Str(nByte7)),2,1)),nByte7)
nByte6  := IIf(nByte6>9,Val(SubStr(AllTrim(Str(nByte6)),1,1))+Val(SubStr(AllTrim(Str(nByte6)),2,1)),nByte6)
nByte5  := IIf(nByte5>9,Val(SubStr(AllTrim(Str(nByte5)),1,1))+Val(SubStr(AllTrim(Str(nByte5)),2,1)),nByte5)
nByte4  := IIf(nByte4>9,Val(SubStr(AllTrim(Str(nByte4)),1,1))+Val(SubStr(AllTrim(Str(nByte4)),2,1)),nByte4)
nByte3  := IIf(nByte3>9,Val(SubStr(AllTrim(Str(nByte3)),1,1))+Val(SubStr(AllTrim(Str(nByte3)),2,1)),nByte3)
nByte2  := IIf(nByte2>9,Val(SubStr(AllTrim(Str(nByte2)),1,1))+Val(SubStr(AllTrim(Str(nByte2)),2,1)),nByte2)
nTotByte:= (nByte2+nByte3+nByte4+nByte5+nByte6+nByte7+nByte8+nByte9+nByte10+nByte11)
	
nAchaC2 := Mod(nTotByte,10)
	
if nAchaC2 == 0
	xcC2 := "0"
else
	xcC2 := Alltrim(Str((10 - nAchaC2)))
endif
	
xcContaV := xcConta1

nByte11 := 2 * Val(Subs(xcContaV,10,1))
nByte10 := 1 * Val(Subs(xcContaV ,9,1))
nByte9  := 2 * Val(Subs(xcContaV ,8,1))
nByte8  := 1 * Val(Subs(xcContaV ,7,1))
nByte7  := 2 * Val(Subs(xcContaV ,6,1))
nByte6  := 1 * Val(Subs(xcContaV ,5,1))
nByte5  := 2 * Val(Subs(xcContaV ,4,1))
nByte4  := 1 * Val(Subs(xcContaV ,3,1))
nByte3  := 2 * Val(Subs(xcContaV ,2,1))
nByte2  := 1 * Val(Subs(xcContaV ,1,1))
nByte11 := IIf(nByte11>9,Val(SubStr(AllTrim(Str(nByte11)),1,1))+Val(SubStr(AllTrim(Str(nByte11)),2,1)),nByte11)
nByte10 := IIf(nByte10>9,Val(SubStr(AllTrim(Str(nByte10)),1,1))+Val(SubStr(AllTrim(Str(nByte10)),2,1)),nByte10)
nByte9  := IIf(nByte9>9,Val(SubStr(AllTrim(Str(nByte9)),1,1))+Val(SubStr(AllTrim(Str(nByte9)),2,1)),nByte9)
nByte8  := IIf(nByte8>9,Val(SubStr(AllTrim(Str(nByte8)),1,1))+Val(SubStr(AllTrim(Str(nByte8)),2,1)),nByte8)
nByte7  := IIf(nByte7>9,Val(SubStr(AllTrim(Str(nByte7)),1,1))+Val(SubStr(AllTrim(Str(nByte7)),2,1)),nByte7)
nByte6  := IIf(nByte6>9,Val(SubStr(AllTrim(Str(nByte6)),1,1))+Val(SubStr(AllTrim(Str(nByte6)),2,1)),nByte6)
nByte5  := IIf(nByte5>9,Val(SubStr(AllTrim(Str(nByte5)),1,1))+Val(SubStr(AllTrim(Str(nByte5)),2,1)),nByte5)
nByte4  := IIf(nByte4>9,Val(SubStr(AllTrim(Str(nByte4)),1,1))+Val(SubStr(AllTrim(Str(nByte4)),2,1)),nByte4)
nByte3  := IIf(nByte3>9,Val(SubStr(AllTrim(Str(nByte3)),1,1))+Val(SubStr(AllTrim(Str(nByte3)),2,1)),nByte3)
nByte2  := IIf(nByte2>9,Val(SubStr(AllTrim(Str(nByte2)),1,1))+Val(SubStr(AllTrim(Str(nByte2)),2,1)),nByte2)
nTotByte:= (nByte2+nByte3+nByte4+nByte5+nByte6+nByte7+nByte8+nByte9+nByte10+nByte11)

nAchaC3 := Mod(nTotByte,10)
	
if nAchaC3 == 0
	xcC3 := "0"
else
	xcC3 := Alltrim(Str((10 - nAchaC3)))
endif
	                        
zC1 := SubStr(xcCMC7, 22, 1)
zC2 := SubStr(xcCMC7,  9, 1)
zC3 := SubStr(xcCMC7, 33, 1)
	
If xcC1 # zC1
	MsgStop("CMC7 Invalido!!! Verifique..Posicao 22 -> " + xcC1)
	xcCMC7 := Space(35)
	xoCmc7:Setfocus()
	Return .f.
Endif
	
If xcC2 # zC2
	MsgStop("CMC7 Invalido!!! Verifique..Posicao 09 -> " + xcC2)
	xcCMC7 := Space(35)
	xoCmc7:Setfocus()
	Return .f.
Endif

If xcC3 # zC3
	MsgStop("CMC7 Invalido!!! Verifique..Posicao 33 -> " + xcC3)
	xcCMC7 := Space(35)
	xoCmc7:Setfocus()
	Return .f.
Endif   

For I := 1 to 34
	If I <>  1 .And.;
	   I <> 10 .And.;
	   I <> 21 .And.;
	   I <> 34
	   If !(Subs(xcCMC7,I,1) $ '0/1/2/3/4//5/6/7/8/9')
			MsgStop("CMC7 Invalido!!! Verifique..Posicao... -> " + Str(I))
			xcCMC7 := Space(35)
			xoCmc7 :Setfocus()
			Return .f.
		Endif   
	Endif	
Next I     


xcDigito1:= xcC1
xcDigito2:= xcC2
xcDigito3:= xcC3
	
xoBanco:Refresh()
xoAgencia:Refresh()
xoConta:Refresh()
xoCheque:Refresh()
xoComp:Refresh()
xoDigito1:Refresh()
xoDigito2:Refresh()
xoDigito3:Refresh()

Return .t.
