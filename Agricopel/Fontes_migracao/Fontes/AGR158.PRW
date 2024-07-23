#include "rwmake.ch"
#INCLUDE "COLORS.CH"

User Function AGR158()

PRIVATE oDlg    := Nil, oCon := Nil, oCan := Nil, oPar := Nil

/*
¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
¤¤ ¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥ ¤¤
¤¤ ¥¥+-------------+---------------------------------------------+¥¥ ¤¤
¤¤ ¥¥| Cliente     | Agricopel                                   |¥¥ ¤¤
¤¤ ¥¥+-------------+---------------------------------------------+¥¥ ¤¤
¤¤ ¥¥| DescriCAO   | Conversão do cadastro de Clientes cod ANP   |¥¥ ¤¤
¤¤ ¥¥+-------------+---------------------------------------------+¥¥ ¤¤
¤¤ ¥¥| Programador | Deco                                        |¥¥ ¤¤
¤¤ ¥¥+-------------+---------------------------------------------+¥¥ ¤¤
¤¤ ¥¥| Elaborado em| 11/02/05                                    |¥¥ ¤¤
¤¤ ¥¥+-------------+---------------------------------------------+¥¥ ¤¤
¤¤ ¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥ ¤¤
¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
*/                  

If !MsgYesNO("Programa Conversão Clientes (Cod ANP/Cod Atividade/Cod Mun) deseja continuar?")
	Return
Endif

cPerg       := "AGR158" 
cPerg       := cPerg+SPACE(10-Len(cPerg))
aRegistros  := {}

Aadd(aRegistros,{cPerg,"01","Arquivo Origem ?	","mv_ch1","C",30,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})

AjustaPar(cPerg,aRegistros)

cCliente   := ""
cLoja      := ""
cAtivida   := ""
cInstAnp   := ""
cCodMun    := ""
nConta     := 0

if pergunte(cPerg,.t.)
	Processa( CONVCli() )
endif

Return

Static Function CONVCli()

LOCAL nHandle  := 0, nConta := 0
LOCAL cArquivo := Alltrim(mv_par01), cStr := ""
LOCAL cMsg     := ""

SA1->(DbSetOrder(1))                 // filial+cod+loja           
SZT->(DbSetOrder(1))                 // filial+cep

If (nHandle := FT_FUSE(AllTrim(cArquivo))) == -1
	Return
EndIf                

ProcRegua(1)
FT_FGOTOP()
While !FT_FEOF()
	
	cStr := FT_FREADLN()

   cMsg := "Gravando Cliente....."+alltrim(Substr(cStr,001,06))+" Loja..."+alltrim(Substr(cStr,007,02))
	Incproc(cMsg)	   

                 
   cCliente   := alltrim(Substr(cStr,001,06))
   cLoja      := alltrim(Substr(cStr,007,02))
   
//	cAtivida   := alltrim(Substr(cStr,117,05))
//	cInstAnp   := alltrim(Substr(cStr,123,07))
//	cCodMun    := alltrim(Substr(cStr,131,04)) 
	cCodMun    := alltrim(Substr(cStr,009,05)) 
		
	dbSelectArea("SA1")                // * Cadastro de Clientes
	dbSetOrder(1)
	If dbSeek(xFilial("SA1")+Substr(cStr,001,06)+Substr(cStr,007,02),.T.)
   
		RecLock("SA1",.F.)
//		SA1->A1_ATIVIDA		:= cAtivida
//		SA1->A1_INSTANP		:= cInstAnp
		SA1->A1_COD_MUN		:= cCodMun 
		MsUnlock('SA1')
		
		DbSelectArea("SZT")
		DbSetOrder(1)
		dbSeek(xFilial("SZT")+SA1->A1_CEP)    
		While !Eof() .and. SZT->ZT_FILIAL == xFilial("SZT") .And.;
		                   SZT->ZT_CEP    == SA1->A1_CEP
			RecLock("SZT",.F.)
			SZT->ZT_COD_MUN		:= cCodMun 
			MsUnlock('SZT')
			
			DbSkip()
		End   
			
	EndIf      

   FT_FSKIP()

   nConta := nConta + 1
   
End

FT_FUSE()

msgstop("Quantidade de Clientes's importados = "+str(nConta))
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
												aPer[_l,23],aPer[_l,24],""         ,""       ,aPer[_l,25],aPer[_l,26],"","","","",""})
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
